import 'dart:io';
import 'package:flutter_tesseract_ocr/flutter_tesseract_ocr.dart';

class OCRService {
  Future<String> recognizeText(File image) async {
    try {
      final recognizedText = await FlutterTesseractOcr.extractText(image.path);
      return recognizedText;
    } catch (e) {
      print('Error recognizing text: $e');
      return '';
    }
  }
}
