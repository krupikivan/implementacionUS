import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:realizarPedido/cart_provider.dart';

import 'cart_page.dart';
import 'item.dart';

class ItemList extends StatelessWidget {
  const ItemList({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);
    return Scaffold(
      appBar: AppBar(
        actions: [
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: GestureDetector(
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (BuildContext context) => CartPage()));
              },
              child: Container(
                height: 150.0,
                width: 45.0,
                child: Stack(
                  children: [
                    Positioned(left: 10, child: Icon(Icons.shopping_cart)),
                    Text(cart.items.length.toString())
                  ],
                ),
              ),
            ),
          )
        ],
        backgroundColor: Colors.grey[800],
        title: Text('Realizar nuevo pedido'),
      ),
      body: Container(
        child: ListView.builder(
            itemCount: list.length,
            itemBuilder: (context, i) => ListTile(
                  title: Text('${list[i].name} - \$40'),
                  leading: Icon(Icons.shop),
                  trailing: GestureDetector(
                      onTap: () => cart.add(list[i]),
                      child: Icon(cart.items.contains(list[i])
                          ? Icons.remove_circle_outline
                          : Icons.add)),
                )),
      ),
    );
  }
}

final list = [
  Item(id: 0, name: 'Item numero 0'),
  Item(id: 1, name: 'Item numero 1'),
  Item(id: 2, name: 'Item numero 2'),
  Item(id: 3, name: 'Item numero 3'),
  Item(id: 4, name: 'Item numero 4'),
];
