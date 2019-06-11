# monalisa_client

Small library to authenticate your Flutter up with Monalisa API/SSO

## Add to your project

in your pubspec.yaml file
```yaml
dependencies:
  flutter:
    sdk: flutter
  monalisa_client:
    git:
      url: https://github.com/mathieujobin/monalisa_client.git

assets:
  - assets/monalisa_config.json
```

## Create and save your app token

Visit https://monalisa.solidcode.bz/app

## Create Config file

```json
{
  "base_url": "https://monalisa.solidcode.bz",
  "environment": "production",
  "client_application_name": "rockpaperscissors",
  "client_application_secret": "1234"
}
```

## Basic usage

```dart
import 'package:monalisa_client/monalisa_client.dart';
final MonalisaClient monalisa_client = MonalisaClient();

  @override
  void initState() {
    super.initState();

    monalisa_client.read_local_config().then((data) {
      return monalisa_client.ensure_user_token();
    }).then((data) {
      setState(() {
        // this is only to debug execution order,
        // setState should not be called before ensure_user_token is completed.
        // also to show how to access user_uuid
        if (monalisa_client.user_uuid == null) {
          throw Exception("user_uuid is missing");
        }
        _user_logged_in = true;
      });
    });
  }
```

## Dart/Flutter package resources

This project is a starting point for a Dart
[package](https://flutter.dev/developing-packages/),
a library module containing code that can be shared easily across
multiple Flutter or Dart projects.

For help getting started with Flutter, view our 
[online documentation](https://flutter.dev/docs), which offers tutorials, 
samples, guidance on mobile development, and a full API reference.
