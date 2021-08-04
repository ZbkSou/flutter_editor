
import 'dart:math' as math;
import 'dart:ui' as ui show TextBox, lerpDouble, BoxHeightStyle, BoxWidthStyle;
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';

import 'extend_text_selection_render_object.dart';
import 'extend_text_utils.dart';
///
///  extended_render_editable
///  @author: DreamilyAI
///  @description:
///  Created by zhao on .
const double _kCaretGap = 1.0; // pixels
///
///Make Ios/Android caret the same height
///https://github.com/fluttercandies/extended_text_field/issues/14
///https://github.com/fluttercandies/extended_text_field/issues/19
///https://github.com/fluttercandies/extended_text_field/issues/10
//const double _kCaretHeightOffset = 2.0; // pixels
const double _kCaretHeightOffset = 0.0; // pixels

// The additional size on the x and y axis with which to expand the prototype
// cursor to render the floating cursor in pixels.
const Offset _kFloatingCaretSizeIncrease = Offset(0.5, 1.0);

// The corner radius of the floating cursor in pixels.
const double _kFloatingCaretRadius = 1.0;

/// Displays some text in a scrollable container with a potentially blinking
/// cursor and with gesture recognizers.
///
/// This is the renderer for an editable text field. It does not directly
/// provide affordances for editing the text, but it does handle text selection
/// and manipulation of the text cursor.
///
/// The [text] is displayed, scrolled by the given [offset], aligned according
/// to [textAlign]. The [maxLines] property controls whether the text displays
/// on one line or many. The [selection], if it is not collapsed, is painted in
/// the [selectionColor]. If it _is_ collapsed, then it represents the cursor
/// position. The cursor is shown while [showCursor] is true. It is painted in
/// the [cursorColor].
///
/// If, when the render object paints, the caret is found to have changed
/// location, [onCaretChanged] is called.
///
/// The user may interact with the render object by tapping or long-pressing.
/// When the user does so, the selection is updated, and [onSelectionChanged] is
/// called.
///
/// Keyboard handling, IME handling, scrolling, toggling the [showCursor] value
/// to actually blink the cursor, and other features not mentioned above are the
/// responsibility of higher layers and not handled by this object.
class ExtendRenderEditable extends ExtendTextSelectionRenderObject {
  /// Creates a render object that implements the visual aspects of a text field.
  ///
  /// The [textAlign] argument must not be null. It defaults to [TextAlign.start].
  ///
  /// The [textDirection] argument must not be null.
  ///
  /// If [showCursor] is not specified, then it defaults to hiding the cursor.
  ///
  /// The [maxLines] property can be set to null to remove the restriction on
  /// the number of lines. By default, it is 1, meaning this is a single-line
  /// text field. If it is not null, it must be greater than zero.
  ///
  /// The [offset] is required and must not be null. You can use [new
  /// ViewportOffset.zero] if you have no need for scrolling.
  ExtendRenderEditable({
    required InlineSpan text,
    required TextDirection textDirection,
    TextAlign textAlign = TextAlign.start,
    Color? cursorColor,
    Color? backgroundCursorColor,
    ValueNotifier<bool>? showCursor,
    bool? hasFocus,
    required LayerLink startHandleLayerLink,
    required LayerLink endHandleLayerLink,
    int? maxLines = 1,
    int? minLines,
    bool expands = false,
    StrutStyle? strutStyle,
    Color? selectionColor,
    double textScaleFactor = 1.0,
    TextSelection? selection,
    required ViewportOffset offset,
    this.onSelectionChanged,
    this.onCaretChanged,
    this.ignorePointer = false,
    bool readOnly = false,
    bool forceLine = true,
    TextHeightBehavior? textHeightBehavior,
    TextWidthBasis textWidthBasis = TextWidthBasis.parent,
    String? obscuringCharacter = '•',
    bool obscureText = false,
    Locale? locale,
    double? cursorWidth = 1.0,
    double? cursorHeight,
    Radius? cursorRadius,
    bool paintCursorAboveText = false,
    Offset? cursorOffset,
    double devicePixelRatio = 1.0,
    ui.BoxHeightStyle selectionHeightStyle = ui.BoxHeightStyle.tight,
    ui.BoxWidthStyle selectionWidthStyle = ui.BoxWidthStyle.tight,
    bool? enableInteractiveSelection,
    EdgeInsets floatingCursorAddedMargin =
    const EdgeInsets.fromLTRB(4, 4, 4, 5),
    TextRange? promptRectRange,
    Color? promptRectColor,
    Clip clipBehavior = Clip.hardEdge,
    required this.textSelectionDelegate,
    this.supportSpecialText = false,
    List<RenderBox>? children,
  })  : assert(maxLines == null || maxLines > 0),
        assert(minLines == null || minLines > 0),
        assert(
        (maxLines == null) || (minLines == null) || (maxLines >= minLines),
        "minLines can't be greater than maxLines",
        ),
        assert(
        !expands || (maxLines == null && minLines == null),
        'minLines and maxLines must be null when expands is true.',
        ),
        assert(obscuringCharacter != null &&
            obscuringCharacter.characters.length == 1),
        assert(cursorWidth != null && cursorWidth >= 0.0),
        assert(cursorHeight == null || cursorHeight >= 0.0),
        _textPainter = TextPainter(
          text: text,
          textAlign: textAlign,
          textDirection: textDirection,
          textScaleFactor: textScaleFactor,
          locale: locale,
          strutStyle: strutStyle,
          textHeightBehavior: textHeightBehavior,
          textWidthBasis: textWidthBasis,
//              supportSpecialText && hasSpecialText(text) ? null : strutStyle,
        ),
        _cursorColor = cursorColor,
        _backgroundCursorColor = backgroundCursorColor,
        _showCursor = showCursor ?? ValueNotifier<bool>(false),
        _maxLines = maxLines,
        _minLines = minLines,
        _expands = expands,
        _selectionColor = selectionColor,
        _selection = selection,
        _offset = offset,
        _cursorWidth = cursorWidth,
        _cursorHeight = cursorHeight,
        _cursorRadius = cursorRadius,
        _paintCursorOnTop = paintCursorAboveText,
        _cursorOffset = cursorOffset,
        _floatingCursorAddedMargin = floatingCursorAddedMargin,
        _enableInteractiveSelection = enableInteractiveSelection,
        _devicePixelRatio = devicePixelRatio,
        _selectionHeightStyle = selectionHeightStyle,
        _selectionWidthStyle = selectionWidthStyle,
        _startHandleLayerLink = startHandleLayerLink,
        _endHandleLayerLink = endHandleLayerLink,
        _obscuringCharacter = obscuringCharacter,
        _obscureText = obscureText,
        _readOnly = readOnly,
        _forceLine = forceLine,
        _promptRectRange = promptRectRange,
        _clipBehavior = clipBehavior {
    assert(!_showCursor.value || cursorColor != null);
    this.hasFocus = hasFocus ?? false;
    addAll(children);
    extractPlaceholderSpans(text);
    if (promptRectColor != null) {
      _promptRectPaint.color = promptRectColor;
    }
  }

  ///whether to support build SpecialText

  bool supportSpecialText = false;
  @override
  bool get hasSpecialInlineSpanBase =>
      supportSpecialText && super.hasSpecialInlineSpanBase;

  /// Called when the selection changes.
  ///
  /// If this is null, then selection changes will be ignored.
  @override
  TextSelectionChangedHandler? onSelectionChanged;

  /// Called during the paint phase when the caret location changes.
  CaretChangedHandler? onCaretChanged;

  /// If true [handleEvent] does nothing and it's assumed that this
  /// renderer will be notified of input gestures via [handleTapDown],
  /// [handleTap], [handleDoubleTap], and [handleLongPress].
  ///
  /// The default value of this property is false.
  @override
  bool ignorePointer;

  /// {@macro flutter.dart:ui.textHeightBehavior}
  TextHeightBehavior? get textHeightBehavior => _textPainter.textHeightBehavior;
  set textHeightBehavior(TextHeightBehavior? value) {
    if (_textPainter.textHeightBehavior == value) {
      return;
    }
    _textPainter.textHeightBehavior = value;
    markNeedsTextLayout();
  }

