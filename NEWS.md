# ggcolonviz 0.0.6

* Improved robustness of internal stat layers when handling unknown or
  missing input parts.

# ggcolonviz 0.0.4

* `geom_colon()` no longer errors when every input row references an
  unknown `part`; the layer now returns an empty polygon layer.
* `geom_colon_label()` correctly honours a user-mapped `label` aesthetic
  (previously overwritten by the derived label).

# ggcolonviz 0.0.3

* Added a variant registry: `register_colon_variant()` and
  `list_colon_variants()` for user-defined colon layouts alongside the
  built-in `"standard"` and `"sescd"` variants.
* Added a `Basics` vignette walking through the core plotting workflow.
* Expanded the test suite to cover blueprint geometry, `sf` helpers,
  stat layers, and the variant registry.

# ggcolonviz 0.0.2

* Initial release.
* `geom_colon()` and `geom_colon_label()` for visualizing the colon with
  `ggplot2`.
* Blueprint system for configurable colon anatomical layouts, with
  `"standard"` and `"sescd"` variants shipped.
