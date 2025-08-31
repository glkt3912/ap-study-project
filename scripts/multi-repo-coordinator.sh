#!/bin/bash

# =================================================================
# マルチリポジトリ連携改善スクリプト - 3層CI/CD統合版
# =================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
CONFIG_FILE="$PROJECT_ROOT/.pr-automation.config"

# 設定読み込み
source "$CONFIG_FILE" 2>/dev/null || {
    echo "⚠️ 設定ファイルが見つかりません"
    exit 1
}

# カラー定義
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info() { echo -e "${BLUE}ℹ️  $1${NC}"; }
log_success() { echo -e "${GREEN}✅ $1${NC}"; }
log_warning() { echo -e "${YELLOW}⚠️  $1${NC}"; }
log_error() { echo -e "${RED}❌ $1${NC}"; }

# マルチリポジトリ状況確認
check_multi_repo_status() {
    log_info "🔍 マルチリポジトリ状況確認中..."
    
    echo "## 📊 リポジトリ状況"
    
    # Backend status
    if [ -d "$BACKEND_DIR" ]; then
        cd "$BACKEND_DIR"
        local backend_branch=$(git rev-parse --abbrev-ref HEAD)
        local backend_status=$(git status --porcelain | wc -l)
        local backend_commits=$(git rev-list --count HEAD ^origin/main 2>/dev/null || echo "0")
        
        echo "### 🔧 Backend ($BACKEND_DIR)"
        echo "- **ブランチ**: $backend_branch"
        echo "- **未コミット変更**: $backend_status ファイル"
        echo "- **未プッシュコミット**: $backend_commits 個"
        
        if [ "$backend_status" -gt 0 ]; then
            echo "- **変更ファイル**:"
            git status --porcelain | head -5 | sed 's/^/  - /'
        fi
        
        cd "$PROJECT_ROOT"
    else
        echo "### ❌ Backend: ディレクトリが見つかりません"
    fi
    
    # Frontend status  
    if [ -d "$FRONTEND_DIR" ]; then
        cd "$FRONTEND_DIR"
        local frontend_branch=$(git rev-parse --abbrev-ref HEAD)
        local frontend_status=$(git status --porcelain | wc -l)
        local frontend_commits=$(git rev-list --count HEAD ^origin/main 2>/dev/null || echo "0")
        
        echo "### 🎨 Frontend ($FRONTEND_DIR)"
        echo "- **ブランチ**: $frontend_branch"
        echo "- **未コミット変更**: $frontend_status ファイル"
        echo "- **未プッシュコミット**: $frontend_commits 個"
        
        if [ "$frontend_status" -gt 0 ]; then
            echo "- **変更ファイル**:"
            git status --porcelain | head -5 | sed 's/^/  - /'
        fi
        
        cd "$PROJECT_ROOT"
    else
        echo "### ❌ Frontend: ディレクトリが見つかりません"
    fi
    
    # Root status
    local root_branch=$(git rev-parse --abbrev-ref HEAD)
    local root_status=$(git status --porcelain | wc -l)
    local root_commits=$(git rev-list --count HEAD ^origin/main 2>/dev/null || echo "0")
    
    echo "### 📁 Root Repository"
    echo "- **ブランチ**: $root_branch"
    echo "- **未コミット変更**: $root_status ファイル"
    echo "- **未プッシュコミット**: $root_commits 個"
    
    if [ "$root_status" -gt 0 ]; then
        echo "- **変更ファイル**:"
        git status --porcelain | head -5 | sed 's/^/  - /'
    fi
}

# 3層CI/CD統合状況確認
check_ci_integration() {
    log_info "🏗️ 3層CI/CD統合状況確認中..."
    
    echo "## 🤖 CI/CD ワークフロー状況"
    
    # Root monitoring workflows
    echo "### 📊 Root Repository (統合監視)"
    for workflow in monitor-backend-quality.yml monitor-frontend-quality.yml monitor-integration-health.yml; do
        if [ -f ".github/workflows/$workflow" ]; then
            echo "- ✅ $workflow"
        else
            echo "- ❌ $workflow (未実装)"
        fi
    done
    
    # Individual repository CIs
    echo "### ⚡ Individual Repository (高速実行)"
    
    if [ -d "$BACKEND_DIR/.github/workflows" ]; then
        echo "- ✅ $BACKEND_DIR/ci.yml"
        local backend_ci_count=$(ls "$BACKEND_DIR/.github/workflows/"*.yml 2>/dev/null | wc -l)
        echo "  - ワークフロー数: $backend_ci_count"
    else
        echo "- ❌ $BACKEND_DIR CI (未設定)"
    fi
    
    if [ -d "$FRONTEND_DIR/.github/workflows" ]; then
        echo "- ✅ $FRONTEND_DIR/ci.yml"
        local frontend_ci_count=$(ls "$FRONTEND_DIR/.github/workflows/"*.yml 2>/dev/null | wc -l)
        echo "  - ワークフロー数: $frontend_ci_count"
    else
        echo "- 📋 $FRONTEND_DIR CI (計画中)"
    fi
}