  /// {@macro flutter.widgets.text.DefaultTextStyle.textWidthBasis}
  TextWidthBasis get textWidthBasis => _textPainter.textWidthBasis;
  set textWidthBasis(TextWidthBasis value) {
    if (_textPainter.textWidthBasis == value) {
      return;
    }
    _textPainter.textWidthBasis = value;
    markNeedsTextLayout();
  }

  /// The pixel ratio of the current device.
  ///
  /// Should be obtained by querying MediaQuery for the devicePixelRatio.
  double? get devicePixelRatio => _devicePixelRatio;
  double? _devicePixelRatio;
  set devicePixelRatio(double? value) {
    if (devicePixelRatio == value) {
      return;
    }
    _devicePixelRatio = value;
    markNeedsTextLayout();
  }

  /// Character used for obscuring text if [obscureText] is true.
  ///
  /// Cannot be null, and must have a length of exactly one.
  String? get obscuringCharacter => _obscuringCharacter;
  String? _obscuringCharacter;
  set obscuringCharacter(String? value) {
    if (_obscuringCharacter == value) {
      return;
    }
    assert(value != null && value.characters.length == 1);
    _obscuringCharacter = value;
    markNeedsLayout();
  }

  /// Whether to hide the text being edited (e.g., for passwords).
  @override
  bool get obscureText => _obscureText!;
  bool? _obscureText;
  set obscureText(bool? value) {
    if (_obscureText == value) {
      return;
    }
    _obscureText = value;
    markNeedsSemanticsUpdate();
  }

  /// The object that controls the text selection, used by this render object
  /// for implementing cut, copy, and paste keyboard shortcuts.
  ///
  /// It must not be null. It will make cut, copy and paste functionality work
  /// with the most recently set [TextSelectionDelegate].
  @override
  TextSelectionDelegate textSelectionDelegate;

  Rect? _lastCaretRect;

  /// Track whether position of the start of the selected text is within the viewport.
  ///
  /// For example, if the text contains "Hello World", and the user selects
  /// "Hello", then scrolls so only "World" is visible, this will become false.
  /// If the user scrolls back so that the "H" is visible again, this will
  /// become true.
  ///
  /// This bool indicates whether the text is scrolled so that the handle is
  /// inside the text field viewport, as opposed to whether it is actually
  /// visible on the screen.
  @override
  ValueListenable<bool> get selectionStartInViewport =>
      _selectionStartInViewport;
  final ValueNotifier<bool> _selectionStartInViewport =
  ValueNotifier<bool>(true);

  /// Track whether position of the end of the selected text is within the viewport.
  ///
  /// For example, if the text contains "Hello World", and the user selects
  /// "World", then scrolls so only "Hello" is visible, this will become
  /// 'false'. If the user scrolls back so that the "d" is visible again, this
  /// will become 'true'.
  ///
  /// This bool indicates whether the text is scrolled so that the handle is
  /// inside the text field viewport, as opposed to whether it is actually
  /// visible on the screen.
  @override
  ValueListenable<bool> get selectionEndInViewport => _selectionEndInViewport;
  final ValueNotifier<bool> _selectionEndInViewport = ValueNotifier<bool>(true);

  void _updateSelectionExtentsVisibility(
      Offset effectiveOffset, TextSelection selection) {
    ///zmt
    ///caret may be less than 0, because it's bigger than text
    // ///
    // issue: #49
    // final Rect visibleRegion = Offset(0.0, _visibleRegionMinY) & size;
    final Rect visibleRegion = Offset.zero & size;

    //getCaretOffset ready has effectiveOffset
    final Offset startOffset = getCaretOffset(
      TextPosition(
        offset: selection.start,
        affinity: selection.affinity,
      ),
      effectiveOffset: effectiveOffset,
      caretPrototype: _caretPrototype,
    );

    // (justinmc): https://github.com/flutter/flutter/issues/31495
    // Check if the selection is visible with an approximation because a
    // difference between rounded and unrounded values causes the caret to be
    // reported as having a slightly (< 0.5) negative y offset. This rounding
    // happens in paragraph.cc's layout and TextPainer's
    // _applyFloatingPointHack. Ideally, the rounding mismatch will be fixed and
    // this can be changed to be a strict check instead of an approximation.
    const double visibleRegionSlop = 0.5;
    _selectionStartInViewport.value =
        visibleRegion.inflate(visibleRegionSlop).contains(startOffset);

    //getCaretOffset ready has effectiveOffset
    final Offset endOffset = getCaretOffset(
      TextPosition(offset: selection.end, affinity: selection.affinity),
      effectiveOffset: effectiveOffset,
      caretPrototype: _caretPrototype,
    );

    _selectionEndInViewport.value =
        visibleRegion.inflate(visibleRegionSlop).contains(endOffset);
  }

  ///some times _visibleRegionMinY will lower than 0.0;
  ///that the _selectionStartInViewport and _selectionEndInViewport will not right.
  ///
  //final double _visibleRegionMinY = -_kCaretHeightOffset;

//   ///zmt
//   void _updateVisibleRegionMinY() {
// //    if (textSelectionDelegate.textEditingValue == null ||
// //        textSelectionDelegate.textEditingValue.text == null ||
// //        textSelectionDelegate.textEditingValue.selection == null ||
// //        _textPainter.text == null) return;
// //    List<TextBox> boxs = _textPainter.getBoxesForSelection(
// //        textSelectionDelegate.textEditingValue.selection.copyWith(
// //            baseOffset: 0,
// //            extentOffset: _textPainter.text.toPlainText().length));
// //    boxs.forEach((f) {
// //      _visibleRegionMinY = math.min(f.top, _visibleRegionMinY);
// //    });
//   }

  // Call through to onSelectionChanged.
  void _handleSelectionChange(
      TextSelection nextSelection,
      SelectionChangedCause cause,
      ) {
    // Changes made by the keyboard can sometimes be "out of band" for listening
    // components, so always send those events, even if we didn't think it
    // changed. Also, focusing an empty field is sent as a selection change even
    // if the selection offset didn't change.
    final bool focusingEmpty = nextSelection.baseOffset == 0 &&
        nextSelection.extentOffset == 0 &&
        !hasFocus;
    if (nextSelection == selection &&
        cause != SelectionChangedCause.keyboard &&
        !focusingEmpty) {
      return;
    }
    if (onSelectionChanged != null) {
      onSelectionChanged!(nextSelection, cause);
    }
  }

  // Retuns a cached plain text version of the text in the painter.
  String? _cachedPlainText;
  @override
  String get plainText {
    _cachedPlainText ??= textSpanToActualText(_textPainter.text!);
    return _cachedPlainText!;
  }

  /// The text to display.
  @override
  InlineSpan? get text => _textPainter.text;
  final TextPainter _textPainter;
  set text(InlineSpan? value) {
    if (_textPainter.text == value) {
      return;
    }
    _textPainter.text = value;
    _cachedPlainText = null;
    extractPlaceholderSpans(value!);
    markNeedsTextLayout();
    markNeedsSemanticsUpdate();
  }

  /// How the text should be aligned horizontally.
  ///
  /// This must not be null.
  TextAlign get textAlign => _textPainter.textAlign;
  set textAlign(TextAlign value) {
    if (_textPainter.textAlign == value) {
      return;
    }
    _textPainter.textAlign = value;
    markNeedsTextLayout();
  }

  /// The directionality of the text.
  ///
  /// This decides how the [TextAlign.start], [TextAlign.end], and
  /// [TextAlign.justify] values of [textAlign] are interpreted.
  ///
  /// This is also used to disambiguate how to render bidirectional text. For
  /// example, if the [text] is an English phrase followed by a Hebrew phrase,
  /// in a [TextDirection.ltr] context the English phrase will be on the left
  /// and the Hebrew phrase to its right, while in a [TextDirection.rtl]
  /// context, the English phrase will be on the right and the Hebrew phrase on
  /// its left.
  ///
  /// This must not be null.
  @override
  TextDirection get textDirection => _textPainter.textDirection!;
  set textDirection(TextDirection value) {
    if (_textPainter.textDirection == value) {
      return;
    }
    _textPainter.textDirection = value;
    markNeedsTextLayout();
    markNeedsSemanticsUpdate();
  }

