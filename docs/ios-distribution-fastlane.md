# iOS Distribution with Flutter and fastlane

This document describes how to build Tsubusu as an iOS app with Flutter and upload it to TestFlight with fastlane.

## Recommended local commands

Install the locked Ruby dependencies and run the complete build-and-upload flow with one command:

```bash
make ios-beta
```

By default, `ios-beta` builds an IPA with Flutter and uploads it to TestFlight. To upload an IPA that has already been built, reuse it without rebuilding:

```bash
make ios-beta IPA_PATH=build/ios/ipa/tsubusu.ipa
```

The App Store Connect API key is loaded from `ASC_API_KEY_PATH` when set, or from `~/.config/tsubusu/api_key.json` by default.

## Prerequisites

- You are enrolled in the Apple Developer Program.
- The `Tsubusu` app has been created in App Store Connect.
- The Bundle ID is `com.shinyayoshida.tsubusu`.
- Flutter is used for iOS builds, and fastlane is used for signing and TestFlight uploads.
- Xcode is installed because Flutter and fastlane use `xcodebuild`; the Xcode GUI is not required for the normal workflow.

This repository must not contain API keys, `.p8` files, certificates, provisioning profiles, IPA files, or other distribution artifacts. The `.gitignore` file excludes these items. Store the API key JSON and `.p8` file outside the repository or in a CI secret store.

`Team ID` and Bundle ID are public identifiers used by Apple to identify an app and developer team; they are not private keys. They are still associated with an Apple Developer account, so avoid exposing them unnecessarily in logs or screenshots. The contents of the `.p8` file, the private-key portion of the API key JSON, certificates, and provisioning profiles must be treated as secrets.

## Manual and CLI tasks

| Task | Method |
| --- | --- |
| Create the App Store Connect API key and download the `.p8` file for the first time | App Store Connect UI |
| Create the Bundle ID, certificate, and provisioning profile | fastlane CLI |
| Update the Bundle ID in the iOS project | fastlane CLI |
| Build the IPA | Flutter CLI |
| Upload to TestFlight | fastlane CLI |
| Configure TestFlight information, export compliance, and submit for review | App Store Connect UI; the UI is most practical for the first setup |

## 1. Create an App Store Connect API key

Create a Team API Key in App Store Connect:

`Users and Access` → `Integrations` → `App Store Connect API` → `Team Keys`

Record the following values:

- Issuer ID
- Key ID
- The downloaded `AuthKey_<KEY_ID>.p8` file

Apple allows the `.p8` file to be downloaded only once after creation. If it is lost, revoke the key in Apple’s systems and create a new one. Never commit the private key to the source repository.

Store the file locally, for example:

```bash
mkdir -p ~/.config/tsubusu
mv ~/Downloads/AuthKey_<KEY_ID>.p8 ~/.config/tsubusu/
chmod 600 ~/.config/tsubusu/AuthKey_<KEY_ID>.p8
```

Create the fastlane API key configuration outside the repository as well.

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

## 2. Add fastlane to the project

Create `ios/Gemfile` to pin the Ruby dependency:

```ruby
source "https://rubygems.org"

gem "fastlane", "= 2.231.1"
```

Install fastlane from the `ios` directory:

```bash
cd ios
bundle install
bundle exec fastlane --version
```

The Makefile wraps these commands for the normal local workflow. Run `make ios-fastlane-install` directly when only the Ruby dependencies need to be installed.

## 3. Prepare the Bundle ID

The App Store Connect app and the Bundle ID in the Apple Developer Portal are separate resources. If the Bundle ID does not exist yet, create it with fastlane:

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

`produce` may request Apple ID authentication. If the Bundle ID already exists, do not repeat this step; use the existing Bundle ID.

Update the Bundle ID in the iOS project:

```bash
cd ios
bundle exec fastlane run update_app_identifier \
  xcodeproj:Runner.xcodeproj \
  plist_path:Runner/Info.plist \
  app_identifier:com.shinyayoshida.tsubusu
```

