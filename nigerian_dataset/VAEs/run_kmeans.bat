:: %1 = Kvae2
:: %2 = Kvae15
:: %3 = "C:\Program Files\Weka-3-9\weka.jar"

@echo off
set Kvae2=%1
set Kvae15=%2
set INFILEvae2=vae2_nigeria.arff
set INFILEvae15=vae15_nigeria.arff
set OUTFILEvae2=vae2_nigeria.csv
set OUTFILEvae15=vae15_nigeria.csv

java --add-opens java.base/java.lang=ALL-UNNAMED ^
 -cp %3 ^
 weka.filters.MultiFilter ^
 -F "weka.filters.unsupervised.attribute.Remove -R 1" ^
 -F "weka.filters.unsupervised.attribute.AddCluster -W \"weka.clusterers.SimpleKMeans -N %Kvae2% -I 500 -init 2 -t1 -1.25 -t2 -1.0 -S 10\"" ^
 -i %INFILEvae2% ^
 -o tmp_clustered.arff
 
python copy_column.py --original_file %INFILEvae2% --clustered_file tmp_clustered.arff --csv_file %OUTFILEvae2%

del  tmp_clustered.arff
echo DRFM-vae2 clustering results saved in '%OUTFILEvae2%'
echo.

java --add-opens java.base/java.lang=ALL-UNNAMED ^
 -cp %3 ^
 weka.filters.MultiFilter ^
 -F "weka.filters.unsupervised.attribute.Remove -R 1" ^
 -F "weka.filters.unsupervised.attribute.AddCluster -W \"weka.clusterers.SimpleKMeans -N %Kvae15% -I 500 -init 2 -t1 -1.25 -t2 -1.0 -S 10\"" ^
 -i %INFILEvae15% ^
 -o tmp_clustered.arff
 
python copy_column.py --original_file %INFILEvae15% --clustered_file tmp_clustered.arff --csv_file %OUTFILEvae15%

del  tmp_clustered.arff
echo DRFM-vae15 clustering results saved in '%OUTFILEvae15%'
echo.
