## inspired by:
### https://raw.githubusercontent.com/stanfordio/truthbrush/main/truthbrush/api.py

## todo:
## 1. pagination
## 2. authentication
## 3. document all api endpoints




library(httr)
library(tidyverse)

# https://truthsocial.com/api/v2/search?q=trump&resolve=true&limit=20&type=statuses


parse_output <- function(x) {
    x %>%
        discard(is_empty) %>%
        map_if(is.list, list) %>%
        as_tibble()
}

untruth_search <- function(what_are_you_looking_for, search_type = "statuses") {

    heads_up <- add_headers(`User-Agent` = "Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:93.0) Gecko/20100101 Firefox/93.0",
                            Authorization = glue::glue("Bearer {Sys.getenv('truth_social_token')}"),
                            Accept = 'application/json',
                            `Accept-Language` = 'en-US,en;q=0.5',
                            `Accept-Encoding` = "gzip, deflate, br",
                            `Content-Type` = "application/json",
                            Connection = "keep-alive"
    )

    getted = GET("https://truthsocial.com/api/v2/search", heads_up, query = list(resolve= "true", limit = 20, q = what_are_you_looking_for, type = search_type), encode = "json")

    res <- content(getted) %>%
        .[[search_type]] %>%
        map_dfr(parse_output)

    return(res)

}

# debugonce(untruth_search)

# untruth_search("putin")



# https://truthsocial.com/api/v1/accounts/107780257626128497/statuses?exclude_replies=true&with_muted=true



untruth_user_truths <- function(account_id = "107780257626128497") {

    heads_up <- add_headers(`User-Agent` = "Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:93.0) Gecko/20100101 Firefox/93.0",
                            Authorization = glue::glue("Bearer {Sys.getenv('truth_social_token')}"),
                            Accept = 'application/json',
                            `Accept-Language` = 'en-US,en;q=0.5',
                            `Accept-Encoding` = "gzip, deflate, br",
                            `Content-Type` = "application/json",
                            Connection = "keep-alive"
    )

    postedy = GET(glue::glue("https://truthsocial.com/api/v1/accounts/{account_id}/statuses"), heads_up, query = list(exclude_replies= "false"), encode = "json")

    res <- content(postedy) %>%
        map_dfr(parse_output)

    return(res)

}

# debugonce(untruth_user_truths)
# untruth_user_truths()
