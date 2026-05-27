import 'package:flutter/material.dart';
import 'screens/login_screen.dart'; // Sesuaikan path jika diletakkan di folder berbeda

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SteamGo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent),
        useMaterial3: true,
      ),
      // Arahkan halaman pertama ke LoginScreen
      home: const LoginScreen(), 
    );
  }
}