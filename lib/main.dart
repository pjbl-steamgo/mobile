import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'screens/login_screen.dart'; // Sesuaikan path jika diletakkan di folder berbeda
import 'config/api_service.dart'; // <-- Pastikan path ini sesuai dengan lokasi file api_service.dart Anda

void main() async {
  // 1. Pastikan binding Flutter sudah siap sebelum menjalankan fungsi async
  WidgetsFlutterBinding.ensureInitialized();
  
  // 2. Inisialisasi data format bahasa Indonesia
  await initializeDateFormatting('id_ID', null);

  // 3. Jalankan aplikasinya
  runApp(const MyApp()); // Sesuaikan 'MyApp' dengan nama class utama kamu
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SteamGo',
      debugShowCheckedModeBanner: false,
      
      // ── TAMBAHAN CLEAN CODE (KUNCI NAVIGASI GLOBAL) ──
      navigatorKey: ApiService.navigatorKey, 
      
      // ── TAMBAHAN CLEAN CODE (DAFTAR RUTE) ──
      routes: {
        '/login': (context) => const LoginScreen(),
      },

      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent),
        useMaterial3: true,
      ),
      
      // Arahkan halaman pertama ke LoginScreen
      home: const LoginScreen(), 
    );
  }
}