import 'dart:core';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:untitled2/Api/apies.dart';
import 'package:untitled2/helper/my_date_util.dart';
import 'package:untitled2/models/chat_user.dart';
import '../main.dart';

class ViewProfileScreen extends StatefulWidget {
  final ChatUser user;
  const ViewProfileScreen({super.key, required this.user});

  @override
  State<ViewProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ViewProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text('Profile', style: TextStyle(fontWeight: FontWeight.bold)),
          elevation: 0,
          backgroundColor: Colors.blueAccent,
          foregroundColor: Colors.white, // Text aur back arrow white karne ke liye
        ),
        body: Column(
          children: [
            // --- Top Profile Header ---
            Stack(
              alignment: Alignment.center,
              children: [
                // Background Blue Shape
                Container(
                  height: mq.height * .20,
                  decoration: const BoxDecoration(
                    color: Colors.blueAccent,
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(50),
                      bottomRight: Radius.circular(50),
                    ),
                  ),
                ),

                // Profile Image with Border
                Positioned(
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(mq.height * .1),
                      child: CachedNetworkImage(
                        width: mq.height * .18,
                        height: mq.height * .18,
                        fit: BoxFit.cover,
                        imageUrl: widget.user.image,
                        errorWidget: (context, url, error) => const CircleAvatar(
                          child: Icon(Icons.person, size: 50),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 15),

            // User Name & Email
            Text(
              widget.user.name,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            Text(
              widget.user.email,
              style: const TextStyle(fontSize: 15, color: Colors.black54),
            ),

            const SizedBox(height: 25),

            // --- Info Section (Cards) ---
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    // About Card
                    _buildInfoCard(
                      icon: Icons.info_outline,
                      label: "About",
                      value: widget.user.about,
                      iconColor: Colors.blueAccent,
                    ),

                    const SizedBox(height: 15),

                    // --- DYNAMIC BLOCK / UNBLOCK CARD ---
                    StreamBuilder(
                      stream: APIs.isUserBlocked(widget.user.id),
                      builder: (context, snapshot) {
                        final isBlocked = snapshot.hasData && snapshot.data!.exists;

                        return InkWell(
                          onTap: () async {
                            if (isBlocked) {
                              // Agar pehle se blocked hai toh unblock karo
                              await APIs.unblockUser(widget.user).then((value) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('User Unblocked Successfully!'))
                                );
                              });
                            } else {
                              // Agar blocked nahi hai toh block karo
                              await APIs.blockUser(widget.user).then((value) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('User Blocked Successfully!'))
                                );
                              });
                            }
                          },
                          borderRadius: BorderRadius.circular(20),
                          child: Card(
                            elevation: 0.5,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                              side: BorderSide(
                                color: isBlocked ? Colors.green.shade200 : Colors.red.shade200,
                              ),
                            ),
                            color: isBlocked ? Colors.green.shade50 : Colors.red.shade50,
                            child: Padding(
                              padding: const EdgeInsets.all(15.0),
                              child: Row(
                                children: [
                                  Icon(
                                    isBlocked ? Icons.check_circle_outline : Icons.block,
                                    color: isBlocked ? Colors.green : Colors.red,
                                    size: 24,
                                  ),
                                  const SizedBox(width: 15),
                                  Text(
                                    isBlocked ? "Unblock User" : "Block User",
                                    style: TextStyle(
                                      color: isBlocked ? Colors.green.shade800 : Colors.red.shade800,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),

            // --- Bottom Fixed Section (Joined Date) ---
            Container(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: RichText(
                text: TextSpan(
                  style: const TextStyle(color: Colors.black87, fontSize: 14),
                  children: [
                    const TextSpan(text: 'Joined ZeeChat on: ', style: TextStyle(fontWeight: FontWeight.bold)),
                    TextSpan(
                      text: MyDateUtil.getLastMesssageTime(
                          context: context,
                          time: widget.user.createdAt,
                          showYear: true
                      ),
                      style: const TextStyle(color: Colors.blueAccent),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget for Information Cards
  Widget _buildInfoCard({required IconData icon, required String label, required String value, required Color iconColor}) {
    return Card(
      elevation: 0.5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide(color: Colors.grey.shade200)),
      color: Colors.grey.shade50,
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: iconColor, size: 24),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: const TextStyle(color: Colors.black45, fontSize: 13, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 5),
                  Text(
                    value,
                    style: const TextStyle(color: Colors.black87, fontSize: 16, height: 1.3),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}