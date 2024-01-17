.. sc-VirusScan documentation master file, created by
   sphinx-quickstart on Thu Jan 11 14:56:35 2024.
   You can adapt this file completely to your liking, but it should at least
   contain the root `toctree` directive.

Welcome to sc-VirusScan's documentation!
========================================

sc-VirusScan is a Snakemake pipeline that enables accurate, sensitive and scalable detection of viral pathogens in single-cell RNA datasets. 

The sc-VirusScan integrates the strengths of two standard approaches, a standard mapping based approach and a Kraken2 k-mer based approach which provides rapid taxonomic classification. The output of the sc-VirusScan pipeline can be integrated easily into existing single cell analysis frameworks (Seurat and Scanpy) which can provide standardized and reliable way to scrutinize virus infections at the single cell level resolution.


Contents
-------------
.. toctree::
   :maxdepth: 2

   method.rst
   installation.rst
   Pipeline.rst


Credits
-------------
sc-VirusScan is developed by Saim Momin under supervision of Deboutte W and Manke T. at `Bioinformatics Unit <http://www.ie-freiburg.mpg.de/bioinformaticsfac>`_ of the `Max Planck Institute for Immunobiology and Epigenetics <http://www.ie-freiburg.mpg.de/>`_, Freiburg.

.. image:: mpi_logo.jpg
   :align: center

Help and Support
----------------

For feature requests or bug reports, please open an issue on `our GitHub Repository <https://github.com/maxplanck-ie/sc-VirusScan>`__.





