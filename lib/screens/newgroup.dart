import 'package:flutter/material.dart';
import 'package:never_lost/components/loading.dart';
import 'package:never_lost/constants.dart';
import 'package:never_lost/firebase/database.dart';

class CreateNewGroup extends StatefulWidget {
  final Map<String, dynamic> user;
  const CreateNewGroup({required this.user, Key? key}) : super(key: key);

  @override
  _CreateNewGroupState createState() => _CreateNewGroupState();
}

class _CreateNewGroupState extends State<CreateNewGroup> {
  List addedPeopleList = [];
  List friendList = [];
  List searchList = [];

  Map<String, dynamic> user = {};

  bool isLoading = true;

  TextEditingController _searchController = TextEditingController();
  TextEditingController _nameController = TextEditingController();

  @override
  void initState() {
    getCurrentUser();
    super.initState();
  }

  void getCurrentUser() async {
    await DatabaseMethods().findUserWithUID(widget.user['uid']).then((value) {
      setState(() {
        user = value.data()!;
        isLoading = false;
      });
    }).then((value) {
      createFriendList();
    });
  }

  void createFriendList() async {
    for (int i = 0; i < user['friendList'].length; i++) {
      await DatabaseMethods()
          .findUserWithUID(user['friendList'][i])
          .then((value) {
        friendList.add(value.data()!);
        searchList.add(value.data()!);
      });
    }
    setState(() {});
  }

  void saveGroup() async {

    if(!addedPeopleList.contains(widget.user['uid'])){
      addedPeopleList.add(widget.user['uid']);
    }

    String groupName = _nameController.text.toUpperCase().trim();
    Map<String, dynamic> groupInfo = {
      'name': groupName,
      'lastMessage': 'Created a group',
      'users': addedPeopleList,
      'admin': widget.user['uid'],
      'timestamp': DateTime.now(),
      'sender': widget.user['uid'],
      'senderName': widget.user['name']
    };
    if (groupName != '') {
      DatabaseMethods().createGroup(groupInfo).then((_){
        Navigator.pop(context);
      });
    }
  }

  Widget friendListTiles() {
    return ListView.builder(
      itemCount: searchList.length,
      shrinkWrap: true,
      itemBuilder: (context, index) {
        var friendUser = searchList[index];
        return Padding(
          padding: const EdgeInsets.all(4.0),
          child: ListTile(
            onTap: () {
              if (addedPeopleList.contains(friendUser['uid'])) {
                addedPeopleList.remove(friendUser['uid']);
              } else {
                addedPeopleList.add(friendUser['uid']);
              }
              setState(() {});
            },
            leading: ClipRRect(
                borderRadius: BorderRadius.circular(100),
                child: Image.network(friendUser['photoURL'])),
            title: Text(friendUser['name'],
                style: TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(friendUser['email'],
                style: TextStyle(fontWeight: FontWeight.bold)),
            trailing: addedPeopleList.contains(friendUser['uid'])
                ? Icon(Icons.radio_button_checked, color: backgroundColor1)
                : Icon(
                    Icons.radio_button_off,
                    color: Colors.grey,
                  ),
          ),
        );
      },
    );
  }

  void searchFriend(text) {
    setState(() {
      searchList = friendList
          .where((element) => element['name'].contains(text.toUpperCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    return isLoading
        ? Loading()
        : Scaffold(
            appBar: AppBar(
              backgroundColor: backgroundColor1,
              elevation: 0,
              title: Text('Create Group'),
              shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.vertical(bottom: Radius.circular(15))),
              actions: [
                TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text(
                      'Cancel',
                      style: TextStyle(color: backgroundColor2),
                    )),
                TextButton(
                    onPressed: () {
                      saveGroup();
                    },
                    child: Text(
                      'Done',
                      style: TextStyle(
                          color: _nameController.text.trim() != ''
                              ? backgroundColor2
                              : textColor1),
                    )),
              ],
            ),
            body: SizedBox(
              height: height,
              width: width,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 20, top: 20),
                    child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Group Name',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: backgroundColor1,
                              fontSize: 24),
                        )),
                  ),
                  Container(
                    margin: EdgeInsets.all(16),
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    decoration: BoxDecoration(
                        color: backgroundColor1.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10)),
                    child: TextField(
                      onChanged: (_) {
                        setState(() {});
                      },
                      controller: _nameController,
                      style: const TextStyle(color: textColor1),
                      decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Group Name',
                          hintStyle: TextStyle(color: textColor1)),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 20),
                    child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Add People',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: backgroundColor1,
                              fontSize: 24),
                        )),
                  ),
                  Container(
                    margin: EdgeInsets.all(16),
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    decoration: BoxDecoration(
                        color: backgroundColor1.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10)),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            onChanged: (value) {
                              searchFriend(value);
                            },
                            controller: _searchController,
                            style: const TextStyle(color: textColor1),
                            decoration: InputDecoration(
                                border: InputBorder.none,
                                hintText: 'Search in Friend List',
                                hintStyle: TextStyle(color: textColor1)),
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                              _searchController.text == ''
                                  ? Icons.search
                                  : Icons.close_rounded,
                              color: textColor1),
                          onPressed: () {
                            _searchController.clear();
                            setState(() {
                              searchList = friendList;
                            });
                          },
                        )
                      ],
                    ),
                  ),
                  Expanded(child: friendListTiles())
                ],
              ),
            ),
          );
  }
}
