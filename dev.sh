#!/bin/bash

# AP Study Project クイック開発スクリプト
# 重複コンテナを自動停止して開発環境を起動

cd "$(dirname "$0")"

# scripts/dev-setup.sh を呼び出し
exec ./scripts/dev-setup.sh "$@"