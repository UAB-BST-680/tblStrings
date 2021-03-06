
# Construction ----

new_pointGap <- function(
  point = numeric(),
  lower = numeric(),
  upper = numeric(),
  point_label = "Estimate",
  gap_label = "95% CI",
  brac_left   = "(",
  brac_right  = ")",
  brac_middle = ", ",
  max_decimals = 2,
  big_mark = ",",
  ref_label = 'ref',
  ref_value = 0
) {

  # main arguments
  vctrs::vec_assert(point, numeric())
  vctrs::vec_assert(lower, numeric())
  vctrs::vec_assert(upper, numeric())

  # attributes
  vctrs::vec_assert(point_label,  character())
  vctrs::vec_assert(gap_label,    character())
  vctrs::vec_assert(brac_left,    character())
  vctrs::vec_assert(brac_right,   character())
  vctrs::vec_assert(brac_middle,  character())
  vctrs::vec_assert(big_mark,     character())
  vctrs::vec_assert(ref_label,    character())
  vctrs::vec_assert(max_decimals, numeric())
  vctrs::vec_assert(ref_value,    numeric())

  column_label <- paste0(point_label, ' ', brac_left, gap_label, brac_right)

  # use vctrs package vctr template
  vctrs::new_vctr(
    # main data
    .data = dbl_to_chr(list(point, lower, upper)),
    # S3 class
    class = "tblStrings_pointGap",
    # attributes
    point_label  = point_label,
    gap_label    = gap_label,
    label        = column_label,
    brac_left    = brac_left,
    brac_right   = brac_right,
    brac_middle  = brac_middle,
    max_decimals = max_decimals,
    big_mark     = big_mark,
    ref_label    = ref_label,
    ref_value    = ref_value
  )

}

methods::setOldClass(c("tblStrings_pointGap", "vctrs_vctr"))


#' tblString vectors
#'
#' @description Scientific tables often include values of the form
#'   estimate (lower value, upper value). It is somewhat tedious to work
#'   with these values in R because to do so, one will usually have to
#'   round their numbers evenly, then paste them into whatever bracket
#'   notation is required by their target journal, and then struggle to
#'   work with the resulting character strings because they can't treat
#'   the character values as numeric. `tblString` vectors are meant
#'   to make the  process of developing tables a little less painful.
#'   The five core vector classes implemented are:
#'   - `pointGap`: estimate (interval)
#'   -`numPer`: count (percent)
#'   -`PointErr`: estimate (error) or estimate +/- error
#'   -`fraction`: numerator / denominator
#'   -`pval`: p-values
#' Each class has some helpful properties, e.g.
#'   - automatically round numeric values based on magnitude so that
#'     tabulated values will have more or less the same width.
#'   - contain underlying numeric data that allows you to sort table
#'     values or develop conditional formatting based on vector properties
#'     (e.g., [pg_covers] for `pointGap` values.).
#'
#' @param point numeric vector of point estimates
#'
#' @param lower numeric vector of lower-bounds.
#'
#' @param upper numeric vector of upper-bounds.
#'
#' @param point_label character value describing the point value.
#'
#' @param gap_label character value describing what goes inside of the
#'   gap.
#'
#' @param brac_left character value that will close brackets from the left.
#'
#' @param brac_right character value that will close brackets from the right.
#'
#' @param brac_middle character value that will separate values inside of
#'   the bracket.
#'
#' @param max_decimals an integer value that will determine the maximum
#'   number of decimals in the output. Larger numbers will not use the
#'   maximum number of decimals in order to maintain the same, or at
#'   least similar length as smaller numbers.
#'
#' @param big_mark  a character value used to separate number groups to the
#'   left of the decimal point. See [prettyNum] for more details on this.
#'   Set this input to '' to negate it's effect.
#'
#' @param ref_label a character value used to describe the referent group
#'  (if there is a referent group).
#'
#' @param ref_value a numeric value that is assumed for the referent group.
#'   For example, in logistic regression, the referent group is often
#'   included in results with a referent odds ratio of 1.
#'
#' @return `pointGap` value(s).
#'
#' @note Although `tblStrings` objects contain numeric data, only the first 15
#'   figures in the numeric values are retained. (this is because the data
#'   are converted to a character strings). Accuracy beyond this level
#'   of precision should not be expected, but should also not be needed
#'   in most tabular summaries. The reason `tblStrings` values keep this
#'   structure instead of the more flexible record style format (see
#'   [vctrs::new_rcrd]) is that record style objects are not easily passed
#'   into tabulation functions such as [flextable::flextable] and
#'   [knitr::kable].
#'
#' @seealso as_pointGap
#'
#' @export
#'
#' @examples
#'
#' x <- rnorm(10)
#' y <- x + rnorm(10)
#'
#' model <- lm(y~x)
#'
#' est <- coef(model)['x']
#' ci <- confint(model)['x', ]
#'
#' pointGap(point = est, lower = ci['2.5 %'], upper = ci['97.5 %'])
#'
#'

