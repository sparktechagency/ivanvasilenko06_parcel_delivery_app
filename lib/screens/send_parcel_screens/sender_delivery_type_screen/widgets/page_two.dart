import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:parcel_delivery_app/constants/app_colors.dart';
import 'package:parcel_delivery_app/constants/app_icons_path.dart';
import 'package:parcel_delivery_app/screens/send_parcel_screens/controller/sending_parcel_controller.dart';
import 'package:parcel_delivery_app/widgets/icon_widget/icon_widget.dart';
import 'package:parcel_delivery_app/widgets/space_widget/space_widget.dart';
import 'package:parcel_delivery_app/widgets/text_widget/text_widgets.dart';

import '../../../../services/reporsitory/location_repository/location_repository.dart';

class PageTwo extends StatefulWidget {
  const PageTwo({super.key});

  @override
  State<PageTwo> createState() => _PageTwoState();
}

class _PageTwoState extends State<PageTwo> {
  final TextEditingController startingController = TextEditingController();
  final TextEditingController endingController = TextEditingController();

  String _activeLocationType = '';
  List<dynamic> _placePredictions = [];
  bool _isLoading = false;
  GoogleMapController? _mapController;
  final LocationRepository _locationRepository = LocationRepository();
  final FocusNode _startingFocusNode = FocusNode();
  final FocusNode _endingFocusNode = FocusNode();
  Set<Marker> _markers = {};
  bool _mapInitialized = false;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();

    // Add listeners to focus nodes to handle keyboard visibility changes
    _startingFocusNode.addListener(() {
      if (_startingFocusNode.hasFocus) {
        setState(() {
          _activeLocationType = 'starting';
        });
      }
    });

