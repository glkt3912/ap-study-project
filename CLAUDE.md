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
└── docs-*/               # プロジェクト文書（docs- プレフィックス）
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
```

### 🧪 品質チェック

```bash
# フロントエンド
cd ap-study-app
npm run lint
npm run build

# バックエンド  
cd ap-study-backend
npm run build
```

## 📚 参考ドキュメント

### 📋 開発管理
- **`docs-milestones.md`** - 詳細なマイルストーン・タスク管理
- **`docs-development-workflow.md`** - 開発手順・ベストプラクティス
- **`docs-commands.md`** - よく使うコマンド一覧

### 📖 プロジェクト仕様
- **`docs-app-requirements.md`** - アプリ要件定義
- **`docs-study-plan.md`** - 学習計画詳細
- **`docs-vercel-deploy-guide.md`** - デプロイ手順

## 📊 現在のマイルストーン

### 🎯 マイルストーン 1: 基盤機能の完成（進行中）
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

## 🔄 開発フロー

### 機能追加時
1. **仕様確認** - `docs-app-requirements.md` 参照
2. **設計検討** - クリーンアーキテクチャに従う
3. **バックエンド実装** - ドメイン → インフラ層
4. **フロントエンド実装** - コンポーネント → API連携
5. **テスト・品質チェック** - lint, build, 動作確認

### ディレクトリ命名規則
- **docs-***: 文書ファイル
- **ap-study-***: プロダクトディレクトリ

## 🚨 重要な制約・注意事項

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

**💡 Claude Code への指示**: このファイルの内容を参考に、効率的で品質の高い開発を進めてください。マイルストーン順に段階的な実装を心がけ、各段階で動作確認を必ず実施してください。