import 'dart:core';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:untitled2/Api/apies.dart';
import 'package:untitled2/Widgets/chat_user_card.dart';
import 'package:untitled2/main.dart';
import 'package:untitled2/models/chat_user.dart';
import 'package:untitled2/screens/profile_screen.dart';
import 'package:flutter/material.dart';
import 'dart:developer';
import '../helper/colors.dart';
import '../helper/dialogs.dart';

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
  int _currentNavIndex = 0;

  @override
  void initState() {
    super.initState();
    ///for getting self info
    APIs.getSelfInfo();

    SystemChannels.lifecycle.setMessageHandler((message) {
      log("message: $message");

      ///for updating user active status according to app lifecycle events
      ///resume // means online
      ///pause // offline
      if (APIs.auth.currentUser != null) {
        if (message.toString().contains('pause')) APIs.updateActiveStatus(false);
        if (message.toString().contains('resume')) APIs.updateActiveStatus(true);
      }
      return Future.value(message);
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      ///when user tap anywhere on screen the hide the keyboard
      onTap: () => FocusScope.of(context).unfocus(),
      child: WillPopScope(
        ///if search button is on and back button is pressed then close the search bar
        ///else simple close current screen on back button click
        onWillPop: () {
          if (_isSearching) {
            setState(() => _isSearching = !_isSearching);
            return Future.value(false);
          } else {
            return Future.value(true);
          }
        },
        child: Scaffold(
          backgroundColor: Colors.white,

          // ⭐ PREMIUM APP BAR DESIGN UPDATE
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            centerTitle: false, // Title left side par set karne k liye (WhatsApp Style)
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
                  }
                }
                setState(() {});
              },
              decoration: const InputDecoration(
                border: InputBorder.none,
                hintText: 'Search name, email...',
                hintStyle: TextStyle(color: Colors.black45, fontSize: 15),
              ),
            )
                : const Text(
              'ZeeChat',
              style: TextStyle(
                color: Color(0xFF534AB7), // Premium Dark Purple Color
                fontSize: 22,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.6,
              ),
            ),

            // Subtle bottom line for clean section separation
            shape: Border(
              bottom: BorderSide(color: Colors.grey.withOpacity(0.15), width: 1),
            ),

            actions: [
              ///for search button
              IconButton(
                onPressed: () => setState(() => _isSearching = !_isSearching),
                icon: Icon(
                  _isSearching ? CupertinoIcons.clear_circled_solid : Icons.search_rounded,
                  color: Colors.black87,
                  size: 24,
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
                icon: const Icon(Icons.more_vert_rounded, color: Colors.black87, size: 24),
              ),
            ],
          ),

          body: _buildBody(),

          // FAB ko Bottom-Right corner par shift kar diya (WhatsApp Style)
          floatingActionButton: Padding(
            padding: const EdgeInsets.only(bottom: 10, right: 4),
            child: _ZeeFAB(
              onPressed: () async => _addChatUserDialog(),
            ),
          ),
          floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,

          bottomNavigationBar: _ZeeBottomNav(
            currentIndex: _currentNavIndex,
            onTap: (index) {
              setState(() {
                _currentNavIndex = index;
                _isSearching = false;
                _searchlist.clear();
              });
            },
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    switch (_currentNavIndex) {
      case 0:
        return _chatListBody();
      case 1:
        return _peopleBody();
      case 2:
        return _profileBody();
      default:
        return _chatListBody();
    }
  }

  ///show card for each user (Sorted Real-time)
  Widget _chatListBody() {
    return StreamBuilder(
      ///STREAM
      stream: APIs.getMyUsersIds(),
      builder: (context, snapshot) {
        ///get id of all known users
        switch (snapshot.connectionState) {
        ///if data is loading
          case ConnectionState.waiting:
          case ConnectionState.none:
            return const Center(child: CircularProgressIndicator());

        /// if some date is loaded or loading
          case ConnectionState.active:
          case ConnectionState.done:
            final orderedIds = snapshot.data?.docs.map((e) => e.id).toList() ?? [];

            return StreamBuilder(
              ///STREAM
              stream: APIs.getAllUsers(orderedIds),
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
                    _list = data
                        ?.map((e) => ChatUser.fromJson(e.data()))
                        .toList() ??
                        [];

                    // Firestore ki returned list ko orderedIds ke mutabiq sort karo (Latest chat top par)
                    _list.sort((a, b) => orderedIds.indexOf(a.id).compareTo(orderedIds.indexOf(b.id)));

                    if (_list.isNotEmpty) {
                      return ListView.builder(
                        physics: const BouncingScrollPhysics(),
                        padding: EdgeInsets.only(top: mq.height * .01),
                        itemCount: _isSearching ? _searchlist.length : _list.length,
                        itemBuilder: (context, index) {
                          return ChatUserCard(
                            user: _isSearching ? _searchlist[index] : _list[index],
                          );
                        },
                      );
                    } else {
                      return const Center(
                        child: Text(
                          'No Contacts Found!',
                          style: TextStyle(fontSize: 20),
                        ),
                      );
                    }
                }
              },
            );
        }
      },
    );
  }

  /// 2. PEOPLE TAB: Saare registered contacts (Except Current User)
  Widget _peopleBody() {
    return StreamBuilder(
      stream: APIs.firestore.collection('User').snapshots(),
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.waiting:
          case ConnectionState.none:
            return const Center(child: CircularProgressIndicator());
          case ConnectionState.active:
          case ConnectionState.done:
            final data = snapshot.data?.docs;
            final fullList = data?.map((e) => ChatUser.fromJson(e.data())).toList() ?? [];

            // Apni profile list se nikal do
            _list = fullList.where((element) => element.id != APIs.user.uid).toList();

            if (_list.isNotEmpty) {
              return ListView.builder(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.only(top: mq.height * .01),
                itemCount: _isSearching ? _searchlist.length : _list.length,
                itemBuilder: (context, index) {
                  return ChatUserCard(
                    user: _isSearching ? _searchlist[index] : _list[index],
                  );
                },
              );
            } else {
              return const Center(
                child: Text('No Registered Users Found!', style: TextStyle(fontSize: 18)),
              );
            }
        }
      },
    );
  }

  /// 3. PROFILE TAB
  Widget _profileBody() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircleAvatar(
            radius: 40,
            backgroundColor: Color(0xFFCECBF6),
            child: Icon(Icons.person, size: 40, color: Color(0xFF3C3489)),
          ),
          const SizedBox(height: 14),
          const Text('Profile',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500, color: Color(0xFF2C2C2A))),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => ProfileScreen(user: APIs.me)),
              );
            },
            icon: const Icon(Icons.edit_outlined),
            label: const Text('Edit Profile'),
            style: ElevatedButton.styleFrom(
              backgroundColor: ZeeColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      ),
    );
  }

  void _addChatUserDialog() {
    String email = '';
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        contentPadding: const EdgeInsets.only(left: 24, right: 24, top: 20, bottom: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: const [
            Icon(Icons.person_add, color: Colors.blue, size: 28),
            Text('  Add User'),
          ],
        ),
        content: TextFormField(
          maxLines: 1,
          onChanged: (value) => email = value,
          decoration: InputDecoration(
            hintText: 'Email Id',
            prefixIcon: const Icon(Icons.email, color: Colors.blue),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
          ),
        ),
        actions: [
          MaterialButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.blue, fontSize: 16)),
          ),
          MaterialButton(
            onPressed: () async {
              Navigator.pop(context);
              if (email.trim().isNotEmpty) {
                await APIs.addChatUser(email).then((value) {
                  if (!value) {
                    Dialogs.showsnackbar(context, 'User does not exist!');
                  } else {
                    Dialogs.showsnackbar(context, 'User added successfully!');
                  }
                });
              } else {
                Dialogs.showsnackbar(context, 'Please enter an email address');
              }
            },
            child: const Text('Add', style: TextStyle(color: Colors.blue, fontSize: 16)),
          ),
        ],
      ),
    );
  }
}

