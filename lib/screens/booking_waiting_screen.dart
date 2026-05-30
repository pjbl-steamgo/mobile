import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'booking_confirmed_screen.dart';

class BookingWaitingScreen extends StatefulWidget {
  final String serviceName;
  final String date;
  final String vehicle;
  final String plateNumber;
  final String slot;
  final String price;

  const BookingWaitingScreen({
    super.key,
    required this.serviceName,
    required this.date,
    required this.vehicle,
    required this.plateNumber,
    required this.slot,
    required this.price,
  });

  @override
  State<BookingWaitingScreen> createState() => _BookingWaitingScreenState();
}

class _BookingWaitingScreenState extends State<BookingWaitingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _spinController;
  late final String _bookingCode;

  @override
  void initState() {
    super.initState();

    // Generate kode booking
    final now = DateTime.now();
    final rand = math.Random().nextInt(900) + 100;
    _bookingCode =
        'STG-${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}-$rand';

    _spinController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat();

    // Setelah 4 detik → BookingConfirmedScreen
    Future.delayed(const Duration(seconds: 4), () {
      if (!mounted) return;
      _spinController.stop();
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => BookingConfirmedScreen(
            serviceName: widget.serviceName,
            date: widget.date,
            vehicle: widget.vehicle,
            plateNumber: widget.plateNumber,
            slot: widget.slot,
            price: widget.price,
            bookingCode: _bookingCode,
          ),
          transitionDuration: const Duration(milliseconds: 400),
          transitionsBuilder: (_, anim, __, child) =>
              FadeTransition(opacity: anim, child: child),
        ),
      );
    });
  }

  @override
  void dispose() {
    _spinController.dispose();
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
                    // Spinner
                    RotationTransition(
                      turns: _spinController,
                      child: SizedBox(
                        width: 76,
                        height: 76,
                        child: CustomPaint(painter: _SpinnerPainter()),
                      ),
                    ),
                    const SizedBox(height: 28),
                    const Text('Booking Dalam Persetujuan',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1A1A2E))),
                    const SizedBox(height: 8),
                    const Text('Pesanan kamu sedang dikonfirmasi,\nsilahkan tunggu',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 13, color: Color(0xFF94A3B8), height: 1.6)),
                    const SizedBox(height: 28),
                    _DashedBox(
                      borderColor: const Color(0xFFCBD5E1),
                      child: Column(
                        children: [
                          const Text('KODE BOOKING',
                              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600,
                                  color: Color(0xFF94A3B8), letterSpacing: 2)),
                          const SizedBox(height: 8),
                          Text(_bookingCode,
                              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold,
                                  color: Color(0xFF1A1A2E), letterSpacing: 1)),
                        ],
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

// ── Spinner ──────────────────────────────────────────────────────────────────
class _SpinnerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const n = 12;
    final cx = size.width / 2;
    final cy = size.height / 2;
    final outerR = size.width / 2 - 2;
    final innerR = outerR * 0.54;
    for (int i = 0; i < n; i++) {
      final angle = (i / n) * 2 * math.pi - math.pi / 2;
      final paint = Paint()
        ..color = const Color(0xFF94A3B8).withOpacity((i + 1) / n)
        ..strokeWidth = 4.5
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(
        Offset(cx + innerR * math.cos(angle), cy + innerR * math.sin(angle)),
        Offset(cx + outerR * math.cos(angle), cy + outerR * math.sin(angle)),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_SpinnerPainter _) => false;
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
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
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
      ..color = color
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