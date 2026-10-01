import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';

import 'catalog.dart';

/// Text in both supported languages.
@immutable
class LText {
  const LText(this.th, this.en);

  final String th;
  final String en;

  String of(Locale locale) => locale.languageCode == 'th' ? th : en;
}

enum BaseId { milkTea, thaiTea, taro, matcha, strawberry, brownSugar }

/// The drink a cup starts from. Its colour fills the cup.
@immutable
class TeaBase {
  const TeaBase({required this.id, required this.name, required this.inName, required this.color, required this.price});

  final BaseId id;

  /// ชานม / Milk tea
  final LText name;

  /// English name after a topping, e.g. "Pearl **milk tea**".
  final String inName;
  final Color color;
  final int price;
}

enum ToppingId { pearls, cheeseFoam, grassJelly, pudding }

@immutable
class Topping {
  const Topping({required this.id, required this.name, required this.prefix, required this.price});

  final ToppingId id;
  final LText name;

  /// English word placed before the base: "Pearl", "Cheese foam".
  final String prefix;
  final int price;
}

enum IceLevel {
  none(0),
  less(2),
  regular(4),
  extra(6);

  const IceLevel(this.cubes);

  /// Ice cubes drawn in the cup.
  final int cubes;
}

enum CupSize {
  medium(extra: 0, scale: 0.9),
  large(extra: 10, scale: 1);

  const CupSize({required this.extra, required this.scale});

  final int extra;

  /// Drawn size relative to a large cup.
  final double scale;
}

const sweetnessLevels = <int>[0, 25, 50, 75, 100];

/// Everything that makes one cup. Equal configs merge into one cart line.
@immutable
class CupConfig {
  const CupConfig({
    required this.base,
    this.size = CupSize.medium,
    this.sweetness = 50,
    this.ice = IceLevel.regular,
    this.toppings = const {},
  });

  final BaseId base;
  final CupSize size;
  final int sweetness;
  final IceLevel ice;
  final Set<ToppingId> toppings;

  TeaBase get tea => Catalog.base(base);

  int get unitPrice => tea.price + size.extra + toppings.fold(0, (sum, id) => sum + Catalog.topping(id).price);

  /// Toppings in menu order, so names and summaries read the same every time.
  List<ToppingId> get orderedToppings => ToppingId.values.where(toppings.contains).toList();

  /// "ชานมไข่มุก" / "Pearl milk tea". Named after the first topping only.
  String name(Locale locale) {
    final toppings = orderedToppings;
    if (toppings.isEmpty) return tea.name.of(locale);
    final topping = Catalog.topping(toppings.first);
    return locale.languageCode == 'th' ? '${tea.name.th}${topping.name.th}' : '${topping.prefix} ${tea.inName}';
  }

  CupConfig copyWith({BaseId? base, CupSize? size, int? sweetness, IceLevel? ice, Set<ToppingId>? toppings}) {
    return CupConfig(
      base: base ?? this.base,
      size: size ?? this.size,
      sweetness: sweetness ?? this.sweetness,
      ice: ice ?? this.ice,
      toppings: toppings ?? this.toppings,
    );
  }

  CupConfig toggle(ToppingId id) {
    final next = {...toppings};
    if (!next.remove(id)) next.add(id);
    return copyWith(toppings: Set.unmodifiable(next));
  }

  @override
  bool operator ==(Object other) =>
      other is CupConfig &&
      other.base == base &&
      other.size == size &&
      other.sweetness == sweetness &&
      other.ice == ice &&
      setEquals(other.toppings, toppings);

  @override
  int get hashCode => Object.hash(base, size, sweetness, ice, Object.hashAllUnordered(toppings));
}

enum MenuTag { bestseller, isNew, signature }

enum MenuFilter { all, tea, milk, cheeseFoam }

@immutable
class MenuItem {
  const MenuItem({required this.id, required this.preset, required this.blurb, this.tag});

  final String id;
  final CupConfig preset;
  final LText blurb;
  final MenuTag? tag;

  static const _teaBases = {BaseId.milkTea, BaseId.thaiTea, BaseId.matcha};

  bool matches(MenuFilter filter) => switch (filter) {
    MenuFilter.all => true,
    MenuFilter.tea => _teaBases.contains(preset.base),
    MenuFilter.milk => !_teaBases.contains(preset.base),
    MenuFilter.cheeseFoam => preset.toppings.contains(ToppingId.cheeseFoam),
  };
}

@immutable
class CartLine {
  const CartLine({required this.id, required this.config, required this.quantity});

  final String id;
  final CupConfig config;
  final int quantity;

  int get total => config.unitPrice * quantity;

  CartLine copyWith({int? quantity}) => CartLine(id: id, config: config, quantity: quantity ?? this.quantity);
}

enum PickupSlot {
  asap(15),
  in30(30),
  in45(45),
  in60(60);

  const PickupSlot(this.minutes);

  final int minutes;
}

enum PaymentMethod { promptPay, card, cash }

enum OrderStatus { received, brewing, ready, completed }

@immutable
class Order {
  const Order({
    required this.number,
    required this.pickupCode,
    required this.lines,
    required this.subtotal,
    required this.discount,
    required this.payment,
    required this.placedAt,
    required this.readyAt,
    this.status = OrderStatus.received,
    this.statusTimes = const {},
  });

  /// BL-0427
  final String number;

  /// A27
  final String pickupCode;
  final List<CartLine> lines;
  final int subtotal;
  final int discount;
  final PaymentMethod payment;
  final DateTime placedAt;
  final DateTime readyAt;
  final OrderStatus status;

  /// When each status was reached.
  final Map<OrderStatus, DateTime> statusTimes;

  int get total => subtotal - discount;
  int get cups => lines.fold(0, (sum, line) => sum + line.quantity);
  bool get isActive => status != OrderStatus.completed;

  Order copyWith({OrderStatus? status, Map<OrderStatus, DateTime>? statusTimes}) {
    return Order(
      number: number,
      pickupCode: pickupCode,
      lines: lines,
      subtotal: subtotal,
      discount: discount,
      payment: payment,
      placedAt: placedAt,
      readyAt: readyAt,
      status: status ?? this.status,
      statusTimes: statusTimes ?? this.statusTimes,
    );
  }
}
