import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreService {
  final CollectionReference posts =
      FirebaseFirestore.instance.collection('posts');

  Stream<QuerySnapshot> getPostsStream() {
    final postsStream =
        posts.orderBy('timestamp', descending: true).snapshots();
    return postsStream;
  }

  Stream<QuerySnapshot> getPostsStreamCurrentUser() {
    // Hent den innloggede brukeren
    User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      // Returner en tom stream eller håndter tilfelle der ingen bruker er logget inn
      return const Stream.empty();
    }

    String currentUserEmail = user.email ?? ''; // Brukerens e-post
    print('Hentet brukerens e-post: $currentUserEmail');

    final postsStream = posts
        .where('createdBy', isEqualTo: currentUserEmail)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .handleError((error) {
      print('Feil ved henting av data: $error');
    });

    return postsStream;
  }

  Future<void> addPost(
      String title, String text, String imageUrl, String user) {
    return posts.add({
      'title': title,
      'timestamp': Timestamp.now(),
      'text': text,
      'imageUrl': imageUrl,
      'createdBy': user,
    });
  }

  Future<void> updatePost(
      String docID, String title, String text, String imageUrl) {
    return posts.doc(docID).update({
      'title': title,
      'timestamp': Timestamp.now(),
      'text': text,
      'imageUrl': imageUrl,
    });
  }

  Future<void> deletePost(String docID) {
    return posts.doc(docID).delete();
  }
}
