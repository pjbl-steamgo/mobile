import 'package:flutter/material.dart';
import 'register_screen.dart'; // Memastikan rute ke halaman register terhubung

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea( 
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              
              // ==========================================
              // HEADER BANNER & LOGO MASUK (PIXEL PERFECT)
              // ==========================================
              SizedBox(
                height: 280,
                width: double.infinity,
                child: Stack(
                  children: [
                    // 1. DISPLAY KOTAK REGISTER
                    Container(
                      height: 220, 
                      width: double.infinity,
                      decoration: const BoxDecoration(
                        color: Color(0xFFEDF2F7), 
                        image: DecorationImage(
                          image: AssetImage('assets/images/login.png'),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    
                    // 2. DISPLAY BULAT REGISTER (UKURAN SAMA PERSIS DENGAN LOGIN)
                    Positioned(
                      top: 160, // Mengunci posisi lingkaran tepat di tengah garis bawah banner
                      left: 0,
                      right: 0,
                      child: Center(
                        child: Container(
                          width: 120, 
                          height: 120, 
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 4), 
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.08),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                            image: const DecorationImage(
                              image: AssetImage('assets/images/logo.png'),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // ==========================================
              // TATA LETAK TAB NAVIGASI (TANPA ANIMASI)
              // ==========================================
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Container(
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: Colors.grey.shade200, width: 2),
                    ),
                  ),
                  child: Row(
                    children: [
                      // Tab Masuk (Aktif)
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.only(bottom: 12),
                          decoration: const BoxDecoration(
                            border: Border(
                              bottom: BorderSide(color: Colors.blueAccent, width: 3),
                            ),
                          ),
                          child: const Text(
                            'Masuk',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blueAccent),
                          ),
                        ),
                      ),
                      
                      // Tab Daftar (Tidak Aktif - Berpindah Halaman Instan)
                      Expanded(
                        child: InkWell(
                          onTap: () {
                            Navigator.pushReplacement(
                              context,
                              PageRouteBuilder(
                                pageBuilder: (context, animation1, animation2) => const RegisterScreen(),
                                transitionDuration: Duration.zero,
                                reverseTransitionDuration: Duration.zero,
                              ),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Text(
                              'Daftar',
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.grey.shade500),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // ==========================================
              // KONTEN FORM LOGIN
              // ==========================================
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.0),
                child: LoginFormWidget(),
              ),
              
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}

// ========================================================
// WIDGET STATEFUL KHUSUS UNTUK MENAMPUNG LOGIKA FORM LOGIN
// ========================================================
class LoginFormWidget extends StatefulWidget {
  const LoginFormWidget({super.key});

  @override
  State<LoginFormWidget> createState() => _LoginFormWidgetState();
}

class _LoginFormWidgetState extends State<LoginFormWidget> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _identifierController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isPasswordVisible = false;

  @override
  void dispose() {
    _identifierController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Label Kolom Identitas
          const Text(
            'No. HP / Email', 
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black87),
          ),
          const SizedBox(height: 8),
          
          // Input No. HP / Email
          TextFormField(
            controller: _identifierController,
            keyboardType: TextInputType.text,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Kolom ini tidak boleh kosong';
              }
              return null;
            },
            decoration: InputDecoration(
              hintText: 'Masukkan No. HP atau email Anda',
              hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
              prefixIcon: const Icon(Icons.phone_android_rounded, color: Colors.grey),
              contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12), 
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12), 
                borderSide: const BorderSide(color: Colors.blueAccent, width: 2),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.redAccent, width: 1),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.redAccent, width: 2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          
          // Label Kolom Password
          const Text(
            'Password', 
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black87),
          ),
          const SizedBox(height: 8),
          
          // Input Password
          TextFormField(
            controller: _passwordController,
            obscureText: !_isPasswordVisible,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Password tidak boleh kosong';
              }
              return null;
            },
            decoration: InputDecoration(
              hintText: 'Masukkan password',
              hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
              prefixIcon: const Icon(Icons.lock_outline_rounded, color: Colors.grey),
              suffixIcon: IconButton(
                icon: Icon(
                  _isPasswordVisible ? Icons.visibility_rounded : Icons.visibility_off_rounded, 
                  color: Colors.grey,
                ),
                onPressed: () {
                  setState(() {
                    _isPasswordVisible = !_isPasswordVisible;
                  });
                },
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12), 
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12), 
                borderSide: const BorderSide(color: Colors.blueAccent, width: 2),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.redAccent, width: 1),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.redAccent, width: 2),
              ),
            ),
          ),
          const SizedBox(height: 8),
          
          // Tombol Lupa Password (Rata Kanan)
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {
                // TODO: Tambahkan navigasi atau aksi aksi lupa password di sini
              },
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: const Text(
                'Lupa password?', 
                style: TextStyle(color: Colors.blueAccent, fontSize: 14, fontWeight: FontWeight.w600),
              ),
            ),
          ),
          const SizedBox(height: 32),
          
          // Tombol Utama Masuk
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  // Jika validasi sukses, jalankan proses login ke back-end
                  print('Identifier: ${_identifierController.text}');
                  print('Password: ${_passwordController.text}');
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent, 
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), 
                elevation: 0,
              ),
              child: const Text(
                'Masuk', 
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}