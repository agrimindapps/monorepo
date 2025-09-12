import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';

const db = admin.firestore();

interface RevenueCatWebhookEvent {
  api_version: string;
  event: {
    type: string;
    id: string;
    event_timestamp_ms: number;
    app_user_id: string;
    aliases?: string[];
    original_app_user_id?: string;
    product_id?: string;
    period_type?: string;
    purchased_at_ms?: number;
    expiration_at_ms?: number;
    environment?: string;
    presented_offering_id?: string;
    transaction_id?: string;
    original_transaction_id?: string;
    is_family_share?: boolean;
    country_code?: string;
    app_id?: string;
    entitlement_id?: string;
    entitlement_ids?: string[];
    store?: string;
    takehome_percentage?: number;
    offer_code?: string;
    tax_percentage?: number;
    currency?: string;
    price?: number;
    price_in_purchased_currency?: number;
    subscriber_attributes?: Record<string, any>;
    cancel_reason?: string;
    new_product_id?: string;
    grace_period_expiration_at_ms?: number;
  };
}

/**
 * Webhook do RevenueCat para sincronizar status de assinatura
 */
export const revenuecatWebhook = functions.https.onRequest(async (req, res) => {
  // Verificar método HTTP
  if (req.method !== 'POST') {
    return res.status(405).send('Method Not Allowed');
  }

  try {
    const webhookEvent: RevenueCatWebhookEvent = req.body;
    const { event } = webhookEvent;

    console.log('RevenueCat webhook received:', {
      type: event.type,
      user_id: event.app_user_id,
      timestamp: event.event_timestamp_ms
    });

    // Processar diferentes tipos de eventos
    switch (event.type) {
      case 'INITIAL_PURCHASE':
        await handleInitialPurchase(event);
        break;
      
      case 'RENEWAL':
        await handleRenewal(event);
        break;
      
      case 'CANCELLATION':
        await handleCancellation(event);
        break;
      
      case 'UNCANCELLATION':
        await handleUncancellation(event);
        break;
      
      case 'NON_RENEWING_PURCHASE':
        await handleNonRenewingPurchase(event);
        break;
      
      case 'EXPIRATION':
        await handleExpiration(event);
        break;
      
      case 'BILLING_ISSUE':
        await handleBillingIssue(event);
        break;
      
      case 'PRODUCT_CHANGE':
        await handleProductChange(event);
        break;
      
      default:
        console.log('Unhandled webhook event type:', event.type);
    }

    // Sempre sincronizar com todos os dispositivos do usuário
    await syncSubscriptionToAllDevices(event.app_user_id);

    res.status(200).send('OK');
  } catch (error) {
    console.error('Error processing RevenueCat webhook:', error);
    res.status(500).send('Internal Server Error');
  }
});

/**
 * Sincroniza status de assinatura manualmente
 */
export const syncSubscriptionStatus = functions.https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'User must be authenticated');
  }

  const userId = context.auth.uid;

  try {
    await syncSubscriptionToAllDevices(userId);
    return { success: true, message: 'Subscription status synced' };
  } catch (error) {
    console.error('Error syncing subscription:', error);
    throw new functions.https.HttpsError('internal', 'Failed to sync subscription');
  }
});

// Handlers para diferentes tipos de eventos RevenueCat

async function handleInitialPurchase(event: any) {
  await updateSubscriptionStatus(event.app_user_id, {
    is_active: true,
    product_id: event.product_id,
    purchased_at: new Date(event.purchased_at_ms),
    expires_at: event.expiration_at_ms ? new Date(event.expiration_at_ms) : null,
    period_type: event.period_type,
    store: event.store,
    environment: event.environment,
    last_updated: admin.firestore.FieldValue.serverTimestamp(),
  });
}

async function handleRenewal(event: any) {
  await updateSubscriptionStatus(event.app_user_id, {
    is_active: true,
    expires_at: event.expiration_at_ms ? new Date(event.expiration_at_ms) : null,
    last_renewal: new Date(event.event_timestamp_ms),
    last_updated: admin.firestore.FieldValue.serverTimestamp(),
  });
}

