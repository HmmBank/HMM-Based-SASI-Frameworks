@echo off

set INFILEvae2=vae2_pkdd99.csv
set INFILEvae15=vae15_pkdd99.csv
set OUTFILE2=metrics2.txt
set OUTFILE15=metrics15.txt

python clustering_metrics.py --csv_vae %INFILEvae2% --dim_embeddings 2 --metrics_file %OUTFILE2%
python clustering_metrics.py --csv_vae %INFILEvae15% --dim_embeddings 15 --metrics_file %OUTFILE15%
echo.
echo Clustering metrics saved in '%OUTFILE2%' and '%OUTFILE15%'
