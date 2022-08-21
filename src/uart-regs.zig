//! Address's and offsets for RK3399 UART registers and UART Base Addr's &
//! UART base MMIO addresses. To find these values, look in the Rk3399 TRM
//! at the address mapping section. We also define a type for each register
//! that represents it as a struct with a u32 backing it. This allows us
//! easy access to specific fields that correspond to the same or similar
//! name as in the TRM.
//!
//! This info can be found under the UART chapter of the RK3399 TRM.
//! I have noticed several different revisions of this TRM floating around,
//! and i advise you get all the copies you can find. Some have different
//! information entirely from others (some never mention the UART). If your TRM
//! does not have a UART section, i recommend finding another revision or
//! 'part x' sub revision of the TRM.`
pub const UART0_BASE = 0xFF180000;
pub const UART1_BASE = 0xFF190000;
pub const UART2_BASE = 0xFF1A0000;
pub const UART3_BASE = 0xFF1B0000;
pub const UART4_BASE = 0xFF270000;

pub const RBR_OFFSET = 0x0000;
pub const THR_OFFSET = 0x0000;
pub const DLL_OFFSET = 0x0000;
pub const DLH_OFFSET = 0x0004;
pub const IER_OFFSET = 0x0004;
pub const IIR_OFFSET = 0x0008;
pub const FCR_OFFSET = 0x0008;
pub const LCR_OFFSET = 0x000C;
pub const MCR_OFFSET = 0x0010;
pub const LSR_OFFSET = 0x0014;
pub const MSR_OFFSET = 0x0018;
pub const SCR_OFFSET = 0x001C;
pub const SRBR_OFFSET = 0x0030;
pub const STHR_OFFSET = 0x006C;
pub const FAR_OFFSET = 0x0070;
pub const TFR_OFFSET = 0x0074;
pub const RFW_OFFSET = 0x078;
pub const USR_OFFSET = 0x007C;
pub const TFL_OFFSET = 0x0080;
pub const RFL_OFFSET = 0x0084;
pub const SRR_OFFSET = 0x0088;
pub const SRTS_OFFSET = 0x008C;
pub const SBCR_OFFSET = 0x0090;
pub const SDMAM_OFFSET = 0x0094;
pub const SFE_OFFSET = 0x0098;
pub const SRT_OFFSET = 0x009C;
pub const STET_OFFSET = 0x00A0;
pub const HTX_OFFSET = 0x00A4;
pub const DMASA_OFFSET = 0x00A8;
pub const CPR_OFFSET = 0x00F4;
pub const UCV_OFFSET = 0x00F8;
pub const CTR_OFFSET = 0x00FC;

/// Register bitfield struct for the UART RBR, short for Read Buffer
/// Register. Address: Operational Base + offset (0x0000)
pub const uart_rbr = packed struct(u32) {
    // From TRM:
    // Data byte received on the serial input port (sin) in UART mode, or the
    // serial infrared input (sir_in) in infrared mode. The data in this
    // register is valid only if the Data Ready (DR) bit in the Line Status
    // Register (LCR) is set.
    //
    // If in non-FIFO mode (FIFO_MODE == NONE) or FIFOs are disabled (FCR[0]
    // set to zero), the data in the RBR must be read before the next data
    // arrives, otherwise it is overwritten, resulting in an over-run error.
    //
    // If in FIFO mode (FIFO_MODE != NONE) and FIFOs are enabled (FCR[0] set
    // to one), this register accesses the head of the receive FIFO. If the
    // receive FIFO is full and this register is not read before the next data
    // character arrives, then the data already in the FIFO is preserved, but
    // any incoming data are lost and an over-run error occurs.
    //
    // Attr: RW (read/write)
    data_input: u8,
    // Attr: RO (read only)
    _reserved: u24,
};

