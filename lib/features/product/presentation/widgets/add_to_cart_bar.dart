
import 'package:flutter/material.dart';
import 'package:myapp/core/widgets/app_primary_button.dart';
import 'package:myapp/features/product/presentation/widgets/quantity_stepper.dart';

class AddToCartBar extends StatefulWidget {
  final double productPrice;
  final VoidCallback onAddToCart;

  const AddToCartBar({
    super.key,
    required this.productPrice,
    required this.onAddToCart,
  });

  @override
  State<AddToCartBar> createState() => _AddToCartBarState();
}

class _AddToCartBarState extends State<AddToCartBar> {
  int _quantity = 1;
  late double _totalPrice;

  @override
  void initState() {
    super.initState();
    _totalPrice = widget.productPrice;
  }

  void _onQuantityChanged(int newQuantity) {
    setState(() {
      _quantity = newQuantity;
      _totalPrice = widget.productPrice * newQuantity;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, -2),
          ),
        ],
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          QuantityStepper(
            onChanged: _onQuantityChanged,
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text(
                'Total Price',
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
              Text(
                '\$$_totalPrice.toStringAsFixed(2)',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          AppPrimaryButton(
            text: 'Add to Cart',
            onPressed: widget.onAddToCart,
          ),
        ],
      ),
    );
  }
}
