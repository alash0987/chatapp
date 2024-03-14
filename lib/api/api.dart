import 'dart:convert';
import 'dart:io';
import 'package:chatapp/cores/snackbars/snackbar.dart';
import 'package:chatapp/models/chat_user.dart';
import 'package:chatapp/models/message.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Apis {
  static FirebaseAuth auth = FirebaseAuth.instance;
  static FirebaseFirestore firestore = FirebaseFirestore.instance;
  static FirebaseStorage storage = FirebaseStorage.instance;
  static User? get _currentUser => auth.currentUser;
  static User? get user => _currentUser;
  //  User cannot be null

  static Future<bool> userExists() async {
    try {
      final DocumentSnapshot doc =
          await firestore.collection('users').doc(auth.currentUser!.uid).get();
      print('${doc.exists}==============');
      if (doc.exists) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      rethrow;
    }
  }

  //  For adding an chat user for our conversation
  static Future<bool> addChatUser(String email) async {
    final data = await firestore
        .collection('users')
        .where('email', isEqualTo: email)
        .get();
    if (data.docs.isNotEmpty && data.docs.first.id != user!.uid) {
      // final chatUser = ChatUser.fromJson(data.docs.first.data());
      // await firestore
      //     .collection('chats/${getConversationId(chatUser.id)}/users')
      //     .doc(chatUser.id)
      //     .set(chatUser.toJson());
      firestore
          .collection('users')
          .doc(user!.uid)
          .collection('my_users')
          .doc(data.docs.first.id)
          .set({});
      return true;
    } else {
      return false;
    }
  }

  //  Storing Logged in user data
  static late ChatUser me;
  static late ChatUser allUser;

  static Future<void> getMe() async {
    try {
      if (FirebaseAuth.instance.currentUser != null) {
        await firestore
            .collection('users')
            .doc(user?.uid)
            .get()
            .then((user) async {
          if (user.exists) {
            me = ChatUser.fromJson(user.data()!);
            await getFirebaseMessagingToken();
            //  For setting active status to true
            Apis.updateActiveStatus(true);
          } else {
            await createUser().then((createuser) {
              getMe();
            });
          }
        });
      }
    } catch (e) {
      rethrow;
    }
  }

  //  For push notification
  static FirebaseMessaging fmessaging = FirebaseMessaging.instance;
  //  For geting Firebase message Token
  static Future<void> getFirebaseMessagingToken() async {
    await fmessaging.requestPermission();
    fmessaging.getToken().then((token) {
      if (token != null) {
        me.pushToken = token;
        debugPrint('Token: $token');
      }
    }

        // FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        //   debugPrint('Got a message whilst in the foreground!');
        //   debugPrint('Message data: ${message.data}');

        //   if (message.notification != null) {
        //     debugPrint(
        //         'Message also contained a notification: ${message.notification}');
        //   }
        // }
        );
  }

  //  For sending push notification
  static Future<void> sendPushNotification(
      ChatUser chatUser, String msg) async {
    try {
      final body = {
        "to": chatUser.pushToken,
        "notification": {
          "title": chatUser.name,
          "body": msg,
          "android_channel_id": "yourchannelid",
        },
        "data": {
          "some_data": "userid :${me.id}",
        }
      };
      // var url = Uri.https('example.com', 'whatsit/create');
      var response =
          await http.post(Uri.parse('https://fcm.googleapis.com/fcm/send'),
              headers: {
                HttpHeaders.contentTypeHeader: 'application/json',
                HttpHeaders.authorizationHeader:
                    'key=AAAAWwNFZl0:APA91bHbHTARcmr_TIIqlhNbfCp0xlnf_VftylfWv1DvzhEWA8Pv6kV2lFvPPGDhRLYb2PGw-Z2DJzoK3HoIkNoW_vwrtJF8eRUZigk3eNbPn0BDjBKHPCtJaxvIPWnk63HpgX1v9D82'
              },
              body: jsonEncode(body));
      debugPrint('Response status: ${response.statusCode}');
      debugPrint('Response body: ${response.body}');
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  //  For geting id of known users  from firebase firestore
  static Stream<QuerySnapshot<Map<String, dynamic>>> getMyUserId() {
    if (user == null) {
      // Handle null user case, maybe return a default stream or throw an error.
      // Example:
      throw Exception('User is null. Please sign in.');
    }
    // Assuming `user` is from Firebase Authentication.
    if (!FirebaseAuth.instance.currentUser!.uid.isNotEmpty) {
      throw Exception('User is not authenticated. Please sign in.');
    }
    return firestore
        .collection('users')
        .doc(user!.uid)
        .collection('my_users')
        .snapshots();
  }

  //  get all user from firestore
  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllUser(
      List<String> userIds) {
    return firestore
        .collection('users')
        .where('id', whereIn: userIds)
        // .where('id', isNotEqualTo: user!.uid)
        .snapshots();
  }

  //  For adding an user to my_users  when first message is send
  static Future<void> sendFirstMessage(
      ChatUser chatUser, String msg, Type type) async {
    await firestore
        .collection('users')
        .doc(chatUser.id)
        .collection('my_users')
        .doc(user!.uid)
        .set({}).then((value) async => await sendMessage(chatUser, msg, type));
  }

  //  Get all messages of a specific conversation from firestore
  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllUserMessage() {
    return firestore.collection('messages').snapshots();
  }

  //  Useful for geting conversation id
  static String getConversationId(String id) =>
      user!.uid.hashCode <= id.hashCode
          ? '${user!.uid}_$id'
          : '${id}_${user!.uid}';

  //  for geting al messages of a specific conversation from firebase database
  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllMessage(
      ChatUser user) {
    return firestore
        .collection('chats/${getConversationId(user.id)}/messages')
        .orderBy('sent', descending: true)
        .snapshots();
  }

  //  for sending message to firebase database
  static Future<void> sendMessage(ChatUser user, String msg, Type type) async {
    final time = DateTime.now().millisecondsSinceEpoch.toString();
    final Message message = Message(
        msg: msg,
        toId: user.id,
        read: '',
        type: type,
        sent: time,
        fromId: Apis.user!.uid);
    final ref =
        firestore.collection('chats/${getConversationId(user.id)}/messages');
    await ref.doc(time).set(message.toJson()).then((value) =>
        sendPushNotification(user, type == Type.text ? msg : 'image'));
  }

  //  Get User Info
  static Stream<QuerySnapshot<Map<String, dynamic>>> getUserInfo(
      ChatUser chatUser) {
    return firestore
        .collection('users')
        .where('id', isEqualTo: chatUser.id)
        .snapshots();
  }

  //  Update Active status
  static Future<void> updateActiveStatus(bool isOnline) async {
    try {
      firestore.collection('users').doc(user?.uid).update({
        'is_online': isOnline,
        'last_active': DateTime.now().millisecondsSinceEpoch.toString(),
        'push_token': me.pushToken
      });
    } catch (e) {
      rethrow;
    }
  }

  //  Adding user to firestore
  static Future<void> createUser() async {
    final time = DateTime.now().millisecondsSinceEpoch.toString();
    try {
      final chatuser = ChatUser(
          image: user!.photoURL.toString(),
          about: "Hey, I'm using lumbiniApp",
          name: user!.displayName.toString(),
          createdAt: time,
          lastActive: time,
          id: user!.uid,
          isOnline: false,
          pushToken: '',
          email: user!.email.toString());
      await firestore.collection('users').doc(user!.uid).set(
            chatuser.toJson(),
          );
    } catch (e) {
      rethrow;
    }
  }
  //  update user to firestore

  static Future<void> updateMe(BuildContext context) async {
    try {
      await firestore.collection('users').doc(user!.uid).update({
        'name': me.name,
        'about': me.about,
      }).then((value) => SnackbarDialog.showSnackbar(context, 'Updated'));
    } catch (e) {
      rethrow;
    }
  }

  static Future<void> updateProfilePicture(File file) async {
    final ext = file.path.split('.').last;
    final ref = storage.ref().child('profile_pictures/${user!.uid}.$ext');
    await ref
        .putFile(file, SettableMetadata(contentType: 'image/$ext'))
        .then((p0) => null);
    me.image = await ref.getDownloadURL();
    await firestore.collection('users').doc(user!.uid).update({
      'image': me.image,
    });
  }

  //  Update msg read status
  static Future<void> updateMessageReadStatus(
      Message message, BuildContext context) async {
    var date = DateTime.now().millisecondsSinceEpoch.toString();
    firestore
        .collection('chats/${getConversationId(message.fromId)}/messages')
        .doc(message.sent)
        .update({
      'read': date,
    });
  }

  //  Get last message of a specific conversation
  static Stream<QuerySnapshot<Map<String, dynamic>>> getLastMessage(
      ChatUser user) {
    return firestore
        .collection('chats/${getConversationId(user.id)}/messages')
        .orderBy('sent', descending: true)
        .limit(1)
        .snapshots();
  }

  //  send chat image
  static Future<void> sendChatImage(ChatUser chatUser, File file) async {
    final ext = file.path.split('.').last;
    final ref = storage.ref().child(
        'images/${getConversationId(chatUser.id)}/${DateTime.now().millisecondsSinceEpoch}.$ext');
    // Uploading images to firebase storage
    await ref
        .putFile(file, SettableMetadata(contentType: 'image/$ext'))
        .then((p0) {
      debugPrint('Total bytes transferred: ${p0.totalBytes}');
    });
    //  For updating image  in firestore database
    final imageUrl = await ref.getDownloadURL();
    await sendMessage(chatUser, imageUrl, Type.image);
  }

  //  To delete a messages
  static Future<void> deleteMessage(Message message) async {
    await firestore
        .collection('chats/${getConversationId(message.toId)}/messages')
        .doc(message.sent)
        .delete();
    if (message.type == Type.image) {
      await storage.refFromURL(message.msg).delete();
    }
  }

  //  To Update a messages
  static Future<void> updateMessage(
      Message message, String updatedMessage) async {
    await firestore
        .collection('chats/${getConversationId(message.toId)}/messages')
        .doc(message.sent)
        .update({"msg": updatedMessage});
  }
}
