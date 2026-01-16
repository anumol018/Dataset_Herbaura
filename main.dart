import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;
import 'package:flutter/foundation.dart';
import 'package:image_cropper/image_cropper.dart';

import 'plant_classifier.dart';
import 'services/plant_database.dart'; // ⭐ ADDED

void main() async { // ⭐ CHANGED
  WidgetsFlutterBinding.ensureInitialized(); // ⭐ ADDED
  await PlantDatabase.init(); // ⭐ ADDED
  runApp(const MyApp());
}

/* ================= APP ROOT ================= */

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      /// 🌿 GLOBAL THEME (Ayurveda + Modern)
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFF6FBF7),
        primaryColor: const Color(0xFF4F8A5B),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF4F8A5B),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF4F8A5B),
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
        ),
        textTheme: const TextTheme(
          headlineLarge: TextStyle(
            color: Color(0xFF4A3B2A),
            fontWeight: FontWeight.bold,
          ),
          bodyMedium: TextStyle(
            color: Color(0xFF4A3B2A),
          ),
        ),
      ),

      home: const WelcomeScreen(),
    );
  }
}

/* ================= WELCOME SCREEN ================= */

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fade;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();

    _controller =
        AnimationController(vsync: this, duration: const Duration(seconds: 3));
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _scale = Tween(begin: 0.95, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _controller.forward();

    Future.delayed(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        _fadeRoute(const MainScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2E2B6),
      body: FadeTransition(
        opacity: _fade,
        child: ScaleTransition(
          scale: _scale,
          child: Stack(
            children: [
              Center(
                child: Container(
                  width: 260,
                  height: 260,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFF4F8A5B).withOpacity(0.25),
                      width: 2,
                    ),
                  ),
                ),
              ),
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.eco, size: 90, color: Color(0xFF4F8A5B)),
                    SizedBox(height: 24),
                    Text(
                      "HerbAura",
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF4A3B2A),
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      "Ancient Wisdom • Modern Intelligence",
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF6B5A45),
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

/* ================= MAIN SCREEN ================= */

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int index = 0; 

  final pages = const [
    HomePage(),
    CameraPage(),
    WellnessPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[index],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: index,
        selectedItemColor: const Color(0xFF4F8A5B),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.camera_alt), label: "Scan"),
          BottomNavigationBarItem(
              icon: Icon(Icons.self_improvement), label: "Wellness"),
        ],
        onTap: (i) => setState(() => index = i),
      ),
    );
  }
}

/* ================= CAMERA PAGE ================= */

class CameraPage extends StatefulWidget {
  const CameraPage({super.key});

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  File? image;
  bool loading = false;

  Map<String, dynamic>? result;
  Map<String, dynamic>? plantInfo; // ⭐ ADDED

  final picker = ImagePicker();
  final classifier = PlantClassifier();

  @override
  void initState() {
    super.initState();
    classifier.loadModel();
  }

  Future<void> scan(bool gallery) async {
    final picked = await picker.pickImage(
      source: gallery ? ImageSource.gallery : ImageSource.camera,
    );
    if (picked == null) return;

    final cropped = await ImageCropper().cropImage(
      sourcePath: picked.path,
      uiSettings: [AndroidUiSettings(toolbarTitle: "Crop Image")],
    );
    if (cropped == null) return;

    setState(() {
      image = File(cropped.path);
      loading = true;
    });

    final decoded = img.decodeImage(await image!.readAsBytes())!;
    final prediction =
        await compute(_runPrediction, {'classifier': classifier, 'image': decoded});

    final dbData =
        PlantDatabase.getPlantInfo(prediction['result']); // ⭐ ADDED

    setState(() {
      result = prediction;
      plantInfo = dbData; // ⭐ ADDED
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Identify Plant")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            if (image != null) Image.file(image!, height: 220),
            const SizedBox(height: 20),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                    onPressed: () => scan(false),
                    child: const Text("Camera")),
                ElevatedButton(
                    onPressed: () => scan(true),
                    child: const Text("Gallery")),
              ],
            ),

            const SizedBox(height: 20),
            if (loading) const CircularProgressIndicator(),

            if (result != null) ...[
              Text(
                result!['result'],
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              Text(
                "Confidence: ${(result!['confidence'] * 100).toStringAsFixed(2)}%",
              ),
            ],

            if (plantInfo != null) ...[
              const SizedBox(height: 16),
              Text(
                plantInfo!['plant']['scientific_name'],
                style: const TextStyle(fontStyle: FontStyle.italic),
              ),
              const SizedBox(height: 8),
              Text(plantInfo!['plant']['description']),
            ],
          ],
        ),
      ),
    );
  }
}

/* ================= OTHER PAGES (UNCHANGED) ================= */

class HomePage extends StatelessWidget {
  const HomePage({super.key});
  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Center(child: Text("Home")));
}

class WellnessPage extends StatelessWidget {
  const WellnessPage({super.key});
  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Center(child: Text("Wellness")));
}

/* ================= ROUTES ================= */

Route _fadeRoute(Widget page) {
  return PageRouteBuilder(
    pageBuilder: (_, __, ___) => page,
    transitionsBuilder: (_, animation, __, child) =>
        FadeTransition(opacity: animation, child: child),
  );
}

/* ================= BACKGROUND ================= */

Map<String, dynamic> _runPrediction(Map<String, dynamic> args) {
  return args['classifier'].predict(args['image']);
}
