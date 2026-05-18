import 'package:flutter/material.dart';

class ProfilePage extends StatefulWidget {
  final String userName;
  final String userEmail;
  final String profileImage;
  final VoidCallback onSignOut;

  const ProfilePage({
    super.key,
    this.userName = 'Ravindu Perera',
    this.userEmail = 'ravindu@biotutor.lk',
    this.profileImage = 'assets/images/image.png',
    required this.onSignOut,
  });

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  static const Color _navy  = Color(0xFF1A2657);
  static const Color _amber = Color(0xFFF5A623);
  static const Color _bg    = Color(0xFFF0F2F5);

  bool _notifications = true;
  String _language = 'සිංහල';

  @override
  Widget build(BuildContext context) {
    final initials = widget.userName.isNotEmpty
        ? widget.userName.split(' ').map((w) => w[0]).take(2).join()
        : 'R';

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 100),
      child: Column(
        children: [
          // ── Avatar ──
          Container(
            width: 80, height: 80,
            decoration: BoxDecoration(
              color: _navy,
              borderRadius: BorderRadius.circular(20),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: widget.profileImage.isNotEmpty
                  ? Image.asset(
                      widget.profileImage,
                      fit: BoxFit.cover,
                      width: 80,
                      height: 80,
                      errorBuilder: (_, __, ___) => Center(
                        child: Text(initials,
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 28,
                                fontWeight: FontWeight.w800)),
                      ),
                    )
                  : Center(
                      child: Text(initials,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.w800)),
                    ),
            ),
          ),
          const SizedBox(height: 14),
          Text(widget.userName,
              style: const TextStyle(
                  color: _navy,
                  fontSize: 20,
                  fontWeight: FontWeight.w800)),
          const SizedBox(height: 4),
          Text(widget.userEmail,
              style: TextStyle(color: Colors.grey.shade400, fontSize: 13)),
          const SizedBox(height: 10),
          // Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: BoxDecoration(
              color: _amber.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text('A/L 2026 · BIO STREAM',
                style: TextStyle(
                    color: _amber,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.3)),
          ),

          const SizedBox(height: 24),

          // ── Stats row ──
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 3))
              ],
            ),
            child: Row(
              children: [
                _StatItem(value: '82', label: 'SESSIONS'),
                _Divider(),
                _StatItem(value: '1,240', label: 'MCQS'),
                _Divider(),
                _StatItem(value: '95%', label: 'BEST', color: const Color(0xFF27AE60)),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // ── Settings ──
          _SectionLabel('SETTINGS'),
          const SizedBox(height: 10),

          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 3))
              ],
            ),
            child: Column(
              children: [
                // Notifications
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 14),
                  child: Row(
                    children: [
                      Container(
                        width: 34, height: 34,
                        decoration: BoxDecoration(
                          color: _navy.withOpacity(0.07),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.notifications_outlined,
                            size: 18, color: _navy),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text('Notifications',
                            style: TextStyle(
                                color: _navy,
                                fontSize: 14,
                                fontWeight: FontWeight.w600)),
                      ),
                      Switch.adaptive(
                        value: _notifications,
                        onChanged: (v) => setState(() => _notifications = v),
                        activeColor: const Color(0xFF27AE60),
                      ),
                    ],
                  ),
                ),
                Divider(height: 1, color: Colors.grey.shade100, indent: 16, endIndent: 16),

                // Language
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 14),
                  child: Row(
                    children: [
                      Container(
                        width: 34, height: 34,
                        decoration: BoxDecoration(
                          color: _navy.withOpacity(0.07),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.person_outline_rounded,
                            size: 18, color: _navy),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text('Language',
                            style: TextStyle(
                                color: _navy,
                                fontSize: 14,
                                fontWeight: FontWeight.w600)),
                      ),
                      Text('SI / EN',
                          style: TextStyle(
                              color: Colors.grey.shade400,
                              fontSize: 13)),
                      const SizedBox(width: 8),
                      Icon(Icons.arrow_forward_ios_rounded,
                          size: 12, color: Colors.grey.shade300),
                    ],
                  ),
                ),
                Divider(height: 1, color: Colors.grey.shade100, indent: 16, endIndent: 16),

                // Clear history
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 14),
                  child: Row(
                    children: [
                      Container(
                        width: 34, height: 34,
                        decoration: BoxDecoration(
                          color: _navy.withOpacity(0.07),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.history_rounded,
                            size: 18, color: _navy),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text('Clear history',
                            style: TextStyle(
                                color: _navy,
                                fontSize: 14,
                                fontWeight: FontWeight.w600)),
                      ),
                      Icon(Icons.arrow_forward_ios_rounded,
                          size: 12, color: Colors.grey.shade300),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // ── About AI card ──
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _navy,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('✦', style: TextStyle(color: Color(0xFFF5A623), fontSize: 16)),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('ABOUT AI',
                          style: TextStyle(
                              color: Color(0xFFF5A623),
                              fontSize: 10,
                              letterSpacing: 1.2,
                              fontWeight: FontWeight.w700)),
                      const SizedBox(height: 6),
                      Text(
                        'Powered by Gemma 4 running entirely on your device. Your study data never leaves your phone.',
                        style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 13,
                            height: 1.5),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // ── Sign out ──
          GestureDetector(
            onTap: widget.onSignOut,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.logout_rounded,
                      color: Colors.redAccent, size: 18),
                  SizedBox(width: 8),
                  Text('Sign out',
                      style: TextStyle(
                          color: Colors.redAccent,
                          fontSize: 15,
                          fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String value;
  final String label;
  final Color? color;
  const _StatItem({required this.value, required this.label, this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(value,
              style: TextStyle(
                  color: color ?? const Color(0xFF1A2657),
                  fontSize: 22,
                  fontWeight: FontWeight.w800)),
          const SizedBox(height: 3),
          Text(label,
              style: TextStyle(
                  color: Colors.grey.shade400,
                  fontSize: 9,
                  letterSpacing: 0.8,
                  fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
        width: 1, height: 36, color: Colors.grey.shade100);
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(text,
          style: TextStyle(
              color: Colors.grey.shade400,
              fontSize: 11,
              letterSpacing: 1,
              fontWeight: FontWeight.w600)),
    );
  }
}