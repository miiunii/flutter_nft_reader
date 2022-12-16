import 'dart:io';
import 'package:flutter/material.dart';

renderTextFormField({
  required String label,
  required FormFieldSetter onSaved,
  required FormFieldValidator validator,
  required InputDecoration decoration,
}) {

  assert(onSaved != null);
  assert(validator != null);

  return Column(
    children: [
      Row(
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12.0,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
      TextFormField(
        onSaved: onSaved,
        validator: validator,
        decoration: decoration,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        autovalidateMode: AutovalidateMode.onUserInteraction
      ),
    ],
  );
}