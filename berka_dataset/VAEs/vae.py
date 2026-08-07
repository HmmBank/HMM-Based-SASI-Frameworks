import os
os.environ['TF_CPP_MIN_LOG_LEVEL'] = '2'
import tensorflow as tf
import numpy as np
import argparse
import time
import re
from datetime import datetime, timedelta
from dataclasses import dataclass, field
from typing import List, Tuple


@dataclass
class Customer:
    matricule: str
    nb_transactions: int = 0
    transactions: List[Tuple[datetime, float]] = field(default_factory=list)


# ========================
# 1. Reading customer data
# ========================
def read_customer_data(dataset, date_start_str, date_end_str, T_min, T_max, min_amount, valid_dataset):

    customers = []
    date_start = datetime.strptime(date_start_str, "%d/%m/%Y")
    date_end = datetime.strptime(date_end_str, "%d/%m/%Y")

    with open(dataset, "r", encoding="utf-8") as f, \
         open(valid_dataset, "w", encoding="utf-8") as g:

        for line in f:
            line = line.strip()
            if not line:
                continue

            # Separation matricule / transactions
            matricule, rest = line.split(",", 1)
            matricule = matricule.strip()

            # Transaction extraction (date,amount)
            pattern = r"\((\d{2}/\d{2}/\d{4}),([-]?\d+)\)"
            matches = re.findall(pattern, rest)

            # Initializing the list of valid transactions
            transactions_valids = []

            nb_transacts = 0
            for date_str, amount_str in matches:
                amount = float(amount_str)

                # Ignore amounts less than min_amount
                if abs(amount) < min_amount:
                    continue

                # Ignore transactions outside the analysis period
                date_obj = datetime.strptime(date_str, "%d/%m/%Y")
                if date_obj < date_start or date_obj > date_end:
                    continue

                # Transaction validation
                transactions_valids.append((date_obj, amount))
                nb_transacts += 1

            # Chronological sorting of transactions
            transactions_valids.sort(key=lambda x: x[0])

            # Ignoring customers with too few transactions
            if nb_transacts < T_min:
                continue

            # Consider the recent transactions of customers with too many transactions
            if nb_transacts > T_max:
                transactions_valids = transactions_valids[-(T_max + 1):]
                nb_transacts = T_max
				
            # Skip customers that only have null amounts
            max_abs = max(abs(m) for _, m in transactions_valids)
            if max_abs == 0:
                continue				


            customer = Customer(matricule=matricule)
            customer.transactions = transactions_valids  
            customer.nb_transactions = nb_transacts
            customers.append(customer)

            # Updating the valid dataset
            g.write(customer.matricule + ",")

            for date_obj, amount in customer.transactions:
                date_str = date_obj.strftime("%d/%m/%Y")
                g.write(f"({date_str},{amount:.0f})")

            g.write("\n")

    return customers


# =========================================================
# 2. Convert customer's transactions into (delta_t, amount)
# =========================================================
def preprocess_sequences(customers):
    processed = []

    for customer in customers:
        seq = customer.transactions
        features = []
        (prev_date, amount) = seq[0]

        for (dt, amount) in seq:
            delta = (dt - prev_date).days
            features.append([delta, amount])
            prev_date = dt

        processed.append(np.array(features, dtype=np.float32))

    return processed


# ================
# 3. Pad sequences
# ================
def pad_sequences(sequences):
    max_len = max(len(seq) for seq in sequences)

    padded = []
    lengths = []

    for seq in sequences:
        length = len(seq)
        pad_len = max_len - length

        padded_seq = np.pad(seq, ((0, pad_len), (0, 0)), mode='constant')

        padded.append(padded_seq)
        lengths.append(length)

    return np.array(padded), np.array(lengths)

