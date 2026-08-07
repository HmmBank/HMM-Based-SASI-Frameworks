@echo off

set INFILE=kmeans_pkdd99.csv
set OUTFILEpdf=kmeans_pkdd99.pdf
set OUTFILEhtml=kmeans_pkdd99.html

python clustering_visualization.py --csv_clustering %INFILE% --pdf_clustering %OUTFILEpdf% --html_clustering %OUTFILEhtml%
echo.
echo Visualization files: '%OUTFILEpdf%' and '%OUTFILEhtml%'
