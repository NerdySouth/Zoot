<!doctype html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">    <title>math.zig - source view</title>
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
<pre><code><span class="line" id="L1"><span class="tok-kw">const</span> builtin = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;builtin&quot;</span>);</span>
<span class="line" id="L2"><span class="tok-kw">const</span> std = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;std.zig&quot;</span>);</span>
<span class="line" id="L3"><span class="tok-kw">const</span> assert = std.debug.assert;</span>
<span class="line" id="L4"><span class="tok-kw">const</span> mem = std.mem;</span>
<span class="line" id="L5"><span class="tok-kw">const</span> testing = std.testing;</span>
<span class="line" id="L6"></span>
<span class="line" id="L7"><span class="tok-comment">/// Euler's number (e)</span></span>
<span class="line" id="L8"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> e = <span class="tok-number">2.71828182845904523536028747135266249775724709369995</span>;</span>
<span class="line" id="L9"></span>
<span class="line" id="L10"><span class="tok-comment">/// Archimedes' constant (π)</span></span>
<span class="line" id="L11"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> pi = <span class="tok-number">3.14159265358979323846264338327950288419716939937510</span>;</span>
<span class="line" id="L12"></span>
<span class="line" id="L13"><span class="tok-comment">/// Phi or Golden ratio constant (Φ) = (1 + sqrt(5))/2</span></span>
<span class="line" id="L14"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> phi = <span class="tok-number">1.6180339887498948482045868343656381177203091798057628621</span>;</span>
<span class="line" id="L15"></span>
<span class="line" id="L16"><span class="tok-comment">/// Circle constant (τ)</span></span>
<span class="line" id="L17"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> tau = <span class="tok-number">2</span> * pi;</span>
<span class="line" id="L18"></span>
<span class="line" id="L19"><span class="tok-comment">/// log2(e)</span></span>
<span class="line" id="L20"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> log2e = <span class="tok-number">1.442695040888963407359924681001892137</span>;</span>
<span class="line" id="L21"></span>
<span class="line" id="L22"><span class="tok-comment">/// log10(e)</span></span>
<span class="line" id="L23"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> log10e = <span class="tok-number">0.434294481903251827651128918916605082</span>;</span>
<span class="line" id="L24"></span>
<span class="line" id="L25"><span class="tok-comment">/// ln(2)</span></span>
<span class="line" id="L26"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> ln2 = <span class="tok-number">0.693147180559945309417232121458176568</span>;</span>
<span class="line" id="L27"></span>
<span class="line" id="L28"><span class="tok-comment">/// ln(10)</span></span>
<span class="line" id="L29"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> ln10 = <span class="tok-number">2.302585092994045684017991454684364208</span>;</span>
<span class="line" id="L30"></span>
<span class="line" id="L31"><span class="tok-comment">/// 2/sqrt(π)</span></span>
<span class="line" id="L32"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> two_sqrtpi = <span class="tok-number">1.128379167095512573896158903121545172</span>;</span>
<span class="line" id="L33"></span>
<span class="line" id="L34"><span class="tok-comment">/// sqrt(2)</span></span>
<span class="line" id="L35"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> sqrt2 = <span class="tok-number">1.414213562373095048801688724209698079</span>;</span>
<span class="line" id="L36"></span>
<span class="line" id="L37"><span class="tok-comment">/// 1/sqrt(2)</span></span>
<span class="line" id="L38"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> sqrt1_2 = <span class="tok-number">0.707106781186547524400844362104849039</span>;</span>
<span class="line" id="L39"></span>
<span class="line" id="L40"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> floatExponentBits = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;math/float.zig&quot;</span>).floatExponentBits;</span>
<span class="line" id="L41"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> floatMantissaBits = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;math/float.zig&quot;</span>).floatMantissaBits;</span>
<span class="line" id="L42"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> floatFractionalBits = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;math/float.zig&quot;</span>).floatFractionalBits;</span>
<span class="line" id="L43"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> floatExponentMin = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;math/float.zig&quot;</span>).floatExponentMin;</span>
<span class="line" id="L44"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> floatExponentMax = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;math/float.zig&quot;</span>).floatExponentMax;</span>
<span class="line" id="L45"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> floatTrueMin = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;math/float.zig&quot;</span>).floatTrueMin;</span>
<span class="line" id="L46"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> floatMin = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;math/float.zig&quot;</span>).floatMin;</span>
<span class="line" id="L47"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> floatMax = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;math/float.zig&quot;</span>).floatMax;</span>
<span class="line" id="L48"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> floatEps = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;math/float.zig&quot;</span>).floatEps;</span>
<span class="line" id="L49"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> inf = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;math/float.zig&quot;</span>).inf;</span>
<span class="line" id="L50"></span>
<span class="line" id="L51"><span class="tok-comment">// TODO Replace with @compileError(&quot;deprecated for foobar&quot;) after 0.10.0 is released.</span>
</span>
<span class="line" id="L52"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> f16_true_min: <span class="tok-type">comptime_float</span> = floatTrueMin(<span class="tok-type">f16</span>); <span class="tok-comment">// prev: 0.000000059604644775390625</span>
</span>
<span class="line" id="L53"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> f32_true_min: <span class="tok-type">comptime_float</span> = floatTrueMin(<span class="tok-type">f32</span>); <span class="tok-comment">// prev: 1.40129846432481707092e-45</span>
</span>
<span class="line" id="L54"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> f64_true_min: <span class="tok-type">comptime_float</span> = floatTrueMin(<span class="tok-type">f64</span>); <span class="tok-comment">// prev: 4.94065645841246544177e-324</span>
</span>
<span class="line" id="L55"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> f80_true_min = floatTrueMin(f80); <span class="tok-comment">// prev: make_f80(.{ .fraction = 1, .exp = 0 })</span>
</span>
<span class="line" id="L56"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> f128_true_min = floatTrueMin(<span class="tok-type">f128</span>); <span class="tok-comment">// prev: @bitCast(f128, @as(u128, 0x00000000000000000000000000000001))</span>
</span>
<span class="line" id="L57"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> f16_min: <span class="tok-type">comptime_float</span> = floatMin(<span class="tok-type">f16</span>); <span class="tok-comment">// prev: 0.00006103515625</span>
</span>
<span class="line" id="L58"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> f32_min: <span class="tok-type">comptime_float</span> = floatMin(<span class="tok-type">f32</span>); <span class="tok-comment">// prev: 1.17549435082228750797e-38</span>
</span>
<span class="line" id="L59"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> f64_min: <span class="tok-type">comptime_float</span> = floatMin(<span class="tok-type">f64</span>); <span class="tok-comment">// prev: 2.2250738585072014e-308</span>
</span>
<span class="line" id="L60"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> f80_min = floatMin(f80); <span class="tok-comment">// prev: make_f80(.{ .fraction = 0x8000000000000000, .exp = 1 })</span>
</span>
<span class="line" id="L61"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> f128_min = floatMin(<span class="tok-type">f128</span>); <span class="tok-comment">// prev: @bitCast(f128, @as(u128, 0x00010000000000000000000000000000))</span>
</span>
<span class="line" id="L62"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> f16_max: <span class="tok-type">comptime_float</span> = floatMax(<span class="tok-type">f16</span>); <span class="tok-comment">// prev: 65504</span>
</span>
<span class="line" id="L63"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> f32_max: <span class="tok-type">comptime_float</span> = floatMax(<span class="tok-type">f32</span>); <span class="tok-comment">// prev: 3.40282346638528859812e+38</span>
</span>
<span class="line" id="L64"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> f64_max: <span class="tok-type">comptime_float</span> = floatMax(<span class="tok-type">f64</span>); <span class="tok-comment">// prev: 1.79769313486231570815e+308</span>
</span>
<span class="line" id="L65"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> f80_max = floatMax(f80); <span class="tok-comment">// prev: make_f80(.{ .fraction = 0xFFFFFFFFFFFFFFFF, .exp = 0x7FFE })</span>
</span>
<span class="line" id="L66"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> f128_max = floatMax(<span class="tok-type">f128</span>); <span class="tok-comment">// prev: @bitCast(f128, @as(u128, 0x7FFEFFFFFFFFFFFFFFFFFFFFFFFFFFFF))</span>
</span>
<span class="line" id="L67"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> f16_epsilon: <span class="tok-type">comptime_float</span> = floatEps(<span class="tok-type">f16</span>); <span class="tok-comment">// prev: 0.0009765625</span>
</span>
<span class="line" id="L68"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> f32_epsilon: <span class="tok-type">comptime_float</span> = floatEps(<span class="tok-type">f32</span>); <span class="tok-comment">// prev: 1.1920928955078125e-07</span>
</span>
<span class="line" id="L69"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> f64_epsilon: <span class="tok-type">comptime_float</span> = floatEps(<span class="tok-type">f64</span>); <span class="tok-comment">// prev: 2.22044604925031308085e-16</span>
</span>
<span class="line" id="L70"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> f80_epsilon = floatEps(f80); <span class="tok-comment">// prev: make_f80(.{ .fraction = 0x8000000000000000, .exp = 0x3FC0 })</span>
</span>
<span class="line" id="L71"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> f128_epsilon = floatEps(<span class="tok-type">f128</span>); <span class="tok-comment">// prev: @bitCast(f128, @as(u128, 0x3F8F0000000000000000000000000000))</span>
</span>
<span class="line" id="L72"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> f16_toint: <span class="tok-type">comptime_float</span> = <span class="tok-number">1.0</span> / f16_epsilon; <span class="tok-comment">// same as before</span>
</span>
<span class="line" id="L73"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> f32_toint: <span class="tok-type">comptime_float</span> = <span class="tok-number">1.0</span> / f32_epsilon; <span class="tok-comment">// same as before</span>
</span>
<span class="line" id="L74"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> f64_toint: <span class="tok-type">comptime_float</span> = <span class="tok-number">1.0</span> / f64_epsilon; <span class="tok-comment">// same as before</span>
</span>
<span class="line" id="L75"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> f80_toint = <span class="tok-number">1.0</span> / f80_epsilon; <span class="tok-comment">// same as before</span>
</span>
<span class="line" id="L76"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> f128_toint = <span class="tok-number">1.0</span> / f128_epsilon; <span class="tok-comment">// same as before</span>
</span>
<span class="line" id="L77"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> inf_u16 = <span class="tok-builtin">@bitCast</span>(<span class="tok-type">u16</span>, inf_f16); <span class="tok-comment">// prev: @as(u16, 0x7C00)</span>
</span>
<span class="line" id="L78"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> inf_f16 = inf(<span class="tok-type">f16</span>); <span class="tok-comment">// prev: @bitCast(f16, inf_u16)</span>
</span>
<span class="line" id="L79"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> inf_u32 = <span class="tok-builtin">@bitCast</span>(<span class="tok-type">u32</span>, inf_f32); <span class="tok-comment">// prev: @as(u32, 0x7F800000)</span>
</span>
<span class="line" id="L80"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> inf_f32 = inf(<span class="tok-type">f32</span>); <span class="tok-comment">// prev: @bitCast(f32, inf_u32)</span>
</span>
<span class="line" id="L81"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> inf_u64 = <span class="tok-builtin">@bitCast</span>(<span class="tok-type">u64</span>, inf_f64); <span class="tok-comment">// prev: @as(u64, 0x7FF &lt;&lt; 52)</span>
</span>
<span class="line" id="L82"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> inf_f64 = inf(<span class="tok-type">f64</span>); <span class="tok-comment">// prev: @bitCast(f64, inf_u64)</span>
</span>
<span class="line" id="L83"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> inf_f80 = inf(f80); <span class="tok-comment">// prev: make_f80(F80{ .fraction = 0x8000000000000000, .exp = 0x7fff })</span>
</span>
<span class="line" id="L84"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> inf_u128 = <span class="tok-builtin">@bitCast</span>(<span class="tok-type">u128</span>, inf_f128); <span class="tok-comment">// prev: @as(u128, 0x7fff0000000000000000000000000000)</span>
</span>
<span class="line" id="L85"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> inf_f128 = inf(<span class="tok-type">f128</span>); <span class="tok-comment">// prev: @bitCast(f128, inf_u128)</span>
</span>
<span class="line" id="L86"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> epsilon = floatEps;</span>
<span class="line" id="L87"><span class="tok-comment">// End of &quot;soft deprecated&quot; section</span>
</span>
<span class="line" id="L88"></span>
<span class="line" id="L89"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> nan_u16 = <span class="tok-builtin">@as</span>(<span class="tok-type">u16</span>, <span class="tok-number">0x7C01</span>);</span>
<span class="line" id="L90"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> nan_f16 = <span class="tok-builtin">@bitCast</span>(<span class="tok-type">f16</span>, nan_u16);</span>
<span class="line" id="L91"></span>
<span class="line" id="L92"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> qnan_u16 = <span class="tok-builtin">@as</span>(<span class="tok-type">u16</span>, <span class="tok-number">0x7E00</span>);</span>
<span class="line" id="L93"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> qnan_f16 = <span class="tok-builtin">@bitCast</span>(<span class="tok-type">f16</span>, qnan_u16);</span>
<span class="line" id="L94"></span>
<span class="line" id="L95"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> nan_u32 = <span class="tok-builtin">@as</span>(<span class="tok-type">u32</span>, <span class="tok-number">0x7F800001</span>);</span>
<span class="line" id="L96"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> nan_f32 = <span class="tok-builtin">@bitCast</span>(<span class="tok-type">f32</span>, nan_u32);</span>
<span class="line" id="L97"></span>
<span class="line" id="L98"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> qnan_u32 = <span class="tok-builtin">@as</span>(<span class="tok-type">u32</span>, <span class="tok-number">0x7FC00000</span>);</span>
<span class="line" id="L99"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> qnan_f32 = <span class="tok-builtin">@bitCast</span>(<span class="tok-type">f32</span>, qnan_u32);</span>
<span class="line" id="L100"></span>
<span class="line" id="L101"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> nan_u64 = <span class="tok-builtin">@as</span>(<span class="tok-type">u64</span>, <span class="tok-number">0x7FF</span> &lt;&lt; <span class="tok-number">52</span>) | <span class="tok-number">1</span>;</span>
<span class="line" id="L102"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> nan_f64 = <span class="tok-builtin">@bitCast</span>(<span class="tok-type">f64</span>, nan_u64);</span>
<span class="line" id="L103"></span>
<span class="line" id="L104"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> qnan_u64 = <span class="tok-builtin">@as</span>(<span class="tok-type">u64</span>, <span class="tok-number">0x7ff8000000000000</span>);</span>
<span class="line" id="L105"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> qnan_f64 = <span class="tok-builtin">@bitCast</span>(<span class="tok-type">f64</span>, qnan_u64);</span>
<span class="line" id="L106"></span>
<span class="line" id="L107"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> nan_f80 = make_f80(F80{ .fraction = <span class="tok-number">0xA000000000000000</span>, .exp = <span class="tok-number">0x7fff</span> });</span>
<span class="line" id="L108"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> qnan_f80 = make_f80(F80{ .fraction = <span class="tok-number">0xC000000000000000</span>, .exp = <span class="tok-number">0x7fff</span> });</span>
<span class="line" id="L109"></span>
<span class="line" id="L110"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> nan_u128 = <span class="tok-builtin">@as</span>(<span class="tok-type">u128</span>, <span class="tok-number">0x7fff0000000000000000000000000001</span>);</span>
<span class="line" id="L111"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> nan_f128 = <span class="tok-builtin">@bitCast</span>(<span class="tok-type">f128</span>, nan_u128);</span>
<span class="line" id="L112"></span>
<span class="line" id="L113"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> qnan_u128 = <span class="tok-builtin">@as</span>(<span class="tok-type">u128</span>, <span class="tok-number">0x7fff8000000000000000000000000000</span>);</span>
<span class="line" id="L114"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> qnan_f128 = <span class="tok-builtin">@bitCast</span>(<span class="tok-type">f128</span>, qnan_u128);</span>
<span class="line" id="L115"></span>
<span class="line" id="L116"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> nan = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;math/nan.zig&quot;</span>).nan;</span>
<span class="line" id="L117"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> snan = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;math/nan.zig&quot;</span>).snan;</span>
<span class="line" id="L118"></span>
<span class="line" id="L119"><span class="tok-comment">/// Performs an approximate comparison of two floating point values `x` and `y`.</span></span>
<span class="line" id="L120"><span class="tok-comment">/// Returns true if the absolute difference between them is less or equal than</span></span>
<span class="line" id="L121"><span class="tok-comment">/// the specified tolerance.</span></span>
<span class="line" id="L122"><span class="tok-comment">///</span></span>
<span class="line" id="L123"><span class="tok-comment">/// The `tolerance` parameter is the absolute tolerance used when determining if</span></span>
<span class="line" id="L124"><span class="tok-comment">/// the two numbers are close enough; a good value for this parameter is a small</span></span>
<span class="line" id="L125"><span class="tok-comment">/// multiple of `floatEps(T)`.</span></span>
<span class="line" id="L126"><span class="tok-comment">///</span></span>
<span class="line" id="L127"><span class="tok-comment">/// Note that this function is recommended for comparing small numbers</span></span>
<span class="line" id="L128"><span class="tok-comment">/// around zero; using `approxEqRel` is suggested otherwise.</span></span>
<span class="line" id="L129"><span class="tok-comment">///</span></span>
<span class="line" id="L130"><span class="tok-comment">/// NaN values are never considered equal to any value.</span></span>
<span class="line" id="L131"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">approxEqAbs</span>(<span class="tok-kw">comptime</span> T: <span class="tok-type">type</span>, x: T, y: T, tolerance: T) <span class="tok-type">bool</span> {</span>
<span class="line" id="L132">    assert(<span class="tok-builtin">@typeInfo</span>(T) == .Float);</span>
<span class="line" id="L133">    assert(tolerance &gt;= <span class="tok-number">0</span>);</span>
<span class="line" id="L134"></span>
<span class="line" id="L135">    <span class="tok-comment">// Fast path for equal values (and signed zeros and infinites).</span>
</span>
<span class="line" id="L136">    <span class="tok-kw">if</span> (x == y)</span>
<span class="line" id="L137">        <span class="tok-kw">return</span> <span class="tok-null">true</span>;</span>
<span class="line" id="L138"></span>
<span class="line" id="L139">    <span class="tok-kw">if</span> (isNan(x) <span class="tok-kw">or</span> isNan(y))</span>
<span class="line" id="L140">        <span class="tok-kw">return</span> <span class="tok-null">false</span>;</span>
<span class="line" id="L141"></span>
<span class="line" id="L142">    <span class="tok-kw">return</span> <span class="tok-builtin">@fabs</span>(x - y) &lt;= tolerance;</span>
<span class="line" id="L143">}</span>
<span class="line" id="L144"></span>
<span class="line" id="L145"><span class="tok-comment">/// Performs an approximate comparison of two floating point values `x` and `y`.</span></span>
<span class="line" id="L146"><span class="tok-comment">/// Returns true if the absolute difference between them is less or equal than</span></span>
<span class="line" id="L147"><span class="tok-comment">/// `max(|x|, |y|) * tolerance`, where `tolerance` is a positive number greater</span></span>
<span class="line" id="L148"><span class="tok-comment">/// than zero.</span></span>
<span class="line" id="L149"><span class="tok-comment">///</span></span>
<span class="line" id="L150"><span class="tok-comment">/// The `tolerance` parameter is the relative tolerance used when determining if</span></span>
<span class="line" id="L151"><span class="tok-comment">/// the two numbers are close enough; a good value for this parameter is usually</span></span>
<span class="line" id="L152"><span class="tok-comment">/// `sqrt(floatEps(T))`, meaning that the two numbers are considered equal if at</span></span>
<span class="line" id="L153"><span class="tok-comment">/// least half of the digits are equal.</span></span>
<span class="line" id="L154"><span class="tok-comment">///</span></span>
<span class="line" id="L155"><span class="tok-comment">/// Note that for comparisons of small numbers around zero this function won't</span></span>
<span class="line" id="L156"><span class="tok-comment">/// give meaningful results, use `approxEqAbs` instead.</span></span>
<span class="line" id="L157"><span class="tok-comment">///</span></span>
<span class="line" id="L158"><span class="tok-comment">/// NaN values are never considered equal to any value.</span></span>
<span class="line" id="L159"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">approxEqRel</span>(<span class="tok-kw">comptime</span> T: <span class="tok-type">type</span>, x: T, y: T, tolerance: T) <span class="tok-type">bool</span> {</span>
<span class="line" id="L160">    assert(<span class="tok-builtin">@typeInfo</span>(T) == .Float);</span>
<span class="line" id="L161">    assert(tolerance &gt; <span class="tok-number">0</span>);</span>
<span class="line" id="L162"></span>
<span class="line" id="L163">    <span class="tok-comment">// Fast path for equal values (and signed zeros and infinites).</span>
</span>
<span class="line" id="L164">    <span class="tok-kw">if</span> (x == y)</span>
<span class="line" id="L165">        <span class="tok-kw">return</span> <span class="tok-null">true</span>;</span>
<span class="line" id="L166"></span>
<span class="line" id="L167">    <span class="tok-kw">if</span> (isNan(x) <span class="tok-kw">or</span> isNan(y))</span>
<span class="line" id="L168">        <span class="tok-kw">return</span> <span class="tok-null">false</span>;</span>
<span class="line" id="L169"></span>
<span class="line" id="L170">    <span class="tok-kw">return</span> <span class="tok-builtin">@fabs</span>(x - y) &lt;= max(<span class="tok-builtin">@fabs</span>(x), <span class="tok-builtin">@fabs</span>(y)) * tolerance;</span>
<span class="line" id="L171">}</span>
<span class="line" id="L172"></span>
<span class="line" id="L173"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">approxEq</span>(<span class="tok-kw">comptime</span> T: <span class="tok-type">type</span>, x: T, y: T, tolerance: T) <span class="tok-type">bool</span> {</span>
<span class="line" id="L174">    _ = T;</span>
<span class="line" id="L175">    _ = x;</span>
<span class="line" id="L176">    _ = y;</span>
<span class="line" id="L177">    _ = tolerance;</span>
<span class="line" id="L178">    <span class="tok-builtin">@compileError</span>(<span class="tok-str">&quot;deprecated; use `approxEqAbs` or `approxEqRel`&quot;</span>);</span>
<span class="line" id="L179">}</span>
<span class="line" id="L180"></span>
<span class="line" id="L181"><span class="tok-kw">test</span> <span class="tok-str">&quot;approxEqAbs and approxEqRel&quot;</span> {</span>
<span class="line" id="L182">    <span class="tok-kw">inline</span> <span class="tok-kw">for</span> ([_]<span class="tok-type">type</span>{ <span class="tok-type">f16</span>, <span class="tok-type">f32</span>, <span class="tok-type">f64</span>, <span class="tok-type">f128</span> }) |T| {</span>
<span class="line" id="L183">        <span class="tok-kw">const</span> eps_value = <span class="tok-kw">comptime</span> floatEps(T);</span>
<span class="line" id="L184">        <span class="tok-kw">const</span> sqrt_eps_value = <span class="tok-kw">comptime</span> sqrt(eps_value);</span>
<span class="line" id="L185">        <span class="tok-kw">const</span> nan_value = <span class="tok-kw">comptime</span> nan(T);</span>
<span class="line" id="L186">        <span class="tok-kw">const</span> inf_value = <span class="tok-kw">comptime</span> inf(T);</span>
<span class="line" id="L187">        <span class="tok-kw">const</span> min_value = <span class="tok-kw">comptime</span> floatMin(T);</span>
<span class="line" id="L188"></span>
<span class="line" id="L189">        <span class="tok-kw">try</span> testing.expect(approxEqAbs(T, <span class="tok-number">0.0</span>, <span class="tok-number">0.0</span>, eps_value));</span>
<span class="line" id="L190">        <span class="tok-kw">try</span> testing.expect(approxEqAbs(T, -<span class="tok-number">0.0</span>, -<span class="tok-number">0.0</span>, eps_value));</span>
<span class="line" id="L191">        <span class="tok-kw">try</span> testing.expect(approxEqAbs(T, <span class="tok-number">0.0</span>, -<span class="tok-number">0.0</span>, eps_value));</span>
<span class="line" id="L192">        <span class="tok-kw">try</span> testing.expect(approxEqRel(T, <span class="tok-number">1.0</span>, <span class="tok-number">1.0</span>, sqrt_eps_value));</span>
<span class="line" id="L193">        <span class="tok-kw">try</span> testing.expect(!approxEqRel(T, <span class="tok-number">1.0</span>, <span class="tok-number">0.0</span>, sqrt_eps_value));</span>
<span class="line" id="L194">        <span class="tok-kw">try</span> testing.expect(!approxEqAbs(T, <span class="tok-number">1.0</span> + <span class="tok-number">2</span> * eps_value, <span class="tok-number">1.0</span>, eps_value));</span>
<span class="line" id="L195">        <span class="tok-kw">try</span> testing.expect(approxEqAbs(T, <span class="tok-number">1.0</span> + <span class="tok-number">1</span> * eps_value, <span class="tok-number">1.0</span>, eps_value));</span>
<span class="line" id="L196">        <span class="tok-kw">try</span> testing.expect(!approxEqRel(T, <span class="tok-number">1.0</span>, nan_value, sqrt_eps_value));</span>
<span class="line" id="L197">        <span class="tok-kw">try</span> testing.expect(!approxEqRel(T, nan_value, nan_value, sqrt_eps_value));</span>
<span class="line" id="L198">        <span class="tok-kw">try</span> testing.expect(approxEqRel(T, inf_value, inf_value, sqrt_eps_value));</span>
<span class="line" id="L199">        <span class="tok-kw">try</span> testing.expect(approxEqRel(T, min_value, min_value, sqrt_eps_value));</span>
<span class="line" id="L200">        <span class="tok-kw">try</span> testing.expect(approxEqRel(T, -min_value, -min_value, sqrt_eps_value));</span>
<span class="line" id="L201">        <span class="tok-kw">try</span> testing.expect(approxEqAbs(T, min_value, <span class="tok-number">0.0</span>, eps_value * <span class="tok-number">2</span>));</span>
<span class="line" id="L202">        <span class="tok-kw">try</span> testing.expect(approxEqAbs(T, -min_value, <span class="tok-number">0.0</span>, eps_value * <span class="tok-number">2</span>));</span>
<span class="line" id="L203">    }</span>
<span class="line" id="L204">}</span>
<span class="line" id="L205"></span>
<span class="line" id="L206"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">doNotOptimizeAway</span>(value: <span class="tok-kw">anytype</span>) <span class="tok-type">void</span> {</span>
<span class="line" id="L207">    <span class="tok-comment">// TODO: use @declareSideEffect() when it is available.</span>
</span>
<span class="line" id="L208">    <span class="tok-comment">// https://github.com/ziglang/zig/issues/6168</span>
</span>
<span class="line" id="L209">    <span class="tok-kw">const</span> T = <span class="tok-builtin">@TypeOf</span>(value);</span>
<span class="line" id="L210">    <span class="tok-kw">var</span> x: T = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L211">    <span class="tok-kw">const</span> p = <span class="tok-builtin">@ptrCast</span>(*<span class="tok-kw">volatile</span> T, &amp;x);</span>
<span class="line" id="L212">    p.* = x;</span>
<span class="line" id="L213">}</span>
<span class="line" id="L214"></span>
<span class="line" id="L215"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">raiseInvalid</span>() <span class="tok-type">void</span> {</span>
<span class="line" id="L216">    <span class="tok-comment">// Raise INVALID fpu exception</span>
</span>
<span class="line" id="L217">}</span>
<span class="line" id="L218"></span>
<span class="line" id="L219"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">raiseUnderflow</span>() <span class="tok-type">void</span> {</span>
<span class="line" id="L220">    <span class="tok-comment">// Raise UNDERFLOW fpu exception</span>
</span>
<span class="line" id="L221">}</span>
<span class="line" id="L222"></span>
<span class="line" id="L223"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">raiseOverflow</span>() <span class="tok-type">void</span> {</span>
<span class="line" id="L224">    <span class="tok-comment">// Raise OVERFLOW fpu exception</span>
</span>
<span class="line" id="L225">}</span>
<span class="line" id="L226"></span>
<span class="line" id="L227"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">raiseInexact</span>() <span class="tok-type">void</span> {</span>
<span class="line" id="L228">    <span class="tok-comment">// Raise INEXACT fpu exception</span>
</span>
<span class="line" id="L229">}</span>
<span class="line" id="L230"></span>
<span class="line" id="L231"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">raiseDivByZero</span>() <span class="tok-type">void</span> {</span>
<span class="line" id="L232">    <span class="tok-comment">// Raise INEXACT fpu exception</span>
</span>
<span class="line" id="L233">}</span>
<span class="line" id="L234"></span>
<span class="line" id="L235"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> isNan = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;math/isnan.zig&quot;</span>).isNan;</span>
<span class="line" id="L236"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> isSignalNan = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;math/isnan.zig&quot;</span>).isSignalNan;</span>
<span class="line" id="L237"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> frexp = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;math/frexp.zig&quot;</span>).frexp;</span>
<span class="line" id="L238"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> Frexp = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;math/frexp.zig&quot;</span>).Frexp;</span>
<span class="line" id="L239"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> modf = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;math/modf.zig&quot;</span>).modf;</span>
<span class="line" id="L240"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> modf32_result = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;math/modf.zig&quot;</span>).modf32_result;</span>
<span class="line" id="L241"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> modf64_result = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;math/modf.zig&quot;</span>).modf64_result;</span>
<span class="line" id="L242"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> copysign = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;math/copysign.zig&quot;</span>).copysign;</span>
<span class="line" id="L243"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> isFinite = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;math/isfinite.zig&quot;</span>).isFinite;</span>
<span class="line" id="L244"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> isInf = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;math/isinf.zig&quot;</span>).isInf;</span>
<span class="line" id="L245"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> isPositiveInf = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;math/isinf.zig&quot;</span>).isPositiveInf;</span>
<span class="line" id="L246"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> isNegativeInf = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;math/isinf.zig&quot;</span>).isNegativeInf;</span>
<span class="line" id="L247"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> isNormal = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;math/isnormal.zig&quot;</span>).isNormal;</span>
<span class="line" id="L248"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> signbit = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;math/signbit.zig&quot;</span>).signbit;</span>
<span class="line" id="L249"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> scalbn = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;math/scalbn.zig&quot;</span>).scalbn;</span>
<span class="line" id="L250"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> ldexp = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;math/ldexp.zig&quot;</span>).ldexp;</span>
<span class="line" id="L251"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> pow = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;math/pow.zig&quot;</span>).pow;</span>
<span class="line" id="L252"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> powi = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;math/powi.zig&quot;</span>).powi;</span>
<span class="line" id="L253"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> sqrt = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;math/sqrt.zig&quot;</span>).sqrt;</span>
<span class="line" id="L254"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> cbrt = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;math/cbrt.zig&quot;</span>).cbrt;</span>
<span class="line" id="L255"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> acos = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;math/acos.zig&quot;</span>).acos;</span>
<span class="line" id="L256"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> asin = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;math/asin.zig&quot;</span>).asin;</span>
<span class="line" id="L257"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> atan = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;math/atan.zig&quot;</span>).atan;</span>
<span class="line" id="L258"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> atan2 = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;math/atan2.zig&quot;</span>).atan2;</span>
<span class="line" id="L259"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> hypot = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;math/hypot.zig&quot;</span>).hypot;</span>
<span class="line" id="L260"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> expm1 = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;math/expm1.zig&quot;</span>).expm1;</span>
<span class="line" id="L261"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> ilogb = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;math/ilogb.zig&quot;</span>).ilogb;</span>
<span class="line" id="L262"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> ln = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;math/ln.zig&quot;</span>).ln;</span>
<span class="line" id="L263"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> log = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;math/log.zig&quot;</span>).log;</span>
<span class="line" id="L264"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> log2 = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;math/log2.zig&quot;</span>).log2;</span>
<span class="line" id="L265"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> log10 = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;math/log10.zig&quot;</span>).log10;</span>
<span class="line" id="L266"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> log1p = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;math/log1p.zig&quot;</span>).log1p;</span>
<span class="line" id="L267"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> asinh = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;math/asinh.zig&quot;</span>).asinh;</span>
<span class="line" id="L268"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> acosh = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;math/acosh.zig&quot;</span>).acosh;</span>
<span class="line" id="L269"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> atanh = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;math/atanh.zig&quot;</span>).atanh;</span>
<span class="line" id="L270"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> sinh = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;math/sinh.zig&quot;</span>).sinh;</span>
<span class="line" id="L271"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> cosh = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;math/cosh.zig&quot;</span>).cosh;</span>
<span class="line" id="L272"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> tanh = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;math/tanh.zig&quot;</span>).tanh;</span>
<span class="line" id="L273"></span>
<span class="line" id="L274"><span class="tok-comment">/// Sine trigonometric function on a floating point number.</span></span>
<span class="line" id="L275"><span class="tok-comment">/// Uses a dedicated hardware instruction when available.</span></span>
<span class="line" id="L276"><span class="tok-comment">/// This is the same as calling the builtin @sin</span></span>
<span class="line" id="L277"><span class="tok-kw">pub</span> <span class="tok-kw">inline</span> <span class="tok-kw">fn</span> <span class="tok-fn">sin</span>(value: <span class="tok-kw">anytype</span>) <span class="tok-builtin">@TypeOf</span>(value) {</span>
<span class="line" id="L278">    <span class="tok-kw">return</span> <span class="tok-builtin">@sin</span>(value);</span>
<span class="line" id="L279">}</span>
<span class="line" id="L280"></span>
<span class="line" id="L281"><span class="tok-comment">/// Cosine trigonometric function on a floating point number.</span></span>
<span class="line" id="L282"><span class="tok-comment">/// Uses a dedicated hardware instruction when available.</span></span>
<span class="line" id="L283"><span class="tok-comment">/// This is the same as calling the builtin @cos</span></span>
<span class="line" id="L284"><span class="tok-kw">pub</span> <span class="tok-kw">inline</span> <span class="tok-kw">fn</span> <span class="tok-fn">cos</span>(value: <span class="tok-kw">anytype</span>) <span class="tok-builtin">@TypeOf</span>(value) {</span>
<span class="line" id="L285">    <span class="tok-kw">return</span> <span class="tok-builtin">@cos</span>(value);</span>
<span class="line" id="L286">}</span>
<span class="line" id="L287"></span>
<span class="line" id="L288"><span class="tok-comment">/// Tangent trigonometric function on a floating point number.</span></span>
<span class="line" id="L289"><span class="tok-comment">/// Uses a dedicated hardware instruction when available.</span></span>
<span class="line" id="L290"><span class="tok-comment">/// This is the same as calling the builtin @tan</span></span>
<span class="line" id="L291"><span class="tok-kw">pub</span> <span class="tok-kw">inline</span> <span class="tok-kw">fn</span> <span class="tok-fn">tan</span>(value: <span class="tok-kw">anytype</span>) <span class="tok-builtin">@TypeOf</span>(value) {</span>
<span class="line" id="L292">    <span class="tok-kw">return</span> <span class="tok-builtin">@tan</span>(value);</span>
<span class="line" id="L293">}</span>
<span class="line" id="L294"></span>
<span class="line" id="L295"><span class="tok-comment">// Convert an angle in radians to degrees. T must be a float type.</span>
</span>
<span class="line" id="L296"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">radiansToDegrees</span>(<span class="tok-kw">comptime</span> T: <span class="tok-type">type</span>, angle_in_radians: T) T {</span>
<span class="line" id="L297">    <span class="tok-kw">if</span> (<span class="tok-builtin">@typeInfo</span>(T) != .Float)</span>
<span class="line" id="L298">        <span class="tok-builtin">@compileError</span>(<span class="tok-str">&quot;T must be a float type.&quot;</span>);</span>
<span class="line" id="L299">    <span class="tok-kw">return</span> angle_in_radians * <span class="tok-number">180.0</span> / pi;</span>
<span class="line" id="L300">}</span>
<span class="line" id="L301"></span>
<span class="line" id="L302"><span class="tok-kw">test</span> <span class="tok-str">&quot;radiansToDegrees&quot;</span> {</span>
<span class="line" id="L303">    <span class="tok-kw">try</span> std.testing.expectApproxEqAbs(<span class="tok-builtin">@as</span>(<span class="tok-type">f32</span>, <span class="tok-number">0</span>), radiansToDegrees(<span class="tok-type">f32</span>, <span class="tok-number">0</span>), <span class="tok-number">1e-6</span>);</span>
<span class="line" id="L304">    <span class="tok-kw">try</span> std.testing.expectApproxEqAbs(<span class="tok-builtin">@as</span>(<span class="tok-type">f32</span>, <span class="tok-number">90</span>), radiansToDegrees(<span class="tok-type">f32</span>, pi / <span class="tok-number">2.0</span>), <span class="tok-number">1e-6</span>);</span>
<span class="line" id="L305">    <span class="tok-kw">try</span> std.testing.expectApproxEqAbs(<span class="tok-builtin">@as</span>(<span class="tok-type">f32</span>, -<span class="tok-number">45</span>), radiansToDegrees(<span class="tok-type">f32</span>, -pi / <span class="tok-number">4.0</span>), <span class="tok-number">1e-6</span>);</span>
<span class="line" id="L306">    <span class="tok-kw">try</span> std.testing.expectApproxEqAbs(<span class="tok-builtin">@as</span>(<span class="tok-type">f32</span>, <span class="tok-number">180</span>), radiansToDegrees(<span class="tok-type">f32</span>, pi), <span class="tok-number">1e-6</span>);</span>
<span class="line" id="L307">    <span class="tok-kw">try</span> std.testing.expectApproxEqAbs(<span class="tok-builtin">@as</span>(<span class="tok-type">f32</span>, <span class="tok-number">360</span>), radiansToDegrees(<span class="tok-type">f32</span>, <span class="tok-number">2.0</span> * pi), <span class="tok-number">1e-6</span>);</span>
<span class="line" id="L308">}</span>
<span class="line" id="L309"></span>
<span class="line" id="L310"><span class="tok-comment">// Convert an angle in degrees to radians. T must be a float type.</span>
</span>
<span class="line" id="L311"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">degreesToRadians</span>(<span class="tok-kw">comptime</span> T: <span class="tok-type">type</span>, angle_in_degrees: T) T {</span>
<span class="line" id="L312">    <span class="tok-kw">if</span> (<span class="tok-builtin">@typeInfo</span>(T) != .Float)</span>
<span class="line" id="L313">        <span class="tok-builtin">@compileError</span>(<span class="tok-str">&quot;T must be a float type.&quot;</span>);</span>
<span class="line" id="L314">    <span class="tok-kw">return</span> angle_in_degrees * pi / <span class="tok-number">180.0</span>;</span>
<span class="line" id="L315">}</span>
<span class="line" id="L316"></span>
<span class="line" id="L317"><span class="tok-kw">test</span> <span class="tok-str">&quot;degreesToRadians&quot;</span> {</span>
<span class="line" id="L318">    <span class="tok-kw">try</span> std.testing.expectApproxEqAbs(<span class="tok-builtin">@as</span>(<span class="tok-type">f32</span>, pi / <span class="tok-number">2.0</span>), degreesToRadians(<span class="tok-type">f32</span>, <span class="tok-number">90</span>), <span class="tok-number">1e-6</span>);</span>
<span class="line" id="L319">    <span class="tok-kw">try</span> std.testing.expectApproxEqAbs(<span class="tok-builtin">@as</span>(<span class="tok-type">f32</span>, -<span class="tok-number">3</span> * pi / <span class="tok-number">2.0</span>), degreesToRadians(<span class="tok-type">f32</span>, -<span class="tok-number">270</span>), <span class="tok-number">1e-6</span>);</span>
<span class="line" id="L320">    <span class="tok-kw">try</span> std.testing.expectApproxEqAbs(<span class="tok-builtin">@as</span>(<span class="tok-type">f32</span>, <span class="tok-number">2</span> * pi), degreesToRadians(<span class="tok-type">f32</span>, <span class="tok-number">360</span>), <span class="tok-number">1e-6</span>);</span>
<span class="line" id="L321">}</span>
<span class="line" id="L322"></span>
<span class="line" id="L323"><span class="tok-comment">/// Base-e exponential function on a floating point number.</span></span>
<span class="line" id="L324"><span class="tok-comment">/// Uses a dedicated hardware instruction when available.</span></span>
<span class="line" id="L325"><span class="tok-comment">/// This is the same as calling the builtin @exp</span></span>
<span class="line" id="L326"><span class="tok-kw">pub</span> <span class="tok-kw">inline</span> <span class="tok-kw">fn</span> <span class="tok-fn">exp</span>(value: <span class="tok-kw">anytype</span>) <span class="tok-builtin">@TypeOf</span>(value) {</span>
<span class="line" id="L327">    <span class="tok-kw">return</span> <span class="tok-builtin">@exp</span>(value);</span>
<span class="line" id="L328">}</span>
<span class="line" id="L329"></span>
<span class="line" id="L330"><span class="tok-comment">/// Base-2 exponential function on a floating point number.</span></span>
<span class="line" id="L331"><span class="tok-comment">/// Uses a dedicated hardware instruction when available.</span></span>
<span class="line" id="L332"><span class="tok-comment">/// This is the same as calling the builtin @exp2</span></span>
<span class="line" id="L333"><span class="tok-kw">pub</span> <span class="tok-kw">inline</span> <span class="tok-kw">fn</span> <span class="tok-fn">exp2</span>(value: <span class="tok-kw">anytype</span>) <span class="tok-builtin">@TypeOf</span>(value) {</span>
<span class="line" id="L334">    <span class="tok-kw">return</span> <span class="tok-builtin">@exp2</span>(value);</span>
<span class="line" id="L335">}</span>
<span class="line" id="L336"></span>
<span class="line" id="L337"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> complex = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;math/complex.zig&quot;</span>);</span>
<span class="line" id="L338"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> Complex = complex.Complex;</span>
<span class="line" id="L339"></span>
<span class="line" id="L340"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> big = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;math/big.zig&quot;</span>);</span>
<span class="line" id="L341"></span>
<span class="line" id="L342"><span class="tok-kw">test</span> {</span>
<span class="line" id="L343">    std.testing.refAllDecls(<span class="tok-builtin">@This</span>());</span>
<span class="line" id="L344">}</span>
<span class="line" id="L345"></span>
<span class="line" id="L346"><span class="tok-comment">/// Given two types, returns the smallest one which is capable of holding the</span></span>
<span class="line" id="L347"><span class="tok-comment">/// full range of the minimum value.</span></span>
<span class="line" id="L348"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">Min</span>(<span class="tok-kw">comptime</span> A: <span class="tok-type">type</span>, <span class="tok-kw">comptime</span> B: <span class="tok-type">type</span>) <span class="tok-type">type</span> {</span>
<span class="line" id="L349">    <span class="tok-kw">switch</span> (<span class="tok-builtin">@typeInfo</span>(A)) {</span>
<span class="line" id="L350">        .Int =&gt; |a_info| <span class="tok-kw">switch</span> (<span class="tok-builtin">@typeInfo</span>(B)) {</span>
<span class="line" id="L351">            .Int =&gt; |b_info| <span class="tok-kw">if</span> (a_info.signedness == .unsigned <span class="tok-kw">and</span> b_info.signedness == .unsigned) {</span>
<span class="line" id="L352">                <span class="tok-kw">if</span> (a_info.bits &lt; b_info.bits) {</span>
<span class="line" id="L353">                    <span class="tok-kw">return</span> A;</span>
<span class="line" id="L354">                } <span class="tok-kw">else</span> {</span>
<span class="line" id="L355">                    <span class="tok-kw">return</span> B;</span>
<span class="line" id="L356">                }</span>
<span class="line" id="L357">            },</span>
<span class="line" id="L358">            <span class="tok-kw">else</span> =&gt; {},</span>
<span class="line" id="L359">        },</span>
<span class="line" id="L360">        <span class="tok-kw">else</span> =&gt; {},</span>
<span class="line" id="L361">    }</span>
<span class="line" id="L362">    <span class="tok-kw">return</span> <span class="tok-builtin">@TypeOf</span>(<span class="tok-builtin">@as</span>(A, <span class="tok-number">0</span>) + <span class="tok-builtin">@as</span>(B, <span class="tok-number">0</span>));</span>
<span class="line" id="L363">}</span>
<span class="line" id="L364"></span>
<span class="line" id="L365"><span class="tok-comment">/// Returns the smaller number. When one parameter's type's full range</span></span>
<span class="line" id="L366"><span class="tok-comment">/// fits in the other, the return type is the smaller type.</span></span>
<span class="line" id="L367"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">min</span>(x: <span class="tok-kw">anytype</span>, y: <span class="tok-kw">anytype</span>) Min(<span class="tok-builtin">@TypeOf</span>(x), <span class="tok-builtin">@TypeOf</span>(y)) {</span>
<span class="line" id="L368">    <span class="tok-kw">const</span> Result = Min(<span class="tok-builtin">@TypeOf</span>(x), <span class="tok-builtin">@TypeOf</span>(y));</span>
<span class="line" id="L369">    <span class="tok-kw">if</span> (x &lt; y) {</span>
<span class="line" id="L370">        <span class="tok-comment">// TODO Zig should allow this as an implicit cast because x is</span>
</span>
<span class="line" id="L371">        <span class="tok-comment">// immutable and in this scope it is known to fit in the</span>
</span>
<span class="line" id="L372">        <span class="tok-comment">// return type.</span>
</span>
<span class="line" id="L373">        <span class="tok-kw">switch</span> (<span class="tok-builtin">@typeInfo</span>(Result)) {</span>
<span class="line" id="L374">            .Int =&gt; <span class="tok-kw">return</span> <span class="tok-builtin">@intCast</span>(Result, x),</span>
<span class="line" id="L375">            <span class="tok-kw">else</span> =&gt; <span class="tok-kw">return</span> x,</span>
<span class="line" id="L376">        }</span>
<span class="line" id="L377">    } <span class="tok-kw">else</span> {</span>
<span class="line" id="L378">        <span class="tok-comment">// TODO Zig should allow this as an implicit cast because y is</span>
</span>
<span class="line" id="L379">        <span class="tok-comment">// immutable and in this scope it is known to fit in the</span>
</span>
<span class="line" id="L380">        <span class="tok-comment">// return type.</span>
</span>
<span class="line" id="L381">        <span class="tok-kw">switch</span> (<span class="tok-builtin">@typeInfo</span>(Result)) {</span>
<span class="line" id="L382">            .Int =&gt; <span class="tok-kw">return</span> <span class="tok-builtin">@intCast</span>(Result, y),</span>
<span class="line" id="L383">            <span class="tok-kw">else</span> =&gt; <span class="tok-kw">return</span> y,</span>
<span class="line" id="L384">        }</span>
<span class="line" id="L385">    }</span>
<span class="line" id="L386">}</span>
<span class="line" id="L387"></span>
<span class="line" id="L388"><span class="tok-kw">test</span> <span class="tok-str">&quot;min&quot;</span> {</span>
<span class="line" id="L389">    <span class="tok-kw">try</span> testing.expect(min(<span class="tok-builtin">@as</span>(<span class="tok-type">i32</span>, -<span class="tok-number">1</span>), <span class="tok-builtin">@as</span>(<span class="tok-type">i32</span>, <span class="tok-number">2</span>)) == -<span class="tok-number">1</span>);</span>
<span class="line" id="L390">    {</span>
<span class="line" id="L391">        <span class="tok-kw">var</span> a: <span class="tok-type">u16</span> = <span class="tok-number">999</span>;</span>
<span class="line" id="L392">        <span class="tok-kw">var</span> b: <span class="tok-type">u32</span> = <span class="tok-number">10</span>;</span>
<span class="line" id="L393">        <span class="tok-kw">var</span> result = min(a, b);</span>
<span class="line" id="L394">        <span class="tok-kw">try</span> testing.expect(<span class="tok-builtin">@TypeOf</span>(result) == <span class="tok-type">u16</span>);</span>
<span class="line" id="L395">        <span class="tok-kw">try</span> testing.expect(result == <span class="tok-number">10</span>);</span>
<span class="line" id="L396">    }</span>
<span class="line" id="L397">    {</span>
<span class="line" id="L398">        <span class="tok-kw">var</span> a: <span class="tok-type">f64</span> = <span class="tok-number">10.34</span>;</span>
<span class="line" id="L399">        <span class="tok-kw">var</span> b: <span class="tok-type">f32</span> = <span class="tok-number">999.12</span>;</span>
<span class="line" id="L400">        <span class="tok-kw">var</span> result = min(a, b);</span>
<span class="line" id="L401">        <span class="tok-kw">try</span> testing.expect(<span class="tok-builtin">@TypeOf</span>(result) == <span class="tok-type">f64</span>);</span>
<span class="line" id="L402">        <span class="tok-kw">try</span> testing.expect(result == <span class="tok-number">10.34</span>);</span>
<span class="line" id="L403">    }</span>
<span class="line" id="L404">    {</span>
<span class="line" id="L405">        <span class="tok-kw">var</span> a: <span class="tok-type">i8</span> = -<span class="tok-number">127</span>;</span>
<span class="line" id="L406">        <span class="tok-kw">var</span> b: <span class="tok-type">i16</span> = -<span class="tok-number">200</span>;</span>
<span class="line" id="L407">        <span class="tok-kw">var</span> result = min(a, b);</span>
<span class="line" id="L408">        <span class="tok-kw">try</span> testing.expect(<span class="tok-builtin">@TypeOf</span>(result) == <span class="tok-type">i16</span>);</span>
<span class="line" id="L409">        <span class="tok-kw">try</span> testing.expect(result == -<span class="tok-number">200</span>);</span>
<span class="line" id="L410">    }</span>
<span class="line" id="L411">    {</span>
<span class="line" id="L412">        <span class="tok-kw">const</span> a = <span class="tok-number">10.34</span>;</span>
<span class="line" id="L413">        <span class="tok-kw">var</span> b: <span class="tok-type">f32</span> = <span class="tok-number">999.12</span>;</span>
<span class="line" id="L414">        <span class="tok-kw">var</span> result = min(a, b);</span>
<span class="line" id="L415">        <span class="tok-kw">try</span> testing.expect(<span class="tok-builtin">@TypeOf</span>(result) == <span class="tok-type">f32</span>);</span>
<span class="line" id="L416">        <span class="tok-kw">try</span> testing.expect(result == <span class="tok-number">10.34</span>);</span>
<span class="line" id="L417">    }</span>
<span class="line" id="L418">}</span>
<span class="line" id="L419"></span>
<span class="line" id="L420"><span class="tok-comment">/// Finds the minimum of three numbers.</span></span>
<span class="line" id="L421"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">min3</span>(x: <span class="tok-kw">anytype</span>, y: <span class="tok-kw">anytype</span>, z: <span class="tok-kw">anytype</span>) <span class="tok-builtin">@TypeOf</span>(x, y, z) {</span>
<span class="line" id="L422">    <span class="tok-kw">return</span> min(x, min(y, z));</span>
<span class="line" id="L423">}</span>
<span class="line" id="L424"></span>
<span class="line" id="L425"><span class="tok-kw">test</span> <span class="tok-str">&quot;min3&quot;</span> {</span>
<span class="line" id="L426">    <span class="tok-kw">try</span> testing.expect(min3(<span class="tok-builtin">@as</span>(<span class="tok-type">i32</span>, <span class="tok-number">0</span>), <span class="tok-builtin">@as</span>(<span class="tok-type">i32</span>, <span class="tok-number">1</span>), <span class="tok-builtin">@as</span>(<span class="tok-type">i32</span>, <span class="tok-number">2</span>)) == <span class="tok-number">0</span>);</span>
<span class="line" id="L427">    <span class="tok-kw">try</span> testing.expect(min3(<span class="tok-builtin">@as</span>(<span class="tok-type">i32</span>, <span class="tok-number">0</span>), <span class="tok-builtin">@as</span>(<span class="tok-type">i32</span>, <span class="tok-number">2</span>), <span class="tok-builtin">@as</span>(<span class="tok-type">i32</span>, <span class="tok-number">1</span>)) == <span class="tok-number">0</span>);</span>
<span class="line" id="L428">    <span class="tok-kw">try</span> testing.expect(min3(<span class="tok-builtin">@as</span>(<span class="tok-type">i32</span>, <span class="tok-number">1</span>), <span class="tok-builtin">@as</span>(<span class="tok-type">i32</span>, <span class="tok-number">0</span>), <span class="tok-builtin">@as</span>(<span class="tok-type">i32</span>, <span class="tok-number">2</span>)) == <span class="tok-number">0</span>);</span>
<span class="line" id="L429">    <span class="tok-kw">try</span> testing.expect(min3(<span class="tok-builtin">@as</span>(<span class="tok-type">i32</span>, <span class="tok-number">1</span>), <span class="tok-builtin">@as</span>(<span class="tok-type">i32</span>, <span class="tok-number">2</span>), <span class="tok-builtin">@as</span>(<span class="tok-type">i32</span>, <span class="tok-number">0</span>)) == <span class="tok-number">0</span>);</span>
<span class="line" id="L430">    <span class="tok-kw">try</span> testing.expect(min3(<span class="tok-builtin">@as</span>(<span class="tok-type">i32</span>, <span class="tok-number">2</span>), <span class="tok-builtin">@as</span>(<span class="tok-type">i32</span>, <span class="tok-number">0</span>), <span class="tok-builtin">@as</span>(<span class="tok-type">i32</span>, <span class="tok-number">1</span>)) == <span class="tok-number">0</span>);</span>
<span class="line" id="L431">    <span class="tok-kw">try</span> testing.expect(min3(<span class="tok-builtin">@as</span>(<span class="tok-type">i32</span>, <span class="tok-number">2</span>), <span class="tok-builtin">@as</span>(<span class="tok-type">i32</span>, <span class="tok-number">1</span>), <span class="tok-builtin">@as</span>(<span class="tok-type">i32</span>, <span class="tok-number">0</span>)) == <span class="tok-number">0</span>);</span>
<span class="line" id="L432">}</span>
<span class="line" id="L433"></span>
<span class="line" id="L434"><span class="tok-comment">/// Returns the maximum of two numbers. Return type is the one with the</span></span>
<span class="line" id="L435"><span class="tok-comment">/// larger range.</span></span>
<span class="line" id="L436"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">max</span>(x: <span class="tok-kw">anytype</span>, y: <span class="tok-kw">anytype</span>) <span class="tok-builtin">@TypeOf</span>(x, y) {</span>
<span class="line" id="L437">    <span class="tok-kw">return</span> <span class="tok-kw">if</span> (x &gt; y) x <span class="tok-kw">else</span> y;</span>
<span class="line" id="L438">}</span>
<span class="line" id="L439"></span>
<span class="line" id="L440"><span class="tok-kw">test</span> <span class="tok-str">&quot;max&quot;</span> {</span>
<span class="line" id="L441">    <span class="tok-kw">try</span> testing.expect(max(<span class="tok-builtin">@as</span>(<span class="tok-type">i32</span>, -<span class="tok-number">1</span>), <span class="tok-builtin">@as</span>(<span class="tok-type">i32</span>, <span class="tok-number">2</span>)) == <span class="tok-number">2</span>);</span>
<span class="line" id="L442">    <span class="tok-kw">try</span> testing.expect(max(<span class="tok-builtin">@as</span>(<span class="tok-type">i32</span>, <span class="tok-number">2</span>), <span class="tok-builtin">@as</span>(<span class="tok-type">i32</span>, -<span class="tok-number">1</span>)) == <span class="tok-number">2</span>);</span>
<span class="line" id="L443">}</span>
<span class="line" id="L444"></span>
<span class="line" id="L445"><span class="tok-comment">/// Finds the maximum of three numbers.</span></span>
<span class="line" id="L446"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">max3</span>(x: <span class="tok-kw">anytype</span>, y: <span class="tok-kw">anytype</span>, z: <span class="tok-kw">anytype</span>) <span class="tok-builtin">@TypeOf</span>(x, y, z) {</span>
<span class="line" id="L447">    <span class="tok-kw">return</span> max(x, max(y, z));</span>
<span class="line" id="L448">}</span>
<span class="line" id="L449"></span>
<span class="line" id="L450"><span class="tok-kw">test</span> <span class="tok-str">&quot;max3&quot;</span> {</span>
<span class="line" id="L451">    <span class="tok-kw">try</span> testing.expect(max3(<span class="tok-builtin">@as</span>(<span class="tok-type">i32</span>, <span class="tok-number">0</span>), <span class="tok-builtin">@as</span>(<span class="tok-type">i32</span>, <span class="tok-number">1</span>), <span class="tok-builtin">@as</span>(<span class="tok-type">i32</span>, <span class="tok-number">2</span>)) == <span class="tok-number">2</span>);</span>
<span class="line" id="L452">    <span class="tok-kw">try</span> testing.expect(max3(<span class="tok-builtin">@as</span>(<span class="tok-type">i32</span>, <span class="tok-number">0</span>), <span class="tok-builtin">@as</span>(<span class="tok-type">i32</span>, <span class="tok-number">2</span>), <span class="tok-builtin">@as</span>(<span class="tok-type">i32</span>, <span class="tok-number">1</span>)) == <span class="tok-number">2</span>);</span>
<span class="line" id="L453">    <span class="tok-kw">try</span> testing.expect(max3(<span class="tok-builtin">@as</span>(<span class="tok-type">i32</span>, <span class="tok-number">1</span>), <span class="tok-builtin">@as</span>(<span class="tok-type">i32</span>, <span class="tok-number">0</span>), <span class="tok-builtin">@as</span>(<span class="tok-type">i32</span>, <span class="tok-number">2</span>)) == <span class="tok-number">2</span>);</span>
<span class="line" id="L454">    <span class="tok-kw">try</span> testing.expect(max3(<span class="tok-builtin">@as</span>(<span class="tok-type">i32</span>, <span class="tok-number">1</span>), <span class="tok-builtin">@as</span>(<span class="tok-type">i32</span>, <span class="tok-number">2</span>), <span class="tok-builtin">@as</span>(<span class="tok-type">i32</span>, <span class="tok-number">0</span>)) == <span class="tok-number">2</span>);</span>
<span class="line" id="L455">    <span class="tok-kw">try</span> testing.expect(max3(<span class="tok-builtin">@as</span>(<span class="tok-type">i32</span>, <span class="tok-number">2</span>), <span class="tok-builtin">@as</span>(<span class="tok-type">i32</span>, <span class="tok-number">0</span>), <span class="tok-builtin">@as</span>(<span class="tok-type">i32</span>, <span class="tok-number">1</span>)) == <span class="tok-number">2</span>);</span>
<span class="line" id="L456">    <span class="tok-kw">try</span> testing.expect(max3(<span class="tok-builtin">@as</span>(<span class="tok-type">i32</span>, <span class="tok-number">2</span>), <span class="tok-builtin">@as</span>(<span class="tok-type">i32</span>, <span class="tok-number">1</span>), <span class="tok-builtin">@as</span>(<span class="tok-type">i32</span>, <span class="tok-number">0</span>)) == <span class="tok-number">2</span>);</span>
<span class="line" id="L457">}</span>
<span class="line" id="L458"></span>
<span class="line" id="L459"><span class="tok-comment">/// Limit val to the inclusive range [lower, upper].</span></span>
<span class="line" id="L460"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">clamp</span>(val: <span class="tok-kw">anytype</span>, lower: <span class="tok-kw">anytype</span>, upper: <span class="tok-kw">anytype</span>) <span class="tok-builtin">@TypeOf</span>(val, lower, upper) {</span>
<span class="line" id="L461">    assert(lower &lt;= upper);</span>
<span class="line" id="L462">    <span class="tok-kw">return</span> max(lower, min(val, upper));</span>
<span class="line" id="L463">}</span>
<span class="line" id="L464"><span class="tok-kw">test</span> <span class="tok-str">&quot;clamp&quot;</span> {</span>
<span class="line" id="L465">    <span class="tok-comment">// Within range</span>
</span>
<span class="line" id="L466">    <span class="tok-kw">try</span> testing.expect(std.math.clamp(<span class="tok-builtin">@as</span>(<span class="tok-type">i32</span>, -<span class="tok-number">1</span>), <span class="tok-builtin">@as</span>(<span class="tok-type">i32</span>, -<span class="tok-number">4</span>), <span class="tok-builtin">@as</span>(<span class="tok-type">i32</span>, <span class="tok-number">7</span>)) == -<span class="tok-number">1</span>);</span>
<span class="line" id="L467">    <span class="tok-comment">// Below</span>
</span>
<span class="line" id="L468">    <span class="tok-kw">try</span> testing.expect(std.math.clamp(<span class="tok-builtin">@as</span>(<span class="tok-type">i32</span>, -<span class="tok-number">5</span>), <span class="tok-builtin">@as</span>(<span class="tok-type">i32</span>, -<span class="tok-number">4</span>), <span class="tok-builtin">@as</span>(<span class="tok-type">i32</span>, <span class="tok-number">7</span>)) == -<span class="tok-number">4</span>);</span>
<span class="line" id="L469">    <span class="tok-comment">// Above</span>
</span>
<span class="line" id="L470">    <span class="tok-kw">try</span> testing.expect(std.math.clamp(<span class="tok-builtin">@as</span>(<span class="tok-type">i32</span>, <span class="tok-number">8</span>), <span class="tok-builtin">@as</span>(<span class="tok-type">i32</span>, -<span class="tok-number">4</span>), <span class="tok-builtin">@as</span>(<span class="tok-type">i32</span>, <span class="tok-number">7</span>)) == <span class="tok-number">7</span>);</span>
<span class="line" id="L471"></span>
<span class="line" id="L472">    <span class="tok-comment">// Floating point</span>
</span>
<span class="line" id="L473">    <span class="tok-kw">try</span> testing.expect(std.math.clamp(<span class="tok-builtin">@as</span>(<span class="tok-type">f32</span>, <span class="tok-number">1.1</span>), <span class="tok-builtin">@as</span>(<span class="tok-type">f32</span>, <span class="tok-number">0.0</span>), <span class="tok-builtin">@as</span>(<span class="tok-type">f32</span>, <span class="tok-number">1.0</span>)) == <span class="tok-number">1.0</span>);</span>
<span class="line" id="L474">    <span class="tok-kw">try</span> testing.expect(std.math.clamp(<span class="tok-builtin">@as</span>(<span class="tok-type">f32</span>, -<span class="tok-number">127.5</span>), <span class="tok-builtin">@as</span>(<span class="tok-type">f32</span>, -<span class="tok-number">200</span>), <span class="tok-builtin">@as</span>(<span class="tok-type">f32</span>, -<span class="tok-number">100</span>)) == -<span class="tok-number">127.5</span>);</span>
<span class="line" id="L475"></span>
<span class="line" id="L476">    <span class="tok-comment">// Mix of comptime and non-comptime</span>
</span>
<span class="line" id="L477">    <span class="tok-kw">var</span> i: <span class="tok-type">i32</span> = <span class="tok-number">1</span>;</span>
<span class="line" id="L478">    <span class="tok-kw">try</span> testing.expect(std.math.clamp(i, <span class="tok-number">0</span>, <span class="tok-number">1</span>) == <span class="tok-number">1</span>);</span>
<span class="line" id="L479">}</span>
<span class="line" id="L480"></span>
<span class="line" id="L481"><span class="tok-comment">/// Returns the product of a and b. Returns an error on overflow.</span></span>
<span class="line" id="L482"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">mul</span>(<span class="tok-kw">comptime</span> T: <span class="tok-type">type</span>, a: T, b: T) (<span class="tok-kw">error</span>{Overflow}!T) {</span>
<span class="line" id="L483">    <span class="tok-kw">var</span> answer: T = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L484">    <span class="tok-kw">return</span> <span class="tok-kw">if</span> (<span class="tok-builtin">@mulWithOverflow</span>(T, a, b, &amp;answer)) <span class="tok-kw">error</span>.Overflow <span class="tok-kw">else</span> answer;</span>
<span class="line" id="L485">}</span>
<span class="line" id="L486"></span>
<span class="line" id="L487"><span class="tok-comment">/// Returns the sum of a and b. Returns an error on overflow.</span></span>
<span class="line" id="L488"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">add</span>(<span class="tok-kw">comptime</span> T: <span class="tok-type">type</span>, a: T, b: T) (<span class="tok-kw">error</span>{Overflow}!T) {</span>
<span class="line" id="L489">    <span class="tok-kw">if</span> (T == <span class="tok-type">comptime_int</span>) <span class="tok-kw">return</span> a + b;</span>
<span class="line" id="L490">    <span class="tok-kw">var</span> answer: T = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L491">    <span class="tok-kw">return</span> <span class="tok-kw">if</span> (<span class="tok-builtin">@addWithOverflow</span>(T, a, b, &amp;answer)) <span class="tok-kw">error</span>.Overflow <span class="tok-kw">else</span> answer;</span>
<span class="line" id="L492">}</span>
<span class="line" id="L493"></span>
<span class="line" id="L494"><span class="tok-comment">/// Returns a - b, or an error on overflow.</span></span>
<span class="line" id="L495"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">sub</span>(<span class="tok-kw">comptime</span> T: <span class="tok-type">type</span>, a: T, b: T) (<span class="tok-kw">error</span>{Overflow}!T) {</span>
<span class="line" id="L496">    <span class="tok-kw">var</span> answer: T = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L497">    <span class="tok-kw">return</span> <span class="tok-kw">if</span> (<span class="tok-builtin">@subWithOverflow</span>(T, a, b, &amp;answer)) <span class="tok-kw">error</span>.Overflow <span class="tok-kw">else</span> answer;</span>
<span class="line" id="L498">}</span>
<span class="line" id="L499"></span>
<span class="line" id="L500"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">negate</span>(x: <span class="tok-kw">anytype</span>) !<span class="tok-builtin">@TypeOf</span>(x) {</span>
<span class="line" id="L501">    <span class="tok-kw">return</span> sub(<span class="tok-builtin">@TypeOf</span>(x), <span class="tok-number">0</span>, x);</span>
<span class="line" id="L502">}</span>
<span class="line" id="L503"></span>
<span class="line" id="L504"><span class="tok-comment">/// Shifts a left by shift_amt. Returns an error on overflow. shift_amt</span></span>
<span class="line" id="L505"><span class="tok-comment">/// is unsigned.</span></span>
<span class="line" id="L506"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">shlExact</span>(<span class="tok-kw">comptime</span> T: <span class="tok-type">type</span>, a: T, shift_amt: Log2Int(T)) !T {</span>
<span class="line" id="L507">    <span class="tok-kw">var</span> answer: T = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L508">    <span class="tok-kw">return</span> <span class="tok-kw">if</span> (<span class="tok-builtin">@shlWithOverflow</span>(T, a, shift_amt, &amp;answer)) <span class="tok-kw">error</span>.Overflow <span class="tok-kw">else</span> answer;</span>
<span class="line" id="L509">}</span>
<span class="line" id="L510"></span>
<span class="line" id="L511"><span class="tok-comment">/// Shifts left. Overflowed bits are truncated.</span></span>
<span class="line" id="L512"><span class="tok-comment">/// A negative shift amount results in a right shift.</span></span>
<span class="line" id="L513"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">shl</span>(<span class="tok-kw">comptime</span> T: <span class="tok-type">type</span>, a: T, shift_amt: <span class="tok-kw">anytype</span>) T {</span>
<span class="line" id="L514">    <span class="tok-kw">const</span> abs_shift_amt = absCast(shift_amt);</span>
<span class="line" id="L515"></span>
<span class="line" id="L516">    <span class="tok-kw">const</span> casted_shift_amt = blk: {</span>
<span class="line" id="L517">        <span class="tok-kw">if</span> (<span class="tok-builtin">@typeInfo</span>(T) == .Vector) {</span>
<span class="line" id="L518">            <span class="tok-kw">const</span> C = <span class="tok-builtin">@typeInfo</span>(T).Vector.child;</span>
<span class="line" id="L519">            <span class="tok-kw">const</span> len = <span class="tok-builtin">@typeInfo</span>(T).Vector.len;</span>
<span class="line" id="L520">            <span class="tok-kw">if</span> (abs_shift_amt &gt;= <span class="tok-builtin">@typeInfo</span>(C).Int.bits) <span class="tok-kw">return</span> <span class="tok-builtin">@splat</span>(len, <span class="tok-builtin">@as</span>(C, <span class="tok-number">0</span>));</span>
<span class="line" id="L521">            <span class="tok-kw">break</span> :blk <span class="tok-builtin">@splat</span>(len, <span class="tok-builtin">@intCast</span>(Log2Int(C), abs_shift_amt));</span>
<span class="line" id="L522">        } <span class="tok-kw">else</span> {</span>
<span class="line" id="L523">            <span class="tok-kw">if</span> (abs_shift_amt &gt;= <span class="tok-builtin">@typeInfo</span>(T).Int.bits) <span class="tok-kw">return</span> <span class="tok-number">0</span>;</span>
<span class="line" id="L524">            <span class="tok-kw">break</span> :blk <span class="tok-builtin">@intCast</span>(Log2Int(T), abs_shift_amt);</span>
<span class="line" id="L525">        }</span>
<span class="line" id="L526">    };</span>
<span class="line" id="L527"></span>
<span class="line" id="L528">    <span class="tok-kw">if</span> (<span class="tok-builtin">@TypeOf</span>(shift_amt) == <span class="tok-type">comptime_int</span> <span class="tok-kw">or</span> <span class="tok-builtin">@typeInfo</span>(<span class="tok-builtin">@TypeOf</span>(shift_amt)).Int.signedness == .signed) {</span>
<span class="line" id="L529">        <span class="tok-kw">if</span> (shift_amt &lt; <span class="tok-number">0</span>) {</span>
<span class="line" id="L530">            <span class="tok-kw">return</span> a &gt;&gt; casted_shift_amt;</span>
<span class="line" id="L531">        }</span>
<span class="line" id="L532">    }</span>
<span class="line" id="L533"></span>
<span class="line" id="L534">    <span class="tok-kw">return</span> a &lt;&lt; casted_shift_amt;</span>
<span class="line" id="L535">}</span>
<span class="line" id="L536"></span>
<span class="line" id="L537"><span class="tok-kw">test</span> <span class="tok-str">&quot;shl&quot;</span> {</span>
<span class="line" id="L538">    <span class="tok-kw">if</span> ((builtin.zig_backend == .stage1 <span class="tok-kw">or</span> builtin.zig_backend == .stage2_llvm) <span class="tok-kw">and</span></span>
<span class="line" id="L539">        builtin.cpu.arch == .aarch64)</span>
<span class="line" id="L540">    {</span>
<span class="line" id="L541">        <span class="tok-comment">// https://github.com/ziglang/zig/issues/12012</span>
</span>
<span class="line" id="L542">        <span class="tok-kw">return</span> <span class="tok-kw">error</span>.SkipZigTest;</span>
<span class="line" id="L543">    }</span>
<span class="line" id="L544">    <span class="tok-kw">try</span> testing.expect(shl(<span class="tok-type">u8</span>, <span class="tok-number">0b11111111</span>, <span class="tok-builtin">@as</span>(<span class="tok-type">usize</span>, <span class="tok-number">3</span>)) == <span class="tok-number">0b11111000</span>);</span>
<span class="line" id="L545">    <span class="tok-kw">try</span> testing.expect(shl(<span class="tok-type">u8</span>, <span class="tok-number">0b11111111</span>, <span class="tok-builtin">@as</span>(<span class="tok-type">usize</span>, <span class="tok-number">8</span>)) == <span class="tok-number">0</span>);</span>
<span class="line" id="L546">    <span class="tok-kw">try</span> testing.expect(shl(<span class="tok-type">u8</span>, <span class="tok-number">0b11111111</span>, <span class="tok-builtin">@as</span>(<span class="tok-type">usize</span>, <span class="tok-number">9</span>)) == <span class="tok-number">0</span>);</span>
<span class="line" id="L547">    <span class="tok-kw">try</span> testing.expect(shl(<span class="tok-type">u8</span>, <span class="tok-number">0b11111111</span>, <span class="tok-builtin">@as</span>(<span class="tok-type">isize</span>, -<span class="tok-number">2</span>)) == <span class="tok-number">0b00111111</span>);</span>
<span class="line" id="L548">    <span class="tok-kw">try</span> testing.expect(shl(<span class="tok-type">u8</span>, <span class="tok-number">0b11111111</span>, <span class="tok-number">3</span>) == <span class="tok-number">0b11111000</span>);</span>
<span class="line" id="L549">    <span class="tok-kw">try</span> testing.expect(shl(<span class="tok-type">u8</span>, <span class="tok-number">0b11111111</span>, <span class="tok-number">8</span>) == <span class="tok-number">0</span>);</span>
<span class="line" id="L550">    <span class="tok-kw">try</span> testing.expect(shl(<span class="tok-type">u8</span>, <span class="tok-number">0b11111111</span>, <span class="tok-number">9</span>) == <span class="tok-number">0</span>);</span>
<span class="line" id="L551">    <span class="tok-kw">try</span> testing.expect(shl(<span class="tok-type">u8</span>, <span class="tok-number">0b11111111</span>, -<span class="tok-number">2</span>) == <span class="tok-number">0b00111111</span>);</span>
<span class="line" id="L552">    <span class="tok-kw">try</span> testing.expect(shl(<span class="tok-builtin">@Vector</span>(<span class="tok-number">1</span>, <span class="tok-type">u32</span>), <span class="tok-builtin">@Vector</span>(<span class="tok-number">1</span>, <span class="tok-type">u32</span>){<span class="tok-number">42</span>}, <span class="tok-builtin">@as</span>(<span class="tok-type">usize</span>, <span class="tok-number">1</span>))[<span class="tok-number">0</span>] == <span class="tok-builtin">@as</span>(<span class="tok-type">u32</span>, <span class="tok-number">42</span>) &lt;&lt; <span class="tok-number">1</span>);</span>
<span class="line" id="L553">    <span class="tok-kw">try</span> testing.expect(shl(<span class="tok-builtin">@Vector</span>(<span class="tok-number">1</span>, <span class="tok-type">u32</span>), <span class="tok-builtin">@Vector</span>(<span class="tok-number">1</span>, <span class="tok-type">u32</span>){<span class="tok-number">42</span>}, <span class="tok-builtin">@as</span>(<span class="tok-type">isize</span>, -<span class="tok-number">1</span>))[<span class="tok-number">0</span>] == <span class="tok-builtin">@as</span>(<span class="tok-type">u32</span>, <span class="tok-number">42</span>) &gt;&gt; <span class="tok-number">1</span>);</span>
<span class="line" id="L554">    <span class="tok-kw">try</span> testing.expect(shl(<span class="tok-builtin">@Vector</span>(<span class="tok-number">1</span>, <span class="tok-type">u32</span>), <span class="tok-builtin">@Vector</span>(<span class="tok-number">1</span>, <span class="tok-type">u32</span>){<span class="tok-number">42</span>}, <span class="tok-number">33</span>)[<span class="tok-number">0</span>] == <span class="tok-number">0</span>);</span>
<span class="line" id="L555">}</span>
<span class="line" id="L556"></span>
<span class="line" id="L557"><span class="tok-comment">/// Shifts right. Overflowed bits are truncated.</span></span>
<span class="line" id="L558"><span class="tok-comment">/// A negative shift amount results in a left shift.</span></span>
<span class="line" id="L559"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">shr</span>(<span class="tok-kw">comptime</span> T: <span class="tok-type">type</span>, a: T, shift_amt: <span class="tok-kw">anytype</span>) T {</span>
<span class="line" id="L560">    <span class="tok-kw">const</span> abs_shift_amt = absCast(shift_amt);</span>
<span class="line" id="L561"></span>
<span class="line" id="L562">    <span class="tok-kw">const</span> casted_shift_amt = blk: {</span>
<span class="line" id="L563">        <span class="tok-kw">if</span> (<span class="tok-builtin">@typeInfo</span>(T) == .Vector) {</span>
<span class="line" id="L564">            <span class="tok-kw">const</span> C = <span class="tok-builtin">@typeInfo</span>(T).Vector.child;</span>
<span class="line" id="L565">            <span class="tok-kw">const</span> len = <span class="tok-builtin">@typeInfo</span>(T).Vector.len;</span>
<span class="line" id="L566">            <span class="tok-kw">if</span> (abs_shift_amt &gt;= <span class="tok-builtin">@typeInfo</span>(C).Int.bits) <span class="tok-kw">return</span> <span class="tok-builtin">@splat</span>(len, <span class="tok-builtin">@as</span>(C, <span class="tok-number">0</span>));</span>
<span class="line" id="L567">            <span class="tok-kw">break</span> :blk <span class="tok-builtin">@splat</span>(len, <span class="tok-builtin">@intCast</span>(Log2Int(C), abs_shift_amt));</span>
<span class="line" id="L568">        } <span class="tok-kw">else</span> {</span>
<span class="line" id="L569">            <span class="tok-kw">if</span> (abs_shift_amt &gt;= <span class="tok-builtin">@typeInfo</span>(T).Int.bits) <span class="tok-kw">return</span> <span class="tok-number">0</span>;</span>
<span class="line" id="L570">            <span class="tok-kw">break</span> :blk <span class="tok-builtin">@intCast</span>(Log2Int(T), abs_shift_amt);</span>
<span class="line" id="L571">        }</span>
<span class="line" id="L572">    };</span>
<span class="line" id="L573"></span>
<span class="line" id="L574">    <span class="tok-kw">if</span> (<span class="tok-builtin">@TypeOf</span>(shift_amt) == <span class="tok-type">comptime_int</span> <span class="tok-kw">or</span> <span class="tok-builtin">@typeInfo</span>(<span class="tok-builtin">@TypeOf</span>(shift_amt)).Int.signedness == .signed) {</span>
<span class="line" id="L575">        <span class="tok-kw">if</span> (shift_amt &lt; <span class="tok-number">0</span>) {</span>
<span class="line" id="L576">            <span class="tok-kw">return</span> a &lt;&lt; casted_shift_amt;</span>
<span class="line" id="L577">        }</span>
<span class="line" id="L578">    }</span>
<span class="line" id="L579"></span>
<span class="line" id="L580">    <span class="tok-kw">return</span> a &gt;&gt; casted_shift_amt;</span>
<span class="line" id="L581">}</span>
<span class="line" id="L582"></span>
<span class="line" id="L583"><span class="tok-kw">test</span> <span class="tok-str">&quot;shr&quot;</span> {</span>
<span class="line" id="L584">    <span class="tok-kw">if</span> ((builtin.zig_backend == .stage1 <span class="tok-kw">or</span> builtin.zig_backend == .stage2_llvm) <span class="tok-kw">and</span></span>
<span class="line" id="L585">        builtin.cpu.arch == .aarch64)</span>
<span class="line" id="L586">    {</span>
<span class="line" id="L587">        <span class="tok-comment">// https://github.com/ziglang/zig/issues/12012</span>
</span>
<span class="line" id="L588">        <span class="tok-kw">return</span> <span class="tok-kw">error</span>.SkipZigTest;</span>
<span class="line" id="L589">    }</span>
<span class="line" id="L590">    <span class="tok-kw">try</span> testing.expect(shr(<span class="tok-type">u8</span>, <span class="tok-number">0b11111111</span>, <span class="tok-builtin">@as</span>(<span class="tok-type">usize</span>, <span class="tok-number">3</span>)) == <span class="tok-number">0b00011111</span>);</span>
<span class="line" id="L591">    <span class="tok-kw">try</span> testing.expect(shr(<span class="tok-type">u8</span>, <span class="tok-number">0b11111111</span>, <span class="tok-builtin">@as</span>(<span class="tok-type">usize</span>, <span class="tok-number">8</span>)) == <span class="tok-number">0</span>);</span>
<span class="line" id="L592">    <span class="tok-kw">try</span> testing.expect(shr(<span class="tok-type">u8</span>, <span class="tok-number">0b11111111</span>, <span class="tok-builtin">@as</span>(<span class="tok-type">usize</span>, <span class="tok-number">9</span>)) == <span class="tok-number">0</span>);</span>
<span class="line" id="L593">    <span class="tok-kw">try</span> testing.expect(shr(<span class="tok-type">u8</span>, <span class="tok-number">0b11111111</span>, <span class="tok-builtin">@as</span>(<span class="tok-type">isize</span>, -<span class="tok-number">2</span>)) == <span class="tok-number">0b11111100</span>);</span>
<span class="line" id="L594">    <span class="tok-kw">try</span> testing.expect(shr(<span class="tok-type">u8</span>, <span class="tok-number">0b11111111</span>, <span class="tok-number">3</span>) == <span class="tok-number">0b00011111</span>);</span>
<span class="line" id="L595">    <span class="tok-kw">try</span> testing.expect(shr(<span class="tok-type">u8</span>, <span class="tok-number">0b11111111</span>, <span class="tok-number">8</span>) == <span class="tok-number">0</span>);</span>
<span class="line" id="L596">    <span class="tok-kw">try</span> testing.expect(shr(<span class="tok-type">u8</span>, <span class="tok-number">0b11111111</span>, <span class="tok-number">9</span>) == <span class="tok-number">0</span>);</span>
<span class="line" id="L597">    <span class="tok-kw">try</span> testing.expect(shr(<span class="tok-type">u8</span>, <span class="tok-number">0b11111111</span>, -<span class="tok-number">2</span>) == <span class="tok-number">0b11111100</span>);</span>
<span class="line" id="L598">    <span class="tok-kw">try</span> testing.expect(shr(<span class="tok-builtin">@Vector</span>(<span class="tok-number">1</span>, <span class="tok-type">u32</span>), <span class="tok-builtin">@Vector</span>(<span class="tok-number">1</span>, <span class="tok-type">u32</span>){<span class="tok-number">42</span>}, <span class="tok-builtin">@as</span>(<span class="tok-type">usize</span>, <span class="tok-number">1</span>))[<span class="tok-number">0</span>] == <span class="tok-builtin">@as</span>(<span class="tok-type">u32</span>, <span class="tok-number">42</span>) &gt;&gt; <span class="tok-number">1</span>);</span>
<span class="line" id="L599">    <span class="tok-kw">try</span> testing.expect(shr(<span class="tok-builtin">@Vector</span>(<span class="tok-number">1</span>, <span class="tok-type">u32</span>), <span class="tok-builtin">@Vector</span>(<span class="tok-number">1</span>, <span class="tok-type">u32</span>){<span class="tok-number">42</span>}, <span class="tok-builtin">@as</span>(<span class="tok-type">isize</span>, -<span class="tok-number">1</span>))[<span class="tok-number">0</span>] == <span class="tok-builtin">@as</span>(<span class="tok-type">u32</span>, <span class="tok-number">42</span>) &lt;&lt; <span class="tok-number">1</span>);</span>
<span class="line" id="L600">    <span class="tok-kw">try</span> testing.expect(shr(<span class="tok-builtin">@Vector</span>(<span class="tok-number">1</span>, <span class="tok-type">u32</span>), <span class="tok-builtin">@Vector</span>(<span class="tok-number">1</span>, <span class="tok-type">u32</span>){<span class="tok-number">42</span>}, <span class="tok-number">33</span>)[<span class="tok-number">0</span>] == <span class="tok-number">0</span>);</span>
<span class="line" id="L601">}</span>
<span class="line" id="L602"></span>
<span class="line" id="L603"><span class="tok-comment">/// Rotates right. Only unsigned values can be rotated.  Negative shift</span></span>
<span class="line" id="L604"><span class="tok-comment">/// values result in shift modulo the bit count.</span></span>
<span class="line" id="L605"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">rotr</span>(<span class="tok-kw">comptime</span> T: <span class="tok-type">type</span>, x: T, r: <span class="tok-kw">anytype</span>) T {</span>
<span class="line" id="L606">    <span class="tok-kw">if</span> (<span class="tok-builtin">@typeInfo</span>(T) == .Vector) {</span>
<span class="line" id="L607">        <span class="tok-kw">const</span> C = <span class="tok-builtin">@typeInfo</span>(T).Vector.child;</span>
<span class="line" id="L608">        <span class="tok-kw">if</span> (<span class="tok-builtin">@typeInfo</span>(C).Int.signedness == .signed) {</span>
<span class="line" id="L609">            <span class="tok-builtin">@compileError</span>(<span class="tok-str">&quot;cannot rotate signed integers&quot;</span>);</span>
<span class="line" id="L610">        }</span>
<span class="line" id="L611">        <span class="tok-kw">const</span> ar = <span class="tok-builtin">@intCast</span>(Log2Int(C), <span class="tok-builtin">@mod</span>(r, <span class="tok-builtin">@typeInfo</span>(C).Int.bits));</span>
<span class="line" id="L612">        <span class="tok-kw">return</span> (x &gt;&gt; <span class="tok-builtin">@splat</span>(<span class="tok-builtin">@typeInfo</span>(T).Vector.len, ar)) | (x &lt;&lt; <span class="tok-builtin">@splat</span>(<span class="tok-builtin">@typeInfo</span>(T).Vector.len, <span class="tok-number">1</span> + ~ar));</span>
<span class="line" id="L613">    } <span class="tok-kw">else</span> <span class="tok-kw">if</span> (<span class="tok-builtin">@typeInfo</span>(T).Int.signedness == .signed) {</span>
<span class="line" id="L614">        <span class="tok-builtin">@compileError</span>(<span class="tok-str">&quot;cannot rotate signed integer&quot;</span>);</span>
<span class="line" id="L615">    } <span class="tok-kw">else</span> {</span>
<span class="line" id="L616">        <span class="tok-kw">const</span> ar = <span class="tok-builtin">@intCast</span>(Log2Int(T), <span class="tok-builtin">@mod</span>(r, <span class="tok-builtin">@typeInfo</span>(T).Int.bits));</span>
<span class="line" id="L617">        <span class="tok-kw">return</span> x &gt;&gt; ar | x &lt;&lt; (<span class="tok-number">1</span> +% ~ar);</span>
<span class="line" id="L618">    }</span>
<span class="line" id="L619">}</span>
<span class="line" id="L620"></span>
<span class="line" id="L621"><span class="tok-kw">test</span> <span class="tok-str">&quot;rotr&quot;</span> {</span>
<span class="line" id="L622">    <span class="tok-kw">if</span> ((builtin.zig_backend == .stage1 <span class="tok-kw">or</span> builtin.zig_backend == .stage2_llvm) <span class="tok-kw">and</span></span>
<span class="line" id="L623">        builtin.cpu.arch == .aarch64)</span>
<span class="line" id="L624">    {</span>
<span class="line" id="L625">        <span class="tok-comment">// https://github.com/ziglang/zig/issues/12012</span>
</span>
<span class="line" id="L626">        <span class="tok-kw">return</span> <span class="tok-kw">error</span>.SkipZigTest;</span>
<span class="line" id="L627">    }</span>
<span class="line" id="L628">    <span class="tok-kw">try</span> testing.expect(rotr(<span class="tok-type">u8</span>, <span class="tok-number">0b00000001</span>, <span class="tok-builtin">@as</span>(<span class="tok-type">usize</span>, <span class="tok-number">0</span>)) == <span class="tok-number">0b00000001</span>);</span>
<span class="line" id="L629">    <span class="tok-kw">try</span> testing.expect(rotr(<span class="tok-type">u8</span>, <span class="tok-number">0b00000001</span>, <span class="tok-builtin">@as</span>(<span class="tok-type">usize</span>, <span class="tok-number">9</span>)) == <span class="tok-number">0b10000000</span>);</span>
<span class="line" id="L630">    <span class="tok-kw">try</span> testing.expect(rotr(<span class="tok-type">u8</span>, <span class="tok-number">0b00000001</span>, <span class="tok-builtin">@as</span>(<span class="tok-type">usize</span>, <span class="tok-number">8</span>)) == <span class="tok-number">0b00000001</span>);</span>
<span class="line" id="L631">    <span class="tok-kw">try</span> testing.expect(rotr(<span class="tok-type">u8</span>, <span class="tok-number">0b00000001</span>, <span class="tok-builtin">@as</span>(<span class="tok-type">usize</span>, <span class="tok-number">4</span>)) == <span class="tok-number">0b00010000</span>);</span>
<span class="line" id="L632">    <span class="tok-kw">try</span> testing.expect(rotr(<span class="tok-type">u8</span>, <span class="tok-number">0b00000001</span>, <span class="tok-builtin">@as</span>(<span class="tok-type">isize</span>, -<span class="tok-number">1</span>)) == <span class="tok-number">0b00000010</span>);</span>
<span class="line" id="L633">    <span class="tok-kw">try</span> testing.expect(rotr(<span class="tok-builtin">@Vector</span>(<span class="tok-number">1</span>, <span class="tok-type">u32</span>), <span class="tok-builtin">@Vector</span>(<span class="tok-number">1</span>, <span class="tok-type">u32</span>){<span class="tok-number">1</span>}, <span class="tok-builtin">@as</span>(<span class="tok-type">usize</span>, <span class="tok-number">1</span>))[<span class="tok-number">0</span>] == <span class="tok-builtin">@as</span>(<span class="tok-type">u32</span>, <span class="tok-number">1</span>) &lt;&lt; <span class="tok-number">31</span>);</span>
<span class="line" id="L634">    <span class="tok-kw">try</span> testing.expect(rotr(<span class="tok-builtin">@Vector</span>(<span class="tok-number">1</span>, <span class="tok-type">u32</span>), <span class="tok-builtin">@Vector</span>(<span class="tok-number">1</span>, <span class="tok-type">u32</span>){<span class="tok-number">1</span>}, <span class="tok-builtin">@as</span>(<span class="tok-type">isize</span>, -<span class="tok-number">1</span>))[<span class="tok-number">0</span>] == <span class="tok-builtin">@as</span>(<span class="tok-type">u32</span>, <span class="tok-number">1</span>) &lt;&lt; <span class="tok-number">1</span>);</span>
<span class="line" id="L635">}</span>
<span class="line" id="L636"></span>
<span class="line" id="L637"><span class="tok-comment">/// Rotates left. Only unsigned values can be rotated.  Negative shift</span></span>
<span class="line" id="L638"><span class="tok-comment">/// values result in shift modulo the bit count.</span></span>
<span class="line" id="L639"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">rotl</span>(<span class="tok-kw">comptime</span> T: <span class="tok-type">type</span>, x: T, r: <span class="tok-kw">anytype</span>) T {</span>
<span class="line" id="L640">    <span class="tok-kw">if</span> (<span class="tok-builtin">@typeInfo</span>(T) == .Vector) {</span>
<span class="line" id="L641">        <span class="tok-kw">const</span> C = <span class="tok-builtin">@typeInfo</span>(T).Vector.child;</span>
<span class="line" id="L642">        <span class="tok-kw">if</span> (<span class="tok-builtin">@typeInfo</span>(C).Int.signedness == .signed) {</span>
<span class="line" id="L643">            <span class="tok-builtin">@compileError</span>(<span class="tok-str">&quot;cannot rotate signed integers&quot;</span>);</span>
<span class="line" id="L644">        }</span>
<span class="line" id="L645">        <span class="tok-kw">const</span> ar = <span class="tok-builtin">@intCast</span>(Log2Int(C), <span class="tok-builtin">@mod</span>(r, <span class="tok-builtin">@typeInfo</span>(C).Int.bits));</span>
<span class="line" id="L646">        <span class="tok-kw">return</span> (x &lt;&lt; <span class="tok-builtin">@splat</span>(<span class="tok-builtin">@typeInfo</span>(T).Vector.len, ar)) | (x &gt;&gt; <span class="tok-builtin">@splat</span>(<span class="tok-builtin">@typeInfo</span>(T).Vector.len, <span class="tok-number">1</span> +% ~ar));</span>
<span class="line" id="L647">    } <span class="tok-kw">else</span> <span class="tok-kw">if</span> (<span class="tok-builtin">@typeInfo</span>(T).Int.signedness == .signed) {</span>
<span class="line" id="L648">        <span class="tok-builtin">@compileError</span>(<span class="tok-str">&quot;cannot rotate signed integer&quot;</span>);</span>
<span class="line" id="L649">    } <span class="tok-kw">else</span> {</span>
<span class="line" id="L650">        <span class="tok-kw">const</span> ar = <span class="tok-builtin">@intCast</span>(Log2Int(T), <span class="tok-builtin">@mod</span>(r, <span class="tok-builtin">@typeInfo</span>(T).Int.bits));</span>
<span class="line" id="L651">        <span class="tok-kw">return</span> x &lt;&lt; ar | x &gt;&gt; <span class="tok-number">1</span> +% ~ar;</span>
<span class="line" id="L652">    }</span>
<span class="line" id="L653">}</span>
<span class="line" id="L654"></span>
<span class="line" id="L655"><span class="tok-kw">test</span> <span class="tok-str">&quot;rotl&quot;</span> {</span>
<span class="line" id="L656">    <span class="tok-kw">if</span> ((builtin.zig_backend == .stage1 <span class="tok-kw">or</span> builtin.zig_backend == .stage2_llvm) <span class="tok-kw">and</span></span>
<span class="line" id="L657">        builtin.cpu.arch == .aarch64)</span>
<span class="line" id="L658">    {</span>
<span class="line" id="L659">        <span class="tok-comment">// https://github.com/ziglang/zig/issues/12012</span>
</span>
<span class="line" id="L660">        <span class="tok-kw">return</span> <span class="tok-kw">error</span>.SkipZigTest;</span>
<span class="line" id="L661">    }</span>
<span class="line" id="L662">    <span class="tok-kw">try</span> testing.expect(rotl(<span class="tok-type">u8</span>, <span class="tok-number">0b00000001</span>, <span class="tok-builtin">@as</span>(<span class="tok-type">usize</span>, <span class="tok-number">0</span>)) == <span class="tok-number">0b00000001</span>);</span>
<span class="line" id="L663">    <span class="tok-kw">try</span> testing.expect(rotl(<span class="tok-type">u8</span>, <span class="tok-number">0b00000001</span>, <span class="tok-builtin">@as</span>(<span class="tok-type">usize</span>, <span class="tok-number">9</span>)) == <span class="tok-number">0b00000010</span>);</span>
<span class="line" id="L664">    <span class="tok-kw">try</span> testing.expect(rotl(<span class="tok-type">u8</span>, <span class="tok-number">0b00000001</span>, <span class="tok-builtin">@as</span>(<span class="tok-type">usize</span>, <span class="tok-number">8</span>)) == <span class="tok-number">0b00000001</span>);</span>
<span class="line" id="L665">    <span class="tok-kw">try</span> testing.expect(rotl(<span class="tok-type">u8</span>, <span class="tok-number">0b00000001</span>, <span class="tok-builtin">@as</span>(<span class="tok-type">usize</span>, <span class="tok-number">4</span>)) == <span class="tok-number">0b00010000</span>);</span>
<span class="line" id="L666">    <span class="tok-kw">try</span> testing.expect(rotl(<span class="tok-type">u8</span>, <span class="tok-number">0b00000001</span>, <span class="tok-builtin">@as</span>(<span class="tok-type">isize</span>, -<span class="tok-number">1</span>)) == <span class="tok-number">0b10000000</span>);</span>
<span class="line" id="L667">    <span class="tok-kw">try</span> testing.expect(rotl(<span class="tok-builtin">@Vector</span>(<span class="tok-number">1</span>, <span class="tok-type">u32</span>), <span class="tok-builtin">@Vector</span>(<span class="tok-number">1</span>, <span class="tok-type">u32</span>){<span class="tok-number">1</span> &lt;&lt; <span class="tok-number">31</span>}, <span class="tok-builtin">@as</span>(<span class="tok-type">usize</span>, <span class="tok-number">1</span>))[<span class="tok-number">0</span>] == <span class="tok-number">1</span>);</span>
<span class="line" id="L668">    <span class="tok-kw">try</span> testing.expect(rotl(<span class="tok-builtin">@Vector</span>(<span class="tok-number">1</span>, <span class="tok-type">u32</span>), <span class="tok-builtin">@Vector</span>(<span class="tok-number">1</span>, <span class="tok-type">u32</span>){<span class="tok-number">1</span> &lt;&lt; <span class="tok-number">31</span>}, <span class="tok-builtin">@as</span>(<span class="tok-type">isize</span>, -<span class="tok-number">1</span>))[<span class="tok-number">0</span>] == <span class="tok-builtin">@as</span>(<span class="tok-type">u32</span>, <span class="tok-number">1</span>) &lt;&lt; <span class="tok-number">30</span>);</span>
<span class="line" id="L669">}</span>
<span class="line" id="L670"></span>
<span class="line" id="L671"><span class="tok-comment">/// Returns an unsigned int type that can hold the number of bits in T</span></span>
<span class="line" id="L672"><span class="tok-comment">/// - 1. Suitable for 0-based bit indices of T.</span></span>
<span class="line" id="L673"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">Log2Int</span>(<span class="tok-kw">comptime</span> T: <span class="tok-type">type</span>) <span class="tok-type">type</span> {</span>
<span class="line" id="L674">    <span class="tok-comment">// comptime ceil log2</span>
</span>
<span class="line" id="L675">    <span class="tok-kw">comptime</span> <span class="tok-kw">var</span> count = <span class="tok-number">0</span>;</span>
<span class="line" id="L676">    <span class="tok-kw">comptime</span> <span class="tok-kw">var</span> s = <span class="tok-builtin">@typeInfo</span>(T).Int.bits - <span class="tok-number">1</span>;</span>
<span class="line" id="L677">    <span class="tok-kw">inline</span> <span class="tok-kw">while</span> (s != <span class="tok-number">0</span>) : (s &gt;&gt;= <span class="tok-number">1</span>) {</span>
<span class="line" id="L678">        count += <span class="tok-number">1</span>;</span>
<span class="line" id="L679">    }</span>
<span class="line" id="L680"></span>
<span class="line" id="L681">    <span class="tok-kw">return</span> std.meta.Int(.unsigned, count);</span>
<span class="line" id="L682">}</span>
<span class="line" id="L683"></span>
<span class="line" id="L684"><span class="tok-comment">/// Returns an unsigned int type that can hold the number of bits in T.</span></span>
<span class="line" id="L685"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">Log2IntCeil</span>(<span class="tok-kw">comptime</span> T: <span class="tok-type">type</span>) <span class="tok-type">type</span> {</span>
<span class="line" id="L686">    <span class="tok-comment">// comptime ceil log2</span>
</span>
<span class="line" id="L687">    <span class="tok-kw">comptime</span> <span class="tok-kw">var</span> count = <span class="tok-number">0</span>;</span>
<span class="line" id="L688">    <span class="tok-kw">comptime</span> <span class="tok-kw">var</span> s = <span class="tok-builtin">@typeInfo</span>(T).Int.bits;</span>
<span class="line" id="L689">    <span class="tok-kw">inline</span> <span class="tok-kw">while</span> (s != <span class="tok-number">0</span>) : (s &gt;&gt;= <span class="tok-number">1</span>) {</span>
<span class="line" id="L690">        count += <span class="tok-number">1</span>;</span>
<span class="line" id="L691">    }</span>
<span class="line" id="L692"></span>
<span class="line" id="L693">    <span class="tok-kw">return</span> std.meta.Int(.unsigned, count);</span>
<span class="line" id="L694">}</span>
<span class="line" id="L695"></span>
<span class="line" id="L696"><span class="tok-comment">/// Returns the smallest integer type that can hold both from and to.</span></span>
<span class="line" id="L697"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">IntFittingRange</span>(<span class="tok-kw">comptime</span> from: <span class="tok-type">comptime_int</span>, <span class="tok-kw">comptime</span> to: <span class="tok-type">comptime_int</span>) <span class="tok-type">type</span> {</span>
<span class="line" id="L698">    assert(from &lt;= to);</span>
<span class="line" id="L699">    <span class="tok-kw">if</span> (from == <span class="tok-number">0</span> <span class="tok-kw">and</span> to == <span class="tok-number">0</span>) {</span>
<span class="line" id="L700">        <span class="tok-kw">return</span> <span class="tok-type">u0</span>;</span>
<span class="line" id="L701">    }</span>
<span class="line" id="L702">    <span class="tok-kw">const</span> signedness: std.builtin.Signedness = <span class="tok-kw">if</span> (from &lt; <span class="tok-number">0</span>) .signed <span class="tok-kw">else</span> .unsigned;</span>
<span class="line" id="L703">    <span class="tok-kw">const</span> largest_positive_integer = max(<span class="tok-kw">if</span> (from &lt; <span class="tok-number">0</span>) (-from) - <span class="tok-number">1</span> <span class="tok-kw">else</span> from, to); <span class="tok-comment">// two's complement</span>
</span>
<span class="line" id="L704">    <span class="tok-kw">const</span> base = log2(largest_positive_integer);</span>
<span class="line" id="L705">    <span class="tok-kw">const</span> upper = (<span class="tok-number">1</span> &lt;&lt; base) - <span class="tok-number">1</span>;</span>
<span class="line" id="L706">    <span class="tok-kw">var</span> magnitude_bits = <span class="tok-kw">if</span> (upper &gt;= largest_positive_integer) base <span class="tok-kw">else</span> base + <span class="tok-number">1</span>;</span>
<span class="line" id="L707">    <span class="tok-kw">if</span> (signedness == .signed) {</span>
<span class="line" id="L708">        magnitude_bits += <span class="tok-number">1</span>;</span>
<span class="line" id="L709">    }</span>
<span class="line" id="L710">    <span class="tok-kw">return</span> std.meta.Int(signedness, magnitude_bits);</span>
<span class="line" id="L711">}</span>
<span class="line" id="L712"></span>
<span class="line" id="L713"><span class="tok-kw">test</span> <span class="tok-str">&quot;IntFittingRange&quot;</span> {</span>
<span class="line" id="L714">    <span class="tok-kw">try</span> testing.expect(IntFittingRange(<span class="tok-number">0</span>, <span class="tok-number">0</span>) == <span class="tok-type">u0</span>);</span>
<span class="line" id="L715">    <span class="tok-kw">try</span> testing.expect(IntFittingRange(<span class="tok-number">0</span>, <span class="tok-number">1</span>) == <span class="tok-type">u1</span>);</span>
<span class="line" id="L716">    <span class="tok-kw">try</span> testing.expect(IntFittingRange(<span class="tok-number">0</span>, <span class="tok-number">2</span>) == <span class="tok-type">u2</span>);</span>
<span class="line" id="L717">    <span class="tok-kw">try</span> testing.expect(IntFittingRange(<span class="tok-number">0</span>, <span class="tok-number">3</span>) == <span class="tok-type">u2</span>);</span>
<span class="line" id="L718">    <span class="tok-kw">try</span> testing.expect(IntFittingRange(<span class="tok-number">0</span>, <span class="tok-number">4</span>) == <span class="tok-type">u3</span>);</span>
<span class="line" id="L719">    <span class="tok-kw">try</span> testing.expect(IntFittingRange(<span class="tok-number">0</span>, <span class="tok-number">7</span>) == <span class="tok-type">u3</span>);</span>
<span class="line" id="L720">    <span class="tok-kw">try</span> testing.expect(IntFittingRange(<span class="tok-number">0</span>, <span class="tok-number">8</span>) == <span class="tok-type">u4</span>);</span>
<span class="line" id="L721">    <span class="tok-kw">try</span> testing.expect(IntFittingRange(<span class="tok-number">0</span>, <span class="tok-number">9</span>) == <span class="tok-type">u4</span>);</span>
<span class="line" id="L722">    <span class="tok-kw">try</span> testing.expect(IntFittingRange(<span class="tok-number">0</span>, <span class="tok-number">15</span>) == <span class="tok-type">u4</span>);</span>
<span class="line" id="L723">    <span class="tok-kw">try</span> testing.expect(IntFittingRange(<span class="tok-number">0</span>, <span class="tok-number">16</span>) == <span class="tok-type">u5</span>);</span>
<span class="line" id="L724">    <span class="tok-kw">try</span> testing.expect(IntFittingRange(<span class="tok-number">0</span>, <span class="tok-number">17</span>) == <span class="tok-type">u5</span>);</span>
<span class="line" id="L725">    <span class="tok-kw">try</span> testing.expect(IntFittingRange(<span class="tok-number">0</span>, <span class="tok-number">4095</span>) == <span class="tok-type">u12</span>);</span>
<span class="line" id="L726">    <span class="tok-kw">try</span> testing.expect(IntFittingRange(<span class="tok-number">2000</span>, <span class="tok-number">4095</span>) == <span class="tok-type">u12</span>);</span>
<span class="line" id="L727">    <span class="tok-kw">try</span> testing.expect(IntFittingRange(<span class="tok-number">0</span>, <span class="tok-number">4096</span>) == <span class="tok-type">u13</span>);</span>
<span class="line" id="L728">    <span class="tok-kw">try</span> testing.expect(IntFittingRange(<span class="tok-number">2000</span>, <span class="tok-number">4096</span>) == <span class="tok-type">u13</span>);</span>
<span class="line" id="L729">    <span class="tok-kw">try</span> testing.expect(IntFittingRange(<span class="tok-number">0</span>, <span class="tok-number">4097</span>) == <span class="tok-type">u13</span>);</span>
<span class="line" id="L730">    <span class="tok-kw">try</span> testing.expect(IntFittingRange(<span class="tok-number">2000</span>, <span class="tok-number">4097</span>) == <span class="tok-type">u13</span>);</span>
<span class="line" id="L731">    <span class="tok-kw">try</span> testing.expect(IntFittingRange(<span class="tok-number">0</span>, <span class="tok-number">123456789123456798123456789</span>) == <span class="tok-type">u87</span>);</span>
<span class="line" id="L732">    <span class="tok-kw">try</span> testing.expect(IntFittingRange(<span class="tok-number">0</span>, <span class="tok-number">123456789123456798123456789123456789123456798123456789</span>) == <span class="tok-type">u177</span>);</span>
<span class="line" id="L733"></span>
<span class="line" id="L734">    <span class="tok-kw">try</span> testing.expect(IntFittingRange(-<span class="tok-number">1</span>, -<span class="tok-number">1</span>) == <span class="tok-type">i1</span>);</span>
<span class="line" id="L735">    <span class="tok-kw">try</span> testing.expect(IntFittingRange(-<span class="tok-number">1</span>, <span class="tok-number">0</span>) == <span class="tok-type">i1</span>);</span>
<span class="line" id="L736">    <span class="tok-kw">try</span> testing.expect(IntFittingRange(-<span class="tok-number">1</span>, <span class="tok-number">1</span>) == <span class="tok-type">i2</span>);</span>
<span class="line" id="L737">    <span class="tok-kw">try</span> testing.expect(IntFittingRange(-<span class="tok-number">2</span>, -<span class="tok-number">2</span>) == <span class="tok-type">i2</span>);</span>
<span class="line" id="L738">    <span class="tok-kw">try</span> testing.expect(IntFittingRange(-<span class="tok-number">2</span>, -<span class="tok-number">1</span>) == <span class="tok-type">i2</span>);</span>
<span class="line" id="L739">    <span class="tok-kw">try</span> testing.expect(IntFittingRange(-<span class="tok-number">2</span>, <span class="tok-number">0</span>) == <span class="tok-type">i2</span>);</span>
<span class="line" id="L740">    <span class="tok-kw">try</span> testing.expect(IntFittingRange(-<span class="tok-number">2</span>, <span class="tok-number">1</span>) == <span class="tok-type">i2</span>);</span>
<span class="line" id="L741">    <span class="tok-kw">try</span> testing.expect(IntFittingRange(-<span class="tok-number">2</span>, <span class="tok-number">2</span>) == <span class="tok-type">i3</span>);</span>
<span class="line" id="L742">    <span class="tok-kw">try</span> testing.expect(IntFittingRange(-<span class="tok-number">1</span>, <span class="tok-number">2</span>) == <span class="tok-type">i3</span>);</span>
<span class="line" id="L743">    <span class="tok-kw">try</span> testing.expect(IntFittingRange(-<span class="tok-number">1</span>, <span class="tok-number">3</span>) == <span class="tok-type">i3</span>);</span>
<span class="line" id="L744">    <span class="tok-kw">try</span> testing.expect(IntFittingRange(-<span class="tok-number">1</span>, <span class="tok-number">4</span>) == <span class="tok-type">i4</span>);</span>
<span class="line" id="L745">    <span class="tok-kw">try</span> testing.expect(IntFittingRange(-<span class="tok-number">1</span>, <span class="tok-number">7</span>) == <span class="tok-type">i4</span>);</span>
<span class="line" id="L746">    <span class="tok-kw">try</span> testing.expect(IntFittingRange(-<span class="tok-number">1</span>, <span class="tok-number">8</span>) == <span class="tok-type">i5</span>);</span>
<span class="line" id="L747">    <span class="tok-kw">try</span> testing.expect(IntFittingRange(-<span class="tok-number">1</span>, <span class="tok-number">9</span>) == <span class="tok-type">i5</span>);</span>
<span class="line" id="L748">    <span class="tok-kw">try</span> testing.expect(IntFittingRange(-<span class="tok-number">1</span>, <span class="tok-number">15</span>) == <span class="tok-type">i5</span>);</span>
<span class="line" id="L749">    <span class="tok-kw">try</span> testing.expect(IntFittingRange(-<span class="tok-number">1</span>, <span class="tok-number">16</span>) == <span class="tok-type">i6</span>);</span>
<span class="line" id="L750">    <span class="tok-kw">try</span> testing.expect(IntFittingRange(-<span class="tok-number">1</span>, <span class="tok-number">17</span>) == <span class="tok-type">i6</span>);</span>
<span class="line" id="L751">    <span class="tok-kw">try</span> testing.expect(IntFittingRange(-<span class="tok-number">1</span>, <span class="tok-number">4095</span>) == <span class="tok-type">i13</span>);</span>
<span class="line" id="L752">    <span class="tok-kw">try</span> testing.expect(IntFittingRange(-<span class="tok-number">4096</span>, <span class="tok-number">4095</span>) == <span class="tok-type">i13</span>);</span>
<span class="line" id="L753">    <span class="tok-kw">try</span> testing.expect(IntFittingRange(-<span class="tok-number">1</span>, <span class="tok-number">4096</span>) == <span class="tok-type">i14</span>);</span>
<span class="line" id="L754">    <span class="tok-kw">try</span> testing.expect(IntFittingRange(-<span class="tok-number">4097</span>, <span class="tok-number">4095</span>) == <span class="tok-type">i14</span>);</span>
<span class="line" id="L755">    <span class="tok-kw">try</span> testing.expect(IntFittingRange(-<span class="tok-number">1</span>, <span class="tok-number">4097</span>) == <span class="tok-type">i14</span>);</span>
<span class="line" id="L756">    <span class="tok-kw">try</span> testing.expect(IntFittingRange(-<span class="tok-number">1</span>, <span class="tok-number">123456789123456798123456789</span>) == <span class="tok-type">i88</span>);</span>
<span class="line" id="L757">    <span class="tok-kw">try</span> testing.expect(IntFittingRange(-<span class="tok-number">1</span>, <span class="tok-number">123456789123456798123456789123456789123456798123456789</span>) == <span class="tok-type">i178</span>);</span>
<span class="line" id="L758">}</span>
<span class="line" id="L759"></span>
<span class="line" id="L760"><span class="tok-kw">test</span> <span class="tok-str">&quot;overflow functions&quot;</span> {</span>
<span class="line" id="L761">    <span class="tok-kw">try</span> testOverflow();</span>
<span class="line" id="L762">    <span class="tok-kw">comptime</span> <span class="tok-kw">try</span> testOverflow();</span>
<span class="line" id="L763">}</span>
<span class="line" id="L764"></span>
<span class="line" id="L765"><span class="tok-kw">fn</span> <span class="tok-fn">testOverflow</span>() !<span class="tok-type">void</span> {</span>
<span class="line" id="L766">    <span class="tok-kw">try</span> testing.expect((mul(<span class="tok-type">i32</span>, <span class="tok-number">3</span>, <span class="tok-number">4</span>) <span class="tok-kw">catch</span> <span class="tok-kw">unreachable</span>) == <span class="tok-number">12</span>);</span>
<span class="line" id="L767">    <span class="tok-kw">try</span> testing.expect((add(<span class="tok-type">i32</span>, <span class="tok-number">3</span>, <span class="tok-number">4</span>) <span class="tok-kw">catch</span> <span class="tok-kw">unreachable</span>) == <span class="tok-number">7</span>);</span>
<span class="line" id="L768">    <span class="tok-kw">try</span> testing.expect((sub(<span class="tok-type">i32</span>, <span class="tok-number">3</span>, <span class="tok-number">4</span>) <span class="tok-kw">catch</span> <span class="tok-kw">unreachable</span>) == -<span class="tok-number">1</span>);</span>
<span class="line" id="L769">    <span class="tok-kw">try</span> testing.expect((shlExact(<span class="tok-type">i32</span>, <span class="tok-number">0b11</span>, <span class="tok-number">4</span>) <span class="tok-kw">catch</span> <span class="tok-kw">unreachable</span>) == <span class="tok-number">0b110000</span>);</span>
<span class="line" id="L770">}</span>
<span class="line" id="L771"></span>
<span class="line" id="L772"><span class="tok-comment">/// Returns the absolute value of x, where x is a value of an integer</span></span>
<span class="line" id="L773"><span class="tok-comment">/// type.</span></span>
<span class="line" id="L774"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">absInt</span>(x: <span class="tok-kw">anytype</span>) !<span class="tok-builtin">@TypeOf</span>(x) {</span>
<span class="line" id="L775">    <span class="tok-kw">const</span> T = <span class="tok-builtin">@TypeOf</span>(x);</span>
<span class="line" id="L776">    <span class="tok-kw">comptime</span> assert(<span class="tok-builtin">@typeInfo</span>(T) == .Int); <span class="tok-comment">// must pass an integer to absInt</span>
</span>
<span class="line" id="L777">    <span class="tok-kw">comptime</span> assert(<span class="tok-builtin">@typeInfo</span>(T).Int.signedness == .signed); <span class="tok-comment">// must pass a signed integer to absInt</span>
</span>
<span class="line" id="L778"></span>
<span class="line" id="L779">    <span class="tok-kw">if</span> (x == minInt(<span class="tok-builtin">@TypeOf</span>(x))) {</span>
<span class="line" id="L780">        <span class="tok-kw">return</span> <span class="tok-kw">error</span>.Overflow;</span>
<span class="line" id="L781">    } <span class="tok-kw">else</span> {</span>
<span class="line" id="L782">        <span class="tok-builtin">@setRuntimeSafety</span>(<span class="tok-null">false</span>);</span>
<span class="line" id="L783">        <span class="tok-kw">return</span> <span class="tok-kw">if</span> (x &lt; <span class="tok-number">0</span>) -x <span class="tok-kw">else</span> x;</span>
<span class="line" id="L784">    }</span>
<span class="line" id="L785">}</span>
<span class="line" id="L786"></span>
<span class="line" id="L787"><span class="tok-kw">test</span> <span class="tok-str">&quot;absInt&quot;</span> {</span>
<span class="line" id="L788">    <span class="tok-kw">try</span> testAbsInt();</span>
<span class="line" id="L789">    <span class="tok-kw">comptime</span> <span class="tok-kw">try</span> testAbsInt();</span>
<span class="line" id="L790">}</span>
<span class="line" id="L791"><span class="tok-kw">fn</span> <span class="tok-fn">testAbsInt</span>() !<span class="tok-type">void</span> {</span>
<span class="line" id="L792">    <span class="tok-kw">try</span> testing.expect((absInt(<span class="tok-builtin">@as</span>(<span class="tok-type">i32</span>, -<span class="tok-number">10</span>)) <span class="tok-kw">catch</span> <span class="tok-kw">unreachable</span>) == <span class="tok-number">10</span>);</span>
<span class="line" id="L793">    <span class="tok-kw">try</span> testing.expect((absInt(<span class="tok-builtin">@as</span>(<span class="tok-type">i32</span>, <span class="tok-number">10</span>)) <span class="tok-kw">catch</span> <span class="tok-kw">unreachable</span>) == <span class="tok-number">10</span>);</span>
<span class="line" id="L794">}</span>
<span class="line" id="L795"></span>
<span class="line" id="L796"><span class="tok-comment">/// Divide numerator by denominator, rounding toward zero. Returns an</span></span>
<span class="line" id="L797"><span class="tok-comment">/// error on overflow or when denominator is zero.</span></span>
<span class="line" id="L798"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">divTrunc</span>(<span class="tok-kw">comptime</span> T: <span class="tok-type">type</span>, numerator: T, denominator: T) !T {</span>
<span class="line" id="L799">    <span class="tok-builtin">@setRuntimeSafety</span>(<span class="tok-null">false</span>);</span>
<span class="line" id="L800">    <span class="tok-kw">if</span> (denominator == <span class="tok-number">0</span>) <span class="tok-kw">return</span> <span class="tok-kw">error</span>.DivisionByZero;</span>
<span class="line" id="L801">    <span class="tok-kw">if</span> (<span class="tok-builtin">@typeInfo</span>(T) == .Int <span class="tok-kw">and</span> <span class="tok-builtin">@typeInfo</span>(T).Int.signedness == .signed <span class="tok-kw">and</span> numerator == minInt(T) <span class="tok-kw">and</span> denominator == -<span class="tok-number">1</span>) <span class="tok-kw">return</span> <span class="tok-kw">error</span>.Overflow;</span>
<span class="line" id="L802">    <span class="tok-kw">return</span> <span class="tok-builtin">@divTrunc</span>(numerator, denominator);</span>
<span class="line" id="L803">}</span>
<span class="line" id="L804"></span>
<span class="line" id="L805"><span class="tok-kw">test</span> <span class="tok-str">&quot;divTrunc&quot;</span> {</span>
<span class="line" id="L806">    <span class="tok-kw">try</span> testDivTrunc();</span>
<span class="line" id="L807">    <span class="tok-kw">comptime</span> <span class="tok-kw">try</span> testDivTrunc();</span>
<span class="line" id="L808">}</span>
<span class="line" id="L809"><span class="tok-kw">fn</span> <span class="tok-fn">testDivTrunc</span>() !<span class="tok-type">void</span> {</span>
<span class="line" id="L810">    <span class="tok-kw">try</span> testing.expect((divTrunc(<span class="tok-type">i32</span>, <span class="tok-number">5</span>, <span class="tok-number">3</span>) <span class="tok-kw">catch</span> <span class="tok-kw">unreachable</span>) == <span class="tok-number">1</span>);</span>
<span class="line" id="L811">    <span class="tok-kw">try</span> testing.expect((divTrunc(<span class="tok-type">i32</span>, -<span class="tok-number">5</span>, <span class="tok-number">3</span>) <span class="tok-kw">catch</span> <span class="tok-kw">unreachable</span>) == -<span class="tok-number">1</span>);</span>
<span class="line" id="L812">    <span class="tok-kw">try</span> testing.expectError(<span class="tok-kw">error</span>.DivisionByZero, divTrunc(<span class="tok-type">i8</span>, -<span class="tok-number">5</span>, <span class="tok-number">0</span>));</span>
<span class="line" id="L813">    <span class="tok-kw">try</span> testing.expectError(<span class="tok-kw">error</span>.Overflow, divTrunc(<span class="tok-type">i8</span>, -<span class="tok-number">128</span>, -<span class="tok-number">1</span>));</span>
<span class="line" id="L814"></span>
<span class="line" id="L815">    <span class="tok-kw">try</span> testing.expect((divTrunc(<span class="tok-type">f32</span>, <span class="tok-number">5.0</span>, <span class="tok-number">3.0</span>) <span class="tok-kw">catch</span> <span class="tok-kw">unreachable</span>) == <span class="tok-number">1.0</span>);</span>
<span class="line" id="L816">    <span class="tok-kw">try</span> testing.expect((divTrunc(<span class="tok-type">f32</span>, -<span class="tok-number">5.0</span>, <span class="tok-number">3.0</span>) <span class="tok-kw">catch</span> <span class="tok-kw">unreachable</span>) == -<span class="tok-number">1.0</span>);</span>
<span class="line" id="L817">}</span>
<span class="line" id="L818"></span>
<span class="line" id="L819"><span class="tok-comment">/// Divide numerator by denominator, rounding toward negative</span></span>
<span class="line" id="L820"><span class="tok-comment">/// infinity. Returns an error on overflow or when denominator is</span></span>
<span class="line" id="L821"><span class="tok-comment">/// zero.</span></span>
<span class="line" id="L822"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">divFloor</span>(<span class="tok-kw">comptime</span> T: <span class="tok-type">type</span>, numerator: T, denominator: T) !T {</span>
<span class="line" id="L823">    <span class="tok-builtin">@setRuntimeSafety</span>(<span class="tok-null">false</span>);</span>
<span class="line" id="L824">    <span class="tok-kw">if</span> (denominator == <span class="tok-number">0</span>) <span class="tok-kw">return</span> <span class="tok-kw">error</span>.DivisionByZero;</span>
<span class="line" id="L825">    <span class="tok-kw">if</span> (<span class="tok-builtin">@typeInfo</span>(T) == .Int <span class="tok-kw">and</span> <span class="tok-builtin">@typeInfo</span>(T).Int.signedness == .signed <span class="tok-kw">and</span> numerator == minInt(T) <span class="tok-kw">and</span> denominator == -<span class="tok-number">1</span>) <span class="tok-kw">return</span> <span class="tok-kw">error</span>.Overflow;</span>
<span class="line" id="L826">    <span class="tok-kw">return</span> <span class="tok-builtin">@divFloor</span>(numerator, denominator);</span>
<span class="line" id="L827">}</span>
<span class="line" id="L828"></span>
<span class="line" id="L829"><span class="tok-kw">test</span> <span class="tok-str">&quot;divFloor&quot;</span> {</span>
<span class="line" id="L830">    <span class="tok-kw">try</span> testDivFloor();</span>
<span class="line" id="L831">    <span class="tok-kw">comptime</span> <span class="tok-kw">try</span> testDivFloor();</span>
<span class="line" id="L832">}</span>
<span class="line" id="L833"><span class="tok-kw">fn</span> <span class="tok-fn">testDivFloor</span>() !<span class="tok-type">void</span> {</span>
<span class="line" id="L834">    <span class="tok-kw">try</span> testing.expect((divFloor(<span class="tok-type">i32</span>, <span class="tok-number">5</span>, <span class="tok-number">3</span>) <span class="tok-kw">catch</span> <span class="tok-kw">unreachable</span>) == <span class="tok-number">1</span>);</span>
<span class="line" id="L835">    <span class="tok-kw">try</span> testing.expect((divFloor(<span class="tok-type">i32</span>, -<span class="tok-number">5</span>, <span class="tok-number">3</span>) <span class="tok-kw">catch</span> <span class="tok-kw">unreachable</span>) == -<span class="tok-number">2</span>);</span>
<span class="line" id="L836">    <span class="tok-kw">try</span> testing.expectError(<span class="tok-kw">error</span>.DivisionByZero, divFloor(<span class="tok-type">i8</span>, -<span class="tok-number">5</span>, <span class="tok-number">0</span>));</span>
<span class="line" id="L837">    <span class="tok-kw">try</span> testing.expectError(<span class="tok-kw">error</span>.Overflow, divFloor(<span class="tok-type">i8</span>, -<span class="tok-number">128</span>, -<span class="tok-number">1</span>));</span>
<span class="line" id="L838"></span>
<span class="line" id="L839">    <span class="tok-kw">try</span> testing.expect((divFloor(<span class="tok-type">f32</span>, <span class="tok-number">5.0</span>, <span class="tok-number">3.0</span>) <span class="tok-kw">catch</span> <span class="tok-kw">unreachable</span>) == <span class="tok-number">1.0</span>);</span>
<span class="line" id="L840">    <span class="tok-kw">try</span> testing.expect((divFloor(<span class="tok-type">f32</span>, -<span class="tok-number">5.0</span>, <span class="tok-number">3.0</span>) <span class="tok-kw">catch</span> <span class="tok-kw">unreachable</span>) == -<span class="tok-number">2.0</span>);</span>
<span class="line" id="L841">}</span>
<span class="line" id="L842"></span>
<span class="line" id="L843"><span class="tok-comment">/// Divide numerator by denominator, rounding toward positive</span></span>
<span class="line" id="L844"><span class="tok-comment">/// infinity. Returns an error on overflow or when denominator is</span></span>
<span class="line" id="L845"><span class="tok-comment">/// zero.</span></span>
<span class="line" id="L846"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">divCeil</span>(<span class="tok-kw">comptime</span> T: <span class="tok-type">type</span>, numerator: T, denominator: T) !T {</span>
<span class="line" id="L847">    <span class="tok-builtin">@setRuntimeSafety</span>(<span class="tok-null">false</span>);</span>
<span class="line" id="L848">    <span class="tok-kw">if</span> (<span class="tok-kw">comptime</span> std.meta.trait.isNumber(T) <span class="tok-kw">and</span> denominator == <span class="tok-number">0</span>) <span class="tok-kw">return</span> <span class="tok-kw">error</span>.DivisionByZero;</span>
<span class="line" id="L849">    <span class="tok-kw">const</span> info = <span class="tok-builtin">@typeInfo</span>(T);</span>
<span class="line" id="L850">    <span class="tok-kw">switch</span> (info) {</span>
<span class="line" id="L851">        .ComptimeFloat, .Float =&gt; <span class="tok-kw">return</span> <span class="tok-builtin">@ceil</span>(numerator / denominator),</span>
<span class="line" id="L852">        .ComptimeInt, .Int =&gt; {</span>
<span class="line" id="L853">            <span class="tok-kw">if</span> (numerator &lt; <span class="tok-number">0</span> <span class="tok-kw">and</span> denominator &lt; <span class="tok-number">0</span>) {</span>
<span class="line" id="L854">                <span class="tok-kw">if</span> (info == .Int <span class="tok-kw">and</span> numerator == minInt(T) <span class="tok-kw">and</span> denominator == -<span class="tok-number">1</span>)</span>
<span class="line" id="L855">                    <span class="tok-kw">return</span> <span class="tok-kw">error</span>.Overflow;</span>
<span class="line" id="L856">                <span class="tok-kw">return</span> <span class="tok-builtin">@divFloor</span>(numerator + <span class="tok-number">1</span>, denominator) + <span class="tok-number">1</span>;</span>
<span class="line" id="L857">            }</span>
<span class="line" id="L858">            <span class="tok-kw">if</span> (numerator &gt; <span class="tok-number">0</span> <span class="tok-kw">and</span> denominator &gt; <span class="tok-number">0</span>)</span>
<span class="line" id="L859">                <span class="tok-kw">return</span> <span class="tok-builtin">@divFloor</span>(numerator - <span class="tok-number">1</span>, denominator) + <span class="tok-number">1</span>;</span>
<span class="line" id="L860">            <span class="tok-kw">return</span> <span class="tok-builtin">@divTrunc</span>(numerator, denominator);</span>
<span class="line" id="L861">        },</span>
<span class="line" id="L862">        <span class="tok-kw">else</span> =&gt; <span class="tok-builtin">@compileError</span>(<span class="tok-str">&quot;divCeil unsupported on &quot;</span> ++ <span class="tok-builtin">@typeName</span>(T)),</span>
<span class="line" id="L863">    }</span>
<span class="line" id="L864">}</span>
<span class="line" id="L865"></span>
<span class="line" id="L866"><span class="tok-kw">test</span> <span class="tok-str">&quot;divCeil&quot;</span> {</span>
<span class="line" id="L867">    <span class="tok-kw">try</span> testDivCeil();</span>
<span class="line" id="L868">    <span class="tok-kw">comptime</span> <span class="tok-kw">try</span> testDivCeil();</span>
<span class="line" id="L869">}</span>
<span class="line" id="L870"><span class="tok-kw">fn</span> <span class="tok-fn">testDivCeil</span>() !<span class="tok-type">void</span> {</span>
<span class="line" id="L871">    <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">i32</span>, <span class="tok-number">2</span>), divCeil(<span class="tok-type">i32</span>, <span class="tok-number">5</span>, <span class="tok-number">3</span>) <span class="tok-kw">catch</span> <span class="tok-kw">unreachable</span>);</span>
<span class="line" id="L872">    <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">i32</span>, -<span class="tok-number">1</span>), divCeil(<span class="tok-type">i32</span>, -<span class="tok-number">5</span>, <span class="tok-number">3</span>) <span class="tok-kw">catch</span> <span class="tok-kw">unreachable</span>);</span>
<span class="line" id="L873">    <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">i32</span>, -<span class="tok-number">1</span>), divCeil(<span class="tok-type">i32</span>, <span class="tok-number">5</span>, -<span class="tok-number">3</span>) <span class="tok-kw">catch</span> <span class="tok-kw">unreachable</span>);</span>
<span class="line" id="L874">    <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">i32</span>, <span class="tok-number">2</span>), divCeil(<span class="tok-type">i32</span>, -<span class="tok-number">5</span>, -<span class="tok-number">3</span>) <span class="tok-kw">catch</span> <span class="tok-kw">unreachable</span>);</span>
<span class="line" id="L875">    <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">i32</span>, <span class="tok-number">0</span>), divCeil(<span class="tok-type">i32</span>, <span class="tok-number">0</span>, <span class="tok-number">5</span>) <span class="tok-kw">catch</span> <span class="tok-kw">unreachable</span>);</span>
<span class="line" id="L876">    <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">u32</span>, <span class="tok-number">0</span>), divCeil(<span class="tok-type">u32</span>, <span class="tok-number">0</span>, <span class="tok-number">5</span>) <span class="tok-kw">catch</span> <span class="tok-kw">unreachable</span>);</span>
<span class="line" id="L877">    <span class="tok-kw">try</span> testing.expectError(<span class="tok-kw">error</span>.DivisionByZero, divCeil(<span class="tok-type">i8</span>, -<span class="tok-number">5</span>, <span class="tok-number">0</span>));</span>
<span class="line" id="L878">    <span class="tok-kw">try</span> testing.expectError(<span class="tok-kw">error</span>.Overflow, divCeil(<span class="tok-type">i8</span>, -<span class="tok-number">128</span>, -<span class="tok-number">1</span>));</span>
<span class="line" id="L879"></span>
<span class="line" id="L880">    <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">f32</span>, <span class="tok-number">0.0</span>), divCeil(<span class="tok-type">f32</span>, <span class="tok-number">0.0</span>, <span class="tok-number">5.0</span>) <span class="tok-kw">catch</span> <span class="tok-kw">unreachable</span>);</span>
<span class="line" id="L881">    <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">f32</span>, <span class="tok-number">2.0</span>), divCeil(<span class="tok-type">f32</span>, <span class="tok-number">5.0</span>, <span class="tok-number">3.0</span>) <span class="tok-kw">catch</span> <span class="tok-kw">unreachable</span>);</span>
<span class="line" id="L882">    <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">f32</span>, -<span class="tok-number">1.0</span>), divCeil(<span class="tok-type">f32</span>, -<span class="tok-number">5.0</span>, <span class="tok-number">3.0</span>) <span class="tok-kw">catch</span> <span class="tok-kw">unreachable</span>);</span>
<span class="line" id="L883">    <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">f32</span>, -<span class="tok-number">1.0</span>), divCeil(<span class="tok-type">f32</span>, <span class="tok-number">5.0</span>, -<span class="tok-number">3.0</span>) <span class="tok-kw">catch</span> <span class="tok-kw">unreachable</span>);</span>
<span class="line" id="L884">    <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">f32</span>, <span class="tok-number">2.0</span>), divCeil(<span class="tok-type">f32</span>, -<span class="tok-number">5.0</span>, -<span class="tok-number">3.0</span>) <span class="tok-kw">catch</span> <span class="tok-kw">unreachable</span>);</span>
<span class="line" id="L885"></span>
<span class="line" id="L886">    <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-number">6</span>, divCeil(<span class="tok-type">comptime_int</span>, <span class="tok-number">23</span>, <span class="tok-number">4</span>) <span class="tok-kw">catch</span> <span class="tok-kw">unreachable</span>);</span>
<span class="line" id="L887">    <span class="tok-kw">try</span> testing.expectEqual(-<span class="tok-number">5</span>, divCeil(<span class="tok-type">comptime_int</span>, -<span class="tok-number">23</span>, <span class="tok-number">4</span>) <span class="tok-kw">catch</span> <span class="tok-kw">unreachable</span>);</span>
<span class="line" id="L888">    <span class="tok-kw">try</span> testing.expectEqual(-<span class="tok-number">5</span>, divCeil(<span class="tok-type">comptime_int</span>, <span class="tok-number">23</span>, -<span class="tok-number">4</span>) <span class="tok-kw">catch</span> <span class="tok-kw">unreachable</span>);</span>
<span class="line" id="L889">    <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-number">6</span>, divCeil(<span class="tok-type">comptime_int</span>, -<span class="tok-number">23</span>, -<span class="tok-number">4</span>) <span class="tok-kw">catch</span> <span class="tok-kw">unreachable</span>);</span>
<span class="line" id="L890">    <span class="tok-kw">try</span> testing.expectError(<span class="tok-kw">error</span>.DivisionByZero, divCeil(<span class="tok-type">comptime_int</span>, <span class="tok-number">23</span>, <span class="tok-number">0</span>));</span>
<span class="line" id="L891"></span>
<span class="line" id="L892">    <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-number">6.0</span>, divCeil(<span class="tok-type">comptime_float</span>, <span class="tok-number">23.0</span>, <span class="tok-number">4.0</span>) <span class="tok-kw">catch</span> <span class="tok-kw">unreachable</span>);</span>
<span class="line" id="L893">    <span class="tok-kw">try</span> testing.expectEqual(-<span class="tok-number">5.0</span>, divCeil(<span class="tok-type">comptime_float</span>, -<span class="tok-number">23.0</span>, <span class="tok-number">4.0</span>) <span class="tok-kw">catch</span> <span class="tok-kw">unreachable</span>);</span>
<span class="line" id="L894">    <span class="tok-kw">try</span> testing.expectEqual(-<span class="tok-number">5.0</span>, divCeil(<span class="tok-type">comptime_float</span>, <span class="tok-number">23.0</span>, -<span class="tok-number">4.0</span>) <span class="tok-kw">catch</span> <span class="tok-kw">unreachable</span>);</span>
<span class="line" id="L895">    <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-number">6.0</span>, divCeil(<span class="tok-type">comptime_float</span>, -<span class="tok-number">23.0</span>, -<span class="tok-number">4.0</span>) <span class="tok-kw">catch</span> <span class="tok-kw">unreachable</span>);</span>
<span class="line" id="L896">    <span class="tok-kw">try</span> testing.expectError(<span class="tok-kw">error</span>.DivisionByZero, divCeil(<span class="tok-type">comptime_float</span>, <span class="tok-number">23.0</span>, <span class="tok-number">0.0</span>));</span>
<span class="line" id="L897">}</span>
<span class="line" id="L898"></span>
<span class="line" id="L899"><span class="tok-comment">/// Divide numerator by denominator. Return an error if quotient is</span></span>
<span class="line" id="L900"><span class="tok-comment">/// not an integer, denominator is zero, or on overflow.</span></span>
<span class="line" id="L901"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">divExact</span>(<span class="tok-kw">comptime</span> T: <span class="tok-type">type</span>, numerator: T, denominator: T) !T {</span>
<span class="line" id="L902">    <span class="tok-builtin">@setRuntimeSafety</span>(<span class="tok-null">false</span>);</span>
<span class="line" id="L903">    <span class="tok-kw">if</span> (denominator == <span class="tok-number">0</span>) <span class="tok-kw">return</span> <span class="tok-kw">error</span>.DivisionByZero;</span>
<span class="line" id="L904">    <span class="tok-kw">if</span> (<span class="tok-builtin">@typeInfo</span>(T) == .Int <span class="tok-kw">and</span> <span class="tok-builtin">@typeInfo</span>(T).Int.signedness == .signed <span class="tok-kw">and</span> numerator == minInt(T) <span class="tok-kw">and</span> denominator == -<span class="tok-number">1</span>) <span class="tok-kw">return</span> <span class="tok-kw">error</span>.Overflow;</span>
<span class="line" id="L905">    <span class="tok-kw">const</span> result = <span class="tok-builtin">@divTrunc</span>(numerator, denominator);</span>
<span class="line" id="L906">    <span class="tok-kw">if</span> (result * denominator != numerator) <span class="tok-kw">return</span> <span class="tok-kw">error</span>.UnexpectedRemainder;</span>
<span class="line" id="L907">    <span class="tok-kw">return</span> result;</span>
<span class="line" id="L908">}</span>
<span class="line" id="L909"></span>
<span class="line" id="L910"><span class="tok-kw">test</span> <span class="tok-str">&quot;divExact&quot;</span> {</span>
<span class="line" id="L911">    <span class="tok-kw">try</span> testDivExact();</span>
<span class="line" id="L912">    <span class="tok-kw">comptime</span> <span class="tok-kw">try</span> testDivExact();</span>
<span class="line" id="L913">}</span>
<span class="line" id="L914"><span class="tok-kw">fn</span> <span class="tok-fn">testDivExact</span>() !<span class="tok-type">void</span> {</span>
<span class="line" id="L915">    <span class="tok-kw">try</span> testing.expect((divExact(<span class="tok-type">i32</span>, <span class="tok-number">10</span>, <span class="tok-number">5</span>) <span class="tok-kw">catch</span> <span class="tok-kw">unreachable</span>) == <span class="tok-number">2</span>);</span>
<span class="line" id="L916">    <span class="tok-kw">try</span> testing.expect((divExact(<span class="tok-type">i32</span>, -<span class="tok-number">10</span>, <span class="tok-number">5</span>) <span class="tok-kw">catch</span> <span class="tok-kw">unreachable</span>) == -<span class="tok-number">2</span>);</span>
<span class="line" id="L917">    <span class="tok-kw">try</span> testing.expectError(<span class="tok-kw">error</span>.DivisionByZero, divExact(<span class="tok-type">i8</span>, -<span class="tok-number">5</span>, <span class="tok-number">0</span>));</span>
<span class="line" id="L918">    <span class="tok-kw">try</span> testing.expectError(<span class="tok-kw">error</span>.Overflow, divExact(<span class="tok-type">i8</span>, -<span class="tok-number">128</span>, -<span class="tok-number">1</span>));</span>
<span class="line" id="L919">    <span class="tok-kw">try</span> testing.expectError(<span class="tok-kw">error</span>.UnexpectedRemainder, divExact(<span class="tok-type">i32</span>, <span class="tok-number">5</span>, <span class="tok-number">2</span>));</span>
<span class="line" id="L920"></span>
<span class="line" id="L921">    <span class="tok-kw">try</span> testing.expect((divExact(<span class="tok-type">f32</span>, <span class="tok-number">10.0</span>, <span class="tok-number">5.0</span>) <span class="tok-kw">catch</span> <span class="tok-kw">unreachable</span>) == <span class="tok-number">2.0</span>);</span>
<span class="line" id="L922">    <span class="tok-kw">try</span> testing.expect((divExact(<span class="tok-type">f32</span>, -<span class="tok-number">10.0</span>, <span class="tok-number">5.0</span>) <span class="tok-kw">catch</span> <span class="tok-kw">unreachable</span>) == -<span class="tok-number">2.0</span>);</span>
<span class="line" id="L923">    <span class="tok-kw">try</span> testing.expectError(<span class="tok-kw">error</span>.UnexpectedRemainder, divExact(<span class="tok-type">f32</span>, <span class="tok-number">5.0</span>, <span class="tok-number">2.0</span>));</span>
<span class="line" id="L924">}</span>
<span class="line" id="L925"></span>
<span class="line" id="L926"><span class="tok-comment">/// Returns numerator modulo denominator, or an error if denominator is</span></span>
<span class="line" id="L927"><span class="tok-comment">/// zero or negative. Negative numerators never result in negative</span></span>
<span class="line" id="L928"><span class="tok-comment">/// return values.</span></span>
<span class="line" id="L929"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">mod</span>(<span class="tok-kw">comptime</span> T: <span class="tok-type">type</span>, numerator: T, denominator: T) !T {</span>
<span class="line" id="L930">    <span class="tok-builtin">@setRuntimeSafety</span>(<span class="tok-null">false</span>);</span>
<span class="line" id="L931">    <span class="tok-kw">if</span> (denominator == <span class="tok-number">0</span>) <span class="tok-kw">return</span> <span class="tok-kw">error</span>.DivisionByZero;</span>
<span class="line" id="L932">    <span class="tok-kw">if</span> (denominator &lt; <span class="tok-number">0</span>) <span class="tok-kw">return</span> <span class="tok-kw">error</span>.NegativeDenominator;</span>
<span class="line" id="L933">    <span class="tok-kw">return</span> <span class="tok-builtin">@mod</span>(numerator, denominator);</span>
<span class="line" id="L934">}</span>
<span class="line" id="L935"></span>
<span class="line" id="L936"><span class="tok-kw">test</span> <span class="tok-str">&quot;mod&quot;</span> {</span>
<span class="line" id="L937">    <span class="tok-kw">try</span> testMod();</span>
<span class="line" id="L938">    <span class="tok-kw">comptime</span> <span class="tok-kw">try</span> testMod();</span>
<span class="line" id="L939">}</span>
<span class="line" id="L940"><span class="tok-kw">fn</span> <span class="tok-fn">testMod</span>() !<span class="tok-type">void</span> {</span>
<span class="line" id="L941">    <span class="tok-kw">try</span> testing.expect((mod(<span class="tok-type">i32</span>, -<span class="tok-number">5</span>, <span class="tok-number">3</span>) <span class="tok-kw">catch</span> <span class="tok-kw">unreachable</span>) == <span class="tok-number">1</span>);</span>
<span class="line" id="L942">    <span class="tok-kw">try</span> testing.expect((mod(<span class="tok-type">i32</span>, <span class="tok-number">5</span>, <span class="tok-number">3</span>) <span class="tok-kw">catch</span> <span class="tok-kw">unreachable</span>) == <span class="tok-number">2</span>);</span>
<span class="line" id="L943">    <span class="tok-kw">try</span> testing.expectError(<span class="tok-kw">error</span>.NegativeDenominator, mod(<span class="tok-type">i32</span>, <span class="tok-number">10</span>, -<span class="tok-number">1</span>));</span>
<span class="line" id="L944">    <span class="tok-kw">try</span> testing.expectError(<span class="tok-kw">error</span>.DivisionByZero, mod(<span class="tok-type">i32</span>, <span class="tok-number">10</span>, <span class="tok-number">0</span>));</span>
<span class="line" id="L945"></span>
<span class="line" id="L946">    <span class="tok-kw">try</span> testing.expect((mod(<span class="tok-type">f32</span>, -<span class="tok-number">5</span>, <span class="tok-number">3</span>) <span class="tok-kw">catch</span> <span class="tok-kw">unreachable</span>) == <span class="tok-number">1</span>);</span>
<span class="line" id="L947">    <span class="tok-kw">try</span> testing.expect((mod(<span class="tok-type">f32</span>, <span class="tok-number">5</span>, <span class="tok-number">3</span>) <span class="tok-kw">catch</span> <span class="tok-kw">unreachable</span>) == <span class="tok-number">2</span>);</span>
<span class="line" id="L948">    <span class="tok-kw">try</span> testing.expectError(<span class="tok-kw">error</span>.NegativeDenominator, mod(<span class="tok-type">f32</span>, <span class="tok-number">10</span>, -<span class="tok-number">1</span>));</span>
<span class="line" id="L949">    <span class="tok-kw">try</span> testing.expectError(<span class="tok-kw">error</span>.DivisionByZero, mod(<span class="tok-type">f32</span>, <span class="tok-number">10</span>, <span class="tok-number">0</span>));</span>
<span class="line" id="L950">}</span>
<span class="line" id="L951"></span>
<span class="line" id="L952"><span class="tok-comment">/// Returns the remainder when numerator is divided by denominator, or</span></span>
<span class="line" id="L953"><span class="tok-comment">/// an error if denominator is zero or negative. Negative numerators</span></span>
<span class="line" id="L954"><span class="tok-comment">/// can give negative results.</span></span>
<span class="line" id="L955"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">rem</span>(<span class="tok-kw">comptime</span> T: <span class="tok-type">type</span>, numerator: T, denominator: T) !T {</span>
<span class="line" id="L956">    <span class="tok-builtin">@setRuntimeSafety</span>(<span class="tok-null">false</span>);</span>
<span class="line" id="L957">    <span class="tok-kw">if</span> (denominator == <span class="tok-number">0</span>) <span class="tok-kw">return</span> <span class="tok-kw">error</span>.DivisionByZero;</span>
<span class="line" id="L958">    <span class="tok-kw">if</span> (denominator &lt; <span class="tok-number">0</span>) <span class="tok-kw">return</span> <span class="tok-kw">error</span>.NegativeDenominator;</span>
<span class="line" id="L959">    <span class="tok-kw">return</span> <span class="tok-builtin">@rem</span>(numerator, denominator);</span>
<span class="line" id="L960">}</span>
<span class="line" id="L961"></span>
<span class="line" id="L962"><span class="tok-kw">test</span> <span class="tok-str">&quot;rem&quot;</span> {</span>
<span class="line" id="L963">    <span class="tok-kw">try</span> testRem();</span>
<span class="line" id="L964">    <span class="tok-kw">comptime</span> <span class="tok-kw">try</span> testRem();</span>
<span class="line" id="L965">}</span>
<span class="line" id="L966"><span class="tok-kw">fn</span> <span class="tok-fn">testRem</span>() !<span class="tok-type">void</span> {</span>
<span class="line" id="L967">    <span class="tok-kw">try</span> testing.expect((rem(<span class="tok-type">i32</span>, -<span class="tok-number">5</span>, <span class="tok-number">3</span>) <span class="tok-kw">catch</span> <span class="tok-kw">unreachable</span>) == -<span class="tok-number">2</span>);</span>
<span class="line" id="L968">    <span class="tok-kw">try</span> testing.expect((rem(<span class="tok-type">i32</span>, <span class="tok-number">5</span>, <span class="tok-number">3</span>) <span class="tok-kw">catch</span> <span class="tok-kw">unreachable</span>) == <span class="tok-number">2</span>);</span>
<span class="line" id="L969">    <span class="tok-kw">try</span> testing.expectError(<span class="tok-kw">error</span>.NegativeDenominator, rem(<span class="tok-type">i32</span>, <span class="tok-number">10</span>, -<span class="tok-number">1</span>));</span>
<span class="line" id="L970">    <span class="tok-kw">try</span> testing.expectError(<span class="tok-kw">error</span>.DivisionByZero, rem(<span class="tok-type">i32</span>, <span class="tok-number">10</span>, <span class="tok-number">0</span>));</span>
<span class="line" id="L971"></span>
<span class="line" id="L972">    <span class="tok-kw">try</span> testing.expect((rem(<span class="tok-type">f32</span>, -<span class="tok-number">5</span>, <span class="tok-number">3</span>) <span class="tok-kw">catch</span> <span class="tok-kw">unreachable</span>) == -<span class="tok-number">2</span>);</span>
<span class="line" id="L973">    <span class="tok-kw">try</span> testing.expect((rem(<span class="tok-type">f32</span>, <span class="tok-number">5</span>, <span class="tok-number">3</span>) <span class="tok-kw">catch</span> <span class="tok-kw">unreachable</span>) == <span class="tok-number">2</span>);</span>
<span class="line" id="L974">    <span class="tok-kw">try</span> testing.expectError(<span class="tok-kw">error</span>.NegativeDenominator, rem(<span class="tok-type">f32</span>, <span class="tok-number">10</span>, -<span class="tok-number">1</span>));</span>
<span class="line" id="L975">    <span class="tok-kw">try</span> testing.expectError(<span class="tok-kw">error</span>.DivisionByZero, rem(<span class="tok-type">f32</span>, <span class="tok-number">10</span>, <span class="tok-number">0</span>));</span>
<span class="line" id="L976">}</span>
<span class="line" id="L977"></span>
<span class="line" id="L978"><span class="tok-comment">/// Returns the absolute value of a floating point number.</span></span>
<span class="line" id="L979"><span class="tok-comment">/// Uses a dedicated hardware instruction when available.</span></span>
<span class="line" id="L980"><span class="tok-comment">/// This is the same as calling the builtin @fabs</span></span>
<span class="line" id="L981"><span class="tok-kw">pub</span> <span class="tok-kw">inline</span> <span class="tok-kw">fn</span> <span class="tok-fn">fabs</span>(value: <span class="tok-kw">anytype</span>) <span class="tok-builtin">@TypeOf</span>(value) {</span>
<span class="line" id="L982">    <span class="tok-kw">return</span> <span class="tok-builtin">@fabs</span>(value);</span>
<span class="line" id="L983">}</span>
<span class="line" id="L984"></span>
<span class="line" id="L985"><span class="tok-comment">/// Returns the absolute value of the integer parameter.</span></span>
<span class="line" id="L986"><span class="tok-comment">/// Result is an unsigned integer.</span></span>
<span class="line" id="L987"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">absCast</span>(x: <span class="tok-kw">anytype</span>) <span class="tok-kw">switch</span> (<span class="tok-builtin">@typeInfo</span>(<span class="tok-builtin">@TypeOf</span>(x))) {</span>
<span class="line" id="L988">    .ComptimeInt =&gt; <span class="tok-type">comptime_int</span>,</span>
<span class="line" id="L989">    .Int =&gt; |int_info| std.meta.Int(.unsigned, int_info.bits),</span>
<span class="line" id="L990">    <span class="tok-kw">else</span> =&gt; <span class="tok-builtin">@compileError</span>(<span class="tok-str">&quot;absCast only accepts integers&quot;</span>),</span>
<span class="line" id="L991">} {</span>
<span class="line" id="L992">    <span class="tok-kw">switch</span> (<span class="tok-builtin">@typeInfo</span>(<span class="tok-builtin">@TypeOf</span>(x))) {</span>
<span class="line" id="L993">        .ComptimeInt =&gt; {</span>
<span class="line" id="L994">            <span class="tok-kw">if</span> (x &lt; <span class="tok-number">0</span>) {</span>
<span class="line" id="L995">                <span class="tok-kw">return</span> -x;</span>
<span class="line" id="L996">            } <span class="tok-kw">else</span> {</span>
<span class="line" id="L997">                <span class="tok-kw">return</span> x;</span>
<span class="line" id="L998">            }</span>
<span class="line" id="L999">        },</span>
<span class="line" id="L1000">        .Int =&gt; |int_info| {</span>
<span class="line" id="L1001">            <span class="tok-kw">if</span> (int_info.signedness == .unsigned) <span class="tok-kw">return</span> x;</span>
<span class="line" id="L1002">            <span class="tok-kw">const</span> Uint = std.meta.Int(.unsigned, int_info.bits);</span>
<span class="line" id="L1003">            <span class="tok-kw">if</span> (x &lt; <span class="tok-number">0</span>) {</span>
<span class="line" id="L1004">                <span class="tok-kw">return</span> ~<span class="tok-builtin">@bitCast</span>(Uint, x +% -<span class="tok-number">1</span>);</span>
<span class="line" id="L1005">            } <span class="tok-kw">else</span> {</span>
<span class="line" id="L1006">                <span class="tok-kw">return</span> <span class="tok-builtin">@intCast</span>(Uint, x);</span>
<span class="line" id="L1007">            }</span>
<span class="line" id="L1008">        },</span>
<span class="line" id="L1009">        <span class="tok-kw">else</span> =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L1010">    }</span>
<span class="line" id="L1011">}</span>
<span class="line" id="L1012"></span>
<span class="line" id="L1013"><span class="tok-kw">test</span> <span class="tok-str">&quot;absCast&quot;</span> {</span>
<span class="line" id="L1014">    <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">u1</span>, <span class="tok-number">1</span>), absCast(<span class="tok-builtin">@as</span>(<span class="tok-type">i1</span>, -<span class="tok-number">1</span>)));</span>
<span class="line" id="L1015">    <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">u32</span>, <span class="tok-number">999</span>), absCast(<span class="tok-builtin">@as</span>(<span class="tok-type">i32</span>, -<span class="tok-number">999</span>)));</span>
<span class="line" id="L1016">    <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">u32</span>, <span class="tok-number">999</span>), absCast(<span class="tok-builtin">@as</span>(<span class="tok-type">i32</span>, <span class="tok-number">999</span>)));</span>
<span class="line" id="L1017">    <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">u32</span>, -minInt(<span class="tok-type">i32</span>)), absCast(<span class="tok-builtin">@as</span>(<span class="tok-type">i32</span>, minInt(<span class="tok-type">i32</span>))));</span>
<span class="line" id="L1018">    <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-number">999</span>, absCast(-<span class="tok-number">999</span>));</span>
<span class="line" id="L1019">}</span>
<span class="line" id="L1020"></span>
<span class="line" id="L1021"><span class="tok-comment">/// Returns the negation of the integer parameter.</span></span>
<span class="line" id="L1022"><span class="tok-comment">/// Result is a signed integer.</span></span>
<span class="line" id="L1023"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">negateCast</span>(x: <span class="tok-kw">anytype</span>) !std.meta.Int(.signed, <span class="tok-builtin">@bitSizeOf</span>(<span class="tok-builtin">@TypeOf</span>(x))) {</span>
<span class="line" id="L1024">    <span class="tok-kw">if</span> (<span class="tok-builtin">@typeInfo</span>(<span class="tok-builtin">@TypeOf</span>(x)).Int.signedness == .signed) <span class="tok-kw">return</span> negate(x);</span>
<span class="line" id="L1025"></span>
<span class="line" id="L1026">    <span class="tok-kw">const</span> int = std.meta.Int(.signed, <span class="tok-builtin">@bitSizeOf</span>(<span class="tok-builtin">@TypeOf</span>(x)));</span>
<span class="line" id="L1027">    <span class="tok-kw">if</span> (x &gt; -minInt(int)) <span class="tok-kw">return</span> <span class="tok-kw">error</span>.Overflow;</span>
<span class="line" id="L1028"></span>
<span class="line" id="L1029">    <span class="tok-kw">if</span> (x == -minInt(int)) <span class="tok-kw">return</span> minInt(int);</span>
<span class="line" id="L1030"></span>
<span class="line" id="L1031">    <span class="tok-kw">return</span> -<span class="tok-builtin">@intCast</span>(int, x);</span>
<span class="line" id="L1032">}</span>
<span class="line" id="L1033"></span>
<span class="line" id="L1034"><span class="tok-kw">test</span> <span class="tok-str">&quot;negateCast&quot;</span> {</span>
<span class="line" id="L1035">    <span class="tok-kw">try</span> testing.expect((negateCast(<span class="tok-builtin">@as</span>(<span class="tok-type">u32</span>, <span class="tok-number">999</span>)) <span class="tok-kw">catch</span> <span class="tok-kw">unreachable</span>) == -<span class="tok-number">999</span>);</span>
<span class="line" id="L1036">    <span class="tok-kw">try</span> testing.expect(<span class="tok-builtin">@TypeOf</span>(negateCast(<span class="tok-builtin">@as</span>(<span class="tok-type">u32</span>, <span class="tok-number">999</span>)) <span class="tok-kw">catch</span> <span class="tok-kw">unreachable</span>) == <span class="tok-type">i32</span>);</span>
<span class="line" id="L1037"></span>
<span class="line" id="L1038">    <span class="tok-kw">try</span> testing.expect((negateCast(<span class="tok-builtin">@as</span>(<span class="tok-type">u32</span>, -minInt(<span class="tok-type">i32</span>))) <span class="tok-kw">catch</span> <span class="tok-kw">unreachable</span>) == minInt(<span class="tok-type">i32</span>));</span>
<span class="line" id="L1039">    <span class="tok-kw">try</span> testing.expect(<span class="tok-builtin">@TypeOf</span>(negateCast(<span class="tok-builtin">@as</span>(<span class="tok-type">u32</span>, -minInt(<span class="tok-type">i32</span>))) <span class="tok-kw">catch</span> <span class="tok-kw">unreachable</span>) == <span class="tok-type">i32</span>);</span>
<span class="line" id="L1040"></span>
<span class="line" id="L1041">    <span class="tok-kw">try</span> testing.expectError(<span class="tok-kw">error</span>.Overflow, negateCast(<span class="tok-builtin">@as</span>(<span class="tok-type">u32</span>, maxInt(<span class="tok-type">i32</span>) + <span class="tok-number">10</span>)));</span>
<span class="line" id="L1042">}</span>
<span class="line" id="L1043"></span>
<span class="line" id="L1044"><span class="tok-comment">/// Cast an integer to a different integer type. If the value doesn't fit,</span></span>
<span class="line" id="L1045"><span class="tok-comment">/// return null.</span></span>
<span class="line" id="L1046"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">cast</span>(<span class="tok-kw">comptime</span> T: <span class="tok-type">type</span>, x: <span class="tok-kw">anytype</span>) ?T {</span>
<span class="line" id="L1047">    <span class="tok-kw">comptime</span> assert(<span class="tok-builtin">@typeInfo</span>(T) == .Int); <span class="tok-comment">// must pass an integer</span>
</span>
<span class="line" id="L1048">    <span class="tok-kw">comptime</span> assert(<span class="tok-builtin">@typeInfo</span>(<span class="tok-builtin">@TypeOf</span>(x)) == .Int); <span class="tok-comment">// must pass an integer</span>
</span>
<span class="line" id="L1049">    <span class="tok-kw">if</span> (maxInt(<span class="tok-builtin">@TypeOf</span>(x)) &gt; maxInt(T) <span class="tok-kw">and</span> x &gt; maxInt(T)) {</span>
<span class="line" id="L1050">        <span class="tok-kw">return</span> <span class="tok-null">null</span>;</span>
<span class="line" id="L1051">    } <span class="tok-kw">else</span> <span class="tok-kw">if</span> (minInt(<span class="tok-builtin">@TypeOf</span>(x)) &lt; minInt(T) <span class="tok-kw">and</span> x &lt; minInt(T)) {</span>
<span class="line" id="L1052">        <span class="tok-kw">return</span> <span class="tok-null">null</span>;</span>
<span class="line" id="L1053">    } <span class="tok-kw">else</span> {</span>
<span class="line" id="L1054">        <span class="tok-kw">return</span> <span class="tok-builtin">@intCast</span>(T, x);</span>
<span class="line" id="L1055">    }</span>
<span class="line" id="L1056">}</span>
<span class="line" id="L1057"></span>
<span class="line" id="L1058"><span class="tok-kw">test</span> <span class="tok-str">&quot;cast&quot;</span> {</span>
<span class="line" id="L1059">    <span class="tok-kw">try</span> testing.expect(cast(<span class="tok-type">u8</span>, <span class="tok-builtin">@as</span>(<span class="tok-type">u32</span>, <span class="tok-number">300</span>)) == <span class="tok-null">null</span>);</span>
<span class="line" id="L1060">    <span class="tok-kw">try</span> testing.expect(cast(<span class="tok-type">i8</span>, <span class="tok-builtin">@as</span>(<span class="tok-type">i32</span>, -<span class="tok-number">200</span>)) == <span class="tok-null">null</span>);</span>
<span class="line" id="L1061">    <span class="tok-kw">try</span> testing.expect(cast(<span class="tok-type">u8</span>, <span class="tok-builtin">@as</span>(<span class="tok-type">i8</span>, -<span class="tok-number">1</span>)) == <span class="tok-null">null</span>);</span>
<span class="line" id="L1062">    <span class="tok-kw">try</span> testing.expect(cast(<span class="tok-type">u64</span>, <span class="tok-builtin">@as</span>(<span class="tok-type">i8</span>, -<span class="tok-number">1</span>)) == <span class="tok-null">null</span>);</span>
<span class="line" id="L1063"></span>
<span class="line" id="L1064">    <span class="tok-kw">try</span> testing.expect(cast(<span class="tok-type">u8</span>, <span class="tok-builtin">@as</span>(<span class="tok-type">u32</span>, <span class="tok-number">255</span>)).? == <span class="tok-builtin">@as</span>(<span class="tok-type">u8</span>, <span class="tok-number">255</span>));</span>
<span class="line" id="L1065">    <span class="tok-kw">try</span> testing.expect(<span class="tok-builtin">@TypeOf</span>(cast(<span class="tok-type">u8</span>, <span class="tok-builtin">@as</span>(<span class="tok-type">u32</span>, <span class="tok-number">255</span>)).?) == <span class="tok-type">u8</span>);</span>
<span class="line" id="L1066">}</span>
<span class="line" id="L1067"></span>
<span class="line" id="L1068"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> AlignCastError = <span class="tok-kw">error</span>{UnalignedMemory};</span>
<span class="line" id="L1069"></span>
<span class="line" id="L1070"><span class="tok-comment">/// Align cast a pointer but return an error if it's the wrong alignment</span></span>
<span class="line" id="L1071"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">alignCast</span>(<span class="tok-kw">comptime</span> alignment: <span class="tok-type">u29</span>, ptr: <span class="tok-kw">anytype</span>) AlignCastError!<span class="tok-builtin">@TypeOf</span>(<span class="tok-builtin">@alignCast</span>(alignment, ptr)) {</span>
<span class="line" id="L1072">    <span class="tok-kw">const</span> addr = <span class="tok-builtin">@ptrToInt</span>(ptr);</span>
<span class="line" id="L1073">    <span class="tok-kw">if</span> (addr % alignment != <span class="tok-number">0</span>) {</span>
<span class="line" id="L1074">        <span class="tok-kw">return</span> <span class="tok-kw">error</span>.UnalignedMemory;</span>
<span class="line" id="L1075">    }</span>
<span class="line" id="L1076">    <span class="tok-kw">return</span> <span class="tok-builtin">@alignCast</span>(alignment, ptr);</span>
<span class="line" id="L1077">}</span>
<span class="line" id="L1078"></span>
<span class="line" id="L1079"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">isPowerOfTwo</span>(v: <span class="tok-kw">anytype</span>) <span class="tok-type">bool</span> {</span>
<span class="line" id="L1080">    assert(v != <span class="tok-number">0</span>);</span>
<span class="line" id="L1081">    <span class="tok-kw">return</span> (v &amp; (v - <span class="tok-number">1</span>)) == <span class="tok-number">0</span>;</span>
<span class="line" id="L1082">}</span>
<span class="line" id="L1083"></span>
<span class="line" id="L1084"><span class="tok-comment">/// Rounds the given floating point number to an integer, away from zero.</span></span>
<span class="line" id="L1085"><span class="tok-comment">/// Uses a dedicated hardware instruction when available.</span></span>
<span class="line" id="L1086"><span class="tok-comment">/// This is the same as calling the builtin @round</span></span>
<span class="line" id="L1087"><span class="tok-kw">pub</span> <span class="tok-kw">inline</span> <span class="tok-kw">fn</span> <span class="tok-fn">round</span>(value: <span class="tok-kw">anytype</span>) <span class="tok-builtin">@TypeOf</span>(value) {</span>
<span class="line" id="L1088">    <span class="tok-kw">return</span> <span class="tok-builtin">@round</span>(value);</span>
<span class="line" id="L1089">}</span>
<span class="line" id="L1090"></span>
<span class="line" id="L1091"><span class="tok-comment">/// Rounds the given floating point number to an integer, towards zero.</span></span>
<span class="line" id="L1092"><span class="tok-comment">/// Uses a dedicated hardware instruction when available.</span></span>
<span class="line" id="L1093"><span class="tok-comment">/// This is the same as calling the builtin @trunc</span></span>
<span class="line" id="L1094"><span class="tok-kw">pub</span> <span class="tok-kw">inline</span> <span class="tok-kw">fn</span> <span class="tok-fn">trunc</span>(value: <span class="tok-kw">anytype</span>) <span class="tok-builtin">@TypeOf</span>(value) {</span>
<span class="line" id="L1095">    <span class="tok-kw">return</span> <span class="tok-builtin">@trunc</span>(value);</span>
<span class="line" id="L1096">}</span>
<span class="line" id="L1097"></span>
<span class="line" id="L1098"><span class="tok-comment">/// Returns the largest integral value not greater than the given floating point number.</span></span>
<span class="line" id="L1099"><span class="tok-comment">/// Uses a dedicated hardware instruction when available.</span></span>
<span class="line" id="L1100"><span class="tok-comment">/// This is the same as calling the builtin @floor</span></span>
<span class="line" id="L1101"><span class="tok-kw">pub</span> <span class="tok-kw">inline</span> <span class="tok-kw">fn</span> <span class="tok-fn">floor</span>(value: <span class="tok-kw">anytype</span>) <span class="tok-builtin">@TypeOf</span>(value) {</span>
<span class="line" id="L1102">    <span class="tok-kw">return</span> <span class="tok-builtin">@floor</span>(value);</span>
<span class="line" id="L1103">}</span>
<span class="line" id="L1104"></span>
<span class="line" id="L1105"><span class="tok-comment">/// Returns the nearest power of two less than or equal to value, or</span></span>
<span class="line" id="L1106"><span class="tok-comment">/// zero if value is less than or equal to zero.</span></span>
<span class="line" id="L1107"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">floorPowerOfTwo</span>(<span class="tok-kw">comptime</span> T: <span class="tok-type">type</span>, value: T) T {</span>
<span class="line" id="L1108">    <span class="tok-kw">const</span> uT = std.meta.Int(.unsigned, <span class="tok-builtin">@typeInfo</span>(T).Int.bits);</span>
<span class="line" id="L1109">    <span class="tok-kw">if</span> (value &lt;= <span class="tok-number">0</span>) <span class="tok-kw">return</span> <span class="tok-number">0</span>;</span>
<span class="line" id="L1110">    <span class="tok-kw">return</span> <span class="tok-builtin">@as</span>(T, <span class="tok-number">1</span>) &lt;&lt; log2_int(uT, <span class="tok-builtin">@intCast</span>(uT, value));</span>
<span class="line" id="L1111">}</span>
<span class="line" id="L1112"></span>
<span class="line" id="L1113"><span class="tok-kw">test</span> <span class="tok-str">&quot;floorPowerOfTwo&quot;</span> {</span>
<span class="line" id="L1114">    <span class="tok-kw">try</span> testFloorPowerOfTwo();</span>
<span class="line" id="L1115">    <span class="tok-kw">comptime</span> <span class="tok-kw">try</span> testFloorPowerOfTwo();</span>
<span class="line" id="L1116">}</span>
<span class="line" id="L1117"></span>
<span class="line" id="L1118"><span class="tok-kw">fn</span> <span class="tok-fn">testFloorPowerOfTwo</span>() !<span class="tok-type">void</span> {</span>
<span class="line" id="L1119">    <span class="tok-kw">try</span> testing.expect(floorPowerOfTwo(<span class="tok-type">u32</span>, <span class="tok-number">63</span>) == <span class="tok-number">32</span>);</span>
<span class="line" id="L1120">    <span class="tok-kw">try</span> testing.expect(floorPowerOfTwo(<span class="tok-type">u32</span>, <span class="tok-number">64</span>) == <span class="tok-number">64</span>);</span>
<span class="line" id="L1121">    <span class="tok-kw">try</span> testing.expect(floorPowerOfTwo(<span class="tok-type">u32</span>, <span class="tok-number">65</span>) == <span class="tok-number">64</span>);</span>
<span class="line" id="L1122">    <span class="tok-kw">try</span> testing.expect(floorPowerOfTwo(<span class="tok-type">u32</span>, <span class="tok-number">0</span>) == <span class="tok-number">0</span>);</span>
<span class="line" id="L1123">    <span class="tok-kw">try</span> testing.expect(floorPowerOfTwo(<span class="tok-type">u4</span>, <span class="tok-number">7</span>) == <span class="tok-number">4</span>);</span>
<span class="line" id="L1124">    <span class="tok-kw">try</span> testing.expect(floorPowerOfTwo(<span class="tok-type">u4</span>, <span class="tok-number">8</span>) == <span class="tok-number">8</span>);</span>
<span class="line" id="L1125">    <span class="tok-kw">try</span> testing.expect(floorPowerOfTwo(<span class="tok-type">u4</span>, <span class="tok-number">9</span>) == <span class="tok-number">8</span>);</span>
<span class="line" id="L1126">    <span class="tok-kw">try</span> testing.expect(floorPowerOfTwo(<span class="tok-type">u4</span>, <span class="tok-number">0</span>) == <span class="tok-number">0</span>);</span>
<span class="line" id="L1127">    <span class="tok-kw">try</span> testing.expect(floorPowerOfTwo(<span class="tok-type">i4</span>, <span class="tok-number">7</span>) == <span class="tok-number">4</span>);</span>
<span class="line" id="L1128">    <span class="tok-kw">try</span> testing.expect(floorPowerOfTwo(<span class="tok-type">i4</span>, -<span class="tok-number">8</span>) == <span class="tok-number">0</span>);</span>
<span class="line" id="L1129">    <span class="tok-kw">try</span> testing.expect(floorPowerOfTwo(<span class="tok-type">i4</span>, -<span class="tok-number">1</span>) == <span class="tok-number">0</span>);</span>
<span class="line" id="L1130">    <span class="tok-kw">try</span> testing.expect(floorPowerOfTwo(<span class="tok-type">i4</span>, <span class="tok-number">0</span>) == <span class="tok-number">0</span>);</span>
<span class="line" id="L1131">}</span>
<span class="line" id="L1132"></span>
<span class="line" id="L1133"><span class="tok-comment">/// Returns the smallest integral value not less than the given floating point number.</span></span>
<span class="line" id="L1134"><span class="tok-comment">/// Uses a dedicated hardware instruction when available.</span></span>
<span class="line" id="L1135"><span class="tok-comment">/// This is the same as calling the builtin @ceil</span></span>
<span class="line" id="L1136"><span class="tok-kw">pub</span> <span class="tok-kw">inline</span> <span class="tok-kw">fn</span> <span class="tok-fn">ceil</span>(value: <span class="tok-kw">anytype</span>) <span class="tok-builtin">@TypeOf</span>(value) {</span>
<span class="line" id="L1137">    <span class="tok-kw">return</span> <span class="tok-builtin">@ceil</span>(value);</span>
<span class="line" id="L1138">}</span>
<span class="line" id="L1139"></span>
<span class="line" id="L1140"><span class="tok-comment">/// Returns the next power of two (if the value is not already a power of two).</span></span>
<span class="line" id="L1141"><span class="tok-comment">/// Only unsigned integers can be used. Zero is not an allowed input.</span></span>
<span class="line" id="L1142"><span class="tok-comment">/// Result is a type with 1 more bit than the input type.</span></span>
<span class="line" id="L1143"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">ceilPowerOfTwoPromote</span>(<span class="tok-kw">comptime</span> T: <span class="tok-type">type</span>, value: T) std.meta.Int(<span class="tok-builtin">@typeInfo</span>(T).Int.signedness, <span class="tok-builtin">@typeInfo</span>(T).Int.bits + <span class="tok-number">1</span>) {</span>
<span class="line" id="L1144">    <span class="tok-kw">comptime</span> assert(<span class="tok-builtin">@typeInfo</span>(T) == .Int);</span>
<span class="line" id="L1145">    <span class="tok-kw">comptime</span> assert(<span class="tok-builtin">@typeInfo</span>(T).Int.signedness == .unsigned);</span>
<span class="line" id="L1146">    assert(value != <span class="tok-number">0</span>);</span>
<span class="line" id="L1147">    <span class="tok-kw">const</span> PromotedType = std.meta.Int(<span class="tok-builtin">@typeInfo</span>(T).Int.signedness, <span class="tok-builtin">@typeInfo</span>(T).Int.bits + <span class="tok-number">1</span>);</span>
<span class="line" id="L1148">    <span class="tok-kw">const</span> ShiftType = std.math.Log2Int(PromotedType);</span>
<span class="line" id="L1149">    <span class="tok-kw">return</span> <span class="tok-builtin">@as</span>(PromotedType, <span class="tok-number">1</span>) &lt;&lt; <span class="tok-builtin">@intCast</span>(ShiftType, <span class="tok-builtin">@typeInfo</span>(T).Int.bits - <span class="tok-builtin">@clz</span>(T, value - <span class="tok-number">1</span>));</span>
<span class="line" id="L1150">}</span>
<span class="line" id="L1151"></span>
<span class="line" id="L1152"><span class="tok-comment">/// Returns the next power of two (if the value is not already a power of two).</span></span>
<span class="line" id="L1153"><span class="tok-comment">/// Only unsigned integers can be used. Zero is not an allowed input.</span></span>
<span class="line" id="L1154"><span class="tok-comment">/// If the value doesn't fit, returns an error.</span></span>
<span class="line" id="L1155"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">ceilPowerOfTwo</span>(<span class="tok-kw">comptime</span> T: <span class="tok-type">type</span>, value: T) (<span class="tok-kw">error</span>{Overflow}!T) {</span>
<span class="line" id="L1156">    <span class="tok-kw">comptime</span> assert(<span class="tok-builtin">@typeInfo</span>(T) == .Int);</span>
<span class="line" id="L1157">    <span class="tok-kw">const</span> info = <span class="tok-builtin">@typeInfo</span>(T).Int;</span>
<span class="line" id="L1158">    <span class="tok-kw">comptime</span> assert(info.signedness == .unsigned);</span>
<span class="line" id="L1159">    <span class="tok-kw">const</span> PromotedType = std.meta.Int(info.signedness, info.bits + <span class="tok-number">1</span>);</span>
<span class="line" id="L1160">    <span class="tok-kw">const</span> overflowBit = <span class="tok-builtin">@as</span>(PromotedType, <span class="tok-number">1</span>) &lt;&lt; info.bits;</span>
<span class="line" id="L1161">    <span class="tok-kw">var</span> x = ceilPowerOfTwoPromote(T, value);</span>
<span class="line" id="L1162">    <span class="tok-kw">if</span> (overflowBit &amp; x != <span class="tok-number">0</span>) {</span>
<span class="line" id="L1163">        <span class="tok-kw">return</span> <span class="tok-kw">error</span>.Overflow;</span>
<span class="line" id="L1164">    }</span>
<span class="line" id="L1165">    <span class="tok-kw">return</span> <span class="tok-builtin">@intCast</span>(T, x);</span>
<span class="line" id="L1166">}</span>
<span class="line" id="L1167"></span>
<span class="line" id="L1168"><span class="tok-comment">/// Returns the next power of two (if the value is not already a power</span></span>
<span class="line" id="L1169"><span class="tok-comment">/// of two). Only unsigned integers can be used. Zero is not an</span></span>
<span class="line" id="L1170"><span class="tok-comment">/// allowed input. Asserts that the value fits.</span></span>
<span class="line" id="L1171"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">ceilPowerOfTwoAssert</span>(<span class="tok-kw">comptime</span> T: <span class="tok-type">type</span>, value: T) T {</span>
<span class="line" id="L1172">    <span class="tok-kw">return</span> ceilPowerOfTwo(T, value) <span class="tok-kw">catch</span> <span class="tok-kw">unreachable</span>;</span>
<span class="line" id="L1173">}</span>
<span class="line" id="L1174"></span>
<span class="line" id="L1175"><span class="tok-kw">test</span> <span class="tok-str">&quot;ceilPowerOfTwoPromote&quot;</span> {</span>
<span class="line" id="L1176">    <span class="tok-kw">try</span> testCeilPowerOfTwoPromote();</span>
<span class="line" id="L1177">    <span class="tok-kw">comptime</span> <span class="tok-kw">try</span> testCeilPowerOfTwoPromote();</span>
<span class="line" id="L1178">}</span>
<span class="line" id="L1179"></span>
<span class="line" id="L1180"><span class="tok-kw">fn</span> <span class="tok-fn">testCeilPowerOfTwoPromote</span>() !<span class="tok-type">void</span> {</span>
<span class="line" id="L1181">    <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">u33</span>, <span class="tok-number">1</span>), ceilPowerOfTwoPromote(<span class="tok-type">u32</span>, <span class="tok-number">1</span>));</span>
<span class="line" id="L1182">    <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">u33</span>, <span class="tok-number">2</span>), ceilPowerOfTwoPromote(<span class="tok-type">u32</span>, <span class="tok-number">2</span>));</span>
<span class="line" id="L1183">    <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">u33</span>, <span class="tok-number">64</span>), ceilPowerOfTwoPromote(<span class="tok-type">u32</span>, <span class="tok-number">63</span>));</span>
<span class="line" id="L1184">    <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">u33</span>, <span class="tok-number">64</span>), ceilPowerOfTwoPromote(<span class="tok-type">u32</span>, <span class="tok-number">64</span>));</span>
<span class="line" id="L1185">    <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">u33</span>, <span class="tok-number">128</span>), ceilPowerOfTwoPromote(<span class="tok-type">u32</span>, <span class="tok-number">65</span>));</span>
<span class="line" id="L1186">    <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">u6</span>, <span class="tok-number">8</span>), ceilPowerOfTwoPromote(<span class="tok-type">u5</span>, <span class="tok-number">7</span>));</span>
<span class="line" id="L1187">    <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">u6</span>, <span class="tok-number">8</span>), ceilPowerOfTwoPromote(<span class="tok-type">u5</span>, <span class="tok-number">8</span>));</span>
<span class="line" id="L1188">    <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">u6</span>, <span class="tok-number">16</span>), ceilPowerOfTwoPromote(<span class="tok-type">u5</span>, <span class="tok-number">9</span>));</span>
<span class="line" id="L1189">    <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">u5</span>, <span class="tok-number">16</span>), ceilPowerOfTwoPromote(<span class="tok-type">u4</span>, <span class="tok-number">9</span>));</span>
<span class="line" id="L1190">}</span>
<span class="line" id="L1191"></span>
<span class="line" id="L1192"><span class="tok-kw">test</span> <span class="tok-str">&quot;ceilPowerOfTwo&quot;</span> {</span>
<span class="line" id="L1193">    <span class="tok-kw">try</span> testCeilPowerOfTwo();</span>
<span class="line" id="L1194">    <span class="tok-kw">comptime</span> <span class="tok-kw">try</span> testCeilPowerOfTwo();</span>
<span class="line" id="L1195">}</span>
<span class="line" id="L1196"></span>
<span class="line" id="L1197"><span class="tok-kw">fn</span> <span class="tok-fn">testCeilPowerOfTwo</span>() !<span class="tok-type">void</span> {</span>
<span class="line" id="L1198">    <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">u32</span>, <span class="tok-number">1</span>), <span class="tok-kw">try</span> ceilPowerOfTwo(<span class="tok-type">u32</span>, <span class="tok-number">1</span>));</span>
<span class="line" id="L1199">    <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">u32</span>, <span class="tok-number">2</span>), <span class="tok-kw">try</span> ceilPowerOfTwo(<span class="tok-type">u32</span>, <span class="tok-number">2</span>));</span>
<span class="line" id="L1200">    <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">u32</span>, <span class="tok-number">64</span>), <span class="tok-kw">try</span> ceilPowerOfTwo(<span class="tok-type">u32</span>, <span class="tok-number">63</span>));</span>
<span class="line" id="L1201">    <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">u32</span>, <span class="tok-number">64</span>), <span class="tok-kw">try</span> ceilPowerOfTwo(<span class="tok-type">u32</span>, <span class="tok-number">64</span>));</span>
<span class="line" id="L1202">    <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">u32</span>, <span class="tok-number">128</span>), <span class="tok-kw">try</span> ceilPowerOfTwo(<span class="tok-type">u32</span>, <span class="tok-number">65</span>));</span>
<span class="line" id="L1203">    <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">u5</span>, <span class="tok-number">8</span>), <span class="tok-kw">try</span> ceilPowerOfTwo(<span class="tok-type">u5</span>, <span class="tok-number">7</span>));</span>
<span class="line" id="L1204">    <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">u5</span>, <span class="tok-number">8</span>), <span class="tok-kw">try</span> ceilPowerOfTwo(<span class="tok-type">u5</span>, <span class="tok-number">8</span>));</span>
<span class="line" id="L1205">    <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">u5</span>, <span class="tok-number">16</span>), <span class="tok-kw">try</span> ceilPowerOfTwo(<span class="tok-type">u5</span>, <span class="tok-number">9</span>));</span>
<span class="line" id="L1206">    <span class="tok-kw">try</span> testing.expectError(<span class="tok-kw">error</span>.Overflow, ceilPowerOfTwo(<span class="tok-type">u4</span>, <span class="tok-number">9</span>));</span>
<span class="line" id="L1207">}</span>
<span class="line" id="L1208"></span>
<span class="line" id="L1209"><span class="tok-comment">/// Return the log base 2 of integer value x, rounding down to the</span></span>
<span class="line" id="L1210"><span class="tok-comment">/// nearest integer.</span></span>
<span class="line" id="L1211"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">log2_int</span>(<span class="tok-kw">comptime</span> T: <span class="tok-type">type</span>, x: T) Log2Int(T) {</span>
<span class="line" id="L1212">    <span class="tok-kw">if</span> (<span class="tok-builtin">@typeInfo</span>(T) != .Int <span class="tok-kw">or</span> <span class="tok-builtin">@typeInfo</span>(T).Int.signedness != .unsigned)</span>
<span class="line" id="L1213">        <span class="tok-builtin">@compileError</span>(<span class="tok-str">&quot;log2_int requires an unsigned integer, found &quot;</span> ++ <span class="tok-builtin">@typeName</span>(T));</span>
<span class="line" id="L1214">    assert(x != <span class="tok-number">0</span>);</span>
<span class="line" id="L1215">    <span class="tok-kw">return</span> <span class="tok-builtin">@intCast</span>(Log2Int(T), <span class="tok-builtin">@typeInfo</span>(T).Int.bits - <span class="tok-number">1</span> - <span class="tok-builtin">@clz</span>(T, x));</span>
<span class="line" id="L1216">}</span>
<span class="line" id="L1217"></span>
<span class="line" id="L1218"><span class="tok-comment">/// Return the log base 2 of integer value x, rounding up to the</span></span>
<span class="line" id="L1219"><span class="tok-comment">/// nearest integer.</span></span>
<span class="line" id="L1220"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">log2_int_ceil</span>(<span class="tok-kw">comptime</span> T: <span class="tok-type">type</span>, x: T) Log2IntCeil(T) {</span>
<span class="line" id="L1221">    <span class="tok-kw">if</span> (<span class="tok-builtin">@typeInfo</span>(T) != .Int <span class="tok-kw">or</span> <span class="tok-builtin">@typeInfo</span>(T).Int.signedness != .unsigned)</span>
<span class="line" id="L1222">        <span class="tok-builtin">@compileError</span>(<span class="tok-str">&quot;log2_int_ceil requires an unsigned integer, found &quot;</span> ++ <span class="tok-builtin">@typeName</span>(T));</span>
<span class="line" id="L1223">    assert(x != <span class="tok-number">0</span>);</span>
<span class="line" id="L1224">    <span class="tok-kw">if</span> (x == <span class="tok-number">1</span>) <span class="tok-kw">return</span> <span class="tok-number">0</span>;</span>
<span class="line" id="L1225">    <span class="tok-kw">const</span> log2_val: Log2IntCeil(T) = log2_int(T, x - <span class="tok-number">1</span>);</span>
<span class="line" id="L1226">    <span class="tok-kw">return</span> log2_val + <span class="tok-number">1</span>;</span>
<span class="line" id="L1227">}</span>
<span class="line" id="L1228"></span>
<span class="line" id="L1229"><span class="tok-kw">test</span> <span class="tok-str">&quot;std.math.log2_int_ceil&quot;</span> {</span>
<span class="line" id="L1230">    <span class="tok-kw">try</span> testing.expect(log2_int_ceil(<span class="tok-type">u32</span>, <span class="tok-number">1</span>) == <span class="tok-number">0</span>);</span>
<span class="line" id="L1231">    <span class="tok-kw">try</span> testing.expect(log2_int_ceil(<span class="tok-type">u32</span>, <span class="tok-number">2</span>) == <span class="tok-number">1</span>);</span>
<span class="line" id="L1232">    <span class="tok-kw">try</span> testing.expect(log2_int_ceil(<span class="tok-type">u32</span>, <span class="tok-number">3</span>) == <span class="tok-number">2</span>);</span>
<span class="line" id="L1233">    <span class="tok-kw">try</span> testing.expect(log2_int_ceil(<span class="tok-type">u32</span>, <span class="tok-number">4</span>) == <span class="tok-number">2</span>);</span>
<span class="line" id="L1234">    <span class="tok-kw">try</span> testing.expect(log2_int_ceil(<span class="tok-type">u32</span>, <span class="tok-number">5</span>) == <span class="tok-number">3</span>);</span>
<span class="line" id="L1235">    <span class="tok-kw">try</span> testing.expect(log2_int_ceil(<span class="tok-type">u32</span>, <span class="tok-number">6</span>) == <span class="tok-number">3</span>);</span>
<span class="line" id="L1236">    <span class="tok-kw">try</span> testing.expect(log2_int_ceil(<span class="tok-type">u32</span>, <span class="tok-number">7</span>) == <span class="tok-number">3</span>);</span>
<span class="line" id="L1237">    <span class="tok-kw">try</span> testing.expect(log2_int_ceil(<span class="tok-type">u32</span>, <span class="tok-number">8</span>) == <span class="tok-number">3</span>);</span>
<span class="line" id="L1238">    <span class="tok-kw">try</span> testing.expect(log2_int_ceil(<span class="tok-type">u32</span>, <span class="tok-number">9</span>) == <span class="tok-number">4</span>);</span>
<span class="line" id="L1239">    <span class="tok-kw">try</span> testing.expect(log2_int_ceil(<span class="tok-type">u32</span>, <span class="tok-number">10</span>) == <span class="tok-number">4</span>);</span>
<span class="line" id="L1240">}</span>
<span class="line" id="L1241"></span>
<span class="line" id="L1242"><span class="tok-comment">/// Cast a value to a different type. If the value doesn't fit in, or</span></span>
<span class="line" id="L1243"><span class="tok-comment">/// can't be perfectly represented by, the new type, it will be</span></span>
<span class="line" id="L1244"><span class="tok-comment">/// converted to the closest possible representation.</span></span>
<span class="line" id="L1245"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">lossyCast</span>(<span class="tok-kw">comptime</span> T: <span class="tok-type">type</span>, value: <span class="tok-kw">anytype</span>) T {</span>
<span class="line" id="L1246">    <span class="tok-kw">switch</span> (<span class="tok-builtin">@typeInfo</span>(T)) {</span>
<span class="line" id="L1247">        .Float =&gt; {</span>
<span class="line" id="L1248">            <span class="tok-kw">switch</span> (<span class="tok-builtin">@typeInfo</span>(<span class="tok-builtin">@TypeOf</span>(value))) {</span>
<span class="line" id="L1249">                .Int =&gt; <span class="tok-kw">return</span> <span class="tok-builtin">@intToFloat</span>(T, value),</span>
<span class="line" id="L1250">                .Float =&gt; <span class="tok-kw">return</span> <span class="tok-builtin">@floatCast</span>(T, value),</span>
<span class="line" id="L1251">                .ComptimeInt =&gt; <span class="tok-kw">return</span> <span class="tok-builtin">@as</span>(T, value),</span>
<span class="line" id="L1252">                .ComptimeFloat =&gt; <span class="tok-kw">return</span> <span class="tok-builtin">@as</span>(T, value),</span>
<span class="line" id="L1253">                <span class="tok-kw">else</span> =&gt; <span class="tok-builtin">@compileError</span>(<span class="tok-str">&quot;bad type&quot;</span>),</span>
<span class="line" id="L1254">            }</span>
<span class="line" id="L1255">        },</span>
<span class="line" id="L1256">        .Int =&gt; {</span>
<span class="line" id="L1257">            <span class="tok-kw">switch</span> (<span class="tok-builtin">@typeInfo</span>(<span class="tok-builtin">@TypeOf</span>(value))) {</span>
<span class="line" id="L1258">                .Int, .ComptimeInt =&gt; {</span>
<span class="line" id="L1259">                    <span class="tok-kw">if</span> (value &gt;= maxInt(T)) {</span>
<span class="line" id="L1260">                        <span class="tok-kw">return</span> <span class="tok-builtin">@as</span>(T, maxInt(T));</span>
<span class="line" id="L1261">                    } <span class="tok-kw">else</span> <span class="tok-kw">if</span> (value &lt;= minInt(T)) {</span>
<span class="line" id="L1262">                        <span class="tok-kw">return</span> <span class="tok-builtin">@as</span>(T, minInt(T));</span>
<span class="line" id="L1263">                    } <span class="tok-kw">else</span> {</span>
<span class="line" id="L1264">                        <span class="tok-kw">return</span> <span class="tok-builtin">@intCast</span>(T, value);</span>
<span class="line" id="L1265">                    }</span>
<span class="line" id="L1266">                },</span>
<span class="line" id="L1267">                .Float, .ComptimeFloat =&gt; {</span>
<span class="line" id="L1268">                    <span class="tok-kw">if</span> (value &gt;= maxInt(T)) {</span>
<span class="line" id="L1269">                        <span class="tok-kw">return</span> <span class="tok-builtin">@as</span>(T, maxInt(T));</span>
<span class="line" id="L1270">                    } <span class="tok-kw">else</span> <span class="tok-kw">if</span> (value &lt;= minInt(T)) {</span>
<span class="line" id="L1271">                        <span class="tok-kw">return</span> <span class="tok-builtin">@as</span>(T, minInt(T));</span>
<span class="line" id="L1272">                    } <span class="tok-kw">else</span> {</span>
<span class="line" id="L1273">                        <span class="tok-kw">return</span> <span class="tok-builtin">@floatToInt</span>(T, value);</span>
<span class="line" id="L1274">                    }</span>
<span class="line" id="L1275">                },</span>
<span class="line" id="L1276">                <span class="tok-kw">else</span> =&gt; <span class="tok-builtin">@compileError</span>(<span class="tok-str">&quot;bad type&quot;</span>),</span>
<span class="line" id="L1277">            }</span>
<span class="line" id="L1278">        },</span>
<span class="line" id="L1279">        <span class="tok-kw">else</span> =&gt; <span class="tok-builtin">@compileError</span>(<span class="tok-str">&quot;bad result type&quot;</span>),</span>
<span class="line" id="L1280">    }</span>
<span class="line" id="L1281">}</span>
<span class="line" id="L1282"></span>
<span class="line" id="L1283"><span class="tok-kw">test</span> <span class="tok-str">&quot;lossyCast&quot;</span> {</span>
<span class="line" id="L1284">    <span class="tok-kw">try</span> testing.expect(lossyCast(<span class="tok-type">i16</span>, <span class="tok-number">70000.0</span>) == <span class="tok-builtin">@as</span>(<span class="tok-type">i16</span>, <span class="tok-number">32767</span>));</span>
<span class="line" id="L1285">    <span class="tok-kw">try</span> testing.expect(lossyCast(<span class="tok-type">u32</span>, <span class="tok-builtin">@as</span>(<span class="tok-type">i16</span>, -<span class="tok-number">255</span>)) == <span class="tok-builtin">@as</span>(<span class="tok-type">u32</span>, <span class="tok-number">0</span>));</span>
<span class="line" id="L1286">    <span class="tok-kw">try</span> testing.expect(lossyCast(<span class="tok-type">i9</span>, <span class="tok-builtin">@as</span>(<span class="tok-type">u32</span>, <span class="tok-number">200</span>)) == <span class="tok-builtin">@as</span>(<span class="tok-type">i9</span>, <span class="tok-number">200</span>));</span>
<span class="line" id="L1287">    <span class="tok-kw">try</span> testing.expect(lossyCast(<span class="tok-type">u32</span>, <span class="tok-builtin">@as</span>(<span class="tok-type">f32</span>, maxInt(<span class="tok-type">u32</span>))) == maxInt(<span class="tok-type">u32</span>));</span>
<span class="line" id="L1288">}</span>
<span class="line" id="L1289"></span>
<span class="line" id="L1290"><span class="tok-comment">/// Returns the maximum value of integer type T.</span></span>
<span class="line" id="L1291"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">maxInt</span>(<span class="tok-kw">comptime</span> T: <span class="tok-type">type</span>) <span class="tok-type">comptime_int</span> {</span>
<span class="line" id="L1292">    <span class="tok-kw">const</span> info = <span class="tok-builtin">@typeInfo</span>(T);</span>
<span class="line" id="L1293">    <span class="tok-kw">const</span> bit_count = info.Int.bits;</span>
<span class="line" id="L1294">    <span class="tok-kw">if</span> (bit_count == <span class="tok-number">0</span>) <span class="tok-kw">return</span> <span class="tok-number">0</span>;</span>
<span class="line" id="L1295">    <span class="tok-kw">return</span> (<span class="tok-number">1</span> &lt;&lt; (bit_count - <span class="tok-builtin">@boolToInt</span>(info.Int.signedness == .signed))) - <span class="tok-number">1</span>;</span>
<span class="line" id="L1296">}</span>
<span class="line" id="L1297"></span>
<span class="line" id="L1298"><span class="tok-comment">/// Returns the minimum value of integer type T.</span></span>
<span class="line" id="L1299"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">minInt</span>(<span class="tok-kw">comptime</span> T: <span class="tok-type">type</span>) <span class="tok-type">comptime_int</span> {</span>
<span class="line" id="L1300">    <span class="tok-kw">const</span> info = <span class="tok-builtin">@typeInfo</span>(T);</span>
<span class="line" id="L1301">    <span class="tok-kw">const</span> bit_count = info.Int.bits;</span>
<span class="line" id="L1302">    <span class="tok-kw">if</span> (info.Int.signedness == .unsigned) <span class="tok-kw">return</span> <span class="tok-number">0</span>;</span>
<span class="line" id="L1303">    <span class="tok-kw">if</span> (bit_count == <span class="tok-number">0</span>) <span class="tok-kw">return</span> <span class="tok-number">0</span>;</span>
<span class="line" id="L1304">    <span class="tok-kw">return</span> -(<span class="tok-number">1</span> &lt;&lt; (bit_count - <span class="tok-number">1</span>));</span>
<span class="line" id="L1305">}</span>
<span class="line" id="L1306"></span>
<span class="line" id="L1307"><span class="tok-kw">test</span> <span class="tok-str">&quot;minInt and maxInt&quot;</span> {</span>
<span class="line" id="L1308">    <span class="tok-kw">try</span> testing.expect(maxInt(<span class="tok-type">u0</span>) == <span class="tok-number">0</span>);</span>
<span class="line" id="L1309">    <span class="tok-kw">try</span> testing.expect(maxInt(<span class="tok-type">u1</span>) == <span class="tok-number">1</span>);</span>
<span class="line" id="L1310">    <span class="tok-kw">try</span> testing.expect(maxInt(<span class="tok-type">u8</span>) == <span class="tok-number">255</span>);</span>
<span class="line" id="L1311">    <span class="tok-kw">try</span> testing.expect(maxInt(<span class="tok-type">u16</span>) == <span class="tok-number">65535</span>);</span>
<span class="line" id="L1312">    <span class="tok-kw">try</span> testing.expect(maxInt(<span class="tok-type">u32</span>) == <span class="tok-number">4294967295</span>);</span>
<span class="line" id="L1313">    <span class="tok-kw">try</span> testing.expect(maxInt(<span class="tok-type">u64</span>) == <span class="tok-number">18446744073709551615</span>);</span>
<span class="line" id="L1314">    <span class="tok-kw">try</span> testing.expect(maxInt(<span class="tok-type">u128</span>) == <span class="tok-number">340282366920938463463374607431768211455</span>);</span>
<span class="line" id="L1315"></span>
<span class="line" id="L1316">    <span class="tok-kw">try</span> testing.expect(maxInt(<span class="tok-type">i0</span>) == <span class="tok-number">0</span>);</span>
<span class="line" id="L1317">    <span class="tok-kw">try</span> testing.expect(maxInt(<span class="tok-type">i1</span>) == <span class="tok-number">0</span>);</span>
<span class="line" id="L1318">    <span class="tok-kw">try</span> testing.expect(maxInt(<span class="tok-type">i8</span>) == <span class="tok-number">127</span>);</span>
<span class="line" id="L1319">    <span class="tok-kw">try</span> testing.expect(maxInt(<span class="tok-type">i16</span>) == <span class="tok-number">32767</span>);</span>
<span class="line" id="L1320">    <span class="tok-kw">try</span> testing.expect(maxInt(<span class="tok-type">i32</span>) == <span class="tok-number">2147483647</span>);</span>
<span class="line" id="L1321">    <span class="tok-kw">try</span> testing.expect(maxInt(<span class="tok-type">i63</span>) == <span class="tok-number">4611686018427387903</span>);</span>
<span class="line" id="L1322">    <span class="tok-kw">try</span> testing.expect(maxInt(<span class="tok-type">i64</span>) == <span class="tok-number">9223372036854775807</span>);</span>
<span class="line" id="L1323">    <span class="tok-kw">try</span> testing.expect(maxInt(<span class="tok-type">i128</span>) == <span class="tok-number">170141183460469231731687303715884105727</span>);</span>
<span class="line" id="L1324"></span>
<span class="line" id="L1325">    <span class="tok-kw">try</span> testing.expect(minInt(<span class="tok-type">u0</span>) == <span class="tok-number">0</span>);</span>
<span class="line" id="L1326">    <span class="tok-kw">try</span> testing.expect(minInt(<span class="tok-type">u1</span>) == <span class="tok-number">0</span>);</span>
<span class="line" id="L1327">    <span class="tok-kw">try</span> testing.expect(minInt(<span class="tok-type">u8</span>) == <span class="tok-number">0</span>);</span>
<span class="line" id="L1328">    <span class="tok-kw">try</span> testing.expect(minInt(<span class="tok-type">u16</span>) == <span class="tok-number">0</span>);</span>
<span class="line" id="L1329">    <span class="tok-kw">try</span> testing.expect(minInt(<span class="tok-type">u32</span>) == <span class="tok-number">0</span>);</span>
<span class="line" id="L1330">    <span class="tok-kw">try</span> testing.expect(minInt(<span class="tok-type">u63</span>) == <span class="tok-number">0</span>);</span>
<span class="line" id="L1331">    <span class="tok-kw">try</span> testing.expect(minInt(<span class="tok-type">u64</span>) == <span class="tok-number">0</span>);</span>
<span class="line" id="L1332">    <span class="tok-kw">try</span> testing.expect(minInt(<span class="tok-type">u128</span>) == <span class="tok-number">0</span>);</span>
<span class="line" id="L1333"></span>
<span class="line" id="L1334">    <span class="tok-kw">try</span> testing.expect(minInt(<span class="tok-type">i0</span>) == <span class="tok-number">0</span>);</span>
<span class="line" id="L1335">    <span class="tok-kw">try</span> testing.expect(minInt(<span class="tok-type">i1</span>) == -<span class="tok-number">1</span>);</span>
<span class="line" id="L1336">    <span class="tok-kw">try</span> testing.expect(minInt(<span class="tok-type">i8</span>) == -<span class="tok-number">128</span>);</span>
<span class="line" id="L1337">    <span class="tok-kw">try</span> testing.expect(minInt(<span class="tok-type">i16</span>) == -<span class="tok-number">32768</span>);</span>
<span class="line" id="L1338">    <span class="tok-kw">try</span> testing.expect(minInt(<span class="tok-type">i32</span>) == -<span class="tok-number">2147483648</span>);</span>
<span class="line" id="L1339">    <span class="tok-kw">try</span> testing.expect(minInt(<span class="tok-type">i63</span>) == -<span class="tok-number">4611686018427387904</span>);</span>
<span class="line" id="L1340">    <span class="tok-kw">try</span> testing.expect(minInt(<span class="tok-type">i64</span>) == -<span class="tok-number">9223372036854775808</span>);</span>
<span class="line" id="L1341">    <span class="tok-kw">try</span> testing.expect(minInt(<span class="tok-type">i128</span>) == -<span class="tok-number">170141183460469231731687303715884105728</span>);</span>
<span class="line" id="L1342">}</span>
<span class="line" id="L1343"></span>
<span class="line" id="L1344"><span class="tok-kw">test</span> <span class="tok-str">&quot;max value type&quot;</span> {</span>
<span class="line" id="L1345">    <span class="tok-kw">const</span> x: <span class="tok-type">u32</span> = maxInt(<span class="tok-type">i32</span>);</span>
<span class="line" id="L1346">    <span class="tok-kw">try</span> testing.expect(x == <span class="tok-number">2147483647</span>);</span>
<span class="line" id="L1347">}</span>
<span class="line" id="L1348"></span>
<span class="line" id="L1349"><span class="tok-comment">/// Multiply a and b. Return type is wide enough to guarantee no</span></span>
<span class="line" id="L1350"><span class="tok-comment">/// overflow.</span></span>
<span class="line" id="L1351"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">mulWide</span>(<span class="tok-kw">comptime</span> T: <span class="tok-type">type</span>, a: T, b: T) std.meta.Int(</span>
<span class="line" id="L1352">    <span class="tok-builtin">@typeInfo</span>(T).Int.signedness,</span>
<span class="line" id="L1353">    <span class="tok-builtin">@typeInfo</span>(T).Int.bits * <span class="tok-number">2</span>,</span>
<span class="line" id="L1354">) {</span>
<span class="line" id="L1355">    <span class="tok-kw">const</span> ResultInt = std.meta.Int(</span>
<span class="line" id="L1356">        <span class="tok-builtin">@typeInfo</span>(T).Int.signedness,</span>
<span class="line" id="L1357">        <span class="tok-builtin">@typeInfo</span>(T).Int.bits * <span class="tok-number">2</span>,</span>
<span class="line" id="L1358">    );</span>
<span class="line" id="L1359">    <span class="tok-kw">return</span> <span class="tok-builtin">@as</span>(ResultInt, a) * <span class="tok-builtin">@as</span>(ResultInt, b);</span>
<span class="line" id="L1360">}</span>
<span class="line" id="L1361"></span>
<span class="line" id="L1362"><span class="tok-kw">test</span> <span class="tok-str">&quot;mulWide&quot;</span> {</span>
<span class="line" id="L1363">    <span class="tok-kw">try</span> testing.expect(mulWide(<span class="tok-type">u8</span>, <span class="tok-number">5</span>, <span class="tok-number">5</span>) == <span class="tok-number">25</span>);</span>
<span class="line" id="L1364">    <span class="tok-kw">try</span> testing.expect(mulWide(<span class="tok-type">i8</span>, <span class="tok-number">5</span>, -<span class="tok-number">5</span>) == -<span class="tok-number">25</span>);</span>
<span class="line" id="L1365">    <span class="tok-kw">try</span> testing.expect(mulWide(<span class="tok-type">u8</span>, <span class="tok-number">100</span>, <span class="tok-number">100</span>) == <span class="tok-number">10000</span>);</span>
<span class="line" id="L1366">}</span>
<span class="line" id="L1367"></span>
<span class="line" id="L1368"><span class="tok-comment">/// See also `CompareOperator`.</span></span>
<span class="line" id="L1369"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> Order = <span class="tok-kw">enum</span> {</span>
<span class="line" id="L1370">    <span class="tok-comment">/// Less than (`&lt;`)</span></span>
<span class="line" id="L1371">    lt,</span>
<span class="line" id="L1372"></span>
<span class="line" id="L1373">    <span class="tok-comment">/// Equal (`==`)</span></span>
<span class="line" id="L1374">    eq,</span>
<span class="line" id="L1375"></span>
<span class="line" id="L1376">    <span class="tok-comment">/// Greater than (`&gt;`)</span></span>
<span class="line" id="L1377">    gt,</span>
<span class="line" id="L1378"></span>
<span class="line" id="L1379">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">invert</span>(self: Order) Order {</span>
<span class="line" id="L1380">        <span class="tok-kw">return</span> <span class="tok-kw">switch</span> (self) {</span>
<span class="line" id="L1381">            .lt =&gt; .gt,</span>
<span class="line" id="L1382">            .eq =&gt; .eq,</span>
<span class="line" id="L1383">            .gt =&gt; .lt,</span>
<span class="line" id="L1384">        };</span>
<span class="line" id="L1385">    }</span>
<span class="line" id="L1386"></span>
<span class="line" id="L1387">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">compare</span>(self: Order, op: CompareOperator) <span class="tok-type">bool</span> {</span>
<span class="line" id="L1388">        <span class="tok-kw">return</span> <span class="tok-kw">switch</span> (self) {</span>
<span class="line" id="L1389">            .lt =&gt; <span class="tok-kw">switch</span> (op) {</span>
<span class="line" id="L1390">                .lt =&gt; <span class="tok-null">true</span>,</span>
<span class="line" id="L1391">                .lte =&gt; <span class="tok-null">true</span>,</span>
<span class="line" id="L1392">                .eq =&gt; <span class="tok-null">false</span>,</span>
<span class="line" id="L1393">                .gte =&gt; <span class="tok-null">false</span>,</span>
<span class="line" id="L1394">                .gt =&gt; <span class="tok-null">false</span>,</span>
<span class="line" id="L1395">                .neq =&gt; <span class="tok-null">true</span>,</span>
<span class="line" id="L1396">            },</span>
<span class="line" id="L1397">            .eq =&gt; <span class="tok-kw">switch</span> (op) {</span>
<span class="line" id="L1398">                .lt =&gt; <span class="tok-null">false</span>,</span>
<span class="line" id="L1399">                .lte =&gt; <span class="tok-null">true</span>,</span>
<span class="line" id="L1400">                .eq =&gt; <span class="tok-null">true</span>,</span>
<span class="line" id="L1401">                .gte =&gt; <span class="tok-null">true</span>,</span>
<span class="line" id="L1402">                .gt =&gt; <span class="tok-null">false</span>,</span>
<span class="line" id="L1403">                .neq =&gt; <span class="tok-null">false</span>,</span>
<span class="line" id="L1404">            },</span>
<span class="line" id="L1405">            .gt =&gt; <span class="tok-kw">switch</span> (op) {</span>
<span class="line" id="L1406">                .lt =&gt; <span class="tok-null">false</span>,</span>
<span class="line" id="L1407">                .lte =&gt; <span class="tok-null">false</span>,</span>
<span class="line" id="L1408">                .eq =&gt; <span class="tok-null">false</span>,</span>
<span class="line" id="L1409">                .gte =&gt; <span class="tok-null">true</span>,</span>
<span class="line" id="L1410">                .gt =&gt; <span class="tok-null">true</span>,</span>
<span class="line" id="L1411">                .neq =&gt; <span class="tok-null">true</span>,</span>
<span class="line" id="L1412">            },</span>
<span class="line" id="L1413">        };</span>
<span class="line" id="L1414">    }</span>
<span class="line" id="L1415">};</span>
<span class="line" id="L1416"></span>
<span class="line" id="L1417"><span class="tok-comment">/// Given two numbers, this function returns the order they are with respect to each other.</span></span>
<span class="line" id="L1418"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">order</span>(a: <span class="tok-kw">anytype</span>, b: <span class="tok-kw">anytype</span>) Order {</span>
<span class="line" id="L1419">    <span class="tok-kw">if</span> (a == b) {</span>
<span class="line" id="L1420">        <span class="tok-kw">return</span> .eq;</span>
<span class="line" id="L1421">    } <span class="tok-kw">else</span> <span class="tok-kw">if</span> (a &lt; b) {</span>
<span class="line" id="L1422">        <span class="tok-kw">return</span> .lt;</span>
<span class="line" id="L1423">    } <span class="tok-kw">else</span> <span class="tok-kw">if</span> (a &gt; b) {</span>
<span class="line" id="L1424">        <span class="tok-kw">return</span> .gt;</span>
<span class="line" id="L1425">    } <span class="tok-kw">else</span> {</span>
<span class="line" id="L1426">        <span class="tok-kw">unreachable</span>;</span>
<span class="line" id="L1427">    }</span>
<span class="line" id="L1428">}</span>
<span class="line" id="L1429"></span>
<span class="line" id="L1430"><span class="tok-comment">/// See also `Order`.</span></span>
<span class="line" id="L1431"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> CompareOperator = <span class="tok-kw">enum</span> {</span>
<span class="line" id="L1432">    <span class="tok-comment">/// Less than (`&lt;`)</span></span>
<span class="line" id="L1433">    lt,</span>
<span class="line" id="L1434">    <span class="tok-comment">/// Less than or equal (`&lt;=`)</span></span>
<span class="line" id="L1435">    lte,</span>
<span class="line" id="L1436">    <span class="tok-comment">/// Equal (`==`)</span></span>
<span class="line" id="L1437">    eq,</span>
<span class="line" id="L1438">    <span class="tok-comment">/// Greater than or equal (`&gt;=`)</span></span>
<span class="line" id="L1439">    gte,</span>
<span class="line" id="L1440">    <span class="tok-comment">/// Greater than (`&gt;`)</span></span>
<span class="line" id="L1441">    gt,</span>
<span class="line" id="L1442">    <span class="tok-comment">/// Not equal (`!=`)</span></span>
<span class="line" id="L1443">    neq,</span>
<span class="line" id="L1444">};</span>
<span class="line" id="L1445"></span>
<span class="line" id="L1446"><span class="tok-comment">/// This function does the same thing as comparison operators, however the</span></span>
<span class="line" id="L1447"><span class="tok-comment">/// operator is a runtime-known enum value. Works on any operands that</span></span>
<span class="line" id="L1448"><span class="tok-comment">/// support comparison operators.</span></span>
<span class="line" id="L1449"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">compare</span>(a: <span class="tok-kw">anytype</span>, op: CompareOperator, b: <span class="tok-kw">anytype</span>) <span class="tok-type">bool</span> {</span>
<span class="line" id="L1450">    <span class="tok-kw">return</span> <span class="tok-kw">switch</span> (op) {</span>
<span class="line" id="L1451">        .lt =&gt; a &lt; b,</span>
<span class="line" id="L1452">        .lte =&gt; a &lt;= b,</span>
<span class="line" id="L1453">        .eq =&gt; a == b,</span>
<span class="line" id="L1454">        .neq =&gt; a != b,</span>
<span class="line" id="L1455">        .gt =&gt; a &gt; b,</span>
<span class="line" id="L1456">        .gte =&gt; a &gt;= b,</span>
<span class="line" id="L1457">    };</span>
<span class="line" id="L1458">}</span>
<span class="line" id="L1459"></span>
<span class="line" id="L1460"><span class="tok-kw">test</span> <span class="tok-str">&quot;compare between signed and unsigned&quot;</span> {</span>
<span class="line" id="L1461">    <span class="tok-kw">try</span> testing.expect(compare(<span class="tok-builtin">@as</span>(<span class="tok-type">i8</span>, -<span class="tok-number">1</span>), .lt, <span class="tok-builtin">@as</span>(<span class="tok-type">u8</span>, <span class="tok-number">255</span>)));</span>
<span class="line" id="L1462">    <span class="tok-kw">try</span> testing.expect(compare(<span class="tok-builtin">@as</span>(<span class="tok-type">i8</span>, <span class="tok-number">2</span>), .gt, <span class="tok-builtin">@as</span>(<span class="tok-type">u8</span>, <span class="tok-number">1</span>)));</span>
<span class="line" id="L1463">    <span class="tok-kw">try</span> testing.expect(!compare(<span class="tok-builtin">@as</span>(<span class="tok-type">i8</span>, -<span class="tok-number">1</span>), .gte, <span class="tok-builtin">@as</span>(<span class="tok-type">u8</span>, <span class="tok-number">255</span>)));</span>
<span class="line" id="L1464">    <span class="tok-kw">try</span> testing.expect(compare(<span class="tok-builtin">@as</span>(<span class="tok-type">u8</span>, <span class="tok-number">255</span>), .gt, <span class="tok-builtin">@as</span>(<span class="tok-type">i8</span>, -<span class="tok-number">1</span>)));</span>
<span class="line" id="L1465">    <span class="tok-kw">try</span> testing.expect(!compare(<span class="tok-builtin">@as</span>(<span class="tok-type">u8</span>, <span class="tok-number">255</span>), .lte, <span class="tok-builtin">@as</span>(<span class="tok-type">i8</span>, -<span class="tok-number">1</span>)));</span>
<span class="line" id="L1466">    <span class="tok-kw">try</span> testing.expect(compare(<span class="tok-builtin">@as</span>(<span class="tok-type">i8</span>, -<span class="tok-number">1</span>), .lt, <span class="tok-builtin">@as</span>(<span class="tok-type">u9</span>, <span class="tok-number">255</span>)));</span>
<span class="line" id="L1467">    <span class="tok-kw">try</span> testing.expect(!compare(<span class="tok-builtin">@as</span>(<span class="tok-type">i8</span>, -<span class="tok-number">1</span>), .gte, <span class="tok-builtin">@as</span>(<span class="tok-type">u9</span>, <span class="tok-number">255</span>)));</span>
<span class="line" id="L1468">    <span class="tok-kw">try</span> testing.expect(compare(<span class="tok-builtin">@as</span>(<span class="tok-type">u9</span>, <span class="tok-number">255</span>), .gt, <span class="tok-builtin">@as</span>(<span class="tok-type">i8</span>, -<span class="tok-number">1</span>)));</span>
<span class="line" id="L1469">    <span class="tok-kw">try</span> testing.expect(!compare(<span class="tok-builtin">@as</span>(<span class="tok-type">u9</span>, <span class="tok-number">255</span>), .lte, <span class="tok-builtin">@as</span>(<span class="tok-type">i8</span>, -<span class="tok-number">1</span>)));</span>
<span class="line" id="L1470">    <span class="tok-kw">try</span> testing.expect(compare(<span class="tok-builtin">@as</span>(<span class="tok-type">i9</span>, -<span class="tok-number">1</span>), .lt, <span class="tok-builtin">@as</span>(<span class="tok-type">u8</span>, <span class="tok-number">255</span>)));</span>
<span class="line" id="L1471">    <span class="tok-kw">try</span> testing.expect(!compare(<span class="tok-builtin">@as</span>(<span class="tok-type">i9</span>, -<span class="tok-number">1</span>), .gte, <span class="tok-builtin">@as</span>(<span class="tok-type">u8</span>, <span class="tok-number">255</span>)));</span>
<span class="line" id="L1472">    <span class="tok-kw">try</span> testing.expect(compare(<span class="tok-builtin">@as</span>(<span class="tok-type">u8</span>, <span class="tok-number">255</span>), .gt, <span class="tok-builtin">@as</span>(<span class="tok-type">i9</span>, -<span class="tok-number">1</span>)));</span>
<span class="line" id="L1473">    <span class="tok-kw">try</span> testing.expect(!compare(<span class="tok-builtin">@as</span>(<span class="tok-type">u8</span>, <span class="tok-number">255</span>), .lte, <span class="tok-builtin">@as</span>(<span class="tok-type">i9</span>, -<span class="tok-number">1</span>)));</span>
<span class="line" id="L1474">    <span class="tok-kw">try</span> testing.expect(compare(<span class="tok-builtin">@as</span>(<span class="tok-type">u8</span>, <span class="tok-number">1</span>), .lt, <span class="tok-builtin">@as</span>(<span class="tok-type">u8</span>, <span class="tok-number">2</span>)));</span>
<span class="line" id="L1475">    <span class="tok-kw">try</span> testing.expect(<span class="tok-builtin">@bitCast</span>(<span class="tok-type">u8</span>, <span class="tok-builtin">@as</span>(<span class="tok-type">i8</span>, -<span class="tok-number">1</span>)) == <span class="tok-builtin">@as</span>(<span class="tok-type">u8</span>, <span class="tok-number">255</span>));</span>
<span class="line" id="L1476">    <span class="tok-kw">try</span> testing.expect(!compare(<span class="tok-builtin">@as</span>(<span class="tok-type">u8</span>, <span class="tok-number">255</span>), .eq, <span class="tok-builtin">@as</span>(<span class="tok-type">i8</span>, -<span class="tok-number">1</span>)));</span>
<span class="line" id="L1477">    <span class="tok-kw">try</span> testing.expect(compare(<span class="tok-builtin">@as</span>(<span class="tok-type">u8</span>, <span class="tok-number">1</span>), .eq, <span class="tok-builtin">@as</span>(<span class="tok-type">u8</span>, <span class="tok-number">1</span>)));</span>
<span class="line" id="L1478">}</span>
<span class="line" id="L1479"></span>
<span class="line" id="L1480"><span class="tok-kw">test</span> <span class="tok-str">&quot;order&quot;</span> {</span>
<span class="line" id="L1481">    <span class="tok-kw">try</span> testing.expect(order(<span class="tok-number">0</span>, <span class="tok-number">0</span>) == .eq);</span>
<span class="line" id="L1482">    <span class="tok-kw">try</span> testing.expect(order(<span class="tok-number">1</span>, <span class="tok-number">0</span>) == .gt);</span>
<span class="line" id="L1483">    <span class="tok-kw">try</span> testing.expect(order(-<span class="tok-number">1</span>, <span class="tok-number">0</span>) == .lt);</span>
<span class="line" id="L1484">}</span>
<span class="line" id="L1485"></span>
<span class="line" id="L1486"><span class="tok-kw">test</span> <span class="tok-str">&quot;order.invert&quot;</span> {</span>
<span class="line" id="L1487">    <span class="tok-kw">try</span> testing.expect(Order.invert(order(<span class="tok-number">0</span>, <span class="tok-number">0</span>)) == .eq);</span>
<span class="line" id="L1488">    <span class="tok-kw">try</span> testing.expect(Order.invert(order(<span class="tok-number">1</span>, <span class="tok-number">0</span>)) == .lt);</span>
<span class="line" id="L1489">    <span class="tok-kw">try</span> testing.expect(Order.invert(order(-<span class="tok-number">1</span>, <span class="tok-number">0</span>)) == .gt);</span>
<span class="line" id="L1490">}</span>
<span class="line" id="L1491"></span>
<span class="line" id="L1492"><span class="tok-kw">test</span> <span class="tok-str">&quot;order.compare&quot;</span> {</span>
<span class="line" id="L1493">    <span class="tok-kw">try</span> testing.expect(order(-<span class="tok-number">1</span>, <span class="tok-number">0</span>).compare(.lt));</span>
<span class="line" id="L1494">    <span class="tok-kw">try</span> testing.expect(order(-<span class="tok-number">1</span>, <span class="tok-number">0</span>).compare(.lte));</span>
<span class="line" id="L1495">    <span class="tok-kw">try</span> testing.expect(order(<span class="tok-number">0</span>, <span class="tok-number">0</span>).compare(.lte));</span>
<span class="line" id="L1496">    <span class="tok-kw">try</span> testing.expect(order(<span class="tok-number">0</span>, <span class="tok-number">0</span>).compare(.eq));</span>
<span class="line" id="L1497">    <span class="tok-kw">try</span> testing.expect(order(<span class="tok-number">0</span>, <span class="tok-number">0</span>).compare(.gte));</span>
<span class="line" id="L1498">    <span class="tok-kw">try</span> testing.expect(order(<span class="tok-number">1</span>, <span class="tok-number">0</span>).compare(.gte));</span>
<span class="line" id="L1499">    <span class="tok-kw">try</span> testing.expect(order(<span class="tok-number">1</span>, <span class="tok-number">0</span>).compare(.gt));</span>
<span class="line" id="L1500">    <span class="tok-kw">try</span> testing.expect(order(<span class="tok-number">1</span>, <span class="tok-number">0</span>).compare(.neq));</span>
<span class="line" id="L1501">}</span>
<span class="line" id="L1502"></span>
<span class="line" id="L1503"><span class="tok-comment">/// Returns a mask of all ones if value is true,</span></span>
<span class="line" id="L1504"><span class="tok-comment">/// and a mask of all zeroes if value is false.</span></span>
<span class="line" id="L1505"><span class="tok-comment">/// Compiles to one instruction for register sized integers.</span></span>
<span class="line" id="L1506"><span class="tok-kw">pub</span> <span class="tok-kw">inline</span> <span class="tok-kw">fn</span> <span class="tok-fn">boolMask</span>(<span class="tok-kw">comptime</span> MaskInt: <span class="tok-type">type</span>, value: <span class="tok-type">bool</span>) MaskInt {</span>
<span class="line" id="L1507">    <span class="tok-kw">if</span> (<span class="tok-builtin">@typeInfo</span>(MaskInt) != .Int)</span>
<span class="line" id="L1508">        <span class="tok-builtin">@compileError</span>(<span class="tok-str">&quot;boolMask requires an integer mask type.&quot;</span>);</span>
<span class="line" id="L1509"></span>
<span class="line" id="L1510">    <span class="tok-kw">if</span> (MaskInt == <span class="tok-type">u0</span> <span class="tok-kw">or</span> MaskInt == <span class="tok-type">i0</span>)</span>
<span class="line" id="L1511">        <span class="tok-builtin">@compileError</span>(<span class="tok-str">&quot;boolMask cannot convert to u0 or i0, they are too small.&quot;</span>);</span>
<span class="line" id="L1512"></span>
<span class="line" id="L1513">    <span class="tok-comment">// The u1 and i1 cases tend to overflow,</span>
</span>
<span class="line" id="L1514">    <span class="tok-comment">// so we special case them here.</span>
</span>
<span class="line" id="L1515">    <span class="tok-kw">if</span> (MaskInt == <span class="tok-type">u1</span>) <span class="tok-kw">return</span> <span class="tok-builtin">@boolToInt</span>(value);</span>
<span class="line" id="L1516">    <span class="tok-kw">if</span> (MaskInt == <span class="tok-type">i1</span>) {</span>
<span class="line" id="L1517">        <span class="tok-comment">// The @as here is a workaround for #7950</span>
</span>
<span class="line" id="L1518">        <span class="tok-kw">return</span> <span class="tok-builtin">@bitCast</span>(<span class="tok-type">i1</span>, <span class="tok-builtin">@as</span>(<span class="tok-type">u1</span>, <span class="tok-builtin">@boolToInt</span>(value)));</span>
<span class="line" id="L1519">    }</span>
<span class="line" id="L1520"></span>
<span class="line" id="L1521">    <span class="tok-kw">return</span> -%<span class="tok-builtin">@intCast</span>(MaskInt, <span class="tok-builtin">@boolToInt</span>(value));</span>
<span class="line" id="L1522">}</span>
<span class="line" id="L1523"></span>
<span class="line" id="L1524"><span class="tok-kw">test</span> <span class="tok-str">&quot;boolMask&quot;</span> {</span>
<span class="line" id="L1525">    <span class="tok-kw">const</span> runTest = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L1526">        <span class="tok-kw">fn</span> <span class="tok-fn">runTest</span>() !<span class="tok-type">void</span> {</span>
<span class="line" id="L1527">            <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">u1</span>, <span class="tok-number">0</span>), boolMask(<span class="tok-type">u1</span>, <span class="tok-null">false</span>));</span>
<span class="line" id="L1528">            <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">u1</span>, <span class="tok-number">1</span>), boolMask(<span class="tok-type">u1</span>, <span class="tok-null">true</span>));</span>
<span class="line" id="L1529"></span>
<span class="line" id="L1530">            <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">i1</span>, <span class="tok-number">0</span>), boolMask(<span class="tok-type">i1</span>, <span class="tok-null">false</span>));</span>
<span class="line" id="L1531">            <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">i1</span>, -<span class="tok-number">1</span>), boolMask(<span class="tok-type">i1</span>, <span class="tok-null">true</span>));</span>
<span class="line" id="L1532"></span>
<span class="line" id="L1533">            <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">u13</span>, <span class="tok-number">0</span>), boolMask(<span class="tok-type">u13</span>, <span class="tok-null">false</span>));</span>
<span class="line" id="L1534">            <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">u13</span>, <span class="tok-number">0x1FFF</span>), boolMask(<span class="tok-type">u13</span>, <span class="tok-null">true</span>));</span>
<span class="line" id="L1535"></span>
<span class="line" id="L1536">            <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">i13</span>, <span class="tok-number">0</span>), boolMask(<span class="tok-type">i13</span>, <span class="tok-null">false</span>));</span>
<span class="line" id="L1537">            <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">i13</span>, -<span class="tok-number">1</span>), boolMask(<span class="tok-type">i13</span>, <span class="tok-null">true</span>));</span>
<span class="line" id="L1538"></span>
<span class="line" id="L1539">            <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">u32</span>, <span class="tok-number">0</span>), boolMask(<span class="tok-type">u32</span>, <span class="tok-null">false</span>));</span>
<span class="line" id="L1540">            <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">u32</span>, <span class="tok-number">0xFFFF_FFFF</span>), boolMask(<span class="tok-type">u32</span>, <span class="tok-null">true</span>));</span>
<span class="line" id="L1541"></span>
<span class="line" id="L1542">            <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">i32</span>, <span class="tok-number">0</span>), boolMask(<span class="tok-type">i32</span>, <span class="tok-null">false</span>));</span>
<span class="line" id="L1543">            <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">i32</span>, -<span class="tok-number">1</span>), boolMask(<span class="tok-type">i32</span>, <span class="tok-null">true</span>));</span>
<span class="line" id="L1544">        }</span>
<span class="line" id="L1545">    }.runTest;</span>
<span class="line" id="L1546">    <span class="tok-kw">try</span> runTest();</span>
<span class="line" id="L1547">    <span class="tok-kw">comptime</span> <span class="tok-kw">try</span> runTest();</span>
<span class="line" id="L1548">}</span>
<span class="line" id="L1549"></span>
<span class="line" id="L1550"><span class="tok-comment">/// Return the mod of `num` with the smallest integer type</span></span>
<span class="line" id="L1551"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">comptimeMod</span>(num: <span class="tok-kw">anytype</span>, denom: <span class="tok-type">comptime_int</span>) IntFittingRange(<span class="tok-number">0</span>, denom - <span class="tok-number">1</span>) {</span>
<span class="line" id="L1552">    <span class="tok-kw">return</span> <span class="tok-builtin">@intCast</span>(IntFittingRange(<span class="tok-number">0</span>, denom - <span class="tok-number">1</span>), <span class="tok-builtin">@mod</span>(num, denom));</span>
<span class="line" id="L1553">}</span>
<span class="line" id="L1554"></span>
<span class="line" id="L1555"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> F80 = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L1556">    fraction: <span class="tok-type">u64</span>,</span>
<span class="line" id="L1557">    exp: <span class="tok-type">u16</span>,</span>
<span class="line" id="L1558">};</span>
<span class="line" id="L1559"></span>
<span class="line" id="L1560"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">make_f80</span>(repr: F80) f80 {</span>
<span class="line" id="L1561">    <span class="tok-kw">const</span> int = (<span class="tok-builtin">@as</span>(<span class="tok-type">u80</span>, repr.exp) &lt;&lt; <span class="tok-number">64</span>) | repr.fraction;</span>
<span class="line" id="L1562">    <span class="tok-kw">return</span> <span class="tok-builtin">@bitCast</span>(f80, int);</span>
<span class="line" id="L1563">}</span>
<span class="line" id="L1564"></span>
<span class="line" id="L1565"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">break_f80</span>(x: f80) F80 {</span>
<span class="line" id="L1566">    <span class="tok-kw">const</span> int = <span class="tok-builtin">@bitCast</span>(<span class="tok-type">u80</span>, x);</span>
<span class="line" id="L1567">    <span class="tok-kw">return</span> .{</span>
<span class="line" id="L1568">        .fraction = <span class="tok-builtin">@truncate</span>(<span class="tok-type">u64</span>, int),</span>
<span class="line" id="L1569">        .exp = <span class="tok-builtin">@truncate</span>(<span class="tok-type">u16</span>, int &gt;&gt; <span class="tok-number">64</span>),</span>
<span class="line" id="L1570">    };</span>
<span class="line" id="L1571">}</span>
<span class="line" id="L1572"></span>
<span class="line" id="L1573"><span class="tok-comment">/// Returns -1, 0, or 1.</span></span>
<span class="line" id="L1574"><span class="tok-comment">/// Supports integer types, vectors of integer types, and float types.</span></span>
<span class="line" id="L1575"><span class="tok-comment">/// Unsigned integer types will always return 0 or 1.</span></span>
<span class="line" id="L1576"><span class="tok-comment">/// TODO: support vectors of floats</span></span>
<span class="line" id="L1577"><span class="tok-comment">/// Branchless.</span></span>
<span class="line" id="L1578"><span class="tok-kw">pub</span> <span class="tok-kw">inline</span> <span class="tok-kw">fn</span> <span class="tok-fn">sign</span>(i: <span class="tok-kw">anytype</span>) <span class="tok-builtin">@TypeOf</span>(i) {</span>
<span class="line" id="L1579">    <span class="tok-kw">const</span> T = <span class="tok-builtin">@TypeOf</span>(i);</span>
<span class="line" id="L1580">    <span class="tok-kw">return</span> <span class="tok-kw">switch</span> (<span class="tok-builtin">@typeInfo</span>(T)) {</span>
<span class="line" id="L1581">        .Int, .ComptimeInt =&gt; <span class="tok-builtin">@as</span>(T, <span class="tok-builtin">@boolToInt</span>(i &gt; <span class="tok-number">0</span>)) - <span class="tok-builtin">@boolToInt</span>(i &lt; <span class="tok-number">0</span>),</span>
<span class="line" id="L1582">        .Float, .ComptimeFloat =&gt; <span class="tok-builtin">@intToFloat</span>(T, <span class="tok-builtin">@boolToInt</span>(i &gt; <span class="tok-number">0</span>)) - <span class="tok-builtin">@intToFloat</span>(T, <span class="tok-builtin">@boolToInt</span>(i &lt; <span class="tok-number">0</span>)),</span>
<span class="line" id="L1583">        .Vector =&gt; |vinfo| blk: {</span>
<span class="line" id="L1584">            <span class="tok-kw">const</span> u1xN = std.meta.Vector(vinfo.len, <span class="tok-type">u1</span>);</span>
<span class="line" id="L1585">            <span class="tok-kw">break</span> :blk <span class="tok-kw">switch</span> (<span class="tok-builtin">@typeInfo</span>(vinfo.child)) {</span>
<span class="line" id="L1586">                .Int =&gt; <span class="tok-builtin">@as</span>(T, <span class="tok-builtin">@bitCast</span>(u1xN, i &gt; <span class="tok-builtin">@splat</span>(vinfo.len, <span class="tok-builtin">@as</span>(vinfo.child, <span class="tok-number">0</span>)))) -</span>
<span class="line" id="L1587">                    <span class="tok-builtin">@as</span>(T, <span class="tok-builtin">@bitCast</span>(u1xN, i &lt; <span class="tok-builtin">@splat</span>(vinfo.len, <span class="tok-builtin">@as</span>(vinfo.child, <span class="tok-number">0</span>)))),</span>
<span class="line" id="L1588">                .Float =&gt; <span class="tok-builtin">@compileError</span>(<span class="tok-str">&quot;TODO: add support for vectors of floats once @intToFloat accepts vector types&quot;</span>),</span>
<span class="line" id="L1589">                <span class="tok-comment">// break :blk @intToFloat(T, @bitCast(u1xN, i &gt; @splat(vinfo.len, @as(vinfo.child, 0)))) -</span>
</span>
<span class="line" id="L1590">                <span class="tok-comment">//     @intToFloat(T, @bitCast(u1xN, i &lt; @splat(vinfo.len, @as(vinfo.child, 0)))),</span>
</span>
<span class="line" id="L1591">                <span class="tok-kw">else</span> =&gt; <span class="tok-builtin">@compileError</span>(<span class="tok-str">&quot;Expected vector of ints or floats, found &quot;</span> ++ <span class="tok-builtin">@typeName</span>(T)),</span>
<span class="line" id="L1592">            };</span>
<span class="line" id="L1593">        },</span>
<span class="line" id="L1594">        <span class="tok-kw">else</span> =&gt; <span class="tok-builtin">@compileError</span>(<span class="tok-str">&quot;Expected an int, float or vector of one, found &quot;</span> ++ <span class="tok-builtin">@typeName</span>(T)),</span>
<span class="line" id="L1595">    };</span>
<span class="line" id="L1596">}</span>
<span class="line" id="L1597"></span>
<span class="line" id="L1598"><span class="tok-kw">fn</span> <span class="tok-fn">testSign</span>() !<span class="tok-type">void</span> {</span>
<span class="line" id="L1599">    <span class="tok-comment">// each of the following blocks checks the inputs</span>
</span>
<span class="line" id="L1600">    <span class="tok-comment">// 2, -2, 0, { 2, -2, 0 } provide expected output</span>
</span>
<span class="line" id="L1601">    <span class="tok-comment">// 1, -1, 0, { 1, -1, 0 } for the given T</span>
</span>
<span class="line" id="L1602">    <span class="tok-comment">// (negative values omitted for unsigned types)</span>
</span>
<span class="line" id="L1603">    {</span>
<span class="line" id="L1604">        <span class="tok-kw">const</span> T = <span class="tok-type">i8</span>;</span>
<span class="line" id="L1605">        <span class="tok-kw">try</span> std.testing.expectEqual(<span class="tok-builtin">@as</span>(T, <span class="tok-number">1</span>), sign(<span class="tok-builtin">@as</span>(T, <span class="tok-number">2</span>)));</span>
<span class="line" id="L1606">        <span class="tok-kw">try</span> std.testing.expectEqual(<span class="tok-builtin">@as</span>(T, -<span class="tok-number">1</span>), sign(<span class="tok-builtin">@as</span>(T, -<span class="tok-number">2</span>)));</span>
<span class="line" id="L1607">        <span class="tok-kw">try</span> std.testing.expectEqual(<span class="tok-builtin">@as</span>(T, <span class="tok-number">0</span>), sign(<span class="tok-builtin">@as</span>(T, <span class="tok-number">0</span>)));</span>
<span class="line" id="L1608">        <span class="tok-kw">try</span> std.testing.expectEqual(<span class="tok-builtin">@Vector</span>(<span class="tok-number">3</span>, T){ <span class="tok-number">1</span>, -<span class="tok-number">1</span>, <span class="tok-number">0</span> }, sign(<span class="tok-builtin">@Vector</span>(<span class="tok-number">3</span>, T){ <span class="tok-number">2</span>, -<span class="tok-number">2</span>, <span class="tok-number">0</span> }));</span>
<span class="line" id="L1609">    }</span>
<span class="line" id="L1610">    {</span>
<span class="line" id="L1611">        <span class="tok-kw">const</span> T = <span class="tok-type">i32</span>;</span>
<span class="line" id="L1612">        <span class="tok-kw">try</span> std.testing.expectEqual(<span class="tok-builtin">@as</span>(T, <span class="tok-number">1</span>), sign(<span class="tok-builtin">@as</span>(T, <span class="tok-number">2</span>)));</span>
<span class="line" id="L1613">        <span class="tok-kw">try</span> std.testing.expectEqual(<span class="tok-builtin">@as</span>(T, -<span class="tok-number">1</span>), sign(<span class="tok-builtin">@as</span>(T, -<span class="tok-number">2</span>)));</span>
<span class="line" id="L1614">        <span class="tok-kw">try</span> std.testing.expectEqual(<span class="tok-builtin">@as</span>(T, <span class="tok-number">0</span>), sign(<span class="tok-builtin">@as</span>(T, <span class="tok-number">0</span>)));</span>
<span class="line" id="L1615">        <span class="tok-kw">try</span> std.testing.expectEqual(<span class="tok-builtin">@Vector</span>(<span class="tok-number">3</span>, T){ <span class="tok-number">1</span>, -<span class="tok-number">1</span>, <span class="tok-number">0</span> }, sign(<span class="tok-builtin">@Vector</span>(<span class="tok-number">3</span>, T){ <span class="tok-number">2</span>, -<span class="tok-number">2</span>, <span class="tok-number">0</span> }));</span>
<span class="line" id="L1616">    }</span>
<span class="line" id="L1617">    {</span>
<span class="line" id="L1618">        <span class="tok-kw">const</span> T = <span class="tok-type">i64</span>;</span>
<span class="line" id="L1619">        <span class="tok-kw">try</span> std.testing.expectEqual(<span class="tok-builtin">@as</span>(T, <span class="tok-number">1</span>), sign(<span class="tok-builtin">@as</span>(T, <span class="tok-number">2</span>)));</span>
<span class="line" id="L1620">        <span class="tok-kw">try</span> std.testing.expectEqual(<span class="tok-builtin">@as</span>(T, -<span class="tok-number">1</span>), sign(<span class="tok-builtin">@as</span>(T, -<span class="tok-number">2</span>)));</span>
<span class="line" id="L1621">        <span class="tok-kw">try</span> std.testing.expectEqual(<span class="tok-builtin">@as</span>(T, <span class="tok-number">0</span>), sign(<span class="tok-builtin">@as</span>(T, <span class="tok-number">0</span>)));</span>
<span class="line" id="L1622">        <span class="tok-kw">try</span> std.testing.expectEqual(<span class="tok-builtin">@Vector</span>(<span class="tok-number">3</span>, T){ <span class="tok-number">1</span>, -<span class="tok-number">1</span>, <span class="tok-number">0</span> }, sign(<span class="tok-builtin">@Vector</span>(<span class="tok-number">3</span>, T){ <span class="tok-number">2</span>, -<span class="tok-number">2</span>, <span class="tok-number">0</span> }));</span>
<span class="line" id="L1623">    }</span>
<span class="line" id="L1624">    {</span>
<span class="line" id="L1625">        <span class="tok-kw">const</span> T = <span class="tok-type">u8</span>;</span>
<span class="line" id="L1626">        <span class="tok-kw">try</span> std.testing.expectEqual(<span class="tok-builtin">@as</span>(T, <span class="tok-number">1</span>), sign(<span class="tok-builtin">@as</span>(T, <span class="tok-number">2</span>)));</span>
<span class="line" id="L1627">        <span class="tok-kw">try</span> std.testing.expectEqual(<span class="tok-builtin">@as</span>(T, <span class="tok-number">0</span>), sign(<span class="tok-builtin">@as</span>(T, <span class="tok-number">0</span>)));</span>
<span class="line" id="L1628">        <span class="tok-kw">try</span> std.testing.expectEqual(<span class="tok-builtin">@Vector</span>(<span class="tok-number">2</span>, T){ <span class="tok-number">1</span>, <span class="tok-number">0</span> }, sign(<span class="tok-builtin">@Vector</span>(<span class="tok-number">2</span>, T){ <span class="tok-number">2</span>, <span class="tok-number">0</span> }));</span>
<span class="line" id="L1629">    }</span>
<span class="line" id="L1630">    {</span>
<span class="line" id="L1631">        <span class="tok-kw">const</span> T = <span class="tok-type">u32</span>;</span>
<span class="line" id="L1632">        <span class="tok-kw">try</span> std.testing.expectEqual(<span class="tok-builtin">@as</span>(T, <span class="tok-number">1</span>), sign(<span class="tok-builtin">@as</span>(T, <span class="tok-number">2</span>)));</span>
<span class="line" id="L1633">        <span class="tok-kw">try</span> std.testing.expectEqual(<span class="tok-builtin">@as</span>(T, <span class="tok-number">0</span>), sign(<span class="tok-builtin">@as</span>(T, <span class="tok-number">0</span>)));</span>
<span class="line" id="L1634">        <span class="tok-kw">try</span> std.testing.expectEqual(<span class="tok-builtin">@Vector</span>(<span class="tok-number">2</span>, T){ <span class="tok-number">1</span>, <span class="tok-number">0</span> }, sign(<span class="tok-builtin">@Vector</span>(<span class="tok-number">2</span>, T){ <span class="tok-number">2</span>, <span class="tok-number">0</span> }));</span>
<span class="line" id="L1635">    }</span>
<span class="line" id="L1636">    {</span>
<span class="line" id="L1637">        <span class="tok-kw">const</span> T = <span class="tok-type">u64</span>;</span>
<span class="line" id="L1638">        <span class="tok-kw">try</span> std.testing.expectEqual(<span class="tok-builtin">@as</span>(T, <span class="tok-number">1</span>), sign(<span class="tok-builtin">@as</span>(T, <span class="tok-number">2</span>)));</span>
<span class="line" id="L1639">        <span class="tok-kw">try</span> std.testing.expectEqual(<span class="tok-builtin">@as</span>(T, <span class="tok-number">0</span>), sign(<span class="tok-builtin">@as</span>(T, <span class="tok-number">0</span>)));</span>
<span class="line" id="L1640">        <span class="tok-kw">try</span> std.testing.expectEqual(<span class="tok-builtin">@Vector</span>(<span class="tok-number">2</span>, T){ <span class="tok-number">1</span>, <span class="tok-number">0</span> }, sign(<span class="tok-builtin">@Vector</span>(<span class="tok-number">2</span>, T){ <span class="tok-number">2</span>, <span class="tok-number">0</span> }));</span>
<span class="line" id="L1641">    }</span>
<span class="line" id="L1642">    {</span>
<span class="line" id="L1643">        <span class="tok-kw">const</span> T = <span class="tok-type">f16</span>;</span>
<span class="line" id="L1644">        <span class="tok-kw">try</span> std.testing.expectEqual(<span class="tok-builtin">@as</span>(T, <span class="tok-number">1</span>), sign(<span class="tok-builtin">@as</span>(T, <span class="tok-number">2</span>)));</span>
<span class="line" id="L1645">        <span class="tok-kw">try</span> std.testing.expectEqual(<span class="tok-builtin">@as</span>(T, -<span class="tok-number">1</span>), sign(<span class="tok-builtin">@as</span>(T, -<span class="tok-number">2</span>)));</span>
<span class="line" id="L1646">        <span class="tok-kw">try</span> std.testing.expectEqual(<span class="tok-builtin">@as</span>(T, <span class="tok-number">0</span>), sign(<span class="tok-builtin">@as</span>(T, <span class="tok-number">0</span>)));</span>
<span class="line" id="L1647">        <span class="tok-comment">// TODO - uncomment once @intToFloat supports vectors</span>
</span>
<span class="line" id="L1648">        <span class="tok-comment">// try std.testing.expectEqual(@Vector(3, T){ 1, -1, 0 }, sign(@Vector(3, T){ 2, -2, 0 }));</span>
</span>
<span class="line" id="L1649">    }</span>
<span class="line" id="L1650">    {</span>
<span class="line" id="L1651">        <span class="tok-kw">const</span> T = <span class="tok-type">f32</span>;</span>
<span class="line" id="L1652">        <span class="tok-kw">try</span> std.testing.expectEqual(<span class="tok-builtin">@as</span>(T, <span class="tok-number">1</span>), sign(<span class="tok-builtin">@as</span>(T, <span class="tok-number">2</span>)));</span>
<span class="line" id="L1653">        <span class="tok-kw">try</span> std.testing.expectEqual(<span class="tok-builtin">@as</span>(T, -<span class="tok-number">1</span>), sign(<span class="tok-builtin">@as</span>(T, -<span class="tok-number">2</span>)));</span>
<span class="line" id="L1654">        <span class="tok-kw">try</span> std.testing.expectEqual(<span class="tok-builtin">@as</span>(T, <span class="tok-number">0</span>), sign(<span class="tok-builtin">@as</span>(T, <span class="tok-number">0</span>)));</span>
<span class="line" id="L1655">        <span class="tok-comment">// TODO - uncomment once @intToFloat supports vectors</span>
</span>
<span class="line" id="L1656">        <span class="tok-comment">// try std.testing.expectEqual(@Vector(3, T){ 1, -1, 0 }, sign(@Vector(3, T){ 2, -2, 0 }));</span>
</span>
<span class="line" id="L1657">    }</span>
<span class="line" id="L1658">    {</span>
<span class="line" id="L1659">        <span class="tok-kw">const</span> T = <span class="tok-type">f64</span>;</span>
<span class="line" id="L1660">        <span class="tok-kw">try</span> std.testing.expectEqual(<span class="tok-builtin">@as</span>(T, <span class="tok-number">1</span>), sign(<span class="tok-builtin">@as</span>(T, <span class="tok-number">2</span>)));</span>
<span class="line" id="L1661">        <span class="tok-kw">try</span> std.testing.expectEqual(<span class="tok-builtin">@as</span>(T, -<span class="tok-number">1</span>), sign(<span class="tok-builtin">@as</span>(T, -<span class="tok-number">2</span>)));</span>
<span class="line" id="L1662">        <span class="tok-kw">try</span> std.testing.expectEqual(<span class="tok-builtin">@as</span>(T, <span class="tok-number">0</span>), sign(<span class="tok-builtin">@as</span>(T, <span class="tok-number">0</span>)));</span>
<span class="line" id="L1663">        <span class="tok-comment">// TODO - uncomment once @intToFloat supports vectors</span>
</span>
<span class="line" id="L1664">        <span class="tok-comment">// try std.testing.expectEqual(@Vector(3, T){ 1, -1, 0 }, sign(@Vector(3, T){ 2, -2, 0 }));</span>
</span>
<span class="line" id="L1665">    }</span>
<span class="line" id="L1666"></span>
<span class="line" id="L1667">    <span class="tok-comment">// comptime_int</span>
</span>
<span class="line" id="L1668">    <span class="tok-kw">try</span> std.testing.expectEqual(-<span class="tok-number">1</span>, sign(-<span class="tok-number">10</span>));</span>
<span class="line" id="L1669">    <span class="tok-kw">try</span> std.testing.expectEqual(<span class="tok-number">1</span>, sign(<span class="tok-number">10</span>));</span>
<span class="line" id="L1670">    <span class="tok-kw">try</span> std.testing.expectEqual(<span class="tok-number">0</span>, sign(<span class="tok-number">0</span>));</span>
<span class="line" id="L1671">    <span class="tok-comment">// comptime_float</span>
</span>
<span class="line" id="L1672">    <span class="tok-kw">try</span> std.testing.expectEqual(-<span class="tok-number">1.0</span>, sign(-<span class="tok-number">10.0</span>));</span>
<span class="line" id="L1673">    <span class="tok-kw">try</span> std.testing.expectEqual(<span class="tok-number">1.0</span>, sign(<span class="tok-number">10.0</span>));</span>
<span class="line" id="L1674">    <span class="tok-kw">try</span> std.testing.expectEqual(<span class="tok-number">0.0</span>, sign(<span class="tok-number">0.0</span>));</span>
<span class="line" id="L1675">}</span>
<span class="line" id="L1676"></span>
<span class="line" id="L1677"><span class="tok-kw">test</span> <span class="tok-str">&quot;sign&quot;</span> {</span>
<span class="line" id="L1678">    <span class="tok-kw">if</span> (builtin.zig_backend == .stage1 <span class="tok-kw">or</span> builtin.zig_backend == .stage2_llvm) {</span>
<span class="line" id="L1679">        <span class="tok-comment">// https://github.com/ziglang/zig/issues/12012</span>
</span>
<span class="line" id="L1680">        <span class="tok-kw">return</span> <span class="tok-kw">error</span>.SkipZigTest;</span>
<span class="line" id="L1681">    }</span>
<span class="line" id="L1682">    <span class="tok-kw">try</span> testSign();</span>
<span class="line" id="L1683">    <span class="tok-kw">comptime</span> <span class="tok-kw">try</span> testSign();</span>
<span class="line" id="L1684">}</span>
<span class="line" id="L1685"></span>
</code></pre></body>
</html>