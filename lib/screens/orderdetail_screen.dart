import 'dart:convert';
import 'dart:io';

// import 'package:downloads_path_provider_28/downloads_path_provider_28.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:group_button/group_button.dart';
import 'package:open_file/open_file.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
// import 'package:group_radio_button/group_radio_button.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:path/path.dart' as path;

class Orderdetailpage extends StatefulWidget {
  final DocumentSnapshot? snapshot;
  Orderdetailpage({Key? key, this.snapshot}) : super(key: key);

  @override
  _OrderdetailpageState createState() => _OrderdetailpageState();
}

class _OrderdetailpageState extends State<Orderdetailpage> {
  String? _verticalGroupValue;

  final Dio _dio = Dio();
  String _progress = "-";

  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  @override
  void initState() {
    super.initState();
    _verticalGroupValue = widget.snapshot!.data()!['status'];
    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    final android = AndroidInitializationSettings('@mipmap/ic_launcher');
    final iOS = IOSInitializationSettings();
    final initSettings = InitializationSettings(android: android, iOS: iOS);

    flutterLocalNotificationsPlugin.initialize(initSettings,
        onSelectNotification: _onSelectNotification);
  }

  Future<void> _onSelectNotification(String? json) async {
    final obj = jsonDecode(json!);

    if (obj['isSuccess']) {
      OpenFile.open(obj['filePath']);
    } else {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text('Error'),
          content: Text('${obj['error']}'),
        ),
      );
    }
  }

  Future<void> _showNotification(Map<String, dynamic> downloadStatus) async {
    final android = AndroidNotificationDetails(
      'channel id',
      'channel name',
      'channel description',
      priority: Priority.high,
      importance: Importance.max,
      // playSound: true,
      // sound: RawResourceAndroidNotificationSound('d'),
    );
    final iOS = IOSNotificationDetails();
    final platform = NotificationDetails(android: android, iOS: iOS);
    final json = jsonEncode(downloadStatus);
    final isSuccess = downloadStatus['isSuccess'];

    await flutterLocalNotificationsPlugin.show(
        0, // notification id
        isSuccess ? 'Success' : 'Failure',
        isSuccess
            ? 'File has been downloaded successfully!'
            : 'There was an error while downloading the file.',
        platform,
        payload: json);
  }

  Future<bool> _requestPermissions() async {
    // var permission = await PermissionHandler()
    // .checkPermissionStatus(PermissionGroup.storage);

    var _permission = await Permission.storage.status;

    // if (permission != PermissionStatus.granted) {
    if (_permission.isGranted) {
      await Permission.storage.request();
      _permission = await Permission.storage.status;
    }
    return _permission == PermissionStatus.granted;
    //   await PermissionHandler().requestPermissions([PermissionGroup.storage]);
    //   permission = await PermissionHandler()
    //       .checkPermissionStatus(PermissionGroup.storage);
    // }
    // return permission == PermissionStatus.granted;
  }

  void _onReceiveProgress(int received, int total) {
    if (total != -1) {
      setState(() {
        _progress = (received / total * 100).toStringAsFixed(0) + "%";
      });
    }
  }

  Future<void> _startDownload(String url, String savePath) async {
    Map<String, dynamic> result = {
      'isSuccess': false,
      'filePath': null,
      'error': null,
    };
    try {
      final response = await _dio.download(url, savePath,
          onReceiveProgress: _onReceiveProgress);
      result['isSuccess'] = response.statusCode == 200;
      result['filePath'] = savePath;
    } catch (ex) {
      result['error'] = ex.toString();
    } finally {
      await _showNotification(result);
    }
  }

  Future<String> _findLocalPath() async {
    // 因为Apple没有外置存储，所以第一步我们需要先对所在平台进行判断
    // 如果是android，使用getExternalStorageDirectory
    // 如果是iOS，使用getApplicationSupportDirectory
    final directory = Theme.of(context).platform == TargetPlatform.android
        ? await getExternalStorageDirectory()
        : await getApplicationSupportDirectory();
    return directory!.path;
  }

  Future<void> _download(String? url, String? fileName) async {
    print("*********************************************");
    print(url);
    print(fileName);
    final dir = await _findLocalPath() + '/Download';
    print(dir.toString());
    print("*********************************************");
    final isPermissionStatusGranted = await _requestPermissions();

    if (isPermissionStatusGranted) {
      final savePath = path.join(dir, fileName);
      await _startDownload(url!, savePath);
    } else {
      // handle the scenario when user declines the permissions
    }
  }

  List<String> _status = ["Pending", "Released", "Blocked"];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: Center(
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
                          _imgaeContainer(widget.snapshot!.data()!['fileUrl'],
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
                                  )
                                  //
                                  //
                                  //  RadioGroup<String>.builder(
                                  //   direction: Axis.horizontal,
                                  //   groupValue: _verticalGroupValue,
                                  //   onChanged: (value) => setState(() {
                                  //     _verticalGroupValue = value;

                                  //     updateval(value);
                                  //   }),
                                  //   items: _status,
                                  //   itemBuilder: (value) => RadioButtonBuilder(
                                  //     value,
                                  //   ),
                                  // ),
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
      ),
      // ),
    );
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
                    onPressed: () => _download(url, fileName)),
              ],
            ),
          )),
    );
  }

  // Widget popMenu() {
  //   return PopupMenuButton(
  //       tooltip: "Change status ",
  //       child: Container(
  //         padding: EdgeInsets.all(15),
  //         child: Shimmer.fromColors(
  //           baseColor: Colors.red,
  //           highlightColor: Colors.yellow,
  //           child: Row(
  //             mainAxisAlignment: MainAxisAlignment.end,
  //             children: [
  //               Text(widget.snapshot.data['status'].toString()),
  //               SizedBox(
  //                 width: 10,
  //               ),
  //               Icon(
  //                 Icons.autorenew_sharp,
  //                 color: Colors.greenAccent,
  //               ),
  //             ],
  //           ),
  //         ),
  //       ),
  //       onSelected: (v) {
  //         Fluttertoast.showToast(
  //             msg: "You have selected " + v.toString(),
  //             toastLength: Toast.LENGTH_SHORT,
  //             gravity: ToastGravity.BOTTOM,
  //             timeInSecForIosWeb: 1,
  //             backgroundColor: Colors.black,
  //             textColor: Colors.white,
  //             fontSize: 16.0);
  //       },
  //       itemBuilder: (context) => [
  //             PopupMenuItem(
  //                 value: 1,
  //                 child: Row(
  //                   children: <Widget>[
  //                     Padding(
  //                       padding: const EdgeInsets.fromLTRB(2, 2, 8, 2),
  //                       child: Icon(Icons.print),
  //                     ),
  //                     Text('Print')
  //                   ],
  //                 )),
  //             PopupMenuItem(
  //                 value: 2,
  //                 child: Row(
  //                   children: <Widget>[
  //                     Padding(
  //                       padding: const EdgeInsets.fromLTRB(2, 2, 8, 2),
  //                       child: Icon(Icons.share),
  //                     ),
  //                     Text('Share')
  //                   ],
  //                 )),
  //             PopupMenuItem(
  //                 value: 3,
  //                 child: Row(
  //                   children: <Widget>[
  //                     Padding(
  //                       padding: const EdgeInsets.fromLTRB(2, 2, 8, 2),
  //                       child: Icon(Icons.add_circle),
  //                     ),
  //                     Text('Add')
  //                   ],
  //                 )),
  //           ]);
  // }

}
