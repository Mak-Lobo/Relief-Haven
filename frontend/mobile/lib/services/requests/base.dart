import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../auth/session_storage.dart';

final _logger = Logger();
final _sessionStorage = SessionStorage();

class RequestException implements Exception {
  const RequestException(this.message, {this.statusCode, this.uri});

  final String message;
  final int? statusCode;
  final Uri? uri;

  @override
  String toString() => message;
}

class Base {
  String get baseURL {
    final configuredUrl = dotenv.env['BACKEND_URL'] ?? '';
    return _normalizeBaseUrl(configuredUrl);
  }

  Base() {
    _dio = Dio(
      BaseOptions(
        baseUrl: baseURL,
        connectTimeout: const Duration(milliseconds: 8000),
        receiveTimeout: const Duration(milliseconds: 8000),
        headers: {
          'Content-Type': 'application/json',
          'ngrok-skip-browser-warning': 'true',
        },
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          if (options.baseUrl.isEmpty) {
            handler.reject(
              DioException(
                requestOptions: options,
                error: const RequestException(
                  'Backend URL is not configured. Set API_BASE_URL or BACKEND_URL in .env.',
                ),
                type: DioExceptionType.badResponse,
              ),
            );
            return;
          }

          final session = Supabase.instance.client.auth.currentSession;
          if (session != null) {
            options.headers['Authorization'] = 'Bearer ${session.accessToken}';
          } else {
            final cachedToken = await _sessionStorage.readAccessToken();
            if (cachedToken != null && cachedToken.isNotEmpty) {
              options.headers['Authorization'] = 'Bearer $cachedToken';
            }
          }
          options.headers.putIfAbsent('Accept', () => 'application/json');
          handler.next(options);
        },
        onError: (error, handler) {
          _logger.w(
            'HTTP ${error.requestOptions.method} ${error.requestOptions.uri} failed',
            error: error,
          );
          handler.next(error);
        },
      ),
    );
  }

  late final Dio _dio;

  Dio get dio => _dio;

  RequestException mapDioException(
    DioException error, {
    String? fallbackMessage,
  }) {
    final responseData = error.response?.data;
    final serverMessage = _extractServerMessage(responseData);

    if (serverMessage != null && serverMessage.isNotEmpty) {
      return RequestException(
        serverMessage,
        statusCode: error.response?.statusCode,
        uri: error.requestOptions.uri,
      );
    }

    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return RequestException(
          fallbackMessage ?? 'The request timed out. Please try again.',
          statusCode: error.response?.statusCode,
          uri: error.requestOptions.uri,
        );
      case DioExceptionType.connectionError:
        return RequestException(
          fallbackMessage ??
              'Unable to reach the server. Check your connection and try again.',
          statusCode: error.response?.statusCode,
          uri: error.requestOptions.uri,
        );
      case DioExceptionType.cancel:
        return RequestException(
          fallbackMessage ?? 'The request was cancelled.',
          statusCode: error.response?.statusCode,
          uri: error.requestOptions.uri,
        );
      case DioExceptionType.badCertificate:
      case DioExceptionType.badResponse:
      case DioExceptionType.unknown:
        return RequestException(
          fallbackMessage ??
              'Something went wrong while talking to the server.',
          statusCode: error.response?.statusCode,
          uri: error.requestOptions.uri,
        );
    }
  }

  String _normalizeBaseUrl(String value) {
    final trimmed = value.trim();
    if (trimmed.endsWith('/')) {
      return trimmed.substring(0, trimmed.length - 1);
    }
    return trimmed;
  }

  String? _extractServerMessage(dynamic data) {
    if (data is Map<String, dynamic>) {
      final detail = data['detail'];
      if (detail is String && detail.trim().isNotEmpty) {
        return detail.trim();
      }

      final message = data['message'];
      if (message is String && message.trim().isNotEmpty) {
        return message.trim();
      }
    }

    if (data is String && data.trim().isNotEmpty) {
      return data.trim();
    }

    return null;
  }
}
