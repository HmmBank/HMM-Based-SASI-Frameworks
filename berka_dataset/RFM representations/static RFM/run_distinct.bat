@echo off

set INFILE=rfm_pkdd99.csv

python distinct.py --csv_file %INFILE%
echo.
