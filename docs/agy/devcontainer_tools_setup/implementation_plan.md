# Devcontainerへのツール追加 実装計画

devcontainer 環境において、利便性向上のために以下の CLI ツールを利用可能にします。

- less
- fzf
- fd
- eza
- dotenvx
- mise
- zoxide
- rg (ripgrep)

## 提案される変更

### Devcontainer 設定

#### [MODIFY] [devcontainer.json](file:///.devcontainer/devcontainer.json)

`features` セクションを追加し、各ツールを導入します。

```json
  "features": {
    "ghcr.io/devcontainers/features/common-utils:1": {
      "installZsh": true,
      "configureZshAsDefaultShell": false
    },
    "ghcr.io/devcontainers-contrib/features/fzf:1": {},
    "ghcr.io/devcontainers-contrib/features/fd:1": {},
    "ghcr.io/devcontainers-contrib/features/eza:1": {},
    "ghcr.io/devcontainers-contrib/features/zoxide:1": {},
    "ghcr.io/devcontainers-contrib/features/ripgrep:1": {},
    "ghcr.io/devcontainers-contrib/features/dotenvx:1": {},
    "ghcr.io/devcontainers-contrib/features/mise:1": {}
  }
```

## 検証計画

### 自動テスト

- `devcontainer.json` の JSON 形式が正しいことを確認します。

### 手動確認

- devcontainer をリビルドし、各コマンド（`less`, `fzf`, `fd`, `eza`, `dotenvx`, `mise`, `zoxide`, `rg`）がパスに通っており、実行可能であることを確認します。
