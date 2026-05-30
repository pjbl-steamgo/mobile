import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ChatMessage {
  final String? text;
  final String? imagePath;
  final bool isUser;
  final DateTime time;
  final ChatMessage? replyTo;
  bool isDeleted;

  ChatMessage({
    this.text,
    this.imagePath,
    required this.isUser,
    required this.time,
    this.replyTo,
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

  final List<ChatMessage> _messages = [
    ChatMessage(
      text: 'Apakah jadwal saya sesuai?',
      isUser: true,
      time: DateTime.now().subtract(const Duration(minutes: 3)),
    ),
    ChatMessage(
      text: 'Halo! Jadwal pemesanan anda sesuai dengan estimasi 25 menit dari sekarang',
      isUser: false,
      time: DateTime.now().subtract(const Duration(minutes: 2)),
    ),
  ];

  final List<String> _autoReplies = [
    'Baik, kami akan segera memproses pesanan Anda.',
    'Terima kasih sudah menghubungi kami! Ada yang bisa kami bantu lagi?',
    'Mohon tunggu sebentar, petugas kami sedang memeriksa.',
    'Jadwal Anda sudah terkonfirmasi. Silahkan datang sesuai waktu yang dipilih.',
    'Kami siap melayani Anda! Jika ada pertanyaan lain, jangan ragu untuk bertanya.',
  ];
  int _replyIndex = 0;

  void _sendMessage({String? text, String? imagePath}) {
    final msgText = text ?? _controller.text.trim();
    if (msgText.isEmpty && imagePath == null) return;

    final newMsg = ChatMessage(
      text: imagePath == null ? msgText : null,
      imagePath: imagePath,
      isUser: true,
      time: DateTime.now(),
      replyTo: _replyingTo,
    );

    setState(() {
      _messages.add(newMsg);
      _controller.clear();
      _replyingTo = null;
    });

    _scrollToBottom();

    // Auto reply hanya untuk teks
    if (imagePath == null) {
      Future.delayed(const Duration(milliseconds: 1000), () {
        if (!mounted) return;
        setState(() {
          _messages.add(ChatMessage(
            text: _autoReplies[_replyIndex % _autoReplies.length],
            isUser: false,
            time: DateTime.now(),
          ));
          _replyIndex++;
        });
        _scrollToBottom();
      });
    }
  }

  Future<void> _pickImage() async {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                    color: const Color(0xFFE2E8F0),
                    borderRadius: BorderRadius.circular(2)),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: Container(
                  width: 42, height: 42,
                  decoration: BoxDecoration(
                      color: const Color(0xFFE3F2FD),
                      borderRadius: BorderRadius.circular(12)),
                  child: const Icon(Icons.camera_alt_rounded,
                      color: Color(0xFF3B5BDB)),
                ),
                title: const Text('Kamera',
                    style: TextStyle(fontWeight: FontWeight.w600)),
                onTap: () async {
                  Navigator.pop(context);
                  final img = await _picker.pickImage(
                      source: ImageSource.camera, imageQuality: 70);
                  if (img != null) _sendMessage(imagePath: img.path);
                },
              ),
              ListTile(
                leading: Container(
                  width: 42, height: 42,
                  decoration: BoxDecoration(
                      color: const Color(0xFFE8F5E9),
                      borderRadius: BorderRadius.circular(12)),
                  child: const Icon(Icons.photo_library_rounded,
                      color: Color(0xFF4CAF50)),
                ),
                title: const Text('Galeri',
                    style: TextStyle(fontWeight: FontWeight.w600)),
                onTap: () async {
                  Navigator.pop(context);
                  final img = await _picker.pickImage(
                      source: ImageSource.gallery, imageQuality: 70);
                  if (img != null) _sendMessage(imagePath: img.path);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _deleteMessage(ChatMessage msg) {
    setState(() => msg.isDeleted = true);
  }

  void _setReply(ChatMessage msg) {
    setState(() => _replyingTo = msg);
  }

  void _cancelReply() {
    setState(() => _replyingTo = null);
  }

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

  String _formatTime(DateTime t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

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
              decoration: const BoxDecoration(
                  color: Color(0xFF3B5BDB), shape: BoxShape.circle),
              child: const Icon(Icons.support_agent_rounded,
                  color: Colors.white, size: 20),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('SteamGo Support',
                    style: TextStyle(
                        color: Color(0xFF1A1A2E),
                        fontSize: 15,
                        fontWeight: FontWeight.bold)),
                Row(
                  children: [
                    Container(
                        width: 7, height: 7,
                        decoration: const BoxDecoration(
                            color: Color(0xFF4CAF50), shape: BoxShape.circle)),
                    const SizedBox(width: 4),
                    const Text('Online',
                        style: TextStyle(fontSize: 11, color: Color(0xFF4CAF50))),
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
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                final showDate = index == 0 ||
                    msg.time.day != _messages[index - 1].time.day;
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
                      decoration: BoxDecoration(
                          color: const Color(0xFF3B5BDB),
                          borderRadius: BorderRadius.circular(2))),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _replyingTo!.isUser ? 'Anda' : 'SteamGo Support',
                          style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF3B5BDB)),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _replyingTo!.isDeleted
                              ? 'Pesan telah dihapus'
                              : (_replyingTo!.imagePath != null
                                  ? '📷 Gambar'
                                  : _replyingTo!.text ?? ''),
                          style: const TextStyle(
                              fontSize: 12, color: Color(0xFF64748B)),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded,
                        size: 18, color: Color(0xFF94A3B8)),
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
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -3))
              ],
            ),
            child: Row(
              children: [
                // Tombol gambar
                GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    width: 40, height: 40,
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(Icons.image_rounded,
                        color: Color(0xFF64748B), size: 20),
                  ),
                ),
                // Input field
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: TextField(
                      controller: _controller,
                      onSubmitted: (_) => _sendMessage(),
                      textInputAction: TextInputAction.send,
                      style: const TextStyle(
                          fontSize: 14, color: Color(0xFF1A1A2E)),
                      decoration: const InputDecoration(
                        hintText: 'Tulis pesan...',
                        hintStyle: TextStyle(
                            color: Color(0xFFCBD5E1), fontSize: 14),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // Tombol kirim
                GestureDetector(
                  onTap: () => _sendMessage(),
                  child: Container(
                    width: 44, height: 44,
                    decoration: const BoxDecoration(
                        color: Color(0xFF3B5BDB), shape: BoxShape.circle),
                    child: const Icon(Icons.send_rounded,
                        color: Colors.white, size: 20),
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
    const months = [
      '', 'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          const Expanded(child: Divider(color: Color(0xFFE2E8F0))),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text('${time.day} ${months[time.month]} ${time.year}',
                style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8))),
          ),
          const Expanded(child: Divider(color: Color(0xFFE2E8F0))),
        ],
      ),
    );
  }

  // ── Chat bubble ───────────────────────────────────────────────────────────
  Widget _buildBubble(ChatMessage msg) {
    final isUser = msg.isUser;

    return GestureDetector(
      onLongPress: () => _showMessageOptions(msg),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Row(
          mainAxisAlignment:
              isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // Avatar admin
            if (!isUser) ...[
              Container(
                width: 30, height: 30,
                decoration: const BoxDecoration(
                    color: Color(0xFF3B5BDB), shape: BoxShape.circle),
                child: const Icon(Icons.support_agent_rounded,
                    color: Colors.white, size: 16),
              ),
              const SizedBox(width: 8),
            ],

            Flexible(
              child: Column(
                crossAxisAlignment:
                    isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                children: [
                  // Preview reply
                  if (msg.replyTo != null && !msg.isDeleted)
                    Container(
                      margin: const EdgeInsets.only(bottom: 4),
                      padding: const EdgeInsets.fromLTRB(10, 6, 10, 6),
                      decoration: BoxDecoration(
                        color: isUser
                            ? const Color(0xFF9DD4A8)
                            : const Color(0xFFE9ECEF),
                        borderRadius: BorderRadius.circular(10),
                        border: const Border(
                          left: BorderSide(
                              color: Color(0xFF3B5BDB), width: 3),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            msg.replyTo!.isUser ? 'Anda' : 'SteamGo Support',
                            style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF3B5BDB)),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            msg.replyTo!.isDeleted
                                ? 'Pesan telah dihapus'
                                : (msg.replyTo!.imagePath != null
                                    ? '📷 Gambar'
                                    : msg.replyTo!.text ?? ''),
                            style: const TextStyle(
                                fontSize: 11, color: Color(0xFF475569)),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),

                  // Bubble utama
                  Container(
                    padding: msg.imagePath != null
                        ? const EdgeInsets.all(4)
                        : const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: msg.isDeleted
                          ? const Color(0xFFF1F5F9)
                          : (isUser
                              ? const Color(0xFFB5EAC2)
                              : Colors.white),
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(16),
                        topRight: const Radius.circular(16),
                        bottomLeft: Radius.circular(isUser ? 16 : 4),
                        bottomRight: Radius.circular(isUser ? 4 : 16),
                      ),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 6,
                            offset: const Offset(0, 2))
                      ],
                    ),
                    child: msg.isDeleted
                        ? Row(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              Icon(Icons.block_rounded,
                                  size: 14, color: Color(0xFF94A3B8)),
                              SizedBox(width: 6),
                              Text('Pesan telah dihapus',
                                  style: TextStyle(
                                      fontSize: 13,
                                      color: Color(0xFF94A3B8),
                                      fontStyle: FontStyle.italic)),
                            ],
                          )
                        : msg.imagePath != null
                            ? GestureDetector(
                                onTap: () => _showImageViewer(context, msg.imagePath!),
                                child: Hero(
                                  tag: msg.imagePath!,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Image.file(
                                      File(msg.imagePath!),
                                      width: 200,
                                      height: 200,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) => Container(
                                        width: 200, height: 120,
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFE9ECEF),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: const Icon(Icons.image_rounded,
                                            color: Color(0xFF94A3B8), size: 40),
                                      ),
                                    ),
                                  ),
                                ),
                              )
                            : Text(
                                msg.text ?? '',
                                style: const TextStyle(
                                    fontSize: 13,
                                    color: Color(0xFF1A1A2E),
                                    height: 1.4),
                              ),
                  ),

                  // Timestamp
                  const SizedBox(height: 4),
                  Text(_formatTime(msg.time),
                      style: const TextStyle(
                          fontSize: 10, color: Color(0xFF94A3B8))),
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
        opaque: false,
        barrierColor: Colors.black,
        pageBuilder: (_, __, ___) => _ImageViewerScreen(imagePath: imagePath),
        transitionDuration: const Duration(milliseconds: 250),
        transitionsBuilder: (_, anim, __, child) =>
            FadeTransition(opacity: anim, child: child),
      ),
    );
  }

  // ── Long press options ────────────────────────────────────────────────────
  void _showMessageOptions(ChatMessage msg) {
    if (msg.isDeleted) return;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                    color: const Color(0xFFE2E8F0),
                    borderRadius: BorderRadius.circular(2)),
              ),
              const SizedBox(height: 12),

              // Preview pesan yang dipilih
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE9ECEF)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.chat_bubble_outline_rounded,
                        size: 16, color: Color(0xFF94A3B8)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        msg.imagePath != null ? '📷 Gambar' : (msg.text ?? ''),
                        style: const TextStyle(
                            fontSize: 13, color: Color(0xFF475569)),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),

              // Opsi: Balas
              ListTile(
                leading: Container(
                  width: 40, height: 40,
                  decoration: BoxDecoration(
                      color: const Color(0xFFE8F0FE),
                      borderRadius: BorderRadius.circular(10)),
                  child: const Icon(Icons.reply_rounded,
                      color: Color(0xFF3B5BDB), size: 20),
                ),
                title: const Text('Balas',
                    style: TextStyle(fontWeight: FontWeight.w600)),
                onTap: () {
                  Navigator.pop(context);
                  _setReply(msg);
                },
              ),

              // Opsi: Hapus (hanya untuk pesan sendiri)
              if (msg.isUser)
                ListTile(
                  leading: Container(
                    width: 40, height: 40,
                    decoration: BoxDecoration(
                        color: const Color(0xFFFFEBEE),
                        borderRadius: BorderRadius.circular(10)),
                    child: const Icon(Icons.delete_outline_rounded,
                        color: Color(0xFFE53935), size: 20),
                  ),
                  title: const Text('Hapus Pesan',
                      style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Color(0xFFE53935))),
                  onTap: () {
                    Navigator.pop(context);
                    showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                        title: const Text('Hapus Pesan?',
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1A1A2E))),
                        content: const Text(
                            'Pesan akan dihapus untuk semua orang.',
                            style: TextStyle(
                                fontSize: 13, color: Color(0xFF64748B))),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Batal',
                                style: TextStyle(color: Color(0xFF64748B))),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                              _deleteMessage(msg);
                            },
                            child: const Text('Hapus',
                                style: TextStyle(
                                    color: Color(0xFFE53935),
                                    fontWeight: FontWeight.bold)),
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
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Gambar dengan pinch-to-zoom + double tap reset
          Center(
            child: Hero(
              tag: widget.imagePath,
              child: GestureDetector(
                onDoubleTap: () {
                  // Double tap: zoom in ke 2.5x, atau reset kalau sudah zoom
                  final zoomed = _transformCtrl.value != Matrix4.identity();
                  if (zoomed) {
                    _resetZoom();
                  } else {
                    final x = MediaQuery.of(context).size.width / 2;
                    final y = MediaQuery.of(context).size.height / 2;
                    _transformCtrl.value = Matrix4.identity()
                      ..translate(-x * 1.5, -y * 1.5)
                      ..scale(2.5);
                  }
                },
                child: InteractiveViewer(
                  transformationController: _transformCtrl,
                  clipBehavior: Clip.none,
                  panEnabled: true,
                  scaleEnabled: true,
                  minScale: 0.5,
                  maxScale: 5.0,
                  child: Image.file(
                    File(widget.imagePath),
                    fit: BoxFit.contain,
                    width: MediaQuery.of(context).size.width,
                    errorBuilder: (_, __, ___) => const Icon(
                      Icons.broken_image_rounded,
                      color: Colors.white54,
                      size: 64,
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Tombol tutup
          SafeArea(
            child: Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.close_rounded,
                      color: Colors.white,
                      size: 22,
                    ),
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