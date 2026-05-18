import 'dart:convert';
import 'package:flutter/services.dart';

class RagService {
  List<Map<String, dynamic>> _chunks = [];
  bool _loaded = false;

  Future<void> load() async {
    if (_loaded) return;
    final String raw = await rootBundle.loadString('assets/bio_db.json');
    final decoded = json.decode(raw);

    if (decoded is List) {
      _chunks = decoded.map<Map<String, dynamic>>((e) => {
        'text': e['text'] ?? '',
        'meta': {'unit': e['unit'] ?? '', 'page': e['page'] ?? ''},
      }).toList();
    } else if (decoded is Map) {
      final List docs = decoded['documents'] ?? [];
      final List metas = decoded['metadatas'] ?? [];
      _chunks = List.generate(docs.length, (i) => {
        'text': docs[i],
        'meta': metas[i],
      });
    }

    _loaded = true;
    print('✅ RAG loaded: ${_chunks.length} chunks');
  }

  /// Top-1 most relevant chunk retrieve කරනවා
  /// Token limit fix: 3 chunks → 1 chunk (quality same, tokens 3x අඩු)
  String retrieve(String question) {
    final qTokens = question
        .toLowerCase()
        .split(RegExp(r'\s+'))
        .where((w) => w.length > 2)
        .toList();

    if (qTokens.isEmpty || _chunks.isEmpty) return '';

    // Score all chunks
    final scores = <int, double>{};
    for (int i = 0; i < _chunks.length; i++) {
      final doc = (_chunks[i]['text'] as String).toLowerCase();
      double score = 0;
      for (final token in qTokens) {
        if (doc.contains(token)) {
          final tf = RegExp(token).allMatches(doc).length;
          score += 1.0 + (tf * 0.3);
        }
      }
      if (score > 0) scores[i] = score;
    }

    if (scores.isEmpty) {
      // Fallback — first chunk
      final c = _chunks[0];
      return 'Unit ${c['meta']['unit']} | Page ${c['meta']['page']}:\n${c['text']}';
    }

    // Top-1 only — best matching chunk
    final best = scores.entries.reduce((a, b) => a.value > b.value ? a : b);
    final meta = _chunks[best.key]['meta'];
    final text = _chunks[best.key]['text'] as String;

    print('📄 Retrieved: Unit ${meta['unit']} | Page ${meta['page']} (score: ${best.value.toStringAsFixed(1)})');
    return 'Unit ${meta['unit']} | Page ${meta['page']}:\n$text';
  }
}