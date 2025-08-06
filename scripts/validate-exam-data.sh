#!/bin/bash

# 過去問データ統合・検証スクリプト
# Usage: ./scripts/validate-exam-data.sh [options]

set -e

# 設定
SEED_DATA_DIR="ap-study-backend/src/infrastructure/database/seeds"
REPORT_DIR="exam-data-reports"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

# カラー出力
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# ログ関数
log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
log_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }
log_report() { echo -e "${CYAN}[REPORT]${NC} $1"; }

# レポートディレクトリ作成
mkdir -p "$REPORT_DIR"

# 使用法表示
show_usage() {
    echo "使用法: $0 [options]"
    echo ""
    echo "オプション:"
    echo "  --report        : 詳細レポートを生成"
    echo "  --fix-ids       : 重複IDの自動修正"
    echo "  --statistics    : 統計情報のみ表示"
    echo "  --coverage      : 網羅率分析"
    echo "  --help|-h       : ヘルプ表示"
}

# 統計情報収集
collect_statistics() {
    local total_questions=0
    local by_year=()
    local by_category=()
    local by_difficulty=()
    
    log_info "統計情報を収集中..."
    
    # 年度別統計
    for year in {2020..2025}; do
        local file="$SEED_DATA_DIR/questions-$year.json"
        if [[ -f "$file" ]]; then
            local count=$(jq 'length' "$file" 2>/dev/null || echo "0")
            by_year+=("$year:$count")
            total_questions=$((total_questions + count))
        else
            by_year+=("$year:0")
        fi
    done
    
    # カテゴリ別統計（全ファイルから）
    local categories=$(find "$SEED_DATA_DIR" -name "questions-*.json" -exec jq -r '.[].category' {} \; 2>/dev/null | sort | uniq -c | sort -nr)
    
    # 難易度別統計
    local difficulties=$(find "$SEED_DATA_DIR" -name "questions-*.json" -exec jq -r '.[].difficulty' {} \; 2>/dev/null | sort | uniq -c | sort -n)
    
    # 結果表示
    log_report "=== 統計情報 ==="
    log_report "総問題数: $total_questions"
    echo ""
    
    log_report "年度別問題数:"
    for stat in "${by_year[@]}"; do
        local year=$(echo "$stat" | cut -d: -f1)
        local count=$(echo "$stat" | cut -d: -f2)
        printf "  %s年度: %3d問\n" "$year" "$count"
    done
    echo ""
    
    if [[ -n "$categories" ]]; then
        log_report "カテゴリ別問題数:"
        echo "$categories" | while read -r count category; do
            printf "  %-20s: %3d問\n" "$category" "$count"
        done
        echo ""
    fi
    
    if [[ -n "$difficulties" ]]; then
        log_report "難易度別問題数:"
        echo "$difficulties" | while read -r count difficulty; do
            printf "  難易度%s: %3d問\n" "$difficulty" "$count"
        done
        echo ""
    fi
    
    # 推定網羅率計算（1年あたり約80問と仮定）
    local estimated_total=$((6 * 80))  # 6年 × 80問
    local coverage_percent=$((total_questions * 100 / estimated_total))
    log_report "推定網羅率: ${coverage_percent}% (${total_questions}/${estimated_total})"
}

