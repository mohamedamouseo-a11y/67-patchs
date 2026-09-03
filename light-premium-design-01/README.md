# 67 Light Premium Design 01

The patch is stored in six ordered parts on branch `store-ui-redesign-concept1`.

Rebuild it before applying:

```bash
cat \
  light-premium-design-01/67-light-premium-design-01.patch.part01 \
  light-premium-design-01/67-light-premium-design-01.patch.part02 \
  light-premium-design-01/67-light-premium-design-01.patch.part03 \
  light-premium-design-01/67-light-premium-design-01.patch.part04 \
  light-premium-design-01/67-light-premium-design-01.patch.part05 \
  light-premium-design-01/67-light-premium-design-01.patch.part06 \
  > /tmp/67-light-premium-design-01.patch
```

Then apply `/tmp/67-light-premium-design-01.patch` to the `QARIX/` project on the feature branch only. Do not merge or push to the project `main` branch.
