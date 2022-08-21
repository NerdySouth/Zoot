<!doctype html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">    <title>x/os/io.zig - source view</title>
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
<pre><code><span class="line" id="L1"><span class="tok-kw">const</span> std = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;../../std.zig&quot;</span>);</span>
<span class="line" id="L2"><span class="tok-kw">const</span> builtin = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;builtin&quot;</span>);</span>
<span class="line" id="L3"></span>
<span class="line" id="L4"><span class="tok-kw">const</span> os = std.os;</span>
<span class="line" id="L5"><span class="tok-kw">const</span> mem = std.mem;</span>
<span class="line" id="L6"><span class="tok-kw">const</span> testing = std.testing;</span>
<span class="line" id="L7"><span class="tok-kw">const</span> native_os = builtin.os;</span>
<span class="line" id="L8"><span class="tok-kw">const</span> linux = std.os.linux;</span>
<span class="line" id="L9"></span>
<span class="line" id="L10"><span class="tok-comment">/// POSIX `iovec`, or Windows `WSABUF`. The difference between the two are the ordering</span></span>
<span class="line" id="L11"><span class="tok-comment">/// of fields, alongside the length being represented as either a ULONG or a size_t.</span></span>
<span class="line" id="L12"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> Buffer = <span class="tok-kw">if</span> (native_os.tag == .windows)</span>
<span class="line" id="L13">    <span class="tok-kw">extern</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L14">        len: <span class="tok-type">c_ulong</span>,</span>
<span class="line" id="L15">        ptr: <span class="tok-type">usize</span>,</span>
<span class="line" id="L16"></span>
<span class="line" id="L17">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">from</span>(slice: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) Buffer {</span>
<span class="line" id="L18">            <span class="tok-kw">return</span> .{ .len = <span class="tok-builtin">@intCast</span>(<span class="tok-type">c_ulong</span>, slice.len), .ptr = <span class="tok-builtin">@ptrToInt</span>(slice.ptr) };</span>
<span class="line" id="L19">        }</span>
<span class="line" id="L20"></span>
<span class="line" id="L21">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">into</span>(self: Buffer) []<span class="tok-kw">const</span> <span class="tok-type">u8</span> {</span>
<span class="line" id="L22">            <span class="tok-kw">return</span> <span class="tok-builtin">@intToPtr</span>([*]<span class="tok-kw">const</span> <span class="tok-type">u8</span>, self.ptr)[<span class="tok-number">0</span>..self.len];</span>
<span class="line" id="L23">        }</span>
<span class="line" id="L24"></span>
<span class="line" id="L25">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">intoMutable</span>(self: Buffer) []<span class="tok-type">u8</span> {</span>
<span class="line" id="L26">            <span class="tok-kw">return</span> <span class="tok-builtin">@intToPtr</span>([*]<span class="tok-type">u8</span>, self.ptr)[<span class="tok-number">0</span>..self.len];</span>
<span class="line" id="L27">        }</span>
<span class="line" id="L28">    }</span>
<span class="line" id="L29"><span class="tok-kw">else</span></span>
<span class="line" id="L30">    <span class="tok-kw">extern</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L31">        ptr: <span class="tok-type">usize</span>,</span>
<span class="line" id="L32">        len: <span class="tok-type">usize</span>,</span>
<span class="line" id="L33"></span>
<span class="line" id="L34">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">from</span>(slice: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) Buffer {</span>
<span class="line" id="L35">            <span class="tok-kw">return</span> .{ .ptr = <span class="tok-builtin">@ptrToInt</span>(slice.ptr), .len = slice.len };</span>
<span class="line" id="L36">        }</span>
<span class="line" id="L37"></span>
<span class="line" id="L38">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">into</span>(self: Buffer) []<span class="tok-kw">const</span> <span class="tok-type">u8</span> {</span>
<span class="line" id="L39">            <span class="tok-kw">return</span> <span class="tok-builtin">@intToPtr</span>([*]<span class="tok-kw">const</span> <span class="tok-type">u8</span>, self.ptr)[<span class="tok-number">0</span>..self.len];</span>
<span class="line" id="L40">        }</span>
<span class="line" id="L41"></span>
<span class="line" id="L42">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">intoMutable</span>(self: Buffer) []<span class="tok-type">u8</span> {</span>
<span class="line" id="L43">            <span class="tok-kw">return</span> <span class="tok-builtin">@intToPtr</span>([*]<span class="tok-type">u8</span>, self.ptr)[<span class="tok-number">0</span>..self.len];</span>
<span class="line" id="L44">        }</span>
<span class="line" id="L45">    };</span>
<span class="line" id="L46"></span>
<span class="line" id="L47"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> Reactor = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L48">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> InitFlags = <span class="tok-kw">enum</span> {</span>
<span class="line" id="L49">        close_on_exec,</span>
<span class="line" id="L50">    };</span>
<span class="line" id="L51"></span>
<span class="line" id="L52">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> Event = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L53">        data: <span class="tok-type">usize</span>,</span>
<span class="line" id="L54">        is_error: <span class="tok-type">bool</span>,</span>
<span class="line" id="L55">        is_hup: <span class="tok-type">bool</span>,</span>
<span class="line" id="L56">        is_readable: <span class="tok-type">bool</span>,</span>
<span class="line" id="L57">        is_writable: <span class="tok-type">bool</span>,</span>
<span class="line" id="L58">    };</span>
<span class="line" id="L59"></span>
<span class="line" id="L60">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> Interest = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L61">        hup: <span class="tok-type">bool</span> = <span class="tok-null">false</span>,</span>
<span class="line" id="L62">        oneshot: <span class="tok-type">bool</span> = <span class="tok-null">false</span>,</span>
<span class="line" id="L63">        readable: <span class="tok-type">bool</span> = <span class="tok-null">false</span>,</span>
<span class="line" id="L64">        writable: <span class="tok-type">bool</span> = <span class="tok-null">false</span>,</span>
<span class="line" id="L65">    };</span>
<span class="line" id="L66"></span>
<span class="line" id="L67">    fd: os.fd_t,</span>
<span class="line" id="L68"></span>
<span class="line" id="L69">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">init</span>(flags: std.enums.EnumFieldStruct(Reactor.InitFlags, <span class="tok-type">bool</span>, <span class="tok-null">false</span>)) !Reactor {</span>
<span class="line" id="L70">        <span class="tok-kw">var</span> raw_flags: <span class="tok-type">u32</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L71">        <span class="tok-kw">const</span> set = std.EnumSet(Reactor.InitFlags).init(flags);</span>
<span class="line" id="L72">        <span class="tok-kw">if</span> (set.contains(.close_on_exec)) raw_flags |= linux.EPOLL.CLOEXEC;</span>
<span class="line" id="L73">        <span class="tok-kw">return</span> Reactor{ .fd = <span class="tok-kw">try</span> os.epoll_create1(raw_flags) };</span>
<span class="line" id="L74">    }</span>
<span class="line" id="L75"></span>
<span class="line" id="L76">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">deinit</span>(self: Reactor) <span class="tok-type">void</span> {</span>
<span class="line" id="L77">        os.close(self.fd);</span>
<span class="line" id="L78">    }</span>
<span class="line" id="L79"></span>
<span class="line" id="L80">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">update</span>(self: Reactor, fd: os.fd_t, identifier: <span class="tok-type">usize</span>, interest: Reactor.Interest) !<span class="tok-type">void</span> {</span>
<span class="line" id="L81">        <span class="tok-kw">var</span> flags: <span class="tok-type">u32</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L82">        flags |= <span class="tok-kw">if</span> (interest.oneshot) linux.EPOLL.ONESHOT <span class="tok-kw">else</span> linux.EPOLL.ET;</span>
<span class="line" id="L83">        <span class="tok-kw">if</span> (interest.hup) flags |= linux.EPOLL.RDHUP;</span>
<span class="line" id="L84">        <span class="tok-kw">if</span> (interest.readable) flags |= linux.EPOLL.IN;</span>
<span class="line" id="L85">        <span class="tok-kw">if</span> (interest.writable) flags |= linux.EPOLL.OUT;</span>
<span class="line" id="L86"></span>
<span class="line" id="L87">        <span class="tok-kw">const</span> event = &amp;linux.epoll_event{</span>
<span class="line" id="L88">            .events = flags,</span>
<span class="line" id="L89">            .data = .{ .ptr = identifier },</span>
<span class="line" id="L90">        };</span>
<span class="line" id="L91"></span>
<span class="line" id="L92">        os.epoll_ctl(self.fd, linux.EPOLL.CTL_MOD, fd, event) <span class="tok-kw">catch</span> |err| <span class="tok-kw">switch</span> (err) {</span>
<span class="line" id="L93">            <span class="tok-kw">error</span>.FileDescriptorNotRegistered =&gt; <span class="tok-kw">try</span> os.epoll_ctl(self.fd, linux.EPOLL.CTL_ADD, fd, event),</span>
<span class="line" id="L94">            <span class="tok-kw">else</span> =&gt; <span class="tok-kw">return</span> err,</span>
<span class="line" id="L95">        };</span>
<span class="line" id="L96">    }</span>
<span class="line" id="L97"></span>
<span class="line" id="L98">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">poll</span>(self: Reactor, <span class="tok-kw">comptime</span> max_num_events: <span class="tok-type">comptime_int</span>, closure: <span class="tok-kw">anytype</span>, timeout_milliseconds: ?<span class="tok-type">u64</span>) !<span class="tok-type">void</span> {</span>
<span class="line" id="L99">        <span class="tok-kw">var</span> events: [max_num_events]linux.epoll_event = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L100"></span>
<span class="line" id="L101">        <span class="tok-kw">const</span> num_events = os.epoll_wait(self.fd, &amp;events, <span class="tok-kw">if</span> (timeout_milliseconds) |ms| <span class="tok-builtin">@intCast</span>(<span class="tok-type">i32</span>, ms) <span class="tok-kw">else</span> -<span class="tok-number">1</span>);</span>
<span class="line" id="L102">        <span class="tok-kw">for</span> (events[<span class="tok-number">0</span>..num_events]) |ev| {</span>
<span class="line" id="L103">            <span class="tok-kw">const</span> is_error = ev.events &amp; linux.EPOLL.ERR != <span class="tok-number">0</span>;</span>
<span class="line" id="L104">            <span class="tok-kw">const</span> is_hup = ev.events &amp; (linux.EPOLL.HUP | linux.EPOLL.RDHUP) != <span class="tok-number">0</span>;</span>
<span class="line" id="L105">            <span class="tok-kw">const</span> is_readable = ev.events &amp; linux.EPOLL.IN != <span class="tok-number">0</span>;</span>
<span class="line" id="L106">            <span class="tok-kw">const</span> is_writable = ev.events &amp; linux.EPOLL.OUT != <span class="tok-number">0</span>;</span>
<span class="line" id="L107"></span>
<span class="line" id="L108">            <span class="tok-kw">try</span> closure.call(Reactor.Event{</span>
<span class="line" id="L109">                .data = ev.data.ptr,</span>
<span class="line" id="L110">                .is_error = is_error,</span>
<span class="line" id="L111">                .is_hup = is_hup,</span>
<span class="line" id="L112">                .is_readable = is_readable,</span>
<span class="line" id="L113">                .is_writable = is_writable,</span>
<span class="line" id="L114">            });</span>
<span class="line" id="L115">        }</span>
<span class="line" id="L116">    }</span>
<span class="line" id="L117">};</span>
<span class="line" id="L118"></span>
<span class="line" id="L119"><span class="tok-kw">test</span> <span class="tok-str">&quot;reactor/linux: drive async tcp client/listener pair&quot;</span> {</span>
<span class="line" id="L120">    <span class="tok-kw">if</span> (native_os.tag != .linux) <span class="tok-kw">return</span> <span class="tok-kw">error</span>.SkipZigTest;</span>
<span class="line" id="L121"></span>
<span class="line" id="L122">    <span class="tok-kw">const</span> ip = std.x.net.ip;</span>
<span class="line" id="L123">    <span class="tok-kw">const</span> tcp = std.x.net.tcp;</span>
<span class="line" id="L124"></span>
<span class="line" id="L125">    <span class="tok-kw">const</span> IPv4 = std.x.os.IPv4;</span>
<span class="line" id="L126">    <span class="tok-kw">const</span> IPv6 = std.x.os.IPv6;</span>
<span class="line" id="L127"></span>
<span class="line" id="L128">    <span class="tok-kw">const</span> reactor = <span class="tok-kw">try</span> Reactor.init(.{ .close_on_exec = <span class="tok-null">true</span> });</span>
<span class="line" id="L129">    <span class="tok-kw">defer</span> reactor.deinit();</span>
<span class="line" id="L130"></span>
<span class="line" id="L131">    <span class="tok-kw">const</span> listener = <span class="tok-kw">try</span> tcp.Listener.init(.ip, .{</span>
<span class="line" id="L132">        .close_on_exec = <span class="tok-null">true</span>,</span>
<span class="line" id="L133">        .nonblocking = <span class="tok-null">true</span>,</span>
<span class="line" id="L134">    });</span>
<span class="line" id="L135">    <span class="tok-kw">defer</span> listener.deinit();</span>
<span class="line" id="L136"></span>
<span class="line" id="L137">    <span class="tok-kw">try</span> reactor.update(listener.socket.fd, <span class="tok-number">0</span>, .{ .readable = <span class="tok-null">true</span> });</span>
<span class="line" id="L138">    <span class="tok-kw">try</span> reactor.poll(<span class="tok-number">1</span>, <span class="tok-kw">struct</span> {</span>
<span class="line" id="L139">        <span class="tok-kw">fn</span> <span class="tok-fn">call</span>(event: Reactor.Event) !<span class="tok-type">void</span> {</span>
<span class="line" id="L140">            <span class="tok-kw">try</span> testing.expectEqual(Reactor.Event{</span>
<span class="line" id="L141">                .data = <span class="tok-number">0</span>,</span>
<span class="line" id="L142">                .is_error = <span class="tok-null">false</span>,</span>
<span class="line" id="L143">                .is_hup = <span class="tok-null">true</span>,</span>
<span class="line" id="L144">                .is_readable = <span class="tok-null">false</span>,</span>
<span class="line" id="L145">                .is_writable = <span class="tok-null">false</span>,</span>
<span class="line" id="L146">            }, event);</span>
<span class="line" id="L147">        }</span>
<span class="line" id="L148">    }, <span class="tok-null">null</span>);</span>
<span class="line" id="L149"></span>
<span class="line" id="L150">    <span class="tok-kw">try</span> listener.bind(ip.Address.initIPv4(IPv4.unspecified, <span class="tok-number">0</span>));</span>
<span class="line" id="L151">    <span class="tok-kw">try</span> listener.listen(<span class="tok-number">128</span>);</span>
<span class="line" id="L152"></span>
<span class="line" id="L153">    <span class="tok-kw">var</span> binded_address = <span class="tok-kw">try</span> listener.getLocalAddress();</span>
<span class="line" id="L154">    <span class="tok-kw">switch</span> (binded_address) {</span>
<span class="line" id="L155">        .ipv4 =&gt; |*ipv4| ipv4.host = IPv4.localhost,</span>
<span class="line" id="L156">        .ipv6 =&gt; |*ipv6| ipv6.host = IPv6.localhost,</span>
<span class="line" id="L157">    }</span>
<span class="line" id="L158"></span>
<span class="line" id="L159">    <span class="tok-kw">const</span> client = <span class="tok-kw">try</span> tcp.Client.init(.ip, .{</span>
<span class="line" id="L160">        .close_on_exec = <span class="tok-null">true</span>,</span>
<span class="line" id="L161">        .nonblocking = <span class="tok-null">true</span>,</span>
<span class="line" id="L162">    });</span>
<span class="line" id="L163">    <span class="tok-kw">defer</span> client.deinit();</span>
<span class="line" id="L164"></span>
<span class="line" id="L165">    <span class="tok-kw">try</span> reactor.update(client.socket.fd, <span class="tok-number">1</span>, .{ .readable = <span class="tok-null">true</span>, .writable = <span class="tok-null">true</span> });</span>
<span class="line" id="L166">    <span class="tok-kw">try</span> reactor.poll(<span class="tok-number">1</span>, <span class="tok-kw">struct</span> {</span>
<span class="line" id="L167">        <span class="tok-kw">fn</span> <span class="tok-fn">call</span>(event: Reactor.Event) !<span class="tok-type">void</span> {</span>
<span class="line" id="L168">            <span class="tok-kw">try</span> testing.expectEqual(Reactor.Event{</span>
<span class="line" id="L169">                .data = <span class="tok-number">1</span>,</span>
<span class="line" id="L170">                .is_error = <span class="tok-null">false</span>,</span>
<span class="line" id="L171">                .is_hup = <span class="tok-null">true</span>,</span>
<span class="line" id="L172">                .is_readable = <span class="tok-null">false</span>,</span>
<span class="line" id="L173">                .is_writable = <span class="tok-null">true</span>,</span>
<span class="line" id="L174">            }, event);</span>
<span class="line" id="L175">        }</span>
<span class="line" id="L176">    }, <span class="tok-null">null</span>);</span>
<span class="line" id="L177"></span>
<span class="line" id="L178">    client.connect(binded_address) <span class="tok-kw">catch</span> |err| <span class="tok-kw">switch</span> (err) {</span>
<span class="line" id="L179">        <span class="tok-kw">error</span>.WouldBlock =&gt; {},</span>
<span class="line" id="L180">        <span class="tok-kw">else</span> =&gt; <span class="tok-kw">return</span> err,</span>
<span class="line" id="L181">    };</span>
<span class="line" id="L182"></span>
<span class="line" id="L183">    <span class="tok-kw">try</span> reactor.poll(<span class="tok-number">1</span>, <span class="tok-kw">struct</span> {</span>
<span class="line" id="L184">        <span class="tok-kw">fn</span> <span class="tok-fn">call</span>(event: Reactor.Event) !<span class="tok-type">void</span> {</span>
<span class="line" id="L185">            <span class="tok-kw">try</span> testing.expectEqual(Reactor.Event{</span>
<span class="line" id="L186">                .data = <span class="tok-number">1</span>,</span>
<span class="line" id="L187">                .is_error = <span class="tok-null">false</span>,</span>
<span class="line" id="L188">                .is_hup = <span class="tok-null">false</span>,</span>
<span class="line" id="L189">                .is_readable = <span class="tok-null">false</span>,</span>
<span class="line" id="L190">                .is_writable = <span class="tok-null">true</span>,</span>
<span class="line" id="L191">            }, event);</span>
<span class="line" id="L192">        }</span>
<span class="line" id="L193">    }, <span class="tok-null">null</span>);</span>
<span class="line" id="L194"></span>
<span class="line" id="L195">    <span class="tok-kw">try</span> reactor.poll(<span class="tok-number">1</span>, <span class="tok-kw">struct</span> {</span>
<span class="line" id="L196">        <span class="tok-kw">fn</span> <span class="tok-fn">call</span>(event: Reactor.Event) !<span class="tok-type">void</span> {</span>
<span class="line" id="L197">            <span class="tok-kw">try</span> testing.expectEqual(Reactor.Event{</span>
<span class="line" id="L198">                .data = <span class="tok-number">0</span>,</span>
<span class="line" id="L199">                .is_error = <span class="tok-null">false</span>,</span>
<span class="line" id="L200">                .is_hup = <span class="tok-null">false</span>,</span>
<span class="line" id="L201">                .is_readable = <span class="tok-null">true</span>,</span>
<span class="line" id="L202">                .is_writable = <span class="tok-null">false</span>,</span>
<span class="line" id="L203">            }, event);</span>
<span class="line" id="L204">        }</span>
<span class="line" id="L205">    }, <span class="tok-null">null</span>);</span>
<span class="line" id="L206">}</span>
<span class="line" id="L207"></span>
</code></pre></body>
</html>