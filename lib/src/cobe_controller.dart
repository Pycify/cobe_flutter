import 'package:flutter/foundation.dart';

import 'cobe_models.dart';

class CobeController extends ChangeNotifier {
  CobeController(this._options);

  CobeOptions _options;

  CobeOptions get options => _options;

  void update(CobeOptionsPatch patch) {
    _options = _options.merge(patch);
    notifyListeners();
  }

  void replace(CobeOptions next) {
    _options = next;
    notifyListeners();
  }
}
