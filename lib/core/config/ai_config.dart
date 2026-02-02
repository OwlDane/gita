class AIConfig {
  static const String modelChat = 'deepseek/deepseek-chat';
  static const String baseUrl = 'https://openrouter.ai/api/v1/chat/completions';
  
  // Parameters for better response quality
  static const double temperatureChat = 0.8;
  static const double temperatureInsight = 0.6; // More focused for quotes/reflections
  static const int maxTokensChat = 500;
  static const int maxTokensInsight = 100;
}
