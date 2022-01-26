import 'package:app_roulette/Screens/ronda.dart';
import 'package:app_roulette/app_devices.dart';
import 'package:app_roulette/model/sesion.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import "package:flutter/material.dart";
import 'dart:math';

class SesionPantalla extends StatelessWidget {
  final String userId;
  final String sesionId;
  final String nickname;
  final bool isAdmin;

  const SesionPantalla({
    Key? key,
    required this.userId,
    required this.sesionId,
    required this.nickname,
    required this.isAdmin,
  }) : super(key: key);

  void comencarPartida(context) async {
    final db = FirebaseFirestore.instance;
    await db.doc('/sesion/$sesionId/users/$userId').update({
      "points": 0,
    });
    await Future.delayed(const Duration(seconds: 3));
    Navigator.of(context!).pushReplacement(MaterialPageRoute(
        builder: (context) => Ronda(
              sesionId: sesionId,
              userId: userId,
              isAdmin: isAdmin,
              nickname: nickname,
            )));
  }

  //Aqui dicidimos el primer icono que se mostrara
  // ignore: non_constant_identifier_names
  void RandomNum(leng) async {
    final db = FirebaseFirestore.instance;
    Random random = Random();
    int randomNumber = random.nextInt(leng+1);
    await db.doc('/sesion/$sesionId').update({
      "randomIcon": randomNumber,
    });
  }

  @override
  Widget build(BuildContext context) {
    final db = FirebaseFirestore.instance;

    return Scaffold(
      appBar: AppBar(
        title: const Center(child: Text("Pantalla de Sesión")),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          StreamBuilder (
            stream: sesionSnapshot(sesionId),
            builder: (
              BuildContext context,
              AsyncSnapshot<Sesion> snapshot,
            ) {
              if (snapshot.hasError) {
                return ErrorWidget(snapshot.error.toString());
              }
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              final sesion = snapshot.data!;
             

              if (sesion.start) {
                comencarPartida(context);
              }
              isAdmin ? RandomNum(sesion.icons.length) : null;

              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(top: 10),
                      child: Text(
                        "PIN Juego:",
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ),
                    Text(
                      sesion.codi,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 80,
                          color: Colors.red),
                    ),
                    ListView.builder(
                      scrollDirection: Axis.vertical,
                      shrinkWrap: true,
                      itemCount: sesion.users.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          title: Center(child: Text(sesion.users[index], style: const TextStyle(fontWeight: FontWeight.w300),)),
                        );
                      },
                    ),
                    AppScreenGetter(
                      nickname: nickname,
                      sesionId: sesionId,
                    ),
                   
                  ],
                ),
              );
            },
          ),
          isAdmin
              ? Center(
                  child: ElevatedButton(
                  style: ElevatedButton.styleFrom(primary: Colors.red),
                  child: const Text("Iniciar Juego"),
                  onPressed: () {
                    db.doc('/sesion/$sesionId').update({
                      "start": true,
                    });
                  },
                ))
              : const Center(
                  child: Text("Wait for the admin to start the game..."),
                ),
        ],
      ),
    );
  }
}
