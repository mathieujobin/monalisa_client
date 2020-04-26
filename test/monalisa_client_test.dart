import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart';
import 'package:http/testing.dart';
import 'dart:convert';

import 'package:monalisa_client/monalisa_client.dart';

void main() {
  test('monalisa reads his local config of a json file', () {
    TestWidgetsFlutterBinding.ensureInitialized();
    MonalisaClient monalisa_client = MonalisaClient();
    /* How to I access my json assets in test ?!?
    monalisa_client.read_local_config()
      .then((data) { expect(data, null); });
    */
  });
  test('monalisa creates a token and return a uuid', () {
    TestWidgetsFlutterBinding.ensureInitialized();
    MonalisaClient monalisa_client = MonalisaClient();
    monalisa_client.httpClient = MockClient((request) async {
      final mapJson = {'id':123};
      return Response(json.encode(mapJson),200);
    });
    /* How to I access my json assets in test ?!?
    monalisa_client.read_local_config().then((data) {
      return monalisa_client.ensure_user_token();
    }).then((data) { expect(data, null); });
    */
  });
}
