# taken from here by @mkearney: https://gist.github.com/mkearney/bb2ce47eb635c14d5f99151636e26b21
#' Conditionally apply expressions on a data object
#'
#' @param .data Input data
#' @param condition A logical value to determine whether to use .if or .else
#' @param .if Formula or function to apply to intput data when condition is TRUE
#' @param .else Formula or function to apply to intput data when condition is FALSE
#' @return Output of appropriate .if/.else call
#' @export
#' @importFrom rlang as_closure
do_if_else <- function(.data, condition, .if, .else = identity) {
    if (condition) {
        call <- rlang::as_closure(.if)
    } else {
        call <- rlang::as_closure(.else)
    }
    do.call(call, list(.data))
}
