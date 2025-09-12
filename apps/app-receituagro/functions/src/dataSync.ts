import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';

const db = admin.firestore();

interface SyncOperation {
  id: string;
  collection: string;
  operation: 'create' | 'update' | 'delete';
  data?: any;
  timestamp: admin.firestore.Timestamp;
  deviceId: string;
}

interface ConflictResolution {
  strategy: 'last_write_wins' | 'user_guided' | 'merge';
  keepLocal?: boolean;
  keepRemote?: boolean;
  mergeFields?: string[];
}

/**
 * Sincroniza dados do usuário de forma bidirecional
 */
export const syncUserData = functions.https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'User must be authenticated');
  }

  const { operations, deviceId, collections } = data;
  const userId = context.auth.uid;

  if (!deviceId) {
    throw new functions.https.HttpsError('invalid-argument', 'Device ID is required');
  }

  try {
    // 1. Processar operações do cliente para o servidor
    const conflicts: any[] = [];
    if (operations && operations.length > 0) {
      const result = await processClientOperations(userId, deviceId, operations);
      conflicts.push(...result.conflicts);
    }

    // 2. Obter operações do servidor para o cliente
    const serverOperations = await getServerOperations(userId, deviceId, collections);

    // 3. Marcar operações como processadas
    if (serverOperations.length > 0) {
      await markOperationsAsProcessed(userId, deviceId, serverOperations.map(op => op.id));
    }

    return {
      success: true,
      serverOperations,
      conflicts,
      timestamp: admin.firestore.Timestamp.now()
    };
  } catch (error) {
    console.error('Error syncing user data:', error);
    throw new functions.https.HttpsError('internal', 'Failed to sync user data');
  }
});

/**
 * Sincronização em lote para grandes volumes de dados
 */
export const batchSyncUserData = functions.https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'User must be authenticated');
  }

  const { batchOperations, deviceId, lastSyncTimestamp } = data;
  const userId = context.auth.uid;

  try {
    const batch = db.batch();
    const conflicts: any[] = [];
    let processedCount = 0;

    // Processar operações em lotes de 500 (limite do Firestore)
    const batchSize = 500;
    
    for (let i = 0; i < batchOperations.length; i += batchSize) {
      const batchSlice = batchOperations.slice(i, i + batchSize);
      
      const batchResult = await processOperationsBatch(userId, deviceId, batchSlice);
      conflicts.push(...batchResult.conflicts);
      processedCount += batchResult.processed;
    }

    // Obter operações do servidor desde último sync
    const serverOperations = await getServerOperationsSince(userId, deviceId, lastSyncTimestamp);

    return {
      success: true,
      processedCount,
      serverOperations,
      conflicts,
      timestamp: admin.firestore.Timestamp.now()
    };
  } catch (error) {
    console.error('Error in batch sync:', error);
    throw new functions.https.HttpsError('internal', 'Failed to batch sync user data');
  }
});

/**
 * Resolve conflitos de sincronização
 */
export const resolveConflicts = functions.https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'User must be authenticated');
  }

  const { conflictId, resolution } = data;
  const userId = context.auth.uid;

  if (!conflictId || !resolution) {
    throw new functions.https.HttpsError('invalid-argument', 'Conflict ID and resolution are required');
  }

  try {
    // Buscar conflito
    const conflictRef = db.collection('sync_conflicts').doc(conflictId);
    const conflictDoc = await conflictRef.get();

    if (!conflictDoc.exists) {
      throw new functions.https.HttpsError('not-found', 'Conflict not found');
    }

    const conflict = conflictDoc.data();
    
    if (conflict?.userId !== userId) {
      throw new functions.https.HttpsError('permission-denied', 'Access denied');
    }

    // Aplicar resolução
    const result = await applyConflictResolution(conflict, resolution);

    // Marcar conflito como resolvido
    await conflictRef.update({
      status: 'resolved',
      resolution,
      resolvedAt: admin.firestore.FieldValue.serverTimestamp(),
      finalData: result.finalData
    });

    // Propagar mudança para outros dispositivos
    await propagateToOtherDevices(userId, conflict.deviceId, {
      collection: conflict.collection,
      documentId: conflict.documentId,
      data: result.finalData,
      operation: 'update',
      timestamp: admin.firestore.Timestamp.now()
    });

    return {
      success: true,
      finalData: result.finalData,
      message: 'Conflict resolved successfully'
    };
  } catch (error) {
    console.error('Error resolving conflict:', error);
    throw new functions.https.HttpsError('internal', 'Failed to resolve conflict');
  }
});

