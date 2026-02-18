# タスクリスト - 汎用的な Devcontainer 権限設定

- [ ] 設定の修正 [/]
  - [ ] `Dockerfile` の `USER node` 削除
  - [ ] `devcontainer.json` の `remoteUser` 削除
  - [ ] `docker-compose.dev.yml` に `user: node` 追加
  - [ ] `setup-env.sh` の動的ユーザー検知ロジック追加
- [ ] 検証 [ ]
  - [ ] VPS (root) での動作確認
  - [ ] ローカル環境での動作確認
