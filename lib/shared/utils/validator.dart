class Validators {
  // NAME VALIDATOR
  static String? name(String? value) {
    if (value == null || value.isEmpty) {
      return "nama tidak boleh kosong";
    }

    return null;
  }

  // EMAIL VALIDATOR
  static String? email(String? value) {
    if (value == null || value.isEmpty) {
      return "Email tidak boleh kosong";
    }

    const pattern = r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$";
    final regex = RegExp(pattern);

    if (!regex.hasMatch(value)) {
      return "Format email tidak valid";
    }

    return null;
  }

  // USERNAME VALIDATOR
  static String? username(String? value) {
    if (value == null || value.isEmpty) {
      return "Username tidak boleh kosong";
    }

    // Minimal 3 karakter, huruf/angka/underscore
    const pattern = r"^[a-zA-Z0-9_]{3,}$";
    final regex = RegExp(pattern);

    if (!regex.hasMatch(value)) {
      return "Username minimal 3 karakter dan tanpa spasi";
    }

    return null;
  }

  // PASSWORD VALIDATOR
  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return "Password tidak boleh kosong";
    }

    if (value.length < 8) {
      return "Password minimal 8 karakter";
    }

    if (!RegExp(r'[a-z]').hasMatch(value)) {
      return "Password harus mengandung minimal 1 huruf kecil";
    }

    // if (!RegExp(r'[A-Z]').hasMatch(value)) {
    //   return "Password harus mengandung minimal 1 huruf besar";
    // }

    if (!RegExp(r'\d').hasMatch(value)) {
      return "Password harus mengandung minimal 1 angka";
    }

    // if (!RegExp(r'[^A-Za-z0-9]').hasMatch(value)) {
    //   return "Password harus mengandung minimal 1 simbol";
    // }

    return null;
  }
}
