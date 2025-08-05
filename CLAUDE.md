# 🤖 Claude Code 開発設定

## 📋 プロジェクト概要

**応用情報技術者試験 学習管理システム**  

- Next.js 15 + React 19 フロントエンド
- Hono.js + Prisma バックエンドAPI  
- クリーンアーキテクチャ採用
- Node.js 22.17.1 LTS 対応
- Docker環境対応

## 🏗️ プロジェクト構造

```
ap-study-project/
├── ap-study-app/          # Next.js フロントエンド
│   ├── src/
│   │   ├── app/           # App Router
│   │   ├── components/    # React コンポーネント
│   │   ├── data/          # 初期データ・型定義
│   │   └── lib/           # API クライアント
│   ├── package.json       # engines: node ^22.17.1
│   └── Dockerfile         # node:22-slim
├── ap-study-backend/      # Hono.js バックエンド
│   ├── src/
│   │   ├── domain/        # ドメイン層（エンティティ、ユースケース）
│   │   └── infrastructure/# インフラ層（DB、Web）
│   ├── package.json       # engines: node ^22.17.1
│   └── Dockerfile         # node:22-slim
├── docs/                 # プロジェクト文書（整理済み）
│   ├── development/      # 開発ワークフロー・TDD
│   ├── operations/       # CI/CD・運用
│   ├── specifications/   # 要件・仕様
│   └── deployment/       # デプロイ設定
└── scripts/              # TDD・開発支援スクリプト
```

## 🧪 TDD開発ワークフロー（推奨）

### **新機能開発時の基本フロー**

```bash
# 1. TDD初期化・実装自動生成
./scripts/tdd-helper.sh init [機能名]
./scripts/tdd-helper.sh generate [機能名]

# 2. TDD Red-Green-Refactorサイクル
./scripts/tdd-helper.sh red       # Red: 失敗テスト実行
./scripts/tdd-helper.sh green     # Green: 最小実装確認  
./scripts/tdd-helper.sh refactor  # Refactor: 品質向上

# 3. TDD状況確認
./scripts/tdd-helper.sh status
```

### **Claude Code PR自動化統合（推奨）**

```typescript
// 完全自動PR開発フロー
TodoWrite: 機能要件明確化
Bash: "./scripts/pr-automation.sh flow [機能名]"       # ブランチ作成→TDD→コミット→レビュー→PR
Edit: 詳細ビジネスロジック実装（ブランチ上で作業）
Bash: "./scripts/pr-automation.sh commit"            # 追加変更のコミット
Bash: "./scripts/pr-automation.sh review"            # 品質チェック
Bash: "./scripts/pr-automation.sh pr"                # PR更新
```

### **Claude Code TDD統合（従来）**

```typescript
// TDD開発フロー
TodoWrite: TDD計画設定
Bash: "./scripts/tdd-helper.sh init [機能名]"
Bash: "./scripts/tdd-helper.sh generate [機能名]"
Edit: 具体的ビジネスロジック実装
Bash: "./scripts/tdd-helper.sh cycle"
```

## ⚙️ 開発コマンド

### 🚀 起動コマンド

**Docker環境（推奨）:**

```bash
# 初回起動
docker compose up --build

# 通常起動
docker compose up
```

**個別起動:**

```bash
# バックエンド
cd ap-study-backend
npm run dev

# フロントエンド
cd ap-study-app  
npm run dev
```

### 🔧 データベース操作

```bash
cd ap-study-backend

# Prisma生成
npm run db:generate

# マイグレーション
npm run db:migrate

# データベース同期
npm run db:push

# Prisma Studio
npm run db:studio

# シードデータ投入
npm run seed

# 問題データID重複修正（必要時）
node ../scripts/fix-question-ids.cjs        # 全年度修正
node ../scripts/fix-question-ids.cjs 2025   # 特定年度のみ修正
```

### 🔧 型定義生成

```bash
cd ap-study-app

# OpenAPI仕様書から型生成（推奨）
npm run generate-types

# 環境変数でバックエンドURL指定
BACKEND_URL=http://localhost:8000 npm run generate-types

# フォールバック動作確認
BACKEND_URL=http://invalid-url npm run generate-types
```

### 🧪 品質チェック・TDD

```bash
# TDD開発（推奨）
./scripts/tdd-helper.sh cycle    # Red-Green-Refactor自動実行
npm run tdd:green               # 個別フェーズ実行

# 従来の品質チェック
cd ap-study-app && npm run lint && npm run build
cd ap-study-backend && npm run build
```

## 📚 参考ドキュメント

### 📋 開発管理

