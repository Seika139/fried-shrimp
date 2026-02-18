# 実装計画 - 汎用的な Devcontainer 権限設定

## 概要

ホスト（VPS/ローカルPC）のユーザーが `root` か一般ユーザーかに関わらず、所有権の不一致を自動的に解消する構成を導入します。これにより、どのような環境でもファイルの編集・保存が制限なく行えるようになります。

## 解決策

VS Code の仕様と `docker-compose.gen.yml` の生成機能を組み合わせることで、動的にユーザーを切り替えます。

### 1. `Dockerfile` の修正

Dockerfile の末尾にある `USER node` を削除（またはコメントアウト）し、イメージのデフォルトユーザーを `root` に戻します。
> [!NOTE]
> これは動的なユーザー切り替えを確実にするためのベースラインです。

### 2. `devcontainer.json` の修正

`"remoteUser": "node"` を削除します。これにより、VS Code は Compose ファイルで指定されたユーザーを使用するようになります。

### 3. `docker-compose.dev.yml` の修正

デフォルトの開発用ユーザーとして `user: node` を指定します。これが非 root ホスト環境でのデフォルトとなります。

### 4. `setup-env.sh` の拡張

ホストの UID をチェックするロジックを追加します。

- **ホストが root (UID: 0) の場合**: `docker-compose.gen.yml` に `user: root` を書き込み、上位の設定をオーバーライドします。
- **ホストが一般ユーザーの場合**: 特に何もしない（あるいは `user: node` を明示）ことで、VS Code の UID 自動調整機能（Update UID）を働かせます。

## 実施手順

1. `Dockerfile` の `USER node` を削除。
2. `devcontainer.json` の `remoteUser` を削除。
3. `docker-compose.dev.yml` に `user: node` を追加。
4. `setup-env.sh` にユーザー検知とオーバーライド生成ロジックを追加。

## 検証計画

- **VPS (root)**: `docker exec -it <id> id` を実行し、`root` (UID 0) で動作していることを確認。
- **ローカル (一般ユーザー)**: 同様に実行し、UID がホストと同じ値に調整された `node` ユーザーであることを確認。
- 両環境で `touch` コマンド等によるファイル作成・編集をテスト。
