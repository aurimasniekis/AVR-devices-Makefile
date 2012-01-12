#
#  Author <insert your name here>
#  Copyright (c) 2012 <insert your copyright message here>
#  License: <insert your license reference here>
#
##########################################################
# Project Settings
##########################################################
PROJECT_NAME = main
OUTPUT_NAME = firmware
TARGET = atmega168
PROGRAMMER_TARGET = m168
SYSTEM_CLOCK = 16000000L
FLASH_AFTER_COMPILE=FALSE
USE_BOOTLOADER=FALSE

##########################################################
# Compiler Options
##########################################################
OPTIMIZATION = s

##########################################################
# Programmer Options
##########################################################
PROGRAMMER = dragon_isp
PORGRMAMER_PORT = usb
PROGRAMMER_OPTIONS =

BOOTLOADER = avrisp
BOOTLOADER_PORT = /dev/tty.usbserial-
BOOTLOADER_OPTIONS = -b 115200

##########################################################
# Project Directories
##########################################################
BUILD_DIR = ./Build
DRIVERS_DIR = ./Drivers
INCLUDES_DIR = ./Includes
LIBRARIES_DIR = ./Libraries
SOURCES_DIR = ./Sources

##########################################################
# Includes
##########################################################
# C Files
C_SRCS = $(wildcard *.c)
C_SRCS += $(wildcard $(DRIVERS_DIR)/*.c)
C_SRCS += $(wildcard $(DRIVERS_DIR)/*/*.c)
C_SRCS += $(wildcard $(DRIVERS_DIR)/*/*/*.c)
C_SRCS += $(wildcard $(SOURCES_DIR)/*.c)
C_SRCS += $(wildcard $(SOURCES_DIR)/*/*.c)
C_SRCS += $(wildcard $(SOURCES_DIR)/*/*/*.c)

# C++ Files
CPP_SRCS = $(wildcard *.cpp)
CPP_SRCS += $(wildcard $(DRIVERS_DIR)/*.cpp)
CPP_SRCS += $(wildcard $(DRIVERS_DIR)/*/*.cpp)
CPP_SRCS += $(wildcard $(DRIVERS_DIR)/*/*/*.cpp)
CPP_SRCS += $(wildcard $(SOURCES_DIR)/*.cpp)
CPP_SRCS += $(wildcard $(SOURCES_DIR)/*/*.cpp)
CPP_SRCS += $(wildcard $(SOURCES_DIR)/*/*/*.cpp)

# ASM Files
AS_SRCS = $(wildcard *.S)
AS_SRCS += $(wildcard $(DRIVERS_DIR)/*.S)
AS_SRCS += $(wildcard $(DRIVERS_DIR)/*/*.S)
AS_SRCS += $(wildcard $(DRIVERS_DIR)/*/*/*.S)
AS_SRCS += $(wildcard $(SOURCES_DIR)/*.S)
AS_SRCS += $(wildcard $(SOURCES_DIR)/*/*.S)
AS_SRCS += $(wildcard $(SOURCES_DIR)/*/*/*.S)

# Header Files
INCLUDES = ./
INCLUDES += $(wildcard $(DRIVERS_DIR))
INCLUDES += $(wildcard $(INCLUDES_DIR))
INCLUDES += $(wildcard $(SOURCES_DIR))

