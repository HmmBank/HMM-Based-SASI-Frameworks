@echo off

set INFILE=vae2_pkdd99.csv
set OUTFILEpdf=vae2_pkdd99.pdf
set OUTFILEhtml=vae2_pkdd99.html

python clustering_visualization.py --csv_clustering %INFILE% --pdf_clustering %OUTFILEpdf% --html_clustering %OUTFILEhtml%
echo Visualization files: '%OUTFILEpdf%' and '%OUTFILEhtml%'
echo.
