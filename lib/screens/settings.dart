
import 'package:flutter/material.dart';
import 'package:never_lost/components/custom_appbar.dart';
import 'package:never_lost/constants.dart';
import 'package:never_lost/firebase/auth.dart';
import 'package:never_lost/firebase/database.dart';
import 'package:never_lost/firebase/hive.dart';
import 'package:never_lost/screens/signin.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';

class Setting extends StatefulWidget {
  final Map<String, dynamic> user;

  const Setting({required this.user, Key? key}) : super(key: key);

  @override
  _SettingState createState() => _SettingState();
}

class _SettingState extends State<Setting> {
  TextEditingController phoneController = TextEditingController();
  TextEditingController statusController = TextEditingController();

  @override
  void initState() {
    phoneController.text = widget.user['phone'];
    statusController.text = widget.user['status'];
    super.initState();
  }

  void showPhoto(height, width) {
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
                            image: NetworkImage(widget.user['photoURL']),
                            fit: BoxFit.fitWidth)),
                  ),
                ]),
          );
        });
  }

  void changePhoneNumber() {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            backgroundColor: backgroundColor1,
            title: const Text('Phone Number',
                style: TextStyle(color: themeColor2)),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('Cancel',
                      style: TextStyle(color: textColor1))),
              TextButton(
                  onPressed: () {
                    var userData = widget.user;
                    userData['phone'] = phoneController.text;
                    HiveDB().updateUserData(userData);
                    DatabaseMethods().updateUserDatabase(userData).then((v){
                      Navigator.pop(context);
                    });
                    
                  },
                  child:
                      const Text('Save', style: TextStyle(color: backgroundColor2))),
            ],
            content: Container(
              decoration: const BoxDecoration(border: Border(bottom: BorderSide(width: 2, color: textColor1))),
              child: TextField(
                maxLength: 10,
                controller: phoneController,
                style: const TextStyle(color: textColor1),
                decoration:
                    const InputDecoration(border: InputBorder.none, helperStyle: TextStyle(color: textColor1)),
              ),
            ),
          );
        });
  }

  void changeStatus() {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            backgroundColor: backgroundColor1,
            title: const Text('Status',
                style: TextStyle(color: themeColor2)),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('Cancel',
                      style: TextStyle(color: textColor1))),
              TextButton(
                  onPressed: () {
                    var userData = widget.user;
                    userData['status'] = statusController.text;
                    HiveDB().updateUserData(userData);
                    DatabaseMethods().updateUserDatabase(userData).then((v){
                      Navigator.pop(context);
                    });
                    
                  },
                  child:
                      const Text('Save', style: TextStyle(color: backgroundColor2))),
            ],
            content: Container(
              decoration: const BoxDecoration(border: Border(bottom: BorderSide(width: 2, color: textColor1))),
              child: TextField(
                minLines: 1,
                maxLines: 5,
                maxLength: 139,
                controller: statusController,
                style: const TextStyle(color: textColor1),
                decoration:
                    const InputDecoration(border: InputBorder.none, helperStyle: TextStyle(color: textColor1)),
              ),
            ),
          );
        });
  }


  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: backgroundColor2,
      appBar: AppBar(
        // shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        backgroundColor: backgroundColor1,
        elevation: 0,
        title: Text('Profile'),
        actions: [
          TextButton.icon(
              onPressed: () {
                AuthMethods().signout().then((value) {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => const Signin()),
                    (route) => false
                  );
                });
              },
              icon: const Icon(
                Icons.logout,
                color: backgroundColor2,
              ),
              label: const Text(
                'Signout',
                style: TextStyle(color: backgroundColor2),
              ))
        ],
      ),
      body: SizedBox(
        height: height,
        width: width,
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.only(bottom: 24),
              decoration: BoxDecoration(
                color: backgroundColor1,
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(15))
              ),
              width: width,
              
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: GestureDetector(
                      onTap: () {
                        showPhoto(height, width);
                      },
                      child: Container(
                        height: width / 3,
                        width: width / 3,
                        decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            image: DecorationImage(
                                image: NetworkImage(widget.user['photoURL']),
                                fit: BoxFit.fitWidth)),
                      ),
                    ),
                  ),
                  Text(
                    widget.user['name'],
                    style: const TextStyle(
                        color: backgroundColor2,
                        fontSize: 24,
                        fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 50,
            ),
            ListTile(
              leading: const Icon(
                Icons.email_outlined,
                color: textColor1,
              ),
              title: const Padding(
                padding: EdgeInsets.symmetric(vertical: 4),
                child: Text(
                  'Email',
                  style: TextStyle(
                      color: textColor1,
                      fontSize: 16,
                      fontWeight: FontWeight.w400),
                ),
              ),
              subtitle: Text(
                widget.user['email'],
                style: const TextStyle(
                    color: textColor2,
                    fontSize: 16,
                    fontWeight: FontWeight.w400),
              ),
            ),
            ListTile(
              onTap: () {
                changePhoneNumber();
              },
              leading: const Icon(
                Icons.call,
                color: textColor1,
              ),
              title: const Padding(
                padding: EdgeInsets.symmetric(vertical: 4.0),
                child: Text(
                  'Phone',
                  style: TextStyle(
                      color: textColor1,
                      fontSize: 16,
                      fontWeight: FontWeight.w400),
                ),
              ),
              subtitle: Text(
                widget.user['phone'],
                style: const TextStyle(
                    color: textColor2,
                    fontSize: 16,
                    fontWeight: FontWeight.w400),
              ),
              trailing: const Icon(
                Icons.edit,
                color: textColor1,
              ),
            ),
            ListTile(
              onTap: () {
                changeStatus();
              },
              leading: const Icon(
                Icons.insert_emoticon,
                color: textColor1,
              ),
              title: const Padding(
                padding: EdgeInsets.symmetric(vertical: 4.0),
                child: Text(
                  'Status',
                  style: TextStyle(
                      color: textColor1,
                      fontSize: 16,
                      fontWeight: FontWeight.w400),
                ),
              ),
              subtitle: Text(
                widget.user['status'],
                style: const TextStyle(
                    color: textColor2,
                    fontSize: 16,
                    fontWeight: FontWeight.w400),
              ),
              trailing: const Icon(
                Icons.edit,
                color: textColor1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
