class AppException implements Exception {
  final String message;

  const AppException(this.message);

  @override
  String toString() => message;
}

class ServerException extends AppException {
  const ServerException([super.message = 'Server error occurred']);
}

class CacheException extends AppException {
  const CacheException([super.message = 'Cache error occurred']);
}

class NetworkException extends AppException {
  const NetworkException([super.message = 'No internet connection']);
}

class AuthException extends AppException {
  const AuthException([super.message = 'Authentication failed']);
}
