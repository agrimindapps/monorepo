import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';

const db = admin.firestore();

interface DeviceData {
  deviceId: string;
  deviceName: string;
  platform: string;
  model: string;
  appVersion: string;
  firstLoginAt: admin.firestore.Timestamp;
  lastActiveAt: admin.firestore.Timestamp;
  isActive: boolean;
}

/**
 * Valida se um dispositivo pode fazer login
 * Limita a 3 dispositivos ativos por usuário
 */
export const validateDevice = functions.https.onCall(async (data, context) => {
  // Verificar autenticação
  if (!context.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'User must be authenticated');
  }

  const { deviceUuid, deviceInfo } = data;
  const userId = context.auth.uid;

  if (!deviceUuid || !deviceInfo) {
    throw new functions.https.HttpsError('invalid-argument', 'Device UUID and info are required');
  }

  try {
    // Executar em transação para evitar race conditions
    const result = await db.runTransaction(async (transaction) => {
      // 1. Verificar se device já existe
      const deviceRef = db.collection('users').doc(userId).collection('devices').doc(deviceUuid);
      const deviceDoc = await transaction.get(deviceRef);

      if (deviceDoc.exists && deviceDoc.data()?.isActive) {
        // Device já registrado e ativo - apenas atualizar lastActiveAt
        transaction.update(deviceRef, {
          lastActiveAt: admin.firestore.FieldValue.serverTimestamp(),
          appVersion: deviceInfo.appVersion || '1.0.0'
        });
        return { success: true, message: 'Device already registered' };
      }

      // 2. Verificar limite de dispositivos ativos
      const activeDevicesSnapshot = await transaction.get(
        db.collection('users').doc(userId).collection('devices')
          .where('isActive', '==', true)
      );

      const maxDevices = 3;
      if (activeDevicesSnapshot.size >= maxDevices && !deviceDoc.exists) {
        // Retornar lista de dispositivos ativos para o usuário escolher qual remover
        const activeDevices = activeDevicesSnapshot.docs.map(doc => ({
          deviceId: doc.id,
          ...doc.data()
        }));

        return {
          success: false,
          error: 'DEVICE_LIMIT_EXCEEDED',
          message: `Limite de ${maxDevices} dispositivos atingido`,
          activeDevices
        };
      }

      // 3. Registrar ou reativar dispositivo
      const deviceData: DeviceData = {
        deviceId: deviceUuid,
        deviceName: deviceInfo.name || 'Unknown Device',
        platform: deviceInfo.platform || 'unknown',
        model: deviceInfo.model || 'Unknown Model',
        appVersion: deviceInfo.appVersion || '1.0.0',
        firstLoginAt: deviceDoc.exists ? 
          deviceDoc.data()?.firstLoginAt : 
          admin.firestore.FieldValue.serverTimestamp() as admin.firestore.Timestamp,
        lastActiveAt: admin.firestore.FieldValue.serverTimestamp() as admin.firestore.Timestamp,
        isActive: true,
      };

      transaction.set(deviceRef, deviceData, { merge: true });

      // 4. Atualizar array de dispositivos ativos no usuário
      const userRef = db.collection('users').doc(userId);
      transaction.update(userRef, {
        activeDevices: admin.firestore.FieldValue.arrayUnion(deviceUuid),
        lastActive: admin.firestore.FieldValue.serverTimestamp(),
      });

      return { success: true, message: 'Device registered successfully' };
    });

    return result;
  } catch (error) {
    console.error('Error validating device:', error);
    throw new functions.https.HttpsError('internal', 'Failed to validate device');
  }
});

/**
 * Revoga acesso de um dispositivo específico
 */
export const revokeDevice = functions.https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'User must be authenticated');
  }

  const { deviceUuid } = data;
  const userId = context.auth.uid;

  if (!deviceUuid) {
    throw new functions.https.HttpsError('invalid-argument', 'Device UUID is required');
  }

  try {
    await db.runTransaction(async (transaction) => {
      // 1. Marcar device como inativo
      const deviceRef = db.collection('users').doc(userId).collection('devices').doc(deviceUuid);
      transaction.update(deviceRef, {
        isActive: false,
        revokedAt: admin.firestore.FieldValue.serverTimestamp(),
      });

      // 2. Remover do array de dispositivos ativos
      const userRef = db.collection('users').doc(userId);
      transaction.update(userRef, {
        activeDevices: admin.firestore.FieldValue.arrayRemove(deviceUuid),
      });
    });

    return { success: true, message: 'Device revoked successfully' };
  } catch (error) {
    console.error('Error revoking device:', error);
    throw new functions.https.HttpsError('internal', 'Failed to revoke device');
  }
});

/**
 * Limpa sessões antigas e dispositivos inativos
 * Executado diariamente via cron
 */
export const cleanupOldSessions = functions.pubsub.schedule('0 2 * * *').onRun(async (context) => {
  const batch = db.batch();
  let operationsCount = 0;

  try {
    // Data limite: 30 dias atrás
    const thirtyDaysAgo = admin.firestore.Timestamp.fromDate(
      new Date(Date.now() - 30 * 24 * 60 * 60 * 1000)
    );

    // Buscar dispositivos inativos há mais de 30 dias
    const usersSnapshot = await db.collection('users').get();

    for (const userDoc of usersSnapshot.docs) {
      const devicesSnapshot = await userDoc.ref.collection('devices')
        .where('isActive', '==', false)
        .where('lastActiveAt', '<', thirtyDaysAgo)
        .get();

      devicesSnapshot.docs.forEach(deviceDoc => {
        if (operationsCount < 500) { // Firestore batch limit
          batch.delete(deviceDoc.ref);
          operationsCount++;
        }
      });
    }

    if (operationsCount > 0) {
      await batch.commit();
      console.log(`Cleaned up ${operationsCount} old device sessions`);
    }

    return { success: true, cleanedDevices: operationsCount };
  } catch (error) {
    console.error('Error cleaning up old sessions:', error);
    throw error;
  }
});

export const deviceManagement = {
  validateDevice,
  revokeDevice,
  cleanupOldSessions,
};