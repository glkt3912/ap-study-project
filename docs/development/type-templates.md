# 📝 TypeScript型定義テンプレート集

## 🎯 概要

ClaudeCodeでの開発時に`any`型を避けて適切な型定義を使用するためのテンプレート集です。

## 🏗️ 基本型パターン

### **1. API レスポンス型テンプレート**

```typescript
// 基本成功レスポンス
interface ApiResponse<T> {
  success: true;
  data: T;
  message?: string;
  metadata?: {
    timestamp: string;
    version: string;
  };
}

// エラーレスポンス
interface ApiError {
  success: false;
  error: string;
  errorCode: string;
  details?: Record<string, unknown>;
}

// 統合レスポンス型
type ApiResult<T> = ApiResponse<T> | ApiError;

// 使用例
interface User {
  id: number;
  name: string;
  email: string;
}

const getUserResponse: ApiResult<User> = {
  success: true,
  data: { id: 1, name: 'John', email: 'john@example.com' }
};
```

### **2. ページネーション型テンプレート**

```typescript
interface PaginationMeta {
  page: number;
  limit: number;
  total: number;
  totalPages: number;
  hasMore: boolean;
  hasPrevious: boolean;
}

interface PaginatedResponse<T> {
  success: true;
  data: T[];
  meta: PaginationMeta;
}

// 使用例
interface Post {
  id: number;
  title: string;
  content: string;
}

const postsResponse: PaginatedResponse<Post> = {
  success: true,
  data: [
    { id: 1, title: 'Post 1', content: 'Content 1' },
    { id: 2, title: 'Post 2', content: 'Content 2' }
  ],
  meta: {
    page: 1,
    limit: 10,
    total: 25,
    totalPages: 3,
    hasMore: true,
    hasPrevious: false
  }
};
```

## 🔐 認証・認可型テンプレート

### **認証関連型**

```typescript
// ユーザー基本情報
interface BaseUser {
  id: number;
  email: string;
  username: string;
  name: string;
  role: UserRole;
  createdAt: Date;
  updatedAt: Date;
}

// ユーザー役割
type UserRole = 'user' | 'admin' | 'moderator';

// 認証コンテキスト
interface AuthContext {
  userId: number;
  email?: string;
  role?: UserRole;
}

// JWTペイロード
interface JWTPayload {
  sub: string;
  userId: number;
  email: string;
  role: UserRole;
  iat: number;
  exp: number;
}

// ログイン要求・応答
interface LoginRequest {
  emailOrUsername: string;
  password: string;
}

interface LoginResponse {
  token: string;
  refreshToken: string;
  user: Omit<BaseUser, 'password'>;
  expiresIn: string;
}

// サインアップ要求
interface SignupRequest {
  email: string;
  username: string;
  password: string;
  name?: string;
}
```

### **権限管理型**

```typescript
// 権限レベル
type Permission = 
  | 'read'
  | 'write'
  | 'delete'
  | 'admin'
  | 'moderate';

// リソース型
type ResourceType = 
  | 'user'
  | 'post'
  | 'comment'
  | 'quiz'
  | 'study_log';

// 権限チェック用
interface PermissionCheck {
  userId: number;
  resource: ResourceType;
  action: Permission;
  resourceId?: number;
}
```

## 📚 学習・クイズ関連型テンプレート

### **学習記録型**

```typescript
// 学習記録エントリ
interface StudyLogEntry {
  id?: number;
  userId: number;
  date: Date;
  subject: string;
  topics: string[];
  studyTime: number; // minutes
  understanding: StudyUnderstanding;
  memo?: string;
  efficiency?: number;
  createdAt?: Date;
  updatedAt?: Date;
}

// 理解度レベル
type StudyUnderstanding = 1 | 2 | 3 | 4 | 5;

// 学習統計
interface StudyStats {
  totalStudyTime: number;
  averageStudyTime: number;
  studyFrequency: number;
  consistencyScore: number;
  strongSubjects: string[];
  weakSubjects: string[];
}

// 学習進捗更新要求
interface StudyProgressUpdate {
  weekNumber: number;
  dayIndex: number;
  actualTime?: number;
  understanding?: StudyUnderstanding;
  memo?: string;
  completed?: boolean;
}
```

### **クイズ・問題型**

```typescript
// 問題定義
interface Question {
  id: string;
  category: string;
  subcategory?: string;
  question: string;
  choices: string[];
  correctAnswer: string;
  explanation: string;
  difficulty: QuestionDifficulty;
  year: number;
  section: string;
  tags?: string[];
}

// 問題難易度
type QuestionDifficulty = 1 | 2 | 3 | 4 | 5;

// クイズセッション
interface QuizSession {
  id: number;
  userId: number;
  sessionType: QuizSessionType;
  category?: string;
  totalQuestions: number;
  correctAnswers: number;
  score: number;
  totalTime: number; // seconds
  avgTimePerQ: number;
  isCompleted: boolean;
  startedAt: Date;
  completedAt?: Date;
}

// セッション種別
type QuizSessionType = 
  | 'practice'
  | 'exam'
  | 'review'
  | 'category'
  | 'random'
  | 'weak_points';

// ユーザー回答
interface UserAnswer {
  id?: number;
  userId: number;
  questionId: string;
  userAnswer: string;
  isCorrect: boolean;
  timeSpent?: number;
  createdAt: Date;
}

// クイズ開始要求
interface StartQuizRequest {
  category?: string;
  sessionType: QuizSessionType;
  questionCount: number;
}

// 回答提出要求
interface SubmitAnswerRequest {
  sessionId: number;
  questionId: string;
  userAnswer: string;
  timeSpent?: number;
}
```

