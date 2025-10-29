Map<String, String> headers2 = {
  'Content-Type': 'text/plain',
};

Future<Map<String, String>> tokenHeaders() async {
  // final token = await readInjectedToken(); // 위 함수 재사용
  final Map<String, String> headers = {
    'Content-Type': 'application/json; charset=utf-8',
    'Accept': 'application/json',
    // 'Authorization': 'Bearer $token'
  };
  return headers;
}
