import 'dart:convert';
import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:untitled2/Widgets/message_card.dart';
import 'package:untitled2/models/chat_user.dart';
import '../Api/apies.dart';
import '../main.dart';
import '../models/message.dart';

class ChatScreen extends StatefulWidget {
  final ChatUser user;

  const ChatScreen({super.key, required this.user});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  ///list for storing messages
  List<Message> _list = [];
  ///for handling text message changes
final _textController=TextEditingController();
  @override
  void initState() {
    /// Normal system UI for ChatScreen
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: SystemUiOverlay.values,
    );
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.white,
        systemNavigationBarColor: Colors.white,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );
  }

  Widget build(BuildContext context) {
    return Container(

      color: Colors.white,
      child: SafeArea(
        child: Scaffold(
          backgroundColor: Colors.blue.shade50,

          appBar: AppBar(
            elevation: 0,
            backgroundColor: Colors.white,
            automaticallyImplyLeading: false,
            flexibleSpace: _appBar(),
          ),

          ///body
          body: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Expanded(
                child: StreamBuilder(
                  ///STREAM
                  stream: APIs.getAllMessages(widget.user),
                  builder: (context, snapshot) {
                    switch (snapshot.connectionState) {
                      ///if data is loading
                      case ConnectionState.waiting:
                      case ConnectionState.none:
                        return const SizedBox();

                      /// if some date is loaded or loading
                      case ConnectionState.active:
                      case ConnectionState.done:
                        final data = snapshot.data?.docs;
                        //log('Data: ${jsonEncode(data![0].data())}');
                        _list =
                            data
                                ?.map((e) => Message.fromJson(e.data()))
                                .toList() ??
                                [];


                        if (_list.isNotEmpty) {
                          return ListView.builder(
                            physics: BouncingScrollPhysics(),
                            padding: EdgeInsets.only(top: mq.height * .01),
                            itemCount: _list.length,
                            itemBuilder: (context, index) {
                              return MessageCard(message: _list[index]);
                            },
                          );
                        } else {
                          return Center(child: Text('Say Hii!🙌',style: TextStyle(fontSize: 20),));
                        }
                    }
                  },
                ),
              ),

              _chatInput(),
            ],
          ),
        ),
      ),
    );
  }

  ///app bar widget
  Widget _appBar() {
    return InkWell(
      onTap: () {},
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(Icons.arrow_back),
            color: Colors.black,
          ),

          ///user profile
          ClipRRect(
            borderRadius: BorderRadius.circular(mq.height * .3),
            child: CachedNetworkImage(
              width: mq.height * .055,
              height: mq.height * .055,
              imageUrl: widget.user.image,
              errorWidget: (context, url, error) =>
                  CircleAvatar(child: Icon(Icons.person)),
            ),
          ),
          SizedBox(width: 10),

          ///user name
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.user.name,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                  fontWeight: FontWeight.w500,
                ),
              ),

              Text(
                'last seen not available',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.black54,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  ///bottom chat input text field
  Widget _chatInput() {
    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: mq.height * .01,
        horizontal: mq.width * .023,
      ),
      child: Row(
        children: [
          Expanded(
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              color: Colors.white,
              child: Row(
                children: [
                  ///icon button for emoji
                  IconButton(
                    onPressed: () {},
                    icon: Icon(Icons.emoji_emotions),
                    color: Colors.blueAccent,
                    iconSize: 25,
                  ),

                  ///text field for input message
                  Expanded(
                    child: TextField(
                      controller: _textController,
                      keyboardType: TextInputType.multiline,
                      maxLines: null,
                      decoration: InputDecoration(
                        hintText: 'type a message',
                        hintStyle: TextStyle(color: Colors.blueAccent),
                        border: InputBorder.none,
                      ),
                    ),
                  ),

                  ///pick image from gallery gallery
                  IconButton(
                    onPressed: () {},
                    icon: Icon(Icons.image),
                    color: Colors.blueAccent,
                    iconSize: 26,
                  ),

                  ///take image from camera
                  IconButton(
                    onPressed: () {},
                    icon: Icon(Icons.camera_alt_rounded),
                    color: Colors.blueAccent,
                    iconSize: 26,
                  ),
                ],
              ),
            ),
          ),

          ///send messages button
          MaterialButton(
            minWidth: 0,
            onPressed: () {
              if (_textController.text.isNotEmpty){
                APIs.sendMessage(widget.user, _textController.text);
                _textController.text='';
              }

            },
            padding: EdgeInsets.only(top: 10, bottom: 10, right: 5, left: 10),
            shape: CircleBorder(),
            color: Colors.green,
            child: Icon(Icons.send, color: Colors.white, size: 28),
          ),
        ],
      ),
    );
  }
}
