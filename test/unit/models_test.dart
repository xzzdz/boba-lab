import 'package:boba_lab/data/catalog.dart';
import 'package:boba_lab/data/models.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';

const th = Locale('th');
const en = Locale('en');

void main() {
  group('CupConfig price', () {
    test('base only', () {
      expect(const CupConfig(base: BaseId.milkTea).unitPrice, 55);
    });

    test('adds size and every topping', () {
      const cup = CupConfig(base: BaseId.matcha, size: CupSize.large, toppings: {ToppingId.pearls, ToppingId.cheeseFoam});
      expect(cup.unitPrice, 65 + 10 + 10 + 15);
    });

    test('every menu price is base + size + toppings', () {
      for (final item in Catalog.menu) {
        final preset = item.preset;
        final expected = preset.tea.price + preset.size.extra + preset.toppings.fold<int>(0, (sum, id) => sum + Catalog.topping(id).price);
        expect(preset.unitPrice, expected, reason: item.id);
      }
    });
  });

  group('CupConfig name', () {
    test('no toppings uses the base name', () {
      const cup = CupConfig(base: BaseId.taro);
      expect(cup.name(th), 'นมเผือก');
      expect(cup.name(en), 'Taro milk');
    });

    test('Thai appends, English prefixes the first topping', () {
      const cup = CupConfig(base: BaseId.milkTea, toppings: {ToppingId.pearls});
      expect(cup.name(th), 'ชานมไข่มุก');
      expect(cup.name(en), 'Pearl milk tea');
    });

    test('names follow menu order, not tap order', () {
      final cup = const CupConfig(base: BaseId.thaiTea).toggle(ToppingId.pudding).toggle(ToppingId.cheeseFoam);
      expect(cup.name(en), 'Cheese foam Thai tea');
      expect(cup.orderedToppings, [ToppingId.cheeseFoam, ToppingId.pudding]);
    });
  });

  test('toggle adds then removes a topping', () {
    final on = const CupConfig(base: BaseId.milkTea).toggle(ToppingId.pearls);
    expect(on.toppings, {ToppingId.pearls});
    expect(on.toggle(ToppingId.pearls).toppings, isEmpty);
  });

  test('equal configs are equal regardless of topping order', () {
    const a = CupConfig(base: BaseId.milkTea, toppings: {ToppingId.pearls, ToppingId.pudding});
    const b = CupConfig(base: BaseId.milkTea, toppings: {ToppingId.pudding, ToppingId.pearls});
    expect(a, b);
    expect(a.hashCode, b.hashCode);
    expect(a == a.copyWith(sweetness: 75), isFalse);
  });

  test('menu filters', () {
    int count(MenuFilter filter) => Catalog.menu.where((item) => item.matches(filter)).length;
    expect(count(MenuFilter.all), Catalog.menu.length);
    expect(count(MenuFilter.tea) + count(MenuFilter.milk), Catalog.menu.length);
    expect(count(MenuFilter.cheeseFoam), 4);
  });

  test('menu ids are unique and resolvable', () {
    final ids = Catalog.menu.map((item) => item.id).toSet();
    expect(ids.length, Catalog.menu.length);
    for (final id in ids) {
      expect(Catalog.item(id)?.id, id);
    }
    expect(Catalog.item('nope'), isNull);
  });
}
