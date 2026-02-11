# follow-upstream タスクの修正計画

## 概要

`mise run follow-upstream` を実行した際、最初の `git checkout main` が失敗したにもかかわらず後続の `git reset --hard upstream/main` が実行されてしまい、意図しないブランチ（作業ブランチ）がリセットされてしまった問題を修正します。

## 修正内容

タスクの定義を、各コマンドが成功した場合のみ次に進むように書き換えます。また、安全のために `set -e` を明示的に使用します。

### [MODIFY] [mise.toml](../../../mise.toml)

以下のタスク定義を追加（または修正）します。

```toml
[tasks.follow-upstream]
description = "本家(upstream)の最新状態を main ブランチに反映し、origin へプッシュする"
shell = "bash -c"
run = '''
set -e
echo "Checking out main branch..."
git checkout main

echo "Fetching from upstream..."
git fetch upstream

echo "Resetting main to upstream/main..."
git reset --hard upstream/main

echo "Pushing to origin main..."
git push origin main --force
'''
```

## 検証計画

1. **エラー時の動作確認**:
   わざと `mise.toml` に未コミットの変更を加え、`mise run follow-upstream` を実行。
   `git checkout main` でエラーが発生し、その時点で **タスクが中断されること** を確認する（`reset --hard` まで到達しないこと）。
2. **正常時の動作確認**:
   変更がない状態で実行し、`main` ブランチが `upstream/main` と同期されることを確認する。
