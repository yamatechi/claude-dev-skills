---
name: create-pr
description: >
  実装内容からGitHub Pull Requestを作成する。タイトル・本文・ラベル・レビュアーを自動生成する。
  実装とレビューが完了し、PRを提出する準備ができた時に使用する。
  トリガー: "PRを作って", "プルリクを出して", "PR作成して"
user-invocable: true
allowed-tools: Read Grep Glob Bash Write Edit Agent
---

# create-pr: Pull Request作成スキル

実装内容からPull Requestを作成する。
ドキュメントは `.dev-docs/<feature-name>/` から読み込む。

## Step 0: 対象ディレクトリの特定

```
IF $ARGUMENTS にfeature名が指定されている
  → .dev-docs/<feature-name>/ を使用
ELSE IF .dev-docs/ 配下にディレクトリが1つだけ存在する
  → そのディレクトリを使用
ELSE IF .dev-docs/ 配下にディレクトリが複数存在する
  → ユーザーに対象を選択してもらう
ELSE
  → エラー: 「仕様書が見つかりません。先に create-spec を実行してください」
```

以降、対象ディレクトリを `$DIR` と表記する。

## PR戦略の判定

`$DIR/tasks.md` を読み込み、PR戦略（単一PR / 分割PR）を確認する。

- **単一PR** → 通常の手順（Step 1〜9）を実行する
- **分割PR** → 分割PRフローを実行する

## 通常の手順（単一PR）

### Step 1: レビューレポートの確認

1. `$DIR/review-report.md` を読み込む
2. 総合判定を確認する:
   - **承認済み** → Step 2 へ進む
   - **承認済みでない** → 「レビューが未承認です（総合判定: 〇〇）。続行しますか？」とユーザーに確認する
   - **ファイルが存在しない** → 「レビューが実施されていません。続行しますか？」とユーザーに確認する

### Step 2: 情報収集

1. `$DIR/prd.md`, `$DIR/spec.md` を読み込む（存在すれば）
2. `$DIR/tasks.md` を読み込み、完了状態を確認する
3. `git log` でコミット履歴を取得する
4. `git diff` で変更差分を取得する
5. ベースブランチは `main` をデフォルトとする。異なる場合はユーザーに確認する

### Step 3: PRタイトルの生成

- 70文字以内にする
- Conventional Commits プレフィックスを付ける
- 複数プレフィックスが混在する場合: 主要な変更のプレフィックスを使用する（feat > fix > refactor の優先順）
- フォーマット: `<prefix>: <変更の要約>`

### Step 4: PR本文の生成

`.github/PULL_REQUEST_TEMPLATE.md` が存在する場合、そのテンプレートに沿って生成する。

存在しない場合、以下のデフォルトテンプレートを使用する:

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

### Step 5: ラベルの設定

1. コミットメッセージのプレフィックスからラベルを導出する:
   - `feat` → `feature`
   - `fix` → `bugfix`
   - `refactor` → `refactor`
   - `docs` → `documentation`
   - `test` → `test`

2. `gh label list` でプロジェクトの既存ラベルを取得する
3. 既存ラベルに存在するもののみ付与する（存在しないラベルは無視する）

### Step 6: レビュアーの設定

1. `.github/CODEOWNERS` が存在する → 変更ファイルに対応するオーナーを抽出する
2. 存在しない場合 → ユーザーに「レビュアーを指定しますか？」と確認する
3. ユーザーが指定 → `--reviewer` に設定する
4. 指定なし → レビュアーなしでPR作成する

### Step 7: リモートプッシュの確認

1. リモートブランチの状態を確認する
2. プッシュされていない場合: 「リモートにプッシュしますか？」とユーザーに確認する
3. 確認後 `git push -u origin <branch>` を実行する

### Step 8: 既存PRの確認とPR作成

1. `gh pr list --head <branch>` で既存PRの有無を確認する
2. 既存PRがある場合: 「既存のPR #<number> があります。本文を更新しますか？」とユーザーに確認する
   - 更新の場合: `gh pr edit <number> --title "..." --body "..."` を実行する
   - 更新しない場合: 終了する
3. 既存PRがない場合: `gh pr create --title "..." --body "..." --label "..." --reviewer "..."` でPR作成する

### Step 9: 結果の報告

作成したPRのURLをユーザーに返す。

## 分割PRフロー

`$DIR/tasks.md` のPR戦略が「分割PR」の場合に実行する。

### Step A: featureブランチの準備

1. `feat/<feature>` ブランチが存在しない場合は `main` から作成する
2. リモートにプッシュする

### Step B: 子PRの作成（PRグループごとに繰り返し）

tasks.mdのPRグループ（`## PR1:`, `## PR2:`, ...）ごとに以下を実行する:

1. `feat/<feature>` から `feat/<feature>/<具体名>` ブランチを作成する
   - `<具体名>` はPRグループ名をkebab-caseに変換する（例: `データモデルとAPI` → `data-model-and-api`）
2. 対応するタスクのコミットが含まれていることを確認する
3. リモートにプッシュする
4. `feat/<feature>/<具体名>` → `feat/<feature>` の子PRを作成する:
   - タイトル: `<prefix>: <PRグループ名>`
   - 本文: 通常のPRテンプレートに準拠（対象タスクの範囲に限定）
   - ラベル: 通常の手順と同様
5. 子PRをマージする（次のPRグループの作業前にマージを完了する）

### Step C: 集約PRの作成

全子PRのマージ完了後:

1. `feat/<feature>` → `main` の集約PRを作成する
2. タイトル: `<prefix>: <feature全体の要約>`
3. 本文:

```markdown
## Summary
- 変更の全体概要

## Child PRs
- #<number> <PRグループ名1>
- #<number> <PRグループ名2>
- ...

## Changes
- 全PRグループの変更内容

## Test plan
- テストの実行方法
- 確認観点
```

### Step D: 結果の報告

集約PRのURLと全子PRのURL一覧をユーザーに返す。

## 異常系フロー

- **`gh` CLI が未インストール/未認証の場合**: エラーメッセージを表示し、以下を案内する:
  - インストール: https://cli.github.com/ の手順に従う（macOS: `brew install gh`, Linux: `sudo apt install gh` 等）
  - 認証: `gh auth login`
- **リモートリポジトリが設定されていない場合**: エラーメッセージを表示する
- **ブランチにコミットがない場合**: エラーメッセージを表示する
