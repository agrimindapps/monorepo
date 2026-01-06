// Arquivo de exportação condicional para AdSense
// Usa importação condicional para selecionar a implementação correta
// baseado na plataforma (web vs mobile)
//
// Em plataformas mobile (dart.library.io), usa AdSenseStubService
// Em web (dart.library.js_interop), usa AdSenseWebService

export '../../../../domain/entities/ads/ad_sense_config_entity.dart';
// Re-exporta o repositório e entidades para conveniência
export '../../../../domain/repositories/i_web_ads_repository.dart';
export 'adsense_stub_service.dart'
    if (dart.library.js_interop) 'adsense_web_service.dart';
