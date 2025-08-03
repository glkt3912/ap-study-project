# 🔄 CI/CD アーキテクチャ設計書

## 📝 GitHub Actions配置方針の説明

### 🤔 **配置に関する検討事項**

ユーザーから重要な指摘を受けました：
> 「CI/CDはドキュメントしか基本配置しないProjectリポジトリに置くのは違和感があるが問題ないのか？」

### 📊 **現在の配置状況**

```
ap-study-project/
├── .github/workflows/          # ⚠️ 現在の配置
│   ├── ci.yml                 # CI/CD パイプライン
│   ├── deploy.yml             # デプロイメント
│   └── pr-check.yml           # PR チェック
├── ap-study-app/              # フロントエンド
├── ap-study-backend/          # バックエンド
└── docs-*                     # ドキュメント
```

## 🔍 **配置オプション検討**

### **Option A: 現在の配置（統合リポジトリ）** 
```
ap-study-project/.github/workflows/
```

**メリット:**
- ✅ フロントエンド・バックエンド統合CI/CD
- ✅ 単一ワークフローで連携テスト可能
- ✅ 依存関係管理が容易
- ✅ モノレポ構成に適している

**デメリット:**
- ❌ 各サブプロジェクトの独立性が低い
- ❌ CI/CD実行時に全体をチェックアウト

### **Option B: 分散配置（各サブディレクトリ）**
```
ap-study-app/.github/workflows/
ap-study-backend/.github/workflows/
```

**メリット:**
- ✅ 各プロジェクトの独立性が高い
- ✅ 部分的なCI/CD実行が可能
- ✅ 将来の分離が容易

**デメリット:**
- ❌ 統合テストが複雑
- ❌ ワークフロー重複・管理負荷
- ❌ 依存関係管理が困難

### **Option C: 外部CI/CDサービス**
```
CircleCI / GitLab CI / Azure DevOps
```

**メリット:**
- ✅ GitHub Actions制約回避
- ✅ 高度なパイプライン機能

**デメリット:**
- ❌ 学習コスト増加
- ❌ GitHub統合度が低下

## 🎯 **推奨解決策**

### **即時対応: Option A継続 + 設定調整**

現在の配置を継続しつつ、以下の改善を実施：

#### **1. ワークフロー最適化**
```yaml
# ci.yml での変更検出最適化
on:
  push:
    paths:
      - 'ap-study-app/**'
      - 'ap-study-backend/**'
  pull_request:
    paths:
      - 'ap-study-app/**'
      - 'ap-study-backend/**'
```

#### **2. ジョブ条件分岐**
```yaml
frontend-test:
  if: contains(github.event.head_commit.modified, 'ap-study-app/')
  
backend-test:
  if: contains(github.event.head_commit.modified, 'ap-study-backend/')
```

#### **3. キャッシュ最適化**
```yaml
- uses: actions/cache@v4
  with:
    path: |
      ap-study-app/node_modules
      ap-study-backend/node_modules
    key: ${{ runner.os }}-node-${{ hashFiles('**/package-lock.json') }}
```

### **中期対応: Option B移行準備**

Phase Cでプロジェクト成熟時に検討：

#### **分離準備**
1. **シンボリックリンク活用**
```bash
ap-study-app/.github -> ../../../.github/workflows/frontend/
ap-study-backend/.github -> ../../../.github/workflows/backend/
```

2. **共通ワークフロー抽出**
```yaml
# .github/workflows/shared/
├── security-scan.yml
├── quality-check.yml
└── deploy-common.yml
```

3. **マトリックス戦略**
```yaml
strategy:
  matrix:
    project: [ap-study-app, ap-study-backend]
    include:
      - project: ap-study-app
        node-version: 22.17.1
        test-command: npm run test:run
      - project: ap-study-backend
        node-version: 22.17.1
        test-command: npm run build
```

## 📋 **ベストプラクティス適用**

### **モノレポCI/CD最適化**

#### **1. 変更検出による効率化**
```yaml
name: Smart CI/CD
on:
  push:
    paths:
      - 'ap-study-app/**'
      - 'ap-study-backend/**'
      - '.github/workflows/**'

jobs:
  detect-changes:
    outputs:
      frontend: ${{ steps.changes.outputs.frontend }}
      backend: ${{ steps.changes.outputs.backend }}
    steps:
      - uses: dorny/paths-filter@v2
        id: changes
        with:
          filters: |
            frontend:
              - 'ap-study-app/**'
            backend:
              - 'ap-study-backend/**'
  
  frontend-test:
    needs: detect-changes
    if: needs.detect-changes.outputs.frontend == 'true'
    # ... フロントエンドテスト
    
  backend-test:
    needs: detect-changes
    if: needs.detect-changes.outputs.backend == 'true'
    # ... バックエンドテスト
```

#### **2. 並列実行最適化**
```yaml
jobs:
  frontend-test:
    strategy:
      matrix:
        os: [ubuntu-latest]
        node-version: [22.17.1]
    runs-on: ${{ matrix.os }}
    
  backend-test:
    strategy:
      matrix:
        os: [ubuntu-latest]
        node-version: [22.17.1]
        database: [postgresql]
    runs-on: ${{ matrix.os }}
```

#### **3. 依存関係管理**
```yaml
integration-test:
  needs: [frontend-test, backend-test]
  if: needs.frontend-test.result == 'success' && needs.backend-test.result == 'success'
```

## 🚀 **実装ロードマップ**

### **Phase 1: 即時最適化** (現在)
- ✅ 変更検出追加
- ✅ ジョブ条件分岐
- ✅ キャッシュ最適化

### **Phase 2: 中期改善** (Phase C時)
- [ ] マトリックス戦略導入
- [ ] 共通ワークフロー抽出
- [ ] パフォーマンス監視強化

### **Phase 3: 最終最適化** (拡張時)
- [ ] 分散配置検討
- [ ] マイクロサービス対応
- [ ] 高度な並列化

## 💡 **結論**

### **現在の方針: Option A継続が最適**

**理由:**
1. **プロジェクト性質**: 学習管理システムは密結合
2. **開発効率**: 統合CI/CDの方が管理効率が高い
3. **現在規模**: フロントエンド・バックエンド2つなら統合が適切
4. **技術的制約**: GitHub Actions無料枠での最適化

### **改善方針:**
1. **即時**: ワークフロー最適化実装
2. **中期**: 条件分岐・並列化強化
3. **長期**: 必要時に分散配置検討

**➡️ 現在の配置は妥当。最適化を継続して品質・効率を向上させる方針で進行**

---

**📝 補足: 大規模プロジェクトでの一般的な配置**

- **Netflix, Google**: モノレポ + 統合CI/CD
- **Facebook**: モノレポ + Buck/Bazel
- **Uber**: マイクロサービス + 分散CI/CD

**学習管理システムの現在規模では統合型が最適解**