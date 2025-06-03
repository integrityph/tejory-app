class APIKeys {
  static const String API_KEY_PLACEHOLDER = "PUT_YOUR_API_KEY_HERE";
  static Map<String, String> _keys = {
    "COINDESK": "PUT_YOUR_API_KEY_HERE",
    "ALCHEMY": "PUT_YOUR_API_KEY_HERE",
    "ETHERSCAN": "PUT_YOUR_API_KEY_HERE",
  };

  static void init() {
    const APIKEY_COINDESK = String.fromEnvironment('APIKEY_COINDESK', defaultValue: "");
    _assignAPIKey("APIKEY_COINDESK", APIKEY_COINDESK);

    const APIKEY_ALCHEMY = String.fromEnvironment('APIKEY_ALCHEMY', defaultValue: "");
    _assignAPIKey("APIKEY_ALCHEMY", APIKEY_ALCHEMY);

    const APIKEY_ETHERSCAN = String.fromEnvironment('APIKEY_ETHERSCAN', defaultValue: "");
    _assignAPIKey("APIKEY_ETHERSCAN", APIKEY_ETHERSCAN);
  }

  static _assignAPIKey(String key, String value) {
    if (value != "") {
      _keys[key.replaceFirst("APIKEY_", "")] = value;
    }
  }

  static String? getAPIKey(String key) {
    String? value = _keys[key.toUpperCase()];
    if (value == API_KEY_PLACEHOLDER) {
      print("WARNING: Unable to get API key for (${key}). Please put your API key in lib/api_keys/api_keys.dart");
      value = null;
    }
    return value;
  }
}

