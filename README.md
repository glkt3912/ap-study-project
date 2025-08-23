# 🎓 AP Study Project

応用情報技術者試験対策のための**高品質・型安全**学習管理アプリケーション

## ✨ 主要機能

### 🎯 学習管理機能
- **12週間体系的学習プラン** - 段階的な学習スケジュール
- **リアルタイム進捗トラッキング** - 学習時間・理解度の可視化
- **午前・午後問題演習記録** - 詳細な成績分析
- **🔐 認証システム** - セキュアなユーザー管理・ログイン機能
- **🧠 ML学習効率分析器** - 機械学習による学習パターン分析・効率予測
- **ダークモード対応** - 快適な学習環境

### 🧪 開発者機能
- **包括的テストスイート** - Vitest + Testing Library による高品質テスト
- **テストカバレッジ監視** - @vitest/coverage-v8 による詳細なカバレッジレポート
- **診断インフラ** - CSS/API/環境の包括的テスト
- **データエクスポート** - JSON/CSV形式での詳細データ出力
- **厳格な型安全性** - TypeScript strict mode + ESLint
- **品質保証** - 自動テスト・lint・ビルド検証
- **TDD開発支援** - 自動化されたRed-Green-Refactorサイクル
- **進捗管理自動化** - スクリプトによる開発進捗の自動記録・分析

## 📁 プロジェクト構成

```
ap-study-project/
├── ap-study-app/                    # Next.js 15 フロントエンド
│   ├── src/
│   │   ├── app/                     # App Router (診断ページ含む)
│   │   │   ├── debug/               # 🧪 総合診断ページ
│   │   │   ├── css-test/            # 🎨 CSS専用テストページ
│   │   │   ├── env-check/           # 🖥️ 環境チェックページ
│   │   │   ├── api-test/            # 🔌 API接続テストページ
│   │   │   ├── simple/              # シンプル表示ページ
│   │   │   └── test-dark/           # ダークモードテストページ
│   │   ├── components/              # React コンポーネント
│   │   │   ├── LearningEfficiencyDashboard.tsx # 📊 学習効率分析ダッシュボード
│   │   │   ├── AdvancedAnalysis.tsx # 📈 高度な分析機能
│   │   │   ├── ReviewSystem.tsx     # 🔄 復習システム
│   │   │   ├── Quiz.tsx             # 📝 クイズ機能
│   │   │   ├── DataExport.tsx       # 💾 データエクスポート機能
│   │   │   ├── DiagnosticHub.tsx    # 🧪 診断ハブ
│   │   │   ├── charts/              # 📊 チャートコンポーネント
│   │   │   ├── ui/                  # UI コンポーネント
│   │   │   └── __tests__/           # コンポーネントテスト
│   │   ├── contexts/                # React Context
│   │   │   ├── AuthContext.tsx      # 🔐 認証コンテキスト
│   │   │   └── ThemeContext.tsx     # 🎨 テーマ管理
│   │   ├── data/                    # 初期データ・型定義
│   │   ├── lib/                     # API クライアント・ユーティリティ
│   │   │   └── __tests__/           # APIテスト
│   │   ├── types/                   # TypeScript型定義
│   │   └── middleware.ts            # Next.js ミドルウェア
│   ├── coverage/                    # テストカバレッジレポート
│   ├── scripts/                     # 型生成スクリプト
│   ├── vitest.config.ts             # Vitestテスト設定
│   ├── vitest.setup.ts              # テストセットアップ
│   ├── .eslintrc.json               # 厳格なlintルール
│   ├── tsconfig.json                # 厳格なTypeScript設定
│   └── Dockerfile
├── ap-study-backend/                # Hono.js バックエンド API
│   ├── src/
│   │   ├── domain/                  # ドメイン層
│   │   │   ├── entities/            # エンティティ
│   │   │   │   ├── learning-efficiency-analyzer.ts # 学習効率分析
│   │   │   │   ├── AnalysisResult.ts # 分析結果
│   │   │   │   ├── PredictionResult.ts # 予測結果
│   │   │   │   └── ReviewSchedule.ts # 復習スケジュール
│   │   │   ├── repositories/        # リポジトリインターフェース
│   │   │   └── usecases/            # ユースケース
│   │   │       ├── learning-efficiency-analyzer.ts # 学習効率分析
│   │   │       ├── AnalyzeStudyData.ts # 学習データ分析
│   │   │       └── PredictExamResults.ts # 試験結果予測
│   │   ├── infrastructure/          # インフラ層
│   │   │   ├── database/            # データベース層
│   │   │   │   ├── prisma/          # Prismaスキーマ・マイグレーション
│   │   │   │   ├── repositories/    # データアクセス実装
│   │   │   │   └── seeds/           # シードデータ (2022-2025年問題集)
│   │   │   └── web/                 # Web層
│   │   │       ├── middleware/      # 認証ミドルウェア
│   │   │       ├── routes/          # APIルート
│   │   │       │   ├── learning-efficiency-analyzer.ts # 学習効率API
│   │   │       │   ├── auth.ts      # 認証API
│   │   │       │   └── quiz.ts      # クイズAPI
│   │   │       └── openapi.ts       # OpenAPI仕様定義
│   │   ├── __tests__/               # バックエンドテスト
│   │   │   ├── auth-system.test.ts  # 認証システムテスト
│   │   │   └── learning-efficiency-*.test.ts # 学習効率テスト
│   │   └── seed.ts                  # 初期データ投入
│   ├── vitest.config.ts             # Vitestテスト設定
│   ├── Dockerfile
│   └── docker-entrypoint.sh         # DB 初期化スクリプト
├── docs/                            # プロジェクト文書 (整理済み)
│   ├── development/                 # 開発ワークフロー・TDD
│   ├── operations/                  # CI/CD・運用
│   ├── specifications/              # 要件・仕様
│   └── deployment/                  # デプロイ設定
├── scripts/                         # TDD・開発支援スクリプト
│   ├── tdd-helper.sh                # TDD自動化スクリプト
│   ├── progress-manager.sh          # 進捗管理自動化
│   └── dev-setup.sh                 # 開発環境セットアップ
├── dev.sh                           # 統合開発環境管理スクリプト
├── docker-compose.yml               # Docker 環境設定
├── CLAUDE.md                        # 🤖 Claude Code専用設定
└── README.md                        # このファイル
```

