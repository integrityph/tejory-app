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

### For Google Play:

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

### For Apple App Store:

Before you build the bindle, make sure you have all the API keys for production.

- Assuming there are two key `XXX=1234567890` and `YYY=0987654321`.
- Synchronize your API keys into `ios/Runner/GeneratedPluginRegistrant.h`:

```
flutter build ios \
  --dart-define="APIKEY_XXX=1234567890" \
  --dart-define="APIKEY_YYY=0987654321"
```

- Open the app in XCode `ios/Runner.xcworkspace`
- In `Signing & Capabilities` make sure you are signed in to the Team `K H Trading Group INC`
- The `secp256k1` library is already pre-compiled. But if you need to compile it from source, follow the instruction in "Compile `secp256k1` for iOS".
- To start publishing, `Product` -> `Archive` then click on `Validate App`
- Once Validation is completed successfully, click on `Distribute App` and choose `App Connect`.
- Contact a team lead to publish the new release.

## Build `secp256k1` from Source

Before you start, make you you clone the librabry from `https://github.com/bitcoin-core/secp256k1` to `android/app/src/main/cpp/`.

```
cd android/app/src/main/cpp/
git clone https://github.com/bitcoin-core/secp256k1
cd secp256k1
git checkout v0.6.0
```

### For Android

A normal build will build it as part of the normal pipeline.

### For iOS

- Run the iOS build script:

```
cd android/app/src/main/cpp/
chmod +x compile_secp256k1_ios.sh
./compile_secp256k1_ios.sh
```

- You should see at the end of the script:

```
✅ Done! XCFramework created at android/app/src/main/cpp/secp256k1.xcframework
You can now add this XCFramework to your Xcode project.
```

- Drag and drop the `secp256k1.xcframework` folder into your XCode project.
- In `Runner` project, make sure the target is `Runner`.
- Under `General`, scroll down to `Framework Libraries and Embedded Context`, and make sure `secp256k1.xcframework` is set as `Do Not Embed`
- Under `Build Settings`, scroll down or search for `Other Linker Flags` and make sure you have these two falgs (`-ObjC`, `-all_load`).
