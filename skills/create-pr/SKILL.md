---
name: create-pr
description: >
  Create a GitHub Pull Request from implementation with auto-generated title, body, labels, and reviewers.
  Use when implementation and review are complete and ready to submit a PR.
  Triggers: "PRを作って", "プルリクを出して", "PR作成して"
user-invocable: true
allowed-tools: Read Grep Glob Bash Write Edit Agent
---

# create-pr: Pull Request作成スキル

実装内容からPull Requestを作成する。

## 手順

### Step 1: レビューレポートの確認

1. `docs/review-report.md` を読み込む
2. 総合判定を確認する:
   - **承認済み** → Step 2 へ進む
   - **承認済みでない** → 「レビューが未承認です（総合判定: 〇〇）。続行しますか？」とユーザーに確認する
   - **ファイルが存在しない** → 「レビューが実施されていません。続行しますか？」とユーザーに確認する

### Step 2: 情報収集

1. `docs/prd.md`, `docs/spec.md` を読み込む（存在すれば）
2. `docs/tasks.md` を読み込み、完了状態を確認する
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

### Step 8: PR作成

1. `gh pr create --title "..." --body "..." --label "..." --reviewer "..."` でPR作成する
2. 既存PRがある場合: 「既存のPR #<number> があります。本文を更新しますか？」とユーザーに確認する
   - 更新の場合: `gh pr edit <number> --title "..." --body "..."` を実行する

### Step 9: 結果の報告

作成したPRのURLをユーザーに返す。

## 異常系フロー

- **`gh` CLI が未インストール/未認証の場合**: エラーメッセージを表示し、以下を案内する:
  - インストール: `brew install gh`
  - 認証: `gh auth login`
- **リモートリポジトリが設定されていない場合**: エラーメッセージを表示する
- **ブランチにコミットがない場合**: エラーメッセージを表示する
