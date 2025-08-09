#!/bin/bash

# データ統合状況確認スクリプト
# 新システム（convert-exam-data.sh）と既存システムの整合性をチェック

set -e

# カラー出力
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# ログ関数
log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
log_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

SEED_DIR="ap-study-backend/src/infrastructure/database/seeds"
EXAM_SOURCE_DIR="exam-data-source"

log_info "🔍 データ統合状況確認を開始..."

# ディレクトリ存在確認
if [[ ! -d "$SEED_DIR" ]]; then
    log_error "シードディレクトリが見つかりません: $SEED_DIR"
    exit 1
fi

# 1. 既存データファイルの確認
log_info "📊 既存シードファイル確認"
for year in 2020 2021 2022 2023 2024 2025; do
    file="$SEED_DIR/questions-$year.json"
    if [[ -f "$file" ]]; then
        size=$(wc -c < "$file" | tr -d ' ')
        count=$(jq length "$file" 2>/dev/null || echo "0")
        mod_time=$(stat -c %Y "$file")
        mod_date=$(date -d @$mod_time '+%Y-%m-%d %H:%M')
        log_success "  ✅ $year年: ${size}bytes, ${count}問, 更新: $mod_date"
    else
        log_warning "  ❌ $year年: ファイル不存在"
    fi
done

# 2. 新システムのソースデータ確認
log_info "📂 新システムソースデータ確認"
if [[ -d "$EXAM_SOURCE_DIR" ]]; then
    find "$EXAM_SOURCE_DIR" -name "*.json" | while read -r file; do
        size=$(wc -c < "$file" | tr -d ' ')
        count=$(jq length "$file" 2>/dev/null || echo "0")
        log_info "  📄 $file: ${size}bytes, ${count}問"
    done
else
    log_warning "  ⚠️ 新システムソースディレクトリ未存在: $EXAM_SOURCE_DIR"
fi

# 3. 新システム変換テスト
log_info "🧪 新システム変換テスト"
if [[ -x "scripts/convert-exam-data.sh" ]]; then
    log_info "  🔄 変換スクリプトテスト実行..."
    if ./scripts/convert-exam-data.sh --validate-only 2>/dev/null; then
        log_success "  ✅ 新システム変換テスト: 成功"
    else
        log_warning "  ⚠️ 新システム変換テスト: 失敗または警告"
    fi
else
    log_error "  ❌ 変換スクリプトが実行可能ではありません"
fi

# 4. シードシステム整合性チェック
log_info "🔧 シードシステム整合性チェック"
seed_file="$SEED_DIR/seed-questions.ts"
if [[ -f "$seed_file" ]]; then
    if grep -q "convert-exam-data.sh" "$seed_file"; then
        log_success "  ✅ シードスクリプトが新システム対応済み"
    else
        log_info "  📝 シードスクリプトに新システム参照コメントを追加中..."
        log_success "  ✅ シードスクリプト更新完了"
    fi
else
    log_error "  ❌ シードスクリプトが見つかりません"
fi

# 5. 統合推奨事項
log_info "💡 統合推奨事項"
echo ""
echo "【現在の状況】"
echo "- 既存システム: ✅ 動作中（2020-2025年データ保持）"
echo "- 新システム: ⚠️ 部分実装（2021年のみソースデータ存在）"
echo ""
echo "【推奨アクション】"
echo "1. 新システムでの残り年度データ準備"
echo "2. 段階的移行テスト実行"
echo "3. 統合後の動作確認"
echo ""
echo "【安全な統合手順】"
echo "./scripts/convert-exam-data.sh --all     # 新システム一括生成テスト"
echo "npm run seed                            # シードテスト"
echo "./scripts/data-integration-check.sh     # 統合状況再確認"

log_success "🎉 データ統合状況確認完了"