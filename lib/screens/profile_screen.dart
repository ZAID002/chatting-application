import 'dart:core';
import 'dart:developer';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_picker/image_picker.dart';
import 'package:untitled2/Api/apies.dart';
import 'package:untitled2/helper/dialogs.dart';
import 'package:untitled2/helper/progress_bar_fix.dart';
import 'package:untitled2/models/chat_user.dart';
import 'package:untitled2/screens/auth/login_screen.dart';
import '../main.dart';
import 'package:untitled2/services/cloudinary_service.dart';

class ProfileScreen extends StatefulWidget {
  final ChatUser user;

  const ProfileScreen({super.key, required this.user});

  @override
  State<ProfileScreen> createState() => _ProfileScreen();
}

class _ProfileScreen extends State<ProfileScreen> {
  final _formkey = GlobalKey<FormState>();
  String? _image;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(title: const Text(' Profile Screen')),
        ///floating add button to add new user
        floatingActionButton: Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: FloatingActionButton.extended(
            backgroundColor: Colors.redAccent,
            onPressed: () async {
              ///fix class is used from helper directory /progress_bar_fix.dart
              ///for showing progress dialog
              Fix.showprogress(context);
              await APIs.updateActiveStatus(false);
              //signout from app
              await APIs.auth.signOut().then((value) async {
                await GoogleSignIn().signOut().then((value) {
                  //for hiding progress dialog
                  Navigator.pop(context);
                  Navigator.pop(context);
APIs.auth=FirebaseAuth.instance;
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => LoginScreen()),
                  );
                });
              });
            },
            icon: Icon(Icons.logout, color: Colors.white),
            label: Text('LogOut', style: TextStyle(color: Colors.white)),
          ),
        ),
        body: Form(
          key: _formkey,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  //for adding some space
                  SizedBox(width: mq.width, height: mq.height * .03),
                  Stack(
                    children: [
                      _image != null
                          ?
                            ///for local image
                            ClipRRect(
                              borderRadius: BorderRadius.circular(
                                mq.height * .1,
                              ),
                              child: Image.file(
                                File(_image!),
                                width: mq.height * .2,
                                height: mq.height * .2,
                                fit: BoxFit.cover,
                              ),
                            )
                          :
                            ///image from server
                            ClipRRect(
                              borderRadius: BorderRadius.circular(
                                mq.height * .1,
                              ),
                              child: CachedNetworkImage(
                                width: mq.height * .2,
                                height: mq.height * .2,
                                fit: BoxFit.cover,
                                imageUrl: widget.user.image,
                                errorWidget: (context, url, error) =>
                                    CircleAvatar(child: Icon(Icons.person)),
                              ),
                            ),

                      ///for edit butttoon
                      Positioned(
                        bottom: 0,
                        right: 0,

                        child: MaterialButton(
                          color: Colors.blue,
                          shape: CircleBorder(),
                          elevation: 1,
                          onPressed: () {
                            _showBottomSheet();
                          },
                          child: Icon(Icons.edit, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: mq.height * .03),
                  //for showing email text
                  Text(
                    widget.user.email,
                    style: const TextStyle(color: Colors.black54, fontSize: 16),
                  ),
                  SizedBox(height: mq.height * .03),

                  ///text form field for name
                  TextFormField(
                    initialValue: widget.user.name,
                    onSaved: (val) => APIs.me.name = val ?? '',

                    ///validator to check if field is empty or not
                    validator: (val) =>
                        val != null && val.isNotEmpty ? null : 'Required Field',
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.person, color: Colors.blue),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      hintText: 'eg John Michel',
                      label: const Text('Name'),
                    ),
                  ),
                  SizedBox(height: mq.height * .03),

                  ///text form field for about
                  TextFormField(
                    initialValue: widget.user.about,
                    onSaved: (val) => APIs.me.about = val ?? '',
                    //validator to check if field is empty or not
                    validator: (val) =>
                        val != null && val.isNotEmpty ? null : 'Required Field',

                    decoration: InputDecoration(
                      prefixIcon: const Icon(
                        Icons.info_outline,
                        color: Colors.blue,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      hintText: "eg Feeling good today",
                      label: const Text('About'),
                    ),
                  ),
                  SizedBox(height: mq.height * .05),
                  //update button
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      shape: StadiumBorder(),
                      backgroundColor: Colors.blue,
                      minimumSize: Size(mq.width * .5, mq.height * .06),
                    ),
                    onPressed: () {
                      if (_formkey.currentState!.validate()) {
                        _formkey.currentState!.save();
                        APIs.updateUserInfo().then((value) {
                          Dialogs.showsnackbar(
                            context,
                            'Profile Updated Successfully',
                          );
                        });
                      }
                    },
                    icon: Icon(Icons.edit, color: Colors.white, size: 25),
                    label: Text(
                      'Update',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  ///bottom sheet for picking profile pic for user
  void _showBottomSheet() {
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
          padding: EdgeInsets.only(
            top: mq.height * .03,
            bottom: mq.height * .03,
          ),
          children: [
            const Text(
              'Pick Profile Picture',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
            ),
            SizedBox(height: mq.height * .02),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ///pick picture from gallery button
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    fixedSize: Size(mq.width * .3, mq.height * .10),
                  ),
                  onPressed: () async {
                    final ImagePicker picker = ImagePicker();
                    final XFile? image = await picker.pickImage(
                      source: ImageSource.gallery,
                    );

                    if (image != null) {
                      log('Image_path ${image.path}');

                      //  local preview ke liye
                      setState(() {
                        _image = image.path;
                      });

                      // bottom sheet band karo
                      Navigator.pop(context);

                      // file banao
                      File file = File(image.path);

                      // Cloudinary upload karo
                      String? imageUrl = await CloudinaryService.uploadImage(
                        file,
                      );

                      // 5️⃣ agar upload successful ho
                      if (imageUrl != null) {
                        APIs.me.image = imageUrl;
                        await APIs.updateUserInfo();

                        Dialogs.showsnackbar(
                          context,
                          'Profile Picture Updated',
                        );
                      }
                    }
                  },


                  child: Image.asset('assets/images/add_image.png'),
                ),

                ///take picture from camera button
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    fixedSize: Size(mq.width * .3, mq.height * .10),
                  ),
                  onPressed: () async {
                    final ImagePicker picker = ImagePicker();
                    final XFile? image = await picker.pickImage(
                      source: ImageSource.camera,
                    );

                    if (image != null) {
                      log('Image_path ${image.path}');

                      //  local preview ke liye
                      setState(() {
                        _image = image.path;
                      });

                      // bottom sheet band karo
                      Navigator.pop(context);

                      // file banao
                      File file = File(image.path);

                      // Cloudinary upload karo
                      String? imageUrl = await CloudinaryService.uploadImage(
                        file,
                      );

                      // 5️⃣ agar upload successful ho
                      if (imageUrl != null) {
                        APIs.me.image = imageUrl;
                        await APIs.updateUserInfo();

                        Dialogs.showsnackbar(
                          context,
                          'Profile Picture Updated',
                        );
                      }
                    }

                  },
                  child: Image.asset('assets/images/camera.png'),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
