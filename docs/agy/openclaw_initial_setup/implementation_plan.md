# Tailscaleによるセキュアアクセスの確立

Tailscaleの「Serve/Funnel」機能を利用して、OpenClawのゲートウェイに HTTPS でアクセスできる環境を構築します。

## ユーザー承認が必要な項目

- **Tailscaleの認証**: ゲートウェイ起動時にログインURLが表示されるので、ブラウザで認証を行う必要があります。

## 変更内容

### ゲートウェイ設定

#### [MODIFY] [openclaw.json](file:///root/.openclaw/openclaw.json)

- `gateway.tailscale.mode` を `"serve"` に変更します。
- `gateway.bind` が `"loopback"` であることを確認します（Tailscale利用時の必須条件）。

#### [MODIFY] [.env](file:///root/programs/fried-shrimp/.env)

- `OPENCLAW_GATEWAY_BIND` を削除、または `loopback` に設定します（`.env` の設定が優先されるため、`lan` のままだとTailscaleがエラーになります）。

## 実行・検証手順

1. ゲートウェイを起動: `pnpm gateway:dev`
2. ターミナルに表示される Tailscale の `Login URL` をクリックして認証。
3. 認証完了後、ターミナルに表示される `https://[node-name].[your-tailnet].ts.net` というURLでダッシュボードにアクセス。
4. ブラウザのセキュリティエラーが消え、正常に動作することを確認。
