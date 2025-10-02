
import 'dart:developer';

import 'package:get/get.dart';
import 'package:parcel_delivery_app/screens/services_screen/model/service_screen_model.dart';
import 'package:parcel_delivery_app/services/apiServices/api_get_services.dart';

import '../../../constants/api_url.dart';
import '../../../services/appStroage/share_helper.dart';

class ServiceController extends GetxController {
  RxBool loading = false.obs;
  RxList<ServiceScreenModel> recentParcelList = <ServiceScreenModel>[].obs;

  // For tracking parcel detail fetching
  RxBool detailLoading = false.obs;
  Rx<Datum?> selectedParcel = Rx<Datum?>(null);
  
  // Add caching variables
  RxBool hasDataCached = false.obs;
  DateTime? lastFetchTime;
  static const Duration cacheValidDuration = Duration(minutes: 30); // Cache valid for 30 minutes

  @override
  void onInit() {
    super.onInit();
    // Only load data if not cached or cache is expired
    if (!hasDataCached.value || _isCacheExpired()) {
      fetchParcelList();
    }
  }

  // Check if cache is expired
  bool _isCacheExpired() {
    if (lastFetchTime == null) return true;
    return DateTime.now().difference(lastFetchTime!) > cacheValidDuration;
  }

  // Method to get cached data or fetch fresh data
  Future<void> fetchParcelListWithCache({bool forceRefresh = false}) async {
    // If we have cached data and it's not expired, and not forcing refresh, return cached data
    if (hasDataCached.value && !_isCacheExpired() && !forceRefresh) {
      log('📦 Using cached services data');
      return;
    }
    
    // Otherwise, fetch fresh data
    await fetchParcelList();
  }

  Future<void> fetchParcelList() async {
    try {
      loading.value = true;
      log("Fetching parcel list...");

      // Retrieve token
      var token = await SharePrefsHelper.getString(SharedPreferenceValue.token);
      if (token.isEmpty) {
        log("Error: No token found in SharedPreferences");
        // AppSnackBar.error('Authentication token missing. Please log in again.');
        loading.value = false;
        return;
      }

      // Make API call
      final response = await ApiGetServices()
          .apiGetServices(AppApiUrl.servicePromote, token: token);

      log("API Response: $response");

      // Check if response is valid
      if (response == null || response.isEmpty) {
        log("Error: Empty or null API response");
        // AppSnackBar.error(
        //     'Failed to load parcels. Empty response from server.');
        recentParcelList.clear();
        loading.value = false;
        return;
      }

      // Process the response
      if (response["status"] == "success" && response["data"] != null) {
        recentParcelList.clear();
        List<dynamic> dataList = response["data"];

        if (dataList.isEmpty) {
          //! log("No parcels found in API response");
          // AppSnackBar.error('No parcels found.');
        } else {
          // Create individual ServiceScreenModel objects for each parcel
          for (var parcel in dataList) {
            try {
              // Create a proper structure for ServiceScreenModel
              // Each parcel becomes a data item in a new ServiceScreenModel
              var serviceModel = ServiceScreenModel(
                  status: parcel["status"], data: [Datum.fromJson(parcel)]);

              // Add to the list
              recentParcelList.add(serviceModel);
              //!  log("Added parcel: ${parcel["_id"]} - ${parcel["title"] ?? 'No title'}");
            } catch (e) {
              //!  log("Error processing parcel: $e for parcel: $parcel");
            }
          }
          //! log("Parcel list updated. Total items: ${recentParcelList.length}");
        }
        
        // Mark data as cached and update fetch time
        hasDataCached.value = true;
        lastFetchTime = DateTime.now();
        log('📦 Services data cached successfully');
      } else {
        //! log("API Error: ${response["message"] ?? "Unknown error"}");
        // AppSnackBar.error(response["message"] ?? 'Failed to load parcels.');
        recentParcelList.clear();
      }
    } catch (e) {
      //! log("Error fetching parcel list: $e", stackTrace: stackTrace);
      // AppSnackBar.error('Failed to load parcels. Please try again later.');
      recentParcelList.clear();
    } finally {
      loading.value = false;
    }
  }

  // Method to fetch details for a specific parcel
  Datum? getParcelById(String? id) {
    if (id == null) return null;

    for (var item in recentParcelList) {
      if (item.data != null && item.data!.isNotEmpty) {
        for (var datum in item.data!) {
          if (datum.id == id) {
            return datum;
          }
        }
      }
    }
    return null;
  }

  // Method to fetch a specific parcel from the API
  Future<Datum?> fetchParcelById(String id) async {
    try {
      detailLoading.value = true;
      //! log("Fetching parcel details for ID: $id");

      // First check if we already have this parcel
      Datum? existingParcel = getParcelById(id);
      if (existingParcel != null) {
        selectedParcel.value = existingParcel;
        return existingParcel;
      }

      // If not found in local storage, make API call
      var token = await SharePrefsHelper.getString(SharedPreferenceValue.token);
      if (token.isEmpty) {
        //! log("Error: No token found in SharedPreferences");
        // AppSnackBar.error('Authentication token missing. Please log in again.');
        return null;
      }

      // Make API call to fetch specific parcel
      // You would need an API endpoint that can fetch a specific parcel by ID
      // For example: `${AppApiUrl.servicePromote}/$id`
      final response = await ApiGetServices()
          .apiGetServices("${AppApiUrl.servicePromote}/$id", token: token);

      if (response == null || response.isEmpty) {
        //! log("Error: Empty or null API response");
        // AppSnackBar.error('Failed to load parcel details.');
        return null;
      }

      if (response["status"] == "success" && response["data"] != null) {
        var parcelData = response["data"];
        Datum parcel = Datum.fromJson(parcelData);
        selectedParcel.value = parcel;
        return parcel;
      } else {
        //! log("API Error: ${response["message"] ?? "Unknown error"}");
        // AppSnackBar.error(
        //     response["message"] ?? 'Failed to load parcel details.');
        return null;
      }
    } catch (e) {
      //! log("Error fetching parcel details: $e");
      // AppSnackBar.error(
      //     'Failed to load parcel details. Please try again later.');
      return null;
    } finally {
      detailLoading.value = false;
    }
  }

  // Method to manually refresh the list
  void refreshParcelList() {
    fetchParcelList();
  }

  // Method to clear cache and force refresh
  void clearCacheAndRefresh() {
    hasDataCached.value = false;
    lastFetchTime = null;
    fetchParcelList();
  }
}