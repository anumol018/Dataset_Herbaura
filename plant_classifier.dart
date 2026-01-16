import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;

class PlantClassifier {
  late Interpreter _interpreter;
  late List<String> _labels;
  bool _loaded = false;

  Future<void> loadModel() async {
    if (_loaded) return;

  _interpreter = await Interpreter.fromAsset(
    'assets/model/herbaura_model_wholeplant.tflite',
    options: InterpreterOptions()
      ..threads = 4
      ..useNnApiForAndroid = false,
  );


    final labelsData =
        await rootBundle.loadString('assets/model/labels.txt');

    _labels = labelsData
        .split('\n')
        .where((e) => e.trim().isNotEmpty)
        .toList();

    // Warm-up (important for low-end phones)
    _warmUp();

    _loaded = true;
  }

  void _warmUp() {
    final dummy = img.Image(width: 224, height: 224);
    predict(dummy);
  }

  Float32List _preprocess(img.Image image) {
    const int size = 224;
    final resized = img.copyResize(image, width: size, height: size);

    final Float32List input = Float32List(1 * size * size * 3);
    int index = 0;

    for (int y = 0; y < size; y++) {
      for (int x = 0; x < size; x++) {
        final pixel = resized.getPixel(x, y);
        input[index++] = pixel.r / 255.0;
        input[index++] = pixel.g / 255.0;
        input[index++] = pixel.b / 255.0;
      }
    }
    return input;
  }

  Map<String, dynamic> predict(img.Image image) {
    final input = _preprocess(image);

    final output =
        List.generate(1, (_) => List.filled(_labels.length, 0.0));

    _interpreter.run(
      input.reshape([1, 224, 224, 3]),
      output,
    );

    final scores = output[0];

    int maxIndex = 0;
    double maxScore = scores[0];

    for (int i = 1; i < scores.length; i++) {
      if (scores[i] > maxScore) {
        maxScore = scores[i];
        maxIndex = i;
      }
    }

    final confidence = maxScore;
    final label = _labels[maxIndex];

    if (confidence < 0.60) {
      return {
        "result": "Rejected",
        "message": "Image does not appear to contain a known medicinal plant",
      };
    }

    if (label.toLowerCase() == "hold") {
      return {
        "result": "Hold",
        "message": "Please capture a clear image of a single leaf",
      };
    }

    return {
      "result": label,
      "confidence": confidence,
    };
  }
}
