// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Thai (`th`).
class AppLocalizationsTh extends AppLocalizations {
  AppLocalizationsTh([String locale = 'th']) : super(locale);

  @override
  String get appTitle => 'Boba Lab';

  @override
  String get tagline => 'ชานมไข่มุกที่คุณออกแบบเอง';

  @override
  String get skip => 'ข้าม';

  @override
  String get next => 'ถัดไป';

  @override
  String get getStarted => 'เริ่มสั่งเลย';

  @override
  String get back => 'ย้อนกลับ';

  @override
  String get close => 'ปิด';

  @override
  String get undo => 'เลิกทำ';

  @override
  String get pageNotFound => 'ไม่พบหน้านี้';

  @override
  String get backToMenu => 'กลับไปหน้าเมนู';

  @override
  String get languageThai => 'ไทย';

  @override
  String get languageEnglish => 'English';

  @override
  String get onboard1Title => 'ปรับแก้วได้ทุกอย่าง';

  @override
  String get onboard1Body => 'เลือกชา ความหวาน น้ำแข็ง และท็อปปิ้ง แล้วดูแก้วเปลี่ยนตามทันที';

  @override
  String get onboard2Title => 'สั่งล่วงหน้า ไม่ต้องรอคิว';

  @override
  String get onboard2Body => 'จ่ายในแอปแล้วมารับตอนพร้อม ติดตามได้ทุกขั้นตอน';

  @override
  String get onboard3Title => 'ครบ 10 แก้ว ฟรี 1 แก้ว';

  @override
  String get onboard3Body => 'ทุกแก้วได้ 1 แสตมป์ สะสมครบการ์ดรับฟรีแก้วถัดไป';

  @override
  String get demoNotice => 'แอปตัวอย่าง เครื่องดื่ม ราคา และออเดอร์ทั้งหมดเป็นข้อมูลจำลอง';

  @override
  String get navMenu => 'เมนู';

  @override
  String get navOrders => 'ออเดอร์';

  @override
  String get navRewards => 'แสตมป์';

  @override
  String get navProfile => 'ฉัน';

  @override
  String get greetingMorning => 'อรุณสวัสดิ์';

  @override
  String get greetingAfternoon => 'สวัสดีตอนบ่าย';

  @override
  String get greetingEvening => 'สวัสดีตอนเย็น';

  @override
  String get menuHeadline => 'วันนี้ดื่มอะไรดี?';

  @override
  String get storeName => 'Boba Lab สาขาอารีย์';

  @override
  String get storeDistance => 'รับที่ร้าน · 450 ม.';

  @override
  String get promoTitle => 'สะสม 10 แสตมป์ รับฟรี 1 แก้ว';

  @override
  String promoProgress(int count) {
    return 'มีแล้ว $count/10';
  }

  @override
  String get promoCta => 'ดูการ์ดสะสม';

  @override
  String get menuSection => 'เมนูของเรา';

  @override
  String get filterAll => 'ทั้งหมด';

  @override
  String get filterTea => 'ชา';

  @override
  String get filterMilk => 'นมสด';

  @override
  String get filterFoam => 'ชีสโฟม';

  @override
  String get tagBestseller => 'ขายดี';

  @override
  String get tagNew => 'ใหม่';

  @override
  String get tagSignature => 'ซิกเนเจอร์';

  @override
  String quickAdd(String name) {
    return 'ใส่ $name ลงตะกร้า';
  }

  @override
  String get addedToCart => 'ใส่ตะกร้าแล้ว';

  @override
  String addedNamed(String name) {
    return 'ใส่ $name ลงตะกร้าแล้ว';
  }

  @override
  String get viewCart => 'ดูตะกร้า';

  @override
  String cupCount(int count) {
    return '$count แก้ว';
  }

  @override
  String get builderTitle => 'ปรับแก้วของคุณ';

  @override
  String get base => 'รสชาติ';

  @override
  String get size => 'ขนาด';

  @override
  String get sizeMedium => 'M · 16 ออนซ์';

  @override
  String get sizeLarge => 'L · 22 ออนซ์';

  @override
  String get sweetness => 'ความหวาน';

  @override
  String get ice => 'น้ำแข็ง';

  @override
  String get iceNone => 'ไม่ใส่';

  @override
  String get iceLess => 'น้อย';

  @override
  String get iceRegular => 'ปกติ';

  @override
  String get iceExtra => 'เยอะ';

