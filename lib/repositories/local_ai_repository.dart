abstract class LocalAiRepository {
  /// Checa a conectividade com o servidor local do LM Studio
  Future<bool> checkConnection({String host = 'http://127.0.0.1:1234'});

  /// Retorna a lista de modelos instalados e disponíveis no LM Studio
  Future<List<String>> getAvailableModels({String host = 'http://127.0.0.1:1234'});

  /// Envia um prompt síncrono para completude via REST API (padrão OpenAI)
  Future<String> sendPrompt({
    required String prompt,
    String? systemPrompt,
    String? model,
  });

  /// Envia um prompt assíncrono com streaming de tokens em tempo real
  Stream<String> streamPrompt({
    required String prompt,
    String? systemPrompt,
    String? model,
  });
}
