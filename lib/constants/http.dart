import 'package:injicare_event/main.dart';

Map<String, String> headers2 = {
  'Content-Type': 'text/plain',
};

Future<Map<String, String>> tokenHeaders() async {
  final token = await readInjectedToken(); // 위 함수 재사용
  return {
    'Content-Type': 'text/plain',
    if (token != null) 'Authorization': 'Bearer $token', // ★
  };
}
