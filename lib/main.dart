import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';

final request =
    Uri.parse("https://api.hgbrasil.com/finance?format=json&key=b63e7335");

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Home(),
      theme: ThemeData(
        hintColor: Colors.amber,
        primaryColor: Colors.white,
      ),
    );
  }
}

class Home extends StatefulWidget {
  const Home({Key key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final realControler = TextEditingController();
  final dolarControler = TextEditingController();
  final euroControler = TextEditingController();

  double dolar;
  double euro;

  void _brChanged(String text) {
    double real = double.parse(text);
    dolarControler.text = (real / dolar).toStringAsFixed(2);
    euroControler.text = (real / euro).toStringAsFixed(2);
    print(text);
  }

  void _usdChanged(String text) {
    double dolar = double.parse(text);
    realControler.text = (dolar * this.dolar).toStringAsFixed(2);
    euroControler.text = (dolar / this.dolar / euro).toStringAsFixed(2);
  }

  void _eurChanged(String text) {
    double euro = double.parse(text);
    realControler.text = (euro * this.euro).toStringAsFixed(2);
    dolarControler.text = (euro * this.euro / dolar).toStringAsFixed(2);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[800],
      appBar: AppBar(
        title: Text("Coin Converter"),
        centerTitle: true,
        backgroundColor: Colors.amber,
      ),
      body: FutureBuilder<Map>(
        future: getData(),
        // ignore: missing_return
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
            case ConnectionState.waiting:
              return Center(
                child: CircularProgressIndicator(),
              );
            default:
              if (snapshot.hasError) {
                return Center(
                  child: Text(
                    "Error",
                    style: TextStyle(
                      fontSize: 25,
                      color: Colors.amber,
                    ),
                    textAlign: TextAlign.center,
                  ),
                );
              } else {
                dolar = snapshot.data["results"]["currencies"]["USD"]["buy"];
                euro = snapshot.data["results"]["currencies"]["EUR"]["buy"];
                return SingleChildScrollView(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 40),
                        child: Icon(
                          Icons.monetization_on,
                          color: Colors.amber,
                          size: 120,
                        ),
                      ),
                      buildTextField("Real", "R\$", realControler, _brChanged),
                      Divider(),
                      buildTextField(
                          "Dolar", "US\$", dolarControler, _usdChanged),
                      Divider(),
                      buildTextField("Euro", "€", euroControler, _eurChanged)
                    ],
                  ),
                );
              }
          }
        },
      ),
    );
  }
}

Widget buildTextField(
    String label, String prefix, TextEditingController coins, Function money) {
  return TextField(
    keyboardType: TextInputType.numberWithOptions(decimal: true),
    controller: coins,
    decoration: InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: Colors.amber),
      prefixText: prefix,
      hintStyle: TextStyle(color: Colors.amber),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
      ),
    ),
    style: TextStyle(color: Colors.amber),
    onChanged: money,
  );
}

Future<Map> getData() async {
  http.Response response = await http.get(request);
  return json.decode(response.body);
}
