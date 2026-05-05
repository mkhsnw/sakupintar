import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';

class ImageHelper {
  static final ImagePicker _picker = ImagePicker();

  static Future<File?> pickAndCompressImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image == null) return null;

    final File file = File(image.path);
    final int size = await file.length();
    
    // Only compress if size is larger than a certain threshold, or always compress
    final String targetPath = '${file.absolute.path}_compressed.jpg';
    
    var result = await FlutterImageCompress.compressAndGetFile(
      file.absolute.path, 
      targetPath,
      quality: 70,
      minWidth: 800,
      minHeight: 800,
    );

    if (result != null) {
      return File(result.path);
    }
    return file; // Return original if compression fails
  }
}
