class Network {
  String networkSymbol = "";
  String networkName = "";
  bool requiresAmount = false;

  Network(
    this.networkSymbol,
    this.networkName,
    {
      this.requiresAmount=false,
    }
  );

  @override
  bool operator ==(Object other) {
    if (other is! Network) return false;
    if (networkSymbol != other.networkSymbol) return false;
    if (networkName != other.networkName) return false;
    return true;
  }
}

Map<String,Set<Network>> networkList = <String,Set<Network>>{
  "":{},
  "BTC":{
    Network("BTC_LEGACY", "Bitcoin (Legacy)"),
    Network("BTC_SEGWIT", "Bitcoin (SegWit)"),
    Network("BTC_TAPROOT", "Bitcoin (Taproot)"),
  },
  "ETH":{
    Network("ETH", "Ethereum"),
  },
  "USDT":{
    Network("ETH", "Ethereum (ECR-20)"),
  },
  "BTCLN":{
    Network("BTC_LEGACY", "Bitcoin (Legacy)"),
    Network("BTC_SEGWIT", "Bitcoin (SegWit)"),
    Network("BTC_TAPROOT", "Bitcoin (Taproot)"),
    Network("BTC_LIGHTNING", "Bitcoin (Lightning)", requiresAmount: true),
  }
};
