import 'package:azkar/model/qari_model.dart';
import 'package:flutter/material.dart';

class QariCustomTile extends StatefulWidget {
  const QariCustomTile({Key? key, required this.qari, required this.ontap})
    : super(key: key);

  final Qari qari;
  final VoidCallback ontap;

  @override
  _QariCustomTileState createState() => _QariCustomTileState();
}

class _QariCustomTileState extends State<QariCustomTile> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.ontap,
      child: Row(
        children: [
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: CircleAvatar(
              radius: 20,
              backgroundImage: AssetImage('assets/logo.png'),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              widget.qari.name!,
              // 'Res',
              style: const TextStyle(color: Colors.white, fontSize: 14),
              overflow: TextOverflow.fade,
            ),
          ),
        ],
      ),
    );
  }
}
