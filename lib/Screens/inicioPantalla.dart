// ignore_for_file: file_names

import 'package:app_roulette/Screens/askCode.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:app_roulette/Screens/sesionPantalla.dart';
import 'dart:math';

class InicioPantalla extends StatelessWidget {
  const InicioPantalla({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const appTitle = 'AppRoulette';
    return MaterialApp(
      title: appTitle,
      home: Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          title: const Center(child: Text(appTitle)),
        ),
        body: const MyCustomFormInicio(),
      ),
    );
  }
}

class MyCustomFormInicio extends StatefulWidget {
  const MyCustomFormInicio({Key? key}) : super(key: key);

  

  @override
  State<MyCustomFormInicio> createState() => _MyCustomForm();
}

class _MyCustomForm extends State<MyCustomFormInicio> {
  late TextEditingController controller;
  late final String text;
  final db = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    controller = TextEditingController();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  String nickname = "";
  String error = "";

  //Get Random String
  static const _chars =
      'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
  final Random _rnd = Random();

  String getRandomString(int length) => String.fromCharCodes(Iterable.generate(
      length, (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length))));

  @override
  Widget build(BuildContext context) {
    final ButtonStyle style =
        ElevatedButton.styleFrom(textStyle: const TextStyle(fontSize: 20));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(10.0),
          child: Container(
            decoration: ShapeDecoration(
              shape: const StadiumBorder(),
              color: Colors.blue[200],
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
              child: Center(
                child: TextFormField(
                  validator: (value) =>
                      value!.isEmpty ? "Introduce un codigo" : null,
                  //controller: controller,
                  decoration: const InputDecoration(
                    hintText: 'Enter Nickname',
                  ),
                  onChanged: (value) {
                    nickname = value;
                  },
                ),
              ),
            ),
          ),
        ),
        Center(
          child: Text(
            error,
            style: const TextStyle(color: Colors.red),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(0, 40, 0, 0),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                ElevatedButton(
                  style: style,
                  onPressed: () {
                    if (nickname == "") {
                      setState(() {
                        error = "Introduce un nombre";
                      });
                    } else {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                            builder: (context) => AskCode(
                                  nickname: nickname,
                                )),
                      );
                    }
                  },
                  child: const Text('Unirse a partida'),
                ),
                const SizedBox(height: 30),
                ElevatedButton(
                  style: style,
                  onPressed: () async {
                    if (nickname == "") {
                      setState(() {
                        error = "Introduce un nombre";
                      });
                    } else {
                      final sesionSnap = await db.collection('/sesion').add({
                        "codi": getRandomString(4),
                        "currentRound": 0,
                        "randomIcon": 1,
                        "start": false,
                        "roundChange":false
                      });

                      final sesionId = sesionSnap.id;

                      final userSnap =
                          await db.collection('/sesion/$sesionId/users').add({
                        "nickname": nickname,
                        "points": 0,
                      });
                      await db.doc('/sesion/$sesionId').update({
                        "users": FieldValue.arrayUnion([nickname]),
                      });

                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                            builder: (context) => SesionPantalla(
                                  userId: userSnap.id,
                                  sesionId: sesionId,
                                  nickname: nickname,
                                  isAdmin: true,
                                )),
                      );
                    }
                  },
                  child: const Text('Crear partida'),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
