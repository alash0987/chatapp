// ignore_for_file: use_build_context_synchronously;, use_build_context_synchronously

import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chatapp/api/api.dart';
import 'package:chatapp/features/auth/presentation/provider/google_sign_in_provider.dart';

import 'package:chatapp/models/chat_user.dart';
// import 'package:chatapp/features/widgets/card_chating.dart';
// import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'package:provider/provider.dart';

// ignore: must_be_immutable
class ProfileScreen extends StatefulWidget {
  ChatUser chatUser;

  ProfileScreen({
    required this.chatUser,
    super.key,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String? _image;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return GestureDetector(
      onTap: FocusScope.of(context).unfocus,
      child: Scaffold(
          appBar: AppBar(
            title: const Text('Profile Screen'),
            centerTitle: true,
          ),
          body: Form(
            key: _formKey,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: size.width * 0.05),
              child: SingleChildScrollView(
                child: SizedBox(
                  width: size.width,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                        height: size.height * 0.03,
                      ),
                      Stack(
                        children: [
                          _image != null
                              ? Container(
                                  width: size.width * 0.3,
                                  height: size.width * 0.3,
                                  clipBehavior: Clip.antiAliasWithSaveLayer,
                                  decoration: BoxDecoration(
                                    color: Colors.amber,
                                    borderRadius:
                                        BorderRadius.circular(size.width * .4),
                                  ),
                                  child: Image.file(
                                    File(_image!),
                                    fit: BoxFit.cover,
                                  ),
                                )
                              : Container(
                                  width: size.width * 0.3,
                                  height: size.width * 0.3,
                                  clipBehavior: Clip.antiAliasWithSaveLayer,
                                  decoration: BoxDecoration(
                                    color: Colors.amber,
                                    borderRadius:
                                        BorderRadius.circular(size.width * .4),
                                  ),
                                  child: CachedNetworkImage(
                                    fit: BoxFit.cover,
                                    imageUrl: widget.chatUser.image,
                                    placeholder: (context, url) =>
                                        const CircularProgressIndicator(),
                                    errorWidget: (context, url, error) =>
                                        const CircularProgressIndicator(),
                                  ),
                                ),
                          //  Edit Image Button
                          Positioned(
                            bottom: -4,
                            right: -16,
                            child: MaterialButton(
                                shape: const CircleBorder(),
                                color: Colors.white,
                                onPressed: () {
                                  _showBottomSheet(context);
                                },
                                child: const Icon(
                                  Icons.edit,
                                  color: Colors.deepOrange,
                                )),
                          )
                        ],
                      ),
                      SizedBox(
                        height: size.height * 0.03,
                      ),
                      Text(
                        widget.chatUser.name,
                        style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black54),
                      ),
                      SizedBox(
                        height: size.height * 0.03,
                      ),
                      Text(
                        widget.chatUser.email,
                        style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black54),
                      ),
                      SizedBox(
                        height: size.height * 0.03,
                      ),
                      TextFormField(
                        onSaved: (value) {
                          Apis.me.name = value ?? '';
                        },
                        validator: (val) {
                          if (val!.isEmpty || val.length < 4) {
                            return 'Please enter your name';
                          }
                          return null;
                        },
                        initialValue: widget.chatUser.name,
                        decoration: const InputDecoration(
                          prefixIcon:
                              Icon(Icons.person, color: Colors.blueAccent),
                          labelText: 'Name',
                          hintText: 'eg. Happy Alash',
                          border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(10.0)),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: size.height * 0.03,
                      ),
                      TextFormField(
                        onSaved: (value) {
                          Apis.me.about = value ?? '';
                        },
                        validator: (val) {
                          if (val!.isEmpty || val.length < 4) {
                            return 'Please enter your name';
                          }
                          return null;
                        },
                        initialValue: widget.chatUser.about,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(10.0)),
                          ),
                          prefixIcon: Icon(Icons.info_outline_rounded,
                              color: Colors.blueAccent),
                          labelText: 'About',
                          hintText: 'eg.',
                        ),
                      ),
                      SizedBox(
                        height: size.height * 0.05,
                      ),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          minimumSize:
                              Size(size.height * 0.2, size.height * 0.07),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                        ),
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            _formKey.currentState!.save();
                            Apis.updateMe(context);
                          }
                        },
                        icon: const Icon(
                          Icons.edit,
                          size: 28,
                        ),
                        label: const Text(
                          'Update',
                          style: TextStyle(fontSize: 16),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
          floatingActionButton:
              Consumer<GoogleSignInProvider>(builder: (context, value, index) {
            return FloatingActionButton.extended(
              label: const Text('Logout'),
              icon: const Icon(Icons.logout),
              backgroundColor: Colors.blue,
              onPressed: () async {
                await Apis.updateActiveStatus(false);
                await value.googleLogout(context);
                // Navigator.pushReplacement(
                //     context,
                //     MaterialPageRoute(
                //         builder: (context) => const LoginScreen()));
                // Navigator.pushNamed(context, '/login_screen');
              },
            );
          })),
    );
  }

  void _showBottomSheet(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    showModalBottomSheet(
        context: context,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20), topRight: Radius.circular(20)),
            side: BorderSide(color: Colors.white)),
        builder: (_) {
          return ListView(
            shrinkWrap: true,
            padding: EdgeInsets.only(
                top: size.height * 0.02, bottom: size.height * .05),
            children: [
              const Text(
                'Pick profile photo',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 23, fontWeight: FontWeight.w500),
              ),
              SizedBox(
                height: size.height * 0.02,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          shape: const CircleBorder(),
                          backgroundColor: Colors.white,
                          fixedSize: Size(size.width * 0.3, size.height * 0.2)),
                      onPressed: () async {
                        final picker = ImagePicker();
                        final XFile? image =
                            await picker.pickImage(source: ImageSource.gallery);
                        if (image != null) {
                          setState(() {
                            _image = image.path;
                          });
                          Apis.updateProfilePicture(File(_image!));
                          Navigator.pop(context);
                        }
                        //  For hiding bottom sheet
                      },
                      child: Image.asset('assets/images/add_image.png')),
                  ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          shape: const CircleBorder(),
                          backgroundColor: Colors.white,
                          fixedSize: Size(size.width * 0.3, size.height * 0.2)),
                      onPressed: () async {
                        final picker = ImagePicker();
                        final XFile? image =
                            await picker.pickImage(source: ImageSource.camera);
                        if (image != null) {
                          setState(() {
                            _image = image.path;
                          });
                          Apis.updateProfilePicture(File(_image!));
                          Navigator.pop(context);
                        }
                      },
                      child: Image.asset('assets/images/camera.png'))
                ],
              )
            ],
          );
        });
  }
}
