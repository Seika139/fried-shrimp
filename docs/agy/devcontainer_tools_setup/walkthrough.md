# Devcontainerへのツール追加 修正内容の確認

devcontainer 環境において、要求された CLI ツールを利用可能にするための設定を行いました。

## 変更内容

### [devcontainer.json](file:///.devcontainer/devcontainer.json)

`features` セクションを追加し、以下のツールを導入するように設定しました。

- `ghcr.io/devcontainers/features/common-utils:1` (bash をデフォルトに維持)
- `ghcr.io/devcontainers-contrib/features/fzf:1`
- `ghcr.io/devcontainers-contrib/features/fd:1`
- `ghcr.io/devcontainers-contrib/features/eza:1`
- `ghcr.io/devcontainers-contrib/features/zoxide:1`
- `ghcr.io/devcontainers-contrib/features/ripgrep:1`
- `ghcr.io/devcontainers-contrib/features/dotenvx:1`
- `ghcr.io/devcontainers-contrib/features/mise:1`

## 検証結果

### 自動確認

- `devcontainer.json` の JSON 構文チェックを行い、正常であることを確認しました。

### 手動確認のお願い

ホスト環境からツールを直接確認することはできないため、以下の手順で動作確認をお願いします。

1. VS Code で **"Dev Containers: Rebuild Container"** を実行し、コンテナを再構築します。
2. ターミナルを開き、以下のコマンドが動作することを確認してください。
   - `less --version`
   - `fzf --version`
   - `fd --version`
   - `eza --version`
   - `dotenvx --version`
   - `mise --version`
   - `zoxide --version`
   - `rg --version`
