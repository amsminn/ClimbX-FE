/// HTTP 메서드 열거형
enum HttpMethod {
  get('GET'),
  post('POST'),
  put('PUT'),
  patch('PATCH'),
  delete('DELETE'),
  head('HEAD'),
  options('OPTIONS');

  const HttpMethod(this.value);
  
  final String value;

  @override
  String toString() => value;
} 