# Generate Object List
OBJECTS = $(C_SRCS:.c=.o) $(CPP_SRCS:.cpp=.o) $(AS_SRCS:.S=.o)
LD_OBJECTS = $(wildcard *.a) $(wildcard $(LIBRARIES_DIR)*.a) $(wildcard $(LIBRARIES_DIR)*/*.a) $(wildcard $(LIBRARIES_DIR)*/*/*.a) $(wildcard $(LIBRARIES_DIR)*.o) $(wildcard $(LIBRARIES_DIR)*/*.o) $(wildcard $(LIBRARIES_DIR)*/*/*.o)

##########################################################
# Tools Path
##########################################################
AVRDUDE = avrdude
AS = avr-gcc
GCC = avr-gcc
GPP = avr-g++
LD = avr-gcc
OBJCOPY = avr-objcopy
OBJDUMP = avr-objdump
SIZE = avr-size
REMOVE = rm -f

##########################################################
# Compiler FLAGS
##########################################################
GCC_FLAGS = -g -mmcu=$(TARGET) -O$(OPTIMIZATION) -DF_CPU=$(SYSTEM_CLOCK) -fpack-struct -fshort-enums -funsigned-bitfields -funsigned-char -Wall -Wstrict-prototypes
GCC_FLAGS += $(patsubst %,-I%,$(INCLUDES)) -I.

GPP_FLAGS = -g -mmcu=$(TARGET) -O$(OPTIMIZATION) -DF_CPU=$(SYSTEM_CLOCK) -fpack-struct -fshort-enums -funsigned-bitfields -funsigned-char -Wall -Wstrict-prototypes -fno-exceptions 
GPP_FLAGS += $(patsubst %,-I%,$(INCLUDES)) -I.

AS_FLAGS = $(LISTING) -mmcu=$(TARGET) -DF_CPU=$(SYSTEM_CLOCK) -x assembler-with-cpp
AS_FLAGS += $(patsubst %,-I%,$(INCLUDES)) -I.

LD_FLAGS = -Wl,-Map,$(BUILD_DIR)/$(OUTPUT_NAME).map -mmcu=$(TARGET)
# Math Library
LD_FLAGS += -lm
# Minimalistic printf version
#LD_FLAGS += -Wl,-u,vfprintf -lprintf_min
# Floating point printf version (require math library above)
#LD_FLAGS += -Wl,-u,vfprintf -lprintf_flt

##########################################################
# Programmer FLAGS
##########################################################

PROGRAMMER_FLAGS = -p $(PROGRAMMER_TARGET) -c $(PROGRAMMER) -P $(PORGRMAMER_PORT) $(PROGRAMMER_OPTIONS)

BOOTLOADER_FLAGS = -p $(PROGRAMMER_TARGET) -c $(BOOTLOADER) -P $(BOOTLOADER_PORT) -F $(BOOTLOADER_OPTIONS)

ifeq ($(FLASH_AFTER_COMPILE),TRUE)
ifeq ($(USE_BOOTLOADER),TRUE)
all:: $(OUTPUT_NAME).hex flash_bootloader
else
all:: $(OUTPUT_NAME).hex flash_programmer
endif
else
all:: $(OUTPUT_NAME).hex
endif

$(OUTPUT_NAME).hex: $(OUTPUT_NAME).elf
	$(OBJCOPY) -j .text -j .data -O ihex $(BUILD_DIR)/$(OUTPUT_NAME).elf $(BUILD_DIR)/$(OUTPUT_NAME).hex
	$(SIZE) $(BUILD_DIR)/$(OUTPUT_NAME).hex

$(OUTPUT_NAME).elf: $(OBJECTS)
	$(LD) $(LD_FLAGS) $(LD_OBJECTS) $(OBJECTS) -o $(BUILD_DIR)/$(OUTPUT_NAME).elf

stats: $(OUTPUT_NAME).hex
	$(SIZE) $(BUILD_DIR)/$(OUTPUT_NAME).hex

clean:
	$(REMOVE) $(OBJECTS)
	$(REMOVE) $(BUILD_DIR)/$(OUTPUT_NAME).hex
	$(REMOVE) $(BUILD_DIR)/$(OUTPUT_NAME).elf
	$(REMOVE) $(BUILD_DIR)/$(OUTPUT_NAME).map
	$(REMOVE) $(OBJECTS)

flash_programmer: $(OUTPUT_NAME).hex
	$(AVRDUDE) $(PROGRAMMER_FLAGS) -U flash:w:$(BUILD_DIR)/$(OUTPUT_NAME).hex

flash_bootloader: $(OUTPUT_NAME).hex
	$(AVRDUDE) $(BOOTLOADER_FLAGS) -U flash:w:$(BUILD_DIR)/$(OUTPUT_NAME).hex


##########################################################
# Default rules to compile .c and .cpp file to .o
# and assemble .S files to .o
##########################################################

.c.o :
	$(GCC) $(GCC_FLAGS) -c $< -o $(<:.c=.o)

.cpp.o :
	$(GPP) $(GPP_FLAGS) -c $< -o $(<:.cpp=.o)

.S.o :
	$(AS) $(AS_FLAGS) -c $< -o $(<:.S=.o)