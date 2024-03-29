<!doctype html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">    <title>unicode.zig - source view</title>
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
<pre><code><span class="line" id="L1"><span class="tok-kw">const</span> std = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;./std.zig&quot;</span>);</span>
<span class="line" id="L2"><span class="tok-kw">const</span> assert = std.debug.assert;</span>
<span class="line" id="L3"><span class="tok-kw">const</span> testing = std.testing;</span>
<span class="line" id="L4"><span class="tok-kw">const</span> mem = std.mem;</span>
<span class="line" id="L5"></span>
<span class="line" id="L6"><span class="tok-comment">/// Use this to replace an unknown, unrecognized, or unrepresentable character.</span></span>
<span class="line" id="L7"><span class="tok-comment">///</span></span>
<span class="line" id="L8"><span class="tok-comment">/// See also: https://en.wikipedia.org/wiki/Specials_(Unicode_block)#Replacement_character</span></span>
<span class="line" id="L9"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> replacement_character: <span class="tok-type">u21</span> = <span class="tok-number">0xFFFD</span>;</span>
<span class="line" id="L10"></span>
<span class="line" id="L11"><span class="tok-comment">/// Returns how many bytes the UTF-8 representation would require</span></span>
<span class="line" id="L12"><span class="tok-comment">/// for the given codepoint.</span></span>
<span class="line" id="L13"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">utf8CodepointSequenceLength</span>(c: <span class="tok-type">u21</span>) !<span class="tok-type">u3</span> {</span>
<span class="line" id="L14">    <span class="tok-kw">if</span> (c &lt; <span class="tok-number">0x80</span>) <span class="tok-kw">return</span> <span class="tok-builtin">@as</span>(<span class="tok-type">u3</span>, <span class="tok-number">1</span>);</span>
<span class="line" id="L15">    <span class="tok-kw">if</span> (c &lt; <span class="tok-number">0x800</span>) <span class="tok-kw">return</span> <span class="tok-builtin">@as</span>(<span class="tok-type">u3</span>, <span class="tok-number">2</span>);</span>
<span class="line" id="L16">    <span class="tok-kw">if</span> (c &lt; <span class="tok-number">0x10000</span>) <span class="tok-kw">return</span> <span class="tok-builtin">@as</span>(<span class="tok-type">u3</span>, <span class="tok-number">3</span>);</span>
<span class="line" id="L17">    <span class="tok-kw">if</span> (c &lt; <span class="tok-number">0x110000</span>) <span class="tok-kw">return</span> <span class="tok-builtin">@as</span>(<span class="tok-type">u3</span>, <span class="tok-number">4</span>);</span>
<span class="line" id="L18">    <span class="tok-kw">return</span> <span class="tok-kw">error</span>.CodepointTooLarge;</span>
<span class="line" id="L19">}</span>
<span class="line" id="L20"></span>
<span class="line" id="L21"><span class="tok-comment">/// Given the first byte of a UTF-8 codepoint,</span></span>
<span class="line" id="L22"><span class="tok-comment">/// returns a number 1-4 indicating the total length of the codepoint in bytes.</span></span>
<span class="line" id="L23"><span class="tok-comment">/// If this byte does not match the form of a UTF-8 start byte, returns Utf8InvalidStartByte.</span></span>
<span class="line" id="L24"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">utf8ByteSequenceLength</span>(first_byte: <span class="tok-type">u8</span>) !<span class="tok-type">u3</span> {</span>
<span class="line" id="L25">    <span class="tok-comment">// The switch is optimized much better than a &quot;smart&quot; approach using @clz</span>
</span>
<span class="line" id="L26">    <span class="tok-kw">return</span> <span class="tok-kw">switch</span> (first_byte) {</span>
<span class="line" id="L27">        <span class="tok-number">0b0000_0000</span>...<span class="tok-number">0b0111_1111</span> =&gt; <span class="tok-number">1</span>,</span>
<span class="line" id="L28">        <span class="tok-number">0b1100_0000</span>...<span class="tok-number">0b1101_1111</span> =&gt; <span class="tok-number">2</span>,</span>
<span class="line" id="L29">        <span class="tok-number">0b1110_0000</span>...<span class="tok-number">0b1110_1111</span> =&gt; <span class="tok-number">3</span>,</span>
<span class="line" id="L30">        <span class="tok-number">0b1111_0000</span>...<span class="tok-number">0b1111_0111</span> =&gt; <span class="tok-number">4</span>,</span>
<span class="line" id="L31">        <span class="tok-kw">else</span> =&gt; <span class="tok-kw">error</span>.Utf8InvalidStartByte,</span>
<span class="line" id="L32">    };</span>
<span class="line" id="L33">}</span>
<span class="line" id="L34"></span>
<span class="line" id="L35"><span class="tok-comment">/// Encodes the given codepoint into a UTF-8 byte sequence.</span></span>
<span class="line" id="L36"><span class="tok-comment">/// c: the codepoint.</span></span>
<span class="line" id="L37"><span class="tok-comment">/// out: the out buffer to write to. Must have a len &gt;= utf8CodepointSequenceLength(c).</span></span>
<span class="line" id="L38"><span class="tok-comment">/// Errors: if c cannot be encoded in UTF-8.</span></span>
<span class="line" id="L39"><span class="tok-comment">/// Returns: the number of bytes written to out.</span></span>
<span class="line" id="L40"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">utf8Encode</span>(c: <span class="tok-type">u21</span>, out: []<span class="tok-type">u8</span>) !<span class="tok-type">u3</span> {</span>
<span class="line" id="L41">    <span class="tok-kw">const</span> length = <span class="tok-kw">try</span> utf8CodepointSequenceLength(c);</span>
<span class="line" id="L42">    assert(out.len &gt;= length);</span>
<span class="line" id="L43">    <span class="tok-kw">switch</span> (length) {</span>
<span class="line" id="L44">        <span class="tok-comment">// The pattern for each is the same</span>
</span>
<span class="line" id="L45">        <span class="tok-comment">// - Increasing the initial shift by 6 each time</span>
</span>
<span class="line" id="L46">        <span class="tok-comment">// - Each time after the first shorten the shifted</span>
</span>
<span class="line" id="L47">        <span class="tok-comment">//   value to a max of 0b111111 (63)</span>
</span>
<span class="line" id="L48">        <span class="tok-number">1</span> =&gt; out[<span class="tok-number">0</span>] = <span class="tok-builtin">@intCast</span>(<span class="tok-type">u8</span>, c), <span class="tok-comment">// Can just do 0 + codepoint for initial range</span>
</span>
<span class="line" id="L49">        <span class="tok-number">2</span> =&gt; {</span>
<span class="line" id="L50">            out[<span class="tok-number">0</span>] = <span class="tok-builtin">@intCast</span>(<span class="tok-type">u8</span>, <span class="tok-number">0b11000000</span> | (c &gt;&gt; <span class="tok-number">6</span>));</span>
<span class="line" id="L51">            out[<span class="tok-number">1</span>] = <span class="tok-builtin">@intCast</span>(<span class="tok-type">u8</span>, <span class="tok-number">0b10000000</span> | (c &amp; <span class="tok-number">0b111111</span>));</span>
<span class="line" id="L52">        },</span>
<span class="line" id="L53">        <span class="tok-number">3</span> =&gt; {</span>
<span class="line" id="L54">            <span class="tok-kw">if</span> (<span class="tok-number">0xd800</span> &lt;= c <span class="tok-kw">and</span> c &lt;= <span class="tok-number">0xdfff</span>) <span class="tok-kw">return</span> <span class="tok-kw">error</span>.Utf8CannotEncodeSurrogateHalf;</span>
<span class="line" id="L55">            out[<span class="tok-number">0</span>] = <span class="tok-builtin">@intCast</span>(<span class="tok-type">u8</span>, <span class="tok-number">0b11100000</span> | (c &gt;&gt; <span class="tok-number">12</span>));</span>
<span class="line" id="L56">            out[<span class="tok-number">1</span>] = <span class="tok-builtin">@intCast</span>(<span class="tok-type">u8</span>, <span class="tok-number">0b10000000</span> | ((c &gt;&gt; <span class="tok-number">6</span>) &amp; <span class="tok-number">0b111111</span>));</span>
<span class="line" id="L57">            out[<span class="tok-number">2</span>] = <span class="tok-builtin">@intCast</span>(<span class="tok-type">u8</span>, <span class="tok-number">0b10000000</span> | (c &amp; <span class="tok-number">0b111111</span>));</span>
<span class="line" id="L58">        },</span>
<span class="line" id="L59">        <span class="tok-number">4</span> =&gt; {</span>
<span class="line" id="L60">            out[<span class="tok-number">0</span>] = <span class="tok-builtin">@intCast</span>(<span class="tok-type">u8</span>, <span class="tok-number">0b11110000</span> | (c &gt;&gt; <span class="tok-number">18</span>));</span>
<span class="line" id="L61">            out[<span class="tok-number">1</span>] = <span class="tok-builtin">@intCast</span>(<span class="tok-type">u8</span>, <span class="tok-number">0b10000000</span> | ((c &gt;&gt; <span class="tok-number">12</span>) &amp; <span class="tok-number">0b111111</span>));</span>
<span class="line" id="L62">            out[<span class="tok-number">2</span>] = <span class="tok-builtin">@intCast</span>(<span class="tok-type">u8</span>, <span class="tok-number">0b10000000</span> | ((c &gt;&gt; <span class="tok-number">6</span>) &amp; <span class="tok-number">0b111111</span>));</span>
<span class="line" id="L63">            out[<span class="tok-number">3</span>] = <span class="tok-builtin">@intCast</span>(<span class="tok-type">u8</span>, <span class="tok-number">0b10000000</span> | (c &amp; <span class="tok-number">0b111111</span>));</span>
<span class="line" id="L64">        },</span>
<span class="line" id="L65">        <span class="tok-kw">else</span> =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L66">    }</span>
<span class="line" id="L67">    <span class="tok-kw">return</span> length;</span>
<span class="line" id="L68">}</span>
<span class="line" id="L69"></span>
<span class="line" id="L70"><span class="tok-kw">const</span> Utf8DecodeError = Utf8Decode2Error || Utf8Decode3Error || Utf8Decode4Error;</span>
<span class="line" id="L71"></span>
<span class="line" id="L72"><span class="tok-comment">/// Decodes the UTF-8 codepoint encoded in the given slice of bytes.</span></span>
<span class="line" id="L73"><span class="tok-comment">/// bytes.len must be equal to utf8ByteSequenceLength(bytes[0]) catch unreachable.</span></span>
<span class="line" id="L74"><span class="tok-comment">/// If you already know the length at comptime, you can call one of</span></span>
<span class="line" id="L75"><span class="tok-comment">/// utf8Decode2,utf8Decode3,utf8Decode4 directly instead of this function.</span></span>
<span class="line" id="L76"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">utf8Decode</span>(bytes: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) Utf8DecodeError!<span class="tok-type">u21</span> {</span>
<span class="line" id="L77">    <span class="tok-kw">return</span> <span class="tok-kw">switch</span> (bytes.len) {</span>
<span class="line" id="L78">        <span class="tok-number">1</span> =&gt; <span class="tok-builtin">@as</span>(<span class="tok-type">u21</span>, bytes[<span class="tok-number">0</span>]),</span>
<span class="line" id="L79">        <span class="tok-number">2</span> =&gt; utf8Decode2(bytes),</span>
<span class="line" id="L80">        <span class="tok-number">3</span> =&gt; utf8Decode3(bytes),</span>
<span class="line" id="L81">        <span class="tok-number">4</span> =&gt; utf8Decode4(bytes),</span>
<span class="line" id="L82">        <span class="tok-kw">else</span> =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L83">    };</span>
<span class="line" id="L84">}</span>
<span class="line" id="L85"></span>
<span class="line" id="L86"><span class="tok-kw">const</span> Utf8Decode2Error = <span class="tok-kw">error</span>{</span>
<span class="line" id="L87">    Utf8ExpectedContinuation,</span>
<span class="line" id="L88">    Utf8OverlongEncoding,</span>
<span class="line" id="L89">};</span>
<span class="line" id="L90"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">utf8Decode2</span>(bytes: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) Utf8Decode2Error!<span class="tok-type">u21</span> {</span>
<span class="line" id="L91">    assert(bytes.len == <span class="tok-number">2</span>);</span>
<span class="line" id="L92">    assert(bytes[<span class="tok-number">0</span>] &amp; <span class="tok-number">0b11100000</span> == <span class="tok-number">0b11000000</span>);</span>
<span class="line" id="L93">    <span class="tok-kw">var</span> value: <span class="tok-type">u21</span> = bytes[<span class="tok-number">0</span>] &amp; <span class="tok-number">0b00011111</span>;</span>
<span class="line" id="L94"></span>
<span class="line" id="L95">    <span class="tok-kw">if</span> (bytes[<span class="tok-number">1</span>] &amp; <span class="tok-number">0b11000000</span> != <span class="tok-number">0b10000000</span>) <span class="tok-kw">return</span> <span class="tok-kw">error</span>.Utf8ExpectedContinuation;</span>
<span class="line" id="L96">    value &lt;&lt;= <span class="tok-number">6</span>;</span>
<span class="line" id="L97">    value |= bytes[<span class="tok-number">1</span>] &amp; <span class="tok-number">0b00111111</span>;</span>
<span class="line" id="L98"></span>
<span class="line" id="L99">    <span class="tok-kw">if</span> (value &lt; <span class="tok-number">0x80</span>) <span class="tok-kw">return</span> <span class="tok-kw">error</span>.Utf8OverlongEncoding;</span>
<span class="line" id="L100"></span>
<span class="line" id="L101">    <span class="tok-kw">return</span> value;</span>
<span class="line" id="L102">}</span>
<span class="line" id="L103"></span>
<span class="line" id="L104"><span class="tok-kw">const</span> Utf8Decode3Error = <span class="tok-kw">error</span>{</span>
<span class="line" id="L105">    Utf8ExpectedContinuation,</span>
<span class="line" id="L106">    Utf8OverlongEncoding,</span>
<span class="line" id="L107">    Utf8EncodesSurrogateHalf,</span>
<span class="line" id="L108">};</span>
<span class="line" id="L109"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">utf8Decode3</span>(bytes: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) Utf8Decode3Error!<span class="tok-type">u21</span> {</span>
<span class="line" id="L110">    assert(bytes.len == <span class="tok-number">3</span>);</span>
<span class="line" id="L111">    assert(bytes[<span class="tok-number">0</span>] &amp; <span class="tok-number">0b11110000</span> == <span class="tok-number">0b11100000</span>);</span>
<span class="line" id="L112">    <span class="tok-kw">var</span> value: <span class="tok-type">u21</span> = bytes[<span class="tok-number">0</span>] &amp; <span class="tok-number">0b00001111</span>;</span>
<span class="line" id="L113"></span>
<span class="line" id="L114">    <span class="tok-kw">if</span> (bytes[<span class="tok-number">1</span>] &amp; <span class="tok-number">0b11000000</span> != <span class="tok-number">0b10000000</span>) <span class="tok-kw">return</span> <span class="tok-kw">error</span>.Utf8ExpectedContinuation;</span>
<span class="line" id="L115">    value &lt;&lt;= <span class="tok-number">6</span>;</span>
<span class="line" id="L116">    value |= bytes[<span class="tok-number">1</span>] &amp; <span class="tok-number">0b00111111</span>;</span>
<span class="line" id="L117"></span>
<span class="line" id="L118">    <span class="tok-kw">if</span> (bytes[<span class="tok-number">2</span>] &amp; <span class="tok-number">0b11000000</span> != <span class="tok-number">0b10000000</span>) <span class="tok-kw">return</span> <span class="tok-kw">error</span>.Utf8ExpectedContinuation;</span>
<span class="line" id="L119">    value &lt;&lt;= <span class="tok-number">6</span>;</span>
<span class="line" id="L120">    value |= bytes[<span class="tok-number">2</span>] &amp; <span class="tok-number">0b00111111</span>;</span>
<span class="line" id="L121"></span>
<span class="line" id="L122">    <span class="tok-kw">if</span> (value &lt; <span class="tok-number">0x800</span>) <span class="tok-kw">return</span> <span class="tok-kw">error</span>.Utf8OverlongEncoding;</span>
<span class="line" id="L123">    <span class="tok-kw">if</span> (<span class="tok-number">0xd800</span> &lt;= value <span class="tok-kw">and</span> value &lt;= <span class="tok-number">0xdfff</span>) <span class="tok-kw">return</span> <span class="tok-kw">error</span>.Utf8EncodesSurrogateHalf;</span>
<span class="line" id="L124"></span>
<span class="line" id="L125">    <span class="tok-kw">return</span> value;</span>
<span class="line" id="L126">}</span>
<span class="line" id="L127"></span>
<span class="line" id="L128"><span class="tok-kw">const</span> Utf8Decode4Error = <span class="tok-kw">error</span>{</span>
<span class="line" id="L129">    Utf8ExpectedContinuation,</span>
<span class="line" id="L130">    Utf8OverlongEncoding,</span>
<span class="line" id="L131">    Utf8CodepointTooLarge,</span>
<span class="line" id="L132">};</span>
<span class="line" id="L133"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">utf8Decode4</span>(bytes: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) Utf8Decode4Error!<span class="tok-type">u21</span> {</span>
<span class="line" id="L134">    assert(bytes.len == <span class="tok-number">4</span>);</span>
<span class="line" id="L135">    assert(bytes[<span class="tok-number">0</span>] &amp; <span class="tok-number">0b11111000</span> == <span class="tok-number">0b11110000</span>);</span>
<span class="line" id="L136">    <span class="tok-kw">var</span> value: <span class="tok-type">u21</span> = bytes[<span class="tok-number">0</span>] &amp; <span class="tok-number">0b00000111</span>;</span>
<span class="line" id="L137"></span>
<span class="line" id="L138">    <span class="tok-kw">if</span> (bytes[<span class="tok-number">1</span>] &amp; <span class="tok-number">0b11000000</span> != <span class="tok-number">0b10000000</span>) <span class="tok-kw">return</span> <span class="tok-kw">error</span>.Utf8ExpectedContinuation;</span>
<span class="line" id="L139">    value &lt;&lt;= <span class="tok-number">6</span>;</span>
<span class="line" id="L140">    value |= bytes[<span class="tok-number">1</span>] &amp; <span class="tok-number">0b00111111</span>;</span>
<span class="line" id="L141"></span>
<span class="line" id="L142">    <span class="tok-kw">if</span> (bytes[<span class="tok-number">2</span>] &amp; <span class="tok-number">0b11000000</span> != <span class="tok-number">0b10000000</span>) <span class="tok-kw">return</span> <span class="tok-kw">error</span>.Utf8ExpectedContinuation;</span>
<span class="line" id="L143">    value &lt;&lt;= <span class="tok-number">6</span>;</span>
<span class="line" id="L144">    value |= bytes[<span class="tok-number">2</span>] &amp; <span class="tok-number">0b00111111</span>;</span>
<span class="line" id="L145"></span>
<span class="line" id="L146">    <span class="tok-kw">if</span> (bytes[<span class="tok-number">3</span>] &amp; <span class="tok-number">0b11000000</span> != <span class="tok-number">0b10000000</span>) <span class="tok-kw">return</span> <span class="tok-kw">error</span>.Utf8ExpectedContinuation;</span>
<span class="line" id="L147">    value &lt;&lt;= <span class="tok-number">6</span>;</span>
<span class="line" id="L148">    value |= bytes[<span class="tok-number">3</span>] &amp; <span class="tok-number">0b00111111</span>;</span>
<span class="line" id="L149"></span>
<span class="line" id="L150">    <span class="tok-kw">if</span> (value &lt; <span class="tok-number">0x10000</span>) <span class="tok-kw">return</span> <span class="tok-kw">error</span>.Utf8OverlongEncoding;</span>
<span class="line" id="L151">    <span class="tok-kw">if</span> (value &gt; <span class="tok-number">0x10FFFF</span>) <span class="tok-kw">return</span> <span class="tok-kw">error</span>.Utf8CodepointTooLarge;</span>
<span class="line" id="L152"></span>
<span class="line" id="L153">    <span class="tok-kw">return</span> value;</span>
<span class="line" id="L154">}</span>
<span class="line" id="L155"></span>
<span class="line" id="L156"><span class="tok-comment">/// Returns true if the given unicode codepoint can be encoded in UTF-8.</span></span>
<span class="line" id="L157"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">utf8ValidCodepoint</span>(value: <span class="tok-type">u21</span>) <span class="tok-type">bool</span> {</span>
<span class="line" id="L158">    <span class="tok-kw">return</span> <span class="tok-kw">switch</span> (value) {</span>
<span class="line" id="L159">        <span class="tok-number">0xD800</span>...<span class="tok-number">0xDFFF</span> =&gt; <span class="tok-null">false</span>, <span class="tok-comment">// Surrogates range</span>
</span>
<span class="line" id="L160">        <span class="tok-number">0x110000</span>...<span class="tok-number">0x1FFFFF</span> =&gt; <span class="tok-null">false</span>, <span class="tok-comment">// Above the maximum codepoint value</span>
</span>
<span class="line" id="L161">        <span class="tok-kw">else</span> =&gt; <span class="tok-null">true</span>,</span>
<span class="line" id="L162">    };</span>
<span class="line" id="L163">}</span>
<span class="line" id="L164"></span>
<span class="line" id="L165"><span class="tok-comment">/// Returns the length of a supplied UTF-8 string literal in terms of unicode</span></span>
<span class="line" id="L166"><span class="tok-comment">/// codepoints.</span></span>
<span class="line" id="L167"><span class="tok-comment">/// Asserts that the data is valid UTF-8.</span></span>
<span class="line" id="L168"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">utf8CountCodepoints</span>(s: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) !<span class="tok-type">usize</span> {</span>
<span class="line" id="L169">    <span class="tok-kw">var</span> len: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L170"></span>
<span class="line" id="L171">    <span class="tok-kw">const</span> N = <span class="tok-builtin">@sizeOf</span>(<span class="tok-type">usize</span>);</span>
<span class="line" id="L172">    <span class="tok-kw">const</span> MASK = <span class="tok-number">0x80</span> * (std.math.maxInt(<span class="tok-type">usize</span>) / <span class="tok-number">0xff</span>);</span>
<span class="line" id="L173"></span>
<span class="line" id="L174">    <span class="tok-kw">var</span> i: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L175">    <span class="tok-kw">while</span> (i &lt; s.len) {</span>
<span class="line" id="L176">        <span class="tok-comment">// Fast path for ASCII sequences</span>
</span>
<span class="line" id="L177">        <span class="tok-kw">while</span> (i + N &lt;= s.len) : (i += N) {</span>
<span class="line" id="L178">            <span class="tok-kw">const</span> v = mem.readIntNative(<span class="tok-type">usize</span>, s[i..][<span class="tok-number">0</span>..N]);</span>
<span class="line" id="L179">            <span class="tok-kw">if</span> (v &amp; MASK != <span class="tok-number">0</span>) <span class="tok-kw">break</span>;</span>
<span class="line" id="L180">            len += N;</span>
<span class="line" id="L181">        }</span>
<span class="line" id="L182"></span>
<span class="line" id="L183">        <span class="tok-kw">if</span> (i &lt; s.len) {</span>
<span class="line" id="L184">            <span class="tok-kw">const</span> n = <span class="tok-kw">try</span> utf8ByteSequenceLength(s[i]);</span>
<span class="line" id="L185">            <span class="tok-kw">if</span> (i + n &gt; s.len) <span class="tok-kw">return</span> <span class="tok-kw">error</span>.TruncatedInput;</span>
<span class="line" id="L186"></span>
<span class="line" id="L187">            <span class="tok-kw">switch</span> (n) {</span>
<span class="line" id="L188">                <span class="tok-number">1</span> =&gt; {}, <span class="tok-comment">// ASCII, no validation needed</span>
</span>
<span class="line" id="L189">                <span class="tok-kw">else</span> =&gt; _ = <span class="tok-kw">try</span> utf8Decode(s[i .. i + n]),</span>
<span class="line" id="L190">            }</span>
<span class="line" id="L191"></span>
<span class="line" id="L192">            i += n;</span>
<span class="line" id="L193">            len += <span class="tok-number">1</span>;</span>
<span class="line" id="L194">        }</span>
<span class="line" id="L195">    }</span>
<span class="line" id="L196"></span>
<span class="line" id="L197">    <span class="tok-kw">return</span> len;</span>
<span class="line" id="L198">}</span>
<span class="line" id="L199"></span>
<span class="line" id="L200"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">utf8ValidateSlice</span>(s: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) <span class="tok-type">bool</span> {</span>
<span class="line" id="L201">    <span class="tok-kw">var</span> i: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L202">    <span class="tok-kw">while</span> (i &lt; s.len) {</span>
<span class="line" id="L203">        <span class="tok-kw">if</span> (utf8ByteSequenceLength(s[i])) |cp_len| {</span>
<span class="line" id="L204">            <span class="tok-kw">if</span> (i + cp_len &gt; s.len) {</span>
<span class="line" id="L205">                <span class="tok-kw">return</span> <span class="tok-null">false</span>;</span>
<span class="line" id="L206">            }</span>
<span class="line" id="L207"></span>
<span class="line" id="L208">            <span class="tok-kw">if</span> (std.meta.isError(utf8Decode(s[i .. i + cp_len]))) {</span>
<span class="line" id="L209">                <span class="tok-kw">return</span> <span class="tok-null">false</span>;</span>
<span class="line" id="L210">            }</span>
<span class="line" id="L211">            i += cp_len;</span>
<span class="line" id="L212">        } <span class="tok-kw">else</span> |_| {</span>
<span class="line" id="L213">            <span class="tok-kw">return</span> <span class="tok-null">false</span>;</span>
<span class="line" id="L214">        }</span>
<span class="line" id="L215">    }</span>
<span class="line" id="L216">    <span class="tok-kw">return</span> <span class="tok-null">true</span>;</span>
<span class="line" id="L217">}</span>
<span class="line" id="L218"></span>
<span class="line" id="L219"><span class="tok-comment">/// Utf8View iterates the code points of a utf-8 encoded string.</span></span>
<span class="line" id="L220"><span class="tok-comment">///</span></span>
<span class="line" id="L221"><span class="tok-comment">/// ```</span></span>
<span class="line" id="L222"><span class="tok-comment">/// var utf8 = (try std.unicode.Utf8View.init(&quot;hi there&quot;)).iterator();</span></span>
<span class="line" id="L223"><span class="tok-comment">/// while (utf8.nextCodepointSlice()) |codepoint| {</span></span>
<span class="line" id="L224"><span class="tok-comment">///   std.debug.print(&quot;got codepoint {}\n&quot;, .{codepoint});</span></span>
<span class="line" id="L225"><span class="tok-comment">/// }</span></span>
<span class="line" id="L226"><span class="tok-comment">/// ```</span></span>
<span class="line" id="L227"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> Utf8View = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L228">    bytes: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>,</span>
<span class="line" id="L229"></span>
<span class="line" id="L230">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">init</span>(s: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) !Utf8View {</span>
<span class="line" id="L231">        <span class="tok-kw">if</span> (!utf8ValidateSlice(s)) {</span>
<span class="line" id="L232">            <span class="tok-kw">return</span> <span class="tok-kw">error</span>.InvalidUtf8;</span>
<span class="line" id="L233">        }</span>
<span class="line" id="L234"></span>
<span class="line" id="L235">        <span class="tok-kw">return</span> initUnchecked(s);</span>
<span class="line" id="L236">    }</span>
<span class="line" id="L237"></span>
<span class="line" id="L238">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">initUnchecked</span>(s: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) Utf8View {</span>
<span class="line" id="L239">        <span class="tok-kw">return</span> Utf8View{ .bytes = s };</span>
<span class="line" id="L240">    }</span>
<span class="line" id="L241"></span>
<span class="line" id="L242">    <span class="tok-comment">/// TODO: https://github.com/ziglang/zig/issues/425</span></span>
<span class="line" id="L243">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">initComptime</span>(<span class="tok-kw">comptime</span> s: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) Utf8View {</span>
<span class="line" id="L244">        <span class="tok-kw">if</span> (<span class="tok-kw">comptime</span> init(s)) |r| {</span>
<span class="line" id="L245">            <span class="tok-kw">return</span> r;</span>
<span class="line" id="L246">        } <span class="tok-kw">else</span> |err| <span class="tok-kw">switch</span> (err) {</span>
<span class="line" id="L247">            <span class="tok-kw">error</span>.InvalidUtf8 =&gt; {</span>
<span class="line" id="L248">                <span class="tok-builtin">@compileError</span>(<span class="tok-str">&quot;invalid utf8&quot;</span>);</span>
<span class="line" id="L249">            },</span>
<span class="line" id="L250">        }</span>
<span class="line" id="L251">    }</span>
<span class="line" id="L252"></span>
<span class="line" id="L253">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">iterator</span>(s: Utf8View) Utf8Iterator {</span>
<span class="line" id="L254">        <span class="tok-kw">return</span> Utf8Iterator{</span>
<span class="line" id="L255">            .bytes = s.bytes,</span>
<span class="line" id="L256">            .i = <span class="tok-number">0</span>,</span>
<span class="line" id="L257">        };</span>
<span class="line" id="L258">    }</span>
<span class="line" id="L259">};</span>
<span class="line" id="L260"></span>
<span class="line" id="L261"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> Utf8Iterator = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L262">    bytes: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>,</span>
<span class="line" id="L263">    i: <span class="tok-type">usize</span>,</span>
<span class="line" id="L264"></span>
<span class="line" id="L265">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">nextCodepointSlice</span>(it: *Utf8Iterator) ?[]<span class="tok-kw">const</span> <span class="tok-type">u8</span> {</span>
<span class="line" id="L266">        <span class="tok-kw">if</span> (it.i &gt;= it.bytes.len) {</span>
<span class="line" id="L267">            <span class="tok-kw">return</span> <span class="tok-null">null</span>;</span>
<span class="line" id="L268">        }</span>
<span class="line" id="L269"></span>
<span class="line" id="L270">        <span class="tok-kw">const</span> cp_len = utf8ByteSequenceLength(it.bytes[it.i]) <span class="tok-kw">catch</span> <span class="tok-kw">unreachable</span>;</span>
<span class="line" id="L271">        it.i += cp_len;</span>
<span class="line" id="L272">        <span class="tok-kw">return</span> it.bytes[it.i - cp_len .. it.i];</span>
<span class="line" id="L273">    }</span>
<span class="line" id="L274"></span>
<span class="line" id="L275">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">nextCodepoint</span>(it: *Utf8Iterator) ?<span class="tok-type">u21</span> {</span>
<span class="line" id="L276">        <span class="tok-kw">const</span> slice = it.nextCodepointSlice() <span class="tok-kw">orelse</span> <span class="tok-kw">return</span> <span class="tok-null">null</span>;</span>
<span class="line" id="L277">        <span class="tok-kw">return</span> utf8Decode(slice) <span class="tok-kw">catch</span> <span class="tok-kw">unreachable</span>;</span>
<span class="line" id="L278">    }</span>
<span class="line" id="L279"></span>
<span class="line" id="L280">    <span class="tok-comment">/// Look ahead at the next n codepoints without advancing the iterator.</span></span>
<span class="line" id="L281">    <span class="tok-comment">/// If fewer than n codepoints are available, then return the remainder of the string.</span></span>
<span class="line" id="L282">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">peek</span>(it: *Utf8Iterator, n: <span class="tok-type">usize</span>) []<span class="tok-kw">const</span> <span class="tok-type">u8</span> {</span>
<span class="line" id="L283">        <span class="tok-kw">const</span> original_i = it.i;</span>
<span class="line" id="L284">        <span class="tok-kw">defer</span> it.i = original_i;</span>
<span class="line" id="L285"></span>
<span class="line" id="L286">        <span class="tok-kw">var</span> end_ix = original_i;</span>
<span class="line" id="L287">        <span class="tok-kw">var</span> found: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L288">        <span class="tok-kw">while</span> (found &lt; n) : (found += <span class="tok-number">1</span>) {</span>
<span class="line" id="L289">            <span class="tok-kw">const</span> next_codepoint = it.nextCodepointSlice() <span class="tok-kw">orelse</span> <span class="tok-kw">return</span> it.bytes[original_i..];</span>
<span class="line" id="L290">            end_ix += next_codepoint.len;</span>
<span class="line" id="L291">        }</span>
<span class="line" id="L292"></span>
<span class="line" id="L293">        <span class="tok-kw">return</span> it.bytes[original_i..end_ix];</span>
<span class="line" id="L294">    }</span>
<span class="line" id="L295">};</span>
<span class="line" id="L296"></span>
<span class="line" id="L297"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> Utf16LeIterator = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L298">    bytes: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>,</span>
<span class="line" id="L299">    i: <span class="tok-type">usize</span>,</span>
<span class="line" id="L300"></span>
<span class="line" id="L301">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">init</span>(s: []<span class="tok-kw">const</span> <span class="tok-type">u16</span>) Utf16LeIterator {</span>
<span class="line" id="L302">        <span class="tok-kw">return</span> Utf16LeIterator{</span>
<span class="line" id="L303">            .bytes = mem.sliceAsBytes(s),</span>
<span class="line" id="L304">            .i = <span class="tok-number">0</span>,</span>
<span class="line" id="L305">        };</span>
<span class="line" id="L306">    }</span>
<span class="line" id="L307"></span>
<span class="line" id="L308">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">nextCodepoint</span>(it: *Utf16LeIterator) !?<span class="tok-type">u21</span> {</span>
<span class="line" id="L309">        assert(it.i &lt;= it.bytes.len);</span>
<span class="line" id="L310">        <span class="tok-kw">if</span> (it.i == it.bytes.len) <span class="tok-kw">return</span> <span class="tok-null">null</span>;</span>
<span class="line" id="L311">        <span class="tok-kw">const</span> c0: <span class="tok-type">u21</span> = mem.readIntLittle(<span class="tok-type">u16</span>, it.bytes[it.i..][<span class="tok-number">0</span>..<span class="tok-number">2</span>]);</span>
<span class="line" id="L312">        it.i += <span class="tok-number">2</span>;</span>
<span class="line" id="L313">        <span class="tok-kw">if</span> (c0 &amp; ~<span class="tok-builtin">@as</span>(<span class="tok-type">u21</span>, <span class="tok-number">0x03ff</span>) == <span class="tok-number">0xd800</span>) {</span>
<span class="line" id="L314">            <span class="tok-comment">// surrogate pair</span>
</span>
<span class="line" id="L315">            <span class="tok-kw">if</span> (it.i &gt;= it.bytes.len) <span class="tok-kw">return</span> <span class="tok-kw">error</span>.DanglingSurrogateHalf;</span>
<span class="line" id="L316">            <span class="tok-kw">const</span> c1: <span class="tok-type">u21</span> = mem.readIntLittle(<span class="tok-type">u16</span>, it.bytes[it.i..][<span class="tok-number">0</span>..<span class="tok-number">2</span>]);</span>
<span class="line" id="L317">            <span class="tok-kw">if</span> (c1 &amp; ~<span class="tok-builtin">@as</span>(<span class="tok-type">u21</span>, <span class="tok-number">0x03ff</span>) != <span class="tok-number">0xdc00</span>) <span class="tok-kw">return</span> <span class="tok-kw">error</span>.ExpectedSecondSurrogateHalf;</span>
<span class="line" id="L318">            it.i += <span class="tok-number">2</span>;</span>
<span class="line" id="L319">            <span class="tok-kw">return</span> <span class="tok-number">0x10000</span> + (((c0 &amp; <span class="tok-number">0x03ff</span>) &lt;&lt; <span class="tok-number">10</span>) | (c1 &amp; <span class="tok-number">0x03ff</span>));</span>
<span class="line" id="L320">        } <span class="tok-kw">else</span> <span class="tok-kw">if</span> (c0 &amp; ~<span class="tok-builtin">@as</span>(<span class="tok-type">u21</span>, <span class="tok-number">0x03ff</span>) == <span class="tok-number">0xdc00</span>) {</span>
<span class="line" id="L321">            <span class="tok-kw">return</span> <span class="tok-kw">error</span>.UnexpectedSecondSurrogateHalf;</span>
<span class="line" id="L322">        } <span class="tok-kw">else</span> {</span>
<span class="line" id="L323">            <span class="tok-kw">return</span> c0;</span>
<span class="line" id="L324">        }</span>
<span class="line" id="L325">    }</span>
<span class="line" id="L326">};</span>
<span class="line" id="L327"></span>
<span class="line" id="L328"><span class="tok-kw">test</span> <span class="tok-str">&quot;utf8 encode&quot;</span> {</span>
<span class="line" id="L329">    <span class="tok-kw">comptime</span> <span class="tok-kw">try</span> testUtf8Encode();</span>
<span class="line" id="L330">    <span class="tok-kw">try</span> testUtf8Encode();</span>
<span class="line" id="L331">}</span>
<span class="line" id="L332"><span class="tok-kw">fn</span> <span class="tok-fn">testUtf8Encode</span>() !<span class="tok-type">void</span> {</span>
<span class="line" id="L333">    <span class="tok-comment">// A few taken from wikipedia a few taken elsewhere</span>
</span>
<span class="line" id="L334">    <span class="tok-kw">var</span> array: [<span class="tok-number">4</span>]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L335">    <span class="tok-kw">try</span> testing.expect((<span class="tok-kw">try</span> utf8Encode(<span class="tok-kw">try</span> utf8Decode(<span class="tok-str">&quot;€&quot;</span>), array[<span class="tok-number">0</span>..])) == <span class="tok-number">3</span>);</span>
<span class="line" id="L336">    <span class="tok-kw">try</span> testing.expect(array[<span class="tok-number">0</span>] == <span class="tok-number">0b11100010</span>);</span>
<span class="line" id="L337">    <span class="tok-kw">try</span> testing.expect(array[<span class="tok-number">1</span>] == <span class="tok-number">0b10000010</span>);</span>
<span class="line" id="L338">    <span class="tok-kw">try</span> testing.expect(array[<span class="tok-number">2</span>] == <span class="tok-number">0b10101100</span>);</span>
<span class="line" id="L339"></span>
<span class="line" id="L340">    <span class="tok-kw">try</span> testing.expect((<span class="tok-kw">try</span> utf8Encode(<span class="tok-kw">try</span> utf8Decode(<span class="tok-str">&quot;$&quot;</span>), array[<span class="tok-number">0</span>..])) == <span class="tok-number">1</span>);</span>
<span class="line" id="L341">    <span class="tok-kw">try</span> testing.expect(array[<span class="tok-number">0</span>] == <span class="tok-number">0b00100100</span>);</span>
<span class="line" id="L342"></span>
<span class="line" id="L343">    <span class="tok-kw">try</span> testing.expect((<span class="tok-kw">try</span> utf8Encode(<span class="tok-kw">try</span> utf8Decode(<span class="tok-str">&quot;¢&quot;</span>), array[<span class="tok-number">0</span>..])) == <span class="tok-number">2</span>);</span>
<span class="line" id="L344">    <span class="tok-kw">try</span> testing.expect(array[<span class="tok-number">0</span>] == <span class="tok-number">0b11000010</span>);</span>
<span class="line" id="L345">    <span class="tok-kw">try</span> testing.expect(array[<span class="tok-number">1</span>] == <span class="tok-number">0b10100010</span>);</span>
<span class="line" id="L346"></span>
<span class="line" id="L347">    <span class="tok-kw">try</span> testing.expect((<span class="tok-kw">try</span> utf8Encode(<span class="tok-kw">try</span> utf8Decode(<span class="tok-str">&quot;𐍈&quot;</span>), array[<span class="tok-number">0</span>..])) == <span class="tok-number">4</span>);</span>
<span class="line" id="L348">    <span class="tok-kw">try</span> testing.expect(array[<span class="tok-number">0</span>] == <span class="tok-number">0b11110000</span>);</span>
<span class="line" id="L349">    <span class="tok-kw">try</span> testing.expect(array[<span class="tok-number">1</span>] == <span class="tok-number">0b10010000</span>);</span>
<span class="line" id="L350">    <span class="tok-kw">try</span> testing.expect(array[<span class="tok-number">2</span>] == <span class="tok-number">0b10001101</span>);</span>
<span class="line" id="L351">    <span class="tok-kw">try</span> testing.expect(array[<span class="tok-number">3</span>] == <span class="tok-number">0b10001000</span>);</span>
<span class="line" id="L352">}</span>
<span class="line" id="L353"></span>
<span class="line" id="L354"><span class="tok-kw">test</span> <span class="tok-str">&quot;utf8 encode error&quot;</span> {</span>
<span class="line" id="L355">    <span class="tok-kw">comptime</span> <span class="tok-kw">try</span> testUtf8EncodeError();</span>
<span class="line" id="L356">    <span class="tok-kw">try</span> testUtf8EncodeError();</span>
<span class="line" id="L357">}</span>
<span class="line" id="L358"><span class="tok-kw">fn</span> <span class="tok-fn">testUtf8EncodeError</span>() !<span class="tok-type">void</span> {</span>
<span class="line" id="L359">    <span class="tok-kw">var</span> array: [<span class="tok-number">4</span>]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L360">    <span class="tok-kw">try</span> testErrorEncode(<span class="tok-number">0xd800</span>, array[<span class="tok-number">0</span>..], <span class="tok-kw">error</span>.Utf8CannotEncodeSurrogateHalf);</span>
<span class="line" id="L361">    <span class="tok-kw">try</span> testErrorEncode(<span class="tok-number">0xdfff</span>, array[<span class="tok-number">0</span>..], <span class="tok-kw">error</span>.Utf8CannotEncodeSurrogateHalf);</span>
<span class="line" id="L362">    <span class="tok-kw">try</span> testErrorEncode(<span class="tok-number">0x110000</span>, array[<span class="tok-number">0</span>..], <span class="tok-kw">error</span>.CodepointTooLarge);</span>
<span class="line" id="L363">    <span class="tok-kw">try</span> testErrorEncode(<span class="tok-number">0x1fffff</span>, array[<span class="tok-number">0</span>..], <span class="tok-kw">error</span>.CodepointTooLarge);</span>
<span class="line" id="L364">}</span>
<span class="line" id="L365"></span>
<span class="line" id="L366"><span class="tok-kw">fn</span> <span class="tok-fn">testErrorEncode</span>(codePoint: <span class="tok-type">u21</span>, array: []<span class="tok-type">u8</span>, expectedErr: <span class="tok-type">anyerror</span>) !<span class="tok-type">void</span> {</span>
<span class="line" id="L367">    <span class="tok-kw">try</span> testing.expectError(expectedErr, utf8Encode(codePoint, array));</span>
<span class="line" id="L368">}</span>
<span class="line" id="L369"></span>
<span class="line" id="L370"><span class="tok-kw">test</span> <span class="tok-str">&quot;utf8 iterator on ascii&quot;</span> {</span>
<span class="line" id="L371">    <span class="tok-kw">comptime</span> <span class="tok-kw">try</span> testUtf8IteratorOnAscii();</span>
<span class="line" id="L372">    <span class="tok-kw">try</span> testUtf8IteratorOnAscii();</span>
<span class="line" id="L373">}</span>
<span class="line" id="L374"><span class="tok-kw">fn</span> <span class="tok-fn">testUtf8IteratorOnAscii</span>() !<span class="tok-type">void</span> {</span>
<span class="line" id="L375">    <span class="tok-kw">const</span> s = Utf8View.initComptime(<span class="tok-str">&quot;abc&quot;</span>);</span>
<span class="line" id="L376"></span>
<span class="line" id="L377">    <span class="tok-kw">var</span> it1 = s.iterator();</span>
<span class="line" id="L378">    <span class="tok-kw">try</span> testing.expect(std.mem.eql(<span class="tok-type">u8</span>, <span class="tok-str">&quot;a&quot;</span>, it1.nextCodepointSlice().?));</span>
<span class="line" id="L379">    <span class="tok-kw">try</span> testing.expect(std.mem.eql(<span class="tok-type">u8</span>, <span class="tok-str">&quot;b&quot;</span>, it1.nextCodepointSlice().?));</span>
<span class="line" id="L380">    <span class="tok-kw">try</span> testing.expect(std.mem.eql(<span class="tok-type">u8</span>, <span class="tok-str">&quot;c&quot;</span>, it1.nextCodepointSlice().?));</span>
<span class="line" id="L381">    <span class="tok-kw">try</span> testing.expect(it1.nextCodepointSlice() == <span class="tok-null">null</span>);</span>
<span class="line" id="L382"></span>
<span class="line" id="L383">    <span class="tok-kw">var</span> it2 = s.iterator();</span>
<span class="line" id="L384">    <span class="tok-kw">try</span> testing.expect(it2.nextCodepoint().? == <span class="tok-str">'a'</span>);</span>
<span class="line" id="L385">    <span class="tok-kw">try</span> testing.expect(it2.nextCodepoint().? == <span class="tok-str">'b'</span>);</span>
<span class="line" id="L386">    <span class="tok-kw">try</span> testing.expect(it2.nextCodepoint().? == <span class="tok-str">'c'</span>);</span>
<span class="line" id="L387">    <span class="tok-kw">try</span> testing.expect(it2.nextCodepoint() == <span class="tok-null">null</span>);</span>
<span class="line" id="L388">}</span>
<span class="line" id="L389"></span>
<span class="line" id="L390"><span class="tok-kw">test</span> <span class="tok-str">&quot;utf8 view bad&quot;</span> {</span>
<span class="line" id="L391">    <span class="tok-kw">comptime</span> <span class="tok-kw">try</span> testUtf8ViewBad();</span>
<span class="line" id="L392">    <span class="tok-kw">try</span> testUtf8ViewBad();</span>
<span class="line" id="L393">}</span>
<span class="line" id="L394"><span class="tok-kw">fn</span> <span class="tok-fn">testUtf8ViewBad</span>() !<span class="tok-type">void</span> {</span>
<span class="line" id="L395">    <span class="tok-comment">// Compile-time error.</span>
</span>
<span class="line" id="L396">    <span class="tok-comment">// const s3 = Utf8View.initComptime(&quot;\xfe\xf2&quot;);</span>
</span>
<span class="line" id="L397">    <span class="tok-kw">try</span> testing.expectError(<span class="tok-kw">error</span>.InvalidUtf8, Utf8View.init(<span class="tok-str">&quot;hel\xadlo&quot;</span>));</span>
<span class="line" id="L398">}</span>
<span class="line" id="L399"></span>
<span class="line" id="L400"><span class="tok-kw">test</span> <span class="tok-str">&quot;utf8 view ok&quot;</span> {</span>
<span class="line" id="L401">    <span class="tok-kw">comptime</span> <span class="tok-kw">try</span> testUtf8ViewOk();</span>
<span class="line" id="L402">    <span class="tok-kw">try</span> testUtf8ViewOk();</span>
<span class="line" id="L403">}</span>
<span class="line" id="L404"><span class="tok-kw">fn</span> <span class="tok-fn">testUtf8ViewOk</span>() !<span class="tok-type">void</span> {</span>
<span class="line" id="L405">    <span class="tok-kw">const</span> s = Utf8View.initComptime(<span class="tok-str">&quot;東京市&quot;</span>);</span>
<span class="line" id="L406"></span>
<span class="line" id="L407">    <span class="tok-kw">var</span> it1 = s.iterator();</span>
<span class="line" id="L408">    <span class="tok-kw">try</span> testing.expect(std.mem.eql(<span class="tok-type">u8</span>, <span class="tok-str">&quot;東&quot;</span>, it1.nextCodepointSlice().?));</span>
<span class="line" id="L409">    <span class="tok-kw">try</span> testing.expect(std.mem.eql(<span class="tok-type">u8</span>, <span class="tok-str">&quot;京&quot;</span>, it1.nextCodepointSlice().?));</span>
<span class="line" id="L410">    <span class="tok-kw">try</span> testing.expect(std.mem.eql(<span class="tok-type">u8</span>, <span class="tok-str">&quot;市&quot;</span>, it1.nextCodepointSlice().?));</span>
<span class="line" id="L411">    <span class="tok-kw">try</span> testing.expect(it1.nextCodepointSlice() == <span class="tok-null">null</span>);</span>
<span class="line" id="L412"></span>
<span class="line" id="L413">    <span class="tok-kw">var</span> it2 = s.iterator();</span>
<span class="line" id="L414">    <span class="tok-kw">try</span> testing.expect(it2.nextCodepoint().? == <span class="tok-number">0x6771</span>);</span>
<span class="line" id="L415">    <span class="tok-kw">try</span> testing.expect(it2.nextCodepoint().? == <span class="tok-number">0x4eac</span>);</span>
<span class="line" id="L416">    <span class="tok-kw">try</span> testing.expect(it2.nextCodepoint().? == <span class="tok-number">0x5e02</span>);</span>
<span class="line" id="L417">    <span class="tok-kw">try</span> testing.expect(it2.nextCodepoint() == <span class="tok-null">null</span>);</span>
<span class="line" id="L418">}</span>
<span class="line" id="L419"></span>
<span class="line" id="L420"><span class="tok-kw">test</span> <span class="tok-str">&quot;bad utf8 slice&quot;</span> {</span>
<span class="line" id="L421">    <span class="tok-kw">comptime</span> <span class="tok-kw">try</span> testBadUtf8Slice();</span>
<span class="line" id="L422">    <span class="tok-kw">try</span> testBadUtf8Slice();</span>
<span class="line" id="L423">}</span>
<span class="line" id="L424"><span class="tok-kw">fn</span> <span class="tok-fn">testBadUtf8Slice</span>() !<span class="tok-type">void</span> {</span>
<span class="line" id="L425">    <span class="tok-kw">try</span> testing.expect(utf8ValidateSlice(<span class="tok-str">&quot;abc&quot;</span>));</span>
<span class="line" id="L426">    <span class="tok-kw">try</span> testing.expect(!utf8ValidateSlice(<span class="tok-str">&quot;abc\xc0&quot;</span>));</span>
<span class="line" id="L427">    <span class="tok-kw">try</span> testing.expect(!utf8ValidateSlice(<span class="tok-str">&quot;abc\xc0abc&quot;</span>));</span>
<span class="line" id="L428">    <span class="tok-kw">try</span> testing.expect(utf8ValidateSlice(<span class="tok-str">&quot;abc\xdf\xbf&quot;</span>));</span>
<span class="line" id="L429">}</span>
<span class="line" id="L430"></span>
<span class="line" id="L431"><span class="tok-kw">test</span> <span class="tok-str">&quot;valid utf8&quot;</span> {</span>
<span class="line" id="L432">    <span class="tok-kw">comptime</span> <span class="tok-kw">try</span> testValidUtf8();</span>
<span class="line" id="L433">    <span class="tok-kw">try</span> testValidUtf8();</span>
<span class="line" id="L434">}</span>
<span class="line" id="L435"><span class="tok-kw">fn</span> <span class="tok-fn">testValidUtf8</span>() !<span class="tok-type">void</span> {</span>
<span class="line" id="L436">    <span class="tok-kw">try</span> testValid(<span class="tok-str">&quot;\x00&quot;</span>, <span class="tok-number">0x0</span>);</span>
<span class="line" id="L437">    <span class="tok-kw">try</span> testValid(<span class="tok-str">&quot;\x20&quot;</span>, <span class="tok-number">0x20</span>);</span>
<span class="line" id="L438">    <span class="tok-kw">try</span> testValid(<span class="tok-str">&quot;\x7f&quot;</span>, <span class="tok-number">0x7f</span>);</span>
<span class="line" id="L439">    <span class="tok-kw">try</span> testValid(<span class="tok-str">&quot;\xc2\x80&quot;</span>, <span class="tok-number">0x80</span>);</span>
<span class="line" id="L440">    <span class="tok-kw">try</span> testValid(<span class="tok-str">&quot;\xdf\xbf&quot;</span>, <span class="tok-number">0x7ff</span>);</span>
<span class="line" id="L441">    <span class="tok-kw">try</span> testValid(<span class="tok-str">&quot;\xe0\xa0\x80&quot;</span>, <span class="tok-number">0x800</span>);</span>
<span class="line" id="L442">    <span class="tok-kw">try</span> testValid(<span class="tok-str">&quot;\xe1\x80\x80&quot;</span>, <span class="tok-number">0x1000</span>);</span>
<span class="line" id="L443">    <span class="tok-kw">try</span> testValid(<span class="tok-str">&quot;\xef\xbf\xbf&quot;</span>, <span class="tok-number">0xffff</span>);</span>
<span class="line" id="L444">    <span class="tok-kw">try</span> testValid(<span class="tok-str">&quot;\xf0\x90\x80\x80&quot;</span>, <span class="tok-number">0x10000</span>);</span>
<span class="line" id="L445">    <span class="tok-kw">try</span> testValid(<span class="tok-str">&quot;\xf1\x80\x80\x80&quot;</span>, <span class="tok-number">0x40000</span>);</span>
<span class="line" id="L446">    <span class="tok-kw">try</span> testValid(<span class="tok-str">&quot;\xf3\xbf\xbf\xbf&quot;</span>, <span class="tok-number">0xfffff</span>);</span>
<span class="line" id="L447">    <span class="tok-kw">try</span> testValid(<span class="tok-str">&quot;\xf4\x8f\xbf\xbf&quot;</span>, <span class="tok-number">0x10ffff</span>);</span>
<span class="line" id="L448">}</span>
<span class="line" id="L449"></span>
<span class="line" id="L450"><span class="tok-kw">test</span> <span class="tok-str">&quot;invalid utf8 continuation bytes&quot;</span> {</span>
<span class="line" id="L451">    <span class="tok-kw">comptime</span> <span class="tok-kw">try</span> testInvalidUtf8ContinuationBytes();</span>
<span class="line" id="L452">    <span class="tok-kw">try</span> testInvalidUtf8ContinuationBytes();</span>
<span class="line" id="L453">}</span>
<span class="line" id="L454"><span class="tok-kw">fn</span> <span class="tok-fn">testInvalidUtf8ContinuationBytes</span>() !<span class="tok-type">void</span> {</span>
<span class="line" id="L455">    <span class="tok-comment">// unexpected continuation</span>
</span>
<span class="line" id="L456">    <span class="tok-kw">try</span> testError(<span class="tok-str">&quot;\x80&quot;</span>, <span class="tok-kw">error</span>.Utf8InvalidStartByte);</span>
<span class="line" id="L457">    <span class="tok-kw">try</span> testError(<span class="tok-str">&quot;\xbf&quot;</span>, <span class="tok-kw">error</span>.Utf8InvalidStartByte);</span>
<span class="line" id="L458">    <span class="tok-comment">// too many leading 1's</span>
</span>
<span class="line" id="L459">    <span class="tok-kw">try</span> testError(<span class="tok-str">&quot;\xf8&quot;</span>, <span class="tok-kw">error</span>.Utf8InvalidStartByte);</span>
<span class="line" id="L460">    <span class="tok-kw">try</span> testError(<span class="tok-str">&quot;\xff&quot;</span>, <span class="tok-kw">error</span>.Utf8InvalidStartByte);</span>
<span class="line" id="L461">    <span class="tok-comment">// expected continuation for 2 byte sequences</span>
</span>
<span class="line" id="L462">    <span class="tok-kw">try</span> testError(<span class="tok-str">&quot;\xc2&quot;</span>, <span class="tok-kw">error</span>.UnexpectedEof);</span>
<span class="line" id="L463">    <span class="tok-kw">try</span> testError(<span class="tok-str">&quot;\xc2\x00&quot;</span>, <span class="tok-kw">error</span>.Utf8ExpectedContinuation);</span>
<span class="line" id="L464">    <span class="tok-kw">try</span> testError(<span class="tok-str">&quot;\xc2\xc0&quot;</span>, <span class="tok-kw">error</span>.Utf8ExpectedContinuation);</span>
<span class="line" id="L465">    <span class="tok-comment">// expected continuation for 3 byte sequences</span>
</span>
<span class="line" id="L466">    <span class="tok-kw">try</span> testError(<span class="tok-str">&quot;\xe0&quot;</span>, <span class="tok-kw">error</span>.UnexpectedEof);</span>
<span class="line" id="L467">    <span class="tok-kw">try</span> testError(<span class="tok-str">&quot;\xe0\x00&quot;</span>, <span class="tok-kw">error</span>.UnexpectedEof);</span>
<span class="line" id="L468">    <span class="tok-kw">try</span> testError(<span class="tok-str">&quot;\xe0\xc0&quot;</span>, <span class="tok-kw">error</span>.UnexpectedEof);</span>
<span class="line" id="L469">    <span class="tok-kw">try</span> testError(<span class="tok-str">&quot;\xe0\xa0&quot;</span>, <span class="tok-kw">error</span>.UnexpectedEof);</span>
<span class="line" id="L470">    <span class="tok-kw">try</span> testError(<span class="tok-str">&quot;\xe0\xa0\x00&quot;</span>, <span class="tok-kw">error</span>.Utf8ExpectedContinuation);</span>
<span class="line" id="L471">    <span class="tok-kw">try</span> testError(<span class="tok-str">&quot;\xe0\xa0\xc0&quot;</span>, <span class="tok-kw">error</span>.Utf8ExpectedContinuation);</span>
<span class="line" id="L472">    <span class="tok-comment">// expected continuation for 4 byte sequences</span>
</span>
<span class="line" id="L473">    <span class="tok-kw">try</span> testError(<span class="tok-str">&quot;\xf0&quot;</span>, <span class="tok-kw">error</span>.UnexpectedEof);</span>
<span class="line" id="L474">    <span class="tok-kw">try</span> testError(<span class="tok-str">&quot;\xf0\x00&quot;</span>, <span class="tok-kw">error</span>.UnexpectedEof);</span>
<span class="line" id="L475">    <span class="tok-kw">try</span> testError(<span class="tok-str">&quot;\xf0\xc0&quot;</span>, <span class="tok-kw">error</span>.UnexpectedEof);</span>
<span class="line" id="L476">    <span class="tok-kw">try</span> testError(<span class="tok-str">&quot;\xf0\x90\x00&quot;</span>, <span class="tok-kw">error</span>.UnexpectedEof);</span>
<span class="line" id="L477">    <span class="tok-kw">try</span> testError(<span class="tok-str">&quot;\xf0\x90\xc0&quot;</span>, <span class="tok-kw">error</span>.UnexpectedEof);</span>
<span class="line" id="L478">    <span class="tok-kw">try</span> testError(<span class="tok-str">&quot;\xf0\x90\x80\x00&quot;</span>, <span class="tok-kw">error</span>.Utf8ExpectedContinuation);</span>
<span class="line" id="L479">    <span class="tok-kw">try</span> testError(<span class="tok-str">&quot;\xf0\x90\x80\xc0&quot;</span>, <span class="tok-kw">error</span>.Utf8ExpectedContinuation);</span>
<span class="line" id="L480">}</span>
<span class="line" id="L481"></span>
<span class="line" id="L482"><span class="tok-kw">test</span> <span class="tok-str">&quot;overlong utf8 codepoint&quot;</span> {</span>
<span class="line" id="L483">    <span class="tok-kw">comptime</span> <span class="tok-kw">try</span> testOverlongUtf8Codepoint();</span>
<span class="line" id="L484">    <span class="tok-kw">try</span> testOverlongUtf8Codepoint();</span>
<span class="line" id="L485">}</span>
<span class="line" id="L486"><span class="tok-kw">fn</span> <span class="tok-fn">testOverlongUtf8Codepoint</span>() !<span class="tok-type">void</span> {</span>
<span class="line" id="L487">    <span class="tok-kw">try</span> testError(<span class="tok-str">&quot;\xc0\x80&quot;</span>, <span class="tok-kw">error</span>.Utf8OverlongEncoding);</span>
<span class="line" id="L488">    <span class="tok-kw">try</span> testError(<span class="tok-str">&quot;\xc1\xbf&quot;</span>, <span class="tok-kw">error</span>.Utf8OverlongEncoding);</span>
<span class="line" id="L489">    <span class="tok-kw">try</span> testError(<span class="tok-str">&quot;\xe0\x80\x80&quot;</span>, <span class="tok-kw">error</span>.Utf8OverlongEncoding);</span>
<span class="line" id="L490">    <span class="tok-kw">try</span> testError(<span class="tok-str">&quot;\xe0\x9f\xbf&quot;</span>, <span class="tok-kw">error</span>.Utf8OverlongEncoding);</span>
<span class="line" id="L491">    <span class="tok-kw">try</span> testError(<span class="tok-str">&quot;\xf0\x80\x80\x80&quot;</span>, <span class="tok-kw">error</span>.Utf8OverlongEncoding);</span>
<span class="line" id="L492">    <span class="tok-kw">try</span> testError(<span class="tok-str">&quot;\xf0\x8f\xbf\xbf&quot;</span>, <span class="tok-kw">error</span>.Utf8OverlongEncoding);</span>
<span class="line" id="L493">}</span>
<span class="line" id="L494"></span>
<span class="line" id="L495"><span class="tok-kw">test</span> <span class="tok-str">&quot;misc invalid utf8&quot;</span> {</span>
<span class="line" id="L496">    <span class="tok-kw">comptime</span> <span class="tok-kw">try</span> testMiscInvalidUtf8();</span>
<span class="line" id="L497">    <span class="tok-kw">try</span> testMiscInvalidUtf8();</span>
<span class="line" id="L498">}</span>
<span class="line" id="L499"><span class="tok-kw">fn</span> <span class="tok-fn">testMiscInvalidUtf8</span>() !<span class="tok-type">void</span> {</span>
<span class="line" id="L500">    <span class="tok-comment">// codepoint out of bounds</span>
</span>
<span class="line" id="L501">    <span class="tok-kw">try</span> testError(<span class="tok-str">&quot;\xf4\x90\x80\x80&quot;</span>, <span class="tok-kw">error</span>.Utf8CodepointTooLarge);</span>
<span class="line" id="L502">    <span class="tok-kw">try</span> testError(<span class="tok-str">&quot;\xf7\xbf\xbf\xbf&quot;</span>, <span class="tok-kw">error</span>.Utf8CodepointTooLarge);</span>
<span class="line" id="L503">    <span class="tok-comment">// surrogate halves</span>
</span>
<span class="line" id="L504">    <span class="tok-kw">try</span> testValid(<span class="tok-str">&quot;\xed\x9f\xbf&quot;</span>, <span class="tok-number">0xd7ff</span>);</span>
<span class="line" id="L505">    <span class="tok-kw">try</span> testError(<span class="tok-str">&quot;\xed\xa0\x80&quot;</span>, <span class="tok-kw">error</span>.Utf8EncodesSurrogateHalf);</span>
<span class="line" id="L506">    <span class="tok-kw">try</span> testError(<span class="tok-str">&quot;\xed\xbf\xbf&quot;</span>, <span class="tok-kw">error</span>.Utf8EncodesSurrogateHalf);</span>
<span class="line" id="L507">    <span class="tok-kw">try</span> testValid(<span class="tok-str">&quot;\xee\x80\x80&quot;</span>, <span class="tok-number">0xe000</span>);</span>
<span class="line" id="L508">}</span>
<span class="line" id="L509"></span>
<span class="line" id="L510"><span class="tok-kw">test</span> <span class="tok-str">&quot;utf8 iterator peeking&quot;</span> {</span>
<span class="line" id="L511">    <span class="tok-kw">comptime</span> <span class="tok-kw">try</span> testUtf8Peeking();</span>
<span class="line" id="L512">    <span class="tok-kw">try</span> testUtf8Peeking();</span>
<span class="line" id="L513">}</span>
<span class="line" id="L514"></span>
<span class="line" id="L515"><span class="tok-kw">fn</span> <span class="tok-fn">testUtf8Peeking</span>() !<span class="tok-type">void</span> {</span>
<span class="line" id="L516">    <span class="tok-kw">const</span> s = Utf8View.initComptime(<span class="tok-str">&quot;noël&quot;</span>);</span>
<span class="line" id="L517">    <span class="tok-kw">var</span> it = s.iterator();</span>
<span class="line" id="L518"></span>
<span class="line" id="L519">    <span class="tok-kw">try</span> testing.expect(std.mem.eql(<span class="tok-type">u8</span>, <span class="tok-str">&quot;n&quot;</span>, it.nextCodepointSlice().?));</span>
<span class="line" id="L520"></span>
<span class="line" id="L521">    <span class="tok-kw">try</span> testing.expect(std.mem.eql(<span class="tok-type">u8</span>, <span class="tok-str">&quot;o&quot;</span>, it.peek(<span class="tok-number">1</span>)));</span>
<span class="line" id="L522">    <span class="tok-kw">try</span> testing.expect(std.mem.eql(<span class="tok-type">u8</span>, <span class="tok-str">&quot;oë&quot;</span>, it.peek(<span class="tok-number">2</span>)));</span>
<span class="line" id="L523">    <span class="tok-kw">try</span> testing.expect(std.mem.eql(<span class="tok-type">u8</span>, <span class="tok-str">&quot;oël&quot;</span>, it.peek(<span class="tok-number">3</span>)));</span>
<span class="line" id="L524">    <span class="tok-kw">try</span> testing.expect(std.mem.eql(<span class="tok-type">u8</span>, <span class="tok-str">&quot;oël&quot;</span>, it.peek(<span class="tok-number">4</span>)));</span>
<span class="line" id="L525">    <span class="tok-kw">try</span> testing.expect(std.mem.eql(<span class="tok-type">u8</span>, <span class="tok-str">&quot;oël&quot;</span>, it.peek(<span class="tok-number">10</span>)));</span>
<span class="line" id="L526"></span>
<span class="line" id="L527">    <span class="tok-kw">try</span> testing.expect(std.mem.eql(<span class="tok-type">u8</span>, <span class="tok-str">&quot;o&quot;</span>, it.nextCodepointSlice().?));</span>
<span class="line" id="L528">    <span class="tok-kw">try</span> testing.expect(std.mem.eql(<span class="tok-type">u8</span>, <span class="tok-str">&quot;ë&quot;</span>, it.nextCodepointSlice().?));</span>
<span class="line" id="L529">    <span class="tok-kw">try</span> testing.expect(std.mem.eql(<span class="tok-type">u8</span>, <span class="tok-str">&quot;l&quot;</span>, it.nextCodepointSlice().?));</span>
<span class="line" id="L530">    <span class="tok-kw">try</span> testing.expect(it.nextCodepointSlice() == <span class="tok-null">null</span>);</span>
<span class="line" id="L531"></span>
<span class="line" id="L532">    <span class="tok-kw">try</span> testing.expect(std.mem.eql(<span class="tok-type">u8</span>, &amp;[_]<span class="tok-type">u8</span>{}, it.peek(<span class="tok-number">1</span>)));</span>
<span class="line" id="L533">}</span>
<span class="line" id="L534"></span>
<span class="line" id="L535"><span class="tok-kw">fn</span> <span class="tok-fn">testError</span>(bytes: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>, expected_err: <span class="tok-type">anyerror</span>) !<span class="tok-type">void</span> {</span>
<span class="line" id="L536">    <span class="tok-kw">try</span> testing.expectError(expected_err, testDecode(bytes));</span>
<span class="line" id="L537">}</span>
<span class="line" id="L538"></span>
<span class="line" id="L539"><span class="tok-kw">fn</span> <span class="tok-fn">testValid</span>(bytes: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>, expected_codepoint: <span class="tok-type">u21</span>) !<span class="tok-type">void</span> {</span>
<span class="line" id="L540">    <span class="tok-kw">try</span> testing.expect((testDecode(bytes) <span class="tok-kw">catch</span> <span class="tok-kw">unreachable</span>) == expected_codepoint);</span>
<span class="line" id="L541">}</span>
<span class="line" id="L542"></span>
<span class="line" id="L543"><span class="tok-kw">fn</span> <span class="tok-fn">testDecode</span>(bytes: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) !<span class="tok-type">u21</span> {</span>
<span class="line" id="L544">    <span class="tok-kw">const</span> length = <span class="tok-kw">try</span> utf8ByteSequenceLength(bytes[<span class="tok-number">0</span>]);</span>
<span class="line" id="L545">    <span class="tok-kw">if</span> (bytes.len &lt; length) <span class="tok-kw">return</span> <span class="tok-kw">error</span>.UnexpectedEof;</span>
<span class="line" id="L546">    <span class="tok-kw">try</span> testing.expect(bytes.len == length);</span>
<span class="line" id="L547">    <span class="tok-kw">return</span> utf8Decode(bytes);</span>
<span class="line" id="L548">}</span>
<span class="line" id="L549"></span>
<span class="line" id="L550"><span class="tok-comment">/// Caller must free returned memory.</span></span>
<span class="line" id="L551"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">utf16leToUtf8Alloc</span>(allocator: mem.Allocator, utf16le: []<span class="tok-kw">const</span> <span class="tok-type">u16</span>) ![]<span class="tok-type">u8</span> {</span>
<span class="line" id="L552">    <span class="tok-comment">// optimistically guess that it will all be ascii.</span>
</span>
<span class="line" id="L553">    <span class="tok-kw">var</span> result = <span class="tok-kw">try</span> std.ArrayList(<span class="tok-type">u8</span>).initCapacity(allocator, utf16le.len);</span>
<span class="line" id="L554">    <span class="tok-kw">errdefer</span> result.deinit();</span>
<span class="line" id="L555">    <span class="tok-kw">var</span> out_index: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L556">    <span class="tok-kw">var</span> it = Utf16LeIterator.init(utf16le);</span>
<span class="line" id="L557">    <span class="tok-kw">while</span> (<span class="tok-kw">try</span> it.nextCodepoint()) |codepoint| {</span>
<span class="line" id="L558">        <span class="tok-kw">const</span> utf8_len = utf8CodepointSequenceLength(codepoint) <span class="tok-kw">catch</span> <span class="tok-kw">unreachable</span>;</span>
<span class="line" id="L559">        <span class="tok-kw">try</span> result.resize(result.items.len + utf8_len);</span>
<span class="line" id="L560">        assert((utf8Encode(codepoint, result.items[out_index..]) <span class="tok-kw">catch</span> <span class="tok-kw">unreachable</span>) == utf8_len);</span>
<span class="line" id="L561">        out_index += utf8_len;</span>
<span class="line" id="L562">    }</span>
<span class="line" id="L563"></span>
<span class="line" id="L564">    <span class="tok-kw">return</span> result.toOwnedSlice();</span>
<span class="line" id="L565">}</span>
<span class="line" id="L566"></span>
<span class="line" id="L567"><span class="tok-comment">/// Caller must free returned memory.</span></span>
<span class="line" id="L568"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">utf16leToUtf8AllocZ</span>(allocator: mem.Allocator, utf16le: []<span class="tok-kw">const</span> <span class="tok-type">u16</span>) ![:<span class="tok-number">0</span>]<span class="tok-type">u8</span> {</span>
<span class="line" id="L569">    <span class="tok-comment">// optimistically guess that it will all be ascii (and allocate space for the null terminator)</span>
</span>
<span class="line" id="L570">    <span class="tok-kw">var</span> result = <span class="tok-kw">try</span> std.ArrayList(<span class="tok-type">u8</span>).initCapacity(allocator, utf16le.len + <span class="tok-number">1</span>);</span>
<span class="line" id="L571">    <span class="tok-kw">errdefer</span> result.deinit();</span>
<span class="line" id="L572">    <span class="tok-kw">var</span> out_index: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L573">    <span class="tok-kw">var</span> it = Utf16LeIterator.init(utf16le);</span>
<span class="line" id="L574">    <span class="tok-kw">while</span> (<span class="tok-kw">try</span> it.nextCodepoint()) |codepoint| {</span>
<span class="line" id="L575">        <span class="tok-kw">const</span> utf8_len = utf8CodepointSequenceLength(codepoint) <span class="tok-kw">catch</span> <span class="tok-kw">unreachable</span>;</span>
<span class="line" id="L576">        <span class="tok-kw">try</span> result.resize(result.items.len + utf8_len);</span>
<span class="line" id="L577">        assert((utf8Encode(codepoint, result.items[out_index..]) <span class="tok-kw">catch</span> <span class="tok-kw">unreachable</span>) == utf8_len);</span>
<span class="line" id="L578">        out_index += utf8_len;</span>
<span class="line" id="L579">    }</span>
<span class="line" id="L580"></span>
<span class="line" id="L581">    <span class="tok-kw">const</span> len = result.items.len;</span>
<span class="line" id="L582"></span>
<span class="line" id="L583">    <span class="tok-kw">try</span> result.append(<span class="tok-number">0</span>);</span>
<span class="line" id="L584"></span>
<span class="line" id="L585">    <span class="tok-kw">return</span> result.toOwnedSlice()[<span class="tok-number">0</span>..len :<span class="tok-number">0</span>];</span>
<span class="line" id="L586">}</span>
<span class="line" id="L587"></span>
<span class="line" id="L588"><span class="tok-comment">/// Asserts that the output buffer is big enough.</span></span>
<span class="line" id="L589"><span class="tok-comment">/// Returns end byte index into utf8.</span></span>
<span class="line" id="L590"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">utf16leToUtf8</span>(utf8: []<span class="tok-type">u8</span>, utf16le: []<span class="tok-kw">const</span> <span class="tok-type">u16</span>) !<span class="tok-type">usize</span> {</span>
<span class="line" id="L591">    <span class="tok-kw">var</span> end_index: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L592">    <span class="tok-kw">var</span> it = Utf16LeIterator.init(utf16le);</span>
<span class="line" id="L593">    <span class="tok-kw">while</span> (<span class="tok-kw">try</span> it.nextCodepoint()) |codepoint| {</span>
<span class="line" id="L594">        end_index += <span class="tok-kw">try</span> utf8Encode(codepoint, utf8[end_index..]);</span>
<span class="line" id="L595">    }</span>
<span class="line" id="L596">    <span class="tok-kw">return</span> end_index;</span>
<span class="line" id="L597">}</span>
<span class="line" id="L598"></span>
<span class="line" id="L599"><span class="tok-kw">test</span> <span class="tok-str">&quot;utf16leToUtf8&quot;</span> {</span>
<span class="line" id="L600">    <span class="tok-kw">var</span> utf16le: [<span class="tok-number">2</span>]<span class="tok-type">u16</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L601">    <span class="tok-kw">const</span> utf16le_as_bytes = mem.sliceAsBytes(utf16le[<span class="tok-number">0</span>..]);</span>
<span class="line" id="L602"></span>
<span class="line" id="L603">    {</span>
<span class="line" id="L604">        mem.writeIntSliceLittle(<span class="tok-type">u16</span>, utf16le_as_bytes[<span class="tok-number">0</span>..], <span class="tok-str">'A'</span>);</span>
<span class="line" id="L605">        mem.writeIntSliceLittle(<span class="tok-type">u16</span>, utf16le_as_bytes[<span class="tok-number">2</span>..], <span class="tok-str">'a'</span>);</span>
<span class="line" id="L606">        <span class="tok-kw">const</span> utf8 = <span class="tok-kw">try</span> utf16leToUtf8Alloc(std.testing.allocator, &amp;utf16le);</span>
<span class="line" id="L607">        <span class="tok-kw">defer</span> std.testing.allocator.free(utf8);</span>
<span class="line" id="L608">        <span class="tok-kw">try</span> testing.expect(mem.eql(<span class="tok-type">u8</span>, utf8, <span class="tok-str">&quot;Aa&quot;</span>));</span>
<span class="line" id="L609">    }</span>
<span class="line" id="L610"></span>
<span class="line" id="L611">    {</span>
<span class="line" id="L612">        mem.writeIntSliceLittle(<span class="tok-type">u16</span>, utf16le_as_bytes[<span class="tok-number">0</span>..], <span class="tok-number">0x80</span>);</span>
<span class="line" id="L613">        mem.writeIntSliceLittle(<span class="tok-type">u16</span>, utf16le_as_bytes[<span class="tok-number">2</span>..], <span class="tok-number">0xffff</span>);</span>
<span class="line" id="L614">        <span class="tok-kw">const</span> utf8 = <span class="tok-kw">try</span> utf16leToUtf8Alloc(std.testing.allocator, &amp;utf16le);</span>
<span class="line" id="L615">        <span class="tok-kw">defer</span> std.testing.allocator.free(utf8);</span>
<span class="line" id="L616">        <span class="tok-kw">try</span> testing.expect(mem.eql(<span class="tok-type">u8</span>, utf8, <span class="tok-str">&quot;\xc2\x80&quot;</span> ++ <span class="tok-str">&quot;\xef\xbf\xbf&quot;</span>));</span>
<span class="line" id="L617">    }</span>
<span class="line" id="L618"></span>
<span class="line" id="L619">    {</span>
<span class="line" id="L620">        <span class="tok-comment">// the values just outside the surrogate half range</span>
</span>
<span class="line" id="L621">        mem.writeIntSliceLittle(<span class="tok-type">u16</span>, utf16le_as_bytes[<span class="tok-number">0</span>..], <span class="tok-number">0xd7ff</span>);</span>
<span class="line" id="L622">        mem.writeIntSliceLittle(<span class="tok-type">u16</span>, utf16le_as_bytes[<span class="tok-number">2</span>..], <span class="tok-number">0xe000</span>);</span>
<span class="line" id="L623">        <span class="tok-kw">const</span> utf8 = <span class="tok-kw">try</span> utf16leToUtf8Alloc(std.testing.allocator, &amp;utf16le);</span>
<span class="line" id="L624">        <span class="tok-kw">defer</span> std.testing.allocator.free(utf8);</span>
<span class="line" id="L625">        <span class="tok-kw">try</span> testing.expect(mem.eql(<span class="tok-type">u8</span>, utf8, <span class="tok-str">&quot;\xed\x9f\xbf&quot;</span> ++ <span class="tok-str">&quot;\xee\x80\x80&quot;</span>));</span>
<span class="line" id="L626">    }</span>
<span class="line" id="L627"></span>
<span class="line" id="L628">    {</span>
<span class="line" id="L629">        <span class="tok-comment">// smallest surrogate pair</span>
</span>
<span class="line" id="L630">        mem.writeIntSliceLittle(<span class="tok-type">u16</span>, utf16le_as_bytes[<span class="tok-number">0</span>..], <span class="tok-number">0xd800</span>);</span>
<span class="line" id="L631">        mem.writeIntSliceLittle(<span class="tok-type">u16</span>, utf16le_as_bytes[<span class="tok-number">2</span>..], <span class="tok-number">0xdc00</span>);</span>
<span class="line" id="L632">        <span class="tok-kw">const</span> utf8 = <span class="tok-kw">try</span> utf16leToUtf8Alloc(std.testing.allocator, &amp;utf16le);</span>
<span class="line" id="L633">        <span class="tok-kw">defer</span> std.testing.allocator.free(utf8);</span>
<span class="line" id="L634">        <span class="tok-kw">try</span> testing.expect(mem.eql(<span class="tok-type">u8</span>, utf8, <span class="tok-str">&quot;\xf0\x90\x80\x80&quot;</span>));</span>
<span class="line" id="L635">    }</span>
<span class="line" id="L636"></span>
<span class="line" id="L637">    {</span>
<span class="line" id="L638">        <span class="tok-comment">// largest surrogate pair</span>
</span>
<span class="line" id="L639">        mem.writeIntSliceLittle(<span class="tok-type">u16</span>, utf16le_as_bytes[<span class="tok-number">0</span>..], <span class="tok-number">0xdbff</span>);</span>
<span class="line" id="L640">        mem.writeIntSliceLittle(<span class="tok-type">u16</span>, utf16le_as_bytes[<span class="tok-number">2</span>..], <span class="tok-number">0xdfff</span>);</span>
<span class="line" id="L641">        <span class="tok-kw">const</span> utf8 = <span class="tok-kw">try</span> utf16leToUtf8Alloc(std.testing.allocator, &amp;utf16le);</span>
<span class="line" id="L642">        <span class="tok-kw">defer</span> std.testing.allocator.free(utf8);</span>
<span class="line" id="L643">        <span class="tok-kw">try</span> testing.expect(mem.eql(<span class="tok-type">u8</span>, utf8, <span class="tok-str">&quot;\xf4\x8f\xbf\xbf&quot;</span>));</span>
<span class="line" id="L644">    }</span>
<span class="line" id="L645"></span>
<span class="line" id="L646">    {</span>
<span class="line" id="L647">        mem.writeIntSliceLittle(<span class="tok-type">u16</span>, utf16le_as_bytes[<span class="tok-number">0</span>..], <span class="tok-number">0xdbff</span>);</span>
<span class="line" id="L648">        mem.writeIntSliceLittle(<span class="tok-type">u16</span>, utf16le_as_bytes[<span class="tok-number">2</span>..], <span class="tok-number">0xdc00</span>);</span>
<span class="line" id="L649">        <span class="tok-kw">const</span> utf8 = <span class="tok-kw">try</span> utf16leToUtf8Alloc(std.testing.allocator, &amp;utf16le);</span>
<span class="line" id="L650">        <span class="tok-kw">defer</span> std.testing.allocator.free(utf8);</span>
<span class="line" id="L651">        <span class="tok-kw">try</span> testing.expect(mem.eql(<span class="tok-type">u8</span>, utf8, <span class="tok-str">&quot;\xf4\x8f\xb0\x80&quot;</span>));</span>
<span class="line" id="L652">    }</span>
<span class="line" id="L653"></span>
<span class="line" id="L654">    {</span>
<span class="line" id="L655">        mem.writeIntSliceLittle(<span class="tok-type">u16</span>, utf16le_as_bytes[<span class="tok-number">0</span>..], <span class="tok-number">0xdcdc</span>);</span>
<span class="line" id="L656">        mem.writeIntSliceLittle(<span class="tok-type">u16</span>, utf16le_as_bytes[<span class="tok-number">2</span>..], <span class="tok-number">0xdcdc</span>);</span>
<span class="line" id="L657">        <span class="tok-kw">const</span> result = utf16leToUtf8Alloc(std.testing.allocator, &amp;utf16le);</span>
<span class="line" id="L658">        <span class="tok-kw">try</span> std.testing.expectError(<span class="tok-kw">error</span>.UnexpectedSecondSurrogateHalf, result);</span>
<span class="line" id="L659">    }</span>
<span class="line" id="L660">}</span>
<span class="line" id="L661"></span>
<span class="line" id="L662"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">utf8ToUtf16LeWithNull</span>(allocator: mem.Allocator, utf8: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) ![:<span class="tok-number">0</span>]<span class="tok-type">u16</span> {</span>
<span class="line" id="L663">    <span class="tok-comment">// optimistically guess that it will not require surrogate pairs</span>
</span>
<span class="line" id="L664">    <span class="tok-kw">var</span> result = <span class="tok-kw">try</span> std.ArrayList(<span class="tok-type">u16</span>).initCapacity(allocator, utf8.len + <span class="tok-number">1</span>);</span>
<span class="line" id="L665">    <span class="tok-kw">errdefer</span> result.deinit();</span>
<span class="line" id="L666"></span>
<span class="line" id="L667">    <span class="tok-kw">const</span> view = <span class="tok-kw">try</span> Utf8View.init(utf8);</span>
<span class="line" id="L668">    <span class="tok-kw">var</span> it = view.iterator();</span>
<span class="line" id="L669">    <span class="tok-kw">while</span> (it.nextCodepoint()) |codepoint| {</span>
<span class="line" id="L670">        <span class="tok-kw">if</span> (codepoint &lt; <span class="tok-number">0x10000</span>) {</span>
<span class="line" id="L671">            <span class="tok-kw">const</span> short = <span class="tok-builtin">@intCast</span>(<span class="tok-type">u16</span>, codepoint);</span>
<span class="line" id="L672">            <span class="tok-kw">try</span> result.append(mem.nativeToLittle(<span class="tok-type">u16</span>, short));</span>
<span class="line" id="L673">        } <span class="tok-kw">else</span> {</span>
<span class="line" id="L674">            <span class="tok-kw">const</span> high = <span class="tok-builtin">@intCast</span>(<span class="tok-type">u16</span>, (codepoint - <span class="tok-number">0x10000</span>) &gt;&gt; <span class="tok-number">10</span>) + <span class="tok-number">0xD800</span>;</span>
<span class="line" id="L675">            <span class="tok-kw">const</span> low = <span class="tok-builtin">@intCast</span>(<span class="tok-type">u16</span>, codepoint &amp; <span class="tok-number">0x3FF</span>) + <span class="tok-number">0xDC00</span>;</span>
<span class="line" id="L676">            <span class="tok-kw">var</span> out: [<span class="tok-number">2</span>]<span class="tok-type">u16</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L677">            out[<span class="tok-number">0</span>] = mem.nativeToLittle(<span class="tok-type">u16</span>, high);</span>
<span class="line" id="L678">            out[<span class="tok-number">1</span>] = mem.nativeToLittle(<span class="tok-type">u16</span>, low);</span>
<span class="line" id="L679">            <span class="tok-kw">try</span> result.appendSlice(out[<span class="tok-number">0</span>..]);</span>
<span class="line" id="L680">        }</span>
<span class="line" id="L681">    }</span>
<span class="line" id="L682"></span>
<span class="line" id="L683">    <span class="tok-kw">const</span> len = result.items.len;</span>
<span class="line" id="L684">    <span class="tok-kw">try</span> result.append(<span class="tok-number">0</span>);</span>
<span class="line" id="L685">    <span class="tok-kw">return</span> result.toOwnedSlice()[<span class="tok-number">0</span>..len :<span class="tok-number">0</span>];</span>
<span class="line" id="L686">}</span>
<span class="line" id="L687"></span>
<span class="line" id="L688"><span class="tok-comment">/// Returns index of next character. If exact fit, returned index equals output slice length.</span></span>
<span class="line" id="L689"><span class="tok-comment">/// Assumes there is enough space for the output.</span></span>
<span class="line" id="L690"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">utf8ToUtf16Le</span>(utf16le: []<span class="tok-type">u16</span>, utf8: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) !<span class="tok-type">usize</span> {</span>
<span class="line" id="L691">    <span class="tok-kw">var</span> dest_i: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L692">    <span class="tok-kw">var</span> src_i: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L693">    <span class="tok-kw">while</span> (src_i &lt; utf8.len) {</span>
<span class="line" id="L694">        <span class="tok-kw">const</span> n = utf8ByteSequenceLength(utf8[src_i]) <span class="tok-kw">catch</span> <span class="tok-kw">return</span> <span class="tok-kw">error</span>.InvalidUtf8;</span>
<span class="line" id="L695">        <span class="tok-kw">const</span> next_src_i = src_i + n;</span>
<span class="line" id="L696">        <span class="tok-kw">const</span> codepoint = utf8Decode(utf8[src_i..next_src_i]) <span class="tok-kw">catch</span> <span class="tok-kw">return</span> <span class="tok-kw">error</span>.InvalidUtf8;</span>
<span class="line" id="L697">        <span class="tok-kw">if</span> (codepoint &lt; <span class="tok-number">0x10000</span>) {</span>
<span class="line" id="L698">            <span class="tok-kw">const</span> short = <span class="tok-builtin">@intCast</span>(<span class="tok-type">u16</span>, codepoint);</span>
<span class="line" id="L699">            utf16le[dest_i] = mem.nativeToLittle(<span class="tok-type">u16</span>, short);</span>
<span class="line" id="L700">            dest_i += <span class="tok-number">1</span>;</span>
<span class="line" id="L701">        } <span class="tok-kw">else</span> {</span>
<span class="line" id="L702">            <span class="tok-kw">const</span> high = <span class="tok-builtin">@intCast</span>(<span class="tok-type">u16</span>, (codepoint - <span class="tok-number">0x10000</span>) &gt;&gt; <span class="tok-number">10</span>) + <span class="tok-number">0xD800</span>;</span>
<span class="line" id="L703">            <span class="tok-kw">const</span> low = <span class="tok-builtin">@intCast</span>(<span class="tok-type">u16</span>, codepoint &amp; <span class="tok-number">0x3FF</span>) + <span class="tok-number">0xDC00</span>;</span>
<span class="line" id="L704">            utf16le[dest_i] = mem.nativeToLittle(<span class="tok-type">u16</span>, high);</span>
<span class="line" id="L705">            utf16le[dest_i + <span class="tok-number">1</span>] = mem.nativeToLittle(<span class="tok-type">u16</span>, low);</span>
<span class="line" id="L706">            dest_i += <span class="tok-number">2</span>;</span>
<span class="line" id="L707">        }</span>
<span class="line" id="L708">        src_i = next_src_i;</span>
<span class="line" id="L709">    }</span>
<span class="line" id="L710">    <span class="tok-kw">return</span> dest_i;</span>
<span class="line" id="L711">}</span>
<span class="line" id="L712"></span>
<span class="line" id="L713"><span class="tok-kw">test</span> <span class="tok-str">&quot;utf8ToUtf16Le&quot;</span> {</span>
<span class="line" id="L714">    <span class="tok-kw">var</span> utf16le: [<span class="tok-number">2</span>]<span class="tok-type">u16</span> = [_]<span class="tok-type">u16</span>{<span class="tok-number">0</span>} ** <span class="tok-number">2</span>;</span>
<span class="line" id="L715">    {</span>
<span class="line" id="L716">        <span class="tok-kw">const</span> length = <span class="tok-kw">try</span> utf8ToUtf16Le(utf16le[<span class="tok-number">0</span>..], <span class="tok-str">&quot;𐐷&quot;</span>);</span>
<span class="line" id="L717">        <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">usize</span>, <span class="tok-number">2</span>), length);</span>
<span class="line" id="L718">        <span class="tok-kw">try</span> testing.expectEqualSlices(<span class="tok-type">u8</span>, <span class="tok-str">&quot;\x01\xd8\x37\xdc&quot;</span>, mem.sliceAsBytes(utf16le[<span class="tok-number">0</span>..]));</span>
<span class="line" id="L719">    }</span>
<span class="line" id="L720">    {</span>
<span class="line" id="L721">        <span class="tok-kw">const</span> length = <span class="tok-kw">try</span> utf8ToUtf16Le(utf16le[<span class="tok-number">0</span>..], <span class="tok-str">&quot;\u{10FFFF}&quot;</span>);</span>
<span class="line" id="L722">        <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">usize</span>, <span class="tok-number">2</span>), length);</span>
<span class="line" id="L723">        <span class="tok-kw">try</span> testing.expectEqualSlices(<span class="tok-type">u8</span>, <span class="tok-str">&quot;\xff\xdb\xff\xdf&quot;</span>, mem.sliceAsBytes(utf16le[<span class="tok-number">0</span>..]));</span>
<span class="line" id="L724">    }</span>
<span class="line" id="L725">    {</span>
<span class="line" id="L726">        <span class="tok-kw">const</span> result = utf8ToUtf16Le(utf16le[<span class="tok-number">0</span>..], <span class="tok-str">&quot;\xf4\x90\x80\x80&quot;</span>);</span>
<span class="line" id="L727">        <span class="tok-kw">try</span> testing.expectError(<span class="tok-kw">error</span>.InvalidUtf8, result);</span>
<span class="line" id="L728">    }</span>
<span class="line" id="L729">}</span>
<span class="line" id="L730"></span>
<span class="line" id="L731"><span class="tok-kw">test</span> <span class="tok-str">&quot;utf8ToUtf16LeWithNull&quot;</span> {</span>
<span class="line" id="L732">    {</span>
<span class="line" id="L733">        <span class="tok-kw">const</span> utf16 = <span class="tok-kw">try</span> utf8ToUtf16LeWithNull(testing.allocator, <span class="tok-str">&quot;𐐷&quot;</span>);</span>
<span class="line" id="L734">        <span class="tok-kw">defer</span> testing.allocator.free(utf16);</span>
<span class="line" id="L735">        <span class="tok-kw">try</span> testing.expectEqualSlices(<span class="tok-type">u8</span>, <span class="tok-str">&quot;\x01\xd8\x37\xdc&quot;</span>, mem.sliceAsBytes(utf16[<span class="tok-number">0</span>..]));</span>
<span class="line" id="L736">        <span class="tok-kw">try</span> testing.expect(utf16[<span class="tok-number">2</span>] == <span class="tok-number">0</span>);</span>
<span class="line" id="L737">    }</span>
<span class="line" id="L738">    {</span>
<span class="line" id="L739">        <span class="tok-kw">const</span> utf16 = <span class="tok-kw">try</span> utf8ToUtf16LeWithNull(testing.allocator, <span class="tok-str">&quot;\u{10FFFF}&quot;</span>);</span>
<span class="line" id="L740">        <span class="tok-kw">defer</span> testing.allocator.free(utf16);</span>
<span class="line" id="L741">        <span class="tok-kw">try</span> testing.expectEqualSlices(<span class="tok-type">u8</span>, <span class="tok-str">&quot;\xff\xdb\xff\xdf&quot;</span>, mem.sliceAsBytes(utf16[<span class="tok-number">0</span>..]));</span>
<span class="line" id="L742">        <span class="tok-kw">try</span> testing.expect(utf16[<span class="tok-number">2</span>] == <span class="tok-number">0</span>);</span>
<span class="line" id="L743">    }</span>
<span class="line" id="L744">    {</span>
<span class="line" id="L745">        <span class="tok-kw">const</span> result = utf8ToUtf16LeWithNull(testing.allocator, <span class="tok-str">&quot;\xf4\x90\x80\x80&quot;</span>);</span>
<span class="line" id="L746">        <span class="tok-kw">try</span> testing.expectError(<span class="tok-kw">error</span>.InvalidUtf8, result);</span>
<span class="line" id="L747">    }</span>
<span class="line" id="L748">}</span>
<span class="line" id="L749"></span>
<span class="line" id="L750"><span class="tok-comment">/// Converts a UTF-8 string literal into a UTF-16LE string literal.</span></span>
<span class="line" id="L751"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">utf8ToUtf16LeStringLiteral</span>(<span class="tok-kw">comptime</span> utf8: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) *<span class="tok-kw">const</span> [calcUtf16LeLen(utf8):<span class="tok-number">0</span>]<span class="tok-type">u16</span> {</span>
<span class="line" id="L752">    <span class="tok-kw">comptime</span> {</span>
<span class="line" id="L753">        <span class="tok-kw">const</span> len: <span class="tok-type">usize</span> = calcUtf16LeLen(utf8);</span>
<span class="line" id="L754">        <span class="tok-kw">var</span> utf16le: [len:<span class="tok-number">0</span>]<span class="tok-type">u16</span> = [_:<span class="tok-number">0</span>]<span class="tok-type">u16</span>{<span class="tok-number">0</span>} ** len;</span>
<span class="line" id="L755">        <span class="tok-kw">const</span> utf16le_len = utf8ToUtf16Le(&amp;utf16le, utf8[<span class="tok-number">0</span>..]) <span class="tok-kw">catch</span> |err| <span class="tok-builtin">@compileError</span>(err);</span>
<span class="line" id="L756">        assert(len == utf16le_len);</span>
<span class="line" id="L757">        <span class="tok-kw">return</span> &amp;utf16le;</span>
<span class="line" id="L758">    }</span>
<span class="line" id="L759">}</span>
<span class="line" id="L760"></span>
<span class="line" id="L761"><span class="tok-kw">fn</span> <span class="tok-fn">calcUtf16LeLen</span>(utf8: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) <span class="tok-type">usize</span> {</span>
<span class="line" id="L762">    <span class="tok-kw">var</span> src_i: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L763">    <span class="tok-kw">var</span> dest_len: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L764">    <span class="tok-kw">while</span> (src_i &lt; utf8.len) {</span>
<span class="line" id="L765">        <span class="tok-kw">const</span> n = utf8ByteSequenceLength(utf8[src_i]) <span class="tok-kw">catch</span> <span class="tok-kw">unreachable</span>;</span>
<span class="line" id="L766">        <span class="tok-kw">const</span> next_src_i = src_i + n;</span>
<span class="line" id="L767">        <span class="tok-kw">const</span> codepoint = utf8Decode(utf8[src_i..next_src_i]) <span class="tok-kw">catch</span> <span class="tok-kw">unreachable</span>;</span>
<span class="line" id="L768">        <span class="tok-kw">if</span> (codepoint &lt; <span class="tok-number">0x10000</span>) {</span>
<span class="line" id="L769">            dest_len += <span class="tok-number">1</span>;</span>
<span class="line" id="L770">        } <span class="tok-kw">else</span> {</span>
<span class="line" id="L771">            dest_len += <span class="tok-number">2</span>;</span>
<span class="line" id="L772">        }</span>
<span class="line" id="L773">        src_i = next_src_i;</span>
<span class="line" id="L774">    }</span>
<span class="line" id="L775">    <span class="tok-kw">return</span> dest_len;</span>
<span class="line" id="L776">}</span>
<span class="line" id="L777"></span>
<span class="line" id="L778"><span class="tok-comment">/// Print the given `utf16le` string</span></span>
<span class="line" id="L779"><span class="tok-kw">fn</span> <span class="tok-fn">formatUtf16le</span>(</span>
<span class="line" id="L780">    utf16le: []<span class="tok-kw">const</span> <span class="tok-type">u16</span>,</span>
<span class="line" id="L781">    <span class="tok-kw">comptime</span> fmt: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>,</span>
<span class="line" id="L782">    options: std.fmt.FormatOptions,</span>
<span class="line" id="L783">    writer: <span class="tok-kw">anytype</span>,</span>
<span class="line" id="L784">) !<span class="tok-type">void</span> {</span>
<span class="line" id="L785">    _ = fmt;</span>
<span class="line" id="L786">    _ = options;</span>
<span class="line" id="L787">    <span class="tok-kw">var</span> buf: [<span class="tok-number">300</span>]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>; <span class="tok-comment">// just a random size I chose</span>
</span>
<span class="line" id="L788">    <span class="tok-kw">var</span> it = Utf16LeIterator.init(utf16le);</span>
<span class="line" id="L789">    <span class="tok-kw">var</span> u8len: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L790">    <span class="tok-kw">while</span> (it.nextCodepoint() <span class="tok-kw">catch</span> replacement_character) |codepoint| {</span>
<span class="line" id="L791">        u8len += utf8Encode(codepoint, buf[u8len..]) <span class="tok-kw">catch</span></span>
<span class="line" id="L792">            utf8Encode(replacement_character, buf[u8len..]) <span class="tok-kw">catch</span> <span class="tok-kw">unreachable</span>;</span>
<span class="line" id="L793">        <span class="tok-kw">if</span> (u8len + <span class="tok-number">3</span> &gt;= buf.len) {</span>
<span class="line" id="L794">            <span class="tok-kw">try</span> writer.writeAll(buf[<span class="tok-number">0</span>..u8len]);</span>
<span class="line" id="L795">            u8len = <span class="tok-number">0</span>;</span>
<span class="line" id="L796">        }</span>
<span class="line" id="L797">    }</span>
<span class="line" id="L798">    <span class="tok-kw">try</span> writer.writeAll(buf[<span class="tok-number">0</span>..u8len]);</span>
<span class="line" id="L799">}</span>
<span class="line" id="L800"></span>
<span class="line" id="L801"><span class="tok-comment">/// Return a Formatter for a Utf16le string</span></span>
<span class="line" id="L802"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">fmtUtf16le</span>(utf16le: []<span class="tok-kw">const</span> <span class="tok-type">u16</span>) std.fmt.Formatter(formatUtf16le) {</span>
<span class="line" id="L803">    <span class="tok-kw">return</span> .{ .data = utf16le };</span>
<span class="line" id="L804">}</span>
<span class="line" id="L805"></span>
<span class="line" id="L806"><span class="tok-kw">test</span> <span class="tok-str">&quot;fmtUtf16le&quot;</span> {</span>
<span class="line" id="L807">    <span class="tok-kw">const</span> expectFmt = std.testing.expectFmt;</span>
<span class="line" id="L808">    <span class="tok-kw">try</span> expectFmt(<span class="tok-str">&quot;&quot;</span>, <span class="tok-str">&quot;{}&quot;</span>, .{fmtUtf16le(utf8ToUtf16LeStringLiteral(<span class="tok-str">&quot;&quot;</span>))});</span>
<span class="line" id="L809">    <span class="tok-kw">try</span> expectFmt(<span class="tok-str">&quot;foo&quot;</span>, <span class="tok-str">&quot;{}&quot;</span>, .{fmtUtf16le(utf8ToUtf16LeStringLiteral(<span class="tok-str">&quot;foo&quot;</span>))});</span>
<span class="line" id="L810">    <span class="tok-kw">try</span> expectFmt(<span class="tok-str">&quot;𐐷&quot;</span>, <span class="tok-str">&quot;{}&quot;</span>, .{fmtUtf16le(utf8ToUtf16LeStringLiteral(<span class="tok-str">&quot;𐐷&quot;</span>))});</span>
<span class="line" id="L811">    <span class="tok-kw">try</span> expectFmt(<span class="tok-str">&quot;퟿&quot;</span>, <span class="tok-str">&quot;{}&quot;</span>, .{fmtUtf16le(&amp;[_]<span class="tok-type">u16</span>{std.mem.readIntNative(<span class="tok-type">u16</span>, <span class="tok-str">&quot;\xff\xd7&quot;</span>)})});</span>
<span class="line" id="L812">    <span class="tok-kw">try</span> expectFmt(<span class="tok-str">&quot;�&quot;</span>, <span class="tok-str">&quot;{}&quot;</span>, .{fmtUtf16le(&amp;[_]<span class="tok-type">u16</span>{std.mem.readIntNative(<span class="tok-type">u16</span>, <span class="tok-str">&quot;\x00\xd8&quot;</span>)})});</span>
<span class="line" id="L813">    <span class="tok-kw">try</span> expectFmt(<span class="tok-str">&quot;�&quot;</span>, <span class="tok-str">&quot;{}&quot;</span>, .{fmtUtf16le(&amp;[_]<span class="tok-type">u16</span>{std.mem.readIntNative(<span class="tok-type">u16</span>, <span class="tok-str">&quot;\xff\xdb&quot;</span>)})});</span>
<span class="line" id="L814">    <span class="tok-kw">try</span> expectFmt(<span class="tok-str">&quot;�&quot;</span>, <span class="tok-str">&quot;{}&quot;</span>, .{fmtUtf16le(&amp;[_]<span class="tok-type">u16</span>{std.mem.readIntNative(<span class="tok-type">u16</span>, <span class="tok-str">&quot;\x00\xdc&quot;</span>)})});</span>
<span class="line" id="L815">    <span class="tok-kw">try</span> expectFmt(<span class="tok-str">&quot;�&quot;</span>, <span class="tok-str">&quot;{}&quot;</span>, .{fmtUtf16le(&amp;[_]<span class="tok-type">u16</span>{std.mem.readIntNative(<span class="tok-type">u16</span>, <span class="tok-str">&quot;\xff\xdf&quot;</span>)})});</span>
<span class="line" id="L816">    <span class="tok-kw">try</span> expectFmt(<span class="tok-str">&quot;&quot;</span>, <span class="tok-str">&quot;{}&quot;</span>, .{fmtUtf16le(&amp;[_]<span class="tok-type">u16</span>{std.mem.readIntNative(<span class="tok-type">u16</span>, <span class="tok-str">&quot;\x00\xe0&quot;</span>)})});</span>
<span class="line" id="L817">}</span>
<span class="line" id="L818"></span>
<span class="line" id="L819"><span class="tok-kw">test</span> <span class="tok-str">&quot;utf8ToUtf16LeStringLiteral&quot;</span> {</span>
<span class="line" id="L820">    {</span>
<span class="line" id="L821">        <span class="tok-kw">const</span> bytes = [_:<span class="tok-number">0</span>]<span class="tok-type">u16</span>{</span>
<span class="line" id="L822">            mem.nativeToLittle(<span class="tok-type">u16</span>, <span class="tok-number">0x41</span>),</span>
<span class="line" id="L823">        };</span>
<span class="line" id="L824">        <span class="tok-kw">const</span> utf16 = utf8ToUtf16LeStringLiteral(<span class="tok-str">&quot;A&quot;</span>);</span>
<span class="line" id="L825">        <span class="tok-kw">try</span> testing.expectEqualSlices(<span class="tok-type">u16</span>, &amp;bytes, utf16);</span>
<span class="line" id="L826">        <span class="tok-kw">try</span> testing.expect(utf16[<span class="tok-number">1</span>] == <span class="tok-number">0</span>);</span>
<span class="line" id="L827">    }</span>
<span class="line" id="L828">    {</span>
<span class="line" id="L829">        <span class="tok-kw">const</span> bytes = [_:<span class="tok-number">0</span>]<span class="tok-type">u16</span>{</span>
<span class="line" id="L830">            mem.nativeToLittle(<span class="tok-type">u16</span>, <span class="tok-number">0xD801</span>),</span>
<span class="line" id="L831">            mem.nativeToLittle(<span class="tok-type">u16</span>, <span class="tok-number">0xDC37</span>),</span>
<span class="line" id="L832">        };</span>
<span class="line" id="L833">        <span class="tok-kw">const</span> utf16 = utf8ToUtf16LeStringLiteral(<span class="tok-str">&quot;𐐷&quot;</span>);</span>
<span class="line" id="L834">        <span class="tok-kw">try</span> testing.expectEqualSlices(<span class="tok-type">u16</span>, &amp;bytes, utf16);</span>
<span class="line" id="L835">        <span class="tok-kw">try</span> testing.expect(utf16[<span class="tok-number">2</span>] == <span class="tok-number">0</span>);</span>
<span class="line" id="L836">    }</span>
<span class="line" id="L837">    {</span>
<span class="line" id="L838">        <span class="tok-kw">const</span> bytes = [_:<span class="tok-number">0</span>]<span class="tok-type">u16</span>{</span>
<span class="line" id="L839">            mem.nativeToLittle(<span class="tok-type">u16</span>, <span class="tok-number">0x02FF</span>),</span>
<span class="line" id="L840">        };</span>
<span class="line" id="L841">        <span class="tok-kw">const</span> utf16 = utf8ToUtf16LeStringLiteral(<span class="tok-str">&quot;\u{02FF}&quot;</span>);</span>
<span class="line" id="L842">        <span class="tok-kw">try</span> testing.expectEqualSlices(<span class="tok-type">u16</span>, &amp;bytes, utf16);</span>
<span class="line" id="L843">        <span class="tok-kw">try</span> testing.expect(utf16[<span class="tok-number">1</span>] == <span class="tok-number">0</span>);</span>
<span class="line" id="L844">    }</span>
<span class="line" id="L845">    {</span>
<span class="line" id="L846">        <span class="tok-kw">const</span> bytes = [_:<span class="tok-number">0</span>]<span class="tok-type">u16</span>{</span>
<span class="line" id="L847">            mem.nativeToLittle(<span class="tok-type">u16</span>, <span class="tok-number">0x7FF</span>),</span>
<span class="line" id="L848">        };</span>
<span class="line" id="L849">        <span class="tok-kw">const</span> utf16 = utf8ToUtf16LeStringLiteral(<span class="tok-str">&quot;\u{7FF}&quot;</span>);</span>
<span class="line" id="L850">        <span class="tok-kw">try</span> testing.expectEqualSlices(<span class="tok-type">u16</span>, &amp;bytes, utf16);</span>
<span class="line" id="L851">        <span class="tok-kw">try</span> testing.expect(utf16[<span class="tok-number">1</span>] == <span class="tok-number">0</span>);</span>
<span class="line" id="L852">    }</span>
<span class="line" id="L853">    {</span>
<span class="line" id="L854">        <span class="tok-kw">const</span> bytes = [_:<span class="tok-number">0</span>]<span class="tok-type">u16</span>{</span>
<span class="line" id="L855">            mem.nativeToLittle(<span class="tok-type">u16</span>, <span class="tok-number">0x801</span>),</span>
<span class="line" id="L856">        };</span>
<span class="line" id="L857">        <span class="tok-kw">const</span> utf16 = utf8ToUtf16LeStringLiteral(<span class="tok-str">&quot;\u{801}&quot;</span>);</span>
<span class="line" id="L858">        <span class="tok-kw">try</span> testing.expectEqualSlices(<span class="tok-type">u16</span>, &amp;bytes, utf16);</span>
<span class="line" id="L859">        <span class="tok-kw">try</span> testing.expect(utf16[<span class="tok-number">1</span>] == <span class="tok-number">0</span>);</span>
<span class="line" id="L860">    }</span>
<span class="line" id="L861">    {</span>
<span class="line" id="L862">        <span class="tok-kw">const</span> bytes = [_:<span class="tok-number">0</span>]<span class="tok-type">u16</span>{</span>
<span class="line" id="L863">            mem.nativeToLittle(<span class="tok-type">u16</span>, <span class="tok-number">0xDBFF</span>),</span>
<span class="line" id="L864">            mem.nativeToLittle(<span class="tok-type">u16</span>, <span class="tok-number">0xDFFF</span>),</span>
<span class="line" id="L865">        };</span>
<span class="line" id="L866">        <span class="tok-kw">const</span> utf16 = utf8ToUtf16LeStringLiteral(<span class="tok-str">&quot;\u{10FFFF}&quot;</span>);</span>
<span class="line" id="L867">        <span class="tok-kw">try</span> testing.expectEqualSlices(<span class="tok-type">u16</span>, &amp;bytes, utf16);</span>
<span class="line" id="L868">        <span class="tok-kw">try</span> testing.expect(utf16[<span class="tok-number">2</span>] == <span class="tok-number">0</span>);</span>
<span class="line" id="L869">    }</span>
<span class="line" id="L870">}</span>
<span class="line" id="L871"></span>
<span class="line" id="L872"><span class="tok-kw">fn</span> <span class="tok-fn">testUtf8CountCodepoints</span>() !<span class="tok-type">void</span> {</span>
<span class="line" id="L873">    <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">usize</span>, <span class="tok-number">10</span>), <span class="tok-kw">try</span> utf8CountCodepoints(<span class="tok-str">&quot;abcdefghij&quot;</span>));</span>
<span class="line" id="L874">    <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">usize</span>, <span class="tok-number">10</span>), <span class="tok-kw">try</span> utf8CountCodepoints(<span class="tok-str">&quot;äåéëþüúíóö&quot;</span>));</span>
<span class="line" id="L875">    <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">usize</span>, <span class="tok-number">5</span>), <span class="tok-kw">try</span> utf8CountCodepoints(<span class="tok-str">&quot;こんにちは&quot;</span>));</span>
<span class="line" id="L876">    <span class="tok-comment">// testing.expectError(error.Utf8EncodesSurrogateHalf, utf8CountCodepoints(&quot;\xED\xA0\x80&quot;));</span>
</span>
<span class="line" id="L877">}</span>
<span class="line" id="L878"></span>
<span class="line" id="L879"><span class="tok-kw">test</span> <span class="tok-str">&quot;utf8 count codepoints&quot;</span> {</span>
<span class="line" id="L880">    <span class="tok-kw">try</span> testUtf8CountCodepoints();</span>
<span class="line" id="L881">    <span class="tok-kw">comptime</span> <span class="tok-kw">try</span> testUtf8CountCodepoints();</span>
<span class="line" id="L882">}</span>
<span class="line" id="L883"></span>
<span class="line" id="L884"><span class="tok-kw">fn</span> <span class="tok-fn">testUtf8ValidCodepoint</span>() !<span class="tok-type">void</span> {</span>
<span class="line" id="L885">    <span class="tok-kw">try</span> testing.expect(utf8ValidCodepoint(<span class="tok-str">'e'</span>));</span>
<span class="line" id="L886">    <span class="tok-kw">try</span> testing.expect(utf8ValidCodepoint(<span class="tok-str">'ë'</span>));</span>
<span class="line" id="L887">    <span class="tok-kw">try</span> testing.expect(utf8ValidCodepoint(<span class="tok-str">'は'</span>));</span>
<span class="line" id="L888">    <span class="tok-kw">try</span> testing.expect(utf8ValidCodepoint(<span class="tok-number">0xe000</span>));</span>
<span class="line" id="L889">    <span class="tok-kw">try</span> testing.expect(utf8ValidCodepoint(<span class="tok-number">0x10ffff</span>));</span>
<span class="line" id="L890">    <span class="tok-kw">try</span> testing.expect(!utf8ValidCodepoint(<span class="tok-number">0xd800</span>));</span>
<span class="line" id="L891">    <span class="tok-kw">try</span> testing.expect(!utf8ValidCodepoint(<span class="tok-number">0xdfff</span>));</span>
<span class="line" id="L892">    <span class="tok-kw">try</span> testing.expect(!utf8ValidCodepoint(<span class="tok-number">0x110000</span>));</span>
<span class="line" id="L893">}</span>
<span class="line" id="L894"></span>
<span class="line" id="L895"><span class="tok-kw">test</span> <span class="tok-str">&quot;utf8 valid codepoint&quot;</span> {</span>
<span class="line" id="L896">    <span class="tok-kw">try</span> testUtf8ValidCodepoint();</span>
<span class="line" id="L897">    <span class="tok-kw">comptime</span> <span class="tok-kw">try</span> testUtf8ValidCodepoint();</span>
<span class="line" id="L898">}</span>
<span class="line" id="L899"></span>
</code></pre></body>
</html>