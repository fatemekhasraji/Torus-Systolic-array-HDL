# Torus-Based MMULT Accelerator in Verilog
A synthesizable Verilog implementation of matrix multiplication on a 2D Torus interconnection network using Processing Elements (PEs), custom controller FSM, and systolic-style data movement.  
The project models parallel matrix multiplication using cyclic data propagation between neighboring PEs and was developed as part of a Parallel Processing course assignment.

## Overview
This project implements:
- A 2D Torus-based processing array
- Parameterized Processing Elements (PEs)
- FSM-based controller
- Parallel matrix multiplication
- Cyclic data movement using Torus topology
- Synthesizable Verilog RTL
- Functional simulation and synthesis analysis  

The architecture follows a systolic/Torus-style dataflow where matrix elements continuously circulate through the network instead of being streamed repeatedly from external memory.
## Architecture
Unlike a conventional mesh, the last row/column in the Torus network wraps around and connects back to the first row/column.
This allows:
- Continuous data circulation
- Reduced external bandwidth requirements
- Reuse of matrix elements across PEs
- Efficient parallel MAC operations

The implemented topology supports scalable matrix multiplication using parameterized dimensions.
## Processing Element (PE)
Each PE is parameterized and responsible for:
- Receiving data from top and left neighbors
- Performing Multiply-Accumulate (MAC)
- Forwarding values to neighboring PEs
- Accumulating partial sums locally
### PE Features
- Signed arithmetic
- Parameterized bitwidth
- Parameterized matrix size
- Synchronous reset
- Synthesizable RTL
- Local accumulation register
<img width="1042" height="465" alt="image" src="https://github.com/user-attachments/assets/08177d4d-d0f6-4d6b-b6d9-03fdfd8d40eb" />

## Controller FSM
The controller manages:
- Initialization
- Data movement
- MAC scheduling
- Computation termination
- FSM States
  - Reset
  - Init
  - Move
  - Mult_Add
  - Finish
 
The FSM coordinates systolic data propagation and computation timing across the Torus array.
<img width="551" height="786" alt="image" src="https://github.com/user-attachments/assets/1e692bb4-16de-4220-adbc-2d05b38bf050" />

Computation Flow
1. Reset network
2. Initialize PE inputs
3. Propagate matrix values through Torus links
4. Perform MAC operations in parallel
5. Accumulate local partial sums
6. Collect final outputs
7. Transpose final matrix

Control signals:
 - START
 - MOVE
 - MULT_ADD
 - FINISH
 - Simulation
## Example Configuration
Torus size: 5×5  
Matrix size: 4×4 

## Synthesis Results
The Torus module was synthesized in Vivado 2019.
