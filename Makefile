PREFIX = .

EXAMPLE_00_METADATA = $(PREFIX)/data/metadata.csv

PREFIX_01 = $(PREFIX)/code/01-fiji-imagej-macros
EXAMPLE_01_FIJI = \
$(PREFIX_01)/ColonyMacro1.ijm \
$(PREFIX_01)/ColonyMacro2.ijm \
$(PREFIX_01)/ColonyMacro3.ijm \
$(PREFIX_01)/ColonyMacro4.ijm

PREFIX_02 = $(PREFIX)/code/02-cellprofiler
EXAMPLE_02_CELLPROFILER = \
$(PREFIX_02)/ColonyCounter.cpproj \
$(PREFIX_02)/random-forrest.model \
$(PREFIX_02)/training-set.csv

EXAMPLE_03_MERGE = $(PREFIX)/code/03-spreadsheet-cfu/cellprofiler.R

EXAMPLE_04_PLOT = $(PREFIX)/code/04-plots/plot_abx_cfu.R

EXAMPLE_RSTUDIO = $(PREFIX)/colony-counting.Rproj

EXAMPLE = \
$(EXAMPLE_00_METADATA) \
$(EXAMPLE_01_FIJI) \
$(EXAMPLE_02_CELLPROFILER) \
$(EXAMPLE_03_MERGE) \
$(EXAMPLE_04_PLOT) \
$(EXAMPLE_RSTUDIO)

PREFIX_R = $(PREFIX)/results
RESULTS = \
$(PREFIX_R)/01-fiji-images/* \
$(PREFIX_R)/02-images-colonies-overlay/* \
$(PREFIX_R)/02-cellprofiler-spreadsheet-counts/* \
$(PREFIX_R)/02-cellprofiler-analyst-spreadsheet-counts/* \
$(PREFIX_R)/03-spreadsheet-cfu/* \
$(PREFIX_R)/04-plots-cfu/*

.PHONY : all
all : example results

.PHONY: example
example : example.zip

example.zip : $(EXAMPLE)
	zip -r $@ $^

.PHONY : results
results : results.zip

results.zip : $(RESULTS)
	zip -r $@ $^
