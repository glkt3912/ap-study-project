# Prisma マイグレーション管理ガイド

## 📋 概要

Prismaのマイグレーションは、データベーススキーマの変更を追跡・管理する仕組みです。
本ガイドでは、開発環境から本番環境まで安全にデータベース変更を管理する方法を説明します。

## 🔄 マイグレーションの基本概念

### マイグレーションとは

- **スキーマ変更の記録**: テーブル作成、カラム追加などの変更履歴
- **バージョン管理**: 変更を時系列で管理
- **ロールバック対応**: 必要に応じて変更を元に戻す

### マイグレーションファイルの構造

```
prisma/migrations/
├── 20240101000000_init/
│   └── migration.sql
├── 20250802012146_add_analysis_results/
│   └── migration.sql
└── migration_lock.toml
```

## 🛠️ 開発ワークフロー

### 1. スキーマ変更の基本フロー

```bash
# 1. schema.prisma を編集
vim src/infrastructure/database/prisma/schema.prisma

# 2. マイグレーション作成 + 適用
npm run db:migrate
# または
npx prisma migrate dev --name "変更の説明" --schema=src/infrastructure/database/prisma/schema.prisma

# 3. Prisma Client 再生成（自動実行される）
npm run db:generate
```

### 2. 開発環境での作業例

#### 新しいテーブル追加

```bash
# schema.prisma にテーブル追加後
npx prisma migrate dev --name "add_user_settings_table"
```

#### カラム追加

```bash
# schema.prisma にカラム追加後
npx prisma migrate dev --name "add_email_verified_column"
```

#### インデックス追加

```bash
# schema.prisma にインデックス追加後
npx prisma migrate dev --name "add_user_email_index"
```

## 🔧 よく使うコマンド

### 基本コマンド

```bash
# マイグレーション作成・適用（開発環境）
npx prisma migrate dev --name "変更内容" --schema=src/infrastructure/database/prisma/schema.prisma

# マイグレーション状況確認
npx prisma migrate status --schema=src/infrastructure/database/prisma/schema.prisma

# Prisma Client 生成
npx prisma generate --schema=src/infrastructure/database/prisma/schema.prisma

# データベース初期化（危険：全データ削除）
npx prisma migrate reset --schema=src/infrastructure/database/prisma/schema.prisma
```

### プロジェクト固有のnpmコマンド

```bash
# 開発用（package.jsonで定義済み）
npm run db:migrate     # migrate dev
npm run db:generate    # generate
npm run db:push        # db push（一時的な変更用）
npm run db:studio      # Prisma Studio起動
```

## 🚀 本番環境デプロイ

### 本番デプロイの流れ

```bash
# 1. マイグレーション適用（本番環境）
npx prisma migrate deploy --schema=src/infrastructure/database/prisma/schema.prisma

# 2. Prisma Client 生成
npx prisma generate --schema=src/infrastructure/database/prisma/schema.prisma
```

### CI/CD での自動化例

```yaml
# GitHub Actions例
- name: Run database migrations
  run: |
    npx prisma migrate deploy --schema=src/infrastructure/database/prisma/schema.prisma
    npx prisma generate --schema=src/infrastructure/database/prisma/schema.prisma
```

## ⚠️ トラブルシューティング

### 1. マイグレーション履歴の不整合

**問題**: データベースにテーブルは存在するが、マイグレーション履歴がない

```bash
# 状況確認
npx prisma migrate status

# 例: "Following migrations have not yet been applied"
```

**解決方法**: 既存マイグレーションを適用済みとしてマーク

```bash
# 特定のマイグレーションをマーク
npx prisma migrate resolve --applied 20240101000000_init --schema=src/infrastructure/database/prisma/schema.prisma

# 複数の場合は1つずつ実行
npx prisma migrate resolve --applied 20250802012146_add_analysis_results --schema=src/infrastructure/database/prisma/schema.prisma
```

### 2. スキーマドリフト（Schema Drift）

**問題**: データベースの実際の状態とスキーマファイルが異なる

