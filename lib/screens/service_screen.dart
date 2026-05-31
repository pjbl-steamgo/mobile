import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'service_model.dart';
import 'service_detail_screen.dart';

class ServiceScreen extends StatefulWidget {
  const ServiceScreen({super.key});

  @override
  State<ServiceScreen> createState() => _ServiceScreenState();
}

class _ServiceScreenState extends State<ServiceScreen> {
  bool _isLoading = true;
  List<ServiceModel> _services = [];
  String _errorMessage = ''; // Menyimpan pesan error agar tampil di layar

  @override
  void initState() {
    super.initState();
    _fetchServices();
  }

  // Menarik data layanan dari database Laravel
  Future<void> _fetchServices() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      // Ganti IP jika diperlukan
      final response = await http.get(Uri.parse('http://192.168.1.14:8000/api/layanan'));
      
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        List<dynamic> rawData = [];

        // Logika super-kebal untuk mengekstrak data dari berbagai format JSON Laravel
        if (decoded is List) {
          rawData = decoded; // Jika Laravel langsung mengirim Array [ {...}, {...} ]
        } else if (decoded is Map) {
          if (decoded.containsKey('data')) {
            rawData = decoded['data']; // Jika Laravel mengirim { "data": [...] }
          } else if (decoded.containsKey('layanan')) {
            rawData = decoded['layanan']; 
          } else {
            // Jika formatnya meleset dari standar
            _errorMessage = 'Format data dari server tidak dikenali.';
          }
        }

        if (mounted && _errorMessage.isEmpty) {
          setState(() {
            _services = rawData.map((json) => ServiceModel.fromJson(json)).toList();
          });
        }
      } else {
        // Jika server error (404 Not Found, 500 Server Error, dll)
        if (mounted) {
          setState(() => _errorMessage = 'Gagal memuat data (Error Code: ${response.statusCode})');
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _errorMessage = 'Tidak dapat terhubung ke server Laravel.\nPastikan IP dan API sudah benar.');
      }
      debugPrint('Error fetch API Layanan: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80),
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF3B5BDB), Color(0xFF4C6EF5)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(24),
              bottomRight: Radius.circular(24),
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.local_car_wash_rounded, color: Colors.white, size: 22),
                  ),
                  const SizedBox(width: 14),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Daftar Layanan',
                        style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'Pilih layanan terbaik untuk kendaraanmu',
                        style: TextStyle(color: Colors.white.withOpacity(0.75), fontSize: 11),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _fetchServices,
        color: const Color(0xFF3B5BDB),
        child: _isLoading 
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF3B5BDB)))
          : _errorMessage.isNotEmpty 
            // JIKA TERJADI ERROR, TAMPILKAN PESANNYA DI SINI
            ? ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  SizedBox(height: MediaQuery.of(context).size.height * 0.3),
                  const Icon(Icons.error_outline_rounded, size: 60, color: Colors.redAccent),
                  const SizedBox(height: 16),
                  Text(
                    _errorMessage,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.redAccent, fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                ],
              )
            : _services.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Text('🧼', style: TextStyle(fontSize: 54)), 
                      SizedBox(height: 16),
                      Text('Belum ada layanan tersedia', style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                )
              : ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(16),
                  children: [
                    const Text(
                      'Pilih Layanan',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1A1A2E)),
                    ),
                    const SizedBox(height: 12),
                    ..._services.map((service) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _buildCard(context, service),
                    )),
                    const SizedBox(height: 24),
                  ],
                ),
      ),
    );
  }

  Widget _buildCard(BuildContext context, ServiceModel service) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ServiceDetailScreen(service: service),
          ),
        );
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: const Color(0xFFE9ECEF), width: 0.8),
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(18, 14, 14, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            color: service.iconBg,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(service.iconData, color: service.iconColor, size: 26),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            service.name,
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1A1A2E)),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              service.price,
                              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: service.accentColor),
                            ),
                            Text(
                              service.unit,
                              style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: Text(
                            service.description,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 12, color: Color(0xFF64748B), height: 1.4),
                          ),
                        ),
                        const SizedBox(width: 12),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => ServiceDetailScreen(service: service)),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 8),
                            decoration: BoxDecoration(color: service.accentColor, borderRadius: BorderRadius.circular(20)),
                            child: const Text('Pesan', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              left: 0, top: 0, bottom: 0,
              child: Container(width: 4, color: service.accentColor),
            ),
          ],
        ),
      ),
    );
  }
}