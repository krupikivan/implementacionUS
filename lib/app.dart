import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:realizarPedido/cart_page.dart';
import 'package:realizarPedido/cart_provider.dart';
import 'package:realizarPedido/pedido_realizado.dart';

import 'item_list.dart';

class App extends StatelessWidget {
  const App({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => CartProvider(),
      child: MaterialApp(
        initialRoute: '/',
        routes: {
          '/': (context) => ItemList(),
          '/success': (context) => PedidoRealizado(),
          '/cart': (context) => CartPage(),
        },
        debugShowCheckedModeBanner: false,
        title: 'Realizar pedido',
        theme: ThemeData.light(),
      ),
    );
  }
}
