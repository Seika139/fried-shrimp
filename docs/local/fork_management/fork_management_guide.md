# Fork リポジトリ管理・運用ガイド

OpenClaw 本家 (`openclaw/openclaw`) から Fork したこのリポジトリを、効率的に運用するためのガイドです。
現在は **`develop` ブランチを開発のメイン**とし、**`main` ブランチを本家（upstream）への追従用**として使用する運用を採用しています。

## 1. ブランチの役割

- **`develop`**: **あなたの作業用メインブランチ**。リポジトリのデフォルトブランチです。新機能の開発や修正はここから開始します。
- **`main`**: **本家 (upstream) 追従用ブランチ**。本家の `main` と常に一致させ、あなたの変更は直接加えません。

---

## 2. リモート設定の確認

以下の 2 つのリモートが設定されていることを確認してください。

- **`origin`**: 自身の GitHub リポジトリ (`Seika139/fried-shrimp`)
- **`upstream`**: 本家のリポジトリ (`openclaw/openclaw`)

```bash
$ git remote -v
origin    git@github.com:Seika139/fried-shrimp.git (fetch/push)
upstream  https://github.com/openclaw/openclaw.git (fetch/push)
```

---

## 3. main ブランチの更新手順 (Upstream 追従)

本家 (upstream) に新しい更新があった場合、まず `main` ブランチを同期させます。
このブランチには自分の変更がないため、常にコンフルクトなしで更新できるはずです。

```bash
# 1. main ブランチに切り替え
git checkout main

# 2. 本家から最新情報を取得
git fetch upstream

# 3. 本家の main を自分の main に反映
git reset --hard upstream/main

# 4. 自分の GitHub (origin) に反映
git push origin main --force
```

---

## 4. develop ブランチの更新手順 (作業内容への統合)

`main` が最新になったら、その変更を `develop` ブランチに取り込みます。

```bash
# 1. develop ブランチに切り替え
git checkout develop

# 2. main (最新の本家) の変更をマージ
git merge main

# (もしコンフリクトが発生したら解決してコミット)

# 3. 自分の GitHub (origin) に反映
git push origin develop
```

> [!TIP]
> **なぜこの運用にするのか？**
> `main` ブランチを本家と全く同じ状態に保つことで、いつでも「本家の最新状態」をクリーンに参照できます。また、`develop` でのコンフリクト解消に失敗しても、`main` からやり直すことが容易になります。

---

## 5. 日々の開発フロー

1. `develop` ブランチで作業を行う。
2. 適宜 `origin/develop` にプッシュする。
3. 本家に更新があれば、上記「3」と「4」の手順で `develop` に取り込む。

大きな機能追加などは、`develop` からさらに `feature/xxx` ブランチを切って作業し、完了後に `develop` へマージすることを推奨します。

---

## 6. 運用のコツ

- **こまめに同期する**: 本家との乖離が大きくなる前に、定期的に上記の手順で同期することをお勧めします。
- **GitHub の "Sync fork" ボタンは使わない**: GitHub 上のボタンを使うと、不要なマージコミットが作成されたり、予期せぬコンフリクトの原因になることがあります。本ガイドの `git reset --hard` を使う手順の方が、履歴をクリーンに保てるため推奨されます。
- **自分の変更は常に develop で**: `main` ブランチは upstream 追従専用とし、間違えて直接コミットしないよう注意してください。
