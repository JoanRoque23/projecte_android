import 'package:cloud_firestore/cloud_firestore.dart';

class Sesion {
  final String id;
  final String codi;
  final int currentRound;
  final int randomIcon;
  final List<String> users;
  final List<String> icons;
  final bool start;
  final bool roundChange;

  Sesion.fromFirestore(this.id, Map<String, dynamic> data)
      : codi = data['codi'],
        currentRound = data['currentRound'],
        roundChange = data['roundChange'],
        randomIcon = data['randomIcon'],
        users = (data['users'] as List).cast<String>(),
        icons =
            data['icons'] == null ? [] : (data['icons'] as List).cast<String>(),
        start = data['start'];
}

Stream<Sesion> sesionSnapshot(String sesionId) {
  final db = FirebaseFirestore.instance;
  return db.collection("sesion").doc(sesionId).snapshots().map((sesionSnap) {
    return Sesion.fromFirestore(sesionSnap.id, sesionSnap.data()!);
  });
}
