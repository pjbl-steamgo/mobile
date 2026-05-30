import 'package:flutter/material.dart';
import 'chat_screen.dart';

class OrderDetailScreen extends StatelessWidget {
  final String serviceName;
  final String date;
  final String vehicle;
  final String plateNumber;
  final String slot;
  final String price;
  final String bookingCode;

  const OrderDetailScreen({
    super.key,
    required this.serviceName,
    required this.date,
    required this.vehicle,
    required this.plateNumber,
    required this.slot,
    required this.price,
    required this.bookingCode,
  });

  static const List<Map<String, dynamic>> _steps = [
    {'label': 'Booking Dikonfirmasi', 'time': '09:52 WIB', 'done': true,  'active': false, 'subtitle': null},
    {'label': 'Kendaraan Diterima',   'time': '10:10 WIB', 'done': true,  'active': false, 'subtitle': null},
    {'label': 'Sedang Dicuci',        'time': '10:15 WIB', 'done': false, 'active': true,  'subtitle': 'Berlangsung...'},
    {'label': 'Selesai & Siap Diambil','time': 'xx:xx WIB','done': false, 'active': false, 'subtitle': null},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: Color(0xFF1A1A2E)),
        title: const Text('Pesanan',
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
            // ── NOMOR ANTRIAN ──
            _buildQueueCard(),
            const SizedBox(height: 16),

            // ── INFO DETAIL ──
            _buildInfoCard(),
            const SizedBox(height: 16),

            // ── TRACKING ──
            _buildTrackingCard(),
            const SizedBox(height: 20),

            // ── TOMBOL ──
            Row(
              children: [
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
                        Text('Batalkan Pesanan',
                            style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFFE53935))),
                      ]),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: GestureDetector(
                    onTap: () => Navigator.push(context,
                        MaterialPageRoute(builder: (_) => const ChatScreen())),
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
                        Text('Chat',
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

  Widget _buildQueueCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 28),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1A237E), Color(0xFF42A5F5)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          const Text('NOMOR ANTRIAN ANDA',
              style: TextStyle(color: Colors.white70, fontSize: 12,
                  fontWeight: FontWeight.w600, letterSpacing: 2)),
          const SizedBox(height: 8),
          const Text('07',
              style: TextStyle(color: Colors.white, fontSize: 72, fontWeight: FontWeight.bold, height: 1)),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withOpacity(0.3)),
            ),
            child: const Text('Antrian Sebelum Anda\n2 antrian',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600, height: 1.5)),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE9ECEF)),
      ),
      child: Column(
        children: [
          _row('Layanan', serviceName),
          _div(),
          _row('Tanggal', '$date, $slot'),
          _div(),
          _row('Kendaraan', vehicle),
          _div(),
          _row('Estimasi', '-25 Menit', valueColor: const Color(0xFF3B5BDB)),
          _div(),
          _row('Pembayaran', 'Transfer Bank'),
          _div(),
          _row('Total', price, valueColor: const Color(0xFF3B5BDB), bold: true, fontSize: 15),
        ],
      ),
    );
  }

  Widget _row(String label, String value,
      {Color? valueColor, bool bold = false, double fontSize = 13}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          Text(label, style: const TextStyle(fontSize: 13, color: Color(0xFF94A3B8))),
          const Spacer(),
          Text(value,
              style: TextStyle(
                  fontSize: fontSize,
                  fontWeight: bold ? FontWeight.bold : FontWeight.w600,
                  color: valueColor ?? const Color(0xFF1A1A2E))),
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE9ECEF)),
      ),
      child: Column(
        children: _steps.asMap().entries.map((e) {
          return _buildStep(e.value, e.key == _steps.length - 1);
        }).toList(),
      ),
    );
  }

  Widget _buildStep(Map<String, dynamic> step, bool isLast) {
    final bool done = step['done'] as bool;
    final bool active = step['active'] as bool;
    final String? subtitle = step['subtitle'] as String?;

    final Color circleColor = done
        ? const Color(0xFF4CAF50)
        : active
            ? const Color(0xFF3B5BDB)
            : const Color(0xFFE2E8F0);

    final Widget circleChild = done
        ? const Icon(Icons.check_rounded, color: Colors.white, size: 14)
        : active
            ? const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 14)
            : Text(
                '${_steps.indexWhere((s) => s['label'] == step['label']) + 1}',
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF94A3B8)),
              );

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 28, height: 28,
                decoration: BoxDecoration(color: circleColor, shape: BoxShape.circle),
                child: Center(child: circleChild),
              ),
              if (!isLast)
                Expanded(
                  child: Container(width: 2,
                      color: done ? const Color(0xFF4CAF50) : const Color(0xFFE2E8F0)),
                ),
            ],
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(step['label'] as String,
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: (done || active) ? const Color(0xFF1A1A2E) : const Color(0xFF94A3B8))),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      Text(step['time'] as String,
                          style: TextStyle(
                              fontSize: 12,
                              color: done ? const Color(0xFF3B5BDB) : const Color(0xFF94A3B8))),
                      if (subtitle != null) ...[
                        const Text('  •  ', style: TextStyle(fontSize: 10, color: Color(0xFF94A3B8))),
                        Text(subtitle,
                            style: const TextStyle(fontSize: 12, color: Color(0xFF3B5BDB), fontWeight: FontWeight.w500)),
                      ],
                    ],
                  ),
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
        title: const Text('Batalkan Pesanan?',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1A1A2E))),
        content: const Text('Pesanan yang sudah dibatalkan tidak dapat dikembalikan.',
            style: TextStyle(fontSize: 13, color: Color(0xFF64748B))),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Kembali', style: TextStyle(color: Color(0xFF64748B))),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('Batalkan',
                style: TextStyle(color: Color(0xFFE53935), fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}