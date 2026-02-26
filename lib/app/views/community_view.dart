import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../controllers/community_controller.dart';

class CommunityView extends GetView<CommunityController> {
  const CommunityView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = Theme.of(context).scaffoldBackgroundColor;
    final cardColor = Theme.of(context).cardColor;

    return GetBuilder<CommunityController>(
      builder: (c) {
        return Scaffold(
          backgroundColor: bg,
          body: Column(
            children: [
              _header(context, c, isDark),
              Expanded(
                child: c.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : c.filteredStudents.isEmpty
                        ? _emptyState(c, isDark)
                        : ListView.builder(
                            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                            itemCount: c.filteredStudents.length,
                            itemBuilder: (_, i) =>
                                _studentCard(c.filteredStudents[i], cardColor, isDark),
                          ),
              ),
            ],
          ),
          bottomNavigationBar: _bottomNavBar(isDark),
        );
      },
    );
  }

  Widget _header(BuildContext context, CommunityController c, bool isDark) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 55, 20, 20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1A2E) : const Color(0xFF0D3B66),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(28)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('community'.tr,
              style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 44,
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF2A2A3E) : Colors.white,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: TextField(
                    onChanged: c.onSearchChanged,
                    style: TextStyle(fontSize: 14, color: isDark ? Colors.white : const Color(0xFF1A1A2E)),
                    decoration: InputDecoration(
                      hintText: 'search_by_name'.tr,
                      hintStyle: TextStyle(color: isDark ? Colors.grey[500] : Colors.grey),
                      prefixIcon: Icon(Icons.search, color: isDark ? Colors.grey[400] : Colors.grey, size: 20),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              GestureDetector(
                onTap: () => _showFilterSheet(context, c, isDark),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: c.activeFilterCount > 0 ? Colors.white : Colors.white.withOpacity(0.18),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(
                        Icons.tune_rounded,
                        color: c.activeFilterCount > 0 ? const Color(0xFF0D3B66) : Colors.white,
                        size: 22,
                      ),
                    ),
                    if (c.activeFilterCount > 0)
                      Positioned(
                        top: -4, right: -4,
                        child: Container(
                          width: 18, height: 18,
                          decoration: const BoxDecoration(color: Color(0xFF3E82F7), shape: BoxShape.circle),
                          child: Center(
                            child: Text('${c.activeFilterCount}',
                                style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          if (c.selectedTrack != null || c.selectedYear != null) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                if (c.selectedTrack != null)
                  _activeTag(c.selectedTrack!, () => c.setTrackFilter(null)),
                if (c.selectedYear != null)
                  _activeTag('${'year_prefix'.tr}${c.selectedYear}', () => c.setYearFilter(null)),
                const Spacer(),
                GestureDetector(
                  onTap: c.clearFilters,
                  child: Text('clear_all'.tr,
                      style: const TextStyle(color: Colors.white70, fontSize: 12, decoration: TextDecoration.underline)),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _activeTag(String label, VoidCallback onRemove) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(20)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
          const SizedBox(width: 4),
          GestureDetector(onTap: onRemove, child: const Icon(Icons.close, color: Colors.white70, size: 14)),
        ],
      ),
    );
  }

  void _showFilterSheet(BuildContext context, CommunityController c, bool isDark) {
    String? tempTrack = c.selectedTrack;
    int? tempYear = c.selectedYear;
    final sheetBg = isDark ? const Color(0xFF1E1E2E) : Colors.white;
    final labelColor = isDark ? Colors.grey[300]! : const Color(0xFF555555);
    final chipBg = isDark ? const Color(0xFF2A2A3E) : const Color(0xFFF0F4F8);
    final chipText = isDark ? Colors.grey[300]! : const Color(0xFF555555);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) {
        return StatefulBuilder(
          builder: (ctx, setState) {
            return Container(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 36),
              decoration: BoxDecoration(color: sheetBg, borderRadius: const BorderRadius.vertical(top: Radius.circular(28))),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40, height: 4,
                      decoration: BoxDecoration(color: isDark ? Colors.grey[700] : Colors.grey[300], borderRadius: BorderRadius.circular(2)),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('filter_students'.tr,
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.white : const Color(0xFF1A1A2E))),
                      if (tempTrack != null || tempYear != null)
                        TextButton(
                          onPressed: () => setState(() { tempTrack = null; tempYear = null; }),
                          child: Text('reset'.tr, style: const TextStyle(color: Color(0xFF3E82F7))),
                        ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text('track'.tr, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: labelColor)),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 10, runSpacing: 10,
                    children: c.tracks.map((track) {
                      final sel = tempTrack == track;
                      return GestureDetector(
                        onTap: () => setState(() => tempTrack = sel ? null : track),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          decoration: BoxDecoration(color: sel ? const Color(0xFF0D3B66) : chipBg, borderRadius: BorderRadius.circular(12)),
                          child: Text(track, style: TextStyle(color: sel ? Colors.white : chipText, fontWeight: FontWeight.w600, fontSize: 14)),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),
                  Text('university_year'.tr, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: labelColor)),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 10, runSpacing: 10,
                    children: c.years.map((year) {
                      final sel = tempYear == year;
                      return GestureDetector(
                        onTap: () => setState(() => tempYear = sel ? null : year),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          decoration: BoxDecoration(color: sel ? const Color(0xFF3E82F7) : chipBg, borderRadius: BorderRadius.circular(12)),
                          child: Text('${'year_prefix'.tr}$year', style: TextStyle(color: sel ? Colors.white : chipText, fontWeight: FontWeight.w600, fontSize: 14)),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 28),
                  SizedBox(
                    width: double.infinity, height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0D3B66), foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), elevation: 0),
                      onPressed: () { c.setTrackFilter(tempTrack); c.setYearFilter(tempYear); Navigator.pop(context); },
                      child: Text('apply_filters'.tr, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _studentCard(StudentModel student, Color cardColor, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(isDark ? 0.3 : 0.06), blurRadius: 10)],
      ),
      child: Row(
        children: [
          _buildAvatar(student),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(student.fullName,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: isDark ? Colors.white : const Color(0xFF1A1A2E))),
                const SizedBox(height: 4),
                Row(
                  children: [
                    _infoBadge(student.track, const Color(0xFF0D3B66)),
                    const SizedBox(width: 6),
                    _infoBadge('${'year_prefix'.tr}${student.universityYear}', const Color(0xFF3E82F7)),
                  ],
                ),
              ],
            ),
          ),
          if (student.linkedin != null && student.linkedin!.isNotEmpty)
            GestureDetector(
              onTap: () => _openLinkedIn(student.linkedin!),
              child: ClipRRect(borderRadius: BorderRadius.circular(10), child: Image.asset('assets/linkedin.png', width: 38, height: 38, fit: BoxFit.cover)),
            ),
        ],
      ),
    );
  }

  Widget _buildAvatar(StudentModel student) {
    if (student.avatarUrl != null && student.avatarUrl!.isNotEmpty) {
      return CircleAvatar(radius: 26, backgroundColor: _avatarColor(student.fullName), backgroundImage: NetworkImage(student.avatarUrl!), onBackgroundImageError: (_, __) {});
    }
    return CircleAvatar(
      radius: 26,
      backgroundColor: _avatarColor(student.fullName),
      child: Text(_initials(student.fullName), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
    );
  }

  Widget _infoBadge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
      child: Text(label, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600)),
    );
  }

  Widget _emptyState(CommunityController c, bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off_rounded, size: 64, color: isDark ? Colors.grey[600] : Colors.grey[350]),
          const SizedBox(height: 16),
          Text('no_students_found'.tr, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.grey[400] : Colors.grey[600])),
          const SizedBox(height: 8),
          Text('try_different_search'.tr, style: TextStyle(color: isDark ? Colors.grey[600] : Colors.grey[400])),
          if (c.hasActiveFilters) ...[
            const SizedBox(height: 20),
            TextButton(onPressed: c.clearFilters, child: Text('clear_filters'.tr)),
          ],
        ],
      ),
    );
  }

  String _initials(String fullName) {
    final parts = fullName.trim().split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    return fullName.isNotEmpty ? fullName[0].toUpperCase() : '?';
  }

  Color _avatarColor(String name) {
    const colors = [Color(0xFF0D3B66), Color(0xFF3E82F7), Color(0xFF1A4A8A), Color(0xFF2E7D32), Color(0xFF6A1B9A), Color(0xFFC62828), Color(0xFF00695C), Color(0xFFE65100)];
    return colors[name.hashCode.abs() % colors.length];
  }

  Future<void> _openLinkedIn(String url) async {
    try {
      String cleaned = url.trim();
      if (!cleaned.startsWith('http://') && !cleaned.startsWith('https://')) cleaned = 'https://$cleaned';
      await launchUrl(Uri.parse(cleaned), mode: LaunchMode.externalApplication);
    } catch (_) {
      Get.snackbar('error'.tr, 'linkedin_error'.tr, snackPosition: SnackPosition.BOTTOM);
    }
  }

  Widget _bottomNavBar(bool isDark) {
    final active = isDark ? const Color(0xFF3E82F7) : const Color(0xFF0D3B66);
    final inactive = isDark ? Colors.grey[500]! : Colors.grey[600]!;
    return BottomAppBar(
      elevation: 8,
      child: SizedBox(
        height: 65,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _navItem(Icons.home_outlined, 'home'.tr, color: inactive, onTap: () => Get.offAllNamed('/home')),
            _navItem(Icons.person_outline, 'profile'.tr, color: inactive, onTap: () => Get.offAllNamed('/profile')),
            _navItem(Icons.groups_rounded, 'community'.tr, color: active, isActive: true, onTap: () {}),
            _navItem(Icons.settings_outlined, 'settings'.tr, color: inactive, onTap: () => Get.offAllNamed('/settings', arguments: {'isTA': false})),
          ],
        ),
      ),
    );
  }

  Widget _navItem(IconData icon, String label, {bool isActive = false, required Color color, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 26),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(color: color, fontSize: 11, fontWeight: isActive ? FontWeight.w600 : FontWeight.normal)),
        ],
      ),
    );
  }
}
