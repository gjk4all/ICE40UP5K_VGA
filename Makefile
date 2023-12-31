PROJECT   = vga5k
BUILD_DIR = ./build
DEVICE    = up5k
PACKAGE   = sg48

FILES     = main.v
TESTFILE  = test.v
PINMAP    = pinmap.pcf

.PHONY: all clean burn world timings

all: $(PROJECT).bin

$(PROJECT).bin: *.v $(PINMAP)
	mkdir -p $(BUILD_DIR)
	yosys -p "synth_ice40 -top main -json $(BUILD_DIR)/$(PROJECT).json" $(FILES)
	nextpnr-ice40 -r --json $(BUILD_DIR)/$(PROJECT).json --pcf $(PINMAP) --asc $(BUILD_DIR)/$(PROJECT).asc --package $(PACKAGE) --freq 25.175 --timing-allow-fail --$(DEVICE)
	icepack $(BUILD_DIR)/$(PROJECT).asc $(BUILD_DIR)/$(PROJECT).bin

burn: $(BUILD_DIR)/$(PROJECT).bin
	iceprog $(BUILD_DIR)/$(PROJECT).bin

timings:
	icetime -tmd $(DEVICE)  $(BUILD_DIR)/$(PROJECT).asc

test: $(TESTFILE)
	verilator --trace $(TESTFILE) --binary -o test_$(PROJECT)
	obj_dir/test_$(PROJECT)

clean:
	rm -rf $(BUILD_DIR) obj_dir

world: clean all
