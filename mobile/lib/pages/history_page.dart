import 'package:flutter/material.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  static const Color _navy  = Color(0xFF1A2657);
  static const Color _green = Color(0xFF27AE60);
  static const Color _amber = Color(0xFFF5A623);
  static const Color _bg    = Color(0xFFF0F2F5);

  static final List<Map<String, dynamic>> _sessions = [
    {
      'group': 'TODAY',
      'items': [
        {
          'title': 'Cell Biology',
          'time': '10:42 AM',
          'duration': '8m 42s',
          'score': 17,
          'total': 20,
          'color': _green,
        },
        {
          'title': 'Quick MCQ',
          'time': '08:15 AM',
          'duration': '4m 11s',
          'score': 8,
          'total': 10,
          'color': _green,
        },
      ],
    },
    {
      'group': 'YESTERDAY',
      'items': [
        {
          'title': 'Genetics',
          'time': '07:30 PM',
          'duration': '11m 02s',
          'score': 12,
          'total': 20,
          'color': _amber,
        },
        {
          'title': 'Plant Bio',
          'time': '02:11 PM',
          'duration': '7m 30s',
          'score': 5,
          'total': 15,
          'color': Colors.redAccent,
        },
      ],
    },
    {
      'group': 'MAY 15',
      'items': [
        {
          'title': 'Evolution',
          'time': '09:00 AM',
          'duration': '9m 18s',
          'score': 14,
          'total': 15,
          'color': _green,
        },
      ],
    },
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('SESSIONS',
              style: TextStyle(
                  color: Colors.grey.shade400,
                  fontSize: 11,
                  letterSpacing: 1.2,
                  fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          const Text('ඉතිහාසය',
              style: TextStyle(
                  color: _navy, fontSize: 28, fontWeight: FontWeight.w800)),
          const SizedBox(height: 20),

          ..._sessions.map((group) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Text(group['group'] as String,
                        style: TextStyle(
                            color: Colors.grey.shade400,
                            fontSize: 11,
                            letterSpacing: 1,
                            fontWeight: FontWeight.w600)),
                  ),
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
                        ...(group['items'] as List<Map<String, dynamic>>)
                            .asMap()
                            .entries
                            .map((entry) {
                          final i = entry.key;
                          final item = entry.value;
                          final isLast = i ==
                              (group['items'] as List).length - 1;
                          final score = item['score'] as int;
                          final total = item['total'] as int;
                          final color = item['color'] as Color;

                          return Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 14),
                                child: Row(
                                  children: [
                                    // Color accent bar
                                    Container(
                                      width: 3,
                                      height: 40,
                                      decoration: BoxDecoration(
                                        color: color,
                                        borderRadius:
                                            BorderRadius.circular(2),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(item['title'] as String,
                                              style: const TextStyle(
                                                color: _navy,
                                                fontSize: 14,
                                                fontWeight: FontWeight.w700,
                                              )),
                                          const SizedBox(height: 3),
                                          Text(
                                            '${item['time']}  •  ${item['duration']}',
                                            style: TextStyle(
                                                color: Colors.grey.shade400,
                                                fontSize: 12),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        Text(
                                          '$score/$total',
                                          style: TextStyle(
                                            color: color,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w800,
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        Icon(
                                            Icons.arrow_forward_ios_rounded,
                                            size: 12,
                                            color: Colors.grey.shade300),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              if (!isLast)
                                Divider(
                                    height: 1,
                                    color: Colors.grey.shade100,
                                    indent: 16,
                                    endIndent: 16),
                            ],
                          );
                        }),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              )),
        ],
      ),
    );
  }
}