# Repository Ruleset への移行計画

旧来の「ブランチ保護ルール」から、GitHub 推奨の最新機能である「Repository Ruleset」へ移行します。

## 移行の理由

- **柔軟なバイパス設定**: 自分（リポジトリオーナー）だけ特定のルール（PRなしのプッシュなど）を許可しつつ、基本はPRを必須にする、といった設定がより直感的に行えます。
- **モダンな管理**: GitHub が今後注力する機能であり、複数のブランチを一括でターゲットにするなどの拡張性が高いです。
- **UI の統合**: Settings > Rulesets の画面で見やすく管理できます。

## 変更内容

### Terraform 構成

#### [MODIFY] [main.tf](file:///Users/suzukikenichi/programs/fried-shrimp/terraform/github/main.tf)

- `github_branch_protection` リソースを **削除**。
- `github_repository_ruleset` リソースを **追加**：
  - `enforcement = "active"`
  - `target = "branch"` (デフォルトブランチをターゲットに設定)
  - `rules`:
    - `deletion = true`
    - `non_fast_forward = true`
    - `pull_request`:
      - `required_approving_review_count = 0`
    - `required_status_checks`:
      - `strict_required_status_checks_policy = false`
      - `required_check`:
        - `context = "lint"`

## 検証プラン

### 自動テスト / 動作確認

1. `dotenvx run -- terraform plan` を実行。
2. 古いルールの削除と、新しい Ruleset の作成が計画されることを確認。
3. `m terra-github` を実行して適用。
