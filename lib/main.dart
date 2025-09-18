// file: lib/main.dart

import 'package:flutter/material.dart';
import 'package:drift/drift.dart' as drift;
import 'package:flutter_drift_crud/database/database.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(title: 'Money Manager', home: HomePage());
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  int _transactionType = 0; // 0 for Expense, 1 for Income

  void _addTransaction() {
    final title = _titleController.text;
    final amount = double.tryParse(_amountController.text);

    if (title.isNotEmpty && amount != null) {
      final newTransaction = TransactionsCompanion(
        title: drift.Value(title),
        amount: drift.Value(amount),
        transactionType: drift.Value(_transactionType),
        // نیازی به دادن تاریخ نیست، خودش اتوماتیک ثبت میشه
      );

      database.addTransaction(newTransaction);

      // پاک کردن فیلدها بعد از ثبت
      _titleController.clear();
      _amountController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('مدیریت مالی')),
      body: Column(
        children: [
          // بخش فرم برای اضافه کردن تراکنش
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                TextField(
                  controller: _titleController,
                  decoration: InputDecoration(labelText: 'عنوان'),
                ),
                TextField(
                  controller: _amountController,
                  decoration: InputDecoration(labelText: 'مبلغ'),
                  keyboardType: TextInputType.number,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('هزینه'),
                    Radio<int>(
                      value: 0,
                      groupValue: _transactionType,
                      onChanged: (v) => setState(() => _transactionType = v!),
                    ),
                    Text('درآمد'),
                    Radio<int>(
                      value: 1,
                      groupValue: _transactionType,
                      onChanged: (v) => setState(() => _transactionType = v!),
                    ),
                  ],
                ),
                ElevatedButton(
                  onPressed: _addTransaction,
                  child: Text('ثبت تراکنش'),
                ),
              ],
            ),
          ),

          // خط جداکننده
          Divider(),

          // بخش نمایش لیست تراکنش‌ها
          Expanded(
            child: StreamBuilder<List<Transaction>>(
              stream: database.watchAllTransactions(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('خطا: ${snapshot.error}'));
                }
                final transactions = snapshot.data ?? [];
                if (transactions.isEmpty) {
                  return Center(child: Text('هیچ تراکنشی ثبت نشده است.'));
                }

                return ListView.builder(
                  itemCount: transactions.length,
                  itemBuilder: (context, index) {
                    final transaction = transactions[index];
                    final isExpense = transaction.transactionType == 0;
                    return ListTile(
                      leading: Icon(
                        isExpense ? Icons.arrow_downward : Icons.arrow_upward,
                        color: isExpense ? Colors.red : Colors.green,
                      ),
                      title: Text(transaction.title),
                      subtitle: Text(
                        '${transaction.transactionDate.toLocal()}',
                      ),
                      trailing: Text(
                        '${transaction.amount} تومان',
                        style: TextStyle(
                          color: isExpense ? Colors.red : Colors.green,
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
