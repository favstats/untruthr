
#' @export
untruth_headers <- function(the_token) {

    httr::add_headers(`User-Agent` = "Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:93.0) Gecko/20100101 Firefox/93.0",
                      Authorization = glue::glue("Bearer {the_token}"),
                      Accept = 'application/json',
                      `Content-Type` = "application/json"
    )

}

ratelimit_check <- function(req_res, base_url, heads_up, q = NULL, retry = T, debug = F, switch_token = NULL, monitor) {

    if(!debug){
        header_dat <- ratelimit_check_int(req_res, switch_token)

        if(header_dat$ratelimit_info == "retry" & retry){

            if(is.null(q)){

                req_res = httr::GET(base_url, heads_up, encode = "json")
            } else {

                req_res = httr::GET(base_url, heads_up, query = q, encode = "json")
            }

        }

        if(monitor){
            untruth_monitor(header_dat)
        }

        return(header_dat)
    } else {
        rlang::inform("Debug mode is on.",   .frequency = "regularly", .frequency_id = "2")
    }

}





setup_available_tokens <- function() {


    s <- Sys.getenv()
    available_tokens <<- s[which(str_detect(names(s), "truth_social_token"))] %>% as.character() %>%
        unique() %>%
        set_names(paste0("token", 1:length(.))) %>%
        as.data.frame() %>%
        tibble::rownames_to_column() %>%
        set_names(c("name", "token"))

    return(available_tokens)


}


