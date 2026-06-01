import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../config/api_config.dart'; // IMPORT CLEAN CODE

class ProfileSkScreen extends StatefulWidget {
  const ProfileSkScreen({super.key});

  @override
  State<ProfileSkScreen> createState() => _ProfileSkScreenState();
}

class _ProfileSkScreenState extends State<ProfileSkScreen> {
  bool _isLoading = true;
  String _kontenSk = "";

  @override
  void initState() {
    super.initState();
    _fetchSK();
  }

  Future<void> _fetchSK() async {
    try {
      final response = await http.get(Uri.parse('${ApiConfig.baseUrl}/pengaturan/syarat-ketentuan')); // CLEAN CODE
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] && data['data'] != null) {
          setState(() {
            _kontenSk = data['data']['konten'] ?? ''; 
          });
        }
      }
    } catch (e) {
      debugPrint('Gagal ambil S&K: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kontenSk.isEmpty ? const Color(0xFFF8FAFC) : Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: _kontenSk.isEmpty ? 0 : 1,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Color(0xFF1A1A2E)),
        title: const Text('Syarat & Ketentuan', style: TextStyle(color: Color(0xFF1A1A2E), fontSize: 16, fontWeight: FontWeight.bold)),
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator(color: Color(0xFF3B5BDB)))
        : _kontenSk.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20)]),
                    child: const Icon(Icons.description_outlined, size: 70, color: Color(0xFFCBD5E1)),
                  ),
                  const SizedBox(height: 20),
                  const Text('S&K Belum Tersedia', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1A1A2E))),
                  const SizedBox(height: 8),
                  const Text('Syarat dan ketentuan layanan aplikasi\nakan segera diperbarui oleh admin.', textAlign: TextAlign.center, style: TextStyle(fontSize: 14, color: Color(0xFF94A3B8), height: 1.5)),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Text(
                _kontenSk,
                style: const TextStyle(color: Color(0xFF475569), height: 1.6, fontSize: 14),
              ),
            ),
    );
  }
}