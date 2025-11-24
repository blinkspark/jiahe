# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Jiahe (家和) is a family-oriented photo sharing application built with Flutter and Go. It allows families to create private photo albums, share photos among family members, and manage their precious memories securely.

**Tech Stack:**
- **Frontend**: Flutter/Dart with GetX for state management
- **Backend**: Go with PocketBase as the backend framework
- **Storage**: Alibaba Cloud OSS for image storage
- **Authentication**: PocketBase authentication system

## Development Commands

### Running the Application

Use the `start.sh` script to run the application:

```bash
# Start frontend only
./start.sh -f

# Start frontend on specific device
./start.sh -f "device_id"

# Start backend only
./start.sh -d
```

### Frontend Development (Flutter)

```bash
cd app

# Install dependencies
flutter pub get

# Run in development mode
flutter run

# Build for production
flutter build apk
flutter build ios
flutter build web
```

### Backend Development (Go)

```bash
cd backend

# Run the backend server
go run . serve --http 192.168.3.219:8090

# Build for production
go build
```

## Architecture

### Frontend Structure (`app/lib/`)

- **`main.dart`**: Application entry point with GetX routing setup
- **`state.dart`**: Central state management using GetX controller (`AppStateController`)
- **`pages/`**: Application screens (login, albums, photo view, follows, etc.)
- **`components/`**: Reusable UI components (dialogs, photo grid, etc.)

Key architectural patterns:
- **GetX** for state management and dependency injection
- **PocketBase** client for backend API communication
- **GetStorage** for local storage (authentication persistence)
- **Material Design** with Google Fonts and theme support

### Backend Structure (`backend/`)

- **`main.go`**: PocketBase server with custom routes and hooks
- **OSS Integration**: Alibaba Cloud OSS for image storage and presigned URLs
- **PocketBase Hooks**: Automatic photo hash generation on upload
- **Custom API Routes**: `/test/{bucket}/{key}` for OSS presigned URLs

### Authentication & Data Flow

1. **Authentication**: PocketBase handles user auth with JWT tokens
2. **State Management**: `AppStateController` manages auth state, upload progress, and UI state
3. **File Upload**: Photos are uploaded to PocketBase, which generates SHA-512 hashes and stores metadata
4. **Image Serving**: OSS presigned URLs are used for secure image access
5. **Album Sharing**: Follow system and album permissions for family sharing

## Configuration

### Environment Variables

Frontend (`.env` in `app/` directory):
```
BASE_URL=https://pb.nealplay001.asia/
```

Backend requires these environment variables for OSS:
- `OSS_REGION`: Alibaba Cloud OSS region
- `OSS_ACCESS_KEY_ID`: OSS access key
- `OSS_ACCESS_KEY_SECRET`: OSS secret key

### PocketBase Collections

The application uses these main collections:
- `users`: User accounts and profiles
- `albums`: Photo albums with owner and permissions
- `photos`: Photo metadata and file references
- `follows`: User following relationships
- `almub_permissions`: Album sharing permissions (note: typo in collection name)

## Development Notes

### State Management

The `AppStateController` in `state.dart` is the central state manager:
- Authentication state and user data
- Upload progress and status
- Navigation state (home page index)
- All API calls through PocketBase client

### File Upload Process

1. User selects files via `file_picker`
2. Files are processed with SHA-512 hash generation
3. Upload progress is tracked with Rx observables
4. Photos are created in PocketBase with metadata
5. Photo IDs are added to album's photos array

### Image Display

- Thumbnails use PocketBase's built-in image processing
- Full-size images use OSS presigned URLs via custom backend route
- Photo caching with `cached_network_image`

### Cross-Platform Considerations

- Web vs native file handling differences
- Font licensing (Google Fonts OFL license bundled)
- Platform-specific UI adaptations

## Testing

Run Flutter tests:
```bash
cd app
flutter test
```

## Deployment

- Frontend: Built for target platforms (Android, iOS, Web)
- Backend: PocketBase server with OSS integration
- Requires Alibaba Cloud OSS account for image storage