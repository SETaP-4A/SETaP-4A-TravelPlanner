import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DatePickerField extends StatelessWidget {
  final TextEditingController controller;
  final String label;

  const DatePickerField({
    super.key,
    required this.controller,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: TextFormField(
        controller: controller,
        readOnly: true,
        decoration: InputDecoration(labelText: label),
        onTap: () async {
          final picked = await showDatePicker(
            context: context,
            initialDate: DateTime.now(),
            firstDate: DateTime(2020),
            lastDate: DateTime(2100),
          );

          if (picked != null) {
            final locale = Localizations.localeOf(context).toString();
            controller.text = DateFormat.yMMMMd(locale).format(picked);
          }
        },
        validator: (value) => value == null || value.trim().isEmpty
            ? 'Please enter $label'
            : null,
      ),
    );
  }
}
