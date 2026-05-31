import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

// Pastikan import ini mengarah ke file Booking Waiting Screen kamu
import 'booking_waiting_screen.dart'; 

class CreateOrderScreen extends StatefulWidget {
  const CreateOrderScreen({super.key});

  @override
  State<CreateOrderScreen> createState() => _CreateOrderScreenState();
}

class _CreateOrderScreenState extends State<CreateOrderScreen> {
  // --- STATE VARIABEL ---
  bool _isLoadingServices = true;
  bool _isSubmitting = false; 
  List<dynamic> _servicesList = []; 

  // Pilihan User
  String _selectedCategory = 'Motor'; 
  Map<String, dynamic>? _selectedService;
  DateTime _selectedDate = DateTime.now();
  String? _selectedTime;

  // Controller Input
  final TextEditingController _vehicleNameController = TextEditingController();
  final TextEditingController _plateNumberController = TextEditingController();

  // Kategori Kendaraan Fix
  final List<Map<String, dynamic>> _categories = [
    {'nama': 'Motor', 'icon': Icons.two_wheeler_rounded, 'aktif': true},
    {'nama': 'Mobil', 'icon': Icons.directions_car_rounded, 'aktif': true},
  ];

  // Jam Operasional (Sampai 20:00)
  final List<String> _timeSlots = [
    '08:00 - 09:00', '09:00 - 10:00', '10:00 - 11:00',
    '11:00 - 12:00', '13:00 - 14:00', '14:00 - 15:00',
    '15:00 - 16:00', '16:00 - 17:00', '17:00 - 18:00',
    '18:00 - 19:00', '19:00 - 20:00',
  ];

  @override
  void initState() {
    super.initState();
    _fetchServices();
    
    // Agar ringkasan otomatis update saat mengetik nama kendaraan/plat
    _vehicleNameController.addListener(() => setState(() {}));
    _plateNumberController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _vehicleNameController.dispose();
    _plateNumberController.dispose();
    super.dispose();
  }

