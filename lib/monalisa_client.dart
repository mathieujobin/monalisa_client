library monalisa_client;

import 'package:flutter/services.dart' show rootBundle; // rootBundle
import 'dart:convert' show json; // utf8;
import 'package:http/http.dart' as http;
import 'dart:io' show Platform; // http client + Platform
import 'dart:async'; // Future/async/await;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Client class that manage authentication and speaking with monalisa service.
class MonalisaClient {
  Map local_config;
  String user_uuid;
  String user_token;
  FlutterSecureStorage _secure_storage;
  final http.BaseClient httpClient = http.Client();
  final String environment;

  MonalisaClient({this.environment = null});

  /// Utility function, loads a json file in the assets subfolder
  Future<String> load_json_asset() async {
    return await rootBundle.loadString('assets/$filename.json');
  }

  String get filename {
    if (environment == null) {
      return 'monalisa_config';
    } else {
      return 'monalisa_config_$environment';
    }
  }

  /// Read and return the content of your monalisa_client config file
  Future<Map> read_local_config() {
    return load_json_asset().then((data) {
      local_config = json.decode(data);
      return local_config;
    });
  }

  /*
  /// NotImplemented, will allow two legged post request to monalisa and other services
  Future two_legged_post() {

  }

  /// NotImplemented, will allow three legged get request to monalisa and other services
  Future three_legged_get() {
    http_client.getUrl(Uri.parse())
        .then((HttpClientRequest request) {
      return request.close();
    }).then((HttpClientResponse response) {
    });
  }*/

  /// Very important method, will initiate a first token creation or verify existing token.
  Future<bool> ensure_user_token() async {
    user_uuid = await stored_user_uuid;
    user_token = await stored_user_token;
    if (user_uuid == null || user_uuid.length != 36 || user_token == null || user_token.length != 36) {
      return token_create();
    } else {
      return token_verify();
    }
  }

  /// Used internally by ensure_user_token, you probably don't need to call this yourself.
  Future<bool> token_create() {
    try {
      return httpClient.post(token_create_url, headers: two_legged_auth_headers).then((res) {
        if (res.statusCode == 201) {
          Map response_map = json.decode(res.body);
          user_uuid = response_map['user_uuid'];
          user_token = response_map['secret_token'];
          secure_storage.write(key: 'user_uuid', value: response_map['user_uuid']);
          secure_storage.write(key: 'secret_token', value: response_map['secret_token']);
          return true;
        } else {
          return false;
        }
      });
    } catch(e, _) {
      var completer = new Completer();
      completer.complete(false);
      return completer.future;
    }
  }

  /// Used internally by ensure_user_token, you probably don't need to call this yourself.
  Future<bool> token_verify() {
    return httpClient.get(token_verify_url, headers: three_legged_auth_headers).then((res) {
      return res.statusCode == 200;
    });
  }

  /// URL to token create endpoint
  String get token_create_url {
    return local_config["base_url"]+"/api/v1/token";
  }

  /// URL to token verify endpoint
  String get token_verify_url {
    return local_config["base_url"]+"/api/v1/token/verify";
  }

  /// Returns auth headers required to do a two legged request to monalisa
  Map<String, String> get two_legged_auth_headers {
    return {
      'X-SC-CLIENT-PLATFORM': client_platform,
      'X-SC-CLIENT-LOCALE': Platform.localeName,
      'X-SC-CLIENT-VERSION': Platform.version,
      'X-SC-CLIENT-OS-VERSION': Platform.operatingSystemVersion,
      'X-SC-APP-NAME': app_name,
      'X-SC-APP-SECRET': app_secret
    };
  }

  /// Returns auth headers required to do a three legged request to monalisa or other services
  Map<String, String> get three_legged_auth_headers {
    return {
      'X-SC-APP-NAME': app_name,
      'X-SC-APP-SECRET': app_secret,
      'X-SC-USER-UUID': user_uuid,
      'X-SC-USER-TOKEN': user_token
    };
  }

  /// Return your app name
  String get app_name {
    return local_config["client_application_name"];
  }

  /// Return your app secret
  String get app_secret {
    return local_config["client_application_secret"];
  }

  /// Return your stored user uuid
  Future<String> get stored_user_uuid {
    return secure_storage.read(key: 'user_uuid');
  }

  /// Return your stored user token
  Future<String> get stored_user_token {
    return secure_storage.read(key: 'secret_token');
  }

  /// Return a common flutter secure storage instance object
  FlutterSecureStorage get secure_storage {
    if (_secure_storage == null)
      this._secure_storage = new FlutterSecureStorage();
    return _secure_storage;
  }

  /// Return your client platform only if it is iOS or Android
  ///
  /// Throw an Exception otherwise
  String get client_platform {
    String os = Platform.operatingSystem;
    if (os != "ios" && os != "android") {
      throw new Exception("unsupported platform $os");
    }
    return os;
  }
}
