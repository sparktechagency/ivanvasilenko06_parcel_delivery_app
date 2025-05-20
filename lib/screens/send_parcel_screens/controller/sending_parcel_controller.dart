import 'dart:convert';
import 'dart:developer';
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
import 'package:parcel_delivery_app/widgets/app_snackbar/custom_snackbar.dart';

class ParcelController extends GetxController {
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
    startingLocationId.value = id;
  }

  void setEndingLocationId(String id) {
    endingLocationId.value = id;
  }

  void setCurrentLocationCoordinates(String latitude, String longitude) {
    currentLocationLatitude.value = latitude;
    currentLocationLongitude.value = longitude;
  }

  final RxString completePhoneNumber = ''.obs;

  void updatePhoneNumber(String phoneNumber) {
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

  //! Setters
  void setStartingLocation(String location) =>
      startingLocation.value = location;

  void setEndingLocation(String location) => endingLocation.value = location;

  void setDeliveryType(String type) => selectedDeliveryType.value = type;

  void setVehicleType(String type) => selectedVehicleType.value = type;

  void setStartDateTime(DateTime start) => startDateTime.value = start;

  void setEndDateTime(DateTime end) => endDateTime.value = end;

  void setReceiverNumber(String number) => phoneController.text = number;

  //! Step navigation with validation
  void goToNextStep() {
    if (!validateCurrentStep()) return;

    if (currentStep.value < 5) {
      currentStep.value++;
      pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      Get.toNamed(AppRoutes.senderSummaryOfParcelScreen);
    }
  }

  void goToPreviousStep() {
    if (currentStep.value > 0) {
      currentStep.value--;
      pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      currentLocationController.dispose();
      destinationController.dispose();
      startingLocation.value = '';
      endingLocation.value = '';
      startingLocationId.value = '';
      endingLocationId.value = '';
      Get.back();
    }
  }

  bool validateCurrentStep() {
    switch (currentStep.value) {
      case 1:
        //! Step 1: Location Validation
        if (startingLocation.isEmpty || endingLocation.isEmpty) {
          AppSnackBar.error(
              "Please fill both pickup and destination locations.");
          return false;
        }
        return true;

      case 2:
        //! Step 2: Time Validation
        if (startDateTime.value == null || endDateTime.value == null) {
          AppSnackBar.error("Please select both delivery start and end time.");
          return false;
        }
        return true;

      case 3:
        //! Step 3: Title Validation (description and images optional)
        if (titleController.text.trim().isEmpty) {
          AppSnackBar.error("Please fill the title.");
          return false;
        }
        return true;

      case 4:
        //! Step 4: Price Validation
        if (priceController.text.trim().isEmpty) {
          AppSnackBar.error("Please enter the delivery price.");
          return false;
        }
        return true;

      case 5:
        //! Step 5: Receiver Info Validation
        if (nameController.text.trim().isEmpty ||
            phoneController.text.trim().isEmpty) {
          AppSnackBar.error("Please enter receiver name and phone number.");
          return false;
        }
        return true;

      default:
        return true;
    }
  }

  //! Comprehensive validation for final submission
  bool validateAllFields() {
    //! Step 1: Location Validation
    if (startingLocation.isEmpty || endingLocation.isEmpty) {
      AppSnackBar.error("Please fill both pickup and destination locations.");
      return false;
    }

    //! Step 2: Time Validation
    if (startDateTime.value == null || endDateTime.value == null) {
      AppSnackBar.error("Please select both delivery start and end time.");
      return false;
    }

    //! Step 3: Title Validation (only title is required, description is optional)
    if (titleController.text.trim().isEmpty) {
      AppSnackBar.error("Please fill the title.");
      return false;
    }

    //! Images are now optional

    //! Step 4: Price Validation
    if (priceController.text.trim().isEmpty) {
      AppSnackBar.error("Please enter the delivery price.");
      return false;
    }

    //! Step 5: Receiver Info Validation
    if (nameController.text.trim().isEmpty ||
        phoneController.text.trim().isEmpty) {
      AppSnackBar.error("Please enter receiver name and phone number.");
      return false;
    }

    //! Vehicle type validation
    if (selectedVehicleType.value.isEmpty) {
      AppSnackBar.error("Please select a vehicle type.");
      return false;
    }

    return true;
  }

  //! Image logic
  Future<void> pickImages() async {
    try {
      final List<XFile> images = await _picker.pickMultiImage();
      if (images.isNotEmpty) {
        selectedImages.addAll(images.map((img) => File(img.path).path));
      } else {
        AppSnackBar.error("No images selected.");
      }
    } catch (e) {
      AppSnackBar.error("Failed to pick images: $e");
    }
  }

  void removeImage(int index) {
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
    //! Validate all required fields before submission
    if (!validateAllFields()) {
      return;
    }

    var token = await SharePrefsHelper.getString(SharedPreferenceValue.token);
    log("🔑 Authorization Token: $token");

    if (token.isEmpty) {
      AppSnackBar.error("Authorization token is missing.");
      return;
    }

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
      log("❌ Error submitting parcel: $e");
      AppSnackBar.error("Failed to submit parcel data.");
    } finally {
      isLoading.value = false;
    }
  }
  void resetAllFields() {
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
  }

  @override
  void onClose() {
    currentLocationController.dispose();
    destinationController.dispose();
    titleController.dispose();
    descriptionController.dispose();
    priceController.dispose();
    nameController.dispose();
    phoneController.dispose();
    super.onClose();
  }
}
