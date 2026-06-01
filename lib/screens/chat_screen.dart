import 'dart:io';
import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import '../config/api_config.dart'; // IMPORT CLEAN CODE API

// ── Model Data Diperbarui ──
class ChatMessage {
  final String id;
  final String? text;
  final String? imagePath;
  final String? replyToText;
  final bool isUser;
  final DateTime time;
  bool isDeleted;

  ChatMessage({
    required this.id,
    this.text,
    this.imagePath,
    this.replyToText,
    required this.isUser,
    required this.time,
    this.isDeleted = false,
  });
}

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ImagePicker _picker = ImagePicker();
  ChatMessage? _replyingTo;

  List<ChatMessage> _messages = [];
  Timer? _pollingTimer;
  String _idUser = "";
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initChat();
  }

  @override
  void dispose() {
    _pollingTimer?.cancel(); 
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // ── 1. INISIALISASI & FETCH DARI DATABASE ─────────────────────────────────
  Future<void> _initChat() async {
    final prefs = await SharedPreferences.getInstance();
    _idUser = prefs.getString('id_user') ?? "";

    if (_idUser.isNotEmpty) {
      await _fetchMessages();
      
      _pollingTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
        _fetchMessages();
      });
    } else {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _fetchMessages() async {
    try {
      final response = await http.get(Uri.parse('${ApiConfig.baseUrl}/chat/$_idUser'));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          List<dynamic> apiMessages = data['data'];
          List<ChatMessage> parsedMessages = [];

          String storageUrl = ApiConfig.baseUrl.replaceAll('/api', '/storage');

          for (var msg in apiMessages) {
            String? imgPath;
            if (msg['image'] != null && msg['image'].toString().isNotEmpty) {
              imgPath = '$storageUrl/${msg['image']}'; 
            }

            parsedMessages.add(ChatMessage(
              id: msg['_id'] ?? msg['id'] ?? '',
              text: msg['message'],
              imagePath: imgPath,
              replyToText: msg['reply_to_text'],
              isUser: msg['sender'] == 'user',
              time: DateTime.parse(msg['created_at']).toLocal(),
            ));
          }

          if (parsedMessages.length != _messages.length && mounted) {
            setState(() {
              _messages = parsedMessages;
              _isLoading = false;
            });
            _scrollToBottom();
          } else if (_isLoading && mounted) {
            setState(() => _isLoading = false);
          }
        }
      }
    } catch (e) {
      debugPrint("Gagal memuat pesan: $e");
    }
  }

  // ── 2. MENGIRIM PESAN (TEKS & GAMBAR BERSAMAAN) ──────────────────────────
  Future<void> _sendMessage({String? text, String? imagePath}) async {
    final msgText = text ?? _controller.text.trim();
    if (msgText.isEmpty && imagePath == null) return;

    // Optimistic UI: Menampilkan Teks & Gambar sekaligus di HP
    final newMsg = ChatMessage(
      id: 'temp_${DateTime.now().millisecondsSinceEpoch}',
      text: msgText.isNotEmpty ? msgText : null, // PERBAIKAN: Teks tidak lagi dikosongkan jika ada gambar
      imagePath: imagePath,
      replyToText: _replyingTo?.text ?? (_replyingTo?.imagePath != null ? 'Gambar' : null),
      isUser: true,
      time: DateTime.now(),
    );

    setState(() {
      _messages.add(newMsg);
      _controller.clear();
      _replyingTo = null;
    });
    _scrollToBottom();

    if (_idUser.isNotEmpty) {
      try {
        var request = http.MultipartRequest('POST', Uri.parse('${ApiConfig.baseUrl}/chat/$_idUser'));
        request.headers['Accept'] = 'application/json';
        
        if (msgText.isNotEmpty) {
          request.fields['message'] = msgText;
        }
        if (newMsg.replyToText != null) {
          request.fields['reply_to_text'] = newMsg.replyToText!;
        }
        if (imagePath != null) {
          request.files.add(await http.MultipartFile.fromPath('image', imagePath));
        }

        var response = await request.send();
        if (response.statusCode == 201 || response.statusCode == 200) {
          _fetchMessages(); 
        }
      } catch (e) {
        debugPrint("Gagal mengirim: $e");
      }
    }
  }

  // ── 3. HAPUS PESAN DARI SERVER ──────────────────────────────────────────
  Future<void> _deleteMessage(ChatMessage msg) async {
    try {
      final response = await http.delete(Uri.parse('${ApiConfig.baseUrl}/chat/message/${msg.id}'));
      if (response.statusCode == 200) {
        _fetchMessages(); 
      }
    } catch (e) {
      debugPrint("Gagal hapus pesan: $e");
    }
  }

  Future<void> _pickImage() async {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40, height: 4,
                decoration: BoxDecoration(color: const Color(0xFFE2E8F0), borderRadius: BorderRadius.circular(2)),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: Container(
                  width: 42, height: 42,
                  decoration: BoxDecoration(color: const Color(0xFFE3F2FD), borderRadius: BorderRadius.circular(12)),
                  child: const Icon(Icons.camera_alt_rounded, color: Color(0xFF3B5BDB)),
                ),
                title: const Text('Kamera', style: TextStyle(fontWeight: FontWeight.w600)),
                onTap: () async {
                  Navigator.pop(context);
                  final img = await _picker.pickImage(source: ImageSource.camera, imageQuality: 60);
                  if (img != null) _sendMessage(imagePath: img.path);
                },
              ),
              ListTile(
                leading: Container(
                  width: 42, height: 42,
                  decoration: BoxDecoration(color: const Color(0xFFE8F5E9), borderRadius: BorderRadius.circular(12)),
                  child: const Icon(Icons.photo_library_rounded, color: Color(0xFF4CAF50)),
                ),
                title: const Text('Galeri', style: TextStyle(fontWeight: FontWeight.w600)),
                onTap: () async {
                  Navigator.pop(context);
                  final img = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 60);
                  if (img != null) _sendMessage(imagePath: img.path);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _setReply(ChatMessage msg) => setState(() => _replyingTo = msg);
  void _cancelReply() => setState(() => _replyingTo = null);

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  String _formatTime(DateTime t) => '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: Color(0xFF1A1A2E)),
        titleSpacing: 0,
        title: Row(
          children: [
            Container(
              width: 36, height: 36,
              decoration: const BoxDecoration(color: Color(0xFF3B5BDB), shape: BoxShape.circle),
              child: const Icon(Icons.support_agent_rounded, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('SteamGo Admin', style: TextStyle(color: Color(0xFF1A1A2E), fontSize: 15, fontWeight: FontWeight.bold)),
                Row(
                  children: [
                    Container(width: 7, height: 7, decoration: const BoxDecoration(color: Color(0xFF4CAF50), shape: BoxShape.circle)),
                    const SizedBox(width: 4),
                    const Text('Online', style: TextStyle(fontSize: 11, color: Color(0xFF4CAF50))),
                  ],
                ),
              ],
            ),
          ],
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: const Color(0xFFE9ECEF)),
        ),
      ),
      body: Column(
        children: [
          // ── Daftar pesan ──────────────────────────────────────────────
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: Color(0xFF3B5BDB)))
                : _messages.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.chat_bubble_outline_rounded, size: 60, color: Color(0xFFCBD5E1)),
                            const SizedBox(height: 16),
                            Text('Belum ada obrolan', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey.shade600)),
                            const SizedBox(height: 8),
                            Text('Tanyakan apa saja kepada admin kami.', style: TextStyle(fontSize: 13, color: Colors.grey.shade500)),
                          ],
                        ),
                      )
                    : ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        itemCount: _messages.length,
                        itemBuilder: (context, index) {
                          final msg = _messages[index];
                          final showDate = index == 0 || msg.time.day != _messages[index - 1].time.day;
                          return Column(
                            children: [
                              if (showDate) _buildDateDivider(msg.time),
                              _buildBubble(msg),
                            ],
                          );
                        },
                      ),
          ),

          // ── Preview reply ─────────────────────────────────────────────
          if (_replyingTo != null)
            Container(
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
              child: Row(
                children: [
                  Container(
                      width: 3, height: 40,
                      decoration: BoxDecoration(color: const Color(0xFF3B5BDB), borderRadius: BorderRadius.circular(2))),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _replyingTo!.isUser ? 'Anda' : 'SteamGo Support',
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF3B5BDB)),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _replyingTo!.isDeleted
                              ? 'Pesan telah dihapus'
                              : (_replyingTo!.imagePath != null ? '📷 Gambar' : _replyingTo!.text ?? ''),
                          style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                          maxLines: 1, overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, size: 18, color: Color(0xFF94A3B8)),
                    onPressed: _cancelReply,
                  ),
                ],
              ),
            ),

          // ── Input area ────────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 24),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -3))],
            ),
            child: Row(
              children: [
                GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    width: 40, height: 40,
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(20)),
                    child: const Icon(Icons.image_rounded, color: Color(0xFF64748B), size: 20),
                  ),
                ),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(24)),
                    child: TextField(
                      controller: _controller,
                      onSubmitted: (_) => _sendMessage(),
                      textInputAction: TextInputAction.send,
                      style: const TextStyle(fontSize: 14, color: Color(0xFF1A1A2E)),
                      decoration: const InputDecoration(
                        hintText: 'Tulis pesan...',
                        hintStyle: TextStyle(color: Color(0xFFCBD5E1), fontSize: 14),
                        border: InputBorder.none, isDense: true, contentPadding: EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () => _sendMessage(),
                  child: Container(
                    width: 44, height: 44,
                    decoration: const BoxDecoration(color: Color(0xFF3B5BDB), shape: BoxShape.circle),
                    child: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Date divider ──────────────────────────────────────────────────────────
  Widget _buildDateDivider(DateTime time) {
    const months = ['', 'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni', 'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'];
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          const Expanded(child: Divider(color: Color(0xFFE2E8F0))),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text('${time.day} ${months[time.month]} ${time.year}', style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8))),
          ),
          const Expanded(child: Divider(color: Color(0xFFE2E8F0))),
        ],
      ),
    );
  }

  // ── Chat bubble (Diperbarui untuk mendukung Teks + Gambar) ───────────────────
  Widget _buildBubble(ChatMessage msg) {
    final isUser = msg.isUser;

    Widget? imageWidget;
    if (msg.imagePath != null) {
      if (msg.imagePath!.startsWith('http')) {
        imageWidget = Image.network(msg.imagePath!, width: 220, fit: BoxFit.fitWidth);
      } else {
        imageWidget = Image.file(File(msg.imagePath!), width: 220, fit: BoxFit.fitWidth);
      }
    }

    return GestureDetector(
      onLongPress: () => _showMessageOptions(msg),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Row(
          mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (!isUser) ...[
              Container(
                width: 30, height: 30,
                decoration: const BoxDecoration(color: Color(0xFF3B5BDB), shape: BoxShape.circle),
                child: const Icon(Icons.support_agent_rounded, color: Colors.white, size: 16),
              ),
              const SizedBox(width: 8),
            ],
            Flexible(
              child: Column(
                crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                children: [
                  if (msg.replyToText != null && !msg.isDeleted)
                    Container(
                      margin: const EdgeInsets.only(bottom: 4),
                      padding: const EdgeInsets.fromLTRB(10, 6, 10, 6),
                      decoration: BoxDecoration(
                        color: isUser ? const Color(0xFF9DD4A8) : const Color(0xFFE9ECEF),
                        borderRadius: BorderRadius.circular(10),
                        border: const Border(left: BorderSide(color: Color(0xFF3B5BDB), width: 3)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Dibalas:', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF3B5BDB))),
                          const SizedBox(height: 2),
                          Text(
                            msg.replyToText!,
                            style: const TextStyle(fontSize: 11, color: Color(0xFF475569)),
                            maxLines: 1, overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    
                  Container(
                    // PERBAIKAN PADDING: Berikan ruang lebih jika ada teks dan gambar
                    padding: (msg.imagePath != null && (msg.text == null || msg.text!.isEmpty))
                        ? const EdgeInsets.all(4)
                        : const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: msg.isDeleted ? const Color(0xFFF1F5F9) : (isUser ? const Color(0xFFB5EAC2) : Colors.white),
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(16),
                        topRight: const Radius.circular(16),
                        bottomLeft: Radius.circular(isUser ? 16 : 4),
                        bottomRight: Radius.circular(isUser ? 4 : 16),
                      ),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6, offset: const Offset(0, 2))],
                    ),
                    // PERBAIKAN: Gunakan Column agar Gambar dan Teks bertumpuk
                    child: msg.isDeleted
                        ? Row(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              Icon(Icons.block_rounded, size: 14, color: Color(0xFF94A3B8)),
                              SizedBox(width: 6),
                              Text('Pesan telah dihapus', style: TextStyle(fontSize: 13, color: Color(0xFF94A3B8), fontStyle: FontStyle.italic)),
                            ],
                          )
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (imageWidget != null)
                                Padding(
                                  padding: (msg.text != null && msg.text!.isNotEmpty)
                                      ? const EdgeInsets.only(bottom: 8) // Jarak antara gambar dan teks
                                      : EdgeInsets.zero,
                                  child: GestureDetector(
                                    onTap: () => _showImageViewer(context, msg.imagePath!),
                                    child: Hero(
                                      tag: msg.imagePath!,
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(12),
                                        child: imageWidget,
                                      ),
                                    ),
                                  ),
                                ),
                              if (msg.text != null && msg.text!.isNotEmpty)
                                Text(
                                  msg.text!, 
                                  style: const TextStyle(fontSize: 13, color: Color(0xFF1A1A2E), height: 1.4)
                                ),
                            ],
                          ),
                  ),
                  const SizedBox(height: 4),
                  Text(_formatTime(msg.time), style: const TextStyle(fontSize: 10, color: Color(0xFF94A3B8))),
                ],
              ),
            ),
            if (isUser) const SizedBox(width: 4),
          ],
        ),
      ),
    );
  }

  // ── Image viewer ─────────────────────────────────────────────────────────
  void _showImageViewer(BuildContext context, String imagePath) {
    Navigator.push(
      context,
      PageRouteBuilder(
        opaque: false, barrierColor: Colors.black,
        pageBuilder: (_, __, ___) => _ImageViewerScreen(imagePath: imagePath),
        transitionDuration: const Duration(milliseconds: 250),
        transitionsBuilder: (_, anim, __, child) => FadeTransition(opacity: anim, child: child),
      ),
    );
  }

  // ── Long press options ────────────────────────────────────────────────────
  void _showMessageOptions(ChatMessage msg) {
    if (msg.isDeleted) return;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 40, height: 4, decoration: BoxDecoration(color: const Color(0xFFE2E8F0), borderRadius: BorderRadius.circular(2))),
              const SizedBox(height: 12),
              
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16), padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFE9ECEF))),
                child: Row(
                  children: [
                    const Icon(Icons.chat_bubble_outline_rounded, size: 16, color: Color(0xFF94A3B8)),
                    const SizedBox(width: 8),
                    Expanded(child: Text(msg.imagePath != null ? '📷 Gambar' : (msg.text ?? ''), style: const TextStyle(fontSize: 13, color: Color(0xFF475569)), maxLines: 2, overflow: TextOverflow.ellipsis)),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              
              ListTile(
                leading: Container(
                  width: 40, height: 40,
                  decoration: BoxDecoration(color: const Color(0xFFE8F0FE), borderRadius: BorderRadius.circular(10)),
                  child: const Icon(Icons.reply_rounded, color: Color(0xFF3B5BDB), size: 20),
                ),
                title: const Text('Balas', style: TextStyle(fontWeight: FontWeight.w600)),
                onTap: () {
                  Navigator.pop(context);
                  _setReply(msg);
                },
              ),
              
              if (msg.isUser)
                ListTile(
                  leading: Container(
                    width: 40, height: 40,
                    decoration: BoxDecoration(color: const Color(0xFFFFEBEE), borderRadius: BorderRadius.circular(10)),
                    child: const Icon(Icons.delete_outline_rounded, color: Color(0xFFE53935), size: 20),
                  ),
                  title: const Text('Hapus Pesan', style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFFE53935))),
                  onTap: () {
                    Navigator.pop(context);
                    showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        title: const Text('Hapus Pesan?', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1A1A2E))),
                        content: const Text('Pesan akan ditarik dan dihapus dari server.', style: TextStyle(fontSize: 13, color: Color(0xFF64748B))),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal', style: TextStyle(color: Color(0xFF64748B)))),
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                              _deleteMessage(msg); 
                            },
                            child: const Text('Hapus', style: TextStyle(color: Color(0xFFE53935), fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Full screen image viewer ──────────────────────────────────────────────────
class _ImageViewerScreen extends StatefulWidget {
  final String imagePath;
  const _ImageViewerScreen({required this.imagePath});

  @override
  State<_ImageViewerScreen> createState() => _ImageViewerScreenState();
}

class _ImageViewerScreenState extends State<_ImageViewerScreen> {
  final TransformationController _transformCtrl = TransformationController();

  @override
  void dispose() {
    _transformCtrl.dispose();
    super.dispose();
  }

  void _resetZoom() {
    _transformCtrl.value = Matrix4.identity();
  }

  @override
  Widget build(BuildContext context) {
    Widget imageWidget = widget.imagePath.startsWith('http') 
        ? Image.network(widget.imagePath, fit: BoxFit.contain, width: MediaQuery.of(context).size.width) 
        : Image.file(File(widget.imagePath), fit: BoxFit.contain, width: MediaQuery.of(context).size.width);

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Center(
            child: Hero(
              tag: widget.imagePath,
              child: GestureDetector(
                onDoubleTap: () {
                  final zoomed = _transformCtrl.value != Matrix4.identity();
                  if (zoomed) {
                    _resetZoom();
                  } else {
                    final x = MediaQuery.of(context).size.width / 2;
                    final y = MediaQuery.of(context).size.height / 2;
                    _transformCtrl.value = Matrix4.identity()..translate(-x * 1.5, -y * 1.5)..scale(2.5);
                  }
                },
                child: InteractiveViewer(
                  transformationController: _transformCtrl,
                  clipBehavior: Clip.none, panEnabled: true, scaleEnabled: true, minScale: 0.5, maxScale: 5.0,
                  child: imageWidget,
                ),
              ),
            ),
          ),
          SafeArea(
            child: Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 40, height: 40,
                    decoration: BoxDecoration(color: Colors.black.withOpacity(0.5), shape: BoxShape.circle),
                    child: const Icon(Icons.close_rounded, color: Colors.white, size: 22),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}