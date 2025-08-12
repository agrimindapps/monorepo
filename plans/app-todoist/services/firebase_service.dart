// services/firebase_service.dart

// Package imports:
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

class FirebaseService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseStorage _storage = FirebaseStorage.instance;

  // Getters para acesso aos serviços
  static FirebaseAuth get auth => _auth;
  static FirebaseFirestore get firestore => _firestore;
  static FirebaseStorage get storage => _storage;

  // Stream do usuário atual
  static Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Usuário atual
  static User? get currentUser => _auth.currentUser;

  // UID do usuário atual
  static String? get currentUserId => _auth.currentUser?.uid;
}
