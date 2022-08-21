<!doctype html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">    <title>fs/path.zig - source view</title>
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
<span class="line" id="L2"><span class="tok-kw">const</span> std = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;../std.zig&quot;</span>);</span>
<span class="line" id="L3"><span class="tok-kw">const</span> debug = std.debug;</span>
<span class="line" id="L4"><span class="tok-kw">const</span> assert = debug.assert;</span>
<span class="line" id="L5"><span class="tok-kw">const</span> testing = std.testing;</span>
<span class="line" id="L6"><span class="tok-kw">const</span> mem = std.mem;</span>
<span class="line" id="L7"><span class="tok-kw">const</span> fmt = std.fmt;</span>
<span class="line" id="L8"><span class="tok-kw">const</span> Allocator = mem.Allocator;</span>
<span class="line" id="L9"><span class="tok-kw">const</span> math = std.math;</span>
<span class="line" id="L10"><span class="tok-kw">const</span> windows = std.os.windows;</span>
<span class="line" id="L11"><span class="tok-kw">const</span> os = std.os;</span>
<span class="line" id="L12"><span class="tok-kw">const</span> fs = std.fs;</span>
<span class="line" id="L13"><span class="tok-kw">const</span> process = std.process;</span>
<span class="line" id="L14"><span class="tok-kw">const</span> native_os = builtin.target.os.tag;</span>
<span class="line" id="L15"></span>
<span class="line" id="L16"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> sep_windows = <span class="tok-str">'\\'</span>;</span>
<span class="line" id="L17"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> sep_posix = <span class="tok-str">'/'</span>;</span>
<span class="line" id="L18"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> sep = <span class="tok-kw">switch</span> (native_os) {</span>
<span class="line" id="L19">    .windows, .uefi =&gt; sep_windows,</span>
<span class="line" id="L20">    <span class="tok-kw">else</span> =&gt; sep_posix,</span>
<span class="line" id="L21">};</span>
<span class="line" id="L22"></span>
<span class="line" id="L23"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> sep_str_windows = <span class="tok-str">&quot;\\&quot;</span>;</span>
<span class="line" id="L24"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> sep_str_posix = <span class="tok-str">&quot;/&quot;</span>;</span>
<span class="line" id="L25"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> sep_str = <span class="tok-kw">switch</span> (native_os) {</span>
<span class="line" id="L26">    .windows, .uefi =&gt; sep_str_windows,</span>
<span class="line" id="L27">    <span class="tok-kw">else</span> =&gt; sep_str_posix,</span>
<span class="line" id="L28">};</span>
<span class="line" id="L29"></span>
<span class="line" id="L30"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> delimiter_windows = <span class="tok-str">';'</span>;</span>
<span class="line" id="L31"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> delimiter_posix = <span class="tok-str">':'</span>;</span>
<span class="line" id="L32"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> delimiter = <span class="tok-kw">if</span> (native_os == .windows) delimiter_windows <span class="tok-kw">else</span> delimiter_posix;</span>
<span class="line" id="L33"></span>
<span class="line" id="L34"><span class="tok-comment">/// Returns if the given byte is a valid path separator</span></span>
<span class="line" id="L35"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">isSep</span>(byte: <span class="tok-type">u8</span>) <span class="tok-type">bool</span> {</span>
<span class="line" id="L36">    <span class="tok-kw">return</span> <span class="tok-kw">switch</span> (native_os) {</span>
<span class="line" id="L37">        .windows =&gt; byte == <span class="tok-str">'/'</span> <span class="tok-kw">or</span> byte == <span class="tok-str">'\\'</span>,</span>
<span class="line" id="L38">        .uefi =&gt; byte == <span class="tok-str">'\\'</span>,</span>
<span class="line" id="L39">        <span class="tok-kw">else</span> =&gt; byte == <span class="tok-str">'/'</span>,</span>
<span class="line" id="L40">    };</span>
<span class="line" id="L41">}</span>
<span class="line" id="L42"></span>
<span class="line" id="L43"><span class="tok-comment">/// This is different from mem.join in that the separator will not be repeated if</span></span>
<span class="line" id="L44"><span class="tok-comment">/// it is found at the end or beginning of a pair of consecutive paths.</span></span>
<span class="line" id="L45"><span class="tok-kw">fn</span> <span class="tok-fn">joinSepMaybeZ</span>(allocator: Allocator, separator: <span class="tok-type">u8</span>, sepPredicate: <span class="tok-kw">fn</span> (<span class="tok-type">u8</span>) <span class="tok-type">bool</span>, paths: []<span class="tok-kw">const</span> []<span class="tok-kw">const</span> <span class="tok-type">u8</span>, zero: <span class="tok-type">bool</span>) ![]<span class="tok-type">u8</span> {</span>
<span class="line" id="L46">    <span class="tok-kw">if</span> (paths.len == <span class="tok-number">0</span>) <span class="tok-kw">return</span> <span class="tok-kw">if</span> (zero) <span class="tok-kw">try</span> allocator.dupe(<span class="tok-type">u8</span>, &amp;[<span class="tok-number">1</span>]<span class="tok-type">u8</span>{<span class="tok-number">0</span>}) <span class="tok-kw">else</span> &amp;[<span class="tok-number">0</span>]<span class="tok-type">u8</span>{};</span>
<span class="line" id="L47"></span>
<span class="line" id="L48">    <span class="tok-comment">// Find first non-empty path index.</span>
</span>
<span class="line" id="L49">    <span class="tok-kw">const</span> first_path_index = blk: {</span>
<span class="line" id="L50">        <span class="tok-kw">for</span> (paths) |path, index| {</span>
<span class="line" id="L51">            <span class="tok-kw">if</span> (path.len == <span class="tok-number">0</span>) <span class="tok-kw">continue</span> <span class="tok-kw">else</span> <span class="tok-kw">break</span> :blk index;</span>
<span class="line" id="L52">        }</span>
<span class="line" id="L53"></span>
<span class="line" id="L54">        <span class="tok-comment">// All paths provided were empty, so return early.</span>
</span>
<span class="line" id="L55">        <span class="tok-kw">return</span> <span class="tok-kw">if</span> (zero) <span class="tok-kw">try</span> allocator.dupe(<span class="tok-type">u8</span>, &amp;[<span class="tok-number">1</span>]<span class="tok-type">u8</span>{<span class="tok-number">0</span>}) <span class="tok-kw">else</span> &amp;[<span class="tok-number">0</span>]<span class="tok-type">u8</span>{};</span>
<span class="line" id="L56">    };</span>
<span class="line" id="L57"></span>
<span class="line" id="L58">    <span class="tok-comment">// Calculate length needed for resulting joined path buffer.</span>
</span>
<span class="line" id="L59">    <span class="tok-kw">const</span> total_len = blk: {</span>
<span class="line" id="L60">        <span class="tok-kw">var</span> sum: <span class="tok-type">usize</span> = paths[first_path_index].len;</span>
<span class="line" id="L61">        <span class="tok-kw">var</span> prev_path = paths[first_path_index];</span>
<span class="line" id="L62">        assert(prev_path.len &gt; <span class="tok-number">0</span>);</span>
<span class="line" id="L63">        <span class="tok-kw">var</span> i: <span class="tok-type">usize</span> = first_path_index + <span class="tok-number">1</span>;</span>
<span class="line" id="L64">        <span class="tok-kw">while</span> (i &lt; paths.len) : (i += <span class="tok-number">1</span>) {</span>
<span class="line" id="L65">            <span class="tok-kw">const</span> this_path = paths[i];</span>
<span class="line" id="L66">            <span class="tok-kw">if</span> (this_path.len == <span class="tok-number">0</span>) <span class="tok-kw">continue</span>;</span>
<span class="line" id="L67">            <span class="tok-kw">const</span> prev_sep = sepPredicate(prev_path[prev_path.len - <span class="tok-number">1</span>]);</span>
<span class="line" id="L68">            <span class="tok-kw">const</span> this_sep = sepPredicate(this_path[<span class="tok-number">0</span>]);</span>
<span class="line" id="L69">            sum += <span class="tok-builtin">@boolToInt</span>(!prev_sep <span class="tok-kw">and</span> !this_sep);</span>
<span class="line" id="L70">            sum += <span class="tok-kw">if</span> (prev_sep <span class="tok-kw">and</span> this_sep) this_path.len - <span class="tok-number">1</span> <span class="tok-kw">else</span> this_path.len;</span>
<span class="line" id="L71">            prev_path = this_path;</span>
<span class="line" id="L72">        }</span>
<span class="line" id="L73"></span>
<span class="line" id="L74">        <span class="tok-kw">if</span> (zero) sum += <span class="tok-number">1</span>;</span>
<span class="line" id="L75">        <span class="tok-kw">break</span> :blk sum;</span>
<span class="line" id="L76">    };</span>
<span class="line" id="L77"></span>
<span class="line" id="L78">    <span class="tok-kw">const</span> buf = <span class="tok-kw">try</span> allocator.alloc(<span class="tok-type">u8</span>, total_len);</span>
<span class="line" id="L79">    <span class="tok-kw">errdefer</span> allocator.free(buf);</span>
<span class="line" id="L80"></span>
<span class="line" id="L81">    mem.copy(<span class="tok-type">u8</span>, buf, paths[first_path_index]);</span>
<span class="line" id="L82">    <span class="tok-kw">var</span> buf_index: <span class="tok-type">usize</span> = paths[first_path_index].len;</span>
<span class="line" id="L83">    <span class="tok-kw">var</span> prev_path = paths[first_path_index];</span>
<span class="line" id="L84">    assert(prev_path.len &gt; <span class="tok-number">0</span>);</span>
<span class="line" id="L85">    <span class="tok-kw">var</span> i: <span class="tok-type">usize</span> = first_path_index + <span class="tok-number">1</span>;</span>
<span class="line" id="L86">    <span class="tok-kw">while</span> (i &lt; paths.len) : (i += <span class="tok-number">1</span>) {</span>
<span class="line" id="L87">        <span class="tok-kw">const</span> this_path = paths[i];</span>
<span class="line" id="L88">        <span class="tok-kw">if</span> (this_path.len == <span class="tok-number">0</span>) <span class="tok-kw">continue</span>;</span>
<span class="line" id="L89">        <span class="tok-kw">const</span> prev_sep = sepPredicate(prev_path[prev_path.len - <span class="tok-number">1</span>]);</span>
<span class="line" id="L90">        <span class="tok-kw">const</span> this_sep = sepPredicate(this_path[<span class="tok-number">0</span>]);</span>
<span class="line" id="L91">        <span class="tok-kw">if</span> (!prev_sep <span class="tok-kw">and</span> !this_sep) {</span>
<span class="line" id="L92">            buf[buf_index] = separator;</span>
<span class="line" id="L93">            buf_index += <span class="tok-number">1</span>;</span>
<span class="line" id="L94">        }</span>
<span class="line" id="L95">        <span class="tok-kw">const</span> adjusted_path = <span class="tok-kw">if</span> (prev_sep <span class="tok-kw">and</span> this_sep) this_path[<span class="tok-number">1</span>..] <span class="tok-kw">else</span> this_path;</span>
<span class="line" id="L96">        mem.copy(<span class="tok-type">u8</span>, buf[buf_index..], adjusted_path);</span>
<span class="line" id="L97">        buf_index += adjusted_path.len;</span>
<span class="line" id="L98">        prev_path = this_path;</span>
<span class="line" id="L99">    }</span>
<span class="line" id="L100"></span>
<span class="line" id="L101">    <span class="tok-kw">if</span> (zero) buf[buf.len - <span class="tok-number">1</span>] = <span class="tok-number">0</span>;</span>
<span class="line" id="L102"></span>
<span class="line" id="L103">    <span class="tok-comment">// No need for shrink since buf is exactly the correct size.</span>
</span>
<span class="line" id="L104">    <span class="tok-kw">return</span> buf;</span>
<span class="line" id="L105">}</span>
<span class="line" id="L106"></span>
<span class="line" id="L107"><span class="tok-comment">/// Naively combines a series of paths with the native path seperator.</span></span>
<span class="line" id="L108"><span class="tok-comment">/// Allocates memory for the result, which must be freed by the caller.</span></span>
<span class="line" id="L109"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">join</span>(allocator: Allocator, paths: []<span class="tok-kw">const</span> []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) ![]<span class="tok-type">u8</span> {</span>
<span class="line" id="L110">    <span class="tok-kw">return</span> joinSepMaybeZ(allocator, sep, isSep, paths, <span class="tok-null">false</span>);</span>
<span class="line" id="L111">}</span>
<span class="line" id="L112"></span>
<span class="line" id="L113"><span class="tok-comment">/// Naively combines a series of paths with the native path seperator and null terminator.</span></span>
<span class="line" id="L114"><span class="tok-comment">/// Allocates memory for the result, which must be freed by the caller.</span></span>
<span class="line" id="L115"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">joinZ</span>(allocator: Allocator, paths: []<span class="tok-kw">const</span> []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) ![:<span class="tok-number">0</span>]<span class="tok-type">u8</span> {</span>
<span class="line" id="L116">    <span class="tok-kw">const</span> out = <span class="tok-kw">try</span> joinSepMaybeZ(allocator, sep, isSep, paths, <span class="tok-null">true</span>);</span>
<span class="line" id="L117">    <span class="tok-kw">return</span> out[<span class="tok-number">0</span> .. out.len - <span class="tok-number">1</span> :<span class="tok-number">0</span>];</span>
<span class="line" id="L118">}</span>
<span class="line" id="L119"></span>
<span class="line" id="L120"><span class="tok-kw">fn</span> <span class="tok-fn">testJoinMaybeZUefi</span>(paths: []<span class="tok-kw">const</span> []<span class="tok-kw">const</span> <span class="tok-type">u8</span>, expected: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>, zero: <span class="tok-type">bool</span>) !<span class="tok-type">void</span> {</span>
<span class="line" id="L121">    <span class="tok-kw">const</span> uefiIsSep = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L122">        <span class="tok-kw">fn</span> <span class="tok-fn">isSep</span>(byte: <span class="tok-type">u8</span>) <span class="tok-type">bool</span> {</span>
<span class="line" id="L123">            <span class="tok-kw">return</span> byte == <span class="tok-str">'\\'</span>;</span>
<span class="line" id="L124">        }</span>
<span class="line" id="L125">    }.isSep;</span>
<span class="line" id="L126">    <span class="tok-kw">const</span> actual = <span class="tok-kw">try</span> joinSepMaybeZ(testing.allocator, sep_windows, uefiIsSep, paths, zero);</span>
<span class="line" id="L127">    <span class="tok-kw">defer</span> testing.allocator.free(actual);</span>
<span class="line" id="L128">    <span class="tok-kw">try</span> testing.expectEqualSlices(<span class="tok-type">u8</span>, expected, <span class="tok-kw">if</span> (zero) actual[<span class="tok-number">0</span> .. actual.len - <span class="tok-number">1</span> :<span class="tok-number">0</span>] <span class="tok-kw">else</span> actual);</span>
<span class="line" id="L129">}</span>
<span class="line" id="L130"></span>
<span class="line" id="L131"><span class="tok-kw">fn</span> <span class="tok-fn">testJoinMaybeZWindows</span>(paths: []<span class="tok-kw">const</span> []<span class="tok-kw">const</span> <span class="tok-type">u8</span>, expected: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>, zero: <span class="tok-type">bool</span>) !<span class="tok-type">void</span> {</span>
<span class="line" id="L132">    <span class="tok-kw">const</span> windowsIsSep = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L133">        <span class="tok-kw">fn</span> <span class="tok-fn">isSep</span>(byte: <span class="tok-type">u8</span>) <span class="tok-type">bool</span> {</span>
<span class="line" id="L134">            <span class="tok-kw">return</span> byte == <span class="tok-str">'/'</span> <span class="tok-kw">or</span> byte == <span class="tok-str">'\\'</span>;</span>
<span class="line" id="L135">        }</span>
<span class="line" id="L136">    }.isSep;</span>
<span class="line" id="L137">    <span class="tok-kw">const</span> actual = <span class="tok-kw">try</span> joinSepMaybeZ(testing.allocator, sep_windows, windowsIsSep, paths, zero);</span>
<span class="line" id="L138">    <span class="tok-kw">defer</span> testing.allocator.free(actual);</span>
<span class="line" id="L139">    <span class="tok-kw">try</span> testing.expectEqualSlices(<span class="tok-type">u8</span>, expected, <span class="tok-kw">if</span> (zero) actual[<span class="tok-number">0</span> .. actual.len - <span class="tok-number">1</span> :<span class="tok-number">0</span>] <span class="tok-kw">else</span> actual);</span>
<span class="line" id="L140">}</span>
<span class="line" id="L141"></span>
<span class="line" id="L142"><span class="tok-kw">fn</span> <span class="tok-fn">testJoinMaybeZPosix</span>(paths: []<span class="tok-kw">const</span> []<span class="tok-kw">const</span> <span class="tok-type">u8</span>, expected: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>, zero: <span class="tok-type">bool</span>) !<span class="tok-type">void</span> {</span>
<span class="line" id="L143">    <span class="tok-kw">const</span> posixIsSep = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L144">        <span class="tok-kw">fn</span> <span class="tok-fn">isSep</span>(byte: <span class="tok-type">u8</span>) <span class="tok-type">bool</span> {</span>
<span class="line" id="L145">            <span class="tok-kw">return</span> byte == <span class="tok-str">'/'</span>;</span>
<span class="line" id="L146">        }</span>
<span class="line" id="L147">    }.isSep;</span>
<span class="line" id="L148">    <span class="tok-kw">const</span> actual = <span class="tok-kw">try</span> joinSepMaybeZ(testing.allocator, sep_posix, posixIsSep, paths, zero);</span>
<span class="line" id="L149">    <span class="tok-kw">defer</span> testing.allocator.free(actual);</span>
<span class="line" id="L150">    <span class="tok-kw">try</span> testing.expectEqualSlices(<span class="tok-type">u8</span>, expected, <span class="tok-kw">if</span> (zero) actual[<span class="tok-number">0</span> .. actual.len - <span class="tok-number">1</span> :<span class="tok-number">0</span>] <span class="tok-kw">else</span> actual);</span>
<span class="line" id="L151">}</span>
<span class="line" id="L152"></span>
<span class="line" id="L153"><span class="tok-kw">test</span> <span class="tok-str">&quot;join&quot;</span> {</span>
<span class="line" id="L154">    {</span>
<span class="line" id="L155">        <span class="tok-kw">const</span> actual: []<span class="tok-type">u8</span> = <span class="tok-kw">try</span> join(testing.allocator, &amp;[_][]<span class="tok-kw">const</span> <span class="tok-type">u8</span>{});</span>
<span class="line" id="L156">        <span class="tok-kw">defer</span> testing.allocator.free(actual);</span>
<span class="line" id="L157">        <span class="tok-kw">try</span> testing.expectEqualSlices(<span class="tok-type">u8</span>, <span class="tok-str">&quot;&quot;</span>, actual);</span>
<span class="line" id="L158">    }</span>
<span class="line" id="L159">    {</span>
<span class="line" id="L160">        <span class="tok-kw">const</span> actual: [:<span class="tok-number">0</span>]<span class="tok-type">u8</span> = <span class="tok-kw">try</span> joinZ(testing.allocator, &amp;[_][]<span class="tok-kw">const</span> <span class="tok-type">u8</span>{});</span>
<span class="line" id="L161">        <span class="tok-kw">defer</span> testing.allocator.free(actual);</span>
<span class="line" id="L162">        <span class="tok-kw">try</span> testing.expectEqualSlices(<span class="tok-type">u8</span>, <span class="tok-str">&quot;&quot;</span>, actual);</span>
<span class="line" id="L163">    }</span>
<span class="line" id="L164">    <span class="tok-kw">for</span> (&amp;[_]<span class="tok-type">bool</span>{ <span class="tok-null">false</span>, <span class="tok-null">true</span> }) |zero| {</span>
<span class="line" id="L165">        <span class="tok-kw">try</span> testJoinMaybeZWindows(&amp;[_][]<span class="tok-kw">const</span> <span class="tok-type">u8</span>{}, <span class="tok-str">&quot;&quot;</span>, zero);</span>
<span class="line" id="L166">        <span class="tok-kw">try</span> testJoinMaybeZWindows(&amp;[_][]<span class="tok-kw">const</span> <span class="tok-type">u8</span>{ <span class="tok-str">&quot;c:\\a\\b&quot;</span>, <span class="tok-str">&quot;c&quot;</span> }, <span class="tok-str">&quot;c:\\a\\b\\c&quot;</span>, zero);</span>
<span class="line" id="L167">        <span class="tok-kw">try</span> testJoinMaybeZWindows(&amp;[_][]<span class="tok-kw">const</span> <span class="tok-type">u8</span>{ <span class="tok-str">&quot;c:\\a\\b&quot;</span>, <span class="tok-str">&quot;c&quot;</span> }, <span class="tok-str">&quot;c:\\a\\b\\c&quot;</span>, zero);</span>
<span class="line" id="L168">        <span class="tok-kw">try</span> testJoinMaybeZWindows(&amp;[_][]<span class="tok-kw">const</span> <span class="tok-type">u8</span>{ <span class="tok-str">&quot;c:\\a\\b\\&quot;</span>, <span class="tok-str">&quot;c&quot;</span> }, <span class="tok-str">&quot;c:\\a\\b\\c&quot;</span>, zero);</span>
<span class="line" id="L169"></span>
<span class="line" id="L170">        <span class="tok-kw">try</span> testJoinMaybeZWindows(&amp;[_][]<span class="tok-kw">const</span> <span class="tok-type">u8</span>{ <span class="tok-str">&quot;c:\\&quot;</span>, <span class="tok-str">&quot;a&quot;</span>, <span class="tok-str">&quot;b\\&quot;</span>, <span class="tok-str">&quot;c&quot;</span> }, <span class="tok-str">&quot;c:\\a\\b\\c&quot;</span>, zero);</span>
<span class="line" id="L171">        <span class="tok-kw">try</span> testJoinMaybeZWindows(&amp;[_][]<span class="tok-kw">const</span> <span class="tok-type">u8</span>{ <span class="tok-str">&quot;c:\\a\\&quot;</span>, <span class="tok-str">&quot;b\\&quot;</span>, <span class="tok-str">&quot;c&quot;</span> }, <span class="tok-str">&quot;c:\\a\\b\\c&quot;</span>, zero);</span>
<span class="line" id="L172"></span>
<span class="line" id="L173">        <span class="tok-kw">try</span> testJoinMaybeZWindows(</span>
<span class="line" id="L174">            &amp;[_][]<span class="tok-kw">const</span> <span class="tok-type">u8</span>{ <span class="tok-str">&quot;c:\\home\\andy\\dev\\zig\\build\\lib\\zig\\std&quot;</span>, <span class="tok-str">&quot;io.zig&quot;</span> },</span>
<span class="line" id="L175">            <span class="tok-str">&quot;c:\\home\\andy\\dev\\zig\\build\\lib\\zig\\std\\io.zig&quot;</span>,</span>
<span class="line" id="L176">            zero,</span>
<span class="line" id="L177">        );</span>
<span class="line" id="L178"></span>
<span class="line" id="L179">        <span class="tok-kw">try</span> testJoinMaybeZUefi(&amp;[_][]<span class="tok-kw">const</span> <span class="tok-type">u8</span>{ <span class="tok-str">&quot;EFI&quot;</span>, <span class="tok-str">&quot;Boot&quot;</span>, <span class="tok-str">&quot;bootx64.efi&quot;</span> }, <span class="tok-str">&quot;EFI\\Boot\\bootx64.efi&quot;</span>, zero);</span>
<span class="line" id="L180">        <span class="tok-kw">try</span> testJoinMaybeZUefi(&amp;[_][]<span class="tok-kw">const</span> <span class="tok-type">u8</span>{ <span class="tok-str">&quot;EFI\\Boot&quot;</span>, <span class="tok-str">&quot;bootx64.efi&quot;</span> }, <span class="tok-str">&quot;EFI\\Boot\\bootx64.efi&quot;</span>, zero);</span>
<span class="line" id="L181">        <span class="tok-kw">try</span> testJoinMaybeZUefi(&amp;[_][]<span class="tok-kw">const</span> <span class="tok-type">u8</span>{ <span class="tok-str">&quot;EFI\\&quot;</span>, <span class="tok-str">&quot;\\Boot&quot;</span>, <span class="tok-str">&quot;bootx64.efi&quot;</span> }, <span class="tok-str">&quot;EFI\\Boot\\bootx64.efi&quot;</span>, zero);</span>
<span class="line" id="L182">        <span class="tok-kw">try</span> testJoinMaybeZUefi(&amp;[_][]<span class="tok-kw">const</span> <span class="tok-type">u8</span>{ <span class="tok-str">&quot;EFI\\&quot;</span>, <span class="tok-str">&quot;\\Boot\\&quot;</span>, <span class="tok-str">&quot;\\bootx64.efi&quot;</span> }, <span class="tok-str">&quot;EFI\\Boot\\bootx64.efi&quot;</span>, zero);</span>
<span class="line" id="L183"></span>
<span class="line" id="L184">        <span class="tok-kw">try</span> testJoinMaybeZWindows(&amp;[_][]<span class="tok-kw">const</span> <span class="tok-type">u8</span>{ <span class="tok-str">&quot;c:\\&quot;</span>, <span class="tok-str">&quot;a&quot;</span>, <span class="tok-str">&quot;b/&quot;</span>, <span class="tok-str">&quot;c&quot;</span> }, <span class="tok-str">&quot;c:\\a\\b/c&quot;</span>, zero);</span>
<span class="line" id="L185">        <span class="tok-kw">try</span> testJoinMaybeZWindows(&amp;[_][]<span class="tok-kw">const</span> <span class="tok-type">u8</span>{ <span class="tok-str">&quot;c:\\a/&quot;</span>, <span class="tok-str">&quot;b\\&quot;</span>, <span class="tok-str">&quot;/c&quot;</span> }, <span class="tok-str">&quot;c:\\a/b\\c&quot;</span>, zero);</span>
<span class="line" id="L186"></span>
<span class="line" id="L187">        <span class="tok-kw">try</span> testJoinMaybeZWindows(&amp;[_][]<span class="tok-kw">const</span> <span class="tok-type">u8</span>{ <span class="tok-str">&quot;&quot;</span>, <span class="tok-str">&quot;c:\\&quot;</span>, <span class="tok-str">&quot;&quot;</span>, <span class="tok-str">&quot;&quot;</span>, <span class="tok-str">&quot;a&quot;</span>, <span class="tok-str">&quot;b\\&quot;</span>, <span class="tok-str">&quot;c&quot;</span>, <span class="tok-str">&quot;&quot;</span> }, <span class="tok-str">&quot;c:\\a\\b\\c&quot;</span>, zero);</span>
<span class="line" id="L188">        <span class="tok-kw">try</span> testJoinMaybeZWindows(&amp;[_][]<span class="tok-kw">const</span> <span class="tok-type">u8</span>{ <span class="tok-str">&quot;c:\\a/&quot;</span>, <span class="tok-str">&quot;&quot;</span>, <span class="tok-str">&quot;b\\&quot;</span>, <span class="tok-str">&quot;&quot;</span>, <span class="tok-str">&quot;/c&quot;</span> }, <span class="tok-str">&quot;c:\\a/b\\c&quot;</span>, zero);</span>
<span class="line" id="L189">        <span class="tok-kw">try</span> testJoinMaybeZWindows(&amp;[_][]<span class="tok-kw">const</span> <span class="tok-type">u8</span>{ <span class="tok-str">&quot;&quot;</span>, <span class="tok-str">&quot;&quot;</span> }, <span class="tok-str">&quot;&quot;</span>, zero);</span>
<span class="line" id="L190"></span>
<span class="line" id="L191">        <span class="tok-kw">try</span> testJoinMaybeZPosix(&amp;[_][]<span class="tok-kw">const</span> <span class="tok-type">u8</span>{}, <span class="tok-str">&quot;&quot;</span>, zero);</span>
<span class="line" id="L192">        <span class="tok-kw">try</span> testJoinMaybeZPosix(&amp;[_][]<span class="tok-kw">const</span> <span class="tok-type">u8</span>{ <span class="tok-str">&quot;/a/b&quot;</span>, <span class="tok-str">&quot;c&quot;</span> }, <span class="tok-str">&quot;/a/b/c&quot;</span>, zero);</span>
<span class="line" id="L193">        <span class="tok-kw">try</span> testJoinMaybeZPosix(&amp;[_][]<span class="tok-kw">const</span> <span class="tok-type">u8</span>{ <span class="tok-str">&quot;/a/b/&quot;</span>, <span class="tok-str">&quot;c&quot;</span> }, <span class="tok-str">&quot;/a/b/c&quot;</span>, zero);</span>
<span class="line" id="L194"></span>
<span class="line" id="L195">        <span class="tok-kw">try</span> testJoinMaybeZPosix(&amp;[_][]<span class="tok-kw">const</span> <span class="tok-type">u8</span>{ <span class="tok-str">&quot;/&quot;</span>, <span class="tok-str">&quot;a&quot;</span>, <span class="tok-str">&quot;b/&quot;</span>, <span class="tok-str">&quot;c&quot;</span> }, <span class="tok-str">&quot;/a/b/c&quot;</span>, zero);</span>
<span class="line" id="L196">        <span class="tok-kw">try</span> testJoinMaybeZPosix(&amp;[_][]<span class="tok-kw">const</span> <span class="tok-type">u8</span>{ <span class="tok-str">&quot;/a/&quot;</span>, <span class="tok-str">&quot;b/&quot;</span>, <span class="tok-str">&quot;c&quot;</span> }, <span class="tok-str">&quot;/a/b/c&quot;</span>, zero);</span>
<span class="line" id="L197"></span>
<span class="line" id="L198">        <span class="tok-kw">try</span> testJoinMaybeZPosix(</span>
<span class="line" id="L199">            &amp;[_][]<span class="tok-kw">const</span> <span class="tok-type">u8</span>{ <span class="tok-str">&quot;/home/andy/dev/zig/build/lib/zig/std&quot;</span>, <span class="tok-str">&quot;io.zig&quot;</span> },</span>
<span class="line" id="L200">            <span class="tok-str">&quot;/home/andy/dev/zig/build/lib/zig/std/io.zig&quot;</span>,</span>
<span class="line" id="L201">            zero,</span>
<span class="line" id="L202">        );</span>
<span class="line" id="L203"></span>
<span class="line" id="L204">        <span class="tok-kw">try</span> testJoinMaybeZPosix(&amp;[_][]<span class="tok-kw">const</span> <span class="tok-type">u8</span>{ <span class="tok-str">&quot;a&quot;</span>, <span class="tok-str">&quot;/c&quot;</span> }, <span class="tok-str">&quot;a/c&quot;</span>, zero);</span>
<span class="line" id="L205">        <span class="tok-kw">try</span> testJoinMaybeZPosix(&amp;[_][]<span class="tok-kw">const</span> <span class="tok-type">u8</span>{ <span class="tok-str">&quot;a/&quot;</span>, <span class="tok-str">&quot;/c&quot;</span> }, <span class="tok-str">&quot;a/c&quot;</span>, zero);</span>
<span class="line" id="L206"></span>
<span class="line" id="L207">        <span class="tok-kw">try</span> testJoinMaybeZPosix(&amp;[_][]<span class="tok-kw">const</span> <span class="tok-type">u8</span>{ <span class="tok-str">&quot;&quot;</span>, <span class="tok-str">&quot;/&quot;</span>, <span class="tok-str">&quot;a&quot;</span>, <span class="tok-str">&quot;&quot;</span>, <span class="tok-str">&quot;b/&quot;</span>, <span class="tok-str">&quot;c&quot;</span>, <span class="tok-str">&quot;&quot;</span> }, <span class="tok-str">&quot;/a/b/c&quot;</span>, zero);</span>
<span class="line" id="L208">        <span class="tok-kw">try</span> testJoinMaybeZPosix(&amp;[_][]<span class="tok-kw">const</span> <span class="tok-type">u8</span>{ <span class="tok-str">&quot;/a/&quot;</span>, <span class="tok-str">&quot;&quot;</span>, <span class="tok-str">&quot;&quot;</span>, <span class="tok-str">&quot;b/&quot;</span>, <span class="tok-str">&quot;c&quot;</span> }, <span class="tok-str">&quot;/a/b/c&quot;</span>, zero);</span>
<span class="line" id="L209">        <span class="tok-kw">try</span> testJoinMaybeZPosix(&amp;[_][]<span class="tok-kw">const</span> <span class="tok-type">u8</span>{ <span class="tok-str">&quot;&quot;</span>, <span class="tok-str">&quot;&quot;</span> }, <span class="tok-str">&quot;&quot;</span>, zero);</span>
<span class="line" id="L210">    }</span>
<span class="line" id="L211">}</span>
<span class="line" id="L212"></span>
<span class="line" id="L213"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">isAbsoluteZ</span>(path_c: [*:<span class="tok-number">0</span>]<span class="tok-kw">const</span> <span class="tok-type">u8</span>) <span class="tok-type">bool</span> {</span>
<span class="line" id="L214">    <span class="tok-kw">if</span> (native_os == .windows) {</span>
<span class="line" id="L215">        <span class="tok-kw">return</span> isAbsoluteWindowsZ(path_c);</span>
<span class="line" id="L216">    } <span class="tok-kw">else</span> {</span>
<span class="line" id="L217">        <span class="tok-kw">return</span> isAbsolutePosixZ(path_c);</span>
<span class="line" id="L218">    }</span>
<span class="line" id="L219">}</span>
<span class="line" id="L220"></span>
<span class="line" id="L221"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">isAbsolute</span>(path: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) <span class="tok-type">bool</span> {</span>
<span class="line" id="L222">    <span class="tok-kw">if</span> (native_os == .windows) {</span>
<span class="line" id="L223">        <span class="tok-kw">return</span> isAbsoluteWindows(path);</span>
<span class="line" id="L224">    } <span class="tok-kw">else</span> {</span>
<span class="line" id="L225">        <span class="tok-kw">return</span> isAbsolutePosix(path);</span>
<span class="line" id="L226">    }</span>
<span class="line" id="L227">}</span>
<span class="line" id="L228"></span>
<span class="line" id="L229"><span class="tok-kw">fn</span> <span class="tok-fn">isAbsoluteWindowsImpl</span>(<span class="tok-kw">comptime</span> T: <span class="tok-type">type</span>, path: []<span class="tok-kw">const</span> T) <span class="tok-type">bool</span> {</span>
<span class="line" id="L230">    <span class="tok-kw">if</span> (path.len &lt; <span class="tok-number">1</span>)</span>
<span class="line" id="L231">        <span class="tok-kw">return</span> <span class="tok-null">false</span>;</span>
<span class="line" id="L232"></span>
<span class="line" id="L233">    <span class="tok-kw">if</span> (path[<span class="tok-number">0</span>] == <span class="tok-str">'/'</span>)</span>
<span class="line" id="L234">        <span class="tok-kw">return</span> <span class="tok-null">true</span>;</span>
<span class="line" id="L235"></span>
<span class="line" id="L236">    <span class="tok-kw">if</span> (path[<span class="tok-number">0</span>] == <span class="tok-str">'\\'</span>)</span>
<span class="line" id="L237">        <span class="tok-kw">return</span> <span class="tok-null">true</span>;</span>
<span class="line" id="L238"></span>
<span class="line" id="L239">    <span class="tok-kw">if</span> (path.len &lt; <span class="tok-number">3</span>)</span>
<span class="line" id="L240">        <span class="tok-kw">return</span> <span class="tok-null">false</span>;</span>
<span class="line" id="L241"></span>
<span class="line" id="L242">    <span class="tok-kw">if</span> (path[<span class="tok-number">1</span>] == <span class="tok-str">':'</span>) {</span>
<span class="line" id="L243">        <span class="tok-kw">if</span> (path[<span class="tok-number">2</span>] == <span class="tok-str">'/'</span>)</span>
<span class="line" id="L244">            <span class="tok-kw">return</span> <span class="tok-null">true</span>;</span>
<span class="line" id="L245">        <span class="tok-kw">if</span> (path[<span class="tok-number">2</span>] == <span class="tok-str">'\\'</span>)</span>
<span class="line" id="L246">            <span class="tok-kw">return</span> <span class="tok-null">true</span>;</span>
<span class="line" id="L247">    }</span>
<span class="line" id="L248"></span>
<span class="line" id="L249">    <span class="tok-kw">return</span> <span class="tok-null">false</span>;</span>
<span class="line" id="L250">}</span>
<span class="line" id="L251"></span>
<span class="line" id="L252"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">isAbsoluteWindows</span>(path: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) <span class="tok-type">bool</span> {</span>
<span class="line" id="L253">    <span class="tok-kw">return</span> isAbsoluteWindowsImpl(<span class="tok-type">u8</span>, path);</span>
<span class="line" id="L254">}</span>
<span class="line" id="L255"></span>
<span class="line" id="L256"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">isAbsoluteWindowsW</span>(path_w: [*:<span class="tok-number">0</span>]<span class="tok-kw">const</span> <span class="tok-type">u16</span>) <span class="tok-type">bool</span> {</span>
<span class="line" id="L257">    <span class="tok-kw">return</span> isAbsoluteWindowsImpl(<span class="tok-type">u16</span>, mem.sliceTo(path_w, <span class="tok-number">0</span>));</span>
<span class="line" id="L258">}</span>
<span class="line" id="L259"></span>
<span class="line" id="L260"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">isAbsoluteWindowsWTF16</span>(path: []<span class="tok-kw">const</span> <span class="tok-type">u16</span>) <span class="tok-type">bool</span> {</span>
<span class="line" id="L261">    <span class="tok-kw">return</span> isAbsoluteWindowsImpl(<span class="tok-type">u16</span>, path);</span>
<span class="line" id="L262">}</span>
<span class="line" id="L263"></span>
<span class="line" id="L264"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">isAbsoluteWindowsZ</span>(path_c: [*:<span class="tok-number">0</span>]<span class="tok-kw">const</span> <span class="tok-type">u8</span>) <span class="tok-type">bool</span> {</span>
<span class="line" id="L265">    <span class="tok-kw">return</span> isAbsoluteWindowsImpl(<span class="tok-type">u8</span>, mem.sliceTo(path_c, <span class="tok-number">0</span>));</span>
<span class="line" id="L266">}</span>
<span class="line" id="L267"></span>
<span class="line" id="L268"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">isAbsolutePosix</span>(path: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) <span class="tok-type">bool</span> {</span>
<span class="line" id="L269">    <span class="tok-kw">return</span> path.len &gt; <span class="tok-number">0</span> <span class="tok-kw">and</span> path[<span class="tok-number">0</span>] == sep_posix;</span>
<span class="line" id="L270">}</span>
<span class="line" id="L271"></span>
<span class="line" id="L272"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">isAbsolutePosixZ</span>(path_c: [*:<span class="tok-number">0</span>]<span class="tok-kw">const</span> <span class="tok-type">u8</span>) <span class="tok-type">bool</span> {</span>
<span class="line" id="L273">    <span class="tok-kw">return</span> isAbsolutePosix(mem.sliceTo(path_c, <span class="tok-number">0</span>));</span>
<span class="line" id="L274">}</span>
<span class="line" id="L275"></span>
<span class="line" id="L276"><span class="tok-kw">test</span> <span class="tok-str">&quot;isAbsoluteWindows&quot;</span> {</span>
<span class="line" id="L277">    <span class="tok-kw">try</span> testIsAbsoluteWindows(<span class="tok-str">&quot;&quot;</span>, <span class="tok-null">false</span>);</span>
<span class="line" id="L278">    <span class="tok-kw">try</span> testIsAbsoluteWindows(<span class="tok-str">&quot;/&quot;</span>, <span class="tok-null">true</span>);</span>
<span class="line" id="L279">    <span class="tok-kw">try</span> testIsAbsoluteWindows(<span class="tok-str">&quot;//&quot;</span>, <span class="tok-null">true</span>);</span>
<span class="line" id="L280">    <span class="tok-kw">try</span> testIsAbsoluteWindows(<span class="tok-str">&quot;//server&quot;</span>, <span class="tok-null">true</span>);</span>
<span class="line" id="L281">    <span class="tok-kw">try</span> testIsAbsoluteWindows(<span class="tok-str">&quot;//server/file&quot;</span>, <span class="tok-null">true</span>);</span>
<span class="line" id="L282">    <span class="tok-kw">try</span> testIsAbsoluteWindows(<span class="tok-str">&quot;\\\\server\\file&quot;</span>, <span class="tok-null">true</span>);</span>
<span class="line" id="L283">    <span class="tok-kw">try</span> testIsAbsoluteWindows(<span class="tok-str">&quot;\\\\server&quot;</span>, <span class="tok-null">true</span>);</span>
<span class="line" id="L284">    <span class="tok-kw">try</span> testIsAbsoluteWindows(<span class="tok-str">&quot;\\\\&quot;</span>, <span class="tok-null">true</span>);</span>
<span class="line" id="L285">    <span class="tok-kw">try</span> testIsAbsoluteWindows(<span class="tok-str">&quot;c&quot;</span>, <span class="tok-null">false</span>);</span>
<span class="line" id="L286">    <span class="tok-kw">try</span> testIsAbsoluteWindows(<span class="tok-str">&quot;c:&quot;</span>, <span class="tok-null">false</span>);</span>
<span class="line" id="L287">    <span class="tok-kw">try</span> testIsAbsoluteWindows(<span class="tok-str">&quot;c:\\&quot;</span>, <span class="tok-null">true</span>);</span>
<span class="line" id="L288">    <span class="tok-kw">try</span> testIsAbsoluteWindows(<span class="tok-str">&quot;c:/&quot;</span>, <span class="tok-null">true</span>);</span>
<span class="line" id="L289">    <span class="tok-kw">try</span> testIsAbsoluteWindows(<span class="tok-str">&quot;c://&quot;</span>, <span class="tok-null">true</span>);</span>
<span class="line" id="L290">    <span class="tok-kw">try</span> testIsAbsoluteWindows(<span class="tok-str">&quot;C:/Users/&quot;</span>, <span class="tok-null">true</span>);</span>
<span class="line" id="L291">    <span class="tok-kw">try</span> testIsAbsoluteWindows(<span class="tok-str">&quot;C:\\Users\\&quot;</span>, <span class="tok-null">true</span>);</span>
<span class="line" id="L292">    <span class="tok-kw">try</span> testIsAbsoluteWindows(<span class="tok-str">&quot;C:cwd/another&quot;</span>, <span class="tok-null">false</span>);</span>
<span class="line" id="L293">    <span class="tok-kw">try</span> testIsAbsoluteWindows(<span class="tok-str">&quot;C:cwd\\another&quot;</span>, <span class="tok-null">false</span>);</span>
<span class="line" id="L294">    <span class="tok-kw">try</span> testIsAbsoluteWindows(<span class="tok-str">&quot;directory/directory&quot;</span>, <span class="tok-null">false</span>);</span>
<span class="line" id="L295">    <span class="tok-kw">try</span> testIsAbsoluteWindows(<span class="tok-str">&quot;directory\\directory&quot;</span>, <span class="tok-null">false</span>);</span>
<span class="line" id="L296">    <span class="tok-kw">try</span> testIsAbsoluteWindows(<span class="tok-str">&quot;/usr/local&quot;</span>, <span class="tok-null">true</span>);</span>
<span class="line" id="L297">}</span>
<span class="line" id="L298"></span>
<span class="line" id="L299"><span class="tok-kw">test</span> <span class="tok-str">&quot;isAbsolutePosix&quot;</span> {</span>
<span class="line" id="L300">    <span class="tok-kw">try</span> testIsAbsolutePosix(<span class="tok-str">&quot;&quot;</span>, <span class="tok-null">false</span>);</span>
<span class="line" id="L301">    <span class="tok-kw">try</span> testIsAbsolutePosix(<span class="tok-str">&quot;/home/foo&quot;</span>, <span class="tok-null">true</span>);</span>
<span class="line" id="L302">    <span class="tok-kw">try</span> testIsAbsolutePosix(<span class="tok-str">&quot;/home/foo/..&quot;</span>, <span class="tok-null">true</span>);</span>
<span class="line" id="L303">    <span class="tok-kw">try</span> testIsAbsolutePosix(<span class="tok-str">&quot;bar/&quot;</span>, <span class="tok-null">false</span>);</span>
<span class="line" id="L304">    <span class="tok-kw">try</span> testIsAbsolutePosix(<span class="tok-str">&quot;./baz&quot;</span>, <span class="tok-null">false</span>);</span>
<span class="line" id="L305">}</span>
<span class="line" id="L306"></span>
<span class="line" id="L307"><span class="tok-kw">fn</span> <span class="tok-fn">testIsAbsoluteWindows</span>(path: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>, expected_result: <span class="tok-type">bool</span>) !<span class="tok-type">void</span> {</span>
<span class="line" id="L308">    <span class="tok-kw">try</span> testing.expectEqual(expected_result, isAbsoluteWindows(path));</span>
<span class="line" id="L309">}</span>
<span class="line" id="L310"></span>
<span class="line" id="L311"><span class="tok-kw">fn</span> <span class="tok-fn">testIsAbsolutePosix</span>(path: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>, expected_result: <span class="tok-type">bool</span>) !<span class="tok-type">void</span> {</span>
<span class="line" id="L312">    <span class="tok-kw">try</span> testing.expectEqual(expected_result, isAbsolutePosix(path));</span>
<span class="line" id="L313">}</span>
<span class="line" id="L314"></span>
<span class="line" id="L315"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> WindowsPath = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L316">    is_abs: <span class="tok-type">bool</span>,</span>
<span class="line" id="L317">    kind: Kind,</span>
<span class="line" id="L318">    disk_designator: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>,</span>
<span class="line" id="L319"></span>
<span class="line" id="L320">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> Kind = <span class="tok-kw">enum</span> {</span>
<span class="line" id="L321">        None,</span>
<span class="line" id="L322">        Drive,</span>
<span class="line" id="L323">        NetworkShare,</span>
<span class="line" id="L324">    };</span>
<span class="line" id="L325">};</span>
<span class="line" id="L326"></span>
<span class="line" id="L327"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">windowsParsePath</span>(path: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) WindowsPath {</span>
<span class="line" id="L328">    <span class="tok-kw">if</span> (path.len &gt;= <span class="tok-number">2</span> <span class="tok-kw">and</span> path[<span class="tok-number">1</span>] == <span class="tok-str">':'</span>) {</span>
<span class="line" id="L329">        <span class="tok-kw">return</span> WindowsPath{</span>
<span class="line" id="L330">            .is_abs = isAbsoluteWindows(path),</span>
<span class="line" id="L331">            .kind = WindowsPath.Kind.Drive,</span>
<span class="line" id="L332">            .disk_designator = path[<span class="tok-number">0</span>..<span class="tok-number">2</span>],</span>
<span class="line" id="L333">        };</span>
<span class="line" id="L334">    }</span>
<span class="line" id="L335">    <span class="tok-kw">if</span> (path.len &gt;= <span class="tok-number">1</span> <span class="tok-kw">and</span> (path[<span class="tok-number">0</span>] == <span class="tok-str">'/'</span> <span class="tok-kw">or</span> path[<span class="tok-number">0</span>] == <span class="tok-str">'\\'</span>) <span class="tok-kw">and</span></span>
<span class="line" id="L336">        (path.len == <span class="tok-number">1</span> <span class="tok-kw">or</span> (path[<span class="tok-number">1</span>] != <span class="tok-str">'/'</span> <span class="tok-kw">and</span> path[<span class="tok-number">1</span>] != <span class="tok-str">'\\'</span>)))</span>
<span class="line" id="L337">    {</span>
<span class="line" id="L338">        <span class="tok-kw">return</span> WindowsPath{</span>
<span class="line" id="L339">            .is_abs = <span class="tok-null">true</span>,</span>
<span class="line" id="L340">            .kind = WindowsPath.Kind.None,</span>
<span class="line" id="L341">            .disk_designator = path[<span class="tok-number">0</span>..<span class="tok-number">0</span>],</span>
<span class="line" id="L342">        };</span>
<span class="line" id="L343">    }</span>
<span class="line" id="L344">    <span class="tok-kw">const</span> relative_path = WindowsPath{</span>
<span class="line" id="L345">        .kind = WindowsPath.Kind.None,</span>
<span class="line" id="L346">        .disk_designator = &amp;[_]<span class="tok-type">u8</span>{},</span>
<span class="line" id="L347">        .is_abs = <span class="tok-null">false</span>,</span>
<span class="line" id="L348">    };</span>
<span class="line" id="L349">    <span class="tok-kw">if</span> (path.len &lt; <span class="tok-str">&quot;//a/b&quot;</span>.len) {</span>
<span class="line" id="L350">        <span class="tok-kw">return</span> relative_path;</span>
<span class="line" id="L351">    }</span>
<span class="line" id="L352"></span>
<span class="line" id="L353">    <span class="tok-kw">inline</span> <span class="tok-kw">for</span> (<span class="tok-str">&quot;/\\&quot;</span>) |this_sep| {</span>
<span class="line" id="L354">        <span class="tok-kw">const</span> two_sep = [_]<span class="tok-type">u8</span>{ this_sep, this_sep };</span>
<span class="line" id="L355">        <span class="tok-kw">if</span> (mem.startsWith(<span class="tok-type">u8</span>, path, &amp;two_sep)) {</span>
<span class="line" id="L356">            <span class="tok-kw">if</span> (path[<span class="tok-number">2</span>] == this_sep) {</span>
<span class="line" id="L357">                <span class="tok-kw">return</span> relative_path;</span>
<span class="line" id="L358">            }</span>
<span class="line" id="L359"></span>
<span class="line" id="L360">            <span class="tok-kw">var</span> it = mem.tokenize(<span class="tok-type">u8</span>, path, &amp;[_]<span class="tok-type">u8</span>{this_sep});</span>
<span class="line" id="L361">            _ = (it.next() <span class="tok-kw">orelse</span> <span class="tok-kw">return</span> relative_path);</span>
<span class="line" id="L362">            _ = (it.next() <span class="tok-kw">orelse</span> <span class="tok-kw">return</span> relative_path);</span>
<span class="line" id="L363">            <span class="tok-kw">return</span> WindowsPath{</span>
<span class="line" id="L364">                .is_abs = isAbsoluteWindows(path),</span>
<span class="line" id="L365">                .kind = WindowsPath.Kind.NetworkShare,</span>
<span class="line" id="L366">                .disk_designator = path[<span class="tok-number">0</span>..it.index],</span>
<span class="line" id="L367">            };</span>
<span class="line" id="L368">        }</span>
<span class="line" id="L369">    }</span>
<span class="line" id="L370">    <span class="tok-kw">return</span> relative_path;</span>
<span class="line" id="L371">}</span>
<span class="line" id="L372"></span>
<span class="line" id="L373"><span class="tok-kw">test</span> <span class="tok-str">&quot;windowsParsePath&quot;</span> {</span>
<span class="line" id="L374">    {</span>
<span class="line" id="L375">        <span class="tok-kw">const</span> parsed = windowsParsePath(<span class="tok-str">&quot;//a/b&quot;</span>);</span>
<span class="line" id="L376">        <span class="tok-kw">try</span> testing.expect(parsed.is_abs);</span>
<span class="line" id="L377">        <span class="tok-kw">try</span> testing.expect(parsed.kind == WindowsPath.Kind.NetworkShare);</span>
<span class="line" id="L378">        <span class="tok-kw">try</span> testing.expect(mem.eql(<span class="tok-type">u8</span>, parsed.disk_designator, <span class="tok-str">&quot;//a/b&quot;</span>));</span>
<span class="line" id="L379">    }</span>
<span class="line" id="L380">    {</span>
<span class="line" id="L381">        <span class="tok-kw">const</span> parsed = windowsParsePath(<span class="tok-str">&quot;\\\\a\\b&quot;</span>);</span>
<span class="line" id="L382">        <span class="tok-kw">try</span> testing.expect(parsed.is_abs);</span>
<span class="line" id="L383">        <span class="tok-kw">try</span> testing.expect(parsed.kind == WindowsPath.Kind.NetworkShare);</span>
<span class="line" id="L384">        <span class="tok-kw">try</span> testing.expect(mem.eql(<span class="tok-type">u8</span>, parsed.disk_designator, <span class="tok-str">&quot;\\\\a\\b&quot;</span>));</span>
<span class="line" id="L385">    }</span>
<span class="line" id="L386">    {</span>
<span class="line" id="L387">        <span class="tok-kw">const</span> parsed = windowsParsePath(<span class="tok-str">&quot;\\\\a\\&quot;</span>);</span>
<span class="line" id="L388">        <span class="tok-kw">try</span> testing.expect(!parsed.is_abs);</span>
<span class="line" id="L389">        <span class="tok-kw">try</span> testing.expect(parsed.kind == WindowsPath.Kind.None);</span>
<span class="line" id="L390">        <span class="tok-kw">try</span> testing.expect(mem.eql(<span class="tok-type">u8</span>, parsed.disk_designator, <span class="tok-str">&quot;&quot;</span>));</span>
<span class="line" id="L391">    }</span>
<span class="line" id="L392">    {</span>
<span class="line" id="L393">        <span class="tok-kw">const</span> parsed = windowsParsePath(<span class="tok-str">&quot;/usr/local&quot;</span>);</span>
<span class="line" id="L394">        <span class="tok-kw">try</span> testing.expect(parsed.is_abs);</span>
<span class="line" id="L395">        <span class="tok-kw">try</span> testing.expect(parsed.kind == WindowsPath.Kind.None);</span>
<span class="line" id="L396">        <span class="tok-kw">try</span> testing.expect(mem.eql(<span class="tok-type">u8</span>, parsed.disk_designator, <span class="tok-str">&quot;&quot;</span>));</span>
<span class="line" id="L397">    }</span>
<span class="line" id="L398">    {</span>
<span class="line" id="L399">        <span class="tok-kw">const</span> parsed = windowsParsePath(<span class="tok-str">&quot;c:../&quot;</span>);</span>
<span class="line" id="L400">        <span class="tok-kw">try</span> testing.expect(!parsed.is_abs);</span>
<span class="line" id="L401">        <span class="tok-kw">try</span> testing.expect(parsed.kind == WindowsPath.Kind.Drive);</span>
<span class="line" id="L402">        <span class="tok-kw">try</span> testing.expect(mem.eql(<span class="tok-type">u8</span>, parsed.disk_designator, <span class="tok-str">&quot;c:&quot;</span>));</span>
<span class="line" id="L403">    }</span>
<span class="line" id="L404">}</span>
<span class="line" id="L405"></span>
<span class="line" id="L406"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">diskDesignator</span>(path: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) []<span class="tok-kw">const</span> <span class="tok-type">u8</span> {</span>
<span class="line" id="L407">    <span class="tok-kw">if</span> (native_os == .windows) {</span>
<span class="line" id="L408">        <span class="tok-kw">return</span> diskDesignatorWindows(path);</span>
<span class="line" id="L409">    } <span class="tok-kw">else</span> {</span>
<span class="line" id="L410">        <span class="tok-kw">return</span> <span class="tok-str">&quot;&quot;</span>;</span>
<span class="line" id="L411">    }</span>
<span class="line" id="L412">}</span>
<span class="line" id="L413"></span>
<span class="line" id="L414"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">diskDesignatorWindows</span>(path: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) []<span class="tok-kw">const</span> <span class="tok-type">u8</span> {</span>
<span class="line" id="L415">    <span class="tok-kw">return</span> windowsParsePath(path).disk_designator;</span>
<span class="line" id="L416">}</span>
<span class="line" id="L417"></span>
<span class="line" id="L418"><span class="tok-kw">fn</span> <span class="tok-fn">networkShareServersEql</span>(ns1: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>, ns2: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) <span class="tok-type">bool</span> {</span>
<span class="line" id="L419">    <span class="tok-kw">const</span> sep1 = ns1[<span class="tok-number">0</span>];</span>
<span class="line" id="L420">    <span class="tok-kw">const</span> sep2 = ns2[<span class="tok-number">0</span>];</span>
<span class="line" id="L421"></span>
<span class="line" id="L422">    <span class="tok-kw">var</span> it1 = mem.tokenize(<span class="tok-type">u8</span>, ns1, &amp;[_]<span class="tok-type">u8</span>{sep1});</span>
<span class="line" id="L423">    <span class="tok-kw">var</span> it2 = mem.tokenize(<span class="tok-type">u8</span>, ns2, &amp;[_]<span class="tok-type">u8</span>{sep2});</span>
<span class="line" id="L424"></span>
<span class="line" id="L425">    <span class="tok-comment">// TODO ASCII is wrong, we actually need full unicode support to compare paths.</span>
</span>
<span class="line" id="L426">    <span class="tok-kw">return</span> asciiEqlIgnoreCase(it1.next().?, it2.next().?);</span>
<span class="line" id="L427">}</span>
<span class="line" id="L428"></span>
<span class="line" id="L429"><span class="tok-kw">fn</span> <span class="tok-fn">compareDiskDesignators</span>(kind: WindowsPath.Kind, p1: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>, p2: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) <span class="tok-type">bool</span> {</span>
<span class="line" id="L430">    <span class="tok-kw">switch</span> (kind) {</span>
<span class="line" id="L431">        WindowsPath.Kind.None =&gt; {</span>
<span class="line" id="L432">            assert(p1.len == <span class="tok-number">0</span>);</span>
<span class="line" id="L433">            assert(p2.len == <span class="tok-number">0</span>);</span>
<span class="line" id="L434">            <span class="tok-kw">return</span> <span class="tok-null">true</span>;</span>
<span class="line" id="L435">        },</span>
<span class="line" id="L436">        WindowsPath.Kind.Drive =&gt; {</span>
<span class="line" id="L437">            <span class="tok-kw">return</span> asciiUpper(p1[<span class="tok-number">0</span>]) == asciiUpper(p2[<span class="tok-number">0</span>]);</span>
<span class="line" id="L438">        },</span>
<span class="line" id="L439">        WindowsPath.Kind.NetworkShare =&gt; {</span>
<span class="line" id="L440">            <span class="tok-kw">const</span> sep1 = p1[<span class="tok-number">0</span>];</span>
<span class="line" id="L441">            <span class="tok-kw">const</span> sep2 = p2[<span class="tok-number">0</span>];</span>
<span class="line" id="L442"></span>
<span class="line" id="L443">            <span class="tok-kw">var</span> it1 = mem.tokenize(<span class="tok-type">u8</span>, p1, &amp;[_]<span class="tok-type">u8</span>{sep1});</span>
<span class="line" id="L444">            <span class="tok-kw">var</span> it2 = mem.tokenize(<span class="tok-type">u8</span>, p2, &amp;[_]<span class="tok-type">u8</span>{sep2});</span>
<span class="line" id="L445"></span>
<span class="line" id="L446">            <span class="tok-comment">// TODO ASCII is wrong, we actually need full unicode support to compare paths.</span>
</span>
<span class="line" id="L447">            <span class="tok-kw">return</span> asciiEqlIgnoreCase(it1.next().?, it2.next().?) <span class="tok-kw">and</span> asciiEqlIgnoreCase(it1.next().?, it2.next().?);</span>
<span class="line" id="L448">        },</span>
<span class="line" id="L449">    }</span>
<span class="line" id="L450">}</span>
<span class="line" id="L451"></span>
<span class="line" id="L452"><span class="tok-kw">fn</span> <span class="tok-fn">asciiUpper</span>(byte: <span class="tok-type">u8</span>) <span class="tok-type">u8</span> {</span>
<span class="line" id="L453">    <span class="tok-kw">return</span> <span class="tok-kw">switch</span> (byte) {</span>
<span class="line" id="L454">        <span class="tok-str">'a'</span>...<span class="tok-str">'z'</span> =&gt; <span class="tok-str">'A'</span> + (byte - <span class="tok-str">'a'</span>),</span>
<span class="line" id="L455">        <span class="tok-kw">else</span> =&gt; byte,</span>
<span class="line" id="L456">    };</span>
<span class="line" id="L457">}</span>
<span class="line" id="L458"></span>
<span class="line" id="L459"><span class="tok-kw">fn</span> <span class="tok-fn">asciiEqlIgnoreCase</span>(s1: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>, s2: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) <span class="tok-type">bool</span> {</span>
<span class="line" id="L460">    <span class="tok-kw">if</span> (s1.len != s2.len)</span>
<span class="line" id="L461">        <span class="tok-kw">return</span> <span class="tok-null">false</span>;</span>
<span class="line" id="L462">    <span class="tok-kw">var</span> i: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L463">    <span class="tok-kw">while</span> (i &lt; s1.len) : (i += <span class="tok-number">1</span>) {</span>
<span class="line" id="L464">        <span class="tok-kw">if</span> (asciiUpper(s1[i]) != asciiUpper(s2[i]))</span>
<span class="line" id="L465">            <span class="tok-kw">return</span> <span class="tok-null">false</span>;</span>
<span class="line" id="L466">    }</span>
<span class="line" id="L467">    <span class="tok-kw">return</span> <span class="tok-null">true</span>;</span>
<span class="line" id="L468">}</span>
<span class="line" id="L469"></span>
<span class="line" id="L470"><span class="tok-comment">/// On Windows, this calls `resolveWindows` and on POSIX it calls `resolvePosix`.</span></span>
<span class="line" id="L471"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">resolve</span>(allocator: Allocator, paths: []<span class="tok-kw">const</span> []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) ![]<span class="tok-type">u8</span> {</span>
<span class="line" id="L472">    <span class="tok-kw">if</span> (native_os == .windows) {</span>
<span class="line" id="L473">        <span class="tok-kw">return</span> resolveWindows(allocator, paths);</span>
<span class="line" id="L474">    } <span class="tok-kw">else</span> {</span>
<span class="line" id="L475">        <span class="tok-kw">return</span> resolvePosix(allocator, paths);</span>
<span class="line" id="L476">    }</span>
<span class="line" id="L477">}</span>
<span class="line" id="L478"></span>
<span class="line" id="L479"><span class="tok-comment">/// This function is like a series of `cd` statements executed one after another.</span></span>
<span class="line" id="L480"><span class="tok-comment">/// It resolves &quot;.&quot; and &quot;..&quot;.</span></span>
<span class="line" id="L481"><span class="tok-comment">/// The result does not have a trailing path separator.</span></span>
<span class="line" id="L482"><span class="tok-comment">/// If all paths are relative it uses the current working directory as a starting point.</span></span>
<span class="line" id="L483"><span class="tok-comment">/// Each drive has its own current working directory.</span></span>
<span class="line" id="L484"><span class="tok-comment">/// Path separators are canonicalized to '\\' and drives are canonicalized to capital letters.</span></span>
<span class="line" id="L485"><span class="tok-comment">/// Note: all usage of this function should be audited due to the existence of symlinks.</span></span>
<span class="line" id="L486"><span class="tok-comment">/// Without performing actual syscalls, resolving `..` could be incorrect.</span></span>
<span class="line" id="L487"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">resolveWindows</span>(allocator: Allocator, paths: []<span class="tok-kw">const</span> []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) ![]<span class="tok-type">u8</span> {</span>
<span class="line" id="L488">    <span class="tok-kw">if</span> (paths.len == <span class="tok-number">0</span>) {</span>
<span class="line" id="L489">        assert(native_os == .windows); <span class="tok-comment">// resolveWindows called on non windows can't use getCwd</span>
</span>
<span class="line" id="L490">        <span class="tok-kw">return</span> process.getCwdAlloc(allocator);</span>
<span class="line" id="L491">    }</span>
<span class="line" id="L492"></span>
<span class="line" id="L493">    <span class="tok-comment">// determine which disk designator we will result with, if any</span>
</span>
<span class="line" id="L494">    <span class="tok-kw">var</span> result_drive_buf = <span class="tok-str">&quot;_:&quot;</span>.*;</span>
<span class="line" id="L495">    <span class="tok-kw">var</span> result_disk_designator: []<span class="tok-kw">const</span> <span class="tok-type">u8</span> = <span class="tok-str">&quot;&quot;</span>;</span>
<span class="line" id="L496">    <span class="tok-kw">var</span> have_drive_kind = WindowsPath.Kind.None;</span>
<span class="line" id="L497">    <span class="tok-kw">var</span> have_abs_path = <span class="tok-null">false</span>;</span>
<span class="line" id="L498">    <span class="tok-kw">var</span> first_index: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L499">    <span class="tok-kw">var</span> max_size: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L500">    <span class="tok-kw">for</span> (paths) |p, i| {</span>
<span class="line" id="L501">        <span class="tok-kw">const</span> parsed = windowsParsePath(p);</span>
<span class="line" id="L502">        <span class="tok-kw">if</span> (parsed.is_abs) {</span>
<span class="line" id="L503">            have_abs_path = <span class="tok-null">true</span>;</span>
<span class="line" id="L504">            first_index = i;</span>
<span class="line" id="L505">            max_size = result_disk_designator.len;</span>
<span class="line" id="L506">        }</span>
<span class="line" id="L507">        <span class="tok-kw">switch</span> (parsed.kind) {</span>
<span class="line" id="L508">            WindowsPath.Kind.Drive =&gt; {</span>
<span class="line" id="L509">                result_drive_buf[<span class="tok-number">0</span>] = asciiUpper(parsed.disk_designator[<span class="tok-number">0</span>]);</span>
<span class="line" id="L510">                result_disk_designator = result_drive_buf[<span class="tok-number">0</span>..];</span>
<span class="line" id="L511">                have_drive_kind = WindowsPath.Kind.Drive;</span>
<span class="line" id="L512">            },</span>
<span class="line" id="L513">            WindowsPath.Kind.NetworkShare =&gt; {</span>
<span class="line" id="L514">                result_disk_designator = parsed.disk_designator;</span>
<span class="line" id="L515">                have_drive_kind = WindowsPath.Kind.NetworkShare;</span>
<span class="line" id="L516">            },</span>
<span class="line" id="L517">            WindowsPath.Kind.None =&gt; {},</span>
<span class="line" id="L518">        }</span>
<span class="line" id="L519">        max_size += p.len + <span class="tok-number">1</span>;</span>
<span class="line" id="L520">    }</span>
<span class="line" id="L521"></span>
<span class="line" id="L522">    <span class="tok-comment">// if we will result with a disk designator, loop again to determine</span>
</span>
<span class="line" id="L523">    <span class="tok-comment">// which is the last time the disk designator is absolutely specified, if any</span>
</span>
<span class="line" id="L524">    <span class="tok-comment">// and count up the max bytes for paths related to this disk designator</span>
</span>
<span class="line" id="L525">    <span class="tok-kw">if</span> (have_drive_kind != WindowsPath.Kind.None) {</span>
<span class="line" id="L526">        have_abs_path = <span class="tok-null">false</span>;</span>
<span class="line" id="L527">        first_index = <span class="tok-number">0</span>;</span>
<span class="line" id="L528">        max_size = result_disk_designator.len;</span>
<span class="line" id="L529">        <span class="tok-kw">var</span> correct_disk_designator = <span class="tok-null">false</span>;</span>
<span class="line" id="L530"></span>
<span class="line" id="L531">        <span class="tok-kw">for</span> (paths) |p, i| {</span>
<span class="line" id="L532">            <span class="tok-kw">const</span> parsed = windowsParsePath(p);</span>
<span class="line" id="L533">            <span class="tok-kw">if</span> (parsed.kind != WindowsPath.Kind.None) {</span>
<span class="line" id="L534">                <span class="tok-kw">if</span> (parsed.kind == have_drive_kind) {</span>
<span class="line" id="L535">                    correct_disk_designator = compareDiskDesignators(have_drive_kind, result_disk_designator, parsed.disk_designator);</span>
<span class="line" id="L536">                } <span class="tok-kw">else</span> {</span>
<span class="line" id="L537">                    <span class="tok-kw">continue</span>;</span>
<span class="line" id="L538">                }</span>
<span class="line" id="L539">            }</span>
<span class="line" id="L540">            <span class="tok-kw">if</span> (!correct_disk_designator) {</span>
<span class="line" id="L541">                <span class="tok-kw">continue</span>;</span>
<span class="line" id="L542">            }</span>
<span class="line" id="L543">            <span class="tok-kw">if</span> (parsed.is_abs) {</span>
<span class="line" id="L544">                first_index = i;</span>
<span class="line" id="L545">                max_size = result_disk_designator.len;</span>
<span class="line" id="L546">                have_abs_path = <span class="tok-null">true</span>;</span>
<span class="line" id="L547">            }</span>
<span class="line" id="L548">            max_size += p.len + <span class="tok-number">1</span>;</span>
<span class="line" id="L549">        }</span>
<span class="line" id="L550">    }</span>
<span class="line" id="L551"></span>
<span class="line" id="L552">    <span class="tok-comment">// Allocate result and fill in the disk designator, calling getCwd if we have to.</span>
</span>
<span class="line" id="L553">    <span class="tok-kw">var</span> result: []<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L554">    <span class="tok-kw">var</span> result_index: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L555"></span>
<span class="line" id="L556">    <span class="tok-kw">if</span> (have_abs_path) {</span>
<span class="line" id="L557">        <span class="tok-kw">switch</span> (have_drive_kind) {</span>
<span class="line" id="L558">            WindowsPath.Kind.Drive =&gt; {</span>
<span class="line" id="L559">                result = <span class="tok-kw">try</span> allocator.alloc(<span class="tok-type">u8</span>, max_size);</span>
<span class="line" id="L560"></span>
<span class="line" id="L561">                mem.copy(<span class="tok-type">u8</span>, result, result_disk_designator);</span>
<span class="line" id="L562">                result_index += result_disk_designator.len;</span>
<span class="line" id="L563">            },</span>
<span class="line" id="L564">            WindowsPath.Kind.NetworkShare =&gt; {</span>
<span class="line" id="L565">                result = <span class="tok-kw">try</span> allocator.alloc(<span class="tok-type">u8</span>, max_size);</span>
<span class="line" id="L566">                <span class="tok-kw">var</span> it = mem.tokenize(<span class="tok-type">u8</span>, paths[first_index], <span class="tok-str">&quot;/\\&quot;</span>);</span>
<span class="line" id="L567">                <span class="tok-kw">const</span> server_name = it.next().?;</span>
<span class="line" id="L568">                <span class="tok-kw">const</span> other_name = it.next().?;</span>
<span class="line" id="L569"></span>
<span class="line" id="L570">                result[result_index] = <span class="tok-str">'\\'</span>;</span>
<span class="line" id="L571">                result_index += <span class="tok-number">1</span>;</span>
<span class="line" id="L572">                result[result_index] = <span class="tok-str">'\\'</span>;</span>
<span class="line" id="L573">                result_index += <span class="tok-number">1</span>;</span>
<span class="line" id="L574">                mem.copy(<span class="tok-type">u8</span>, result[result_index..], server_name);</span>
<span class="line" id="L575">                result_index += server_name.len;</span>
<span class="line" id="L576">                result[result_index] = <span class="tok-str">'\\'</span>;</span>
<span class="line" id="L577">                result_index += <span class="tok-number">1</span>;</span>
<span class="line" id="L578">                mem.copy(<span class="tok-type">u8</span>, result[result_index..], other_name);</span>
<span class="line" id="L579">                result_index += other_name.len;</span>
<span class="line" id="L580"></span>
<span class="line" id="L581">                result_disk_designator = result[<span class="tok-number">0</span>..result_index];</span>
<span class="line" id="L582">            },</span>
<span class="line" id="L583">            WindowsPath.Kind.None =&gt; {</span>
<span class="line" id="L584">                assert(native_os == .windows); <span class="tok-comment">// resolveWindows called on non windows can't use getCwd</span>
</span>
<span class="line" id="L585">                <span class="tok-kw">const</span> cwd = <span class="tok-kw">try</span> process.getCwdAlloc(allocator);</span>
<span class="line" id="L586">                <span class="tok-kw">defer</span> allocator.free(cwd);</span>
<span class="line" id="L587">                <span class="tok-kw">const</span> parsed_cwd = windowsParsePath(cwd);</span>
<span class="line" id="L588">                result = <span class="tok-kw">try</span> allocator.alloc(<span class="tok-type">u8</span>, max_size + parsed_cwd.disk_designator.len + <span class="tok-number">1</span>);</span>
<span class="line" id="L589">                mem.copy(<span class="tok-type">u8</span>, result, parsed_cwd.disk_designator);</span>
<span class="line" id="L590">                result_index += parsed_cwd.disk_designator.len;</span>
<span class="line" id="L591">                result_disk_designator = result[<span class="tok-number">0</span>..parsed_cwd.disk_designator.len];</span>
<span class="line" id="L592">                <span class="tok-kw">if</span> (parsed_cwd.kind == WindowsPath.Kind.Drive) {</span>
<span class="line" id="L593">                    result[<span class="tok-number">0</span>] = asciiUpper(result[<span class="tok-number">0</span>]);</span>
<span class="line" id="L594">                }</span>
<span class="line" id="L595">                have_drive_kind = parsed_cwd.kind;</span>
<span class="line" id="L596">            },</span>
<span class="line" id="L597">        }</span>
<span class="line" id="L598">    } <span class="tok-kw">else</span> {</span>
<span class="line" id="L599">        assert(native_os == .windows); <span class="tok-comment">// resolveWindows called on non windows can't use getCwd</span>
</span>
<span class="line" id="L600">        <span class="tok-comment">// TODO call get cwd for the result_disk_designator instead of the global one</span>
</span>
<span class="line" id="L601">        <span class="tok-kw">const</span> cwd = <span class="tok-kw">try</span> process.getCwdAlloc(allocator);</span>
<span class="line" id="L602">        <span class="tok-kw">defer</span> allocator.free(cwd);</span>
<span class="line" id="L603"></span>
<span class="line" id="L604">        result = <span class="tok-kw">try</span> allocator.alloc(<span class="tok-type">u8</span>, max_size + cwd.len + <span class="tok-number">1</span>);</span>
<span class="line" id="L605"></span>
<span class="line" id="L606">        mem.copy(<span class="tok-type">u8</span>, result, cwd);</span>
<span class="line" id="L607">        result_index += cwd.len;</span>
<span class="line" id="L608">        <span class="tok-kw">const</span> parsed_cwd = windowsParsePath(result[<span class="tok-number">0</span>..result_index]);</span>
<span class="line" id="L609">        result_disk_designator = parsed_cwd.disk_designator;</span>
<span class="line" id="L610">        <span class="tok-kw">if</span> (parsed_cwd.kind == WindowsPath.Kind.Drive) {</span>
<span class="line" id="L611">            result[<span class="tok-number">0</span>] = asciiUpper(result[<span class="tok-number">0</span>]);</span>
<span class="line" id="L612">            <span class="tok-comment">// Remove the trailing slash if present, eg. if the cwd is a root</span>
</span>
<span class="line" id="L613">            <span class="tok-comment">// directory.</span>
</span>
<span class="line" id="L614">            <span class="tok-kw">if</span> (cwd.len &gt; <span class="tok-number">0</span> <span class="tok-kw">and</span> cwd[cwd.len - <span class="tok-number">1</span>] == sep_windows) {</span>
<span class="line" id="L615">                result_index -= <span class="tok-number">1</span>;</span>
<span class="line" id="L616">            }</span>
<span class="line" id="L617">        }</span>
<span class="line" id="L618">        have_drive_kind = parsed_cwd.kind;</span>
<span class="line" id="L619">    }</span>
<span class="line" id="L620">    <span class="tok-kw">errdefer</span> allocator.free(result);</span>
<span class="line" id="L621"></span>
<span class="line" id="L622">    <span class="tok-comment">// Now we know the disk designator to use, if any, and what kind it is. And our result</span>
</span>
<span class="line" id="L623">    <span class="tok-comment">// is big enough to append all the paths to.</span>
</span>
<span class="line" id="L624">    <span class="tok-kw">var</span> correct_disk_designator = <span class="tok-null">true</span>;</span>
<span class="line" id="L625">    <span class="tok-kw">for</span> (paths[first_index..]) |p| {</span>
<span class="line" id="L626">        <span class="tok-kw">const</span> parsed = windowsParsePath(p);</span>
<span class="line" id="L627"></span>
<span class="line" id="L628">        <span class="tok-kw">if</span> (parsed.kind != WindowsPath.Kind.None) {</span>
<span class="line" id="L629">            <span class="tok-kw">if</span> (parsed.kind == have_drive_kind) {</span>
<span class="line" id="L630">                correct_disk_designator = compareDiskDesignators(have_drive_kind, result_disk_designator, parsed.disk_designator);</span>
<span class="line" id="L631">            } <span class="tok-kw">else</span> {</span>
<span class="line" id="L632">                <span class="tok-kw">continue</span>;</span>
<span class="line" id="L633">            }</span>
<span class="line" id="L634">        }</span>
<span class="line" id="L635">        <span class="tok-kw">if</span> (!correct_disk_designator) {</span>
<span class="line" id="L636">            <span class="tok-kw">continue</span>;</span>
<span class="line" id="L637">        }</span>
<span class="line" id="L638">        <span class="tok-kw">var</span> it = mem.tokenize(<span class="tok-type">u8</span>, p[parsed.disk_designator.len..], <span class="tok-str">&quot;/\\&quot;</span>);</span>
<span class="line" id="L639">        <span class="tok-kw">while</span> (it.next()) |component| {</span>
<span class="line" id="L640">            <span class="tok-kw">if</span> (mem.eql(<span class="tok-type">u8</span>, component, <span class="tok-str">&quot;.&quot;</span>)) {</span>
<span class="line" id="L641">                <span class="tok-kw">continue</span>;</span>
<span class="line" id="L642">            } <span class="tok-kw">else</span> <span class="tok-kw">if</span> (mem.eql(<span class="tok-type">u8</span>, component, <span class="tok-str">&quot;..&quot;</span>)) {</span>
<span class="line" id="L643">                <span class="tok-kw">while</span> (<span class="tok-null">true</span>) {</span>
<span class="line" id="L644">                    <span class="tok-kw">if</span> (result_index == <span class="tok-number">0</span> <span class="tok-kw">or</span> result_index == result_disk_designator.len)</span>
<span class="line" id="L645">                        <span class="tok-kw">break</span>;</span>
<span class="line" id="L646">                    result_index -= <span class="tok-number">1</span>;</span>
<span class="line" id="L647">                    <span class="tok-kw">if</span> (result[result_index] == <span class="tok-str">'\\'</span> <span class="tok-kw">or</span> result[result_index] == <span class="tok-str">'/'</span>)</span>
<span class="line" id="L648">                        <span class="tok-kw">break</span>;</span>
<span class="line" id="L649">                }</span>
<span class="line" id="L650">            } <span class="tok-kw">else</span> {</span>
<span class="line" id="L651">                result[result_index] = sep_windows;</span>
<span class="line" id="L652">                result_index += <span class="tok-number">1</span>;</span>
<span class="line" id="L653">                mem.copy(<span class="tok-type">u8</span>, result[result_index..], component);</span>
<span class="line" id="L654">                result_index += component.len;</span>
<span class="line" id="L655">            }</span>
<span class="line" id="L656">        }</span>
<span class="line" id="L657">    }</span>
<span class="line" id="L658"></span>
<span class="line" id="L659">    <span class="tok-kw">if</span> (result_index == result_disk_designator.len) {</span>
<span class="line" id="L660">        result[result_index] = <span class="tok-str">'\\'</span>;</span>
<span class="line" id="L661">        result_index += <span class="tok-number">1</span>;</span>
<span class="line" id="L662">    }</span>
<span class="line" id="L663"></span>
<span class="line" id="L664">    <span class="tok-kw">return</span> allocator.shrink(result, result_index);</span>
<span class="line" id="L665">}</span>
<span class="line" id="L666"></span>
<span class="line" id="L667"><span class="tok-comment">/// This function is like a series of `cd` statements executed one after another.</span></span>
<span class="line" id="L668"><span class="tok-comment">/// It resolves &quot;.&quot; and &quot;..&quot;.</span></span>
<span class="line" id="L669"><span class="tok-comment">/// The result does not have a trailing path separator.</span></span>
<span class="line" id="L670"><span class="tok-comment">/// If all paths are relative it uses the current working directory as a starting point.</span></span>
<span class="line" id="L671"><span class="tok-comment">/// Note: all usage of this function should be audited due to the existence of symlinks.</span></span>
<span class="line" id="L672"><span class="tok-comment">/// Without performing actual syscalls, resolving `..` could be incorrect.</span></span>
<span class="line" id="L673"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">resolvePosix</span>(allocator: Allocator, paths: []<span class="tok-kw">const</span> []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) ![]<span class="tok-type">u8</span> {</span>
<span class="line" id="L674">    <span class="tok-kw">if</span> (paths.len == <span class="tok-number">0</span>) {</span>
<span class="line" id="L675">        assert(native_os != .windows); <span class="tok-comment">// resolvePosix called on windows can't use getCwd</span>
</span>
<span class="line" id="L676">        <span class="tok-kw">return</span> process.getCwdAlloc(allocator);</span>
<span class="line" id="L677">    }</span>
<span class="line" id="L678"></span>
<span class="line" id="L679">    <span class="tok-kw">var</span> first_index: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L680">    <span class="tok-kw">var</span> have_abs = <span class="tok-null">false</span>;</span>
<span class="line" id="L681">    <span class="tok-kw">var</span> max_size: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L682">    <span class="tok-kw">for</span> (paths) |p, i| {</span>
<span class="line" id="L683">        <span class="tok-kw">if</span> (isAbsolutePosix(p)) {</span>
<span class="line" id="L684">            first_index = i;</span>
<span class="line" id="L685">            have_abs = <span class="tok-null">true</span>;</span>
<span class="line" id="L686">            max_size = <span class="tok-number">0</span>;</span>
<span class="line" id="L687">        }</span>
<span class="line" id="L688">        max_size += p.len + <span class="tok-number">1</span>;</span>
<span class="line" id="L689">    }</span>
<span class="line" id="L690"></span>
<span class="line" id="L691">    <span class="tok-kw">var</span> result: []<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L692">    <span class="tok-kw">var</span> result_index: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L693"></span>
<span class="line" id="L694">    <span class="tok-kw">if</span> (have_abs) {</span>
<span class="line" id="L695">        result = <span class="tok-kw">try</span> allocator.alloc(<span class="tok-type">u8</span>, max_size);</span>
<span class="line" id="L696">    } <span class="tok-kw">else</span> {</span>
<span class="line" id="L697">        assert(native_os != .windows); <span class="tok-comment">// resolvePosix called on windows can't use getCwd</span>
</span>
<span class="line" id="L698">        <span class="tok-kw">const</span> cwd = <span class="tok-kw">try</span> process.getCwdAlloc(allocator);</span>
<span class="line" id="L699">        <span class="tok-kw">defer</span> allocator.free(cwd);</span>
<span class="line" id="L700">        result = <span class="tok-kw">try</span> allocator.alloc(<span class="tok-type">u8</span>, max_size + cwd.len + <span class="tok-number">1</span>);</span>
<span class="line" id="L701">        mem.copy(<span class="tok-type">u8</span>, result, cwd);</span>
<span class="line" id="L702">        result_index += cwd.len;</span>
<span class="line" id="L703">    }</span>
<span class="line" id="L704">    <span class="tok-kw">errdefer</span> allocator.free(result);</span>
<span class="line" id="L705"></span>
<span class="line" id="L706">    <span class="tok-kw">for</span> (paths[first_index..]) |p| {</span>
<span class="line" id="L707">        <span class="tok-kw">var</span> it = mem.tokenize(<span class="tok-type">u8</span>, p, <span class="tok-str">&quot;/&quot;</span>);</span>
<span class="line" id="L708">        <span class="tok-kw">while</span> (it.next()) |component| {</span>
<span class="line" id="L709">            <span class="tok-kw">if</span> (mem.eql(<span class="tok-type">u8</span>, component, <span class="tok-str">&quot;.&quot;</span>)) {</span>
<span class="line" id="L710">                <span class="tok-kw">continue</span>;</span>
<span class="line" id="L711">            } <span class="tok-kw">else</span> <span class="tok-kw">if</span> (mem.eql(<span class="tok-type">u8</span>, component, <span class="tok-str">&quot;..&quot;</span>)) {</span>
<span class="line" id="L712">                <span class="tok-kw">while</span> (<span class="tok-null">true</span>) {</span>
<span class="line" id="L713">                    <span class="tok-kw">if</span> (result_index == <span class="tok-number">0</span>)</span>
<span class="line" id="L714">                        <span class="tok-kw">break</span>;</span>
<span class="line" id="L715">                    result_index -= <span class="tok-number">1</span>;</span>
<span class="line" id="L716">                    <span class="tok-kw">if</span> (result[result_index] == <span class="tok-str">'/'</span>)</span>
<span class="line" id="L717">                        <span class="tok-kw">break</span>;</span>
<span class="line" id="L718">                }</span>
<span class="line" id="L719">            } <span class="tok-kw">else</span> {</span>
<span class="line" id="L720">                result[result_index] = <span class="tok-str">'/'</span>;</span>
<span class="line" id="L721">                result_index += <span class="tok-number">1</span>;</span>
<span class="line" id="L722">                mem.copy(<span class="tok-type">u8</span>, result[result_index..], component);</span>
<span class="line" id="L723">                result_index += component.len;</span>
<span class="line" id="L724">            }</span>
<span class="line" id="L725">        }</span>
<span class="line" id="L726">    }</span>
<span class="line" id="L727"></span>
<span class="line" id="L728">    <span class="tok-kw">if</span> (result_index == <span class="tok-number">0</span>) {</span>
<span class="line" id="L729">        result[<span class="tok-number">0</span>] = <span class="tok-str">'/'</span>;</span>
<span class="line" id="L730">        result_index += <span class="tok-number">1</span>;</span>
<span class="line" id="L731">    }</span>
<span class="line" id="L732"></span>
<span class="line" id="L733">    <span class="tok-kw">return</span> allocator.shrink(result, result_index);</span>
<span class="line" id="L734">}</span>
<span class="line" id="L735"></span>
<span class="line" id="L736"><span class="tok-kw">test</span> <span class="tok-str">&quot;resolve&quot;</span> {</span>
<span class="line" id="L737">    <span class="tok-kw">if</span> (native_os == .wasi <span class="tok-kw">and</span> builtin.link_libc) <span class="tok-kw">return</span> <span class="tok-kw">error</span>.SkipZigTest;</span>
<span class="line" id="L738">    <span class="tok-kw">if</span> (native_os == .wasi <span class="tok-kw">and</span> !builtin.link_libc) <span class="tok-kw">try</span> os.initPreopensWasi(std.heap.page_allocator, <span class="tok-str">&quot;/&quot;</span>);</span>
<span class="line" id="L739"></span>
<span class="line" id="L740">    <span class="tok-kw">const</span> cwd = <span class="tok-kw">try</span> process.getCwdAlloc(testing.allocator);</span>
<span class="line" id="L741">    <span class="tok-kw">defer</span> testing.allocator.free(cwd);</span>
<span class="line" id="L742">    <span class="tok-kw">if</span> (native_os == .windows) {</span>
<span class="line" id="L743">        <span class="tok-kw">if</span> (windowsParsePath(cwd).kind == WindowsPath.Kind.Drive) {</span>
<span class="line" id="L744">            cwd[<span class="tok-number">0</span>] = asciiUpper(cwd[<span class="tok-number">0</span>]);</span>
<span class="line" id="L745">        }</span>
<span class="line" id="L746">        <span class="tok-kw">try</span> testResolveWindows(&amp;[_][]<span class="tok-kw">const</span> <span class="tok-type">u8</span>{<span class="tok-str">&quot;.&quot;</span>}, cwd);</span>
<span class="line" id="L747">    } <span class="tok-kw">else</span> {</span>
<span class="line" id="L748">        <span class="tok-kw">try</span> testResolvePosix(&amp;[_][]<span class="tok-kw">const</span> <span class="tok-type">u8</span>{ <span class="tok-str">&quot;a/b/c/&quot;</span>, <span class="tok-str">&quot;../../..&quot;</span> }, cwd);</span>
<span class="line" id="L749">        <span class="tok-kw">try</span> testResolvePosix(&amp;[_][]<span class="tok-kw">const</span> <span class="tok-type">u8</span>{<span class="tok-str">&quot;.&quot;</span>}, cwd);</span>
<span class="line" id="L750">    }</span>
<span class="line" id="L751">}</span>
<span class="line" id="L752"></span>
<span class="line" id="L753"><span class="tok-kw">test</span> <span class="tok-str">&quot;resolveWindows&quot;</span> {</span>
<span class="line" id="L754">    <span class="tok-kw">if</span> (builtin.target.cpu.arch == .aarch64) {</span>
<span class="line" id="L755">        <span class="tok-comment">// TODO https://github.com/ziglang/zig/issues/3288</span>
</span>
<span class="line" id="L756">        <span class="tok-kw">return</span> <span class="tok-kw">error</span>.SkipZigTest;</span>
<span class="line" id="L757">    }</span>
<span class="line" id="L758">    <span class="tok-kw">if</span> (native_os == .wasi <span class="tok-kw">and</span> builtin.link_libc) <span class="tok-kw">return</span> <span class="tok-kw">error</span>.SkipZigTest;</span>
<span class="line" id="L759">    <span class="tok-kw">if</span> (native_os == .wasi <span class="tok-kw">and</span> !builtin.link_libc) <span class="tok-kw">try</span> os.initPreopensWasi(std.heap.page_allocator, <span class="tok-str">&quot;/&quot;</span>);</span>
<span class="line" id="L760">    <span class="tok-kw">if</span> (native_os == .windows) {</span>
<span class="line" id="L761">        <span class="tok-kw">const</span> cwd = <span class="tok-kw">try</span> process.getCwdAlloc(testing.allocator);</span>
<span class="line" id="L762">        <span class="tok-kw">defer</span> testing.allocator.free(cwd);</span>
<span class="line" id="L763">        <span class="tok-kw">const</span> parsed_cwd = windowsParsePath(cwd);</span>
<span class="line" id="L764">        {</span>
<span class="line" id="L765">            <span class="tok-kw">const</span> expected = <span class="tok-kw">try</span> join(testing.allocator, &amp;[_][]<span class="tok-kw">const</span> <span class="tok-type">u8</span>{</span>
<span class="line" id="L766">                parsed_cwd.disk_designator,</span>
<span class="line" id="L767">                <span class="tok-str">&quot;usr\\local\\lib\\zig\\std\\array_list.zig&quot;</span>,</span>
<span class="line" id="L768">            });</span>
<span class="line" id="L769">            <span class="tok-kw">defer</span> testing.allocator.free(expected);</span>
<span class="line" id="L770">            <span class="tok-kw">if</span> (parsed_cwd.kind == WindowsPath.Kind.Drive) {</span>
<span class="line" id="L771">                expected[<span class="tok-number">0</span>] = asciiUpper(parsed_cwd.disk_designator[<span class="tok-number">0</span>]);</span>
<span class="line" id="L772">            }</span>
<span class="line" id="L773">            <span class="tok-kw">try</span> testResolveWindows(&amp;[_][]<span class="tok-kw">const</span> <span class="tok-type">u8</span>{ <span class="tok-str">&quot;/usr/local&quot;</span>, <span class="tok-str">&quot;lib\\zig\\std\\array_list.zig&quot;</span> }, expected);</span>
<span class="line" id="L774">        }</span>
<span class="line" id="L775">        {</span>
<span class="line" id="L776">            <span class="tok-kw">const</span> expected = <span class="tok-kw">try</span> join(testing.allocator, &amp;[_][]<span class="tok-kw">const</span> <span class="tok-type">u8</span>{</span>
<span class="line" id="L777">                cwd,</span>
<span class="line" id="L778">                <span class="tok-str">&quot;usr\\local\\lib\\zig&quot;</span>,</span>
<span class="line" id="L779">            });</span>
<span class="line" id="L780">            <span class="tok-kw">defer</span> testing.allocator.free(expected);</span>
<span class="line" id="L781">            <span class="tok-kw">if</span> (parsed_cwd.kind == WindowsPath.Kind.Drive) {</span>
<span class="line" id="L782">                expected[<span class="tok-number">0</span>] = asciiUpper(parsed_cwd.disk_designator[<span class="tok-number">0</span>]);</span>
<span class="line" id="L783">            }</span>
<span class="line" id="L784">            <span class="tok-kw">try</span> testResolveWindows(&amp;[_][]<span class="tok-kw">const</span> <span class="tok-type">u8</span>{ <span class="tok-str">&quot;usr/local&quot;</span>, <span class="tok-str">&quot;lib\\zig&quot;</span> }, expected);</span>
<span class="line" id="L785">        }</span>
<span class="line" id="L786">    }</span>
<span class="line" id="L787"></span>
<span class="line" id="L788">    <span class="tok-kw">try</span> testResolveWindows(&amp;[_][]<span class="tok-kw">const</span> <span class="tok-type">u8</span>{ <span class="tok-str">&quot;c:\\a\\b\\c&quot;</span>, <span class="tok-str">&quot;/hi&quot;</span>, <span class="tok-str">&quot;ok&quot;</span> }, <span class="tok-str">&quot;C:\\hi\\ok&quot;</span>);</span>
<span class="line" id="L789">    <span class="tok-kw">try</span> testResolveWindows(&amp;[_][]<span class="tok-kw">const</span> <span class="tok-type">u8</span>{ <span class="tok-str">&quot;c:/blah\\blah&quot;</span>, <span class="tok-str">&quot;d:/games&quot;</span>, <span class="tok-str">&quot;c:../a&quot;</span> }, <span class="tok-str">&quot;C:\\blah\\a&quot;</span>);</span>
<span class="line" id="L790">    <span class="tok-kw">try</span> testResolveWindows(&amp;[_][]<span class="tok-kw">const</span> <span class="tok-type">u8</span>{ <span class="tok-str">&quot;c:/blah\\blah&quot;</span>, <span class="tok-str">&quot;d:/games&quot;</span>, <span class="tok-str">&quot;C:../a&quot;</span> }, <span class="tok-str">&quot;C:\\blah\\a&quot;</span>);</span>
<span class="line" id="L791">    <span class="tok-kw">try</span> testResolveWindows(&amp;[_][]<span class="tok-kw">const</span> <span class="tok-type">u8</span>{ <span class="tok-str">&quot;c:/ignore&quot;</span>, <span class="tok-str">&quot;d:\\a/b\\c/d&quot;</span>, <span class="tok-str">&quot;\\e.exe&quot;</span> }, <span class="tok-str">&quot;D:\\e.exe&quot;</span>);</span>
<span class="line" id="L792">    <span class="tok-kw">try</span> testResolveWindows(&amp;[_][]<span class="tok-kw">const</span> <span class="tok-type">u8</span>{ <span class="tok-str">&quot;c:/ignore&quot;</span>, <span class="tok-str">&quot;c:/some/file&quot;</span> }, <span class="tok-str">&quot;C:\\some\\file&quot;</span>);</span>
<span class="line" id="L793">    <span class="tok-kw">try</span> testResolveWindows(&amp;[_][]<span class="tok-kw">const</span> <span class="tok-type">u8</span>{ <span class="tok-str">&quot;d:/ignore&quot;</span>, <span class="tok-str">&quot;d:some/dir//&quot;</span> }, <span class="tok-str">&quot;D:\\ignore\\some\\dir&quot;</span>);</span>
<span class="line" id="L794">    <span class="tok-kw">try</span> testResolveWindows(&amp;[_][]<span class="tok-kw">const</span> <span class="tok-type">u8</span>{ <span class="tok-str">&quot;//server/share&quot;</span>, <span class="tok-str">&quot;..&quot;</span>, <span class="tok-str">&quot;relative\\&quot;</span> }, <span class="tok-str">&quot;\\\\server\\share\\relative&quot;</span>);</span>
<span class="line" id="L795">    <span class="tok-kw">try</span> testResolveWindows(&amp;[_][]<span class="tok-kw">const</span> <span class="tok-type">u8</span>{ <span class="tok-str">&quot;c:/&quot;</span>, <span class="tok-str">&quot;//&quot;</span> }, <span class="tok-str">&quot;C:\\&quot;</span>);</span>
<span class="line" id="L796">    <span class="tok-kw">try</span> testResolveWindows(&amp;[_][]<span class="tok-kw">const</span> <span class="tok-type">u8</span>{ <span class="tok-str">&quot;c:/&quot;</span>, <span class="tok-str">&quot;//dir&quot;</span> }, <span class="tok-str">&quot;C:\\dir&quot;</span>);</span>
<span class="line" id="L797">    <span class="tok-kw">try</span> testResolveWindows(&amp;[_][]<span class="tok-kw">const</span> <span class="tok-type">u8</span>{ <span class="tok-str">&quot;c:/&quot;</span>, <span class="tok-str">&quot;//server/share&quot;</span> }, <span class="tok-str">&quot;\\\\server\\share\\&quot;</span>);</span>
<span class="line" id="L798">    <span class="tok-kw">try</span> testResolveWindows(&amp;[_][]<span class="tok-kw">const</span> <span class="tok-type">u8</span>{ <span class="tok-str">&quot;c:/&quot;</span>, <span class="tok-str">&quot;//server//share&quot;</span> }, <span class="tok-str">&quot;\\\\server\\share\\&quot;</span>);</span>
<span class="line" id="L799">    <span class="tok-kw">try</span> testResolveWindows(&amp;[_][]<span class="tok-kw">const</span> <span class="tok-type">u8</span>{ <span class="tok-str">&quot;c:/&quot;</span>, <span class="tok-str">&quot;///some//dir&quot;</span> }, <span class="tok-str">&quot;C:\\some\\dir&quot;</span>);</span>
<span class="line" id="L800">    <span class="tok-kw">try</span> testResolveWindows(&amp;[_][]<span class="tok-kw">const</span> <span class="tok-type">u8</span>{ <span class="tok-str">&quot;C:\\foo\\tmp.3\\&quot;</span>, <span class="tok-str">&quot;..\\tmp.3\\cycles\\root.js&quot;</span> }, <span class="tok-str">&quot;C:\\foo\\tmp.3\\cycles\\root.js&quot;</span>);</span>
<span class="line" id="L801">}</span>
<span class="line" id="L802"></span>
<span class="line" id="L803"><span class="tok-kw">test</span> <span class="tok-str">&quot;resolvePosix&quot;</span> {</span>
<span class="line" id="L804">    <span class="tok-kw">if</span> (native_os == .wasi <span class="tok-kw">and</span> builtin.link_libc) <span class="tok-kw">return</span> <span class="tok-kw">error</span>.SkipZigTest;</span>
<span class="line" id="L805">    <span class="tok-kw">if</span> (native_os == .wasi <span class="tok-kw">and</span> !builtin.link_libc) <span class="tok-kw">try</span> os.initPreopensWasi(std.heap.page_allocator, <span class="tok-str">&quot;/&quot;</span>);</span>
<span class="line" id="L806"></span>
<span class="line" id="L807">    <span class="tok-kw">try</span> testResolvePosix(&amp;[_][]<span class="tok-kw">const</span> <span class="tok-type">u8</span>{ <span class="tok-str">&quot;/a/b&quot;</span>, <span class="tok-str">&quot;c&quot;</span> }, <span class="tok-str">&quot;/a/b/c&quot;</span>);</span>
<span class="line" id="L808">    <span class="tok-kw">try</span> testResolvePosix(&amp;[_][]<span class="tok-kw">const</span> <span class="tok-type">u8</span>{ <span class="tok-str">&quot;/a/b&quot;</span>, <span class="tok-str">&quot;c&quot;</span>, <span class="tok-str">&quot;//d&quot;</span>, <span class="tok-str">&quot;e///&quot;</span> }, <span class="tok-str">&quot;/d/e&quot;</span>);</span>
<span class="line" id="L809">    <span class="tok-kw">try</span> testResolvePosix(&amp;[_][]<span class="tok-kw">const</span> <span class="tok-type">u8</span>{ <span class="tok-str">&quot;/a/b/c&quot;</span>, <span class="tok-str">&quot;..&quot;</span>, <span class="tok-str">&quot;../&quot;</span> }, <span class="tok-str">&quot;/a&quot;</span>);</span>
<span class="line" id="L810">    <span class="tok-kw">try</span> testResolvePosix(&amp;[_][]<span class="tok-kw">const</span> <span class="tok-type">u8</span>{ <span class="tok-str">&quot;/&quot;</span>, <span class="tok-str">&quot;..&quot;</span>, <span class="tok-str">&quot;..&quot;</span> }, <span class="tok-str">&quot;/&quot;</span>);</span>
<span class="line" id="L811">    <span class="tok-kw">try</span> testResolvePosix(&amp;[_][]<span class="tok-kw">const</span> <span class="tok-type">u8</span>{<span class="tok-str">&quot;/a/b/c/&quot;</span>}, <span class="tok-str">&quot;/a/b/c&quot;</span>);</span>
<span class="line" id="L812"></span>
<span class="line" id="L813">    <span class="tok-kw">try</span> testResolvePosix(&amp;[_][]<span class="tok-kw">const</span> <span class="tok-type">u8</span>{ <span class="tok-str">&quot;/var/lib&quot;</span>, <span class="tok-str">&quot;../&quot;</span>, <span class="tok-str">&quot;file/&quot;</span> }, <span class="tok-str">&quot;/var/file&quot;</span>);</span>
<span class="line" id="L814">    <span class="tok-kw">try</span> testResolvePosix(&amp;[_][]<span class="tok-kw">const</span> <span class="tok-type">u8</span>{ <span class="tok-str">&quot;/var/lib&quot;</span>, <span class="tok-str">&quot;/../&quot;</span>, <span class="tok-str">&quot;file/&quot;</span> }, <span class="tok-str">&quot;/file&quot;</span>);</span>
<span class="line" id="L815">    <span class="tok-kw">try</span> testResolvePosix(&amp;[_][]<span class="tok-kw">const</span> <span class="tok-type">u8</span>{ <span class="tok-str">&quot;/some/dir&quot;</span>, <span class="tok-str">&quot;.&quot;</span>, <span class="tok-str">&quot;/absolute/&quot;</span> }, <span class="tok-str">&quot;/absolute&quot;</span>);</span>
<span class="line" id="L816">    <span class="tok-kw">try</span> testResolvePosix(&amp;[_][]<span class="tok-kw">const</span> <span class="tok-type">u8</span>{ <span class="tok-str">&quot;/foo/tmp.3/&quot;</span>, <span class="tok-str">&quot;../tmp.3/cycles/root.js&quot;</span> }, <span class="tok-str">&quot;/foo/tmp.3/cycles/root.js&quot;</span>);</span>
<span class="line" id="L817">}</span>
<span class="line" id="L818"></span>
<span class="line" id="L819"><span class="tok-kw">fn</span> <span class="tok-fn">testResolveWindows</span>(paths: []<span class="tok-kw">const</span> []<span class="tok-kw">const</span> <span class="tok-type">u8</span>, expected: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) !<span class="tok-type">void</span> {</span>
<span class="line" id="L820">    <span class="tok-kw">const</span> actual = <span class="tok-kw">try</span> resolveWindows(testing.allocator, paths);</span>
<span class="line" id="L821">    <span class="tok-kw">defer</span> testing.allocator.free(actual);</span>
<span class="line" id="L822">    <span class="tok-kw">try</span> testing.expect(mem.eql(<span class="tok-type">u8</span>, actual, expected));</span>
<span class="line" id="L823">}</span>
<span class="line" id="L824"></span>
<span class="line" id="L825"><span class="tok-kw">fn</span> <span class="tok-fn">testResolvePosix</span>(paths: []<span class="tok-kw">const</span> []<span class="tok-kw">const</span> <span class="tok-type">u8</span>, expected: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) !<span class="tok-type">void</span> {</span>
<span class="line" id="L826">    <span class="tok-kw">const</span> actual = <span class="tok-kw">try</span> resolvePosix(testing.allocator, paths);</span>
<span class="line" id="L827">    <span class="tok-kw">defer</span> testing.allocator.free(actual);</span>
<span class="line" id="L828">    <span class="tok-kw">try</span> testing.expect(mem.eql(<span class="tok-type">u8</span>, actual, expected));</span>
<span class="line" id="L829">}</span>
<span class="line" id="L830"></span>
<span class="line" id="L831"><span class="tok-comment">/// Strip the last component from a file path.</span></span>
<span class="line" id="L832"><span class="tok-comment">///</span></span>
<span class="line" id="L833"><span class="tok-comment">/// If the path is a file in the current directory (no directory component)</span></span>
<span class="line" id="L834"><span class="tok-comment">/// then returns null.</span></span>
<span class="line" id="L835"><span class="tok-comment">///</span></span>
<span class="line" id="L836"><span class="tok-comment">/// If the path is the root directory, returns null.</span></span>
<span class="line" id="L837"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">dirname</span>(path: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) ?[]<span class="tok-kw">const</span> <span class="tok-type">u8</span> {</span>
<span class="line" id="L838">    <span class="tok-kw">if</span> (native_os == .windows) {</span>
<span class="line" id="L839">        <span class="tok-kw">return</span> dirnameWindows(path);</span>
<span class="line" id="L840">    } <span class="tok-kw">else</span> {</span>
<span class="line" id="L841">        <span class="tok-kw">return</span> dirnamePosix(path);</span>
<span class="line" id="L842">    }</span>
<span class="line" id="L843">}</span>
<span class="line" id="L844"></span>
<span class="line" id="L845"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">dirnameWindows</span>(path: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) ?[]<span class="tok-kw">const</span> <span class="tok-type">u8</span> {</span>
<span class="line" id="L846">    <span class="tok-kw">if</span> (path.len == <span class="tok-number">0</span>)</span>
<span class="line" id="L847">        <span class="tok-kw">return</span> <span class="tok-null">null</span>;</span>
<span class="line" id="L848"></span>
<span class="line" id="L849">    <span class="tok-kw">const</span> root_slice = diskDesignatorWindows(path);</span>
<span class="line" id="L850">    <span class="tok-kw">if</span> (path.len == root_slice.len)</span>
<span class="line" id="L851">        <span class="tok-kw">return</span> <span class="tok-null">null</span>;</span>
<span class="line" id="L852"></span>
<span class="line" id="L853">    <span class="tok-kw">const</span> have_root_slash = path.len &gt; root_slice.len <span class="tok-kw">and</span> (path[root_slice.len] == <span class="tok-str">'/'</span> <span class="tok-kw">or</span> path[root_slice.len] == <span class="tok-str">'\\'</span>);</span>
<span class="line" id="L854"></span>
<span class="line" id="L855">    <span class="tok-kw">var</span> end_index: <span class="tok-type">usize</span> = path.len - <span class="tok-number">1</span>;</span>
<span class="line" id="L856"></span>
<span class="line" id="L857">    <span class="tok-kw">while</span> (path[end_index] == <span class="tok-str">'/'</span> <span class="tok-kw">or</span> path[end_index] == <span class="tok-str">'\\'</span>) {</span>
<span class="line" id="L858">        <span class="tok-kw">if</span> (end_index == <span class="tok-number">0</span>)</span>
<span class="line" id="L859">            <span class="tok-kw">return</span> <span class="tok-null">null</span>;</span>
<span class="line" id="L860">        end_index -= <span class="tok-number">1</span>;</span>
<span class="line" id="L861">    }</span>
<span class="line" id="L862"></span>
<span class="line" id="L863">    <span class="tok-kw">while</span> (path[end_index] != <span class="tok-str">'/'</span> <span class="tok-kw">and</span> path[end_index] != <span class="tok-str">'\\'</span>) {</span>
<span class="line" id="L864">        <span class="tok-kw">if</span> (end_index == <span class="tok-number">0</span>)</span>
<span class="line" id="L865">            <span class="tok-kw">return</span> <span class="tok-null">null</span>;</span>
<span class="line" id="L866">        end_index -= <span class="tok-number">1</span>;</span>
<span class="line" id="L867">    }</span>
<span class="line" id="L868"></span>
<span class="line" id="L869">    <span class="tok-kw">if</span> (have_root_slash <span class="tok-kw">and</span> end_index == root_slice.len) {</span>
<span class="line" id="L870">        end_index += <span class="tok-number">1</span>;</span>
<span class="line" id="L871">    }</span>
<span class="line" id="L872"></span>
<span class="line" id="L873">    <span class="tok-kw">if</span> (end_index == <span class="tok-number">0</span>)</span>
<span class="line" id="L874">        <span class="tok-kw">return</span> <span class="tok-null">null</span>;</span>
<span class="line" id="L875"></span>
<span class="line" id="L876">    <span class="tok-kw">return</span> path[<span class="tok-number">0</span>..end_index];</span>
<span class="line" id="L877">}</span>
<span class="line" id="L878"></span>
<span class="line" id="L879"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">dirnamePosix</span>(path: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) ?[]<span class="tok-kw">const</span> <span class="tok-type">u8</span> {</span>
<span class="line" id="L880">    <span class="tok-kw">if</span> (path.len == <span class="tok-number">0</span>)</span>
<span class="line" id="L881">        <span class="tok-kw">return</span> <span class="tok-null">null</span>;</span>
<span class="line" id="L882"></span>
<span class="line" id="L883">    <span class="tok-kw">var</span> end_index: <span class="tok-type">usize</span> = path.len - <span class="tok-number">1</span>;</span>
<span class="line" id="L884">    <span class="tok-kw">while</span> (path[end_index] == <span class="tok-str">'/'</span>) {</span>
<span class="line" id="L885">        <span class="tok-kw">if</span> (end_index == <span class="tok-number">0</span>)</span>
<span class="line" id="L886">            <span class="tok-kw">return</span> <span class="tok-null">null</span>;</span>
<span class="line" id="L887">        end_index -= <span class="tok-number">1</span>;</span>
<span class="line" id="L888">    }</span>
<span class="line" id="L889"></span>
<span class="line" id="L890">    <span class="tok-kw">while</span> (path[end_index] != <span class="tok-str">'/'</span>) {</span>
<span class="line" id="L891">        <span class="tok-kw">if</span> (end_index == <span class="tok-number">0</span>)</span>
<span class="line" id="L892">            <span class="tok-kw">return</span> <span class="tok-null">null</span>;</span>
<span class="line" id="L893">        end_index -= <span class="tok-number">1</span>;</span>
<span class="line" id="L894">    }</span>
<span class="line" id="L895"></span>
<span class="line" id="L896">    <span class="tok-kw">if</span> (end_index == <span class="tok-number">0</span> <span class="tok-kw">and</span> path[<span class="tok-number">0</span>] == <span class="tok-str">'/'</span>)</span>
<span class="line" id="L897">        <span class="tok-kw">return</span> path[<span class="tok-number">0</span>..<span class="tok-number">1</span>];</span>
<span class="line" id="L898"></span>
<span class="line" id="L899">    <span class="tok-kw">if</span> (end_index == <span class="tok-number">0</span>)</span>
<span class="line" id="L900">        <span class="tok-kw">return</span> <span class="tok-null">null</span>;</span>
<span class="line" id="L901"></span>
<span class="line" id="L902">    <span class="tok-kw">return</span> path[<span class="tok-number">0</span>..end_index];</span>
<span class="line" id="L903">}</span>
<span class="line" id="L904"></span>
<span class="line" id="L905"><span class="tok-kw">test</span> <span class="tok-str">&quot;dirnamePosix&quot;</span> {</span>
<span class="line" id="L906">    <span class="tok-kw">try</span> testDirnamePosix(<span class="tok-str">&quot;/a/b/c&quot;</span>, <span class="tok-str">&quot;/a/b&quot;</span>);</span>
<span class="line" id="L907">    <span class="tok-kw">try</span> testDirnamePosix(<span class="tok-str">&quot;/a/b/c///&quot;</span>, <span class="tok-str">&quot;/a/b&quot;</span>);</span>
<span class="line" id="L908">    <span class="tok-kw">try</span> testDirnamePosix(<span class="tok-str">&quot;/a&quot;</span>, <span class="tok-str">&quot;/&quot;</span>);</span>
<span class="line" id="L909">    <span class="tok-kw">try</span> testDirnamePosix(<span class="tok-str">&quot;/&quot;</span>, <span class="tok-null">null</span>);</span>
<span class="line" id="L910">    <span class="tok-kw">try</span> testDirnamePosix(<span class="tok-str">&quot;//&quot;</span>, <span class="tok-null">null</span>);</span>
<span class="line" id="L911">    <span class="tok-kw">try</span> testDirnamePosix(<span class="tok-str">&quot;///&quot;</span>, <span class="tok-null">null</span>);</span>
<span class="line" id="L912">    <span class="tok-kw">try</span> testDirnamePosix(<span class="tok-str">&quot;////&quot;</span>, <span class="tok-null">null</span>);</span>
<span class="line" id="L913">    <span class="tok-kw">try</span> testDirnamePosix(<span class="tok-str">&quot;&quot;</span>, <span class="tok-null">null</span>);</span>
<span class="line" id="L914">    <span class="tok-kw">try</span> testDirnamePosix(<span class="tok-str">&quot;a&quot;</span>, <span class="tok-null">null</span>);</span>
<span class="line" id="L915">    <span class="tok-kw">try</span> testDirnamePosix(<span class="tok-str">&quot;a/&quot;</span>, <span class="tok-null">null</span>);</span>
<span class="line" id="L916">    <span class="tok-kw">try</span> testDirnamePosix(<span class="tok-str">&quot;a//&quot;</span>, <span class="tok-null">null</span>);</span>
<span class="line" id="L917">}</span>
<span class="line" id="L918"></span>
<span class="line" id="L919"><span class="tok-kw">test</span> <span class="tok-str">&quot;dirnameWindows&quot;</span> {</span>
<span class="line" id="L920">    <span class="tok-kw">try</span> testDirnameWindows(<span class="tok-str">&quot;c:\\&quot;</span>, <span class="tok-null">null</span>);</span>
<span class="line" id="L921">    <span class="tok-kw">try</span> testDirnameWindows(<span class="tok-str">&quot;c:\\foo&quot;</span>, <span class="tok-str">&quot;c:\\&quot;</span>);</span>
<span class="line" id="L922">    <span class="tok-kw">try</span> testDirnameWindows(<span class="tok-str">&quot;c:\\foo\\&quot;</span>, <span class="tok-str">&quot;c:\\&quot;</span>);</span>
<span class="line" id="L923">    <span class="tok-kw">try</span> testDirnameWindows(<span class="tok-str">&quot;c:\\foo\\bar&quot;</span>, <span class="tok-str">&quot;c:\\foo&quot;</span>);</span>
<span class="line" id="L924">    <span class="tok-kw">try</span> testDirnameWindows(<span class="tok-str">&quot;c:\\foo\\bar\\&quot;</span>, <span class="tok-str">&quot;c:\\foo&quot;</span>);</span>
<span class="line" id="L925">    <span class="tok-kw">try</span> testDirnameWindows(<span class="tok-str">&quot;c:\\foo\\bar\\baz&quot;</span>, <span class="tok-str">&quot;c:\\foo\\bar&quot;</span>);</span>
<span class="line" id="L926">    <span class="tok-kw">try</span> testDirnameWindows(<span class="tok-str">&quot;\\&quot;</span>, <span class="tok-null">null</span>);</span>
<span class="line" id="L927">    <span class="tok-kw">try</span> testDirnameWindows(<span class="tok-str">&quot;\\foo&quot;</span>, <span class="tok-str">&quot;\\&quot;</span>);</span>
<span class="line" id="L928">    <span class="tok-kw">try</span> testDirnameWindows(<span class="tok-str">&quot;\\foo\\&quot;</span>, <span class="tok-str">&quot;\\&quot;</span>);</span>
<span class="line" id="L929">    <span class="tok-kw">try</span> testDirnameWindows(<span class="tok-str">&quot;\\foo\\bar&quot;</span>, <span class="tok-str">&quot;\\foo&quot;</span>);</span>
<span class="line" id="L930">    <span class="tok-kw">try</span> testDirnameWindows(<span class="tok-str">&quot;\\foo\\bar\\&quot;</span>, <span class="tok-str">&quot;\\foo&quot;</span>);</span>
<span class="line" id="L931">    <span class="tok-kw">try</span> testDirnameWindows(<span class="tok-str">&quot;\\foo\\bar\\baz&quot;</span>, <span class="tok-str">&quot;\\foo\\bar&quot;</span>);</span>
<span class="line" id="L932">    <span class="tok-kw">try</span> testDirnameWindows(<span class="tok-str">&quot;c:&quot;</span>, <span class="tok-null">null</span>);</span>
<span class="line" id="L933">    <span class="tok-kw">try</span> testDirnameWindows(<span class="tok-str">&quot;c:foo&quot;</span>, <span class="tok-null">null</span>);</span>
<span class="line" id="L934">    <span class="tok-kw">try</span> testDirnameWindows(<span class="tok-str">&quot;c:foo\\&quot;</span>, <span class="tok-null">null</span>);</span>
<span class="line" id="L935">    <span class="tok-kw">try</span> testDirnameWindows(<span class="tok-str">&quot;c:foo\\bar&quot;</span>, <span class="tok-str">&quot;c:foo&quot;</span>);</span>
<span class="line" id="L936">    <span class="tok-kw">try</span> testDirnameWindows(<span class="tok-str">&quot;c:foo\\bar\\&quot;</span>, <span class="tok-str">&quot;c:foo&quot;</span>);</span>
<span class="line" id="L937">    <span class="tok-kw">try</span> testDirnameWindows(<span class="tok-str">&quot;c:foo\\bar\\baz&quot;</span>, <span class="tok-str">&quot;c:foo\\bar&quot;</span>);</span>
<span class="line" id="L938">    <span class="tok-kw">try</span> testDirnameWindows(<span class="tok-str">&quot;file:stream&quot;</span>, <span class="tok-null">null</span>);</span>
<span class="line" id="L939">    <span class="tok-kw">try</span> testDirnameWindows(<span class="tok-str">&quot;dir\\file:stream&quot;</span>, <span class="tok-str">&quot;dir&quot;</span>);</span>
<span class="line" id="L940">    <span class="tok-kw">try</span> testDirnameWindows(<span class="tok-str">&quot;\\\\unc\\share&quot;</span>, <span class="tok-null">null</span>);</span>
<span class="line" id="L941">    <span class="tok-kw">try</span> testDirnameWindows(<span class="tok-str">&quot;\\\\unc\\share\\foo&quot;</span>, <span class="tok-str">&quot;\\\\unc\\share\\&quot;</span>);</span>
<span class="line" id="L942">    <span class="tok-kw">try</span> testDirnameWindows(<span class="tok-str">&quot;\\\\unc\\share\\foo\\&quot;</span>, <span class="tok-str">&quot;\\\\unc\\share\\&quot;</span>);</span>
<span class="line" id="L943">    <span class="tok-kw">try</span> testDirnameWindows(<span class="tok-str">&quot;\\\\unc\\share\\foo\\bar&quot;</span>, <span class="tok-str">&quot;\\\\unc\\share\\foo&quot;</span>);</span>
<span class="line" id="L944">    <span class="tok-kw">try</span> testDirnameWindows(<span class="tok-str">&quot;\\\\unc\\share\\foo\\bar\\&quot;</span>, <span class="tok-str">&quot;\\\\unc\\share\\foo&quot;</span>);</span>
<span class="line" id="L945">    <span class="tok-kw">try</span> testDirnameWindows(<span class="tok-str">&quot;\\\\unc\\share\\foo\\bar\\baz&quot;</span>, <span class="tok-str">&quot;\\\\unc\\share\\foo\\bar&quot;</span>);</span>
<span class="line" id="L946">    <span class="tok-kw">try</span> testDirnameWindows(<span class="tok-str">&quot;/a/b/&quot;</span>, <span class="tok-str">&quot;/a&quot;</span>);</span>
<span class="line" id="L947">    <span class="tok-kw">try</span> testDirnameWindows(<span class="tok-str">&quot;/a/b&quot;</span>, <span class="tok-str">&quot;/a&quot;</span>);</span>
<span class="line" id="L948">    <span class="tok-kw">try</span> testDirnameWindows(<span class="tok-str">&quot;/a&quot;</span>, <span class="tok-str">&quot;/&quot;</span>);</span>
<span class="line" id="L949">    <span class="tok-kw">try</span> testDirnameWindows(<span class="tok-str">&quot;&quot;</span>, <span class="tok-null">null</span>);</span>
<span class="line" id="L950">    <span class="tok-kw">try</span> testDirnameWindows(<span class="tok-str">&quot;/&quot;</span>, <span class="tok-null">null</span>);</span>
<span class="line" id="L951">    <span class="tok-kw">try</span> testDirnameWindows(<span class="tok-str">&quot;////&quot;</span>, <span class="tok-null">null</span>);</span>
<span class="line" id="L952">    <span class="tok-kw">try</span> testDirnameWindows(<span class="tok-str">&quot;foo&quot;</span>, <span class="tok-null">null</span>);</span>
<span class="line" id="L953">}</span>
<span class="line" id="L954"></span>
<span class="line" id="L955"><span class="tok-kw">fn</span> <span class="tok-fn">testDirnamePosix</span>(input: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>, expected_output: ?[]<span class="tok-kw">const</span> <span class="tok-type">u8</span>) !<span class="tok-type">void</span> {</span>
<span class="line" id="L956">    <span class="tok-kw">if</span> (dirnamePosix(input)) |output| {</span>
<span class="line" id="L957">        <span class="tok-kw">try</span> testing.expect(mem.eql(<span class="tok-type">u8</span>, output, expected_output.?));</span>
<span class="line" id="L958">    } <span class="tok-kw">else</span> {</span>
<span class="line" id="L959">        <span class="tok-kw">try</span> testing.expect(expected_output == <span class="tok-null">null</span>);</span>
<span class="line" id="L960">    }</span>
<span class="line" id="L961">}</span>
<span class="line" id="L962"></span>
<span class="line" id="L963"><span class="tok-kw">fn</span> <span class="tok-fn">testDirnameWindows</span>(input: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>, expected_output: ?[]<span class="tok-kw">const</span> <span class="tok-type">u8</span>) !<span class="tok-type">void</span> {</span>
<span class="line" id="L964">    <span class="tok-kw">if</span> (dirnameWindows(input)) |output| {</span>
<span class="line" id="L965">        <span class="tok-kw">try</span> testing.expect(mem.eql(<span class="tok-type">u8</span>, output, expected_output.?));</span>
<span class="line" id="L966">    } <span class="tok-kw">else</span> {</span>
<span class="line" id="L967">        <span class="tok-kw">try</span> testing.expect(expected_output == <span class="tok-null">null</span>);</span>
<span class="line" id="L968">    }</span>
<span class="line" id="L969">}</span>
<span class="line" id="L970"></span>
<span class="line" id="L971"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">basename</span>(path: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) []<span class="tok-kw">const</span> <span class="tok-type">u8</span> {</span>
<span class="line" id="L972">    <span class="tok-kw">if</span> (native_os == .windows) {</span>
<span class="line" id="L973">        <span class="tok-kw">return</span> basenameWindows(path);</span>
<span class="line" id="L974">    } <span class="tok-kw">else</span> {</span>
<span class="line" id="L975">        <span class="tok-kw">return</span> basenamePosix(path);</span>
<span class="line" id="L976">    }</span>
<span class="line" id="L977">}</span>
<span class="line" id="L978"></span>
<span class="line" id="L979"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">basenamePosix</span>(path: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) []<span class="tok-kw">const</span> <span class="tok-type">u8</span> {</span>
<span class="line" id="L980">    <span class="tok-kw">if</span> (path.len == <span class="tok-number">0</span>)</span>
<span class="line" id="L981">        <span class="tok-kw">return</span> &amp;[_]<span class="tok-type">u8</span>{};</span>
<span class="line" id="L982"></span>
<span class="line" id="L983">    <span class="tok-kw">var</span> end_index: <span class="tok-type">usize</span> = path.len - <span class="tok-number">1</span>;</span>
<span class="line" id="L984">    <span class="tok-kw">while</span> (path[end_index] == <span class="tok-str">'/'</span>) {</span>
<span class="line" id="L985">        <span class="tok-kw">if</span> (end_index == <span class="tok-number">0</span>)</span>
<span class="line" id="L986">            <span class="tok-kw">return</span> &amp;[_]<span class="tok-type">u8</span>{};</span>
<span class="line" id="L987">        end_index -= <span class="tok-number">1</span>;</span>
<span class="line" id="L988">    }</span>
<span class="line" id="L989">    <span class="tok-kw">var</span> start_index: <span class="tok-type">usize</span> = end_index;</span>
<span class="line" id="L990">    end_index += <span class="tok-number">1</span>;</span>
<span class="line" id="L991">    <span class="tok-kw">while</span> (path[start_index] != <span class="tok-str">'/'</span>) {</span>
<span class="line" id="L992">        <span class="tok-kw">if</span> (start_index == <span class="tok-number">0</span>)</span>
<span class="line" id="L993">            <span class="tok-kw">return</span> path[<span class="tok-number">0</span>..end_index];</span>
<span class="line" id="L994">        start_index -= <span class="tok-number">1</span>;</span>
<span class="line" id="L995">    }</span>
<span class="line" id="L996"></span>
<span class="line" id="L997">    <span class="tok-kw">return</span> path[start_index + <span class="tok-number">1</span> .. end_index];</span>
<span class="line" id="L998">}</span>
<span class="line" id="L999"></span>
<span class="line" id="L1000"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">basenameWindows</span>(path: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) []<span class="tok-kw">const</span> <span class="tok-type">u8</span> {</span>
<span class="line" id="L1001">    <span class="tok-kw">if</span> (path.len == <span class="tok-number">0</span>)</span>
<span class="line" id="L1002">        <span class="tok-kw">return</span> &amp;[_]<span class="tok-type">u8</span>{};</span>
<span class="line" id="L1003"></span>
<span class="line" id="L1004">    <span class="tok-kw">var</span> end_index: <span class="tok-type">usize</span> = path.len - <span class="tok-number">1</span>;</span>
<span class="line" id="L1005">    <span class="tok-kw">while</span> (<span class="tok-null">true</span>) {</span>
<span class="line" id="L1006">        <span class="tok-kw">const</span> byte = path[end_index];</span>
<span class="line" id="L1007">        <span class="tok-kw">if</span> (byte == <span class="tok-str">'/'</span> <span class="tok-kw">or</span> byte == <span class="tok-str">'\\'</span>) {</span>
<span class="line" id="L1008">            <span class="tok-kw">if</span> (end_index == <span class="tok-number">0</span>)</span>
<span class="line" id="L1009">                <span class="tok-kw">return</span> &amp;[_]<span class="tok-type">u8</span>{};</span>
<span class="line" id="L1010">            end_index -= <span class="tok-number">1</span>;</span>
<span class="line" id="L1011">            <span class="tok-kw">continue</span>;</span>
<span class="line" id="L1012">        }</span>
<span class="line" id="L1013">        <span class="tok-kw">if</span> (byte == <span class="tok-str">':'</span> <span class="tok-kw">and</span> end_index == <span class="tok-number">1</span>) {</span>
<span class="line" id="L1014">            <span class="tok-kw">return</span> &amp;[_]<span class="tok-type">u8</span>{};</span>
<span class="line" id="L1015">        }</span>
<span class="line" id="L1016">        <span class="tok-kw">break</span>;</span>
<span class="line" id="L1017">    }</span>
<span class="line" id="L1018"></span>
<span class="line" id="L1019">    <span class="tok-kw">var</span> start_index: <span class="tok-type">usize</span> = end_index;</span>
<span class="line" id="L1020">    end_index += <span class="tok-number">1</span>;</span>
<span class="line" id="L1021">    <span class="tok-kw">while</span> (path[start_index] != <span class="tok-str">'/'</span> <span class="tok-kw">and</span> path[start_index] != <span class="tok-str">'\\'</span> <span class="tok-kw">and</span></span>
<span class="line" id="L1022">        !(path[start_index] == <span class="tok-str">':'</span> <span class="tok-kw">and</span> start_index == <span class="tok-number">1</span>))</span>
<span class="line" id="L1023">    {</span>
<span class="line" id="L1024">        <span class="tok-kw">if</span> (start_index == <span class="tok-number">0</span>)</span>
<span class="line" id="L1025">            <span class="tok-kw">return</span> path[<span class="tok-number">0</span>..end_index];</span>
<span class="line" id="L1026">        start_index -= <span class="tok-number">1</span>;</span>
<span class="line" id="L1027">    }</span>
<span class="line" id="L1028"></span>
<span class="line" id="L1029">    <span class="tok-kw">return</span> path[start_index + <span class="tok-number">1</span> .. end_index];</span>
<span class="line" id="L1030">}</span>
<span class="line" id="L1031"></span>
<span class="line" id="L1032"><span class="tok-kw">test</span> <span class="tok-str">&quot;basename&quot;</span> {</span>
<span class="line" id="L1033">    <span class="tok-kw">try</span> testBasename(<span class="tok-str">&quot;&quot;</span>, <span class="tok-str">&quot;&quot;</span>);</span>
<span class="line" id="L1034">    <span class="tok-kw">try</span> testBasename(<span class="tok-str">&quot;/&quot;</span>, <span class="tok-str">&quot;&quot;</span>);</span>
<span class="line" id="L1035">    <span class="tok-kw">try</span> testBasename(<span class="tok-str">&quot;/dir/basename.ext&quot;</span>, <span class="tok-str">&quot;basename.ext&quot;</span>);</span>
<span class="line" id="L1036">    <span class="tok-kw">try</span> testBasename(<span class="tok-str">&quot;/basename.ext&quot;</span>, <span class="tok-str">&quot;basename.ext&quot;</span>);</span>
<span class="line" id="L1037">    <span class="tok-kw">try</span> testBasename(<span class="tok-str">&quot;basename.ext&quot;</span>, <span class="tok-str">&quot;basename.ext&quot;</span>);</span>
<span class="line" id="L1038">    <span class="tok-kw">try</span> testBasename(<span class="tok-str">&quot;basename.ext/&quot;</span>, <span class="tok-str">&quot;basename.ext&quot;</span>);</span>
<span class="line" id="L1039">    <span class="tok-kw">try</span> testBasename(<span class="tok-str">&quot;basename.ext//&quot;</span>, <span class="tok-str">&quot;basename.ext&quot;</span>);</span>
<span class="line" id="L1040">    <span class="tok-kw">try</span> testBasename(<span class="tok-str">&quot;/aaa/bbb&quot;</span>, <span class="tok-str">&quot;bbb&quot;</span>);</span>
<span class="line" id="L1041">    <span class="tok-kw">try</span> testBasename(<span class="tok-str">&quot;/aaa/&quot;</span>, <span class="tok-str">&quot;aaa&quot;</span>);</span>
<span class="line" id="L1042">    <span class="tok-kw">try</span> testBasename(<span class="tok-str">&quot;/aaa/b&quot;</span>, <span class="tok-str">&quot;b&quot;</span>);</span>
<span class="line" id="L1043">    <span class="tok-kw">try</span> testBasename(<span class="tok-str">&quot;/a/b&quot;</span>, <span class="tok-str">&quot;b&quot;</span>);</span>
<span class="line" id="L1044">    <span class="tok-kw">try</span> testBasename(<span class="tok-str">&quot;//a&quot;</span>, <span class="tok-str">&quot;a&quot;</span>);</span>
<span class="line" id="L1045"></span>
<span class="line" id="L1046">    <span class="tok-kw">try</span> testBasenamePosix(<span class="tok-str">&quot;\\dir\\basename.ext&quot;</span>, <span class="tok-str">&quot;\\dir\\basename.ext&quot;</span>);</span>
<span class="line" id="L1047">    <span class="tok-kw">try</span> testBasenamePosix(<span class="tok-str">&quot;\\basename.ext&quot;</span>, <span class="tok-str">&quot;\\basename.ext&quot;</span>);</span>
<span class="line" id="L1048">    <span class="tok-kw">try</span> testBasenamePosix(<span class="tok-str">&quot;basename.ext&quot;</span>, <span class="tok-str">&quot;basename.ext&quot;</span>);</span>
<span class="line" id="L1049">    <span class="tok-kw">try</span> testBasenamePosix(<span class="tok-str">&quot;basename.ext\\&quot;</span>, <span class="tok-str">&quot;basename.ext\\&quot;</span>);</span>
<span class="line" id="L1050">    <span class="tok-kw">try</span> testBasenamePosix(<span class="tok-str">&quot;basename.ext\\\\&quot;</span>, <span class="tok-str">&quot;basename.ext\\\\&quot;</span>);</span>
<span class="line" id="L1051">    <span class="tok-kw">try</span> testBasenamePosix(<span class="tok-str">&quot;foo&quot;</span>, <span class="tok-str">&quot;foo&quot;</span>);</span>
<span class="line" id="L1052"></span>
<span class="line" id="L1053">    <span class="tok-kw">try</span> testBasenameWindows(<span class="tok-str">&quot;\\dir\\basename.ext&quot;</span>, <span class="tok-str">&quot;basename.ext&quot;</span>);</span>
<span class="line" id="L1054">    <span class="tok-kw">try</span> testBasenameWindows(<span class="tok-str">&quot;\\basename.ext&quot;</span>, <span class="tok-str">&quot;basename.ext&quot;</span>);</span>
<span class="line" id="L1055">    <span class="tok-kw">try</span> testBasenameWindows(<span class="tok-str">&quot;basename.ext&quot;</span>, <span class="tok-str">&quot;basename.ext&quot;</span>);</span>
<span class="line" id="L1056">    <span class="tok-kw">try</span> testBasenameWindows(<span class="tok-str">&quot;basename.ext\\&quot;</span>, <span class="tok-str">&quot;basename.ext&quot;</span>);</span>
<span class="line" id="L1057">    <span class="tok-kw">try</span> testBasenameWindows(<span class="tok-str">&quot;basename.ext\\\\&quot;</span>, <span class="tok-str">&quot;basename.ext&quot;</span>);</span>
<span class="line" id="L1058">    <span class="tok-kw">try</span> testBasenameWindows(<span class="tok-str">&quot;foo&quot;</span>, <span class="tok-str">&quot;foo&quot;</span>);</span>
<span class="line" id="L1059">    <span class="tok-kw">try</span> testBasenameWindows(<span class="tok-str">&quot;C:&quot;</span>, <span class="tok-str">&quot;&quot;</span>);</span>
<span class="line" id="L1060">    <span class="tok-kw">try</span> testBasenameWindows(<span class="tok-str">&quot;C:.&quot;</span>, <span class="tok-str">&quot;.&quot;</span>);</span>
<span class="line" id="L1061">    <span class="tok-kw">try</span> testBasenameWindows(<span class="tok-str">&quot;C:\\&quot;</span>, <span class="tok-str">&quot;&quot;</span>);</span>
<span class="line" id="L1062">    <span class="tok-kw">try</span> testBasenameWindows(<span class="tok-str">&quot;C:\\dir\\base.ext&quot;</span>, <span class="tok-str">&quot;base.ext&quot;</span>);</span>
<span class="line" id="L1063">    <span class="tok-kw">try</span> testBasenameWindows(<span class="tok-str">&quot;C:\\basename.ext&quot;</span>, <span class="tok-str">&quot;basename.ext&quot;</span>);</span>
<span class="line" id="L1064">    <span class="tok-kw">try</span> testBasenameWindows(<span class="tok-str">&quot;C:basename.ext&quot;</span>, <span class="tok-str">&quot;basename.ext&quot;</span>);</span>
<span class="line" id="L1065">    <span class="tok-kw">try</span> testBasenameWindows(<span class="tok-str">&quot;C:basename.ext\\&quot;</span>, <span class="tok-str">&quot;basename.ext&quot;</span>);</span>
<span class="line" id="L1066">    <span class="tok-kw">try</span> testBasenameWindows(<span class="tok-str">&quot;C:basename.ext\\\\&quot;</span>, <span class="tok-str">&quot;basename.ext&quot;</span>);</span>
<span class="line" id="L1067">    <span class="tok-kw">try</span> testBasenameWindows(<span class="tok-str">&quot;C:foo&quot;</span>, <span class="tok-str">&quot;foo&quot;</span>);</span>
<span class="line" id="L1068">    <span class="tok-kw">try</span> testBasenameWindows(<span class="tok-str">&quot;file:stream&quot;</span>, <span class="tok-str">&quot;file:stream&quot;</span>);</span>
<span class="line" id="L1069">}</span>
<span class="line" id="L1070"></span>
<span class="line" id="L1071"><span class="tok-kw">fn</span> <span class="tok-fn">testBasename</span>(input: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>, expected_output: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) !<span class="tok-type">void</span> {</span>
<span class="line" id="L1072">    <span class="tok-kw">try</span> testing.expectEqualSlices(<span class="tok-type">u8</span>, expected_output, basename(input));</span>
<span class="line" id="L1073">}</span>
<span class="line" id="L1074"></span>
<span class="line" id="L1075"><span class="tok-kw">fn</span> <span class="tok-fn">testBasenamePosix</span>(input: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>, expected_output: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) !<span class="tok-type">void</span> {</span>
<span class="line" id="L1076">    <span class="tok-kw">try</span> testing.expectEqualSlices(<span class="tok-type">u8</span>, expected_output, basenamePosix(input));</span>
<span class="line" id="L1077">}</span>
<span class="line" id="L1078"></span>
<span class="line" id="L1079"><span class="tok-kw">fn</span> <span class="tok-fn">testBasenameWindows</span>(input: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>, expected_output: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) !<span class="tok-type">void</span> {</span>
<span class="line" id="L1080">    <span class="tok-kw">try</span> testing.expectEqualSlices(<span class="tok-type">u8</span>, expected_output, basenameWindows(input));</span>
<span class="line" id="L1081">}</span>
<span class="line" id="L1082"></span>
<span class="line" id="L1083"><span class="tok-comment">/// Returns the relative path from `from` to `to`. If `from` and `to` each</span></span>
<span class="line" id="L1084"><span class="tok-comment">/// resolve to the same path (after calling `resolve` on each), a zero-length</span></span>
<span class="line" id="L1085"><span class="tok-comment">/// string is returned.</span></span>
<span class="line" id="L1086"><span class="tok-comment">/// On Windows this canonicalizes the drive to a capital letter and paths to `\\`.</span></span>
<span class="line" id="L1087"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">relative</span>(allocator: Allocator, from: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>, to: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) ![]<span class="tok-type">u8</span> {</span>
<span class="line" id="L1088">    <span class="tok-kw">if</span> (native_os == .windows) {</span>
<span class="line" id="L1089">        <span class="tok-kw">return</span> relativeWindows(allocator, from, to);</span>
<span class="line" id="L1090">    } <span class="tok-kw">else</span> {</span>
<span class="line" id="L1091">        <span class="tok-kw">return</span> relativePosix(allocator, from, to);</span>
<span class="line" id="L1092">    }</span>
<span class="line" id="L1093">}</span>
<span class="line" id="L1094"></span>
<span class="line" id="L1095"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">relativeWindows</span>(allocator: Allocator, from: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>, to: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) ![]<span class="tok-type">u8</span> {</span>
<span class="line" id="L1096">    <span class="tok-kw">const</span> resolved_from = <span class="tok-kw">try</span> resolveWindows(allocator, &amp;[_][]<span class="tok-kw">const</span> <span class="tok-type">u8</span>{from});</span>
<span class="line" id="L1097">    <span class="tok-kw">defer</span> allocator.free(resolved_from);</span>
<span class="line" id="L1098"></span>
<span class="line" id="L1099">    <span class="tok-kw">var</span> clean_up_resolved_to = <span class="tok-null">true</span>;</span>
<span class="line" id="L1100">    <span class="tok-kw">const</span> resolved_to = <span class="tok-kw">try</span> resolveWindows(allocator, &amp;[_][]<span class="tok-kw">const</span> <span class="tok-type">u8</span>{to});</span>
<span class="line" id="L1101">    <span class="tok-kw">defer</span> <span class="tok-kw">if</span> (clean_up_resolved_to) allocator.free(resolved_to);</span>
<span class="line" id="L1102"></span>
<span class="line" id="L1103">    <span class="tok-kw">const</span> parsed_from = windowsParsePath(resolved_from);</span>
<span class="line" id="L1104">    <span class="tok-kw">const</span> parsed_to = windowsParsePath(resolved_to);</span>
<span class="line" id="L1105">    <span class="tok-kw">const</span> result_is_to = x: {</span>
<span class="line" id="L1106">        <span class="tok-kw">if</span> (parsed_from.kind != parsed_to.kind) {</span>
<span class="line" id="L1107">            <span class="tok-kw">break</span> :x <span class="tok-null">true</span>;</span>
<span class="line" id="L1108">        } <span class="tok-kw">else</span> <span class="tok-kw">switch</span> (parsed_from.kind) {</span>
<span class="line" id="L1109">            WindowsPath.Kind.NetworkShare =&gt; {</span>
<span class="line" id="L1110">                <span class="tok-kw">break</span> :x !networkShareServersEql(parsed_to.disk_designator, parsed_from.disk_designator);</span>
<span class="line" id="L1111">            },</span>
<span class="line" id="L1112">            WindowsPath.Kind.Drive =&gt; {</span>
<span class="line" id="L1113">                <span class="tok-kw">break</span> :x asciiUpper(parsed_from.disk_designator[<span class="tok-number">0</span>]) != asciiUpper(parsed_to.disk_designator[<span class="tok-number">0</span>]);</span>
<span class="line" id="L1114">            },</span>
<span class="line" id="L1115">            <span class="tok-kw">else</span> =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L1116">        }</span>
<span class="line" id="L1117">    };</span>
<span class="line" id="L1118"></span>
<span class="line" id="L1119">    <span class="tok-kw">if</span> (result_is_to) {</span>
<span class="line" id="L1120">        clean_up_resolved_to = <span class="tok-null">false</span>;</span>
<span class="line" id="L1121">        <span class="tok-kw">return</span> resolved_to;</span>
<span class="line" id="L1122">    }</span>
<span class="line" id="L1123"></span>
<span class="line" id="L1124">    <span class="tok-kw">var</span> from_it = mem.tokenize(<span class="tok-type">u8</span>, resolved_from, <span class="tok-str">&quot;/\\&quot;</span>);</span>
<span class="line" id="L1125">    <span class="tok-kw">var</span> to_it = mem.tokenize(<span class="tok-type">u8</span>, resolved_to, <span class="tok-str">&quot;/\\&quot;</span>);</span>
<span class="line" id="L1126">    <span class="tok-kw">while</span> (<span class="tok-null">true</span>) {</span>
<span class="line" id="L1127">        <span class="tok-kw">const</span> from_component = from_it.next() <span class="tok-kw">orelse</span> <span class="tok-kw">return</span> allocator.dupe(<span class="tok-type">u8</span>, to_it.rest());</span>
<span class="line" id="L1128">        <span class="tok-kw">const</span> to_rest = to_it.rest();</span>
<span class="line" id="L1129">        <span class="tok-kw">if</span> (to_it.next()) |to_component| {</span>
<span class="line" id="L1130">            <span class="tok-comment">// TODO ASCII is wrong, we actually need full unicode support to compare paths.</span>
</span>
<span class="line" id="L1131">            <span class="tok-kw">if</span> (asciiEqlIgnoreCase(from_component, to_component))</span>
<span class="line" id="L1132">                <span class="tok-kw">continue</span>;</span>
<span class="line" id="L1133">        }</span>
<span class="line" id="L1134">        <span class="tok-kw">var</span> up_count: <span class="tok-type">usize</span> = <span class="tok-number">1</span>;</span>
<span class="line" id="L1135">        <span class="tok-kw">while</span> (from_it.next()) |_| {</span>
<span class="line" id="L1136">            up_count += <span class="tok-number">1</span>;</span>
<span class="line" id="L1137">        }</span>
<span class="line" id="L1138">        <span class="tok-kw">const</span> up_index_end = up_count * <span class="tok-str">&quot;..\\&quot;</span>.len;</span>
<span class="line" id="L1139">        <span class="tok-kw">const</span> result = <span class="tok-kw">try</span> allocator.alloc(<span class="tok-type">u8</span>, up_index_end + to_rest.len);</span>
<span class="line" id="L1140">        <span class="tok-kw">errdefer</span> allocator.free(result);</span>
<span class="line" id="L1141"></span>
<span class="line" id="L1142">        <span class="tok-kw">var</span> result_index: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L1143">        <span class="tok-kw">while</span> (result_index &lt; up_index_end) {</span>
<span class="line" id="L1144">            result[result_index] = <span class="tok-str">'.'</span>;</span>
<span class="line" id="L1145">            result_index += <span class="tok-number">1</span>;</span>
<span class="line" id="L1146">            result[result_index] = <span class="tok-str">'.'</span>;</span>
<span class="line" id="L1147">            result_index += <span class="tok-number">1</span>;</span>
<span class="line" id="L1148">            result[result_index] = <span class="tok-str">'\\'</span>;</span>
<span class="line" id="L1149">            result_index += <span class="tok-number">1</span>;</span>
<span class="line" id="L1150">        }</span>
<span class="line" id="L1151">        <span class="tok-comment">// shave off the trailing slash</span>
</span>
<span class="line" id="L1152">        result_index -= <span class="tok-number">1</span>;</span>
<span class="line" id="L1153"></span>
<span class="line" id="L1154">        <span class="tok-kw">var</span> rest_it = mem.tokenize(<span class="tok-type">u8</span>, to_rest, <span class="tok-str">&quot;/\\&quot;</span>);</span>
<span class="line" id="L1155">        <span class="tok-kw">while</span> (rest_it.next()) |to_component| {</span>
<span class="line" id="L1156">            result[result_index] = <span class="tok-str">'\\'</span>;</span>
<span class="line" id="L1157">            result_index += <span class="tok-number">1</span>;</span>
<span class="line" id="L1158">            mem.copy(<span class="tok-type">u8</span>, result[result_index..], to_component);</span>
<span class="line" id="L1159">            result_index += to_component.len;</span>
<span class="line" id="L1160">        }</span>
<span class="line" id="L1161"></span>
<span class="line" id="L1162">        <span class="tok-kw">return</span> result[<span class="tok-number">0</span>..result_index];</span>
<span class="line" id="L1163">    }</span>
<span class="line" id="L1164"></span>
<span class="line" id="L1165">    <span class="tok-kw">return</span> [_]<span class="tok-type">u8</span>{};</span>
<span class="line" id="L1166">}</span>
<span class="line" id="L1167"></span>
<span class="line" id="L1168"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">relativePosix</span>(allocator: Allocator, from: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>, to: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) ![]<span class="tok-type">u8</span> {</span>
<span class="line" id="L1169">    <span class="tok-kw">const</span> resolved_from = <span class="tok-kw">try</span> resolvePosix(allocator, &amp;[_][]<span class="tok-kw">const</span> <span class="tok-type">u8</span>{from});</span>
<span class="line" id="L1170">    <span class="tok-kw">defer</span> allocator.free(resolved_from);</span>
<span class="line" id="L1171"></span>
<span class="line" id="L1172">    <span class="tok-kw">const</span> resolved_to = <span class="tok-kw">try</span> resolvePosix(allocator, &amp;[_][]<span class="tok-kw">const</span> <span class="tok-type">u8</span>{to});</span>
<span class="line" id="L1173">    <span class="tok-kw">defer</span> allocator.free(resolved_to);</span>
<span class="line" id="L1174"></span>
<span class="line" id="L1175">    <span class="tok-kw">var</span> from_it = mem.tokenize(<span class="tok-type">u8</span>, resolved_from, <span class="tok-str">&quot;/&quot;</span>);</span>
<span class="line" id="L1176">    <span class="tok-kw">var</span> to_it = mem.tokenize(<span class="tok-type">u8</span>, resolved_to, <span class="tok-str">&quot;/&quot;</span>);</span>
<span class="line" id="L1177">    <span class="tok-kw">while</span> (<span class="tok-null">true</span>) {</span>
<span class="line" id="L1178">        <span class="tok-kw">const</span> from_component = from_it.next() <span class="tok-kw">orelse</span> <span class="tok-kw">return</span> allocator.dupe(<span class="tok-type">u8</span>, to_it.rest());</span>
<span class="line" id="L1179">        <span class="tok-kw">const</span> to_rest = to_it.rest();</span>
<span class="line" id="L1180">        <span class="tok-kw">if</span> (to_it.next()) |to_component| {</span>
<span class="line" id="L1181">            <span class="tok-kw">if</span> (mem.eql(<span class="tok-type">u8</span>, from_component, to_component))</span>
<span class="line" id="L1182">                <span class="tok-kw">continue</span>;</span>
<span class="line" id="L1183">        }</span>
<span class="line" id="L1184">        <span class="tok-kw">var</span> up_count: <span class="tok-type">usize</span> = <span class="tok-number">1</span>;</span>
<span class="line" id="L1185">        <span class="tok-kw">while</span> (from_it.next()) |_| {</span>
<span class="line" id="L1186">            up_count += <span class="tok-number">1</span>;</span>
<span class="line" id="L1187">        }</span>
<span class="line" id="L1188">        <span class="tok-kw">const</span> up_index_end = up_count * <span class="tok-str">&quot;../&quot;</span>.len;</span>
<span class="line" id="L1189">        <span class="tok-kw">const</span> result = <span class="tok-kw">try</span> allocator.alloc(<span class="tok-type">u8</span>, up_index_end + to_rest.len);</span>
<span class="line" id="L1190">        <span class="tok-kw">errdefer</span> allocator.free(result);</span>
<span class="line" id="L1191"></span>
<span class="line" id="L1192">        <span class="tok-kw">var</span> result_index: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L1193">        <span class="tok-kw">while</span> (result_index &lt; up_index_end) {</span>
<span class="line" id="L1194">            result[result_index] = <span class="tok-str">'.'</span>;</span>
<span class="line" id="L1195">            result_index += <span class="tok-number">1</span>;</span>
<span class="line" id="L1196">            result[result_index] = <span class="tok-str">'.'</span>;</span>
<span class="line" id="L1197">            result_index += <span class="tok-number">1</span>;</span>
<span class="line" id="L1198">            result[result_index] = <span class="tok-str">'/'</span>;</span>
<span class="line" id="L1199">            result_index += <span class="tok-number">1</span>;</span>
<span class="line" id="L1200">        }</span>
<span class="line" id="L1201">        <span class="tok-kw">if</span> (to_rest.len == <span class="tok-number">0</span>) {</span>
<span class="line" id="L1202">            <span class="tok-comment">// shave off the trailing slash</span>
</span>
<span class="line" id="L1203">            <span class="tok-kw">return</span> allocator.shrink(result, result_index - <span class="tok-number">1</span>);</span>
<span class="line" id="L1204">        }</span>
<span class="line" id="L1205"></span>
<span class="line" id="L1206">        mem.copy(<span class="tok-type">u8</span>, result[result_index..], to_rest);</span>
<span class="line" id="L1207">        <span class="tok-kw">return</span> result;</span>
<span class="line" id="L1208">    }</span>
<span class="line" id="L1209"></span>
<span class="line" id="L1210">    <span class="tok-kw">return</span> [_]<span class="tok-type">u8</span>{};</span>
<span class="line" id="L1211">}</span>
<span class="line" id="L1212"></span>
<span class="line" id="L1213"><span class="tok-kw">test</span> <span class="tok-str">&quot;relative&quot;</span> {</span>
<span class="line" id="L1214">    <span class="tok-kw">if</span> (builtin.target.cpu.arch == .aarch64) {</span>
<span class="line" id="L1215">        <span class="tok-comment">// TODO https://github.com/ziglang/zig/issues/3288</span>
</span>
<span class="line" id="L1216">        <span class="tok-kw">return</span> <span class="tok-kw">error</span>.SkipZigTest;</span>
<span class="line" id="L1217">    }</span>
<span class="line" id="L1218">    <span class="tok-kw">if</span> (native_os == .wasi <span class="tok-kw">and</span> builtin.link_libc) <span class="tok-kw">return</span> <span class="tok-kw">error</span>.SkipZigTest;</span>
<span class="line" id="L1219">    <span class="tok-kw">if</span> (native_os == .wasi <span class="tok-kw">and</span> !builtin.link_libc) <span class="tok-kw">try</span> os.initPreopensWasi(std.heap.page_allocator, <span class="tok-str">&quot;/&quot;</span>);</span>
<span class="line" id="L1220"></span>
<span class="line" id="L1221">    <span class="tok-kw">try</span> testRelativeWindows(<span class="tok-str">&quot;c:/blah\\blah&quot;</span>, <span class="tok-str">&quot;d:/games&quot;</span>, <span class="tok-str">&quot;D:\\games&quot;</span>);</span>
<span class="line" id="L1222">    <span class="tok-kw">try</span> testRelativeWindows(<span class="tok-str">&quot;c:/aaaa/bbbb&quot;</span>, <span class="tok-str">&quot;c:/aaaa&quot;</span>, <span class="tok-str">&quot;..&quot;</span>);</span>
<span class="line" id="L1223">    <span class="tok-kw">try</span> testRelativeWindows(<span class="tok-str">&quot;c:/aaaa/bbbb&quot;</span>, <span class="tok-str">&quot;c:/cccc&quot;</span>, <span class="tok-str">&quot;..\\..\\cccc&quot;</span>);</span>
<span class="line" id="L1224">    <span class="tok-kw">try</span> testRelativeWindows(<span class="tok-str">&quot;c:/aaaa/bbbb&quot;</span>, <span class="tok-str">&quot;c:/aaaa/bbbb&quot;</span>, <span class="tok-str">&quot;&quot;</span>);</span>
<span class="line" id="L1225">    <span class="tok-kw">try</span> testRelativeWindows(<span class="tok-str">&quot;c:/aaaa/bbbb&quot;</span>, <span class="tok-str">&quot;c:/aaaa/cccc&quot;</span>, <span class="tok-str">&quot;..\\cccc&quot;</span>);</span>
<span class="line" id="L1226">    <span class="tok-kw">try</span> testRelativeWindows(<span class="tok-str">&quot;c:/aaaa/&quot;</span>, <span class="tok-str">&quot;c:/aaaa/cccc&quot;</span>, <span class="tok-str">&quot;cccc&quot;</span>);</span>
<span class="line" id="L1227">    <span class="tok-kw">try</span> testRelativeWindows(<span class="tok-str">&quot;c:/&quot;</span>, <span class="tok-str">&quot;c:\\aaaa\\bbbb&quot;</span>, <span class="tok-str">&quot;aaaa\\bbbb&quot;</span>);</span>
<span class="line" id="L1228">    <span class="tok-kw">try</span> testRelativeWindows(<span class="tok-str">&quot;c:/aaaa/bbbb&quot;</span>, <span class="tok-str">&quot;d:\\&quot;</span>, <span class="tok-str">&quot;D:\\&quot;</span>);</span>
<span class="line" id="L1229">    <span class="tok-kw">try</span> testRelativeWindows(<span class="tok-str">&quot;c:/AaAa/bbbb&quot;</span>, <span class="tok-str">&quot;c:/aaaa/bbbb&quot;</span>, <span class="tok-str">&quot;&quot;</span>);</span>
<span class="line" id="L1230">    <span class="tok-kw">try</span> testRelativeWindows(<span class="tok-str">&quot;c:/aaaaa/&quot;</span>, <span class="tok-str">&quot;c:/aaaa/cccc&quot;</span>, <span class="tok-str">&quot;..\\aaaa\\cccc&quot;</span>);</span>
<span class="line" id="L1231">    <span class="tok-kw">try</span> testRelativeWindows(<span class="tok-str">&quot;C:\\foo\\bar\\baz\\quux&quot;</span>, <span class="tok-str">&quot;C:\\&quot;</span>, <span class="tok-str">&quot;..\\..\\..\\..&quot;</span>);</span>
<span class="line" id="L1232">    <span class="tok-kw">try</span> testRelativeWindows(<span class="tok-str">&quot;C:\\foo\\test&quot;</span>, <span class="tok-str">&quot;C:\\foo\\test\\bar\\package.json&quot;</span>, <span class="tok-str">&quot;bar\\package.json&quot;</span>);</span>
<span class="line" id="L1233">    <span class="tok-kw">try</span> testRelativeWindows(<span class="tok-str">&quot;C:\\foo\\bar\\baz-quux&quot;</span>, <span class="tok-str">&quot;C:\\foo\\bar\\baz&quot;</span>, <span class="tok-str">&quot;..\\baz&quot;</span>);</span>
<span class="line" id="L1234">    <span class="tok-kw">try</span> testRelativeWindows(<span class="tok-str">&quot;C:\\foo\\bar\\baz&quot;</span>, <span class="tok-str">&quot;C:\\foo\\bar\\baz-quux&quot;</span>, <span class="tok-str">&quot;..\\baz-quux&quot;</span>);</span>
<span class="line" id="L1235">    <span class="tok-kw">try</span> testRelativeWindows(<span class="tok-str">&quot;\\\\foo\\bar&quot;</span>, <span class="tok-str">&quot;\\\\foo\\bar\\baz&quot;</span>, <span class="tok-str">&quot;baz&quot;</span>);</span>
<span class="line" id="L1236">    <span class="tok-kw">try</span> testRelativeWindows(<span class="tok-str">&quot;\\\\foo\\bar\\baz&quot;</span>, <span class="tok-str">&quot;\\\\foo\\bar&quot;</span>, <span class="tok-str">&quot;..&quot;</span>);</span>
<span class="line" id="L1237">    <span class="tok-kw">try</span> testRelativeWindows(<span class="tok-str">&quot;\\\\foo\\bar\\baz-quux&quot;</span>, <span class="tok-str">&quot;\\\\foo\\bar\\baz&quot;</span>, <span class="tok-str">&quot;..\\baz&quot;</span>);</span>
<span class="line" id="L1238">    <span class="tok-kw">try</span> testRelativeWindows(<span class="tok-str">&quot;\\\\foo\\bar\\baz&quot;</span>, <span class="tok-str">&quot;\\\\foo\\bar\\baz-quux&quot;</span>, <span class="tok-str">&quot;..\\baz-quux&quot;</span>);</span>
<span class="line" id="L1239">    <span class="tok-kw">try</span> testRelativeWindows(<span class="tok-str">&quot;C:\\baz-quux&quot;</span>, <span class="tok-str">&quot;C:\\baz&quot;</span>, <span class="tok-str">&quot;..\\baz&quot;</span>);</span>
<span class="line" id="L1240">    <span class="tok-kw">try</span> testRelativeWindows(<span class="tok-str">&quot;C:\\baz&quot;</span>, <span class="tok-str">&quot;C:\\baz-quux&quot;</span>, <span class="tok-str">&quot;..\\baz-quux&quot;</span>);</span>
<span class="line" id="L1241">    <span class="tok-kw">try</span> testRelativeWindows(<span class="tok-str">&quot;\\\\foo\\baz-quux&quot;</span>, <span class="tok-str">&quot;\\\\foo\\baz&quot;</span>, <span class="tok-str">&quot;..\\baz&quot;</span>);</span>
<span class="line" id="L1242">    <span class="tok-kw">try</span> testRelativeWindows(<span class="tok-str">&quot;\\\\foo\\baz&quot;</span>, <span class="tok-str">&quot;\\\\foo\\baz-quux&quot;</span>, <span class="tok-str">&quot;..\\baz-quux&quot;</span>);</span>
<span class="line" id="L1243">    <span class="tok-kw">try</span> testRelativeWindows(<span class="tok-str">&quot;C:\\baz&quot;</span>, <span class="tok-str">&quot;\\\\foo\\bar\\baz&quot;</span>, <span class="tok-str">&quot;\\\\foo\\bar\\baz&quot;</span>);</span>
<span class="line" id="L1244">    <span class="tok-kw">try</span> testRelativeWindows(<span class="tok-str">&quot;\\\\foo\\bar\\baz&quot;</span>, <span class="tok-str">&quot;C:\\baz&quot;</span>, <span class="tok-str">&quot;C:\\baz&quot;</span>);</span>
<span class="line" id="L1245"></span>
<span class="line" id="L1246">    <span class="tok-kw">try</span> testRelativePosix(<span class="tok-str">&quot;/var/lib&quot;</span>, <span class="tok-str">&quot;/var&quot;</span>, <span class="tok-str">&quot;..&quot;</span>);</span>
<span class="line" id="L1247">    <span class="tok-kw">try</span> testRelativePosix(<span class="tok-str">&quot;/var/lib&quot;</span>, <span class="tok-str">&quot;/bin&quot;</span>, <span class="tok-str">&quot;../../bin&quot;</span>);</span>
<span class="line" id="L1248">    <span class="tok-kw">try</span> testRelativePosix(<span class="tok-str">&quot;/var/lib&quot;</span>, <span class="tok-str">&quot;/var/lib&quot;</span>, <span class="tok-str">&quot;&quot;</span>);</span>
<span class="line" id="L1249">    <span class="tok-kw">try</span> testRelativePosix(<span class="tok-str">&quot;/var/lib&quot;</span>, <span class="tok-str">&quot;/var/apache&quot;</span>, <span class="tok-str">&quot;../apache&quot;</span>);</span>
<span class="line" id="L1250">    <span class="tok-kw">try</span> testRelativePosix(<span class="tok-str">&quot;/var/&quot;</span>, <span class="tok-str">&quot;/var/lib&quot;</span>, <span class="tok-str">&quot;lib&quot;</span>);</span>
<span class="line" id="L1251">    <span class="tok-kw">try</span> testRelativePosix(<span class="tok-str">&quot;/&quot;</span>, <span class="tok-str">&quot;/var/lib&quot;</span>, <span class="tok-str">&quot;var/lib&quot;</span>);</span>
<span class="line" id="L1252">    <span class="tok-kw">try</span> testRelativePosix(<span class="tok-str">&quot;/foo/test&quot;</span>, <span class="tok-str">&quot;/foo/test/bar/package.json&quot;</span>, <span class="tok-str">&quot;bar/package.json&quot;</span>);</span>
<span class="line" id="L1253">    <span class="tok-kw">try</span> testRelativePosix(<span class="tok-str">&quot;/Users/a/web/b/test/mails&quot;</span>, <span class="tok-str">&quot;/Users/a/web/b&quot;</span>, <span class="tok-str">&quot;../..&quot;</span>);</span>
<span class="line" id="L1254">    <span class="tok-kw">try</span> testRelativePosix(<span class="tok-str">&quot;/foo/bar/baz-quux&quot;</span>, <span class="tok-str">&quot;/foo/bar/baz&quot;</span>, <span class="tok-str">&quot;../baz&quot;</span>);</span>
<span class="line" id="L1255">    <span class="tok-kw">try</span> testRelativePosix(<span class="tok-str">&quot;/foo/bar/baz&quot;</span>, <span class="tok-str">&quot;/foo/bar/baz-quux&quot;</span>, <span class="tok-str">&quot;../baz-quux&quot;</span>);</span>
<span class="line" id="L1256">    <span class="tok-kw">try</span> testRelativePosix(<span class="tok-str">&quot;/baz-quux&quot;</span>, <span class="tok-str">&quot;/baz&quot;</span>, <span class="tok-str">&quot;../baz&quot;</span>);</span>
<span class="line" id="L1257">    <span class="tok-kw">try</span> testRelativePosix(<span class="tok-str">&quot;/baz&quot;</span>, <span class="tok-str">&quot;/baz-quux&quot;</span>, <span class="tok-str">&quot;../baz-quux&quot;</span>);</span>
<span class="line" id="L1258">}</span>
<span class="line" id="L1259"></span>
<span class="line" id="L1260"><span class="tok-kw">fn</span> <span class="tok-fn">testRelativePosix</span>(from: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>, to: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>, expected_output: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) !<span class="tok-type">void</span> {</span>
<span class="line" id="L1261">    <span class="tok-kw">const</span> result = <span class="tok-kw">try</span> relativePosix(testing.allocator, from, to);</span>
<span class="line" id="L1262">    <span class="tok-kw">defer</span> testing.allocator.free(result);</span>
<span class="line" id="L1263">    <span class="tok-kw">try</span> testing.expectEqualSlices(<span class="tok-type">u8</span>, expected_output, result);</span>
<span class="line" id="L1264">}</span>
<span class="line" id="L1265"></span>
<span class="line" id="L1266"><span class="tok-kw">fn</span> <span class="tok-fn">testRelativeWindows</span>(from: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>, to: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>, expected_output: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) !<span class="tok-type">void</span> {</span>
<span class="line" id="L1267">    <span class="tok-kw">const</span> result = <span class="tok-kw">try</span> relativeWindows(testing.allocator, from, to);</span>
<span class="line" id="L1268">    <span class="tok-kw">defer</span> testing.allocator.free(result);</span>
<span class="line" id="L1269">    <span class="tok-kw">try</span> testing.expectEqualSlices(<span class="tok-type">u8</span>, expected_output, result);</span>
<span class="line" id="L1270">}</span>
<span class="line" id="L1271"></span>
<span class="line" id="L1272"><span class="tok-comment">/// Returns the extension of the file name (if any).</span></span>
<span class="line" id="L1273"><span class="tok-comment">/// This function will search for the file extension (separated by a `.`) and will return the text after the `.`.</span></span>
<span class="line" id="L1274"><span class="tok-comment">/// Files that end with `.` are considered to have no extension, files that start with `.`</span></span>
<span class="line" id="L1275"><span class="tok-comment">/// Examples:</span></span>
<span class="line" id="L1276"><span class="tok-comment">/// - `&quot;main.zig&quot;`     ⇒ `&quot;.zig&quot;`</span></span>
<span class="line" id="L1277"><span class="tok-comment">/// - `&quot;src/main.zig&quot;` ⇒ `&quot;.zig&quot;`</span></span>
<span class="line" id="L1278"><span class="tok-comment">/// - `&quot;.gitignore&quot;`   ⇒ `&quot;&quot;`</span></span>
<span class="line" id="L1279"><span class="tok-comment">/// - `&quot;keep.&quot;`        ⇒ `&quot;.&quot;`</span></span>
<span class="line" id="L1280"><span class="tok-comment">/// - `&quot;src.keep.me&quot;`  ⇒ `&quot;.me&quot;`</span></span>
<span class="line" id="L1281"><span class="tok-comment">/// - `&quot;/src/keep.me&quot;`  ⇒ `&quot;.me&quot;`</span></span>
<span class="line" id="L1282"><span class="tok-comment">/// - `&quot;/src/keep.me/&quot;`  ⇒ `&quot;.me&quot;`</span></span>
<span class="line" id="L1283"><span class="tok-comment">/// The returned slice is guaranteed to have its pointer within the start and end</span></span>
<span class="line" id="L1284"><span class="tok-comment">/// pointer address range of `path`, even if it is length zero.</span></span>
<span class="line" id="L1285"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">extension</span>(path: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) []<span class="tok-kw">const</span> <span class="tok-type">u8</span> {</span>
<span class="line" id="L1286">    <span class="tok-kw">const</span> filename = basename(path);</span>
<span class="line" id="L1287">    <span class="tok-kw">const</span> index = mem.lastIndexOfScalar(<span class="tok-type">u8</span>, filename, <span class="tok-str">'.'</span>) <span class="tok-kw">orelse</span> <span class="tok-kw">return</span> path[path.len..];</span>
<span class="line" id="L1288">    <span class="tok-kw">if</span> (index == <span class="tok-number">0</span>) <span class="tok-kw">return</span> path[path.len..];</span>
<span class="line" id="L1289">    <span class="tok-kw">return</span> filename[index..];</span>
<span class="line" id="L1290">}</span>
<span class="line" id="L1291"></span>
<span class="line" id="L1292"><span class="tok-kw">fn</span> <span class="tok-fn">testExtension</span>(path: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>, expected: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) !<span class="tok-type">void</span> {</span>
<span class="line" id="L1293">    <span class="tok-kw">try</span> std.testing.expectEqualStrings(expected, extension(path));</span>
<span class="line" id="L1294">}</span>
<span class="line" id="L1295"></span>
<span class="line" id="L1296"><span class="tok-kw">test</span> <span class="tok-str">&quot;extension&quot;</span> {</span>
<span class="line" id="L1297">    <span class="tok-kw">try</span> testExtension(<span class="tok-str">&quot;&quot;</span>, <span class="tok-str">&quot;&quot;</span>);</span>
<span class="line" id="L1298">    <span class="tok-kw">try</span> testExtension(<span class="tok-str">&quot;.&quot;</span>, <span class="tok-str">&quot;&quot;</span>);</span>
<span class="line" id="L1299">    <span class="tok-kw">try</span> testExtension(<span class="tok-str">&quot;a.&quot;</span>, <span class="tok-str">&quot;.&quot;</span>);</span>
<span class="line" id="L1300">    <span class="tok-kw">try</span> testExtension(<span class="tok-str">&quot;abc.&quot;</span>, <span class="tok-str">&quot;.&quot;</span>);</span>
<span class="line" id="L1301">    <span class="tok-kw">try</span> testExtension(<span class="tok-str">&quot;.a&quot;</span>, <span class="tok-str">&quot;&quot;</span>);</span>
<span class="line" id="L1302">    <span class="tok-kw">try</span> testExtension(<span class="tok-str">&quot;.file&quot;</span>, <span class="tok-str">&quot;&quot;</span>);</span>
<span class="line" id="L1303">    <span class="tok-kw">try</span> testExtension(<span class="tok-str">&quot;.gitignore&quot;</span>, <span class="tok-str">&quot;&quot;</span>);</span>
<span class="line" id="L1304">    <span class="tok-kw">try</span> testExtension(<span class="tok-str">&quot;file.ext&quot;</span>, <span class="tok-str">&quot;.ext&quot;</span>);</span>
<span class="line" id="L1305">    <span class="tok-kw">try</span> testExtension(<span class="tok-str">&quot;file.ext.&quot;</span>, <span class="tok-str">&quot;.&quot;</span>);</span>
<span class="line" id="L1306">    <span class="tok-kw">try</span> testExtension(<span class="tok-str">&quot;very-long-file.bruh&quot;</span>, <span class="tok-str">&quot;.bruh&quot;</span>);</span>
<span class="line" id="L1307">    <span class="tok-kw">try</span> testExtension(<span class="tok-str">&quot;a.b.c&quot;</span>, <span class="tok-str">&quot;.c&quot;</span>);</span>
<span class="line" id="L1308">    <span class="tok-kw">try</span> testExtension(<span class="tok-str">&quot;a.b.c/&quot;</span>, <span class="tok-str">&quot;.c&quot;</span>);</span>
<span class="line" id="L1309"></span>
<span class="line" id="L1310">    <span class="tok-kw">try</span> testExtension(<span class="tok-str">&quot;/&quot;</span>, <span class="tok-str">&quot;&quot;</span>);</span>
<span class="line" id="L1311">    <span class="tok-kw">try</span> testExtension(<span class="tok-str">&quot;/.&quot;</span>, <span class="tok-str">&quot;&quot;</span>);</span>
<span class="line" id="L1312">    <span class="tok-kw">try</span> testExtension(<span class="tok-str">&quot;/a.&quot;</span>, <span class="tok-str">&quot;.&quot;</span>);</span>
<span class="line" id="L1313">    <span class="tok-kw">try</span> testExtension(<span class="tok-str">&quot;/abc.&quot;</span>, <span class="tok-str">&quot;.&quot;</span>);</span>
<span class="line" id="L1314">    <span class="tok-kw">try</span> testExtension(<span class="tok-str">&quot;/.a&quot;</span>, <span class="tok-str">&quot;&quot;</span>);</span>
<span class="line" id="L1315">    <span class="tok-kw">try</span> testExtension(<span class="tok-str">&quot;/.file&quot;</span>, <span class="tok-str">&quot;&quot;</span>);</span>
<span class="line" id="L1316">    <span class="tok-kw">try</span> testExtension(<span class="tok-str">&quot;/.gitignore&quot;</span>, <span class="tok-str">&quot;&quot;</span>);</span>
<span class="line" id="L1317">    <span class="tok-kw">try</span> testExtension(<span class="tok-str">&quot;/file.ext&quot;</span>, <span class="tok-str">&quot;.ext&quot;</span>);</span>
<span class="line" id="L1318">    <span class="tok-kw">try</span> testExtension(<span class="tok-str">&quot;/file.ext.&quot;</span>, <span class="tok-str">&quot;.&quot;</span>);</span>
<span class="line" id="L1319">    <span class="tok-kw">try</span> testExtension(<span class="tok-str">&quot;/very-long-file.bruh&quot;</span>, <span class="tok-str">&quot;.bruh&quot;</span>);</span>
<span class="line" id="L1320">    <span class="tok-kw">try</span> testExtension(<span class="tok-str">&quot;/a.b.c&quot;</span>, <span class="tok-str">&quot;.c&quot;</span>);</span>
<span class="line" id="L1321">    <span class="tok-kw">try</span> testExtension(<span class="tok-str">&quot;/a.b.c/&quot;</span>, <span class="tok-str">&quot;.c&quot;</span>);</span>
<span class="line" id="L1322"></span>
<span class="line" id="L1323">    <span class="tok-kw">try</span> testExtension(<span class="tok-str">&quot;/foo/bar/bam/&quot;</span>, <span class="tok-str">&quot;&quot;</span>);</span>
<span class="line" id="L1324">    <span class="tok-kw">try</span> testExtension(<span class="tok-str">&quot;/foo/bar/bam/.&quot;</span>, <span class="tok-str">&quot;&quot;</span>);</span>
<span class="line" id="L1325">    <span class="tok-kw">try</span> testExtension(<span class="tok-str">&quot;/foo/bar/bam/a.&quot;</span>, <span class="tok-str">&quot;.&quot;</span>);</span>
<span class="line" id="L1326">    <span class="tok-kw">try</span> testExtension(<span class="tok-str">&quot;/foo/bar/bam/abc.&quot;</span>, <span class="tok-str">&quot;.&quot;</span>);</span>
<span class="line" id="L1327">    <span class="tok-kw">try</span> testExtension(<span class="tok-str">&quot;/foo/bar/bam/.a&quot;</span>, <span class="tok-str">&quot;&quot;</span>);</span>
<span class="line" id="L1328">    <span class="tok-kw">try</span> testExtension(<span class="tok-str">&quot;/foo/bar/bam/.file&quot;</span>, <span class="tok-str">&quot;&quot;</span>);</span>
<span class="line" id="L1329">    <span class="tok-kw">try</span> testExtension(<span class="tok-str">&quot;/foo/bar/bam/.gitignore&quot;</span>, <span class="tok-str">&quot;&quot;</span>);</span>
<span class="line" id="L1330">    <span class="tok-kw">try</span> testExtension(<span class="tok-str">&quot;/foo/bar/bam/file.ext&quot;</span>, <span class="tok-str">&quot;.ext&quot;</span>);</span>
<span class="line" id="L1331">    <span class="tok-kw">try</span> testExtension(<span class="tok-str">&quot;/foo/bar/bam/file.ext.&quot;</span>, <span class="tok-str">&quot;.&quot;</span>);</span>
<span class="line" id="L1332">    <span class="tok-kw">try</span> testExtension(<span class="tok-str">&quot;/foo/bar/bam/very-long-file.bruh&quot;</span>, <span class="tok-str">&quot;.bruh&quot;</span>);</span>
<span class="line" id="L1333">    <span class="tok-kw">try</span> testExtension(<span class="tok-str">&quot;/foo/bar/bam/a.b.c&quot;</span>, <span class="tok-str">&quot;.c&quot;</span>);</span>
<span class="line" id="L1334">    <span class="tok-kw">try</span> testExtension(<span class="tok-str">&quot;/foo/bar/bam/a.b.c/&quot;</span>, <span class="tok-str">&quot;.c&quot;</span>);</span>
<span class="line" id="L1335">}</span>
<span class="line" id="L1336"></span>
</code></pre></body>
</html>