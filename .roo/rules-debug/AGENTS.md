# Project Debug Rules (Non-Obvious Only)

- **Log locations**: Frontend logs are printed to console via `Logger` (injected via `Get.find`). Backend logs are printed to stdout via PocketBase's built‑in logger.
- **OSS failures silent**: Missing OSS environment variables cause uploads/downloads to fail without explicit error messages; check backend logs for "Presign" or "DeleteObject" errors.
- **Photo hash mismatch**: If photo uploads fail with hash errors, ensure the file stream is re‑readable (non‑web platforms) and that the same stream is used for both hash calculation and upload.
- **Drive upload progress**: Upload progress is tracked via `DriveController.uploadProgress` but may not update smoothly due to direct OSS PUT; monitor network traffic instead.
- **PocketBase admin UI**: Accessible at `http://127.0.0.1:8090/_/` for inspecting collections and records during debugging.
- **Image loading failures**: Thumbnails may fail if PocketBase's file service is not running; full‑size images may fail if OSS credentials are incorrect (check `/down_url/{id}` response).
- **Database schema changes**: The backend uses PocketBase's built‑in SQLite; schema changes require manual migration via PocketBase admin UI or `schema.json`.
- **Cross‑platform file picker**: On web, `file_picker` returns a `PlatformFile` with `readStream`; on native, it provides a `path`. Handle accordingly to avoid stream errors.