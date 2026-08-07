:: %1 = Kagregation
:: %2 = Klstm2
:: %3 = Klstm15
:: %4 = "C:\Program Files\Weka-3-9\weka.jar"

:: EXAMPLE OF EXECUTION: run_program 7 6 5 "C:\Program Files\Weka-3-9\weka.jar"

@echo off

call "D:\sylvain\CodesC\PAAbank\Codes Python\online\RFM representations\dynamic RFM\env_tslearn\Scripts\activate"
echo.
echo ===================================
echo 1. dynamic RFM features computation
echo ===================================
call run_drfm.bat
echo.
call "D:\sylvain\CodesC\PAAbank\Codes Python\online\RFM representations\dynamic RFM\env_tslearn\Scripts\deactivate"

echo ===============
echo 2. ELBOW method
echo ===============
call run_elbow.bat %4
echo.

echo =====================
echo 3. K-means clustering
echo =====================
call run_kmeans.bat %1 %2 %3 %4
echo.

echo =====================
echo 4. Clustering metrics
echo =====================
call run_clustering_metrics.bat
echo.

echo ===========================
echo 5. Clustering visualization
echo ===========================
call run_clustering_visualization.bat
echo.

echo ==========================
echo 6. Counting the duplicates
echo ==========================
call run_distinct.bat

