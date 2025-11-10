class Validators {
  static String? notEmpty(String? value, {String fieldName = 'Field'}) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName cannot be empty';
    }
    return null;
  }

  static String? email(String? value) {
    if (value == null || value.isEmpty) return 'Email cannot be empty';
    final emailRegex = RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) return 'Enter a valid email';
    return null;
  }

  static String? number(String? value, {String fieldName = 'Number'}) {
    if (value == null || value.isEmpty) return '$fieldName is required';
    if (double.tryParse(value) == null) return '$fieldName must be numeric';
    return null;
  }

  static String? minLength(
    String? value,
    int length, {
    String fieldName = 'Field',
  }) {
    if (value == null || value.trim().length < length) {
      return '$fieldName must be at least $length characters long';
    }
    return null;
  }
}
