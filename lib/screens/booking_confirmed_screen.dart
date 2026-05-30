import 'package:flutter/material.dart';
import 'order_detail_screen.dart';
import 'order_repository.dart';

class BookingConfirmedScreen extends StatefulWidget {
  final String serviceName;
  final String date;
  final String vehicle;
  final String plateNumber;
  final String slot;
  final String price;
  final String bookingCode;

  const BookingConfirmedScreen({
    super.key,
    required this.serviceName,
    required this.date,
    required this.vehicle,
    required this.plateNumber,
    required this.slot,
    required this.price,
    required this.bookingCode,
  });

  @override
  State<BookingConfirmedScreen> createState() => _BookingConfirmedScreenState();
}

class _BookingConfirmedScreenState extends State<BookingConfirmedScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _scaleCtrl;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();

    // Tambah ke riwayat pesanan
    OrderRepository.instance.addOrder(OrderItem(
      serviceName: widget.serviceName,
      date: widget.date,
      vehicle: widget.vehicle,
      plateNumber: widget.plateNumber,
      price: widget.price,
      status: OrderStatus.proses,
    ));

    // Animasi pop-in ikon centang
    _scaleCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    _scaleAnim = CurvedAnimation(parent: _scaleCtrl, curve: Curves.elasticOut);
    _scaleCtrl.forward();
  }

  @override
  void dispose() {
    _scaleCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        // Tidak ada AppBar
        body: Stack(
          children: [
            // Dim overlay
            Positioned.fill(child: Container(color: Colors.black.withOpacity(0.45))),

            // Bottom modal
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                ),
                padding: const EdgeInsets.fromLTRB(28, 36, 28, 52),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // ── Ikon centang dengan animasi ──
                    ScaleTransition(
                      scale: _scaleAnim,
                      child: Container(
                        width: 72,
                        height: 72,
                        decoration: const BoxDecoration(
                          color: Color(0xFF4CAF50),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.check_rounded, color: Colors.white, size: 36),
                      ),
                    ),
                    const SizedBox(height: 20),

                    const Text('Booking Berhasil',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1A1A2E))),
                    const SizedBox(height: 8),
                    const Text('Pesanan kamu sudah dikonfirmasi,\nsilahkan datang sesuai jadwal',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 13, color: Color(0xFF94A3B8), height: 1.6)),
                    const SizedBox(height: 28),

                    // ── Kode booking (dashed biru) ──
                    _DashedBox(
                      borderColor: const Color(0xFF3B5BDB),
                      child: Column(
                        children: [
                          const Text('KODE BOOKING',
                              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600,
                                  color: Color(0xFF3B5BDB), letterSpacing: 2)),
                          const SizedBox(height: 8),
                          Text(widget.bookingCode,
                              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold,
                                  color: Color(0xFF1A1A2E), letterSpacing: 1.2)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // ── Tombol Lihat Status Antrian ──
                    GestureDetector(
                      onTap: () {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder: (_) => OrderDetailScreen(
                              serviceName: widget.serviceName,
                              date: widget.date,
                              vehicle: widget.vehicle,
                              plateNumber: widget.plateNumber,
                              slot: widget.slot,
                              price: widget.price,
                              bookingCode: widget.bookingCode,
                            ),
                          ),
                          (route) => route.isFirst,
                        );
                      },
                      child: Container(
                        width: double.infinity,
                        height: 52,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF00B4D8), Color(0xFF0096C7)],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Center(
                          child: Text('Lihat Status Antrian',
                              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Dashed border box ─────────────────────────────────────────────────────────
class _DashedBox extends StatelessWidget {
  final Widget child;
  final Color borderColor;
  const _DashedBox({required this.child, required this.borderColor});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DashedPainter(color: borderColor),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
        child: Center(child: child),
      ),
    );
  }
}

class _DashedPainter extends CustomPainter {
  final Color color;
  const _DashedPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withOpacity(0.6)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    const dw = 8.0;
    const ds = 5.0;
    final path = Path()
      ..addRRect(RRect.fromRectAndRadius(
          Rect.fromLTWH(0, 0, size.width, size.height), const Radius.circular(14)));
    for (final m in path.computeMetrics()) {
      double d = 0;
      while (d < m.length) {
        final n = d + dw;
        canvas.drawPath(m.extractPath(d, n < m.length ? n : m.length), paint);
        d += dw + ds;
      }
    }
  }

  @override
  bool shouldRepaint(_DashedPainter o) => o.color != color;
}