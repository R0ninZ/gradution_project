import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AIBuddyView extends StatefulWidget {
  const AIBuddyView({super.key});

  @override
  State<AIBuddyView> createState() => _AIBuddyViewState();
}

class _AIBuddyViewState extends State<AIBuddyView> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<_ChatMessage> _messages = [];

  late final String _returnRoute;

  @override
  void initState() {
    super.initState();
    _returnRoute =
        (Get.arguments as Map<String, dynamic>?)?['returnRoute'] ?? '/home';
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final text = _textController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add(_ChatMessage(text: text, isUser: true));
      _messages.add(_ChatMessage(
        text: "I'm still being set up! Check back soon. 🤖",
        isUser: false,
      ));
    });

    _textController.clear();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0D1F3C), Color(0xFF0A1628)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _topBar(),
              Expanded(
                child: _messages.isEmpty ? _emptyState() : _messageList(),
              ),
              _inputBar(),
            ],
          ),
        ),
      ),
    );
  }

  // =========================================================
  // TOP BAR
  // =========================================================

  Widget _topBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          _iconButton(
            icon: Icons.home_rounded,
            onTap: () => Get.offAllNamed(_returnRoute),
          ),
          const Spacer(),
          // App name — not localized (brand name)
          const Text(
            'Echo Mind',
            style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5),
          ),
          const Spacer(),
          _iconButton(
            icon: Icons.refresh_rounded,
            onTap: () => setState(() => _messages.clear()),
          ),
        ],
      ),
    );
  }

  Widget _iconButton({required IconData icon, required VoidCallback onTap}) =>
      GestureDetector(
        onTap: onTap,
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: Colors.white, size: 22),
        ),
      );

  // =========================================================
  // EMPTY STATE  — fully localized
  // =========================================================

  Widget _emptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.07),
            ),
            child: const Icon(Icons.smart_toy_rounded,
                color: Colors.white38, size: 36),
          ),
          const SizedBox(height: 20),
          Text(
            'what_can_i_help'.tr,
            style: const TextStyle(
                color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'ask_me_anything'.tr,
            style: TextStyle(
                color: Colors.white.withOpacity(0.45), fontSize: 14),
          ),
        ],
      ),
    );
  }

  // =========================================================
  // MESSAGE LIST
  // =========================================================

  Widget _messageList() {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: _messages.length,
      itemBuilder: (_, i) => _messageBubble(_messages[i]),
    );
  }

  Widget _messageBubble(_ChatMessage msg) {
    return Align(
      alignment: msg.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5),
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.72,
        ),
        decoration: BoxDecoration(
          color: msg.isUser
              ? const Color(0xFF3E82F7)
              : Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(18),
            topRight: const Radius.circular(18),
            bottomLeft: Radius.circular(msg.isUser ? 18 : 4),
            bottomRight: Radius.circular(msg.isUser ? 4 : 18),
          ),
        ),
        child: Text(msg.text,
            style: const TextStyle(
                color: Colors.white, fontSize: 14, height: 1.4)),
      ),
    );
  }

  // =========================================================
  // INPUT BAR — localized hint
  // =========================================================

  Widget _inputBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 50,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(25),
                border:
                    Border.all(color: Colors.white.withOpacity(0.15)),
              ),
              child: TextField(
                controller: _textController,
                style:
                    const TextStyle(color: Colors.white, fontSize: 14),
                onSubmitted: (_) => _sendMessage(),
                decoration: InputDecoration(
                  hintText: 'message'.tr,
                  hintStyle: TextStyle(
                      color: Colors.white.withOpacity(0.4), fontSize: 14),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 14),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: _sendMessage,
            child: Container(
              width: 50,
              height: 50,
              decoration: const BoxDecoration(
                  shape: BoxShape.circle, color: Color(0xFF3E82F7)),
              child: const Icon(Icons.arrow_upward_rounded,
                  color: Colors.white, size: 22),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChatMessage {
  final String text;
  final bool isUser;
  _ChatMessage({required this.text, required this.isUser});
}
