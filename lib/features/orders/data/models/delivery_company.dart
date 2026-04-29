enum DeliveryCompany {
  yalidine,
  zaki,
  maystro,
  guiddini,
  procolis,
  ecotrack,
  other,
}

extension DeliveryCompanyExtension on DeliveryCompany {
  String get label {
    switch (this) {
      case DeliveryCompany.yalidine:
        return 'Yalidine';
      case DeliveryCompany.zaki:
        return 'Zaki';
      case DeliveryCompany.maystro:
        return 'Maystro';
      case DeliveryCompany.guiddini:
        return 'Guiddini';
      case DeliveryCompany.procolis:
        return 'Procolis';
      case DeliveryCompany.ecotrack:
        return 'Ecotrack';
      case DeliveryCompany.other:
        return 'Other';
    }
  }
}
