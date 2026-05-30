import 'package:flutter/material.dart';
import 'order_repository.dart';
import 'create_order_screen.dart';
import 'order_detail_screen.dart';

class OrderScreen extends StatefulWidget {
  const OrderScreen({super.key});

  @override
  State<OrderScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  @override
  void initState() {
    super.initState();
    // Dengarkan perubahan repository
    OrderRepository.instance.addListener(_onOrderChanged);
  }

  void _onOrderChanged() => setState(() {});

  @override
  void dispose() {
    OrderRepository.instance.removeListener(_onOrderChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final orders = OrderRepository.instance.orders;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80),
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF1A237E), Color(0xFF3B5BDB)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(24),
              bottomRight: Radius.circular(24),
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.receipt_long_rounded,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Pesanan',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Riwayat & status pesananmu',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.75),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ── Header riwayat + tombol tambah ──
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Riwayat Transaksi',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF1A1A2E))),
              GestureDetector(
                onTap: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const CreateOrderScreen()));
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F5E9),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFF4CAF50)),
                  ),
                  child: const Text('Tambah Pesanan',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF2E7D32))),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // ── Daftar pesanan ──
          if (orders.isEmpty)
            const Padding(
              padding: EdgeInsets.only(top: 40),
              child: Center(
                child: Text('Belum ada pesanan',
                    style: TextStyle(fontSize: 14, color: Color(0xFF94A3B8))),
              ),
            )
          else
            ...orders.map((order) => _buildOrderCard(context, order)),
        ],
      ),
    );
  }

  Widget _buildOrderCard(BuildContext context, OrderItem order) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => OrderDetailScreen(
              serviceName: order.serviceName,
              date: order.date,
              vehicle: order.vehicle,
              plateNumber: order.plateNumber,
              slot: '',
              price: order.price,
              bookingCode: 'STG-00000000-000',
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE9ECEF), width: 0.8),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8, offset: const Offset(0, 2))
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Baris 1: nama + badge
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(order.serviceName,
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1A1A2E))),
                        const SizedBox(height: 3),
                        Text(order.date,
                            style: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8))),
                      ],
                    ),
                  ),
                  _buildBadge(order.status),
                ],
              ),

              const SizedBox(height: 10),
              const Divider(height: 1, color: Color(0xFFF1F5F9)),
              const SizedBox(height: 10),

              // Baris 2: kendaraan + tombol aksi
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.two_wheeler_rounded, size: 14, color: Color(0xFF64748B)),
                            const SizedBox(width: 6),
                            Text(order.vehicle,
                                style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 5),
                              child: Text('•', style: TextStyle(fontSize: 10, color: Color(0xFF94A3B8))),
                            ),
                            Text(order.plateNumber,
                                style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                          ],
                        ),
                        const SizedBox(height: 5),
                        Text(order.price,
                            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF1A1A2E))),
                      ],
                    ),
                  ),
                  _buildActionButton(order.status),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBadge(OrderStatus status) {
    switch (status) {
      case OrderStatus.proses:
        return _badge('Proses', const Color(0xFFE8F0FE), const Color(0xFF3B5BDB));
      case OrderStatus.selesai:
        return _badge('Selesai', const Color(0xFFF1F5F9), const Color(0xFF64748B));
      case OrderStatus.batal:
        return _badge('Batal', const Color(0xFFFFEBEE), const Color(0xFFE53935));
    }
  }

  Widget _badge(String label, Color bg, Color fg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
      child: Text(label,
          style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: fg)),
    );
  }

  Widget _buildActionButton(OrderStatus status) {
    switch (status) {
      case OrderStatus.proses:
        return _actionBtn('Lacak', const Color(0xFF3B5BDB), null, Colors.white, true);
      case OrderStatus.selesai:
        return _actionBtn('Cek', Colors.transparent, const Color(0xFFCBD5E1), const Color(0xFF64748B), false);
      case OrderStatus.batal:
        return _actionBtn('Cek', Colors.transparent, const Color(0xFFE53935), const Color(0xFFE53935), false);
    }
  }

  Widget _actionBtn(String label, Color bg, Color? borderColor, Color textColor, bool solid) {
    return GestureDetector(
      onTap: () {},
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 7),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(20),
          border: borderColor != null ? Border.all(color: borderColor) : null,
        ),
        child: Text(label,
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: textColor)),
      ),
    );
  }
}