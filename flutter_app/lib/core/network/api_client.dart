import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../config/env_config.dart';
import '../errors/failures.dart';

class ApiClient {
  late final Dio dio;

  ApiClient({String? baseUrl, String? authToken}) {
    String defaultUrl;
    if (kIsWeb) {
      defaultUrl = EnvConfig.apiBaseUrlWeb;
    } else if (Platform.isAndroid) {
      defaultUrl = EnvConfig.apiBaseUrl; // 10.0.2.2 for Android emulator
    } else {
      defaultUrl = EnvConfig.apiBaseUrlWeb; // 127.0.0.1 for Windows desktop / macOS / Linux / iOS Simulator
    }

    dio = Dio(
      BaseOptions(
        baseUrl: baseUrl ?? defaultUrl,
        connectTimeout: const Duration(milliseconds: EnvConfig.connectTimeoutMs),
        receiveTimeout: const Duration(milliseconds: EnvConfig.receiveTimeoutMs),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          if (authToken != null) 'Authorization': 'Bearer $authToken',
        },
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          if (kDebugMode) {
            debugPrint('[API REQ] ${options.method} -> ${options.uri}');
          }
          return handler.next(options);
        },
        onResponse: (response, handler) {
          if (kDebugMode) {
            debugPrint('[API RES] ${response.statusCode} <- ${response.requestOptions.uri}');
          }
          return handler.next(response);
        },
        onError: (DioException e, handler) {
          if (kDebugMode) {
            debugPrint('[API ERR] ${e.response?.statusCode} !! ${e.message}');
          }
          return handler.next(e);
        },
      ),
    );
  }

  Failure handleError(dynamic error) {
    if (error is DioException) {
      if (error.error is SocketException ||
          error.type == DioExceptionType.connectionError ||
          error.type == DioExceptionType.connectionTimeout) {
        return const NetworkFailure();
      }
      final statusCode = error.response?.statusCode;
      final data = error.response?.data;
      String message = 'An unexpected server error occurred.';
      if (data is Map<String, dynamic> && data.containsKey('detail')) {
        message = data['detail'].toString();
      } else if (error.message != null) {
        message = error.message!;
      }
      return ServerFailure(message, statusCode: statusCode);
    }
    return ServerFailure(error.toString());
  }
}