# 統合品質チェック
run_integrated_quality_check() {
    log_info "🔍 統合品質チェック実行中..."
    
    local overall_status=0
    
    # Backend quality check
    if [ -d "$BACKEND_DIR" ]; then
        echo "### 🔧 Backend Quality"
        cd "$BACKEND_DIR"
        
        if npm run build >/dev/null 2>&1; then
            echo "- ✅ Build: 成功"
        else
            echo "- ❌ Build: 失敗"
            overall_status=1
        fi
        
        if npm run lint >/dev/null 2>&1; then
            echo "- ✅ Lint: 成功" 
        else
            echo "- ❌ Lint: 失敗"
            overall_status=1
        fi
        
        local test_result=$(npm run test 2>&1 | grep -E "Tests.*failed.*passed" | tail -1 || echo "No test results")
        echo "- 📊 Tests: $test_result"
        
        cd "$PROJECT_ROOT"
    fi
    
    # Frontend quality check
    if [ -d "$FRONTEND_DIR" ]; then
        echo "### 🎨 Frontend Quality"
        cd "$FRONTEND_DIR"
        
        if npm run build >/dev/null 2>&1; then
            echo "- ✅ Build: 成功"
        else
            echo "- ❌ Build: 失敗"
            overall_status=1
        fi
        
        if npm run lint >/dev/null 2>&1; then
            echo "- ✅ Lint: 成功"
        else
            echo "- ❌ Lint: 失敗" 
            overall_status=1
        fi
        
        cd "$PROJECT_ROOT"
    fi
    
    return $overall_status
}

# マルチリポジトリ同期
sync_repositories() {
    log_info "🔄 マルチリポジトリ同期中..."
    
    # Root repository
    echo "### 📁 Root Repository"
    git fetch origin
    git status --porcelain
    
    # Backend repository
    if [ -d "$BACKEND_DIR" ]; then
        echo "### 🔧 Backend Repository"
        cd "$BACKEND_DIR"
        git fetch origin
        git status --porcelain
        cd "$PROJECT_ROOT"
    fi
    
    # Frontend repository  
    if [ -d "$FRONTEND_DIR" ]; then
        echo "### 🎨 Frontend Repository"
        cd "$FRONTEND_DIR"
        git fetch origin
        git status --porcelain
        cd "$PROJECT_ROOT"
    fi
}

# 統合PR作成
create_integrated_pr() {
    local feature_name="$1"
    local pr_description="$2"
    
    log_info "🚀 統合PR作成中: $feature_name"
    
    # Check changes in each repository
    local has_root_changes=false
    local has_backend_changes=false  
    local has_frontend_changes=false
    
    # Root changes
    if [ "$(git status --porcelain | wc -l)" -gt 0 ]; then
        has_root_changes=true
    fi
    
    # Backend changes
    if [ -d "$BACKEND_DIR" ]; then
        cd "$BACKEND_DIR"
        if [ "$(git status --porcelain | wc -l)" -gt 0 ]; then
            has_backend_changes=true
        fi
        cd "$PROJECT_ROOT"
    fi
    
    # Frontend changes
    if [ -d "$FRONTEND_DIR" ]; then
        cd "$FRONTEND_DIR" 
        if [ "$(git status --porcelain | wc -l)" -gt 0 ]; then
            has_frontend_changes=true
        fi
        cd "$PROJECT_ROOT"
    fi
    
    echo "## 🔍 変更検出結果"
    echo "- Root: $( [ "$has_root_changes" = true ] && echo "✅ 変更あり" || echo "❌ 変更なし" )"
    echo "- Backend: $( [ "$has_backend_changes" = true ] && echo "✅ 変更あり" || echo "❌ 変更なし" )"
    echo "- Frontend: $( [ "$has_frontend_changes" = true ] && echo "✅ 変更あり" || echo "❌ 変更なし" )"
    
    # Create PRs for repositories with changes
    if [ "$has_root_changes" = true ]; then
        log_info "📁 Root Repository PR作成中..."
        "$PROJECT_ROOT/scripts/pr-automation.sh" pr "$feature_name - Root Changes"
    fi
    
    if [ "$has_backend_changes" = true ]; then
        log_info "🔧 Backend Repository PR作成中..."
        cd "$BACKEND_DIR"
        if [ -f "./scripts/pr-automation.sh" ]; then
            ./scripts/pr-automation.sh pr "$feature_name - Backend Implementation"
        else
            log_warning "Backend PR自動化スクリプトが見つかりません"
        fi
        cd "$PROJECT_ROOT"
    fi
    
    if [ "$has_frontend_changes" = true ]; then
        log_info "🎨 Frontend Repository PR作成中..."
        cd "$FRONTEND_DIR"
        if [ -f "./scripts/pr-automation.sh" ]; then
            ./scripts/pr-automation.sh pr "$feature_name - Frontend Implementation"
        else
            log_warning "Frontend PR自動化スクリプトが見つかりません"
        fi
        cd "$PROJECT_ROOT"
    fi
}

# メイン処理
case "${1:-help}" in
    "status"|"s")
        check_multi_repo_status
        echo ""
        check_ci_integration
        ;;
    "quality"|"q")
        run_integrated_quality_check
        ;;
    "sync")
        sync_repositories
        ;;
    "pr")
        create_integrated_pr "$2" "$3"
        ;;
    "help"|*)
        cat << EOF
🤖 マルチリポジトリ連携改善スクリプト

使用方法:
  $0 status     # マルチリポジトリ状況確認
  $0 quality    # 統合品質チェック
  $0 sync       # リポジトリ同期
  $0 pr <name>  # 統合PR作成

例:
  $0 status                           # 全体状況確認
  $0 quality                          # 品質チェック
  $0 pr "新機能実装" "機能説明"           # 統合PR作成

🎯 3層CI/CD構造との統合により効率的なマルチリポジトリ開発を支援
EOF
        ;;
esac