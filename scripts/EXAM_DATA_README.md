# 📚 過去問データ管理システム

応用情報技術者試験の過去問データを効率的に管理・変換するためのシステムです。

## 🏗️ ディレクトリ構造

```
ap-study-project/
├── exam-data-source/          # 過去問データソース（gitignore対象）
│   ├── 2020/
│   │   ├── spring/{morning,afternoon}/
│   │   └── autumn/{morning,afternoon}/
│   ├── 2021/
│   ├── 2022/
│   ├── 2023/
│   ├── 2024/
│   └── 2025/
├── scripts/
│   ├── convert-exam-data.sh   # データ変換スクリプト
│   └── validate-exam-data.sh  # データ検証・分析スクリプト
└── ap-study-backend/src/infrastructure/database/seeds/
    ├── questions-2020.json
    ├── questions-2021.json
    ├── questions-2022.json
    ├── questions-2023.json
    ├── questions-2024.json
    └── questions-2025.json
```

## 🚀 使用方法

### 1. 過去問データソースの準備

過去問データを以下の形式で `exam-data-source/` ディレクトリに配置してください：

```bash
# 例: 2024年春季午前のデータ
exam-data-source/2024/spring/morning/questions.json
```

#### 対応データ形式

- **JSON**: 推奨形式
- **CSV**: 自動変換対応
- **YAML**: 自動変換対応
- **TXT**: 構造化テキスト（要カスタマイズ）

#### JSON形式の例

```json
[
  {
    \"id\": \"ap2024spring_am_01\",
    \"year\": 2024,
    \"season\": \"spring\",
    \"section\": \"morning\",
    \"number\": 1,
    \"category\": \"基礎理論\",
    \"subcategory\": \"2進数\",
    \"difficulty\": 2,
    \"question\": \"2進数1101を10進数で表したものはどれか。\",
    \"choices\": [\"11\", \"13\", \"15\", \"17\"],
    \"answer\": \"B\",
    \"explanation\": \"2進数1101 = 1×2³ + 1×2² + 0×2¹ + 1×2⁰ = 8 + 4 + 0 + 1 = 13\",
    \"tags\": [\"2進数\", \"計算\", \"基礎\"]
  }
]
```

### 2. データ変換

#### 単一データセットの変換

```bash
# 特定年度・季節・部の変換
./scripts/convert-exam-data.sh 2024 spring morning

# 例: 2023年秋季午後の変換
./scripts/convert-exam-data.sh 2023 autumn afternoon
```

#### 一括変換

```bash
# 全年度・全季節・全部を一括変換
./scripts/convert-exam-data.sh --all

# 特定年度のみ一括変換
./scripts/convert-exam-data.sh --year 2024

# ドライラン（実際の変換は行わず、処理内容のみ表示）
./scripts/convert-exam-data.sh --all --dry-run
```

#### データ検証のみ

```bash
# 既存データの検証
./scripts/convert-exam-data.sh --validate-only
```

### 3. データ検証・分析

#### 基本統計・整合性チェック

```bash
# 統計情報と整合性チェック
./scripts/validate-exam-data.sh

# 統計情報のみ
./scripts/validate-exam-data.sh --statistics

# 網羅率分析
./scripts/validate-exam-data.sh --coverage
```

#### 詳細レポート生成

```bash
# HTML形式の詳細レポート生成
./scripts/validate-exam-data.sh --report
```

#### 自動修正

```bash
# 重複IDの自動修正
./scripts/validate-exam-data.sh --fix-ids
```

## 📊 データ形式仕様

### 必須フィールド

| フィールド | 型 | 説明 | 例 |
|-----------|---|-----|---|
| `id` | string | 一意識別子 | \"ap2024spring_am_01\" |
| `year` | number | 年度 | 2024 |
| `season` | string | 季節 | \"spring\" / \"autumn\" |
| `section` | string | 部 | \"morning\" / \"afternoon\" |
| `number` | number | 問題番号 | 1 |
| `category` | string | 大分類 | \"基礎理論\" |
| `question` | string | 問題文 | \"2進数1101を...\" |
| `choices` | array | 選択肢 | [\"11\", \"13\", \"15\", \"17\"] |
| `answer` | string | 正答 | \"B\" |

### 任意フィールド

| フィールド | 型 | 説明 | 例 |
|-----------|---|-----|---|
| `subcategory` | string | 小分類 | \"2進数\" |
| `difficulty` | number | 難易度(1-5) | 2 |
| `explanation` | string | 解説 | \"2進数1101 = ...\" |
| `tags` | array | タグ | [\"2進数\", \"計算\"] |

### カテゴリ一覧

- **基礎理論**: 数学、論理回路、アルゴリズム等
- **コンピュータシステム**: ハードウェア、OS、アーキテクチャ
- **技術要素**: ネットワーク、データベース、セキュリティ
- **開発技術**: プログラミング、設計手法、テスト
- **プロジェクトマネジメント**: 工程管理、品質管理
- **サービスマネジメント**: ITIL、運用管理
- **システム戦略**: システム企画、要件定義
- **経営戦略・企業と法務**: 経営戦略、法律、標準化

## 🔧 トラブルシューティング

### よくある問題

#### Q: 「データソースディレクトリが存在しません」エラー

```bash
# ディレクトリを作成してください
mkdir -p exam-data-source/2024/spring/morning
```

#### Q: JSON形式エラー

```bash
# JSON形式をチェック
jq . exam-data-source/2024/spring/morning/questions.json
```

#### Q: 重複IDエラー

```bash
# 自動修正実行
./scripts/validate-exam-data.sh --fix-ids
```

#### Q: 文字化け

```bash
# UTF-8エンコーディングに変換
iconv -f SHIFT_JIS -t UTF-8 input.txt > output.txt
```

### ログ確認

スクリプトは詳細なログを出力します：

- 🔵 **[INFO]**: 情報メッセージ
- 🟢 **[SUCCESS]**: 成功メッセージ  
- 🟡 **[WARNING]**: 警告メッセージ
- 🔴 **[ERROR]**: エラーメッセージ
- 🔷 **[REPORT]**: レポート情報

### バックアップ

データ変換時、既存ファイルは自動的にバックアップされます：

```bash
# バックアップファイル例
ap-study-backend/src/infrastructure/database/seeds/questions-2024.json.backup.20241201_143022
```

## 📈 効果・メリット

### Token使用量削減

- **従来**: 問題1問あたり約100-200トークン消費
- **本システム**: データ変換時のみ少量トークン使用
- **削減効果**: 約80-90%のトークン節約

### 品質向上

- 実際の試験問題による高精度
- 統一されたデータ形式
- 自動検証による品質保証

### 効率性

- 大量データの一括処理
- 自動化された変換・検証
- 豊富なレポート機能

## 🛡️ セキュリティ・著作権

- 過去問データソースは`.gitignore`で除外
- 著作権保護されたデータの適切な管理
- ローカル環境での安全な処理

## 🔄 更新・メンテナンス

### 新年度データ追加

```bash
# 1. データソース配置
mkdir -p exam-data-source/2026/spring/morning
# データファイルをコピー

# 2. 変換実行
./scripts/convert-exam-data.sh --year 2026

# 3. 検証実行
./scripts/validate-exam-data.sh --statistics
```

### システム更新

```bash
# 最新の変換ロジック適用
./scripts/convert-exam-data.sh --all

# 全データ再検証
./scripts/validate-exam-data.sh --report
```

---

💡 **ヒント**: 定期的に `./scripts/validate-exam-data.sh --report` を実行して、データの健康状態をモニタリングしてください。