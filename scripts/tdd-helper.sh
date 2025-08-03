#!/bin/bash

# TDD Helper Script for AP Study Project
# Usage: ./scripts/tdd-helper.sh <command> <feature-name>

set -e

FEATURE_NAME=$2
BACKEND_DIR="ap-study-backend"
FRONTEND_DIR="ap-study-app"

case $1 in
  "init")
    if [ -z "$FEATURE_NAME" ]; then
      echo "Usage: ./scripts/tdd-helper.sh init <feature-name>"
      exit 1
    fi
    
    echo "🧪 TDD初期化: $FEATURE_NAME"
    
    # バックエンドテストファイル作成
    mkdir -p $BACKEND_DIR/src/__tests__
    cat > $BACKEND_DIR/src/__tests__/${FEATURE_NAME}.test.ts << EOF
// TDD Red Phase: $FEATURE_NAME
import { describe, it, expect, beforeEach } from 'vitest'
import { ${FEATURE_NAME}UseCase } from '../domain/usecases/${FEATURE_NAME}'
import { I${FEATURE_NAME}Repository } from '../domain/repositories/I${FEATURE_NAME}Repository'

describe('${FEATURE_NAME}UseCase', () => {
  let useCase: ${FEATURE_NAME}UseCase
  let mockRepository: I${FEATURE_NAME}Repository

  beforeEach(() => {
    mockRepository = {
      // TODO: Add repository methods
    } as I${FEATURE_NAME}Repository
    useCase = new ${FEATURE_NAME}UseCase(mockRepository)
  })

  it('should fail initially (Red phase)', () => {
    // TODO: Add failing test for $FEATURE_NAME
    expect(false).toBe(true) // Intentional failure
  })

  it('should handle main functionality', async () => {
    // TODO: Add main functionality test
    expect(useCase).toBeDefined()
  })
})
EOF

    echo "✅ テストファイル作成: $BACKEND_DIR/src/__tests__/${FEATURE_NAME}.test.ts"
    ;;

  "generate")
    if [ -z "$FEATURE_NAME" ]; then
      echo "Usage: ./scripts/tdd-helper.sh generate <feature-name>"
      exit 1
    fi
    
    echo "🏗️ TDD実装生成: $FEATURE_NAME"
    
    # 1. エンティティ作成
    mkdir -p $BACKEND_DIR/src/domain/entities
    cat > $BACKEND_DIR/src/domain/entities/${FEATURE_NAME}.ts << EOF
// Domain Entity: $FEATURE_NAME
export interface ${FEATURE_NAME} {
  id: string
  createdAt: Date
  updatedAt: Date
  // TODO: Add specific properties for $FEATURE_NAME
}

export interface Create${FEATURE_NAME}Input {
  // TODO: Add input properties for creating $FEATURE_NAME
}

export interface Update${FEATURE_NAME}Input {
  // TODO: Add input properties for updating $FEATURE_NAME
}
EOF

    # 2. リポジトリインターフェース作成
    mkdir -p $BACKEND_DIR/src/domain/repositories
    cat > $BACKEND_DIR/src/domain/repositories/I${FEATURE_NAME}Repository.ts << EOF
// Repository Interface: $FEATURE_NAME
import { ${FEATURE_NAME}, Create${FEATURE_NAME}Input, Update${FEATURE_NAME}Input } from '../entities/${FEATURE_NAME}'

export interface I${FEATURE_NAME}Repository {
  findById(id: string): Promise<${FEATURE_NAME} | null>
  findAll(): Promise<${FEATURE_NAME}[]>
  create(input: Create${FEATURE_NAME}Input): Promise<${FEATURE_NAME}>
  update(id: string, input: Update${FEATURE_NAME}Input): Promise<${FEATURE_NAME}>
  delete(id: string): Promise<void>
}
EOF

    # 3. ユースケース作成
    mkdir -p $BACKEND_DIR/src/domain/usecases
    cat > $BACKEND_DIR/src/domain/usecases/${FEATURE_NAME}.ts << EOF
// Use Case: $FEATURE_NAME
import { ${FEATURE_NAME}, Create${FEATURE_NAME}Input, Update${FEATURE_NAME}Input } from '../entities/${FEATURE_NAME}'
import { I${FEATURE_NAME}Repository } from '../repositories/I${FEATURE_NAME}Repository'

