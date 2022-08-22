<!doctype html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">    <title>gpio.zig - source view</title>
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
<span class="line" id="L2"><span class="tok-comment">/// A Gpio struct is made up of all the various MMIO registers associated with</span></span>
<span class="line" id="L3"><span class="tok-comment">/// a given GpioBase. See the RK3399 TRM for more info. Chapter 20 in my copy.</span></span>
<span class="line" id="L4"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> Gpio = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L5">    data: mmio.Register(<span class="tok-type">u32</span>, <span class="tok-type">u32</span>),</span>
<span class="line" id="L6">    dir: mmio.Register(<span class="tok-type">u32</span>, <span class="tok-type">u32</span>),</span>
<span class="line" id="L7"></span>
<span class="line" id="L8">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">init</span>(<span class="tok-kw">comptime</span> base: GpioBase) Gpio {</span>
<span class="line" id="L9">        <span class="tok-kw">return</span> Gpio{</span>
<span class="line" id="L10">            .data = mmio.Register(<span class="tok-type">u32</span>, <span class="tok-type">u32</span>).init(<span class="tok-builtin">@enumToInt</span>(base)),</span>
<span class="line" id="L11">            .dir = mmio.Register(<span class="tok-type">u32</span>, <span class="tok-type">u32</span>).init(<span class="tok-builtin">@enumToInt</span>(base) + <span class="tok-number">0x4</span>),</span>
<span class="line" id="L12">        };</span>
<span class="line" id="L13">    }</span>
<span class="line" id="L14">};</span>
<span class="line" id="L15"></span>
<span class="line" id="L16"><span class="tok-comment">/// A GpioBase is just an address to the base of a given set of GPIO MMIO</span></span>
<span class="line" id="L17"><span class="tok-comment">/// registers as defined in the RK3399 TRM chapter 20.</span></span>
<span class="line" id="L18"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> GpioBase = <span class="tok-kw">enum</span>(<span class="tok-type">u32</span>) {</span>
<span class="line" id="L19">    zero = <span class="tok-number">0xFF720000</span>,</span>
<span class="line" id="L20">    one = <span class="tok-number">0xFF730000</span>,</span>
<span class="line" id="L21">    two = <span class="tok-number">0xFF780000</span>,</span>
<span class="line" id="L22">    three = <span class="tok-number">0xFF788000</span>,</span>
<span class="line" id="L23">    four = <span class="tok-number">0xFF790000</span>,</span>
<span class="line" id="L24">};</span>
<span class="line" id="L25"></span>
</code></pre></body>
</html>