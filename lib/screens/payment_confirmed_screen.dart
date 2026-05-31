import 'package:flutter/material.dart';
import 'order_detail_screen.dart';

class PaymentConfirmedScreen extends StatefulWidget {
  final String orderId, serviceName, date, vehicle, plateNumber, price, bookingCode, slot;

  const PaymentConfirmedScreen({
    super.key, required this.orderId, required this.serviceName, required this.date,
    required this.vehicle, required this.plateNumber, required this.price, 
    required this.bookingCode, required this.slot,
  });

  @override
  State<PaymentConfirmedScreen> createState() => _PaymentConfirmedScreenState();
}

class _PaymentConfirmedScreenState extends State<PaymentConfirmedScreen> with SingleTickerProviderStateMixin {
  late AnimationController _scaleCtrl;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _scaleCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
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
        backgroundColor: Colors.white,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ScaleTransition(
                  scale: _scaleAnim,
                  child: Container(
                    width: 80, height: 80,
                    decoration: const BoxDecoration(color: Color(0xFF4CAF50), shape: BoxShape.circle),
                    child: const Icon(Icons.check_rounded, color: Colors.white, size: 40),
                  ),
                ),
                const SizedBox(height: 24),
                const Text('Pembayaran Berhasil!', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                Text('Status pesanan Anda saat ini adalah: ${widget.slot.toUpperCase()}', style: const TextStyle(color: Colors.grey), textAlign: TextAlign.center),
                const SizedBox(height: 40),
                ElevatedButton(
                  onPressed: () {
                    // Pindah ke Order Detail Screen dengan membawa orderId dan estimasiWaktu
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (_) => OrderDetailScreen(
                          orderId: widget.orderId, 
                          serviceName: widget.serviceName,
                          date: widget.date,
                          vehicle: widget.vehicle,
                          plateNumber: widget.plateNumber,
                          slot: widget.slot,
                          price: widget.price,
                          bookingCode: widget.bookingCode,
                          estimasiWaktu: 'Menunggu Giliran', // <-- TAMBAHAN PERBAIKANNYA DI SINI
                        ),
                      ),
                      (route) => route.isFirst,
                    );
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF3B5BDB), minimumSize: const Size(double.infinity, 50)),
                  child: const Text('Lihat Detail Pesanan', style: TextStyle(color: Colors.white)),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}