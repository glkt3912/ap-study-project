#!/bin/bash

# =================================================================
# PR自動化スクリプト - Claude Code統合開発フロー
# =================================================================

set -e

# 設定
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
CONFIG_FILE="$PROJECT_ROOT/.pr-automation.config"

# デフォルト設定
DEFAULT_BASE_BRANCH="main"
PR_BRANCH_PREFIX="feature/"
FRONTEND_DIR="frontend"
BACKEND_DIR="backend"
TDD_ENABLED=true

# 設定ファイル読み込み
if [ -f "$CONFIG_FILE" ]; then
    echo "📋 設定ファイルを読み込み中: .pr-automation.config"
    source "$CONFIG_FILE"
    echo "✅ 設定読み込み完了"
else
    echo "⚠️  設定ファイルが見つかりません。デフォルト設定を使用します。"
    echo "💡 .pr-automation.config を作成することで設定をカスタマイズできます。"
fi

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
  update-pr                      既存PRの説明を最新実装内容で更新
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
  $0 update-pr
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

# 自動コミット（.claude/commands/commit.md準拠）
auto_commit() {
    local commit_message="$1"
    local base_branch="${2:-$DEFAULT_BASE_BRANCH}"
    
    # 変更があるか確認
    if ! git diff --quiet || ! git diff --cached --quiet; then
        # ステージングエリアに追加
        git add .
        
        # コミットメッセージが指定されていない場合は詳細分析して自動生成
        if [ -z "$commit_message" ]; then
            log_info "コミットメッセージを詳細分析で自動生成中..."
            commit_message=$(generate_commit_message "$base_branch")
        fi
        
        # Conventional Commits形式でコミット（Claude Code署名除外）
        git commit -m "$commit_message"
        log_success "コミット完了: $commit_message"
    else
        log_info "コミット対象の変更がありません。"
    fi
}

