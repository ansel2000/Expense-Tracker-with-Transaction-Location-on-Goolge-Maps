import 'package:expensetracker/models/Transaction.dart';
import "package:flutter/foundation.dart";
import 'package:geocoder/geocoder.dart';
import 'package:gsheets/gsheets.dart';

import 'notification_api.dart';

class GoogleSheetsProvider extends ChangeNotifier {
  // create credentials
  static const _credentials = r'''
   {
   
   PUT YOUR CREDENTIALS HERE
  
  }
  ''';

  // set up & connect to the spreadsheet
  static final _spreadsheetId = '14moi4Enlb-SKvyy1IxDNG6F8bgu6Bug3op5ELKFc9W0';
  static final GSheets _gsheets = GSheets(_credentials);
  static Worksheet? _worksheet;
  int numberOfTransactions = 0;
  List<List<dynamic>> currentTransactions = [];
  List<Transaction> transactionList = [];
  bool loading = true;

  GoogleSheetsProvider() {
    init();
  }

  // initialise the spreadsheet!
  Future<void> init() async {
    loading = true;
    notifyListeners();
    final _ss = await _gsheets.spreadsheet(_spreadsheetId);
    print("Initialize the spreadsheet!");
    _worksheet = _ss.worksheetByTitle('Worksheet1');

    await fetchTransactions();

    loading = false;
    notifyListeners();
  }

  // count the number of notes
  Future<void> countRows() async {
    while ((await _worksheet!.values
            .value(column: 1, row: numberOfTransactions + 1)) !=
        '') {
      numberOfTransactions++;
    }
  }

  Future<void> fetchTransactions() async {
    transactionList = [];

    var _rawTransactionList = await _worksheet!.values.allRows(fromRow: 2);

    _rawTransactionList.forEach((_rawTransaction) {
      transactionList.add(Transaction.fromRawList(_rawTransaction));
    });

    print(_rawTransactionList);
  }

  // insert a new transaction
  Future insert({
    required String name,
    required double money,
    required bool isExpense,
    required double latitude,
    required double longitude,
  }) async {
    if (_worksheet == null) {
      print("worksheet null1");
      return;
    }
    Transaction newTransaction = Transaction(
      id: transactionList.length + 1,
      name: name,
      money: money,
      isExpense: isExpense,
      latitude: latitude,
      longitude: longitude,
    );

    transactionList.add(newTransaction);

    await _worksheet!.values.appendRow(newTransaction.toListData());

    notifyListeners();
    print(currentTransactions);

    String type = isExpense ? 'Expense' : 'Income';
    NotificationApi.showNotification(
      title: type.toUpperCase() + ' added',
      body: 'You have added an ' + type + ' amounting to: ' + money.toString(),
    );
  }

  double calculateIncome() {
    double totalIncome = 0;
    transactionList
        .where((_transaction) => !_transaction.isExpense)
        .forEach((Transaction _transaction) {
      totalIncome += _transaction.money;
    });

    return totalIncome;
  }

  double calculateExpense() {
    double totalExpense = 0;
    transactionList
        .where((_transaction) => _transaction.isExpense)
        .forEach((Transaction _transaction) {
      totalExpense += _transaction.money;
    });

    return totalExpense;
  }

  double totalBalance() {
    return calculateIncome() - calculateExpense();
  }
}
