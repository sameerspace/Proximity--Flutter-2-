import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/Database.dart';
import '../widgets/MessageTile.dart';

class ChatScreen extends StatefulWidget {
  final String userA;
  final String userB;
  final otherUsername;
  ChatScreen(
      {@required this.userA,
      @required this.userB,
      @required this.otherUsername});
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  TextEditingController msgController = TextEditingController();
  String chatroomId;

  Stream<QuerySnapshot> getUserChats() {
    chatroomId = DatabaseHelper.generateChatRoomId(widget.userA, widget.userB);
    print("Chat id: $chatroomId");
    return FirebaseFirestore.instance
        .collection('chatrooms')
        .doc(chatroomId)
        .collection('messages')
        .orderBy('time', descending: true)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).accentColor,
      appBar: AppBar(
        title: Text(
          widget.otherUsername,
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder(
              stream: getUserChats(),
              builder: (context, AsyncSnapshot snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }
                if (snapshot.hasData) {
                  print('has data');
                  return ListView.builder(
                      itemCount: snapshot.data.docs.length,
                      reverse: true,
                      itemBuilder: (context, index) {
                        return MessageTile(
                          message: snapshot.data.docs[index]['text'],
                          isMe: snapshot.data.docs[index]['sentBy'] ==
                                  widget.userA
                              ? true
                              : false,
                          key: ValueKey(snapshot.data.docs[index].id),
                        );
                      });
                }
                return Center(
                  child: Text('No Chats to show'),
                );
              },
            ),
          ),
          Row(
            children: [
              Expanded(
                  child: TextField(
                controller: msgController,
                maxLines: 10,
                minLines: 1,
                keyboardType: TextInputType.multiline,
                decoration:
                    InputDecoration(filled: true, fillColor: Colors.grey[350]),
              )),
              IconButton(
                  icon: Icon(Icons.send, color: Theme.of(context).primaryColor),
                  onPressed: () {
                    if (msgController.text != '') {
                      FirebaseFirestore.instance
                          .collection('chatrooms')
                          .doc(chatroomId)
                          .collection('messages')
                          .doc()
                          .set({
                        'sentBy': widget.userA,
                        'recievedBy': widget.userB,
                        'text': msgController.text,
                        'time': DateTime.now().toString(),
                      });
                      msgController.clear();
                    }
                  }),
            ],
          ),
        ],
      ),
    );
  }
}
