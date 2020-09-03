import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import 'package:realizarPedido/input_fortmat.dart';
import 'package:realizarPedido/payment.dart';
import 'cart_provider.dart';

class CartPage extends StatefulWidget {
  const CartPage({Key key}) : super(key: key);

  @override
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  TextEditingController _dirContr;
  TextEditingController _numContr;
  TextEditingController _arsContr;
  TextEditingController _nameContr;
  TextEditingController _dateContr;
  var _scaffoldKey = GlobalKey<ScaffoldState>();
  var _formKey = GlobalKey<FormState>();
  var numberController = TextEditingController();
  var _paymentCard = PaymentCard();
  var _autoValidate = false;
  var _card = PaymentCard();
  bool showCredit;
  @override
  void initState() {
    super.initState();
    showCredit = false;
    _paymentCard.type = CardType.Others;
    numberController.addListener(_getCardTypeFrmNumber);
  }

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);
    return Scaffold(
      appBar: AppBar(actions: [
        Container(
          padding: const EdgeInsets.only(top: 20, right: 10),
          child: Text(
            'Total: \$ ${cart.totalPrice.toString()}',
            style: TextStyle(fontSize: 18),
          ),
        ),
      ], backgroundColor: Colors.grey[800], title: Text('Carrito de compra')),
      floatingActionButton: _getPayButton(),
      body: Container(
        child: ListView(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(children: [
                TextField(
                  decoration: InputDecoration(
                      icon: Icon(Icons.location_on),
                      labelText: 'Indique direccion (Calle - Numero - Ciudad)'),
                  controller: _dirContr,
                ),
                SizedBox(height: 20),
                Row(
                  children: [
                    ChoiceChip(
                        onSelected: (val) => cart.change(!val),
                        selectedColor: Colors.green,
                        labelStyle: TextStyle(color: Colors.white),
                        label: Text('Tarjeta VISA'),
                        selected: !cart.efectivoPago),
                    SizedBox(
                      width: 10,
                    ),
                    ChoiceChip(
                        onSelected: (val) => cart.change(val),
                        selectedColor: Colors.green,
                        labelStyle: TextStyle(color: Colors.white),
                        label: Text('Efectivo'),
                        selected: cart.efectivoPago),
                  ],
                ),
                SizedBox(height: 20),
                !cart.efectivoPago ? goToVisa() : buildEfectivo(),
                SizedBox(height: 20),
                showCredit && !cart.efectivoPago
                    ? buildTarjeta()
                    : Container(
                        decoration: BoxDecoration(
                            color: Colors.white,
                            boxShadow: [BoxShadow(color: Colors.grey[500])],
                            borderRadius:
                                BorderRadius.all(Radius.circular(20))),
                        width: 340,
                        child: Column(
                          children: cart.items
                              .map((e) => ListTile(
                                    title: Text(e.name),
                                    leading: GestureDetector(
                                        onTap: () => cart.add(e),
                                        child:
                                            Icon(Icons.remove_circle_outline)),
                                  ))
                              .toList(),
                        ),
                      )
              ]),
            ),
          ],
        ),
      ),
    );
  }

  Widget goToVisa() {
    return OutlineButton(
        color: Colors.white,
        child:
            Text(showCredit ? 'Mostrar items' : 'Completar Datos de Tarjeta'),
        onPressed: () => setState(() => showCredit = !showCredit));
  }

  Widget buildTarjeta() {
    return Container(
      height: 450,
      padding: const EdgeInsets.only(right: 20),
      child: Form(
          key: _formKey,
          autovalidate: _autoValidate,
          child: ListView(
            children: <Widget>[
              SizedBox(
                height: 20.0,
              ),
              TextFormField(
                decoration: const InputDecoration(
                  border: const UnderlineInputBorder(),
                  filled: true,
                  icon: const Icon(
                    Icons.person,
                  ),
                  labelText: 'Nombre apellido del titular',
                ),
                onSaved: (String value) {
                  _card.name = value;
                },
                keyboardType: TextInputType.text,
                validator: (String value) =>
                    value.isEmpty ? Strings.fieldReq : null,
              ),
              SizedBox(
                height: 30.0,
              ),
              TextFormField(
                keyboardType: TextInputType.number,
                inputFormatters: [
                  WhitelistingTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(19),
                  CardNumberInputFormatter()
                ],
                controller: numberController,
                decoration: InputDecoration(
                  border: const UnderlineInputBorder(),
                  filled: true,
                  icon: CardUtils.getCardIcon(_paymentCard.type),
                  // icon: Icon(Icons.credit_card),
                  labelText: 'Numero de tarjeta',
                ),
                onSaved: (String value) {
                  _paymentCard.number = CardUtils.getCleanedNumber(value);
                },
                validator: CardUtils.validateCardNum,
              ),
              SizedBox(
                height: 30.0,
              ),
              TextFormField(
                inputFormatters: [
                  WhitelistingTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(4),
                ],
                decoration: InputDecoration(
                  border: const UnderlineInputBorder(),
                  filled: true,
                  icon: Icon(Icons.verified_user),
                  labelText: 'CVV',
                ),
                validator: CardUtils.validateCVV,
                keyboardType: TextInputType.number,
                onSaved: (value) {
                  _paymentCard.cvv = int.parse(value);
                },
              ),
              SizedBox(
                height: 30.0,
              ),
              TextFormField(
                inputFormatters: [
                  WhitelistingTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(4),
                  CardMonthInputFormatter()
                ],
                decoration: InputDecoration(
                  border: const UnderlineInputBorder(),
                  filled: true,
                  icon: Icon(Icons.date_range),
                  hintText: 'MM/YY',
                  labelText: 'Expiry Date',
                ),
                validator: CardUtils.validateDate,
                keyboardType: TextInputType.number,
                onSaved: (value) {
                  List<int> expiryDate = CardUtils.getExpiryDate(value);
                  _paymentCard.month = expiryDate[0];
                  _paymentCard.year = expiryDate[1];
                },
              ),
            ],
          )),
    );
  }

  @override
  void dispose() {
    // Clean up the controller when the Widget is removed from the Widget tree
    numberController.removeListener(_getCardTypeFrmNumber);
    numberController.dispose();
    super.dispose();
  }

  void _getCardTypeFrmNumber() {
    String input = CardUtils.getCleanedNumber(numberController.text);
    CardType cardType = CardUtils.getCardTypeFrmNumber(input);
    setState(() {
      this._paymentCard.type = cardType;
    });
  }

  void _validateInputs() {
    final FormState form = _formKey.currentState;
    if (!form.validate()) {
      setState(() {
        _autoValidate = true; // Start validating on every change.
      });
    } else {
      form.save();
    }
  }

  Widget _getPayButton() {
    return FloatingActionButton.extended(
      onPressed: _validateInputs,
      backgroundColor: Colors.lightBlue,
      splashColor: Colors.deepPurple,
      shape: RoundedRectangleBorder(
        borderRadius: const BorderRadius.all(const Radius.circular(100.0)),
      ),
      label: Text(
        Strings.pay.toUpperCase(),
        style: const TextStyle(fontSize: 17.0),
      ),
    );
  }

  Widget buildEfectivo() {
    return Padding(
      padding: const EdgeInsets.only(right: 20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        TextField(
          decoration: InputDecoration(labelText: 'Ingrese monto'),
          controller: _arsContr,
          inputFormatters: <TextInputFormatter>[
            FilteringTextInputFormatter.digitsOnly
          ],
          keyboardType: TextInputType.numberWithOptions(
            decimal: true,
            signed: false,
          ),
        )
      ]),
    );
  }
}
