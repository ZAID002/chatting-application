import 'dart:developer';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:untitled2/Api/apies.dart';
import 'package:untitled2/main.dart';
import 'package:saver_gallery/saver_gallery.dart';
import '../helper/dialogs.dart';
import '../helper/my_date_util.dart';
import '../models/message.dart';
import 'package:http/http.dart' as http;
import '../helper/colors.dart';

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
    return InkWell(
      onLongPress: () {
        _showBottomSheet(isMe);
      },
      child: isMe ? _greenmessage() : _bluemessage(),
    );
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

  ///our message
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
              color: ZeeColors.primary,
              border: Border.all(color: ZeeColors.primary, width: 2),
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
                    style: TextStyle(fontSize: 15, color: ZeeColors.primaryLight),
                  ),
          ),
        ),
      ],
    );
  }

  ///bottom sheet for picking profile pic for user
  void _showBottomSheet(bool isMe) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadiusGeometry.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      builder: (_) {
        return ListView(
          shrinkWrap: true,

          children: [
            Container(
              height: 4,
              margin: EdgeInsets.symmetric(
                vertical: mq.height * .015,
                horizontal: mq.width * .4,
              ),
              decoration: BoxDecoration(
                color: Colors.grey,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            widget.message.type == Type.text
                ?
                  ///copy option
                  _OtionItem(
                    icon: Icon(
                      Icons.copy_all_rounded,
                      color: Colors.blue,
                      size: 26,
                    ),
                    name: 'Copy Text',
                    onTap: () async {
                      await Clipboard.setData(
                        ClipboardData(text: widget.message.msg),
                      ).then((value) {
                        Navigator.pop(context);
                        Dialogs.showsnackbar(context, 'Text Copied');
                      });
                    },
                  )
                :
                  ///image save option
                  _OtionItem(
                    icon: Icon(
                      Icons.download_rounded,
                      color: Colors.blue,
                      size: 26,
                    ),
                    name: 'Save Image',
                    // ✅ NAYA - ye lagao
                    onTap: () async {
                      try {
                        final response = await http.get(Uri.parse(widget.message.msg));
                        await SaverGallery.saveImage(
                          response.bodyBytes,
                          fileName: 'zeechat_${DateTime.now().millisecondsSinceEpoch}',
                          androidRelativePath: "Pictures/ZeeChat", skipIfExists: true,
                        );
                        Navigator.pop(context);
                        Dialogs.showsnackbar(context, 'Image Saved!');
                      } catch (e) {
                        Dialogs.showsnackbar(context, 'Failed to save image');
                      }
                    },
                  ),

            ///seprator
            if (isMe)
              Divider(
                color: Colors.grey,
                endIndent: mq.width * .04,
                indent: mq.width * .04,
              ),

            ///edit option
            if (widget.message.type == Type.text && isMe)
              _OtionItem(
                icon: Icon(Icons.edit, color: Colors.blue, size: 26),
                name: 'Edit Message',
                onTap: () {},
              ),

            ///delete option
            if (isMe)
              _OtionItem(
                icon: Icon(Icons.delete_forever, color: Colors.red, size: 26),
                name: 'Delete Message',
                onTap: () async {
                  await APIs.deleteMessage(widget.message).then((value) {
                    Navigator.pop(context);
                  });
                },
              ),


            ///seprator
            Divider(
              color: Colors.grey,
              endIndent: mq.width * .04,
              indent: mq.width * .04,
            ),

            ///sent time
            if(isMe)
            _OtionItem(
              icon: Icon(Icons.schedule, color: Colors.blue),
              name:
                  'Sent At ${MyDateUtil.getMessageTime(context: context, time: widget.message.sent)}',
              onTap: () {},
            ),

            ///read time
            if(isMe)
            _OtionItem(
              icon: Icon(Icons.done_all, color: Colors.green),
              name: widget.message.read.isEmpty
                  ? "Read At : Not Seen yet"
                  : 'Read At ${MyDateUtil.getMessageTime(context: context, time: widget.message.read)}',
              onTap: () {},
            ),
          ],
        );
      },
    );
  }
}



class _OtionItem extends StatelessWidget {
  final Icon icon;
  final String name;
  final VoidCallback onTap;
  const _OtionItem({
    super.key,
    required this.icon,
    required this.name,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onTap(),
      child: Padding(
        padding: EdgeInsets.only(
          left: mq.width * .05,
          top: mq.height * .015,
          bottom: mq.height * .015,
        ),
        child: Row(
          children: [
            icon,
            Flexible(child: Text('   $name')),
          ],
        ),
      ),
    );
  }
}
