import 'package:cloud_firestore/cloud_firestore.dart';

class CurrentUser {
  final String id;
  final String nickname;
  final int points;

  CurrentUser.fromFirestore(this.id, Map<String, dynamic> data)
      : nickname = data['codi'],
        points = data['currentRound'];
}

Stream<CurrentUser> userSnapshot(String sesionId, String userId) {
  final db = FirebaseFirestore.instance;
  return db
      .collection("sesion")
      .doc(sesionId)
      .collection("users")
      .doc(userId)
      .snapshots()
      .map((userSnap) {
    return CurrentUser.fromFirestore(userSnap.id, userSnap.data()!);
  });
}
