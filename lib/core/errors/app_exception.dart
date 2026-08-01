sealed class AppException implements Exception {
  final String message;
  final dynamic cause;

  const AppException(this.message, [this.cause]);
  
  @override
  String toString() => '$runtimeType: $message${cause != null ? ' (Cause: $cause)' : ''}';
}

class DatabaseException extends AppException {
  const DatabaseException(super.message, [super.cause]);
}

class NetworkException extends AppException {
  const NetworkException(super.message, [super.cause]);
}

class AuthException extends AppException {
  const AuthException(super.message, [super.cause]);
}

class CryptographyException extends AppException {
  const CryptographyException(super.message, [super.cause]);
}