/// UART THR, short for Transmit Holding Register
/// Address: Operational Base + offset (0x0000)
pub const uart_thr = packed struct(u32) {
    // From the TRM:
    //
    // Data to be transmitted on the serial output port (sout) in UART mode
    // or the serial infrared output (sir_out_n) in infrared mode. Data should
    // only be written to the THR when the THR Empty (THRE) bit (LSR[5]) is
    // set.
    //
    // If in non-FIFO mode or FIFOs are disabled (FCR[0] = 0) and THRE is set,
    // writing a single character to the THR clears the THRE. Any additional
    // writes to the THR before the THRE is set again causes the THR data to
    // be overwritten.
    //
    // If in FIFO mode and FIFOs are enabled (FCR[0] = 1) and THRE is set, x
    // number of characters of data may be written to the THR before the FIFO
    // is full. The number x (default=16) is determined by the value of FIFO
    // Depth that you set during configuration. Any attempt to write data when
    // the FIFO is full results in the write data being lost.
    //
    // Attr: RW (Read/Write)
    data_output: u8,
    // Attr: RO (read only)
    _reserved: u24 = 0,
};

/// UART DLL register, short for Divisor Latch (Low)
/// Address: Operational Base + offset (0x0000)
pub const uart_dll = packed struct(u32) {
    // Lower 8-bits of a 16-bit, read/write, Divisor Latch register that
    // contains the baud rate divisor for the UART. This register may only be
    // accessed when the DLAB bit (LCR[7]) is set and the UART is not busy
    // (USR[0] is zero). The output baud rate is equal to the serial clock
    // (sclk) frequency divided by sixteen times the value of the baud rate
    // divisor, as follows: baud rate = (serial clock freq) / (16 * divisor).
    //
    // Note that with the Divisor Latch Registers (DLL and DLH) set to zero,
    // the baud clock is disabled and no serial communications occur. Also,
    // once the DLH is set, at least 8 clock cycles of the slowest UART clock
    // should be allowed to pass before transmitting or receiving data.
    //
    // Attr: RW (Read/Write)
    baud_rate_divisor_L: u8,
    // Attr: RO (read only)
    _reserved: u24,
};

/// UART DLH register, short for Divisor Latch (High)
/// Address: Operational Base + offset (0x0004)
pub const uart_dlh = packed struct(u32) {
    // Upper 8 bits of a 16-bit, read/write, Divisor Latch register that
    // contains the baud rate divisor for the UART.
    //
    // Attr: RW
    baud_rate_divisor_H: u8,
    // Attr: RO (read only)
    _reserved: u24,
};

/// UART IER, short for Interrupt Enable Register
/// Address: Operational Base + offset (0x0004)
pub const uart_ier = packed struct(u32) {
    /// Enable Received Data Available Interrupt.
    /// This is used to enable/disable the generation of Received Data
    /// Available Interrupt and the Character Timeout Interrupt (if in FIFO
    /// mode and FIFOs enabled). These are the second highest priority
    /// interrupts.
    ///
    /// Attr: RW
    recv_data_aval_int_en: bool,
    /// Enable Transmit Holding Register Empty Interrupt.
    ///
    /// Attr: RW
    trans_hold_empty_int_en: bool,
    /// Enable Receiver Line Status Interrupt.
    /// This is used to enable/disable the generation of Receiver Line Status
    /// Interrupt. This is the highest priority interrupt.
    ///
    /// Attr: RW
    recv_line_status_int_en: bool,
    /// Enable Modem Status Interrupt.
    /// This is used to enable/disable the generation of Modem Status Interrupt.
    /// This is the fourth highest priority interrupt
    ///
    /// Attr: RW
    modem_status_int_en: bool,
    /// Should be 0, bits 4:6
    /// Attr: RO
    _reserved4_6: u3,
    /// Programmable THRE Interrupt Mode Enable
    /// This is used to enable/disable the generation of THRE Interrupt.
    ///
    /// Attr: RW
    prog_thre_int_en: bool,
    /// Should be 0, bits 8:31
    /// Attr: RO
    _reserved8_31: u24,
};

/// UART IIR, short for Interrupt Identification Register
/// Address: Operational Base + offset (0x0008)
pub const uart_iir = packed struct(u32) {
    /// Interrupt ID
    ///
    /// This indicates the highest priority pending interrupt which can be one
    /// of the following types:
    /// 0000 = modem status
    /// 0001 = no interrupt pending
    /// 0010 = THR empty
    /// 0100 = received data available
    /// 0110 = receiver line status
    /// 0111 = busy detect
    /// 1100 = character timeout
    ///
    /// Attr: RO
    int_id: u4,
    /// Should be 0, bits 4:5
    /// Attr: RO
    _reserved4_5: u2,
    /// FIFOs Enabled.
    ///
    /// This is used to indicate whether the FIFOs are enabled or disabled.
    /// 00 = disabled
    /// 11 = Enabled
    /// Attr: RO
    fifos_en: u2,
    /// Should be 0, bits 8:31,
    /// Attr: RO
    _reserved8_31: u24,
};

