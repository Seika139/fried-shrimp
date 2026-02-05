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
- [x] 完了報告
  - [x] `walkthrough.md` の更新
