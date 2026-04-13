# 技術仕様書: Claude Dev Skills

## 1. アーキテクチャ概要

### スキルシステム構成

各スキルは独立した `SKILL.md` ファイルとして定義される。Claude Code のスキル機能により、YAMLフロントマター + Markdownプロンプトの形式で動作を制御する。

```
claude-dev-skills/
├── skills/
│   ├── orchestrator/
│   │   └── SKILL.md
│   ├── create-spec/
│   │   └── SKILL.md
│   ├── create-tests/
│   │   └── SKILL.md
│   ├── implement-code/
│   │   └── SKILL.md
│   ├── review-implements/
│   │   └── SKILL.md
│   └── create-pr/
│       └── SKILL.md
├── docs/
│   └── prd.md
│   └── spec.md
│   └── plan.md
│   └── tasks.md
└── README.md
```

### インストール方法

ユーザーはこのリポジトリをクローンまたはシンボリックリンクで `~/.claude/skills/` に配置する:

```bash
# 方法1: シンボリックリンク（推奨）
git clone <repo-url> ~/claude-dev-skills
ln -s ~/claude-dev-skills/skills/* ~/.claude/skills/

# 方法2: プロジェクト固有
cp -r skills/* <project>/.claude/skills/
```

## 2. SKILL.md フロントマター仕様

各スキルの `SKILL.md` は以下のフロントマター構造を持つ:

```yaml
---
name: <スキル名>
description: <スキルの説明 — Claudeがいつ使うか判断する文>
user-invocable: true
allowed-tools: <使用可能なツール>
---
```

### スキル別フロントマター定義

#### orchestrator

```yaml
---
name: orchestrator
description: >
  開発フロー全体（仕様→テスト→実装→レビュー→PR）を自動オーケストレーションする。
  ユーザーの入力とプロジェクト状態から開始ポイントを判定し、実行計画を確認後、全自動で実行する。
  トリガー: "作って", "開発して", "機能を追加して", "実装して欲しい", "これ作れる？"
user-invocable: true
allowed-tools: Read Grep Glob Bash Write Edit Agent
---
```

#### create-spec

```yaml
---
name: create-spec
description: >
  Create project documents (PRD, spec, plan, tasks) from user requirements.
  Use when starting a new feature, planning implementation, or documenting requirements.
  Triggers: "仕様書を作って", "PRDを書いて", "設計して", "要件を整理して"
user-invocable: true
allowed-tools: Read Grep Glob Bash Write Edit Agent
---
```

#### create-tests

```yaml
---
name: create-tests
description: >
  Generate test code from specifications (TDD Red Phase).
  Use when creating tests before implementation, adding test coverage, or starting TDD workflow.
  Triggers: "テストを書いて", "テストを生成して", "TDDで始めて", "テストカバレッジを追加"
user-invocable: true
allowed-tools: Read Grep Glob Bash Write Edit Agent
---
```

#### implement-code

```yaml
---
name: implement-code
description: >
  Implement code to pass existing tests (TDD Green→Refactor Phase).
  Use when implementing features after tests are written, fixing failing tests, or applying review feedback.
  Triggers: "実装して", "テストを通して", "レビュー指摘を修正して", "Greenにして"
user-invocable: true
allowed-tools: Read Grep Glob Bash Write Edit Agent
---
```

#### review-implements

```yaml
---
name: review-implements
description: >
  Review implementation code for quality, spec compliance, and test coverage.
  Use when code review is needed, checking implementation quality, or validating against specifications.
  Triggers: "レビューして", "コードを確認して", "品質チェックして"
user-invocable: true
allowed-tools: Read Grep Glob Bash Write Edit Agent
---
```

#### create-pr

```yaml
---
name: create-pr
description: >
  Create a GitHub Pull Request from implementation with auto-generated title, body, labels, and reviewers.
  Use when implementation and review are complete and ready to submit a PR.
  Triggers: "PRを作って", "プルリクを出して", "PR作成して"
user-invocable: true
allowed-tools: Read Grep Glob Bash Write Edit Agent
---
```

## 3. スキル別プロンプト仕様

### 3.0 orchestrator スキル（メタスキル）

