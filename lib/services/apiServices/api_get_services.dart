import 'dart:async';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:parcel_delivery_app/routes/app_routes.dart';
import 'package:parcel_delivery_app/services/apiServices/api.dart';
import 'package:parcel_delivery_app/services/appStroage/app_auth_storage.dart';
import 'package:parcel_delivery_app/utils/appLog/error_app_log.dart';
import 'package:parcel_delivery_app/widgets/app_snackbar/custom_snackbar.dart';

class ApiGetServices {
  final api = AppApi();

  apiGetServices(
      String url, {
        int statusCode = 200,
        Map<String, dynamic>? queryParameters,
        dynamic body,
        String? token,
      }) async {
    try {
      final response = await api.sendRequest.get(
        url,
        queryParameters: queryParameters,
        data: body,options:Options(headers: {"Authorization": "Bearer $token}"}),
      );
      if (response.statusCode == statusCode) {
        return response.data;
      } else {
        return null;
      }
    } on SocketException catch (e) {
      errorLog('api socket exception', e);
      AppSnackBar.error("Check Your Internet Connection");
      return null;
    } on TimeoutException catch (e) {
      // AppSnackBar.error("Something Went Wrong");

      errorLog('api time out exception', e);
      return null;
    } on DioException catch (e) {
      if (e.response.runtimeType != Null) {
        if (e.response?.statusCode == 400) {
          if (e.response?.data["message"].runtimeType != Null) {
            AppSnackBar.error("${e.response?.data["message"]}");
          }
          return null;
        } else if (e.response?.statusCode == 401) {
          // AppSnackBar.error("Your login section has time out ");
          await AppAuthStorage().storageClear();
          Get.offAllNamed(AppRoutes.loginScreen);
          // AppSnackBar.message("Sign-in again with your credential");
        }
      } else {
        // AppSnackBar.error("Something Went Wrong");
      }
      errorLog('api dio exception', e);
      return null;
    } catch (e) {
      // AppSnackBar.error("Something Went Wrong");
      errorLog('api exception', e);
      return null;
    }
  }
}
