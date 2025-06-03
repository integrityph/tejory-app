class Currency {
  String name;
	String isoName;
  String symbol;
  bool symbolBeforeNumber;
  double usdMultiplier = 1.0;

  Currency(this.name, this.isoName, this.symbol, this.symbolBeforeNumber);
}