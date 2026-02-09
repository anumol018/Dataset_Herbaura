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
      appBar: AppBar(
        title: const Text("Search by Disease"),
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // 🔍 Modern Search Bar
            TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: "Search  ",
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.green.shade50,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (value) {
                if (value.isNotEmpty) {
                  searchDisease(value);
                } else {
                  setState(() => results = []);
                }
              },
            ),

            const SizedBox(height: 20),

            // 🌱 Results / Empty State
            Expanded(
              child: results.isEmpty
                  ? const Center(
                      child: Text(
                        "🌿 No remedies found\nTry another disease",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                    )
                  : ListView.builder(
                      itemCount: results.length,
                      itemBuilder: (_, i) {
                        final item = results[i];
                        final plant = item['plant'];

                        return Card(
                          elevation: 3,
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(14),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // 🦠 Disease name
                                Text(
                                  item['disease'] ?? 'Unknown Disease',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),

                                const SizedBox(height: 6),

                                // 💊 Remedy instructions
                                Text(
                                  (item['instructions'] ?? 'Details not available')
                                      .replaceAll(r'\n:', '\n')
                                      .replaceAll(r'\n', '\n'),
                                  style: const TextStyle(fontSize: 14),
                                ),


                                const SizedBox(height: 10),

                                // 🌿 Plant info
                                if (plant != null)
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.eco,
                                        size: 16,
                                        color: Colors.green,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        "Plant: ${plant['common_name'] ?? plant['scientific_name']}",
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
            ),
          ],
        ),
      ),
    );
  }
}
