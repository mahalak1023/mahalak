
import 'package:flutter/material.dart';

class AddressPickerPage extends StatefulWidget {
  const AddressPickerPage({super.key});

  @override
  State<AddressPickerPage> createState() => _AddressPickerPageState();
}

class _AddressPickerPageState extends State<AddressPickerPage> {
  int _selectedAddress = 0;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('اختيار العنوان'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: 2,
                  itemBuilder: (context, index) {
                    return Card(
                      child: ListTile(
                        title: Text('عنوان ${index + 1}'),
                        subtitle: const Text('تفاصيل العنوان هنا...'),
                        selected: _selectedAddress == index,
                        onTap: () {
                          setState(() {
                            _selectedAddress = index;
                          });
                          Navigator.pushNamed(context, '/checkout');
                        },
                      ),
                    );
                  },
                ),
              ),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pushNamed(context, '/add-address');
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('إضافة عنوان جديد'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
