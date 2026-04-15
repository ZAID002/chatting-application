import 'dart:core';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:untitled2/Api/apies.dart';
import 'package:untitled2/Widgets/chat_user_card.dart';
import 'package:untitled2/main.dart';
import 'package:untitled2/models/chat_user.dart';
import 'package:untitled2/screens/profile_screen.dart';
import 'package:flutter/material.dart';
import 'dart:developer';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  ///for storing all users
  List<ChatUser> _list = [];

  ///for searching all users
  final List<ChatUser> _searchlist = [];

  ///for storing search status of user
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    APIs.getSelfInfo();
    ///for setting user status to active
    APIs.updateActiveStatus(true);
    SystemChannels.lifecycle.setMessageHandler((message) {
      log("message: $message");
      ///for updating user active status according to app lifecycle events
      ///resume // means online
      ///pause // offline
      if(APIs.auth.currentUser != null){
        if(message.toString().contains('pause')) APIs.updateActiveStatus(false);
        if(message.toString().contains('resume')) APIs.updateActiveStatus(true);

      }

      return Future.value(message);
    });
    {}
  }

  Widget build(BuildContext context) {
    return GestureDetector(
      ///when user tap anywhere on screen the hide the keyboard
      onTap: () => FocusScope.of(context).unfocus(),
      child: WillPopScope(
        ///if search button is on and back button is pressed then close the search bar
        ///else simple close current screen on back button click
        onWillPop: () {
          if (_isSearching) {
            setState(() {
              _isSearching = !_isSearching;
            });
            return Future.value(false);
          } else {
            return Future.value(true);
          }
        },
        child: Scaffold(
          appBar: AppBar(
            leading: const Icon(CupertinoIcons.home),

            ///when user press search button then show search bar
            title: _isSearching
                ? TextField(
                    autofocus: true,
                    style: const TextStyle(fontSize: 16, letterSpacing: 0.5),
                    onChanged: (val) {
                      ///search logic
                      _searchlist.clear();
                      for (var i in _list) {
                        if (i.name.toLowerCase().contains(val.toLowerCase()) ||
                            i.email.toLowerCase().contains(val.toLowerCase())) {
                          _searchlist.add(i);
                          setState(() {
                            _searchlist;
                          });
                        }
                      }
                      setState(() {
                        _searchlist;
                      });
                    },
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Name ,Email,...',
                    ),
                  )
                : const Text('zee chat'),
            actions: [
              ///for search button
              IconButton(
                onPressed: () {
                  setState(() {
                    _isSearching = !_isSearching;
                  });
                },
                icon: Icon(
                  _isSearching ? CupertinoIcons.clear_circled : Icons.search,
                ),
              ),
              IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ProfileScreen(user: APIs.me),
                    ),
                  );
                },
                icon: const Icon(Icons.more_vert),
              ),
            ],
          ),
          //floating add button to add new user
          floatingActionButton: Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: FloatingActionButton(
              onPressed: () async {
                await APIs.auth.signOut();
                await GoogleSignIn().signOut();
              },
              child: Icon(Icons.add_comment_rounded),
            ),
          ),
          body:
              ///show card for each user
              StreamBuilder(
                ///STREAM
                stream: APIs.getAllUsers(),
                builder: (context, snapshot) {
                  switch (snapshot.connectionState) {
                    ///if data is loading
                    case ConnectionState.waiting:
                    case ConnectionState.none:
                      return const Center(child: CircularProgressIndicator());

                    /// if some date is loaded or loading
                    case ConnectionState.active:
                    case ConnectionState.done:
                      final data = snapshot.data?.docs;
                      _list =
                          data
                              ?.map((e) => ChatUser.fromJson(e.data()))
                              .toList() ??
                          [];

                      if (_list.isNotEmpty) {
                        return ListView.builder(
                          physics: BouncingScrollPhysics(),
                          padding: EdgeInsets.only(top: mq.height * .01),
                          itemCount: _isSearching
                              ? _searchlist.length
                              : _list.length,
                          itemBuilder: (context, index) {
                            return ChatUserCard(
                              user: _isSearching
                                  ? _searchlist[index]
                                  : _list[index],
                            );
                          },
                        );
                      } else {
                        return Center(
                          child: Text(
                            'NO Contacts Found!',
                            style: TextStyle(fontSize: 20),
                          ),
                        );
                      }
                  }
                },
              ),
        ),
      ),
    );
  }
}
