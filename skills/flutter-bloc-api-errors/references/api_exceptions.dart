// Typed API exceptions for apps that don't have their own.
// Copy into the data layer (e.g. lib/data/api/api_exceptions.dart).
// Repositories rethrow these; BLoCs turn them into localized messages.

import 'dart:async';
import 'dart:convert';
import 'dart:io';

/// Base type: the request reached the server and it answered with an error.
class ApiException implements Exception {
  const ApiException(this.statusCode, [this.message]);

  final int statusCode;

  /// The server's explanation, when its error body has one.
  final String? message;

  @override
  String toString() => 'ApiException($statusCode, $message)';
}

/// 401: not signed in, or the session expired.
class UnauthorizedException extends ApiException {
  const UnauthorizedException([String? message]) : super(401, message);
}

/// No connection, a timeout, or a server failure (5xx): retrying may help.
class NetworkException implements Exception {
  const NetworkException([this.cause]);

  final Object? cause;

  @override
  String toString() => 'NetworkException($cause)';
}

/// The response arrived but couldn't be read (bad JSON, missing fields).
class BadResponseException implements Exception {
  const BadResponseException([this.cause]);

  final Object? cause;

  @override
  String toString() => 'BadResponseException($cause)';
}

/// For `package:http`: throws the matching exception unless [statusCode] is 2xx.
void throwIfError(int statusCode, String body) {
  if (statusCode >= 200 && statusCode < 300) return;
  final message = _messageFrom(body);
  if (statusCode == 401) throw UnauthorizedException(message);
  if (statusCode >= 500) throw NetworkException('HTTP $statusCode');
  throw ApiException(statusCode, message);
}

/// Wraps a `package:http` request: transport failures become [NetworkException].
Future<T> guardRequest<T>(
  Future<T> Function() request, {
  Duration timeout = const Duration(seconds: 15),
}) async {
  try {
    return await request().timeout(timeout);
  } on TimeoutException catch (e) {
    throw NetworkException(e);
  } on SocketException catch (e) {
    throw NetworkException(e);
  }
}

// For Dio, convert in one interceptor or helper instead:
//   on DioException catch (e) {
//     final code = e.response?.statusCode;
//     if (code == null) throw NetworkException(e);   // connection, timeout
//     throwIfError(code, jsonEncode(e.response?.data));
//     rethrow;
//   }
// (SocketException comes from dart:io; on the web, catch http.ClientException.)

String? _messageFrom(String body) {
  try {
    final json = jsonDecode(body);
    if (json is Map<String, dynamic>) {
      final value = json['message'] ?? json['error'] ?? json['detail'];
      return value?.toString();
    }
  } on FormatException {
    // Not JSON: no server message.
  }
  return null;
}
