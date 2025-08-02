#!/bin/bash

# AP Study Project 開発環境管理スクリプト
# 重複コンテナの停止・削除と新規起動を自動化

set -e

# カラー出力用の定義
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# ログ出力関数
log() {
    echo -e "${BLUE}[$(date +'%Y-%m-%d %H:%M:%S')]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1" >&2
}

warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

# プロジェクトのルートディレクトリに移動
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
cd "$PROJECT_ROOT"

log "AP Study Project 開発環境セットアップを開始します..."
log "プロジェクトディレクトリ: $PROJECT_ROOT"

# 既存の重複プロセスを停止
stop_existing_processes() {
    log "既存プロセスの停止中..."
    
    # Next.js開発サーバーを停止
    if pgrep -f "next dev" > /dev/null; then
        warning "Next.js開発サーバーを停止中..."
        pkill -f "next dev" || true
        sleep 2
    fi
    
    # Node.js/tsx開発サーバーを停止
    if pgrep -f "tsx.*app.ts" > /dev/null; then
        warning "バックエンド開発サーバーを停止中..."
        pkill -f "tsx.*app.ts" || true
        sleep 2
    fi
    
    # 関連するDockerコンテナを停止
    if docker ps -q --filter "name=ap-study" | grep -q .; then
        warning "既存のDockerコンテナを停止中..."
        docker compose down || true
        sleep 3
    fi
    
    # 使用中のポートを確認・解放
    for port in 3000 3001 3002 8000; do
        if lsof -Pi :$port -sTCP:LISTEN -t >/dev/null 2>&1; then
            local pid=$(lsof -Pi :$port -sTCP:LISTEN -t)
            warning "ポート $port を使用中のプロセス ($pid) を停止中..."
            kill -9 $pid 2>/dev/null || true
        fi
    done
    
    success "既存プロセスの停止完了"
}

# Docker環境のクリーンアップ
cleanup_docker() {
    log "Docker環境のクリーンアップ中..."
    
    # 停止したコンテナを削除
    if docker ps -aq --filter "name=ap-study" | grep -q .; then
        docker rm $(docker ps -aq --filter "name=ap-study") 2>/dev/null || true
    fi
    
    # 不要なイメージを削除（optional）
    if [ "${CLEANUP_IMAGES:-false}" = "true" ]; then
        warning "古いイメージを削除中..."
        docker image prune -f || true
    fi
    
    success "Docker環境のクリーンアップ完了"
}

# データベースの準備
prepare_database() {
    log "データベースの準備中..."
    
    # PostgreSQLコンテナを先に起動
    docker compose up -d postgres
    
    # データベースの起動を待機
    log "PostgreSQLの起動を待機中..."
    local max_attempts=30
    local attempt=1
    
    while ! docker compose exec postgres pg_isready -U postgres >/dev/null 2>&1; do
        if [ $attempt -ge $max_attempts ]; then
            error "PostgreSQLの起動がタイムアウトしました"
            exit 1
        fi
        echo -n "."
        sleep 2
        ((attempt++))
    done
    echo ""
    
    success "PostgreSQL起動完了"
    
    # Prismaマイグレーションの実行
    log "データベースマイグレーション実行中..."
    cd ap-study-backend
    npm run db:generate || true
    npm run db:push || true
    
    # シードデータの投入
    if [ -f "src/infrastructure/database/seeds/seed-questions.ts" ]; then
        log "シードデータを投入中..."
        npx tsx src/infrastructure/database/seeds/seed-questions.ts || warning "シードデータの投入に失敗しました"
    fi
    
    cd "$PROJECT_ROOT"
    success "データベース準備完了"
}