// ─── FAB Button ───────────────────────────────────────────
class _ZeeFAB extends StatelessWidget {
  final VoidCallback onPressed;
  const _ZeeFAB({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF7F77DD), Color(0xFF534AB7)],
        ),
        boxShadow: [
          BoxShadow(
            color: ZeeColors.primary.withOpacity(0.35),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        shape: const CircleBorder(),
        child: InkWell(
          onTap: onPressed,
          customBorder: const CircleBorder(),
          child: const Icon(Icons.add_comment_rounded, color: Colors.white, size: 24),
        ),
      ),
    );
  }
}

// ─── Bottom Navigation Bar (Symmetrical 3-Tab Layout) ───
class _ZeeBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _ZeeBottomNav({
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      color: Colors.white,
      elevation: 8,
      child: Container(
        height: 60,
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: ZeeColors.border, width: 0.5)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _NavItem(
              icon: Icons.chat_bubble_outline_rounded,
              activeIcon: Icons.chat_bubble_rounded,
              label: 'chats',
              isActive: currentIndex == 0,
              onTap: () => onTap(0),
            ),
            _NavItem(
              icon: Icons.people_outline_rounded,
              activeIcon: Icons.people_rounded,
              label: 'people',
              isActive: currentIndex == 1,
              onTap: () => onTap(1),
            ),
            _NavItem(
              icon: Icons.person_outline_rounded,
              activeIcon: Icons.person_rounded,
              label: 'me',
              isActive: currentIndex == 2,
              onTap: () => onTap(2),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Single Nav Item — overflow FIXED ─────────────────────
class _NavItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;
  final int badge;
  final Color badgeColor;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isActive,
    required this.onTap,
    this.badge = 0,
    this.badgeColor = ZeeColors.primary,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: Icon(
                    isActive ? activeIcon : icon,
                    key: ValueKey(isActive),
                    color: isActive ? ZeeColors.primary : ZeeColors.textTertiary,
                    size: 22,
                  ),
                ),
                if (badge > 0)
                  Positioned(
                    top: -4,
                    right: -8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                      decoration: BoxDecoration(
                        color: badgeColor,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.white, width: 1.5),
                      ),
                      constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                      child: Text(
                        '$badge',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 2),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: TextStyle(
                fontSize: 10,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                color: isActive ? ZeeColors.primary : ZeeColors.textTertiary,
              ),
              child: Text(label),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: isActive ? 18 : 0,
              height: 2,
              decoration: BoxDecoration(
                color: ZeeColors.primary,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ],
        ),
      ),
    );
  }
}