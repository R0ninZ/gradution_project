import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../controllers/profile_controller.dart';

class EditProfileView extends StatefulWidget {
  const EditProfileView({super.key});

  @override
  State<EditProfileView> createState() => _EditProfileViewState();
}

class _EditProfileViewState extends State<EditProfileView> {
  late String _selectedTrack;
  late TextEditingController _firstNameCtrl;
  late TextEditingController _lastNameCtrl;
  late TextEditingController _fullNameCtrl;
  late TextEditingController _linkedinCtrl;

  // Lock full name once set — evaluated once in initState, not on every build
  late bool _fullNameAlreadySet;

  @override
  void initState() {
    super.initState();
    final c = Get.find<ProfileController>();
    final options = ['AIM', 'SAD', 'DAS'];
    _selectedTrack = options.contains(c.track) ? c.track : options.first;
    _firstNameCtrl = TextEditingController(text: c.firstName);
    _lastNameCtrl  = TextEditingController(text: c.lastName);
    _fullNameCtrl  = TextEditingController(text: c.fullNameField);
    _linkedinCtrl  = TextEditingController(text: c.linkedin ?? '');
    _fullNameAlreadySet = c.fullNameField.trim().isNotEmpty;
  }

  @override
  void dispose() {
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _fullNameCtrl.dispose();
    _linkedinCtrl.dispose();
    super.dispose();
  }

  // ── Cached theme helpers (avoid repeated Theme.of(Get.context!) calls) ────
  bool   get _isDark      => Theme.of(context).brightness == Brightness.dark;
  Color  get _cardColor   => Theme.of(context).cardColor;
  Color  get _scaffoldBg  => Theme.of(context).scaffoldBackgroundColor;
  Color  get _surfaceColor => _isDark ? const Color(0xFF2A2A3E) : const Color(0xFFF4F6FA);
  Color  get _borderColor  => _isDark ? Colors.grey[700]! : const Color(0xFFDDE3EC);
  Color  get _headerColor  => _isDark ? const Color(0xFF1A1A2E) : const Color(0xFF0D3B66);
  Color  get _onSurface    => Theme.of(context).colorScheme.onSurface;

