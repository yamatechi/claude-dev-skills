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

### 方法1: プラグインとしてインストール（推奨）

```bash
claude plugin add /path/to/claude-dev-skills
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

## 要件

- Claude Code
- `gh` CLI（create-pr スキル使用時）
