# Commit Changes

Analyze branch changes and create appropriate commit message based on detected modifications.

## Important Project Rules

**CRITICAL**: このプロジェクトでは Claude Code 署名を含めない
- 🤖 Generated with [Claude Code] を除外する
- Co-Authored-By: Claude を除外する
- Conventional Commits形式を使用する

## Usage

```bash
/commit [optional: base-branch] [optional: --format=single|multi]
```

Default base branch: `main`
Format options:

- `single`: Single comprehensive commit message (default)
- `multi`: Multiple commit messages for each change category

## Command

```bash
Analyze current branch changes and suggest commit message:

1. Change Detection:
   - git status (staged and unstaged changes)
   - git diff --cached (staged changes)
   - git diff (unstaged changes)
   - git diff ${1:main}..$(git branch --show-current) --name-only
   - git diff ${1:main}..$(git branch --show-current) --stat
   - git log --oneline ${1:main}..$(git branch --show-current)

2. Change Categorization:
   - New features (feat:)
   - Bug fixes (fix:)
   - Documentation (docs:)
   - Code style/formatting (style:)
   - Refactoring (refactor:)
   - Performance improvements (perf:)
   - Tests (test:)
   - Build/CI changes (build:, ci:)
   - Chores (chore:)

3. Impact Analysis:
   - Scope identification (controller, service, repository, etc.)
   - Breaking changes detection
   - Dependencies affected
   - Uncommitted changes integration

4. Commit Message Generation:
   - Conventional Commits format
   - Clear, concise description
   - Optional body with detailed changes
   - Optional footer with breaking changes
   - **IMPORTANT**: Claude Code署名（🤖 Generated with [Claude Code] および Co-Authored-By: Claude）は絶対に除外する

5. Format Selection:
   - Single format: One comprehensive commit covering all changes
   - Multi format: Separate commits for each logical change group with specific file paths

6. File Path Analysis (Multi format only):
   - Group changed files by commit category
   - Provide specific git add commands for each commit
   - Consider file dependencies and logical grouping

Base branch: ${1:main}
Current branch: $(git branch --show-current)
Format: ${2:single} (single|multi)

Based on format selection:

**Single format (default):**
- One comprehensive commit message covering all changes
- Consolidated description with bullet points for major changes

**Multi format:**
- Separate commit messages for each logical change group
- Individual commits for: features, fixes, docs, tests, chores
- Suggested commit sequence with dependencies
- Specific file paths to add for each commit

Please provide:
- Suggested commit message(s) based on selected format (WITHOUT Claude Code signatures)
- Alternative commit message options
- Rationale for the suggested approach
- Scope and impact summary
- Integration of uncommitted changes with branch changes
- For multi format: Specific file paths and git add commands for each commit
```

## Expected Output

**Single format:**

- Primary comprehensive commit message (NO Claude signatures)
- 2-3 alternative consolidated options
- Explanation of categorization logic
- Scope and impact assessment

**Multi format:**

- Sequence of individual commit messages (NO Claude signatures)
- Logical grouping rationale
- Dependency order recommendations
- Individual commit impact analysis
- Specific file paths for each commit with git add commands

**Both formats:**

- Combined analysis of branch changes and uncommitted files
- Conventional commits compliance
- NO Claude Code signatures in any commit messages