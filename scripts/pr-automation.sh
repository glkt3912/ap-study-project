#!/bin/bash

# =================================================================
# PR自動化スクリプト - Claude Code統合開発フロー
# =================================================================

set -e

# 設定
DEFAULT_BASE_BRANCH="main"
PR_BRANCH_PREFIX="feature/"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

# カラー定義
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# ログ関数
log_info() { echo -e "${BLUE}ℹ️  $1${NC}"; }
log_success() { echo -e "${GREEN}✅ $1${NC}"; }
log_warning() { echo -e "${YELLOW}⚠️  $1${NC}"; }
log_error() { echo -e "${RED}❌ $1${NC}"; }

# ヘルプ表示
show_help() {
    cat << EOF
🤖 PR自動化スクリプト - Claude Code統合開発フロー

使用方法:
  $0 <command> [options]

コマンド:
  start <feature-name>           新機能開発開始（ブランチ作成・TDD初期化）
  commit [message]               自動コミット（Conventional Commits形式）
  review                         自己レビュー実行
  pr [--draft]                   PR作成（--draft: ドラフトPR）
  merge                          PR承認・マージ
  cleanup                        ブランチクリーンアップ
  status                         現在の開発状況確認
  flow <feature-name>            完全自動フロー（start → commit → review → pr）

オプション:
  --base <branch>                ベースブランチ指定（デフォルト: main）
  --no-tdd                       TDD初期化をスキップ
  --draft                        ドラフトPRとして作成
  --auto-merge                   自動マージ有効化
  -h, --help                     このヘルプを表示

例:
  $0 start exam-data-expansion
  $0 commit "feat: add exam data validation"
  $0 review
  $0 pr --draft
  $0 flow user-authentication
  
Claude Code統合例:
  TodoWrite: 機能要件明確化
  Bash: "./scripts/pr-automation.sh start [機能名]"
  # ... Claude Code開発作業 ...
  Bash: "./scripts/pr-automation.sh flow [機能名]"
EOF
}

# ブランチ名生成
generate_branch_name() {
    local feature_name="$1"
    local branch_type="${2:-feature}"
    
    # 特殊文字の置換・正規化
    local normalized_name=$(echo "$feature_name" | \
        tr '[:upper:]' '[:lower:]' | \
        sed 's/[^a-z0-9]/-/g' | \
        sed 's/--*/-/g' | \
        sed 's/^-\|-$//g')
    
    echo "${branch_type}/${normalized_name}"
}

# 現在のブランチ名取得
get_current_branch() {
    git rev-parse --abbrev-ref HEAD
}

# ベースブランチとの差分確認
check_changes() {
    local base_branch="${1:-$DEFAULT_BASE_BRANCH}"
    local current_branch=$(get_current_branch)
    
    if [ "$current_branch" = "$base_branch" ]; then
        log_error "ベースブランチ上で作業しています。機能ブランチを作成してください。"
        return 1
    fi
    
    local changes=$(git diff --name-only "$base_branch"..."$current_branch" | wc -l)
    log_info "変更ファイル数: $changes"
    
    if [ "$changes" -eq 0 ]; then
        log_warning "変更が検出されません。"
        return 1
    fi
    
    return 0
}

# TDD初期化
init_tdd() {
    local feature_name="$1"
    
    if [ -f "./scripts/tdd-helper.sh" ]; then
        log_info "TDD環境を初期化中..."
        ./scripts/tdd-helper.sh init "$feature_name"
        ./scripts/tdd-helper.sh generate "$feature_name"
        log_success "TDD環境初期化完了"
    else
        log_warning "TDDヘルパースクリプトが見つかりません。スキップします。"
    fi
}

