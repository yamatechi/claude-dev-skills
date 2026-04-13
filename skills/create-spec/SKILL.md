---
name: create-spec
description: >
  Create project documents (PRD, spec, plan, tasks) from user requirements.
  Use when starting a new feature, planning implementation, or documenting requirements.
  Also updates existing documents when changes are needed.
  Triggers: "仕様書を作って", "PRDを書いて", "設計して", "要件を整理して", "仕様を更新して"
user-invocable: true
allowed-tools: Read Grep Glob Bash Write Edit Agent
---

# create-spec: ドキュメント作成スキル

ユーザーの要望からプロジェクトドキュメント（PRD・仕様書・実装計画・タスク一覧）を作成する。

## モード判定

まず以下を確認してモードを判定する:

```
IF docs/prd.md OR docs/spec.md OR docs/plan.md OR docs/tasks.md が存在する
  → 差分更新モード
ELSE
  → 新規作成モード
```

---

## 新規作成モード

### Step 1: 要望のヒアリング

ユーザーの要望を `$ARGUMENTS` または対話で受け取る。以下を明確にする:
- 何を作りたいか（機能・目的）
- 誰のためか（ユーザー・ステークホルダー）
- 制約条件（技術・期限・スコープ）
- 不明点があればユーザーに質問する

### Step 2: 既存プロジェクトの調査

ソースコードが既に存在するか確認する:
- ソースコードが存在する → 既存プロジェクト
- 空またはスキャフォールドのみ → 新規プロジェクト

**既存プロジェクトの場合:**
1. ディレクトリ構造を調査する
2. 主要な設定ファイルを読んで技術スタックを把握する:
   - `package.json`, `pyproject.toml`, `go.mod`, `Gemfile`, `Cargo.toml`, `build.gradle`, `pom.xml`, `composer.json`, `Package.swift` 等
3. 既存テストのスタイル・ディレクトリ構造を分析する
4. 既存コードの設計パターン・命名規則を把握する

### Step 3: ドキュメント生成

以下の順序でドキュメントを生成する。各ドキュメント生成後、ユーザーに確認を求める。

#### 1. `docs/prd.md` — プロダクト要件定義書

以下のセクションを含める:
- 概要
- 背景・課題
- ゴール
- 機能要件
- 非機能要件
- スコープ外
- 成功指標

#### 2. `docs/spec.md` — 技術仕様書

以下のセクションを含める:
- アーキテクチャ概要
- データモデル / API設計 / 処理フロー（該当するもの）
- 技術選定と理由
- エラーハンドリング方針
- セキュリティ考慮事項

#### 3. `docs/plan.md` — 実装計画

以下のセクションを含める:
- 実装方針
- 実装順序（フェーズ分け）
- アーキテクチャ決定とその理由
- 既存コードへの影響範囲（既存プロジェクトの場合）

#### 4. `docs/tasks.md` — タスク一覧

以下のフォーマットに従う:

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

**タスク分解ルール:**
- 1タスク = 1つの論理的な機能単位（基本的に1テストファイルに対応）
- テストファイルが大きくなる場合は describe/context 単位で分割する
- 1タスク = 1コミット
- タスク間の依存関係を明記する
- 依存関係に循環がないことを確認する（循環を検出したらユーザーに警告）
- テストファイルに対応しないタスク（セットアップ・設定等）は「セットアップタスク」セクションに記載する

---

## 差分更新モード

### Step 1: 既存ドキュメントの読み込み

`docs/prd.md`, `docs/spec.md`, `docs/plan.md`, `docs/tasks.md` を全て読み込む。

### Step 2: 変更要望のヒアリング

ユーザーの変更要望を受け取る。

### Step 3: 影響範囲の分析

変更が波及するドキュメントを特定する:
- PRDの変更 → spec, plan, tasks への波及を判定
- specの変更 → plan, tasks への波及を判定

### Step 4: ドキュメントの更新

変更が必要なドキュメントを更新する。

### Step 5: 変更履歴の追記

更新したドキュメントの末尾に変更履歴を追記する:

```markdown
## 変更履歴
- YYYY-MM-DD: 変更内容の要約（変更理由）
```

### Step 6: ユーザー確認

変更した差分をユーザーに提示し、確認・承認を得る。
