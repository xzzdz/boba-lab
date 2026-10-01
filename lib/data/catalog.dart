import 'package:flutter/painting.dart';

import 'models.dart';

/// Sample menu for the demo. Prices are in Thai baht; every menu price is
/// derived from base + size + toppings, never typed twice.
abstract final class Catalog {
  static const bases = <TeaBase>[
    TeaBase(id: BaseId.milkTea, name: LText('ชานม', 'Milk tea'), inName: 'milk tea', color: Color(0xFFC99A6E), price: 55),
    TeaBase(id: BaseId.thaiTea, name: LText('ชาไทย', 'Thai tea'), inName: 'Thai tea', color: Color(0xFFEE8A3A), price: 55),
    TeaBase(id: BaseId.taro, name: LText('นมเผือก', 'Taro milk'), inName: 'taro milk', color: Color(0xFFB39BDF), price: 60),
    TeaBase(id: BaseId.matcha, name: LText('มัทฉะลาเต้', 'Matcha latte'), inName: 'matcha latte', color: Color(0xFF8DBA68), price: 65),
    TeaBase(
      id: BaseId.strawberry,
      name: LText('นมสตรอว์เบอร์รี', 'Strawberry milk'),
      inName: 'strawberry milk',
      color: Color(0xFFF09AB3),
      price: 60,
    ),
    TeaBase(
      id: BaseId.brownSugar,
      name: LText('นมสดบราวน์ชูการ์', 'Brown sugar milk'),
      inName: 'brown sugar milk',
      color: Color(0xFFB07A52),
      price: 65,
    ),
  ];

  static const toppings = <Topping>[
    Topping(id: ToppingId.pearls, name: LText('ไข่มุก', 'Pearls'), prefix: 'Pearl', price: 10),
    Topping(id: ToppingId.cheeseFoam, name: LText('ชีสโฟม', 'Cheese foam'), prefix: 'Cheese foam', price: 15),
    Topping(id: ToppingId.grassJelly, name: LText('เฉาก๊วย', 'Grass jelly'), prefix: 'Grass jelly', price: 10),
    Topping(id: ToppingId.pudding, name: LText('พุดดิ้ง', 'Pudding'), prefix: 'Pudding', price: 10),
  ];

  static TeaBase base(BaseId id) => bases[id.index];
  static Topping topping(ToppingId id) => toppings[id.index];

  static const menu = <MenuItem>[
    MenuItem(
      id: 'pearl-milk-tea',
      preset: CupConfig(base: BaseId.milkTea, toppings: {ToppingId.pearls}),
      blurb: LText('สูตรคลาสสิก ชาเข้ม นมหอม ไข่มุกหนึบ', 'The classic: bold tea, creamy milk, chewy pearls.'),
      tag: MenuTag.bestseller,
    ),
    MenuItem(
      id: 'pearl-thai-tea',
      preset: CupConfig(base: BaseId.thaiTea, toppings: {ToppingId.pearls}),
      blurb: LText('ชาไทยสีส้มสด หวานมันกำลังดี', 'Bright orange Thai tea, sweet and creamy.'),
      tag: MenuTag.bestseller,
    ),
    MenuItem(
      id: 'brown-sugar-pearl',
      preset: CupConfig(base: BaseId.brownSugar, sweetness: 75, toppings: {ToppingId.pearls}),
      blurb: LText('บราวน์ชูการ์เคี่ยวเอง ไหลเป็นลายข้างแก้ว', 'House-cooked brown sugar that streaks down the cup.'),
      tag: MenuTag.signature,
    ),
    MenuItem(
      id: 'cheese-foam-milk-tea',
      preset: CupConfig(base: BaseId.milkTea, toppings: {ToppingId.cheeseFoam}),
      blurb: LText('ชีสโฟมเค็มนิดๆ ตัดความหวาน', 'Lightly salted cheese foam on top.'),
    ),
    MenuItem(
      id: 'cheese-foam-thai-tea',
      preset: CupConfig(base: BaseId.thaiTea, toppings: {ToppingId.cheeseFoam}),
      blurb: LText('ชาไทยเข้มๆ กับชีสโฟมนุ่ม', 'Strong Thai tea under soft cheese foam.'),
      tag: MenuTag.bestseller,
    ),
    MenuItem(
      id: 'taro-pudding',
      preset: CupConfig(base: BaseId.taro, toppings: {ToppingId.pudding}),
      blurb: LText('เผือกหอม พุดดิ้งไข่เนื้อนุ่ม', 'Fragrant taro with silky egg pudding.'),
    ),
    MenuItem(
      id: 'taro-pearl',
      preset: CupConfig(base: BaseId.taro, toppings: {ToppingId.pearls}),
      blurb: LText('นมเผือกสีม่วงอ่อน ไข่มุกเคี้ยวเพลิน', 'Lilac taro milk with chewy pearls.'),
    ),
    MenuItem(
      id: 'matcha-latte',
      preset: CupConfig(base: BaseId.matcha, sweetness: 25),
      blurb: LText('มัทฉะเข้มข้น ขมนิดๆ หวานน้อย', 'Rich matcha, a little bitter, lightly sweet.'),
    ),
    MenuItem(
      id: 'cheese-foam-matcha',
      preset: CupConfig(base: BaseId.matcha, sweetness: 25, toppings: {ToppingId.cheeseFoam}),
      blurb: LText('มัทฉะกับชีสโฟม เค็ม หวาน ขม ครบ', 'Matcha and cheese foam: salty, sweet, bitter.'),
      tag: MenuTag.isNew,
    ),
    MenuItem(
      id: 'strawberry-milk',
      preset: CupConfig(base: BaseId.strawberry, ice: IceLevel.less),
      blurb: LText('สตรอว์เบอร์รีสดปั่นกับนม', 'Fresh strawberries blended with milk.'),
      tag: MenuTag.isNew,
    ),
    MenuItem(
      id: 'strawberry-cheese-foam',
      preset: CupConfig(base: BaseId.strawberry, ice: IceLevel.less, toppings: {ToppingId.cheeseFoam}),
      blurb: LText('นมสตรอว์เบอร์รีราดชีสโฟม', 'Strawberry milk crowned with cheese foam.'),
      tag: MenuTag.isNew,
    ),
    MenuItem(
      id: 'grass-jelly-milk-tea',
      preset: CupConfig(base: BaseId.milkTea, sweetness: 25, toppings: {ToppingId.grassJelly}),
      blurb: LText('เฉาก๊วยเย็นๆ หวานน้อย สดชื่น', 'Cool grass jelly, less sweet, very refreshing.'),
    ),
  ];

  static MenuItem? item(String id) {
    for (final item in menu) {
      if (item.id == id) return item;
    }
    return null;
  }
}
