import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:never_lost/components/loading.dart';
import 'package:never_lost/constants.dart';
import 'package:never_lost/firebase/database.dart';

class Notifications extends StatefulWidget {
  final Map<String, dynamic> user;

  const Notifications({required this.user, Key? key}) : super(key: key);

  @override
  _NotificationsState createState() => _NotificationsState();
}

class _NotificationsState extends State<Notifications>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    _tabController = TabController(length: 2, vsync: this, initialIndex: 0);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor2,
      appBar: AppBar(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(15))),
        backgroundColor: backgroundColor1,
        elevation: 0,
        title: const Text('Notifications'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Align(
              alignment: Alignment.centerLeft,
              child: TabBar(
                labelColor: backgroundColor1,
                unselectedLabelColor: backgroundColor2,
                padding: const EdgeInsets.all(8),
                isScrollable: true,
                indicatorSize: TabBarIndicatorSize.tab,
                controller: _tabController,
                indicator: BoxDecoration(
                  color: backgroundColor2,
                  borderRadius: BorderRadius.circular(10),
                ),
                tabs: [
                  Container(
                      alignment: Alignment.center,
                      height: 30,
                      child: const Text(
                        'Friend Requests',
                      )),
                  Container(
                      alignment: Alignment.center,
                      height: 30,
                      child: const Text(
                        'Chats',
                      )),
                ],
              ),
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          FriendRequests(
            user: widget.user,
          ),
          Loading()
        ],
      ),
    );
  }
}

class FriendRequests extends StatefulWidget {
  final Map<String, dynamic> user;

  const FriendRequests({required this.user, Key? key}) : super(key: key);

  @override
  _FriendRequestsState createState() => _FriendRequestsState();
}

class _FriendRequestsState extends State<FriendRequests> {
  late Stream userStream;
  bool isLoading = true;

  @override
  void initState() {
    getCurrentUserSnapshots();
    super.initState();
  }

  void getCurrentUserSnapshots() async {
    userStream = await DatabaseMethods().getUserSnapshots(widget.user['uid']);
    setState(() {
      isLoading = false;
    });
    print(widget.user);
  }

  void acceptFriendRequest(currentUserUID, friendUserUID, index) async {
    await DatabaseMethods().findUserWithUID(friendUserUID).then((value) {
      var friendUser = value.data()!;
      friendUser['friendList'].add(currentUserUID);
      DatabaseMethods().updateUserDatabase(friendUser);
    });
    await DatabaseMethods().findUserWithUID(currentUserUID).then((value) {
      var currentUser = value.data()!;
      currentUser['friendList'].add(friendUserUID);
      currentUser['pendingRequestList'].removeAt(index);
      DatabaseMethods().updateUserDatabase(currentUser);
    });
  }

  void rejectFriedRequest(currentUserUID, index) async {
    await DatabaseMethods().findUserWithUID(currentUserUID).then((value) {
      var currentUser = value.data()!;
      currentUser['pendingRequestList'].removeAt(index);
      DatabaseMethods().updateUserDatabase(currentUser);
    });
  }

  Widget friendRequestTiles() {
    return StreamBuilder(
      stream: userStream,
      builder: (context, AsyncSnapshot snapshot) {
        print(snapshot.hasData);
        return snapshot.hasData
            ? ListView.builder(
                reverse: true,
                itemCount: snapshot.data['pendingRequestList'].length,
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  return StreamBuilder(
                    stream: DatabaseMethods().getUserSnapshots(
                        snapshot.data['pendingRequestList'][index]),
                    builder: (context, AsyncSnapshot snap) {
                      Map<String, dynamic> friendUser =
                          snap.hasData ? snap.data.data() : {};
                      return snap.hasData
                          ? ListTile(
                              leading: ClipRRect(
                                  borderRadius: BorderRadius.circular(100),
                                  child: Image.network(friendUser['photoURL'])),
                              title: Text(friendUser['name'],
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                              subtitle: Text(friendUser['email'],
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                              trailing: Wrap(children: [
                                IconButton(
                                    onPressed: () {
                                      acceptFriendRequest(widget.user['uid'],
                                          friendUser['uid'], index);
                                    },
                                    icon: Icon(
                                      Icons.check_rounded,
                                      color: Colors.green,
                                    )),
                                IconButton(
                                    onPressed: () {
                                      rejectFriedRequest(
                                          widget.user['uid'], index);
                                    },
                                    icon: Icon(
                                      Icons.close,
                                      color: Colors.red,
                                    ))
                              ]),
                            )
                          : Container();
                    },
                  );
                },
              )
            : Container();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading ? Loading() : friendRequestTiles(),
    );
  }
}
