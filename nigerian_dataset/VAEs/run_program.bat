:: %1 = Kvae2
:: %2 = Kvae15
:: %3 = "C:\Program Files\Weka-3-9\weka.jar"

:: EXAMPLE OF EXECUTION: run_program 6 5 "C:\Program Files\Weka-3-9\weka.jar"

@echo off

echo.
echo ===================================
echo 1. VAEs features computation
echo ===================================
call run_vae.bat
echo.

echo ===============
echo 2. ELBOW method
echo ===============
call run_elbow.bat %3
echo.

echo =====================
echo 3. K-means clustering
echo =====================
call run_kmeans.bat %1 %2 %3
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

