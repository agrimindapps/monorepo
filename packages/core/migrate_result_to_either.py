#!/usr/bin/env python3
"""
Migrates Result<T> to Either<Failure, T> in DriftRepositoryBase
"""
import re

# Read the file
with open('lib/src/infrastructure/storage/drift/repositories/drift_repository_base.dart', 'r') as f:
    content = f.read()

# Update imports
content = re.sub(
    r"import '../../../../shared/utils/app_error\.dart';",
    "import 'package:dartz/dartz.dart';",
    content
)

content = re.sub(
    r"import '../../../../shared/utils/result\.dart';",
    "import '../../../../shared/utils/failure.dart';",
    content
)

# Replace Result<T> with Either<Failure, T> in type signatures
content = re.sub(
    r'Future<Result<([^>]+)>>',
    r'Future<Either<Failure, \1>>',
    content
)

# Replace Result.success with Right
content = re.sub(
    r'return Result\.success\(([^)]+)\);',
    r'return Right(\1);',
    content
)

# Replace Result.error with Left and convert AppError to Failure
# This is more complex - we need to handle the AppErrorFactory.fromException calls
def convert_error_to_failure(match):
    """Convert Result.error(AppErrorFactory.fromException(...)) to Left(ServerFailure(...))"""
    error_content = match.group(1)
    
    # Extract the exception message
    # Look for DriftTableException or similar
    exception_match = re.search(r"DriftTableException\(\s*'([^']+)'", error_content)
    if exception_match:
        message = exception_match.group(1)
        return f"return Left(ServerFailure('{message}: $e'));"
    else:
        # Fallback
        return f"return Left(ServerFailure('Operation failed: $e'));"

content = re.sub(
    r'return Result\.error\((.*?)\);',
    convert_error_to_failure,
    content,
    flags=re.DOTALL
)

# Write back
with open('lib/src/infrastructure/storage/drift/repositories/drift_repository_base.dart', 'w') as f:
    f.write(content)

print("✅ Migration completed!")
print("- Replaced Result<T> with Either<Failure, T>")
print("- Replaced Result.success() with Right()")
print("- Replaced Result.error() with Left(ServerFailure())")
