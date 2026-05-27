import 'package:flutter/material.dart';
import 'home_screen.dart'; // Menghubungkan ke halaman beranda

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  // Daftar halaman yang sejajar dengan urutan menu di Navbar
  final List<Widget> _pages = [
    const HomeScreen(), // Index 0: Beranda
    const Center(child: Text('Halaman Layanan', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)))), // Index 1: Layanan
    const Center(child: Text('Halaman Pesanan', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)))), // Index 2: Pesanan
    const Center(child: Text('Halaman Profil', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)))),  // Index 3: Profil
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      
      // Menampilkan halaman aktif sesuai index menu yang dipilih
      body: _pages[_selectedIndex],
      
      // ==========================================
      // CUSTOM BOTTOM NAVIGATION BAR (TERBARU)
      // ==========================================
      bottomNavigationBar: Container(
        padding: const EdgeInsets.only(top: 12, bottom: 20), // Padding bawah disesuaikan untuk kenyamanan navigasi HP
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(Icons.home_filled, 'Beranda', 0),
            _buildNavItem(Icons.grid_view_rounded, 'Layanan', 1), // Menu Layanan Baru
            _buildNavItem(Icons.receipt_long_rounded, 'Pesanan', 2),
            _buildNavItem(Icons.person_rounded, 'Profil', 3),
          ],
        ),
      ),
    );
  }

  // Fungsi pembangun item navigasi kustom agar tata letak icon dan teks presisi
  Widget _buildNavItem(IconData icon, String label, int index) {
    final bool isActive = _selectedIndex == index;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedIndex = index;
        });
      },
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 75, // Lebar proporsional agar jarak antar menu seimbang
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: isActive ? 26 : 24, // Efek membesar sedikit saat menu aktif
              color: isActive ? Colors.blueAccent : const Color(0xFF94A3B8),
            ),
            const SizedBox(height: 5),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isActive ? FontWeight.bold : FontWeight.w600,
                color: isActive ? Colors.blueAccent : const Color(0xFF94A3B8),
                letterSpacing: 0.1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}