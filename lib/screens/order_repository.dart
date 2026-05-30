// Singleton sederhana untuk menyimpan state pesanan antar screen
import 'package:flutter/material.dart';

enum OrderStatus { proses, selesai, batal }

class OrderItem {
  final String serviceName;
  final String date;
  final String vehicle;
  final String plateNumber;
  final String price;
  final OrderStatus status;

  const OrderItem({
    required this.serviceName,
    required this.date,
    required this.vehicle,
    required this.plateNumber,
    required this.price,
    required this.status,
  });
}

class OrderRepository extends ChangeNotifier {
  OrderRepository._();
  static final OrderRepository instance = OrderRepository._();

  final List<OrderItem> _orders = [
    const OrderItem(
      serviceName: 'Steam Biasa - Motor',
      date: '20 Februari 2025',
      vehicle: 'Honda Beat',
      plateNumber: 'F 1234 BB',
      price: 'Rp. 20.000',
      status: OrderStatus.proses,
    ),
    const OrderItem(
      serviceName: 'Steam Biasa - Motor',
      date: '15 Februari 2025',
      vehicle: 'Honda Beat',
      plateNumber: 'F 1234 BB',
      price: 'Rp. 20.000',
      status: OrderStatus.selesai,
    ),
    const OrderItem(
      serviceName: 'Steam Biasa - Motor',
      date: '10 Februari 2025',
      vehicle: 'Honda Beat',
      plateNumber: 'F 1234 BB',
      price: 'Rp. 20.000',
      status: OrderStatus.batal,
    ),
    const OrderItem(
      serviceName: 'Steam Biasa - Motor',
      date: '15 Februari 2025',
      vehicle: 'Honda Beat',
      plateNumber: 'F 1234 BB',
      price: 'Rp. 20.000',
      status: OrderStatus.selesai,
    ),
  ];

  List<OrderItem> get orders => List.unmodifiable(_orders);

  void addOrder(OrderItem item) {
    _orders.insert(0, item); // tambah di paling atas
    notifyListeners();
  }
}