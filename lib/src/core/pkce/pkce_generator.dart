import 'dart:convert';

import 'package:crypto/crypto.dart';

import 'pkce_pair.dart';
import '../random_string_generator.dart';

enum PkceEncoding {
  plain,
  // ignore: constant_identifier_names
  S256,
}

class PkceGenerator {
  final PkceEncoding encoding;

  PkceGenerator({this.encoding = PkceEncoding.S256});

  PkcePair build() {
    final verifier = RandomStringGenerator().generateRandom(128);
    final challenge = _generateChallenge(verifier);

    return PkcePair(codeChallenge: challenge, codeVerifier: verifier);
  }

  String _generateChallenge(String codeVerifier) {
    final codeAsAscii = ascii.encode(codeVerifier);
    final encryptedCode = sha256.convert(codeAsAscii).bytes;
    final challenge = base64Url.encode(encryptedCode).replaceAll('=', '');

    return challenge;
  }
}
