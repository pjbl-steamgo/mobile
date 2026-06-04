class ApiConfig {
  // Ganti IP ini sesuai dengan komputermu atau domain aslinya nanti
  static const String baseUrl = 'https://font-snowless-unbent.ngrok-free.dev/api';
  
  // Kamu juga bisa menambahkan endpoint spesifik jika mau agar lebih rapi
  static const String userProfile = '$baseUrl/user';
  static const String orderHistory = '$baseUrl/order-history';
  static const String faq = '$baseUrl/pengaturan/faq';
  static const String syaratKetentuan = '$baseUrl/pengaturan/syarat-ketentuan';
}