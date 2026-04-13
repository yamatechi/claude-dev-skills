# タスク一覧

## セットアップタスク

- [ ] プロジェクト構造のセットアップ
  - 概要: skills/ ディレクトリ構造の作成、README.md の作成

## 実装タスク

- [ ] create-spec スキルの実装（skills/create-spec/SKILL.md）
  - 概要: ドキュメント作成スキル。新規作成モード・差分更新モード・タスク分解ルール・変更履歴ルールを含む

- [ ] create-tests スキルの実装（skills/create-tests/SKILL.md）
  - 依存: create-spec スキルの実装
  - 概要: テストコード作成スキル。技術スタック検出・ファイル配置ルール・テスト実行コマンド検出・Red Phase確認を含む

- [ ] implement-code スキルの実装（skills/implement-code/SKILL.md）
  - 依存: create-tests スキルの実装
  - 概要: 実装コードスキル。TDD Green→Refactor・コミット戦略・タスク完了更新・レビュー指摘反映モードを含む

- [ ] review-implements スキルの実装（skills/review-implements/SKILL.md）
  - 依存: implement-code スキルの実装
  - 概要: 実装レビュースキル。レビュー観点・重要度分類・レポート構造（チャット+ファイル出力）・総合判定を含む

- [ ] create-pr スキルの実装（skills/create-pr/SKILL.md）
  - 依存: review-implements スキルの実装
  - 概要: Pull Request作成スキル。承認チェック・PR本文生成・ラベル導出・レビュアー設定・gh CLI連携を含む

## 検証タスク

- [ ] Python サンプルプロジェクトでの全フロー検証
  - 依存: create-pr スキルの実装
  - 概要: Python プロジェクトで create-spec → create-tests → implement-code → review-implements → create-pr の全フローが動作することを確認

- [ ] TypeScript サンプルプロジェクトでの全フロー検証
  - 依存: create-pr スキルの実装
  - 概要: TypeScript プロジェクトで全フローが動作することを確認

- [ ] Go サンプルプロジェクトでの全フロー検証
  - 依存: create-pr スキルの実装
  - 概要: Go プロジェクトで全フローが動作することを確認