```bash
# データベースから現在の状態を逆引き
npx prisma db pull --schema=src/infrastructure/database/prisma/schema.prisma

# 差分を確認してからマイグレーション作成
npx prisma migrate dev --name "fix_schema_drift"
```

### 3. マイグレーション失敗

**問題**: マイグレーションが途中で失敗

```bash
# 失敗したマイグレーションをロールバック
npx prisma migrate resolve --rolled-back マイグレーション名

# スキーマを修正してから再実行
npx prisma migrate dev --name "fix_migration"
```

## 🚨 危険なコマンドと注意点

### 避けるべきコマンド（本番環境）

```bash
# 🚫 全データ削除（開発環境以外では絶対に使わない）
npx prisma migrate reset

# 🚫 強制的にスキーマ同期（データロスの可能性）
npx prisma db push --force-reset
```

### 安全な運用ルール

1. **本番環境では migrate deploy のみ使用**
2. **migrate dev は開発環境でのみ使用**
3. **マイグレーション前は必ずバックアップ**
4. **破壊的変更は段階的に実施**

## 🎯 ベストプラクティス

### 1. マイグレーション命名規則

```bash
# Good: 具体的で分かりやすい名前
npx prisma migrate dev --name "add_user_email_verification"
npx prisma migrate dev --name "create_exam_config_table"
npx prisma migrate dev --name "add_index_on_user_email"

# Bad: 曖昧な名前
npx prisma migrate dev --name "update"
npx prisma migrate dev --name "fix"
```

### 2. 段階的な変更

```bash
# 大きな変更は小さく分割
# 1. まずNULL許可でカラム追加
npx prisma migrate dev --name "add_optional_column"

# 2. デフォルト値設定
npx prisma migrate dev --name "set_default_values"

# 3. NOT NULL制約追加
npx prisma migrate dev --name "add_not_null_constraint"
```

### 3. 本番前の検証

```bash
# ステージング環境でテスト
npx prisma migrate deploy --preview-feature

# マイグレーション内容の事前確認
cat prisma/migrations/[タイムスタンプ]_[名前]/migration.sql
```

## 📊 現在のプロジェクト状況

### マイグレーション履歴

```
✅ 20240101000000_init                           # 初期テーブル
✅ 20250801151813_add_topics_and_fix_afternoon_test  # トピック機能
✅ 20250802012146_add_analysis_results              # 分析結果
✅ 20250802013524_add_prediction_results            # 予測結果
✅ 20250802014625_add_review_system                 # 復習システム
✅ 20250802051041_add_quiz_functionality            # クイズ機能
✅ 20250810000000_add_exam_config                   # 試験設定
```

### 現在のテーブル構成

- `users` - ユーザー情報
- `study_weeks` - 学習週計画
- `study_days` - 学習日計画
- `study_logs` - 学習記録
- `morning_tests` - 午前問題記録
- `afternoon_tests` - 午後問題記録
- `analysis_results` - 分析結果
- `prediction_results` - 予測結果
- `review_items` - 復習項目
- `review_sessions` - 復習セッション
- `questions` - 過去問題
- `user_answers` - ユーザー回答記録
- `quiz_sessions` - クイズセッション
- `exam_configs` - 試験設定

## 🔍 デバッグ・確認コマンド

```bash
# データベース接続確認
npx prisma db execute --stdin --schema=src/infrastructure/database/prisma/schema.prisma < query.sql

# Prisma Studio でデータ確認
npm run db:studio

# マイグレーション履歴表示
npx prisma migrate status --schema=src/infrastructure/database/prisma/schema.prisma

# スキーマ検証
npx prisma validate --schema=src/infrastructure/database/prisma/schema.prisma
```

## 🚀 次のステップ

1. **定期的なバックアップ設定**
2. **マイグレーション監視の自動化**
3. **ロールバック手順の文書化**
4. **チーム内でのマイグレーション運用ルール策定**

---

**💡 重要**: マイグレーションは不可逆的な操作が多いため、特に本番環境では慎重に実行してください。
