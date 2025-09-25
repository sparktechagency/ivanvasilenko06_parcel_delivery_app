import 'dart:io';
import 'package:flutter_image_compress/flutter_image_compress.dart';
Future<XFile?> compressImage(File file) async {
final compressedImage = await FlutterImageCompress.compressAndGetFile(file.path, '${file.parent.path}/compressed_${file.path.split('/').last}', quality: 50);
return compressedImage ?? XFile(file.path);
}