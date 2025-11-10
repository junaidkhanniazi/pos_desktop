import 'dart:io';
import 'package:sqflite/sqflite.dart';
import 'failure.dart';

class ExceptionHandler {
  static Failure handle(dynamic error) {
    if (error is SocketException) {
      return const NetworkFailure('No Internet connection.');
    } else if (error is DatabaseException) {
      return const DatabaseFailure('Database operation failed.');
    } else if (error is FormatException) {
      return const ValidationFailure('Invalid data format.');
    } else if (error.toString().contains('401')) {
      return const UnauthorizedFailure('Unauthorized request.');
    } else if (error.toString().contains('404')) {
      return const NotFoundFailure('Requested resource not found.');
    } else {
      return Failure('Unexpected error: $error');
    }
  }
}
