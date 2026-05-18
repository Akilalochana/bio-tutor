import 'package:flutter/material.dart';
import 'package:flutter_gemma/flutter_gemma.dart';
import 'pages/loading_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FlutterGemma.initialize();
  runApp(const BioTutorApp());
}

class BioTutorApp extends StatelessWidget {
  const BioTutorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Bio Tutor',
      theme: ThemeData(
        colorSchemeSeed: Colors.green,
        useMaterial3: true,
      ),
      home: const LoadingScreen(),
    );
  }
}