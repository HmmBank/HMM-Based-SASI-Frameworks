set INFILE2=vae2_pkdd99.csv
set INFILE15=vae15_pkdd99.csv

python distinct.py --csv_file %INFILE2%
python distinct.py --csv_file %INFILE15%
echo.
