#!/usr/bin/env python3
"""Script para converter providers restantes para Riverpod puro."""
import re
from pathlib import Path

# Features a converter
FEATURES = [
    ("emergency_reserve", "EmergencyReserve"),
    ("net_salary", "NetSalary"),
    ("overtime", "Overtime"),
    ("thirteenth_salary", "ThirteenthSalary"),
    ("unemployment_insurance", "UnemploymentInsurance"),
]

BASE_PATH = Path("lib/features")

for feature_name, class_prefix in FEATURES:
    provider_file = BASE_PATH / f"{feature_name}_calculator/presentation/providers/{feature_name}_calculator_provider.dart"

    if not provider_file.exists():
        print(f"Arquivo não encontrado: {provider_file}")
        continue

    content = provider_file.read_text()

    # Remover import injection
    content = re.sub(r"import 'package:app_calculei/core/di/injection\.dart';?\n?", "", content)
    content = re.sub(r"import.*injection.*\n", "", content)

    # Adicionar imports necessários
    imports_section = f"""import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/providers/core_providers.dart';
import '../../data/datasources/{feature_name}_local_datasource.dart';
import '../../data/repositories/{feature_name}_repository_impl.dart';"""

    # Substituir imports
    content = re.sub(
        r"import 'package:riverpod_annotation/riverpod_annotation\.dart';",
        imports_section,
        content
    )

    # Adicionar imports do domain
    if f"import '../../domain/repositories/{feature_name}_repository.dart';" not in content:
        imports_section_end = content.find("part ")
        content = content[:imports_section_end] + f"import '../../domain/repositories/{feature_name}_repository.dart';\n" + content[imports_section_end:]

    # Remover getIt<> calls e substituir por providers

    # 1. Datasource provider
    datasource_provider = f"""
// ========== DATA LAYER PROVIDERS ==========

/// Provider for {class_prefix}LocalDataSource
@riverpod
{class_prefix}LocalDataSource {feature_name.lower().replace('_', '')}LocalDataSource(
  {class_prefix}LocalDataSourceRef ref,
) {{
  final sharedPrefs = ref.watch(sharedPreferencesProvider).requireValue;
  return {class_prefix}LocalDataSourceImpl(sharedPrefs);
}}

/// Provider for {class_prefix}Repository
@riverpod
{class_prefix}Repository {feature_name.lower().replace('_', '')}Repository(
  {class_prefix}RepositoryRef ref,
) {{
  final localDataSource = ref.watch({feature_name.lower().replace('_', '')}LocalDataSourceProvider);
  return {class_prefix}RepositoryImpl(localDataSource);
}}

"""

    # Substituir getIt<> por providers
    content = re.sub(
        r"return getIt<Calculate.*UseCase>\(\);",
        lambda m: "return Calculate" + m.group(0).split("Calculate")[1].split(">")[0] + "();",
        content
    )

    content = re.sub(
        r"return getIt<Save.*UseCase>\(\);",
        lambda m: f"  final repository = ref.watch({feature_name.lower().replace('_', '')}RepositoryProvider);\n  return Save" + m.group(0).split("Save")[1].split(">")[0] + "(repository);",
        content
    )

    content = re.sub(
        r"return getIt<Get.*UseCase>\(\);",
        lambda m: f"  final repository = ref.watch({feature_name.lower().replace('_', '')}RepositoryProvider);\n  return Get" + m.group(0).split("Get")[1].split(">")[0] + "(repository);",
        content
    )

    # Inserir data layer providers antes de USE CASE PROVIDERS
    if "// ========== USE CASE PROVIDERS ==========" in content:
        content = content.replace(
            "// ========== USE CASE PROVIDERS ==========",
            datasource_provider + "// ========== USE CASE PROVIDERS =========="
        )

    provider_file.write_text(content)
    print(f"✅ Converted: {feature_name}_calculator")

print("\n🎉 All providers converted!")
