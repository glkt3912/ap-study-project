#!/bin/bash

# 過去問データ変換スクリプト
# Usage: ./scripts/convert-exam-data.sh [year] [season] [section]
# Example: ./scripts/convert-exam-data.sh 2024 spring morning

set -e  # エラー時に終了

# 設定
EXAM_DATA_SOURCE_DIR="exam-data-source"
SEED_DATA_DIR="ap-study-backend/src/infrastructure/database/seeds"
TEMP_DIR="temp-exam-processing"

# カラー出力
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# ログ関数
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# 使用法表示
show_usage() {
    echo "使用法: $0 [year] [season] [section] [options]"
    echo ""
    echo "引数:"
    echo "  year     : 年度 (2020-2025)"
    echo "  season   : 季節 (spring/autumn)"  
    echo "  section  : 部 (morning/afternoon)"
    echo ""
    echo "オプション:"
    echo "  --all           : 全年度・全季節・全部を一括変換"
    echo "  --year YEAR     : 指定年度のみ"
    echo "  --validate-only : データ検証のみ実行"
    echo "  --dry-run       : 実際の変換は行わず、処理内容のみ表示"
    echo ""
    echo "例:"
    echo "  $0 2024 spring morning"
    echo "  $0 --all"
    echo "  $0 --year 2024"
    echo "  $0 --validate-only"
}

# 引数チェック
check_arguments() {
    local year=$1
    local season=$2
    local section=$3
    
    if [[ ! "$year" =~ ^(2020|2021|2022|2023|2024|2025)$ ]]; then
        log_error "無効な年度: $year (2020-2025で指定してください)"
        return 1
    fi
    
    if [[ ! "$season" =~ ^(spring|autumn)$ ]]; then
        log_error "無効な季節: $season (spring/autumnで指定してください)"
        return 1
    fi
    
    if [[ ! "$section" =~ ^(morning|afternoon)$ ]]; then
        log_error "無効な部: $section (morning/afternoonで指定してください)"
        return 1
    fi
    
    return 0
}

# ディレクトリ存在確認
check_directories() {
    if [[ ! -d "$EXAM_DATA_SOURCE_DIR" ]]; then
        log_error "データソースディレクトリが存在しません: $EXAM_DATA_SOURCE_DIR"
        return 1
    fi
    
    if [[ ! -d "$SEED_DATA_DIR" ]]; then
        log_error "シードデータディレクトリが存在しません: $SEED_DATA_DIR"
        return 1
    fi
    
    return 0
}

# 一時ディレクトリ作成
create_temp_directory() {
    mkdir -p "$TEMP_DIR"
    log_info "一時ディレクトリを作成: $TEMP_DIR"
}

# 一時ディレクトリクリーンアップ
cleanup_temp_directory() {
    if [[ -d "$TEMP_DIR" ]]; then
        rm -rf "$TEMP_DIR"
        log_info "一時ディレクトリを削除: $TEMP_DIR"
    fi
}

# データファイル検索
find_exam_data_files() {
    local year=$1
    local season=$2
    local section=$3
    
    local source_path="$EXAM_DATA_SOURCE_DIR/$year/$season/$section"
    
    if [[ ! -d "$source_path" ]]; then
        log_warning "データソースディレクトリが存在しません: $source_path"
        return 1
    fi
    
    # 各種形式のファイルを検索
    find "$source_path" -type f \( -name "*.json" -o -name "*.csv" -o -name "*.txt" -o -name "*.yaml" -o -name "*.yml" \) 2>/dev/null || true
}

# JSON形式の検証
validate_json_format() {
    local file=$1
    
    if ! jq empty "$file" 2>/dev/null; then
        log_error "無効なJSON形式: $file"
        return 1
    fi
    
    return 0
}

