import 'failure.dart';

class ExceptionHandler {
  static Failure handle(dynamic error) {
    if (error.toString().contains('Database')) {
      return DatabaseFailure('Database error occurred.');
    } else if (error.toString().contains('Format')) {
      return ValidationFailure('Invalid data format.');
    } else {
      return Failure('Unexpected error: $error');
    }
  }
}
