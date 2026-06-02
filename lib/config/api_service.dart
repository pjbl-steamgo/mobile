import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'api_config.dart'; // Sesuaikan jika beda folder

class ApiService {
  // Kunci Navigator Global: Untuk pindah ke halaman Login dari mana saja tanpa butuh BuildContext
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  // 1. Fungsi Otomatis Menyisipkan Token ke Headers
  static Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';
    
    return {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      if (token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }

  // 2. Fungsi Otomatis Menangani Token Mati / Error HTML
  static Future<bool> _isResponseInvalid(http.Response response) async {
    if (response.statusCode == 401 || response.body.trim().startsWith('<')) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear(); // Hapus sesi
      
      // Lempar paksa ke halaman login
      if (navigatorKey.currentContext != null) {
        ScaffoldMessenger.of(navigatorKey.currentContext!).showSnackBar(
          const SnackBar(
            content: Text('Sesi Anda telah berakhir. Silakan login kembali.'),
            backgroundColor: Colors.redAccent,
          ),
        );
        Navigator.pushNamedAndRemoveUntil(navigatorKey.currentContext!, '/login', (route) => false);
      }
      return true;
    }
    return false;
  }

  // =========================================================
  // KUMPULAN FUNGSI REQUEST (GET, POST, DELETE)
  // =========================================================

  // HTTP GET
  static Future<http.Response?> get(String endpoint) async {
    try {
      final url = Uri.parse('${ApiConfig.baseUrl}$endpoint');
      final response = await http.get(url, headers: await _getHeaders()).timeout(const Duration(seconds: 10));
      
      // Jika token mati, hentikan proses (return null)
      if (await _isResponseInvalid(response)) return null;
      return response;
    } catch (e) {
      debugPrint('API GET Error ($endpoint): $e');
      throw Exception('Gagal terhubung ke server');
    }
  }

  // HTTP POST
  static Future<http.Response?> post(String endpoint, Map<String, dynamic> body) async {
    try {
      final url = Uri.parse('${ApiConfig.baseUrl}$endpoint');
      final response = await http.post(
        url, 
        headers: await _getHeaders(), 
        body: jsonEncode(body),
      ).timeout(const Duration(seconds: 10));
      
      if (await _isResponseInvalid(response)) return null;
      return response;
    } catch (e) {
      debugPrint('API POST Error ($endpoint): $e');
      throw Exception('Gagal terhubung ke server');
    }
  }

  // HTTP DELETE
  static Future<http.Response?> delete(String endpoint) async {
    try {
      final url = Uri.parse('${ApiConfig.baseUrl}$endpoint');
      final response = await http.delete(url, headers: await _getHeaders()).timeout(const Duration(seconds: 10));
      
      if (await _isResponseInvalid(response)) return null;
      return response;
    } catch (e) {
      debugPrint('API DELETE Error ($endpoint): $e');
      throw Exception('Gagal terhubung ke server');
    }
  }

  // HTTP MULTIPART (Untuk Upload Gambar Chat/Pembayaran)
  static Future<http.StreamedResponse?> multipartPost(String endpoint, Map<String, String> fields, {String? filePath, String fileField = 'image'}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';

      var request = http.MultipartRequest('POST', Uri.parse('${ApiConfig.baseUrl}$endpoint'));
      request.headers['Accept'] = 'application/json';
      if (token.isNotEmpty) request.headers['Authorization'] = 'Bearer $token';

      // Masukkan field text
      request.fields.addAll(fields);
      
      // Masukkan file gambar
      if (filePath != null) {
        request.files.add(await http.MultipartFile.fromPath(fileField, filePath));
      }

      var streamedResponse = await request.send();
      
      // Cek apakah token mati
      if (streamedResponse.statusCode == 401) {
        // Panggil fungsi handle error 401
        await _isResponseInvalid(http.Response('', 401)); 
        return null;
      }
      return streamedResponse;
    } catch (e) {
      debugPrint('API MULTIPART Error ($endpoint): $e');
      throw Exception('Gagal terhubung ke server');
    }
  }

  // HTTP PUT
  static Future<http.Response?> put(String endpoint, Map<String, dynamic> body) async {
    try {
      final url = Uri.parse('${ApiConfig.baseUrl}$endpoint');
      final response = await http.put(
        url, 
        headers: await _getHeaders(), 
        body: jsonEncode(body),
      ).timeout(const Duration(seconds: 10));
      
      if (await _isResponseInvalid(response)) return null;
      return response;
    } catch (e) {
      debugPrint('API PUT Error ($endpoint): $e');
      throw Exception('Gagal terhubung ke server');
    }
  }
}