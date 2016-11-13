# exptools

[![Build Status](https://travis-ci.org/betabandido/exptools.svg?branch=master)](https://travis-ci.org/betabandido/exptools)

This package is a collection of useful tools for helping with
processing experimental results in the field of computer science research.
Although that is the primary intention, parts of this package might as
well be useful for processing data in other research fields.

To install:

* the latest development version: `install_github("betabandido/exptools")`

# Usage

## load.data

`load.data` loads data from multiple CSV files and combines the data into
a `data.table` object. A regular expression is used to decide which CSV files
will be used and how they should be merged.

Example:

    load.data('results',
              'exp-(\\w+)/(\\d+)\\.csv',
              c('name', 'config'))
              
This command will load all the CSV files that match the given pattern within
'results' folder. Two extra columns will be added to the `data.table` ('name'
and 'config'). Values for 'name' will be obtained from the first capture
group `(\\w+)` and values for 'config' will be obtained from the second
capture group `(\\d+)`.

Assuming the following files in 'results' folder:

    'results/exp-A/1.csv'
    'results/exp-A/2.csv'
    'results/exp-B/1.csv'
    'results/exp-B/2.csv'

the resulting `data.table` will look like:

       name config ...
    1:    A      1
    2:    A      2
    3:    B      1
    4:    B      2

`load.data` accepts two additional arguments (`local.func` and `global.func`).
Both arguments must be functions that accept a `data.table` as an argument,
and return a potentially modified `data.table`. `local.func` will be applied
to the data read from each CSV file (before merging all of them together).
`global.func` will be called with the resulting data after the merge step. By
providing these functions it is possible to filter or alter the data to suit
the specific pre-processing requirements.
