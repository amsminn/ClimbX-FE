class AuthCancelledException implements Exception {
  final String message;

  const AuthCancelledException([this.message = '사용자가 로그인을 취소했습니다.']);

  @override
  String toString() => message;
}

