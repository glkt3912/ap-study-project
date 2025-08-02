# 🎓 AP Study Project

応用情報技術者試験対策のための**高品質・型安全**学習管理アプリケーション

## ✨ 主要機能

### 🎯 学習管理機能
- **12週間体系的学習プラン** - 段階的な学習スケジュール
- **リアルタイム進捗トラッキング** - 学習時間・理解度の可視化
- **午前・午後問題演習記録** - 詳細な成績分析
- **ダークモード対応** - 快適な学習環境

### 🧪 開発者機能
- **診断インフラ** - CSS/API/環境の包括的テスト
- **データエクスポート** - JSON/CSV形式での詳細データ出力
- **厳格な型安全性** - TypeScript strict mode + ESLint
- **品質保証** - 自動テスト・lint・ビルド検証

## 📁 プロジェクト構成

```
ap-study-project/
├── ap-study-app/                    # Next.js 15 フロントエンド
│   ├── src/
│   │   ├── app/                     # App Router (診断ページ含む)
│   │   │   ├── debug/               # 🧪 総合診断ページ
│   │   │   ├── css-test/            # 🎨 CSS専用テストページ
│   │   │   ├── env-check/           # 🖥️ 環境チェックページ
│   │   │   └── api-test/            # 🔌 API接続テストページ
│   │   ├── components/              # React コンポーネント
│   │   │   ├── DataExport.tsx       # 💾 データエクスポート機能
│   │   │   ├── DiagnosticHub.tsx    # 🧪 診断ハブ
│   │   │   └── ui/                  # UI コンポーネント
│   │   ├── contexts/                # React Context (テーマ管理)
│   │   ├── data/                    # 初期データ・型定義
│   │   └── lib/                     # API クライアント
│   ├── .eslintrc.json               # 厳格なlintルール
│   ├── tsconfig.json                # 厳格なTypeScript設定
│   └── Dockerfile
├── ap-study-backend/                # Hono.js バックエンド API
│   ├── src/
│   │   ├── domain/                  # ドメインロジック
│   │   ├── infrastructure/          # インフラ層（DB、Web）
│   │   └── seed.ts                  # 初期データ投入
│   ├── Dockerfile
│   └── docker-entrypoint.sh         # DB 初期化スクリプト
├── docs-*/                          # プロジェクト文書
│   ├── docs-milestones.md           # 開発マイルストーン
│   ├── docs-development-workflow.md # 開発手順
│   └── docs-commands.md             # コマンド一覧
├── docker-compose.yml               # Docker 環境設定
├── CLAUDE.md                        # 🤖 Claude Code専用設定
└── README.md                        # このファイル
```

## 🚀 クイックスタート（推奨）

重複コンテナを自動停止して開発環境を起動する便利スクリプトを用意しています：

```bash
# プロジェクトディレクトリに移動
cd ap-study-project

# 🐳 Docker環境で起動（推奨）
./dev.sh start docker
# または
npm run dev:docker

# 💻 ローカル環境で起動（高速）
./dev.sh start local  
# または
npm run dev

# 📊 サービス状態確認
./dev.sh status
# または
npm run status

# 🛑 全サービス停止
./dev.sh stop
# または
npm run stop

# 🔄 再起動
./dev.sh restart docker
# または
npm run restart:docker

# 🧹 環境クリーンアップ
./dev.sh clean
# または
npm run clean
```

### 従来のDocker Compose起動

