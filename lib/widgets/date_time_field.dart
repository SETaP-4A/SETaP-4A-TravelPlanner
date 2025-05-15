import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// A reusable form field widget that allows picking both date and time.
/// Shows a combined date & time picker on tap and formats the result for display.
class DateTimeField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final bool isRequired;

  const DateTimeField({
    super.key,
    required this.controller,
    required this.label,
    this.isRequired = false,
  });

  /// Opens date picker followed by time picker,
  /// then formats and sets the combined datetime string to the controller.
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

    // Get the locale from context for localized formatting
    final locale = Localizations.localeOf(context).toString();

    // Format date and time (e.g. May 15, 2025 14:30)
    controller.text = DateFormat.yMMMMd(locale).add_Hm().format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    final themeColor = Theme.of(context).textTheme.bodySmall?.color;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: TextFormField(
        controller: controller,
        readOnly: true, // Prevents keyboard from opening
        onTap: () => _pickDateTime(context),
        validator: (value) {
          // Validate required field
          if (isRequired && (value == null || value.trim().isEmpty)) {
            return 'Please enter $label';
          }
          return null;
        },
        decoration: InputDecoration(
          label: RichText(
            text: TextSpan(
              text: label,
              style: TextStyle(
                fontSize: 16,
                color: themeColor,
              ),
              children: isRequired
                  ? const [
                      TextSpan(
                        text: ' *',
                        style: TextStyle(color: Colors.red),
                      )
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
