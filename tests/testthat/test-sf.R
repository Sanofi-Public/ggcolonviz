skip_if_not_installed("sf")

# ── colon_sf() ────────────────────────────────────────────────────────────────

test_that("colon_sf() returns an sf object", {
    expect_s3_class(colon_sf(), "sf")
})

test_that("colon_sf('standard') has 7 rows (one per colon segment)", {
    expect_equal(nrow(colon_sf("standard")), 7)
})

test_that("colon_sf('sescd') has 5 rows (one per colon segment)", {
    expect_equal(nrow(colon_sf("sescd")), 5)
})

test_that("colon_sf() geometry type is POLYGON", {
    geom_types <- unique(as.character(sf::st_geometry_type(colon_sf())))
    expect_equal(geom_types, "POLYGON")
})

test_that("colon_sf() geometries are all valid", {
    expect_true(all(sf::st_is_valid(colon_sf())))
})

test_that("colon_sf() result has a 'part' column", {
    expect_true("part" %in% names(colon_sf()))
})

test_that("colon_sf() standard parts match expected segment names", {
    expected <- c(
        "Ileum",
        "Cecum",
        "Ascending",
        "Transverse",
        "Descending",
        "Sigmoid",
        "Rectum"
    )
    expect_setequal(colon_sf()$part, expected)
})

test_that("colon_sf('sescd') parts match expected segment names", {
    expected <- c("Ileum", "Transverse", "Rectum", "Left", "Right")
    expect_setequal(colon_sf("sescd")$part, expected)
})

# ── colon_heatmap_grid() ──────────────────────────────────────────────────────

test_that("colon_heatmap_grid() returns an sf object", {
    expect_s3_class(colon_heatmap_grid(grid_res = 20), "sf")
})

test_that("colon_heatmap_grid() result has 'part' column tagging each point", {
    g <- colon_heatmap_grid(grid_res = 20)
    expect_true("part" %in% names(g))
})

test_that("colon_heatmap_grid() result has 'x' and 'y' columns", {
    g <- colon_heatmap_grid(grid_res = 20)
    expect_true(all(c("x", "y") %in% names(g)))
})

test_that("colon_heatmap_grid() points lie within blueprint bounding box", {
    bp <- ggcolonviz:::.get_variant("standard")
    g <- colon_heatmap_grid(grid_res = 20)
    expect_true(all(g$x >= min(bp$dx) - 1e-9))
    expect_true(all(g$x <= max(bp$dx) + 1e-9))
    expect_true(all(g$y >= min(bp$dy) - 1e-9))
    expect_true(all(g$y <= max(bp$dy) + 1e-9))
})

test_that("higher grid_res produces more points than lower grid_res", {
    g_low <- colon_heatmap_grid(grid_res = 10)
    g_high <- colon_heatmap_grid(grid_res = 30)
    expect_gt(nrow(g_high), nrow(g_low))
})

test_that("colon_heatmap_grid() works with sescd variant", {
    expect_no_error({
        g <- colon_heatmap_grid(grid_res = 10, variant = "sescd")
    })
    expect_s3_class(colon_heatmap_grid(grid_res = 10, variant = "sescd"), "sf")
})

test_that("colon_heatmap_grid() returns no points outside colon geometry", {
    g <- colon_heatmap_grid(grid_res = 20)
    colon <- colon_sf()
    # All points should intersect (touch or lie inside) the colon union
    # st_intersects is used rather than st_within because st_intersection
    # can place points exactly on polygon boundaries, which st_within excludes.
    colon_union <- sf::st_union(colon)
    intersect_flags <- sf::st_intersects(g, colon_union, sparse = FALSE)[, 1]
    expect_true(all(intersect_flags))
})
