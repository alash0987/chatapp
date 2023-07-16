// ignore_for_file: use_build_context_synchronously, no_leading_underscores_for_local_identifiers
import 'package:chatapp/api/api.dart';
import 'package:chatapp/cores/providercommon/searching_provider.dart';
import 'package:chatapp/cores/snackbars/snackbar.dart';
import 'package:chatapp/features/pages/profile_screen.dart';
import 'package:chatapp/features/widgets/card_chating.dart';
import 'package:chatapp/models/chat_user.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    debugPrint('data----------------------------------');

    List<ChatUser> _list = [];
    return Consumer<SearchingProvider>(
      builder: (context, values, index) => WillPopScope(
        onWillPop: () async {
          await SystemNavigator.pop();
          return true;
        },
        child: GestureDetector(
          child: Scaffold(
            appBar: AppBar(
              leading: Padding(
                padding: const EdgeInsets.only(left: 18),
                child: IconButton(
                  icon: const Icon(Icons.home),
                  onPressed: () {},
                ),
              ),
              title: values.isSearching
                  ? TextFormField(
                      style: const TextStyle(fontSize: 16, letterSpacing: 0.5),
                      autofocus: true,
                      onChanged: (value) {
                        values.clearList();

                        for (var i in _list) {
                          if (i.name
                                  .toLowerCase()
                                  .contains(value.toLowerCase()) ||
                              i.email
                                  .toLowerCase()
                                  .contains(value.toLowerCase())) {
                            values.addToList(i);
                          }
                        }
                      },
                      decoration: const InputDecoration(
                        hintText: 'Name,Email,...',
                        border: InputBorder.none,
                      ),
                    )
                  : const Text('Chat App'),
              centerTitle: true,
              actions: [
                IconButton(
                  icon: values.isSearching
                      ? const Icon(Icons.cancel)
                      : const Icon(Icons.search),
                  onPressed: () {
                    values.isSearchingMethod();
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.more_vert),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProfileScreen(
                          chatUser: Apis.me,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
            floatingActionButton: Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: FloatingActionButton(
                onPressed: () {
                  _addChatUserDialog(context);
                },
                child: const Icon(Icons.add),
              ),
            ),
            body: StreamBuilder(
              stream: Apis.getMyUserId(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return const Center(child: Text('Something went wrong'));
                }
                if (snapshot.data!.docs.map((e) => e.id).isEmpty) {
                  return const Text('No user found');
                } else {
                  return StreamBuilder(
                    stream: Apis.getAllUser(
                      snapshot.data!.docs.map((e) => e.id).isNotEmpty
                          ? snapshot.data?.docs.map((e) => e.id).toList() ?? []
                          : [],
                    ),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (snapshot.hasError) {
                        return const Center(
                            child: Text('Something went wrong'));
                      }
                      if (snapshot.hasData) {
                        final data = snapshot.data?.docs;
                        _list = data!
                            .map((e) => ChatUser.fromJson(e.data()))
                            .toList();
                      }
                      return ListView.builder(
                        itemCount: values.isSearching
                            ? values.list.length
                            : _list.length,
                        itemBuilder: (context, index) {
                          return CardChatting(
                            chatUser: values.isSearching
                                ? values.list[index]
                                : _list[index],
                          );
                        },
                      );
                    },
                  );
                }
              },
            ),
          ),
        ),
      ),
    );
  }

  void _addChatUserDialog(BuildContext context) {
    String email = '';
    showDialog(
      context: context,
      builder: (BuildContext context1) => AlertDialog(
        contentPadding:
            const EdgeInsets.only(left: 24, right: 24, top: 20, bottom: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(
              Icons.person_add,
              size: 24,
            ),
            Text(' Add User')
          ],
        ),
        content: TextFormField(
          maxLines: null,
          onChanged: (value) => {
            //  remove all the spaces in the value and remove dot only of last index (dot '.')

            email = value.replaceAll(' ', ''),
            debugPrint(email.length.toString()),
          },
          decoration: InputDecoration(
            hintText: ' Email id',
            prefixIcon: const Icon(
              Icons.email,
              color: Colors.blue,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Colors.blue),
            ),
          ),
        ),
        actions: [
          MaterialButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Cancel', style: TextStyle(color: Colors.red)),
          ),
          MaterialButton(
            onPressed: () async {
              // Navigator.pop(context);
              if (email.isNotEmpty) {
                await Apis.addChatUser(email).then((value) async {
                  Navigator.pop(context);
                  if (!value) {
                    SnackbarDialog.showSnackbar(context, 'User not found');
                    await Future.delayed(const Duration(seconds: 2), () {
                      _addChatUserDialog(context);
                    });
                  }
                });
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}
