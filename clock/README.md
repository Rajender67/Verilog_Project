# Custom Digital Clock (RTL Design & Verification)

In this project, I designed and verified a custom digital clock using Verilog. The goal was to build the system from basic components using a structural approach, instead of relying on behavioral shortcuts.

The clock operates with non-standard limits:
- Hours: 1–12  
- Minutes: 1–10  
- Seconds: 1–15  

It also supports loading a user-defined time and continues execution from that state.

---

## Design Details

The entire design is built in a modular way, similar to real hardware systems.

- Implemented a 4-bit incrementer using full adders  
- Designed a 4-bit comparator using cascaded 1-bit comparators (MSB priority)  
- Used multiplexers to control increment, rollover, and load operations  
- Built independent counters for seconds, minutes, and hours  
- Implemented carry propagation across all stages  
- Used D flip-flops for a fully synchronous design  

---

## Verification

A self-checking testbench was developed to validate the design.

- Created a behavioral golden reference model  
- Performed cycle-by-cycle comparison with the DUT  
- Tested key scenarios including rollover and user load  
- Added automatic mismatch detection  

Simulation completed with zero mismatches.

---

## 📚 Key Takeaways

- Gained hands-on experience with structural RTL design  
- Improved understanding of reusable hardware blocks  
- Learned how to build reliable verification environments  
- Strengthened concepts of synchronization and carry propagation  
