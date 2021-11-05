import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:never_lost/components/loading.dart';
import 'package:never_lost/constants.dart';
import 'package:never_lost/firebase/database.dart';
import 'package:never_lost/screens/groupchatroom.dart';
import 'package:never_lost/screens/newgroup.dart';

class GroupChats extends StatefulWidget {
  final Map<String, dynamic> user;
  const GroupChats({required this.user, Key? key}) : super(key: key);

  @override
  _GroupChatsState createState() => _GroupChatsState();
}

class _GroupChatsState extends State<GroupChats> {

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

  Widget messageCount(groupChatIS, uid) {
    return StreamBuilder(
      stream: DatabaseMethods().getUnseenGroupMessages(groupChatIS, uid),
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

  Widget groupChatTiles() {
    return StreamBuilder(
      stream: DatabaseMethods().findGroupChat(widget.user['uid']),
      builder: (context, AsyncSnapshot snapshot) {
        return snapshot.hasData
            ? ListView.builder(
                itemCount: snapshot.data.docs.length,
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  Map<String, dynamic> groupInfo =
                      snapshot.data.docs[index].data();
                  groupInfo['id'] = snapshot.data.docs[index].id;
                  return Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: ListTile(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => GroupChatRoomBar(
                                    user: widget.user, groupInfo: groupInfo)));
                      },
                      leading: CircleAvatar(
                        radius: 28,
                        child: Icon(Icons.people_alt_outlined, size: 28),
                        backgroundColor: backgroundColor1,
                      ),
                      title: Text(
                        groupInfo['name'],
                        style: TextStyle(fontWeight: FontWeight.bold),
                                softWrap: true,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                      ),
                      subtitle: Text(
                        "${groupInfo['senderName']}: ${groupInfo['lastMessage']}",
                        softWrap: true,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        // crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(claculateTime(groupInfo['timestamp'])),
                          messageCount(groupInfo['id'], widget.user['uid'])
                        ],
                      ),
                    ),
                  );
                },
              )
            : Loading();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => CreateNewGroup(user: widget.user)));
          },
          backgroundColor: backgroundColor1,
          child: Icon(
            Icons.add,
            color: backgroundColor2,
          ),
        ),
        body: groupChatTiles());
  }
}
