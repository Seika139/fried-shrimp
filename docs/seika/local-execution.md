# OpenClaw Local Execution Guide (VPS)

Docker での起動が難しい場合に、VPS（Linux）上で直接 OpenClaw を実行するための手順です。

## 1. 前提条件の確認 (Prerequisites)

OpenClaw は **Node.js v22.12.0 以上** と **pnpm** を必要とします。

### Node.js の確認

```bash
node -v
# v22.12.0 以上であることを確認してください
```

もしバージョンが古い、またはインストールされていない場合は `nvm` 等でインストールしてください。

```bash
# nvm のインストール（未導入の場合）
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
source ~/.bashrc

# Node.js v22 のインストール
nvm install 22
nvm use 22
```

### pnpm の確認

```bash
pnpm -v
```

もしインストールされていない場合:

```bash
npm install -g pnpm
# または corepack を有効化
corepack enable
```

## 2. 依存関係のインストール (Install Dependencies)

プロジェクトのルートディレクトリで実行します。

```bash
pnpm install
```

※ `sharp` や `node-llama-cpp` などのネイティブ依存関係のビルドが走るため、時間がかかる場合があります。

## 3. 環境設定 (Environment Setup)

`.env` ファイルが既に存在していることを確認してください（Docker 設定時に作成済みのはずですが、念のため）。

```bash
ls -l .env
# 存在しない場合: cp .env.example .env
```

`OPENCLAW_GATEWAY_TOKEN` が設定されているか確認します。

```bash
grep OPENCLAW_GATEWAY_TOKEN .env
```

もし空または設定されていない場合は、ランダムなトークンを生成して設定してください。

```bash
# 新規生成して追記 (Mac/Linux)
echo "OPENCLAW_GATEWAY_TOKEN=$(openssl rand -hex 32)" >> .env
```

## 4. ビルド (Build)

TypeScript のコンパイルを行います。

```bash
pnpm build
```

## 5. Gateway の起動 (Run Gateway)

Gateway サーバーを起動します。

```bash
pnpm gateway:dev
```

正常に起動すると、ログに `Gateway started on port 18789` 之ようなメッセージが表示されます。
（このターミナルは占有されるため、CLI 操作用にもう一つターミナルを開くか、`tmux` / `screen` を使用することをお勧めします）

## 6. CLI の実行 (Run CLI)

別のターミナルを開き、CLI ツールを実行して動作確認します。

```bash
# ヘルプの表示
pnpm dev -- help

# Gateway への接続確認 (Gateway が起動している状態で)
pnpm dev gateway status
```

## トラブルシューティング

### "Address already in use" エラー

Docker で起動しようとして失敗したコンテナがポート（18789, 18790）を掴んだままになっている可能性があります。

```bash
# Docker コンテナの停止
docker ps
docker compose down
# または強制的に停止
docker rm -f $(docker ps -a -q)
```

### メモリ不足 (OOM)

ビルド中 (`pnpm build`) にメモリ不足で落ちる場合は、スワップ領域を増やすか、ローカル（手元のPC）でビルドした `dist` ディレクトリをアップロードする方法を検討してください。