  // --- MENGAMBIL LAYANAN DARI API LARAVEL ---
  Future<void> _fetchServices() async {
    final String apiUrl = 'http://192.168.1.14:8000/api/services';
    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success']) {
          setState(() {
            _servicesList = data['data'];
            _isLoadingServices = false;
          });
        }
      }
    } catch (e) {
      debugPrint("Gagal mengambil data layanan: $e");
      setState(() => _isLoadingServices = false);
    }
  }

  // --- MENGIRIM PESANAN KE API LARAVEL ---
  Future<void> _submitOrder() async {
    setState(() => _isSubmitting = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('id_user') ?? "";

      if (userId.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Sesi login habis, silakan login kembali.')));
        setState(() => _isSubmitting = false);
        return;
      }

      final String apiUrl = 'http://192.168.1.14:8000/api/orders';
      
      String tanggalTampil = "${DateFormat('dd MMMM yyyy', 'id_ID').format(_selectedDate)}, $_selectedTime";
      String layananId = _selectedService?['_id'] ?? _selectedService?['id'] ?? "";

      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'user_id': userId,
          'layanan_id': layananId,
          'kendaraan': _vehicleNameController.text,
          'plat_nomor': _plateNumberController.text,
          'tanggal': tanggalTampil,
          'total_harga': _selectedService?['harga'] ?? 0,
        }),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        
        // Tangkap ID yang dikembalikan oleh Laravel
        final String orderId = responseData['data']['_id'] ?? responseData['data']['id'];
        
        // Tangkap Kode Pesanan yang di-generate Laravel (contoh: STG-8A9B2C)
        final String bookingCode = responseData['data']['kode_pesanan'] ?? '-';

        if (mounted) {
          // Ganti layar ke Waiting Screen, sambil membawa semua data yang dibutuhkan
          Navigator.pushReplacement(
            context, 
            MaterialPageRoute(
              builder: (_) => BookingWaitingScreen(
                orderId: orderId,
                serviceName: "${_selectedService?['nama_layanan']} ($_selectedCategory)",
                date: tanggalTampil,
                vehicle: _vehicleNameController.text,
                plateNumber: _plateNumberController.text,
                price: "Rp ${_selectedService?['harga'] ?? 0}",
                bookingCode: bookingCode,
              )
            )
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Gagal membuat pesanan. Silakan coba lagi.')));
      }
    } catch (e) {
      debugPrint("Error submit: $e");
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Terjadi kesalahan koneksi jaringan.')));
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  // --- PEMILIH TANGGAL ---
  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 14)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: Color(0xFF3B5BDB)),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _selectedTime = null; 
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    List<dynamic> displayedServices = _servicesList.where((service) {
      return service['kategori'] == _selectedCategory;
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A237E),
        elevation: 0,
        centerTitle: true,
        title: const Text('Buat Pesanan Baru', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                // 1. KATEGORI KENDARAAN
                _buildSectionTitle('Kategori Kendaraan', Icons.category_rounded),
                const SizedBox(height: 12),
                Row(
                  children: _categories.map((cat) {
                    bool isSelected = _selectedCategory == cat['nama'];
                    bool isActive = cat['aktif'];
                    return Expanded(
                      child: GestureDetector(
                        onTap: isActive 
                            ? () {
                                setState(() {
                                  _selectedCategory = cat['nama'];
                                  _selectedService = null; 
                                });
                              } 
                            : null,
                        child: Container(
                          margin: const EdgeInsets.only(right: 10),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(
                            color: isActive 
                                ? (isSelected ? const Color(0xFF3B5BDB) : Colors.white) 
                                : Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: isSelected ? const Color(0xFF3B5BDB) : Colors.grey.shade300),
                            boxShadow: isActive && !isSelected ? [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 4)] : [],
                          ),
                          child: Column(
                            children: [
                              Icon(cat['icon'], color: isActive ? (isSelected ? Colors.white : const Color(0xFF3B5BDB)) : Colors.grey.shade500),
                              const SizedBox(height: 8),
                              Text(cat['nama'], style: TextStyle(
                                fontSize: 13, 
                                fontWeight: FontWeight.bold, 
                                color: isActive ? (isSelected ? Colors.white : const Color(0xFF1A1A2E)) : Colors.grey.shade500,
                              )),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),

                // 2. PILIH LAYANAN
                _buildSectionTitle('Pilih Layanan ($_selectedCategory)', Icons.local_car_wash_rounded),
                const SizedBox(height: 12),
                _isLoadingServices
                    ? const Center(child: CircularProgressIndicator())
                    : displayedServices.isEmpty
                        ? const Text("Layanan untuk kategori ini belum tersedia.", style: TextStyle(color: Colors.grey))
                        : Wrap(
                            spacing: 12,
                            runSpacing: 12,
                            children: displayedServices.map((service) {
                              
                              bool isSelected = _selectedService != null && 
                                  ((service['_id'] != null && _selectedService!['_id'] == service['_id']) ||
                                   (service['id'] != null && _selectedService!['id'] == service['id']));
                              
                              bool isActive = service['is_active'] ?? true;

                              return GestureDetector(
                                onTap: isActive ? () => setState(() => _selectedService = service) : null,
                                child: Container(
                                  width: (MediaQuery.of(context).size.width / 2) - 26, 
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: isActive 
                                        ? (isSelected ? const Color(0xFFE8F0FE) : Colors.white)
                                        : Colors.grey.shade200, 
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: isActive 
                                          ? (isSelected ? const Color(0xFF3B5BDB) : Colors.grey.shade300) 
                                          : Colors.grey.shade300,
                                      width: isSelected ? 1.5 : 1.0,
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              service['nama_layanan'] ?? 'Layanan', 
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold, fontSize: 13, 
                                                color: isActive ? const Color(0xFF1A1A2E) : Colors.grey.shade500
                                              )
                                            ),
                                          ),
                                          if (!isActive)
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                              decoration: BoxDecoration(color: Colors.grey.shade400, borderRadius: BorderRadius.circular(4)),
                                              child: const Text('Tutup', style: TextStyle(fontSize: 8, color: Colors.white, fontWeight: FontWeight.bold)),
                                            )
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Rp ${service['harga'] ?? 0}', 
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold, fontSize: 12, 
                                          color: isActive ? const Color(0xFF3B5BDB) : Colors.grey.shade500
                                        )
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                const SizedBox(height: 24),

                // 3. DETAIL KENDARAAN
                _buildSectionTitle('Detail Kendaraan', Icons.directions_car_rounded),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _vehicleNameController,
                  textCapitalization: TextCapitalization.words, 
                  decoration: _inputStyle('Merek & Tipe (cth: Honda Brio)'),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _plateNumberController,
                  textCapitalization: TextCapitalization.characters, 
                  inputFormatters: [LengthLimitingTextInputFormatter(11)],
                  decoration: _inputStyle('Nomor Polisi (cth: B 1234 XYZ)'),
                ),
                const SizedBox(height: 24),

                // 4. WAKTU KEDATANGAN
                _buildSectionTitle('Waktu Kedatangan', Icons.calendar_month_rounded),
                const SizedBox(height: 12),
                GestureDetector(
                  onTap: _pickDate,
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade300)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(_selectedDate), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                        const Icon(Icons.edit_calendar_rounded, size: 20, color: Color(0xFF3B5BDB)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: _timeSlots.map((time) {
                    bool isSelected = _selectedTime == time;
                    bool isPast = false;
                    
                    if (_selectedDate.day == DateTime.now().day && _selectedDate.month == DateTime.now().month && _selectedDate.year == DateTime.now().year) {
                      int jamMulai = int.parse(time.split(':')[0]);
                      if (jamMulai <= DateTime.now().hour) {
                        isPast = true;
                      }
                    }

                    return GestureDetector(
                      onTap: isPast ? null : () => setState(() => _selectedTime = time),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: isPast 
                              ? Colors.grey.shade200 
                              : (isSelected ? const Color(0xFF3B5BDB) : Colors.white),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: isPast ? Colors.transparent : (isSelected ? const Color(0xFF3B5BDB) : Colors.grey.shade300)),
                        ),
                        child: Text(
                          time, 
                          style: TextStyle(
                            fontSize: 12, fontWeight: FontWeight.bold,
                            color: isPast ? Colors.grey.shade400 : (isSelected ? Colors.white : const Color(0xFF1A1A2E)),
                          )
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 32),

                // 5. RINGKASAN & PEMBAYARAN
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.shade200)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Ringkasan Pesanan', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      const Divider(height: 24),
                      _summaryRow('Layanan', _selectedService?['nama_layanan'] ?? '-'),
                      _summaryRow('Kategori', _selectedCategory), 
                      _summaryRow('Kendaraan', _vehicleNameController.text.isEmpty ? '-' : _vehicleNameController.text),
                      _summaryRow('Nomor Polisi', _plateNumberController.text.isEmpty ? '-' : _plateNumberController.text),
                      _summaryRow('Jadwal', _selectedTime == null ? '-' : "${DateFormat('dd/MM').format(_selectedDate)}, $_selectedTime"),
                      const Divider(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Total Pembayaran', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1A1A2E))),
                          Text('Rp ${_selectedService?['harga'] ?? 0}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF3B5BDB))),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Keterangan Pembayaran
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        decoration: BoxDecoration(color: const Color(0xFFFFF3CD), borderRadius: BorderRadius.circular(8)),
                        child: Row(
                          children: const [
                            Icon(Icons.access_time_rounded, color: Color(0xFFB78103), size: 18),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Metode Pembayaran: QRIS (Tersedia setelah booking dikonfirmasi Admin)', 
                                style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF92400E)),
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // 6. TOMBOL SUBMIT
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))],
            ),
            child: SafeArea(
              child: ElevatedButton(
                onPressed: (_selectedService == null || _vehicleNameController.text.isEmpty || _plateNumberController.text.isEmpty || _selectedTime == null || _isSubmitting)
                    ? null
                    : _submitOrder, 
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3B5BDB),
                  disabledBackgroundColor: Colors.grey.shade300,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: _isSubmitting 
                    ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text('Konfirmasi & Buat Pesanan', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper Widget
  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 18, color: const Color(0xFF64748B)),
        const SizedBox(width: 8),
        Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1A1A2E))),
      ],
    );
  }

  InputDecoration _inputStyle(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF3B5BDB))),
    );
  }

  Widget _summaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
          Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF1A1A2E))),
        ],
      ),
    );
  }
}