import 'package:flutter/material.dart';
import 'package:myapp/core/widgets/app_app_bar.dart';

class StoresPage extends StatefulWidget {
  const StoresPage({super.key});

  @override
  State<StoresPage> createState() => _StoresPageState();
}

class _StoresPageState extends State<StoresPage> {
  @override
  Widget build(BuildContext context) {
    return const Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppAppBar(title: 'المتاجر'),
        body: Center(
          child: Text('صفحة المتاجر'),
        ),
      ),
    );
  }
}
