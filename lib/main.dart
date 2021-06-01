import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'api/chat_methods.dart';
import 'constance/constance.dart';
import 'models/contact.dart';
import 'widget/contact_view.dart';
import 'widget/quietBox.dart';

import 'package:flutter/foundation.dart' show kIsWeb;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "demo",
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: !kIsWeb ? MyHomePage() : MyHomePageWeb(),
    );
  }
}

class MyHomePageWeb extends StatefulWidget {
  MyHomePageWeb({Key? key}) : super(key: key);

  @override
  _MyHomePageWebState createState() => _MyHomePageWebState();
}

class _MyHomePageWebState extends State<MyHomePageWeb> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("Chat"),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: ChatMethods().fetchContacts(userId: "Admin"),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            var docList = snapshot.data!.docs;
            if (docList.isEmpty) {
              return QuietBox();
            }
            return ListView.builder(
              shrinkWrap: true,
              physics: BouncingScrollPhysics(),
              padding: EdgeInsets.all(10),
              itemCount: docList.length,
              itemBuilder: (context, index) {
                Contact contact = Contact.fromMap(docList[index].data());
                return ContactView(contact);
              },
            );
          } else
            return Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  FlutterLocalNotificationsPlugin fltNotification =
      FlutterLocalNotificationsPlugin();
  int? count;
  final ChatMethods _chatMethods = ChatMethods();
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final DocumentReference _userCollection =
      _firestore.collection('/users').doc('Admin');
  String toToken = '';
  @override
  void initState() {
    super.initState();
    getToken().whenComplete(() => refreshAdmin());
  }

  getToken() async {
    final token = await messaging.getToken();
    setState(() {
      toToken = token!;
    });
    print('********* Token is : $token');
  }

  refreshAdmin() {
    _userCollection.set({
      'id': 'admin_id',
      'name': 'Admin',
      'email': 'admin@mail.kz',
      'profileImageUrl': "",
      'token': toToken,
      // 'isVerified': false,
      // 'role': 'user',
      'timeCreated': Timestamp.now(),
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("Chat"),
      ),
      body: Container(
        child: StreamBuilder<QuerySnapshot>(
          stream: _chatMethods.fetchContacts(userId: "Admin"),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              var docList = snapshot.data!.docs;
              if (docList.isEmpty) {
                return QuietBox();
              }
              return ListView.builder(
                shrinkWrap: true,
                physics: BouncingScrollPhysics(),
                padding: EdgeInsets.all(10),
                itemCount: docList.length,
                itemBuilder: (context, index) {
                  Contact contact = Contact.fromMap(docList[index].data());
                  return ContactView(contact);
                },
              );
            } else
              return Center(child: CircularProgressIndicator());
          },
        ),
      ),
    );
  }
}
