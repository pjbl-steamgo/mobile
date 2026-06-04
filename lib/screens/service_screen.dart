import 'package:flutter/material.dart';
import 'dart:convert';

import '../config/api_service.dart'; // ── IMPORT CLEAN CODE API ──
import 'service_model.dart';
import 'service_detail_screen.dart';
import 'create_order_screen.dart'; // ── IMPORT DITAMBAHKAN ──

class ServiceScreen extends StatefulWidget {
  const ServiceScreen({super.key});

  @override
  State<ServiceScreen> createState() => _ServiceScreenState();
}

class _ServiceScreenState extends State<ServiceScreen> {
  bool _isLoading = true;
  List<ServiceModel> _services = [];
  String _errorMessage = ''; 

  @override
  void initState() {
    super.initState();
    _fetchServices();
  }

  // ── CLEAN CODE: MENGAMBIL LAYANAN ──
  Future<void> _fetchServices() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final response = await ApiService.get('/layanan');
      
      // Jika response == null, berarti ada error 401 dan ApiService sudah melempar user ke halaman Login
      if (response != null && response.statusCode == 200) {
        try {
          final decoded = jsonDecode(response.body);
          List<dynamic> rawData = [];

          if (decoded is List) {
            rawData = decoded; 
          } else if (decoded is Map) {
            if (decoded.containsKey('data')) {
              rawData = decoded['data']; 
            } else if (decoded.containsKey('layanan')) {
              rawData = decoded['layanan']; 
            } else {
              if (mounted) setState(() => _errorMessage = 'Format data tidak dikenali.');
              return;
            }
          }

          if (mounted) {
            setState(() {
              _services = rawData.map((json) => ServiceModel.fromJson(json)).toList();
            });
          }
        } catch (e) {
          if (mounted) setState(() => _errorMessage = 'Gagal memproses data dari server.');
        }
      } 
      // JIKA ERROR LAIN (Misal 500 Server Error)
      else if (response != null) {
        if (mounted) {
          setState(() => _errorMessage = 'Gagal memuat data (Error: ${response.statusCode})');
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _errorMessage = 'Gagal terhubung ke server.\nPastikan koneksi internet stabil.');
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
            // ── PERUBAHAN WARNA BACKGROUND APP BAR ──
            gradient: LinearGradient(
              colors: [Color(0xFF1A237E), Color(0xFF3B5BDB)],
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
                    // ── PERUBAHAN UI LOGO LAYANAN ──
                    child: const Icon(Icons.grid_view_rounded, color: Colors.white, size: 22),
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
                            // ── PERBAIKAN: Arahkan ke CreateOrderScreen dan lempar parameternya ──
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => CreateOrderScreen(
                                  preselectedServiceId: service.id,
                                  preselectedCategory: service.category,
                                ),
                              ),
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