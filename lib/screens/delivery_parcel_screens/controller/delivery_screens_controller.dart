import 'dart:convert';
import 'dart:developer';

import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:parcel_delivery_app/constants/api_url.dart';
import 'package:parcel_delivery_app/services/apiServices/api_get_services.dart';
import 'package:parcel_delivery_app/services/apiServices/api_post_services.dart';
import 'package:parcel_delivery_app/widgets/app_snackbar/custom_snackbar.dart';

import '../models/delivery_screen_models.dart';

class DeliveryScreenController extends GetxController {
// For storing delivery type and addresses
  RxString selectedDeliveryType = ''.obs;
  RxString pickupLocation = ''.obs;
  RxString selectedDeliveryLocation = ''.obs;

  // For storing pickup lat/lng as strings
  RxString pickupLocationLatitude = ''.obs;
  RxString pickupLocationLongitude = ''.obs;

  // For storing starting/ending coordinates as LatLng
  Rxn<LatLng> startingCoordinates = Rxn<LatLng>();
  Rxn<LatLng> endingCoordinates = Rxn<LatLng>();

  // For Showing Parcels List using Model
  RxList<DeliverParcelList> parcels = RxList<DeliverParcelList>();
  RxBool isLoading = false.obs;

  // New variable to store parcel IDs that need to be sent
  RxList<String> selectedParcelIds = RxList<String>();

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
    // if (selectedDeliveryType.value.isNotEmpty &&
    //     selectedDeliveryLocation.value.isNotEmpty) {
    //   isLoading.value = true;
    //   try {
    //     // final String url = '${AppApiUrl.deliverParcel}?deliveryType=${selectedDeliveryType.value}&pickupLocation=${pickupLocation.value}&deliveryLocation=${selectedDeliveryLocation.value}&radius=${radius.value}';
    //     final String url =
    //         "https://azizul3000.binarybards.online/api/parcel/filtered?deliveryType=truck&pickupLocation=Faridpur&deliveryLocation=Banasree&latitude=23.6057352&longitude=89.8386531&radius=10";
    //
    //     final response = await ApiGetServices().apiGetServices(url);
    //     print("body res====================================================");
    //     print(response.body);
    //
    //     if (response.status == "success" &&
    //         response.deliveryParcelList != null) {
    //       parcels.value = (response.deliveryParcelList as List)
    //           .map((item) => DeliverParcelList.fromJson(item))
    //           .toList();
    //     } else {
    //       parcels.clear();
    //     }
    //   } catch (e) {
    //     log("Error fetching parcels: $e");
    //     parcels.clear();
    //   } finally {
    //     isLoading.value = false;
    //   }
    // } else {
    //   parcels.cle
  }

  RxList<DeliverParcelList> deliveryParcelList = <DeliverParcelList>[].obs;

  // Future<void> fetchDeliveryParcelsList() async {
  //   // try {
  //   //   // final String url = '${AppApiUrl.deliverParcel}?deliveryType=${selectedDeliveryType.value}&pickupLocation=${pickupLocation.value}&deliveryLocation=${selectedDeliveryLocation.value}&radius=${radius.value}';
  //   //   final String url =
  //   //       "https://azizul3000.binarybards.online/api/parcel/filtered?deliveryType=truck&pickupLocation=Faridpur&deliveryLocation=Banasree&latitude=23.6057352&longitude=89.8386531&radius=10";
  //   //   print("Api url************************");
  //   //   print(url);
  //   //
  //   //   final response = await ApiGetServices().apiGetServices(url);
  //   //   print("Response body******************************** my code");
  //   //   print(response.statusCode);
  //   //   if (response.statusCode == 200) {
  //   //     DeliverParcelModel fetchStoryModel =
  //   //         DeliverParcelModel.fromJson(response.body);
  //   //     if (fetchStoryModel.deliveryParcelList != null) {
  //   //       deliveryParcelList.addAll(fetchStoryModel.deliveryParcelList!);
  //   //     }
  //   //   } else {
  //   //     log("Error on delivery parcel");
  //   //   }
  //   // } catch (e) {
  //   //   log("Error on delivery parcel", error: e);
  //   // }
  //   var c = true;
  //   if (c == true) {
  //     isLoading.value = true;
  //     try {
  //       // final String url = '${AppApiUrl.deliverParcel}?deliveryType=${selectedDeliveryType.value}&pickupLocation=${pickupLocation.value}&deliveryLocation=${selectedDeliveryLocation.value}&radius=${radius.value}';
  //       final String url =
  //           "https://azizul3000.binarybards.online/api/parcel/filtered?deliveryType=truck&pickupLocation=Faridpur&deliveryLocation=Banasree&latitude=23.6057352&longitude=89.8386531&radius=10";
  //
  //       final response = await ApiGetServices().apiGetServices(url);
  //       print("body res====================================================");
  //       print(response.data);
  //
  //       if (response.status == "success" &&
  //           response.deliveryParcelList != null) {
  //         parcels.value = (response.deliveryParcelList as List)
  //             .map((item) => DeliverParcelList.fromJson(item))
  //             .toList();
  //
  //         print("Parcel list**********==========================");
  //         print(parcels.value);
  //       } else {
  //         parcels.clear();
  //       }
  //     } catch (e) {
  //       log("Error fetching parcels: $e");
  //       parcels.clear();
  //     } finally {
  //       isLoading.value = false;
  //     }
  //   } else {
  //     parcels.clear();
  //
  Future<void> fetchDeliveryParcelsList() async {
    if (selectedDeliveryType.value != null &&
        pickupLocation.value != null &&
        selectedDeliveryLocation.value != null) {
      isLoading.value = true;
      try {
        final String url =
            '${AppApiUrl.deliverParcel}?deliveryType=${selectedDeliveryType.value}&pickupLocation=${pickupLocation.value}&deliveryLocation=${selectedDeliveryLocation.value}&latitude=${pickupLocationLatitude.value}&longitude=${pickupLocationLongitude.value}}';

        final response = await ApiGetServices().apiGetServices(url);
        print("Body res 👀👀👀👀👀👀👀👀👀👀👀👀👀👀👀");
        print(response);

        if (response != null &&
            response['status'] == 'success' &&
            response['data'] != null) {
          parcels.value = (response['data'] as List)
              .map((item) => DeliverParcelList.fromJson(item))
              .toList();

          print("Parcel list**********=============================");
          print(parcels.value.length);
        } else {
          parcels.clear();
        }
      } catch (e) {
        log("Error fetching parcels: $e");
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
      AppSnackBar.error("No parcel selected");
      return;
    }

    isLoading.value = true;
    try {
      // POST request URL for sending parcel ID to the database
      const String requestUrl = AppApiUrl.deliveryRequest;

      // Prepare the body for the POST request
      final data = json.encode({
        'parcelIds': [parcelId],
      });

      final response = await ApiPostServices().apiPostServices(
        url: requestUrl,
        body: data,
      );

      if (response != null && response['status'] == 'success') {
        AppSnackBar.success("Parcel request sent successfully");
      } else {
        AppSnackBar.error("Failed to send parcel request");
      }
    } catch (e) {
      AppSnackBar.error("Error sending parcel request: $e");
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onInit() {
    fetchParcels();
    // TODO: implement onInit
    super.onInit();
  }
}
