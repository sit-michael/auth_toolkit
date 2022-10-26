enum Salutation {
  none,
  female,
  male,
}

extension SalutationExtension on Salutation {
  static const _femaleStringValue = '1';
  static const _maleStringValue = '2';

  static Salutation fromString(String value) {
    if (value == Salutation.female.toApiString()) return Salutation.female;
    if (value == Salutation.male.toApiString()) return Salutation.male;
    return Salutation.none;
  }

  String? toApiString() {
    switch (this) {
      case Salutation.none:
        return null;
      case Salutation.female:
        return _femaleStringValue;
      case Salutation.male:
        return _maleStringValue;
    }
  }
}
