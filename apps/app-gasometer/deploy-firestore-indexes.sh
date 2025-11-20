#!/bin/bash

#############################################################################
# Firebase Firestore Indices Deployment Script
# Gasometer App
#
# Purpose: Deploy composite indices required for sync operations
#
# Usage:
#   chmod +x deploy-firestore-indexes.sh
#   ./deploy-firestore-indexes.sh [PROJECT_ID] [ENVIRONMENT]
#
# Arguments:
#   PROJECT_ID: Firebase project ID (required)
#   ENVIRONMENT: dev or prod (optional, default: dev)
#
# Examples:
#   ./deploy-firestore-indexes.sh my-project-dev
#   ./deploy-firestore-indexes.sh my-project-prod prod
#
# Prerequisites:
#   - Firebase CLI installed (npm install -g firebase-tools)
#   - Authenticated with Firebase (firebase login)
#   - firestore.indexes.json in current directory
#############################################################################

set -e

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Functions
print_header() {
  echo -e "${BLUE}========================================${NC}"
  echo -e "${BLUE}$1${NC}"
  echo -e "${BLUE}========================================${NC}"
}

print_success() {
  echo -e "${GREEN}✅ $1${NC}"
}

print_error() {
  echo -e "${RED}❌ $1${NC}"
}

print_info() {
  echo -e "${YELLOW}ℹ️  $1${NC}"
}

# Validate arguments
if [ -z "$1" ]; then
  print_error "PROJECT_ID is required"
  echo ""
  echo "Usage: $0 PROJECT_ID [ENVIRONMENT]"
  echo ""
  echo "Examples:"
  echo "  $0 my-project-dev"
  echo "  $0 my-project-prod prod"
  exit 1
fi

PROJECT_ID="$1"
ENVIRONMENT="${2:-dev}"

# Validate files
if [ ! -f "firestore.indexes.json" ]; then
  print_error "firestore.indexes.json not found in current directory"
  exit 1
fi

print_header "Firestore Indices Deployment"
print_info "Project ID: $PROJECT_ID"
print_info "Environment: $ENVIRONMENT"
print_info "Configuration file: firestore.indexes.json"

# Check Firebase CLI
if ! command -v firebase &> /dev/null; then
  print_error "Firebase CLI not found"
  echo "Install it with: npm install -g firebase-tools"
  exit 1
fi

print_success "Firebase CLI found"

# Validate Firebase login
print_info "Verifying Firebase authentication..."
if ! firebase projects:list &> /dev/null; then
  print_error "Not authenticated with Firebase"
  echo "Run: firebase login"
  exit 1
fi

print_success "Firebase authenticated"

# Parse indices from JSON and display
print_header "Indices to Deploy"
echo ""
echo "The following indices will be created in Firestore:"
echo ""

# Count indices
INDEX_COUNT=$(grep -c '"collectionGroup"' firestore.indexes.json)
echo "Total indices: $INDEX_COUNT"
echo ""

# Display indices
echo "Collections:"
grep '"collectionGroup"' firestore.indexes.json | sed 's/.*"collectionGroup": "\(.*\)".*/  - \1/' | sort | uniq

echo ""
print_info "Each index enables efficient queries on updatedAt field for sync operations"
echo "  Query pattern: where('updatedAt', isGreaterThan: timestamp)"
echo ""

# Confirmation
read -p "Do you want to continue? (y/n) " -n 1 -r
echo ""
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
  print_error "Deployment cancelled"
  exit 1
fi

# Deploy indices
print_header "Deploying Indices"
echo ""

if firebase firestore:indexes --project="$PROJECT_ID" > /dev/null 2>&1; then
  print_info "Existing indices:"
  firebase firestore:indexes --project="$PROJECT_ID" | grep -i 'collection\|status' || true
  echo ""
fi

print_info "Deploying firestore.indexes.json..."
echo ""

if firebase deploy --project="$PROJECT_ID" --only firestore:indexes 2>&1 | tee /tmp/firebase_deploy.log; then
  print_success "Indices deployed successfully!"
  echo ""
  print_header "Next Steps"
  echo ""
  echo "1. Verify indices creation:"
  echo "   firebase firestore:indexes --project=\"$PROJECT_ID\""
  echo ""
  echo "2. Monitor index creation in Firebase Console:"
  echo "   https://console.firebase.google.com/project/$PROJECT_ID/firestore/indexes"
  echo ""
  echo "3. Note: Index creation may take a few minutes for large collections"
  echo ""
else
  print_error "Deployment failed"
  echo "Check the error above and retry"
  exit 1
fi

print_success "Deployment complete!"
