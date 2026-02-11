# 不要な GitHub Actions ワークフローおよび関連ファイルの削除

本プロジェクトは `openclaw/openclaw` の個人用フォークであり、アップストリーム向けの PR や Issue 管理に使用していた不要なワークフローやテンプレートファイルを削除し、リポジトリを軽量化・整理します。

## Proposed Changes

### GitHub Configuration (.github)

#### [DELETE] ci.yml (.github/workflows/ci.yml)

#### [DELETE] workflow-sanity.yml (.github/workflows/workflow-sanity.yml)

#### [DELETE] auto-response.yml (.github/workflows/auto-response.yml)

#### [DELETE] docker-release.yml (.github/workflows/docker-release.yml)

#### [DELETE] formal-conformance.yml (.github/workflows/formal-conformance.yml)

#### [DELETE] install-smoke.yml (.github/workflows/install-smoke.yml)

#### [DELETE] labeler.yml (.github/workflows/labeler.yml)

#### [DELETE] stale.yml (.github/workflows/stale.yml)

#### [DELETE] labeler.yml (.github/labeler.yml)

#### [DELETE] FUNDING.yml (.github/FUNDING.yml)

#### [DELETE] ISSUE_TEMPLATE (.github/ISSUE_TEMPLATE/)

> [!NOTE]
>
> - `lint-markdown.yml` はユーザー自作のワークフローであり、継続して利用するため維持します。
> - `ci.yml` は `runs-on: blacksmith-...` という特殊なランナーを使用しており、標準の GitHub Actions 環境では動作しません。また、非常に大規模なテストが含まれており、個人用フォークでは過剰であるため削除します。
> - `workflow-sanity.yml` はワークフローファイル内のタブ混入チェックのみであり、不要と判断しました。

## Verification Plan

### Automated Tests

- `actionlint` を実行して、残ったワークフローファイルに構文エラーがないか確認します。

  ```bash
  actionlint .github/workflows/*.yml
  ```

### Manual Verification

- GitHub 画面上で、不要なワークフローが「Actions」タブから消えていることを確認します。
- ローカルで `git status` を確認し、意図しないファイルが削除されていないか最終確認します。
