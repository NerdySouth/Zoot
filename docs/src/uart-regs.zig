<!doctype html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">    <title>uart-regs.zig - source view</title>
    <link rel="icon" href="data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAAgklEQVR4AWMYWuD7EllJIM4G4g4g5oIJ/odhOJ8wToOxSTXgNxDHoeiBMfA4+wGShjyYOCkG/IGqWQziEzYAoUAeiF9D5U+DxEg14DRU7jWIT5IBIOdCxf+A+CQZAAoopEB7QJwBCBwHiip8UYmRdrAlDpIMgApwQZNnNii5Dq0MBgCxxycBnwEd+wAAAABJRU5ErkJggg=="/>
    <style>
      body{
        font-family: system-ui, -apple-system, Roboto, "Segoe UI", sans-serif;
        margin: 0;
        line-height: 1.5;
      }

      pre > code {
        display: block;
        overflow: auto;
        line-height: normal;
        margin: 0em;
      }
      .tok-kw {
          color: #333;
          font-weight: bold;
      }
      .tok-str {
          color: #d14;
      }
      .tok-builtin {
          color: #005C7A;
      }
      .tok-comment {
          color: #545454;
          font-style: italic;
      }
      .tok-fn {
          color: #900;
          font-weight: bold;
      }
      .tok-null {
          color: #005C5C;
      }
      .tok-number {
          color: #005C5C;
      }
      .tok-type {
          color: #458;
          font-weight: bold;
      }
      pre {
        counter-reset: line;
      }
      pre .line:before {
        counter-increment: line;
        content: counter(line);
        display: inline-block;
        padding-right: 1em;
        width: 2em;
        text-align: right;
        color: #999;
      }

      @media (prefers-color-scheme: dark) {
        body{
            background:#222;
            color: #ccc;
        }
        pre > code {
            color: #ccc;
            background: #222;
            border: unset;
        }
        .tok-kw {
            color: #eee;
        }
        .tok-str {
            color: #2e5;
        }
        .tok-builtin {
            color: #ff894c;
        }
        .tok-comment {
            color: #aa7;
        }
        .tok-fn {
            color: #B1A0F8;
        }
        .tok-null {
            color: #ff8080;
        }
        .tok-number {
            color: #ff8080;
        }
        .tok-type {
            color: #68f;
        }
      }
    </style>
