# Upstream マージコンフリクト解消計画

## 概要

`main` (upstream/main) から `develop` へのマージで発生した `.env.example` のコンフリクトを解消します。
自分たちの変更（Twilio/GitHub Token 等）と Upstream の新しい設定項目を統合します。

## 変更内容

### [MODIFY] [.env.example](../../../.env.example)

- Upstream の新しいフォーマットをベースにします。
- `develop` ブランチで独自に追加されていた以下の変数を、適切な場所に追加します。
  - `TWILIO_ACCOUNT_SID`
  - `TWILIO_AUTH_TOKEN`
  - `TWILIO_WHATSAPP_FROM`
  - `GITHUB_TOKEN`

## 検証計画

### 自動テスト

- `git merge --continue` を実行し、マージを正常に完了させる。
- `mise run check` を実行し、マージ後のコードが Linter 等に違反していないか確認する。

### 手動確認

- `.env.example` の内容を目視で確認し、必要な変数がすべて含まれていることを確認する。
