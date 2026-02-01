import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:gita/core/config/secrets.dart';

class ChatRepository {
  final List<Map<String, String>> _history = [];
  final String _model = 'tngtech/deepseek-r1t2-chimera:free';
  final String _baseUrl = 'https://openrouter.ai/api/v1/chat/completions';

  final String _systemInstructions = '''
Kamu adalah Gita, teman curhat yang sangat pengertian, santai, dan asik. 
Gaya bahasamu sangat natural seperti manusia (best friend), bukan robot. 
Gunakan bahasa Indonesia yang kasual, hangat, dan akrab (seperti 'aku', 'kamu', 'ya', 'sih', 'dong', 'banget', 'oke'). 

Aturan Utama:
1. Jangan memberikan jawaban yang terlalu kaku atau berformat list panjang jika tidak diperlukan. 
2. Berikan empati yang tulus, dengarkan curhatan user, dan berikan saran yang suportif seperti ngobrol sama sahabat.
3. Singkat tapi bermakna lebih baik daripada panjang tapi membosankan.
4. Gunakan sedikit emoji untuk mempermanis percakapan.
5. Selalu panggil user dengan sebutan ramah atau 'kamu'.
''';

  ChatRepository() {
    resetChat();
  }

  Future<String> sendMessage(String message) async {
    _history.add({'role': 'user', 'content': message});

    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Authorization': 'Bearer ${Secrets.openRouterKey}',
          'Content-Type': 'application/json',
          'HTTP-Referer': 'https://github.com/zidnae/gita', // Optional
        },
        body: jsonEncode({
          'model': _model,
          'messages': _history,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final content = data['choices'][0]['message']['content'] as String;
        
        // Remove reasoning if present (R1 models often include <think> tags)
        final cleanContent = content.replaceAll(RegExp(r'<think>[\s\S]*?</think>'), '').trim();
        
        _history.add({'role': 'assistant', 'content': cleanContent});
        return cleanContent;
      } else {
        debugPrint('OpenRouter Error: ${response.statusCode} - ${response.body}');
        return 'Gita lagi agak linglung nih, kayaknya sinyalnya kurang oke. Coba lagi bentar ya? 🙏';
      }
    } catch (e) {
      debugPrint('Chat Error: $e');
      return 'Duh, kayaknya ada yang salah. Coba tanya lagi ya? 🥺';
    }
  }

  void resetChat() {
    _history.clear();
    _history.add({'role': 'system', 'content': _systemInstructions});
  }
}
