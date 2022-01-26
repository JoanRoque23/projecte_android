import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:device_apps/device_apps.dart';
import 'dart:async';

// ignore: must_be_immutable
class AppScreenGetter extends StatefulWidget {
  String nickname;
  String sesionId;

  AppScreenGetter({
    Key? key,
    required this.nickname,
    required this.sesionId,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _FirstScreen();
  }
}

class _FirstScreen extends State<AppScreenGetter> {
  List<Application>? apps;
  final db = FirebaseFirestore.instance;
  @override
  void initState() {
    super.initState();
    getApp();
  }

  Future<void> getApp() async {
    List<Application> _apps = await DeviceApps.getInstalledApplications(
      onlyAppsWithLaunchIntent: true,
      includeAppIcons: true,
      includeSystemApps: true,
    );
    setState(() => apps = _apps);
    List<Future<dynamic>> futureList = [];
    WriteBatch batch = db.batch();
    List<String> icons = [];
    for (final app in _apps) {
      final icon = (app as ApplicationWithIcon).icon;
      final iconsRef =
          db.doc('/sesion/${widget.sesionId}/icons/${app.packageName}');
      batch.set(
        iconsRef,
        {"path": app.appName, "user": widget.nickname},
      );

      futureList.add(FirebaseStorage.instance
          .ref("/images/${app.appName}.icon")
          .putData(icon)
          .then((_) {}));

      /*db
          .doc('/AppRoulette/W6bhLZIHSTwPBBjS3r6T/sesion/tdIr3vmyUke2pbTJ5Bru/')
          .update({
        "icons": FieldValue.arrayUnion([app.packageName])
      });*/
      icons.add(app.packageName);
    }

    icons.shuffle();
    db
        .doc("/sesion/${widget.sesionId}")
        .update({
      "icons": icons,
    });

    batch.commit();
    Future.wait(futureList);
    debugPrint("Done!");
  }

  @override
  Widget build(BuildContext context) {
    if (apps == null) {
      return 
          const CircularProgressIndicator();
        
    } else {
      return const Text("Apps recolectadas con exito!", style: TextStyle(color: Colors.blue),);
    }
  }
}