  /// Used by this renderer's internal [TextPainter] to select a locale-specific
  /// font.
  ///
  /// In some cases the same Unicode character may be rendered differently depending
  /// on the locale. For example the '骨' character is rendered differently in
  /// the Chinese and Japanese locales. In these cases the [locale] may be used
  /// to select a locale-specific font.
  ///
  /// If this value is null, a system-dependent algorithm is used to select
  /// the font.
  Locale? get locale => _textPainter.locale;
  set locale(Locale? value) {
    if (_textPainter.locale == value) {
      return;
    }
    _textPainter.locale = value;
    markNeedsTextLayout();
  }

  /// The [StrutStyle] used by the renderer's internal [TextPainter] to
  /// determine the strut to use.
  StrutStyle? get strutStyle => _textPainter.strutStyle;
  set strutStyle(StrutStyle? value) {
    if (_textPainter.strutStyle == value) {
      return;
    }
    _textPainter.strutStyle = value;
    markNeedsTextLayout();
  }

  /// The color to use when painting the cursor.
  Color? get cursorColor => _cursorColor;
  Color? _cursorColor;
  set cursorColor(Color? value) {
    if (_cursorColor == value) {
      return;
    }
    _cursorColor = value;
    markNeedsPaint();
  }

  /// The color to use when painting the cursor aligned to the text while
  /// rendering the floating cursor.
  ///
  /// The default is light grey.
  Color? get backgroundCursorColor => _backgroundCursorColor;
  Color? _backgroundCursorColor;
  set backgroundCursorColor(Color? value) {
    if (backgroundCursorColor == value) {
      return;
    }
    _backgroundCursorColor = value;
    markNeedsPaint();
  }

  /// Whether to paint the cursor.
  ValueNotifier<bool> get showCursor => _showCursor;
  ValueNotifier<bool> _showCursor;
  set showCursor(ValueNotifier<bool> value) {
    if (_showCursor == value) {
      return;
    }
    if (attached) {
      _showCursor.removeListener(markNeedsPaint);
    }
    _showCursor = value;
    if (attached) {
      _showCursor.addListener(markNeedsPaint);
    }
    markNeedsPaint();
  }

  /// Whether this rendering object will take a full line regardless the text width.
  @override
  bool get forceLine => _forceLine;
  bool _forceLine = false;
  set forceLine(bool value) {
    if (_forceLine == value) {
      return;
    }
    _forceLine = value;
    markNeedsLayout();
  }

  /// Whether this rendering object is read only.
  @override
  bool get readOnly => _readOnly;
  bool _readOnly = false;
  set readOnly(bool value) {
    if (_readOnly == value) {
      return;
    }
    _readOnly = value;
    markNeedsSemanticsUpdate();
  }

  /// The maximum number of lines for the text to span, wrapping if necessary.
  ///
  /// If this is 1 (the default), the text will not wrap, but will extend
  /// indefinitely instead.
  ///
  /// If this is null, there is no limit to the number of lines.
  ///
  /// When this is not null, the intrinsic height of the render object is the
  /// height of one line of text multiplied by this value. In other words, this
  /// also controls the height of the actual editing widget.
  int? get maxLines => _maxLines;
  int? _maxLines;

  /// The value may be null. If it is not null, then it must be greater than zero.
  set maxLines(int? value) {
    assert(value == null || value > 0);
    if (maxLines == value) {
      return;
    }
    _maxLines = value;
    markNeedsTextLayout();
  }

  /// {@macro flutter.widgets.editableText.minLines}
  int? get minLines => _minLines;
  int? _minLines;

  /// The value may be null. If it is not null, then it must be greater than zero.
  set minLines(int? value) {
    assert(value == null || value > 0);
    if (minLines == value) {
      return;
    }
    _minLines = value;
    markNeedsTextLayout();
  }

  /// {@macro flutter.widgets.editableText.expands}
  bool get expands => _expands;
  bool _expands;
  set expands(bool value) {
    if (expands == value) {
      return;
    }
    _expands = value;
    markNeedsTextLayout();
  }

  /// The color to use when painting the selection.
  @override
  Color? get selectionColor => _selectionColor;
  Color? _selectionColor;
  @override
  set selectionColor(Color? value) {
    if (_selectionColor == value) {
      return;
    }
    _selectionColor = value;
    markNeedsPaint();
  }

  /// The number of font pixels for each logical pixel.
  ///
  /// For example, if the text scale factor is 1.5, text will be 50% larger than
  /// the specified font size.
  double get textScaleFactor => _textPainter.textScaleFactor;
  set textScaleFactor(double value) {
    if (_textPainter.textScaleFactor == value) {
      return;
    }
    _textPainter.textScaleFactor = value;
    markNeedsTextLayout();
  }

  List<ui.TextBox>? _selectionRects;

  /// The region of text that is selected, if any.
  @override
  TextSelection? get selection => _selection;
  TextSelection? _selection;
  @override
  set selection(TextSelection? value) {
    if (_selection == value) {
      return;
    }
    _selection = value;
    _selectionRects = null;
    markNeedsPaint();
    markNeedsSemanticsUpdate();
  }

  /// The offset at which the text should be painted.
  ///
  /// If the text content is larger than the editable line itself, the editable
  /// line clips the text. This property controls which part of the text is
  /// visible by shifting the text by the given offset before clipping.
  ViewportOffset get offset => _offset;
  ViewportOffset _offset;
  set offset(ViewportOffset value) {
    if (_offset == value) {
      return;
    }
    if (attached) {
      _offset.removeListener(markNeedsPaint);
    }
    _offset = value;
    if (attached) {
      _offset.addListener(markNeedsPaint);
    }
    markNeedsLayout();
  }

  /// How thick the cursor will be.
  double? get cursorWidth => _cursorWidth;
  double? _cursorWidth = 1.0;
  set cursorWidth(double? value) {
    if (_cursorWidth == value) {
      return;
    }
    _cursorWidth = value;
    markNeedsLayout();
  }

  /// How tall the cursor will be.
  ///
  /// This can be null, in which case the getter will actually return [preferredLineHeight].
  ///
  /// Setting this to itself fixes the value to the current [preferredLineHeight]. Setting
  /// this to null returns the behaviour of deferring to [preferredLineHeight].
  // TODO(ianh): This is a confusing API. We should have a separate getter for the effective cursor height.
  double get cursorHeight => _cursorHeight ?? preferredLineHeight;
  double? _cursorHeight;
  set cursorHeight(double? value) {
    if (_cursorHeight == value) {
      return;
    }
    _cursorHeight = value;
    markNeedsLayout();
  }

  /// {@template flutter.rendering.editable.paintCursorOnTop}
  /// If the cursor should be painted on top of the text or underneath it.
  ///
  /// By default, the cursor should be painted on top for iOS platforms and
  /// underneath for Android platforms.
  /// {@endtemplate}
  bool? get paintCursorAboveText => _paintCursorOnTop;
  bool? _paintCursorOnTop;
  set paintCursorAboveText(bool? value) {
    if (_paintCursorOnTop == value) {
      return;
    }
    _paintCursorOnTop = value;
    markNeedsLayout();
  }

  /// {@template flutter.rendering.editable.cursorOffset}
  /// The offset that is used, in pixels, when painting the cursor on screen.
  ///
  /// By default, the cursor position should be set to an offset of
  /// (-[cursorWidth] * 0.5, 0.0) on iOS platforms and (0, 0) on Android
  /// platforms. The origin from where the offset is applied to is the arbitrary
  /// location where the cursor ends up being rendered from by default.
  /// {@endtemplate}
  Offset? get cursorOffset => _cursorOffset;
  Offset? _cursorOffset;
  set cursorOffset(Offset? value) {
    if (_cursorOffset == value) {
      return;
    }
    _cursorOffset = value;
    markNeedsLayout();
  }

