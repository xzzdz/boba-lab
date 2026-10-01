import 'package:flutter/widgets.dart';

class SettingsController extends ChangeNotifier {
  SettingsController({this._locale = const Locale('th'), this._reduceMotion = false, this._onboardingDone = false});

  Locale _locale;
  bool _reduceMotion;
  bool _onboardingDone;

  Locale get locale => _locale;
  bool get reduceMotion => _reduceMotion;
  bool get onboardingDone => _onboardingDone;
  bool get isThai => _locale.languageCode == 'th';

  void setLocale(Locale locale) {
    if (locale == _locale) return;
    _locale = locale;
    notifyListeners();
  }

  void setReduceMotion(bool value) {
    if (value == _reduceMotion) return;
    _reduceMotion = value;
    notifyListeners();
  }

  void completeOnboarding() {
    if (_onboardingDone) return;
    _onboardingDone = true;
    notifyListeners();
  }

  void replayOnboarding() {
    _onboardingDone = false;
    notifyListeners();
  }
}
