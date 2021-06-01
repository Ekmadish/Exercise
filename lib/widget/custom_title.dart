import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class CustomTile extends StatelessWidget {
  final Widget leading;
  final Widget title;
  final Widget? icon;
  final Widget subtitle;
  final Widget? trailing;
  final EdgeInsets margin;
  final bool mini;

  final GestureTapCallback? onTap;

  final GestureLongPressCallback? onLongPress;

  const CustomTile(
      {this.icon,
      required this.leading,
      this.margin = const EdgeInsets.all(0),
      required this.subtitle,
      required this.title,
      this.trailing,
      this.mini = true,
      this.onLongPress,
      this.onTap,
      Stream<QuerySnapshot>? stream});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: mini ? 10 : 0),
        margin: margin,
        child: Row(
          children: <Widget>[
            leading,
            Expanded(
                child: Container(
              margin: EdgeInsets.only(left: mini ? 10 : 15),
              padding: EdgeInsets.symmetric(vertical: mini ? 3 : 20),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    width: 1,
                    color: Colors.greenAccent,
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      title,
                      SizedBox(height: 5),
                      Row(
                        children: [
                          icon ?? Container(),
                          icon != null ? icon! : Container(),
                          subtitle,
                        ],
                      )
                    ],
                  ),
                  trailing ?? Container(),
                ],
              ),
            ))
          ],
        ),
      ),
    );
  }
}