/// UART FCR, short for FIFO Control Register
/// Address: Operational Base + offset (0x0008)
pub const uart_fcr = packed struct(u32) {
    /// FIFO Enable.
    /// FIFO Enable. This enables/disables the transmit (XMIT) and receive
    /// (RCVR) FIFOs. Whenever the value of this bit is changed both the XMIT
    /// and RCVR controller portion of FIFOs is reset.
    ///
    /// Attr: WO (Write Only)
    fifo_en: bool,
    /// RCVR FIFO Reset.
    ///
    /// This resets the control portion of the receive FIFO and treats the
    /// FIFO as empty. This also de-asserts the DMA RX request and single
    /// signals when additional DMA handshaking signals are selected. Note
    /// that this bit is 'self-clearing'. It is not necessary to clear this bit
    rcvr_fifo_reset: bool,
    /// XMIT FIFO Reset.
    ///
    /// This resets the control portion of the transmit FIFO and treats the
    /// FIFO as empty. This also de-asserts the DMA TX request and single
    /// signals when additional DMA handshaking signals are selected . Note
    /// that this bit is 'self-clearing'. It is not necessary to clear this bit
    xmit_fifo_reset: bool,
    /// DMA Mode
    ///
    /// This determines the DMA signalling mode used for the dma_tx_req_n and
    /// dma_rx_req_n output signals when additional DMA handshaking signals
    /// are not selected .
    /// 0 = mode 0
    /// 1 = mode 11100 = character timeout.
    ///
    /// Attr: WO
    dma_mode: bool,
    /// TX Empty Trigger.
    ///
    /// This is used to select the empty threshold level at which the THRE
    /// Interrupts are generated when the mode is active. It also determines
    /// when the dma_tx_req_n signal is asserted when in certain modes of
    /// operation. The following trigger levels are supported:
    /// 00 = FIFO empty
    /// 01 = 2 characters in the FIFO
    /// 10 = FIFO 1/4 full
    /// 11 = FIFO 1/2 full
    ///
    /// Attr: WO
    tx_empty_trigger: u2,
    /// RCVR Trigger
    ///
    /// This is used to select the trigger level in the receiver FIFO at which
    /// the Received Data Available Interrupt is generated. In auto flow
    /// control mode it is used to determine when the rts_n signal is
    /// de-asserted. It also determines when the dma_rx_req_n signal is
    /// asserted in certain modes of operation. The following trigger levels
    /// are supported:
    ///
    /// 00 = 1 character in the FIFO
    /// 01 = FIFO 1/4 full
    /// 10 = FIFO 1/2 full
    /// 11 = FIFO 2 less than ful (-> is this an errata?)
    ///
    /// Attr: WO
    rcvr_trigger: u2,
    /// Should be 0, bits 8:31
    /// Attr: RO
    _reserved8_31: u24,
};