pointGap <- function(
  point = numeric(),
  lower = numeric(),
  upper = numeric(),
  point_label = "Estimate",
  gap_label = "95% CI",
  brac_left = '(',
  brac_right = ')',
  brac_middle = ', ',
  max_decimals = 2,
  big_mark = ',',
  ref_label = 'ref',
  ref_value = 0
) {
  validate_pointGap(point = point, lower = lower, upper = upper)

  point <- vctrs::vec_cast(point, double())
  lower <- vctrs::vec_cast(lower, double())
  upper <- vctrs::vec_cast(upper, double())

  new_pointGap(
    # main arguments
    point = point,
    lower = lower,
    upper = upper,
    # labels
    point_label = point_label,
    gap_label = gap_label,
    # attributes
    brac_left    = brac_left,
    brac_right   = brac_right,
    brac_middle  = brac_middle,
    max_decimals = max_decimals,
    big_mark     = big_mark,
    ref_label    = ref_label,
    ref_value    = ref_value
  )

}

validate_pointGap <- function(point, lower, upper) {

  stopifnot(
    vctrs::vec_size(point) ==  vctrs::vec_size(lower),
    vctrs::vec_size(point) ==  vctrs::vec_size(upper)
  )

  cp_data <- data.frame(point=point, lower=lower, upper=upper)
  cp_data <- cp_data[stats::complete.cases(cp_data), , drop = FALSE]

  if(nrow(cp_data) > 0){

    if(any(cp_data$lower > cp_data$point)){

      stop("lower values should be less than corresponding point values",
        call. = FALSE)

    }

    if(any(cp_data$upper < cp_data$point)){

      stop("upper values should be greater than corresponding point values",
        call. = FALSE)

    }

  }

}

# Formatting  ----

#' tblString formats
#'
#' @description `tblString`objects are printed with some guiding principles.
#'
#'   - table values should be rounded based on their magnitude,
#'     not based on a uniform number of rounding digits.
#'
#'   - data should be spaced appropriately, not smushed together.
#'
#'
#' @param x an object to print
#'
#' @param ... not currently used
#'
#' @return printed output in the console window
#'
#' @method format tblStrings_pointGap
#'
#' @export
#'
#' @export format.tblStrings_pointGap
#'
#' @examples
#'
#' pointGap(1, 0, 2, max_decimal = 0)
#' pointGap(1, 0, 2, max_decimal = 1)
#' pointGap(1, 0, 2, max_decimal = 2)
#'
#' pointGap(1e4, 1e3, 2e4)
#' pointGap(1e4, 1e3, 2e4, big_mark = '-')
#' pointGap(1e4, 1e3, 2e4, brac_left = '[', brac_right = ']', brac_middle = '-')
#'
format.tblStrings_pointGap <- function(x, ...) {

  .dat <- vctrs::vec_data(x) %>%
    chr_to_dbl()

  ref_indices <- .dat %>%
    lapply(function(.x) .x == ref_value(x)) %>%
    do.call(cbind, .) %>%
    apply(1, all)

  .dat <- .dat %>%
    lapply(tbv_round,
      max_decimals = max_decimals(x),
      big_mark = big_mark(x)
    )

  output <- paste0(
    .dat[[1]], ' ',  brac_left(x),
    .dat[[2]], brac_middle(x),
    .dat[[3]], brac_right(x)
  )

  if(any(ref_indices, na.rm = TRUE)) output[which(ref_indices)] <- paste0(
    ref_value(x), ' ', brac_left(x), ref_label(x), brac_right(x)
  )

  output

}

