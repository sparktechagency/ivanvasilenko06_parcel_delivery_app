import 'dart:convert';
import 'dart:developer';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:parcel_delivery_app/constants/api_url.dart';
import 'package:parcel_delivery_app/services/apiServices/api_post_services.dart';
import 'package:parcel_delivery_app/screens/delivery_parcel_screens/models/delivery_screen_models.dart';

class EarnMoneyRadiusController extends GetxController {
  RxDouble radius = 5.0.obs;
  Rxn<LatLng> currentLocation = Rxn<LatLng>();
  RxList<Marker> markers = <Marker>[].obs;
  RxList<DeliverParcelList> parcels = <DeliverParcelList>[].obs;
  RxBool isLoading = false.obs;

  void setCurrentLocation(LatLng location) {
    currentLocation.value = location;
  }

  Future<void> fetchParcelsInRadius() async {
    if (currentLocation.value == null) {
      log('Current location is null. Cannot fetch parcels.');
      return;
    }

    final lat = currentLocation.value!.latitude;
    final lng = currentLocation.value!.longitude;
    final radiusValue = radius.value;

    log('Fetching parcels with: Lat: $lat, Lng: $lng, Radius: $radiusValue');

    try {
      isLoading.value = true;
      
      final requestBody = json
          .encode({'latitude': lat, 'longitude': lng, 'radius': radiusValue});

      log('API Request URL: ${AppApiUrl.getParcelInRadius}');
      log('API Request Body: $requestBody');

      final response = await ApiPostServices()
          .apiPostServices(url: AppApiUrl.getParcelInRadius, body: requestBody);

      log('API Response: $response');

      if (response != null && response['status'] == 'success') {
        List<dynamic> data = response['data'];
        parcels.value = data.map((json) => DeliverParcelList.fromJson(json)).toList();

        markers.clear();
        for (var parcel in parcels) {
          if (parcel.pickupLocation?.coordinates != null &&
              parcel.pickupLocation!.coordinates!.length >= 2) {
            double pickupLat = parcel.pickupLocation!.coordinates![1];
            double pickupLng = parcel.pickupLocation!.coordinates![0];

            markers.add(Marker(
              markerId: MarkerId(parcel.sId ?? ''),
              position: LatLng(pickupLat, pickupLng),
              infoWindow: InfoWindow(
                  title: parcel.title ?? 'Parcel', 
                  snippet: parcel.description ?? ''),
            ));
          }
        }

        log('Found ${markers.length} parcels in radius');
      } else {
        log('API returned error or invalid data: $response');
        parcels.value = [];
        markers.clear();
      }
    } catch (e, stackTrace) {
      log('Exception while fetching parcels: $e');
      log('Stack trace: $stackTrace');
      parcels.value = [];
      markers.clear();
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onInit() {
    super.onInit();
    fetchParcelsInRadius();
  }
}
