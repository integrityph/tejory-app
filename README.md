# Tejory App

This is the app for [Tejory Hardware Wallet](https://tejory.io).

TO REPORT A SECURITY ISSUE: `security@tejory.io`

## Getting Started

- Language/Framework: Dart/Flutter
- Platform Compatibility: Android / iOS
- Hardware Requirements: NFC

## Before you build:

Make sure you use your own API key in `lib/api_keys/api_keys.dart`

## To build:

In debug mode:

```
flutter run --debug
```

In release mode:

```
flutter run --release
```

## For Production Builds:

For Google Play:
- Ensure you have Google Play singing key setup `android/key.properties`
- Make sure you have Google Play singing key at the path from your `android/key.properties`
- Run the following commands to ensure the app bundle runs as expected:

Before you build the bindle, make sure you have all the API keys for production.

- Assuming there are two key `XXX=1234567890` and `YYY=0987654321`.

Build the bundle:

```
flutter build appbundle --release \
  --dart-define="APIKEY_XXX=1234567890" \
  --dart-define="APIKEY_YYY=0987654321"
```

- Assuming your absolute path for your app is `/home/dev/workspace/tejory-app`
- Assuming the absolute path to your signing keys is `/home/dev/.keys`
- Assuming the singing key name is `upload`
- Create a file (if you don't have it) called `pass.txt` with the signing key password

Extract APKS file:

```
bundletool build-apks \
  --overwrite --mode=universal \
  --bundle=/home/dev/workspace/tejory-app/build/app/outputs/bundle/release/app-release.aab \
  --output=/home/dev/workspace/tejory-app/build/app/outputs/bundle/release/app-release.apks \
  --ks=/home/dev/.keys/upload-keystore.jks \
  --ks-pass=file:pass.txt \
  --ks-key-alias=upload \
  --key-pass=file:pass.txt
```

Install the APKS file on android:

```
bundletool install-apks \
  --apks=/home/dev/workspace/tejory-app/build/app/outputs/bundle/release/app-release.apks
```
