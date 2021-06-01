import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:group_button/group_button.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:url_launcher/url_launcher.dart';

class WebOrderdetailpage extends StatefulWidget {
  final DocumentSnapshot? snapshot;

  const WebOrderdetailpage({Key? key, this.snapshot}) : super(key: key);
  @override
  _WebOrderdetailpageState createState() => _WebOrderdetailpageState();
}

class _WebOrderdetailpageState extends State<WebOrderdetailpage> {
  String? _verticalGroupValue;
  List<String> _status = ["Pending", "Released", "Blocked"];

  @override
  void initState() {
    super.initState();
    _verticalGroupValue = widget.snapshot!.data()!['status'];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        // child: Container(
        //   height: MediaQuery.of(context).size.height / 2,
        //   width: MediaQuery.of(context).size.width,
        // color: Colors.greenAccent,
        child: Column(
          children: [
            Card(
              child: Container(
                margin: EdgeInsets.all(5),
                // height: MediaQuery.of(context).size.height / 3,
                width: MediaQuery.of(context).size.width,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _imgaeContainer(widget.snapshot!.data()!['fileUrl'],
                            widget.snapshot!.data()!['name']),
                        _imgaeContainer(
                            widget.snapshot!.data()!['paymentPdfUrl'],
                            widget.snapshot!.data()!['paymentId']),
                      ],
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    Container(
                      decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(5)),
                      child: ListTile(
                        title: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text("Order  Detail : " +
                                widget.snapshot!.data()!['info'].toString()),
                            Text(timeago
                                .format(
                                    widget.snapshot!.data()!['time'].toDate())
                                .toString()),
                            Text("Order name : " +
                                widget.snapshot!.data()!['name'].toString()),
                            Text("Type :" +
                                widget.snapshot!.data()!['type'].toString()),
                            Text("Status :" + _verticalGroupValue.toString()),
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: Colors.white,
                                boxShadow: [
                                  BoxShadow(
                                      color: Colors.blue, spreadRadius: 3),
                                ],
                              ),
                              child: Center(
                                child: GroupButton(
                                  isRadio: true,
                                  spacing: 10,
                                  onSelected: (index, isSelected) =>
                                      setState(() {
                                    _verticalGroupValue = _status[index];

                                    updateval(_status[index]);
                                  }),
                                  buttons: _status,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _launchInWebViewOrVC(String? url, String? name) async {
    print("***************************************************");
    print(name);
    print(url);
    print("***************************************************");

    if (await canLaunch(url!)) {
      await launch(
        url,
        forceSafariVC: true,
        forceWebView: true,
        headers: <String, String>{'my_header_key': 'my_header_value'},
      );
    } else {
      throw 'Could not launch $url';
    }
  }

  updateval(String status) async {
    await widget.snapshot!.reference.update({"status": status});

    // updateData({"status": status});
  }

  Widget _imgaeContainer(String? url, String? fileName) {
    return Container(
      width: MediaQuery.of(context).size.width / 2.5,
      height: MediaQuery.of(context).size.height / 5,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(5)),
        image: DecorationImage(
          fit: BoxFit.fill,
          image: NetworkImage("https://picsum.photos/250?image=9"),
        ),
      ),
      child: Align(
          alignment: Alignment.bottomLeft,
          child: Container(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  "data size ",
                  style: TextStyle(
                    fontSize: 24,
                  ),
                ),
                IconButton(
                    icon: Icon(
                      Icons.download_rounded,
                      size: 35,
                    ),
                    onPressed: () {
                      _launchInWebViewOrVC(url, fileName);
                    }),
              ],
            ),
          )),
    );
  }
}
