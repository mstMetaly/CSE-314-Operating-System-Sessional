# CSE 314 Operating System Sessional - Complete Offline Assignment Collection

<div align="center">

![CSE314](https://img.shields.io/badge/CSE-314%20Operating%20Systems-blue)
![Language](https://img.shields.io/badge/Language-C%2FC%2B%2B%2CBash-orange)
![Platform](https://img.shields.io/badge/Platform-xv6%20%7C%20Linux-green)
![Status](https://img.shields.io/badge/Status-Complete-success)

**A comprehensive collection of operating system concepts implemented through hands-on projects**

</div>

---

## 📚 Overview

This repository contains all five offline assignments from the **CSE 314 Operating System** course, covering fundamental OS concepts through practical implementation. Each assignment focuses on different aspects of operating systems, from high-level scripting to low-level kernel development.

## 🎯 Learning Objectives

- **System Programming**: Kernel development, system call implementation
- **Concurrency**: Multi-threading, process synchronization, race condition handling  
- **Operating Systems**: Process management, scheduling, memory management
- **Scripting**: Bash automation, testing frameworks
- **Low-level Programming**: C/C++, assembly integration, kernel-level development

---

## 📁 Repository Structure

```
ALL-OFFLINES/
├── OFFLINE1_BASH/          # Bash scripting and autograder system
│   ├── 2005110/           # Student implementation
│   └── Resources/         # Assignment specifications and test cases
├── OFFLINE2_SystemCall/   # xv6 system call implementation
│   ├── 2005110/           # Kernel patches
│   └── Resources/         # System call specifications
├── OFFLINE3_Scheduler/    # CPU scheduling algorithms
│   ├── 2005110/           # Scheduler implementations
│   └── Resources/         # Scheduling algorithm documentation
├── OFFLINE4_IPC/          # Inter-process communication
│   ├── 2005110/           # Multi-threaded museum simulation
│   └── Resources/         # IPC specifications and templates
└── OFFLINE5_Threading/    # Threading and synchronization in xv6
    ├── 2005110/           # Thread library implementation
    └── Resources/         # Threading specifications
```

---

## 🚀 Assignment Details

### **OFFLINE 1: Bash Scripting & Autograder Design**

**Objective**: Design and implement an automated grading system for evaluating student submissions.

**Key Features**:
- **Automated Submission Processing**: Extract and validate student submissions
- **Multi-language Support**: C, C++, Python compilation and execution
- **Test Case Management**: Comprehensive test suite execution
- **Plagiarism Detection**: Automated similarity checking
- **Grading & Reporting**: Detailed feedback and score generation

**Technical Implementation**:
- Bash scripting for automation
- File format validation (ZIP, TAR)
- Dynamic compilation and execution
- Output comparison and scoring
- Comprehensive error handling

**Files**:
- `2005110.sh` - Main autograder script
- Test cases with sample submissions
- Configuration files for different scenarios

---

### **OFFLINE 2: System Call Implementation**

**Objective**: Implement custom system calls in the xv6 operating system kernel.

**Requirements**:
- Kernel-level system call development
- xv6 operating system modification
- RISC-V architecture understanding
- Process and memory management

**Deliverable**: Patch file containing kernel modifications

**Technologies**:
- xv6 operating system
- RISC-V assembly
- C kernel programming
- Git patch management

---

### **OFFLINE 3: CPU Scheduling Algorithms**

**Objective**: Implement and analyze various CPU scheduling algorithms in xv6.

**Algorithms Implemented**:
- **Multi-Level Feedback Queue (MLFQ)**: Priority-based scheduling with aging
- **Lottery Scheduling**: Probabilistic fair scheduling
- **Performance Analysis**: Comparative evaluation of algorithms

**Key Concepts**:
- Process scheduling policies
- Priority management
- Context switching optimization
- Fairness and starvation prevention

**Deliverable**: Patch file with scheduler implementations

**Resources**:
- xv6 kernel modifications
- Scheduling algorithm documentation
- Performance benchmarking tools

---

### **OFFLINE 4: Inter-Process Communication (IPC)**

**Objective**: Develop a multi-threaded museum simulation demonstrating IPC concepts.

**Simulation Overview**:
The museum simulation models visitor flow through different galleries with synchronization requirements:

**Museum Layout**:
```
Hallway AB → Step 0 → Step 1 → Step 2 → Gallery 1 → Glass Corridor DE → Gallery 2
```

**Visitor Types**:
- **Standard Tickets** (IDs: 1001-1100): Regular visitors
- **Premium Tickets** (IDs: 2001-2100): Priority visitors

**Synchronization Requirements**:
- **Gallery 1**: Maximum 5 visitors simultaneously
- **Glass Corridor DE**: Maximum 3 visitors simultaneously
- **Gallery 2**: Different processing for standard vs premium visitors

**Technical Implementation**:
- **POSIX Threads**: Multi-threaded visitor simulation
- **Mutexes**: Critical section protection
- **Semaphores**: Resource management (galleries, corridors)
- **Real-time Logging**: Thread-safe event recording

**Key Features**:
- Poisson-distributed arrival times
- State-based visitor progression
- Resource contention handling
- Comprehensive event logging

**Compilation & Execution**:
```bash
g++ -pthread 2005110.cpp -o museum_sim
./museum_sim
```

---

### **OFFLINE 5: Threading & Synchronization in xv6**

**Objective**: Implement a user-level thread library and synchronization primitives in xv6.

**Task 1: Thread Support Implementation**

**System Calls to Implement**:
```c
int thread_create(void(*fcn)(void*), void *arg, void*stack)
int thread_join(int thread_id)
void thread_exit(void)
```

**Key Requirements**:
- Shared address space between threads
- Independent stack allocation (one page per thread)
- File descriptor sharing
- Proper thread lifecycle management

**Task 2: Synchronization Primitives**

**Spinlock Implementation**:
```c
void thread_spin_init(struct thread_spinlock *lk)
void thread_spin_lock(struct thread_spinlock *lk)
void thread_spin_unlock(struct thread_spinlock *lk)
```

**Mutex Implementation**:
```c
void thread_mutex_init(struct thread_mutex *m)
void thread_mutex_lock(struct thread_mutex *m)
void thread_mutex_unlock(struct thread_mutex *m)
```

**Technical Challenges**:
- Kernel-level thread management
- Memory mapping and page table synchronization
- Context switching optimization
- Race condition prevention

**Mark Distribution**:
- Thread Implementation: 55 marks
- Spinlock Implementation: 20 marks
- Mutex Implementation: 25 marks

**Deliverable**: Patch file with thread library implementation

---

## 🛠️ Technical Stack

### **Programming Languages**
- **C/C++**: Kernel development, system programming
- **Bash**: Automation and scripting
- **Assembly**: RISC-V architecture integration

### **Operating Systems**
- **xv6**: Educational operating system for kernel development
- **Linux**: Development and testing environment

### **Tools & Technologies**
- **Git**: Version control and patch management
- **POSIX Threads**: Multi-threading implementation
- **Make**: Build system management
- **GDB**: Debugging and analysis

---

## 📋 Prerequisites

### **System Requirements**
- Linux/Unix environment
- GCC compiler suite
- Git version control
- QEMU (for xv6 development)

### **Knowledge Requirements**
- C/C++ programming
- Operating system concepts
- Computer architecture basics
- Shell scripting fundamentals

---

## 🚀 Getting Started

### **Setup Instructions**

1. **Clone the Repository**
   ```bash
   git clone <repository-url>
   cd ALL-OFFLINES
   ```

2. **Environment Setup**
   ```bash
   # Install required packages (Ubuntu/Debian)
   sudo apt-get update
   sudo apt-get install build-essential git qemu-system-riscv64
   ```

3. **xv6 Setup** (for Offlines 2, 3, 5)
   ```bash
   # Clone xv6-riscv
   git clone https://github.com/mit-pdos/xv6-riscv.git
   cd xv6-riscv
   
   # Apply patches (example for Offline 5)
   git apply ../OFFLINE5_Threading/2005110/2005110.patch
   make qemu
   ```

### **Running Individual Assignments**

#### **Offline 1: Bash Autograder**
```bash
cd OFFLINE1_BASH/2005110
chmod +x 2005110.sh
./2005110.sh
```

#### **Offline 4: IPC Museum Simulation**
```bash
cd OFFLINE4_IPC/2005110
g++ -pthread 2005110.cpp -o museum_sim
./museum_sim
```

#### **Offline 5: Threading (in xv6)**
```bash
# In xv6 environment
threads
```

---

## 📊 Evaluation Criteria

### **Offline 1: Bash Scripting**
- Correctness of autograder logic
- Handling of edge cases
- Output accuracy and formatting
- Error handling robustness

### **Offline 2: System Calls**
- Functional system call implementation
- Kernel integration correctness
- Error handling and validation
- Documentation and comments

### **Offline 3: Scheduling**
- Algorithm correctness
- Performance optimization
- Fairness and starvation prevention
- Comparative analysis

### **Offline 4: IPC**
- Thread synchronization correctness
- Resource management accuracy
- Output consistency
- Performance under load

### **Offline 5: Threading**
- Thread library functionality (55 marks)
- Spinlock implementation (20 marks)
- Mutex implementation (25 marks)
- Overall system stability

---

## 🔧 Development Guidelines

### **Code Quality Standards**
- Clear and consistent naming conventions
- Comprehensive error handling
- Detailed documentation and comments
- Modular and maintainable design

### **Testing Requirements**
- Unit testing for individual components
- Integration testing for system interactions
- Performance benchmarking
- Edge case validation

### **Documentation Standards**
- README files for each assignment
- Code comments explaining complex logic
- Design decisions and trade-offs
- Usage examples and tutorials

---

## 📚 Resources & References

### **Official Documentation**
- [xv6 Book](https://pdos.csail.mit.edu/6.828/2022/xv6/book-riscv-rev3.pdf)
- [POSIX Threads Tutorial](https://hpc-tutorials.llnl.gov/posix/)
- [RISC-V Specification](https://riscv.org/specifications/)

### **Academic Resources**
- Operating System Concepts (Silberschatz)
- Modern Operating Systems (Tanenbaum)
- xv6 Educational Operating System

### **Online Resources**
- [MIT 6.S081 Course](https://pdos.csail.mit.edu/6.S081/2020/)
- [xv6 Threading Resources](https://pages.cs.wisc.edu/~gerald/cs537/Summer17/projects/p4b.html)
- [Scheduling Algorithm References](https://en.wikipedia.org/wiki/Lottery_scheduling)

---

## 🤝 Contributing

This repository contains academic assignments. For educational purposes:

1. **Understanding**: Study the implementations thoroughly
2. **Learning**: Use as reference for similar projects
3. **Improvement**: Suggest enhancements or optimizations
4. **Documentation**: Help improve documentation and examples

**Note**: Direct copying is strictly prohibited. Use for learning and understanding only.

---

## 📄 License

This project is for educational purposes. All rights reserved to the respective course instructors and institutions.

---

## 👨‍💻 Author

**Student ID**: 2005110  
**Course**: CSE 314 Operating System Sessional  
**Institution**: Bangladesh University of Engineering and Technology  
**Semester**: January 2024

---

<div align="center">

**⭐ Star this repository if you find it helpful!**

*Built with ❤️ for Operating System Education*

</div> 
