import 'package:flutter/material.dart';
import 'plant_database.dart';

class HairOilPage extends StatelessWidget {
  const HairOilPage({super.key});

  @override
  Widget build(BuildContext context) {
    final oils = PlantDatabase.getRemediesByCategory(
      'Wellness',
      subCategory: 'Hair Oil',
    );


    return Scaffold(
      appBar: AppBar(title: const Text("Hair Oil Recipes")),
      body: oils.isEmpty
          ? const Center(child: Text("No hair oil recipes available"))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: oils.length,
              itemBuilder: (context, i) {
                final item = oils[i];
                final plant = item['plant'];

                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.only(bottom: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: const [
                            Icon(Icons.opacity, color: Colors.green),
                            SizedBox(width: 8),
                            Text(
                              "Hair Oil",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 10),

                        Text(
                          item['title'],
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),

                        const SizedBox(height: 8),

                        Text(
                          item['instructions']
                              .replaceAll(r'\n', '\n'),
                          style: const TextStyle(fontSize: 14),
                        ),

                        if (plant != null) ...[
                          const SizedBox(height: 10),
                          Text(
                            "🌿 Plant: ${plant['common_name'] ?? plant['scientific_name']}",
                            style: const TextStyle(
                              fontStyle: FontStyle.italic,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
