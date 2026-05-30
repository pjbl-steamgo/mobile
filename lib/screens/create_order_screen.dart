import 'package:flutter/material.dart';
import 'booking_waiting_screen.dart';

class CreateOrderScreen extends StatefulWidget {
  const CreateOrderScreen({super.key});

  @override
  State<CreateOrderScreen> createState() => _CreateOrderScreenState();
}

class _CreateOrderScreenState extends State<CreateOrderScreen> {
  String? _selectedVehicle;
  String? _selectedService;
  String? _selectedSlot;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _plateController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();

  final List<Map<String, dynamic>> _vehicles = [
    {'label': 'Motor', 'icon': Icons.two_wheeler_rounded, 'color': const Color(0xFFE53935)},
    {'label': 'Mobil', 'icon': Icons.directions_car_rounded, 'color': const Color(0xFF1E88E5)},
  ];

  final List<Map<String, dynamic>> _services = [
    {'label': 'Steam Biasa', 'icon': Icons.water_drop_rounded, 'iconColor': const Color(0xFF9C64A6), 'iconBg': const Color(0xFFF3E5F5)},
    {'label': 'Snow Wash', 'icon': Icons.ac_unit_rounded, 'iconColor': const Color(0xFF00B4D8), 'iconBg': const Color(0xFFE0F7FA)},
    {'label': 'Detailing', 'icon': Icons.auto_awesome_rounded, 'iconColor': const Color(0xFFF59F00), 'iconBg': const Color(0xFFFFF9E6)},
  ];

  final List<String> _slots = [
    '08.00-09.00', '09.00-10.00', '10.00-11.00', '11.00-12.00',
    '13.00-14.00', '14.00-15.00', '15.00-16.00', '16.00-17.00',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _plateController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  String get _serviceSummary {
    if (_selectedVehicle == null || _selectedService == null) return '-';
    return '$_selectedService - $_selectedVehicle';
  }

  String get _dateSummary {
    if (_dateController.text.isEmpty || _selectedSlot == null) return '-';
    return '${_dateController.text}, ${_selectedSlot!.split('-').first}';
  }

  // Harga berdasarkan layanan & kendaraan
  String get _calculatedPrice {
    final Map<String, Map<String, String>> pricing = {
      'Steam Biasa': {'Motor': 'Rp. 20.000', 'Mobil': 'Rp. 40.000'},
      'Snow Wash':   {'Motor': 'Rp. 30.000', 'Mobil': 'Rp. 50.000'},
      'Detailing':   {'Motor': 'Rp. 120.000', 'Mobil': 'Rp. 250.000'},
    };
    return pricing[_selectedService]?[_selectedVehicle] ?? 'Rp. 20.000';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: Color(0xFF1A1A2E)),
        title: const Text(
          'Buat Pesanan',
          style: TextStyle(color: Color(0xFF1A1A2E), fontSize: 18, fontWeight: FontWeight.bold),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: const Color(0xFFE9ECEF)),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // ── PILIH KENDARAAN ──
            _sectionTitle('Pilih Kendaraan'),
            const SizedBox(height: 10),
            Row(
              children: _vehicles.asMap().entries.map((e) {
                final v = e.value;
                final bool sel = _selectedVehicle == v['label'];
                final Color col = v['color'] as Color;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedVehicle = v['label']),
                    child: Container(
                      margin: EdgeInsets.only(right: e.key == 0 ? 8 : 0),
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      decoration: BoxDecoration(
                        color: sel ? col.withOpacity(0.06) : Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: sel ? col : const Color(0xFFE9ECEF), width: sel ? 2 : 1),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 6, offset: const Offset(0, 2))],
                      ),
                      child: Column(
                        children: [
                          Icon(v['icon'] as IconData, size: 40, color: col),
                          const SizedBox(height: 8),
                          Text(v['label'] as String,
                              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold,
                                  color: sel ? col : const Color(0xFF1A1A2E))),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 20),

            // ── PILIH LAYANAN ──
            _sectionTitle('Pilih Layanan'),
            const SizedBox(height: 10),
            Row(
              children: _services.asMap().entries.map((e) {
                final s = e.value;
                final bool sel = _selectedService == s['label'];
                final Color accent = s['iconColor'] as Color;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedService = s['label']),
                    child: Container(
                      margin: EdgeInsets.only(right: e.key < _services.length - 1 ? 8 : 0),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: sel ? accent.withOpacity(0.06) : Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: sel ? accent : const Color(0xFFE9ECEF), width: sel ? 2 : 1),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 6, offset: const Offset(0, 2))],
                      ),
                      child: Column(
                        children: [
                          Container(
                            width: 46, height: 46,
                            decoration: BoxDecoration(color: s['iconBg'] as Color, borderRadius: BorderRadius.circular(12)),
                            child: Icon(s['icon'] as IconData, size: 24, color: accent),
                          ),
                          const SizedBox(height: 8),
                          Text(s['label'] as String,
                              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600,
                                  color: sel ? accent : const Color(0xFF1A1A2E))),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 20),

