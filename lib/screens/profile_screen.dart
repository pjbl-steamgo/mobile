import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import 'profile_username_screen.dart';
import 'profile_hp_screen.dart';
import 'profile_email_screen.dart';
import 'profile_password_screen.dart';
import 'profile_faq_screen.dart';
import 'profile_sk_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isLoading = true;
  
  // Variabel untuk menampung data profil dari database
  String _username = "Memuat...";
  String _phone = "-";
  String _email = "-";
  String _member = "Silver";
  String? _fotoProfil; 

  // Variabel untuk Statistik
  String _totalPesanan = "-";
  String _rating = "-";
  String _totalBayar = "-";

  @override
  void initState() {
    super.initState();
    _fetchUserDataAndStats();
  }

  // Fungsi untuk menarik data user & menghitung statistik pesanan 'Selesai'
  Future<void> _fetchUserDataAndStats() async {
    setState(() => _isLoading = true);
    
    try {
      final prefs = await SharedPreferences.getInstance();
      final idUser = prefs.getString('id_user') ?? "";

      if (idUser.isEmpty) {
        setState(() => _isLoading = false);
        return;
      }

      // MENGGUNAKAN API CONFIG (CLEAN CODE)
      final String apiUser = '${ApiConfig.baseUrl}/user/$idUser';
      final String apiOrder = '${ApiConfig.baseUrl}/order-history?user_id=$idUser';

      // Eksekusi dua API sekaligus agar lebih cepat
      final responses = await Future.wait([
        http.get(Uri.parse(apiUser), headers: {'Accept': 'application/json'}),
        http.get(Uri.parse(apiOrder), headers: {'Accept': 'application/json'})
      ]);

      final resUser = responses[0];
      final resOrder = responses[1];

      if (mounted) {
        setState(() {
          // ── A. PROSES DATA PROFIL ──
          if (resUser.statusCode == 200) {
            final dataUser = jsonDecode(resUser.body);
            if (dataUser['success'] == true && dataUser['data'] != null) {
              final uData = dataUser['data'];
              _username = uData['username']?.toString() ?? 'Pengguna';
              _phone = uData['no_hp']?.toString() ?? '-';
              _email = uData['email']?.toString() ?? '-';
              _member = uData['member']?.toString() ?? 'Silver';
              
              if (uData['foto_profil'] != null && uData['foto_profil'].toString().isNotEmpty) {
                _fotoProfil = uData['foto_profil'].toString();
              }

              String rawRating = uData['rating']?.toString() ?? "-";
              _rating = (rawRating.isEmpty || rawRating == "null") ? "-" : rawRating;
            }
          }

          // ── B. PROSES DATA STATISTIK PESANAN (HANYA YANG 'SELESAI') ──
          int countSelesai = 0;
          double sumBayar = 0;

          if (resOrder.statusCode == 200) {
            final dataOrder = jsonDecode(resOrder.body);
            if (dataOrder['success'] == true && dataOrder['data'] != null) {
              List<dynamic> allOrders = dataOrder['data'];
              
              // Looping dan cek satu per satu
              for (var order in allOrders) {
                if (order['status'] == 'Selesai') {
                  countSelesai++; // Hitung jumlah pesanan selesai
                  
                  // Hitung total uang
                  String hargaString = order['total_harga']?.toString() ?? '0';
                  double harga = double.tryParse(hargaString) ?? 0;
                  sumBayar += harga;
                }
              }
            }
          }

          // ── C. FORMAT TAMPILAN ANGKA STATISTIK ──
          if (countSelesai == 0) {
            _totalPesanan = "-";
            _totalBayar = "-";
          } else {
            _totalPesanan = countSelesai.toString();
            
            // Penyingkat angka cerdas untuk Total Bayar (Misal: 250000 jadi 250K)
            if (sumBayar >= 1000000) {
              _totalBayar = '${(sumBayar / 1000000).toStringAsFixed(1).replaceAll('.0', '')}M';
            } else if (sumBayar >= 1000) {
              _totalBayar = '${(sumBayar / 1000).toStringAsFixed(0)}K';
            } else {
              _totalBayar = sumBayar.toStringAsFixed(0);
            }
          }
        });
      }
    } catch (e) {
      debugPrint("Gagal memuat profil & statistik: $e");
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // ── Fungsi Warna & Ikon Dinamis untuk Member ──
  Color _getBadgeBgColor() {
    String m = _member.toLowerCase();
    if (m == 'gold') return const Color(0xFFFFD700); 
    if (m == 'diamond') return const Color(0xFF00E5FF); 
    return const Color(0xFFE0E0E0); 
  }

  Color _getBadgeTextColor() {
    String m = _member.toLowerCase();
    if (m == 'gold') return const Color(0xFF5D4037); 
    if (m == 'diamond') return const Color(0xFF006064); 
    return const Color(0xFF424242); 
  }

  String _getBadgeIcon() {
    String m = _member.toLowerCase();
    if (m == 'gold') return '🌟';
    if (m == 'diamond') return '💎';
    return '⭐'; 
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(330), 
        child: _buildHeader(),
      ),
      body: RefreshIndicator(
        onRefresh: _fetchUserDataAndStats,
        color: const Color(0xFF3B5BDB),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              // ── STATS CARD DINAMIS ─────────────────────────────────────────
              _buildStatsCard(),

              const SizedBox(height: 20),

              // ── MENU SECTIONS ────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionTitle('Akun'),
                    const SizedBox(height: 8),
                    _buildMenuCard(items: [
                      _MenuItem(
                        icon: Icons.person_outline_rounded,
                        iconColor: const Color(0xFF3B5BDB),
                        iconBg: const Color(0xFFE8F0FE),
                        label: 'Username',
                        value: _isLoading ? '...' : _username,
                        onTap: () async {
                          final result = await Navigator.push(context, MaterialPageRoute(builder: (_) => ProfileUsernameScreen(currentUsername: _username)));
                          if (result == true) _fetchUserDataAndStats();
                        },
                      ),
                      _MenuItem(
                        icon: Icons.phone_outlined,
                        iconColor: const Color(0xFF00B4D8),
                        iconBg: const Color(0xFFE0F7FA),
                        label: 'No Telepon',
                        value: _isLoading ? '...' : _phone,
                        onTap: () async {
                          final result = await Navigator.push(context, MaterialPageRoute(builder: (_) => ProfileHpScreen(currentHp: _phone)));
                          if (result == true) _fetchUserDataAndStats();
                        },
                      ),
                      _MenuItem(
                        icon: Icons.mail_outline_rounded,
                        iconColor: const Color(0xFF43A047),
                        iconBg: const Color(0xFFE8F5E9),
                        label: 'Email',
                        value: _isLoading ? '...' : _email,
                        onTap: () async {
                          final result = await Navigator.push(context, MaterialPageRoute(builder: (_) => ProfileEmailScreen(currentEmail: _email)));
                          if (result == true) _fetchUserDataAndStats();
                        },
                      ),
                      const _MenuItem(
                        icon: Icons.discount_outlined,
                        iconColor: Color(0xFF3B5BDB),
                        iconBg: Color(0xFFE8F0FE),
                        label: 'Voucher saya',
                        isLast: true,
                      ),
                    ]),

                    const SizedBox(height: 20),

                    _buildSectionTitle('Keamanan'),
                    const SizedBox(height: 8),
                    _buildMenuCard(items: [
                      _MenuItem(
                        icon: Icons.lock_outline_rounded,
                        iconColor: const Color(0xFFF59F00),
                        iconBg: const Color(0xFFFFF3CD),
                        label: 'Kata sandi',
                        isLast: true,
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfilePasswordScreen()));
                        },
                      ),
                    ]),

                    const SizedBox(height: 20),

                    _buildSectionTitle('Lainnya'),
                    const SizedBox(height: 8),
                    _buildMenuCard(items: [
                      _MenuItem(
                        icon: Icons.help_outline_rounded,
                        iconColor: const Color(0xFF3B5BDB),
                        iconBg: const Color(0xFFE8F0FE),
                        label: 'Bantuan & FAQ',
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileFaqScreen()));
                        },
                      ),
                      _MenuItem(
                        icon: Icons.description_outlined,
                        iconColor: const Color(0xFFE53935),
                        iconBg: const Color(0xFFFFEBEE),
                        label: 'Syarat & Ketentuan',
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileSkScreen()));
                        },
                      ),
                      _MenuItem(
                        icon: Icons.logout_rounded,
                        iconColor: const Color(0xFFE53935),
                        iconBg: const Color(0xFFFFEBEE),
                        label: 'Keluar',
                        isLast: true,
                        isDestructive: true,
                        onTap: () => _showLogoutDialog(context),
                      ),
                    ]),

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Header Premium ─────────────────────────────────────────────────────────
  Widget _buildHeader() {
    Color bgBadge = _getBadgeBgColor();
    Color textBadge = _getBadgeTextColor();
    String iconBadge = _getBadgeIcon();

    // Otomatis menyesuaikan URL gambar dari ApiConfig (Membersihkan path '/api' jadi '/storage')
    String storageUrl = ApiConfig.baseUrl.replaceAll('/api', '/storage');

    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1A237E), Color(0xFF42A5F5)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
          child: _isLoading 
            ? const Center(child: CircularProgressIndicator(color: Colors.white))
            : Column(
              children: [
                // Avatar Premium dengan efek Glow
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [Color(0xFF81D4FA), Color(0xFFE3F2FD)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.white),
                    child: ClipOval(
                      child: _fotoProfil != null
                        ? Image.network(
                            '$storageUrl/$_fotoProfil', // <-- URL DINAMIS MENGGUNAKAN APICONFIG
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return const Icon(Icons.person_rounded, size: 52, color: Color(0xFF1A237E));
                            },
                          )
                        : const Icon(Icons.person_rounded, size: 52, color: Color(0xFF1A237E)),
                    ),
                  ),
                ),
                const SizedBox(height: 14),

                // Nama Dinamis
                Text(
                  _username,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                    shadows: [
                      Shadow(color: Colors.black.withOpacity(0.3), offset: const Offset(0, 2), blurRadius: 4)
                    ]
                  ),
                ),
                const SizedBox(height: 12),

                // Contact Chips (Glassmorphism)
                Column(
                  children: [
                    _buildContactChip(Icons.phone_rounded, _phone),
                    const SizedBox(height: 6),
                    _buildContactChip(Icons.email_rounded, _email),
                  ],
                ),
                const SizedBox(height: 16),

                // Badge Member Dinamis dengan Latar Solid
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                  decoration: BoxDecoration(
                    color: bgBadge,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: bgBadge.withOpacity(0.4),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(iconBadge, style: const TextStyle(fontSize: 14)),
                      const SizedBox(width: 8),
                      Text(
                        'Member $_member',
                        style: TextStyle(
                          color: textBadge,
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
        ),
      ),
    );
  }

  Widget _buildContactChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.white.withOpacity(0.9)),
          const SizedBox(width: 6),
          Text(text, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  // ── Stats card DINAMIS (Berdasarkan Pesanan 'Selesai') ───────────────
  Widget _buildStatsCard() {
    String ratingDisplay = _rating == "-" ? "-" : "$_rating ⭐";

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.07),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              _buildStatItem(
                  _isLoading ? '...' : _totalPesanan, 
                  'Total Pesanan',
                  const Color(0xFF1A1A2E), 
                  false
              ),
              _buildStatDivider(),
              _buildStatItem(
                  _isLoading ? '...' : ratingDisplay, 
                  'Rating',
                  const Color(0xFFF59F00), 
                  false
              ),
              _buildStatDivider(),
              _buildStatItem(
                  _isLoading ? '...' : _totalBayar, 
                  'Total Bayar',
                  const Color(0xFF3B5BDB), 
                  true
              ),
            ],
          ),
      ),
    );
  }

  Widget _buildStatItem(String value, String label, Color valueColor, bool isBlue) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 18),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: valueColor,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF94A3B8),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatDivider() {
    return Container(
      width: 1,
      height: 44,
      color: const Color(0xFFF1F5F9),
    );
  }

  // ── Section title ─────────────────────────────────────────────────────────
  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.bold,
        color: Color(0xFF1A1A2E),
      ),
    );
  }

  // ── Menu card ─────────────────────────────────────────────────────────────
  Widget _buildMenuCard({required List<_MenuItem> items}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE9ECEF), width: 0.8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: items.map((item) => _buildMenuItem(item)).toList(),
      ),
    );
  }

  Widget _buildMenuItem(_MenuItem item) {
    return GestureDetector(
      onTap: item.onTap ?? () {},
      behavior: HitTestBehavior.opaque,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: item.iconBg,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(item.icon, color: item.iconColor, size: 18),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    item.label,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: item.isDestructive
                          ? const Color(0xFFE53935)
                          : const Color(0xFF1A1A2E),
                    ),
                  ),
                ),
                if (item.value != null) ...[
                  Text(
                    item.value!,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF94A3B8),
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
                Icon(
                  Icons.chevron_right_rounded,
                  size: 20,
                  color: item.isDestructive
                      ? const Color(0xFFE53935)
                      : const Color(0xFFCBD5E1),
                ),
              ],
            ),
          ),
          if (!item.isLast)
            const Divider(height: 1, indent: 66, endIndent: 16, color: Color(0xFFF1F5F9)),
        ],
      ),
    );
  }

  // ── Logout dialog ─────────────────────────────────────────────────────────
  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Keluar dari Akun?',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1A1A2E)),
        ),
        content: const Text(
          'Kamu akan keluar dari akun SteamGo. Yakin ingin melanjutkan?',
          style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal', style: TextStyle(color: Color(0xFF64748B))),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final prefs = await SharedPreferences.getInstance();
              await prefs.clear();
              // Arahkan ke halaman login jika diperlukan
            },
            child: const Text('Keluar', style: TextStyle(color: Color(0xFFE53935), fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}

// ── Data class ────────────────────────────────────────────────────────────────
class _MenuItem {
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String label;
  final String? value; 
  final bool isLast;
  final bool isDestructive;
  final VoidCallback? onTap;

  const _MenuItem({
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.label,
    this.value,
    this.isLast = false,
    this.isDestructive = false,
    this.onTap,
  });
}