  /// How rounded the corners of the cursor should be.
  Radius? get cursorRadius => _cursorRadius;
  Radius? _cursorRadius;
  set cursorRadius(Radius? value) {
    if (_cursorRadius == value) {
      return;
    }
    _cursorRadius = value;
    markNeedsPaint();
  }

  /// The [LayerLink] of start selection handle.
  ///
  /// [RenderEditable] is responsible for calculating the [Offset] of this
  /// [LayerLink], which will be used as [CompositedTransformTarget] of start handle.
  @override
  LayerLink? get startHandleLayerLink => _startHandleLayerLink;
  LayerLink? _startHandleLayerLink;
  @override
  set startHandleLayerLink(LayerLink? value) {
    if (_startHandleLayerLink == value) {
      return;
    }
    _startHandleLayerLink = value;
    markNeedsPaint();
  }

  /// The [LayerLink] of end selection handle.
  ///
  /// [RenderEditable] is responsible for calculating the [Offset] of this
  /// [LayerLink], which will be used as [CompositedTransformTarget] of end handle.
  @override
  LayerLink? get endHandleLayerLink => _endHandleLayerLink;
  LayerLink? _endHandleLayerLink;
  @override
  set endHandleLayerLink(LayerLink? value) {
    if (_endHandleLayerLink == value) {
      return;
    }
    _endHandleLayerLink = value;
    markNeedsPaint();
  }

  /// The padding applied to text field. Used to determine the bounds when
  /// moving the floating cursor.
  ///
  /// Defaults to a padding with left, top and right set to 4, bottom to 5.
  EdgeInsets get floatingCursorAddedMargin => _floatingCursorAddedMargin;
  EdgeInsets _floatingCursorAddedMargin;
  set floatingCursorAddedMargin(EdgeInsets value) {
    if (_floatingCursorAddedMargin == value) {
      return;
    }
    _floatingCursorAddedMargin = value;
    markNeedsPaint();
  }

  bool _floatingCursorOn = false;
  late Offset _floatingCursorOffset;
  TextPosition? _floatingCursorTextPosition;

  /// Controls how tall the selection highlight boxes are computed to be.
  ///
  /// See [ui.BoxHeightStyle] for details on available styles.
  ui.BoxHeightStyle get selectionHeightStyle => _selectionHeightStyle;
  ui.BoxHeightStyle _selectionHeightStyle;
  set selectionHeightStyle(ui.BoxHeightStyle value) {
    if (_selectionHeightStyle == value) {
      return;
    }
    _selectionHeightStyle = value;
    markNeedsPaint();
  }

  /// Controls how wide the selection highlight boxes are computed to be.
  ///
  /// See [ui.BoxWidthStyle] for details on available styles.
  ui.BoxWidthStyle get selectionWidthStyle => _selectionWidthStyle;
  ui.BoxWidthStyle _selectionWidthStyle;
  set selectionWidthStyle(ui.BoxWidthStyle value) {
    if (_selectionWidthStyle == value) {
      return;
    }
    _selectionWidthStyle = value;
    markNeedsPaint();
  }

  /// If false, [describeSemanticsConfiguration] will not set the
  /// configuration's cursor motion or set selection callbacks.
  ///
  /// True by default.
  bool? get enableInteractiveSelection => _enableInteractiveSelection;
  bool? _enableInteractiveSelection;
  set enableInteractiveSelection(bool? value) {
    if (_enableInteractiveSelection == value) {
      return;
    }
    _enableInteractiveSelection = value;
    markNeedsTextLayout();
    markNeedsSemanticsUpdate();
  }

  /// {@template flutter.rendering.editable.selectionEnabled}
  /// True if interactive selection is enabled based on the values of
  /// [enableInteractiveSelection] and [obscureText].
  ///
  /// By default [enableInteractiveSelection] is null, obscureText is false,
  /// and this method returns true.
  /// If [enableInteractiveSelection] is null and obscureText is true, then this
  /// method returns false. This is the common case for password fields.
  /// If [enableInteractiveSelection] is non-null then its value is returned. An
  /// app might set it to true to enable interactive selection for a password
  /// field, or to false to unconditionally disable interactive selection.
  /// {@endtemplate}
  bool get selectionEnabled {
    return enableInteractiveSelection ?? !obscureText;
  }

  /// The color used to paint the prompt rectangle.
  ///
  /// The prompt rectangle will only be requested on non-web iOS applications.
  Color get promptRectColor => _promptRectPaint.color;
  set promptRectColor(Color? newValue) {
    // Painter.color can not be null.
    if (newValue == null) {
      setPromptRectRange(null);
      return;
    }

    if (promptRectColor == newValue) {
      return;
    }

    _promptRectPaint.color = newValue;
    if (_promptRectRange != null) {
      markNeedsPaint();
    }
  }

  TextRange? _promptRectRange;

  /// Dismisses the currently displayed prompt rectangle and displays a new prompt rectangle
  /// over [newRange] in the given color [promptRectColor].
  ///
  /// The prompt rectangle will only be requested on non-web iOS applications.
  ///
  /// When set to null, the currently displayed prompt rectangle (if any) will be dismissed.
  void setPromptRectRange(TextRange? newRange) {
    // ignore: always_put_control_body_on_new_line
    if (_promptRectRange == newRange) return;

    _promptRectRange = newRange;
    markNeedsPaint();
  }

  /// The maximum amount the text is allowed to scroll.
  ///
  /// This value is only valid after layout and can change as additional
  /// text is entered or removed in order to accommodate expanding when
  /// [expands] is set to true.
  double? get maxScrollExtent => _maxScrollExtent;
  double? _maxScrollExtent = 0;

  double get _caretMargin => _kCaretGap + cursorWidth!;

  /// {@macro flutter.widgets.Clip}
  ///
  /// Defaults to [Clip.hardEdge], and must not be null.
  Clip get clipBehavior => _clipBehavior;
  Clip _clipBehavior = Clip.hardEdge;
  set clipBehavior(Clip value) {
    if (value != _clipBehavior) {
      _clipBehavior = value;
      markNeedsPaint();
      markNeedsSemanticsUpdate();
    }
  }

  @override
  void describeSemanticsConfiguration(SemanticsConfiguration config) {
    super.describeSemanticsConfiguration(config);

    config
      ..value = obscureText ? obscuringCharacter! * plainText.length : plainText
      ..isObscured = obscureText
      ..isMultiline = _isMultiline
      ..textDirection = textDirection
      ..isFocused = hasFocus
      ..isTextField = true
      ..isReadOnly = readOnly;

    if (hasFocus && selectionEnabled)
      config.onSetSelection = _handleSetSelection;

    if (selectionEnabled && _selection?.isValid == true) {
      config.textSelection = _selection;
      if (_textPainter.getOffsetBefore(_selection!.extentOffset) != null) {
        config
          ..onMoveCursorBackwardByWord = _handleMoveCursorBackwardByWord
          ..onMoveCursorBackwardByCharacter =
              _handleMoveCursorBackwardByCharacter;
      }
      if (_textPainter.getOffsetAfter(_selection!.extentOffset) != null) {
        config
          ..onMoveCursorForwardByWord = _handleMoveCursorForwardByWord
          ..onMoveCursorForwardByCharacter =
              _handleMoveCursorForwardByCharacter;
      }
    }
  }

  void _handleSetSelection(TextSelection selection) {
    _handleSelectionChange(selection, SelectionChangedCause.keyboard);
  }

  void _handleMoveCursorForwardByCharacter(bool extentSelection) {
    final int? extentOffset =
    _textPainter.getOffsetAfter(_selection!.extentOffset);
    if (extentOffset == null) {
      return;
    }
    final int baseOffset =
    !extentSelection ? extentOffset : _selection!.baseOffset;
    _handleSelectionChange(
      TextSelection(baseOffset: baseOffset, extentOffset: extentOffset),
      SelectionChangedCause.keyboard,
    );
  }

