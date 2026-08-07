:: %1 = "C:\Program Files\Weka-3-9\weka.jar"

@echo off
setlocal enabledelayedexpansion

set KMAX=12
set INFILEagregation=agregation_nigeria.arff
set INFILElstm2=lstm2_nigeria.arff
set INFILElstm15=lstm15_nigeria.arff
set OUTFILEagregation=elbow_agregation_nigeria.csv
set OUTFILElstm2=elbow_lstm2_nigeria.csv
set OUTFILElstm15=elbow_lstm15_nigeria.csv

echo K,SSE > %OUTFILEagregation%

for /L %%K in (2,1,%KMAX%) do (

    echo K-means with K=%%K ...

    set "TMPFILE=.\weka_k_%%K.txt"

    java --add-opens java.base/java.lang=ALL-UNNAMED ^
    -cp %1 ^
    weka.clusterers.FilteredClusterer ^
    -F "weka.filters.unsupervised.attribute.Remove -R 1,17" ^
    -W weka.clusterers.SimpleKMeans ^
    -t %INFILEagregation% ^
    -- -N %%K -I 500 -init 2 -t1 -1.25 -t2 -1.0 -S 10 -output-debug-info ^
    > "!TMPFILE!" 2>&1

    for /f "tokens=2 delims=:" %%B in ('findstr "squared" "!TMPFILE!"') do (
        >>"%OUTFILEagregation%" echo %%K,%%B
    )

    del "!TMPFILE!"
)
echo SSE values saved in '%OUTFILEagregation%'
echo.

echo K,SSE > %OUTFILElstm2%

for /L %%K in (2,1,%KMAX%) do (

    echo K-means with K=%%K ...

    set "TMPFILE=.\weka_k_%%K.txt"

    java --add-opens java.base/java.lang=ALL-UNNAMED ^
    -cp %1 ^
    weka.clusterers.FilteredClusterer ^
    -F "weka.filters.unsupervised.attribute.Remove -R 1,4" ^
    -W weka.clusterers.SimpleKMeans ^
    -t %INFILElstm2% ^
    -- -N %%K -I 500 -init 2 -t1 -1.25 -t2 -1.0 -S 10 -output-debug-info ^
    > "!TMPFILE!" 2>&1

    for /f "tokens=2 delims=:" %%B in ('findstr "squared" "!TMPFILE!"') do (
        >>"%OUTFILElstm2%" echo %%K,%%B
    )

    del "!TMPFILE!"
)
echo SSE values saved in '%OUTFILElstm2%'
echo.

echo K,SSE > %OUTFILElstm15%

for /L %%K in (2,1,%KMAX%) do (

    echo K-means with K=%%K ...

    set "TMPFILE=.\weka_k_%%K.txt"

    java --add-opens java.base/java.lang=ALL-UNNAMED ^
    -cp %1 ^
    weka.clusterers.FilteredClusterer ^
    -F "weka.filters.unsupervised.attribute.Remove -R 1,17" ^
    -W weka.clusterers.SimpleKMeans ^
    -t %INFILElstm15% ^
    -- -N %%K -I 500 -init 2 -t1 -1.25 -t2 -1.0 -S 10 -output-debug-info ^
    > "!TMPFILE!" 2>&1

    for /f "tokens=2 delims=:" %%B in ('findstr "squared" "!TMPFILE!"') do (
        >>"%OUTFILElstm15%" echo %%K,%%B
    )

    del "!TMPFILE!"
)
echo SSE values saved in '%OUTFILElstm15%'
