import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:demo2/api/chat_methods.dart';
import 'package:demo2/constance/constance.dart';
import 'package:demo2/models/user.dart';
import 'package:firebase_storage/firebase_storage.dart';

class Funcs {
  static Future<User?> getUserDetailsById(id) async {
    try {
      DocumentSnapshot documentSnapshot = await usersRef.doc(id).get();
      return User.fromMap(documentSnapshot.data()!);
    } catch (e) {
      print(e);
      return null;
    }
  }

  static Stream<QuerySnapshot> fetchLastMessageBetween({
    required String senderId,
    required String receiverId,
  }) =>
      messagesRef
          .doc(senderId)
          .collection(receiverId)
          .orderBy("timestamp")
          .snapshots();

  static final FirebaseFirestore firestore = FirebaseFirestore.instance;

  late Reference _storageReference;

  //user class
  User user = User();

  Future<String?> uploadImageToStorage(File imageFile) async {
    // mention try catch later on

    try {
      _storageReference = FirebaseStorage.instance
          .ref()
          .child('${DateTime.now().millisecondsSinceEpoch}');

      UploadTask storageUploadTask = _storageReference.putFile(imageFile);
      var url = await storageUploadTask.storage.ref().getDownloadURL();

      // .ref
      // .getDownloadURL();
      // print(url);
      return url;
    } catch (e) {
      return null;
    }
  }

  void uploadImage({
    required File image,
    required String? receiverId,
    required String? senderId,
    // @required ImageUploadProvider imageUploadProvider,
  }) async {
    final ChatMethods chatMethods = ChatMethods();

    // Set some loading value to db and show it to user
    // imageUploadProvider.setToLoding();

    // Get url from the image bucket
    String? url = await uploadImageToStorage(image);

    // Hide loading
    // imageUploadProvider.setToIdel();

    chatMethods.setImageMsg(url, receiverId, senderId);
  }
}
