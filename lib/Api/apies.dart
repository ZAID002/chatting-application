import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart';
import 'package:untitled2/models/chat_user.dart';
import 'package:untitled2/models/message.dart';

class APIs {
  ///for authentication
  static FirebaseAuth auth = FirebaseAuth.instance;

  ///for accessing cloud firestore data base
  static FirebaseFirestore firestore = FirebaseFirestore.instance;

  ///for storing self information
  static late ChatUser me;

  ///to return current user
  static User get user => auth.currentUser!;

  ///for firebase push notification
  static FirebaseMessaging fMessaging = FirebaseMessaging.instance;

  ///FOR getting firebase push notifications
  static Future<void> getFirebaseMessagingToken() async {
    await fMessaging.requestPermission();
    await fMessaging.getToken().then((t) {
      if (t != null) {
        me.pushToken = t;
        ("Push Token: $t");
        log("push token $t");
      }
    });
  }
/// for sending push notifications
  static Future<void> sendPushNotification(ChatUser chatUser, String msg) async {
    try {
      final response = await post(
        Uri.parse('https://server-zeechat.onrender.com/send-notification'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'token': chatUser.pushToken,
          'title': me.name,
          'body': msg,
        }),
      );

      log('Response status: ${response.statusCode}');
      log('Response body: ${response.body}');
    } catch (e) {
      log('\nsendPushNotification Error: $e');
    }
  }
  ///for checking if user exist or not
  static Future<bool> userExists() async {
    return (await firestore.collection('User').doc(user.uid).get()).exists;
  }

  //for getting current user info
  static Future<void> getSelfInfo() async {
    (await firestore.collection('User').doc(user.uid).get().then((user) async {
      if (user.exists) {
        me = ChatUser.fromJson(user.data()!);
        await getFirebaseMessagingToken();

        ///for setting user status to active
        APIs.updateActiveStatus(true);
      } else {
        await createUser().then((value) => getSelfInfo());
      }
    }));
  }

  ///for creating a new user
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
    return (await firestore
        .collection('User')
        .doc(user.uid)
        .set(chatUser.toJson()));
  }

  ///for getting all user from firestore data base
  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllUsers() {
    return firestore
        .collection('User')
        .where('id', isNotEqualTo: user.uid)
        .snapshots();
  }

  ///for updating user info
  static Future<void> updateUserInfo() async {
    (await firestore.collection('User').doc(user.uid).update({
      'name': me.name,
      'about': me.about,
      'image': me.image,
    }));
  }

  ///for geting spcific user info
  static Stream<QuerySnapshot<Map<String, dynamic>>> getUserInfo(
    ChatUser chatUser,
  ) {
    return firestore
        .collection('User')
        .where('id', isEqualTo: chatUser.id)
        .snapshots();
  }

  ///update online status or last active time
  static Future<void> updateActiveStatus(bool isOnline) async {
    await firestore.collection('User').doc(user.uid).update({
      'is_online': isOnline,
      'last_active': DateTime.now().millisecondsSinceEpoch.toString(),
      'push_token': me.pushToken,
    });
  }

  ///***************************** chat screen related apis ******************************
  //useful fir getting conversation id:
  // Generates a consistent conversation ID by comparing
  // the UIDs of both users to maintain a fixed order.
  static String getConversationID(String id) {
    // compareTo alphabetically compare karta hai, jo hamesha stable rehta hai
    if (user.uid.compareTo(id) <= 0) {
      return '${user.uid}_$id';
    } else {
      return '${id}_${user.uid}';
    }
  }

  ///for getting all messages for specific conversation from firestore database
  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllMessages(
    ChatUser user,
  ) {
    return firestore
        .collection('chats/${getConversationID(user.id)}/messages')
        .orderBy('sent', descending: true)
        .snapshots();
  }

  ///for sending message
  static Future<void> sendMessage(
    ChatUser chatUser,
    String msg, {
    required Type msgType,
  }) async {
    ///message sending time also use as a id
    final time = DateTime.now().millisecondsSinceEpoch.toString();

    /// message to send
    final Message message = Message(
      msg: msg,
      toId: chatUser.id,
      read: '',
      type: msgType,
      fromId: user.uid,
      sent: time,
    );
    final ref = firestore.collection(
      'chats/${getConversationID(chatUser.id)}/messages',
    );
    await ref.doc(time).set(message.toJson());
    await sendPushNotification(chatUser, msgType == Type.text ? msg : 'image');
  }

  //chats collection --> conversation_id (doc) --> messages (collection) --> message (doc)

  ///update read message of status
  static Future<void> updateMessageReadStatus(Message message) async {
    await firestore
        .collection('chats/${getConversationID(message.fromId)}/messages')
        .doc(message.sent)
        .set({
          'read': DateTime.now().millisecondsSinceEpoch.toString(),
        }, SetOptions(merge: true));
  }

  //get only a last message of a specific chat
  static Stream<QuerySnapshot<Map<String, dynamic>>> getLastMessages(
    ChatUser user,
  ) {
    return firestore
        .collection('chats/${getConversationID(user.id)}/messages')
        .limit(1)
        .orderBy('sent', descending: true)
        .snapshots();
  }
}
