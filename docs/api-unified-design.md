# Unified API Design - Simplified Architecture

## 🎯 目標
重複APIエンドポイントを統一し、一貫性のあるAPI設計を実現

## 📊 現状の問題点

### ❌ 重複エンドポイント
| 機能 | 現在 | 問題 |
|------|------|------|
| 学習計画 | `/api/study/plan` + `/api/study-plan/:userId` | 2つのエンドポイントが競合 |
| 復習システム | `/api/analysis/review/*` | 実装されていない404エラー |
| 学習ログ | `/api/studylog` + StudyUnit | データ形式が異なる |

### ❌ 一貫性のない命名
```
/api/study/plan      <- kebab-case + noun
/api/studylog        <- camelCase + noun  
/api/exam-config     <- kebab-case + noun
/api/study-plan      <- kebab-case + noun
```

## ✅ 統一API設計

### 🎯 命名規則
- **URL**: kebab-case (`/api/study-plans`)
- **リソース**: 複数形 (`plans`, `sessions`, `entries`)
- **HTTP Method**: RESTful原則に従う

### 📚 エンドポイント統一

#### 1. Study Plans (学習計画)
```typescript
// 統一後: /api/study-plans
GET    /api/study-plans/:userId           // 取得
POST   /api/study-plans/:userId           // 作成
PUT    /api/study-plans/:userId           // 更新
DELETE /api/study-plans/:userId           // 削除

// 学習単位
GET    /api/study-plans/:userId/units     // 学習単位一覧
PUT    /api/study-plans/:userId/units/:id // 進捗更新
```

#### 2. Test Sessions (テストセッション)
```typescript
// 統一後: /api/test-sessions
GET    /api/test-sessions/:userId         // セッション一覧
POST   /api/test-sessions/:userId         // セッション作成
GET    /api/test-sessions/:userId/:id     // セッション詳細
PUT    /api/test-sessions/:userId/:id     // セッション更新
```

#### 3. User Analysis (分析結果)
```typescript
// 統一後: /api/user-analysis
GET    /api/user-analysis/:userId         // 分析結果一覧
POST   /api/user-analysis/:userId         // 新規分析実行
GET    /api/user-analysis/:userId/latest  // 最新分析
```

#### 4. Review Entries (復習エントリ)
```typescript
// 統一後: /api/review-entries
GET    /api/review-entries/:userId        // 復習項目一覧
GET    /api/review-entries/:userId/today  // 今日の復習
POST   /api/review-entries/:userId        // 復習項目追加
PUT    /api/review-entries/:userId/:id    // 復習完了
```

#### 5. Exam Config (試験設定)
```typescript
// 既存維持: /api/exam-configs
GET    /api/exam-configs/:userId          // 設定取得
POST   /api/exam-configs/:userId          // 設定作成
PUT    /api/exam-configs/:userId          // 設定更新
```

## 🔄 移行計画

### Phase 2.1: 新API実装
1. 新しいルートファイル作成
2. 簡素化されたリポジトリ実装
3. 統一されたレスポンス形式

### Phase 2.2: 段階的移行
1. 両方のAPIを一時的に並行運用
2. フロントエンドを新APIに移行
3. 旧APIの廃止

### Phase 2.3: 文書化
1. OpenAPI仕様書更新
2. 型定義自動生成確認
3. エラーハンドリング標準化

## 📋 レスポンス形式統一

### ✅ 成功レスポンス
```typescript
{
  success: true,
  data: T,
  metadata?: {
    pagination?: PaginationInfo,
    version?: string,
    timestamp?: string
  }
}
```

### ❌ エラーレスポンス  
```typescript
{
  success: false,
  error: {
    code: string,
    message: string,
    details?: any
  },
  timestamp: string
}
```

## 🎯 期待効果

### 開発効率
- ✅ 一貫性のあるAPI設計
- ✅ 自動生成される型定義
- ✅ 予測可能なエンドポイント

### 保守性
- ✅ 重複コードの削減
- ✅ 統一されたエラーハンドリング
- ✅ 簡潔なドキュメント

### ユーザー体験
- ✅ 404エラーの削減
- ✅ 一貫したローディング状態
- ✅ 予測可能な動作