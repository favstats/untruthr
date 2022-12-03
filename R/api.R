## inspired by:
### https://raw.githubusercontent.com/stanfordio/truthbrush/main/truthbrush/api.py

## todo:
## 1. document all api endpoints
## 2. more functionalities (e.g. get truths by date)




# https://truthsocial.com/api/v2/search?q=trump&resolve=true&limit=20&type=statuses





#' Get trending hashtags or truths from Truth Social
#'
#' This function retrieves trending hashtags or truths from Truth Social. The type of content to retrieve is determined by the `type` argument. If the `switch_token` argument is provided, the function will use a randomly selected token from the available tokens.
#'
#' @param type A character string specifying the type of content to retrieve. Valid values are "hashtags" and "truths".
#' @param switch_token A logical value indicating whether to use a randomly selected token from the available tokens `DON'T USE. This is EXPERIMENTAL`.
#' @return A data frame containing the trending hashtags or truths, as well as a timestamp indicating when the data was retrieved.
#' @export
untruth_trends <- function(type = "hashtags", switch_token = NULL) {
    tsta <- Sys.time()
    if (is.null(switch_token)) {
        the_token <<- Sys.getenv('truth_social_token')
    } else {

        available_tokens <<- setup_available_tokens(); all_tokens <<- available_tokens

        the_token <<- sample(setup_available_tokens()$token, 1)
    }
    heads_up <- untruth_headers(the_token)
    type <- dplyr::case_when(type == "hashtags" ~ "trends", type == "truths" ~ "truth/trending/truths")
    req_res <- httr::GET(glue::glue("https://truthsocial.com/api/v1/{type}", type=type), heads_up)
    # ratelimit_check(req_res)
    res <- httr::content(req_res) %>% purrr::map_dfr(parse_output) %>% dplyr::mutate(tstamp = tsta)
    return(res)
}

# debugonce(untruth_trends)