# 開発環境の起動
start_development() {
    local mode="${1:-docker}"
    
    case $mode in
        "docker")
            log "Docker環境で開発サーバーを起動中..."
            docker compose up --build
            ;;
        "local")
            log "ローカル環境で開発サーバーを起動中..."
            
            # バックエンドを背景で起動
            cd ap-study-backend
            log "バックエンドサーバー起動中 (ポート8000)..."
            npm run dev &
            BACKEND_PID=$!
            cd "$PROJECT_ROOT"
            
            # 少し待ってからフロントエンド起動
            sleep 5
            
            # フロントエンドを起動
            cd ap-study-app
            log "フロントエンドサーバー起動中 (ポート3000)..."
            npm run dev &
            FRONTEND_PID=$!
            cd "$PROJECT_ROOT"
            
            # 起動ログ
            success "開発サーバー起動完了"
            log "フロントエンド: http://localhost:3000"
            log "バックエンド: http://localhost:8000"
            log "API仕様: http://localhost:8000/api"
            
            # 終了時のクリーンアップ
            trap "kill $BACKEND_PID $FRONTEND_PID 2>/dev/null || true" EXIT
            
            # プロセスの監視
            wait
            ;;
        *)
            error "無効なモード: $mode (docker|local)"
            exit 1
            ;;
    esac
}

# ヘルプメッセージ
show_help() {
    cat << EOF
AP Study Project 開発環境管理スクリプト

使用方法:
    $0 [オプション] [コマンド]

コマンド:
    start [docker|local]  開発サーバーを起動 (デフォルト: docker)
    stop                  全プロセスを停止
    restart [docker|local] プロセス停止後に再起動
    clean                 Docker環境をクリーンアップ
    db-setup             データベースのみをセットアップ
    status               サービスの状態を確認

オプション:
    --cleanup-images     Docker起動前に古いイメージを削除
    --help, -h          このヘルプを表示

例:
    $0 start docker      # Docker環境で起動
    $0 start local       # ローカル環境で起動
    $0 restart           # Docker環境で再起動
    $0 clean             # 環境クリーンアップ
    $0 db-setup          # データベースセットアップのみ

EOF
}

# サービス状態の確認
check_status() {
    log "サービス状態を確認中..."
    
    echo "=== Docker コンテナ ==="
    docker compose ps || echo "Docker Composeサービスが起動していません"
    
    echo ""
    echo "=== ポート使用状況 ==="
    for port in 3000 3001 3002 8000 5432; do
        if lsof -Pi :$port -sTCP:LISTEN -t >/dev/null 2>&1; then
            local pid=$(lsof -Pi :$port -sTCP:LISTEN -t)
            local process=$(ps -p $pid -o comm= 2>/dev/null || echo "unknown")
            echo "ポート $port: 使用中 (PID: $pid, プロセス: $process)"
        else
            echo "ポート $port: 利用可能"
        fi
    done
    
    echo ""
    echo "=== エンドポイント確認 ==="
    if curl -s http://localhost:8000/ >/dev/null 2>&1; then
        echo "✅ バックエンドAPI: http://localhost:8000/ (正常)"
    else
        echo "❌ バックエンドAPI: http://localhost:8000/ (接続不可)"
    fi
    
    if curl -s http://localhost:3000/ >/dev/null 2>&1; then
        echo "✅ フロントエンド: http://localhost:3000/ (正常)"
    else
        echo "❌ フロントエンド: http://localhost:3000/ (接続不可)"
    fi
}

# メイン処理
main() {
    # オプションの解析
    while [[ $# -gt 0 ]]; do
        case $1 in
            --cleanup-images)
                export CLEANUP_IMAGES=true
                shift
                ;;
            --help|-h)
                show_help
                exit 0
                ;;
            start)
                local mode="${2:-docker}"
                stop_existing_processes
                cleanup_docker
                prepare_database
                start_development "$mode"
                shift 2
                ;;
            stop)
                stop_existing_processes
                cleanup_docker
                success "全サービスを停止しました"
                shift
                ;;
            restart)
                local mode="${2:-docker}"
                stop_existing_processes
                cleanup_docker
                prepare_database
                start_development "$mode"
                shift 2
                ;;
            clean)
                stop_existing_processes
                cleanup_docker
                success "環境をクリーンアップしました"
                shift
                ;;
            db-setup)
                prepare_database
                shift
                ;;
            status)
                check_status
                shift
                ;;
            *)
                error "無効なコマンド: $1"
                show_help
                exit 1
                ;;
        esac
    done
    
    # コマンドが指定されない場合はヘルプを表示
    if [ $# -eq 0 ]; then
        show_help
    fi
}

# スクリプト実行
main "$@"