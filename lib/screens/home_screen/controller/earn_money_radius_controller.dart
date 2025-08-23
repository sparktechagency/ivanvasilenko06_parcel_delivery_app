import 'dart:convert';
import 'dart:developer';

import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:parcel_delivery_app/constants/api_url.dart';
import 'package:parcel_delivery_app/services/apiServices/api_post_services.dart';

class EarnMoneyRadiusController extends GetxController {
  RxDouble radius = 5.0.obs;
  Rxn<LatLng> currentLocation = Rxn<LatLng>();
  RxList<Marker> markers = <Marker>[].obs;
  RxList<dynamic> parcelsInRadius = <dynamic>[].obs;

  void setCurrentLocation(LatLng location) {
    currentLocation.value = location;
  }

  Future<void> fetchParcelsInRadius() async {
    if (currentLocation.value == null) {
      //! log('Current location is null. Cannot fetch parcels.');
      return;
    }

    final lat = currentLocation.value!.latitude;
    final lng = currentLocation.value!.longitude;
    final radiusValue = radius.value;

   //!  log('Fetching parcels with: Lat: $lat, Lng: $lng, Radius: $radiusValue');

    try {
      final requestBody = json
          .encode({'latitude': lat, 'longitude': lng, 'radius': radiusValue});

      //! log('API Request URL: ${AppApiUrl.getParcelInRadius}');
      //! log('API Request Body: $requestBody');

      final response = await ApiPostServices()
          .apiPostServices(url: AppApiUrl.getParcelInRadius, body: requestBody);

     //!  log('API Response: $response');

      if (response != null && response['status'] == 'success') {
        List<dynamic> data = response['data'];
        parcelsInRadius.value = data; // Store the fetched parcels

        markers.clear();
        for (var parcel in data) {
          double pickupLat = parcel["pickupLocation"]["coordinates"][1];
          double pickupLng = parcel["pickupLocation"]["coordinates"][0];

          markers.add(Marker(
            markerId: MarkerId(parcel["_id"]),
            position: LatLng(pickupLat, pickupLng),
            infoWindow: InfoWindow(
                title: parcel["title"], snippet: parcel["description"]),
          ));
        }

        //! log('Found ${markers.length} parcels in radius');
      } else {
        //! log('API returned error or invalid data: $response');
        parcelsInRadius.value = [];
        markers.clear();
      }
    } catch (e, stackTrace) {
     //!  log('Exception while fetching parcels: $e');
      //! log('Stack trace: $stackTrace');
      parcelsInRadius.value = [];
      markers.clear();
    }
  }

  @override
  void onInit() {
    super.onInit();
    fetchParcelsInRadius();
  }
}
