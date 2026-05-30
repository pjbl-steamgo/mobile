import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'chat_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Variabel untuk profil user
  String _username = "Memuat...";
  String _userId = "";
  
  // Variabel state untuk antrian
  bool _isLoadingOrder = true;
  Map<String, dynamic>? _activeOrder;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  // 1. Fungsi mengambil data user dari memori lokal
  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final idUser = prefs.getString('id_user') ?? "";
    final username = prefs.getString('username') ?? "Pelanggan";

    setState(() {
      _username = username;
      _userId = idUser;
    });

    if (idUser.isNotEmpty) {
      _fetchActiveOrder(idUser);
    } else {
      setState(() {
        _isLoadingOrder = false;
      });
    }
  }

  // 2. Fungsi menembak API Laravel untuk pesanan terakhir user
  Future<void> _fetchActiveOrder(String userId) async {
    // Sesuaikan dengan IP Laravel kamu saat ini
    final String apiUrl = 'http://192.168.1.14:8000/api/active-order?user_id=$userId';

    try {
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
            _activeOrder = responseData['data'];
          });
        }
      }
    } catch (e) {
      debugPrint("Gagal memuat data antrian: $e");
    } finally {
      setState(() {
        _isLoadingOrder = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4FF),
      // ══════════════════════════════════════════
      // APP BAR (Menampilkan Nama Dinamis)
      // ══════════════════════════════════════════
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
              bottomLeft: Radius.circular(28),
              bottomRight: Radius.circular(28),
            ),
          ),
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.25),
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: const Icon(Icons.person_rounded, color: Colors.white, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Selamat datang kembali,',
                          style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 12),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '$_username 👋',
                          style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ChatScreen())),
                    child: Container(
                      width: 40, height: 40,
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(color: Colors.white.withOpacity(0.18), shape: BoxShape.circle),
                      child: const Icon(Icons.chat_bubble_outline_rounded, color: Colors.white, size: 20),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      
      // ══════════════════════════════════════════
      // BODY DENGAN FITUR PULL-TO-REFRESH
      // ══════════════════════════════════════════
      body: RefreshIndicator(
        onRefresh: () => _fetchActiveOrder(_userId),
        color: const Color(0xFF3B5BDB),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              
              // ── CARD ANTRIAN DINAMIS ──
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _buildDynamicQueueCard(),
              ),

              const SizedBox(height: 20),

              // ── PILIH LAYANAN ──
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Pilih Layanan', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF1A1A2E))),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        _buildServiceCard(iconData: Icons.water_drop_rounded, iconColor: const Color(0xFF3B5BDB), iconBg: const Color(0xFFE3F2FD), label: 'Steam Biasa', price: 'Rp 20.000'),
                        const SizedBox(width: 10),
                        _buildServiceCard(iconData: Icons.ac_unit_rounded, iconColor: const Color(0xFF00B4D8), iconBg: const Color(0xFFE0F7FA), label: 'Snow Wash', price: 'Rp 30.000'),
                        const SizedBox(width: 10),
                        _buildServiceCard(iconData: Icons.auto_awesome_rounded, iconColor: const Color(0xFFF59F00), iconBg: const Color(0xFFFFF3CD), label: 'Detailing', price: 'Rp 120.000'),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // ── PROMO BANNER ──
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [Color(0xFFF9A825), Color(0xFFFB8C00)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Snow Wash Gratis\nUntuk Member Baru!', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold, height: 1.3)),
                            const SizedBox(height: 6),
                            Text('Berlaku s/d 28 Feb 2026', style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 11)),
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
                              child: const Text('Klaim Sekarang', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFFE65100))),
                            ),
                          ],
                        ),
                      ),
                      const Text('🎁', style: TextStyle(fontSize: 48)),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // ── JADWAL HARI INI ──
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Jadwal Hari Ini', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF1A1A2E))),
                    const SizedBox(height: 12),
                    _buildScheduleCard(
                      time: '08.00 – 09.00',
                      status: 'Selesai',
                      state: _SlotState.done,
                      chips: const [_SlotChip(icon: Icons.two_wheeler_rounded, label: '4 Slot - Penuh'), _SlotChip(icon: Icons.directions_car_rounded, label: '1/2 Slot Terisi')],
                    ),
                    const SizedBox(height: 8),
                    _buildScheduleCard(
                      time: '09.00 – 10.00',
                      status: 'Proses',
                      state: _SlotState.active,
                      chips: const [_SlotChip(icon: Icons.two_wheeler_rounded, label: '4 Slot - Penuh'), _SlotChip(icon: Icons.directions_car_rounded, label: '2 Slot - Penuh')],
                    ),
                    const SizedBox(height: 8),
                    _buildScheduleCard(
                      time: '10.00 – 11.00',
                      status: 'Menunggu',
                      state: _SlotState.waiting,
                      chips: const [_SlotChip(icon: Icons.two_wheeler_rounded, label: '3 Slot Terisi'), _SlotChip(icon: Icons.directions_car_rounded, label: '1 Slot Terisi')],
                    ),
                    const SizedBox(height: 8),
                    _buildScheduleCard(
                      time: '11.00 – 12.00',
                      status: 'Tersedia',
                      state: _SlotState.available,
                      chips: const [_SlotChip(icon: Icons.two_wheeler_rounded, label: '4 Slot Tersedia'), _SlotChip(icon: Icons.directions_car_rounded, label: '2 Slot Tersedia')],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════
  // WIDGET CARD ANTRIAN (Di-generate Berdasarkan Database)
  // ══════════════════════════════════════════════════════════
  Widget _buildDynamicQueueCard() {
    // 1. State Loading
    if (_isLoadingOrder) {
      return Container(
        height: 90,
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
        child: const Center(child: CircularProgressIndicator(color: Color(0xFF3B5BDB))),
      );
    }

    // 2. State Kosong (Belum ada pesanan)
    if (_activeOrder == null) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10)],
        ),
        child: Row(
          children: [
            const Text('📭', style: TextStyle(fontSize: 32)),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Status Belum Tersedia', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1A1A2E))),
                  const SizedBox(height: 4),
                  Text('Kamu belum memesan jadwal cuci hari ini. Yuk pesan sekarang!', style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
                ],
              ),
            ),
          ],
        ),
      );
    }

    // 3. Ekstrak data dari Backend
    String status = _activeOrder!['status'] ?? 'Booking';
    String kodePesanan = _activeOrder!['kode_pesanan'] ?? '-';
    String kendaraan = _activeOrder!['kendaraan'] ?? 'Kendaraan';
    String namaLayanan = _activeOrder!['layanan']?['nama_layanan'] ?? 'Steam Cuci';
    String noAntrian = _activeOrder!['no_antrian'] ?? '00';
    if (noAntrian == '-' || noAntrian.isEmpty) noAntrian = '--';

    // 4. Atur tampilan berdasarkan status
    String badgeText = "Booking";
    Color badgeBg = const Color(0xFFE8F5E9);
    Color badgeTextColor = const Color(0xFF2E7D32);
    String subtitleText = "Pesanan terdaftar di sistem";
    String estimasiText = "Menunggu info admin";

    if (status == 'Booking' || status == 'Pending') {
      badgeText = "Baru Di-booking";
      badgeBg = const Color(0xFFE3F2FD);
      badgeTextColor = const Color(0xFF1565C0);
      subtitleText = "$namaLayanan • $kendaraan";
      estimasiText = "Menunggu persetujuan Admin";
    } else if (status == 'Menunggu Pembayaran') {
      badgeText = "Belum Bayar";
      badgeBg = const Color(0xFFFFF3CD);
      badgeTextColor = const Color(0xFFB78103);
      subtitleText = "Kode: $kodePesanan";
      estimasiText = "Silakan lengkapi pembayaran Anda";
    } else if (status == 'Antri') {
      badgeText = "Dalam Antrean";
      badgeBg = const Color(0xFFE8F5E9);
      badgeTextColor = const Color(0xFF2E7D32);
      subtitleText = "$namaLayanan • $kendaraan";
      estimasiText = "Estimasi siap dalam ±25 menit";
    } else if (status == 'Proses') {
      badgeText = "Sedang Diproses";
      badgeBg = const Color(0xFFE0F7FA);
      badgeTextColor = const Color(0xFF006064);
      subtitleText = "Kendaraan sedang dicuci tim";
      estimasiText = "Harap tunggu sebentar...";
    } else if (status == 'Selesai') {
      badgeText = "Cucian Selesai";
      badgeBg = const Color(0xFFF3E5F5);
      badgeTextColor = const Color(0xFF6A1B9A);
      subtitleText = "Kelar! Kendaraan kinclong";
      estimasiText = "Silakan lakukan pengambilan";
    } else if (status == 'Batal') {
      badgeText = "Dibatalkan";
      badgeBg = const Color(0xFFFFEBEE);
      badgeTextColor = const Color(0xFFC62828);
      subtitleText = "Booking telah di-cancel";
      estimasiText = "Hubungi admin untuk info lanjut";
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.07), blurRadius: 16, offset: const Offset(0, 4))],
      ),
      child: Row(
        children: [
          // Nomor Antrian
          Text(noAntrian, style: const TextStyle(fontSize: 38, fontWeight: FontWeight.w900, color: Color(0xFF3B5BDB), height: 1)),
          const SizedBox(width: 14),
          
          // Info Detail
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(subtitleText, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF1A1A2E))),
                const SizedBox(height: 5),
                Row(
                  children: [
                    const Icon(Icons.access_time_rounded, size: 13, color: Color(0xFF94A3B8)),
                    const SizedBox(width: 4),
                    Expanded(child: Text(estimasiText, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8)))),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),

          // Badge Status
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(color: badgeBg, borderRadius: BorderRadius.circular(20)),
            child: Text(badgeText, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: badgeTextColor)),
          ),
        ],
      ),
    );
  }

  // Helper: Card Layanan
  Widget _buildServiceCard({required IconData iconData, required Color iconColor, required Color iconBg, required String label, required String price}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: const Color(0xFFE8ECFF))),
        child: Column(
          children: [
            Container(
              width: 46, height: 46,
              decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(12)),
              child: Icon(iconData, color: iconColor, size: 22),
            ),
            const SizedBox(height: 8),
            Text(label, textAlign: TextAlign.center, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF1A1A2E))),
            const SizedBox(height: 4),
            const Text('Mulai dari', style: TextStyle(fontSize: 9, color: Color(0xFF94A3B8))),
            Text(price, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF3B5BDB))),
          ],
        ),
      ),
    );
  }

  // Helper: Card Jadwal
  Widget _buildScheduleCard({required String time, required String status, required _SlotState state, required List<_SlotChip> chips}) {
    Color bgColor, timeColor, statusColor, chipBg, chipTextColor;
    Widget trailingIcon;

    switch (state) {
      case _SlotState.done:
        bgColor = const Color(0xFFF8F9FA); timeColor = const Color(0xFF1A1A2E); statusColor = const Color(0xFF94A3B8); chipBg = const Color(0xFFE2E8F0); chipTextColor = const Color(0xFF64748B);
        trailingIcon = Container(width: 30, height: 30, decoration: const BoxDecoration(color: Color(0xFFE8F5E9), shape: BoxShape.circle), child: const Icon(Icons.check_rounded, size: 16, color: Color(0xFF2E7D32)));
        break;
      case _SlotState.active:
        bgColor = const Color(0xFF4C6EF5); timeColor = Colors.white; statusColor = Colors.white70; chipBg = Colors.white.withOpacity(0.25); chipTextColor = Colors.white;
        trailingIcon = Container(width: 30, height: 30, decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), shape: BoxShape.circle), child: Icon(Icons.more_horiz_rounded, size: 16, color: Colors.white.withOpacity(0.9)));
        break;
      case _SlotState.waiting:
        bgColor = Colors.white; timeColor = const Color(0xFF1A1A2E); statusColor = const Color(0xFFF59F00); chipBg = const Color(0xFFFFF3CD); chipTextColor = const Color(0xFF92400E);
        trailingIcon = Container(width: 30, height: 30, decoration: const BoxDecoration(color: Color(0xFFFFF3CD), shape: BoxShape.circle), child: const Icon(Icons.schedule_rounded, size: 16, color: Color(0xFFF59F00)));
        break;
      case _SlotState.available:
        bgColor = Colors.white; timeColor = const Color(0xFF1A1A2E); statusColor = const Color(0xFF4CAF50); chipBg = const Color(0xFFE8F5E9); chipTextColor = const Color(0xFF2E7D32);
        trailingIcon = Container(width: 30, height: 30, decoration: const BoxDecoration(color: Color(0xFFE8F5E9), shape: BoxShape.circle), child: const Icon(Icons.add_rounded, size: 18, color: Color(0xFF2E7D32)));
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(14), border: state != _SlotState.active ? Border.all(color: const Color(0xFFE9ECEF)) : null),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(time, style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: timeColor)),
                    const SizedBox(width: 6),
                    Text('| $status', style: TextStyle(fontSize: 12, color: statusColor)),
                  ],
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6, runSpacing: 6,
                  children: chips.map((c) => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: chipBg, borderRadius: BorderRadius.circular(20)),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(c.icon, size: 12, color: chipTextColor),
                        const SizedBox(width: 4),
                        Text(c.label, style: TextStyle(fontSize: 10, color: chipTextColor, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  )).toList(),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          trailingIcon,
        ],
      ),
    );
  }
}

// Enumerasi dan class pembantu untuk Jadwal
enum _SlotState { done, active, waiting, available }
class _SlotChip {
  final IconData icon;
  final String label;
  const _SlotChip({required this.icon, required this.label});
}