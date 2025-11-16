
import 'package:flutter/material.dart';

class StoreListPage extends StatelessWidget {
  const StoreListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('المتاجر'),
        ),
        body: ListView.builder(
          itemCount: 10,
          itemBuilder: (context, index) {
            return ListTile(
              title: Text('متجر رقم ${index + 1}'),
              subtitle: const Text('وصف قصير للمتجر'),
              onTap: () {
                Navigator.pushNamed(context, '/products');
              },
            );
          },
        ),
      ),
    );
  }
}
