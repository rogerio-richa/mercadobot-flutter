import 'package:flutter/material.dart';
import 'package:roundcheckbox/roundcheckbox.dart';

class CustomCheckBox extends StatefulWidget {
  final dynamic Function(bool?)? onTap;
  final bool isSelected;

  const CustomCheckBox({
    Key? key,
    required this.isSelected,
    required this.onTap,
  }) : super(key: key);

  @override
  State<CustomCheckBox> createState() => _CustomCheckBoxState();
}

class _CustomCheckBoxState extends State<CustomCheckBox> {
  @override
  Widget build(BuildContext context) {
    return RoundCheckBox(
        size: 20,
        border: !widget.isSelected
            ? null
            : Border.all(color: Theme.of(context).colorScheme.primary),
        checkedColor: Theme.of(context).colorScheme.primary,
        checkedWidget: Icon(Icons.check,
            size: 15, color: Theme.of(context).colorScheme.surface),
        animationDuration: const Duration(milliseconds: 70),
        isChecked: widget.isSelected,
        onTap: widget.onTap);
  }
}

class ScrollDownButton extends StatefulWidget {
  final Function onTap;

  const ScrollDownButton({
    Key? key,
    required this.onTap,
  }) : super(key: key);

  @override
  State<ScrollDownButton> createState() => _ScrollDownButtonState();
}

class _ScrollDownButtonState extends State<ScrollDownButton> {

  bool isSelected = false;

  @override
  Widget build(BuildContext context) {
    return RoundCheckBox(
        size: 35,
        border: Border.all(color: Theme.of(context).colorScheme.primary),
        uncheckedColor: Theme.of(context).colorScheme. onPrimary,
        checkedColor: Theme.of(context).colorScheme.onPrimary,
        checkedWidget: Icon(Icons.keyboard_arrow_down,
            size: 30, color: Theme.of(context).colorScheme.primary),
        animationDuration: const Duration(milliseconds: 700),
        isChecked: !isSelected,
        onTap: (input) {
          
          Future.delayed(const Duration(milliseconds: 2000));
          setState(() {
            isSelected = false;
          });
          return widget.onTap();
        });
  }
}