import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:archive/archive.dart';

class PlantDatabase {
  static List<dynamic> plants = [];
  static List<dynamic> diseases = [];
  static List<dynamic> remedies = [];
  static List<dynamic> remedyDiseases = [];
  static List<dynamic> precautions = [];
  static List<dynamic> plantImages = [];
  static List<dynamic> medicinalUses = [];
  static List<dynamic> diseaseWeatherTags = [];

  static Future<void> init() async {
    final data = await rootBundle.load('assets/database/herbaura_database.zip');

    final bytes = data.buffer.asUint8List();
    final archive = ZipDecoder().decodeBytes(bytes);

    for (final file in archive) {
      final content = utf8.decode(file.content);

      if (file.name.endsWith('plants.json')) {
        plants = jsonDecode(content);
      }

      if (file.name.endsWith('diseases.json')) {
        diseases = jsonDecode(content);
      }

      if (file.name.endsWith('remedies.json')) {
        remedies = jsonDecode(content);
      }

      if (file.name.endsWith('remedy_diseases.json')) {
        remedyDiseases = jsonDecode(content);
      }

      if (file.name.endsWith('precautions.json')) {
        precautions = jsonDecode(content);
      }

      if (file.name.endsWith('plant_images.json')) {
        plantImages = jsonDecode(content);
      }

      if (file.name.endsWith('medicinal_uses.json')) {
        medicinalUses = jsonDecode(content);
      }

      if (file.name.endsWith('disease_weather_tags.json')) {
        diseaseWeatherTags = jsonDecode(content);
      }
    }

    print('Plants: ${plants.length}');
    print('Diseases: ${diseases.length}');
    print('Remedies: ${remedies.length}');
    print('Remedy-Diseases: ${remedyDiseases.length}');
  }

  static Map<String, dynamic>? getPlantInfo(String label) {
    for (final plant in plants) {
      if (plant['ai_label'].toString().trim().toLowerCase() ==
          label.trim().toLowerCase()) {
        final int plantId = plant['id'];

        final plantPrecautions = precautions
            .where((p) => p['plant_id'] == plantId)
            .toList();

        final medUses = medicinalUses
            .where((u) => u['plant_id'] == plantId)
            .toList();

        return {
          "plant": plant, // 🌿 main plant table
          "precautions": plantPrecautions, // 🌿 precautions.json
          "medicinal_uses": medUses, // 🌿 medicinal_uses.json
        };
      }
    }
    return null;
  }

  static List<Map<String, dynamic>> searchByDisease(String query) {
    if (query.trim().isEmpty) return [];

    final q = query.trim().toLowerCase();

    // 🔎 Partial match instead of exact match
    final matchedDiseases = diseases.where((d) {
      final name = d['name'].toString().toLowerCase();
      return name.contains(q);
    }).toList();

    if (matchedDiseases.isEmpty) return [];

    final int diseaseId = matchedDiseases.first['id'];

    // Find linked remedy IDs
    final linkedRemedyIds = remedyDiseases
        .where((rd) => rd['disease_id'] == diseaseId)
        .map((rd) => rd['remedy_id'])
        .toList();

    // Get remedy details
    final matchedRemedies = remedies.where(
      (r) => linkedRemedyIds.contains(r['id']),
    );

    return matchedRemedies.map<Map<String, dynamic>>((r) {
      final plant = plants.firstWhere(
        (p) => p['id'] == r['plant_id'],
        orElse: () => null,
      );

      return {
        'disease': matchedDiseases.first['name'],
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
        .where(
          (r) =>
              r['category'].toString().toLowerCase() == category.toLowerCase(),
        )
        .where(
          (r) =>
              subCategory == null ||
              r['sub_category'].toString().toLowerCase() ==
                  subCategory.toLowerCase(),
        )
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

  // 🌿 GET DISEASES BY SEASON
  static List<Map<String, dynamic>> getDiseasesByTags(List<String> tags) {
    final matchedDiseaseIds = diseaseWeatherTags
        .where((dw) => tags.contains(dw['tag']))
        .map((dw) => dw['disease_id'])
        .toSet(); // remove duplicates

    return diseases
        .where((d) => matchedDiseaseIds.contains(d['id']))
        .map<Map<String, dynamic>>((d) => d)
        .toList();
  }
}
