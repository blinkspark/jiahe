# AGENTS.md

This file provides guidance to agents when working with code in this repository.

## Non-Obvious Project-Specific Information

### Build/Run Commands
- Use `./start.sh` for convenient startup (not standard Flutter/Go commands):
  - `./start.sh -f` – start frontend only (default device)
  - `./start.sh -f "device_id"` – start frontend on specific device
  - `./start.sh -d` – start backend only
  - `./start.sh -a` – start both frontend and backend
- Backend runs on `127.0.0.1:8090` by default (configurable in start.sh).
- Frontend expects `BASE_URL` in `.env` (points to PocketBase instance).

### Hidden Architectural Behaviors
- **Photo upload hash generation**: Backend automatically computes SHA‑512 hash of uploaded photos via PocketBase hook (`OnRecordCreate` on `photos` collection). The hash is stored in the `hash` field and can be used for duplicate detection.
- **Default album & folder creation**: When a user registers, the backend automatically creates a "默认相册" album and a root folder object in the `objects` collection (see `OnRecordAfterCreateSuccess` for `users`).
- **OSS integration**: File deletions in the `objects` collection trigger automatic deletion of the corresponding Alibaba Cloud OSS object (via `OnRecordDelete` hook).
- **Drive uploads use pre‑signed URLs**: The frontend's `DriveService` obtains a pre‑signed PUT URL from `/presign/{path}` and uploads directly to OSS, then creates a record in PocketBase.

### Code Patterns
- **State management**: Central `AppStateController` (in `state.dart`) manages authentication, upload progress, and UI state. It is a GetX controller injected via `Get.put`.
- **Image display**: Thumbnails use PocketBase's built‑in image processing (`/api/files/...?thumb=200x200`). Full‑size images are served via OSS pre‑signed URLs obtained from `/down_url/{id}`.
- **Drive file listing**: The `DriveController` uses `DriveService` which communicates with PocketBase's `objects` collection; folder navigation is path‑based.

### Environment Variables
- **Frontend** (`app/.env`): `BASE_URL` (must end with `/`).
- **Backend** (set in shell or `.env`): `OSS_REGION`, `OSS_ACCESS_KEY_ID`, `OSS_ACCESS_KEY_SECRET`, `OSS_BUCKET`. Missing these will cause OSS operations to fail.

### Testing
- No unit or integration tests are currently written. Running `flutter test` inside `app/` will find zero tests.

### Gotchas
- The `objects` collection stores file metadata; its `key` field is the relative path within the user's folder. OSS object key is constructed as `{collectionId}/{userId}/{key}`.
- When deleting a photo from an album, the photo record is **not immediately deleted** – it is only removed from the album's `photos` array. Actual deletion occurs after a 30‑day delay (see `deletePhotoFromAlbum` comment).
- The `drive_service.dart` uses `Dio` for uploads; the stream must be re‑readable because the same stream is used for hash calculation and upload (on non‑web platforms).