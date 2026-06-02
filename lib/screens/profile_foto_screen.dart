import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../config/api_service.dart';
import '../config/api_config.dart';

class ProfileFotoScreen extends StatefulWidget {
  final String? currentFotoUrl;
  final String username;

  const ProfileFotoScreen({
    super.key,
    this.currentFotoUrl,
    required this.username,
  });

  @override
  State<ProfileFotoScreen> createState() => _ProfileFotoScreenState();
}

class _ProfileFotoScreenState extends State<ProfileFotoScreen> {
  File? _image;
  bool _isUploading = false;
  final ImagePicker _picker = ImagePicker();

  String _getValidImageUrl(String path) {
    if (path.startsWith('http')) return '$path?v=${DateTime.now().millisecondsSinceEpoch}';
    
    String baseUrl = ApiConfig.baseUrl.replaceAll('/api', '');
    String safePath = path.startsWith('/') ? path : '/$path';
    if (!safePath.startsWith('/storage')) {
      safePath = '/storage$safePath';
    }
    return '$baseUrl$safePath?v=${DateTime.now().millisecondsSinceEpoch}';
  }

  Future<void> _pickImage(ImageSource source) async {
    final XFile? pickedFile = await _picker.pickImage(
      source: source,
      imageQuality: 80, 
    );

    if (pickedFile != null) {
      // Buka halaman Crop Gambar (Tanpa parameter cropStyle yang bikin error)
      CroppedFile? croppedFile = await ImageCropper().cropImage(
        sourcePath: pickedFile.path,
        aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1), // Ini akan memastikan potongan berbentuk rasio 1:1 (Persegi)
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Potong Foto',
            toolbarColor: const Color(0xFF1A237E),
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.square,
            lockAspectRatio: true, // Kunci agar selalu kotak 1:1
            hideBottomControls: false,
          ),
          IOSUiSettings(
            title: 'Potong Foto',
            aspectRatioLockEnabled: true,
          ),
        ],
      );

      if (croppedFile != null) {
        setState(() {
          _image = File(croppedFile.path); 
        });
      }
    }
  }

  // ── MENGGUNAKAN METODE POST MURNI UNTUK UPLOAD ──
  Future<void> _uploadFoto() async {
    if (_image == null) return;
    setState(() => _isUploading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final idUser = prefs.getString('id_user') ?? "";

      final response = await ApiService.multipartPost(
        '/user/$idUser/foto',
        {}, 
        filePath: _image!.path,
        fileField: 'foto_profil', 
      );

      if (response != null && (response.statusCode == 200 || response.statusCode == 201)) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Foto profil berhasil diperbarui!"), backgroundColor: Colors.green)
          );
          Navigator.pop(context, true); 
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Gagal mengunggah foto profil."), backgroundColor: Colors.redAccent)
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Terjadi kesalahan jaringan."), backgroundColor: Colors.redAccent)
        );
      }
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  // ── MENGGUNAKAN METODE DELETE UNTUK HAPUS FOTO ──
  Future<void> _deleteFoto() async {
    setState(() => _isUploading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final idUser = prefs.getString('id_user') ?? "";

      final response = await ApiService.delete('/user/$idUser/foto');

      if (response != null && response.statusCode == 200) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Foto profil berhasil dihapus!"), backgroundColor: Colors.green)
          );
          Navigator.pop(context, true); 
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Gagal menghapus foto profil."), backgroundColor: Colors.redAccent)
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Terjadi kesalahan jaringan."), backgroundColor: Colors.redAccent)
        );
      }
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    String initial = widget.username.isNotEmpty && widget.username != "Memuat..." 
        ? widget.username[0].toUpperCase() 
        : "?";

    bool hasExistingPhoto = widget.currentFotoUrl != null && _image == null;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Color(0xFF1A1A2E)),
        title: const Text('Foto Profil', style: TextStyle(color: Color(0xFF1A1A2E), fontSize: 16, fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 20),
            Center(
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 20, offset: const Offset(0, 10))],
                  border: Border.all(color: Colors.white, width: 6),
                ),
                child: ClipRRect( // ── INI YANG MEMBUATNYA JADI BULAT SEMPURNA DI UI APLIKASI ──
                  borderRadius: BorderRadius.circular(100),
                  child: _image != null
                      ? Image.file(_image!, fit: BoxFit.cover, width: 200, height: 200) 
                      : (widget.currentFotoUrl != null
                          ? Image.network(
                              _getValidImageUrl(widget.currentFotoUrl!),
                              fit: BoxFit.cover, width: 200, height: 200,
                              errorBuilder: (_, __, ___) => _buildFallbackAvatar(initial),
                            )
                          : _buildFallbackAvatar(initial)), 
                ),
              ),
            ),
            const SizedBox(height: 40),

            _buildOptionBtn(
              icon: Icons.photo_library_rounded,
              label: 'Pilih dari Galeri',
              color: const Color(0xFF3B5BDB),
              onTap: () => _pickImage(ImageSource.gallery),
            ),
            const SizedBox(height: 16),
            
            _buildOptionBtn(
              icon: Icons.camera_alt_rounded,
              label: 'Ambil dari Kamera',
              color: const Color(0xFF00B4D8),
              onTap: () => _pickImage(ImageSource.camera),
            ),

            if (hasExistingPhoto) ...[
              const SizedBox(height: 16),
              _buildOptionBtn(
                icon: Icons.delete_outline_rounded,
                label: 'Hapus Foto Profil',
                color: const Color(0xFFE53935),
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('Hapus Foto?'),
                      content: const Text('Foto profil Anda akan dihapus secara permanen.'),
                      actions: [
                        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
                        TextButton(
                          onPressed: () {
                            Navigator.pop(ctx);
                            _deleteFoto();
                          }, 
                          child: const Text('Hapus', style: TextStyle(color: Colors.red)),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],

            const SizedBox(height: 40),

            if (_image != null)
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _isUploading ? null : _uploadFoto,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4CAF50),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    elevation: 0,
                  ),
                  child: _isUploading
                      ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text('Simpan Foto Baru', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildFallbackAvatar(String initial) {
    return Container(
      color: const Color(0xFF1A237E),
      child: Center(
        child: Text(
          initial,
          style: const TextStyle(fontSize: 80, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildOptionBtn({required IconData icon, required String label, required Color color, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE9ECEF)),
        ),
        child: Row(
          children: [
            Container(
              width: 40, height: 40,
              decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 16),
            Text(
              label, 
              style: TextStyle(
                fontSize: 15, 
                fontWeight: FontWeight.bold, 
                color: color == const Color(0xFFE53935) ? color : const Color(0xFF1A1A2E)
              )
            ),
            const Spacer(),
            Icon(Icons.chevron_right_rounded, color: color == const Color(0xFFE53935) ? color : const Color(0xFFCBD5E1)),
          ],
        ),
      ),
    );
  }
}