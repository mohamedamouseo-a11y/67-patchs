# QA Report — V19.3 Date Control Redesign

PATCH_VERSION=V19.3
TARGET=https://sixty-seven.net/admin/
PATCH_APPLIED=YES
BUILD=PASS
STATE_ACTION=ALREADY_AT_V19_3
SCREENSHOTS_COUNT=7
DATA_CHANGED=NO
NATIVE_PICKER_CAPTURE=UNAVAILABLE

> Native browser date popup could not be rendered/captured by the
> browser automation (headless viewport has no OS-native date picker
> chrome; the DOM did not receive a picker element). Screenshots 05/06
> show the date cards inside the open Custom Range panel (clicked/open
> state) instead.

## Per-Screenshot Visual Assessment

### 01-overview-date-closed.png
- Shows: Full Overview — Hero + Date Control (closed) + KPI row + charts.
- Clipping: PASS
- Readability: PASS
- Premium appearance: PASS
- Date picker visibility: PASS (closed pill with current range visible)
- Overlap: PASS
- Hierarchy: PASS

### 02-date-control-closed-closeup.png
- Shows: Date Control closeup — current range (12 Aug 2026 — 10 Sep 2026),
  Today / 7 days / 30 days / Custom buttons + Refresh/Export action icons.
- Clipping: PASS
- Readability: PASS
- Premium appearance: PASS
- Date picker visibility: PASS
- Overlap: PASS
- Hierarchy: PASS

### 03-custom-range-open.png
- Shows: Hero + Custom Range panel fully open (via Custom), panel not clipped,
  displayed correctly above the KPI area.
- Clipping: PASS
- Readability: PASS
- Premium appearance: PASS
- Date picker visibility: PASS
- Overlap: PASS
- Hierarchy: PASS

### 04-custom-range-closeup.png
- Shows: Custom Range panel closeup — title (اختر نطاق التقرير), day count (31 يوم),
  From (من) date 12 Aug 2026, To (إلى) date 10 Sep 2026, Cancel (إلغاء),
  Apply (تطبيق وعرض البيانات) buttons.
- Clipping: PASS
- Readability: PASS
- Premium appearance: PASS
- Date picker visibility: PASS
- Overlap: PASS
- Hierarchy: PASS

### 05-from-date-picker-open.png
- Shows: From date card clicked/open inside the Custom Range panel. Native OS
  date picker popup NOT renderable by automation (see NATIVE_PICKER_CAPTURE).
- Clipping: PASS
- Readability: PASS
- Premium appearance: PASS
- Date picker visibility: PASS (From field visible; picker chrome unavailable)
- Overlap: PASS
- Hierarchy: PASS

### 06-to-date-picker-open.png
- Shows: To date card clicked/open inside the Custom Range panel. Native OS
  date picker popup NOT renderable by automation (see NATIVE_PICKER_CAPTURE).
- Clipping: PASS
- Readability: PASS
- Premium appearance: PASS
- Date picker visibility: PASS (To field visible; picker chrome unavailable)
- Overlap: PASS
- Hierarchy: PASS

### 07-overview-final.png
- Shows: Final Overview after closing the Custom panel — Hero + Date Control
  closed + KPI row. Data unchanged (date range still 12 Aug 2026 — 10 Sep 2026).
- Clipping: PASS
- Readability: PASS
- Premium appearance: PASS
- Date picker visibility: PASS
- Overlap: PASS
- Hierarchy: PASS

## Summary Criteria

PREMIUM_LEVEL=PASS
DATE_VISIBILITY=PASS
HIERARCHY=PASS
CLIPPING=PASS
CONTRAST=PASS
SPACING=PASS
DATE_PICKER_VISIBILITY=PASS
HERO_INTEGRATION=PASS
OVERALL_VISUAL_STATUS=PASS

## Notes
- No data was modified during QA (no Apply / Export / Refresh-data / date change).
- Custom panel is not clipped and overlays the Hero/KPI area correctly.
- Date control integrates cleanly with the Hero (not a pasted-on element).
- Only limitation: native OS date picker popup cannot be captured in headless
  automation — flagged for manual human verification.