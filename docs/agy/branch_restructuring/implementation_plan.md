# ブランチ構成の再編計画 (Terraform連携版)

## 概要

現在、`main` ブランチで行っている開発を保持しつつ、今後のコンフリクト解消を容易にするため、構成を変更します。リポジトリの設定変更は Terraform を通じて行います。

- `main` ブランチ: `upstream/main` をそのまま反映するだけのブランチにします。
- `develop` ブランチ: 自分の作業用メインブランチ（このリポジトリのデフォルト）にします。

## 提案される変更

### 1. Git 操作 (作業内容の移行)

1. 現在の `main`（作業内容やPRが含まれている状態）から `develop` ブランチを作成し、リモートにプッシュします。

    ```bash
    git checkout -b develop
    git push -u origin develop
    ```

### 2. Terraform 操作 (リポジトリ設定の変更)

1. [main.tf](file:///Users/suzukikenichi/programs/fried-shrimp/terraform/github/main.tf) を更新し、`github_branch_default` リソースを追加してデフォルトブランチを `develop` に設定します。
2. `terraform apply` を実行し、GitHub 上のデフォルトブランチを `develop` に切り替えます。

### 3. Git 操作 (mainブランチのクリーンアップ)

1. `main` ブランチを `upstream/main` と完全に同期させ、ローカルの変更を破棄します。

    ```bash
    git checkout main
    git reset --hard upstream/main
    git push origin main --force
    ```

## 検証計画

- `develop` ブランチに今までの作業内容（マージしたPR等）が含まれていることを確認する。
- GitHub 上でデフォルトブランチが `develop` になっていることを確認する。
- `main` ブランチが `upstream/main` と一致していることを確認する。
