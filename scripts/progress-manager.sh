#!/bin/bash

# Progress Management System for AP Study Project
# Auto-updates tasks.md, development-log.md, and milestones.md

set -e

DOCS_DIR="docs/specifications"
TASKS_FILE="$DOCS_DIR/tasks.md"
DEV_LOG_FILE="$DOCS_DIR/development-log.md"
MILESTONES_FILE="$DOCS_DIR/milestones.md"

DATE=$(date +%Y-%m-%d)
TIME=$(date +%H:%M)
DATETIME="$DATE $TIME"

case $1 in
  "task-complete")
    if [ -z "$2" ]; then
      echo "Usage: ./scripts/progress-manager.sh task-complete '<task-description>'"
      exit 1
    fi
    
    TASK_DESC="$2"
    
    echo "✅ タスク完了記録: $TASK_DESC"
    
    # tasks.mdに完了記録追加
    echo "### **$DATE**" >> $TASKS_FILE
    echo "- ✅ **$TIME**: $TASK_DESC" >> $TASKS_FILE
    echo "" >> $TASKS_FILE
    
    # development-log.mdに詳細記録
    echo "#### **$DATETIME: タスク完了**" >> $DEV_LOG_FILE
    echo "- ✅ $TASK_DESC" >> $DEV_LOG_FILE
    echo "" >> $DEV_LOG_FILE
    
    echo "✅ 進捗記録完了"
    ;;

  "milestone-update")
    if [ -z "$2" ] || [ -z "$3" ]; then
      echo "Usage: ./scripts/progress-manager.sh milestone-update '<milestone-name>' '<status>'"
      echo "Status: planning, in-progress, completed"
      exit 1
    fi
    
    MILESTONE_NAME="$2"
    STATUS="$3"
    
    case $STATUS in
      "planning")
        STATUS_ICON="📋"
        STATUS_TEXT="計画中"
        ;;
      "in-progress") 
        STATUS_ICON="🔄"
        STATUS_TEXT="進行中"
        ;;
      "completed")
        STATUS_ICON="✅"
        STATUS_TEXT="完了"
        ;;
      *)
        echo "Invalid status. Use: planning, in-progress, completed"
        exit 1
        ;;
    esac
    
    echo "$STATUS_ICON マイルストーン更新: $MILESTONE_NAME → $STATUS_TEXT"
    
    # development-log.mdに記録
    echo "### **$DATE: マイルストーン更新**" >> $DEV_LOG_FILE
    echo "- $STATUS_ICON **$MILESTONE_NAME**: $STATUS_TEXT" >> $DEV_LOG_FILE
    echo "" >> $DEV_LOG_FILE
    
    echo "✅ マイルストーン更新完了"
    ;;

  "daily-summary")
    echo "📊 本日の開発サマリー生成: $DATE"
    
    # 本日のGitコミット数取得
    COMMITS_TODAY=$(git log --since="$DATE 00:00:00" --until="$DATE 23:59:59" --oneline | wc -l)
    
    # 本日変更されたファイル数
    FILES_CHANGED=$(git log --since="$DATE 00:00:00" --until="$DATE 23:59:59" --name-only --pretty=format: | sort -u | wc -l)
    
    # development-log.mdに日次サマリー追加
    cat >> $DEV_LOG_FILE << EOF

### **$DATE (Day X): 日次サマリー**

#### **📊 活動指標**
- **コミット数**: $COMMITS_TODAY件
- **変更ファイル数**: $FILES_CHANGED件
- **作業時間**: TODO: 手動入力
- **主要達成**: TODO: 手動入力

#### **🎯 本日の主要成果**
- [ ] TODO: 具体的な成果を記録
- [ ] TODO: 重要な変更・改善点
- [ ] TODO: 技術的な達成事項

#### **⚠️ 課題・ブロッカー**
- [ ] TODO: 発生した問題
- [ ] TODO: 解決待ちの課題
- [ ] TODO: 明日への引き継ぎ事項

#### **📋 明日の予定**
- [ ] TODO: 明日の主要タスク
- [ ] TODO: 優先度の高い作業
- [ ] TODO: 週間目標への貢献

EOF

    echo "✅ 日次サマリー テンプレート生成完了"
    echo "📝 $DEV_LOG_FILE を編集して詳細を追加してください"
    ;;

  "feature-start")
    if [ -z "$2" ]; then
      echo "Usage: ./scripts/progress-manager.sh feature-start '<feature-name>'"
      exit 1
    fi
    
    FEATURE_NAME="$2"
    
    echo "🚀 新機能開発開始: $FEATURE_NAME"
    
    # tasks.mdに開発タスク追加
    cat >> $TASKS_FILE << EOF

