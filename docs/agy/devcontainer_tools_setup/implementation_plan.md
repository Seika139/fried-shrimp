# Devcontainer ビルド失敗の解決 (2回目) 実装計画

## 概要

`ghcr.io/devcontainers-contrib/features/dotenvx:1` の解決に失敗し、他の一部の Feature もリダイレクトにより不安定なため、より確実なインストール方法に切り替えます。

## 課題と解決策

- **課題:** `dotenvx` 用の公式/準公式 Feature がレジストリに見つからない。また、一部の Feature (`eza` 等) もリダイレクトの影響で解決が不安定。
- **解決策:**
  - **安定重視:** Debian 標準レポジトリにあるツール (`fzf`, `ripgrep`, `fd`, `zoxide`, `less`) は `apt-packages` 特徴量で一括インストールします。
  - **mise の活用:** `mise` は Feature で導入し、それを利用して `eza` をインストールします。
  - **直接インストール:** `dotenvx` は `postCreateCommand` で公式のインストールスクリプトを実行します。

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
      "packages": "fzf,ripgrep,fd-find,zoxide,less"
    },
    "ghcr.io/devcontainers-contrib/features/mise:1": {}
  },
  "postCreateCommand": "mkdir -p ~/.local/bin && ln -s $(which fdfind) ~/.local/bin/fd || true && curl -sfS https://dotenvx.sh/install.sh | sh && mise use -g eza",
```

## 検証計画

### 自動テスト

- `devcontainer.json` の JSON 形式が正しいことを確認します。

### 手動確認

- devcontainer をリビルドし、全てのツール (`less`, `fzf`, `fd`, `rg`, `zoxide`, `mise`, `eza`, `dotenvx`) が動作することを確認します。