  void _handleMoveCursorBackwardByCharacter(bool extentSelection) {
    final int? extentOffset =
    _textPainter.getOffsetBefore(_selection!.extentOffset);
    if (extentOffset == null) {
      return;
    }
    final int baseOffset =
    !extentSelection ? extentOffset : _selection!.baseOffset;
    _handleSelectionChange(
      TextSelection(baseOffset: baseOffset, extentOffset: extentOffset),
      SelectionChangedCause.keyboard,
    );
  }

  void _handleMoveCursorForwardByWord(bool extentSelection) {
    final TextRange currentWord =
    _textPainter.getWordBoundary(_selection!.extent);
    final TextRange? nextWord = _getNextWord(currentWord.end);
    if (nextWord == null) {
      return;
    }
    final int baseOffset =
    extentSelection ? _selection!.baseOffset : nextWord.start;
    _handleSelectionChange(
      TextSelection(
        baseOffset: baseOffset,
        extentOffset: nextWord.start,
      ),
      SelectionChangedCause.keyboard,
    );
  }

  void _handleMoveCursorBackwardByWord(bool extentSelection) {
    final TextRange currentWord =
    _textPainter.getWordBoundary(_selection!.extent);
    final TextRange? previousWord = _getPreviousWord(currentWord.start - 1);
    if (previousWord == null) {
      return;
    }
    final int baseOffset =
    extentSelection ? _selection!.baseOffset : previousWord.start;
    _handleSelectionChange(
      TextSelection(
        baseOffset: baseOffset,
        extentOffset: previousWord.start,
      ),
      SelectionChangedCause.keyboard,
    );
  }

  TextRange? _getNextWord(int offset) {
    while (true) {
      final TextRange range =
      _textPainter.getWordBoundary(TextPosition(offset: offset));
      if (!range.isValid || range.isCollapsed) {
        return null;
      }
      if (!_onlyWhitespace(range)) {
        return range;
      }
      offset = range.end;
    }
  }

  TextRange? _getPreviousWord(int offset) {
    while (offset >= 0) {
      final TextRange range =
      _textPainter.getWordBoundary(TextPosition(offset: offset));
      if (!range.isValid || range.isCollapsed) {
        return null;
      }
      if (!_onlyWhitespace(range)) {
        return range;
      }
      offset = range.start - 1;
    }
    return null;
  }

  // Check if the given text range only contains white space or separator
  // characters.
  //
  // Includes newline characters from ASCII and separators from the
  // [unicode separator category](https://www.compart.com/en/unicode/category/Zs)
  // TODO(jonahwilliams): replace when we expose this ICU information.
  bool _onlyWhitespace(TextRange range) {
    for (int i = range.start; i < range.end; i++) {
      final int codeUnit = text!.codeUnitAt(i)!;
      if (!isWhitespace(codeUnit)) {
        return false;
      }
    }
    return true;
  }

  @override
  void attach(PipelineOwner owner) {
    super.attach(owner);
    // _tap = TapGestureRecognizer(debugOwner: this)
    //   ..onTapDown = _handleTapDown
    //   ..onTap = _handleTap;
    // _longPress = LongPressGestureRecognizer(debugOwner: this)
    //   ..onLongPress = _handleLongPress;
    _offset.addListener(markNeedsPaint);
    _showCursor.addListener(markNeedsPaint);
  }

  @override
  void detach() {
    // _tap.dispose();
    // _longPress.dispose();
    _offset.removeListener(markNeedsPaint);
    _showCursor.removeListener(markNeedsPaint);
    super.detach();
  }

  bool get _isMultiline => maxLines != 1;

  Axis get _viewportAxis => _isMultiline ? Axis.vertical : Axis.horizontal;

  @override
  Offset get paintOffset {
    switch (_viewportAxis) {
      case Axis.horizontal:
        return Offset(-offset.pixels, 0.0);
      case Axis.vertical:
        return Offset(0.0, -offset.pixels);
    }
  }

  double get _viewportExtent {
    assert(hasSize);
    switch (_viewportAxis) {
      case Axis.horizontal:
        return size.width;
      case Axis.vertical:
        return size.height;
    }
  }

  double _getMaxScrollExtent(Size contentSize) {
    assert(hasSize);
    switch (_viewportAxis) {
      case Axis.horizontal:
        return math.max(0.0, contentSize.width - size.width);
      case Axis.vertical:
        return math.max(0.0, contentSize.height - size.height);
    }
  }

  // We need to check the paint offset here because during animation, the start of
  // the text may position outside the visible region even when the text fits.
  bool get _hasVisualOverflow =>
      _maxScrollExtent! > 0 || paintOffset != Offset.zero;

  /// Returns the local coordinates of the endpoints of the given selection.
  ///
  /// If the selection is collapsed (and therefore occupies a single point), the
  /// returned list is of length one. Otherwise, the selection is not collapsed
  /// and the returned list is of length two. In this case, however, the two
  /// points might actually be co-located (e.g., because of a bidirectional
  /// selection that contains some text but whose ends meet in the middle).
  ///
  /// See also:
  ///
  ///  * [getLocalRectForCaret], which is the equivalent but for
  ///    a [TextPosition] rather than a [TextSelection].
  @override
  List<TextSelectionPoint> getEndpointsForSelection(TextSelection selection) {
    layoutText(minWidth: constraints.minWidth, maxWidth: constraints.maxWidth);

    //final Offset paintOffset = _paintOffset;
    ///zmt
    final Offset effectiveOffset = _effectiveOffset;

    TextSelection textPainterSelection = selection;
    if (hasSpecialInlineSpanBase) {
      textPainterSelection =
          convertTextInputSelectionToTextPainterSelection(text!, selection);
    }
    if (selection.isCollapsed) {
      // todo(mpcomplete): This doesn't work well at an RTL/LTR boundary.

      double? caretHeight;
      final ValueChanged<double> caretHeightCallBack = (double value) {
        caretHeight = value;
      };

      final Offset caretOffset = getCaretOffset(
        TextPosition(
            offset: textPainterSelection.extentOffset,
            affinity: selection.extent.affinity),
        caretHeightCallBack: caretHeightCallBack,
        effectiveOffset: effectiveOffset,
        caretPrototype: _caretPrototype,
      );

      final Offset start =
          Offset(0.0, caretHeight ?? preferredLineHeight) + caretOffset;

      return <TextSelectionPoint>[TextSelectionPoint(start, null)];
    } else {
      final List<ui.TextBox> boxes =
      _textPainter.getBoxesForSelection(textPainterSelection);
      final Offset start =
          Offset(boxes.first.start, boxes.first.bottom) + effectiveOffset;
      final Offset end =
          Offset(boxes.last.end, boxes.last.bottom) + effectiveOffset;
      return <TextSelectionPoint>[
        TextSelectionPoint(start, boxes.first.direction),
        TextSelectionPoint(end, boxes.last.direction),
      ];
    }
  }

  /// Returns the smallest [Rect], in the local coordinate system, that covers
  /// the text within the [TextRange] specified.
  ///
  /// This method is used to calculate the approximate position of the IME bar
  /// on iOS.
  ///
  /// Returns null if [TextRange.isValid] is false for the given `range`, or the
  /// given `range` is collapsed.
  Rect? getRectForComposingRange(TextRange range) {
    if (!range.isValid || range.isCollapsed) {
      return null;
    }
    layoutText(minWidth: constraints.minWidth, maxWidth: constraints.maxWidth);

    final List<ui.TextBox> boxes = _textPainter.getBoxesForSelection(
      TextSelection(baseOffset: range.start, extentOffset: range.end),
    );

    return boxes
        .fold(
      null,
          (Rect? accum, TextBox incoming) =>
      accum?.expandToInclude(incoming.toRect()) ?? incoming.toRect(),
    )
        ?.shift(paintOffset);
  }

  /// Returns the position in the text for the given global coordinate.
  ///
  /// See also:
  ///
  ///  * [getLocalRectForCaret], which is the reverse operation, taking
  ///    a [TextPosition] and returning a [Rect].
  ///  * [TextPainter.getPositionForOffset], which is the equivalent method
  ///    for a [TextPainter] object.
  @override
  TextPosition getPositionForPoint(Offset globalPosition) {
    layoutText(minWidth: constraints.minWidth, maxWidth: constraints.maxWidth);
    globalPosition += -paintOffset;
    return _textPainter.getPositionForOffset(globalToLocal(globalPosition));
  }

