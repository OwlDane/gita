import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:gita/core/config/secrets.dart';
import 'package:gita/core/config/ai_config.dart';

class ChatRepository {
  final List<Map<String, String>> _history = [];

  final String _systemInstructions = '''
Kamu adalah Gita, sahabat curhat yang sangat pengertian, santai, dan modern. 
Bahasa kamu harus sangat natural (seperti best friend), bukan seperti asisten AI formal. 
Gunakan bahasa Indonesia yang akrab, santai (pake 'aku', 'kamu', 'ya', 'sih', 'dong', 'banget', 'oke').

Karakteristik Gita:
1. Empati Tinggi: Selalu dengerin dan validasi perasaan user dulu sebelum kasih saran.
2. Santai: Nggak kaku, sesekali pake slang ringan yang umum (tapi tetep sopan).
3. Pendukung: Selalu kasih vibe positif dan suportif.
4. Ringkas: Jangan kasih ceramah panjang leber, mending tanya balik yang bikin user mikir.
5. Manusiawi: Pake sedikit emoji yang pas (misal: ✨, 🍏, 🤍, 😊) tapi jangan lebay.

Aturan Respon:
- Jangan pernah jawab pake format list angka/bullet point yang kaku (misal: 1. blabla).
- Ngobrol mengalir aja kayak di WhatsApp.
- Tetap panggil user dengan 'kamu'.
''';

  ChatRepository() {
    resetChat();
  }

  Future<String> _postRequest(List<Map<String, String>> messages, {double temp = AIConfig.temperatureChat, int maxTokens = AIConfig.maxTokensChat}) async {
    try {
      final response = await http.post(
        Uri.parse(AIConfig.baseUrl),
        headers: {
          'Authorization': 'Bearer ${Secrets.openRouterKey}',
          'Content-Type': 'application/json',
          'HTTP-Referer': 'https://github.com/zidnae/gita',
        },
        body: jsonEncode({
          'model': AIConfig.modelChat,
          'messages': messages,
          'temperature': temp,
          'max_tokens': maxTokens,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return (data['choices'][0]['message']['content'] as String).trim();
      } else {
        debugPrint('OpenRouter Error: ${response.statusCode} - ${response.body}');
        return '';
      }
    } catch (e) {
      debugPrint('API Request Error: $e');
      return '';
    }
  }

  Future<String> sendMessage(String message) async {
    _history.add({'role': 'user', 'content': message});

    final response = await _postRequest(_history);
    
    if (response.isNotEmpty) {
      _history.add({'role': 'assistant', 'content': response});
      return response;
    }
    
    return 'Duh, kayaknya sinyal Gita lagi gak stabil deh. Coba chat lagi ya? 🙏';
  }

  Future<String> generateQuote(String journalText) async {
    final prompt = '''
User baru aja nulis jurnal ini: "$journalText"
Sebagai Gita (sahabatnya), kasih 1 kalimat semangat yang "dalam" tapi singkat (max 12 kata).
Bahasa santai, akrab, dan relevan sama isi jurnalnya.
Langsung kasih quote-nya aja, jangan pake pembuka.
''';

    final response = await _postRequest(
      [
        {'role': 'system', 'content': _systemInstructions},
        {'role': 'user', 'content': prompt},
      ],
      temp: AIConfig.temperatureInsight,
      maxTokens: AIConfig.maxTokensInsight,
    );

    return response.isNotEmpty 
        ? response.replaceAll('"', '') 
        : "Apapun yang kamu rasain sekarang, aku bangga kamu sudah jujur sama dirimu sendiri. ✨";
  }

  Future<String> generateWeeklyReflection(List<String> journals) async {
    if (journals.isEmpty) return "Yuk, mulai catat ceritamu minggu ini biar Gita bisa kasih rahasia kecil buat kamu! ✨";

    final journalsCombined = journals.map((j) => "- $j").join('\n');
    final prompt = '''
Summary jurnal seminggu ini:
$journalsCombined

Kasih 1 feedback/refleksi singkat (max 18 kata) yang kerasa "kena" di hati tapi tetep santai. 
Gambarkan "vibe" perasaan user minggu ini.
Langsung jawab refleksinya aja.
''';

    final response = await _postRequest(
      [
        {'role': 'system', 'content': _systemInstructions},
        {'role': 'user', 'content': prompt},
      ],
      temp: AIConfig.temperatureInsight,
      maxTokens: AIConfig.maxTokensInsight,
    );

    return response.isNotEmpty 
        ? response.replaceAll('"', '') 
        : "Minggu ini penuh warna ya! Apapun itu, kamu sudah hebat banget sudah melaluinya. ❤️";
  }

  void resetChat() {
    _history.clear();
    _history.add({'role': 'system', 'content': _systemInstructions});
  }
}