- **`docs/development/workflow.md`** - TDD開発手順・ベストプラクティス
- **`docs/development/commands.md`** - よく使うコマンド一覧
- **`docs/development/tdd-commands.md`** - TDD専用コマンドリファレンス
- **`docs/specifications/milestones.md`** - 重要な節目・達成目標
- **`docs/specifications/tasks.md`** - 日次・週次タスク管理
- **`docs/specifications/development-log.md`** - 詳細な開発進捗記録

### 📖 プロジェクト仕様

- **`docs/specifications/requirements.md`** - アプリ要件定義
- **`docs/specifications/study-plan.md`** - 学習計画詳細
- **`docs/deployment/vercel-guide.md`** - デプロイ手順

## 📊 現在のマイルストーン

### 🎯 マイルストーン 1: 基盤機能の完成（進行中）

- [x] OpenAPI型生成システム実装（完了）
- [ ] データベース初期化・マイグレーション実行
- [ ] API-Frontend連携実装
- [ ] 基本UI改善（ローディング、エラーハンドリング）
- [ ] レスポンシブデザイン調整

**詳細**: `docs-milestones.md` 参照

### 📋 次のマイルストーン

- **マイルストーン 2**: 学習記録機能の充実
- **マイルストーン 3**: 分析・予測機能
- **マイルストーン 4**: UX/パフォーマンス最適化

## 🎨 技術スタック・制約

### フロントエンド

- **Next.js 15** (App Router)
- **React 19**
- **TypeScript 5.8+**
- **Tailwind CSS 4.1+**

### バックエンド

- **Hono.js 4.0+** (軽量Webフレームワーク)
- **Prisma ORM 5.10+** (データベースORM)
- **Zod 3.22+** (バリデーション)
- **TypeScript 5.3+**

### インフラ

- **Node.js 22.17.1** (LTS)
- **Docker & Docker Compose**
- **PostgreSQL 15** (本番) / SQLite (開発)

### 開発支援・品質管理

- **OpenAPI型生成** (自動TypeScript型定義生成)
- **Vitest** (テストフレームワーク)
- **TDD Helper Scripts** (自動コード生成)
- **ESLint + Prettier** (コード品質)
- **GitHub Actions** (CI/CD)

## 🔄 開発フロー

### **TDD機能追加時（推奨）**

```bash
# 1. TDD初期化・実装生成
TodoWrite: 機能要件明確化
Bash: "./scripts/tdd-helper.sh init [機能名]"
Bash: "./scripts/tdd-helper.sh generate [機能名]"

# 2. 詳細実装
Edit: 具体的ビジネスロジック実装
Edit: テスト詳細化

# 3. TDDサイクル実行・品質確保
Bash: "./scripts/tdd-helper.sh cycle"
TodoWrite: 進捗更新
```

### **従来の機能追加時**

1. **仕様確認** - `docs/specifications/requirements.md` 参照
2. **設計検討** - クリーンアーキテクチャに従う
3. **バックエンド実装** - ドメイン → インフラ層
4. **フロントエンド実装** - コンポーネント → API連携
5. **テスト・品質チェック** - lint, build, 動作確認

### ディレクトリ命名規則

