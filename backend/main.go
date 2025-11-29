package main

import (
	"context"
	"crypto/sha512"
	"encoding/hex"
	"io"
	"log"
	"net/http"
	"net/url"
	"os"
	"path"
	"time"

	"github.com/aliyun/alibabacloud-oss-go-sdk-v2/oss"
	"github.com/aliyun/alibabacloud-oss-go-sdk-v2/oss/credentials"
	"github.com/joho/godotenv"
	"github.com/pocketbase/pocketbase"
	"github.com/pocketbase/pocketbase/apis"
	"github.com/pocketbase/pocketbase/core"
)

func main() {
	err := godotenv.Load()
	if err != nil {
		log.Fatalf("Error loading .env file: %v", err)
	}
	app := pocketbase.New()
	cfg := oss.LoadDefaultConfig().WithCredentialsProvider(credentials.NewEnvironmentVariableCredentialsProvider()).WithRegion(os.Getenv("OSS_REGION"))
	ossClient := oss.NewClient(cfg)
	bucket := os.Getenv("OSS_BUCKET")

	app.OnServe().BindFunc(func(se *core.ServeEvent) error {
		se.Router.GET("/test/{bucket}/{key}", func(e *core.RequestEvent) error {
			bucket := e.Request.PathValue("bucket")
			key := e.Request.PathValue("key")
			decKey, err := url.PathUnescape(key)
			if err != nil {
				return err
			}
			res, err := ossClient.Presign(context.Background(), &oss.GetObjectRequest{
				Bucket: oss.Ptr(bucket),
				Key:    oss.Ptr(decKey),
			},
				oss.PresignExpires(time.Hour))
			if err != nil {
				return err
			}
			return e.String(http.StatusOK, res.URL)
		}).Bind()

		se.Router.GET("/presign/{path}", func(e *core.RequestEvent) error {
			reqPath := e.Request.PathValue("path")
			objs, err := app.FindCollectionByNameOrId("objects")
			if err != nil {
				return err
			}
			key := path.Join(objs.Id, e.Auth.Id, reqPath)

			res, err := ossClient.Presign(context.Background(), &oss.PutObjectRequest{
				Bucket: oss.Ptr(bucket),
				Key:    oss.Ptr(key),
			}, oss.PresignExpires(time.Minute*10))
			if err != nil {
				return err
			}
			app.Logger().Debug("presign", "url", res.SignedHeaders)

			return e.String(http.StatusOK, res.URL)
		}).Bind(apis.RequireAuth())

		// register "POST /api/myapp/settings" route (allowed only for authenticated users)
		se.Router.POST("/api/myapp/settings", func(e *core.RequestEvent) error {
			// do something ...
			return e.JSON(http.StatusOK, map[string]bool{"success": true})
		}).Bind(apis.RequireAuth())

		return se.Next()
	})

	app.OnRecordCreate("photos").BindFunc(func(e *core.RecordEvent) error {
		h := e.Record.GetString("hash")
		if h != "" {
			return e.Next()
		}
		files := e.Record.GetUnsavedFiles("content")
		for _, file := range files {
			reader, err := file.Reader.Open()
			if err != nil {
				return err
			}
			defer reader.Close()
			hasher := sha512.New()
			_, err = io.Copy(hasher, reader)
			if err != nil {
				return err
			}
			hash := hasher.Sum(nil)
			e.Record.Set("hash", hex.EncodeToString(hash))
		}
		return e.Next()
	})

	app.OnRecordAfterCreateSuccess("users").BindFunc(func(e *core.RecordEvent) error {
		// create default album
		albums, err := app.FindCollectionByNameOrId("albums")
		if err != nil {
			return err
		}
		album := core.NewRecord(albums)
		album.Set("name", "默认相册")
		album.Set("owner", e.Record.Id)

		err = app.Save(album)
		if err != nil {
			return err
		}

		objects, err := app.FindCollectionByNameOrId("objects")
		if err != nil {
			return err
		}

		object := core.NewRecord(objects)
		object.Set("name", "/")
		object.Set("owner", e.Record.Id)
		object.Set("type", "folder")

		err = app.Save(object)
		if err != nil {
			return err
		}

		return e.Next()
	})

	app.OnRecordDelete("objects").BindFunc(func(e *core.RecordEvent) error {
		key := path.Join(e.Record.Id, e.Record.GetString("owner"), e.Record.GetString("key"))
		app.Logger().Debug("delete", "key", key)

		res, err := ossClient.DeleteObject(e.Context, &oss.DeleteObjectRequest{
			Bucket: oss.Ptr(bucket),
			Key:    oss.Ptr(key),
		})
		if err != nil {
			return err
		}

		app.Logger().Debug("delete", "res", res)

		return e.Next()
	})

	if err := app.Start(); err != nil {
		log.Fatal(err)
	}
}
