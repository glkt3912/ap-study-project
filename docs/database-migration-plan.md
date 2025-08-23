# Database Migration Plan: Complex → Simple

## 🎯 目標
22テーブル → 12テーブルに削減し、システムの複雑性を大幅に改善

## 📊 変更概要

### ✅ 統合されるテーブル

| 旧システム | 新システム | 変更内容 |
|------------|------------|----------|
| `MorningTest` + `AfternoonTest` + `QuizSession` | `TestSession` | 3→1に統合 |
| `AnalysisResult` + `PredictionResult` | `UserAnalysis` | 2→1に統合 |
| `ReviewItem` + `ReviewSession` | `ReviewEntry` | 2→1に統合 |
| `StudyPlan` + `StudyWeek` + `StudyDay` | `StudyPlan` + `StudyUnit` | 3→2に簡素化 |
| `StudyLog` | `StudyUnit` | 統合（学習記録を学習単位に） |

### 🗑️ 削除されるテーブル

- `StudyPlanTemplate` (static data → code)
- `StudyScheduleTemplate` (static data → code)  
- `StudyRecommendation` (→ `UserAnalysis` に統合)
- `StudyPlanPreferences` (→ `StudyPlan` に統合)
- `UserAnswer` (→ `TestAnswer` に統合)

### 📈 改善ポイント

**テーブル数**: 22 → 12 (45%削減)  
**User関連**: 13 → 5 (60%削減)  
**Jsonフィールド**: 18 → 2 (90%削減)

## 🔄 段階的マイグレーション

### Phase 1: 新テーブル作成
1. `schema-simplified.prisma` → `schema.prisma` 置換
2. `prisma migrate dev --name simplify_tables`
3. 新テーブル構造確認

### Phase 2: データ移行スクリプト
```sql
-- TestSession統合
INSERT INTO test_sessions (userId, sessionType, category, ...)
SELECT userId, 'morning', category, ... FROM morning_tests
UNION ALL  
SELECT userId, 'afternoon', category, ... FROM afternoon_tests
UNION ALL
SELECT userId, 'quiz', category, ... FROM quiz_sessions;

-- UserAnalysis統合  
INSERT INTO user_analysis (userId, analysisType, ...)
SELECT userId, 'learning_efficiency', ... FROM analysis_results
UNION ALL
SELECT userId, 'prediction', ... FROM prediction_results;

-- その他のテーブル...
```

### Phase 3: API更新
1. Repository層の更新
2. UseCase層の更新  
3. API Routes更新
4. フロントエンド適応

### Phase 4: 旧テーブル削除
1. 動作確認完了後
2. バックアップ取得
3. 旧テーブルDROP

## 🚀 期待効果

### 開発効率
- ✅ 理解しやすいテーブル構造
- ✅ 型安全性の向上(JSON→構造化)
- ✅ 保守性の向上

### システム性能  
- ✅ クエリ最適化の容易さ
- ✅ インデックス設計の簡素化
- ✅ JOIN操作の削減

### エラー削減
- ✅ 複雑な関連の解消
- ✅ データ整合性の向上
- ✅ API設計の一貫性

## ⚠️ リスク管理

### データ損失防止
- 全段階でバックアップ取得
- ロールバック手順の準備
- 段階的移行でリスク分散

### 動作確認
- 自動テストスイート実行
- 手動機能テスト
- パフォーマンステスト

## 📅 実行スケジュール

- **Day 1**: 新スキーマ作成・マイグレーション実行
- **Day 2**: データ移行スクリプト作成・実行
- **Day 3**: Repository/UseCase更新  
- **Day 4**: API Routes更新・テスト
- **Day 5**: フロントエンド適応
- **Day 6**: 最終確認・旧テーブル削除