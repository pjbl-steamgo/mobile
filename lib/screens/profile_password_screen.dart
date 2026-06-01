import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../config/api_config.dart'; // IMPORT CLEAN CODE

class ProfilePasswordScreen extends StatefulWidget {
  const ProfilePasswordScreen({super.key});

  @override
  State<ProfilePasswordScreen> createState() => _ProfilePasswordScreenState();
}

class _ProfilePasswordScreenState extends State<ProfilePasswordScreen> {
  final TextEditingController _newPasswordCtrl = TextEditingController();
  final TextEditingController _confirmPasswordCtrl = TextEditingController();
  
  bool _isLoading = false;
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  Future<void> _updatePassword() async {
    if (_newPasswordCtrl.text.isEmpty || _confirmPasswordCtrl.text.isEmpty) {
      _showError('Kolom kata sandi tidak boleh kosong');
      return;
    }

    if (_newPasswordCtrl.text != _confirmPasswordCtrl.text) {
      _showError('Konfirmasi kata sandi baru tidak cocok');
      return;
    }
    
    if (_newPasswordCtrl.text.length < 6) {
      _showError('Kata sandi baru minimal 6 karakter');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final idUser = prefs.getString('id_user') ?? "";

      final response = await http.put(
        Uri.parse('${ApiConfig.baseUrl}/user/$idUser/password'), // CLEAN CODE
        headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
        body: jsonEncode({
          'password_baru': _newPasswordCtrl.text,
          'password_baru_confirmation': _confirmPasswordCtrl.text,
        }),
      );

      final resData = jsonDecode(response.body);

      if (response.statusCode == 200 && resData['success'] == true) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Kata sandi berhasil diubah!'), backgroundColor: Colors.green));
          Navigator.pop(context);
        }
      } else {
        _showError(resData['message'] ?? 'Gagal mengubah kata sandi');
      }
    } catch (e) {
      _showError('Terjadi kesalahan koneksi');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.red));
  }

  Widget _buildPasswordField(String label, TextEditingController ctrl, bool isObscure, VoidCallback toggleObscure) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF64748B))),
        const SizedBox(height: 8),
        TextField(
          controller: ctrl,
          obscureText: isObscure,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            prefixIcon: const Icon(Icons.lock_outline_rounded, color: Color(0xFFF59F00)),
            suffixIcon: IconButton(
              icon: Icon(isObscure ? Icons.visibility_off : Icons.visibility, color: const Color(0xFFCBD5E1)),
              onPressed: toggleObscure,
            ),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFFE9ECEF))),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFFE9ECEF))),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFF3B5BDB), width: 2)),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
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
        title: const Text('Ubah Kata Sandi', style: TextStyle(color: Color(0xFF1A1A2E), fontSize: 16, fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.only(bottom: 24),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F0FE),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF3B5BDB).withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline_rounded, color: Color(0xFF3B5BDB)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Pastikan kata sandi barumu unik dan memiliki minimal 6 karakter.',
                      style: TextStyle(fontSize: 12, color: const Color(0xFF1A1A2E).withOpacity(0.8), height: 1.4),
                    ),
                  ),
                ],
              ),
            ),
            _buildPasswordField('Kata Sandi Baru', _newPasswordCtrl, _obscureNew, () => setState(() => _obscureNew = !_obscureNew)),
            _buildPasswordField('Konfirmasi Kata Sandi Baru', _confirmPasswordCtrl, _obscureConfirm, () => setState(() => _obscureConfirm = !_obscureConfirm)),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF3B5BDB), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                onPressed: _isLoading ? null : _updatePassword,
                child: _isLoading 
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Text('Simpan Kata Sandi', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}