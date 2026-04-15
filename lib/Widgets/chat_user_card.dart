import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:untitled2/Api/apies.dart';
import 'package:untitled2/helper/my_date_util.dart';
import 'package:untitled2/models/message.dart';
import '../main.dart';
import '../models/chat_user.dart';
import '../screens/chatscreen.dart';

class ChatUserCard extends StatefulWidget {
  final ChatUser user;
  const ChatUserCard({super.key, required this.user});

  @override
  State<ChatUserCard> createState() => _ChatUserCardState();
}

class _ChatUserCardState extends State<ChatUserCard> {
  ///last message of a user if null ---- no message
  Message? _message;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0.5,
      margin: EdgeInsets.symmetric(horizontal: mq.width * .05, vertical: 4),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => ChatScreen(user: widget.user)),
          );
        },

        child: StreamBuilder(
          stream: APIs.getLastMessages(widget.user),
          builder: (context, snapshots) {
            final data = snapshots.data?.docs;
            final list =
                data?.map((e) => Message.fromJson(e.data())).toList() ?? [];
            if (list.isNotEmpty) {
              _message = list[0];
            }
            return ListTile(
              ///user profile image
              /// leading: CircleAvatar(child: Icon(Icons.person),),
              leading: CircleAvatar(
                radius: mq.height * .03,
                backgroundImage: NetworkImage(widget.user.image),
                onBackgroundImageError: (_, __) {},
                child: widget.user.image.isEmpty
                    ? Icon(Icons.person)
                    : null,
              ),

              ///user name
              title: Text(widget.user.name),

              ///user last message if
              subtitle: Text(
                _message != null ? _message!.msg : widget.user.about,
                maxLines: 1,
              ),

              ///time of last message
              /// trailing: Text('4:00 am',style: TextStyle(color: Colors.black45),),
              trailing: _message == null
                  ? null
                  : _message!.read.isEmpty && _message!.fromId != APIs.user.uid
                  ? Container(
                      width: 15,
                      height: 15,
                      decoration: BoxDecoration(
                        color: Colors.greenAccent.shade400,
                        borderRadius: BorderRadius.circular(08),
                      ),
                    )
                  : Text(
                      MyDateUtil.getLastMesssageTime(context: context, time: _message!.sent),
                      style: TextStyle(color: Colors.black45),
                    ),
            );
          },
        ),
      ),
    );
  }
}
