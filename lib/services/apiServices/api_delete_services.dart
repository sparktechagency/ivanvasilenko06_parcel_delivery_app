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
    String? token, // Optional token parameter
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
        return response.data; // Return response data if status code is 200
      } else {
        return null; // Return null for any other status code
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
