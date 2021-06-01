import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  String? id;
  String? name;
  String? email;
  String? token;
  // String status;
  // int state;
  String? profileImageUrl;
  Timestamp? timeCreated;

  User(
      {this.id,
      this.name,
      this.email,
      // this.status,
      // this.state,
      this.profileImageUrl,
      this.token,
      this.timeCreated});

  Map toMap(User user) {
    var data = Map<String, dynamic>();
    data['id'] = user.id;
    data['name'] = user.name;
    data['email'] = user.email;
    data['token'] = user.token;
    data['timeCreated'] = user.timeCreated;
    // data["status"] = user.status;
    // data["state"] = user.state;
    data["profileImageUrl"] = user.profileImageUrl;
    return data;
  }

  // Named constructor
  User.fromMap(Map<String, dynamic> mapData) {
    this.id = mapData['id'];
    this.name = mapData['name'];
    this.email = mapData['email'];
    this.timeCreated = mapData['timeCreated'];
    // this.status = mapData['status'];
    // this.state = mapData['state'];
    this.token = mapData['token'];
    this.profileImageUrl = mapData['profileImageUrl'];
  }
}
