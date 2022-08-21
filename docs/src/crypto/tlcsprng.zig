<!doctype html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">    <title>crypto/tlcsprng.zig - source view</title>
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
<pre><code><span class="line" id="L1"><span class="tok-comment">//! Thread-local cryptographically secure pseudo-random number generator.</span></span>
<span class="line" id="L2"><span class="tok-comment">//! This file has public declarations that are intended to be used internally</span></span>
<span class="line" id="L3"><span class="tok-comment">//! by the standard library; this namespace is not intended to be exposed</span></span>
<span class="line" id="L4"><span class="tok-comment">//! directly to standard library users.</span></span>
<span class="line" id="L5"></span>
<span class="line" id="L6"><span class="tok-kw">const</span> std = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;std&quot;</span>);</span>
<span class="line" id="L7"><span class="tok-kw">const</span> builtin = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;builtin&quot;</span>);</span>
<span class="line" id="L8"><span class="tok-kw">const</span> root = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;root&quot;</span>);</span>
<span class="line" id="L9"><span class="tok-kw">const</span> mem = std.mem;</span>
<span class="line" id="L10"><span class="tok-kw">const</span> os = std.os;</span>
<span class="line" id="L11"></span>
<span class="line" id="L12"><span class="tok-comment">/// We use this as a layer of indirection because global const pointers cannot</span></span>
<span class="line" id="L13"><span class="tok-comment">/// point to thread-local variables.</span></span>
<span class="line" id="L14"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> interface = std.rand.Random{</span>
<span class="line" id="L15">    .ptr = <span class="tok-null">undefined</span>,</span>
<span class="line" id="L16">    .fillFn = tlsCsprngFill,</span>
<span class="line" id="L17">};</span>
<span class="line" id="L18"></span>
<span class="line" id="L19"><span class="tok-kw">const</span> os_has_fork = <span class="tok-kw">switch</span> (builtin.os.tag) {</span>
<span class="line" id="L20">    .dragonfly,</span>
<span class="line" id="L21">    .freebsd,</span>
<span class="line" id="L22">    .ios,</span>
<span class="line" id="L23">    .kfreebsd,</span>
<span class="line" id="L24">    .linux,</span>
<span class="line" id="L25">    .macos,</span>
<span class="line" id="L26">    .netbsd,</span>
<span class="line" id="L27">    .openbsd,</span>
<span class="line" id="L28">    .solaris,</span>
<span class="line" id="L29">    .tvos,</span>
<span class="line" id="L30">    .watchos,</span>
<span class="line" id="L31">    .haiku,</span>
<span class="line" id="L32">    =&gt; <span class="tok-null">true</span>,</span>
<span class="line" id="L33"></span>
<span class="line" id="L34">    <span class="tok-kw">else</span> =&gt; <span class="tok-null">false</span>,</span>
<span class="line" id="L35">};</span>
<span class="line" id="L36"><span class="tok-kw">const</span> os_has_arc4random = builtin.link_libc <span class="tok-kw">and</span> <span class="tok-builtin">@hasDecl</span>(std.c, <span class="tok-str">&quot;arc4random_buf&quot;</span>);</span>
<span class="line" id="L37"><span class="tok-kw">const</span> want_fork_safety = os_has_fork <span class="tok-kw">and</span> !os_has_arc4random <span class="tok-kw">and</span></span>
<span class="line" id="L38">    (std.meta.globalOption(<span class="tok-str">&quot;crypto_fork_safety&quot;</span>, <span class="tok-type">bool</span>) <span class="tok-kw">orelse</span> <span class="tok-null">true</span>);</span>
<span class="line" id="L39"><span class="tok-kw">const</span> maybe_have_wipe_on_fork = builtin.os.isAtLeast(.linux, .{</span>
<span class="line" id="L40">    .major = <span class="tok-number">4</span>,</span>
<span class="line" id="L41">    .minor = <span class="tok-number">14</span>,</span>
<span class="line" id="L42">}) <span class="tok-kw">orelse</span> <span class="tok-null">true</span>;</span>
<span class="line" id="L43"><span class="tok-kw">const</span> is_haiku = builtin.os.tag == .haiku;</span>
<span class="line" id="L44"></span>
<span class="line" id="L45"><span class="tok-kw">const</span> Context = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L46">    init_state: <span class="tok-kw">enum</span>(<span class="tok-type">u8</span>) { uninitialized = <span class="tok-number">0</span>, initialized, failed },</span>
<span class="line" id="L47">    gimli: std.crypto.core.Gimli,</span>
<span class="line" id="L48">};</span>
<span class="line" id="L49"></span>
<span class="line" id="L50"><span class="tok-kw">var</span> install_atfork_handler = std.once(<span class="tok-kw">struct</span> {</span>
<span class="line" id="L51">    <span class="tok-comment">// Install the global handler only once.</span>
</span>
<span class="line" id="L52">    <span class="tok-comment">// The same handler is shared among threads and is inherinted by fork()-ed</span>
</span>
<span class="line" id="L53">    <span class="tok-comment">// processes.</span>
</span>
<span class="line" id="L54">    <span class="tok-kw">fn</span> <span class="tok-fn">do</span>() <span class="tok-type">void</span> {</span>
<span class="line" id="L55">        <span class="tok-kw">const</span> r = std.c.pthread_atfork(<span class="tok-null">null</span>, <span class="tok-null">null</span>, childAtForkHandler);</span>
<span class="line" id="L56">        std.debug.assert(r == <span class="tok-number">0</span>);</span>
<span class="line" id="L57">    }</span>
<span class="line" id="L58">}.do);</span>
<span class="line" id="L59"></span>
<span class="line" id="L60"><span class="tok-kw">threadlocal</span> <span class="tok-kw">var</span> wipe_mem: []<span class="tok-kw">align</span>(mem.page_size) <span class="tok-type">u8</span> = &amp;[_]<span class="tok-type">u8</span>{};</span>
<span class="line" id="L61"></span>
<span class="line" id="L62"><span class="tok-kw">fn</span> <span class="tok-fn">tlsCsprngFill</span>(_: *<span class="tok-type">anyopaque</span>, buffer: []<span class="tok-type">u8</span>) <span class="tok-type">void</span> {</span>
<span class="line" id="L63">    <span class="tok-kw">if</span> (builtin.link_libc <span class="tok-kw">and</span> <span class="tok-builtin">@hasDecl</span>(std.c, <span class="tok-str">&quot;arc4random_buf&quot;</span>)) {</span>
<span class="line" id="L64">        <span class="tok-comment">// arc4random is already a thread-local CSPRNG.</span>
</span>
<span class="line" id="L65">        <span class="tok-kw">return</span> std.c.arc4random_buf(buffer.ptr, buffer.len);</span>
<span class="line" id="L66">    }</span>
<span class="line" id="L67">    <span class="tok-comment">// Allow applications to decide they would prefer to have every call to</span>
</span>
<span class="line" id="L68">    <span class="tok-comment">// std.crypto.random always make an OS syscall, rather than rely on an</span>
</span>
<span class="line" id="L69">    <span class="tok-comment">// application implementation of a CSPRNG.</span>
</span>
<span class="line" id="L70">    <span class="tok-kw">if</span> (<span class="tok-kw">comptime</span> std.meta.globalOption(<span class="tok-str">&quot;crypto_always_getrandom&quot;</span>, <span class="tok-type">bool</span>) <span class="tok-kw">orelse</span> <span class="tok-null">false</span>) {</span>
<span class="line" id="L71">        <span class="tok-kw">return</span> fillWithOsEntropy(buffer);</span>
<span class="line" id="L72">    }</span>
<span class="line" id="L73"></span>
<span class="line" id="L74">    <span class="tok-kw">if</span> (wipe_mem.len == <span class="tok-number">0</span>) {</span>
<span class="line" id="L75">        <span class="tok-comment">// Not initialized yet.</span>
</span>
<span class="line" id="L76">        <span class="tok-kw">if</span> (want_fork_safety <span class="tok-kw">and</span> maybe_have_wipe_on_fork <span class="tok-kw">or</span> is_haiku) {</span>
<span class="line" id="L77">            <span class="tok-comment">// Allocate a per-process page, madvise operates with page</span>
</span>
<span class="line" id="L78">            <span class="tok-comment">// granularity.</span>
</span>
<span class="line" id="L79">            wipe_mem = os.mmap(</span>
<span class="line" id="L80">                <span class="tok-null">null</span>,</span>
<span class="line" id="L81">                <span class="tok-builtin">@sizeOf</span>(Context),</span>
<span class="line" id="L82">                os.PROT.READ | os.PROT.WRITE,</span>
<span class="line" id="L83">                os.MAP.PRIVATE | os.MAP.ANONYMOUS,</span>
<span class="line" id="L84">                -<span class="tok-number">1</span>,</span>
<span class="line" id="L85">                <span class="tok-number">0</span>,</span>
<span class="line" id="L86">            ) <span class="tok-kw">catch</span> {</span>
<span class="line" id="L87">                <span class="tok-comment">// Could not allocate memory for the local state, fall back to</span>
</span>
<span class="line" id="L88">                <span class="tok-comment">// the OS syscall.</span>
</span>
<span class="line" id="L89">                <span class="tok-kw">return</span> fillWithOsEntropy(buffer);</span>
<span class="line" id="L90">            };</span>
<span class="line" id="L91">            <span class="tok-comment">// The memory is already zero-initialized.</span>
</span>
<span class="line" id="L92">        } <span class="tok-kw">else</span> {</span>
<span class="line" id="L93">            <span class="tok-comment">// Use a static thread-local buffer.</span>
</span>
<span class="line" id="L94">            <span class="tok-kw">const</span> S = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L95">                <span class="tok-kw">threadlocal</span> <span class="tok-kw">var</span> buf: Context <span class="tok-kw">align</span>(mem.page_size) = .{</span>
<span class="line" id="L96">                    .init_state = .uninitialized,</span>
<span class="line" id="L97">                    .gimli = <span class="tok-null">undefined</span>,</span>
<span class="line" id="L98">                };</span>
<span class="line" id="L99">            };</span>
<span class="line" id="L100">            wipe_mem = mem.asBytes(&amp;S.buf);</span>
<span class="line" id="L101">        }</span>
<span class="line" id="L102">    }</span>
<span class="line" id="L103">    <span class="tok-kw">const</span> ctx = <span class="tok-builtin">@ptrCast</span>(*Context, wipe_mem.ptr);</span>
<span class="line" id="L104"></span>
<span class="line" id="L105">    <span class="tok-kw">switch</span> (ctx.init_state) {</span>
<span class="line" id="L106">        .uninitialized =&gt; {</span>
<span class="line" id="L107">            <span class="tok-kw">if</span> (!want_fork_safety) {</span>
<span class="line" id="L108">                <span class="tok-kw">return</span> initAndFill(buffer);</span>
<span class="line" id="L109">            }</span>
<span class="line" id="L110"></span>
<span class="line" id="L111">            <span class="tok-kw">if</span> (maybe_have_wipe_on_fork) wof: {</span>
<span class="line" id="L112">                <span class="tok-comment">// Qemu user-mode emulation ignores any valid/invalid madvise</span>
</span>
<span class="line" id="L113">                <span class="tok-comment">// hint and returns success. Check if this is the case by</span>
</span>
<span class="line" id="L114">                <span class="tok-comment">// passing bogus parameters, we expect EINVAL as result.</span>
</span>
<span class="line" id="L115">                <span class="tok-kw">if</span> (os.madvise(wipe_mem.ptr, <span class="tok-number">0</span>, <span class="tok-number">0xffffffff</span>)) |_| {</span>
<span class="line" id="L116">                    <span class="tok-kw">break</span> :wof;</span>
<span class="line" id="L117">                } <span class="tok-kw">else</span> |_| {}</span>
<span class="line" id="L118"></span>
<span class="line" id="L119">                <span class="tok-kw">if</span> (os.madvise(wipe_mem.ptr, wipe_mem.len, os.MADV.WIPEONFORK)) |_| {</span>
<span class="line" id="L120">                    <span class="tok-kw">return</span> initAndFill(buffer);</span>
<span class="line" id="L121">                } <span class="tok-kw">else</span> |_| {}</span>
<span class="line" id="L122">            }</span>
<span class="line" id="L123"></span>
<span class="line" id="L124">            <span class="tok-kw">if</span> (std.Thread.use_pthreads) {</span>
<span class="line" id="L125">                <span class="tok-kw">return</span> setupPthreadAtforkAndFill(buffer);</span>
<span class="line" id="L126">            }</span>
<span class="line" id="L127"></span>
<span class="line" id="L128">            <span class="tok-comment">// Since we failed to set up fork safety, we fall back to always</span>
</span>
<span class="line" id="L129">            <span class="tok-comment">// calling getrandom every time.</span>
</span>
<span class="line" id="L130">            ctx.init_state = .failed;</span>
<span class="line" id="L131">            <span class="tok-kw">return</span> fillWithOsEntropy(buffer);</span>
<span class="line" id="L132">        },</span>
<span class="line" id="L133">        .initialized =&gt; {</span>
<span class="line" id="L134">            <span class="tok-kw">return</span> fillWithCsprng(buffer);</span>
<span class="line" id="L135">        },</span>
<span class="line" id="L136">        .failed =&gt; {</span>
<span class="line" id="L137">            <span class="tok-kw">if</span> (want_fork_safety) {</span>
<span class="line" id="L138">                <span class="tok-kw">return</span> fillWithOsEntropy(buffer);</span>
<span class="line" id="L139">            } <span class="tok-kw">else</span> {</span>
<span class="line" id="L140">                <span class="tok-kw">unreachable</span>;</span>
<span class="line" id="L141">            }</span>
<span class="line" id="L142">        },</span>
<span class="line" id="L143">    }</span>
<span class="line" id="L144">}</span>
<span class="line" id="L145"></span>
<span class="line" id="L146"><span class="tok-kw">fn</span> <span class="tok-fn">setupPthreadAtforkAndFill</span>(buffer: []<span class="tok-type">u8</span>) <span class="tok-type">void</span> {</span>
<span class="line" id="L147">    install_atfork_handler.call();</span>
<span class="line" id="L148">    <span class="tok-kw">return</span> initAndFill(buffer);</span>
<span class="line" id="L149">}</span>
<span class="line" id="L150"></span>
<span class="line" id="L151"><span class="tok-kw">fn</span> <span class="tok-fn">childAtForkHandler</span>() <span class="tok-kw">callconv</span>(.C) <span class="tok-type">void</span> {</span>
<span class="line" id="L152">    <span class="tok-comment">// The atfork handler is global, this function may be called after</span>
</span>
<span class="line" id="L153">    <span class="tok-comment">// fork()-ing threads that never initialized the CSPRNG context.</span>
</span>
<span class="line" id="L154">    <span class="tok-kw">if</span> (wipe_mem.len == <span class="tok-number">0</span>) <span class="tok-kw">return</span>;</span>
<span class="line" id="L155">    std.crypto.utils.secureZero(<span class="tok-type">u8</span>, wipe_mem);</span>
<span class="line" id="L156">}</span>
<span class="line" id="L157"></span>
<span class="line" id="L158"><span class="tok-kw">fn</span> <span class="tok-fn">fillWithCsprng</span>(buffer: []<span class="tok-type">u8</span>) <span class="tok-type">void</span> {</span>
<span class="line" id="L159">    <span class="tok-kw">const</span> ctx = <span class="tok-builtin">@ptrCast</span>(*Context, wipe_mem.ptr);</span>
<span class="line" id="L160">    <span class="tok-kw">if</span> (buffer.len != <span class="tok-number">0</span>) {</span>
<span class="line" id="L161">        ctx.gimli.squeeze(buffer);</span>
<span class="line" id="L162">    } <span class="tok-kw">else</span> {</span>
<span class="line" id="L163">        ctx.gimli.permute();</span>
<span class="line" id="L164">    }</span>
<span class="line" id="L165">    mem.set(<span class="tok-type">u8</span>, ctx.gimli.toSlice()[<span class="tok-number">0</span>..std.crypto.core.Gimli.RATE], <span class="tok-number">0</span>);</span>
<span class="line" id="L166">}</span>
<span class="line" id="L167"></span>
<span class="line" id="L168"><span class="tok-kw">fn</span> <span class="tok-fn">fillWithOsEntropy</span>(buffer: []<span class="tok-type">u8</span>) <span class="tok-type">void</span> {</span>
<span class="line" id="L169">    os.getrandom(buffer) <span class="tok-kw">catch</span> <span class="tok-builtin">@panic</span>(<span class="tok-str">&quot;getrandom() failed to provide entropy&quot;</span>);</span>
<span class="line" id="L170">}</span>
<span class="line" id="L171"></span>
<span class="line" id="L172"><span class="tok-kw">fn</span> <span class="tok-fn">initAndFill</span>(buffer: []<span class="tok-type">u8</span>) <span class="tok-type">void</span> {</span>
<span class="line" id="L173">    <span class="tok-kw">var</span> seed: [std.crypto.core.Gimli.BLOCKBYTES]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L174">    <span class="tok-comment">// Because we panic on getrandom() failing, we provide the opportunity</span>
</span>
<span class="line" id="L175">    <span class="tok-comment">// to override the default seed function. This also makes</span>
</span>
<span class="line" id="L176">    <span class="tok-comment">// `std.crypto.random` available on freestanding targets, provided that</span>
</span>
<span class="line" id="L177">    <span class="tok-comment">// the `cryptoRandomSeed` function is provided.</span>
</span>
<span class="line" id="L178">    <span class="tok-kw">if</span> (<span class="tok-builtin">@hasDecl</span>(root, <span class="tok-str">&quot;cryptoRandomSeed&quot;</span>)) {</span>
<span class="line" id="L179">        root.cryptoRandomSeed(&amp;seed);</span>
<span class="line" id="L180">    } <span class="tok-kw">else</span> {</span>
<span class="line" id="L181">        fillWithOsEntropy(&amp;seed);</span>
<span class="line" id="L182">    }</span>
<span class="line" id="L183"></span>
<span class="line" id="L184">    <span class="tok-kw">const</span> ctx = <span class="tok-builtin">@ptrCast</span>(*Context, wipe_mem.ptr);</span>
<span class="line" id="L185">    ctx.gimli = std.crypto.core.Gimli.init(seed);</span>
<span class="line" id="L186"></span>
<span class="line" id="L187">    <span class="tok-comment">// This is at the end so that accidental recursive dependencies result</span>
</span>
<span class="line" id="L188">    <span class="tok-comment">// in stack overflows instead of invalid random data.</span>
</span>
<span class="line" id="L189">    ctx.init_state = .initialized;</span>
<span class="line" id="L190"></span>
<span class="line" id="L191">    <span class="tok-kw">return</span> fillWithCsprng(buffer);</span>
<span class="line" id="L192">}</span>
<span class="line" id="L193"></span>
</code></pre></body>
</html>