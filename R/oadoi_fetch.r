#' Fetch open access status information and full-text links from oaDOI
#'
#' This is the main function to retrieve comprehensive open acccess status
#' information from the oaDOI service. Please play nice with the API. At the
#' moment only 100k request are allowed per user and day.
#' For more info see \url{https://oadoi.org/api}.
#'
#' @param dois character vector, search by a single DOI or many DOIs.
#'   A rate limit of 100k requests per day is suggested. If you need to access
#'   more data, use the data dump \url{https://oadoi.org/api#dataset} instead.
#' @param email character vector, required! It is strongly encourage to tell
#'   oaDOI your email adress, so that they can track usage and notify you
#'   when something breaks. Set email address in your `.Rprofile` file with
#'   the option `roadoi_email` \code{options(roadoi_email = "name@example.com")}.
#' @param .progress Shows the \code{plyr}-style progress bar.
#'   Options are "none", "text", "tk", "win", and "time".
#'   See \code{\link[plyr]{create_progress_bar}} for details
#'   of each. By default, no progress bar is displayed.
#'
#' @return The result is a tibble with each row representing a publication and
#' and the following columns.
#'
#' \tabular{rll}{
#'  [,1] \tab `_best_open_url`   \tab link to free full-text \cr
#'  [,2] \tab doi                \tab DOI \cr
#'  [,3] \tab doi_resolver       \tab DOI agency \cr
#'  [,4] \tab evidence           \tab A phrase summarizing the step of the
#'  open access detection process where the full-text links were found. \cr
#'  [,5] \tab found_green        \tab logical indicating whether a self-archived
#'  copy in a repository was found \cr
#'  [,6] \tab found_hybrid       \tab logical indicating whether an open access
#'  article was published in a toll-access journal \cr
#'  [,7] \tab free_fulltext_url  \tab URL where the free version was found \cr
#'  [,8] \tab green_base_collections \tab internal collection ID from the
#'  Bielefeld Academic Search Engine (BASE) \cr
#'  [,9] \tab is_boai_license    \tab TRUE whenever the license indications are
#'  Creative Commons - Attribution (CC BY), Creative Commons CC - Universal(CC 0))
#'  or Public Domain. These permissive licenses comply with the
#'  highly-regarded Budapest Open Access Initiative (BOAI) definition of
#'  open access \cr
#'  [,10] \tab is_free_to_read  \tab TRUE if freely available full-text
#'  was found \cr
#'  [,11] \tab is_subscription_journal \tab TRUE if article is published in
#'  toll-access journal \cr
#'  [,12] \tab license          \tab Contains the name of the Creative
#'  Commons license associated with the free_fulltext_url, whenever one
#'  was found. \cr
#'  [,13] \tab oa_color         \tab OA delivered by journal (gold),
#'  by repository (green) or others (blue) \cr
#'  [,14] \tab `_open_base_ids` \tab  ids of oai metadata records with open access
#'  full-text links collected by the Bielefeld Academic Search Engine (BASE) \cr
#'  [,15] \tab `_open_urls`      \tab full-text url \cr
#'  [,16] \tab `reported_noncompliant_copies` \tab links to free full-texts found
#'  provided by service often considered as not open access compliant, e.g.
#'  ResearchGate \cr
#'  [,17] \tab url               \tab the canonical DOI UR \cr
#'  [,18] \tab year              \tab publishing year \cr
#' }
#'
#' The columns  \code{`_open_base_ids`},
#' \code{`_open_urls`}, and \code{`reported_noncompliant_copies`},
#' are list-columns and may have multiple entries.
#'
#' @examples \dontrun{
#' oadoi_fetch("10.1016/j.shpsc.2013.03.020")
#' oadoi_fetch(dois = c("10.1016/j.jbiotec.2010.07.030",
#' "10.1186/1471-2164-11-245"))
#'
#' # you can unnest list-columns with tidyr:
#' tt %>%
#'   tidyr::unnest(open_base_ids)
#' }
#'
#' @export
oadoi_fetch <-
  function(dois = NULL,
           email = getOption("roadoi_email"),
           .progress = "none") {
    # limit
    # input validation
    stopifnot(!is.null(dois))
    email <- val_email(email)
    if (length(dois) > api_limit)
      stop(
        "A rate limit of 100k requests per day is suggested.
        If you need to access tomore data, use the data dump
        https://oadoi.org/api#dataset instead",
        .call = FALSE
      )
    # Call API for every DOI, and return results as tbl_df
    plyr::ldply(dois, oadoi_fetch_, email, .progress = .progress) %>%
      dplyr::as_data_frame()
  }

#' Get open access status information.
#'
#' In general, use \code{\link{oadoi_fetch}} instead. It calls this
#' method, returning open access status information from all your requests.
#'
#' @param doi character vector,a DOI
#' @param email character vector, required! It is strongly encourage to tell
#'   oaDOI your email adress, so that they can track usage and notify you
#'   when something breaks. Set email address in your `.Rprofile` file with
#'   the option `roadoi_email` \code{options(roadoi_email = "name@example.com")}.
#' @return A tibble
#' @examples \dontrun{
#' oadoi_fetch_(doi = c("10.1016/j.jbiotec.2010.07.030"))
#' }
#' @export
oadoi_fetch_ <- function(doi = NULL, email) {
  u <- httr::modify_url(oadoi_baseurl(),
                        query = list(email = email),
                        path = doi)
  # Call oaDOI API
  resp <- httr::GET(u,
                    ua,
                    # be explicit about the API version roadoi has to request
                    add_headers(
                      Accept = paste0("application/x.oadoi.",
                                      oadoi_api_version(), "+json")
                    ), timeout(10))

  # test for valid json
  if (httr::http_type(resp) != "application/json") {
    # test needed because oaDOI throws 505 when non-encoded whitespace
    # is provided by this client
    stop(
      sprintf(
        "Oops, API did not return json after calling '%s':
        check your query - or api.oadoi.org may experience problems",
        doi
      ),
      call. = FALSE
    )
  }

  # warn if nothing could be found and return meaningful message
  if (httr::status_code(resp) != 200) {
    warning(
      sprintf(
        "oaDOI request failed [%s]\n%s",
        httr::status_code(resp),
        httr::content(resp)$message
      ),
      call. = FALSE
    )
  }
  jsonlite::fromJSON(httr::content(resp, "text", encoding = "UTF-8"))$results
}
