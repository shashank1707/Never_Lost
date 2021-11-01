import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:never_lost/components/loading.dart';
import 'package:never_lost/constants.dart';
import 'package:never_lost/firebase/database.dart';

class ChatRoom extends StatefulWidget {
  final Map<String, dynamic> user, friendUser;
  const ChatRoom({Key? key, required this.user, required this.friendUser})
      : super(key: key);

  @override
  _ChatRoomState createState() => _ChatRoomState();
}

class _ChatRoomState extends State<ChatRoom> {
  final _messageController = TextEditingController();
  late Stream messageStream;
  late String chatRoomID;
  bool isLoading = true;

  @override
  void initState() {
    createChatRoomID();
    super.initState();
  }

  void createChatRoomID() async {
    List tempList = [
      widget.user['email'].split('@')[0],
      widget.friendUser['email'].split('@')[0]
    ];
    tempList.sort((a, b) => a.compareTo(b));
    setState(() {
      chatRoomID = tempList.join('_');
    });
    await createChatRoom().then((value) {
      getMessages();
    });
  }

  Future<void> createChatRoom() async {
    Map<String, dynamic> tempUser = {
      'name': widget.user['name'],
      'email': widget.user['email'],
      'uid': widget.user['uid'],
      'photoURL': widget.user['photoURL'],
    };

    Map<String, dynamic> tempFriendUser = {
      'name': widget.friendUser['name'],
      'email': widget.friendUser['email'],
      'uid': widget.friendUser['uid'],
      'photoURL': widget.friendUser['photoURL'],
    };
    await DatabaseMethods().createChatRoom(
        chatRoomID, widget.user['email'], widget.friendUser['email']);
  }

  void getMessages() async {
    await DatabaseMethods().getMessages(chatRoomID).then((value) {
      setState(() {
        messageStream = value;
        isLoading = false;
      });
    });
  }

  void sendMessage() async {
    Map<String, dynamic> lastMessageInfo = {
      'lastMessage': _messageController.text.trim(),
      'sender': widget.user['email'],
      'receiver': widget.friendUser['email'],
      'seen': false,
      'timestamp': DateTime.now(),
    };

    Map<String, dynamic> messageInfo = {
      'message': _messageController.text.trim(),
      'sender': widget.user['email'],
      'receiver': widget.friendUser['email'],
      'seen': false,
      'timestamp': DateTime.now()
    };

    DatabaseMethods().addMessage(chatRoomID, messageInfo, lastMessageInfo);
    _messageController.clear();
  }

  Widget messageList() {
    return StreamBuilder(
      stream: messageStream,
      builder: (context, AsyncSnapshot snapshot) {
        return snapshot.hasData
            ? ListView.builder(
                padding: EdgeInsets.only(bottom: 70),
                itemCount: snapshot.data.docs.length,
                shrinkWrap: true,
                reverse: true,
                itemBuilder: (context, index) {
                  DocumentSnapshot ds = snapshot.data.docs[index];
                  bool sendbyMe = ds['sender'] == widget.user['email'];
                  if (!sendbyMe) {
                    DatabaseMethods().updateSeenInfo(chatRoomID, ds.id);
                  }
                  return Wrap(
                    crossAxisAlignment: WrapCrossAlignment.end,
                    alignment: sendbyMe ? WrapAlignment.end : WrapAlignment.start,
                    children: [
                      Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        margin: EdgeInsets.only(
                            top: 8,
                            bottom: 8,
                            left: sendbyMe ? 50 : 8,
                            right: sendbyMe ? 8 : 50),
                        decoration: BoxDecoration(
                            color: sendbyMe
                                ? backgroundColor1
                                : backgroundColor1.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(15)),
                        child: Text(
                          ds['message'],
                          style: TextStyle(
                            fontSize: 16,
                              color: sendbyMe
                                  ? backgroundColor2
                                  : backgroundColor1),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8, right: 8),
                        child: Visibility(
                          visible: sendbyMe,
                          child: Icon(
                            ds['seen']
                                ? Icons.check_circle
                                : Icons.check_circle_outline,
                            color: ds['seen'] ? backgroundColor1 : Colors.grey,
                            size: 15,
                          ),
                        ),
                      )
                    ],
                  );
                },
              )
            : Loading();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;
    return isLoading
        ? Loading()
        : Scaffold(
            appBar: AppBar(
              backgroundColor: backgroundColor1,
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.vertical(bottom: Radius.circular(15))),
              leading: Padding(
                padding: const EdgeInsets.all(8.0),
                child: ClipRRect(
                    borderRadius: BorderRadius.circular(100),
                    child: Image.network(widget.friendUser['photoURL'])),
              ),
              title: Text(widget.friendUser['name']),
            ),
            body: Stack(
              children: [
                Align(alignment: Alignment.bottomCenter, child: messageList()),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                      color: backgroundColor2,
                      child: Row(
                        children: [
                          Expanded(
                            child: Container(
                              margin: EdgeInsets.all(8),
                              padding: EdgeInsets.symmetric(horizontal: 16),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(15),
                                  color: backgroundColor1.withOpacity(0.1)),
                              child: TextField(
                                controller: _messageController,
                                minLines: 1,
                                maxLines: 4,
                                decoration: InputDecoration(
                                    border: InputBorder.none,
                                    hintText: 'Enter your Message',
                                    hintStyle: TextStyle(color: textColor1)),
                              ),
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.all(8),
                            decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: backgroundColor1),
                            child: IconButton(
                                onPressed: () {
                                  sendMessage();
                                },
                                icon: Icon(
                                  Icons.send_rounded,
                                  color: backgroundColor2,
                                )),
                          )
                        ],
                      )),
                ),
              ],
            ),
          );
  }
}
