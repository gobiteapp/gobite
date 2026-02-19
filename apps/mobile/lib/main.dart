import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://izkkxdsuvjuuthtcvsvl.supabase.co',
    anonKey: 'vuestra_anon_key',
  );

  runApp(
    const ProviderScope(
      child: GoBiteApp(),
    ),
  );
}

class GoBiteApp extends StatelessWidget {
  const GoBiteApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GoBite',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFFF5C00),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const Scaffold(
        body: Center(
          child: Text('GoBite', style: TextStyle(fontSize: 32)),
        ),
      ),
    );
  }
}