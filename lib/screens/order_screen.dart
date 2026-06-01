import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:async'; // WAJIB UNTUK TIMER AUTO REFRESH
import 'package:http/http.dart' as http;

import 'create_order_screen.dart';
import 'order_detail_screen.dart';
// Import layar-layar baru untuk alur booking & pembayaran
import 'booking_waiting_screen.dart';
import 'payment_screen.dart';
import 'payment_waiting_screen.dart';

class OrderScreen extends StatefulWidget {
  const OrderScreen({super.key});

  @override
  State<OrderScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  bool _isLoading = true;
  List<dynamic> _orderHistory = [];
  Timer? _pollingTimer; // Variabel untuk Auto-Refresh

  @override
  void initState() {
    super.initState();
    _fetchOrderHistory(); // Tarik data pertama kali (dengan loading)
    
    // ── LOGIKA AUTO REFRESH SETIAP 5 DETIK ──
    _pollingTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      _fetchOrderHistory(isSilent: true); // Tarik data diam-diam (tanpa loading)
    });
  }

  @override
  void dispose() {
    _pollingTimer?.cancel(); // Matikan timer saat pindah menu agar tidak bocor memori
    super.dispose();
  }

  // Fungsi untuk menarik data riwayat pesanan dari Laravel
  Future<void> _fetchOrderHistory({bool isSilent = false}) async {
    if (!isSilent && mounted) {
      setState(() {
        _isLoading = true;
      });
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      final idUser = prefs.getString('id_user') ?? "";

      if (idUser.isEmpty) {
        if (!isSilent && mounted) setState(() => _isLoading = false);
        return;
      }

      // Pastikan IP sesuai dengan server Laravel kamu
      final String apiUrl = 'http://192.168.100.36:8000/api/order-history?user_id=$idUser';

      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['success'] == true) {
          if (mounted) {
            setState(() {
              _orderHistory = responseData['data'];
            });
          }
        }
      }
    } catch (e) {
      debugPrint("Gagal memuat riwayat: $e");
    } finally {
      if (!isSilent && mounted) {
        setState(() {
          _isLoading = false;
        });
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
                    child: const Icon(
                      Icons.receipt_long_rounded,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Pesanan',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Riwayat & status pesananmu',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.75),
                          fontSize: 11,
                        ),
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
        onRefresh: () => _fetchOrderHistory(isSilent: false),
        color: const Color(0xFF3B5BDB),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          children: [
            // ── Header riwayat + tombol tambah ──
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Riwayat Transaksi',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF1A1A2E))),
                GestureDetector(
                  onTap: () async {
                    // Tunggu user kembali dari layar create order, lalu refresh datanya
                    await Navigator.push(context,
                        MaterialPageRoute(builder: (_) => const CreateOrderScreen()));
                    _fetchOrderHistory(isSilent: true);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F5E9),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFF4CAF50)),
                    ),
                    child: const Text('Tambah Pesanan',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF2E7D32))),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // ── Daftar pesanan Dinamis ──
            if (_isLoading)
              const Padding(
                padding: EdgeInsets.only(top: 80),
                child: Center(child: CircularProgressIndicator(color: Color(0xFF3B5BDB))),
              )
            else if (_orderHistory.isEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 60),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Text('📭', style: TextStyle(fontSize: 54)),
                      SizedBox(height: 16),
                      Text(
                        'Kamu belum mempunyai riwayat transaksi,\nYuk pesan sekarang!',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14, 
                          fontWeight: FontWeight.w500, 
                          color: Color(0xFF94A3B8), 
                          height: 1.5
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              ..._orderHistory.map((order) => _buildOrderCard(context, order)),
          ],
        ),
      ),
    );
  }

  // Widget Pembuat Kartu Pesanan Dinamis
  Widget _buildOrderCard(BuildContext context, Map<String, dynamic> order) {
    String statusPesanan = order['status']?.toString() ?? 'Belum Dikonfirmasi';
    String orderId = order['_id']?.toString() ?? order['id']?.toString() ?? '';
    
    var dataLayanan = order['layanan'];
    String namaLayanan = dataLayanan?['nama_layanan']?.toString() ?? 'Layanan Cuci';
    
    String tanggalTampil = order['tanggal']?.toString() ?? order['created_at']?.toString() ?? '-';
    String kendaraan = order['kendaraan']?.toString() ?? '-';
    String platNomor = order['plat_nomor']?.toString() ?? '-';
    String hargaTampil = 'Rp ${order['total_harga']?.toString() ?? 0}';
    String bookingCode = order['kode_pesanan']?.toString() ?? '-';

    String estimasiLayanan = '-';
    if (dataLayanan != null) {
      var estDb = dataLayanan['estimasi_waktu'] ?? dataLayanan['estimasi'] ?? dataLayanan['waktu'] ?? dataLayanan['durasi'] ?? order['estimasi_waktu'];
      if (estDb != null) {
        String estText = estDb.toString();
        if (estText.toLowerCase().contains('menit') || estText.toLowerCase().contains('jam')) {
          estimasiLayanan = estText;
        } else {
          estimasiLayanan = '± $estText Menit';
        }
      } else {
        estimasiLayanan = 'Belum ada estimasi';
      }
    }

    return GestureDetector(
      onTap: () async {
        if (statusPesanan == 'Belum Dikonfirmasi') {
          await Navigator.push(context, MaterialPageRoute(builder: (_) => BookingWaitingScreen(
            orderId: orderId, serviceName: namaLayanan, date: tanggalTampil,
            vehicle: kendaraan, plateNumber: platNomor, price: hargaTampil, bookingCode: bookingCode,
          )));
        } 
        else if (statusPesanan == 'Belum Bayar') {
          await Navigator.push(context, MaterialPageRoute(builder: (_) => PaymentScreen(
            orderId: orderId, serviceName: namaLayanan, date: tanggalTampil,
            vehicle: kendaraan, plateNumber: platNomor, price: hargaTampil, bookingCode: bookingCode,
          )));
        } 
        else if (statusPesanan == 'Sedang Diverifikasi') {
          await Navigator.push(context, MaterialPageRoute(builder: (_) => PaymentWaitingScreen(
            orderId: orderId, serviceName: namaLayanan, date: tanggalTampil,
            vehicle: kendaraan, plateNumber: platNomor, price: hargaTampil, bookingCode: bookingCode,
          )));
        } 
        else {
          await Navigator.push(context, MaterialPageRoute(builder: (_) => OrderDetailScreen(
            orderId: orderId, 
            serviceName: namaLayanan, 
            date: tanggalTampil, 
            vehicle: kendaraan,
            plateNumber: platNomor, 
            slot: statusPesanan, 
            price: hargaTampil, 
            bookingCode: bookingCode,
            estimasiWaktu: estimasiLayanan, 
          )));
        }
        // Refresh secara cepat (diam-diam) tanpa memunculkan loading spinner saat kembali
        _fetchOrderHistory(isSilent: true);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE9ECEF), width: 0.8),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8, offset: const Offset(0, 2))
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Baris 1: nama + badge
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(namaLayanan,
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1A1A2E))),
                        const SizedBox(height: 3),
                        Text(tanggalTampil,
                            style: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8))),
                      ],
                    ),
                  ),
                  _buildBadge(statusPesanan),
                ],
              ),

              const SizedBox(height: 10),
              const Divider(height: 1, color: Color(0xFFF1F5F9)),
              const SizedBox(height: 10),

              // Baris 2: kendaraan + tombol aksi
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.two_wheeler_rounded, size: 14, color: Color(0xFF64748B)),
                            const SizedBox(width: 6),
                            Text(kendaraan,
                                style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 5),
                              child: Text('•', style: TextStyle(fontSize: 10, color: Color(0xFF94A3B8))),
                            ),
                            Text(platNomor,
                                style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                          ],
                        ),
                        const SizedBox(height: 5),
                        Text(hargaTampil,
                            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF1A1A2E))),
                      ],
                    ),
                  ),
                  _buildActionButton(statusPesanan),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Penyesuaian Badge Status
  Widget _buildBadge(String status) {
    if (status == 'Belum Dikonfirmasi') return _badge('Tunggu Admin', const Color(0xFFFFF3CD), const Color(0xFFB78103));
    if (status == 'Belum Bayar') return _badge('Belum Bayar', const Color(0xFFFFE0B2), const Color(0xFFE65100)); 
    if (status == 'Sedang Diverifikasi') return _badge('Verifikasi', const Color(0xFFE0E7FF), const Color(0xFF3B5BDB));
    if (status == 'Antri') return _badge('Antri', const Color(0xFFE8F0FE), const Color(0xFF3B5BDB));
    if (status == 'Proses') return _badge('Proses', const Color(0xFFE0F7FA), const Color(0xFF006064)); // Warna lebih tua untuk Proses
    if (status == 'Selesai') return _badge('Selesai', const Color(0xFFE8F5E9), const Color(0xFF2E7D32));
    if (status == 'Batal' || status == 'Dihapus') return _badge('Batal', const Color(0xFFFFEBEE), const Color(0xFFE53935));
    return _badge(status, const Color(0xFFF1F5F9), const Color(0xFF64748B));
  }

  Widget _badge(String label, Color bg, Color fg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
      child: Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: fg)),
    );
  }

  // Tombol aksi dinamis menyesuaikan status
  Widget _buildActionButton(String status) {
    if (status == 'Belum Dikonfirmasi' || status == 'Belum Bayar' || status == 'Sedang Diverifikasi') {
      return _actionBtn('Lanjut', const Color(0xFF3B5BDB), null, Colors.white, true);
    } else if (status == 'Antri' || status == 'Proses') {
      return _actionBtn('Lacak', const Color(0xFF3B5BDB), null, Colors.white, true);
    } else if (status == 'Selesai') {
      return _actionBtn('Cek', Colors.transparent, const Color(0xFFCBD5E1), const Color(0xFF64748B), false);
    } else if (status == 'Batal' || status == 'Dihapus') {
      return _actionBtn('Cek', Colors.transparent, const Color(0xFFE53935), const Color(0xFFE53935), false);
    }
    return _actionBtn('Detail', Colors.transparent, const Color(0xFFCBD5E1), const Color(0xFF64748B), false);
  }

  Widget _actionBtn(String label, Color bg, Color? borderColor, Color textColor, bool solid) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 7),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: borderColor != null ? Border.all(color: borderColor) : null,
      ),
      child: Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: textColor)),
    );
  }
}