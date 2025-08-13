/// Barrel file for all domain events
/// 
/// Exports all domain events from the sistema de plantas
/// for easy importing throughout the application
library;

// Base event classes
export 'domain_event.dart';

// Specific domain events
export 'domain_event.dart' show 
  // Espaço Events
  EspacoEvent,
  EspacoCriado,
  EspacoAtualizado, 
  EspacoRemovido,
  EspacoStatusAlterado,
  
  // Planta Events
  PlantaEvent,
  PlantaCriada,
  PlantaAtualizada,
  PlantaRemovida,
  PlantaMovida,
  
  // Tarefa Events  
  TarefaEvent,
  TarefaCriada,
  TarefaConcluida,
  TarefaRemovida,
  
  // Configuração Events
  PlantaConfigEvent,
  PlantaConfigCriada,
  TipoCuidadoAlterado,
  PlantaConfigRemovida;