# データ整合性チェック
check_data_integrity() {
    local total_errors=0
    
    log_info "データ整合性チェック中..."
    
    for file in "$SEED_DATA_DIR"/questions-*.json; do
        if [[ ! -f "$file" ]]; then
            continue
        fi
        
        local year=$(basename "$file" .json | sed 's/questions-//')
        log_info "チェック中: $year年度"
        
        local errors=0
        
        # JSON形式チェック
        if ! jq empty "$file" 2>/dev/null; then
            log_error "$year年度: 無効なJSON形式"
            ((errors++))
        fi
        
        # 必須フィールドチェック
        local required_fields=("id" "year" "season" "section" "number" "category" "question" "choices" "answer")
        for field in "${required_fields[@]}"; do
            local missing_count=$(jq -r "[.[] | select(has(\"$field\") | not)] | length" "$file" 2>/dev/null || echo "0")
            if [[ $missing_count -gt 0 ]]; then
                log_error "$year年度: $field フィールドが $missing_count 問で不足"
                ((errors++))
            fi
        done
        
        # 年度整合性チェック
        local wrong_year_count=$(jq -r "[.[] | select(.year != $year)] | length" "$file" 2>/dev/null || echo "0")
        if [[ $wrong_year_count -gt 0 ]]; then
            log_error "$year年度: 年度が不整合な問題が $wrong_year_count 問"
            ((errors++))
        fi
        
        # 重複IDチェック
        local duplicate_count=$(jq -r '.[].id' "$file" | sort | uniq -d | wc -l)
        if [[ $duplicate_count -gt 0 ]]; then
            log_error "$year年度: 重複IDが $duplicate_count 個"
            ((errors++))
        fi
        
        # 空文字列チェック
        local empty_questions=$(jq -r '[.[] | select(.question == "")] | length' "$file" 2>/dev/null || echo "0")
        if [[ $empty_questions -gt 0 ]]; then
            log_warning "$year年度: 問題文が空の問題が $empty_questions 問"
            ((errors++))
        fi
        
        # 選択肢数チェック
        local invalid_choices=$(jq -r '[.[] | select((.choices | length) < 2)] | length' "$file" 2>/dev/null || echo "0")
        if [[ $invalid_choices -gt 0 ]]; then
            log_warning "$year年度: 選択肢が不足している問題が $invalid_choices 問"
            ((errors++))
        fi
        
        if [[ $errors -eq 0 ]]; then
            log_success "$year年度: エラーなし"
        else
            log_error "$year年度: $errors 個のエラー"
            total_errors=$((total_errors + errors))
        fi
    done
    
    if [[ $total_errors -eq 0 ]]; then
        log_success "全データ整合性チェック完了: エラーなし"
        return 0
    else
        log_error "全データ整合性チェック完了: 合計 $total_errors 個のエラー"
        return 1
    fi
}

# 重複ID修正
fix_duplicate_ids() {
    log_info "重複ID自動修正中..."
    
    for file in "$SEED_DATA_DIR"/questions-*.json; do
        if [[ ! -f "$file" ]]; then
            continue
        fi
        
        local year=$(basename "$file" .json | sed 's/questions-//')
        local backup_file="$file.backup.$TIMESTAMP"
        
        # バックアップ作成
        cp "$file" "$backup_file"
        log_info "$year年度: バックアップ作成 $backup_file"
        
        # 重複ID修正（連番で再生成）
        jq -r '
        . as $data |
        reduce range(length) as $i ([]; 
            . + [$data[$i] | 
                .id = ("ap" + (.year | tostring) + .season + "_" + .section + "_" + (($i + 1) | tostring | sprintf("%02d")))
            ]
        )' "$file" > "$file.tmp" && mv "$file.tmp" "$file"
        
        log_success "$year年度: ID修正完了"
    done
}

# 網羅率分析
analyze_coverage() {
    log_info "網羅率分析中..."
    
    local report_file="$REPORT_DIR/coverage_analysis_$TIMESTAMP.txt"
    
    {
        echo "=== 応用情報技術者試験 過去問データ網羅率分析 ==="
        echo "生成日時: $(date)"
        echo ""
        
        # 年度別詳細分析
        echo "=== 年度別詳細分析 ==="
        for year in {2020..2025}; do
            local file="$SEED_DATA_DIR/questions-$year.json"
            if [[ -f "$file" ]]; then
                local total=$(jq 'length' "$file")
                local spring_morning=$(jq '[.[] | select(.season == "spring" and .section == "morning")] | length' "$file")
                local spring_afternoon=$(jq '[.[] | select(.season == "spring" and .section == "afternoon")] | length' "$file")
                local autumn_morning=$(jq '[.[] | select(.season == "autumn" and .section == "morning")] | length' "$file")
                local autumn_afternoon=$(jq '[.[] | select(.season == "autumn" and .section == "afternoon")] | length' "$file")
                
                printf "%s年度: 合計%3d問 (春午前:%2d, 春午後:%2d, 秋午前:%2d, 秋午後:%2d)\n" \
                    "$year" "$total" "$spring_morning" "$spring_afternoon" "$autumn_morning" "$autumn_afternoon"
            else
                printf "%s年度: データなし\n" "$year"
            fi
        done
        echo ""
        
        # カテゴリ網羅率分析
        echo "=== カテゴリ網羅率分析 ==="
        local categories=("基礎理論" "コンピュータシステム" "技術要素" "開発技術" "プロジェクトマネジメント" "サービスマネジメント" "システム戦略" "経営戦略・企業と法務")
        
        for category in "${categories[@]}"; do
            local count=$(find "$SEED_DATA_DIR" -name "questions-*.json" -exec jq -r --arg cat "$category" '[.[] | select(.category == $cat)] | length' {} \; 2>/dev/null | awk '{sum += $1} END {print sum+0}')
            printf "%-30s: %3d問\n" "$category" "$count"
        done
        echo ""
        
        # 推奨改善案
        echo "=== 推奨改善案 ==="
        echo "1. 不足年度のデータ補強"
        echo "2. 午後問題（記述式）の充実"
        echo "3. 最新技術動向を反映した問題の追加"
        echo "4. 難易度バランスの調整"
        
    } | tee "$report_file"
    
    log_success "網羅率分析完了: $report_file"
}

