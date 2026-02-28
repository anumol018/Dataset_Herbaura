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
  bool loading = true;

  List<Map<String, dynamic>> diseaseList = [];

  double? temperature;
  double? humidity;
  double? pressure;
  double? windSpeed;
  bool isRaining = false;

  @override
  void initState() {
    super.initState();
    loadWeatherAndDiseases();
  }

  // 🌿 Generate Weather Tags
  List<String> generateWeatherTags(Map<String, dynamic> weather) {
    double temp = (weather['main']['temp'] as num).toDouble();
    double humidity = (weather['main']['humidity'] as num).toDouble();
    double pressure = (weather['main']['pressure'] as num).toDouble();
    double wind = (weather['wind']['speed'] as num).toDouble();
    String condition = weather['weather'][0]['main'];

    List<String> tags = [];

    if (temp > 33) tags.add("high_temp");
    if (temp < 20) tags.add("low_temp");
    if (humidity > 75) tags.add("high_humidity");
    if (pressure < 1005) tags.add("low_pressure");
    if (wind > 5) tags.add("high_wind");
    if (condition.toLowerCase().contains("rain")) {
      tags.add("rain");
    }
    if (condition.toLowerCase().contains("cloud")) {
      tags.add("cloudy");
    }

    return tags;
  }

  Future<void> loadWeatherAndDiseases() async {
    try {
      final position = await LocationService.getCurrentLocation();

      final weather = await WeatherService.fetchWeather(
        position.latitude,
        position.longitude,
      );

      final temp = (weather['main']['temp'] as num).toDouble();
      final hum = (weather['main']['humidity'] as num).toDouble();
      final pres = (weather['main']['pressure'] as num).toDouble();
      final wind = (weather['wind']['speed'] as num).toDouble();
      final condition = weather['weather'][0]['main'];

      final rain = condition.toString().toLowerCase().contains("rai n");

      // 🌿 Generate Tags
      final tags = generateWeatherTags(weather);

      print("Generated Tags: $tags");

      // 🌿 Fetch diseases using tags
      final diseases = PlantDatabase.getDiseasesByTags(tags);

      setState(() {
        temperature = temp;
        humidity = hum;
        pressure = pres;
        windSpeed = wind;
        isRaining = rain;
        diseaseList = diseases;
        loading = false;
      });
    } catch (e) {
      print("Error: $e");
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Weather-Based Health Risk")),
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Temperature: ${temperature?.toStringAsFixed(1)} °C",
                      ),
                      Text("Humidity: $humidity%"),
                      Text("Pressure: $pressure hPa"),
                      Text("Wind Speed: $windSpeed m/s"),
                      Text("Rain: ${isRaining ? "Yes" : "No"}"),
                    ],
                  ),
                ),

                // 🌿 Disease List
                Expanded(
                  child: diseaseList.isEmpty
                      ? const Center(
                          child: Text("No weather-related health risks found"),
                        )
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
                                subtitle: Text(disease['description'] ?? ""),
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
