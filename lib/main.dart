import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:logging/logging.dart';
import 'dart:developer' as dev;

// Import widgets
import 'widgets/auth_gate.dart';

Future<void> main() async {
  // Configure logging
  Logger.root.level = Level.INFO;
  Logger.root.onRecord.listen((record) {
    dev.log(
      '${record.level.name}: ${record.message}',
      name: record.loggerName,
      time: record.time,
    );
  });

  // Load environment variables
  await dotenv.load(fileName: ".env");
  String supabaseUrl = dotenv.env['SUPABASE_URL']!;
  String supabaseAnonKey = dotenv.env['SUPABASE_ANON_KEY']!;

  // Initialize Supabase
  await Supabase.initialize(url: supabaseUrl, anonKey: supabaseAnonKey);
  dev.log("Supabase initialized with url: $supabaseUrl");

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My Book Library',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const AuthGate(),
    );
  }
}
