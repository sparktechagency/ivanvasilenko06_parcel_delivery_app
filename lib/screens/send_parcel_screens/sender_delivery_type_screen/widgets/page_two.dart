import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:parcel_delivery_app/constants/api_key.dart';
import 'package:parcel_delivery_app/constants/app_colors.dart';
import 'package:parcel_delivery_app/constants/app_icons_path.dart';
import 'package:parcel_delivery_app/screens/send_parcel_screens/controller/sending_parcel_controller.dart';
import 'package:parcel_delivery_app/widgets/icon_widget/icon_widget.dart';
import 'package:parcel_delivery_app/widgets/space_widget/space_widget.dart';
import 'package:parcel_delivery_app/widgets/text_widget/text_widgets.dart';

class PageTwo extends StatefulWidget {
  const PageTwo({super.key});

  @override
  State<PageTwo> createState() => _PageTwoState();
}

class _PageTwoState extends State<PageTwo> {
  final TextEditingController startingController = TextEditingController();
  final TextEditingController endingController = TextEditingController();
  List<dynamic> _placePredictions = [];
  bool _isLoading = false;

  // Variables to store selected location's coordinates
  LatLng? _startingLocationCoordinates;
  LatLng? _endingLocationCoordinates;
  GoogleMapController? _mapController;
  final Set<Marker> _markers = <Marker>{};
  Polyline? _polyline;

