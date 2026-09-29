# 1. Terminal Ileum
ileum <- data.frame(
    dx = c(-2.75, -1.75, -2, -2.5),
    dy = c(0, 0, 0.5, 0.5),
    part = "Ileum"
)

# 2. Cecum & Ascending (Left Side)
cecum <- data.frame(
    dx = c(-2.5, -3.5, -3.25, -2.75),
    dy = c(0.5, 0.5, 0.0, 0.0),
    part = "Cecum"
)

#3. Ascending (Left Side - Slanted Top)

ascending <- data.frame(
    dx = c(-2.5, -3.5, -3.5, -2.5),
    dy = c(0.5, 0.5, 3.5, 2.75),
    part = "Ascending"
)

# 4. Transverse (Fixed Alignment - 102 points total)
tx_top <- seq(-3.5, 0.5, length.out = 50)
tx_bot <- seq(-0.5, -2.5, length.out = 50)

ty_top <- 3.5 +
    (4.5 - 3.5) * seq(0, 1, length.out = 50) +
    sin(seq(0, pi, length.out = 50)) * 0.6

ty_bot <- seq(3.7, 2.75, length.out = 50) +
    sin(seq(0, pi, length.out = 50)) * 0.6


transverse <- data.frame(
    dx = c(tx_top, 0.5, -0.5, tx_bot),
    dy = c(ty_top, 4.5, 3.7, ty_bot),
    part = "Transverse"
)

# 5. Descending (Right Side - Slanted Top)
descending <- data.frame(
    dx = c(-0.5, 0.5, 0.5, -0.5),
    dy = c(3.7, 4.5, 1.0, 1.0),
    part = "Descending"
)

# 6. Sigmoid & Rectum (Right Side)
sigmoid <- data.frame(
    dx = c(-1.5, 0.5, 0.5, -1.5),
    dy = c(1, 1, 0, 0),
    part = "Sigmoid"
)
rectum <- data.frame(
    dx = c(-1.5, -0.5, -0.75, -1.25),
    dy = c(0, 0, -1, -1),
    part = "Rectum"
)

left_side_merged <- data.frame(
    dx = c(-0.5, 0.5, 0.5, -1.5, -1.5, -0.5, -0.5), # Vertical walls at -0.5 and 0.5
    dy = c(3.7, 4.5, 0.0, 0.0, 1.0, 1.0, 3.7), # Added the 4.5 top-right and 3.7 top-left
    part = "Left"
)

right_side_merged <- data.frame(
    dx = c(-3.25, -3.5, -3.5, -2.50, -2.5, -2.75),
    dy = c(0.00, 0.5, 3.5, 2.75, 0.5, 0.00),
    part = "Right"
)

# Internal environment that holds all registered variants
.ggcolonviz_env <- new.env(parent = emptyenv())

.ggcolonviz_env$variants <- list(
    standard = rbind(
        ileum,
        cecum,
        ascending,
        transverse,
        descending,
        sigmoid,
        rectum
    ),
    sescd = rbind(
        ileum,
        transverse,
        rectum,
        left_side_merged,
        right_side_merged
    )
)
