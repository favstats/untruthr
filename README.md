
<!-- README.md is generated from README.Rmd. Please edit that file -->

# untruthr

<!-- badges: start -->

[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)
[![CRAN
status](https://www.r-pkg.org/badges/version/untruthr)](https://CRAN.R-project.org/package=untruthr)

<!-- badges: end -->

The goal of `untruthr` is to provide a scraper for the social networking
website [Truth Social](https://truthsocial.com/)

## Installation

You can install the development version of `untruthr` like so:

``` r
remotes::install_github("favstats/untruthr")
```

## Example

This is a basic example which shows you how to solve a common problem:

``` r
library(untruthr)
## basic example code
```

## Authentication

Authenticate yourself with `untruth_auth`. Note: you require a Truth
Social account for this.

Set the following environment variables (note it’s best to type this
into your console so you don’t create a script with your valuable login
details):

``` r
set_renv(truth_social_client_id="YOUR_CLIENT_ID")
set_renv(truth_social_client_secret="YOUR_CLIENT_SECRET")
set_renv(truth_social_user="YOUR_USER_HANDLE")
set_renv(truth_social_pw="YOUR_PW")
```

You can find your `client_id` and `client_secret` by checking the
following file (via inspect) once you have logged into Truth Social in
your browser:
<https://truthsocial.com/packs/js/application-e63292e218e83e726270.js>

Once you are done, run `untruth_auth`.

``` r
untruth_auth()
```

Now you can use `untruthr`. Note: you only need to authenticate once.
You only have to redo this once your token becomes stale.

## Get trending hashtags

``` r
untruth_trends()
#> # A tibble: 25 x 3
#>    name                    url                                           history
#>    <chr>                   <chr>                                         <list> 
#>  1 dropdisney              https://truthsocial.com/tags/dropdisney       <list> 
#>  2 RayEpps                 https://truthsocial.com/tags/RayEpps          <list> 
#>  3 Guns                    https://truthsocial.com/tags/Guns             <list> 
#>  4 news                    https://truthsocial.com/tags/news             <list> 
#>  5 jan6thcommittee         https://truthsocial.com/tags/jan6thcommittee  <list> 
#>  6 2000mules               https://truthsocial.com/tags/2000mules        <list> 
#>  7 americathebeautiful     https://truthsocial.com/tags/americathebeaut~ <list> 
#>  8 makesocialmediafunagain https://truthsocial.com/tags/makesocialmedia~ <list> 
#>  9 GasPrices               https://truthsocial.com/tags/GasPrices        <list> 
#> 10 justTRUTHit             https://truthsocial.com/tags/justTRUTHit      <list> 
#> # ... with 15 more rows
```

## Get trending statuses

``` r
untruth_trends(type = "truths")
#> # A tibble: 6 x 19
#>   id           created_at sensitive spoiler_text visibility language uri   url  
#>   <chr>        <chr>      <lgl>     <chr>        <chr>      <chr>    <chr> <chr>
#> 1 10835247775~ 2022-05-2~ FALSE     ""           public     en       http~ http~
#> 2 10833623672~ 2022-05-2~ FALSE     ""           public     en       http~ http~
#> 3 10835256289~ 2022-05-2~ FALSE     ""           public     en       http~ http~
#> 4 10834414189~ 2022-05-2~ FALSE     ""           public     en       http~ http~
#> 5 10833617688~ 2022-05-2~ FALSE     ""           public     en       http~ http~
#> 6 10834346653~ 2022-05-2~ FALSE     ""           public     ca       http~ http~
#> # ... with 11 more variables: replies_count <int>, reblogs_count <int>,
#> #   favourites_count <int>, favourited <lgl>, reblogged <lgl>, muted <lgl>,
#> #   bookmarked <lgl>, content <chr>, account <list>, card <list>,
#> #   media_attachments <list>
```

## Get statuses from account

In this case we are getting the 40 last “truths” from Donald Trump

``` r
untruth_user_statuses("realdonaldtrump", size = 40)
#> Warning: You didn't specify the user ID. It is suggested that you include the
#> user ID if you call this API many times, the function will lookup the user ID
#> for each pagination. You can lookup user IDs with 'untruth_lookup_users'.
#> # A tibble: 40 x 21
#>    id     created_at sensitive spoiler_text visibility uri   url   replies_count
#>    <chr>  <chr>      <lgl>     <chr>        <chr>      <chr> <chr>         <int>
#>  1 10876~ 2022-08-0~ FALSE     ""           public     http~ http~             3
#>  2 10876~ 2022-08-0~ FALSE     ""           public     http~ http~             0
#>  3 10876~ 2022-08-0~ FALSE     ""           public     http~ http~             0
#>  4 10876~ 2022-08-0~ FALSE     ""           public     http~ http~             0
#>  5 10876~ 2022-08-0~ FALSE     ""           public     http~ http~             0
#>  6 10876~ 2022-08-0~ FALSE     ""           public     http~ http~             0
#>  7 10876~ 2022-08-0~ FALSE     ""           public     http~ http~           212
#>  8 10876~ 2022-08-0~ FALSE     ""           public     http~ http~           682
#>  9 10876~ 2022-08-0~ FALSE     ""           public     http~ http~           131
#> 10 10876~ 2022-08-0~ FALSE     ""           public     http~ http~           166
#> # ... with 30 more rows, and 13 more variables: reblogs_count <int>,
#> #   favourites_count <int>, favourited <lgl>, reblogged <lgl>, muted <lgl>,
#> #   bookmarked <lgl>, content <chr>, account <list>, card <list>,
#> #   reblog <list>, language <chr>, media_attachments <list>, mentions <list>
```

## Search for statuses containing keywords

``` r
untruth_search("qanon", search_type = "statuses", size = 40)
#> [1] "N: 74 (R: 3.67%)"
#> # A tibble: 74 x 26
#>    id          created_at in_reply_to_id in_reply_to_acc~ sensitive spoiler_text
#>    <chr>       <chr>      <chr>          <chr>            <lgl>     <chr>       
#>  1 1087506592~ 2022-08-0~ 1087506420631~ 107992062094454~ FALSE     ""          
#>  2 1087547114~ 2022-08-0~ 1087534621106~ 107876484215240~ FALSE     ""          
#>  3 1087543727~ 2022-08-0~ <NA>           <NA>             FALSE     ""          
#>  4 1087547744~ 2022-08-0~ 1087511807885~ 107838120844166~ FALSE     ""          
#>  5 1087539119~ 2022-08-0~ 1087538968798~ 107834326941457~ FALSE     ""          
#>  6 1087501741~ 2022-08-0~ <NA>           <NA>             FALSE     ""          
#>  7 1087502890~ 2022-08-0~ 1087502844657~ 107954795628667~ FALSE     ""          
#>  8 1087560898~ 2022-08-0~ 1087560837681~ 108540820420969~ FALSE     ""          
#>  9 1087480280~ 2022-08-0~ 1087479556724~ 108685529323880~ FALSE     ""          
#> 10 1087540359~ 2022-08-0~ 1087540211607~ 107842364856057~ FALSE     ""          
#> # ... with 64 more rows, and 20 more variables: visibility <chr>,
#> #   language <chr>, uri <chr>, url <chr>, replies_count <int>,
#> #   reblogs_count <int>, favourites_count <int>, favourited <lgl>,
#> #   reblogged <lgl>, muted <lgl>, bookmarked <lgl>, content <chr>,
#> #   account <list>, mentions <list>, in_reply_to <list>,
#> #   media_attachments <list>, tags <list>, card <list>, quote_id <chr>,
#> #   quote <list>
```

## Search for accounts containing keywords

``` r
untruth_search("qanon", search_type = "accounts", size = 40)
#> # A tibble: 40 x 23
#>    id     username acct  display_name locked bot   discoverable group created_at
#>    <chr>  <chr>    <chr> <chr>        <lgl>  <lgl> <lgl>        <lgl> <chr>     
#>  1 10783~ Qanon76  Qano~ "@Q anon76~  FALSE  FALSE TRUE         FALSE 2022-02-2~
#>  2 10824~ QAnon20~ QAno~ "QAnon"      FALSE  FALSE TRUE         FALSE 2022-05-0~
#>  3 10828~ QAnon_A~ QAno~ "QAnon Awak~ FALSE  FALSE TRUE         FALSE 2022-05-1~
#>  4 10783~ qanon_   qano~ "q"          FALSE  FALSE TRUE         FALSE 2022-02-2~
#>  5 10828~ QAnonPub QAno~ "QAnon Pub"  FALSE  FALSE TRUE         FALSE 2022-05-1~
#>  6 10830~ Qanon_M~ Qano~ "Q Tip"      FALSE  FALSE TRUE         FALSE 2022-05-1~
#>  7 10825~ QAN0NWA~ QAN0~ "QAnon Warr~ FALSE  FALSE TRUE         FALSE 2022-05-0~
#>  8 10835~ QAnon_P~ QAno~ "QAnon Patr~ FALSE  FALSE TRUE         FALSE 2022-05-2~
#>  9 10824~ QanonMe~ Qano~ "QanonMemes" FALSE  FALSE TRUE         FALSE 2022-05-0~
#> 10 10839~ Qanon2   Qano~ "QAnon"      FALSE  FALSE TRUE         FALSE 2022-05-3~
#> # ... with 30 more rows, and 14 more variables: note <chr>, url <chr>,
#> #   avatar <chr>, avatar_static <chr>, header <chr>, header_static <chr>,
#> #   followers_count <int>, following_count <int>, statuses_count <int>,
#> #   last_status_at <chr>, verified <lgl>, location <chr>, website <chr>,
#> #   suspended <lgl>
```

## Lookup user ids (and other info) about users

``` r
untruth_lookup_users("realdonaldtrump")
#> # A tibble: 1 x 21
#>   id       username acct  display_name locked bot   group created_at note  url  
#>   <chr>    <chr>    <chr> <chr>        <lgl>  <lgl> <lgl> <chr>      <chr> <chr>
#> 1 1077802~ realDon~ real~ Donald J. T~ FALSE  FALSE FALSE 2022-02-1~ <p>4~ http~
#> # ... with 11 more variables: avatar <chr>, avatar_static <chr>, header <chr>,
#> #   header_static <chr>, followers_count <int>, following_count <int>,
#> #   statuses_count <int>, last_status_at <chr>, verified <lgl>, location <chr>,
#> #   website <chr>
```
