# AP Study Project

応用情報技術者試験対策のための学習管理アプリケーション

## 🚀 特徴

- 12週間の体系的な学習計画管理
- 学習進捗の可視化とトラッキング
- 午前・午後問題の演習記録
- 理解度とメモの記録機能
- PostgreSQL による本格的なデータ管理

## 📁 プロジェクト構成

```
ap-study-project/
├── ap-study-app/                    # Next.js フロントエンド
│   ├── src/
│   │   ├── app/                     # App Router
│   │   ├── components/              # React コンポーネント
│   │   └── lib/                     # API クライアント
│   └── Dockerfile
├── ap-study-backend/                # Hono.js バックエンド API
│   ├── src/
│   │   ├── domain/                  # ドメインロジック
│   │   ├── infrastructure/          # インフラ層（DB、Web）
│   │   └── seed.ts                  # 初期データ投入
│   ├── Dockerfile
│   └── docker-entrypoint.sh         # DB 初期化スクリプト
├── docker-compose.yml               # Docker 環境設定
├── ap-study-plan.md                 # 学習計画書
├── app-requirements.md              # アプリ要件定義
└── README.md                        # このファイル
```

## 🐳 Docker環境での起動（推奨）

```bash
# プロジェクトディレクトリに移動
cd ap-study-project

# 初回起動（ビルド・DB初期化・シード投入）
docker compose up --build

# 通常起動
docker compose up
```

## 🔧 個別起動（開発用）

### 前提条件

- Node.js 22+
- PostgreSQL 15+

### データベース準備

```bash
# PostgreSQL を起動
# データベース 'ap_study' を作成
createdb ap_study
```

### バックエンド

```bash
cd ap-study-backend

# 依存関係インストール
npm install

# 環境変数設定
export DATABASE_URL="postgresql://username:password@localhost:5432/ap_study?schema=public"

# マイグレーション実行
npx prisma migrate deploy --schema=./src/infrastructure/database/prisma/schema.prisma

# シードデータ投入
npx tsx src/seed.ts

# 開発サーバー起動
npm run dev
```

### フロントエンド

```bash
cd ap-study-app

# 依存関係インストール
npm install

# 環境変数設定
export NEXT_PUBLIC_API_URL="http://localhost:8000"

# 開発サーバー起動
npm run dev
```

## 🌐 アクセス URL

- **フロントエンド**: <http://localhost:3000>
- **バックエンド API**: <http://localhost:3001>
- **PostgreSQL**: localhost:5432

## 🛠 技術スタック

### フロントエンド

- **Next.js 15** - React フレームワーク (Node.js 22+ 対応)
- **React 19** - UI ライブラリ
- **TypeScript** - 型安全性
- **Tailwind CSS** - スタイリング

### バックエンド

- **Hono.js** - 軽量 Web フレームワーク (Node.js 22+ 対応)
- **TypeScript** - 型安全性
- **Prisma ORM** - データベース ORM
- **PostgreSQL** - リレーショナルデータベース
- **Zod** - バリデーション

### インフラ

- **Docker & Docker Compose** - コンテナ化
- **PostgreSQL 15** - データベース

## 📊 データベース構造

- **study_weeks** - 学習週管理
- **study_days** - 日別学習内容
- **study_logs** - 学習記録
- **morning_tests** - 午前問題記録
- **afternoon_tests** - 午後問題記録

## 🎯 API エンドポイント

- `GET /api/study/plan` - 全学習計画取得
- `GET /api/study/plan/:weekNumber` - 特定週の計画取得
- `GET /api/study/current-week` - 現在週の取得
- `PUT /api/study/progress` - 学習進捗更新
- `POST /api/study/complete-task` - タスク完了

## 🚀 デプロイ

このプロジェクトは Supabase (PostgreSQL) への本番デプロイを想定して設計されています。

