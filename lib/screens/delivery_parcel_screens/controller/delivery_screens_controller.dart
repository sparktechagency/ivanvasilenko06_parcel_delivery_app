import 'dart:developer';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:parcel_delivery_app/constants/api_url.dart';
import 'package:parcel_delivery_app/services/apiServices/api_get_services.dart';
import '../models/delivery_screen_models.dart';

class DeliveryScreenController extends GetxController {
  // Observables for the locations
  RxString selectedDeliveryType = ''.obs;
  RxString pickupLocation = 'baridhara'.obs;
  RxString selectedDeliveryLocation = ''.obs;

  // New observables to store the coordinates of starting and ending locations
  Rx<LatLng?> startingCoordinates = Rx<LatLng?>(null);
  Rx<LatLng?> endingCoordinates = Rx<LatLng?>(null);

  RxList<Parcel> parcels = RxList<Parcel>();
  RxBool isLoading = false.obs;

  // Setter for selected delivery type
  void setSelectedDeliveryType(String type) {
    selectedDeliveryType.value = type;
    fetchParcels();
  }

  // Setter for selected delivery location (pickup)
  void setSelectedDeliveryLocation(String location) {
    selectedDeliveryLocation.value = location;
    fetchParcels();
  }

  // Setter for starting location and coordinates
  void setStartingLocation(String location, LatLng coordinates) {
    selectedDeliveryLocation.value = location; // Set the name of the starting location
    startingCoordinates.value = coordinates; // Set the coordinates of the starting location
    fetchParcels();
  }

  // Setter for ending location and coordinates
  void setEndingLocation(String location, LatLng coordinates) {
    selectedDeliveryLocation.value = location; // Set the name of the ending location
    endingCoordinates.value = coordinates; // Set the coordinates of the ending location
    fetchParcels();
  }

  // Fetch parcels based on selected delivery type and location
  Future<void> fetchParcels() async {
    if (selectedDeliveryType.value.isNotEmpty &&
        selectedDeliveryLocation.value.isNotEmpty) {
      isLoading.value = true;
      try {
        final String url =
            '${AppApiUrl.deliverParcel}?deliveryType=${selectedDeliveryType.value}&pickupLocation=${pickupLocation.value}&deliveryLocation=${selectedDeliveryLocation.value}';

        final response = await ApiGetServices().apiGetServices(url);

        if (response.status == "success" && response.data != null) {
          parcels.value = (response.data as List)
              .map((item) => Parcel.fromJson(item))
              .toList();
        } else {
          parcels.clear();
        }
      } catch (e) {
        log("Error fetching parcels: $e");
        parcels.clear();
        isLoading.value = false;
      }
    } else {
      parcels.clear(); // Clear the parcels list if type or location is empty
    }
  }

  // Optionally, you could add a method to clear the coordinates
  void clearLocations() {
    startingCoordinates.value = null;
    endingCoordinates.value = null;
    selectedDeliveryLocation.value = '';
  }
}
