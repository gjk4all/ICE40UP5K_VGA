# ICE40UP5K_VGA
An I/O ports only VGA card for a Z80 computer in verilog.

This VGA interface is designed with the UpDuino 3.0. It shows a 80x30 text display in 640x480/60Hz mode.
The output is shown in 16 foreground/background colors from a 64 color palette. The interface is EGA compatible and can be transferred to VGA analog levels using a PMOD VGA adaptor or using an R/2R network (not included in the design).

# Pinout:
## Inputs:
```
GPIO_35 - CLK in, 25.175 MHz from a crystal oscillator. (VGA dotclock)
```
## Output:
```
GPIO_20 - vsync
GPIO_30 - hsync
GPIO_12 - red
GPIO_21 - red intensity
GPIO_13 - green
GPIO_19 - green intensity
GPIO_18 - blue
GPIO_11 - blue intensity
```

# License:
This verilog design is made by me, Gert Jan Kruizinga. It is free fot non-commercial use.
