/// Device Management Feature for PetiVeti
/// 
/// Gerenciamento de dispositivos conectados à conta do usuário.
/// Utiliza a implementação base do core package com customizações específicas.
/// 
/// Funcionalidades:
/// - Limite de 3 dispositivos mobile por conta (Web ilimitado)
/// - Visualização de dispositivos conectados
/// - Revogação de dispositivos
/// - Validação de novos dispositivos
library;

// Data Layer
export 'data/models/device_model.dart';

// Presentation Layer - Providers
export 'presentation/providers/device_management_notifier.dart';
export 'presentation/providers/device_management_providers.dart';