5つの個別スキルを自動的に連携・実行するオーケストレーションスキル。詳細は `skills/orchestrator/SKILL.md` を参照。

**主な機能:**
- プロジェクト状態の分析（仕様書/テスト/実装/レビューの有無 + テスト実行結果）
- 開始ポイントの自動判定（6パターン）
- 実行計画のユーザー確認
- フローの自動実行（確認ポイントを明示した上で自動進行）
- レビュー指摘の適切な分岐（テスト不足→create-tests、コード不備→implement-code）
- 中断・再開対応（tasks.mdの進捗から再開ポイントを自動判定）


### 3.1 create-spec スキル

#### モード判定ロジック

```
IF docs/prd.md OR docs/spec.md OR docs/plan.md OR docs/tasks.md が存在する
  → 差分更新モード
ELSE
  → 新規作成モード
```

#### 新規作成モード手順

1. ユーザーの要望を受け取る（`$ARGUMENTS` または対話）
2. 既存プロジェクトかどうかを判定:
   - ソースコードが存在する → 既存プロジェクト
   - 空またはスキャフォールドのみ → 新規プロジェクト
3. 既存プロジェクトの場合:
   - ディレクトリ構造を調査（`ls`, `find`）
   - 主要な設定ファイルを読む（→ 技術スタック検出）
   - 既存テストのスタイルを分析
4. ドキュメント生成順序:
   1. `docs/prd.md` — 要件定義
   2. `docs/spec.md` — 技術仕様（API設計、データモデル、処理フロー等）
   3. `docs/plan.md` — 実装計画（アーキテクチャ決定、技術選定理由）
   4. `docs/tasks.md` — タスク一覧（→ タスク分解仕様に準拠）
5. 各ドキュメント生成後、ユーザーに確認を求める

#### 差分更新モード手順

1. 既存ドキュメント4点を全て読み込む
2. ユーザーの変更要望をヒアリング
3. 影響範囲を分析:
   - PRDの変更 → spec, plan, tasks への波及を判定
   - specの変更 → plan, tasks への波及を判定
4. 変更対象ドキュメントを更新
5. 各ドキュメントの末尾に変更履歴を追記:
   ```markdown
   ## 変更履歴
   - YYYY-MM-DD: 変更内容の要約（変更理由）
   ```
6. ユーザーに差分を提示し確認

#### タスク分解仕様

`docs/tasks.md` のフォーマット:

```markdown
# タスク一覧

## セットアップタスク

- [ ] タスク名
  - 概要: タスクの説明

## 実装タスク

- [ ] タスク名（テストファイルパス）
  - 依存: 依存タスク名（あれば）
  - 概要: タスクの説明
```

粒度ルール:
- 1タスク = 1つの論理的な機能単位（基本的に1テストファイルに対応）
- テストファイルが大きくなる場合は describe/context 単位で分割
- 依存関係に循環がないことを確認する（A→B→C→A のような循環を検出したらユーザーに警告）
- 1タスク = 1コミット

### 3.2 create-tests スキル

#### 技術スタック検出ロジック

以下の優先順で検出する:

**Step 1: 設定ファイルから検出**

| ファイル | 言語 | テストFW検出方法 |
|---------|------|----------------|
| `package.json` | Node.js/TypeScript | `devDependencies` から jest/vitest/mocha 等を検索 |
| `tsconfig.json` | TypeScript | 上記と組み合わせ |
| `pyproject.toml` | Python | `[tool.pytest]` や `[project.optional-dependencies]` から検出 |
| `setup.py` / `setup.cfg` | Python | `tests_require` から検出 |
| `requirements.txt` / `requirements-dev.txt` | Python | pytest 等の記載を検索 |
| `Gemfile` | Ruby | rspec/minitest の記載を検索 |
| `go.mod` | Go | 標準 testing パッケージ（設定ファイル不要） |
| `Cargo.toml` | Rust | 標準テスト機能（設定ファイル不要） |
| `build.gradle` / `build.gradle.kts` | Java/Kotlin | JUnit/Kotest の依存を検索 |
| `pom.xml` | Java | JUnit の依存を検索 |
| `composer.json` | PHP | `require-dev` から PHPUnit 等を検索 |
| `Package.swift` | Swift | XCTest（標準） |

