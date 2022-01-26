import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

class StorageImage extends StatelessWidget {
  final String path;
  const StorageImage({Key? key, required this.path}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final storage = FirebaseStorage.instance;
    return FutureBuilder(
      future: storage.ref("/images/$path.icon").getDownloadURL(),
      builder: (context, AsyncSnapshot<String> snapshot) {
       
        if (!snapshot.hasData) {
          return const CircularProgressIndicator();
        }
        debugPrint(snapshot.data!);
        return Image.network(snapshot.data!, fit: BoxFit.fill);
      },
    );
  }
}
