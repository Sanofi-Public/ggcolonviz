test_that("both built-in variants are present in the registry", {
    expect_true("standard" %in% list_colon_variants())
    expect_true("sescd" %in% list_colon_variants())
})

test_that("standard variant has the 7 expected parts", {
    parts <- unique(ggcolonviz:::.get_variant("standard")$part)
    expected <- c(
        "Ileum",
        "Cecum",
        "Ascending",
        "Transverse",
        "Descending",
        "Sigmoid",
        "Rectum"
    )
    expect_setequal(parts, expected)
})

test_that("sescd variant has the 5 expected parts", {
    parts <- unique(ggcolonviz:::.get_variant("sescd")$part)
    expected <- c("Ileum", "Transverse", "Rectum", "Left", "Right")
    expect_setequal(parts, expected)
})

test_that("standard variant has no NA coordinates", {
    expect_false(anyNA(ggcolonviz:::.get_variant("standard")))
})

test_that("sescd variant has no NA coordinates", {
    expect_false(anyNA(ggcolonviz:::.get_variant("sescd")))
})

test_that("each part in standard has at least 3 coordinate rows", {
    bp <- ggcolonviz:::.get_variant("standard")
    counts <- tapply(bp$part, bp$part, length)
    expect_true(all(counts >= 3))
})

test_that("each part in sescd has at least 3 coordinate rows", {
    bp <- ggcolonviz:::.get_variant("sescd")
    counts <- tapply(bp$part, bp$part, length)
    expect_true(all(counts >= 3))
})

test_that("standard variant data frame has expected column names", {
    expect_named(ggcolonviz:::.get_variant("standard"), c("dx", "dy", "part"))
})

test_that("sescd variant data frame has expected column names", {
    expect_named(ggcolonviz:::.get_variant("sescd"), c("dx", "dy", "part"))
})

test_that("dx and dy columns are numeric in standard", {
    bp <- ggcolonviz:::.get_variant("standard")
    expect_type(bp$dx, "double")
    expect_type(bp$dy, "double")
})

test_that("dx and dy columns are numeric in sescd", {
    bp <- ggcolonviz:::.get_variant("sescd")
    expect_type(bp$dx, "double")
    expect_type(bp$dy, "double")
})
