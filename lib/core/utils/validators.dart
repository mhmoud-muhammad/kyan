// lib/core/utils/validators.dart
class Validators {
  static String? phone(String? value) {
    // if (value == null || value.isEmpty) return 'رقم الهاتف مطلوب';
    // final regex = RegExp(r'^[0-9]{10}$');
    // if (!regex.hasMatch(value)) return 'رقم الهاتف غير صالح';
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) return 'كلمة المرور مطلوبة';
    //if (value.length < 6) return 'كلمة المرور يجب أن تكون ٦ أحرف على الأقل';
    return null;
  }
}