### **新機能開発: $FEATURE_NAME**
**開始日**: $DATE
**ステータス**: 🔄 開発中

#### **TDD開発タスク**
- [ ] **TDD-0**: 要件定義・仕様明確化
- [ ] **TDD-1**: Red Phase - 失敗テスト作成
- [ ] **TDD-2**: Green Phase - 最小実装
- [ ] **TDD-3**: Refactor Phase - 品質向上
- [ ] **TDD-4**: フロントエンド統合
- [ ] **TDD-5**: 完了確認・ドキュメント更新

#### **関連タスク**
- [ ] API仕様更新 (OpenAPI)
- [ ] 型定義更新 (TypeScript)
- [ ] テストカバレッジ確認
- [ ] セキュリティチェック
- [ ] パフォーマンス測定

EOF

    # development-log.mdに記録
    echo "### **$DATE: 新機能開発開始**" >> $DEV_LOG_FILE
    echo "- 🚀 **$FEATURE_NAME**: TDD開発開始" >> $DEV_LOG_FILE
    echo "- 📋 関連タスク11件生成" >> $DEV_LOG_FILE
    echo "" >> $DEV_LOG_FILE
    
    echo "✅ 新機能開発タスク生成完了"
    echo "🧪 TDD Helper で開発を開始: ./scripts/tdd-helper.sh init $FEATURE_NAME"
    ;;

  "week-summary")
    WEEK_START=$(date -d "monday" +%Y-%m-%d)
    WEEK_END=$(date -d "sunday" +%Y-%m-%d)
    
    echo "📊 週次サマリー生成: $WEEK_START 〜 $WEEK_END"
    
    # 週間のコミット数
    WEEK_COMMITS=$(git log --since="$WEEK_START 00:00:00" --until="$WEEK_END 23:59:59" --oneline | wc -l)
    
    # development-log.mdに週次サマリー追加
    cat >> $DEV_LOG_FILE << EOF

## 📊 週次サマリー ($WEEK_START 〜 $WEEK_END)

### **📈 週間指標**
- **総コミット数**: $WEEK_COMMITS件
- **主要機能追加**: TODO: 手動入力
- **バグ修正**: TODO: 手動入力
- **テストカバレッジ**: TODO: 測定結果

### **🏆 週間主要成果**
- [ ] TODO: 重要な機能追加・改善
- [ ] TODO: 技術的な達成事項
- [ ] TODO: 品質向上・最適化

### **🎯 来週の目標**
- [ ] TODO: 来週の主要目標
- [ ] TODO: 重点的に取り組む課題
- [ ] TODO: マイルストーンへの貢献

EOF

    echo "✅ 週次サマリー テンプレート生成完了"
    ;;

  "status")
    echo "📊 Progress Management System Status"
    echo ""
    echo "📁 管理ファイル:"
    echo "  - Tasks: $TASKS_FILE"
    echo "  - Dev Log: $DEV_LOG_FILE" 
    echo "  - Milestones: $MILESTONES_FILE"
    echo ""
    echo "📅 最終更新:"
    echo "  - Tasks: $(stat -c %y $TASKS_FILE 2>/dev/null || echo 'Not found')"
    echo "  - Dev Log: $(stat -c %y $DEV_LOG_FILE 2>/dev/null || echo 'Not found')"
    echo ""
    echo "🔄 利用可能コマンド:"
    echo "  - task-complete '<description>'"
    echo "  - milestone-update '<name>' '<status>'"
    echo "  - feature-start '<feature-name>'"
    echo "  - daily-summary"
    echo "  - week-summary"
    ;;

  *)
    echo "🚀 Progress Management System"
    echo ""
    echo "Commands:"
    echo "  task-complete '<description>'     - タスク完了記録"
    echo "  milestone-update '<name>' '<status>' - マイルストーン更新"
    echo "  feature-start '<feature-name>'    - 新機能開発開始"
    echo "  daily-summary                     - 日次サマリー生成"
    echo "  week-summary                      - 週次サマリー生成"
    echo "  status                           - 現在の状況確認"
    echo ""
    echo "Examples:"
    echo "  ./scripts/progress-manager.sh task-complete 'TDD環境構築完了'"
    echo "  ./scripts/progress-manager.sh milestone-update 'Milestone 3' 'in-progress'"
    echo "  ./scripts/progress-manager.sh feature-start 'UserAuthentication'"
    echo "  ./scripts/progress-manager.sh daily-summary"
    ;;
esac