#' @title Do not use
#'
#' @description these functions are exported in order to ensure consistency
#'  with methods in the `vctrs` package and should not be used directly.
#'
#' @param x an object.
#' @param .x an object.
#' @param to an object.
#' @param y an object.
#' @param op an operation.
#' @param .fn a function.
#' @param ... not used.
#'
#' @method obj_print_data tblStrings_pointGap
#' @export
#' @export obj_print_data.tblStrings_pointGap
obj_print_data.tblStrings_pointGap <- function(x) {
  cat(format(x), sep = "\n")
}

#' @rdname obj_print_data.tblStrings_pointGap
#' @method vec_ptype_abbr tblStrings_pointGap
#' @export
#' @export vec_ptype_abbr.tblStrings_pointGap
vec_ptype_abbr.tblStrings_pointGap <- function(x, ...) {
  "pntGap"
}

# Casting ----

#' @rdname obj_print_data.tblStrings_pointGap
#' @method vec_cast tblStrings_pointGap
#' @export
#' @export vec_cast.tblStrings_pointGap
vec_cast.tblStrings_pointGap <- function(x, to, ...){
  UseMethod("vec_cast.tblStrings_pointGap")
}

#' @method vec_cast.tblStrings_pointGap default
#' @export
vec_cast.tblStrings_pointGap.default <- function(x, to, ...){
  vctrs::vec_default_cast(x, to)
}

#' @method vec_cast.tblStrings_pointGap tblStrings_pointGap
#' @export
vec_cast.tblStrings_pointGap.tblStrings_pointGap <- function(x, to, ...) x

#' @method vec_cast.character tblStrings_pointGap
#' @export
vec_cast.character.tblStrings_pointGap <- function(x, to, ...){
  format(x)
}

#' @method vec_cast.tblStrings_pointGap numeric
#' @export
vec_cast.tblStrings_pointGap.numeric <- function(x, to, ...){
  stopifnot(vctrs::vec_size(x) == 3L)
  pointGap(x[1], x[2], x[3])
}

#' @method vec_cast.tblStrings_pointGap matrix
#' @export
vec_cast.tblStrings_pointGap.matrix <- function(x, to, ...){
  stopifnot(ncol(x) == 3L)
  pointGap(x[, 1], x[, 2], x[, 3])
}

#' @method vec_cast.tblStrings_pointGap list
#' @export
vec_cast.tblStrings_pointGap.list <- function(x, to, ...){
  stopifnot(vctrs::vec_size(x) == 3L)
  pointGap(x[[1]], x[[2]], x[[3]])
}

#' @method vec_cast.tblStrings_pointGap data.frame
#' @export
vec_cast.tblStrings_pointGap.data.frame <- function(x, to, ...){
  vec_cast.tblStrings_pointGap(as.list(x))
}

# Coercion ----

#' @rdname obj_print_data.tblStrings_pointGap
#' @method vec_ptype2 tblStrings_pointGap
#' @export
#' @export vec_ptype2.tblStrings_pointGap
vec_ptype2.tblStrings_pointGap <- function(x, y, ...) {
  UseMethod("vec_ptype2.tblStrings_pointGap", y)
}

#' @method vec_ptype2.tblStrings_pointGap default
#' @export
vec_ptype2.tblStrings_pointGap.default <-
  function(x, y, ..., x_arg = "x", y_arg = "y") {
    vctrs::vec_default_ptype2(x, y, x_arg = x_arg, y_arg = y_arg)
  }

#' @method vec_ptype2.tblStrings_pointGap tblStrings_pointGap
#' @export
vec_ptype2.tblStrings_pointGap.tblStrings_pointGap <- function(x, y, ...)
  new_pointGap(
    brac_left = brac_left(x),
    brac_right = brac_right(x),
    brac_middle = brac_middle(x),
    point_label = point_label(x),
    gap_label = gap_label(x)
  )


# Comparisons ----

#' @rdname obj_print_data.tblStrings_pointGap
#' @method vec_proxy_equal tblStrings_pointGap
#' @export
#' @export vec_proxy_equal.tblStrings_pointGap
vec_proxy_equal.tblStrings_pointGap <- function(x, ...) {

  matrix(
    unlist(chr_to_dbl(vctrs::vec_data(x))),
    nrow = vctrs::vec_size(x),
    byrow = FALSE
  )

}

