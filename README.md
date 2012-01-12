AVR devices Makefile
====================

I made this Makefile from zero so that it could fit my requirements. I am using CrossPack-AVR Toolchain. This Makefile supports after compile upload via programmer or bootloader

Configuring Makefile
--------------------

Project Name:
	PROJECT_NAME = main 
	
Output file used for building and finished .hex will have this name
	OUTPUT_NAME = firmware

MCU which you use for e.g ATmega168
	TARGET = atmega168

MCU option for programmer (avrdude)	
	PROGRAMMER_TARGET = m168
	
System clock default is 16Mhz
	SYSTEM_CLOCK = 16000000L

Flash MCU with fresh code after compile (TRUE/FALSE)
	FLASH_AFTER_COMPILE=FALSE

Use bootloader instead programmer (TRUE/FALSE)
	USE_BOOTLOADER=FALSE
	
Code optimization level (I suggest to leave it s)
	OPTIMIZATION = s

Programmer Options (e.g. programmer=dragon_isp port=usb options=)
	PROGRAMMER = dragon_isp
	PORGRMAMER_PORT = usb
	PROGRAMMER_OPTIONS =

Bootloader Options (e.g. for arduino optiboot programmer=avrisp port=/dev/tty.usb... options= -b 115200)
	BOOTLOADER = avrisp
	BOOTLOADER_PORT = /dev/tty.usbserial-
	BOOTLOADER_OPTIONS = -b 115200
	
Installing for AVR-Project in CrossPack-AVR toolchain
------------------------------------------------------

	$ cd /usr/local/CrossPack-AVR/etc/templates/
	$ mv TemplateProject TemplateProject.old
	$ git clone git://github.com/gcds/AVR-devices-Makefile.git
	$ mv AVR-devices-Makefile  TemplateProject
	