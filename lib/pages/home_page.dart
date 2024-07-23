import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:message_app/services/firestore.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final firestoreService = FirestoreService();
  final titlePostController = TextEditingController();
  final textPostController = TextEditingController();

  Future<User?> _getCurrentUser() async {
    // Get the current user
    return FirebaseAuth.instance.currentUser;
  }

  // sign user out
  void signOut() {
    FirebaseAuth.instance.signOut();
  }

  // open a dialog box to add a post
  void openPostBox({String? docID}) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: Container(
          width: MediaQuery.of(context).size.width,
          child: Column(
            children: [
              TextField(
                controller: titlePostController,
                decoration: const InputDecoration(
                  hintText: 'Enter title',
                ),
              ),
              TextField(
                controller: textPostController,
                decoration: const InputDecoration(
                  hintText: 'Enter text',
                ),
              ),
            ],
          ),
        ),
        actions: [
          // button to save
          ElevatedButton(
            onPressed: () {
              if (docID == null) {
                firestoreService.addPost(
                    titlePostController.text, textPostController.text);
              } else {
                firestoreService.updatePost(
                    docID, titlePostController.text, textPostController.text);
              }
              titlePostController.clear();
              textPostController.clear();
              Navigator.pop(context);
            },
            child: const Text('Add'),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text("MessageApp"),
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
          // sign out button
          IconButton(
            onPressed: signOut,
            icon: const Icon(Icons.logout),
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: openPostBox,
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: firestoreService.getPostsStream(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            List postsList = snapshot.data!.docs;
            return ListView.builder(
              itemCount: postsList.length,
              itemBuilder: (context, index) {
                DocumentSnapshot document = postsList[index];
                String docID = document.id;
                Map<String, dynamic> data =
                    document.data() as Map<String, dynamic>;
                String postTitle = data['title'];
                String postText = data['text'];
                // A Post
                return Column(
                  children: [
                    Text(postTitle),
                    Container(
                      decoration: const BoxDecoration(
                          color: Color.fromARGB(255, 233, 233, 233)),
                      height: 400,
                      width: double.infinity,
                    ),
                    Row(
                      children: [
                        Container(
                          constraints: const BoxConstraints(maxWidth: 350),
                          padding: const EdgeInsets.only(left: 10, top: 5),
                          child: Text(postText),
                        ),
                        const Spacer(),
                        Column(
                          children: [
                            // Favorite button
                            IconButton(
                              padding:
                                  const EdgeInsets.only(top: 15, right: 15),
                              onPressed: () {},
                              icon: const Icon(
                                Icons.favorite,
                                size: 30,
                              ),
                            ),
                            // updatebutton
                            IconButton(
                              padding:
                                  const EdgeInsets.only(top: 15, right: 15),
                              onPressed: () => openPostBox(docID: docID),
                              icon: const Icon(
                                Icons.settings,
                                size: 30,
                              ),
                            ),
                            // deletebutton
                            IconButton(
                              padding:
                                  const EdgeInsets.only(top: 15, right: 15),
                              onPressed: () =>
                                  firestoreService.deletePost(docID),
                              icon: const Icon(
                                Icons.delete,
                                size: 30,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                );
              },
            );
          } else {
            return const Text('No posts...');
          }
        },
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
                    'Menu',
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
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.search, color: Colors.white),
                title:
                    const Text('Search', style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.person, color: Colors.white),
                title: const Text('Profile',
                    style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              Center(
                child: Column(
                  children: [
                    const Text(
                      'Current User:',
                      style:
                          TextStyle(color: Color.fromARGB(126, 241, 241, 241)),
                    ),
                    FutureBuilder<User?>(
                      future: _getCurrentUser(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const CircularProgressIndicator();
                        } else if (snapshot.hasError) {
                          return Text('Error: ${snapshot.error}');
                        } else if (snapshot.hasData) {
                          User? user = snapshot.data;
                          return Text(
                            user?.email ?? 'No user signed in',
                            style: const TextStyle(
                                fontSize: 20, color: Colors.blue),
                          );
                        } else {
                          return const Text('No user signed in');
                        }
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
