import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:never_lost/components/loading.dart';
import 'package:never_lost/constants.dart';
import 'package:never_lost/firebase/database.dart';
import 'package:never_lost/screens/user_profile.dart';

class Search extends StatefulWidget {
  final String uid;

  const Search({required this.uid, Key? key}) : super(key: key);

  @override
  _SearchState createState() => _SearchState();
}

class _SearchState extends State<Search> {
  var selectedMethod = [true, false];
  String searchMethod = 'Name';
  bool isSearching = false;
  bool isLoading = true;

  Map<String, dynamic> user = {};

  final TextEditingController _searchController = TextEditingController();

  late Stream searchStream;

  @override
  void initState() {
    getCurrentUser();
    super.initState();
  }

  void getCurrentUser() async {
    print('getting');
    await DatabaseMethods().findUserWithUID(widget.uid).then((value) {
      setState(() {
        user = value.data()!;
        isLoading = false;
      });
    });
  }

  void onSearch() async {
    isSearching = _searchController.text != '' ? true : false;

    switch (searchMethod) {
      case 'Name':
        searchStream =
            await DatabaseMethods().searchByName(_searchController.text);
        break;
      case 'Email':
        searchStream =
            await DatabaseMethods().searchByEmail(_searchController.text);
        break;
    }
    setState(() {});
  }

  Widget searchList() {
    return StreamBuilder(
      stream: searchStream,
      builder: (context, AsyncSnapshot snapshot) {
        return snapshot.hasData
            ? ListView.builder(
                shrinkWrap: true,
                itemCount: snapshot.data.docs.length,
                itemBuilder: (context, index) {
                  var ds = snapshot.data.docs[index];
                  return Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: ListTile(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => UserProfile(
                                    currentUser: user, userUID: ds['uid'])));
                      },
                      leading: ClipRRect(
                          borderRadius: BorderRadius.circular(100),
                          child: Image.network(ds['photoURL'])),
                      title: Text(ds['name'],
                          style: TextStyle(fontWeight: FontWeight.bold),
                                softWrap: true,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,),
                      subtitle: Text(ds['email'],
                          style: TextStyle(fontWeight: FontWeight.bold),
                                softWrap: true,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,),
                      trailing: Icon(Icons.chevron_right_rounded),
                    ),
                  );
                },
              )
            : const Center(
                child: CircularProgressIndicator(
                  color: backgroundColor1,
                ),
              );
      },
    );
  }

  Widget recentSearchTiles() {
    return ListView.builder(
      itemCount: user['recentSearchList'].length,
      shrinkWrap: true,
      itemBuilder: (context, index) {
        return StreamBuilder(
          stream: DatabaseMethods().getUserSnapshots(user['recentSearchList'][index]),
          builder: (context, AsyncSnapshot snapshot){
            Map<String, dynamic> searchedUser = snapshot.hasData ? snapshot.data.data() : {};
            return snapshot.hasData
            ? Padding(
                padding: const EdgeInsets.all(4.0),
                child: ListTile(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => UserProfile(
                                currentUser: user,
                                userUID: searchedUser['uid'])));
                  },
                  leading: ClipRRect(
                      borderRadius: BorderRadius.circular(100),
                      child: Image.network(searchedUser['photoURL'])),
                  title: Text(searchedUser['name'],
                      style: TextStyle(fontWeight: FontWeight.bold),
                                softWrap: true,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,),
                  subtitle: Text(searchedUser['email'],
                      style: TextStyle(fontWeight: FontWeight.bold),
                                softWrap: true,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,),
                  trailing: Icon(Icons.chevron_right_rounded),
                ),
              )
            : const Text('');
          },
        );        
      },
    );
  }

  void changeSearchMethod(index) {
    selectedMethod = List.filled(2, false);

    setState(() {
      selectedMethod[index] = true;
      if (index == 0) {
        searchMethod = 'Name';
      } else {
        searchMethod = 'Email';
      }
    });

    onSearch();
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    return isLoading
        ? Loading()
        : Scaffold(
            backgroundColor: backgroundColor2,
            body: SizedBox(
              height: height,
              width: width,
              child: Column(
                children: [
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
                              onSearch();
                            },
                            controller: _searchController,
                            style: const TextStyle(color: textColor1),
                            decoration: InputDecoration(
                                border: InputBorder.none,
                                hintText: 'Search by $searchMethod',
                                hintStyle: TextStyle(color: textColor1)),
                          ),
                        ),
                        IconButton(
                          icon: Icon(_searchController.text == '' ? Icons.search : Icons.close_rounded, color: textColor1),
                          onPressed: () {
                            setState(() {
                              _searchController.clear();
                            });
                          },
                        )
                      ],
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                        color: backgroundColor1,
                        borderRadius: BorderRadius.circular(10)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Container(
                          height: 35,
                          decoration: BoxDecoration(
                            color: selectedMethod[0]
                                ? backgroundColor2
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: MaterialButton(
                            child: Text(
                              'Name',
                              style: TextStyle(
                                  color: selectedMethod[0]
                                      ? backgroundColor1
                                      : textColor1),
                            ),
                            onPressed: () {
                              changeSearchMethod(0);
                            },
                          ),
                        ),
                        Container(
                          height: 35,
                          decoration: BoxDecoration(
                            color: selectedMethod[1]
                                ? backgroundColor2
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: MaterialButton(
                            child: Text(
                              'Email',
                              style: TextStyle(
                                  color: selectedMethod[1]
                                      ? backgroundColor1
                                      : textColor1),
                            ),
                            onPressed: () {
                              changeSearchMethod(1);
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  isSearching
                      ? Expanded(child: searchList())
                      : Expanded(child: recentSearchTiles())
                ],
              ),
            ),
          );
  }
}
