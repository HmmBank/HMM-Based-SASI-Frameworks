:: %1 = "C:\Program Files\Weka-3-9\weka.jar"

@echo off
setlocal enabledelayedexpansion

set KMAX=12
set INFILEvae2=vae2_pkdd99.arff
set INFILEvae15=vae15_pkdd99.arff
set OUTFILEvae2=elbow_vae2_pkdd99.csv
set OUTFILEvae15=elbow_vae15_pkdd99.csv

echo K,SSE > %OUTFILEvae2%

for /L %%K in (2,1,%KMAX%) do (

    echo K-means with K=%%K ...

    set "TMPFILE=.\weka_k_%%K.txt"

    java --add-opens java.base/java.lang=ALL-UNNAMED ^
    -cp %1 ^
    weka.clusterers.FilteredClusterer ^
    -F "weka.filters.unsupervised.attribute.Remove -R 1" ^
    -W weka.clusterers.SimpleKMeans ^
    -t %INFILEvae2% ^
    -- -N %%K -I 500 -init 2 -t1 -1.25 -t2 -1.0 -S 10 -output-debug-info ^
    > "!TMPFILE!" 2>&1

    for /f "tokens=2 delims=:" %%B in ('findstr "squared" "!TMPFILE!"') do (
        >>"%OUTFILEvae2%" echo %%K,%%B
    )

    del "!TMPFILE!"
)
echo SSE values saved in '%OUTFILEvae2%'
echo.

echo K,SSE > %OUTFILEvae15%

for /L %%K in (2,1,%KMAX%) do (

    echo K-means with K=%%K ...

    set "TMPFILE=.\weka_k_%%K.txt"

    java --add-opens java.base/java.lang=ALL-UNNAMED ^
    -cp %1 ^
    weka.clusterers.FilteredClusterer ^
    -F "weka.filters.unsupervised.attribute.Remove -R 1" ^
    -W weka.clusterers.SimpleKMeans ^
    -t %INFILEvae15% ^
    -- -N %%K -I 500 -init 2 -t1 -1.25 -t2 -1.0 -S 10 -output-debug-info ^
    > "!TMPFILE!" 2>&1

    for /f "tokens=2 delims=:" %%B in ('findstr "squared" "!TMPFILE!"') do (
        >>"%OUTFILEvae15%" echo %%K,%%B
    )

    del "!TMPFILE!"
)
echo SSE values saved in '%OUTFILEvae15%'
