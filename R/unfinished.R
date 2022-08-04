untruth_user_followers <- function(user_handle = NULL, account_id = NULL, limit = 40, size = 120, verbose = T, retry_on_timeout = T) {

    if(is.null(account_id)){
        rlang::warn("You didn't specify the user ID. It is suggested that you include the user ID if you call this API many times, the function will lookup the user ID for each pagination. You can lookup user IDs with 'untruth_lookup_users'.",   .frequency = "once", .frequency_id = "24")

        account_id  <- untruth_lookup_users(user_handle)$id
    }

    heads_up <- untruth_headers()

    base_url <- glue::glue("https://truthsocial.com/api/v1/accounts/{account_id}/followers")

    q <- NULL

    req_res = httr::GET(base_url, heads_up, encode = "json")

    header_dat <- ratelimit_check(req_res, base_url, heads_up, retry = retry_on_timeout)

    res <- httr::content(req_res) %>%
        purrr::map_dfr(parse_output)

    ### paginate
    res <- paginate(base_url, q, res, size, limit, verbose = verbose)


    res <- dplyr::distinct(res, id, .keep_all = T)

    return(res)

}

# debugonce(paginate)
# www <- untruth_user_followers("realdonaltrump")