// Funções auxiliares

/**
 * Processa operações vindas do cliente
 */
async function processClientOperations(userId: string, deviceId: string, operations: SyncOperation[]) {
  const conflicts: any[] = [];
  const batch = db.batch();

  for (const operation of operations) {
    try {
      const collectionRef = db.collection('users').doc(userId).collection(operation.collection);
      const docRef = collectionRef.doc(operation.id);

      switch (operation.operation) {
        case 'create':
          // Verificar se documento já existe (possível conflito)
          const existingDoc = await docRef.get();
          if (existingDoc.exists) {
            // Criar conflito
            const conflictId = await createConflict(userId, deviceId, operation, existingDoc.data());
            conflicts.push({ conflictId, type: 'create_collision', documentId: operation.id });
          } else {
            batch.set(docRef, {
              ...operation.data,
              createdAt: operation.timestamp,
              updatedAt: operation.timestamp,
              deviceId,
              syncVersion: 1
            });
          }
          break;

        case 'update':
          const currentDoc = await docRef.get();
          if (!currentDoc.exists) {
            // Documento não existe - criar
            batch.set(docRef, {
              ...operation.data,
              createdAt: operation.timestamp,
              updatedAt: operation.timestamp,
              deviceId,
              syncVersion: 1
            });
          } else {
            const currentData = currentDoc.data();
            const currentTimestamp = currentData?.updatedAt?.toDate();
            const operationTimestamp = operation.timestamp.toDate();

            // Verificar conflito temporal
            if (currentTimestamp && operationTimestamp < currentTimestamp) {
              // Possível conflito - operação mais antiga que dados atuais
              const conflictId = await createConflict(userId, deviceId, operation, currentData);
              conflicts.push({ conflictId, type: 'update_collision', documentId: operation.id });
            } else {
              // Atualizar normalmente
              batch.update(docRef, {
                ...operation.data,
                updatedAt: operation.timestamp,
                syncVersion: (currentData?.syncVersion || 0) + 1,
                lastModifiedDevice: deviceId
              });
            }
          }
          break;

        case 'delete':
          const docToDelete = await docRef.get();
          if (docToDelete.exists) {
            batch.update(docRef, {
              deletedAt: operation.timestamp,
              isDeleted: true,
              deletedByDevice: deviceId
            });
          }
          break;
      }
    } catch (error) {
      console.error('Error processing operation:', operation.id, error);
    }
  }

  await batch.commit();
  
  // Propagar operações para outros dispositivos
  await propagateToOtherDevices(userId, deviceId, operations);

  return { conflicts };
}

/**
 * Obtém operações do servidor para sincronizar com cliente
 */
async function getServerOperations(userId: string, deviceId: string, collections: string[]) {
  const operations: any[] = [];

  // Buscar na fila de sincronização
  const syncQueueSnapshot = await db.collection('sync_queue')
    .where('userId', '==', userId)
    .where('deviceId', '==', deviceId)
    .where('processed', '==', false)
    .orderBy('created_at', 'asc')
    .limit(100)
    .get();

  syncQueueSnapshot.docs.forEach(doc => {
    operations.push({
      id: doc.id,
      ...doc.data()
    });
  });

  return operations;
}

/**
 * Obtém operações desde um timestamp específico
 */
async function getServerOperationsSince(userId: string, deviceId: string, lastSyncTimestamp: any) {
  const syncTimestamp = lastSyncTimestamp ? 
    admin.firestore.Timestamp.fromDate(new Date(lastSyncTimestamp)) : 
    admin.firestore.Timestamp.fromDate(new Date(0));

  const syncQueueSnapshot = await db.collection('sync_queue')
    .where('userId', '==', userId)
    .where('deviceId', '==', deviceId)
    .where('created_at', '>', syncTimestamp)
    .orderBy('created_at', 'asc')
    .limit(500)
    .get();

  return syncQueueSnapshot.docs.map(doc => ({
    id: doc.id,
    ...doc.data()
  }));
}

