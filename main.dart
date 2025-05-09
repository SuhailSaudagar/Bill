import 'package:flutter/material.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: BillingScreen(),
    );
  }
}

class BillingScreen extends StatefulWidget {
  @override
  _BillingScreenState createState() => _BillingScreenState();
}

class _BillingScreenState extends State<BillingScreen> {
  final TextEditingController typeController = TextEditingController();
  final TextEditingController quantityController = TextEditingController();
  List<Map<String, dynamic>> items = [];
  bool applyDiscount = true;

  void addItem() {
    final type = typeController.text;
    final quantity = int.tryParse(quantityController.text) ?? 0;
    if (type.isNotEmpty && quantity > 0) {
      items.add({'type': type, 'quantity': quantity, 'discount': applyDiscount});
      typeController.clear();
      quantityController.clear();
      setState(() {});
    }
  }

  double calculateTotal() {
    double total = 0;
    for (var item in items) {
      double price = item['quantity'] * 100; // 100 per item
      if (item['discount']) {
        price *= 0.9;
      }
      total += price;
    }
    return total;
  }

  void printBill() {
    final pdf = pw.Document();
    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('Cloth Shop Bill', style: pw.TextStyle(fontSize: 24)),
              pw.SizedBox(height: 10),
              ...items.map((item) => pw.Text(
                  '${item['quantity']} x ${item['type']} - ${item['discount'] ? '10% off' : 'No discount'}')),
              pw.Divider(),
              pw.Text('Total: Rs ${calculateTotal().toStringAsFixed(2)}'),
            ],
          );
        },
      ),
    );
    Printing.layoutPdf(onLayout: (format) => pdf.save());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Cloth Billing')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(controller: typeController, decoration: InputDecoration(labelText: 'Item Type')),
            TextField(controller: quantityController, decoration: InputDecoration(labelText: 'Quantity'), keyboardType: TextInputType.number),
            Row(
              children: [
                Checkbox(value: applyDiscount, onChanged: (val) => setState(() => applyDiscount = val!)),
                Text('Apply 10% Discount')
              ],
            ),
            ElevatedButton(onPressed: addItem, child: Text('Add Item')),
            Expanded(
              child: ListView(
                children: items.map((item) => ListTile(
                  title: Text('${item['quantity']} x ${item['type']}'),
                  subtitle: Text(item['discount'] ? '10% discount' : 'No discount'),
                )).toList(),
              ),
            ),
            ElevatedButton(onPressed: printBill, child: Text('Print Bill')),
          ],
        ),
      ),
    );
  }
}