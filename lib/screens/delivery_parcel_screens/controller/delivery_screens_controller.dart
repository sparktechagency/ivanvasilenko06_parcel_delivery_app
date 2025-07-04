import 'dart:convert';

import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:parcel_delivery_app/constants/api_url.dart';
import 'package:parcel_delivery_app/services/apiServices/api_get_services.dart';
import 'package:parcel_delivery_app/services/apiServices/api_post_services.dart';
import 'package:parcel_delivery_app/utils/appLog/app_log.dart';
import 'package:parcel_delivery_app/widgets/app_snackbar/custom_snackbar.dart';

import '../models/delivery_screen_models.dart';

class DeliveryScreenController extends GetxController {
  //! For storing delivery type and addresses
  RxString selectedDeliveryType = ''.obs;
  RxString pickupLocation = ''.obs;
  RxString selectedDeliveryLocation = ''.obs;

  //! For storing pickup lat/lng as strings
  RxString pickupLocationLatitude = ''.obs;
  RxString pickupLocationLongitude = ''.obs;

  // For storing current location lat/lng as strings
  RxString currentLocationLatitude = ''.obs;
  RxString currentLocationLongitude = ''.obs;

  // For storing starting/ending coordinates as LatLng
  Rxn<LatLng> startingCoordinates = Rxn<LatLng>();
  Rxn<LatLng> endingCoordinates = Rxn<LatLng>();

  // For Showing Parcels List using Model
  RxList<DeliverParcelList> parcels = RxList<DeliverParcelList>();
  RxBool isLoading = false.obs;

  // New variable to store parcel IDs that have been sent successfully
  RxSet<String> sentParcelIds = RxSet<String>();

  // Methods to set the pickup and destination
  void setStartingLocation(String address, LatLng latLng) {
    pickupLocation.value = address;
    startingCoordinates.value = latLng;
  }

  void setEndingLocation(String address, LatLng latLng) {
    selectedDeliveryLocation.value = address;
    endingCoordinates.value = latLng;
  }

  /// Will hold all the [LatLng] of each `deliveryLocation` from your API data.
  RxList<LatLng> allDeliveryCoordinates = <LatLng>[].obs;

  /// Parse the raw JSON string and store all `deliveryLocation` coordinates
  void parseAndStoreDeliveryMarkers(String responseBody) {
    final responseData = json.decode(responseBody);
    if (responseData["status"] == "success") {
      final dataList = responseData["data"] as List;
      final coords = <LatLng>[];
      for (final item in dataList) {
        final pickupLoc = item["pickupLocation"];
        if (pickupLoc != null && pickupLoc["coordinates"] is List) {
          final coordsList = pickupLoc["coordinates"] as List;
          // The array is [lng, lat], so you read them carefully
          if (coordsList.length == 2) {
            final double lng = coordsList[0].toDouble();
            final double lat = coordsList[1].toDouble();
            coords.add(LatLng(lat, lng));
          }
        }
      }
      // Store them in the reactive list so we can show them on the map
      allDeliveryCoordinates.assignAll(coords);
    }
  }

  // Fetch parcels based on selected delivery type, location, and radius
  Future<void> fetchParcels() async {
    // Existing implementation...
  }

  RxList<DeliverParcelList> deliveryParcelList = <DeliverParcelList>[].obs;

  Future<void> fetchDeliveryParcelsList() async {
    if (selectedDeliveryType.value != null &&
        pickupLocation.value != null &&
        selectedDeliveryLocation.value != null) {
      isLoading.value = true;
      try {
        final String url =
            '${AppApiUrl.deliverParcel}?deliveryType=${selectedDeliveryType.value}&pickupLocation=${pickupLocation.value}&deliveryLocation=${selectedDeliveryLocation.value}&latitude=${pickupLocationLatitude.value}&longitude=${pickupLocationLongitude.value}}';

        final response = await ApiGetServices().apiGetServices(url);
        appLog("Body res 👀👀👀👀👀👀👀👀👀👀👀👀👀👀👀");
        appLog(response);

        if (response != null &&
            response['status'] == 'success' &&
            response['data'] != null) {
          // Fix: Access the 'parcels' array inside the 'data' object
          final dataObject = response['data'];
          if (dataObject is Map<String, dynamic> &&
              dataObject['parcels'] != null) {
            parcels.value = (dataObject['parcels'] as List)
                .map((item) => DeliverParcelList.fromJson(item))
                .toList();
          } else {
            parcels.clear();
          }

          appLog("Parcel list**********=============================");
          appLog(parcels.value.length);
        } else {
          parcels.clear();
        }
      } catch (e) {
        appLog("Error fetching parcels: $e");
        parcels.clear();
      } finally {
        isLoading.value = false;
      }
    } else {
      parcels.clear();
    }
  }

  Future<void> sendParcelRequest(String parcelId) async {
    if (parcelId.isEmpty) {
      // AppSnackBar.error("No parcel selected");
      return;
    }

    isLoading.value = true;
    try {
      // POST request URL for sending parcel ID to the database
      const String requestUrl = AppApiUrl.deliveryRequest;
      final data = json.encode({
        'parcelIds': [parcelId],
      });
      final response = await ApiPostServices().apiPostServices(
        url: requestUrl,
        body: data,
      );

      if (response != null && response['status'] == 'success') {
        sentParcelIds.add(parcelId);
        update();
        AppSnackBar.success("Parcel request sent successfully");
      } else {
        // AppSnackBar.error("Failed to send parcel request");
      }
    } catch (e) {
      // AppSnackBar.error("Error sending parcel request: $e");
    } finally {
      isLoading.value = false;
    }
  }

  // Method to check if a request has been sent for a specific parcel
  bool isRequestSent(String? parcelId) {
    if (parcelId == null || parcelId.isEmpty) return false;
    return sentParcelIds.contains(parcelId);
  }

  @override
  void onInit() {
    fetchParcels();
    super.onInit();
  }

  @override
  void onClose() {
    pickupLocation.value = '';
    selectedDeliveryLocation.value = '';
    super.onClose();
  }
}
