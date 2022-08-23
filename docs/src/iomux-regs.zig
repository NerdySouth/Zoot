<!doctype html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">    <title>iomux-regs.zig - source view</title>
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
<pre><code><span class="line" id="L1"><span class="tok-kw">const</span> mmio = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;mmio.zig&quot;</span>);</span>
<span class="line" id="L2"><span class="tok-comment">/// IOMUX: IO Multiplexing</span></span>
<span class="line" id="L3"><span class="tok-comment">/// This is for the problem of having more onboard perpherals/services than</span></span>
<span class="line" id="L4"><span class="tok-comment">/// we have pins for. Although each pin on the system can only be used for</span></span>
<span class="line" id="L5"><span class="tok-comment">/// one peripheral/service at a time, we can dynamically assign which perpherals</span></span>
<span class="line" id="L6"><span class="tok-comment">/// or service it should perform internally.</span></span>
<span class="line" id="L7"><span class="tok-comment">/// See the GRF (General Register Files) chapter of the RK3399 TRM for more</span></span>
<span class="line" id="L8"><span class="tok-comment">/// info</span></span>
<span class="line" id="L9"><span class="tok-kw">const</span> GRF_BASE = <span class="tok-number">0xFF770000</span>;</span>
<span class="line" id="L10"><span class="tok-kw">const</span> IOMUX_BASE = <span class="tok-number">0xFF77E000</span>;</span>
<span class="line" id="L11"><span class="tok-kw">const</span> GPIO4B_OFFSET = <span class="tok-number">0xE024</span>;</span>
<span class="line" id="L12"><span class="tok-kw">const</span> GPIO4C_OFFSET = <span class="tok-number">0xE028</span>;</span>
<span class="line" id="L13"><span class="tok-kw">const</span> PMU_GRF_BASE = <span class="tok-number">0xFF320000</span>;</span>
<span class="line" id="L14"></span>
<span class="line" id="L15"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> Register = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L16">    reg: mmio.Register(<span class="tok-type">u32</span>, <span class="tok-type">u32</span>),</span>
<span class="line" id="L17"></span>
<span class="line" id="L18">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">init</span>(<span class="tok-kw">comptime</span> addr: GRFAddr) Register {</span>
<span class="line" id="L19">        <span class="tok-kw">return</span> Register{ .reg = mmio.Register(<span class="tok-type">u32</span>, <span class="tok-type">u32</span>).init(<span class="tok-builtin">@enumToInt</span>(addr)) };</span>
<span class="line" id="L20">    }</span>
<span class="line" id="L21">};</span>
<span class="line" id="L22"></span>
<span class="line" id="L23"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> GRFAddr = <span class="tok-kw">enum</span>(<span class="tok-type">u32</span>) {</span>
<span class="line" id="L24">    GPIO4B = GRF_BASE + GPIO4B_OFFSET,</span>
<span class="line" id="L25">    GPIO4C = GRF_BASE + GPIO4C_OFFSET,</span>
<span class="line" id="L26">};</span>
<span class="line" id="L27"></span>
<span class="line" id="L28"><span class="tok-comment">/// GPIO4B IOMUX Control Register</span></span>
<span class="line" id="L29"><span class="tok-kw">const</span> gpio_4b_grf = <span class="tok-kw">packed</span> <span class="tok-kw">struct</span>(<span class="tok-type">u32</span>) {</span>
<span class="line" id="L30">    sel_0: <span class="tok-type">u2</span>,</span>
<span class="line" id="L31">    sel_1: <span class="tok-type">u2</span>,</span>
<span class="line" id="L32">    sel_2: <span class="tok-type">u2</span>,</span>
<span class="line" id="L33">    sel_3: <span class="tok-type">u2</span>,</span>
<span class="line" id="L34">    sel_4: <span class="tok-type">u2</span>,</span>
<span class="line" id="L35">    sel_5: <span class="tok-type">u2</span>,</span>
<span class="line" id="L36">    _reserbed12_15: <span class="tok-type">u4</span>,</span>
<span class="line" id="L37">    write_enable: <span class="tok-type">u16</span>,</span>
<span class="line" id="L38">};</span>
<span class="line" id="L39"></span>
<span class="line" id="L40"><span class="tok-comment">/// GPIO4C IOMUX Control Register</span></span>
<span class="line" id="L41"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> gpio_4c_grf = <span class="tok-kw">packed</span> <span class="tok-kw">struct</span>(<span class="tok-type">u32</span>) {</span>
<span class="line" id="L42">    sel_0: <span class="tok-type">u2</span>,</span>
<span class="line" id="L43">    sel_1: <span class="tok-type">u2</span>,</span>
<span class="line" id="L44">    sel_2: <span class="tok-type">u2</span>,</span>
<span class="line" id="L45">    sel_3: <span class="tok-type">u2</span>,</span>
<span class="line" id="L46">    sel_4: <span class="tok-type">u2</span>,</span>
<span class="line" id="L47">    sel_5: <span class="tok-type">u2</span>,</span>
<span class="line" id="L48">    sel_6: <span class="tok-type">u2</span>,</span>
<span class="line" id="L49">    sel_7: <span class="tok-type">u2</span>,</span>
<span class="line" id="L50">    write_enable: <span class="tok-type">u16</span>,</span>
<span class="line" id="L51">};</span>
<span class="line" id="L52"></span>
</code></pre></body>
</html>