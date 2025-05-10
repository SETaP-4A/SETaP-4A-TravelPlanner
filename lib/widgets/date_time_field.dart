import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DateTimeField extends StatelessWidget {
  final TextEditingController controller;
  final String label;

  const DateTimeField({
    super.key,
    required this.controller,
    required this.label,
  });

  Future<void> _pickDateTime(BuildContext context) async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (date == null) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (time == null) return;

    final dateTime = DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );

    final locale = Localizations.localeOf(context).toString();
    controller.text = DateFormat.yMMMMd(locale)
        .add_Hm()
        .format(dateTime); // e.g., April 9, 2025 at 18:00
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: TextFormField(
        controller: controller,
        readOnly: true,
        decoration: InputDecoration(labelText: label),
        onTap: () => _pickDateTime(context),
        validator: (value) => value == null || value.trim().isEmpty
            ? 'Please enter $label'
            : null,
      ),
    );
  }
}