ratelimit_check_int <- function(res, switch_token = NULL) {

    header_dat <- httr::headers(res) %>%
        dplyr::bind_rows()

    header_dat$ratelimit_info <- "all good"

    ratelimit_max <- as.numeric(header_dat[["x-ratelimit-limit"]])
    ratelimit_remaining <- as.numeric(header_dat[["x-ratelimit-remaining"]])
    ratelimit_reset <- header_dat[["x-ratelimit-reset"]] %>% lubridate::ymd_hms()

    da_sleep <- abs(as.numeric(ratelimit_reset - Sys.time(), units = "secs"))
    if(length(da_sleep)==0) da_sleep <- 0


    perc <- ratelimit_remaining/ratelimit_max*100
    perc_opp <- 100 - perc

    if(length(perc_opp)==0) perc_opp <- 0


    header_dat$ratelimit_perc_raw <- perc_opp
    header_dat$ratelimit_perc <- paste0(format(round(perc_opp, 2)), "%")

    header_dat$token <- the_token



    if(null_transform(ratelimit_remaining) <= 50) {

        if(!is.null(switch_token)){

            print("switch token!")

            # switch_token <- c("yo", "bo", "flo")
            # the_token <- "yo"

            if(length(switch_token)!=1){


                print("more than 1 token!")

                 # header_dat$token <- Sys.getenv("truth_social_token3")
                current_token_pos <<- which(available_tokens$token == header_dat$token)


                if(any(is.null(available_tokens$sleepy_time))){
                    print("QANNY NULL")
                    available_tokens$sleepy_time <- NA
                    available_tokens$ratelimit_perc_raw <- NA

                } else {
                    print("assign sleepy!")
                    available_tokens$sleepy_time[current_token_pos] <- da_sleep
                    available_tokens$ratelimit_perc_raw[current_token_pos] <- perc_opp
                }

                print("int_tokens!")
                int_tokens <<- available_tokens

                # available_tokens <<- available_tokens %>%
                #     filter(ratelimit_perc_raw <= 80)

                # available_tokens$ratelimit_perc_raw[2] <- 39
                # available_tokens$ratelimit_perc_raw[3] <- 99


                take_em <- which(available_tokens$ratelimit_perc_raw <= 80 | is.na(available_tokens$ratelimit_perc_raw ))


                # available_tokens <<- available_tokens[take_em,]

                # cars %>% slice(take_em)

                available_tokens <<- available_tokens %>%
                    slice(take_em)
               print("youve slcied!")

#
#                 if(any(perc_opp<=80)){
#                     print("failswitch?")
#                     available_tokens <<- available_tokens %>%
#                         filter(is.na(ratelimit_perc_raw) | ratelimit_perc_raw <= 80)
#                 }


                message(paste0("Tokens available: ", nrow(available_tokens)))

                available_tokens %>% map(~.x) %>% print()

                if(nrow(available_tokens)<=0){

                    # message("Only 1 token available. Wait for 5 minutes.")
                    message(glue::glue("No token available: sleeping for {60} seconds..."))

                    Sys.sleep(60)
                    the_token <<- sample(switch_token, 1)

                    available_tokens <<- all_tokens

                } else {

                    print("sample from available tokens")
                    print(available_tokens)

                    the_token <<- sample(available_tokens$token, 1)

                }

                # the_token <<- sample(switch_token[the_token != switch_token], 1)

                message("Switched token!")

            } else if(length(switch_token)==1){
                le_slep <- abs(as.numeric(ratelimit_reset - Sys.time(), units = "secs"))

                message(glue::glue("Rate limit is close: sleeping for {le_slep} seconds..."))

                Sys.sleep(le_slep)

                header_dat$ratelimit_info <- "retry"
            }



        } else {
            le_slep <- abs(as.numeric(ratelimit_reset - Sys.time(), units = "secs"))

            message(glue::glue("Rate limit is close: sleeping for {le_slep} seconds..."))

            Sys.sleep(le_slep)

            header_dat$ratelimit_info <- "retry"
        }



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




paginate <- function(base_url, q, res, size, limit = NULL, verbose, search_type = "", switch_token = NULL, monitor, ...) {

    if(is.null(switch_token)){
        the_token <- Sys.getenv('truth_social_token')
    } #else {
        # the_token <- switch_token
    # }


    set_offset <- 0

    ### paginate
    while(nrow(res) < size){

        heads_up <- untruth_headers(the_token)

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

        header_dat <- ratelimit_check(next_page, glue::glue("{base_url}"), heads_up, q, retry = T, switch_token = switch_token, monitor = monitor, ...)

        if(monitor){
            untruth_monitor(header_dat)
        }

        # next_page2 <<- next_page

        # header_dat2 <<- header_dat

        if(any(class(httr::content(next_page)) == "xml_document") | !is.null(httr::content(next_page)$error)){
            if(verbose){
                print(paste0("Returned xml document or error, so maybe end, maybe something else?"))
            }
            break
        }

        res_next <- httr::content(next_page) %>%
            do_if_else(base_url == "https://truthsocial.com/api/v2/search", ~.x[[search_type]], ~.x) %>%
            purrr::map_dfr(parse_output)

        # res_next2 <- res_next

        if(all(suppressWarnings(res_next$id %in% res$id)) | nrow(res_next)==0){
            if(verbose){
                print(paste0("Reached end!"))
            }
            break
        }

        res <- dplyr::bind_rows(res, res_next)

        # res2 <<- res

        if(verbose){
            print(paste0("N: ", nrow(res), " (R: ", header_dat$ratelimit_perc, ")"))
        }

    }

    return(res)

}



untruth_monitor <- function(header_dat) {

    s <- Sys.getenv()
    senvs <- s[which(str_detect(names(s), "truth_social_token"))] %>% as.character() %>%
        unique() %>%
        set_names(paste0("token", 1:length(.)))

    token_name <- names(senvs[senvs == the_token])

    write_lines(header_dat$ratelimit_perc_raw ,paste0(token_name, ".txt"))

    # ratelimit_reset <- header_dat[["x-ratelimit-reset"]] %>% lubridate::ymd_hms()

    # sleepy_time <- abs(as.numeric(ratelimit_reset - Sys.time(), units = "secs"))

    # message(glue::glue("Rate limit is close: sleeping for {sleepy_time} seconds..."))
    #
    # Sys.sleep(sleepy_time)
    #
    # write_c

}


