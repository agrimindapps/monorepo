// MÓDULO: Detalhes de Diagnóstico
// ARQUIVO: Interface TTS Service
// DESCRIÇÃO: Contrato para serviços de Text-to-Speech
// RESPONSABILIDADES: Definir contratos para TTS (falar, parar, status)
// DEPENDÊNCIAS: Nenhuma (interface pura)
// CRIADO: 2025-06-22 | ATUALIZADO: 2025-06-22
// AUTOR: Sistema de Desenvolvimento ReceituAgro

/// Interface para serviços de Text-to-Speech
abstract class ITtsService {
  /// Fala o texto fornecido
  Future<void> speak(String text);

  /// Para a reprodução de áudio
  Future<void> stop();

  /// Verifica se está falando atualmente
  bool get isSpeaking;

  /// Dispõe dos recursos
  Future<void> dispose();
}
