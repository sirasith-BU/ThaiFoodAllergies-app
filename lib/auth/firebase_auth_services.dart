import 'dart:developer';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final _auth = FirebaseAuth.instance;
  User? get currentUser => _auth.currentUser;

  Future<User?> createUserWithEmailAndPassword(
      String email, String password) async {
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      return cred.user;
    } on FirebaseAuthException catch (e) {
      exceptionHandler(e.code);
    } catch (e) {
      log("Something went wrong");
    }
    return null;
  }

  Future<User?> loginUserWithEmailAndPassword(
      String email, String password) async {
    try {
      final cred = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      return cred.user;
    } on FirebaseAuthException catch (e) {
      exceptionHandler(e.code);
    } catch (e) {
      log("Something went wrong");
    }
    return null;
  }

  Future<void> signout() async {
    try {
      await _auth.signOut();
    } catch (e) {
      log("Something went wrong");
    }
  }

  Future<void> sendResetpasswordlink(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      log(e.toString());
    }
  }

  Future<void> deleteUser() async {
    try {
      final user = currentUser;
      if (user != null) {
        await user.delete();
        log("User account deleted successfully");
      } else {
        log("No user is currently signed in");
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'requires-recent-login') {
        log("The user must re-authenticate before this operation can be executed.");
      } else {
        exceptionHandler(e.code);
      }
    } catch (e) {
      log("Something went wrong while deleting the user");
    }
  }
}

void exceptionHandler(String code) {
  switch (code) {
    case "invalid-credential":
      log("Your login credentials are invalid");
      break;
    case "weak-password":
      log("Your password must be at least 8 characters");
      break;
    case "email-already-in-use":
      log("User already exists");
      break;
    default:
      log("Something went wrong");
  }
}
