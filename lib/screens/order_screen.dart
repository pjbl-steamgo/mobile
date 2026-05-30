import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import 'create_order_screen.dart';
import 'order_detail_screen.dart';

class OrderScreen extends StatefulWidget {
  const OrderScreen({super.key});

  @override
  State<OrderScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  bool _isLoading = true;
  List<dynamic> _orderHistory = [];

  @override
  void initState() {
    super.initState();
    _fetchOrderHistory();
  }

  // Fungsi untuk menarik data riwayat pesanan dari Laravel
  Future<void> _fetchOrderHistory() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final idUser = prefs.getString('id_user') ?? "";

      if (idUser.isEmpty) {
        setState(() => _isLoading = false);
        return;
      }

      // Pastikan IP sesuai dengan server Laravel kamu
      final String apiUrl = 'http://192.168.1.14:8000/api/order-history?user_id=$idUser';

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
          setState(() {
            _orderHistory = responseData['data'];
          });
        }
      }
    } catch (e) {
      debugPrint("Gagal memuat riwayat: $e");
    } finally {
      setState(() {
        _isLoading = false;
      });
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
        onRefresh: _fetchOrderHistory,
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
                  onTap: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (_) => const CreateOrderScreen()));
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
    // Ekstrak data dari JSON
    String status = order['status'] ?? 'Booking';
    String namaLayanan = order['layanan']?['nama_layanan'] ?? 'Layanan Cuci';
    
    // Format tanggal sederhana (bisa dipercanggih pakai package intl jika mau)
    String rawDate = order['tanggal'] ?? order['created_at'] ?? '';
    String tanggalTampil = rawDate.length >= 10 ? rawDate.substring(0, 10) : rawDate;

    String kendaraan = order['kendaraan'] ?? '-';
    String platNomor = order['plat_nomor'] ?? '-';
    
    // Format harga
    int totalHarga = order['total_harga'] ?? 0;
    String hargaTampil = 'Rp ${totalHarga.toString()}'; // Bisa ditambahkan titik ribuan nantinya

    return GestureDetector(
      onTap: () {
        // Navigasi ke halaman detail dengan membawa data dinamis
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => OrderDetailScreen(
              serviceName: namaLayanan,
              date: tanggalTampil,
              vehicle: kendaraan,
              plateNumber: platNomor,
              slot: order['no_antrian'] ?? '-',
              price: hargaTampil,
              bookingCode: order['kode_pesanan'] ?? 'STG-0000',
            ),
          ),
        );
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
                  _buildBadge(status),
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
                  _buildActionButton(status),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Penyesuaian Badge Status berdasarkan String dari Laravel
  Widget _buildBadge(String status) {
    if (status == 'Booking' || status == 'Pending') {
      return _badge('Booking', const Color(0xFFFFF3CD), const Color(0xFFB78103));
    } else if (status == 'Menunggu Pembayaran') {
      return _badge('Belum Bayar', const Color(0xFFFFF3CD), const Color(0xFFB78103));
    } else if (status == 'Antri' || status == 'Proses') {
      return _badge('Proses', const Color(0xFFE8F0FE), const Color(0xFF3B5BDB));
    } else if (status == 'Selesai') {
      return _badge('Selesai', const Color(0xFFF1F5F9), const Color(0xFF64748B));
    } else if (status == 'Batal') {
      return _badge('Batal', const Color(0xFFFFEBEE), const Color(0xFFE53935));
    }
    return _badge(status, const Color(0xFFF1F5F9), const Color(0xFF64748B));
  }

  Widget _badge(String label, Color bg, Color fg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
      child: Text(label,
          style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: fg)),
    );
  }

  // Tombol aksi dinamis menyesuaikan status
  Widget _buildActionButton(String status) {
    if (status == 'Antri' || status == 'Proses' || status == 'Booking' || status == 'Menunggu Pembayaran') {
      return _actionBtn('Lacak', const Color(0xFF3B5BDB), null, Colors.white, true);
    } else if (status == 'Selesai') {
      return _actionBtn('Cek', Colors.transparent, const Color(0xFFCBD5E1), const Color(0xFF64748B), false);
    } else if (status == 'Batal') {
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
      child: Text(label,
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: textColor)),
    );
  }
}