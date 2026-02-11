# Fork リポジトリ管理・運用ガイド

OpenClaw 本家 (`openclaw/openclaw`) から Fork したこのリポジトリを、効率的に運用するためのガイドです。
現在は **`develop` ブランチを開発のメイン**とし、**`main` ブランチを本家（upstream）への追従用**として使用する運用を採用しています。

## 1. ブランチの役割

- **`develop`**: **あなたの作業用メインブランチ**。リポジトリのデフォルトブランチです。
  - **保護ルール**: 直接のプッシュは禁止されており、**必ずプルリクエスト (PR) を経由してマージする必要があります。**
- **`main`**: **本家 (upstream) 追従用ブランチ**。本家の `main` と常に一致させ、あなたの変更は直接加えません。

---

## 2. リモート設定の確認

以下の 2 つのリモートが設定されていることを確認してください。

- **`origin`**: 自身の GitHub リポジトリ (`Seika139/fried-shrimp`)
- **`upstream`**: 本家のリポジトリ (`openclaw/openclaw`)

```bash
$ git remote -v
origin    git@github.com:Seika139/fried-shrimp.git (fetch/push)
upstream  https://github.com/openclaw/openclaw.git (fetch/push)
```

---

## 3. main ブランチの更新手順 (Upstream 追従)

本家 (upstream) に新しい更新があった場合、まず `main` ブランチを同期させます。
`mise run follow-upstream` コマンドで安全に一括更新できます。

```bash
# コマンド一つで main の切り替え、fetch、reset、origin へのプッシュを行います
mise run follow-upstream
```

> [!IMPORTANT]
> 手動で行う場合は、必ず `main` に切り替えてから `git reset --hard upstream/main` を行ってください。

---

## 4. develop ブランチの更新手順 (PR 経由の統合)

`develop` ブランチは保護されているため、`main` の更新を取り込むには **GitHub 上で PR を作成してマージ** する必要があります。

### 手順

1. **同期用ブランチの作成とプッシュ**:

    ```bash
    git checkout main
    git checkout -b sync-upstream-to-develop
    git push origin sync-upstream-to-develop
    ```

2. **GitHub で PR を作成**:
    - `base: develop` ← `compare: sync-upstream-to-develop` の PR を作成します。
3. **マージと後片付け**:
    - GitHub 上で PR をマージします。
    - ローカルに戻り、作業を再開します。

    ```bash
    git checkout develop
    git pull origin develop
    git branch -d sync-upstream-to-develop
    ```

---

## 5. 日々の開発フロー

1. `develop` から作業用ブランチ（例: `feature/my-fix`）を作成。
2. 作業が完了したら `origin` にプッシュし、`develop` への PR を作成。
3. PR をマージして `develop` を更新。

---

## 6. 運用のコツ

- **GitHub の "Sync fork" ボタンは使わない**: `main` を直接更新するボタンですが、履歴をクリーンに保つため `mise run follow-upstream` (CLI) の使用を推奨します。
- **自分の変更は常に PR で**: デフォルトブランチ (`develop`) は保護されているため、直接のプッシュはエラーになります。
