@ bootrom dumper payload
@ (c) pod2g october 2010

@constants -----------------------------------
.pool
@ usb_wait_for_image call offset
.set	RET_ADDR,			0x7ef	@ A4
.set	a4_aes_crypto_cmd,		0x686d

.set	AES_TYPE_GID,			0x20000200

.set	loadaddr,			0x84000000
.set	maxsize,			0x24000
.set	dumpaddr,			0x0
.set	dumpto,				0x84000000
.set	dumpsize,			0x10000
.text
@main code -----------------------------------
.code 16
_start: .global _start
	B	entry_point
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP


.set gpio_custom_io, 0xd21
.set gpio_pin_output, 0xdb1
.set set_pll, 0x94dc

entry_point:

  LDR R0, =0x8000841f
  LDR R1, =0xbf100040
  STR R0, [R1]


# simple test
simple_test:
  LDR R0, =0xbfa00068
  LDR R1, =0x213
  STR R1, [R0]

  BL do_spin_wait
  BL do_spin_wait_crunch
  BL do_spin_wait
  BL do_spin_wait_crunch

  LDR R0, =0xbfa00068
  LDR R1, =0x212
  STR R1, [R0]


  B simple_test



  B do_aes_shit
  #MOV R1, #4
  #LDR R0, =0x302
  #LDR R4, =gpio_custom_io
  #BLX R4

  # divide by 32


  MOV R3, #0
  MOV R2, #0x30
  MOV R1, #1
  LDR R0, =0x3c346000
  LDR R4, =set_pll
  BLX R4

loop2:
  LDR R0, =0xbfa00068
  LDR R1, =0x212
  STR R1, [R0]

  BL do_spin_wait

  LDR R0, =0xbfa00068
  LDR R1, =0x213
  STR R1, [R0]

  BL do_spin_wait

  B loop2

loop:
  # GPIO26, port 3, bit 2
  MOV R1, #1
  LDR R0, =0x302
  LDR R4, =gpio_pin_output
  BLX R4
  
  BL do_spin_wait

  # GPIO26, port 3, bit 2
  MOV R1, #0
  LDR R0, =0x302
  LDR R4, =gpio_pin_output
  BLX R4

  BL do_spin_wait
  B loop


  #LDR R0, =1000000

do_spin_wait:
  LDR R0, =50
spin_wait:
  SUB R0, #1
  CMP R0, #0
  BNE spin_wait
  BX LR

do_spin_wait_crunch:
  LDR R0, =50
spin_wait_crunch:
  MUL R2, R3
  SUB R0, #1
  CMP R0, #0
  BNE spin_wait_crunch
  BX LR


do_aes_shit:

  # GPIO ON
  LDR R0, =0xbfa00068
  LDR R1, =0x213
  STR R1, [R0]

  BL do_spin_wait

	MOV	R0,	#0x11		@ AES_DECRYPT
  # R1 is source?, R2 is target?
	MOV	R4,	#0x14
	ADR	R1,	aes_data
	ADR	R2,	aes_data
	#MOV	R3,	#0x30		@ KBAG_KEY_IV_SIZE
	MOV	R3,	#0x10		@ KBAG_KEY_IV_SIZE
	LDR	R4,	=AES_TYPE_GID
	STR	R4,	[SP]
	MOV	R4,	#0
	STR	R4,	[SP, #4]
	MOV	R4,	#0
	STR	R4,	[SP, #8]
  ldr r4, =a4_aes_crypto_cmd
	BLX	R4

  # GPIO OFF
  LDR R0, =0xbfa00068
  LDR R1, =0x212
  STR R1, [R0]

  B do_aes_shit

	LDR	R0,	=dumpto
	ADR	R1,	data
	LDR	R2,	=0x80
	BL	memcpy

	LDR	R0,	=loadaddr
	LDR	R1,	=maxsize
	MOV	R2,	#0	
	LDR	R3,	=RET_ADDR
	BLX	R3
@-----------------------------------------------------
memcpy:

_memcpy_loop:
        LDRB     R3,     [R1]
        STRB     R3,     [R0]
        ADD     R0,     #1
        ADD     R1,     #1
        SUB     R2,     #1
        CMP     R2,     #0
        BNE     _memcpy_loop

        BX      LR
@-----------------------------------------------------

.align 4
data:
  .byte 0xAA, 0xBB, 0xCC, 0xDD
  .byte 0xAA, 0xBB, 0xCC, 0xDD
  .byte 0xAA, 0xBB, 0xCC, 0xDD
  .byte 0xAA, 0xBB, 0xCC, 0xDD

aes_data:
  .byte 0,1,2,3,4,5,6,7
  .byte 0,1,2,3,4,5,6,7
  .byte 0,1,2,3,4,5,6,7
  .byte 0,1,2,3,4,5,6,7
  .byte 0,1,2,3,4,5,6,7
  .byte 0,1,2,3,4,5,6,7

end_data:
  .byte 0xAA, 0xBB, 0xCC, 0xDD
  .byte 0xAA, 0xBB, 0xCC, 0xDD
  .byte 0xAA, 0xBB, 0xCC, 0xDD
  .byte 0xAA, 0xBB, 0xCC, 0xDD

.end
