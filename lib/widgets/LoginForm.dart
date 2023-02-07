import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:proximity/widgets/ErrorSnackBar.dart';
import '../screens/SignUpScreen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/Database.dart';

class LoginForm extends StatefulWidget {
  @override
  _LoginFormState createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  String email;
  String password;
  bool isLoading = false;

  final _form = GlobalKey<FormState>();

  Future<void> submitForm() async {
    if (_form.currentState.validate()) {
      setState(() => isLoading = true);
      FocusScope.of(context).unfocus();
      _form.currentState.save();
      try {
        final auth = FirebaseAuth.instance;
        UserCredential user = await auth.signInWithEmailAndPassword(
            email: email, password: password);
        SharedPreferenceHelper().saveUserEmail(email);
        Location previousLocation =
            await SharedPreferenceHelper().getUserLocation();
        print(
            "prevLat: ${previousLocation.lat}, prevLong: ${previousLocation.long}");
        Position currentPos = await Geolocator.getCurrentPosition();
        if (previousLocation.lat != currentPos.latitude ||
            previousLocation.long != currentPos.longitude) {
          FirebaseFirestore.instance
              .collection('users')
              .doc(user.user.uid)
              .update({
            'location': {
              'longitude': currentPos.longitude,
              'latitude': currentPos.latitude,
            }
          });
          SharedPreferenceHelper()
              .saveUserLocation(currentPos.longitude, currentPos.latitude);
        }
      } on FirebaseAuthException catch (error) {
        errorSnackBar(context, error.message);
        setState(() => isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _form,
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 15),
              child: Container(
                width: 320,
                child: TextFormField(
                  validator: (value) {
                    if (value.isEmpty || !value.contains('@')) {
                      return 'Please enter valid email';
                    }
                    return null;
                  },
                  onSaved: (newValue) => email = newValue.trim(),
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25.0),
                      borderSide:
                          BorderSide(width: 3, color: Colors.greenAccent[700]),
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
              padding: const EdgeInsets.symmetric(vertical: 10),
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
                  keyboardType: TextInputType.visiblePassword,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25.0),
                      borderSide:
                          BorderSide(width: 3, color: Colors.greenAccent[700]),
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
            SizedBox(height: 10),
            MaterialButton(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 50, vertical: 10),
                child: isLoading
                    ? CircularProgressIndicator(
                        backgroundColor: Colors.amber[700],
                      )
                    : Text(
                        'Login',
                        style: TextStyle(color: Colors.white, fontSize: 30),
                      ),
              ),
              color: Colors.greenAccent[700],
              focusElevation: 5,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18.0),
                  side: BorderSide(color: Colors.greenAccent[700])),
              onPressed: submitForm,
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextButton(
                  child: Text(
                    'Sign up instead ?',
                    style: TextStyle(
                      color: Colors.greenAccent[700],
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (ctx) => SignUpScreen()))),
            ),
          ],
        ),
      ),
    );
  }
}
