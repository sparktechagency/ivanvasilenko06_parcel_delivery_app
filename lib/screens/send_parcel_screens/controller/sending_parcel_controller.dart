import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:parcel_delivery_app/constants/api_url.dart';
import 'package:parcel_delivery_app/routes/app_routes.dart';
import 'package:parcel_delivery_app/services/apiServices/api_post_services.dart';
import 'package:parcel_delivery_app/services/appStroage/app_auth_storage.dart';
import 'package:parcel_delivery_app/services/appStroage/share_helper.dart';
import 'package:mime/mime.dart';

class ParcelController extends GetxController {
  // Variables to store user selections

  var isProfessional = false.obs; // Professional or Non-Professional
  var selectedVehicleType = ''.obs; // Selected vehicle type
  var selectedLocation = ''.obs; // Selected location
  var selectedDate = DateTime.now().obs; // Selected date
  var selectedTime = TimeOfDay.now().obs; // Selected time
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

  // Function to set professional or non-professional
  void setProfessional(bool value) {
    isProfessional.value = value;
  }

  // Function to set vehicle type
  void setVehicleType(String type) {
    selectedVehicleType.value = type;
  }

  // Function to set location
  void setLocation(String location) {
    selectedLocation.value = location;
  }

  // Function to set date
  void setDate(DateTime date) {
    selectedDate.value = date;
  }

  // Function to set time
  void setTime(TimeOfDay time) {
    selectedTime.value = time;
  }

  // Function to set description
  void setDescription(String desc) {
    description.value = desc;
  }

  // Function to set price
  void setPrice(double value) {
    price.value = value;
  }

  // Function to set receiver's name
  void setReceiverName(String name) {
    receiverName.value = name;
  }

  // Function to set receiver's number
  void setReceiverNumber(String number) {
    receiverNumber.value = number;
  }

  // Function to pick images
  Future<void> pickImages() async {
    final List<XFile>? images = await _picker.pickMultiImage();
    if (images != null) {
      selectedImages.addAll(images.map((image) => File(image.path)));
    }
  }

  // Function to remove an image
  void removeImage(int index) {
    selectedImages.removeAt(index);
  }

  // Function to navigate to the next step
  void goToNextStep() {
    if (currentStep.value < 5) {
      currentStep.value++;
      pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      // Navigate to the summary screen
      Get.toNamed(AppRoutes.senderSummaryOfParcelScreen);
    }
  }

  // Function to navigate to the previous step
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

  // Function to format date and time
  String formatDateTime(DateTime dateTime) {
    return DateFormat('yyyy-MM-dd HH:mm').format(dateTime);
  }

  // Function to convert image to base64
  String imageToBase64(File image) {
    final bytes = image.readAsBytesSync();
    return base64Encode(bytes);
  }

  // Function to submit parcel data to the backend
  Future<void> submitParcelData() async {
    try {
      final Map<String, dynamic> parcelData = {
        'senderType': isProfessional.value,
        'pickupLocation': currentLocationController.text,
        'deliveryLocation': destinationController.text,
        'deliveryStartTime': "2025-03-10T10:00:00Z".toString(),
        'deliveryEndTime': "2025-03-21T12:00:00Z".toString(),
        'deliveryType': selectedVehicleType.value.toString(),
        'vehicleType': selectedVehicleType.value,
        // 'location': selectedLocation.value,
        // 'deliveryEndTime': selectedDate.value.toIso8601String(),
        // 'time': selectedTime.value.format(Get.context!),
        // 'description': description.value,
        'price': price.value.toString(),
        'receiverDetails': { "name": receiverName.value,
          "phoneNumber": receiverNumber.value},
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

      var token = await SharePrefsHelper.getString(SharedPreferenceValue.token);
      log("🔑 Authorization Token: $token");
      request.headers['Authorization'] = 'Bearer $token';

      log("🌐 Sending request to: ${AppApiUrl.sendPercel}");
        var response = await request.send();
        log("📩 Response Status Code: ${response.statusCode}");
        if (response.statusCode == 200) {
          String responseBody = await response.stream.bytesToString();
          log("✅ Parcel data sent successfully! Response: $responseBody");
          Get.toNamed(AppRoutes.hurrahScreen);
        } else {
          log("❌ Failed to send parcel data: ${response.statusCode}");
          Get.snackbar('Error', 'Failed to submit parcel data: ${response.statusCode}');
        }

    } catch (e) {
      log("❌ Error sending parcel data: $e");
      Get.snackbar('Error', 'Failed to submit parcel data: $e');
    }
  }


  // Function to reset all fields
  void resetAllFields() {
    isProfessional.value = false;
    selectedVehicleType.value = '';
    selectedLocation.value = '';
    selectedDate.value = DateTime.now();
    selectedTime.value = TimeOfDay.now();
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

Future multipartRequest({
  required String url,
  method = "POST",
  List imagePath = const [],
  imageName = 'images',
  required Map<String, dynamic> body,
  required Map<String, String> header,
}) async {
  try {
    var request = http.MultipartRequest(method, Uri.parse(url));
    body.forEach((key, value) {
      request.fields[key] = value;
    });

    for (var item in imagePath) {
      if (item != null) {
        var mimeType = lookupMimeType(item);
        var shopImage = await http.MultipartFile.fromPath(imageName, item,
            contentType: MediaType.parse(mimeType!));
        request.files.add(shopImage);
      }
    }

    Map<String, String> headers = header;

    headers.forEach((key, value) {
      request.headers[key] = value;
    });

    var response = await request.send();

    if (response.statusCode == 200) {
      String data = await response.stream.bytesToString();

      return response;
    } else if (response.statusCode == 201) {
      String data = await response.stream.bytesToString();

      return response;
    } else {
      String data = await response.stream.bytesToString();
      return response;
    }
  } catch (e) {
    print(e);
  }
}
