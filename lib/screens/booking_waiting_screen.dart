import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:async';

import '../config/api_service.dart'; // ── IMPORT CLEAN CODE API ──
import 'booking_confirmed_screen.dart'; 

class BookingWaitingScreen extends StatefulWidget {
  final String orderId;
  final String serviceName;
  final String date;
  
  // Data tambahan untuk diteruskan hingga ke bukti pembayaran
  final String vehicle;
  final String plateNumber;
  final String price;
  final String bookingCode;

  const BookingWaitingScreen({
    super.key,
    required this.orderId,
    required this.serviceName,
    required this.date,
    required this.vehicle,
    required this.plateNumber,
    required this.price,
    required this.bookingCode,
  });

  @override
  State<BookingWaitingScreen> createState() => _BookingWaitingScreenState();
}

class _BookingWaitingScreenState extends State<BookingWaitingScreen> {
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

  // --- FUNGSI PENGECEKAN STATUS KE SERVER (MENGGUNAKAN API SERVICE) ---
  void _startPolling() {
    _pollingTimer = Timer.periodic(const Duration(seconds: 3), (timer) async {
      if (_isDisposed) {
        timer.cancel();
        return;
      }

      try {
        // ── PANGGILAN API CLEAN CODE ──
        final response = await ApiService.get('/orders/status/${widget.orderId}');
        
        if (response != null && response.statusCode == 200) {
          final data = jsonDecode(response.body);
          
          if (data['success'] == true) {
            String currentStatus = data['status'];
            
            // JIKA ADMIN SUDAH MENGKONFIRMASI JADWAL
            if (currentStatus == 'Belum Bayar') {
              timer.cancel(); 
              
              if (mounted) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => BookingConfirmedScreen(
                      orderId: widget.orderId,
                      serviceName: widget.serviceName,
                      date: widget.date,
                      vehicle: widget.vehicle,
                      plateNumber: widget.plateNumber,
                      slot: '-', 
                      price: widget.price,
                      bookingCode: widget.bookingCode,
                    ), 
                  )
                );
              }
            }
            // Jika pesanan ditolak/dihapus
            else if (currentStatus == 'Dihapus') {
              timer.cancel();
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(data['message'] ?? 'Pesanan dibatalkan/ditolak.'))
                );
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
    return WillPopScope(
      onWillPop: () async {
        _pollingTimer?.cancel(); 
        return true; 
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
              Navigator.pop(context); 
            },
          ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(color: Color(0xFF3B5BDB)),
              const SizedBox(height: 32),
              const Text(
                'Menunggu Konfirmasi Admin...',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1A1A2E)),
              ),
              const SizedBox(height: 12),
              Text(
                widget.serviceName,
                style: const TextStyle(fontSize: 15, color: Color(0xFF3B5BDB), fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 4),
              Text(
                widget.date,
                style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 40),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 40),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200)
                ),
                child: Column(
                  children: [
                    const Icon(Icons.info_outline_rounded, color: Color(0xFF64748B), size: 24),
                    const SizedBox(height: 8),
                    Text(
                      'Mohon jangan tutup halaman ini.\nPesanan Anda sedang ditinjau ketersediaannya oleh admin kami.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade600, height: 1.5),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}