<!doctype html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">    <title>json.zig - source view</title>
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
<pre><code><span class="line" id="L1"><span class="tok-comment">// JSON parser conforming to RFC8259.</span>
</span>
<span class="line" id="L2"><span class="tok-comment">//</span>
</span>
<span class="line" id="L3"><span class="tok-comment">// https://tools.ietf.org/html/rfc8259</span>
</span>
<span class="line" id="L4"></span>
<span class="line" id="L5"><span class="tok-kw">const</span> builtin = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;builtin&quot;</span>);</span>
<span class="line" id="L6"><span class="tok-kw">const</span> std = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;std.zig&quot;</span>);</span>
<span class="line" id="L7"><span class="tok-kw">const</span> debug = std.debug;</span>
<span class="line" id="L8"><span class="tok-kw">const</span> assert = debug.assert;</span>
<span class="line" id="L9"><span class="tok-kw">const</span> testing = std.testing;</span>
<span class="line" id="L10"><span class="tok-kw">const</span> mem = std.mem;</span>
<span class="line" id="L11"><span class="tok-kw">const</span> maxInt = std.math.maxInt;</span>
<span class="line" id="L12"></span>
<span class="line" id="L13"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> WriteStream = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;json/write_stream.zig&quot;</span>).WriteStream;</span>
<span class="line" id="L14"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> writeStream = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;json/write_stream.zig&quot;</span>).writeStream;</span>
<span class="line" id="L15"></span>
<span class="line" id="L16"><span class="tok-kw">const</span> StringEscapes = <span class="tok-kw">union</span>(<span class="tok-kw">enum</span>) {</span>
<span class="line" id="L17">    None,</span>
<span class="line" id="L18"></span>
<span class="line" id="L19">    Some: <span class="tok-kw">struct</span> {</span>
<span class="line" id="L20">        size_diff: <span class="tok-type">isize</span>,</span>
<span class="line" id="L21">    },</span>
<span class="line" id="L22">};</span>
<span class="line" id="L23"></span>
<span class="line" id="L24"><span class="tok-comment">/// Checks to see if a string matches what it would be as a json-encoded string</span></span>
<span class="line" id="L25"><span class="tok-comment">/// Assumes that `encoded` is a well-formed json string</span></span>
<span class="line" id="L26"><span class="tok-kw">fn</span> <span class="tok-fn">encodesTo</span>(decoded: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>, encoded: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) <span class="tok-type">bool</span> {</span>
<span class="line" id="L27">    <span class="tok-kw">var</span> i: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L28">    <span class="tok-kw">var</span> j: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L29">    <span class="tok-kw">while</span> (i &lt; decoded.len) {</span>
<span class="line" id="L30">        <span class="tok-kw">if</span> (j &gt;= encoded.len) <span class="tok-kw">return</span> <span class="tok-null">false</span>;</span>
<span class="line" id="L31">        <span class="tok-kw">if</span> (encoded[j] != <span class="tok-str">'\\'</span>) {</span>
<span class="line" id="L32">            <span class="tok-kw">if</span> (decoded[i] != encoded[j]) <span class="tok-kw">return</span> <span class="tok-null">false</span>;</span>
<span class="line" id="L33">            j += <span class="tok-number">1</span>;</span>
<span class="line" id="L34">            i += <span class="tok-number">1</span>;</span>
<span class="line" id="L35">        } <span class="tok-kw">else</span> {</span>
<span class="line" id="L36">            <span class="tok-kw">const</span> escape_type = encoded[j + <span class="tok-number">1</span>];</span>
<span class="line" id="L37">            <span class="tok-kw">if</span> (escape_type != <span class="tok-str">'u'</span>) {</span>
<span class="line" id="L38">                <span class="tok-kw">const</span> t: <span class="tok-type">u8</span> = <span class="tok-kw">switch</span> (escape_type) {</span>
<span class="line" id="L39">                    <span class="tok-str">'\\'</span> =&gt; <span class="tok-str">'\\'</span>,</span>
<span class="line" id="L40">                    <span class="tok-str">'/'</span> =&gt; <span class="tok-str">'/'</span>,</span>
<span class="line" id="L41">                    <span class="tok-str">'n'</span> =&gt; <span class="tok-str">'\n'</span>,</span>
<span class="line" id="L42">                    <span class="tok-str">'r'</span> =&gt; <span class="tok-str">'\r'</span>,</span>
<span class="line" id="L43">                    <span class="tok-str">'t'</span> =&gt; <span class="tok-str">'\t'</span>,</span>
<span class="line" id="L44">                    <span class="tok-str">'f'</span> =&gt; <span class="tok-number">12</span>,</span>
<span class="line" id="L45">                    <span class="tok-str">'b'</span> =&gt; <span class="tok-number">8</span>,</span>
<span class="line" id="L46">                    <span class="tok-str">'&quot;'</span> =&gt; <span class="tok-str">'&quot;'</span>,</span>
<span class="line" id="L47">                    <span class="tok-kw">else</span> =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L48">                };</span>
<span class="line" id="L49">                <span class="tok-kw">if</span> (decoded[i] != t) <span class="tok-kw">return</span> <span class="tok-null">false</span>;</span>
<span class="line" id="L50">                j += <span class="tok-number">2</span>;</span>
<span class="line" id="L51">                i += <span class="tok-number">1</span>;</span>
<span class="line" id="L52">            } <span class="tok-kw">else</span> {</span>
<span class="line" id="L53">                <span class="tok-kw">var</span> codepoint = std.fmt.parseInt(<span class="tok-type">u21</span>, encoded[j + <span class="tok-number">2</span> .. j + <span class="tok-number">6</span>], <span class="tok-number">16</span>) <span class="tok-kw">catch</span> <span class="tok-kw">unreachable</span>;</span>
<span class="line" id="L54">                j += <span class="tok-number">6</span>;</span>
<span class="line" id="L55">                <span class="tok-kw">if</span> (codepoint &gt;= <span class="tok-number">0xD800</span> <span class="tok-kw">and</span> codepoint &lt; <span class="tok-number">0xDC00</span>) {</span>
<span class="line" id="L56">                    <span class="tok-comment">// surrogate pair</span>
</span>
<span class="line" id="L57">                    assert(encoded[j] == <span class="tok-str">'\\'</span>);</span>
<span class="line" id="L58">                    assert(encoded[j + <span class="tok-number">1</span>] == <span class="tok-str">'u'</span>);</span>
<span class="line" id="L59">                    <span class="tok-kw">const</span> low_surrogate = std.fmt.parseInt(<span class="tok-type">u21</span>, encoded[j + <span class="tok-number">2</span> .. j + <span class="tok-number">6</span>], <span class="tok-number">16</span>) <span class="tok-kw">catch</span> <span class="tok-kw">unreachable</span>;</span>
<span class="line" id="L60">                    codepoint = <span class="tok-number">0x10000</span> + (((codepoint &amp; <span class="tok-number">0x03ff</span>) &lt;&lt; <span class="tok-number">10</span>) | (low_surrogate &amp; <span class="tok-number">0x03ff</span>));</span>
<span class="line" id="L61">                    j += <span class="tok-number">6</span>;</span>
<span class="line" id="L62">                }</span>
<span class="line" id="L63">                <span class="tok-kw">var</span> buf: [<span class="tok-number">4</span>]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L64">                <span class="tok-kw">const</span> len = std.unicode.utf8Encode(codepoint, &amp;buf) <span class="tok-kw">catch</span> <span class="tok-kw">unreachable</span>;</span>
<span class="line" id="L65">                <span class="tok-kw">if</span> (i + len &gt; decoded.len) <span class="tok-kw">return</span> <span class="tok-null">false</span>;</span>
<span class="line" id="L66">                <span class="tok-kw">if</span> (!mem.eql(<span class="tok-type">u8</span>, decoded[i .. i + len], buf[<span class="tok-number">0</span>..len])) <span class="tok-kw">return</span> <span class="tok-null">false</span>;</span>
<span class="line" id="L67">                i += len;</span>
<span class="line" id="L68">            }</span>
<span class="line" id="L69">        }</span>
<span class="line" id="L70">    }</span>
<span class="line" id="L71">    assert(i == decoded.len);</span>
<span class="line" id="L72">    assert(j == encoded.len);</span>
<span class="line" id="L73">    <span class="tok-kw">return</span> <span class="tok-null">true</span>;</span>
<span class="line" id="L74">}</span>
<span class="line" id="L75"></span>
<span class="line" id="L76"><span class="tok-comment">/// A single token slice into the parent string.</span></span>
<span class="line" id="L77"><span class="tok-comment">///</span></span>
<span class="line" id="L78"><span class="tok-comment">/// Use `token.slice()` on the input at the current position to get the current slice.</span></span>
<span class="line" id="L79"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> Token = <span class="tok-kw">union</span>(<span class="tok-kw">enum</span>) {</span>
<span class="line" id="L80">    ObjectBegin,</span>
<span class="line" id="L81">    ObjectEnd,</span>
<span class="line" id="L82">    ArrayBegin,</span>
<span class="line" id="L83">    ArrayEnd,</span>
<span class="line" id="L84">    String: <span class="tok-kw">struct</span> {</span>
<span class="line" id="L85">        <span class="tok-comment">/// How many bytes the token is.</span></span>
<span class="line" id="L86">        count: <span class="tok-type">usize</span>,</span>
<span class="line" id="L87"></span>
<span class="line" id="L88">        <span class="tok-comment">/// Whether string contains an escape sequence and cannot be zero-copied</span></span>
<span class="line" id="L89">        escapes: StringEscapes,</span>
<span class="line" id="L90"></span>
<span class="line" id="L91">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">decodedLength</span>(self: <span class="tok-builtin">@This</span>()) <span class="tok-type">usize</span> {</span>
<span class="line" id="L92">            <span class="tok-kw">return</span> self.count +% <span class="tok-kw">switch</span> (self.escapes) {</span>
<span class="line" id="L93">                .None =&gt; <span class="tok-number">0</span>,</span>
<span class="line" id="L94">                .Some =&gt; |s| <span class="tok-builtin">@bitCast</span>(<span class="tok-type">usize</span>, s.size_diff),</span>
<span class="line" id="L95">            };</span>
<span class="line" id="L96">        }</span>
<span class="line" id="L97"></span>
<span class="line" id="L98">        <span class="tok-comment">/// Slice into the underlying input string.</span></span>
<span class="line" id="L99">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">slice</span>(self: <span class="tok-builtin">@This</span>(), input: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>, i: <span class="tok-type">usize</span>) []<span class="tok-kw">const</span> <span class="tok-type">u8</span> {</span>
<span class="line" id="L100">            <span class="tok-kw">return</span> input[i - self.count .. i];</span>
<span class="line" id="L101">        }</span>
<span class="line" id="L102">    },</span>
<span class="line" id="L103">    Number: <span class="tok-kw">struct</span> {</span>
<span class="line" id="L104">        <span class="tok-comment">/// How many bytes the token is.</span></span>
<span class="line" id="L105">        count: <span class="tok-type">usize</span>,</span>
<span class="line" id="L106"></span>
<span class="line" id="L107">        <span class="tok-comment">/// Whether number is simple and can be represented by an integer (i.e. no `.` or `e`)</span></span>
<span class="line" id="L108">        is_integer: <span class="tok-type">bool</span>,</span>
<span class="line" id="L109"></span>
<span class="line" id="L110">        <span class="tok-comment">/// Slice into the underlying input string.</span></span>
<span class="line" id="L111">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">slice</span>(self: <span class="tok-builtin">@This</span>(), input: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>, i: <span class="tok-type">usize</span>) []<span class="tok-kw">const</span> <span class="tok-type">u8</span> {</span>
<span class="line" id="L112">            <span class="tok-kw">return</span> input[i - self.count .. i];</span>
<span class="line" id="L113">        }</span>
<span class="line" id="L114">    },</span>
<span class="line" id="L115">    True,</span>
<span class="line" id="L116">    False,</span>
<span class="line" id="L117">    Null,</span>
<span class="line" id="L118">};</span>
<span class="line" id="L119"></span>
<span class="line" id="L120"><span class="tok-kw">const</span> AggregateContainerType = <span class="tok-kw">enum</span>(<span class="tok-type">u1</span>) { object, array };</span>
<span class="line" id="L121"></span>
<span class="line" id="L122"><span class="tok-comment">// A LIFO bit-stack. Tracks which container-types have been entered during parse.</span>
</span>
<span class="line" id="L123"><span class="tok-kw">fn</span> <span class="tok-fn">AggregateContainerStack</span>(<span class="tok-kw">comptime</span> n: <span class="tok-type">usize</span>) <span class="tok-type">type</span> {</span>
<span class="line" id="L124">    <span class="tok-kw">return</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L125">        <span class="tok-kw">const</span> Self = <span class="tok-builtin">@This</span>();</span>
<span class="line" id="L126"></span>
<span class="line" id="L127">        <span class="tok-kw">const</span> element_bitcount = <span class="tok-number">8</span> * <span class="tok-builtin">@sizeOf</span>(<span class="tok-type">usize</span>);</span>
<span class="line" id="L128">        <span class="tok-kw">const</span> element_count = n / element_bitcount;</span>
<span class="line" id="L129">        <span class="tok-kw">const</span> ElementType = <span class="tok-builtin">@Type</span>(.{ .Int = .{ .signedness = .unsigned, .bits = element_bitcount } });</span>
<span class="line" id="L130">        <span class="tok-kw">const</span> ElementShiftAmountType = std.math.Log2Int(ElementType);</span>
<span class="line" id="L131"></span>
<span class="line" id="L132">        <span class="tok-kw">comptime</span> {</span>
<span class="line" id="L133">            std.debug.assert(n % element_bitcount == <span class="tok-number">0</span>);</span>
<span class="line" id="L134">        }</span>
<span class="line" id="L135"></span>
<span class="line" id="L136">        memory: [element_count]ElementType,</span>
<span class="line" id="L137">        len: <span class="tok-type">usize</span>,</span>
<span class="line" id="L138"></span>
<span class="line" id="L139">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">init</span>(self: *Self) <span class="tok-type">void</span> {</span>
<span class="line" id="L140">            self.memory = [_]ElementType{<span class="tok-number">0</span>} ** element_count;</span>
<span class="line" id="L141">            self.len = <span class="tok-number">0</span>;</span>
<span class="line" id="L142">        }</span>
<span class="line" id="L143"></span>
<span class="line" id="L144">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">push</span>(self: *Self, ty: AggregateContainerType) ?<span class="tok-type">void</span> {</span>
<span class="line" id="L145">            <span class="tok-kw">if</span> (self.len &gt;= n) {</span>
<span class="line" id="L146">                <span class="tok-kw">return</span> <span class="tok-null">null</span>;</span>
<span class="line" id="L147">            }</span>
<span class="line" id="L148"></span>
<span class="line" id="L149">            <span class="tok-kw">const</span> index = self.len / element_bitcount;</span>
<span class="line" id="L150">            <span class="tok-kw">const</span> sub_index = <span class="tok-builtin">@intCast</span>(ElementShiftAmountType, self.len % element_bitcount);</span>
<span class="line" id="L151">            <span class="tok-kw">const</span> clear_mask = ~(<span class="tok-builtin">@as</span>(ElementType, <span class="tok-number">1</span>) &lt;&lt; sub_index);</span>
<span class="line" id="L152">            <span class="tok-kw">const</span> set_bits = <span class="tok-builtin">@as</span>(ElementType, <span class="tok-builtin">@enumToInt</span>(ty)) &lt;&lt; sub_index;</span>
<span class="line" id="L153"></span>
<span class="line" id="L154">            self.memory[index] &amp;= clear_mask;</span>
<span class="line" id="L155">            self.memory[index] |= set_bits;</span>
<span class="line" id="L156">            self.len += <span class="tok-number">1</span>;</span>
<span class="line" id="L157">        }</span>
<span class="line" id="L158"></span>
<span class="line" id="L159">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">peek</span>(self: *Self) ?AggregateContainerType {</span>
<span class="line" id="L160">            <span class="tok-kw">if</span> (self.len == <span class="tok-number">0</span>) {</span>
<span class="line" id="L161">                <span class="tok-kw">return</span> <span class="tok-null">null</span>;</span>
<span class="line" id="L162">            }</span>
<span class="line" id="L163"></span>
<span class="line" id="L164">            <span class="tok-kw">const</span> bit_to_extract = self.len - <span class="tok-number">1</span>;</span>
<span class="line" id="L165">            <span class="tok-kw">const</span> index = bit_to_extract / element_bitcount;</span>
<span class="line" id="L166">            <span class="tok-kw">const</span> sub_index = <span class="tok-builtin">@intCast</span>(ElementShiftAmountType, bit_to_extract % element_bitcount);</span>
<span class="line" id="L167">            <span class="tok-kw">const</span> bit = <span class="tok-builtin">@intCast</span>(<span class="tok-type">u1</span>, (self.memory[index] &gt;&gt; sub_index) &amp; <span class="tok-number">1</span>);</span>
<span class="line" id="L168">            <span class="tok-kw">return</span> <span class="tok-builtin">@intToEnum</span>(AggregateContainerType, bit);</span>
<span class="line" id="L169">        }</span>
<span class="line" id="L170"></span>
<span class="line" id="L171">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">pop</span>(self: *Self) ?AggregateContainerType {</span>
<span class="line" id="L172">            <span class="tok-kw">if</span> (self.peek()) |ty| {</span>
<span class="line" id="L173">                self.len -= <span class="tok-number">1</span>;</span>
<span class="line" id="L174">                <span class="tok-kw">return</span> ty;</span>
<span class="line" id="L175">            }</span>
<span class="line" id="L176"></span>
<span class="line" id="L177">            <span class="tok-kw">return</span> <span class="tok-null">null</span>;</span>
<span class="line" id="L178">        }</span>
<span class="line" id="L179">    };</span>
<span class="line" id="L180">}</span>
<span class="line" id="L181"></span>
<span class="line" id="L182"><span class="tok-comment">/// A small streaming JSON parser. This accepts input one byte at a time and returns tokens as</span></span>
<span class="line" id="L183"><span class="tok-comment">/// they are encountered. No copies or allocations are performed during parsing and the entire</span></span>
<span class="line" id="L184"><span class="tok-comment">/// parsing state requires ~40-50 bytes of stack space.</span></span>
<span class="line" id="L185"><span class="tok-comment">///</span></span>
<span class="line" id="L186"><span class="tok-comment">/// Conforms strictly to RFC8259.</span></span>
<span class="line" id="L187"><span class="tok-comment">///</span></span>
<span class="line" id="L188"><span class="tok-comment">/// For a non-byte based wrapper, consider using TokenStream instead.</span></span>
<span class="line" id="L189"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> StreamingParser = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L190">    <span class="tok-kw">const</span> default_max_nestings = <span class="tok-number">256</span>;</span>
<span class="line" id="L191"></span>
<span class="line" id="L192">    <span class="tok-comment">// Current state</span>
</span>
<span class="line" id="L193">    state: State,</span>
<span class="line" id="L194">    <span class="tok-comment">// How many bytes we have counted for the current token</span>
</span>
<span class="line" id="L195">    count: <span class="tok-type">usize</span>,</span>
<span class="line" id="L196">    <span class="tok-comment">// What state to follow after parsing a string (either property or value string)</span>
</span>
<span class="line" id="L197">    after_string_state: State,</span>
<span class="line" id="L198">    <span class="tok-comment">// What state to follow after parsing a value (either top-level or value end)</span>
</span>
<span class="line" id="L199">    after_value_state: State,</span>
<span class="line" id="L200">    <span class="tok-comment">// If we stopped now, would the complete parsed string to now be a valid json string</span>
</span>
<span class="line" id="L201">    complete: <span class="tok-type">bool</span>,</span>
<span class="line" id="L202">    <span class="tok-comment">// Current token flags to pass through to the next generated, see Token.</span>
</span>
<span class="line" id="L203">    string_escapes: StringEscapes,</span>
<span class="line" id="L204">    <span class="tok-comment">// When in .String states, was the previous character a high surrogate?</span>
</span>
<span class="line" id="L205">    string_last_was_high_surrogate: <span class="tok-type">bool</span>,</span>
<span class="line" id="L206">    <span class="tok-comment">// Used inside of StringEscapeHexUnicode* states</span>
</span>
<span class="line" id="L207">    string_unicode_codepoint: <span class="tok-type">u21</span>,</span>
<span class="line" id="L208">    <span class="tok-comment">// The first byte needs to be stored to validate 3- and 4-byte sequences.</span>
</span>
<span class="line" id="L209">    sequence_first_byte: <span class="tok-type">u8</span> = <span class="tok-null">undefined</span>,</span>
<span class="line" id="L210">    <span class="tok-comment">// When in .Number states, is the number a (still) valid integer?</span>
</span>
<span class="line" id="L211">    number_is_integer: <span class="tok-type">bool</span>,</span>
<span class="line" id="L212">    <span class="tok-comment">// Bit-stack for nested object/map literals (max 256 nestings).</span>
</span>
<span class="line" id="L213">    stack: AggregateContainerStack(default_max_nestings),</span>
<span class="line" id="L214"></span>
<span class="line" id="L215">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">init</span>() StreamingParser {</span>
<span class="line" id="L216">        <span class="tok-kw">var</span> p: StreamingParser = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L217">        p.reset();</span>
<span class="line" id="L218">        <span class="tok-kw">return</span> p;</span>
<span class="line" id="L219">    }</span>
<span class="line" id="L220"></span>
<span class="line" id="L221">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">reset</span>(p: *StreamingParser) <span class="tok-type">void</span> {</span>
<span class="line" id="L222">        p.state = .TopLevelBegin;</span>
<span class="line" id="L223">        p.count = <span class="tok-number">0</span>;</span>
<span class="line" id="L224">        <span class="tok-comment">// Set before ever read in main transition function</span>
</span>
<span class="line" id="L225">        p.after_string_state = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L226">        p.after_value_state = .ValueEnd; <span class="tok-comment">// handle end of values normally</span>
</span>
<span class="line" id="L227">        p.stack.init();</span>
<span class="line" id="L228">        p.complete = <span class="tok-null">false</span>;</span>
<span class="line" id="L229">        p.string_escapes = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L230">        p.string_last_was_high_surrogate = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L231">        p.string_unicode_codepoint = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L232">        p.number_is_integer = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L233">    }</span>
<span class="line" id="L234"></span>
<span class="line" id="L235">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> State = <span class="tok-kw">enum</span>(<span class="tok-type">u8</span>) {</span>
<span class="line" id="L236">        <span class="tok-comment">// These must be first with these explicit values as we rely on them for indexing the</span>
</span>
<span class="line" id="L237">        <span class="tok-comment">// bit-stack directly and avoiding a branch.</span>
</span>
<span class="line" id="L238">        ObjectSeparator = <span class="tok-number">0</span>,</span>
<span class="line" id="L239">        ValueEnd = <span class="tok-number">1</span>,</span>
<span class="line" id="L240"></span>
<span class="line" id="L241">        TopLevelBegin,</span>
<span class="line" id="L242">        TopLevelEnd,</span>
<span class="line" id="L243"></span>
<span class="line" id="L244">        ValueBegin,</span>
<span class="line" id="L245">        ValueBeginNoClosing,</span>
<span class="line" id="L246"></span>
<span class="line" id="L247">        String,</span>
<span class="line" id="L248">        StringUtf8Byte2Of2,</span>
<span class="line" id="L249">        StringUtf8Byte2Of3,</span>
<span class="line" id="L250">        StringUtf8Byte3Of3,</span>
<span class="line" id="L251">        StringUtf8Byte2Of4,</span>
<span class="line" id="L252">        StringUtf8Byte3Of4,</span>
<span class="line" id="L253">        StringUtf8Byte4Of4,</span>
<span class="line" id="L254">        StringEscapeCharacter,</span>
<span class="line" id="L255">        StringEscapeHexUnicode4,</span>
<span class="line" id="L256">        StringEscapeHexUnicode3,</span>
<span class="line" id="L257">        StringEscapeHexUnicode2,</span>
<span class="line" id="L258">        StringEscapeHexUnicode1,</span>
<span class="line" id="L259"></span>
<span class="line" id="L260">        Number,</span>
<span class="line" id="L261">        NumberMaybeDotOrExponent,</span>
<span class="line" id="L262">        NumberMaybeDigitOrDotOrExponent,</span>
<span class="line" id="L263">        NumberFractionalRequired,</span>
<span class="line" id="L264">        NumberFractional,</span>
<span class="line" id="L265">        NumberMaybeExponent,</span>
<span class="line" id="L266">        NumberExponent,</span>
<span class="line" id="L267">        NumberExponentDigitsRequired,</span>
<span class="line" id="L268">        NumberExponentDigits,</span>
<span class="line" id="L269"></span>
<span class="line" id="L270">        TrueLiteral1,</span>
<span class="line" id="L271">        TrueLiteral2,</span>
<span class="line" id="L272">        TrueLiteral3,</span>
<span class="line" id="L273"></span>
<span class="line" id="L274">        FalseLiteral1,</span>
<span class="line" id="L275">        FalseLiteral2,</span>
<span class="line" id="L276">        FalseLiteral3,</span>
<span class="line" id="L277">        FalseLiteral4,</span>
<span class="line" id="L278"></span>
<span class="line" id="L279">        NullLiteral1,</span>
<span class="line" id="L280">        NullLiteral2,</span>
<span class="line" id="L281">        NullLiteral3,</span>
<span class="line" id="L282"></span>
<span class="line" id="L283">        <span class="tok-comment">// Given an aggregate container type, return the state which should be entered after</span>
</span>
<span class="line" id="L284">        <span class="tok-comment">// processing a complete value type.</span>
</span>
<span class="line" id="L285">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">fromAggregateContainerType</span>(ty: AggregateContainerType) State {</span>
<span class="line" id="L286">            <span class="tok-kw">comptime</span> {</span>
<span class="line" id="L287">                std.debug.assert(<span class="tok-builtin">@enumToInt</span>(AggregateContainerType.object) == <span class="tok-builtin">@enumToInt</span>(State.ObjectSeparator));</span>
<span class="line" id="L288">                std.debug.assert(<span class="tok-builtin">@enumToInt</span>(AggregateContainerType.array) == <span class="tok-builtin">@enumToInt</span>(State.ValueEnd));</span>
<span class="line" id="L289">            }</span>
<span class="line" id="L290"></span>
<span class="line" id="L291">            <span class="tok-kw">return</span> <span class="tok-builtin">@intToEnum</span>(State, <span class="tok-builtin">@enumToInt</span>(ty));</span>
<span class="line" id="L292">        }</span>
<span class="line" id="L293">    };</span>
<span class="line" id="L294"></span>
<span class="line" id="L295">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> Error = <span class="tok-kw">error</span>{</span>
<span class="line" id="L296">        InvalidTopLevel,</span>
<span class="line" id="L297">        TooManyNestedItems,</span>
<span class="line" id="L298">        TooManyClosingItems,</span>
<span class="line" id="L299">        InvalidValueBegin,</span>
<span class="line" id="L300">        InvalidValueEnd,</span>
<span class="line" id="L301">        UnbalancedBrackets,</span>
<span class="line" id="L302">        UnbalancedBraces,</span>
<span class="line" id="L303">        UnexpectedClosingBracket,</span>
<span class="line" id="L304">        UnexpectedClosingBrace,</span>
<span class="line" id="L305">        InvalidNumber,</span>
<span class="line" id="L306">        InvalidSeparator,</span>
<span class="line" id="L307">        InvalidLiteral,</span>
<span class="line" id="L308">        InvalidEscapeCharacter,</span>
<span class="line" id="L309">        InvalidUnicodeHexSymbol,</span>
<span class="line" id="L310">        InvalidUtf8Byte,</span>
<span class="line" id="L311">        InvalidTopLevelTrailing,</span>
<span class="line" id="L312">        InvalidControlCharacter,</span>
<span class="line" id="L313">    };</span>
<span class="line" id="L314"></span>
<span class="line" id="L315">    <span class="tok-comment">/// Give another byte to the parser and obtain any new tokens. This may (rarely) return two</span></span>
<span class="line" id="L316">    <span class="tok-comment">/// tokens. token2 is always null if token1 is null.</span></span>
<span class="line" id="L317">    <span class="tok-comment">///</span></span>
<span class="line" id="L318">    <span class="tok-comment">/// There is currently no error recovery on a bad stream.</span></span>
<span class="line" id="L319">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">feed</span>(p: *StreamingParser, c: <span class="tok-type">u8</span>, token1: *?Token, token2: *?Token) Error!<span class="tok-type">void</span> {</span>
<span class="line" id="L320">        token1.* = <span class="tok-null">null</span>;</span>
<span class="line" id="L321">        token2.* = <span class="tok-null">null</span>;</span>
<span class="line" id="L322">        p.count += <span class="tok-number">1</span>;</span>
<span class="line" id="L323"></span>
<span class="line" id="L324">        <span class="tok-comment">// unlikely</span>
</span>
<span class="line" id="L325">        <span class="tok-kw">if</span> (<span class="tok-kw">try</span> p.transition(c, token1)) {</span>
<span class="line" id="L326">            _ = <span class="tok-kw">try</span> p.transition(c, token2);</span>
<span class="line" id="L327">        }</span>
<span class="line" id="L328">    }</span>
<span class="line" id="L329"></span>
<span class="line" id="L330">    <span class="tok-comment">// Perform a single transition on the state machine and return any possible token.</span>
</span>
<span class="line" id="L331">    <span class="tok-kw">fn</span> <span class="tok-fn">transition</span>(p: *StreamingParser, c: <span class="tok-type">u8</span>, token: *?Token) Error!<span class="tok-type">bool</span> {</span>
<span class="line" id="L332">        <span class="tok-kw">switch</span> (p.state) {</span>
<span class="line" id="L333">            .TopLevelBegin =&gt; <span class="tok-kw">switch</span> (c) {</span>
<span class="line" id="L334">                <span class="tok-str">'{'</span> =&gt; {</span>
<span class="line" id="L335">                    p.stack.push(.object) <span class="tok-kw">orelse</span> <span class="tok-kw">return</span> <span class="tok-kw">error</span>.TooManyNestedItems;</span>
<span class="line" id="L336">                    p.state = .ValueBegin;</span>
<span class="line" id="L337">                    p.after_string_state = .ObjectSeparator;</span>
<span class="line" id="L338"></span>
<span class="line" id="L339">                    token.* = Token.ObjectBegin;</span>
<span class="line" id="L340">                },</span>
<span class="line" id="L341">                <span class="tok-str">'['</span> =&gt; {</span>
<span class="line" id="L342">                    p.stack.push(.array) <span class="tok-kw">orelse</span> <span class="tok-kw">return</span> <span class="tok-kw">error</span>.TooManyNestedItems;</span>
<span class="line" id="L343">                    p.state = .ValueBegin;</span>
<span class="line" id="L344">                    p.after_string_state = .ValueEnd;</span>
<span class="line" id="L345"></span>
<span class="line" id="L346">                    token.* = Token.ArrayBegin;</span>
<span class="line" id="L347">                },</span>
<span class="line" id="L348">                <span class="tok-str">'-'</span> =&gt; {</span>
<span class="line" id="L349">                    p.number_is_integer = <span class="tok-null">true</span>;</span>
<span class="line" id="L350">                    p.state = .Number;</span>
<span class="line" id="L351">                    p.after_value_state = .TopLevelEnd;</span>
<span class="line" id="L352">                    p.count = <span class="tok-number">0</span>;</span>
<span class="line" id="L353">                },</span>
<span class="line" id="L354">                <span class="tok-str">'0'</span> =&gt; {</span>
<span class="line" id="L355">                    p.number_is_integer = <span class="tok-null">true</span>;</span>
<span class="line" id="L356">                    p.state = .NumberMaybeDotOrExponent;</span>
<span class="line" id="L357">                    p.after_value_state = .TopLevelEnd;</span>
<span class="line" id="L358">                    p.count = <span class="tok-number">0</span>;</span>
<span class="line" id="L359">                },</span>
<span class="line" id="L360">                <span class="tok-str">'1'</span>...<span class="tok-str">'9'</span> =&gt; {</span>
<span class="line" id="L361">                    p.number_is_integer = <span class="tok-null">true</span>;</span>
<span class="line" id="L362">                    p.state = .NumberMaybeDigitOrDotOrExponent;</span>
<span class="line" id="L363">                    p.after_value_state = .TopLevelEnd;</span>
<span class="line" id="L364">                    p.count = <span class="tok-number">0</span>;</span>
<span class="line" id="L365">                },</span>
<span class="line" id="L366">                <span class="tok-str">'&quot;'</span> =&gt; {</span>
<span class="line" id="L367">                    p.state = .String;</span>
<span class="line" id="L368">                    p.after_value_state = .TopLevelEnd;</span>
<span class="line" id="L369">                    <span class="tok-comment">// We don't actually need the following since after_value_state should override.</span>
</span>
<span class="line" id="L370">                    p.after_string_state = .ValueEnd;</span>
<span class="line" id="L371">                    p.string_escapes = .None;</span>
<span class="line" id="L372">                    p.string_last_was_high_surrogate = <span class="tok-null">false</span>;</span>
<span class="line" id="L373">                    p.count = <span class="tok-number">0</span>;</span>
<span class="line" id="L374">                },</span>
<span class="line" id="L375">                <span class="tok-str">'t'</span> =&gt; {</span>
<span class="line" id="L376">                    p.state = .TrueLiteral1;</span>
<span class="line" id="L377">                    p.after_value_state = .TopLevelEnd;</span>
<span class="line" id="L378">                    p.count = <span class="tok-number">0</span>;</span>
<span class="line" id="L379">                },</span>
<span class="line" id="L380">                <span class="tok-str">'f'</span> =&gt; {</span>
<span class="line" id="L381">                    p.state = .FalseLiteral1;</span>
<span class="line" id="L382">                    p.after_value_state = .TopLevelEnd;</span>
<span class="line" id="L383">                    p.count = <span class="tok-number">0</span>;</span>
<span class="line" id="L384">                },</span>
<span class="line" id="L385">                <span class="tok-str">'n'</span> =&gt; {</span>
<span class="line" id="L386">                    p.state = .NullLiteral1;</span>
<span class="line" id="L387">                    p.after_value_state = .TopLevelEnd;</span>
<span class="line" id="L388">                    p.count = <span class="tok-number">0</span>;</span>
<span class="line" id="L389">                },</span>
<span class="line" id="L390">                <span class="tok-number">0x09</span>, <span class="tok-number">0x0A</span>, <span class="tok-number">0x0D</span>, <span class="tok-number">0x20</span> =&gt; {</span>
<span class="line" id="L391">                    <span class="tok-comment">// whitespace</span>
</span>
<span class="line" id="L392">                },</span>
<span class="line" id="L393">                <span class="tok-kw">else</span> =&gt; {</span>
<span class="line" id="L394">                    <span class="tok-kw">return</span> <span class="tok-kw">error</span>.InvalidTopLevel;</span>
<span class="line" id="L395">                },</span>
<span class="line" id="L396">            },</span>
<span class="line" id="L397"></span>
<span class="line" id="L398">            .TopLevelEnd =&gt; <span class="tok-kw">switch</span> (c) {</span>
<span class="line" id="L399">                <span class="tok-number">0x09</span>, <span class="tok-number">0x0A</span>, <span class="tok-number">0x0D</span>, <span class="tok-number">0x20</span> =&gt; {</span>
<span class="line" id="L400">                    <span class="tok-comment">// whitespace</span>
</span>
<span class="line" id="L401">                },</span>
<span class="line" id="L402">                <span class="tok-kw">else</span> =&gt; {</span>
<span class="line" id="L403">                    <span class="tok-kw">return</span> <span class="tok-kw">error</span>.InvalidTopLevelTrailing;</span>
<span class="line" id="L404">                },</span>
<span class="line" id="L405">            },</span>
<span class="line" id="L406"></span>
<span class="line" id="L407">            .ValueBegin =&gt; <span class="tok-kw">switch</span> (c) {</span>
<span class="line" id="L408">                <span class="tok-comment">// NOTE: These are shared in ValueEnd as well, think we can reorder states to</span>
</span>
<span class="line" id="L409">                <span class="tok-comment">// be a bit clearer and avoid this duplication.</span>
</span>
<span class="line" id="L410">                <span class="tok-str">'}'</span> =&gt; {</span>
<span class="line" id="L411">                    <span class="tok-kw">const</span> last_type = p.stack.peek() <span class="tok-kw">orelse</span> <span class="tok-kw">return</span> <span class="tok-kw">error</span>.TooManyClosingItems;</span>
<span class="line" id="L412"></span>
<span class="line" id="L413">                    <span class="tok-kw">if</span> (last_type != .object) {</span>
<span class="line" id="L414">                        <span class="tok-kw">return</span> <span class="tok-kw">error</span>.UnexpectedClosingBrace;</span>
<span class="line" id="L415">                    }</span>
<span class="line" id="L416"></span>
<span class="line" id="L417">                    _ = p.stack.pop();</span>
<span class="line" id="L418">                    p.state = .ValueBegin;</span>
<span class="line" id="L419">                    p.after_string_state = State.fromAggregateContainerType(last_type);</span>
<span class="line" id="L420"></span>
<span class="line" id="L421">                    <span class="tok-kw">switch</span> (p.stack.len) {</span>
<span class="line" id="L422">                        <span class="tok-number">0</span> =&gt; {</span>
<span class="line" id="L423">                            p.complete = <span class="tok-null">true</span>;</span>
<span class="line" id="L424">                            p.state = .TopLevelEnd;</span>
<span class="line" id="L425">                        },</span>
<span class="line" id="L426">                        <span class="tok-kw">else</span> =&gt; {</span>
<span class="line" id="L427">                            p.state = .ValueEnd;</span>
<span class="line" id="L428">                        },</span>
<span class="line" id="L429">                    }</span>
<span class="line" id="L430"></span>
<span class="line" id="L431">                    token.* = Token.ObjectEnd;</span>
<span class="line" id="L432">                },</span>
<span class="line" id="L433">                <span class="tok-str">']'</span> =&gt; {</span>
<span class="line" id="L434">                    <span class="tok-kw">const</span> last_type = p.stack.peek() <span class="tok-kw">orelse</span> <span class="tok-kw">return</span> <span class="tok-kw">error</span>.TooManyClosingItems;</span>
<span class="line" id="L435"></span>
<span class="line" id="L436">                    <span class="tok-kw">if</span> (last_type != .array) {</span>
<span class="line" id="L437">                        <span class="tok-kw">return</span> <span class="tok-kw">error</span>.UnexpectedClosingBracket;</span>
<span class="line" id="L438">                    }</span>
<span class="line" id="L439"></span>
<span class="line" id="L440">                    _ = p.stack.pop();</span>
<span class="line" id="L441">                    p.state = .ValueBegin;</span>
<span class="line" id="L442">                    p.after_string_state = State.fromAggregateContainerType(last_type);</span>
<span class="line" id="L443"></span>
<span class="line" id="L444">                    <span class="tok-kw">switch</span> (p.stack.len) {</span>
<span class="line" id="L445">                        <span class="tok-number">0</span> =&gt; {</span>
<span class="line" id="L446">                            p.complete = <span class="tok-null">true</span>;</span>
<span class="line" id="L447">                            p.state = .TopLevelEnd;</span>
<span class="line" id="L448">                        },</span>
<span class="line" id="L449">                        <span class="tok-kw">else</span> =&gt; {</span>
<span class="line" id="L450">                            p.state = .ValueEnd;</span>
<span class="line" id="L451">                        },</span>
<span class="line" id="L452">                    }</span>
<span class="line" id="L453"></span>
<span class="line" id="L454">                    token.* = Token.ArrayEnd;</span>
<span class="line" id="L455">                },</span>
<span class="line" id="L456">                <span class="tok-str">'{'</span> =&gt; {</span>
<span class="line" id="L457">                    p.stack.push(.object) <span class="tok-kw">orelse</span> <span class="tok-kw">return</span> <span class="tok-kw">error</span>.TooManyNestedItems;</span>
<span class="line" id="L458"></span>
<span class="line" id="L459">                    p.state = .ValueBegin;</span>
<span class="line" id="L460">                    p.after_string_state = .ObjectSeparator;</span>
<span class="line" id="L461"></span>
<span class="line" id="L462">                    token.* = Token.ObjectBegin;</span>
<span class="line" id="L463">                },</span>
<span class="line" id="L464">                <span class="tok-str">'['</span> =&gt; {</span>
<span class="line" id="L465">                    p.stack.push(.array) <span class="tok-kw">orelse</span> <span class="tok-kw">return</span> <span class="tok-kw">error</span>.TooManyNestedItems;</span>
<span class="line" id="L466"></span>
<span class="line" id="L467">                    p.state = .ValueBegin;</span>
<span class="line" id="L468">                    p.after_string_state = .ValueEnd;</span>
<span class="line" id="L469"></span>
<span class="line" id="L470">                    token.* = Token.ArrayBegin;</span>
<span class="line" id="L471">                },</span>
<span class="line" id="L472">                <span class="tok-str">'-'</span> =&gt; {</span>
<span class="line" id="L473">                    p.number_is_integer = <span class="tok-null">true</span>;</span>
<span class="line" id="L474">                    p.state = .Number;</span>
<span class="line" id="L475">                    p.count = <span class="tok-number">0</span>;</span>
<span class="line" id="L476">                },</span>
<span class="line" id="L477">                <span class="tok-str">'0'</span> =&gt; {</span>
<span class="line" id="L478">                    p.number_is_integer = <span class="tok-null">true</span>;</span>
<span class="line" id="L479">                    p.state = .NumberMaybeDotOrExponent;</span>
<span class="line" id="L480">                    p.count = <span class="tok-number">0</span>;</span>
<span class="line" id="L481">                },</span>
<span class="line" id="L482">                <span class="tok-str">'1'</span>...<span class="tok-str">'9'</span> =&gt; {</span>
<span class="line" id="L483">                    p.number_is_integer = <span class="tok-null">true</span>;</span>
<span class="line" id="L484">                    p.state = .NumberMaybeDigitOrDotOrExponent;</span>
<span class="line" id="L485">                    p.count = <span class="tok-number">0</span>;</span>
<span class="line" id="L486">                },</span>
<span class="line" id="L487">                <span class="tok-str">'&quot;'</span> =&gt; {</span>
<span class="line" id="L488">                    p.state = .String;</span>
<span class="line" id="L489">                    p.string_escapes = .None;</span>
<span class="line" id="L490">                    p.string_last_was_high_surrogate = <span class="tok-null">false</span>;</span>
<span class="line" id="L491">                    p.count = <span class="tok-number">0</span>;</span>
<span class="line" id="L492">                },</span>
<span class="line" id="L493">                <span class="tok-str">'t'</span> =&gt; {</span>
<span class="line" id="L494">                    p.state = .TrueLiteral1;</span>
<span class="line" id="L495">                    p.count = <span class="tok-number">0</span>;</span>
<span class="line" id="L496">                },</span>
<span class="line" id="L497">                <span class="tok-str">'f'</span> =&gt; {</span>
<span class="line" id="L498">                    p.state = .FalseLiteral1;</span>
<span class="line" id="L499">                    p.count = <span class="tok-number">0</span>;</span>
<span class="line" id="L500">                },</span>
<span class="line" id="L501">                <span class="tok-str">'n'</span> =&gt; {</span>
<span class="line" id="L502">                    p.state = .NullLiteral1;</span>
<span class="line" id="L503">                    p.count = <span class="tok-number">0</span>;</span>
<span class="line" id="L504">                },</span>
<span class="line" id="L505">                <span class="tok-number">0x09</span>, <span class="tok-number">0x0A</span>, <span class="tok-number">0x0D</span>, <span class="tok-number">0x20</span> =&gt; {</span>
<span class="line" id="L506">                    <span class="tok-comment">// whitespace</span>
</span>
<span class="line" id="L507">                },</span>
<span class="line" id="L508">                <span class="tok-kw">else</span> =&gt; {</span>
<span class="line" id="L509">                    <span class="tok-kw">return</span> <span class="tok-kw">error</span>.InvalidValueBegin;</span>
<span class="line" id="L510">                },</span>
<span class="line" id="L511">            },</span>
<span class="line" id="L512"></span>
<span class="line" id="L513">            <span class="tok-comment">// TODO: A bit of duplication here and in the following state, redo.</span>
</span>
<span class="line" id="L514">            .ValueBeginNoClosing =&gt; <span class="tok-kw">switch</span> (c) {</span>
<span class="line" id="L515">                <span class="tok-str">'{'</span> =&gt; {</span>
<span class="line" id="L516">                    p.stack.push(.object) <span class="tok-kw">orelse</span> <span class="tok-kw">return</span> <span class="tok-kw">error</span>.TooManyNestedItems;</span>
<span class="line" id="L517"></span>
<span class="line" id="L518">                    p.state = .ValueBegin;</span>
<span class="line" id="L519">                    p.after_string_state = .ObjectSeparator;</span>
<span class="line" id="L520"></span>
<span class="line" id="L521">                    token.* = Token.ObjectBegin;</span>
<span class="line" id="L522">                },</span>
<span class="line" id="L523">                <span class="tok-str">'['</span> =&gt; {</span>
<span class="line" id="L524">                    p.stack.push(.array) <span class="tok-kw">orelse</span> <span class="tok-kw">return</span> <span class="tok-kw">error</span>.TooManyNestedItems;</span>
<span class="line" id="L525"></span>
<span class="line" id="L526">                    p.state = .ValueBegin;</span>
<span class="line" id="L527">                    p.after_string_state = .ValueEnd;</span>
<span class="line" id="L528"></span>
<span class="line" id="L529">                    token.* = Token.ArrayBegin;</span>
<span class="line" id="L530">                },</span>
<span class="line" id="L531">                <span class="tok-str">'-'</span> =&gt; {</span>
<span class="line" id="L532">                    p.number_is_integer = <span class="tok-null">true</span>;</span>
<span class="line" id="L533">                    p.state = .Number;</span>
<span class="line" id="L534">                    p.count = <span class="tok-number">0</span>;</span>
<span class="line" id="L535">                },</span>
<span class="line" id="L536">                <span class="tok-str">'0'</span> =&gt; {</span>
<span class="line" id="L537">                    p.number_is_integer = <span class="tok-null">true</span>;</span>
<span class="line" id="L538">                    p.state = .NumberMaybeDotOrExponent;</span>
<span class="line" id="L539">                    p.count = <span class="tok-number">0</span>;</span>
<span class="line" id="L540">                },</span>
<span class="line" id="L541">                <span class="tok-str">'1'</span>...<span class="tok-str">'9'</span> =&gt; {</span>
<span class="line" id="L542">                    p.number_is_integer = <span class="tok-null">true</span>;</span>
<span class="line" id="L543">                    p.state = .NumberMaybeDigitOrDotOrExponent;</span>
<span class="line" id="L544">                    p.count = <span class="tok-number">0</span>;</span>
<span class="line" id="L545">                },</span>
<span class="line" id="L546">                <span class="tok-str">'&quot;'</span> =&gt; {</span>
<span class="line" id="L547">                    p.state = .String;</span>
<span class="line" id="L548">                    p.string_escapes = .None;</span>
<span class="line" id="L549">                    p.string_last_was_high_surrogate = <span class="tok-null">false</span>;</span>
<span class="line" id="L550">                    p.count = <span class="tok-number">0</span>;</span>
<span class="line" id="L551">                },</span>
<span class="line" id="L552">                <span class="tok-str">'t'</span> =&gt; {</span>
<span class="line" id="L553">                    p.state = .TrueLiteral1;</span>
<span class="line" id="L554">                    p.count = <span class="tok-number">0</span>;</span>
<span class="line" id="L555">                },</span>
<span class="line" id="L556">                <span class="tok-str">'f'</span> =&gt; {</span>
<span class="line" id="L557">                    p.state = .FalseLiteral1;</span>
<span class="line" id="L558">                    p.count = <span class="tok-number">0</span>;</span>
<span class="line" id="L559">                },</span>
<span class="line" id="L560">                <span class="tok-str">'n'</span> =&gt; {</span>
<span class="line" id="L561">                    p.state = .NullLiteral1;</span>
<span class="line" id="L562">                    p.count = <span class="tok-number">0</span>;</span>
<span class="line" id="L563">                },</span>
<span class="line" id="L564">                <span class="tok-number">0x09</span>, <span class="tok-number">0x0A</span>, <span class="tok-number">0x0D</span>, <span class="tok-number">0x20</span> =&gt; {</span>
<span class="line" id="L565">                    <span class="tok-comment">// whitespace</span>
</span>
<span class="line" id="L566">                },</span>
<span class="line" id="L567">                <span class="tok-kw">else</span> =&gt; {</span>
<span class="line" id="L568">                    <span class="tok-kw">return</span> <span class="tok-kw">error</span>.InvalidValueBegin;</span>
<span class="line" id="L569">                },</span>
<span class="line" id="L570">            },</span>
<span class="line" id="L571"></span>
<span class="line" id="L572">            .ValueEnd =&gt; <span class="tok-kw">switch</span> (c) {</span>
<span class="line" id="L573">                <span class="tok-str">','</span> =&gt; {</span>
<span class="line" id="L574">                    <span class="tok-kw">const</span> last_type = p.stack.peek() <span class="tok-kw">orelse</span> <span class="tok-kw">unreachable</span>;</span>
<span class="line" id="L575">                    p.after_string_state = State.fromAggregateContainerType(last_type);</span>
<span class="line" id="L576">                    p.state = .ValueBeginNoClosing;</span>
<span class="line" id="L577">                },</span>
<span class="line" id="L578">                <span class="tok-str">']'</span> =&gt; {</span>
<span class="line" id="L579">                    <span class="tok-kw">const</span> last_type = p.stack.peek() <span class="tok-kw">orelse</span> <span class="tok-kw">return</span> <span class="tok-kw">error</span>.TooManyClosingItems;</span>
<span class="line" id="L580"></span>
<span class="line" id="L581">                    <span class="tok-kw">if</span> (last_type != .array) {</span>
<span class="line" id="L582">                        <span class="tok-kw">return</span> <span class="tok-kw">error</span>.UnexpectedClosingBracket;</span>
<span class="line" id="L583">                    }</span>
<span class="line" id="L584"></span>
<span class="line" id="L585">                    _ = p.stack.pop();</span>
<span class="line" id="L586">                    p.state = .ValueEnd;</span>
<span class="line" id="L587">                    p.after_string_state = State.fromAggregateContainerType(last_type);</span>
<span class="line" id="L588"></span>
<span class="line" id="L589">                    <span class="tok-kw">if</span> (p.stack.len == <span class="tok-number">0</span>) {</span>
<span class="line" id="L590">                        p.complete = <span class="tok-null">true</span>;</span>
<span class="line" id="L591">                        p.state = .TopLevelEnd;</span>
<span class="line" id="L592">                    }</span>
<span class="line" id="L593"></span>
<span class="line" id="L594">                    token.* = Token.ArrayEnd;</span>
<span class="line" id="L595">                },</span>
<span class="line" id="L596">                <span class="tok-str">'}'</span> =&gt; {</span>
<span class="line" id="L597">                    <span class="tok-kw">const</span> last_type = p.stack.peek() <span class="tok-kw">orelse</span> <span class="tok-kw">return</span> <span class="tok-kw">error</span>.TooManyClosingItems;</span>
<span class="line" id="L598"></span>
<span class="line" id="L599">                    <span class="tok-kw">if</span> (last_type != .object) {</span>
<span class="line" id="L600">                        <span class="tok-kw">return</span> <span class="tok-kw">error</span>.UnexpectedClosingBrace;</span>
<span class="line" id="L601">                    }</span>
<span class="line" id="L602"></span>
<span class="line" id="L603">                    _ = p.stack.pop();</span>
<span class="line" id="L604">                    p.state = .ValueEnd;</span>
<span class="line" id="L605">                    p.after_string_state = State.fromAggregateContainerType(last_type);</span>
<span class="line" id="L606"></span>
<span class="line" id="L607">                    <span class="tok-kw">if</span> (p.stack.len == <span class="tok-number">0</span>) {</span>
<span class="line" id="L608">                        p.complete = <span class="tok-null">true</span>;</span>
<span class="line" id="L609">                        p.state = .TopLevelEnd;</span>
<span class="line" id="L610">                    }</span>
<span class="line" id="L611"></span>
<span class="line" id="L612">                    token.* = Token.ObjectEnd;</span>
<span class="line" id="L613">                },</span>
<span class="line" id="L614">                <span class="tok-number">0x09</span>, <span class="tok-number">0x0A</span>, <span class="tok-number">0x0D</span>, <span class="tok-number">0x20</span> =&gt; {</span>
<span class="line" id="L615">                    <span class="tok-comment">// whitespace</span>
</span>
<span class="line" id="L616">                },</span>
<span class="line" id="L617">                <span class="tok-kw">else</span> =&gt; {</span>
<span class="line" id="L618">                    <span class="tok-kw">return</span> <span class="tok-kw">error</span>.InvalidValueEnd;</span>
<span class="line" id="L619">                },</span>
<span class="line" id="L620">            },</span>
<span class="line" id="L621"></span>
<span class="line" id="L622">            .ObjectSeparator =&gt; <span class="tok-kw">switch</span> (c) {</span>
<span class="line" id="L623">                <span class="tok-str">':'</span> =&gt; {</span>
<span class="line" id="L624">                    p.state = .ValueBeginNoClosing;</span>
<span class="line" id="L625">                    p.after_string_state = .ValueEnd;</span>
<span class="line" id="L626">                },</span>
<span class="line" id="L627">                <span class="tok-number">0x09</span>, <span class="tok-number">0x0A</span>, <span class="tok-number">0x0D</span>, <span class="tok-number">0x20</span> =&gt; {</span>
<span class="line" id="L628">                    <span class="tok-comment">// whitespace</span>
</span>
<span class="line" id="L629">                },</span>
<span class="line" id="L630">                <span class="tok-kw">else</span> =&gt; {</span>
<span class="line" id="L631">                    <span class="tok-kw">return</span> <span class="tok-kw">error</span>.InvalidSeparator;</span>
<span class="line" id="L632">                },</span>
<span class="line" id="L633">            },</span>
<span class="line" id="L634"></span>
<span class="line" id="L635">            .String =&gt; <span class="tok-kw">switch</span> (c) {</span>
<span class="line" id="L636">                <span class="tok-number">0x00</span>...<span class="tok-number">0x1F</span> =&gt; {</span>
<span class="line" id="L637">                    <span class="tok-kw">return</span> <span class="tok-kw">error</span>.InvalidControlCharacter;</span>
<span class="line" id="L638">                },</span>
<span class="line" id="L639">                <span class="tok-str">'&quot;'</span> =&gt; {</span>
<span class="line" id="L640">                    p.state = p.after_string_state;</span>
<span class="line" id="L641">                    <span class="tok-kw">if</span> (p.after_value_state == .TopLevelEnd) {</span>
<span class="line" id="L642">                        p.state = .TopLevelEnd;</span>
<span class="line" id="L643">                        p.complete = <span class="tok-null">true</span>;</span>
<span class="line" id="L644">                    }</span>
<span class="line" id="L645"></span>
<span class="line" id="L646">                    token.* = .{</span>
<span class="line" id="L647">                        .String = .{</span>
<span class="line" id="L648">                            .count = p.count - <span class="tok-number">1</span>,</span>
<span class="line" id="L649">                            .escapes = p.string_escapes,</span>
<span class="line" id="L650">                        },</span>
<span class="line" id="L651">                    };</span>
<span class="line" id="L652">                    p.string_escapes = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L653">                    p.string_last_was_high_surrogate = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L654">                },</span>
<span class="line" id="L655">                <span class="tok-str">'\\'</span> =&gt; {</span>
<span class="line" id="L656">                    p.state = .StringEscapeCharacter;</span>
<span class="line" id="L657">                    <span class="tok-kw">switch</span> (p.string_escapes) {</span>
<span class="line" id="L658">                        .None =&gt; {</span>
<span class="line" id="L659">                            p.string_escapes = .{ .Some = .{ .size_diff = <span class="tok-number">0</span> } };</span>
<span class="line" id="L660">                        },</span>
<span class="line" id="L661">                        .Some =&gt; {},</span>
<span class="line" id="L662">                    }</span>
<span class="line" id="L663">                },</span>
<span class="line" id="L664">                <span class="tok-number">0x20</span>, <span class="tok-number">0x21</span>, <span class="tok-number">0x23</span>...<span class="tok-number">0x5B</span>, <span class="tok-number">0x5D</span>...<span class="tok-number">0x7F</span> =&gt; {</span>
<span class="line" id="L665">                    <span class="tok-comment">// non-control ascii</span>
</span>
<span class="line" id="L666">                    p.string_last_was_high_surrogate = <span class="tok-null">false</span>;</span>
<span class="line" id="L667">                },</span>
<span class="line" id="L668">                <span class="tok-number">0xC2</span>...<span class="tok-number">0xDF</span> =&gt; {</span>
<span class="line" id="L669">                    p.state = .StringUtf8Byte2Of2;</span>
<span class="line" id="L670">                },</span>
<span class="line" id="L671">                <span class="tok-number">0xE0</span>...<span class="tok-number">0xEF</span> =&gt; {</span>
<span class="line" id="L672">                    p.state = .StringUtf8Byte2Of3;</span>
<span class="line" id="L673">                    p.sequence_first_byte = c;</span>
<span class="line" id="L674">                },</span>
<span class="line" id="L675">                <span class="tok-number">0xF0</span>...<span class="tok-number">0xF4</span> =&gt; {</span>
<span class="line" id="L676">                    p.state = .StringUtf8Byte2Of4;</span>
<span class="line" id="L677">                    p.sequence_first_byte = c;</span>
<span class="line" id="L678">                },</span>
<span class="line" id="L679">                <span class="tok-kw">else</span> =&gt; {</span>
<span class="line" id="L680">                    <span class="tok-kw">return</span> <span class="tok-kw">error</span>.InvalidUtf8Byte;</span>
<span class="line" id="L681">                },</span>
<span class="line" id="L682">            },</span>
<span class="line" id="L683"></span>
<span class="line" id="L684">            .StringUtf8Byte2Of2 =&gt; <span class="tok-kw">switch</span> (c &gt;&gt; <span class="tok-number">6</span>) {</span>
<span class="line" id="L685">                <span class="tok-number">0b10</span> =&gt; p.state = .String,</span>
<span class="line" id="L686">                <span class="tok-kw">else</span> =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.InvalidUtf8Byte,</span>
<span class="line" id="L687">            },</span>
<span class="line" id="L688">            .StringUtf8Byte2Of3 =&gt; {</span>
<span class="line" id="L689">                <span class="tok-kw">switch</span> (p.sequence_first_byte) {</span>
<span class="line" id="L690">                    <span class="tok-number">0xE0</span> =&gt; <span class="tok-kw">switch</span> (c) {</span>
<span class="line" id="L691">                        <span class="tok-number">0xA0</span>...<span class="tok-number">0xBF</span> =&gt; {},</span>
<span class="line" id="L692">                        <span class="tok-kw">else</span> =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.InvalidUtf8Byte,</span>
<span class="line" id="L693">                    },</span>
<span class="line" id="L694">                    <span class="tok-number">0xE1</span>...<span class="tok-number">0xEF</span> =&gt; <span class="tok-kw">switch</span> (c) {</span>
<span class="line" id="L695">                        <span class="tok-number">0x80</span>...<span class="tok-number">0xBF</span> =&gt; {},</span>
<span class="line" id="L696">                        <span class="tok-kw">else</span> =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.InvalidUtf8Byte,</span>
<span class="line" id="L697">                    },</span>
<span class="line" id="L698">                    <span class="tok-kw">else</span> =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.InvalidUtf8Byte,</span>
<span class="line" id="L699">                }</span>
<span class="line" id="L700">                p.state = .StringUtf8Byte3Of3;</span>
<span class="line" id="L701">            },</span>
<span class="line" id="L702">            .StringUtf8Byte3Of3 =&gt; <span class="tok-kw">switch</span> (c) {</span>
<span class="line" id="L703">                <span class="tok-number">0x80</span>...<span class="tok-number">0xBF</span> =&gt; p.state = .String,</span>
<span class="line" id="L704">                <span class="tok-kw">else</span> =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.InvalidUtf8Byte,</span>
<span class="line" id="L705">            },</span>
<span class="line" id="L706">            .StringUtf8Byte2Of4 =&gt; {</span>
<span class="line" id="L707">                <span class="tok-kw">switch</span> (p.sequence_first_byte) {</span>
<span class="line" id="L708">                    <span class="tok-number">0xF0</span> =&gt; <span class="tok-kw">switch</span> (c) {</span>
<span class="line" id="L709">                        <span class="tok-number">0x90</span>...<span class="tok-number">0xBF</span> =&gt; {},</span>
<span class="line" id="L710">                        <span class="tok-kw">else</span> =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.InvalidUtf8Byte,</span>
<span class="line" id="L711">                    },</span>
<span class="line" id="L712">                    <span class="tok-number">0xF1</span>...<span class="tok-number">0xF3</span> =&gt; <span class="tok-kw">switch</span> (c) {</span>
<span class="line" id="L713">                        <span class="tok-number">0x80</span>...<span class="tok-number">0xBF</span> =&gt; {},</span>
<span class="line" id="L714">                        <span class="tok-kw">else</span> =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.InvalidUtf8Byte,</span>
<span class="line" id="L715">                    },</span>
<span class="line" id="L716">                    <span class="tok-number">0xF4</span> =&gt; <span class="tok-kw">switch</span> (c) {</span>
<span class="line" id="L717">                        <span class="tok-number">0x80</span>...<span class="tok-number">0x8F</span> =&gt; {},</span>
<span class="line" id="L718">                        <span class="tok-kw">else</span> =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.InvalidUtf8Byte,</span>
<span class="line" id="L719">                    },</span>
<span class="line" id="L720">                    <span class="tok-kw">else</span> =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.InvalidUtf8Byte,</span>
<span class="line" id="L721">                }</span>
<span class="line" id="L722">                p.state = .StringUtf8Byte3Of4;</span>
<span class="line" id="L723">            },</span>
<span class="line" id="L724">            .StringUtf8Byte3Of4 =&gt; <span class="tok-kw">switch</span> (c) {</span>
<span class="line" id="L725">                <span class="tok-number">0x80</span>...<span class="tok-number">0xBF</span> =&gt; p.state = .StringUtf8Byte4Of4,</span>
<span class="line" id="L726">                <span class="tok-kw">else</span> =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.InvalidUtf8Byte,</span>
<span class="line" id="L727">            },</span>
<span class="line" id="L728">            .StringUtf8Byte4Of4 =&gt; <span class="tok-kw">switch</span> (c) {</span>
<span class="line" id="L729">                <span class="tok-number">0x80</span>...<span class="tok-number">0xBF</span> =&gt; p.state = .String,</span>
<span class="line" id="L730">                <span class="tok-kw">else</span> =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.InvalidUtf8Byte,</span>
<span class="line" id="L731">            },</span>
<span class="line" id="L732"></span>
<span class="line" id="L733">            .StringEscapeCharacter =&gt; <span class="tok-kw">switch</span> (c) {</span>
<span class="line" id="L734">                <span class="tok-comment">// NOTE: '/' is allowed as an escaped character but it also is allowed</span>
</span>
<span class="line" id="L735">                <span class="tok-comment">// as unescaped according to the RFC. There is a reported errata which suggests</span>
</span>
<span class="line" id="L736">                <span class="tok-comment">// removing the non-escaped variant but it makes more sense to simply disallow</span>
</span>
<span class="line" id="L737">                <span class="tok-comment">// it as an escape code here.</span>
</span>
<span class="line" id="L738">                <span class="tok-comment">//</span>
</span>
<span class="line" id="L739">                <span class="tok-comment">// The current JSONTestSuite tests rely on both of this behaviour being present</span>
</span>
<span class="line" id="L740">                <span class="tok-comment">// however, so we default to the status quo where both are accepted until this</span>
</span>
<span class="line" id="L741">                <span class="tok-comment">// is further clarified.</span>
</span>
<span class="line" id="L742">                <span class="tok-str">'&quot;'</span>, <span class="tok-str">'\\'</span>, <span class="tok-str">'/'</span>, <span class="tok-str">'b'</span>, <span class="tok-str">'f'</span>, <span class="tok-str">'n'</span>, <span class="tok-str">'r'</span>, <span class="tok-str">'t'</span> =&gt; {</span>
<span class="line" id="L743">                    p.string_escapes.Some.size_diff -= <span class="tok-number">1</span>;</span>
<span class="line" id="L744">                    p.state = .String;</span>
<span class="line" id="L745">                    p.string_last_was_high_surrogate = <span class="tok-null">false</span>;</span>
<span class="line" id="L746">                },</span>
<span class="line" id="L747">                <span class="tok-str">'u'</span> =&gt; {</span>
<span class="line" id="L748">                    p.state = .StringEscapeHexUnicode4;</span>
<span class="line" id="L749">                },</span>
<span class="line" id="L750">                <span class="tok-kw">else</span> =&gt; {</span>
<span class="line" id="L751">                    <span class="tok-kw">return</span> <span class="tok-kw">error</span>.InvalidEscapeCharacter;</span>
<span class="line" id="L752">                },</span>
<span class="line" id="L753">            },</span>
<span class="line" id="L754"></span>
<span class="line" id="L755">            .StringEscapeHexUnicode4 =&gt; {</span>
<span class="line" id="L756">                <span class="tok-kw">var</span> codepoint: <span class="tok-type">u21</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L757">                <span class="tok-kw">switch</span> (c) {</span>
<span class="line" id="L758">                    <span class="tok-kw">else</span> =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.InvalidUnicodeHexSymbol,</span>
<span class="line" id="L759">                    <span class="tok-str">'0'</span>...<span class="tok-str">'9'</span> =&gt; {</span>
<span class="line" id="L760">                        codepoint = c - <span class="tok-str">'0'</span>;</span>
<span class="line" id="L761">                    },</span>
<span class="line" id="L762">                    <span class="tok-str">'A'</span>...<span class="tok-str">'F'</span> =&gt; {</span>
<span class="line" id="L763">                        codepoint = c - <span class="tok-str">'A'</span> + <span class="tok-number">10</span>;</span>
<span class="line" id="L764">                    },</span>
<span class="line" id="L765">                    <span class="tok-str">'a'</span>...<span class="tok-str">'f'</span> =&gt; {</span>
<span class="line" id="L766">                        codepoint = c - <span class="tok-str">'a'</span> + <span class="tok-number">10</span>;</span>
<span class="line" id="L767">                    },</span>
<span class="line" id="L768">                }</span>
<span class="line" id="L769">                p.state = .StringEscapeHexUnicode3;</span>
<span class="line" id="L770">                p.string_unicode_codepoint = codepoint &lt;&lt; <span class="tok-number">12</span>;</span>
<span class="line" id="L771">            },</span>
<span class="line" id="L772"></span>
<span class="line" id="L773">            .StringEscapeHexUnicode3 =&gt; {</span>
<span class="line" id="L774">                <span class="tok-kw">var</span> codepoint: <span class="tok-type">u21</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L775">                <span class="tok-kw">switch</span> (c) {</span>
<span class="line" id="L776">                    <span class="tok-kw">else</span> =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.InvalidUnicodeHexSymbol,</span>
<span class="line" id="L777">                    <span class="tok-str">'0'</span>...<span class="tok-str">'9'</span> =&gt; {</span>
<span class="line" id="L778">                        codepoint = c - <span class="tok-str">'0'</span>;</span>
<span class="line" id="L779">                    },</span>
<span class="line" id="L780">                    <span class="tok-str">'A'</span>...<span class="tok-str">'F'</span> =&gt; {</span>
<span class="line" id="L781">                        codepoint = c - <span class="tok-str">'A'</span> + <span class="tok-number">10</span>;</span>
<span class="line" id="L782">                    },</span>
<span class="line" id="L783">                    <span class="tok-str">'a'</span>...<span class="tok-str">'f'</span> =&gt; {</span>
<span class="line" id="L784">                        codepoint = c - <span class="tok-str">'a'</span> + <span class="tok-number">10</span>;</span>
<span class="line" id="L785">                    },</span>
<span class="line" id="L786">                }</span>
<span class="line" id="L787">                p.state = .StringEscapeHexUnicode2;</span>
<span class="line" id="L788">                p.string_unicode_codepoint |= codepoint &lt;&lt; <span class="tok-number">8</span>;</span>
<span class="line" id="L789">            },</span>
<span class="line" id="L790"></span>
<span class="line" id="L791">            .StringEscapeHexUnicode2 =&gt; {</span>
<span class="line" id="L792">                <span class="tok-kw">var</span> codepoint: <span class="tok-type">u21</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L793">                <span class="tok-kw">switch</span> (c) {</span>
<span class="line" id="L794">                    <span class="tok-kw">else</span> =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.InvalidUnicodeHexSymbol,</span>
<span class="line" id="L795">                    <span class="tok-str">'0'</span>...<span class="tok-str">'9'</span> =&gt; {</span>
<span class="line" id="L796">                        codepoint = c - <span class="tok-str">'0'</span>;</span>
<span class="line" id="L797">                    },</span>
<span class="line" id="L798">                    <span class="tok-str">'A'</span>...<span class="tok-str">'F'</span> =&gt; {</span>
<span class="line" id="L799">                        codepoint = c - <span class="tok-str">'A'</span> + <span class="tok-number">10</span>;</span>
<span class="line" id="L800">                    },</span>
<span class="line" id="L801">                    <span class="tok-str">'a'</span>...<span class="tok-str">'f'</span> =&gt; {</span>
<span class="line" id="L802">                        codepoint = c - <span class="tok-str">'a'</span> + <span class="tok-number">10</span>;</span>
<span class="line" id="L803">                    },</span>
<span class="line" id="L804">                }</span>
<span class="line" id="L805">                p.state = .StringEscapeHexUnicode1;</span>
<span class="line" id="L806">                p.string_unicode_codepoint |= codepoint &lt;&lt; <span class="tok-number">4</span>;</span>
<span class="line" id="L807">            },</span>
<span class="line" id="L808"></span>
<span class="line" id="L809">            .StringEscapeHexUnicode1 =&gt; {</span>
<span class="line" id="L810">                <span class="tok-kw">var</span> codepoint: <span class="tok-type">u21</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L811">                <span class="tok-kw">switch</span> (c) {</span>
<span class="line" id="L812">                    <span class="tok-kw">else</span> =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.InvalidUnicodeHexSymbol,</span>
<span class="line" id="L813">                    <span class="tok-str">'0'</span>...<span class="tok-str">'9'</span> =&gt; {</span>
<span class="line" id="L814">                        codepoint = c - <span class="tok-str">'0'</span>;</span>
<span class="line" id="L815">                    },</span>
<span class="line" id="L816">                    <span class="tok-str">'A'</span>...<span class="tok-str">'F'</span> =&gt; {</span>
<span class="line" id="L817">                        codepoint = c - <span class="tok-str">'A'</span> + <span class="tok-number">10</span>;</span>
<span class="line" id="L818">                    },</span>
<span class="line" id="L819">                    <span class="tok-str">'a'</span>...<span class="tok-str">'f'</span> =&gt; {</span>
<span class="line" id="L820">                        codepoint = c - <span class="tok-str">'a'</span> + <span class="tok-number">10</span>;</span>
<span class="line" id="L821">                    },</span>
<span class="line" id="L822">                }</span>
<span class="line" id="L823">                p.state = .String;</span>
<span class="line" id="L824">                p.string_unicode_codepoint |= codepoint;</span>
<span class="line" id="L825">                <span class="tok-kw">if</span> (p.string_unicode_codepoint &lt; <span class="tok-number">0xD800</span> <span class="tok-kw">or</span> p.string_unicode_codepoint &gt;= <span class="tok-number">0xE000</span>) {</span>
<span class="line" id="L826">                    <span class="tok-comment">// not part of surrogate pair</span>
</span>
<span class="line" id="L827">                    p.string_escapes.Some.size_diff -= <span class="tok-builtin">@as</span>(<span class="tok-type">isize</span>, <span class="tok-number">6</span> - (std.unicode.utf8CodepointSequenceLength(p.string_unicode_codepoint) <span class="tok-kw">catch</span> <span class="tok-kw">unreachable</span>));</span>
<span class="line" id="L828">                    p.string_last_was_high_surrogate = <span class="tok-null">false</span>;</span>
<span class="line" id="L829">                } <span class="tok-kw">else</span> <span class="tok-kw">if</span> (p.string_unicode_codepoint &lt; <span class="tok-number">0xDC00</span>) {</span>
<span class="line" id="L830">                    <span class="tok-comment">// 'high' surrogate</span>
</span>
<span class="line" id="L831">                    <span class="tok-comment">// takes 3 bytes to encode a half surrogate pair into wtf8</span>
</span>
<span class="line" id="L832">                    p.string_escapes.Some.size_diff -= <span class="tok-number">6</span> - <span class="tok-number">3</span>;</span>
<span class="line" id="L833">                    p.string_last_was_high_surrogate = <span class="tok-null">true</span>;</span>
<span class="line" id="L834">                } <span class="tok-kw">else</span> {</span>
<span class="line" id="L835">                    <span class="tok-comment">// 'low' surrogate</span>
</span>
<span class="line" id="L836">                    p.string_escapes.Some.size_diff -= <span class="tok-number">6</span>;</span>
<span class="line" id="L837">                    <span class="tok-kw">if</span> (p.string_last_was_high_surrogate) {</span>
<span class="line" id="L838">                        <span class="tok-comment">// takes 4 bytes to encode a full surrogate pair into utf8</span>
</span>
<span class="line" id="L839">                        <span class="tok-comment">// 3 bytes are already reserved by high surrogate</span>
</span>
<span class="line" id="L840">                        p.string_escapes.Some.size_diff -= -<span class="tok-number">1</span>;</span>
<span class="line" id="L841">                    } <span class="tok-kw">else</span> {</span>
<span class="line" id="L842">                        <span class="tok-comment">// takes 3 bytes to encode a half surrogate pair into wtf8</span>
</span>
<span class="line" id="L843">                        p.string_escapes.Some.size_diff -= -<span class="tok-number">3</span>;</span>
<span class="line" id="L844">                    }</span>
<span class="line" id="L845">                    p.string_last_was_high_surrogate = <span class="tok-null">false</span>;</span>
<span class="line" id="L846">                }</span>
<span class="line" id="L847">                p.string_unicode_codepoint = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L848">            },</span>
<span class="line" id="L849"></span>
<span class="line" id="L850">            .Number =&gt; {</span>
<span class="line" id="L851">                p.complete = p.after_value_state == .TopLevelEnd;</span>
<span class="line" id="L852">                <span class="tok-kw">switch</span> (c) {</span>
<span class="line" id="L853">                    <span class="tok-str">'0'</span> =&gt; {</span>
<span class="line" id="L854">                        p.state = .NumberMaybeDotOrExponent;</span>
<span class="line" id="L855">                    },</span>
<span class="line" id="L856">                    <span class="tok-str">'1'</span>...<span class="tok-str">'9'</span> =&gt; {</span>
<span class="line" id="L857">                        p.state = .NumberMaybeDigitOrDotOrExponent;</span>
<span class="line" id="L858">                    },</span>
<span class="line" id="L859">                    <span class="tok-kw">else</span> =&gt; {</span>
<span class="line" id="L860">                        <span class="tok-kw">return</span> <span class="tok-kw">error</span>.InvalidNumber;</span>
<span class="line" id="L861">                    },</span>
<span class="line" id="L862">                }</span>
<span class="line" id="L863">            },</span>
<span class="line" id="L864"></span>
<span class="line" id="L865">            .NumberMaybeDotOrExponent =&gt; {</span>
<span class="line" id="L866">                p.complete = p.after_value_state == .TopLevelEnd;</span>
<span class="line" id="L867">                <span class="tok-kw">switch</span> (c) {</span>
<span class="line" id="L868">                    <span class="tok-str">'.'</span> =&gt; {</span>
<span class="line" id="L869">                        p.number_is_integer = <span class="tok-null">false</span>;</span>
<span class="line" id="L870">                        p.state = .NumberFractionalRequired;</span>
<span class="line" id="L871">                    },</span>
<span class="line" id="L872">                    <span class="tok-str">'e'</span>, <span class="tok-str">'E'</span> =&gt; {</span>
<span class="line" id="L873">                        p.number_is_integer = <span class="tok-null">false</span>;</span>
<span class="line" id="L874">                        p.state = .NumberExponent;</span>
<span class="line" id="L875">                    },</span>
<span class="line" id="L876">                    <span class="tok-kw">else</span> =&gt; {</span>
<span class="line" id="L877">                        p.state = p.after_value_state;</span>
<span class="line" id="L878">                        token.* = .{</span>
<span class="line" id="L879">                            .Number = .{</span>
<span class="line" id="L880">                                .count = p.count,</span>
<span class="line" id="L881">                                .is_integer = p.number_is_integer,</span>
<span class="line" id="L882">                            },</span>
<span class="line" id="L883">                        };</span>
<span class="line" id="L884">                        p.number_is_integer = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L885">                        <span class="tok-kw">return</span> <span class="tok-null">true</span>;</span>
<span class="line" id="L886">                    },</span>
<span class="line" id="L887">                }</span>
<span class="line" id="L888">            },</span>
<span class="line" id="L889"></span>
<span class="line" id="L890">            .NumberMaybeDigitOrDotOrExponent =&gt; {</span>
<span class="line" id="L891">                p.complete = p.after_value_state == .TopLevelEnd;</span>
<span class="line" id="L892">                <span class="tok-kw">switch</span> (c) {</span>
<span class="line" id="L893">                    <span class="tok-str">'.'</span> =&gt; {</span>
<span class="line" id="L894">                        p.number_is_integer = <span class="tok-null">false</span>;</span>
<span class="line" id="L895">                        p.state = .NumberFractionalRequired;</span>
<span class="line" id="L896">                    },</span>
<span class="line" id="L897">                    <span class="tok-str">'e'</span>, <span class="tok-str">'E'</span> =&gt; {</span>
<span class="line" id="L898">                        p.number_is_integer = <span class="tok-null">false</span>;</span>
<span class="line" id="L899">                        p.state = .NumberExponent;</span>
<span class="line" id="L900">                    },</span>
<span class="line" id="L901">                    <span class="tok-str">'0'</span>...<span class="tok-str">'9'</span> =&gt; {</span>
<span class="line" id="L902">                        <span class="tok-comment">// another digit</span>
</span>
<span class="line" id="L903">                    },</span>
<span class="line" id="L904">                    <span class="tok-kw">else</span> =&gt; {</span>
<span class="line" id="L905">                        p.state = p.after_value_state;</span>
<span class="line" id="L906">                        token.* = .{</span>
<span class="line" id="L907">                            .Number = .{</span>
<span class="line" id="L908">                                .count = p.count,</span>
<span class="line" id="L909">                                .is_integer = p.number_is_integer,</span>
<span class="line" id="L910">                            },</span>
<span class="line" id="L911">                        };</span>
<span class="line" id="L912">                        <span class="tok-kw">return</span> <span class="tok-null">true</span>;</span>
<span class="line" id="L913">                    },</span>
<span class="line" id="L914">                }</span>
<span class="line" id="L915">            },</span>
<span class="line" id="L916"></span>
<span class="line" id="L917">            .NumberFractionalRequired =&gt; {</span>
<span class="line" id="L918">                p.complete = p.after_value_state == .TopLevelEnd;</span>
<span class="line" id="L919">                <span class="tok-kw">switch</span> (c) {</span>
<span class="line" id="L920">                    <span class="tok-str">'0'</span>...<span class="tok-str">'9'</span> =&gt; {</span>
<span class="line" id="L921">                        p.state = .NumberFractional;</span>
<span class="line" id="L922">                    },</span>
<span class="line" id="L923">                    <span class="tok-kw">else</span> =&gt; {</span>
<span class="line" id="L924">                        <span class="tok-kw">return</span> <span class="tok-kw">error</span>.InvalidNumber;</span>
<span class="line" id="L925">                    },</span>
<span class="line" id="L926">                }</span>
<span class="line" id="L927">            },</span>
<span class="line" id="L928"></span>
<span class="line" id="L929">            .NumberFractional =&gt; {</span>
<span class="line" id="L930">                p.complete = p.after_value_state == .TopLevelEnd;</span>
<span class="line" id="L931">                <span class="tok-kw">switch</span> (c) {</span>
<span class="line" id="L932">                    <span class="tok-str">'0'</span>...<span class="tok-str">'9'</span> =&gt; {</span>
<span class="line" id="L933">                        <span class="tok-comment">// another digit</span>
</span>
<span class="line" id="L934">                    },</span>
<span class="line" id="L935">                    <span class="tok-str">'e'</span>, <span class="tok-str">'E'</span> =&gt; {</span>
<span class="line" id="L936">                        p.number_is_integer = <span class="tok-null">false</span>;</span>
<span class="line" id="L937">                        p.state = .NumberExponent;</span>
<span class="line" id="L938">                    },</span>
<span class="line" id="L939">                    <span class="tok-kw">else</span> =&gt; {</span>
<span class="line" id="L940">                        p.state = p.after_value_state;</span>
<span class="line" id="L941">                        token.* = .{</span>
<span class="line" id="L942">                            .Number = .{</span>
<span class="line" id="L943">                                .count = p.count,</span>
<span class="line" id="L944">                                .is_integer = p.number_is_integer,</span>
<span class="line" id="L945">                            },</span>
<span class="line" id="L946">                        };</span>
<span class="line" id="L947">                        <span class="tok-kw">return</span> <span class="tok-null">true</span>;</span>
<span class="line" id="L948">                    },</span>
<span class="line" id="L949">                }</span>
<span class="line" id="L950">            },</span>
<span class="line" id="L951"></span>
<span class="line" id="L952">            .NumberMaybeExponent =&gt; {</span>
<span class="line" id="L953">                p.complete = p.after_value_state == .TopLevelEnd;</span>
<span class="line" id="L954">                <span class="tok-kw">switch</span> (c) {</span>
<span class="line" id="L955">                    <span class="tok-str">'e'</span>, <span class="tok-str">'E'</span> =&gt; {</span>
<span class="line" id="L956">                        p.number_is_integer = <span class="tok-null">false</span>;</span>
<span class="line" id="L957">                        p.state = .NumberExponent;</span>
<span class="line" id="L958">                    },</span>
<span class="line" id="L959">                    <span class="tok-kw">else</span> =&gt; {</span>
<span class="line" id="L960">                        p.state = p.after_value_state;</span>
<span class="line" id="L961">                        token.* = .{</span>
<span class="line" id="L962">                            .Number = .{</span>
<span class="line" id="L963">                                .count = p.count,</span>
<span class="line" id="L964">                                .is_integer = p.number_is_integer,</span>
<span class="line" id="L965">                            },</span>
<span class="line" id="L966">                        };</span>
<span class="line" id="L967">                        <span class="tok-kw">return</span> <span class="tok-null">true</span>;</span>
<span class="line" id="L968">                    },</span>
<span class="line" id="L969">                }</span>
<span class="line" id="L970">            },</span>
<span class="line" id="L971"></span>
<span class="line" id="L972">            .NumberExponent =&gt; <span class="tok-kw">switch</span> (c) {</span>
<span class="line" id="L973">                <span class="tok-str">'-'</span>, <span class="tok-str">'+'</span> =&gt; {</span>
<span class="line" id="L974">                    p.complete = <span class="tok-null">false</span>;</span>
<span class="line" id="L975">                    p.state = .NumberExponentDigitsRequired;</span>
<span class="line" id="L976">                },</span>
<span class="line" id="L977">                <span class="tok-str">'0'</span>...<span class="tok-str">'9'</span> =&gt; {</span>
<span class="line" id="L978">                    p.complete = p.after_value_state == .TopLevelEnd;</span>
<span class="line" id="L979">                    p.state = .NumberExponentDigits;</span>
<span class="line" id="L980">                },</span>
<span class="line" id="L981">                <span class="tok-kw">else</span> =&gt; {</span>
<span class="line" id="L982">                    <span class="tok-kw">return</span> <span class="tok-kw">error</span>.InvalidNumber;</span>
<span class="line" id="L983">                },</span>
<span class="line" id="L984">            },</span>
<span class="line" id="L985"></span>
<span class="line" id="L986">            .NumberExponentDigitsRequired =&gt; <span class="tok-kw">switch</span> (c) {</span>
<span class="line" id="L987">                <span class="tok-str">'0'</span>...<span class="tok-str">'9'</span> =&gt; {</span>
<span class="line" id="L988">                    p.complete = p.after_value_state == .TopLevelEnd;</span>
<span class="line" id="L989">                    p.state = .NumberExponentDigits;</span>
<span class="line" id="L990">                },</span>
<span class="line" id="L991">                <span class="tok-kw">else</span> =&gt; {</span>
<span class="line" id="L992">                    <span class="tok-kw">return</span> <span class="tok-kw">error</span>.InvalidNumber;</span>
<span class="line" id="L993">                },</span>
<span class="line" id="L994">            },</span>
<span class="line" id="L995"></span>
<span class="line" id="L996">            .NumberExponentDigits =&gt; {</span>
<span class="line" id="L997">                p.complete = p.after_value_state == .TopLevelEnd;</span>
<span class="line" id="L998">                <span class="tok-kw">switch</span> (c) {</span>
<span class="line" id="L999">                    <span class="tok-str">'0'</span>...<span class="tok-str">'9'</span> =&gt; {</span>
<span class="line" id="L1000">                        <span class="tok-comment">// another digit</span>
</span>
<span class="line" id="L1001">                    },</span>
<span class="line" id="L1002">                    <span class="tok-kw">else</span> =&gt; {</span>
<span class="line" id="L1003">                        p.state = p.after_value_state;</span>
<span class="line" id="L1004">                        token.* = .{</span>
<span class="line" id="L1005">                            .Number = .{</span>
<span class="line" id="L1006">                                .count = p.count,</span>
<span class="line" id="L1007">                                .is_integer = p.number_is_integer,</span>
<span class="line" id="L1008">                            },</span>
<span class="line" id="L1009">                        };</span>
<span class="line" id="L1010">                        <span class="tok-kw">return</span> <span class="tok-null">true</span>;</span>
<span class="line" id="L1011">                    },</span>
<span class="line" id="L1012">                }</span>
<span class="line" id="L1013">            },</span>
<span class="line" id="L1014"></span>
<span class="line" id="L1015">            .TrueLiteral1 =&gt; <span class="tok-kw">switch</span> (c) {</span>
<span class="line" id="L1016">                <span class="tok-str">'r'</span> =&gt; p.state = .TrueLiteral2,</span>
<span class="line" id="L1017">                <span class="tok-kw">else</span> =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.InvalidLiteral,</span>
<span class="line" id="L1018">            },</span>
<span class="line" id="L1019"></span>
<span class="line" id="L1020">            .TrueLiteral2 =&gt; <span class="tok-kw">switch</span> (c) {</span>
<span class="line" id="L1021">                <span class="tok-str">'u'</span> =&gt; p.state = .TrueLiteral3,</span>
<span class="line" id="L1022">                <span class="tok-kw">else</span> =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.InvalidLiteral,</span>
<span class="line" id="L1023">            },</span>
<span class="line" id="L1024"></span>
<span class="line" id="L1025">            .TrueLiteral3 =&gt; <span class="tok-kw">switch</span> (c) {</span>
<span class="line" id="L1026">                <span class="tok-str">'e'</span> =&gt; {</span>
<span class="line" id="L1027">                    p.state = p.after_value_state;</span>
<span class="line" id="L1028">                    p.complete = p.state == .TopLevelEnd;</span>
<span class="line" id="L1029">                    token.* = Token.True;</span>
<span class="line" id="L1030">                },</span>
<span class="line" id="L1031">                <span class="tok-kw">else</span> =&gt; {</span>
<span class="line" id="L1032">                    <span class="tok-kw">return</span> <span class="tok-kw">error</span>.InvalidLiteral;</span>
<span class="line" id="L1033">                },</span>
<span class="line" id="L1034">            },</span>
<span class="line" id="L1035"></span>
<span class="line" id="L1036">            .FalseLiteral1 =&gt; <span class="tok-kw">switch</span> (c) {</span>
<span class="line" id="L1037">                <span class="tok-str">'a'</span> =&gt; p.state = .FalseLiteral2,</span>
<span class="line" id="L1038">                <span class="tok-kw">else</span> =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.InvalidLiteral,</span>
<span class="line" id="L1039">            },</span>
<span class="line" id="L1040"></span>
<span class="line" id="L1041">            .FalseLiteral2 =&gt; <span class="tok-kw">switch</span> (c) {</span>
<span class="line" id="L1042">                <span class="tok-str">'l'</span> =&gt; p.state = .FalseLiteral3,</span>
<span class="line" id="L1043">                <span class="tok-kw">else</span> =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.InvalidLiteral,</span>
<span class="line" id="L1044">            },</span>
<span class="line" id="L1045"></span>
<span class="line" id="L1046">            .FalseLiteral3 =&gt; <span class="tok-kw">switch</span> (c) {</span>
<span class="line" id="L1047">                <span class="tok-str">'s'</span> =&gt; p.state = .FalseLiteral4,</span>
<span class="line" id="L1048">                <span class="tok-kw">else</span> =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.InvalidLiteral,</span>
<span class="line" id="L1049">            },</span>
<span class="line" id="L1050"></span>
<span class="line" id="L1051">            .FalseLiteral4 =&gt; <span class="tok-kw">switch</span> (c) {</span>
<span class="line" id="L1052">                <span class="tok-str">'e'</span> =&gt; {</span>
<span class="line" id="L1053">                    p.state = p.after_value_state;</span>
<span class="line" id="L1054">                    p.complete = p.state == .TopLevelEnd;</span>
<span class="line" id="L1055">                    token.* = Token.False;</span>
<span class="line" id="L1056">                },</span>
<span class="line" id="L1057">                <span class="tok-kw">else</span> =&gt; {</span>
<span class="line" id="L1058">                    <span class="tok-kw">return</span> <span class="tok-kw">error</span>.InvalidLiteral;</span>
<span class="line" id="L1059">                },</span>
<span class="line" id="L1060">            },</span>
<span class="line" id="L1061"></span>
<span class="line" id="L1062">            .NullLiteral1 =&gt; <span class="tok-kw">switch</span> (c) {</span>
<span class="line" id="L1063">                <span class="tok-str">'u'</span> =&gt; p.state = .NullLiteral2,</span>
<span class="line" id="L1064">                <span class="tok-kw">else</span> =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.InvalidLiteral,</span>
<span class="line" id="L1065">            },</span>
<span class="line" id="L1066"></span>
<span class="line" id="L1067">            .NullLiteral2 =&gt; <span class="tok-kw">switch</span> (c) {</span>
<span class="line" id="L1068">                <span class="tok-str">'l'</span> =&gt; p.state = .NullLiteral3,</span>
<span class="line" id="L1069">                <span class="tok-kw">else</span> =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.InvalidLiteral,</span>
<span class="line" id="L1070">            },</span>
<span class="line" id="L1071"></span>
<span class="line" id="L1072">            .NullLiteral3 =&gt; <span class="tok-kw">switch</span> (c) {</span>
<span class="line" id="L1073">                <span class="tok-str">'l'</span> =&gt; {</span>
<span class="line" id="L1074">                    p.state = p.after_value_state;</span>
<span class="line" id="L1075">                    p.complete = p.state == .TopLevelEnd;</span>
<span class="line" id="L1076">                    token.* = Token.Null;</span>
<span class="line" id="L1077">                },</span>
<span class="line" id="L1078">                <span class="tok-kw">else</span> =&gt; {</span>
<span class="line" id="L1079">                    <span class="tok-kw">return</span> <span class="tok-kw">error</span>.InvalidLiteral;</span>
<span class="line" id="L1080">                },</span>
<span class="line" id="L1081">            },</span>
<span class="line" id="L1082">        }</span>
<span class="line" id="L1083"></span>
<span class="line" id="L1084">        <span class="tok-kw">return</span> <span class="tok-null">false</span>;</span>
<span class="line" id="L1085">    }</span>
<span class="line" id="L1086">};</span>
<span class="line" id="L1087"></span>
<span class="line" id="L1088"><span class="tok-comment">/// A small wrapper over a StreamingParser for full slices. Returns a stream of json Tokens.</span></span>
<span class="line" id="L1089"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> TokenStream = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L1090">    i: <span class="tok-type">usize</span>,</span>
<span class="line" id="L1091">    slice: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>,</span>
<span class="line" id="L1092">    parser: StreamingParser,</span>
<span class="line" id="L1093">    token: ?Token,</span>
<span class="line" id="L1094"></span>
<span class="line" id="L1095">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> Error = StreamingParser.Error || <span class="tok-kw">error</span>{UnexpectedEndOfJson};</span>
<span class="line" id="L1096"></span>
<span class="line" id="L1097">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">init</span>(slice: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) TokenStream {</span>
<span class="line" id="L1098">        <span class="tok-kw">return</span> TokenStream{</span>
<span class="line" id="L1099">            .i = <span class="tok-number">0</span>,</span>
<span class="line" id="L1100">            .slice = slice,</span>
<span class="line" id="L1101">            .parser = StreamingParser.init(),</span>
<span class="line" id="L1102">            .token = <span class="tok-null">null</span>,</span>
<span class="line" id="L1103">        };</span>
<span class="line" id="L1104">    }</span>
<span class="line" id="L1105"></span>
<span class="line" id="L1106">    <span class="tok-kw">fn</span> <span class="tok-fn">stackUsed</span>(self: *TokenStream) <span class="tok-type">usize</span> {</span>
<span class="line" id="L1107">        <span class="tok-kw">return</span> self.parser.stack.len + <span class="tok-kw">if</span> (self.token != <span class="tok-null">null</span>) <span class="tok-builtin">@as</span>(<span class="tok-type">usize</span>, <span class="tok-number">1</span>) <span class="tok-kw">else</span> <span class="tok-number">0</span>;</span>
<span class="line" id="L1108">    }</span>
<span class="line" id="L1109"></span>
<span class="line" id="L1110">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">next</span>(self: *TokenStream) Error!?Token {</span>
<span class="line" id="L1111">        <span class="tok-kw">if</span> (self.token) |token| {</span>
<span class="line" id="L1112">            self.token = <span class="tok-null">null</span>;</span>
<span class="line" id="L1113">            <span class="tok-kw">return</span> token;</span>
<span class="line" id="L1114">        }</span>
<span class="line" id="L1115"></span>
<span class="line" id="L1116">        <span class="tok-kw">var</span> t1: ?Token = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L1117">        <span class="tok-kw">var</span> t2: ?Token = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L1118"></span>
<span class="line" id="L1119">        <span class="tok-kw">while</span> (self.i &lt; self.slice.len) {</span>
<span class="line" id="L1120">            <span class="tok-kw">try</span> self.parser.feed(self.slice[self.i], &amp;t1, &amp;t2);</span>
<span class="line" id="L1121">            self.i += <span class="tok-number">1</span>;</span>
<span class="line" id="L1122"></span>
<span class="line" id="L1123">            <span class="tok-kw">if</span> (t1) |token| {</span>
<span class="line" id="L1124">                self.token = t2;</span>
<span class="line" id="L1125">                <span class="tok-kw">return</span> token;</span>
<span class="line" id="L1126">            }</span>
<span class="line" id="L1127">        }</span>
<span class="line" id="L1128"></span>
<span class="line" id="L1129">        <span class="tok-comment">// Without this a bare number fails, the streaming parser doesn't know the input ended</span>
</span>
<span class="line" id="L1130">        <span class="tok-kw">try</span> self.parser.feed(<span class="tok-str">' '</span>, &amp;t1, &amp;t2);</span>
<span class="line" id="L1131">        self.i += <span class="tok-number">1</span>;</span>
<span class="line" id="L1132"></span>
<span class="line" id="L1133">        <span class="tok-kw">if</span> (t1) |token| {</span>
<span class="line" id="L1134">            <span class="tok-kw">return</span> token;</span>
<span class="line" id="L1135">        } <span class="tok-kw">else</span> <span class="tok-kw">if</span> (self.parser.complete) {</span>
<span class="line" id="L1136">            <span class="tok-kw">return</span> <span class="tok-null">null</span>;</span>
<span class="line" id="L1137">        } <span class="tok-kw">else</span> {</span>
<span class="line" id="L1138">            <span class="tok-kw">return</span> <span class="tok-kw">error</span>.UnexpectedEndOfJson;</span>
<span class="line" id="L1139">        }</span>
<span class="line" id="L1140">    }</span>
<span class="line" id="L1141">};</span>
<span class="line" id="L1142"></span>
<span class="line" id="L1143"><span class="tok-comment">/// Validate a JSON string. This does not limit number precision so a decoder may not necessarily</span></span>
<span class="line" id="L1144"><span class="tok-comment">/// be able to decode the string even if this returns true.</span></span>
<span class="line" id="L1145"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">validate</span>(s: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) <span class="tok-type">bool</span> {</span>
<span class="line" id="L1146">    <span class="tok-kw">var</span> p = StreamingParser.init();</span>
<span class="line" id="L1147"></span>
<span class="line" id="L1148">    <span class="tok-kw">for</span> (s) |c| {</span>
<span class="line" id="L1149">        <span class="tok-kw">var</span> token1: ?Token = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L1150">        <span class="tok-kw">var</span> token2: ?Token = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L1151"></span>
<span class="line" id="L1152">        p.feed(c, &amp;token1, &amp;token2) <span class="tok-kw">catch</span> {</span>
<span class="line" id="L1153">            <span class="tok-kw">return</span> <span class="tok-null">false</span>;</span>
<span class="line" id="L1154">        };</span>
<span class="line" id="L1155">    }</span>
<span class="line" id="L1156"></span>
<span class="line" id="L1157">    <span class="tok-kw">return</span> p.complete;</span>
<span class="line" id="L1158">}</span>
<span class="line" id="L1159"></span>
<span class="line" id="L1160"><span class="tok-kw">const</span> Allocator = std.mem.Allocator;</span>
<span class="line" id="L1161"><span class="tok-kw">const</span> ArenaAllocator = std.heap.ArenaAllocator;</span>
<span class="line" id="L1162"><span class="tok-kw">const</span> ArrayList = std.ArrayList;</span>
<span class="line" id="L1163"><span class="tok-kw">const</span> StringArrayHashMap = std.StringArrayHashMap;</span>
<span class="line" id="L1164"></span>
<span class="line" id="L1165"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> ValueTree = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L1166">    arena: ArenaAllocator,</span>
<span class="line" id="L1167">    root: Value,</span>
<span class="line" id="L1168"></span>
<span class="line" id="L1169">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">deinit</span>(self: *ValueTree) <span class="tok-type">void</span> {</span>
<span class="line" id="L1170">        self.arena.deinit();</span>
<span class="line" id="L1171">    }</span>
<span class="line" id="L1172">};</span>
<span class="line" id="L1173"></span>
<span class="line" id="L1174"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> ObjectMap = StringArrayHashMap(Value);</span>
<span class="line" id="L1175"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> Array = ArrayList(Value);</span>
<span class="line" id="L1176"></span>
<span class="line" id="L1177"><span class="tok-comment">/// Represents a JSON value</span></span>
<span class="line" id="L1178"><span class="tok-comment">/// Currently only supports numbers that fit into i64 or f64.</span></span>
<span class="line" id="L1179"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> Value = <span class="tok-kw">union</span>(<span class="tok-kw">enum</span>) {</span>
<span class="line" id="L1180">    Null,</span>
<span class="line" id="L1181">    Bool: <span class="tok-type">bool</span>,</span>
<span class="line" id="L1182">    Integer: <span class="tok-type">i64</span>,</span>
<span class="line" id="L1183">    Float: <span class="tok-type">f64</span>,</span>
<span class="line" id="L1184">    NumberString: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>,</span>
<span class="line" id="L1185">    String: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>,</span>
<span class="line" id="L1186">    Array: Array,</span>
<span class="line" id="L1187">    Object: ObjectMap,</span>
<span class="line" id="L1188"></span>
<span class="line" id="L1189">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">jsonStringify</span>(</span>
<span class="line" id="L1190">        value: <span class="tok-builtin">@This</span>(),</span>
<span class="line" id="L1191">        options: StringifyOptions,</span>
<span class="line" id="L1192">        out_stream: <span class="tok-kw">anytype</span>,</span>
<span class="line" id="L1193">    ) <span class="tok-builtin">@TypeOf</span>(out_stream).Error!<span class="tok-type">void</span> {</span>
<span class="line" id="L1194">        <span class="tok-kw">switch</span> (value) {</span>
<span class="line" id="L1195">            .Null =&gt; <span class="tok-kw">try</span> stringify(<span class="tok-null">null</span>, options, out_stream),</span>
<span class="line" id="L1196">            .Bool =&gt; |inner| <span class="tok-kw">try</span> stringify(inner, options, out_stream),</span>
<span class="line" id="L1197">            .Integer =&gt; |inner| <span class="tok-kw">try</span> stringify(inner, options, out_stream),</span>
<span class="line" id="L1198">            .Float =&gt; |inner| <span class="tok-kw">try</span> stringify(inner, options, out_stream),</span>
<span class="line" id="L1199">            .NumberString =&gt; |inner| <span class="tok-kw">try</span> out_stream.writeAll(inner),</span>
<span class="line" id="L1200">            .String =&gt; |inner| <span class="tok-kw">try</span> stringify(inner, options, out_stream),</span>
<span class="line" id="L1201">            .Array =&gt; |inner| <span class="tok-kw">try</span> stringify(inner.items, options, out_stream),</span>
<span class="line" id="L1202">            .Object =&gt; |inner| {</span>
<span class="line" id="L1203">                <span class="tok-kw">try</span> out_stream.writeByte(<span class="tok-str">'{'</span>);</span>
<span class="line" id="L1204">                <span class="tok-kw">var</span> field_output = <span class="tok-null">false</span>;</span>
<span class="line" id="L1205">                <span class="tok-kw">var</span> child_options = options;</span>
<span class="line" id="L1206">                <span class="tok-kw">if</span> (child_options.whitespace) |*child_whitespace| {</span>
<span class="line" id="L1207">                    child_whitespace.indent_level += <span class="tok-number">1</span>;</span>
<span class="line" id="L1208">                }</span>
<span class="line" id="L1209">                <span class="tok-kw">var</span> it = inner.iterator();</span>
<span class="line" id="L1210">                <span class="tok-kw">while</span> (it.next()) |entry| {</span>
<span class="line" id="L1211">                    <span class="tok-kw">if</span> (!field_output) {</span>
<span class="line" id="L1212">                        field_output = <span class="tok-null">true</span>;</span>
<span class="line" id="L1213">                    } <span class="tok-kw">else</span> {</span>
<span class="line" id="L1214">                        <span class="tok-kw">try</span> out_stream.writeByte(<span class="tok-str">','</span>);</span>
<span class="line" id="L1215">                    }</span>
<span class="line" id="L1216">                    <span class="tok-kw">if</span> (child_options.whitespace) |child_whitespace| {</span>
<span class="line" id="L1217">                        <span class="tok-kw">try</span> child_whitespace.outputIndent(out_stream);</span>
<span class="line" id="L1218">                    }</span>
<span class="line" id="L1219"></span>
<span class="line" id="L1220">                    <span class="tok-kw">try</span> stringify(entry.key_ptr.*, options, out_stream);</span>
<span class="line" id="L1221">                    <span class="tok-kw">try</span> out_stream.writeByte(<span class="tok-str">':'</span>);</span>
<span class="line" id="L1222">                    <span class="tok-kw">if</span> (child_options.whitespace) |child_whitespace| {</span>
<span class="line" id="L1223">                        <span class="tok-kw">if</span> (child_whitespace.separator) {</span>
<span class="line" id="L1224">                            <span class="tok-kw">try</span> out_stream.writeByte(<span class="tok-str">' '</span>);</span>
<span class="line" id="L1225">                        }</span>
<span class="line" id="L1226">                    }</span>
<span class="line" id="L1227">                    <span class="tok-kw">try</span> stringify(entry.value_ptr.*, child_options, out_stream);</span>
<span class="line" id="L1228">                }</span>
<span class="line" id="L1229">                <span class="tok-kw">if</span> (field_output) {</span>
<span class="line" id="L1230">                    <span class="tok-kw">if</span> (options.whitespace) |whitespace| {</span>
<span class="line" id="L1231">                        <span class="tok-kw">try</span> whitespace.outputIndent(out_stream);</span>
<span class="line" id="L1232">                    }</span>
<span class="line" id="L1233">                }</span>
<span class="line" id="L1234">                <span class="tok-kw">try</span> out_stream.writeByte(<span class="tok-str">'}'</span>);</span>
<span class="line" id="L1235">            },</span>
<span class="line" id="L1236">        }</span>
<span class="line" id="L1237">    }</span>
<span class="line" id="L1238"></span>
<span class="line" id="L1239">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">dump</span>(self: Value) <span class="tok-type">void</span> {</span>
<span class="line" id="L1240">        std.debug.getStderrMutex().lock();</span>
<span class="line" id="L1241">        <span class="tok-kw">defer</span> std.debug.getStderrMutex().unlock();</span>
<span class="line" id="L1242"></span>
<span class="line" id="L1243">        <span class="tok-kw">const</span> stderr = std.io.getStdErr().writer();</span>
<span class="line" id="L1244">        std.json.stringify(self, std.json.StringifyOptions{ .whitespace = <span class="tok-null">null</span> }, stderr) <span class="tok-kw">catch</span> <span class="tok-kw">return</span>;</span>
<span class="line" id="L1245">    }</span>
<span class="line" id="L1246">};</span>
<span class="line" id="L1247"></span>
<span class="line" id="L1248"><span class="tok-comment">/// parse tokens from a stream, returning `false` if they do not decode to `value`</span></span>
<span class="line" id="L1249"><span class="tok-kw">fn</span> <span class="tok-fn">parsesTo</span>(<span class="tok-kw">comptime</span> T: <span class="tok-type">type</span>, value: T, tokens: *TokenStream, options: ParseOptions) !<span class="tok-type">bool</span> {</span>
<span class="line" id="L1250">    <span class="tok-comment">// TODO: should be able to write this function to not require an allocator</span>
</span>
<span class="line" id="L1251">    <span class="tok-kw">const</span> tmp = <span class="tok-kw">try</span> parse(T, tokens, options);</span>
<span class="line" id="L1252">    <span class="tok-kw">defer</span> parseFree(T, tmp, options);</span>
<span class="line" id="L1253"></span>
<span class="line" id="L1254">    <span class="tok-kw">return</span> parsedEqual(tmp, value);</span>
<span class="line" id="L1255">}</span>
<span class="line" id="L1256"></span>
<span class="line" id="L1257"><span class="tok-comment">/// Returns if a value returned by `parse` is deep-equal to another value</span></span>
<span class="line" id="L1258"><span class="tok-kw">fn</span> <span class="tok-fn">parsedEqual</span>(a: <span class="tok-kw">anytype</span>, b: <span class="tok-builtin">@TypeOf</span>(a)) <span class="tok-type">bool</span> {</span>
<span class="line" id="L1259">    <span class="tok-kw">switch</span> (<span class="tok-builtin">@typeInfo</span>(<span class="tok-builtin">@TypeOf</span>(a))) {</span>
<span class="line" id="L1260">        .Optional =&gt; {</span>
<span class="line" id="L1261">            <span class="tok-kw">if</span> (a == <span class="tok-null">null</span> <span class="tok-kw">and</span> b == <span class="tok-null">null</span>) <span class="tok-kw">return</span> <span class="tok-null">true</span>;</span>
<span class="line" id="L1262">            <span class="tok-kw">if</span> (a == <span class="tok-null">null</span> <span class="tok-kw">or</span> b == <span class="tok-null">null</span>) <span class="tok-kw">return</span> <span class="tok-null">false</span>;</span>
<span class="line" id="L1263">            <span class="tok-kw">return</span> parsedEqual(a.?, b.?);</span>
<span class="line" id="L1264">        },</span>
<span class="line" id="L1265">        .Union =&gt; |info| {</span>
<span class="line" id="L1266">            <span class="tok-kw">if</span> (info.tag_type) |UnionTag| {</span>
<span class="line" id="L1267">                <span class="tok-kw">const</span> tag_a = std.meta.activeTag(a);</span>
<span class="line" id="L1268">                <span class="tok-kw">const</span> tag_b = std.meta.activeTag(b);</span>
<span class="line" id="L1269">                <span class="tok-kw">if</span> (tag_a != tag_b) <span class="tok-kw">return</span> <span class="tok-null">false</span>;</span>
<span class="line" id="L1270"></span>
<span class="line" id="L1271">                <span class="tok-kw">inline</span> <span class="tok-kw">for</span> (info.fields) |field_info| {</span>
<span class="line" id="L1272">                    <span class="tok-kw">if</span> (<span class="tok-builtin">@field</span>(UnionTag, field_info.name) == tag_a) {</span>
<span class="line" id="L1273">                        <span class="tok-kw">return</span> parsedEqual(<span class="tok-builtin">@field</span>(a, field_info.name), <span class="tok-builtin">@field</span>(b, field_info.name));</span>
<span class="line" id="L1274">                    }</span>
<span class="line" id="L1275">                }</span>
<span class="line" id="L1276">                <span class="tok-kw">return</span> <span class="tok-null">false</span>;</span>
<span class="line" id="L1277">            } <span class="tok-kw">else</span> {</span>
<span class="line" id="L1278">                <span class="tok-kw">unreachable</span>;</span>
<span class="line" id="L1279">            }</span>
<span class="line" id="L1280">        },</span>
<span class="line" id="L1281">        .Array =&gt; {</span>
<span class="line" id="L1282">            <span class="tok-kw">for</span> (a) |e, i|</span>
<span class="line" id="L1283">                <span class="tok-kw">if</span> (!parsedEqual(e, b[i])) <span class="tok-kw">return</span> <span class="tok-null">false</span>;</span>
<span class="line" id="L1284">            <span class="tok-kw">return</span> <span class="tok-null">true</span>;</span>
<span class="line" id="L1285">        },</span>
<span class="line" id="L1286">        .Struct =&gt; |info| {</span>
<span class="line" id="L1287">            <span class="tok-kw">inline</span> <span class="tok-kw">for</span> (info.fields) |field_info| {</span>
<span class="line" id="L1288">                <span class="tok-kw">if</span> (!parsedEqual(<span class="tok-builtin">@field</span>(a, field_info.name), <span class="tok-builtin">@field</span>(b, field_info.name))) <span class="tok-kw">return</span> <span class="tok-null">false</span>;</span>
<span class="line" id="L1289">            }</span>
<span class="line" id="L1290">            <span class="tok-kw">return</span> <span class="tok-null">true</span>;</span>
<span class="line" id="L1291">        },</span>
<span class="line" id="L1292">        .Pointer =&gt; |ptrInfo| <span class="tok-kw">switch</span> (ptrInfo.size) {</span>
<span class="line" id="L1293">            .One =&gt; <span class="tok-kw">return</span> parsedEqual(a.*, b.*),</span>
<span class="line" id="L1294">            .Slice =&gt; {</span>
<span class="line" id="L1295">                <span class="tok-kw">if</span> (a.len != b.len) <span class="tok-kw">return</span> <span class="tok-null">false</span>;</span>
<span class="line" id="L1296">                <span class="tok-kw">for</span> (a) |e, i|</span>
<span class="line" id="L1297">                    <span class="tok-kw">if</span> (!parsedEqual(e, b[i])) <span class="tok-kw">return</span> <span class="tok-null">false</span>;</span>
<span class="line" id="L1298">                <span class="tok-kw">return</span> <span class="tok-null">true</span>;</span>
<span class="line" id="L1299">            },</span>
<span class="line" id="L1300">            .Many, .C =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L1301">        },</span>
<span class="line" id="L1302">        <span class="tok-kw">else</span> =&gt; <span class="tok-kw">return</span> a == b,</span>
<span class="line" id="L1303">    }</span>
<span class="line" id="L1304">    <span class="tok-kw">unreachable</span>;</span>
<span class="line" id="L1305">}</span>
<span class="line" id="L1306"></span>
<span class="line" id="L1307"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> ParseOptions = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L1308">    allocator: ?Allocator = <span class="tok-null">null</span>,</span>
<span class="line" id="L1309"></span>
<span class="line" id="L1310">    <span class="tok-comment">/// Behaviour when a duplicate field is encountered.</span></span>
<span class="line" id="L1311">    duplicate_field_behavior: <span class="tok-kw">enum</span> {</span>
<span class="line" id="L1312">        UseFirst,</span>
<span class="line" id="L1313">        Error,</span>
<span class="line" id="L1314">        UseLast,</span>
<span class="line" id="L1315">    } = .Error,</span>
<span class="line" id="L1316"></span>
<span class="line" id="L1317">    <span class="tok-comment">/// If false, finding an unknown field returns an error.</span></span>
<span class="line" id="L1318">    ignore_unknown_fields: <span class="tok-type">bool</span> = <span class="tok-null">false</span>,</span>
<span class="line" id="L1319"></span>
<span class="line" id="L1320">    allow_trailing_data: <span class="tok-type">bool</span> = <span class="tok-null">false</span>,</span>
<span class="line" id="L1321">};</span>
<span class="line" id="L1322"></span>
<span class="line" id="L1323"><span class="tok-kw">const</span> SkipValueError = <span class="tok-kw">error</span>{UnexpectedJsonDepth} || TokenStream.Error;</span>
<span class="line" id="L1324"></span>
<span class="line" id="L1325"><span class="tok-kw">fn</span> <span class="tok-fn">skipValue</span>(tokens: *TokenStream) SkipValueError!<span class="tok-type">void</span> {</span>
<span class="line" id="L1326">    <span class="tok-kw">const</span> original_depth = tokens.stackUsed();</span>
<span class="line" id="L1327"></span>
<span class="line" id="L1328">    <span class="tok-comment">// Return an error if no value is found</span>
</span>
<span class="line" id="L1329">    _ = <span class="tok-kw">try</span> tokens.next();</span>
<span class="line" id="L1330">    <span class="tok-kw">if</span> (tokens.stackUsed() &lt; original_depth) <span class="tok-kw">return</span> <span class="tok-kw">error</span>.UnexpectedJsonDepth;</span>
<span class="line" id="L1331">    <span class="tok-kw">if</span> (tokens.stackUsed() == original_depth) <span class="tok-kw">return</span>;</span>
<span class="line" id="L1332"></span>
<span class="line" id="L1333">    <span class="tok-kw">while</span> (<span class="tok-kw">try</span> tokens.next()) |_| {</span>
<span class="line" id="L1334">        <span class="tok-kw">if</span> (tokens.stackUsed() == original_depth) <span class="tok-kw">return</span>;</span>
<span class="line" id="L1335">    }</span>
<span class="line" id="L1336">}</span>
<span class="line" id="L1337"></span>
<span class="line" id="L1338"><span class="tok-kw">fn</span> <span class="tok-fn">ParseInternalError</span>(<span class="tok-kw">comptime</span> T: <span class="tok-type">type</span>) <span class="tok-type">type</span> {</span>
<span class="line" id="L1339">    <span class="tok-comment">// `inferred_types` is used to avoid infinite recursion for recursive type definitions.</span>
</span>
<span class="line" id="L1340">    <span class="tok-kw">const</span> inferred_types = [_]<span class="tok-type">type</span>{};</span>
<span class="line" id="L1341">    <span class="tok-kw">return</span> ParseInternalErrorImpl(T, &amp;inferred_types);</span>
<span class="line" id="L1342">}</span>
<span class="line" id="L1343"></span>
<span class="line" id="L1344"><span class="tok-kw">fn</span> <span class="tok-fn">ParseInternalErrorImpl</span>(<span class="tok-kw">comptime</span> T: <span class="tok-type">type</span>, <span class="tok-kw">comptime</span> inferred_types: []<span class="tok-kw">const</span> <span class="tok-type">type</span>) <span class="tok-type">type</span> {</span>
<span class="line" id="L1345">    <span class="tok-kw">for</span> (inferred_types) |ty| {</span>
<span class="line" id="L1346">        <span class="tok-kw">if</span> (T == ty) <span class="tok-kw">return</span> <span class="tok-kw">error</span>{};</span>
<span class="line" id="L1347">    }</span>
<span class="line" id="L1348"></span>
<span class="line" id="L1349">    <span class="tok-kw">switch</span> (<span class="tok-builtin">@typeInfo</span>(T)) {</span>
<span class="line" id="L1350">        .Bool =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>{UnexpectedToken},</span>
<span class="line" id="L1351">        .Float, .ComptimeFloat =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>{UnexpectedToken} || std.fmt.ParseFloatError,</span>
<span class="line" id="L1352">        .Int, .ComptimeInt =&gt; {</span>
<span class="line" id="L1353">            <span class="tok-kw">return</span> <span class="tok-kw">error</span>{ UnexpectedToken, InvalidNumber, Overflow } ||</span>
<span class="line" id="L1354">                std.fmt.ParseIntError || std.fmt.ParseFloatError;</span>
<span class="line" id="L1355">        },</span>
<span class="line" id="L1356">        .Optional =&gt; |optionalInfo| {</span>
<span class="line" id="L1357">            <span class="tok-kw">return</span> ParseInternalErrorImpl(optionalInfo.child, inferred_types ++ [_]<span class="tok-type">type</span>{T});</span>
<span class="line" id="L1358">        },</span>
<span class="line" id="L1359">        .Enum =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>{ UnexpectedToken, InvalidEnumTag } || std.fmt.ParseIntError ||</span>
<span class="line" id="L1360">            std.meta.IntToEnumError || std.meta.IntToEnumError,</span>
<span class="line" id="L1361">        .Union =&gt; |unionInfo| {</span>
<span class="line" id="L1362">            <span class="tok-kw">if</span> (unionInfo.tag_type) |_| {</span>
<span class="line" id="L1363">                <span class="tok-kw">var</span> errors = <span class="tok-kw">error</span>{NoUnionMembersMatched};</span>
<span class="line" id="L1364">                <span class="tok-kw">for</span> (unionInfo.fields) |u_field| {</span>
<span class="line" id="L1365">                    errors = errors || ParseInternalErrorImpl(u_field.field_type, inferred_types ++ [_]<span class="tok-type">type</span>{T});</span>
<span class="line" id="L1366">                }</span>
<span class="line" id="L1367">                <span class="tok-kw">return</span> errors;</span>
<span class="line" id="L1368">            } <span class="tok-kw">else</span> {</span>
<span class="line" id="L1369">                <span class="tok-builtin">@compileError</span>(<span class="tok-str">&quot;Unable to parse into untagged union '&quot;</span> ++ <span class="tok-builtin">@typeName</span>(T) ++ <span class="tok-str">&quot;'&quot;</span>);</span>
<span class="line" id="L1370">            }</span>
<span class="line" id="L1371">        },</span>
<span class="line" id="L1372">        .Struct =&gt; |structInfo| {</span>
<span class="line" id="L1373">            <span class="tok-kw">var</span> errors = <span class="tok-kw">error</span>{</span>
<span class="line" id="L1374">                DuplicateJSONField,</span>
<span class="line" id="L1375">                UnexpectedEndOfJson,</span>
<span class="line" id="L1376">                UnexpectedToken,</span>
<span class="line" id="L1377">                UnexpectedValue,</span>
<span class="line" id="L1378">                UnknownField,</span>
<span class="line" id="L1379">                MissingField,</span>
<span class="line" id="L1380">            } || SkipValueError || TokenStream.Error;</span>
<span class="line" id="L1381">            <span class="tok-kw">for</span> (structInfo.fields) |field| {</span>
<span class="line" id="L1382">                errors = errors || ParseInternalErrorImpl(field.field_type, inferred_types ++ [_]<span class="tok-type">type</span>{T});</span>
<span class="line" id="L1383">            }</span>
<span class="line" id="L1384">            <span class="tok-kw">return</span> errors;</span>
<span class="line" id="L1385">        },</span>
<span class="line" id="L1386">        .Array =&gt; |arrayInfo| {</span>
<span class="line" id="L1387">            <span class="tok-kw">return</span> <span class="tok-kw">error</span>{ UnexpectedEndOfJson, UnexpectedToken } || TokenStream.Error ||</span>
<span class="line" id="L1388">                UnescapeValidStringError ||</span>
<span class="line" id="L1389">                ParseInternalErrorImpl(arrayInfo.child, inferred_types ++ [_]<span class="tok-type">type</span>{T});</span>
<span class="line" id="L1390">        },</span>
<span class="line" id="L1391">        .Pointer =&gt; |ptrInfo| {</span>
<span class="line" id="L1392">            <span class="tok-kw">var</span> errors = <span class="tok-kw">error</span>{AllocatorRequired} || std.mem.Allocator.Error;</span>
<span class="line" id="L1393">            <span class="tok-kw">switch</span> (ptrInfo.size) {</span>
<span class="line" id="L1394">                .One =&gt; {</span>
<span class="line" id="L1395">                    <span class="tok-kw">return</span> errors || ParseInternalErrorImpl(ptrInfo.child, inferred_types ++ [_]<span class="tok-type">type</span>{T});</span>
<span class="line" id="L1396">                },</span>
<span class="line" id="L1397">                .Slice =&gt; {</span>
<span class="line" id="L1398">                    <span class="tok-kw">return</span> errors || <span class="tok-kw">error</span>{ UnexpectedEndOfJson, UnexpectedToken } ||</span>
<span class="line" id="L1399">                        ParseInternalErrorImpl(ptrInfo.child, inferred_types ++ [_]<span class="tok-type">type</span>{T}) ||</span>
<span class="line" id="L1400">                        UnescapeValidStringError || TokenStream.Error;</span>
<span class="line" id="L1401">                },</span>
<span class="line" id="L1402">                <span class="tok-kw">else</span> =&gt; <span class="tok-builtin">@compileError</span>(<span class="tok-str">&quot;Unable to parse into type '&quot;</span> ++ <span class="tok-builtin">@typeName</span>(T) ++ <span class="tok-str">&quot;'&quot;</span>),</span>
<span class="line" id="L1403">            }</span>
<span class="line" id="L1404">        },</span>
<span class="line" id="L1405">        <span class="tok-kw">else</span> =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>{},</span>
<span class="line" id="L1406">    }</span>
<span class="line" id="L1407">    <span class="tok-kw">unreachable</span>;</span>
<span class="line" id="L1408">}</span>
<span class="line" id="L1409"></span>
<span class="line" id="L1410"><span class="tok-kw">fn</span> <span class="tok-fn">parseInternal</span>(</span>
<span class="line" id="L1411">    <span class="tok-kw">comptime</span> T: <span class="tok-type">type</span>,</span>
<span class="line" id="L1412">    token: Token,</span>
<span class="line" id="L1413">    tokens: *TokenStream,</span>
<span class="line" id="L1414">    options: ParseOptions,</span>
<span class="line" id="L1415">) ParseInternalError(T)!T {</span>
<span class="line" id="L1416">    <span class="tok-kw">switch</span> (<span class="tok-builtin">@typeInfo</span>(T)) {</span>
<span class="line" id="L1417">        .Bool =&gt; {</span>
<span class="line" id="L1418">            <span class="tok-kw">return</span> <span class="tok-kw">switch</span> (token) {</span>
<span class="line" id="L1419">                .True =&gt; <span class="tok-null">true</span>,</span>
<span class="line" id="L1420">                .False =&gt; <span class="tok-null">false</span>,</span>
<span class="line" id="L1421">                <span class="tok-kw">else</span> =&gt; <span class="tok-kw">error</span>.UnexpectedToken,</span>
<span class="line" id="L1422">            };</span>
<span class="line" id="L1423">        },</span>
<span class="line" id="L1424">        .Float, .ComptimeFloat =&gt; {</span>
<span class="line" id="L1425">            <span class="tok-kw">switch</span> (token) {</span>
<span class="line" id="L1426">                .Number =&gt; |numberToken| <span class="tok-kw">return</span> <span class="tok-kw">try</span> std.fmt.parseFloat(T, numberToken.slice(tokens.slice, tokens.i - <span class="tok-number">1</span>)),</span>
<span class="line" id="L1427">                .String =&gt; |stringToken| <span class="tok-kw">return</span> <span class="tok-kw">try</span> std.fmt.parseFloat(T, stringToken.slice(tokens.slice, tokens.i - <span class="tok-number">1</span>)),</span>
<span class="line" id="L1428">                <span class="tok-kw">else</span> =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.UnexpectedToken,</span>
<span class="line" id="L1429">            }</span>
<span class="line" id="L1430">        },</span>
<span class="line" id="L1431">        .Int, .ComptimeInt =&gt; {</span>
<span class="line" id="L1432">            <span class="tok-kw">switch</span> (token) {</span>
<span class="line" id="L1433">                .Number =&gt; |numberToken| {</span>
<span class="line" id="L1434">                    <span class="tok-kw">if</span> (numberToken.is_integer)</span>
<span class="line" id="L1435">                        <span class="tok-kw">return</span> <span class="tok-kw">try</span> std.fmt.parseInt(T, numberToken.slice(tokens.slice, tokens.i - <span class="tok-number">1</span>), <span class="tok-number">10</span>);</span>
<span class="line" id="L1436">                    <span class="tok-kw">const</span> float = <span class="tok-kw">try</span> std.fmt.parseFloat(<span class="tok-type">f128</span>, numberToken.slice(tokens.slice, tokens.i - <span class="tok-number">1</span>));</span>
<span class="line" id="L1437">                    <span class="tok-kw">if</span> (<span class="tok-builtin">@round</span>(float) != float) <span class="tok-kw">return</span> <span class="tok-kw">error</span>.InvalidNumber;</span>
<span class="line" id="L1438">                    <span class="tok-kw">if</span> (float &gt; std.math.maxInt(T) <span class="tok-kw">or</span> float &lt; std.math.minInt(T)) <span class="tok-kw">return</span> <span class="tok-kw">error</span>.Overflow;</span>
<span class="line" id="L1439">                    <span class="tok-kw">return</span> <span class="tok-builtin">@floatToInt</span>(T, float);</span>
<span class="line" id="L1440">                },</span>
<span class="line" id="L1441">                .String =&gt; |stringToken| {</span>
<span class="line" id="L1442">                    <span class="tok-kw">return</span> std.fmt.parseInt(T, stringToken.slice(tokens.slice, tokens.i - <span class="tok-number">1</span>), <span class="tok-number">10</span>) <span class="tok-kw">catch</span> |err| {</span>
<span class="line" id="L1443">                        <span class="tok-kw">switch</span> (err) {</span>
<span class="line" id="L1444">                            <span class="tok-kw">error</span>.Overflow =&gt; <span class="tok-kw">return</span> err,</span>
<span class="line" id="L1445">                            <span class="tok-kw">error</span>.InvalidCharacter =&gt; {</span>
<span class="line" id="L1446">                                <span class="tok-kw">const</span> float = <span class="tok-kw">try</span> std.fmt.parseFloat(<span class="tok-type">f128</span>, stringToken.slice(tokens.slice, tokens.i - <span class="tok-number">1</span>));</span>
<span class="line" id="L1447">                                <span class="tok-kw">if</span> (<span class="tok-builtin">@round</span>(float) != float) <span class="tok-kw">return</span> <span class="tok-kw">error</span>.InvalidNumber;</span>
<span class="line" id="L1448">                                <span class="tok-kw">if</span> (float &gt; std.math.maxInt(T) <span class="tok-kw">or</span> float &lt; std.math.minInt(T)) <span class="tok-kw">return</span> <span class="tok-kw">error</span>.Overflow;</span>
<span class="line" id="L1449">                                <span class="tok-kw">return</span> <span class="tok-builtin">@floatToInt</span>(T, float);</span>
<span class="line" id="L1450">                            },</span>
<span class="line" id="L1451">                        }</span>
<span class="line" id="L1452">                    };</span>
<span class="line" id="L1453">                },</span>
<span class="line" id="L1454">                <span class="tok-kw">else</span> =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.UnexpectedToken,</span>
<span class="line" id="L1455">            }</span>
<span class="line" id="L1456">        },</span>
<span class="line" id="L1457">        .Optional =&gt; |optionalInfo| {</span>
<span class="line" id="L1458">            <span class="tok-kw">if</span> (token == .Null) {</span>
<span class="line" id="L1459">                <span class="tok-kw">return</span> <span class="tok-null">null</span>;</span>
<span class="line" id="L1460">            } <span class="tok-kw">else</span> {</span>
<span class="line" id="L1461">                <span class="tok-kw">return</span> <span class="tok-kw">try</span> parseInternal(optionalInfo.child, token, tokens, options);</span>
<span class="line" id="L1462">            }</span>
<span class="line" id="L1463">        },</span>
<span class="line" id="L1464">        .Enum =&gt; |enumInfo| {</span>
<span class="line" id="L1465">            <span class="tok-kw">switch</span> (token) {</span>
<span class="line" id="L1466">                .Number =&gt; |numberToken| {</span>
<span class="line" id="L1467">                    <span class="tok-kw">if</span> (!numberToken.is_integer) <span class="tok-kw">return</span> <span class="tok-kw">error</span>.UnexpectedToken;</span>
<span class="line" id="L1468">                    <span class="tok-kw">const</span> n = <span class="tok-kw">try</span> std.fmt.parseInt(enumInfo.tag_type, numberToken.slice(tokens.slice, tokens.i - <span class="tok-number">1</span>), <span class="tok-number">10</span>);</span>
<span class="line" id="L1469">                    <span class="tok-kw">return</span> <span class="tok-kw">try</span> std.meta.intToEnum(T, n);</span>
<span class="line" id="L1470">                },</span>
<span class="line" id="L1471">                .String =&gt; |stringToken| {</span>
<span class="line" id="L1472">                    <span class="tok-kw">const</span> source_slice = stringToken.slice(tokens.slice, tokens.i - <span class="tok-number">1</span>);</span>
<span class="line" id="L1473">                    <span class="tok-kw">switch</span> (stringToken.escapes) {</span>
<span class="line" id="L1474">                        .None =&gt; <span class="tok-kw">return</span> std.meta.stringToEnum(T, source_slice) <span class="tok-kw">orelse</span> <span class="tok-kw">return</span> <span class="tok-kw">error</span>.InvalidEnumTag,</span>
<span class="line" id="L1475">                        .Some =&gt; {</span>
<span class="line" id="L1476">                            <span class="tok-kw">inline</span> <span class="tok-kw">for</span> (enumInfo.fields) |field| {</span>
<span class="line" id="L1477">                                <span class="tok-kw">if</span> (field.name.len == stringToken.decodedLength() <span class="tok-kw">and</span> encodesTo(field.name, source_slice)) {</span>
<span class="line" id="L1478">                                    <span class="tok-kw">return</span> <span class="tok-builtin">@field</span>(T, field.name);</span>
<span class="line" id="L1479">                                }</span>
<span class="line" id="L1480">                            }</span>
<span class="line" id="L1481">                            <span class="tok-kw">return</span> <span class="tok-kw">error</span>.InvalidEnumTag;</span>
<span class="line" id="L1482">                        },</span>
<span class="line" id="L1483">                    }</span>
<span class="line" id="L1484">                },</span>
<span class="line" id="L1485">                <span class="tok-kw">else</span> =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.UnexpectedToken,</span>
<span class="line" id="L1486">            }</span>
<span class="line" id="L1487">        },</span>
<span class="line" id="L1488">        .Union =&gt; |unionInfo| {</span>
<span class="line" id="L1489">            <span class="tok-kw">if</span> (unionInfo.tag_type) |_| {</span>
<span class="line" id="L1490">                <span class="tok-comment">// try each of the union fields until we find one that matches</span>
</span>
<span class="line" id="L1491">                <span class="tok-kw">inline</span> <span class="tok-kw">for</span> (unionInfo.fields) |u_field| {</span>
<span class="line" id="L1492">                    <span class="tok-comment">// take a copy of tokens so we can withhold mutations until success</span>
</span>
<span class="line" id="L1493">                    <span class="tok-kw">var</span> tokens_copy = tokens.*;</span>
<span class="line" id="L1494">                    <span class="tok-kw">if</span> (parseInternal(u_field.field_type, token, &amp;tokens_copy, options)) |value| {</span>
<span class="line" id="L1495">                        tokens.* = tokens_copy;</span>
<span class="line" id="L1496">                        <span class="tok-kw">return</span> <span class="tok-builtin">@unionInit</span>(T, u_field.name, value);</span>
<span class="line" id="L1497">                    } <span class="tok-kw">else</span> |err| {</span>
<span class="line" id="L1498">                        <span class="tok-comment">// Bubble up error.OutOfMemory</span>
</span>
<span class="line" id="L1499">                        <span class="tok-comment">// Parsing some types won't have OutOfMemory in their</span>
</span>
<span class="line" id="L1500">                        <span class="tok-comment">// error-sets, for the condition to be valid, merge it in.</span>
</span>
<span class="line" id="L1501">                        <span class="tok-kw">if</span> (<span class="tok-builtin">@as</span>(<span class="tok-builtin">@TypeOf</span>(err) || <span class="tok-kw">error</span>{OutOfMemory}, err) == <span class="tok-kw">error</span>.OutOfMemory) <span class="tok-kw">return</span> err;</span>
<span class="line" id="L1502">                        <span class="tok-comment">// Bubble up AllocatorRequired, as it indicates missing option</span>
</span>
<span class="line" id="L1503">                        <span class="tok-kw">if</span> (<span class="tok-builtin">@as</span>(<span class="tok-builtin">@TypeOf</span>(err) || <span class="tok-kw">error</span>{AllocatorRequired}, err) == <span class="tok-kw">error</span>.AllocatorRequired) <span class="tok-kw">return</span> err;</span>
<span class="line" id="L1504">                        <span class="tok-comment">// otherwise continue through the `inline for`</span>
</span>
<span class="line" id="L1505">                    }</span>
<span class="line" id="L1506">                }</span>
<span class="line" id="L1507">                <span class="tok-kw">return</span> <span class="tok-kw">error</span>.NoUnionMembersMatched;</span>
<span class="line" id="L1508">            } <span class="tok-kw">else</span> {</span>
<span class="line" id="L1509">                <span class="tok-builtin">@compileError</span>(<span class="tok-str">&quot;Unable to parse into untagged union '&quot;</span> ++ <span class="tok-builtin">@typeName</span>(T) ++ <span class="tok-str">&quot;'&quot;</span>);</span>
<span class="line" id="L1510">            }</span>
<span class="line" id="L1511">        },</span>
<span class="line" id="L1512">        .Struct =&gt; |structInfo| {</span>
<span class="line" id="L1513">            <span class="tok-kw">switch</span> (token) {</span>
<span class="line" id="L1514">                .ObjectBegin =&gt; {},</span>
<span class="line" id="L1515">                <span class="tok-kw">else</span> =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.UnexpectedToken,</span>
<span class="line" id="L1516">            }</span>
<span class="line" id="L1517">            <span class="tok-kw">var</span> r: T = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L1518">            <span class="tok-kw">var</span> fields_seen = [_]<span class="tok-type">bool</span>{<span class="tok-null">false</span>} ** structInfo.fields.len;</span>
<span class="line" id="L1519">            <span class="tok-kw">errdefer</span> {</span>
<span class="line" id="L1520">                <span class="tok-kw">inline</span> <span class="tok-kw">for</span> (structInfo.fields) |field, i| {</span>
<span class="line" id="L1521">                    <span class="tok-kw">if</span> (fields_seen[i] <span class="tok-kw">and</span> !field.is_comptime) {</span>
<span class="line" id="L1522">                        parseFree(field.field_type, <span class="tok-builtin">@field</span>(r, field.name), options);</span>
<span class="line" id="L1523">                    }</span>
<span class="line" id="L1524">                }</span>
<span class="line" id="L1525">            }</span>
<span class="line" id="L1526"></span>
<span class="line" id="L1527">            <span class="tok-kw">while</span> (<span class="tok-null">true</span>) {</span>
<span class="line" id="L1528">                <span class="tok-kw">switch</span> ((<span class="tok-kw">try</span> tokens.next()) <span class="tok-kw">orelse</span> <span class="tok-kw">return</span> <span class="tok-kw">error</span>.UnexpectedEndOfJson) {</span>
<span class="line" id="L1529">                    .ObjectEnd =&gt; <span class="tok-kw">break</span>,</span>
<span class="line" id="L1530">                    .String =&gt; |stringToken| {</span>
<span class="line" id="L1531">                        <span class="tok-kw">const</span> key_source_slice = stringToken.slice(tokens.slice, tokens.i - <span class="tok-number">1</span>);</span>
<span class="line" id="L1532">                        <span class="tok-kw">var</span> child_options = options;</span>
<span class="line" id="L1533">                        child_options.allow_trailing_data = <span class="tok-null">true</span>;</span>
<span class="line" id="L1534">                        <span class="tok-kw">var</span> found = <span class="tok-null">false</span>;</span>
<span class="line" id="L1535">                        <span class="tok-kw">inline</span> <span class="tok-kw">for</span> (structInfo.fields) |field, i| {</span>
<span class="line" id="L1536">                            <span class="tok-comment">// TODO: using switches here segfault the compiler (#2727?)</span>
</span>
<span class="line" id="L1537">                            <span class="tok-kw">if</span> ((stringToken.escapes == .None <span class="tok-kw">and</span> mem.eql(<span class="tok-type">u8</span>, field.name, key_source_slice)) <span class="tok-kw">or</span> (stringToken.escapes == .Some <span class="tok-kw">and</span> (field.name.len == stringToken.decodedLength() <span class="tok-kw">and</span> encodesTo(field.name, key_source_slice)))) {</span>
<span class="line" id="L1538">                                <span class="tok-comment">// if (switch (stringToken.escapes) {</span>
</span>
<span class="line" id="L1539">                                <span class="tok-comment">//     .None =&gt; mem.eql(u8, field.name, key_source_slice),</span>
</span>
<span class="line" id="L1540">                                <span class="tok-comment">//     .Some =&gt; (field.name.len == stringToken.decodedLength() and encodesTo(field.name, key_source_slice)),</span>
</span>
<span class="line" id="L1541">                                <span class="tok-comment">// }) {</span>
</span>
<span class="line" id="L1542">                                <span class="tok-kw">if</span> (fields_seen[i]) {</span>
<span class="line" id="L1543">                                    <span class="tok-comment">// switch (options.duplicate_field_behavior) {</span>
</span>
<span class="line" id="L1544">                                    <span class="tok-comment">//     .UseFirst =&gt; {},</span>
</span>
<span class="line" id="L1545">                                    <span class="tok-comment">//     .Error =&gt; {},</span>
</span>
<span class="line" id="L1546">                                    <span class="tok-comment">//     .UseLast =&gt; {},</span>
</span>
<span class="line" id="L1547">                                    <span class="tok-comment">// }</span>
</span>
<span class="line" id="L1548">                                    <span class="tok-kw">if</span> (options.duplicate_field_behavior == .UseFirst) {</span>
<span class="line" id="L1549">                                        <span class="tok-comment">// unconditonally ignore value. for comptime fields, this skips check against default_value</span>
</span>
<span class="line" id="L1550">                                        parseFree(field.field_type, <span class="tok-kw">try</span> parse(field.field_type, tokens, child_options), child_options);</span>
<span class="line" id="L1551">                                        found = <span class="tok-null">true</span>;</span>
<span class="line" id="L1552">                                        <span class="tok-kw">break</span>;</span>
<span class="line" id="L1553">                                    } <span class="tok-kw">else</span> <span class="tok-kw">if</span> (options.duplicate_field_behavior == .Error) {</span>
<span class="line" id="L1554">                                        <span class="tok-kw">return</span> <span class="tok-kw">error</span>.DuplicateJSONField;</span>
<span class="line" id="L1555">                                    } <span class="tok-kw">else</span> <span class="tok-kw">if</span> (options.duplicate_field_behavior == .UseLast) {</span>
<span class="line" id="L1556">                                        <span class="tok-kw">if</span> (!field.is_comptime) {</span>
<span class="line" id="L1557">                                            parseFree(field.field_type, <span class="tok-builtin">@field</span>(r, field.name), child_options);</span>
<span class="line" id="L1558">                                        }</span>
<span class="line" id="L1559">                                        fields_seen[i] = <span class="tok-null">false</span>;</span>
<span class="line" id="L1560">                                    }</span>
<span class="line" id="L1561">                                }</span>
<span class="line" id="L1562">                                <span class="tok-kw">if</span> (field.is_comptime) {</span>
<span class="line" id="L1563">                                    <span class="tok-kw">if</span> (!<span class="tok-kw">try</span> parsesTo(field.field_type, <span class="tok-builtin">@ptrCast</span>(*<span class="tok-kw">const</span> field.field_type, field.default_value.?).*, tokens, child_options)) {</span>
<span class="line" id="L1564">                                        <span class="tok-kw">return</span> <span class="tok-kw">error</span>.UnexpectedValue;</span>
<span class="line" id="L1565">                                    }</span>
<span class="line" id="L1566">                                } <span class="tok-kw">else</span> {</span>
<span class="line" id="L1567">                                    <span class="tok-builtin">@field</span>(r, field.name) = <span class="tok-kw">try</span> parse(field.field_type, tokens, child_options);</span>
<span class="line" id="L1568">                                }</span>
<span class="line" id="L1569">                                fields_seen[i] = <span class="tok-null">true</span>;</span>
<span class="line" id="L1570">                                found = <span class="tok-null">true</span>;</span>
<span class="line" id="L1571">                                <span class="tok-kw">break</span>;</span>
<span class="line" id="L1572">                            }</span>
<span class="line" id="L1573">                        }</span>
<span class="line" id="L1574">                        <span class="tok-kw">if</span> (!found) {</span>
<span class="line" id="L1575">                            <span class="tok-kw">if</span> (options.ignore_unknown_fields) {</span>
<span class="line" id="L1576">                                <span class="tok-kw">try</span> skipValue(tokens);</span>
<span class="line" id="L1577">                                <span class="tok-kw">continue</span>;</span>
<span class="line" id="L1578">                            } <span class="tok-kw">else</span> {</span>
<span class="line" id="L1579">                                <span class="tok-kw">return</span> <span class="tok-kw">error</span>.UnknownField;</span>
<span class="line" id="L1580">                            }</span>
<span class="line" id="L1581">                        }</span>
<span class="line" id="L1582">                    },</span>
<span class="line" id="L1583">                    <span class="tok-kw">else</span> =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.UnexpectedToken,</span>
<span class="line" id="L1584">                }</span>
<span class="line" id="L1585">            }</span>
<span class="line" id="L1586">            <span class="tok-kw">inline</span> <span class="tok-kw">for</span> (structInfo.fields) |field, i| {</span>
<span class="line" id="L1587">                <span class="tok-kw">if</span> (!fields_seen[i]) {</span>
<span class="line" id="L1588">                    <span class="tok-kw">if</span> (field.default_value) |default_ptr| {</span>
<span class="line" id="L1589">                        <span class="tok-kw">if</span> (!field.is_comptime) {</span>
<span class="line" id="L1590">                            <span class="tok-kw">const</span> default = <span class="tok-builtin">@ptrCast</span>(*<span class="tok-kw">const</span> field.field_type, default_ptr).*;</span>
<span class="line" id="L1591">                            <span class="tok-builtin">@field</span>(r, field.name) = default;</span>
<span class="line" id="L1592">                        }</span>
<span class="line" id="L1593">                    } <span class="tok-kw">else</span> {</span>
<span class="line" id="L1594">                        <span class="tok-kw">return</span> <span class="tok-kw">error</span>.MissingField;</span>
<span class="line" id="L1595">                    }</span>
<span class="line" id="L1596">                }</span>
<span class="line" id="L1597">            }</span>
<span class="line" id="L1598">            <span class="tok-kw">return</span> r;</span>
<span class="line" id="L1599">        },</span>
<span class="line" id="L1600">        .Array =&gt; |arrayInfo| {</span>
<span class="line" id="L1601">            <span class="tok-kw">switch</span> (token) {</span>
<span class="line" id="L1602">                .ArrayBegin =&gt; {</span>
<span class="line" id="L1603">                    <span class="tok-kw">var</span> r: T = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L1604">                    <span class="tok-kw">var</span> i: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L1605">                    <span class="tok-kw">var</span> child_options = options;</span>
<span class="line" id="L1606">                    child_options.allow_trailing_data = <span class="tok-null">true</span>;</span>
<span class="line" id="L1607">                    <span class="tok-kw">errdefer</span> {</span>
<span class="line" id="L1608">                        <span class="tok-comment">// Without the r.len check `r[i]` is not allowed</span>
</span>
<span class="line" id="L1609">                        <span class="tok-kw">if</span> (r.len &gt; <span class="tok-number">0</span>) <span class="tok-kw">while</span> (<span class="tok-null">true</span>) : (i -= <span class="tok-number">1</span>) {</span>
<span class="line" id="L1610">                            parseFree(arrayInfo.child, r[i], options);</span>
<span class="line" id="L1611">                            <span class="tok-kw">if</span> (i == <span class="tok-number">0</span>) <span class="tok-kw">break</span>;</span>
<span class="line" id="L1612">                        };</span>
<span class="line" id="L1613">                    }</span>
<span class="line" id="L1614">                    <span class="tok-kw">while</span> (i &lt; r.len) : (i += <span class="tok-number">1</span>) {</span>
<span class="line" id="L1615">                        r[i] = <span class="tok-kw">try</span> parse(arrayInfo.child, tokens, child_options);</span>
<span class="line" id="L1616">                    }</span>
<span class="line" id="L1617">                    <span class="tok-kw">const</span> tok = (<span class="tok-kw">try</span> tokens.next()) <span class="tok-kw">orelse</span> <span class="tok-kw">return</span> <span class="tok-kw">error</span>.UnexpectedEndOfJson;</span>
<span class="line" id="L1618">                    <span class="tok-kw">switch</span> (tok) {</span>
<span class="line" id="L1619">                        .ArrayEnd =&gt; {},</span>
<span class="line" id="L1620">                        <span class="tok-kw">else</span> =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.UnexpectedToken,</span>
<span class="line" id="L1621">                    }</span>
<span class="line" id="L1622">                    <span class="tok-kw">return</span> r;</span>
<span class="line" id="L1623">                },</span>
<span class="line" id="L1624">                .String =&gt; |stringToken| {</span>
<span class="line" id="L1625">                    <span class="tok-kw">if</span> (arrayInfo.child != <span class="tok-type">u8</span>) <span class="tok-kw">return</span> <span class="tok-kw">error</span>.UnexpectedToken;</span>
<span class="line" id="L1626">                    <span class="tok-kw">var</span> r: T = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L1627">                    <span class="tok-kw">const</span> source_slice = stringToken.slice(tokens.slice, tokens.i - <span class="tok-number">1</span>);</span>
<span class="line" id="L1628">                    <span class="tok-kw">switch</span> (stringToken.escapes) {</span>
<span class="line" id="L1629">                        .None =&gt; mem.copy(<span class="tok-type">u8</span>, &amp;r, source_slice),</span>
<span class="line" id="L1630">                        .Some =&gt; <span class="tok-kw">try</span> unescapeValidString(&amp;r, source_slice),</span>
<span class="line" id="L1631">                    }</span>
<span class="line" id="L1632">                    <span class="tok-kw">return</span> r;</span>
<span class="line" id="L1633">                },</span>
<span class="line" id="L1634">                <span class="tok-kw">else</span> =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.UnexpectedToken,</span>
<span class="line" id="L1635">            }</span>
<span class="line" id="L1636">        },</span>
<span class="line" id="L1637">        .Pointer =&gt; |ptrInfo| {</span>
<span class="line" id="L1638">            <span class="tok-kw">const</span> allocator = options.allocator <span class="tok-kw">orelse</span> <span class="tok-kw">return</span> <span class="tok-kw">error</span>.AllocatorRequired;</span>
<span class="line" id="L1639">            <span class="tok-kw">switch</span> (ptrInfo.size) {</span>
<span class="line" id="L1640">                .One =&gt; {</span>
<span class="line" id="L1641">                    <span class="tok-kw">const</span> r: T = <span class="tok-kw">try</span> allocator.create(ptrInfo.child);</span>
<span class="line" id="L1642">                    <span class="tok-kw">errdefer</span> allocator.destroy(r);</span>
<span class="line" id="L1643">                    r.* = <span class="tok-kw">try</span> parseInternal(ptrInfo.child, token, tokens, options);</span>
<span class="line" id="L1644">                    <span class="tok-kw">return</span> r;</span>
<span class="line" id="L1645">                },</span>
<span class="line" id="L1646">                .Slice =&gt; {</span>
<span class="line" id="L1647">                    <span class="tok-kw">switch</span> (token) {</span>
<span class="line" id="L1648">                        .ArrayBegin =&gt; {</span>
<span class="line" id="L1649">                            <span class="tok-kw">var</span> arraylist = std.ArrayList(ptrInfo.child).init(allocator);</span>
<span class="line" id="L1650">                            <span class="tok-kw">errdefer</span> {</span>
<span class="line" id="L1651">                                <span class="tok-kw">while</span> (arraylist.popOrNull()) |v| {</span>
<span class="line" id="L1652">                                    parseFree(ptrInfo.child, v, options);</span>
<span class="line" id="L1653">                                }</span>
<span class="line" id="L1654">                                arraylist.deinit();</span>
<span class="line" id="L1655">                            }</span>
<span class="line" id="L1656"></span>
<span class="line" id="L1657">                            <span class="tok-kw">while</span> (<span class="tok-null">true</span>) {</span>
<span class="line" id="L1658">                                <span class="tok-kw">const</span> tok = (<span class="tok-kw">try</span> tokens.next()) <span class="tok-kw">orelse</span> <span class="tok-kw">return</span> <span class="tok-kw">error</span>.UnexpectedEndOfJson;</span>
<span class="line" id="L1659">                                <span class="tok-kw">switch</span> (tok) {</span>
<span class="line" id="L1660">                                    .ArrayEnd =&gt; <span class="tok-kw">break</span>,</span>
<span class="line" id="L1661">                                    <span class="tok-kw">else</span> =&gt; {},</span>
<span class="line" id="L1662">                                }</span>
<span class="line" id="L1663"></span>
<span class="line" id="L1664">                                <span class="tok-kw">try</span> arraylist.ensureUnusedCapacity(<span class="tok-number">1</span>);</span>
<span class="line" id="L1665">                                <span class="tok-kw">const</span> v = <span class="tok-kw">try</span> parseInternal(ptrInfo.child, tok, tokens, options);</span>
<span class="line" id="L1666">                                arraylist.appendAssumeCapacity(v);</span>
<span class="line" id="L1667">                            }</span>
<span class="line" id="L1668"></span>
<span class="line" id="L1669">                            <span class="tok-kw">if</span> (ptrInfo.sentinel) |some| {</span>
<span class="line" id="L1670">                                <span class="tok-kw">const</span> sentinel_value = <span class="tok-builtin">@ptrCast</span>(*<span class="tok-kw">const</span> ptrInfo.child, some).*;</span>
<span class="line" id="L1671">                                <span class="tok-kw">try</span> arraylist.append(sentinel_value);</span>
<span class="line" id="L1672">                                <span class="tok-kw">const</span> output = arraylist.toOwnedSlice();</span>
<span class="line" id="L1673">                                <span class="tok-kw">return</span> output[<span class="tok-number">0</span> .. output.len - <span class="tok-number">1</span> :sentinel_value];</span>
<span class="line" id="L1674">                            }</span>
<span class="line" id="L1675"></span>
<span class="line" id="L1676">                            <span class="tok-kw">return</span> arraylist.toOwnedSlice();</span>
<span class="line" id="L1677">                        },</span>
<span class="line" id="L1678">                        .String =&gt; |stringToken| {</span>
<span class="line" id="L1679">                            <span class="tok-kw">if</span> (ptrInfo.child != <span class="tok-type">u8</span>) <span class="tok-kw">return</span> <span class="tok-kw">error</span>.UnexpectedToken;</span>
<span class="line" id="L1680">                            <span class="tok-kw">const</span> source_slice = stringToken.slice(tokens.slice, tokens.i - <span class="tok-number">1</span>);</span>
<span class="line" id="L1681">                            <span class="tok-kw">const</span> len = stringToken.decodedLength();</span>
<span class="line" id="L1682">                            <span class="tok-kw">const</span> output = <span class="tok-kw">try</span> allocator.alloc(<span class="tok-type">u8</span>, len + <span class="tok-builtin">@boolToInt</span>(ptrInfo.sentinel != <span class="tok-null">null</span>));</span>
<span class="line" id="L1683">                            <span class="tok-kw">errdefer</span> allocator.free(output);</span>
<span class="line" id="L1684">                            <span class="tok-kw">switch</span> (stringToken.escapes) {</span>
<span class="line" id="L1685">                                .None =&gt; mem.copy(<span class="tok-type">u8</span>, output, source_slice),</span>
<span class="line" id="L1686">                                .Some =&gt; <span class="tok-kw">try</span> unescapeValidString(output, source_slice),</span>
<span class="line" id="L1687">                            }</span>
<span class="line" id="L1688"></span>
<span class="line" id="L1689">                            <span class="tok-kw">if</span> (ptrInfo.sentinel) |some| {</span>
<span class="line" id="L1690">                                <span class="tok-kw">const</span> char = <span class="tok-builtin">@ptrCast</span>(*<span class="tok-kw">const</span> <span class="tok-type">u8</span>, some).*;</span>
<span class="line" id="L1691">                                output[len] = char;</span>
<span class="line" id="L1692">                                <span class="tok-kw">return</span> output[<span class="tok-number">0</span>..len :char];</span>
<span class="line" id="L1693">                            }</span>
<span class="line" id="L1694"></span>
<span class="line" id="L1695">                            <span class="tok-kw">return</span> output;</span>
<span class="line" id="L1696">                        },</span>
<span class="line" id="L1697">                        <span class="tok-kw">else</span> =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.UnexpectedToken,</span>
<span class="line" id="L1698">                    }</span>
<span class="line" id="L1699">                },</span>
<span class="line" id="L1700">                <span class="tok-kw">else</span> =&gt; <span class="tok-builtin">@compileError</span>(<span class="tok-str">&quot;Unable to parse into type '&quot;</span> ++ <span class="tok-builtin">@typeName</span>(T) ++ <span class="tok-str">&quot;'&quot;</span>),</span>
<span class="line" id="L1701">            }</span>
<span class="line" id="L1702">        },</span>
<span class="line" id="L1703">        <span class="tok-kw">else</span> =&gt; <span class="tok-builtin">@compileError</span>(<span class="tok-str">&quot;Unable to parse into type '&quot;</span> ++ <span class="tok-builtin">@typeName</span>(T) ++ <span class="tok-str">&quot;'&quot;</span>),</span>
<span class="line" id="L1704">    }</span>
<span class="line" id="L1705">    <span class="tok-kw">unreachable</span>;</span>
<span class="line" id="L1706">}</span>
<span class="line" id="L1707"></span>
<span class="line" id="L1708"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">ParseError</span>(<span class="tok-kw">comptime</span> T: <span class="tok-type">type</span>) <span class="tok-type">type</span> {</span>
<span class="line" id="L1709">    <span class="tok-kw">return</span> ParseInternalError(T) || <span class="tok-kw">error</span>{UnexpectedEndOfJson} || TokenStream.Error;</span>
<span class="line" id="L1710">}</span>
<span class="line" id="L1711"></span>
<span class="line" id="L1712"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">parse</span>(<span class="tok-kw">comptime</span> T: <span class="tok-type">type</span>, tokens: *TokenStream, options: ParseOptions) ParseError(T)!T {</span>
<span class="line" id="L1713">    <span class="tok-kw">const</span> token = (<span class="tok-kw">try</span> tokens.next()) <span class="tok-kw">orelse</span> <span class="tok-kw">return</span> <span class="tok-kw">error</span>.UnexpectedEndOfJson;</span>
<span class="line" id="L1714">    <span class="tok-kw">const</span> r = <span class="tok-kw">try</span> parseInternal(T, token, tokens, options);</span>
<span class="line" id="L1715">    <span class="tok-kw">errdefer</span> parseFree(T, r, options);</span>
<span class="line" id="L1716">    <span class="tok-kw">if</span> (!options.allow_trailing_data) {</span>
<span class="line" id="L1717">        <span class="tok-kw">if</span> ((<span class="tok-kw">try</span> tokens.next()) != <span class="tok-null">null</span>) <span class="tok-kw">unreachable</span>;</span>
<span class="line" id="L1718">        assert(tokens.i &gt;= tokens.slice.len);</span>
<span class="line" id="L1719">    }</span>
<span class="line" id="L1720">    <span class="tok-kw">return</span> r;</span>
<span class="line" id="L1721">}</span>
<span class="line" id="L1722"></span>
<span class="line" id="L1723"><span class="tok-comment">/// Releases resources created by `parse`.</span></span>
<span class="line" id="L1724"><span class="tok-comment">/// Should be called with the same type and `ParseOptions` that were passed to `parse`</span></span>
<span class="line" id="L1725"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">parseFree</span>(<span class="tok-kw">comptime</span> T: <span class="tok-type">type</span>, value: T, options: ParseOptions) <span class="tok-type">void</span> {</span>
<span class="line" id="L1726">    <span class="tok-kw">switch</span> (<span class="tok-builtin">@typeInfo</span>(T)) {</span>
<span class="line" id="L1727">        .Bool, .Float, .ComptimeFloat, .Int, .ComptimeInt, .Enum =&gt; {},</span>
<span class="line" id="L1728">        .Optional =&gt; {</span>
<span class="line" id="L1729">            <span class="tok-kw">if</span> (value) |v| {</span>
<span class="line" id="L1730">                <span class="tok-kw">return</span> parseFree(<span class="tok-builtin">@TypeOf</span>(v), v, options);</span>
<span class="line" id="L1731">            }</span>
<span class="line" id="L1732">        },</span>
<span class="line" id="L1733">        .Union =&gt; |unionInfo| {</span>
<span class="line" id="L1734">            <span class="tok-kw">if</span> (unionInfo.tag_type) |UnionTagType| {</span>
<span class="line" id="L1735">                <span class="tok-kw">inline</span> <span class="tok-kw">for</span> (unionInfo.fields) |u_field| {</span>
<span class="line" id="L1736">                    <span class="tok-kw">if</span> (value == <span class="tok-builtin">@field</span>(UnionTagType, u_field.name)) {</span>
<span class="line" id="L1737">                        parseFree(u_field.field_type, <span class="tok-builtin">@field</span>(value, u_field.name), options);</span>
<span class="line" id="L1738">                        <span class="tok-kw">break</span>;</span>
<span class="line" id="L1739">                    }</span>
<span class="line" id="L1740">                }</span>
<span class="line" id="L1741">            } <span class="tok-kw">else</span> {</span>
<span class="line" id="L1742">                <span class="tok-kw">unreachable</span>;</span>
<span class="line" id="L1743">            }</span>
<span class="line" id="L1744">        },</span>
<span class="line" id="L1745">        .Struct =&gt; |structInfo| {</span>
<span class="line" id="L1746">            <span class="tok-kw">inline</span> <span class="tok-kw">for</span> (structInfo.fields) |field| {</span>
<span class="line" id="L1747">                <span class="tok-kw">if</span> (!field.is_comptime) {</span>
<span class="line" id="L1748">                    parseFree(field.field_type, <span class="tok-builtin">@field</span>(value, field.name), options);</span>
<span class="line" id="L1749">                }</span>
<span class="line" id="L1750">            }</span>
<span class="line" id="L1751">        },</span>
<span class="line" id="L1752">        .Array =&gt; |arrayInfo| {</span>
<span class="line" id="L1753">            <span class="tok-kw">for</span> (value) |v| {</span>
<span class="line" id="L1754">                parseFree(arrayInfo.child, v, options);</span>
<span class="line" id="L1755">            }</span>
<span class="line" id="L1756">        },</span>
<span class="line" id="L1757">        .Pointer =&gt; |ptrInfo| {</span>
<span class="line" id="L1758">            <span class="tok-kw">const</span> allocator = options.allocator <span class="tok-kw">orelse</span> <span class="tok-kw">unreachable</span>;</span>
<span class="line" id="L1759">            <span class="tok-kw">switch</span> (ptrInfo.size) {</span>
<span class="line" id="L1760">                .One =&gt; {</span>
<span class="line" id="L1761">                    parseFree(ptrInfo.child, value.*, options);</span>
<span class="line" id="L1762">                    allocator.destroy(value);</span>
<span class="line" id="L1763">                },</span>
<span class="line" id="L1764">                .Slice =&gt; {</span>
<span class="line" id="L1765">                    <span class="tok-kw">for</span> (value) |v| {</span>
<span class="line" id="L1766">                        parseFree(ptrInfo.child, v, options);</span>
<span class="line" id="L1767">                    }</span>
<span class="line" id="L1768">                    allocator.free(value);</span>
<span class="line" id="L1769">                },</span>
<span class="line" id="L1770">                <span class="tok-kw">else</span> =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L1771">            }</span>
<span class="line" id="L1772">        },</span>
<span class="line" id="L1773">        <span class="tok-kw">else</span> =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L1774">    }</span>
<span class="line" id="L1775">}</span>
<span class="line" id="L1776"></span>
<span class="line" id="L1777"><span class="tok-comment">/// A non-stream JSON parser which constructs a tree of Value's.</span></span>
<span class="line" id="L1778"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> Parser = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L1779">    allocator: Allocator,</span>
<span class="line" id="L1780">    state: State,</span>
<span class="line" id="L1781">    copy_strings: <span class="tok-type">bool</span>,</span>
<span class="line" id="L1782">    <span class="tok-comment">// Stores parent nodes and un-combined Values.</span>
</span>
<span class="line" id="L1783">    stack: Array,</span>
<span class="line" id="L1784"></span>
<span class="line" id="L1785">    <span class="tok-kw">const</span> State = <span class="tok-kw">enum</span> {</span>
<span class="line" id="L1786">        ObjectKey,</span>
<span class="line" id="L1787">        ObjectValue,</span>
<span class="line" id="L1788">        ArrayValue,</span>
<span class="line" id="L1789">        Simple,</span>
<span class="line" id="L1790">    };</span>
<span class="line" id="L1791"></span>
<span class="line" id="L1792">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">init</span>(allocator: Allocator, copy_strings: <span class="tok-type">bool</span>) Parser {</span>
<span class="line" id="L1793">        <span class="tok-kw">return</span> Parser{</span>
<span class="line" id="L1794">            .allocator = allocator,</span>
<span class="line" id="L1795">            .state = .Simple,</span>
<span class="line" id="L1796">            .copy_strings = copy_strings,</span>
<span class="line" id="L1797">            .stack = Array.init(allocator),</span>
<span class="line" id="L1798">        };</span>
<span class="line" id="L1799">    }</span>
<span class="line" id="L1800"></span>
<span class="line" id="L1801">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">deinit</span>(p: *Parser) <span class="tok-type">void</span> {</span>
<span class="line" id="L1802">        p.stack.deinit();</span>
<span class="line" id="L1803">    }</span>
<span class="line" id="L1804"></span>
<span class="line" id="L1805">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">reset</span>(p: *Parser) <span class="tok-type">void</span> {</span>
<span class="line" id="L1806">        p.state = .Simple;</span>
<span class="line" id="L1807">        p.stack.shrinkRetainingCapacity(<span class="tok-number">0</span>);</span>
<span class="line" id="L1808">    }</span>
<span class="line" id="L1809"></span>
<span class="line" id="L1810">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">parse</span>(p: *Parser, input: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) !ValueTree {</span>
<span class="line" id="L1811">        <span class="tok-kw">var</span> s = TokenStream.init(input);</span>
<span class="line" id="L1812"></span>
<span class="line" id="L1813">        <span class="tok-kw">var</span> arena = ArenaAllocator.init(p.allocator);</span>
<span class="line" id="L1814">        <span class="tok-kw">errdefer</span> arena.deinit();</span>
<span class="line" id="L1815">        <span class="tok-kw">const</span> allocator = arena.allocator();</span>
<span class="line" id="L1816"></span>
<span class="line" id="L1817">        <span class="tok-kw">while</span> (<span class="tok-kw">try</span> s.next()) |token| {</span>
<span class="line" id="L1818">            <span class="tok-kw">try</span> p.transition(allocator, input, s.i - <span class="tok-number">1</span>, token);</span>
<span class="line" id="L1819">        }</span>
<span class="line" id="L1820"></span>
<span class="line" id="L1821">        debug.assert(p.stack.items.len == <span class="tok-number">1</span>);</span>
<span class="line" id="L1822"></span>
<span class="line" id="L1823">        <span class="tok-kw">return</span> ValueTree{</span>
<span class="line" id="L1824">            .arena = arena,</span>
<span class="line" id="L1825">            .root = p.stack.items[<span class="tok-number">0</span>],</span>
<span class="line" id="L1826">        };</span>
<span class="line" id="L1827">    }</span>
<span class="line" id="L1828"></span>
<span class="line" id="L1829">    <span class="tok-comment">// Even though p.allocator exists, we take an explicit allocator so that allocation state</span>
</span>
<span class="line" id="L1830">    <span class="tok-comment">// can be cleaned up on error correctly during a `parse` on call.</span>
</span>
<span class="line" id="L1831">    <span class="tok-kw">fn</span> <span class="tok-fn">transition</span>(p: *Parser, allocator: Allocator, input: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>, i: <span class="tok-type">usize</span>, token: Token) !<span class="tok-type">void</span> {</span>
<span class="line" id="L1832">        <span class="tok-kw">switch</span> (p.state) {</span>
<span class="line" id="L1833">            .ObjectKey =&gt; <span class="tok-kw">switch</span> (token) {</span>
<span class="line" id="L1834">                .ObjectEnd =&gt; {</span>
<span class="line" id="L1835">                    <span class="tok-kw">if</span> (p.stack.items.len == <span class="tok-number">1</span>) {</span>
<span class="line" id="L1836">                        <span class="tok-kw">return</span>;</span>
<span class="line" id="L1837">                    }</span>
<span class="line" id="L1838"></span>
<span class="line" id="L1839">                    <span class="tok-kw">var</span> value = p.stack.pop();</span>
<span class="line" id="L1840">                    <span class="tok-kw">try</span> p.pushToParent(&amp;value);</span>
<span class="line" id="L1841">                },</span>
<span class="line" id="L1842">                .String =&gt; |s| {</span>
<span class="line" id="L1843">                    <span class="tok-kw">try</span> p.stack.append(<span class="tok-kw">try</span> p.parseString(allocator, s, input, i));</span>
<span class="line" id="L1844">                    p.state = .ObjectValue;</span>
<span class="line" id="L1845">                },</span>
<span class="line" id="L1846">                <span class="tok-kw">else</span> =&gt; {</span>
<span class="line" id="L1847">                    <span class="tok-comment">// The streaming parser would return an error eventually.</span>
</span>
<span class="line" id="L1848">                    <span class="tok-comment">// To prevent invalid state we return an error now.</span>
</span>
<span class="line" id="L1849">                    <span class="tok-comment">// TODO make the streaming parser return an error as soon as it encounters an invalid object key</span>
</span>
<span class="line" id="L1850">                    <span class="tok-kw">return</span> <span class="tok-kw">error</span>.InvalidLiteral;</span>
<span class="line" id="L1851">                },</span>
<span class="line" id="L1852">            },</span>
<span class="line" id="L1853">            .ObjectValue =&gt; {</span>
<span class="line" id="L1854">                <span class="tok-kw">var</span> object = &amp;p.stack.items[p.stack.items.len - <span class="tok-number">2</span>].Object;</span>
<span class="line" id="L1855">                <span class="tok-kw">var</span> key = p.stack.items[p.stack.items.len - <span class="tok-number">1</span>].String;</span>
<span class="line" id="L1856"></span>
<span class="line" id="L1857">                <span class="tok-kw">switch</span> (token) {</span>
<span class="line" id="L1858">                    .ObjectBegin =&gt; {</span>
<span class="line" id="L1859">                        <span class="tok-kw">try</span> p.stack.append(Value{ .Object = ObjectMap.init(allocator) });</span>
<span class="line" id="L1860">                        p.state = .ObjectKey;</span>
<span class="line" id="L1861">                    },</span>
<span class="line" id="L1862">                    .ArrayBegin =&gt; {</span>
<span class="line" id="L1863">                        <span class="tok-kw">try</span> p.stack.append(Value{ .Array = Array.init(allocator) });</span>
<span class="line" id="L1864">                        p.state = .ArrayValue;</span>
<span class="line" id="L1865">                    },</span>
<span class="line" id="L1866">                    .String =&gt; |s| {</span>
<span class="line" id="L1867">                        <span class="tok-kw">try</span> object.put(key, <span class="tok-kw">try</span> p.parseString(allocator, s, input, i));</span>
<span class="line" id="L1868">                        _ = p.stack.pop();</span>
<span class="line" id="L1869">                        p.state = .ObjectKey;</span>
<span class="line" id="L1870">                    },</span>
<span class="line" id="L1871">                    .Number =&gt; |n| {</span>
<span class="line" id="L1872">                        <span class="tok-kw">try</span> object.put(key, <span class="tok-kw">try</span> p.parseNumber(n, input, i));</span>
<span class="line" id="L1873">                        _ = p.stack.pop();</span>
<span class="line" id="L1874">                        p.state = .ObjectKey;</span>
<span class="line" id="L1875">                    },</span>
<span class="line" id="L1876">                    .True =&gt; {</span>
<span class="line" id="L1877">                        <span class="tok-kw">try</span> object.put(key, Value{ .Bool = <span class="tok-null">true</span> });</span>
<span class="line" id="L1878">                        _ = p.stack.pop();</span>
<span class="line" id="L1879">                        p.state = .ObjectKey;</span>
<span class="line" id="L1880">                    },</span>
<span class="line" id="L1881">                    .False =&gt; {</span>
<span class="line" id="L1882">                        <span class="tok-kw">try</span> object.put(key, Value{ .Bool = <span class="tok-null">false</span> });</span>
<span class="line" id="L1883">                        _ = p.stack.pop();</span>
<span class="line" id="L1884">                        p.state = .ObjectKey;</span>
<span class="line" id="L1885">                    },</span>
<span class="line" id="L1886">                    .Null =&gt; {</span>
<span class="line" id="L1887">                        <span class="tok-kw">try</span> object.put(key, Value.Null);</span>
<span class="line" id="L1888">                        _ = p.stack.pop();</span>
<span class="line" id="L1889">                        p.state = .ObjectKey;</span>
<span class="line" id="L1890">                    },</span>
<span class="line" id="L1891">                    .ObjectEnd, .ArrayEnd =&gt; {</span>
<span class="line" id="L1892">                        <span class="tok-kw">unreachable</span>;</span>
<span class="line" id="L1893">                    },</span>
<span class="line" id="L1894">                }</span>
<span class="line" id="L1895">            },</span>
<span class="line" id="L1896">            .ArrayValue =&gt; {</span>
<span class="line" id="L1897">                <span class="tok-kw">var</span> array = &amp;p.stack.items[p.stack.items.len - <span class="tok-number">1</span>].Array;</span>
<span class="line" id="L1898"></span>
<span class="line" id="L1899">                <span class="tok-kw">switch</span> (token) {</span>
<span class="line" id="L1900">                    .ArrayEnd =&gt; {</span>
<span class="line" id="L1901">                        <span class="tok-kw">if</span> (p.stack.items.len == <span class="tok-number">1</span>) {</span>
<span class="line" id="L1902">                            <span class="tok-kw">return</span>;</span>
<span class="line" id="L1903">                        }</span>
<span class="line" id="L1904"></span>
<span class="line" id="L1905">                        <span class="tok-kw">var</span> value = p.stack.pop();</span>
<span class="line" id="L1906">                        <span class="tok-kw">try</span> p.pushToParent(&amp;value);</span>
<span class="line" id="L1907">                    },</span>
<span class="line" id="L1908">                    .ObjectBegin =&gt; {</span>
<span class="line" id="L1909">                        <span class="tok-kw">try</span> p.stack.append(Value{ .Object = ObjectMap.init(allocator) });</span>
<span class="line" id="L1910">                        p.state = .ObjectKey;</span>
<span class="line" id="L1911">                    },</span>
<span class="line" id="L1912">                    .ArrayBegin =&gt; {</span>
<span class="line" id="L1913">                        <span class="tok-kw">try</span> p.stack.append(Value{ .Array = Array.init(allocator) });</span>
<span class="line" id="L1914">                        p.state = .ArrayValue;</span>
<span class="line" id="L1915">                    },</span>
<span class="line" id="L1916">                    .String =&gt; |s| {</span>
<span class="line" id="L1917">                        <span class="tok-kw">try</span> array.append(<span class="tok-kw">try</span> p.parseString(allocator, s, input, i));</span>
<span class="line" id="L1918">                    },</span>
<span class="line" id="L1919">                    .Number =&gt; |n| {</span>
<span class="line" id="L1920">                        <span class="tok-kw">try</span> array.append(<span class="tok-kw">try</span> p.parseNumber(n, input, i));</span>
<span class="line" id="L1921">                    },</span>
<span class="line" id="L1922">                    .True =&gt; {</span>
<span class="line" id="L1923">                        <span class="tok-kw">try</span> array.append(Value{ .Bool = <span class="tok-null">true</span> });</span>
<span class="line" id="L1924">                    },</span>
<span class="line" id="L1925">                    .False =&gt; {</span>
<span class="line" id="L1926">                        <span class="tok-kw">try</span> array.append(Value{ .Bool = <span class="tok-null">false</span> });</span>
<span class="line" id="L1927">                    },</span>
<span class="line" id="L1928">                    .Null =&gt; {</span>
<span class="line" id="L1929">                        <span class="tok-kw">try</span> array.append(Value.Null);</span>
<span class="line" id="L1930">                    },</span>
<span class="line" id="L1931">                    .ObjectEnd =&gt; {</span>
<span class="line" id="L1932">                        <span class="tok-kw">unreachable</span>;</span>
<span class="line" id="L1933">                    },</span>
<span class="line" id="L1934">                }</span>
<span class="line" id="L1935">            },</span>
<span class="line" id="L1936">            .Simple =&gt; <span class="tok-kw">switch</span> (token) {</span>
<span class="line" id="L1937">                .ObjectBegin =&gt; {</span>
<span class="line" id="L1938">                    <span class="tok-kw">try</span> p.stack.append(Value{ .Object = ObjectMap.init(allocator) });</span>
<span class="line" id="L1939">                    p.state = .ObjectKey;</span>
<span class="line" id="L1940">                },</span>
<span class="line" id="L1941">                .ArrayBegin =&gt; {</span>
<span class="line" id="L1942">                    <span class="tok-kw">try</span> p.stack.append(Value{ .Array = Array.init(allocator) });</span>
<span class="line" id="L1943">                    p.state = .ArrayValue;</span>
<span class="line" id="L1944">                },</span>
<span class="line" id="L1945">                .String =&gt; |s| {</span>
<span class="line" id="L1946">                    <span class="tok-kw">try</span> p.stack.append(<span class="tok-kw">try</span> p.parseString(allocator, s, input, i));</span>
<span class="line" id="L1947">                },</span>
<span class="line" id="L1948">                .Number =&gt; |n| {</span>
<span class="line" id="L1949">                    <span class="tok-kw">try</span> p.stack.append(<span class="tok-kw">try</span> p.parseNumber(n, input, i));</span>
<span class="line" id="L1950">                },</span>
<span class="line" id="L1951">                .True =&gt; {</span>
<span class="line" id="L1952">                    <span class="tok-kw">try</span> p.stack.append(Value{ .Bool = <span class="tok-null">true</span> });</span>
<span class="line" id="L1953">                },</span>
<span class="line" id="L1954">                .False =&gt; {</span>
<span class="line" id="L1955">                    <span class="tok-kw">try</span> p.stack.append(Value{ .Bool = <span class="tok-null">false</span> });</span>
<span class="line" id="L1956">                },</span>
<span class="line" id="L1957">                .Null =&gt; {</span>
<span class="line" id="L1958">                    <span class="tok-kw">try</span> p.stack.append(Value.Null);</span>
<span class="line" id="L1959">                },</span>
<span class="line" id="L1960">                .ObjectEnd, .ArrayEnd =&gt; {</span>
<span class="line" id="L1961">                    <span class="tok-kw">unreachable</span>;</span>
<span class="line" id="L1962">                },</span>
<span class="line" id="L1963">            },</span>
<span class="line" id="L1964">        }</span>
<span class="line" id="L1965">    }</span>
<span class="line" id="L1966"></span>
<span class="line" id="L1967">    <span class="tok-kw">fn</span> <span class="tok-fn">pushToParent</span>(p: *Parser, value: *<span class="tok-kw">const</span> Value) !<span class="tok-type">void</span> {</span>
<span class="line" id="L1968">        <span class="tok-kw">switch</span> (p.stack.items[p.stack.items.len - <span class="tok-number">1</span>]) {</span>
<span class="line" id="L1969">            <span class="tok-comment">// Object Parent -&gt; [ ..., object, &lt;key&gt;, value ]</span>
</span>
<span class="line" id="L1970">            Value.String =&gt; |key| {</span>
<span class="line" id="L1971">                _ = p.stack.pop();</span>
<span class="line" id="L1972"></span>
<span class="line" id="L1973">                <span class="tok-kw">var</span> object = &amp;p.stack.items[p.stack.items.len - <span class="tok-number">1</span>].Object;</span>
<span class="line" id="L1974">                <span class="tok-kw">try</span> object.put(key, value.*);</span>
<span class="line" id="L1975">                p.state = .ObjectKey;</span>
<span class="line" id="L1976">            },</span>
<span class="line" id="L1977">            <span class="tok-comment">// Array Parent -&gt; [ ..., &lt;array&gt;, value ]</span>
</span>
<span class="line" id="L1978">            Value.Array =&gt; |*array| {</span>
<span class="line" id="L1979">                <span class="tok-kw">try</span> array.append(value.*);</span>
<span class="line" id="L1980">                p.state = .ArrayValue;</span>
<span class="line" id="L1981">            },</span>
<span class="line" id="L1982">            <span class="tok-kw">else</span> =&gt; {</span>
<span class="line" id="L1983">                <span class="tok-kw">unreachable</span>;</span>
<span class="line" id="L1984">            },</span>
<span class="line" id="L1985">        }</span>
<span class="line" id="L1986">    }</span>
<span class="line" id="L1987"></span>
<span class="line" id="L1988">    <span class="tok-kw">fn</span> <span class="tok-fn">parseString</span>(p: *Parser, allocator: Allocator, s: std.meta.TagPayload(Token, Token.String), input: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>, i: <span class="tok-type">usize</span>) !Value {</span>
<span class="line" id="L1989">        <span class="tok-kw">const</span> slice = s.slice(input, i);</span>
<span class="line" id="L1990">        <span class="tok-kw">switch</span> (s.escapes) {</span>
<span class="line" id="L1991">            .None =&gt; <span class="tok-kw">return</span> Value{ .String = <span class="tok-kw">if</span> (p.copy_strings) <span class="tok-kw">try</span> allocator.dupe(<span class="tok-type">u8</span>, slice) <span class="tok-kw">else</span> slice },</span>
<span class="line" id="L1992">            .Some =&gt; {</span>
<span class="line" id="L1993">                <span class="tok-kw">const</span> output = <span class="tok-kw">try</span> allocator.alloc(<span class="tok-type">u8</span>, s.decodedLength());</span>
<span class="line" id="L1994">                <span class="tok-kw">errdefer</span> allocator.free(output);</span>
<span class="line" id="L1995">                <span class="tok-kw">try</span> unescapeValidString(output, slice);</span>
<span class="line" id="L1996">                <span class="tok-kw">return</span> Value{ .String = output };</span>
<span class="line" id="L1997">            },</span>
<span class="line" id="L1998">        }</span>
<span class="line" id="L1999">    }</span>
<span class="line" id="L2000"></span>
<span class="line" id="L2001">    <span class="tok-kw">fn</span> <span class="tok-fn">parseNumber</span>(p: *Parser, n: std.meta.TagPayload(Token, Token.Number), input: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>, i: <span class="tok-type">usize</span>) !Value {</span>
<span class="line" id="L2002">        _ = p;</span>
<span class="line" id="L2003">        <span class="tok-kw">return</span> <span class="tok-kw">if</span> (n.is_integer)</span>
<span class="line" id="L2004">            Value{</span>
<span class="line" id="L2005">                .Integer = std.fmt.parseInt(<span class="tok-type">i64</span>, n.slice(input, i), <span class="tok-number">10</span>) <span class="tok-kw">catch</span> |e| <span class="tok-kw">switch</span> (e) {</span>
<span class="line" id="L2006">                    <span class="tok-kw">error</span>.Overflow =&gt; <span class="tok-kw">return</span> Value{ .NumberString = n.slice(input, i) },</span>
<span class="line" id="L2007">                    <span class="tok-kw">error</span>.InvalidCharacter =&gt; |err| <span class="tok-kw">return</span> err,</span>
<span class="line" id="L2008">                },</span>
<span class="line" id="L2009">            }</span>
<span class="line" id="L2010">        <span class="tok-kw">else</span></span>
<span class="line" id="L2011">            Value{ .Float = <span class="tok-kw">try</span> std.fmt.parseFloat(<span class="tok-type">f64</span>, n.slice(input, i)) };</span>
<span class="line" id="L2012">    }</span>
<span class="line" id="L2013">};</span>
<span class="line" id="L2014"></span>
<span class="line" id="L2015"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> UnescapeValidStringError = <span class="tok-kw">error</span>{InvalidUnicodeHexSymbol};</span>
<span class="line" id="L2016"></span>
<span class="line" id="L2017"><span class="tok-comment">/// Unescape a JSON string</span></span>
<span class="line" id="L2018"><span class="tok-comment">/// Only to be used on strings already validated by the parser</span></span>
<span class="line" id="L2019"><span class="tok-comment">/// (note the unreachable statements and lack of bounds checking)</span></span>
<span class="line" id="L2020"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">unescapeValidString</span>(output: []<span class="tok-type">u8</span>, input: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) UnescapeValidStringError!<span class="tok-type">void</span> {</span>
<span class="line" id="L2021">    <span class="tok-kw">var</span> inIndex: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L2022">    <span class="tok-kw">var</span> outIndex: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L2023"></span>
<span class="line" id="L2024">    <span class="tok-kw">while</span> (inIndex &lt; input.len) {</span>
<span class="line" id="L2025">        <span class="tok-kw">if</span> (input[inIndex] != <span class="tok-str">'\\'</span>) {</span>
<span class="line" id="L2026">            <span class="tok-comment">// not an escape sequence</span>
</span>
<span class="line" id="L2027">            output[outIndex] = input[inIndex];</span>
<span class="line" id="L2028">            inIndex += <span class="tok-number">1</span>;</span>
<span class="line" id="L2029">            outIndex += <span class="tok-number">1</span>;</span>
<span class="line" id="L2030">        } <span class="tok-kw">else</span> <span class="tok-kw">if</span> (input[inIndex + <span class="tok-number">1</span>] != <span class="tok-str">'u'</span>) {</span>
<span class="line" id="L2031">            <span class="tok-comment">// a simple escape sequence</span>
</span>
<span class="line" id="L2032">            output[outIndex] = <span class="tok-builtin">@as</span>(<span class="tok-type">u8</span>, <span class="tok-kw">switch</span> (input[inIndex + <span class="tok-number">1</span>]) {</span>
<span class="line" id="L2033">                <span class="tok-str">'\\'</span> =&gt; <span class="tok-str">'\\'</span>,</span>
<span class="line" id="L2034">                <span class="tok-str">'/'</span> =&gt; <span class="tok-str">'/'</span>,</span>
<span class="line" id="L2035">                <span class="tok-str">'n'</span> =&gt; <span class="tok-str">'\n'</span>,</span>
<span class="line" id="L2036">                <span class="tok-str">'r'</span> =&gt; <span class="tok-str">'\r'</span>,</span>
<span class="line" id="L2037">                <span class="tok-str">'t'</span> =&gt; <span class="tok-str">'\t'</span>,</span>
<span class="line" id="L2038">                <span class="tok-str">'f'</span> =&gt; <span class="tok-number">12</span>,</span>
<span class="line" id="L2039">                <span class="tok-str">'b'</span> =&gt; <span class="tok-number">8</span>,</span>
<span class="line" id="L2040">                <span class="tok-str">'&quot;'</span> =&gt; <span class="tok-str">'&quot;'</span>,</span>
<span class="line" id="L2041">                <span class="tok-kw">else</span> =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L2042">            });</span>
<span class="line" id="L2043">            inIndex += <span class="tok-number">2</span>;</span>
<span class="line" id="L2044">            outIndex += <span class="tok-number">1</span>;</span>
<span class="line" id="L2045">        } <span class="tok-kw">else</span> {</span>
<span class="line" id="L2046">            <span class="tok-comment">// a unicode escape sequence</span>
</span>
<span class="line" id="L2047">            <span class="tok-kw">const</span> firstCodeUnit = std.fmt.parseInt(<span class="tok-type">u16</span>, input[inIndex + <span class="tok-number">2</span> .. inIndex + <span class="tok-number">6</span>], <span class="tok-number">16</span>) <span class="tok-kw">catch</span> <span class="tok-kw">unreachable</span>;</span>
<span class="line" id="L2048"></span>
<span class="line" id="L2049">            <span class="tok-comment">// guess optimistically that it's not a surrogate pair</span>
</span>
<span class="line" id="L2050">            <span class="tok-kw">if</span> (std.unicode.utf8Encode(firstCodeUnit, output[outIndex..])) |byteCount| {</span>
<span class="line" id="L2051">                outIndex += byteCount;</span>
<span class="line" id="L2052">                inIndex += <span class="tok-number">6</span>;</span>
<span class="line" id="L2053">            } <span class="tok-kw">else</span> |err| {</span>
<span class="line" id="L2054">                <span class="tok-comment">// it might be a surrogate pair</span>
</span>
<span class="line" id="L2055">                <span class="tok-kw">if</span> (err != <span class="tok-kw">error</span>.Utf8CannotEncodeSurrogateHalf) {</span>
<span class="line" id="L2056">                    <span class="tok-kw">return</span> <span class="tok-kw">error</span>.InvalidUnicodeHexSymbol;</span>
<span class="line" id="L2057">                }</span>
<span class="line" id="L2058">                <span class="tok-comment">// check if a second code unit is present</span>
</span>
<span class="line" id="L2059">                <span class="tok-kw">if</span> (inIndex + <span class="tok-number">7</span> &gt;= input.len <span class="tok-kw">or</span> input[inIndex + <span class="tok-number">6</span>] != <span class="tok-str">'\\'</span> <span class="tok-kw">or</span> input[inIndex + <span class="tok-number">7</span>] != <span class="tok-str">'u'</span>) {</span>
<span class="line" id="L2060">                    <span class="tok-kw">return</span> <span class="tok-kw">error</span>.InvalidUnicodeHexSymbol;</span>
<span class="line" id="L2061">                }</span>
<span class="line" id="L2062"></span>
<span class="line" id="L2063">                <span class="tok-kw">const</span> secondCodeUnit = std.fmt.parseInt(<span class="tok-type">u16</span>, input[inIndex + <span class="tok-number">8</span> .. inIndex + <span class="tok-number">12</span>], <span class="tok-number">16</span>) <span class="tok-kw">catch</span> <span class="tok-kw">unreachable</span>;</span>
<span class="line" id="L2064"></span>
<span class="line" id="L2065">                <span class="tok-kw">const</span> utf16le_seq = [<span class="tok-number">2</span>]<span class="tok-type">u16</span>{</span>
<span class="line" id="L2066">                    mem.nativeToLittle(<span class="tok-type">u16</span>, firstCodeUnit),</span>
<span class="line" id="L2067">                    mem.nativeToLittle(<span class="tok-type">u16</span>, secondCodeUnit),</span>
<span class="line" id="L2068">                };</span>
<span class="line" id="L2069">                <span class="tok-kw">if</span> (std.unicode.utf16leToUtf8(output[outIndex..], &amp;utf16le_seq)) |byteCount| {</span>
<span class="line" id="L2070">                    outIndex += byteCount;</span>
<span class="line" id="L2071">                    inIndex += <span class="tok-number">12</span>;</span>
<span class="line" id="L2072">                } <span class="tok-kw">else</span> |_| {</span>
<span class="line" id="L2073">                    <span class="tok-kw">return</span> <span class="tok-kw">error</span>.InvalidUnicodeHexSymbol;</span>
<span class="line" id="L2074">                }</span>
<span class="line" id="L2075">            }</span>
<span class="line" id="L2076">        }</span>
<span class="line" id="L2077">    }</span>
<span class="line" id="L2078">    assert(outIndex == output.len);</span>
<span class="line" id="L2079">}</span>
<span class="line" id="L2080"></span>
<span class="line" id="L2081"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> StringifyOptions = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L2082">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> Whitespace = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L2083">        <span class="tok-comment">/// How many indentation levels deep are we?</span></span>
<span class="line" id="L2084">        indent_level: <span class="tok-type">usize</span> = <span class="tok-number">0</span>,</span>
<span class="line" id="L2085"></span>
<span class="line" id="L2086">        <span class="tok-comment">/// What character(s) should be used for indentation?</span></span>
<span class="line" id="L2087">        indent: <span class="tok-kw">union</span>(<span class="tok-kw">enum</span>) {</span>
<span class="line" id="L2088">            Space: <span class="tok-type">u8</span>,</span>
<span class="line" id="L2089">            Tab: <span class="tok-type">void</span>,</span>
<span class="line" id="L2090">            None: <span class="tok-type">void</span>,</span>
<span class="line" id="L2091">        } = .{ .Space = <span class="tok-number">4</span> },</span>
<span class="line" id="L2092"></span>
<span class="line" id="L2093">        <span class="tok-comment">/// After a colon, should whitespace be inserted?</span></span>
<span class="line" id="L2094">        separator: <span class="tok-type">bool</span> = <span class="tok-null">true</span>,</span>
<span class="line" id="L2095"></span>
<span class="line" id="L2096">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">outputIndent</span>(</span>
<span class="line" id="L2097">            whitespace: <span class="tok-builtin">@This</span>(),</span>
<span class="line" id="L2098">            out_stream: <span class="tok-kw">anytype</span>,</span>
<span class="line" id="L2099">        ) <span class="tok-builtin">@TypeOf</span>(out_stream).Error!<span class="tok-type">void</span> {</span>
<span class="line" id="L2100">            <span class="tok-kw">var</span> char: <span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L2101">            <span class="tok-kw">var</span> n_chars: <span class="tok-type">usize</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L2102">            <span class="tok-kw">switch</span> (whitespace.indent) {</span>
<span class="line" id="L2103">                .Space =&gt; |n_spaces| {</span>
<span class="line" id="L2104">                    char = <span class="tok-str">' '</span>;</span>
<span class="line" id="L2105">                    n_chars = n_spaces;</span>
<span class="line" id="L2106">                },</span>
<span class="line" id="L2107">                .Tab =&gt; {</span>
<span class="line" id="L2108">                    char = <span class="tok-str">'\t'</span>;</span>
<span class="line" id="L2109">                    n_chars = <span class="tok-number">1</span>;</span>
<span class="line" id="L2110">                },</span>
<span class="line" id="L2111">                .None =&gt; <span class="tok-kw">return</span>,</span>
<span class="line" id="L2112">            }</span>
<span class="line" id="L2113">            <span class="tok-kw">try</span> out_stream.writeByte(<span class="tok-str">'\n'</span>);</span>
<span class="line" id="L2114">            n_chars *= whitespace.indent_level;</span>
<span class="line" id="L2115">            <span class="tok-kw">try</span> out_stream.writeByteNTimes(char, n_chars);</span>
<span class="line" id="L2116">        }</span>
<span class="line" id="L2117">    };</span>
<span class="line" id="L2118"></span>
<span class="line" id="L2119">    <span class="tok-comment">/// Controls the whitespace emitted</span></span>
<span class="line" id="L2120">    whitespace: ?Whitespace = <span class="tok-null">null</span>,</span>
<span class="line" id="L2121"></span>
<span class="line" id="L2122">    <span class="tok-comment">/// Should optional fields with null value be written?</span></span>
<span class="line" id="L2123">    emit_null_optional_fields: <span class="tok-type">bool</span> = <span class="tok-null">true</span>,</span>
<span class="line" id="L2124"></span>
<span class="line" id="L2125">    string: StringOptions = StringOptions{ .String = .{} },</span>
<span class="line" id="L2126"></span>
<span class="line" id="L2127">    <span class="tok-comment">/// Should []u8 be serialised as a string? or an array?</span></span>
<span class="line" id="L2128">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> StringOptions = <span class="tok-kw">union</span>(<span class="tok-kw">enum</span>) {</span>
<span class="line" id="L2129">        Array,</span>
<span class="line" id="L2130">        String: StringOutputOptions,</span>
<span class="line" id="L2131"></span>
<span class="line" id="L2132">        <span class="tok-comment">/// String output options</span></span>
<span class="line" id="L2133">        <span class="tok-kw">const</span> StringOutputOptions = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L2134">            <span class="tok-comment">/// Should '/' be escaped in strings?</span></span>
<span class="line" id="L2135">            escape_solidus: <span class="tok-type">bool</span> = <span class="tok-null">false</span>,</span>
<span class="line" id="L2136"></span>
<span class="line" id="L2137">            <span class="tok-comment">/// Should unicode characters be escaped in strings?</span></span>
<span class="line" id="L2138">            escape_unicode: <span class="tok-type">bool</span> = <span class="tok-null">false</span>,</span>
<span class="line" id="L2139">        };</span>
<span class="line" id="L2140">    };</span>
<span class="line" id="L2141">};</span>
<span class="line" id="L2142"></span>
<span class="line" id="L2143"><span class="tok-kw">fn</span> <span class="tok-fn">outputUnicodeEscape</span>(</span>
<span class="line" id="L2144">    codepoint: <span class="tok-type">u21</span>,</span>
<span class="line" id="L2145">    out_stream: <span class="tok-kw">anytype</span>,</span>
<span class="line" id="L2146">) !<span class="tok-type">void</span> {</span>
<span class="line" id="L2147">    <span class="tok-kw">if</span> (codepoint &lt;= <span class="tok-number">0xFFFF</span>) {</span>
<span class="line" id="L2148">        <span class="tok-comment">// If the character is in the Basic Multilingual Plane (U+0000 through U+FFFF),</span>
</span>
<span class="line" id="L2149">        <span class="tok-comment">// then it may be represented as a six-character sequence: a reverse solidus, followed</span>
</span>
<span class="line" id="L2150">        <span class="tok-comment">// by the lowercase letter u, followed by four hexadecimal digits that encode the character's code point.</span>
</span>
<span class="line" id="L2151">        <span class="tok-kw">try</span> out_stream.writeAll(<span class="tok-str">&quot;\\u&quot;</span>);</span>
<span class="line" id="L2152">        <span class="tok-kw">try</span> std.fmt.formatIntValue(codepoint, <span class="tok-str">&quot;x&quot;</span>, std.fmt.FormatOptions{ .width = <span class="tok-number">4</span>, .fill = <span class="tok-str">'0'</span> }, out_stream);</span>
<span class="line" id="L2153">    } <span class="tok-kw">else</span> {</span>
<span class="line" id="L2154">        assert(codepoint &lt;= <span class="tok-number">0x10FFFF</span>);</span>
<span class="line" id="L2155">        <span class="tok-comment">// To escape an extended character that is not in the Basic Multilingual Plane,</span>
</span>
<span class="line" id="L2156">        <span class="tok-comment">// the character is represented as a 12-character sequence, encoding the UTF-16 surrogate pair.</span>
</span>
<span class="line" id="L2157">        <span class="tok-kw">const</span> high = <span class="tok-builtin">@intCast</span>(<span class="tok-type">u16</span>, (codepoint - <span class="tok-number">0x10000</span>) &gt;&gt; <span class="tok-number">10</span>) + <span class="tok-number">0xD800</span>;</span>
<span class="line" id="L2158">        <span class="tok-kw">const</span> low = <span class="tok-builtin">@intCast</span>(<span class="tok-type">u16</span>, codepoint &amp; <span class="tok-number">0x3FF</span>) + <span class="tok-number">0xDC00</span>;</span>
<span class="line" id="L2159">        <span class="tok-kw">try</span> out_stream.writeAll(<span class="tok-str">&quot;\\u&quot;</span>);</span>
<span class="line" id="L2160">        <span class="tok-kw">try</span> std.fmt.formatIntValue(high, <span class="tok-str">&quot;x&quot;</span>, std.fmt.FormatOptions{ .width = <span class="tok-number">4</span>, .fill = <span class="tok-str">'0'</span> }, out_stream);</span>
<span class="line" id="L2161">        <span class="tok-kw">try</span> out_stream.writeAll(<span class="tok-str">&quot;\\u&quot;</span>);</span>
<span class="line" id="L2162">        <span class="tok-kw">try</span> std.fmt.formatIntValue(low, <span class="tok-str">&quot;x&quot;</span>, std.fmt.FormatOptions{ .width = <span class="tok-number">4</span>, .fill = <span class="tok-str">'0'</span> }, out_stream);</span>
<span class="line" id="L2163">    }</span>
<span class="line" id="L2164">}</span>
<span class="line" id="L2165"></span>
<span class="line" id="L2166"><span class="tok-comment">/// Write `string` to `writer` as a JSON encoded string.</span></span>
<span class="line" id="L2167"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">encodeJsonString</span>(string: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>, options: StringifyOptions, writer: <span class="tok-kw">anytype</span>) !<span class="tok-type">void</span> {</span>
<span class="line" id="L2168">    <span class="tok-kw">try</span> writer.writeByte(<span class="tok-str">'\&quot;'</span>);</span>
<span class="line" id="L2169">    <span class="tok-kw">try</span> encodeJsonStringChars(string, options, writer);</span>
<span class="line" id="L2170">    <span class="tok-kw">try</span> writer.writeByte(<span class="tok-str">'\&quot;'</span>);</span>
<span class="line" id="L2171">}</span>
<span class="line" id="L2172"></span>
<span class="line" id="L2173"><span class="tok-comment">/// Write `chars` to `writer` as JSON encoded string characters.</span></span>
<span class="line" id="L2174"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">encodeJsonStringChars</span>(chars: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>, options: StringifyOptions, writer: <span class="tok-kw">anytype</span>) !<span class="tok-type">void</span> {</span>
<span class="line" id="L2175">    <span class="tok-kw">var</span> i: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L2176">    <span class="tok-kw">while</span> (i &lt; chars.len) : (i += <span class="tok-number">1</span>) {</span>
<span class="line" id="L2177">        <span class="tok-kw">switch</span> (chars[i]) {</span>
<span class="line" id="L2178">            <span class="tok-comment">// normal ascii character</span>
</span>
<span class="line" id="L2179">            <span class="tok-number">0x20</span>...<span class="tok-number">0x21</span>, <span class="tok-number">0x23</span>...<span class="tok-number">0x2E</span>, <span class="tok-number">0x30</span>...<span class="tok-number">0x5B</span>, <span class="tok-number">0x5D</span>...<span class="tok-number">0x7F</span> =&gt; |c| <span class="tok-kw">try</span> writer.writeByte(c),</span>
<span class="line" id="L2180">            <span class="tok-comment">// only 2 characters that *must* be escaped</span>
</span>
<span class="line" id="L2181">            <span class="tok-str">'\\'</span> =&gt; <span class="tok-kw">try</span> writer.writeAll(<span class="tok-str">&quot;\\\\&quot;</span>),</span>
<span class="line" id="L2182">            <span class="tok-str">'\&quot;'</span> =&gt; <span class="tok-kw">try</span> writer.writeAll(<span class="tok-str">&quot;\\\&quot;&quot;</span>),</span>
<span class="line" id="L2183">            <span class="tok-comment">// solidus is optional to escape</span>
</span>
<span class="line" id="L2184">            <span class="tok-str">'/'</span> =&gt; {</span>
<span class="line" id="L2185">                <span class="tok-kw">if</span> (options.string.String.escape_solidus) {</span>
<span class="line" id="L2186">                    <span class="tok-kw">try</span> writer.writeAll(<span class="tok-str">&quot;\\/&quot;</span>);</span>
<span class="line" id="L2187">                } <span class="tok-kw">else</span> {</span>
<span class="line" id="L2188">                    <span class="tok-kw">try</span> writer.writeByte(<span class="tok-str">'/'</span>);</span>
<span class="line" id="L2189">                }</span>
<span class="line" id="L2190">            },</span>
<span class="line" id="L2191">            <span class="tok-comment">// control characters with short escapes</span>
</span>
<span class="line" id="L2192">            <span class="tok-comment">// TODO: option to switch between unicode and 'short' forms?</span>
</span>
<span class="line" id="L2193">            <span class="tok-number">0x8</span> =&gt; <span class="tok-kw">try</span> writer.writeAll(<span class="tok-str">&quot;\\b&quot;</span>),</span>
<span class="line" id="L2194">            <span class="tok-number">0xC</span> =&gt; <span class="tok-kw">try</span> writer.writeAll(<span class="tok-str">&quot;\\f&quot;</span>),</span>
<span class="line" id="L2195">            <span class="tok-str">'\n'</span> =&gt; <span class="tok-kw">try</span> writer.writeAll(<span class="tok-str">&quot;\\n&quot;</span>),</span>
<span class="line" id="L2196">            <span class="tok-str">'\r'</span> =&gt; <span class="tok-kw">try</span> writer.writeAll(<span class="tok-str">&quot;\\r&quot;</span>),</span>
<span class="line" id="L2197">            <span class="tok-str">'\t'</span> =&gt; <span class="tok-kw">try</span> writer.writeAll(<span class="tok-str">&quot;\\t&quot;</span>),</span>
<span class="line" id="L2198">            <span class="tok-kw">else</span> =&gt; {</span>
<span class="line" id="L2199">                <span class="tok-kw">const</span> ulen = std.unicode.utf8ByteSequenceLength(chars[i]) <span class="tok-kw">catch</span> <span class="tok-kw">unreachable</span>;</span>
<span class="line" id="L2200">                <span class="tok-comment">// control characters (only things left with 1 byte length) should always be printed as unicode escapes</span>
</span>
<span class="line" id="L2201">                <span class="tok-kw">if</span> (ulen == <span class="tok-number">1</span> <span class="tok-kw">or</span> options.string.String.escape_unicode) {</span>
<span class="line" id="L2202">                    <span class="tok-kw">const</span> codepoint = std.unicode.utf8Decode(chars[i .. i + ulen]) <span class="tok-kw">catch</span> <span class="tok-kw">unreachable</span>;</span>
<span class="line" id="L2203">                    <span class="tok-kw">try</span> outputUnicodeEscape(codepoint, writer);</span>
<span class="line" id="L2204">                } <span class="tok-kw">else</span> {</span>
<span class="line" id="L2205">                    <span class="tok-kw">try</span> writer.writeAll(chars[i .. i + ulen]);</span>
<span class="line" id="L2206">                }</span>
<span class="line" id="L2207">                i += ulen - <span class="tok-number">1</span>;</span>
<span class="line" id="L2208">            },</span>
<span class="line" id="L2209">        }</span>
<span class="line" id="L2210">    }</span>
<span class="line" id="L2211">}</span>
<span class="line" id="L2212"></span>
<span class="line" id="L2213"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">stringify</span>(</span>
<span class="line" id="L2214">    value: <span class="tok-kw">anytype</span>,</span>
<span class="line" id="L2215">    options: StringifyOptions,</span>
<span class="line" id="L2216">    out_stream: <span class="tok-kw">anytype</span>,</span>
<span class="line" id="L2217">) <span class="tok-builtin">@TypeOf</span>(out_stream).Error!<span class="tok-type">void</span> {</span>
<span class="line" id="L2218">    <span class="tok-kw">const</span> T = <span class="tok-builtin">@TypeOf</span>(value);</span>
<span class="line" id="L2219">    <span class="tok-kw">switch</span> (<span class="tok-builtin">@typeInfo</span>(T)) {</span>
<span class="line" id="L2220">        .Float, .ComptimeFloat =&gt; {</span>
<span class="line" id="L2221">            <span class="tok-kw">return</span> std.fmt.formatFloatScientific(value, std.fmt.FormatOptions{}, out_stream);</span>
<span class="line" id="L2222">        },</span>
<span class="line" id="L2223">        .Int, .ComptimeInt =&gt; {</span>
<span class="line" id="L2224">            <span class="tok-kw">return</span> std.fmt.formatIntValue(value, <span class="tok-str">&quot;&quot;</span>, std.fmt.FormatOptions{}, out_stream);</span>
<span class="line" id="L2225">        },</span>
<span class="line" id="L2226">        .Bool =&gt; {</span>
<span class="line" id="L2227">            <span class="tok-kw">return</span> out_stream.writeAll(<span class="tok-kw">if</span> (value) <span class="tok-str">&quot;true&quot;</span> <span class="tok-kw">else</span> <span class="tok-str">&quot;false&quot;</span>);</span>
<span class="line" id="L2228">        },</span>
<span class="line" id="L2229">        .Null =&gt; {</span>
<span class="line" id="L2230">            <span class="tok-kw">return</span> out_stream.writeAll(<span class="tok-str">&quot;null&quot;</span>);</span>
<span class="line" id="L2231">        },</span>
<span class="line" id="L2232">        .Optional =&gt; {</span>
<span class="line" id="L2233">            <span class="tok-kw">if</span> (value) |payload| {</span>
<span class="line" id="L2234">                <span class="tok-kw">return</span> <span class="tok-kw">try</span> stringify(payload, options, out_stream);</span>
<span class="line" id="L2235">            } <span class="tok-kw">else</span> {</span>
<span class="line" id="L2236">                <span class="tok-kw">return</span> <span class="tok-kw">try</span> stringify(<span class="tok-null">null</span>, options, out_stream);</span>
<span class="line" id="L2237">            }</span>
<span class="line" id="L2238">        },</span>
<span class="line" id="L2239">        .Enum =&gt; {</span>
<span class="line" id="L2240">            <span class="tok-kw">if</span> (<span class="tok-kw">comptime</span> std.meta.trait.hasFn(<span class="tok-str">&quot;jsonStringify&quot;</span>)(T)) {</span>
<span class="line" id="L2241">                <span class="tok-kw">return</span> value.jsonStringify(options, out_stream);</span>
<span class="line" id="L2242">            }</span>
<span class="line" id="L2243"></span>
<span class="line" id="L2244">            <span class="tok-builtin">@compileError</span>(<span class="tok-str">&quot;Unable to stringify enum '&quot;</span> ++ <span class="tok-builtin">@typeName</span>(T) ++ <span class="tok-str">&quot;'&quot;</span>);</span>
<span class="line" id="L2245">        },</span>
<span class="line" id="L2246">        .Union =&gt; {</span>
<span class="line" id="L2247">            <span class="tok-kw">if</span> (<span class="tok-kw">comptime</span> std.meta.trait.hasFn(<span class="tok-str">&quot;jsonStringify&quot;</span>)(T)) {</span>
<span class="line" id="L2248">                <span class="tok-kw">return</span> value.jsonStringify(options, out_stream);</span>
<span class="line" id="L2249">            }</span>
<span class="line" id="L2250"></span>
<span class="line" id="L2251">            <span class="tok-kw">const</span> info = <span class="tok-builtin">@typeInfo</span>(T).Union;</span>
<span class="line" id="L2252">            <span class="tok-kw">if</span> (info.tag_type) |UnionTagType| {</span>
<span class="line" id="L2253">                <span class="tok-kw">inline</span> <span class="tok-kw">for</span> (info.fields) |u_field| {</span>
<span class="line" id="L2254">                    <span class="tok-kw">if</span> (value == <span class="tok-builtin">@field</span>(UnionTagType, u_field.name)) {</span>
<span class="line" id="L2255">                        <span class="tok-kw">return</span> <span class="tok-kw">try</span> stringify(<span class="tok-builtin">@field</span>(value, u_field.name), options, out_stream);</span>
<span class="line" id="L2256">                    }</span>
<span class="line" id="L2257">                }</span>
<span class="line" id="L2258">            } <span class="tok-kw">else</span> {</span>
<span class="line" id="L2259">                <span class="tok-builtin">@compileError</span>(<span class="tok-str">&quot;Unable to stringify untagged union '&quot;</span> ++ <span class="tok-builtin">@typeName</span>(T) ++ <span class="tok-str">&quot;'&quot;</span>);</span>
<span class="line" id="L2260">            }</span>
<span class="line" id="L2261">        },</span>
<span class="line" id="L2262">        .Struct =&gt; |S| {</span>
<span class="line" id="L2263">            <span class="tok-kw">if</span> (<span class="tok-kw">comptime</span> std.meta.trait.hasFn(<span class="tok-str">&quot;jsonStringify&quot;</span>)(T)) {</span>
<span class="line" id="L2264">                <span class="tok-kw">return</span> value.jsonStringify(options, out_stream);</span>
<span class="line" id="L2265">            }</span>
<span class="line" id="L2266"></span>
<span class="line" id="L2267">            <span class="tok-kw">try</span> out_stream.writeByte(<span class="tok-str">'{'</span>);</span>
<span class="line" id="L2268">            <span class="tok-kw">var</span> field_output = <span class="tok-null">false</span>;</span>
<span class="line" id="L2269">            <span class="tok-kw">var</span> child_options = options;</span>
<span class="line" id="L2270">            <span class="tok-kw">if</span> (child_options.whitespace) |*child_whitespace| {</span>
<span class="line" id="L2271">                child_whitespace.indent_level += <span class="tok-number">1</span>;</span>
<span class="line" id="L2272">            }</span>
<span class="line" id="L2273">            <span class="tok-kw">inline</span> <span class="tok-kw">for</span> (S.fields) |Field| {</span>
<span class="line" id="L2274">                <span class="tok-comment">// don't include void fields</span>
</span>
<span class="line" id="L2275">                <span class="tok-kw">if</span> (Field.field_type == <span class="tok-type">void</span>) <span class="tok-kw">continue</span>;</span>
<span class="line" id="L2276"></span>
<span class="line" id="L2277">                <span class="tok-kw">var</span> emit_field = <span class="tok-null">true</span>;</span>
<span class="line" id="L2278"></span>
<span class="line" id="L2279">                <span class="tok-comment">// don't include optional fields that are null when emit_null_optional_fields is set to false</span>
</span>
<span class="line" id="L2280">                <span class="tok-kw">if</span> (<span class="tok-builtin">@typeInfo</span>(Field.field_type) == .Optional) {</span>
<span class="line" id="L2281">                    <span class="tok-kw">if</span> (options.emit_null_optional_fields == <span class="tok-null">false</span>) {</span>
<span class="line" id="L2282">                        <span class="tok-kw">if</span> (<span class="tok-builtin">@field</span>(value, Field.name) == <span class="tok-null">null</span>) {</span>
<span class="line" id="L2283">                            emit_field = <span class="tok-null">false</span>;</span>
<span class="line" id="L2284">                        }</span>
<span class="line" id="L2285">                    }</span>
<span class="line" id="L2286">                }</span>
<span class="line" id="L2287"></span>
<span class="line" id="L2288">                <span class="tok-kw">if</span> (emit_field) {</span>
<span class="line" id="L2289">                    <span class="tok-kw">if</span> (!field_output) {</span>
<span class="line" id="L2290">                        field_output = <span class="tok-null">true</span>;</span>
<span class="line" id="L2291">                    } <span class="tok-kw">else</span> {</span>
<span class="line" id="L2292">                        <span class="tok-kw">try</span> out_stream.writeByte(<span class="tok-str">','</span>);</span>
<span class="line" id="L2293">                    }</span>
<span class="line" id="L2294">                    <span class="tok-kw">if</span> (child_options.whitespace) |child_whitespace| {</span>
<span class="line" id="L2295">                        <span class="tok-kw">try</span> child_whitespace.outputIndent(out_stream);</span>
<span class="line" id="L2296">                    }</span>
<span class="line" id="L2297">                    <span class="tok-kw">try</span> encodeJsonString(Field.name, options, out_stream);</span>
<span class="line" id="L2298">                    <span class="tok-kw">try</span> out_stream.writeByte(<span class="tok-str">':'</span>);</span>
<span class="line" id="L2299">                    <span class="tok-kw">if</span> (child_options.whitespace) |child_whitespace| {</span>
<span class="line" id="L2300">                        <span class="tok-kw">if</span> (child_whitespace.separator) {</span>
<span class="line" id="L2301">                            <span class="tok-kw">try</span> out_stream.writeByte(<span class="tok-str">' '</span>);</span>
<span class="line" id="L2302">                        }</span>
<span class="line" id="L2303">                    }</span>
<span class="line" id="L2304">                    <span class="tok-kw">try</span> stringify(<span class="tok-builtin">@field</span>(value, Field.name), child_options, out_stream);</span>
<span class="line" id="L2305">                }</span>
<span class="line" id="L2306">            }</span>
<span class="line" id="L2307">            <span class="tok-kw">if</span> (field_output) {</span>
<span class="line" id="L2308">                <span class="tok-kw">if</span> (options.whitespace) |whitespace| {</span>
<span class="line" id="L2309">                    <span class="tok-kw">try</span> whitespace.outputIndent(out_stream);</span>
<span class="line" id="L2310">                }</span>
<span class="line" id="L2311">            }</span>
<span class="line" id="L2312">            <span class="tok-kw">try</span> out_stream.writeByte(<span class="tok-str">'}'</span>);</span>
<span class="line" id="L2313">            <span class="tok-kw">return</span>;</span>
<span class="line" id="L2314">        },</span>
<span class="line" id="L2315">        .ErrorSet =&gt; <span class="tok-kw">return</span> stringify(<span class="tok-builtin">@as</span>([]<span class="tok-kw">const</span> <span class="tok-type">u8</span>, <span class="tok-builtin">@errorName</span>(value)), options, out_stream),</span>
<span class="line" id="L2316">        .Pointer =&gt; |ptr_info| <span class="tok-kw">switch</span> (ptr_info.size) {</span>
<span class="line" id="L2317">            .One =&gt; <span class="tok-kw">switch</span> (<span class="tok-builtin">@typeInfo</span>(ptr_info.child)) {</span>
<span class="line" id="L2318">                .Array =&gt; {</span>
<span class="line" id="L2319">                    <span class="tok-kw">const</span> Slice = []<span class="tok-kw">const</span> std.meta.Elem(ptr_info.child);</span>
<span class="line" id="L2320">                    <span class="tok-kw">return</span> stringify(<span class="tok-builtin">@as</span>(Slice, value), options, out_stream);</span>
<span class="line" id="L2321">                },</span>
<span class="line" id="L2322">                <span class="tok-kw">else</span> =&gt; {</span>
<span class="line" id="L2323">                    <span class="tok-comment">// TODO: avoid loops?</span>
</span>
<span class="line" id="L2324">                    <span class="tok-kw">return</span> stringify(value.*, options, out_stream);</span>
<span class="line" id="L2325">                },</span>
<span class="line" id="L2326">            },</span>
<span class="line" id="L2327">            <span class="tok-comment">// TODO: .Many when there is a sentinel (waiting for https://github.com/ziglang/zig/pull/3972)</span>
</span>
<span class="line" id="L2328">            .Slice =&gt; {</span>
<span class="line" id="L2329">                <span class="tok-kw">if</span> (ptr_info.child == <span class="tok-type">u8</span> <span class="tok-kw">and</span> options.string == .String <span class="tok-kw">and</span> std.unicode.utf8ValidateSlice(value)) {</span>
<span class="line" id="L2330">                    <span class="tok-kw">try</span> encodeJsonString(value, options, out_stream);</span>
<span class="line" id="L2331">                    <span class="tok-kw">return</span>;</span>
<span class="line" id="L2332">                }</span>
<span class="line" id="L2333"></span>
<span class="line" id="L2334">                <span class="tok-kw">try</span> out_stream.writeByte(<span class="tok-str">'['</span>);</span>
<span class="line" id="L2335">                <span class="tok-kw">var</span> child_options = options;</span>
<span class="line" id="L2336">                <span class="tok-kw">if</span> (child_options.whitespace) |*whitespace| {</span>
<span class="line" id="L2337">                    whitespace.indent_level += <span class="tok-number">1</span>;</span>
<span class="line" id="L2338">                }</span>
<span class="line" id="L2339">                <span class="tok-kw">for</span> (value) |x, i| {</span>
<span class="line" id="L2340">                    <span class="tok-kw">if</span> (i != <span class="tok-number">0</span>) {</span>
<span class="line" id="L2341">                        <span class="tok-kw">try</span> out_stream.writeByte(<span class="tok-str">','</span>);</span>
<span class="line" id="L2342">                    }</span>
<span class="line" id="L2343">                    <span class="tok-kw">if</span> (child_options.whitespace) |child_whitespace| {</span>
<span class="line" id="L2344">                        <span class="tok-kw">try</span> child_whitespace.outputIndent(out_stream);</span>
<span class="line" id="L2345">                    }</span>
<span class="line" id="L2346">                    <span class="tok-kw">try</span> stringify(x, child_options, out_stream);</span>
<span class="line" id="L2347">                }</span>
<span class="line" id="L2348">                <span class="tok-kw">if</span> (value.len != <span class="tok-number">0</span>) {</span>
<span class="line" id="L2349">                    <span class="tok-kw">if</span> (options.whitespace) |whitespace| {</span>
<span class="line" id="L2350">                        <span class="tok-kw">try</span> whitespace.outputIndent(out_stream);</span>
<span class="line" id="L2351">                    }</span>
<span class="line" id="L2352">                }</span>
<span class="line" id="L2353">                <span class="tok-kw">try</span> out_stream.writeByte(<span class="tok-str">']'</span>);</span>
<span class="line" id="L2354">                <span class="tok-kw">return</span>;</span>
<span class="line" id="L2355">            },</span>
<span class="line" id="L2356">            <span class="tok-kw">else</span> =&gt; <span class="tok-builtin">@compileError</span>(<span class="tok-str">&quot;Unable to stringify type '&quot;</span> ++ <span class="tok-builtin">@typeName</span>(T) ++ <span class="tok-str">&quot;'&quot;</span>),</span>
<span class="line" id="L2357">        },</span>
<span class="line" id="L2358">        .Array =&gt; <span class="tok-kw">return</span> stringify(&amp;value, options, out_stream),</span>
<span class="line" id="L2359">        .Vector =&gt; |info| {</span>
<span class="line" id="L2360">            <span class="tok-kw">const</span> array: [info.len]info.child = value;</span>
<span class="line" id="L2361">            <span class="tok-kw">return</span> stringify(&amp;array, options, out_stream);</span>
<span class="line" id="L2362">        },</span>
<span class="line" id="L2363">        <span class="tok-kw">else</span> =&gt; <span class="tok-builtin">@compileError</span>(<span class="tok-str">&quot;Unable to stringify type '&quot;</span> ++ <span class="tok-builtin">@typeName</span>(T) ++ <span class="tok-str">&quot;'&quot;</span>),</span>
<span class="line" id="L2364">    }</span>
<span class="line" id="L2365">    <span class="tok-kw">unreachable</span>;</span>
<span class="line" id="L2366">}</span>
<span class="line" id="L2367"></span>
<span class="line" id="L2368"><span class="tok-comment">// Same as `stringify` but accepts an Allocator and stores result in dynamically allocated memory instead of using a Writer.</span>
</span>
<span class="line" id="L2369"><span class="tok-comment">// Caller owns returned memory.</span>
</span>
<span class="line" id="L2370"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">stringifyAlloc</span>(allocator: std.mem.Allocator, value: <span class="tok-kw">anytype</span>, options: StringifyOptions) ![]<span class="tok-kw">const</span> <span class="tok-type">u8</span> {</span>
<span class="line" id="L2371">    <span class="tok-kw">var</span> list = std.ArrayList(<span class="tok-type">u8</span>).init(allocator);</span>
<span class="line" id="L2372">    <span class="tok-kw">errdefer</span> list.deinit();</span>
<span class="line" id="L2373">    <span class="tok-kw">try</span> stringify(value, options, list.writer());</span>
<span class="line" id="L2374">    <span class="tok-kw">return</span> list.toOwnedSlice();</span>
<span class="line" id="L2375">}</span>
<span class="line" id="L2376"></span>
<span class="line" id="L2377"><span class="tok-kw">test</span> {</span>
<span class="line" id="L2378">    <span class="tok-kw">if</span> (builtin.zig_backend != .stage1) {</span>
<span class="line" id="L2379">        <span class="tok-comment">// https://github.com/ziglang/zig/issues/8442</span>
</span>
<span class="line" id="L2380">        _ = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;json/test.zig&quot;</span>);</span>
<span class="line" id="L2381">    }</span>
<span class="line" id="L2382">    _ = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;json/write_stream.zig&quot;</span>);</span>
<span class="line" id="L2383">}</span>
<span class="line" id="L2384"></span>
<span class="line" id="L2385"><span class="tok-kw">test</span> <span class="tok-str">&quot;stringify null optional fields&quot;</span> {</span>
<span class="line" id="L2386">    <span class="tok-kw">const</span> MyStruct = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L2387">        optional: ?[]<span class="tok-kw">const</span> <span class="tok-type">u8</span> = <span class="tok-null">null</span>,</span>
<span class="line" id="L2388">        required: []<span class="tok-kw">const</span> <span class="tok-type">u8</span> = <span class="tok-str">&quot;something&quot;</span>,</span>
<span class="line" id="L2389">        another_optional: ?[]<span class="tok-kw">const</span> <span class="tok-type">u8</span> = <span class="tok-null">null</span>,</span>
<span class="line" id="L2390">        another_required: []<span class="tok-kw">const</span> <span class="tok-type">u8</span> = <span class="tok-str">&quot;something else&quot;</span>,</span>
<span class="line" id="L2391">    };</span>
<span class="line" id="L2392">    <span class="tok-kw">try</span> teststringify(</span>
<span class="line" id="L2393">        <span class="tok-str">\\{&quot;optional&quot;:null,&quot;required&quot;:&quot;something&quot;,&quot;another_optional&quot;:null,&quot;another_required&quot;:&quot;something else&quot;}</span></span>

<span class="line" id="L2394">    ,</span>
<span class="line" id="L2395">        MyStruct{},</span>
<span class="line" id="L2396">        StringifyOptions{},</span>
<span class="line" id="L2397">    );</span>
<span class="line" id="L2398">    <span class="tok-kw">try</span> teststringify(</span>
<span class="line" id="L2399">        <span class="tok-str">\\{&quot;required&quot;:&quot;something&quot;,&quot;another_required&quot;:&quot;something else&quot;}</span></span>

<span class="line" id="L2400">    ,</span>
<span class="line" id="L2401">        MyStruct{},</span>
<span class="line" id="L2402">        StringifyOptions{ .emit_null_optional_fields = <span class="tok-null">false</span> },</span>
<span class="line" id="L2403">    );</span>
<span class="line" id="L2404"></span>
<span class="line" id="L2405">    <span class="tok-kw">var</span> ts = TokenStream.init(</span>
<span class="line" id="L2406">        <span class="tok-str">\\{&quot;required&quot;:&quot;something&quot;,&quot;another_required&quot;:&quot;something else&quot;}</span></span>

<span class="line" id="L2407">    );</span>
<span class="line" id="L2408">    <span class="tok-kw">try</span> std.testing.expect(<span class="tok-kw">try</span> parsesTo(MyStruct, MyStruct{}, &amp;ts, .{</span>
<span class="line" id="L2409">        .allocator = std.testing.allocator,</span>
<span class="line" id="L2410">    }));</span>
<span class="line" id="L2411">}</span>
<span class="line" id="L2412"></span>
<span class="line" id="L2413"><span class="tok-kw">test</span> <span class="tok-str">&quot;skipValue&quot;</span> {</span>
<span class="line" id="L2414">    <span class="tok-kw">var</span> ts = TokenStream.init(<span class="tok-str">&quot;false&quot;</span>);</span>
<span class="line" id="L2415">    <span class="tok-kw">try</span> skipValue(&amp;ts);</span>
<span class="line" id="L2416">    ts = TokenStream.init(<span class="tok-str">&quot;true&quot;</span>);</span>
<span class="line" id="L2417">    <span class="tok-kw">try</span> skipValue(&amp;ts);</span>
<span class="line" id="L2418">    ts = TokenStream.init(<span class="tok-str">&quot;null&quot;</span>);</span>
<span class="line" id="L2419">    <span class="tok-kw">try</span> skipValue(&amp;ts);</span>
<span class="line" id="L2420">    ts = TokenStream.init(<span class="tok-str">&quot;42&quot;</span>);</span>
<span class="line" id="L2421">    <span class="tok-kw">try</span> skipValue(&amp;ts);</span>
<span class="line" id="L2422">    ts = TokenStream.init(<span class="tok-str">&quot;42.0&quot;</span>);</span>
<span class="line" id="L2423">    <span class="tok-kw">try</span> skipValue(&amp;ts);</span>
<span class="line" id="L2424">    ts = TokenStream.init(<span class="tok-str">&quot;\&quot;foo\&quot;&quot;</span>);</span>
<span class="line" id="L2425">    <span class="tok-kw">try</span> skipValue(&amp;ts);</span>
<span class="line" id="L2426">    ts = TokenStream.init(<span class="tok-str">&quot;[101, 111, 121]&quot;</span>);</span>
<span class="line" id="L2427">    <span class="tok-kw">try</span> skipValue(&amp;ts);</span>
<span class="line" id="L2428">    ts = TokenStream.init(<span class="tok-str">&quot;{}&quot;</span>);</span>
<span class="line" id="L2429">    <span class="tok-kw">try</span> skipValue(&amp;ts);</span>
<span class="line" id="L2430">    ts = TokenStream.init(<span class="tok-str">&quot;{\&quot;foo\&quot;: \&quot;bar\&quot;}&quot;</span>);</span>
<span class="line" id="L2431">    <span class="tok-kw">try</span> skipValue(&amp;ts);</span>
<span class="line" id="L2432"></span>
<span class="line" id="L2433">    { <span class="tok-comment">// An absurd number of nestings</span>
</span>
<span class="line" id="L2434">        <span class="tok-kw">const</span> nestings = StreamingParser.default_max_nestings + <span class="tok-number">1</span>;</span>
<span class="line" id="L2435"></span>
<span class="line" id="L2436">        ts = TokenStream.init(<span class="tok-str">&quot;[&quot;</span> ** nestings ++ <span class="tok-str">&quot;]&quot;</span> ** nestings);</span>
<span class="line" id="L2437">        <span class="tok-kw">try</span> testing.expectError(<span class="tok-kw">error</span>.TooManyNestedItems, skipValue(&amp;ts));</span>
<span class="line" id="L2438">    }</span>
<span class="line" id="L2439"></span>
<span class="line" id="L2440">    { <span class="tok-comment">// Would a number token cause problems in a deeply-nested array?</span>
</span>
<span class="line" id="L2441">        <span class="tok-kw">const</span> nestings = StreamingParser.default_max_nestings;</span>
<span class="line" id="L2442">        <span class="tok-kw">const</span> deeply_nested_array = <span class="tok-str">&quot;[&quot;</span> ** nestings ++ <span class="tok-str">&quot;0.118, 999, 881.99, 911.9, 725, 3&quot;</span> ++ <span class="tok-str">&quot;]&quot;</span> ** nestings;</span>
<span class="line" id="L2443"></span>
<span class="line" id="L2444">        ts = TokenStream.init(deeply_nested_array);</span>
<span class="line" id="L2445">        <span class="tok-kw">try</span> skipValue(&amp;ts);</span>
<span class="line" id="L2446"></span>
<span class="line" id="L2447">        ts = TokenStream.init(<span class="tok-str">&quot;[&quot;</span> ++ deeply_nested_array ++ <span class="tok-str">&quot;]&quot;</span>);</span>
<span class="line" id="L2448">        <span class="tok-kw">try</span> testing.expectError(<span class="tok-kw">error</span>.TooManyNestedItems, skipValue(&amp;ts));</span>
<span class="line" id="L2449">    }</span>
<span class="line" id="L2450"></span>
<span class="line" id="L2451">    <span class="tok-comment">// Mismatched brace/square bracket</span>
</span>
<span class="line" id="L2452">    ts = TokenStream.init(<span class="tok-str">&quot;[102, 111, 111}&quot;</span>);</span>
<span class="line" id="L2453">    <span class="tok-kw">try</span> testing.expectError(<span class="tok-kw">error</span>.UnexpectedClosingBrace, skipValue(&amp;ts));</span>
<span class="line" id="L2454"></span>
<span class="line" id="L2455">    { <span class="tok-comment">// should fail if no value found (e.g. immediate close of object)</span>
</span>
<span class="line" id="L2456">        <span class="tok-kw">var</span> empty_object = TokenStream.init(<span class="tok-str">&quot;{}&quot;</span>);</span>
<span class="line" id="L2457">        assert(.ObjectBegin == (<span class="tok-kw">try</span> empty_object.next()).?);</span>
<span class="line" id="L2458">        <span class="tok-kw">try</span> testing.expectError(<span class="tok-kw">error</span>.UnexpectedJsonDepth, skipValue(&amp;empty_object));</span>
<span class="line" id="L2459"></span>
<span class="line" id="L2460">        <span class="tok-kw">var</span> empty_array = TokenStream.init(<span class="tok-str">&quot;[]&quot;</span>);</span>
<span class="line" id="L2461">        assert(.ArrayBegin == (<span class="tok-kw">try</span> empty_array.next()).?);</span>
<span class="line" id="L2462">        <span class="tok-kw">try</span> testing.expectError(<span class="tok-kw">error</span>.UnexpectedJsonDepth, skipValue(&amp;empty_array));</span>
<span class="line" id="L2463">    }</span>
<span class="line" id="L2464">}</span>
<span class="line" id="L2465"></span>
<span class="line" id="L2466"><span class="tok-kw">test</span> <span class="tok-str">&quot;stringify basic types&quot;</span> {</span>
<span class="line" id="L2467">    <span class="tok-kw">try</span> teststringify(<span class="tok-str">&quot;false&quot;</span>, <span class="tok-null">false</span>, StringifyOptions{});</span>
<span class="line" id="L2468">    <span class="tok-kw">try</span> teststringify(<span class="tok-str">&quot;true&quot;</span>, <span class="tok-null">true</span>, StringifyOptions{});</span>
<span class="line" id="L2469">    <span class="tok-kw">try</span> teststringify(<span class="tok-str">&quot;null&quot;</span>, <span class="tok-builtin">@as</span>(?<span class="tok-type">u8</span>, <span class="tok-null">null</span>), StringifyOptions{});</span>
<span class="line" id="L2470">    <span class="tok-kw">try</span> teststringify(<span class="tok-str">&quot;null&quot;</span>, <span class="tok-builtin">@as</span>(?*<span class="tok-type">u32</span>, <span class="tok-null">null</span>), StringifyOptions{});</span>
<span class="line" id="L2471">    <span class="tok-kw">try</span> teststringify(<span class="tok-str">&quot;42&quot;</span>, <span class="tok-number">42</span>, StringifyOptions{});</span>
<span class="line" id="L2472">    <span class="tok-kw">try</span> teststringify(<span class="tok-str">&quot;4.2e+01&quot;</span>, <span class="tok-number">42.0</span>, StringifyOptions{});</span>
<span class="line" id="L2473">    <span class="tok-kw">try</span> teststringify(<span class="tok-str">&quot;42&quot;</span>, <span class="tok-builtin">@as</span>(<span class="tok-type">u8</span>, <span class="tok-number">42</span>), StringifyOptions{});</span>
<span class="line" id="L2474">    <span class="tok-kw">try</span> teststringify(<span class="tok-str">&quot;42&quot;</span>, <span class="tok-builtin">@as</span>(<span class="tok-type">u128</span>, <span class="tok-number">42</span>), StringifyOptions{});</span>
<span class="line" id="L2475">    <span class="tok-kw">try</span> teststringify(<span class="tok-str">&quot;4.2e+01&quot;</span>, <span class="tok-builtin">@as</span>(<span class="tok-type">f32</span>, <span class="tok-number">42</span>), StringifyOptions{});</span>
<span class="line" id="L2476">    <span class="tok-kw">try</span> teststringify(<span class="tok-str">&quot;4.2e+01&quot;</span>, <span class="tok-builtin">@as</span>(<span class="tok-type">f64</span>, <span class="tok-number">42</span>), StringifyOptions{});</span>
<span class="line" id="L2477">    <span class="tok-kw">try</span> teststringify(<span class="tok-str">&quot;\&quot;ItBroke\&quot;&quot;</span>, <span class="tok-builtin">@as</span>(<span class="tok-type">anyerror</span>, <span class="tok-kw">error</span>.ItBroke), StringifyOptions{});</span>
<span class="line" id="L2478">}</span>
<span class="line" id="L2479"></span>
<span class="line" id="L2480"><span class="tok-kw">test</span> <span class="tok-str">&quot;stringify string&quot;</span> {</span>
<span class="line" id="L2481">    <span class="tok-kw">try</span> teststringify(<span class="tok-str">&quot;\&quot;hello\&quot;&quot;</span>, <span class="tok-str">&quot;hello&quot;</span>, StringifyOptions{});</span>
<span class="line" id="L2482">    <span class="tok-kw">try</span> teststringify(<span class="tok-str">&quot;\&quot;with\\nescapes\\r\&quot;&quot;</span>, <span class="tok-str">&quot;with\nescapes\r&quot;</span>, StringifyOptions{});</span>
<span class="line" id="L2483">    <span class="tok-kw">try</span> teststringify(<span class="tok-str">&quot;\&quot;with\\nescapes\\r\&quot;&quot;</span>, <span class="tok-str">&quot;with\nescapes\r&quot;</span>, StringifyOptions{ .string = .{ .String = .{ .escape_unicode = <span class="tok-null">true</span> } } });</span>
<span class="line" id="L2484">    <span class="tok-kw">try</span> teststringify(<span class="tok-str">&quot;\&quot;with unicode\\u0001\&quot;&quot;</span>, <span class="tok-str">&quot;with unicode\u{1}&quot;</span>, StringifyOptions{});</span>
<span class="line" id="L2485">    <span class="tok-kw">try</span> teststringify(<span class="tok-str">&quot;\&quot;with unicode\\u0001\&quot;&quot;</span>, <span class="tok-str">&quot;with unicode\u{1}&quot;</span>, StringifyOptions{ .string = .{ .String = .{ .escape_unicode = <span class="tok-null">true</span> } } });</span>
<span class="line" id="L2486">    <span class="tok-kw">try</span> teststringify(<span class="tok-str">&quot;\&quot;with unicode\u{80}\&quot;&quot;</span>, <span class="tok-str">&quot;with unicode\u{80}&quot;</span>, StringifyOptions{});</span>
<span class="line" id="L2487">    <span class="tok-kw">try</span> teststringify(<span class="tok-str">&quot;\&quot;with unicode\\u0080\&quot;&quot;</span>, <span class="tok-str">&quot;with unicode\u{80}&quot;</span>, StringifyOptions{ .string = .{ .String = .{ .escape_unicode = <span class="tok-null">true</span> } } });</span>
<span class="line" id="L2488">    <span class="tok-kw">try</span> teststringify(<span class="tok-str">&quot;\&quot;with unicode\u{FF}\&quot;&quot;</span>, <span class="tok-str">&quot;with unicode\u{FF}&quot;</span>, StringifyOptions{});</span>
<span class="line" id="L2489">    <span class="tok-kw">try</span> teststringify(<span class="tok-str">&quot;\&quot;with unicode\\u00ff\&quot;&quot;</span>, <span class="tok-str">&quot;with unicode\u{FF}&quot;</span>, StringifyOptions{ .string = .{ .String = .{ .escape_unicode = <span class="tok-null">true</span> } } });</span>
<span class="line" id="L2490">    <span class="tok-kw">try</span> teststringify(<span class="tok-str">&quot;\&quot;with unicode\u{100}\&quot;&quot;</span>, <span class="tok-str">&quot;with unicode\u{100}&quot;</span>, StringifyOptions{});</span>
<span class="line" id="L2491">    <span class="tok-kw">try</span> teststringify(<span class="tok-str">&quot;\&quot;with unicode\\u0100\&quot;&quot;</span>, <span class="tok-str">&quot;with unicode\u{100}&quot;</span>, StringifyOptions{ .string = .{ .String = .{ .escape_unicode = <span class="tok-null">true</span> } } });</span>
<span class="line" id="L2492">    <span class="tok-kw">try</span> teststringify(<span class="tok-str">&quot;\&quot;with unicode\u{800}\&quot;&quot;</span>, <span class="tok-str">&quot;with unicode\u{800}&quot;</span>, StringifyOptions{});</span>
<span class="line" id="L2493">    <span class="tok-kw">try</span> teststringify(<span class="tok-str">&quot;\&quot;with unicode\\u0800\&quot;&quot;</span>, <span class="tok-str">&quot;with unicode\u{800}&quot;</span>, StringifyOptions{ .string = .{ .String = .{ .escape_unicode = <span class="tok-null">true</span> } } });</span>
<span class="line" id="L2494">    <span class="tok-kw">try</span> teststringify(<span class="tok-str">&quot;\&quot;with unicode\u{8000}\&quot;&quot;</span>, <span class="tok-str">&quot;with unicode\u{8000}&quot;</span>, StringifyOptions{});</span>
<span class="line" id="L2495">    <span class="tok-kw">try</span> teststringify(<span class="tok-str">&quot;\&quot;with unicode\\u8000\&quot;&quot;</span>, <span class="tok-str">&quot;with unicode\u{8000}&quot;</span>, StringifyOptions{ .string = .{ .String = .{ .escape_unicode = <span class="tok-null">true</span> } } });</span>
<span class="line" id="L2496">    <span class="tok-kw">try</span> teststringify(<span class="tok-str">&quot;\&quot;with unicode\u{D799}\&quot;&quot;</span>, <span class="tok-str">&quot;with unicode\u{D799}&quot;</span>, StringifyOptions{});</span>
<span class="line" id="L2497">    <span class="tok-kw">try</span> teststringify(<span class="tok-str">&quot;\&quot;with unicode\\ud799\&quot;&quot;</span>, <span class="tok-str">&quot;with unicode\u{D799}&quot;</span>, StringifyOptions{ .string = .{ .String = .{ .escape_unicode = <span class="tok-null">true</span> } } });</span>
<span class="line" id="L2498">    <span class="tok-kw">try</span> teststringify(<span class="tok-str">&quot;\&quot;with unicode\u{10000}\&quot;&quot;</span>, <span class="tok-str">&quot;with unicode\u{10000}&quot;</span>, StringifyOptions{});</span>
<span class="line" id="L2499">    <span class="tok-kw">try</span> teststringify(<span class="tok-str">&quot;\&quot;with unicode\\ud800\\udc00\&quot;&quot;</span>, <span class="tok-str">&quot;with unicode\u{10000}&quot;</span>, StringifyOptions{ .string = .{ .String = .{ .escape_unicode = <span class="tok-null">true</span> } } });</span>
<span class="line" id="L2500">    <span class="tok-kw">try</span> teststringify(<span class="tok-str">&quot;\&quot;with unicode\u{10FFFF}\&quot;&quot;</span>, <span class="tok-str">&quot;with unicode\u{10FFFF}&quot;</span>, StringifyOptions{});</span>
<span class="line" id="L2501">    <span class="tok-kw">try</span> teststringify(<span class="tok-str">&quot;\&quot;with unicode\\udbff\\udfff\&quot;&quot;</span>, <span class="tok-str">&quot;with unicode\u{10FFFF}&quot;</span>, StringifyOptions{ .string = .{ .String = .{ .escape_unicode = <span class="tok-null">true</span> } } });</span>
<span class="line" id="L2502">    <span class="tok-kw">try</span> teststringify(<span class="tok-str">&quot;\&quot;/\&quot;&quot;</span>, <span class="tok-str">&quot;/&quot;</span>, StringifyOptions{});</span>
<span class="line" id="L2503">    <span class="tok-kw">try</span> teststringify(<span class="tok-str">&quot;\&quot;\\/\&quot;&quot;</span>, <span class="tok-str">&quot;/&quot;</span>, StringifyOptions{ .string = .{ .String = .{ .escape_solidus = <span class="tok-null">true</span> } } });</span>
<span class="line" id="L2504">}</span>
<span class="line" id="L2505"></span>
<span class="line" id="L2506"><span class="tok-kw">test</span> <span class="tok-str">&quot;stringify tagged unions&quot;</span> {</span>
<span class="line" id="L2507">    <span class="tok-kw">try</span> teststringify(<span class="tok-str">&quot;42&quot;</span>, <span class="tok-kw">union</span>(<span class="tok-kw">enum</span>) {</span>
<span class="line" id="L2508">        Foo: <span class="tok-type">u32</span>,</span>
<span class="line" id="L2509">        Bar: <span class="tok-type">bool</span>,</span>
<span class="line" id="L2510">    }{ .Foo = <span class="tok-number">42</span> }, StringifyOptions{});</span>
<span class="line" id="L2511">}</span>
<span class="line" id="L2512"></span>
<span class="line" id="L2513"><span class="tok-kw">test</span> <span class="tok-str">&quot;stringify struct&quot;</span> {</span>
<span class="line" id="L2514">    <span class="tok-kw">try</span> teststringify(<span class="tok-str">&quot;{\&quot;foo\&quot;:42}&quot;</span>, <span class="tok-kw">struct</span> {</span>
<span class="line" id="L2515">        foo: <span class="tok-type">u32</span>,</span>
<span class="line" id="L2516">    }{ .foo = <span class="tok-number">42</span> }, StringifyOptions{});</span>
<span class="line" id="L2517">}</span>
<span class="line" id="L2518"></span>
<span class="line" id="L2519"><span class="tok-kw">test</span> <span class="tok-str">&quot;stringify struct with string as array&quot;</span> {</span>
<span class="line" id="L2520">    <span class="tok-kw">try</span> teststringify(<span class="tok-str">&quot;{\&quot;foo\&quot;:\&quot;bar\&quot;}&quot;</span>, .{ .foo = <span class="tok-str">&quot;bar&quot;</span> }, StringifyOptions{});</span>
<span class="line" id="L2521">    <span class="tok-kw">try</span> teststringify(<span class="tok-str">&quot;{\&quot;foo\&quot;:[98,97,114]}&quot;</span>, .{ .foo = <span class="tok-str">&quot;bar&quot;</span> }, StringifyOptions{ .string = .Array });</span>
<span class="line" id="L2522">}</span>
<span class="line" id="L2523"></span>
<span class="line" id="L2524"><span class="tok-kw">test</span> <span class="tok-str">&quot;stringify struct with indentation&quot;</span> {</span>
<span class="line" id="L2525">    <span class="tok-kw">try</span> teststringify(</span>
<span class="line" id="L2526">        <span class="tok-str">\\{</span></span>

<span class="line" id="L2527">        <span class="tok-str">\\    &quot;foo&quot;: 42,</span></span>

<span class="line" id="L2528">        <span class="tok-str">\\    &quot;bar&quot;: [</span></span>

<span class="line" id="L2529">        <span class="tok-str">\\        1,</span></span>

<span class="line" id="L2530">        <span class="tok-str">\\        2,</span></span>

<span class="line" id="L2531">        <span class="tok-str">\\        3</span></span>

<span class="line" id="L2532">        <span class="tok-str">\\    ]</span></span>

<span class="line" id="L2533">        <span class="tok-str">\\}</span></span>

<span class="line" id="L2534">    ,</span>
<span class="line" id="L2535">        <span class="tok-kw">struct</span> {</span>
<span class="line" id="L2536">            foo: <span class="tok-type">u32</span>,</span>
<span class="line" id="L2537">            bar: [<span class="tok-number">3</span>]<span class="tok-type">u32</span>,</span>
<span class="line" id="L2538">        }{</span>
<span class="line" id="L2539">            .foo = <span class="tok-number">42</span>,</span>
<span class="line" id="L2540">            .bar = .{ <span class="tok-number">1</span>, <span class="tok-number">2</span>, <span class="tok-number">3</span> },</span>
<span class="line" id="L2541">        },</span>
<span class="line" id="L2542">        StringifyOptions{</span>
<span class="line" id="L2543">            .whitespace = .{},</span>
<span class="line" id="L2544">        },</span>
<span class="line" id="L2545">    );</span>
<span class="line" id="L2546">    <span class="tok-kw">try</span> teststringify(</span>
<span class="line" id="L2547">        <span class="tok-str">&quot;{\n\t\&quot;foo\&quot;:42,\n\t\&quot;bar\&quot;:[\n\t\t1,\n\t\t2,\n\t\t3\n\t]\n}&quot;</span>,</span>
<span class="line" id="L2548">        <span class="tok-kw">struct</span> {</span>
<span class="line" id="L2549">            foo: <span class="tok-type">u32</span>,</span>
<span class="line" id="L2550">            bar: [<span class="tok-number">3</span>]<span class="tok-type">u32</span>,</span>
<span class="line" id="L2551">        }{</span>
<span class="line" id="L2552">            .foo = <span class="tok-number">42</span>,</span>
<span class="line" id="L2553">            .bar = .{ <span class="tok-number">1</span>, <span class="tok-number">2</span>, <span class="tok-number">3</span> },</span>
<span class="line" id="L2554">        },</span>
<span class="line" id="L2555">        StringifyOptions{</span>
<span class="line" id="L2556">            .whitespace = .{</span>
<span class="line" id="L2557">                .indent = .Tab,</span>
<span class="line" id="L2558">                .separator = <span class="tok-null">false</span>,</span>
<span class="line" id="L2559">            },</span>
<span class="line" id="L2560">        },</span>
<span class="line" id="L2561">    );</span>
<span class="line" id="L2562">    <span class="tok-kw">try</span> teststringify(</span>
<span class="line" id="L2563">        <span class="tok-str">\\{&quot;foo&quot;:42,&quot;bar&quot;:[1,2,3]}</span></span>

<span class="line" id="L2564">    ,</span>
<span class="line" id="L2565">        <span class="tok-kw">struct</span> {</span>
<span class="line" id="L2566">            foo: <span class="tok-type">u32</span>,</span>
<span class="line" id="L2567">            bar: [<span class="tok-number">3</span>]<span class="tok-type">u32</span>,</span>
<span class="line" id="L2568">        }{</span>
<span class="line" id="L2569">            .foo = <span class="tok-number">42</span>,</span>
<span class="line" id="L2570">            .bar = .{ <span class="tok-number">1</span>, <span class="tok-number">2</span>, <span class="tok-number">3</span> },</span>
<span class="line" id="L2571">        },</span>
<span class="line" id="L2572">        StringifyOptions{</span>
<span class="line" id="L2573">            .whitespace = .{</span>
<span class="line" id="L2574">                .indent = .None,</span>
<span class="line" id="L2575">                .separator = <span class="tok-null">false</span>,</span>
<span class="line" id="L2576">            },</span>
<span class="line" id="L2577">        },</span>
<span class="line" id="L2578">    );</span>
<span class="line" id="L2579">}</span>
<span class="line" id="L2580"></span>
<span class="line" id="L2581"><span class="tok-kw">test</span> <span class="tok-str">&quot;stringify struct with void field&quot;</span> {</span>
<span class="line" id="L2582">    <span class="tok-kw">try</span> teststringify(<span class="tok-str">&quot;{\&quot;foo\&quot;:42}&quot;</span>, <span class="tok-kw">struct</span> {</span>
<span class="line" id="L2583">        foo: <span class="tok-type">u32</span>,</span>
<span class="line" id="L2584">        bar: <span class="tok-type">void</span> = {},</span>
<span class="line" id="L2585">    }{ .foo = <span class="tok-number">42</span> }, StringifyOptions{});</span>
<span class="line" id="L2586">}</span>
<span class="line" id="L2587"></span>
<span class="line" id="L2588"><span class="tok-kw">test</span> <span class="tok-str">&quot;stringify array of structs&quot;</span> {</span>
<span class="line" id="L2589">    <span class="tok-kw">const</span> MyStruct = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L2590">        foo: <span class="tok-type">u32</span>,</span>
<span class="line" id="L2591">    };</span>
<span class="line" id="L2592">    <span class="tok-kw">try</span> teststringify(<span class="tok-str">&quot;[{\&quot;foo\&quot;:42},{\&quot;foo\&quot;:100},{\&quot;foo\&quot;:1000}]&quot;</span>, [_]MyStruct{</span>
<span class="line" id="L2593">        MyStruct{ .foo = <span class="tok-number">42</span> },</span>
<span class="line" id="L2594">        MyStruct{ .foo = <span class="tok-number">100</span> },</span>
<span class="line" id="L2595">        MyStruct{ .foo = <span class="tok-number">1000</span> },</span>
<span class="line" id="L2596">    }, StringifyOptions{});</span>
<span class="line" id="L2597">}</span>
<span class="line" id="L2598"></span>
<span class="line" id="L2599"><span class="tok-kw">test</span> <span class="tok-str">&quot;stringify struct with custom stringifier&quot;</span> {</span>
<span class="line" id="L2600">    <span class="tok-kw">try</span> teststringify(<span class="tok-str">&quot;[\&quot;something special\&quot;,42]&quot;</span>, <span class="tok-kw">struct</span> {</span>
<span class="line" id="L2601">        foo: <span class="tok-type">u32</span>,</span>
<span class="line" id="L2602">        <span class="tok-kw">const</span> Self = <span class="tok-builtin">@This</span>();</span>
<span class="line" id="L2603">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">jsonStringify</span>(</span>
<span class="line" id="L2604">            value: Self,</span>
<span class="line" id="L2605">            options: StringifyOptions,</span>
<span class="line" id="L2606">            out_stream: <span class="tok-kw">anytype</span>,</span>
<span class="line" id="L2607">        ) !<span class="tok-type">void</span> {</span>
<span class="line" id="L2608">            _ = value;</span>
<span class="line" id="L2609">            <span class="tok-kw">try</span> out_stream.writeAll(<span class="tok-str">&quot;[\&quot;something special\&quot;,&quot;</span>);</span>
<span class="line" id="L2610">            <span class="tok-kw">try</span> stringify(<span class="tok-number">42</span>, options, out_stream);</span>
<span class="line" id="L2611">            <span class="tok-kw">try</span> out_stream.writeByte(<span class="tok-str">']'</span>);</span>
<span class="line" id="L2612">        }</span>
<span class="line" id="L2613">    }{ .foo = <span class="tok-number">42</span> }, StringifyOptions{});</span>
<span class="line" id="L2614">}</span>
<span class="line" id="L2615"></span>
<span class="line" id="L2616"><span class="tok-kw">test</span> <span class="tok-str">&quot;stringify vector&quot;</span> {</span>
<span class="line" id="L2617">    <span class="tok-kw">try</span> teststringify(<span class="tok-str">&quot;[1,1]&quot;</span>, <span class="tok-builtin">@splat</span>(<span class="tok-number">2</span>, <span class="tok-builtin">@as</span>(<span class="tok-type">u32</span>, <span class="tok-number">1</span>)), StringifyOptions{});</span>
<span class="line" id="L2618">}</span>
<span class="line" id="L2619"></span>
<span class="line" id="L2620"><span class="tok-kw">fn</span> <span class="tok-fn">teststringify</span>(expected: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>, value: <span class="tok-kw">anytype</span>, options: StringifyOptions) !<span class="tok-type">void</span> {</span>
<span class="line" id="L2621">    <span class="tok-kw">const</span> ValidationWriter = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L2622">        <span class="tok-kw">const</span> Self = <span class="tok-builtin">@This</span>();</span>
<span class="line" id="L2623">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> Writer = std.io.Writer(*Self, Error, write);</span>
<span class="line" id="L2624">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> Error = <span class="tok-kw">error</span>{</span>
<span class="line" id="L2625">            TooMuchData,</span>
<span class="line" id="L2626">            DifferentData,</span>
<span class="line" id="L2627">        };</span>
<span class="line" id="L2628"></span>
<span class="line" id="L2629">        expected_remaining: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>,</span>
<span class="line" id="L2630"></span>
<span class="line" id="L2631">        <span class="tok-kw">fn</span> <span class="tok-fn">init</span>(exp: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) Self {</span>
<span class="line" id="L2632">            <span class="tok-kw">return</span> .{ .expected_remaining = exp };</span>
<span class="line" id="L2633">        }</span>
<span class="line" id="L2634"></span>
<span class="line" id="L2635">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">writer</span>(self: *Self) Writer {</span>
<span class="line" id="L2636">            <span class="tok-kw">return</span> .{ .context = self };</span>
<span class="line" id="L2637">        }</span>
<span class="line" id="L2638"></span>
<span class="line" id="L2639">        <span class="tok-kw">fn</span> <span class="tok-fn">write</span>(self: *Self, bytes: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) Error!<span class="tok-type">usize</span> {</span>
<span class="line" id="L2640">            <span class="tok-kw">if</span> (self.expected_remaining.len &lt; bytes.len) {</span>
<span class="line" id="L2641">                std.debug.print(</span>
<span class="line" id="L2642">                    <span class="tok-str">\\====== expected this output: =========</span></span>

<span class="line" id="L2643">                    <span class="tok-str">\\{s}</span></span>

<span class="line" id="L2644">                    <span class="tok-str">\\======== instead found this: =========</span></span>

<span class="line" id="L2645">                    <span class="tok-str">\\{s}</span></span>

<span class="line" id="L2646">                    <span class="tok-str">\\======================================</span></span>

<span class="line" id="L2647">                , .{</span>
<span class="line" id="L2648">                    self.expected_remaining,</span>
<span class="line" id="L2649">                    bytes,</span>
<span class="line" id="L2650">                });</span>
<span class="line" id="L2651">                <span class="tok-kw">return</span> <span class="tok-kw">error</span>.TooMuchData;</span>
<span class="line" id="L2652">            }</span>
<span class="line" id="L2653">            <span class="tok-kw">if</span> (!mem.eql(<span class="tok-type">u8</span>, self.expected_remaining[<span class="tok-number">0</span>..bytes.len], bytes)) {</span>
<span class="line" id="L2654">                std.debug.print(</span>
<span class="line" id="L2655">                    <span class="tok-str">\\====== expected this output: =========</span></span>

<span class="line" id="L2656">                    <span class="tok-str">\\{s}</span></span>

<span class="line" id="L2657">                    <span class="tok-str">\\======== instead found this: =========</span></span>

<span class="line" id="L2658">                    <span class="tok-str">\\{s}</span></span>

<span class="line" id="L2659">                    <span class="tok-str">\\======================================</span></span>

<span class="line" id="L2660">                , .{</span>
<span class="line" id="L2661">                    self.expected_remaining[<span class="tok-number">0</span>..bytes.len],</span>
<span class="line" id="L2662">                    bytes,</span>
<span class="line" id="L2663">                });</span>
<span class="line" id="L2664">                <span class="tok-kw">return</span> <span class="tok-kw">error</span>.DifferentData;</span>
<span class="line" id="L2665">            }</span>
<span class="line" id="L2666">            self.expected_remaining = self.expected_remaining[bytes.len..];</span>
<span class="line" id="L2667">            <span class="tok-kw">return</span> bytes.len;</span>
<span class="line" id="L2668">        }</span>
<span class="line" id="L2669">    };</span>
<span class="line" id="L2670"></span>
<span class="line" id="L2671">    <span class="tok-kw">var</span> vos = ValidationWriter.init(expected);</span>
<span class="line" id="L2672">    <span class="tok-kw">try</span> stringify(value, options, vos.writer());</span>
<span class="line" id="L2673">    <span class="tok-kw">if</span> (vos.expected_remaining.len &gt; <span class="tok-number">0</span>) <span class="tok-kw">return</span> <span class="tok-kw">error</span>.NotEnoughData;</span>
<span class="line" id="L2674">}</span>
<span class="line" id="L2675"></span>
<span class="line" id="L2676"><span class="tok-kw">test</span> <span class="tok-str">&quot;encodesTo&quot;</span> {</span>
<span class="line" id="L2677">    <span class="tok-comment">// same</span>
</span>
<span class="line" id="L2678">    <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-null">true</span>, encodesTo(<span class="tok-str">&quot;false&quot;</span>, <span class="tok-str">&quot;false&quot;</span>));</span>
<span class="line" id="L2679">    <span class="tok-comment">// totally different</span>
</span>
<span class="line" id="L2680">    <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-null">false</span>, encodesTo(<span class="tok-str">&quot;false&quot;</span>, <span class="tok-str">&quot;true&quot;</span>));</span>
<span class="line" id="L2681">    <span class="tok-comment">// different lengths</span>
</span>
<span class="line" id="L2682">    <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-null">false</span>, encodesTo(<span class="tok-str">&quot;false&quot;</span>, <span class="tok-str">&quot;other&quot;</span>));</span>
<span class="line" id="L2683">    <span class="tok-comment">// with escape</span>
</span>
<span class="line" id="L2684">    <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-null">true</span>, encodesTo(<span class="tok-str">&quot;\\&quot;</span>, <span class="tok-str">&quot;\\\\&quot;</span>));</span>
<span class="line" id="L2685">    <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-null">true</span>, encodesTo(<span class="tok-str">&quot;with\nescape&quot;</span>, <span class="tok-str">&quot;with\\nescape&quot;</span>));</span>
<span class="line" id="L2686">    <span class="tok-comment">// with unicode</span>
</span>
<span class="line" id="L2687">    <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-null">true</span>, encodesTo(<span class="tok-str">&quot;ą&quot;</span>, <span class="tok-str">&quot;\\u0105&quot;</span>));</span>
<span class="line" id="L2688">    <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-null">true</span>, encodesTo(<span class="tok-str">&quot;😂&quot;</span>, <span class="tok-str">&quot;\\ud83d\\ude02&quot;</span>));</span>
<span class="line" id="L2689">    <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-null">true</span>, encodesTo(<span class="tok-str">&quot;withąunicode😂&quot;</span>, <span class="tok-str">&quot;with\\u0105unicode\\ud83d\\ude02&quot;</span>));</span>
<span class="line" id="L2690">}</span>
<span class="line" id="L2691"></span>
</code></pre></body>
</html>