/// UART LCR, short for Line Control Register
/// Address: Operational Base + offset (0x000C)
pub const uart_lcr = packed struct(u32) {
    /// Data Length Select.
    /// Writeable only when UART is not busy (USR[0] is zero), always readable.
    /// This is used to select the number of data bits per character that the
    /// peripheral transmits and receives. The number of bit that may be
    /// selected areas follows:
    /// 00 = 5 bits
    /// 01 = 6 bits
    /// 10 = 7 bits
    /// 11 = 8 bits
    ///
    /// Attr: RW
    data_len_sel: u2,
    /// Number of stop bits.
    /// Writeable only when UART is not busy (USR[0] is zero), always readable.
    /// This is used to select the number of stop bits per character that the
    /// peripheral transmits and receives. If set to zero, one stop bit is
    /// transmitted in the serial data. If set to one and the data bits are
    /// set to 5 (LCR[1:0] set to zero) one and a half stop bits is transmitted
    /// Otherwise, two stop bits are transmitted. Note that regardless of the
    /// number of stop bits selected, the receiver checks only the first stop
    /// bit.
    /// 0 = 1 stop bit
    /// 1 = 1.5 stop bits when DLS (LCR[1:0]) is zero, else 2 stop bit.
    ///
    /// Attr: RW
    stop_bits_num: bool,
    /// Parity Enable.
    /// Writeable only when UART is not busy (USR[0] is zero), always readable.
    /// This bit is used to enable and disable parity generation and detection
    /// in transmitted and received serial character respectively.
    /// 0 = parity disabled
    /// 1 = parity enabled
    ///
    /// Attr: RW
    parity_en: bool,
    /// Even Parity Select.
    ///
    /// Writeable only when UART is not busy (USR[0] is zero), always readable.
    /// This is used to select between even and odd parity, when parity is
    /// enabled (PEN set to one). If set to one, an even number of logic 1s
    /// is transmitted or checked. If set to zero, an odd number of logic 1s
    /// is transmitted or checked.
    ///
    /// Attr: RW
    even_parity_sel: bool,
    /// SBZ, Bit 5
    _reserved: bool = false,
    /// Break Control bit
    ///
    /// This is used to cause a break condition to be transmitted to the
    /// receiving device. If set to one the serial output is forced to the
    /// spacing (logic 0) state. When not in Loopback Mode, as determined by
    /// MCR[4], the sout line is forced low until the Break bit is cleared.
    /// If MCR[6] set to one, the sir_out_n line is continuously pulsed. When
    /// in Loopback Mode, the break condition is internally looped back to
    /// the receiver and the sir_out_n line is forced low.
    ///
    /// Attr: RW
    break_ctrl: bool,
    /// Divisor Latch Access Bit.
    ////
    /// Writeable only when UART is not busy (USR[0] is zero), always readable.
    /// This bit is used to enable reading and writing of the Divisor Latch
    /// register (DLL and DLH) to set the baud rate of the UART. This bit must
    /// be cleared after initial baud rate setup in order to access other
    /// registers.
    ///
    /// Attr: RW
    div_lat_access: bool,
    /// SBZ, bits 8:31
    /// Attr: RO
    _reserved8_31: u24 = 0,
};

/// UART MCR, short for Modem Control Register
/// Address: Operational Base + offset (0x0010)
pub const uart_mcr = packed struct(u32) {
    /// Data Terminal Ready.
    ///
    /// This is used to directly control the Data Terminal Ready (dtr_n) output.
    /// The value written to this location is inverted and driven out on
    /// dtr_n, that is:
    /// 0 = dtr_n de-asserted (logic 1)
    /// 1 = dtr_n asserted (logic 0)
    ///
    /// Attr: RW
    data_term_ready: bool,
    /// Request to Send.
    ///
    /// This is used to directly control the Request to Send (rts_n) output.
    /// The Request To Send (rts_n) output is used to inform the modem or data
    /// set that the UART is ready to exchange data.
    ///
    /// Attr: RW
    req_to_send: bool,
    /// OUT1
    ///
    /// This is used to directly control the user-designated Output1 (out1_n)
    /// output. The value written to this location is inverted and driven out
    /// on out1_n, that is:
    /// 1’b0: out1_n de-asserted (logic 1)
    /// 1’b1: out1_n asserted (logic 0)
    ///
    /// Attr: RW
    out1: bool,
    /// OUT2, same as above but with 2 :)
    out2: bool,
    /// Loopback Bit
    ///
    /// This is used to put the UART into a diagnostic mode for test purposes.
    ///
    /// Attr: RW
    loopback: bool,
    /// Auto Flow Control Enable
    ///
    /// Auto Flow Control Enable.
    /// 0 = Auto Flow Control Mode disabled
    /// 1 = Auto Flow Control Mode enabled
    ///
    /// Attr: RW
    auto_flow_ctrl_en: bool,
    /// SIR Mode Enable
    ///
    /// This is used to enable/disable the IrDA SIR Mode.
    /// 0 = irda sir mode disabled
    /// 1 = IrDA SIR Mode Enabled
    ///
    /// Attr: RW
    sir_mode_en: bool,
    /// SBZ, bits 7:31
    _reserved7_31: u25,
};

