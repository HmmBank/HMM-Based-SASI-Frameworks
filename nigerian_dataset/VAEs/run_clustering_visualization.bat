@echo off

set INFILE=vae2_nigeria.csv
set OUTFILEpdf=vae2_nigeria.pdf
set OUTFILEhtml=vae2_nigeria.html

python clustering_visualization.py --csv_clustering %INFILE% --pdf_clustering %OUTFILEpdf% --html_clustering %OUTFILEhtml%
echo Visualization files: '%OUTFILEpdf%' and '%OUTFILEhtml%'
echo.
