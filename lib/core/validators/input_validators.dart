String? requiredField(String? value) {
  if (value == null || value.trim().isEmpty) {
    return 'This field is required';
  }
  return null;
}

String? emailValidator(String? value) {
  final requiredMessage = requiredField(value);
  if (requiredMessage != null) {
    return requiredMessage;
  }
  final email = value!.trim();
  if (!email.contains('@') || !email.contains('.')) {
    return 'Enter a valid email';
  }
  return null;
}

String? passwordValidator(String? value) {
  final requiredMessage = requiredField(value);
  if (requiredMessage != null) {
    return requiredMessage;
  }
  if (value!.length < 6) {
    return 'Use at least 6 characters';
  }
  return null;
}
