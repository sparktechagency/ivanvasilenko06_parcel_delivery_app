import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:parcel_delivery_app/routes/app_routes.dart';
import 'package:parcel_delivery_app/utils/appLog/error_app_log.dart';

import 'api.dart';

class ApiPutServices {
  final api = AppApi();

  Future<dynamic> apiPutServices({
    required String url,
    dynamic body,
    int statusCode = 200,
    Map<String, dynamic>? query,
    String? token, // Add token parameter
  }) async {
    try {
      final response = await api.sendRequest.put(
        url,
        data: body,
        queryParameters: query,
        options: Options(
          headers: token != null ? {"Authorization": "Bearer $token"} : null,
        ),
      );

      if (response.statusCode == statusCode) {
        return response.data;
      } else {
        return null;
      }
    } on SocketException catch (e) {
      errorLog('api socket exception', e);
      // AppSnackBar.error("Check Your Internet Connection");
      return null;
    } on TimeoutException catch (e) {
      errorLog('api time out exception', e);
      return null;
    } on DioException catch (e) {
      if (e.response?.statusCode == 400) {
        // AppSnackBar.error("${e.response?.data["message"]}");
      } else if (e.response?.statusCode == 401) {
        Get.offAllNamed(AppRoutes.loginScreen);
      }
      errorLog('api dio exception', e);
      return null;
    } catch (e) {
      errorLog('api exception', e);
      return null;
    }
  }
}
