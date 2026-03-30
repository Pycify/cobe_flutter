import 'package:flutter/foundation.dart';

import 'cobe_models.dart';

/// Controls the current [CobeOptions] used by a [CobeGlobe].
class CobeController extends ChangeNotifier {
  /// Creates a controller with an initial set of globe [options].
  CobeController(this._options);

  CobeOptions _options;

  /// The current immutable options snapshot used by the globe.
  CobeOptions get options => _options;

  /// Merges a partial [patch] into the current options and notifies listeners.
  void update(CobeOptionsPatch patch) {
    _options = _options.merge(patch);
    notifyListeners();
  }

  /// Replaces the current options object and notifies listeners.
  void replace(CobeOptions next) {
    _options = next;
    notifyListeners();
  }
}
