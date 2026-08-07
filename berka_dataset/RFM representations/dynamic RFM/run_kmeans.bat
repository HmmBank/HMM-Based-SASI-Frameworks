:: %1 = Kagregation
:: %2 = Klstm2
:: %3 = Klstm15
:: %4 = "C:\Program Files\Weka-3-9\weka.jar"

@echo off
set Kagregation=%1
set Klstm2=%2
set Klstm15=%3
set INFILEagregation=agregation_pkdd99.arff
set INFILElstm2=lstm2_pkdd99.arff
set INFILElstm15=lstm15_pkdd99.arff
set OUTFILEagregation=drfm_agregation_pkdd99.csv
set OUTFILElstm2=drfm_lstm2_pkdd99.csv
set OUTFILElstm15=drfm_lstm15_pkdd99.csv

java --add-opens java.base/java.lang=ALL-UNNAMED ^
 -cp %4 ^
 weka.filters.MultiFilter ^
 -F "weka.filters.unsupervised.attribute.Remove -R 1,17" ^
 -F "weka.filters.unsupervised.attribute.AddCluster -W \"weka.clusterers.SimpleKMeans -N %Kagregation% -I 500 -init 2 -t1 -1.25 -t2 -1.0 -S 10\"" ^
 -i %INFILEagregation% ^
 -o tmp_clustered.arff
 
python copy_column.py --original_file %INFILEagregation% --clustered_file tmp_clustered.arff --csv_file %OUTFILEagregation%

del  tmp_clustered.arff
echo DRFM-aggregation clustering results saved in '%OUTFILEagregation%'
echo.

java --add-opens java.base/java.lang=ALL-UNNAMED ^
 -cp %4 ^
 weka.filters.MultiFilter ^
 -F "weka.filters.unsupervised.attribute.Remove -R 1,4" ^
 -F "weka.filters.unsupervised.attribute.AddCluster -W \"weka.clusterers.SimpleKMeans -N %Klstm2% -I 500 -init 2 -t1 -1.25 -t2 -1.0 -S 10\"" ^
 -i %INFILElstm2% ^
 -o tmp_clustered.arff
 
python copy_column.py --original_file %INFILElstm2% --clustered_file tmp_clustered.arff --csv_file %OUTFILElstm2%

del  tmp_clustered.arff
echo DRFM-lstm2 clustering results saved in '%OUTFILElstm2%'
echo.

java --add-opens java.base/java.lang=ALL-UNNAMED ^
 -cp %4 ^
 weka.filters.MultiFilter ^
 -F "weka.filters.unsupervised.attribute.Remove -R 1,17" ^
 -F "weka.filters.unsupervised.attribute.AddCluster -W \"weka.clusterers.SimpleKMeans -N %Klstm15% -I 500 -init 2 -t1 -1.25 -t2 -1.0 -S 10\"" ^
 -i %INFILElstm15% ^
 -o tmp_clustered.arff
 
python copy_column.py --original_file %INFILElstm15% --clustered_file tmp_clustered.arff --csv_file %OUTFILElstm15%

del  tmp_clustered.arff
echo DRFM-lstm15 clustering results saved in '%OUTFILElstm15%'
echo.
