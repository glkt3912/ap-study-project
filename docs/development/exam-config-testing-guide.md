# 試験日設定機能テストガイド

## 📋 概要

試験日設定機能の包括的なテスト戦略とテストケース一覧です。
ユニットテストから統合テストまで、品質保証のための完全なテストスイートを提供します。

## 🧪 テストの構成

### 1. バックエンドテスト

#### APIエンドポイントテスト
**場所**: `src/__tests__/unit/exam-config-api.test.ts`

```bash
# テスト実行
npm test -- exam-config-api

# 特定のテストケース実行
npm test -- exam-config-api -t "should return exam config with remaining days"
```

**テストカバレッジ**:
- ✅ GET `/api/exam-config/:userId` - 設定取得
- ✅ POST `/api/exam-config/:userId` - 設定作成・更新  
- ✅ DELETE `/api/exam-config/:userId` - 設定削除
- ✅ バリデーションエラーハンドリング
- ✅ 残り日数計算の正確性
- ✅ エラーレスポンス形式

#### ユーティリティ関数テスト
**場所**: `src/__tests__/unit/exam-utils.test.ts`

```bash
# テスト実行
npm test -- exam-utils
```

**テストカバレッジ**:
- ✅ `calculateRemainingDays()` - 日数計算
- ✅ `getExamStatus()` - 状況判定
- ✅ `formatRemainingDays()` - 表示形式変換
- ✅ `calculateStudyUrgency()` - 学習推奨度計算
- ✅ エッジケース（うるう年、月境界）
- ✅ タイムゾーン一貫性

#### 統合テスト
**場所**: `src/__tests__/integration/exam-config-integration.test.ts`

```bash
# テスト実行
npm test -- exam-config-integration
```

**テストカバレッジ**:
- ✅ 完全なCRUDワークフロー
- ✅ データベース整合性
- ✅ 同時操作処理
- ✅ 外部キー制約
- ✅ ユニーク制約

### 2. フロントエンドテスト

#### コンポーネントテスト
**場所**: `src/components/__tests__/ExamConfigModal.test.tsx`

```bash
# テスト実行（ap-study-app ディレクトリ内で実行）
npm test -- ExamConfigModal

# ウォッチモード
npm test -- ExamConfigModal --watch
```

**テストカバレッジ**:
- ✅ モーダル表示・非表示
- ✅ フォーム入力・バリデーション
- ✅ API呼び出し連携
- ✅ エラーハンドリング表示
- ✅ ローディング状態
- ✅ 削除確認フロー

#### API クライアントテスト
**場所**: `src/lib/__tests__/exam-config-api.test.ts`

```bash
# テスト実行
npm test -- exam-config-api
```

**テストカバレッジ**:
- ✅ HTTP リクエスト形式
- ✅ レスポンス処理
- ✅ エラーハンドリング
- ✅ 認証ヘッダー
- ✅ URL エンコーディング

## 🎯 テストケース詳細

### 正常系テスト

#### 新規作成フロー
```typescript
// 1. 設定が存在しないことを確認
GET /api/exam-config/1 → 404

// 2. 新規作成
POST /api/exam-config/1
Body: { examDate: "2024-12-01", targetScore: 85 }
→ 200, remainingDays 計算済み

// 3. 作成された設定を取得
GET /api/exam-config/1 → 200, 作成されたデータ
```

#### 更新フロー
```typescript
// 1. 既存設定を更新
POST /api/exam-config/1  
Body: { examDate: "2024-12-15", targetScore: 90 }
→ 200, 更新されたデータ

// 2. 部分更新（targetScore のみ）
POST /api/exam-config/1
Body: { targetScore: 95 }
→ 200, examDate は変更されず
```

#### 削除フロー
```typescript
// 1. 設定を削除
DELETE /api/exam-config/1 
→ 200, success message

// 2. 削除確認
GET /api/exam-config/1 → 404
```

### 異常系テスト

#### バリデーションエラー
```typescript
// 無効な日付形式
POST /api/exam-config/1
Body: { examDate: "invalid-date" }
→ 400, validation error details

// 無効なユーザーID
POST /api/exam-config/invalid
→ 400, "Invalid user ID"

// 必須フィールド不足
POST /api/exam-config/1
Body: { targetScore: 80 }  // examDate なし
→ 400, validation error
```