**Step 2: 既存テストファイルから検出**

既存テストのパターンを分析:
- ディレクトリ: `tests/`, `test/`, `__tests__/`, `spec/`, ソースと同階層
- ファイル命名: `*_test.go`, `*.test.ts`, `*.test.tsx`, `*_spec.rb`, `test_*.py`, `*Test.java`
- テストヘルパー・フィクスチャの使用パターン
- セットアップ/ティアダウンのパターン（beforeEach, setUp, before 等）
- アサーションスタイル（expect/assert/should 等）

**Step 3: フォールバック**

検出できない場合、ユーザーに以下を質問:
- 使用言語
- テストフレームワーク
- テストディレクトリの配置

#### テスト実行コマンド検出

| 検出元 | コマンド |
|--------|---------|
| `package.json` の `scripts.test` | `npm test` / `yarn test` |
| `Makefile` の `test` ターゲット | `make test` |
| Python + pytest | `pytest` |
| Python + unittest | `python -m unittest` |
| Go | `go test ./...` |
| Ruby + rspec | `bundle exec rspec` |
| Ruby + minitest | `bundle exec rake test` |
| Rust | `cargo test` |
| Java + Gradle | `./gradlew test` |
| Java + Maven | `mvn test` |
| PHP + PHPUnit | `./vendor/bin/phpunit` |
| Swift | `swift test` |

検出できない場合はユーザーに確認する。

#### テストコード生成手順

1. 仕様書（`docs/spec.md`）を読み込む（存在しない場合はユーザーの口頭仕様を使用）
2. 技術スタックを検出
3. 既存テストがある場合、スタイルを分析:
   - ディレクトリ構造
   - ファイル命名規則
   - テストヘルパー/フィクスチャの使用
   - セットアップ/ティアダウンのパターン
   - アサーションスタイル
4. `docs/tasks.md` のタスク一覧を参照し、タスクごとにテストケースを設計:
   - 正常系: 期待される入出力の検証
   - 異常系: エラー条件・バリデーション失敗の検証
   - エッジケース: 境界値・空入力・大量データ等
5. テストコードを生成（ファイル配置ルールに従う）
6. テストを実行:
   - 全てFailする → 正常（Red Phase完了）
   - 一部Passする → 実装が既存の可能性を警告、テストの妥当性を再検討
   - 実行自体が失敗（構文エラー等） → 修正して再実行

#### ファイル配置ルール

1. 既存テストディレクトリが存在する → そのディレクトリに合わせる
2. 既存テストがない場合 → 言語のデフォルト構成を提案しユーザーに確認:
   - Node.js: `__tests__/` or `src/**/*.test.ts`
   - Python: `tests/`
   - Go: ソースと同階層 `*_test.go`
   - Ruby: `spec/` (rspec) or `test/` (minitest)
   - Rust: ソース内 `#[cfg(test)]` or `tests/`
   - Java: `src/test/java/`
3. テストファイルの命名は既存パターンに従う

### 3.3 implement-code スキル

#### 実装手順

1. 入力を読み込む:
   - `docs/spec.md`（存在すれば）
   - `docs/tasks.md`（存在すれば）
   - テストコード
   - `docs/review-report.md`（レビュー指摘反映モードの場合）
2. `docs/tasks.md` から未完了タスクを依存順に取得
3. タスクごとに以下を実行:
   a. 対応するテストファイルを読む
   b. テストが期待する振る舞いを分析
   c. 既存コードがある場合、設計パターンに準拠して実装
   d. テストが通る最小限のコードを実装（Green）
   e. テスト実行 → 全Pass確認
   f. リファクタリング（重複排除、命名改善、構造整理）
   g. テスト再実行 → 全Pass維持
   h. `docs/tasks.md` のチェックボックスを `[x]` に更新
   i. コミット: `<prefix>: <タスク名>`

#### コミット戦略

- ブランチ作成・切り替えは行わない（ユーザーが事前に準備）
- Conventional Commits プレフィックス:
  - 新機能: `feat: <タスク名>`
  - バグ修正: `fix: <タスク名>`
  - リファクタリング: `refactor: <タスク名>`
  - テスト: `test: <タスク名>`
  - ドキュメント: `docs: <タスク名>`
