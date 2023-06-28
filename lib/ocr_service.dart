import 'dart:io';
import 'package:tflite/tflite.dart';

class OCRService {
  Future<void> loadModel() async {
    try {
      final modelPath = 'assets/ocr_model.tflite';
      final labelsPath = 'assets/ocr_labels.txt';

      await Tflite.loadModel(
        model: modelPath,
        labels: labelsPath,
      );
    } catch (e) {
      print('Error loading OCR model: $e');
    }
  }

  Future<List<String>> recognizeText(File image) async {
    try {
      final List<dynamic> output = await Tflite.runModelOnImage(
        path: image.path,
      );

      final List<String> recognizedText = [];

      for (var i = 0; i < output.length; i++) {
        recognizedText.add(output[i]['label']);
      }

      return recognizedText;
    } catch (e) {
      print('Error recognizing text: $e');
      return [];
    }
  }
}
