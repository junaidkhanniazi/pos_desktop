class Failure {
  final String message;
  const Failure(this.message);

  @override
  String toString() => message;
}

// ---- Common Failure Types ----
class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'Network connection failed']);
}

class DatabaseFailure extends Failure {
  const DatabaseFailure([super.message = 'Database operation failed']);
}

class ValidationFailure extends Failure {
  const ValidationFailure([super.message = 'Validation failed']);
}

class CacheFailure extends Failure {
  const CacheFailure([super.message = 'Cache operation failed']);
}

class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure([super.message = 'Unauthorized access']);
}

class NotFoundFailure extends Failure {
  const NotFoundFailure([super.message = 'Resource not found']);
}
