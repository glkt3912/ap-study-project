#!/bin/bash

# ========================================
# ConoHa VPS セットアップスクリプト
# ap-study-project 自動環境構築
# ========================================

set -e  # エラー時に停止

# 色付きログ
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

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

# ========================================
# Phase 1: システム基盤構築
# ========================================

setup_system() {
    log "🔧 システム基盤構築を開始..."
    
    # システム更新
    log "📦 システムパッケージ更新..."
    apt update && apt upgrade -y
    
    # 基本パッケージインストール
    log "🛠️ 基本パッケージインストール..."
    apt install -y curl wget git vim ufw fail2ban htop tree
    
    # タイムゾーン設定
    log "🕐 タイムゾーン設定..."
    timedatectl set-timezone Asia/Tokyo
    
    log "✅ システム基盤構築完了"
}

# ========================================
# Phase 2: セキュリティ設定
# ========================================

setup_security() {
    log "🛡️ セキュリティ設定を開始..."
    
    # ファイアウォール設定
    log "🔥 ファイアウォール設定..."
    ufw default deny incoming
    ufw default allow outgoing
    ufw allow ssh
    ufw allow 80
    ufw allow 443
    echo "y" | ufw enable
    
    # fail2ban設定
    log "🚫 fail2ban設定..."
    systemctl enable fail2ban
    systemctl start fail2ban
    
    # SSH設定強化
    log "🔐 SSH設定強化..."
    sed -i 's/#PermitRootLogin yes/PermitRootLogin yes/' /etc/ssh/sshd_config
    sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config
    systemctl restart ssh
    
    log "✅ セキュリティ設定完了"
}

# ========================================
# Phase 3: Node.js 22 インストール
# ========================================

setup_nodejs() {
    log "🟢 Node.js 22 インストールを開始..."
    
    # NodeSource repository追加
    log "📦 NodeSource repository追加..."
    curl -fsSL https://deb.nodesource.com/setup_22.x | bash -
    
    # Node.js インストール
    log "📥 Node.js 22 インストール..."
    apt install -y nodejs
    
    # バージョン確認
    log "🔍 Node.js バージョン確認..."
    node_version=$(node --version)
    npm_version=$(npm --version)
    log "Node.js: $node_version"
    log "npm: $npm_version"
    
    # PM2インストール
    log "⚙️ PM2プロセス管理ツールインストール..."
    npm install -g pm2
    
    # PM2自動起動設定
    log "🚀 PM2自動起動設定..."
    pm2 startup
    
    log "✅ Node.js環境構築完了"
}

# ========================================
# Phase 4: PostgreSQL インストール・設定
# ========================================

setup_postgresql() {
    log "🐘 PostgreSQL 15 インストールを開始..."
    
    # PostgreSQL インストール
    log "📥 PostgreSQL インストール..."
    apt install -y postgresql postgresql-contrib
    
    # 自動起動設定
    log "🚀 PostgreSQL自動起動設定..."
    systemctl enable postgresql
    systemctl start postgresql
    
    # データベース・ユーザー作成
    log "🗄️ データベース・ユーザー作成..."
    sudo -u postgres psql -c "CREATE DATABASE ap_study;"
    sudo -u postgres psql -c "CREATE USER ap_study_user WITH PASSWORD 'secure_password_123';"
    sudo -u postgres psql -c "GRANT ALL PRIVILEGES ON DATABASE ap_study TO ap_study_user;"
    sudo -u postgres psql -c "ALTER USER ap_study_user CREATEDB;"
    
    # PostgreSQL設定調整
    log "⚙️ PostgreSQL設定調整..."
    PG_VERSION=$(psql --version | awk '{print $3}' | sed 's/\..*//')
    PG_CONFIG="/etc/postgresql/$PG_VERSION/main/postgresql.conf"
    
    # 接続設定
    sed -i "s/#listen_addresses = 'localhost'/listen_addresses = 'localhost'/" $PG_CONFIG
    sed -i "s/#port = 5432/port = 5432/" $PG_CONFIG
    
    # メモリ設定（512MB VPS対応・最小構成）
    sed -i "s/#shared_buffers = 128MB/shared_buffers = 128MB/" $PG_CONFIG
    sed -i "s/#effective_cache_size = 4GB/effective_cache_size = 256MB/" $PG_CONFIG
    sed -i "s/#max_connections = 100/max_connections = 30/" $PG_CONFIG
    
    # 設定反映
    systemctl restart postgresql
    
    # 接続テスト
    log "🔍 PostgreSQL接続テスト..."
    if sudo -u postgres psql -d ap_study -c "SELECT version();" > /dev/null 2>&1; then
        log "✅ PostgreSQL接続成功"
    else
        error "❌ PostgreSQL接続失敗"
    fi
    
    log "✅ PostgreSQL設定完了"
}

# ========================================
# Phase 5: Nginx インストール・設定
# ========================================