  /// Returns the [Rect] in local coordinates for the caret at the given text
  /// position.
  ///
  /// See also:
  ///
  ///  * [getPositionForPoint], which is the reverse operation, taking
  ///    an [Offset] in global coordinates and returning a [TextPosition].
  ///  * [getEndpointsForSelection], which is the equivalent but for
  ///    a selection rather than a particular text position.
  ///  * [TextPainter.getOffsetForCaret], the equivalent method for a
  ///    [TextPainter] object.
  Rect getLocalRectForCaret(TextPosition caretPosition) {
    layoutText(minWidth: constraints.minWidth, maxWidth: constraints.maxWidth);
    //  final  Offset caretOffset =
    //       _textPainter.getOffsetForCaret(caretPosition, _caretPrototype);

    final Offset caretOffset = getCaretOffset(
      caretPosition,
      caretPrototype: _caretPrototype,
      // effectiveOffset: effectiveOffset,
    );

    // This rect is the same as _caretPrototype but without the vertical padding.
    Rect rect = Rect.fromLTWH(0.0, 0.0, cursorWidth!, preferredLineHeight)
        .shift(caretOffset + paintOffset);
    // Add additional cursor offset (generally only if on iOS).
    if (_cursorOffset != null) {
      rect = rect.shift(_cursorOffset!);
    }

    return rect.shift(_getPixelPerfectCursorOffset(rect));
  }

  /// An estimate of the height of a line in the text. See [TextPainter.preferredLineHeight].
  /// This does not required the layout to be updated.
  @override
  double get preferredLineHeight => _textPainter.preferredLineHeight;

  double _preferredHeight(double width) {
    final bool singleLine = maxLines == 1;

    // issue: #67,#76
    if (singleLine) {
      //preferredLineHeight is not right for WidgetSpan.
      return _textPainter.size.height;
    }
    // Lock height to maxLines if needed
    final bool lockedMax = maxLines != null && minLines == null;
    final bool lockedBoth = minLines != null && minLines == maxLines;

    if (lockedMax || lockedBoth) {
      return preferredLineHeight * maxLines!;
    }

    // Clamp height to minLines or maxLines if needed
    final bool minLimited = minLines != null && minLines! > 1;
    final bool maxLimited = maxLines != null;
    if (minLimited || maxLimited) {
      layoutText(maxWidth: width);
      if (minLimited && _textPainter.height < preferredLineHeight * minLines!) {
        return preferredLineHeight * minLines!;
      }
      if (maxLimited && _textPainter.height > preferredLineHeight * maxLines!) {
        return preferredLineHeight * maxLines!;
      }
    }

    // Set the height based on the content
    if (width == double.infinity) {
      final String text = plainText;
      int lines = 1;
      for (int index = 0; index < text.length; index += 1) {
        if (text.codeUnitAt(index) == 0x0A) // count explicit line breaks
          lines += 1;
      }
      return preferredLineHeight * lines;
    }
    layoutText(maxWidth: width);
    return math.max(preferredLineHeight, _textPainter.height);
  }

  @override
  double computeDistanceToActualBaseline(TextBaseline baseline) {
    layoutText(minWidth: constraints.minWidth, maxWidth: constraints.maxWidth);
    return _textPainter.computeDistanceToActualBaseline(baseline);
  }

  @override
  bool hitTestSelf(Offset position) => true;

  late TapGestureRecognizer _tap;
  late LongPressGestureRecognizer _longPress;

  @override
  void handleEvent(PointerEvent event, BoxHitTestEntry entry) {
    assert(debugHandleEvent(event, entry));
    if (event is PointerDownEvent) {
      assert(!debugNeedsLayout);
      // // Checks if there is any gesture recognizer in the text span.
      // final Offset offset = entry.localPosition;
      // final TextPosition position = _textPainter.getPositionForOffset(offset);
      // final InlineSpan? span = _textPainter.text!.getSpanForPosition(position);
      // if (span != null && span is TextSpan) {
      //   final TextSpan textSpan = span;
      //   textSpan.recognizer?.addPointer(event);
      // }

      if (!ignorePointer && onSelectionChanged != null) {
        // Propagates the pointer event to selection handlers.
        _tap.addPointer(event);
        _longPress.addPointer(event);
      }
    }
  }

  // void _handleTap() {
  //   assert(!ignorePointer);
  //   handleTap();
  // }

  /// If [ignorePointer] is false (the default) then this method is called by
  /// the internal gesture recognizer's [DoubleTapGestureRecognizer.onDoubleTap]
  /// callback.
  ///
  /// When [ignorePointer] is true, an ancestor widget must respond to double
  /// tap events by calling this method.
  void handleDoubleTap() {
    selectWord(cause: SelectionChangedCause.doubleTap);
  }

  // void _handleLongPress() {
  //   assert(!ignorePointer);
  //   handleLongPress();
  // }

  late Rect _caretPrototype;

  // todo(garyq): This is no longer producing the highest-fidelity caret
  // heights for Android, especially when non-alphabetic languages
  // are involved. The current implementation overrides the height set
  // here with the full measured height of the text on Android which looks
  // superior (subjectively and in terms of fidelity) in _paintCaret. We
  // should rework this properly to once again match the platform. The constant
  // _kCaretHeightOffset scales poorly for small font sizes.
  //
  /// On iOS, the cursor is taller than the cursor on Android. The height
  /// of the cursor for iOS is approximate and obtained through an eyeball
  /// comparison.
  void _computeCaretPrototype() {
    switch (defaultTargetPlatform) {
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
        _caretPrototype =
            Rect.fromLTWH(0.0, 0.0, cursorWidth!, cursorHeight + 2);
        break;
      case TargetPlatform.android:
      case TargetPlatform.fuchsia:
      case TargetPlatform.linux:
      case TargetPlatform.windows:
        _caretPrototype = Rect.fromLTWH(0.0, _kCaretHeightOffset, cursorWidth!,
            cursorHeight - 2.0 * _kCaretHeightOffset);
        break;
    }
  }

  @override
  void performLayout() {
    layoutChildren(constraints);
    layoutText(
        minWidth: constraints.minWidth,
        maxWidth: constraints.maxWidth,
        forceLayout: true);
    setParentData();
    _computeCaretPrototype();
    _selectionRects = null;
    // We grab _textPainter.size here because assigning to `size` on the next
    // line will trigger us to validate our intrinsic sizes, which will change
    // _textPainter's layout because the intrinsic size calculations are
    // destructive, which would mean we would get different results if we later
    // used properties on _textPainter in this method.
    // Other _textPainter state like didExceedMaxLines will also be affected,
    // though we currently don't use those here.
    // See also RenderParagraph which has a similar issue.
    final Size textPainterSize = _textPainter.size;
    final double width = forceLine
        ? constraints.maxWidth
        : constraints.constrainWidth(_textPainter.size.width + _caretMargin);
    size = Size(width,
        constraints.constrainHeight(_preferredHeight(constraints.maxWidth)));
    final Size contentSize =
    Size(textPainterSize.width + _caretMargin, textPainterSize.height);
    _maxScrollExtent = _getMaxScrollExtent(contentSize);
    offset.applyViewportDimension(_viewportExtent);
    offset.applyContentDimensions(0.0, _maxScrollExtent!);
  }

  Offset _getPixelPerfectCursorOffset(Rect caretRect) {
    final Offset caretPosition = localToGlobal(caretRect.topLeft);
    final double pixelMultiple = 1.0 / _devicePixelRatio!;
    final int quotientX = (caretPosition.dx / pixelMultiple).round();
    final int quotientY = (caretPosition.dy / pixelMultiple).round();
    final double pixelPerfectOffsetX =
        quotientX * pixelMultiple - caretPosition.dx;
    final double pixelPerfectOffsetY =
        quotientY * pixelMultiple - caretPosition.dy;
    return Offset(pixelPerfectOffsetX, pixelPerfectOffsetY);
  }

