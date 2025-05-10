import 'package:get/get.dart';

class PhoneValidation {
  // Map of country codes to their digit limits
  static final Map<String, int> countryDigitLimits = {
    'AF': 9, // Afghanistan
    'AL': 8, // Albania
    'DZ': 9, // Algeria
    'AD': 6, // Andorra
    'AO': 9, // Angola
    'AG': 7, // Antigua and Barbuda
    'AR': 10, // Argentina
    'AM': 8, // Armenia
    'AU': 9, // Australia
    'AT': 8, // Austria
    'AZ': 9, // Azerbaijan
    'BS': 7, // Bahamas
    'BH': 8, // Bahrain
    'BD': 10, // Bangladesh
    'BB': 7, // Barbados
    'BY': 9, // Belarus
    'BE': 9, // Belgium
    'BZ': 7, // Belize
    'BJ': 8, // Benin
    'BT': 8, // Bhutan
    'BO': 8, // Bolivia
    'BA': 8, // Bosnia and Herzegovina
    'BW': 7, // Botswana
    'BR': 11, // Brazil (using max of 10 or 11)
    'BN': 7, // Brunei
    'BG': 9, // Bulgaria
    'BF': 8, // Burkina Faso
    'BI': 8, // Burundi
    'CV': 7, // Cabo Verde
    'KH': 8, // Cambodia
    'CM': 8, // Cameroon
    'CA': 10, // Canada
    'CF': 8, // Central African Republic
    'TD': 8, // Chad
    'CL': 9, // Chile
    'CN': 11, // China
    'CO': 10, // Colombia
    'KM': 7, // Comoros
    'CG': 8, // Congo (Congo-Brazzaville)
    'CD': 9, // Congo (Congo-Kinshasa)
    'CR': 8, // Costa Rica
    'HR': 9, // Croatia
    'CU': 8, // Cuba
    'CY': 8, // Cyprus
    'CZ': 9, // Czech Republic
    'DK': 8, // Denmark
    'DJ': 7, // Djibouti
    'DM': 7, // Dominica
    'DO': 10, // Dominican Republic
    'EC': 9, // Ecuador
    'EG': 10, // Egypt
    'SV': 8, // El Salvador
    'GQ': 9, // Equatorial Guinea
    'ER': 7, // Eritrea
    'EE': 8, // Estonia
    'SZ': 8, // Eswatini (Swaziland)
    'ET': 9, // Ethiopia
    'FJ': 7, // Fiji
    'FI': 8, // Finland
    'FR': 9, // France
    'GA': 8, // Gabon
    'GM': 7, // Gambia
    'GE': 9, // Georgia
    'DE': 10, // Germany
    'GH': 9, // Ghana
    'GR': 10, // Greece
    'GD': 7, // Grenada
    'GT': 8, // Guatemala
    'GN': 9, // Guinea
    'GW': 7, // Guinea-Bissau
    'GY': 7, // Guyana
    'HT': 8, // Haiti
    'HN': 8, // Honduras
    'HU': 9, // Hungary
    'IS': 7, // Iceland
    'IN': 10, // India
    'ID': 10, // Indonesia
    'IR': 10, // Iran
    'IQ': 9, // Iraq
    'IE': 9, // Ireland
    'IL': 9, // Israel
    'IT': 10, // Italy
    'JM': 7, // Jamaica
    'JP': 10, // Japan
    'JO': 9, // Jordan
    'KZ': 10, // Kazakhstan
    'KE': 10, // Kenya
    'KI': 7, // Kiribati
    'KP': 8, // Korea, North
    'KR': 10, // Korea, South
    'KW': 8, // Kuwait
    'KG': 9, // Kyrgyzstan
    'LA': 8, // Laos
    'LV': 8, // Latvia
    'LB': 8, // Lebanon
    'LS': 8, // Lesotho
    'LR': 7, // Liberia
    'LY': 9, // Libya
    'LI': 7, // Liechtenstein
    'LT': 8, // Lithuania
    'LU': 8, // Luxembourg
    'MG': 9, // Madagascar
    'MW': 9, // Malawi
    'MY': 9, // Malaysia
    'MV': 7, // Maldives
    'ML': 8, // Mali
    'MT': 8, // Malta
    'MH': 7, // Marshall Islands
    'MR': 8, // Mauritania
    'MU': 8, // Mauritius
    'MX': 10, // Mexico
    'FM': 7, // Micronesia
    'MD': 8, // Moldova
    'MC': 8, // Monaco
    'MN': 8, // Mongolia
    'ME': 8, // Montenegro
    'MA': 9, // Morocco
    'MZ': 9, // Mozambique
    'MM': 9, // Myanmar (Burma)
    'NA': 8, // Namibia
    'NR': 7, // Nauru
    'NP': 10, // Nepal
    'NL': 9, // Netherlands
    'NZ': 9, // New Zealand
    'NI': 8, // Nicaragua
    'NE': 8, // Niger
    'NG': 10, // Nigeria
    'MK': 8, // North Macedonia
    'NO': 8, // Norway
    'OM': 8, // Oman
    'PK': 10, // Pakistan
    'PW': 7, // Palau
    'PA': 7, // Panama
    'PG': 9, // Papua New Guinea
    'PY': 9, // Paraguay
    'PE': 9, // Peru
    'PH': 10, // Philippines
    'PL': 9, // Poland
    'PT': 9, // Portugal
    'QA': 8, // Qatar
    'RO': 9, // Romania
    'RU': 10, // Russia
    'RW': 8, // Rwanda
    'KN': 7, // Saint Kitts and Nevis
    'LC': 7, // Saint Lucia
    'VC': 7, // Saint Vincent and the Grenadines
    'WS': 7, // Samoa
    'SM': 7, // San Marino
    'ST': 7, // Sao Tome and Principe
    'SA': 9, // Saudi Arabia
    'SN': 8, // Senegal
    'RS': 9, // Serbia
    'SC': 7, // Seychelles
    'SL': 8, // Sierra Leone
    'SG': 8, // Singapore
    'SK': 9, // Slovakia
    'SI': 8, // Slovenia
    'SB': 7, // Solomon Islands
    'SO': 8, // Somalia
    'ZA': 9, // South Africa
    'SS': 9, // South Sudan
    'ES': 9, // Spain
    'LK': 9, // Sri Lanka
    'SD': 9, // Sudan
    'SR': 7, // Suriname
    'SE': 9, // Sweden
    'CH': 9, // Switzerland
    'SY': 9, // Syria
    'TW': 9, // Taiwan
    'TJ': 9, // Tajikistan
    'TZ': 9, // Tanzania
    'TH': 9, // Thailand
    'TL': 7, // Timor-Leste
    'TG': 8, // Togo
    'TO': 7, // Tonga
    'TT': 7, // Trinidad and Tobago
    'TN': 8, // Tunisia
    'TR': 10, // Turkey
    'TM': 9, // Turkmenistan
    'TV': 7, // Tuvalu
    'UG': 9, // Uganda
    'UA': 9, // Ukraine
    'AE': 9, // United Arab Emirates
    'GB': 10, // United Kingdom
    'US': 10, // United States
    'UY': 8, // Uruguay
    'UZ': 9, // Uzbekistan
    'VU': 7, // Vanuatu
    'VA': 7, // Vatican City
    'VE': 10, // Venezuela
    'VN': 10, // Vietnam
    'YE': 9, // Yemen
    'ZM': 9, // Zambia
    'ZW': 9, // Zimbabwe
  };

  // Get the digit limit for a country code
  static int getDigitLimit(String? isoCode) {
    if (isoCode == null) return 10; // Default
    return countryDigitLimits[isoCode] ?? 10; // Default to 10 if not found
  }

  // Validate a phone number based on country code
  static String? validatePhoneNumber(String? phoneNumber, String? isoCode) {
    if (phoneNumber == null || phoneNumber.isEmpty) {
      return 'Phone number is required'.tr;
    }

    // Extract only digits from the phone number
    String digitsOnly = phoneNumber.replaceAll(RegExp(r'[^0-9]'), '');

    // Get the digit limit for the country
    int digitLimit = getDigitLimit(isoCode);

    if (digitsOnly.length > digitLimit) {
      return 'Phone number cannot exceed $digitLimit digits for this country'
          .tr;
    }

    return null; // Valid
  }
}

// Example of how to use this in a form
