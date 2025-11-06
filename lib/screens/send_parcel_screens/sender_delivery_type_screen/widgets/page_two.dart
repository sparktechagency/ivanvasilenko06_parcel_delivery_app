import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:parcel_delivery_app/constants/app_colors.dart';
import 'package:parcel_delivery_app/constants/app_icons_path.dart';
import 'package:parcel_delivery_app/screens/send_parcel_screens/controller/sending_parcel_controller.dart';
import 'package:parcel_delivery_app/services/reporsitory/location_repository/location_repository.dart';
import 'package:parcel_delivery_app/services/location_permission_service.dart';
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
  bool _isDisposed = false; // Add disposal tracking

  // Add controller reference
  ParcelController? _parcelController;

  @override
  void initState() {
    super.initState();
    _isDisposed = false; // Initialize disposal state

    // Initialize controller safely
    try {
      _parcelController = Get.find<ParcelController>();
    } catch (e) {
      _parcelController = Get.put(ParcelController());
    }
    // Clear existing polylines and markers when initializing
    _clearPreviousRouteData();

    // Use existing location data from parcelController instead of fetching again
    _useExistingLocationData();

    debugPrint(
        '=======================================Current location: lat=${_parcelController?.currentLocationLatitude.value}, lng=${_parcelController?.currentLocationLongitude.value}');
    _startingFocusNode.addListener(() {
      if (_startingFocusNode.hasFocus && mounted && !_isDisposed) {
        setState(() {
          _activeLocationType = 'starting';
        });
      }
    });

    _endingFocusNode.addListener(() {
      if (_endingFocusNode.hasFocus && mounted && !_isDisposed) {
        setState(() {
          _activeLocationType = 'ending';
        });
      }
    });
  }

  @override
  void dispose() {
    _isDisposed = true; // Mark as disposed first

    // Dispose focus nodes first to prevent any callbacks
    _startingFocusNode.dispose();
    _endingFocusNode.dispose();

    // Dispose text controllers
    startingController.dispose();
    endingController.dispose();

    // Clear the polyline and location data when leaving the screen
    _clearPreviousRouteData();

    // Dispose map controller last and set to null
    // This is critical to prevent platform view conflicts
    if (_mapController != null) {
      _mapController!.dispose();
      _mapController = null;
    }

    super.dispose();
  }

  // New method to clear previous route data
  void _clearPreviousRouteData() {
    // Clear polylines in the repository
    _locationRepository.clearPolylines();

    // Clear stored coordinates
    _locationRepository.clearLocationCoordinates();

    // Clear markers only if widget is still mounted
    if (mounted && !_isDisposed) {
      setState(() {
        _markers = {};
      });
    } else {
      // If not mounted, just clear the markers without setState
      _markers = {};
    }
  }

  Future<void> _useExistingLocationData() async {
    if (_isDisposed) return;

    try {
      // Check if parcelController has location data
      if (_parcelController != null &&
          _parcelController!.currentLocationLatitude.value.isNotEmpty &&
          _parcelController!.currentLocationLongitude.value.isNotEmpty) {
        final lat =
            double.parse(_parcelController!.currentLocationLatitude.value);
        final lng =
            double.parse(_parcelController!.currentLocationLongitude.value);
        final location = LatLng(lat, lng);

        // Set the location in the repository
        _locationRepository.currentLocationCoordinates = location;

        // Create marker for current location
        _currentLocationMarker = Marker(
          markerId: const MarkerId('current_location'),
          position: location,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
          infoWindow: const InfoWindow(title: 'Current Location'),
        );

        if (mounted && !_isDisposed) {
          setState(() {
            _markers = {_currentLocationMarker!};
            _locationLoaded = true;
          });
        }

        // Get address for current location with timeout
        try {
          final address =
              await _locationRepository.getAddressFromLatLng(lat, lng).timeout(
            const Duration(seconds: 5),
            onTimeout: () {
              debugPrint('Address fetch timed out');
              return "Your Current Location";
            },
          );
          if (mounted && !_isDisposed) {
            setState(() {
              _currentLocationAddress = address;
            });
          }
        } catch (e) {
          debugPrint('Error getting address: $e');
          if (mounted && !_isDisposed) {
            setState(() {
              _currentLocationAddress = "Your Current Location";
            });
          }
        }

        // Move camera to current location
        if (_mapController != null && !_isDisposed) {
          try {
            _mapController?.animateCamera(
              CameraUpdate.newLatLng(location),
            );
          } catch (e) {
            debugPrint('Error animating camera: $e');
          }
        }
      } else {
        // Fallback to getting current location if parcelController doesn't have data
        debugPrint(
            'No location data in parcelController, falling back to getCurrentLocation');
        _getCurrentLocation();
      }
    } catch (e) {
      debugPrint('Error using existing location data: $e');
      // Fallback to getting current location
      _getCurrentLocation();
    }
  }

  Future<void> _getCurrentLocation() async {
    if (_isDisposed) return;

    try {
      // Use the uniform location permission service
      final locationService = LocationPermissionService.instance;
      final position = await locationService.getCurrentPosition(
        requestPermission: true,
      );
      if (_isDisposed) return;

      if (position != null && mounted && !_isDisposed) {
        final location = LatLng(position.latitude, position.longitude);

        // Create marker for current location
        _currentLocationMarker = Marker(
          markerId: const MarkerId('current_location'),
          position: location,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
          infoWindow: const InfoWindow(title: 'Current Location'),
        );

        if (mounted && !_isDisposed) {
          setState(() {
            _markers = {_currentLocationMarker!};
            _locationLoaded = true; // Mark location as loaded
          });
        }

        // Get address for current location with timeout
        try {
          final address = await _locationRepository
              .getAddressFromLatLng(position.latitude, position.longitude)
              .timeout(
            const Duration(seconds: 5),
            onTimeout: () {
              debugPrint('Address fetch timed out');
              return "Your Current Location";
            },
          );
          if (mounted && !_isDisposed) {
            setState(() {
              _currentLocationAddress = address;
            });
          }
        } catch (e) {
          debugPrint('Error getting address: $e');
          if (mounted && !_isDisposed) {
            setState(() {
              _currentLocationAddress = "Your Current Location";
            });
          }
        }

        // Move camera to current location
        if (_mapController != null && !_isDisposed) {
          try {
            _mapController?.animateCamera(
              CameraUpdate.newLatLng(location),
            );
          } catch (e) {
            debugPrint('Error animating camera: $e');
          }
        }
      } else {
        // Handle case where location is null (permission denied, etc.)
        if (mounted && !_isDisposed) {
          setState(() {
            _locationLoaded = true; 
          });
        }
      }
    } catch (e) {
      debugPrint('Error getting current location: $e');
      if (mounted && !_isDisposed) {
        setState(() {
          _locationLoaded = true;
        });
      }
    }
  }

  // Handle place autocomplete with disposal checks
  Future<void> _placeAutoComplete(String query) async {
    if (!mounted || _isDisposed) return;

    if (query.isEmpty) {
      if (mounted && !_isDisposed) {
        setState(() {
          _placePredictions = [];
        });
      }
      return;
    }

    if (mounted && !_isDisposed) {
      setState(() {
        _isLoading = true;
      });
    }

    try {
      final predictions =
          await _locationRepository.placeAutoComplete(query).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          debugPrint('Place autocomplete timed out');
          return [];
        },
      );
      if (_isDisposed) return;

      if (mounted && !_isDisposed) {
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
      if (mounted && !_isDisposed) {
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
    if (!mounted || _isDisposed) return;

    // Update UI immediately
    if (mounted && !_isDisposed) {
      setState(() {
        _placePredictions = [];
        startingController.text = description;
        _activeLocationType = '';
        _showCurrentLocationMarker = isCurrentLocation;
      });
    }

    // Update controller safely
    _parcelController?.setStartingLocation(description);

    if (isCurrentLocation) {
      // Use current location
      if (_locationRepository.currentLocationCoordinates != null &&
          !_isDisposed) {
        // Set starting location in repository - important for directions
        _locationRepository.startingLocationCoordinates =
            _locationRepository.currentLocationCoordinates;

        if (!_isDisposed && _mapController != null) {
          try {
            _mapController?.animateCamera(
              CameraUpdate.newLatLng(
                  _locationRepository.currentLocationCoordinates!),
            );
          } catch (e) {
            debugPrint('Error animating camera: $e');
          }
        }

        // Update markers
        if (mounted && !_isDisposed) {
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
              icon: BitmapDescriptor.defaultMarkerWithHue(
                  BitmapDescriptor.hueRed),
              infoWindow: const InfoWindow(title: 'Pickup Location'),
            );

            _markers.add(pickupMarker);
          });
        }

        // If we already have an ending location, fetch directions
        if (_locationRepository.endingLocationCoordinates != null &&
            !_isDisposed) {
          try {
            await _locationRepository.fetchDirections().timeout(
              const Duration(seconds: 10),
              onTimeout: () {
                debugPrint('Fetch directions timed out');
                return null;
              },
            );
            if (mounted && !_isDisposed) {
              setState(() {}); // Trigger rebuild to show polyline
            }
          } catch (e) {
            debugPrint('Error fetching directions: $e');
          }
        }
      }
    } else {
      try {
        // Fetch location details for selected place with timeout
        final location = await _locationRepository
            .fetchPlaceDetails(placeId, 'starting')
            .timeout(
          const Duration(seconds: 10),
          onTimeout: () {
            debugPrint('Fetch place details timed out');
            return null;
          },
        );

        if (_isDisposed) return;

        // Check if widget is still mounted before updating UI
        if (location != null && mounted && !_isDisposed) {
          // Move camera to the location
          if (!_isDisposed && _mapController != null) {
            try {
              _mapController?.animateCamera(
                CameraUpdate.newLatLng(location),
              );
            } catch (e) {
              debugPrint('Error animating camera: $e');
            }
          }

          // Update markers - hide current location marker
          if (mounted && !_isDisposed) {
            setState(() {
              // Start with empty set
              _markers = {};

              // Add repository markers (but not current location marker unless explicitly shown)
              _markers.addAll(_locationRepository.markers);
            });
          }

          // If we already have an ending location, fetch directions
          if (_locationRepository.endingLocationCoordinates != null &&
              !_isDisposed) {
            try {
              await _locationRepository.fetchDirections().timeout(
                const Duration(seconds: 10),
                onTimeout: () {
                  debugPrint('Fetch directions timed out');
                  return null;
                },
              );
              if (mounted && !_isDisposed) {
                setState(() {}); // Ensure UI updates to show polyline
              }
            } catch (e) {
              debugPrint('Error fetching directions: $e');
            }
          }
        }
      } catch (e) {
        debugPrint('Error fetching starting location details: $e');
      }
    }

    // Unfocus keyboard
    if (mounted && !_isDisposed) {
      FocusScope.of(context).unfocus();
    }
  }

  // Handle ending location selection with disposal checks
  void _onEndingLocationSelected(String placeId, String description) async {
    if (!mounted || _isDisposed) return;

    // Update UI immediately
    if (mounted && !_isDisposed) {
      setState(() {
        _placePredictions = [];
        endingController.text = description;
        _activeLocationType = '';
      });
    }

    // Update controller safely
    _parcelController?.setEndingLocation(description);

    try {
      final location = await _locationRepository
          .fetchPlaceDetails(placeId, 'ending')
          .timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          debugPrint('Fetch place details timed out');
          return null;
        },
      );

      if (_isDisposed) return;

      if (location != null && mounted && !_isDisposed) {
        // Move camera to the location
        if (!_isDisposed && _mapController != null) {
          try {
            _mapController?.animateCamera(
              CameraUpdate.newLatLng(location),
            );
          } catch (e) {
            debugPrint('Error animating camera: $e');
          }
        }

        // Update markers
        if (mounted && !_isDisposed) {
          setState(() {
            // Start with empty set
            _markers = {};
            if (_showCurrentLocationMarker && _currentLocationMarker != null) {
              _markers.add(_currentLocationMarker!);
            }
            _markers.addAll(_locationRepository.markers);
          });
        }

        if (_locationRepository.startingLocationCoordinates != null &&
            !_isDisposed) {
          try {
            await _locationRepository.fetchDirections().timeout(
              const Duration(seconds: 10),
              onTimeout: () {
                debugPrint('Fetch directions timed out');
                return null;
              },
            );
            if (mounted && !_isDisposed) {
              setState(() {});
            }
          } catch (e) {
            debugPrint('Error fetching directions: $e');
          }
        }
      }
    } catch (e) {
      debugPrint('Error fetching ending location details: $e');
    }

    if (mounted && !_isDisposed) {
      FocusScope.of(context).unfocus();
    }
  }

  Widget _buildPredictionsList() {
    if (_placePredictions.isEmpty || _isLoading || _isDisposed) {
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
                if (_isDisposed) return;

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
    if (_isDisposed) return const SizedBox.shrink();

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
                  if (mounted && !_isDisposed) {
                    setState(() {
                      _activeLocationType = 'starting';
                    });
                    _placeAutoComplete(query);
                  }
                },
                onTap: () {
                  if (mounted &&
                      !_isDisposed &&
                      _startingFocusNode.hasFocus &&
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
                  hintText: "pickupLocation".tr,
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
                  if (mounted && !_isDisposed) {
                    setState(() {
                      _activeLocationType = 'ending';
                    });
                    _placeAutoComplete(query);
                  }
                },
                style: const TextStyle(
                  color: AppColors.black,
                ),
                decoration: InputDecoration(
                  hintText: "destination".tr,
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

  // Build the map section with disposal checks
  Widget _buildMap() {
    if (_isDisposed) return const SizedBox.shrink();

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
                  if (mounted && !_isDisposed) {
                    setState(() {
                      _locationLoaded = false;
                    });
                    _useExistingLocationData();
                  }
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
    } else {
      return SizedBox(
        height: MediaQuery.of(context).size.height * 0.65,
        width: double.infinity,
        child: GoogleMap(
          key: ValueKey(
              'page_two_map_${DateTime.now().millisecondsSinceEpoch}'), // Use unique key with timestamp to prevent platform view conflicts
          initialCameraPosition: CameraPosition(
            target: _locationRepository.currentLocationCoordinates!,
            zoom: 15.0,
          ),
          onMapCreated: (GoogleMapController controller) {
            if (mounted && !_isDisposed && _mapController == null) {
              // Only set controller if it's not already set
              _mapController = controller;
              _mapInitialized = true;

              // Animate to current location immediately after map creation
              if (!_isDisposed) {
                try {
                  _mapController?.animateCamera(
                    CameraUpdate.newLatLng(
                        _locationRepository.currentLocationCoordinates!),
                  );
                } catch (e) {
                  debugPrint('Error animating camera on map creation: $e');
                }
              }
            }
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
  }

  @override
  Widget build(BuildContext context) {
    // Return empty container if disposed to prevent build errors
    if (_isDisposed) {
      return const SizedBox.shrink();
    }

    return WillPopScope(
      onWillPop: () async {
        // Ensure proper cleanup when navigating back
        _isDisposed = true;
        if (_mapController != null) {
          try {
            _mapController!.dispose();
          } catch (e) {
            debugPrint('Error disposing map controller: $e');
          }
          _mapController = null;
        }
        return true;
      },
      child: Scaffold(
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
            if (mounted && !_isDisposed) {
              FocusScope.of(context).unfocus();
              setState(() {
                _placePredictions = [];
                _activeLocationType = '';
              });
            }
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
                    _placePredictions.isNotEmpty &&
                    !_isDisposed)
                  Positioned(
                    top: _activeLocationType == 'starting' ? 60 : 120,
                    left: 47,
                    right: 16,
                    child: _buildPredictionsList(),
                  ),
                // Loading indicator
                if (_isLoading && !_isDisposed)
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
      ),
    );
  }
}
