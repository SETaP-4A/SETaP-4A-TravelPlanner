# Configuration file for the Sphinx documentation builder.

# -- Project information -----------------------------------------------------
project = 'Setap 4a Travel Planner'
copyright = '2025, Theo Graham, Kevn De Gouveia, Matt Hall, Dayana Manikatova, Sophie Nice, Ebere Ezeronye, Mufaro Munyeza'
author = 'Theo Graham, Kevn De Gouveia, Matt Hall, Dayana Manikatova, Sophie Nice, Ebere Ezeronye, Mufaro Munyeza'
release = '1.0'

# -- General configuration ---------------------------------------------------
extensions = [
    "myst_parser",  # Enables Markdown support
]

templates_path = ['_templates']
exclude_patterns = []

# Support both .md and .rst files
source_suffix = {
    '.rst': 'restructuredtext',
    '.md': 'markdown',
}

# Set your main entry file (e.g. index.md)
master_doc = 'index'

# -- Options for HTML output -------------------------------------------------
html_theme = 'alabaster'
html_static_path = ['_static']
