# 🤖 Claude Code 開発設定

## 📋 プロジェクト概要

**応用情報技術者試験 学習管理システム**  

- Next.js 15 + React 19 フロントエンド
- Hono.js + Prisma バックエンドAPI  
- クリーンアーキテクチャ採用
- Node.js 22.17.1 LTS 対応
- Docker環境対応

## 🏗️ プロジェクト構造

**⚠️ 重要: マルチリポジトリ構成**

```
ap-study-project/          # 📁 ルートリポジトリ（このリポジトリ）
├── .gitignore             # ap-study-* を除外設定
├── docs/                  # プロジェクト文書（ルート管理）
│   ├── development/       # 開発ワークフロー・TDD
│   ├── operations/        # CI/CD・運用
│   ├── specifications/    # 要件・仕様・進捗管理
│   └── deployment/        # デプロイ設定
├── scripts/               # 開発支援・過去問データ管理スクリプト
├── exam-data-reports/     # データ分析レポート（自動生成）
└── CLAUDE.md              # このファイル
```

**🔗 別リポジトリ管理 (.gitignoreで除外済み)**

```
ap-study-app/              # 📁 フロントエンドリポジトリ（別管理）
├── src/
│   ├── app/               # Next.js 15 App Router
│   ├── components/        # React 19 コンポーネント
│   ├── data/              # 初期データ・型定義
│   └── lib/               # API クライアント
├── package.json           # engines: node ^22.17.1
└── Dockerfile             # node:22-slim

ap-study-backend/          # 📁 バックエンドリポジトリ（別管理）
├── src/
│   ├── domain/            # ドメイン層（エンティティ、ユースケース）
│   └── infrastructure/    # インフラ層（DB・Web・過去問データ）
│       └── database/seeds/# 🔴 過去問データファイル（別リポジトリ）
├── package.json           # engines: node ^22.17.1
└── Dockerfile             # node:22-slim
```

### 📋 リポジトリ別責任範囲

| リポジトリ | 管理対象 | Claude Codeでの作業範囲 |
|----------|---------|---------------------|
| **ルート** | ドキュメント・スクリプト・設定 | ✅ 全範囲対応 |
| **フロントエンド** | UI・コンポーネント・型定義 | 🔄 別途作業必要 |
| **バックエンド** | API・DB・過去問データ | 🔄 別途作業必要 |

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

**⚠️ 重要: マルチリポジトリ対応**

```typescript
// ルートリポジトリでの完全自動PR開発フロー
TodoWrite: 機能要件明確化
Bash: "./scripts/pr-automation.sh flow [機能名]"       # ブランチ作成→TDD→コミット→レビュー→PR
Edit: ドキュメント・スクリプト実装（ルートリポジトリ範囲）
Bash: "./scripts/pr-automation.sh commit"            # 追加変更のコミット
Bash: "./scripts/pr-automation.sh review"            # 品質チェック
Bash: "./scripts/pr-automation.sh pr"                # PR更新

// フロントエンド・バックエンドは別途作業が必要
// 🔄 ap-study-app/    : 別リポジトリでUI・API連携実装
// 🔄 ap-study-backend/: 別リポジトリでAPI・DB・過去問データ実装
```

**🎯 対応リポジトリ:**
- **ルート** (`/`): ドキュメント・スクリプト・設定管理
- **フロントエンド** (`/ap-study-app`): Next.js + React UI実装
- **バックエンド** (`/ap-study-backend`): Hono.js + Prisma API実装

**🔄 自動ブランチ削除:**
- PRマージ後、リモート・ローカルブランチを自動削除
- `gh pr merge --squash --delete-branch` + ローカルクリーンアップ
- 完全なワークフロー自動化を実現

**🧠 インテリジェント差分分析:**
- **変更検出**: 各リポジトリの変更有無を自動判定
- **コンテキスト分析**: ファイル種別によるCommit Type自動選択
- **スマートメッセージ**: 変更内容に基づくコミットメッセージ自動生成
- **効率化**: 変更のないリポジトリは自動スキップ

