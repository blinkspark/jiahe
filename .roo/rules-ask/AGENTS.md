# Project Documentation Rules (Non-Obvious Only)

- **Frontend structure**: The `app/lib/` directory follows GetX pattern: `pages/` for screens, `controllers/` for business logic, `services/` for API clients, `components/` for reusable widgets.
- **Backend extensions**: Custom routes are defined in `main.go` under `app.OnServe().BindFunc`. Key routes: `/down_url/{id}` (OSS pre‑signed GET), `/presign/{path}` (OSS pre‑signed PUT), `/api/myapp/settings` (placeholder).
- **Data model**: PocketBase collections include `users`, `albums`, `photos`, `follows`, `album_permissions`, `objects`. Relationships are managed via expand and reference fields.
- **Authentication flow**: Users authenticate via PocketBase's built‑in email/password auth; tokens are stored in `pb.authStore` and automatically included in API requests.
- **File storage strategy**: User‑uploaded photos are stored in PocketBase's `photos` collection with file content; drive files are stored in OSS with metadata in `objects` collection.
- **Sharing model**: Album sharing uses `album_permissions` collection with `readers` and `writers` arrays; sharing is managed via `AppStateController.shareAlbum`/`unshareAlbum`.
- **Chinese language**: UI strings are in Chinese; font `NotoSansSC` is bundled via `google_fonts` directory with OFL license.
- **Deployment notes**: Frontend builds for multiple platforms (Android, iOS, Web, desktop). Backend requires OSS credentials and can be deployed as a standalone PocketBase binary.