setup_nginx() {
    log "🌐 Nginx インストール・設定を開始..."
    
    # Nginx インストール
    log "📥 Nginx インストール..."
    apt install -y nginx
    
    # ディレクトリ作成
    log "📁 ディレクトリ作成..."
    mkdir -p /var/www/ap-study
    mkdir -p /var/log/ap-study
    
    # Nginx設定ファイル作成
    log "⚙️ Nginx設定ファイル作成..."
    cat > /etc/nginx/sites-available/ap-study << 'EOF'
server {
    listen 80;
    server_name _;  # IPアドレスでアクセス許可

    # セキュリティヘッダー
    add_header X-Content-Type-Options nosniff;
    add_header X-Frame-Options DENY;
    add_header X-XSS-Protection "1; mode=block";
    add_header Referrer-Policy strict-origin-when-cross-origin;

    # API プロキシ
    location /api/ {
        proxy_pass http://localhost:8000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_cache_bypass $http_upgrade;
        
        # CORS対応
        add_header Access-Control-Allow-Origin "https://ap-study-app.vercel.app" always;
        add_header Access-Control-Allow-Methods "GET, POST, PUT, DELETE, OPTIONS" always;
        add_header Access-Control-Allow-Headers "Content-Type, Authorization, X-Requested-With" always;
        add_header Access-Control-Allow-Credentials true always;
        
        # Preflight対応
        if ($request_method = 'OPTIONS') {
            return 204;
        }
    }

    # ヘルスチェック
    location / {
        proxy_pass http://localhost:8000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }

    # ログ設定
    access_log /var/log/nginx/ap-study.access.log;
    error_log /var/log/nginx/ap-study.error.log;
}
EOF

    # サイト有効化
    log "🔗 サイト有効化..."
    ln -sf /etc/nginx/sites-available/ap-study /etc/nginx/sites-enabled/
    rm -f /etc/nginx/sites-enabled/default
    
    # Nginx設定テスト
    log "🧪 Nginx設定テスト..."
    nginx -t
    
    # Nginx起動
    log "🚀 Nginx起動..."
    systemctl enable nginx
    systemctl start nginx
    systemctl reload nginx
    
    log "✅ Nginx設定完了"
}

# ========================================
# Phase 6: アプリケーション環境準備
# ========================================

setup_application() {
    log "📱 アプリケーション環境準備を開始..."
    
    # アプリディレクトリ作成
    log "📁 アプリディレクトリ作成..."
    mkdir -p /var/www/ap-study
    mkdir -p /var/log/ap-study
    chmod 755 /var/www/ap-study
    chmod 755 /var/log/ap-study
    
    # Git設定
    log "🔧 Git設定..."
    git config --global init.defaultBranch main
    git config --global user.name "VPS Deploy"
    git config --global user.email "deploy@ap-study.local"
    
    log "✅ アプリケーション環境準備完了"
}

# ========================================
# Phase 7: システム監視・ログ設定
# ========================================

setup_monitoring() {
    log "📊 システム監視・ログ設定を開始..."
    
    # logrotate設定（ログローテーション）
    log "🔄 ログローテーション設定..."
    cat > /etc/logrotate.d/ap-study << 'EOF'
/var/log/ap-study/*.log {
    daily
    missingok
    rotate 14
    compress
    delaycompress
    notifempty
    copytruncate
    su root root
}
EOF

    # システム監視用エイリアス
    log "📋 便利コマンドエイリアス設定..."
    cat >> /root/.bashrc << 'EOF'

# ap-study-project管理エイリアス
alias ap-status='pm2 status && systemctl status nginx postgresql'
alias ap-logs='pm2 logs --lines 50'
alias ap-restart='pm2 restart ap-study-backend'
alias ap-deploy='cd /var/www/ap-study && git pull && cd ap-study-backend && npm ci && npm run build && pm2 reload ap-study-backend'
alias ap-backup='pg_dump -h localhost -U ap_study_user ap_study > /var/backups/ap_study_$(date +%Y%m%d_%H%M).sql'
alias ap-monitor='htop'
EOF

    # バックアップディレクトリ作成
    log "💾 バックアップディレクトリ作成..."
    mkdir -p /var/backups
    chmod 700 /var/backups
    
    # 日次バックアップcron設定
    log "⏰ 自動バックアップ設定..."
    echo "0 3 * * * root pg_dump -h localhost -U ap_study_user ap_study > /var/backups/ap_study_\$(date +\%Y\%m\%d).sql 2>/dev/null" >> /etc/crontab
    
    log "✅ システム監視・ログ設定完了"
}

# ========================================
# メイン実行
# ========================================

main() {
    log "🚀 ConoHa VPS セットアップ開始..."
    log "📋 対象: ap-study-project Node.js + PostgreSQL環境"
    
    # 各フェーズ実行
    setup_system
    setup_security  
    setup_nodejs
    setup_postgresql
    setup_nginx
    setup_application
    setup_monitoring
    
    # 完了報告
    log "🎉 ConoHa VPS セットアップ完了！"
    log ""
    log "📋 次のステップ:"
    log "1. アプリケーションデプロイ: ap-deploy"
    log "2. 状態確認: ap-status"
    log "3. ログ確認: ap-logs"
    log "4. 監視: ap-monitor"
    log ""
    log "📡 アクセスURL: http://$(curl -s ipinfo.io/ip)/"
    log "🔧 管理コマンド: ap-status, ap-logs, ap-restart, ap-deploy"
    log ""
    log "💰 月額コスト: ¥583（ConoHa VPS 1GBプラン）"
    log "🎓 学習効果: Linux・Nginx・PostgreSQL・Node.js運用スキル"
}

# スクリプト実行
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi