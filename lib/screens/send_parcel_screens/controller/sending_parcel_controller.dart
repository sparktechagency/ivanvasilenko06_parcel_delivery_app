import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:parcel_delivery_app/constants/api_url.dart';
import 'package:parcel_delivery_app/routes/app_routes.dart';
import 'package:parcel_delivery_app/services/appStroage/share_helper.dart';
import 'package:http_parser/http_parser.dart';

class ParcelController extends GetxController {
  // Variables to store user selections
  var selectedDeliveryType = 'non-professional'.obs; // Professional or Non-Professional
  var selectedVehicleType = ''.obs; // Selected vehicle type
  var selectedLocation = ''.obs; // Selected location
  var selectedDate = DateTime.now().obs; // Selected date
  var selectedTime = DateTime.now().obs; // Selected time
  var description = ''.obs; // Parcel description
  var price = 0.0.obs; // Parcel price
  var receiverName = ''.obs; // Receiver's name
  var receiverNumber = ''.obs; // Receiver's phone number
  var selectedImages = <File>[].obs; // Selected images for the parcel

  // Controllers for text fields
  final currentLocationController = TextEditingController();
  final destinationController = TextEditingController();
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final priceController = TextEditingController();
  final nameController = TextEditingController();
  final phoneController = TextEditingController();

  // Page and tab controllers
  PageController pageController = PageController();
  PageController tabController = PageController();
  CarouselSliderController carouselController = CarouselSliderController();

  // Current step in the process
  var currentStep = 0.obs;

  // Image picker
  final ImagePicker _picker = ImagePicker();

  // New variables for storing start and end time
  var startDateTime = DateTime.now().obs; // Start date-time
  var endDateTime = DateTime.now().obs; // End date-time

  // Setters for fields
  void setProfessional(String value) {
    selectedDeliveryType.value = value;
  }

  void setVehicleType(String type) {
    selectedVehicleType.value = type;
  }

  void setLocation(String location) {
    selectedLocation.value = location;
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

  void setPrice(double value) {
    price.value = value;
  }

  void setReceiverName(String name) {
    receiverName.value = name;
  }

  void setReceiverNumber(String number) {
    receiverNumber.value = number;
  }

  // Setters for start and end time
  void setStartDateTime(DateTime start) {
    startDateTime.value = start;
  }

  void setEndDateTime(DateTime end) {
    endDateTime.value = end;
  }

  Future<void> pickImages() async {
    try {
      final List<XFile>? images = await _picker.pickMultiImage();
      if (images != null && images.isNotEmpty) {
        selectedImages.addAll(images.map((image) => File(image.path)));
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

  // Navigation functions
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

  // Format date and time
  String formatDateTime(DateTime dateTime) {
    return DateFormat('yyyy-MM-dd HH:mm').format(dateTime);
  }

  // Convert image to base64
  String imageToBase64(File image) {
    final bytes = image.readAsBytesSync();
    return base64Encode(bytes);
  }

  // Submit parcel data
  Future<void> submitParcelData() async {

    if (selectedDeliveryType.value.isEmpty ||
        selectedVehicleType.value.isEmpty ||
        currentLocationController.text.isEmpty ||
        destinationController.text.isEmpty ||
        titleController.text.isEmpty ||
        descriptionController.text.isEmpty ||
        receiverName.value.isEmpty ||
        receiverNumber.value.isEmpty ||
        selectedImages.isEmpty) {
      Get.snackbar('Error', 'Please fill all the required fields including images');
      return;
    }

    var token = await SharePrefsHelper.getString(SharedPreferenceValue.token);
    log("🔑 Authorization Token: $token");

    var startTime = DateFormat('yyyy-MM-dd HH:mm').format(startDateTime.value);
    var endTime = DateFormat('yyyy-MM-dd HH:mm').format(endDateTime.value);

    log("This is startTime: $startTime");

    try {
      final Map<String, dynamic> parcelData = {
        'senderType': selectedDeliveryType.value,
        'pickupLocation': currentLocationController.text,
        'deliveryLocation': destinationController.text,
        'deliveryStartTime': startTime, // Use startTime from the controller
        'deliveryEndTime': endTime, // Use endTime from the controller
        'deliveryType': selectedVehicleType.value,
        'price': price.value.toString(),
        'receiverDetails': {
          "name": receiverName.value,
          "phoneNumber": receiverNumber.value,
        },
        'title': titleController.text,
        'description': descriptionController.text,
      };

      log("📦 Sending parcel data: $parcelData");

      var request = http.MultipartRequest(
        'POST',
        Uri.parse(AppApiUrl.sendPercel),
      );

      request.fields.addAll(parcelData.map((key, value) => MapEntry(key, value.toString())));

      log("🖼 Selected images count: ${selectedImages.length}");
      for (var image in selectedImages) {
        log("📸 Adding image: ${image.path}");
        request.files.add(
          await http.MultipartFile.fromPath(
            'images',
            image.path,
            contentType: MediaType('image', 'png'),
          ),
        );
      }

      request.headers['Authorization'] = 'Bearer $token';
      log("🌐 Sending request to: ${AppApiUrl.sendPercel}");

      var response = await request.send();

      log("📩 Response Status Code: ${response.statusCode}");
      if (response.statusCode == 200 || response.statusCode == 201) {
        String responseBody = await response.stream.bytesToString();
        log("✅ Parcel data sent successfully! Response: $responseBody");
        Get.toNamed(AppRoutes.hurrahScreen);
      } else {
        String responseBody = await response.stream.bytesToString();
        log("❌ Failed to send parcel data: ${response.statusCode} - $responseBody");
        Get.snackbar('Error', 'Failed to submit parcel data: ${response.statusCode}');
      }
    } catch (e) {
      log("❌ Error sending parcel data: $e");
      Get.snackbar('Error', 'Failed to submit parcel data: $e');
    }
  }

  // Reset all fields
  void resetAllFields() {
    selectedDeliveryType.value = 'non-professional';
    selectedVehicleType.value = '';
    selectedLocation.value = '';
    selectedDate.value = DateTime.now();
    selectedTime.value = DateTime.now();
    description.value = '';
    price.value = 0.0;
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
    // Dispose of controllers
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
