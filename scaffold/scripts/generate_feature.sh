#!/bin/bash

# Feature Generator Script
# Creates a complete feature structure following Clean Architecture
# Usage: ./generate_feature.sh <feature_name>

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Validate arguments
if [ $# -ne 1 ]; then
    print_error "Invalid number of arguments"
    echo "Usage: $0 <feature_name>"
    echo "Example: $0 users"
    exit 1
fi

FEATURE_NAME=$1

# Validate feature_name (should be snake_case, plural)
if [[ ! $FEATURE_NAME =~ ^[a-z][a-z0-9_]*$ ]]; then
    print_error "Feature name must be lowercase snake_case (e.g., users)"
    exit 1
fi

# Convert to different cases
FEATURE_NAME_SINGULAR="${FEATURE_NAME%s}" # Simple pluralization removal
FEATURE_NAME_PASCAL=$(echo "$FEATURE_NAME_SINGULAR" | sed -r 's/(^|_)([a-z])/\U\2/g')
FEATURE_NAME_PASCAL_PLURAL=$(echo "$FEATURE_NAME" | sed -r 's/(^|_)([a-z])/\U\2/g')

print_info "Generating feature: $FEATURE_NAME"
print_info "Entity name: $FEATURE_NAME_PASCAL"

# Create directory structure
FEATURE_DIR="lib/features/$FEATURE_NAME"

if [ -d "$FEATURE_DIR" ]; then
    print_error "Feature $FEATURE_NAME already exists!"
    exit 1
fi

print_info "Creating directory structure..."

mkdir -p "$FEATURE_DIR"/{data/{datasources/{local,remote},models,repositories},domain/{entities,repositories,services,usecases},presentation/{notifiers,pages,providers,widgets}}
mkdir -p "test/features/$FEATURE_NAME/domain/usecases"

print_success "Directory structure created"

# Generate entity file
print_info "Generating domain layer files..."

cat > "$FEATURE_DIR/domain/entities/${FEATURE_NAME_SINGULAR}_entity.dart" << EOF
import 'package:core/core.dart';
import 'package:equatable/equatable.dart';

/// ${FEATURE_NAME_PASCAL} entity
/// Represents a ${FEATURE_NAME_SINGULAR} in the domain layer
class ${FEATURE_NAME_PASCAL} extends BaseSyncEntity with EquatableMixin {
  const ${FEATURE_NAME_PASCAL}({
    required super.id,
    required this.name,
    super.createdAt,
    super.updatedAt,
    super.isDirty = false,
    super.userId,
    super.moduleName = '{{APP_NAME}}',
  });

  final String name;
  // TODO: Add your entity properties here

  @override
  List<Object?> get props => [
        id,
        name,
        createdAt,
        updatedAt,
        isDirty,
        userId,
        moduleName,
        // TODO: Add your properties to props list
      ];

  ${FEATURE_NAME_PASCAL} copyWith({
    String? id,
    String? name,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isDirty,
    String? userId,
    String? moduleName,
    // TODO: Add your properties to copyWith
  }) {
    return ${FEATURE_NAME_PASCAL}(
      id: id ?? this.id,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isDirty: isDirty ?? this.isDirty,
      userId: userId ?? this.userId,
      moduleName: moduleName ?? this.moduleName,
      // TODO: Add your properties to copyWith implementation
    );
  }

  @override
  Map<String, dynamic> toFirebaseMap() {
    return {
      'id': id,
      'name': name,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'isDirty': isDirty,
      'userId': userId,
      'moduleName': moduleName,
      // TODO: Add your properties to Firebase map
    };
  }

  factory ${FEATURE_NAME_PASCAL}.fromFirebaseMap(Map<String, dynamic> map) {
    return ${FEATURE_NAME_PASCAL}(
      id: map['id'] as String,
      name: map['name'] as String,
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'] as String)
          : null,
      updatedAt: map['updatedAt'] != null
          ? DateTime.parse(map['updatedAt'] as String)
          : null,
      isDirty: map['isDirty'] as bool? ?? false,
      userId: map['userId'] as String?,
      moduleName: map['moduleName'] as String? ?? '{{APP_NAME}}',
      // TODO: Add your properties from Firebase map
    );
  }
}
EOF

# Generate repository interface
cat > "$FEATURE_DIR/domain/repositories/${FEATURE_NAME}_repository.dart" << EOF
import 'package:dartz/dartz.dart';
import 'package:core/core.dart';
import '../entities/${FEATURE_NAME_SINGULAR}_entity.dart';

/// Repository interface for ${FEATURE_NAME}
/// Defines the contract for ${FEATURE_NAME_SINGULAR} data operations
abstract class ${FEATURE_NAME_PASCAL_PLURAL}Repository {
  /// Get all ${FEATURE_NAME}
  Future<Either<Failure, List<${FEATURE_NAME_PASCAL}>>> get${FEATURE_NAME_PASCAL_PLURAL}();

  /// Get ${FEATURE_NAME_SINGULAR} by ID
  Future<Either<Failure, ${FEATURE_NAME_PASCAL}>> get${FEATURE_NAME_PASCAL}ById(String id);

  /// Add new ${FEATURE_NAME_SINGULAR}
  Future<Either<Failure, ${FEATURE_NAME_PASCAL}>> add${FEATURE_NAME_PASCAL}(${FEATURE_NAME_PASCAL} ${FEATURE_NAME_SINGULAR});

  /// Update existing ${FEATURE_NAME_SINGULAR}
  Future<Either<Failure, ${FEATURE_NAME_PASCAL}>> update${FEATURE_NAME_PASCAL}(${FEATURE_NAME_PASCAL} ${FEATURE_NAME_SINGULAR});

  /// Delete ${FEATURE_NAME_SINGULAR}
  Future<Either<Failure, void>> delete${FEATURE_NAME_PASCAL}(String id);
}
EOF

# Generate CRUD service
cat > "$FEATURE_DIR/domain/services/${FEATURE_NAME}_crud_service.dart" << EOF
import 'package:injectable/injectable.dart';
import 'package:dartz/dartz.dart';
import 'package:core/core.dart';
import '../entities/${FEATURE_NAME_SINGULAR}_entity.dart';
import '../repositories/${FEATURE_NAME}_repository.dart';

/// CRUD operations service for ${FEATURE_NAME}
/// Single Responsibility: Only handles CRUD operations
@injectable
class ${FEATURE_NAME_PASCAL_PLURAL}CrudService {
  const ${FEATURE_NAME_PASCAL_PLURAL}CrudService(this._repository);

  final ${FEATURE_NAME_PASCAL_PLURAL}Repository _repository;

  Future<Either<Failure, List<${FEATURE_NAME_PASCAL}>>> getAll() async {
    return _repository.get${FEATURE_NAME_PASCAL_PLURAL}();
  }

  Future<Either<Failure, ${FEATURE_NAME_PASCAL}>> getById(String id) async {
    return _repository.get${FEATURE_NAME_PASCAL}ById(id);
  }

  Future<Either<Failure, ${FEATURE_NAME_PASCAL}>> add(${FEATURE_NAME_PASCAL} ${FEATURE_NAME_SINGULAR}) async {
    return _repository.add${FEATURE_NAME_PASCAL}(${FEATURE_NAME_SINGULAR});
  }

  Future<Either<Failure, ${FEATURE_NAME_PASCAL}>> update(${FEATURE_NAME_PASCAL} ${FEATURE_NAME_SINGULAR}) async {
    return _repository.update${FEATURE_NAME_PASCAL}(${FEATURE_NAME_SINGULAR});
  }

  Future<Either<Failure, void>> delete(String id) async {
    return _repository.delete${FEATURE_NAME_PASCAL}(id);
  }
}
EOF

print_success "Domain layer files created"

print_success "Feature $FEATURE_NAME generated successfully!"
echo ""
print_info "Next steps:"
echo "  1. Implement data layer (models, datasources, repository impl)"
echo "  2. Create use cases in domain/usecases/"
echo "  3. Implement presentation layer (notifiers, pages, widgets)"
echo "  4. Write tests in test/features/$FEATURE_NAME/"
echo ""
print_info "Example feature structure available in lib/features/example/"
