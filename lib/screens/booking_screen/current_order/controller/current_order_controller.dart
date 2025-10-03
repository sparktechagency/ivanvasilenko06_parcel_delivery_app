import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:parcel_delivery_app/constants/api_url.dart';
import 'package:parcel_delivery_app/constants/app_colors.dart';
import 'package:parcel_delivery_app/screens/booking_screen/current_order/model/current_order_model.dart';
import 'package:parcel_delivery_app/services/apiServices/api_get_services.dart';
import 'package:parcel_delivery_app/services/apiServices/api_post_services.dart';
import 'package:parcel_delivery_app/services/appStroage/share_helper.dart';
import 'package:parcel_delivery_app/widgets/app_snackbar/custom_snackbar.dart';

class CurrentOrderController extends GetxController {
  RxBool isLoading = false.obs;
  Rx<CurrentOrderModel> currentOrdersModel = CurrentOrderModel().obs;
  var rating = 1.0.obs;
  var parcelID = "".obs;
  var userID = "".obs;

  var finishedParcelId = "".obs;
  var parcelStatus = "".obs;

  // Add caching variables
  RxBool hasDataCached = false.obs;
  DateTime? lastFetchTime;
  static const Duration cacheValidDuration = Duration(minutes: 15); // Cache valid for 15 minutes

  @override
  void onInit() {
    super.onInit();
    // Only load data if not cached or cache is expired
    if (!hasDataCached.value || _isCacheExpired()) {
      getCurrentOrder();
    }
  }

  // Check if cache is expired
  bool _isCacheExpired() {
    if (lastFetchTime == null) return true;
    return DateTime.now().difference(lastFetchTime!) > cacheValidDuration;
  }

  // Method to get cached data or fetch fresh data
  Future<void> getCurrentOrderWithCache({bool forceRefresh = false}) async {
    // If we have cached data and it's not expired, and not forcing refresh, return cached data
    if (hasDataCached.value && !_isCacheExpired() && !forceRefresh) {
      log('📦 Using cached current order data');
      return;
    }
    
    // Otherwise, fetch fresh data
    await getCurrentOrder();
  }

  Future<CurrentOrderModel?> getCurrentOrder() async {
    if (isLoading.value) return null; // Prevent multiple simultaneous calls

    isLoading(true);
    try {
      final response = await ApiGetServices()
          .apiGetServices(AppApiUrl.getCurrentOrders, statusCode: 200);

      log("API response received: ${response.runtimeType}");

      try {
        if (response is Map<String, dynamic>) {
          if (response.containsKey("body")) {
            var body = response["body"];
            if (body is Map<String, dynamic>) {
              currentOrdersModel.value = CurrentOrderModel.fromJson(body);
            } else if (body is String) {
              currentOrdersModel.value =
                  CurrentOrderModel.fromJson(json.decode(body));
            }
          } else {
            currentOrdersModel.value = CurrentOrderModel.fromJson(response);
          }

          log("Current orders model updated: ${currentOrdersModel.value.data?.length ?? 0} orders found");
          
          // Mark data as cached and update fetch time
          hasDataCached.value = true;
          lastFetchTime = DateTime.now();
          log('📦 Current order data cached successfully');
          
          return currentOrdersModel.value;
        } else {
          log("Unexpected response type: ${response.runtimeType}");
          // Initialize with empty data to prevent null checks
          currentOrdersModel.value = CurrentOrderModel(data: []);
          return null;
        }
      } catch (parseError) {
        log("Error parsing response data: ${parseError.toString()}");
        // Initialize with empty data to prevent null checks
        currentOrdersModel.value = CurrentOrderModel(data: []);
        return null;
      }
    } catch (ex) {
      log("Error in getCurrentOrder: ${ex.toString()}");
      // Initialize with empty data to prevent null checks
      currentOrdersModel.value = CurrentOrderModel(data: []);
      return null;
    } finally {
      isLoading(false);
    }
  }

Future<void> givingReview() async {
  try {
    // Validate required fields
    if (parcelID.value.isEmpty) {
      AppSnackBar.error("Parcel information is missing");
      return;
    }

    if (userID.value.isEmpty) {
      AppSnackBar.error("Delivery person information is missing");
      return;
    }

    isLoading(true);

    final Map<String, dynamic> body = {
      "parcelId": parcelID.value,
      "rating": rating.value,
      "targetUserId": userID.value,
    };

    log("Submitting review: $body");

    final response = await ApiPostServices().apiPostServices(
      url: AppApiUrl.givingReview, 
      body: body, 
      statusCode: 200
    );

    if (response != null) {
      log("Successfully given review");
      AppSnackBar.success("Successfully given review");

      // Clear the values after successful submission
      parcelID.value = "";
      userID.value = "";
      rating.value = 1.0;

      // Refresh orders to show updated status
      await getCurrentOrderWithCache(forceRefresh: true);
    } else {
      log("Failed to give review");
      AppSnackBar.error("Failed to submit your review. Please try again.");
    }
  } catch (ex) {
    log("Error in givingReview: ${ex.toString()}");
    AppSnackBar.error("Something went wrong: ${ex.toString()}");
  } finally {
    isLoading(false);
  }
}

  Future<void> finishedDelivery() async {
    isLoading(true);
    try {
      final Map<String, dynamic> body = {
        "parcelId": finishedParcelId.value,
        "status": parcelStatus.value,
      };
      final response = await ApiPostServices().apiPostServices(
          url: AppApiUrl.finishedDelivery, body: body, statusCode: 200);
      if (response != null) {
        log("Successfully finished delivery");
        AppSnackBar.success("Successfully finished delivery");
        await refreshCurrentOrder();
      } else {
        log("Failed to finish delivery");
        // AppSnackBar.error("Failed to finish delivery. Please try again.");
      }
    } catch (ex) {
      log("Error in finishedDelivery: ${ex.toString()}");
    }
  }

  Future<void> refreshCurrentOrder() async {
    isLoading(true);
    await getCurrentOrder();
  }

  // Method to clear cache and force refresh
  Future<void> clearCacheAndRefresh() async {
    hasDataCached.value = false;
    lastFetchTime = null;
    getCurrentOrder();
  }
}