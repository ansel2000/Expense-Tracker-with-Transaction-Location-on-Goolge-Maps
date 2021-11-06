import 'package:expensetracker/models/Transaction.dart';
import 'package:expensetracker/services/address_api.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class MyTransaction extends StatelessWidget {
  final Transaction transaction;

  MyTransaction({
    required this.transaction,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: EdgeInsets.all(15),
          color: Colors.grey[100],
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                        shape: BoxShape.circle, color: Colors.grey[500]),
                    child: Center(
                      child: FaIcon(
                        FontAwesomeIcons.rupeeSign,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        transaction.name,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[700],
                        ),
                      ),
                      FutureBuilder(
                        future: getAddress(
                          transaction.latitude,
                          transaction.longitude,
                        ),
                        builder: (context, asyncSnapshot) {
                          if (asyncSnapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Container();
                          }
                          print(asyncSnapshot.data);
                          if (asyncSnapshot.hasData) {
                            return Text(
                              asyncSnapshot.data.toString(),
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[500],
                              ),
                            );
                          }
                          return Container();
                        },
                      )
                    ],
                  ),
                ],
              ),
              Text(
                (transaction.isExpense ? '- ' : '+ ') +
                    // '\u{20B9}' +
                    transaction.money.toString(),
                style: TextStyle(
                  //fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: transaction.isExpense ? Colors.red : Colors.green,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
