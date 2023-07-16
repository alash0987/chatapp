// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';

class ImageScreen extends StatelessWidget {
  String message;
  ImageScreen({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.black,
          title: const Text('Image'),
        ),
        body: Center(
          child: Container(
            width: MediaQuery.of(context).size.width * 1,
            height: MediaQuery.of(context).size.height * 1,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Image.network(
              message,
              height: MediaQuery.of(context).size.height * 1,
              width: MediaQuery.of(context).size.width * 1,
              fit: BoxFit.fitHeight,
            ),
          ),
        ),
      ),
    );
  }
}
