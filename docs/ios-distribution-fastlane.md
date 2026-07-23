# iOS Distribution with Flutter and fastlane

このドキュメントでは、Tsubusu を Flutter から iOS アプリとしてビルドし、fastlane で TestFlight へアップロードするまでの手順をまとめる。

## 前提

- Apple Developer Program に登録済み
- App Store Connect にアプリ `Tsubusu` を作成済み
- Bundle ID は `com.shinyayoshida.tsubusu`
- iOS のビルドは Flutter、署名と TestFlight へのアップロードは fastlane を使う
- Xcode は GUI 操作のためではなく、`xcodebuild` を利用する Flutter / fastlane の実行環境としてインストール済みであること

## 手作業と CLI で行う作業

| 作業                                                        | 方法                                        |
| ----------------------------------------------------------- | ------------------------------------------- |
| App Store Connect API Key の作成と `.p8` の初回ダウンロード | App Store Connect の画面                    |
| Bundle ID、証明書、Provisioning Profile の作成              | fastlane CLI                                |
| iOS プロジェクトの Bundle ID 更新                           | fastlane CLI                                |
| IPA のビルド                                                | Flutter CLI                                 |
| TestFlight へのアップロード                                 | fastlane CLI                                |
| TestFlight の説明、輸出コンプライアンス、審査提出           | App Store Connect（初回は画面操作が現実的） |

## 1. App Store Connect API Key を作成する

App Store Connect の以下の場所で、Team API Key を作成する。

`Users and Access` → `Integrations` → `App Store Connect API` → `Team Keys`

作成時に次の情報を控える。

- Issuer ID
- Key ID
- ダウンロードした `AuthKey_<KEY_ID>.p8`

`.p8` は作成直後に一度しかダウンロードできない。紛失した場合は Apple 側で revoke して新しいキーを作成する。秘密鍵本体はリポジトリに commit しない。

ローカルでは、例えば次のように保存する。

```bash
mkdir -p ~/.config/tsubusu
mv ~/Downloads/AuthKey_<KEY_ID>.p8 ~/.config/tsubusu/
chmod 600 ~/.config/tsubusu/AuthKey_<KEY_ID>.p8
```

fastlane 用の API Key 設定ファイルもリポジトリ外に作成する。

`~/.config/tsubusu/api_key.json`:

```json
{
  "key_id": "YOUR_KEY_ID",
  "issuer_id": "YOUR_ISSUER_ID",
  "key_filepath": "/Users/YOUR_USERNAME/.config/tsubusu/AuthKey_YOUR_KEY_ID.p8"
}
```

```bash
chmod 600 ~/.config/tsubusu/api_key.json
```

## 2. fastlane をプロジェクトに追加する

Ruby の依存関係を固定するため、`ios/Gemfile` を作成する。

```ruby
source "https://rubygems.org"

gem "fastlane"
```

その後、`ios` ディレクトリで fastlane をインストールする。

```bash
cd ios
bundle install
bundle exec fastlane --version
```

以降の fastlane コマンドは、プロジェクトで固定したバージョンを使うため `bundle exec fastlane` で実行する。

## 3. Bundle ID を準備する

App Store Connect のアプリと、Apple Developer Portal の Bundle ID は別の管理対象である。Bundle ID がまだ存在しない場合は、fastlane で作成する。

```bash
cd ios
bundle exec fastlane produce create \
  --app_identifier com.shinyayoshida.tsubusu \
  --app_name Tsubusu \
  --app_version 1.0 \
  --sku com.shinyayoshida.tsubusu \
  --language English \
  --skip_itc
```

`produce` は Apple ID によるログインを求める場合がある。すでに同じ Bundle ID が存在する場合は、この手順を繰り返さず、その Bundle ID を使う。

次に、iOS プロジェクトの Bundle ID を更新する。

```bash
cd ios
bundle exec fastlane run update_app_identifier \
  xcodeproj:Runner.xcodeproj \
  plist_path:Runner/Info.plist \
  app_identifier:com.shinyayoshida.tsubusu
```

変更後は、Xcode プロジェクト内の Debug / Release / Profile など、すべての iOS ターゲット設定で Bundle ID が `com.shinyayoshida.tsubusu` になっていることを確認する。

## 4. 署名情報を fastlane match で管理する

`match` は Apple の署名証明書と Provisioning Profile を作成し、暗号化して専用の private repository に保存する仕組みである。

アプリのソースコード用リポジトリとは別に、private repository を一つ用意する。例:

```bash
gh repo create ShinyaYoshida-biomet/tsubusu-ios-certificates --private
```

このリポジトリには署名情報が入るため、必ず private にする。作成後、`ios` ディレクトリで初期化する。

