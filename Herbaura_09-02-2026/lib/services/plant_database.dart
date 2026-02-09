import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:archive/archive.dart';


class PlantDatabase {
  static List<dynamic> plants = [];
  static List<dynamic> uses = [];
  static List<dynamic> diseases = [];
  static List<dynamic> remedies = [];
  static List<dynamic> remedyDiseases = [];
  static List<dynamic> precautions = [];     
  static List<dynamic> plantImages = [];     
  static List<dynamic> medicinalUses = [];   

  static Future<void> init() async {
  final data = await rootBundle.load(
    'assets/database/herbaura_database.zip',
  );

  final bytes = data.buffer.asUint8List();
  final archive = ZipDecoder().decodeBytes(bytes);

  for (final file in archive) {
    final content = utf8.decode(file.content);

    if (file.name == 'plants.json') {
      plants = jsonDecode(content);
    }

    if (file.name == 'diseases.json') {
      diseases = jsonDecode(content);
    }

    if (file.name == 'remedies.json') {
      remedies = jsonDecode(content);
    }

    if (file.name == 'remedy_diseases.json') {
      remedyDiseases = jsonDecode(content);
    }

    if (file.name == 'precautions.json') {
      precautions = jsonDecode(content);
    }

    if (file.name == 'plant_images.json') {
      plantImages = jsonDecode(content);
    }

    if (file.name == 'medicinal_uses.json') {
      medicinalUses = jsonDecode(content);
    }

  }

  print('Plants: ${plants.length}');
  print('Diseases: ${diseases.length}');
  print('Remedies: ${remedies.length}');
  print('Remedy-Diseases: ${remedyDiseases.length}');
}

  static Map<String, dynamic>? getPlantInfo(String label) {
  for (final plant in plants) {

    // 🔍 DEBUG PRINTS (TEMPORARY)
    print("AI LABEL RECEIVED: $label");
    print("DB LABEL: ${plant['ai_label']}");
    for (final p in plants) {
         print(p['ai_label']);
    }

    if (plant['ai_label']
        .toString()
        .trim()
        .toLowerCase() ==
    label.trim().toLowerCase()) {

      final plantId = plant['id'];

      final plantUses =
          uses.where((u) => u['plant_id'] == plantId).toList();

      return {
        "plant": plant,
        "uses": plantUses,
      };
    }
  }
  return null;
}

static List<Map<String, dynamic>> searchByDisease(String query) {
  if (query.trim().isEmpty) return [];

  final q = query.trim().toLowerCase();

  // 1️⃣ Find disease
  final disease = diseases.firstWhere(
    (d) => d['name'].toString().toLowerCase() == q,
    orElse: () => null,
  );

  if (disease == null) return [];

  final int diseaseId = disease['id'];

  // 2️⃣ Find remedy IDs linked to disease
  final linkedRemedyIds = remedyDiseases
      .where((rd) => rd['disease_id'] == diseaseId)
      .map((rd) => rd['remedy_id'])
      .toList();

  // 3️⃣ Get remedy details
  final matchedRemedies = remedies.where(
    (r) => linkedRemedyIds.contains(r['id']),
  );

  // 4️⃣ Attach plant details
  return matchedRemedies.map<Map<String, dynamic>>((r) {
    final plant = plants.firstWhere(
      (p) => p['id'] == r['plant_id'],
      orElse: () => null,
    );

    return {
      'disease': disease['name'],
      'remedy_title': r['title'],
      'instructions': r['instructions'],
      'duration': r['duration'],
      'dosage': r['dosage'],
      'plant': plant,
    };
  }).toList();
}


static List<Map<String, dynamic>> getAllRemedies() {
  return remedies.map<Map<String, dynamic>>((r) {
    final plant = plants.firstWhere(
      (p) => p['id'] == r['plant_id'],
      orElse: () => null,
    );

    return {
      'title': r['title'],
      'instructions': r['instructions'],
      'duration': r['duration'],
      'dosage': r['dosage'],
      'plant': plant,
    };
  }).toList();
}

static List<Map<String, dynamic>> getRemediesByCategory(
  String category, {
  String? subCategory,
}) {
  return remedies
      .where((r) =>
          r['category'].toString().toLowerCase() ==
          category.toLowerCase())
      .where((r) =>
          subCategory == null ||
          r['sub_category'].toString().toLowerCase() ==
              subCategory.toLowerCase())
      .map<Map<String, dynamic>>((r) {
        final plant = plants.firstWhere(
          (p) => p['id'] == r['plant_id'],
          orElse: () => null,
        );

        return {
          'title': r['title'],
          'instructions': r['instructions'],
          'duration': r['duration'],
          'dosage': r['dosage'],
          'plant': plant,
          'category': r['category'],
          'sub_category': r['sub_category'],
        };
      })
      .toList();
}

// 🌿 GET PLANT PRECAUTIONS
static List<Map<String, dynamic>> getPlantPrecautions(int plantId) {
  return precautions
      .where((p) => p['plant_id'] == plantId)
      .map<Map<String, dynamic>>((p) => p)
      .toList();
}

// 🌿 GET PLANT IMAGES
static List<Map<String, dynamic>> getPlantImages(int plantId) {
  return plantImages
      .where((img) => img['plant_id'] == plantId)
      .map<Map<String, dynamic>>((img) => img)
      .toList();
}

// 🌿 GET MEDICINAL USES
static List<Map<String, dynamic>> getMedicinalUses(int plantId) {
  return medicinalUses
      .where((u) => u['plant_id'] == plantId)
      .map<Map<String, dynamic>>((u) => u)
      .toList();
}








}
