
test_that("untruth_search() returns a data frame", {
    result <- untruth_search("putin")
    expect_type(result, "list")
})

test_that("untruth_search() works with search_type = hashtags", {
    result <- untruth_search("putin", search_type = "hashtags")
    expect_type(result, "list")
})


