---
name: create-tests
description: >
  仕様書からテストコードを生成する（TDDのRed Phase）。
  実装前のテスト作成、テストカバレッジの追加、TDDワークフローの開始時に使用する。
  トリガー: "テストを書いて", "テストを生成して", "TDDで始めて", "テストカバレッジを追加"
user-invocable: true
allowed-tools: Read Grep Glob Bash Write Edit Agent
---

# create-tests: テストコード作成スキル

仕様書からテストコードを生成する（TDDのRed Phase）。

## 手順

### Step 1: 仕様書の読み込み

1. `.dev-docs/spec.md` を読み込む
   - 存在しない場合: ユーザーに仕様を口頭で伝えてもらう
2. `.dev-docs/tasks.md` を読み込む（存在すれば）
   - タスク一覧からテスト対象のタスクを特定する

### Step 2: 技術スタックの検出

以下の優先順で技術スタック・テストフレームワークを検出する:

**Step 2a: 設定ファイルから検出**

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

**Step 2b: 既存テストファイルから検出**

既存テストのパターンを分析する:
- ディレクトリ: `tests/`, `test/`, `__tests__/`, `spec/`, ソースと同階層
- ファイル命名: `*_test.go`, `*.test.ts`, `*.test.tsx`, `*_spec.rb`, `test_*.py`, `*Test.java`

**Step 2c: フォールバック**

検出できない場合、ユーザーに以下を質問する:
- 使用言語
- テストフレームワーク
- テストディレクトリの配置

### Step 3: 既存テストスタイルの分析

既存テストがある場合、以下を分析して合わせる:
- ディレクトリ構造
- ファイル命名規則
- テストヘルパー/フィクスチャの使用
- セットアップ/ティアダウンのパターン（beforeEach, setUp, before 等）
- アサーションスタイル（expect/assert/should 等）

### Step 4: テスト実行コマンドの検出

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

### Step 5: テストケースの設計

`.dev-docs/tasks.md` のタスク一覧を参照し、タスクごとにテストケースを設計する:

- **正常系**: 期待される入出力の検証
- **異常系**: エラー条件・バリデーション失敗の検証
- **エッジケース**: 境界値・空入力・大量データ等

### Step 6: テストコードの生成

テストコードを生成する。出力先はファイル配置ルールに従う:

1. 既存テストディレクトリが存在する → そのディレクトリに合わせる
2. 既存テストがない場合 → 言語のデフォルト構成を提案しユーザーに確認:
   - Node.js: `__tests__/` or `src/**/*.test.ts`
   - Python: `tests/`
   - Go: ソースと同階層 `*_test.go`
   - Ruby: `spec/` (rspec) or `test/` (minitest)
   - Rust: ソース内 `#[cfg(test)]` or `tests/`
   - Java: `src/test/java/`
3. テストファイルの命名は既存パターンに従う

### Step 7: テストの実行と確認（Red Phase）

テストを実行して結果を確認する。

**判定基準:** 今回新規追加したテストケースが対象。既存テストのPass/Failは判定に含めない。

- **新規追加テストが全てFailする** → 正常。Red Phase完了。ユーザーに報告する
- **新規追加テストの一部がPassする** → 以下を確認する:
  - 対応する実装が既に存在する → 正常（既存機能のテスト追加として扱う）
  - 実装がないのにPassする → テストの妥当性を再検討する（アサーションが甘い可能性）
- **実行自体が失敗する**（構文エラー等） → 修正してから再実行する
