#!/bin/bash

BACKEND_DIR="backend/"
FRONTEND_DIR="app/"

function start_backend() {
  cd $BACKEND_DIR
  go run . serve --http 192.168.3.219:8090
  cd ..
}

function start_frontend() {
  local target_device="$1"
  cd $FRONTEND_DIR
  if [ -n "$target_device" ]; then
    echo "Starting frontend on device: $target_device"
    flutter run -d "$target_device"
  else
    echo "Starting frontend on default device"
    flutter run
  fi
  cd ..
}

# 解析命令行参数
frontend_arg=""
while getopts "f::d" opt; do
  case $opt in
    f)
      frontend_arg="$OPTARG"
      start_frontend "$frontend_arg"
      ;;
    d)
      start_backend
      ;;
    \?)
      echo "无效选项: -$OPTARG" >&2
      exit 1
      ;;
    :)
      echo "选项 -$OPTARG 需要一个参数." >&2
      exit 1
      ;;
  esac
done

# 如果没有提供参数，则显示使用说明
if [ $OPTIND -eq 1 ]; then
  echo "用法: $0 [-f [device]] [-d]"
  echo "  -f [device]: 启动前端，可选择在指定设备上运行"
  echo "  -d: 启动后端"
  exit 1
fi