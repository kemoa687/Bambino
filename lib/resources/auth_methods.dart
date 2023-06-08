import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:babmbino/models/user.dart' as model;
import 'package:babmbino/resources/storage_methods.dart';

class AuthMethods {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // get user details
  Future<model.User> getUserDetails() async {
    User currentUser = _auth.currentUser!;

    DocumentSnapshot documentSnapshot =
        await _firestore.collection('users').doc(currentUser.uid).get();

    return model.User.fromSnap(documentSnapshot);
  }

  // Signing Up User

  Future<String> signUpUser({
    required String email,
    required String password,
    required String username,
    required String bio,
    required Uint8List file,
    required String parentEmail,
    required int age,
  }) async {
    String res = "Some error Occurred";
    try {
      if (email.isEmpty ||
          password.isEmpty ||
          username.isEmpty ||
          bio.isEmpty ||
          parentEmail.isEmpty ||
          age==0){
        res = 'Please enter all the fields';
      }else if (email == parentEmail){
        res = 'The user email and parent email are the same';
      }else if (age>14 || age <8){
        res = 'The allowed age is 14 - 16';
      }else if ((email.contains('@') == false) ||(parentEmail.contains('@') == false) ){
        res = 'Wrong form of email';
      }else if (password.length < 8){
        res = 'Enter a password of 8 letters';
      }else if (email.isNotEmpty ||
          password.isNotEmpty ||
          username.isNotEmpty ||
          bio.isNotEmpty ||
          parentEmail.isNotEmpty ||
          (8<=age && age<=14)) {
        // registering user in auth with email and password
        UserCredential cred = await _auth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );

        String photoUrl =
            await StorageMethods().uploadImageToStorage('profilePics', file, false);

        model.User _user = model.User(
          username: username,
          uid: cred.user!.uid,
          photoUrl: photoUrl,
          email: email,
          bio: bio,
          parentEmail: parentEmail,
          age: age,
          followers: [],
          following: [],
        );
        // adding user in our database
        await _firestore
            .collection("users")
            .doc(cred.user!.uid)
            .set(_user.toJson());
        res = "success";
      }
    } catch (err) {
      return 'Existed email. Please try another email';
    }
    return res;
  }

  // logging in user
  Future<String> loginUser({
    required String email,
    required String password,
  }) async {
    String res = "Some error Occurred";
    try {
      if (email.isNotEmpty || password.isNotEmpty) {
        // logging in user with email and password
        await _auth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
        res = "success";
      } else {
        res = "Please enter all the fields";
      }
    } catch (err) {
      return 'Wrong e-mail or password';
    }
    return res;
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }
}