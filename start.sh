#!/bin/bash

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 配置
BACKEND_DIR="backend/"
FRONTEND_DIR="app/"
BACKEND_HOST="127.0.0.1"
BACKEND_PORT="8090"

# 日志函数
log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }
log_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }

# 清理函数
cleanup() {
    log_info "正在停止所有服务..."
    if [ ! -z "$BACKEND_PID" ]; then
        kill $BACKEND_PID 2>/dev/null
        log_success "后端服务已停止"
    fi
    if [ ! -z "$FRONTEND_PID" ]; then
        kill $FRONTEND_PID 2>/dev/null
        log_success "前端服务已停止"
    fi
    exit 0
}

# 检查依赖
check_dependencies() {
    log_info "检查系统依赖..."

    # 检查目录
    if [ ! -d "$BACKEND_DIR" ]; then
        log_error "后端目录 $BACKEND_DIR 不存在"
        exit 1
    fi

    if [ ! -d "$FRONTEND_DIR" ]; then
        log_error "前端目录 $FRONTEND_DIR 不存在"
        exit 1
    fi

    # 检查命令
    if ! command -v go &> /dev/null; then
        log_error "Go 未安装或不在 PATH 中"
        exit 1
    fi

    if ! command -v flutter &> /dev/null; then
        log_error "Flutter 未安装或不在 PATH 中"
        exit 1
    fi

    log_success "依赖检查通过"
}

# 启动后端
start_backend() {
    log_info "启动后端服务..."
    cd "$BACKEND_DIR" || exit 1

    # 检查端口是否被占用
    if lsof -Pi :$BACKEND_PORT -sTCP:LISTEN -t >/dev/null 2>&1; then
        log_warning "端口 $BACKEND_PORT 已被占用，尝试终止现有进程..."
        lsof -ti:$BACKEND_PORT | xargs kill -9 2>/dev/null
        sleep 2
    fi

    go run . serve --http $BACKEND_HOST:$BACKEND_PORT
    BACKEND_PID=$!
    cd ..

    # 等待后端启动
    sleep 3
    if kill -0 $BACKEND_PID 2>/dev/null; then
        log_success "后端服务已启动 (PID: $BACKEND_PID)"
        log_info "后端地址: http://$BACKEND_HOST:$BACKEND_PORT"
    else
        log_error "后端服务启动失败"
        exit 1
    fi
}

# 启动前端
start_frontend() {
    local target_device="$1"
    log_info "启动前端服务..."
    cd "$FRONTEND_DIR" || exit 1

    # 获取 Flutter 设备列表
    if [ -n "$target_device" ]; then
        log_info "在指定设备上启动: $target_device"
        flutter run -d "$target_device"
    else
        log_info "在默认设备上启动"
        flutter run
    fi

    FRONTEND_PID=$!
    cd ..
    log_success "前端服务已启动 (PID: $FRONTEND_PID)"
}

# 显示可用设备
show_devices() {
    log_info "可用的 Flutter 设备:"
    cd "$FRONTEND_DIR" && flutter devices && cd ..
}

# 使用说明
show_usage() {
    echo "用法: $0 [选项]"
    echo ""
    echo "选项:"
    echo "  -f [device]    启动前端，可选择指定设备"
    echo "  -d             启动后端"
    echo "  -a [device]    同时启动前后端，可选择指定前端设备"
    echo "  -l             显示可用的 Flutter 设备列表"
    echo "  -h             显示此帮助信息"
    echo ""
    echo "示例:"
    echo "  $0 -f                    # 启动前端（默认设备）"
    echo "  $0 -f 'chrome'           # 在 Chrome 上启动前端"
    echo "  $0 -d                    # 启动后端"
    echo "  $0 -a                    # 同时启动前后端（前端使用默认设备）"
    echo "  $0 -a 'chrome'           # 同时启动前后端（前端在 Chrome 上启动）"
    echo "  $0 -l                    # 列出可用设备"
}

# 主程序
main() {
    # 设置信号处理
    trap cleanup SIGINT SIGTERM

    local start_frontend=false
    local start_backend=false
    local frontend_device=""
    local show_devices_flag=false

    # 解析命令行参数
    # 先处理简单的选项
    while [[ $# -gt 0 ]]; do
        case $1 in
            -d)
                start_backend=true
                shift
                ;;
            -a)
                start_frontend=true
                start_backend=true
                # 检查下一个参数是否是设备名称（不是以-开头的选项）
                if [[ $# -gt 1 && ! "$2" =~ ^- ]]; then
                    frontend_device="$2"
                    shift 2
                else
                    shift
                fi
                ;;
            -l)
                show_devices_flag=true
                shift
                ;;
            -h)
                show_usage
                exit 0
                ;;
            -f)
                start_frontend=true
                # 检查下一个参数是否是设备名称（不是以-开头的选项）
                if [[ $# -gt 1 && ! "$2" =~ ^- ]]; then
                    frontend_device="$2"
                    shift 2
                else
                    shift
                fi
                ;;
            *)
                log_error "无效选项: $1"
                show_usage
                exit 1
                ;;
        esac
    done

    # 如果没有提供参数，显示使用说明
    if [ "$show_devices_flag" = false ] && [ "$start_frontend" = false ] && [ "$start_backend" = false ]; then
        show_usage
        exit 1
    fi

    # 显示设备列表
    if [ "$show_devices_flag" = true ]; then
        show_devices
        exit 0
    fi

    # 检查依赖
    check_dependencies

    # 启动服务
    if [ "$start_backend" = true ]; then
        start_backend
    fi

    if [ "$start_frontend" = true ]; then
        start_frontend "$frontend_device"
    fi

    # 如果启动了服务，等待退出信号
    if [ "$start_backend" = true ] || [ "$start_frontend" = true ]; then
        log_info "服务正在运行，按 Ctrl+C 停止..."
        wait
    fi
}

# 运行主程序
main "$@"