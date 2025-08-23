#!/bin/bash

# Git hooks setup script for ESLint pre-commit validation
# ClaudeCode ESLint規約遵守支援

set -e

# 色付きoutput用の設定
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🔧 Git Hooks セットアップ開始${NC}"
echo "=================================="

# プロジェクトルートに移動
PROJECT_ROOT="$(dirname "$0")/.."
cd "$PROJECT_ROOT" || {
    echo -e "${RED}❌ プロジェクトルートディレクトリが見つかりません${NC}"
    exit 1
}

# .gitディレクトリの存在確認
if [ ! -d ".git" ]; then
    echo -e "${RED}❌ Gitリポジトリが見つかりません${NC}"
    exit 1
fi

echo -e "${BLUE}📂 プロジェクトルート: $(pwd)${NC}"

# pre-commitフックの作成
echo -e "\n${YELLOW}Step 1: pre-commitフックを作成中...${NC}"

PRE_COMMIT_HOOK=".git/hooks/pre-commit"

cat > "$PRE_COMMIT_HOOK" << 'EOF'
#!/bin/bash

# ESLint pre-commit hook
# ClaudeCode ESLint規約遵守チェック

set -e

# 色付きoutput用の設定
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}🔍 Pre-commit ESLintチェック実行中...${NC}"

# バックエンドディレクトリに移動
cd ap-study-backend || {
    echo -e "${YELLOW}⚠️  バックエンドディレクトリが見つかりません - スキップ${NC}"
    exit 0
}

# ESLintチェック実行
echo -e "${YELLOW}ESLint規約チェック中...${NC}"
if npm run lint > /dev/null 2>&1; then
    echo -e "${GREEN}✅ ESLintチェック通過${NC}"
    exit 0
else
    echo -e "${RED}❌ ESLint規約違反が検出されました${NC}"
    echo -e "${YELLOW}詳細:${NC}"
    npm run lint
    
    echo -e "\n${YELLOW}🔧 自動修正を実行して再度コミットしてください:${NC}"
    echo -e "${BLUE}cd ap-study-backend && npm run lint -- --fix${NC}"
    echo -e "${BLUE}git add . && git commit${NC}"
    
    echo -e "\n${YELLOW}または以下のスクリプトを使用:${NC}"
    echo -e "${BLUE}./scripts/lint-check.sh${NC}"
    
    exit 1
fi
EOF

# フックに実行権限を付与
chmod +x "$PRE_COMMIT_HOOK"
echo -e "${GREEN}✅ pre-commitフック作成完了${NC}"

# commit-msgフックの作成（Conventional Commits形式チェック）
echo -e "\n${YELLOW}Step 2: commit-msgフックを作成中...${NC}"

COMMIT_MSG_HOOK=".git/hooks/commit-msg"

cat > "$COMMIT_MSG_HOOK" << 'EOF'
#!/bin/bash

# Conventional Commits format check
# CLAUDE.md規約に基づくコミットメッセージ形式チェック

set -e

# 色付きoutput用の設定
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

COMMIT_MSG_FILE="$1"
COMMIT_MSG=$(cat "$COMMIT_MSG_FILE")

echo -e "${YELLOW}📝 コミットメッセージ形式チェック中...${NC}"

# Conventional Commits形式チェック
# 形式: type(scope): description
# 例: feat(api): add user authentication
# 例: fix(auth): resolve login issue
# 例: docs(readme): update installation guide

PATTERN="^(feat|fix|docs|style|refactor|test|chore)(\(.+\))?: .{1,72}$"

if echo "$COMMIT_MSG" | head -1 | grep -qE "$PATTERN"; then
    echo -e "${GREEN}✅ コミットメッセージ形式OK${NC}"
    
    # Claude Code署名の除外チェック（CLAUDE.md規約）
    if echo "$COMMIT_MSG" | grep -q "Generated with \[Claude Code\]"; then
        echo -e "${RED}❌ Claude Code署名が含まれています（CLAUDE.md規約違反）${NC}"
        echo -e "${YELLOW}Claude Code署名を除外してください${NC}"
        exit 1
    fi
    
    if echo "$COMMIT_MSG" | grep -q "Co-Authored-By: Claude"; then
        echo -e "${RED}❌ Claude署名が含まれています（CLAUDE.md規約違反）${NC}"
        echo -e "${YELLOW}Claude署名を除外してください${NC}"
        exit 1
    fi
    
    exit 0
else
    echo -e "${RED}❌ コミットメッセージが規約に準拠していません${NC}"
    echo -e "${YELLOW}現在のメッセージ:${NC}"
    echo -e "${YELLOW}$COMMIT_MSG${NC}"
    echo ""
    echo -e "${YELLOW}正しい形式:${NC}"
    echo -e "${GREEN}type(scope): description${NC}"
    echo ""
    echo -e "${YELLOW}利用可能なtype:${NC}"
    echo -e "  • ${GREEN}feat${NC}     : 新機能追加"
    echo -e "  • ${GREEN}fix${NC}      : バグ修正"
    echo -e "  • ${GREEN}docs${NC}     : ドキュメント更新"
    echo -e "  • ${GREEN}style${NC}    : コードスタイル・フォーマット"
    echo -e "  • ${GREEN}refactor${NC} : リファクタリング"
    echo -e "  • ${GREEN}test${NC}     : テスト追加・修正"
    echo -e "  • ${GREEN}chore${NC}    : 設定・ツール・その他"
    echo ""
    echo -e "${YELLOW}例:${NC}"
    echo -e "  ${GREEN}feat(auth): add user login functionality${NC}"
    echo -e "  ${GREEN}fix(api): resolve database connection issue${NC}"
    echo -e "  ${GREEN}docs(readme): update setup instructions${NC}"
    
    exit 1
fi
EOF

# フックに実行権限を付与
chmod +x "$COMMIT_MSG_HOOK"
echo -e "${GREEN}✅ commit-msgフック作成完了${NC}"

# テストフック作成
echo -e "\n${YELLOW}Step 3: フック動作テスト...${NC}"

# pre-commitテスト
echo -e "${YELLOW}pre-commitフックテスト中...${NC}"
if "$PRE_COMMIT_HOOK" > /dev/null 2>&1; then
    echo -e "${GREEN}✅ pre-commitフック動作確認完了${NC}"
else
    echo -e "${RED}❌ pre-commitフックでエラーが発生しました${NC}"
fi

echo -e "\n${GREEN}🎉 Git Hooksセットアップ完了！${NC}"
echo "=================================="
echo -e "${BLUE}設定されたフック:${NC}"
echo -e "  • ${GREEN}pre-commit${NC}  : ESLint規約チェック"
echo -e "  • ${GREEN}commit-msg${NC}  : Conventional Commits形式チェック"
echo ""
echo -e "${YELLOW}💡 使用方法:${NC}"
echo "1. 通常通りgit commitを実行"
echo "2. ESLint違反がある場合は自動的に検出・阻止"
echo "3. 修正後に再度コミット"
echo ""
echo -e "${BLUE}便利なコマンド:${NC}"
echo -e "  ${GREEN}./scripts/lint-check.sh${NC}      : ESLint自動修正"
echo -e "  ${GREEN}git commit --no-verify${NC}       : フック無視（緊急時のみ）"
echo ""
echo -e "${GREEN}✨ ESLint規約遵守が自動化されました！${NC}"