# 🔄 開発ワークフロー（Claude Code専用）

## 🎯 Claude Code 効率化設定

### 📋 作業開始時のチェックリスト

```bash
# 1. 現在の状況確認
git status
git log --oneline -5

# 2. 依存関係確認
cd ap-study-backend && npm install
cd ../ap-study-app && npm install

# 3. 環境動作確認
docker compose up --build
# または
npm run dev (各ディレクトリで)
```

### 🛠️ 機能開発フロー

#### Step 1: 設計・計画 (5分)
1. **マイルストーン確認**: `docs-milestones.md` で現在のタスク確認
2. **要件確認**: `docs-app-requirements.md` で仕様確認
3. **アーキテクチャ確認**: クリーンアーキテクチャに従った設計

#### Step 2: バックエンド実装 (20-30分)
```bash
cd ap-study-backend

# 2.1 ドメイン層実装
# src/domain/entities/ - エンティティ
# src/domain/repositories/ - リポジトリI/F
# src/domain/usecases/ - ユースケース

# 2.2 インフラ層実装  
# src/infrastructure/database/ - Prisma実装
# src/infrastructure/web/ - API実装

# 2.3 動作確認
npm run dev
curl http://localhost:8000/api/test-endpoint
```

#### Step 3: フロントエンド実装 (20-30分)
```bash
cd ap-study-app

# 3.1 API クライアント更新
# src/lib/api.ts - HTTP クライアント

# 3.2 コンポーネント実装
# src/components/ - UI コンポーネント
# src/app/ - ページコンポーネント

# 3.3 動作確認
npm run dev
# http://localhost:3000 でUI確認
```

#### Step 4: 品質チェック (5-10分)
```bash
# 4.1 Lint チェック
cd ap-study-app && npm run lint
cd ../ap-study-backend && npm run build

# 4.2 型チェック
# TypeScript エラーがないことを確認

# 4.3 動作テスト
# 基本的なCRUD操作を手動テスト
```

#### Step 5: コミット・文書更新 (5分)
```bash
# 5.1 変更をコミット
git add .
git commit -m "feat: implement [機能名]

- Add [具体的な変更内容]
- Update [更新内容]

🤖 Generated with Claude Code"

# 5.2 マイルストーン進捗更新
# docs-milestones.md の該当タスクを完了に更新
```

## 🏗️ クリーンアーキテクチャ実装パターン

### バックエンド実装順序

1. **エンティティ作成** (`src/domain/entities/`)
```typescript
// 例: StudyLog.ts
export interface StudyLog {
  id: string
  date: Date
  subject: string
  studyTime: number
  understanding: number
  memo?: string
}
```

2. **リポジトリI/F定義** (`src/domain/repositories/`)
```typescript
// 例: IStudyLogRepository.ts
export interface IStudyLogRepository {
  findByDate(date: Date): Promise<StudyLog[]>
  create(studyLog: StudyLog): Promise<StudyLog>
  update(id: string, studyLog: Partial<StudyLog>): Promise<StudyLog>
}
```

3. **ユースケース実装** (`src/domain/usecases/`)
```typescript
// 例: CreateStudyLog.ts
export class CreateStudyLogUseCase {
  constructor(private repository: IStudyLogRepository) {}
  
  async execute(studyLog: StudyLog): Promise<StudyLog> {
    // ビジネスロジック
    return await this.repository.create(studyLog)
  }
}
```

4. **Prisma実装** (`src/infrastructure/database/`)
```typescript
// 例: StudyLogRepository.ts
export class StudyLogRepository implements IStudyLogRepository {
  constructor(private prisma: PrismaClient) {}
  
  async findByDate(date: Date): Promise<StudyLog[]> {
    return await this.prisma.studyLog.findMany({
      where: { date }
    })
  }
}
```

5. **API実装** (`src/infrastructure/web/routes/`)
```typescript
// 例: studyLog.ts  
export function createStudyLogRoutes(useCase: CreateStudyLogUseCase) {
  const router = new Hono()
  
  router.post('/', async (c) => {
    const body = await c.req.json()
    const result = await useCase.execute(body)
    return c.json({ success: true, data: result })
  })
  
  return router
}
```

### フロントエンド実装パターン

1. **API クライアント更新** (`src/lib/api.ts`)
```typescript
export async function createStudyLog(studyLog: StudyLog) {
  const response = await fetch('/api/study/log', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify(studyLog)
  })
  return response.json()
}
```

2. **コンポーネント実装** (`src/components/`)
```typescript
export function StudyLogForm() {
  const [loading, setLoading] = useState(false)
  
  const handleSubmit = async (data: StudyLog) => {
    setLoading(true)
    try {
      await createStudyLog(data)
      // 成功処理
    } catch (error) {
      // エラー処理
    } finally {
      setLoading(false)
    }
  }
  
  return (
    // UI実装
  )
}
```

## 🔍 品質管理・チェックポイント

### 必須チェック項目

#### コードの品質
- [ ] **TypeScript エラーなし**: 型安全性確保
- [ ] **ESLint警告なし**: コード品質維持
- [ ] **命名規則統一**: 英語での適切な命名
- [ ] **コメント**: 複雑なロジックのみ最小限

#### 機能の品質
- [ ] **API動作確認**: 全エンドポイントのテスト
- [ ] **UI動作確認**: 基本的なユーザー操作
- [ ] **エラーハンドリング**: 適切なエラー表示
- [ ] **ローディング状態**: UX向上のための待機表示

#### アーキテクチャの品質
- [ ] **層の分離**: 適切な責務分離
- [ ] **依存性注入**: インターフェースの活用
- [ ] **単一責任**: 各クラス・関数の役割明確化

### パフォーマンスチェック

```bash
# バンドルサイズ確認
cd ap-study-app
npm run build
# .next/static の出力サイズを確認

# API レスポンス確認
time curl http://localhost:8000/api/study/plan
# 200ms以内を目標
```

## 🚨 トラブルシューティング

### よくある問題と対処法

#### 1. CORS エラー
```bash
# 原因: オリジン設定の問題
# 対処: ap-study-backend/src/app.ts のCORS設定確認
```

#### 2. TypeScript エラー
```bash
# 原因: 型定義の不整合
# 対処: 
npm install @types/node@^22.11.0
npm run build
```

#### 3. Prisma接続エラー
```bash
# 原因: データベース設定の問題
# 対処:
cd ap-study-backend
npm run db:generate  
npm run db:push
```

#### 4. Docker起動失敗
```bash
# 原因: ポート競合・キャッシュ問題
# 対処:
docker compose down
docker system prune -f
docker compose up --build
```

## 📊 進捗管理

### 日次確認項目
- [ ] 本日完了予定タスクの進捗
- [ ] 次回作業内容の明確化
- [ ] 技術的課題の洗い出し

### 週次確認項目  
- [ ] マイルストーン進捗の更新
- [ ] 品質指標の測定
- [ ] 次週計画の調整

## 🎯 パフォーマンス目標

### 開発効率
- **新機能実装**: 1-2時間/機能
- **バグ修正**: 15-30分/件  
- **品質チェック**: 10分/機能

### アプリ性能
- **初期表示**: 1秒以内
- **API応答**: 200ms以内
- **ビルド時間**: 30秒以内

---

**💡 Claude Code専用メモ**: このワークフローに従って効率的な開発を心がけ、品質と速度のバランスを保ちながら進めてください。