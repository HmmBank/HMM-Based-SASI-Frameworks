@echo off

set INFILE=rfm_pkdd99.csv
set OUTFILEpdf=rfm_pkdd99.pdf
set OUTFILEhtml=rfm_pkdd99.html

python clustering_visualization.py --csv_clustering %INFILE% --pdf_clustering %OUTFILEpdf% --html_clustering %OUTFILEhtml%
echo.
echo Visualization files: '%OUTFILEpdf%' and '%OUTFILEhtml%'
echo.
