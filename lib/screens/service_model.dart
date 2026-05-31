import 'package:flutter/material.dart';

class ServiceModel {
  final String id; // Sangat berguna saat nanti dilempar ke CreateOrderScreen
  final String name;
  final String description;
  final String price;
  final String unit;
  final IconData iconData;
  final Color iconColor;
  final Color iconBg;
  final Color accentColor;
  final List<String> includes;
  final String duration;
  final String category;

  const ServiceModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.unit,
    required this.iconData,
    required this.iconColor,
    required this.iconBg,
    required this.accentColor,
    required this.includes,
    required this.duration,
    required this.category,
  });

  // Fungsi Penerjemah dari Database Laravel ke Flutter
  factory ServiceModel.fromJson(Map<String, dynamic> json) {
    String idLayanan = json['id']?.toString() ?? json['_id']?.toString() ?? '';
    String nama = json['nama_layanan']?.toString() ?? 'Layanan Cuci';
    String deskripsi = json['deskripsi']?.toString() ?? 'Deskripsi tidak tersedia.';
    String hargaRaw = json['harga']?.toString() ?? '0';
    String kategori = json['kategori']?.toString() ?? 'Motor';
    
    // Keamanan dari error Integer
    String durasiRaw = json['estimasi_waktu']?.toString() ?? json['estimasi']?.toString() ?? '30';
    String durasiTampil = durasiRaw.toLowerCase().contains('menit') ? durasiRaw : '± $durasiRaw Menit';

    // Parsing array includes (Yang didapat). Jika di DB tidak ada, pakai default.
    List<String> listIncludes = [];
    if (json['includes'] != null && json['includes'] is List) {
      listIncludes = List<String>.from(json['includes']);
    } else {
      listIncludes = [
        'Pencucian eksterior kendaraan',
        'Pembersihan velg & ban',
        'Pengeringan dengan microfiber',
      ];
    }

    // LOGIKA UI CERDAS: Menentukan Ikon dan Warna berdasarkan nama layanan otomatis
    IconData iData = Icons.water_drop_rounded;
    Color iColor = const Color(0xFF3B5BDB);
    Color iBg = const Color(0xFFE3F2FD);
    Color aColor = const Color(0xFF3B5BDB);

    String namaLower = nama.toLowerCase();
    if (namaLower.contains('snow') || namaLower.contains('salju')) {
      iData = Icons.ac_unit_rounded;
      iColor = const Color(0xFF00B4D8);
      iBg = const Color(0xFFE0F7FA);
      aColor = const Color(0xFF00B4D8);
    } else if (namaLower.contains('detail') || namaLower.contains('poles')) {
      iData = Icons.auto_awesome_rounded;
      iColor = const Color(0xFFF59F00);
      iBg = const Color(0xFFFFF3CD);
      aColor = const Color(0xFFF59F00);
    } else if (kategori.toLowerCase() == 'mobil') {
      iData = Icons.directions_car_rounded;
    } else {
      iData = Icons.two_wheeler_rounded;
    }

    return ServiceModel(
      id: idLayanan,
      name: nama,
      description: deskripsi,
      price: 'Rp. $hargaRaw',
      unit: '/$kategori',
      iconData: iData,
      iconColor: iColor,
      iconBg: iBg,
      accentColor: aColor,
      includes: listIncludes,
      duration: durasiTampil,
      category: kategori,
    );
  }
}