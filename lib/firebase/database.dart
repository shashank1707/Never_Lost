
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:never_lost/firebase/hive.dart';

class DatabaseMethods {
  final firestore = FirebaseFirestore.instance;

  createUserDatabase(name, email, uid, photoURL, phone) async {

    Map<String, dynamic> user = {
      "name": name.toUpperCase(),
      "email": email.toLowerCase(),
      "uid": uid,
      "photoURL": photoURL,
      "status": "I was a TRACTOR!",
      "phone": phone ?? '-',
      "recentSearchList": [],
      "friendList": [],
      "pendingRequestList": [],
      'latitude': 0.0,
      'longitude': 0.0,
    };
    await findUserWithEmail(email).then((value) async {
      if(value.isEmpty){
        await firestore.collection('users').doc(uid).set(user);
      }else{
        user = value;
      }
    });

    return user;

  }

  findUserWithEmail(email) async {
    var user = {};
    await firestore.collection('users').where('email', isEqualTo: email).get().then((value){
      if(value.docs.isNotEmpty){
        user = value.docs[0].data();
      }
    });
    return user;
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> findUserWithUID(uid) async {
    return await firestore.collection('users').doc(uid).get();
  }

  updateUserDatabase(userData) async {
    await firestore.collection('users').doc(userData['uid']).update(userData);
  }

  Future<Stream<QuerySnapshot>> searchByName(name) async {
    return firestore.collection('users').where('name', isEqualTo: name.toUpperCase()).snapshots();
  }
  Stream<QuerySnapshot> searchByEmail(email) {
    return firestore.collection('users').where('email', isEqualTo: email.toLowerCase()).snapshots();
  }
  Future<Stream<QuerySnapshot>> searchByPhone(phone) async {
    return firestore.collection('users').where('phone', isEqualTo: phone).snapshots();
  }

  Stream<DocumentSnapshot> getUserSnapshots(uid) {
    return firestore.collection('users').doc(uid).snapshots();
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> findChatRoom(chatRoomID) async {
    return await firestore.collection('chatRooms').doc(chatRoomID).get();
  }

  createChatRoom(chatRoomID, user1, user2) async {
    Map<String, dynamic> chatRoomInfo = {
      'lastMessage': "Started a ChatRoom",
      'sender': user1,
      'receiver': user2,
      'seen': false,
      'timestamp': DateTime.now(),
      'users': [user1, user2],
    };

    await findChatRoom(chatRoomID).then((value)async {
      if(!value.exists){
        await firestore.collection('chatRooms').doc(chatRoomID).set(chatRoomInfo);
      } 
    });


  }

  addMessage(chatRoomID , messageInfo, lastMessageInfo) async {
    await firestore.collection('chatRooms').doc(chatRoomID).collection('chats').doc().set(messageInfo);

    await firestore.collection('chatRooms').doc(chatRoomID).update(lastMessageInfo);
  }

  Future<Stream<QuerySnapshot<Map<String, dynamic>>>> getMessages(chatRoomID) async {
    return firestore.collection('chatRooms').doc(chatRoomID).collection('chats').orderBy('timestamp', descending: true).snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getUnseenMessages(chatRoomID, email){
    return firestore.collection('chatRooms').doc(chatRoomID).collection('chats').where('seen', isEqualTo: false).where('receiver', isEqualTo: email).snapshots();
  }

  updateSeenInfo(chatRoomID, messageID) async {
    await firestore.collection('chatRooms').doc(chatRoomID).collection('chats').doc(messageID).update({'seen': true});
  }

  Future<Stream<QuerySnapshot<Map<String, dynamic>>>> getChats(email) async {
    return firestore.collection('chatRooms').where('users', arrayContains: email).orderBy('timestamp', descending: true).snapshots();
  }

}