  void _paintCaret(Canvas canvas, Offset effectiveOffset,
      TextPosition textPosition, TextPosition? textInputPosition) {
    assert(
    textLayoutLastMaxWidth == constraints.maxWidth &&
        textLayoutLastMinWidth == constraints.minWidth,
    'Last width ($textLayoutLastMinWidth, $textLayoutLastMaxWidth) not the same as max width constraint (${constraints.minWidth}, ${constraints.maxWidth}).');

    // If the floating cursor is enabled, the text cursor's color is [backgroundCursorColor] while
    // the floating cursor's color is _cursorColor;
    final Paint paint = Paint()
      ..color = _floatingCursorOn ? backgroundCursorColor! : _cursorColor!;

    double? caretHeight;
    final ValueChanged<double> caretHeightCallBack = (double value) {
      caretHeight = value;
    };
    final Offset caretOffset = getCaretOffset(
      textPosition,
      caretHeightCallBack: caretHeightCallBack,
      effectiveOffset: effectiveOffset,
      caretPrototype: _caretPrototype,
    );

    Rect caretRect = _caretPrototype.shift(caretOffset);
    if (_cursorOffset != null) {
      caretRect = caretRect.shift(_cursorOffset!);
    }

    final double? fullHeight =
        _textPainter.getFullHeightForCaret(textPosition, _caretPrototype) ??
            caretHeight;
    if (fullHeight != null) {
      switch (defaultTargetPlatform) {
        case TargetPlatform.iOS:
          {
//            final double heightDiff = fullHeight - caretRect.height;
//            // Center the caret vertically along the text.
//            caretRect = Rect.fromLTWH(
//              caretRect.left,
//              caretRect.top + heightDiff / 2,
//              caretRect.width,
//              caretRect.height,
//            );
            caretRect = Rect.fromLTWH(
              caretRect.left,
              caretRect.top,
              caretRect.width,
              fullHeight,
            );
            break;
          }
        default:
          {
            // Override the height to take the full height of the glyph at the TextPosition
            // when not on iOS. iOS has special handling that creates a taller caret.
            // todo(garyq): See the todo for _getCaretPrototype.
            caretRect = Rect.fromLTWH(
              caretRect.left,
              caretRect.top - _kCaretHeightOffset,
              caretRect.width,
              fullHeight,
            );
            break;
          }
      }
    }

    caretRect = caretRect.shift(_getPixelPerfectCursorOffset(caretRect));

    if (cursorRadius == null) {
      canvas.drawRect(caretRect, paint);
    } else {
      final RRect caretRRect =
      RRect.fromRectAndRadius(caretRect, cursorRadius!);
      canvas.drawRRect(caretRRect, paint);
    }

    if (caretRect != _lastCaretRect) {
      _lastCaretRect = caretRect;
      if (onCaretChanged != null) {
        onCaretChanged!(caretRect);
      }
    }
  }

  /// Sets the screen position of the floating cursor and the text position
  /// closest to the cursor.
  void setFloatingCursor(FloatingCursorDragState state, Offset boundedOffset,
      TextPosition lastTextPosition,
      {double? resetLerpValue}) {
    if (state == FloatingCursorDragState.Start) {
      _relativeOrigin = const Offset(0, 0);
      _previousOffset = null;
      _resetOriginOnBottom = false;
      _resetOriginOnTop = false;
      _resetOriginOnRight = false;
      _resetOriginOnBottom = false;
    }
    _floatingCursorOn = state != FloatingCursorDragState.End;
    _resetFloatingCursorAnimationValue = resetLerpValue;
    if (_floatingCursorOn) {
      _floatingCursorOffset = boundedOffset;
      _floatingCursorTextPosition = lastTextPosition;
    }
    markNeedsPaint();
  }

  void _paintFloatingCaret(Canvas canvas, Offset effectiveOffset) {
    assert(
    textLayoutLastMaxWidth == constraints.maxWidth &&
        textLayoutLastMinWidth == constraints.minWidth,
    'Last width ($textLayoutLastMinWidth, $textLayoutLastMaxWidth) not the same as max width constraint (${constraints.minWidth}, ${constraints.maxWidth}).');
    assert(_floatingCursorOn);

    // We always want the floating cursor to render at full opacity.
    final Paint paint = Paint()..color = _cursorColor!.withOpacity(0.75);
    double? sizeAdjustmentX = _kFloatingCaretSizeIncrease.dx;
    double? sizeAdjustmentY = _kFloatingCaretSizeIncrease.dy;

    if (_resetFloatingCursorAnimationValue != null) {
      sizeAdjustmentX = ui.lerpDouble(
          sizeAdjustmentX, 0, _resetFloatingCursorAnimationValue!);
      sizeAdjustmentY = ui.lerpDouble(
          sizeAdjustmentY, 0, _resetFloatingCursorAnimationValue!);
    }

    final Rect floatingCaretPrototype = Rect.fromLTRB(
      _caretPrototype.left - sizeAdjustmentX!,
      _caretPrototype.top - sizeAdjustmentY!,
      _caretPrototype.right + sizeAdjustmentX,
      _caretPrototype.bottom + sizeAdjustmentY,
    );

    final Rect caretRect = floatingCaretPrototype.shift(effectiveOffset);
    const Radius floatingCursorRadius = Radius.circular(_kFloatingCaretRadius);
    final RRect caretRRect =
    RRect.fromRectAndRadius(caretRect, floatingCursorRadius);
    canvas.drawRRect(caretRRect, paint);
  }

  // The relative origin in relation to the distance the user has theoretically
  // dragged the floating cursor offscreen. This value is used to account for the
  // difference in the rendering position and the raw offset value.
  Offset _relativeOrigin = const Offset(0, 0);
  Offset? _previousOffset;
  bool _resetOriginOnLeft = false;
  bool _resetOriginOnRight = false;
  bool _resetOriginOnTop = false;
  bool _resetOriginOnBottom = false;
  double? _resetFloatingCursorAnimationValue;

  /// Returns the position within the text field closest to the raw cursor offset.
  Offset calculateBoundedFloatingCursorOffset(Offset rawCursorOffset) {
    Offset deltaPosition = const Offset(0, 0);
    final double topBound = -floatingCursorAddedMargin.top;
    final double bottomBound = _textPainter.height -
        preferredLineHeight +
        floatingCursorAddedMargin.bottom;
    final double leftBound = -floatingCursorAddedMargin.left;
    final double rightBound =
        _textPainter.width + floatingCursorAddedMargin.right;

    if (_previousOffset != null)
      deltaPosition = rawCursorOffset - _previousOffset!;

    // If the raw cursor offset has gone off an edge, we want to reset the relative
    // origin of the dragging when the user drags back into the field.
    if (_resetOriginOnLeft && deltaPosition.dx > 0) {
      _relativeOrigin =
          Offset(rawCursorOffset.dx - leftBound, _relativeOrigin.dy);
      _resetOriginOnLeft = false;
    } else if (_resetOriginOnRight && deltaPosition.dx < 0) {
      _relativeOrigin =
          Offset(rawCursorOffset.dx - rightBound, _relativeOrigin.dy);
      _resetOriginOnRight = false;
    }
    if (_resetOriginOnTop && deltaPosition.dy > 0) {
      _relativeOrigin =
          Offset(_relativeOrigin.dx, rawCursorOffset.dy - topBound);
      _resetOriginOnTop = false;
    } else if (_resetOriginOnBottom && deltaPosition.dy < 0) {
      _relativeOrigin =
          Offset(_relativeOrigin.dx, rawCursorOffset.dy - bottomBound);
      _resetOriginOnBottom = false;
    }

    final double currentX = rawCursorOffset.dx - _relativeOrigin.dx;
    final double currentY = rawCursorOffset.dy - _relativeOrigin.dy;
    final double adjustedX =
    math.min(math.max(currentX, leftBound), rightBound);
    final double adjustedY =
    math.min(math.max(currentY, topBound), bottomBound);
    final Offset adjustedOffset = Offset(adjustedX, adjustedY);

    if (currentX < leftBound && deltaPosition.dx < 0)
      _resetOriginOnLeft = true;
    else if (currentX > rightBound && deltaPosition.dx > 0)
      _resetOriginOnRight = true;
    if (currentY < topBound && deltaPosition.dy < 0)
      _resetOriginOnTop = true;
    else if (currentY > bottomBound && deltaPosition.dy > 0)
      _resetOriginOnBottom = true;

    _previousOffset = rawCursorOffset;

    return adjustedOffset;
  }

