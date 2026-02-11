# ブランチ構成の再編および follow-upstream 修正 完了報告

## 実施内容

### 1. 開発用ブランチ (`develop`) の作成

現在の `main` ブランチから `develop` ブランチを作成し、すべての作業内容を安全に移行しました。

### 2. Terraform によるデフォルトブランチの切り替え

GitHub 上のデフォルトブランチを `develop` に変更しました。

### 3. `main` ブランチのリセット

`main` ブランチを `upstream/main` と完全に同期させ、クリーンな状態にしました。

### 4. 運用ガイドの更新

[fork_management_guide.md](../../../docs/seika/fork_management/fork_management_guide.md) を刷新し、新運用フローと注記（Sync fork ボタンの回避など）を追加しました。

### 5. `follow-upstream` タスクの修正

`mise run follow-upstream` がチェックアウト失敗時などに後続の `reset --hard` を実行してしまう問題を修正しました。

- `set -e` を追加し、いずれかのコマンドが失敗した時点でタスクを中断するようにしました。
- 動作検証を行い、未コミットの変更がある場合に安全に停止することを確認しました。

## 確認事項

- [x] `develop` ブランチにすべての変更が保持されている。
- [x] デフォルトブランチが `develop` になっている。
- [x] `follow-upstream` がエラー時に安全に停止する。

## 今後の運用

- 開発は `develop` ブランチで行ってください。
- 本家の更新取り込みは `mise run follow-upstream` を使用し、エラーが出た場合はメッセージに従って stash や commit を行ってから再試行してください。
