import 'dart:async';

import 'package:flutter/foundation.dart';

import '../data/models.dart';

/// Places mock orders and walks them through the store's statuses on timers:
/// received → brewing → ready. The customer marks "picked up" themselves.
class OrderController extends ChangeNotifier {
  OrderController({
    DateTime Function()? clock,
    this.brewAfter = const Duration(seconds: 4),
    this.readyAfter = const Duration(seconds: 7),
    List<Order> history = const [],
  }) : _clock = clock ?? DateTime.now,
       _orders = [...history];

  final DateTime Function() _clock;
  final Duration brewAfter;
  final Duration readyAfter;
  final List<Order> _orders;
  Timer? _timer;
  int _sequence = 427;

  List<Order> get orders => List.unmodifiable(_orders);

  Order? get active {
    for (final order in _orders) {
      if (order.isActive) return order;
    }
    return null;
  }

  List<Order> get past => _orders.where((order) => !order.isActive).toList();

  Order? byNumber(String number) {
    for (final order in _orders) {
      if (order.number == number) return order;
    }
    return null;
  }

  Order place({
    required List<CartLine> lines,
    required int subtotal,
    required int discount,
    required PaymentMethod payment,
    required int pickupMinutes,
  }) {
    final now = _clock();
    final seq = _sequence++;
    final order = Order(
      number: 'BL-${seq.toString().padLeft(4, '0')}',
      pickupCode: '${String.fromCharCode(65 + seq % 6)}${seq * 7 % 90 + 10}',
      lines: List.unmodifiable(lines),
      subtotal: subtotal,
      discount: discount,
      payment: payment,
      placedAt: now,
      readyAt: now.add(Duration(minutes: pickupMinutes)),
      statusTimes: {OrderStatus.received: now},
    );
    _orders.insert(0, order);
    _schedule();
    notifyListeners();
    return order;
  }

  /// Moves an order one status forward, stopping at "ready".
  void advance(String number) {
    final index = _orders.indexWhere((order) => order.number == number);
    if (index < 0) return;
    final order = _orders[index];
    if (order.status.index >= OrderStatus.ready.index) return;
    _setStatus(index, OrderStatus.values[order.status.index + 1]);
  }

  void pickUp(String number) {
    final index = _orders.indexWhere((order) => order.number == number);
    if (index < 0 || !_orders[index].isActive) return;
    _setStatus(index, OrderStatus.completed);
  }

  void reset({List<Order> history = const []}) {
    _timer?.cancel();
    _orders
      ..clear()
      ..addAll(history);
    notifyListeners();
  }

  void _setStatus(int index, OrderStatus status) {
    final order = _orders[index];
    _orders[index] = order.copyWith(status: status, statusTimes: {...order.statusTimes, status: _clock()});
    _schedule();
    notifyListeners();
  }

  void _schedule() {
    _timer?.cancel();
    final order = active;
    if (order == null) return;
    final wait = switch (order.status) {
      OrderStatus.received => brewAfter,
      OrderStatus.brewing => readyAfter,
      _ => null,
    };
    if (wait == null) return;
    final number = order.number;
    _timer = Timer(wait, () => advance(number));
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
