import 'dart:convert';
import 'dart:developer';
import 'package:shared_preferences/shared_preferences.dart';

/// Model class for storing location data
class LocationData {
  final String parcelId;
  final String addressType; // 'pickup' or 'delivery'
  final double latitude;
  final double longitude;
  final String address;
  final DateTime timestamp;
  final bool isValid;

  LocationData({
    required this.parcelId,
    required this.addressType,
    required this.latitude,
    required this.longitude,
    required this.address,
    required this.timestamp,
    this.isValid = true,
  });

  /// Convert LocationData to JSON
  Map<String, dynamic> toJson() {
    return {
      'parcelId': parcelId,
      'addressType': addressType,
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'isValid': isValid,
    };
  }

  /// Create LocationData from JSON
  factory LocationData.fromJson(Map<String, dynamic> json) {
    return LocationData(
      parcelId: json['parcelId'] ?? '',
      addressType: json['addressType'] ?? '',
      latitude: (json['latitude'] ?? 0.0).toDouble(),
      longitude: (json['longitude'] ?? 0.0).toDouble(),
      address: json['address'] ?? '',
      timestamp: DateTime.fromMillisecondsSinceEpoch(json['timestamp'] ?? 0),
      isValid: json['isValid'] ?? true,
    );
  }

  /// Create cache key for this location
  String get cacheKey => '${parcelId}_$addressType';

  /// Check if coordinates are valid
  bool get hasValidCoordinates {
    return !latitude.isNaN &&
        !longitude.isNaN &&
        latitude.abs() <= 90 &&
        longitude.abs() <= 180;
  }

  /// Check if location data is expired (older than 24 hours)
  bool get isExpired {
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    return difference.inHours > 24;
  }
}

/// Comprehensive location storage service using SharedPreferences
class LocationStorage {
  static const String _locationDataKey = 'location_data_cache';
  static const String _coordinateToAddressKey = 'coordinate_to_address_cache';
  static const String _lastCleanupKey = 'last_cleanup_timestamp';
  
  static LocationStorage? _instance;
  SharedPreferences? _prefs;

  LocationStorage._internal();

  /// Singleton instance
  static LocationStorage get instance {
    _instance ??= LocationStorage._internal();
    return _instance!;
  }

  /// Initialize SharedPreferences
  Future<void> initialize() async {
    try {
      _prefs ??= await SharedPreferences.getInstance();
      await _performPeriodicCleanup();
    } catch (e) {
      log('LocationStorage: Failed to initialize SharedPreferences: $e');
    }
  }

  /// Ensure SharedPreferences is initialized
  Future<SharedPreferences> get _preferences async {
    if (_prefs == null) {
      await initialize();
    }
    return _prefs!;
  }

  /// Store location data for a specific parcel
  Future<bool> storeLocationData(LocationData locationData) async {
    try {
      if (!locationData.hasValidCoordinates) {
        log('LocationStorage: Invalid coordinates for ${locationData.cacheKey}');
        return false;
      }

      final prefs = await _preferences;
      final existingDataJson = prefs.getString(_locationDataKey) ?? '{}';
      final Map<String, dynamic> existingData = json.decode(existingDataJson);

      // Store the location data
      existingData[locationData.cacheKey] = locationData.toJson();

      // Also store coordinate-to-address mapping for reuse
      final coordKey = '${locationData.latitude.toStringAsFixed(6)},${locationData.longitude.toStringAsFixed(6)}';
      final coordDataJson = prefs.getString(_coordinateToAddressKey) ?? '{}';
      final Map<String, dynamic> coordData = json.decode(coordDataJson);
      coordData[coordKey] = {
        'address': locationData.address,
        'timestamp': locationData.timestamp.millisecondsSinceEpoch,
      };

      // Save both mappings
      final success1 = await prefs.setString(_locationDataKey, json.encode(existingData));
      final success2 = await prefs.setString(_coordinateToAddressKey, json.encode(coordData));

      log('LocationStorage: Stored location data for ${locationData.cacheKey}');
      return success1 && success2;
    } catch (e) {
      log('LocationStorage: Failed to store location data: $e');
      return false;
    }
  }

