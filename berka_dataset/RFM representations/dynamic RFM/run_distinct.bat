set INFILE2=drfm_lstm2_pkdd99.csv
set INFILE15=drfm_lstm15_pkdd99.csv

python distinct.py --csv_file %INFILE2%
python distinct.py --csv_file %INFILE15%
echo.
