import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RegistrationLoginService {

  // LOGIN
  Future<void> loginUser({
    required String email,
    required String password,
  }) async {
    try {
      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      debugPrint("Login successful: ${userCredential.user?.uid}");

    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        debugPrint("No user found for that email");
      } else if (e.code == 'wrong-password') {
        debugPrint("Wrong password provided");
      } else if (e.code == 'invalid-email') {
        debugPrint("Invalid email format");
      } else {
        debugPrint("Login failed: ${e.message}");
      }

    } catch (e) {
      debugPrint("Unexpected error: $e");
    }
  }


  // REGISTER
  Future<String?> registerUser({
    required String fullname,
    required String email,
    required String password,
    required String confirmPassword,
  }) async {

    final validationError = validateRegistration(
      fullname: fullname,
      email: email,
      password: password,
      confirmPassword: confirmPassword,
    );

    if (validationError != null) {
      return validationError;
    }

    try {
      UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      final user = userCredential.user;

      if (user == null) {
        return "Failed to create user";
      }

      await FirebaseFirestore.instance
          .collection("users")
          .doc(user.uid)
          .set({
        "fullName": fullname.trim(),
        "email": email.trim(),
        "createdAt": Timestamp.now(),
      });

      return null;

    } on FirebaseAuthException catch (e) {
      if (e.code == "email-already-in-use") {
        return "This email is already registered";
      }

      if (e.code == "weak-password") {
        return "Password is too weak";
      }

      return e.message ?? "Registration failed";

    } catch (e) {
      return "Something went wrong: $e";
    }
  }


  // VALIDATION
  String? validateRegistration({
    required String fullname,
    required String email,
    required String password,
    required String confirmPassword,
  }) {
    if (fullname.isEmpty) {
      return "Please enter your full name";
    }

    if (email.isEmpty) {
      return "Please enter your email";
    }

    if (!email.trim().toLowerCase().endsWith("@student.gsu.edu")) {
      return "Please use your GSU student email";
    }

    if (password.isEmpty || confirmPassword.isEmpty) {
      return "Please fill in both password fields";
    }

    if (password != confirmPassword) {
      return "Passwords do not match";
    }

    return null;
  }
}