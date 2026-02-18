# Devcontainer設定の構造化と自動化

Tailscaleのインストールを含むセットアップ処理を専用スクリプトに分離し、コンテナ構築時に自動実行されるようにします。

### セットアップスクリプト

#### [NEW] [post-create.sh](file:///root/programs/fried-shrimp/.devcontainer/post-create.sh)

- 既存の `postCreateCommand` のロジックを移動。
- Tailscale のインストールと、**`tailscaled` デーモンのバックグラウンド起動処理**を追加。

### Devcontainer設定

#### [MODIFY] [devcontainer.json](file:///root/programs/fried-shrimp/.devcontainer/devcontainer.json)

- `postCreateCommand` を `"bash .devcontainer/post-create.sh"` に変更。
- **[Optional]** Tailscale の状態（ログイン情報）を永続化したい場合は、`/var/lib/tailscale` をマウント対象に追加します。

#### [MODIFY] [docker-compose.dev.yml](file:///root/programs/fried-shrimp/.devcontainer/docker-compose.dev.yml)

- `cap_add: [NET_ADMIN]` を追加。
- `devices: ["/dev/net/tun:/dev/net/tun"]` を追加。

## 実行・検証手順

1. ファイルを作成・修正。
2. （ユーザー側で）Devcontainer を **Rebuild**。
3. 起動後、`tailscale --version` および `fd --version` が動作し、環境変数が正しくセットされていることを確認。
