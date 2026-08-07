@echo off

set INFILE=rfm_nigeria.csv

python distinct.py --csv_file %INFILE%
echo.
