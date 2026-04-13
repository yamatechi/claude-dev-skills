# Claude Dev Skills

仕様駆動開発（Spec-Driven Development）とテスト駆動開発（TDD）のワークフローを支援する Claude Code スキルセット。

## スキル一覧

| スキル | 説明 | コマンド |
|--------|------|---------|
| create-spec | PRD・仕様書・実装計画・タスク一覧の作成 | `/create-spec` |
| create-tests | 仕様書からテストコードを生成（TDD Red Phase） | `/create-tests` |
| implement-code | テストが通るようにコードを実装（TDD Green→Refactor） | `/implement-code` |
| review-implements | 実装コードの品質・仕様適合性をレビュー | `/review-implements` |
| create-pr | Pull Requestを作成 | `/create-pr` |

## 推奨ワークフロー

```
create-spec → create-tests → implement-code → review-implements → create-pr
```

## インストール

### 方法1: シンボリックリンク（推奨）

```bash
git clone <repo-url> ~/claude-dev-skills
ln -s ~/claude-dev-skills/skills/* ~/.claude/skills/
```

### 方法2: プロジェクト固有

```bash
cp -r skills/* <your-project>/.claude/skills/
```

## 要件

- Claude Code
- `gh` CLI（create-pr スキル使用時）
