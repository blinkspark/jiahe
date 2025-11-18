#!/bin/bash

BACKEND_DIR="backend/"
FRONTEND_DIR="app/"

function start_backend() {
  cd $BACKEND_DIR
  go run . serve --http 192.168.3.219:8090
  cd ..
}
function start_frontend() {
  cd $FRONTEND_DIR
  flutter run -d windows
  cd ..
}

# 解析命令行参数
while getopts "fda" opt; do
  case $opt in
    f)
      start_frontend
      ;;
    d)
      start_backend
      ;;
    \?)
      echo "无效选项: -$OPTARG" >&2
      exit 1
      ;;
  esac
done

# 如果没有提供参数，则显示使用说明
if [ $OPTIND -eq 1 ]; then
  echo "用法: $0 [-f] [-d] [-a]"
  echo "  -f: 启动前端"
  echo "  -d: 启动后端"
  exit 1
fi