  @override
  String get toppings => 'ท็อปปิ้ง';

  @override
  String get addToCart => 'ใส่ตะกร้า';

  @override
  String summarySweet(int percent) {
    return 'หวาน $percent%';
  }

  @override
  String get summaryNoIce => 'ไม่ใส่น้ำแข็ง';

  @override
  String get summaryIceLess => 'น้ำแข็งน้อย';

  @override
  String get summaryIceRegular => 'น้ำแข็งปกติ';

  @override
  String get summaryIceExtra => 'น้ำแข็งเยอะ';

  @override
  String get summaryNoToppings => 'ไม่ใส่ท็อปปิ้ง';

  @override
  String summaryToppingCount(int count) {
    return 'ท็อปปิ้ง $count อย่าง';
  }

  @override
  String get drinkNotFound => 'ไม่พบเมนูนี้';

  @override
  String get cartTitle => 'ตะกร้า';

  @override
  String get cartEmptyTitle => 'ยังไม่มีแก้วในตะกร้า';

  @override
  String get cartEmptyBody => 'ปรับแก้วที่ชอบแล้วใส่ตะกร้าได้เลย';

  @override
  String get browseMenu => 'ไปเลือกเมนู';

  @override
  String removedItem(String name) {
    return 'ลบ $name แล้ว';
  }

  @override
  String get pickupTime => 'เวลารับ';

  @override
  String get pickupAsap => 'เร็วที่สุด · ~15 นาที';

  @override
  String pickupIn(int minutes) {
    return 'อีก $minutes นาที';
  }

  @override
  String get useFreeCup => 'ใช้สิทธิ์แก้วฟรี';

  @override
  String freeCupsLeft(int count) {
    return 'เหลือ $count สิทธิ์';
  }

  @override
  String get subtotal => 'ค่าเครื่องดื่ม';

  @override
  String get discount => 'ส่วนลดแก้วฟรี';

  @override
  String get total => 'รวม';

  @override
  String get goToCheckout => 'ไปชำระเงิน';

  @override
  String get decreaseQuantity => 'ลดจำนวน';

  @override
  String get increaseQuantity => 'เพิ่มจำนวน';

  @override
  String quantity(int count) {
    return 'จำนวน $count';
  }

  @override
  String get checkoutTitle => 'ชำระเงิน';

  @override
  String get orderSummary => 'สรุปรายการ';

  @override
  String get paymentMethod => 'วิธีชำระเงิน';

  @override
  String get payPromptPay => 'พร้อมเพย์ (QR)';

  @override
  String get payPromptPayHint => 'สแกนจ่ายผ่านแอปธนาคาร';

  @override
  String get payCard => 'บัตรเครดิต/เดบิต';

  @override
  String get payCardHint => 'Visa •••• 4242 (ตัวอย่าง)';

  @override
  String get payCash => 'จ่ายที่ร้าน';

  @override
  String get payCashHint => 'ชำระตอนรับเครื่องดื่ม';

  @override
  String pickupAt(String store) {
    return 'รับที่ $store';
  }

  @override
  String payAmount(String amount) {
    return 'ชำระ $amount';
  }

  @override
  String get placeOrder => 'ยืนยันออเดอร์';

  @override
  String get qrTitle => 'สแกนเพื่อชำระเงิน';

  @override
  String get qrSample => 'QR ตัวอย่าง ใช้ชำระเงินจริงไม่ได้';

  @override
  String qrExpires(String time) {
    return 'หมดเวลาใน $time';
  }

  @override
  String get qrSimulate => 'จำลองว่าจ่ายสำเร็จ';

  @override
  String get processingPayment => 'กำลังยืนยันการชำระเงิน…';

  @override
  String get processingOrder => 'กำลังส่งออเดอร์ไปที่ร้าน…';

  @override
  String get successTitle => 'ชำระเงินสำเร็จ!';

  @override
  String get successTitleCash => 'ส่งออเดอร์แล้ว!';

  @override
  String orderNumber(String number) {
    return 'ออเดอร์ $number';
  }

  @override
  String get pickupCode => 'รหัสรับเครื่องดื่ม';

  @override
  String stampsEarned(int count) {
    return '+$count แสตมป์';
  }

  @override
  String get trackOrder => 'ติดตามออเดอร์';

  @override
  String readyAround(String time) {
    return 'พร้อมรับประมาณ $time น.';
  }

  @override
  String get statusReceived => 'ร้านรับออเดอร์แล้ว';

