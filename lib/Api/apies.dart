import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:untitled2/models/chat_user.dart';

class APIs {
  //for authentication
  static FirebaseAuth auth = FirebaseAuth.instance;


  //for accessing cloud firestore data base
  static FirebaseFirestore firestore = FirebaseFirestore.instance;
//for storing self information
  static late ChatUser me;
  //to return current user
  static User get user => auth.currentUser!;

  //for checking if user exist or not
  static Future<bool> userExists() async {
    return (await firestore.collection('User').doc(user.uid).get()).exists;
  }


  //for getting current user info
  static Future<void> getSelfInfo() async {
     (await firestore.collection('User').doc(user.uid).get().then( (user) async {
       if(user.exists){
me=ChatUser.fromJson(user.data()!);
       }
       else{
         await createUser().then((value)=> getSelfInfo());
       }
     }));
  }

  //for creating a new user
  static Future<void> createUser() async {
    final time = DateTime.now().millisecondsSinceEpoch.toString();
    final chatUser = ChatUser(
      image: user.photoURL.toString(),
      about: 'Hey Im using zeechat',
      name: user.displayName.toString(),
      createdAt: time,
      lastActive: time,
      isOnline: false,
      id: user.uid,
      email: user.email.toString(),
      pushToken: '',
    );
    return (await firestore.collection('User').doc(user.uid).set(chatUser.toJson()));
  }
  ///for getting all user from firestore data base
  static  Stream <QuerySnapshot<Map<String,dynamic>>>getAllUsers(){
    return firestore.collection('User').where('id', isNotEqualTo: user.uid).snapshots();
  }
 ///for updating user info
  static Future<void> updateUserInfo() async {
     (await firestore.collection('User').doc(user.uid).update({'name': me.name, 'about':me.about,'image':me.image}));
  }
}
