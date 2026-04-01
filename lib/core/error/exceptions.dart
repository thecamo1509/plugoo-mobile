/// Infrastructure-layer exceptions — only used in data sources.
/// Never let these bubble up to domain or presentation; always catch and map to [Failure].

class ServerException implements Exception {
  final String message;
  final int statusCode;

  const ServerException({required this.message, required this.statusCode});
}

class NetworkException implements Exception {
  const NetworkException();
}

class UnauthorizedException implements Exception {
  const UnauthorizedException();
}

class CacheException implements Exception {
  final String message;

  const CacheException({required this.message});
}
