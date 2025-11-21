# Jiahe - 家和相册

[English](#jiahe---family-photo-album) | [中文](#家和---家庭相册)

## Jiahe - Family Photo Album

Jiahe is a family-oriented photo sharing application built with Flutter and Go. It allows families to create private photo albums, share photos among family members, and manage their precious memories securely.

### Features

- **User Authentication**: Secure login and registration system
- **Album Management**: Create, edit, and organize photo albums
- **Photo Sharing**: Share photos with family members
- **Follow System**: Follow other users to see their shared albums
- **Cross-platform Support**: Runs on mobile devices (iOS/Android) and desktop platforms
- **Dark/Light Theme**: Supports both light and dark themes based on system preferences

### Tech Stack

- **Frontend**: Flutter/Dart with GetX for state management
- **Backend**: Go with PocketBase as the backend framework
- **Storage**: Alibaba Cloud OSS for image storage
- **Authentication**: PocketBase authentication system

### Getting Started

#### Prerequisites

- Flutter SDK 3.9.2 or higher
- Go 1.19 or higher
- Alibaba Cloud OSS account (for image storage)

#### Installation

1. Clone the repository:
   ```
   git clone <repository-url>
   ```

2. Install frontend dependencies:
   ```
   cd app
   flutter pub get
   ```

3. Configure environment variables:
   Create a `.env` file in the [app](file:///e:/dev/jiahe/app) directory with the required environment variables.

4. Run the application:
   ```
   ./start.sh -f    # Start frontend
   ./start.sh -d    # Start backend
   ```

### Project Structure

```
├── app/             # Flutter frontend application
│   ├── lib/         # Dart source code
│   │   ├── components/  # Reusable UI components
│   │   └── pages/       # Application pages
│   └── ...
├── backend/         # Go backend service
└── start.sh         # Startup script
```

### Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

### License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## 家和 - 家庭相册

家和是一个基于Flutter和Go构建的面向家庭的照片分享应用。它允许家庭成员创建私人相册，在家庭成员之间分享照片，并安全地管理珍贵的回忆。

### 功能特性

- **用户认证**: 安全的登录和注册系统
- **相册管理**: 创建、编辑和组织相册
- **照片分享**: 与家庭成员分享照片
- **关注系统**: 关注其他用户以查看他们分享的相册
- **跨平台支持**: 支持移动设备(iOS/Android)和桌面平台
- **主题切换**: 支持根据系统偏好设置亮色和暗色主题

### 技术栈

- **前端**: 使用GetX进行状态管理的Flutter/Dart
- **后端**: 使用PocketBase框架的Go语言
- **存储**: 阿里云OSS用于图片存储
- **认证**: PocketBase认证系统

### 快速开始

#### 前提条件

- Flutter SDK 3.9.2 或更高版本
- Go 1.19 或更高版本
- 阿里云OSS账户（用于图片存储）

#### 安装步骤

1. 克隆仓库:
   ```
   git clone <repository-url>
   ```

2. 安装前端依赖:
   ```
   cd app
   flutter pub get
   ```

3. 配置环境变量:
   在[app](file:///e:/dev/jiahe/app)目录下创建一个`.env`文件，包含所需的环境变量。

4. 运行应用:
   ```
   ./start.sh -f    # 启动前端
   ./start.sh -d    # 启动后端
   ```

### 项目结构

```
├── app/             # Flutter前端应用
│   ├── lib/         # Dart源代码
│   │   ├── components/  # 可复用UI组件
│   │   └── pages/       # 应用页面
│   └── ...
├── backend/         # Go后端服务
└── start.sh         # 启动脚本
```

### 贡献

欢迎贡献！请随时提交Pull Request。

### 许可证

该项目采用 Apache License 2.0 许可证 - 详情请见[LICENSE](LICENSE)文件。