```bash
# 差分分析例
# フロントエンド: .tsx/.jsx → "feat(ui): add new components and UI features"
# バックエンド: .ts API → "feat(api): add new API endpoints and services"  
# ルート: scripts → "feat(scripts): enhance development automation"
# ルート: docs → "docs(project): update project documentation"
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

### 🧪 品質チェック・TDD（最適化済み）

```bash
# バックエンド（ap-study-backend）
cd ap-study-backend

# 🧪 TDD開発（推奨・最適化済み）
npm run tdd:test                # テスト実行（詳細出力）
npm run tdd:cycle               # 統合TDDサイクル（テスト→修正→フォーマット→再テスト）

# 🔍 品質チェック（統合版）
npm run quality:all             # 全品質チェック実行
npm run quality:critical        # 重要な品質チェックのみ
npm run quality:security        # セキュリティチェック
npm run quality:api             # APIスキーマ・品質チェック

# 🔧 個別コマンド
npm run lint                    # ESLintチェック
npm run lint:fix               # ESLint自動修正
npm run format                 # Prettier実行
npm run type-check             # TypeScript型チェック
npm run test                   # テスト実行
npm run test:watch             # ウォッチモードテスト
npm run test:ui                # Vitest UIモード

# 📋 個別シードデータ投入
npm run seed:questions         # 過去問データのみ
npm run seed:study-plan        # 学習計画データのみ
```

```bash
# フロントエンド（ap-study-app）
cd ap-study-app
npm run lint && npm run build
```

**💡 最適化のポイント:**
- **34個 → 29個** のスクリプトに整理（約15%削減）
- **重複コマンド削除**: `seed:all`, `pr:check`, `quality:code`
- **TDD簡略化**: 4個のTDDコマンド → 2個に統合
- **品質チェック統合**: `quality:all` でワンストップ実行
- **個別実行可能**: 必要に応じて細かいコマンドも利用可能

## 📚 参考ドキュメント

### 📋 開発管理

- **`docs/development/workflow.md`** - TDD開発手順・ベストプラクティス
- **`docs/development/commands.md`** - よく使うコマンド一覧
- **`docs/development/tdd-commands.md`** - TDD専用コマンドリファレンス
- **`docs/specifications/milestones.md`** - プロジェクト全体のフェーズ管理

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

### Git コミット・PR規約

#### **📝 コミットメッセージ規約**

- **言語**: 英語必須
- **形式**: Conventional Commits完全準拠
- **構造**: `type(scope): description`
  - `feat:` 新機能追加
  - `fix:` バグ修正
  - `docs:` ドキュメント更新
  - `style:` コードスタイル・フォーマット
  - `refactor:` リファクタリング
  - `test:` テスト追加・修正
  - `chore:` 設定・ツール・その他
- **説明**: 動詞原形で開始、簡潔で明確
- **本文**: 必要に応じて詳細説明（英語）

#### **🚫 Claude Code署名除外（重要）**

- **絶対禁止**: `🤖 Generated with [Claude Code]`
- **絶対禁止**: `Co-Authored-By: Claude <noreply@anthropic.com>`
- **理由**: プロジェクト固有のGit履歴ポリシー

#### **📋 PR（Pull Request）規約**

- **PRタイトル**: 日本語ベース・機能名に応じた自然な表現
  - 例：「過去問データ管理システム の開発」
  - 例：「認証機能強化 の実装」
- **PR本文**: 日本語ベース・詳細レビューチェックリスト
  - ## Summary（概要）
  - ## Test plan（テスト計画）  
  - ## Breaking changes（破壊的変更）
  - ## Related issues（関連Issue）

#### **🔀 マージ戦略**

- **Squash and merge**: コミット履歴の整理
- **Linear history**: 直線的な履歴維持
- **Protected branches**: main ブランチ保護

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

### **🔍 ESLint遵守の徹底（最重要）**

Claude Codeは以下のESLint規約を**絶対に遵守**してください：

#### **1. コード作成時の必須チェック**
```typescript
// コード作成・編集の度に以下を自動実行
Edit: コード実装
Bash: "npm run lint"                    # ESLintチェック必須
Bash: "npm run lint -- --fix"          # 自動修正実行
Bash: "npm run build"                  # TypeScript型チェック
```

#### **2. 絶対遵守ルール**
- **`any` 型禁止**: `unknown`、具体的な型定義、またはインターフェースを使用
- **複雑度制限**: 関数の複雑度は最大8 → ヘルパー関数で分割
- **波括弧必須**: `if/else`文は必ず `{}` を使用
- **行長制限**: 120文字以内
- **console禁止**: `console.log()` は使用せず、適切なロギングを実装

#### **3. 型定義パターン（推奨）**
```typescript
// ❌ 禁止パターン
function handleData(data: any) { ... }
const response: any = await fetch(...);