#' Authenticate with Truth Social
#'
#' This function authenticates with Truth Social using the provided client ID, client secret, username, and password. If a valid authentication token is already stored in the `truth_social_token` environment variable, the function will ask if the user wants to refresh the token.
#'
#' @param CLIENT_ID The client ID provided by Truth Social.
#' @param CLIENT_SECRET The client secret provided by Truth Social.
#' @param username The username to use for authentication.
#' @param password The password to use for authentication.
#' @return A character string containing the authentication token.
#' @export
untruth_auth <- function(CLIENT_ID = Sys.getenv("truth_social_client_id"),
                         CLIENT_SECRET = Sys.getenv("truth_social_client_secret"),
                         username = Sys.getenv("truth_social_user"),
                         password = Sys.getenv("truth_social_pw")
) {
    if (Sys.getenv("truth_social_token") != "") {
        out <- tryCatch(
            {
                untruth_trends("truths")
                "no error"
            },
            error = function(cond) {
                print(as.character(cond))
                return("error")
            }
        )
        resp <- readline("'truth_social_token' is already set.\nDo you want to refresh your token anyway? [Y/N]")
        if (resp == "Y") {
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


#' Search for content on Truth Social
#'
#' This function searches for content on Truth Social using the provided query string and search type. The number of results to return is determined by the `limit` argument, and the size of the results pages is determined by the `size` argument. If the `switch_token` argument is provided, the function will use a randomly selected token from the available tokens.
#'
#' @param what_are_you_looking_for A character string specifying the search query.
#' @param search_type A character string specifying the type of content to search for. Valid values are "statuses" and "hashtags".
#' @param limit An integer specifying the maximum number of results to return.
#' @param size An integer specifying the size of the results pages to return.
#' @param verbose A logical value indicating whether to print status messages to the console.
#' @param retry_on_timeout A logical value indicating whether to retry the search if a timeout occurs.
#' @param switch_token A logical value indicating whether to use a randomly selected token from the available tokens `DON'T USE. This is EXPERIMENTAL`.
#' @param monitor A logical value indicating whether to monitor the rate limit status.
#' @param ... Additional arguments to pass to the httr::GET() function.
#' @return A data frame containing the search results.
#' @export
untruth_search <- function(what_are_you_looking_for, search_type = "statuses", limit = 40, size = 80, verbose = T, retry_on_timeout = T, switch_token = NULL, monitor = F, ...) {
    tsta <- Sys.time()
    if (is.null(switch_token)) {
        the_token <<- Sys.getenv('truth_social_token')
    } else {
        the_token <<- sample(setup_available_tokens()$token, 1)
    }
    heads_up <- untruth_headers(the_token)
    # heads_up <- list(untruth_headers(the_token))

    base_url <- "https://truthsocial.com/api/v2/search"
    if (search_type == "statuses") {
        q <- list(limit = limit, q = what_are_you_looking_for, type = search_type, resolve = "true")
    } else {
        q <- list(limit = limit, q = what_are_you_looking_for, type = search_type)
    }
    req_res <- tryCatch(
        {
            httr::GET(base_url, heads_up, query = q, encode = "json", ...)
        },
        error = function(cond) {
            print(as.character(cond))
            return("error")
        }
    )
    header_dat <- ratelimit_check(req_res, base_url, heads_up, q, retry = retry_on_timeout, switch_token = switch_token, monitor = monitor, ...)
    res <- httr::content(req_res)[[search_type]] %>% purrr::map_dfr(parse_output)
    ### paginate
    if (nrow(res) != 0) {
        res <- paginate(base_url, q, res, size, limit, verbose, search_type, switch_token = switch_token, monitor = monitor, ...)
        if (search_type == "hashtags") {
            res$id <- res$url
        }
        res <- dplyr::distinct(res, id, .keep_all = T) %>% dplyr::mutate(tstamp = tsta)
    }
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

#' Retrieve user statuses on Truth Social
#'
#' @param user_handle The user's handle on Truth Social
#' @param account_id The user's account ID on Truth Social
#' @param limit The number of statuses to retrieve
#' @param size The number of statuses per pagination
#' @param verbose Whether to print information about pagination
#' @param retry_on_timeout Whether to retry the request if a timeout occurs
#' @param switch_token Whether to use a different API token for this request
#' @param monitor Whether to monitor the API rate limit
#' @return A data frame containing the statuses
#' @examples
#' untruth_user_statuses("truth_social", account_id = "107780257626128497")
#' untruth_user_statuses("truth_social")
untruth_user_statuses <- function(user_handle = NULL, account_id = NULL, limit = 40, size = 120, verbose = T, retry_on_timeout = T, switch_token = NULL, monitor = F, ...) {

    tsta <- Sys.time()

    if(is.null(account_id)){
        rlang::warn("You didn't specify the user ID. It is suggested that you include the user ID if you call this API many times, the function will lookup the user ID for each pagination. You can lookup user IDs with 'untruth_lookup_users'.",   .frequency = "once", .frequency_id = "24")

        account_id  <- untruth_lookup_users(user_handle)$id
    }

    if(is.null(switch_token)){
        the_token <<- Sys.getenv('truth_social_token')
    } else {

        if(!exists("available_tokens")){
            available_tokens <<- setup_available_tokens(); all_tokens <<- available_tokens
        }


        the_token <<- sample(available_tokens$token, 1)
    }

    heads_up <- untruth_headers(the_token)

    base_url <- glue::glue("https://truthsocial.com/api/v1/accounts/{account_id}/statuses")

    q <- list(exclude_replies= "false", limit = limit)

    req_res = httr::GET(base_url, heads_up, query = q, encode = "json")

    header_dat <- ratelimit_check(req_res, base_url, heads_up, q, retry = retry_on_timeout, switch_token = switch_token, monitor = monitor, ...)

    res <- httr::content(req_res) %>%
        purrr::map_dfr(parse_output)

    ### paginate
    if(nrow(res)!=0){
        res <- paginate(base_url, q, res, size, limit, verbose, switch_token = switch_token, monitor = monitor, ...)


        res <- dplyr::distinct(res, id, .keep_all = T) %>%
            dplyr::mutate(tstamp = tsta)
    }


    return(res)

}

# debugonce(untruth_user_statuses)
# trumpieboy2 <- untruth_user_statuses("realdonaldtrump")



#' Look up a user by their handle
#'
#' This function allows you to look up a user by their handle.
#'
#' @param user_handle The user's handle.
#' @param monitor Whether to monitor the rate limit.
#' @param switch_token Whether to switch the token.
#' @param ... Additional parameters to pass to the `httr::GET` function.
#'
#' @return A data frame containing information about the user.
#'
#' @examples
#' untruth_lookup_users("realdonaldtrump")
untruth_lookup_users <- function(user_handle, monitor = F, switch_token = NULL, ...) {

    tsta <- Sys.time()

    if(is.null(switch_token)){
        the_token <<- Sys.getenv('truth_social_token')
    } else {

        available_tokens <<- setup_available_tokens(); all_tokens <<- available_tokens

        the_token <<- sample(available_tokens$token, 1)
    }

    heads_up <- untruth_headers(the_token)

    base_url <- "https://truthsocial.com/api/v1/accounts/lookup"

    req_res = httr::GET(base_url, heads_up, query = list(acct = user_handle), encode = "json")

    header_dat <- ratelimit_check(req_res, base_url, heads_up, q, retry = T, switch_token = switch_token, monitor = monitor, ...)

    res <- httr::content(req_res) %>%
        purrr::discard(purrr::is_empty) %>%
        dplyr::bind_rows() %>%
        dplyr::mutate(tstamp = tsta)

    return(res)

}

# debugonce(untruth_lookup_users)
# untruth_lookup_users("realdonaldtrump")


#' @title Get suggested users from Truth Social
#' @param maximum Maximum number of suggestions to return
#' @param monitor If `TRUE`, show detailed output of the rate limit status
#' @param switch_token If `TRUE`, use the `switch_token` function to switch to a new token if rate limits are reached
#' @return A data frame of suggested users
#' @export
untruth_suggested_users <- function(maximum = 20, monitor = FALSE, switch_token = NULL, ...) {

    tsta <- Sys.time()

    if(is.null(switch_token)){
        the_token <<- Sys.getenv('truth_social_token')
    } else {

        available_tokens <<- setup_available_tokens(); all_tokens <<- available_tokens

        the_token <<- sample(available_tokens$token, 1)
    }

    heads_up <- untruth_headers(the_token)

    req_res = httr::GET(glue::glue("https://truthsocial.com/api/v2/suggestions?limit={maximum}"), heads_up, encode = "json")

    header_dat <- ratelimit_check(req_res, base_url, heads_up, q, retry = T, switch_token = switch_token, monitor = monitor, ...)

    res <- httr::content(req_res) %>%
        purrr::map_dfr(parse_output) %>%
        tidyr::unnest_wider(account) %>%
        dplyr::mutate(tstamp = tsta)

    return(res)

}





