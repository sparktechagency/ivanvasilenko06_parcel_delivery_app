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
      setState(() {});
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
    setState(() {
      _placePredictions = [];
      startingController.text = description;
    });

    Get.find<ParcelController>().setStartingLocation(description);

    final location =
        await _locationRepository.fetchPlaceDetails(placeId, 'starting');
    if (location != null && mounted) {
      setState(() {});
      _mapController?.animateCamera(
        CameraUpdate.newLatLng(location),
      );
    }
    FocusScope.of(context).unfocus();
  }

  // Handle ending location selection
  void _onEndingLocationSelected(String placeId, String description) async {
    setState(() {
      _placePredictions = [];
      endingController.text = description;
    });

    Get.find<ParcelController>().setEndingLocation(description);

    // Fetch place details and update map
    final location =
        await _locationRepository.fetchPlaceDetails(placeId, 'ending');
    if (location != null && mounted) {
      setState(() {});
      _mapController?.animateCamera(
        CameraUpdate.newLatLng(location),
      );
    }
    FocusScope.of(context).unfocus();
  }

  // Build prediction list for autocomplete results
  Widget _buildPredictionsList() {
    if (_placePredictions.isEmpty) {
      return const SizedBox.shrink();
    }

    return SingleChildScrollView(
      child: Container(
        constraints: const BoxConstraints(maxHeight: 200),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withAlpha(76),
              spreadRadius: 1,
              blurRadius: 3,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: _placePredictions.length,
          itemBuilder: (context, index) {
            final prediction = _placePredictions[index];
            return ListTile(
              dense: true,
              // Make list tiles more compact
              visualDensity: const VisualDensity(vertical: -2),
              // Further reduce height
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
                  // contentPadding: const EdgeInsets.symmetric(vertical: 5),
                ),
              ),
              const SpaceWidget(spaceHeight: 08),

              // Show predictions if active field is starting
              if (_activeLocationType == 'starting' &&
                  _placePredictions.isNotEmpty)
                _buildPredictionsList(),

              // Destination location field
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
                  // contentPadding: const EdgeInsets.symmetric(vertical: 5),
                ),
              ),
              const SpaceWidget(spaceHeight: 08),

              // Show predictions if active field is ending
              if (_activeLocationType == 'ending' &&
                  _placePredictions.isNotEmpty)
                _buildPredictionsList(),
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
          _mapController = controller;
          if (_locationRepository.currentLocationCoordinates != null) {
            _mapController?.animateCamera(
              CameraUpdate.newLatLng(
                  _locationRepository.currentLocationCoordinates!),
            );
          }
        },
        mapType: MapType.terrain,
        markers: _locationRepository.markers,
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
      // Allow the screen to resize when keyboard appears
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
          });
        },
        child: LayoutBuilder(builder: (context, constraints) {
          // Get keyboard height
          final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
          final isKeyboardVisible = keyboardHeight > 0;

          return Stack(
            children: [
              // Main content in a scrollable container
              SingleChildScrollView(
                physics: isKeyboardVisible
                    ? const AlwaysScrollableScrollPhysics()
                    : const NeverScrollableScrollPhysics(),
                child: SizedBox(
                  height: constraints.maxHeight +
                      (isKeyboardVisible ? keyboardHeight : 0),
                  child: Column(
                    children: [
                      // Location input fields
                      _buildLocationInputs(),

                      // Spacer
                      const SpaceWidget(spaceHeight: 16),

                      // Map section - will get smaller when keyboard appears
                      Expanded(child: _buildMap()),
                    ],
                  ),
                ),
              ),

              // This will ensure predictions stay visible when keyboard is open
              if (_activeLocationType.isNotEmpty &&
                  _placePredictions.isNotEmpty)
                Positioned(
                  top: _activeLocationType == 'starting' ? 60 : 120,
                  left: 47, // Align with text fields
                  right: 16,
                  child: _buildPredictionsList(),
                ),
            ],
          );
        }),
      ),
    );
  }
}
