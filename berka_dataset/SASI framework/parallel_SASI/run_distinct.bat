@echo off

set INFILE=kmeans_pkdd99.csv

python distinct.py --csv_file %INFILE%
echo.
