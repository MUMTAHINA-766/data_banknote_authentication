# Homework 3: load public data and create the prescribed analysis splits.
# Run from the folder containing this file: source("HW3-data-setup.R")
# This file prepares data only; write your analysis in separate R scripts.

# Data credits (original data files unchanged):
# Lohweg, V. (2012), Banknote Authentication, UCI Machine Learning Repository.
# https://doi.org/10.24432/C55P57
# Yeh, I. (2007), Concrete Slump Test, UCI Machine Learning Repository.
# https://doi.org/10.24432/C5FG7D
# Both datasets: CC BY 4.0, https://creativecommons.org/licenses/by/4.0/
# This script removes duplicate banknotes, renames columns, and creates splits.

# Require R >= 3.6 and lock the generators as well as the seed so that
# previous session settings cannot change the prescribed training/test rows.
if (getRversion() < "3.6.0") stop("HW3 requires R 3.6.0 or later.")
RNGkind("Mersenne-Twister", "Inversion", "Rejection")

banknotes <- read.csv(
  "data/data_banknote_authentication.txt", header = FALSE,
  col.names = c("variance", "skewness", "kurtosis", "entropy", "class"))
stopifnot(nrow(banknotes) == 1372L, ncol(banknotes) == 5L,
          !anyNA(banknotes), all(banknotes$class %in% c(0, 1)))
# Remove exact duplicates of all five columns before defining any split.
banknotes <- banknotes[!duplicated(banknotes), , drop = FALSE]
banknotes$class <- factor(banknotes$class, levels = c(0, 1))
banknote_predictors <- c("variance", "skewness", "kurtosis", "entropy")

set.seed(2026)
bn_train_rows <- sort(unlist(lapply(levels(banknotes$class), function(g) {
  rows <- which(banknotes$class == g)
  sample(rows, size = floor(0.70 * length(rows)))
})))
bn_train <- banknotes[bn_train_rows, , drop = FALSE]
bn_test <- banknotes[-bn_train_rows, , drop = FALSE]

concrete <- read.csv("data/slump_test.data", check.names = FALSE)
stopifnot(nrow(concrete) == 103L, ncol(concrete) == 11L, !anyNA(concrete))
names(concrete) <- c("id", "cement", "slag", "fly_ash", "water", "sp",
                     "coarse", "fine", "slump", "flow", "strength")
concrete_predictors <- c("cement", "slag", "fly_ash", "water", "sp", "coarse", "fine")
set.seed(2026)
concrete_train_rows <- sort(sample(seq_len(nrow(concrete)),
                                  size = floor(0.70 * nrow(concrete))))
concrete_train <- concrete[concrete_train_rows, , drop = FALSE]
concrete_test <- concrete[-concrete_train_rows, , drop = FALSE]

stopifnot(nrow(banknotes) == 1348L, nrow(bn_train) == 943L, nrow(bn_test) == 405L,
          nrow(concrete_train) == 72L, nrow(concrete_test) == 31L)
cat("Data ready: banknotes", nrow(bn_train), "training /", nrow(bn_test), "test;",
    "concrete", nrow(concrete_train), "training /", nrow(concrete_test), "test.\n")
