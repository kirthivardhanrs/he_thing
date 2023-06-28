import 'dart:io';
import 'package:tflite_flutter/tflite_flutter.dart';

class OCRService {
  Interpreter? _interpreter;

  Future<void> loadModel() async {
    try {
      final modelFile = File('assets/ocr_model.tflite');
      final labelsFile = File('assets/ocr_labels.txt');

      final model = await FileInterpreter.loadModel(
        modelFile: modelFile,
        labelFile: labelsFile,
        options: FileInterpreterOptions(),
      );

      _interpreter = model.createInterpreter();
    } catch (e) {
      print('Error loading OCR model: $e');
    }
  }

  Future<List<String>> recognizeText(File image) async {
    if (_interpreter == null) {
      print('OCR model not loaded.');
      return [];
    }

    try {
      final inputImage = await loadImage(image);

      final output = await _interpreter!.run(inputImage);

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

  Future<List> loadImage(File image) async {
    final inputImage = await image.readAsBytes();

    return inputImage.buffer.asUint8List();
  }
}
