import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC), // Latar belakang abu-abu sangat muda
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            
            // ==========================================
            // HEADER UTAMA DENGAN EFEK GANTUNG
            // ==========================================
            Stack(
              clipBehavior: Clip.none, 
              children: [
                // 1. KOTAK BANNER BIRU UTAMA
                Container(
                  width: double.infinity,
                  height: 225, 
                  decoration: const BoxDecoration(
                    color: Colors.blueAccent,
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(24),
                      bottomRight: Radius.circular(24),
                    ),
                  ),
                  child: SafeArea(
                    bottom: false,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // BARIS 1: Foto Profil, Detail Lokasi & Tombol Notifikasi
                          Row(
                            children: [
                              Container(
                                width: 42,
                                height: 42,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.white, width: 2),
                                  image: const DecorationImage(
                                    image: AssetImage('assets/images/logo.png'), 
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Lokasi Anda',
                                    style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 11, fontWeight: FontWeight.w500),
                                  ),
                                  const SizedBox(height: 2),
                                  Row(
                                    children: [
                                      const Text(
                                        'Bogor, Indonesia',
                                        style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                                      ),
                                      const SizedBox(width: 2),
                                      Icon(Icons.keyboard_arrow_down_rounded, color: Colors.white.withOpacity(0.8), size: 16),
                                    ],
                                  ),
                                ],
                              ),
                              const Spacer(),
                              Stack(
                                children: [
                                  Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.15),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Icons.notifications_none_rounded, color: Colors.white, size: 22),
                                  ),
                                  Positioned(
                                    top: 10,
                                    right: 11,
                                    child: Container(
                                      width: 8,
                                      height: 8,
                                      decoration: const BoxDecoration(
                                        color: Colors.redAccent,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          
                          // BARIS 2: Teks Sapaan
                          const Text(
                            'Halo, Faza!',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // 2. KARTU SALDO PUTIH OVERLAP
                Positioned(
                  bottom: -60, 
                  left: 24,
                  right: 24,
                  child: Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.06),
                          blurRadius: 15,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.account_balance_wallet_rounded, color: Colors.blueAccent, size: 15),
                                  const SizedBox(width: 6),
                                  const Text(
                                    'Saldo SteamGo',
                                    style: TextStyle(color: Color(0xFF64748B), fontSize: 12, fontWeight: FontWeight.w600),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              const Text(
                                'Rp 125.000',
                                style: TextStyle(color: Color(0xFF1E293B), fontSize: 20, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.orange.shade50,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.star_rounded, color: Colors.orange.shade600, size: 14),
                                    const SizedBox(width: 4),
                                    Text(
                                      '1.250 Poin',
                                      style: TextStyle(color: Colors.orange.shade700, fontSize: 11, fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          height: 55,
                          width: 1,
                          color: const Color(0xFFF1F5F9),
                          margin: const EdgeInsets.symmetric(horizontal: 8),
                        ),
                        Expanded(
                          flex: 2,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _buildCardAction(Icons.add_box_rounded, 'Top Up'),
                              _buildCardAction(Icons.receipt_long_rounded, 'Riwayat'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 84),

            // ==========================================
            // KONTEN LAYANAN KAMI
            // ==========================================
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Layanan Kami',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildServiceItem(Icons.local_car_wash_rounded, 'Cuci\nReguler'),
                      _buildServiceItem(Icons.workspace_premium_rounded, 'Premium\nWash'),
                      _buildServiceItem(Icons.content_cut_rounded, 'Pangkas\nAntrean'),
                      _buildServiceItem(Icons.calendar_month_rounded, 'Booking\nCuci'),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // ==========================================
            // KONTEN PROMO SPESIAL
            // ==========================================
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Promo Spesial',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                      ),
                      Text(
                        'Lihat Semua',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.blueAccent.shade400),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 140,
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    scrollDirection: Axis.horizontal,
                    itemCount: 3,
                    itemBuilder: (context, index) {
                      return Container(
                        width: MediaQuery.of(context).size.width * 0.8,
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          color: const Color(0xFFE2E8F0),
                          image: const DecorationImage(
                            image: NetworkImage('https://images.unsplash.com/photo-1607860108855-64acf2078ed9?q=80&w=800&auto=format&fit=crop'),
                            fit: BoxFit.cover,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 32),

            // ==========================================
            // KONTEN DAFTAR HARI INI (DIUBAH SESUAI REFERENSI)
            // ==========================================
            _buildTodaysListSection(),
            
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // WIDGET BARU: Seksi Daftar Hari Ini
  Widget _buildTodaysListSection() {
    // Data List disesuaikan dengan Mockup
    final List<Map<String, dynamic>> todaysActivities = [
      {
        'vehicle': 'Yamaha NMax (F 1234 ABC)',
        'service': 'Cuci Reguler',
        'time': '10:30 WIB',
        'status': 'Sedang Dicuci',
        'statusColor': Colors.orange.shade700,
        'statusBg': Colors.orange.shade50,
        'icon': Icons.two_wheeler_rounded,
      },
      {
        'vehicle': 'Toyota Avanza (B 9876 KKK)',
        'service': 'Premium Wash',
        'time': '13:00 WIB',
        'status': 'Dalam Antrean',
        'statusColor': Colors.blueAccent,
        'statusBg': Colors.blue.shade50,
        'icon': Icons.directions_car_filled_rounded,
      },
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Daftar Hari Ini',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
              ),
              Text(
                'Lihat Semua',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.blueAccent),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // List Item Antrean
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(), 
            padding: EdgeInsets.zero,
            itemCount: todaysActivities.length,
            itemBuilder: (context, index) {
              final item = todaysActivities[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade200), // Border tipis abu-abu
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.02),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    // PERBAIKAN: Lingkaran Ikon Kendaraan berlatar BIRU SOLID, ikon PUTIH
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: const BoxDecoration(
                        color: Colors.blueAccent,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(item['icon'], color: Colors.white, size: 24),
                    ),
                    const SizedBox(width: 14),
                    
                    // Detail Teks Informasi
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item['vehicle'],
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${item['service']} • ${item['time']}',
                            style: const TextStyle(fontSize: 12, color: Color(0xFF64748B), fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ),
                    
                    // Badge Status Kerja
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: item['statusBg'],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        item['status'],
                        style: TextStyle(
                          fontSize: 11, 
                          color: item['statusColor'], 
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCardAction(IconData icon, String label) {
    return InkWell(
      onTap: () {},
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.blueAccent, size: 28),
          const SizedBox(height: 6),
          Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF475569))),
        ],
      ),
    );
  }

  Widget _buildServiceItem(IconData icon, String label) {
    return Expanded(
      child: Column(
        children: [
          Container(
            height: 54,
            width: 54,
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF), 
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: Colors.blueAccent, size: 26),
          ),
          const SizedBox(height: 10),
          Text(label, textAlign: TextAlign.center, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF1E293B), height: 1.2)),
        ],
      ),
    );
  }
}