- プレフィックスはタスクの性質から自動判定

#### レビュー指摘反映モード

`docs/review-report.md` が存在し、ユーザーが「レビュー指摘を修正して」等と指示した場合:

1. `docs/review-report.md` を読み込む
2. `[Critical]` と `[Warning]` の指摘を抽出
3. 指摘ごとに:
   a. 対象ファイル・行番号を特定
   b. 改善案に基づいて修正を適用
   c. テスト実行 → 全Pass確認
4. 全指摘の修正後にコミット: `fix: レビュー指摘の修正`
5. `docs/review-report.md` は上書きしない（次の `review` で再生成される）

#### 異常系フロー

テストがPassしない場合の段階的アプローチ:

1. **直接修正**: エラーメッセージを分析し、直接的な修正を適用
2. **アプローチ見直し**: 仕様書を再確認し、実装アプローチを根本から見直す
3. **ユーザー判断**: テスト自体の妥当性を検証し、テストが不適切な可能性も含めてユーザーに判断を仰ぐ

各段階でテストを再実行し、Passすれば次のタスクに進む。3段階を経てもPassしない場合はユーザーに報告し、タスクをスキップするか対応を相談する。

### 3.4 review-implements スキル

#### レビュー手順

1. 入力を読み込む:
   - `docs/spec.md`（存在すれば）
   - `docs/tasks.md`（存在すれば）
   - テストコード
   - 実装コード
   - `git diff` で変更差分を確認
2. レビュー観点ごとに検査:

| 観点 | 検査内容 |
|------|---------|
| 仕様適合性 | spec.mdの要件が全て実装されているか。未実装の要件がないか |
| テストカバレッジ | 正常系・異常系・エッジケースが網羅されているか。テストが仕様の要件をカバーしているか |
| コード品質 | 可読性（命名、コメント）、保守性（関数分割、責務分離）、DRY原則 |
| セキュリティ | 入力バリデーション、SQLインジェクション、XSS、認証・認可、機密情報の露出 |
| パフォーマンス | N+1クエリ、不要なループ、メモリリーク、大量データ処理 |
| 既存コードとの一貫性 | 命名規則、設計パターン、ディレクトリ構成、コーディングスタイル |

3. 指摘を重要度で分類:
   - `[Critical]`: 機能不全・セキュリティ脆弱性・データ損失リスク → 修正必須
   - `[Warning]`: 品質低下・保守性の問題・軽微な仕様逸脱 → 修正推奨
   - `[Info]`: 改善提案・ベストプラクティス → 任意

4. 総合判定:
   - **承認**: Critical/Warning が 0件
   - **要修正**: Critical が 0件、Warning が 1件以上
   - **要再設計**: Critical が 1件以上

5. レビューレポートを出力:
   - チャットに表示
   - `docs/review-report.md` に保存

6. 次のアクションを提案

#### レビューレポート出力仕様

`docs/review-report.md` のフォーマット:

```markdown
# レビューレポート

**日時**: YYYY-MM-DD HH:MM
**対象**: 変更ファイル一覧

## 総合判定: 承認 / 要修正 / 要再設計

## 指摘一覧

### [Critical] 指摘タイトル
- **対象**: ファイルパス:行番号
- **内容**: 問題の説明
- **改善案**: 具体的な修正提案

### [Warning] 指摘タイトル
- **対象**: ファイルパス:行番号
- **内容**: 問題の説明
- **改善案**: 具体的な修正提案

### [Info] 指摘タイトル
- **対象**: ファイルパス:行番号
- **内容**: 問題の説明
- **改善案**: 具体的な修正提案

## 次のアクション
- 推奨するスキルと対応内容
```

#### 異常系フロー

- 仕様書が存在しない場合: 仕様適合性の観点をスキップし、その旨をレポートに明記
- テストコードが存在しない場合: テストカバレッジの観点をスキップし、`create-tests` でのテスト作成を推奨
- 実装コードが存在しない場合: レビュー不可としてエラーメッセージを表示

### 3.5 create-pr スキル

#### PR作成手順

