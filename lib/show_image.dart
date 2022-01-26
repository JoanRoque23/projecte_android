import 'package:app_roulette/widgets/storage_image.dart';
import 'package:flutter/material.dart';

class ShowImage extends StatefulWidget {
  final String path;
  const ShowImage({Key? key, required this.path}) : super(key: key);

  @override
  State<ShowImage> createState() => _ShowImageState();
}

class _ShowImageState extends State<ShowImage> {
  @override
  Widget build(BuildContext context) {
   

    return Column(
      children: [
        Center(child: StorageImage(path: widget.path)),
      ],
    );
  }
}
