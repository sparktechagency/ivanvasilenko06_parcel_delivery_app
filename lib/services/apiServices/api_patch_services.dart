import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:parcel_delivery_app/services/apiServices/api.dart';
import 'package:parcel_delivery_app/widgets/app_snackbar/custom_snackbar.dart';

class ApiPatchServices {
  final api = AppApi();

  apiPatchServices({
    required String url,
    Object? body,
    int statusCode = 200,
    Map<String, dynamic>? query,
    Options? options,
    String? token,
  }) async {
    try {
      final response = await api.sendRequest.patch(
        url,
        data: body,
        queryParameters: query,
        options: Options(headers: {"Authorization": token}),
      );
      if (response.statusCode == statusCode || token != null) {
        return response.data;
      } else {
        // Handle cases where status code is different
        AppSnackBar.error(
            "Unexpected response: ${response.statusCode} ${response.statusMessage}");
        return null;
      }
    } on SocketException catch (e) {
      log("SocketException: $e");
      AppSnackBar.error("Check Your Internet Connection");
      return null;
    } on TimeoutException catch (e) {
      log("TimeoutException: $e");
      // AppSnackBar.error("Request Timed Out");
      return null;
    } on DioException catch (e) {
      // Log detailed Dio error information
      log("DioException: ${e.message}");
      log("DioError: ${e.response?.data}");
      log("Request Data: ${e.requestOptions.data}");
      log("Status Code: ${e.response?.statusCode}");

      // if (e.response != null) {
      //   AppSnackBar.error("Error: ${e.response?.data['message'] ?? 'Something went wrong'}");
      // } else {
      //   AppSnackBar.error("Request failed with Dio error");
      // }

      return null;
    } catch (e) {
      log("Exception: $e");
      // AppSnackBar.error("Something Went Wrong");
      return null;
    }
  }
}
