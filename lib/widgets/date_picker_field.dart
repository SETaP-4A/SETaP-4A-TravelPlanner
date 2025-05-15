import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// A reusable form field that opens a date picker when tapped
/// and displays the selected date in yyyy-MM-dd format.
class DatePickerField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final bool isRequired;

  const DatePickerField({
    super.key,
    required this.controller,
    required this.label,
    this.isRequired = false,
  });

  /// Opens the date picker and sets the selected date in the text field.
  Future<void> _pickDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      controller.text = DateFormat('yyyy-MM-dd').format(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeColor = Theme.of(context).textTheme.bodySmall?.color;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: TextFormField(
        controller: controller,
        readOnly: true, // prevents keyboard from showing
        onTap: () => _pickDate(context),
        validator: (value) =>
            isRequired && (value == null || value.trim().isEmpty)
                ? 'Please enter $label'
                : null,
        decoration: InputDecoration(
          label: RichText(
            text: TextSpan(
              text: label,
              style: TextStyle(fontSize: 16, color: themeColor),
              children: isRequired
                  ? const [
                      TextSpan(text: ' *', style: TextStyle(color: Colors.red)),
                    ]
                  : [],
            ),
          ),
          suffixIcon: const Icon(Icons.calendar_today),
          border: const UnderlineInputBorder(),
        ),
      ),
    );
  }
}