# ===============
# 5. Sequence VAE
# ===============
class SequenceVAE(tf.keras.Model):
    def __init__(self, input_dim=2, embed_dim=64, latent_dim=15):
        super().__init__()

        # ===== Encoder (LSTM) =====
        self.embedding = tf.keras.layers.Dense(embed_dim)

        self.encoder_lstm1 = tf.keras.layers.LSTM(
            embed_dim,
            return_sequences=True
        )

        self.encoder_lstm2 = tf.keras.layers.LSTM(
            embed_dim,
            return_sequences=False  # last hidden state only
        )

        self.fc_mu = tf.keras.layers.Dense(latent_dim)
        self.fc_logvar = tf.keras.layers.Dense(latent_dim)

        # ===== Decoder (LSTM) =====
        self.decoder_input = tf.keras.layers.Dense(embed_dim)

        self.decoder_lstm1 = tf.keras.layers.LSTM(
            embed_dim,
            return_sequences=True
        )

        self.decoder_lstm2 = tf.keras.layers.LSTM(
            embed_dim,
            return_sequences=True
        )

        self.output_layer = tf.keras.layers.Dense(input_dim)

    def encode(self, x):
        x = self.embedding(x)

        x = self.encoder_lstm1(x)
        x = self.encoder_lstm2(x)  # shape: (batch, embed_dim)

        mu = self.fc_mu(x)
        logvar = self.fc_logvar(x)

        return mu, logvar

    def reparameterize(self, mu, logvar):
        std = tf.exp(0.5 * logvar)
        eps = tf.random.normal(shape=tf.shape(std))
        return mu + eps * std

    def decode(self, z, seq_len):
        dec_input = self.decoder_input(z)

        # Repeat latent vector across time
        dec_input = tf.expand_dims(dec_input, axis=1)
        dec_input = tf.repeat(dec_input, repeats=seq_len, axis=1)

        x = self.decoder_lstm1(dec_input)
        x = self.decoder_lstm2(x)

        output = self.output_layer(x)
        return output

    def call(self, x):
        seq_len = tf.shape(x)[1]

        mu, logvar = self.encode(x)
        z = self.reparameterize(mu, logvar)
        reconstructed = self.decode(z, seq_len)

        return reconstructed, mu, logvar

# ================
# 6. Loss function
# ================
def vae_loss(recon_x, x, mu, logvar):
    recon_loss = tf.reduce_mean(tf.square(recon_x - x))

    kl_loss = -0.5 * tf.reduce_mean(
        1 + logvar - tf.square(mu) - tf.exp(logvar)
    )

    return recon_loss + kl_loss


# ============
# 7. Save ARFF
# ============
def save_arff(filename, customers, embeddings):
    p = embeddings.shape[1]

    with open(filename, "w") as f:
        f.write("@RELATION vae_embeddings\n\n")

        f.write("@ATTRIBUTE matricule STRING\n")
        for i in range(p):
            f.write(f"@ATTRIBUTE x_{i+1} NUMERIC\n")

        f.write("\n@DATA\n")

        for customer, emb in zip(customers, embeddings):
            line = f'"{customer.matricule}",' + ",".join(map(str, emb))
            f.write(line + "\n")


# ===============
# 8. Save timings
# ===============
def save_timings(filename, timings):
    with open(filename, "w") as f:
        for k, v in timings.items():
            f.write(f"{k}: {v:.4f} seconds\n")