/**
 * Processa lote de operações
 */
async function processOperationsBatch(userId: string, deviceId: string, operations: SyncOperation[]) {
  const batch = db.batch();
  const conflicts: any[] = [];
  let processed = 0;

  for (const operation of operations) {
    // Lógica similar ao processClientOperations, mas otimizada para lote
    // ... (implementação simplificada para brevidade)
    processed++;
  }

  await batch.commit();
  return { conflicts, processed };
}

/**
 * Cria registro de conflito
 */
async function createConflict(userId: string, deviceId: string, operation: SyncOperation, existingData: any) {
  const conflictRef = db.collection('sync_conflicts').doc();
  
  await conflictRef.set({
    userId,
    deviceId,
    collection: operation.collection,
    documentId: operation.id,
    conflictType: operation.operation,
    clientData: operation.data,
    serverData: existingData,
    clientTimestamp: operation.timestamp,
    serverTimestamp: existingData.updatedAt || admin.firestore.Timestamp.now(),
    status: 'pending',
    createdAt: admin.firestore.FieldValue.serverTimestamp()
  });

  return conflictRef.id;
}

/**
 * Aplica resolução de conflito
 */
async function applyConflictResolution(conflict: any, resolution: ConflictResolution) {
  let finalData;

  switch (resolution.strategy) {
    case 'last_write_wins':
      // Usar dados mais recentes baseado no timestamp
      finalData = conflict.clientTimestamp.toDate() > conflict.serverTimestamp.toDate() ? 
        conflict.clientData : conflict.serverData;
      break;

    case 'user_guided':
      // Usuário escolheu explicitamente
      finalData = resolution.keepLocal ? conflict.clientData : conflict.serverData;
      break;

    case 'merge':
      // Mergear campos específicos
      finalData = { ...conflict.serverData };
      if (resolution.mergeFields) {
        resolution.mergeFields.forEach(field => {
          if (conflict.clientData[field] !== undefined) {
            finalData[field] = conflict.clientData[field];
          }
        });
      }
      break;

    default:
      finalData = conflict.serverData;
  }

  // Aplicar no documento real
  const docRef = db.collection('users')
    .doc(conflict.userId)
    .collection(conflict.collection)
    .doc(conflict.documentId);

  await docRef.set({
    ...finalData,
    updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    resolvedConflict: true,
    conflictResolution: resolution.strategy
  }, { merge: true });

  return { finalData };
}

/**
 * Propaga operações para outros dispositivos do usuário
 */
async function propagateToOtherDevices(userId: string, originDeviceId: string, operations: any) {
  // Buscar outros dispositivos ativos
  const devicesSnapshot = await db.collection('users')
    .doc(userId)
    .collection('devices')
    .where('isActive', '==', true)
    .get();

  const batch = db.batch();

  devicesSnapshot.docs.forEach(deviceDoc => {
    const targetDeviceId = deviceDoc.id;
    
    // Não enviar de volta para o dispositivo de origem
    if (targetDeviceId === originDeviceId) return;

    // Criar entrada na fila de sincronização
    const syncRef = db.collection('sync_queue').doc();
    
    batch.set(syncRef, {
      userId,
      deviceId: targetDeviceId,
      operations: Array.isArray(operations) ? operations : [operations],
      created_at: admin.firestore.FieldValue.serverTimestamp(),
      processed: false,
      priority: 'normal'
    });
  });

  if (devicesSnapshot.size > 1) { // Mais de um dispositivo (pelo menos o de origem + outros)
    await batch.commit();
  }
}

/**
 * Marca operações como processadas
 */
async function markOperationsAsProcessed(userId: string, deviceId: string, operationIds: string[]) {
  const batch = db.batch();

  operationIds.forEach(operationId => {
    const syncRef = db.collection('sync_queue').doc(operationId);
    batch.update(syncRef, {
      processed: true,
      processedAt: admin.firestore.FieldValue.serverTimestamp()
    });
  });

  await batch.commit();
}

export const dataSync = {
  syncUserData,
  batchSyncUserData,
  resolveConflicts,
};