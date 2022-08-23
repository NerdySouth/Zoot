<!doctype html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">    <title>uart.zig - source view</title>
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
<pre><code><span class="line" id="L1"><span class="tok-kw">const</span> uart_regs = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;uart-regs.zig&quot;</span>);</span>
<span class="line" id="L2"><span class="tok-kw">const</span> iomux = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;iomux-regs.zig&quot;</span>);</span>
<span class="line" id="L3"><span class="tok-kw">const</span> mmio = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;mmio.zig&quot;</span>);</span>
<span class="line" id="L4"></span>
<span class="line" id="L5"><span class="tok-comment">/// RK3399 UART's</span></span>
<span class="line" id="L6"><span class="tok-comment">/// The RK3399 has 5 independent UART's. All 5 contain two 64 Byte FIFOs for</span></span>
<span class="line" id="L7"><span class="tok-comment">/// data receive and transmit. UART0 and UART3 support auto flow-control.</span></span>
<span class="line" id="L8"><span class="tok-comment">/// Bitrates:</span></span>
<span class="line" id="L9"><span class="tok-comment">///     - 115.2Kbps</span></span>
<span class="line" id="L10"><span class="tok-comment">///     - 460.8Kbps</span></span>
<span class="line" id="L11"><span class="tok-comment">///     - 921.6Kbps</span></span>
<span class="line" id="L12"><span class="tok-comment">///     - 1.5Mbps</span></span>
<span class="line" id="L13"><span class="tok-comment">///     - 3Mbps</span></span>
<span class="line" id="L14"><span class="tok-comment">///     - 4Mbps</span></span>
<span class="line" id="L15"><span class="tok-comment">/// All support programmable baud rates, even with non-integer clock divider</span></span>
<span class="line" id="L16"><span class="tok-comment">/// Start, Stop, Parity bits.</span></span>
<span class="line" id="L17"><span class="tok-comment">/// Interrupt-based or DMA mode</span></span>
<span class="line" id="L18"><span class="tok-comment">/// support 5-8 bit width transfer</span></span>
<span class="line" id="L19"><span class="tok-comment">/// See section UART, page 439 of the RK3399 Technical Reference Manual for</span></span>
<span class="line" id="L20"><span class="tok-comment">/// more info.</span></span>
<span class="line" id="L21"><span class="tok-kw">const</span> uart_clock = <span class="tok-number">24000000</span>;</span>
<span class="line" id="L22"></span>
<span class="line" id="L23"><span class="tok-kw">const</span> uart_base = uart_regs.UART2_BASE;</span>
<span class="line" id="L24"><span class="tok-kw">const</span> ier_addr = uart_base | uart_regs.IER_OFFSET;</span>
<span class="line" id="L25"><span class="tok-kw">const</span> srr_addr = uart_base | uart_regs.SRR_OFFSET;</span>
<span class="line" id="L26"><span class="tok-kw">const</span> mcr_addr = uart_base | uart_regs.MCR_OFFSET;</span>
<span class="line" id="L27"><span class="tok-kw">const</span> lcr_addr = uart_base | uart_regs.LCR_OFFSET;</span>
<span class="line" id="L28"><span class="tok-kw">const</span> dll_addr = uart_base | uart_regs.DLL_OFFSET;</span>
<span class="line" id="L29"><span class="tok-kw">const</span> dlh_addr = uart_base | uart_regs.DLH_OFFSET;</span>
<span class="line" id="L30"><span class="tok-kw">const</span> sfe_addr = uart_base | uart_regs.SFE_OFFSET;</span>
<span class="line" id="L31"><span class="tok-kw">const</span> srt_addr = uart_base | uart_regs.SRT_OFFSET;</span>
<span class="line" id="L32"><span class="tok-kw">const</span> stet_addr = uart_base | uart_regs.STET_OFFSET;</span>
<span class="line" id="L33"><span class="tok-kw">const</span> usr_addr = uart_base | uart_regs.USR_OFFSET;</span>
<span class="line" id="L34"><span class="tok-kw">const</span> thr_addr = uart_base | uart_regs.THR_OFFSET;</span>
<span class="line" id="L35"></span>
<span class="line" id="L36"><span class="tok-comment">/// Sets the GPIO pins 8 and 10 up for use by the UART2</span></span>
<span class="line" id="L37"><span class="tok-comment">/// See page 204 in TRM. Note that GRF is General Register Files.</span></span>
<span class="line" id="L38"><span class="tok-comment">/// On page 55 of the data sheet, we see:</span></span>
<span class="line" id="L39"><span class="tok-comment">/// GPIO_B0 is our uart Rx when func 3 is selected</span></span>
<span class="line" id="L40"><span class="tok-comment">/// GPIO_B1 is our uart Tx when func 3 is selected.</span></span>
<span class="line" id="L41"><span class="tok-comment">/// This particular GRF is described on page 309 of the TRM.</span></span>
<span class="line" id="L42"><span class="tok-kw">fn</span> <span class="tok-fn">uartIOMux</span>() <span class="tok-type">void</span> {</span>
<span class="line" id="L43">    <span class="tok-comment">// The top 16 bits of the IOMUX register control whether or not software</span>
</span>
<span class="line" id="L44">    <span class="tok-comment">// can write to the lower 16 bits. Bit 16 controls writes to bit 0.</span>
</span>
<span class="line" id="L45">    <span class="tok-comment">//</span>
</span>
<span class="line" id="L46">    <span class="tok-comment">// We want to set gpio_4c.sel_3 and sel_4 to mode 1 (0b01), since this is</span>
</span>
<span class="line" id="L47">    <span class="tok-comment">// the mode for UART2</span>
</span>
<span class="line" id="L48">    <span class="tok-comment">//</span>
</span>
<span class="line" id="L49">    <span class="tok-comment">// It does appear that the TRM says we could use the GPIO_4B GRF, but</span>
</span>
<span class="line" id="L50">    <span class="tok-comment">// it appears to  work just fine using this method as well.</span>
</span>
<span class="line" id="L51">    <span class="tok-kw">const</span> register = iomux.Register.init(iomux.GRFAddr.GPIO4C);</span>
<span class="line" id="L52">    <span class="tok-kw">var</span> reg_val: <span class="tok-type">u32</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L53">    <span class="tok-comment">// enable write to proper bits</span>
</span>
<span class="line" id="L54">    reg_val |= (<span class="tok-number">1</span> &lt;&lt; <span class="tok-number">22</span>);</span>
<span class="line" id="L55">    reg_val |= (<span class="tok-number">1</span> &lt;&lt; <span class="tok-number">24</span>);</span>
<span class="line" id="L56">    <span class="tok-comment">// can now switch mode to UART2</span>
</span>
<span class="line" id="L57">    reg_val |= (<span class="tok-number">1</span> &lt;&lt; <span class="tok-number">6</span>);</span>
<span class="line" id="L58">    reg_val = (<span class="tok-number">1</span> &lt;&lt; <span class="tok-number">8</span>);</span>
<span class="line" id="L59">    register.reg.write(reg_val);</span>
<span class="line" id="L60">}</span>
<span class="line" id="L61"></span>
<span class="line" id="L62"><span class="tok-kw">fn</span> <span class="tok-fn">setBaudrate</span>(baud: <span class="tok-type">u32</span>) <span class="tok-type">void</span> {</span>
<span class="line" id="L63">    <span class="tok-comment">// per rk3399 TRM:</span>
</span>
<span class="line" id="L64">    <span class="tok-comment">// Baudrate = (serial clock freq) / (16 * divisor)</span>
</span>
<span class="line" id="L65">    <span class="tok-comment">//</span>
</span>
<span class="line" id="L66">    <span class="tok-comment">// We can solve for divisor given a baudrate since we know the clock freq.</span>
</span>
<span class="line" id="L67">    <span class="tok-comment">// where divisor is represented by a 32 bit integer stored in the DLL</span>
</span>
<span class="line" id="L68">    <span class="tok-comment">// and DLH registers.</span>
</span>
<span class="line" id="L69">    <span class="tok-kw">const</span> rate = uart_clock / <span class="tok-number">16</span> / baud;</span>
<span class="line" id="L70"></span>
<span class="line" id="L71">    <span class="tok-comment">// write to div_lat_access field to allow DLL and DLH writes</span>
</span>
<span class="line" id="L72">    <span class="tok-kw">const</span> lcr_reg = mmio.Register(<span class="tok-type">u32</span>, <span class="tok-type">u32</span>).init(lcr_addr);</span>
<span class="line" id="L73">    lcr_reg.modify(<span class="tok-number">0x80</span>);</span>
<span class="line" id="L74"></span>
<span class="line" id="L75">    <span class="tok-comment">// write the rate to the DLL and DLH registers</span>
</span>
<span class="line" id="L76">    mmio.Register(<span class="tok-type">void</span>, <span class="tok-type">u32</span>).init(dll_addr).write(rate &amp; <span class="tok-number">0xff</span>);</span>
<span class="line" id="L77">    mmio.Register(<span class="tok-type">void</span>, <span class="tok-type">u32</span>).init(dlh_addr).write((rate &gt;&gt; <span class="tok-number">8</span>) &amp; <span class="tok-number">0xff</span>);</span>
<span class="line" id="L78"></span>
<span class="line" id="L79">    <span class="tok-comment">// clear div_lat_access field to prevent future DLL and DLH writes</span>
</span>
<span class="line" id="L80">    lcr_reg.write(lcr_reg.read() &amp; ~(<span class="tok-builtin">@as</span>(<span class="tok-type">u32</span>, <span class="tok-number">0x80</span>)));</span>
<span class="line" id="L81">}</span>
<span class="line" id="L82"></span>
<span class="line" id="L83"><span class="tok-comment">/// Initialization function for the uart</span></span>
<span class="line" id="L84"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">uartInit</span>() <span class="tok-type">void</span> {</span>
<span class="line" id="L85">    <span class="tok-comment">// setup GPIO pin multiplex functions for UART2</span>
</span>
<span class="line" id="L86">    uartIOMux();</span>
<span class="line" id="L87"></span>
<span class="line" id="L88">    <span class="tok-comment">// disable all interrupts</span>
</span>
<span class="line" id="L89">    mmio.Register(<span class="tok-type">void</span>, <span class="tok-type">u32</span>).init(ier_addr).write_raw(<span class="tok-number">0</span>);</span>
<span class="line" id="L90"></span>
<span class="line" id="L91">    <span class="tok-comment">// Reset the uart and both fifos</span>
</span>
<span class="line" id="L92">    mmio.Register(<span class="tok-type">void</span>, <span class="tok-type">u32</span>).init(srr_addr).write(<span class="tok-number">0x1</span> | <span class="tok-number">0x2</span> | <span class="tok-number">0x4</span>);</span>
<span class="line" id="L93"></span>
<span class="line" id="L94">    <span class="tok-comment">// set MCR register to 0 (broadly disables some stuff)</span>
</span>
<span class="line" id="L95">    mmio.Register(<span class="tok-type">void</span>, <span class="tok-type">u32</span>).init(mcr_addr).write(<span class="tok-number">0</span>);</span>
<span class="line" id="L96"></span>
<span class="line" id="L97">    <span class="tok-comment">// disable parity, set one stop bit, 8 bit width, aka 8n1</span>
</span>
<span class="line" id="L98">    <span class="tok-kw">const</span> uart_8n1 = uart_regs.uart_lcr{</span>
<span class="line" id="L99">        .data_len_sel = <span class="tok-number">3</span>,</span>
<span class="line" id="L100">        .stop_bits_num = <span class="tok-null">false</span>, <span class="tok-comment">// 0 = 1 bit, 1 = 1.5 bits</span>
</span>
<span class="line" id="L101">        .parity_en = <span class="tok-null">false</span>,</span>
<span class="line" id="L102">        .even_parity_sel = <span class="tok-null">false</span>,</span>
<span class="line" id="L103">        .break_ctrl = <span class="tok-null">false</span>,</span>
<span class="line" id="L104">        .div_lat_access = <span class="tok-null">false</span>,</span>
<span class="line" id="L105">    };</span>
<span class="line" id="L106">    mmio.Register(<span class="tok-type">void</span>, uart_regs.uart_lcr).init(lcr_addr).write(uart_8n1);</span>
<span class="line" id="L107"></span>
<span class="line" id="L108">    setBaudrate(<span class="tok-number">115200</span>);</span>
<span class="line" id="L109"></span>
<span class="line" id="L110">    <span class="tok-comment">// enable the FIFOs and tx empty trigger via their shadow registers</span>
</span>
<span class="line" id="L111">    mmio.Register(<span class="tok-type">void</span>, <span class="tok-type">u32</span>).init(sfe_addr).write(<span class="tok-number">1</span>);</span>
<span class="line" id="L112">    mmio.Register(<span class="tok-type">void</span>, <span class="tok-type">u32</span>).init(srt_addr).write(<span class="tok-number">1</span>);</span>
<span class="line" id="L113">    mmio.Register(<span class="tok-type">void</span>, <span class="tok-type">u32</span>).init(stet_addr).write(<span class="tok-number">1</span>);</span>
<span class="line" id="L114">}</span>
<span class="line" id="L115"></span>
<span class="line" id="L116"><span class="tok-kw">fn</span> <span class="tok-fn">putc</span>(char: <span class="tok-type">u8</span>) <span class="tok-type">void</span> {</span>
<span class="line" id="L117">    <span class="tok-kw">const</span> usr_reg = mmio.Register(<span class="tok-type">u32</span>, <span class="tok-type">void</span>).init(usr_addr);</span>
<span class="line" id="L118"></span>
<span class="line" id="L119">    <span class="tok-comment">// wait until the transmit fifo is empty (we are only sending one char</span>
</span>
<span class="line" id="L120">    <span class="tok-comment">// at a time right now.</span>
</span>
<span class="line" id="L121">    <span class="tok-kw">while</span> ((usr_reg.read() &amp; <span class="tok-number">0x1</span>) != <span class="tok-number">0x1</span>) {}</span>
<span class="line" id="L122"></span>
<span class="line" id="L123">    <span class="tok-kw">const</span> xmit_reg = mmio.Register(<span class="tok-type">void</span>, <span class="tok-type">u32</span>).init(thr_addr);</span>
<span class="line" id="L124">    xmit_reg.write(<span class="tok-builtin">@as</span>(<span class="tok-type">u32</span>, char));</span>
<span class="line" id="L125">}</span>
<span class="line" id="L126"></span>
<span class="line" id="L127"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">print</span>(str: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) <span class="tok-type">void</span> {</span>
<span class="line" id="L128">    <span class="tok-kw">for</span> (str) |char| {</span>
<span class="line" id="L129">        putc(char);</span>
<span class="line" id="L130">    }</span>
<span class="line" id="L131">}</span>
<span class="line" id="L132"></span>
</code></pre></body>
</html>