  /// Retrieve location data for a specific parcel and address type
  Future<LocationData?> getLocationData(String parcelId, String addressType) async {
    try {
      final prefs = await _preferences;
      final dataJson = prefs.getString(_locationDataKey) ?? '{}';
      final Map<String, dynamic> data = json.decode(dataJson);

      final cacheKey = '${parcelId}_$addressType';
      final locationJson = data[cacheKey];

      if (locationJson != null) {
        final locationData = LocationData.fromJson(locationJson);
        
        // Check if data is still valid and not expired
        if (locationData.isValid && !locationData.isExpired && locationData.hasValidCoordinates) {
          return locationData;
        } else {
          // Remove expired or invalid data
          await _removeLocationData(cacheKey);
        }
      }

      return null;
    } catch (e) {
      log('LocationStorage: Failed to retrieve location data for ${parcelId}_$addressType: $e');
      return null;
    }
  }

  /// Get address from coordinates (check coordinate cache first)
  Future<String?> getAddressFromCoordinates(double latitude, double longitude) async {
    try {
      if (latitude.isNaN || longitude.isNaN || latitude.abs() > 90 || longitude.abs() > 180) {
        return null;
      }

      final prefs = await _preferences;
      final coordKey = '${latitude.toStringAsFixed(6)},${longitude.toStringAsFixed(6)}';
      final coordDataJson = prefs.getString(_coordinateToAddressKey) ?? '{}';
      final Map<String, dynamic> coordData = json.decode(coordDataJson);

      final cachedData = coordData[coordKey];
      if (cachedData != null) {
        final timestamp = DateTime.fromMillisecondsSinceEpoch(cachedData['timestamp'] ?? 0);
        final now = DateTime.now();
        
        // Check if cached address is not older than 24 hours
        if (now.difference(timestamp).inHours <= 24) {
          return cachedData['address'];
        } else {
          // Remove expired coordinate cache
          coordData.remove(coordKey);
          await prefs.setString(_coordinateToAddressKey, json.encode(coordData));
        }
      }

      return null;
    } catch (e) {
      log('LocationStorage: Failed to get address from coordinates: $e');
      return null;
    }
  }

  /// Save coordinate-to-address mapping directly
  Future<bool> saveCoordinateAddress(double latitude, double longitude, String address) async {
    try {
      if (latitude.isNaN || longitude.isNaN || latitude.abs() > 90 || longitude.abs() > 180) {
        return false;
      }

      final prefs = await _preferences;
      final coordKey = '${latitude.toStringAsFixed(6)},${longitude.toStringAsFixed(6)}';
      final coordDataJson = prefs.getString(_coordinateToAddressKey) ?? '{}';
      final Map<String, dynamic> coordData = json.decode(coordDataJson);
      
      coordData[coordKey] = {
        'address': address,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      };

      final success = await prefs.setString(_coordinateToAddressKey, json.encode(coordData));
      log('LocationStorage: Saved coordinate address mapping for $coordKey');
      return success;
    } catch (e) {
      log('LocationStorage: Failed to save coordinate address: $e');
      return false;
    }
  }

