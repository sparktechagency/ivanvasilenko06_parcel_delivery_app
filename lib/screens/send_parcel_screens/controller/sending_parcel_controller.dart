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

class ParcelController extends GetxController {
  // Observables for form fields
  RxString startingLocation = ''.obs;
  RxString endingLocation = ''.obs;
  RxString selectedDeliveryType = ''.obs;
  RxString selectedVehicleType = ''.obs;
  Rx<DateTime> selectedDate = DateTime.now().obs;
  Rx<DateTime> selectedTime = DateTime.now().obs;
  RxString description = ''.obs;
  RxString price = ''.obs;
  RxString receiverName = ''.obs;
  RxString receiverNumber = ''.obs;
  RxList<String> selectedImages = <String>[].obs;

  // Controllers for text inputs
  final currentLocationController = TextEditingController();
  final destinationController = TextEditingController();
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final priceController = TextEditingController();
  final nameController = TextEditingController();
  final phoneController = TextEditingController();

  // Stepper and carousel controllers
  PageController pageController = PageController();
  PageController tabController = PageController();
  CarouselSliderController carouselController = CarouselSliderController();

  RxInt currentStep = 0.obs;

  final ImagePicker _picker = ImagePicker();

  Rx<DateTime> startDateTime = DateTime.now().obs;
  Rx<DateTime> endDateTime = DateTime.now().obs;

  // Setters for form fields
  void setStartingLocation(String location) {
    startingLocation.value = location;
  }

  void setEndingLocation(String location) {
    endingLocation.value = location;
  }

  void setDeliveryType(String value) {
    selectedDeliveryType.value = value;
  }

  void setVehicleType(String type) {
    selectedVehicleType.value = type;
  }

  void setDate(DateTime date) {
    selectedDate.value = date;
  }

  void setTime(DateTime time) {
    selectedTime.value = time;
  }

  void setDescription(String desc) {
    description.value = desc;
  }

  void setPrice(String value) {
    price.value = value;
  }

  void setReceiverName(String name) {
    receiverName.value = name;
  }

  void setReceiverNumber(String number) {
    receiverNumber.value = number;
  }

  void setStartDateTime(DateTime start) {
    startDateTime.value = start;
  }

  void setEndDateTime(DateTime end) {
    endDateTime.value = end;
  }

  // Image picking logic
  Future<void> pickImages() async {
    try {
      final List<XFile> images = await _picker.pickMultiImage();
      if (images.isNotEmpty) {
        selectedImages.addAll(images.map((image) => File(image.path).path));
      } else {
        Get.snackbar('No images selected', 'Please select at least one image.');
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to pick images: $e');
    }
  }

  void removeImage(int index) {
    selectedImages.removeAt(index);
  }

  // Step navigation logic
  void goToNextStep() {
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
      Get.back();
    }
  }

  String formatDateTime(DateTime dateTime) {
    return DateFormat('yyyy-MM-dd HH:mm').format(dateTime);
  }

  String imageToBase64(File image) {
    final bytes = image.readAsBytesSync();
    return base64Encode(bytes);
  }

  // Submission of parcel data
  Future<void> submitParcelData() async {
    var token = await SharePrefsHelper.getString(SharedPreferenceValue.token);
    log("🔑 Authorization Token: $token");

    if (token.isEmpty) {
      Get.snackbar('Error', 'Authorization token is missing');
      return;
    }

    var startTime = DateFormat('yyyy-MM-dd HH:mm').format(startDateTime.value);
    var endTime = DateFormat('yyyy-MM-dd HH:mm').format(endDateTime.value);
    log("This is startTime: $startTime");

    try {
      final Map<String, dynamic> parcelData = {
        'senderType': selectedDeliveryType.value,
        'pickupLocation': startingLocation.value,
        // Use the starting location from the controller
        'deliveryLocation': endingLocation.value,
        // Use the ending location from the controller
        'deliveryStartTime': startTime,
        'deliveryEndTime': endTime,
        'deliveryType': selectedVehicleType.value,
        'price': priceController.text,
        'title': titleController.text,
        'description': descriptionController.text,
        'name': nameController.text,
        'phoneNumber': phoneController.text,
      };

      log("📦 Sending parcel data: $parcelData");

      if (selectedImages.isEmpty) {
        Get.snackbar('Error', 'Please select at least one image.');
        return;
      }

      await ImageMultipartUpload().imageUploadWithData2(
        body: parcelData,
        url: AppApiUrl.sendPercel,
        imagePath: selectedImages.value,
      );
    } catch (e) {
      log("❌ Error sending parcel data: $e");
      Get.snackbar('Error', 'Failed to submit parcel data: $e');
    }
  }

  // Reset form fields to default values
  void resetAllFields() {
    selectedDeliveryType.value = 'non-professional';
    selectedVehicleType.value = '';
    startingLocation.value = '';
    endingLocation.value = '';
    selectedDate.value = DateTime.now();
    selectedTime.value = DateTime.now();
    description.value = '';
    price.value = '';
    receiverName.value = '';
    receiverNumber.value = '';
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
