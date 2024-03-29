<!doctype html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">    <title>Thread.zig - source view</title>
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
<pre><code><span class="line" id="L1"><span class="tok-comment">//! This struct represents a kernel thread, and acts as a namespace for concurrency</span></span>
<span class="line" id="L2"><span class="tok-comment">//! primitives that operate on kernel threads. For concurrency primitives that support</span></span>
<span class="line" id="L3"><span class="tok-comment">//! both evented I/O and async I/O, see the respective names in the top level std namespace.</span></span>
<span class="line" id="L4"></span>
<span class="line" id="L5"><span class="tok-kw">const</span> std = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;std.zig&quot;</span>);</span>
<span class="line" id="L6"><span class="tok-kw">const</span> builtin = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;builtin&quot;</span>);</span>
<span class="line" id="L7"><span class="tok-kw">const</span> math = std.math;</span>
<span class="line" id="L8"><span class="tok-kw">const</span> os = std.os;</span>
<span class="line" id="L9"><span class="tok-kw">const</span> assert = std.debug.assert;</span>
<span class="line" id="L10"><span class="tok-kw">const</span> target = builtin.target;</span>
<span class="line" id="L11"><span class="tok-kw">const</span> Atomic = std.atomic.Atomic;</span>
<span class="line" id="L12"></span>
<span class="line" id="L13"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> Futex = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;Thread/Futex.zig&quot;</span>);</span>
<span class="line" id="L14"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> ResetEvent = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;Thread/ResetEvent.zig&quot;</span>);</span>
<span class="line" id="L15"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> Mutex = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;Thread/Mutex.zig&quot;</span>);</span>
<span class="line" id="L16"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> Semaphore = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;Thread/Semaphore.zig&quot;</span>);</span>
<span class="line" id="L17"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> Condition = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;Thread/Condition.zig&quot;</span>);</span>
<span class="line" id="L18"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> RwLock = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;Thread/RwLock.zig&quot;</span>);</span>
<span class="line" id="L19"></span>
<span class="line" id="L20"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> use_pthreads = target.os.tag != .windows <span class="tok-kw">and</span> target.os.tag != .wasi <span class="tok-kw">and</span> builtin.link_libc;</span>
<span class="line" id="L21"><span class="tok-kw">const</span> is_gnu = target.abi.isGnu();</span>
<span class="line" id="L22"></span>
<span class="line" id="L23"><span class="tok-kw">const</span> Thread = <span class="tok-builtin">@This</span>();</span>
<span class="line" id="L24"><span class="tok-kw">const</span> Impl = <span class="tok-kw">if</span> (target.os.tag == .windows)</span>
<span class="line" id="L25">    WindowsThreadImpl</span>
<span class="line" id="L26"><span class="tok-kw">else</span> <span class="tok-kw">if</span> (use_pthreads)</span>
<span class="line" id="L27">    PosixThreadImpl</span>
<span class="line" id="L28"><span class="tok-kw">else</span> <span class="tok-kw">if</span> (target.os.tag == .linux)</span>
<span class="line" id="L29">    LinuxThreadImpl</span>
<span class="line" id="L30"><span class="tok-kw">else</span></span>
<span class="line" id="L31">    UnsupportedImpl;</span>
<span class="line" id="L32"></span>
<span class="line" id="L33">impl: Impl,</span>
<span class="line" id="L34"></span>
<span class="line" id="L35"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> max_name_len = <span class="tok-kw">switch</span> (target.os.tag) {</span>
<span class="line" id="L36">    .linux =&gt; <span class="tok-number">15</span>,</span>
<span class="line" id="L37">    .windows =&gt; <span class="tok-number">31</span>,</span>
<span class="line" id="L38">    .macos, .ios, .watchos, .tvos =&gt; <span class="tok-number">63</span>,</span>
<span class="line" id="L39">    .netbsd =&gt; <span class="tok-number">31</span>,</span>
<span class="line" id="L40">    .freebsd =&gt; <span class="tok-number">15</span>,</span>
<span class="line" id="L41">    .openbsd =&gt; <span class="tok-number">31</span>,</span>
<span class="line" id="L42">    .dragonfly =&gt; <span class="tok-number">1023</span>,</span>
<span class="line" id="L43">    .solaris =&gt; <span class="tok-number">31</span>,</span>
<span class="line" id="L44">    <span class="tok-kw">else</span> =&gt; <span class="tok-number">0</span>,</span>
<span class="line" id="L45">};</span>
<span class="line" id="L46"></span>
<span class="line" id="L47"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> SetNameError = <span class="tok-kw">error</span>{</span>
<span class="line" id="L48">    NameTooLong,</span>
<span class="line" id="L49">    Unsupported,</span>
<span class="line" id="L50">    Unexpected,</span>
<span class="line" id="L51">} || os.PrctlError || os.WriteError || std.fs.File.OpenError || std.fmt.BufPrintError;</span>
<span class="line" id="L52"></span>
<span class="line" id="L53"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">setName</span>(self: Thread, name: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) SetNameError!<span class="tok-type">void</span> {</span>
<span class="line" id="L54">    <span class="tok-kw">if</span> (name.len &gt; max_name_len) <span class="tok-kw">return</span> <span class="tok-kw">error</span>.NameTooLong;</span>
<span class="line" id="L55"></span>
<span class="line" id="L56">    <span class="tok-kw">const</span> name_with_terminator = blk: {</span>
<span class="line" id="L57">        <span class="tok-kw">var</span> name_buf: [max_name_len:<span class="tok-number">0</span>]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L58">        std.mem.copy(<span class="tok-type">u8</span>, &amp;name_buf, name);</span>
<span class="line" id="L59">        name_buf[name.len] = <span class="tok-number">0</span>;</span>
<span class="line" id="L60">        <span class="tok-kw">break</span> :blk name_buf[<span class="tok-number">0</span>..name.len :<span class="tok-number">0</span>];</span>
<span class="line" id="L61">    };</span>
<span class="line" id="L62"></span>
<span class="line" id="L63">    <span class="tok-kw">switch</span> (target.os.tag) {</span>
<span class="line" id="L64">        .linux =&gt; <span class="tok-kw">if</span> (use_pthreads) {</span>
<span class="line" id="L65">            <span class="tok-kw">const</span> err = std.c.pthread_setname_np(self.getHandle(), name_with_terminator.ptr);</span>
<span class="line" id="L66">            <span class="tok-kw">switch</span> (err) {</span>
<span class="line" id="L67">                .SUCCESS =&gt; <span class="tok-kw">return</span>,</span>
<span class="line" id="L68">                .RANGE =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L69">                <span class="tok-kw">else</span> =&gt; |e| <span class="tok-kw">return</span> os.unexpectedErrno(e),</span>
<span class="line" id="L70">            }</span>
<span class="line" id="L71">        } <span class="tok-kw">else</span> <span class="tok-kw">if</span> (use_pthreads <span class="tok-kw">and</span> self.getHandle() == std.c.pthread_self()) {</span>
<span class="line" id="L72">            <span class="tok-comment">// TODO: this is dead code. what did the author of this code intend to happen here?</span>
</span>
<span class="line" id="L73">            <span class="tok-kw">const</span> err = <span class="tok-kw">try</span> os.prctl(.SET_NAME, .{<span class="tok-builtin">@ptrToInt</span>(name_with_terminator.ptr)});</span>
<span class="line" id="L74">            <span class="tok-kw">switch</span> (<span class="tok-builtin">@intToEnum</span>(os.E, err)) {</span>
<span class="line" id="L75">                .SUCCESS =&gt; <span class="tok-kw">return</span>,</span>
<span class="line" id="L76">                <span class="tok-kw">else</span> =&gt; |e| <span class="tok-kw">return</span> os.unexpectedErrno(e),</span>
<span class="line" id="L77">            }</span>
<span class="line" id="L78">        } <span class="tok-kw">else</span> {</span>
<span class="line" id="L79">            <span class="tok-kw">var</span> buf: [<span class="tok-number">32</span>]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L80">            <span class="tok-kw">const</span> path = <span class="tok-kw">try</span> std.fmt.bufPrint(&amp;buf, <span class="tok-str">&quot;/proc/self/task/{d}/comm&quot;</span>, .{self.getHandle()});</span>
<span class="line" id="L81"></span>
<span class="line" id="L82">            <span class="tok-kw">const</span> file = <span class="tok-kw">try</span> std.fs.cwd().openFile(path, .{ .mode = .write_only });</span>
<span class="line" id="L83">            <span class="tok-kw">defer</span> file.close();</span>
<span class="line" id="L84"></span>
<span class="line" id="L85">            <span class="tok-kw">try</span> file.writer().writeAll(name);</span>
<span class="line" id="L86">            <span class="tok-kw">return</span>;</span>
<span class="line" id="L87">        },</span>
<span class="line" id="L88">        .windows =&gt; {</span>
<span class="line" id="L89">            <span class="tok-kw">var</span> buf: [max_name_len]<span class="tok-type">u16</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L90">            <span class="tok-kw">const</span> len = <span class="tok-kw">try</span> std.unicode.utf8ToUtf16Le(&amp;buf, name);</span>
<span class="line" id="L91">            <span class="tok-kw">const</span> byte_len = math.cast(<span class="tok-type">c_ushort</span>, len * <span class="tok-number">2</span>) <span class="tok-kw">orelse</span> <span class="tok-kw">return</span> <span class="tok-kw">error</span>.NameTooLong;</span>
<span class="line" id="L92"></span>
<span class="line" id="L93">            <span class="tok-comment">// Note: NT allocates its own copy, no use-after-free here.</span>
</span>
<span class="line" id="L94">            <span class="tok-kw">const</span> unicode_string = os.windows.UNICODE_STRING{</span>
<span class="line" id="L95">                .Length = byte_len,</span>
<span class="line" id="L96">                .MaximumLength = byte_len,</span>
<span class="line" id="L97">                .Buffer = &amp;buf,</span>
<span class="line" id="L98">            };</span>
<span class="line" id="L99"></span>
<span class="line" id="L100">            <span class="tok-kw">switch</span> (os.windows.ntdll.NtSetInformationThread(</span>
<span class="line" id="L101">                self.getHandle(),</span>
<span class="line" id="L102">                .ThreadNameInformation,</span>
<span class="line" id="L103">                &amp;unicode_string,</span>
<span class="line" id="L104">                <span class="tok-builtin">@sizeOf</span>(os.windows.UNICODE_STRING),</span>
<span class="line" id="L105">            )) {</span>
<span class="line" id="L106">                .SUCCESS =&gt; <span class="tok-kw">return</span>,</span>
<span class="line" id="L107">                .NOT_IMPLEMENTED =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.Unsupported,</span>
<span class="line" id="L108">                <span class="tok-kw">else</span> =&gt; |err| <span class="tok-kw">return</span> os.windows.unexpectedStatus(err),</span>
<span class="line" id="L109">            }</span>
<span class="line" id="L110">        },</span>
<span class="line" id="L111">        .macos, .ios, .watchos, .tvos =&gt; <span class="tok-kw">if</span> (use_pthreads) {</span>
<span class="line" id="L112">            <span class="tok-comment">// There doesn't seem to be a way to set the name for an arbitrary thread, only the current one.</span>
</span>
<span class="line" id="L113">            <span class="tok-kw">if</span> (self.getHandle() != std.c.pthread_self()) <span class="tok-kw">return</span> <span class="tok-kw">error</span>.Unsupported;</span>
<span class="line" id="L114"></span>
<span class="line" id="L115">            <span class="tok-kw">const</span> err = std.c.pthread_setname_np(name_with_terminator.ptr);</span>
<span class="line" id="L116">            <span class="tok-kw">switch</span> (err) {</span>
<span class="line" id="L117">                .SUCCESS =&gt; <span class="tok-kw">return</span>,</span>
<span class="line" id="L118">                <span class="tok-kw">else</span> =&gt; |e| <span class="tok-kw">return</span> os.unexpectedErrno(e),</span>
<span class="line" id="L119">            }</span>
<span class="line" id="L120">        },</span>
<span class="line" id="L121">        .netbsd, .solaris =&gt; <span class="tok-kw">if</span> (use_pthreads) {</span>
<span class="line" id="L122">            <span class="tok-kw">const</span> err = std.c.pthread_setname_np(self.getHandle(), name_with_terminator.ptr, <span class="tok-null">null</span>);</span>
<span class="line" id="L123">            <span class="tok-kw">switch</span> (err) {</span>
<span class="line" id="L124">                .SUCCESS =&gt; <span class="tok-kw">return</span>,</span>
<span class="line" id="L125">                .INVAL =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L126">                .SRCH =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L127">                .NOMEM =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L128">                <span class="tok-kw">else</span> =&gt; |e| <span class="tok-kw">return</span> os.unexpectedErrno(e),</span>
<span class="line" id="L129">            }</span>
<span class="line" id="L130">        },</span>
<span class="line" id="L131">        .freebsd, .openbsd =&gt; <span class="tok-kw">if</span> (use_pthreads) {</span>
<span class="line" id="L132">            <span class="tok-comment">// Use pthread_set_name_np for FreeBSD because pthread_setname_np is FreeBSD 12.2+ only.</span>
</span>
<span class="line" id="L133">            <span class="tok-comment">// TODO maybe revisit this if depending on FreeBSD 12.2+ is acceptable because</span>
</span>
<span class="line" id="L134">            <span class="tok-comment">// pthread_setname_np can return an error.</span>
</span>
<span class="line" id="L135"></span>
<span class="line" id="L136">            std.c.pthread_set_name_np(self.getHandle(), name_with_terminator.ptr);</span>
<span class="line" id="L137">            <span class="tok-kw">return</span>;</span>
<span class="line" id="L138">        },</span>
<span class="line" id="L139">        .dragonfly =&gt; <span class="tok-kw">if</span> (use_pthreads) {</span>
<span class="line" id="L140">            <span class="tok-kw">const</span> err = std.c.pthread_setname_np(self.getHandle(), name_with_terminator.ptr);</span>
<span class="line" id="L141">            <span class="tok-kw">switch</span> (err) {</span>
<span class="line" id="L142">                .SUCCESS =&gt; <span class="tok-kw">return</span>,</span>
<span class="line" id="L143">                .INVAL =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L144">                .FAULT =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L145">                .NAMETOOLONG =&gt; <span class="tok-kw">unreachable</span>, <span class="tok-comment">// already checked</span>
</span>
<span class="line" id="L146">                .SRCH =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L147">                <span class="tok-kw">else</span> =&gt; |e| <span class="tok-kw">return</span> os.unexpectedErrno(e),</span>
<span class="line" id="L148">            }</span>
<span class="line" id="L149">        },</span>
<span class="line" id="L150">        <span class="tok-kw">else</span> =&gt; {},</span>
<span class="line" id="L151">    }</span>
<span class="line" id="L152">    <span class="tok-kw">return</span> <span class="tok-kw">error</span>.Unsupported;</span>
<span class="line" id="L153">}</span>
<span class="line" id="L154"></span>
<span class="line" id="L155"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> GetNameError = <span class="tok-kw">error</span>{</span>
<span class="line" id="L156">    <span class="tok-comment">// For Windows, the name is converted from UTF16 to UTF8</span>
</span>
<span class="line" id="L157">    CodepointTooLarge,</span>
<span class="line" id="L158">    Utf8CannotEncodeSurrogateHalf,</span>
<span class="line" id="L159">    DanglingSurrogateHalf,</span>
<span class="line" id="L160">    ExpectedSecondSurrogateHalf,</span>
<span class="line" id="L161">    UnexpectedSecondSurrogateHalf,</span>
<span class="line" id="L162"></span>
<span class="line" id="L163">    Unsupported,</span>
<span class="line" id="L164">    Unexpected,</span>
<span class="line" id="L165">} || os.PrctlError || os.ReadError || std.fs.File.OpenError || std.fmt.BufPrintError;</span>
<span class="line" id="L166"></span>
<span class="line" id="L167"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">getName</span>(self: Thread, buffer_ptr: *[max_name_len:<span class="tok-number">0</span>]<span class="tok-type">u8</span>) GetNameError!?[]<span class="tok-kw">const</span> <span class="tok-type">u8</span> {</span>
<span class="line" id="L168">    buffer_ptr[max_name_len] = <span class="tok-number">0</span>;</span>
<span class="line" id="L169">    <span class="tok-kw">var</span> buffer = std.mem.span(buffer_ptr);</span>
<span class="line" id="L170"></span>
<span class="line" id="L171">    <span class="tok-kw">switch</span> (target.os.tag) {</span>
<span class="line" id="L172">        .linux =&gt; <span class="tok-kw">if</span> (use_pthreads <span class="tok-kw">and</span> is_gnu) {</span>
<span class="line" id="L173">            <span class="tok-kw">const</span> err = std.c.pthread_getname_np(self.getHandle(), buffer.ptr, max_name_len + <span class="tok-number">1</span>);</span>
<span class="line" id="L174">            <span class="tok-kw">switch</span> (err) {</span>
<span class="line" id="L175">                .SUCCESS =&gt; <span class="tok-kw">return</span> std.mem.sliceTo(buffer, <span class="tok-number">0</span>),</span>
<span class="line" id="L176">                .RANGE =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L177">                <span class="tok-kw">else</span> =&gt; |e| <span class="tok-kw">return</span> os.unexpectedErrno(e),</span>
<span class="line" id="L178">            }</span>
<span class="line" id="L179">        } <span class="tok-kw">else</span> <span class="tok-kw">if</span> (use_pthreads <span class="tok-kw">and</span> self.getHandle() == std.c.pthread_self()) {</span>
<span class="line" id="L180">            <span class="tok-kw">const</span> err = <span class="tok-kw">try</span> os.prctl(.GET_NAME, .{<span class="tok-builtin">@ptrToInt</span>(buffer.ptr)});</span>
<span class="line" id="L181">            <span class="tok-kw">switch</span> (<span class="tok-builtin">@intToEnum</span>(os.E, err)) {</span>
<span class="line" id="L182">                .SUCCESS =&gt; <span class="tok-kw">return</span> std.mem.sliceTo(buffer, <span class="tok-number">0</span>),</span>
<span class="line" id="L183">                <span class="tok-kw">else</span> =&gt; |e| <span class="tok-kw">return</span> os.unexpectedErrno(e),</span>
<span class="line" id="L184">            }</span>
<span class="line" id="L185">        } <span class="tok-kw">else</span> <span class="tok-kw">if</span> (!use_pthreads) {</span>
<span class="line" id="L186">            <span class="tok-kw">var</span> buf: [<span class="tok-number">32</span>]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L187">            <span class="tok-kw">const</span> path = <span class="tok-kw">try</span> std.fmt.bufPrint(&amp;buf, <span class="tok-str">&quot;/proc/self/task/{d}/comm&quot;</span>, .{self.getHandle()});</span>
<span class="line" id="L188"></span>
<span class="line" id="L189">            <span class="tok-kw">const</span> file = <span class="tok-kw">try</span> std.fs.cwd().openFile(path, .{});</span>
<span class="line" id="L190">            <span class="tok-kw">defer</span> file.close();</span>
<span class="line" id="L191"></span>
<span class="line" id="L192">            <span class="tok-kw">const</span> data_len = <span class="tok-kw">try</span> file.reader().readAll(buffer_ptr[<span class="tok-number">0</span> .. max_name_len + <span class="tok-number">1</span>]);</span>
<span class="line" id="L193"></span>
<span class="line" id="L194">            <span class="tok-kw">return</span> <span class="tok-kw">if</span> (data_len &gt;= <span class="tok-number">1</span>) buffer[<span class="tok-number">0</span> .. data_len - <span class="tok-number">1</span>] <span class="tok-kw">else</span> <span class="tok-null">null</span>;</span>
<span class="line" id="L195">        } <span class="tok-kw">else</span> {</span>
<span class="line" id="L196">            <span class="tok-comment">// musl doesn't provide pthread_getname_np and there's no way to retrieve the thread id of an arbitrary thread.</span>
</span>
<span class="line" id="L197">            <span class="tok-kw">return</span> <span class="tok-kw">error</span>.Unsupported;</span>
<span class="line" id="L198">        },</span>
<span class="line" id="L199">        .windows =&gt; {</span>
<span class="line" id="L200">            <span class="tok-kw">const</span> buf_capacity = <span class="tok-builtin">@sizeOf</span>(os.windows.UNICODE_STRING) + (<span class="tok-builtin">@sizeOf</span>(<span class="tok-type">u16</span>) * max_name_len);</span>
<span class="line" id="L201">            <span class="tok-kw">var</span> buf: [buf_capacity]<span class="tok-type">u8</span> <span class="tok-kw">align</span>(<span class="tok-builtin">@alignOf</span>(os.windows.UNICODE_STRING)) = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L202"></span>
<span class="line" id="L203">            <span class="tok-kw">switch</span> (os.windows.ntdll.NtQueryInformationThread(</span>
<span class="line" id="L204">                self.getHandle(),</span>
<span class="line" id="L205">                .ThreadNameInformation,</span>
<span class="line" id="L206">                &amp;buf,</span>
<span class="line" id="L207">                buf_capacity,</span>
<span class="line" id="L208">                <span class="tok-null">null</span>,</span>
<span class="line" id="L209">            )) {</span>
<span class="line" id="L210">                .SUCCESS =&gt; {</span>
<span class="line" id="L211">                    <span class="tok-kw">const</span> string = <span class="tok-builtin">@ptrCast</span>(*<span class="tok-kw">const</span> os.windows.UNICODE_STRING, &amp;buf);</span>
<span class="line" id="L212">                    <span class="tok-kw">const</span> len = <span class="tok-kw">try</span> std.unicode.utf16leToUtf8(buffer, string.Buffer[<span class="tok-number">0</span> .. string.Length / <span class="tok-number">2</span>]);</span>
<span class="line" id="L213">                    <span class="tok-kw">return</span> <span class="tok-kw">if</span> (len &gt; <span class="tok-number">0</span>) buffer[<span class="tok-number">0</span>..len] <span class="tok-kw">else</span> <span class="tok-null">null</span>;</span>
<span class="line" id="L214">                },</span>
<span class="line" id="L215">                .NOT_IMPLEMENTED =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.Unsupported,</span>
<span class="line" id="L216">                <span class="tok-kw">else</span> =&gt; |err| <span class="tok-kw">return</span> os.windows.unexpectedStatus(err),</span>
<span class="line" id="L217">            }</span>
<span class="line" id="L218">        },</span>
<span class="line" id="L219">        .macos, .ios, .watchos, .tvos =&gt; <span class="tok-kw">if</span> (use_pthreads) {</span>
<span class="line" id="L220">            <span class="tok-kw">const</span> err = std.c.pthread_getname_np(self.getHandle(), buffer.ptr, max_name_len + <span class="tok-number">1</span>);</span>
<span class="line" id="L221">            <span class="tok-kw">switch</span> (err) {</span>
<span class="line" id="L222">                .SUCCESS =&gt; <span class="tok-kw">return</span> std.mem.sliceTo(buffer, <span class="tok-number">0</span>),</span>
<span class="line" id="L223">                .SRCH =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L224">                <span class="tok-kw">else</span> =&gt; |e| <span class="tok-kw">return</span> os.unexpectedErrno(e),</span>
<span class="line" id="L225">            }</span>
<span class="line" id="L226">        },</span>
<span class="line" id="L227">        .netbsd, .solaris =&gt; <span class="tok-kw">if</span> (use_pthreads) {</span>
<span class="line" id="L228">            <span class="tok-kw">const</span> err = std.c.pthread_getname_np(self.getHandle(), buffer.ptr, max_name_len + <span class="tok-number">1</span>);</span>
<span class="line" id="L229">            <span class="tok-kw">switch</span> (err) {</span>
<span class="line" id="L230">                .SUCCESS =&gt; <span class="tok-kw">return</span> std.mem.sliceTo(buffer, <span class="tok-number">0</span>),</span>
<span class="line" id="L231">                .INVAL =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L232">                .SRCH =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L233">                <span class="tok-kw">else</span> =&gt; |e| <span class="tok-kw">return</span> os.unexpectedErrno(e),</span>
<span class="line" id="L234">            }</span>
<span class="line" id="L235">        },</span>
<span class="line" id="L236">        .freebsd, .openbsd =&gt; <span class="tok-kw">if</span> (use_pthreads) {</span>
<span class="line" id="L237">            <span class="tok-comment">// Use pthread_get_name_np for FreeBSD because pthread_getname_np is FreeBSD 12.2+ only.</span>
</span>
<span class="line" id="L238">            <span class="tok-comment">// TODO maybe revisit this if depending on FreeBSD 12.2+ is acceptable because pthread_getname_np can return an error.</span>
</span>
<span class="line" id="L239"></span>
<span class="line" id="L240">            std.c.pthread_get_name_np(self.getHandle(), buffer.ptr, max_name_len + <span class="tok-number">1</span>);</span>
<span class="line" id="L241">            <span class="tok-kw">return</span> std.mem.sliceTo(buffer, <span class="tok-number">0</span>);</span>
<span class="line" id="L242">        },</span>
<span class="line" id="L243">        .dragonfly =&gt; <span class="tok-kw">if</span> (use_pthreads) {</span>
<span class="line" id="L244">            <span class="tok-kw">const</span> err = std.c.pthread_getname_np(self.getHandle(), buffer.ptr, max_name_len + <span class="tok-number">1</span>);</span>
<span class="line" id="L245">            <span class="tok-kw">switch</span> (err) {</span>
<span class="line" id="L246">                .SUCCESS =&gt; <span class="tok-kw">return</span> std.mem.sliceTo(buffer, <span class="tok-number">0</span>),</span>
<span class="line" id="L247">                .INVAL =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L248">                .FAULT =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L249">                .SRCH =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L250">                <span class="tok-kw">else</span> =&gt; |e| <span class="tok-kw">return</span> os.unexpectedErrno(e),</span>
<span class="line" id="L251">            }</span>
<span class="line" id="L252">        },</span>
<span class="line" id="L253">        <span class="tok-kw">else</span> =&gt; {},</span>
<span class="line" id="L254">    }</span>
<span class="line" id="L255">    <span class="tok-kw">return</span> <span class="tok-kw">error</span>.Unsupported;</span>
<span class="line" id="L256">}</span>
<span class="line" id="L257"></span>
<span class="line" id="L258"><span class="tok-comment">/// Represents a unique ID per thread.</span></span>
<span class="line" id="L259"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> Id = <span class="tok-type">u64</span>;</span>
<span class="line" id="L260"></span>
<span class="line" id="L261"><span class="tok-comment">/// Returns the platform ID of the callers thread.</span></span>
<span class="line" id="L262"><span class="tok-comment">/// Attempts to use thread locals and avoid syscalls when possible.</span></span>
<span class="line" id="L263"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">getCurrentId</span>() Id {</span>
<span class="line" id="L264">    <span class="tok-kw">return</span> Impl.getCurrentId();</span>
<span class="line" id="L265">}</span>
<span class="line" id="L266"></span>
<span class="line" id="L267"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> CpuCountError = <span class="tok-kw">error</span>{</span>
<span class="line" id="L268">    PermissionDenied,</span>
<span class="line" id="L269">    SystemResources,</span>
<span class="line" id="L270">    Unexpected,</span>
<span class="line" id="L271">};</span>
<span class="line" id="L272"></span>
<span class="line" id="L273"><span class="tok-comment">/// Returns the platforms view on the number of logical CPU cores available.</span></span>
<span class="line" id="L274"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">getCpuCount</span>() CpuCountError!<span class="tok-type">usize</span> {</span>
<span class="line" id="L275">    <span class="tok-kw">return</span> Impl.getCpuCount();</span>
<span class="line" id="L276">}</span>
<span class="line" id="L277"></span>
<span class="line" id="L278"><span class="tok-comment">/// Configuration options for hints on how to spawn threads.</span></span>
<span class="line" id="L279"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> SpawnConfig = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L280">    <span class="tok-comment">// TODO compile-time call graph analysis to determine stack upper bound</span>
</span>
<span class="line" id="L281">    <span class="tok-comment">// https://github.com/ziglang/zig/issues/157</span>
</span>
<span class="line" id="L282"></span>
<span class="line" id="L283">    <span class="tok-comment">/// Size in bytes of the Thread's stack</span></span>
<span class="line" id="L284">    stack_size: <span class="tok-type">usize</span> = <span class="tok-number">16</span> * <span class="tok-number">1024</span> * <span class="tok-number">1024</span>,</span>
<span class="line" id="L285">};</span>
<span class="line" id="L286"></span>
<span class="line" id="L287"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> SpawnError = <span class="tok-kw">error</span>{</span>
<span class="line" id="L288">    <span class="tok-comment">/// A system-imposed limit on the number of threads was encountered.</span></span>
<span class="line" id="L289">    <span class="tok-comment">/// There are a number of limits that may trigger this error:</span></span>
<span class="line" id="L290">    <span class="tok-comment">/// *  the  RLIMIT_NPROC soft resource limit (set via setrlimit(2)),</span></span>
<span class="line" id="L291">    <span class="tok-comment">///    which limits the number of processes and threads for  a  real</span></span>
<span class="line" id="L292">    <span class="tok-comment">///    user ID, was reached;</span></span>
<span class="line" id="L293">    <span class="tok-comment">/// *  the kernel's system-wide limit on the number of processes and</span></span>
<span class="line" id="L294">    <span class="tok-comment">///    threads,  /proc/sys/kernel/threads-max,  was   reached   (see</span></span>
<span class="line" id="L295">    <span class="tok-comment">///    proc(5));</span></span>
<span class="line" id="L296">    <span class="tok-comment">/// *  the  maximum  number  of  PIDs, /proc/sys/kernel/pid_max, was</span></span>
<span class="line" id="L297">    <span class="tok-comment">///    reached (see proc(5)); or</span></span>
<span class="line" id="L298">    <span class="tok-comment">/// *  the PID limit (pids.max) imposed by the cgroup &quot;process  num‐</span></span>
<span class="line" id="L299">    <span class="tok-comment">///    ber&quot; (PIDs) controller was reached.</span></span>
<span class="line" id="L300">    ThreadQuotaExceeded,</span>
<span class="line" id="L301"></span>
<span class="line" id="L302">    <span class="tok-comment">/// The kernel cannot allocate sufficient memory to allocate a task structure</span></span>
<span class="line" id="L303">    <span class="tok-comment">/// for the child, or to copy those parts of the caller's context that need to</span></span>
<span class="line" id="L304">    <span class="tok-comment">/// be copied.</span></span>
<span class="line" id="L305">    SystemResources,</span>
<span class="line" id="L306"></span>
<span class="line" id="L307">    <span class="tok-comment">/// Not enough userland memory to spawn the thread.</span></span>
<span class="line" id="L308">    OutOfMemory,</span>
<span class="line" id="L309"></span>
<span class="line" id="L310">    <span class="tok-comment">/// `mlockall` is enabled, and the memory needed to spawn the thread</span></span>
<span class="line" id="L311">    <span class="tok-comment">/// would exceed the limit.</span></span>
<span class="line" id="L312">    LockedMemoryLimitExceeded,</span>
<span class="line" id="L313"></span>
<span class="line" id="L314">    Unexpected,</span>
<span class="line" id="L315">};</span>
<span class="line" id="L316"></span>
<span class="line" id="L317"><span class="tok-comment">/// Spawns a new thread which executes `function` using `args` and returns a handle the spawned thread.</span></span>
<span class="line" id="L318"><span class="tok-comment">/// `config` can be used as hints to the platform for now to spawn and execute the `function`.</span></span>
<span class="line" id="L319"><span class="tok-comment">/// The caller must eventually either call `join()` to wait for the thread to finish and free its resources</span></span>
<span class="line" id="L320"><span class="tok-comment">/// or call `detach()` to excuse the caller from calling `join()` and have the thread clean up its resources on completion`.</span></span>
<span class="line" id="L321"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">spawn</span>(config: SpawnConfig, <span class="tok-kw">comptime</span> function: <span class="tok-kw">anytype</span>, args: <span class="tok-kw">anytype</span>) SpawnError!Thread {</span>
<span class="line" id="L322">    <span class="tok-kw">if</span> (builtin.single_threaded) {</span>
<span class="line" id="L323">        <span class="tok-builtin">@compileError</span>(<span class="tok-str">&quot;Cannot spawn thread when building in single-threaded mode&quot;</span>);</span>
<span class="line" id="L324">    }</span>
<span class="line" id="L325"></span>
<span class="line" id="L326">    <span class="tok-kw">const</span> impl = <span class="tok-kw">try</span> Impl.spawn(config, function, args);</span>
<span class="line" id="L327">    <span class="tok-kw">return</span> Thread{ .impl = impl };</span>
<span class="line" id="L328">}</span>
<span class="line" id="L329"></span>
<span class="line" id="L330"><span class="tok-comment">/// Represents a kernel thread handle.</span></span>
<span class="line" id="L331"><span class="tok-comment">/// May be an integer or a pointer depending on the platform.</span></span>
<span class="line" id="L332"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> Handle = Impl.ThreadHandle;</span>
<span class="line" id="L333"></span>
<span class="line" id="L334"><span class="tok-comment">/// Returns the handle of this thread</span></span>
<span class="line" id="L335"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">getHandle</span>(self: Thread) Handle {</span>
<span class="line" id="L336">    <span class="tok-kw">return</span> self.impl.getHandle();</span>
<span class="line" id="L337">}</span>
<span class="line" id="L338"></span>
<span class="line" id="L339"><span class="tok-comment">/// Release the obligation of the caller to call `join()` and have the thread clean up its own resources on completion.</span></span>
<span class="line" id="L340"><span class="tok-comment">/// Once called, this consumes the Thread object and invoking any other functions on it is considered undefined behavior.</span></span>
<span class="line" id="L341"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">detach</span>(self: Thread) <span class="tok-type">void</span> {</span>
<span class="line" id="L342">    <span class="tok-kw">return</span> self.impl.detach();</span>
<span class="line" id="L343">}</span>
<span class="line" id="L344"></span>
<span class="line" id="L345"><span class="tok-comment">/// Waits for the thread to complete, then deallocates any resources created on `spawn()`.</span></span>
<span class="line" id="L346"><span class="tok-comment">/// Once called, this consumes the Thread object and invoking any other functions on it is considered undefined behavior.</span></span>
<span class="line" id="L347"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">join</span>(self: Thread) <span class="tok-type">void</span> {</span>
<span class="line" id="L348">    <span class="tok-kw">return</span> self.impl.join();</span>
<span class="line" id="L349">}</span>
<span class="line" id="L350"></span>
<span class="line" id="L351"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> YieldError = <span class="tok-kw">error</span>{</span>
<span class="line" id="L352">    <span class="tok-comment">/// The system is not configured to allow yielding</span></span>
<span class="line" id="L353">    SystemCannotYield,</span>
<span class="line" id="L354">};</span>
<span class="line" id="L355"></span>
<span class="line" id="L356"><span class="tok-comment">/// Yields the current thread potentially allowing other threads to run.</span></span>
<span class="line" id="L357"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">yield</span>() YieldError!<span class="tok-type">void</span> {</span>
<span class="line" id="L358">    <span class="tok-kw">if</span> (builtin.os.tag == .windows) {</span>
<span class="line" id="L359">        <span class="tok-comment">// The return value has to do with how many other threads there are; it is not</span>
</span>
<span class="line" id="L360">        <span class="tok-comment">// an error condition on Windows.</span>
</span>
<span class="line" id="L361">        _ = os.windows.kernel32.SwitchToThread();</span>
<span class="line" id="L362">        <span class="tok-kw">return</span>;</span>
<span class="line" id="L363">    }</span>
<span class="line" id="L364">    <span class="tok-kw">switch</span> (os.errno(os.system.sched_yield())) {</span>
<span class="line" id="L365">        .SUCCESS =&gt; <span class="tok-kw">return</span>,</span>
<span class="line" id="L366">        .NOSYS =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.SystemCannotYield,</span>
<span class="line" id="L367">        <span class="tok-kw">else</span> =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.SystemCannotYield,</span>
<span class="line" id="L368">    }</span>
<span class="line" id="L369">}</span>
<span class="line" id="L370"></span>
<span class="line" id="L371"><span class="tok-comment">/// State to synchronize detachment of spawner thread to spawned thread</span></span>
<span class="line" id="L372"><span class="tok-kw">const</span> Completion = Atomic(<span class="tok-kw">enum</span>(<span class="tok-type">u8</span>) {</span>
<span class="line" id="L373">    running,</span>
<span class="line" id="L374">    detached,</span>
<span class="line" id="L375">    completed,</span>
<span class="line" id="L376">});</span>
<span class="line" id="L377"></span>
<span class="line" id="L378"><span class="tok-comment">/// Used by the Thread implementations to call the spawned function with the arguments.</span></span>
<span class="line" id="L379"><span class="tok-kw">fn</span> <span class="tok-fn">callFn</span>(<span class="tok-kw">comptime</span> f: <span class="tok-kw">anytype</span>, args: <span class="tok-kw">anytype</span>) <span class="tok-kw">switch</span> (Impl) {</span>
<span class="line" id="L380">    WindowsThreadImpl =&gt; std.os.windows.DWORD,</span>
<span class="line" id="L381">    LinuxThreadImpl =&gt; <span class="tok-type">u8</span>,</span>
<span class="line" id="L382">    PosixThreadImpl =&gt; ?*<span class="tok-type">anyopaque</span>,</span>
<span class="line" id="L383">    <span class="tok-kw">else</span> =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L384">} {</span>
<span class="line" id="L385">    <span class="tok-kw">const</span> default_value = <span class="tok-kw">if</span> (Impl == PosixThreadImpl) <span class="tok-null">null</span> <span class="tok-kw">else</span> <span class="tok-number">0</span>;</span>
<span class="line" id="L386">    <span class="tok-kw">const</span> bad_fn_ret = <span class="tok-str">&quot;expected return type of startFn to be 'u8', 'noreturn', 'void', or '!void'&quot;</span>;</span>
<span class="line" id="L387"></span>
<span class="line" id="L388">    <span class="tok-kw">switch</span> (<span class="tok-builtin">@typeInfo</span>(<span class="tok-builtin">@typeInfo</span>(<span class="tok-builtin">@TypeOf</span>(f)).Fn.return_type.?)) {</span>
<span class="line" id="L389">        .NoReturn =&gt; {</span>
<span class="line" id="L390">            <span class="tok-builtin">@call</span>(.{}, f, args);</span>
<span class="line" id="L391">        },</span>
<span class="line" id="L392">        .Void =&gt; {</span>
<span class="line" id="L393">            <span class="tok-builtin">@call</span>(.{}, f, args);</span>
<span class="line" id="L394">            <span class="tok-kw">return</span> default_value;</span>
<span class="line" id="L395">        },</span>
<span class="line" id="L396">        .Int =&gt; |info| {</span>
<span class="line" id="L397">            <span class="tok-kw">if</span> (info.bits != <span class="tok-number">8</span>) {</span>
<span class="line" id="L398">                <span class="tok-builtin">@compileError</span>(bad_fn_ret);</span>
<span class="line" id="L399">            }</span>
<span class="line" id="L400"></span>
<span class="line" id="L401">            <span class="tok-kw">const</span> status = <span class="tok-builtin">@call</span>(.{}, f, args);</span>
<span class="line" id="L402">            <span class="tok-kw">if</span> (Impl != PosixThreadImpl) {</span>
<span class="line" id="L403">                <span class="tok-kw">return</span> status;</span>
<span class="line" id="L404">            }</span>
<span class="line" id="L405"></span>
<span class="line" id="L406">            <span class="tok-comment">// pthreads don't support exit status, ignore value</span>
</span>
<span class="line" id="L407">            _ = status;</span>
<span class="line" id="L408">            <span class="tok-kw">return</span> default_value;</span>
<span class="line" id="L409">        },</span>
<span class="line" id="L410">        .ErrorUnion =&gt; |info| {</span>
<span class="line" id="L411">            <span class="tok-kw">if</span> (info.payload != <span class="tok-type">void</span>) {</span>
<span class="line" id="L412">                <span class="tok-builtin">@compileError</span>(bad_fn_ret);</span>
<span class="line" id="L413">            }</span>
<span class="line" id="L414"></span>
<span class="line" id="L415">            <span class="tok-builtin">@call</span>(.{}, f, args) <span class="tok-kw">catch</span> |err| {</span>
<span class="line" id="L416">                std.debug.print(<span class="tok-str">&quot;error: {s}\n&quot;</span>, .{<span class="tok-builtin">@errorName</span>(err)});</span>
<span class="line" id="L417">                <span class="tok-kw">if</span> (<span class="tok-builtin">@errorReturnTrace</span>()) |trace| {</span>
<span class="line" id="L418">                    std.debug.dumpStackTrace(trace.*);</span>
<span class="line" id="L419">                }</span>
<span class="line" id="L420">            };</span>
<span class="line" id="L421"></span>
<span class="line" id="L422">            <span class="tok-kw">return</span> default_value;</span>
<span class="line" id="L423">        },</span>
<span class="line" id="L424">        <span class="tok-kw">else</span> =&gt; {</span>
<span class="line" id="L425">            <span class="tok-builtin">@compileError</span>(bad_fn_ret);</span>
<span class="line" id="L426">        },</span>
<span class="line" id="L427">    }</span>
<span class="line" id="L428">}</span>
<span class="line" id="L429"></span>
<span class="line" id="L430"><span class="tok-comment">/// We can't compile error in the `Impl` switch statement as its eagerly evaluated.</span></span>
<span class="line" id="L431"><span class="tok-comment">/// So instead, we compile-error on the methods themselves for platforms which don't support threads.</span></span>
<span class="line" id="L432"><span class="tok-kw">const</span> UnsupportedImpl = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L433">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> ThreadHandle = <span class="tok-type">void</span>;</span>
<span class="line" id="L434"></span>
<span class="line" id="L435">    <span class="tok-kw">fn</span> <span class="tok-fn">getCurrentId</span>() <span class="tok-type">u64</span> {</span>
<span class="line" id="L436">        <span class="tok-kw">return</span> unsupported({});</span>
<span class="line" id="L437">    }</span>
<span class="line" id="L438"></span>
<span class="line" id="L439">    <span class="tok-kw">fn</span> <span class="tok-fn">getCpuCount</span>() !<span class="tok-type">usize</span> {</span>
<span class="line" id="L440">        <span class="tok-kw">return</span> unsupported({});</span>
<span class="line" id="L441">    }</span>
<span class="line" id="L442"></span>
<span class="line" id="L443">    <span class="tok-kw">fn</span> <span class="tok-fn">spawn</span>(config: SpawnConfig, <span class="tok-kw">comptime</span> f: <span class="tok-kw">anytype</span>, args: <span class="tok-kw">anytype</span>) !Impl {</span>
<span class="line" id="L444">        <span class="tok-kw">return</span> unsupported(.{ config, f, args });</span>
<span class="line" id="L445">    }</span>
<span class="line" id="L446"></span>
<span class="line" id="L447">    <span class="tok-kw">fn</span> <span class="tok-fn">getHandle</span>(self: Impl) ThreadHandle {</span>
<span class="line" id="L448">        <span class="tok-kw">return</span> unsupported(self);</span>
<span class="line" id="L449">    }</span>
<span class="line" id="L450"></span>
<span class="line" id="L451">    <span class="tok-kw">fn</span> <span class="tok-fn">detach</span>(self: Impl) <span class="tok-type">void</span> {</span>
<span class="line" id="L452">        <span class="tok-kw">return</span> unsupported(self);</span>
<span class="line" id="L453">    }</span>
<span class="line" id="L454"></span>
<span class="line" id="L455">    <span class="tok-kw">fn</span> <span class="tok-fn">join</span>(self: Impl) <span class="tok-type">void</span> {</span>
<span class="line" id="L456">        <span class="tok-kw">return</span> unsupported(self);</span>
<span class="line" id="L457">    }</span>
<span class="line" id="L458"></span>
<span class="line" id="L459">    <span class="tok-kw">fn</span> <span class="tok-fn">unsupported</span>(unusued: <span class="tok-kw">anytype</span>) <span class="tok-type">noreturn</span> {</span>
<span class="line" id="L460">        _ = unusued;</span>
<span class="line" id="L461">        <span class="tok-builtin">@compileError</span>(<span class="tok-str">&quot;Unsupported operating system &quot;</span> ++ <span class="tok-builtin">@tagName</span>(target.os.tag));</span>
<span class="line" id="L462">    }</span>
<span class="line" id="L463">};</span>
<span class="line" id="L464"></span>
<span class="line" id="L465"><span class="tok-kw">const</span> WindowsThreadImpl = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L466">    <span class="tok-kw">const</span> windows = os.windows;</span>
<span class="line" id="L467"></span>
<span class="line" id="L468">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> ThreadHandle = windows.HANDLE;</span>
<span class="line" id="L469"></span>
<span class="line" id="L470">    <span class="tok-kw">fn</span> <span class="tok-fn">getCurrentId</span>() <span class="tok-type">u64</span> {</span>
<span class="line" id="L471">        <span class="tok-kw">return</span> windows.kernel32.GetCurrentThreadId();</span>
<span class="line" id="L472">    }</span>
<span class="line" id="L473"></span>
<span class="line" id="L474">    <span class="tok-kw">fn</span> <span class="tok-fn">getCpuCount</span>() !<span class="tok-type">usize</span> {</span>
<span class="line" id="L475">        <span class="tok-comment">// Faster than calling into GetSystemInfo(), even if amortized.</span>
</span>
<span class="line" id="L476">        <span class="tok-kw">return</span> windows.peb().NumberOfProcessors;</span>
<span class="line" id="L477">    }</span>
<span class="line" id="L478"></span>
<span class="line" id="L479">    thread: *ThreadCompletion,</span>
<span class="line" id="L480"></span>
<span class="line" id="L481">    <span class="tok-kw">const</span> ThreadCompletion = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L482">        completion: Completion,</span>
<span class="line" id="L483">        heap_ptr: windows.PVOID,</span>
<span class="line" id="L484">        heap_handle: windows.HANDLE,</span>
<span class="line" id="L485">        thread_handle: windows.HANDLE = <span class="tok-null">undefined</span>,</span>
<span class="line" id="L486"></span>
<span class="line" id="L487">        <span class="tok-kw">fn</span> <span class="tok-fn">free</span>(self: ThreadCompletion) <span class="tok-type">void</span> {</span>
<span class="line" id="L488">            <span class="tok-kw">const</span> status = windows.kernel32.HeapFree(self.heap_handle, <span class="tok-number">0</span>, self.heap_ptr);</span>
<span class="line" id="L489">            assert(status != <span class="tok-number">0</span>);</span>
<span class="line" id="L490">        }</span>
<span class="line" id="L491">    };</span>
<span class="line" id="L492"></span>
<span class="line" id="L493">    <span class="tok-kw">fn</span> <span class="tok-fn">spawn</span>(config: SpawnConfig, <span class="tok-kw">comptime</span> f: <span class="tok-kw">anytype</span>, args: <span class="tok-kw">anytype</span>) !Impl {</span>
<span class="line" id="L494">        <span class="tok-kw">const</span> Args = <span class="tok-builtin">@TypeOf</span>(args);</span>
<span class="line" id="L495">        <span class="tok-kw">const</span> Instance = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L496">            fn_args: Args,</span>
<span class="line" id="L497">            thread: ThreadCompletion,</span>
<span class="line" id="L498"></span>
<span class="line" id="L499">            <span class="tok-kw">fn</span> <span class="tok-fn">entryFn</span>(raw_ptr: windows.PVOID) <span class="tok-kw">callconv</span>(.C) windows.DWORD {</span>
<span class="line" id="L500">                <span class="tok-kw">const</span> self = <span class="tok-builtin">@ptrCast</span>(*<span class="tok-builtin">@This</span>(), <span class="tok-builtin">@alignCast</span>(<span class="tok-builtin">@alignOf</span>(<span class="tok-builtin">@This</span>()), raw_ptr));</span>
<span class="line" id="L501">                <span class="tok-kw">defer</span> <span class="tok-kw">switch</span> (self.thread.completion.swap(.completed, .SeqCst)) {</span>
<span class="line" id="L502">                    .running =&gt; {},</span>
<span class="line" id="L503">                    .completed =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L504">                    .detached =&gt; self.thread.free(),</span>
<span class="line" id="L505">                };</span>
<span class="line" id="L506">                <span class="tok-kw">return</span> callFn(f, self.fn_args);</span>
<span class="line" id="L507">            }</span>
<span class="line" id="L508">        };</span>
<span class="line" id="L509"></span>
<span class="line" id="L510">        <span class="tok-kw">const</span> heap_handle = windows.kernel32.GetProcessHeap() <span class="tok-kw">orelse</span> <span class="tok-kw">return</span> <span class="tok-kw">error</span>.OutOfMemory;</span>
<span class="line" id="L511">        <span class="tok-kw">const</span> alloc_bytes = <span class="tok-builtin">@alignOf</span>(Instance) + <span class="tok-builtin">@sizeOf</span>(Instance);</span>
<span class="line" id="L512">        <span class="tok-kw">const</span> alloc_ptr = windows.kernel32.HeapAlloc(heap_handle, <span class="tok-number">0</span>, alloc_bytes) <span class="tok-kw">orelse</span> <span class="tok-kw">return</span> <span class="tok-kw">error</span>.OutOfMemory;</span>
<span class="line" id="L513">        <span class="tok-kw">errdefer</span> assert(windows.kernel32.HeapFree(heap_handle, <span class="tok-number">0</span>, alloc_ptr) != <span class="tok-number">0</span>);</span>
<span class="line" id="L514"></span>
<span class="line" id="L515">        <span class="tok-kw">const</span> instance_bytes = <span class="tok-builtin">@ptrCast</span>([*]<span class="tok-type">u8</span>, alloc_ptr)[<span class="tok-number">0</span>..alloc_bytes];</span>
<span class="line" id="L516">        <span class="tok-kw">var</span> fba = std.heap.FixedBufferAllocator.init(instance_bytes);</span>
<span class="line" id="L517">        <span class="tok-kw">const</span> instance = fba.allocator().create(Instance) <span class="tok-kw">catch</span> <span class="tok-kw">unreachable</span>;</span>
<span class="line" id="L518">        instance.* = .{</span>
<span class="line" id="L519">            .fn_args = args,</span>
<span class="line" id="L520">            .thread = .{</span>
<span class="line" id="L521">                .completion = Completion.init(.running),</span>
<span class="line" id="L522">                .heap_ptr = alloc_ptr,</span>
<span class="line" id="L523">                .heap_handle = heap_handle,</span>
<span class="line" id="L524">            },</span>
<span class="line" id="L525">        };</span>
<span class="line" id="L526"></span>
<span class="line" id="L527">        <span class="tok-comment">// Windows appears to only support SYSTEM_INFO.dwAllocationGranularity minimum stack size.</span>
</span>
<span class="line" id="L528">        <span class="tok-comment">// Going lower makes it default to that specified in the executable (~1mb).</span>
</span>
<span class="line" id="L529">        <span class="tok-comment">// Its also fine if the limit here is incorrect as stack size is only a hint.</span>
</span>
<span class="line" id="L530">        <span class="tok-kw">var</span> stack_size = std.math.cast(<span class="tok-type">u32</span>, config.stack_size) <span class="tok-kw">orelse</span> std.math.maxInt(<span class="tok-type">u32</span>);</span>
<span class="line" id="L531">        stack_size = std.math.max(<span class="tok-number">64</span> * <span class="tok-number">1024</span>, stack_size);</span>
<span class="line" id="L532"></span>
<span class="line" id="L533">        instance.thread.thread_handle = windows.kernel32.CreateThread(</span>
<span class="line" id="L534">            <span class="tok-null">null</span>,</span>
<span class="line" id="L535">            stack_size,</span>
<span class="line" id="L536">            Instance.entryFn,</span>
<span class="line" id="L537">            <span class="tok-builtin">@ptrCast</span>(*<span class="tok-type">anyopaque</span>, instance),</span>
<span class="line" id="L538">            <span class="tok-number">0</span>,</span>
<span class="line" id="L539">            <span class="tok-null">null</span>,</span>
<span class="line" id="L540">        ) <span class="tok-kw">orelse</span> {</span>
<span class="line" id="L541">            <span class="tok-kw">const</span> errno = windows.kernel32.GetLastError();</span>
<span class="line" id="L542">            <span class="tok-kw">return</span> windows.unexpectedError(errno);</span>
<span class="line" id="L543">        };</span>
<span class="line" id="L544"></span>
<span class="line" id="L545">        <span class="tok-kw">return</span> Impl{ .thread = &amp;instance.thread };</span>
<span class="line" id="L546">    }</span>
<span class="line" id="L547"></span>
<span class="line" id="L548">    <span class="tok-kw">fn</span> <span class="tok-fn">getHandle</span>(self: Impl) ThreadHandle {</span>
<span class="line" id="L549">        <span class="tok-kw">return</span> self.thread.thread_handle;</span>
<span class="line" id="L550">    }</span>
<span class="line" id="L551"></span>
<span class="line" id="L552">    <span class="tok-kw">fn</span> <span class="tok-fn">detach</span>(self: Impl) <span class="tok-type">void</span> {</span>
<span class="line" id="L553">        windows.CloseHandle(self.thread.thread_handle);</span>
<span class="line" id="L554">        <span class="tok-kw">switch</span> (self.thread.completion.swap(.detached, .SeqCst)) {</span>
<span class="line" id="L555">            .running =&gt; {},</span>
<span class="line" id="L556">            .completed =&gt; self.thread.free(),</span>
<span class="line" id="L557">            .detached =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L558">        }</span>
<span class="line" id="L559">    }</span>
<span class="line" id="L560"></span>
<span class="line" id="L561">    <span class="tok-kw">fn</span> <span class="tok-fn">join</span>(self: Impl) <span class="tok-type">void</span> {</span>
<span class="line" id="L562">        windows.WaitForSingleObjectEx(self.thread.thread_handle, windows.INFINITE, <span class="tok-null">false</span>) <span class="tok-kw">catch</span> <span class="tok-kw">unreachable</span>;</span>
<span class="line" id="L563">        windows.CloseHandle(self.thread.thread_handle);</span>
<span class="line" id="L564">        assert(self.thread.completion.load(.SeqCst) == .completed);</span>
<span class="line" id="L565">        self.thread.free();</span>
<span class="line" id="L566">    }</span>
<span class="line" id="L567">};</span>
<span class="line" id="L568"></span>
<span class="line" id="L569"><span class="tok-kw">const</span> PosixThreadImpl = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L570">    <span class="tok-kw">const</span> c = std.c;</span>
<span class="line" id="L571"></span>
<span class="line" id="L572">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> ThreadHandle = c.pthread_t;</span>
<span class="line" id="L573"></span>
<span class="line" id="L574">    <span class="tok-kw">fn</span> <span class="tok-fn">getCurrentId</span>() Id {</span>
<span class="line" id="L575">        <span class="tok-kw">switch</span> (target.os.tag) {</span>
<span class="line" id="L576">            .linux =&gt; {</span>
<span class="line" id="L577">                <span class="tok-kw">return</span> LinuxThreadImpl.getCurrentId();</span>
<span class="line" id="L578">            },</span>
<span class="line" id="L579">            .macos, .ios, .watchos, .tvos =&gt; {</span>
<span class="line" id="L580">                <span class="tok-kw">var</span> thread_id: <span class="tok-type">u64</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L581">                <span class="tok-comment">// Pass thread=null to get the current thread ID.</span>
</span>
<span class="line" id="L582">                assert(c.pthread_threadid_np(<span class="tok-null">null</span>, &amp;thread_id) == <span class="tok-number">0</span>);</span>
<span class="line" id="L583">                <span class="tok-kw">return</span> thread_id;</span>
<span class="line" id="L584">            },</span>
<span class="line" id="L585">            .dragonfly =&gt; {</span>
<span class="line" id="L586">                <span class="tok-kw">return</span> <span class="tok-builtin">@bitCast</span>(<span class="tok-type">u32</span>, c.lwp_gettid());</span>
<span class="line" id="L587">            },</span>
<span class="line" id="L588">            .netbsd =&gt; {</span>
<span class="line" id="L589">                <span class="tok-kw">return</span> <span class="tok-builtin">@bitCast</span>(<span class="tok-type">u32</span>, c._lwp_self());</span>
<span class="line" id="L590">            },</span>
<span class="line" id="L591">            .freebsd =&gt; {</span>
<span class="line" id="L592">                <span class="tok-kw">return</span> <span class="tok-builtin">@bitCast</span>(<span class="tok-type">u32</span>, c.pthread_getthreadid_np());</span>
<span class="line" id="L593">            },</span>
<span class="line" id="L594">            .openbsd =&gt; {</span>
<span class="line" id="L595">                <span class="tok-kw">return</span> <span class="tok-builtin">@bitCast</span>(<span class="tok-type">u32</span>, c.getthrid());</span>
<span class="line" id="L596">            },</span>
<span class="line" id="L597">            .haiku =&gt; {</span>
<span class="line" id="L598">                <span class="tok-kw">return</span> <span class="tok-builtin">@bitCast</span>(<span class="tok-type">u32</span>, c.find_thread(<span class="tok-null">null</span>));</span>
<span class="line" id="L599">            },</span>
<span class="line" id="L600">            <span class="tok-kw">else</span> =&gt; {</span>
<span class="line" id="L601">                <span class="tok-kw">return</span> <span class="tok-builtin">@ptrToInt</span>(c.pthread_self());</span>
<span class="line" id="L602">            },</span>
<span class="line" id="L603">        }</span>
<span class="line" id="L604">    }</span>
<span class="line" id="L605"></span>
<span class="line" id="L606">    <span class="tok-kw">fn</span> <span class="tok-fn">getCpuCount</span>() !<span class="tok-type">usize</span> {</span>
<span class="line" id="L607">        <span class="tok-kw">switch</span> (target.os.tag) {</span>
<span class="line" id="L608">            .linux =&gt; {</span>
<span class="line" id="L609">                <span class="tok-kw">return</span> LinuxThreadImpl.getCpuCount();</span>
<span class="line" id="L610">            },</span>
<span class="line" id="L611">            .openbsd =&gt; {</span>
<span class="line" id="L612">                <span class="tok-kw">var</span> count: <span class="tok-type">c_int</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L613">                <span class="tok-kw">var</span> count_size: <span class="tok-type">usize</span> = <span class="tok-builtin">@sizeOf</span>(<span class="tok-type">c_int</span>);</span>
<span class="line" id="L614">                <span class="tok-kw">const</span> mib = [_]<span class="tok-type">c_int</span>{ os.CTL.HW, os.system.HW_NCPUONLINE };</span>
<span class="line" id="L615">                os.sysctl(&amp;mib, &amp;count, &amp;count_size, <span class="tok-null">null</span>, <span class="tok-number">0</span>) <span class="tok-kw">catch</span> |err| <span class="tok-kw">switch</span> (err) {</span>
<span class="line" id="L616">                    <span class="tok-kw">error</span>.NameTooLong, <span class="tok-kw">error</span>.UnknownName =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L617">                    <span class="tok-kw">else</span> =&gt; |e| <span class="tok-kw">return</span> e,</span>
<span class="line" id="L618">                };</span>
<span class="line" id="L619">                <span class="tok-kw">return</span> <span class="tok-builtin">@intCast</span>(<span class="tok-type">usize</span>, count);</span>
<span class="line" id="L620">            },</span>
<span class="line" id="L621">            .solaris =&gt; {</span>
<span class="line" id="L622">                <span class="tok-comment">// The &quot;proper&quot; way to get the cpu count would be to query</span>
</span>
<span class="line" id="L623">                <span class="tok-comment">// /dev/kstat via ioctls, and traverse a linked list for each</span>
</span>
<span class="line" id="L624">                <span class="tok-comment">// cpu.</span>
</span>
<span class="line" id="L625">                <span class="tok-kw">const</span> rc = c.sysconf(os._SC.NPROCESSORS_ONLN);</span>
<span class="line" id="L626">                <span class="tok-kw">return</span> <span class="tok-kw">switch</span> (os.errno(rc)) {</span>
<span class="line" id="L627">                    .SUCCESS =&gt; <span class="tok-builtin">@intCast</span>(<span class="tok-type">usize</span>, rc),</span>
<span class="line" id="L628">                    <span class="tok-kw">else</span> =&gt; |err| os.unexpectedErrno(err),</span>
<span class="line" id="L629">                };</span>
<span class="line" id="L630">            },</span>
<span class="line" id="L631">            .haiku =&gt; {</span>
<span class="line" id="L632">                <span class="tok-kw">var</span> system_info: os.system.system_info = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L633">                <span class="tok-kw">const</span> rc = os.system.get_system_info(&amp;system_info); <span class="tok-comment">// always returns B_OK</span>
</span>
<span class="line" id="L634">                <span class="tok-kw">return</span> <span class="tok-kw">switch</span> (os.errno(rc)) {</span>
<span class="line" id="L635">                    .SUCCESS =&gt; <span class="tok-builtin">@intCast</span>(<span class="tok-type">usize</span>, system_info.cpu_count),</span>
<span class="line" id="L636">                    <span class="tok-kw">else</span> =&gt; |err| os.unexpectedErrno(err),</span>
<span class="line" id="L637">                };</span>
<span class="line" id="L638">            },</span>
<span class="line" id="L639">            <span class="tok-kw">else</span> =&gt; {</span>
<span class="line" id="L640">                <span class="tok-kw">var</span> count: <span class="tok-type">c_int</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L641">                <span class="tok-kw">var</span> count_len: <span class="tok-type">usize</span> = <span class="tok-builtin">@sizeOf</span>(<span class="tok-type">c_int</span>);</span>
<span class="line" id="L642">                <span class="tok-kw">const</span> name = <span class="tok-kw">if</span> (<span class="tok-kw">comptime</span> target.isDarwin()) <span class="tok-str">&quot;hw.logicalcpu&quot;</span> <span class="tok-kw">else</span> <span class="tok-str">&quot;hw.ncpu&quot;</span>;</span>
<span class="line" id="L643">                os.sysctlbynameZ(name, &amp;count, &amp;count_len, <span class="tok-null">null</span>, <span class="tok-number">0</span>) <span class="tok-kw">catch</span> |err| <span class="tok-kw">switch</span> (err) {</span>
<span class="line" id="L644">                    <span class="tok-kw">error</span>.NameTooLong, <span class="tok-kw">error</span>.UnknownName =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L645">                    <span class="tok-kw">else</span> =&gt; |e| <span class="tok-kw">return</span> e,</span>
<span class="line" id="L646">                };</span>
<span class="line" id="L647">                <span class="tok-kw">return</span> <span class="tok-builtin">@intCast</span>(<span class="tok-type">usize</span>, count);</span>
<span class="line" id="L648">            },</span>
<span class="line" id="L649">        }</span>
<span class="line" id="L650">    }</span>
<span class="line" id="L651"></span>
<span class="line" id="L652">    handle: ThreadHandle,</span>
<span class="line" id="L653"></span>
<span class="line" id="L654">    <span class="tok-kw">fn</span> <span class="tok-fn">spawn</span>(config: SpawnConfig, <span class="tok-kw">comptime</span> f: <span class="tok-kw">anytype</span>, args: <span class="tok-kw">anytype</span>) !Impl {</span>
<span class="line" id="L655">        <span class="tok-kw">const</span> Args = <span class="tok-builtin">@TypeOf</span>(args);</span>
<span class="line" id="L656">        <span class="tok-kw">const</span> allocator = std.heap.c_allocator;</span>
<span class="line" id="L657"></span>
<span class="line" id="L658">        <span class="tok-kw">const</span> Instance = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L659">            <span class="tok-kw">fn</span> <span class="tok-fn">entryFn</span>(raw_arg: ?*<span class="tok-type">anyopaque</span>) <span class="tok-kw">callconv</span>(.C) ?*<span class="tok-type">anyopaque</span> {</span>
<span class="line" id="L660">                <span class="tok-comment">// @alignCast() below doesn't support zero-sized-types (ZST)</span>
</span>
<span class="line" id="L661">                <span class="tok-kw">if</span> (<span class="tok-builtin">@sizeOf</span>(Args) &lt; <span class="tok-number">1</span>) {</span>
<span class="line" id="L662">                    <span class="tok-kw">return</span> callFn(f, <span class="tok-builtin">@as</span>(Args, <span class="tok-null">undefined</span>));</span>
<span class="line" id="L663">                }</span>
<span class="line" id="L664"></span>
<span class="line" id="L665">                <span class="tok-kw">const</span> args_ptr = <span class="tok-builtin">@ptrCast</span>(*Args, <span class="tok-builtin">@alignCast</span>(<span class="tok-builtin">@alignOf</span>(Args), raw_arg));</span>
<span class="line" id="L666">                <span class="tok-kw">defer</span> allocator.destroy(args_ptr);</span>
<span class="line" id="L667">                <span class="tok-kw">return</span> callFn(f, args_ptr.*);</span>
<span class="line" id="L668">            }</span>
<span class="line" id="L669">        };</span>
<span class="line" id="L670"></span>
<span class="line" id="L671">        <span class="tok-kw">const</span> args_ptr = <span class="tok-kw">try</span> allocator.create(Args);</span>
<span class="line" id="L672">        args_ptr.* = args;</span>
<span class="line" id="L673">        <span class="tok-kw">errdefer</span> allocator.destroy(args_ptr);</span>
<span class="line" id="L674"></span>
<span class="line" id="L675">        <span class="tok-kw">var</span> attr: c.pthread_attr_t = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L676">        <span class="tok-kw">if</span> (c.pthread_attr_init(&amp;attr) != .SUCCESS) <span class="tok-kw">return</span> <span class="tok-kw">error</span>.SystemResources;</span>
<span class="line" id="L677">        <span class="tok-kw">defer</span> assert(c.pthread_attr_destroy(&amp;attr) == .SUCCESS);</span>
<span class="line" id="L678"></span>
<span class="line" id="L679">        <span class="tok-comment">// Use the same set of parameters used by the libc-less impl.</span>
</span>
<span class="line" id="L680">        <span class="tok-kw">const</span> stack_size = std.math.max(config.stack_size, <span class="tok-number">16</span> * <span class="tok-number">1024</span>);</span>
<span class="line" id="L681">        assert(c.pthread_attr_setstacksize(&amp;attr, stack_size) == .SUCCESS);</span>
<span class="line" id="L682">        assert(c.pthread_attr_setguardsize(&amp;attr, std.mem.page_size) == .SUCCESS);</span>
<span class="line" id="L683"></span>
<span class="line" id="L684">        <span class="tok-kw">var</span> handle: c.pthread_t = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L685">        <span class="tok-kw">switch</span> (c.pthread_create(</span>
<span class="line" id="L686">            &amp;handle,</span>
<span class="line" id="L687">            &amp;attr,</span>
<span class="line" id="L688">            Instance.entryFn,</span>
<span class="line" id="L689">            <span class="tok-kw">if</span> (<span class="tok-builtin">@sizeOf</span>(Args) &gt; <span class="tok-number">1</span>) <span class="tok-builtin">@ptrCast</span>(*<span class="tok-type">anyopaque</span>, args_ptr) <span class="tok-kw">else</span> <span class="tok-null">undefined</span>,</span>
<span class="line" id="L690">        )) {</span>
<span class="line" id="L691">            .SUCCESS =&gt; <span class="tok-kw">return</span> Impl{ .handle = handle },</span>
<span class="line" id="L692">            .AGAIN =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.SystemResources,</span>
<span class="line" id="L693">            .PERM =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L694">            .INVAL =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L695">            <span class="tok-kw">else</span> =&gt; |err| <span class="tok-kw">return</span> os.unexpectedErrno(err),</span>
<span class="line" id="L696">        }</span>
<span class="line" id="L697">    }</span>
<span class="line" id="L698"></span>
<span class="line" id="L699">    <span class="tok-kw">fn</span> <span class="tok-fn">getHandle</span>(self: Impl) ThreadHandle {</span>
<span class="line" id="L700">        <span class="tok-kw">return</span> self.handle;</span>
<span class="line" id="L701">    }</span>
<span class="line" id="L702"></span>
<span class="line" id="L703">    <span class="tok-kw">fn</span> <span class="tok-fn">detach</span>(self: Impl) <span class="tok-type">void</span> {</span>
<span class="line" id="L704">        <span class="tok-kw">switch</span> (c.pthread_detach(self.handle)) {</span>
<span class="line" id="L705">            .SUCCESS =&gt; {},</span>
<span class="line" id="L706">            .INVAL =&gt; <span class="tok-kw">unreachable</span>, <span class="tok-comment">// thread handle is not joinable</span>
</span>
<span class="line" id="L707">            .SRCH =&gt; <span class="tok-kw">unreachable</span>, <span class="tok-comment">// thread handle is invalid</span>
</span>
<span class="line" id="L708">            <span class="tok-kw">else</span> =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L709">        }</span>
<span class="line" id="L710">    }</span>
<span class="line" id="L711"></span>
<span class="line" id="L712">    <span class="tok-kw">fn</span> <span class="tok-fn">join</span>(self: Impl) <span class="tok-type">void</span> {</span>
<span class="line" id="L713">        <span class="tok-kw">switch</span> (c.pthread_join(self.handle, <span class="tok-null">null</span>)) {</span>
<span class="line" id="L714">            .SUCCESS =&gt; {},</span>
<span class="line" id="L715">            .INVAL =&gt; <span class="tok-kw">unreachable</span>, <span class="tok-comment">// thread handle is not joinable (or another thread is already joining in)</span>
</span>
<span class="line" id="L716">            .SRCH =&gt; <span class="tok-kw">unreachable</span>, <span class="tok-comment">// thread handle is invalid</span>
</span>
<span class="line" id="L717">            .DEADLK =&gt; <span class="tok-kw">unreachable</span>, <span class="tok-comment">// two threads tried to join each other</span>
</span>
<span class="line" id="L718">            <span class="tok-kw">else</span> =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L719">        }</span>
<span class="line" id="L720">    }</span>
<span class="line" id="L721">};</span>
<span class="line" id="L722"></span>
<span class="line" id="L723"><span class="tok-kw">const</span> LinuxThreadImpl = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L724">    <span class="tok-kw">const</span> linux = os.linux;</span>
<span class="line" id="L725"></span>
<span class="line" id="L726">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> ThreadHandle = <span class="tok-type">i32</span>;</span>
<span class="line" id="L727"></span>
<span class="line" id="L728">    <span class="tok-kw">threadlocal</span> <span class="tok-kw">var</span> tls_thread_id: ?Id = <span class="tok-null">null</span>;</span>
<span class="line" id="L729"></span>
<span class="line" id="L730">    <span class="tok-kw">fn</span> <span class="tok-fn">getCurrentId</span>() Id {</span>
<span class="line" id="L731">        <span class="tok-kw">return</span> tls_thread_id <span class="tok-kw">orelse</span> {</span>
<span class="line" id="L732">            <span class="tok-kw">const</span> tid = <span class="tok-builtin">@bitCast</span>(<span class="tok-type">u32</span>, linux.gettid());</span>
<span class="line" id="L733">            tls_thread_id = tid;</span>
<span class="line" id="L734">            <span class="tok-kw">return</span> tid;</span>
<span class="line" id="L735">        };</span>
<span class="line" id="L736">    }</span>
<span class="line" id="L737"></span>
<span class="line" id="L738">    <span class="tok-kw">fn</span> <span class="tok-fn">getCpuCount</span>() !<span class="tok-type">usize</span> {</span>
<span class="line" id="L739">        <span class="tok-kw">const</span> cpu_set = <span class="tok-kw">try</span> os.sched_getaffinity(<span class="tok-number">0</span>);</span>
<span class="line" id="L740">        <span class="tok-comment">// TODO: should not need this usize cast</span>
</span>
<span class="line" id="L741">        <span class="tok-kw">return</span> <span class="tok-builtin">@as</span>(<span class="tok-type">usize</span>, os.CPU_COUNT(cpu_set));</span>
<span class="line" id="L742">    }</span>
<span class="line" id="L743"></span>
<span class="line" id="L744">    thread: *ThreadCompletion,</span>
<span class="line" id="L745"></span>
<span class="line" id="L746">    <span class="tok-kw">const</span> ThreadCompletion = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L747">        completion: Completion = Completion.init(.running),</span>
<span class="line" id="L748">        child_tid: Atomic(<span class="tok-type">i32</span>) = Atomic(<span class="tok-type">i32</span>).init(<span class="tok-number">1</span>),</span>
<span class="line" id="L749">        parent_tid: <span class="tok-type">i32</span> = <span class="tok-null">undefined</span>,</span>
<span class="line" id="L750">        mapped: []<span class="tok-kw">align</span>(std.mem.page_size) <span class="tok-type">u8</span>,</span>
<span class="line" id="L751"></span>
<span class="line" id="L752">        <span class="tok-comment">/// Calls `munmap(mapped.ptr, mapped.len)` then `exit(1)` without touching the stack (which lives in `mapped.ptr`).</span></span>
<span class="line" id="L753">        <span class="tok-comment">/// Ported over from musl libc's pthread detached implementation:</span></span>
<span class="line" id="L754">        <span class="tok-comment">/// https://github.com/ifduyue/musl/search?q=__unmapself</span></span>
<span class="line" id="L755">        <span class="tok-kw">fn</span> <span class="tok-fn">freeAndExit</span>(self: *ThreadCompletion) <span class="tok-type">noreturn</span> {</span>
<span class="line" id="L756">            <span class="tok-kw">switch</span> (target.cpu.arch) {</span>
<span class="line" id="L757">                .<span class="tok-type">i386</span> =&gt; <span class="tok-kw">asm</span> <span class="tok-kw">volatile</span> (</span>
<span class="line" id="L758">                    <span class="tok-str">\\  movl $91, %%eax</span></span>

<span class="line" id="L759">                    <span class="tok-str">\\  movl %[ptr], %%ebx</span></span>

<span class="line" id="L760">                    <span class="tok-str">\\  movl %[len], %%ecx</span></span>

<span class="line" id="L761">                    <span class="tok-str">\\  int $128</span></span>

<span class="line" id="L762">                    <span class="tok-str">\\  movl $1, %%eax</span></span>

<span class="line" id="L763">                    <span class="tok-str">\\  movl $0, %%ebx</span></span>

<span class="line" id="L764">                    <span class="tok-str">\\  int $128</span></span>

<span class="line" id="L765">                    :</span>
<span class="line" id="L766">                    : [ptr] <span class="tok-str">&quot;r&quot;</span> (<span class="tok-builtin">@ptrToInt</span>(self.mapped.ptr)),</span>
<span class="line" id="L767">                      [len] <span class="tok-str">&quot;r&quot;</span> (self.mapped.len),</span>
<span class="line" id="L768">                    : <span class="tok-str">&quot;memory&quot;</span></span>
<span class="line" id="L769">                ),</span>
<span class="line" id="L770">                .x86_64 =&gt; <span class="tok-kw">asm</span> <span class="tok-kw">volatile</span> (</span>
<span class="line" id="L771">                    <span class="tok-str">\\  movq $11, %%rax</span></span>

<span class="line" id="L772">                    <span class="tok-str">\\  movq %[ptr], %%rbx</span></span>

<span class="line" id="L773">                    <span class="tok-str">\\  movq %[len], %%rcx</span></span>

<span class="line" id="L774">                    <span class="tok-str">\\  syscall</span></span>

<span class="line" id="L775">                    <span class="tok-str">\\  movq $60, %%rax</span></span>

<span class="line" id="L776">                    <span class="tok-str">\\  movq $1, %%rdi</span></span>

<span class="line" id="L777">                    <span class="tok-str">\\  syscall</span></span>

<span class="line" id="L778">                    :</span>
<span class="line" id="L779">                    : [ptr] <span class="tok-str">&quot;r&quot;</span> (<span class="tok-builtin">@ptrToInt</span>(self.mapped.ptr)),</span>
<span class="line" id="L780">                      [len] <span class="tok-str">&quot;r&quot;</span> (self.mapped.len),</span>
<span class="line" id="L781">                    : <span class="tok-str">&quot;memory&quot;</span></span>
<span class="line" id="L782">                ),</span>
<span class="line" id="L783">                .arm, .armeb, .thumb, .thumbeb =&gt; <span class="tok-kw">asm</span> <span class="tok-kw">volatile</span> (</span>
<span class="line" id="L784">                    <span class="tok-str">\\  mov r7, #91</span></span>

<span class="line" id="L785">                    <span class="tok-str">\\  mov r0, %[ptr]</span></span>

<span class="line" id="L786">                    <span class="tok-str">\\  mov r1, %[len]</span></span>

<span class="line" id="L787">                    <span class="tok-str">\\  svc 0</span></span>

<span class="line" id="L788">                    <span class="tok-str">\\  mov r7, #1</span></span>

<span class="line" id="L789">                    <span class="tok-str">\\  mov r0, #0</span></span>

<span class="line" id="L790">                    <span class="tok-str">\\  svc 0</span></span>

<span class="line" id="L791">                    :</span>
<span class="line" id="L792">                    : [ptr] <span class="tok-str">&quot;r&quot;</span> (<span class="tok-builtin">@ptrToInt</span>(self.mapped.ptr)),</span>
<span class="line" id="L793">                      [len] <span class="tok-str">&quot;r&quot;</span> (self.mapped.len),</span>
<span class="line" id="L794">                    : <span class="tok-str">&quot;memory&quot;</span></span>
<span class="line" id="L795">                ),</span>
<span class="line" id="L796">                .aarch64, .aarch64_be, .aarch64_32 =&gt; <span class="tok-kw">asm</span> <span class="tok-kw">volatile</span> (</span>
<span class="line" id="L797">                    <span class="tok-str">\\  mov x8, #215</span></span>

<span class="line" id="L798">                    <span class="tok-str">\\  mov x0, %[ptr]</span></span>

<span class="line" id="L799">                    <span class="tok-str">\\  mov x1, %[len]</span></span>

<span class="line" id="L800">                    <span class="tok-str">\\  svc 0</span></span>

<span class="line" id="L801">                    <span class="tok-str">\\  mov x8, #93</span></span>

<span class="line" id="L802">                    <span class="tok-str">\\  mov x0, #0</span></span>

<span class="line" id="L803">                    <span class="tok-str">\\  svc 0</span></span>

<span class="line" id="L804">                    :</span>
<span class="line" id="L805">                    : [ptr] <span class="tok-str">&quot;r&quot;</span> (<span class="tok-builtin">@ptrToInt</span>(self.mapped.ptr)),</span>
<span class="line" id="L806">                      [len] <span class="tok-str">&quot;r&quot;</span> (self.mapped.len),</span>
<span class="line" id="L807">                    : <span class="tok-str">&quot;memory&quot;</span></span>
<span class="line" id="L808">                ),</span>
<span class="line" id="L809">                .mips, .mipsel =&gt; <span class="tok-kw">asm</span> <span class="tok-kw">volatile</span> (</span>
<span class="line" id="L810">                    <span class="tok-str">\\  move $sp, $25</span></span>

<span class="line" id="L811">                    <span class="tok-str">\\  li $2, 4091</span></span>

<span class="line" id="L812">                    <span class="tok-str">\\  move $4, %[ptr]</span></span>

<span class="line" id="L813">                    <span class="tok-str">\\  move $5, %[len]</span></span>

<span class="line" id="L814">                    <span class="tok-str">\\  syscall</span></span>

<span class="line" id="L815">                    <span class="tok-str">\\  li $2, 4001</span></span>

<span class="line" id="L816">                    <span class="tok-str">\\  li $4, 0</span></span>

<span class="line" id="L817">                    <span class="tok-str">\\  syscall</span></span>

<span class="line" id="L818">                    :</span>
<span class="line" id="L819">                    : [ptr] <span class="tok-str">&quot;r&quot;</span> (<span class="tok-builtin">@ptrToInt</span>(self.mapped.ptr)),</span>
<span class="line" id="L820">                      [len] <span class="tok-str">&quot;r&quot;</span> (self.mapped.len),</span>
<span class="line" id="L821">                    : <span class="tok-str">&quot;memory&quot;</span></span>
<span class="line" id="L822">                ),</span>
<span class="line" id="L823">                .mips64, .mips64el =&gt; <span class="tok-kw">asm</span> <span class="tok-kw">volatile</span> (</span>
<span class="line" id="L824">                    <span class="tok-str">\\  li $2, 4091</span></span>

<span class="line" id="L825">                    <span class="tok-str">\\  move $4, %[ptr]</span></span>

<span class="line" id="L826">                    <span class="tok-str">\\  move $5, %[len]</span></span>

<span class="line" id="L827">                    <span class="tok-str">\\  syscall</span></span>

<span class="line" id="L828">                    <span class="tok-str">\\  li $2, 4001</span></span>

<span class="line" id="L829">                    <span class="tok-str">\\  li $4, 0</span></span>

<span class="line" id="L830">                    <span class="tok-str">\\  syscall</span></span>

<span class="line" id="L831">                    :</span>
<span class="line" id="L832">                    : [ptr] <span class="tok-str">&quot;r&quot;</span> (<span class="tok-builtin">@ptrToInt</span>(self.mapped.ptr)),</span>
<span class="line" id="L833">                      [len] <span class="tok-str">&quot;r&quot;</span> (self.mapped.len),</span>
<span class="line" id="L834">                    : <span class="tok-str">&quot;memory&quot;</span></span>
<span class="line" id="L835">                ),</span>
<span class="line" id="L836">                .powerpc, .powerpcle, .powerpc64, .powerpc64le =&gt; <span class="tok-kw">asm</span> <span class="tok-kw">volatile</span> (</span>
<span class="line" id="L837">                    <span class="tok-str">\\  li 0, 91</span></span>

<span class="line" id="L838">                    <span class="tok-str">\\  mr %[ptr], 3</span></span>

<span class="line" id="L839">                    <span class="tok-str">\\  mr %[len], 4</span></span>

<span class="line" id="L840">                    <span class="tok-str">\\  sc</span></span>

<span class="line" id="L841">                    <span class="tok-str">\\  li 0, 1</span></span>

<span class="line" id="L842">                    <span class="tok-str">\\  li 3, 0</span></span>

<span class="line" id="L843">                    <span class="tok-str">\\  sc</span></span>

<span class="line" id="L844">                    <span class="tok-str">\\  blr</span></span>

<span class="line" id="L845">                    :</span>
<span class="line" id="L846">                    : [ptr] <span class="tok-str">&quot;r&quot;</span> (<span class="tok-builtin">@ptrToInt</span>(self.mapped.ptr)),</span>
<span class="line" id="L847">                      [len] <span class="tok-str">&quot;r&quot;</span> (self.mapped.len),</span>
<span class="line" id="L848">                    : <span class="tok-str">&quot;memory&quot;</span></span>
<span class="line" id="L849">                ),</span>
<span class="line" id="L850">                .riscv64 =&gt; <span class="tok-kw">asm</span> <span class="tok-kw">volatile</span> (</span>
<span class="line" id="L851">                    <span class="tok-str">\\  li a7, 215</span></span>

<span class="line" id="L852">                    <span class="tok-str">\\  mv a0, %[ptr]</span></span>

<span class="line" id="L853">                    <span class="tok-str">\\  mv a1, %[len]</span></span>

<span class="line" id="L854">                    <span class="tok-str">\\  ecall</span></span>

<span class="line" id="L855">                    <span class="tok-str">\\  li a7, 93</span></span>

<span class="line" id="L856">                    <span class="tok-str">\\  mv a0, zero</span></span>

<span class="line" id="L857">                    <span class="tok-str">\\  ecall</span></span>

<span class="line" id="L858">                    :</span>
<span class="line" id="L859">                    : [ptr] <span class="tok-str">&quot;r&quot;</span> (<span class="tok-builtin">@ptrToInt</span>(self.mapped.ptr)),</span>
<span class="line" id="L860">                      [len] <span class="tok-str">&quot;r&quot;</span> (self.mapped.len),</span>
<span class="line" id="L861">                    : <span class="tok-str">&quot;memory&quot;</span></span>
<span class="line" id="L862">                ),</span>
<span class="line" id="L863">                .sparc64 =&gt; <span class="tok-kw">asm</span> <span class="tok-kw">volatile</span> (</span>
<span class="line" id="L864">                    <span class="tok-str">\\ # SPARCs really don't like it when active stack frames</span></span>

<span class="line" id="L865">                    <span class="tok-str">\\ # is unmapped (it will result in a segfault), so we</span></span>

<span class="line" id="L866">                    <span class="tok-str">\\ # force-deactivate it by running `restore` until</span></span>

<span class="line" id="L867">                    <span class="tok-str">\\ # all frames are cleared.</span></span>

<span class="line" id="L868">                    <span class="tok-str">\\  1:</span></span>

<span class="line" id="L869">                    <span class="tok-str">\\  cmp %%fp, 0</span></span>

<span class="line" id="L870">                    <span class="tok-str">\\  beq 2f</span></span>

<span class="line" id="L871">                    <span class="tok-str">\\  nop</span></span>

<span class="line" id="L872">                    <span class="tok-str">\\  ba 1b</span></span>

<span class="line" id="L873">                    <span class="tok-str">\\  restore</span></span>

<span class="line" id="L874">                    <span class="tok-str">\\  2:</span></span>

<span class="line" id="L875">                    <span class="tok-str">\\  mov 73, %%g1</span></span>

<span class="line" id="L876">                    <span class="tok-str">\\  mov %[ptr], %%o0</span></span>

<span class="line" id="L877">                    <span class="tok-str">\\  mov %[len], %%o1</span></span>

<span class="line" id="L878">                    <span class="tok-str">\\  # Flush register window contents to prevent background</span></span>

<span class="line" id="L879">                    <span class="tok-str">\\  # memory access before unmapping the stack.</span></span>

<span class="line" id="L880">                    <span class="tok-str">\\  flushw</span></span>

<span class="line" id="L881">                    <span class="tok-str">\\  t 0x6d</span></span>

<span class="line" id="L882">                    <span class="tok-str">\\  mov 1, %%g1</span></span>

<span class="line" id="L883">                    <span class="tok-str">\\  mov 1, %%o0</span></span>

<span class="line" id="L884">                    <span class="tok-str">\\  t 0x6d</span></span>

<span class="line" id="L885">                    :</span>
<span class="line" id="L886">                    : [ptr] <span class="tok-str">&quot;r&quot;</span> (<span class="tok-builtin">@ptrToInt</span>(self.mapped.ptr)),</span>
<span class="line" id="L887">                      [len] <span class="tok-str">&quot;r&quot;</span> (self.mapped.len),</span>
<span class="line" id="L888">                    : <span class="tok-str">&quot;memory&quot;</span></span>
<span class="line" id="L889">                ),</span>
<span class="line" id="L890">                <span class="tok-kw">else</span> =&gt; |cpu_arch| <span class="tok-builtin">@compileError</span>(<span class="tok-str">&quot;Unsupported linux arch: &quot;</span> ++ <span class="tok-builtin">@tagName</span>(cpu_arch)),</span>
<span class="line" id="L891">            }</span>
<span class="line" id="L892">            <span class="tok-kw">unreachable</span>;</span>
<span class="line" id="L893">        }</span>
<span class="line" id="L894">    };</span>
<span class="line" id="L895"></span>
<span class="line" id="L896">    <span class="tok-kw">fn</span> <span class="tok-fn">spawn</span>(config: SpawnConfig, <span class="tok-kw">comptime</span> f: <span class="tok-kw">anytype</span>, args: <span class="tok-kw">anytype</span>) !Impl {</span>
<span class="line" id="L897">        <span class="tok-kw">const</span> page_size = std.mem.page_size;</span>
<span class="line" id="L898">        <span class="tok-kw">const</span> Args = <span class="tok-builtin">@TypeOf</span>(args);</span>
<span class="line" id="L899">        <span class="tok-kw">const</span> Instance = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L900">            fn_args: Args,</span>
<span class="line" id="L901">            thread: ThreadCompletion,</span>
<span class="line" id="L902"></span>
<span class="line" id="L903">            <span class="tok-kw">fn</span> <span class="tok-fn">entryFn</span>(raw_arg: <span class="tok-type">usize</span>) <span class="tok-kw">callconv</span>(.C) <span class="tok-type">u8</span> {</span>
<span class="line" id="L904">                <span class="tok-kw">const</span> self = <span class="tok-builtin">@intToPtr</span>(*<span class="tok-builtin">@This</span>(), raw_arg);</span>
<span class="line" id="L905">                <span class="tok-kw">defer</span> <span class="tok-kw">switch</span> (self.thread.completion.swap(.completed, .SeqCst)) {</span>
<span class="line" id="L906">                    .running =&gt; {},</span>
<span class="line" id="L907">                    .completed =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L908">                    .detached =&gt; self.thread.freeAndExit(),</span>
<span class="line" id="L909">                };</span>
<span class="line" id="L910">                <span class="tok-kw">return</span> callFn(f, self.fn_args);</span>
<span class="line" id="L911">            }</span>
<span class="line" id="L912">        };</span>
<span class="line" id="L913"></span>
<span class="line" id="L914">        <span class="tok-kw">var</span> guard_offset: <span class="tok-type">usize</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L915">        <span class="tok-kw">var</span> stack_offset: <span class="tok-type">usize</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L916">        <span class="tok-kw">var</span> tls_offset: <span class="tok-type">usize</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L917">        <span class="tok-kw">var</span> instance_offset: <span class="tok-type">usize</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L918"></span>
<span class="line" id="L919">        <span class="tok-kw">const</span> map_bytes = blk: {</span>
<span class="line" id="L920">            <span class="tok-kw">var</span> bytes: <span class="tok-type">usize</span> = page_size;</span>
<span class="line" id="L921">            guard_offset = bytes;</span>
<span class="line" id="L922"></span>
<span class="line" id="L923">            bytes += std.math.max(page_size, config.stack_size);</span>
<span class="line" id="L924">            bytes = std.mem.alignForward(bytes, page_size);</span>
<span class="line" id="L925">            stack_offset = bytes;</span>
<span class="line" id="L926"></span>
<span class="line" id="L927">            bytes = std.mem.alignForward(bytes, linux.tls.tls_image.alloc_align);</span>
<span class="line" id="L928">            tls_offset = bytes;</span>
<span class="line" id="L929">            bytes += linux.tls.tls_image.alloc_size;</span>
<span class="line" id="L930"></span>
<span class="line" id="L931">            bytes = std.mem.alignForward(bytes, <span class="tok-builtin">@alignOf</span>(Instance));</span>
<span class="line" id="L932">            instance_offset = bytes;</span>
<span class="line" id="L933">            bytes += <span class="tok-builtin">@sizeOf</span>(Instance);</span>
<span class="line" id="L934"></span>
<span class="line" id="L935">            bytes = std.mem.alignForward(bytes, page_size);</span>
<span class="line" id="L936">            <span class="tok-kw">break</span> :blk bytes;</span>
<span class="line" id="L937">        };</span>
<span class="line" id="L938"></span>
<span class="line" id="L939">        <span class="tok-comment">// map all memory needed without read/write permissions</span>
</span>
<span class="line" id="L940">        <span class="tok-comment">// to avoid committing the whole region right away</span>
</span>
<span class="line" id="L941">        <span class="tok-kw">const</span> mapped = os.mmap(</span>
<span class="line" id="L942">            <span class="tok-null">null</span>,</span>
<span class="line" id="L943">            map_bytes,</span>
<span class="line" id="L944">            os.PROT.NONE,</span>
<span class="line" id="L945">            os.MAP.PRIVATE | os.MAP.ANONYMOUS,</span>
<span class="line" id="L946">            -<span class="tok-number">1</span>,</span>
<span class="line" id="L947">            <span class="tok-number">0</span>,</span>
<span class="line" id="L948">        ) <span class="tok-kw">catch</span> |err| <span class="tok-kw">switch</span> (err) {</span>
<span class="line" id="L949">            <span class="tok-kw">error</span>.MemoryMappingNotSupported =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L950">            <span class="tok-kw">error</span>.AccessDenied =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L951">            <span class="tok-kw">error</span>.PermissionDenied =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L952">            <span class="tok-kw">else</span> =&gt; |e| <span class="tok-kw">return</span> e,</span>
<span class="line" id="L953">        };</span>
<span class="line" id="L954">        assert(mapped.len &gt;= map_bytes);</span>
<span class="line" id="L955">        <span class="tok-kw">errdefer</span> os.munmap(mapped);</span>
<span class="line" id="L956"></span>
<span class="line" id="L957">        <span class="tok-comment">// map everything but the guard page as read/write</span>
</span>
<span class="line" id="L958">        os.mprotect(</span>
<span class="line" id="L959">            <span class="tok-builtin">@alignCast</span>(page_size, mapped[guard_offset..]),</span>
<span class="line" id="L960">            os.PROT.READ | os.PROT.WRITE,</span>
<span class="line" id="L961">        ) <span class="tok-kw">catch</span> |err| <span class="tok-kw">switch</span> (err) {</span>
<span class="line" id="L962">            <span class="tok-kw">error</span>.AccessDenied =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L963">            <span class="tok-kw">else</span> =&gt; |e| <span class="tok-kw">return</span> e,</span>
<span class="line" id="L964">        };</span>
<span class="line" id="L965"></span>
<span class="line" id="L966">        <span class="tok-comment">// Prepare the TLS segment and prepare a user_desc struct when needed on i386</span>
</span>
<span class="line" id="L967">        <span class="tok-kw">var</span> tls_ptr = os.linux.tls.prepareTLS(mapped[tls_offset..]);</span>
<span class="line" id="L968">        <span class="tok-kw">var</span> user_desc: <span class="tok-kw">if</span> (target.cpu.arch == .<span class="tok-type">i386</span>) os.linux.user_desc <span class="tok-kw">else</span> <span class="tok-type">void</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L969">        <span class="tok-kw">if</span> (target.cpu.arch == .<span class="tok-type">i386</span>) {</span>
<span class="line" id="L970">            <span class="tok-kw">defer</span> tls_ptr = <span class="tok-builtin">@ptrToInt</span>(&amp;user_desc);</span>
<span class="line" id="L971">            user_desc = .{</span>
<span class="line" id="L972">                .entry_number = os.linux.tls.tls_image.gdt_entry_number,</span>
<span class="line" id="L973">                .base_addr = tls_ptr,</span>
<span class="line" id="L974">                .limit = <span class="tok-number">0xfffff</span>,</span>
<span class="line" id="L975">                .seg_32bit = <span class="tok-number">1</span>,</span>
<span class="line" id="L976">                .contents = <span class="tok-number">0</span>, <span class="tok-comment">// Data</span>
</span>
<span class="line" id="L977">                .read_exec_only = <span class="tok-number">0</span>,</span>
<span class="line" id="L978">                .limit_in_pages = <span class="tok-number">1</span>,</span>
<span class="line" id="L979">                .seg_not_present = <span class="tok-number">0</span>,</span>
<span class="line" id="L980">                .useable = <span class="tok-number">1</span>,</span>
<span class="line" id="L981">            };</span>
<span class="line" id="L982">        }</span>
<span class="line" id="L983"></span>
<span class="line" id="L984">        <span class="tok-kw">const</span> instance = <span class="tok-builtin">@ptrCast</span>(*Instance, <span class="tok-builtin">@alignCast</span>(<span class="tok-builtin">@alignOf</span>(Instance), &amp;mapped[instance_offset]));</span>
<span class="line" id="L985">        instance.* = .{</span>
<span class="line" id="L986">            .fn_args = args,</span>
<span class="line" id="L987">            .thread = .{ .mapped = mapped },</span>
<span class="line" id="L988">        };</span>
<span class="line" id="L989"></span>
<span class="line" id="L990">        <span class="tok-kw">const</span> flags: <span class="tok-type">u32</span> = linux.CLONE.THREAD | linux.CLONE.DETACHED |</span>
<span class="line" id="L991">            linux.CLONE.VM | linux.CLONE.FS | linux.CLONE.FILES |</span>
<span class="line" id="L992">            linux.CLONE.PARENT_SETTID | linux.CLONE.CHILD_CLEARTID |</span>
<span class="line" id="L993">            linux.CLONE.SIGHAND | linux.CLONE.SYSVSEM | linux.CLONE.SETTLS;</span>
<span class="line" id="L994"></span>
<span class="line" id="L995">        <span class="tok-kw">switch</span> (linux.getErrno(linux.clone(</span>
<span class="line" id="L996">            Instance.entryFn,</span>
<span class="line" id="L997">            <span class="tok-builtin">@ptrToInt</span>(&amp;mapped[stack_offset]),</span>
<span class="line" id="L998">            flags,</span>
<span class="line" id="L999">            <span class="tok-builtin">@ptrToInt</span>(instance),</span>
<span class="line" id="L1000">            &amp;instance.thread.parent_tid,</span>
<span class="line" id="L1001">            tls_ptr,</span>
<span class="line" id="L1002">            &amp;instance.thread.child_tid.value,</span>
<span class="line" id="L1003">        ))) {</span>
<span class="line" id="L1004">            .SUCCESS =&gt; <span class="tok-kw">return</span> Impl{ .thread = &amp;instance.thread },</span>
<span class="line" id="L1005">            .AGAIN =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.ThreadQuotaExceeded,</span>
<span class="line" id="L1006">            .INVAL =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L1007">            .NOMEM =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.SystemResources,</span>
<span class="line" id="L1008">            .NOSPC =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L1009">            .PERM =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L1010">            .USERS =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L1011">            <span class="tok-kw">else</span> =&gt; |err| <span class="tok-kw">return</span> os.unexpectedErrno(err),</span>
<span class="line" id="L1012">        }</span>
<span class="line" id="L1013">    }</span>
<span class="line" id="L1014"></span>
<span class="line" id="L1015">    <span class="tok-kw">fn</span> <span class="tok-fn">getHandle</span>(self: Impl) ThreadHandle {</span>
<span class="line" id="L1016">        <span class="tok-kw">return</span> self.thread.parent_tid;</span>
<span class="line" id="L1017">    }</span>
<span class="line" id="L1018"></span>
<span class="line" id="L1019">    <span class="tok-kw">fn</span> <span class="tok-fn">detach</span>(self: Impl) <span class="tok-type">void</span> {</span>
<span class="line" id="L1020">        <span class="tok-kw">switch</span> (self.thread.completion.swap(.detached, .SeqCst)) {</span>
<span class="line" id="L1021">            .running =&gt; {},</span>
<span class="line" id="L1022">            .completed =&gt; self.join(),</span>
<span class="line" id="L1023">            .detached =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L1024">        }</span>
<span class="line" id="L1025">    }</span>
<span class="line" id="L1026"></span>
<span class="line" id="L1027">    <span class="tok-kw">fn</span> <span class="tok-fn">join</span>(self: Impl) <span class="tok-type">void</span> {</span>
<span class="line" id="L1028">        <span class="tok-kw">defer</span> os.munmap(self.thread.mapped);</span>
<span class="line" id="L1029"></span>
<span class="line" id="L1030">        <span class="tok-kw">var</span> spin: <span class="tok-type">u8</span> = <span class="tok-number">10</span>;</span>
<span class="line" id="L1031">        <span class="tok-kw">while</span> (<span class="tok-null">true</span>) {</span>
<span class="line" id="L1032">            <span class="tok-kw">const</span> tid = self.thread.child_tid.load(.SeqCst);</span>
<span class="line" id="L1033">            <span class="tok-kw">if</span> (tid == <span class="tok-number">0</span>) {</span>
<span class="line" id="L1034">                <span class="tok-kw">break</span>;</span>
<span class="line" id="L1035">            }</span>
<span class="line" id="L1036"></span>
<span class="line" id="L1037">            <span class="tok-kw">if</span> (spin &gt; <span class="tok-number">0</span>) {</span>
<span class="line" id="L1038">                spin -= <span class="tok-number">1</span>;</span>
<span class="line" id="L1039">                std.atomic.spinLoopHint();</span>
<span class="line" id="L1040">                <span class="tok-kw">continue</span>;</span>
<span class="line" id="L1041">            }</span>
<span class="line" id="L1042"></span>
<span class="line" id="L1043">            <span class="tok-kw">switch</span> (linux.getErrno(linux.futex_wait(</span>
<span class="line" id="L1044">                &amp;self.thread.child_tid.value,</span>
<span class="line" id="L1045">                linux.FUTEX.WAIT,</span>
<span class="line" id="L1046">                tid,</span>
<span class="line" id="L1047">                <span class="tok-null">null</span>,</span>
<span class="line" id="L1048">            ))) {</span>
<span class="line" id="L1049">                .SUCCESS =&gt; <span class="tok-kw">continue</span>,</span>
<span class="line" id="L1050">                .INTR =&gt; <span class="tok-kw">continue</span>,</span>
<span class="line" id="L1051">                .AGAIN =&gt; <span class="tok-kw">continue</span>,</span>
<span class="line" id="L1052">                <span class="tok-kw">else</span> =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L1053">            }</span>
<span class="line" id="L1054">        }</span>
<span class="line" id="L1055">    }</span>
<span class="line" id="L1056">};</span>
<span class="line" id="L1057"></span>
<span class="line" id="L1058"><span class="tok-kw">fn</span> <span class="tok-fn">testThreadName</span>(thread: *Thread) !<span class="tok-type">void</span> {</span>
<span class="line" id="L1059">    <span class="tok-kw">const</span> testCases = &amp;[_][]<span class="tok-kw">const</span> <span class="tok-type">u8</span>{</span>
<span class="line" id="L1060">        <span class="tok-str">&quot;mythread&quot;</span>,</span>
<span class="line" id="L1061">        <span class="tok-str">&quot;b&quot;</span> ** max_name_len,</span>
<span class="line" id="L1062">    };</span>
<span class="line" id="L1063"></span>
<span class="line" id="L1064">    <span class="tok-kw">inline</span> <span class="tok-kw">for</span> (testCases) |tc| {</span>
<span class="line" id="L1065">        <span class="tok-kw">try</span> thread.setName(tc);</span>
<span class="line" id="L1066"></span>
<span class="line" id="L1067">        <span class="tok-kw">var</span> name_buffer: [max_name_len:<span class="tok-number">0</span>]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L1068"></span>
<span class="line" id="L1069">        <span class="tok-kw">const</span> name = <span class="tok-kw">try</span> thread.getName(&amp;name_buffer);</span>
<span class="line" id="L1070">        <span class="tok-kw">if</span> (name) |value| {</span>
<span class="line" id="L1071">            <span class="tok-kw">try</span> std.testing.expectEqual(tc.len, value.len);</span>
<span class="line" id="L1072">            <span class="tok-kw">try</span> std.testing.expectEqualStrings(tc, value);</span>
<span class="line" id="L1073">        }</span>
<span class="line" id="L1074">    }</span>
<span class="line" id="L1075">}</span>
<span class="line" id="L1076"></span>
<span class="line" id="L1077"><span class="tok-kw">test</span> <span class="tok-str">&quot;setName, getName&quot;</span> {</span>
<span class="line" id="L1078">    <span class="tok-kw">if</span> (builtin.single_threaded) <span class="tok-kw">return</span> <span class="tok-kw">error</span>.SkipZigTest;</span>
<span class="line" id="L1079"></span>
<span class="line" id="L1080">    <span class="tok-kw">const</span> Context = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L1081">        start_wait_event: ResetEvent = .{},</span>
<span class="line" id="L1082">        test_done_event: ResetEvent = .{},</span>
<span class="line" id="L1083">        thread_done_event: ResetEvent = .{},</span>
<span class="line" id="L1084"></span>
<span class="line" id="L1085">        done: std.atomic.Atomic(<span class="tok-type">bool</span>) = std.atomic.Atomic(<span class="tok-type">bool</span>).init(<span class="tok-null">false</span>),</span>
<span class="line" id="L1086">        thread: Thread = <span class="tok-null">undefined</span>,</span>
<span class="line" id="L1087"></span>
<span class="line" id="L1088">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">run</span>(ctx: *<span class="tok-builtin">@This</span>()) !<span class="tok-type">void</span> {</span>
<span class="line" id="L1089">            <span class="tok-comment">// Wait for the main thread to have set the thread field in the context.</span>
</span>
<span class="line" id="L1090">            ctx.start_wait_event.wait();</span>
<span class="line" id="L1091"></span>
<span class="line" id="L1092">            <span class="tok-kw">switch</span> (target.os.tag) {</span>
<span class="line" id="L1093">                .windows =&gt; testThreadName(&amp;ctx.thread) <span class="tok-kw">catch</span> |err| <span class="tok-kw">switch</span> (err) {</span>
<span class="line" id="L1094">                    <span class="tok-kw">error</span>.Unsupported =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.SkipZigTest,</span>
<span class="line" id="L1095">                    <span class="tok-kw">else</span> =&gt; <span class="tok-kw">return</span> err,</span>
<span class="line" id="L1096">                },</span>
<span class="line" id="L1097">                <span class="tok-kw">else</span> =&gt; <span class="tok-kw">try</span> testThreadName(&amp;ctx.thread),</span>
<span class="line" id="L1098">            }</span>
<span class="line" id="L1099"></span>
<span class="line" id="L1100">            <span class="tok-comment">// Signal our test is done</span>
</span>
<span class="line" id="L1101">            ctx.test_done_event.set();</span>
<span class="line" id="L1102"></span>
<span class="line" id="L1103">            <span class="tok-comment">// wait for the thread to property exit</span>
</span>
<span class="line" id="L1104">            ctx.thread_done_event.wait();</span>
<span class="line" id="L1105">        }</span>
<span class="line" id="L1106">    };</span>
<span class="line" id="L1107"></span>
<span class="line" id="L1108">    <span class="tok-kw">var</span> context = Context{};</span>
<span class="line" id="L1109">    <span class="tok-kw">var</span> thread = <span class="tok-kw">try</span> spawn(.{}, Context.run, .{&amp;context});</span>
<span class="line" id="L1110"></span>
<span class="line" id="L1111">    context.thread = thread;</span>
<span class="line" id="L1112">    context.start_wait_event.set();</span>
<span class="line" id="L1113">    context.test_done_event.wait();</span>
<span class="line" id="L1114"></span>
<span class="line" id="L1115">    <span class="tok-kw">switch</span> (target.os.tag) {</span>
<span class="line" id="L1116">        .macos, .ios, .watchos, .tvos =&gt; {</span>
<span class="line" id="L1117">            <span class="tok-kw">const</span> res = thread.setName(<span class="tok-str">&quot;foobar&quot;</span>);</span>
<span class="line" id="L1118">            <span class="tok-kw">try</span> std.testing.expectError(<span class="tok-kw">error</span>.Unsupported, res);</span>
<span class="line" id="L1119">        },</span>
<span class="line" id="L1120">        .windows =&gt; testThreadName(&amp;thread) <span class="tok-kw">catch</span> |err| <span class="tok-kw">switch</span> (err) {</span>
<span class="line" id="L1121">            <span class="tok-kw">error</span>.Unsupported =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.SkipZigTest,</span>
<span class="line" id="L1122">            <span class="tok-kw">else</span> =&gt; <span class="tok-kw">return</span> err,</span>
<span class="line" id="L1123">        },</span>
<span class="line" id="L1124">        <span class="tok-kw">else</span> =&gt; |tag| <span class="tok-kw">if</span> (tag == .linux <span class="tok-kw">and</span> use_pthreads <span class="tok-kw">and</span> <span class="tok-kw">comptime</span> target.abi.isMusl()) {</span>
<span class="line" id="L1125">            <span class="tok-kw">try</span> thread.setName(<span class="tok-str">&quot;foobar&quot;</span>);</span>
<span class="line" id="L1126"></span>
<span class="line" id="L1127">            <span class="tok-kw">var</span> name_buffer: [max_name_len:<span class="tok-number">0</span>]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L1128">            <span class="tok-kw">const</span> res = thread.getName(&amp;name_buffer);</span>
<span class="line" id="L1129"></span>
<span class="line" id="L1130">            <span class="tok-kw">try</span> std.testing.expectError(<span class="tok-kw">error</span>.Unsupported, res);</span>
<span class="line" id="L1131">        } <span class="tok-kw">else</span> {</span>
<span class="line" id="L1132">            <span class="tok-kw">try</span> testThreadName(&amp;thread);</span>
<span class="line" id="L1133">        },</span>
<span class="line" id="L1134">    }</span>
<span class="line" id="L1135"></span>
<span class="line" id="L1136">    context.thread_done_event.set();</span>
<span class="line" id="L1137">    thread.join();</span>
<span class="line" id="L1138">}</span>
<span class="line" id="L1139"></span>
<span class="line" id="L1140"><span class="tok-kw">test</span> <span class="tok-str">&quot;std.Thread&quot;</span> {</span>
<span class="line" id="L1141">    <span class="tok-comment">// Doesn't use testing.refAllDecls() since that would pull in the compileError spinLoopHint.</span>
</span>
<span class="line" id="L1142">    _ = Futex;</span>
<span class="line" id="L1143">    _ = ResetEvent;</span>
<span class="line" id="L1144">    _ = Mutex;</span>
<span class="line" id="L1145">    _ = Semaphore;</span>
<span class="line" id="L1146">    _ = Condition;</span>
<span class="line" id="L1147">}</span>
<span class="line" id="L1148"></span>
<span class="line" id="L1149"><span class="tok-kw">fn</span> <span class="tok-fn">testIncrementNotify</span>(value: *<span class="tok-type">usize</span>, event: *ResetEvent) <span class="tok-type">void</span> {</span>
<span class="line" id="L1150">    value.* += <span class="tok-number">1</span>;</span>
<span class="line" id="L1151">    event.set();</span>
<span class="line" id="L1152">}</span>
<span class="line" id="L1153"></span>
<span class="line" id="L1154"><span class="tok-kw">test</span> <span class="tok-str">&quot;Thread.join&quot;</span> {</span>
<span class="line" id="L1155">    <span class="tok-kw">if</span> (builtin.single_threaded) <span class="tok-kw">return</span> <span class="tok-kw">error</span>.SkipZigTest;</span>
<span class="line" id="L1156"></span>
<span class="line" id="L1157">    <span class="tok-kw">var</span> value: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L1158">    <span class="tok-kw">var</span> event = ResetEvent{};</span>
<span class="line" id="L1159"></span>
<span class="line" id="L1160">    <span class="tok-kw">const</span> thread = <span class="tok-kw">try</span> Thread.spawn(.{}, testIncrementNotify, .{ &amp;value, &amp;event });</span>
<span class="line" id="L1161">    thread.join();</span>
<span class="line" id="L1162"></span>
<span class="line" id="L1163">    <span class="tok-kw">try</span> std.testing.expectEqual(value, <span class="tok-number">1</span>);</span>
<span class="line" id="L1164">}</span>
<span class="line" id="L1165"></span>
<span class="line" id="L1166"><span class="tok-kw">test</span> <span class="tok-str">&quot;Thread.detach&quot;</span> {</span>
<span class="line" id="L1167">    <span class="tok-kw">if</span> (builtin.single_threaded) <span class="tok-kw">return</span> <span class="tok-kw">error</span>.SkipZigTest;</span>
<span class="line" id="L1168"></span>
<span class="line" id="L1169">    <span class="tok-kw">var</span> value: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L1170">    <span class="tok-kw">var</span> event = ResetEvent{};</span>
<span class="line" id="L1171"></span>
<span class="line" id="L1172">    <span class="tok-kw">const</span> thread = <span class="tok-kw">try</span> Thread.spawn(.{}, testIncrementNotify, .{ &amp;value, &amp;event });</span>
<span class="line" id="L1173">    thread.detach();</span>
<span class="line" id="L1174"></span>
<span class="line" id="L1175">    event.wait();</span>
<span class="line" id="L1176">    <span class="tok-kw">try</span> std.testing.expectEqual(value, <span class="tok-number">1</span>);</span>
<span class="line" id="L1177">}</span>
<span class="line" id="L1178"></span>
</code></pre></body>
</html>