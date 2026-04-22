import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:untitled2/Api/apies.dart';
import 'package:untitled2/main.dart';

import '../helper/my_date_util.dart';
import '../models/message.dart';

class MessageCard extends StatefulWidget {
  const MessageCard({super.key, required this.message});
  final Message message;

  @override
  State<MessageCard> createState() => _MessageCardState();
}

class _MessageCardState extends State<MessageCard> {
  bool _isReadUpdating = false;
  @override
  Widget build(BuildContext context) {
    bool isMe = APIs.user.uid == widget.message.fromId;
    return InkWell(onLongPress: () {

      
    },
        child: isMe ? _greenmessage() : _bluemessage());
  }

  ///sender or another user message
  Widget _bluemessage() {
    if (widget.message.read.isEmpty && !_isReadUpdating) {
      _isReadUpdating = true; // isko true kar dein taake dobara loop na chale

      APIs.updateMessageReadStatus(widget.message)
          .then((_) {
            log("message read updated");
          })
          .catchError((e) {
            // Agar koi error aaye toh flag wapas false kar dein taake dobara retry ho sake
            _isReadUpdating = false;
          });
    }

    ///update last read message if sender and receiver are different

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        //message content
        Flexible(
          child: Container(
            padding: EdgeInsets.all(mq.width * .04),
            margin: EdgeInsets.symmetric(
              horizontal: mq.width * .04,
              vertical: mq.height * .01,
            ),

            decoration: BoxDecoration(
              color: Colors.blue.shade100,
              border: Border.all(color: Colors.lightBlue, width: 2),
              //for round corners
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(30),
                topRight: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),

            child: widget.message.type == Type.images
                ? CachedNetworkImage(
                    imageUrl: widget.message.msg,
                    fit: BoxFit.cover,
                    placeholder: (context, url) =>
                        const CircularProgressIndicator(),
                    errorWidget: (context, url, error) =>
                        const Icon(Icons.broken_image),
                  )
                : Text(
                    widget.message.msg,
                    style: TextStyle(fontSize: 15, color: Colors.black87),
                  ),
          ),
        ),
        Row(
          children: [
            ///time of message sent
            Text(
              MyDateUtil.getFormattedTime(
                context: context,
                time: widget.message.sent,
              ),
              style: TextStyle(fontSize: 13, color: Colors.black54),
            ),
            SizedBox(width: mq.height * .01),
            // ///double tick blue icon for message read
            // if(widget.message.read.isNotEmpty)
            //   const Icon(Icons.done_all_rounded,color: Colors.lightBlue,),
          ],
        ),
      ],
    );
  }

  ///our or user message
  Widget _greenmessage() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        //message content
        Row(
          children: [
            SizedBox(width: mq.height * .02),

            ///double tick blue icon for message read
            if (widget.message.read.isNotEmpty)
              const Icon(Icons.done_all_rounded, color: Colors.lightBlue)
            else
              const Icon(Icons.done_all_rounded, color: Colors.grey),

            /// for adding some space
            SizedBox(width: mq.height * .01),

            //sent time
            Text(
              MyDateUtil.getFormattedTime(
                context: context,
                time: widget.message.sent,
              ),
              style: TextStyle(fontSize: 13, color: Colors.black54),
            ),
          ],
        ),
        Flexible(
          child: Container(
            padding: EdgeInsets.all(mq.width * .04),
            margin: EdgeInsets.symmetric(
              horizontal: mq.width * .04,
              vertical: mq.height * .01,
            ),

            decoration: BoxDecoration(
              color: Colors.green.shade100,
              border: Border.all(color: Colors.lightGreen, width: 2),
              //for round corners
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(30),
                topRight: Radius.circular(30),
                bottomLeft: Radius.circular(30),
              ),
            ),

            child: widget.message.type == Type.images
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: CachedNetworkImage(
                      imageUrl: widget.message.msg,
                      fit: BoxFit.cover,
                      placeholder: (context, url) =>
                          const CircularProgressIndicator(),
                      errorWidget: (context, url, error) =>
                          const Icon(Icons.broken_image),
                    ),
                  )
                : Text(
                    widget.message.msg,
                    style: TextStyle(fontSize: 15, color: Colors.black87),
                  ),
          ),
        ),
      ],
    );
  }
}