```bash
cd ios
bundle exec fastlane match init
```

質問には次のように答える。

- Storage mode: `git`
- Git repository: 作成した private repository の URL

初回の証明書・Provisioning Profile 作成と取得:

```bash
cd ios
bundle exec fastlane match appstore \
  --api_key_path ~/.config/tsubusu/api_key.json
```

この処理では、Apple Distribution Certificate と App Store 用 Provisioning Profile が作成または取得され、Mac の Keychain にインストールされる。暗号化された署名情報は match の private repository に保存される。

パスフレーズを求められたら、`MATCH_PASSWORD` に設定する値を作成する。パスフレーズは証明書リポジトリの復号に必要なので、パスワードマネージャーなどで保管する。

署名証明書が入ったことを確認する。

```bash
security find-identity -v -p codesigning
```

`Apple Distribution: ...` が表示されれば、Distribution 用の署名証明書を利用できる状態である。古い `.mobileprovision` が Mac に残っていても、別アプリ用や期限切れの可能性があるため、その存在だけで Tsubusu の署名が準備済みとは判断しない。

## 5. ローカルでテストして IPA を作る

まず静的解析とテストを実行する。

```bash
fvm flutter analyze
fvm flutter test
```

IPA を作成する。

```bash
fvm flutter build ipa \
  --release \
  --build-name 1.0.0 \
  --build-number 1
```

通常、IPA は次の場所に出力される。

```text
build/ios/ipa/tsubusu.ipa
```

build number は App Store Connect に同じものを再アップロードできない。同じバージョンを再ビルドする場合は、`--build-number` を増やす。

## 6. fastlane で TestFlight にアップロードする

```bash
cd ios
bundle exec fastlane pilot upload \
  --ipa ../build/ios/ipa/tsubusu.ipa \
  --api_key_path ~/.config/tsubusu/api_key.json
```

アップロード後は App Store Connect 側で処理が完了するまで待つ。初回は次の項目を確認する。

- Export Compliance の回答
- TestFlight の Beta App Information
- Internal Tester / External Tester の追加
- 必要に応じた審査提出

IPA のアップロード自体は CLI で完結できるが、初回のアプリ情報や審査関連の入力は App Store Connect で行う。

## 7. 今後の定型 lane

運用が固まったら `ios/fastlane/Fastfile` に lane を追加すると、ビルドと TestFlight upload を一つのコマンドにまとめられる。

```ruby
default_platform(:ios)

platform :ios do
  lane :beta do
    match(
      type: "appstore",
      api_key_path: ENV.fetch("FASTLANE_API_KEY_PATH")
    )

    sh("cd .. && fvm flutter build ipa --release")

    upload_to_testflight(
      ipa: "../build/ios/ipa/tsubusu.ipa",
      api_key_path: ENV.fetch("FASTLANE_API_KEY_PATH")
    )
  end
end
```

```bash
cd ios
FASTLANE_API_KEY_PATH="$HOME/.config/tsubusu/api_key.json" \
  bundle exec fastlane beta
```

## 8. GitHub Actions に移す場合

CI では次の情報を GitHub Secrets に登録する。

- App Store Connect API Key の内容、または安全に生成した API Key JSON
- `MATCH_PASSWORD`
- match 用 private repository を clone するための認証情報

`.p8`、API Key JSON、`MATCH_PASSWORD`、証明書、Provisioning Profile はソースコードリポジトリに commit しない。ローカルと CI で同じ署名情報を使う場合も、秘密情報は GitHub Secrets や CI の secret store から注入する。

## リリース前に確認すること

- Bundle ID が `com.shinyayoshida.tsubusu` で統一されている
- App Store Connect のアプリと Developer Portal の Bundle ID が一致している
- `security find-identity -v -p codesigning` に有効な Apple Distribution 証明書が表示される
- build number が過去にアップロードした値より大きい
- アプリ再起動後もユーザーの Todo データが同じリストに復元される
- App Store Connect の Export Compliance、TestFlight 情報、スクリーンショット、説明文を確認している

## 参考資料

- [Flutter: Build and release an iOS app](https://docs.flutter.dev/deployment/ios)
- [Flutter: Continuous delivery with fastlane](https://docs.flutter.dev/deployment/cd)
- [fastlane: App Store Connect API](https://docs.fastlane.tools/app-store-connect-api/)
- [fastlane: produce](https://docs.fastlane.tools/actions/produce/)
- [fastlane: match](https://docs.fastlane.tools/actions/match/)
- [fastlane: upload_to_testflight / pilot](https://docs.fastlane.tools/actions/upload_to_testflight/)
