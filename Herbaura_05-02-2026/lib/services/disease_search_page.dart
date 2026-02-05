import 'package:flutter/material.dart';
import 'plant_database.dart';

class DiseaseSearchPage extends StatefulWidget {
  const DiseaseSearchPage({super.key});

  @override
  State<DiseaseSearchPage> createState() => _DiseaseSearchPageState();
}

class _DiseaseSearchPageState extends State<DiseaseSearchPage> {
  final controller = TextEditingController();
  List<Map<String, dynamic>> results = [];

  void searchDisease(String query) {
    final data = PlantDatabase.searchByDisease(query);
    setState(() => results = data);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Search by Disease")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                labelText: "Enter disease name",
                prefixIcon: Icon(Icons.search),
              ),
              onSubmitted: (value) {
                searchDisease(value);
              },
              onChanged: (value) {
                if (value.isNotEmpty) {
               searchDisease(value);
                }
              },
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: results.length,
                itemBuilder: (_, i) => ListTile(
                 title: Text(
                    results[i]['disease'] ?? 'Unknown Disease',
                ),
                subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  Text(
                     results[i]['instructions'] ?? 'Details not available',
                  ),
                  if (results[i]['plant'] != null) ...[
                    const SizedBox(height: 6),
                    Text(
                      "Plant: ${results[i]['plant']['common_name'] ?? results[i]['plant']['scientific_name']}",
                      style: const TextStyle(
                        fontStyle: FontStyle.italic,
                        fontSize: 12,
                      ),
                    ),
                  ],
               ],
              ),
              ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
