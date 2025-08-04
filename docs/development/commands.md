# ⚡ プロジェクト コマンドリファレンス

## 🚀 クイックスタート

```bash
# プロジェクト全体を起動
docker compose up --build

# 個別起動（開発用）
cd ap-study-backend && npm run dev
cd ap-study-app && npm run dev
```

---

## 🐳 Docker コマンド

### 基本操作

```bash
# 初回起動（ビルド付き）
docker compose up --build

# 通常起動
docker compose up

# バックグラウンド起動
docker compose up -d

# 停止
docker compose down

# 停止してボリューム削除
docker compose down -v

# ログ確認
docker compose logs
docker compose logs ap-study-backend
docker compose logs ap-study-app

# コンテナ内でコマンド実行
docker compose exec ap-study-backend sh
docker compose exec ap-study-app sh
```

### トラブルシューティング

```bash
# キャッシュクリア
docker system prune -f
docker compose build --no-cache

# 全コンテナ・イメージ削除
docker compose down --rmi all
docker system prune -a -f
```

---

## 🔧 バックエンド (ap-study-backend)

### 開発コマンド

```bash
cd ap-study-backend

# 開発サーバー起動
npm run dev

# プロダクションビルド
npm run build

# プロダクション実行
npm run start

# 型チェック
npx tsc --noEmit
```

### データベース操作

```bash
cd ap-study-backend

# Prisma生成
npm run db:generate
# または
npx prisma generate --schema=./src/infrastructure/database/prisma/schema.prisma

# データベース同期
npm run db:push
# または  
npx prisma db push --schema=./src/infrastructure/database/prisma/schema.prisma

# マイグレーション作成
npm run db:migrate
# または
npx prisma migrate dev --schema=./src/infrastructure/database/prisma/schema.prisma

# Prisma Studio (DB GUI)
npm run db:studio
# または
npx prisma studio --schema=./src/infrastructure/database/prisma/schema.prisma

# データベースリセット
npx prisma migrate reset --schema=./src/infrastructure/database/prisma/schema.prisma

# シードデータ投入
npx tsx src/seed.ts
```

### API テスト

```bash
# ヘルスチェック
curl http://localhost:8000/

# 学習計画取得
curl http://localhost:8000/api/study/plan

# 特定週の取得
curl http://localhost:8000/api/study/plan/1

# 進捗更新（POST）
curl -X PUT http://localhost:8000/api/study/progress \
  -H "Content-Type: application/json" \
  -d '{"weekNumber": 1, "dayIndex": 0, "completed": true}'
```

---

## 🎨 フロントエンド (ap-study-app)

### 開発コマンド

```bash
cd ap-study-app

# 開発サーバー起動
npm run dev

# プロダクションビルド
npm run build

# プロダクション実行  
npm run start

# 静的エクスポート
npm run build && npm run export

# Lint実行
npm run lint

# Lint修正
npm run lint -- --fix
```

### Next.js 特有

```bash
cd ap-study-app

# キャッシュクリア
rm -rf .next

# 型チェック
npx tsc --noEmit

# バンドル分析
ANALYZE=true npm run build
```

### 型定義生成 (重要)

```bash
cd ap-study-app

# OpenAPI仕様書から自動型生成（推奨）
npm run generate-types

# 環境変数でバックエンドURL指定
BACKEND_URL=http://localhost:8000 npm run generate-types

# フォールバック動作テスト
BACKEND_URL=http://invalid-url npm run generate-types

# 生成された型ファイル確認
cat src/types/api.ts
```

---

## 📦 パッケージ管理

### 依存関係更新

```bash
# バックエンド
cd ap-study-backend
npm install
npm audit fix

# フロントエンド  
cd ap-study-app
npm install
npm audit fix
```

### よく使うパッケージ追加

```bash
# バックエンド
cd ap-study-backend
npm install zod @hono/zod-validator
npm install -D @types/node tsx

# フロントエンド
cd ap-study-app  
npm install react-hook-form chart.js
npm install -D @types/react @types/react-dom
```

---

## 🧪 テスト・品質チェック

### TDD開発 (推奨)

```bash
# TDD初期化 + 実装生成
./scripts/tdd-helper.sh init StudyLogCreation
./scripts/tdd-helper.sh generate StudyLogCreation

# TDD Red-Green-Refactorサイクル
./scripts/tdd-helper.sh red       # Red: 失敗テスト実行
./scripts/tdd-helper.sh green     # Green: 最小実装確認
./scripts/tdd-helper.sh refactor  # Refactor: 品質向上

# TDD完全サイクル (一括実行)
./scripts/tdd-helper.sh cycle

# 現在のTDD状況確認
./scripts/tdd-helper.sh status
```

