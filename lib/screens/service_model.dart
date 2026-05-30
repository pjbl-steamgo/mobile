import 'package:flutter/material.dart';

class ServiceModel {
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
}

final List<ServiceModel> serviceList = [
  ServiceModel(
    name: 'Steam Biasa - Motor',
    description: 'Cuci body, velg, dan rantai menggunakan steam bertekanan tinggi.',
    price: 'Rp. 20.000',
    unit: '/Motor',
    iconData: Icons.water_drop_rounded,
    iconColor: const Color(0xFF3B5BDB),
    iconBg: const Color(0xFFE3F2FD),
    accentColor: const Color(0xFF3B5BDB),
    duration: '15 – 20 menit',
    category: 'Motor',
    includes: [
      'Cuci body luar dengan steam bertekanan tinggi',
      'Pembersihan velg dan ban',
      'Pembersihan rantai dan gear',
      'Lap kering seluruh bodi',
    ],
  ),
  ServiceModel(
    name: 'Snow Wash - Motor',
    description: 'Snow foam tebal untuk hasil bersih merata, aman untuk cat.',
    price: 'Rp. 30.000',
    unit: '/Motor',
    iconData: Icons.ac_unit_rounded,
    iconColor: const Color(0xFF00B4D8),
    iconBg: const Color(0xFFE0F7FA),
    accentColor: const Color(0xFF00B4D8),
    duration: '20 – 25 menit',
    category: 'Motor',
    includes: [
      'Aplikasi snow foam tebal ke seluruh bodi',
      'Pembilasan dengan air bertekanan',
      'Pembersihan velg dan sela-sela knalpot',
      'Lap microfiber dan finishing',
    ],
  ),
  ServiceModel(
    name: 'Detailing - Motor',
    description: 'Perawatan menyeluruh untuk tampilan motor bersih sempurna.',
    price: 'Rp. 120.000',
    unit: '/Motor',
    iconData: Icons.auto_awesome_rounded,
    iconColor: const Color(0xFFF59F00),
    iconBg: const Color(0xFFFFF3CD),
    accentColor: const Color(0xFFF59F00),
    duration: '60 – 90 menit',
    category: 'Motor',
    includes: [
      'Snow wash lengkap',
      'Poles body dan tangki',
      'Semir ban dan proteksi plastik',
      'Pembersihan detail celah rangka',
      'Wax coating untuk kilap tahan lama',
    ],
  ),
  ServiceModel(
    name: 'Steam Biasa - Mobil',
    description: 'Cuci body, velg, dan kolong menggunakan steam bertekanan tinggi.',
    price: 'Rp. 40.000',
    unit: '/Mobil',
    iconData: Icons.water_drop_rounded,
    iconColor: const Color(0xFF3B5BDB),
    iconBg: const Color(0xFFE3F2FD),
    accentColor: const Color(0xFF3B5BDB),
    duration: '25 – 35 menit',
    category: 'Mobil',
    includes: [
      'Cuci eksterior dengan steam bertekanan tinggi',
      'Pembersihan velg dan ban',
      'Pembersihan kolong mobil',
      'Lap kering seluruh eksterior',
    ],
  ),
  ServiceModel(
    name: 'Snow Wash - Mobil',
    description: 'Snow foam tebal untuk hasil bersih merata, aman untuk cat.',
    price: 'Rp. 50.000',
    unit: '/Mobil',
    iconData: Icons.ac_unit_rounded,
    iconColor: const Color(0xFF00B4D8),
    iconBg: const Color(0xFFE0F7FA),
    accentColor: const Color(0xFF00B4D8),
    duration: '30 – 40 menit',
    category: 'Mobil',
    includes: [
      'Aplikasi snow foam tebal ke seluruh eksterior',
      'Pembilasan dengan air bertekanan',
      'Pembersihan velg, ban, dan kolong',
      'Lap microfiber dan finishing eksterior',
    ],
  ),
  ServiceModel(
    name: 'Detailing - Mobil',
    description: 'Perawatan menyeluruh untuk tampilan mobil bersih sempurna.',
    price: 'Rp. 250.000',
    unit: '/Mobil',
    iconData: Icons.auto_awesome_rounded,
    iconColor: const Color(0xFFF59F00),
    iconBg: const Color(0xFFFFF3CD),
    accentColor: const Color(0xFFF59F00),
    duration: '120 – 150 menit',
    category: 'Mobil',
    includes: [
      'Snow wash lengkap eksterior',
      'Cuci interior: vakum, lap dashboard, kaca',
      'Poles body dan bumper',
      'Semir ban dan proteksi karet',
      'Wax coating eksterior',
      'Parfum interior gratis',
    ],
  ),
];