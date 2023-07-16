// ignore_for_file: must_be_immutable

import 'package:chatapp/features/pages/view_profile_screen.dart';
import 'package:chatapp/models/chat_user.dart';
import 'package:flutter/material.dart';

class ProfileDialog extends StatelessWidget {
  ChatUser chatUser;

  ProfileDialog({super.key, required this.chatUser});

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        content: SizedBox(
          height: size.height * 0.3,
          width: size.width * 0.8,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    chatUser.name,
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  InkWell(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) =>
                                  ViewProfileScreen(chatUser: chatUser)));
                    },
                    child: const Icon(
                      Icons.info_outline_rounded,
                      color: Colors.blue,
                    ),
                  )
                ],
              ),
              CircleAvatar(
                radius: size.height * 0.05,
                backgroundImage: NetworkImage(chatUser.image),
              ),
              Text(
                chatUser.email,
                style:
                    const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ));
  }
}
