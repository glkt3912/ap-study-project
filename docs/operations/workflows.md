# 🔄 ワークフロー詳細解説

## 📋 概要

3つのリポジトリに分散配置されたCI/CDワークフローの詳細解説

## 🎨 **フロントエンド ワークフロー** (`ap-study-app/.github/workflows/ci.yml`)

### 🔧 **トリガー条件**

```yaml
on:
  push:
    branches: [main, develop]    # main・developブランチへのpush
  pull_request:
    branches: [main]             # mainブランチへのPR
```

### 🧪 **Job 1: test-and-build**

#### **目的**: フロントエンドの品質保証・ビルド

```yaml
steps:
  1. Checkout code               # ソースコード取得
  2. Setup Node.js 22.17.1      # Node.js環境構築
  3. Install dependencies        # npm ci (package-lock.json厳密)
  4. Run ESLint                  # コード品質チェック
  5. Run tests                   # Vitestテスト実行
  6. Generate test coverage      # カバレッジレポート生成
  7. Upload coverage to Codecov  # カバレッジ可視化
  8. Build application           # Next.js本番ビルド
  9. Upload build artifacts      # ビルド成果物保存(7日間)
```

#### **環境変数**

```yaml
NEXT_PUBLIC_API_URL: https://ap-study-backend.vercel.app
```

#### **成果物**

- ✅ ESLintエラー0件確認
- ✅ テストカバレッジレポート
- ✅ 本番ビルド済み`.next`ディレクトリ

### 🔒 **Job 2: security-scan**

#### **目的**: セキュリティ脆弱性検出

```yaml
steps:
  1. Checkout code               # ソースコード取得
  2. Run Trivy scanner          # ファイルシステム脆弱性スキャン
  3. NPM Audit                  # 依存関係脆弱性チェック
```

#### **チェック項目**

- 既知の脆弱性 (CVE)
- 悪意のあるパッケージ
- 古いバージョンの依存関係
- セキュリティアドバイザリ

### 🚀 **Job 3: deploy-production** (main ブランチのみ)

#### **条件**: `github.ref == 'refs/heads/main'`

```yaml
needs: [test-and-build, security-scan]  # 前段ジョブ成功が必須
steps:
  1. Checkout code               # ソースコード取得
  2. Setup Node.js               # Node.js環境
  3. Install Vercel CLI          # Vercelコマンドライン
  4. Pull Vercel Environment     # 本番環境設定取得
  5. Build Project Artifacts     # Vercel用ビルド
  6. Deploy to Vercel           # 本番デプロイ実行
```

#### **必要なSecrets**

```
VERCEL_TOKEN=xxx               # Vercel認証トークン
```

### 🔍 **Job 4: deploy-preview** (PR のみ)

#### **条件**: `github.event_name == 'pull_request'`

```yaml
steps:
  1-6. (同上)                    # 基本的な流れは本番と同じ
  7. Deploy to Vercel           # プレビューデプロイ
  8. Comment PR with URL        # PRにプレビューURL投稿
```

#### **PR自動コメント例**

```
🚀 **Preview deployed!**

📱 Preview URL: https://ap-study-app-git-feature-username.vercel.app

✅ Build completed successfully.
```

---

## ⚙️ **バックエンド ワークフロー** (`ap-study-backend/.github/workflows/ci.yml`)

### 🔧 **トリガー条件**

```yaml
on:
  push:
    branches: [main, develop]    # main・developブランチへのpush
  pull_request:
    branches: [main]             # mainブランチへのPR
```

### 🧪 **Job 1: test-and-build**

#### **PostgreSQLサービス**

```yaml
services:
  postgres:
    image: postgres:15           # PostgreSQL 15
    env:
      POSTGRES_USER: postgres
      POSTGRES_PASSWORD: password
      POSTGRES_DB: ap_study_test
    options: >-
      --health-cmd pg_isready    # ヘルスチェック
      --health-interval 10s      # 10秒間隔
      --health-timeout 5s        # 5秒タイムアウト
      --health-retries 5         # 5回リトライ
    ports:
      - 5432:5432               # ポート公開
```

#### **ビルド・テスト手順**

```yaml
steps:
  1. Checkout code               # ソースコード取得
  2. Setup Node.js 22.17.1      # Node.js環境構築
  3. Install dependencies        # npm ci
  4. Setup test database         # Prisma DB初期化
     - npm run db:generate       # Prismaクライアント生成
     - npm run db:push          # スキーマ適用
  5. Run TypeScript build       # TypeScriptコンパイル
  6. Run tests                  # テスト実行 (Phase C実装予定)
  7. Upload build artifacts     # dist/ディレクトリ保存
```

#### **データベース接続**

```yaml
env:
  DATABASE_URL: postgresql://postgres:password@localhost:5432/ap_study_test
```

### 🔒 **Job 2: security-scan** (フロントエンドと同じ)

