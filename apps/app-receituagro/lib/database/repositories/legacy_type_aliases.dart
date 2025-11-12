/// ARQUIVO TEMPORÁRIO - Compatibility Layer para migração Hive → Drift
///
/// Este arquivo fornece type aliases para que código antigo continue funcionando
/// durante a migração. Será removido após a migração completa.
///
/// **USO**: Imports que usavam "DiagnosticoLegacyRepository" agora podem usar
/// este arquivo para obter o Drift repository com o nome antigo.

// ignore_for_file: camel_case_types

import 'diagnostico_repository.dart';
import 'comentario_repository.dart';
import 'fitossanitarios_repository.dart';
import 'pragas_repository.dart';
import 'favorito_repository.dart';
import 'pragas_inf_repository.dart';
import 'plantas_inf_repository.dart';

/// @deprecated Use DiagnosticoRepository (Drift) instead
typedef DiagnosticoLegacyRepository = DiagnosticoRepository;

/// @deprecated Use ComentarioRepository (Drift) instead
typedef ComentariosLegacyRepository = ComentarioRepository;

/// @deprecated Use FitossanitariosRepository (Drift) instead
typedef FitossanitarioLegacyRepository = FitossanitariosRepository;

/// @deprecated Use PragasRepository (Drift) instead
typedef PragasLegacyRepository = PragasRepository;

/// @deprecated Use FavoritoRepository (Drift) instead
typedef FavoritosLegacyRepository = FavoritoRepository;

/// @deprecated Use PragasInfRepository (Drift) instead
typedef PragasInfLegacyRepository = PragasInfRepository;

/// @deprecated Use PlantasInfRepository (Drift) instead
typedef PlantasInfLegacyRepository = PlantasInfRepository;
