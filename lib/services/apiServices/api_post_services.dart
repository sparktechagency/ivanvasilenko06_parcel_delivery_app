import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:parcel_delivery_app/services/apiServices/api.dart';
import 'package:parcel_delivery_app/services/apiServices/non_auth_api.dart';
import 'package:parcel_delivery_app/widgets/app_snackbar/custom_snackbar.dart';

class ApiPostServices {
  apiPostServices({
    required String url,
    dynamic body,
    int statusCode = 200,
    Map<String, dynamic>? query,
    String? token,
  }) async {
    final Response response;
    try {
      if (token != null) {
        response = await NonAuthApi().sendRequest.post(
          url,
          data: body,
          options: Options(headers: {"Authorization": "Bearer $token"}),
        );
      } else {
        response = await AppApi().sendRequest.post(url, data: body);
      }

      if (response.statusCode == statusCode) {
        return response.data;
      } else {
        return null;
      }
    } on SocketException catch (e) {
      log(e.toString());
      AppSnackBar.error("Check Your Internet Connection");
      return null;
    } on TimeoutException catch (e) {
      // AppSnackBar.error("Something Went Wrong");
      log(e.toString());
      return null;
    } on DioException catch (e) {
      if (e.response.runtimeType != Null) {
        if (e.response?.statusCode == 400) {
          if (e.response?.data["message"].runtimeType != Null) {
            AppSnackBar.error("${e.response?.data["message"]}");
          }
          return null;
        }
      } else {
        // AppSnackBar.error("Something Went Wrong");
      }
      log(e.toString());
      return null;
    } catch (e) {
      // AppSnackBar.error("Something Went Wrong");
      log(e.toString());
      return null;
    }
  }
}
