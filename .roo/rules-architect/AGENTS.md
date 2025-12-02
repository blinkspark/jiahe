# Project Architecture Rules (Non-Obvious Only)

- **Monolithic backend**: The backend is a single PocketBase instance with custom Go hooks; all business logic (hash generation, OSS operations) is implemented as PocketBase event handlers.
- **OSS integration pattern**: OSS operations are performed via Alibaba Cloud SDK with pre‑signed URLs; the backend never stores files locally, only metadata.
- **Frontend state isolation**: `AppStateController` is the single source of truth for auth and upload state; all other controllers depend on it via GetX dependency injection.
- **File upload duality**: Photos are uploaded to PocketBase's built‑in file system, while drive files are uploaded directly to OSS via pre‑signed URLs. This creates two distinct storage paths.
- **Collection‑based access control**: Permission checks are implemented at the PocketBase collection level using filters and hooks; there is no separate RBAC layer.
- **Path‑based drive navigation**: The drive mimics a file system using the `objects` collection with `type` ("folder"/"file") and `key` as the relative path; navigation is purely path‑based.
- **Image processing pipeline**: Thumbnails are generated on‑the‑fly by PocketBase's image service; full‑size images are served directly from OSS to reduce backend load.
- **Data retention policy**: Deleting a photo from an album does not immediately delete the photo record; a 30‑day delay is intentionally hard‑coded to allow recovery.
- **Cross‑platform considerations**: The frontend uses conditional compilation (`kIsWeb`) to handle file I/O differences; hash calculation is skipped on web due to stream limitations.
- **Environment‑driven configuration**: Missing OSS credentials will cause OSS operations to fail silently; the backend will still run but file operations will not work.