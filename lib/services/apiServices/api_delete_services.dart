import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:parcel_delivery_app/routes/app_routes.dart';
import 'package:parcel_delivery_app/utils/appLog/error_app_log.dart';
import 'package:parcel_delivery_app/widgets/app_snackbar/custom_snackbar.dart';

import 'api.dart';

class ApiDeleteServices {
  final api = AppApi();

   Future<dynamic> apiDeleteServices({
    required String url,
    Map<String, dynamic>? query,
    String? token,
  }) async {
    try {
      final response = await api.sendRequest.delete(
        url,
        queryParameters: query,
        options: Options(
          headers: token != null ? {"Authorization": "Bearer $token"} : null,
        ),
      );

      if (response.statusCode == 200) {
        return response.data;
      } else {
        return null;
      }
    } on SocketException catch (e) {
      errorLog('api socket exception', e);
      return null;
    } on TimeoutException catch (e) {
      errorLog('api time out exception', e);
      return null;
    } on DioException catch (e) {
      if (e.response?.statusCode == 400) {
        // Handle bad request
      } else if (e.response?.statusCode == 401) {
        // Log the detailed error before redirecting
        errorLog('401 Unauthorized Error', 'Token: $token, Response: ${e.response?.data}');
        Get.offAllNamed(AppRoutes.loginScreen);
      }
      errorLog('api dio exception', e);
      // Re-throw the exception to let the caller handle it
      rethrow;
    } catch (e) {
      errorLog('api exception', e);
      rethrow;
    }
  }
}
