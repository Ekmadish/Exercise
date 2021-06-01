
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:demo2/api/chat_methods.dart';
import 'package:demo2/screens/orderdetail_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'WebOrderdetailpage.dart';
import 'package:timeago/timeago.dart' as timeago;

class FilesPage extends StatefulWidget {
  final String? userId;
  final String? title;
  FilesPage({Key? key, this.userId, this.title}) : super(key: key);

  @override
  _FilesPageState createState() => _FilesPageState();
}

class _FilesPageState extends State<FilesPage> {
  @override
  void initState() {
    super.initState();

    print("******************************************");
    print(widget.userId);
    print("******************************************");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(widget.title ?? "User"),
      ),
      body: SafeArea(
        child: StreamBuilder(
          stream: ChatMethods().fetchFiles(widget.userId),
          builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) =>
              filesCardWidget(snapshot),
        ),
      ),
    );
  }

  filesCardWidget(AsyncSnapshot<QuerySnapshot> snapshot) {
    if (snapshot.hasData) {
      return ListView.builder(
        shrinkWrap: true,
        itemCount: snapshot.data!.docs.length,
        itemBuilder: (context, index) {
          DocumentSnapshot file = snapshot.data!.docs[index];
          return InkWell(
            onTap: () =>
                Navigator.push(context, MaterialPageRoute(builder: (context) {
              // if (!Platform.isAndroid) {
              return WebOrderdetailpage(
                snapshot: file,
              );
              // } else
              // return Orderdetailpage(
              // snapshot: file,
              // );
            })),
            child: ListTile(

                // Access the fields as defined in FireStore  file.data['time']
                title: Text(
                    timeago.format(file.data()!['time'].toDate()).toString()),
                subtitle: Text("user.data['lastName']"),
                trailing: file.data()!['type'] == 'pdf'
                    ? Icon(Icons.picture_as_pdf)
                    : file.data()!['type'] == 'jpg'
                        ? Icon(Icons.book)
                        : Icon(Icons.image)),
          );
        },
      );
    } else if (snapshot.connectionState == ConnectionState.done &&
        !snapshot.hasData) {
      // Handle no data
      return Center(
        child: Text("No users found."),
      );
    } else {
      // Still loading
      return CircularProgressIndicator();
    }
  }
}
