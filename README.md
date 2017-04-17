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
roadoi::oadoi_fetch(dois = c("10.1038/ng.3260", "10.1093/nar/gkr1047"))
#> # A tibble: 2 × 16
#>                                      `_best_open_url` `_closed_base_ids`
#>                                                 <chr>             <list>
#> 1 http://nrs.harvard.edu/urn-3:HUL.InstRepos:25290367          <chr [1]>
#> 2                  http://doi.org/10.1093/nar/gkr1047         <list [0]>
#> # ... with 14 more variables: `_closed_urls` <list>,
#> #   `_open_base_ids` <list>, `_open_urls` <list>, doi <chr>,
#> #   doi_resolver <chr>, evidence <chr>, free_fulltext_url <chr>,
#> #   is_boai_license <lgl>, is_free_to_read <lgl>,
#> #   is_subscription_journal <lgl>, license <chr>, oa_color <chr>,
#> #   url <chr>, year <int>
```

There are no API restrictions. However, a rate limit of 100k is implemented. If you need to access more data, use the data dump <https://oadoi.org/api#dataset> instead.

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

There is one major function to talk with oaDOI.org, `oadoi_fetch()`.


```r
library(roadoi)
roadoi::oadoi_fetch(dois = c("10.1186/s12864-016-2566-9", "10.1016/j.cognition.2014.07.007"))
#> # A tibble: 2 × 16
#>                                       `_best_open_url` `_closed_base_ids`
#>                                                  <chr>             <list>
#> 1             http://doi.org/10.1186/s12864-016-2566-9         <list [0]>
#> 2 http://hdl.handle.net/11858/00-001M-0000-0024-2A9E-8          <chr [1]>
#> # ... with 14 more variables: `_closed_urls` <list>,
#> #   `_open_base_ids` <list>, `_open_urls` <list>, doi <chr>,
#> #   doi_resolver <chr>, evidence <chr>, free_fulltext_url <chr>,
#> #   is_boai_license <lgl>, is_free_to_read <lgl>,
#> #   is_subscription_journal <lgl>, license <chr>, oa_color <chr>,
#> #   url <chr>, year <int>
```

According to the [oaDOI.org API specification](https://oadoi.org/api), the following variables with the following definitions are returned:

* `_best_open_url`: Link to free full-text
* `_closed_base_ids`: Ids of oai metadata records with closed access full-text links collected by the [Bielefeld Academic Search Engine (BASE)](https://www.base-search.net/) 
* `_open_base_ids`: Ids of oai metadata records with open access full-text links collected by the [Bielefeld Academic Search Engine (BASE)](https://www.base-search.net/)
* `_open_urls`: full-text url
* `doi`: the requested DOI
* `doi_resolver`: Possible values:
    + crossref
    + datacite
* `evidence`: A phrase summarizing the step of the open access detection process where the `free_fulltext_url` was found.
* `free_fulltext_url`: The URL where we found a free-to-read version of the DOI. None when no free-to-read version was found.
* `is_boai_license`: TRUE whenever the license indications Creative Commons - Attribution (CC BY), Creative Commons  CC - Universal(CC 0)) or Public Domain were found. These permissive licenses comply with the highly-regarded [BOAI definition of Open access](http://www.budapestopenaccessinitiative.org/)
* `is_free_to_read`: TRUE whenever the free_fulltext_url is not None.
* `is_subscription_journal`: TRUE whenever the journal is not in the Directory of Open Access Journals or DataCite. Please note that there might be a time-lag between the first publication of an open access journal and its registration in the DOAJ.
* `license`: Contains the name of the [Creative Commons license](https://creativecommons.org/) associated with the `free_fulltext_url`, whenever one was found. Example: "cc-by".
* `oa_color`: Possible values:
    + green
    + gold
* `url`: the canonical DOI URL
* `year`: year of publication

Providing your email address when using this client is highly appreciated by oaDOI.org. It not only helps the maintainer of oaDOI.org, the non-profit [Impactstory](https://impactstory.org/), to inform you when something breaks, but also to demonstrate API usage to its funders. Simply use the `email` parameter for this purpose:


```r
roadoi::oadoi_fetch("10.1186/s12864-016-2566-9", email = "name@example.com")
#> # A tibble: 1 × 16
#>                           `_best_open_url` `_closed_base_ids`
#>                                      <chr>             <list>
#> 1 http://doi.org/10.1186/s12864-016-2566-9         <list [0]>
#> # ... with 14 more variables: `_closed_urls` <list>,
#> #   `_open_base_ids` <list>, `_open_urls` <list>, doi <chr>,
#> #   doi_resolver <chr>, evidence <chr>, free_fulltext_url <chr>,
#> #   is_boai_license <lgl>, is_free_to_read <lgl>,
#> #   is_subscription_journal <lgl>, license <chr>, oa_color <chr>,
#> #   url <chr>, year <int>
```

To follow your API call, and to estimate the time until completion, use the `.progress` parameter inherited from plyr to display a progress bar.


```r
roadoi::oadoi_fetch(dois = c("10.1186/s12864-016-2566-9", "10.1016/j.cognition.2014.07.007"), .progress = "text")
#>   |                                                                         |                                                                 |   0%  |                                                                         |================================                                 |  50%  |                                                                         |=================================================================| 100%
#> # A tibble: 2 × 16
#>                                       `_best_open_url` `_closed_base_ids`
#>                                                  <chr>             <list>
#> 1             http://doi.org/10.1186/s12864-016-2566-9         <list [0]>
#> 2 http://hdl.handle.net/11858/00-001M-0000-0024-2A9E-8          <chr [1]>
#> # ... with 14 more variables: `_closed_urls` <list>,
#> #   `_open_base_ids` <list>, `_open_urls` <list>, doi <chr>,
#> #   doi_resolver <chr>, evidence <chr>, free_fulltext_url <chr>,
#> #   is_boai_license <lgl>, is_free_to_read <lgl>,
#> #   is_subscription_journal <lgl>, license <chr>, oa_color <chr>,
#> #   url <chr>, year <int>
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
#> # A tibble: 100 × 33
#>       alternative.id                           container.title    created
#>                <chr>                                     <chr>      <chr>
#> 1                                                              2014-03-14
#> 2                    Journal of Physics C: Solid State Physics 2002-07-26
#> 3   0038109888900932                Solid State Communications 2002-10-18
#> 4                            The American Mathematical Monthly 2006-04-23
#> 5  S1353113198901511     Journal of Clinical Forensic Medicine 2004-08-05
#> 6                          Clinical and Experimental Optometry 2009-04-23
#> 7   0148619583900346         Journal of Economics and Business 2002-10-11
#> 8                                     Southern Medical Journal 2011-04-06
#> 9                                                              2007-05-02
#> 10        BF00157945                                GeoJournal 2004-09-25
#> # ... with 90 more rows, and 30 more variables: deposited <chr>,
#> #   DOI <chr>, funder <list>, indexed <chr>, ISBN <chr>, ISSN <chr>,
#> #   issued <chr>, link <list>, member <chr>, prefix <chr>,
#> #   publisher <chr>, score <chr>, source <chr>, subject <chr>,
#> #   subtitle <chr>, title <chr>, type <chr>, URL <chr>, assertion <list>,
#> #   author <list>, `clinical-trial-number` <list>, issue <chr>,
#> #   page <chr>, volume <chr>, license_date <chr>, license_URL <chr>,
#> #   license_delay.in.days <chr>, license_content.version <chr>,
#> #   archive <chr>, update.policy <chr>
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
#> # A tibble: 42 × 2
#>    issued  pubs
#>     <dbl> <int>
#> 1      NA     9
#> 2    2015     8
#> 3    2016     7
#> 4    2012     5
#> 5    1987     4
#> 6    2000     4
#> 7    2007     4
#> 8    2010     4
#> 9    1983     3
#> 10   2002     3
#> # ... with 32 more rows
```

and of what type they are


```r
random_dois %>%
  group_by(type) %>%
  summarize(pubs = n()) %>%
  arrange(desc(pubs))