```bash
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

### 📱 メインアプリケーション
- **フロントエンド**: <http://localhost:3000>
- **バックエンド API**: <http://localhost:8000>
- **PostgreSQL**: localhost:5432

### 🧪 診断・テストページ
- **総合診断**: <http://localhost:3000/debug>
- **CSS専用テスト**: <http://localhost:3000/css-test>
- **環境チェック**: <http://localhost:3000/env-check>
- **API接続テスト**: <http://localhost:3000/api-test>

### 🎯 主要機能

#### 学習管理機能
- **📊 ダッシュボード**: 学習進捗の概要・統計表示
- **📅 学習計画**: 12週間の詳細学習スケジュール管理
- **✏️ 学習記録**: 日別学習時間・理解度・メモ記録
- **📝 問題演習**: 午前・午後問題の結果記録・分析
- **🧭 Quiz**: IPA公式過去問による演習システム
- **📈 分析**: 学習パターン分析・成績予測機能
- **💾 エクスポート**: JSON/CSV形式での学習データ出力
- **🌙 ダークモード**: 目に優しい学習環境

#### 開発者機能
- **🧪 診断インフラ**: CSS/JavaScript/API/環境の包括的テスト
- **🎨 型安全性**: 厳格なTypeScript + ESLint設定
- **⚡ パフォーマンス監視**: 読み込み時間・メモリ使用量計測
- **🔧 デバッグ支援**: エラー特定・環境情報の自動収集

## 🛠 技術スタック

### フロントエンド
- **Next.js 15** - React フレームワーク (App Router)
- **React 19** - 最新UI ライブラリ
- **TypeScript 5.8+** - 厳格な型安全性
- **Tailwind CSS 3.4+** - ユーティリティファーストCSS
- **ESLint** - 厳格なコード品質チェック

### バックエンド
- **Hono.js 4.0+** - 軽量・高速 Web フレームワーク
- **TypeScript 5.3+** - 型安全なサーバーサイド
- **Prisma ORM 5.10+** - 型安全なデータベースORM
- **PostgreSQL 15** - 高性能リレーショナルDB
- **Zod 3.22+** - スキーマバリデーション

### 開発・品質保証
- **Docker & Docker Compose** - 一貫した開発環境
- **Node.js 22.17.1 LTS** - 最新安定版
- **厳格TypeScript設定** - strictNullChecks, noImplicitAny
- **包括的診断システム** - 4種類の専用テストページ
- **自動品質チェック** - lint, typecheck, build 自動実行

## 📊 データベース構造

- **study_weeks** - 学習週管理
- **study_days** - 日別学習内容
- **study_logs** - 学習記録
- **morning_tests** - 午前問題記録
- **afternoon_tests** - 午後問題記録

## 🎯 API エンドポイント

### 学習計画管理
- `GET /api/study/plan` - 全学習計画取得
- `GET /api/study/plan/:weekNumber` - 特定週の計画取得  
- `GET /api/study/current-week` - 現在週の取得
- `PUT /api/study/progress` - 学習進捗更新
- `POST /api/study/complete-task` - タスク完了

### 学習記録・テスト
- `GET /api/study/logs` - 学習記録一覧
- `POST /api/study/logs` - 学習記録追加
- `GET /api/tests/morning` - 午前問題記録
- `GET /api/tests/afternoon` - 午後問題記録

### 診断・ヘルスチェック
- `GET /api/health` - システムヘルスチェック
- `GET /api/debug/info` - 環境情報取得

## 📈 品質指標

- **型安全性**: 95% (strict TypeScript + ESLint)
- **テストカバレッジ**: 診断インフラによる包括的チェック
- **パフォーマンス**: 初期表示 <1秒, API応答 <200ms
- **開発効率**: デバッグ時間 80%短縮 (診断ページ活用)

## 🚀 デプロイ & 本番運用

### 推奨デプロイ環境
- **フロントエンド**: Vercel (Next.js最適化)
- **バックエンド**: Railway/Render (Hono.js対応)
- **データベース**: Supabase/Railway PostgreSQL

### 本番環境設定
```bash
# 環境変数設定例
NEXT_PUBLIC_API_URL=https://your-api-domain.com
DATABASE_URL=postgresql://username:password@host:5432/database
NODE_ENV=production
```

### 品質保証コマンド
```bash
# 本番ビルド前チェック
npm run lint      # ESLint厳格チェック
npm run build     # TypeScript型チェック + ビルド
npm run test      # 診断テスト実行
```