1. レビューレポートの確認:
   - `docs/review-report.md` を読み込む
   - 総合判定が「承認」か確認
   - 承認でない場合: 「レビューが未承認です。続行しますか？」と警告し確認
   - ファイルが存在しない場合: 「レビューが実施されていません。続行しますか？」と警告し確認

2. 情報収集:
   - `docs/prd.md`, `docs/spec.md` を読み込む
   - `docs/tasks.md` を読み込み完了状態を確認
   - `git log <base>..HEAD` でコミット履歴を取得
   - `git diff <base>...HEAD` で変更差分を取得
   - ベースブランチは `main` をデフォルトとし、異なる場合はユーザーに確認

3. PRタイトル生成:
   - 70文字以内
   - Conventional Commits プレフィックス付き
   - 複数プレフィックスが混在する場合: 主要な変更のプレフィックスを使用（feat > fix > refactor の優先順）
   - フォーマット: `<prefix>: <変更の要約>`

4. PR本文生成:
   - `.github/PULL_REQUEST_TEMPLATE.md` が存在する → そのテンプレートに沿って生成
   - 存在しない → デフォルトテンプレートを使用:

   ```markdown
   ## Summary
   - 変更の概要（prd.md/spec.md から要約、1-3箇条書き）

   ## Changes
   - 変更内容の詳細（tasks.md の完了タスク一覧から生成）

   ## Test plan
   - テストの実行方法（テスト実行コマンド）
   - 確認観点（テストケースの概要）

   ## Review notes
   - レビューの総合判定
   - 残存する Info 指摘（あれば）
   ```

5. ラベル設定:
   - コミットメッセージのプレフィックスからラベルを導出:
     - `feat` → `feature`
     - `fix` → `bugfix`
     - `refactor` → `refactor`
     - `docs` → `documentation`
     - `test` → `test`
   - `gh label list` でプロジェクトの既存ラベルを取得
   - 存在するラベルのみ付与（存在しないラベルは無視）

6. レビュアー設定:
   - `.github/CODEOWNERS` が存在する → 変更ファイルに対応するオーナーを抽出
   - 存在しない場合 → ユーザーに「レビュアーを指定しますか？」と確認
   - ユーザーが指定 → `--reviewer` に設定
   - 指定なし → レビュアーなしでPR作成

7. リモートプッシュ確認:
   - `git status` でリモートとの同期状態を確認
   - プッシュされていない場合: 「リモートにプッシュしますか？」と確認
   - 確認後 `git push -u origin <branch>`

8. PR作成:
   - `gh pr create --title "..." --body "..." --label "..." --reviewer "..."`
   - 既存PRがある場合: 「既存のPR #<number> があります。本文を更新しますか？」と確認
   - 更新の場合: `gh pr edit <number> --title "..." --body "..."`

9. PRのURLを返す

#### 異常系フロー

- `gh` CLI が未インストール/未認証の場合: エラーメッセージを表示し、インストール・認証手順を案内
- リモートリポジトリが設定されていない場合: エラーメッセージを表示
- ブランチにコミットがない場合: エラーメッセージを表示

## 4. ドキュメント配置仕様

スキルが生成・参照するドキュメントの配置:

| ファイル | 生成元 | 参照元 |
|---------|-------|-------|
| `docs/prd.md` | create-spec | create-pr |
| `docs/spec.md` | create-spec | create-tests, implement-code, review-implements, create-pr |
| `docs/plan.md` | create-spec | implement-code |
| `docs/tasks.md` | create-spec | create-tests, implement-code, create-pr |
| `docs/review-report.md` | review-implements | implement-code（指摘反映）, create-pr |

`docs/` ディレクトリはプロジェクトルート直下に配置する。モノレポ等でサブディレクトリ単位で開発する場合は、ユーザーが作業ディレクトリを指定し、そのディレクトリ直下の `docs/` を使用する。

## 5. スコープ外の明確化

- **CI/CD連携**: PR作成はスコープ内だが、CIの設定・管理・監視は行わない。PR作成がCIトリガーとなることは許容する
- **特定言語固有の最適化**: 技術スタック検出は行うが、言語固有のベストプラクティスの強制は行わない
- **デプロイ**: デプロイ関連の操作は一切行わない
