# Helper: minimal valid blueprint data frame
valid_bp <- function(parts = c("SegA", "SegB")) {
    do.call(
        rbind,
        lapply(parts, function(p) {
            data.frame(
                dx = c(0, 1, 1, 0),
                dy = c(0, 0, 1, 1),
                part = p,
                stringsAsFactors = FALSE
            )
        })
    )
}

# Cleanup helper: remove a test variant if it was registered
remove_variant <- function(name) {
    env <- getFromNamespace(".ggcolonviz_env", "ggcolonviz")
    env$variants[[name]] <- NULL
}

# ── list_colon_variants() ─────────────────────────────────────────────────────

test_that("list_colon_variants() returns a character vector", {
    expect_type(list_colon_variants(), "character")
})

test_that("list_colon_variants() includes built-in variants", {
    v <- list_colon_variants()
    expect_true("standard" %in% v)
    expect_true("sescd" %in% v)
})

# ── register_colon_variant() — happy path ─────────────────────────────────────

test_that("register_colon_variant() returns name invisibly", {
    on.exit(remove_variant("test_happy"), add = TRUE)
    result <- register_colon_variant("test_happy", valid_bp())
    expect_equal(result, "test_happy")
})

test_that("registered variant appears in list_colon_variants()", {
    on.exit(remove_variant("test_list"), add = TRUE)
    register_colon_variant("test_list", valid_bp())
    expect_true("test_list" %in% list_colon_variants())
})

test_that("registered variant is retrievable via .get_variant()", {
    on.exit(remove_variant("test_get"), add = TRUE)
    bp <- valid_bp("MyPart")
    register_colon_variant("test_get", bp)
    retrieved <- ggcolonviz:::.get_variant("test_get")
    expect_equal(nrow(retrieved), nrow(bp))
    expect_true("MyPart" %in% retrieved$part)
})

test_that("registering an existing name overwrites the variant", {
    on.exit(remove_variant("test_overwrite"), add = TRUE)
    register_colon_variant("test_overwrite", valid_bp("Old"))
    register_colon_variant("test_overwrite", valid_bp("New"))
    expect_true("New" %in% ggcolonviz:::.get_variant("test_overwrite")$part)
    expect_false("Old" %in% ggcolonviz:::.get_variant("test_overwrite")$part)
})

test_that("custom variant works with geom_colon()", {
    on.exit(remove_variant("test_geom_colon"), add = TRUE)
    register_colon_variant("test_geom_colon", valid_bp("SegA"))
    df <- data.frame(x = 0, y = 0, part = "SegA")
    p <- ggplot2::ggplot(df, ggplot2::aes(x = x, y = y, part = part)) +
        geom_colon(variant = "test_geom_colon")
    expect_no_error(ggplot2::layer_data(p))
    expect_gt(nrow(ggplot2::layer_data(p)), 0)
})

test_that("custom variant works with geom_colon_label()", {
    on.exit(remove_variant("test_geom_label"), add = TRUE)
    register_colon_variant("test_geom_label", valid_bp("SegA"))
    df <- data.frame(x = 0, y = 0, part = "SegA")
    p <- ggplot2::ggplot(df, ggplot2::aes(x = x, y = y, part = part)) +
        geom_colon_label(variant = "test_geom_label")
    expect_no_error(ggplot2::layer_data(p))
    expect_equal(ggplot2::layer_data(p)$label, "SegA")
})

test_that("custom variant works with colon_sf()", {
    skip_if_not_installed("sf")
    on.exit(remove_variant("test_sf"), add = TRUE)
    register_colon_variant("test_sf", valid_bp(c("SegA", "SegB")))
    result <- colon_sf("test_sf")
    expect_s3_class(result, "sf")
    expect_equal(nrow(result), 2)
})

test_that("custom variant works with colon_heatmap_grid()", {
    skip_if_not_installed("sf")
    on.exit(remove_variant("test_heatmap"), add = TRUE)
    register_colon_variant("test_heatmap", valid_bp("SegA"))
    expect_no_error(colon_heatmap_grid(grid_res = 10, variant = "test_heatmap"))
})

# ── register_colon_variant() — validation errors ──────────────────────────────

test_that("error if name is not a character", {
    expect_error(
        register_colon_variant(123, valid_bp()),
        "single non-empty character"
    )
})

test_that("error if name is empty string", {
    expect_error(
        register_colon_variant("", valid_bp()),
        "single non-empty character"
    )
})

test_that("error if name is length > 1", {
    expect_error(
        register_colon_variant(c("a", "b"), valid_bp()),
        "single non-empty character"
    )
})

test_that("error if data is not a data frame", {
    expect_error(
        register_colon_variant("bad_data", list(dx = 1, dy = 1, part = "x")),
        "must be a data frame"
    )
})

test_that("error if dx column is missing", {
    bad <- valid_bp()
    bad$dx <- NULL
    expect_error(register_colon_variant("bad_cols", bad), "Missing")
})

test_that("error if dy column is missing", {
    bad <- valid_bp()
    bad$dy <- NULL
    expect_error(register_colon_variant("bad_cols", bad), "Missing")
})

test_that("error if part column is missing", {
    bad <- valid_bp()
    bad$part <- NULL
    expect_error(register_colon_variant("bad_cols", bad), "Missing")
})

test_that("error if dx is not numeric", {
    bad <- valid_bp()
    bad$dx <- as.character(bad$dx)
    expect_error(register_colon_variant("bad_numeric", bad), "numeric")
})

test_that("error if dy is not numeric", {
    bad <- valid_bp()
    bad$dy <- as.character(bad$dy)
    expect_error(register_colon_variant("bad_numeric", bad), "numeric")
})

test_that("error if a part has fewer than 3 rows", {
    bad <- data.frame(
        dx = c(0, 1),
        dy = c(0, 1),
        part = "TinyPart",
        stringsAsFactors = FALSE
    )
    expect_error(register_colon_variant("bad_rows", bad), "at least 3 rows")
})

# ── .get_variant() — unknown variant error ────────────────────────────────────

test_that(".get_variant() errors informatively for unknown variant", {
    expect_error(ggcolonviz:::.get_variant("does_not_exist"), "Unknown variant")
})
