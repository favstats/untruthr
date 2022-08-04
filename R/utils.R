parse_output <- function(x) {
    x %>%
        purrr::discard(purrr::is_empty) %>%
        purrr::map_if(is.list, list) %>%
        tibble::as_tibble()
}

null_transform <- function(x) {
    if(length(x) == 0){
        fin <- Inf
    } else if(is.null(x)){
        fin <- Inf
    } else {
        fin <- x
    }

    return(fin)
}


untruth_headers <- function() {
    httr::add_headers(`User-Agent` = "Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:93.0) Gecko/20100101 Firefox/93.0",
                      Authorization = glue::glue("Bearer {Sys.getenv('truth_social_token')}"),
                      Accept = 'application/json',
                      `Content-Type` = "application/json"
    )

}


paginate <- function(base_url, q, res, size, limit = NULL, verbose, search_type = "") {

    heads_up <- untruth_headers()

    set_offset <- 0

    ### paginate
    while(nrow(res) < size){

        # headers(next_page)

        if(search_type %in% c("accounts", "hashtags") | stringr::str_detect(base_url, "followers")){

            set_offset <- set_offset+limit
            new_params <- list(offset = set_offset)

            q <- c(q, new_params)

        } else if(search_type == "statuses" | search_type == ""){

            new_params <- list(max_id = min(res$id))

            q <- c(q, new_params)

        }


        next_page <- httr::GET(glue::glue("{base_url}"), heads_up, query = q, encode = "json")

        header_dat <- ratelimit_check(next_page, glue::glue("{base_url}"), heads_up, q, retry = T)


        res_next <- httr::content(next_page) %>%
            do_if_else(base_url == "https://truthsocial.com/api/v2/search", ~.x[[search_type]], ~.x) %>%
            purrr::map_dfr(parse_output)

        if(all(suppressWarnings(res_next$id %in% res$id)) | nrow(res_next)==0){
            if(verbose){
                print(paste0("Reached end!"))
            }
            break
        }

        res <- dplyr::bind_rows(res, res_next)

        if(verbose){
            print(paste0("N: ", nrow(res), " (R: ", header_dat$ratelimit_perc, ")"))
        }

    }

    return(res)

}



ratelimit_check_int <- function(res) {

    header_dat <- httr::headers(res) %>%
        dplyr::bind_rows()

    header_dat$ratelimit_info <- "all good"

    ratelimit_max <- as.numeric(header_dat[["x-ratelimit-limit"]])
    ratelimit_remaining <- as.numeric(header_dat[["x-ratelimit-remaining"]])
    ratelimit_reset <- header_dat[["x-ratelimit-reset"]] %>% lubridate::ymd_hms()

    header_dat$ratelimit_perc <- paste0(round(100-(ratelimit_remaining/ratelimit_max*100), 2), "%")

    if(null_transform(ratelimit_remaining) <= 50) {
        sleepy_time <- abs(as.numeric(ratelimit_reset - Sys.time(), units = "secs"))

        message(glue::glue("Rate limit is close: sleeping for {sleepy_time} seconds..."))

        header_dat$ratelimit_info <- "retry"

    }

    return(header_dat)
}


untruth_auth_int <- function(CLIENT_ID, CLIENT_SECRET, username, password) {
    if(any(c(CLIENT_ID, CLIENT_SECRET, username, password) %in% "")){
        stop("ERROR: Please set your CLIENT_ID, CLIENT_SECRET, username, password as environment variables.")
    }

    auth_url =  "https://truthsocial.com/oauth/token"

    creds = list(
        client_id = CLIENT_ID,
        client_secret = CLIENT_SECRET,
        grant_type = "password",
        username = username,
        password = password
    )

    res <- httr::POST(auth_url, body = creds, headers = httr::add_headers(`User-Agent` = "Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:93.0) Gecko/20100101 Firefox/93.0"))

    truth_token <- httr::content(res)$access_token

    set_renv(truth_social_token = truth_token)

    message("Your token has been set! You are ready to use untruthr.")

    return(truth_token)

}
