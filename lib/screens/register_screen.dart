import 'package:flutter/material.dart';
import 'login_screen.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

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
              // HEADER BANNER & LOGO DAFTAR (PIXEL PERFECT)
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
                          image: AssetImage('assets/images/register.png'),
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
              // TATA LETAK TAB NAVIGASI
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
                      Expanded(
                        child: InkWell(
                          onTap: () {
                            Navigator.pushReplacement(
                              context,
                              PageRouteBuilder(
                                pageBuilder: (context, animation1, animation2) => const LoginScreen(),
                                transitionDuration: Duration.zero,
                                reverseTransitionDuration: Duration.zero,
                              ),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Text(
                              'Masuk',
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.grey.shade500),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.only(bottom: 12),
                          decoration: const BoxDecoration(
                            border: Border(
                              bottom: BorderSide(color: Colors.blueAccent, width: 3),
                            ),
                          ),
                          child: const Text(
                            'Daftar',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blueAccent),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // ==========================================
              // KONTEN FORM REGISTER
              // ==========================================
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.0),
                child: RegisterFormWidget(),
              ),
              
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}

class RegisterFormWidget extends StatefulWidget {
  const RegisterFormWidget({super.key});

  @override
  State<RegisterFormWidget> createState() => _RegisterFormWidgetState();
}

class _RegisterFormWidgetState extends State<RegisterFormWidget> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isPasswordVisible = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
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
          const Text('Username', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black87)),
          const SizedBox(height: 8),
          TextFormField(
            controller: _usernameController,
            decoration: InputDecoration(
              hintText: 'Masukkan username Anda',
              hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
              prefixIcon: const Icon(Icons.person_outline_rounded, color: Colors.grey),
              contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.blueAccent, width: 2)),
            ),
          ),
          const SizedBox(height: 20),
          const Text('No. HP', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black87)),
          const SizedBox(height: 8),
          TextFormField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            decoration: InputDecoration(
              hintText: 'Masukkan nomor HP Anda',
              hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
              prefixIcon: const Icon(Icons.phone_android_rounded, color: Colors.grey),
              contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.blueAccent, width: 2)),
            ),
          ),
          const SizedBox(height: 20),
          const Text('Email', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black87)),
          const SizedBox(height: 8),
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              hintText: 'Masukkan email Anda',
              hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
              prefixIcon: const Icon(Icons.mail_outline_rounded, color: Colors.grey),
              contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.blueAccent, width: 2)),
            ),
          ),
          const SizedBox(height: 20),
          const Text('Password', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black87)),
          const SizedBox(height: 8),
          TextFormField(
            controller: _passwordController,
            obscureText: !_isPasswordVisible,
            decoration: InputDecoration(
              hintText: 'Buat password baru',
              hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
              prefixIcon: const Icon(Icons.lock_outline_rounded, color: Colors.grey),
              suffixIcon: IconButton(
                icon: Icon(_isPasswordVisible ? Icons.visibility_rounded : Icons.visibility_off_rounded, color: Colors.grey),
                onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.blueAccent, width: 2)),
            ),
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), elevation: 0),
              child: const Text('Daftar Sekarang', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }
}