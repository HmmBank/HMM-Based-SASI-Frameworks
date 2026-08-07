@echo off

set INFILE=customers_pkdd99.txt
set OUTFILE=customers_pkdd99.arff

python rfm.py --dataset %INFILE% --valid_dataset valid_customers_pkdd99.txt --file_rfm %OUTFILE% --date_start_str 01/01/1993 --date_end_str 31/12/1998 --min_amount 186 --T_min 150 --T_max 500 
echo.
echo RFM scores saved in '%OUTFILE%'

