import 'dart:async';
import 'package:expensetracker/models/Transaction.dart';
import 'package:expensetracker/screens/map_screen.dart';
import 'package:expensetracker/services/google_sheets_provider.dart';
import 'package:expensetracker/services/location_provider.dart';
import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../components/loading_circle.dart';
import '../components/plus_button.dart';
import '../components/top_card.dart';
import '../components/transaction.dart';

class HomeScreen extends StatefulWidget {
  static const routeName = "homeScreen";

  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // collect user input
  final _textControllerAmount = TextEditingController();
  final _textControllerName = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  List<bool> isSelected = [true, false];

  // new transaction
  void _newTransaction() {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, setState) {
            return AlertDialog(
              title: Text('N E W  T R A N S A C T I O N'),
              content: SingleChildScrollView(
                child: Column(
                  children: [
                    ToggleButtons(
                      children: [
                        Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: 30, vertical: 10),
                          child: Text(
                            "Expense",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: isSelected[0]
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: 30, vertical: 10),
                          child: Text(
                            "Income",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: isSelected[1]
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                        ),
                      ],
                      isSelected: isSelected,
                      onPressed: (index) {
                        List<bool> newIsSelected =
                            isSelected.map((item) => !item).toList();
                        newIsSelected[index] = true;
                        setState(() {
                          isSelected = newIsSelected;
                        });
                      },
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          TextFormField(
                            decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              hintText: 'Amount',
                            ),
                            keyboardType: TextInputType.number,
                            validator: (text) {
                              if (text == null || text.isEmpty) {
                                return 'Enter an amount';
                              }
                              return null;
                            },
                            controller: _textControllerAmount,
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          TextField(
                            decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              hintText: 'Short Description',
                            ),
                            textCapitalization: TextCapitalization.sentences,
                            maxLength: 50,
                            controller: _textControllerName,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              actions: <Widget>[
                ElevatedButton(
                  child: Text('Cancel'),
                  onPressed: () {
                    Navigator.of(context).pop();
                    _textControllerAmount.clear();
                    _textControllerName.clear();
                    isSelected = [true, false];
                  },
                ),
                ElevatedButton(
                  child: Text('Enter'),
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      LocationData _locationData =
                          Provider.of<LocationProvider>(context, listen: false)
                              .locationData;
                      Provider.of<GoogleSheetsProvider>(context, listen: false)
                          .insert(
                        name: _textControllerName.text,
                        money: double.parse(_textControllerAmount.text),
                        isExpense: isSelected[0],
                        latitude: _locationData.latitude,
                        longitude: _locationData.longitude,
                      )
                          .then((_) {
                        Navigator.of(context).pop();
                        _textControllerAmount.clear();
                        _textControllerName.clear();
                        isSelected = [true, false];
                      });
                    }
                  },
                )
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Provider.of<GoogleSheetsProvider>(context, listen: false)
    //     .fetchTransactions();
    // print(Provider.of<LocationProvider>(context, listen: false).locationData);

    return Scaffold(
      body: Consumer<GoogleSheetsProvider>(
        builder: (context, googleSheetsProvider, _) {
          return Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 25.0,
              vertical: 0,
            ),
            child: Column(
              children: [
                SizedBox(
                  height: 30,
                ),
                TopNeuCard(
                  balance: googleSheetsProvider.totalBalance(),
                  income: googleSheetsProvider.calculateIncome(),
                  expense: googleSheetsProvider.calculateExpense(),
                ),
                Expanded(
                  child: Container(
                    child: Center(
                      child: Column(
                        children: [
                          SizedBox(
                            height: 20,
                          ),
                          Expanded(
                            child: googleSheetsProvider.loading
                                ? LoadingCircle()
                                : ListView.builder(
                                    // physics: ClampingScrollPhysics(),
                                    itemCount: googleSheetsProvider
                                        .transactionList.length,
                                    itemBuilder: (context, index) {
                                      Transaction _transaction =
                                          googleSheetsProvider.transactionList[
                                              googleSheetsProvider
                                                      .transactionList.length -
                                                  1 -
                                                  index];
                                      return MyTransaction(
                                        transaction: _transaction,
                                      );
                                    },
                                  ),
                          ),
                          SizedBox(
                            height: MediaQuery.of(context).padding.bottom,
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: PlusButton(
        function: _newTransaction,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: _DemoBottomAppBar(
        fabLocation: FloatingActionButtonLocation.centerDocked,
      ),
    );
  }
}

class _DemoBottomAppBar extends StatelessWidget {
  const _DemoBottomAppBar({
    this.fabLocation = FloatingActionButtonLocation.endDocked,
    this.shape = const CircularNotchedRectangle(),
  });

  final FloatingActionButtonLocation fabLocation;
  final NotchedShape? shape;

  static final List<FloatingActionButtonLocation> centerLocations =
      <FloatingActionButtonLocation>[
    FloatingActionButtonLocation.centerDocked,
    FloatingActionButtonLocation.centerFloat,
  ];

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      shape: shape,
      color: Colors.grey[300],
      elevation: 0,
      child: IconTheme(
        data: IconThemeData(color: Theme.of(context).colorScheme.onPrimary),
        child: Row(
          children: <Widget>[
            // IconButton(
            //   tooltip: 'Open navigation menu',
            //   icon: const Icon(Icons.menu),
            //   onPressed: () {},
            // ),
            if (centerLocations.contains(fabLocation)) const Spacer(),
            // IconButton(
            //   tooltip: 'Search',
            //   icon: const Icon(Icons.search),
            //   onPressed: () {},
            // ),
            IconButton(
              tooltip: 'Favorite',
              icon: const Icon(Icons.map),
              color: Colors.blue,
              onPressed: () {
                Navigator.of(context).pushNamed(MapScreen.routeName);
              },
            ),
          ],
        ),
      ),
    );
  }
}
