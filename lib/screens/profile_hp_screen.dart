import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../config/api_config.dart'; // IMPORT CLEAN CODE

class ProfileHpScreen extends StatefulWidget {
  final String currentHp;
  const ProfileHpScreen({super.key, required this.currentHp});

  @override
  State<ProfileHpScreen> createState() => _ProfileHpScreenState();
}

class _ProfileHpScreenState extends State<ProfileHpScreen> {
  final TextEditingController _controller = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _controller.text = widget.currentHp == "-" ? "" : widget.currentHp;
  }

  Future<void> _saveHp() async {
    if (_controller.text.trim().isEmpty) return;
    setState(() => _isLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final idUser = prefs.getString('id_user') ?? "";

      final response = await http.put(
        Uri.parse('${ApiConfig.baseUrl}/user/$idUser'), // CLEAN CODE
        headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
        body: jsonEncode({'no_hp': _controller.text.trim()}),
      );

      if (response.statusCode == 200) {
        if (mounted) Navigator.pop(context, true);
      } else {
        _showError("Gagal memperbarui nomor telepon");
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
        title: const Text('Ubah No Telepon', style: TextStyle(color: Color(0xFF1A1A2E), fontSize: 16, fontWeight: FontWeight.bold)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Nomor Telepon (WhatsApp)', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF64748B))),
            const SizedBox(height: 8),
            TextField(
              controller: _controller,
              keyboardType: TextInputType.phone,
              style: const TextStyle(fontWeight: FontWeight.w600),
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                prefixIcon: const Icon(Icons.phone_outlined, color: Color(0xFF00B4D8)),
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
                onPressed: _isLoading ? null : _saveHp,
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