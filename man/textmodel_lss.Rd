% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/textmodel.R
\name{textmodel_lss}
\alias{textmodel_lss}
\alias{textmodel_lss.dfm}
\alias{textmodel_lss.fcm}
\title{A word embeddings-based semisupervised model for document scaling}
\usage{
textmodel_lss(x, ...)

\method{textmodel_lss}{dfm}(
  x,
  seeds,
  terms = NULL,
  k = 300,
  slice = NULL,
  weight = "count",
  cache = FALSE,
  simil_method = "cosine",
  engine = c("RSpectra", "irlba", "rsvd"),
  include_data = FALSE,
  verbose = FALSE,
  ...
)

\method{textmodel_lss}{fcm}(
  x,
  seeds,
  terms = NULL,
  w = 50,
  weight = "count",
  cache = FALSE,
  simil_method = "cosine",
  engine = c("rsparse"),
  verbose = FALSE,
  ...
)
}
\arguments{
\item{x}{a dfm or fcm created by \code{\link[quanteda:dfm]{quanteda::dfm()}} or \code{\link[quanteda:fcm]{quanteda::fcm()}}}

\item{...}{additional argument passed to the SVD engine}

\item{seeds}{a character vector, named numeric vector or dictionary that
contains seed words.}

\item{terms}{words weighted as model terms. All the features of
\code{\link[quanteda:dfm]{quanteda::dfm()}} or \code{\link[quanteda:fcm]{quanteda::fcm()}} will be used if not specified.}

\item{k}{the number of singular values requested to the SVD engine. Only used
when \code{x} is a \code{dfm}.}

\item{slice}{a number or indices of the components of word vectors used to
compute similarity; \code{slice < k} to truncate word vectors; useful for diagnosys
and simulation.}

\item{weight}{weighting scheme passed to \code{\link[quanteda:dfm_weight]{quanteda::dfm_weight()}}. Ignored
when \code{engine} is "rsparse".}

\item{cache}{if \code{TRUE}, save result of SVD for next execution with identical
\code{x} and settings. Use the \code{base::options(lss_cache_dir)} to change the
location cache files to be save.}

\item{simil_method}{specifies method to compute similarity between features.
The value is passed to \code{\link[quanteda.textstats:textstat_simil]{quanteda.textstats::textstat_simil()}}, "cosine" is
used otherwise.}

\item{engine}{choose SVD engine between \code{\link[RSpectra:svds]{RSpectra::svds()}}, \code{\link[irlba:irlba]{irlba::irlba()}},
and \code{\link[rsparse:GloVe]{rsparse::GloVe()}}.}

\item{include_data}{if \code{TRUE}, fitted model include the dfm supplied as \code{x}.}

\item{verbose}{show messages if \code{TRUE}.}

\item{w}{the size of word vectors. Only used when \code{x} is a \code{fcm}}
}
\description{
A word embeddings-based semisupervised model for document scaling
}
\examples{
\donttest{
library("quanteda")
con <- url("https://bit.ly/2GZwLcN", "rb")
corp <- readRDS(con)
close(con)
toks <- corpus_reshape(corp, "sentences") \%>\%
        tokens(remove_punct = TRUE) \%>\%
        tokens_remove(stopwords("en")) \%>\%
        tokens_select("^[\\\\p{L}]+$", valuetype = "regex", padding = TRUE)
dfmt <- dfm(toks) \%>\%
        dfm_trim(min_termfreq = 10)

seed <- as.seedwords(data_dictionary_sentiment)

# SVD
lss_svd <- textmodel_lss(dfmt, seed)
summary(lss_svd)

# sentiment model on economy
eco <- head(char_keyness(toks, 'econom*'), 500)
svd_eco <- textmodel_lss(dfmt, seed, terms = eco)

# sentiment model on politics
pol <- head(char_keyness(toks, 'politi*'), 500)
svd_pol <- textmodel_lss(dfmt, seed, terms = pol)

# GloVe
fcmt  <- fcm(toks, context = "window", count = "weighted", weights = 1 / (1:5), tri = TRUE)
lss_glov <- textmodel_lss(fcmt, seed)
summary(lss_glov)
}

}
\references{
Watanabe, Kohei. 2020. "Latent Semantic Scaling: A Semisupervised
Text Analysis Technique for New Domains and Languages", Communication
Methods and Measures. \doi{10.1080/19312458.2020.1832976}.
Watanabe, Kohei. 2017. "Measuring News Bias: Russia's
Official News Agency ITAR-TASS' Coverage of the Ukraine Crisis" European
Journal of Communication. \doi{10.1177/0267323117695735}.
}
