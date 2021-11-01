import 'package:flutter/material.dart';
import 'package:never_lost/components/loading.dart';
import 'package:never_lost/constants.dart';
import 'package:never_lost/firebase/database.dart';
import 'package:never_lost/screens/chatroom.dart';

class FriendList extends StatefulWidget {

  final Map<String, dynamic> user;

  const FriendList({required this.user, Key? key }) : super(key: key);

  @override
  _FriendListState createState() => _FriendListState();
}

class _FriendListState extends State<FriendList> {

  late Map<String, dynamic> user;
  List<Map<String, dynamic>> friendList = [];
  bool isLoading = true;

  @override
  void initState() {
    getCurrentUser();
    super.initState();
  }


  void getCurrentUser() async {
    await DatabaseMethods().findUserWithUID(widget.user['uid']).then((value){
      setState(() {
        user = value.data()!;
      });
    }).then((value){
      createFriendList(user['friendList']);
    });
    
  }

  void createFriendList(tempList) async {
    for(int i=0; i<tempList.length; i++){
      await DatabaseMethods().findUserWithUID(tempList[i]).then((value){
        friendList.add(value.data()!);
      });
    }
    friendList.sort((a, b) => a['name'].compareTo(b['name']));
    setState(() {
      isLoading = false;
    });
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

  Widget friendListTiles(height, width) {
    return friendList.isNotEmpty ? ListView.builder(
      itemCount: friendList.length,
      shrinkWrap: true,
      itemBuilder: (context, index){
        var friendUser = friendList[index];
        return Padding(
          padding: const EdgeInsets.all(4.0),
          child: ListTile(
            onTap: (){
              Navigator.push(context, MaterialPageRoute(builder: (context) => ChatRoom(user: user, friendUser: friendUser)));
            },
            leading: GestureDetector(
              onTap: (){
                showPhoto(height, width, friendUser['photoURL']);
              },
              child: ClipRRect(
                          borderRadius: BorderRadius.circular(100),
                          child: Image.network(friendUser['photoURL'])),
            ),
             title: Text(friendUser['name'],
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(friendUser['email'],
                          style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        );
      },
    ) : Text('No friends');
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: backgroundColor1,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(bottom: Radius.circular(15))),
        title: Text('Friends'),
      ),
      body: isLoading ? Loading() : friendListTiles(height, width),
    );
  }
}