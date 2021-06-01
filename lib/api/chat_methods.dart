import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:demo2/constance/constance.dart';
import 'package:demo2/constance/string.dart';
import 'package:demo2/models/contact.dart';
import 'package:demo2/models/message.dart';
import 'package:demo2/models/user.dart';

class ChatMethods {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final CollectionReference _messageCollection =
      _firestore.collection(MESSAGES_COLLECTION);

  final CollectionReference _userCollection =
      _firestore.collection(USERS_COLLECTION);

  Future<DocumentReference> addMessageToDb(
      Message message, User? sender, User? receiver) async {
    var map = message.toMap();

    await _messageCollection
        .doc(message.senderId)
        .collection(message.receiverId!)
        .add(map as Map<String, dynamic>);

    addToContacts(senderId: message.senderId, receiverId: message.receiverId);

    return await _messageCollection
        .doc(message.receiverId)
        .collection(message.senderId!)
        .add(map);
  }

  DocumentReference getContactsDocument({String? of, String? forContact}) =>
      _userCollection.doc(of).collection(CONTACTS_COLLECTION).doc(forContact);

  addToContacts({String? senderId, String? receiverId}) async {
    Timestamp currentTime = Timestamp.now();

    await addToSenderContacts(senderId, receiverId, currentTime);
    await addToReceiverContacts(senderId, receiverId, currentTime);
  }

  Future<void> addToSenderContacts(
    String? senderId,
    String? receiverId,
    currentTime,
  ) async {
    DocumentSnapshot senderSnapshot =
        await getContactsDocument(of: senderId, forContact: receiverId).get();

    if (!senderSnapshot.exists) {
      //does not exists
      Contact receiverContact = Contact(
        uid: receiverId,
        addedOn: currentTime,
      );

      var receiverMap = receiverContact.toMap(receiverContact);

      await getContactsDocument(of: senderId, forContact: receiverId)
          .set(receiverMap as Map<String, dynamic>);
    }
  }

  Future<void> addToReceiverContacts(
    String? senderId,
    String? receiverId,
    currentTime,
  ) async {
    DocumentSnapshot receiverSnapshot =
        await getContactsDocument(of: receiverId, forContact: senderId).get();

    if (!receiverSnapshot.exists) {
      //does not exists
      Contact senderContact = Contact(
        uid: senderId,
        addedOn: currentTime,
      );

      var senderMap = senderContact.toMap(senderContact);

      await getContactsDocument(of: receiverId, forContact: senderId)
          .set(senderMap as Map<String, dynamic>);
    }
  }

  void setImageMsg(String? url, String? receiverId, String? senderId) async {
    Message message;

    message = Message.imageMessage(
        message: "IMAGE",
        receiverId: receiverId,
        senderId: senderId,
        photoUrl: url,
        timestamp: Timestamp.now(),
        type: 'image');

    // create imagemap
    var map = message.toImageMap();

    // var map = Map<String, dynamic>();
    await _messageCollection
        .doc(message.senderId)
        .collection(message.receiverId!)
        .add(map as Map<String, dynamic>);

    _messageCollection
        .doc(message.receiverId)
        .collection(message.senderId!)
        .add(map);
  }

  Stream<QuerySnapshot> fetchContacts({String? userId}) =>
      contactsRef.doc(userId).collection(CONTACTS_COLLECTION).snapshots();

  Stream<QuerySnapshot> fetchFiles(String? userId) =>
      fileRef.doc(userId).collection("files").snapshots();

  Stream<QuerySnapshot> fetchLastMessageBetween({
    required String senderId,
    required String receiverId,
  }) =>
      _messageCollection
          .doc(senderId)
          .collection(receiverId)
          .orderBy("timestamp")
          .snapshots();

  void addmessageToDb() async {}
}