  @override
  String get statusReceivedBody => 'ร้านได้รับออเดอร์ของคุณแล้ว';

  @override
  String get statusBrewing => 'กำลังชงเครื่องดื่ม';

  @override
  String get statusBrewingBody => 'บาริสต้ากำลังทำแก้วของคุณอยู่';

  @override
  String get statusReady => 'พร้อมรับแล้ว';

  @override
  String get statusReadyBody => 'แสดงรหัสรับที่เคาน์เตอร์ได้เลย';

  @override
  String get statusCompleted => 'รับเครื่องดื่มแล้ว';

  @override
  String get statusCompletedBody => 'ขอให้อร่อย ขอบคุณที่สั่งกับเรา';

  @override
  String get pickedUp => 'รับเครื่องดื่มแล้ว';

  @override
  String get demoNextStep => 'เดโม: ไปขั้นถัดไป';

  @override
  String get orderNotFound => 'ไม่พบออเดอร์นี้';

  @override
  String get orderAgain => 'สั่งอีกครั้ง';

  @override
  String get items => 'รายการ';

  @override
  String get store => 'สาขา';

  @override
  String get storeAddress => 'ซอยอารีย์ 1 พญาไท กรุงเทพฯ';

  @override
  String get ordersTitle => 'ออเดอร์';

  @override
  String get activeOrder => 'กำลังดำเนินการ';

  @override
  String get pastOrders => 'ออเดอร์ที่ผ่านมา';

  @override
  String get noOrders => 'ยังไม่มีออเดอร์';

  @override
  String get today => 'วันนี้';

  @override
  String get yesterday => 'เมื่อวาน';

  @override
  String daysAgo(int count) {
    return '$count วันก่อน';
  }

  @override
  String get rewardsTitle => 'การ์ดสะสมแสตมป์';

  @override
  String stampsToGo(int count) {
    return 'อีก $count แก้ว รับฟรี 1 แก้ว';
  }

  @override
  String get cardComplete => 'ครบการ์ดแล้ว! ได้แก้วฟรี 1 แก้ว';

  @override
  String get freeCups => 'แก้วฟรีของคุณ';

  @override
  String get freeCupTicket => 'ฟรี 1 แก้ว · ใช้ได้ทุกเมนู';

  @override
  String get freeCupHint => 'เปิดใช้ได้ในตะกร้าก่อนชำระเงิน';

  @override
  String get noFreeCups => 'ยังไม่มีแก้วฟรี สะสมต่ออีกนิด';

  @override
  String get howItWorks => 'สะสมยังไง';

  @override
  String get how1 => 'ทุกแก้วที่สั่ง ได้ 1 แสตมป์';

  @override
  String get how2 => 'สะสมครบ 10 แสตมป์ = 1 การ์ด';

  @override
  String get how3 => 'ครบการ์ดรับแก้วฟรีทันที';

  @override
  String get guest => 'แขก';

  @override
  String get member => 'สมาชิก Boba Lab';

  @override
  String get settings => 'ตั้งค่า';

  @override
  String get language => 'ภาษา';

  @override
  String get reduceMotion => 'ลดการเคลื่อนไหว';

  @override
  String get reduceMotionHint => 'ปิดการเด้งและ animation ตกแต่ง';

  @override
  String get replayOnboarding => 'ดูหน้าแนะนำอีกครั้ง';

  @override
  String get resetDemo => 'รีเซ็ตข้อมูลตัวอย่าง';

  @override
  String get resetDone => 'รีเซ็ตข้อมูลตัวอย่างแล้ว';

  @override
  String get aboutTitle => 'เกี่ยวกับโปรเจกต์นี้';

  @override
  String get aboutBody => 'ผลงาน portfolio ฝั่ง frontend เครื่องดื่ม ราคา และออเดอร์ทั้งหมดเป็นข้อมูลตัวอย่าง ไม่มีการเรียกเก็บเงินจริง';

  @override
  String get builtWith => 'สร้างด้วย';

  @override
  String get designedWith => 'ออกแบบด้วย';

  @override
  String version(String version) {
    return 'เวอร์ชัน $version';
  }

  @override
  String get frameBody => 'แอปสั่งชานมไข่มุกที่ทำด้วย Flutter ลองกดเล่นในมือถือได้เลย ทุกออเดอร์เป็นข้อมูลตัวอย่าง';

  @override
  String get frameHint => 'ลองกดเล่นในมือถือ';
}
