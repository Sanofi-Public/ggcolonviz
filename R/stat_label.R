#' @title Colon Label Layer for ggplot2
#' @description This function defines a custom ggplot2 layer that allows users to add
#'   labels to the colon parts based on the predefined blueprint. It takes in aesthetics for x, y, and
#'   part, and uses the StatColonLabels ggproto object to compute the necessary data
#'   for positioning and labeling the colon parts. The resulting layer can be used in
#'   conjunction with other ggplot2 layers to create detailed visualizations of the colon with
#'   informative labels.
#' @details The geom_colon_label function creates a layer that can be added to a ggplot2 plot.
#'   It requires the aesthetics x, y, and part to be specified, which correspond to the position
#'   and the specific part of the colon to be labeled.
#'
#'   The variants can be defined in the colon_variants list, which should contain
#'   different blueprints for the colon geometry.#'
#' @inheritParams ggplot2::layer
#' @param variant A character string specifying the variant of the colon blueprint to use.
#' @param \dots Additional parameters passed to the layer, such as fill, color, size, etc.
#' @return A ggplot2 layer that can be added to a plot to visualize labels
#'  on the colon parts.
#' @export
geom_colon_label <- function(
    mapping = NULL,
    data = NULL,
    show.legend = NA,
    variant = "standard",
    ...
) {
    ggplot2::layer(
        data = data,
        mapping = mapping,
        stat = StatColonLabels,
        geom = "text",
        position = "identity",
        show.legend = show.legend,
        params = list(variant = variant, na.rm = FALSE, ...)
    )
}


StatColonLabels <- ggplot2::ggproto(
    "StatColonLabels",
    ggplot2::Stat,
    required_aes = c("x", "y", "part"),
    compute_panel = function(data, scales, params, variant = "standard") {
        colon_blueprint <- .get_variant(variant)

        rows <- lapply(seq_len(nrow(data)), function(i) {
            row <- data[i, ]
            coords <- colon_blueprint[
                colon_blueprint$part == as.character(row$part),
            ]
            if (nrow(coords) == 0) {
                return(NULL)
            }

            center_x <- (min(coords$dx) + max(coords$dx)) / 2
            center_y <- (min(coords$dy) + max(coords$dy)) / 2

            # Use the mapped label if it exists, otherwise use 'part'
            final_text <- if (!is.null(row$label)) {
                as.character(row$label)
            } else {
                as.character(row$part)
            }

            x_offset <- dplyr::case_when(
                row$part == "Left" ~ 0.5,
                TRUE ~ 0
            )

            y_offset <- dplyr::case_when(
                row$part == "Transverse" ~ 0.4,
                row$part == "Rectum" ~ 0.2,
                row$part == "Cecum" ~ 0.1,
                TRUE ~ 0
            )

            # Rotation: Rotate labels for Ascending and Descending to align with the colon's orientation
            rot_angle <- ifelse(
                row$part %in%
                    c("Ascending", "Descending", "Left", "Right"),
                90,
                0
            )

            data.frame(
                x = row$x + center_x + x_offset,
                y = row$y + center_y + y_offset,
                label = final_text,
                angle = rot_angle,
                row[, setdiff(names(row), c("x", "y", "label")), drop = FALSE],
                row.names = NULL
            )
        })

        final_df <- do.call(rbind, rows)
        if (is.null(final_df)) {
            return(data.frame(
                x = numeric(0),
                y = numeric(0),
                label = character(0),
                angle = numeric(0)
            ))
        }
        final_df
    }
)
