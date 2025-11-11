package main

import (
	"crypto/sha512"
	"encoding/hex"
	"io"
	"log"
	"net/http"

	"github.com/pocketbase/pocketbase"
	"github.com/pocketbase/pocketbase/apis"
	"github.com/pocketbase/pocketbase/core"
)

func main() {
	app := pocketbase.New()

	app.OnServe().BindFunc(func(se *core.ServeEvent) error {
		// register "GET /hello/{name}" route (allowed for everyone)
		se.Router.GET("/hello/{name}", func(e *core.RequestEvent) error {
			name := e.Request.PathValue("name")

			return e.String(http.StatusOK, "Hello "+name)
		})

		// register "POST /api/myapp/settings" route (allowed only for authenticated users)
		se.Router.POST("/api/myapp/settings", func(e *core.RequestEvent) error {
			// do something ...
			return e.JSON(http.StatusOK, map[string]bool{"success": true})
		}).Bind(apis.RequireAuth())

		return se.Next()
	})

	app.OnRecordCreate("photos").BindFunc(func(e *core.RecordEvent) error {
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

	if err := app.Start(); err != nil {
		log.Fatal(err)
	}
}