/// UART LSR, short for Line Status Register
/// Address: Operational Base + offset (0x0014)
pub const uart_lsr = packed struct(u32) {
    /// Data Ready bit.
    ///
    /// This is used to indicate that the receiver contains at least one
    /// character in the RBR or the receiver FIFO.
    /// 0 = no data ready
    /// 1 = data ready
    ///
    /// Attr: RO
    data_ready: bool,
    /// Overrun error bit.
    /// This is used to indicate the occurrence of an overrun error.
    /// This occurs if a new data character was received before the previous
    /// data was read.
    ///
    /// Attr: RO
    overrun_error: bool,
    /// Parity Error Bit
    ///
    /// This is used to indicate the occurrence of a parity error in the
    /// receiver if the Parity Enable (PEN) bit (LCR[3]) is set.
    ///
    /// Attr: RO
    parity_error: bool,
    /// Framing Error Bit
    ///
    /// This is used to indicate the occurrence of a framing error in the
    /// receiver. A framing error occurs when the receiver does not detect a
    /// valid STOP bit in the received data.
    ///
    /// Attr: RO
    framing_error: bool,
    /// Transmit Holding Register Empty bit.
    /// If THRE mode is disabled (IER[7] set to zero) and regardless of FIFO's
    /// being implemented/enabled or not, this bit indicates that the THR or
    /// TX FIFO is empty.
    ///
    /// This bit is set whenever data is transferred from the THR or TX FIFO to
    /// the transmitter shift register and no new data has been written to the
    /// THR or TX FIFO. This also causes a THRE Interrupt to occur, if the
    /// THRE Interrupt is enabled. If IER[7] set to one and FCR[0] set to one
    /// respectively, the functionality is switched to indicate the
    /// transmitter FIFO is full, and no longer controls THRE interrupts,
    /// which are then controlled by the FCR[5:4] threshold setting.
    ///
    /// Attr: RO
    trans_hold_reg_empty: bool,
    /// Transmitter Empty bit
    ///
    /// Transmitter Empty bit. If FIFOs enabled (FCR[0] set to one), this bit
    /// is set whenever the Transmitter Shift Register and the FIFO are both
    /// empty. If FIFOs are disabled, this bit is set whenever the Transmitter
    /// Holding Register and the Transmitter Shift Register are both empty.
    ///
    /// Attr: RO
    trans_empty: bool,
    /// Receiver FIFO Error bit.
    ///
    /// This bit is relevant FIFOs are enabled (FCR[0] set to one). This is
    /// used to indicate if there is at least one parity error, framing error,
    /// or break indication in the FIFO.
    /// 0 = no error in RX FIFO
    /// 1 = error in RX FIFO
    ///
    /// Attr: RO
    recv_fifo_error: bool,
    /// SBZ, bits 8:31
    ///
    /// Attr: RO
    _reserved8_31: u24,
};

/// UART MSR, short for Modem Status Register
/// Address: Operational Base + offset (0x0018)
/// Attr: RO
pub const uart_msr = packed struct(u32) {
    /// Delta Clear to Send.
    /// This is used to indicate that the modem control line cts_n has changed
    /// since the last time the MSR was read.
    delta_clear_to_sent: bool,
    /// Delta Data Set Ready.
    ///
    /// This is used to indicate that the modem control line dsr_n has changed
    /// since the last time the MSR was read.
    delta_data_set_ready: bool,
    /// Trailing Edge of Ring Indicator.
    ///
    /// Trailing Edge of Ring Indicator. This is used to indicate that a
    /// change on the input ri_n (from an active-low to an inactive-high state)
    /// has occurred since the last time the MSR was read.
    trailing_edge_ring_indicator: bool,
    /// Delta Data Carrier Detect.
    ///
    /// This is used to indicate that the modem control line dcd_n has changed
    /// since the last time the MSR was read.
    delta_data_carrier_detect: bool,
    /// Data Set Ready.
    ///
    /// This is used to indicate the current state of the modem control line
    /// dsr_n.
    data_set_ready: bool,
    /// Ring Indicator
    ///
    /// This is used to indicate the current state of the modem control line ri_n.
    ring_indicator: bool,
    /// Data Carrier Detect.
    /// This is used to indicate the current state of the modem control line
    /// dcd_n.
    data_carrier_detect: bool,
    /// SBZ bits 8:31
    _reserved8_31: u24,
};

/// UART SCR, short for Scratch Pad Register
/// Address: Operational Base + offset (0x001C)
pub const uart_scr = packed struct(u32) {
    /// This register is for programmers to use as a temporary storage space.
    /// Attr: RW
    temp_store_space: u8,
    /// SBZ, bits 8:31
    _reserved8_31: u24,
};