# 自動コミット
auto_commit() {
    local commit_message="$1"
    local base_branch="${2:-$DEFAULT_BASE_BRANCH}"
    
    # 変更があるか確認
    if ! git diff --quiet || ! git diff --cached --quiet; then
        # ステージングエリアに追加
        git add .
        
        # コミットメッセージが指定されていない場合は自動生成
        if [ -z "$commit_message" ]; then
            log_info "コミットメッセージを自動生成中..."
            local current_branch=$(get_current_branch)
            local feature_name=$(echo "$current_branch" | sed 's/^feature\///' | sed 's/-/ /g')
            commit_message="feat: implement $feature_name functionality"
        fi
        
        # Conventional Commits形式でコミット
        git commit -m "$commit_message"
        log_success "コミット完了: $commit_message"
    else
        log_info "コミット対象の変更がありません。"
    fi
}

# 自己レビュー実行
self_review() {
    local base_branch="${1:-$DEFAULT_BASE_BRANCH}"
    local current_branch=$(get_current_branch)
    
    log_info "自己レビューを実行中..."
    
    # 変更統計
    echo -e "\n📊 変更統計:"
    git diff --stat "$base_branch"..."$current_branch"
    
    # 変更内容のサマリー  
    echo -e "\n📝 実装内容・コミット履歴:"
    git log --oneline "$base_branch"..."$current_branch"
    
    # 重要なファイルの変更チェック
    echo -e "\n🔍 変更されたファイル（重要度順）:"
    git diff --name-only "$base_branch"..."$current_branch" | while read file; do
        if [[ "$file" =~ \.(ts|tsx|js|jsx)$ ]]; then
            echo "  📁 TypeScript/JavaScript: $file"
        elif [[ "$file" =~ \.(json)$ ]]; then
            echo "  ⚙️  設定ファイル: $file"
        elif [[ "$file" =~ \.(md)$ ]]; then
            echo "  📖 ドキュメント: $file"
        elif [[ "$file" =~ \.(css|scss)$ ]]; then
            echo "  🎨 スタイル: $file"
        else
            echo "  📄 その他: $file"
        fi
    done
    
    # コード変更の詳細分析
    echo -e "\n🔍 コード変更の詳細分析:"
    local additions=$(git diff --numstat "$base_branch"..."$current_branch" | awk '{sum+=$1} END {print sum+0}')
    local deletions=$(git diff --numstat "$base_branch"..."$current_branch" | awk '{sum+=$2} END {print sum+0}')
    echo "  - 追加行数: ${additions}行"
    echo "  - 削除行数: ${deletions}行"
    echo "  - 純増加: $((additions - deletions))行"
    
    # lint・build チェック
    echo -e "\n🔧 コード品質チェック実行中..."
    
    # フロントエンド品質チェック
    if [ -d "ap-study-app" ]; then
        cd ap-study-app
        if [ -f "package.json" ]; then
            log_info "📱 フロントエンド品質チェック実行中..."
            npm run lint || log_warning "⚠️  Lint警告が検出されました"
            npm run build || log_error "❌ フロントエンドビルドエラーが発生しました"
        fi
        cd ..
    fi
    
    # バックエンド品質チェック
    if [ -d "ap-study-backend" ]; then
        cd ap-study-backend
        if [ -f "package.json" ]; then
            log_info "🔧 バックエンド品質チェック実行中..."
            npm run build || log_error "❌ バックエンドビルドエラーが発生しました"
        fi
        cd ..
    fi
    
    echo -e "\n📋 レビュー結果サマリー:"
    echo "  ✅ コード変更の統計情報を確認済み"
    echo "  ✅ 実装内容・コミット履歴を確認済み"
    echo "  ✅ 変更ファイルの分類・重要度を確認済み"
    echo "  ✅ コード品質チェック（lint・build）実行済み"
    echo ""
    echo "💡 次のステップ: PR作成（./scripts/pr-automation.sh pr）"
    
    log_success "🎉 自己レビュー完了"
}