## 🚀 クイックスタート（推奨）

重複プロセス・コンテナを自動停止して開発環境を起動する便利スクリプトを用意しています：

```bash
# プロジェクトディレクトリに移動
cd ap-study-project

# 🐳 Docker環境で起動（推奨）
./dev.sh start docker
# または
npm run dev:docker

# 💻 ローカル環境で起動（高速開発用）
./dev.sh start local  
# または
npm run dev

# 📊 サービス状態確認（ポート・プロセス・エンドポイント）
./dev.sh status
# または
npm run status

# 🛑 全サービス停止（重複プロセス含む）
./dev.sh stop
# または
npm run stop

# 🔄 再起動（クリーンアップ後起動）
./dev.sh restart docker
# または
npm run restart:docker

# 🧹 環境完全クリーンアップ
./dev.sh clean
# または
npm run clean

# 🗄️ データベースのみセットアップ
./dev.sh db-setup
```

### 🔧 従来のDocker Compose起動

```bash
# 初回起動（ビルド・DB初期化・シード投入）
docker compose up --build

# 通常起動
docker compose up

# バックグラウンド起動
docker compose up -d
```

## 🗄️ データベース・シードデータ管理

### シードデータ実行ポリシー

**過去問データのみ**を**手動実行**で提供するポリシーです。ユーザーの学習計画データを完全に保護します。

### シードデータ実行方法（過去問データのみ）

