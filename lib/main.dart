import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:developer';

Future<void> main() async {
  await dotenv.load(fileName: ".env");
  String supabaseUrl = dotenv.env['SUPABASE_URL']!;
  String supabaseAnonKey = dotenv.env['SUPABASE_ANON_KEY']!;

  await Supabase.initialize(url: supabaseUrl, anonKey: supabaseAnonKey);
  log("supabase initialized with url: $supabaseUrl");
  runApp(const MyApp());
}

final supabase = Supabase.instance.client;
final myQuery = supabase.from('genres').select();

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(title: 'Instruments', home: HomePage());
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _future = Supabase.instance.client.from('genres').select();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
        future: _future,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final genres = snapshot.data!;
          log("got genres: $genres");
          return ListView.builder(
            itemCount: genres.length,
            itemBuilder: ((context, index) {
              final genre = genres[index];
              return ListTile(title: Text(genre['name']));
            }),
          );
        },
      ),
    );
  }
}
