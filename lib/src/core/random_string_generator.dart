import 'dart:math';

class RandomStringGenerator {
  final _randomCharset = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-._~';

  String generateRandom(int length) =>
      List.generate(length, (i) => _randomCharset[Random.secure().nextInt(_randomCharset.length)]).join();
}