#' @rdname obj_print_data.tblStrings_pointGap
#' @method vec_proxy_compare tblStrings_pointGap
#' @export
#' @export vec_proxy_compare.tblStrings_pointGap
vec_proxy_compare.tblStrings_pointGap <- function(x, ...) {

  chr_to_dbl(vctrs::vec_data(x))[[1]]

}

# ---- Math

#' @rdname obj_print_data.tblStrings_pointGap
#' @method vec_math tblStrings_pointGap
#' @export
#' @export vec_math.tblStrings_pointGap
vec_math.tblStrings_pointGap <- function(.fn, .x, ...) {

  # get character strings from x
  output <- vctrs::vec_data(.x) %>%
    # convert to numeric data
    chr_to_dbl() %>%
    # apply operations to point/lower/upper, separately
    lapply(vctrs::vec_math_base, .fn = .fn, ...) %>%
    # convert back to point-gap
    as_pointGap() %>%
    # restore the original attributes
    vctrs::vec_restore(to = .x)

  attr(output, 'ref_value') <-
    vctrs::vec_math_base(.fn, .x = ref_value(.x), ...)

  output

}

# Arithmetic ----

#' @rdname obj_print_data.tblStrings_pointGap
#' @method vec_arith tblStrings_pointGap
#' @export
#' @export vec_arith.tblStrings_pointGap
vec_arith.tblStrings_pointGap <- function(op, x, y, ...) {
  UseMethod("vec_arith.tblStrings_pointGap", y)
}

#' @method vec_arith.tblStrings_pointGap default
#' @export
vec_arith.tblStrings_pointGap.default <- function(op, x, y, ...) {
  vctrs::stop_incompatible_op(op, x, y)
}


#' @method vec_arith.tblStrings_pointGap tblStrings_pointGap
#' @export
vec_arith.tblStrings_pointGap.tblStrings_pointGap <- function(op,x,y,...){
  vec_arith.tblStrings_pointGap.default(op, x, y, ...)
}

# Front-end ----

#' Coverage
#'
#' @description Determining whether a gap covers a value. `pg_covers`
#'   will determine whether a gap contains a given `value`. The
#'   negation function, `pg_omits`, will indicate whether a gap does
#'   not contain a given `value`.
#'
#' @param x a `pointGap` object or an object that can be coerced into
#'   a `pointGap` object (see [as_pointGap]).
#'
#' @param value a numeric value that may or may not be contained in
#'   the gap.
#'
#' @param strict_coverage a logical value. If `TRUE`, then strict
#'   coverage is tested. Strict coverage will not be met if `value`
#'   is on the boundary of the gap. If `FALSE`, then a `value`
#'   on the boundary will be considered inside of the gap.
#'
#' @param strict_omission a logical value. If `TRUE`, then strict
#'   omission is tested. Strict omission will not be met if `value`
#'   is on the boundary of the gap. If `FALSE`, then a `value`
#'   on the boundary will be considered inside the gap.
#'
#' @return a `logical` vector the same size as `x` when `x` is converted
#'   to a `pointGap`.
#'
#' @examples
#'
#' p <- pointGap(1, 0, 2)
#'
#' pg_covers(p, value = c(1, 2, 3))
#' pg_omits(p, value = c(1, 2, 3))
#'
#' pg_covers(p, value = c(1, 2, 3), strict_coverage = FALSE)
#' pg_omits(p, value = c(1,2,3), strict_omission = TRUE)
#'
#' @export

pg_covers <- function(x, value, strict_coverage = TRUE){

  if(!is_pointGap(x))
    stop("x must be a vector of type <tblStrings_pointGap>.",
      "\nInstead, it has type <", typeof(x), '>', call. = FALSE)

  vctrs::vec_assert(value, numeric())
  vctrs::vec_assert(strict_coverage, logical())

  .x <- chr_to_dbl(vctrs::vec_data(x))

  # a special case for referent values
  refs <- do.call(cbind, .x) %>%
    apply(1, function(x_row) all(x_row == value))

  output <- if(strict_coverage)
    .x[[2]] <  value & .x[[3]] >  value
  else
    .x[[2]] <= value & .x[[3]] >= value

  if(any(refs, na.rm = TRUE)) output[which(refs)] <- TRUE

  output

}

