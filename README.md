# Jiahe - 家和相册

[English](#jiahe---family-photo-album) | [中文](#家和---家庭相册)

## Jiahe - Family Photo Album

Jiahe is a family-oriented photo sharing and file management application built with Flutter and Go. It allows families to create private photo albums, share photos among family members, manage files via a built‑in drive, and securely store memories with Alibaba Cloud OSS integration.

### Features

- **User Authentication**: Secure login and registration via PocketBase.
- **Album Management**: Create, edit, organize, and share photo albums.
- **Photo Sharing**: Share photos with family members and follow other users.
- **Drive/File Management**: Upload, download, and organize files in a folder‑based drive.
- **Video Playback**: Built‑in video player for videos stored in albums or drive.
- **Cross‑platform Support**: Runs on mobile (iOS/Android), desktop, and web.
- **Theme Support**: Automatic light/dark theme based on system preference.
- **Duplicate Detection**: SHA‑512 hash‑based duplicate photo detection.
- **Automatic Defaults**: On registration, a default album and root folder are created automatically.
- **OSS Integration**: Seamless storage with Alibaba Cloud OSS; file deletions are synchronized.

### Tech Stack

- **Frontend**: Flutter/Dart with GetX for state management.
- **Backend**: Go with PocketBase as the backend framework (embedded database, real‑time API).
- **Storage**: Alibaba Cloud OSS for scalable object storage.
- **Authentication**: PocketBase’s built‑in authentication system.
- **Image Processing**: PocketBase’s built‑in thumbnail generation and OSS pre‑signed URLs for full‑size images.
- **Video Playback**: `media_kit` for cross‑platform video playback.

### Getting Started

#### Prerequisites

- Flutter SDK 3.9.2 or higher
- Go 1.19 or higher
- Alibaba Cloud OSS account (for image storage)
- PocketBase (embedded in the backend, no separate installation needed)

#### Installation

1. Clone the repository:
   ```
   git clone <repository-url>
   cd jiahe
   ```

2. Install frontend dependencies:
   ```
   cd app
   flutter pub get
   ```

3. Configure environment variables:

   **Frontend** (`app/.env`):
   ```
   BASE_URL=http://127.0.0.1:8090/
   ```
   (Must end with a slash.)

   **Backend** (set in shell or `.env` in the backend directory):
   ```
   OSS_REGION=your-oss-region
   OSS_ACCESS_KEY_ID=your-access-key-id
   OSS_ACCESS_KEY_SECRET=your-access-key-secret
   OSS_BUCKET=your-bucket-name
   ```

4. Run the application:

   Use the provided `start.sh` script for convenience:
   ```
   ./start.sh -f          # Start frontend only (default device)
   ./start.sh -f "device" # Start frontend on a specific device
   ./start.sh -d          # Start backend only
   ./start.sh -a          # Start both frontend and backend
   ```

   The backend will run on `127.0.0.1:8090` by default.

### Project Structure

```
jiahe/
├── app/                     # Flutter frontend
│   ├── lib/
│   │   ├── components/      # Reusable UI components
│   │   ├── controllers/     # GetX controllers
│   │   ├── pages/          # Application pages
│   │   ├── services/       # API and business logic
│   │   └── state.dart      # Central AppStateController
│   ├── assets/
│   └── pubspec.yaml
├── backend/                 # Go backend
│   ├── main.go             # PocketBase hooks and custom routes
│   └── go.mod
├── start.sh                # Unified startup script
├── AGENTS.md               # Project‑specific guidance for agents
└── LICENSE                 # Apache 2.0 license
```

### Key Architectural Details

- **Photo Upload Hash**: Backend automatically computes SHA‑512 hash of uploaded photos via PocketBase hook (`OnRecordCreate` on `photos` collection). The hash is stored for duplicate detection.
- **Default Album & Folder**: When a user registers, the backend creates a "默认相册" album and a root folder in the `objects` collection.
- **OSS Synchronization**: File deletions in the `objects` collection trigger automatic deletion of the corresponding OSS object.
- **Drive Uploads**: Frontend obtains pre‑signed PUT URLs from `/presign/{path}` and uploads directly to OSS, then creates a record in PocketBase.
- **Image Display**: Thumbnails via PocketBase's built‑in processing (`/api/files/...?thumb=200x200`). Full‑size images via OSS pre‑signed URLs from `/down_url/{id}`.

### Environment Variables

| Variable | Purpose | Required |
|----------|---------|----------|
| `BASE_URL` | PocketBase instance URL (frontend) | Yes |
| `OSS_REGION` | Alibaba Cloud OSS region | Yes |
| `OSS_ACCESS_KEY_ID` | OSS access key ID | Yes |
| `OSS_ACCESS_KEY_SECRET` | OSS access key secret | Yes |
| `OSS_BUCKET` | OSS bucket name | Yes |

Missing OSS variables will cause silent failures in file operations.

### Testing

Currently, no unit or integration tests are written. Running `flutter test` inside `app/` will find zero tests.

### Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

### License

This project is licensed under the Apache License 2.0 - see the [LICENSE](LICENSE) file for details.

---

## 家和 - 家庭相册

家和是一个基于Flutter和Go构建的面向家庭的相册分享与文件管理应用。它允许家庭成员创建私人相册，在家庭成员之间分享照片，通过内置网盘管理文件，并利用阿里云OSS安全地存储记忆。

### 功能特性

- **用户认证**: 通过PocketBase实现安全的登录和注册。
- **相册管理**: 创建、编辑、组织和分享相册。
- **照片分享**: 与家庭成员分享照片，并关注其他用户。
- **网盘/文件管理**: 在基于文件夹的网盘中上传、下载和组织文件。
- **视频播放**: 内置视频播放器，可播放相册或网盘中的视频。
- **跨平台支持**: 支持移动设备(iOS/Android)、桌面和Web。
- **主题支持**: 根据系统偏好自动切换亮色/暗色主题。
- **重复检测**: 基于SHA‑512哈希的照片重复检测。
- **自动创建默认内容**: 用户注册时自动创建“默认相册”和根文件夹。
- **OSS集成**: 与阿里云OSS无缝集成；文件删除会自动同步。

### 技术栈

- **前端**: 使用GetX进行状态管理的Flutter/Dart。
- **后端**: 使用PocketBase框架的Go语言（嵌入式数据库、实时API）。
- **存储**: 阿里云OSS用于可扩展的对象存储。
- **认证**: PocketBase内置认证系统。
- **图片处理**: PocketBase内置缩略图生成，全尺寸图片使用OSS预签名URL。
- **视频播放**: 使用`media_kit`实现跨平台视频播放。

### 快速开始

#### 前提条件

- Flutter SDK 3.9.2 或更高版本
- Go 1.19 或更高版本
- 阿里云OSS账户（用于图片存储）
- PocketBase（已嵌入后端，无需单独安装）

#### 安装步骤

1. 克隆仓库:
   ```
   git clone <repository-url>
   cd jiahe
   ```

2. 安装前端依赖:
   ```
   cd app
   flutter pub get
   ```

3. 配置环境变量:

   **前端** (`app/.env`):
   ```
   BASE_URL=http://127.0.0.1:8090/
   ```
   （必须以斜杠结尾。）

   **后端**（在shell或backend目录下的`.env`中设置）:
   ```
   OSS_REGION=你的OSS区域
   OSS_ACCESS_KEY_ID=你的访问密钥ID
   OSS_ACCESS_KEY_SECRET=你的访问密钥密钥
   OSS_BUCKET=你的桶名称
   ```

4. 运行应用:

   使用提供的 `start.sh` 脚本方便启动:
   ```
   ./start.sh -f          # 仅启动前端（默认设备）
   ./start.sh -f "设备ID" # 在指定设备上启动前端
   ./start.sh -d          # 仅启动后端
   ./start.sh -a          # 同时启动前端和后端
   ```

   后端默认运行在 `127.0.0.1:8090`。

### 项目结构

```
jiahe/
├── app/                     # Flutter前端
│   ├── lib/
│   │   ├── components/      # 可复用UI组件
│   │   ├── controllers/     # GetX控制器
│   │   ├── pages/          # 应用页面
│   │   ├── services/       # API和业务逻辑
│   │   └── state.dart      # 中央AppStateController
│   ├── assets/
│   └── pubspec.yaml
├── backend/                 # Go后端
│   ├── main.go             # PocketBase钩子和自定义路由
│   └── go.mod
├── start.sh                # 统一启动脚本
├── AGENTS.md               # 面向代理的项目特定指南
└── LICENSE                 # Apache 2.0 许可证
```

### 关键架构细节

- **照片上传哈希**: 后端通过PocketBase钩子（`photos`集合的`OnRecordCreate`）自动计算上传照片的SHA‑512哈希值，用于重复检测。
- **默认相册和文件夹**: 用户注册时，后端自动创建“默认相册”和在`objects`集合中的根文件夹。
- **OSS同步**: `objects`集合中的文件删除会触发对应OSS对象的自动删除。
- **网盘上传**: 前端从`/presign/{path}`获取预签名的PUT URL，直接上传到OSS，然后在PocketBase中创建记录。
- **图片显示**: 缩略图通过PocketBase内置处理（`/api/files/...?thumb=200x200`）获取；全尺寸图片通过`/down_url/{id}`获取的OSS预签名URL。

### 环境变量

| 变量名 | 用途 | 是否必需 |
|--------|------|----------|
| `BASE_URL` | PocketBase实例URL（前端） | 是 |
| `OSS_REGION` | 阿里云OSS区域 | 是 |
| `OSS_ACCESS_KEY_ID` | OSS访问密钥ID | 是 |
| `OSS_ACCESS_KEY_SECRET` | OSS访问密钥密钥 | 是 |
| `OSS_BUCKET` | OSS桶名称 | 是 |

缺少OSS变量会导致文件操作静默失败。

### 测试

目前尚未编写单元测试或集成测试。在`app/`目录下运行`flutter test`将找不到任何测试。

### 贡献

欢迎贡献！请随时提交Pull Request。

### 许可证

本项目采用 Apache License 2.0 许可证 - 详情请见[LICENSE](LICENSE)文件。