- **docs/**: 文書ファイル（整理済み）
- **ap-study-***: プロダクトディレクトリ
- **scripts/**: TDD・開発支援スクリプト

## 🚨 重要な制約・注意事項

### Git コミット規約

- **IMPORTANT**: コミットメッセージにClaude Code署名を含めない
- 🤖 Generated with [Claude Code] および Co-Authored-By: Claude は除外する
- Conventional Commits形式を使用（feat:, fix:, docs:など）

### セキュリティ

- 機密情報は `.env` で管理
- 本番環境では環境変数設定必須
- CORS設定は開発/本番で切り替え

### パフォーマンス

- バンドルサイズ最適化が必要
- API レスポンス最適化が必要
- 画像最適化が必要

### 開発効率

- **Claude Code 専用**: このファイルで効率的な開発を支援
- **段階的実装**: マイルストーン順に機能追加
- **品質重視**: 各段階で lint/build チェック必須

## 🔍 デバッグ・トラブルシューティング

### よくある問題

- **CORS エラー**: `ap-study-backend/src/app.ts` のCORS設定確認
- **型エラー**: TypeScript 5.8+ と React 19 の互換性確認
- **ビルドエラー**: Node.js 22.17.1 使用確認
- **シードデータエラー**: 問題データID重複時は `fix-question-ids.cjs` 実行

### 🛠️ データベース関連のトラブル解決

```bash
# PostgreSQL起動確認
docker compose up postgres -d

# シードデータ投入エラー時の対処手順
cd ap-study-backend
npm run build                                # TypeScript コンパイル
docker compose up postgres -d               # PostgreSQL 起動
node ../scripts/fix-question-ids.cjs        # ID重複修正
npm run seed                                # シードデータ再投入
```

### ログ確認

```bash
# バックエンドログ
docker compose logs ap-study-backend

# フロントエンドログ  
docker compose logs ap-study-app
```

## 📈 パフォーマンス目標

- **初期表示**: 1秒以内
- **API応答**: 200ms以内
- **ビルド時間**: 30秒以内
- **バンドルサイズ**: 500KB以内

---

**💡 Claude Code への指示**:

### **🔄 PR自動化開発フロー（推奨）**

- **新機能開発時**: PR自動化フローを使用してください
- **完全自動化**: `./scripts/pr-automation.sh flow [機能名]` で一括実行
- **段階的実行**: start → commit → review → pr の各段階で実行可能
- **TDD統合**: TDD初期化も自動実行（--no-tddでスキップ可能）

```bash
# 完全自動PR開発フロー（推奨）
./scripts/pr-automation.sh flow [機能名]              # ブランチ作成→TDD→コミット→レビュー→PR

# 段階的PR開発フロー  
./scripts/pr-automation.sh start [機能名]             # ブランチ作成・TDD初期化
./scripts/pr-automation.sh commit "コミットメッセージ"   # 自動コミット
./scripts/pr-automation.sh review                    # 自己レビュー・品質チェック
./scripts/pr-automation.sh pr [--draft]              # PR作成
./scripts/pr-automation.sh merge                     # PR承認・マージ
./scripts/pr-automation.sh cleanup                   # ブランチクリーンアップ

# 状況確認
./scripts/pr-automation.sh status                    # 開発状況確認
```

### **🧪 TDD優先開発（従来）**

- **新機能開発時**: 必ずTDDワークフローを使用してください
- **コード生成**: `./scripts/tdd-helper.sh generate [機能名]` で自動実装
- **品質確保**: `./scripts/tdd-helper.sh cycle` でRed-Green-Refactor実行

### **📋 進捗管理自動化**

- **TodoWrite活用**: 各TDDフェーズで進捗を明確に管理
- **自動進捗更新**: `./scripts/progress-manager.sh` で自動記録
- **段階的実装**: マイルストーン順に実装し、各段階で動作確認必須
- **3層管理**: milestones.md (節目) / tasks.md (日次) / development-log.md (詳細)

```bash
# タスク完了時（必須実行）
./scripts/progress-manager.sh task-complete "具体的なタスク内容"

# 新機能開発開始時  
./scripts/progress-manager.sh feature-start "機能名"

# マイルストーン更新時
./scripts/progress-manager.sh milestone-update "Milestone名" "planning|in-progress|completed"

# 日次・週次サマリー生成
./scripts/progress-manager.sh daily-summary
./scripts/progress-manager.sh week-summary
```

### **⚠️ 重要な制約**

- **gitコミット**: 署名を含めず、Conventional Commits形式を厳守
- **TDD vs 従来**: 重要機能はTDD、UI調整は従来開発を選択
- **自動化活用**: 手動作業を最小限にし、スクリプトによる効率化を重視

### **🎯 効率化の実現**

- **81%短縮**: TDDスクリプトによる大幅な開発時間短縮
- **品質向上**: 自動テスト・型チェック・Lintによる高品質コード
- **継続改善**: 問題発生時は即座にワークフロー・スクリプトを改善

---

## 🤖 Claude Code自動進捗管理

### **必須動作**

Claude Codeは開発作業の各段階で、以下を**自動実行**してください：

#### **1. TodoWrite使用後（必須）**
```bash
# TodoWriteでタスクを完了マーク後、必ず実行
Bash: "./scripts/progress-manager.sh task-complete '[完了したタスクの具体的内容]'"
```

#### **2. 新機能開発開始時（必須）**
```bash
# 新機能開発開始時、必ず実行
Bash: "./scripts/progress-manager.sh feature-start '[機能名]'"
TodoWrite: 生成されたTDDタスクを活用
```

#### **3. マイルストーン達成時（必須）**
```bash
# マイルストーン状況変更時、必ず実行
Bash: "./scripts/progress-manager.sh milestone-update '[Milestone名]' '[planning|in-progress|completed]'"
```

### **推奨動作**

作業日の終わりや重要な節目で実行を検討：

```bash
# 日次サマリー（推奨）
Bash: "./scripts/progress-manager.sh daily-summary"

# 週次サマリー（推奨）  
Bash: "./scripts/progress-manager.sh week-summary"
```

### **進捗管理フロー統合**

1. **TDD開発フロー**:
   - feature-start → generate → red → green → refactor → task-complete
   
2. **従来開発フロー**:
   - TodoWrite（タスク追加） → 実装 → task-complete

3. **マイルストーン管理**:
   - milestone-update（開始時） → 継続開発 → milestone-update（完了時）

**💡 このシステムにより、開発進捗が自動的に文書化され、継続的な改善とプロジェクト管理が実現されます。**
