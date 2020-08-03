NS_DATAPORT    EQU    0x10    ; NatSemi-defined port window offset.
NE_DATAPORT    EQU    0x10    ; NatSemi-defined port window offset.
NS_RESET       EQU    0x1f    ; Issue a read to reset, a write to clear.

NE1SM_START_PG EQU    0x20    ; First page of TX buffer
NE1SM_STOP_PG  EQU    0x40    ; Last page +1 of RX ring
NESM_START_PG  EQU    0x40    ; First page of TX buffer
NESM_STOP_PG   EQU    0x80    ; Last page +1 of RX ring

E8390_CMD      EQU    0x00    ; The command register (for all pages)
E8390_STOP     EQU    0x01    ; Stop and reset the chip
E8390_START    EQU    0x02    ; Start the chip, clear reset
E8390_RREAD    EQU    0x08    ; Remote read
E8390_NODMA    EQU    0x20    ; Remote DMA
E8390_PAGE0    EQU    0x00    ; Select page chip registers
E8390_PAGE1    EQU    0x40    ; using the two high-order bits
E8390_PAGE2    EQU    0x80
E8390_PAGE3    EQU    0xC0    ; Page 3 is invalid on the real 8390.

E8390_RXOFF    EQU    0x20    ; EN0_RXCR: Accept no packets
E8390_TXOFF    EQU    0x02    ; EN0_TXCR: Transmitter off

               ; Page 0 register offsets.
EN0_CLDALO     EQU    0x01    ; Low byte of current local dma addr  RD
EN0_STARTPG    EQU    0x01    ; Starting page of ring bfr WR
EN0_CLDAHI     EQU    0x02    ; High byte of current local dma addr     RD
EN0_STOPPG     EQU    0x02    ; Ending page +1 of ring bfr WR
EN0_BOUNDARY   EQU    0x03    ; Boundary page of ring bfr RD WR
EN0_TSR        EQU    0x04    ; Transmit status reg RD
EN0_TPSR       EQU    0x04    ; Transmit starting page WR
EN0_NCR        EQU    0x05    ; Number of collision reg RD
EN0_TCNTLO     EQU    0x05    ; Low     byte of tx byte count WR
EN0_FIFO       EQU    0x06    ; FIFO RD
EN0_TCNTHI     EQU    0x06    ; High byte of tx byte count WR
EN0_ISR        EQU    0x07    ; Interrupt status reg RD WR
EN0_CRDALO     EQU    0x08    ; low byte of current remote dma address RD
EN0_RSARLO     EQU    0x08    ; Remote start address reg 0
EN0_CRDAHI     EQU    0x09    ; high byte, current remote dma address RD
EN0_RSARHI     EQU    0x09    ; Remote start address reg 1
EN0_RCNTLO     EQU    0x0a    ; Remote byte count reg WR
EN0_RCNTHI     EQU    0x0b    ; Remote byte count reg WR
EN0_RSR        EQU    0x0c    ; rx status reg RD
EN0_RXCR       EQU    0x0c    ; RX configuration reg WR
EN0_TXCR       EQU    0x0d    ; TX configuration reg WR
EN0_COUNTER0   EQU    0x0d    ; Rcv alignment error counter RD
EN0_DCFG       EQU    0x0e    ; Data configuration reg WR
EN0_COUNTER1   EQU    0x0e    ; Rcv CRC error counter RD
EN0_IMR        EQU    0x0f    ; Interrupt mask reg WR
EN0_COUNTER2   EQU    0x0f    ; Rcv missed frame error counter RD

PORT_BASE      EQU    0x300   ; Default base port

[BITS 16]

    org 0x100

section .text

start:
    push   cs
    pop    ds

    ; Probe for NE2000 card

    ; Try non destructive test first
    mov    dx, PORT_BASE+E8390_CMD
    in     al, dx
    cmp    al, 0xff
    jz     .s_notfound

    ; Attempt potentially destuctive tests
    mov    al, E8390_NODMA | E8390_PAGE1 | E8390_STOP
    mov    dx, PORT_BASE+E8390_CMD
    out    dx, al    ; Receive alignment error counter
    mov    dx, PORT_BASE+EN0_COUNTER0
    in     al, dx
    mov    cl, al    ; Save to REGD (CL)
    mov    al, 0xff
    out    dx, al
    mov    al, E8390_NODMA | E8390_PAGE0
    mov    dx, PORT_BASE+E8390_CMD
    out    dx, al
    mov    dx, PORT_BASE+EN0_COUNTER0
    in     al, dx    ; Clear the counter by reading.
    test   al, al
    jz     .s_found  ; If al is clear then card was found

    ; Card not found
.s_notfound:
    xchg   al, cl    ; Temporarily save al to avoid clobber
    out    dx, al
    mov    ah, 0x09
    mov    dx, notfound_str
    int    0x21
    xchg   al, cl    ; Restore al. al = error value to return
    jmp    .s_exit

    ; Card found
.s_found:
    mov    ah, 0x09
    mov    dx, found_str
    int    0x21
    xor    al, al    ; Clear the error code

    ; exit with al = errcode
.s_exit:
    mov    ah, 0x4C
    int    0x21

notfound_str db "NE2000 not found", 0x0a, 0x0d, "$"
found_str    db "NE2000 found", 0x0a, 0x0d, "$"