            // ── NAMA KENDARAAN ──
            _sectionTitle('Nama Kendaraan'),
            const SizedBox(height: 8),
            _buildTextField(controller: _nameController, hint: 'Cth : Honda Beat'),

            const SizedBox(height: 14),

            // ── NOMOR POLISI ──
            _sectionTitle('Nomor Polisi'),
            const SizedBox(height: 8),
            _buildTextField(controller: _plateController, hint: 'Cth : B 5678 XYZ'),

            const SizedBox(height: 14),

            // ── TANGGAL KEDATANGAN ──
            _sectionTitle('Tanggal Kedatangan'),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 30)),
                  builder: (ctx, child) => Theme(
                    data: Theme.of(ctx).copyWith(colorScheme: const ColorScheme.light(primary: Color(0xFF3B5BDB))),
                    child: child!,
                  ),
                );
                if (picked != null) {
                  setState(() {
                    _dateController.text =
                        '${picked.day.toString().padLeft(2,'0')}/${picked.month.toString().padLeft(2,'0')}/${picked.year}';
                  });
                }
              },
              child: AbsorbPointer(
                child: _buildTextField(
                  controller: _dateController,
                  hint: 'Cth : 19/03/2026',
                  suffixIcon: Icons.calendar_month_rounded,
                ),
              ),
            ),

            const SizedBox(height: 20),

            // ── PILIH JAM ──
            _sectionTitle('Pilih Jam'),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _slots.map((slot) {
                final bool sel = _selectedSlot == slot;
                return GestureDetector(
                  onTap: () => setState(() => _selectedSlot = slot),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: sel ? const Color(0xFF3B5BDB) : Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: sel ? const Color(0xFF3B5BDB) : const Color(0xFFE9ECEF)),
                    ),
                    child: Text(slot,
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600,
                            color: sel ? Colors.white : const Color(0xFF475569))),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 24),

            // ── RINGKASAN PESANAN ──
            _sectionTitle('Ringkasan Pesanan'),
            const SizedBox(height: 10),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFE9ECEF)),
              ),
              child: Column(
                children: [
                  _summaryRow('Layanan', _serviceSummary),
                  _divider(),
                  _summaryRow('Tanggal', _dateSummary),
                  _divider(),
                  _summaryRow('Kendaraan', _nameController.text.isEmpty ? '-' : _nameController.text),
                  _divider(),
                  _summaryRow('Pembayaran', 'Transfer Bank'),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ── TOMBOL BUAT PESANAN ──
            GestureDetector(
              onTap: () {
                if (_selectedVehicle == null ||
                    _selectedService == null ||
                    _nameController.text.isEmpty ||
                    _plateController.text.isEmpty ||
                    _dateController.text.isEmpty ||
                    _selectedSlot == null) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: const Text('Harap lengkapi semua data pesanan'),
                    backgroundColor: Colors.redAccent,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ));
                  return;
                }
                // ✅ Navigasi ke BookingWaitingScreen
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => BookingWaitingScreen(
                      serviceName: _serviceSummary,
                      date: _dateController.text,
                      vehicle: _nameController.text,
                      plateNumber: _plateController.text,
                      slot: _selectedSlot!,
                      price: _calculatedPrice,
                    ),
                  ),
                );
              },
              child: Container(
                width: double.infinity,
                height: 52,
                decoration: BoxDecoration(
                  color: const Color(0xFF3B5BDB),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Center(
                  child: Text('Buat Pesanan',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) => Padding(
        padding: const EdgeInsets.only(bottom: 2),
        child: Text(title,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1A1A2E))),
      );

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    IconData? suffixIcon,
  }) {
    return TextField(
      controller: controller,
      onChanged: (_) => setState(() {}),
      style: const TextStyle(fontSize: 13, color: Color(0xFF1A1A2E)),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Color(0xFFCBD5E1), fontSize: 13),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        suffixIcon: suffixIcon != null
            ? Icon(suffixIcon, size: 20, color: const Color(0xFF94A3B8))
            : null,
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE9ECEF))),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFF3B5BDB), width: 1.5)),
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }

  Widget _summaryRow(String label, String value) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            Text(label, style: const TextStyle(fontSize: 13, color: Color(0xFF94A3B8))),
            const Spacer(),
            Flexible(
              child: Text(value,
                  textAlign: TextAlign.right,
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF1A1A2E))),
            ),
          ],
        ),
      );

  Widget _divider() => const Divider(height: 1, indent: 14, endIndent: 14, color: Color(0xFFF1F5F9));
}