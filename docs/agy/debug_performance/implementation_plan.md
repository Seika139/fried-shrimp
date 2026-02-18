# パフォーマンス低下問題の解決 実装計画

## 概要

`mise run gateway` (実態は `node scripts/run-node.mjs`) を実行した際、出力が停止し CPU/メモリに負荷がかかる問題を修正します。

## 解析

- `scripts/run-node.mjs` の `findLatestMtime` 関数が `src` ディレクトリを再帰的にスキャンしています。
- devcontainer (Docker Desktop on Mac 等) では、ファイルシステムのスキャンが同期処理で行われると非常に低速になる場合があります。
- また、予期せぬディレクトリ（循環したシンボリックリンクなど）が含まれている場合、無限ループに陥る可能性があります。

## 提案される変更

### ツールスクリプト

#### [MODIFY] [run-node.mjs](file:///scripts/run-node.mjs)

- `findLatestMtime` 関数に以下の改善を施します：
  - スキャンの開始と終了時にログを出力。
  - 訪問済みのパスを記録し、シンボリックリンクによる循環参照を防止。
  - `.git`, `node_modules`, `.next` などの明らかに不要なディレクトリをスキップ。

```javascript
const findLatestMtime = (dirPath, shouldSkip) => {
  logRunner(`Scanning for changes in ${dirPath}...`);
  let latest = null;
  const queue = [dirPath];
  const visited = new Set(); // 循環参照防止

  while (queue.length > 0) {
    const current = queue.pop();
    if (!current || visited.has(current)) continue;
    visited.add(current);

    // 不要なディレクトリをスキップ
    const base = path.basename(current);
    if (base === "node_modules" || base === ".git" || base === ".next") continue;
...
```

## 検証計画

### 自動テスト

- スクリプトが正常に終了することを確認します。

### 手動確認

- `mise run gateway` を実行し、ハングせずに起動することを確認します。
- ログにより、どの程度の時間がスキャンにかかっているか確認可能になります。
