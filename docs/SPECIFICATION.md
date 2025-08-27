# 卓上ゲーム調整アプリ 仕様書

## 1. プロジェクト概要

### 1.1 アプリケーション名
卓日程くん

### 1.2 目的
卓上ゲーム（TRPG、ボードゲーム等）の参加者間で日程調整を効率化し、Google Calendarとの連携により自動化されたスケジュール管理を実現する。

### 1.3 技術スタック
- **フレームワーク**: Rails 8
- **認証**: Devise + OmniAuth Google OAuth2
- **外部API**: Google Calendar API v3
- **データベース**: MySQL2
- **フロントエンド**: Hotwire (Turbo + Stimulus)
- **CSS**: Tailwind CSS

## 2. 機能要件

### 2.1 ユーザー管理機能
- **ログイン・ログアウト**: Googleアカウントによる認証
- **ユーザープロフィール**: 自己紹介、プレイ履歴の管理
- **権限管理**: KP（キーパー：別名ゲームマスター）とPL（プレイヤー）のロール設定

### 2.2 グループ・セッション管理
- **シナリオグループ作成**: KPがセッションを作成し、日程を設定
- **メンバー管理**: PLの参加・退出管理
- **ロール設定**: KP/PLの権限管理

### 2.3 カレンダー連携機能
- **Google Calendar連携**: ユーザーのGoogle Calendarからデータ取得
- **空き時間自動抽出**: 全メンバーの空き時間を自動計算
- **日程自動挿入**: 決定された日程を全メンバーのGoogle Calendarに自動登録

### 2.4 シナリオ管理
- **シナリオタグ付け**: 過去のプレイ履歴をタグ付け
- **シナリオ検索**: タグによる検索・フィルタリング

## 3. データベース設計

### 3.1 テーブル構造

#### users（ユーザー）
```sql
- id: int (PK) - 主キー、primary key, unique
- name: string - 名前、length: { maximum: 20 }
- email: string - メールアドレス（ログインID）、unique
- password: string - パスワード、length: { minimum: 6 }（devise標準）
- confirmed_password: string - 確認用パスワード（DBには保存しない）
- google_uid: int - GoogleUID、unique
- google_access_token: string - Google API用アクセストークン
- google_refresh_token: string - Google API用リフレッシュトークン
- google_token_expires_at: datetime - Googleトークンの有効期限
- created_at: timestamp
- updated_at: timestamp

# リレーション
- has_many: groups
- has_many: events
- has_one: calendar
- has_many: scenarios
```

#### groups（シナリオグループ）
```sql
- id: int (PK) - 主キー、primary key, unique
- user_id: int (FK) - ユーザーID、unique
- owner_id: string - オーナーID、unique
- name: string - グループ名
- intro: string - グループ紹介
- created_at: timestamp
- updated_at: timestamp

# リレーション
- belongs_to: user
- has_many: memberships
- has_many: events
```

#### memberships（メンバーシップ）
```sql
- id: int (PK) - 主キー、unique
- user_id: int (FK) - ユーザーID、unique
- group_id: int (FK) - グループID、unique
- role: int - ロール（KP/PL）
- created_at: timestamp
- updated_at: timestamp
- deleted_at: timestamp - 論理削除用

# リレーション
- belongs_to: user
- belongs_to: group
```

#### events（卓の日程）
```sql
- id: int (PK) - 主キー、primary key, unique
- user_id: int (FK) - ユーザーID、unique
- group_id: int (FK) - グループID、unique
- title: string - イベントタイトル、length: { maximum: 20 }
- start_time: int - 卓開始時間
- end_time: int - 卓終了時間
- description: string - 説明、length: { maximum: 3000 }
- google_event_id: string - Google CalendarイベントID
- created_at: timestamp
- updated_at: timestamp

# リレーション
- belongs_to: user
- belongs_to: group
```

#### calendars（ユーザーカレンダー）
```sql
- id: int (PK) - 主キー、primary key, unique
- user_id: int (FK) - ユーザーID、unique
- google_calendar_id: string - Google Calendar ID、unique
- google_event_id: string - Google Event ID、unique
- name: string - カレンダー名
- start_time: datetime - 開始時間
- end_time: datetime - 終了時間
- created_at: timestamp
- updated_at: timestamp

# リレーション
- belongs_to: user
```

#### profiles（ユーザープロフィール）
```sql
- id: int (PK) - 主キー、primary key, unique
- group_id: int (FK) - グループID、unique
- user_id: int (FK) - ユーザーID、unique
- title: string - タイトル、length: { maximum: 20 }
- description: int - 説明、length: { maximum: 3000 }
- holiday_start_time: int - 休日の卓開始時間
- holiday_end_time: int - 休日の卓終了時間
- start_time: int - 平日の卓開始時間
- end_time: int - 平日の卓終了時間
- created_at: timestamp
- updated_at: timestamp

# リレーション
- belongs_to: group
- belongs_to: user
```

#### scenarios（シナリオ）
```sql
- id: int (PK) - 主キー、primary key, unique
- user_id: int (FK) - ユーザーID、unique
- senario_id: string - シナリオID、unique
- created_at: timestamp
- updated_at: timestamp

# リレーション
- belongs_to: user
```

#### availability（空き時間テーブル）
```sql
- id: int (PK) - 主キー、primary key, unique
- user_id: int (FK) - ユーザーID、unique
- start_time: datetime - 開始時間
- end_time: datetime - 終了時間
- source: string - 手動入力かGoogle Calendarか（manual/google_calendar）
- created_at: timestamp
- updated_at: timestamp

# リレーション
- belongs_to: user
```

