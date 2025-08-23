# 🔍 ESLint規約遵守ガイド

## 📋 概要

このガイドは、ClaudeCodeを使用する際にESLint規約を確実に遵守するための包括的なリファレンスです。

## 🚨 必須遵守ルール

### 1. **TypeScript型安全性**

#### ❌ 禁止パターン
```typescript
// any型の使用（絶対禁止）
function processData(data: any) { return data; }
const response: any = await fetch('/api/users');
const user: any = { id: 1, name: 'test' };

// 非null assertion（避けるべき）
const user = getUser()!;
const name = user.profile!.name;
```

#### ✅ 推奨パターン
```typescript
// 適切な型定義
interface UserData {
  id: number;
  name: string;
  email: string;
}

function processData(data: UserData): UserData {
  return data;
}

// 適切なAPIレスポンス型
interface ApiResponse<T> {
  success: boolean;
  data: T;
}

const response: ApiResponse<UserData> = await fetch('/api/users');

// 安全なnullチェック
const user = getUser();
if (user?.profile?.name) {
  console.log(user.profile.name);
}
```

### 2. **関数複雑度制限（最大8）**

#### ❌ 複雑すぎる関数
```typescript
// 複雑度 > 8 の例
async function processUserData(userData: UserData) {
  if (userData.type === 'admin') {
    if (userData.permissions.includes('read')) {
      if (userData.status === 'active') {
        // 複雑な処理...
        for (let i = 0; i < userData.resources.length; i++) {
          if (userData.resources[i].category === 'public') {
            // さらに複雑な処理...
          }
        }
      }
    }
  }
  // ... 複雑度が8を超える
}
```

#### ✅ 複雑度を下げた実装
```typescript
// ヘルパー関数に分割
const isAuthorizedAdmin = (user: UserData): boolean => {
  return user.type === 'admin' && 
         user.permissions.includes('read') && 
         user.status === 'active';
};

const processPublicResources = (resources: Resource[]): void => {
  resources
    .filter(resource => resource.category === 'public')
    .forEach(resource => {
      // 処理...
    });
};

// メイン関数（複雑度 ≤ 8）
async function processUserData(userData: UserData) {
  if (!isAuthorizedAdmin(userData)) {
    return;
  }
  
  processPublicResources(userData.resources);
  // ... シンプルで読みやすい
}
```

### 3. **コードスタイル規約**

#### ❌ スタイル違反
```typescript
// 波括弧なし（禁止）
if (condition) doSomething();
else doSomethingElse();

// 長すぎる行（120文字制限）
const veryLongVariableName = someFunction(parameter1, parameter2, parameter3, parameter4, parameter5, parameter6);

// console使用（禁止）
console.log('Debug message');
console.error('Error occurred');
```

#### ✅ 正しいスタイル
```typescript
// 波括弧必須
if (condition) {
  doSomething();
} else {
  doSomethingElse();
}

// 適切な行分割
const veryLongVariableName = someFunction(
  parameter1,
  parameter2,
  parameter3,
  parameter4,
  parameter5,
  parameter6
);

// 適切なロギング（console禁止）
import { logger } from '../utils/logger';
logger.info('Debug message');
logger.error('Error occurred');
```

## 🔧 ClaudeCode使用時のワークフロー

### **必須実行手順**

```typescript
// 1. コード実装
Edit: 新しい機能やファイルの編集

// 2. ESLintチェック（必須）
Bash: "npm run lint"

// 3. 自動修正実行（推奨）
Bash: "npm run lint -- --fix"

// 4. TypeScriptビルドチェック（必須）
Bash: "npm run build"

// 5. 問題があれば再度修正
Edit: ESLint違反箇所の手動修正

// 6. 最終確認
Bash: "npm run lint"
```

### **ESLint違反検出時の対処法**

