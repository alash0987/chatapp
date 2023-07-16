// ignore_for_file: must_be_immutable, no_leading_underscores_for_local_identifiers
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chatapp/api/api.dart';
import 'package:chatapp/cores/helper/my_date_util.dart';
import 'package:chatapp/features/auth/presentation/provider/show_emoji_provider.dart';
import 'package:chatapp/features/pages/view_profile_screen.dart';
import 'package:chatapp/features/widgets/message_card.dart';
import 'package:chatapp/models/chat_user.dart';
import 'package:chatapp/models/message.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class ChatScreen extends StatelessWidget {
  ChatScreen({super.key, required this.chatUser});
  ChatUser? chatUser;

  //  For storing all user message
  List<Message> _list = [];

  final TextEditingController _msgController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: SafeArea(
        child: WillPopScope(
          onWillPop: () {
            Provider.of<ShowEmojiProvider>(context, listen: false);
            if (context.read<ShowEmojiProvider>().isShowEmoji) {
              context.read<ShowEmojiProvider>().showEmoji();
              return Future.value(false);
            } else {
              return Future.value(true);
            }
          },
          child: Scaffold(
            appBar: AppBar(
              automaticallyImplyLeading: false,
              flexibleSpace: _appBar(context),
            ),
            backgroundColor: Colors.blue[100],
            body: Consumer<ShowEmojiProvider>(
                builder: (context, valueEmoji, index) {
              return Column(
                children: [
                  Expanded(
                    child: StreamBuilder(
                      stream: Apis.getAllMessage(chatUser!),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(child: SizedBox());
                        }
                        if (snapshot.hasError) {
                          return const Center(
                              child: Text('Something went wrong'));
                        }
                        final data = snapshot.data?.docs;
                        _list = data
                                ?.map((e) => Message.fromJson(e.data()))
                                .toList() ??
                            [];
                        if (snapshot.hasData) {
                          if (_list.isNotEmpty) {
                            return ListView.builder(
                              reverse: true,
                              physics: const BouncingScrollPhysics(),
                              itemCount: _list.length,
                              itemBuilder: (context, index) {
                                return MessageCard(
                                  message: _list[index],
                                );
                              },
                            );
                          } else {
                            return const Center(
                              child: Text(
                                'No Message Found',
                                style: TextStyle(fontSize: 20),
                              ),
                            );
                          }
                        }
                        return const Center(
                          child: Text(
                            'Say Hi, 👋',
                            style: TextStyle(fontSize: 20),
                          ),
                        );
                      },
                    ),
                  ),
                  valueEmoji.isUploading
                      ? const LinearProgressIndicator()
                      : const SizedBox(),
                  _chatInput(context),
                  Consumer<ShowEmojiProvider>(builder: (context, value, index) {
                    return value.isShowEmoji
                        ? SizedBox(
                            height: size.height * .35,
                            child: EmojiPicker(
                              textEditingController: _msgController,
                              config: Config(
                                bgColor: Colors.blue[100]!,
                                columns: 10,
                                emojiSizeMax:
                                    32 * (Platform.isIOS ? 1.30 : 1.0),
                              ),
                            ),
                          )
                        : const SizedBox(
                            height: 0,
                          );
                  })
                ],
              );
            }),
          ),
        ),
      ),
    );
  }

  Widget _appBar(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return InkWell(
        onTap: () => {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => ViewProfileScreen(
                            chatUser: chatUser!,
                          )))
            },
        child: StreamBuilder(
          stream: Apis.getUserInfo(chatUser!),
          builder: (context, snapshot) {
            final _data = snapshot.data?.docs;
            final _list =
                _data?.map((e) => ChatUser.fromJson(e.data())).toList() ?? [];

            return Row(
              children: [
                IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(
                      Icons.arrow_back,
                      color: Colors.black54,
                    )),
                ClipRRect(
                  borderRadius: BorderRadius.circular(50),
                  child: CachedNetworkImage(
                    fit: BoxFit.cover,
                    height: size.height * 0.05,
                    width: size.height * 0.05,
                    imageUrl:
                        _list.isNotEmpty ? _list[0].image : chatUser!.image,
                    placeholder: (context, url) =>
                        const CircularProgressIndicator(),
                    errorWidget: (context, url, error) =>
                        const CircularProgressIndicator(),
                  ),
                ),
                const SizedBox(
                  width: 10,
                ),
                //  Username and last seen
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _list.isNotEmpty ? _list[0].name : chatUser!.name,
                      style: const TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                          fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(
                      height: 4,
                    ),
                    Text(
                      _list.isNotEmpty
                          ? _list[0].isOnline
                              ? 'Online'
                              : MyDateUtil.getLastActiveTime(
                                  context: context,
                                  lastActive: _list[0].lastActive)
                          : MyDateUtil.getLastActiveTime(
                              context: context,
                              lastActive: chatUser!.lastActive),
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.white,
                      ),
                    ),
                    // Text(widget.chatUser!.email),
                  ],
                )
              ],
            );
          },
        ));
  }

  Widget _chatInput(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Padding(
      padding: EdgeInsets.symmetric(
          horizontal: size.width * 0.02, vertical: size.height * 0.01),
      child: Consumer<ShowEmojiProvider>(builder: (context, btn, index) {
        return Row(
          children: [
            Expanded(
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0),
                ),
                child: Row(
                  children: [
                    //  This is an emoji icon button
                    IconButton(
                        onPressed: () => {
                              FocusScope.of(context).unfocus(),
                              btn.showEmoji(),
                              debugPrint(
                                  'Emoji button pressed: ${btn.isShowEmoji}'),
                            },
                        icon: const Icon(
                          Icons.emoji_emotions_outlined,
                          color: Colors.black54,
                        )),
                    //  For showing input field
                    Expanded(
                        child: TextField(
                      onTap: () {
                        btn.isShowEmoji ? btn.showEmoji() : null;
                      },
                      controller: _msgController,
                      keyboardType: TextInputType.multiline,
                      minLines: 1,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        hintText: 'Type a message',
                        hintStyle: TextStyle(color: Colors.blueAccent),
                        border: InputBorder.none,
                      ),
                    )),

                    //  pick image from gallery
                    IconButton(
                        onPressed: () async {
                          final picker = ImagePicker();

                          final List<XFile?> images =
                              await picker.pickMultiImage(imageQuality: 100);
                          for (var i in images) {
                            if (i != null) {
                              btn.isUploadingFunction();
                              await Apis.sendChatImage(chatUser!, File(i.path));
                              btn.isUploadingFunction();
                            }
                          }
                        },
                        icon: const Icon(
                          Icons.image,
                          color: Colors.black54,
                          size: 26,
                        )),
                    //  pick image from Camera
                    IconButton(
                        onPressed: () async {
                          final picker = ImagePicker();
                          final XFile? image = await picker.pickImage(
                              source: ImageSource.camera);
                          if (image != null) {
                            btn.isUploadingFunction();
                            await Apis.sendChatImage(
                                chatUser!, File(image.path));
                            btn.isUploadingFunction();
                            // Navigator.pop(context);
                          }
                        },
                        icon: const Icon(
                          Icons.camera_alt_outlined,
                          color: Colors.black54,
                          size: 26,
                        )),
                    SizedBox(
                      width: size.width * .02,
                    )
                  ],
                ),
              ),
            ),
            //  send message button
            MaterialButton(
                // padding: const EdgeInsets.only(
                //     top: 10, bottom: 10, right: 5, left: 10),
                shape: const CircleBorder(),
                color: Colors.green,
                onPressed: () {},
                child: IconButton(
                  onPressed: () {
                    if (_msgController.text.isNotEmpty) {
                      if (_list.isEmpty) {
                        //  on first message add chat user to my_users collection of chat user
                        Apis.sendFirstMessage(
                            chatUser!,
                            _msgController.text.split('\n').join(' '),
                            Type.text);
                      } else {
                        Apis.sendMessage(
                            chatUser!,
                            _msgController.text.split('\n').join(' '),
                            Type.text);
                      }

                      _msgController.clear();
                    }
                  },
                  icon: const Icon(Icons.send),
                  color: Colors.white,
                  iconSize: 28,
                )),
          ],
        );
      }),
    );
  }
}
