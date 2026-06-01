import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../config/api_config.dart'; // IMPORT CLEAN CODE

class ProfileFaqScreen extends StatefulWidget {
  const ProfileFaqScreen({super.key});

  @override
  State<ProfileFaqScreen> createState() => _ProfileFaqScreenState();
}

class _ProfileFaqScreenState extends State<ProfileFaqScreen> {
  bool _isLoading = true;
  List<dynamic> _faqList = [];

  @override
  void initState() {
    super.initState();
    _fetchFaq();
  }

  Future<void> _fetchFaq() async {
    try {
      final response = await http.get(Uri.parse('${ApiConfig.baseUrl}/pengaturan/faq')); // CLEAN CODE
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success']) {
          setState(() {
            _faqList = data['data'];
          });
        }
      }
    } catch (e) {
      debugPrint('Gagal ambil FAQ: $e');
    } finally {
      setState(() => _isLoading = false);
    }
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
        title: const Text('Bantuan & FAQ', style: TextStyle(color: Color(0xFF1A1A2E), fontSize: 16, fontWeight: FontWeight.bold)),
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator(color: Color(0xFF3B5BDB)))
        : _faqList.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20)]),
                    child: const Icon(Icons.help_outline_rounded, size: 70, color: Color(0xFFCBD5E1)),
                  ),
                  const SizedBox(height: 20),
                  const Text('Belum Ada Bantuan/FAQ', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1A1A2E))),
                  const SizedBox(height: 8),
                  const Text('Daftar pertanyaan dan panduan aplikasi\nakan segera ditambahkan oleh admin.', textAlign: TextAlign.center, style: TextStyle(fontSize: 14, color: Color(0xFF94A3B8), height: 1.5)),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _faqList.length,
              itemBuilder: (context, index) {
                final faq = _faqList[index];
                return Card(
                  elevation: 0,
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14), side: const BorderSide(color: Color(0xFFE9ECEF))),
                  child: ExpansionTile(
                    title: Text(faq['pertanyaan'] ?? 'Pertanyaan', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF1A1A2E))),
                    iconColor: const Color(0xFF3B5BDB),
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        child: Text(faq['jawaban'] ?? '-', style: const TextStyle(color: Color(0xFF64748B), height: 1.5)),
                      )
                    ],
                  ),
                );
              },
            ),
    );
  }
}