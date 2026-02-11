import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../main.dart';
import '../models/chat_user.dart';


class ChatUserCard extends StatefulWidget {
  final ChatUser user;
  const ChatUserCard({super.key, required this.user});

  @override
  State<ChatUserCard> createState() => _ChatUserCardState();
}

class _ChatUserCardState extends State<ChatUserCard> {
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0.5,
      margin: EdgeInsets.symmetric(horizontal: mq.width*.05,vertical:4),
      child: InkWell(
        onTap: (){},
        child: ListTile(
          //user profile image
         // leading: CircleAvatar(child: Icon(Icons.person),),
          leading: ClipRRect(
            borderRadius: BorderRadius.circular(mq.height* .3),
            child: CachedNetworkImage(
              width: mq.height* .055,
              height: mq.height* .055,
              imageUrl: widget.user.image,
              errorWidget: (context, url, error) => CircleAvatar(child: Icon(Icons.person),),
            ),
          ),
          //user name
          title: Text(widget.user.name),
          //user last message if
          subtitle: Text(widget.user.about,maxLines: 1,),
          //time of last message
          // trailing: Text('4:00 am',style: TextStyle(color: Colors.black45),),
          trailing: Container(width: 15,height: 15,
          decoration: BoxDecoration(color: Colors.greenAccent.shade400,borderRadius: BorderRadius.circular(08)),),
        ),
      ),
    );
  }
}
