// ignore_for_file: no_leading_underscores_for_local_identifiers, must_be_immutable

import 'package:chatapp/api/api.dart';
import 'package:chatapp/cores/helper/my_date_util.dart';
import 'package:chatapp/features/pages/chat_screen.dart';
import 'package:chatapp/features/widgets/dialogs/profile_dialog.dart';
import 'package:chatapp/models/chat_user.dart';
import 'package:chatapp/models/message.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class CardChatting extends StatelessWidget {
  final ChatUser? chatUser;
  //  Last message info if null then no message
  Message? _message;
  CardChatting({super.key, required this.chatUser});
  @override
  Widget build(BuildContext context) {
    late Size size = MediaQuery.of(context).size;
    return Card(
      elevation: 0.8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      margin: EdgeInsets.symmetric(
          horizontal: size.width * 0.02, vertical: size.height * 0.01),
      child: InkWell(
          onTap: () {
            // ignore: avoid_print
            // print('Card tapped.');
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => ChatScreen(
                          chatUser: chatUser,
                        )));
          },
          child: StreamBuilder(
              stream: Apis.getLastMessage(chatUser!),
              builder: (context, snapshot) {
                final _data = snapshot.data?.docs;
                final _list =
                    _data?.map((e) => Message.fromJson(e.data())).toList() ??
                        [];
                if (_list.isNotEmpty) _message = _list[0];

                return ListTile(
                  title: Text(chatUser!.name),
                  subtitle: _message?.type == Type.image
                      ? Text('${chatUser!.name} sent an image')
                      : Text(
                          maxLines: 3,
                          _message != null ? _message!.msg : 'Say Hi!',
                          style: TextStyle(
                              fontWeight: _message != null &&
                                      _message!.read.isEmpty &&
                                      _message!.fromId != Apis.user?.uid
                                  ? FontWeight.w800
                                  : FontWeight.normal,
                              color: _message != null &&
                                      _message!.read.isEmpty &&
                                      _message!.fromId != Apis.user!.uid
                                  ? Colors.black
                                  : Colors.grey.shade600),
                        ),
                  leading: InkWell(
                    onTap: () {
                      showDialog(
                          context: context,
                          builder: (_) => ProfileDialog(chatUser: chatUser!));
                    },
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(50),
                      child: CachedNetworkImage(
                        width: 50,
                        height: 50,
                        imageUrl: chatUser!.image,
                        fit: BoxFit.cover,
                        placeholder: (context, url) =>
                            const CircularProgressIndicator(),
                        errorWidget: (context, url, error) =>
                            const CircularProgressIndicator(),
                      ),
                    ),
                  ),
                  trailing: _message == null
                      ? Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                              color: Colors.green.shade400,
                              borderRadius: BorderRadius.circular(10)),
                        )
                      : _message!.read.isEmpty &&
                              _message!.fromId != Apis.user?.uid
                          ? Container(
                              height: 15,
                              width: 15,
                              decoration: BoxDecoration(
                                  color: Colors.green.shade400,
                                  borderRadius: BorderRadius.circular(10)),
                            )
                          : Text(MyDateUtil.getLastMessageTime(
                              context: context, time: _message!.sent)),
                );
              })),
    );
  }
}