async function handleCancellation(event: any) {
  await updateSubscriptionStatus(event.app_user_id, {
    will_renew: false,
    cancel_reason: event.cancel_reason,
    cancelled_at: new Date(event.event_timestamp_ms),
    // Nota: is_active continua true até expirar
    last_updated: admin.firestore.FieldValue.serverTimestamp(),
  });
}

async function handleUncancellation(event: any) {
  await updateSubscriptionStatus(event.app_user_id, {
    will_renew: true,
    cancel_reason: null,
    cancelled_at: null,
    last_updated: admin.firestore.FieldValue.serverTimestamp(),
  });
}

async function handleNonRenewingPurchase(event: any) {
  await updateSubscriptionStatus(event.app_user_id, {
    is_active: true,
    product_id: event.product_id,
    purchased_at: new Date(event.purchased_at_ms),
    expires_at: null, // Non-renewing não expira
    period_type: 'non_renewing',
    last_updated: admin.firestore.FieldValue.serverTimestamp(),
  });
}

async function handleExpiration(event: any) {
  await updateSubscriptionStatus(event.app_user_id, {
    is_active: false,
    expired_at: new Date(event.event_timestamp_ms),
    last_updated: admin.firestore.FieldValue.serverTimestamp(),
  });
}

async function handleBillingIssue(event: any) {
  await updateSubscriptionStatus(event.app_user_id, {
    billing_issue: true,
    billing_issue_detected_at: new Date(event.event_timestamp_ms),
    grace_period_expires_at: event.grace_period_expiration_at_ms ? 
      new Date(event.grace_period_expiration_at_ms) : null,
    last_updated: admin.firestore.FieldValue.serverTimestamp(),
  });
}

async function handleProductChange(event: any) {
  await updateSubscriptionStatus(event.app_user_id, {
    product_id: event.new_product_id,
    previous_product_id: event.product_id,
    product_changed_at: new Date(event.event_timestamp_ms),
    last_updated: admin.firestore.FieldValue.serverTimestamp(),
  });
}

/**
 * Atualiza o status de assinatura no Firestore
 */
async function updateSubscriptionStatus(userId: string, updates: any) {
  const userRef = db.collection('users').doc(userId);
  
  await db.runTransaction(async (transaction) => {
    const userDoc = await transaction.get(userRef);
    
    if (!userDoc.exists) {
      // Criar documento de usuário se não existir
      transaction.set(userRef, {
        created_at: admin.firestore.FieldValue.serverTimestamp(),
        subscription: updates
      });
    } else {
      // Atualizar apenas os campos de subscription
      const currentData = userDoc.data()?.subscription || {};
      transaction.update(userRef, {
        subscription: { ...currentData, ...updates }
      });
    }
  });
}

/**
 * Sincroniza status de assinatura com todos os dispositivos do usuário
 */
async function syncSubscriptionToAllDevices(userId: string) {
  const userDoc = await db.collection('users').doc(userId).get();
  
  if (!userDoc.exists) {
    console.log('User not found:', userId);
    return;
  }

  const userData = userDoc.data();
  const subscriptionStatus = userData?.subscription;

  if (!subscriptionStatus) {
    console.log('No subscription data for user:', userId);
    return;
  }

  // Buscar todos os dispositivos ativos do usuário
  const devicesSnapshot = await db.collection('users')
    .doc(userId)
    .collection('devices')
    .where('isActive', '==', true)
    .get();

  // Criar documento de sincronização para cada dispositivo
  const batch = db.batch();
  
  devicesSnapshot.docs.forEach(deviceDoc => {
    const syncRef = db.collection('sync_queue').doc();
    
    batch.set(syncRef, {
      userId,
      deviceId: deviceDoc.id,
      type: 'subscription_status',
      data: subscriptionStatus,
      created_at: admin.firestore.FieldValue.serverTimestamp(),
      processed: false,
      priority: 'high' // Subscription updates são alta prioridade
    });
  });

  if (!devicesSnapshot.empty) {
    await batch.commit();
    console.log(`Queued subscription sync for ${devicesSnapshot.size} devices`);
  }
}

export const subscriptionWebhook = {
  revenuecatWebhook,
  syncSubscriptionStatus,
};