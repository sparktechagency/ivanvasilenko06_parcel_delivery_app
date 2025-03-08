import 'dart:async';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:get/get.dart';

import '../../routes/app_routes.dart';
import '../../utils/appLog/error_app_log.dart';
import '../../widgets/app_snackbar/custom_snackbar.dart';
import '../appStroage/app_auth_storage.dart';
import 'api.dart';
import 'non_auth_api.dart';

class ApiPostServices {
  apiPostServices({
    required String url,
    dynamic body,
    int statusCode = 200,
    Map<String, dynamic>? query,
    String? token,
  }) async {
    final dynamic response;
    try {
      if (token != null) {
        response = await NonAuthApi().sendRequest.post(url, data: body, options: Options(headers: {"Authorization": token}));
      } else {
        response = await AppApi().sendRequest.post(url, data: body);
      }

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
