import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../config/api_config.dart'; // IMPORT CLEAN CODE

class ProfileUsernameScreen extends StatefulWidget {
  final String currentUsername;
  const ProfileUsernameScreen({super.key, required this.currentUsername});

  @override
  State<ProfileUsernameScreen> createState() => _ProfileUsernameScreenState();
}

class _ProfileUsernameScreenState extends State<ProfileUsernameScreen> {
  final TextEditingController _controller = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _controller.text = widget.currentUsername;
  }

  Future<void> _saveUsername() async {
    if (_controller.text.trim().isEmpty) return;
    setState(() => _isLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final idUser = prefs.getString('id_user') ?? "";

      final response = await http.put(
        Uri.parse('${ApiConfig.baseUrl}/user/$idUser'), // CLEAN CODE
        headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
        body: jsonEncode({'username': _controller.text.trim()}),
      );

      if (response.statusCode == 200) {
        await prefs.setString('username', _controller.text.trim());
        if (mounted) Navigator.pop(context, true); 
      } else {
        _showError("Gagal memperbarui username");
      }
    } catch (e) {
      _showError("Terjadi kesalahan koneksi");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.red));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Color(0xFF1A1A2E)),
        title: const Text('Ubah Username', style: TextStyle(color: Color(0xFF1A1A2E), fontSize: 16, fontWeight: FontWeight.bold)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Username Baru', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF64748B))),
            const SizedBox(height: 8),
            TextField(
              controller: _controller,
              style: const TextStyle(fontWeight: FontWeight.w600),
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                prefixIcon: const Icon(Icons.person_outline_rounded, color: Color(0xFF3B5BDB)),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFFE9ECEF))),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFFE9ECEF))),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFF3B5BDB), width: 2)),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF3B5BDB), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)), elevation: 0),
                onPressed: _isLoading ? null : _saveUsername,
                child: _isLoading 
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Text('Simpan Perubahan', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}