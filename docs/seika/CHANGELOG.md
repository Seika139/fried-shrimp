# Local Changelog (Internal / Agentic)

このプロジェクト（フォーク）における独自の変更内容を記録します。
アップストリーム（OpenClaw）の `CHANGELOG.md` とのコンフリクトを避けるため、ローカルの変更はこちらで管理します。

## [0.2.0] - 2026-02-12

### Removed

- **GitHub Actions Workflows Cleanup**: 個人用フォークで不要なアップストリーム固有のワークフローを削除。
  - 削除したワークフロー: `ci.yml`, `workflow-sanity.yml`, `auto-response.yml`, `docker-release.yml`, `formal-conformance.yml`, `install-smoke.yml`, `labeler.yml`, `stale.yml`
  - 削除した関連ファイル: `.github/labeler.yml`, `.github/FUNDING.yml`, `.github/ISSUE_TEMPLATE/`
  - 維持したワークフロー: `lint-markdown.yml` (自作)
- **Documentation**:
  - `docs/agy/cleanup_github_workflows/` (実装計画、タスク、ウォークスルー)

### Changed

- **Branch Protection**: `develop` ブランチの保護ルールを更新し、より柔軟な運用を可能にした。

## [0.1.0] - 2026-02-06

### Added

- **Terraform GitHub Integration**: GitHub リポジトリの設定を IaC で管理する基盤を導入。
- **Repository Rulesets**: `main` ブランチの保護ルール（PR必須、強制プッシュ禁止、ステータスチェック必須）を適用。
- **dotenvx Security**: `GITHUB_TOKEN` などの機密情報を `dotenvx` で暗号化し、`.env` を安全にコミット・共有可能にした。
- **mise Automation**: `mise run terra-github`, `mise run encrypt/decrypt` などの自動化コマンドを追加。
- **Markdownlint Configuration**: `docs/agy/` フォルダのみをリント対象にするホワイトリスト設定を導入（アップストリームとの競合回避）。
- **Documentation**:
  - `docs/agy/terraform_github_integration/` (実装、タスク、ウォークスルー)
  - `docs/agy/fork_management/` (フォーク管理ガイド)

### Fixed

- GitHub Token のスコープ不足による認証エラーの修正（`read:org` スコープの追加案内）。
- markdownlint によるアップストリームファイルの意図しない変更を防止。
