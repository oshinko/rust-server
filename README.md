# Rust Server

Steam で配信されている Rust のカスタムサーバーに関するリポジトリです。

## Windows サーバーを起動

主に、ゲームシステムを理解するためのチュートリアル的なソロプレイ用途のサーバーです。
お使いの PC (ローカル環境) で起動し、用が済んだら停止する、といった使い方を想定しています。

1. このリポジトリをローカルにダウンロードする
2. [./start.bat](./start.bat) をダブルクリックし、サーバーを起動する
3. サーバーの起動が終わるまで待機 (約 5 分)
4. Rust クライアントを起動し、F1 キーを押下し、コンソールを開く
5. `client.connect` と入力し、エンターキーを押下し、サーバーに接続する

もしくは、コマンドプロンプトを起動し、次のコマンドを実行することで、サーバーが起動します。

```bat
cd \path\to\repo
.\start.bat
```

## Linux サーバーを起動

コミュニティサーバーを公開する場合に使用します。

```sh
cp .env.template .env
. .env
sudo STEAMCMD=$HOME/Steam/steamcmd.sh sh ./start.sh
```

留意点は次の通り。

- AWS EC2 t3a.large (メモリ 8GB, ストレージ 32GB) で実権済み
- AWS EC2 t3a.medium (メモリ 4GB) では起動しなかった

## Docker 環境でサーバーを起動

Docker でサーバーを起動する場合に使用します。

Linux 環境の場合、次のコマンドで Docker をインストールします。

```sh
curl https://raw.githubusercontent.com/oshinko/ops/main/src/install/docker-on-linux.sh | sudo sh
```

サーバーを起動します。

```sh
cp .env.template .env
sudo docker-compose up -d
```

留意点は次の通り。

- Docker Desktop (Windows) では、正常に起動したように見えるものの、クライアントから接続できない

## 備考

### RustDedicated コマンド

- コマンドライン引数 `+rcon.password` に `password` を設定すると rcon が有効にならない
- コミュニティサーバーとしてゲーム内に表示するためには `+server.hostname` 以外の情報が必要 (?)
  - 時間が経てば一覧に表示されるとの情報もある
- `+server.saveinterval` を短くし過ぎると処理が詰まる場合がある
  - Steam 関連の通信処理が失敗してしまう？
  - ポートを開放し、コミュニティサーバーとして公開した場合のみ起こり得る？
  - `10` (秒) だと短すぎるので `60` 程度にしておいた方が無難 (デフォルトは `300` とのこと)
