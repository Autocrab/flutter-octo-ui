import 'package:flutter/foundation.dart';

/// Drives the open / closed state of an [OctoMenu].
///
/// Hold one instance per menu in your `State`, dispose it in `dispose()`,
/// and wire trigger gestures (button tap, keyboard shortcut) to
/// [open] / [close] / [toggle]. The menu listens via `addListener` and
/// shows or hides its overlay accordingly.
class OctoMenuController extends ChangeNotifier {
  bool _isOpen = false;

  /// `true` while the menu overlay is shown.
  bool get isOpen => _isOpen;

  /// Shows the menu. No-op if already open.
  void open() {
    if (_isOpen) return;
    _isOpen = true;
    notifyListeners();
  }

  /// Hides the menu. No-op if already closed.
  void close() {
    if (!_isOpen) return;
    _isOpen = false;
    notifyListeners();
  }

  /// Flips the open state.
  void toggle() => _isOpen ? close() : open();
}
