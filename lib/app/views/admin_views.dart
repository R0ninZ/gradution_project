import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gradution_project/app/controllers/admin_controller.dart';

class AdminHomeView extends StatelessWidget {
  const AdminHomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AdminController>(
      init: AdminController(),
      builder: (c) {
        return Scaffold(
          backgroundColor: const Color(0xFFF4F6FA),
          appBar: AppBar(
            backgroundColor: const Color(0xFF003366),
            elevation: 0,
            automaticallyImplyLeading: false,
            title: Text('admin_dashboard'.tr,
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold)),
            actions: [
              IconButton(
                onPressed: c.loadPendingTAs,
                icon: const Icon(Icons.refresh_rounded, color: Colors.white),
                tooltip: 'Refresh',
              ),
              IconButton(
                onPressed: c.logout,
                icon: const Icon(Icons.logout_rounded, color: Colors.white),
                tooltip: 'Logout',
              ),
            ],
          ),
          body: c.isDashboardLoading
              ? const Center(
                  child: CircularProgressIndicator(color: Color(0xFF003366)))
              : RefreshIndicator(
                  onRefresh: c.loadPendingTAs,
                  child: Column(
                    children: [
                      if (c.generatedCode != null) _codeBanner(c),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
                        child: Row(
                          children: [
                            Text('teaching_assistants'.tr,
                                style: TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF1A1A2E))),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 3),
                              decoration: BoxDecoration(
                                color: const Color(0xFF003366),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text('${c.pendingTAs.length}',
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: c.pendingTAs.isEmpty
                            ? _emptyState()
                            : ListView.separated(
                                padding:
                                    const EdgeInsets.fromLTRB(20, 4, 20, 24),
                                itemCount: c.pendingTAs.length,
                                separatorBuilder: (_, __) =>
                                    const SizedBox(height: 12),
                                itemBuilder: (_, i) =>
                                    _taTile(c, c.pendingTAs[i]),
                              ),
                      ),
                    ],
                  ),
                ),
        );
      },
    );
  }

  Widget _codeBanner(AdminController c) {
    final remaining = c.codeExpiresAt!.difference(DateTime.now().toUtc());
    final mins = remaining.inMinutes;
    final secs = remaining.inSeconds % 60;

    return Container(
      margin: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
            colors: [Color(0xFF003366), Color(0xFF1A5499)]),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: const Color(0xFF003366).withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.vpn_key_rounded,
                  color: Colors.white70, size: 18),
              const SizedBox(width: 8),
              Text('${'code_for'.tr}${c.generatedForName}',
                  style: const TextStyle(color: Colors.white70, fontSize: 13)),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(c.generatedCode!,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 10)),
          ),
          const SizedBox(height: 12),
          Text('${'expires_in'.tr}${mins}m ${secs}s',
              style: const TextStyle(color: Colors.white60, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _taTile(AdminController c, Map<String, dynamic> ta) {
    final fullName =
        '${ta['first_name'] ?? ''} ${ta['last_name'] ?? ''}'.trim();
    final email = ta['email'] ?? '';

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2))
        ],
      ),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        leading: CircleAvatar(
          backgroundColor: const Color(0xFFEEF3FF),
          child: Text(
            fullName.isNotEmpty ? fullName[0].toUpperCase() : '?',
            style: const TextStyle(
                color: Color(0xFF003366), fontWeight: FontWeight.bold),
          ),
        ),
        title: Text(fullName,
            style: const TextStyle(
                fontWeight: FontWeight.w600, color: Color(0xFF1A1A2E))),
        subtitle: Text(email,
            style: TextStyle(fontSize: 12, color: Colors.grey[600])),
        trailing: ElevatedButton(
          onPressed: () => c.generateCodeForTA(ta['id'], fullName),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF003366),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            elevation: 0,
          ),
          child: Text('generate_code'.tr,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }

  Widget _emptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.people_outline_rounded, size: 64, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text('no_tas_yet'.tr,
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[500])),
          const SizedBox(height: 6),
          Text('tas_appear_here'.tr,
              style: TextStyle(fontSize: 13, color: Colors.grey[400])),
        ],
      ),
    );
  }
}
