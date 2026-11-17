
import 'text_utils/app_strings.dart';

class AppException implements Exception {
  final String message;
  final String prefix;
  final String url;

  AppException(this.message, this.prefix, this.url);
}

class BadRequestException extends AppException {
  BadRequestException(String message, String url)
      : super(message, '${AppStrings.BadRequestException}', url);
}

class FetchDataException extends AppException {
  FetchDataException(String message, String url)
      : super(message, '${AppStrings.FetchDataException}', url);
}

class ApiNotResponding extends AppException {
  ApiNotResponding(String message, String url)
      : super(message, '${AppStrings.ApiNotResponding}', url);
}

class UnAuthorizedException extends AppException {
  UnAuthorizedException(String message, String url)
      : super(message, '${AppStrings.UnAuthorizedException}', url);
}

/// Thrown by BaseClient after it has already ended the login session (forced
/// logout + Login route + toast). Subclass of [UnAuthorizedException] so
/// existing catches keep working; catch it first to avoid a second snackbar.
class SessionEndedException extends UnAuthorizedException {
  SessionEndedException(super.message, super.url);
}
