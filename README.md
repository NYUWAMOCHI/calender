# Calender

卓日程くん

## 機能

- **Rails 8.0.2**
- **MySQL**
- **Tailwind CSS**
- **Hotwire (Turbo + Stimulus)**
- **Import Maps**
- **Docker**
- **Kamal**

## 前提条件

- Ruby 3.4.2
- MySQL 5.7以上
- Node.js 18以上（Tailwind CSSコンパイル用）
- Docker（オプション、コンテナ化デプロイ用）

## インストール

1. **リポジトリをクローン**
   ```bash
   git clone <repository-url>
   cd calender
   ```

2. **Ruby依存関係をインストール**
   ```bash
   bundle install
   ```

3. **Node.js依存関係をインストール**
   ```bash
   npm install
   ```

4. **データベースを設定**
   ```bash
   cp config/database.yml.example config/database.yml
   # config/database.ymlを編集してデータベース認証情報を設定
   ```

5. **データベースをセットアップ**
   ```bash
   rails db:create
   rails db:migrate
   rails db:seed
   ```

6. **アセットをコンパイル**
   ```bash
   rails assets:precompile
   ```

## 開発

### サーバーの起動
```bash
# Railsサーバーを起動
rails server

# Tailwind CSSウォッチャーを起動（別ターミナルで）
rails tailwindcss:watch
```

### テストの実行
```bash
# すべてのテストを実行
bundle exec rspec

# 特定のテストファイルを実行
bundle exec rspec spec/models/user_spec.rb

# カバレッジ付きでテストを実行
COVERAGE=true bundle exec rspec
```

### コード品質
```bash
# RuboCopを実行
bundle exec rubocop

# RuboCop違反を自動修正
bundle exec rubocop -a

# Brakemanセキュリティスキャナーを実行
bundle exec brakeman
```

## デプロイ

このアプリケーションは[Kamal](https://kamal-deploy.org/)を使用してデプロイします。

```bash
# 本番環境にデプロイ
kamal deploy

# ステージング環境にデプロイ
kamal deploy --config config/deploy.staging.yml
```

## プロジェクト構造

```
calender/
├── app/                    # アプリケーションコード
│   ├── controllers/       # コントローラー
│   ├── models/           # モデル
│   ├── views/            # ビュー
│   ├── assets/           # アセットパイプライン
│   └── javascript/       # JavaScriptファイル
├── config/               # 設定ファイル
├── db/                   # データベースファイル
├── docs/                 # ドキュメント
├── test/                 # テストファイル
└── public/               # パブリックアセット
```

## コントリビューション

1. リポジトリをフォーク
2. featureブランチを作成（`git checkout -b feature/amazing-feature`）
3. 変更をコミット（`git commit -m 'Add amazing feature'`）
4. ブランチにプッシュ（`git push origin feature/amazing-feature`）
5. プルリクエストを作成

## ライセンス

このプロジェクトはMITライセンスの下で公開されています。詳細は[LICENSE](LICENSE)ファイルを参照してください。

## サポート

サポートや質問がある場合は、GitHubリポジトリでIssueを作成してください。
