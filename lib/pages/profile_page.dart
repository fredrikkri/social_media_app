import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  void signOut() {
    FirebaseAuth.instance.signOut();
    Navigator.popUntil(context, ModalRoute.withName("/"));
  }

  Future<User?> _getCurrentUser() async {
    return FirebaseAuth.instance.currentUser;
  }

  Widget getCurrentUserEmailTextWidget() {
    return FutureBuilder<User?>(
      future: _getCurrentUser(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else if (snapshot.hasData) {
          User? user = snapshot.data;
          return Text(
            user?.email ?? 'No user signed in',
            style: const TextStyle(
                fontSize: 20, color: Color.fromARGB(255, 145, 33, 243)),
          );
        } else {
          return const Text('No user signed in');
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(
          "Profile",
          style: TextStyle(color: Colors.blue),
        ),
        actions: [
          IconButton(
            onPressed: signOut,
            icon: const Icon(Icons.logout),
          )
        ],
      ),
      body: Column(
        children: [
          Center(
            child: Column(
              children: [
                const Text(
                  'Current User:',
                  style: TextStyle(color: Color.fromARGB(255, 146, 146, 146)),
                ),
                getCurrentUserEmailTextWidget(),
              ],
            ),
          ),
          FutureBuilder<User?>(
            future: _getCurrentUser(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else if (snapshot.hasData) {
                User? user = snapshot.data;
                DateTime? creationTime = user?.metadata.creationTime;

                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                          'Account Created: ${creationTime?.toLocal() ?? 'Unknown'}'),
                    ],
                  ),
                );
              } else {
                return const Center(child: Text('No user signed in'));
              }
            },
          ),
        ],
      ),
    );
  }
}
