import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class AuthRemoteDataSource {
  final FirebaseAuth firebaseAuth;
  final FirebaseFirestore firestore;

  AuthRemoteDataSource(this.firebaseAuth, this.firestore);

  Future<UserModel> login(String email, String password) async {
    final credential = await firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    final uid = credential.user!.uid;

    if(!email.endsWith("@pens.ac.id")) {
      await firebaseAuth.signOut();
      throw Exception("Email must be a valid pens.ac.id address");
    }

    final doc = await firestore.collection("users").doc(uid).get();
    return UserModel.fromFirestore(doc.data()!, uid);
  }

  Future<UserModel> register(String email, String password, String role, String name) async {
    if (!email.endsWith("@pens.ac.id")) {
      throw Exception("Email must be a valid pens.ac.id address");
    }
    final credential = await firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    final uid = credential.user!.uid;

    final userModel = UserModel(uid: uid, email: email, role: role);
    
    // Save user data with name to Firestore
    await firestore.collection("users").doc(uid).set({
      ...userModel.toMap(),
      'name': name,
      'created_at': FieldValue.serverTimestamp(),
    });
    
    return userModel;
  }

  Future<void> logout() async {
    await firebaseAuth.signOut();
  }
}
