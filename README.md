# Claude Dev Skills

仕様駆動開発（Spec-Driven Development）とテスト駆動開発（TDD）のワークフローを支援する Claude Code スキルセット。

## スキル一覧

| スキル | 説明 | コマンド |
|--------|------|---------|
| **orchestrator** | **開発フロー全体を自動オーケストレーション** | **`/orchestrator`** |
| create-spec | PRD・仕様書・実装計画・タスク一覧の作成 | `/create-spec` |
| create-tests | 仕様書からテストコードを生成（TDD Red Phase） | `/create-tests` |
| implement-code | テストが通るようにコードを実装（TDD Green→Refactor） | `/implement-code` |
| review-implements | 実装コードの品質・仕様適合性をレビュー | `/review-implements` |
| create-pr | Pull Requestを作成 | `/create-pr` |

## 使い方

### 全自動（推奨）

`/orchestrator` で要望を伝えるだけ。プロジェクトの状態を分析し、最適なフローを提案、承認後に全自動で実行する。

```
/orchestrator ログイン機能を作って
```

### 個別スキル

各スキルを個別に呼び出すことも可能。

```
create-spec → create-tests → implement-code → review-implements → create-pr
```

## インストール

### 方法1: マーケットプレイスからインストール（推奨）

Claude Code 内で以下を実行:

```
/plugin marketplace add yamatechi/claude-dev-skills
/plugin install claude-dev-skills@claude-dev-skills
```

プラグインとしてインストールすると、各スキルは `claude-dev-skills:` プレフィックス付きで呼び出せる:

```
/claude-dev-skills:orchestrator ログイン機能を作って
```

### 方法2: シンボリックリンク

```bash
git clone https://github.com/yamatechi/claude-dev-skills.git ~/claude-dev-skills
ln -s ~/claude-dev-skills/skills/* ~/.claude/skills/
```

### 方法3: プロジェクト固有

```bash
cp -r skills/* <your-project>/.claude/skills/
```

## GitHub Actions で実行

Issue コメントや手動トリガーから Claude Code スキルを自動実行できる。

### セットアップ

1. `.github/workflows/claude-dev.yml` をプロジェクトにコピーする:

```bash
# このリポジトリから直接コピー
mkdir -p .github/workflows
curl -o .github/workflows/claude-dev.yml \
  https://raw.githubusercontent.com/yamatechi/claude-dev-skills/main/.github/workflows/claude-dev.yml
```

2. 認証情報を設定する（いずれか一方）:

   **Anthropic API の場合:**

   Settings > Secrets > `ANTHROPIC_API_KEY` を設定。

   **Amazon Bedrock の場合（OIDC 認証）:**

   a. AWS 側で GitHub Actions 用の IAM ロールを作成する:
      - OIDC プロバイダー: `token.actions.githubusercontent.com`
      - 信頼ポリシーの条件: `repo:<owner>/<repo>:*`
      - 必要な権限: `bedrock:InvokeModel`, `bedrock:InvokeModelWithResponseStream`

   b. Settings > Variables（Secrets ではない）で以下を設定:
      - `AWS_ROLE_ARN`: IAM ロール ARN（例: `arn:aws:iam::123456789012:role/github-actions-bedrock`）
      - `AWS_REGION`: リージョン（例: `us-east-1`）
      - `ANTHROPIC_MODEL`: *(任意)* モデル ID（例: `us.anthropic.claude-sonnet-4-6-20250514-v1:0`）

   > `AWS_ROLE_ARN` が設定されている場合、OIDC 認証で Bedrock が自動的に使用される。

3. リポジトリの Settings > Actions > General で:
   - Workflow permissions を **Read and write permissions** に設定

### 使い方

**Issue コメントから実行:**

Issue を作成し、コメントで以下のように指示する:

```
/orchestrator ログイン機能を作って
```

個別スキルも実行可能:

```
/create-spec ユーザー管理機能の仕様を作成して
/create-tests
/implement-code
/review-implements
/create-pr
```

**手動実行:**

Actions タブ → "Claude Dev Skills" → "Run workflow" からスキルと要望を入力して実行。

### 動作の流れ

1. Issue コメントでコマンドを検知（write 権限を持つユーザーのみ実行可能）
2. Claude Code をインストールし、スキルをセットアップ
3. 指定されたスキルを CI モード（確認なし・全自動）で実行
4. 実行結果を Issue コメントとして投稿

## 要件

- Claude Code
- `gh` CLI（create-pr スキル使用時）
