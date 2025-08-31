#!/bin/bash

# ========================================
# VPS アプリケーションデプロイスクリプト
# ap-study-backend の自動デプロイ
# ========================================

set -e

# 色付きログ
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log() {
    echo -e "${GREEN}[$(date +'%Y-%m-%d %H:%M:%S')] $1${NC}"
}

warn() {
    echo -e "${YELLOW}[$(date +'%Y-%m-%d %H:%M:%S')] WARNING: $1${NC}"
}

error() {
    echo -e "${RED}[$(date +'%Y-%m-%d %H:%M:%S')] ERROR: $1${NC}"
    exit 1
}

# 設定値
APP_DIR="/var/www/ap-study"
BACKEND_DIR="$APP_DIR/ap-study-backend"
LOG_DIR="/var/log/ap-study"
BACKUP_DIR="/var/backups"

# ========================================
# デプロイ前バックアップ
# ========================================

backup_before_deploy() {
    log "💾 デプロイ前バックアップ作成..."
    
    # データベースバックアップ
    timestamp=$(date +%Y%m%d_%H%M%S)
    backup_file="$BACKUP_DIR/pre_deploy_$timestamp.sql"
    
    log "🗄️ データベースバックアップ作成: $backup_file"
    sudo -u postgres pg_dump -h localhost -U ap_study_user ap_study > "$backup_file"
    
    # アプリケーションコードバックアップ
    if [ -d "$BACKEND_DIR" ]; then
        log "📦 アプリコードバックアップ作成..."
        tar -czf "$BACKUP_DIR/app_backup_$timestamp.tar.gz" -C "$APP_DIR" ap-study-backend
    fi
    
    log "✅ バックアップ完了"
}

# ========================================
# アプリケーションデプロイ
# ========================================

deploy_application() {
    log "🚀 アプリケーションデプロイ開始..."
    
    # アプリディレクトリに移動
    cd "$APP_DIR"
    
    # 初回クローンまたは更新
    if [ ! -d ".git" ]; then
        log "📥 初回リポジトリクローン..."
        git clone https://github.com/USERNAME/ap-study-project.git temp_repo
        mv temp_repo/* .
        mv temp_repo/.* . 2>/dev/null || true
        rm -rf temp_repo
    else
        log "🔄 リポジトリ更新..."
        git fetch origin
        git reset --hard origin/main
    fi
    
    # バックエンドディレクトリに移動
    cd "$BACKEND_DIR"
    
    # 依存関係インストール
    log "📦 依存関係インストール..."
    npm ci --production
    
    # 本番ビルド
    log "🔨 本番ビルド実行..."
    npm run build
    
    # 環境変数コピー
    log "⚙️ 本番環境変数設定..."
    cp .env.production .env
    
    # Prismaマイグレーション
    log "🗄️ データベースマイグレーション実行..."
    npx prisma migrate deploy
    
    # Prisma Client生成
    log "🔧 Prisma Client生成..."
    npx prisma generate
    
    # シードデータ投入（初回のみ）
    if [ ! -f "/tmp/seed_completed" ]; then
        log "🌱 シードデータ投入..."
        npm run seed || warn "シードデータ投入でエラーが発生しましたが続行します"
        touch /tmp/seed_completed
    fi
    
    log "✅ アプリケーションデプロイ完了"
}

# ========================================
# PM2プロセス管理
# ========================================

setup_pm2_process() {
    log "⚙️ PM2プロセス管理設定..."
    
    cd "$BACKEND_DIR"
    
    # 既存プロセス停止
    pm2 delete ap-study-backend 2>/dev/null || true
    
    # PM2でアプリ起動
    log "🚀 PM2でアプリケーション起動..."
    pm2 start ecosystem.config.js
    
    # プロセス保存
    pm2 save
    
    # 状態確認
    log "📊 PM2プロセス状態確認..."
    pm2 status
    
    log "✅ PM2設定完了"
}

# ========================================
# ヘルスチェック・動作確認
# ========================================

health_check() {
    log "🏥 ヘルスチェック開始..."
    
    # サービス状態確認
    log "🔍 サービス状態確認..."
    systemctl is-active --quiet postgresql || error "PostgreSQL not running"
    systemctl is-active --quiet nginx || error "Nginx not running"
    
    # アプリケーション起動確認
    log "📱 アプリケーション起動確認..."
    sleep 5
    
    if curl -f http://localhost:8000/ > /dev/null 2>&1; then
        log "✅ アプリケーション正常起動"
    else
        error "❌ アプリケーション起動失敗"
    fi
    
    # API エンドポイント確認
    log "🔗 API エンドポイント確認..."
    if curl -f http://localhost:8000/api/studylog > /dev/null 2>&1; then
        log "✅ API エンドポイント正常"
    else
        warn "⚠️ API エンドポイントに問題がある可能性があります"
    fi
    
    # 外部アクセス確認
    external_ip=$(curl -s ipinfo.io/ip)
    log "🌐 外部アクセスURL: http://$external_ip/"
    
    log "✅ ヘルスチェック完了"
}

# ========================================
# 完了報告
# ========================================

deployment_summary() {
    log "📋 デプロイ完了サマリー"
    log ""
    log "🎯 アプリケーション情報:"
    log "  - アプリ名: ap-study-backend"
    log "  - ポート: 8000"
    log "  - プロセス管理: PM2"
    log "  - リバースプロキシ: Nginx"
    log ""
    log "📡 アクセス情報:"
    external_ip=$(curl -s ipinfo.io/ip)
    log "  - 外部URL: http://$external_ip/"
    log "  - API Base: http://$external_ip/api/"
    log "  - ヘルスチェック: http://$external_ip/"
    log ""
    log "🔧 管理コマンド:"
    log "  - 状態確認: ap-status"
    log "  - ログ確認: ap-logs"
    log "  - 再起動: ap-restart"
    log "  - 再デプロイ: ap-deploy"
    log "  - バックアップ: ap-backup"
    log ""
    log "📊 次のステップ:"
    log "1. Vercelでフロントエンド環境変数更新"
    log "   NEXT_PUBLIC_API_URL=http://$external_ip"
    log "2. フロントエンドからAPI接続テスト"
    log "3. SSL証明書設定（ドメイン取得後）"
}

# ========================================
# メイン実行
# ========================================

main() {
    log "🚀 ap-study-backend VPSデプロイ開始..."
    
    # 実行確認
    read -p "ConoHa VPS基本セットアップは完了していますか？ (y/N): " confirm
    if [[ ! $confirm =~ ^[Yy]$ ]]; then
        error "まず vps-setup.sh を実行してください"
    fi
    
    # 各フェーズ実行
    backup_before_deploy
    deploy_application
    setup_pm2_process
    health_check
    deployment_summary
    
    log "🎉 デプロイ完了！"
}

# スクリプト実行
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi