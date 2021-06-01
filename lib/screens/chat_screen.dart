import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:demo2/api/chat_methods.dart';
import 'package:demo2/constance/constance.dart';
import 'package:demo2/functions/func.dart';
import 'package:demo2/functions/send_message.dart';
import 'package:demo2/models/message.dart';
import 'package:demo2/models/user.dart';
import 'package:demo2/screens/files_screen.dart';
import 'package:demo2/widget/cached_image.dart';
import 'package:demo2/widget/custom_title.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ChatScreen extends StatefulWidget {
  final User? receiver;

  ChatScreen({this.receiver});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  TextEditingController textFieldController = TextEditingController();
  FocusNode textFieldFocus = FocusNode();

  final Funcs _storageMethods = Funcs();
  final ChatMethods _chatMethods = ChatMethods();

  ScrollController _listScrollController = ScrollController();

  User? sender;

  String? _currentUserId;

  bool isWriting = false;

  bool showEmojiPicker = false;

  @override
  void initState() {
    super.initState();
    sender = senderUser;
  }

  showKeyboard() => textFieldFocus.requestFocus();

  hideKeyboard() => textFieldFocus.unfocus();

  hideEmojiContainer() {
    setState(() {
      showEmojiPicker = false;
    });
  }

  showEmojiContainer() {
    setState(() {
      showEmojiPicker = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.cyan,
      appBar: AppBar(
        centerTitle: true,
        title:
            Text(widget.receiver!.name!, style: TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            icon: Icon(Icons.contact_mail),
            tooltip: 'Manage users file',
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => FilesPage(
                            title: "User Files",
                            userId: widget.receiver!.id,
                          ),
                      fullscreenDialog: true));
            },
          ),
        ],
      ),
      body: Column(
        children: <Widget>[
          Flexible(
            child: messageList(),
          ),
          chatControls(),
          showEmojiPicker ? Container(child: emojiContainer()) : Container(),
        ],
      ),
    );
  }

  emojiContainer() {}

  Widget messageList() {
    return StreamBuilder(
      stream: messagesRef
          .doc(widget.receiver!.id)
          .collection(sender!.id!)
          .orderBy("timestamp", descending: true)
          .snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.data == null) {
          return Center(child: CircularProgressIndicator());
        }

        return ListView.builder(
          padding: EdgeInsets.all(10),
          controller: _listScrollController,
          reverse: true,
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            return chatMessageItem(snapshot.data!.docs[index]);
          },
        );
      },
    );
  }

  Widget chatMessageItem(DocumentSnapshot snapshot) {
    Message _message = Message.fromMap(snapshot.data()!);

    return Container(
      margin: EdgeInsets.symmetric(vertical: 15),
      child: Container(
        alignment: _message.senderId == sender!.id
            ? Alignment.centerRight
            : Alignment.centerLeft,
        child: _message.senderId == sender!.id
            ? senderLayout(_message)
            : receiverLayout(_message),
      ),
    );
  }

  Widget senderLayout(Message message) {
    Radius messageRadius = Radius.circular(10);

    return Container(
      margin: EdgeInsets.only(top: 12),
      constraints:
          BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.65),
      decoration: BoxDecoration(
        color: Color(0xff2b343b),
        borderRadius: BorderRadius.only(
          topLeft: messageRadius,
          topRight: messageRadius,
          bottomLeft: messageRadius,
        ),
      ),
      child: Column(
        children: [
          SizedBox(
            height: 5,
          ),
          Icon(
            Icons.policy,
            color: Colors.green,
          ),
          Padding(
            padding: EdgeInsets.all(10),
            child: getMessage(message),
          ),
        ],
      ),
    );
  }

  getMessage(Message message) {
    return message.type != MESSAGE_TYPE_IMAGE
        ? Text(
            message.message!,
            style: TextStyle(
              color: Colors.white,
              fontSize: 16.0,
            ),
          )
        : message.photoUrl != null
            ? CachedImage(
                message.photoUrl,
                height: 250,
                width: 250,
                radius: 10,
              )
            : Text("Url was null");
  }

  Widget receiverLayout(Message message) {
    Radius messageRadius = Radius.circular(10);

    return Container(
      margin: EdgeInsets.only(top: 12),
      constraints:
          BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.65),
      decoration: BoxDecoration(
        color: Color(0xff1e2225),
        borderRadius: BorderRadius.only(
          bottomRight: messageRadius,
          topRight: messageRadius,
          bottomLeft: messageRadius,
        ),
      ),
      child: Column(
        children: [
          SizedBox(
            height: 5,
          ),
          Icon(
            Icons.person,
            color: Colors.lightGreen,
          ),
          Padding(
            padding: EdgeInsets.all(10),
            child: getMessage(message),
          ),
        ],
      ),
    );
  }

  Widget chatControls() {
    setWritingTo(bool val) {
      setState(() {
        isWriting = val;
      });
    }

    addMediaModal(context) {
      showModalBottomSheet(
          context: context,
          elevation: 0,
          backgroundColor: Color(0xff19191b),
          builder: (context) {
            return Column(
              children: <Widget>[
                Container(
                  padding: EdgeInsets.symmetric(vertical: 15),
                  child: Row(
                    children: <Widget>[
                      FlatButton(
                        child: Icon(
                          Icons.close,
                        ),
                        onPressed: () => Navigator.maybePop(context),
                      ),
                      Expanded(
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "Content and tools",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Flexible(
                  child: ListView(
                    children: <Widget>[
                      ModalTile(
                        title: "Media",
                        subtitle: "Share Photos and Video",
                        icon: Icons.image,
                        onTap: () => pickImage(source: ImageSource.gallery),
                      ),
                      ModalTile(
                        title: "File",
                        subtitle: "Share files",
                        icon: Icons.tab,
                      ),
                      ModalTile(
                        title: "Contact",
                        subtitle: "Share contacts",
                        icon: Icons.contacts,
                      ),
                      ModalTile(
                        title: "Location",
                        subtitle: "Share a location",
                        icon: Icons.add_location,
                      ),
                      ModalTile(
                        title: "Schedule Call",
                        subtitle: "Arrange a skype call and get reminders",
                        icon: Icons.schedule,
                      ),
                      ModalTile(
                        title: "Create Poll",
                        subtitle: "Share polls",
                        icon: Icons.poll,
                      )
                    ],
                  ),
                ),
              ],
            );
          });
    }

    sendMessage() {
      var text = textFieldController.text;

      Message _message = Message(
        receiverId: widget.receiver!.id,
        senderId: sender!.id,
        message: text,
        timestamp: Timestamp.now(),
        type: 'text',
      );

      setState(() {
        isWriting = false;
      });

      textFieldController.text = "";

      _chatMethods
          .addMessageToDb(_message, sender, widget.receiver)
          .whenComplete(() => SendMessage().sendMessage(
              widget.receiver!.token!, _message.message!, "Admin"));
    }

    return Container(
      padding: EdgeInsets.all(10),
      child: Row(
        children: <Widget>[
          GestureDetector(
            onTap: () => addMediaModal(context),
            child: Container(
              padding: EdgeInsets.all(5),
              decoration: BoxDecoration(
                gradient: UniversalVariables.fabGradient,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.add),
            ),
          ),
          SizedBox(
            width: 5,
          ),
          Expanded(
            child: Stack(
              alignment: Alignment.centerRight,
              children: [
                TextField(
                  controller: textFieldController,
                  focusNode: textFieldFocus,
                  onTap: () => hideEmojiContainer(),
                  style: TextStyle(
                    color: Colors.white,
                  ),
                  onChanged: (val) {
                    (val.length > 0 && val.trim() != "")
                        ? setWritingTo(true)
                        : setWritingTo(false);
                  },
                  decoration: InputDecoration(
                    hintText: "Type a message",
                    hintStyle: TextStyle(
                      color: Color(0xff8f8f8f),
                    ),
                    border: OutlineInputBorder(
                        borderRadius: const BorderRadius.all(
                          const Radius.circular(50.0),
                        ),
                        borderSide: BorderSide.none),
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                    filled: true,
                    fillColor: Color(0xff272c35),
                  ),
                ),
                IconButton(
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  onPressed: () {
                    if (!showEmojiPicker) {
                      hideKeyboard();
                      showEmojiContainer();
                    } else {
                      showKeyboard();
                      hideEmojiContainer();
                    }
                  },
                  icon: Icon(Icons.face),
                ),
              ],
            ),
          ),
          isWriting
              ? Container()
              : Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: Icon(Icons.record_voice_over),
                ),
          isWriting
              ? Container()
              : GestureDetector(
                  child: Icon(Icons.camera_alt),
                  onTap: () => pickImage(source: ImageSource.camera),
                ),
          isWriting
              ? Container(
                  margin: EdgeInsets.only(left: 10),
                  decoration: BoxDecoration(
                      gradient: UniversalVariables.fabGradient,
                      shape: BoxShape.circle),
                  child: IconButton(
                    icon: Icon(
                      Icons.send,
                      size: 15,
                    ),
                    onPressed: () => sendMessage(),
                  ))
              : Container()
        ],
      ),
    );
  }

  void pickImage({required ImageSource source}) async {
    PickedFile _selectedImage = await (ImagePicker.platform
        .pickImage(source: source) as FutureOr<PickedFile>);

    File selectedImage = File(_selectedImage.path);

    _storageMethods.uploadImage(
      image: selectedImage,
      receiverId: widget.receiver!.id,
      senderId: _currentUserId,
    );
  }
}

class ModalTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Function? onTap;

  const ModalTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 15),
      child: CustomTile(
        mini: false,
        onTap: onTap as void Function()?,
        leading: Container(
          margin: EdgeInsets.only(right: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            color: Color(0xff1e2225),
          ),
          padding: EdgeInsets.all(10),
          child: Icon(
            icon,
            color: Color(0xff8f8f8f),
            size: 38,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            color: Color(0xff8f8f8f),
            fontSize: 14,
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 18,
          ),
        ),
      ),
    );
  }
}