  /// Store multiple location data entries at once
  Future<bool> storeMultipleLocationData(List<LocationData> locationDataList) async {
    try {
      final prefs = await _preferences;
      final existingDataJson = prefs.getString(_locationDataKey) ?? '{}';
      final existingCoordJson = prefs.getString(_coordinateToAddressKey) ?? '{}';
      
      final Map<String, dynamic> existingData = json.decode(existingDataJson);
      final Map<String, dynamic> coordData = json.decode(existingCoordJson);

      for (final locationData in locationDataList) {
        if (locationData.hasValidCoordinates) {
          existingData[locationData.cacheKey] = locationData.toJson();
          
          // Also update coordinate cache
          final coordKey = '${locationData.latitude.toStringAsFixed(6)},${locationData.longitude.toStringAsFixed(6)}';
          coordData[coordKey] = {
            'address': locationData.address,
            'timestamp': locationData.timestamp.millisecondsSinceEpoch,
          };
        }
      }

      final success1 = await prefs.setString(_locationDataKey, json.encode(existingData));
      final success2 = await prefs.setString(_coordinateToAddressKey, json.encode(coordData));

      log('LocationStorage: Stored ${locationDataList.length} location data entries');
      return success1 && success2;
    } catch (e) {
      log('LocationStorage: Failed to store multiple location data: $e');
      return false;
    }
  }

  /// Get all location data for a specific parcel
  Future<Map<String, LocationData>> getAllLocationDataForParcel(String parcelId) async {
    try {
      final prefs = await _preferences;
      final dataJson = prefs.getString(_locationDataKey) ?? '{}';
      final Map<String, dynamic> data = json.decode(dataJson);

      final Map<String, LocationData> parcelLocations = {};

      for (final entry in data.entries) {
        if (entry.key.startsWith('${parcelId}_')) {
          try {
            final locationData = LocationData.fromJson(entry.value);
            if (locationData.isValid && !locationData.isExpired && locationData.hasValidCoordinates) {
              parcelLocations[locationData.addressType] = locationData;
            }
          } catch (e) {
            log('LocationStorage: Failed to parse location data for ${entry.key}: $e');
          }
        }
      }

      return parcelLocations;
    } catch (e) {
      log('LocationStorage: Failed to get all location data for parcel $parcelId: $e');
      return {};
    }
  }

  /// Enhanced method to preload addresses for multiple parcels efficiently
  Future<Map<String, String>> preloadParcelAddresses(List<dynamic> parcels) async {
    final Map<String, String> addressResults = {};
    final List<LocationData> newLocationData = [];
    
    try {
      final prefs = await _preferences;
      final existingDataJson = prefs.getString(_locationDataKey) ?? '{}';
      final Map<String, dynamic> existingData = json.decode(existingDataJson);
      
      // First, check what we already have cached
      for (var parcel in parcels) {
        final parcelId = parcel.id ?? "";
        
        // Check delivery location
        final deliveryLocation = parcel.deliveryLocation?.coordinates;
        if (deliveryLocation != null && deliveryLocation.length == 2) {
          final deliveryCacheKey = '${parcelId}_delivery';
          if (existingData.containsKey(deliveryCacheKey)) {
            try {
              final locationData = LocationData.fromJson(existingData[deliveryCacheKey]);
              if (locationData.isValid && !locationData.isExpired && locationData.hasValidCoordinates) {
                addressResults[deliveryCacheKey] = locationData.address;
              }
            } catch (e) {
              log('LocationStorage: Failed to parse cached delivery data for $parcelId: $e');
            }
          }
        }
        
        // Check pickup location
        final pickupLocation = parcel.pickupLocation?.coordinates;
        if (pickupLocation != null && pickupLocation.length == 2) {
          final pickupCacheKey = '${parcelId}_pickup';
          if (existingData.containsKey(pickupCacheKey)) {
            try {
              final locationData = LocationData.fromJson(existingData[pickupCacheKey]);
              if (locationData.isValid && !locationData.isExpired && locationData.hasValidCoordinates) {
                addressResults[pickupCacheKey] = locationData.address;
              }
            } catch (e) {
              log('LocationStorage: Failed to parse cached pickup data for $parcelId: $e');
            }
          }
        }
      }
      
      log('LocationStorage: Preloaded ${addressResults.length} cached addresses');
      return addressResults;
    } catch (e) {
      log('LocationStorage: Failed to preload parcel addresses: $e');
      return {};
    }
  }

