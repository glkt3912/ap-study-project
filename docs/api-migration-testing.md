# API Migration Testing Guide

## 🎯 Phase 2 統一API実装状況

### ✅ 実装済み統一API

| 新API | 旧API | ステータス |
|-------|-------|----------|
| `/api/study-plans/:userId` | `/api/study/plan` + `/api/study-plan/:userId` | ✅ 統合完了 |
| `/api/test-sessions/:userId` | 複数のテストAPI | ✅ 統合完了 |
| `/api/user-analysis/:userId` | `/api/analysis/*` | ✅ 統合完了 |
| `/api/review-entries/:userId` | 未実装だった復習API | ✅ 新規実装 |

## 🧪 API動作テスト

### 1. Study Plans API テスト

```bash
# 新API: 学習計画取得
curl -X GET "http://localhost:8000/api/study-plans/1"

# 新API: 学習計画作成  
curl -X POST "http://localhost:8000/api/study-plans/1" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "応用情報対策プラン",
    "targetExamDate": "2024-04-21",
    "weeklyHours": 15,
    "studyDaysPerWeek": 6
  }'

# 新API: 学習単位更新
curl -X PUT "http://localhost:8000/api/study-plans/1/units/1" \
  -H "Content-Type: application/json" \
  -d '{
    "actualHours": 2.5,
    "isCompleted": true,
    "understanding": 4
  }'
```

### 2. Test Sessions API テスト

```bash
# 新API: テストセッション一覧
curl -X GET "http://localhost:8000/api/test-sessions/1?limit=5&offset=0"

# 新API: テストセッション作成
curl -X POST "http://localhost:8000/api/test-sessions/1" \
  -H "Content-Type: application/json" \
  -d '{
    "sessionType": "morning",
    "category": "ネットワーク",
    "totalQuestions": 20,
    "correctAnswers": 16,
    "timeSpentMinutes": 45,
    "isCompleted": true
  }'
```

### 3. User Analysis API テスト

```bash
# 新API: 分析結果取得
curl -X GET "http://localhost:8000/api/user-analysis/1?type=learning_efficiency"

# 新API: 新規分析作成
curl -X POST "http://localhost:8000/api/user-analysis/1" \
  -H "Content-Type: application/json" \
  -d '{
    "analysisType": "prediction",
    "overallScore": 75.5,
    "passProbability": 0.82,
    "weakSubjects": "データベース,セキュリティ",
    "strongSubjects": "ネットワーク,プログラミング"
  }'
```

### 4. Review Entries API テスト

```bash
# 新API: 復習項目一覧
curl -X GET "http://localhost:8000/api/review-entries/1"

# 新API: 今日の復習項目
curl -X GET "http://localhost:8000/api/review-entries/1/today"

# 新API: 復習完了マーク
curl -X PUT "http://localhost:8000/api/review-entries/1/123" \
  -H "Content-Type: application/json" \
  -d '{"understanding": 4}'
```

## 📊 レスポンス形式比較

### ✅ 新API統一レスポンス
```json
{
  "success": true,
  "data": { "...": "actual data" },
  "metadata": {
    "timestamp": "2024-01-15T10:30:00Z",
    "pagination": {
      "page": 1,
      "limit": 10,
      "total": 50
    }
  }
}
```

### ❌ 旧API非統一レスポンス
```json
// 旧API1: 直接データ返却
{ "studyPlan": { "...": "data" } }

// 旧API2: カスタム形式
{ "result": "success", "payload": { "...": "data" } }

// 旧API3: エラー時不統一
{ "error": "something went wrong" }
```

## 🔄 移行フェーズ

### Phase 2.1: ✅ 並行運用開始
- 新APIと旧APIを同時に提供
- 新APIの動作確認・テスト実施
- レガシーAPIは「Legacy」マーク

### Phase 2.2: 🔄 フロントエンド移行 (次のステップ)
- フロントエンドを新APIに段階的移行
- 旧API使用箇所の特定と更新
- OpenAPI型定義の再生成

### Phase 2.3: 🚧 レガシーAPI削除 (最終段階)
- 旧APIルートの完全削除
- ログによる使用状況確認後実施
- 最終的なAPI仕様書更新

## 📈 期待効果

### 🎯 重複エンドポイント解消
- 学習計画: 2つ → 1つ
- テストセッション: 3つ → 1つ  
- 分析結果: 複数 → 1つ
- 復習機能: 404エラー → 正常動作

### 🔧 開発効率向上
- 一貫性のあるAPI設計
- 予測可能なエンドポイント名
- 統一されたエラーハンドリング
- 自動生成される型定義

### 🚀 ユーザー体験改善
- 404エラーの大幅削減
- 一貫したローディング状態
- 予測可能なレスポンス形式