/// UART SRBR, short for Shadow Recv Buffer Register
/// Address: Operational Base + offset (0x0030)
/// Attr: RO
pub const uart_srbr = packed struct(u32) {
    /// This is a shadow register for the RBR and has been allocated sixteen
    /// 32-bit locations so as to accommodate burst accesses from the master.
    /// This register contains the data byte received on the serial input port
    /// (sin) in UART mode or the serial infrared input (sir_in) in infrared
    /// mode. The data in this register is valid only if the Data Ready (DR)
    /// bit in the Line status Register (LSR) is set.
    ///
    /// If FIFOs are disabled (FCR[0] set to zero), the data in the RBR must
    /// be read before the next data arrives, otherwise it is overwritten,
    /// resulting in an overrun error.
    ///
    /// If FIFOs are enabled (FCR[0] set to one), this register accesses the
    /// head of the receive FIFO. If the receive FIFO is full and this register
    /// is not read before the next data character arrives, then the data
    /// already in the FIFO are preserved, but any incoming data is lost. An
    /// overrun error also occurs.
    shadow_rbr: u8,
    /// SBZ, bits 8:31
    _reserved8_31: u24,
};

/// UART STHR, short for Shadow Transmit Holding Register
/// Address: Operational Base + offset (0x006C)
/// Attr: RO
pub const uart_sthr = packed struct(u32) {
    /// This is a shadow register for the THR.
    shadow_thr: u8,
    _reserved8_31: u24,
};

/// UART FAR, short for FIFO Access Register
/// Address: Operational Base + offset (0x0070)
pub const uart_far = packed struct(u32) {
    /// This register is use to enable a FIFO access mode for testing, so that
    /// the receive FIFO can be written by the master and the transmit FIFO
    /// can be read by the master when FIFOs are implemented and enabled.
    /// When FIFOs are not enabled it allows the RBR to be written by the
    /// master and the THR to be read by the master.
    /// 0 = FIFO access mode disabled
    /// 1 = FIFO access mode Enabled
    ///
    /// Attr: RW
    fifo_access_test_en: bool,
    /// SBZ Bits 1:31
    /// Attr: RO
    _reserved1_31: u31,
};

/// UART TFR, short for Transmit FIFO Read
/// Address: Operational Base + offset (0x0074)
/// Attr: RO
pub const uart_tfr = packed struct(u32) {
    /// Transmit FIFO Read.
    ///
    /// These bits are only valid when FIFO access mode is enabled (FAR[0] is
    /// set to one).When FIFOs are implemented and enabled, reading this
    /// register gives the data at the top of the transmit FIFO. Each
    /// consecutive read pops the transmit FIFO and gives the next data value
    /// that is currently at the top of the FIFO.
    trans_fifo_read: u8,
    /// SBZ, Bits 8:31
    _reserved8_31: u24,
};

/// UART RFW, short for Receive FIFO Write
/// Address: Operational Base + offset (0x0078)
/// Attr: WO
pub const uart_rfw = packed struct(u32) {
    /// Receive FIFO Write Data.
    ///
    /// These bits are only valid when FIFO access mode is enabled (FAR[0] is
    /// set to one).
    ///
    /// When FIFOs are enabled, the data that is written to the RFWD is
    /// pushed into the receive FIFO. Each consecutive write pushes the new
    /// data to the next write location in the receive FIFO.
    ///
    /// When FIFOs not enabled, the data that is written to the RFWD is pushed
    /// into the RBR.
    recv_fifo_write: u8,
    /// Receive FIFO Parity Error.
    ///
    /// These bits are only valid when FIFO access mode is enabled (FAR[0] is
    /// set to one).
    recv_fifo_parity_error: bool,
    /// Receive FIFO Framing Error.
    ///
    /// These bits are only valid when FIFO access mode is enabled (FAR[0] is
    /// set to one).
    recv_fifo_framing_error: bool,
    /// SBZ, Bits 10:31
    _reserved10_31: u22,
};

