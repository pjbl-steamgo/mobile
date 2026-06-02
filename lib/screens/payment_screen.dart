import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../config/api_service.dart'; // ── IMPORT CLEAN CODE API ──
import 'payment_waiting_screen.dart';

class PaymentScreen extends StatefulWidget {
  final String orderId;
  final String price;
  
  final String serviceName;
  final String date;
  final String vehicle;
  final String plateNumber;
  final String bookingCode;

  const PaymentScreen({
    super.key, 
    required this.orderId, 
    required this.price,
    required this.serviceName, 
    required this.date, 
    required this.vehicle,
    required this.plateNumber, 
    required this.bookingCode,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  File? _image;
  bool _isUploading = false;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() => _image = File(pickedFile.path));
    }
  }

  // ── PENGIRIMAN GAMBAR MENGGUNAKAN API SERVICE MULTIPART ──
  Future<void> _uploadPayment() async {
    if (_image == null) return;
    setState(() => _isUploading = true);

    try {
      final response = await ApiService.multipartPost(
        '/orders/${widget.orderId}/payment',
        {}, // Tidak ada text field tambahan
        filePath: _image!.path,
        fileField: 'bukti_pembayaran' // Nama key field file gambar di Laravel
      );

      if (response != null && response.statusCode == 200) {
        if (!mounted) return;
        
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => PaymentWaitingScreen(
            orderId: widget.orderId, 
            serviceName: widget.serviceName,
            date: widget.date, 
            vehicle: widget.vehicle, 
            plateNumber: widget.plateNumber, 
            price: widget.price, 
            bookingCode: widget.bookingCode,
          )),
        );
      } else if (response != null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Gagal mengunggah bukti pembayaran.")));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Terjadi kesalahan jaringan.")));
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Pembayaran', style: TextStyle(color: Colors.black, fontSize: 16)), 
        backgroundColor: Colors.white, 
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white, 
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))
                ]
              ),
              child: Column(
                children: [
                  const Text('Scan QRIS untuk Membayar', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  const SizedBox(height: 16),
                  
                  Image.asset('assets/images/qris.jpg', height: 250), 
                  
                  const SizedBox(height: 16),
                  const Text('Total Tagihan', style: TextStyle(color: Colors.grey, fontSize: 12)),
                  const SizedBox(height: 4),
                  Text(widget.price, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF3B5BDB))),
                ],
              ),
            ),
            const SizedBox(height: 24),

            GestureDetector(
              onTap: _pickImage,
              child: Container(
                width: double.infinity,
                height: 150,
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.grey.shade300, style: BorderStyle.solid),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: _image != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(12), 
                        child: Image.file(_image!, fit: BoxFit.cover)
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.cloud_upload_outlined, size: 40, color: Colors.grey),
                          SizedBox(height: 8),
                          Text(
                            'Ketuk untuk upload bukti transfer\n(JPG/PNG)', 
                            textAlign: TextAlign.center, 
                            style: TextStyle(color: Colors.grey, fontSize: 12)
                          ),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: 32),

            ElevatedButton(
              onPressed: (_image == null || _isUploading) ? null : _uploadPayment,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3B5BDB), 
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                disabledBackgroundColor: Colors.grey.shade300,
              ),
              child: _isUploading 
                ? const SizedBox(
                    width: 20, height: 20, 
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                  )
                : const Text('Kirim Bukti Pembayaran', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
            )
          ],
        ),
      ),
    );
  }
}