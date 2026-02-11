# Terraform GitHub Integration Task List

- [x] Terraform 構成の準備
  - [x] `terraform/github/main.tf` の更新
  - [x] `.env.example` の更新
- [x] Repository Ruleset への移行
  - [x] `terraform/github/main.tf` の更新（Ruleset リソースへの置換）
  - [x] 旧ルールの削除と新ルールの反映
  - [x] `m terra-github` の実行成功
- [x] 動作確認
  - [x] `terraform init` の実行
  - [x] `dotenvx run -- terraform plan` の確認
- [x] 安全なコミットと共有
  - [x] `.gitignore` の調整（暗号化済み `.env` の許可）
  - [x] 全ての変更をコミット
- [x] 長期的な運用と履歴管理
  - [x] 独自の `docs/seika/CHANGELOG.md` を作成（コンフリクト回避）
- [x] 完了報告
  - [x] `walkthrough.md` の更新