# 過去問データの標準化
standardize_exam_data() {
    local input_file=$1
    local year=$2
    local season=$3
    local section=$4
    local output_file="$TEMP_DIR/standardized_${year}_${season}_${section}.json"
    
    log_info "データの標準化: $input_file -> $output_file"
    
    # JSON形式の場合の変換処理
    if [[ "$input_file" == *.json ]]; then
        # 既存のJSONを標準形式に変換
        jq --arg year "$year" --arg season "$season" --arg section "$section" '
        if type == "array" then
            map(
                {
                    id: (.id // ("ap" + $year + $season + "_" + $section + "_" + ((.number // 1) | tostring))),
                    year: (.year // ($year | tonumber)),
                    season: (.season // $season),
                    section: (.section // $section), 
                    number: (.number // 1),
                    category: (.category // "未分類"),
                    subcategory: (.subcategory // ""),
                    difficulty: (.difficulty // 2),
                    question: (.question // .text // ""),
                    choices: (.choices // .options // []),
                    answer: (.answer // .correct_answer // ""),
                    explanation: (.explanation // .description // ""),
                    tags: (.tags // [])
                }
            )
        else
            [.]
        end
        ' "$input_file" > "$output_file"
    else
        log_warning "未対応の形式: $input_file"
        return 1
    fi
    
    echo "$output_file"
}

# データ整合性チェック
validate_exam_data() {
    local file=$1
    local errors=0
    
    log_info "データ整合性チェック: $file"
    
    # 必須フィールドのチェック
    local required_fields=("id" "year" "season" "section" "number" "category" "question" "choices" "answer")
    
    for field in "${required_fields[@]}"; do
        if ! jq -e ".[0] | has(\"$field\")" "$file" >/dev/null 2>&1; then
            log_error "必須フィールドが不足: $field"
            ((errors++))
        fi
    done
    
    # データ型チェック
    if ! jq -e 'all(.[]; .year | type == "number")' "$file" >/dev/null 2>&1; then
        log_error "年度は数値である必要があります"
        ((errors++))
    fi
    
    if ! jq -e 'all(.[]; .difficulty | type == "number")' "$file" >/dev/null 2>&1; then
        log_error "難易度は数値である必要があります"
        ((errors++))
    fi
    
    # 重複IDチェック
    local duplicate_count=$(jq -r '.[].id' "$file" | sort | uniq -d | wc -l)
    if [[ $duplicate_count -gt 0 ]]; then
        log_error "重複したIDが検出されました"
        ((errors++))
    fi
    
    if [[ $errors -eq 0 ]]; then
        log_success "データ整合性チェック完了: エラーなし"
        return 0
    else
        log_error "データ整合性チェック完了: $errors 個のエラー"
        return 1
    fi
}

# シードファイル統合
integrate_to_seed_file() {
    local standardized_file=$1
    local year=$2
    
    local seed_file="$SEED_DATA_DIR/questions-$year.json"
    local backup_file="$seed_file.backup.$(date +%Y%m%d_%H%M%S)"
    
    log_info "シードファイル統合: $seed_file"
    
    # バックアップ作成
    if [[ -f "$seed_file" ]]; then
        cp "$seed_file" "$backup_file"
        log_info "バックアップ作成: $backup_file"
    fi
    
    # 既存データと新データをマージ
    if [[ -f "$seed_file" ]]; then
        # 既存ファイルがある場合は重複を除去してマージ
        jq -s 'flatten | unique_by(.id) | sort_by(.number)' "$seed_file" "$standardized_file" > "$TEMP_DIR/merged.json"
        mv "$TEMP_DIR/merged.json" "$seed_file"
    else
        # 新規作成
        cp "$standardized_file" "$seed_file"
    fi
    
    log_success "シードファイル更新完了: $seed_file"
    
    # 統計情報表示
    local question_count=$(jq 'length' "$seed_file")
    log_info "問題数: $question_count"
}

# 単一データセットの変換
convert_single_dataset() {
    local year=$1
    local season=$2
    local section=$3
    local dry_run=${4:-false}
    
    log_info "=== $year年度 $season $section の変換開始 ==="
    
    if ! check_arguments "$year" "$season" "$section"; then
        return 1
    fi
    
    # データファイル検索
    local data_files
    data_files=$(find_exam_data_files "$year" "$season" "$section")
    
    if [[ -z "$data_files" ]]; then
        log_warning "データファイルが見つかりません: $year/$season/$section"
        return 0
    fi
    
    # 各ファイルを処理
    while IFS= read -r file; do
        if [[ -z "$file" ]]; then
            continue
        fi
        
        log_info "処理中: $file"
        
        if [[ "$dry_run" == "true" ]]; then
            log_info "[DRY RUN] 変換処理をスキップ: $file"
            continue
        fi
        
        # データ標準化
        local standardized_file
        if standardized_file=$(standardize_exam_data "$file" "$year" "$season" "$section"); then
            # データ検証
            if validate_exam_data "$standardized_file"; then
                # シードファイル統合
                integrate_to_seed_file "$standardized_file" "$year"
                log_success "変換完了: $file"
            else
                log_error "データ検証エラー: $file"
                return 1
            fi
        else
            log_error "データ標準化エラー: $file"
            return 1
        fi
    done <<< "$data_files"
    
    log_success "=== $year年度 $season $section の変換完了 ==="
}

# 全データセット変換
convert_all_datasets() {
    local dry_run=${1:-false}
    
    log_info "=== 全データセット変換開始 ==="
    
    local years=(2020 2021 2022 2023 2024 2025)
    local seasons=(spring autumn)
    local sections=(morning afternoon)
    
    for year in "${years[@]}"; do
        for season in "${seasons[@]}"; do
            for section in "${sections[@]}"; do
                convert_single_dataset "$year" "$season" "$section" "$dry_run"
            done
        done
    done
    
    log_success "=== 全データセット変換完了 ==="
}

# 指定年度のみ変換
convert_year_datasets() {
    local year=$1
    local dry_run=${2:-false}
    
    log_info "=== $year年度データセット変換開始 ==="
    
    local seasons=(spring autumn)
    local sections=(morning afternoon)
    
    for season in "${seasons[@]}"; do
        for section in "${sections[@]}"; do
            convert_single_dataset "$year" "$season" "$section" "$dry_run"
        done
    done
    
    log_success "=== $year年度データセット変換完了 ==="
}

# データ検証のみ実行
validate_only() {
    log_info "=== データ検証モード ==="
    
    for seed_file in "$SEED_DATA_DIR"/questions-*.json; do
        if [[ -f "$seed_file" ]]; then
            log_info "検証中: $seed_file"
            if validate_exam_data "$seed_file"; then
                log_success "検証OK: $seed_file"
            else
                log_error "検証NG: $seed_file"
            fi
        fi
    done
}

# メイン処理
main() {
    local dry_run=false
    local validate_only_mode=false
    
    # ディレクトリチェック
    if ! check_directories; then
        exit 1
    fi
    
    # 一時ディレクトリ作成
    create_temp_directory
    
    # トラップ設定（クリーンアップ）
    trap cleanup_temp_directory EXIT
    
    case "$1" in
        --help|-h)
            show_usage
            exit 0
            ;;
        --all)
            shift
            while [[ $# -gt 0 ]]; do
                case $1 in
                    --dry-run)
                        dry_run=true
                        ;;
                    *)
                        log_error "不明なオプション: $1"
                        show_usage
                        exit 1
                        ;;
                esac
                shift
            done
            convert_all_datasets "$dry_run"
            ;;
        --year)
            local year=$2
            shift 2
            while [[ $# -gt 0 ]]; do
                case $1 in
                    --dry-run)
                        dry_run=true
                        ;;
                    *)
                        log_error "不明なオプション: $1"
                        show_usage
                        exit 1
                        ;;
                esac
                shift
            done
            convert_year_datasets "$year" "$dry_run"
            ;;
        --validate-only)
            validate_only
            ;;
        *)
            if [[ $# -eq 3 ]]; then
                convert_single_dataset "$1" "$2" "$3"
            elif [[ $# -eq 0 ]]; then
                show_usage
                exit 1
            else
                log_error "引数が不正です"
                show_usage
                exit 1
            fi
            ;;
    esac
}

# スクリプト実行
main "$@"