  // =========================================================
  // BUILD
  // =========================================================

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ProfileController>(
      builder: (c) => Scaffold(
        backgroundColor: _scaffoldBg,
        body: Column(
          children: [
            _header(c),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 28, 20, 30),
                child: Column(
                  children: [
                    _formCard(c),
                    const SizedBox(height: 28),
                    _saveButton(c),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =========================================================
  // HEADER
  // =========================================================

  Widget _header(ProfileController c) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 55, 20, 32),
      decoration: BoxDecoration(
        color: _headerColor,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(32)),
      ),
      child: Column(
        children: [
          Align(
            alignment: Alignment.topLeft,
            child: GestureDetector(
              onTap: Get.back,
              child: const Icon(Icons.arrow_back_ios_new_rounded,
                  color: Colors.white, size: 20),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'edit_profile'.tr,
            style: const TextStyle(
                color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          Stack(
            children: [
              GestureDetector(
                onTap: c.pickAndUploadAvatar,
                child: Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 3),
                    color: const Color(0xFFDDE6F0),
                  ),
                  child: ClipOval(
                    child: c.isSaving
                        ? const Center(
                            child: CircularProgressIndicator(
                                color: Color(0xFF0D3B66)))
                        : c.avatarUrl != null && c.avatarUrl!.isNotEmpty
                            ? Image.network(c.avatarUrl!,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) =>
                                    _defaultAvatar(c.fullName))
                            : _defaultAvatar(c.fullName),
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: GestureDetector(
                  onTap: c.pickAndUploadAvatar,
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: const Color(0xFF3E82F7),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: const Icon(Icons.camera_alt_rounded,
                        color: Colors.white, size: 14),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _defaultAvatar(String fullName) {
    final parts = fullName.trim().split(' ');
    final initials = parts.length >= 2
        ? '${parts[0][0]}${parts[1][0]}'.toUpperCase()
        : fullName.isNotEmpty
            ? fullName[0].toUpperCase()
            : '?';
    return Container(
      color: const Color(0xFF1A4A8A),
      child: Center(
        child: Text(initials,
            style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 28)),
      ),
    );
  }

  // =========================================================
  // FORM CARD
  // =========================================================

  Widget _formCard(ProfileController c) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 12)
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── First Name ────────────────────────────────────────────────────
          _fieldLabel('first_name'.tr),
          const SizedBox(height: 6),
          _editableTextField(
            controller: _firstNameCtrl,
            hint: 'first_name_hint'.tr,
            icon: Icons.person_outline_rounded,
          ),
          const SizedBox(height: 16),

          // ── Last Name ─────────────────────────────────────────────────────
          _fieldLabel('last_name'.tr),
          const SizedBox(height: 6),
          _editableTextField(
            controller: _lastNameCtrl,
            hint: 'last_name_hint'.tr,
            icon: Icons.person_outline_rounded,
          ),
          const SizedBox(height: 16),

          // ── Full Name — one-time only ──────────────────────────────────────
          _fieldLabel('full_name_required'.tr),
          const SizedBox(height: 8),
          if (_fullNameAlreadySet) ...[
            _lockedField(text: _fullNameCtrl.text, icon: Icons.badge_outlined),
            const SizedBox(height: 8),
            _lockedNote('full_name_locked_note'.tr),
            const SizedBox(height: 10),
            _whatsAppBanner(
              title: 'need_to_change_name'.tr,
              subtitle: 'contact_support_whatsapp'.tr,
            ),
          ] else ...[
            _infoHint('full_name_unlock_hint'.tr),
            const SizedBox(height: 8),
            _editableTextField(
              controller: _fullNameCtrl,
              hint: 'full_name_placeholder'.tr,
              icon: Icons.badge_outlined,
            ),
          ],
          const SizedBox(height: 16),

          // ── Email — read-only ─────────────────────────────────────────────
          _readOnlyField(
              label: 'email'.tr, value: c.email, icon: Icons.email_outlined),
          const SizedBox(height: 16),

          // ── Student ID — locked ───────────────────────────────────────────
          _fieldLabel('student_id'.tr),
          const SizedBox(height: 6),
          _lockedField(text: c.studentId, icon: Icons.numbers_rounded),
          const SizedBox(height: 10),
          _whatsAppBanner(
            title: 'need_to_change_id'.tr,
            subtitle: 'contact_support_whatsapp'.tr,
          ),
          const SizedBox(height: 16),

          // ── Track dropdown ────────────────────────────────────────────────
          _fieldLabel('specialization'.tr),
          const SizedBox(height: 6),
          Container(
            decoration: BoxDecoration(
              color: _surfaceColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _borderColor),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedTrack,
                isExpanded: true,
                icon: const Icon(Icons.keyboard_arrow_down_rounded,
                    color: Color(0xFF0D3B66)),
                style: TextStyle(
                    color: _onSurface,
                    fontSize: 14,
                    fontWeight: FontWeight.w600),
                items: c.trackOptions.map((t) {
                  return DropdownMenuItem(value: t, child: Text(t));
                }).toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _selectedTrack = val);
                },
              ),
            ),
          ),
          const SizedBox(height: 16),

          // ── LinkedIn ──────────────────────────────────────────────────────
          _fieldLabel('linkedin_optional'.tr),
          const SizedBox(height: 6),
          _editableTextField(
            controller: _linkedinCtrl,
            hint: 'linkedin_placeholder'.tr,
            icon: Icons.link_rounded,
          ),
        ],
      ),
    );
  }

  // =========================================================
  // REUSABLE WIDGETS
  // =========================================================