/// UART USR, short for UART Status Register
/// Address: Operational Base + offset (0x007C)
/// Attr: RO
pub const uart_usr = packed struct(u32) {
    /// UART Busy.
    ///
    /// UART Busy. This is indicates that a serial transfer is in progress,
    /// when cleared indicates that the UART is idle or inactive.
    /// 0 = UART is idle or inactive
    /// 1 = UART is busy (actively transferring data)
    uart_busy: bool,
    /// Transmit FIFO Not Full.
    ///
    /// This is used to indicate that the transmit FIFO in not full.
    /// 0 = Transmit FIFO is full
    /// 1 = Transmit FIFO is not full
    /// This bit is cleared when the TX FIFO is full.
    trans_fifo_not_full: bool,
    /// Transmit FIFO Empty.
    ///
    /// This is used to indicate that the transmit FIFO is completely empty.
    /// 0 = Transmit FIFO is not empty
    /// 1 = Transmit FIFO is empty
    /// This bit is cleared when the TX FIFO is no longer empty
    trans_fifo_empty: bool,
    /// Receive FIFO Not Empty.
    ///
    /// This is used to indicate that the receive FIFO contains one or more
    /// entries.
    /// 0 = Receive FIFO is empty
    /// 1 = Receive FIFO is not empty
    /// This bit is cleared when the RX FIFO is empty.
    recv_fifo_not_empty: bool,
    /// Receive FIFO Full.
    ///
    /// This is used to indicate that the receive FIFO is completely full.
    /// 0 = Receive FIFO not full
    /// 1 = Receive FIFO Full
    /// This bit is cleared when the RX FIFO is no longer full.
    recv_fifo_full: bool,
    /// SBZ, Bits 5:31
    _reserved5_31: u27,
};

/// UART TFL, short for Transmit FIFO Level
/// Address: Operational Base + offset (0x0080)
/// Attr: RW
pub const uart_tfl = packed struct(u32) {
    /// Transmit FIFO Level
    ///
    /// This indicates the number of data entries in the transmit FIFO
    trans_fifo_lvl: u5,
    /// SBZ, Bits 5:31
    _reserved5_31: u27,
};

/// UART RFL, short for Recv FIFO Level
/// Address: Operational Base + offset (0x0084)
/// Attr: RO
pub const uart_rfl = packed struct(u32) {
    /// Receive FIFO Level.
    ///
    /// This is indicates the number of data entries in the receive FIFO.
    recv_fifo_lvl: u5,
    /// SBZ, Bits 5:31
    _reserved5_31: u27,
};

/// UART SRR, short for Software Reset Register
/// Address: Operational Base + offset (0x0088)
/// Attr: WO
pub const uart_srr = packed struct(u32) {
    /// UART Reset.
    ///
    /// This asynchronously resets the UART and synchronously removes the
    /// reset assertion. For a two clock implementation both pclk and sclk
    /// domains are reset.
    uart_reset: bool,
    /// RCVR FIFO Reset
    ///
    /// This is a shadow register for the RCVR FIFO Reset Bit (FCR[1])
    rcvr_fifo_reset: bool,
    /// XMIT FIFO Reset
    ///
    /// This is a shadow for the XMIT FIFO Reset bit (FCR[2])
    xmit_fifo_reset: bool,
    /// SBZ, Bits 3:31
    _reserved3_31: u29 = 0,
};

/// UART SRTS, short for Software Request To Send
/// Address: Operational Base + offset (0x008C)
/// Attr: RW
pub const uart_srts = packed struct(u32) {
    /// Shadow Request to Send.
    ///
    /// This is a shadow register for the RTS bit (MCR[1]), this can be used
    /// to remove the burden of having to performing a read- modify-write on
    /// the MCR.
    shadow_req_to_send: bool,
    /// SBZ, Bits 1:31
    _reserved1_31: u31,
};

/// UART SBCR, short for Shadow Break Control Register
/// Address: Operational Base + offset (0x0090)
/// Attr: RW
pub const uart_sbcr = packed struct(u32) {
    /// Shadow Break Control Bit.
    ///
    /// This is a shadow register for the Break bit (LCR[6]), this can be used
    /// to remove the burden of having to performing a read modify write on
    /// the LCR.
    shadow_break_ctrl: bool,
    /// SBZ, Bits 1:31
    _reserved1_31: u31,
};

