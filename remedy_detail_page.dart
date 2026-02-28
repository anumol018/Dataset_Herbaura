import 'package:flutter/material.dart';
import 'plant_detail_page.dart';

class RemedyDetailPage extends StatelessWidget {
  final Map<String, dynamic> remedy;

  const RemedyDetailPage({super.key, required this.remedy});

  @override
  Widget build(BuildContext context) {
    print(remedy);
    final String instructions = (remedy['instructions'] ?? "").replaceAll(
      "\\n",
      "\n",
    );
    final List<String> steps = instructions.split('\n');

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: const Color(0xFF6D4C41),
        title: Text(
          remedy['title'] ?? "",
          style: const TextStyle(
            fontFamily: "AlexBrush",
            fontSize: 26,
            color: Colors.amber,
          ),
        ),
        centerTitle: true,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/Remedy_page.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),

                const Text(
                  "Instructions",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF4A2F1B),
                  ),
                ),

                const SizedBox(height: 16),

                // ✅ FIXED ERROR HERE
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: steps.map<Widget>((step) {
                    if (step.trim().isEmpty) {
                      return const SizedBox();
                    }

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Text(
                        "• ${step.trim()}.",
                        style: const TextStyle(
                          fontSize: 17,
                          height: 1.6,
                          color: Color(0xFF5D4037),
                        ),
                      ),
                    );
                  }).toList(),
                ),

                const SizedBox(height: 30),

                // 🌿 Plant Link
                // 🌿 Plant Link (Correct for your structure)
                if (remedy['plant'] != null) ...[
                  const SizedBox(height: 30),

                  Row(
                    children: [
                      const Icon(Icons.eco, color: Color(0xFF2E7D32)),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  PlantDetailPage(plant: remedy['plant']),
                            ),
                          );
                        },
                        child: Text(
                          remedy['plant']['common_name'] ?? "",
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF2E7D32),
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],

                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
