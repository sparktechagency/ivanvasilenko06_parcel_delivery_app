import 'dart:convert';
import 'dart:developer';

import 'package:get/get.dart';
import 'package:parcel_delivery_app/constants/api_url.dart';
import 'package:parcel_delivery_app/screens/booking_screen/current_order/model/current_order_model.dart';
import 'package:parcel_delivery_app/services/apiServices/api_get_services.dart';
import 'package:parcel_delivery_app/services/apiServices/api_post_services.dart';
import 'package:parcel_delivery_app/services/appStroage/location_storage.dart';
import 'package:parcel_delivery_app/widgets/app_snackbar/custom_snackbar.dart';

class CurrentOrderController extends GetxController {
  RxBool isLoading = false.obs;
  RxBool isReviewLoading = false.obs;
  RxBool isDeliverFinished = false.obs;
  Rx<CurrentOrderModel> currentOrdersModel = CurrentOrderModel().obs;
  var rating = 1.0.obs;
  var parcelID = "".obs;
  var userID = "".obs;

  var finishedParcelId = "".obs;
  var parcelStatus = "".obs;

  // Add caching variables
  RxBool hasDataCached = false.obs;
  DateTime? lastFetchTime;
  static const Duration cacheValidDuration =
      Duration(minutes: 15); // Cache valid for 15 minutes

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

          // Notify listeners about the update
          update();

          return currentOrdersModel.value;
        } else {
          log("Unexpected response type: ${response.runtimeType}");
          // Initialize with empty data to prevent null checks
          currentOrdersModel.value = CurrentOrderModel(data: []);
          update();
          return null;
        }
      } catch (parseError) {
        log("Error parsing response data: ${parseError.toString()}");
        // Initialize with empty data to prevent null checks
        currentOrdersModel.value = CurrentOrderModel(data: []);
        update();
        return null;
      }
    } catch (ex) {
      log("Error in getCurrentOrder: ${ex.toString()}");
      // Initialize with empty data to prevent null checks
      currentOrdersModel.value = CurrentOrderModel(data: []);
      update();
      return null;
    } finally {
      isLoading(false);
    }
  }

  Future<void> givingReview() async {
    try {
      // Validate required fields
      if (parcelID.value.isEmpty) {
        //AppSnackBar.error("Parcel information is missing");
        return;
      }

      if (userID.value.isEmpty) {
        AppSnackBar.error("Delivery person information is missing");
        return;
      }

      isReviewLoading(true);

      final Map<String, dynamic> body = {
        "parcelId": parcelID.value,
        "rating": rating.value,
        "targetUserId": userID.value,
      };

      log("Submitting review: $body");

      final response = await ApiPostServices().apiPostServices(
          url: AppApiUrl.givingReview, body: body, statusCode: 200);

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
    try {
      isDeliverFinished(true);
      final Map<String, dynamic> body = {
        "parcelId": finishedParcelId.value,
        "status": parcelStatus.value,
      };
      final response = await ApiPostServices().apiPostServices(
          url: AppApiUrl.finishedDelivery, body: body, statusCode: 200);
      if (response != null) {
        log("Successfully finished delivery");
        AppSnackBar.success("Successfully finished delivery");

        // Clear cache and force refresh to get updated data
        await clearCacheAndRefresh();

        // Notify all listeners about the change
        update();
      } else {
        log("Failed to finish delivery");
        AppSnackBar.error("Failed to finish delivery. Please try again.");
      }
    } catch (ex) {
      log("Error in finishedDelivery: ${ex.toString()}");
      AppSnackBar.error("Something went wrong: ${ex.toString()}");
    } finally {
      isLoading(false);
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
    clearCachedAddresses(); // Clear address cache as well
    await getCurrentOrder();
    update(); // Notify all listeners about the change
  }

  // Cache for storing addresses to avoid repeated API calls
  final Map<String, String> _cachedAddresses = {};

  /// Enhanced method to prefetch addresses for all parcels with caching
  Future<void> prefetchAllAddresses(List<dynamic> parcels) async {
    try {
      if (parcels.isEmpty) return;

      // Use the enhanced caching system to preload addresses
      final cachedAddresses = await LocationStorage.instance
          .getCachedAddressesWithFallback(parcels);

      // Store the cached addresses for immediate UI display
      _cachedAddresses.addAll(cachedAddresses);

      // Trigger UI update to show cached addresses immediately
      update();

      log('CurrentOrderController: Prefetched ${cachedAddresses.length} addresses with caching');
    } catch (e) {
      log('CurrentOrderController: Failed to prefetch addresses: $e');
    }
  }

  /// Get cached address for a specific parcel and location type
  String getCachedAddress(String parcelId, String locationType) {
    final cacheKey = '${parcelId}_$locationType';
    return _cachedAddresses[cacheKey] ?? 'Loading...';
  }

  /// Clear cached addresses
  void clearCachedAddresses() {
    _cachedAddresses.clear();
  }
}