</head>
<body>
<pre><code><span class="line" id="L1"><span class="tok-comment">//! Address's and offsets for RK3399 UART registers and UART Base Addr's &amp;</span></span>
<span class="line" id="L2"><span class="tok-comment">//! UART base MMIO addresses. To find these values, look in the Rk3399 TRM</span></span>
<span class="line" id="L3"><span class="tok-comment">//! at the address mapping section. We also define a type for each register</span></span>
<span class="line" id="L4"><span class="tok-comment">//! that represents it as a struct with a u32 backing it. This allows us</span></span>
<span class="line" id="L5"><span class="tok-comment">//! easy access to specific fields that correspond to the same or similar</span></span>
<span class="line" id="L6"><span class="tok-comment">//! name as in the TRM.</span></span>
<span class="line" id="L7"><span class="tok-comment">//!</span></span>
<span class="line" id="L8"><span class="tok-comment">//! This info can be found under the UART chapter of the RK3399 TRM.</span></span>
<span class="line" id="L9"><span class="tok-comment">//! I have noticed several different revisions of this TRM floating around,</span></span>
<span class="line" id="L10"><span class="tok-comment">//! and i advise you get all the copies you can find. Some have different</span></span>
<span class="line" id="L11"><span class="tok-comment">//! information entirely from others (some never mention the UART). If your TRM</span></span>
<span class="line" id="L12"><span class="tok-comment">//! does not have a UART section, i recommend finding another revision or</span></span>
<span class="line" id="L13"><span class="tok-comment">//! 'part x' sub revision of the TRM.`</span></span>
<span class="line" id="L14"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> UART0_BASE = <span class="tok-number">0xFF180000</span>;</span>
<span class="line" id="L15"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> UART1_BASE = <span class="tok-number">0xFF190000</span>;</span>
<span class="line" id="L16"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> UART2_BASE = <span class="tok-number">0xFF1A0000</span>;</span>
<span class="line" id="L17"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> UART3_BASE = <span class="tok-number">0xFF1B0000</span>;</span>
<span class="line" id="L18"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> UART4_BASE = <span class="tok-number">0xFF270000</span>;</span>
<span class="line" id="L19"></span>
<span class="line" id="L20"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> RBR_OFFSET = <span class="tok-number">0x0000</span>;</span>
<span class="line" id="L21"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> THR_OFFSET = <span class="tok-number">0x0000</span>;</span>
<span class="line" id="L22"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> DLL_OFFSET = <span class="tok-number">0x0000</span>;</span>
<span class="line" id="L23"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> DLH_OFFSET = <span class="tok-number">0x0004</span>;</span>
<span class="line" id="L24"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> IER_OFFSET = <span class="tok-number">0x0004</span>;</span>
<span class="line" id="L25"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> IIR_OFFSET = <span class="tok-number">0x0008</span>;</span>
<span class="line" id="L26"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> FCR_OFFSET = <span class="tok-number">0x0008</span>;</span>
<span class="line" id="L27"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> LCR_OFFSET = <span class="tok-number">0x000C</span>;</span>
<span class="line" id="L28"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> MCR_OFFSET = <span class="tok-number">0x0010</span>;</span>
<span class="line" id="L29"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> LSR_OFFSET = <span class="tok-number">0x0014</span>;</span>
<span class="line" id="L30"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> MSR_OFFSET = <span class="tok-number">0x0018</span>;</span>
<span class="line" id="L31"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> SCR_OFFSET = <span class="tok-number">0x001C</span>;</span>
<span class="line" id="L32"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> SRBR_OFFSET = <span class="tok-number">0x0030</span>;</span>
<span class="line" id="L33"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> STHR_OFFSET = <span class="tok-number">0x006C</span>;</span>
<span class="line" id="L34"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> FAR_OFFSET = <span class="tok-number">0x0070</span>;</span>
<span class="line" id="L35"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> TFR_OFFSET = <span class="tok-number">0x0074</span>;</span>
<span class="line" id="L36"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> RFW_OFFSET = <span class="tok-number">0x078</span>;</span>
<span class="line" id="L37"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> USR_OFFSET = <span class="tok-number">0x007C</span>;</span>
<span class="line" id="L38"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> TFL_OFFSET = <span class="tok-number">0x0080</span>;</span>
<span class="line" id="L39"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> RFL_OFFSET = <span class="tok-number">0x0084</span>;</span>
<span class="line" id="L40"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> SRR_OFFSET = <span class="tok-number">0x0088</span>;</span>
<span class="line" id="L41"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> SRTS_OFFSET = <span class="tok-number">0x008C</span>;</span>
<span class="line" id="L42"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> SBCR_OFFSET = <span class="tok-number">0x0090</span>;</span>
<span class="line" id="L43"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> SDMAM_OFFSET = <span class="tok-number">0x0094</span>;</span>
<span class="line" id="L44"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> SFE_OFFSET = <span class="tok-number">0x0098</span>;</span>
<span class="line" id="L45"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> SRT_OFFSET = <span class="tok-number">0x009C</span>;</span>
<span class="line" id="L46"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> STET_OFFSET = <span class="tok-number">0x00A0</span>;</span>
<span class="line" id="L47"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> HTX_OFFSET = <span class="tok-number">0x00A4</span>;</span>
<span class="line" id="L48"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> DMASA_OFFSET = <span class="tok-number">0x00A8</span>;</span>
<span class="line" id="L49"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> CPR_OFFSET = <span class="tok-number">0x00F4</span>;</span>
<span class="line" id="L50"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> UCV_OFFSET = <span class="tok-number">0x00F8</span>;</span>
<span class="line" id="L51"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> CTR_OFFSET = <span class="tok-number">0x00FC</span>;</span>
<span class="line" id="L52"></span>
<span class="line" id="L53"><span class="tok-comment">/// Register bitfield struct for the UART RBR, short for Read Buffer</span></span>
<span class="line" id="L54"><span class="tok-comment">/// Register. Address: Operational Base + offset (0x0000)</span></span>
<span class="line" id="L55"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> uart_rbr = <span class="tok-kw">packed</span> <span class="tok-kw">struct</span>(<span class="tok-type">u32</span>) {</span>
<span class="line" id="L56">    <span class="tok-comment">// From TRM:</span>
</span>
<span class="line" id="L57">    <span class="tok-comment">// Data byte received on the serial input port (sin) in UART mode, or the</span>
</span>
<span class="line" id="L58">    <span class="tok-comment">// serial infrared input (sir_in) in infrared mode. The data in this</span>
</span>
<span class="line" id="L59">    <span class="tok-comment">// register is valid only if the Data Ready (DR) bit in the Line Status</span>
</span>
<span class="line" id="L60">    <span class="tok-comment">// Register (LCR) is set.</span>
</span>
<span class="line" id="L61">    <span class="tok-comment">//</span>
</span>
<span class="line" id="L62">    <span class="tok-comment">// If in non-FIFO mode (FIFO_MODE == NONE) or FIFOs are disabled (FCR[0]</span>
</span>
<span class="line" id="L63">    <span class="tok-comment">// set to zero), the data in the RBR must be read before the next data</span>
</span>
<span class="line" id="L64">    <span class="tok-comment">// arrives, otherwise it is overwritten, resulting in an over-run error.</span>
</span>
<span class="line" id="L65">    <span class="tok-comment">//</span>
</span>
<span class="line" id="L66">    <span class="tok-comment">// If in FIFO mode (FIFO_MODE != NONE) and FIFOs are enabled (FCR[0] set</span>
</span>
<span class="line" id="L67">    <span class="tok-comment">// to one), this register accesses the head of the receive FIFO. If the</span>
</span>
<span class="line" id="L68">    <span class="tok-comment">// receive FIFO is full and this register is not read before the next data</span>
</span>
<span class="line" id="L69">    <span class="tok-comment">// character arrives, then the data already in the FIFO is preserved, but</span>
</span>
<span class="line" id="L70">    <span class="tok-comment">// any incoming data are lost and an over-run error occurs.</span>
</span>
<span class="line" id="L71">    <span class="tok-comment">//</span>
</span>
<span class="line" id="L72">    <span class="tok-comment">// Attr: RW (read/write)</span>
</span>
<span class="line" id="L73">    data_input: <span class="tok-type">u8</span>,</span>
<span class="line" id="L74">    <span class="tok-comment">// Attr: RO (read only)</span>
</span>
<span class="line" id="L75">    _reserved: <span class="tok-type">u24</span>,</span>
<span class="line" id="L76">};</span>
<span class="line" id="L77"></span>
<span class="line" id="L78"><span class="tok-comment">/// UART THR, short for Transmit Holding Register</span></span>
<span class="line" id="L79"><span class="tok-comment">/// Address: Operational Base + offset (0x0000)</span></span>
<span class="line" id="L80"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> uart_thr = <span class="tok-kw">packed</span> <span class="tok-kw">struct</span>(<span class="tok-type">u32</span>) {</span>
<span class="line" id="L81">    <span class="tok-comment">// From the TRM:</span>
</span>
<span class="line" id="L82">    <span class="tok-comment">//</span>
</span>
<span class="line" id="L83">    <span class="tok-comment">// Data to be transmitted on the serial output port (sout) in UART mode</span>
</span>
<span class="line" id="L84">    <span class="tok-comment">// or the serial infrared output (sir_out_n) in infrared mode. Data should</span>
</span>
<span class="line" id="L85">    <span class="tok-comment">// only be written to the THR when the THR Empty (THRE) bit (LSR[5]) is</span>
</span>
<span class="line" id="L86">    <span class="tok-comment">// set.</span>
</span>
<span class="line" id="L87">    <span class="tok-comment">//</span>
</span>
<span class="line" id="L88">    <span class="tok-comment">// If in non-FIFO mode or FIFOs are disabled (FCR[0] = 0) and THRE is set,</span>
</span>
<span class="line" id="L89">    <span class="tok-comment">// writing a single character to the THR clears the THRE. Any additional</span>
</span>
<span class="line" id="L90">    <span class="tok-comment">// writes to the THR before the THRE is set again causes the THR data to</span>
</span>
<span class="line" id="L91">    <span class="tok-comment">// be overwritten.</span>
</span>
<span class="line" id="L92">    <span class="tok-comment">//</span>
</span>
<span class="line" id="L93">    <span class="tok-comment">// If in FIFO mode and FIFOs are enabled (FCR[0] = 1) and THRE is set, x</span>
</span>
<span class="line" id="L94">    <span class="tok-comment">// number of characters of data may be written to the THR before the FIFO</span>
</span>
<span class="line" id="L95">    <span class="tok-comment">// is full. The number x (default=16) is determined by the value of FIFO</span>
</span>
<span class="line" id="L96">    <span class="tok-comment">// Depth that you set during configuration. Any attempt to write data when</span>
</span>
<span class="line" id="L97">    <span class="tok-comment">// the FIFO is full results in the write data being lost.</span>
</span>
<span class="line" id="L98">    <span class="tok-comment">//</span>
</span>
<span class="line" id="L99">    <span class="tok-comment">// Attr: RW (Read/Write)</span>
</span>
<span class="line" id="L100">    data_output: <span class="tok-type">u8</span>,</span>
<span class="line" id="L101">    <span class="tok-comment">// Attr: RO (read only)</span>
</span>
<span class="line" id="L102">    _reserved: <span class="tok-type">u24</span> = <span class="tok-number">0</span>,</span>
<span class="line" id="L103">};</span>
<span class="line" id="L104"></span>
<span class="line" id="L105"><span class="tok-comment">/// UART DLL register, short for Divisor Latch (Low)</span></span>
<span class="line" id="L106"><span class="tok-comment">/// Address: Operational Base + offset (0x0000)</span></span>
<span class="line" id="L107"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> uart_dll = <span class="tok-kw">packed</span> <span class="tok-kw">struct</span>(<span class="tok-type">u32</span>) {</span>
<span class="line" id="L108">    <span class="tok-comment">// Lower 8-bits of a 16-bit, read/write, Divisor Latch register that</span>
</span>
<span class="line" id="L109">    <span class="tok-comment">// contains the baud rate divisor for the UART. This register may only be</span>
</span>
<span class="line" id="L110">    <span class="tok-comment">// accessed when the DLAB bit (LCR[7]) is set and the UART is not busy</span>
</span>
<span class="line" id="L111">    <span class="tok-comment">// (USR[0] is zero). The output baud rate is equal to the serial clock</span>
</span>
<span class="line" id="L112">    <span class="tok-comment">// (sclk) frequency divided by sixteen times the value of the baud rate</span>
</span>
<span class="line" id="L113">    <span class="tok-comment">// divisor, as follows: baud rate = (serial clock freq) / (16 * divisor).</span>
</span>
<span class="line" id="L114">    <span class="tok-comment">//</span>
</span>
<span class="line" id="L115">    <span class="tok-comment">// Note that with the Divisor Latch Registers (DLL and DLH) set to zero,</span>
</span>
<span class="line" id="L116">    <span class="tok-comment">// the baud clock is disabled and no serial communications occur. Also,</span>
</span>
<span class="line" id="L117">    <span class="tok-comment">// once the DLH is set, at least 8 clock cycles of the slowest UART clock</span>
</span>
<span class="line" id="L118">    <span class="tok-comment">// should be allowed to pass before transmitting or receiving data.</span>
</span>
<span class="line" id="L119">    <span class="tok-comment">//</span>
</span>
<span class="line" id="L120">    <span class="tok-comment">// Attr: RW (Read/Write)</span>
</span>
<span class="line" id="L121">    baud_rate_divisor_L: <span class="tok-type">u8</span>,</span>
<span class="line" id="L122">    <span class="tok-comment">// Attr: RO (read only)</span>
</span>
<span class="line" id="L123">    _reserved: <span class="tok-type">u24</span>,</span>
<span class="line" id="L124">};</span>
<span class="line" id="L125"></span>
<span class="line" id="L126"><span class="tok-comment">/// UART DLH register, short for Divisor Latch (High)</span></span>
<span class="line" id="L127"><span class="tok-comment">/// Address: Operational Base + offset (0x0004)</span></span>
<span class="line" id="L128"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> uart_dlh = <span class="tok-kw">packed</span> <span class="tok-kw">struct</span>(<span class="tok-type">u32</span>) {</span>
<span class="line" id="L129">    <span class="tok-comment">// Upper 8 bits of a 16-bit, read/write, Divisor Latch register that</span>
</span>
<span class="line" id="L130">    <span class="tok-comment">// contains the baud rate divisor for the UART.</span>
</span>
<span class="line" id="L131">    <span class="tok-comment">//</span>
</span>
<span class="line" id="L132">    <span class="tok-comment">// Attr: RW</span>
</span>
<span class="line" id="L133">    baud_rate_divisor_H: <span class="tok-type">u8</span>,</span>
<span class="line" id="L134">    <span class="tok-comment">// Attr: RO (read only)</span>
</span>
<span class="line" id="L135">    _reserved: <span class="tok-type">u24</span>,</span>
<span class="line" id="L136">};</span>
<span class="line" id="L137"></span>
<span class="line" id="L138"><span class="tok-comment">/// UART IER, short for Interrupt Enable Register</span></span>
<span class="line" id="L139"><span class="tok-comment">/// Address: Operational Base + offset (0x0004)</span></span>
<span class="line" id="L140"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> uart_ier = <span class="tok-kw">packed</span> <span class="tok-kw">struct</span>(<span class="tok-type">u32</span>) {</span>
<span class="line" id="L141">    <span class="tok-comment">/// Enable Received Data Available Interrupt.</span></span>
<span class="line" id="L142">    <span class="tok-comment">/// This is used to enable/disable the generation of Received Data</span></span>
<span class="line" id="L143">    <span class="tok-comment">/// Available Interrupt and the Character Timeout Interrupt (if in FIFO</span></span>
<span class="line" id="L144">    <span class="tok-comment">/// mode and FIFOs enabled). These are the second highest priority</span></span>
<span class="line" id="L145">    <span class="tok-comment">/// interrupts.</span></span>
<span class="line" id="L146">    <span class="tok-comment">///</span></span>
<span class="line" id="L147">    <span class="tok-comment">/// Attr: RW</span></span>
<span class="line" id="L148">    recv_data_aval_int_en: <span class="tok-type">bool</span>,</span>
<span class="line" id="L149">    <span class="tok-comment">/// Enable Transmit Holding Register Empty Interrupt.</span></span>
<span class="line" id="L150">    <span class="tok-comment">///</span></span>
<span class="line" id="L151">    <span class="tok-comment">/// Attr: RW</span></span>
<span class="line" id="L152">    trans_hold_empty_int_en: <span class="tok-type">bool</span>,</span>
<span class="line" id="L153">    <span class="tok-comment">/// Enable Receiver Line Status Interrupt.</span></span>
<span class="line" id="L154">    <span class="tok-comment">/// This is used to enable/disable the generation of Receiver Line Status</span></span>
<span class="line" id="L155">    <span class="tok-comment">/// Interrupt. This is the highest priority interrupt.</span></span>
<span class="line" id="L156">    <span class="tok-comment">///</span></span>
<span class="line" id="L157">    <span class="tok-comment">/// Attr: RW</span></span>
<span class="line" id="L158">    recv_line_status_int_en: <span class="tok-type">bool</span>,</span>
<span class="line" id="L159">    <span class="tok-comment">/// Enable Modem Status Interrupt.</span></span>
<span class="line" id="L160">    <span class="tok-comment">/// This is used to enable/disable the generation of Modem Status Interrupt.</span></span>
<span class="line" id="L161">    <span class="tok-comment">/// This is the fourth highest priority interrupt</span></span>
<span class="line" id="L162">    <span class="tok-comment">///</span></span>
<span class="line" id="L163">    <span class="tok-comment">/// Attr: RW</span></span>
<span class="line" id="L164">    modem_status_int_en: <span class="tok-type">bool</span>,</span>
<span class="line" id="L165">    <span class="tok-comment">/// Should be 0, bits 4:6</span></span>
<span class="line" id="L166">    <span class="tok-comment">/// Attr: RO</span></span>
<span class="line" id="L167">    _reserved4_6: <span class="tok-type">u3</span>,</span>
<span class="line" id="L168">    <span class="tok-comment">/// Programmable THRE Interrupt Mode Enable</span></span>
<span class="line" id="L169">    <span class="tok-comment">/// This is used to enable/disable the generation of THRE Interrupt.</span></span>
<span class="line" id="L170">    <span class="tok-comment">///</span></span>
<span class="line" id="L171">    <span class="tok-comment">/// Attr: RW</span></span>
<span class="line" id="L172">    prog_thre_int_en: <span class="tok-type">bool</span>,</span>
<span class="line" id="L173">    <span class="tok-comment">/// Should be 0, bits 8:31</span></span>
<span class="line" id="L174">    <span class="tok-comment">/// Attr: RO</span></span>
<span class="line" id="L175">    _reserved8_31: <span class="tok-type">u24</span>,</span>
<span class="line" id="L176">};</span>
<span class="line" id="L177"></span>
<span class="line" id="L178"><span class="tok-comment">/// UART IIR, short for Interrupt Identification Register</span></span>
<span class="line" id="L179"><span class="tok-comment">/// Address: Operational Base + offset (0x0008)</span></span>
<span class="line" id="L180"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> uart_iir = <span class="tok-kw">packed</span> <span class="tok-kw">struct</span>(<span class="tok-type">u32</span>) {</span>
<span class="line" id="L181">    <span class="tok-comment">/// Interrupt ID</span></span>
<span class="line" id="L182">    <span class="tok-comment">///</span></span>
<span class="line" id="L183">    <span class="tok-comment">/// This indicates the highest priority pending interrupt which can be one</span></span>
<span class="line" id="L184">    <span class="tok-comment">/// of the following types:</span></span>
<span class="line" id="L185">    <span class="tok-comment">/// 0000 = modem status</span></span>
<span class="line" id="L186">    <span class="tok-comment">/// 0001 = no interrupt pending</span></span>
<span class="line" id="L187">    <span class="tok-comment">/// 0010 = THR empty</span></span>
<span class="line" id="L188">    <span class="tok-comment">/// 0100 = received data available</span></span>
<span class="line" id="L189">    <span class="tok-comment">/// 0110 = receiver line status</span></span>
<span class="line" id="L190">    <span class="tok-comment">/// 0111 = busy detect</span></span>
<span class="line" id="L191">    <span class="tok-comment">/// 1100 = character timeout</span></span>
<span class="line" id="L192">    <span class="tok-comment">///</span></span>
<span class="line" id="L193">    <span class="tok-comment">/// Attr: RO</span></span>
<span class="line" id="L194">    int_id: <span class="tok-type">u4</span>,</span>
<span class="line" id="L195">    <span class="tok-comment">/// Should be 0, bits 4:5</span></span>
<span class="line" id="L196">    <span class="tok-comment">/// Attr: RO</span></span>
<span class="line" id="L197">    _reserved4_5: <span class="tok-type">u2</span>,</span>
<span class="line" id="L198">    <span class="tok-comment">/// FIFOs Enabled.</span></span>
<span class="line" id="L199">    <span class="tok-comment">///</span></span>
<span class="line" id="L200">    <span class="tok-comment">/// This is used to indicate whether the FIFOs are enabled or disabled.</span></span>
<span class="line" id="L201">    <span class="tok-comment">/// 00 = disabled</span></span>
<span class="line" id="L202">    <span class="tok-comment">/// 11 = Enabled</span></span>
<span class="line" id="L203">    <span class="tok-comment">/// Attr: RO</span></span>
<span class="line" id="L204">    fifos_en: <span class="tok-type">u2</span>,</span>
<span class="line" id="L205">    <span class="tok-comment">/// Should be 0, bits 8:31,</span></span>
<span class="line" id="L206">    <span class="tok-comment">/// Attr: RO</span></span>
<span class="line" id="L207">    _reserved8_31: <span class="tok-type">u24</span>,</span>
<span class="line" id="L208">};</span>
<span class="line" id="L209"></span>
<span class="line" id="L210"><span class="tok-comment">/// UART FCR, short for FIFO Control Register</span></span>
<span class="line" id="L211"><span class="tok-comment">/// Address: Operational Base + offset (0x0008)</span></span>
<span class="line" id="L212"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> uart_fcr = <span class="tok-kw">packed</span> <span class="tok-kw">struct</span>(<span class="tok-type">u32</span>) {</span>
<span class="line" id="L213">    <span class="tok-comment">/// FIFO Enable.</span></span>
<span class="line" id="L214">    <span class="tok-comment">/// FIFO Enable. This enables/disables the transmit (XMIT) and receive</span></span>
<span class="line" id="L215">    <span class="tok-comment">/// (RCVR) FIFOs. Whenever the value of this bit is changed both the XMIT</span></span>
<span class="line" id="L216">    <span class="tok-comment">/// and RCVR controller portion of FIFOs is reset.</span></span>
<span class="line" id="L217">    <span class="tok-comment">///</span></span>
<span class="line" id="L218">    <span class="tok-comment">/// Attr: WO (Write Only)</span></span>
<span class="line" id="L219">    fifo_en: <span class="tok-type">bool</span>,</span>
<span class="line" id="L220">    <span class="tok-comment">/// RCVR FIFO Reset.</span></span>
<span class="line" id="L221">    <span class="tok-comment">///</span></span>
<span class="line" id="L222">    <span class="tok-comment">/// This resets the control portion of the receive FIFO and treats the</span></span>
<span class="line" id="L223">    <span class="tok-comment">/// FIFO as empty. This also de-asserts the DMA RX request and single</span></span>
<span class="line" id="L224">    <span class="tok-comment">/// signals when additional DMA handshaking signals are selected. Note</span></span>
<span class="line" id="L225">    <span class="tok-comment">/// that this bit is 'self-clearing'. It is not necessary to clear this bit</span></span>
<span class="line" id="L226">    rcvr_fifo_reset: <span class="tok-type">bool</span>,</span>
<span class="line" id="L227">    <span class="tok-comment">/// XMIT FIFO Reset.</span></span>
<span class="line" id="L228">    <span class="tok-comment">///</span></span>
<span class="line" id="L229">    <span class="tok-comment">/// This resets the control portion of the transmit FIFO and treats the</span></span>
<span class="line" id="L230">    <span class="tok-comment">/// FIFO as empty. This also de-asserts the DMA TX request and single</span></span>
<span class="line" id="L231">    <span class="tok-comment">/// signals when additional DMA handshaking signals are selected . Note</span></span>
<span class="line" id="L232">    <span class="tok-comment">/// that this bit is 'self-clearing'. It is not necessary to clear this bit</span></span>
<span class="line" id="L233">    xmit_fifo_reset: <span class="tok-type">bool</span>,</span>
<span class="line" id="L234">    <span class="tok-comment">/// DMA Mode</span></span>
<span class="line" id="L235">    <span class="tok-comment">///</span></span>
<span class="line" id="L236">    <span class="tok-comment">/// This determines the DMA signalling mode used for the dma_tx_req_n and</span></span>
<span class="line" id="L237">    <span class="tok-comment">/// dma_rx_req_n output signals when additional DMA handshaking signals</span></span>
<span class="line" id="L238">    <span class="tok-comment">/// are not selected .</span></span>
<span class="line" id="L239">    <span class="tok-comment">/// 0 = mode 0</span></span>
<span class="line" id="L240">    <span class="tok-comment">/// 1 = mode 11100 = character timeout.</span></span>
<span class="line" id="L241">    <span class="tok-comment">///</span></span>
<span class="line" id="L242">    <span class="tok-comment">/// Attr: WO</span></span>
<span class="line" id="L243">    dma_mode: <span class="tok-type">bool</span>,</span>
<span class="line" id="L244">    <span class="tok-comment">/// TX Empty Trigger.</span></span>
<span class="line" id="L245">    <span class="tok-comment">///</span></span>
<span class="line" id="L246">    <span class="tok-comment">/// This is used to select the empty threshold level at which the THRE</span></span>
<span class="line" id="L247">    <span class="tok-comment">/// Interrupts are generated when the mode is active. It also determines</span></span>
<span class="line" id="L248">    <span class="tok-comment">/// when the dma_tx_req_n signal is asserted when in certain modes of</span></span>
<span class="line" id="L249">    <span class="tok-comment">/// operation. The following trigger levels are supported:</span></span>
<span class="line" id="L250">    <span class="tok-comment">/// 00 = FIFO empty</span></span>
<span class="line" id="L251">    <span class="tok-comment">/// 01 = 2 characters in the FIFO</span></span>
<span class="line" id="L252">    <span class="tok-comment">/// 10 = FIFO 1/4 full</span></span>
<span class="line" id="L253">    <span class="tok-comment">/// 11 = FIFO 1/2 full</span></span>
<span class="line" id="L254">    <span class="tok-comment">///</span></span>
<span class="line" id="L255">    <span class="tok-comment">/// Attr: WO</span></span>
<span class="line" id="L256">    tx_empty_trigger: <span class="tok-type">u2</span>,</span>
<span class="line" id="L257">    <span class="tok-comment">/// RCVR Trigger</span></span>
<span class="line" id="L258">    <span class="tok-comment">///</span></span>
<span class="line" id="L259">    <span class="tok-comment">/// This is used to select the trigger level in the receiver FIFO at which</span></span>
<span class="line" id="L260">    <span class="tok-comment">/// the Received Data Available Interrupt is generated. In auto flow</span></span>
<span class="line" id="L261">    <span class="tok-comment">/// control mode it is used to determine when the rts_n signal is</span></span>
<span class="line" id="L262">    <span class="tok-comment">/// de-asserted. It also determines when the dma_rx_req_n signal is</span></span>
<span class="line" id="L263">    <span class="tok-comment">/// asserted in certain modes of operation. The following trigger levels</span></span>
<span class="line" id="L264">    <span class="tok-comment">/// are supported:</span></span>
<span class="line" id="L265">    <span class="tok-comment">///</span></span>
<span class="line" id="L266">    <span class="tok-comment">/// 00 = 1 character in the FIFO</span></span>
<span class="line" id="L267">    <span class="tok-comment">/// 01 = FIFO 1/4 full</span></span>
<span class="line" id="L268">    <span class="tok-comment">/// 10 = FIFO 1/2 full</span></span>
<span class="line" id="L269">    <span class="tok-comment">/// 11 = FIFO 2 less than ful (-&gt; is this an errata?)</span></span>
<span class="line" id="L270">    <span class="tok-comment">///</span></span>
<span class="line" id="L271">    <span class="tok-comment">/// Attr: WO</span></span>
<span class="line" id="L272">    rcvr_trigger: <span class="tok-type">u2</span>,</span>
<span class="line" id="L273">    <span class="tok-comment">/// Should be 0, bits 8:31</span></span>
<span class="line" id="L274">    <span class="tok-comment">/// Attr: RO</span></span>
<span class="line" id="L275">    _reserved8_31: <span class="tok-type">u24</span>,</span>
<span class="line" id="L276">};</span>
<span class="line" id="L277"></span>
<span class="line" id="L278"><span class="tok-comment">/// UART LCR, short for Line Control Register</span></span>
<span class="line" id="L279"><span class="tok-comment">/// Address: Operational Base + offset (0x000C)</span></span>
<span class="line" id="L280"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> uart_lcr = <span class="tok-kw">packed</span> <span class="tok-kw">struct</span>(<span class="tok-type">u32</span>) {</span>
<span class="line" id="L281">    <span class="tok-comment">/// Data Length Select.</span></span>
<span class="line" id="L282">    <span class="tok-comment">/// Writeable only when UART is not busy (USR[0] is zero), always readable.</span></span>
<span class="line" id="L283">    <span class="tok-comment">/// This is used to select the number of data bits per character that the</span></span>
<span class="line" id="L284">    <span class="tok-comment">/// peripheral transmits and receives. The number of bit that may be</span></span>
<span class="line" id="L285">    <span class="tok-comment">/// selected areas follows:</span></span>
<span class="line" id="L286">    <span class="tok-comment">/// 00 = 5 bits</span></span>
<span class="line" id="L287">    <span class="tok-comment">/// 01 = 6 bits</span></span>
<span class="line" id="L288">    <span class="tok-comment">/// 10 = 7 bits</span></span>
<span class="line" id="L289">    <span class="tok-comment">/// 11 = 8 bits</span></span>
<span class="line" id="L290">    <span class="tok-comment">///</span></span>
<span class="line" id="L291">    <span class="tok-comment">/// Attr: RW</span></span>
<span class="line" id="L292">    data_len_sel: <span class="tok-type">u2</span>,</span>
<span class="line" id="L293">    <span class="tok-comment">/// Number of stop bits.</span></span>
<span class="line" id="L294">    <span class="tok-comment">/// Writeable only when UART is not busy (USR[0] is zero), always readable.</span></span>
<span class="line" id="L295">    <span class="tok-comment">/// This is used to select the number of stop bits per character that the</span></span>
<span class="line" id="L296">    <span class="tok-comment">/// peripheral transmits and receives. If set to zero, one stop bit is</span></span>
<span class="line" id="L297">    <span class="tok-comment">/// transmitted in the serial data. If set to one and the data bits are</span></span>
<span class="line" id="L298">    <span class="tok-comment">/// set to 5 (LCR[1:0] set to zero) one and a half stop bits is transmitted</span></span>
<span class="line" id="L299">    <span class="tok-comment">/// Otherwise, two stop bits are transmitted. Note that regardless of the</span></span>
<span class="line" id="L300">    <span class="tok-comment">/// number of stop bits selected, the receiver checks only the first stop</span></span>
<span class="line" id="L301">    <span class="tok-comment">/// bit.</span></span>
<span class="line" id="L302">    <span class="tok-comment">/// 0 = 1 stop bit</span></span>
<span class="line" id="L303">    <span class="tok-comment">/// 1 = 1.5 stop bits when DLS (LCR[1:0]) is zero, else 2 stop bit.</span></span>
<span class="line" id="L304">    <span class="tok-comment">///</span></span>
<span class="line" id="L305">    <span class="tok-comment">/// Attr: RW</span></span>
<span class="line" id="L306">    stop_bits_num: <span class="tok-type">bool</span>,</span>
<span class="line" id="L307">    <span class="tok-comment">/// Parity Enable.</span></span>
<span class="line" id="L308">    <span class="tok-comment">/// Writeable only when UART is not busy (USR[0] is zero), always readable.</span></span>
<span class="line" id="L309">    <span class="tok-comment">/// This bit is used to enable and disable parity generation and detection</span></span>
<span class="line" id="L310">    <span class="tok-comment">/// in transmitted and received serial character respectively.</span></span>
<span class="line" id="L311">    <span class="tok-comment">/// 0 = parity disabled</span></span>
<span class="line" id="L312">    <span class="tok-comment">/// 1 = parity enabled</span></span>
<span class="line" id="L313">    <span class="tok-comment">///</span></span>
<span class="line" id="L314">    <span class="tok-comment">/// Attr: RW</span></span>
<span class="line" id="L315">    parity_en: <span class="tok-type">bool</span>,</span>
<span class="line" id="L316">    <span class="tok-comment">/// Even Parity Select.</span></span>
<span class="line" id="L317">    <span class="tok-comment">///</span></span>
<span class="line" id="L318">    <span class="tok-comment">/// Writeable only when UART is not busy (USR[0] is zero), always readable.</span></span>
<span class="line" id="L319">    <span class="tok-comment">/// This is used to select between even and odd parity, when parity is</span></span>
<span class="line" id="L320">    <span class="tok-comment">/// enabled (PEN set to one). If set to one, an even number of logic 1s</span></span>
<span class="line" id="L321">    <span class="tok-comment">/// is transmitted or checked. If set to zero, an odd number of logic 1s</span></span>
<span class="line" id="L322">    <span class="tok-comment">/// is transmitted or checked.</span></span>
<span class="line" id="L323">    <span class="tok-comment">///</span></span>
<span class="line" id="L324">    <span class="tok-comment">/// Attr: RW</span></span>
<span class="line" id="L325">    even_parity_sel: <span class="tok-type">bool</span>,</span>
<span class="line" id="L326">    <span class="tok-comment">/// SBZ, Bit 5</span></span>
<span class="line" id="L327">    _reserved: <span class="tok-type">bool</span> = <span class="tok-null">false</span>,</span>
<span class="line" id="L328">    <span class="tok-comment">/// Break Control bit</span></span>
<span class="line" id="L329">    <span class="tok-comment">///</span></span>
<span class="line" id="L330">    <span class="tok-comment">/// This is used to cause a break condition to be transmitted to the</span></span>
<span class="line" id="L331">    <span class="tok-comment">/// receiving device. If set to one the serial output is forced to the</span></span>
<span class="line" id="L332">    <span class="tok-comment">/// spacing (logic 0) state. When not in Loopback Mode, as determined by</span></span>
<span class="line" id="L333">    <span class="tok-comment">/// MCR[4], the sout line is forced low until the Break bit is cleared.</span></span>
<span class="line" id="L334">    <span class="tok-comment">/// If MCR[6] set to one, the sir_out_n line is continuously pulsed. When</span></span>
<span class="line" id="L335">    <span class="tok-comment">/// in Loopback Mode, the break condition is internally looped back to</span></span>
<span class="line" id="L336">    <span class="tok-comment">/// the receiver and the sir_out_n line is forced low.</span></span>
<span class="line" id="L337">    <span class="tok-comment">///</span></span>
<span class="line" id="L338">    <span class="tok-comment">/// Attr: RW</span></span>
<span class="line" id="L339">    break_ctrl: <span class="tok-type">bool</span>,</span>
<span class="line" id="L340">    <span class="tok-comment">/// Divisor Latch Access Bit.</span></span>
<span class="line" id="L341">    <span class="tok-comment">////</span>
</span>
<span class="line" id="L342">    <span class="tok-comment">/// Writeable only when UART is not busy (USR[0] is zero), always readable.</span></span>
<span class="line" id="L343">    <span class="tok-comment">/// This bit is used to enable reading and writing of the Divisor Latch</span></span>
<span class="line" id="L344">    <span class="tok-comment">/// register (DLL and DLH) to set the baud rate of the UART. This bit must</span></span>
<span class="line" id="L345">    <span class="tok-comment">/// be cleared after initial baud rate setup in order to access other</span></span>
<span class="line" id="L346">    <span class="tok-comment">/// registers.</span></span>
<span class="line" id="L347">    <span class="tok-comment">///</span></span>
<span class="line" id="L348">    <span class="tok-comment">/// Attr: RW</span></span>
<span class="line" id="L349">    div_lat_access: <span class="tok-type">bool</span>,</span>
<span class="line" id="L350">    <span class="tok-comment">/// SBZ, bits 8:31</span></span>
<span class="line" id="L351">    <span class="tok-comment">/// Attr: RO</span></span>
<span class="line" id="L352">    _reserved8_31: <span class="tok-type">u24</span> = <span class="tok-number">0</span>,</span>
<span class="line" id="L353">};</span>
<span class="line" id="L354"></span>
<span class="line" id="L355"><span class="tok-comment">/// UART MCR, short for Modem Control Register</span></span>
<span class="line" id="L356"><span class="tok-comment">/// Address: Operational Base + offset (0x0010)</span></span>
<span class="line" id="L357"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> uart_mcr = <span class="tok-kw">packed</span> <span class="tok-kw">struct</span>(<span class="tok-type">u32</span>) {</span>
<span class="line" id="L358">    <span class="tok-comment">/// Data Terminal Ready.</span></span>
<span class="line" id="L359">    <span class="tok-comment">///</span></span>
<span class="line" id="L360">    <span class="tok-comment">/// This is used to directly control the Data Terminal Ready (dtr_n) output.</span></span>
<span class="line" id="L361">    <span class="tok-comment">/// The value written to this location is inverted and driven out on</span></span>
<span class="line" id="L362">    <span class="tok-comment">/// dtr_n, that is:</span></span>
<span class="line" id="L363">    <span class="tok-comment">/// 0 = dtr_n de-asserted (logic 1)</span></span>
<span class="line" id="L364">    <span class="tok-comment">/// 1 = dtr_n asserted (logic 0)</span></span>
<span class="line" id="L365">    <span class="tok-comment">///</span></span>
<span class="line" id="L366">    <span class="tok-comment">/// Attr: RW</span></span>
<span class="line" id="L367">    data_term_ready: <span class="tok-type">bool</span>,</span>
<span class="line" id="L368">    <span class="tok-comment">/// Request to Send.</span></span>
<span class="line" id="L369">    <span class="tok-comment">///</span></span>
<span class="line" id="L370">    <span class="tok-comment">/// This is used to directly control the Request to Send (rts_n) output.</span></span>
<span class="line" id="L371">    <span class="tok-comment">/// The Request To Send (rts_n) output is used to inform the modem or data</span></span>
<span class="line" id="L372">    <span class="tok-comment">/// set that the UART is ready to exchange data.</span></span>
<span class="line" id="L373">    <span class="tok-comment">///</span></span>
<span class="line" id="L374">    <span class="tok-comment">/// Attr: RW</span></span>
<span class="line" id="L375">    req_to_send: <span class="tok-type">bool</span>,</span>
<span class="line" id="L376">    <span class="tok-comment">/// OUT1</span></span>
<span class="line" id="L377">    <span class="tok-comment">///</span></span>
<span class="line" id="L378">    <span class="tok-comment">/// This is used to directly control the user-designated Output1 (out1_n)</span></span>
<span class="line" id="L379">    <span class="tok-comment">/// output. The value written to this location is inverted and driven out</span></span>
<span class="line" id="L380">    <span class="tok-comment">/// on out1_n, that is:</span></span>
<span class="line" id="L381">    <span class="tok-comment">/// 1’b0: out1_n de-asserted (logic 1)</span></span>
<span class="line" id="L382">    <span class="tok-comment">/// 1’b1: out1_n asserted (logic 0)</span></span>
<span class="line" id="L383">    <span class="tok-comment">///</span></span>
<span class="line" id="L384">    <span class="tok-comment">/// Attr: RW</span></span>
<span class="line" id="L385">    out1: <span class="tok-type">bool</span>,</span>
<span class="line" id="L386">    <span class="tok-comment">/// OUT2, same as above but with 2 :)</span></span>
<span class="line" id="L387">    out2: <span class="tok-type">bool</span>,</span>
<span class="line" id="L388">    <span class="tok-comment">/// Loopback Bit</span></span>
<span class="line" id="L389">    <span class="tok-comment">///</span></span>
<span class="line" id="L390">    <span class="tok-comment">/// This is used to put the UART into a diagnostic mode for test purposes.</span></span>
<span class="line" id="L391">    <span class="tok-comment">///</span></span>
<span class="line" id="L392">    <span class="tok-comment">/// Attr: RW</span></span>
<span class="line" id="L393">    loopback: <span class="tok-type">bool</span>,</span>
<span class="line" id="L394">    <span class="tok-comment">/// Auto Flow Control Enable</span></span>
<span class="line" id="L395">    <span class="tok-comment">///</span></span>
<span class="line" id="L396">    <span class="tok-comment">/// Auto Flow Control Enable.</span></span>
<span class="line" id="L397">    <span class="tok-comment">/// 0 = Auto Flow Control Mode disabled</span></span>
<span class="line" id="L398">    <span class="tok-comment">/// 1 = Auto Flow Control Mode enabled</span></span>
<span class="line" id="L399">    <span class="tok-comment">///</span></span>
<span class="line" id="L400">    <span class="tok-comment">/// Attr: RW</span></span>
<span class="line" id="L401">    auto_flow_ctrl_en: <span class="tok-type">bool</span>,</span>
<span class="line" id="L402">    <span class="tok-comment">/// SIR Mode Enable</span></span>
<span class="line" id="L403">    <span class="tok-comment">///</span></span>
<span class="line" id="L404">    <span class="tok-comment">/// This is used to enable/disable the IrDA SIR Mode.</span></span>
<span class="line" id="L405">    <span class="tok-comment">/// 0 = irda sir mode disabled</span></span>
<span class="line" id="L406">    <span class="tok-comment">/// 1 = IrDA SIR Mode Enabled</span></span>
<span class="line" id="L407">    <span class="tok-comment">///</span></span>
<span class="line" id="L408">    <span class="tok-comment">/// Attr: RW</span></span>
<span class="line" id="L409">    sir_mode_en: <span class="tok-type">bool</span>,</span>
<span class="line" id="L410">    <span class="tok-comment">/// SBZ, bits 7:31</span></span>
<span class="line" id="L411">    _reserved7_31: <span class="tok-type">u25</span>,</span>
<span class="line" id="L412">};</span>
<span class="line" id="L413"></span>
<span class="line" id="L414"><span class="tok-comment">/// UART LSR, short for Line Status Register</span></span>
<span class="line" id="L415"><span class="tok-comment">/// Address: Operational Base + offset (0x0014)</span></span>
<span class="line" id="L416"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> uart_lsr = <span class="tok-kw">packed</span> <span class="tok-kw">struct</span>(<span class="tok-type">u32</span>) {</span>
<span class="line" id="L417">    <span class="tok-comment">/// Data Ready bit.</span></span>
<span class="line" id="L418">    <span class="tok-comment">///</span></span>
<span class="line" id="L419">    <span class="tok-comment">/// This is used to indicate that the receiver contains at least one</span></span>
<span class="line" id="L420">    <span class="tok-comment">/// character in the RBR or the receiver FIFO.</span></span>
<span class="line" id="L421">    <span class="tok-comment">/// 0 = no data ready</span></span>
<span class="line" id="L422">    <span class="tok-comment">/// 1 = data ready</span></span>
<span class="line" id="L423">    <span class="tok-comment">///</span></span>
<span class="line" id="L424">    <span class="tok-comment">/// Attr: RO</span></span>
<span class="line" id="L425">    data_ready: <span class="tok-type">bool</span>,</span>
<span class="line" id="L426">    <span class="tok-comment">/// Overrun error bit.</span></span>
<span class="line" id="L427">    <span class="tok-comment">/// This is used to indicate the occurrence of an overrun error.</span></span>
<span class="line" id="L428">    <span class="tok-comment">/// This occurs if a new data character was received before the previous</span></span>
<span class="line" id="L429">    <span class="tok-comment">/// data was read.</span></span>
<span class="line" id="L430">    <span class="tok-comment">///</span></span>
<span class="line" id="L431">    <span class="tok-comment">/// Attr: RO</span></span>
<span class="line" id="L432">    overrun_error: <span class="tok-type">bool</span>,</span>
<span class="line" id="L433">    <span class="tok-comment">/// Parity Error Bit</span></span>
<span class="line" id="L434">    <span class="tok-comment">///</span></span>
<span class="line" id="L435">    <span class="tok-comment">/// This is used to indicate the occurrence of a parity error in the</span></span>
<span class="line" id="L436">    <span class="tok-comment">/// receiver if the Parity Enable (PEN) bit (LCR[3]) is set.</span></span>
<span class="line" id="L437">    <span class="tok-comment">///</span></span>
<span class="line" id="L438">    <span class="tok-comment">/// Attr: RO</span></span>
<span class="line" id="L439">    parity_error: <span class="tok-type">bool</span>,</span>
<span class="line" id="L440">    <span class="tok-comment">/// Framing Error Bit</span></span>
<span class="line" id="L441">    <span class="tok-comment">///</span></span>
<span class="line" id="L442">    <span class="tok-comment">/// This is used to indicate the occurrence of a framing error in the</span></span>
<span class="line" id="L443">    <span class="tok-comment">/// receiver. A framing error occurs when the receiver does not detect a</span></span>
<span class="line" id="L444">    <span class="tok-comment">/// valid STOP bit in the received data.</span></span>
<span class="line" id="L445">    <span class="tok-comment">///</span></span>
<span class="line" id="L446">    <span class="tok-comment">/// Attr: RO</span></span>
<span class="line" id="L447">    framing_error: <span class="tok-type">bool</span>,</span>
<span class="line" id="L448">    <span class="tok-comment">/// Transmit Holding Register Empty bit.</span></span>
<span class="line" id="L449">    <span class="tok-comment">/// If THRE mode is disabled (IER[7] set to zero) and regardless of FIFO's</span></span>
<span class="line" id="L450">    <span class="tok-comment">/// being implemented/enabled or not, this bit indicates that the THR or</span></span>
<span class="line" id="L451">    <span class="tok-comment">/// TX FIFO is empty.</span></span>
<span class="line" id="L452">    <span class="tok-comment">///</span></span>
<span class="line" id="L453">    <span class="tok-comment">/// This bit is set whenever data is transferred from the THR or TX FIFO to</span></span>
<span class="line" id="L454">    <span class="tok-comment">/// the transmitter shift register and no new data has been written to the</span></span>
<span class="line" id="L455">    <span class="tok-comment">/// THR or TX FIFO. This also causes a THRE Interrupt to occur, if the</span></span>
<span class="line" id="L456">    <span class="tok-comment">/// THRE Interrupt is enabled. If IER[7] set to one and FCR[0] set to one</span></span>
<span class="line" id="L457">    <span class="tok-comment">/// respectively, the functionality is switched to indicate the</span></span>
<span class="line" id="L458">    <span class="tok-comment">/// transmitter FIFO is full, and no longer controls THRE interrupts,</span></span>
<span class="line" id="L459">    <span class="tok-comment">/// which are then controlled by the FCR[5:4] threshold setting.</span></span>
<span class="line" id="L460">    <span class="tok-comment">///</span></span>
<span class="line" id="L461">    <span class="tok-comment">/// Attr: RO</span></span>
<span class="line" id="L462">    trans_hold_reg_empty: <span class="tok-type">bool</span>,</span>
<span class="line" id="L463">    <span class="tok-comment">/// Transmitter Empty bit</span></span>
<span class="line" id="L464">    <span class="tok-comment">///</span></span>
<span class="line" id="L465">    <span class="tok-comment">/// Transmitter Empty bit. If FIFOs enabled (FCR[0] set to one), this bit</span></span>
<span class="line" id="L466">    <span class="tok-comment">/// is set whenever the Transmitter Shift Register and the FIFO are both</span></span>
<span class="line" id="L467">    <span class="tok-comment">/// empty. If FIFOs are disabled, this bit is set whenever the Transmitter</span></span>
<span class="line" id="L468">    <span class="tok-comment">/// Holding Register and the Transmitter Shift Register are both empty.</span></span>
<span class="line" id="L469">    <span class="tok-comment">///</span></span>
<span class="line" id="L470">    <span class="tok-comment">/// Attr: RO</span></span>
<span class="line" id="L471">    trans_empty: <span class="tok-type">bool</span>,</span>
<span class="line" id="L472">    <span class="tok-comment">/// Receiver FIFO Error bit.</span></span>
<span class="line" id="L473">    <span class="tok-comment">///</span></span>
<span class="line" id="L474">    <span class="tok-comment">/// This bit is relevant FIFOs are enabled (FCR[0] set to one). This is</span></span>
<span class="line" id="L475">    <span class="tok-comment">/// used to indicate if there is at least one parity error, framing error,</span></span>
<span class="line" id="L476">    <span class="tok-comment">/// or break indication in the FIFO.</span></span>
<span class="line" id="L477">    <span class="tok-comment">/// 0 = no error in RX FIFO</span></span>
<span class="line" id="L478">    <span class="tok-comment">/// 1 = error in RX FIFO</span></span>
<span class="line" id="L479">    <span class="tok-comment">///</span></span>
<span class="line" id="L480">    <span class="tok-comment">/// Attr: RO</span></span>
<span class="line" id="L481">    recv_fifo_error: <span class="tok-type">bool</span>,</span>
<span class="line" id="L482">    <span class="tok-comment">/// SBZ, bits 8:31</span></span>
<span class="line" id="L483">    <span class="tok-comment">///</span></span>
<span class="line" id="L484">    <span class="tok-comment">/// Attr: RO</span></span>
<span class="line" id="L485">    _reserved8_31: <span class="tok-type">u24</span>,</span>
<span class="line" id="L486">};</span>
<span class="line" id="L487"></span>
<span class="line" id="L488"><span class="tok-comment">/// UART MSR, short for Modem Status Register</span></span>
<span class="line" id="L489"><span class="tok-comment">/// Address: Operational Base + offset (0x0018)</span></span>
<span class="line" id="L490"><span class="tok-comment">/// Attr: RO</span></span>
<span class="line" id="L491"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> uart_msr = <span class="tok-kw">packed</span> <span class="tok-kw">struct</span>(<span class="tok-type">u32</span>) {</span>
<span class="line" id="L492">    <span class="tok-comment">/// Delta Clear to Send.</span></span>
<span class="line" id="L493">    <span class="tok-comment">/// This is used to indicate that the modem control line cts_n has changed</span></span>
<span class="line" id="L494">    <span class="tok-comment">/// since the last time the MSR was read.</span></span>
<span class="line" id="L495">    delta_clear_to_sent: <span class="tok-type">bool</span>,</span>
<span class="line" id="L496">    <span class="tok-comment">/// Delta Data Set Ready.</span></span>
<span class="line" id="L497">    <span class="tok-comment">///</span></span>
<span class="line" id="L498">    <span class="tok-comment">/// This is used to indicate that the modem control line dsr_n has changed</span></span>
<span class="line" id="L499">    <span class="tok-comment">/// since the last time the MSR was read.</span></span>
<span class="line" id="L500">    delta_data_set_ready: <span class="tok-type">bool</span>,</span>
<span class="line" id="L501">    <span class="tok-comment">/// Trailing Edge of Ring Indicator.</span></span>
<span class="line" id="L502">    <span class="tok-comment">///</span></span>
<span class="line" id="L503">    <span class="tok-comment">/// Trailing Edge of Ring Indicator. This is used to indicate that a</span></span>
<span class="line" id="L504">    <span class="tok-comment">/// change on the input ri_n (from an active-low to an inactive-high state)</span></span>
<span class="line" id="L505">    <span class="tok-comment">/// has occurred since the last time the MSR was read.</span></span>
<span class="line" id="L506">    trailing_edge_ring_indicator: <span class="tok-type">bool</span>,</span>
<span class="line" id="L507">    <span class="tok-comment">/// Delta Data Carrier Detect.</span></span>
<span class="line" id="L508">    <span class="tok-comment">///</span></span>
<span class="line" id="L509">    <span class="tok-comment">/// This is used to indicate that the modem control line dcd_n has changed</span></span>
<span class="line" id="L510">    <span class="tok-comment">/// since the last time the MSR was read.</span></span>
<span class="line" id="L511">    delta_data_carrier_detect: <span class="tok-type">bool</span>,</span>
<span class="line" id="L512">    <span class="tok-comment">/// Data Set Ready.</span></span>
<span class="line" id="L513">    <span class="tok-comment">///</span></span>
<span class="line" id="L514">    <span class="tok-comment">/// This is used to indicate the current state of the modem control line</span></span>
<span class="line" id="L515">    <span class="tok-comment">/// dsr_n.</span></span>
<span class="line" id="L516">    data_set_ready: <span class="tok-type">bool</span>,</span>
<span class="line" id="L517">    <span class="tok-comment">/// Ring Indicator</span></span>
<span class="line" id="L518">    <span class="tok-comment">///</span></span>
<span class="line" id="L519">    <span class="tok-comment">/// This is used to indicate the current state of the modem control line ri_n.</span></span>
<span class="line" id="L520">    ring_indicator: <span class="tok-type">bool</span>,</span>
<span class="line" id="L521">    <span class="tok-comment">/// Data Carrier Detect.</span></span>
<span class="line" id="L522">    <span class="tok-comment">/// This is used to indicate the current state of the modem control line</span></span>
<span class="line" id="L523">    <span class="tok-comment">/// dcd_n.</span></span>
<span class="line" id="L524">    data_carrier_detect: <span class="tok-type">bool</span>,</span>
<span class="line" id="L525">    <span class="tok-comment">/// SBZ bits 8:31</span></span>
<span class="line" id="L526">    _reserved8_31: <span class="tok-type">u24</span>,</span>
<span class="line" id="L527">};</span>
<span class="line" id="L528"></span>
<span class="line" id="L529"><span class="tok-comment">/// UART SCR, short for Scratch Pad Register</span></span>
<span class="line" id="L530"><span class="tok-comment">/// Address: Operational Base + offset (0x001C)</span></span>
<span class="line" id="L531"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> uart_scr = <span class="tok-kw">packed</span> <span class="tok-kw">struct</span>(<span class="tok-type">u32</span>) {</span>
<span class="line" id="L532">    <span class="tok-comment">/// This register is for programmers to use as a temporary storage space.</span></span>
<span class="line" id="L533">    <span class="tok-comment">/// Attr: RW</span></span>
<span class="line" id="L534">    temp_store_space: <span class="tok-type">u8</span>,</span>
<span class="line" id="L535">    <span class="tok-comment">/// SBZ, bits 8:31</span></span>
<span class="line" id="L536">    _reserved8_31: <span class="tok-type">u24</span>,</span>
<span class="line" id="L537">};</span>
<span class="line" id="L538"></span>
<span class="line" id="L539"><span class="tok-comment">/// UART SRBR, short for Shadow Recv Buffer Register</span></span>
<span class="line" id="L540"><span class="tok-comment">/// Address: Operational Base + offset (0x0030)</span></span>
<span class="line" id="L541"><span class="tok-comment">/// Attr: RO</span></span>
<span class="line" id="L542"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> uart_srbr = <span class="tok-kw">packed</span> <span class="tok-kw">struct</span>(<span class="tok-type">u32</span>) {</span>
<span class="line" id="L543">    <span class="tok-comment">/// This is a shadow register for the RBR and has been allocated sixteen</span></span>
<span class="line" id="L544">    <span class="tok-comment">/// 32-bit locations so as to accommodate burst accesses from the master.</span></span>
<span class="line" id="L545">    <span class="tok-comment">/// This register contains the data byte received on the serial input port</span></span>
<span class="line" id="L546">    <span class="tok-comment">/// (sin) in UART mode or the serial infrared input (sir_in) in infrared</span></span>
<span class="line" id="L547">    <span class="tok-comment">/// mode. The data in this register is valid only if the Data Ready (DR)</span></span>
<span class="line" id="L548">    <span class="tok-comment">/// bit in the Line status Register (LSR) is set.</span></span>
<span class="line" id="L549">    <span class="tok-comment">///</span></span>
<span class="line" id="L550">    <span class="tok-comment">/// If FIFOs are disabled (FCR[0] set to zero), the data in the RBR must</span></span>
<span class="line" id="L551">    <span class="tok-comment">/// be read before the next data arrives, otherwise it is overwritten,</span></span>
<span class="line" id="L552">    <span class="tok-comment">/// resulting in an overrun error.</span></span>
<span class="line" id="L553">    <span class="tok-comment">///</span></span>
<span class="line" id="L554">    <span class="tok-comment">/// If FIFOs are enabled (FCR[0] set to one), this register accesses the</span></span>
<span class="line" id="L555">    <span class="tok-comment">/// head of the receive FIFO. If the receive FIFO is full and this register</span></span>
<span class="line" id="L556">    <span class="tok-comment">/// is not read before the next data character arrives, then the data</span></span>
<span class="line" id="L557">    <span class="tok-comment">/// already in the FIFO are preserved, but any incoming data is lost. An</span></span>
<span class="line" id="L558">    <span class="tok-comment">/// overrun error also occurs.</span></span>
<span class="line" id="L559">    shadow_rbr: <span class="tok-type">u8</span>,</span>
<span class="line" id="L560">    <span class="tok-comment">/// SBZ, bits 8:31</span></span>
<span class="line" id="L561">    _reserved8_31: <span class="tok-type">u24</span>,</span>
<span class="line" id="L562">};</span>
<span class="line" id="L563"></span>
<span class="line" id="L564"><span class="tok-comment">/// UART STHR, short for Shadow Transmit Holding Register</span></span>
<span class="line" id="L565"><span class="tok-comment">/// Address: Operational Base + offset (0x006C)</span></span>
<span class="line" id="L566"><span class="tok-comment">/// Attr: RO</span></span>
<span class="line" id="L567"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> uart_sthr = <span class="tok-kw">packed</span> <span class="tok-kw">struct</span>(<span class="tok-type">u32</span>) {</span>
<span class="line" id="L568">    <span class="tok-comment">/// This is a shadow register for the THR.</span></span>
<span class="line" id="L569">    shadow_thr: <span class="tok-type">u8</span>,</span>
<span class="line" id="L570">    _reserved8_31: <span class="tok-type">u24</span>,</span>
<span class="line" id="L571">};</span>
<span class="line" id="L572"></span>
<span class="line" id="L573"><span class="tok-comment">/// UART FAR, short for FIFO Access Register</span></span>
<span class="line" id="L574"><span class="tok-comment">/// Address: Operational Base + offset (0x0070)</span></span>
<span class="line" id="L575"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> uart_far = <span class="tok-kw">packed</span> <span class="tok-kw">struct</span>(<span class="tok-type">u32</span>) {</span>
<span class="line" id="L576">    <span class="tok-comment">/// This register is use to enable a FIFO access mode for testing, so that</span></span>
<span class="line" id="L577">    <span class="tok-comment">/// the receive FIFO can be written by the master and the transmit FIFO</span></span>
<span class="line" id="L578">    <span class="tok-comment">/// can be read by the master when FIFOs are implemented and enabled.</span></span>
<span class="line" id="L579">    <span class="tok-comment">/// When FIFOs are not enabled it allows the RBR to be written by the</span></span>
<span class="line" id="L580">    <span class="tok-comment">/// master and the THR to be read by the master.</span></span>
<span class="line" id="L581">    <span class="tok-comment">/// 0 = FIFO access mode disabled</span></span>
<span class="line" id="L582">    <span class="tok-comment">/// 1 = FIFO access mode Enabled</span></span>
<span class="line" id="L583">    <span class="tok-comment">///</span></span>
<span class="line" id="L584">    <span class="tok-comment">/// Attr: RW</span></span>
<span class="line" id="L585">    fifo_access_test_en: <span class="tok-type">bool</span>,</span>
<span class="line" id="L586">    <span class="tok-comment">/// SBZ Bits 1:31</span></span>
<span class="line" id="L587">    <span class="tok-comment">/// Attr: RO</span></span>
<span class="line" id="L588">    _reserved1_31: <span class="tok-type">u31</span>,</span>
<span class="line" id="L589">};</span>
<span class="line" id="L590"></span>
<span class="line" id="L591"><span class="tok-comment">/// UART TFR, short for Transmit FIFO Read</span></span>
<span class="line" id="L592"><span class="tok-comment">/// Address: Operational Base + offset (0x0074)</span></span>
<span class="line" id="L593"><span class="tok-comment">/// Attr: RO</span></span>
<span class="line" id="L594"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> uart_tfr = <span class="tok-kw">packed</span> <span class="tok-kw">struct</span>(<span class="tok-type">u32</span>) {</span>
<span class="line" id="L595">    <span class="tok-comment">/// Transmit FIFO Read.</span></span>
<span class="line" id="L596">    <span class="tok-comment">///</span></span>
<span class="line" id="L597">    <span class="tok-comment">/// These bits are only valid when FIFO access mode is enabled (FAR[0] is</span></span>
<span class="line" id="L598">    <span class="tok-comment">/// set to one).When FIFOs are implemented and enabled, reading this</span></span>
<span class="line" id="L599">    <span class="tok-comment">/// register gives the data at the top of the transmit FIFO. Each</span></span>
<span class="line" id="L600">    <span class="tok-comment">/// consecutive read pops the transmit FIFO and gives the next data value</span></span>
<span class="line" id="L601">    <span class="tok-comment">/// that is currently at the top of the FIFO.</span></span>
<span class="line" id="L602">    trans_fifo_read: <span class="tok-type">u8</span>,</span>
<span class="line" id="L603">    <span class="tok-comment">/// SBZ, Bits 8:31</span></span>
<span class="line" id="L604">    _reserved8_31: <span class="tok-type">u24</span>,</span>
<span class="line" id="L605">};</span>
<span class="line" id="L606"></span>
<span class="line" id="L607"><span class="tok-comment">/// UART RFW, short for Receive FIFO Write</span></span>
<span class="line" id="L608"><span class="tok-comment">/// Address: Operational Base + offset (0x0078)</span></span>
<span class="line" id="L609"><span class="tok-comment">/// Attr: WO</span></span>
<span class="line" id="L610"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> uart_rfw = <span class="tok-kw">packed</span> <span class="tok-kw">struct</span>(<span class="tok-type">u32</span>) {</span>
<span class="line" id="L611">    <span class="tok-comment">/// Receive FIFO Write Data.</span></span>
<span class="line" id="L612">    <span class="tok-comment">///</span></span>
<span class="line" id="L613">    <span class="tok-comment">/// These bits are only valid when FIFO access mode is enabled (FAR[0] is</span></span>
<span class="line" id="L614">    <span class="tok-comment">/// set to one).</span></span>
<span class="line" id="L615">    <span class="tok-comment">///</span></span>
<span class="line" id="L616">    <span class="tok-comment">/// When FIFOs are enabled, the data that is written to the RFWD is</span></span>
<span class="line" id="L617">    <span class="tok-comment">/// pushed into the receive FIFO. Each consecutive write pushes the new</span></span>
<span class="line" id="L618">    <span class="tok-comment">/// data to the next write location in the receive FIFO.</span></span>
<span class="line" id="L619">    <span class="tok-comment">///</span></span>
<span class="line" id="L620">    <span class="tok-comment">/// When FIFOs not enabled, the data that is written to the RFWD is pushed</span></span>
<span class="line" id="L621">    <span class="tok-comment">/// into the RBR.</span></span>
<span class="line" id="L622">    recv_fifo_write: <span class="tok-type">u8</span>,</span>
<span class="line" id="L623">    <span class="tok-comment">/// Receive FIFO Parity Error.</span></span>
<span class="line" id="L624">    <span class="tok-comment">///</span></span>
<span class="line" id="L625">    <span class="tok-comment">/// These bits are only valid when FIFO access mode is enabled (FAR[0] is</span></span>
<span class="line" id="L626">    <span class="tok-comment">/// set to one).</span></span>
<span class="line" id="L627">    recv_fifo_parity_error: <span class="tok-type">bool</span>,</span>
<span class="line" id="L628">    <span class="tok-comment">/// Receive FIFO Framing Error.</span></span>
<span class="line" id="L629">    <span class="tok-comment">///</span></span>
<span class="line" id="L630">    <span class="tok-comment">/// These bits are only valid when FIFO access mode is enabled (FAR[0] is</span></span>
<span class="line" id="L631">    <span class="tok-comment">/// set to one).</span></span>
<span class="line" id="L632">    recv_fifo_framing_error: <span class="tok-type">bool</span>,</span>
<span class="line" id="L633">    <span class="tok-comment">/// SBZ, Bits 10:31</span></span>
<span class="line" id="L634">    _reserved10_31: <span class="tok-type">u22</span>,</span>
<span class="line" id="L635">};</span>
<span class="line" id="L636"></span>
<span class="line" id="L637"><span class="tok-comment">/// UART USR, short for UART Status Register</span></span>
<span class="line" id="L638"><span class="tok-comment">/// Address: Operational Base + offset (0x007C)</span></span>
<span class="line" id="L639"><span class="tok-comment">/// Attr: RO</span></span>
<span class="line" id="L640"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> uart_usr = <span class="tok-kw">packed</span> <span class="tok-kw">struct</span>(<span class="tok-type">u32</span>) {</span>
<span class="line" id="L641">    <span class="tok-comment">/// UART Busy.</span></span>
<span class="line" id="L642">    <span class="tok-comment">///</span></span>
<span class="line" id="L643">    <span class="tok-comment">/// UART Busy. This is indicates that a serial transfer is in progress,</span></span>
<span class="line" id="L644">    <span class="tok-comment">/// when cleared indicates that the UART is idle or inactive.</span></span>
<span class="line" id="L645">    <span class="tok-comment">/// 0 = UART is idle or inactive</span></span>
<span class="line" id="L646">    <span class="tok-comment">/// 1 = UART is busy (actively transferring data)</span></span>
<span class="line" id="L647">    uart_busy: <span class="tok-type">bool</span>,</span>
<span class="line" id="L648">    <span class="tok-comment">/// Transmit FIFO Not Full.</span></span>
<span class="line" id="L649">    <span class="tok-comment">///</span></span>
<span class="line" id="L650">    <span class="tok-comment">/// This is used to indicate that the transmit FIFO in not full.</span></span>
<span class="line" id="L651">    <span class="tok-comment">/// 0 = Transmit FIFO is full</span></span>
<span class="line" id="L652">    <span class="tok-comment">/// 1 = Transmit FIFO is not full</span></span>
<span class="line" id="L653">    <span class="tok-comment">/// This bit is cleared when the TX FIFO is full.</span></span>
<span class="line" id="L654">    trans_fifo_not_full: <span class="tok-type">bool</span>,</span>
<span class="line" id="L655">    <span class="tok-comment">/// Transmit FIFO Empty.</span></span>
<span class="line" id="L656">    <span class="tok-comment">///</span></span>
<span class="line" id="L657">    <span class="tok-comment">/// This is used to indicate that the transmit FIFO is completely empty.</span></span>
<span class="line" id="L658">    <span class="tok-comment">/// 0 = Transmit FIFO is not empty</span></span>
<span class="line" id="L659">    <span class="tok-comment">/// 1 = Transmit FIFO is empty</span></span>
<span class="line" id="L660">    <span class="tok-comment">/// This bit is cleared when the TX FIFO is no longer empty</span></span>
<span class="line" id="L661">    trans_fifo_empty: <span class="tok-type">bool</span>,</span>
<span class="line" id="L662">    <span class="tok-comment">/// Receive FIFO Not Empty.</span></span>
<span class="line" id="L663">    <span class="tok-comment">///</span></span>
<span class="line" id="L664">    <span class="tok-comment">/// This is used to indicate that the receive FIFO contains one or more</span></span>
<span class="line" id="L665">    <span class="tok-comment">/// entries.</span></span>
<span class="line" id="L666">    <span class="tok-comment">/// 0 = Receive FIFO is empty</span></span>
<span class="line" id="L667">    <span class="tok-comment">/// 1 = Receive FIFO is not empty</span></span>
<span class="line" id="L668">    <span class="tok-comment">/// This bit is cleared when the RX FIFO is empty.</span></span>
<span class="line" id="L669">    recv_fifo_not_empty: <span class="tok-type">bool</span>,</span>
<span class="line" id="L670">    <span class="tok-comment">/// Receive FIFO Full.</span></span>
<span class="line" id="L671">    <span class="tok-comment">///</span></span>
<span class="line" id="L672">    <span class="tok-comment">/// This is used to indicate that the receive FIFO is completely full.</span></span>
<span class="line" id="L673">    <span class="tok-comment">/// 0 = Receive FIFO not full</span></span>
<span class="line" id="L674">    <span class="tok-comment">/// 1 = Receive FIFO Full</span></span>
<span class="line" id="L675">    <span class="tok-comment">/// This bit is cleared when the RX FIFO is no longer full.</span></span>
<span class="line" id="L676">    recv_fifo_full: <span class="tok-type">bool</span>,</span>
<span class="line" id="L677">    <span class="tok-comment">/// SBZ, Bits 5:31</span></span>
<span class="line" id="L678">    _reserved5_31: <span class="tok-type">u27</span>,</span>
<span class="line" id="L679">};</span>
<span class="line" id="L680"></span>
<span class="line" id="L681"><span class="tok-comment">/// UART TFL, short for Transmit FIFO Level</span></span>
<span class="line" id="L682"><span class="tok-comment">/// Address: Operational Base + offset (0x0080)</span></span>
<span class="line" id="L683"><span class="tok-comment">/// Attr: RW</span></span>
<span class="line" id="L684"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> uart_tfl = <span class="tok-kw">packed</span> <span class="tok-kw">struct</span>(<span class="tok-type">u32</span>) {</span>
<span class="line" id="L685">    <span class="tok-comment">/// Transmit FIFO Level</span></span>
<span class="line" id="L686">    <span class="tok-comment">///</span></span>
<span class="line" id="L687">    <span class="tok-comment">/// This indicates the number of data entries in the transmit FIFO</span></span>
<span class="line" id="L688">    trans_fifo_lvl: <span class="tok-type">u5</span>,</span>
<span class="line" id="L689">    <span class="tok-comment">/// SBZ, Bits 5:31</span></span>
<span class="line" id="L690">    _reserved5_31: <span class="tok-type">u27</span>,</span>
<span class="line" id="L691">};</span>
<span class="line" id="L692"></span>
<span class="line" id="L693"><span class="tok-comment">/// UART RFL, short for Recv FIFO Level</span></span>
<span class="line" id="L694"><span class="tok-comment">/// Address: Operational Base + offset (0x0084)</span></span>
<span class="line" id="L695"><span class="tok-comment">/// Attr: RO</span></span>
<span class="line" id="L696"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> uart_rfl = <span class="tok-kw">packed</span> <span class="tok-kw">struct</span>(<span class="tok-type">u32</span>) {</span>
<span class="line" id="L697">    <span class="tok-comment">/// Receive FIFO Level.</span></span>
<span class="line" id="L698">    <span class="tok-comment">///</span></span>
<span class="line" id="L699">    <span class="tok-comment">/// This is indicates the number of data entries in the receive FIFO.</span></span>
<span class="line" id="L700">    recv_fifo_lvl: <span class="tok-type">u5</span>,</span>
<span class="line" id="L701">    <span class="tok-comment">/// SBZ, Bits 5:31</span></span>
<span class="line" id="L702">    _reserved5_31: <span class="tok-type">u27</span>,</span>
<span class="line" id="L703">};</span>
<span class="line" id="L704"></span>
<span class="line" id="L705"><span class="tok-comment">/// UART SRR, short for Software Reset Register</span></span>
<span class="line" id="L706"><span class="tok-comment">/// Address: Operational Base + offset (0x0088)</span></span>
<span class="line" id="L707"><span class="tok-comment">/// Attr: WO</span></span>
<span class="line" id="L708"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> uart_srr = <span class="tok-kw">packed</span> <span class="tok-kw">struct</span>(<span class="tok-type">u32</span>) {</span>
<span class="line" id="L709">    <span class="tok-comment">/// UART Reset.</span></span>
<span class="line" id="L710">    <span class="tok-comment">///</span></span>
<span class="line" id="L711">    <span class="tok-comment">/// This asynchronously resets the UART and synchronously removes the</span></span>
<span class="line" id="L712">    <span class="tok-comment">/// reset assertion. For a two clock implementation both pclk and sclk</span></span>
<span class="line" id="L713">    <span class="tok-comment">/// domains are reset.</span></span>
<span class="line" id="L714">    uart_reset: <span class="tok-type">bool</span>,</span>
<span class="line" id="L715">    <span class="tok-comment">/// RCVR FIFO Reset</span></span>
<span class="line" id="L716">    <span class="tok-comment">///</span></span>
<span class="line" id="L717">    <span class="tok-comment">/// This is a shadow register for the RCVR FIFO Reset Bit (FCR[1])</span></span>
<span class="line" id="L718">    rcvr_fifo_reset: <span class="tok-type">bool</span>,</span>
<span class="line" id="L719">    <span class="tok-comment">/// XMIT FIFO Reset</span></span>
<span class="line" id="L720">    <span class="tok-comment">///</span></span>
<span class="line" id="L721">    <span class="tok-comment">/// This is a shadow for the XMIT FIFO Reset bit (FCR[2])</span></span>
<span class="line" id="L722">    xmit_fifo_reset: <span class="tok-type">bool</span>,</span>
<span class="line" id="L723">    <span class="tok-comment">/// SBZ, Bits 3:31</span></span>
<span class="line" id="L724">    _reserved3_31: <span class="tok-type">u29</span> = <span class="tok-number">0</span>,</span>
<span class="line" id="L725">};</span>
<span class="line" id="L726"></span>
<span class="line" id="L727"><span class="tok-comment">/// UART SRTS, short for Software Request To Send</span></span>
<span class="line" id="L728"><span class="tok-comment">/// Address: Operational Base + offset (0x008C)</span></span>
<span class="line" id="L729"><span class="tok-comment">/// Attr: RW</span></span>
<span class="line" id="L730"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> uart_srts = <span class="tok-kw">packed</span> <span class="tok-kw">struct</span>(<span class="tok-type">u32</span>) {</span>
<span class="line" id="L731">    <span class="tok-comment">/// Shadow Request to Send.</span></span>
<span class="line" id="L732">    <span class="tok-comment">///</span></span>
<span class="line" id="L733">    <span class="tok-comment">/// This is a shadow register for the RTS bit (MCR[1]), this can be used</span></span>
<span class="line" id="L734">    <span class="tok-comment">/// to remove the burden of having to performing a read- modify-write on</span></span>
<span class="line" id="L735">    <span class="tok-comment">/// the MCR.</span></span>
<span class="line" id="L736">    shadow_req_to_send: <span class="tok-type">bool</span>,</span>
<span class="line" id="L737">    <span class="tok-comment">/// SBZ, Bits 1:31</span></span>
<span class="line" id="L738">    _reserved1_31: <span class="tok-type">u31</span>,</span>
<span class="line" id="L739">};</span>
<span class="line" id="L740"></span>
<span class="line" id="L741"><span class="tok-comment">/// UART SBCR, short for Shadow Break Control Register</span></span>
<span class="line" id="L742"><span class="tok-comment">/// Address: Operational Base + offset (0x0090)</span></span>
<span class="line" id="L743"><span class="tok-comment">/// Attr: RW</span></span>
<span class="line" id="L744"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> uart_sbcr = <span class="tok-kw">packed</span> <span class="tok-kw">struct</span>(<span class="tok-type">u32</span>) {</span>
<span class="line" id="L745">    <span class="tok-comment">/// Shadow Break Control Bit.</span></span>
<span class="line" id="L746">    <span class="tok-comment">///</span></span>
<span class="line" id="L747">    <span class="tok-comment">/// This is a shadow register for the Break bit (LCR[6]), this can be used</span></span>
<span class="line" id="L748">    <span class="tok-comment">/// to remove the burden of having to performing a read modify write on</span></span>
<span class="line" id="L749">    <span class="tok-comment">/// the LCR.</span></span>
<span class="line" id="L750">    shadow_break_ctrl: <span class="tok-type">bool</span>,</span>
<span class="line" id="L751">    <span class="tok-comment">/// SBZ, Bits 1:31</span></span>
<span class="line" id="L752">    _reserved1_31: <span class="tok-type">u31</span>,</span>
<span class="line" id="L753">};</span>
<span class="line" id="L754"></span>
<span class="line" id="L755"><span class="tok-comment">/// UART SDMAM, short for Shadow DMA Mode</span></span>
<span class="line" id="L756"><span class="tok-comment">/// Address: Operational Base + offset (0x0094)</span></span>
<span class="line" id="L757"><span class="tok-comment">/// Attr: RW</span></span>
<span class="line" id="L758"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> uart_sdmam = <span class="tok-kw">packed</span> <span class="tok-kw">struct</span>(<span class="tok-type">u32</span>) {</span>
<span class="line" id="L759">    <span class="tok-comment">/// Shadow DMA Mode.</span></span>
<span class="line" id="L760">    <span class="tok-comment">///</span></span>
<span class="line" id="L761">    <span class="tok-comment">/// This is a shadow register for the DMA mode bit (FCR[3]).</span></span>
<span class="line" id="L762">    shadow_dma_mode: <span class="tok-type">bool</span>,</span>
<span class="line" id="L763">    <span class="tok-comment">/// SBZ, Bits 1:31</span></span>
<span class="line" id="L764">    _reserved1_31: <span class="tok-type">u31</span>,</span>
<span class="line" id="L765">};</span>
<span class="line" id="L766"></span>
<span class="line" id="L767"><span class="tok-comment">/// UART SFE, short for Shadow FIFO Control</span></span>
<span class="line" id="L768"><span class="tok-comment">/// Address: Operational Base + offset (0x0098)</span></span>
<span class="line" id="L769"><span class="tok-comment">/// Attr: RW</span></span>
<span class="line" id="L770"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> uart_sfe = <span class="tok-kw">packed</span> <span class="tok-kw">struct</span>(<span class="tok-type">u32</span>) {</span>
<span class="line" id="L771">    <span class="tok-comment">/// Shadow FIFO Enable.</span></span>
<span class="line" id="L772">    <span class="tok-comment">///</span></span>
<span class="line" id="L773">    <span class="tok-comment">/// Shadow FIFO Enable. This is a shadow register for the FIFO enable bit</span></span>
<span class="line" id="L774">    <span class="tok-comment">/// (FCR[0]).</span></span>
<span class="line" id="L775">    shadow_fifo_en: <span class="tok-type">bool</span>,</span>
<span class="line" id="L776">    <span class="tok-comment">/// SBZ, Bits 1:31</span></span>
<span class="line" id="L777">    _reserved1_31: <span class="tok-type">u31</span>,</span>
<span class="line" id="L778">};</span>
<span class="line" id="L779"></span>
<span class="line" id="L780"><span class="tok-comment">/// UART SRT, short for Shadow RCVR Trigger</span></span>
<span class="line" id="L781"><span class="tok-comment">/// Address: Operational Base + offset (0x009C)</span></span>
<span class="line" id="L782"><span class="tok-comment">///  Attr: RW</span></span>
<span class="line" id="L783"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> uart_srt = <span class="tok-kw">packed</span> <span class="tok-kw">struct</span>(<span class="tok-type">u32</span>) {</span>
<span class="line" id="L784">    <span class="tok-comment">/// Shadow RCVR Trigger.</span></span>
<span class="line" id="L785">    <span class="tok-comment">///</span></span>
<span class="line" id="L786">    <span class="tok-comment">/// This is a shadow register for the RCVR trigger bits (FCR[7:6]).</span></span>
<span class="line" id="L787">    shadow_rcvr_trigger: <span class="tok-type">bool</span>,</span>
<span class="line" id="L788">    <span class="tok-comment">/// SBZ, Bits 1:31</span></span>
<span class="line" id="L789">    _reserved1_31: <span class="tok-type">u31</span>,</span>
<span class="line" id="L790">};</span>
<span class="line" id="L791"></span>
<span class="line" id="L792"><span class="tok-comment">/// UART STET, short for Shadow TX Empty Register</span></span>
<span class="line" id="L793"><span class="tok-comment">/// Address: Operational Base + offset (0x00A0)</span></span>
<span class="line" id="L794"><span class="tok-comment">/// Attr: RW</span></span>
<span class="line" id="L795"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> uart_stet = <span class="tok-kw">packed</span> <span class="tok-kw">struct</span>(<span class="tok-type">u32</span>) {</span>
<span class="line" id="L796">    <span class="tok-comment">/// Shadow TX Empty Trigger.</span></span>
<span class="line" id="L797">    <span class="tok-comment">///</span></span>
<span class="line" id="L798">    <span class="tok-comment">/// This is a shadow register for the TX empty trigger bits (FCR[5:4]).</span></span>
<span class="line" id="L799">    shadow_tx_empty_trigger: <span class="tok-type">bool</span>,</span>
<span class="line" id="L800">    <span class="tok-comment">/// SBZ, Bits 1:31</span></span>
<span class="line" id="L801">    _reserved1_31: <span class="tok-type">u31</span>,</span>
<span class="line" id="L802">};</span>
<span class="line" id="L803"></span>
<span class="line" id="L804"><span class="tok-comment">/// UART HTX, short for Halt TX</span></span>
<span class="line" id="L805"><span class="tok-comment">/// Address: Operational Base + offset (0x00A4)</span></span>
<span class="line" id="L806"><span class="tok-comment">/// Attr: RW</span></span>
<span class="line" id="L807"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> uart_htx = <span class="tok-kw">packed</span> <span class="tok-kw">struct</span>(<span class="tok-type">u32</span>) {</span>
<span class="line" id="L808">    <span class="tok-comment">/// This register is use to halt transmissions for testing, so that the</span></span>
<span class="line" id="L809">    <span class="tok-comment">/// transmit FIFO can be filled by the master when FIFOs are implemented</span></span>
<span class="line" id="L810">    <span class="tok-comment">/// and enabled.</span></span>
<span class="line" id="L811">    <span class="tok-comment">/// 0 = Halt TX disabled</span></span>
<span class="line" id="L812">    <span class="tok-comment">/// 1 = Halt TX enabled</span></span>
<span class="line" id="L813">    halt_tx_en: <span class="tok-type">bool</span>,</span>
<span class="line" id="L814">    <span class="tok-comment">/// SBZ, Bits 1:31</span></span>
<span class="line" id="L815">    _reserved1_31: <span class="tok-type">u31</span>,</span>
<span class="line" id="L816">};</span>
<span class="line" id="L817"></span>
<span class="line" id="L818"><span class="tok-comment">/// UART DMASA, short for DMA Software Acknowledge</span></span>
<span class="line" id="L819"><span class="tok-comment">/// Address: Operational Base + offset (0x00A8)</span></span>
<span class="line" id="L820"><span class="tok-comment">/// Attr: WO</span></span>
<span class="line" id="L821"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> uart_dmasa = <span class="tok-kw">packed</span> <span class="tok-kw">struct</span>(<span class="tok-type">u32</span>) {</span>
<span class="line" id="L822">    <span class="tok-comment">/// This register is use to perform a DMA software acknowledge if a</span></span>
<span class="line" id="L823">    <span class="tok-comment">/// transfer needs to be terminated due to an error condition.</span></span>
<span class="line" id="L824">    dma_software_ack: <span class="tok-type">bool</span>,</span>
<span class="line" id="L825">    <span class="tok-comment">/// SBZ, Bits 1:31</span></span>
<span class="line" id="L826">    _reserved1_31: <span class="tok-type">u31</span>,</span>
<span class="line" id="L827">};</span>
<span class="line" id="L828"></span>
<span class="line" id="L829"><span class="tok-comment">/// UART CPR, short for Component Parameter Register</span></span>
<span class="line" id="L830"><span class="tok-comment">/// Address: Operational Base + offset (0x00F4)</span></span>
<span class="line" id="L831"><span class="tok-comment">/// UART_CPR is UART0’s own unique register !!!</span></span>
<span class="line" id="L832"><span class="tok-comment">/// Attr: RO</span></span>
<span class="line" id="L833"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> uart_cpr = <span class="tok-kw">packed</span> <span class="tok-kw">struct</span>(<span class="tok-type">u32</span>) {</span>
<span class="line" id="L834">    <span class="tok-comment">/// 00 = 8 bits</span></span>
<span class="line" id="L835">    <span class="tok-comment">/// 01 = 16 bits</span></span>
<span class="line" id="L836">    <span class="tok-comment">/// 10 = 32 bits</span></span>
<span class="line" id="L837">    <span class="tok-comment">/// 11 = reserved</span></span>
<span class="line" id="L838">    APB_DATA_WIDTH: <span class="tok-type">u2</span>,</span>
<span class="line" id="L839">    <span class="tok-comment">/// SBZ</span></span>
<span class="line" id="L840">    _reserved2_3: <span class="tok-type">u2</span>,</span>
<span class="line" id="L841">    <span class="tok-comment">/// 0 = FALSE</span></span>
<span class="line" id="L842">    <span class="tok-comment">/// 1 = TRUE</span></span>
<span class="line" id="L843">    AFCE_MODE: <span class="tok-type">bool</span>,</span>
<span class="line" id="L844">    <span class="tok-comment">/// 0 = FALSE</span></span>
<span class="line" id="L845">    <span class="tok-comment">/// 1 = TRUE</span></span>
<span class="line" id="L846">    THRE_MODE: <span class="tok-type">bool</span>,</span>
<span class="line" id="L847">    SIR_MODE: <span class="tok-type">bool</span>,</span>
<span class="line" id="L848">    SIR_LP_MODE: <span class="tok-type">bool</span>,</span>
<span class="line" id="L849">    NEW_FEAT: <span class="tok-type">bool</span>,</span>
<span class="line" id="L850">    FIFO_ACCESS: <span class="tok-type">bool</span>,</span>
<span class="line" id="L851">    FIFO_STAT: <span class="tok-type">bool</span>,</span>
<span class="line" id="L852">    SHADOW: <span class="tok-type">bool</span>,</span>
<span class="line" id="L853">    UART_ADD_ENCODED_PARAMS: <span class="tok-type">bool</span>,</span>
<span class="line" id="L854">    DMA_EXTRA: <span class="tok-type">bool</span>,</span>
<span class="line" id="L855">    _reserved14_15: <span class="tok-type">u2</span>,</span>
<span class="line" id="L856">    <span class="tok-comment">/// FIFO Mode</span></span>
<span class="line" id="L857">    <span class="tok-comment">/// 0x00 = 0</span></span>
<span class="line" id="L858">    <span class="tok-comment">/// 0x01 = 16</span></span>
<span class="line" id="L859">    <span class="tok-comment">/// 0x02 = 32</span></span>
<span class="line" id="L860">    <span class="tok-comment">/// to</span></span>
<span class="line" id="L861">    <span class="tok-comment">/// 0x80 = 2048</span></span>
<span class="line" id="L862">    <span class="tok-comment">/// 0x81 - 0xFF = Reserved</span></span>
<span class="line" id="L863">    FIFO_MODE: <span class="tok-type">u8</span>,</span>
<span class="line" id="L864">    _reserved24_31: <span class="tok-type">u9</span>,</span>
<span class="line" id="L865">};</span>
<span class="line" id="L866"></span>
<span class="line" id="L867"><span class="tok-comment">/// UART UCV, short for UART Component Version</span></span>
<span class="line" id="L868"><span class="tok-comment">/// Address: Operational Base + offset (0x00F8)</span></span>
<span class="line" id="L869"><span class="tok-comment">/// Attr: RO</span></span>
<span class="line" id="L870"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> uart_ucv = <span class="tok-kw">packed</span> <span class="tok-kw">struct</span>(<span class="tok-type">u32</span>) {</span>
<span class="line" id="L871">    <span class="tok-comment">/// Version</span></span>
<span class="line" id="L872">    <span class="tok-comment">///</span></span>
<span class="line" id="L873">    <span class="tok-comment">/// ASCII valye for each number in the version</span></span>
<span class="line" id="L874">    version: <span class="tok-type">u32</span>,</span>
<span class="line" id="L875">};</span>
<span class="line" id="L876"></span>
<span class="line" id="L877"><span class="tok-comment">/// UART CTR, short for Component Type Register</span></span>
<span class="line" id="L878"><span class="tok-comment">/// Address: Operational Base + offset (0x00FC)</span></span>
<span class="line" id="L879"><span class="tok-comment">/// Attr: RO</span></span>
<span class="line" id="L880"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> uart_ctr = <span class="tok-kw">packed</span> <span class="tok-kw">struct</span>(<span class="tok-type">u32</span>) {</span>
<span class="line" id="L881">    <span class="tok-comment">/// This register contains the peripherals identification code.</span></span>
<span class="line" id="L882">    peripheral_id: <span class="tok-type">u32</span>,</span>
<span class="line" id="L883">};</span>
<span class="line" id="L884"></span>
</code></pre></body>
</html>