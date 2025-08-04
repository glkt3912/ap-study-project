# 🔄 開発ワークフロー（Claude Code専用）

## 🎯 Claude Code 効率化設定

### 📋 作業開始時のチェックリスト

```bash
# 1. 現在の状況確認
git status
git log --oneline -5

# 2. 依存関係確認
cd ap-study-backend && npm install
cd ../ap-study-app && npm install

# 3. 環境動作確認
docker compose up --build
# または
npm run dev (各ディレクトリで)
```

### 🧪 TDD段階的実装フロー (推奨)

#### TDD-0: 要件定義 (5分)

```bash
# TodoWriteで機能要件を明確化
# 「StudyLog作成機能」例：
# - [ ] ユーザーが学習時間を記録できる
# - [ ] 理解度を1-5で評価できる  
# - [ ] メモを追加できる
# - [ ] データがDBに保存される
```

#### TDD-1: Red (失敗テスト作成) (10分)

```bash
cd ap-study-backend

# 1. テストファイル作成
touch src/__tests__/CreateStudyLog.test.ts

# 2. 失敗テストを記述
# - APIエンドポイントの存在確認
# - 入力バリデーション確認
# - DB保存確認
```

#### TDD-2: Green (最小実装) (15分)

```bash
# 1. テストが通る最小実装
# - エンティティ定義
# - リポジトリI/F
# - ユースケース（仮実装）
# - API（仮実装）

# 2. テスト実行で緑を確認
npm test CreateStudyLog.test.ts
```

#### TDD-3: Refactor (リファクタリング) (10分)

```bash
# 1. コード品質向上
# - 適切な命名
# - エラーハンドリング
# - 型安全性向上

# 2. テスト実行で緑を維持
npm test CreateStudyLog.test.ts
npm run lint
```

#### TDD-4: フロントエンド統合 (15分)

```bash
cd ../ap-study-app

# 1. APIクライアント実装
# 2. UI コンポーネント実装  
# 3. E2Eテスト確認
npm run test:run
```

#### TDD-5: 完了確認 (5分)

```bash
# TodoWriteで進捗更新
# - [ ] ✅ バックエンドテスト通過
# - [ ] ✅ フロントエンドテスト通過
# - [ ] ✅ 手動動作確認完了
# - [ ] ✅ コード品質チェック通過
```

### 🤖 Claude Code TDD支援

#### TDD開始時のTodo設定

```typescript
// Claude Codeでの自動TDD進捗管理
TodoWrite: [
  { content: "TDD-0: [機能名] 要件定義", status: "pending" },
  { content: "TDD-1: [機能名] Red - 失敗テスト", status: "pending" },
  { content: "TDD-2: [機能名] Green - 最小実装", status: "pending" },
  { content: "TDD-3: [機能名] Refactor - 品質向上", status: "pending" },
  { content: "TDD-4: [機能名] フロントエンド統合", status: "pending" },
  { content: "TDD-5: [機能名] 完了確認", status: "pending" }
]
```

#### 段階的チェックポイント

```bash
# TDD-1 (Red) 成功基準
✅ テストが失敗する（期待通り）
✅ テストコードが明確で理解しやすい
✅ エッジケースを含む

# TDD-2 (Green) 成功基準  
✅ 全テストが通過する
✅ 最小限の実装（過剰実装なし）
✅ 仮実装でも動作する

# TDD-3 (Refactor) 成功基準
✅ テストが引き続き通過する
✅ コード品質が向上している
✅ 適切な抽象化ができている
```

#### TDD実践例: StudyLog作成機能

```bash
# 1. 要件をTodoに設定
TodoWrite: "StudyLog作成: ユーザーが学習記録を作成できる"

# 2. Redフェーズ
Write: src/__tests__/CreateStudyLog.test.ts
- API POST /api/study/logs のテスト
- 入力バリデーションテスト
- DB保存確認テスト

# 3. Greenフェーズ  
Edit: src/domain/entities/StudyLog.ts (エンティティ)
Edit: src/domain/usecases/CreateStudyLog.ts (ユースケース)
Edit: src/infrastructure/web/routes/study.ts (API)

# 4. Refactorフェーズ
Edit: エラーハンドリング追加
Edit: 型安全性向上
Edit: 命名改善

# 5. フロントエンド統合
Edit: src/lib/api.ts (APIクライアント)
Edit: src/components/StudyLogForm.tsx (UI)
```

### 🎯 TDD vs 従来開発の使い分け

#### TDD推奨ケース

- ✅ **新機能開発**: 仕様が明確な機能
- ✅ **重要機能**: 品質が特に重要な機能
- ✅ **複雑ロジック**: バグリスクが高い機能
- ✅ **API設計**: 外部インターフェース

#### 従来開発推奨ケース

- ✅ **UI調整**: 見た目・レイアウト変更
- ✅ **設定変更**: 環境設定・デプロイ設定
- ✅ **実験的実装**: プロトタイプ・概念検証
- ✅ **緊急修正**: 即座の対応が必要

### 🚀 効率的TDD実行順序 (Claude Code)

#### 基本コマンドシーケンス

```bash
# 1. Todo設定 → 2. Test → 3. Code → 4. Verify のサイクル

# Phase 1: TDD準備
TodoWrite: TDD計画設定
Read: 関連する既存コード確認  
Glob: 既存テストファイル確認

# Phase 2: Red (失敗テスト)
Write: テストファイル作成
Bash: npm test (失敗確認)
TodoWrite: Red完了マーク

# Phase 3: Green (最小実装)  
Write/Edit: 実装ファイル作成
Bash: npm test (成功確認)
TodoWrite: Green完了マーク

# Phase 4: Refactor (品質向上)
Edit: コード改善
Bash: npm test && npm run lint
TodoWrite: Refactor完了マーク

# Phase 5: 統合・確認
Bash: 手動動作テスト
TodoWrite: 全体完了マーク
```