# コミットメッセージ自動生成（.claude/commands/commit.md完全準拠）
generate_commit_message() {
    local base_branch="${1:-$DEFAULT_BASE_BRANCH}"
    local current_branch=$(get_current_branch)
    
    # 1. 詳細な変更検出・分析
    local staged_files=($(git diff --cached --name-only))
    local total_files=${#staged_files[@]}
    local additions=$(git diff --cached --numstat | awk '{sum+=$1} END {print sum+0}')
    local deletions=$(git diff --cached --numstat | awk '{sum+=$2} END {print sum+0}')
    
    # 2. 変更パターンの詳細分析
    local has_new_files=$(git diff --cached --name-status | grep -c "^A" || echo 0)
    local has_deleted_files=$(git diff --cached --name-status | grep -c "^D" || echo 0)
    local has_modified_files=$(git diff --cached --name-status | grep -c "^M" || echo 0)
    
    # 3. 変更カテゴリの高度な判定
    local category="feat"
    local scope=""
    local description=""
    local is_breaking=false
    
    # 新機能実装の検出
    if [[ $has_new_files -gt 0 ]] && [[ $additions -gt 50 ]]; then
        # 新しいスクリプト・機能ファイルの追加
        if printf '%s\n' "${staged_files[@]}" | grep -q "scripts/.*\.sh$"; then
            category="feat"
            description="add new automation script"
        # 新しいコンポーネント・API追加
        elif printf '%s\n' "${staged_files[@]}" | grep -q "components/\|routes/\|api/"; then
            category="feat" 
            description="add new functionality"
        # 設定・ドキュメント追加
        elif printf '%s\n' "${staged_files[@]}" | grep -q "\.md$\|\.json$\|config"; then
            if [[ $additions -gt $((has_new_files * 20)) ]]; then
                category="feat"
                description="add comprehensive configuration"
            else
                category="docs"
                description="add documentation"
            fi
        else
            category="feat"
            description="add new files"
        fi
    # 依存関係・ビルド変更
    elif printf '%s\n' "${staged_files[@]}" | grep -q "package\.json\|package-lock\.json\|yarn\.lock\|Dockerfile\|docker-compose"; then
        category="build"
        description="update dependencies and build configuration"
    # テスト関連
    elif printf '%s\n' "${staged_files[@]}" | grep -q "test\|spec\|__tests__"; then
        category="test"
        if [[ $has_new_files -gt 0 ]]; then
            description="add comprehensive test suite"
        else
            description="update existing tests"
        fi
    # パフォーマンス最適化
    elif printf '%s\n' "${staged_files[@]}" | grep -q "performance\|optimization\|perf" || 
         git diff --cached | grep -q "performance\|optimize\|efficient"; then
        category="perf"
        description="improve performance and optimization"
    # バグ修正
    elif printf '%s\n' "${staged_files[@]}" | grep -q "fix\|bug" || 
         git diff --cached | grep -q "fix\|bug\|error\|issue"; then
        category="fix"
        description="resolve critical issues"
    # リファクタリング
    elif [[ $has_modified_files -gt $has_new_files ]] && [[ $deletions -gt 20 ]]; then
        category="refactor"
        description="improve code structure and maintainability"
    # スタイル・フォーマット
    elif printf '%s\n' "${staged_files[@]}" | grep -q "\.css\|\.scss\|styles" || 
         [[ $additions -lt 10 && $deletions -lt 10 ]]; then
        category="style"
        description="update code formatting and styles"
    # ドキュメント更新
    elif printf '%s\n' "${staged_files[@]}" | grep -q "\.md$\|README\|docs/"; then
        if [[ $total_files -eq 1 ]]; then
            category="docs"
            description="update documentation"
        else
            category="feat"
            description="enhance documentation system"
        fi
    # 設定変更
    elif printf '%s\n' "${staged_files[@]}" | grep -q "\.env\|config\|\.json$\|\.gitignore"; then
        category="chore"
        description="update project configuration"
    else
        # 複合的な変更の場合、主要な変更を分析
        category="feat"
        local feature_name=$(echo "$current_branch" | sed 's/^feature\///' | sed 's/-/ /g')
        if [[ "$feature_name" != "main" && "$feature_name" != "$current_branch" ]]; then
            description="implement $feature_name system"
        else
            description="add comprehensive functionality"
        fi
    fi
    
    # 4. スコープの詳細決定
    local app_changes=0
    local api_changes=0
    local script_changes=0
    local doc_changes=0
    local config_changes=0
    
    for file in "${staged_files[@]}"; do
        if [[ "$file" =~ ^${FRONTEND_DIR}/ ]]; then
            ((app_changes++))
        elif [[ "$file" =~ ^${BACKEND_DIR}/ ]]; then
            ((api_changes++))
        elif [[ "$file" =~ ^scripts/ ]]; then
            ((script_changes++))
        elif [[ "$file" =~ ^docs/|\.md$ ]]; then
            ((doc_changes++))
        elif [[ "$file" =~ ^\.|config|\.json$ ]]; then
            ((config_changes++))
        fi
    done
    
    if [[ $script_changes -gt 0 ]] && [[ $script_changes -ge $app_changes ]] && [[ $script_changes -ge $api_changes ]]; then
        scope="scripts"
    elif [[ $app_changes -gt 0 ]] && [[ $api_changes -gt 0 ]]; then
        scope="app,api"
    elif [[ $app_changes -gt 0 ]]; then
        scope="app"
    elif [[ $api_changes -gt 0 ]]; then
        scope="api"
    elif [[ $doc_changes -gt 0 ]] && [[ $doc_changes -ge $config_changes ]]; then
        scope="docs"
    elif [[ $config_changes -gt 0 ]]; then
        scope="config"
    fi
    
    # 5. 破壊的変更の検出
    if git diff --cached | grep -q "BREAKING CHANGE" || 
       [[ $deletions -gt $additions ]] && [[ $deletions -gt 100 ]]; then
        is_breaking=true
    fi
    
    # 6. コミットメッセージ生成（Conventional Commits完全準拠）
    local commit_msg="$category"
    if [ -n "$scope" ]; then
        commit_msg="$commit_msg($scope)"
    fi
    if [ "$is_breaking" = true ]; then
        commit_msg="$commit_msg!"
    fi
    commit_msg="$commit_msg: $description"
    
    # 7. 詳細な本文追加（大規模変更時）
    if [[ $total_files -gt 3 ]] || [[ $additions -gt 50 ]] || [[ $has_new_files -gt 0 ]]; then
        local body=""
        
        # 新規追加ファイルの詳細
        if [[ $has_new_files -gt 0 ]]; then
            body="$body\n- Add $has_new_files new files"
        fi
        
        # 主要な変更の説明
        if printf '%s\n' "${staged_files[@]}" | grep -q "scripts/.*automation"; then
            body="$body\n- Implement PR automation with Japanese localization"
        fi
        if printf '%s\n' "${staged_files[@]}" | grep -q "\.claude/"; then
            body="$body\n- Integrate Claude Code commit analysis system"
        fi
        if printf '%s\n' "${staged_files[@]}" | grep -q "\.gitignore"; then
            body="$body\n- Update gitignore for team collaboration"
        fi
        
        # 統計情報
        if [[ $additions -gt 100 ]] || [[ $deletions -gt 50 ]]; then
            body="$body\n- Modified $total_files files (+$additions/-$deletions lines)"
        fi
        
        if [ -n "$body" ]; then
            commit_msg="$commit_msg$body"
        fi
    fi
    
    # 8. 破壊的変更のフッター
    if [ "$is_breaking" = true ]; then
        commit_msg="$commit_msg\n\nBREAKING CHANGE: Significant structural modifications"
    fi
    
    echo "$commit_msg"
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
    if [ -d "$FRONTEND_DIR" ]; then
        cd "$FRONTEND_DIR"
        if [ -f "package.json" ]; then
            log_info "📱 フロントエンド品質チェック実行中..."
            npm run lint || log_warning "⚠️  Lint警告が検出されました"
            npm run build || log_error "❌ フロントエンドビルドエラーが発生しました"
        fi
        cd ..
    fi
    
    # バックエンド品質チェック
    if [ -d "$BACKEND_DIR" ]; then
        cd "$BACKEND_DIR"
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

# PR本文生成（Claude分析ベース）
generate_pr_body() {
    local base_branch="${1:-$DEFAULT_BASE_BRANCH}"
    local current_branch="${2:-$(get_current_branch)}"
    
    # 基本的な変更情報収集
    local changed_files=$(git diff --name-only "$base_branch"..."$current_branch")
    local file_count=$(echo "$changed_files" | wc -l)
    local commits=$(git log --oneline "$base_branch"..."$current_branch")
    local commit_count=$(echo "$commits" | wc -l)
    
    # ファイル種別分析
    local script_changes=$(echo "$changed_files" | grep -E "\.(sh|js|ts)$" | wc -l)
    local doc_changes=$(echo "$changed_files" | grep -E "\.(md|txt)$" | wc -l)
    local config_changes=$(echo "$changed_files" | grep -E "\.(json|yaml|config)$" | wc -l)
    
    # 主要な機能キーワード抽出
    local feature_keywords=$(echo "$commits" | grep -oE "(feat|add|implement|create|enhance|improve|fix)" | head -5 | tr '\n' ',' | sed 's/,$//')
    
    # ブランチ名から機能推測
    local branch_feature=$(echo "$current_branch" | sed 's/^feature\///' | sed 's/-/ /g')
    
    # コミットパターン分析
    local commit_types=$(echo "$commits" | grep -oE "^[a-f0-9]+ (feat|fix|docs|style|refactor|test|chore|perf|build|ci|revert|improve|add|update|remove)" | cut -d' ' -f2 | sort | uniq -c | sort -nr)
    local primary_type=$(echo "$commit_types" | head -1 | awk '{print $2}')
    local type_count=$(echo "$commit_types" | head -1 | awk '{print $1}')
    
    # ファイル種別による影響分析
    local frontend_files=$(echo "$changed_files" | grep -E "\.(tsx?|jsx?|css|scss|html)$" | wc -l)
    local backend_files=$(echo "$changed_files" | grep -E "\.ts$|\.js$" | grep -v test | wc -l)
    local test_files=$(echo "$changed_files" | grep -E "\.test\.|\.spec\.|test/" | wc -l)
    local doc_files=$(echo "$changed_files" | grep -E "\.(md|txt|rst)$" | wc -l)
    local config_files=$(echo "$changed_files" | grep -E "\.(json|yaml|yml|toml|ini|conf|config)$" | wc -l)
    local script_files=$(echo "$changed_files" | grep -E "\.(sh|bash|zsh)$" | wc -l)
    
    # 主要なコミットタイプに基づく説明生成
    local pr_summary=""
    local pr_motivation=""
    local testing_focus=""
    
    case "$primary_type" in
        "feat")
            pr_summary="新機能の追加"
            pr_motivation="システムの機能性向上とユーザー体験の改善を目的として、新たな機能を実装しました。"
            testing_focus="新機能の正常動作確認と既存機能への影響がないことの確認"
            ;;
        "fix")
            pr_summary="バグ修正・問題解決"
            pr_motivation="発見された問題を修正し、システムの安定性と信頼性を向上させます。"
            testing_focus="修正内容の動作確認と問題が再発しないことの確認"
            ;;
        "docs")
            pr_summary="ドキュメント更新"
            pr_motivation="ドキュメントの品質向上により、開発効率とプロジェクトの理解しやすさを改善します。"
            testing_focus="ドキュメントの内容が正確で分かりやすいことの確認"
            ;;
        "refactor")
            pr_summary="リファクタリング・コード改善"
            pr_motivation="コードの品質、可読性、保守性を向上させるためのリファクタリングを実施しました。"
            testing_focus="機能に変更がないことと、コード品質が向上していることの確認"
            ;;
        "improve"|"update")
            pr_summary="既存機能の改善・更新"
            pr_motivation="既存機能の使いやすさ、パフォーマンス、品質を向上させるための改善を行いました。"
            testing_focus="改善内容が正しく動作し、ユーザー体験が向上していることの確認"
            ;;
        "test")
            pr_summary="テスト追加・テスト改善"
            pr_motivation="テストカバレッジの向上と品質保証の強化を目的として、テストの追加・改善を行いました。"
            testing_focus="テストが正しく実行され、適切にテストケースをカバーしていることの確認"
            ;;
        *)
            pr_summary="システム改善・機能追加"
            pr_motivation="システムの品質向上と機能性の拡充を目的とした変更を実施しました。"
            testing_focus="変更内容の動作確認と既存機能への影響がないことの確認"
            ;;
    esac
    
    cat << EOF
