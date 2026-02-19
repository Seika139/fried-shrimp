# セットアップ完了レポート

VPS上のDevcontainer環境において、OpenClawのゲートウェイを正常に起動し、Tailscale経由でセキュアにアクセスできる環境を構築しました。

## 実施した主な変更

### 1. 接続不具合の解消
- `src/gateway/protocol/client-info.ts` にダッシュボード用のIDを登録。
- `.env` のトークン設定を修正し、`src/gateway/server-runtime-config.ts` で環境変数が正しく評価されるよう改善。

### 2. Tailscaleによるセキュアアクセスとセキュリティ制限の回避
- `openclaw.json` で `tailscale: serve` を有効化し、HTTPS（*.ts.net）経由のアクセスを確立。
- ブラウザの「セキュアコンテキスト」要件やパブリックIP経由の制限を回避するため、`gateway.controlUi.allowInsecureAuth: true` を設定（OpenClawの標準機能を利用）。

### 3. Devcontainer設定の自動化と構造化
- **[NEW]** `.devcontainer/post-create.sh`: コンテナ構築時にTailscale等を自動インストール。
- `devcontainer.json`: 複雑だった `postCreateCommand` を上記スクリプトに集約。
- `docker-compose.dev.yml`: Tailscaleの動作に必要な `NET_ADMIN` 権限と `/dev/net/tun` マウントを追加。

## 検証結果
- [x] `pnpm gateway:dev` の正常起動
- [x] Tailscale による HTTPS エンドポイントの生成
- [x] ダッシュボードへの HTTP/WS 接続の確立（バイパスフラグによる制限解除を確認）

## 今後の利用方法
### ログインエラー（token_mismatch）が発生した場合
ダッシュボードが表示されても「token_mismatch」でログインできない場合は、ブラウザ上の **Control UI Settings** を開き、設定されているトークンが以下の値と一致しているか確認・修正してください：
- **Token**: `1cdb6211e965ea8c66f5d13896e665288c4332b497857e68`

### Tailscale の再接続
コンテナ再構築後に認証が切れた場合は、ターミナルで `tailscale up` を実行してログインし直してください。
設定が完了したら、以下のURLでダッシュボードにアクセスできます：
`https://[あなたのノード名].[テイルネット名].ts.net:18789`
