import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../domain/user_model.dart';
import '../presentation/notifications/notification_service.dart';

class AuthRepository {
  final firebase_auth.FirebaseAuth _auth = firebase_auth.FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get current user stream
  Stream<firebase_auth.User?> get authStateChanges => _auth.authStateChanges();

  // Get current user data from Firestore
  Future<UserModel?> getCurrentUserData() async {
    final user = _auth.currentUser;
    if (user == null) return null;

    final doc = await _firestore.collection('users').doc(user.uid).get();
    if (!doc.exists) return null;

    return UserModel.fromMap(doc.data()!);
  }

  // Register
  Future<UserModel> register({
    required String email,
    required String password,
    required String nom,
    required String prenom,
    required String role,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    final user = UserModel(
      uid: credential.user!.uid,
      email: email,
      nom: nom,
      prenom: prenom,
      role: role,
    );

    // Save user data in Firestore
    await _firestore
        .collection('users')
        .doc(user.uid)
        .set(user.toMap());

    return user;
  }

  // Login
Future<UserModel> login({
  required String email,
  required String password,
}) async {
  await _auth.signInWithEmailAndPassword(
    email: email,
    password: password,
  );

  final user = await getCurrentUserData() as UserModel;

  // Save FCM token for push notifications
  await NotificationService.instance.saveTokenToFirestore(user.uid);

  return user;
}

  // Logout
  Future<void> logout() async {
    await _auth.signOut();
  }
}
