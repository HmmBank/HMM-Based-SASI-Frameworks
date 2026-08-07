@echo off

set INFILE=drfm_lstm2_nigeria.csv
set OUTFILEpdf=drfm_lstm2_nigeria.pdf
set OUTFILEhtml=drfm_lstm2_nigeria.html

python clustering_visualization.py --csv_clustering %INFILE% --pdf_clustering %OUTFILEpdf% --html_clustering %OUTFILEhtml%
echo Visualization files: '%OUTFILEpdf%' and '%OUTFILEhtml%'
echo.
