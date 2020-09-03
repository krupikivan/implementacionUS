import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:realizarPedido/cart_provider.dart';

import 'item_list.dart';

class App extends StatelessWidget {
  const App({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => CartProvider(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Realizar pedido',
        home: ItemList(),
        theme: ThemeData.light(),
      ),
    );
  }
}