After the update, verify that every iOS target configuration, including Debug, Release, and Profile, uses `com.shinyayoshida.tsubusu`.

## 4. Manage signing with fastlane match

`match` creates Apple signing certificates and provisioning profiles, encrypts them, and stores them in a dedicated private repository.

Create a private repository separate from the application source repository. For example:

```bash
gh repo create ShinyaYoshida-biomet/tsubusu-ios-certificates --private
```

This repository contains signing material and must remain private. Initialize it from the `ios` directory:

```bash
cd ios
bundle exec fastlane match init
```

Use the following answers when prompted:

- Storage mode: `git`
- Git repository: the URL of the private repository you created

Create or retrieve the App Store provisioning profile and certificate:

```bash
cd ios
bundle exec fastlane match appstore \
  --api_key_path ~/.config/tsubusu/api_key.json
```

This creates or retrieves an Apple Distribution Certificate and an App Store provisioning profile, then installs them in the Mac Keychain. The encrypted signing material is stored in the private `match` repository.

If prompted for a passphrase, create a value for `MATCH_PASSWORD`. Store it in a password manager because it is required to decrypt the certificate repository.

Verify that the signing certificate is available:

```bash
security find-identity -v -p codesigning
```

If an `Apple Distribution: ...` identity is listed, a Distribution certificate is available. Existing `.mobileprovision` files may belong to another app or may be expired, so their presence alone does not confirm that Tsubusu signing is ready.

## 5. Test locally and build the IPA

Run static analysis and tests first:

```bash
fvm flutter analyze
fvm flutter test
```

Build the IPA using `ios/ExportOptions.plist` and the local signing configuration:

```bash
make ios-ipa
```

You can optionally specify the version and build number with environment variables:

```bash
make ios-ipa BUILD_NAME=1.0.6 BUILD_NUMBER=3
```

The IPA is normally written to:

```text
build/ios/ipa/tsubusu.ipa
```

App Store Connect does not accept the same build number twice. Increase the build number when rebuilding the same app version.

## 6. Upload to TestFlight with fastlane

```bash
make ios-beta
```

If an IPA already exists, pass it through `IPA_PATH` so fastlane uploads it directly:

```bash
make ios-beta IPA_PATH=../build/ios/ipa/tsubusu.ipa
```

Wait for App Store Connect to finish processing the upload. For the first release, review the following items:

- Export Compliance answers
- TestFlight Beta App Information
- Internal and external testers
- Review submission, if required

The IPA upload can be completed from the CLI, but the initial app information and review-related fields are most practical to configure in App Store Connect.

## 7. App Store upload lane

Upload an existing IPA to App Store Connect without submitting it for review:

```bash
make ios-release IPA_PATH=build/ios/ipa/tsubusu.ipa
```

## 8. Moving the workflow to GitHub Actions

Store the following values in GitHub Secrets for CI:

- App Store Connect API key material, or a securely generated API key JSON file
- `MATCH_PASSWORD`
- Credentials that allow CI to clone the private `match` repository

Never commit `.p8` files, API key JSON files, `MATCH_PASSWORD`, certificates, or provisioning profiles to the source repository. Inject secrets from GitHub Secrets or another CI secret store for both local and CI workflows.

## Release checklist

- The Bundle ID is consistently `com.shinyayoshida.tsubusu`.
- The App Store Connect app and Developer Portal Bundle ID match.
- `security find-identity -v -p codesigning` lists a valid Apple Distribution certificate.
- The build number is greater than every build previously uploaded.
- User Todo data is restored to the same list after restarting the app.
- App Store Connect export compliance, TestFlight information, screenshots, and descriptions have been reviewed.

## References

- [fastlane documentation](https://docs.fastlane.tools/)
- [Flutter iOS deployment documentation](https://docs.flutter.dev/deployment/ios)
- [App Store Connect Help](https://developer.apple.com/help/app-store-connect/)
