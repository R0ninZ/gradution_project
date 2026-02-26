import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/ta_profile_controller.dart';

class TaEditProfileView extends StatefulWidget {
  const TaEditProfileView({super.key});

  @override
  State<TaEditProfileView> createState() => _TaEditProfileViewState();
}

class _TaEditProfileViewState extends State<TaEditProfileView> {
  late TextEditingController _firstNameCtrl;
  late TextEditingController _lastNameCtrl;

  @override
  void initState() {
    super.initState();
    final c = Get.find<TaProfileController>();
    _firstNameCtrl = TextEditingController(text: c.firstName);
    _lastNameCtrl  = TextEditingController(text: c.lastName);
  }

  @override
  void dispose() {
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    super.dispose();
  }

  // ── Cached theme helpers (avoid repeated Theme.of(Get.context!) calls) ────
  bool  get _isDark      => Theme.of(context).brightness == Brightness.dark;
  Color get _cardColor   => Theme.of(context).cardColor;
  Color get _scaffoldBg  => Theme.of(context).scaffoldBackgroundColor;
  Color get _surfaceColor => _isDark ? const Color(0xFF2A2A3E) : const Color(0xFFF4F6FA);
  Color get _borderColor  => _isDark ? Colors.grey[700]! : const Color(0xFFDDE3EC);
  Color get _headerColor  => _isDark ? const Color(0xFF1A1A2E) : const Color(0xFF0D3B66);
  Color get _onSurface    => Theme.of(context).colorScheme.onSurface;

  // =========================================================
  // BUILD
  // =========================================================

  @override
  Widget build(BuildContext context) {
    return GetBuilder<TaProfileController>(
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

  Widget _header(TaProfileController c) {
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
          // ── Localized title ──────────────────────────────────────────────
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

  Widget _formCard(TaProfileController c) {
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

          // ── Email — read-only ─────────────────────────────────────────────
          _readOnlyField(
              label: 'email'.tr,
              value: c.email,
              icon: Icons.email_outlined),
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

  // =========================================================
  // SAVE BUTTON
  // =========================================================

  Widget _saveButton(TaProfileController c) {
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
