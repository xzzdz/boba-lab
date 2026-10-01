// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Boba Lab';

  @override
  String get tagline => 'Bubble tea you design yourself';

  @override
  String get skip => 'Skip';

  @override
  String get next => 'Next';

  @override
  String get getStarted => 'Start ordering';

  @override
  String get back => 'Back';

  @override
  String get close => 'Close';

  @override
  String get undo => 'Undo';

  @override
  String get pageNotFound => 'We couldn\'t find that page.';

  @override
  String get backToMenu => 'Back to menu';

  @override
  String get languageThai => 'ไทย';

  @override
  String get languageEnglish => 'English';

  @override
  String get onboard1Title => 'Build your cup, your way';

  @override
  String get onboard1Body => 'Pick the base, sweetness, ice and toppings, and watch your cup change as you go.';

  @override
  String get onboard2Title => 'Order ahead, skip the line';

  @override
  String get onboard2Body => 'Pay in the app and pick up when it\'s ready. You\'ll see every step.';

  @override
  String get onboard3Title => 'Every 10th cup is on us';

  @override
  String get onboard3Body => 'Each cup earns a stamp. Fill the card and your next cup is free.';

  @override
  String get demoNotice => 'Demo app. All drinks, prices and orders are sample data.';

  @override
  String get navMenu => 'Menu';

  @override
  String get navOrders => 'Orders';

  @override
  String get navRewards => 'Stamps';

  @override
  String get navProfile => 'Me';

  @override
  String get greetingMorning => 'Good morning';

  @override
  String get greetingAfternoon => 'Good afternoon';

  @override
  String get greetingEvening => 'Good evening';

  @override
  String get menuHeadline => 'What are we sipping today?';

  @override
  String get storeName => 'Boba Lab Ari';

  @override
  String get storeDistance => 'Pickup · 450 m';

  @override
  String get promoTitle => '10 stamps = 1 free cup';

  @override
  String promoProgress(int count) {
    return '$count of 10 stamps';
  }

  @override
  String get promoCta => 'See my card';

  @override
  String get menuSection => 'Our menu';

  @override
  String get filterAll => 'All';

  @override
  String get filterTea => 'Tea';

  @override
  String get filterMilk => 'Fresh milk';

  @override
  String get filterFoam => 'Cheese foam';

  @override
  String get tagBestseller => 'Bestseller';

  @override
  String get tagNew => 'New';

  @override
  String get tagSignature => 'Signature';

  @override
  String quickAdd(String name) {
    return 'Add $name to cart';
  }

  @override
  String get addedToCart => 'Added to cart';

  @override
  String addedNamed(String name) {
    return '$name is in your cart';
  }

  @override
  String get viewCart => 'View cart';

  @override
  String cupCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(count, locale: localeName, other: '$count cups', one: '1 cup');
    return '$_temp0';
  }

  @override
  String get builderTitle => 'Build your cup';

  @override
  String get base => 'Base';

  @override
  String get size => 'Size';

  @override
  String get sizeMedium => 'M · 16 oz';

  @override
  String get sizeLarge => 'L · 22 oz';

  @override
  String get sweetness => 'Sweetness';

  @override
  String get ice => 'Ice';

  @override
  String get iceNone => 'None';

  @override
  String get iceLess => 'Less';

  @override
  String get iceRegular => 'Regular';

  @override
  String get iceExtra => 'Extra';

  @override
  String get toppings => 'Toppings';

  @override
  String get addToCart => 'Add to cart';

  @override
  String summarySweet(int percent) {
    return '$percent% sweet';
  }

  @override
  String get summaryNoIce => 'No ice';

  @override
  String get summaryIceLess => 'Less ice';

  @override
  String get summaryIceRegular => 'Regular ice';

  @override
  String get summaryIceExtra => 'Extra ice';

  @override
  String get summaryNoToppings => 'No toppings';

  @override
  String summaryToppingCount(int count) {
    return '$count toppings';
  }

  @override
  String get drinkNotFound => 'We couldn\'t find that drink.';

  @override
  String get cartTitle => 'Your cart';

  @override
  String get cartEmptyTitle => 'Your cart is empty';

  @override
  String get cartEmptyBody => 'Build a cup you like and it will show up here.';

  @override
  String get browseMenu => 'Browse the menu';

  @override
  String removedItem(String name) {
    return 'Removed $name';
  }

  @override
  String get pickupTime => 'Pickup time';

  @override
  String get pickupAsap => 'ASAP · ~15 min';

  @override
  String pickupIn(int minutes) {
    return 'In $minutes min';
  }

  @override
  String get useFreeCup => 'Use a free cup';

  @override
  String freeCupsLeft(int count) {
    String _temp0 = intl.Intl.pluralLogic(count, locale: localeName, other: '$count free cups available', one: '1 free cup available');
    return '$_temp0';
  }

  @override
  String get subtotal => 'Drinks';

  @override
  String get discount => 'Free cup';

  @override
  String get total => 'Total';

  @override
  String get goToCheckout => 'Checkout';

  @override
  String get decreaseQuantity => 'Decrease quantity';

  @override
  String get increaseQuantity => 'Increase quantity';

  @override
  String quantity(int count) {
    return 'Quantity $count';
  }

  @override
  String get checkoutTitle => 'Checkout';

  @override
  String get orderSummary => 'Order summary';

  @override
  String get paymentMethod => 'Payment method';

  @override
  String get payPromptPay => 'PromptPay QR';

  @override
  String get payPromptPayHint => 'Scan with any banking app';

  @override
  String get payCard => 'Card';

  @override
  String get payCardHint => 'Visa •••• 4242 (sample)';

  @override
  String get payCash => 'Pay at the store';

  @override
  String get payCashHint => 'Pay when you pick up';

  @override
  String pickupAt(String store) {
    return 'Pickup at $store';
  }

  @override
  String payAmount(String amount) {
    return 'Pay $amount';
  }

  @override
  String get placeOrder => 'Place order';

  @override
  String get qrTitle => 'Scan to pay';

  @override
  String get qrSample => 'Sample QR. It can\'t receive real payments.';

  @override
  String qrExpires(String time) {
    return 'Expires in $time';
  }

  @override
  String get qrSimulate => 'Simulate a successful payment';

  @override
  String get processingPayment => 'Confirming your payment…';

  @override
  String get processingOrder => 'Sending your order to the store…';

  @override
  String get successTitle => 'Payment complete!';

  @override
  String get successTitleCash => 'Order placed!';

  @override
  String orderNumber(String number) {
    return 'Order $number';
  }

  @override
  String get pickupCode => 'Pickup code';

  @override
  String stampsEarned(int count) {
    String _temp0 = intl.Intl.pluralLogic(count, locale: localeName, other: '+$count stamps', one: '+1 stamp');
    return '$_temp0';
  }

  @override
  String get trackOrder => 'Track order';

  @override
  String readyAround(String time) {
    return 'Ready around $time';
  }

  @override
  String get statusReceived => 'Order received';

  @override
  String get statusReceivedBody => 'The store has your order.';

  @override
  String get statusBrewing => 'Brewing your drinks';

  @override
  String get statusBrewingBody => 'Your cups are being made right now.';

  @override
  String get statusReady => 'Ready for pickup';

  @override
  String get statusReadyBody => 'Show your pickup code at the counter.';

  @override
  String get statusCompleted => 'Picked up';

  @override
  String get statusCompletedBody => 'Enjoy! Thanks for ordering with us.';

  @override
  String get pickedUp => 'I picked it up';

  @override
  String get demoNextStep => 'Demo: next step';

  @override
  String get orderNotFound => 'We couldn\'t find that order.';

  @override
  String get orderAgain => 'Order again';

  @override
  String get items => 'Items';

  @override
  String get store => 'Store';

  @override
  String get storeAddress => 'Soi Ari 1, Phaya Thai, Bangkok';

  @override
  String get ordersTitle => 'Orders';

  @override
  String get activeOrder => 'In progress';

  @override
  String get pastOrders => 'Past orders';

  @override
  String get noOrders => 'No orders yet';

  @override
  String get today => 'Today';

  @override
  String get yesterday => 'Yesterday';

  @override
  String daysAgo(int count) {
    return '$count days ago';
  }

  @override
  String get rewardsTitle => 'Stamp card';

  @override
  String stampsToGo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count more cups for a free drink',
      one: '1 more cup for a free drink',
    );
    return '$_temp0';
  }

  @override
  String get cardComplete => 'Card complete! A free cup is yours.';

  @override
  String get freeCups => 'Free cups';

  @override
  String get freeCupTicket => '1 free cup · any drink';

  @override
  String get freeCupHint => 'Turn it on in your cart before checkout.';

  @override
  String get noFreeCups => 'No free cups yet. Keep collecting!';

  @override
  String get howItWorks => 'How it works';

  @override
  String get how1 => 'Every cup you order earns 1 stamp.';

  @override
  String get how2 => 'Collect 10 stamps to fill a card.';

  @override
  String get how3 => 'Each full card gives you a free cup.';

  @override
  String get guest => 'Guest';

  @override
  String get member => 'Boba Lab member';

  @override
  String get settings => 'Settings';

  @override
  String get language => 'Language';

  @override
  String get reduceMotion => 'Reduce motion';

  @override
  String get reduceMotionHint => 'Turns off bounces and decorative animation.';

  @override
  String get replayOnboarding => 'Show the intro again';

  @override
  String get resetDemo => 'Reset demo data';

  @override
  String get resetDone => 'Demo data is back to the start';

  @override
  String get aboutTitle => 'About this project';

  @override
  String get aboutBody => 'A frontend portfolio piece. Every drink, price and order here is sample data, and nothing is charged.';

  @override
  String get builtWith => 'Built with';

  @override
  String get designedWith => 'Designed with';

  @override
  String version(String version) {
    return 'Version $version';
  }

  @override
  String get frameBody => 'A bubble tea ordering app built with Flutter. Try it in the phone. Every order is sample data.';

  @override
  String get frameHint => 'Tap around in the phone';
}