// ✅ 推奨パターン  
interface UserData { id: number; name: string; }
function handleData(data: UserData) { ... }
const response: ApiResponse<UserData> = await fetch(...);
```

#### **4. ESLint違反時の対処**
- **即座に修正**: ESLint違反を検出したら即座に修正
- **ヘルパー関数**: 複雑度違反はヘルパー関数で分割
- **型安全性**: `any`型は具体的な型に置き換え
- **コード品質**: 未使用変数・インポートを削除

### **🔄 PR自動化開発フロー（推奨）**

- **新機能開発時**: PR自動化フローを使用してください
- **完全自動化**: `./scripts/pr-automation.sh flow [機能名]` で一括実行
- **段階的実行**: start → commit → review → pr の各段階で実行可能
- **TDD統合**: TDD初期化も自動実行（--no-tddでスキップ可能）

```bash
# 完全自動PR開発フロー（推奨）
./scripts/pr-automation.sh flow [機能名]              # ブランチ作成→TDD→コミット→レビュー→PR
# 例: ./scripts/pr-automation.sh flow "ユーザー認証機能"
#     → PRタイトル: "ユーザー認証機能 の開発"

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

### **🔍 ESLint コード品質規約（必須遵守）**

#### **TypeScript型安全性ルール**
- **絶対禁止**: `any` 型の使用 → `unknown` または適切な型定義を使用
- **推奨**: インターフェース・型定義の積極的活用
- **禁止**: 非null assertion (`!`) → 適切なnullチェックを実装

#### **関数複雑度制限**
- **最大複雑度**: 8 (cyclomatic complexity)
- **解決法**: ヘルパー関数への分割、単一責任原則の遵守
- **パターン**: switch文、早期return、関数抽出を活用

#### **コードスタイル規約**
- **必須**: すべてのif/else文で波括弧 `{}` を使用
- **行長制限**: 最大120文字
- **禁止**: `console.log()` → 適切なロギング機能を使用
- **必須**: 未使用変数・インポートの削除

#### **コーディング時の自動チェック**
```bash
# コード作成・編集後は必ず実行
npm run lint                    # ESLintチェック
npm run lint -- --fix         # 自動修正可能な問題を修正
npm run build                  # TypeScriptコンパイルチェック
```

### **🎯 効率化の実現**

- **81%短縮**: TDDスクリプトによる大幅な開発時間短縮
- **品質向上**: 自動テスト・型チェック・Lintによる高品質コード
- **継続改善**: 問題発生時は即座にワークフロー・スクリプトを改善

---

## 🤖 Claude Code マルチリポジトリ運用

### **📋 作業管理の責任分離**

**ルートリポジトリ** (`/home/glkt/projects/ap-study-project`):
- 全体戦略・フェーズ管理 (`docs/specifications/milestones.md`)
- 開発ツール・スクリプト管理 (`scripts/`)
- プロジェクト文書・設計書管理 (`docs/`)

**個別リポジトリ** (`ap-study-app/`, `ap-study-backend/`):
- 具体的機能開発・コード変更はPRで管理
- 詳細な進捗・タスク管理はPR・Issue活用
- 技術的実装・テスト・品質管理

### **🔄 統合作業フロー**

1. **全体設計・計画**: ルートリポジトリで文書・方針策定
2. **機能開発**: 個別リポジトリでPR運用による実装
3. **統合・デプロイ**: PR自動化スクリプトによる連携管理

**💡 この分離により、文書と実装の整合性を保ちながら効率的な開発を実現。**