  final Paint _promptRectPaint = Paint();
  void _paintPromptRectIfNeeded(Canvas canvas, Offset effectiveOffset) {
    if (_promptRectRange == null) {
      return;
    }

    final List<TextBox> boxes = _textPainter.getBoxesForSelection(
      TextSelection(
        baseOffset: _promptRectRange!.start,
        extentOffset: _promptRectRange!.end,
      ),
    );

    for (final TextBox box in boxes) {
      canvas.drawRect(box.toRect().shift(effectiveOffset), _promptRectPaint);
    }
  }

  void _paintContents(PaintingContext context, Offset offset) {
    assert(
    textLayoutLastMaxWidth == constraints.maxWidth &&
        textLayoutLastMinWidth == constraints.minWidth,
    'Last width ($textLayoutLastMinWidth, $textLayoutLastMaxWidth) not the same as max width constraint (${constraints.minWidth}, ${constraints.maxWidth}).');
    final Offset effectiveOffset = offset + paintOffset;

    bool showSelection = false;
    bool showCaret = false;

    ///zmt
    final TextSelection? actualSelection = hasSpecialInlineSpanBase
        ? convertTextInputSelectionToTextPainterSelection(text!, _selection!)
        : _selection;
    if (actualSelection != null && !_floatingCursorOn) {
      if (actualSelection.isCollapsed &&
          _showCursor.value &&
          cursorColor != null)
        showCaret = true;
      else if (!actualSelection.isCollapsed && _selectionColor != null)
        showSelection = true;
      _updateSelectionExtentsVisibility(effectiveOffset, actualSelection);
    }
    if (showSelection) {
      _selectionRects ??= _textPainter.getBoxesForSelection(actualSelection!,
          boxHeightStyle: _selectionHeightStyle,
          boxWidthStyle: _selectionWidthStyle);
      paintSelection(context.canvas, effectiveOffset);
    }

    paintWidgets(context, effectiveOffset);

    ///zmt
    _paintSpecialText(context, effectiveOffset);
    _paintPromptRectIfNeeded(context.canvas, effectiveOffset);

    // On iOS, the cursor is painted over the text, on Android, it's painted
    // under it.
    if (paintCursorAboveText!)
      _textPainter.paint(context.canvas, effectiveOffset);

    if (showCaret)
      _paintCaret(context.canvas, effectiveOffset, actualSelection!.extent,
          _selection!.extent);

    if (!paintCursorAboveText!)
      _textPainter.paint(context.canvas, effectiveOffset);

    if (_floatingCursorOn) {
      if (_resetFloatingCursorAnimationValue == null) {
        _paintCaret(
            context.canvas,
            effectiveOffset,
            convertTextInputPostionToTextPainterPostion(
                text!, _floatingCursorTextPosition!),
            _floatingCursorTextPosition);
      }
      _paintFloatingCaret(context.canvas, _floatingCursorOffset);
    }
  }

  Offset? _initialOffset;
  Offset get _effectiveOffset => (_initialOffset ?? Offset.zero) + paintOffset;

  @override
  void paint(PaintingContext context, Offset offset) {
    ///zmt
    _initialOffset = offset;

    layoutText(minWidth: constraints.minWidth, maxWidth: constraints.maxWidth);
    if (_hasVisualOverflow)
      context.pushClipRect(needsCompositing, offset, Offset.zero & size, _paintContents);
    else
      _paintContents(context, offset);

    paintHandleLayers(context, super.paint);
  }

  void _paintSpecialText(PaintingContext context, Offset offset) {


    final Canvas canvas = context.canvas;

    canvas.save();

    ///move to extended text
    canvas.translate(offset.dx, offset.dy);

    ///we have move the canvas, so rect top left should be (0,0)
    final Rect rect = const Offset(0.0, 0.0) & size;
    _paintSpecialTextChildren(<InlineSpan?>[text], canvas, rect);
    canvas.restore();
  }

  void _paintSpecialTextChildren(
      List<InlineSpan?>? textSpans, Canvas canvas, Rect rect,
      {int textOffset = 0}) {
    if (textSpans == null) {
      return;
    }

    for (final InlineSpan? ts in textSpans) {
      final Offset topLeftOffset = getOffsetForCaret(
        TextPosition(offset: textOffset),
        rect,
      );
      //skip invalid or overflow
      if (textOffset != 0 && topLeftOffset == Offset.zero) {
        return;
      }

      if (ts is TextSpan && ts.children != null) {
        _paintSpecialTextChildren(ts.children, canvas, rect,
            textOffset: textOffset);
      }
      textOffset += ts!.toPlainText().length;
    }
  }

  Offset _findEndOffset(Rect rect, int endTextOffset) {
    final Offset endOffset = getOffsetForCaret(
      TextPosition(offset: endTextOffset, affinity: TextAffinity.upstream),
      rect,
    );
    //overflow
    if (endTextOffset != 0 && endOffset == Offset.zero) {
      return _findEndOffset(rect, endTextOffset - 1);
    }
    return endOffset;
  }

  Offset getOffsetForCaret(TextPosition position, Rect caretPrototype) {
    assert(!debugNeedsLayout);
    return _textPainter.getOffsetForCaret(position, caretPrototype);
  }

  @override
  Rect? describeApproximatePaintClip(RenderObject child) =>
      _hasVisualOverflow ? Offset.zero & size : null;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(ColorProperty('cursorColor', cursorColor));
    properties.add(
        DiagnosticsProperty<ValueNotifier<bool>>('showCursor', showCursor));
    properties.add(IntProperty('maxLines', maxLines));
    properties.add(IntProperty('minLines', minLines));
    properties.add(
        DiagnosticsProperty<bool>('expands', expands, defaultValue: false));
    properties.add(ColorProperty('selectionColor', selectionColor));
    properties.add(DoubleProperty('textScaleFactor', textScaleFactor));
    properties
        .add(DiagnosticsProperty<Locale>('locale', locale, defaultValue: null));
    properties.add(DiagnosticsProperty<TextSelection>('selection', selection));
    properties.add(DiagnosticsProperty<ViewportOffset>('offset', offset));
  }

  @override
  List<DiagnosticsNode> debugDescribeChildren() {
    return <DiagnosticsNode>[
      text!.toDiagnosticsNode(
        name: 'text',
        style: DiagnosticsTreeStyle.transition,
      ),
    ];
  }

//  double _computeIntrinsicHeight(double width) {
//    if (!_canComputeIntrinsics()) {
//      return 0.0;
//    }
//    _computeChildrenHeightWithMinIntrinsics(width);
//    _layoutText(width);
//    return _textPainter.height;
//  }

  @override
  bool get isAttached => attached;

  @override
  TextOverflow get overflow => TextOverflow.visible;

  @override
  bool get softWrap => false;

  @override
  TextPainter get textPainter => _textPainter;

  @override
  double get caretMargin => _caretMargin;

  @override
  bool get isMultiline => _isMultiline;

  @override
  List<ui.TextBox>? get selectionRects => _selectionRects;

  @override
  Offset get effectiveOffset => _effectiveOffset;

  @override
  Widget? get overflowWidget => null;

  @override
  Rect get caretPrototype => _caretPrototype;
}
String textSpanToActualText(InlineSpan textSpan) {
  final StringBuffer buffer = StringBuffer();

  textSpan.visitChildren((InlineSpan span) {

      // ignore: invalid_use_of_protected_member
      span.computeToPlainText(buffer);
    return true;
  });
  return buffer.toString();
}
