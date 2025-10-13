import 'dart:io' as io;
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';

class PlatformHelper {
  static bool get isWeb => kIsWeb;
  
  static Future<io.File?> xFileToFile(XFile xFile) async {
    if (isWeb) {
      return null; // N\u00e3o suportado no web
    }
    return io.File(xFile.path);
  }
}