import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:parcel_delivery_app/constants/app_colors.dart';
import 'package:parcel_delivery_app/constants/app_icons_path.dart';
import 'package:parcel_delivery_app/screens/send_parcel_screens/controller/sending_parcel_controller.dart';
import 'package:parcel_delivery_app/services/reporsitory/location_repository/location_repository.dart';
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

  String _activeLocationType = '';
  List<dynamic> _placePredictions = [];
  bool _isLoading = false;
  GoogleMapController? _mapController;
  final LocationRepository _locationRepository = LocationRepository();
  final FocusNode _startingFocusNode = FocusNode();
  final FocusNode _endingFocusNode = FocusNode();
  Set<Marker> _markers = {};
  // ignore: unused_field
  bool _mapInitialized = false;
  Marker? _currentLocationMarker;
  String? _currentLocationAddress;
  bool _showCurrentLocationMarker = false;
  bool _locationLoaded = false;

  @override
  void initState() {
    super.initState();
    // Clear existing polylines and markers when initializing
    _clearPreviousRouteData();
    _getCurrentLocation();
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
    // Clear the polyline and location data when leaving the screen
    _clearPreviousRouteData();

    startingController.dispose();
    endingController.dispose();
    _mapController?.dispose();
    _startingFocusNode.dispose();
    _endingFocusNode.dispose();
    super.dispose();
  }

  // New method to clear previous route data
  void _clearPreviousRouteData() {
    // Clear polylines in the repository
    _locationRepository.clearPolylines();

    // Clear stored coordinates
    _locationRepository.clearLocationCoordinates();

    // Clear markers
    setState(() {
      _markers = {};
    });
  }

  Future<void> _getCurrentLocation() async {
    try {
      final location = await _locationRepository.getCurrentLocation();
      if (location != null && mounted) {
        // Create marker for current location
        _currentLocationMarker = Marker(
          markerId: const MarkerId('current_location'),
          position: location,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
          infoWindow: const InfoWindow(title: 'Current Location'),
        );

        setState(() {
          _markers = {..._locationRepository.markers};
          _locationLoaded = true; // Mark location as loaded
        });

        // Get address for current location
        try {
          final address = await _locationRepository.getAddressFromLatLng(
              location.latitude, location.longitude);
          if (mounted) {
            setState(() {
              _currentLocationAddress = address;
            });
          }
        } catch (e) {
          debugPrint('Error getting address: $e');
          if (mounted) {
            setState(() {
              _currentLocationAddress = "Your Current Location";
            });
          }
        }

        // Move camera to current location
        if (_mapController != null) {
          _mapController?.animateCamera(
            CameraUpdate.newLatLng(location),
          );
        }
      } else {
        // Handle case where location is null (permission denied, etc.)
        if (mounted) {
          setState(() {
            _locationLoaded = true; // Still mark as loaded to show error state
          });
        }
      }
    } catch (e) {
      debugPrint('Error getting current location: $e');
      if (mounted) {
        setState(() {
          _locationLoaded = true; // Mark as loaded to show error state
        });
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
          // Add current location as first suggestion if searching for starting location
          if (_activeLocationType == 'starting' &&
              _currentLocationAddress != null) {
            _placePredictions = [
              {
                'place_id': 'current_location',
                'description':
                    _currentLocationAddress ?? 'Your Current Location',
                'is_current_location': true,
              },
              ...predictions
            ];
          } else {
            _placePredictions = predictions;
          }
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          // Even on error, add current location option for starting location
          if (_activeLocationType == 'starting' &&
              _currentLocationAddress != null) {
            _placePredictions = [
              {
                'place_id': 'current_location',
                'description':
                    _currentLocationAddress ?? 'Your Current Location',
                'is_current_location': true,
              }
            ];
          } else {
            _placePredictions = [];
          }
          _isLoading = false;
        });
      }
      debugPrint('Error: $e');
    }
  }

  void _onStartingLocationSelected(String placeId, String description,
      {bool isCurrentLocation = false}) async {
    // Update UI immediately
    setState(() {
      _placePredictions = [];
      startingController.text = description;
      _activeLocationType = '';
      _showCurrentLocationMarker = isCurrentLocation;
    });

    // Update controller
    Get.find<ParcelController>().setStartingLocation(description);

    if (isCurrentLocation) {
      // Use current location
      if (_locationRepository.currentLocationCoordinates != null) {
        // Set starting location in repository - important for directions
        _locationRepository.startingLocationCoordinates =
            _locationRepository.currentLocationCoordinates;

        _mapController?.animateCamera(
          CameraUpdate.newLatLng(
              _locationRepository.currentLocationCoordinates!),
        );

        // Update markers
        setState(() {
          _markers = {};

          // Add current location marker when using current location as pickup
          if (_currentLocationMarker != null && _showCurrentLocationMarker) {
            _markers.add(_currentLocationMarker!);
          }

          // Add pickup marker at same location
          final pickupMarker = Marker(
            markerId: const MarkerId('starting_location'),
            position: _locationRepository.currentLocationCoordinates!,
            icon:
                BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
            infoWindow: const InfoWindow(title: 'Pickup Location'),
          );

          _markers.add(pickupMarker);
        });

        // If we already have an ending location, fetch directions
        if (_locationRepository.endingLocationCoordinates != null) {
          await _locationRepository.fetchDirections();
          setState(() {}); // Trigger rebuild to show polyline
        }
      }
    } else {
      try {
        // Fetch location details for selected place
        final location =
            await _locationRepository.fetchPlaceDetails(placeId, 'starting');

        // Check if widget is still mounted before updating UI
        if (location != null && mounted) {
          // Move camera to the location
          _mapController?.animateCamera(
            CameraUpdate.newLatLng(location),
          );

          // Update markers - hide current location marker
          setState(() {
            // Start with empty set
            _markers = {};

            // Add repository markers (but not current location marker unless explicitly shown)
            _markers.addAll(_locationRepository.markers);
          });

          // If we already have an ending location, fetch directions
          if (_locationRepository.endingLocationCoordinates != null) {
            await _locationRepository.fetchDirections();
            setState(() {}); // Ensure UI updates to show polyline
          }
        }
      } catch (e) {
        debugPrint('Error fetching starting location details: $e');
      }
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
      final location =
          await _locationRepository.fetchPlaceDetails(placeId, 'ending');

      if (location != null && mounted) {
        // Move camera to the location
        _mapController?.animateCamera(
          CameraUpdate.newLatLng(location),
        );

        // Update markers
        setState(() {
          // Start with empty set
          _markers = {};
          if (_showCurrentLocationMarker && _currentLocationMarker != null) {
            _markers.add(_currentLocationMarker!);
          }
          _markers.addAll(_locationRepository.markers);
        });

        if (_locationRepository.startingLocationCoordinates != null) {
          await _locationRepository.fetchDirections();
          setState(() {});
        }
      }
    } catch (e) {
      debugPrint('Error fetching ending location details: $e');
    }

    FocusScope.of(context).unfocus();
  }

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
            final bool isCurrentLocation =
                prediction['is_current_location'] == true;

            return ListTile(
              dense: true,
              visualDensity: const VisualDensity(vertical: -2),
              leading: Icon(
                  isCurrentLocation ? Icons.my_location : Icons.location_on,
                  color: isCurrentLocation
                      ? AppColors.black
                      : AppColors.greyDarkLight2,
                  size: 18),
              title: Text(
                prediction['description'],
                style: TextStyle(
                  fontSize: 14,
                  fontWeight:
                      isCurrentLocation ? FontWeight.w500 : FontWeight.normal,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              onTap: () {
                final placeId = prediction['place_id'];
                final description = prediction['description'];

                if (_activeLocationType == 'starting') {
                  _onStartingLocationSelected(placeId, description,
                      isCurrentLocation: isCurrentLocation);
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
                onTap: () {
                  if (_startingFocusNode.hasFocus &&
                      _activeLocationType == 'starting') {
                    // Show current location option immediately when tapping on starting field
                    if (_currentLocationAddress != null) {
                      setState(() {
                        _placePredictions = [
                          {
                            'place_id': 'current_location',
                            'description': _currentLocationAddress ??
                                'Your Current Location',
                            'is_current_location': true,
                          }
                        ];
                      });
                    }
                  }
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
    // Show loading indicator until location is loaded
    if (!_locationLoaded) {
      return SizedBox(
        height: MediaQuery.of(context).size.height * 0.65,
        width: double.infinity,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              LoadingAnimationWidget.hexagonDots(
                color: AppColors.black,
                size: 40,
              ),
              const SizedBox(height: 16),
              const TextWidget(
                text: "Getting your location...",
                fontSize: 16,
                fontWeight: FontWeight.w500,
                fontColor: AppColors.greyDark2,
              ),
            ],
          ),
        ),
      );
    }

    // Show error state if location is not available
    if (_locationRepository.currentLocationCoordinates == null) {
      return SizedBox(
        height: MediaQuery.of(context).size.height * 0.65,
        width: double.infinity,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.location_off,
                size: 60,
                color: AppColors.greyDark2,
              ),
              const SizedBox(height: 16),
              const TextWidget(
                text: "Location not available",
                fontSize: 18,
                fontWeight: FontWeight.w600,
                fontColor: AppColors.black,
              ),
              const SizedBox(height: 8),
              const TextWidget(
                text: "Please enable location services and try again",
                fontSize: 14,
                fontWeight: FontWeight.w400,
                fontColor: AppColors.greyDark2,
                textAlignment: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _locationLoaded = false;
                  });
                  _getCurrentLocation();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.black,
                  foregroundColor: AppColors.white,
                ),
                child: const Text("Retry"),
              ),
            ],
          ),
        ),
      );
    }

    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.65,
      width: double.infinity,
      child: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: _locationRepository.currentLocationCoordinates!,
          zoom: 15.0, // Increased zoom for better view
        ),
        onMapCreated: (GoogleMapController controller) {
          setState(() {
            _mapController = controller;
            _mapInitialized = true;
          });

          // Animate to current location immediately after map creation
          _mapController?.animateCamera(
            CameraUpdate.newLatLng(
                _locationRepository.currentLocationCoordinates!),
          );
        },
        mapType: MapType.terrain,
        markers: _markers,
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
          //! Close keyboard when tapping outside of text fields
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
              // Position predictions list properly
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
                    child: Center(
                      child: LoadingAnimationWidget.hexagonDots(
                        color: AppColors.black,
                        size: 40,
                      ),
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
