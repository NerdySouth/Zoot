 /** @type {DocData} */
 var zigAnalysis={
 "typeKinds": ["Unanalyzed","Type","Void","Bool","NoReturn","Int","Float","Pointer","Array","Struct","ComptimeExpr","ComptimeFloat","ComptimeInt","Undefined","Null","Optional","ErrorUnion","InferredErrorUnion","ErrorSet","Enum","Union","Fn","BoundFn","Opaque","Frame","AnyFrame","Vector","EnumLiteral"],
 "rootPkg": 0,
 "rootPkgName": "main",
 "params": {"zigId": "arst","zigVersion": "0.10.0-dev.3659+e5e6eb983","target": "arst","rootName": "root","builds": [{"target": "arst"}]},
 "packages": [{
 "name": "root",
 "file": 0,
 "main": 61,
 "table": {
  "root": 0
 }
}],
 "errors": [],
 "astNodes": [{"file": 0,"line": 0,"col": 0,"name": "(root)","fields": [],"comptime": false},{"file": 0,"line": 0,"col": 0,"fields": [],"comptime": false},{"file": 1,"line": 0,"col": 0,"fields": [],"comptime": false},{"file": 2,"line": 3,"col": 0,"docs": " A register can be read or written, but may have different behavior or characteristics depending on which\n you choose to do. This allows us to instantiate Register instances that\n can handle that fact by having distinct read and write types.","fields": [4,5],"comptime": false},{"file": 0,"line": 0,"col": 0,"name": "Read","docs": "","comptime": true},{"file": 0,"line": 0,"col": 0,"name": "Write","docs": "","fields": [22],"comptime": true},{"file": 2,"line": 8,"col": 0,"comptime": false},{"file": 2,"line": 13,"col": 0,"fields": [8],"comptime": false},{"file": 0,"line": 0,"col": 0,"name": "addr","docs": "","comptime": true},{"file": 2,"line": 26,"col": 0,"fields": [10],"comptime": false},{"file": 0,"line": 0,"col": 0,"name": "self","docs": "","comptime": false},{"file": 2,"line": 39,"col": 0,"fields": [12,13],"comptime": false},{"file": 0,"line": 0,"col": 0,"name": "self","docs": "","comptime": false},{"file": 0,"line": 0,"col": 0,"name": "val","docs": "","comptime": false},{"file": 2,"line": 50,"col": 0,"fields": [15],"comptime": false},{"file": 0,"line": 0,"col": 0,"name": "self","docs": "","comptime": false},{"file": 2,"line": 61,"col": 0,"fields": [17,18],"comptime": false},{"file": 0,"line": 0,"col": 0,"name": "self","docs": "","comptime": false},{"file": 0,"line": 0,"col": 0,"name": "val","docs": "","comptime": false},{"file": 2,"line": 74,"col": 0,"fields": [20,21],"comptime": false},{"file": 0,"line": 0,"col": 0,"name": "self","docs": "","comptime": false},{"file": 0,"line": 0,"col": 0,"name": "new_val","docs": "","comptime": false},{"file": 0,"line": 0,"col": 0,"name": "raw_ptr","comptime": false},{"file": 1,"line": 3,"col": 0,"docs": " A Gpio struct is made up of all the various MMIO registers associated with\n a given GpioBase. See the RK3399 TRM for more info. Chapter 20 in my copy.","fields": [26,27],"comptime": false},{"file": 1,"line": 5,"col": 0,"docs": " Initialize a Gpio instance with a given GpioBase.","fields": [25],"comptime": false},{"file": 0,"line": 0,"col": 0,"name": "base","docs": "","comptime": true},{"file": 0,"line": 0,"col": 0,"name": "data","comptime": false},{"file": 0,"line": 0,"col": 0,"name": "dir","comptime": false},{"file": 1,"line": 18,"col": 0,"docs": " A GpioBase is just an address to the base of a given set of GPIO MMIO\n registers as defined in the RK3399 TRM chapter 20.","fields": [29,30,31,32,33],"comptime": false},{"file": 0,"line": 0,"col": 0,"name": "zero","comptime": false},{"file": 0,"line": 0,"col": 0,"name": "one","comptime": false},{"file": 0,"line": 0,"col": 0,"name": "two","comptime": false},{"file": 0,"line": 0,"col": 0,"name": "three","comptime": false},{"file": 0,"line": 0,"col": 0,"name": "four","comptime": false},{"file": 0,"line": 1,"col": 0,"fields": [],"comptime": false},{"file": 3,"line": 0,"col": 0,"fields": [],"comptime": false},{"file": 4,"line": 13,"col": 0,"comptime": false},{"file": 4,"line": 14,"col": 0,"comptime": false},{"file": 4,"line": 15,"col": 0,"comptime": false},{"file": 4,"line": 16,"col": 0,"comptime": false},{"file": 4,"line": 17,"col": 0,"comptime": false},{"file": 4,"line": 19,"col": 0,"comptime": false},{"file": 4,"line": 20,"col": 0,"comptime": false},{"file": 4,"line": 21,"col": 0,"comptime": false},{"file": 4,"line": 22,"col": 0,"comptime": false},{"file": 4,"line": 23,"col": 0,"comptime": false},{"file": 4,"line": 24,"col": 0,"comptime": false},{"file": 4,"line": 25,"col": 0,"comptime": false},{"file": 4,"line": 26,"col": 0,"comptime": false},{"file": 4,"line": 27,"col": 0,"comptime": false},{"file": 4,"line": 28,"col": 0,"comptime": false},{"file": 4,"line": 29,"col": 0,"comptime": false},{"file": 4,"line": 30,"col": 0,"comptime": false},{"file": 4,"line": 31,"col": 0,"comptime": false},{"file": 4,"line": 32,"col": 0,"comptime": false},{"file": 4,"line": 33,"col": 0,"comptime": false},{"file": 4,"line": 34,"col": 0,"comptime": false},{"file": 4,"line": 35,"col": 0,"comptime": false},{"file": 4,"line": 36,"col": 0,"comptime": false},{"file": 4,"line": 37,"col": 0,"comptime": false},{"file": 4,"line": 38,"col": 0,"comptime": false},{"file": 4,"line": 39,"col": 0,"comptime": false},{"file": 4,"line": 40,"col": 0,"comptime": false},{"file": 4,"line": 41,"col": 0,"comptime": false},{"file": 4,"line": 42,"col": 0,"comptime": false},{"file": 4,"line": 43,"col": 0,"comptime": false},{"file": 4,"line": 44,"col": 0,"comptime": false},{"file": 4,"line": 45,"col": 0,"comptime": false},{"file": 4,"line": 46,"col": 0,"comptime": false},{"file": 4,"line": 47,"col": 0,"comptime": false},{"file": 4,"line": 48,"col": 0,"comptime": false},{"file": 4,"line": 49,"col": 0,"comptime": false},{"file": 4,"line": 50,"col": 0,"comptime": false},{"file": 4,"line": 54,"col": 0,"docs": " Register bitfield struct for the UART RBR, short for Read Buffer\n Register. Address: Operational Base + offset (0x0000)","fields": [74,75],"comptime": false},{"file": 0,"line": 0,"col": 0,"name": "data_input","comptime": false},{"file": 0,"line": 0,"col": 0,"name": "_reserved","comptime": false},{"file": 4,"line": 79,"col": 0,"docs": " UART THR, short for Transmit Holding Register\n Address: Operational Base + offset (0x0000)","fields": [77,78],"comptime": false},{"file": 0,"line": 0,"col": 0,"name": "data_output","comptime": false},{"file": 0,"line": 0,"col": 0,"name": "_reserved","comptime": false},{"file": 4,"line": 106,"col": 0,"docs": " UART DLL register, short for Divisor Latch (Low)\n Address: Operational Base + offset (0x0000)","fields": [80,81],"comptime": false},{"file": 0,"line": 0,"col": 0,"name": "baud_rate_divisor_L","comptime": false},{"file": 0,"line": 0,"col": 0,"name": "_reserved","comptime": false},{"file": 4,"line": 127,"col": 0,"docs": " UART DLH register, short for Divisor Latch (High)\n Address: Operational Base + offset (0x0004)","fields": [83,84],"comptime": false},{"file": 0,"line": 0,"col": 0,"name": "baud_rate_divisor_H","comptime": false},{"file": 0,"line": 0,"col": 0,"name": "_reserved","comptime": false},{"file": 4,"line": 139,"col": 0,"docs": " UART IER, short for Interrupt Enable Register\n Address: Operational Base + offset (0x0004)","fields": [86,87,88,89,90,91,92],"comptime": false},{"file": 0,"line": 0,"col": 0,"name": "recv_data_aval_int_en","docs": " Enable Received Data Available Interrupt.\n This is used to enable/disable the generation of Received Data\n Available Interrupt and the Character Timeout Interrupt (if in FIFO\n mode and FIFOs enabled). These are the second highest priority\n interrupts.\n\n Attr: RW","comptime": false},{"file": 0,"line": 0,"col": 0,"name": "trans_hold_empty_int_en","docs": " Enable Transmit Holding Register Empty Interrupt.\n\n Attr: RW","comptime": false},{"file": 0,"line": 0,"col": 0,"name": "recv_line_status_int_en","docs": " Enable Receiver Line Status Interrupt.\n This is used to enable/disable the generation of Receiver Line Status\n Interrupt. This is the highest priority interrupt.\n\n Attr: RW","comptime": false},{"file": 0,"line": 0,"col": 0,"name": "modem_status_int_en","docs": " Enable Modem Status Interrupt.\n This is used to enable/disable the generation of Modem Status Interrupt.\n This is the fourth highest priority interrupt\n\n Attr: RW","comptime": false},{"file": 0,"line": 0,"col": 0,"name": "_reserved4_6","docs": " Should be 0, bits 4:6\n Attr: RO","comptime": false},{"file": 0,"line": 0,"col": 0,"name": "prog_thre_int_en","docs": " Programmable THRE Interrupt Mode Enable\n This is used to enable/disable the generation of THRE Interrupt.\n\n Attr: RW","comptime": false},{"file": 0,"line": 0,"col": 0,"name": "_reserved8_31","docs": " Should be 0, bits 8:31\n Attr: RO","comptime": false},{"file": 4,"line": 179,"col": 0,"docs": " UART IIR, short for Interrupt Identification Register\n Address: Operational Base + offset (0x0008)","fields": [94,95,96,97],"comptime": false},{"file": 0,"line": 0,"col": 0,"name": "int_id","docs": " Interrupt ID\n\n This indicates the highest priority pending interrupt which can be one\n of the following types:\n 0000 = modem status\n 0001 = no interrupt pending\n 0010 = THR empty\n 0100 = received data available\n 0110 = receiver line status\n 0111 = busy detect\n 1100 = character timeout\n\n Attr: RO","comptime": false},{"file": 0,"line": 0,"col": 0,"name": "_reserved4_5","docs": " Should be 0, bits 4:5\n Attr: RO","comptime": false},{"file": 0,"line": 0,"col": 0,"name": "fifos_en","docs": " FIFOs Enabled.\n\n This is used to indicate whether the FIFOs are enabled or disabled.\n 00 = disabled\n 11 = Enabled\n Attr: RO","comptime": false},{"file": 0,"line": 0,"col": 0,"name": "_reserved8_31","docs": " Should be 0, bits 8:31,\n Attr: RO","comptime": false},{"file": 4,"line": 211,"col": 0,"docs": " UART FCR, short for FIFO Control Register\n Address: Operational Base + offset (0x0008)","fields": [99,100,101,102,103,104,105],"comptime": false},{"file": 0,"line": 0,"col": 0,"name": "fifo_en","docs": " FIFO Enable.\n FIFO Enable. This enables/disables the transmit (XMIT) and receive\n (RCVR) FIFOs. Whenever the value of this bit is changed both the XMIT\n and RCVR controller portion of FIFOs is reset.\n\n Attr: WO (Write Only)","comptime": false},{"file": 0,"line": 0,"col": 0,"name": "rcvr_fifo_reset","docs": " RCVR FIFO Reset.\n\n This resets the control portion of the receive FIFO and treats the\n FIFO as empty. This also de-asserts the DMA RX request and single\n signals when additional DMA handshaking signals are selected. Note\n that this bit is 'self-clearing'. It is not necessary to clear this bit","comptime": false},{"file": 0,"line": 0,"col": 0,"name": "xmit_fifo_reset","docs": " XMIT FIFO Reset.\n\n This resets the control portion of the transmit FIFO and treats the\n FIFO as empty. This also de-asserts the DMA TX request and single\n signals when additional DMA handshaking signals are selected . Note\n that this bit is 'self-clearing'. It is not necessary to clear this bit","comptime": false},{"file": 0,"line": 0,"col": 0,"name": "dma_mode","docs": " DMA Mode\n\n This determines the DMA signalling mode used for the dma_tx_req_n and\n dma_rx_req_n output signals when additional DMA handshaking signals\n are not selected .\n 0 = mode 0\n 1 = mode 11100 = character timeout.\n\n Attr: WO","comptime": false},{"file": 0,"line": 0,"col": 0,"name": "tx_empty_trigger","docs": " TX Empty Trigger.\n\n This is used to select the empty threshold level at which the THRE\n Interrupts are generated when the mode is active. It also determines\n when the dma_tx_req_n signal is asserted when in certain modes of\n operation. The following trigger levels are supported:\n 00 = FIFO empty\n 01 = 2 characters in the FIFO\n 10 = FIFO 1/4 full\n 11 = FIFO 1/2 full\n\n Attr: WO","comptime": false},{"file": 0,"line": 0,"col": 0,"name": "rcvr_trigger","docs": " RCVR Trigger\n\n This is used to select the trigger level in the receiver FIFO at which\n the Received Data Available Interrupt is generated. In auto flow\n control mode it is used to determine when the rts_n signal is\n de-asserted. It also determines when the dma_rx_req_n signal is\n asserted in certain modes of operation. The following trigger levels\n are supported:\n\n 00 = 1 character in the FIFO\n 01 = FIFO 1/4 full\n 10 = FIFO 1/2 full\n 11 = FIFO 2 less than ful (-> is this an errata?)\n\n Attr: WO","comptime": false},{"file": 0,"line": 0,"col": 0,"name": "_reserved8_31","docs": " Should be 0, bits 8:31\n Attr: RO","comptime": false},{"file": 4,"line": 279,"col": 0,"docs": " UART LCR, short for Line Control Register\n Address: Operational Base + offset (0x000C)","fields": [107,108,109,110,111,112,113,114],"comptime": false},{"file": 0,"line": 0,"col": 0,"name": "data_len_sel","docs": " Data Length Select.\n Writeable only when UART is not busy (USR[0] is zero), always readable.\n This is used to select the number of data bits per character that the\n peripheral transmits and receives. The number of bit that may be\n selected areas follows:\n 00 = 5 bits\n 01 = 6 bits\n 10 = 7 bits\n 11 = 8 bits\n\n Attr: RW","comptime": false},{"file": 0,"line": 0,"col": 0,"name": "stop_bits_num","docs": " Number of stop bits.\n Writeable only when UART is not busy (USR[0] is zero), always readable.\n This is used to select the number of stop bits per character that the\n peripheral transmits and receives. If set to zero, one stop bit is\n transmitted in the serial data. If set to one and the data bits are\n set to 5 (LCR[1:0] set to zero) one and a half stop bits is transmitted\n Otherwise, two stop bits are transmitted. Note that regardless of the\n number of stop bits selected, the receiver checks only the first stop\n bit.\n 0 = 1 stop bit\n 1 = 1.5 stop bits when DLS (LCR[1:0]) is zero, else 2 stop bit.\n\n Attr: RW","comptime": false},{"file": 0,"line": 0,"col": 0,"name": "parity_en","docs": " Parity Enable.\n Writeable only when UART is not busy (USR[0] is zero), always readable.\n This bit is used to enable and disable parity generation and detection\n in transmitted and received serial character respectively.\n 0 = parity disabled\n 1 = parity enabled\n\n Attr: RW","comptime": false},{"file": 0,"line": 0,"col": 0,"name": "even_parity_sel","docs": " Even Parity Select.\n\n Writeable only when UART is not busy (USR[0] is zero), always readable.\n This is used to select between even and odd parity, when parity is\n enabled (PEN set to one). If set to one, an even number of logic 1s\n is transmitted or checked. If set to zero, an odd number of logic 1s\n is transmitted or checked.\n\n Attr: RW","comptime": false},{"file": 0,"line": 0,"col": 0,"name": "_reserved","docs": " SBZ, Bit 5","comptime": false},{"file": 0,"line": 0,"col": 0,"name": "break_ctrl","docs": " Break Control bit\n\n This is used to cause a break condition to be transmitted to the\n receiving device. If set to one the serial output is forced to the\n spacing (logic 0) state. When not in Loopback Mode, as determined by\n MCR[4], the sout line is forced low until the Break bit is cleared.\n If MCR[6] set to one, the sir_out_n line is continuously pulsed. When\n in Loopback Mode, the break condition is internally looped back to\n the receiver and the sir_out_n line is forced low.\n\n Attr: RW","comptime": false},{"file": 0,"line": 0,"col": 0,"name": "div_lat_access","docs": " Divisor Latch Access Bit.\n Writeable only when UART is not busy (USR[0] is zero), always readable.\n This bit is used to enable reading and writing of the Divisor Latch\n register (DLL and DLH) to set the baud rate of the UART. This bit must\n be cleared after initial baud rate setup in order to access other\n registers.\n\n Attr: RW","comptime": false},{"file": 0,"line": 0,"col": 0,"name": "_reserved8_31","docs": " SBZ, bits 8:31\n Attr: RO","comptime": false},{"file": 4,"line": 356,"col": 0,"docs": " UART MCR, short for Modem Control Register\n Address: Operational Base + offset (0x0010)","fields": [116,117,118,119,120,121,122,123],"comptime": false},{"file": 0,"line": 0,"col": 0,"name": "data_term_ready","docs": " Data Terminal Ready.\n\n This is used to directly control the Data Terminal Ready (dtr_n) output.\n The value written to this location is inverted and driven out on\n dtr_n, that is:\n 0 = dtr_n de-asserted (logic 1)\n 1 = dtr_n asserted (logic 0)\n\n Attr: RW","comptime": false},{"file": 0,"line": 0,"col": 0,"name": "req_to_send","docs": " Request to Send.\n\n This is used to directly control the Request to Send (rts_n) output.\n The Request To Send (rts_n) output is used to inform the modem or data\n set that the UART is ready to exchange data.\n\n Attr: RW","comptime": false},{"file": 0,"line": 0,"col": 0,"name": "out1","docs": " OUT1\n\n This is used to directly control the user-designated Output1 (out1_n)\n output. The value written to this location is inverted and driven out\n on out1_n, that is:\n 1’b0: out1_n de-asserted (logic 1)\n 1’b1: out1_n asserted (logic 0)\n\n Attr: RW","comptime": false},{"file": 0,"line": 0,"col": 0,"name": "out2","docs": " OUT2, same as above but with 2 :)","comptime": false},{"file": 0,"line": 0,"col": 0,"name": "loopback","docs": " Loopback Bit\n\n This is used to put the UART into a diagnostic mode for test purposes.\n\n Attr: RW","comptime": false},{"file": 0,"line": 0,"col": 0,"name": "auto_flow_ctrl_en","docs": " Auto Flow Control Enable\n\n Auto Flow Control Enable.\n 0 = Auto Flow Control Mode disabled\n 1 = Auto Flow Control Mode enabled\n\n Attr: RW","comptime": false},{"file": 0,"line": 0,"col": 0,"name": "sir_mode_en","docs": " SIR Mode Enable\n\n This is used to enable/disable the IrDA SIR Mode.\n 0 = irda sir mode disabled\n 1 = IrDA SIR Mode Enabled\n\n Attr: RW","comptime": false},{"file": 0,"line": 0,"col": 0,"name": "_reserved7_31","docs": " SBZ, bits 7:31","comptime": false},{"file": 4,"line": 415,"col": 0,"docs": " UART LSR, short for Line Status Register\n Address: Operational Base + offset (0x0014)","fields": [125,126,127,128,129,130,131,132],"comptime": false},{"file": 0,"line": 0,"col": 0,"name": "data_ready","docs": " Data Ready bit.\n\n This is used to indicate that the receiver contains at least one\n character in the RBR or the receiver FIFO.\n 0 = no data ready\n 1 = data ready\n\n Attr: RO","comptime": false},{"file": 0,"line": 0,"col": 0,"name": "overrun_error","docs": " Overrun error bit.\n This is used to indicate the occurrence of an overrun error.\n This occurs if a new data character was received before the previous\n data was read.\n\n Attr: RO","comptime": false},{"file": 0,"line": 0,"col": 0,"name": "parity_error","docs": " Parity Error Bit\n\n This is used to indicate the occurrence of a parity error in the\n receiver if the Parity Enable (PEN) bit (LCR[3]) is set.\n\n Attr: RO","comptime": false},{"file": 0,"line": 0,"col": 0,"name": "framing_error","docs": " Framing Error Bit\n\n This is used to indicate the occurrence of a framing error in the\n receiver. A framing error occurs when the receiver does not detect a\n valid STOP bit in the received data.\n\n Attr: RO","comptime": false},{"file": 0,"line": 0,"col": 0,"name": "trans_hold_reg_empty","docs": " Transmit Holding Register Empty bit.\n If THRE mode is disabled (IER[7] set to zero) and regardless of FIFO's\n being implemented/enabled or not, this bit indicates that the THR or\n TX FIFO is empty.\n\n This bit is set whenever data is transferred from the THR or TX FIFO to\n the transmitter shift register and no new data has been written to the\n THR or TX FIFO. This also causes a THRE Interrupt to occur, if the\n THRE Interrupt is enabled. If IER[7] set to one and FCR[0] set to one\n respectively, the functionality is switched to indicate the\n transmitter FIFO is full, and no longer controls THRE interrupts,\n which are then controlled by the FCR[5:4] threshold setting.\n\n Attr: RO","comptime": false},{"file": 0,"line": 0,"col": 0,"name": "trans_empty","docs": " Transmitter Empty bit\n\n Transmitter Empty bit. If FIFOs enabled (FCR[0] set to one), this bit\n is set whenever the Transmitter Shift Register and the FIFO are both\n empty. If FIFOs are disabled, this bit is set whenever the Transmitter\n Holding Register and the Transmitter Shift Register are both empty.\n\n Attr: RO","comptime": false},{"file": 0,"line": 0,"col": 0,"name": "recv_fifo_error","docs": " Receiver FIFO Error bit.\n\n This bit is relevant FIFOs are enabled (FCR[0] set to one). This is\n used to indicate if there is at least one parity error, framing error,\n or break indication in the FIFO.\n 0 = no error in RX FIFO\n 1 = error in RX FIFO\n\n Attr: RO","comptime": false},{"file": 0,"line": 0,"col": 0,"name": "_reserved8_31","docs": " SBZ, bits 8:31\n\n Attr: RO","comptime": false},{"file": 4,"line": 490,"col": 0,"docs": " UART MSR, short for Modem Status Register\n Address: Operational Base + offset (0x0018)\n Attr: RO","fields": [134,135,136,137,138,139,140,141],"comptime": false},{"file": 0,"line": 0,"col": 0,"name": "delta_clear_to_sent","docs": " Delta Clear to Send.\n This is used to indicate that the modem control line cts_n has changed\n since the last time the MSR was read.","comptime": false},{"file": 0,"line": 0,"col": 0,"name": "delta_data_set_ready","docs": " Delta Data Set Ready.\n\n This is used to indicate that the modem control line dsr_n has changed\n since the last time the MSR was read.","comptime": false},{"file": 0,"line": 0,"col": 0,"name": "trailing_edge_ring_indicator","docs": " Trailing Edge of Ring Indicator.\n\n Trailing Edge of Ring Indicator. This is used to indicate that a\n change on the input ri_n (from an active-low to an inactive-high state)\n has occurred since the last time the MSR was read.","comptime": false},{"file": 0,"line": 0,"col": 0,"name": "delta_data_carrier_detect","docs": " Delta Data Carrier Detect.\n\n This is used to indicate that the modem control line dcd_n has changed\n since the last time the MSR was read.","comptime": false},{"file": 0,"line": 0,"col": 0,"name": "data_set_ready","docs": " Data Set Ready.\n\n This is used to indicate the current state of the modem control line\n dsr_n.","comptime": false},{"file": 0,"line": 0,"col": 0,"name": "ring_indicator","docs": " Ring Indicator\n\n This is used to indicate the current state of the modem control line ri_n.","comptime": false},{"file": 0,"line": 0,"col": 0,"name": "data_carrier_detect","docs": " Data Carrier Detect.\n This is used to indicate the current state of the modem control line\n dcd_n.","comptime": false},{"file": 0,"line": 0,"col": 0,"name": "_reserved8_31","docs": " SBZ bits 8:31","comptime": false},{"file": 4,"line": 530,"col": 0,"docs": " UART SCR, short for Scratch Pad Register\n Address: Operational Base + offset (0x001C)","fields": [143,144],"comptime": false},{"file": 0,"line": 0,"col": 0,"name": "temp_store_space","docs": " This register is for programmers to use as a temporary storage space.\n Attr: RW","comptime": false},{"file": 0,"line": 0,"col": 0,"name": "_reserved8_31","docs": " SBZ, bits 8:31","comptime": false},{"file": 4,"line": 541,"col": 0,"docs": " UART SRBR, short for Shadow Recv Buffer Register\n Address: Operational Base + offset (0x0030)\n Attr: RO","fields": [146,147],"comptime": false},{"file": 0,"line": 0,"col": 0,"name": "shadow_rbr","docs": " This is a shadow register for the RBR and has been allocated sixteen\n 32-bit locations so as to accommodate burst accesses from the master.\n This register contains the data byte received on the serial input port\n (sin) in UART mode or the serial infrared input (sir_in) in infrared\n mode. The data in this register is valid only if the Data Ready (DR)\n bit in the Line status Register (LSR) is set.\n\n If FIFOs are disabled (FCR[0] set to zero), the data in the RBR must\n be read before the next data arrives, otherwise it is overwritten,\n resulting in an overrun error.\n\n If FIFOs are enabled (FCR[0] set to one), this register accesses the\n head of the receive FIFO. If the receive FIFO is full and this register\n is not read before the next data character arrives, then the data\n already in the FIFO are preserved, but any incoming data is lost. An\n overrun error also occurs.","comptime": false},{"file": 0,"line": 0,"col": 0,"name": "_reserved8_31","docs": " SBZ, bits 8:31","comptime": false},{"file": 4,"line": 566,"col": 0,"docs": " UART STHR, short for Shadow Transmit Holding Register\n Address: Operational Base + offset (0x006C)\n Attr: RO","fields": [149,150],"comptime": false},{"file": 0,"line": 0,"col": 0,"name": "shadow_thr","docs": " This is a shadow register for the THR.","comptime": false},{"file": 0,"line": 0,"col": 0,"name": "_reserved8_31","comptime": false},{"file": 4,"line": 574,"col": 0,"docs": " UART FAR, short for FIFO Access Register\n Address: Operational Base + offset (0x0070)","fields": [152,153],"comptime": false},{"file": 0,"line": 0,"col": 0,"name": "fifo_access_test_en","docs": " This register is use to enable a FIFO access mode for testing, so that\n the receive FIFO can be written by the master and the transmit FIFO\n can be read by the master when FIFOs are implemented and enabled.\n When FIFOs are not enabled it allows the RBR to be written by the\n master and the THR to be read by the master.\n 0 = FIFO access mode disabled\n 1 = FIFO access mode Enabled\n\n Attr: RW","comptime": false},{"file": 0,"line": 0,"col": 0,"name": "_reserved1_31","docs": " SBZ Bits 1:31\n Attr: RO","comptime": false},{"file": 4,"line": 593,"col": 0,"docs": " UART TFR, short for Transmit FIFO Read\n Address: Operational Base + offset (0x0074)\n Attr: RO","fields": [155,156],"comptime": false},{"file": 0,"line": 0,"col": 0,"name": "trans_fifo_read","docs": " Transmit FIFO Read.\n\n These bits are only valid when FIFO access mode is enabled (FAR[0] is\n set to one).When FIFOs are implemented and enabled, reading this\n register gives the data at the top of the transmit FIFO. Each\n consecutive read pops the transmit FIFO and gives the next data value\n that is currently at the top of the FIFO.","comptime": false},{"file": 0,"line": 0,"col": 0,"name": "_reserved8_31","docs": " SBZ, Bits 8:31","comptime": false},{"file": 4,"line": 609,"col": 0,"docs": " UART RFW, short for Receive FIFO Write\n Address: Operational Base + offset (0x0078)\n Attr: WO","fields": [158,159,160,161],"comptime": false},{"file": 0,"line": 0,"col": 0,"name": "recv_fifo_write","docs": " Receive FIFO Write Data.\n\n These bits are only valid when FIFO access mode is enabled (FAR[0] is\n set to one).\n\n When FIFOs are enabled, the data that is written to the RFWD is\n pushed into the receive FIFO. Each consecutive write pushes the new\n data to the next write location in the receive FIFO.\n\n When FIFOs not enabled, the data that is written to the RFWD is pushed\n into the RBR.","comptime": false},{"file": 0,"line": 0,"col": 0,"name": "recv_fifo_parity_error","docs": " Receive FIFO Parity Error.\n\n These bits are only valid when FIFO access mode is enabled (FAR[0] is\n set to one).","comptime": false},{"file": 0,"line": 0,"col": 0,"name": "recv_fifo_framing_error","docs": " Receive FIFO Framing Error.\n\n These bits are only valid when FIFO access mode is enabled (FAR[0] is\n set to one).","comptime": false},{"file": 0,"line": 0,"col": 0,"name": "_reserved10_31","docs": " SBZ, Bits 10:31","comptime": false},{"file": 4,"line": 639,"col": 0,"docs": " UART USR, short for UART Status Register\n Address: Operational Base + offset (0x007C)\n Attr: RO","fields": [163,164,165,166,167,168],"comptime": false},{"file": 0,"line": 0,"col": 0,"name": "uart_busy","docs": " UART Busy.\n\n UART Busy. This is indicates that a serial transfer is in progress,\n when cleared indicates that the UART is idle or inactive.\n 0 = UART is idle or inactive\n 1 = UART is busy (actively transferring data)","comptime": false},{"file": 0,"line": 0,"col": 0,"name": "trans_fifo_not_full","docs": " Transmit FIFO Not Full.\n\n This is used to indicate that the transmit FIFO in not full.\n 0 = Transmit FIFO is full\n 1 = Transmit FIFO is not full\n This bit is cleared when the TX FIFO is full.","comptime": false},{"file": 0,"line": 0,"col": 0,"name": "trans_fifo_empty","docs": " Transmit FIFO Empty.\n\n This is used to indicate that the transmit FIFO is completely empty.\n 0 = Transmit FIFO is not empty\n 1 = Transmit FIFO is empty\n This bit is cleared when the TX FIFO is no longer empty","comptime": false},{"file": 0,"line": 0,"col": 0,"name": "recv_fifo_not_empty","docs": " Receive FIFO Not Empty.\n\n This is used to indicate that the receive FIFO contains one or more\n entries.\n 0 = Receive FIFO is empty\n 1 = Receive FIFO is not empty\n This bit is cleared when the RX FIFO is empty.","comptime": false},{"file": 0,"line": 0,"col": 0,"name": "recv_fifo_full","docs": " Receive FIFO Full.\n\n This is used to indicate that the receive FIFO is completely full.\n 0 = Receive FIFO not full\n 1 = Receive FIFO Full\n This bit is cleared when the RX FIFO is no longer full.","comptime": false},{"file": 0,"line": 0,"col": 0,"name": "_reserved5_31","docs": " SBZ, Bits 5:31","comptime": false},{"file": 4,"line": 683,"col": 0,"docs": " UART TFL, short for Transmit FIFO Level\n Address: Operational Base + offset (0x0080)\n Attr: RW","fields": [170,171],"comptime": false},{"file": 0,"line": 0,"col": 0,"name": "trans_fifo_lvl","docs": " Transmit FIFO Level\n\n This indicates the number of data entries in the transmit FIFO","comptime": false},{"file": 0,"line": 0,"col": 0,"name": "_reserved5_31","docs": " SBZ, Bits 5:31","comptime": false},{"file": 4,"line": 695,"col": 0,"docs": " UART RFL, short for Recv FIFO Level\n Address: Operational Base + offset (0x0084)\n Attr: RO","fields": [173,174],"comptime": false},{"file": 0,"line": 0,"col": 0,"name": "recv_fifo_lvl","docs": " Receive FIFO Level.\n\n This is indicates the number of data entries in the receive FIFO.","comptime": false},{"file": 0,"line": 0,"col": 0,"name": "_reserved5_31","docs": " SBZ, Bits 5:31","comptime": false},{"file": 4,"line": 707,"col": 0,"docs": " UART SRR, short for Software Reset Register\n Address: Operational Base + offset (0x0088)\n Attr: WO","fields": [176,177,178,179],"comptime": false},{"file": 0,"line": 0,"col": 0,"name": "uart_reset","docs": " UART Reset.\n\n This asynchronously resets the UART and synchronously removes the\n reset assertion. For a two clock implementation both pclk and sclk\n domains are reset.","comptime": false},{"file": 0,"line": 0,"col": 0,"name": "rcvr_fifo_reset","docs": " RCVR FIFO Reset\n\n This is a shadow register for the RCVR FIFO Reset Bit (FCR[1])","comptime": false},{"file": 0,"line": 0,"col": 0,"name": "xmit_fifo_reset","docs": " XMIT FIFO Reset\n\n This is a shadow for the XMIT FIFO Reset bit (FCR[2])","comptime": false},{"file": 0,"line": 0,"col": 0,"name": "_reserved3_31","docs": " SBZ, Bits 3:31","comptime": false},{"file": 4,"line": 729,"col": 0,"docs": " UART SRTS, short for Software Request To Send\n Address: Operational Base + offset (0x008C)\n Attr: RW","fields": [181,182],"comptime": false},{"file": 0,"line": 0,"col": 0,"name": "shadow_req_to_send","docs": " Shadow Request to Send.\n\n This is a shadow register for the RTS bit (MCR[1]), this can be used\n to remove the burden of having to performing a read- modify-write on\n the MCR.","comptime": false},{"file": 0,"line": 0,"col": 0,"name": "_reserved1_31","docs": " SBZ, Bits 1:31","comptime": false},{"file": 4,"line": 743,"col": 0,"docs": " UART SBCR, short for Shadow Break Control Register\n Address: Operational Base + offset (0x0090)\n Attr: RW","fields": [184,185],"comptime": false},{"file": 0,"line": 0,"col": 0,"name": "shadow_break_ctrl","docs": " Shadow Break Control Bit.\n\n This is a shadow register for the Break bit (LCR[6]), this can be used\n to remove the burden of having to performing a read modify write on\n the LCR.","comptime": false},{"file": 0,"line": 0,"col": 0,"name": "_reserved1_31","docs": " SBZ, Bits 1:31","comptime": false},{"file": 4,"line": 757,"col": 0,"docs": " UART SDMAM, short for Shadow DMA Mode\n Address: Operational Base + offset (0x0094)\n Attr: RW","fields": [187,188],"comptime": false},{"file": 0,"line": 0,"col": 0,"name": "shadow_dma_mode","docs": " Shadow DMA Mode.\n\n This is a shadow register for the DMA mode bit (FCR[3]).","comptime": false},{"file": 0,"line": 0,"col": 0,"name": "_reserved1_31","docs": " SBZ, Bits 1:31","comptime": false},{"file": 4,"line": 769,"col": 0,"docs": " UART SFE, short for Shadow FIFO Control\n Address: Operational Base + offset (0x0098)\n Attr: RW","fields": [190,191],"comptime": false},{"file": 0,"line": 0,"col": 0,"name": "shadow_fifo_en","docs": " Shadow FIFO Enable.\n\n Shadow FIFO Enable. This is a shadow register for the FIFO enable bit\n (FCR[0]).","comptime": false},{"file": 0,"line": 0,"col": 0,"name": "_reserved1_31","docs": " SBZ, Bits 1:31","comptime": false},{"file": 4,"line": 782,"col": 0,"docs": " UART SRT, short for Shadow RCVR Trigger\n Address: Operational Base + offset (0x009C)\n  Attr: RW","fields": [193,194],"comptime": false},{"file": 0,"line": 0,"col": 0,"name": "shadow_rcvr_trigger","docs": " Shadow RCVR Trigger.\n\n This is a shadow register for the RCVR trigger bits (FCR[7:6]).","comptime": false},{"file": 0,"line": 0,"col": 0,"name": "_reserved1_31","docs": " SBZ, Bits 1:31","comptime": false},{"file": 4,"line": 794,"col": 0,"docs": " UART STET, short for Shadow TX Empty Register\n Address: Operational Base + offset (0x00A0)\n Attr: RW","fields": [196,197],"comptime": false},{"file": 0,"line": 0,"col": 0,"name": "shadow_tx_empty_trigger","docs": " Shadow TX Empty Trigger.\n\n This is a shadow register for the TX empty trigger bits (FCR[5:4]).","comptime": false},{"file": 0,"line": 0,"col": 0,"name": "_reserved1_31","docs": " SBZ, Bits 1:31","comptime": false},{"file": 4,"line": 806,"col": 0,"docs": " UART HTX, short for Halt TX\n Address: Operational Base + offset (0x00A4)\n Attr: RW","fields": [199,200],"comptime": false},{"file": 0,"line": 0,"col": 0,"name": "halt_tx_en","docs": " This register is use to halt transmissions for testing, so that the\n transmit FIFO can be filled by the master when FIFOs are implemented\n and enabled.\n 0 = Halt TX disabled\n 1 = Halt TX enabled","comptime": false},{"file": 0,"line": 0,"col": 0,"name": "_reserved1_31","docs": " SBZ, Bits 1:31","comptime": false},{"file": 4,"line": 820,"col": 0,"docs": " UART DMASA, short for DMA Software Acknowledge\n Address: Operational Base + offset (0x00A8)\n Attr: WO","fields": [202,203],"comptime": false},{"file": 0,"line": 0,"col": 0,"name": "dma_software_ack","docs": " This register is use to perform a DMA software acknowledge if a\n transfer needs to be terminated due to an error condition.","comptime": false},{"file": 0,"line": 0,"col": 0,"name": "_reserved1_31","docs": " SBZ, Bits 1:31","comptime": false},{"file": 4,"line": 832,"col": 0,"docs": " UART CPR, short for Component Parameter Register\n Address: Operational Base + offset (0x00F4)\n UART_CPR is UART0’s own unique register !!!\n Attr: RO","fields": [205,206,207,208,209,210,211,212,213,214,215,216,217,218,219],"comptime": false},{"file": 0,"line": 0,"col": 0,"name": "APB_DATA_WIDTH","docs": " 00 = 8 bits\n 01 = 16 bits\n 10 = 32 bits\n 11 = reserved","comptime": false},{"file": 0,"line": 0,"col": 0,"name": "_reserved2_3","docs": " SBZ","comptime": false},{"file": 0,"line": 0,"col": 0,"name": "AFCE_MODE","docs": " 0 = FALSE\n 1 = TRUE","comptime": false},{"file": 0,"line": 0,"col": 0,"name": "THRE_MODE","docs": " 0 = FALSE\n 1 = TRUE","comptime": false},{"file": 0,"line": 0,"col": 0,"name": "SIR_MODE","comptime": false},{"file": 0,"line": 0,"col": 0,"name": "SIR_LP_MODE","comptime": false},{"file": 0,"line": 0,"col": 0,"name": "NEW_FEAT","comptime": false},{"file": 0,"line": 0,"col": 0,"name": "FIFO_ACCESS","comptime": false},{"file": 0,"line": 0,"col": 0,"name": "FIFO_STAT","comptime": false},{"file": 0,"line": 0,"col": 0,"name": "SHADOW","comptime": false},{"file": 0,"line": 0,"col": 0,"name": "UART_ADD_ENCODED_PARAMS","comptime": false},{"file": 0,"line": 0,"col": 0,"name": "DMA_EXTRA","comptime": false},{"file": 0,"line": 0,"col": 0,"name": "_reserved14_15","comptime": false},{"file": 0,"line": 0,"col": 0,"name": "FIFO_MODE","docs": " FIFO Mode\n 0x00 = 0\n 0x01 = 16\n 0x02 = 32\n to\n 0x80 = 2048\n 0x81 - 0xFF = Reserved","comptime": false},{"file": 0,"line": 0,"col": 0,"name": "_reserved24_31","comptime": false},{"file": 4,"line": 869,"col": 0,"docs": " UART UCV, short for UART Component Version\n Address: Operational Base + offset (0x00F8)\n Attr: RO","fields": [221],"comptime": false},{"file": 0,"line": 0,"col": 0,"name": "version","docs": " Version\n\n ASCII valye for each number in the version","comptime": false},{"file": 4,"line": 879,"col": 0,"docs": " UART CTR, short for Component Type Register\n Address: Operational Base + offset (0x00FC)\n Attr: RO","fields": [223],"comptime": false},{"file": 0,"line": 0,"col": 0,"name": "peripheral_id","docs": " This register contains the peripherals identification code.","comptime": false},{"file": 3,"line": 1,"col": 0,"fields": [],"comptime": false},{"file": 5,"line": 0,"col": 0,"comptime": false},{"file": 5,"line": 8,"col": 0,"docs": " IOMUX: IO Multiplexing\n This is for the problem of having more onboard perpherals/services than\n we have pins for. Although each pin on the system can only be used for\n one peripheral/service at a time, we can dynamically assign which perpherals\n or service it should perform internally.\n See the GRF (General Register Files) chapter of the RK3399 TRM for more\n info","comptime": false},{"file": 5,"line": 9,"col": 0,"comptime": false},{"file": 5,"line": 10,"col": 0,"comptime": false},{"file": 5,"line": 11,"col": 0,"comptime": false},{"file": 5,"line": 12,"col": 0,"comptime": false},{"file": 5,"line": 14,"col": 0,"fields": [234],"comptime": false},{"file": 5,"line": 3,"col": 0,"fields": [233],"comptime": false},{"file": 0,"line": 0,"col": 0,"name": "addr","docs": "","comptime": true},{"file": 0,"line": 0,"col": 0,"name": "reg","comptime": false},{"file": 5,"line": 22,"col": 0,"fields": [236,237],"comptime": false},{"file": 0,"line": 0,"col": 0,"name": "GPIO4B","comptime": false},{"file": 0,"line": 0,"col": 0,"name": "GPIO4C","comptime": false},{"file": 5,"line": 28,"col": 0,"docs": " GPIO4B IOMUX Control Register","fields": [239,240,241,242,243,244,245,246],"comptime": false},{"file": 0,"line": 0,"col": 0,"name": "sel_0","comptime": false},{"file": 0,"line": 0,"col": 0,"name": "sel_1","comptime": false},{"file": 0,"line": 0,"col": 0,"name": "sel_2","comptime": false},{"file": 0,"line": 0,"col": 0,"name": "sel_3","comptime": false},{"file": 0,"line": 0,"col": 0,"name": "sel_4","comptime": false},{"file": 0,"line": 0,"col": 0,"name": "sel_5","comptime": false},{"file": 0,"line": 0,"col": 0,"name": "_reserbed12_15","comptime": false},{"file": 0,"line": 0,"col": 0,"name": "write_enable","comptime": false},{"file": 5,"line": 40,"col": 0,"docs": " GPIO4C IOMUX Control Register","fields": [248,249,250,251,252,253,254,255,256],"comptime": false},{"file": 0,"line": 0,"col": 0,"name": "sel_0","comptime": false},{"file": 0,"line": 0,"col": 0,"name": "sel_1","comptime": false},{"file": 0,"line": 0,"col": 0,"name": "sel_2","comptime": false},{"file": 0,"line": 0,"col": 0,"name": "sel_3","comptime": false},{"file": 0,"line": 0,"col": 0,"name": "sel_4","comptime": false},{"file": 0,"line": 0,"col": 0,"name": "sel_5","comptime": false},{"file": 0,"line": 0,"col": 0,"name": "sel_6","comptime": false},{"file": 0,"line": 0,"col": 0,"name": "sel_7","comptime": false},{"file": 0,"line": 0,"col": 0,"name": "write_enable","comptime": false},{"file": 3,"line": 2,"col": 0,"comptime": false},{"file": 3,"line": 20,"col": 0,"docs": " RK3399 UART's\n The RK3399 has 5 independent UART's. All 5 contain two 64 Byte FIFOs for\n data receive and transmit. UART0 and UART3 support auto flow-control.\n Bitrates:\n     - 115.2Kbps\n     - 460.8Kbps\n     - 921.6Kbps\n     - 1.5Mbps\n     - 3Mbps\n     - 4Mbps\n All support programmable baud rates, even with non-integer clock divider\n Start, Stop, Parity bits.\n Interrupt-based or DMA mode\n support 5-8 bit width transfer\n See section UART, page 439 of the RK3399 Technical Reference Manual for\n more info.","comptime": false},{"file": 3,"line": 22,"col": 0,"comptime": false},{"file": 3,"line": 23,"col": 0,"comptime": false},{"file": 3,"line": 24,"col": 0,"comptime": false},{"file": 3,"line": 25,"col": 0,"comptime": false},{"file": 3,"line": 26,"col": 0,"comptime": false},{"file": 3,"line": 27,"col": 0,"comptime": false},{"file": 3,"line": 28,"col": 0,"comptime": false},{"file": 3,"line": 29,"col": 0,"comptime": false},{"file": 3,"line": 30,"col": 0,"comptime": false},{"file": 3,"line": 31,"col": 0,"comptime": false},{"file": 3,"line": 32,"col": 0,"comptime": false},{"file": 3,"line": 33,"col": 0,"comptime": false},{"file": 3,"line": 41,"col": 0,"docs": " Sets the GPIO pins 8 and 10 up for use by the UART2\n See page 204 in TRM. Note that GRF is General Register Files.\n On page 55 of the data sheet, we see:\n GPIO_B0 is our uart Rx when func 3 is selected\n GPIO_B1 is our uart Tx when func 3 is selected.\n This particular GRF is described on page 309 of the TRM.","fields": [],"comptime": false},{"file": 3,"line": 61,"col": 0,"fields": [273],"comptime": false},{"file": 0,"line": 0,"col": 0,"name": "baud","docs": "","comptime": false},{"file": 3,"line": 83,"col": 0,"docs": " Initialization function for the uart","fields": [],"comptime": false},{"file": 3,"line": 115,"col": 0,"fields": [276],"comptime": false},{"file": 0,"line": 0,"col": 0,"name": "char","docs": "","comptime": false},{"file": 3,"line": 126,"col": 0,"fields": [278],"comptime": false},{"file": 0,"line": 0,"col": 0,"name": "str","docs": "","comptime": false},{"file": 0,"line": 3,"col": 0,"comptime": false},{"file": 0,"line": 4,"col": 0,"comptime": false},{"file": 0,"line": 6,"col": 0,"fields": [],"comptime": false},{"file": 0,"line": 15,"col": 0,"fields": [],"comptime": false},{"file": 0,"line": 24,"col": 0,"docs": " Zig entry point for the first bit of user code loaded by the BROM into the\n 192K SRAM. The main goal is to initialize DDR Memory, then we can load\n programs to RAM and run there.","fields": [],"comptime": false}],
 "calls": [{"func": {
 "refPath": [{
 "declRef": 7
},{
 "declRef": 10
}]
},"args": [{
 "type": 7
},{
 "type": 7
}],"ret": {
 "comptimeExpr": 4
}},{"func": {
 "refPath": [{
 "declRef": 7
},{
 "declRef": 10
}]
},"args": [{
 "type": 7
},{
 "type": 7
}],"ret": {
 "comptimeExpr": 5
}},{"func": {
 "refPath": [{
 "declRef": 109
},{
 "declRef": 10
}]
},"args": [{
 "type": 7
},{
 "type": 7
}],"ret": {
 "comptimeExpr": 6
}}],
 "files": [
  "main.zig",
  "gpio.zig",
  "mmio.zig",
  "uart.zig",
  "uart-regs.zig",
  "iomux-regs.zig"
 ],
 "types": [{
 "kind": 10,
 "name": "ComptimeExpr"
},{
 "kind": 5,
 "name": "u1"
},{
 "kind": 5,
 "name": "u8"
},{
 "kind": 5,
 "name": "i8"
},{
 "kind": 5,
 "name": "u16"
},{
 "kind": 5,
 "name": "i16"
},{
 "kind": 8,
 "len": {
 "int": 1
},
 "child": {
 "type": 0
},
 "sentinel": null
},{
 "kind": 5,
 "name": "u32"
},{
 "kind": 5,
 "name": "i32"
},{
 "kind": 5,
 "name": "u64"
},{
 "kind": 5,
 "name": "i64"
},{
 "kind": 5,
 "name": "u128"
},{
 "kind": 5,
 "name": "i128"
},{
 "kind": 5,
 "name": "usize"
},{
 "kind": 5,
 "name": "isize"
},{
 "kind": 5,
 "name": "c_short"
},{
 "kind": 5,
 "name": "c_ushort"
},{
 "kind": 5,
 "name": "c_int"
},{
 "kind": 5,
 "name": "c_uint"
},{
 "kind": 5,
 "name": "c_long"
},{
 "kind": 5,
 "name": "c_ulong"
},{
 "kind": 5,
 "name": "c_longlong"
},{
 "kind": 5,
 "name": "c_ulonglong"
},{
 "kind": 5,
 "name": "c_longdouble"
},{
 "kind": 6,
 "name": "f16"
},{
 "kind": 6,
 "name": "f32"
},{
 "kind": 6,
 "name": "f64"
},{
 "kind": 8,
 "len": {
 "int": 1
},
 "child": {
 "type": 0
},
 "sentinel": null
},{
 "kind": 6,
 "name": "f128"
},{
 "kind": 10,
 "name": "anyopaque"
},{
 "kind": 3,
 "name": "bool"
},{
 "kind": 2,
 "name": "void"
},{
 "kind": 1,
 "name": "type"
},{
 "kind": 18,
 "name": "anyerror",
 "fields": null
},{
 "kind": 12,
 "name": "comptime_int"
},{
 "kind": 11,
 "name": "comptime_float"
},{
 "kind": 4,
 "name": "noreturn"
},{
 "kind": 8,
 "len": {
 "int": 1
},
 "child": {
 "type": 0
},
 "sentinel": null
},{
 "kind": 8,
 "len": {
 "int": 1
},
 "child": {
 "type": 0
},
 "sentinel": null
},{
 "kind": 8,
 "len": {
 "int": 1
},
 "child": {
 "type": 0
},
 "sentinel": null
},{
 "kind": 8,
 "len": {
 "int": 1
},
 "child": {
 "type": 0
},
 "sentinel": null
},{
 "kind": 8,
 "len": {
 "int": 1
},
 "child": {
 "type": 0
},
 "sentinel": null
},{
 "kind": 8,
 "len": {
 "int": 1
},
 "child": {
 "type": 0
},
 "sentinel": null
},{
 "kind": 27,
 "name": "std.builtin.CallingConvention"
},{
 "kind": 8,
 "len": {
 "int": 1
},
 "child": {
 "type": 0
},
 "sentinel": null
},{
 "kind": 8,
 "len": {
 "int": 1
},
 "child": {
 "type": 0
},
 "sentinel": null
},{
 "kind": 8,
 "len": {
 "int": 1
},
 "child": {
 "type": 0
},
 "sentinel": null
},{
 "kind": 8,
 "len": {
 "int": 1
},
 "child": {
 "type": 0
},
 "sentinel": null
},{
 "kind": 8,
 "len": {
 "int": 1
},
 "child": {
 "type": 0
},
 "sentinel": null
},{
 "kind": 8,
 "len": {
 "int": 1
},
 "child": {
 "type": 0
},
 "sentinel": null
},{
 "kind": 8,
 "len": {
 "int": 1
},
 "child": {
 "type": 0
},
 "sentinel": null
},{
 "kind": 8,
 "len": {
 "int": 1
},
 "child": {
 "type": 0
},
 "sentinel": null
},{
 "kind": 8,
 "len": {
 "int": 1
},
 "child": {
 "type": 0
},
 "sentinel": null
},{
 "kind": 8,
 "len": {
 "int": 1
},
 "child": {
 "type": 0
},
 "sentinel": null
},{
 "kind": 8,
 "len": {
 "int": 1
},
 "child": {
 "type": 0
},
 "sentinel": null
},{
 "kind": 8,
 "len": {
 "int": 1
},
 "child": {
 "type": 0
},
 "sentinel": null
},{
 "kind": 8,
 "len": {
 "int": 1
},
 "child": {
 "type": 0
},
 "sentinel": null
},{
 "kind": 8,
 "len": {
 "int": 1
},
 "child": {
 "type": 0
},
 "sentinel": null
},{
 "kind": 8,
 "len": {
 "int": 1
},
 "child": {
 "type": 0
},
 "sentinel": null
},{
 "kind": 8,
 "len": {
 "int": 1
},
 "child": {
 "type": 0
},
 "sentinel": null
},{
 "kind": 8,
 "len": {
 "int": 1
},
 "child": {
 "type": 0
},
 "sentinel": null
},{
 "kind": 9,
 "name": "todo_name",
 "src": 0,
 "privDecls": [0,1,2,3,4,5,6],
 "pubDecls": [],
 "fields": [],
 "line_number": 0,
 "outer_decl": 60,
 "ast": 0
},{
 "kind": 9,
 "name": "todo_name",
 "src": 1,
 "privDecls": [7],
 "pubDecls": [8,9],
 "fields": [],
 "line_number": 0,
 "outer_decl": 61,
 "ast": 1
},{
 "kind": 9,
 "name": "todo_name",
 "src": 2,
 "privDecls": [],
 "pubDecls": [10],
 "fields": [],
 "line_number": 0,
 "outer_decl": 62,
 "ast": 2
},{
 "kind": 21,
 "name": "todo_name func",
 "src": 3,
 "ret": {
 "type": 32
},
 "generic_ret": {
 "as": {"typeRefArg": 1,"exprArg": 0}
},
 "params": [{
 "type": 32
},{
 "type": 32
}],
 "lib_name": "",
 "is_var_args": false,
 "is_inferred_error": false,
 "has_lib_name": false,
 "has_cc": false,
 "cc": null,
 "align": null,
 "has_align": false,
 "is_test": false,
 "is_extern": false
},{
 "kind": 9,
 "name": "todo_name",
 "src": 5,
 "privDecls": [11],
 "pubDecls": [12,13,14,15,16,17],
 "fields": [{
 "type": 72
}],
 "line_number": 0,
 "outer_decl": 64,
 "ast": 5
},{
 "kind": 21,
 "name": "todo_name func",
 "src": 7,
 "ret": {
 "declRef": 11
},
 "generic_ret": null,
 "params": [{
 "type": 7
}],
 "lib_name": "",
 "is_var_args": false,
 "is_inferred_error": false,
 "has_lib_name": false,
 "has_cc": false,
 "cc": null,
 "align": null,
 "has_align": false,
 "is_test": false,
 "is_extern": false
},{
 "kind": 21,
 "name": "todo_name func",
 "src": 9,
 "ret": {
 "type": 7
},
 "generic_ret": null,
 "params": [{
 "declRef": 11
}],
 "lib_name": "",
 "is_var_args": false,
 "is_inferred_error": false,
 "has_lib_name": false,
 "has_cc": false,
 "cc": null,
 "align": null,
 "has_align": false,
 "is_test": false,
 "is_extern": false
},{
 "kind": 21,
 "name": "todo_name func",
 "src": 11,
 "ret": {
 "type": 31
},
 "generic_ret": null,
 "params": [{
 "declRef": 11
},{
 "type": 7
}],
 "lib_name": "",
 "is_var_args": false,
 "is_inferred_error": false,
 "has_lib_name": false,
 "has_cc": false,
 "cc": null,
 "align": null,
 "has_align": false,
 "is_test": false,
 "is_extern": false
},{
 "kind": 21,
 "name": "todo_name func",
 "src": 14,
 "ret": {
 "comptimeExpr": 1
},
 "generic_ret": null,
 "params": [{
 "declRef": 11
}],
 "lib_name": "",
 "is_var_args": false,
 "is_inferred_error": false,
 "has_lib_name": false,
 "has_cc": false,
 "cc": null,
 "align": null,
 "has_align": false,
 "is_test": false,
 "is_extern": false
},{
 "kind": 21,
 "name": "todo_name func",
 "src": 16,
 "ret": {
 "type": 31
},
 "generic_ret": null,
 "params": [{
 "declRef": 11
},{
 "comptimeExpr": 2
}],
 "lib_name": "",
 "is_var_args": false,
 "is_inferred_error": false,
 "has_lib_name": false,
 "has_cc": false,
 "cc": null,
 "align": null,
 "has_align": false,
 "is_test": false,
 "is_extern": false
},{
 "kind": 21,
 "name": "todo_name func",
 "src": 19,
 "ret": {
 "type": 31
},
 "generic_ret": null,
 "params": [{
 "declRef": 11
},{
 "comptimeExpr": 3
}],
 "lib_name": "",
 "is_var_args": false,
 "is_inferred_error": false,
 "has_lib_name": false,
 "has_cc": false,
 "cc": null,
 "align": null,
 "has_align": false,
 "is_test": false,
 "is_extern": false
},{
 "kind": 7,
 "size": 0,
 "child": {
 "type": 7
},
 "sentinel": null,
 "align": null,
 "address_space": null,
 "bit_start": null,
 "host_size": null,
 "is_ref": false,
 "is_allowzero": false,
 "is_mutable": true,
 "is_volatile": true,
 "has_sentinel": false,
 "has_align": false,
 "has_addrspace": false,
 "has_bit_range": false
},{
 "kind": 9,
 "name": "todo_name",
 "src": 23,
 "privDecls": [],
 "pubDecls": [18],
 "fields": [{
 "call": 0
},{
 "call": 1
}],
 "line_number": 3,
 "outer_decl": 72,
 "ast": 23
},{
 "kind": 21,
 "name": "todo_name func",
 "src": 24,
 "ret": {
 "declRef": 8
},
 "generic_ret": null,
 "params": [{
 "declRef": 9
}],
 "lib_name": "",
 "is_var_args": false,
 "is_inferred_error": false,
 "has_lib_name": false,
 "has_cc": false,
 "cc": null,
 "align": null,
 "has_align": false,
 "is_test": false,
 "is_extern": false
},{
 "kind": 19,
 "name": "todo_name",
 "src": 28,
 "privDecls": [],
 "pubDecls": [],
 "ast": 28
},{
 "kind": 9,
 "name": "todo_name",
 "src": 34,
 "privDecls": [19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,38],
 "pubDecls": [37,39],
 "fields": [],
 "line_number": 1,
 "outer_decl": 75,
 "ast": 34
},{
 "kind": 9,
 "name": "todo_name",
 "src": 35,
 "privDecls": [],
 "pubDecls": [40,41,42,43,44,45,46,47,48,49,50,51,52,53,54,55,56,57,58,59,60,61,62,63,64,65,66,67,68,69,70,71,72,73,74,75,76,77,78,79,80,81,82,83,84,85,86,87,88,89,90,91,92,93,94,95,96,97,98,99,100,101,102,103,104,105,106,107,108],
 "fields": [],
 "line_number": 0,
 "outer_decl": 76,
 "ast": 35
},{
 "kind": 9,
 "name": "todo_name",
 "src": 73,
 "privDecls": [],
 "pubDecls": [],
 "fields": [{
 "type": 2
},{
 "type": 79
}],
 "line_number": 54,
 "outer_decl": 77,
 "ast": 73
},{
 "kind": 5,
 "name": "u24"
},{
 "kind": 9,
 "name": "todo_name",
 "src": 76,
 "privDecls": [],
 "pubDecls": [],
 "fields": [{
 "type": 2
},{
 "type": 81
}],
 "line_number": 79,
 "outer_decl": 79,
 "ast": 76
},{
 "kind": 5,
 "name": "u24"
},{
 "kind": 9,
 "name": "todo_name",
 "src": 79,
 "privDecls": [],
 "pubDecls": [],
 "fields": [{
 "type": 2
},{
 "type": 83
}],
 "line_number": 106,
 "outer_decl": 81,
 "ast": 79
},{
 "kind": 5,
 "name": "u24"
},{
 "kind": 9,
 "name": "todo_name",
 "src": 82,
 "privDecls": [],
 "pubDecls": [],
 "fields": [{
 "type": 2
},{
 "type": 85
}],
 "line_number": 127,
 "outer_decl": 83,
 "ast": 82
},{
 "kind": 5,
 "name": "u24"
},{
 "kind": 9,
 "name": "todo_name",
 "src": 85,
 "privDecls": [],
 "pubDecls": [],
 "fields": [{
 "type": 30
},{
 "type": 30
},{
 "type": 30
},{
 "type": 30
},{
 "type": 87
},{
 "type": 30
},{
 "type": 88
}],
 "line_number": 139,
 "outer_decl": 85,
 "ast": 85
},{
 "kind": 5,
 "name": "u3"
},{
 "kind": 5,
 "name": "u24"
},{
 "kind": 9,
 "name": "todo_name",
 "src": 93,
 "privDecls": [],
 "pubDecls": [],
 "fields": [{
 "type": 90
},{
 "type": 91
},{
 "type": 92
},{
 "type": 93
}],
 "line_number": 179,
 "outer_decl": 88,
 "ast": 93
},{
 "kind": 5,
 "name": "u4"
},{
 "kind": 5,
 "name": "u2"
},{
 "kind": 5,
 "name": "u2"
},{
 "kind": 5,
 "name": "u24"
},{
 "kind": 9,
 "name": "todo_name",
 "src": 98,
 "privDecls": [],
 "pubDecls": [],
 "fields": [{
 "type": 30
},{
 "type": 30
},{
 "type": 30
},{
 "type": 30
},{
 "type": 95
},{
 "type": 96
},{
 "type": 97
}],
 "line_number": 211,
 "outer_decl": 93,
 "ast": 98
},{
 "kind": 5,
 "name": "u2"
},{
 "kind": 5,
 "name": "u2"
},{
 "kind": 5,
 "name": "u24"
},{
 "kind": 9,
 "name": "todo_name",
 "src": 106,
 "privDecls": [],
 "pubDecls": [],
 "fields": [{
 "type": 99
},{
 "type": 30
},{
 "type": 30
},{
 "type": 30
},{
 "type": 30
},{
 "type": 30
},{
 "type": 30
},{
 "type": 100
}],
 "line_number": 279,
 "outer_decl": 97,
 "ast": 106
},{
 "kind": 5,
 "name": "u2"
},{
 "kind": 5,
 "name": "u24"
},{
 "kind": 9,
 "name": "todo_name",
 "src": 115,
 "privDecls": [],
 "pubDecls": [],
 "fields": [{
 "type": 30
},{
 "type": 30
},{
 "type": 30
},{
 "type": 30
},{
 "type": 30
},{
 "type": 30
},{
 "type": 30
},{
 "type": 102
}],
 "line_number": 356,
 "outer_decl": 100,
 "ast": 115
},{
 "kind": 5,
 "name": "u25"
},{
 "kind": 9,
 "name": "todo_name",
 "src": 124,
 "privDecls": [],
 "pubDecls": [],
 "fields": [{
 "type": 30
},{
 "type": 30
},{
 "type": 30
},{
 "type": 30
},{
 "type": 30
},{
 "type": 30
},{
 "type": 30
},{
 "type": 104
}],
 "line_number": 415,
 "outer_decl": 102,
 "ast": 124
},{
 "kind": 5,
 "name": "u24"
},{
 "kind": 9,
 "name": "todo_name",
 "src": 133,
 "privDecls": [],
 "pubDecls": [],
 "fields": [{
 "type": 30
},{
 "type": 30
},{
 "type": 30
},{
 "type": 30
},{
 "type": 30
},{
 "type": 30
},{
 "type": 30
},{
 "type": 106
}],
 "line_number": 490,
 "outer_decl": 104,
 "ast": 133
},{
 "kind": 5,
 "name": "u24"
},{
 "kind": 9,
 "name": "todo_name",
 "src": 142,
 "privDecls": [],
 "pubDecls": [],
 "fields": [{
 "type": 2
},{
 "type": 108
}],
 "line_number": 530,
 "outer_decl": 106,
 "ast": 142
},{
 "kind": 5,
 "name": "u24"
},{
 "kind": 9,
 "name": "todo_name",
 "src": 145,
 "privDecls": [],
 "pubDecls": [],
 "fields": [{
 "type": 2
},{
 "type": 110
}],
 "line_number": 541,
 "outer_decl": 108,
 "ast": 145
},{
 "kind": 5,
 "name": "u24"
},{
 "kind": 9,
 "name": "todo_name",
 "src": 148,
 "privDecls": [],
 "pubDecls": [],
 "fields": [{
 "type": 2
},{
 "type": 112
}],
 "line_number": 566,
 "outer_decl": 110,
 "ast": 148
},{
 "kind": 5,
 "name": "u24"
},{
 "kind": 9,
 "name": "todo_name",
 "src": 151,
 "privDecls": [],
 "pubDecls": [],
 "fields": [{
 "type": 30
},{
 "type": 114
}],
 "line_number": 574,
 "outer_decl": 112,
 "ast": 151
},{
 "kind": 5,
 "name": "u31"
},{
 "kind": 9,
 "name": "todo_name",
 "src": 154,
 "privDecls": [],
 "pubDecls": [],
 "fields": [{
 "type": 2
},{
 "type": 116
}],
 "line_number": 593,
 "outer_decl": 114,
 "ast": 154
},{
 "kind": 5,
 "name": "u24"
},{
 "kind": 9,
 "name": "todo_name",
 "src": 157,
 "privDecls": [],
 "pubDecls": [],
 "fields": [{
 "type": 2
},{
 "type": 30
},{
 "type": 30
},{
 "type": 118
}],
 "line_number": 609,
 "outer_decl": 116,
 "ast": 157
},{
 "kind": 5,
 "name": "u22"
},{
 "kind": 9,
 "name": "todo_name",
 "src": 162,
 "privDecls": [],
 "pubDecls": [],
 "fields": [{
 "type": 30
},{
 "type": 30
},{
 "type": 30
},{
 "type": 30
},{
 "type": 30
},{
 "type": 120
}],
 "line_number": 639,
 "outer_decl": 118,
 "ast": 162
},{
 "kind": 5,
 "name": "u27"
},{
 "kind": 9,
 "name": "todo_name",
 "src": 169,
 "privDecls": [],
 "pubDecls": [],
 "fields": [{
 "type": 122
},{
 "type": 123
}],
 "line_number": 683,
 "outer_decl": 120,
 "ast": 169
},{
 "kind": 5,
 "name": "u5"
},{
 "kind": 5,
 "name": "u27"
},{
 "kind": 9,
 "name": "todo_name",
 "src": 172,
 "privDecls": [],
 "pubDecls": [],
 "fields": [{
 "type": 125
},{
 "type": 126
}],
 "line_number": 695,
 "outer_decl": 123,
 "ast": 172
},{
 "kind": 5,
 "name": "u5"
},{
 "kind": 5,
 "name": "u27"
},{
 "kind": 9,
 "name": "todo_name",
 "src": 175,
 "privDecls": [],
 "pubDecls": [],
 "fields": [{
 "type": 30
},{
 "type": 30
},{
 "type": 30
},{
 "type": 6
}],
 "line_number": 707,
 "outer_decl": 126,
 "ast": 175
},{
 "kind": 9,
 "name": "todo_name",
 "src": 180,
 "privDecls": [],
 "pubDecls": [],
 "fields": [{
 "type": 30
},{
 "type": 129
}],
 "line_number": 729,
 "outer_decl": 127,
 "ast": 180
},{
 "kind": 5,
 "name": "u31"
},{
 "kind": 9,
 "name": "todo_name",
 "src": 183,
 "privDecls": [],
 "pubDecls": [],
 "fields": [{
 "type": 30
},{
 "type": 131
}],
 "line_number": 743,
 "outer_decl": 129,
 "ast": 183
},{
 "kind": 5,
 "name": "u31"
},{
 "kind": 9,
 "name": "todo_name",
 "src": 186,
 "privDecls": [],
 "pubDecls": [],
 "fields": [{
 "type": 30
},{
 "type": 133
}],
 "line_number": 757,
 "outer_decl": 131,
 "ast": 186
},{
 "kind": 5,
 "name": "u31"
},{
 "kind": 9,
 "name": "todo_name",
 "src": 189,
 "privDecls": [],
 "pubDecls": [],
 "fields": [{
 "type": 30
},{
 "type": 135
}],
 "line_number": 769,
 "outer_decl": 133,
 "ast": 189
},{
 "kind": 5,
 "name": "u31"
},{
 "kind": 9,
 "name": "todo_name",
 "src": 192,
 "privDecls": [],
 "pubDecls": [],
 "fields": [{
 "type": 30
},{
 "type": 137
}],
 "line_number": 782,
 "outer_decl": 135,
 "ast": 192
},{
 "kind": 5,
 "name": "u31"
},{
 "kind": 9,
 "name": "todo_name",
 "src": 195,
 "privDecls": [],
 "pubDecls": [],
 "fields": [{
 "type": 30
},{
 "type": 139
}],
 "line_number": 794,
 "outer_decl": 137,
 "ast": 195
},{
 "kind": 5,
 "name": "u31"
},{
 "kind": 9,
 "name": "todo_name",
 "src": 198,
 "privDecls": [],
 "pubDecls": [],
 "fields": [{
 "type": 30
},{
 "type": 141
}],
 "line_number": 806,
 "outer_decl": 139,
 "ast": 198
},{
 "kind": 5,
 "name": "u31"
},{
 "kind": 9,
 "name": "todo_name",
 "src": 201,
 "privDecls": [],
 "pubDecls": [],
 "fields": [{
 "type": 30
},{
 "type": 143
}],
 "line_number": 820,
 "outer_decl": 141,
 "ast": 201
},{
 "kind": 5,
 "name": "u31"
},{
 "kind": 9,
 "name": "todo_name",
 "src": 204,
 "privDecls": [],
 "pubDecls": [],
 "fields": [{
 "type": 145
},{
 "type": 146
},{
 "type": 30
},{
 "type": 30
},{
 "type": 30
},{
 "type": 30
},{
 "type": 30
},{
 "type": 30
},{
 "type": 30
},{
 "type": 30
},{
 "type": 30
},{
 "type": 30
},{
 "type": 147
},{
 "type": 2
},{
 "type": 148
}],
 "line_number": 832,
 "outer_decl": 143,
 "ast": 204
},{
 "kind": 5,
 "name": "u2"
},{
 "kind": 5,
 "name": "u2"
},{
 "kind": 5,
 "name": "u2"
},{
 "kind": 5,
 "name": "u9"
},{
 "kind": 9,
 "name": "todo_name",
 "src": 220,
 "privDecls": [],
 "pubDecls": [],
 "fields": [{
 "type": 7
}],
 "line_number": 869,
 "outer_decl": 148,
 "ast": 220
},{
 "kind": 9,
 "name": "todo_name",
 "src": 222,
 "privDecls": [],
 "pubDecls": [],
 "fields": [{
 "type": 7
}],
 "line_number": 879,
 "outer_decl": 149,
 "ast": 222
},{
 "kind": 9,
 "name": "todo_name",
 "src": 224,
 "privDecls": [109,110,111,112,113,114,117],
 "pubDecls": [115,116,118],
 "fields": [],
 "line_number": 1,
 "outer_decl": 150,
 "ast": 224
},{
 "kind": 9,
 "name": "todo_name",
 "src": 231,
 "privDecls": [],
 "pubDecls": [119],
 "fields": [{
 "call": 2
}],
 "line_number": 14,
 "outer_decl": 151,
 "ast": 231
},{
 "kind": 21,
 "name": "todo_name func",
 "src": 232,
 "ret": {
 "declRef": 115
},
 "generic_ret": null,
 "params": [{
 "declRef": 116
}],
 "lib_name": "",
 "is_var_args": false,
 "is_inferred_error": false,
 "has_lib_name": false,
 "has_cc": false,
 "cc": null,
 "align": null,
 "has_align": false,
 "is_test": false,
 "is_extern": false
},{
 "kind": 19,
 "name": "todo_name",
 "src": 235,
 "privDecls": [],
 "pubDecls": [],
 "ast": 235
},{
 "kind": 9,
 "name": "todo_name",
 "src": 238,
 "privDecls": [],
 "pubDecls": [],
 "fields": [{
 "type": 156
},{
 "type": 157
},{
 "type": 158
},{
 "type": 159
},{
 "type": 160
},{
 "type": 161
},{
 "type": 162
},{
 "type": 4
}],
 "line_number": 28,
 "outer_decl": 154,
 "ast": 238
},{
 "kind": 5,
 "name": "u2"
},{
 "kind": 5,
 "name": "u2"
},{
 "kind": 5,
 "name": "u2"
},{
 "kind": 5,
 "name": "u2"
},{
 "kind": 5,
 "name": "u2"
},{
 "kind": 5,
 "name": "u2"
},{
 "kind": 5,
 "name": "u4"
},{
 "kind": 9,
 "name": "todo_name",
 "src": 247,
 "privDecls": [],
 "pubDecls": [],
 "fields": [{
 "type": 164
},{
 "type": 165
},{
 "type": 166
},{
 "type": 167
},{
 "type": 168
},{
 "type": 169
},{
 "type": 170
},{
 "type": 171
},{
 "type": 4
}],
 "line_number": 40,
 "outer_decl": 162,
 "ast": 247
},{
 "kind": 5,
 "name": "u2"
},{
 "kind": 5,
 "name": "u2"
},{
 "kind": 5,
 "name": "u2"
},{
 "kind": 5,
 "name": "u2"
},{
 "kind": 5,
 "name": "u2"
},{
 "kind": 5,
 "name": "u2"
},{
 "kind": 5,
 "name": "u2"
},{
 "kind": 5,
 "name": "u2"
},{
 "kind": 21,
 "name": "todo_name func",
 "src": 271,
 "ret": {
 "type": 31
},
 "generic_ret": null,
 "params": [],
 "lib_name": "",
 "is_var_args": false,
 "is_inferred_error": false,
 "has_lib_name": false,
 "has_cc": false,
 "cc": null,
 "align": null,
 "has_align": false,
 "is_test": false,
 "is_extern": false
},{
 "kind": 21,
 "name": "todo_name func",
 "src": 272,
 "ret": {
 "type": 31
},
 "generic_ret": null,
 "params": [{
 "type": 7
}],
 "lib_name": "",
 "is_var_args": false,
 "is_inferred_error": false,
 "has_lib_name": false,
 "has_cc": false,
 "cc": null,
 "align": null,
 "has_align": false,
 "is_test": false,
 "is_extern": false
},{
 "kind": 21,
 "name": "todo_name func",
 "src": 274,
 "ret": {
 "type": 31
},
 "generic_ret": null,
 "params": [],
 "lib_name": "",
 "is_var_args": false,
 "is_inferred_error": false,
 "has_lib_name": false,
 "has_cc": false,
 "cc": null,
 "align": null,
 "has_align": false,
 "is_test": false,
 "is_extern": false
},{
 "kind": 21,
 "name": "todo_name func",
 "src": 275,
 "ret": {
 "type": 31
},
 "generic_ret": null,
 "params": [{
 "type": 2
}],
 "lib_name": "",
 "is_var_args": false,
 "is_inferred_error": false,
 "has_lib_name": false,
 "has_cc": false,
 "cc": null,
 "align": null,
 "has_align": false,
 "is_test": false,
 "is_extern": false
},{
 "kind": 21,
 "name": "todo_name func",
 "src": 277,
 "ret": {
 "type": 31
},
 "generic_ret": null,
 "params": [{
 "type": 177
}],
 "lib_name": "",
 "is_var_args": false,
 "is_inferred_error": false,
 "has_lib_name": false,
 "has_cc": false,
 "cc": null,
 "align": null,
 "has_align": false,
 "is_test": false,
 "is_extern": false
},{
 "kind": 7,
 "size": 2,
 "child": {
 "type": 2
},
 "sentinel": null,
 "align": null,
 "address_space": null,
 "bit_start": null,
 "host_size": null,
 "is_ref": false,
 "is_allowzero": false,
 "is_mutable": false,
 "is_volatile": false,
 "has_sentinel": false,
 "has_align": false,
 "has_addrspace": false,
 "has_bit_range": false
},{
 "kind": 21,
 "name": "todo_name func",
 "src": 281,
 "ret": {
 "type": 31
},
 "generic_ret": null,
 "params": [],
 "lib_name": "",
 "is_var_args": false,
 "is_inferred_error": false,
 "has_lib_name": false,
 "has_cc": false,
 "cc": null,
 "align": null,
 "has_align": false,
 "is_test": false,
 "is_extern": false
},{
 "kind": 21,
 "name": "todo_name func",
 "src": 282,
 "ret": {
 "type": 31
},
 "generic_ret": null,
 "params": [],
 "lib_name": "",
 "is_var_args": false,
 "is_inferred_error": false,
 "has_lib_name": false,
 "has_cc": false,
 "cc": null,
 "align": null,
 "has_align": false,
 "is_test": false,
 "is_extern": false
},{
 "kind": 21,
 "name": "todo_name func",
 "src": 283,
 "ret": {
 "type": 36
},
 "generic_ret": null,
 "params": [],
 "lib_name": "",
 "is_var_args": false,
 "is_inferred_error": false,
 "has_lib_name": false,
 "has_cc": false,
 "cc": null,
 "align": null,
 "has_align": false,
 "is_test": false,
 "is_extern": false
}],
 "decls": [{"name": "gpio","kind": "const","isTest": false,"src": 1,"value": {"typeRef": {
 "type": 32
},"expr": {
 "type": 62
}},"_analyzed": true},{"name": "uart","kind": "const","isTest": false,"src": 34,"value": {"typeRef": {
 "type": 32
},"expr": {
 "type": 76
}},"_analyzed": true},{"name": "__bss_start","kind": "const","isTest": false,"src": 279,"value": {"expr": {
 "void": {}
}},"_analyzed": true},{"name": "__bss_end","kind": "const","isTest": false,"src": 280,"value": {"expr": {
 "void": {}
}},"_analyzed": true},{"name": "delay","kind": "const","isTest": false,"src": 281,"value": {"typeRef": {
 "type": 32
},"expr": {
 "type": 178
}},"_analyzed": true},{"name": "talker","kind": "const","isTest": false,"src": 282,"value": {"typeRef": {
 "type": 32
},"expr": {
 "type": 179
}},"_analyzed": true},{"name": "zigMain","kind": "const","isTest": false,"src": 283,"value": {"typeRef": {
 "type": 32
},"expr": {
 "type": 180
}},"_analyzed": true},{"name": "mmio","kind": "const","isTest": false,"src": 2,"value": {"typeRef": {
 "type": 32
},"expr": {
 "type": 63
}},"_analyzed": true},{"name": "Gpio","kind": "const","isTest": false,"src": 23,"value": {"typeRef": {
 "type": 32
},"expr": {
 "type": 73
}},"_analyzed": true},{"name": "GpioBase","kind": "const","isTest": false,"src": 28,"value": {"typeRef": {
 "type": 32
},"expr": {
 "type": 75
}},"_analyzed": true},{"name": "Register","kind": "const","isTest": false,"src": 3,"value": {"typeRef": {
 "type": 32
},"expr": {
 "type": 64
}},"_analyzed": true},{"name": "Self","kind": "const","isTest": false,"src": 6,"value": {"typeRef": {
 "type": 32
},"expr": {
 "this": 65
}},"_analyzed": true},{"name": "init","kind": "const","isTest": false,"src": 7,"value": {"typeRef": {
 "type": 32
},"expr": {
 "type": 66
}},"_analyzed": true},{"name": "read_raw","kind": "const","isTest": false,"src": 9,"value": {"typeRef": {
 "type": 32
},"expr": {
 "type": 67
}},"_analyzed": true},{"name": "write_raw","kind": "const","isTest": false,"src": 11,"value": {"typeRef": {
 "type": 32
},"expr": {
 "type": 68
}},"_analyzed": true},{"name": "read","kind": "const","isTest": false,"src": 14,"value": {"typeRef": {
 "type": 32
},"expr": {
 "type": 69
}},"_analyzed": true},{"name": "write","kind": "const","isTest": false,"src": 16,"value": {"typeRef": {
 "type": 32
},"expr": {
 "type": 70
}},"_analyzed": true},{"name": "modify","kind": "const","isTest": false,"src": 19,"value": {"typeRef": {
 "type": 32
},"expr": {
 "type": 71
}},"_analyzed": true},{"name": "init","kind": "const","isTest": false,"src": 24,"value": {"typeRef": {
 "type": 32
},"expr": {
 "type": 74
}},"_analyzed": true},{"name": "uart_regs","kind": "const","isTest": false,"src": 35,"value": {"typeRef": {
 "type": 32
},"expr": {
 "type": 77
}},"_analyzed": true},{"name": "iomux","kind": "const","isTest": false,"src": 224,"value": {"typeRef": {
 "type": 32
},"expr": {
 "type": 151
}},"_analyzed": true},{"name": "mmio","kind": "const","isTest": false,"src": 257,"value": {"typeRef": {
 "type": 32
},"expr": {
 "type": 63
}},"_analyzed": true},{"name": "uart_clock","kind": "const","isTest": false,"src": 258,"value": {"typeRef": {
 "type": 34
},"expr": {
 "int": 24000000
}},"_analyzed": true},{"name": "uart_base","kind": "const","isTest": false,"src": 259,"value": {"expr": {
 "refPath": [{
 "declRef": 19
},{
 "declRef": 42
}]
}},"_analyzed": true},{"name": "ier_addr","kind": "const","isTest": false,"src": 260,"value": {"typeRef": {
 "type": 32
},"expr": {
 "binOpIndex": 2
}},"_analyzed": true},{"name": "srr_addr","kind": "const","isTest": false,"src": 261,"value": {"typeRef": {
 "type": 32
},"expr": {
 "binOpIndex": 5
}},"_analyzed": true},{"name": "mcr_addr","kind": "const","isTest": false,"src": 262,"value": {"typeRef": {
 "type": 32
},"expr": {
 "binOpIndex": 8
}},"_analyzed": true},{"name": "lcr_addr","kind": "const","isTest": false,"src": 263,"value": {"typeRef": {
 "type": 32
},"expr": {
 "binOpIndex": 11
}},"_analyzed": true},{"name": "dll_addr","kind": "const","isTest": false,"src": 264,"value": {"typeRef": {
 "type": 32
},"expr": {
 "binOpIndex": 14
}},"_analyzed": true},{"name": "dlh_addr","kind": "const","isTest": false,"src": 265,"value": {"typeRef": {
 "type": 32
},"expr": {
 "binOpIndex": 17
}},"_analyzed": true},{"name": "sfe_addr","kind": "const","isTest": false,"src": 266,"value": {"typeRef": {
 "type": 32
},"expr": {
 "binOpIndex": 20
}},"_analyzed": true},{"name": "srt_addr","kind": "const","isTest": false,"src": 267,"value": {"typeRef": {
 "type": 32
},"expr": {
 "binOpIndex": 23
}},"_analyzed": true},{"name": "stet_addr","kind": "const","isTest": false,"src": 268,"value": {"typeRef": {
 "type": 32
},"expr": {
 "binOpIndex": 26
}},"_analyzed": true},{"name": "usr_addr","kind": "const","isTest": false,"src": 269,"value": {"typeRef": {
 "type": 32
},"expr": {
 "binOpIndex": 29
}},"_analyzed": true},{"name": "thr_addr","kind": "const","isTest": false,"src": 270,"value": {"typeRef": {
 "type": 32
},"expr": {
 "binOpIndex": 32
}},"_analyzed": true},{"name": "uartIOMux","kind": "const","isTest": false,"src": 271,"value": {"typeRef": {
 "type": 32
},"expr": {
 "type": 172
}},"_analyzed": true},{"name": "setBaudrate","kind": "const","isTest": false,"src": 272,"value": {"typeRef": {
 "type": 32
},"expr": {
 "type": 173
}},"_analyzed": true},{"name": "uartInit","kind": "const","isTest": false,"src": 274,"value": {"typeRef": {
 "type": 32
},"expr": {
 "type": 174
}},"_analyzed": true},{"name": "putc","kind": "const","isTest": false,"src": 275,"value": {"typeRef": {
 "type": 32
},"expr": {
 "type": 175
}},"_analyzed": true},{"name": "print","kind": "const","isTest": false,"src": 277,"value": {"typeRef": {
 "type": 32
},"expr": {
 "type": 176
}},"_analyzed": true},{"name": "UART0_BASE","kind": "const","isTest": false,"src": 36,"value": {"typeRef": {
 "type": 34
},"expr": {
 "int": 4279762944
}},"_analyzed": true},{"name": "UART1_BASE","kind": "const","isTest": false,"src": 37,"value": {"typeRef": {
 "type": 34
},"expr": {
 "int": 4279828480
}},"_analyzed": true},{"name": "UART2_BASE","kind": "const","isTest": false,"src": 38,"value": {"typeRef": {
 "type": 34
},"expr": {
 "int": 4279894016
}},"_analyzed": true},{"name": "UART3_BASE","kind": "const","isTest": false,"src": 39,"value": {"typeRef": {
 "type": 34
},"expr": {
 "int": 4279959552
}},"_analyzed": true},{"name": "UART4_BASE","kind": "const","isTest": false,"src": 40,"value": {"typeRef": {
 "type": 34
},"expr": {
 "int": 4280745984
}},"_analyzed": true},{"name": "RBR_OFFSET","kind": "const","isTest": false,"src": 41,"value": {"typeRef": {
 "type": 34
},"expr": {
 "int": 0
}},"_analyzed": true},{"name": "THR_OFFSET","kind": "const","isTest": false,"src": 42,"value": {"typeRef": {
 "type": 34
},"expr": {
 "int": 0
}},"_analyzed": true},{"name": "DLL_OFFSET","kind": "const","isTest": false,"src": 43,"value": {"typeRef": {
 "type": 34
},"expr": {
 "int": 0
}},"_analyzed": true},{"name": "DLH_OFFSET","kind": "const","isTest": false,"src": 44,"value": {"typeRef": {
 "type": 34
},"expr": {
 "int": 4
}},"_analyzed": true},{"name": "IER_OFFSET","kind": "const","isTest": false,"src": 45,"value": {"typeRef": {
 "type": 34
},"expr": {
 "int": 4
}},"_analyzed": true},{"name": "IIR_OFFSET","kind": "const","isTest": false,"src": 46,"value": {"typeRef": {
 "type": 34
},"expr": {
 "int": 8
}},"_analyzed": true},{"name": "FCR_OFFSET","kind": "const","isTest": false,"src": 47,"value": {"typeRef": {
 "type": 34
},"expr": {
 "int": 8
}},"_analyzed": true},{"name": "LCR_OFFSET","kind": "const","isTest": false,"src": 48,"value": {"typeRef": {
 "type": 34
},"expr": {
 "int": 12
}},"_analyzed": true},{"name": "MCR_OFFSET","kind": "const","isTest": false,"src": 49,"value": {"typeRef": {
 "type": 34
},"expr": {
 "int": 16
}},"_analyzed": true},{"name": "LSR_OFFSET","kind": "const","isTest": false,"src": 50,"value": {"typeRef": {
 "type": 34
},"expr": {
 "int": 20
}},"_analyzed": true},{"name": "MSR_OFFSET","kind": "const","isTest": false,"src": 51,"value": {"typeRef": {
 "type": 34
},"expr": {
 "int": 24
}},"_analyzed": true},{"name": "SCR_OFFSET","kind": "const","isTest": false,"src": 52,"value": {"typeRef": {
 "type": 34
},"expr": {
 "int": 28
}},"_analyzed": true},{"name": "SRBR_OFFSET","kind": "const","isTest": false,"src": 53,"value": {"typeRef": {
 "type": 34
},"expr": {
 "int": 48
}},"_analyzed": true},{"name": "STHR_OFFSET","kind": "const","isTest": false,"src": 54,"value": {"typeRef": {
 "type": 34
},"expr": {
 "int": 108
}},"_analyzed": true},{"name": "FAR_OFFSET","kind": "const","isTest": false,"src": 55,"value": {"typeRef": {
 "type": 34
},"expr": {
 "int": 112
}},"_analyzed": true},{"name": "TFR_OFFSET","kind": "const","isTest": false,"src": 56,"value": {"typeRef": {
 "type": 34
},"expr": {
 "int": 116
}},"_analyzed": true},{"name": "RFW_OFFSET","kind": "const","isTest": false,"src": 57,"value": {"typeRef": {
 "type": 34
},"expr": {
 "int": 120
}},"_analyzed": true},{"name": "USR_OFFSET","kind": "const","isTest": false,"src": 58,"value": {"typeRef": {
 "type": 34
},"expr": {
 "int": 124
}},"_analyzed": true},{"name": "TFL_OFFSET","kind": "const","isTest": false,"src": 59,"value": {"typeRef": {
 "type": 34
},"expr": {
 "int": 128
}},"_analyzed": true},{"name": "RFL_OFFSET","kind": "const","isTest": false,"src": 60,"value": {"typeRef": {
 "type": 34
},"expr": {
 "int": 132
}},"_analyzed": true},{"name": "SRR_OFFSET","kind": "const","isTest": false,"src": 61,"value": {"typeRef": {
 "type": 34
},"expr": {
 "int": 136
}},"_analyzed": true},{"name": "SRTS_OFFSET","kind": "const","isTest": false,"src": 62,"value": {"typeRef": {
 "type": 34
},"expr": {
 "int": 140
}},"_analyzed": true},{"name": "SBCR_OFFSET","kind": "const","isTest": false,"src": 63,"value": {"typeRef": {
 "type": 34
},"expr": {
 "int": 144
}},"_analyzed": true},{"name": "SDMAM_OFFSET","kind": "const","isTest": false,"src": 64,"value": {"typeRef": {
 "type": 34
},"expr": {
 "int": 148
}},"_analyzed": true},{"name": "SFE_OFFSET","kind": "const","isTest": false,"src": 65,"value": {"typeRef": {
 "type": 34
},"expr": {
 "int": 152
}},"_analyzed": true},{"name": "SRT_OFFSET","kind": "const","isTest": false,"src": 66,"value": {"typeRef": {
 "type": 34
},"expr": {
 "int": 156
}},"_analyzed": true},{"name": "STET_OFFSET","kind": "const","isTest": false,"src": 67,"value": {"typeRef": {
 "type": 34
},"expr": {
 "int": 160
}},"_analyzed": true},{"name": "HTX_OFFSET","kind": "const","isTest": false,"src": 68,"value": {"typeRef": {
 "type": 34
},"expr": {
 "int": 164
}},"_analyzed": true},{"name": "DMASA_OFFSET","kind": "const","isTest": false,"src": 69,"value": {"typeRef": {
 "type": 34
},"expr": {
 "int": 168
}},"_analyzed": true},{"name": "CPR_OFFSET","kind": "const","isTest": false,"src": 70,"value": {"typeRef": {
 "type": 34
},"expr": {
 "int": 244
}},"_analyzed": true},{"name": "UCV_OFFSET","kind": "const","isTest": false,"src": 71,"value": {"typeRef": {
 "type": 34
},"expr": {
 "int": 248
}},"_analyzed": true},{"name": "CTR_OFFSET","kind": "const","isTest": false,"src": 72,"value": {"typeRef": {
 "type": 34
},"expr": {
 "int": 252
}},"_analyzed": true},{"name": "uart_rbr","kind": "const","isTest": false,"src": 73,"value": {"typeRef": {
 "type": 32
},"expr": {
 "type": 78
}},"_analyzed": true},{"name": "uart_thr","kind": "const","isTest": false,"src": 76,"value": {"typeRef": {
 "type": 32
},"expr": {
 "type": 80
}},"_analyzed": true},{"name": "uart_dll","kind": "const","isTest": false,"src": 79,"value": {"typeRef": {
 "type": 32
},"expr": {
 "type": 82
}},"_analyzed": true},{"name": "uart_dlh","kind": "const","isTest": false,"src": 82,"value": {"typeRef": {
 "type": 32
},"expr": {
 "type": 84
}},"_analyzed": true},{"name": "uart_ier","kind": "const","isTest": false,"src": 85,"value": {"typeRef": {
 "type": 32
},"expr": {
 "type": 86
}},"_analyzed": true},{"name": "uart_iir","kind": "const","isTest": false,"src": 93,"value": {"typeRef": {
 "type": 32
},"expr": {
 "type": 89
}},"_analyzed": true},{"name": "uart_fcr","kind": "const","isTest": false,"src": 98,"value": {"typeRef": {
 "type": 32
},"expr": {
 "type": 94
}},"_analyzed": true},{"name": "uart_lcr","kind": "const","isTest": false,"src": 106,"value": {"typeRef": {
 "type": 32
},"expr": {
 "type": 98
}},"_analyzed": true},{"name": "uart_mcr","kind": "const","isTest": false,"src": 115,"value": {"typeRef": {
 "type": 32
},"expr": {
 "type": 101
}},"_analyzed": true},{"name": "uart_lsr","kind": "const","isTest": false,"src": 124,"value": {"typeRef": {
 "type": 32
},"expr": {
 "type": 103
}},"_analyzed": true},{"name": "uart_msr","kind": "const","isTest": false,"src": 133,"value": {"typeRef": {
 "type": 32
},"expr": {
 "type": 105
}},"_analyzed": true},{"name": "uart_scr","kind": "const","isTest": false,"src": 142,"value": {"typeRef": {
 "type": 32
},"expr": {
 "type": 107
}},"_analyzed": true},{"name": "uart_srbr","kind": "const","isTest": false,"src": 145,"value": {"typeRef": {
 "type": 32
},"expr": {
 "type": 109
}},"_analyzed": true},{"name": "uart_sthr","kind": "const","isTest": false,"src": 148,"value": {"typeRef": {
 "type": 32
},"expr": {
 "type": 111
}},"_analyzed": true},{"name": "uart_far","kind": "const","isTest": false,"src": 151,"value": {"typeRef": {
 "type": 32
},"expr": {
 "type": 113
}},"_analyzed": true},{"name": "uart_tfr","kind": "const","isTest": false,"src": 154,"value": {"typeRef": {
 "type": 32
},"expr": {
 "type": 115
}},"_analyzed": true},{"name": "uart_rfw","kind": "const","isTest": false,"src": 157,"value": {"typeRef": {
 "type": 32
},"expr": {
 "type": 117
}},"_analyzed": true},{"name": "uart_usr","kind": "const","isTest": false,"src": 162,"value": {"typeRef": {
 "type": 32
},"expr": {
 "type": 119
}},"_analyzed": true},{"name": "uart_tfl","kind": "const","isTest": false,"src": 169,"value": {"typeRef": {
 "type": 32
},"expr": {
 "type": 121
}},"_analyzed": true},{"name": "uart_rfl","kind": "const","isTest": false,"src": 172,"value": {"typeRef": {
 "type": 32
},"expr": {
 "type": 124
}},"_analyzed": true},{"name": "uart_srr","kind": "const","isTest": false,"src": 175,"value": {"typeRef": {
 "type": 32
},"expr": {
 "type": 127
}},"_analyzed": true},{"name": "uart_srts","kind": "const","isTest": false,"src": 180,"value": {"typeRef": {
 "type": 32
},"expr": {
 "type": 128
}},"_analyzed": true},{"name": "uart_sbcr","kind": "const","isTest": false,"src": 183,"value": {"typeRef": {
 "type": 32
},"expr": {
 "type": 130
}},"_analyzed": true},{"name": "uart_sdmam","kind": "const","isTest": false,"src": 186,"value": {"typeRef": {
 "type": 32
},"expr": {
 "type": 132
}},"_analyzed": true},{"name": "uart_sfe","kind": "const","isTest": false,"src": 189,"value": {"typeRef": {
 "type": 32
},"expr": {
 "type": 134
}},"_analyzed": true},{"name": "uart_srt","kind": "const","isTest": false,"src": 192,"value": {"typeRef": {
 "type": 32
},"expr": {
 "type": 136
}},"_analyzed": true},{"name": "uart_stet","kind": "const","isTest": false,"src": 195,"value": {"typeRef": {
 "type": 32
},"expr": {
 "type": 138
}},"_analyzed": true},{"name": "uart_htx","kind": "const","isTest": false,"src": 198,"value": {"typeRef": {
 "type": 32
},"expr": {
 "type": 140
}},"_analyzed": true},{"name": "uart_dmasa","kind": "const","isTest": false,"src": 201,"value": {"typeRef": {
 "type": 32
},"expr": {
 "type": 142
}},"_analyzed": true},{"name": "uart_cpr","kind": "const","isTest": false,"src": 204,"value": {"typeRef": {
 "type": 32
},"expr": {
 "type": 144
}},"_analyzed": true},{"name": "uart_ucv","kind": "const","isTest": false,"src": 220,"value": {"typeRef": {
 "type": 32
},"expr": {
 "type": 149
}},"_analyzed": true},{"name": "uart_ctr","kind": "const","isTest": false,"src": 222,"value": {"typeRef": {
 "type": 32
},"expr": {
 "type": 150
}},"_analyzed": true},{"name": "mmio","kind": "const","isTest": false,"src": 225,"value": {"typeRef": {
 "type": 32
},"expr": {
 "type": 63
}},"_analyzed": true},{"name": "GRF_BASE","kind": "const","isTest": false,"src": 226,"value": {"typeRef": {
 "type": 34
},"expr": {
 "int": 4285988864
}},"_analyzed": true},{"name": "IOMUX_BASE","kind": "const","isTest": false,"src": 227,"value": {"typeRef": {
 "type": 34
},"expr": {
 "int": 4286046208
}},"_analyzed": true},{"name": "GPIO4B_OFFSET","kind": "const","isTest": false,"src": 228,"value": {"typeRef": {
 "type": 34
},"expr": {
 "int": 57380
}},"_analyzed": true},{"name": "GPIO4C_OFFSET","kind": "const","isTest": false,"src": 229,"value": {"typeRef": {
 "type": 34
},"expr": {
 "int": 57384
}},"_analyzed": true},{"name": "PMU_GRF_BASE","kind": "const","isTest": false,"src": 230,"value": {"typeRef": {
 "type": 34
},"expr": {
 "int": 4281466880
}},"_analyzed": true},{"name": "Register","kind": "const","isTest": false,"src": 231,"value": {"typeRef": {
 "type": 32
},"expr": {
 "type": 152
}},"_analyzed": true},{"name": "GRFAddr","kind": "const","isTest": false,"src": 235,"value": {"typeRef": {
 "type": 32
},"expr": {
 "type": 154
}},"_analyzed": true},{"name": "gpio_4b_grf","kind": "const","isTest": false,"src": 238,"value": {"typeRef": {
 "type": 32
},"expr": {
 "type": 155
}},"_analyzed": true},{"name": "gpio_4c_grf","kind": "const","isTest": false,"src": 247,"value": {"typeRef": {
 "type": 32
},"expr": {
 "type": 163
}},"_analyzed": true},{"name": "init","kind": "const","isTest": false,"src": 232,"value": {"typeRef": {
 "type": 32
},"expr": {
 "type": 153
}},"_analyzed": true}],
 "exprs": [{
 "type": 65
},{
 "comptimeExpr": 0
},{
 "binOp": {"lhs": 3,"rhs": 4,"name": "bit_or"}
},{
 "declRef": 23
},{
 "refPath": [{
 "declRef": 19
},{
 "declRef": 49
}]
},{
 "binOp": {"lhs": 6,"rhs": 7,"name": "bit_or"}
},{
 "declRef": 23
},{
 "refPath": [{
 "declRef": 19
},{
 "declRef": 65
}]
},{
 "binOp": {"lhs": 9,"rhs": 10,"name": "bit_or"}
},{
 "declRef": 23
},{
 "refPath": [{
 "declRef": 19
},{
 "declRef": 53
}]
},{
 "binOp": {"lhs": 12,"rhs": 13,"name": "bit_or"}
},{
 "declRef": 23
},{
 "refPath": [{
 "declRef": 19
},{
 "declRef": 52
}]
},{
 "binOp": {"lhs": 15,"rhs": 16,"name": "bit_or"}
},{
 "declRef": 23
},{
 "refPath": [{
 "declRef": 19
},{
 "declRef": 47
}]
},{
 "binOp": {"lhs": 18,"rhs": 19,"name": "bit_or"}
},{
 "declRef": 23
},{
 "refPath": [{
 "declRef": 19
},{
 "declRef": 48
}]
},{
 "binOp": {"lhs": 21,"rhs": 22,"name": "bit_or"}
},{
 "declRef": 23
},{
 "refPath": [{
 "declRef": 19
},{
 "declRef": 69
}]
},{
 "binOp": {"lhs": 24,"rhs": 25,"name": "bit_or"}
},{
 "declRef": 23
},{
 "refPath": [{
 "declRef": 19
},{
 "declRef": 70
}]
},{
 "binOp": {"lhs": 27,"rhs": 28,"name": "bit_or"}
},{
 "declRef": 23
},{
 "refPath": [{
 "declRef": 19
},{
 "declRef": 71
}]
},{
 "binOp": {"lhs": 30,"rhs": 31,"name": "bit_or"}
},{
 "declRef": 23
},{
 "refPath": [{
 "declRef": 19
},{
 "declRef": 62
}]
},{
 "binOp": {"lhs": 33,"rhs": 34,"name": "bit_or"}
},{
 "declRef": 23
},{
 "refPath": [{
 "declRef": 19
},{
 "declRef": 46
}]
}],
 "comptimeExprs": [{"code": "ret_type"},{"code": "Read"},{"code": "Write"},{"code": "Write"},{"code": "func call"},{"code": "func call"},{"code": "func call"}]
};