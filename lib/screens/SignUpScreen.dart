import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../services/Database.dart';
import 'package:geolocator/geolocator.dart';
import '../services/LocationServices.dart';
import '../widgets/PhotoAvatar.dart';
import 'dart:io';
import '../widgets/ErrorSnackBar.dart';

class SignUpScreen extends StatefulWidget {
  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _form = GlobalKey<FormState>();
  String email;
  String password;
  String username;
  File profilePic;
  bool isLoading = false;

  TextEditingController passController = TextEditingController();
  TextEditingController verifyController = TextEditingController();

  Future<void> trySubmit() async {
    if (_form.currentState.validate()) {
      setState(() {
        isLoading = true;
      });
      FocusScope.of(context).unfocus();
      if (profilePic == null) {
        errorSnackBar(context, 'Please pick a profile pic');
        setState(() => isLoading = false);
        return;
      }
      _form.currentState.save();
      try {
        final auth = FirebaseAuth.instance;
        Position currentPos = await determinePosition(context);
        print('Long : ${currentPos.longitude}, lat: ${currentPos.latitude}');
        SharedPreferenceHelper()
            .saveUserLocation(currentPos.longitude, currentPos.latitude);
        UserCredential authResult = await auth.createUserWithEmailAndPassword(
            email: email, password: password);

        final ref = FirebaseStorage.instance
            .ref()
            .child('userimages')
            .child('${authResult.user.uid}.jpg');

        await ref.putFile(profilePic);
        String imageUrl = await ref.getDownloadURL();
        await FirebaseFirestore.instance
            .collection('users')
            .doc(authResult.user.uid)
            .set({
          'username': username,
          'email': email,
          'imageurl': imageUrl,
          'location': {
            'longitude': currentPos.longitude,
            'latitude': currentPos.latitude,
          }
        });
        Navigator.of(context).pop();
      } on FirebaseAuthException catch (error) {
        errorSnackBar(context, error.message);
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  void setProfilePic(File image) {
    profilePic = image;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Form(
        key: _form,
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 50, 0, 0),
                  child: IconButton(
                      icon: Icon(
                        Icons.arrow_back_ios,
                        color: Theme.of(context).primaryColor,
                        size: 35,
                      ),
                      onPressed: () => Navigator.of(context).pop()),
                ),
              ),
              SizedBox(height: 30),
              Align(
                alignment: Alignment.center,
                child: Text(
                  'Register',
                  style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontSize: 50,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              PhotoAvatar(
                submitImage: setProfilePic,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 15),
                child: Container(
                  width: 320,
                  child: TextFormField(
                    validator: (value) {
                      if (value.isEmpty) {
                        return 'Please enter your email';
                      } else if (!value.contains('@')) {
                        return 'Please enter valid email address';
                      }
                      return null;
                    },
                    onSaved: (newValue) => email = newValue.trim(),
                    decoration: InputDecoration(
                      labelText: 'Email',
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15.0),
                        borderSide: BorderSide(
                            width: 3, color: Colors.greenAccent[400]),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25.0),
                        borderSide: BorderSide(
                          color: Colors.greenAccent[700],
                          width: 3.0,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 15),
                child: Container(
                  width: 320,
                  child: TextFormField(
                    validator: (value) {
                      if (value.isEmpty) {
                        return 'Please enter a username';
                      }
                      return null;
                    },
                    onSaved: (newValue) => username = newValue.trim(),
                    decoration: InputDecoration(
                      labelText: 'Username',
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25.0),
                        borderSide: BorderSide(
                            width: 3, color: Colors.greenAccent[400]),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25.0),
                        borderSide: BorderSide(
                          color: Colors.greenAccent[700],
                          width: 3.0,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 15),
                child: Container(
                  width: 320,
                  child: TextFormField(
                    validator: (value) {
                      if (value.isEmpty) {
                        return 'Password cannot be empty';
                      } else if (value.length < 8) {
                        return 'Password cannot be less than 8 characters';
                      }
                      return null;
                    },
                    onSaved: (newValue) => password = newValue.trim(),
                    controller: passController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25.0),
                        borderSide: BorderSide(
                            width: 3, color: Colors.greenAccent[400]),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25.0),
                        borderSide: BorderSide(
                          color: Colors.greenAccent[700],
                          width: 3.0,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 15),
                child: Container(
                  width: 320,
                  child: TextFormField(
                    controller: verifyController,
                    validator: (value) {
                      if (value.isEmpty) {
                        return 'Password cannot be empty';
                      } else if (value.length < 8) {
                        return 'Password cannot be less than 8 characters';
                      } else if (value != passController.text) {
                        return 'Passwords donot match';
                      }
                      return null;
                    },
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'Verify Password',
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25.0),
                        borderSide: BorderSide(
                            width: 3, color: Colors.greenAccent[400]),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25.0),
                        borderSide: BorderSide(
                          color: Colors.greenAccent[700],
                          width: 3.0,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              MaterialButton(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 50, vertical: 10),
                  child: isLoading
                      ? CircularProgressIndicator(
                          backgroundColor: Colors.amber[700],
                        )
                      : Text(
                          'Register',
                          style: TextStyle(color: Colors.white, fontSize: 30),
                        ),
                ),
                color: Colors.greenAccent[700],
                focusElevation: 5,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18.0),
                    side: BorderSide(color: Colors.greenAccent[700])),
                onPressed: trySubmit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
