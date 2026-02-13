# Remote Devcontainer Setup Guide

このドキュメントでは、リモートサーバー（VPS やクラウドインスタンスなど）上の Docker コンテナ内で、VS Code を使用して開発を行うための手順を解説します。

特に、`dotenvx` で暗号化された `.env` ファイルを適切に扱い、Dev Container 環境で環境変数を利用できるようにする方法に重点を置いています。

## 前提条件

- **ローカルマシン**:
  - VS Code がインストールされていること。
  - VS Code 拡張機能「Remote - SSH」と「Dev Containers」がインストールされていること。
- **リモートサーバー**:
  - SSH で接続可能であること。
  - Docker および Docker Compose がインストールされていること。
  - Node.js (npm/npx) が利用可能であること（`dotenvx` コマンド実行のため）。

## 1. サーバーでの準備

まず、リモートサーバーに SSH ログインし、リポジトリのセットアップを行います。

```bash
# リポジトリのクローン（例）
git clone <repository-url> fried-shrimp
cd fried-shrimp
```

### `.env` ファイルの復号化

このプロジェクトでは `.env` ファイルが `dotenvx` によって暗号化されています。
Dev Container (Docker Compose) が環境変数を正しく読み込めるように、サーバー上で `.env` を復号化する必要があります。

1. **復号鍵の配置**:
   プロジェクトルートに `.env.keys` ファイルを作成し、復号鍵 (`DOTENV_PRIVATE_KEY`) を記述します。
   ※ `.env.keys` は `.gitignore` されているため、安全に配置できますが、本番サーバー等での取り扱いには十分注意してください。

   ```bash
   # .env.keys ファイルを作成
   echo 'DOTENV_PRIVATE_KEY=your_actual_private_key_here' > .env.keys
   ```

2. **復号化の実行**:
   `dotenvx` を使用して `.env` ファイルを復号化（上書き）します。

   ```bash
   npx dotenvx decrypt -f .env
   ```

   > **注意**: これにより `.env` ファイルの内容が平文に書き換わります。`git status` で差分が表示されますが、**この変更は絶対にコミットしないでください**。

## 2. VS Code からの接続

ローカルマシンの VS Code からリモートサーバーに接続し、Dev Container を起動します。

1. **Remote - SSH で接続**:
   VS Code のコマンドパレット (`Cmd+Shift+P` / `Ctrl+Shift+P`) を開き、`Remote-SSH: Connect to Host...` を選択してリモートサーバーに接続します。

2. **フォルダを開く**:
   接続したウィンドウで「フォルダーを開く」を選択し、クローンしたリポジトリのディレクトリ（例: `~/fried-shrimp`）を開きます。

3. **Dev Container で開き直す**:
   右下に「このフォルダーには Dev Container 設定ファイルが含まれています」という通知が表示されたら、「Reopen in Container」をクリックします。
   または、コマンドパレットから `Dev Containers: Reopen in Container` を実行します。

## 3. 開発の開始

コンテナのビルドと起動が完了すると、VS Code はコンテナ内の環境に接続されます。
ターミナルを開くと、コンテナ内のシェル (`/app` ディレクトリ) が利用可能です。

```bash
# 開発サーバーの起動確認
pnpm dev
```

## 4. 作業終了時の注意

作業が終了し、`.env` を元の暗号化された状態に戻したい場合は、以下のコマンドを実行します。

```bash
git checkout .env
```
