import 'package:drift/drift.dart';

import '../../core/data/models/comentario_model.dart';
import '../plantis_database.dart' as db;

/// Repository Drift para Comments (comentários sobre plantas)
class CommentsDriftRepository {
  final db.PlantisDatabase _db;

  CommentsDriftRepository(this._db);

  Future<int> insertComment(ComentarioModel model) async {
    final localPlantId = await _resolvePlantId(model.plantId);

    final companion = db.CommentsCompanion.insert(
      firebaseId: Value(model.id),
      plantId: Value(localPlantId),
      conteudo: model.conteudo,
      createdAt: Value(model.createdAt ?? DateTime.now()),
      updatedAt: Value(model.updatedAt ?? DateTime.now()),
      lastSyncAt: Value(model.lastSyncAt),
      isDirty: Value(model.isDirty),
      isDeleted: Value(model.isDeleted),
      version: Value(model.version),
      userId: Value(model.userId),
      moduleName: Value(model.moduleName ?? 'plantis'),
    );

    return await _db.into(_db.comments).insert(companion);
  }

  Future<List<ComentarioModel>> getCommentsByPlant(
    String plantFirebaseId,
  ) async {
    final localPlantId = await _resolvePlantId(plantFirebaseId);
    if (localPlantId == null) return [];

    final comments = await (_db.select(_db.comments)
          ..where(
            (c) => c.plantId.equals(localPlantId) & c.isDeleted.equals(false),
          )
          ..orderBy([
            (c) => OrderingTerm.desc(c.createdAt),
          ]))
        .get();

    return comments.map(_commentDriftToModel).toList();
  }

  Stream<List<ComentarioModel>> watchCommentsByPlant(String plantFirebaseId) {
    return Stream.fromFuture(_resolvePlantId(plantFirebaseId)).asyncExpand((
      localPlantId,
    ) {
      if (localPlantId == null) return Stream.value(<ComentarioModel>[]);

      return (_db.select(_db.comments)
            ..where(
              (c) => c.plantId.equals(localPlantId) & c.isDeleted.equals(false),
            )
            ..orderBy([
              (c) => OrderingTerm.desc(c.createdAt),
            ]))
          .watch()
          .map((comments) => comments.map(_commentDriftToModel).toList());
    });
  }

  ComentarioModel _commentDriftToModel(db.Comment comment) {
    return ComentarioModel(
      id: comment.firebaseId ?? comment.id.toString(),
      plantId: comment.plantId?.toString(),
      conteudo: comment.conteudo,
      createdAtMs: comment.createdAt?.millisecondsSinceEpoch,
      updatedAtMs: comment.updatedAt?.millisecondsSinceEpoch,
      lastSyncAtMs: comment.lastSyncAt?.millisecondsSinceEpoch,
      isDirty: comment.isDirty,
      isDeleted: comment.isDeleted,
      version: comment.version,
      userId: comment.userId,
      moduleName: comment.moduleName,
    );
  }

  Future<int?> _resolvePlantId(String? plantFirebaseId) async {
    if (plantFirebaseId == null) return null;
    final asInt = int.tryParse(plantFirebaseId);
    if (asInt != null) return asInt;

    final plant = await (_db.select(
      _db.plants,
    )..where((p) => p.firebaseId.equals(plantFirebaseId)))
        .getSingleOrNull();
    return plant?.id;
  }
}
