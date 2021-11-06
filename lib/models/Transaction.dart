import "package:flutter/foundation.dart";

class Transaction {
  final int id;
  final String name;
  final double money;
  final bool isExpense;
  final double latitude;
  final double longitude;

  Transaction({
    required this.id,
    required this.name,
    required this.money,
    required this.isExpense,
    // required this.location,
    required this.latitude,
    required this.longitude,
  });

  factory Transaction.fromRawList(List<String> _rawList) {
    return Transaction(
      id: int.parse(_rawList[0]),
      name: _rawList[1],
      money: double.parse(_rawList[2]),
      isExpense: _rawList[3] == "expense" ? true : false,
      latitude: double.parse(_rawList[4]),
      longitude: double.parse(_rawList[5]),
    );
  }

  List<String> toListData() {
    return [
      this.id.toString(),
      this.name,
      this.money.toString(),
      this.isExpense ? "expense" : "income",
      this.latitude.toString(),
      this.longitude.toString(),
    ];
  }
}
