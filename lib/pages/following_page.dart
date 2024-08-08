import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:message_app/pages/home_page.dart';
import 'package:message_app/pages/my_posts_page.dart';
import 'package:message_app/pages/profile_page.dart';
import 'package:message_app/pages/user_page.dart';
import 'package:message_app/services/firestore_user.dart';

class FollowingPage extends StatefulWidget {
  const FollowingPage({super.key});

  @override
  State<FollowingPage> createState() => _FollowingPageState();
}

void showUserList(BuildContext context) {
  final firestoreUserService = FirestoreUserService();

  showDialog(
    context: context,
    builder: (context) {
      return SimpleDialog(
        title: const Text('Existing Users'),
        children: [
          SizedBox(
            width: double.maxFinite,
            height: 300, // Sett høyde for å sikre at listen er rullbar
            child: StreamBuilder<QuerySnapshot>(
              stream: firestoreUserService.getUsersStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('No users found.'));
                }

                // Hent den nåværende brukerens e-post
                User? currentUser = FirebaseAuth.instance.currentUser;
                String currentUserEmail = currentUser?.email ?? '';

                // Filtrer ut den nåværende brukeren fra listen
                List<DocumentSnapshot> users = snapshot.data!.docs.where((doc) {
                  Map<String, dynamic> user =
                      doc.data() as Map<String, dynamic>;
                  return user['email'] !=
                      currentUserEmail; // Ekskluder den nåværende brukeren
                }).toList();

                return ListView.builder(
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    Map<String, dynamic> user =
                        users[index].data() as Map<String, dynamic>;
                    bool isFollowing = currentUser != null &&
                        List<String>.from(user['followers'] ?? [])
                            .contains(currentUserEmail);
                    return ListTile(
                      title: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(user['email'] ?? 'No Email'),
                          TextButton(
                            onPressed: () {
                              firestoreUserService.followAUser(user['email']);
                            },
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.white,
                              backgroundColor:
                                  isFollowing ? Colors.red : Colors.blue,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              textStyle: const TextStyle(fontSize: 14),
                            ),
                            child: Text(
                              isFollowing ? 'Unfollow' : 'Follow',
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Close'),
          ),
        ],
      );
    },
  );
}

class _FollowingPageState extends State<FollowingPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(
          "Following",
          style: TextStyle(color: Colors.blue),
        ),
        leading: Builder(
          builder: (context) {
            return IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            );
          },
        ),
        actions: [
          IconButton(
            onPressed: () {
              showUserList(context);
            },
            icon: const Icon(Icons.find_in_page_rounded),
          )
        ],
      ),
      drawer: Drawer(
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color.fromARGB(255, 77, 103, 125),
                Color.fromARGB(255, 122, 67, 132),
                Color.fromARGB(255, 179, 131, 188)
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              const DrawerHeader(
                decoration: BoxDecoration(
                  color: Colors.transparent,
                ),
                child: Center(
                  child: Text(
                    'SocialApp',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                    ),
                  ),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.home, color: Colors.white),
                title:
                    const Text('Home', style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const HomePage()),
                  );
                },
              ),
              ListTile(
                leading:
                    const Icon(Icons.content_copy_sharp, color: Colors.white),
                title: const Text('My Posts',
                    style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const MyPostsPage()),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.emoji_people, color: Colors.white),
                title: const Text('Following',
                    style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.person, color: Colors.white),
                title: const Text('Profile',
                    style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const ProfilePage()),
                  );
                },
              ),
            ],
          ),
        ),
      ),
      body: StreamBuilder<List<String>?>(
        stream: FirestoreUserService().getFollowingForCurrentUser(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Ingen følgere funnet.'));
          }

          List<String> followingList = snapshot.data!;

          return ListView.builder(
            itemCount: followingList.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            UserPage(email: followingList[index]),
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.only(
                        left: 8, top: 10, bottom: 10, right: 8),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.grey[200]),
                    child: Column(
                      children: [
                        Text(followingList[index]),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
