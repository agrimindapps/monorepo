#!/usr/bin/env python3
import re

# Read the interface file
with open('lib/src/infrastructure/storage/drift/interfaces/i_drift_repository.dart', 'r') as f:
    content = f.read()

# Update imports - check if Result is imported
if "import '../../../../shared/utils/result.dart';" in content:
    content = content.replace(
        "import '../../../../shared/utils/result.dart';",
        "import 'package:dartz/dartz.dart';\nimport '../../../../shared/utils/failure.dart';"
    )
elif "result.dart" in content:
    # Try other import patterns
    content = re.sub(
        r"import.*result\.dart.*;",
        "import 'package:dartz/dartz.dart';\nimport '../../../../shared/utils/failure.dart';",
        content
    )

# Replace Result<T> with Either<Failure, T>
content = re.sub(
    r'Future<Result<([^>]+)>>',
    r'Future<Either<Failure, \1>>',
    content
)

# Write back
with open('lib/src/infrastructure/storage/drift/interfaces/i_drift_repository.dart', 'w') as f:
    f.write(content)

print("✅ Interface migrated!")
