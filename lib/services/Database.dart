import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Location {
  double long;
  double lat;
  Location({@required this.lat, @required this.long});
}

class SharedPreferenceHelper {
  static String userIdKey = "USERKEY";
  static String userNameKey = "USERNAMEKEY";
  static String displayNameKey = "USERDISPLAYNAMEKEY";
  static String userEmailKey = "USEREMAILKEY";
  static String userProfilePicKey = "USERPROFILEPICKEY";
  static String userLongitude = "LONGITUDE";
  static String userLatitude = "LATITUDE";

  //save data
  Future<bool> saveUserName(String getUserName) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setString(userNameKey, getUserName);
  }

  Future<bool> saveUserLocation(double longitude, double latitude) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool a = await prefs.setDouble(userLongitude, longitude);
    bool b = await prefs.setDouble(userLatitude, latitude);
    if (a && b) {
      return true;
    }
    return false;
  }

  Future<bool> saveUserEmail(String getUseremail) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setString(userEmailKey, getUseremail);
  }

  Future<bool> saveUserId(String getUserId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setString(userIdKey, getUserId);
  }

  Future<bool> saveDisplayName(String getDisplayName) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setString(displayNameKey, getDisplayName);
  }

  Future<bool> saveUserProfileUrl(String getUserProfile) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setString(userProfilePicKey, getUserProfile);
  }

  // get data
  Future<String> getUserName() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(userNameKey);
  }

  Future<Location> getUserLocation() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Location loc = Location(
        lat: prefs.getDouble(userLatitude),
        long: prefs.getDouble(userLongitude));

    return loc;
  }

  Future<String> getUserEmail() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(userEmailKey);
  }

  Future<String> getUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(userIdKey);
  }

  Future<String> getDisplayName() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(displayNameKey);
  }

  Future<String> getUserProfileUrl() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(userProfilePicKey);
  }
}

class DatabaseHelper {
  static String generateChatRoomId(String a, String b) {
    //trimming the strings until the first characters are different
    if (a.toLowerCase().codeUnitAt(0) == b.toLowerCase().codeUnitAt(0)) {
      int i = 0;
      while (a[i] == b[i]) {
        i++;
      }
      String tempa, tempb;
      tempa = a.substring(i, a.length);
      tempb = b.substring(i, b.length);
      if (tempa.toLowerCase().codeUnitAt(0) >
          tempb.toLowerCase().codeUnitAt(0)) {
        return "$tempb\_$tempa";
      }
      return "$tempa\_$tempb";
    } else if (a.toLowerCase().codeUnitAt(0) > b.toLowerCase().codeUnitAt(0)) {
      return "$b\_$a";
    }
    return "$a\_$b";
  }
}