### 🔧 TDD問題対処法

#### よくある問題と対処

**Red段階で詰まった場合:**

```bash
# 1. 仕様を再確認
Read: docs/specifications/requirements.md

# 2. 既存コードを参考
Grep: 類似機能検索
Read: 既存実装確認

# 3. 段階的に細分化
TodoWrite: より小さな単位に分割
```

**Green段階で詰まった場合:**

```bash
# 1. 最小実装に戻る
# → 仮実装・ダミーデータでも良い

# 2. 依存関係を確認
Read: 関連ファイル確認
Bash: 型エラー・ビルドエラー確認

# 3. 段階的実装
# → 一つずつテストを通す
```

### 🛠️ 機能開発フロー (従来)

#### Step 1: 設計・計画 (5分)

1. **マイルストーン確認**: `docs/specifications/milestones.md` で現在のタスク確認
2. **要件確認**: `docs/specifications/requirements.md` で仕様確認
3. **アーキテクチャ確認**: クリーンアーキテクチャに従った設計

#### Step 2: バックエンド実装 (20-30分)

```bash
cd ap-study-backend

# 2.1 ドメイン層実装
# src/domain/entities/ - エンティティ
# src/domain/repositories/ - リポジトリI/F
# src/domain/usecases/ - ユースケース

# 2.2 インフラ層実装  
# src/infrastructure/database/ - Prisma実装
# src/infrastructure/web/ - API実装

# 2.3 動作確認
npm run dev
curl http://localhost:8000/api/test-endpoint
```

#### Step 3: フロントエンド実装 (20-30分)

```bash
cd ap-study-app

# 3.1 API クライアント更新
# src/lib/api.ts - HTTP クライアント

# 3.2 コンポーネント実装
# src/components/ - UI コンポーネント
# src/app/ - ページコンポーネント

# 3.3 動作確認
npm run dev
# http://localhost:3000 でUI確認
```

#### Step 4: 品質チェック (5-10分)

```bash
# 4.1 Lint チェック
cd ap-study-app && npm run lint
cd ../ap-study-backend && npm run build

# 4.2 型チェック
# TypeScript エラーがないことを確認

# 4.3 動作テスト
# 基本的なCRUD操作を手動テスト
```

#### Step 5: コミット・文書更新 (5分)

```bash
# 5.1 変更をコミット
git add .
git commit -m "feat: implement [機能名]

- Add [具体的な変更内容]
- Update [更新内容]"

# 5.2 マイルストーン進捗更新
# docs/specifications/milestones.md の該当タスクを完了に更新
```

## 🏗️ クリーンアーキテクチャ実装パターン

### バックエンド実装順序

1. **エンティティ作成** (`src/domain/entities/`)
2. **リポジトリI/F定義** (`src/domain/repositories/`)
3. **ユースケース実装** (`src/domain/usecases/`)
4. **Prisma実装** (`src/infrastructure/database/`)
5. **API実装** (`src/infrastructure/web/routes/`)

### フロントエンド実装パターン

1. **API クライアント更新** (`src/lib/api.ts`)
2. **コンポーネント実装** (`src/components/`)

## 🔍 品質管理・チェックポイント

### 必須チェック項目

#### コードの品質

- [ ] **TypeScript エラーなし**: 型安全性確保
- [ ] **ESLint警告なし**: コード品質維持
- [ ] **命名規則統一**: 英語での適切な命名
- [ ] **コメント**: 複雑なロジックのみ最小限

#### 機能の品質

- [ ] **API動作確認**: 全エンドポイントのテスト
- [ ] **UI動作確認**: 基本的なユーザー操作
- [ ] **エラーハンドリング**: 適切なエラー表示
- [ ] **ローディング状態**: UX向上のための待機表示

#### アーキテクチャの品質

- [ ] **層の分離**: 適切な責務分離
- [ ] **依存性注入**: インターフェースの活用
- [ ] **単一責任**: 各クラス・関数の役割明確化

### パフォーマンスチェック

```bash
# バンドルサイズ確認
cd ap-study-app
npm run build
# .next/static の出力サイズを確認

# API レスポンス確認
time curl http://localhost:8000/api/study/plan
# 200ms以内を目標
```

## 🚨 トラブルシューティング

### よくある問題と対処法

#### 1. CORS エラー

```bash
# 原因: オリジン設定の問題
# 対処: ap-study-backend/src/app.ts のCORS設定確認
```

#### 2. TypeScript エラー

```bash
# 原因: 型定義の不整合
# 対処: 
npm install @types/node@^22.11.0
npm run build
```

#### 3. Prisma接続エラー

```bash
# 原因: データベース設定の問題
# 対処:
cd ap-study-backend
npm run db:generate  
npm run db:push
```

#### 4. Docker起動失敗

```bash
# 原因: ポート競合・キャッシュ問題
# 対処:
docker compose down
docker system prune -f
docker compose up --build
```

## 📊 進捗管理

### 日次確認項目

- [ ] 本日完了予定タスクの進捗
- [ ] 次回作業内容の明確化
- [ ] 技術的課題の洗い出し

## 🎯 パフォーマンス目標

- **初期表示**: 1秒以内
- **API応答**: 200ms以内
- **ビルド時間**: 30秒以内

---

**💡 効率的な開発を心がけ、品質と速度のバランスを保ちながら進めてください。**