/// UART SDMAM, short for Shadow DMA Mode
/// Address: Operational Base + offset (0x0094)
/// Attr: RW
pub const uart_sdmam = packed struct(u32) {
    /// Shadow DMA Mode.
    ///
    /// This is a shadow register for the DMA mode bit (FCR[3]).
    shadow_dma_mode: bool,
    /// SBZ, Bits 1:31
    _reserved1_31: u31,
};

/// UART SFE, short for Shadow FIFO Control
/// Address: Operational Base + offset (0x0098)
/// Attr: RW
pub const uart_sfe = packed struct(u32) {
    /// Shadow FIFO Enable.
    ///
    /// Shadow FIFO Enable. This is a shadow register for the FIFO enable bit
    /// (FCR[0]).
    shadow_fifo_en: bool,
    /// SBZ, Bits 1:31
    _reserved1_31: u31,
};

/// UART SRT, short for Shadow RCVR Trigger
/// Address: Operational Base + offset (0x009C)
///  Attr: RW
pub const uart_srt = packed struct(u32) {
    /// Shadow RCVR Trigger.
    ///
    /// This is a shadow register for the RCVR trigger bits (FCR[7:6]).
    shadow_rcvr_trigger: bool,
    /// SBZ, Bits 1:31
    _reserved1_31: u31,
};

/// UART STET, short for Shadow TX Empty Register
/// Address: Operational Base + offset (0x00A0)
/// Attr: RW
pub const uart_stet = packed struct(u32) {
    /// Shadow TX Empty Trigger.
    ///
    /// This is a shadow register for the TX empty trigger bits (FCR[5:4]).
    shadow_tx_empty_trigger: bool,
    /// SBZ, Bits 1:31
    _reserved1_31: u31,
};

/// UART HTX, short for Halt TX
/// Address: Operational Base + offset (0x00A4)
/// Attr: RW
pub const uart_htx = packed struct(u32) {
    /// This register is use to halt transmissions for testing, so that the
    /// transmit FIFO can be filled by the master when FIFOs are implemented
    /// and enabled.
    /// 0 = Halt TX disabled
    /// 1 = Halt TX enabled
    halt_tx_en: bool,
    /// SBZ, Bits 1:31
    _reserved1_31: u31,
};

/// UART DMASA, short for DMA Software Acknowledge
/// Address: Operational Base + offset (0x00A8)
/// Attr: WO
pub const uart_dmasa = packed struct(u32) {
    /// This register is use to perform a DMA software acknowledge if a
    /// transfer needs to be terminated due to an error condition.
    dma_software_ack: bool,
    /// SBZ, Bits 1:31
    _reserved1_31: u31,
};

/// UART CPR, short for Component Parameter Register
/// Address: Operational Base + offset (0x00F4)
/// UART_CPR is UART0’s own unique register !!!
/// Attr: RO
pub const uart_cpr = packed struct(u32) {
    /// 00 = 8 bits
    /// 01 = 16 bits
    /// 10 = 32 bits
    /// 11 = reserved
    APB_DATA_WIDTH: u2,
    /// SBZ
    _reserved2_3: u2,
    /// 0 = FALSE
    /// 1 = TRUE
    AFCE_MODE: bool,
    /// 0 = FALSE
    /// 1 = TRUE
    THRE_MODE: bool,
    SIR_MODE: bool,
    SIR_LP_MODE: bool,
    NEW_FEAT: bool,
    FIFO_ACCESS: bool,
    FIFO_STAT: bool,
    SHADOW: bool,
    UART_ADD_ENCODED_PARAMS: bool,
    DMA_EXTRA: bool,
    _reserved14_15: u2,
    /// FIFO Mode
    /// 0x00 = 0
    /// 0x01 = 16
    /// 0x02 = 32
    /// to
    /// 0x80 = 2048
    /// 0x81 - 0xFF = Reserved
    FIFO_MODE: u8,
    _reserved24_31: u9,
};

/// UART UCV, short for UART Component Version
/// Address: Operational Base + offset (0x00F8)
/// Attr: RO
pub const uart_ucv = packed struct(u32) {
    /// Version
    ///
    /// ASCII valye for each number in the version
    version: u32,
};

/// UART CTR, short for Component Type Register
/// Address: Operational Base + offset (0x00FC)
/// Attr: RO
pub const uart_ctr = packed struct(u32) {
    /// This register contains the peripherals identification code.
    peripheral_id: u32,
};
