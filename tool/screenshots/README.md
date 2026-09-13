# Screenshot tool

Renders real app screens headlessly and saves them as PNGs — useful when
there's no device/emulator/browser handy (e.g. an agent sandbox) but you
still want to see what a change actually looks like.

## Run

```sh
flutter pub get   # once, if you haven't
flutter test tool/screenshots/capture_screenshots_test.dart
```

Screenshots land in `/tmp/app_screenshots/<flow>/<n>_<name>.png` by default.
Override the location with `SCREENSHOT_OUT_DIR`.

## Fonts

The default `flutter test` binding has no real fonts (there's no Android/iOS
OS here to supply Roboto), so without extra setup, text and icons render as
solid boxes. This tool loads real font files if it can find them, bundled
with a full Flutter *engine* checkout (not just the `flutter` CLI tarball) —
that's a large download most setups don't have. If yours does, or keeps them
somewhere else, point `SCREENSHOT_FONT_ROOT` / `SCREENSHOT_ICONS_FONT` at:

- `SCREENSHOT_FONT_ROOT` → a Roboto `.ttf` (e.g.
  `<flutter-sdk>/engine/src/flutter/txt/third_party/fonts/Roboto-Regular.ttf`)
- `SCREENSHOT_ICONS_FONT` → a `MaterialIcons-Regular.ttf`

Missing fonts are skipped with a printed warning rather than failing the
run — you still get correct layout/colors, just with tofu boxes for text.

## Adding a new flow

Copy an existing `testWidgets` block in `capture_screenshots_test.dart`.
Seed whatever accounts/transactions you need directly through
`FakeAccountRepository` / `FakeTransactionRepository` (no UI needed for
setup — see `test/domain/fake_*_repository.dart`), then drive the real
screens with `tester.tap` / `tester.enterText`, calling `capture(...)`
wherever you want a frame saved.

## Gotchas this file already works around

- **Real async I/O** (file writes, `path_provider`, image decoding)
  triggered by a widget's fire-and-forget `onPressed` doesn't resolve
  under the test's fake-async clock — `pumpAndSettle()` alone will hang or
  return too early. `settleWithRealIo()` steps out to the real event loop
  (via `tester.runAsync`) a few times to let it actually finish.
- **`image_picker` / `path_provider`** have no platform implementation in
  this headless binding. The tool swaps `ImagePickerPlatform.instance` /
  `PathProviderPlatform.instance` — the officially supported testing seam
  for federated plugins — instead of trying to drive a real camera/gallery
  picker. `fixtures/sample_receipt.png` is what "picking a receipt" returns.

This file is a dev tool, not a test: it has no `expect()`s, only captures
frames. It lives under `tool/`, not `test/`, so a plain `flutter test`
never runs it.
