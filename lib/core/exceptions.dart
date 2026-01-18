class ViseronException implements Exception {
  final String message;
  final int? statusCode;

  ViseronException(this.message, [this.statusCode]);

  @override
  String toString() => 'ViseronException: $message ${statusCode != null ? "($statusCode)" : ""}';
}

class NetworkException extends ViseronException {
  NetworkException(String message) : super(message);
}

class AuthException extends ViseronException {
  AuthException(String message, [int? statusCode]) : super(message, statusCode);
}

class ServerException extends ViseronException {
  ServerException(String message, [int? statusCode]) : super(message, statusCode);
}
