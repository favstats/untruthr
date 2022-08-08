
<!-- README.md is generated from README.Rmd. Please edit that file -->

# untruthr

<!-- badges: start -->

[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)
[![CRAN
status](https://www.r-pkg.org/badges/version/untruthr)](https://CRAN.R-project.org/package=untruthr)

<!-- badges: end -->

The goal of `untruthr` is to provide access to the social networking
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
## NOTE: Client ID and Client Secret seem to be the same for every single user
set_renv(truth_social_client_id="9X1Fdd-pxNsAgEDNi_SfhJWi8T-vLuV2WVzKIbkTCw4")
set_renv(truth_social_client_secret="ozF8jzI4968oTKFkEnsBC-UbLPCdrSv0MkXGQu2o_-M")
## is that safe? I don't know but I also don't have a social media platform sooo..

## set your user handle and pw here:
set_renv(truth_social_user="YOUR_USER_HANDLE")
set_renv(truth_social_pw="YOUR_PW")
```

Once you are done, run `untruth_auth`.

``` r
untruth_auth()
```

Now you can use `untruthr`. Note: you only need to authenticate once.
You only have to redo this once your token becomes stale, which does not
seem to happen very often. It seems like the token is active for a few
days at least. Will update once I know more.

## Get trending hashtags

``` r
untruth_trends()
#> # A tibble: 25 × 4
#>    name              url                             history tstamp             
#>    <chr>             <chr>                           <list>  <dttm>             
#>  1 news              https://truthsocial.com/tags/n… <list>  2022-08-08 20:26:27
#>  2 BannonTrial       https://truthsocial.com/tags/B… <list>  2022-08-08 20:26:27
#>  3 infor             https://truthsocial.com/tags/i… <list>  2022-08-08 20:26:27
#>  4 dogsoftruthsocial https://truthsocial.com/tags/d… <list>  2022-08-08 20:26:27
#>  5 GasPrices         https://truthsocial.com/tags/G… <list>  2022-08-08 20:26:27
#>  6 dropdisney        https://truthsocial.com/tags/d… <list>  2022-08-08 20:26:27
#>  7 2000mules         https://truthsocial.com/tags/2… <list>  2022-08-08 20:26:27
#>  8 RayEpps           https://truthsocial.com/tags/R… <list>  2022-08-08 20:26:27
#>  9 jan6thcommittee   https://truthsocial.com/tags/j… <list>  2022-08-08 20:26:27
#> 10 justTRUTHit       https://truthsocial.com/tags/j… <list>  2022-08-08 20:26:27
#> # … with 15 more rows
```

## Get trending statuses

``` r
untruth_trends(type = "truths")
#> # A tibble: 6 × 20
#>   id           created_at sensitive spoiler_text visibility language uri   url  
#>   <chr>        <chr>      <lgl>     <chr>        <chr>      <chr>    <chr> <chr>
#> 1 10835247775… 2022-05-2… FALSE     ""           public     en       http… http…
#> 2 10833623672… 2022-05-2… FALSE     ""           public     en       http… http…
#> 3 10835256289… 2022-05-2… FALSE     ""           public     en       http… http…
#> 4 10834414189… 2022-05-2… FALSE     ""           public     en       http… http…
#> 5 10833617688… 2022-05-2… FALSE     ""           public     en       http… http…
#> 6 10834346653… 2022-05-2… FALSE     ""           public     ca       http… http…
#> # … with 12 more variables: replies_count <int>, reblogs_count <int>,
#> #   favourites_count <int>, favourited <lgl>, reblogged <lgl>, muted <lgl>,
#> #   bookmarked <lgl>, content <chr>, account <list>, card <list>,
#> #   media_attachments <list>, tstamp <dttm>
```

## Get statuses from account

In this case we are getting the 40 last “truths” from Donald Trump

``` r
untruth_user_statuses("realdonaldtrump", size = 40)
#> Warning: You didn't specify the user ID. It is suggested that you include the user ID if you call this API many times, the function will lookup the user ID for each pagination. You can lookup user IDs with 'untruth_lookup_users'.
#> This warning is displayed once per session.
#> # A tibble: 40 × 25
#>    id          created_at sensitive spoiler_text visibility language uri   url  
#>    <chr>       <chr>      <lgl>     <chr>        <chr>      <chr>    <chr> <chr>
#>  1 1087853698… 2022-08-0… FALSE     ""           public     en       http… http…
#>  2 1087853438… 2022-08-0… FALSE     ""           public     <NA>     http… http…
#>  3 1087853371… 2022-08-0… FALSE     ""           public     en       http… http…
#>  4 1087853083… 2022-08-0… FALSE     ""           public     en       http… http…
#>  5 1087849402… 2022-08-0… FALSE     ""           public     <NA>     http… http…
#>  6 1087849086… 2022-08-0… FALSE     ""           public     en       http… http…
#>  7 1087840585… 2022-08-0… FALSE     ""           public     en       http… http…
#>  8 1087840132… 2022-08-0… FALSE     ""           public     en       http… http…
#>  9 1087835534… 2022-08-0… FALSE     ""           public     en       http… http…
#> 10 1087835485… 2022-08-0… FALSE     ""           public     en       http… http…
#> # … with 30 more rows, and 17 more variables: replies_count <int>,
#> #   reblogs_count <int>, favourites_count <int>, favourited <lgl>,
#> #   reblogged <lgl>, muted <lgl>, bookmarked <lgl>, content <chr>,
#> #   account <list>, reblog <list>, quote_id <chr>, mentions <list>,
#> #   quote <list>, media_attachments <list>, card <list>, tags <list>,
#> #   tstamp <dttm>
```

## Search for statuses containing keywords

``` r
untruth_search("qanon", search_type = "statuses", size = 40)
#> Rate limit is close: sleeping for 205.881520032883 seconds...
#> [1] "N: 69 (R: 84.67%)"
#> # A tibble: 69 × 28
#>    id          created_at in_reply_to_id in_reply_to_acc… sensitive spoiler_text
#>    <chr>       <chr>      <chr>          <chr>            <lgl>     <chr>       
#>  1 1087506592… 2022-08-0… 1087506420631… 107992062094454… FALSE     ""          
#>  2 1087662589… 2022-08-0… <NA>           <NA>             FALSE     ""          
#>  3 1087664524… 2022-08-0… 1087664405947… 108321964385213… FALSE     ""          
#>  4 1087547114… 2022-08-0… 1087534621106… 107876484215240… FALSE     ""          
#>  5 1087543727… 2022-08-0… <NA>           <NA>             FALSE     ""          
#>  6 1087539119… 2022-08-0… 1087538968798… 107834326941457… FALSE     ""          
#>  7 1087501741… 2022-08-0… <NA>           <NA>             FALSE     ""          
#>  8 1087813294… 2022-08-0… 1087813224513… 108454850265623… FALSE     ""          
#>  9 1087560898… 2022-08-0… 1087560837681… 108540820420969… FALSE     ""          
#> 10 1087502890… 2022-08-0… 1087502844657… 107954795628667… FALSE     ""          
#> # … with 59 more rows, and 22 more variables: visibility <chr>, language <chr>,
#> #   uri <chr>, url <chr>, replies_count <int>, reblogs_count <int>,
#> #   favourites_count <int>, favourited <lgl>, reblogged <lgl>, muted <lgl>,
#> #   bookmarked <lgl>, content <chr>, account <list>, mentions <list>,
#> #   in_reply_to <list>, media_attachments <list>, tags <list>, card <list>,
#> #   quote_id <chr>, quote <list>, poll <list>, tstamp <dttm>
```

## Search for accounts containing keywords

``` r
untruth_search("qanon", search_type = "accounts", size = 40)
#> # A tibble: 40 × 24
#>    id     username acct  display_name locked bot   discoverable group created_at
#>    <chr>  <chr>    <chr> <chr>        <lgl>  <lgl> <lgl>        <lgl> <chr>     
#>  1 10783… Qanon76  Qano… @Q anon76⭐️… FALSE  FALSE TRUE         FALSE 2022-02-2…
#>  2 10824… QAnon20… QAno… QAnon        FALSE  FALSE TRUE         FALSE 2022-05-0…
#>  3 10828… QAnon_A… QAno… QAnon Awake… FALSE  FALSE TRUE         FALSE 2022-05-1…
#>  4 10783… qanon_   qano… q            FALSE  FALSE TRUE         FALSE 2022-02-2…
#>  5 10830… Qanon_M… Qano… Q Tip        FALSE  FALSE TRUE         FALSE 2022-05-1…
#>  6 10828… QAnonPub QAno… QAnon Pub    FALSE  FALSE TRUE         FALSE 2022-05-1…
#>  7 10824… QanonMe… Qano… QanonMemes   FALSE  FALSE TRUE         FALSE 2022-05-0…
#>  8 10825… QAN0NWA… QAN0… QAnon Warri… FALSE  FALSE TRUE         FALSE 2022-05-0…
#>  9 10841… QAnonRe… QAno… Q Reality    FALSE  FALSE TRUE         FALSE 2022-06-0…
#> 10 10839… Qanon2   Qano… QAnon        FALSE  FALSE TRUE         FALSE 2022-05-3…
#> # … with 30 more rows, and 15 more variables: note <chr>, url <chr>,
#> #   avatar <chr>, avatar_static <chr>, header <chr>, header_static <chr>,
#> #   followers_count <int>, following_count <int>, statuses_count <int>,
#> #   last_status_at <chr>, verified <lgl>, location <chr>, website <chr>,
#> #   suspended <lgl>, tstamp <dttm>
```

## Lookup user ids (and other info) about users

``` r
untruth_lookup_users("realdonaldtrump")
#> # A tibble: 1 × 22
#>   id       username acct  display_name locked bot   group created_at note  url  
#>   <chr>    <chr>    <chr> <chr>        <lgl>  <lgl> <lgl> <chr>      <chr> <chr>
#> 1 1077802… realDon… real… Donald J. T… FALSE  FALSE FALSE 2022-02-1… <p>4… http…
#> # … with 12 more variables: avatar <chr>, avatar_static <chr>, header <chr>,
#> #   header_static <chr>, followers_count <int>, following_count <int>,
#> #   statuses_count <int>, last_status_at <chr>, verified <lgl>, location <chr>,
#> #   website <chr>, tstamp <dttm>
```
