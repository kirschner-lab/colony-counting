Semi-automated colony-forming unit counting for biosafety level 3 laboratories
==============================================================================

[![DOI](https://zenodo.org/badge/636337900.svg)](https://zenodo.org/badge/latestdoi/636337900)

Summary
-------

Obtain CFU counts using image processing with Fiji and CellProfiler, and
visualize dose-response relationships across drug concentrations using R.

These companion programs are to help automate and follow along with the STAR
Protocols paper.

Instructions
------------

To run the tutorial, download three files:

1. [example.zip](https://github.com/kirschner-lab/colony-counting/releases/download/v1.0/example.zip)
2. [images.zip](https://doi.org/10.5281/zenodo.7896805)
3. [results.zip](https://doi.org/10.5281/zenodo.7896821)

Unpack the `example.zip` and `results.zip` files alongside each other.  Then
unpack `images.zip` inside the `data/` directory that was unpacked from
`example.zip`.

This organization separates the unmodified input source data from the code and
output results ([Wilson 2017](#1)):

1. `data/` contains the raw unedited images and spreadsheet describing the
   images,
2. `results/` contains the output generated from the programs in `code/`.  The
   numeric prefix in `results/` matches that in `code/` to indicate which
   results are generated by programs in the corresponding directory.  The
   `results/` are provided to check important intermediate calculations that
   are illustrated in the protocol step-by-step figures.  Finally,
3. `code/` generates results from the `data/` and any previous results.  The
   code is organized into subdirectories named according to the tool or the
   intended result.

After unzipping the three directories, the file hierarchy should appear as
follows:

```console
$ tree -F --filelimit=10 --noreport *
README.md  [error opening dir]
code/
├── 01-fiji-imagej-macros/
│   ├── ColonyMacro1.ijm
│   ├── ColonyMacro2.ijm
│   ├── ColonyMacro3.ijm
│   └── ColonyMacro4.ijm
├── 02-cellprofiler/
│   ├── ColonyCounter.cpproj
│   ├── random-forrest.model
│   └── training-set.csv
├── 03-spreadsheet-cfu/
│   └── cellprofiler.R
└── 04-plots/
    └── plot_abx_cfu.R
colony-counting.Rproj  [error opening dir]
data/
├── images/  [11 entries exceeds filelimit, not opening dir]
└── metadata.csv
results/
├── 01-fiji-images/  [78 entries exceeds filelimit, not opening dir]
├── 02-cellprofiler-analyst-spreadsheet-counts/
│   ├── ColonyCountDB.db
│   ├── ColonyCountDB.properties
│   └── random-forrest-classfied.csv
├── 02-cellprofiler-spreadsheet-counts/
│   ├── Artifacts.csv
│   ├── Colonies.csv
│   ├── ColoniesUnsplit.csv
│   ├── ColoniesWithArtifacts.csv
│   ├── ColoniesWithArtifactsUnsplit.csv
│   ├── Experiment.csv
│   └── Image.csv
├── 02-images-colonies-overlay/  [117 entries exceeds filelimit, not opening dir]
├── 03-spreadsheet-cfu/
│   └── abx-cfu.csv
└── 04-plots-cfu/
    ├── fiji-time.png
    └── log-log.png
```

References
----------

<a id="1">[1]</a>
Wilson, G., Bryan, J., Cranston, K., Kitzes, J., Nederbragt, L., and Teal,
T.K. (2017). Good enough practices in scientific computing. PLoS Comput 
Biol 13, e1005510. 
[10.1371/journal.pcbi.1005510](https://doi.org/10.1371/journal.pcbi.1005510).