  /// Enhanced method to get cached addresses with fallback loading states
  Future<Map<String, String>> getCachedAddressesWithFallback(List<dynamic> parcels) async {
    final Map<String, String> results = {};
    
    try {
      final cachedAddresses = await preloadParcelAddresses(parcels);
      
      for (var parcel in parcels) {
        final parcelId = parcel.id ?? "";
        
        // Set delivery address or loading state
        final deliveryCacheKey = '${parcelId}_delivery';
        results[deliveryCacheKey] = cachedAddresses[deliveryCacheKey] ?? 'Loading...';
        
        // Set pickup address or loading state
        final pickupCacheKey = '${parcelId}_pickup';
        results[pickupCacheKey] = cachedAddresses[pickupCacheKey] ?? 'Loading...';
      }
      
      return results;
    } catch (e) {
      log('LocationStorage: Failed to get cached addresses with fallback: $e');
      return {};
    }
  }

      /// Remove location data for a specific parcel and address type
  Future<bool> _removeLocationData(String cacheKey) async {
    try {
      final prefs = await _preferences;
      final dataJson = prefs.getString(_locationDataKey) ?? '{}';
      final Map<String, dynamic> data = json.decode(dataJson);

      data.remove(cacheKey);
      final success = await prefs.setString(_locationDataKey, json.encode(data));
      
      log('LocationStorage: Removed location data for $cacheKey');
      return success;
    } catch (e) {
      log('LocationStorage: Failed to remove location data for $cacheKey: $e');
      return false;
    }
  }

  /// Remove all location data for a specific parcel
  Future<bool> removeParcelLocationData(String parcelId) async {
    try {
      final prefs = await _preferences;
      final dataJson = prefs.getString(_locationDataKey) ?? '{}';
      final Map<String, dynamic> data = json.decode(dataJson);

      // Remove all entries that start with the parcel ID
      final keysToRemove = data.keys.where((key) => key.startsWith('${parcelId}_')).toList();
      
      for (final key in keysToRemove) {
        data.remove(key);
      }

      final success = await prefs.setString(_locationDataKey, json.encode(data));
      log('LocationStorage: Removed all location data for parcel $parcelId');
      return success;
    } catch (e) {
      log('LocationStorage: Failed to remove parcel location data for $parcelId: $e');
      return false;
    }
  }

  /// Clear all location data
  Future<bool> clearAllLocationData() async {
    try {
      final prefs = await _preferences;
      final success1 = await prefs.remove(_locationDataKey);
      final success2 = await prefs.remove(_coordinateToAddressKey);
      
      log('LocationStorage: Cleared all location data');
      return success1 && success2;
    } catch (e) {
      log('LocationStorage: Failed to clear all location data: $e');
      return false;
    }
  }

  /// Get storage statistics
  Future<Map<String, int>> getStorageStats() async {
    try {
      final prefs = await _preferences;
      final dataJson = prefs.getString(_locationDataKey) ?? '{}';
      final coordJson = prefs.getString(_coordinateToAddressKey) ?? '{}';
      
      final Map<String, dynamic> data = json.decode(dataJson);
      final Map<String, dynamic> coordData = json.decode(coordJson);

      int validEntries = 0;
      int expiredEntries = 0;
      int invalidEntries = 0;

      for (final entry in data.values) {
        try {
          final locationData = LocationData.fromJson(entry);
          if (!locationData.hasValidCoordinates || !locationData.isValid) {
            invalidEntries++;
          } else if (locationData.isExpired) {
            expiredEntries++;
          } else {
            validEntries++;
          }
        } catch (e) {
          invalidEntries++;
        }
      }

      return {
        'totalEntries': data.length,
        'validEntries': validEntries,
        'expiredEntries': expiredEntries,
        'invalidEntries': invalidEntries,
        'coordinateCache': coordData.length,
      };
    } catch (e) {
      log('LocationStorage: Failed to get storage stats: $e');
      return {};
    }
  }

