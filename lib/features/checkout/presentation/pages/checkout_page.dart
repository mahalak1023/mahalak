import 'package:flutter/material.dart';
import 'package:myapp/core/widgets/app_app_bar.dart';
import 'package:myapp/core/widgets/app_primary_button.dart';
import 'package:myapp/core/widgets/app_text_field.dart';

class CheckoutPage extends StatelessWidget {
  const CheckoutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: const AppAppBar(title: 'الدفع'),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('عنوان التوصيل', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 16),
              const AppTextField(label: 'الاسم الكامل'),
              const SizedBox(height: 16),
              const AppTextField(label: 'العنوان'),
              const SizedBox(height: 16),
              const AppTextField(label: 'المدينة'),
              const SizedBox(height: 16),
              const AppTextField(label: 'الرمز البريدي'),
              const SizedBox(height: 32),
              Text('طريقة الدفع', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 16),
              // For simplicity, using a basic card input. In a real app, use a proper payment gateway.
              const AppTextField(label: 'رقم البطاقة'),
              const SizedBox(height: 16),
              Row(
                children: const [
                  Expanded(child: AppTextField(label: 'تاريخ انتهاء الصلاحية')),
                  SizedBox(width: 16),
                  Expanded(child: AppTextField(label: 'CVV')),
                ],
              ),
            ],
          ),
        ),
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.all(16.0),
          child: AppPrimaryButton(
            text: 'تأكيد الطلب',
            onPressed: () {
              // TODO: Process payment and create order
              Navigator.pushNamed(context, '/orders');
            },
          ),
        ),
      ),
    );
  }
}
