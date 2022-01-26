import 'dart:async';

import 'package:app_roulette/Screens/finalClassification.dart';
import 'package:app_roulette/Screens/sesionPantalla.dart';
import 'package:app_roulette/app_devices.dart';
import 'package:app_roulette/model/sesion.dart';
import 'package:app_roulette/show_image.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'dart:math';

class Ronda extends StatefulWidget {
  final String sesionId;
  final String userId;
  final bool isAdmin;
  final String nickname;

  const Ronda({
    Key? key,
    required this.sesionId,
    required this.userId,
    required this.isAdmin,
    required this.nickname,
  }) : super(key: key);

  @override
  _RondaState createState() => _RondaState();
}

class _RondaState extends State<Ronda> {
  @override
  void initState() {
    super.initState();
    startTimer();
    Timer(Duration(seconds: 10), () {
      setState(() {
        //nextRound=true;
      });
    });
  }

  final db = FirebaseFirestore.instance;
  String selected = "";
  bool press = false;
  int points = 0;
  int secondsTime = 15;
  static const maxSeconds = 15;
  late Timer _timer;
  bool nextRound = false;

  void RandomNum(leng) async {
    Random random = Random();
    int randomNumber = random.nextInt(leng);
    await db.doc('/sesion/${widget.sesionId}').update({
      "randomIcon": randomNumber,
    });
  }

  void startTimer() async {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (secondsTime > 0) {
          secondsTime--;
        } else {
          _timer.cancel();
        }
      });
    });
  }

/*
  void screenChange(context, icons, currentRound) async {
    if (currentRound >= 5) {
      await Future.delayed(const Duration(seconds: 3));
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => Clasification(
            sesionId: widget.sesionId,
            userId: widget.userId,
            isAdmin: widget.isAdmin,
          ),
        ),
      );
    } else {
      widget.isAdmin ? RandomNum(icons.length) : RandomNum(icons.length);
      await db
          .doc('/sesion/${widget.sesionId}')
          .update({"currentRound": currentRound++});
      await Future.delayed(const Duration(seconds: 3));
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => Ronda(
            sesionId: widget.sesionId,
            userId: widget.userId,
            isAdmin: widget.isAdmin,
          ),
        ),
      );
    }
  }*/
  changePage(context, currentRound, icons) async {
    if (currentRound >= 5) {
      await Future.delayed(const Duration(seconds: 2));
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
            builder: (context) => Clasification(
                  sesionId: widget.sesionId,
                  userId: widget.userId,
                  isAdmin: widget.isAdmin,
                  nickname: widget.nickname,
                )),
      );
    } else {
      await db.doc('/sesion/${widget.sesionId}').update({
        "roundChange": false,
      });
      widget.isAdmin ? RandomNum(icons.length) : RandomNum(icons.length);
      await Future.delayed(const Duration(seconds: 2));
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
            builder: (context) => Ronda(
                  sesionId: widget.sesionId,
                  userId: widget.userId,
                  isAdmin: widget.isAdmin,
                  nickname: widget.nickname,
                )),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: sesionSnapshot(widget.sesionId),
      builder: (
        BuildContext context,
        AsyncSnapshot<Sesion> snapshot,
      ) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final sesion = snapshot.data!;

        final String iconID = sesion.icons[sesion.randomIcon];
        if (secondsTime == 0) {
          nextRound = true;
        }

        return Scaffold(
          appBar: AppBar(
            title: Center(child: Text("Ronda : ${sesion.currentRound + 1}")),
          ),
          body: StreamBuilder(
            stream:
                db.doc("sesion/${widget.sesionId}/icons/$iconID").snapshots(),
            builder: (
              BuildContext context,
              AsyncSnapshot<DocumentSnapshot<Map<String, dynamic>>> snapshot,
            ) {
              if (snapshot.hasError) {
                return ErrorWidget(snapshot.error.toString());
              }
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              final dataIcon = snapshot.data!.data()!;

              List<dynamic> _choices = sesion.users;
              String answer = dataIcon['user'];

              if (sesion.roundChange) {
                changePage(context, sesion.currentRound, sesion.icons);
              }

              return StreamBuilder(
                stream: db
                    .doc("sesion/${widget.sesionId}/users/${widget.userId}")
                    .snapshots(),
                builder: (
                  BuildContext context,
                  AsyncSnapshot<DocumentSnapshot<Map<String, dynamic>>>
                      snapshot,
                ) {
                  if (snapshot.hasError) {
                    return ErrorWidget(snapshot.error.toString());
                  }
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final user = snapshot.data!.data()!;

                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Text(
                          "Points : ${user['points']}",
                          style: const TextStyle(
                              fontWeight: FontWeight.w500, color: Colors.red),
                        ),
                        ShowImage(
                          path: dataIcon['path'],
                        ),
                        ListView.builder(
                          scrollDirection: Axis.vertical,
                          shrinkWrap: true,
                          itemCount: sesion.users.length,
                          itemBuilder: (context, index) {
                            return ElevatedButton(
                              child: Center(child: Text(sesion.users[index])),
                              style: ElevatedButton.styleFrom(
                                primary: selected == _choices[index]
                                    ? (selected == answer
                                        ? Colors.green
                                        : Colors.red)
                                    : Colors.grey,
                              ),
                              onPressed: () async {
                                if (press == false) {
                                  setState(() {
                                    selected = _choices[index];
                                    press = true;
                                  });
                                  if (selected == answer) {
                                    setState(() {
                                      points = 30;
                                    });
                                  } else {
                                    setState(() {
                                      user['points'] != 0
                                          ? points = -10
                                          : points = 0;
                                    });
                                  }
                                  await db
                                      .doc(
                                          '/sesion/${widget.sesionId}/users/${widget.userId}')
                                      .update({
                                    "points": user['points'] + points,
                                  });
                                }
                              },
                            );
                          },
                        ),
                        widget.isAdmin
                            ? ElevatedButton(
                                child: const Text("Next Round"),
                                onPressed: () async {
                                  db.doc('/sesion/${widget.sesionId}').update({
                                    "currentRound": sesion.currentRound + 1
                                  });
                                  db.doc('/sesion/${widget.sesionId}').update({
                                    "roundChange": true,
                                  });
                                },
                              )
                            : const Text("Wait for admin to next round"),
                        SizedBox(
                          width: 100,
                          height: 100,
                          child: Stack(fit: StackFit.expand, children: [
                            CircularProgressIndicator(
                              value: secondsTime / maxSeconds,
                              strokeWidth: 10,
                            ),
                            Center(
                              child: secondsTime == 0
                                  ? const Text(
                                      "Time out",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 20),
                                    )
                                  : Text(
                                      "$secondsTime",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 50),
                                    ),
                            ),
                          ]),
                        )
                      ],
                    ),
                  );
                },
              );
            },
          ),
        );
      },
    );
  }
}
