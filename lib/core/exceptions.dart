class ViseronException implements Exception {
  final String message;
  final int? statusCode;

  ViseronException(this.message, [this.statusCode]);

  @override
  String toString() => 'ViseronException: $message ${statusCode != null ? "($statusCode)" : ""}';
}

class NetworkException extends ViseronException {
  NetworkException(super.message);
}

class AuthException extends ViseronException {
  AuthException(super.message, [super.statusCode]);
}

class ServerException extends ViseronException {
  ServerException(super.message, [super.statusCode]);
}
