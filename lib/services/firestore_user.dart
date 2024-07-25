import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreUserService {
  final CollectionReference users =
      FirebaseFirestore.instance.collection('users');

  Stream<QuerySnapshot> getUsersStream() {
    final usersStream = users.orderBy('email', descending: true).snapshots();
    return usersStream;
  }

  Future<void> addUser() {
    User? currentUser = FirebaseAuth.instance.currentUser;

    return users.add({
      'email': currentUser?.email.toString(),
      'following': [],
      'followers': [],
      'timestamp': Timestamp.now(),
    });
  }

  Future<void> followAUser(String emailUserToFollow) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      print("No authenticated user.");
      return;
    }

    String currentUserEmail = user.email!;
    print('Current user email: $currentUserEmail');
    print('User to follow: $emailUserToFollow');

    try {
      // Finn dokument-ID-en for brukeren som skal følges basert på e-post
      QuerySnapshot querySnapshotToFollow = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: emailUserToFollow)
          .limit(1)
          .get();

      if (querySnapshotToFollow.docs.isEmpty) {
        print("User to follow does not exist!");
        return;
      }

      DocumentSnapshot userToFollowSnapshot = querySnapshotToFollow.docs.first;
      String userToFollowId = userToFollowSnapshot.id;
      DocumentReference userToFollowRef =
          FirebaseFirestore.instance.collection('users').doc(userToFollowId);

      // Finn dokument-ID-en for den nåværende brukeren basert på e-post
      QuerySnapshot querySnapshotCurrentUser = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: currentUserEmail)
          .limit(1)
          .get();

      if (querySnapshotCurrentUser.docs.isEmpty) {
        print("Current user does not exist!");
        return;
      }

      DocumentSnapshot currentUserSnapshot =
          querySnapshotCurrentUser.docs.first;
      String currentUserId = currentUserSnapshot.id;
      DocumentReference currentUserRef =
          FirebaseFirestore.instance.collection('users').doc(currentUserId);

      await FirebaseFirestore.instance.runTransaction((transaction) async {
        // Hent og oppdater 'followers' listen for brukeren som skal følges
        DocumentSnapshot userToFollowData =
            await transaction.get(userToFollowRef);
        List<String> followersList =
            List<String>.from(userToFollowData['followers'] ?? []);
        print('Current followers list: $followersList');

        if (followersList.contains(currentUserEmail)) {
          followersList.remove(currentUserEmail);
          print('Removed $currentUserEmail from followers list');
        } else {
          followersList.add(currentUserEmail);
          print('Added $currentUserEmail to followers list');
        }

        // Hent og oppdater 'following' listen for den nåværende brukeren
        DocumentSnapshot currentUserData =
            await transaction.get(currentUserRef);
        List<String> followingList =
            List<String>.from(currentUserData['following'] ?? []);
        print('Current following list: $followingList');

        if (followingList.contains(emailUserToFollow)) {
          followingList.remove(emailUserToFollow);
          print('Removed $emailUserToFollow from following list');
        } else {
          followingList.add(emailUserToFollow);
          print('Added $emailUserToFollow to following list');
        }

        // Oppdater dokumentene
        transaction.update(userToFollowRef, {'followers': followersList});
        transaction.update(currentUserRef, {'following': followingList});

        print('Transaction completed successfully.');
      });
    } catch (e, stackTrace) {
      print("Failed to follow user: $e");
      print("Stack trace: $stackTrace");
    }
  }
}
