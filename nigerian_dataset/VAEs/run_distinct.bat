set INFILE2=vae2_nigeria.csv
set INFILE15=vae15_nigeria.csv

python distinct.py --csv_file %INFILE2%
python distinct.py --csv_file %INFILE15%
echo.
