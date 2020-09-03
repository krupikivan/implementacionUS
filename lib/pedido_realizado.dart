import 'dart:async';

import 'package:flutter/material.dart';

class PedidoRealizado extends StatefulWidget {
  PedidoRealizado({Key key}) : super(key: key);

  @override
  _PedidoRealizadoState createState() => _PedidoRealizadoState();
}

class _PedidoRealizadoState extends State<PedidoRealizado> {
  @override
  void initState() {
    super.initState();
    Timer(Duration(seconds: 3),
        () => Navigator.popUntil(context, ModalRoute.withName('/')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green,
      body: Container(
        child: Center(
          child: Icon(
            Icons.check,
            size: 50,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
