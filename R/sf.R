#' @title Colon Geometry as sf Object
#' @description This function converts the colon blueprint into an sf object,
#'  which can be used for spatial operations and visualizations. It groups the
#'  blueprint by colon parts and creates polygon geometries for each part.
#' @param variant A character string specifying the variant of the colon
#'   blueprint to use.
#' @details The resulting sf object contains the geometry of the colon parts,
#'  which can be used for various spatial analyses or visualizations, such as
#'  creating heatmaps or overlaying additional data on the colon structure.
#' @return An sf object with polygon geometries for each part of the colon.
#' @export
colon_sf <- function(variant = "standard") {
    .get_variant(variant) |>
        sf::st_as_sf(coords = c("dx", "dy"), crs = NA) |>
        dplyr::group_by(part) |>
        dplyr::summarise(geometry = sf::st_combine(geometry)) |>
        sf::st_cast("POLYGON") |>
        sf::st_make_valid()
}

#' @title Colon Heatmap Grid
#' @description This function creates a grid of points within the colon geometry,
#'  which can be used to generate heatmaps or other spatial visualizations.
#'  The grid is created by intersecting a dense grid of points with the colon geometry,
#'  resulting in a set of points that lie within the colon structure.
#' @details The function first creates a dense grid of points based on the specified resolution,
#'  then intersects this grid with the colon geometry to retain only the points that
#'  lie within the colon. The resulting sf object contains the coordinates of the points
#'  that can be used for further analysis or visualization.
#' @param grid_res The resolution of the grid, which determines how many points are generated.
#'  A higher resolution will create a denser grid, which can lead to
#'  smoother heatmaps but may also increase computation time.
#' @param variant A character string specifying the variant of the colon
#'   blueprint to use.
#' @return An sf object containing the points that lie within the colon geometry,
#'  which can be used for heatmap generation or other spatial analyses.

#' @export
colon_heatmap_grid <- function(grid_res = 500, variant = "standard") {
    suppressWarnings(
        sf::st_intersection(
            colon_grid(grid_res, variant = variant),
            colon_sf(variant = variant)
        )
    )
}

colon_grid <- function(grid_res = 500, variant = "standard") {
    colon_blueprint <- .get_variant(variant)
    expand.grid(
        x = seq(
            min(colon_blueprint$dx),
            max(colon_blueprint$dx),
            length.out = grid_res
        ),
        y = seq(
            min(colon_blueprint$dy),
            max(colon_blueprint$dy),
            length.out = grid_res
        )
    ) |>
        sf::st_as_sf(
            coords = c("x", "y"),
            crs = NA,
            remove = FALSE
        )
}
