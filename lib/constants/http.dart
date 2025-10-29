import 'package:injicare_event_security/main.dart';

Map<String, String> headers2 = {
  'Content-Type': 'text/plain',
};

Future<Map<String, String>> tokenHeaders() async {
  final token = await readInjectedToken(); // 위 함수 재사용
  final Map<String, String> headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'Authorization': 'Bearer $token'
  };
  return headers;
}
