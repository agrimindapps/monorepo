/**
 * Cloud Functions para app-plantis
 *
 * Funções implementadas:
 * 1. cleanOrphanImages - Limpa imagens órfãs do Storage (GAP-003)
 * 2. validateImageUpload - Valida uploads server-side (GAP-006)
 * 3. rateLimitUploads - Rate limiting de uploads
 */

import * as functions from "firebase-functions";
import * as admin from "firebase-admin";

// Inicializar Firebase Admin
admin.initializeApp();

const db = admin.firestore();
const storage = admin.storage();

/**
 * GAP-003: Limpar imagens órfãs do Storage
 *
 * Executa diariamente às 2h AM (horário de menor uso)
 * Deleta imagens que não estão associadas a nenhuma planta
 *
 * Critérios para considerar órfã:
 * - Imagem existe no Storage na pasta plants/
 * - URL da imagem NÃO existe em nenhum documento de planta
 * - Imagem tem mais de 7 dias (evitar deletar uploads em progresso)
 */
export const cleanOrphanImages = functions
  .runWith({
    timeoutSeconds: 540, // 9 minutos
    memory: "512MB",
  })
  .pubsub
  .schedule("0 2 * * *") // Diariamente às 2h AM
  .timeZone("America/Sao_Paulo")
  .onRun(async (context) => {
    const deletionLog: {
      deleted: string[];
      errors: string[];
      skipped: string[];
    } = {
      deleted: [],
      errors: [],
      skipped: [],
    };

    try {
      console.log("🧹 Iniciando limpeza de imagens órfãs...");

      const bucket = storage.bucket();

      // 1. Listar todas as imagens na pasta plants/
      const [files] = await bucket.getFiles({prefix: "plants/"});

      console.log(`📦 Encontradas ${files.length} imagens no Storage`);

      // 2. Para cada imagem, verificar se está em uso
      for (const file of files) {
        try {
          // Ignorar pastas
          if (file.name.endsWith("/")) {
            continue;
          }

          // Verificar idade da imagem (7 dias)
          const [metadata] = await file.getMetadata();
          const createdAt = new Date(metadata.timeCreated);
          const ageInDays = (Date.now() - createdAt.getTime()) / (1000 * 60 * 60 * 24);

          if (ageInDays < 7) {
            console.log(`⏭️  Skipping recent image: ${file.name} (${ageInDays.toFixed(1)} days old)`);
            deletionLog.skipped.push(file.name);
            continue;
          }

          // Obter URL pública
          const [url] = await file.getDownloadURL();

          // 3. Buscar em todas as coleções de plantas de todos os usuários
          let isInUse = false;

          // Query em collection group (busca em todas as subcoleções 'plants')
          const plantsQuery = await db
            .collectionGroup("plants")
            .where("imageUrls", "array-contains", url)
            .limit(1)
            .get();

          if (!plantsQuery.empty) {
            isInUse = true;
          }

          // 4. Se não está em uso, deletar
          if (!isInUse) {
            await file.delete();
            console.log(`✅ Deleted orphan image: ${file.name}`);
            deletionLog.deleted.push(file.name);
          }
        } catch (error) {
          const errorMsg = error instanceof Error ? error.message : String(error);
          console.error(`❌ Error processing ${file.name}:`, errorMsg);
          deletionLog.errors.push(`${file.name}: ${errorMsg}`);
        }
      }

      // Log final
      console.log("🎉 Limpeza concluída!");
      console.log(`✅ Deletadas: ${deletionLog.deleted.length}`);
      console.log(`⏭️  Ignoradas (recentes): ${deletionLog.skipped.length}`);
      console.log(`❌ Erros: ${deletionLog.errors.length}`);

      // Salvar log no Firestore para auditoria
      await db.collection("system_logs").add({
        type: "image_cleanup",
        timestamp: admin.firestore.FieldValue.serverTimestamp(),
        summary: {
          totalProcessed: files.length,
          deleted: deletionLog.deleted.length,
          skipped: deletionLog.skipped.length,
          errors: deletionLog.errors.length,
        },
        details: deletionLog,
      });

      return {success: true, ...deletionLog};
    } catch (error) {
      console.error("💥 Erro crítico na limpeza:", error);

      // Log de erro
      await db.collection("system_logs").add({
        type: "image_cleanup_error",
        timestamp: admin.firestore.FieldValue.serverTimestamp(),
        error: error instanceof Error ? error.message : String(error),
      });

      throw error;
    }
  });

/**
 * GAP-006: Validar upload de imagem server-side
 *
 * Executa após cada upload no Storage
 * Valida:
 * - Content Type (apenas imagens)
 * - Tamanho (máximo 10MB)
 * - Formato (JPEG, PNG, WEBP)
 *
 * Se inválido, deleta o arquivo automaticamente
 */
