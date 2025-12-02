# Project Coding Rules (Non-Obvious Only)

- **State management**: Always use `AppStateController` (in `state.dart`) for authentication and upload state; do not create separate controllers for these purposes.
- **Photo uploads**: The backend automatically computes SHA‑512 hash; frontend must provide file stream that can be re‑read for hash calculation (non‑web platforms). Use `sha512.bind(fstream).first` from `crypto` package.
- **Drive uploads**: Use `DriveService` which obtains pre‑signed PUT URLs from `/presign/{path}` and uploads directly to OSS with `Dio`. The same stream is used for hash calculation and upload, ensure it is re‑readable.
- **Image display**: Thumbnails via PocketBase's built‑in processing (`/api/files/...?thumb=200x200`). Full‑size images via OSS pre‑signed URLs from `/down_url/{id}`.
- **Collection IDs**: The `objects` collection ID is used in OSS key construction (`{collectionId}/{userId}/{key}`). Do not hardcode collection names; use `collection().Id` from PocketBase.
- **Album photo deletion**: When removing a photo from an album, the photo record is not deleted immediately; actual deletion occurs after a 30‑day delay (see `deletePhotoFromAlbum` comment). This is intentional to allow recovery.
- **Error handling**: Use `Get.snackbar` for user‑facing errors in controllers; log technical details with `Logger` (injected via `Get.find`).
- **Environment variables**: Frontend requires `BASE_URL` ending with `/`; backend requires OSS credentials (`OSS_REGION`, `OSS_ACCESS_KEY_ID`, `OSS_ACCESS_KEY_SECRET`, `OSS_BUCKET`). Missing OSS vars will cause silent failures in file operations.