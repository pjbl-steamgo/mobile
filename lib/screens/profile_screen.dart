import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import '../config/api_service.dart'; 
import '../config/api_config.dart';
import 'profile_username_screen.dart';
import 'profile_hp_screen.dart';
import 'profile_email_screen.dart';
import 'profile_password_screen.dart';
import 'profile_foto_screen.dart'; 
import 'login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isLoading = true;
  
  String _username = "Memuat...";
  String _phone = "-";
  String _email = "-";
  String _member = "Silver";
  String? _fotoProfil; 

  String _totalPesanan = "-";
  String _rating = "-";
  String _totalBayar = "-";

  int _imageVersion = DateTime.now().millisecondsSinceEpoch;

  @override
  void initState() {
    super.initState();
    _fetchUserDataAndStats();
  }

  String _getValidImageUrl(String path) {
    if (path.startsWith('http')) return '$path?v=$_imageVersion';
    String baseUrl = ApiConfig.baseUrl.replaceAll('/api', '');
    String safePath = path.startsWith('/') ? path : '/$path';
    if (!safePath.startsWith('/storage')) {
      safePath = '/storage$safePath';
    }
    return '$baseUrl$safePath?v=$_imageVersion'; 
  }

  Future<void> _fetchUserDataAndStats() async {
    setState(() => _isLoading = true);
    
    try {
      final prefs = await SharedPreferences.getInstance();
      final idUser = prefs.getString('id_user') ?? "";

      if (idUser.isEmpty) {
        setState(() => _isLoading = false);
        return;
      }

      final resUser = await ApiService.get('/user/$idUser');
      final resOrder = await ApiService.get('/order-history?user_id=$idUser');

      if (resUser == null || resOrder == null) {
        if (mounted) setState(() => _isLoading = false);
        return;
      }

      if (mounted) {
        setState(() {
          _imageVersion = DateTime.now().millisecondsSinceEpoch;

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
              } else {
                _fotoProfil = null; 
              }

              String rawRating = uData['rating']?.toString() ?? "-";
              _rating = (rawRating.isEmpty || rawRating == "null") ? "-" : rawRating;
            }
          }

          int countSelesai = 0;
          double sumBayar = 0;

          if (resOrder.statusCode == 200) {
            final dataOrder = jsonDecode(resOrder.body);
            if (dataOrder['success'] == true && dataOrder['data'] != null) {
              List<dynamic> allOrders = dataOrder['data'];
              for (var order in allOrders) {
                if (order['status'] == 'Selesai') {
                  countSelesai++; 
                  String hargaString = order['total_harga']?.toString() ?? '0';
                  double harga = double.tryParse(hargaString) ?? 0;
                  sumBayar += harga;
                }
              }
            }
          }

          if (countSelesai == 0) {
            _totalPesanan = "-";
            _totalBayar = "-";
          } else {
            _totalPesanan = countSelesai.toString();
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
      debugPrint("Gagal memuat profil: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ── PENGATURAN WARNA BACKGROUND BADGE ──
  Color _getBadgeBgColor() {
    String m = _member.toLowerCase();
    if (m == 'gold') return const Color(0xFFFFF8E1); 
    if (m == 'diamond') return const Color(0xFFE0F7FA); 
    return const Color(0xFFF1F5F9); 
  }

  // ── PENGATURAN WARNA TEKS BADGE ──
  Color _getBadgeTextColor() {
    String m = _member.toLowerCase();
    if (m == 'gold') return const Color(0xFFF57F17); 
    if (m == 'diamond') return const Color(0xFF00838F); 
    return const Color(0xFF334155); 
  }

  // ── PENGATURAN IKON BADGE ──
  Widget _getBadgeIconWidget(Color iconColor) {
    String m = _member.toLowerCase();
    if (m == 'gold') return const Text('👑', style: TextStyle(fontSize: 14));
    if (m == 'diamond') return const Text('✨', style: TextStyle(fontSize: 14));
    
    return Icon(Icons.diamond_outlined, size: 16, color: iconColor); 
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
              _buildStatsCard(),
              const SizedBox(height: 20),
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
                        isLast: true, 
                        onTap: () async {
                          final result = await Navigator.push(context, MaterialPageRoute(builder: (_) => ProfileEmailScreen(currentEmail: _email)));
                          if (result == true) _fetchUserDataAndStats();
                        },
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
                      // MENU FAQ DAN SK DIHAPUS, HANYA TERSISA LOGOUT
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

  Widget _buildHeader() {
    Color bgBadge = _getBadgeBgColor();
    Color textBadge = _getBadgeTextColor();

    String initial = _username.isNotEmpty && _username != "Memuat..." 
        ? _username[0].toUpperCase() 
        : "?";

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
                GestureDetector(
                  onTap: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => ProfileFotoScreen(
                        currentFotoUrl: _fotoProfil,
                        username: _username,
                      )),
                    );
                    if (result == true) {
                      _fetchUserDataAndStats(); 
                    }
                  },
                  child: Stack(
                    children: [
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
                          child: ClipRRect( 
                            borderRadius: BorderRadius.circular(40),
                            child: _fotoProfil != null
                              ? Image.network(
                                  _getValidImageUrl(_fotoProfil!), 
                                  fit: BoxFit.cover, width: 80, height: 80,
                                  errorBuilder: (context, error, stackTrace) => _buildInitials(initial),
                                )
                              : _buildInitials(initial), 
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF59F00), 
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                            boxShadow: [
                              BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 4, offset: const Offset(0, 2))
                            ]
                          ),
                          child: const Icon(Icons.edit_rounded, color: Colors.white, size: 14),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),

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

                Column(
                  children: [
                    _buildContactChip(Icons.phone_rounded, _phone),
                    const SizedBox(height: 6),
                    _buildContactChip(Icons.email_rounded, _email),
                  ],
                ),
                const SizedBox(height: 16),

                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(
                    color: bgBadge,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFE2E8F0), width: 1), 
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _getBadgeIconWidget(textBadge), 
                      const SizedBox(width: 6),
                      Text(
                        _member.toUpperCase(),
                        style: TextStyle(
                          color: textBadge,
                          fontSize: 14,
                          fontWeight: FontWeight.w900, 
                          letterSpacing: 0.5,
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

  Widget _buildInitials(String initial) {
    return Container(
      color: const Color(0xFF1A237E), 
      child: Center(
        child: Text(
          initial,
          style: const TextStyle(fontSize: 34, fontWeight: FontWeight.bold, color: Colors.white),
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
              _buildStatItem(_isLoading ? '...' : _totalPesanan, 'Total Pesanan', const Color(0xFF1A1A2E)),
              _buildStatDivider(),
              _buildStatItem(_isLoading ? '...' : ratingDisplay, 'Rating', const Color(0xFFF59F00)),
              _buildStatDivider(),
              _buildStatItem(_isLoading ? '...' : _totalBayar, 'Total Bayar', const Color(0xFF3B5BDB)),
            ],
          ),
      ),
    );
  }

  Widget _buildStatItem(String value, String label, Color valueColor) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 18),
        child: Column(
          children: [
            Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: valueColor)),
            const SizedBox(height: 4),
            Text(label, style: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8)), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  Widget _buildStatDivider() {
    return Container(width: 1, height: 44, color: const Color(0xFFF1F5F9));
  }

  Widget _buildSectionTitle(String title) {
    return Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF1A1A2E)));
  }

  Widget _buildMenuCard({required List<_MenuItem> items}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE9ECEF), width: 0.8),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(children: items.map((item) => _buildMenuItem(item)).toList()),
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
                  width: 36, height: 36,
                  decoration: BoxDecoration(color: item.iconBg, borderRadius: BorderRadius.circular(10)),
                  child: Icon(item.icon, color: item.iconColor, size: 18),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    item.label,
                    style: TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w500,
                      color: item.isDestructive ? const Color(0xFFE53935) : const Color(0xFF1A1A2E),
                    ),
                  ),
                ),
                if (item.value != null) ...[
                  Text(item.value!, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Color(0xFF94A3B8))),
                  const SizedBox(width: 8),
                ],
                Icon(
                  Icons.chevron_right_rounded, size: 20,
                  color: item.isDestructive ? const Color(0xFFE53935) : const Color(0xFFCBD5E1),
                ),
              ],
            ),
          ),
          if (!item.isLast) const Divider(height: 1, indent: 66, endIndent: 16, color: Color(0xFFF1F5F9)),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Keluar dari Akun?', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1A1A2E))),
        content: const Text('Kamu akan keluar dari akun SteamGo. Yakin ingin melanjutkan?', style: TextStyle(fontSize: 13, color: Color(0xFF64748B))),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal', style: TextStyle(color: Color(0xFF64748B)))),
          TextButton(
            onPressed: () async {
              Navigator.pop(context); 
              showDialog(context: context, barrierDismissible: false, builder: (context) => const Center(child: CircularProgressIndicator()));
              try {
                await ApiService.post('/logout', {});
                final prefs = await SharedPreferences.getInstance();
                await prefs.clear(); 
              } catch (e) {
                debugPrint("Error saat proses logout: $e");
              }
              if (context.mounted) {
                Navigator.pop(context); 
                Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const LoginScreen()), (route) => false);
              }
            },
            child: const Text('Keluar', style: TextStyle(color: Color(0xFFE53935), fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}

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
    required this.icon, required this.iconColor, required this.iconBg, required this.label,
    this.value, this.isLast = false, this.isDestructive = false, this.onTap,
  });
}