#> # A tibble: 10 × 2
#>                   type  pubs
#>                  <chr> <int>
#> 1      journal-article    72
#> 2         book-chapter    12
#> 3  proceedings-article     6
#> 4            component     3
#> 5                 book     2
#> 6         dissertation     1
#> 7        journal-issue     1
#> 8            monograph     1
#> 9      reference-entry     1
#> 10              report     1
```

#### Calling oaDOI.org

Now let's call oaDOI.org


```r
oa_df <- roadoi::oadoi_fetch(dois = random_dois$DOI)
```

and merge the resulting information about open access full-text links with our Crossref metadata-set


```r
my_df <- dplyr::left_join(oa_df, random_dois, by = c("doi" = "DOI"))
my_df
#> # A tibble: 100 × 48
#>    `_best_open_url` `_closed_base_ids` `_closed_urls` `_open_base_ids`
#>               <chr>             <list>         <list>           <list>
#> 1              <NA>          <chr [1]>      <chr [1]>       <list [0]>
#> 2              <NA>         <list [0]>     <list [0]>       <list [0]>
#> 3              <NA>          <chr [2]>      <chr [3]>       <list [0]>
#> 4              <NA>         <list [0]>     <list [0]>       <list [0]>
#> 5              <NA>         <list [0]>     <list [0]>       <list [0]>
#> 6              <NA>         <list [0]>     <list [0]>       <list [0]>
#> 7              <NA>          <chr [1]>      <chr [1]>       <list [0]>
#> 8              <NA>         <list [0]>     <list [0]>       <list [0]>
#> 9              <NA>          <chr [1]>      <chr [1]>       <list [0]>
#> 10             <NA>         <list [0]>     <list [0]>       <list [0]>
#> # ... with 90 more rows, and 44 more variables: `_open_urls` <list>,
#> #   doi <chr>, doi_resolver <chr>, evidence <chr>,
#> #   free_fulltext_url <chr>, is_boai_license <lgl>, is_free_to_read <lgl>,
#> #   is_subscription_journal <lgl>, license <chr>, oa_color <chr>,
#> #   url <chr>, year <int>, alternative.id <chr>, container.title <chr>,
#> #   created <chr>, deposited <chr>, funder <list>, indexed <chr>,
#> #   ISBN <chr>, ISSN <chr>, issued <chr>, link <list>, member <chr>,
#> #   prefix <chr>, publisher <chr>, score <chr>, source <chr>,
#> #   subject <chr>, subtitle <chr>, title <chr>, type <chr>, URL <chr>,
#> #   assertion <list>, author <list>, `clinical-trial-number` <list>,
#> #   issue <chr>, page <chr>, volume <chr>, license_date <chr>,
#> #   license_URL <chr>, license_delay.in.days <chr>,
#> #   license_content.version <chr>, archive <chr>, update.policy <chr>
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
|closed                                                |       87|       0.87|
|oa repository (via BASE title and first author match) |        4|       0.04|
|oa journal (via journal title in doaj)                |        3|       0.03|
|oa journal (via publisher name)                       |        2|       0.02|
|oa repository (via pmcid lookup)                      |        2|       0.02|
|hybrid journal (via crossref license)                 |        1|       0.01|
|oa repository (via BASE doi match)                    |        1|       0.01|

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
|NA       |       87|       0.87|
|green    |        7|       0.07|
|gold     |        6|       0.06|

Let's take a closer look and assess how green and gold is distributed over publication types?


```r
my_df %>%
  filter(!evidence == "closed") %>% 
  count(oa_color, type, sort = TRUE) %>% 
  knitr::kable()
```



|oa_color |type            |  n|
|:--------|:---------------|--:|
|green    |journal-article |  7|
|gold     |journal-article |  4|
|gold     |component       |  2|


## Meta

Please note that this project is released with a [Contributor Code of Conduct](CONDUCT.md). By participating in this project you agree to abide by its terms.

License: MIT

Please use the [issue tracker](https://github.com/njahn82/roadoi/issues) for bug reporting and feature requests.

