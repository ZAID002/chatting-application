import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:untitled2/Widgets/message_card.dart';
import 'package:untitled2/helper/my_date_util.dart';
import 'package:untitled2/models/chat_user.dart';
import 'package:untitled2/screens/view_profile_screen.dart';
import '../Api/apies.dart';
import '../main.dart';
import '../models/message.dart';
import '../services/cloudinary_service.dart';

class ChatScreen extends StatefulWidget {
  final ChatUser user;

  const ChatScreen({super.key, required this.user});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  ///list for storing messages
  List<Message> _list = [];
  final ImagePicker _picker = ImagePicker();

  ///for handling text message changes
  final _textController = TextEditingController();
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
                            reverse: true,
                            physics: BouncingScrollPhysics(),
                            padding: EdgeInsets.only(top: mq.height * .01),
                            itemCount: _list.length,
                            itemBuilder: (context, index) {
                              return MessageCard(message: _list[index]);
                            },
                          );
                        } else {
                          return Center(
                            child: Text(
                              'Say Hii!🙌',
                              style: TextStyle(fontSize: 20),
                            ),
                          );
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
  ///picking images from gallery
  Future<void> _sendMultipleImages() async {
    final List<XFile> images = await _picker.pickMultiImage(
      imageQuality: 70,
    );

    for (var img in images) {
      File file = File(img.path);

      String? imageUrl = await CloudinaryService.uploadImage(file);

      if (imageUrl != null) {
        APIs.sendMessage(widget.user, imageUrl, msgType: Type.images);
      }
    }
  }
  ///sending image from camera
  Future<void> _sendImageFromCamera() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.camera, imageQuality: 70);

    if (image != null) {
      File file = File(image.path);

      // 🔥 Direct upload ke bajaye Preview Screen pr bhejo
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ImagePreviewScreen(imageFile: file, user: widget.user),
        ),
      );
    }
  }
  ///app bar widget
  Widget _appBar() {
    return InkWell(
      onTap: () {Navigator.push(context, MaterialPageRoute(builder: (_)=>ViewProfileScreen(user: widget.user)));},
      child: StreamBuilder(
        stream: APIs.getUserInfo(widget.user),
        builder: (context, snapshot) {
          final data = snapshot.data?.docs;
          final list =
              data?.map((e) => ChatUser.fromJson(e.data())).toList() ?? [];
          return Row(
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
                  fit: BoxFit.cover, // ⭐ MOST IMPORTANT FIX
                  imageUrl: list.isNotEmpty ? list[0].image : widget.user.image,

                  placeholder: (context, url) =>
                      CircleAvatar(child: Icon(Icons.person)),

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
                    list.isNotEmpty ? list[0].name : widget.user.name,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black87,
                      fontWeight: FontWeight.w500,
                    ),
                  ),

                  Text(
                    list.isNotEmpty
                        ? list[0].isOnline
                              ? 'Online'
                              : MyDateUtil.getLastActiveTime(context: context, lastActive: list[0].lastActive)
                        : MyDateUtil.getLastActiveTime(context: context, lastActive: widget.user.lastActive),
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.black54,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          );
        },
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
                    onPressed: () {
                      _sendMultipleImages();
                    },
                    icon: Icon(Icons.image),
                    color: Colors.blueAccent,
                    iconSize: 26,
                  ),

                  ///take image from camera
                  IconButton(
                    onPressed: () {
                      _sendImageFromCamera();
                    },
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
              if (_textController.text.isNotEmpty) {
                APIs.sendMessage(widget.user, _textController.text,msgType: Type.text);
                _textController.text = '';
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
class ImagePreviewScreen extends StatelessWidget {
  final File imageFile;
  final ChatUser user;

  const ImagePreviewScreen({super.key, required this.imageFile, required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(backgroundColor: Colors.black, iconTheme: const IconThemeData(color: Colors.white)),
      body: Stack(
        children: [
          // Image Display
          Center(child: Image.file(imageFile)),

          // Send Button
          Positioned(
            bottom: 20,
            right: 20,
            child: FloatingActionButton(
              backgroundColor: Colors.green,
              onPressed: () async {
                // 1. Blue Loading Indicator
                showDialog(
                  context: context,
                  barrierDismissible: false, // User screen click karke band na kar sakay
                  builder: (context) {
                    return const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.blue), // Blue color fix
                      ),
                    );
                  },
                );

                try {
                  // 2. Image upload start (Wait karega jab tak upload ho na jaye)
                  String? imageUrl = await CloudinaryService.uploadImage(imageFile);

                  if (imageUrl != null) {
                    // 3. Firestore mein message save karein
                    await APIs.sendMessage(user, imageUrl, msgType: Type.images);
                  }
                } catch (e) {
                  print("Upload failed: $e");
                } finally {
                  // 4. Jab kaam khatam ho jaye (Upload + Firestore save), tab band karein
                  Navigator.pop(context); // Dialog band
                  Navigator.pop(context); // Preview Screen band aur wapas Chat Screen pr
                }
              },
              child: const Icon(Icons.send, color: Colors.white),
            ),
          )
        ],
      ),
    );
  }
}