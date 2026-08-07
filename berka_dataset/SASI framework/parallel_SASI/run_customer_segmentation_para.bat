@echo off

set OUTFILEcsv=customers_pkdd99.csv
set OUTFILEarff=customers_pkdd99.arff
set INFILE=customers_pkdd99.txt

mpiexec -n %1 python customer_segmentation_para.py --dataset %INFILE% --valid_dataset valid_customers_pkdd99.txt --file_mc mc_customers_pkdd99.dat --csv_scores_SASI %OUTFILEcsv% --arff_scores_SASI %OUTFILEarff% --date_start_str 01/01/1993 --date_end_str 31/12/1998 --M 20 --min_amount 186 --T_min 150 --T_max 500 --maxiter 500 
echo.
echo Scores saved in '%OUTFILEcsv%' and '%OUTFILEarff%'
