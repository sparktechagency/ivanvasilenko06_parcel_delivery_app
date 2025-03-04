import 'package:dio/dio.dart';
import 'package:parcel_delivery_app/constants/api_url.dart';

class NonAuthApi {
  final Dio _dio = Dio();
  NonAuthApi() {
    _dio.options.baseUrl = AppApiUrl.baseUrl;
    _dio.options.sendTimeout = const Duration(seconds: 60);
    _dio.options.connectTimeout = const Duration(seconds: 60);
    _dio.options.receiveTimeout = const Duration(seconds: 60);
    _dio.options.followRedirects = false;
  }
  Dio get sendRequest => _dio;
}
