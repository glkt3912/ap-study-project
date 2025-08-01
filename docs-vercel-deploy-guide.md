# 🚀 Vercel デプロイガイド

## 方法1: Vercel CLI でデプロイ

### 1. Vercel CLI のインストール

```bash
# グローバルにインストール
npm install -g vercel

# または npx で一時的に使用
npx vercel
```

### 2. Vercelにログイン

```bash
vercel login
```

ブラウザが開いて認証画面が表示されます：

- **GitHub**
- **GitLab**
- **Bitbucket**
- **Email**

どれかでサインアップ/ログインします。

### 3. プロジェクトをデプロイ

```bash
cd ap-study-app

# 初回デプロイ（設定が対話形式で進む）
vercel

# 本番デプロイ
vercel --prod
```

### 4. 対話形式の設定

```
? Set up and deploy "~/projects/ap-study-app"? [Y/n] y
? Which scope do you want to deploy to? Your Personal Account
? Link to existing project? [y/N] n
? What's your project's name? ap-study-app
? In which directory is your code located? ./
? Want to modify these settings? [y/N] n
```

### 5. デプロイ完了

```
✅  Production: https://ap-study-app-xxxx.vercel.app [1s]
📝  Deployed to production. Run `vercel --prod` to overwrite later.
💡  To change the domain or build command, go to https://vercel.com/your-username/ap-study-app
```

## 方法2: GitHub連携でデプロイ

### 1. GitHubリポジトリ作成

```bash
# GitHubでリポジトリ作成後
git init
git add .
git commit -m "Initial commit"
git remote add origin https://github.com/username/ap-study-app.git
git push -u origin main
```

### 2. Vercel Dashboardで連携

1. [vercel.com](https://vercel.com) にアクセス
2. **Import Project** をクリック
3. **GitHub** を選択
4. リポジトリを選択
5. **Import** をクリック

### 3. 自動設定

Vercelが自動で検出：

- ✅ **Framework**: Next.js
- ✅ **Build Command**: `npm run build`
- ✅ **Output Directory**: `.next`
- ✅ **Install Command**: `npm install`

### 4. 環境変数設定（必要に応じて）

Settings → Environment Variables で設定：

```
NEXT_PUBLIC_API_URL = https://your-backend.com/api
DATABASE_URL = your-database-url
```

## 🔧 デプロイ設定のカスタマイズ

### vercel.json 設定ファイル

```json
{
  "framework": "nextjs",
  "buildCommand": "npm run build",
  "outputDirectory": ".next",
  "installCommand": "npm install",
  "devCommand": "npm run dev",
  "regions": ["nrt1"],
  "functions": {
    "app/api/**/*.ts": {
      "runtime": "nodejs18.x"
    }
  },
  "rewrites": [
    {
      "source": "/api/(.*)",
      "destination": "https://your-backend.com/api/$1"
    }
  ]
}
```

## 📊 デプロイ結果の確認

### デプロイURL

- **Production**: `https://your-app.vercel.app`
- **Preview**: `https://your-app-git-branch.vercel.app`

### パフォーマンス

- **Build Time**: 通常30秒-2分
- **Cold Start**: 50-200ms
- **CDN Cache**: 世界中に配信

### 自動最適化

- ✅ **Image Optimization** - 自動画像最適化
- ✅ **Static Generation** - 静的ファイル生成
- ✅ **Edge Functions** - エッジでの実行
- ✅ **Compression** - Gzip/Brotli圧縮

## 🎯 実際のデプロイ体験

### 初回デプロイ（約2分）

```bash
cd ap-study-app
npx vercel

> Set up and deploy "ap-study-app"? Yes
> Which scope? Personal Account
> What's your project's name? ap-study-app
> In which directory is your code located? ./

🔍  Inspect: https://vercel.com/username/ap-study-app/xxx
✅  Production: https://ap-study-app.vercel.app
```

### 更新デプロイ（約30秒）

```bash
# コード変更後
git add .
git commit -m "Update dashboard"
git push

# 自動でビルド・デプロイ開始！
```

## 🔍 デプロイ後の管理

### Vercel Dashboard

- **Deployments**: デプロイ履歴
- **Functions**: サーバーレス関数
- **Analytics**: アクセス解析
- **Domains**: カスタムドメイン
- **Settings**: 環境変数・チーム設定

### プレビュー機能

- **PR毎の自動プレビュー**
- **ブランチ毎のURL生成**
- **レビュー用の一時URL**

## 🚨 よくある問題と解決法

### ビルドエラー

```bash
# ローカルでビルドテスト
npm run build

# 成功すればVercelでも成功する
```

### 環境変数エラー

```bash
# NEXT_PUBLIC_ プレフィックスが必要
NEXT_PUBLIC_API_URL=https://api.example.com
```

### 画像の最適化エラー

```javascript
// next.config.js
module.exports = {
  images: {
    unoptimized: true  // 画像最適化を無効化
  }
}
```

## 💰 料金体系

### 無料プラン（Hobby）

- **帯域幅**: 100GB/月
- **ビルド時間**: 6,000分/月
- **プロジェクト数**: 無制限
- **カスタムドメイン**: 可能

### 有料プラン（Pro: $20/月）

- **帯域幅**: 1TB/月
- **ビルド時間**: 24,000分/月
- **パスワード保護**: 可能
- **チーム機能**: 可能

## 🌐 カスタムドメイン設定

### 独自ドメインの設定

1. Vercel Dashboard → Domains
2. **Add Domain** をクリック
3. ドメイン名を入力（例: `my-study-app.com`）
4. DNS設定を変更：

```
Type: CNAME
Name: www
Value: cname.vercel-dns.com

Type: A
Name: @
Value: 76.76.19.61
```

## 🔄 継続的デプロイ (CI/CD)

### 自動デプロイフロー

```
1. コード変更・コミット
   ↓
2. GitHubにpush
   ↓
3. Vercelが自動検知
   ↓
4. ビルド開始
   ↓
5. テスト実行
   ↓
6. デプロイ完了
   ↓
7. Slack/Email通知
```

### GitHub Actions連携

```yaml
# .github/workflows/deploy.yml
name: Deploy to Vercel
on:
  push:
    branches: [main]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - name: Deploy to Vercel
        uses: amondnet/vercel-action@v20
        with:
          vercel-token: ${{ secrets.VERCEL_TOKEN }}
          vercel-org-id: ${{ secrets.VERCEL_ORG_ID }}
          vercel-project-id: ${{ secrets.VERCEL_PROJECT_ID }}
```

Vercelは本当に**簡単で高機能**なサービスです！特にNext.jsアプリなら数分でデプロイできます。
