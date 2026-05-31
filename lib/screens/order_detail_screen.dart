import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'chat_screen.dart'; 

class OrderDetailScreen extends StatefulWidget {
  final String orderId; 
  final String serviceName;
  final String date;
  final String vehicle;
  final String plateNumber;
  final String slot; 
  final String price;
  final String bookingCode;
  final String estimasiWaktu; 

  const OrderDetailScreen({
    super.key,
    required this.orderId, 
    required this.serviceName,
    required this.date,
    required this.vehicle,
    required this.plateNumber,
    required this.slot,
    required this.price,
    required this.bookingCode,
    required this.estimasiWaktu,
  });

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  Timer? _pollingTimer;
  late String _currentStatus;

  final List<String> _timelineSteps = [
    "Booking",
    "Booking Dikonfirmasi",
    "Pembayaran",
    "Pembayaran Dikonfirmasi",
    "Sedang dalam antrian",
    "Sedang dicuci",
    "Selesai & Siap diambil"
  ];

  @override
  void initState() {
    super.initState();
    _currentStatus = widget.slot; 
    
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);

    _startPolling();
  }

  void _startPolling() {
    _pollingTimer = Timer.periodic(const Duration(seconds: 3), (timer) async {
      try {
        final response = await http.get(Uri.parse('http://192.168.1.14:8000/api/orders/status/${widget.orderId}'));
        
        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          if (data['success'] == true && data['status'] != null) {
            
            if (_currentStatus != data['status'] && mounted) {
              setState(() {
                _currentStatus = data['status'];
              });
            }

            if (_currentStatus == 'Selesai' || _currentStatus == 'Batal' || _currentStatus == 'Dihapus') {
              timer.cancel();
            }
          }
        }
      } catch (e) {
        debugPrint("Polling detail error: $e");
      }
    });
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  int get _currentStepIndex {
    switch (_currentStatus) { 
      case 'Belum Dikonfirmasi': return 0;
      case 'Belum Bayar': return 1;
      case 'Sedang Diverifikasi': return 2;
      case 'Antri': return 4; 
      case 'Proses': return 5;
      case 'Selesai': return 6;
      default: return 0;
    }
  }

  int get _mainStepIndex {
    if (_currentStatus == 'Selesai') return 2;
    if (_currentStatus == 'Proses') return 1;
    return 0; 
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: Color(0xFF1A1A2E)),
        title: const Text('Detail Pesanan',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1A1A2E))),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: const Color(0xFFE9ECEF)),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildAnimatedHeaderCard(),
            const SizedBox(height: 16),
            _buildInfoCard(),
            const SizedBox(height: 16),
            _buildTrackingCard(),
            const SizedBox(height: 24),
            Row(
              children: [
                if (_currentStepIndex < 4) ...[
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _showCancelDialog(context),
                      child: Container(
                        height: 48,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFEBEE),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFEF5350)),
                        ),
                        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: const [
                          Icon(Icons.cancel_outlined, size: 18, color: Color(0xFFE53935)),
                          SizedBox(width: 6),
                          Text('Batalkan',
                              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFFE53935))),
                        ]),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                ],
                Expanded(
                  flex: _currentStepIndex < 4 ? 1 : 2,
                  child: GestureDetector(
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ChatScreen())),
                    child: Container(
                      height: 48,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8F5E9),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFF4CAF50)),
                      ),
                      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: const [
                        Icon(Icons.chat_bubble_outline_rounded, size: 18, color: Color(0xFF2E7D32)),
                        SizedBox(width: 6),
                        Text('Chat Admin',
                            style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF2E7D32))),
                      ]),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedHeaderCard() {
    int currentMainStep = _mainStepIndex;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1A237E), Color(0xFF3B5BDB)],
          begin: Alignment.topLeft, end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [BoxShadow(color: const Color(0xFF3B5BDB).withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 5))],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Status Cucian', style: TextStyle(color: Colors.white70, fontSize: 12)),
                  const SizedBox(height: 4),
                  Text('Kode: ${widget.bookingCode}', style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(color: Colors.black.withOpacity(0.2), borderRadius: BorderRadius.circular(20)),
                child: Text(_currentStatus.toUpperCase(), style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
              )
            ],
          ),
          const SizedBox(height: 32),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildMainStepNode(0, currentMainStep, Icons.hourglass_bottom_rounded, 'Antri'),
              _buildMainStepLine(0, currentMainStep),
              _buildMainStepNode(1, currentMainStep, Icons.local_car_wash_rounded, 'Proses'),
              _buildMainStepLine(1, currentMainStep),
              _buildMainStepNode(2, currentMainStep, Icons.check_circle_rounded, 'Selesai'),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildMainStepNode(int index, int currentStep, IconData icon, String label) {
    bool isActive = index == currentStep;
    bool isDone = index < currentStep;

    Widget circle = Container(
      width: 46, height: 46,
      decoration: BoxDecoration(
        color: isDone ? const Color(0xFF4CAF50) : (isActive ? Colors.white : Colors.white.withOpacity(0.15)),
        shape: BoxShape.circle,
        boxShadow: isActive ? [BoxShadow(color: Colors.white.withOpacity(0.4), blurRadius: 12, spreadRadius: 2)] : [],
      ),
      child: Icon(
        isDone ? Icons.check_rounded : icon,
        color: isDone ? Colors.white : (isActive ? const Color(0xFF3B5BDB) : Colors.white54),
        size: 22,
      ),
    );

    if (isActive) {
      circle = AnimatedBuilder(
        animation: _pulseController,
        builder: (context, child) {
          return Transform.scale(scale: 1.0 + (_pulseController.value * 0.1), child: child);
        },
        child: circle,
      );
    }

    return SizedBox(
      width: 60,
      child: Column(
        children: [
          circle,
          const SizedBox(height: 10),
          Text(label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isDone || isActive ? Colors.white : Colors.white54,
              fontSize: 12,
              fontWeight: isDone || isActive ? FontWeight.bold : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainStepLine(int index, int currentStep) {
    bool isDone = index < currentStep;
    return Expanded(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 500),
        margin: const EdgeInsets.only(top: 22, left: 4, right: 4), 
        height: 3,
        decoration: BoxDecoration(
          color: isDone ? const Color(0xFF4CAF50) : Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(2)
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white, borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE9ECEF)),
      ),
      child: Column(
        children: [
          _row('Layanan', widget.serviceName, bold: true), _div(),
          _row('Tanggal', widget.date), _div(),
          _row('Kendaraan', '${widget.vehicle} (${widget.plateNumber})'), _div(),
          
          // PERBAIKAN MUTLAK: Teks Estimasi murni mengambil dari database tanpa diubah
          _row('Estimasi', widget.estimasiWaktu, valueColor: const Color(0xFF3B5BDB)), _div(),
          
          _row('Pembayaran', 'QRIS'), _div(),
          _row('Total', widget.price, valueColor: const Color(0xFF3B5BDB), bold: true, fontSize: 15),
        ],
      ),
    );
  }

  Widget _row(String label, String value, {Color? valueColor, bool bold = false, double fontSize = 13}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 13, color: Color(0xFF94A3B8))),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: fontSize, 
                fontWeight: bold ? FontWeight.bold : FontWeight.w600, 
                color: valueColor ?? const Color(0xFF1A1A2E)
              )
            ),
          ),
        ],
      ),
    );
  }

  Widget _div() => const Divider(height: 1, indent: 14, endIndent: 14, color: Color(0xFFF1F5F9));

  Widget _buildTrackingCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white, borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE9ECEF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(bottom: 16, left: 4),
            child: Text('Riwayat Status', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1A1A2E))),
          ),
          ...List.generate(_timelineSteps.length, (index) {
            bool isLast = index == _timelineSteps.length - 1;
            int activeStep = _currentStepIndex;
            
            bool isCompleted = index < activeStep || (activeStep == 6 && index == 6);
            bool isActive = index == activeStep;

            return _buildStep(_timelineSteps[index], isCompleted, isActive, isLast);
          }),
        ],
      ),
    );
  }

  Widget _buildStep(String label, bool done, bool active, bool isLast) {
    bool isFinalStep = label == "Selesai & Siap diambil";

    final Color circleColor = done
        ? const Color(0xFF4CAF50)
        : active
            ? const Color(0xFF3B5BDB)
            : const Color(0xFFE2E8F0);

    final Widget circleChild = done
        ? const Icon(Icons.check_rounded, color: Colors.white, size: 14)
        : active
            ? const Center(child: CircleAvatar(radius: 4, backgroundColor: Colors.white))
            : const SizedBox(); 

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 24, height: 24,
                decoration: BoxDecoration(
                  color: circleColor, 
                  shape: BoxShape.circle,
                  border: (active && !done) ? Border.all(color: const Color(0xFFE0E7FF), width: 4) : null,
                ),
                child: Center(child: circleChild),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    color: done ? const Color(0xFF4CAF50) : const Color(0xFFE2E8F0)
                  ),
                ),
            ],
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: (done || active) ? FontWeight.bold : FontWeight.w500,
                          color: (done || active) ? const Color(0xFF1A1A2E) : const Color(0xFF94A3B8))),
                  
                  if (active && !isFinalStep) ...[
                    const SizedBox(height: 4),
                    const Text('Berlangsung...', style: TextStyle(fontSize: 11, color: Color(0xFF3B5BDB), fontWeight: FontWeight.w600)),
                  ]
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showCancelDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Batalkan Pesanan?', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1A1A2E))),
        content: const Text('Pesanan yang sudah dibatalkan tidak dapat dikembalikan.', style: TextStyle(fontSize: 13, color: Color(0xFF64748B))),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Kembali', style: TextStyle(color: Color(0xFF64748B)))),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('Batalkan', style: TextStyle(color: Color(0xFFE53935), fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}