  Widget _fieldLabel(String label) => Text(
        label,
        style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Color(0xFF555555)),
      );

  Widget _lockedField({required String text, required IconData icon}) =>
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        decoration: BoxDecoration(
          color: const Color(0xFFF4F6FA),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFDDE3EC)),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: Colors.grey[400]),
            const SizedBox(width: 10),
            Expanded(
              child: Text(text,
                  style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[500],
                      fontWeight: FontWeight.w600)),
            ),
            const Icon(Icons.lock_rounded, size: 16, color: Color(0xFFBDBDBD)),
          ],
        ),
      );

  Widget _lockedNote(String note) => Row(
        children: [
          const Icon(Icons.info_outline_rounded,
              size: 13, color: Color(0xFF9E9E9E)),
          const SizedBox(width: 5),
          Text(note,
              style: const TextStyle(
                  fontSize: 11, color: Color(0xFF9E9E9E))),
        ],
      );

  Widget _infoHint(String text) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF8E1),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFFFE082)),
        ),
        child: Row(
          children: [
            const Icon(Icons.info_outline_rounded,
                color: Color(0xFFF9A825), size: 16),
            const SizedBox(width: 8),
            Expanded(
              child: Text(text,
                  style: const TextStyle(
                      fontSize: 11, color: Color(0xFF795548), height: 1.4)),
            ),
          ],
        ),
      );

  Widget _whatsAppBanner(
      {required String title, required String subtitle}) =>
      GestureDetector(
        onTap: _openWhatsAppSupport,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xFFE8F5E9),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFA5D6A7)),
          ),
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: const BoxDecoration(
                    color: Color(0xFF25D366), shape: BoxShape.circle),
                child: const Icon(Icons.chat_rounded,
                    color: Colors.white, size: 17),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2E7D32))),
                    const SizedBox(height: 2),
                    Text(subtitle,
                        style: const TextStyle(
                            fontSize: 11, color: Color(0xFF388E3C))),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios_rounded,
                  size: 14, color: Color(0xFF388E3C)),
            ],
          ),
        ),
      );

  Widget _readOnlyField({
    required String label,
    required String value,
    required IconData icon,
  }) =>
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _fieldLabel(label),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
            decoration: BoxDecoration(
              color: const Color(0xFFF4F6FA),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFDDE3EC)),
            ),
            child: Row(
              children: [
                Icon(icon, size: 18, color: Colors.grey[400]),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(value,
                      style:
                          TextStyle(fontSize: 14, color: Colors.grey[500])),
                ),
                const Icon(Icons.lock_rounded,
                    size: 15, color: Color(0xFFBDBDBD)),
              ],
            ),
          ),
        ],
      );

  Widget _editableTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
  }) =>
      Container(
        decoration: BoxDecoration(
          color: _surfaceColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _borderColor),
        ),
        child: TextField(
          controller: controller,
          style: TextStyle(fontSize: 14, color: _onSurface),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey[400], fontSize: 13),
            prefixIcon:
                Icon(icon, color: const Color(0xFF0D3B66), size: 18),
            border: InputBorder.none,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
          ),
        ),
      );

  Future<void> _openWhatsAppSupport() async {
    const phone = '201011280453';
    const message =
        'Hello, I need to update my full name or my ID on the university app. My current name or ID is: ';
    final url =
        'https://wa.me/$phone?text=${Uri.encodeComponent(message)}';
    try {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    } catch (_) {
      Get.snackbar(
        'error'.tr,
        'whatsapp_error'.tr,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // =========================================================
  // SAVE BUTTON
  // =========================================================

  Widget _saveButton(ProfileController c) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF0D3B66),
          foregroundColor: Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 0,
        ),
        onPressed: c.isSaving
            ? null
            : () => c.saveChanges(
                  newFirstName: _firstNameCtrl.text,
                  newLastName: _lastNameCtrl.text,
                  newFullName: _fullNameAlreadySet
                      ? c.fullNameField
                      : _fullNameCtrl.text,
                  newStudentId: c.studentId,
                  newTrack: _selectedTrack,
                  newLinkedin: _linkedinCtrl.text,
                ),
        child: c.isSaving
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                    color: Colors.white, strokeWidth: 2),
              )
            : Text('save_changes'.tr,
                style: const TextStyle(
                    fontSize: 15, fontWeight: FontWeight.w600)),
      ),
    );
  }
}
