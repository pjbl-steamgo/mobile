import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(270),
        child: _buildHeader(),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // ── STATS CARD ───────────────────────────────────────────────
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
                    ),
                    _MenuItem(
                      icon: Icons.phone_outlined,
                      iconColor: const Color(0xFF00B4D8),
                      iconBg: const Color(0xFFE0F7FA),
                      label: 'No Telepon',
                    ),
                    _MenuItem(
                      icon: Icons.mail_outline_rounded,
                      iconColor: const Color(0xFF43A047),
                      iconBg: const Color(0xFFE8F5E9),
                      label: 'Email',
                    ),
                    _MenuItem(
                      icon: Icons.discount_outlined,
                      iconColor: const Color(0xFF3B5BDB),
                      iconBg: const Color(0xFFE8F0FE),
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
                    ),
                    _MenuItem(
                      icon: Icons.history_rounded,
                      iconColor: const Color(0xFFF59F00),
                      iconBg: const Color(0xFFFFF3CD),
                      label: 'Riwayat Perangkat',
                      isLast: true,
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
                    ),
                    _MenuItem(
                      icon: Icons.description_outlined,
                      iconColor: const Color(0xFFE53935),
                      iconBg: const Color(0xFFFFEBEE),
                      label: 'Syarat & Ketentuan',
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
    );
  }

  // ── Header ────────────────────────────────────────────────────────────────
  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1A237E), Color(0xFF42A5F5)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
          child: Column(
            children: [
              // Avatar
              Container(
                width: 76,
                height: 76,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF90CAF9),
                  border: Border.all(color: Colors.white, width: 3),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.person_rounded,
                  size: 52,
                  color: Color(0xFF1A237E),
                ),
              ),
              const SizedBox(height: 10),

              // Nama
              const Text(
                'Raditya Hafiz Utomo',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 3),

              // Nomor HP
              Text(
                '+62 813-xxxx-xx12',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 10),

              // Badge member
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                      color: Colors.white.withOpacity(0.3), width: 1),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Text('⭐', style: TextStyle(fontSize: 14)),
                    SizedBox(width: 6),
                    Text(
                      'Member Silver',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
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

  // ── Stats card (overlap dengan header) ───────────────────────────────────
  Widget _buildStatsCard() {
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
              _buildStatItem('8', 'Total Steam',
                  const Color(0xFF1A1A2E), false),
              _buildStatDivider(),
              _buildStatItem('4.8 ⭐', 'Rating',
                  const Color(0xFFF59F00), false),
              _buildStatDivider(),
              _buildStatItem('248K', 'Total Bayar',
                  const Color(0xFF3B5BDB), true),
            ],
          ),
      ),
    );
  }

  Widget _buildStatItem(
      String value, String label, Color valueColor, bool isBlue) {
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
      child: Column(
        children: [
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
            child: Row(
              children: [
                // Ikon
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
                // Label
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
                // Chevron
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
            const Divider(
                height: 1, indent: 66, endIndent: 16,
                color: Color(0xFFF1F5F9)),
        ],
      ),
    );
  }

  // ── Logout dialog ─────────────────────────────────────────────────────────
  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Keluar dari Akun?',
          style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A1A2E)),
        ),
        content: const Text(
          'Kamu akan keluar dari akun SteamGo. Yakin ingin melanjutkan?',
          style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal',
                style: TextStyle(color: Color(0xFF64748B))),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Keluar',
              style: TextStyle(
                  color: Color(0xFFE53935), fontWeight: FontWeight.bold),
            ),
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
  final bool isLast;
  final bool isDestructive;
  final VoidCallback? onTap;

  const _MenuItem({
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.label,
    this.isLast = false,
    this.isDestructive = false,
    this.onTap,
  });
}