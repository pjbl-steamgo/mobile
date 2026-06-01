import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'payment_confirmed_screen.dart';

class PaymentWaitingScreen extends StatefulWidget {
  final String orderId, serviceName, date, vehicle, plateNumber, price, bookingCode;

  const PaymentWaitingScreen({
    super.key, required this.orderId, required this.serviceName, required this.date,
    required this.vehicle, required this.plateNumber, required this.price, required this.bookingCode,
  });

  @override
  State<PaymentWaitingScreen> createState() => _PaymentWaitingScreenState();
}

class _PaymentWaitingScreenState extends State<PaymentWaitingScreen> {
  Timer? _pollingTimer;
  bool _isDisposed = false;

  @override
  void initState() {
    super.initState();
    _startPolling();
  }

  @override
  void dispose() {
    _isDisposed = true;
    _pollingTimer?.cancel();
    super.dispose();
  }

  void _startPolling() {
    _pollingTimer = Timer.periodic(const Duration(seconds: 3), (timer) async {
      if (_isDisposed) {
        timer.cancel();
        return;
      }

      try {
        final response = await http.get(Uri.parse('http://192.168.100.36:8000/api/orders/status/${widget.orderId}'));
        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          if (data['success'] == true) {
            String status = data['status'];
            
            // Jika admin sudah ACC pembayaran (jadi Antri atau Proses)
            if (status == 'Antri' || status == 'Proses') {
              timer.cancel();
              if (mounted) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => PaymentConfirmedScreen(
                    orderId: widget.orderId, serviceName: widget.serviceName, date: widget.date,
                    vehicle: widget.vehicle, plateNumber: widget.plateNumber, price: widget.price,
                    bookingCode: widget.bookingCode, slot: status, 
                  )),
                );
              }
            }
            // Jika ditolak/dihapus
            else if (status == 'Dihapus') {
              timer.cancel();
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Pesanan dibatalkan/ditolak admin.')));
                Navigator.pop(context);
              }
            }
          }
        }
      } catch (e) {
        debugPrint("Polling error: $e");
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // WillPopScope mematikan timer saat user menekan back di HP
    return WillPopScope(
      onWillPop: () async {
        _pollingTimer?.cancel();
        return true; // Mengizinkan user untuk back
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () {
              _pollingTimer?.cancel();
              Navigator.pop(context); // Kembali ke Riwayat Pesanan
            },
          ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(color: Color(0xFF3B5BDB)),
              const SizedBox(height: 32),
              const Text('Verifikasi Pembayaran', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 40),
                child: Text('Pembayaran berhasil dikirim.\nPembayaran kamu sedang diverifikasi oleh admin kami, mohon tunggu sebentar.', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey, height: 1.5)),
              ),
              const SizedBox(height: 40),
              
              // Tambahan box info agar user tahu ini aman untuk di-back
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 40),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(8)),
                child: const Text('Kamu bisa menutup halaman ini. Status pesanan dapat dicek kembali melalui menu Riwayat Pesanan.', textAlign: TextAlign.center, style: TextStyle(fontSize: 11, color: Colors.grey)),
              )
            ],
          ),
        ),
      ),
    );
  }
}