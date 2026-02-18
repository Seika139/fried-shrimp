# Devcontainer ビルド失敗の解決 実装計画

## 概要

`ghcr.io/devcontainers-contrib/features/zoxide:1` の解決に失敗したため、より確実な方法でツールをインストールするように構成を変更します。

## 課題と解決策

- **課題:** `devcontainers-contrib` から `devcontainers-extra` へのリダイレクトに伴い、一部の Feature (zoxide 等) が見つからない。
- **解決策:**
  - Debian (Bookworm) の標準レポジトリに含まれるツール (`fzf`, `ripgrep`, `fd-find`, `zoxide`) は、汎用的な `apt-packages` Feature を使用してインストールします。
  - 標準レポジトリにないツール (`eza`, `mise`, `dotenvx`) は、リダイレクト先を考慮した名称で個別の Feature を使用します。
  - Debian では `fd` コマンドが `fdfind` という名前になるため、`postCreateCommand` でエイリアスを設定します。

## 提案される変更

### Devcontainer 設定

#### [MODIFY] [devcontainer.json](file:///.devcontainer/devcontainer.json)

```json
  "features": {
    "ghcr.io/devcontainers/features/common-utils:1": {
      "installZsh": true,
      "configureZshAsDefaultShell": false
    },
    "ghcr.io/devcontainers-contrib/features/apt-packages:1": {
      "packages": "fzf,ripgrep,fd-find,zoxide"
    },
    "ghcr.io/devcontainers-contrib/features/eza:1": {},
    "ghcr.io/devcontainers-contrib/features/mise:1": {},
    "ghcr.io/devcontainers-contrib/features/dotenvx:1": {}
  },
  "postCreateCommand": "mkdir -p ~/.local/bin && ln -s $(which fdfind) ~/.local/bin/fd || true"
```

## 検証計画

### 自動テスト

- `devcontainer.json` の JSON 形式が正しいことを確認します。

### 手動確認

- devcontainer をリビルドし、各コマンドが正常にインストールされ、実行可能であることを確認します。
