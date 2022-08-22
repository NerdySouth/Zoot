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
<pre><code><span class="line" id="L1"><span class="tok-comment">// This is the real entry point for our program. It simply jumps (or branches,</span>
</span>
<span class="line" id="L2"><span class="tok-comment">// using the `b` instruction) to our main function, `zigMain`, written</span>
</span>
<span class="line" id="L3"><span class="tok-comment">// in Zig below.</span>
</span>
<span class="line" id="L4"><span class="tok-comment">//</span>
</span>
<span class="line" id="L5"><span class="tok-comment">// One important thing here is that I place this code in the `.text.boot`</span>
</span>
<span class="line" id="L6"><span class="tok-comment">// section of the resulting object. The linker script, `simplest.ld`, makes sure</span>
</span>
<span class="line" id="L7"><span class="tok-comment">// this section is placed right at the beginning of the resulting binary. That's</span>
</span>
<span class="line" id="L8"><span class="tok-comment">// what I want, because the RockPro64 will start running from the beginning</span>
</span>
<span class="line" id="L9"><span class="tok-comment">// of the binary.</span>
</span>
<span class="line" id="L10"><span class="tok-comment">//</span>
</span>
<span class="line" id="L11"><span class="tok-comment">// Maybe important: the linker will look (by default) for the `_start` symbol as</span>
</span>
<span class="line" id="L12"><span class="tok-comment">// the program entry point. As far as I understand, though, this isn't relevant</span>
</span>
<span class="line" id="L13"><span class="tok-comment">// for this program, because the RockPro64 will start running from the first</span>
</span>
<span class="line" id="L14"><span class="tok-comment">// byte of the image. I am really defining the entry point by using the</span>
</span>
<span class="line" id="L15"><span class="tok-comment">// `.text.boot`, and `_start` is effectivelly ignored. However, the linker</span>
</span>
<span class="line" id="L16"><span class="tok-comment">// will complain if it can't find `_start`, so I define it here to make our</span>
</span>
<span class="line" id="L17"><span class="tok-comment">// tools happy. There's probably a more elegant way to do this...</span>
</span>
<span class="line" id="L18"><span class="tok-kw">const</span> gpio = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;gpio.zig&quot;</span>);</span>
<span class="line" id="L19"><span class="tok-comment">//const uart = @import(&quot;uart.zig&quot;);</span>
</span>
<span class="line" id="L20"></span>
<span class="line" id="L21"><span class="tok-kw">extern</span> <span class="tok-kw">var</span> __bss_start: <span class="tok-type">u8</span>;</span>
<span class="line" id="L22"><span class="tok-kw">extern</span> <span class="tok-kw">var</span> __bss_end: <span class="tok-type">u8</span>;</span>
<span class="line" id="L23"></span>
<span class="line" id="L24"><span class="tok-kw">fn</span> <span class="tok-fn">delay</span>() <span class="tok-type">void</span> {</span>
<span class="line" id="L25">    <span class="tok-kw">var</span> def_delay: <span class="tok-type">usize</span> = <span class="tok-number">1000000</span>;</span>
<span class="line" id="L26">    <span class="tok-kw">const</span> ptr: *<span class="tok-kw">volatile</span> <span class="tok-type">usize</span> = &amp;def_delay;</span>
<span class="line" id="L27"></span>
<span class="line" id="L28">    <span class="tok-kw">while</span> (def_delay &gt; <span class="tok-number">0</span>) {</span>
<span class="line" id="L29">        ptr.* -= <span class="tok-number">1</span>;</span>
<span class="line" id="L30">    }</span>
<span class="line" id="L31">}</span>
<span class="line" id="L32"></span>
<span class="line" id="L33"><span class="tok-kw">export</span> <span class="tok-kw">fn</span> <span class="tok-fn">zigMain</span>() <span class="tok-type">noreturn</span> {</span>
<span class="line" id="L34">    <span class="tok-comment">// zero BSS</span>
</span>
<span class="line" id="L35">    <span class="tok-builtin">@memset</span>(<span class="tok-builtin">@as</span>(*<span class="tok-kw">volatile</span> [<span class="tok-number">1</span>]<span class="tok-type">u8</span>, &amp;__bss_start), <span class="tok-number">0</span>, <span class="tok-builtin">@ptrToInt</span>(&amp;__bss_end) - <span class="tok-builtin">@ptrToInt</span>(&amp;__bss_start));</span>
<span class="line" id="L36">    <span class="tok-comment">// uart.uartInit();</span>
</span>
<span class="line" id="L37">    <span class="tok-kw">var</span> rk_gpio = gpio.Gpio.init(gpio.GpioBase.zero);</span>
<span class="line" id="L38">    <span class="tok-kw">const</span> led_mask = <span class="tok-builtin">@as</span>(<span class="tok-type">u32</span>, <span class="tok-number">0x800</span>);</span>
<span class="line" id="L39">    rk_gpio.dir.write(led_mask);</span>
<span class="line" id="L40">    <span class="tok-kw">while</span> (<span class="tok-null">true</span>) {</span>
<span class="line" id="L41">        rk_gpio.data.write(led_mask);</span>
<span class="line" id="L42">        delay();</span>
<span class="line" id="L43">        rk_gpio.data.write(<span class="tok-number">0</span>);</span>
<span class="line" id="L44">        delay();</span>
<span class="line" id="L45">    }</span>
<span class="line" id="L46">    <span class="tok-comment">//talker();</span>
</span>
<span class="line" id="L47">    <span class="tok-kw">unreachable</span>;</span>
<span class="line" id="L48">}</span>
<span class="line" id="L49"></span>
</code></pre></body>
</html>