#### データベースエラー
```typescript
// 存在しないユーザー
POST /api/exam-config/99999
Body: { examDate: "2024-12-01" }
→ 500, foreign key constraint error

// 削除時の存在チェック
DELETE /api/exam-config/99999
→ 500, record not found
```

### エッジケーステスト

#### 日数計算の境界値
```typescript
describe('Boundary value tests', () => {
  // 今日の日付
  calculateRemainingDays(today) → 0
  
  // 昨日の日付
  calculateRemainingDays(yesterday) → -1
  
  // 明日の日付
  calculateRemainingDays(tomorrow) → 1
  
  // うるう年の2月29日
  calculateRemainingDays(leapDay) → 適切な計算結果
})
```

#### 時間コンポーネント無視
```typescript
// 同じ日の異なる時刻は同じ結果
calculateRemainingDays('2024-12-01T08:00:00Z') === 
calculateRemainingDays('2024-12-01T20:00:00Z')
```

## 🚀 テスト実行方法

### バックエンドテスト

```bash
# 全テスト実行
npm test

# 試験設定関連のみ
npm test -- exam-config
npm test -- exam-utils

# カバレッジレポート生成
npm run test:coverage

# ウォッチモード
npm test -- --watch
```

### フロントエンドテスト

```bash
# ap-study-app ディレクトリに移動
cd ap-study-app

# 全テスト実行
npm test

# 試験設定関連のみ
npm test -- ExamConfig

# カバレッジレポート
npm run test:coverage
```

### 統合テスト

```bash
# データベースを起動してから実行
docker compose up postgres -d
npm run test:integration
```

## 📊 期待されるカバレッジ目標

### バックエンド
- **Line Coverage**: 95%以上
- **Branch Coverage**: 90%以上
- **Function Coverage**: 100%

### フロントエンド
- **Line Coverage**: 90%以上
- **Branch Coverage**: 85%以上
- **Function Coverage**: 95%以上

## 🔧 テスト環境設定

### 必要な環境変数
```bash
# テスト用データベース
DATABASE_URL="postgresql://user:password@localhost:5432/test_db"

# テスト環境フラグ
NODE_ENV="test"

# API ベースURL
NEXT_PUBLIC_API_URL="http://localhost:8000"
```

### モックとスタブ

#### バックエンド
```typescript
// Prisma Client モック
const mockPrisma = {
  examConfig: {
    findUnique: vi.fn(),
    create: vi.fn(),
    update: vi.fn(),
    delete: vi.fn(),
  },
};
```

#### フロントエンド
```typescript
// API クライアントモック
const mockApi = {
  getExamConfig: vi.fn(),
  setExamConfig: vi.fn(),
  updateExamConfig: vi.fn(),
  deleteExamConfig: vi.fn(),
};
```

## 🐛 トラブルシューティング

### よくある問題

#### テスト時間の不一致
```typescript
// 解決方法: システム時間を固定
beforeEach(() => {
  vi.setSystemTime(new Date('2024-08-10T12:00:00Z'));
});
```

#### データベース接続エラー
```bash
# PostgreSQL が起動していることを確認
docker compose up postgres -d

# テスト用データベースの作成
createdb test_db
```

#### フロントエンドの型エラー
```typescript
// 型定義が更新されている場合
npm run generate-types
```

## 📈 継続的インテグレーション

### GitHub Actions 設定例
```yaml
name: Test Exam Config Feature
on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    services:
      postgres:
        image: postgres:15
        env:
          POSTGRES_PASSWORD: password
        options: >-
          --health-cmd pg_isready
          --health-interval 10s
          --health-timeout 5s
          --health-retries 5

    steps:
      - uses: actions/checkout@v3
      - uses: actions/setup-node@v3
        with:
          node-version: '22'
      
      - name: Install dependencies
        run: npm ci
      
      - name: Run database migrations
        run: npm run db:migrate
        
      - name: Run tests
        run: npm run test:coverage
        
      - name: Upload coverage
        uses: codecov/codecov-action@v3
```

## 🔄 テストデータ管理

### テストデータクリーンアップ
```typescript
// 各テスト後のクリーンアップ
afterEach(async () => {
  await prisma.examConfig.deleteMany({
    where: { userId: testUserId },
  });
});
```

### テストデータファクトリー
```typescript
const createTestExamConfig = (overrides = {}) => ({
  examDate: '2024-12-01T00:00:00Z',
  targetScore: 80,
  ...overrides,
});
```

---

**💡 重要**: テストは開発の品質保証の要です。新機能追加時は必ず対応するテストも作成してください。