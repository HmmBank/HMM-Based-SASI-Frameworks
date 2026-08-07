import sys
import os
import csv
from sklearn.metrics import (
    silhouette_score,
    davies_bouldin_score,
    calinski_harabasz_score
)
import numpy as np
import math
import time
import argparse


# ===========================================================
# 1. Reading the VAEs clustering results from a CSV file
# ===========================================================
def read_vae_results(file_vae, dim_embeddings=15):

    clusters = []
    matricules = []
    features_dynamic_RFM = []
	
    y = np.zeros(dim_embeddings, dtype=float)
    with open(file_vae, mode='r', newline='') as f:

        reader = csv.reader(f)

        for line in reader:
            if line[0] == "matricule":
                continue
				
            matricule = line[0]

            for i in range(dim_embeddings):
                y[i] = float(line[1 + i])
				
            cluster = int(line[dim_embeddings+1].removeprefix("c"))

            matricules.append(matricule)
            L = [i for i in y]
            features_dynamic_RFM.append(L)
            clusters.append(cluster)

    labels = np.array(clusters)
    clusters_uniques, cluster_sizes = np.unique(labels, return_counts=True)
    nb_clusters = len(clusters_uniques)

    # Silhouette score
    X = np.array(features_dynamic_RFM, dtype=float)
    if nb_clusters > 1 and len(X) > nb_clusters:
        silhouette = silhouette_score(X, labels)
    else:
        silhouette = None  

    # Davies-Bouldin index
    if nb_clusters > 1:
        db_index = davies_bouldin_score(X, labels)
    else:
        db_index = None

    # Calinski-Harabasz index
    if nb_clusters > 1:
        ch_index = calinski_harabasz_score(X, labels)
    else:
        ch_index = None

    print("  1- VAEs (TF/LSTM)")
    print(f"     -silhouette: {silhouette:g}\n     -db_index: {db_index:g}\n     -ch_index: {ch_index:g}\n")

    return silhouette, db_index, ch_index
	
# ============
# Main program
# ============
def main():

    # Reading the parameters to be passed to the command line
    parser = argparse.ArgumentParser(description="Metrics of customer clusters")

    parser.add_argument("--csv_vae", type=str, default="./vaes_customers.csv", help="CSV file containing the results of customer drfm-lstm clustering")
    parser.add_argument("--metrics_file", type=str, default="./metrics.txt", help="TXT file containing the clustering metrics")
    parser.add_argument("--dim_embeddings", type=int, default=15, help="Number of LSTM latent features.")

    args = parser.parse_args()

    # Files taken as input parameters
    csv_vae = args.csv_vae
    metrics_file = args.metrics_file
		
    # dim_embeddings between 2 and 20
    dim_embeddings = args.dim_embeddings
    if dim_embeddings < 2:
        dim_embeddings = 2
    elif dim_embeddings > 20:
        dim_embeddings = 20

    # Start of timing of the time cost
    start = time.perf_counter()

    # Reading the lstm clustering
    silhouette_vae, db_index_vae, ch_index_vae = read_vae_results(csv_vae, dim_embeddings)

    # Saving the metrics in a file
    with open(metrics_file, "w") as f:
        f.write(f"silhouette(vae): {silhouette_vae:g}\n")
        f.write(f"db_index(vae): {db_index_vae:g}\n")
        f.write(f"ch_index(vae): {ch_index_vae:g}\n")
        f.write("###################################################\n")
     
    # End of the timing of the time cost
    end = time.perf_counter()
    print(f"Time complexity: {end - start:g} s")

if __name__ == "__main__":
    main()
	