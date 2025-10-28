# 🌐 Network Simulation and Analysis with NS-2

This repository contains a complete set of NS-2 simulation scripts and AWK analysis tools developed for the **Computer Networks** course during the **Master 1 in Computer Science** program at **Université Claude Bernard Lyon 1**.

The goal of this project is to simulate, analyze, and compare **TCP and UDP network flows**, measure throughput, packet loss, delay, and understand the impact of **congestion**, **buffers**, and **link capacity** on network performance.

---

## 🧠 Overview

The simulations model both **wired** and **wireless** communication networks using **NS-2 (Network Simulator 2)**.  
They explore concepts such as:
- End-to-end delay and transmission time
- Queue management (DropTail policy)
- TCP vs. UDP coexistence
- Congestion and bandwidth sharing
- Throughput, loss rate, and average delay analysis via AWK scripts

---

## 🧩 Project Structure

| File | Description |
|------|--------------|
| `udp_flow.tcl` | Simulates a simple UDP flow between two nodes to measure delay and throughput. |
| `combine_udp_tcp_flow.tcl` | Models concurrent TCP and UDP flows to study fairness and congestion effects. |
| `tp2-concurrents.tcl` | Extends the previous simulation with multiple TCP flows and varying durations. |
| `surcout.tcl` | Evaluates overhead and link utilization when multiple flows coexist. |
| `script.awk` | Processes trace files to compute packet loss rate over specific time intervals. |
| `calculate.awk` | Computes average end-to-end delay for received UDP packets between t1 and t2. |
| `analyse.awk` | Combines throughput, loss, and delay metrics for comprehensive performance evaluation. |
| `throughput.awk` | Measures throughput (Mb/s) from trace data using packet size and transmission times. |
| `note.txt` | Contains numerical results, explanations, and analysis of observations. |

---

## ⚙️ Simulation Environment

### Tools
- **NS-2** (Network Simulator 2)
- **AWK** (Data processing for trace analysis)
- **Grep, Bash, and Gnuplot** (optional for visualization)

### Run Example
To execute a simulation and generate a trace file:
```bash
ns udp_flow.tcl
```
Then analyze the trace file:
```bash
awk -v t1=1 -v t2=2 -f calculate.awk out.tr
```

---

## 📊 Key Concepts Demonstrated

### 1️⃣ UDP Flow Analysis (`udp_flow.tcl`)
- Calculates **transmission delay** and **end-to-end delay**
- Demonstrates how **queueing and congestion** increase real delay compared to theoretical minimum

**Example Results:**
- Minimum delay: 18 ms  
- End-to-end delay (packet #10): 48 ms  
- Application throughput: ~1.6 Mbps

---

### 2️⃣ TCP and UDP Coexistence (`combine_udp_tcp_flow.tcl`)
- Analyzes **fairness** and **bandwidth sharing** between TCP and UDP
- Uses **DropTail queues** to model congestion and packet loss
- Demonstrates that UDP can starve TCP when buffers are small

**Metrics:**
- Packet loss rate between 24.8% and 26.4%
- Delay increases when buffer size increases (due to queueing)

---

### 3️⃣ TCP Flow Performance (`tp2-concurrents.tcl`)
- Two concurrent TCP flows over a bottleneck link (1 Mbps)
- Throughput computed from trace:
  - Flow 1: 0.103 Mb/s  
  - Flow 2: 0.993 Mb/s
- Sum exceeds link capacity → **congestion detected**

**Findings:**
- Flow 2 dominates due to longer duration and adaptive congestion control
- Flow 1 experiences 100% packet loss and no valid RTT
- Flow 2 maintains ~4% loss, RTT ≈ 4.7 s

---

### 4️⃣ Buffer Impact (`script.awk`, `calculate.awk`)
- Compares performance for queue sizes of **10** and **100 packets**

**Results:**
| Metric | Buffer = 10 | Buffer = 100 |
|--------|--------------|--------------|
| Packet loss | 24–26% | Similar (congestion limited) |
| Avg delay | 0.07 s | up to 0.77 s |

**Conclusion:**  
Larger buffers reduce packet drops but increase delay due to queue buildup (bufferbloat).

---

### 5️⃣ Wireless Simulation (`surcout.tcl`)
- Demonstrates **AODV routing** and **802.11 MAC behavior**
- Models:
  - Propagation: `TwoRayGround`
  - Antenna: `OmniAntenna`
- Observations:
  - MAC layer generates ACKs for each data frame
  - Queue drops occur when offered load (20 Mb/s) > Wi-Fi capacity (11 Mb/s)
  - Typical measured throughput: **6.1 Mb/s**

---

## 📈 Analysis Examples

### Compute packet loss rate
```bash
./script.awk 1 2 out.tr
```
Example output:
```
Interval: [1, 2]
Packets sent: 250
Packets received: 188
Packets lost: 62
Loss rate: 24.8%
```

### Compute average delay
```bash
awk -v t1=1 -v t2=2 -f calculate.awk out.tr
```
Output:
```
Period [1, 2]:
  Packets received: 201
  Average delay: 0.074697 s
```

### Compute throughput
```bash
grep "^+.*tcp" out.tr | awk '$2 >= 0 && $2 <= 5 && $3 == 2 {sum += $6} END {print (sum * 8) / (5 * 10^6) " Mb/s"}'
```
Output: `0.993 Mb/s`

---

## 🧪 Observations and Conclusions

- **Congestion** leads to delay spikes and packet loss.  
- **TCP** adapts its rate dynamically; **UDP** does not → unfair bandwidth sharing.  
- **Queue length** influences delay more than packet loss.  
- **Wireless constraints** (MAC, signal propagation) limit throughput compared to theoretical rates.  

---

## 🧰 Technologies Used

| Category | Tools |
|-----------|--------|
| Simulator | NS-2 |
| Scripting | Tcl, AWK, Bash |
| Analysis | AWK, Grep, Gnuplot |
| OS | Linux / WSL2 |

---

## 👨‍💻 Author

**Alexandre COTTIER**  
Master’s student in Computer Science – *Image, Développement et Technologie 3D (ID3D)*  
Université Claude Bernard Lyon 1  

📍 Lyon, France  
🔗 [GitHub](https://github.com/yourusername) · [LinkedIn](https://linkedin.com/in/yourprofile)

---

## 📜 License

This repository is provided for **educational and academic purposes** only.  
You may reuse and modify the code with attribution.

---

> *“Understanding networks isn’t about cables and packets — it’s about timing, fairness, and flow.”*
