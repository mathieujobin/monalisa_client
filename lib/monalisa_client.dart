library monalisa_client;

import 'package:flutter/services.dart' show rootBundle; // rootBundle
import 'dart:convert' show json; // utf8;
import 'package:http/http.dart' as http;
import 'dart:io' show Platform; // http client + Platform
import 'dart:async'; // Future/async/await;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class MonalisaClient {
  Map local_config;
  String user_uuid;
  String user_token;
  //final http_client = new HttpClient();
  FlutterSecureStorage _secure_storage;
  final http.BaseClient httpClient = http.Client();

  Future<String> load_json_asset(String filename) async {
    return await rootBundle.loadString('assets/$filename.json');
  }

  Future<Map> read_local_config() {
    return load_json_asset('monalisa_config').then((data) {
      local_config = json.decode(data);
      return local_config;
    });
  }

  Future two_legged_post() {

  }

  /*Future three_legged_get() {
    http_client.getUrl(Uri.parse())
        .then((HttpClientRequest request) {
      return request.close();
    }).then((HttpClientResponse response) {
    });
  }*/

  Future<bool> ensure_user_token() async {
    user_uuid = await stored_user_uuid;
    user_token = await stored_user_token;
    if (user_uuid == null || user_uuid.length != 36 || user_token == null || user_token.length != 36) {
      return token_create();
    } else {
      return token_verify();
    }
  }

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

  Future<bool> token_verify() {
    return httpClient.get(token_verify_url, headers: three_legged_auth_headers).then((res) {
      return res.statusCode == 200;
    });
  }

  String get token_create_url {
    return local_config["base_url"]+"/api/v1/token";
  }

  String get token_verify_url {
    return local_config["base_url"]+"/api/v1/token/verify";
  }

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

  Map<String, String> get three_legged_auth_headers {
    return {
      'X-SC-APP-NAME': app_name,
      'X-SC-APP-SECRET': app_secret,
      'X-SC-USER-UUID': user_uuid,
      'X-SC-USER-TOKEN': user_token
    };
  }

  String get app_name {
    return local_config["client_application_name"];
  }

  String get app_secret {
    return local_config["client_application_secret"];
  }

  Future<String> get stored_user_uuid {
    return secure_storage.read(key: 'user_uuid');
  }

  Future<String> get stored_user_token {
    return secure_storage.read(key: 'secret_token');
  }

  FlutterSecureStorage get secure_storage {
    if (_secure_storage == null)
      this._secure_storage = new FlutterSecureStorage();
    return _secure_storage;
  }

  String get client_platform {
    String os = Platform.operatingSystem;
    if (os != "ios" && os != "android") {
      throw new Exception("unsupported platform $os");
    }
    return os;
  }
}
