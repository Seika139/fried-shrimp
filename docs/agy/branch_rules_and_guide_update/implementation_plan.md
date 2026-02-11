# ブランチ保護ルールとガイドの更新計画

## 概要

Terraform を使用して `main` と `develop` の両ブランチに適切な保護ルールを適用します。また、`develop` ブランチでのプルリクエスト（PR）必須運用に合わせて、運用ガイドを更新します。

## Proposed Changes

### [MODIFY] [main.tf](../../../terraform/github/main.tf)

1. **デフォルトブランチの設定**: `github_branch_default` リソースを追加し、`develop` をデフォルトにします。
2. **ルールセットの調整**:
   - **`develop` (Default Branch)**: プルリクエスト必須、ステータスチェック必須を維持。
   - **`main`**: 誤削除防止のためルールセットに含めるが、upstream 同期のための強制プッシュを許可するか、バイパス設定を検討。
   - `conditions` の `include` に `refs/heads/main` を追加し、`~DEFAULT_BRANCH` と併せて保護します。

### [MODIFY] [fork_management_guide.md](../../../docs/seika/fork_management/fork_management_guide.md)

1. **同期フローの修正**: `develop` へのマージに PR が必要なため、GitHub 上で PR を作成してマージする手順を追記します。
2. **CLI での暫定対応**: または、必要に応じてブランチルールの管理者バイパス権限を利用した手順（強制プッシュではないが直接マージ）について言及します。

## Verification Plan

### Automated Tests

- `mise run terra-github` を実行し、計画通りにルールが適用されることを確認。

### Manual Verification

- `develop` ブランチに対して直接プッシュを試み、GitHub 側で拒否されることを確認。
- ガイドに沿って、`main` から `develop` への同期 PR を作成し、マージできることを確認。
