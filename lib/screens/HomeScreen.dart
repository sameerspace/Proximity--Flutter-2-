import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:proximity/widgets/UserTile.dart';
import 'package:geolocator/geolocator.dart';
import '../services/Database.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String myEmail;
  bool _isLoading = false;
  bool once = true;
  bool _logLoad = false;
  Location myPos;

  Future<void> getMyEmail() async {
    myEmail = await SharedPreferenceHelper().getUserEmail();
    myPos = await SharedPreferenceHelper().getUserLocation();
    if (myPos.lat == null || myPos.long == null) {
      Position p = await Geolocator.getCurrentPosition();
      myPos.lat = p.latitude;
      myPos.long = p.longitude;
    }
    return myEmail;
  }

  @override
  void initState() {
    if (once) {
      setState(() => _isLoading = true);
      getMyEmail().then((value) {
        setState(() => _isLoading = false);
      });
    }
    once = false;
    super.initState();
  }

  Stream<QuerySnapshot> getUserList() {
    print("My Email is $myEmail");
    return FirebaseFirestore.instance
        .collection('users')
        .where('email', isNotEqualTo: myEmail)
        .snapshots();
  }

  Future<void> logout() async {
    setState(() => _logLoad = true);
    try {
      // final pref = await SharedPreferences.getInstance();
      // pref.clear();
    } catch (erro) {
      print(erro.toString());
    }
    setState(() => _logLoad = true);
    FirebaseAuth.instance.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      appBar: AppBar(
        title: Text(
          'Proximity',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        actions: [
          IconButton(
              icon: _logLoad
                  ? Center(
                      child: CircularProgressIndicator(),
                    )
                  : Icon(Icons.logout),
              onPressed: _logLoad ? null : logout),
        ],
        elevation: 0,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : StreamBuilder(
              stream: getUserList(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  print('eror');
                }
                if (snapshot.hasData) {
                  return _isLoading
                      ? Center(child: CircularProgressIndicator())
                      : ListView.builder(
                          itemCount: snapshot.data.docs.length,
                          itemBuilder: (context, index) {
                            print(
                                'mylat : ${myPos.lat} myLong : ${myPos.long}');
                            print(
                                "hisLat:${snapshot.data.docs[index]['location']['latitude']} ,hisLong:${snapshot.data.docs[index]['location']['longitude']}");
                            return UserTile(
                              username: snapshot.data.docs[index]['username'],
                              imageUrl: snapshot.data.docs[index]['imageurl'],
                              email2: snapshot.data.docs[index]['email'],
                              distance: Geolocator.distanceBetween(
                                  myPos.lat,
                                  myPos.long,
                                  snapshot.data.docs[index]['location']
                                      ['latitude'],
                                  snapshot.data.docs[index]['location']
                                      ['longitude']),
                            );
                          });
                }

                return Center(child: Text('No Users to show'));
              },
            ),
    );
  }
}
