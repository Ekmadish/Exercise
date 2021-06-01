import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:demo2/api/chat_methods.dart';
import 'package:demo2/functions/func.dart';
import 'package:demo2/models/contact.dart';
import 'package:demo2/models/user.dart';
import 'package:demo2/screens/chat_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'custom_title.dart';
import 'last_message_container.dart';

class ContactView extends StatefulWidget {
  final Contact contact;
  // final AuthMethods _authMethods = AuthMethods();

  ContactView(this.contact);

  @override
  _ContactViewState createState() => _ContactViewState();
}

class _ContactViewState extends State<ContactView> {
  Future<Null> checkFocChanges(String? s) async {
    FirebaseFirestore.instance.runTransaction((Transaction tx) async {
      CollectionReference reference = FirebaseFirestore.instance.collection(s!);
      reference.snapshots().listen((event) {
        event.docChanges.forEach((element) {
          print(element.newIndex.toString());
          print(element.doc.data());
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    // print(
    //     "-------------------------------------------------------------------------");
    // print(contact.addedOn);
    // print(contact.uid);
    // print("-----------------------------------------------------------");

    return FutureBuilder<User?>(
      future: Funcs.getUserDetailsById(widget.contact.uid),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          User? user = snapshot.data;

          // print(
          //     "**************************************************************");
          // print("email " + snapshot.data.email);
          // print("id " + snapshot.data.id);
          // print("time created " + snapshot.data.timeCreated.toString());
          // print("name " + snapshot.data.name);
          // print(
          //     "**************************************************************");

          return ViewLayout(
            contact: user,
          );
        }
        return Center(
            // child: CircularProgressIndicator(),
            );
      },
    );
  }
}

class ViewLayout extends StatelessWidget {
  final User? contact;

  ViewLayout({
    required this.contact,
  });

  @override
  Widget build(BuildContext context) {
    // final UserProvider userProvider = Provider.of<UserProvider>(context);

    return Card(
      child: CustomTile(
        margin: EdgeInsets.all(5),
        mini: false,
        onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              fullscreenDialog: true,
              builder: (context) => ChatScreen(
                receiver: contact,
              ),
            )),
        title: Text(
          (contact != null ? contact!.name : null) != null
              ? contact!.name!
              : "..",
          style:
              TextStyle(color: Colors.black, fontFamily: "Arial", fontSize: 19),
        ),
        trailing: Container(
          height: 55,
          width: 55,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(35),
            color: Colors.blueAccent.withOpacity(0.6),
          ),
          child: InkWell(
            splashColor: Colors.blueAccent,
            borderRadius: BorderRadius.circular(35),
            onLongPress: () {
              showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                        title: Text("Do you want delete this message ? "),
                        actions: [
                          Row(
                            mainAxisSize: MainAxisSize.max,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              ButtonBar(
                                children: [
                                  IconButton(
                                      icon: Icon(Icons.done), onPressed: () {}),
                                  IconButton(
                                      icon: Icon(Icons.close), onPressed: () {})
                                ],
                              )
                            ],
                          )
                        ],
                      ));
            },
            child: Icon(Icons.delete),
          ),
        ),
        subtitle: LastMessageContainer(
          stream: Funcs.fetchLastMessageBetween(
            senderId: "Admin",
            receiverId: contact!.id!,
          ),
        ),
        leading: Container(
          constraints: BoxConstraints(maxHeight: 55, maxWidth: 55),
          child: Stack(
            textDirection: TextDirection.rtl,
            children: <Widget>[
              // contact.profileImageUrl.isNotEmpty ??
              // ? CachedImage(
              //     contact?.profileImageUrl ?? "",
              //     radius: 80,
              //     isRound: true,
              //   )
              // :

              CircleAvatar(
                radius: 35,
                backgroundImage: AssetImage("assets/logo.png"),
              )
            ],
          ),
        ),
      ),
    );
  }
}
