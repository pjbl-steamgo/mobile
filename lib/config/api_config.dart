class ApiConfig {
  // Ganti IP ini sesuai dengan komputermu atau domain aslinya nanti
  static const String baseUrl = 'http://192.168.100.36:8000/api';
  
  // Kamu juga bisa menambahkan endpoint spesifik jika mau agar lebih rapi
  static const String userProfile = '$baseUrl/user';
  static const String orderHistory = '$baseUrl/order-history';
  static const String faq = '$baseUrl/pengaturan/faq';
  static const String syaratKetentuan = '$baseUrl/pengaturan/syarat-ketentuan';
}