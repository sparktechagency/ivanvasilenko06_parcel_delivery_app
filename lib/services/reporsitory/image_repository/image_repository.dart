import 'dart:io';

import 'package:dio/dio.dart';
import 'package:get/get.dart' as GET;
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';
import 'package:parcel_delivery_app/routes/app_routes.dart';
import 'package:parcel_delivery_app/services/apiServices/api_post_services.dart';
import 'package:parcel_delivery_app/widgets/compressed/compressed_image.dart';

class ImageMultipartUpload {
  Future<dynamic> imageUploadWithData2({
    required String url,
    required List<String> imagePath,
    required Map<String, dynamic> body,
  }) async {
    try {
// Initialize FormData with the body fields
      FormData formData = FormData.fromMap(body);
// Check if an image path is provided
      if (imagePath.isNotEmpty) {
        for (var element in imagePath) {
          final file = File(element);
          if (await file.exists()) {
            final compressedFile = await compressImage(file);
            String fileName = compressedFile!.path.split('/').last;
            String? mimeType = lookupMimeType(file.path);
            formData.files.add(
              MapEntry(
                'image',
                await MultipartFile.fromFile(
                  file.path,
                  filename: fileName,
                  contentType:
                      mimeType != null ? MediaType.parse(mimeType) : null,
                ),
              ),
            );
          }
        }
      }
      var data = await ApiPostServices()
          .apiPostServices(url: url, body: formData, statusCode: 201
// token: AppStorage().getToken(),
              );
      if (data != null) {
        //AppSnackBar.success("Image uploaded successfully");
        GET.Get.toNamed(AppRoutes.hurrahScreen);
        return data;
      }
    } catch (e) {
      //! log("$e");
    }
    return null;
  }
}
