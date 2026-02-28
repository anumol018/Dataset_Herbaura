import 'package:flutter/material.dart';
import 'plant_database.dart';

class PlantDetailPage extends StatelessWidget {
  final Map<String, dynamic> plant;

  const PlantDetailPage({super.key, required this.plant});

  @override
  Widget build(BuildContext context) {
    final int plantId = plant['id'];

    // ✅ FETCH EXTRA DATA
    final uses = PlantDatabase.getMedicinalUses(plantId);
    final precautions = PlantDatabase.getPlantPrecautions(plantId);
    final images = PlantDatabase.getPlantImages(plantId);

    return Scaffold(
      appBar: AppBar(
        title: Text(plant['common_name'] ?? 'Plant Details'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // 🌿 COMMON NAME
            Text(
              plant['common_name'],
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 4),

           

            // 🖼️ PLANT IMAGES
            if (images.isNotEmpty) ...[
                const Text(
                  "Images",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),

                SizedBox(
                  height: 180,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: images.length,
                    itemBuilder: (_, i) {
                      final imagePath =
                          "${images[i]['rel_path']}${images[i]['filename']}";

                      return Padding(
                        padding: const EdgeInsets.only(right: 12),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.asset(
                            imagePath,
                            width: 220,
                            height: 180,
                            fit: BoxFit.cover,
                            gaplessPlayback: true,

                            // 🔹 SAFETY FALLBACK
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                width: 220,
                                height: 180,
                                color: Colors.grey.shade200,
                                alignment: Alignment.center,
                                child: const Text(
                                  "Image not available",
                                  style: TextStyle(color: Colors.grey),
                                ),
                              );
                            },
                          ),
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 20),
              ],
            
             // 🔬 SCIENTIFIC NAME
            Text(
              plant['scientific_name'],
              style: const TextStyle(
                fontSize: 16,
                fontStyle: FontStyle.italic,
                color: Colors.grey,
              ),
            ),

            const SizedBox(height: 16),

            // 🌍 VERNACULAR / LOCAL NAME  ✅ ADD THIS
            if (plant['vernacular_names'] != null &&
                plant['vernacular_names'].toString().isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                "Local name: ${plant['vernacular_names']}",
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.green,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],


            // 📖 DESCRIPTION
            const Text(
              "Description",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text(
              plant['description'] ?? '',
              style: const TextStyle(fontSize: 15),
            ),

            const SizedBox(height: 20),

            // 💊 MEDICINAL USES
            if (uses.isNotEmpty) ...[
              const Text(
                "Medicinal Uses",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              ...uses.map((u) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("• "),
                        Expanded(child: Text(u['use_text'])),
                      ],
                    ),
                  )),
              const SizedBox(height: 20),
            ],

            // ⚠️ PRECAUTIONS
            if (precautions.isNotEmpty) ...[
              const Text(
                "Precautions",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              ...precautions.map((p) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.warning, size: 16, color: Colors.red),
                        const SizedBox(width: 6),
                        Expanded(child: Text(p['precaution_text'])),
                      ],
                    ),
                  )),
            ],
          ],
        ),
      ),
    );
  }
}
