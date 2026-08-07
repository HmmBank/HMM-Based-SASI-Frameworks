@echo off

set INFILE=kmeans_nigeria.csv

python distinct.py --csv_file %INFILE%
echo.
