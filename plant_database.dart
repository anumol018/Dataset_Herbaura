import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:archive/archive.dart';

class PlantDatabase {
  static List<dynamic> plants = [];
  static List<dynamic> uses = [];

  static Future<void> init() async {
    // 1️⃣ Load ZIP file
    final data = await rootBundle.load(
      'assets/database/herbaura_database.zip',
    );

    // 2️⃣ Decode ZIP
    final bytes = data.buffer.asUint8List();
    final archive = ZipDecoder().decodeBytes(bytes);

    // 3️⃣ Read files inside ZIP
    for (final file in archive) {
      final content = utf8.decode(file.content);

      if (file.name == 'plants.json') {
        plants = jsonDecode(content);
        print('PLANTS LOADED: ${plants.length}');
      }

      if (file.name == 'medicinal_uses.json') {
        uses = jsonDecode(content);
        print('USES LOADED: ${uses.length}');
      }
    }
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

}
