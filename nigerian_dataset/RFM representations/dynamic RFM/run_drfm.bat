@echo off

set INFILE=customers_nigeria.txt
set OUTFILEagregation=agregation_nigeria.arff
set OUTFILElstm2=lstm2_nigeria.arff
set OUTFILElstm15=lstm15_nigeria.arff
set OUTFILEtime2=timings2.txt
set OUTFILEtime15=timings15.txt

python drfm.py --dataset %INFILE% --valid_dataset valid_customers_nigeria.txt --file_agregation %OUTFILEagregation% --file_lstm %OUTFILElstm2% --file_timings %OUTFILEtime2% --date_start_str 01/01/2023 --date_end_str 31/12/2024 --dim_lstm 2 --min_amount 12500 --T_min 150 --T_max 500 
python drfm.py --dataset %INFILE% --valid_dataset valid_customers_nigeria.txt --file_agregation %OUTFILEagregation% --file_lstm %OUTFILElstm15% --file_timings %OUTFILEtime15%  --date_start_str 01/01/2023 --date_end_str 31/12/2024 --dim_lstm 15 --min_amount 12500 --T_min 150 --T_max 500 
echo.
echo DRFM features saved in '%OUTFILEagregation%', '%OUTFILElstm2%' and '%OUTFILElstm15%'.
echo Timings saved in '%OUTFILEtime2%' and '%OUTFILEtime15%'