#### user_scenarios（ユーザーシナリオ中間テーブル）
```sql
- id: bigint (PK)
- user_id: bigint (FK -> users.id)
- scenario_id: bigint (FK -> scenarios.id)
- status: string (played, want_to_play, completed)
- notes: text (メモ)
- created_at: timestamp
- updated_at: timestamp
```

### 3.2 インデックス
- users.google_uid (UNIQUE)
- memberships.user_id, memberships.group_id (複合)
- events.group_id, events.start_time
- calendars.user_id

## 4. API設計

### 4.1 Google Calendar API連携
- **認証フロー**: OAuth2.0認証コードフロー
- **スコープ**: `https://www.googleapis.com/auth/calendar`
- **主要エンドポイント**:
  - カレンダー一覧取得
  - イベント一覧取得
  - イベント作成・更新・削除
  - 空き時間検索

### 4.2 アプリケーションAPI
- **認証**: JWTトークン（Devise）
- **レスポンス形式**: JSON
- **エラーハンドリング**: 標準的なHTTPステータスコード

## 5. 画面設計

### 5.1 主要画面
1. **ログイン画面**: Google OAuth認証
2. **ダッシュボード**: 参加グループ一覧、最近の活動
3. **グループ詳細**: メンバー一覧、日程調整
4. **カレンダー表示**: 個人カレンダー、グループカレンダー
5. **空き時間調整**: 全メンバーの空き時間表示、日程提案
6. **プロフィール**: ユーザー情報編集、シナリオ履歴

### 5.2 UI/UX要件
- **レスポンシブデザイン**: モバイル・デスクトップ対応
- **直感的な操作**: ドラッグ&ドロップによる日程調整
- **リアルタイム更新**: WebSocketによる即座の反映
- **アクセシビリティ**: キーボード操作、スクリーンリーダー対応

## 6. ビジネスロジック

### 6.1 空き時間計算アルゴリズム
1. 全メンバーのGoogle Calendarからイベント情報を取得
2. 指定期間内の全イベントを時系列でソート
3. 重複する時間帯を除外
4. 残った空き時間を候補として提示

### 6.2 日程調整フロー
1. **提案フェーズ**: KPが候補日程を提案
2. **確認フェーズ**: PLが参加可能かどうか確認
3. **決定フェーズ**: 全員参加可能な日程を決定
4. **登録フェーズ**: 決定された日程を全メンバーのGoogle Calendarに登録

## 7. セキュリティ要件

### 7.1 認証・認可
- **OAuth2.0**: Googleアカウントによる安全な認証
- **トークン管理**: アクセストークンの安全な保存・更新
- **権限管理**: ロールベースアクセス制御

### 7.2 データ保護
- **個人情報**: 最小限の情報収集
- **API制限**: Google APIの利用制限への対応
- **ログ管理**: アクセスログの適切な管理

## 8. パフォーマンス要件

### 8.1 レスポンス時間
- **ページ表示**: 3秒以内
- **API応答**: 1秒以内
- **空き時間計算**: 5秒以内

### 8.2 スケーラビリティ
- **同時ユーザー**: 1000人以上
- **データベース**: 適切なインデックス設計
- **キャッシュ**: Redisによるセッション・データキャッシュ

## 9. 運用・保守

### 9.1 監視・ログ
- **アプリケーションログ**: エラー・アクセスログ
- **パフォーマンス監視**: レスポンス時間・エラー率
- **Google API制限監視**: クォータ使用状況

### 9.2 バックアップ・復旧
- **データベース**: 日次バックアップ
- **設定ファイル**: バージョン管理
- **災害復旧**: 24時間以内の復旧

## 10. 開発・テスト

### 10.1 開発環境
- **ローカル環境**: Docker Compose
- **テスト環境**: CI/CDパイプライン
- **本番環境**: クラウドプラットフォーム

### 10.2 テスト戦略
- **単体テスト**: RSpec
- **統合テスト**: Capybara
- **APIテスト**: Postman/Newman
- **E2Eテスト**: Playwright

## 11. リリース計画

### 11.1 Phase 1（MVP）
- 基本的なユーザー認証
- グループ作成・管理
- 基本的なカレンダー表示

### 11.2 Phase 2
- Google Calendar連携
- 空き時間計算
- 日程自動登録

### 11.3 Phase 3
- シナリオ管理
- 高度なUI/UX
- モバイルアプリ

## 12. リスク・課題

### 12.1 技術的リスク
- **Google API制限**: クォータ超過への対応
- **認証トークン**: 期限切れ・無効化への対応
- **データ同期**: リアルタイム性の確保

### 12.2 運用リスク
- **ユーザー増加**: スケーラビリティの確保
- **データ整合性**: 複数カレンダー間の同期
- **プライバシー**: 個人情報の適切な管理

## 13. 成功指標

### 13.1 ユーザー指標
- **月間アクティブユーザー**: 1000人以上
- **ユーザー満足度**: 4.0/5.0以上
- **リピート率**: 80%以上

### 13.2 機能指標
- **日程調整完了率**: 90%以上
- **Google Calendar連携成功率**: 95%以上
- **システム稼働率**: 99.9%以上

---

**作成日**: 2024年12月
**バージョン**: 1.0
**作成者**: AI Assistant 