---

## 📊 進捗管理 (自動化)

### 基本進捗記録

```bash
# タスク完了記録 (TodoWrite使用後必須)
./scripts/progress-manager.sh task-complete "具体的なタスク内容"

# 新機能開発開始
./scripts/progress-manager.sh feature-start "機能名"

# マイルストーン更新
./scripts/progress-manager.sh milestone-update "Milestone 3" "in-progress"
./scripts/progress-manager.sh milestone-update "Milestone 3" "completed"
```

### サマリー生成

```bash
# 日次開発サマリー
./scripts/progress-manager.sh daily-summary

# 週次開発サマリー  
./scripts/progress-manager.sh week-summary

# 進捗管理システム状況確認
./scripts/progress-manager.sh status
```

### NPMスクリプトTDD

```bash
cd ap-study-backend

# 個別フェーズ実行
npm run tdd:red      # Red Phase
npm run tdd:green    # Green Phase  
npm run tdd:refactor # Refactor Phase
npm run tdd:cycle    # Full Cycle
```

### 品質チェック一括実行

```bash
# バックエンド品質チェック
cd ap-study-backend
npm run build
npx tsc --noEmit

# フロントエンド品質チェック  
cd ap-study-app
npm run generate-types  # 型生成を最初に実行
npm run lint
npm run build
npx tsc --noEmit
```

### パフォーマンステスト

```bash
# API レスポンス時間
time curl http://localhost:8000/api/study/plan

# ビルド時間測定
cd ap-study-app
time npm run build

# バンドルサイズ確認
cd ap-study-app
npm run build
du -sh .next/static/chunks/*
```

---

## 🔍 デバッグ・ログ確認

### ログ確認

```bash
# Docker環境のログ
docker compose logs -f ap-study-backend
docker compose logs -f ap-study-app

# 個別開発時のログ
cd ap-study-backend && npm run dev
cd ap-study-app && npm run dev
```

### プロセス確認

```bash
# ポート使用状況確認
lsof -i :3000  # フロントエンド
lsof -i :8000  # バックエンド  
lsof -i :5432  # PostgreSQL

# プロセス終了
pkill -f "next"
pkill -f "tsx"
```

---

## 📁 ファイル・ディレクトリ操作

### よく使うファイル確認

```bash
# 設定ファイル確認
cat package.json
cat tsconfig.json  
cat docker-compose.yml
cat .env

# ログファイル確認
tail -f ap-study-backend/logs/app.log
tail -f /var/log/nginx/error.log
```

### プロジェクト構造確認

```bash
# 主要ディレクトリ構造
tree -I "node_modules|.next|dist" -L 3

# TypeScriptファイル一覧
find . -name "*.ts" -o -name "*.tsx" | grep -v node_modules | head -20

# 重要な設定ファイル確認
ls -la */package.json
ls -la */tsconfig.json
ls -la */Dockerfile
```

---

## 🌐 本番デプロイ関連

### Vercel デプロイ

```bash
cd ap-study-app

# Vercel CLI インストール
npm install -g vercel

# ログイン
vercel login

# デプロイ
vercel

# 本番デプロイ
vercel --prod
```

### 環境変数設定

```bash
# 開発環境
cp .env.example .env
vim .env

# 環境変数確認
cd ap-study-backend && node -e "console.log(process.env)"
cd ap-study-app && node -e "console.log(process.env)"
```

---

## 🚨 緊急時対応

### サービス復旧

```bash
# 全サービス停止・再起動
docker compose down
docker compose up --build

# 個別サービス再起動
docker compose restart ap-study-backend
docker compose restart ap-study-app
```

### データベース復旧

```bash
cd ap-study-backend

# マイグレーション再実行
npm run db:generate
npm run db:push

# データベースリセット（注意：データ消失）
npx prisma migrate reset --schema=./src/infrastructure/database/prisma/schema.prisma
```

### キャッシュクリア

```bash
# Next.js キャッシュ
cd ap-study-app && rm -rf .next

# npm キャッシュ
npm cache clean --force

# Docker キャッシュ
docker system prune -f
```

---

**⚡ よく使用するコマンドは上記を参考に効率的な開発を進めてください。**
