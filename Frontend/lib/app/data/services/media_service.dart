import 'dart:io';
import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';

class MediaService {
  final Dio _dio = Dio();
  final ImagePicker _picker = ImagePicker();

  Future<XFile?> pickImage() async {
    return await _picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
  }

  Future<String?> uploadToS3(File file, String uploadUrl, String fileType) async {
    try {
      await _dio.put(
        uploadUrl,
        data: file.openRead(),
        options: Options(
          headers: {
            'Content-Type': fileType,
            'Content-Length': file.lengthSync(),
          },
        ),
      );
      return uploadUrl.split('?').first;
    } catch (e) {
      return null;
    }
  }
}
