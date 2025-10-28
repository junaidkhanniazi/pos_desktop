class Failure {
  final String message;
  Failure(this.message);
}

class DatabaseFailure extends Failure {
  DatabaseFailure(String message) : super(message);
}

class ValidationFailure extends Failure {
  ValidationFailure(String message) : super(message);
}
