## inspired by:
### https://raw.githubusercontent.com/stanfordio/truthbrush/main/truthbrush/api.py

## todo:
## 1. document all api endpoints
## 2. more functionalities (e.g. get truths by date)




# https://truthsocial.com/api/v2/search?q=trump&resolve=true&limit=20&type=statuses






#' @export
untruth_trends <- function(type = "hashtags") {


    tsta <- Sys.time()

    heads_up <- untruth_headers()

    type <- dplyr::case_when(
        type == "hashtags" ~ "trends",
        type == "truths" ~ "truth/trending/truths",
    )

    req_res = httr::GET(glue::glue("https://truthsocial.com/api/v1/{type}"), heads_up)

    # ratelimit_check(req_res)

    res <- httr::content(req_res) %>%
        purrr::map_dfr(parse_output)  %>%
        dplyr::mutate(tstamp = tsta)

    return(res)
}
# debugonce(untruth_trends)



#' @export
untruth_auth <- function(CLIENT_ID = Sys.getenv("truth_social_client_id"),
                         CLIENT_SECRET = Sys.getenv("truth_social_client_secret"),
                         username = Sys.getenv("truth_social_user"),
                         password = Sys.getenv("truth_social_pw")
) {

    if(Sys.getenv("truth_social_token")!=""){

        out <- tryCatch(
            {
                untruth_trends("truths")

                "no error"
            },
            error=function(cond) {
                # message(paste("URL does not seem to exist:", url))
                message("You already set a token but it API calls are not working so it might be stale. Here is the error message:")
                print(as.character(cond))

                # Choose a return value in case of error
                return("error")
            }
        )

        if(out == "error"){
            resp <- readline("Do you want to refresh your token? [Y/N]")
        } else {
            resp <- readline("'truth_social_token' is already set and it still seems to work.\nDo you want to refresh your token anyway? [Y/N]")

        }

        if(resp == "Y"){

            truth_token <- untruth_auth_int(CLIENT_ID, CLIENT_SECRET, username, password)

            return(truth_token)

        } else {
            message("Your token remains the same!")
        }
    } else {

        truth_token <- untruth_auth_int(CLIENT_ID, CLIENT_SECRET, username, password)

        return(truth_token)

    }
}


#' @export
untruth_search <- function(what_are_you_looking_for, search_type = "statuses", limit = 40, size = 80, verbose = T, retry_on_timeout = T) {

    # what_are_you_looking_for <- "putin"

    tsta <- Sys.time()

    heads_up <- untruth_headers()

    base_url <- "https://truthsocial.com/api/v2/search"

    if(search_type == "statuses"){

        q <- list(resolve= "true", limit = limit, q = what_are_you_looking_for, type = search_type)

    } else {

        q <- list(limit = limit, q = what_are_you_looking_for, type = search_type)

    }




    req_res = httr::GET(base_url, heads_up, query = q, encode = "json")

    header_dat <- ratelimit_check(req_res, base_url, heads_up, q, retry = retry_on_timeout)

    res <- httr::content(req_res) %>%
        .[[search_type]] %>%
        purrr::map_dfr(parse_output)


    ### paginate
    res <- paginate(base_url, q, res, size, limit, verbose, search_type)

    if(search_type == "hashtags"){
        res$id <- res$url
    }

    res <- dplyr::distinct(res, id, .keep_all = T) %>%
        dplyr::mutate(tstamp = tsta)

    return(res)

}

# debugonce(paginate)

# yo2 <- untruth_search("trump", search_type = "hashtags", size = 340)

# yo %>%
#     mutate(created_at = lubridate::ymd_hms(created_at)) %>%
#     arrange(created_at) %>%
#     mutate(created_at = lubridate::floor_date(created_at, "day")) %>%
#     count(created_at) %>%
#     ggplot(aes(created_at, n)) +
#     geom_line()


# https://truthsocial.com/api/v1/accounts/107780257626128497/statuses?exclude_replies=true&with_muted=true





# GET("https://truthsocial.com/api/v2/search?q=putin&type=accounts&offset=220", )

#' @export
untruth_user_statuses <- function(user_handle = NULL, account_id = NULL, limit = 40, size = 120, verbose = T, retry_on_timeout = T) {

    tsta <- Sys.time()

    if(is.null(account_id)){
        rlang::warn("You didn't specify the user ID. It is suggested that you include the user ID if you call this API many times, the function will lookup the user ID for each pagination. You can lookup user IDs with 'untruth_lookup_users'.",   .frequency = "once", .frequency_id = "24")

        account_id  <- untruth_lookup_users(user_handle)$id
    }

    heads_up <- untruth_headers()

    base_url <- glue::glue("https://truthsocial.com/api/v1/accounts/{account_id}/statuses")

    q <- list(exclude_replies= "false", limit = limit)

    req_res = httr::GET(base_url, heads_up, query = q, encode = "json")

    header_dat <- ratelimit_check(req_res, base_url, heads_up, q, retry = retry_on_timeout)

    res <- httr::content(req_res) %>%
        purrr::map_dfr(parse_output)

    ### paginate
    res <- paginate(base_url, q, res, size, limit, verbose)


    res <- dplyr::distinct(res, id, .keep_all = T) %>%
        dplyr::mutate(tstamp = tsta)

    return(res)

}

# debugonce(untruth_user_statuses)
# trumpieboy2 <- untruth_user_statuses("realdonaldtrump")



#' @export
untruth_lookup_users <- function(user_handle) {

    tsta <- Sys.time()

    heads_up <- untruth_headers()

    req_res = httr::GET(glue::glue("https://truthsocial.com/api/v1/accounts/lookup"), heads_up, query = list(acct = user_handle), encode = "json")

    header_dat <- ratelimit_check(req_res, base_url, heads_up, q, retry = T)

    res <- httr::content(req_res) %>%
        purrr::discard(purrr::is_empty) %>%
        dplyr::bind_rows() %>%
        dplyr::mutate(tstamp = tsta)

    return(res)

}

# debugonce(untruth_lookup_users)
# untruth_lookup_users("realdonaldtrump")


#' @export
untruth_suggested_users <- function(maximum = 20) {

    tsta <- Sys.time()

    heads_up <- untruth_headers()

    req_res = httr::GET(glue::glue("https://truthsocial.com/api/v2/suggestions?limit={maximum}"), heads_up, encode = "json")

    header_dat <- ratelimit_check(req_res, base_url, heads_up, q, retry = T)

    res <- httr::content(req_res) %>%
        purrr::map_dfr(parse_output) %>%
        tidyr::unnest_wider(account) %>%
        dplyr::mutate(tstamp = tsta)

    return(res)

}