#' @rdname pg_covers
#' @export
pg_omits <- function(x, value, strict_omission = FALSE){
  !pg_covers(x=x, value=value, strict_coverage = !strict_omission)
}



#' Flip
#'
#' @description Multiplying a point-gap by negative 1 is sometimes
#'   useful, but `pointGap` objects won't let you multiply them like that.
#'   Instead, use `pg_flip()` which will automatically switch the upper and
#'   lower bounds of the gap so it pg_covers the same numbers multiplied
#'   by negative 1.
#'
#' @param x a point gap object (see [pointGap])
#'
#' @return a `pointGap` object with flipped coordinates.
#'
#' @export
#'
#' @examples
#'
#' ptr <- pointGap(2, 1, 4)
#'
#' # negate
#' pg_flip(ptr)
#'
#' # double negate = no change
#' pg_flip(pg_flip(ptr))
#'
#'
pg_flip <- function(x){

  if(!is_pointGap(x)) stop("x must be a vector of type <tblStrings_pointGap>.",
    "\nInstead, it has type <", typeof(x), '>', call. = FALSE)

  .x <- chr_to_dbl(vctrs::vec_data(x))

  list(
    point = -1 * .x[[1]],
    lower = -1 * .x[[3]],
    upper = -1 * .x[[2]]
  ) %>%
    as_pointGap() %>%
    vctrs::vec_restore(to = x)

}

#' tblString casting
#'
#' @description Coerces object(s) into `tblString` types.
#'
#' @param x object to be coerced. Eligible object types are
#'
#'  - `list`
#'  - `matrix`
#'  - `data.frame`
#'
#'  The values of `x` should be ordered in the same manner as the
#'  inputs of the `tblString` type. For example, coercing a list
#'  into a `pointGap` object would require the list to have three
#'  elements in the order of point, lower, and upper values.
#'
#' @return a `tblString` vector.
#'
#' @export
#'
#' @note data in `x` must be numeric.
#'
#' @examples
#'
#' x <- list(c(1,2,3), c(0,1,2), c(2,3,4))
#'
#' as_pointGap(x)
#'
#' x <- as.data.frame(x)
#'
#' as_pointGap(x)
#'
#' x <- c(1L, 0L, 2L)
#'
#' as_pointGap(x)
#'
#' x <- matrix(c(1,2,3,0,1,2,2,3,4), ncol=3)
#'
#' as_pointGap(x)
#'
#'
as_pointGap <- function(x) {
  vec_cast.tblStrings_pointGap(x)
}



#' tblString inheritance
#'
#' @param x an object
#'
#' @return a logical vector of length equal to `x`
#'
#' @export
#'
#' @examples
#'
#' is_pointGap(1)
#'
#' is_pointGap(pointGap(1,0,2))
#'
#'
is_pointGap <- function(x) {
  inherits(x, "tblStrings_pointGap")
}


#' Reference labels
#'
#' @param x a point gap object (see [pointGap])
#'
#' @return a `pointGap` object with reference values replacing values
#'   with all NA.
#'
#' @export
#'
pg_misRef <- function(x){

  if(!is_pointGap(x)) stop("x must be a vector of type <tblStrings_pointGap>.",
    "\nInstead, it has type <", typeof(x), '>', call. = FALSE)

  all_miss_indx <- chr_to_dbl(vctrs::vec_data(x)) %>%
    do.call(cbind, .) %>%
    apply(1, function(row) all(is.na(row)))

  x[all_miss_indx] <- rep(
    pointGap(point = ref_value(x), lower = ref_value(x), upper = ref_value(x)),
    sum(all_miss_indx)
  )

  x

}



# vctr template:

# Construction ---------------------------------------------------------------
# Formatting -----------------------------------------------------------------
# Casting --------------------------------------------------------------------
# Coercion -------------------------------------------------------------------
# Comparisons ----------------------------------------------------------------
# Arithmetic -----------------------------------------------------------------
# Math -----------------------------------------------------------------------
# Front-end ------------------------------------------------------------------