export class ${FEATURE_NAME}UseCase {
  constructor(private repository: I${FEATURE_NAME}Repository) {}

  async get${FEATURE_NAME}ById(id: string): Promise<${FEATURE_NAME} | null> {
    return await this.repository.findById(id)
  }

  async getAll${FEATURE_NAME}s(): Promise<${FEATURE_NAME}[]> {
    return await this.repository.findAll()
  }

  async create${FEATURE_NAME}(input: Create${FEATURE_NAME}Input): Promise<${FEATURE_NAME}> {
    // TODO: Add business logic validation
    return await this.repository.create(input)
  }

  async update${FEATURE_NAME}(id: string, input: Update${FEATURE_NAME}Input): Promise<${FEATURE_NAME}> {
    // TODO: Add business logic validation
    const existing = await this.repository.findById(id)
    if (!existing) {
      throw new Error(\`${FEATURE_NAME} with id \${id} not found\`)
    }
    return await this.repository.update(id, input)
  }

  async delete${FEATURE_NAME}(id: string): Promise<void> {
    const existing = await this.repository.findById(id)
    if (!existing) {
      throw new Error(\`${FEATURE_NAME} with id \${id} not found\`)
    }
    await this.repository.delete(id)
  }
}
EOF

    # 4. Prismaリポジトリ実装作成
    mkdir -p $BACKEND_DIR/src/infrastructure/database/repositories
    cat > $BACKEND_DIR/src/infrastructure/database/repositories/${FEATURE_NAME}Repository.ts << EOF
// Prisma Repository Implementation: $FEATURE_NAME
import { PrismaClient } from '@prisma/client'
import { ${FEATURE_NAME}, Create${FEATURE_NAME}Input, Update${FEATURE_NAME}Input } from '../../../domain/entities/${FEATURE_NAME}'
import { I${FEATURE_NAME}Repository } from '../../../domain/repositories/I${FEATURE_NAME}Repository'

export class ${FEATURE_NAME}Repository implements I${FEATURE_NAME}Repository {
  constructor(private prisma: PrismaClient) {}

  async findById(id: string): Promise<${FEATURE_NAME} | null> {
    // TODO: Add Prisma query
    return null
  }

  async findAll(): Promise<${FEATURE_NAME}[]> {
    // TODO: Add Prisma query
    return []
  }

  async create(input: Create${FEATURE_NAME}Input): Promise<${FEATURE_NAME}> {
    // TODO: Add Prisma create query
    throw new Error('Not implemented')
  }

  async update(id: string, input: Update${FEATURE_NAME}Input): Promise<${FEATURE_NAME}> {
    // TODO: Add Prisma update query
    throw new Error('Not implemented')
  }

  async delete(id: string): Promise<void> {
    // TODO: Add Prisma delete query
    throw new Error('Not implemented')
  }
}
EOF

    # 5. API Routes作成
    mkdir -p $BACKEND_DIR/src/infrastructure/web/routes
    cat > $BACKEND_DIR/src/infrastructure/web/routes/${FEATURE_NAME,,}.ts << EOF
// API Routes: $FEATURE_NAME
import { Hono } from 'hono'
import { ${FEATURE_NAME}UseCase } from '../../../domain/usecases/${FEATURE_NAME}'

export function create${FEATURE_NAME}Routes(useCase: ${FEATURE_NAME}UseCase) {
  const router = new Hono()

  // GET /${FEATURE_NAME,,}s
  router.get('/', async (c) => {
    try {
      const items = await useCase.getAll${FEATURE_NAME}s()
      return c.json({ success: true, data: items })
    } catch (error) {
      return c.json({ success: false, error: error.message }, 500)
    }
  })

  // GET /${FEATURE_NAME,,}s/:id
  router.get('/:id', async (c) => {
    try {
      const id = c.req.param('id')
      const item = await useCase.get${FEATURE_NAME}ById(id)
      if (!item) {
        return c.json({ success: false, error: '${FEATURE_NAME} not found' }, 404)
      }
      return c.json({ success: true, data: item })
    } catch (error) {
      return c.json({ success: false, error: error.message }, 500)
    }
  })

  // POST /${FEATURE_NAME,,}s
  router.post('/', async (c) => {
    try {
      const body = await c.req.json()
      const item = await useCase.create${FEATURE_NAME}(body)
      return c.json({ success: true, data: item }, 201)
    } catch (error) {
      return c.json({ success: false, error: error.message }, 500)
    }
  })

  // PUT /${FEATURE_NAME,,}s/:id
  router.put('/:id', async (c) => {
    try {
      const id = c.req.param('id')
      const body = await c.req.json()
      const item = await useCase.update${FEATURE_NAME}(id, body)
      return c.json({ success: true, data: item })
    } catch (error) {
      return c.json({ success: false, error: error.message }, 500)
    }
  })

  // DELETE /${FEATURE_NAME,,}s/:id
  router.delete('/:id', async (c) => {
    try {
      const id = c.req.param('id')
      await useCase.delete${FEATURE_NAME}(id)
      return c.json({ success: true })
    } catch (error) {
      return c.json({ success: false, error: error.message }, 500)
    }
  })

  return router
}
EOF

    echo "✅ クリーンアーキテクチャ実装生成完了:"
    echo "   - Entity: $BACKEND_DIR/src/domain/entities/${FEATURE_NAME}.ts"
    echo "   - Repository I/F: $BACKEND_DIR/src/domain/repositories/I${FEATURE_NAME}Repository.ts"
    echo "   - Use Case: $BACKEND_DIR/src/domain/usecases/${FEATURE_NAME}.ts"
    echo "   - Prisma Repo: $BACKEND_DIR/src/infrastructure/database/repositories/${FEATURE_NAME}Repository.ts"
    echo "   - API Routes: $BACKEND_DIR/src/infrastructure/web/routes/${FEATURE_NAME,,}.ts"
    echo ""
    echo "📝 次のステップ:"
    echo "   1. Prismaスキーマにモデル追加"
    echo "   2. テストの具体的な実装"
    echo "   3. ビジネスロジックの詳細実装"
    ;;

  "red")
    echo "🔴 TDD Red Phase: テスト実行"
    cd $BACKEND_DIR
    npm run tdd:red
    ;;

  "green")
    echo "🟢 TDD Green Phase: 最小実装確認"
    cd $BACKEND_DIR
    npm run tdd:green
    ;;

  "refactor")
    echo "🔵 TDD Refactor Phase: コード品質向上"
    cd $BACKEND_DIR
    npm run tdd:refactor
    ;;

  "cycle")
    echo "🔄 TDD Full Cycle: Red → Green → Refactor"
    cd $BACKEND_DIR
    npm run tdd:cycle
    ;;

  "status")
    echo "📊 TDD Status Check"
    echo "Backend tests:"
    cd $BACKEND_DIR && npm test 2>/dev/null || echo "❌ Tests failing"
    echo "Frontend tests:"
    cd ../$FRONTEND_DIR && npm run test:run 2>/dev/null || echo "❌ Tests failing"
    ;;

  *)
    echo "🧪 TDD Helper Commands:"
    echo "  init <feature>     - TDD初期化（テストファイル作成）"
    echo "  generate <feature> - クリーンアーキテクチャ実装生成"
    echo "  red               - Red Phase（失敗テスト実行）"
    echo "  green             - Green Phase（最小実装確認）"
    echo "  refactor          - Refactor Phase（品質向上）"
    echo "  cycle             - Full Cycle（Red→Green→Refactor）"
    echo "  status            - 現在のテスト状況確認"
    echo ""
    echo "TDD Workflow Example:"
    echo "  ./scripts/tdd-helper.sh init StudyLogCreation"
    echo "  ./scripts/tdd-helper.sh generate StudyLogCreation"
    echo "  ./scripts/tdd-helper.sh red"
    echo "  ./scripts/tdd-helper.sh green"
    echo "  ./scripts/tdd-helper.sh refactor"
    echo ""
    echo "Generated Files (for StudyLogCreation):"
    echo "  ├── src/__tests__/StudyLogCreation.test.ts"
    echo "  ├── src/domain/entities/StudyLogCreation.ts"
    echo "  ├── src/domain/repositories/IStudyLogCreationRepository.ts"
    echo "  ├── src/domain/usecases/StudyLogCreation.ts"
    echo "  ├── src/infrastructure/database/repositories/StudyLogCreationRepository.ts"
    echo "  └── src/infrastructure/web/routes/studylogcreation.ts"
    ;;
esac