#### **複雑度違反 (complexity)**
```typescript
// 対処法: ヘルパー関数抽出
// Before: 複雑度 > 8
async function complexFunction() {
  // 多数の条件分岐、ループ、処理
}

// After: 複雑度 ≤ 8
const validateInput = (input) => { /* 検証処理 */ };
const processData = (data) => { /* データ処理 */ };
const generateResponse = (result) => { /* レスポンス生成 */ };

async function simpleFunction() {
  validateInput(input);
  const result = processData(data);
  return generateResponse(result);
}
```

#### **型安全性違反 (@typescript-eslint/no-explicit-any)**
```typescript
// Before: any使用
function handleRequest(req: any, res: any) {
  const data: any = req.body;
  return res.json(data);
}

// After: 適切な型定義
interface RequestBody {
  userId: number;
  action: string;
}

interface ResponseData {
  success: boolean;
  result: string;
}

function handleRequest(req: Request<RequestBody>, res: Response<ResponseData>) {
  const data: RequestBody = req.body;
  return res.json({ success: true, result: 'processed' });
}
```

## 📚 よく使用する型定義パターン

### **API関連型**
```typescript
// レスポンス型
interface ApiResponse<T> {
  success: boolean;
  data: T;
  message?: string;
}

// エラーレスポンス型
interface ApiError {
  success: false;
  error: string;
  errorCode: string;
}

// ページネーション型
interface PaginatedResponse<T> {
  success: true;
  data: T[];
  meta: {
    page: number;
    limit: number;
    total: number;
    hasMore: boolean;
  };
}
```

### **認証関連型**
```typescript
// 認証ユーザー型
interface AuthUser {
  userId: number;
  email: string;
  username: string;
  role: 'user' | 'admin';
}

// JWT payload型
interface JWTPayload {
  sub: string;
  userId: number;
  email: string;
  role: string;
  iat: number;
  exp: number;
}

// ログイン関連型
interface LoginRequest {
  emailOrUsername: string;
  password: string;
}

interface LoginResponse {
  token: string;
  user: Omit<AuthUser, 'password'>;
  expiresIn: string;
}
```

### **学習・クイズ関連型**
```typescript
// 学習記録型
interface StudyLogEntry {
  id?: number;
  userId: number;
  date: Date;
  subject: string;
  topics: string[];
  studyTime: number;
  understanding: number;
  memo?: string;
}

// クイズセッション型
interface QuizSession {
  id: number;
  userId: number;
  sessionType: 'practice' | 'exam' | 'review';
  category?: string;
  totalQuestions: number;
  correctAnswers: number;
  score: number;
  totalTime: number;
  isCompleted: boolean;
  startedAt: Date;
  completedAt?: Date;
}

// 問題型
interface Question {
  id: string;
  category: string;
  subcategory?: string;
  question: string;
  choices: string[];
  correctAnswer: string;
  explanation: string;
  difficulty: number;
  year: number;
  section: string;
}
```

## ⚠️ 重要な注意事項

### **ClaudeCode使用時の絶対ルール**

1. **Edit実行後は必ずESLintチェック**
   ```typescript
   Edit: ファイル編集
   Bash: "npm run lint"  // 必須実行
   ```

2. **`any`型検出時は即座に修正**
   - 具体的な型定義を作成
   - `unknown`型への置換
   - インターフェース定義の活用

3. **複雑度違反時の対処**
   - ヘルパー関数への分割
   - 単一責任原則の適用
   - 早期returnパターンの活用

4. **自動修正の活用**
   ```bash
   npm run lint -- --fix  # 自動修正可能な問題を解決
   ```

## 🎯 成功の指標

- **ESLint違反数**: 0件維持
- **TypeScript型安全性**: 100%（`any`型なし）
- **関数複雑度**: 全関数 ≤ 8
- **コード品質**: 一貫したスタイル維持

このガイドに従うことで、ClaudeCodeを使用した開発時に高品質で保守性の高いコードを確実に生成できます。