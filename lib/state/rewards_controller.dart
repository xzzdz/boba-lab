import 'package:flutter/foundation.dart';

/// One stamp per cup; every full card of 10 becomes a free cup.
class RewardsController extends ChangeNotifier {
  RewardsController({this._stamps = 6, this._freeCups = 0});

  static const cardSize = 10;

  int _stamps;
  int _freeCups;
  int _fresh = 0;
  bool _completedCard = false;

  /// Stamps on the current card, 0–9.
  int get stamps => _stamps;
  int get freeCups => _freeCups;
  int get toGo => cardSize - _stamps;

  /// Stamps added since the stamp card last showed them; it animates these.
  int get freshStamps => _fresh;

  /// A card filled up since the stamp card was last seen.
  bool get completedCard => _completedCard;

  /// Adds stamps and returns how many cards were completed.
  int addStamps(int count) {
    if (count <= 0) return 0;
    final total = _stamps + count;
    final cards = total ~/ cardSize;
    _stamps = total % cardSize;
    _freeCups += cards;
    _fresh = cards > 0 ? _stamps : _fresh + count;
    _completedCard = _completedCard || cards > 0;
    notifyListeners();
    return cards;
  }

  /// The stamp card has played its animations. Deliberately silent: nothing
  /// else needs to rebuild for this.
  void acknowledge() {
    _fresh = 0;
    _completedCard = false;
  }

  bool useFreeCup() {
    if (_freeCups == 0) return false;
    _freeCups--;
    notifyListeners();
    return true;
  }

  void reset({int stamps = 6, int freeCups = 0}) {
    _stamps = stamps;
    _freeCups = freeCups;
    _fresh = 0;
    _completedCard = false;
    notifyListeners();
  }
}
