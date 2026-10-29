### install package

dev_dependencies:
flutter_flavorizr: ^2.4.1

### Generate APK

```
# Generate APK for development
flutter build apk --flavor development

# Generate WEB for production
flutter build web --release --csp

# Generate APK for production
flutter build apk --obfuscate --release --flavor production
flutter build apk --obfuscate --split-debug-info --release --dart-define-from-file=config.prod.json --flavor production

# Generate Appbundle for production
flutter build appbundle --obfuscate --release --flavor production
```

### Run the app

```
# Run the app in development mode
flutter run --flavor development

# Run the app in production mode
flutter run --flavor production
```

### Generate Flavorizr

```
# Generate flavorizr files
flutter pub run flutter_flavorizr -p assets:download,assets:extract,android:androidManifest,android:flavorizrGradle,android:buildGradle,android:dummyAssets,android:icons,flutter:flavors,ios:podfile,ios:xcconfig,ios:buildTargets,ios:schema,ios:dummyAssets,ios:icons,ios:plist,ios:launchScreen,google:firebase,assets:clean
```

dart pub run flutter_flavorizr -p assets:download,assets:extract,android:androidManifest,android:flavorizrGradle,android:buildGradle,android:dummyAssets,android:icons,flutter:flavors,google:firebase,huawei:agconnect,ide:config

### AUTO INCERMENT

## install

    flutter pub global activate pub_version_plus

## RUN

    pubversion major => "1.1.71+1" => "2.0.0+2"
    pubversion minor => "1.1.71+1" => "2.0.0+2"
    pubversion build => "1.1.71+1" => "1.1.71+2"
    pubversion patch => "1.1.71+1" => "1.1.72+2"

## generate isar schema

    dart run build_runner build

## deploy to firebase hosting

    flutter build web --release --dart-define-from-file=config.prod.json && powershell -Command "Remove-Item -Recurse -Force build\web\assets\packages\win_ble" && firebase deploy --only hosting
    # windows
    powershell -Command "Remove-Item -Recurse -Force build\web\assets\packages\win_ble"

# atau di file pubspec.yaml (build_runner custom)

# (tidak disarankan untuk produksi, gunakan cara 1/2 di atas)

supabase db password

ydUfVGlAb8NvhyKr

yanti123@yopmail.com
kasir123

budi123@yopmail.com
kitchen123

mamang123@yopmail.com
waiter123