# PR作成
create_pr() {
    local is_draft="$1"
    local base_branch="${2:-$DEFAULT_BASE_BRANCH}"
    local current_branch=$(get_current_branch)
    
    # リモートにプッシュ
    log_info "リモートにプッシュ中..."
    git push -u origin "$current_branch"
    
    # PR本文生成（日本語ベース）
    local pr_title=$(echo "$current_branch" | sed 's/^feature\///' | sed 's/-/ /g')
    local pr_body=$(cat << EOF
## 📋 概要・実装内容
$(git log --oneline "$base_branch"..."$current_branch" | sed 's/^[a-f0-9]* /- /')

## 🧪 テスト計画
- [ ] 基本機能の動作確認
- [ ] エラーハンドリングの確認
- [ ] レスポンシブデザインの確認
- [ ] アクセシビリティの確認
- [ ] 関連機能への影響確認

## 📊 変更統計
$(git diff --stat "$base_branch"..."$current_branch")

## 🔍 レビューチェックリスト
- [ ] コード品質・可読性の確認
- [ ] セキュリティ観点での確認
- [ ] パフォーマンスへの影響確認
- [ ] ドキュメント更新の確認
- [ ] テストカバレッジの確認
- [ ] 型定義・エラーハンドリングの適切性
- [ ] 既存機能への影響がないことの確認

## 💡 備考・注意事項
<!-- 特記事項があれば記載 -->

## 🚀 デプロイ前の確認事項
- [ ] データベース変更がある場合、マイグレーション手順の確認
- [ ] 環境変数の追加・変更がある場合の設定確認
- [ ] 本番環境での動作に問題がないことの確認
EOF
)

    # PR作成コマンド（日本語タイトル）
    local pr_cmd="gh pr create --title \"feat: $pr_title の実装\" --body \"$pr_body\" --base \"$base_branch\""
    
    if [ "$is_draft" = "true" ]; then
        pr_cmd="$pr_cmd --draft"
        log_info "📝 ドラフトPRを作成中..."
    else
        log_info "🚀 PRを作成中..."
    fi
    
    eval "$pr_cmd"
    
    # PR URL取得・表示
    local pr_url=$(gh pr view --json url --jq .url)
    echo -e "\n📋 PR作成結果:"
    echo "  🔗 PR URL: $pr_url"
    echo "  📝 タイトル: feat: $pr_title の実装"
    echo "  🎯 ベースブランチ: $base_branch"
    echo ""
    echo "💡 次のステップ: GitHubでPRを確認・マージ"
    
    log_success "🎉 PR作成完了"
    
    return 0
}

# PR承認・マージ
merge_pr() {
    local current_branch=$(get_current_branch)
    local base_branch="${1:-$DEFAULT_BASE_BRANCH}"
    
    log_info "🔄 PRをマージ中..."
    
    # PRのマージ
    gh pr merge --squash
    
    # ベースブランチに切り替え
    git checkout "$base_branch"
    git pull origin "$base_branch"
    
    echo -e "\n📋 マージ結果:"
    echo "  ✅ PRがスカッシュマージされました"
    echo "  🔄 $base_branch ブランチに切り替え完了"
    echo "  📥 最新の変更を取得完了"
    echo ""
    echo "💡 次のステップ: ブランチクリーンアップ（./scripts/pr-automation.sh cleanup）"
    
    log_success "🎉 PRマージ完了"
}

# ブランチクリーンアップ
cleanup_branches() {
    local base_branch="${1:-$DEFAULT_BASE_BRANCH}"
    
    log_info "ブランチをクリーンアップ中..."
    
    # ローカルブランチの削除
    git branch --merged | grep -v "$base_branch" | grep -v "$(get_current_branch)" | xargs -r git branch -d
    
    # リモート追跡ブランチの削除
    git remote prune origin
    
    log_success "ブランチクリーンアップ完了"
}

