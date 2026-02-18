# 修正内容の確認 (Walkthrough)

OpenClawセットアップ中に行われたWS接続不具合の修正とバインド設定の変更について報告します。

## 実施した変更

### バックエンド: クライアントIDバリデーションの修正
ダッシュボードが送信していたクライアントID `moltbot-control-ui` が、バックエンドの許可リストに含まれていなかったため、バリデーションエラーが発生していました。これを許可リストに追加しました。

- [src/gateway/protocol/client-info.ts](file:///root/programs/fried-shrimp/src/gateway/protocol/client-info.ts)

### バックエンド: 環境変数のバインド設定への反映
`.env` で設定した `OPENCLAW_GATEWAY_BIND` が反映されるよう、ゲートウェイの起動時設定を修正しました。

- [src/gateway/server-runtime-config.ts](file:///root/programs/fried-shrimp/src/gateway/server-runtime-config.ts)

### ホストOS: ファイアウォール (ufw) の設定
VPSのファイアウォールでポート `18789` と `18790` が閉じられていたため、外部からのアクセスを許可するように設定しました。

- コマンド: `sudo ufw allow 18789/tcp && sudo ufw allow 18790/tcp`

### デバッグログの削除
不具合調査のために一時的に挿入したログを削除しました。

- [src/gateway/server/ws-connection/message-handler.ts](file:///root/programs/fried-shrimp/src/gateway/server/ws-connection/message-handler.ts)

## 検証結果

ユーザーからのデバッグログ出力により、原因が `client.id` の不整合であることを特定し、修正を適用しました。

### 修正前のエラー
```
20:02:43 [ws] closed before connect ... code=1008 reason=invalid connect params: at /client/id: must be equal to constant; at /client/id: must match a schema in anyOf
```

### 修正後
- バリデーションエラーが解消され、WebSocket接続が可能になります。
- ゲートウェイが `0.0.0.0` でバインドされるようになり、外部からのアクセスが可能になります。

## ユーザーへの確認事項
変更を反映させるため、一度ゲートウェイを終了し、再度以下のコマンドを実行してください。

```bash
pnpm gateway:dev
```
