# Fork リポジトリ管理・運用ガイド

OpenClaw 本家 (`openclaw/openclaw`) から Fork したこのリポジトリを、自分の変更を加えつつ本家の更新も取り込んでいくためのガイドです。

## 1. 基本コンセプト：2 つのリモート

Fork したリポジトリには、通常 2 つの「接続先（リモート）」を設定します。

- **`origin`**: あなた自身の GitHub リポジトリ (`Seika139/fried-shrimp`)。あなたが直接コードをプッシュする場所です。
- **`upstream`**: 元になった本家のリポジトリ (`openclaw/openclaw`)。ここから最新の更新を取得します。

## 2. セットアップ：Upstream の登録

リポジトリをクローンした直後には `origin` しか登録されていません。以下のコマンドで本家を登録します。

```bash
# 現在のリモートを確認
$ git remote -v
origin  git@github.com:Seika139/fried-shrimp.git (fetch)
origin  git@github.com:Seika139/fried-shrimp.git (push)

# もし、upstream が登録されていない場合は
# 以下を実行して本家リポジトリを 'upstream' という名前で登録する
git remote add upstream https://github.com/openclaw/openclaw.git

# 登録されたことを確認
$ git remote -v
origin  git@github.com:Seika139/fried-shrimp.git (fetch)
origin  git@github.com:Seika139/fried-shrimp.git (push)
upstream        git@github.com:openclaw/openclaw.git (fetch)
upstream        git@github.com:openclaw/openclaw.git (push)
```

## 3. 同期の手順：本家の更新を取り込む

本家で新しい機能や修正が追加されたら、自分のリポジトリに取り込みます。

### ステップ 1: 本家の最新情報を取得

```bash
git fetch upstream
```

### ステップ 2: 自分のブランチに統合する

「Rebase（リベース）」という方法が、履歴が一直線になり綺麗なので推奨されます。

```bash
# 自分の main ブランチにいることを確認
git checkout main

# 本家の更新の上に、自分の変更を「乗せ直す」
git rebase upstream/main
```

> [!TIP]
> **Rebase と Merge の違い**
>
> - **Rebase**: 自分の変更履歴が本家の最新版の「後に」続くように整列されます。
> - **Merge**: 本家の更新を自分の履歴に「流し込む」専用のコミット（Merge commit）が作成されます。

## 4. 競合（Conflict）が起きたら

同じ場所を編集していた場合、Git が停止して解決を求めてきます。

1. **VS Code などのエディタで解決**:
   VS Code で該当ファイルを開くと、「Accept Current Change（自分の変更を採用）」「Accept Incoming Change（本家の変更を採用）」「Accept Both」などの選択肢が出ます。コードを見て適切な方を選びます。
2. **解決を報告**:

   ```bash
   git add <修正したファイル>
   git rebase --continue
   ```

## 5. 自分の GitHub に反映

同期が完了したら、自分の GitHub リポジトリにプッシュします。
※ Rebase を行った後は履歴が変わるため、強制プッシュ (`--force-with-lease`) が必要になる場合があります。

```bash
git push origin main --force-with-lease
```

## 6. 運用のコツ

- **こまめに同期する**: 本家との乖離が大きくなる前に、週に一度などは `git fetch upstream` することをお勧めします。
- **自分の変更は別ブランチで**: `main` ブランチは本家との同期用とし、大きな新機能開発は `feature/my-new-tool` のような別ブランチで行うと、管理がさらに楽になります。
