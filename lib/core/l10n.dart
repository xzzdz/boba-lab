import 'package:flutter/widgets.dart';

import '../data/catalog.dart';
import '../data/models.dart';
import '../l10n/app_localizations.dart';

extension L10nContext on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
  Locale get locale => Localizations.localeOf(this);
  String tr(LText text) => text.of(locale);
}

extension CupText on AppLocalizations {
  String iceOption(IceLevel ice) => switch (ice) {
    IceLevel.none => iceNone,
    IceLevel.less => iceLess,
    IceLevel.regular => iceRegular,
    IceLevel.extra => iceExtra,
  };

  String iceSummary(IceLevel ice) => switch (ice) {
    IceLevel.none => summaryNoIce,
    IceLevel.less => summaryIceLess,
    IceLevel.regular => summaryIceRegular,
    IceLevel.extra => summaryIceExtra,
  };

  String sizeOption(CupSize size) => size == CupSize.medium ? sizeMedium : sizeLarge;

  /// "หวาน 50% · น้ำแข็งปกติ · ไข่มุก"
  String cupSummary(CupConfig config, Locale locale) {
    final toppings = config.orderedToppings;
    final toppingText = switch (toppings.length) {
      0 => summaryNoToppings,
      1 => Catalog.topping(toppings.first).name.of(locale),
      _ => summaryToppingCount(toppings.length),
    };
    return [summarySweet(config.sweetness), iceSummary(config.ice), toppingText].join(' · ');
  }

  /// Size first, then the full summary, for cart and order rows.
  String cupDetails(CupConfig config, Locale locale) {
    final size = config.size == CupSize.medium ? 'M' : 'L';
    final toppings = config.orderedToppings.map((id) => Catalog.topping(id).name.of(locale));
    return [size, summarySweet(config.sweetness), iceSummary(config.ice), ...toppings].join(' · ');
  }

  String tagLabel(MenuTag tag) => switch (tag) {
    MenuTag.bestseller => tagBestseller,
    MenuTag.isNew => tagNew,
    MenuTag.signature => tagSignature,
  };

  String statusTitle(OrderStatus status) => switch (status) {
    OrderStatus.received => statusReceived,
    OrderStatus.brewing => statusBrewing,
    OrderStatus.ready => statusReady,
    OrderStatus.completed => statusCompleted,
  };

  String statusBody(OrderStatus status) => switch (status) {
    OrderStatus.received => statusReceivedBody,
    OrderStatus.brewing => statusBrewingBody,
    OrderStatus.ready => statusReadyBody,
    OrderStatus.completed => statusCompletedBody,
  };
}
