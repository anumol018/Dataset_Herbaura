import 'package:flutter/material.dart';
import 'location_service.dart';
import 'weather_service.dart';
import 'plant_database.dart';

class SeasonalDiseasePage extends StatefulWidget {
  const SeasonalDiseasePage({super.key});

  @override
  State<SeasonalDiseasePage> createState() => _SeasonalDiseasePageState();
}

class _SeasonalDiseasePageState extends State<SeasonalDiseasePage> {
  String? season;
  bool loading = true;

  List<Map<String, dynamic>> diseaseList = [];

  String? weatherCondition;
  double? temperature;

  @override
  void initState() {
    super.initState();
    loadSeason();
  }

  Future<void> loadSeason() async {
    try {
      final position = await LocationService.getCurrentLocation();

      final weather = await WeatherService.fetchWeather(
        position.latitude,
        position.longitude,
      );

      final detectedSeason = detectSeason(weather);

      final diseases = PlantDatabase.getDiseasesBySeason(detectedSeason);

      setState(() {
        season = detectedSeason;
        weatherCondition = weather['weather'][0]['main'];
        temperature = weather['main']['temp'];
        diseaseList = diseases;
        loading = false;
      });
    } catch (e) {
      print(e);
      setState(() => loading = false);
    }
  }

  String detectSeason(Map<String, dynamic> weather) {
    double temp = weather['main']['temp'];
    String condition = weather['weather'][0]['main'];

    if (condition.contains("Rain")) {
      return "Monsoon";
    } else if (temp > 32) {
      return "Summer";
    } else if (temp < 20) {
      return "Winter";
    } else {
      return "Normal";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Seasonal Diseases ")),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // 🌦 Weather Info Card
                Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      Text(
                        "Current Season: $season",
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text("Weather: $weatherCondition"),
                      Text(
                        "Temperature: ${temperature?.toStringAsFixed(1)} °C",
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: diseaseList.isEmpty
                      ? const Center(child: Text("No seasonal diseases found"))
                      : ListView.builder(
                          itemCount: diseaseList.length,
                          itemBuilder: (context, index) {
                            final disease = diseaseList[index];

                            return Card(
                              margin: const EdgeInsets.all(10),
                              child: ListTile(
                                title: Text(
                                  disease['name'],
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                subtitle: Text(disease['description']),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }
}
