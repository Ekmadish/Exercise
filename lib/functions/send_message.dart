import 'package:dio/dio.dart';

class SendMessage {
  Future<Response> sendMessage(String token, String bodyM, String title) async {
    final postUrl = 'https://fcm.googleapis.com/fcm/send';
    // final data = {
    //   'notification': {'title': "dededed", 'body': bodyM},
    //   'data': {'click_action': 'FLUTTER_NOTIFICATION_CLICK', 'type': 'COMMENT'},
    //   'to': 't'
    // };
    final data = {
      "notification": {"body": bodyM, "title": title},
      "priority": "high",
      "data": {
        "click_action": "FLUTTER_NOTIFICATION_CLICK",
        "id": "1",
        "status": "done"
      },
      "to": token
    };
    final headers = {
      'content-type': 'application/json',
      'Authorization':
          'key=AAAApQl92I8:APA91bE_LWFT2bzuCOkuLDtQVh6Rm3EeM1d23KdCjYgDyNVFYEE6iPCzKJ-CzQx10VY5y5B9ypTg5_8VxiItuS8C-kcy01dGoKU4EkLd4ppEDmHDfSRKmaMDe60d6za_7A4DyPk9itIi'
    };

    final response = await Dio()
        .post(postUrl, data: data, options: Options(headers: headers));

    // print(response.data.toString());

    return response;
  }
}
