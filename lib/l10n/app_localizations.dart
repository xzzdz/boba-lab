import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_th.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[Locale('en'), Locale('th')];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Boba Lab'**
  String get appTitle;

  /// No description provided for @tagline.
  ///
  /// In en, this message translates to:
  /// **'Bubble tea you design yourself'**
  String get tagline;

  /// No description provided for @skip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @getStarted.
  ///
  /// In en, this message translates to:
  /// **'Start ordering'**
  String get getStarted;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @undo.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get undo;

  /// No description provided for @pageNotFound.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t find that page.'**
  String get pageNotFound;

  /// No description provided for @backToMenu.
  ///
  /// In en, this message translates to:
  /// **'Back to menu'**
  String get backToMenu;

  /// No description provided for @languageThai.
  ///
  /// In en, this message translates to:
  /// **'ไทย'**
  String get languageThai;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @onboard1Title.
  ///
  /// In en, this message translates to:
  /// **'Build your cup, your way'**
  String get onboard1Title;

  /// No description provided for @onboard1Body.
  ///
  /// In en, this message translates to:
  /// **'Pick the base, sweetness, ice and toppings, and watch your cup change as you go.'**
  String get onboard1Body;

  /// No description provided for @onboard2Title.
  ///
  /// In en, this message translates to:
  /// **'Order ahead, skip the line'**
  String get onboard2Title;

  /// No description provided for @onboard2Body.
  ///
  /// In en, this message translates to:
  /// **'Pay in the app and pick up when it\'s ready. You\'ll see every step.'**
  String get onboard2Body;

  /// No description provided for @onboard3Title.
  ///
  /// In en, this message translates to:
  /// **'Every 10th cup is on us'**
  String get onboard3Title;

  /// No description provided for @onboard3Body.
  ///
  /// In en, this message translates to:
  /// **'Each cup earns a stamp. Fill the card and your next cup is free.'**
  String get onboard3Body;

  /// No description provided for @demoNotice.
  ///
  /// In en, this message translates to:
  /// **'Demo app. All drinks, prices and orders are sample data.'**
  String get demoNotice;

  /// No description provided for @navMenu.
  ///
  /// In en, this message translates to:
  /// **'Menu'**
  String get navMenu;

  /// No description provided for @navOrders.
  ///
  /// In en, this message translates to:
  /// **'Orders'**
  String get navOrders;

  /// No description provided for @navRewards.
  ///
  /// In en, this message translates to:
  /// **'Stamps'**
  String get navRewards;

  /// No description provided for @navProfile.
  ///
  /// In en, this message translates to:
  /// **'Me'**
  String get navProfile;

  /// No description provided for @greetingMorning.
  ///
  /// In en, this message translates to:
  /// **'Good morning'**
  String get greetingMorning;

  /// No description provided for @greetingAfternoon.
  ///
  /// In en, this message translates to:
  /// **'Good afternoon'**
  String get greetingAfternoon;

  /// No description provided for @greetingEvening.
  ///
  /// In en, this message translates to:
  /// **'Good evening'**
  String get greetingEvening;

  /// No description provided for @menuHeadline.
  ///
  /// In en, this message translates to:
  /// **'What are we sipping today?'**
  String get menuHeadline;

  /// No description provided for @storeName.
  ///
  /// In en, this message translates to:
  /// **'Boba Lab Ari'**
  String get storeName;

  /// No description provided for @storeDistance.
  ///
  /// In en, this message translates to:
  /// **'Pickup · 450 m'**
  String get storeDistance;

  /// No description provided for @promoTitle.
  ///
  /// In en, this message translates to:
  /// **'10 stamps = 1 free cup'**
  String get promoTitle;

  /// No description provided for @promoProgress.
  ///
  /// In en, this message translates to:
  /// **'{count} of 10 stamps'**
  String promoProgress(int count);

  /// No description provided for @promoCta.
  ///
  /// In en, this message translates to:
  /// **'See my card'**
  String get promoCta;

  /// No description provided for @menuSection.
  ///
  /// In en, this message translates to:
  /// **'Our menu'**
  String get menuSection;

  /// No description provided for @filterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get filterAll;

  /// No description provided for @filterTea.
  ///
  /// In en, this message translates to:
  /// **'Tea'**
  String get filterTea;

  /// No description provided for @filterMilk.
  ///
  /// In en, this message translates to:
  /// **'Fresh milk'**
  String get filterMilk;

  /// No description provided for @filterFoam.
  ///
  /// In en, this message translates to:
  /// **'Cheese foam'**
  String get filterFoam;

  /// No description provided for @tagBestseller.
  ///
  /// In en, this message translates to:
  /// **'Bestseller'**
  String get tagBestseller;

  /// No description provided for @tagNew.
  ///
  /// In en, this message translates to:
  /// **'New'**
  String get tagNew;

  /// No description provided for @tagSignature.
  ///
  /// In en, this message translates to:
  /// **'Signature'**
  String get tagSignature;

  /// No description provided for @quickAdd.
  ///
  /// In en, this message translates to:
  /// **'Add {name} to cart'**
  String quickAdd(String name);

  /// No description provided for @addedToCart.
  ///
  /// In en, this message translates to:
  /// **'Added to cart'**
  String get addedToCart;

  /// No description provided for @addedNamed.
  ///
  /// In en, this message translates to:
  /// **'{name} is in your cart'**
  String addedNamed(String name);

  /// No description provided for @viewCart.
  ///
  /// In en, this message translates to:
  /// **'View cart'**
  String get viewCart;

  /// No description provided for @cupCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 cup} other{{count} cups}}'**
  String cupCount(int count);

  /// No description provided for @builderTitle.
  ///
  /// In en, this message translates to:
  /// **'Build your cup'**
  String get builderTitle;

  /// No description provided for @base.
  ///
  /// In en, this message translates to:
  /// **'Base'**
  String get base;

  /// No description provided for @size.
  ///
  /// In en, this message translates to:
  /// **'Size'**
  String get size;

  /// No description provided for @sizeMedium.
  ///
  /// In en, this message translates to:
  /// **'M · 16 oz'**
  String get sizeMedium;

  /// No description provided for @sizeLarge.
  ///
  /// In en, this message translates to:
  /// **'L · 22 oz'**
  String get sizeLarge;

  /// No description provided for @sweetness.
  ///
  /// In en, this message translates to:
  /// **'Sweetness'**
  String get sweetness;

  /// No description provided for @ice.
  ///
  /// In en, this message translates to:
  /// **'Ice'**
  String get ice;

  /// No description provided for @iceNone.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get iceNone;

  /// No description provided for @iceLess.
  ///
  /// In en, this message translates to:
  /// **'Less'**
  String get iceLess;

  /// No description provided for @iceRegular.
  ///
  /// In en, this message translates to:
  /// **'Regular'**
  String get iceRegular;

  /// No description provided for @iceExtra.
  ///
  /// In en, this message translates to:
  /// **'Extra'**
  String get iceExtra;

  /// No description provided for @toppings.
  ///
  /// In en, this message translates to:
  /// **'Toppings'**
  String get toppings;

  /// No description provided for @addToCart.
  ///
  /// In en, this message translates to:
  /// **'Add to cart'**
  String get addToCart;

  /// No description provided for @summarySweet.
  ///
  /// In en, this message translates to:
  /// **'{percent}% sweet'**
  String summarySweet(int percent);

  /// No description provided for @summaryNoIce.
  ///
  /// In en, this message translates to:
  /// **'No ice'**
  String get summaryNoIce;

  /// No description provided for @summaryIceLess.
  ///
  /// In en, this message translates to:
  /// **'Less ice'**
  String get summaryIceLess;

  /// No description provided for @summaryIceRegular.
  ///
  /// In en, this message translates to:
  /// **'Regular ice'**
  String get summaryIceRegular;

  /// No description provided for @summaryIceExtra.
  ///
  /// In en, this message translates to:
  /// **'Extra ice'**
  String get summaryIceExtra;

  /// No description provided for @summaryNoToppings.
  ///
  /// In en, this message translates to:
  /// **'No toppings'**
  String get summaryNoToppings;

  /// No description provided for @summaryToppingCount.
  ///
  /// In en, this message translates to:
  /// **'{count} toppings'**
  String summaryToppingCount(int count);

  /// No description provided for @drinkNotFound.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t find that drink.'**
  String get drinkNotFound;

  /// No description provided for @cartTitle.
  ///
  /// In en, this message translates to:
  /// **'Your cart'**
  String get cartTitle;

  /// No description provided for @cartEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'Your cart is empty'**
  String get cartEmptyTitle;

  /// No description provided for @cartEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Build a cup you like and it will show up here.'**
  String get cartEmptyBody;

  /// No description provided for @browseMenu.
  ///
  /// In en, this message translates to:
  /// **'Browse the menu'**
  String get browseMenu;

  /// No description provided for @removedItem.
  ///
  /// In en, this message translates to:
  /// **'Removed {name}'**
  String removedItem(String name);

  /// No description provided for @pickupTime.
  ///
  /// In en, this message translates to:
  /// **'Pickup time'**
  String get pickupTime;

  /// No description provided for @pickupAsap.
  ///
  /// In en, this message translates to:
  /// **'ASAP · ~15 min'**
  String get pickupAsap;

  /// No description provided for @pickupIn.
  ///
  /// In en, this message translates to:
  /// **'In {minutes} min'**
  String pickupIn(int minutes);

  /// No description provided for @useFreeCup.
  ///
  /// In en, this message translates to:
  /// **'Use a free cup'**
  String get useFreeCup;

  /// No description provided for @freeCupsLeft.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 free cup available} other{{count} free cups available}}'**
  String freeCupsLeft(int count);

  /// No description provided for @subtotal.
  ///
  /// In en, this message translates to:
  /// **'Drinks'**
  String get subtotal;

  /// No description provided for @discount.
  ///
  /// In en, this message translates to:
  /// **'Free cup'**
  String get discount;

  /// No description provided for @total.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get total;

  /// No description provided for @goToCheckout.
  ///
  /// In en, this message translates to:
  /// **'Checkout'**
  String get goToCheckout;

  /// No description provided for @decreaseQuantity.
  ///
  /// In en, this message translates to:
  /// **'Decrease quantity'**
  String get decreaseQuantity;

  /// No description provided for @increaseQuantity.
  ///
  /// In en, this message translates to:
  /// **'Increase quantity'**
  String get increaseQuantity;

  /// No description provided for @quantity.
  ///
  /// In en, this message translates to:
  /// **'Quantity {count}'**
  String quantity(int count);

  /// No description provided for @checkoutTitle.
  ///
  /// In en, this message translates to:
  /// **'Checkout'**
  String get checkoutTitle;

  /// No description provided for @orderSummary.
  ///
  /// In en, this message translates to:
  /// **'Order summary'**
  String get orderSummary;

  /// No description provided for @paymentMethod.
  ///
  /// In en, this message translates to:
  /// **'Payment method'**
  String get paymentMethod;

  /// No description provided for @payPromptPay.
  ///
  /// In en, this message translates to:
  /// **'PromptPay QR'**
  String get payPromptPay;

  /// No description provided for @payPromptPayHint.
  ///
  /// In en, this message translates to:
  /// **'Scan with any banking app'**
  String get payPromptPayHint;

  /// No description provided for @payCard.
  ///
  /// In en, this message translates to:
  /// **'Card'**
  String get payCard;

  /// No description provided for @payCardHint.
  ///
  /// In en, this message translates to:
  /// **'Visa •••• 4242 (sample)'**
  String get payCardHint;

  /// No description provided for @payCash.
  ///
  /// In en, this message translates to:
  /// **'Pay at the store'**
  String get payCash;

  /// No description provided for @payCashHint.
  ///
  /// In en, this message translates to:
  /// **'Pay when you pick up'**
  String get payCashHint;

  /// No description provided for @pickupAt.
  ///
  /// In en, this message translates to:
  /// **'Pickup at {store}'**
  String pickupAt(String store);

  /// No description provided for @payAmount.
  ///
  /// In en, this message translates to:
  /// **'Pay {amount}'**
  String payAmount(String amount);

  /// No description provided for @placeOrder.
  ///
  /// In en, this message translates to:
  /// **'Place order'**
  String get placeOrder;

  /// No description provided for @qrTitle.
  ///
  /// In en, this message translates to:
  /// **'Scan to pay'**
  String get qrTitle;

  /// No description provided for @qrSample.
  ///
  /// In en, this message translates to:
  /// **'Sample QR. It can\'t receive real payments.'**
  String get qrSample;

  /// No description provided for @qrExpires.
  ///
  /// In en, this message translates to:
  /// **'Expires in {time}'**
  String qrExpires(String time);

  /// No description provided for @qrSimulate.
  ///
  /// In en, this message translates to:
  /// **'Simulate a successful payment'**
  String get qrSimulate;

  /// No description provided for @processingPayment.
  ///
  /// In en, this message translates to:
  /// **'Confirming your payment…'**
  String get processingPayment;

  /// No description provided for @processingOrder.
  ///
  /// In en, this message translates to:
  /// **'Sending your order to the store…'**
  String get processingOrder;

  /// No description provided for @successTitle.
  ///
  /// In en, this message translates to:
  /// **'Payment complete!'**
  String get successTitle;

  /// No description provided for @successTitleCash.
  ///
  /// In en, this message translates to:
  /// **'Order placed!'**
  String get successTitleCash;

  /// No description provided for @orderNumber.
  ///
  /// In en, this message translates to:
  /// **'Order {number}'**
  String orderNumber(String number);

  /// No description provided for @pickupCode.
  ///
  /// In en, this message translates to:
  /// **'Pickup code'**
  String get pickupCode;

  /// No description provided for @stampsEarned.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{+1 stamp} other{+{count} stamps}}'**
  String stampsEarned(int count);

  /// No description provided for @trackOrder.
  ///
  /// In en, this message translates to:
  /// **'Track order'**
  String get trackOrder;

  /// No description provided for @readyAround.
  ///
  /// In en, this message translates to:
  /// **'Ready around {time}'**
  String readyAround(String time);

  /// No description provided for @statusReceived.
  ///
  /// In en, this message translates to:
  /// **'Order received'**
  String get statusReceived;

  /// No description provided for @statusReceivedBody.
  ///
  /// In en, this message translates to:
  /// **'The store has your order.'**
  String get statusReceivedBody;

  /// No description provided for @statusBrewing.
  ///
  /// In en, this message translates to:
  /// **'Brewing your drinks'**
  String get statusBrewing;

  /// No description provided for @statusBrewingBody.
  ///
  /// In en, this message translates to:
  /// **'Your cups are being made right now.'**
  String get statusBrewingBody;

  /// No description provided for @statusReady.
  ///
  /// In en, this message translates to:
  /// **'Ready for pickup'**
  String get statusReady;

  /// No description provided for @statusReadyBody.
  ///
  /// In en, this message translates to:
  /// **'Show your pickup code at the counter.'**
  String get statusReadyBody;

  /// No description provided for @statusCompleted.
  ///
  /// In en, this message translates to:
  /// **'Picked up'**
  String get statusCompleted;

  /// No description provided for @statusCompletedBody.
  ///
  /// In en, this message translates to:
  /// **'Enjoy! Thanks for ordering with us.'**
  String get statusCompletedBody;

  /// No description provided for @pickedUp.
  ///
  /// In en, this message translates to:
  /// **'I picked it up'**
  String get pickedUp;

  /// No description provided for @demoNextStep.
  ///
  /// In en, this message translates to:
  /// **'Demo: next step'**
  String get demoNextStep;

  /// No description provided for @orderNotFound.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t find that order.'**
  String get orderNotFound;

  /// No description provided for @orderAgain.
  ///
  /// In en, this message translates to:
  /// **'Order again'**
  String get orderAgain;

  /// No description provided for @items.
  ///
  /// In en, this message translates to:
  /// **'Items'**
  String get items;

  /// No description provided for @store.
  ///
  /// In en, this message translates to:
  /// **'Store'**
  String get store;

  /// No description provided for @storeAddress.
  ///
  /// In en, this message translates to:
  /// **'Soi Ari 1, Phaya Thai, Bangkok'**
  String get storeAddress;

  /// No description provided for @ordersTitle.
  ///
  /// In en, this message translates to:
  /// **'Orders'**
  String get ordersTitle;

  /// No description provided for @activeOrder.
  ///
  /// In en, this message translates to:
  /// **'In progress'**
  String get activeOrder;

  /// No description provided for @pastOrders.
  ///
  /// In en, this message translates to:
  /// **'Past orders'**
  String get pastOrders;

  /// No description provided for @noOrders.
  ///
  /// In en, this message translates to:
  /// **'No orders yet'**
  String get noOrders;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @yesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get yesterday;

  /// No description provided for @daysAgo.
  ///
  /// In en, this message translates to:
  /// **'{count} days ago'**
  String daysAgo(int count);

  /// No description provided for @rewardsTitle.
  ///
  /// In en, this message translates to:
  /// **'Stamp card'**
  String get rewardsTitle;

  /// No description provided for @stampsToGo.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 more cup for a free drink} other{{count} more cups for a free drink}}'**
  String stampsToGo(int count);

  /// No description provided for @cardComplete.
  ///
  /// In en, this message translates to:
  /// **'Card complete! A free cup is yours.'**
  String get cardComplete;

  /// No description provided for @freeCups.
  ///
  /// In en, this message translates to:
  /// **'Free cups'**
  String get freeCups;

  /// No description provided for @freeCupTicket.
  ///
  /// In en, this message translates to:
  /// **'1 free cup · any drink'**
  String get freeCupTicket;

  /// No description provided for @freeCupHint.
  ///
  /// In en, this message translates to:
  /// **'Turn it on in your cart before checkout.'**
  String get freeCupHint;

  /// No description provided for @noFreeCups.
  ///
  /// In en, this message translates to:
  /// **'No free cups yet. Keep collecting!'**
  String get noFreeCups;

  /// No description provided for @howItWorks.
  ///
  /// In en, this message translates to:
  /// **'How it works'**
  String get howItWorks;

  /// No description provided for @how1.
  ///
  /// In en, this message translates to:
  /// **'Every cup you order earns 1 stamp.'**
  String get how1;

  /// No description provided for @how2.
  ///
  /// In en, this message translates to:
  /// **'Collect 10 stamps to fill a card.'**
  String get how2;

  /// No description provided for @how3.
  ///
  /// In en, this message translates to:
  /// **'Each full card gives you a free cup.'**
  String get how3;

  /// No description provided for @guest.
  ///
  /// In en, this message translates to:
  /// **'Guest'**
  String get guest;

  /// No description provided for @member.
  ///
  /// In en, this message translates to:
  /// **'Boba Lab member'**
  String get member;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @reduceMotion.
  ///
  /// In en, this message translates to:
  /// **'Reduce motion'**
  String get reduceMotion;

  /// No description provided for @reduceMotionHint.
  ///
  /// In en, this message translates to:
  /// **'Turns off bounces and decorative animation.'**
  String get reduceMotionHint;

  /// No description provided for @replayOnboarding.
  ///
  /// In en, this message translates to:
  /// **'Show the intro again'**
  String get replayOnboarding;

  /// No description provided for @resetDemo.
  ///
  /// In en, this message translates to:
  /// **'Reset demo data'**
  String get resetDemo;

  /// No description provided for @resetDone.
  ///
  /// In en, this message translates to:
  /// **'Demo data is back to the start'**
  String get resetDone;

  /// No description provided for @aboutTitle.
  ///
  /// In en, this message translates to:
  /// **'About this project'**
  String get aboutTitle;

  /// No description provided for @aboutBody.
  ///
  /// In en, this message translates to:
  /// **'A frontend portfolio piece. Every drink, price and order here is sample data, and nothing is charged.'**
  String get aboutBody;

  /// No description provided for @builtWith.
  ///
  /// In en, this message translates to:
  /// **'Built with'**
  String get builtWith;

  /// No description provided for @designedWith.
  ///
  /// In en, this message translates to:
  /// **'Designed with'**
  String get designedWith;

  /// No description provided for @version.
  ///
  /// In en, this message translates to:
  /// **'Version {version}'**
  String version(String version);

  /// No description provided for @frameBody.
  ///
  /// In en, this message translates to:
  /// **'A bubble tea ordering app built with Flutter. Try it in the phone. Every order is sample data.'**
  String get frameBody;

  /// No description provided for @frameHint.
  ///
  /// In en, this message translates to:
  /// **'Tap around in the phone'**
  String get frameHint;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'th'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'th':
      return AppLocalizationsTh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
