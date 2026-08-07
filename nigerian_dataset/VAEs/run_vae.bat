@echo off

set INFILE=customers_nigeria.txt
set OUTFILEvae2=vae2_nigeria.arff
set OUTFILEvae15=vae15_nigeria.arff
set OUTFILEtime2=timings2.txt
set OUTFILEtime15=timings15.txt

python vae.py --dataset %INFILE% --valid_dataset valid_customers_nigeria.txt --file_embeddings %OUTFILEvae2% --file_timings %OUTFILEtime2% --date_start_str 01/01/2023 --date_end_str 31/12/2024 --dim_embeddings 2 --min_amount 12500 --T_min 150 --T_max 500 
python vae.py --dataset %INFILE% --valid_dataset valid_customers_nigeria.txt --file_embeddings %OUTFILEvae15% --file_timings %OUTFILEtime15% --date_start_str 01/01/2023 --date_end_str 31/12/2024 --dim_embeddings 15 --min_amount 12500 --T_min 150 --T_max 500 
echo.
echo VAEs features saved in '%OUTFILEvae2%' and '%OUTFILEvae15%' 
echo Timings saved in '%OUTFILEtime2%' and '%OUTFILEtime15%'
