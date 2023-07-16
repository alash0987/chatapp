// ignore_for_file: use_build_context_synchronously

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chatapp/api/api.dart';
import 'package:chatapp/cores/helper/my_date_util.dart';
import 'package:chatapp/cores/snackbars/snackbar.dart';
import 'package:chatapp/features/widgets/image_screen.dart';
import 'package:chatapp/models/message.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gallery_saver/gallery_saver.dart';

class MessageCard extends StatelessWidget {
  const MessageCard({super.key, required this.message});
  final Message message;

  @override
  Widget build(BuildContext context) {
    bool isMe = Apis.user!.uid == message.fromId;
    return InkWell(
      onLongPress: () {
        _showBottomSheet(context, message, isMe);
      },
      child: isMe ? _greenMessage(context) : _blueMessage(context),
    );
  }

  //  sender or another user message card
  Widget _blueMessage(BuildContext context) {
    if (message.read.isEmpty) {
      Apis.updateMessageReadStatus(message, context);
    }
    Size size = MediaQuery.of(context).size;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Container(
            decoration: BoxDecoration(
              border: message.type == Type.text
                  ? Border.all(color: Colors.blue[600]!)
                  : null,
              color: Colors.black.withOpacity(.8),
              borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                  bottomRight: Radius.circular(20)),
            ),
            padding: EdgeInsets.all(message.type == Type.image
                ? size.width * 0.005
                : size.width * 0.03),
            margin: EdgeInsets.symmetric(
                horizontal: size.width * 0.04, vertical: size.height * 0.01),
            child: message.type == Type.text
                ? Text(
                    message.msg,
                    style: const TextStyle(fontSize: 17, color: Colors.white),
                  )
                : GestureDetector(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) =>
                                  ImageScreen(message: message.msg)));
                    },
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(size.height * .03),
                      child: CachedNetworkImage(
                        // width: size.height * .05,
                        // height: size.height * .05,
                        imageUrl: message.msg,
                        placeholder: (context, url) => SizedBox(
                            width: size.height * .05,
                            height: size.height * .05,
                            child: const Center(
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )),
                        errorWidget: (context, url, error) =>
                            const Icon(Icons.person),
                      ),
                    ),
                  ),
          ),
        ),
        Row(
          children: [
            if (message.read.isNotEmpty)
              Icon(
                Icons.done_all_rounded,
                color: Colors.blue[600],
                size: 20,
              ),
            SizedBox(width: size.width * 0.02),
            //  sent time of message
            Text(
              MyDateUtil.getFormattedTime(context: context, time: message.sent),
              style: const TextStyle(fontSize: 13, color: Colors.black54),
            ),
            SizedBox(width: size.width * 0.04)
          ],
        )
      ],
    );
  }

  //  Our of user message card
  Widget _greenMessage(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Padding(
          padding: EdgeInsets.all(message.type == Type.image
              ? size.width * 0.01
              : size.width * 0.04),
          child: Text(
            MyDateUtil.getFormattedTime(context: context, time: message.sent),
            style: const TextStyle(fontSize: 13, color: Colors.black54),
          ),
        ),
        Flexible(
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.blue[600]!),
              color: Colors.blue[500],
              borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20)),
            ),
            padding: EdgeInsets.all(message.type == Type.image
                ? size.width * 0.005
                : size.width * 0.04),
            margin: EdgeInsets.symmetric(
                horizontal: size.width * 0.04, vertical: size.height * 0.01),
            child: message.type == Type.text
                ? Text(
                    message.msg,
                    style: const TextStyle(fontSize: 17, color: Colors.white),
                  )
                : GestureDetector(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) =>
                                  ImageScreen(message: message.msg)));
                    },
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(size.height * .03),
                      child: CachedNetworkImage(
                        // width: size.height * .05,
                        // height: size.height * .05,
                        imageUrl: message.msg,
                        placeholder: (context, url) => SizedBox(
                            width: size.height * .05,
                            height: size.height * .05,
                            child: const Center(
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )),
                        errorWidget: (context, url, error) =>
                            const Icon(Icons.person),
                      ),
                    ),
                  ),
          ),
        ),
      ],
    );
  }
}