# 詳細レポート生成
generate_detailed_report() {
    log_info "詳細レポート生成中..."
    
    local report_file="$REPORT_DIR/detailed_report_$TIMESTAMP.html"
    
    cat > "$report_file" << 'EOF'
<!DOCTYPE html>
<html lang="ja">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>応用情報技術者試験 過去問データ分析レポート</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 20px; }
        .header { background: #f0f8ff; padding: 20px; border-radius: 5px; margin-bottom: 20px; }
        .section { margin-bottom: 30px; }
        .stats-table { border-collapse: collapse; width: 100%; }
        .stats-table th, .stats-table td { border: 1px solid #ddd; padding: 8px; text-align: left; }
        .stats-table th { background-color: #f2f2f2; }
        .chart { margin: 20px 0; }
        .success { color: #28a745; }
        .warning { color: #ffc107; }
        .error { color: #dc3545; }
    </style>
</head>
<body>
    <div class="header">
        <h1>応用情報技術者試験 過去問データ分析レポート</h1>
        <p>生成日時: <script>document.write(new Date().toLocaleString('ja-JP'));</script></p>
    </div>
EOF

    # JavaScript でデータを動的に挿入
    cat >> "$report_file" << 'EOF'
    <div class="section">
        <h2>統計サマリー</h2>
        <div id="statistics"></div>
    </div>
    
    <div class="section">
        <h2>年度別データ状況</h2>
        <table class="stats-table">
            <thead>
                <tr><th>年度</th><th>問題数</th><th>春季</th><th>秋季</th><th>状況</th></tr>
            </thead>
            <tbody id="year-stats"></tbody>
        </table>
    </div>
    
    <div class="section">
        <h2>カテゴリ別分布</h2>
        <div id="category-chart"></div>
    </div>
    
    <script>
        // データ統計の動的生成
        fetch('statistics.json')
            .then(response => response.json())
            .then(data => {
                // 統計データの表示処理
                displayStatistics(data);
            })
            .catch(error => {
                console.log('統計データを手動で更新してください');
                displayPlaceholderData();
            });
            
        function displayPlaceholderData() {
            document.getElementById('statistics').innerHTML = 
                '<p>詳細データは ./scripts/validate-exam-data.sh --report を実行して更新してください。</p>';
        }
    </script>
</body>
</html>
EOF

    log_success "詳細レポート生成完了: $report_file"
}

# メイン処理
main() {
    case "$1" in
        --help|-h)
            show_usage
            exit 0
            ;;
        --statistics)
            collect_statistics
            ;;
        --report)
            collect_statistics
            check_data_integrity
            analyze_coverage
            generate_detailed_report
            ;;
        --fix-ids)
            fix_duplicate_ids
            ;;
        --coverage)
            analyze_coverage
            ;;
        "")
            collect_statistics
            check_data_integrity
            ;;
        *)
            log_error "不明なオプション: $1"
            show_usage
            exit 1
            ;;
    esac
}

# スクリプト実行
main "$@"