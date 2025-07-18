
require(quanteda)
require(ggplot2)

toks_test <- readRDS("../data/tokens.RDS")
toks_test <- tokens_remove(toks_test, stopwords())
feat_test <- head(char_context(toks_test, "america*", min_count = 1, p = 0.05), 100)
dict <- dictionary(list("keywords" = c("positive", "bad", "xxxx")))

test_that("textplot_* works with SVD", {
  dfmt <- dfm(toks_test)
  seed <- c("nice*" = 1, "positive*" = 1, "bad*" = -1, "negative*" = -1)
  lss <- textmodel_lss(dfmt, seed, k = 10)
  suppressWarnings({
    is_ggplot(textplot_simil(lss))
  })
  is_ggplot(textplot_terms(lss, highlighted = dict$keywords))
  is_ggplot(textplot_terms(lss, highlighted = dict$keywords, max_words = 2))
  is_ggplot(textplot_terms(lss, highlighted = dict$keywords, max_highlighted = 10))
  is_ggplot(textplot_terms(lss, highlighted = dict$keywords, max_highlighted = 0))
  is_ggplot(textplot_terms(lss, highlighted = dict))
  is_ggplot(textplot_terms(lss, highlighted = character()))
  is_ggplot(textplot_terms(lss))
  is_ggplot(textplot_terms(lss, max_highlighted = 10))
  is_ggplot(textplot_terms(lss, sampling = "relative"))
  is_ggplot(textplot_terms(lss, sampling = "absolute"))
  expect_error(textplot_terms(lss, sampling = "xxx"))

  lss2 <- textmodel_lss(dfmt, seed, terms = feat_test, k = 10)
  is_ggplot(textplot_terms(lss2))
  is_ggplot(textplot_terms(lss2, sampling = "relative"))
  is_ggplot(textplot_terms(lss2, sampling = "absolute"))
  expect_error(textplot_terms(lss2, sampling = "xxx"))
})

test_that("textplot_* works even when frequency and beta do not match (#71)", {
  dfmt <- dfm(toks_test)
  seed <- c("nice*" = 1, "positive*" = 1, "bad*" = -1, "negative*" = -1)
  lss <- textmodel_lss(dfmt, seed, k = 10)
  lss$frequency <- c(lss$frequency, "xxx" = 1, "yyy" = 1) # replicate #71
  is_ggplot(textplot_terms(lss))
})

test_that("textplot_* works with Glove", {
  fcmt <- fcm(toks_test)
  seed <- c("nice*" = 1, "positive*" = 1, "bad*" = -1, "negative*" = -1)
  lss <- textmodel_lss(fcmt, seed, w = 10)
  suppressWarnings({
    is_ggplot(textplot_simil(lss))
  })
  is_ggplot(textplot_terms(lss, highlighted = dict$keywords))
  is_ggplot(textplot_terms(lss, highlighted = dict$keywords, max_words = 2))
  is_ggplot(textplot_terms(lss, highlighted = dict))
  is_ggplot(textplot_terms(lss))
  expect_error(textplot_terms(lss, highlighted = dict, max_words = 100:200),
               "The length of max_words must be 1")

  lss2 <- textmodel_lss(fcmt, seed, terms = feat_test, w = 10)
  is_ggplot(textplot_terms(lss2))
})

test_that("textplot_components() works", {

  seed <- c("nice*" = 1, "positive*" = 1, "bad*" = -1, "negative*" = -1)

  dfmt <- dfm(toks_test)
  lss_svd <- textmodel_lss(dfmt, seed, k = 10)
  fcmt <- fcm(toks_test)
  lss_glove <- textmodel_lss(fcmt, seed, w = 10)

  gg1 <- textplot_components(lss_svd, n = 5)
  expect_equal(length(levels(gg1$data$group)), 5)
  gg2 <- textplot_components(lss_svd, n = 3)
  expect_equal(length(levels(gg2$data$group)), 3)

  is_ggplot(textplot_components(lss_svd, 3))
  is_ggplot(textplot_components(lss_svd, 3, scale = "relative"))
  expect_error(textplot_components(lss_svd, n = c(5, 6)), "The length of n must be 1")
  expect_error(textplot_components(lss_svd, n = 20), "The value of n must be between 2 and 10")
  expect_error(textplot_components(lss_glove), "SVD must be used to generate word vectors")
})

test_that("textplot_* raise error when attributes are missing", {
  dfmt <- dfm(toks_test)
  coef <- rnorm(100)
  names(coef) <- topfeatures(dfmt, 100)
  lss <- as.textmodel_lss(coef)
  suppressWarnings({
    expect_error(textplot_simil(lss),
                 "textplot_simil() does not work with dummy models", fixed = TRUE)
  })
})

test_that("textplot_terms works even when frequency has zeros (#85)", {
  dfmt <- dfm(toks_test) %>%
    dfm_subset(Year > 2000)
  seed <- c("nice*" = 1, "positive*" = 1, "bad*" = -1, "negative*" = -1)
  suppressWarnings(
    lss <- textmodel_lss(dfmt, seed, k = 10)
  )
  expect_true(any(lss$frequency == 0))
  is_ggplot(textplot_terms(lss))
  expect_silent(print(textplot_terms(lss, max_highlighted = 10)))
})

test_that("textplot_terms works with dictionary", {

  dict <- dictionary(list("american" = c("american *"),
                          "president" = c("president *")))
  toks <- tokens_subset(toks_test, Year > 2000) %>%
    tokens_compound(dict)
  dfmt <- dfm(toks)
  seed <- c("nice*" = 1, "positive*" = 1, "bad*" = -1, "negative*" = -1)
  suppressWarnings(
    lss <- textmodel_lss(dfmt, seed, k = 10)
  )
  expect_silent(print(
    textplot_terms(lss, dict, max_highlighted = 10)
  ))
  expect_silent(print(
    textplot_terms(lss, dictionary(list(none = "xxxxx")))
  ))
})

