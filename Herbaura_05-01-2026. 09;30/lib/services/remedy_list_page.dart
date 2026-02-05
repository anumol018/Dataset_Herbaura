import 'package:flutter/material.dart';
import 'plant_database.dart';

class RemedyListPage extends StatelessWidget {
  const RemedyListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final remedies = PlantDatabase.getRemediesByCategory('Health care');

    return Scaffold(
      appBar: AppBar(title: const Text("Remedies")),
      body: ListView.builder(
        itemCount: remedies.length,
        itemBuilder: (_, i) {
          final remedy = remedies[i];
          final plant = remedy['plant'];

          return Card(
  elevation: 3,
  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(14),
  ),
  child: Padding(
    padding: const EdgeInsets.all(14),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: const [
            Icon(Icons.healing, color: Colors.green),
            SizedBox(width: 6),
            Text(
              "Remedy",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
          ],
        ),

        const SizedBox(height: 6),

        Text(
          remedy['title'] ?? 'Unknown Remedy',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 6),

        Text(
          (remedy['instructions'] ?? 'Details not available')
              .replaceAll(r'\n', '\n'),
          style: const TextStyle(fontSize: 14),
        ),


        const SizedBox(height: 10),

        if (plant != null)
          Row(
            children: [
              const Icon(Icons.eco, size: 16, color: Colors.green),
              const SizedBox(width: 6),
              Text(
                "Plant: ${plant['common_name'] ?? plant['name']}",
                style: const TextStyle(
                  fontStyle: FontStyle.italic,
                  fontSize: 13,
                  color: Colors.green,
                ),
              ),
            ],
          ),
      ],
    ),
  ),
);

        },
      ),
    );
  }
}