    _endingFocusNode.addListener(() {
      if (_endingFocusNode.hasFocus) {
        setState(() {
          _activeLocationType = 'ending';
        });
      }
    });
  }

  @override
  void dispose() {
    startingController.dispose();
    endingController.dispose();
    _mapController?.dispose();
    _startingFocusNode.dispose();
    _endingFocusNode.dispose();
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    final location = await _locationRepository.getCurrentLocation();
    if (location != null && mounted) {
      setState(() {
        // Update any state variables if needed
      });

      // Only animate camera if the map controller is initialized
      if (_mapController != null) {
        _mapController?.animateCamera(
          CameraUpdate.newLatLng(location),
        );
      }
    }
  }

  // Handle place autocomplete
  Future<void> _placeAutoComplete(String query) async {
    if (query.isEmpty) {
      setState(() {
        _placePredictions = [];
      });
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final predictions = await _locationRepository.placeAutoComplete(query);
      if (mounted) {
        setState(() {
          _placePredictions = predictions;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _placePredictions = [];
          _isLoading = false;
        });
      }
      debugPrint('Error: $e');
    }
  }

  void _onStartingLocationSelected(String placeId, String description) async {
    // Update UI immediately
    setState(() {
      _placePredictions = [];
      startingController.text = description;
      _activeLocationType = '';
    });

    // Update controller
    Get.find<ParcelController>().setStartingLocation(description);

    try {
      // Fetch location details
      final location =
          await _locationRepository.fetchPlaceDetails(placeId, 'starting');

      // Check if widget is still mounted before updating UI
      if (location != null && mounted) {
        // Move camera to the location
        _mapController?.animateCamera(
          CameraUpdate.newLatLng(location),
        );

        // Force UI update to refresh map
        setState(() {
          _markers = _locationRepository.markers;
        });
      }
    } catch (e) {
      debugPrint('Error fetching starting location details: $e');
    }

    // Unfocus keyboard
    FocusScope.of(context).unfocus();
  }

  // Handle ending location selection
  void _onEndingLocationSelected(String placeId, String description) async {
    // Update UI immediately
    setState(() {
      _placePredictions = [];
      endingController.text = description;
      _activeLocationType = '';
    });

    // Update controller
    Get.find<ParcelController>().setEndingLocation(description);

    try {
      // Fetch place details and update map
      final location =
          await _locationRepository.fetchPlaceDetails(placeId, 'ending');

      // Check if widget is still mounted before updating UI
      if (location != null && mounted) {
        // Move camera to the location
        _mapController?.animateCamera(
          CameraUpdate.newLatLng(location),
        );

        // Force UI update to refresh map
        setState(() {
          _markers = _locationRepository.markers;
        });
      }
    } catch (e) {
      debugPrint('Error fetching ending location details: $e');
    }

    // Unfocus keyboard
    FocusScope.of(context).unfocus();
  }

  // Build prediction list for autocomplete results
  Widget _buildPredictionsList() {
    if (_placePredictions.isEmpty || _isLoading) {
      return const SizedBox.shrink();
    }

    return Material(
      elevation: 4.0,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        constraints: const BoxConstraints(maxHeight: 200),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
        ),
        child: ListView.separated(
          shrinkWrap: true,
          padding: EdgeInsets.zero,
          itemCount: _placePredictions.length,
          separatorBuilder: (context, index) => const Divider(
            height: 1,
            thickness: 1,
            color: AppColors.greyLight2,
          ),
          itemBuilder: (context, index) {
            final prediction = _placePredictions[index];
            return ListTile(
              dense: true,
              visualDensity: const VisualDensity(vertical: -2),
              leading: const Icon(Icons.location_on,
                  color: AppColors.greyDarkLight2, size: 18),
              title: Text(
                prediction['description'],
                style: const TextStyle(fontSize: 14),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              onTap: () {
                final placeId = prediction['place_id'];
                final description = prediction['description'];

                if (_activeLocationType == 'starting') {
                  _onStartingLocationSelected(placeId, description);
                } else {
                  _onEndingLocationSelected(placeId, description);
                }
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildLocationInputs() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(width: 20),
        // Icons column
        IntrinsicHeight(
          child: Column(
            mainAxisSize: MainAxisSize.min,
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
        ),
        const SpaceWidget(spaceWidth: 12),
        // Text fields column
        Expanded(
          child: Column(
            children: [
              TextFormField(
                controller: startingController,
                focusNode: _startingFocusNode,
                onChanged: (query) {
                  setState(() {
                    _activeLocationType = 'starting';
                  });
                  _placeAutoComplete(query);
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
              const SpaceWidget(spaceHeight: 08),
              TextFormField(
                controller: endingController,
                focusNode: _endingFocusNode,
                onChanged: (query) {
                  setState(() {
                    _activeLocationType = 'ending';
                  });
                  _placeAutoComplete(query);
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
              const SpaceWidget(spaceHeight: 08),
            ],
          ),
        ),
        const SpaceWidget(spaceWidth: 16),
      ],
    );
  }

  // Build the map section
  Widget _buildMap() {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.65,
      width: double.infinity,
      child: GoogleMap(
        initialCameraPosition:
            _locationRepository.currentLocationCoordinates != null
                ? CameraPosition(
                    target: _locationRepository.currentLocationCoordinates!,
                    zoom: 12.0,
                  )
                : const CameraPosition(
                    target: LatLng(23.76171, 90.43128), // Default position
                    zoom: 12.0,
                  ),
        onMapCreated: (GoogleMapController controller) {
          setState(() {
            _mapController = controller;
            _mapInitialized = true;
          });

          if (_locationRepository.currentLocationCoordinates != null) {
            _mapController?.animateCamera(
              CameraUpdate.newLatLng(
                  _locationRepository.currentLocationCoordinates!),
            );
          }
        },
        mapType: MapType.terrain,
        markers: _locationRepository.markers.isNotEmpty
            ? _locationRepository.markers
            : _markers,
        polylines: _locationRepository.polyline != null
            ? {_locationRepository.polyline!}
            : {},
        myLocationButtonEnabled: true,
        myLocationEnabled: true,
        scrollGesturesEnabled: true,
        zoomGesturesEnabled: true,
        tiltGesturesEnabled: true,
        rotateGesturesEnabled: true,
        zoomControlsEnabled: true,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
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
        elevation: 0,
      ),
      backgroundColor: AppColors.white,
      body: GestureDetector(
        onTap: () {
          // Close keyboard when tapping outside of text fields
          FocusScope.of(context).unfocus();
          setState(() {
            _placePredictions = [];
            _activeLocationType = '';
          });
        },
        child: SafeArea(
          child: Stack(
            children: [
              // Main content
              Column(
                children: [
                  // Location input fields
                  _buildLocationInputs(),

                  // Spacer
                  const SpaceWidget(spaceHeight: 16),

                  // Map section
                  Expanded(child: _buildMap()),
                ],
              ),

              // Position predictions list properly - now with correct positioning
              if (_activeLocationType.isNotEmpty &&
                  _placePredictions.isNotEmpty)
                Positioned(
                  top: _activeLocationType == 'starting' ? 60 : 120,
                  left: 47,
                  right: 16,
                  child: _buildPredictionsList(),
                ),

              // Loading indicator
              if (_isLoading)
                Positioned(
                  top: _activeLocationType == 'starting' ? 60 : 120,
                  left: 47,
                  right: 16,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
