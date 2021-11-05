import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:never_lost/components/loading.dart';
import 'package:never_lost/constants.dart';
import 'package:never_lost/firebase/database.dart';
import 'package:never_lost/screens/chatroom.dart';
import 'package:never_lost/screens/friendlst.dart';

class Chats extends StatefulWidget {
  final Map<String, dynamic> user;

  const Chats({required this.user, Key? key}) : super(key: key);

  @override
  _ChatsState createState() => _ChatsState();
}

class _ChatsState extends State<Chats> {
  late Stream chatStream;
  bool isLoading = true;

  @override
  void initState() {
    getChats();
    super.initState();
  }

  void getChats() async {
    await DatabaseMethods().getChats(widget.user['email']).then((value) {
      setState(() {
        chatStream = value;
        isLoading = false;
      });
    });
  }

  String claculateTime(_timestamp) {
    DateTime currentTime = DateTime.now();
    var timestamp =
        DateTime.fromMicrosecondsSinceEpoch(_timestamp.microsecondsSinceEpoch);
    var yearDiff = currentTime.year - timestamp.year;
    var monthDiff = currentTime.month - timestamp.month;
    var dayDiff = currentTime.day - timestamp.day;
    var hourDiff = currentTime.hour - timestamp.hour;
    var minDiff = currentTime.minute - timestamp.minute;

    var min = '${timestamp.minute}'.length > 1
        ? '${timestamp.minute}'
        : '0${timestamp.minute}';

    var hour = '${timestamp.hour}'.length > 1
        ? '${timestamp.hour}'
        : '0${timestamp.hour}';

    var day = '${timestamp.day}'.length > 1
        ? '${timestamp.day}'
        : '0${timestamp.day}';

    var month = '${timestamp.month}'.length > 1
        ? '${timestamp.month}'
        : '0${timestamp.month}';
    
    var year = '${timestamp.year}'.substring(2);

    if (yearDiff < 1 &&
        monthDiff < 1 &&
        dayDiff < 1 &&
        hourDiff < 1 &&
        minDiff < 1) {
      return 'Just Now';
    } else if (yearDiff < 1 && monthDiff < 1 && dayDiff < 1) {
      if (int.parse(hour) == 0) {
        return '12:$min AM';
      } else if (int.parse(hour) == 12) {
        return '12:$min PM';
      } else if (int.parse(hour) > 12) {
        return '${int.parse(hour) - 12}:$min PM';
      } else {
        return '$hour:$min AM';
      }
    } else if ((yearDiff < 1 && monthDiff < 1 && dayDiff < 2) || (yearDiff < 1 && monthDiff <= 1 && dayDiff < 0) || (yearDiff == 1 && currentTime.day == 1 && currentTime.month == 1)) {
      return 'Yesterday';
    } else {
      return '$day/$month/$year';
    }
  }

  void showPhoto(height, width, photoURL) {
    showDialog(
        context: context,
        barrierDismissible: true,
        builder: (context) {
          return InteractiveViewer(
            child: SimpleDialog(
                elevation: 0,
                backgroundColor: Colors.transparent,
                children: [
                  Container(
                    height: width,
                    width: width,
                    decoration: BoxDecoration(
                        image: DecorationImage(
                            image: NetworkImage(photoURL),
                            fit: BoxFit.fitWidth)),
                  ),
                ]),
          );
        });
  }

  Widget messageCount(chatRoomId, email) {
    return StreamBuilder(
      stream: DatabaseMethods().getUnseenMessages(chatRoomId, email),
      builder: (context, AsyncSnapshot snapshot) {
        return snapshot.hasData && snapshot.data.docs.length > 0
            ? Container(
                margin: EdgeInsets.all(2),
                padding: EdgeInsets.all(4),
                decoration: BoxDecoration(
                    color: backgroundColor1, shape: BoxShape.circle),
                child: Text(
                  '${snapshot.data.docs.length}',
                  style: TextStyle(
                      color: backgroundColor2, fontWeight: FontWeight.bold, fontSize: 10),
                ),
              )
            : Container(
                padding: EdgeInsets.all(4),
                child: Text(
                  ' ',
                  style: TextStyle(
                      color: backgroundColor2, fontWeight: FontWeight.bold),
                ),
              );
      },
    );
  }

  Widget chatList(height, width) {
    return StreamBuilder(
      stream: chatStream,
      builder: (context, AsyncSnapshot snapshot) {
        return snapshot.hasData
            ? ListView.builder(
                itemCount: snapshot.data.docs.length,
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  DocumentSnapshot ds = snapshot.data.docs[index];
                  String friendEmail = ds['users'][0] != widget.user['email']
                      ? ds['users'][0]
                      : ds['users'][1];

                  return StreamBuilder(
                    stream: DatabaseMethods().searchByEmail(friendEmail),
                    builder: (context, AsyncSnapshot snap) {
                      Map<String, dynamic> friendUser = snap.hasData ?
                          snap.data.docs[0].data() : {};
                      return snap.hasData ? Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: ListTile(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => ChatRoomBar(
                                            user: widget.user,
                                            friendUser: friendUser)));
                              },
                              title: Text(
                                friendUser['name'],
                                style: TextStyle(fontWeight: FontWeight.bold),
                                softWrap: true,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                                
                              ),
                              subtitle: Text(
                                ds['lastMessage'],
                                softWrap: true,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                              leading: GestureDetector(
                                onTap: () {
                                  showPhoto(
                                      height, width, friendUser['photoURL']);
                                },
                                child: ClipRRect(
                                    borderRadius: BorderRadius.circular(100),
                                    child:
                                        Image.network(friendUser['photoURL'])),
                              ),
                              trailing: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                // crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(claculateTime(ds['timestamp'])),
                                  messageCount(ds.id, widget.user['email'])
                                ],
                              )),
                        ),
                      ) : Container();
                    },
                  );
                },
              )
            : SizedBox();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    return isLoading
        ? Loading()
        : Scaffold(
            floatingActionButton: FloatingActionButton(
              backgroundColor: backgroundColor1,
              child: Icon(
                Icons.message,
                color: backgroundColor2,
              ),
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => FriendList(user: widget.user)));
              },
            ),
            body: chatList(height, width),
          );
  }
}
