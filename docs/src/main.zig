<!doctype html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">    <title>main.zig - source view</title>
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
<pre><code><span class="line" id="L1"><span class="tok-kw">const</span> gpio = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;gpio.zig&quot;</span>);</span>
<span class="line" id="L2"><span class="tok-kw">const</span> uart = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;uart.zig&quot;</span>);</span>
<span class="line" id="L3"></span>
<span class="line" id="L4"><span class="tok-kw">extern</span> <span class="tok-kw">var</span> __bss_start: <span class="tok-type">u8</span>;</span>
<span class="line" id="L5"><span class="tok-kw">extern</span> <span class="tok-kw">var</span> __bss_end: <span class="tok-type">u8</span>;</span>
<span class="line" id="L6"></span>
<span class="line" id="L7"><span class="tok-kw">fn</span> <span class="tok-fn">delay</span>() <span class="tok-type">void</span> {</span>
<span class="line" id="L8">    <span class="tok-kw">var</span> def_delay: <span class="tok-type">usize</span> = <span class="tok-number">1000000</span>;</span>
<span class="line" id="L9">    <span class="tok-kw">const</span> ptr: *<span class="tok-kw">volatile</span> <span class="tok-type">usize</span> = &amp;def_delay;</span>
<span class="line" id="L10"></span>
<span class="line" id="L11">    <span class="tok-kw">while</span> (def_delay &gt; <span class="tok-number">0</span>) {</span>
<span class="line" id="L12">        ptr.* -= <span class="tok-number">1</span>;</span>
<span class="line" id="L13">    }</span>
<span class="line" id="L14">}</span>
<span class="line" id="L15"></span>
<span class="line" id="L16"><span class="tok-kw">fn</span> <span class="tok-fn">talker</span>() <span class="tok-type">void</span> {</span>
<span class="line" id="L17">    <span class="tok-kw">while</span> (<span class="tok-null">true</span>) {</span>
<span class="line" id="L18">        uart.print(<span class="tok-str">&quot;Zoot\n&quot;</span>);</span>
<span class="line" id="L19">    }</span>
<span class="line" id="L20">}</span>
<span class="line" id="L21"></span>
<span class="line" id="L22"><span class="tok-comment">/// Zig entry point for the first bit of user code loaded by the BROM into the</span></span>
<span class="line" id="L23"><span class="tok-comment">/// 192K SRAM. The main goal is to initialize DDR Memory, then we can load</span></span>
<span class="line" id="L24"><span class="tok-comment">/// programs to RAM and run there.</span></span>
<span class="line" id="L25"><span class="tok-kw">export</span> <span class="tok-kw">fn</span> <span class="tok-fn">zigMain</span>() <span class="tok-type">noreturn</span> {</span>
<span class="line" id="L26">    <span class="tok-comment">// zero BSS</span>
</span>
<span class="line" id="L27">    <span class="tok-builtin">@memset</span>(<span class="tok-builtin">@as</span>(*<span class="tok-kw">volatile</span> [<span class="tok-number">1</span>]<span class="tok-type">u8</span>, &amp;__bss_start), <span class="tok-number">0</span>, <span class="tok-builtin">@ptrToInt</span>(&amp;__bss_end) - <span class="tok-builtin">@ptrToInt</span>(&amp;__bss_start));</span>
<span class="line" id="L28">    uart.uartInit();</span>
<span class="line" id="L29">    <span class="tok-kw">var</span> rk_gpio = gpio.Gpio.init(gpio.GpioBase.zero);</span>
<span class="line" id="L30">    <span class="tok-kw">const</span> led_mask = <span class="tok-builtin">@as</span>(<span class="tok-type">u32</span>, <span class="tok-number">0x800</span>);</span>
<span class="line" id="L31">    rk_gpio.dir.write(led_mask);</span>
<span class="line" id="L32">    rk_gpio.data.write(led_mask);</span>
<span class="line" id="L33">    delay();</span>
<span class="line" id="L34">    rk_gpio.data.write(<span class="tok-number">0</span>);</span>
<span class="line" id="L35">    delay();</span>
<span class="line" id="L36">    talker();</span>
<span class="line" id="L37">    <span class="tok-kw">unreachable</span>;</span>
<span class="line" id="L38">}</span>
<span class="line" id="L39"></span>
</code></pre></body>
</html>