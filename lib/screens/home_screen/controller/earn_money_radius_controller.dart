import 'dart:convert';

import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:parcel_delivery_app/constants/api_url.dart';
import 'package:parcel_delivery_app/services/apiServices/api_get_services.dart';
import 'package:parcel_delivery_app/screens/delivery_parcel_screens/models/delivery_screen_models.dart';
import 'package:parcel_delivery_app/utils/appLog/app_log.dart';

class EarnMoneyRadiusController extends GetxController {
  RxDouble radius = 5.0.obs;
  Rxn<LatLng> currentLocation = Rxn<LatLng>();
  RxList<Marker> markers = <Marker>[].obs;
  RxList<DeliverParcelList> parcels = <DeliverParcelList>[].obs;
  RxBool isLoading = false.obs;

  void setCurrentLocation(LatLng location) {
    currentLocation.value = location;
  }

  void fetchParcelsInRadius() async {
    try {
      // Check if current location is available
      if (currentLocation.value == null) {
        appLog("Error: Current location is null, cannot fetch parcels");
        return;
      }

      isLoading.value = true;
      
      final response = await ApiGetServices().apiGetServices(
        "${AppApiUrl.getParcelInRadius}?lat=${currentLocation.value!.latitude}&lng=${currentLocation.value!.longitude}&radius=${radius.value}",
      );

      if (response != null && response['status'] == 'success') {
        final List<dynamic> parcelsData = response['data'];
        parcels.value = parcelsData.map((json) => DeliverParcelList.fromJson(json)).toList();
        
        // Create markers for each parcel
        markers.clear();
        for (var parcel in parcels) {
          if (parcel.pickupLocation?.coordinates != null && 
              parcel.pickupLocation!.coordinates!.length >= 2) {
            markers.add(
              Marker(
                markerId: MarkerId(parcel.sId ?? ''),
                position: LatLng(
                  parcel.pickupLocation!.coordinates![1], // latitude
                  parcel.pickupLocation!.coordinates![0], // longitude
                ),
                infoWindow: InfoWindow(
                  title: parcel.title ?? 'Parcel',
                  snippet: parcel.description ?? '',
                ),
              ),
            );
          }
        }
      }
    } catch (e) {
      appLog("Error fetching parcels: $e");
    } finally {
      isLoading.value = false;
    }
  }

}