# ================
# 9. Main program
# ================
def main():
    parser = argparse.ArgumentParser()

    parser.add_argument("--dataset", type=str, default="./customers.txt", help="Customer bank transaction file")
    parser.add_argument("--valid_dataset", type=str, default="./valid_customers.txt", help="Valid customer transaction file")
    parser.add_argument("--date_start_str", type=str, default="01/01/1993", help="Start date of the customer analysis period")
    parser.add_argument("--date_end_str", type=str, default="31/12/1998", help="End date of the customer analysis period")
    parser.add_argument("--min_amount", type=int, default=186, help="Minimum amount for a valid transaction.")
    parser.add_argument("--T_min", type=int, default=150, help="Minimum number of valid transactions.")
    parser.add_argument("--T_max", type=int, default=500, help="Maximum number of valid recent transactions.")
    parser.add_argument("--file_embeddings", type=str, default="./embeddings.arff")
    parser.add_argument("--file_timings", type=str, default="./timings.txt")
    parser.add_argument("--dim_embeddings", type=int, default=15)

    args = parser.parse_args()

    tf.keras.utils.set_random_seed(42)
    tf.config.experimental.enable_op_determinism()

    # Files taken as input parameters
    dataset = args.dataset
    valid_dataset = args.valid_dataset
    file_embeddings = args.file_embeddings
    file_timings = args.file_timings

    # Verification of the analysis duration 
    date_start_str = args.date_start_str
    date_end_str = args.date_end_str
    date_start = datetime.strptime(date_start_str, "%d/%m/%Y")
    date_end = datetime.strptime(date_end_str, "%d/%m/%Y")

    # always have (date_start <= date_end) 
    if date_start > date_end:
        date_start, date_end = date_end, date_start

    # minimum duration of around 6 months 
    nb_days_analysis = (date_end - date_start).days
    if nb_days_analysis < 181:
        print(f"Analysis time too short ({nb_days_analysis} days).")
        print(f"Minimum analysis time: 181 days.")
        return 

    date_start_str = date_start.strftime("%d/%m/%Y")
    date_end_str = date_end.strftime("%d/%m/%Y")
    print(f"\nAnalysis from {date_start_str} to {date_end_str}")

    # min_amount must be positive
    min_amount = args.min_amount
    if min_amount < 0:
        min_amount = 12500

    # T_min between 150 and 500
    T_min = args.T_min
    if T_min < 150:
        T_min = 150
    elif T_min > 500:
        T_min = 500
		
    # T_max between 150 and 500
    T_max = args.T_max
    if T_max < 150:
        T_max = 150
    elif T_max > 500:
        T_max = 500

    # always have (T_min <= T_max) 
    if T_min > T_max:
        T_min, T_max = T_max, T_min
		
    # dim_embeddings between 2 and 20
    dim_embeddings = args.dim_embeddings
    if dim_embeddings < 2:
        dim_embeddings = 2
    elif dim_embeddings > 20:
        dim_embeddings = 20

    # Other parameters
    nb_epochs = 50
    batch_size = 32
    patience = 10

    timings = {}
    total_start = time.time()

    # Reading customer data
    t0 = time.time()
    customers = read_customer_data(dataset, date_start_str, date_end_str, T_min, T_max, min_amount, valid_dataset)
    print(f"\nNumber of valid customers :{len(customers)}")
    timings["reading_data"] = time.time() - t0

    # preprocess sequences
    t0 = time.time()
    processed = preprocess_sequences(customers)
    padded, masks = pad_sequences(processed)
    X = tf.convert_to_tensor(padded, dtype=tf.float32)

    # Data normalization
    mean = tf.reduce_mean(X, axis=[0,1], keepdims=True)
    std = tf.math.reduce_std(X, axis=[0,1], keepdims=True) + 1e-6
    X = (X - mean) / std
    timings["preprocessing"] = time.time() - t0

    # VAE model initialization
    t0 = time.time()
    model = SequenceVAE(latent_dim=dim_embeddings)
    optimizer = tf.keras.optimizers.Adam()
    timings["model_initialization"] = time.time() - t0

    # VAE model training
    t0 = time.time()

    dataset_tf = tf.data.Dataset.from_tensor_slices(X)
    dataset_tf = dataset_tf.shuffle(buffer_size=1024).batch(batch_size)

    best_loss = float("inf")
    wait = 0

    for epoch in range(nb_epochs):
        epoch_loss = 0.0
        nb_batches = 0

        for batch in dataset_tf:
            with tf.GradientTape() as tape:
                recon, mu, logvar = model(batch)
                loss = vae_loss(recon, batch, mu, logvar)

            gradients = tape.gradient(loss, model.trainable_variables)
            optimizer.apply_gradients(zip(gradients, model.trainable_variables))

            epoch_loss += loss.numpy()
            nb_batches += 1

        epoch_loss /= nb_batches
        print(f"Epoch {epoch+1}, Loss: {epoch_loss:.6f}")

        if epoch_loss < best_loss:
            best_loss = epoch_loss
            wait = 0
        else:
            wait += 1
            if wait >= patience:
                print("Early stopping triggered.")
                break


    timings["training"] = time.time() - t0

    # Embeddings extraction
    t0 = time.time()
    mu, logvar = model.encode(X)
    embeddings = mu.numpy()
    timings["embedding_extraction"] = time.time() - t0

    # Saving the arff file
    t0 = time.time()
    save_arff(file_embeddings, customers, embeddings)
    timings["arff_export"] = time.time() - t0

    # Saving the start and end dates of the analysis in a file
    with open("./dates.txt", "w") as f:
        f.write(date_start_str + "\n")
        f.write(date_end_str + "\n")

    timings["total_execution"] = time.time() - total_start
    save_timings(file_timings, timings)

if __name__ == "__main__":
    main()