## 📊 分析・統計型テンプレート

### **学習分析型**

```typescript
// 分析結果
interface AnalysisResult {
  id?: number;
  userId: number;
  analysisDate: Date;
  overallScore: number;
  studyPattern: StudyPattern;
  weaknessAnalysis: WeaknessAnalysis;
  studyRecommendation: StudyRecommendation;
  createdAt?: Date;
}

// 学習パターン
interface StudyPattern {
  optimalTimeSlot?: string;
  optimalDayOfWeek?: string;
  averageSessionLength: number;
  preferredCategories: string[];
  studyConsistency: number;
}

// 弱点分析
interface WeaknessAnalysis {
  overallWeakness: number;
  weakAreas: string[];
  improvementPotential: number;
}

// 学習推奨
interface StudyRecommendation {
  summary: string;
  strongAreas: string[];
  focusAreas: string[];
  dailyStudyTime: number;
  weeklyGoals: string[];
}

// 予測結果
interface PredictionResult {
  id?: number;
  userId: number;
  predictionDate: Date;
  examDate: Date;
  passProbability: PassProbability;
  examReadiness: ExamReadiness;
  studyTimePrediction: StudyTimePrediction;
  modelVersion: string;
  scorePrediction: ScorePrediction;
}

// 合格確率
interface PassProbability {
  overall: number;
  byCategory: Record<string, number>;
  confidence: number;
}

// 試験準備度
interface ExamReadiness {
  currentReadiness: number;
  targetReadiness: number;
  daysRemaining: number;
  readinessTrend: 'improving' | 'stable' | 'declining';
}

// 学習時間予測
interface StudyTimePrediction {
  totalHoursNeeded: number;
  dailyHoursRecommended: number;
  byCategory: Record<string, number>;
}

// スコア予測
interface ScorePrediction {
  expectedScore: number;
  confidenceInterval: {
    lower: number;
    upper: number;
  };
  byCategory: Record<string, number>;
}
```

## 🛠️ Hono フレームワーク関連型

### **Hono コンテキスト型**

```typescript
// Variables型定義（認証用）
export type Variables = {
  authUser: AuthContext;
};

// Honoアプリケーション型
type HonoApp = Hono<{ Variables: Variables }>;

// ルートハンドラー型
type RouteHandler = (c: Context<{ Variables: Variables }>) => Promise<Response> | Response;

// バリデーション済みコンテキスト型
interface ValidatedContext<T> extends Context<{ Variables: Variables }> {
  req: {
    valid: (target: 'json' | 'query' | 'param') => T;
  } & Request;
}
```

### **ミドルウェア型**

```typescript
// 認証ミドルウェアコンテキスト
interface AuthMiddlewareContext {
  token?: string;
  user?: AuthContext;
}

// エラーハンドリング用
interface ErrorContext {
  error: Error;
  request: Request;
  requestId?: string;
}
```

## 🔧 ユーティリティ型テンプレート

### **汎用的なユーティリティ型**

```typescript
// レスポンスビルダー用
interface ResponseBuilder {
  success<T>(data: T, message?: string): ApiResponse<T>;
  error(message: string, errorCode: string, details?: Record<string, unknown>): ApiError;
}

// データベース操作結果型
interface DbResult<T> {
  success: boolean;
  data?: T;
  error?: string;
  rowsAffected?: number;
}

// ファイル操作型
interface FileUpload {
  filename: string;
  mimetype: string;
  size: number;
  buffer: Buffer;
}

// 設定型
interface AppConfig {
  port: number;
  environment: 'development' | 'production' | 'test';
  database: {
    url: string;
    maxConnections: number;
  };
  jwt: {
    secret: string;
    expiresIn: string;
  };
  cors: {
    origin: string | string[];
    credentials: boolean;
  };
}
```

## 🎯 使用時のベストプラクティス

### **1. 型定義の命名規則**

```typescript
// インターフェース: PascalCase
interface UserProfile { }
interface ApiResponse<T> { }

// 型エイリアス: PascalCase
type UserRole = 'admin' | 'user';
type DatabaseResult<T> = Promise<T | null>;

// 列挙型: PascalCase
enum ResponseStatus {
  SUCCESS = 'success',
  ERROR = 'error',
  PENDING = 'pending'
}
```

### **2. ジェネリクス活用**

```typescript
// 再利用可能な型定義
interface Repository<T> {
  findById(id: number): Promise<T | null>;
  findMany(filter?: Partial<T>): Promise<T[]>;
  create(data: Omit<T, 'id'>): Promise<T>;
  update(id: number, data: Partial<T>): Promise<T>;
  delete(id: number): Promise<boolean>;
}

// 使用例
const userRepository: Repository<User> = new UserRepositoryImpl();
const postRepository: Repository<Post> = new PostRepositoryImpl();
```

### **3. 型ガード関数**

```typescript
// 型安全な型チェック
function isApiError(response: unknown): response is ApiError {
  return typeof response === 'object' && 
         response !== null && 
         'success' in response && 
         (response as any).success === false;
}

// 使用例
const response = await fetchData();
if (isApiError(response)) {
  console.error(response.error);
} else {
  console.log(response.data);
}
```

このテンプレート集を参考にして、ClaudeCodeでの開発時に適切な型定義を使用し、`any`型を完全に避けた型安全なコードを書いてください。