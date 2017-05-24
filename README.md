# roadoi - Use oaDOI.org with R




[![Build Status](https://travis-ci.org/njahn82/roadoi.svg?branch=master)](https://travis-ci.org/njahn82/roadoi)
[![AppVeyor Build Status](https://ci.appveyor.com/api/projects/status/github/njahn82/roadoi?branch=master&svg=true)](https://ci.appveyor.com/project/njahn82/roadoi)
[![codecov.io](https://codecov.io/github/njahn82/roadoi/coverage.svg?branch=master)](https://codecov.io/github/njahn82/roadoi?branch=master)
[![cran version](http://www.r-pkg.org/badges/version/roadoi)](https://cran.r-project.org/package=roadoi)
[![rstudio mirror downloads](http://cranlogs.r-pkg.org/badges/roadoi)](https://github.com/metacran/cranlogs.app)

roadoi interacts with the [oaDOI API](http://oadoi.org/), a simple interface which links DOIs 
and open access versions of scholarly works. oaDOI powers [unpaywall](http://unpaywall.org/).

API Documentation: <http://oadoi.org/api>

## How do I use it? 

Use the `oadoi_fetch()` function in this package to get open access status
information and full-text links from oaDOI.


```r
roadoi::oadoi_fetch(dois = c("10.1038/ng.3260", "10.1093/nar/gkr1047"), 
                    email = "name@example.com")
#> # A tibble: 2 x 20
#>                                                              `_best_open_url`
#>                                                                         <chr>
#> 1 https://dash.harvard.edu/bitstream/handle/1/25290367/mallet%202015%20polyte
#> 2                                          http://doi.org/10.1093/nar/gkr1047
#> # ... with 19 more variables: `_closed_base_ids` <list>,
#> #   `_green_base_collections` <list>, `_open_base_ids` <list>,
#> #   `_open_urls` <list>, doi <chr>, doi_resolver <chr>, evidence <chr>,
#> #   found_green <lgl>, found_hybrid <lgl>, free_fulltext_url <chr>,
#> #   is_boai_license <lgl>, is_free_to_read <lgl>,
#> #   is_subscription_journal <lgl>, license <chr>, oa_color <chr>,
#> #   oa_color_long <chr>, reported_noncompliant_copies <list>, url <chr>,
#> #   year <int>
```

There are no API restrictions. However, providing an email address is required and a rate limit of 100k is implemented If you need to access more data, use the data dump <https://oadoi.org/api#dataset> instead.

### RStudio Addin

This package also has a RStudio Addin for easily finding free full-texts in RStudio.

![](inst/img/oadoi_addin.gif)

## How do I get it? 

Install and load from [CRAN](https://cran.r-project.org/package=roadoi):


```r
install.packages("roadoi")
library(roadoi)
```

To install the development version, use the [devtools package](https://cran.r-project.org/package=devtools)


```r
devtools::install_github("njahn82/roadoi")
library(roadoi)
```

## Long-Form Documentation including use-case



Open access copies of scholarly publications are sometimes hard to find. Some are published in open access journals. Others are made freely available as preprints before publication, and others are deposited in institutional repositories, digital archives maintained by universities and research institutions. This document guides you to roadoi, a R client that makes it easy to search for these open access copies by interfacing the [oaDOI.org](https://oadoi.org/) service where DOIs are matched with full-text links in open access journals and archives.

### About oaDOI.org

[oaDOI.org](https://oadoi.org/), developed and maintained by the [team of Impactstory](https://oadoi.org/team), is a non-profit service that finds open access copies of scholarly literature simply by looking up a DOI (Digital Object Identifier). It not only returns open access full-text links, but also helpful metadata about the open access status of a publication such as licensing or provenance information.

oaDOI uses different data sources to find open access full-texts including:

- [Crossref](http://www.crossref.org/): a DOI registration agency serving major scholarly publishers.
- [Datacite](https://www.datacite.org/): another DOI registration agency with main focus on research data
- [Directory of Open Access Journals (DOAJ)](https://doaj.org/): a registry of open access journals
- [Bielefeld Academic Search Engine (BASE)](https://www.base-search.net/): an aggregator of various OAI-PMH metadata sources. OAI-PMH is a protocol often used by open access journals and repositories.

### Basic usage

There is one major function to talk with oaDOI.org, `oadoi_fetch()`, taking DOIs and your email address as required arguments.


```r
library(roadoi)
roadoi::oadoi_fetch(dois = c("10.1186/s12864-016-2566-9",
                             "10.1016/j.cognition.2014.07.007"), 
                    email = "name@example.com")
#> # A tibble: 2 x 20
#>                                                              `_best_open_url`
#>                                                                         <chr>
#> 1                                    http://doi.org/10.1186/s12864-016-2566-9
#> 2 http://pubman.mpdl.mpg.de/pubman/item/escidoc:2070098/component/escidoc:207
#> # ... with 19 more variables: `_closed_base_ids` <list>,
#> #   `_green_base_collections` <list>, `_open_base_ids` <list>,
#> #   `_open_urls` <list>, doi <chr>, doi_resolver <chr>, evidence <chr>,
#> #   found_green <lgl>, found_hybrid <lgl>, free_fulltext_url <chr>,
#> #   is_boai_license <lgl>, is_free_to_read <lgl>,
#> #   is_subscription_journal <lgl>, license <chr>, oa_color <chr>,
#> #   oa_color_long <chr>, reported_noncompliant_copies <list>, url <chr>,
#> #   year <int>
```

#### What's returned?

According to the [oaDOI.org API specification](https://oadoi.org/api), the following variables with the following definitions are returned:

* `_best_open_url`: Link to free full-text
* `doi`: the requested DOI
* `doi_resolver`: Possible values:
    + crossref
    + datacite
* `evidence`: A phrase summarizing the step of the open access detection process where the `free_fulltext_url` was found.
* `found_green` :logical indicating whether a self-archived copy in a repository was found
* `found_hybrid`: logical indicating whether an open access
 article was published in a toll-access journal
* `free_fulltext_url`: The URL where we found a free-to-read version of the DOI. None when no free-to-read version was found.
* `green_base_collections`: internal collection ID from the
 Bielefeld Academic Search Engine (BASE)
* `is_boai_license`: TRUE whenever the license indications Creative Commons - Attribution (CC BY), Creative Commons  CC - Universal(CC 0)) or Public Domain were found. These permissive licenses comply with the highly-regarded [BOAI definition of Open access](http://www.budapestopenaccessinitiative.org/)
* `is_free_to_read`: TRUE whenever the free_fulltext_url is not None.
* `is_subscription_journal`: TRUE whenever the journal is not in the Directory of Open Access Journals or DataCite. Please note that there might be a time-lag between the first publication of an open access journal and its registration in the DOAJ.
* `license`: Contains the name of the [Creative Commons license](https://creativecommons.org/) associated with the `free_fulltext_url`, whenever one was found. Example: "cc-by".
* `oa_color`: Possible values:
    + green
    + gold
    + blue
* `_open_base_ids`: ids of oai metadata records with open access
 full-text links collected by the Bielefeld Academic Search Engine (BASE) 
* `_open_urls`: full-text urls
* `reported_noncompliant_copies` links to free full-texts found provided by service often considered as non  compliant with open access policies and guidelines
* `url`: the canonical DOI URL
* `year`: year of publication

#### Any API restrictions?

There are no API restrictions. However, providing your email address when using this client is required by oaDOI.org. Set email address in your `.Rprofile` file with the option `roadoi_email` when you are tired to type in your email address every time you want to call oadDOI.

```r
options(roadoi_email = "name@example.com")
```

#### Keeping track of crawling

To follow your API call, and to estimate the time until completion, use the `.progress` parameter inherited from `plyr` to display a progress bar.


```r
roadoi::oadoi_fetch(dois = c("10.1186/s12864-016-2566-9",
                             "10.1016/j.cognition.2014.07.007"), 
                    email = "name@example.com", 
                    .progress = "text")
#>   |                                                                         |                                                                 |   0%  |                                                                         |================================                                 |  50%  |                                                                         |=================================================================| 100%
#> # A tibble: 2 x 20
#>                                                              `_best_open_url`
#>                                                                         <chr>
#> 1                                    http://doi.org/10.1186/s12864-016-2566-9
#> 2 http://pubman.mpdl.mpg.de/pubman/item/escidoc:2070098/component/escidoc:207
#> # ... with 19 more variables: `_closed_base_ids` <list>,
#> #   `_green_base_collections` <list>, `_open_base_ids` <list>,
#> #   `_open_urls` <list>, doi <chr>, doi_resolver <chr>, evidence <chr>,
#> #   found_green <lgl>, found_hybrid <lgl>, free_fulltext_url <chr>,
#> #   is_boai_license <lgl>, is_free_to_read <lgl>,
#> #   is_subscription_journal <lgl>, license <chr>, oa_color <chr>,
#> #   oa_color_long <chr>, reported_noncompliant_copies <list>, url <chr>,
#> #   year <int>
```

#### Catching errors

oaDOI is a reliable API. However, this client follows [Hadley Wickham's Best practices for writing an API package](https://cran.r-project.org/web/packages/httr/vignettes/api-packages.html) and throws an error when API does not return valid json or is not available. To catch these errors, you may want to use [plyr's `failwith()`](https://www.rdocumentation.org/packages/plyr/versions/1.8.4/topics/failwith) function


```r
random_dois <-  c("ldld", "10.1038/ng.3260", "§dldl  ")
purrr::map_df(random_dois, 
              plyr::failwith(f = function(x) roadoi::oadoi_fetch(x, email ="name@example.com")))
#> # A tibble: 1 x 20
#>                                                              `_best_open_url`
#>                                                                         <chr>
#> 1 https://dash.harvard.edu/bitstream/handle/1/25290367/mallet%202015%20polyte
#> # ... with 19 more variables: `_closed_base_ids` <list>,
#> #   `_green_base_collections` <list>, `_open_base_ids` <list>,
#> #   `_open_urls` <list>, doi <chr>, doi_resolver <chr>, evidence <chr>,
#> #   found_green <lgl>, found_hybrid <lgl>, free_fulltext_url <chr>,
#> #   is_boai_license <lgl>, is_free_to_read <lgl>,
#> #   is_subscription_journal <lgl>, license <chr>, oa_color <chr>,
#> #   oa_color_long <chr>, reported_noncompliant_copies <list>, url <chr>,
#> #   year <int>
```

### Use Case: Studying the compliance with open access policies

An increasing number of universities, research organisations and funders have launched open access policies in recent years. Using roadoi together with other R-packages makes it easy to examine how and to what extent researchers comply with these policies in a reproducible and transparent manner. In particular, the [rcrossref package](https://github.com/ropensci/rcrossref), maintained by rOpenSci, provides many helpful functions for this task.

#### Gathering DOIs representing scholarly publications

DOIs have become essential for referencing scholarly publications, and thus many digital libraries and institutional databases keep track of these persistent identifiers. For the sake of this vignette, instead of starting with a pre-defined set of publications originating from these sources, we simply generate a random sample of 100 DOIs registered with Crossref by using the [rcrossref package](https://github.com/ropensci/rcrossref).


```r
library(dplyr)
library(rcrossref)
# get a random sample of DOIs and metadata describing these works
random_dois <- rcrossref::cr_r(sample = 100) %>%
  rcrossref::cr_works() %>%
  .$data
random_dois
#> # A tibble: 100 x 35
#>                    alternative.id
#>                             <chr>
#>  1     10.1021/cen-v024n009.p1271
#>  2                               
#>  3                               
#>  4                     BF01500284
#>  5                               
#>  6 scientificamerican12081900-363
#>  7                               
#>  8       10.1177/0883911508095517
#>  9                               
#> 10                               
#> # ... with 90 more rows, and 34 more variables: container.title <chr>,
#> #   created <chr>, deposited <chr>, DOI <chr>, funder <list>,
#> #   indexed <chr>, ISBN <chr>, ISSN <chr>, issue <chr>, issued <chr>,
#> #   link <list>, member <chr>, page <chr>, prefix <chr>, publisher <chr>,
#> #   reference.count <chr>, score <chr>, source <chr>, subject <chr>,
#> #   title <chr>, type <chr>, URL <chr>, volume <chr>, assertion <list>,
#> #   author <list>, `clinical-trial-number` <list>, license_date <chr>,
#> #   license_URL <chr>, license_delay.in.days <chr>,
#> #   license_content.version <chr>, subtitle <chr>, update.policy <chr>,
#> #   abstract <chr>, archive <chr>
```

Let's see when these random publications were published


```r
random_dois %>%
  # convert to years
  mutate(issued, issued = lubridate::parse_date_time(issued, c('y', 'ymd', 'ym'))) %>%
  mutate(issued, issued = lubridate::year(issued)) %>%
  group_by(issued) %>%
  summarize(pubs = n()) %>%
  arrange(desc(pubs))
#> # A tibble: 48 x 2
#>    issued  pubs
#>     <dbl> <int>
#>  1     NA    10
#>  2   2006     7
#>  3   2014     7
#>  4   2015     5
#>  5   1997     4
#>  6   2002     4
#>  7   2011     4
#>  8   2003     3
#>  9   2009     3
#> 10   2010     3
#> # ... with 38 more rows
```

and of what type they are


```r
random_dois %>%
  group_by(type) %>%
  summarize(pubs = n()) %>%
  arrange(desc(pubs))
#> # A tibble: 6 x 2
#>                  type  pubs
#>                 <chr> <int>
#> 1     journal-article    73
#> 2        book-chapter    12
#> 3 proceedings-article     8
#> 4           component     5
#> 5             dataset     1
#> 6           monograph     1
```

#### Calling oaDOI.org

Now let's call oaDOI.org


```r
oa_df <- roadoi::oadoi_fetch(dois = random_dois$DOI, email = "name@example.com")
```

and merge the resulting information about open access full-text links with our Crossref metadata-set


```r
my_df <- dplyr::left_join(oa_df, random_dois, by = c("doi" = "DOI"))
my_df
#> # A tibble: 100 x 54
#>                                     `_best_open_url`
#>                                                <chr>
#>  1                                              <NA>
#>  2                                              <NA>
#>  3                                              <NA>
#>  4                                              <NA>
#>  5                                              <NA>
#>  6                                              <NA>
#>  7                                              <NA>
#>  8                                              <NA>
#>  9 http://heart.bmj.com/cgi/content/short/35/12/1280
#> 10                                              <NA>
#> # ... with 90 more rows, and 53 more variables: `_closed_base_ids` <list>,
#> #   `_green_base_collections` <list>, `_open_base_ids` <list>,
#> #   `_open_urls` <list>, doi <chr>, doi_resolver <chr>, evidence <chr>,
#> #   found_green <lgl>, found_hybrid <lgl>, free_fulltext_url <chr>,
#> #   is_boai_license <lgl>, is_free_to_read <lgl>,
#> #   is_subscription_journal <lgl>, license <chr>, oa_color <chr>,
#> #   oa_color_long <chr>, reported_noncompliant_copies <list>, url <chr>,
#> #   year <int>, alternative.id <chr>, container.title <chr>,
#> #   created <chr>, deposited <chr>, funder <list>, indexed <chr>,
#> #   ISBN <chr>, ISSN <chr>, issue <chr>, issued <chr>, link <list>,
#> #   member <chr>, page <chr>, prefix <chr>, publisher <chr>,
#> #   reference.count <chr>, score <chr>, source <chr>, subject <chr>,
#> #   title <chr>, type <chr>, URL <chr>, volume <chr>, assertion <list>,
#> #   author <list>, `clinical-trial-number` <list>, license_date <chr>,
#> #   license_URL <chr>, license_delay.in.days <chr>,
#> #   license_content.version <chr>, subtitle <chr>, update.policy <chr>,
#> #   abstract <chr>, archive <chr>
```

#### Reporting

After gathering the data, reporting with R is very straightforward. You can even generate dynamic reports using [R Markdown](http://rmarkdown.rstudio.com/) and related packages, thus making your study reproducible and transparent for others.

To display how many full-text links were found and which sources were used in a nicely formatted markdown-table using the [`knitr`](https://yihui.name/knitr/)-package:


```r
my_df %>%
  group_by(evidence) %>%
  summarise(Articles = n()) %>%
  mutate(Proportion = Articles / sum(Articles)) %>%
  arrange(desc(Articles)) %>%
  knitr::kable()
```



|evidence                                              | Articles| Proportion|
|:-----------------------------------------------------|--------:|----------:|
|closed                                                |       81|       0.81|
|oa repository (via BASE title and first author match) |        7|       0.07|
|oa journal (via journal title in doaj)                |        5|       0.05|
|oa journal (via publisher name)                       |        3|       0.03|
|oa repository (via BASE doi match)                    |        2|       0.02|
|hybrid (via crossref license)                         |        1|       0.01|
|oa repository (via pmcid lookup)                      |        1|       0.01|

How many of them are provided as green or gold open access?


```r
my_df %>%
  group_by(oa_color) %>%
  summarise(Articles = n()) %>%
  mutate(Proportion = Articles / sum(Articles)) %>%
  arrange(desc(Articles)) %>%
  knitr::kable()
```



|oa_color | Articles| Proportion|
|:--------|--------:|----------:|
|NA       |       81|       0.81|
|gold     |        8|       0.08|
|green    |        8|       0.08|
|blue     |        3|       0.03|

Let's take a closer look and assess how green and gold is distributed over publication types?


```r
my_df %>%
  filter(!evidence == "closed") %>% 
  count(oa_color, type, sort = TRUE) %>% 
  knitr::kable()
```



|oa_color |type                |  n|
|:--------|:-------------------|--:|
|gold     |journal-article     |  5|
|green    |journal-article     |  4|
|blue     |journal-article     |  3|
|gold     |component           |  3|
|green    |proceedings-article |  3|
|green    |monograph           |  1|


## Meta

Please note that this project is released with a [Contributor Code of Conduct](CONDUCT.md). By participating in this project you agree to abide by its terms.

License: MIT

Please use the [issue tracker](https://github.com/njahn82/roadoi/issues) for bug reporting and feature requests.

