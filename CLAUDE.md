# claude-dev-skills

Claude Code用の開発スキル集。

## スキル一覧

以下のスキルが `skills/` ディレクトリに定義されている。
イシューのコメントからスラッシュコマンドで実行可能。

| コマンド | 説明 |
|---------|------|
| `/orchestrator` | 開発フロー全体を自動オーケストレーション（仕様→テスト→実装→レビュー→PR） |
| `/create-spec` | PRD・仕様書・実装計画・タスク一覧を作成 |
| `/create-tests` | 仕様書からテストコードを生成（TDD Red Phase） |
| `/implement-code` | テストが通るよう実装（TDD Green → Refactor） |
| `/review-implements` | コード品質・仕様適合性レビュー |
| `/create-pr` | GitHub Pull Request作成 |

## git戦略

- mainブランチには直接コミットしない
- 作業ブランチには必ず `feat/`, `fix/` 等のプレフィックスをつける
- コミットタイトルには必ず `feat:`, `fix:` 等のプレフィックスをつける

## 開発フロー

ドキュメントは `.dev-docs/<feature-name>/` に格納する。
