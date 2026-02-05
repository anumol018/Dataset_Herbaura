import 'package:flutter/material.dart';
import 'plant_database.dart';

class RemedyListPage extends StatelessWidget {
  const RemedyListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final remedies = PlantDatabase.getAllRemedies();

    return Scaffold(
      appBar: AppBar(title: const Text("Remedies")),
      body: ListView.builder(
        itemCount: remedies.length,
        itemBuilder: (_, i) {
          final remedy = remedies[i];
          final plant = remedy['plant'];

          return ListTile(
            leading: const Icon(Icons.healing),

            // ✅ Correct key
            title: Text(
              remedy['title'] ?? 'Unknown Remedy',
            ),

            // ✅ Correct key
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  remedy['instructions'] ?? 'Details not available',
                ),
                if (plant != null)
                  Text(
                    "Plant: ${plant['common_name'] ?? plant['name']}",
                    style: const TextStyle(
                      fontStyle: FontStyle.italic,
                      fontSize: 12,
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
