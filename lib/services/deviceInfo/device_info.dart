import 'dart:developer';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';

class DeviceInfo {
  // Cached values
  String? _cachedDeviceId;
  String? _cachedDeviceType;

  // Method to get device info as a map
  Future<Map<String, dynamic>> getDeviceInfo() async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    Map<String, dynamic> deviceData = <String, dynamic>{};

    try {
      if (Platform.isAndroid) {
        // Android devices
        AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
        deviceData = {
          'deviceId': androidInfo.id,
          'deviceType': 'android',
          'brand': androidInfo.brand,
          'model': androidInfo.model,
          'manufacturer': androidInfo.manufacturer,
          'androidVersion': androidInfo.version.release,
          'sdkInt': androidInfo.version.sdkInt,
        };

        // Cache the values
        _cachedDeviceId = androidInfo.id;
        _cachedDeviceType = 'android';
      } else if (Platform.isIOS) {
        // iOS devices
        IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
        deviceData = {
          'deviceId': iosInfo.identifierForVendor,
          'deviceType': 'ios',
          'name': iosInfo.name,
          'model': iosInfo.model,
          'systemName': iosInfo.systemName,
          'systemVersion': iosInfo.systemVersion,
          'isPhysicalDevice': iosInfo.isPhysicalDevice,
        };

        // Cache the values
        _cachedDeviceId = iosInfo.identifierForVendor;
        _cachedDeviceType = 'ios';
      }
    } catch (e) {
      log('Failed to get device info: $e');
    }

    return deviceData;
  }

  // Method to get device ID as a string
  Future<String> getDeviceId() async {
    // Return cached value if available
    if (_cachedDeviceId != null) {
      return _cachedDeviceId!;
    }

    // Otherwise, get device info and return the ID
    final deviceData = await getDeviceInfo();
    return deviceData['deviceId'] as String? ?? 'unknown';
  }

  Future<String> getDeviceType() async {
    // Return cached value if available
    if (_cachedDeviceType != null) {
      return _cachedDeviceType!;
    }

    // Otherwise, get device info and return the type
    final deviceData = await getDeviceInfo();
    return deviceData['deviceType'] as String? ?? 'unknown';
  }
}