//  buttom sheet for modifying msg
_showBottomSheet(BuildContext context, Message message, bool isMe) {
  Size size = MediaQuery.of(context).size;
  showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20), topRight: Radius.circular(20)),
          side: BorderSide(color: Colors.white)),
      builder: (BuildContext context2) {
        return ListView(
          shrinkWrap: true,
          children: [
            Container(
              height: 4,
              margin: EdgeInsets.symmetric(
                  vertical: size.height * 0.015, horizontal: size.width * 0.4),
              decoration: BoxDecoration(
                  color: Colors.grey, borderRadius: BorderRadius.circular(8)),
            ),

            message.type == Type.text
                ? _OptionItem(
                    icon: const Icon(
                      Icons.copy_all_rounded,
                      color: Colors.blue,
                      size: 26,
                    ),
                    name: 'Copy Text',
                    onTap: () async {
                      await Clipboard.setData(ClipboardData(text: message.msg))
                          .then((value) => {
                                Navigator.pop(context2),
                                SnackbarDialog.showSnackbar(
                                    context2, 'Text Copied')
                              });
                    })
                : _OptionItem(
                    icon: const Icon(
                      Icons.download,
                      color: Colors.blue,
                      size: 26,
                    ),
                    name: 'Save Image',
                    onTap: () async {
                      try {
                        await GallerySaver.saveImage(message.msg)
                            .then((success) => {
                                  Navigator.pop(context2),
                                  if (success != null && success)
                                    {
                                      SnackbarDialog.showSnackbar(
                                          context, 'Image Saved')
                                    }
                                });
                      } catch (e) {
                        SnackbarDialog.showSnackbar(context2, e.toString());
                      }
                    }),

            //  Seperator or divider
            if (message.type == Type.text && isMe)
              Divider(
                color: Colors.grey,
                thickness: 1,
                indent: size.width * 0.05,
                endIndent: size.width * 0.05,
              ),
            if (message.type == Type.text && isMe)
              _OptionItem(
                  icon: const Icon(
                    Icons.edit,
                    color: Colors.blue,
                    size: 26,
                  ),
                  name: 'Edit Message',
                  onTap: () {
                    //  hiding BottomSheet
                    // Navigator.pop(context);
                    _showAlertMessageUpdateDialog(context2, message);
                  }),
            //  Seperator or divider
            if (isMe)
              Divider(
                color: Colors.grey,
                thickness: 1,
                indent: size.width * 0.05,
                endIndent: size.width * 0.05,
              ),
            if (isMe)
              _OptionItem(
                  icon: const Icon(
                    Icons.delete_forever,
                    color: Colors.red,
                    size: 26,
                  ),
                  name: 'Delete Message',
                  onTap: () async {
                    await Apis.deleteMessage(message).then((value) {
                      Navigator.pop(context2);
                    });
                  }),
            //  Seperator or divider
            Divider(
              color: Colors.grey,
              thickness: 1,
              indent: size.width * 0.05,
              endIndent: size.width * 0.05,
            ),
            _OptionItem(
                icon: const Icon(
                  Icons.remove_red_eye_outlined,
                  color: Colors.blue,
                  size: 26,
                ),
                name:
                    'Sent At ${MyDateUtil.getFormattedTime(context: context2, time: message.sent)}',
                onTap: () {}),
            //  Seperator or divider
            Divider(
              color: Colors.grey,
              thickness: 1,
              indent: size.width * 0.05,
              endIndent: size.width * 0.05,
            ),
            _OptionItem(
                icon: const Icon(
                  Icons.remove_red_eye_outlined,
                  color: Colors.red,
                  size: 26,
                ),
                name: message.read.isEmpty
                    ? 'Read At Not Available'
                    : 'Read At  ${MyDateUtil.getFormattedTime(context: context2, time: message.read)}',
                onTap: () {})
          ],
        );
      });
}
//  Show alert dialog for updating message

void _showAlertMessageUpdateDialog(BuildContext context, message) {
  String updatedMsg = message.msg;
  showDialog(
      context: context,
      builder: (BuildContext context1) => AlertDialog(
            contentPadding:
                const EdgeInsets.only(left: 24, right: 24, top: 20, bottom: 10),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: const Row(
              children: [
                Icon(
                  Icons.message_outlined,
                  size: 24,
                ),
                Text('  Update Message')
              ],
            ),
            content: TextFormField(
              maxLines: null,
              onChanged: (value) => updatedMsg = value,
              initialValue: updatedMsg,
              decoration: InputDecoration(
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Colors.blue))),
            ),
            //  For button
            actions: [
              MaterialButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child:
                    const Text('Cancel', style: TextStyle(color: Colors.red)),
              ),
              MaterialButton(
                  onPressed: () async {
                    await Apis.updateMessage(message, updatedMsg);
                    Navigator.pop(context1);
                  },
                  child: const Text('Update')),
            ],
          ));
}

class _OptionItem extends StatelessWidget {
  final Icon icon;
  final String name;
  final VoidCallback onTap;
  const _OptionItem(
      {required this.icon, required this.name, required this.onTap});

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return InkWell(
      onTap: () {
        onTap();
      },
      child: Padding(
        padding: EdgeInsets.only(
          left: size.width * 0.05,
          top: size.height * 0.015,
          bottom: size.height * 0.025,
        ),
        child: Row(
          children: [
            icon,
            Flexible(
                child: Text(
              '    $name,',
              style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.black54,
                  letterSpacing: 0.5),
            ))
          ],
        ),
      ),
    );
  }
}