export const validateImageUpload = functions
  .runWith({
    memory: "256MB",
  })
  .storage
  .object()
  .onFinalize(async (object) => {
    const filePath = object.name;
    const contentType = object.contentType;
    const size = parseInt(object.size || "0");

    // Apenas validar imagens na pasta plants/
    if (!filePath || !filePath.startsWith("plants/")) {
      return null;
    }

    console.log(`🔍 Validando upload: ${filePath}`);

    const validationErrors: string[] = [];

    // 1. Validar Content Type
    const allowedTypes = ["image/jpeg", "image/png", "image/webp"];
    if (!contentType || !allowedTypes.includes(contentType)) {
      validationErrors.push(`Invalid content type: ${contentType}. Allowed: ${allowedTypes.join(", ")}`);
    }

    // 2. Validar tamanho (10MB)
    const maxSizeBytes = 10 * 1024 * 1024;
    if (size > maxSizeBytes) {
      const sizeMB = (size / (1024 * 1024)).toFixed(2);
      validationErrors.push(`File too large: ${sizeMB}MB. Max: 10MB`);
    }

    // 3. Validar extensão do arquivo
    const allowedExtensions = [".jpg", ".jpeg", ".png", ".webp"];
    const fileExtension = filePath.substring(filePath.lastIndexOf(".")).toLowerCase();
    if (!allowedExtensions.includes(fileExtension)) {
      validationErrors.push(`Invalid extension: ${fileExtension}. Allowed: ${allowedExtensions.join(", ")}`);
    }

    // Se tem erros, deletar arquivo
    if (validationErrors.length > 0) {
      console.error(`❌ Validation failed for ${filePath}:`, validationErrors);

      try {
        const bucket = storage.bucket();
        await bucket.file(filePath).delete();
        console.log(`🗑️  Deleted invalid file: ${filePath}`);

        // Log de segurança
        await db.collection("security_logs").add({
          type: "invalid_upload_blocked",
          timestamp: admin.firestore.FieldValue.serverTimestamp(),
          filePath,
          contentType,
          size,
          errors: validationErrors,
        });
      } catch (error) {
        console.error(`Failed to delete invalid file ${filePath}:`, error);
      }

      throw new functions.https.HttpsError(
        "invalid-argument",
        `Upload validation failed: ${validationErrors.join("; ")}`
      );
    }

    console.log(`✅ Upload válido: ${filePath}`);
    return null;
  });

/**
 * Rate limiting de uploads por usuário
 *
 * Limita uploads a 10 imagens por minuto por usuário
 * Previne abuso e controla custos
 */
export const checkUploadRateLimit = functions
  .runWith({
    memory: "128MB",
  })
  .https
  .onCall(async (data, context) => {
    // Verificar autenticação
    if (!context.auth) {
      throw new functions.https.HttpsError(
        "unauthenticated",
        "User must be authenticated"
      );
    }

    const userId = context.auth.uid;
    const now = Date.now();
    const oneMinuteAgo = now - 60000;

    // Buscar uploads recentes do usuário
    const recentUploadsRef = db
      .collection("upload_logs")
      .where("userId", "==", userId)
      .where("timestamp", ">", oneMinuteAgo)
      .orderBy("timestamp", "desc");

    const recentUploads = await recentUploadsRef.get();

    const uploadCount = recentUploads.size;
    const maxUploadsPerMinute = 10;

    if (uploadCount >= maxUploadsPerMinute) {
      console.warn(`⚠️  Rate limit exceeded for user ${userId}: ${uploadCount} uploads`);

      // Log de segurança
      await db.collection("security_logs").add({
        type: "rate_limit_exceeded",
        timestamp: admin.firestore.FieldValue.serverTimestamp(),
        userId,
        uploadCount,
      });

      throw new functions.https.HttpsError(
        "resource-exhausted",
        `Too many uploads. Limit: ${maxUploadsPerMinute} per minute. Please wait.`
      );
    }

    // Registrar tentativa de upload
    await db.collection("upload_logs").add({
      userId,
      timestamp: now,
    });

    console.log(`✅ Rate limit OK for user ${userId}: ${uploadCount + 1}/${maxUploadsPerMinute}`);

    return {
      allowed: true,
      remaining: maxUploadsPerMinute - uploadCount - 1,
    };
  });

/**
 * Função de manutenção: Limpar logs antigos
 *
 * Executa semanalmente aos domingos
 * Remove logs com mais de 30 dias
 */
export const cleanOldLogs = functions
  .runWith({
    timeoutSeconds: 300,
    memory: "256MB",
  })
  .pubsub
  .schedule("0 3 * * 0") // Domingos às 3h AM
  .timeZone("America/Sao_Paulo")
  .onRun(async (context) => {
    const thirtyDaysAgo = Date.now() - (30 * 24 * 60 * 60 * 1000);

    try {
      console.log("🧹 Limpando logs antigos...");

      // Limpar upload_logs
      const uploadLogsQuery = await db
        .collection("upload_logs")
        .where("timestamp", "<", thirtyDaysAgo)
        .limit(500) // Batch de 500
        .get();

      const batch = db.batch();
      uploadLogsQuery.docs.forEach((doc) => {
        batch.delete(doc.ref);
      });

      await batch.commit();

      console.log(`✅ Deleted ${uploadLogsQuery.size} old upload logs`);

      return {success: true, deleted: uploadLogsQuery.size};
    } catch (error) {
      console.error("Error cleaning old logs:", error);
      throw error;
    }
  });
