import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:myapp/main.dart'; // تأكدي إن اسم الباكدج صح في pubspec.yaml

void main() {
  testWidgets('App builds without crashing', (WidgetTester tester) async {
    // نبني التطبيق الرئيسي
    await tester.pumpWidget(const MahallakApp());

    // نتأكد إن في عنصر أساسي ظاهر (مثلاً عنوان الصفحة الرئيسية أو زر)
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
