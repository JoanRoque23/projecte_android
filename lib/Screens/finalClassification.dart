import 'package:app_roulette/Screens/ronda.dart';
import 'package:app_roulette/Screens/sesionPantalla.dart';
import 'package:app_roulette/model/sesion.dart';
import 'package:flutter/material.dart';

class Clasification extends StatelessWidget {
  final String sesionId;
  final String userId;
  final bool isAdmin;
  final String nickname;

  const Clasification({
    Key? key,
    required this.sesionId,
    required this.userId,
    required this.isAdmin,
    required this.nickname,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: sesionSnapshot(sesionId),
      builder: (
        BuildContext context,
        AsyncSnapshot<Sesion> snapshot,
      ) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final sesion = snapshot.data!;

        return Scaffold(
          appBar: AppBar(
            title: const Center(child: Text("FINAL")),
          ),
          body: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              const Padding(
                padding: EdgeInsets.only(top: 10),
                child: Text(
                  "FINAL",
                  style: TextStyle(
                      fontSize: 50,
                      fontWeight: FontWeight.bold,
                      color: Colors.red),
                ),
              ),
              const Text(
                "Your final score is: ",
                style: TextStyle(color: Colors.green, fontSize: 15),
              ),
              const Text(
                "Points",
                style: TextStyle(color: Colors.green, fontSize: 35),
              ),
              const Text(
                "Clasification:",
                style: TextStyle(
                  fontSize: 25,
                ),
              ),
              ListView.builder(
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                itemCount: sesion.users.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Center(
                        child: Text("${index + 1}- ${sesion.users[index]}")),
                  );
                },
              ),
              ElevatedButton(onPressed: () {

                SesionPantalla(userId: userId, sesionId: sesionId, nickname: nickname, isAdmin: isAdmin);

              }, child: const Text("Play Again"))
            ],
          ),
        );
      },
    );
  }
}
