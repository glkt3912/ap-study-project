# 🚦 CI/CD運用状況・制御設定

## 📊 **現在の運用状況**

### **✅ 有効化されているワークフロー**

#### **開発CI（テスト・品質チェックのみ）**

```
✅ .github/workflows/ci.yml              # 統合CI（開発用）
✅ ap-study-app/.github/workflows/ci.yml # フロントエンドCI
✅ ap-study-backend/.github/workflows/ci.yml # バックエンドCI
```

**実行内容**:

- ✅ TypeScript ビルド・型チェック
- ✅ ESLint コード品質チェック
- ✅ Vitest テスト実行
- ✅ セキュリティスキャン（Trivy + npm audit）
- ✅ TDD統合（npm run tdd:cycle）

### **❌ 無効化されているワークフロー**

#### **本番デプロイ関連（全て無効化済み）**

```
❌ .github/workflows/disabled/deploy.yml    # 本番デプロイ（移動済み）
❌ Vercel自動デプロイ                        # フロントエンド本番デプロイ
❌ Railway自動デプロイ                       # バックエンド本番デプロイ  
❌ プレビューデプロイ                        # PR環境デプロイ
```

**無効化理由**:

- 🚫 本番環境未整備
- 🚫 Secrets未設定（VERCEL_TOKEN, RAILWAY_TOKEN等）
- 🚫 ドメイン・環境変数未設定
- 🚫 デプロイ戦略未確定

## 🎯 **運用方針**

### **Phase 1: 開発CI（現在）**

```bash
目的: 開発品質確保・TDD支援
対象: main, develop ブランチ + PR
実行: テスト・ビルド・セキュリティチェックのみ
```

### **Phase 2: 本番環境準備（未来）**

```bash
前提条件:
1. 本番環境セットアップ完了
2. GitHub Secrets設定完了
3. ドメイン・DNS設定完了
4. デプロイ戦略確定（Vercel + Supabase等）
```

### **Phase 3: 本番CI/CD有効化（未来）**

```bash
有効化内容:
- Vercel本番デプロイ
- Supabase Edge Functions
- プレビュー環境
- ヘルスチェック・監視
```

## 🔧 **ワークフロー詳細**

### **統合CI (.github/workflows/ci.yml)**

**トリガー**: push (main/develop), PR, manual
**実行内容**:

```yaml
jobs:
  detect-changes     # 変更検出（効率化）
  frontend-test      # フロントエンドCI
  backend-test       # バックエンドCI  
  integration-test   # 統合テスト
  security-scan      # セキュリティスキャン
  development-ready  # 開発完了通知
```

**現在の設定**:

- ✅ PostgreSQL テストDB自動構築
- ✅ 依存関係キャッシュ
- ✅ TDD支援統合
- ❌ デプロイ機能無効化

### **フロントエンドCI (ap-study-app/.github/workflows/ci.yml)**

**実行内容**:

```yaml
jobs:
  test-and-build    # Vitest + ESLint + Build
  security-scan     # Trivy + npm audit
  # deploy-*        # 全デプロイ無効化済み
```

**設定変更**:

- ✅ `NEXT_PUBLIC_API_URL: http://localhost:8000` (開発用)
- ❌ Vercelデプロイ完全無効化

### **バックエンドCI (ap-study-backend/.github/workflows/ci.yml)**

**実行内容**:

```yaml
jobs:
  test-and-build       # tsc + Prisma + TDD
  security-scan        # Trivy + npm audit
  development-ready    # 開発完了通知
  # deploy-*           # 全デプロイ無効化済み
```

**設定変更**:

- ✅ TDD統合 (`npm run tdd:cycle`)
- ❌ Railway/Vercelデプロイ完全無効化

## 🚀 **本番環境有効化の手順**

### **前提条件チェックリスト**

#### **1. インフラ準備**

- [ ] Vercel プロジェクト作成・設定
- [ ] Supabase プロジェクト作成・設定
- [ ] ドメイン取得・DNS設定
- [ ] 環境変数設定完了

#### **2. GitHub設定**

- [ ] Repository Secrets設定
  - `VERCEL_TOKEN`
  - `SUPABASE_URL`
  - `SUPABASE_ANON_KEY`
  - `SUPABASE_SERVICE_ROLE_KEY`
- [ ] 本番ブランチ保護設定

#### **3. デプロイ戦略確定**

- [ ] Vercel (フロントエンド) 設定確認
- [ ] Supabase Edge Functions (バックエンド) 移行計画
- [ ] データベース移行計画（Prisma → Supabase）

### **有効化手順**

#### **Step 1: デプロイワークフロー復元**

```bash
# 無効化されたデプロイジョブのコメントアウト解除
# 各ワークフローファイルの deploy-* ジョブを有効化
```

#### **Step 2: 設定ファイル更新**

```bash
# 本番環境用設定に変更
NEXT_PUBLIC_API_URL: https://your-backend.supabase.co
DATABASE_URL: postgresql://...supabase...
```

#### **Step 3: 段階的有効化**

```bash
1. プレビュー環境（PR）のみ有効化
2. ステージング環境テスト
3. 本番環境デプロイ有効化
```

## ⚠️ **注意事項**

### **現在の制限**

- 🚫 **本番デプロイ厳禁**: Secrets未設定のため失敗確実
- 🚫 **プレビュー環境なし**: 全デプロイワークフロー無効化済み
- ✅ **開発CI正常**: テスト・ビルド・品質チェックは正常動作

### **運用ガイドライン**

1. **開発フェーズ**: 現在の設定で継続開発
2. **本番準備**: インフラ整備完了後にワークフロー有効化
3. **段階的移行**: 一気に有効化せず、段階的にテスト
4. **監視体制**: デプロイ有効化時はエラー監視強化

## 📋 **トラブルシューティング**

### **よくある問題**

#### **CI失敗時**

```bash
# 原因: Secrets未設定
解決: 該当ワークフローが無効化済みか確認

# 原因: 依存関係エラー  
解決: package.json / package-lock.json 整合性確認

# 原因: PostgreSQL接続エラー
解決: GitHub Actions の postgres サービス確認
```

#### **デプロイエラー時（将来）**

```bash
# 原因: Vercel設定エラー
解決: vercel.json 設定・プロジェクト連携確認

# 原因: 環境変数未設定
解決: GitHub Secrets・Vercel環境変数確認

# 原因: ビルドエラー
解決: ローカル環境でのビルド成功確認
```

---

**💡 現在は開発品質確保のCI機能のみ稼働中。本番デプロイは環境整備完了まで安全に無効化されています。**
