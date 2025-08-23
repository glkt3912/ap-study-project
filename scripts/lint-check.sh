#!/bin/bash

# ESLint 自動チェック・修正スクリプト
# ClaudeCode開発支援用

set -e

# 色付きoutput用の設定
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# ログ用のタイムスタンプ
timestamp() {
    date '+[%Y-%m-%d %H:%M:%S]'
}

echo -e "${BLUE}🔍 ESLint品質チェック開始 $(timestamp)${NC}"
echo "======================================"

# バックエンドディレクトリに移動
cd "$(dirname "$0")/../ap-study-backend" || {
    echo -e "${RED}❌ バックエンドディレクトリが見つかりません${NC}"
    exit 1
}

echo -e "${BLUE}📂 作業ディレクトリ: $(pwd)${NC}"

# Step 1: 初回ESLintチェック
echo -e "\n${YELLOW}Step 1: ESLintチェック実行中...${NC}"
if npm run lint > /tmp/eslint_output.txt 2>&1; then
    echo -e "${GREEN}✅ ESLint違反なし - コードは完璧です！${NC}"
    cat /tmp/eslint_output.txt
    echo -e "\n${GREEN}🎉 品質チェック完了 $(timestamp)${NC}"
    exit 0
else
    echo -e "${YELLOW}⚠️  ESLint違反が検出されました${NC}"
    echo ""
    cat /tmp/eslint_output.txt
    
    # 違反数をカウント
    ERROR_COUNT=$(grep -c "error" /tmp/eslint_output.txt || echo "0")
    WARNING_COUNT=$(grep -c "warning" /tmp/eslint_output.txt || echo "0")
    
    echo -e "\n${YELLOW}📊 検出された問題:${NC}"
    echo -e "   • エラー: ${ERROR_COUNT}件"
    echo -e "   • 警告: ${WARNING_COUNT}件"
fi

# Step 2: 自動修正実行
echo -e "\n${YELLOW}Step 2: 自動修正を実行中...${NC}"
echo "自動修正可能な問題を解決します..."

if npm run lint -- --fix > /tmp/eslint_fix_output.txt 2>&1; then
    echo -e "${GREEN}🔧 自動修正が完了しました${NC}"
else
    echo -e "${YELLOW}⚠️  自動修正中に問題が発生しました${NC}"
    cat /tmp/eslint_fix_output.txt
fi

# Step 3: 修正後の再チェック
echo -e "\n${YELLOW}Step 3: 修正結果を確認中...${NC}"
if npm run lint > /tmp/eslint_final_output.txt 2>&1; then
    echo -e "${GREEN}🎉 すべてのESLint問題が解決されました！${NC}"
    echo -e "${GREEN}✅ コード品質チェック完了 $(timestamp)${NC}"
    
    # 成功ログ
    echo -e "\n${GREEN}📈 修正結果サマリー:${NC}"
    echo "   • 自動修正により全ての問題が解決"
    echo "   • ESLint規約完全準拠"
    echo "   • コード品質: 優秀"
    
    exit 0
else
    echo -e "${YELLOW}⚠️  まだ手動修正が必要な問題があります${NC}"
    echo ""
    cat /tmp/eslint_final_output.txt
    
    # 残存問題の分析
    REMAINING_ERRORS=$(grep -c "error" /tmp/eslint_final_output.txt || echo "0")
    REMAINING_WARNINGS=$(grep -c "warning" /tmp/eslint_final_output.txt || echo "0")
    
    echo -e "\n${YELLOW}📋 残存する問題:${NC}"
    echo -e "   • エラー: ${REMAINING_ERRORS}件"
    echo -e "   • 警告: ${REMAINING_WARNINGS}件"
    
    # 修正のヒント
    echo -e "\n${BLUE}💡 手動修正が必要な主な問題:${NC}"
    
    # any型の問題をチェック
    if grep -q "@typescript-eslint/no-explicit-any" /tmp/eslint_final_output.txt; then
        echo -e "   • ${YELLOW}TypeScript 'any'型違反${NC}"
        echo -e "     → 適切な型定義またはunknown型を使用してください"
        echo -e "     → 参考: docs/development/type-templates.md"
    fi
    
    # 複雑度の問題をチェック
    if grep -q "complexity" /tmp/eslint_final_output.txt; then
        echo -e "   • ${YELLOW}関数複雑度違反${NC}"
        echo -e "     → ヘルパー関数に分割してください（最大複雑度: 8）"
        echo -e "     → 参考: docs/development/eslint-guide.md"
    fi
    
    # 未使用変数の問題をチェック
    if grep -q "no-unused-vars" /tmp/eslint_final_output.txt; then
        echo -e "   • ${YELLOW}未使用変数${NC}"
        echo -e "     → 使用されていない変数・インポートを削除してください"
    fi
    
    # console使用の問題をチェック
    if grep -q "no-console" /tmp/eslint_final_output.txt; then
        echo -e "   • ${YELLOW}console文使用違反${NC}"
        echo -e "     → 適切なロガーまたはconsole文を削除してください"
    fi
    
    echo -e "\n${BLUE}🔧 推奨される次のステップ:${NC}"
    echo "1. Edit: 検出された問題を手動で修正"
    echo "2. Bash: 'npm run lint' で再確認"
    echo "3. Bash: 'npm run build' でTypeScriptチェック"
    
    exit 1
fi

# Step 4: TypeScriptビルドチェック（オプション）
if [ "$1" = "--with-build" ]; then
    echo -e "\n${YELLOW}Step 4: TypeScriptビルドチェック...${NC}"
    if npm run build > /tmp/build_output.txt 2>&1; then
        echo -e "${GREEN}✅ TypeScriptビルド成功${NC}"
    else
        echo -e "${RED}❌ TypeScriptビルドエラー${NC}"
        cat /tmp/build_output.txt
        exit 1
    fi
fi

# クリーンアップ
rm -f /tmp/eslint_output.txt /tmp/eslint_fix_output.txt /tmp/eslint_final_output.txt /tmp/build_output.txt

echo -e "\n${GREEN}🏁 ESLint品質チェック完了 $(timestamp)${NC}"
echo "======================================"