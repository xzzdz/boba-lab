import 'dart:math' as math;

import 'package:flutter/foundation.dart';

import '../data/models.dart';

class CartController extends ChangeNotifier {
  final List<CartLine> _lines = [];
  int _nextId = 1;
  PickupSlot _pickup = PickupSlot.asap;
  bool _useFreeCup = false;

  List<CartLine> get lines => List.unmodifiable(_lines);
  bool get isEmpty => _lines.isEmpty;
  int get cupCount => _lines.fold(0, (sum, line) => sum + line.quantity);
  int get subtotal => _lines.fold(0, (sum, line) => sum + line.total);
  PickupSlot get pickup => _pickup;
  bool get useFreeCup => _useFreeCup;

  /// A free cup covers the most expensive single cup in the cart.
  int freeCupDiscount({required bool available}) {
    if (!available || !_useFreeCup || _lines.isEmpty) return 0;
    return _lines.map((line) => line.config.unitPrice).reduce(math.max);
  }

  int total({required bool freeCupAvailable}) => subtotal - freeCupDiscount(available: freeCupAvailable);

  /// Adds cups; an identical cup already in the cart just gets more quantity.
  CartLine add(CupConfig config, {int quantity = 1}) {
    final index = _lines.indexWhere((line) => line.config == config);
    final CartLine line;
    if (index >= 0) {
      line = _lines[index].copyWith(quantity: _lines[index].quantity + quantity);
      _lines[index] = line;
    } else {
      line = CartLine(id: 'line-${_nextId++}', config: config, quantity: quantity);
      _lines.add(line);
    }
    notifyListeners();
    return line;
  }

  void setQuantity(String id, int quantity) {
    final index = _lines.indexWhere((line) => line.id == id);
    if (index < 0) return;
    if (quantity <= 0) {
      _lines.removeAt(index);
    } else {
      _lines[index] = _lines[index].copyWith(quantity: quantity);
    }
    notifyListeners();
  }

  /// Removes a line and returns it with its position, for undo.
  ({CartLine line, int index})? remove(String id) {
    final index = _lines.indexWhere((line) => line.id == id);
    if (index < 0) return null;
    final line = _lines.removeAt(index);
    notifyListeners();
    return (line: line, index: index);
  }

  void restore(CartLine line, int index) {
    _lines.insert(math.min(index, _lines.length), line);
    notifyListeners();
  }

  void setPickup(PickupSlot slot) {
    if (slot == _pickup) return;
    _pickup = slot;
    notifyListeners();
  }

  void setUseFreeCup(bool value) {
    if (value == _useFreeCup) return;
    _useFreeCup = value;
    notifyListeners();
  }

  void clear() {
    _lines.clear();
    _pickup = PickupSlot.asap;
    _useFreeCup = false;
    notifyListeners();
  }
}
