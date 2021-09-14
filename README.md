R data analysis template
========================

My template for setting up an R analysis project. This template uses
[cookiecutter](https://github.com/audreyr/cookiecutter), a Python templating
tool, to setup a directory structure.

Requirements
------------

Install `cookiecutter` using `pip`:

```
pip install cookiecutter
```

OR

`homebrew`:

```
brew install cookiecutter
```

OR

`conda`:

```
conda install -c conda-forge cookiecutter
```

Usage
-----

Generate a new analysis directory using:

```
cookiecutter gh:https://github.com/Metuendus/cookiecutter_data_analysis
```


Structure
----------

The resulting analysis project will have the following structure.

```
.
├── README.md
├── project_name.Rproj <- R.proj
├── etl                <- ETL scripts that stands for Extraction, Transformation and Load data
├── data
│   ├── external       <- Data from third party sources.
│   ├── interim        <- Intermediate data that has been transformed.
│   ├── processed      <- The final, canonical data sets for reports.
│   └── raw            <- The original, immutable data dump.
├── docs               <- Documentation, e.g., doxygen or scientific papers (not tracked by git)
├── analysis           <- Python notebooks or R notebooks of diferent analysis needed
├── R                  <- R scripts
└── reports            <- For a manuscript source, e.g., LaTeX, Markdown, etc., or any project reports
    └── figures        <- Figures for the manuscript or reports
```

License
-------

This project is licensed under the terms of the [MIT License](/LICENSE)  


Acknowledgements
----------------

Much of this template is based on bdcaf's
[cookiecutter-r-analysis](https://github.com/lazappi/cookiecutter-r-analysis)
template.

