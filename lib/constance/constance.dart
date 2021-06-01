import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:demo2/models/user.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

final _firestore = FirebaseFirestore.instance;
final storageRef = FirebaseStorage.instance.ref();
final usersRef = _firestore.collection('users');
final postsRef = _firestore.collection('posts');
final docxFileRef = _firestore.collection("docxFiles");
final pdfFileRef = _firestore.collection("pdfFiles");
final imageFileRef = _firestore.collection("imageFiles");
final messagesRef = _firestore.collection("messages");
final contactsRef = _firestore.collection("contacts");
final fileRef = _firestore.collection("userFiles");

const String MESSAGE_TYPE_IMAGE = "image";

final String name = "Admin";
final String photoUrl = "http://sns-hub.com/img/admin.png";
final String receiverUid = "demoID";

final mapKey = "AIzaSyBVaeQvza2CrBjwLRMLOnLQ5kUHqPDMjss";

class UniversalVariables {
  static final Color gradientColorStart = Color(0xff00b6f3);
  static final Color gradientColorEnd = Color(0xff0184dc);
  static final Gradient fabGradient = LinearGradient(
      colors: [gradientColorStart, gradientColorEnd],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight);
}

final User senderUser = User(
    id: "Admin",
    email: "admin@gmail.com",
    name: "Admin",
    profileImageUrl: "",
    token: "Admin",
    timeCreated: Timestamp.now());
