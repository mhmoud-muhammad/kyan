
// API Constants'
class KyanException implements Exception {
  final String message;
  final int? code;
  
  KyanException(this.message, {this.code});
  
  @override
  String toString() => 'KyanException: $message (Code: $code)';
}

class ServerException extends KyanException {
  ServerException(super.message, {super.code});
}

class NetworkException extends KyanException {
  NetworkException([super.message = 'No internet connection']);
}

class UnauthorizedException extends KyanException {
  UnauthorizedException([super.message = 'Session expired']);
}

class CacheException extends KyanException {
  CacheException([super.message = 'Cache error occurred']);
}

class ValidationException extends KyanException {
  final Map<String, String> errors;
  
  ValidationException(this.errors) : super('Validation failed');
}