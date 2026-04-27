import 'package:flutter/material.dart';

class RadioImageContainer<T> extends StatelessWidget {
  final String imageUrl;
  final T value;
  final T? groupValue;
  final ValueChanged<T?> onChanged;

  const RadioImageContainer({
    super.key,
    required this.imageUrl,
    required this.value,
    required this.groupValue,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () => onChanged(value),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Radio<T>(value: value, groupValue: groupValue, onChanged: onChanged),
          SizedBox(
            height: 70,
            width: 70,
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: Theme.of(context).colorScheme.primaryContainer,
              ),
              child: Center(
                child: Image.asset(imageUrl, height: 50, width: 50),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
