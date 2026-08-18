# Microwave Controller (MIPS Assembly) 

[![Language](https://img.shields.io/badge/Language-MIPS%20Assembly-red)](#)
[![Simulator](https://img.shields.io/badge/Simulator-MARS%204.5-blue)](#)

This repository contains the final project for the **Computer Organization** course. It consists of a firmware simulation for an automated microwave, written entirely in **MIPS Assembly**. 

The system handles user inputs, timer countdowns, and safety mechanisms (like opening the door) using a highly modular architecture and low-level hardware concepts.

##  Technical Highlights
* **Finite State Machine (FSM):** The core logic is driven by a 5-state machine (IDLE, RUNNING, PAUSED, DOOR_OPEN, DONE) to ensure safe and predictable behavior.
* **Memory-Mapped I/O:** Hardware components like the hexadecimal keyboard and 7-segment displays are controlled directly via memory addresses.
* **Asynchronous Timers:** The time countdown uses system calls (syscall 30) for non-blocking execution, allowing the system to poll the keyboard continuously without freezing.
* **Debounce Handling:** Implemented logical debounce to prevent double-clicks on the matrix keyboard.

##  Architecture & Modules
The project follows a top-down approach and the Single Responsibility Principle, divided into 5 distinct modules:

* `main.asm`: The entry point and main polling loop.
* `logica.asm`: The FSM that controls the business rules and state transitions.
* `teclado.asm`: Hardware abstraction for the matrix keyboard (polling and logical mapping).
* `display.asm`: Handles the rendering of numbers and characters (like "OP" for open door) on the 7-segment displays.
* `timer.asm`: Manages the 1000ms ticks using the OS clock.

##  How to Run
To simulate this firmware, you need the **MARS (MIPS Assembler and Runtime Simulator)** and the **Digital Lab Sim** tool.

1. Clone this repository and ensure all `.asm` files are in the same folder.
2. Open `main.asm` in MARS.
3. Open the **Digital Lab Sim** tool (Tools > Digital Lab Sim).
4. Click **Connect to MIPS** in the Digital Lab Sim window.
5. Assemble and run the code in MARS.
6. Use the hexadecimal keyboard to input the time (0-9), press **A** to start, **B** to pause/cancel, and **C** to toggle the microwave door.
