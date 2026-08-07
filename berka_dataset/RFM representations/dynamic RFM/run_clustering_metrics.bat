@echo off

set INFILEagregation=drfm_agregation_pkdd99.csv
set INFILElstm2=drfm_lstm2_pkdd99.csv
set INFILElstm15=drfm_lstm15_pkdd99.csv
set OUTFILE2=metrics2.txt
set OUTFILE15=metrics15.txt

python clustering_metrics.py --csv_agregation %INFILEagregation% --csv_lstm %INFILElstm2% --dim_lstm 2 --metrics_file %OUTFILE2%
python clustering_metrics.py --csv_agregation %INFILEagregation% --csv_lstm %INFILElstm15% --dim_lstm 15 --metrics_file %OUTFILE15%
echo.
echo Clustering metrics saved in '%OUTFILE2%' and '%OUTFILE15%'
