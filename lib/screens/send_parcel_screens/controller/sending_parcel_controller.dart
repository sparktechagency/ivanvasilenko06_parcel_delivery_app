import 'dart:convert';
import 'dart:io';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:parcel_delivery_app/constants/api_url.dart';
import 'package:parcel_delivery_app/routes/app_routes.dart';
import 'package:parcel_delivery_app/services/appStroage/share_helper.dart';
import 'package:parcel_delivery_app/services/reporsitory/image_repository/image_repository.dart';

class ParcelController extends GetxController {
  // Add disposal tracking
  bool _isDisposed = false;
  
  // Observable data
  RxString startingLocation = ''.obs;
  RxString endingLocation = ''.obs;
  RxString selectedDeliveryType = 'non-professional'.obs;
  RxString selectedVehicleType = ''.obs;
  RxString description = ''.obs;
  RxString price = ''.obs;
  RxString receiverName = ''.obs;
  RxString receiverNumber = ''.obs;
  Rx<DateTime> selectedDate = DateTime.now().obs;
  Rx<DateTime> selectedTime = DateTime.now().obs;
  Rx<DateTime> startDateTime = DateTime.now().obs;
  Rx<DateTime> endDateTime = DateTime.now().obs;
  RxList<String> selectedImages = <String>[].obs;
  RxBool isLoading = false.obs;

  //! For storing current location lat/lng as strings
  RxString currentLocationLatitude = ''.obs;
  RxString currentLocationLongitude = ''.obs;

  //! Location ID fields
  final RxString startingLocationId = ''.obs;
  final RxString endingLocationId = ''.obs;

  //! Location methods
  void setStartingLocationId(String id) {
    if (_isDisposed) return;
    startingLocationId.value = id;
  }

  void setEndingLocationId(String id) {
    if (_isDisposed) return;
    endingLocationId.value = id;
  }

  void setCurrentLocationCoordinates(String latitude, String longitude) {
    if (_isDisposed) return;
    currentLocationLatitude.value = latitude;
    currentLocationLongitude.value = longitude;
  }

  final RxString completePhoneNumber = ''.obs;

  void updatePhoneNumber(String phoneNumber) {
    if (_isDisposed) return;
    completePhoneNumber.value = phoneNumber;
  }

  //! Controllers
  final currentLocationController = TextEditingController();
  final destinationController = TextEditingController();
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final priceController = TextEditingController();
  final nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  //! Navigation
  PageController pageController = PageController();
  PageController tabController = PageController();
  CarouselSliderController carouselController = CarouselSliderController();
  RxInt currentStep = 0.obs;

  final ImagePicker _picker = ImagePicker();

  //! Setters with disposal checks
  void setStartingLocation(String location) {
    if (_isDisposed) return;
    startingLocation.value = location;
  }

  void setEndingLocation(String location) {
    if (_isDisposed) return;
    endingLocation.value = location;
  }

  void setDeliveryType(String type) {
    if (_isDisposed) return;
    selectedDeliveryType.value = type;
  }

  void setVehicleType(String type) {
    if (_isDisposed) return;
    selectedVehicleType.value = type;
  }

  void setStartDateTime(DateTime start) {
    if (_isDisposed) return;
    startDateTime.value = start;
  }

  void setEndDateTime(DateTime end) {
    if (_isDisposed) return;
    endDateTime.value = end;
  }

  void setReceiverNumber(String number) {
    if (_isDisposed) return;
    phoneController.text = number;
  }

