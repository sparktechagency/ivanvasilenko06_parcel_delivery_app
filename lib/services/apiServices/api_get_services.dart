import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:parcel_delivery_app/services/apiServices/api.dart';
import 'package:parcel_delivery_app/widgets/app_snackbar/custom_snackbar.dart';

class ApiGetServices {
  final api = AppApi();

  apiGetServices(
      String url, {
        String? token,
        int statusCode = 200,
        Map<String, dynamic>? queryParameters,
      }) async {
    try {
      final response = await api.sendRequest.get(
        url,
        queryParameters: queryParameters,
        options: Options(headers: {"Authorization": "Bearer $token"}),
      );
      if (response.statusCode == statusCode) {
        return response.data;
      } else {
        return null;
      }
    } on SocketException catch (e) {
      debugPrint(e.toString());
      AppSnackBar.error("Check Your Internet Connection");
      return null;
    } on TimeoutException catch (e) {
      // AppSnackBar.error("Something Went Wrong");
      debugPrint(e.toString());
      return null;
    } on DioException catch (e) {
      // AppSnackBar.error("Something Went Wrong");
      debugPrint(e.toString());
      return null;
    } catch (e) {
      // AppSnackBar.error("Something Went Wrong");
      return null;
    }
  }
}
