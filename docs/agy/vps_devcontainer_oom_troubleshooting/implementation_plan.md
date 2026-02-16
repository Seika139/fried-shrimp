# 実装計画 - VPS Devcontainer OOM トラブルシューティング

## 概要

メモリ 4GB の VPS 環境において、Devcontainer の起動（特に VS Code Server のインストール）中にプロセスが強制終了（Exit code 137）される問題を解決します。

## 背景・原因分析

`free -m` の結果から、以下の状態が推測されます：

- `available` (3.1Gi) は十分にあるように見えますが、`free` (112Mi) は非常に低いです。
- `buff/cache` (3.3Gi) がメモリの大部分を占めています。
- VS Code Server のダウンロードや展開はディスク I/O を伴い、キャッシュをさらに圧迫します。
- **原因の推測**: カーネルがキャッシュを解放して新しいプロセスにメモリを割り当てる速度よりも、急激なメモリ要求が上回った場合、あるいは I/O 待ちでキャッシュが「汚れて」いて即座に解放できない場合に、OOM キラーが作動して SIGKILL (137) を送っている可能性があります。
- Swap (2GB) がほとんど利用されていないのも、メモリ不足が急激すぎてスワップアウトが追いつかなかった可能性を示唆しています。

## 提案する対策

### 1. 原因の確定（dmesg の確認）

実際に OOM キラーが作動したのかを確認します。VPS ターミナルで以下を実行してください。

```bash
dmesg -T | grep -i oom
```

または

```bash
journalctl -xe | grep -i "out of memory"
```

### 2. VPS カーネル設定の調整

スワップをより積極的に利用し、急激なメモリ圧迫を緩和します。

#### swappiness の変更

```bash
sudo sysctl vm.swappiness=60
```

（デフォルトの 10 などが低すぎる場合、キャッシュ解放よりもプロセスの殺害が優先されるケースがあります）

### 3. Swap 領域の増設（推奨）

現在 2GB ですが、4GB 程度に増設しておくとより安心です。

```bash
sudo swapoff /swapfile
sudo fallocate -l 4G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile
```

## 変更内容

現時点ではコードの自動修正よりも、環境設定の調整を優先します。

## 検証計画

1. ユーザーに `dmesg` で OOM を確認していただく。
2. `vm.swappiness` の調整または Swap 増設後、再度 "Reopen in Container" を実行。
