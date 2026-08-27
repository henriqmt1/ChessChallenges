class BoardMove {
  const BoardMove({required this.from, required this.to});

  final String from;
  final String to;

  Set<String> get squares => {from, to};
}
