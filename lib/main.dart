import 'package:flutter/material.dart';
import 'package:flutter_drift_crud/database/database.dart';
import 'package:drift/drift.dart' as drift;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: HomePage());
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final AppDatabase _database = AppDatabase();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  @override
  void dispose() {
    _database.close();
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Test Database')),
      body: Column(
        children: [
          TextField(
            controller: _amountController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(labelText: 'Amount'),
          ),
          TextField(
            controller: _descriptionController,
            decoration: InputDecoration(labelText: 'Description'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (_amountController.text.isNotEmpty &&
                  _descriptionController.text.isNotEmpty) {
                await _database.addExpense(
                  ExpensesCompanion(
                    amount: drift.Value(double.parse(_amountController.text)),
                    description: drift.Value(_descriptionController.text),
                    date: drift.Value(DateTime.now()),
                  ),
                );
                setState(() {});
              }
            },
            child: Text('Add Expense'),
          ),
          Expanded(
            child: FutureBuilder<List<Expense>>(
              future: _database.getAllExpenses(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }
                final expenses = snapshot.data!;
                return ListView.builder(
                  itemCount: expenses.length,
                  itemBuilder: (context, index) {
                    final expense = expenses[index];
                    return ListTile(
                      title: Text(expense.description),
                      subtitle: Text('${expense.amount} - ${expense.date}'),
                      trailing: IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () async {
                          await _database.deleteExpense(expense.id);
                          setState(() {});
                        },
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
