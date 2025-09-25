import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';

/// A service to handle location permissions uniformly across Android and iOS
class LocationPermissionService {
  static LocationPermissionService? _instance;

  LocationPermissionService._internal();

  static LocationPermissionService get instance {
    _instance ??= LocationPermissionService._internal();
    return _instance!;
  }

  /// Check if location services are enabled
  Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  /// Check current location permission status
  Future<LocationPermission> checkPermission() async {
    return await Geolocator.checkPermission();
  }

  /// Request location permission with proper handling for both platforms
  Future<LocationPermission> requestPermission() async {
    return await Geolocator.requestPermission();
  }

  /// Comprehensive method to ensure location permission is granted
  /// Returns true if permission is granted, false otherwise
  Future<bool> ensureLocationPermission({
    bool showDialog = true,
    String? customMessage,
  }) async {
    try {
      // Check if location services are enabled
      bool serviceEnabled = await isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (showDialog) {
          _showLocationServiceDialog();
        }
        return false;
      }

      // Check current permission status
      LocationPermission permission = await checkPermission();

      // Handle denied permission
      if (permission == LocationPermission.denied) {
        permission = await requestPermission();

        // If still denied after request
        if (permission == LocationPermission.denied) {
          if (showDialog) {
            _showPermissionDeniedDialog(customMessage);
          }
          return false;
        }
      }

      // Handle permanently denied permission
      if (permission == LocationPermission.deniedForever) {
        if (showDialog) {
          _showPermissionPermanentlyDeniedDialog();
        }
        return false;
      }

      // Permission granted (whileInUse or always)
      return permission == LocationPermission.whileInUse ||
          permission == LocationPermission.always;
    } catch (e) {
      if (showDialog) {
        _showErrorDialog(e.toString());
      }
      return false;
    }
  }

  /// Get current position with permission check
  Future<Position?> getCurrentPosition({
    LocationAccuracy accuracy = LocationAccuracy.high,
    bool requestPermission = true,
  }) async {
    try {
      if (requestPermission) {
        bool hasPermission = await ensureLocationPermission();
        if (!hasPermission) {
          return null;
        }
      }

      return await Geolocator.getCurrentPosition(
        desiredAccuracy: accuracy,
      );
    } catch (e) {
      return null;
    }
  }

  /// Show dialog when location services are disabled
  void _showLocationServiceDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('Location Services Disabled'),
        content: const Text(
          'Location services are disabled. Please enable location services in your device settings to continue.',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              Geolocator.openLocationSettings();
            },
            child: const Text('Settings'),
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }

  /// Show dialog when permission is denied
  void _showPermissionDeniedDialog(String? customMessage) {
    Get.dialog(
      AlertDialog(
        title: const Text('Location Permission Required'),
        content: Text(
          customMessage ??
              'This app needs location permission to provide location-based services. Please grant location permission to continue.',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Get.back();
              await requestPermission();
            },
            child: const Text('Retry'),
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }

  /// Show dialog when permission is permanently denied
  void _showPermissionPermanentlyDeniedDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('Location Permission Permanently Denied'),
        content: const Text(
          'Location permission has been permanently denied. Please enable it manually in app settings to use location features.',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              Geolocator.openAppSettings();
            },
            child: const Text('App Settings'),
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }

  /// Show error dialog
  void _showErrorDialog(String error) {
    Get.dialog(
      AlertDialog(
        title: const Text('Location Error'),
        content: Text('An error occurred while accessing location: $error'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