# 開発状況確認
check_status() {
    local current_branch=$(get_current_branch)
    local base_branch="${1:-$DEFAULT_BASE_BRANCH}"
    
    echo -e "\n🔄 現在の開発状況"
    echo "📍 現在のブランチ: $current_branch"
    echo "🎯 ベースブランチ: $base_branch"
    
    # 変更状況
    if check_changes "$base_branch" 2>/dev/null; then
        echo -e "\n📊 変更統計:"
        git diff --stat "$base_branch"..."$current_branch"
        
        echo -e "\n📝 実装内容・コミット履歴:"
        git log --oneline "$base_branch"..."$current_branch"
        
        echo -e "\n🔍 作業進捗:"
        local commit_count=$(git rev-list --count "$base_branch".."$current_branch")
        local file_count=$(git diff --name-only "$base_branch"..."$current_branch" | wc -l)
        echo "  - コミット数: ${commit_count}個"
        echo "  - 変更ファイル数: ${file_count}個"
    else
        echo -e "\n✅ 変更なし（クリーンな状態）"
    fi
    
    # PR状況確認
    if gh pr view &>/dev/null; then
        echo -e "\n🔍 関連するPR状況:"
        gh pr view --json title,url,state,mergeable --template "  📋 タイトル: {{.title}}
  🔗 URL: {{.url}}
  📊 状態: {{.state}}
  ✅ マージ可能: {{.mergeable}}"
    else
        echo -e "\n📝 PR未作成（PRを作成する場合: ./scripts/pr-automation.sh pr）"
    fi
}

# 完全自動フロー
full_auto_flow() {
    local feature_name="$1"
    local base_branch="${2:-$DEFAULT_BASE_BRANCH}"
    local no_tdd="$3"
    
    log_info "完全自動フロー開始: $feature_name"
    
    # 1. 機能開発開始
    start_feature "$feature_name" "$base_branch" "$no_tdd"
    
    # 2. 自動コミット
    auto_commit "feat: implement $feature_name initial version"
    
    # 3. 自己レビュー
    self_review "$base_branch"
    
    # 4. PR作成
    create_pr "false" "$base_branch"
    
    log_success "完全自動フロー完了"
}

# 機能開発開始
start_feature() {
    local feature_name="$1"
    local base_branch="${2:-$DEFAULT_BASE_BRANCH}"
    local no_tdd="$3"
    
    if [ -z "$feature_name" ]; then
        log_error "機能名を指定してください"
        show_help
        exit 1
    fi
    
    # ブランチ名生成
    local branch_name=$(generate_branch_name "$feature_name")
    
    log_info "機能開発開始: $feature_name"
    log_info "ブランチ名: $branch_name"
    
    # ベースブランチの最新取得
    git checkout "$base_branch"
    git pull origin "$base_branch"
    
    # 機能ブランチ作成・切り替え
    git checkout -b "$branch_name"
    
    # TDD初期化（オプション）
    if [ "$no_tdd" != "true" ]; then
        init_tdd "$feature_name"
    fi
    
    # 進捗管理スクリプト実行
    if [ -f "./scripts/progress-manager.sh" ]; then
        ./scripts/progress-manager.sh feature-start "$feature_name"
    fi
    
    log_success "機能開発準備完了: $branch_name"
}

# メイン処理
main() {
    # 引数チェック
    if [ $# -eq 0 ]; then
        show_help
        exit 1
    fi
    
    local command="$1"
    shift
    
    # オプション解析
    local base_branch="$DEFAULT_BASE_BRANCH"
    local no_tdd="false"
    local is_draft="false"
    local auto_merge="false"
    
    while [[ $# -gt 0 ]]; do
        case $1 in
            --base)
                base_branch="$2"
                shift 2
                ;;
            --no-tdd)
                no_tdd="true"
                shift
                ;;
            --draft)
                is_draft="true"
                shift
                ;;
            --auto-merge)
                auto_merge="true"
                shift
                ;;
            -h|--help)
                show_help
                exit 0
                ;;
            *)
                break
                ;;
        esac
    done
    
    # コマンド実行
    case $command in
        start)
            start_feature "$1" "$base_branch" "$no_tdd"
            ;;
        commit)
            auto_commit "$1" "$base_branch"
            ;;
        review)
            self_review "$base_branch"
            ;;
        pr)
            create_pr "$is_draft" "$base_branch"
            ;;
        merge)
            merge_pr "$base_branch"
            ;;
        cleanup)
            cleanup_branches "$base_branch"
            ;;
        status)
            check_status "$base_branch"
            ;;
        flow)
            full_auto_flow "$1" "$base_branch" "$no_tdd"
            ;;
        *)
            log_error "不明なコマンド: $command"
            show_help
            exit 1
            ;;
    esac
}

# スクリプト実行
main "$@"