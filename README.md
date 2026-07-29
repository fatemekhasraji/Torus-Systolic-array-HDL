# 2D Torus Systolic Array Hardware Engine in Verilog

![Language](https://img.shields.io/badge/Language-Verilog-blue)
![Tools](https://img.shields.io/badge/EDA-Xilinx%20Vivado%202019.1-red)
![Topology](https://img.shields.io/badge/Topology-2D%20Torus%20Grid-purple)
![License](https://img.shields.io/badge/License-MIT-brightgreen)

## 📌 Overview
This repository contains a **synthesizable Verilog implementation of a 2D Torus-based Systolic Array Accelerator** for parallel matrix multiplication. 

Unlike standard 2D mesh arrays, the **Torus topology** cyclically connects array boundary edges—wrapping the rightmost outputs back into the leftmost inputs and bottommost outputs back into the top inputs. This cyclic data movement allows matrix elements to continuously circulate through the processing grid, eliminating global data broadcast bottlenecks and drastically reducing external memory bandwidth requirements.

> 🌟 **Deep Learning Application**: This Torus microkernel engine serves as the compute datapath for the [FPGA Accelerator of LeNet-5 CNN for Fashion-MNIST](https://github.com/fatemekhasraji/FashionMnist_LeNet5).

---

## 🏗 System Architecture & Datapath

```mermaid
graph TD
    subgraph Controller_FSM["Hardware Controller FSM (Controller.v)"]
        FSM["Controller FSM<br/>S_IDLE → S_PRIME → S_RUN → S_DONE"]
        FSM -->|MULT_ADD| MAC_CTRL["MULT_ADD = Enable MAC"]
        FSM -->|MOVE| MOVE_CTRL["MOVE = Shift Torus Registers"]
        FSM -->|FINISH| FIN_CTRL["FINISH = Computation Complete"]
    end

    subgraph Skew_Logic["Diagonal Index Skew Unit (SA.v)"]
        A_IN["Matrix A Input"] --> SKEW_A["up[r][c] = Matrix_A[c][temp]"]
        B_IN["Matrix B Input"] --> SKEW_B["left[r][c] = Matrix_B[temp][r]"]
        NOTE_TEMP["temp = (N - ((r + 1 + c) % N)) % N"]
    end

    subgraph Torus_Grid["5×5 Torus PE Grid (SA.v)"]
        direction TB
        subgraph R0["Row 0 PEs"]
            PE00["PE(0,0)"] -->|right| PE01["PE(0,1)"] -->|right| PE02["PE(0,2)"] -->|right| PE03["PE(0,3)"] -->|right| PE04["PE(0,4)"]
        end
        subgraph R1["Row 1 PEs"]
            PE10["PE(1,0)"] -->|right| PE11["PE(1,1)"] -->|right| PE12["PE(1,2)"] -->|right| PE13["PE(1,3)"] -->|right| PE14["PE(1,4)"]
        end
        subgraph R4["Row 4 PEs (Bottom)"]
            PE40["PE(4,0)"] -->|right| PE41["PE(4,1)"] -->|right| PE42["PE(4,2)"] -->|right| PE43["PE(4,3)"] -->|right| PE44["PE(4,4)"]
        end

        PE00 -->|down| PE10
        PE04 -->|down| PE14
        PE10 -.->|down| PE40
        PE14 -.->|down| PE44

        PE04 -.->|Horizontal Wrap| PE00
        PE14 -.->|Horizontal Wrap| PE10
        PE44 -.->|Horizontal Wrap| PE40

        PE40 -.->|Vertical Wrap| PE00
        PE44 -.->|Vertical Wrap| PE04
    end

    subgraph PE_Module["PE Internal Engine (PE.v)"]
        PE_IN_U["up"] --> PE_OUT_D["down = up"]
        PE_IN_L["left"] --> PE_OUT_R["right = left"]
        PE_IN_U & PE_IN_L --> PE_MAC["16×16 Signed Mult >>> FRAC_BITS"]
        PE_MAC --> PE_PROD["prod [31:0] Output"]
    end

    Skew_Logic -->|START Signal| Torus_Grid
    Controller_FSM -->|MOVE & MULT_ADD Signals| Torus_Grid
    Torus_Grid -->|FINISH Signal| OUT["Matrix C Output [799:0]"]
```

## ⚡ Processing Element (PE) Design
Each **Processing Element (`PE.v`)** operates as a local Multiply-Accumulate (MAC) engine:
* **Datapath**: $16 \times 16$-bit signed multiplication with 32-bit local accumulation register (`psum`).
* **Direct Routing**: Assigns `down = up` and `right = left` for zero-latency pass-through to adjacent PEs.
* **Q8.8 Fixed-Point Normalization**: Right-shifts multiplication product by `FRAC_BITS` (8 bits) before accumulating.

---

## 🕹 Controller Finite State Machine (FSM)

The hardware controller (`Controller.v`) manages systolic tile sequencing through four discrete states:

```
  +--------+    START    +---------+             +--------+    step_cnt >= N    +--------+
  | S_IDLE | ----------> | S_PRIME | ----------> | S_RUN  | -----------------> | S_DONE |
  +--------+             +---------+             +--------+                         +--------+
      ^                                                                                 |
      +---------------------------------------------------------------------------------+
```

| State | Control Signals | Function |
| :--- | :--- | :--- |
| `S_IDLE` | `MOVE=0`, `MULT_ADD=0` | Waits for high assertion on `START`. |
| `S_PRIME`| `MOVE=0`, `MULT_ADD=1` | Computes first MAC product for initial skewed inputs. |
| `S_RUN`  | `MOVE=1`, `MULT_ADD=1` | Cyclically shifts Torus registers and accumulates partial products across $N-1$ cycles. |
| `S_DONE` | `FINISH=1` | Signals computation completion and holds result in `Matrix_C`. |

---

## 📊 Synthesis & Resource Utilization Benchmarks

The core $5 \times 5$ Torus microkernel was synthesized targeting a **Xilinx Artix-7 XC7A100T FPGA** (`xc7a100tcsg324-1`) using Xilinx Vivado 2019.1 Out-Of-Context synthesis:

| Resource Metric | Used | Available | Utilization (%) | Notes / Hardware Insight |
| :--- | :--- | :--- | :--- | :--- |
| **Slice LUTs** | **1,616** | 63,400 | **2.55%** | Combinational logic & adder trees |
| **Slice Registers** | **3,206** | 126,800 | **2.53%** | Flip-Flops & Torus shift registers |
| **DSP48E1 Multipliers**| **25** | 240 | **10.42%** | Exactly 25 DSPs for 5x5 PE grid |
| **Block RAM (BRAM)** | **0** | 135 | **0.00%** | Compute engine uses register streaming |
| **Worst Negative Slack**| **+2.129 ns**| - | - | Positive setup slack @ 100 MHz |
| **Max Frequency ($f_{max}$)**| **127.05 MHz**| - | - | High throughput & low routing congestion |

---

## 🛠 Project Structure

```
torus-systolic-array-verilog/
├── README.md                # Project documentation
├── LICENSE                  # MIT License
├── rtl/                     # Synthesizable Verilog Source Files
│   ├── Controller.v         # FSM Tile Controller
│   ├── PE.v                 # Processing Element MAC engine
│   └── SA.v                 # 2D Torus Systolic Array top module
└── tb/                      # Testbenches
    └── tb_direct_torus.v    # Simulation testbench
```

---

## 🚀 How to Run Simulation

### Via Xilinx Vivado XSim GUI / Command Line:
1. Open Vivado and load the source files from `rtl/` and testbench from `tb/`.
2. Set `tb_direct_torus` as the top simulation module.
3. Run behavioral simulation for `200 ns`.

### Via Icarus Verilog (`iverilog`):
```bash
iverilog -o torus_sim rtl/Controller.v rtl/PE.v rtl/SA.v tb/tb_direct_torus.v
vvp torus_sim
```

---

## 📜 License
Distributed under the [MIT License](LICENSE).
```
