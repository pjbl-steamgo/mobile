import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:async'; 

import '../config/api_service.dart'; 
import '../config/api_config.dart';  
import 'chat_screen.dart';
import 'order_screen.dart';
import 'order_detail_screen.dart';
import 'booking_waiting_screen.dart';
import 'payment_screen.dart';
import 'payment_waiting_screen.dart';
import 'service_screen.dart';

class HomeScreen extends StatefulWidget {
  final VoidCallback? onSeeAllOrders;
  final VoidCallback? onSeeAllServices;

  const HomeScreen({
    super.key, 
    this.onSeeAllOrders, 
    this.onSeeAllServices,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _username = "Memuat...";
  String _userId = "";
  String? _fotoProfil; 
  int _imageVersion = DateTime.now().millisecondsSinceEpoch; 

  bool _isLoadingOrder = true;
  List<dynamic> _activeOrders = []; 

  bool _isLoadingJam = true;
  List<dynamic> _jamOperasional = [];

  late PageController _sliderController;
  int _currentSliderPage = 0;
  Timer? _sliderTimer;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _fetchJamOperasional();

    _sliderController = PageController(initialPage: 0);
    _sliderTimer = Timer.periodic(const Duration(seconds: 3), (Timer timer) {
      if (_currentSliderPage < 2) {
        _currentSliderPage++;
      } else {
        _currentSliderPage = 0;
      }
      if (_sliderController.hasClients) {
        _sliderController.animateToPage(
          _currentSliderPage,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _sliderTimer?.cancel(); 
    _sliderController.dispose();
    super.dispose();
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

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final idUser = prefs.getString('id_user') ?? "";
    final username = prefs.getString('username') ?? "Pelanggan";

    if (mounted) {
      setState(() {
        _username = username;
        _userId = idUser;
      });
    }

    if (idUser.isNotEmpty) {
      _fetchUserProfile(idUser); 
      _fetchActiveOrders(idUser);
    } else {
      if (mounted) setState(() => _isLoadingOrder = false);
    }
  }

  Future<void> _fetchUserProfile(String userId) async {
    try {
      final response = await ApiService.get('/user/$userId');
      if (response != null && response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['data'] != null) {
          if (mounted) {
            setState(() {
              _username = data['data']['username'] ?? _username;
              String? foto = data['data']['foto_profil'];
              _fotoProfil = (foto != null && foto.isNotEmpty) ? foto : null;
              _imageVersion = DateTime.now().millisecondsSinceEpoch;
            });
          }
        }
      }
    } catch (e) {
      debugPrint("Gagal memuat profil user: $e");
    }
  }

  Future<void> _fetchActiveOrders(String userId) async {
    if (mounted) setState(() => _isLoadingOrder = true);

    try {
      final response = await ApiService.get('/order-history?user_id=$userId');

      if (response != null && response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['success'] == true) {
          List<dynamic> allOrders = responseData['data'];
          List<dynamic> active = [];

          for (var order in allOrders) {
            String status = order['status']?.toString() ?? '';
            if (!['Selesai', 'Batal', 'Dihapus'].contains(status)) {
              active.add(order);
            }
          }

          active.sort((a, b) {
            String dateA = a['created_at']?.toString() ?? '';
            String dateB = b['created_at']?.toString() ?? '';
            return dateA.compareTo(dateB);
          });

          if (mounted) setState(() => _activeOrders = active);
        }
      }
    } catch (e) {
      debugPrint("Gagal memuat antrian: $e");
    } finally {
      if (mounted) setState(() => _isLoadingOrder = false);
    }
  }

  Future<void> _fetchJamOperasional() async {
    if (mounted) setState(() => _isLoadingJam = true);
    try {
      final response = await ApiService.get('/jam-operasional');

      if (response != null && response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          if (mounted) {
            setState(() {
              _jamOperasional = data['data'];
            });
          }
        }
      }
    } catch (e) {
      debugPrint("Gagal memuat jam operasional: $e");
    } finally {
      if (mounted) setState(() => _isLoadingJam = false);
    }
  }

  Future<void> _handleQueueTap(Map<String, dynamic> order) async {
    String status = order['status']?.toString() ?? 'Belum Dikonfirmasi';
    String orderId = order['_id']?.toString() ?? order['id']?.toString() ?? '';
    String namaLayanan = order['layanan']?['nama_layanan']?.toString() ?? 'Layanan Cuci';
    String tanggalTampil = order['tanggal']?.toString() ?? order['created_at']?.toString() ?? '-';
    String kendaraan = order['kendaraan']?.toString() ?? '-';
    String platNomor = order['plat_nomor']?.toString() ?? '-';
    String hargaTampil = 'Rp ${order['total_harga'] ?? 0}';
    String bookingCode = order['kode_pesanan']?.toString() ?? '-';

    String estimasiLayanan = '± 30 Menit';
    if (order['layanan'] != null && order['layanan']['estimasi_waktu'] != null) {
      String estText = order['layanan']['estimasi_waktu'].toString();
      estimasiLayanan = estText.toLowerCase().contains('menit') ? estText : '± $estText Menit';
    }

    if (status == 'Belum Dikonfirmasi') {
      await Navigator.push(context, MaterialPageRoute(builder: (_) => BookingWaitingScreen(
        orderId: orderId, serviceName: namaLayanan, date: tanggalTampil, vehicle: kendaraan, plateNumber: platNomor, price: hargaTampil, bookingCode: bookingCode,
      )));
    } else if (status == 'Belum Bayar') {
      await Navigator.push(context, MaterialPageRoute(builder: (_) => PaymentScreen(
        orderId: orderId, serviceName: namaLayanan, date: tanggalTampil, vehicle: kendaraan, plateNumber: platNomor, price: hargaTampil, bookingCode: bookingCode,
      )));
    } else if (status == 'Sedang Diverifikasi') {
      await Navigator.push(context, MaterialPageRoute(builder: (_) => PaymentWaitingScreen(
        orderId: orderId, serviceName: namaLayanan, date: tanggalTampil, vehicle: kendaraan, plateNumber: platNomor, price: hargaTampil, bookingCode: bookingCode,
      )));
    } else {
      await Navigator.push(context, MaterialPageRoute(builder: (_) => OrderDetailScreen(
        orderId: orderId, serviceName: namaLayanan, date: tanggalTampil, vehicle: kendaraan, plateNumber: platNomor, slot: status, price: hargaTampil, bookingCode: bookingCode, estimasiWaktu: estimasiLayanan,
      )));
    }
    
    _fetchActiveOrders(_userId); 
  }

  Future<void> _handleRefresh() async {
    await _fetchUserProfile(_userId); 
    await _fetchActiveOrders(_userId);
    await _fetchJamOperasional();
  }

  void _showProfilePhotoDialog(String initial) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent, 
          elevation: 0,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 250, 
                height: 250,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  border: Border.all(color: Colors.white, width: 4),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 10))
                  ]
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(125), 
                  child: _fotoProfil != null
                    ? Image.network(
                        _getValidImageUrl(_fotoProfil!),
                        fit: BoxFit.cover, width: 250, height: 250,
                        errorBuilder: (context, error, stackTrace) => _buildInitialsLarge(initial),
                      )
                    : _buildInitialsLarge(initial),
                ),
              ),
              const SizedBox(height: 24),
              Container(
                decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.black54),
                child: IconButton(
                  icon: const Icon(Icons.close_rounded, color: Colors.white, size: 30),
                  onPressed: () => Navigator.pop(context),
                ),
              )
            ],
          ),
        );
      }
    );
  }

  Widget _buildInitialsLarge(String initial) {
    return Container(
      color: const Color(0xFF1A237E), 
      child: Center(
        child: Text(
          initial,
          style: const TextStyle(fontSize: 90, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    String initial = _username.isNotEmpty && _username != "Memuat..." 
        ? _username[0].toUpperCase() 
        : "?";

    return Scaffold(
      backgroundColor: const Color(0xFFF0F4FF),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80),
        child: Container(
          decoration: const BoxDecoration(
            // ── PERUBAHAN 1: WARNA BACKGROUND APP BAR DISAMAKAN ──
            gradient: LinearGradient(
              colors: [Color(0xFF1A237E), Color(0xFF3B5BDB)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.only(bottomLeft: Radius.circular(28), bottomRight: Radius.circular(28)),
          ),
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 14),
              child: Row(
                children: [
                  // ── PERUBAHAN 2: FOTO PROFIL (HANYA GET / MUNCULKAN POP UP) ──
                  GestureDetector(
                    onTap: () => _showProfilePhotoDialog(initial),
                    child: Container(
                      width: 44, height: 44,
                      decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withOpacity(0.25), border: Border.all(color: Colors.white, width: 2)),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(22),
                        child: _fotoProfil != null
                          ? Image.network(
                              _getValidImageUrl(_fotoProfil!),
                              fit: BoxFit.cover, width: 44, height: 44,
                              errorBuilder: (context, error, stackTrace) => Center(child: Text(initial, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 18))),
                            )
                          : Center(child: Text(initial, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 18))),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Selamat datang kembali,', style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 12)),
                        const SizedBox(height: 2),
                        Text('$_username 👋', style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                  // ── PERUBAHAN 3: UI LOGO CHAT BARU ──
                  GestureDetector(
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ChatScreen())),
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          width: 44, height: 44,
                          margin: const EdgeInsets.only(right: 8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.18),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white.withOpacity(0.3), width: 1.5),
                          ),
                          child: const Icon(Icons.mark_chat_unread_rounded, color: Colors.white, size: 22),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      
      body: RefreshIndicator(
        onRefresh: _handleRefresh,
        color: const Color(0xFF3B5BDB),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _buildDynamicQueueSection(),
              ),

              const SizedBox(height: 24),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text('Layanan Kami', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1A1A2E))),
                        GestureDetector(
                          onTap: () {
                            if (widget.onSeeAllServices != null) {
                              widget.onSeeAllServices!();
                            } else {
                              Navigator.push(context, MaterialPageRoute(builder: (_) => const ServiceScreen()));
                            }
                          },
                          child: const Text('Lihat Semua', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF3B5BDB))),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    
                    SizedBox(
                      height: 160, 
                      child: PageView(
                        controller: _sliderController,
                        onPageChanged: (int page) {
                          setState(() => _currentSliderPage = page);
                        },
                        children: [
                          // ── BAGIAN YANG DIPERBARUI: MENAMBAHKAN GAMBAR LAYANAN ──
                          _buildImageBanner('assets/images/steamwash.png'), // Gambar yang baru Anda tambahkan
                          _buildImageBanner('assets/images/snowwash.png'),      // Anda juga bisa mengganti gambar slider lainnya
                          _buildImageBanner('assets/images/detailing.png'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(3, (index) => _buildSliderDot(index)),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Jam Operasional Hari Ini', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF1A1A2E))),
                    const SizedBox(height: 12),
                    
                    if (_isLoadingJam)
                      const Center(child: CircularProgressIndicator(color: Color(0xFF3B5BDB)))
                    else if (_jamOperasional.isEmpty)
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: const Color(0xFFE9ECEF))),
                        child: const Text('Belum ada data jam operasional yang ditambahkan dari Admin.', style: TextStyle(fontSize: 12, color: Colors.grey)),
                      )
                    else
                      ..._jamOperasional.map((jamData) {
                        String waktu = jamData['jam']?.toString() ?? '-';
                        bool isActive = false;
                        
                        if (jamData['is_active'] != null) {
                          if (jamData['is_active'] is bool) {
                            isActive = jamData['is_active'];
                          } else {
                            isActive = jamData['is_active'].toString() == '1' || jamData['is_active'].toString() == 'true';
                          }
                        }

                        return _buildOperasionalCard(waktu, isActive);
                      }),
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

  Widget _buildOperasionalCard(String waktu, bool isActive) {
    final Color bgColor = isActive ? Colors.white : const Color(0xFFF8F9FA);
    final Color timeColor = isActive ? const Color(0xFF1A1A2E) : const Color(0xFF94A3B8);
    final Color statusColor = isActive ? const Color(0xFF4CAF50) : const Color(0xFFE53935);
    final String statusText = isActive ? 'Tersedia' : 'Tutup';
    final IconData iconData = isActive ? Icons.check_circle_rounded : Icons.cancel_rounded;
    final Color iconBg = isActive ? const Color(0xFFE8F5E9) : const Color(0xFFFFEBEE);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE9ECEF)),
      ),
      child: Row(
        children: [
          Icon(Icons.access_time_rounded, size: 18, color: timeColor),
          const SizedBox(width: 10),
          Expanded(
            child: Row(
              children: [
                Text(
                  waktu, 
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: timeColor),
                ),
                const SizedBox(width: 8),
                Text(
                  '| $statusText', 
                  style: TextStyle(fontSize: 12, color: statusColor, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
          Container(
            width: 32, height: 32,
            decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
            child: Icon(iconData, size: 18, color: statusColor),
          ),
        ],
      ),
    );
  }

  Widget _buildDynamicQueueSection() {
    if (_isLoadingOrder) {
      return Container(
        height: 90,
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
        child: const Center(child: CircularProgressIndicator(color: Color(0xFF3B5BDB))),
      );
    }

    if (_activeOrders.isEmpty) {
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
                  const Text('Belum ada pesanan', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1A1A2E))),
                  const SizedBox(height: 4),
                  Text('Kamu belum memesan jadwal cuci hari ini. Yuk pesan sekarang!', style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
                ],
              ),
            ),
          ],
        ),
      );
    }

    int displayCount = _activeOrders.length > 3 ? 3 : _activeOrders.length;
    bool showSeeAll = _activeOrders.length > 3;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            const Text('Pesanan Aktif', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF1A1A2E))),
            if (showSeeAll)
              GestureDetector(
                onTap: () {
                  if (widget.onSeeAllOrders != null) {
                    widget.onSeeAllOrders!();
                  } else {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const OrderScreen()));
                  }
                },
                child: const Text('Lihat Semua', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF3B5BDB))),
              ),
          ],
        ),
        const SizedBox(height: 12),

        ...List.generate(displayCount, (index) {
          Map<String, dynamic> order = _activeOrders[index];
          int urutan = index + 1; 
          
          String statusPesanan = order['status']?.toString() ?? 'Belum Dikonfirmasi';
          String namaLayanan = order['layanan']?['nama_layanan']?.toString() ?? 'Layanan Cuci';
          String kendaraan = order['kendaraan']?.toString() ?? '-';
          String platNomor = order['plat_nomor']?.toString() ?? '-';

          return GestureDetector(
            onTap: () => _handleQueueTap(order),
            child: Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE9ECEF)),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))],
              ),
              child: Row(
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(color: const Color(0xFFE8F0FE), borderRadius: BorderRadius.circular(12)),
                    child: Center(
                      child: Text('#$urutan', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF3B5BDB))),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(namaLayanan, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1A1A2E)), maxLines: 1, overflow: TextOverflow.ellipsis),
                        const SizedBox(height: 5),
                        Row(
                          children: [
                            const Icon(Icons.two_wheeler_rounded, size: 12, color: Color(0xFF64748B)),
                            const SizedBox(width: 4),
                            Expanded(child: Text('$kendaraan ($platNomor)', style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)), maxLines: 1, overflow: TextOverflow.ellipsis)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  _buildBadge(statusPesanan),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildImageBanner(String imagePath) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(16), color: Colors.grey.shade300),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Image.asset(
          imagePath,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.image_not_supported_rounded, color: Colors.grey, size: 30),
                  SizedBox(height: 5),
                  Text('Gambar belum ada', style: TextStyle(fontSize: 10, color: Colors.grey)),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSliderDot(int index) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.only(right: 6),
      height: 6,
      width: _currentSliderPage == index ? 20 : 6,
      decoration: BoxDecoration(
        color: _currentSliderPage == index ? const Color(0xFF3B5BDB) : const Color(0xFFCBD5E1),
        borderRadius: BorderRadius.circular(3),
      ),
    );
  }

  Widget _buildBadge(String status) {
    if (status == 'Belum Dikonfirmasi') return _badge('Menunggu Dikonfirmasi', const Color(0xFFFFF3CD), const Color(0xFFB78103));
    if (status == 'Belum Bayar') return _badge('Belum Bayar', const Color(0xFFFFE0B2), const Color(0xFFE65100));
    if (status == 'Sedang Diverifikasi') return _badge('Sedang diverifikasi', const Color(0xFFE0E7FF), const Color(0xFF3B5BDB));
    if (status == 'Antri' || status == 'Proses') return _badge(status, const Color(0xFFE8F0FE), const Color(0xFF3B5BDB));
    return _badge(status, const Color(0xFFF1F5F9), const Color(0xFF64748B));
  }

  Widget _badge(String label, Color bg, Color fg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(8)),
      child: Text(label, style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: fg)),
    );
  }
}