  //! Step navigation with validation and disposal checks
  void goToNextStep() {
    if (_isDisposed) return;
    
    if (!validateCurrentStep()) return;

    if (currentStep.value < 5) {
      currentStep.value++;
      
      // Check if pageController is still valid before using it
      if (!_isDisposed && pageController.hasClients) {
        try {
          pageController.nextPage(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        } catch (e) {
          debugPrint('Error in goToNextStep: $e');
        }
      }
    } else {
      if (!_isDisposed) {
        Get.toNamed(AppRoutes.senderSummaryOfParcelScreen);
      }
    }
  }

  void goToPreviousStep() {
    if (_isDisposed) return;
    
    if (currentStep.value > 0) {
      currentStep.value--;
      
      // Check if pageController is still valid before using it
      if (!_isDisposed && pageController.hasClients) {
        try {
          pageController.previousPage(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        } catch (e) {
          debugPrint('Error in goToPreviousStep: $e');
        }
      }
    } else {
      // Reset fields without disposing controllers here
      // Controllers will be disposed in onClose()
      if (!_isDisposed) {
        _resetFieldsSafely();
        
        // Navigate back after clearing fields
        Get.back();
      }
    }
  }

  // Safe field reset method
  void _resetFieldsSafely() {
    if (_isDisposed) return;
    
    try {
      startingLocation.value = '';
      endingLocation.value = '';
      startingLocationId.value = '';
      endingLocationId.value = '';
      currentLocationController.clear();
      destinationController.clear();
    } catch (e) {
      debugPrint('Error resetting fields: $e');
    }
  }

  bool validateCurrentStep() {
    if (_isDisposed) return false;
    
    switch (currentStep.value) {
      case 1:
        //! Step 1: Location Validation
        if (startingLocation.isEmpty || endingLocation.isEmpty) {
          // AppSnackBar.error(
          //     "Please fill both pickup and destination locations.");
          return false;
        }
        return true;

      case 2:
        //! Step 2: Time Validation
        if (endDateTime.value == null) {
          // AppSnackBar.error("Please select both delivery start and end time.");
          return false;
        }
        return true;

      case 3:
        //! Step 3: Title Validation (description and images optional)
        if (titleController.text.trim().isEmpty) {
          // AppSnackBar.error("Please fill the title.");
          return false;
        }
        return true;

      case 4:
        //! Step 4: Price Validation
        if (priceController.text.trim().isEmpty) {
          // AppSnackBar.error("Please enter the delivery price.");
          return false;
        }
        return true;

      case 5:
        //! Step 5: Receiver Info Validation
        if (nameController.text.trim().isEmpty ||
            phoneController.text.trim().isEmpty) {
          // AppSnackBar.error("Please enter receiver name and phone number.");
          return false;
        }
        return true;

      default:
        return true;
    }
  }

  //! Comprehensive validation for final submission
  bool validateAllFields() {
    if (_isDisposed) return false;
    
    //! Step 1: Location Validation
    if (startingLocation.isEmpty || endingLocation.isEmpty) {
      // AppSnackBar.error("Please fill both pickup and destination locations.");
      return false;
    }

    //! Step 3: Title Validation (only title is required, description is optional)
    if (titleController.text.trim().isEmpty) {
      // AppSnackBar.error("Please fill the title.");
      return false;
    }

    //! Images are now optional

    //! Step 4: Price Validation
    if (priceController.text.trim().isEmpty) {
      // AppSnackBar.error("Please enter the delivery price.");
      return false;
    }

    //! Step 5: Receiver Info Validation
    if (nameController.text.trim().isEmpty ||
        phoneController.text.trim().isEmpty) {
      // AppSnackBar.error("Please enter receiver name and phone number.");
      return false;
    }

    //! Vehicle type validation
    if (selectedVehicleType.value.isEmpty) {
      // AppSnackBar.error("Please select a vehicle type.");
      return false;
    }

    return true;
  }

  //! Image logic with disposal checks
  Future<void> pickImages() async {
    if (_isDisposed) return;
    
    try {
      final List<XFile> images = await _picker.pickMultiImage();
      
      // Check disposal after async operation
      if (_isDisposed) return;
      
      if (images.isNotEmpty) {
        selectedImages.addAll(images.map((img) => File(img.path).path));
      } else {
        // AppSnackBar.error("No images selected.");
      }
    } catch (e) {
      // AppSnackBar.error("Failed to pick images: $e");
    }
  }

  void removeImage(int index) {
    if (_isDisposed) return;
    selectedImages.removeAt(index);
  }

  String formatDateTime(DateTime dateTime) {
    return DateFormat('yyyy-MM-dd HH:mm').format(dateTime);
  }

  String imageToBase64(File image) {
    final bytes = image.readAsBytesSync();
    return base64Encode(bytes);
  }

  // Submission with complete validation
  Future<void> submitParcelData() async {
    if (_isDisposed) return;
    
    //! Validate all required fields before submission
    if (!validateAllFields()) {
      return;
    }

    var token = await SharePrefsHelper.getString(SharedPreferenceValue.token);
    //! log("🔑 Authorization Token: $token");

    if (token.isEmpty) {
      // AppSnackBar.error("Authorization token is missing.");
      return;
    }

    if (_isDisposed) return;
    
    isLoading.value = true;
    try {
      final parcelData = {
        'senderType': selectedDeliveryType.value,
        'pickupLocation': startingLocation.value,
        'deliveryLocation': endingLocation.value,
        'deliveryStartTime': formatDateTime(startDateTime.value),
        'deliveryEndTime': formatDateTime(endDateTime.value),
        'deliveryType': selectedVehicleType.value,
        'price': priceController.text,
        'title': titleController.text,
        'description': descriptionController.text,
        'name': nameController.text,
        'phoneNumber': completePhoneNumber.value,
      };

      await ImageMultipartUpload().imageUploadWithData2(
        body: parcelData,
        url: AppApiUrl.sendPercel,
        imagePath: selectedImages,
      );
    } catch (e) {
      //! log("⚠️ Error submitting parcel: $e");
      // AppSnackBar.error("Failed to submit parcel data.");
    } finally {
      if (!_isDisposed) {
        isLoading.value = false;
      }
    }
  }

  void resetAllFields() {
    if (_isDisposed) return;
    
    try {
      selectedDeliveryType.value = 'non-professional';
      selectedVehicleType.value = '';
      startingLocation.value = '';
      endingLocation.value = '';
      selectedDate.value = DateTime.now();
      selectedTime.value = DateTime.now();
      startDateTime.value = DateTime.now();
      endDateTime.value = DateTime.now();
      selectedImages.clear();

      currentLocationController.clear();
      destinationController.clear();
      titleController.clear();
      descriptionController.clear();
      priceController.clear();
      nameController.clear();
      phoneController.clear();
    } catch (e) {
      debugPrint('Error resetting fields: $e');
    }
  }

  // Safe navigation method that can be called from UI
  void navigateBack() {
    if (_isDisposed) return;
    
    try {
      // Reset current step to 0
      currentStep.value = 0;

      // Clear all fields
      resetAllFields();

      // Navigate back
      Get.back();
    } catch (e) {
      //! log("Error during navigation back: $e");
      // Force navigation if there's an error
      if (!_isDisposed) {
        Get.back();
      }
    }
  }

  @override
  void onClose() {
    _isDisposed = true; // Mark as disposed first
    
    // Dispose all controllers safely
    try {
      currentLocationController.dispose();
      destinationController.dispose();
      titleController.dispose();
      descriptionController.dispose();
      priceController.dispose();
      nameController.dispose();
      phoneController.dispose();
      pageController.dispose();
      tabController.dispose();
    } catch (e) {
      //! log("Error disposing controllers: $e");
    }
    super.onClose();
  }
}