import 'package:flutter/material.dart';
import 'plant_detail_page.dart';

class RemedyDetailPage extends StatelessWidget {
  final Map<String, dynamic> remedy;

  const RemedyDetailPage({super.key, required this.remedy});

  @override
  Widget build(BuildContext context) {
    final plant = remedy['plant'];

    return Scaffold(
      appBar: AppBar(title: Text(remedy['title'] ?? 'Remedy')),
      body: SingleChildScrollView(
        child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Instructions",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),

            Text(
              (remedy['instructions'] ?? '')
                  .replaceAll(r'\n', '\n'),
              style: const TextStyle(fontSize: 15),
            ),

            const SizedBox(height: 20),

            if (plant != null)
              InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PlantDetailPage(plant: plant),
                    ),
                  );
                },
                child: Row(
                  children: [
                    const Icon(Icons.eco, color: Colors.green),
                    const SizedBox(width: 6),
                    Text(
                      plant['common_name'] ?? plant['name'] ?? 'Plant Details',
                      style: const TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),

          ],
        ),
      ),
      ),
    );
  }
}
