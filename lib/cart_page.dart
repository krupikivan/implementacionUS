import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:realizarPedido/input_fortmat.dart';
import 'package:realizarPedido/payment.dart';
import 'cart_provider.dart';
import 'package:intl/intl.dart';

class CartPage extends StatefulWidget {
  const CartPage({Key key}) : super(key: key);

  @override
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  TextEditingController _calleDirContr = TextEditingController();
  TextEditingController _ciuDirContr = TextEditingController();
  TextEditingController _numDirContr = TextEditingController();
  TextEditingController _numContr = TextEditingController();
  TextEditingController _arsContr = TextEditingController();
  TextEditingController _nameContr = TextEditingController();
  TextEditingController _dateContr = TextEditingController();
  TextEditingController _cvvController = TextEditingController();
  TextEditingController _expDateController = TextEditingController();
  var _scaffoldKey = GlobalKey<ScaffoldState>();
  var _formKey = GlobalKey<FormState>();
  var numberController = TextEditingController();
  var _paymentCard = PaymentCard();
  var _autoValidate = false;
  var _card = PaymentCard();
  bool showCredit;
  bool loAntesPosible;
  DateTime selectedDate;
  TimeOfDay selectedTime;
  bool nameTar = false;
  bool numTar = false;
  bool dateTar = false;
  bool monto = false;
  bool cvvTar = false;
  bool number = false;
  bool street = false;
  bool card = false;
  bool montoMenor;
  bool city = false;
  @override
  void initState() {
    super.initState();
    showCredit = false;
    loAntesPosible = false;
    _paymentCard.type = CardType.Others;
    numberController.addListener(_getCardTypeFrmNumber);
  }

  bool validateData(CartProvider cart) {
    return street &&
        city &&
        number &&
        (loAntesPosible ||
            (!loAntesPosible &&
                selectedDate != null &&
                selectedTime != null)) &&
        ((cart.efectivoPago && monto) ||
            (!cart.efectivoPago &&
                nameTar &&
                numTar &&
                cvvTar &&
                dateTar &&
                card));
    // if (cart.efectivoPago) {
    //   //Valido lo relacionado al monto
    // } else {
    //   //Valido lo relacionado a la tarjeta
    //   _validateInputs();
    //   data = _autoValidate;
    // }
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
      floatingActionButton: _getPayButton(cart),
      body: Container(
        child: ListView(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
              child: Column(children: [
                Text("Direccion"),
                TextField(
                  onChanged: (value) => setState(() => street = value != ""),
                  decoration: InputDecoration(
                    icon: Icon(Icons.location_on),
                    labelText: 'Calle',
                  ),
                  controller: _calleDirContr,
                ),
                TextField(
                  onChanged: (value) => setState(() => number = value != ""),
                  decoration: InputDecoration(
                      icon: Icon(Icons.location_on), labelText: 'Numero'),
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.digitsOnly
                  ],
                  keyboardType: TextInputType.numberWithOptions(
                    decimal: false,
                    signed: false,
                  ),
                  controller: _numDirContr,
                ),
                TextField(
                  onChanged: (value) => setState(() => city = value != ""),
                  decoration: InputDecoration(
                      icon: Icon(Icons.location_on), labelText: 'Ciudad'),
                  controller: _ciuDirContr,
                ),
                SizedBox(height: 20),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text("Lo antes posible "),
                        Switch(
                          value: loAntesPosible,
                          onChanged: (val) =>
                              setState(() => loAntesPosible = val),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        loAntesPosible
                            ? SizedBox()
                            : RaisedButton(
                                child: Text(selectedDate == null
                                    ? 'Fecha'
                                    : DateFormat('dd/MM/yy')
                                        .format(selectedDate)
                                        .toString()),
                                onPressed: () async {
                                  DateTime date = await showDatePicker(
                                      context: context,
                                      initialDate:
                                          selectedDate ?? DateTime.now(),
                                      firstDate: DateTime.now(),
                                      lastDate:
                                          DateTime(DateTime.now().year + 1));
                                  if (date != null)
                                    setState(() {
                                      selectedDate = date;
                                    });
                                },
                              ),
                        SizedBox(
                          width: 20,
                        ),
                        loAntesPosible
                            ? SizedBox()
                            : RaisedButton(
                                child: Text(selectedTime == null
                                    ? 'Hora'
                                    : DateFormat('HH:mm')
                                        .format(DateTime(
                                            DateTime.now().year,
                                            DateTime.now().month,
                                            DateTime.now().day,
                                            selectedTime.hour,
                                            selectedTime.minute))
                                        .toString()),
                                onPressed: () async {
                                  TimeOfDay time = await showTimePicker(
                                    context: context,
                                    initialTime:
                                        selectedTime ?? TimeOfDay.now(),
                                  );
                                  if (time != null)
                                    setState(() {
                                      selectedTime = time;
                                    });
                                },
                              )
                      ],
                    )
                  ],
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
                                    trailing: Text('\$${e.precio.toString()}'),
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
          child: Column(
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
                controller: _nameContr,
                onChanged: (value) => setState(() => nameTar = value != ""),
                keyboardType: TextInputType.text,
                validator: (String value) =>
                    value.isEmpty ? Strings.fieldReq : null,
              ),
              SizedBox(
                height: 30.0,
              ),
              TextFormField(
                onChanged: (value) => setState(() => numTar = value != ""),
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
                onChanged: (value) => setState(() => cvvTar = value != ""),
                controller: _cvvController,
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
                onChanged: (value) => setState(() => dateTar = value != ""),
                decoration: InputDecoration(
                  border: const UnderlineInputBorder(),
                  filled: true,
                  icon: Icon(Icons.date_range),
                  hintText: 'MM/YY',
                  labelText: 'Fecha vencimiento',
                ),
                validator: CardUtils.validateDate,
                keyboardType: TextInputType.number,
                controller: _expDateController,
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
    if (cardType == CardType.Visa) {
      card = true;
    } else {
      card = false;
    }
  }

  void _validateInputs(CartProvider cart) {
    final FormState form = _formKey.currentState;
    if (!form.validate()) {
      setState(() {
        _autoValidate = true; // Start validating on every change.
      });
    } else {
      form.save();
      cart.removeAll();
      Navigator.pushNamed(context, '/success');
    }
  }

  _validateAmmount(CartProvider cart) {
    if (int.parse(_arsContr.text) >= cart.totalPrice) {
      setState(() {
        montoMenor = false;
      });
      cart.removeAll();
      Navigator.pushNamed(context, '/success');
    } else {
      setState(() {
        montoMenor = true;
      });
    }
  }

  Widget _getPayButton(CartProvider cart) {
    return FloatingActionButton.extended(
      onPressed: () => validateData(cart)
          ? !cart.efectivoPago ? _validateInputs(cart) : _validateAmmount(cart)
          : null,
      backgroundColor: validateData(cart) ? Colors.lightBlue : Colors.grey[600],
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
          decoration: InputDecoration(
              errorText: montoMenor != null && montoMenor
                  ? 'El monto debe ser mayor a la compra'
                  : null,
              labelText: 'Ingrese monto'),
          controller: _arsContr,
          onChanged: (value) => setState(() => monto = value != ""),
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
