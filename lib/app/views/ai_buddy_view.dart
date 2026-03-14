import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/ai_buddy_controller.dart';

class AIBuddyView extends StatelessWidget {
  const AIBuddyView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AIBuddyController>();
    final returnRoute =
        (Get.arguments as Map<String, dynamic>?)?['returnRoute'] ?? '/home';

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
              _TopBar(controller: controller, returnRoute: returnRoute),
              Expanded(
                child: Obx(() {
                  if (controller.isFetchingId.value) {
                    return const Center(
                      child: CircularProgressIndicator(color: Colors.white38),
                    );
                  }
                  return controller.messages.isEmpty
                      ? _EmptyState()
                      : _MessageList(controller: controller);
                }),
              ),
              _InputBar(controller: controller),
            ],
          ),
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.controller, required this.returnRoute});
  final AIBuddyController controller;
  final String returnRoute;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          _IconBtn(icon: Icons.home_rounded, onTap: () => Get.offAllNamed(returnRoute)),
          const Spacer(),
          const Text('Echo Mind',
              style: TextStyle(color: Colors.white, fontSize: 18,
                  fontWeight: FontWeight.bold, letterSpacing: 0.5)),
          const Spacer(),
          _IconBtn(icon: Icons.refresh_rounded, onTap: controller.clearHistory),
        ],
      ),
    );
  }
}

class _IconBtn extends StatelessWidget {
  const _IconBtn({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40, height: 40,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: Colors.white, size: 22),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 72, height: 72,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.07),
            ),
            child: const Icon(Icons.smart_toy_rounded, color: Colors.white38, size: 36),
          ),
          const SizedBox(height: 20),
          Text('what_can_i_help'.tr,
              style: const TextStyle(color: Colors.white, fontSize: 22,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text('ask_me_anything'.tr,
              style: TextStyle(color: Colors.white.withOpacity(0.45), fontSize: 14)),
        ],
      ),
    );
  }
}

class _MessageList extends StatelessWidget {
  const _MessageList({required this.controller});
  final AIBuddyController controller;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: controller.scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: controller.messages.length,
      itemBuilder: (_, i) => _MessageBubble(message: controller.messages[i]),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({required this.message});
  final ChatMessage message;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.72),
        decoration: BoxDecoration(
          color: message.isError
              ? const Color(0xFF7B2D2D)
              : message.isUser
                  ? const Color(0xFF3E82F7)
                  : Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(18),
            topRight: const Radius.circular(18),
            bottomLeft: Radius.circular(message.isUser ? 18 : 4),
            bottomRight: Radius.circular(message.isUser ? 4 : 18),
          ),
        ),
        child: Text(message.text,
            style: const TextStyle(color: Colors.white, fontSize: 14, height: 1.4)),
      ),
    );
  }
}

class _InputBar extends StatelessWidget {
  const _InputBar({required this.controller});
  final AIBuddyController controller;

  @override
  Widget build(BuildContext context) {
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
                border: Border.all(color: Colors.white.withOpacity(0.15)),
              ),
              child: TextField(
                controller: controller.textController,
                style: const TextStyle(color: Colors.white, fontSize: 14),
                onSubmitted: (_) => controller.sendMessage(),
                decoration: InputDecoration(
                  hintText: 'message'.tr,
                  hintStyle: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 14),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Obx(() => GestureDetector(
                onTap: controller.sendMessage,
                child: Container(
                  width: 50, height: 50,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: controller.isLoading.value ? Colors.white24 : const Color(0xFF3E82F7),
                  ),
                  child: controller.isLoading.value
                      ? const Padding(
                          padding: EdgeInsets.all(14),
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Icon(Icons.arrow_upward_rounded, color: Colors.white, size: 22),
                ),
              )),
        ],
      ),
    );
  }
}