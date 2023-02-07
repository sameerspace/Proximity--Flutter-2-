import 'package:flutter/material.dart';
import '../screens/ChatScreen.dart';
import '../services/Database.dart';

class UserTile extends StatefulWidget {
  final String username;
  final String imageUrl;
  final String email2;
  final double distance;
  UserTile({this.username, this.imageUrl, this.email2, this.distance});

  @override
  _UserTileState createState() => _UserTileState();
}

class _UserTileState extends State<UserTile> {
  String currentUserEmail;
  String subtitle;
  Future<void> getEmail() async {
    currentUserEmail = await SharedPreferenceHelper().getUserEmail();
  }

  @override
  void initState() {
    getEmail();
    if (widget.distance.ceil() < 1000) {
      setState(() => subtitle = '< 1');
    } else {
      double km = widget.distance.ceil() / 1000;
      var finalDistance = double.parse((km).toStringAsFixed(1));
      setState(() => subtitle = finalDistance.toString());
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 8, 20, 8),
      child: ClipRRect(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(16),
          bottomRight: Radius.circular(16),
        ),
        child: ListTile(
          contentPadding: EdgeInsets.all(20),
          tileColor: Theme.of(context).accentColor,
          title: Text(
            widget.username,
            style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
          ),
          subtitle: Text('${subtitle}km away..'),
          trailing: widget.imageUrl == null
              ? null
              : CircleAvatar(
                  radius: 35,
                  backgroundImage: NetworkImage(widget.imageUrl),
                ),
          onTap: () => Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => ChatScreen(
                    userA: currentUserEmail,
                    userB: widget.email2,
                    otherUsername: widget.username,
                  ))),
        ),
      ),
    );
  }
}
