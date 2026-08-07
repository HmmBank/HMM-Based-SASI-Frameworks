import csv
import argparse
import numpy as np


def distinct_elements(csv_file):

    # Dictionary:
    # key   = cluster label (c0, c1, ...)
    # value = number of elements in cluster
    cluster_sizes = {}

    # Dictionary:
    # key   = cluster label
    # value = set of distinct vectors
    cluster_vectors = {}

    with open(csv_file, "r", encoding="utf-8") as f:
        reader = csv.reader(f)

        # Skip header
        header = next(reader)

        for row in reader:
            if not row:
                continue

            # Cluster is last column
            cluster = row[-1].strip()

            # Feature vector = columns between matricule and cluster
            vector = tuple(float(x) for x in row[1:-1])

            # Update size
            if cluster not in cluster_sizes:
                cluster_sizes[cluster] = 0
                cluster_vectors[cluster] = set()

            cluster_sizes[cluster] += 1

            # Add vector to set (duplicates automatically ignored)
            cluster_vectors[cluster].add(vector)

    # Sorting clusters by cluster index: c0, c1, c2, ...
    sorted_clusters = sorted(cluster_sizes.keys(), key=lambda x: int(x[1:]))

    size_clusters = [cluster_sizes[c] for c in sorted_clusters]
    distinct_clusters = [len(cluster_vectors[c]) for c in sorted_clusters]

    return size_clusters, distinct_clusters


def main():
    parser = argparse.ArgumentParser(description="Count cluster sizes and distinct vectors")
    parser.add_argument("--csv_file", type=str, help="Input CSV file")

    args = parser.parse_args()

    size_clusters, distinct_clusters = distinct_elements(args.csv_file)
    repetitions = [(size - distinct) for size, distinct in zip(size_clusters, distinct_clusters)]
	
    print("Cluster sizes:")
    print(size_clusters)

    print("\nDistinct vectors per cluster:")
    print(distinct_clusters)

    print(f"\nTotal repetitions: {np.sum(repetitions)}")


if __name__ == "__main__":
    main()
	