  /// Perform periodic cleanup of expired and invalid data
  Future<void> _performPeriodicCleanup() async {
    try {
      final prefs = await _preferences;
      final lastCleanup = prefs.getInt(_lastCleanupKey) ?? 0;
      final now = DateTime.now().millisecondsSinceEpoch;
      
      // Perform cleanup once every 6 hours
      if (now - lastCleanup < 6 * 60 * 60 * 1000) {
        return;
      }

      await cleanupExpiredData();
      await prefs.setInt(_lastCleanupKey, now);
    } catch (e) {
      log('LocationStorage: Failed to perform periodic cleanup: $e');
    }
  }

  /// Clean up expired and invalid location data
  Future<bool> cleanupExpiredData() async {
    try {
      final prefs = await _preferences;
      final dataJson = prefs.getString(_locationDataKey) ?? '{}';
      final coordJson = prefs.getString(_coordinateToAddressKey) ?? '{}';
      
      final Map<String, dynamic> data = json.decode(dataJson);
      final Map<String, dynamic> coordData = json.decode(coordJson);

      int removedCount = 0;
      int coordRemovedCount = 0;

      // Clean location data
      final keysToRemove = <String>[];
      for (final entry in data.entries) {
        try {
          final locationData = LocationData.fromJson(entry.value);
          if (!locationData.hasValidCoordinates || !locationData.isValid || locationData.isExpired) {
            keysToRemove.add(entry.key);
          }
        } catch (e) {
          keysToRemove.add(entry.key);
        }
      }

      for (final key in keysToRemove) {
        data.remove(key);
        removedCount++;
      }

      // Clean coordinate cache
      final coordKeysToRemove = <String>[];
      for (final entry in coordData.entries) {
        try {
          final timestamp = DateTime.fromMillisecondsSinceEpoch(entry.value['timestamp'] ?? 0);
          if (DateTime.now().difference(timestamp).inHours > 24) {
            coordKeysToRemove.add(entry.key);
          }
        } catch (e) {
          coordKeysToRemove.add(entry.key);
        }
      }

      for (final key in coordKeysToRemove) {
        coordData.remove(key);
        coordRemovedCount++;
      }

      final success1 = await prefs.setString(_locationDataKey, json.encode(data));
      final success2 = await prefs.setString(_coordinateToAddressKey, json.encode(coordData));

      log('LocationStorage: Cleanup completed - removed $removedCount location entries and $coordRemovedCount coordinate entries');
      return success1 && success2;
    } catch (e) {
      log('LocationStorage: Failed to cleanup expired data: $e');
      return false;
    }
  }

  /// Check if location storage is healthy
  Future<bool> isStorageHealthy() async {
    try {
      final prefs = await _preferences;
      
      // Try to read and parse the data
      final dataJson = prefs.getString(_locationDataKey) ?? '{}';
      final coordJson = prefs.getString(_coordinateToAddressKey) ?? '{}';
      
      json.decode(dataJson);
      json.decode(coordJson);
      
      return true;
    } catch (e) {
      log('LocationStorage: Storage health check failed: $e');
      return false;
    }
  }

  /// Repair corrupted storage
  Future<bool> repairStorage() async {
    try {
      final prefs = await _preferences;
      
      // Try to repair location data
      try {
        final dataJson = prefs.getString(_locationDataKey) ?? '{}';
        json.decode(dataJson);
      } catch (e) {
        log('LocationStorage: Repairing corrupted location data');
        await prefs.setString(_locationDataKey, '{}');
      }

      // Try to repair coordinate data
      try {
        final coordJson = prefs.getString(_coordinateToAddressKey) ?? '{}';
        json.decode(coordJson);
      } catch (e) {
        log('LocationStorage: Repairing corrupted coordinate data');
        await prefs.setString(_coordinateToAddressKey, '{}');
      }

      log('LocationStorage: Storage repair completed');
      return true;
    } catch (e) {
      log('LocationStorage: Failed to repair storage: $e');
      return false;
    }
  }
}