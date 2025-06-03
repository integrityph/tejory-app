class Seed {
  final String seedRange;
  final int phraseLength;

  Seed(this.seedRange, this.phraseLength);
}

Set<Seed> seedList = <Seed>{
  Seed("12-word phrase", 12),
  Seed("15-word phrase", 15),
  Seed("18-word phrase", 18),
  Seed("21-word phrase", 21),
  Seed("24-word phrase", 24),
};