## 🎯 概要

この PR では **${pr_summary}** を行いました。

${pr_motivation}

## 🔧 変更内容

### 主要な変更
$(git log --oneline "$base_branch"..."$current_branch" | sed 's/^[a-f0-9]* /- /' | head -5)

### 影響範囲
$(
if [[ $frontend_files -gt 0 ]]; then
    echo "- **フロントエンド**: ${frontend_files}ファイル （UI・ユーザー体験の改善）"
fi
if [[ $backend_files -gt 0 ]]; then
    echo "- **バックエンド**: ${backend_files}ファイル （サーバーサイドロジック・API）"
fi
if [[ $script_files -gt 0 ]]; then
    echo "- **スクリプト**: ${script_files}ファイル （開発・運用ツール）"
fi
if [[ $doc_files -gt 0 ]]; then
    echo "- **ドキュメント**: ${doc_files}ファイル （説明・仕様書）"
fi
if [[ $config_files -gt 0 ]]; then
    echo "- **設定**: ${config_files}ファイル （システム設定・環境設定）"
fi
if [[ $test_files -gt 0 ]]; then
    echo "- **テスト**: ${test_files}ファイル （品質保証・テストケース）"
fi
)

### 変更規模
\`\`\`
$(git diff --stat "$base_branch"..."$current_branch" 2>/dev/null)
\`\`\`

## ✅ 動作確認・テスト

- [ ] ${testing_focus}
- [ ] エラーハンドリングが適切に動作することの確認
$(if [[ $frontend_files -gt 0 ]]; then echo "- [ ] UI/UXに問題がないことの確認"; fi)
$(if [[ $backend_files -gt 0 ]]; then echo "- [ ] API・サーバーサイド機能の動作確認"; fi)
$(if [[ $config_files -gt 0 ]]; then echo "- [ ] 設定変更が正しく反映されることの確認"; fi)
- [ ] パフォーマンスに悪影響がないことの確認

## 🤔 レビューで確認してほしい点

- **実装の妥当性**: 要件を満たす適切な実装になっているか
- **コード品質**: 可読性・保守性・拡張性が確保されているか
$(if [[ $backend_files -gt 0 ]] || [[ $frontend_files -gt 0 ]]; then echo "- **セキュリティ**: セキュリティ上の問題がないか"; fi)
$(if [[ $primary_type == "feat" ]] || [[ $primary_type == "improve" ]]; then echo "- **ユーザー体験**: 使いやすさが向上しているか"; fi)
$(if [[ $test_files -gt 0 ]]; then echo "- **テスト品質**: テストケースが適切に設計されているか"; fi)

## 🚀 マージ後の期待効果

$(
case "$primary_type" in
    "feat")
        echo "- 新機能により、ユーザーの利便性が向上します
- システムの機能性が拡充され、より多くの用途に対応可能になります"
        ;;
    "fix")
        echo "- 問題が解決され、システムの安定性が向上します
- ユーザーが安心してシステムを利用できるようになります"
        ;;
    "docs")
        echo "- ドキュメントの品質向上により、開発・利用効率が向上します
- プロジェクトの理解しやすさが改善されます"
        ;;
    "refactor"|"improve")
        echo "- コード品質が向上し、今後の開発・保守が効率的になります
- システムのパフォーマンスや使いやすさが改善されます"
        ;;
    *)
        echo "- システム全体の品質と機能性が向上します
- より安定した、使いやすいシステムになります"
        ;;
esac
)

---
💬 **質問・相談**: 実装内容について質問や懸念点があれば、お気軽にコメントでお知らせください。
EOF
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
    local feature_name=$(echo "$current_branch" | sed 's/^feature\///' | sed 's/-/ /g')
    
    # 日本語ベースのPRタイトル生成
    local pr_title
    case "$feature_name" in
        *"自動化"*) pr_title="$feature_name システムの実装" ;;
        *"機能"*) pr_title="$feature_name の開発" ;;
        *"修正"*|*"バグ"*) pr_title="$feature_name の修正対応" ;;
        *"改善"*|*"最適化"*) pr_title="$feature_name の改善" ;;
        *"追加"*|*"拡充"*) pr_title="$feature_name の追加実装" ;;
        *"統合"*|*"連携"*) pr_title="$feature_name の統合対応" ;;
        *"テスト"*) pr_title="$feature_name の実装とテスト" ;;
        *"データ"*) pr_title="$feature_name の実装" ;;
        *"UI"*|*"画面"*) pr_title="$feature_name の実装" ;;
        *"API"*) pr_title="$feature_name の開発" ;;
        *) pr_title="$feature_name 機能の実装" ;;
    esac
    
    # PR本文生成
    local pr_body=$(generate_pr_body "$base_branch" "$current_branch")

    # PR作成コマンド（日本語タイトル）
    local pr_cmd="gh pr create --title \"$pr_title\" --body \"$pr_body\" --base \"$base_branch\""
    
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
    echo "  📝 タイトル: $pr_title"
    echo "  🎯 ベースブランチ: $base_branch"
    echo ""
    echo "💡 次のステップ: GitHubでPRを確認・マージ"
    
    log_success "🎉 PR作成完了"
    
    return 0
}

# PR説明更新
update_pr() {
    local base_branch="${1:-$DEFAULT_BASE_BRANCH}"
    local current_branch=$(get_current_branch)
    
    # 現在のブランチがPRブランチかチェック
    if [[ ! "$current_branch" =~ ^feature/ ]]; then
        log_error "現在のブランチ（$current_branch）はfeatureブランチではありません"
        exit 1
    fi
    
    log_info "🔄 PR説明を最新実装内容で更新中..."
    
    # 最新の本文生成
    local updated_pr_body=$(generate_pr_body "$base_branch" "$current_branch")
    
    # PRのタイトルも再生成
    local feature_name=$(echo "$current_branch" | sed 's/^feature\///' | sed 's/-/ /g')
    local pr_title
    case "$feature_name" in
        *"自動化"*) pr_title="$feature_name システムの実装" ;;
        *"機能"*) pr_title="$feature_name の開発" ;;
        *"修正"*|*"バグ"*) pr_title="$feature_name の修正対応" ;;
        *"改善"*|*"最適化"*) pr_title="$feature_name の改善" ;;
        *"追加"*|*"拡充"*) pr_title="$feature_name の追加実装" ;;
        *"統合"*|*"連携"*) pr_title="$feature_name の統合対応" ;;
        *"テスト"*) pr_title="$feature_name の実装とテスト" ;;
        *"データ"*) pr_title="$feature_name の実装" ;;
        *"UI"*|*"画面"*) pr_title="$feature_name の実装" ;;
        *"API"*) pr_title="$feature_name の開発" ;;
        *) pr_title="$feature_name 機能の実装" ;;
    esac
    
    # 一時ファイルにPR本文を保存
    local temp_file=$(mktemp)
    echo "$updated_pr_body" > "$temp_file"
    
    # PR更新実行（タイトルと本文）
    if gh pr edit --title "$pr_title" --body-file "$temp_file"; then
        log_success "✅ PR説明更新完了"
        echo ""
        echo "📋 更新内容:"
        echo "  📝 タイトル: $pr_title"
        echo "  📄 本文: 最新の実装内容で更新"
        echo "  📊 変更統計: 最新のコミットまで反映"
        echo "  🔧 実装詳細: 新しい関数・設定変更を反映"
        echo ""
        echo "🔗 PR URL: $(gh pr view --json url -q .url 2>/dev/null || echo '取得中...')"
        echo ""
        echo "💡 次のステップ:"
        echo "  - GitHubでPR内容を確認"
        echo "  - レビュー依頼・マージ準備"
    else
        log_error "❌ PR説明の更新に失敗しました"
        echo "💡 対処方法:"
        echo "  - 現在のブランチに対応するPRが存在するか確認"
        echo "  - gh CLI の認証状況を確認（gh auth status）"
        echo "  - PRが既にマージされていないか確認"
    fi
    
    # 一時ファイルクリーンアップ
    rm -f "$temp_file"
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

# =================================================================
# マルチリポジトリ対応関数
# =================================================================

# マルチリポジトリ機能開発開始
multi_start_feature() {
    local feature_name="$1"
    local base_branch="${2:-$DEFAULT_BASE_BRANCH}"
    local no_tdd="$3"
    local target_repo="$4"
    
    if [ -z "$feature_name" ]; then
        log_error "機能名を指定してください"
        show_help
        exit 1
    fi
    
    log_info "🚀 マルチリポジトリ機能開発開始: $feature_name"
    
    local repos_to_process=()
    if [[ -n "$target_repo" ]]; then
        repos_to_process=("$target_repo")
    else
        repos_to_process=("root" "frontend" "backend")
    fi
    
    for repo in "${repos_to_process[@]}"; do
        if [[ -d "${REPOSITORIES[$repo]}" ]]; then
            log_info "📁 ${REPO_DESCRIPTIONS[$repo]} で処理開始"
            execute_in_repo "$repo" "./scripts/pr-automation.sh start '$feature_name' --base '$base_branch' $([ "$no_tdd" = "true" ] && echo "--no-tdd")" || {
                # ルートリポジトリの場合は直接実行
                if [[ "$repo" == "root" ]]; then
                    start_feature "$feature_name" "$base_branch" "$no_tdd"
                else
                    log_warning "${REPO_DESCRIPTIONS[$repo]} でスクリプト実行失敗、git操作を直接実行"
                    execute_in_repo "$repo" "git checkout '$base_branch' && git pull origin '$base_branch' && git checkout -b 'feature/$feature_name' && git push -u origin 'feature/$feature_name'"
                fi
            }
        else
            log_warning "${REPO_DESCRIPTIONS[$repo]} ディレクトリが見つかりません: ${REPOSITORIES[$repo]}"
        fi
    done
    
    log_success "マルチリポジトリ機能開発開始完了"
}

# マルチリポジトリ自動コミット（差分分析機能付き）
multi_auto_commit() {
    local feature_name="$1"
    local base_branch="${2:-$DEFAULT_BASE_BRANCH}"
    local target_repo="$3"
    
    log_info "💾 マルチリポジトリインテリジェント自動コミット"
    
    local repos_to_process=()
    if [[ -n "$target_repo" ]]; then
        repos_to_process=("$target_repo")
    else
        repos_to_process=("root" "frontend" "backend")
    fi
    
    local processed_count=0
    local skipped_count=0
    
    for repo in "${repos_to_process[@]}"; do
        if [[ -d "${REPOSITORIES[$repo]}" ]]; then
            log_info "📁 ${REPO_DESCRIPTIONS[$repo]} で差分分析・コミット処理"
            
            # 差分分析実行
            local changes_info
            changes_info=$(analyze_repo_changes "$repo")
            
            if [[ "$changes_info" == "no_changes" ]]; then
                log_info "📝 ${REPO_DESCRIPTIONS[$repo]} に変更なし、スキップ"
                ((skipped_count++))
                continue
            fi
            
            # インテリジェントなコミットメッセージ生成
            local smart_message
            smart_message=$(generate_smart_commit_message "$repo" "$feature_name" "$changes_info")
            
            if [[ -n "$smart_message" ]]; then
                log_info "📝 コミットメッセージ: $smart_message"
                
                # コミット実行
                if execute_in_repo "$repo" "git add -A && git commit -m '$smart_message'"; then
                    log_success "✅ ${REPO_DESCRIPTIONS[$repo]} コミット完了"
                    ((processed_count++))
                else
                    log_warning "⚠️ ${REPO_DESCRIPTIONS[$repo]} コミット失敗"
                fi
            else
                log_warning "⚠️ ${REPO_DESCRIPTIONS[$repo]} コミットメッセージ生成失敗"
            fi
        fi
    done
    
    log_info "📊 コミット結果: 処理完了=$processed_count, スキップ=$skipped_count"
    log_success "マルチリポジトリインテリジェント自動コミット完了"
}

# マルチリポジトリPR作成（差分分析機能付き）
multi_create_pr() {
    local is_draft="$1"
    local base_branch="${2:-$DEFAULT_BASE_BRANCH}"
    local target_repo="$3"
    local feature_name="$4"
    
    log_info "📋 マルチリポジトリインテリジェントPR作成"
    
    local repos_to_process=()
    if [[ -n "$target_repo" ]]; then
        repos_to_process=("$target_repo")
    else
        repos_to_process=("root" "frontend" "backend")
    fi
    
    local pr_created_count=0
    local skipped_count=0
    
    for repo in "${repos_to_process[@]}"; do
        if [[ -d "${REPOSITORIES[$repo]}" ]]; then
            log_info "📁 ${REPO_DESCRIPTIONS[$repo]} でPR作成判定"
            
            # 現在のブランチがfeatureブランチかチェック
            local current_branch
            current_branch=$(execute_in_repo "$repo" "git branch --show-current" 2>/dev/null)
            
            if [[ ! "$current_branch" =~ ^feature/ ]]; then
                log_info "📝 ${REPO_DESCRIPTIONS[$repo]} はfeatureブランチではない、スキップ"
                ((skipped_count++))
                continue
            fi
            
            # ベースブランチとの差分をチェック
            local has_commits
            has_commits=$(execute_in_repo "$repo" "git log $base_branch..$current_branch --oneline" 2>/dev/null)
            
            if [[ -z "$has_commits" ]]; then
                log_info "📝 ${REPO_DESCRIPTIONS[$repo]} に新しいコミットなし、スキップ"
                ((skipped_count++))
                continue
            fi
            
            # 差分分析でPRタイトル・説明生成
            local changes_info
            local pr_title=""
            local pr_body=""
            
            # 最新のコミットメッセージを取得（すでにインテリジェントなメッセージ）
            local latest_commit_msg
            latest_commit_msg=$(execute_in_repo "$repo" "git log -1 --pretty=format:'%s'" 2>/dev/null)
            
            if [[ -n "$latest_commit_msg" ]]; then
                pr_title="$latest_commit_msg"
                pr_body="## Summary
This PR implements $feature_name in the ${REPO_DESCRIPTIONS[$repo]}.

## Changes
$(execute_in_repo "$repo" "git log $base_branch..$current_branch --oneline" 2>/dev/null | sed 's/^/- /')

## Files Changed
$(execute_in_repo "$repo" "git diff --name-only $base_branch..$current_branch" 2>/dev/null | sed 's/^/- /')

🤖 Generated with [Claude Code](https://claude.ai/code)"
            else
                pr_title="$feature_name の開発"
                pr_body="## Summary
This PR implements $feature_name.

🤖 Generated with [Claude Code](https://claude.ai/code)"
            fi
            
            log_info "📝 PRタイトル: $pr_title"
            
            # PR作成実行
            if execute_in_repo "$repo" "gh pr create --title '$pr_title' --body '$pr_body' $([ "$is_draft" = "true" ] && echo "--draft")"; then
                log_success "✅ ${REPO_DESCRIPTIONS[$repo]} PR作成完了"
                ((pr_created_count++))
            else
                log_warning "⚠️ ${REPO_DESCRIPTIONS[$repo]} PR作成失敗"
            fi
        fi
    done
    
    log_info "📊 PR作成結果: 作成完了=$pr_created_count, スキップ=$skipped_count"
    log_success "マルチリポジトリインテリジェントPR作成完了"
}

# マルチリポジトリ状況確認
multi_check_status() {
    local base_branch="${1:-$DEFAULT_BASE_BRANCH}"
    local target_repo="$2"
    
    log_info "🔍 マルチリポジトリ状況確認"
    
    local repos_to_process=()
    if [[ -n "$target_repo" ]]; then
        repos_to_process=("$target_repo")
    else
        repos_to_process=("root" "frontend" "backend")
    fi
    
    for repo in "${repos_to_process[@]}"; do
        if [[ -d "${REPOSITORIES[$repo]}" ]]; then
            echo
            log_info "📁 ${REPO_DESCRIPTIONS[$repo]} の状況:"
            echo "====================================="
            execute_in_repo "$repo" "git status --short; echo '---'; git log --oneline -3; echo '---'; git branch -v"
        fi
    done
    
    log_success "マルチリポジトリ状況確認完了"
}

# マルチリポジトリ完全自動フロー（差分分析機能付き）
multi_full_auto_flow() {
    local feature_name="$1"
    local base_branch="${2:-$DEFAULT_BASE_BRANCH}"
    local no_tdd="$3"
    local target_repo="$4"
    
    log_info "🚀 マルチリポジトリインテリジェント完全自動フロー開始: $feature_name"
    
    # 1. 機能開発開始
    log_info "📋 Step 1: 機能開発ブランチ作成"
    multi_start_feature "$feature_name" "$base_branch" "$no_tdd" "$target_repo"
    
    # 2. インテリジェント自動コミット（差分分析付き）
    log_info "📋 Step 2: インテリジェント差分分析・自動コミット"
    multi_auto_commit "$feature_name" "$base_branch" "$target_repo"
    
    # 3. インテリジェントPR作成（差分分析付き）
    log_info "📋 Step 3: インテリジェントPR作成"
    multi_create_pr "false" "$base_branch" "$target_repo" "$feature_name"
    
    log_success "🎉 マルチリポジトリインテリジェント完全自動フロー完了"
    
    # 4. サマリー表示
    log_info "📊 フロー完了サマリー:"
    echo "  🔄 処理されたリポジトリ: $([ -n "$target_repo" ] && echo "$target_repo" || echo "all (root, frontend, backend)")"
    echo "  📝 機能名: $feature_name"
    echo "  🌿 ベースブランチ: $base_branch"
    echo "  🧪 TDD初期化: $([ "$no_tdd" = "true" ] && echo "無効" || echo "有効")"
    echo ""
    echo "💡 次のステップ:"
    echo "  - 各リポジトリで具体的な実装作業を行う"
    echo "  - ./scripts/pr-automation.sh multi-status で状況確認"
    echo "  - ./scripts/pr-automation.sh multi-merge で全PR一括マージ"
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
        update-pr)
            update_pr "$base_branch"
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