### 🚀 **Job 3: deploy-production** (main ブランチのみ)

#### **Vercel デプロイ**

```yaml
steps:
  1. Checkout code               # ソースコード取得
  2. Install Vercel CLI          # Vercel CLI設定
  3. Deploy to Vercel           # Vercel デプロイ実行
  4. Health check               # デプロイ後ヘルスチェック
```

#### **必要なSecrets**

```
VERCEL_TOKEN=xxx              # Vercel認証トークン
```

### 🔍 **Job 4: deploy-preview** (PR のみ)

#### **PR自動コメント例**

```
🚀 **Backend Preview deployed!**

📡 API URL: https://ap-study-backend-preview.vercel.app
📄 API Docs: https://ap-study-backend-preview.vercel.app/ui

✅ Build completed successfully.
```

---

## 🎯 **統合ワークフロー** (`ap-study-project/.github/workflows/ci.yml`)

### 🔧 **トリガー条件**

```yaml
on:
  workflow_dispatch:            # 手動実行
    inputs:
      deploy_frontend: boolean   # フロントエンドデプロイ選択
      deploy_backend: boolean    # バックエンドデプロイ選択
  
  repository_dispatch:          # 子リポジトリからの通知
    types: [frontend-updated, backend-updated]
```

### 🎛️ **手動実行オプション**

```yaml
inputs:
  deploy_frontend:
    description: 'Deploy frontend'
    type: boolean
    default: false
  deploy_backend:
    description: 'Deploy backend'
    type: boolean
    default: false
```

### 🔄 **Repository Dispatch**

子リポジトリから親リポジトリに通知を送信:

```bash
# 例: フロントエンドから通知
curl -X POST \
  -H "Authorization: token ${{ secrets.GITHUB_TOKEN }}" \
  -H "Accept: application/vnd.github.v3+json" \
  https://api.github.com/repos/glkt3912/ap-study-project/dispatches \
  -d '{"event_type":"frontend-updated"}'
```

---

## 📊 **ワークフロー比較表**

| 項目 | フロントエンド | バックエンド | 統合ハブ |
|------|---------------|-------------|----------|
| **トリガー** | push/PR | push/PR | 手動/通知 |
| **テスト** | Vitest | TypeScript | 統合テスト |
| **ビルド** | Next.js | tsc | - |
| **DB** | なし | PostgreSQL | - |
| **デプロイ** | Vercel | Vercel | 調整のみ |
| **プレビュー** | 自動 | 自動 | - |
| **セキュリティ** | Trivy+Audit | Trivy+Audit | 監視 |

## 🔄 **ワークフロー実行フロー**

### **通常開発フロー**

```mermaid
graph TD
    A[開発者がコード変更] --> B{どのリポジトリ?}
    B -->|Frontend| C[ap-study-app CI/CD実行]
    B -->|Backend| D[ap-study-backend CI/CD実行]
    C --> E[Vercelプレビューデプロイ]
    D --> F[Vercelプレビューデプロイ]
    E --> G[PRレビュー]
    F --> G
    G --> H[mainマージ]
    H --> I[本番デプロイ自動実行]
```

### **統合テストフロー**

```mermaid
graph TD
    A[統合ワークフロー手動実行] --> B[フロントエンドヘルスチェック]
    B --> C[バックエンドヘルスチェック]
    C --> D[API統合テスト]
    D --> E[結果レポート生成]
```

## 🎯 **実行タイミング**

### **自動実行**

- ✅ コードpush時 (各リポジトリ)
- ✅ PR作成時 (プレビューデプロイ)
- ✅ mainマージ時 (本番デプロイ)

### **手動実行**

- 🔧 統合テスト実行
- 🔧 緊急デプロイ
- 🔧 ヘルスチェック

## 📈 **期待される効果**

### **品質向上**

- ✅ **自動テスト**: 100%カバレッジ測定
- ✅ **セキュリティ**: 脆弱性0件保証
- ✅ **型安全性**: TypeScriptエラー0件

### **開発効率**

- ✅ **自動デプロイ**: 手動作業0分
- ✅ **プレビュー**: PRごとに確認環境
- ✅ **並列開発**: フロント・バック独立

### **運用安定性**

- ✅ **ヘルスチェック**: 自動監視
- ✅ **ロールバック**: 問題時即座復旧
- ✅ **統合監視**: 全体状況把握

---

## 🚀 **次のステップ**

### **各リポジトリでの実行**

```bash
# 1. フロントエンド
cd ap-study-app
git add .github/
git commit -m "feat: Add complete CI/CD pipeline"
git push origin main

# 2. バックエンド
cd ap-study-backend
git add .github/
git commit -m "feat: Add complete CI/CD pipeline"
git push origin main

# 3. Secrets設定 (GitHub UI)
# - VERCEL_TOKEN
# - CODECOV_TOKEN
```

**これで完全なCI/CD環境が稼働開始します。**