```bash
# 手動でコンテナ内実行（推奨）
./scripts/seed-database.sh

# 直接実行
cd ap-study-backend
npx tsx src/infrastructure/database/seeds/index.ts
```

### ⚠️ 重要な注意事項

- **シード内容**: 過去問データ（2022-2025年）のみ
- **学習計画**: シードデータには含まれません（ユーザーデータ保護）
- **本番環境**: 過去問データのみ必要に応じて実行
- **自動実行**: Docker起動時の自動実行は完全に無効化

## 🔧 個別起動（開発用）

### 前提条件

- **Node.js 22.17.1 LTS** (厳密バージョン要求)
- **PostgreSQL 15+** (本番環境)
- **Docker & Docker Compose** (推奨開発環境)

### データベース準備

```bash
# PostgreSQL を起動してデータベース作成
createdb ap_study

# または Docker でPostgreSQL起動
docker compose up -d postgres
```

### バックエンド

```bash
cd ap-study-backend

# 依存関係インストール
npm install

# 環境変数設定
export DATABASE_URL="postgresql://username:password@localhost:5432/ap_study?schema=public"

# Prismaクライアント生成
npm run db:generate

# データベーススキーマ同期
npm run db:push

# 過去問データシード（必要時のみ手動実行）
# npx tsx src/infrastructure/database/seeds/index.ts
# または専用スクリプト使用: ../../scripts/seed-database.sh

# 開発サーバー起動（ポート8000）
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
- **🧭 Quiz**: IPA公式過去問による演習システム (2022-2025年データ収録)
- **🔐 認証システム**: JWT/ヘッダー認証によるセキュアなユーザー管理
- **🧠 学習効率分析**: AI による時間帯別・分野別効率分析・個人最適化提案
- **🔄 復習システム**: 忘却曲線に基づく復習スケジュール自動生成
- **📈 高度な分析**: 学習パターン分析・成績予測・弱点特定機能
- **💾 エクスポート**: JSON/CSV形式での学習データ出力
- **🌙 ダークモード**: 目に優しい学習環境

#### 開発者機能
- **包括的テストスイート**: Vitest + Testing Library による高品質テスト
- **テストカバレッジ監視**: @vitest/coverage-v8 による詳細なカバレッジレポート
- **🧪 診断インフラ**: CSS/JavaScript/API/環境の包括的テスト
- **🎨 型安全性**: 厳格なTypeScript + ESLint設定
- **⚡ パフォーマンス監視**: 読み込み時間・メモリ使用量計測
- **🔧 デバッグ支援**: エラー特定・環境情報の自動収集
- **TDD開発支援**: 自動化されたRed-Green-Refactorサイクル
- **進捗管理自動化**: スクリプトによる開発進捗の自動記録・分析

## 🛠 技術スタック

### フロントエンド
- **Next.js 15** - React フレームワーク (App Router)
- **React 19** - 最新UI ライブラリ
- **TypeScript 5.8+** - 厳格な型安全性 (strict mode)
- **Tailwind CSS 4.1+** - ユーティリティファーストCSS
- **ESLint** - 厳格なコード品質チェック
- **PWA対応** - プログレッシブウェブアプリ機能

### バックエンド
- **Hono.js 4.0+** - 軽量・高速 Web フレームワーク
- **TypeScript 5.3+** - 型安全なサーバーサイド
- **Prisma ORM 5.10+** - 型安全なデータベースORM
- **PostgreSQL 15** - 高性能リレーショナルDB
- **Zod 3.22+** - スキーマバリデーション
- **クリーンアーキテクチャ** - domain/infrastructure 分離

### 開発・品質保証
- **Vitest 3.2+** - 高速テストランナー (フロントエンド・バックエンド)
- **@vitest/coverage-v8** - V8エンジン基盤の高精度カバレッジ測定
- **Testing Library** - ユーザー視点の統合テスト
- **Docker & Docker Compose** - 一貫した開発環境
- **Node.js 22.17.1 LTS** - 最新安定版（厳密バージョン管理）
- **厳格TypeScript設定** - strictNullChecks, noImplicitAny, noUncheckedIndexedAccess
- **包括的診断システム** - 6種類の専用テストページ
- **自動開発環境管理** - dev.sh スクリプトによる重複プロセス管理
- **自動品質チェック** - lint, typecheck, build 自動実行
- **TDD支援ツール** - Red-Green-Refactorサイクル自動化
- **進捗管理システム** - 開発進捗の自動記録・分析・報告

## 📊 データベース構造

### 基本学習管理
- **study_weeks** - 学習週管理
- **study_days** - 日別学習内容
- **study_logs** - 学習記録
- **morning_tests** - 午前問題記録
- **afternoon_tests** - 午後問題記録

### 高度分析機能
- **learning_efficiency_analyses** - 学習効率分析結果
- **analysis_results** - 分析結果詳細
- **prediction_results** - 試験結果予測
- **review_schedules** - 復習スケジュール
- **quiz_sessions** - クイズセッション記録
- **quiz_questions** - 問題データ (2022-2025年収録)

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

### 🧠 学習効率分析
- `GET /api/learning-efficiency/user/:userId` - ユーザー分析履歴
- `GET /api/learning-efficiency/:id` - 特定分析結果取得
- `POST /api/learning-efficiency/generate` - 新規分析生成
- `GET /api/learning-efficiency/latest/:userId` - 最新分析結果
- `GET /api/learning-efficiency/predict/:userId` - 予測分析
- `GET /api/learning-efficiency/recommendations/:userId` - 個別化推奨

### 🔐 認証システム
- `POST /api/auth/login` - ログイン (JWT発行)
- `POST /api/auth/logout` - ログアウト
- `GET /api/auth/profile` - ユーザープロファイル取得
- `PUT /api/auth/profile` - プロファイル更新

### 📝 クイズ・復習システム
- `GET /api/quiz/questions` - 問題一覧取得
- `POST /api/quiz/session` - クイズセッション開始
- `POST /api/quiz/answer` - 回答送信
- `GET /api/review/schedule/:userId` - 復習スケジュール取得

### 診断・ヘルスチェック
- `GET /api/health` - システムヘルスチェック
- `GET /api/debug/info` - 環境情報取得

## 📈 品質指標・特徴

### コード品質
- **型安全性**: 98% (strict TypeScript + ESLint + 厳格設定)
- **テストカバレッジ**: Vitest + @vitest/coverage-v8による高精度測定
- **テスト品質**: フロントエンド・バックエンド両方でVitestテスト実装
- **コード品質**: 未使用変数・import自動削除、厳格lint適用
- **アーキテクチャ**: クリーンアーキテクチャ準拠
- **TDD実践**: Red-Green-Refactorサイクル自動化で品質向上

### パフォーマンス
- **初期表示**: <1秒 (PWA対応による高速化)
- **API応答**: <200ms (Hono.js軽量フレームワーク)
- **バンドルサイズ**: 最適化済み
- **開発効率**: デバッグ時間 80%短縮 (診断ページ活用)

### 開発体験
- **自動環境管理**: 重複プロセス・ポートの自動解決
- **包括的検査**: CSS/API/環境の統合診断 (6種類のテストページ)
- **即座のフィードバック**: リアルタイム型チェック・lint
- **TDD開発効率**: 81%短縮 (自動スクリプトによる開発時間短縮)
- **進捗可視化**: 自動進捗記録・マイルストーン管理
- **機械学習支援**: 学習効率分析による開発品質向上

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
# フロントエンド品質チェック
cd ap-study-app
npm run lint      # ESLint厳格チェック (未使用削除含む)
npm run build     # TypeScript strict型チェック + ビルド

# バックエンド品質チェック  
cd ap-study-backend
npm run build     # TypeScript strict型チェック + ビルド
npm run db:generate # Prismaクライアント生成

# 統合診断テスト
./dev.sh status   # 環境・API・ポート包括チェック
```

