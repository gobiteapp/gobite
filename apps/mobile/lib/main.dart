import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'features/auth/auth_screen.dart';
import 'features/map/map_screen.dart';
import 'core/services/api_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://izkkxdsuvjuuthtcvsvl.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Iml6a2t4ZHN1dmp1dXRodGN2c3ZsIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzE1MTMzNDEsImV4cCI6MjA4NzA4OTM0MX0.ROkD_1DJhNy_ZPLSEZsAHMMMGn2VHkj8XOVj2AcDago',
  );

  runApp(
    const ProviderScope(
      child: GoBiteApp(),
    ),
  );
}

class GoBiteApp extends StatefulWidget {
  const GoBiteApp({super.key});

  @override
  State<GoBiteApp> createState() => _GoBiteAppState();
}

class _GoBiteAppState extends State<GoBiteApp> {
  final _supabase = Supabase.instance.client;

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
      home: StreamBuilder<AuthState>(
        stream: _supabase.auth.onAuthStateChange,
builder: (context, snapshot) {
  if (snapshot.hasData) {
    final event = snapshot.data!.event;
    final session = snapshot.data!.session;
    if (session != null) {
      if (event == AuthChangeEvent.signedIn) {
        // Sincronizar usuario con nuestro backend
        final api = ApiService();
        api.syncUser(session.user);
      }
      return const MapScreen();
    }
  }
  return const AuthScreen();
},
      ),
    );
  }
}