  // Fetch autocomplete predictions from Google Places API
  Future<void> placeAutoComplete(String query,
      {required String locationType}) async {
    if (query.isEmpty) {
      setState(() {
        _placePredictions = [];
      });
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final Uri uri = Uri.https(
      'maps.googleapis.com',
      'maps/api/place/autocomplete/json',
      {
        'input': query,
        'key': apikey,
      },
    );

    try {
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _placePredictions = data['predictions'];
        });
      } else {
        setState(() {
          _placePredictions = [];
        });
      }
    } catch (e) {
      setState(() {
        _placePredictions = [];
      });
      debugPrint('Error: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Handle selection of a starting location
  void onStartingLocationSelected(String placeId, String description) async {
    setState(() {
      _placePredictions = [];
      startingController.text = description;
    });
    // Update the location in the controller
    Get.find<ParcelController>().setStartingLocation(description);
    await fetchPlaceDetails(placeId, 'starting');
  }

  // Handle selection of an ending location
  void onEndingLocationSelected(String placeId, String description) async {
    setState(() {
      _placePredictions = [];
      endingController.text = description;
    });
    // Update the location in the controller
    Get.find<ParcelController>().setEndingLocation(description);
    await fetchPlaceDetails(placeId, 'ending');
  }

  // Fetch details of the selected place using the place_id
  Future<void> fetchPlaceDetails(String placeId, String locationType) async {
    final Uri uri = Uri.https(
      'maps.googleapis.com',
      'maps/api/place/details/json',
      {
        'place_id': placeId,
        'key': apikey,
      },
    );

    try {
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final location = data['result']['geometry']['location'];

        setState(() {
          if (locationType == 'starting') {
            _startingLocationCoordinates =
                LatLng(location['lat'], location['lng']);
            _markers.add(
              Marker(
                markerId: const MarkerId('starting-location'),
                position: _startingLocationCoordinates!,
                infoWindow: InfoWindow(
                  title: startingController.text,
                  snippet: 'This is your starting location',
                ),
              ),
            );
          } else if (locationType == 'ending') {
            _endingLocationCoordinates =
                LatLng(location['lat'], location['lng']);
            _markers.add(
              Marker(
                markerId: const MarkerId('ending-location'),
                position: _endingLocationCoordinates!,
                infoWindow: InfoWindow(
                  title: endingController.text,
                  snippet: 'This is your ending location',
                ),
              ),
            );
          }
        });

        // Fetch the route directions once both locations are selected
        if (_startingLocationCoordinates != null &&
            _endingLocationCoordinates != null) {
          await fetchDirections();
        }

        // Move map camera to selected location
        _mapController?.animateCamera(CameraUpdate.newLatLng(
            locationType == 'starting'
                ? _startingLocationCoordinates!
                : _endingLocationCoordinates!));
      }
    } catch (e) {
      debugPrint('Error: $e');
    }
  }

  // Fetch directions using the Google Directions API
  Future<void> fetchDirections() async {
    if (_startingLocationCoordinates == null ||
        _endingLocationCoordinates == null) {
      return;
    }
    final String url =
        'https://maps.googleapis.com/maps/api/directions/json?origin=${_startingLocationCoordinates!.latitude},${_startingLocationCoordinates!.longitude}&destination=${_endingLocationCoordinates!.latitude},${_endingLocationCoordinates!.longitude}&key=$apikey';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List<LatLng> polylineCoordinates =
          _decodePolyline(data['routes'][0]['overview_polyline']['points']);

      setState(() {
        _polyline = Polyline(
          polylineId: const PolylineId('route'),
          points: polylineCoordinates,
          color: Colors.black,
          width: 5,
        );
      });
    } else {
      debugPrint('Error fetching directions: ${response.statusCode}');
    }
  }

  // Decode polyline encoded string into LatLng points
  List<LatLng> _decodePolyline(String encoded) {
    List<LatLng> polylineCoordinates = [];
    int index = 0;
    int len = encoded.length;
    int lat = 0;
    int lng = 0;

    while (index < len) {
      int b;
      int shift = 0;
      int result = 0;

      // Decode latitude
      do {
        b = encoded.codeUnitAt(index) - 63;
        index++;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      lat += (result & 0x01) != 0 ? ~(result >> 1) : (result >> 1);

      shift = 0;
      result = 0;

      // Decode longitude
      do {
        b = encoded.codeUnitAt(index) - 63;
        index++;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      lng += (result & 0x01) != 0 ? ~(result >> 1) : (result >> 1);

      polylineCoordinates.add(LatLng(
        (lat / 1E5).toDouble(),
        (lng / 1E5).toDouble(),
      ));
    }
    return polylineCoordinates;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: TextWidget(
            text: "enterDeliveryLocation".tr,
            fontSize: 24,
            fontWeight: FontWeight.w600,
            fontColor: AppColors.black,
            textAlignment: TextAlign.start,
          ),
        ),
        automaticallyImplyLeading: false,
        backgroundColor: AppColors.white,
      ),
      backgroundColor: AppColors.white,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SpaceWidget(spaceHeight: 24),
            Row(
              children: [
                const SizedBox(width: 24),
                Column(
                  children: [
                    const IconWidget(
                      height: 15,
                      width: 15,
                      icon: AppIconsPath.destinationIcon,
                    ),
                    Container(
                      width: 1,
                      height: 50,
                      color: AppColors.greyLight2,
                    ),
                    const IconWidget(
                      height: 15,
                      width: 15,
                      icon: AppIconsPath.currentLocationIcon,
                    ),
                  ],
                ),
                const SpaceWidget(spaceWidth: 12),
                Expanded(
                  child: Column(
                    children: [
                      TextFormField(
                        controller: startingController,
                        onChanged: (query) {
                          placeAutoComplete(query, locationType: 'starting');
                        },
                        style: const TextStyle(
                          color: AppColors.black,
                        ),
                        decoration: InputDecoration(
                          hintText: "Pickup Location".tr,
                          hintStyle: const TextStyle(
                            color: AppColors.greyDarkLight2,
                          ),
                        ),
                      ),
                      const SpaceWidget(spaceHeight: 12),
                      TextFormField(
                        controller: endingController,
                        onChanged: (query) {
                          placeAutoComplete(query, locationType: 'ending');
                        },
                        style: const TextStyle(
                          color: AppColors.black,
                        ),
                        decoration: InputDecoration(
                          hintText: "Destination".tr,
                          hintStyle: const TextStyle(
                            color: AppColors.greyDarkLight2,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SpaceWidget(spaceWidth: 16),
              ],
            ),
            const SpaceWidget(spaceHeight: 24),

            // Wrap GoogleMap and suggestion list with a Stack
            Stack(
              children: [
                SizedBox(
                  height: 500,
                  width: double.infinity,
                  child: GoogleMap(
                    initialCameraPosition: const CameraPosition(
                      target: LatLng(23.76171, 90.43128),
                      zoom: 12.0,
                    ),
                    onMapCreated: (GoogleMapController controller) {
                      _mapController = controller;
                    },
                    mapType: MapType.terrain,
                    markers: _markers,
                    zoomControlsEnabled: true,
                    polylines: _polyline != null ? {_polyline!} : {},
                  ),
                ),
                if (_placePredictions.isNotEmpty)
                  Positioned(
                    left: 16,
                    right: 16,
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xB3FFFFFF).withAlpha(160),
                      ),
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: _placePredictions.length,
                        itemBuilder: (context, index) {
                          final prediction = _placePredictions[index];
                          return ListTile(
                            title: Text(prediction['description']),
                            onTap: () => prediction['description']
                                    .contains(startingController.text)
                                ? onStartingLocationSelected(
                                    prediction['place_id'],
                                    prediction['description'])
                                : onEndingLocationSelected(
                                    prediction['place_id'],
                                    prediction['description']),
                          );
                        },
                      ),
                    ),
                  ),
                if (_isLoading)
                  Positioned(
                    top: 120,
                    left: 16,
                    right: 16,
                    child: Container(
                      color: Colors.white.withAlpha(70),
                      child: const Center(child: CircularProgressIndicator()),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
