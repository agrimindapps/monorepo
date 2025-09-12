import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';

// Initialize Firebase Admin
admin.initializeApp();

// Import function modules
import { deviceManagement } from './deviceManagement';
import { subscriptionWebhook } from './subscription';
import { dataSync } from './dataSync';

// Export all Cloud Functions
export const validateDevice = deviceManagement.validateDevice;
export const revokeDevice = deviceManagement.revokeDevice;
export const cleanupOldSessions = deviceManagement.cleanupOldSessions;

export const revenuecatWebhook = subscriptionWebhook.revenuecatWebhook;
export const syncSubscriptionStatus = subscriptionWebhook.syncSubscriptionStatus;

export const syncUserData = dataSync.syncUserData;
export const batchSyncUserData = dataSync.batchSyncUserData;
export const resolveConflicts = dataSync.resolveConflicts;