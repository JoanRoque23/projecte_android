
import 'package:app_roulette/Screens/sesionPantalla.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AskCode extends StatefulWidget {
  final String nickname;
  const AskCode({Key? key, required this.nickname}) : super(key: key);

  @override
  _AskCodeState createState() => _AskCodeState();
}

class _AskCodeState extends State<AskCode> {
  final _formKey = GlobalKey<FormState>();
  final db = FirebaseFirestore.instance;
  String sesioncode = "";
  String error = "";

  @override
  Widget build(BuildContext context) {
    const appTitle = 'Codigo de Sesión';

    return Scaffold(
      appBar: AppBar(
        title: const Center(child: Text(appTitle)),
      ),
      body: Form(
        key: _formKey,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(
                height: 20,
              ),
              Text("Tu nickname es: ${widget.nickname}"),
              const SizedBox(
                height: 20,
              ),
              TextFormField(
                // The validator receives the text that the user has entered.
                validator: (value) =>
                    value!.isEmpty ? "Introduce un codigo" : null,

                onChanged: (value) {
                  setState(() {
                    sesioncode = value;
                  });
                },
              ),
              Text(
                error,
                style: TextStyle(color: Colors.red),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Center(
                  child: Builder(builder: (context) {
                    return ElevatedButton(
                      onPressed: () async {
                        final sesionSnap = await db
                            .collection('sesion')
                            .where('codi', isEqualTo: sesioncode)
                            .get();

                        if (sesionSnap.docs.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("No existe sesion con este codigo"),
                            ),
                          );
                          return;
                        }
                        final sesionId = sesionSnap.docs[0].id;

                        

                        final userSnap =
                            await db.collection('/sesion/$sesionId/users').add({
                          "nickname": widget.nickname,
                          "points": 0,
                        });
                        await db.doc('/sesion/$sesionId').update({
                          "users": FieldValue.arrayUnion([widget.nickname])
                        });

                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                              builder: (context) => SesionPantalla(
                                    userId: userSnap.id,
                                    sesionId: sesionId,
                                    nickname: widget.nickname,
                                    isAdmin: false,
                                  )),
                        );
                      },
                      child: const Text('Enter Code'),
                    );
                  }),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
