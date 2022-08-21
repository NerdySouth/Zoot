<!doctype html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">    <title>target.zig - source view</title>
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
<pre><code><span class="line" id="L1"><span class="tok-kw">const</span> std = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;std.zig&quot;</span>);</span>
<span class="line" id="L2"><span class="tok-kw">const</span> mem = std.mem;</span>
<span class="line" id="L3"><span class="tok-kw">const</span> Version = std.builtin.Version;</span>
<span class="line" id="L4"></span>
<span class="line" id="L5"><span class="tok-comment">/// TODO Nearly all the functions in this namespace would be</span></span>
<span class="line" id="L6"><span class="tok-comment">/// better off if https://github.com/ziglang/zig/issues/425</span></span>
<span class="line" id="L7"><span class="tok-comment">/// was solved.</span></span>
<span class="line" id="L8"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> Target = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L9">    cpu: Cpu,</span>
<span class="line" id="L10">    os: Os,</span>
<span class="line" id="L11">    abi: Abi,</span>
<span class="line" id="L12">    ofmt: ObjectFormat,</span>
<span class="line" id="L13"></span>
<span class="line" id="L14">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> Os = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L15">        tag: Tag,</span>
<span class="line" id="L16">        version_range: VersionRange,</span>
<span class="line" id="L17"></span>
<span class="line" id="L18">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> Tag = <span class="tok-kw">enum</span> {</span>
<span class="line" id="L19">            freestanding,</span>
<span class="line" id="L20">            ananas,</span>
<span class="line" id="L21">            cloudabi,</span>
<span class="line" id="L22">            dragonfly,</span>
<span class="line" id="L23">            freebsd,</span>
<span class="line" id="L24">            fuchsia,</span>
<span class="line" id="L25">            ios,</span>
<span class="line" id="L26">            kfreebsd,</span>
<span class="line" id="L27">            linux,</span>
<span class="line" id="L28">            lv2,</span>
<span class="line" id="L29">            macos,</span>
<span class="line" id="L30">            netbsd,</span>
<span class="line" id="L31">            openbsd,</span>
<span class="line" id="L32">            solaris,</span>
<span class="line" id="L33">            windows,</span>
<span class="line" id="L34">            zos,</span>
<span class="line" id="L35">            haiku,</span>
<span class="line" id="L36">            minix,</span>
<span class="line" id="L37">            rtems,</span>
<span class="line" id="L38">            nacl,</span>
<span class="line" id="L39">            aix,</span>
<span class="line" id="L40">            cuda,</span>
<span class="line" id="L41">            nvcl,</span>
<span class="line" id="L42">            amdhsa,</span>
<span class="line" id="L43">            ps4,</span>
<span class="line" id="L44">            elfiamcu,</span>
<span class="line" id="L45">            tvos,</span>
<span class="line" id="L46">            watchos,</span>
<span class="line" id="L47">            mesa3d,</span>
<span class="line" id="L48">            contiki,</span>
<span class="line" id="L49">            amdpal,</span>
<span class="line" id="L50">            hermit,</span>
<span class="line" id="L51">            hurd,</span>
<span class="line" id="L52">            wasi,</span>
<span class="line" id="L53">            emscripten,</span>
<span class="line" id="L54">            uefi,</span>
<span class="line" id="L55">            opencl,</span>
<span class="line" id="L56">            glsl450,</span>
<span class="line" id="L57">            vulkan,</span>
<span class="line" id="L58">            plan9,</span>
<span class="line" id="L59">            other,</span>
<span class="line" id="L60"></span>
<span class="line" id="L61">            <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">isDarwin</span>(tag: Tag) <span class="tok-type">bool</span> {</span>
<span class="line" id="L62">                <span class="tok-kw">return</span> <span class="tok-kw">switch</span> (tag) {</span>
<span class="line" id="L63">                    .ios, .macos, .watchos, .tvos =&gt; <span class="tok-null">true</span>,</span>
<span class="line" id="L64">                    <span class="tok-kw">else</span> =&gt; <span class="tok-null">false</span>,</span>
<span class="line" id="L65">                };</span>
<span class="line" id="L66">            }</span>
<span class="line" id="L67"></span>
<span class="line" id="L68">            <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">isBSD</span>(tag: Tag) <span class="tok-type">bool</span> {</span>
<span class="line" id="L69">                <span class="tok-kw">return</span> tag.isDarwin() <span class="tok-kw">or</span> <span class="tok-kw">switch</span> (tag) {</span>
<span class="line" id="L70">                    .kfreebsd, .freebsd, .openbsd, .netbsd, .dragonfly =&gt; <span class="tok-null">true</span>,</span>
<span class="line" id="L71">                    <span class="tok-kw">else</span> =&gt; <span class="tok-null">false</span>,</span>
<span class="line" id="L72">                };</span>
<span class="line" id="L73">            }</span>
<span class="line" id="L74"></span>
<span class="line" id="L75">            <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">dynamicLibSuffix</span>(tag: Tag) [:<span class="tok-number">0</span>]<span class="tok-kw">const</span> <span class="tok-type">u8</span> {</span>
<span class="line" id="L76">                <span class="tok-kw">if</span> (tag.isDarwin()) {</span>
<span class="line" id="L77">                    <span class="tok-kw">return</span> <span class="tok-str">&quot;.dylib&quot;</span>;</span>
<span class="line" id="L78">                }</span>
<span class="line" id="L79">                <span class="tok-kw">switch</span> (tag) {</span>
<span class="line" id="L80">                    .windows =&gt; <span class="tok-kw">return</span> <span class="tok-str">&quot;.dll&quot;</span>,</span>
<span class="line" id="L81">                    <span class="tok-kw">else</span> =&gt; <span class="tok-kw">return</span> <span class="tok-str">&quot;.so&quot;</span>,</span>
<span class="line" id="L82">                }</span>
<span class="line" id="L83">            }</span>
<span class="line" id="L84"></span>
<span class="line" id="L85">            <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">defaultVersionRange</span>(tag: Tag, arch: Cpu.Arch) Os {</span>
<span class="line" id="L86">                <span class="tok-kw">return</span> .{</span>
<span class="line" id="L87">                    .tag = tag,</span>
<span class="line" id="L88">                    .version_range = VersionRange.default(tag, arch),</span>
<span class="line" id="L89">                };</span>
<span class="line" id="L90">            }</span>
<span class="line" id="L91">        };</span>
<span class="line" id="L92"></span>
<span class="line" id="L93">        <span class="tok-comment">/// Based on NTDDI version constants from</span></span>
<span class="line" id="L94">        <span class="tok-comment">/// https://docs.microsoft.com/en-us/cpp/porting/modifying-winver-and-win32-winnt</span></span>
<span class="line" id="L95">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> WindowsVersion = <span class="tok-kw">enum</span>(<span class="tok-type">u32</span>) {</span>
<span class="line" id="L96">            nt4 = <span class="tok-number">0x04000000</span>,</span>
<span class="line" id="L97">            win2k = <span class="tok-number">0x05000000</span>,</span>
<span class="line" id="L98">            xp = <span class="tok-number">0x05010000</span>,</span>
<span class="line" id="L99">            ws2003 = <span class="tok-number">0x05020000</span>,</span>
<span class="line" id="L100">            vista = <span class="tok-number">0x06000000</span>,</span>
<span class="line" id="L101">            win7 = <span class="tok-number">0x06010000</span>,</span>
<span class="line" id="L102">            win8 = <span class="tok-number">0x06020000</span>,</span>
<span class="line" id="L103">            win8_1 = <span class="tok-number">0x06030000</span>,</span>
<span class="line" id="L104">            win10 = <span class="tok-number">0x0A000000</span>, <span class="tok-comment">//aka win10_th1</span>
</span>
<span class="line" id="L105">            win10_th2 = <span class="tok-number">0x0A000001</span>,</span>
<span class="line" id="L106">            win10_rs1 = <span class="tok-number">0x0A000002</span>,</span>
<span class="line" id="L107">            win10_rs2 = <span class="tok-number">0x0A000003</span>,</span>
<span class="line" id="L108">            win10_rs3 = <span class="tok-number">0x0A000004</span>,</span>
<span class="line" id="L109">            win10_rs4 = <span class="tok-number">0x0A000005</span>,</span>
<span class="line" id="L110">            win10_rs5 = <span class="tok-number">0x0A000006</span>,</span>
<span class="line" id="L111">            win10_19h1 = <span class="tok-number">0x0A000007</span>,</span>
<span class="line" id="L112">            win10_vb = <span class="tok-number">0x0A000008</span>, <span class="tok-comment">//aka win10_19h2</span>
</span>
<span class="line" id="L113">            win10_mn = <span class="tok-number">0x0A000009</span>, <span class="tok-comment">//aka win10_20h1</span>
</span>
<span class="line" id="L114">            win10_fe = <span class="tok-number">0x0A00000A</span>, <span class="tok-comment">//aka win10_20h2</span>
</span>
<span class="line" id="L115">            _,</span>
<span class="line" id="L116"></span>
<span class="line" id="L117">            <span class="tok-comment">/// Latest Windows version that the Zig Standard Library is aware of</span></span>
<span class="line" id="L118">            <span class="tok-kw">pub</span> <span class="tok-kw">const</span> latest = WindowsVersion.win10_fe;</span>
<span class="line" id="L119"></span>
<span class="line" id="L120">            <span class="tok-comment">/// Compared against build numbers reported by the runtime to distinguish win10 versions,</span></span>
<span class="line" id="L121">            <span class="tok-comment">/// where 0x0A000000 + index corresponds to the WindowsVersion u32 value.</span></span>
<span class="line" id="L122">            <span class="tok-kw">pub</span> <span class="tok-kw">const</span> known_win10_build_numbers = [_]<span class="tok-type">u32</span>{</span>
<span class="line" id="L123">                <span class="tok-number">10240</span>, <span class="tok-comment">//win10 aka win10_th1</span>
</span>
<span class="line" id="L124">                <span class="tok-number">10586</span>, <span class="tok-comment">//win10_th2</span>
</span>
<span class="line" id="L125">                <span class="tok-number">14393</span>, <span class="tok-comment">//win10_rs1</span>
</span>
<span class="line" id="L126">                <span class="tok-number">15063</span>, <span class="tok-comment">//win10_rs2</span>
</span>
<span class="line" id="L127">                <span class="tok-number">16299</span>, <span class="tok-comment">//win10_rs3</span>
</span>
<span class="line" id="L128">                <span class="tok-number">17134</span>, <span class="tok-comment">//win10_rs4</span>
</span>
<span class="line" id="L129">                <span class="tok-number">17763</span>, <span class="tok-comment">//win10_rs5</span>
</span>
<span class="line" id="L130">                <span class="tok-number">18362</span>, <span class="tok-comment">//win10_19h1</span>
</span>
<span class="line" id="L131">                <span class="tok-number">18363</span>, <span class="tok-comment">//win10_vb aka win10_19h2</span>
</span>
<span class="line" id="L132">                <span class="tok-number">19041</span>, <span class="tok-comment">//win10_mn aka win10_20h1</span>
</span>
<span class="line" id="L133">                <span class="tok-number">19042</span>, <span class="tok-comment">//win10_fe aka win10_20h2</span>
</span>
<span class="line" id="L134">            };</span>
<span class="line" id="L135"></span>
<span class="line" id="L136">            <span class="tok-comment">/// Returns whether the first version `self` is newer (greater) than or equal to the second version `ver`.</span></span>
<span class="line" id="L137">            <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">isAtLeast</span>(self: WindowsVersion, ver: WindowsVersion) <span class="tok-type">bool</span> {</span>
<span class="line" id="L138">                <span class="tok-kw">return</span> <span class="tok-builtin">@enumToInt</span>(self) &gt;= <span class="tok-builtin">@enumToInt</span>(ver);</span>
<span class="line" id="L139">            }</span>
<span class="line" id="L140"></span>
<span class="line" id="L141">            <span class="tok-kw">pub</span> <span class="tok-kw">const</span> Range = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L142">                min: WindowsVersion,</span>
<span class="line" id="L143">                max: WindowsVersion,</span>
<span class="line" id="L144"></span>
<span class="line" id="L145">                <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">includesVersion</span>(self: Range, ver: WindowsVersion) <span class="tok-type">bool</span> {</span>
<span class="line" id="L146">                    <span class="tok-kw">return</span> <span class="tok-builtin">@enumToInt</span>(ver) &gt;= <span class="tok-builtin">@enumToInt</span>(self.min) <span class="tok-kw">and</span> <span class="tok-builtin">@enumToInt</span>(ver) &lt;= <span class="tok-builtin">@enumToInt</span>(self.max);</span>
<span class="line" id="L147">                }</span>
<span class="line" id="L148"></span>
<span class="line" id="L149">                <span class="tok-comment">/// Checks if system is guaranteed to be at least `version` or older than `version`.</span></span>
<span class="line" id="L150">                <span class="tok-comment">/// Returns `null` if a runtime check is required.</span></span>
<span class="line" id="L151">                <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">isAtLeast</span>(self: Range, ver: WindowsVersion) ?<span class="tok-type">bool</span> {</span>
<span class="line" id="L152">                    <span class="tok-kw">if</span> (<span class="tok-builtin">@enumToInt</span>(self.min) &gt;= <span class="tok-builtin">@enumToInt</span>(ver)) <span class="tok-kw">return</span> <span class="tok-null">true</span>;</span>
<span class="line" id="L153">                    <span class="tok-kw">if</span> (<span class="tok-builtin">@enumToInt</span>(self.max) &lt; <span class="tok-builtin">@enumToInt</span>(ver)) <span class="tok-kw">return</span> <span class="tok-null">false</span>;</span>
<span class="line" id="L154">                    <span class="tok-kw">return</span> <span class="tok-null">null</span>;</span>
<span class="line" id="L155">                }</span>
<span class="line" id="L156">            };</span>
<span class="line" id="L157"></span>
<span class="line" id="L158">            <span class="tok-comment">/// This function is defined to serialize a Zig source code representation of this</span></span>
<span class="line" id="L159">            <span class="tok-comment">/// type, that, when parsed, will deserialize into the same data.</span></span>
<span class="line" id="L160">            <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">format</span>(</span>
<span class="line" id="L161">                self: WindowsVersion,</span>
<span class="line" id="L162">                <span class="tok-kw">comptime</span> fmt: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>,</span>
<span class="line" id="L163">                _: std.fmt.FormatOptions,</span>
<span class="line" id="L164">                out_stream: <span class="tok-kw">anytype</span>,</span>
<span class="line" id="L165">            ) !<span class="tok-type">void</span> {</span>
<span class="line" id="L166">                <span class="tok-kw">if</span> (fmt.len &gt; <span class="tok-number">0</span> <span class="tok-kw">and</span> fmt[<span class="tok-number">0</span>] == <span class="tok-str">'s'</span>) {</span>
<span class="line" id="L167">                    <span class="tok-kw">if</span> (<span class="tok-builtin">@enumToInt</span>(self) &gt;= <span class="tok-builtin">@enumToInt</span>(WindowsVersion.nt4) <span class="tok-kw">and</span> <span class="tok-builtin">@enumToInt</span>(self) &lt;= <span class="tok-builtin">@enumToInt</span>(WindowsVersion.latest)) {</span>
<span class="line" id="L168">                        <span class="tok-kw">try</span> std.fmt.format(out_stream, <span class="tok-str">&quot;.{s}&quot;</span>, .{<span class="tok-builtin">@tagName</span>(self)});</span>
<span class="line" id="L169">                    } <span class="tok-kw">else</span> {</span>
<span class="line" id="L170">                        <span class="tok-comment">// TODO this code path breaks zig triples, but it is used in `builtin`</span>
</span>
<span class="line" id="L171">                        <span class="tok-kw">try</span> std.fmt.format(out_stream, <span class="tok-str">&quot;@intToEnum(Target.Os.WindowsVersion, 0x{X:0&gt;8})&quot;</span>, .{<span class="tok-builtin">@enumToInt</span>(self)});</span>
<span class="line" id="L172">                    }</span>
<span class="line" id="L173">                } <span class="tok-kw">else</span> {</span>
<span class="line" id="L174">                    <span class="tok-kw">if</span> (<span class="tok-builtin">@enumToInt</span>(self) &gt;= <span class="tok-builtin">@enumToInt</span>(WindowsVersion.nt4) <span class="tok-kw">and</span> <span class="tok-builtin">@enumToInt</span>(self) &lt;= <span class="tok-builtin">@enumToInt</span>(WindowsVersion.latest)) {</span>
<span class="line" id="L175">                        <span class="tok-kw">try</span> std.fmt.format(out_stream, <span class="tok-str">&quot;WindowsVersion.{s}&quot;</span>, .{<span class="tok-builtin">@tagName</span>(self)});</span>
<span class="line" id="L176">                    } <span class="tok-kw">else</span> {</span>
<span class="line" id="L177">                        <span class="tok-kw">try</span> std.fmt.format(out_stream, <span class="tok-str">&quot;WindowsVersion(0x{X:0&gt;8})&quot;</span>, .{<span class="tok-builtin">@enumToInt</span>(self)});</span>
<span class="line" id="L178">                    }</span>
<span class="line" id="L179">                }</span>
<span class="line" id="L180">            }</span>
<span class="line" id="L181">        };</span>
<span class="line" id="L182"></span>
<span class="line" id="L183">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> LinuxVersionRange = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L184">            range: Version.Range,</span>
<span class="line" id="L185">            glibc: Version,</span>
<span class="line" id="L186"></span>
<span class="line" id="L187">            <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">includesVersion</span>(self: LinuxVersionRange, ver: Version) <span class="tok-type">bool</span> {</span>
<span class="line" id="L188">                <span class="tok-kw">return</span> self.range.includesVersion(ver);</span>
<span class="line" id="L189">            }</span>
<span class="line" id="L190"></span>
<span class="line" id="L191">            <span class="tok-comment">/// Checks if system is guaranteed to be at least `version` or older than `version`.</span></span>
<span class="line" id="L192">            <span class="tok-comment">/// Returns `null` if a runtime check is required.</span></span>
<span class="line" id="L193">            <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">isAtLeast</span>(self: LinuxVersionRange, ver: Version) ?<span class="tok-type">bool</span> {</span>
<span class="line" id="L194">                <span class="tok-kw">return</span> self.range.isAtLeast(ver);</span>
<span class="line" id="L195">            }</span>
<span class="line" id="L196">        };</span>
<span class="line" id="L197"></span>
<span class="line" id="L198">        <span class="tok-comment">/// The version ranges here represent the minimum OS version to be supported</span></span>
<span class="line" id="L199">        <span class="tok-comment">/// and the maximum OS version to be supported. The default values represent</span></span>
<span class="line" id="L200">        <span class="tok-comment">/// the range that the Zig Standard Library bases its abstractions on.</span></span>
<span class="line" id="L201">        <span class="tok-comment">///</span></span>
<span class="line" id="L202">        <span class="tok-comment">/// The minimum version of the range is the main setting to tweak for a target.</span></span>
<span class="line" id="L203">        <span class="tok-comment">/// Usually, the maximum target OS version will remain the default, which is</span></span>
<span class="line" id="L204">        <span class="tok-comment">/// the latest released version of the OS.</span></span>
<span class="line" id="L205">        <span class="tok-comment">///</span></span>
<span class="line" id="L206">        <span class="tok-comment">/// To test at compile time if the target is guaranteed to support a given OS feature,</span></span>
<span class="line" id="L207">        <span class="tok-comment">/// one should check that the minimum version of the range is greater than or equal to</span></span>
<span class="line" id="L208">        <span class="tok-comment">/// the version the feature was introduced in.</span></span>
<span class="line" id="L209">        <span class="tok-comment">///</span></span>
<span class="line" id="L210">        <span class="tok-comment">/// To test at compile time if the target certainly will not support a given OS feature,</span></span>
<span class="line" id="L211">        <span class="tok-comment">/// one should check that the maximum version of the range is less than the version the</span></span>
<span class="line" id="L212">        <span class="tok-comment">/// feature was introduced in.</span></span>
<span class="line" id="L213">        <span class="tok-comment">///</span></span>
<span class="line" id="L214">        <span class="tok-comment">/// If neither of these cases apply, a runtime check should be used to determine if the</span></span>
<span class="line" id="L215">        <span class="tok-comment">/// target supports a given OS feature.</span></span>
<span class="line" id="L216">        <span class="tok-comment">///</span></span>
<span class="line" id="L217">        <span class="tok-comment">/// Binaries built with a given maximum version will continue to function on newer</span></span>
<span class="line" id="L218">        <span class="tok-comment">/// operating system versions. However, such a binary may not take full advantage of the</span></span>
<span class="line" id="L219">        <span class="tok-comment">/// newer operating system APIs.</span></span>
<span class="line" id="L220">        <span class="tok-comment">///</span></span>
<span class="line" id="L221">        <span class="tok-comment">/// See `Os.isAtLeast`.</span></span>
<span class="line" id="L222">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> VersionRange = <span class="tok-kw">union</span> {</span>
<span class="line" id="L223">            none: <span class="tok-type">void</span>,</span>
<span class="line" id="L224">            semver: Version.Range,</span>
<span class="line" id="L225">            linux: LinuxVersionRange,</span>
<span class="line" id="L226">            windows: WindowsVersion.Range,</span>
<span class="line" id="L227"></span>
<span class="line" id="L228">            <span class="tok-comment">/// The default `VersionRange` represents the range that the Zig Standard Library</span></span>
<span class="line" id="L229">            <span class="tok-comment">/// bases its abstractions on.</span></span>
<span class="line" id="L230">            <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">default</span>(tag: Tag, arch: Cpu.Arch) VersionRange {</span>
<span class="line" id="L231">                <span class="tok-kw">switch</span> (tag) {</span>
<span class="line" id="L232">                    .freestanding,</span>
<span class="line" id="L233">                    .ananas,</span>
<span class="line" id="L234">                    .cloudabi,</span>
<span class="line" id="L235">                    .fuchsia,</span>
<span class="line" id="L236">                    .kfreebsd,</span>
<span class="line" id="L237">                    .lv2,</span>
<span class="line" id="L238">                    .zos,</span>
<span class="line" id="L239">                    .haiku,</span>
<span class="line" id="L240">                    .minix,</span>
<span class="line" id="L241">                    .rtems,</span>
<span class="line" id="L242">                    .nacl,</span>
<span class="line" id="L243">                    .aix,</span>
<span class="line" id="L244">                    .cuda,</span>
<span class="line" id="L245">                    .nvcl,</span>
<span class="line" id="L246">                    .amdhsa,</span>
<span class="line" id="L247">                    .ps4,</span>
<span class="line" id="L248">                    .elfiamcu,</span>
<span class="line" id="L249">                    .mesa3d,</span>
<span class="line" id="L250">                    .contiki,</span>
<span class="line" id="L251">                    .amdpal,</span>
<span class="line" id="L252">                    .hermit,</span>
<span class="line" id="L253">                    .hurd,</span>
<span class="line" id="L254">                    .wasi,</span>
<span class="line" id="L255">                    .emscripten,</span>
<span class="line" id="L256">                    .uefi,</span>
<span class="line" id="L257">                    .opencl, <span class="tok-comment">// TODO: OpenCL versions</span>
</span>
<span class="line" id="L258">                    .glsl450, <span class="tok-comment">// TODO: GLSL versions</span>
</span>
<span class="line" id="L259">                    .vulkan,</span>
<span class="line" id="L260">                    .plan9,</span>
<span class="line" id="L261">                    .other,</span>
<span class="line" id="L262">                    =&gt; <span class="tok-kw">return</span> .{ .none = {} },</span>
<span class="line" id="L263"></span>
<span class="line" id="L264">                    .freebsd =&gt; <span class="tok-kw">return</span> .{</span>
<span class="line" id="L265">                        .semver = Version.Range{</span>
<span class="line" id="L266">                            .min = .{ .major = <span class="tok-number">12</span>, .minor = <span class="tok-number">0</span> },</span>
<span class="line" id="L267">                            .max = .{ .major = <span class="tok-number">13</span>, .minor = <span class="tok-number">0</span> },</span>
<span class="line" id="L268">                        },</span>
<span class="line" id="L269">                    },</span>
<span class="line" id="L270">                    .macos =&gt; <span class="tok-kw">return</span> <span class="tok-kw">switch</span> (arch) {</span>
<span class="line" id="L271">                        .aarch64 =&gt; VersionRange{</span>
<span class="line" id="L272">                            .semver = .{</span>
<span class="line" id="L273">                                .min = .{ .major = <span class="tok-number">11</span>, .minor = <span class="tok-number">6</span>, .patch = <span class="tok-number">6</span> },</span>
<span class="line" id="L274">                                .max = .{ .major = <span class="tok-number">12</span>, .minor = <span class="tok-number">4</span> },</span>
<span class="line" id="L275">                            },</span>
<span class="line" id="L276">                        },</span>
<span class="line" id="L277">                        .x86_64 =&gt; VersionRange{</span>
<span class="line" id="L278">                            .semver = .{</span>
<span class="line" id="L279">                                .min = .{ .major = <span class="tok-number">10</span>, .minor = <span class="tok-number">15</span>, .patch = <span class="tok-number">7</span> },</span>
<span class="line" id="L280">                                .max = .{ .major = <span class="tok-number">12</span>, .minor = <span class="tok-number">4</span> },</span>
<span class="line" id="L281">                            },</span>
<span class="line" id="L282">                        },</span>
<span class="line" id="L283">                        <span class="tok-kw">else</span> =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L284">                    },</span>
<span class="line" id="L285">                    .ios =&gt; <span class="tok-kw">return</span> .{</span>
<span class="line" id="L286">                        .semver = .{</span>
<span class="line" id="L287">                            .min = .{ .major = <span class="tok-number">12</span>, .minor = <span class="tok-number">0</span> },</span>
<span class="line" id="L288">                            .max = .{ .major = <span class="tok-number">13</span>, .minor = <span class="tok-number">4</span>, .patch = <span class="tok-number">0</span> },</span>
<span class="line" id="L289">                        },</span>
<span class="line" id="L290">                    },</span>
<span class="line" id="L291">                    .watchos =&gt; <span class="tok-kw">return</span> .{</span>
<span class="line" id="L292">                        .semver = .{</span>
<span class="line" id="L293">                            .min = .{ .major = <span class="tok-number">6</span>, .minor = <span class="tok-number">0</span> },</span>
<span class="line" id="L294">                            .max = .{ .major = <span class="tok-number">6</span>, .minor = <span class="tok-number">2</span>, .patch = <span class="tok-number">0</span> },</span>
<span class="line" id="L295">                        },</span>
<span class="line" id="L296">                    },</span>
<span class="line" id="L297">                    .tvos =&gt; <span class="tok-kw">return</span> .{</span>
<span class="line" id="L298">                        .semver = .{</span>
<span class="line" id="L299">                            .min = .{ .major = <span class="tok-number">13</span>, .minor = <span class="tok-number">0</span> },</span>
<span class="line" id="L300">                            .max = .{ .major = <span class="tok-number">13</span>, .minor = <span class="tok-number">4</span>, .patch = <span class="tok-number">0</span> },</span>
<span class="line" id="L301">                        },</span>
<span class="line" id="L302">                    },</span>
<span class="line" id="L303">                    .netbsd =&gt; <span class="tok-kw">return</span> .{</span>
<span class="line" id="L304">                        .semver = .{</span>
<span class="line" id="L305">                            .min = .{ .major = <span class="tok-number">8</span>, .minor = <span class="tok-number">0</span> },</span>
<span class="line" id="L306">                            .max = .{ .major = <span class="tok-number">9</span>, .minor = <span class="tok-number">1</span> },</span>
<span class="line" id="L307">                        },</span>
<span class="line" id="L308">                    },</span>
<span class="line" id="L309">                    .openbsd =&gt; <span class="tok-kw">return</span> .{</span>
<span class="line" id="L310">                        .semver = .{</span>
<span class="line" id="L311">                            .min = .{ .major = <span class="tok-number">6</span>, .minor = <span class="tok-number">8</span> },</span>
<span class="line" id="L312">                            .max = .{ .major = <span class="tok-number">6</span>, .minor = <span class="tok-number">9</span> },</span>
<span class="line" id="L313">                        },</span>
<span class="line" id="L314">                    },</span>
<span class="line" id="L315">                    .dragonfly =&gt; <span class="tok-kw">return</span> .{</span>
<span class="line" id="L316">                        .semver = .{</span>
<span class="line" id="L317">                            .min = .{ .major = <span class="tok-number">5</span>, .minor = <span class="tok-number">8</span> },</span>
<span class="line" id="L318">                            .max = .{ .major = <span class="tok-number">6</span>, .minor = <span class="tok-number">0</span> },</span>
<span class="line" id="L319">                        },</span>
<span class="line" id="L320">                    },</span>
<span class="line" id="L321">                    .solaris =&gt; <span class="tok-kw">return</span> .{</span>
<span class="line" id="L322">                        .semver = .{</span>
<span class="line" id="L323">                            .min = .{ .major = <span class="tok-number">5</span>, .minor = <span class="tok-number">11</span> },</span>
<span class="line" id="L324">                            .max = .{ .major = <span class="tok-number">5</span>, .minor = <span class="tok-number">11</span> },</span>
<span class="line" id="L325">                        },</span>
<span class="line" id="L326">                    },</span>
<span class="line" id="L327"></span>
<span class="line" id="L328">                    .linux =&gt; <span class="tok-kw">return</span> .{</span>
<span class="line" id="L329">                        .linux = .{</span>
<span class="line" id="L330">                            .range = .{</span>
<span class="line" id="L331">                                .min = .{ .major = <span class="tok-number">3</span>, .minor = <span class="tok-number">16</span> },</span>
<span class="line" id="L332">                                .max = .{ .major = <span class="tok-number">5</span>, .minor = <span class="tok-number">10</span>, .patch = <span class="tok-number">81</span> },</span>
<span class="line" id="L333">                            },</span>
<span class="line" id="L334">                            .glibc = .{ .major = <span class="tok-number">2</span>, .minor = <span class="tok-number">19</span> },</span>
<span class="line" id="L335">                        },</span>
<span class="line" id="L336">                    },</span>
<span class="line" id="L337"></span>
<span class="line" id="L338">                    .windows =&gt; <span class="tok-kw">return</span> .{</span>
<span class="line" id="L339">                        .windows = .{</span>
<span class="line" id="L340">                            .min = .win8_1,</span>
<span class="line" id="L341">                            .max = WindowsVersion.latest,</span>
<span class="line" id="L342">                        },</span>
<span class="line" id="L343">                    },</span>
<span class="line" id="L344">                }</span>
<span class="line" id="L345">            }</span>
<span class="line" id="L346">        };</span>
<span class="line" id="L347"></span>
<span class="line" id="L348">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> TaggedVersionRange = <span class="tok-kw">union</span>(<span class="tok-kw">enum</span>) {</span>
<span class="line" id="L349">            none: <span class="tok-type">void</span>,</span>
<span class="line" id="L350">            semver: Version.Range,</span>
<span class="line" id="L351">            linux: LinuxVersionRange,</span>
<span class="line" id="L352">            windows: WindowsVersion.Range,</span>
<span class="line" id="L353">        };</span>
<span class="line" id="L354"></span>
<span class="line" id="L355">        <span class="tok-comment">/// Provides a tagged union. `Target` does not store the tag because it is</span></span>
<span class="line" id="L356">        <span class="tok-comment">/// redundant with the OS tag; this function abstracts that part away.</span></span>
<span class="line" id="L357">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">getVersionRange</span>(self: Os) TaggedVersionRange {</span>
<span class="line" id="L358">            <span class="tok-kw">switch</span> (self.tag) {</span>
<span class="line" id="L359">                .linux =&gt; <span class="tok-kw">return</span> TaggedVersionRange{ .linux = self.version_range.linux },</span>
<span class="line" id="L360">                .windows =&gt; <span class="tok-kw">return</span> TaggedVersionRange{ .windows = self.version_range.windows },</span>
<span class="line" id="L361"></span>
<span class="line" id="L362">                .freebsd,</span>
<span class="line" id="L363">                .macos,</span>
<span class="line" id="L364">                .ios,</span>
<span class="line" id="L365">                .tvos,</span>
<span class="line" id="L366">                .watchos,</span>
<span class="line" id="L367">                .netbsd,</span>
<span class="line" id="L368">                .openbsd,</span>
<span class="line" id="L369">                .dragonfly,</span>
<span class="line" id="L370">                .solaris,</span>
<span class="line" id="L371">                =&gt; <span class="tok-kw">return</span> TaggedVersionRange{ .semver = self.version_range.semver },</span>
<span class="line" id="L372"></span>
<span class="line" id="L373">                <span class="tok-kw">else</span> =&gt; <span class="tok-kw">return</span> .none,</span>
<span class="line" id="L374">            }</span>
<span class="line" id="L375">        }</span>
<span class="line" id="L376"></span>
<span class="line" id="L377">        <span class="tok-comment">/// Checks if system is guaranteed to be at least `version` or older than `version`.</span></span>
<span class="line" id="L378">        <span class="tok-comment">/// Returns `null` if a runtime check is required.</span></span>
<span class="line" id="L379">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">isAtLeast</span>(self: Os, <span class="tok-kw">comptime</span> tag: Tag, version: <span class="tok-kw">anytype</span>) ?<span class="tok-type">bool</span> {</span>
<span class="line" id="L380">            <span class="tok-kw">if</span> (self.tag != tag) <span class="tok-kw">return</span> <span class="tok-null">false</span>;</span>
<span class="line" id="L381"></span>
<span class="line" id="L382">            <span class="tok-kw">return</span> <span class="tok-kw">switch</span> (tag) {</span>
<span class="line" id="L383">                .linux =&gt; self.version_range.linux.isAtLeast(version),</span>
<span class="line" id="L384">                .windows =&gt; self.version_range.windows.isAtLeast(version),</span>
<span class="line" id="L385">                <span class="tok-kw">else</span> =&gt; self.version_range.semver.isAtLeast(version),</span>
<span class="line" id="L386">            };</span>
<span class="line" id="L387">        }</span>
<span class="line" id="L388"></span>
<span class="line" id="L389">        <span class="tok-comment">/// On Darwin, we always link libSystem which contains libc.</span></span>
<span class="line" id="L390">        <span class="tok-comment">/// Similarly on FreeBSD and NetBSD we always link system libc</span></span>
<span class="line" id="L391">        <span class="tok-comment">/// since this is the stable syscall interface.</span></span>
<span class="line" id="L392">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">requiresLibC</span>(os: Os) <span class="tok-type">bool</span> {</span>
<span class="line" id="L393">            <span class="tok-kw">return</span> <span class="tok-kw">switch</span> (os.tag) {</span>
<span class="line" id="L394">                .freebsd,</span>
<span class="line" id="L395">                .netbsd,</span>
<span class="line" id="L396">                .macos,</span>
<span class="line" id="L397">                .ios,</span>
<span class="line" id="L398">                .tvos,</span>
<span class="line" id="L399">                .watchos,</span>
<span class="line" id="L400">                .dragonfly,</span>
<span class="line" id="L401">                .openbsd,</span>
<span class="line" id="L402">                .haiku,</span>
<span class="line" id="L403">                .solaris,</span>
<span class="line" id="L404">                =&gt; <span class="tok-null">true</span>,</span>
<span class="line" id="L405"></span>
<span class="line" id="L406">                .linux,</span>
<span class="line" id="L407">                .windows,</span>
<span class="line" id="L408">                .freestanding,</span>
<span class="line" id="L409">                .ananas,</span>
<span class="line" id="L410">                .cloudabi,</span>
<span class="line" id="L411">                .fuchsia,</span>
<span class="line" id="L412">                .kfreebsd,</span>
<span class="line" id="L413">                .lv2,</span>
<span class="line" id="L414">                .zos,</span>
<span class="line" id="L415">                .minix,</span>
<span class="line" id="L416">                .rtems,</span>
<span class="line" id="L417">                .nacl,</span>
<span class="line" id="L418">                .aix,</span>
<span class="line" id="L419">                .cuda,</span>
<span class="line" id="L420">                .nvcl,</span>
<span class="line" id="L421">                .amdhsa,</span>
<span class="line" id="L422">                .ps4,</span>
<span class="line" id="L423">                .elfiamcu,</span>
<span class="line" id="L424">                .mesa3d,</span>
<span class="line" id="L425">                .contiki,</span>
<span class="line" id="L426">                .amdpal,</span>
<span class="line" id="L427">                .hermit,</span>
<span class="line" id="L428">                .hurd,</span>
<span class="line" id="L429">                .wasi,</span>
<span class="line" id="L430">                .emscripten,</span>
<span class="line" id="L431">                .uefi,</span>
<span class="line" id="L432">                .opencl,</span>
<span class="line" id="L433">                .glsl450,</span>
<span class="line" id="L434">                .vulkan,</span>
<span class="line" id="L435">                .plan9,</span>
<span class="line" id="L436">                .other,</span>
<span class="line" id="L437">                =&gt; <span class="tok-null">false</span>,</span>
<span class="line" id="L438">            };</span>
<span class="line" id="L439">        }</span>
<span class="line" id="L440">    };</span>
<span class="line" id="L441"></span>
<span class="line" id="L442">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> aarch64 = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;target/aarch64.zig&quot;</span>);</span>
<span class="line" id="L443">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> arc = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;target/arc.zig&quot;</span>);</span>
<span class="line" id="L444">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> amdgpu = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;target/amdgpu.zig&quot;</span>);</span>
<span class="line" id="L445">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> arm = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;target/arm.zig&quot;</span>);</span>
<span class="line" id="L446">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> avr = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;target/avr.zig&quot;</span>);</span>
<span class="line" id="L447">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> bpf = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;target/bpf.zig&quot;</span>);</span>
<span class="line" id="L448">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> csky = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;target/csky.zig&quot;</span>);</span>
<span class="line" id="L449">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> hexagon = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;target/hexagon.zig&quot;</span>);</span>
<span class="line" id="L450">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> mips = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;target/mips.zig&quot;</span>);</span>
<span class="line" id="L451">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> msp430 = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;target/msp430.zig&quot;</span>);</span>
<span class="line" id="L452">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> nvptx = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;target/nvptx.zig&quot;</span>);</span>
<span class="line" id="L453">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> powerpc = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;target/powerpc.zig&quot;</span>);</span>
<span class="line" id="L454">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> riscv = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;target/riscv.zig&quot;</span>);</span>
<span class="line" id="L455">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> sparc = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;target/sparc.zig&quot;</span>);</span>
<span class="line" id="L456">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> spirv = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;target/spirv.zig&quot;</span>);</span>
<span class="line" id="L457">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> s390x = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;target/s390x.zig&quot;</span>);</span>
<span class="line" id="L458">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> ve = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;target/ve.zig&quot;</span>);</span>
<span class="line" id="L459">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> wasm = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;target/wasm.zig&quot;</span>);</span>
<span class="line" id="L460">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> x86 = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;target/x86.zig&quot;</span>);</span>
<span class="line" id="L461"></span>
<span class="line" id="L462">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> Abi = <span class="tok-kw">enum</span> {</span>
<span class="line" id="L463">        none,</span>
<span class="line" id="L464">        gnu,</span>
<span class="line" id="L465">        gnuabin32,</span>
<span class="line" id="L466">        gnuabi64,</span>
<span class="line" id="L467">        gnueabi,</span>
<span class="line" id="L468">        gnueabihf,</span>
<span class="line" id="L469">        gnux32,</span>
<span class="line" id="L470">        gnuilp32,</span>
<span class="line" id="L471">        code16,</span>
<span class="line" id="L472">        eabi,</span>
<span class="line" id="L473">        eabihf,</span>
<span class="line" id="L474">        android,</span>
<span class="line" id="L475">        musl,</span>
<span class="line" id="L476">        musleabi,</span>
<span class="line" id="L477">        musleabihf,</span>
<span class="line" id="L478">        muslx32,</span>
<span class="line" id="L479">        msvc,</span>
<span class="line" id="L480">        itanium,</span>
<span class="line" id="L481">        cygnus,</span>
<span class="line" id="L482">        coreclr,</span>
<span class="line" id="L483">        simulator,</span>
<span class="line" id="L484">        macabi,</span>
<span class="line" id="L485"></span>
<span class="line" id="L486">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">default</span>(arch: Cpu.Arch, target_os: Os) Abi {</span>
<span class="line" id="L487">            <span class="tok-kw">if</span> (arch.isWasm()) {</span>
<span class="line" id="L488">                <span class="tok-kw">return</span> .musl;</span>
<span class="line" id="L489">            }</span>
<span class="line" id="L490">            <span class="tok-kw">switch</span> (target_os.tag) {</span>
<span class="line" id="L491">                .freestanding,</span>
<span class="line" id="L492">                .ananas,</span>
<span class="line" id="L493">                .cloudabi,</span>
<span class="line" id="L494">                .dragonfly,</span>
<span class="line" id="L495">                .lv2,</span>
<span class="line" id="L496">                .solaris,</span>
<span class="line" id="L497">                .zos,</span>
<span class="line" id="L498">                .minix,</span>
<span class="line" id="L499">                .rtems,</span>
<span class="line" id="L500">                .nacl,</span>
<span class="line" id="L501">                .aix,</span>
<span class="line" id="L502">                .cuda,</span>
<span class="line" id="L503">                .nvcl,</span>
<span class="line" id="L504">                .amdhsa,</span>
<span class="line" id="L505">                .ps4,</span>
<span class="line" id="L506">                .elfiamcu,</span>
<span class="line" id="L507">                .mesa3d,</span>
<span class="line" id="L508">                .contiki,</span>
<span class="line" id="L509">                .amdpal,</span>
<span class="line" id="L510">                .hermit,</span>
<span class="line" id="L511">                .other,</span>
<span class="line" id="L512">                =&gt; <span class="tok-kw">return</span> .eabi,</span>
<span class="line" id="L513">                .openbsd,</span>
<span class="line" id="L514">                .freebsd,</span>
<span class="line" id="L515">                .fuchsia,</span>
<span class="line" id="L516">                .kfreebsd,</span>
<span class="line" id="L517">                .netbsd,</span>
<span class="line" id="L518">                .hurd,</span>
<span class="line" id="L519">                .haiku,</span>
<span class="line" id="L520">                .windows,</span>
<span class="line" id="L521">                =&gt; <span class="tok-kw">return</span> .gnu,</span>
<span class="line" id="L522">                .uefi =&gt; <span class="tok-kw">return</span> .msvc,</span>
<span class="line" id="L523">                .linux,</span>
<span class="line" id="L524">                .wasi,</span>
<span class="line" id="L525">                .emscripten,</span>
<span class="line" id="L526">                =&gt; <span class="tok-kw">return</span> .musl,</span>
<span class="line" id="L527">                .opencl, <span class="tok-comment">// TODO: SPIR-V ABIs with Linkage capability</span>
</span>
<span class="line" id="L528">                .glsl450,</span>
<span class="line" id="L529">                .vulkan,</span>
<span class="line" id="L530">                .plan9, <span class="tok-comment">// TODO specify abi</span>
</span>
<span class="line" id="L531">                .macos,</span>
<span class="line" id="L532">                .ios,</span>
<span class="line" id="L533">                .tvos,</span>
<span class="line" id="L534">                .watchos,</span>
<span class="line" id="L535">                =&gt; <span class="tok-kw">return</span> .none,</span>
<span class="line" id="L536">            }</span>
<span class="line" id="L537">        }</span>
<span class="line" id="L538"></span>
<span class="line" id="L539">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">isGnu</span>(abi: Abi) <span class="tok-type">bool</span> {</span>
<span class="line" id="L540">            <span class="tok-kw">return</span> <span class="tok-kw">switch</span> (abi) {</span>
<span class="line" id="L541">                .gnu, .gnuabin32, .gnuabi64, .gnueabi, .gnueabihf, .gnux32 =&gt; <span class="tok-null">true</span>,</span>
<span class="line" id="L542">                <span class="tok-kw">else</span> =&gt; <span class="tok-null">false</span>,</span>
<span class="line" id="L543">            };</span>
<span class="line" id="L544">        }</span>
<span class="line" id="L545"></span>
<span class="line" id="L546">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">isMusl</span>(abi: Abi) <span class="tok-type">bool</span> {</span>
<span class="line" id="L547">            <span class="tok-kw">return</span> <span class="tok-kw">switch</span> (abi) {</span>
<span class="line" id="L548">                .musl, .musleabi, .musleabihf =&gt; <span class="tok-null">true</span>,</span>
<span class="line" id="L549">                <span class="tok-kw">else</span> =&gt; <span class="tok-null">false</span>,</span>
<span class="line" id="L550">            };</span>
<span class="line" id="L551">        }</span>
<span class="line" id="L552"></span>
<span class="line" id="L553">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">floatAbi</span>(abi: Abi) FloatAbi {</span>
<span class="line" id="L554">            <span class="tok-kw">return</span> <span class="tok-kw">switch</span> (abi) {</span>
<span class="line" id="L555">                .gnueabihf,</span>
<span class="line" id="L556">                .eabihf,</span>
<span class="line" id="L557">                .musleabihf,</span>
<span class="line" id="L558">                =&gt; .hard,</span>
<span class="line" id="L559">                <span class="tok-kw">else</span> =&gt; .soft,</span>
<span class="line" id="L560">            };</span>
<span class="line" id="L561">        }</span>
<span class="line" id="L562">    };</span>
<span class="line" id="L563"></span>
<span class="line" id="L564">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> ObjectFormat = <span class="tok-kw">enum</span> {</span>
<span class="line" id="L565">        <span class="tok-comment">/// Common Object File Format (Windows)</span></span>
<span class="line" id="L566">        coff,</span>
<span class="line" id="L567">        <span class="tok-comment">/// Executable and Linking Format</span></span>
<span class="line" id="L568">        elf,</span>
<span class="line" id="L569">        <span class="tok-comment">/// macOS relocatables</span></span>
<span class="line" id="L570">        macho,</span>
<span class="line" id="L571">        <span class="tok-comment">/// WebAssembly</span></span>
<span class="line" id="L572">        wasm,</span>
<span class="line" id="L573">        <span class="tok-comment">/// C source code</span></span>
<span class="line" id="L574">        c,</span>
<span class="line" id="L575">        <span class="tok-comment">/// Standard, Portable Intermediate Representation V</span></span>
<span class="line" id="L576">        spirv,</span>
<span class="line" id="L577">        <span class="tok-comment">/// Intel IHEX</span></span>
<span class="line" id="L578">        hex,</span>
<span class="line" id="L579">        <span class="tok-comment">/// Machine code with no metadata.</span></span>
<span class="line" id="L580">        raw,</span>
<span class="line" id="L581">        <span class="tok-comment">/// Plan 9 from Bell Labs</span></span>
<span class="line" id="L582">        plan9,</span>
<span class="line" id="L583">        <span class="tok-comment">/// Nvidia PTX format</span></span>
<span class="line" id="L584">        nvptx,</span>
<span class="line" id="L585"></span>
<span class="line" id="L586">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">fileExt</span>(of: ObjectFormat, cpu_arch: Cpu.Arch) [:<span class="tok-number">0</span>]<span class="tok-kw">const</span> <span class="tok-type">u8</span> {</span>
<span class="line" id="L587">            <span class="tok-kw">return</span> <span class="tok-kw">switch</span> (of) {</span>
<span class="line" id="L588">                .coff =&gt; <span class="tok-str">&quot;.obj&quot;</span>,</span>
<span class="line" id="L589">                .elf, .macho, .wasm =&gt; <span class="tok-str">&quot;.o&quot;</span>,</span>
<span class="line" id="L590">                .c =&gt; <span class="tok-str">&quot;.c&quot;</span>,</span>
<span class="line" id="L591">                .spirv =&gt; <span class="tok-str">&quot;.spv&quot;</span>,</span>
<span class="line" id="L592">                .hex =&gt; <span class="tok-str">&quot;.ihex&quot;</span>,</span>
<span class="line" id="L593">                .raw =&gt; <span class="tok-str">&quot;.bin&quot;</span>,</span>
<span class="line" id="L594">                .plan9 =&gt; plan9Ext(cpu_arch),</span>
<span class="line" id="L595">                .nvptx =&gt; <span class="tok-str">&quot;.ptx&quot;</span>,</span>
<span class="line" id="L596">            };</span>
<span class="line" id="L597">        }</span>
<span class="line" id="L598"></span>
<span class="line" id="L599">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">default</span>(os_tag: Os.Tag, cpu_arch: Cpu.Arch) ObjectFormat {</span>
<span class="line" id="L600">            <span class="tok-kw">return</span> <span class="tok-kw">switch</span> (os_tag) {</span>
<span class="line" id="L601">                .windows, .uefi =&gt; .coff,</span>
<span class="line" id="L602">                .ios, .macos, .watchos, .tvos =&gt; .macho,</span>
<span class="line" id="L603">                .plan9 =&gt; .plan9,</span>
<span class="line" id="L604">                <span class="tok-kw">else</span> =&gt; <span class="tok-kw">return</span> <span class="tok-kw">switch</span> (cpu_arch) {</span>
<span class="line" id="L605">                    .wasm32, .wasm64 =&gt; .wasm,</span>
<span class="line" id="L606">                    .spirv32, .spirv64 =&gt; .spirv,</span>
<span class="line" id="L607">                    .nvptx, .nvptx64 =&gt; .nvptx,</span>
<span class="line" id="L608">                    <span class="tok-kw">else</span> =&gt; .elf,</span>
<span class="line" id="L609">                },</span>
<span class="line" id="L610">            };</span>
<span class="line" id="L611">        }</span>
<span class="line" id="L612">    };</span>
<span class="line" id="L613"></span>
<span class="line" id="L614">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> SubSystem = <span class="tok-kw">enum</span> {</span>
<span class="line" id="L615">        Console,</span>
<span class="line" id="L616">        Windows,</span>
<span class="line" id="L617">        Posix,</span>
<span class="line" id="L618">        Native,</span>
<span class="line" id="L619">        EfiApplication,</span>
<span class="line" id="L620">        EfiBootServiceDriver,</span>
<span class="line" id="L621">        EfiRom,</span>
<span class="line" id="L622">        EfiRuntimeDriver,</span>
<span class="line" id="L623">    };</span>
<span class="line" id="L624"></span>
<span class="line" id="L625">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> Cpu = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L626">        <span class="tok-comment">/// Architecture</span></span>
<span class="line" id="L627">        arch: Arch,</span>
<span class="line" id="L628"></span>
<span class="line" id="L629">        <span class="tok-comment">/// The CPU model to target. It has a set of features</span></span>
<span class="line" id="L630">        <span class="tok-comment">/// which are overridden with the `features` field.</span></span>
<span class="line" id="L631">        model: *<span class="tok-kw">const</span> Model,</span>
<span class="line" id="L632"></span>
<span class="line" id="L633">        <span class="tok-comment">/// An explicit list of the entire CPU feature set. It may differ from the specific CPU model's features.</span></span>
<span class="line" id="L634">        features: Feature.Set,</span>
<span class="line" id="L635"></span>
<span class="line" id="L636">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> Feature = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L637">            <span class="tok-comment">/// The bit index into `Set`. Has a default value of `undefined` because the canonical</span></span>
<span class="line" id="L638">            <span class="tok-comment">/// structures are populated via comptime logic.</span></span>
<span class="line" id="L639">            index: Set.Index = <span class="tok-null">undefined</span>,</span>
<span class="line" id="L640"></span>
<span class="line" id="L641">            <span class="tok-comment">/// Has a default value of `undefined` because the canonical</span></span>
<span class="line" id="L642">            <span class="tok-comment">/// structures are populated via comptime logic.</span></span>
<span class="line" id="L643">            name: []<span class="tok-kw">const</span> <span class="tok-type">u8</span> = <span class="tok-null">undefined</span>,</span>
<span class="line" id="L644"></span>
<span class="line" id="L645">            <span class="tok-comment">/// If this corresponds to an LLVM-recognized feature, this will be populated;</span></span>
<span class="line" id="L646">            <span class="tok-comment">/// otherwise null.</span></span>
<span class="line" id="L647">            llvm_name: ?[:<span class="tok-number">0</span>]<span class="tok-kw">const</span> <span class="tok-type">u8</span>,</span>
<span class="line" id="L648"></span>
<span class="line" id="L649">            <span class="tok-comment">/// Human-friendly UTF-8 text.</span></span>
<span class="line" id="L650">            description: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>,</span>
<span class="line" id="L651"></span>
<span class="line" id="L652">            <span class="tok-comment">/// Sparse `Set` of features this depends on.</span></span>
<span class="line" id="L653">            dependencies: Set,</span>
<span class="line" id="L654"></span>
<span class="line" id="L655">            <span class="tok-comment">/// A bit set of all the features.</span></span>
<span class="line" id="L656">            <span class="tok-kw">pub</span> <span class="tok-kw">const</span> Set = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L657">                ints: [usize_count]<span class="tok-type">usize</span>,</span>
<span class="line" id="L658"></span>
<span class="line" id="L659">                <span class="tok-kw">pub</span> <span class="tok-kw">const</span> needed_bit_count = <span class="tok-number">288</span>;</span>
<span class="line" id="L660">                <span class="tok-kw">pub</span> <span class="tok-kw">const</span> byte_count = (needed_bit_count + <span class="tok-number">7</span>) / <span class="tok-number">8</span>;</span>
<span class="line" id="L661">                <span class="tok-kw">pub</span> <span class="tok-kw">const</span> usize_count = (byte_count + (<span class="tok-builtin">@sizeOf</span>(<span class="tok-type">usize</span>) - <span class="tok-number">1</span>)) / <span class="tok-builtin">@sizeOf</span>(<span class="tok-type">usize</span>);</span>
<span class="line" id="L662">                <span class="tok-kw">pub</span> <span class="tok-kw">const</span> Index = std.math.Log2Int(std.meta.Int(.unsigned, usize_count * <span class="tok-builtin">@bitSizeOf</span>(<span class="tok-type">usize</span>)));</span>
<span class="line" id="L663">                <span class="tok-kw">pub</span> <span class="tok-kw">const</span> ShiftInt = std.math.Log2Int(<span class="tok-type">usize</span>);</span>
<span class="line" id="L664"></span>
<span class="line" id="L665">                <span class="tok-kw">pub</span> <span class="tok-kw">const</span> empty = Set{ .ints = [<span class="tok-number">1</span>]<span class="tok-type">usize</span>{<span class="tok-number">0</span>} ** usize_count };</span>
<span class="line" id="L666">                <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">empty_workaround</span>() Set {</span>
<span class="line" id="L667">                    <span class="tok-kw">return</span> Set{ .ints = [<span class="tok-number">1</span>]<span class="tok-type">usize</span>{<span class="tok-number">0</span>} ** usize_count };</span>
<span class="line" id="L668">                }</span>
<span class="line" id="L669"></span>
<span class="line" id="L670">                <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">isEmpty</span>(set: Set) <span class="tok-type">bool</span> {</span>
<span class="line" id="L671">                    <span class="tok-kw">return</span> <span class="tok-kw">for</span> (set.ints) |x| {</span>
<span class="line" id="L672">                        <span class="tok-kw">if</span> (x != <span class="tok-number">0</span>) <span class="tok-kw">break</span> <span class="tok-null">false</span>;</span>
<span class="line" id="L673">                    } <span class="tok-kw">else</span> <span class="tok-null">true</span>;</span>
<span class="line" id="L674">                }</span>
<span class="line" id="L675"></span>
<span class="line" id="L676">                <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">isEnabled</span>(set: Set, arch_feature_index: Index) <span class="tok-type">bool</span> {</span>
<span class="line" id="L677">                    <span class="tok-kw">const</span> usize_index = arch_feature_index / <span class="tok-builtin">@bitSizeOf</span>(<span class="tok-type">usize</span>);</span>
<span class="line" id="L678">                    <span class="tok-kw">const</span> bit_index = <span class="tok-builtin">@intCast</span>(ShiftInt, arch_feature_index % <span class="tok-builtin">@bitSizeOf</span>(<span class="tok-type">usize</span>));</span>
<span class="line" id="L679">                    <span class="tok-kw">return</span> (set.ints[usize_index] &amp; (<span class="tok-builtin">@as</span>(<span class="tok-type">usize</span>, <span class="tok-number">1</span>) &lt;&lt; bit_index)) != <span class="tok-number">0</span>;</span>
<span class="line" id="L680">                }</span>
<span class="line" id="L681"></span>
<span class="line" id="L682">                <span class="tok-comment">/// Adds the specified feature but not its dependencies.</span></span>
<span class="line" id="L683">                <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">addFeature</span>(set: *Set, arch_feature_index: Index) <span class="tok-type">void</span> {</span>
<span class="line" id="L684">                    <span class="tok-kw">const</span> usize_index = arch_feature_index / <span class="tok-builtin">@bitSizeOf</span>(<span class="tok-type">usize</span>);</span>
<span class="line" id="L685">                    <span class="tok-kw">const</span> bit_index = <span class="tok-builtin">@intCast</span>(ShiftInt, arch_feature_index % <span class="tok-builtin">@bitSizeOf</span>(<span class="tok-type">usize</span>));</span>
<span class="line" id="L686">                    set.ints[usize_index] |= <span class="tok-builtin">@as</span>(<span class="tok-type">usize</span>, <span class="tok-number">1</span>) &lt;&lt; bit_index;</span>
<span class="line" id="L687">                }</span>
<span class="line" id="L688"></span>
<span class="line" id="L689">                <span class="tok-comment">/// Adds the specified feature set but not its dependencies.</span></span>
<span class="line" id="L690">                <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">addFeatureSet</span>(set: *Set, other_set: Set) <span class="tok-type">void</span> {</span>
<span class="line" id="L691">                    set.ints = <span class="tok-builtin">@as</span>(<span class="tok-builtin">@Vector</span>(usize_count, <span class="tok-type">usize</span>), set.ints) | <span class="tok-builtin">@as</span>(<span class="tok-builtin">@Vector</span>(usize_count, <span class="tok-type">usize</span>), other_set.ints);</span>
<span class="line" id="L692">                }</span>
<span class="line" id="L693"></span>
<span class="line" id="L694">                <span class="tok-comment">/// Removes the specified feature but not its dependents.</span></span>
<span class="line" id="L695">                <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">removeFeature</span>(set: *Set, arch_feature_index: Index) <span class="tok-type">void</span> {</span>
<span class="line" id="L696">                    <span class="tok-kw">const</span> usize_index = arch_feature_index / <span class="tok-builtin">@bitSizeOf</span>(<span class="tok-type">usize</span>);</span>
<span class="line" id="L697">                    <span class="tok-kw">const</span> bit_index = <span class="tok-builtin">@intCast</span>(ShiftInt, arch_feature_index % <span class="tok-builtin">@bitSizeOf</span>(<span class="tok-type">usize</span>));</span>
<span class="line" id="L698">                    set.ints[usize_index] &amp;= ~(<span class="tok-builtin">@as</span>(<span class="tok-type">usize</span>, <span class="tok-number">1</span>) &lt;&lt; bit_index);</span>
<span class="line" id="L699">                }</span>
<span class="line" id="L700"></span>
<span class="line" id="L701">                <span class="tok-comment">/// Removes the specified feature but not its dependents.</span></span>
<span class="line" id="L702">                <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">removeFeatureSet</span>(set: *Set, other_set: Set) <span class="tok-type">void</span> {</span>
<span class="line" id="L703">                    set.ints = <span class="tok-builtin">@as</span>(<span class="tok-builtin">@Vector</span>(usize_count, <span class="tok-type">usize</span>), set.ints) &amp; ~<span class="tok-builtin">@as</span>(<span class="tok-builtin">@Vector</span>(usize_count, <span class="tok-type">usize</span>), other_set.ints);</span>
<span class="line" id="L704">                }</span>
<span class="line" id="L705"></span>
<span class="line" id="L706">                <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">populateDependencies</span>(set: *Set, all_features_list: []<span class="tok-kw">const</span> Cpu.Feature) <span class="tok-type">void</span> {</span>
<span class="line" id="L707">                    <span class="tok-builtin">@setEvalBranchQuota</span>(<span class="tok-number">1000000</span>);</span>
<span class="line" id="L708"></span>
<span class="line" id="L709">                    <span class="tok-kw">var</span> old = set.ints;</span>
<span class="line" id="L710">                    <span class="tok-kw">while</span> (<span class="tok-null">true</span>) {</span>
<span class="line" id="L711">                        <span class="tok-kw">for</span> (all_features_list) |feature, index_usize| {</span>
<span class="line" id="L712">                            <span class="tok-kw">const</span> index = <span class="tok-builtin">@intCast</span>(Index, index_usize);</span>
<span class="line" id="L713">                            <span class="tok-kw">if</span> (set.isEnabled(index)) {</span>
<span class="line" id="L714">                                set.addFeatureSet(feature.dependencies);</span>
<span class="line" id="L715">                            }</span>
<span class="line" id="L716">                        }</span>
<span class="line" id="L717">                        <span class="tok-kw">const</span> nothing_changed = mem.eql(<span class="tok-type">usize</span>, &amp;old, &amp;set.ints);</span>
<span class="line" id="L718">                        <span class="tok-kw">if</span> (nothing_changed) <span class="tok-kw">return</span>;</span>
<span class="line" id="L719">                        old = set.ints;</span>
<span class="line" id="L720">                    }</span>
<span class="line" id="L721">                }</span>
<span class="line" id="L722"></span>
<span class="line" id="L723">                <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">asBytes</span>(set: *<span class="tok-kw">const</span> Set) *<span class="tok-kw">const</span> [byte_count]<span class="tok-type">u8</span> {</span>
<span class="line" id="L724">                    <span class="tok-kw">return</span> <span class="tok-builtin">@ptrCast</span>(*<span class="tok-kw">const</span> [byte_count]<span class="tok-type">u8</span>, &amp;set.ints);</span>
<span class="line" id="L725">                }</span>
<span class="line" id="L726"></span>
<span class="line" id="L727">                <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">eql</span>(set: Set, other_set: Set) <span class="tok-type">bool</span> {</span>
<span class="line" id="L728">                    <span class="tok-kw">return</span> mem.eql(<span class="tok-type">usize</span>, &amp;set.ints, &amp;other_set.ints);</span>
<span class="line" id="L729">                }</span>
<span class="line" id="L730"></span>
<span class="line" id="L731">                <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">isSuperSetOf</span>(set: Set, other_set: Set) <span class="tok-type">bool</span> {</span>
<span class="line" id="L732">                    <span class="tok-kw">const</span> V = <span class="tok-builtin">@Vector</span>(usize_count, <span class="tok-type">usize</span>);</span>
<span class="line" id="L733">                    <span class="tok-kw">const</span> set_v: V = set.ints;</span>
<span class="line" id="L734">                    <span class="tok-kw">const</span> other_v: V = other_set.ints;</span>
<span class="line" id="L735">                    <span class="tok-kw">return</span> <span class="tok-builtin">@reduce</span>(.And, (set_v &amp; other_v) == other_v);</span>
<span class="line" id="L736">                }</span>
<span class="line" id="L737">            };</span>
<span class="line" id="L738"></span>
<span class="line" id="L739">            <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">feature_set_fns</span>(<span class="tok-kw">comptime</span> F: <span class="tok-type">type</span>) <span class="tok-type">type</span> {</span>
<span class="line" id="L740">                <span class="tok-kw">return</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L741">                    <span class="tok-comment">/// Populates only the feature bits specified.</span></span>
<span class="line" id="L742">                    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">featureSet</span>(features: []<span class="tok-kw">const</span> F) Set {</span>
<span class="line" id="L743">                        <span class="tok-kw">var</span> x = Set.empty_workaround(); <span class="tok-comment">// TODO remove empty_workaround</span>
</span>
<span class="line" id="L744">                        <span class="tok-kw">for</span> (features) |feature| {</span>
<span class="line" id="L745">                            x.addFeature(<span class="tok-builtin">@enumToInt</span>(feature));</span>
<span class="line" id="L746">                        }</span>
<span class="line" id="L747">                        <span class="tok-kw">return</span> x;</span>
<span class="line" id="L748">                    }</span>
<span class="line" id="L749"></span>
<span class="line" id="L750">                    <span class="tok-comment">/// Returns true if the specified feature is enabled.</span></span>
<span class="line" id="L751">                    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">featureSetHas</span>(set: Set, feature: F) <span class="tok-type">bool</span> {</span>
<span class="line" id="L752">                        <span class="tok-kw">return</span> set.isEnabled(<span class="tok-builtin">@enumToInt</span>(feature));</span>
<span class="line" id="L753">                    }</span>
<span class="line" id="L754"></span>
<span class="line" id="L755">                    <span class="tok-comment">/// Returns true if any specified feature is enabled.</span></span>
<span class="line" id="L756">                    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">featureSetHasAny</span>(set: Set, features: <span class="tok-kw">anytype</span>) <span class="tok-type">bool</span> {</span>
<span class="line" id="L757">                        <span class="tok-kw">comptime</span> std.debug.assert(std.meta.trait.isIndexable(<span class="tok-builtin">@TypeOf</span>(features)));</span>
<span class="line" id="L758">                        <span class="tok-kw">inline</span> <span class="tok-kw">for</span> (features) |feature| {</span>
<span class="line" id="L759">                            <span class="tok-kw">if</span> (set.isEnabled(<span class="tok-builtin">@enumToInt</span>(<span class="tok-builtin">@as</span>(F, feature)))) <span class="tok-kw">return</span> <span class="tok-null">true</span>;</span>
<span class="line" id="L760">                        }</span>
<span class="line" id="L761">                        <span class="tok-kw">return</span> <span class="tok-null">false</span>;</span>
<span class="line" id="L762">                    }</span>
<span class="line" id="L763"></span>
<span class="line" id="L764">                    <span class="tok-comment">/// Returns true if every specified feature is enabled.</span></span>
<span class="line" id="L765">                    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">featureSetHasAll</span>(set: Set, features: <span class="tok-kw">anytype</span>) <span class="tok-type">bool</span> {</span>
<span class="line" id="L766">                        <span class="tok-kw">comptime</span> std.debug.assert(std.meta.trait.isIndexable(<span class="tok-builtin">@TypeOf</span>(features)));</span>
<span class="line" id="L767">                        <span class="tok-kw">inline</span> <span class="tok-kw">for</span> (features) |feature| {</span>
<span class="line" id="L768">                            <span class="tok-kw">if</span> (!set.isEnabled(<span class="tok-builtin">@enumToInt</span>(<span class="tok-builtin">@as</span>(F, feature)))) <span class="tok-kw">return</span> <span class="tok-null">false</span>;</span>
<span class="line" id="L769">                        }</span>
<span class="line" id="L770">                        <span class="tok-kw">return</span> <span class="tok-null">true</span>;</span>
<span class="line" id="L771">                    }</span>
<span class="line" id="L772">                };</span>
<span class="line" id="L773">            }</span>
<span class="line" id="L774">        };</span>
<span class="line" id="L775"></span>
<span class="line" id="L776">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> Arch = <span class="tok-kw">enum</span> {</span>
<span class="line" id="L777">            arm,</span>
<span class="line" id="L778">            armeb,</span>
<span class="line" id="L779">            aarch64,</span>
<span class="line" id="L780">            aarch64_be,</span>
<span class="line" id="L781">            aarch64_32,</span>
<span class="line" id="L782">            arc,</span>
<span class="line" id="L783">            avr,</span>
<span class="line" id="L784">            bpfel,</span>
<span class="line" id="L785">            bpfeb,</span>
<span class="line" id="L786">            csky,</span>
<span class="line" id="L787">            hexagon,</span>
<span class="line" id="L788">            m68k,</span>
<span class="line" id="L789">            mips,</span>
<span class="line" id="L790">            mipsel,</span>
<span class="line" id="L791">            mips64,</span>
<span class="line" id="L792">            mips64el,</span>
<span class="line" id="L793">            msp430,</span>
<span class="line" id="L794">            powerpc,</span>
<span class="line" id="L795">            powerpcle,</span>
<span class="line" id="L796">            powerpc64,</span>
<span class="line" id="L797">            powerpc64le,</span>
<span class="line" id="L798">            r600,</span>
<span class="line" id="L799">            amdgcn,</span>
<span class="line" id="L800">            riscv32,</span>
<span class="line" id="L801">            riscv64,</span>
<span class="line" id="L802">            sparc,</span>
<span class="line" id="L803">            sparc64,</span>
<span class="line" id="L804">            sparcel,</span>
<span class="line" id="L805">            s390x,</span>
<span class="line" id="L806">            tce,</span>
<span class="line" id="L807">            tcele,</span>
<span class="line" id="L808">            thumb,</span>
<span class="line" id="L809">            thumbeb,</span>
<span class="line" id="L810">            <span class="tok-type">i386</span>,</span>
<span class="line" id="L811">            x86_64,</span>
<span class="line" id="L812">            xcore,</span>
<span class="line" id="L813">            nvptx,</span>
<span class="line" id="L814">            nvptx64,</span>
<span class="line" id="L815">            le32,</span>
<span class="line" id="L816">            le64,</span>
<span class="line" id="L817">            amdil,</span>
<span class="line" id="L818">            amdil64,</span>
<span class="line" id="L819">            hsail,</span>
<span class="line" id="L820">            hsail64,</span>
<span class="line" id="L821">            spir,</span>
<span class="line" id="L822">            spir64,</span>
<span class="line" id="L823">            spirv32,</span>
<span class="line" id="L824">            spirv64,</span>
<span class="line" id="L825">            kalimba,</span>
<span class="line" id="L826">            shave,</span>
<span class="line" id="L827">            lanai,</span>
<span class="line" id="L828">            wasm32,</span>
<span class="line" id="L829">            wasm64,</span>
<span class="line" id="L830">            renderscript32,</span>
<span class="line" id="L831">            renderscript64,</span>
<span class="line" id="L832">            ve,</span>
<span class="line" id="L833">            <span class="tok-comment">// Stage1 currently assumes that architectures above this comment</span>
</span>
<span class="line" id="L834">            <span class="tok-comment">// map one-to-one with the ZigLLVM_ArchType enum.</span>
</span>
<span class="line" id="L835">            spu_2,</span>
<span class="line" id="L836"></span>
<span class="line" id="L837">            <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">isX86</span>(arch: Arch) <span class="tok-type">bool</span> {</span>
<span class="line" id="L838">                <span class="tok-kw">return</span> <span class="tok-kw">switch</span> (arch) {</span>
<span class="line" id="L839">                    .<span class="tok-type">i386</span>, .x86_64 =&gt; <span class="tok-null">true</span>,</span>
<span class="line" id="L840">                    <span class="tok-kw">else</span> =&gt; <span class="tok-null">false</span>,</span>
<span class="line" id="L841">                };</span>
<span class="line" id="L842">            }</span>
<span class="line" id="L843"></span>
<span class="line" id="L844">            <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">isARM</span>(arch: Arch) <span class="tok-type">bool</span> {</span>
<span class="line" id="L845">                <span class="tok-kw">return</span> <span class="tok-kw">switch</span> (arch) {</span>
<span class="line" id="L846">                    .arm, .armeb =&gt; <span class="tok-null">true</span>,</span>
<span class="line" id="L847">                    <span class="tok-kw">else</span> =&gt; <span class="tok-null">false</span>,</span>
<span class="line" id="L848">                };</span>
<span class="line" id="L849">            }</span>
<span class="line" id="L850"></span>
<span class="line" id="L851">            <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">isAARCH64</span>(arch: Arch) <span class="tok-type">bool</span> {</span>
<span class="line" id="L852">                <span class="tok-kw">return</span> <span class="tok-kw">switch</span> (arch) {</span>
<span class="line" id="L853">                    .aarch64, .aarch64_be, .aarch64_32 =&gt; <span class="tok-null">true</span>,</span>
<span class="line" id="L854">                    <span class="tok-kw">else</span> =&gt; <span class="tok-null">false</span>,</span>
<span class="line" id="L855">                };</span>
<span class="line" id="L856">            }</span>
<span class="line" id="L857"></span>
<span class="line" id="L858">            <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">isThumb</span>(arch: Arch) <span class="tok-type">bool</span> {</span>
<span class="line" id="L859">                <span class="tok-kw">return</span> <span class="tok-kw">switch</span> (arch) {</span>
<span class="line" id="L860">                    .thumb, .thumbeb =&gt; <span class="tok-null">true</span>,</span>
<span class="line" id="L861">                    <span class="tok-kw">else</span> =&gt; <span class="tok-null">false</span>,</span>
<span class="line" id="L862">                };</span>
<span class="line" id="L863">            }</span>
<span class="line" id="L864"></span>
<span class="line" id="L865">            <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">isWasm</span>(arch: Arch) <span class="tok-type">bool</span> {</span>
<span class="line" id="L866">                <span class="tok-kw">return</span> <span class="tok-kw">switch</span> (arch) {</span>
<span class="line" id="L867">                    .wasm32, .wasm64 =&gt; <span class="tok-null">true</span>,</span>
<span class="line" id="L868">                    <span class="tok-kw">else</span> =&gt; <span class="tok-null">false</span>,</span>
<span class="line" id="L869">                };</span>
<span class="line" id="L870">            }</span>
<span class="line" id="L871"></span>
<span class="line" id="L872">            <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">isRISCV</span>(arch: Arch) <span class="tok-type">bool</span> {</span>
<span class="line" id="L873">                <span class="tok-kw">return</span> <span class="tok-kw">switch</span> (arch) {</span>
<span class="line" id="L874">                    .riscv32, .riscv64 =&gt; <span class="tok-null">true</span>,</span>
<span class="line" id="L875">                    <span class="tok-kw">else</span> =&gt; <span class="tok-null">false</span>,</span>
<span class="line" id="L876">                };</span>
<span class="line" id="L877">            }</span>
<span class="line" id="L878"></span>
<span class="line" id="L879">            <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">isMIPS</span>(arch: Arch) <span class="tok-type">bool</span> {</span>
<span class="line" id="L880">                <span class="tok-kw">return</span> <span class="tok-kw">switch</span> (arch) {</span>
<span class="line" id="L881">                    .mips, .mipsel, .mips64, .mips64el =&gt; <span class="tok-null">true</span>,</span>
<span class="line" id="L882">                    <span class="tok-kw">else</span> =&gt; <span class="tok-null">false</span>,</span>
<span class="line" id="L883">                };</span>
<span class="line" id="L884">            }</span>
<span class="line" id="L885"></span>
<span class="line" id="L886">            <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">isPPC</span>(arch: Arch) <span class="tok-type">bool</span> {</span>
<span class="line" id="L887">                <span class="tok-kw">return</span> <span class="tok-kw">switch</span> (arch) {</span>
<span class="line" id="L888">                    .powerpc, .powerpcle =&gt; <span class="tok-null">true</span>,</span>
<span class="line" id="L889">                    <span class="tok-kw">else</span> =&gt; <span class="tok-null">false</span>,</span>
<span class="line" id="L890">                };</span>
<span class="line" id="L891">            }</span>
<span class="line" id="L892"></span>
<span class="line" id="L893">            <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">isPPC64</span>(arch: Arch) <span class="tok-type">bool</span> {</span>
<span class="line" id="L894">                <span class="tok-kw">return</span> <span class="tok-kw">switch</span> (arch) {</span>
<span class="line" id="L895">                    .powerpc64, .powerpc64le =&gt; <span class="tok-null">true</span>,</span>
<span class="line" id="L896">                    <span class="tok-kw">else</span> =&gt; <span class="tok-null">false</span>,</span>
<span class="line" id="L897">                };</span>
<span class="line" id="L898">            }</span>
<span class="line" id="L899"></span>
<span class="line" id="L900">            <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">isSPARC</span>(arch: Arch) <span class="tok-type">bool</span> {</span>
<span class="line" id="L901">                <span class="tok-kw">return</span> <span class="tok-kw">switch</span> (arch) {</span>
<span class="line" id="L902">                    .sparc, .sparcel, .sparc64 =&gt; <span class="tok-null">true</span>,</span>
<span class="line" id="L903">                    <span class="tok-kw">else</span> =&gt; <span class="tok-null">false</span>,</span>
<span class="line" id="L904">                };</span>
<span class="line" id="L905">            }</span>
<span class="line" id="L906"></span>
<span class="line" id="L907">            <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">isSPIRV</span>(arch: Arch) <span class="tok-type">bool</span> {</span>
<span class="line" id="L908">                <span class="tok-kw">return</span> <span class="tok-kw">switch</span> (arch) {</span>
<span class="line" id="L909">                    .spirv32, .spirv64 =&gt; <span class="tok-null">true</span>,</span>
<span class="line" id="L910">                    <span class="tok-kw">else</span> =&gt; <span class="tok-null">false</span>,</span>
<span class="line" id="L911">                };</span>
<span class="line" id="L912">            }</span>
<span class="line" id="L913"></span>
<span class="line" id="L914">            <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">isBpf</span>(arch: Arch) <span class="tok-type">bool</span> {</span>
<span class="line" id="L915">                <span class="tok-kw">return</span> <span class="tok-kw">switch</span> (arch) {</span>
<span class="line" id="L916">                    .bpfel, .bpfeb =&gt; <span class="tok-null">true</span>,</span>
<span class="line" id="L917">                    <span class="tok-kw">else</span> =&gt; <span class="tok-null">false</span>,</span>
<span class="line" id="L918">                };</span>
<span class="line" id="L919">            }</span>
<span class="line" id="L920"></span>
<span class="line" id="L921">            <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">parseCpuModel</span>(arch: Arch, cpu_name: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) !*<span class="tok-kw">const</span> Cpu.Model {</span>
<span class="line" id="L922">                <span class="tok-kw">for</span> (arch.allCpuModels()) |cpu| {</span>
<span class="line" id="L923">                    <span class="tok-kw">if</span> (mem.eql(<span class="tok-type">u8</span>, cpu_name, cpu.name)) {</span>
<span class="line" id="L924">                        <span class="tok-kw">return</span> cpu;</span>
<span class="line" id="L925">                    }</span>
<span class="line" id="L926">                }</span>
<span class="line" id="L927">                <span class="tok-kw">return</span> <span class="tok-kw">error</span>.UnknownCpuModel;</span>
<span class="line" id="L928">            }</span>
<span class="line" id="L929"></span>
<span class="line" id="L930">            <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">toElfMachine</span>(arch: Arch) std.elf.EM {</span>
<span class="line" id="L931">                <span class="tok-kw">return</span> <span class="tok-kw">switch</span> (arch) {</span>
<span class="line" id="L932">                    .avr =&gt; .AVR,</span>
<span class="line" id="L933">                    .msp430 =&gt; .MSP430,</span>
<span class="line" id="L934">                    .arc =&gt; .ARC,</span>
<span class="line" id="L935">                    .arm =&gt; .ARM,</span>
<span class="line" id="L936">                    .armeb =&gt; .ARM,</span>
<span class="line" id="L937">                    .hexagon =&gt; .HEXAGON,</span>
<span class="line" id="L938">                    .m68k =&gt; .@&quot;68K&quot;,</span>
<span class="line" id="L939">                    .le32 =&gt; .NONE,</span>
<span class="line" id="L940">                    .mips =&gt; .MIPS,</span>
<span class="line" id="L941">                    .mipsel =&gt; .MIPS_RS3_LE,</span>
<span class="line" id="L942">                    .powerpc, .powerpcle =&gt; .PPC,</span>
<span class="line" id="L943">                    .r600 =&gt; .NONE,</span>
<span class="line" id="L944">                    .riscv32 =&gt; .RISCV,</span>
<span class="line" id="L945">                    .sparc =&gt; .SPARC,</span>
<span class="line" id="L946">                    .sparcel =&gt; .SPARC,</span>
<span class="line" id="L947">                    .tce =&gt; .NONE,</span>
<span class="line" id="L948">                    .tcele =&gt; .NONE,</span>
<span class="line" id="L949">                    .thumb =&gt; .ARM,</span>
<span class="line" id="L950">                    .thumbeb =&gt; .ARM,</span>
<span class="line" id="L951">                    .<span class="tok-type">i386</span> =&gt; .@&quot;386&quot;,</span>
<span class="line" id="L952">                    .xcore =&gt; .XCORE,</span>
<span class="line" id="L953">                    .nvptx =&gt; .NONE,</span>
<span class="line" id="L954">                    .amdil =&gt; .NONE,</span>
<span class="line" id="L955">                    .hsail =&gt; .NONE,</span>
<span class="line" id="L956">                    .spir =&gt; .NONE,</span>
<span class="line" id="L957">                    .kalimba =&gt; .CSR_KALIMBA,</span>
<span class="line" id="L958">                    .shave =&gt; .NONE,</span>
<span class="line" id="L959">                    .lanai =&gt; .LANAI,</span>
<span class="line" id="L960">                    .wasm32 =&gt; .NONE,</span>
<span class="line" id="L961">                    .renderscript32 =&gt; .NONE,</span>
<span class="line" id="L962">                    .aarch64_32 =&gt; .AARCH64,</span>
<span class="line" id="L963">                    .aarch64 =&gt; .AARCH64,</span>
<span class="line" id="L964">                    .aarch64_be =&gt; .AARCH64,</span>
<span class="line" id="L965">                    .mips64 =&gt; .MIPS,</span>
<span class="line" id="L966">                    .mips64el =&gt; .MIPS_RS3_LE,</span>
<span class="line" id="L967">                    .powerpc64 =&gt; .PPC64,</span>
<span class="line" id="L968">                    .powerpc64le =&gt; .PPC64,</span>
<span class="line" id="L969">                    .riscv64 =&gt; .RISCV,</span>
<span class="line" id="L970">                    .x86_64 =&gt; .X86_64,</span>
<span class="line" id="L971">                    .nvptx64 =&gt; .NONE,</span>
<span class="line" id="L972">                    .le64 =&gt; .NONE,</span>
<span class="line" id="L973">                    .amdil64 =&gt; .NONE,</span>
<span class="line" id="L974">                    .hsail64 =&gt; .NONE,</span>
<span class="line" id="L975">                    .spir64 =&gt; .NONE,</span>
<span class="line" id="L976">                    .wasm64 =&gt; .NONE,</span>
<span class="line" id="L977">                    .renderscript64 =&gt; .NONE,</span>
<span class="line" id="L978">                    .amdgcn =&gt; .NONE,</span>
<span class="line" id="L979">                    .bpfel =&gt; .BPF,</span>
<span class="line" id="L980">                    .bpfeb =&gt; .BPF,</span>
<span class="line" id="L981">                    .csky =&gt; .CSKY,</span>
<span class="line" id="L982">                    .sparc64 =&gt; .SPARCV9,</span>
<span class="line" id="L983">                    .s390x =&gt; .S390,</span>
<span class="line" id="L984">                    .ve =&gt; .NONE,</span>
<span class="line" id="L985">                    .spu_2 =&gt; .SPU_2,</span>
<span class="line" id="L986">                    .spirv32 =&gt; .NONE,</span>
<span class="line" id="L987">                    .spirv64 =&gt; .NONE,</span>
<span class="line" id="L988">                };</span>
<span class="line" id="L989">            }</span>
<span class="line" id="L990"></span>
<span class="line" id="L991">            <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">toCoffMachine</span>(arch: Arch) std.coff.MachineType {</span>
<span class="line" id="L992">                <span class="tok-kw">return</span> <span class="tok-kw">switch</span> (arch) {</span>
<span class="line" id="L993">                    .avr =&gt; .Unknown,</span>
<span class="line" id="L994">                    .msp430 =&gt; .Unknown,</span>
<span class="line" id="L995">                    .arc =&gt; .Unknown,</span>
<span class="line" id="L996">                    .arm =&gt; .ARM,</span>
<span class="line" id="L997">                    .armeb =&gt; .Unknown,</span>
<span class="line" id="L998">                    .hexagon =&gt; .Unknown,</span>
<span class="line" id="L999">                    .m68k =&gt; .Unknown,</span>
<span class="line" id="L1000">                    .le32 =&gt; .Unknown,</span>
<span class="line" id="L1001">                    .mips =&gt; .Unknown,</span>
<span class="line" id="L1002">                    .mipsel =&gt; .Unknown,</span>
<span class="line" id="L1003">                    .powerpc, .powerpcle =&gt; .POWERPC,</span>
<span class="line" id="L1004">                    .r600 =&gt; .Unknown,</span>
<span class="line" id="L1005">                    .riscv32 =&gt; .RISCV32,</span>
<span class="line" id="L1006">                    .sparc =&gt; .Unknown,</span>
<span class="line" id="L1007">                    .sparcel =&gt; .Unknown,</span>
<span class="line" id="L1008">                    .tce =&gt; .Unknown,</span>
<span class="line" id="L1009">                    .tcele =&gt; .Unknown,</span>
<span class="line" id="L1010">                    .thumb =&gt; .Thumb,</span>
<span class="line" id="L1011">                    .thumbeb =&gt; .Thumb,</span>
<span class="line" id="L1012">                    .<span class="tok-type">i386</span> =&gt; .I386,</span>
<span class="line" id="L1013">                    .xcore =&gt; .Unknown,</span>
<span class="line" id="L1014">                    .nvptx =&gt; .Unknown,</span>
<span class="line" id="L1015">                    .amdil =&gt; .Unknown,</span>
<span class="line" id="L1016">                    .hsail =&gt; .Unknown,</span>
<span class="line" id="L1017">                    .spir =&gt; .Unknown,</span>
<span class="line" id="L1018">                    .kalimba =&gt; .Unknown,</span>
<span class="line" id="L1019">                    .shave =&gt; .Unknown,</span>
<span class="line" id="L1020">                    .lanai =&gt; .Unknown,</span>
<span class="line" id="L1021">                    .wasm32 =&gt; .Unknown,</span>
<span class="line" id="L1022">                    .renderscript32 =&gt; .Unknown,</span>
<span class="line" id="L1023">                    .aarch64_32 =&gt; .ARM64,</span>
<span class="line" id="L1024">                    .aarch64 =&gt; .ARM64,</span>
<span class="line" id="L1025">                    .aarch64_be =&gt; .Unknown,</span>
<span class="line" id="L1026">                    .mips64 =&gt; .Unknown,</span>
<span class="line" id="L1027">                    .mips64el =&gt; .Unknown,</span>
<span class="line" id="L1028">                    .powerpc64 =&gt; .Unknown,</span>
<span class="line" id="L1029">                    .powerpc64le =&gt; .Unknown,</span>
<span class="line" id="L1030">                    .riscv64 =&gt; .RISCV64,</span>
<span class="line" id="L1031">                    .x86_64 =&gt; .X64,</span>
<span class="line" id="L1032">                    .nvptx64 =&gt; .Unknown,</span>
<span class="line" id="L1033">                    .le64 =&gt; .Unknown,</span>
<span class="line" id="L1034">                    .amdil64 =&gt; .Unknown,</span>
<span class="line" id="L1035">                    .hsail64 =&gt; .Unknown,</span>
<span class="line" id="L1036">                    .spir64 =&gt; .Unknown,</span>
<span class="line" id="L1037">                    .wasm64 =&gt; .Unknown,</span>
<span class="line" id="L1038">                    .renderscript64 =&gt; .Unknown,</span>
<span class="line" id="L1039">                    .amdgcn =&gt; .Unknown,</span>
<span class="line" id="L1040">                    .bpfel =&gt; .Unknown,</span>
<span class="line" id="L1041">                    .bpfeb =&gt; .Unknown,</span>
<span class="line" id="L1042">                    .csky =&gt; .Unknown,</span>
<span class="line" id="L1043">                    .sparc64 =&gt; .Unknown,</span>
<span class="line" id="L1044">                    .s390x =&gt; .Unknown,</span>
<span class="line" id="L1045">                    .ve =&gt; .Unknown,</span>
<span class="line" id="L1046">                    .spu_2 =&gt; .Unknown,</span>
<span class="line" id="L1047">                    .spirv32 =&gt; .Unknown,</span>
<span class="line" id="L1048">                    .spirv64 =&gt; .Unknown,</span>
<span class="line" id="L1049">                };</span>
<span class="line" id="L1050">            }</span>
<span class="line" id="L1051"></span>
<span class="line" id="L1052">            <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">endian</span>(arch: Arch) std.builtin.Endian {</span>
<span class="line" id="L1053">                <span class="tok-kw">return</span> <span class="tok-kw">switch</span> (arch) {</span>
<span class="line" id="L1054">                    .avr,</span>
<span class="line" id="L1055">                    .arm,</span>
<span class="line" id="L1056">                    .aarch64_32,</span>
<span class="line" id="L1057">                    .aarch64,</span>
<span class="line" id="L1058">                    .amdgcn,</span>
<span class="line" id="L1059">                    .amdil,</span>
<span class="line" id="L1060">                    .amdil64,</span>
<span class="line" id="L1061">                    .bpfel,</span>
<span class="line" id="L1062">                    .csky,</span>
<span class="line" id="L1063">                    .hexagon,</span>
<span class="line" id="L1064">                    .hsail,</span>
<span class="line" id="L1065">                    .hsail64,</span>
<span class="line" id="L1066">                    .kalimba,</span>
<span class="line" id="L1067">                    .le32,</span>
<span class="line" id="L1068">                    .le64,</span>
<span class="line" id="L1069">                    .mipsel,</span>
<span class="line" id="L1070">                    .mips64el,</span>
<span class="line" id="L1071">                    .msp430,</span>
<span class="line" id="L1072">                    .nvptx,</span>
<span class="line" id="L1073">                    .nvptx64,</span>
<span class="line" id="L1074">                    .sparcel,</span>
<span class="line" id="L1075">                    .tcele,</span>
<span class="line" id="L1076">                    .powerpcle,</span>
<span class="line" id="L1077">                    .powerpc64le,</span>
<span class="line" id="L1078">                    .r600,</span>
<span class="line" id="L1079">                    .riscv32,</span>
<span class="line" id="L1080">                    .riscv64,</span>
<span class="line" id="L1081">                    .<span class="tok-type">i386</span>,</span>
<span class="line" id="L1082">                    .x86_64,</span>
<span class="line" id="L1083">                    .wasm32,</span>
<span class="line" id="L1084">                    .wasm64,</span>
<span class="line" id="L1085">                    .xcore,</span>
<span class="line" id="L1086">                    .thumb,</span>
<span class="line" id="L1087">                    .spir,</span>
<span class="line" id="L1088">                    .spir64,</span>
<span class="line" id="L1089">                    .renderscript32,</span>
<span class="line" id="L1090">                    .renderscript64,</span>
<span class="line" id="L1091">                    .shave,</span>
<span class="line" id="L1092">                    .ve,</span>
<span class="line" id="L1093">                    .spu_2,</span>
<span class="line" id="L1094">                    <span class="tok-comment">// GPU bitness is opaque. For now, assume little endian.</span>
</span>
<span class="line" id="L1095">                    .spirv32,</span>
<span class="line" id="L1096">                    .spirv64,</span>
<span class="line" id="L1097">                    =&gt; .Little,</span>
<span class="line" id="L1098"></span>
<span class="line" id="L1099">                    .arc,</span>
<span class="line" id="L1100">                    .armeb,</span>
<span class="line" id="L1101">                    .aarch64_be,</span>
<span class="line" id="L1102">                    .bpfeb,</span>
<span class="line" id="L1103">                    .m68k,</span>
<span class="line" id="L1104">                    .mips,</span>
<span class="line" id="L1105">                    .mips64,</span>
<span class="line" id="L1106">                    .powerpc,</span>
<span class="line" id="L1107">                    .powerpc64,</span>
<span class="line" id="L1108">                    .thumbeb,</span>
<span class="line" id="L1109">                    .sparc,</span>
<span class="line" id="L1110">                    .sparc64,</span>
<span class="line" id="L1111">                    .tce,</span>
<span class="line" id="L1112">                    .lanai,</span>
<span class="line" id="L1113">                    .s390x,</span>
<span class="line" id="L1114">                    =&gt; .Big,</span>
<span class="line" id="L1115">                };</span>
<span class="line" id="L1116">            }</span>
<span class="line" id="L1117"></span>
<span class="line" id="L1118">            <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">ptrBitWidth</span>(arch: Arch) <span class="tok-type">u16</span> {</span>
<span class="line" id="L1119">                <span class="tok-kw">switch</span> (arch) {</span>
<span class="line" id="L1120">                    .avr,</span>
<span class="line" id="L1121">                    .msp430,</span>
<span class="line" id="L1122">                    .spu_2,</span>
<span class="line" id="L1123">                    =&gt; <span class="tok-kw">return</span> <span class="tok-number">16</span>,</span>
<span class="line" id="L1124"></span>
<span class="line" id="L1125">                    .arc,</span>
<span class="line" id="L1126">                    .arm,</span>
<span class="line" id="L1127">                    .armeb,</span>
<span class="line" id="L1128">                    .csky,</span>
<span class="line" id="L1129">                    .hexagon,</span>
<span class="line" id="L1130">                    .m68k,</span>
<span class="line" id="L1131">                    .le32,</span>
<span class="line" id="L1132">                    .mips,</span>
<span class="line" id="L1133">                    .mipsel,</span>
<span class="line" id="L1134">                    .powerpc,</span>
<span class="line" id="L1135">                    .powerpcle,</span>
<span class="line" id="L1136">                    .r600,</span>
<span class="line" id="L1137">                    .riscv32,</span>
<span class="line" id="L1138">                    .sparc,</span>
<span class="line" id="L1139">                    .sparcel,</span>
<span class="line" id="L1140">                    .tce,</span>
<span class="line" id="L1141">                    .tcele,</span>
<span class="line" id="L1142">                    .thumb,</span>
<span class="line" id="L1143">                    .thumbeb,</span>
<span class="line" id="L1144">                    .<span class="tok-type">i386</span>,</span>
<span class="line" id="L1145">                    .xcore,</span>
<span class="line" id="L1146">                    .nvptx,</span>
<span class="line" id="L1147">                    .amdil,</span>
<span class="line" id="L1148">                    .hsail,</span>
<span class="line" id="L1149">                    .spir,</span>
<span class="line" id="L1150">                    .kalimba,</span>
<span class="line" id="L1151">                    .shave,</span>
<span class="line" id="L1152">                    .lanai,</span>
<span class="line" id="L1153">                    .wasm32,</span>
<span class="line" id="L1154">                    .renderscript32,</span>
<span class="line" id="L1155">                    .aarch64_32,</span>
<span class="line" id="L1156">                    .spirv32,</span>
<span class="line" id="L1157">                    =&gt; <span class="tok-kw">return</span> <span class="tok-number">32</span>,</span>
<span class="line" id="L1158"></span>
<span class="line" id="L1159">                    .aarch64,</span>
<span class="line" id="L1160">                    .aarch64_be,</span>
<span class="line" id="L1161">                    .mips64,</span>
<span class="line" id="L1162">                    .mips64el,</span>
<span class="line" id="L1163">                    .powerpc64,</span>
<span class="line" id="L1164">                    .powerpc64le,</span>
<span class="line" id="L1165">                    .riscv64,</span>
<span class="line" id="L1166">                    .x86_64,</span>
<span class="line" id="L1167">                    .nvptx64,</span>
<span class="line" id="L1168">                    .le64,</span>
<span class="line" id="L1169">                    .amdil64,</span>
<span class="line" id="L1170">                    .hsail64,</span>
<span class="line" id="L1171">                    .spir64,</span>
<span class="line" id="L1172">                    .wasm64,</span>
<span class="line" id="L1173">                    .renderscript64,</span>
<span class="line" id="L1174">                    .amdgcn,</span>
<span class="line" id="L1175">                    .bpfel,</span>
<span class="line" id="L1176">                    .bpfeb,</span>
<span class="line" id="L1177">                    .sparc64,</span>
<span class="line" id="L1178">                    .s390x,</span>
<span class="line" id="L1179">                    .ve,</span>
<span class="line" id="L1180">                    .spirv64,</span>
<span class="line" id="L1181">                    =&gt; <span class="tok-kw">return</span> <span class="tok-number">64</span>,</span>
<span class="line" id="L1182">                }</span>
<span class="line" id="L1183">            }</span>
<span class="line" id="L1184"></span>
<span class="line" id="L1185">            <span class="tok-comment">/// Returns a name that matches the lib/std/target/* source file name.</span></span>
<span class="line" id="L1186">            <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">genericName</span>(arch: Arch) []<span class="tok-kw">const</span> <span class="tok-type">u8</span> {</span>
<span class="line" id="L1187">                <span class="tok-kw">return</span> <span class="tok-kw">switch</span> (arch) {</span>
<span class="line" id="L1188">                    .arm, .armeb, .thumb, .thumbeb =&gt; <span class="tok-str">&quot;arm&quot;</span>,</span>
<span class="line" id="L1189">                    .aarch64, .aarch64_be, .aarch64_32 =&gt; <span class="tok-str">&quot;aarch64&quot;</span>,</span>
<span class="line" id="L1190">                    .bpfel, .bpfeb =&gt; <span class="tok-str">&quot;bpf&quot;</span>,</span>
<span class="line" id="L1191">                    .mips, .mipsel, .mips64, .mips64el =&gt; <span class="tok-str">&quot;mips&quot;</span>,</span>
<span class="line" id="L1192">                    .powerpc, .powerpcle, .powerpc64, .powerpc64le =&gt; <span class="tok-str">&quot;powerpc&quot;</span>,</span>
<span class="line" id="L1193">                    .amdgcn =&gt; <span class="tok-str">&quot;amdgpu&quot;</span>,</span>
<span class="line" id="L1194">                    .riscv32, .riscv64 =&gt; <span class="tok-str">&quot;riscv&quot;</span>,</span>
<span class="line" id="L1195">                    .sparc, .sparc64, .sparcel =&gt; <span class="tok-str">&quot;sparc&quot;</span>,</span>
<span class="line" id="L1196">                    .s390x =&gt; <span class="tok-str">&quot;s390x&quot;</span>,</span>
<span class="line" id="L1197">                    .<span class="tok-type">i386</span>, .x86_64 =&gt; <span class="tok-str">&quot;x86&quot;</span>,</span>
<span class="line" id="L1198">                    .nvptx, .nvptx64 =&gt; <span class="tok-str">&quot;nvptx&quot;</span>,</span>
<span class="line" id="L1199">                    .wasm32, .wasm64 =&gt; <span class="tok-str">&quot;wasm&quot;</span>,</span>
<span class="line" id="L1200">                    .spirv32, .spirv64 =&gt; <span class="tok-str">&quot;spir-v&quot;</span>,</span>
<span class="line" id="L1201">                    <span class="tok-kw">else</span> =&gt; <span class="tok-builtin">@tagName</span>(arch),</span>
<span class="line" id="L1202">                };</span>
<span class="line" id="L1203">            }</span>
<span class="line" id="L1204"></span>
<span class="line" id="L1205">            <span class="tok-comment">/// All CPU features Zig is aware of, sorted lexicographically by name.</span></span>
<span class="line" id="L1206">            <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">allFeaturesList</span>(arch: Arch) []<span class="tok-kw">const</span> Cpu.Feature {</span>
<span class="line" id="L1207">                <span class="tok-kw">return</span> <span class="tok-kw">switch</span> (arch) {</span>
<span class="line" id="L1208">                    .arm, .armeb, .thumb, .thumbeb =&gt; &amp;arm.all_features,</span>
<span class="line" id="L1209">                    .aarch64, .aarch64_be, .aarch64_32 =&gt; &amp;aarch64.all_features,</span>
<span class="line" id="L1210">                    .avr =&gt; &amp;avr.all_features,</span>
<span class="line" id="L1211">                    .bpfel, .bpfeb =&gt; &amp;bpf.all_features,</span>
<span class="line" id="L1212">                    .hexagon =&gt; &amp;hexagon.all_features,</span>
<span class="line" id="L1213">                    .mips, .mipsel, .mips64, .mips64el =&gt; &amp;mips.all_features,</span>
<span class="line" id="L1214">                    .msp430 =&gt; &amp;msp430.all_features,</span>
<span class="line" id="L1215">                    .powerpc, .powerpcle, .powerpc64, .powerpc64le =&gt; &amp;powerpc.all_features,</span>
<span class="line" id="L1216">                    .amdgcn =&gt; &amp;amdgpu.all_features,</span>
<span class="line" id="L1217">                    .riscv32, .riscv64 =&gt; &amp;riscv.all_features,</span>
<span class="line" id="L1218">                    .sparc, .sparc64, .sparcel =&gt; &amp;sparc.all_features,</span>
<span class="line" id="L1219">                    .spirv32, .spirv64 =&gt; &amp;spirv.all_features,</span>
<span class="line" id="L1220">                    .s390x =&gt; &amp;s390x.all_features,</span>
<span class="line" id="L1221">                    .<span class="tok-type">i386</span>, .x86_64 =&gt; &amp;x86.all_features,</span>
<span class="line" id="L1222">                    .nvptx, .nvptx64 =&gt; &amp;nvptx.all_features,</span>
<span class="line" id="L1223">                    .ve =&gt; &amp;ve.all_features,</span>
<span class="line" id="L1224">                    .wasm32, .wasm64 =&gt; &amp;wasm.all_features,</span>
<span class="line" id="L1225"></span>
<span class="line" id="L1226">                    <span class="tok-kw">else</span> =&gt; &amp;[<span class="tok-number">0</span>]Cpu.Feature{},</span>
<span class="line" id="L1227">                };</span>
<span class="line" id="L1228">            }</span>
<span class="line" id="L1229"></span>
<span class="line" id="L1230">            <span class="tok-comment">/// All processors Zig is aware of, sorted lexicographically by name.</span></span>
<span class="line" id="L1231">            <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">allCpuModels</span>(arch: Arch) []<span class="tok-kw">const</span> *<span class="tok-kw">const</span> Cpu.Model {</span>
<span class="line" id="L1232">                <span class="tok-kw">return</span> <span class="tok-kw">switch</span> (arch) {</span>
<span class="line" id="L1233">                    .arm, .armeb, .thumb, .thumbeb =&gt; <span class="tok-kw">comptime</span> allCpusFromDecls(arm.cpu),</span>
<span class="line" id="L1234">                    .aarch64, .aarch64_be, .aarch64_32 =&gt; <span class="tok-kw">comptime</span> allCpusFromDecls(aarch64.cpu),</span>
<span class="line" id="L1235">                    .avr =&gt; <span class="tok-kw">comptime</span> allCpusFromDecls(avr.cpu),</span>
<span class="line" id="L1236">                    .bpfel, .bpfeb =&gt; <span class="tok-kw">comptime</span> allCpusFromDecls(bpf.cpu),</span>
<span class="line" id="L1237">                    .hexagon =&gt; <span class="tok-kw">comptime</span> allCpusFromDecls(hexagon.cpu),</span>
<span class="line" id="L1238">                    .mips, .mipsel, .mips64, .mips64el =&gt; <span class="tok-kw">comptime</span> allCpusFromDecls(mips.cpu),</span>
<span class="line" id="L1239">                    .msp430 =&gt; <span class="tok-kw">comptime</span> allCpusFromDecls(msp430.cpu),</span>
<span class="line" id="L1240">                    .powerpc, .powerpcle, .powerpc64, .powerpc64le =&gt; <span class="tok-kw">comptime</span> allCpusFromDecls(powerpc.cpu),</span>
<span class="line" id="L1241">                    .amdgcn =&gt; <span class="tok-kw">comptime</span> allCpusFromDecls(amdgpu.cpu),</span>
<span class="line" id="L1242">                    .riscv32, .riscv64 =&gt; <span class="tok-kw">comptime</span> allCpusFromDecls(riscv.cpu),</span>
<span class="line" id="L1243">                    .sparc, .sparc64, .sparcel =&gt; <span class="tok-kw">comptime</span> allCpusFromDecls(sparc.cpu),</span>
<span class="line" id="L1244">                    .s390x =&gt; <span class="tok-kw">comptime</span> allCpusFromDecls(s390x.cpu),</span>
<span class="line" id="L1245">                    .<span class="tok-type">i386</span>, .x86_64 =&gt; <span class="tok-kw">comptime</span> allCpusFromDecls(x86.cpu),</span>
<span class="line" id="L1246">                    .nvptx, .nvptx64 =&gt; <span class="tok-kw">comptime</span> allCpusFromDecls(nvptx.cpu),</span>
<span class="line" id="L1247">                    .ve =&gt; <span class="tok-kw">comptime</span> allCpusFromDecls(ve.cpu),</span>
<span class="line" id="L1248">                    .wasm32, .wasm64 =&gt; <span class="tok-kw">comptime</span> allCpusFromDecls(wasm.cpu),</span>
<span class="line" id="L1249"></span>
<span class="line" id="L1250">                    <span class="tok-kw">else</span> =&gt; &amp;[<span class="tok-number">0</span>]*<span class="tok-kw">const</span> Model{},</span>
<span class="line" id="L1251">                };</span>
<span class="line" id="L1252">            }</span>
<span class="line" id="L1253"></span>
<span class="line" id="L1254">            <span class="tok-kw">fn</span> <span class="tok-fn">allCpusFromDecls</span>(<span class="tok-kw">comptime</span> cpus: <span class="tok-type">type</span>) []<span class="tok-kw">const</span> *<span class="tok-kw">const</span> Cpu.Model {</span>
<span class="line" id="L1255">                <span class="tok-kw">const</span> decls = <span class="tok-builtin">@typeInfo</span>(cpus).Struct.decls;</span>
<span class="line" id="L1256">                <span class="tok-kw">var</span> array: [decls.len]*<span class="tok-kw">const</span> Cpu.Model = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L1257">                <span class="tok-kw">for</span> (decls) |decl, i| {</span>
<span class="line" id="L1258">                    array[i] = &amp;<span class="tok-builtin">@field</span>(cpus, decl.name);</span>
<span class="line" id="L1259">                }</span>
<span class="line" id="L1260">                <span class="tok-kw">return</span> &amp;array;</span>
<span class="line" id="L1261">            }</span>
<span class="line" id="L1262">        };</span>
<span class="line" id="L1263"></span>
<span class="line" id="L1264">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> Model = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L1265">            name: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>,</span>
<span class="line" id="L1266">            llvm_name: ?[:<span class="tok-number">0</span>]<span class="tok-kw">const</span> <span class="tok-type">u8</span>,</span>
<span class="line" id="L1267">            features: Feature.Set,</span>
<span class="line" id="L1268"></span>
<span class="line" id="L1269">            <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">toCpu</span>(model: *<span class="tok-kw">const</span> Model, arch: Arch) Cpu {</span>
<span class="line" id="L1270">                <span class="tok-kw">var</span> features = model.features;</span>
<span class="line" id="L1271">                features.populateDependencies(arch.allFeaturesList());</span>
<span class="line" id="L1272">                <span class="tok-kw">return</span> .{</span>
<span class="line" id="L1273">                    .arch = arch,</span>
<span class="line" id="L1274">                    .model = model,</span>
<span class="line" id="L1275">                    .features = features,</span>
<span class="line" id="L1276">                };</span>
<span class="line" id="L1277">            }</span>
<span class="line" id="L1278"></span>
<span class="line" id="L1279">            <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">generic</span>(arch: Arch) *<span class="tok-kw">const</span> Model {</span>
<span class="line" id="L1280">                <span class="tok-kw">const</span> S = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L1281">                    <span class="tok-kw">const</span> generic_model = Model{</span>
<span class="line" id="L1282">                        .name = <span class="tok-str">&quot;generic&quot;</span>,</span>
<span class="line" id="L1283">                        .llvm_name = <span class="tok-null">null</span>,</span>
<span class="line" id="L1284">                        .features = Cpu.Feature.Set.empty,</span>
<span class="line" id="L1285">                    };</span>
<span class="line" id="L1286">                };</span>
<span class="line" id="L1287">                <span class="tok-kw">return</span> <span class="tok-kw">switch</span> (arch) {</span>
<span class="line" id="L1288">                    .arm, .armeb, .thumb, .thumbeb =&gt; &amp;arm.cpu.generic,</span>
<span class="line" id="L1289">                    .aarch64, .aarch64_be, .aarch64_32 =&gt; &amp;aarch64.cpu.generic,</span>
<span class="line" id="L1290">                    .avr =&gt; &amp;avr.cpu.avr2,</span>
<span class="line" id="L1291">                    .bpfel, .bpfeb =&gt; &amp;bpf.cpu.generic,</span>
<span class="line" id="L1292">                    .hexagon =&gt; &amp;hexagon.cpu.generic,</span>
<span class="line" id="L1293">                    .mips, .mipsel =&gt; &amp;mips.cpu.mips32,</span>
<span class="line" id="L1294">                    .mips64, .mips64el =&gt; &amp;mips.cpu.mips64,</span>
<span class="line" id="L1295">                    .msp430 =&gt; &amp;msp430.cpu.generic,</span>
<span class="line" id="L1296">                    .powerpc =&gt; &amp;powerpc.cpu.ppc,</span>
<span class="line" id="L1297">                    .powerpcle =&gt; &amp;powerpc.cpu.ppc,</span>
<span class="line" id="L1298">                    .powerpc64 =&gt; &amp;powerpc.cpu.ppc64,</span>
<span class="line" id="L1299">                    .powerpc64le =&gt; &amp;powerpc.cpu.ppc64le,</span>
<span class="line" id="L1300">                    .amdgcn =&gt; &amp;amdgpu.cpu.generic,</span>
<span class="line" id="L1301">                    .riscv32 =&gt; &amp;riscv.cpu.generic_rv32,</span>
<span class="line" id="L1302">                    .riscv64 =&gt; &amp;riscv.cpu.generic_rv64,</span>
<span class="line" id="L1303">                    .sparc, .sparcel =&gt; &amp;sparc.cpu.generic,</span>
<span class="line" id="L1304">                    .sparc64 =&gt; &amp;sparc.cpu.v9, <span class="tok-comment">// 64-bit SPARC needs v9 as the baseline</span>
</span>
<span class="line" id="L1305">                    .s390x =&gt; &amp;s390x.cpu.generic,</span>
<span class="line" id="L1306">                    .<span class="tok-type">i386</span> =&gt; &amp;x86.cpu.<span class="tok-type">i386</span>,</span>
<span class="line" id="L1307">                    .x86_64 =&gt; &amp;x86.cpu.x86_64,</span>
<span class="line" id="L1308">                    .nvptx, .nvptx64 =&gt; &amp;nvptx.cpu.sm_20,</span>
<span class="line" id="L1309">                    .ve =&gt; &amp;ve.cpu.generic,</span>
<span class="line" id="L1310">                    .wasm32, .wasm64 =&gt; &amp;wasm.cpu.generic,</span>
<span class="line" id="L1311"></span>
<span class="line" id="L1312">                    <span class="tok-kw">else</span> =&gt; &amp;S.generic_model,</span>
<span class="line" id="L1313">                };</span>
<span class="line" id="L1314">            }</span>
<span class="line" id="L1315"></span>
<span class="line" id="L1316">            <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">baseline</span>(arch: Arch) *<span class="tok-kw">const</span> Model {</span>
<span class="line" id="L1317">                <span class="tok-kw">return</span> <span class="tok-kw">switch</span> (arch) {</span>
<span class="line" id="L1318">                    .arm, .armeb, .thumb, .thumbeb =&gt; &amp;arm.cpu.baseline,</span>
<span class="line" id="L1319">                    .riscv32 =&gt; &amp;riscv.cpu.baseline_rv32,</span>
<span class="line" id="L1320">                    .riscv64 =&gt; &amp;riscv.cpu.baseline_rv64,</span>
<span class="line" id="L1321">                    .<span class="tok-type">i386</span> =&gt; &amp;x86.cpu.pentium4,</span>
<span class="line" id="L1322">                    .nvptx, .nvptx64 =&gt; &amp;nvptx.cpu.sm_20,</span>
<span class="line" id="L1323">                    .sparc, .sparcel =&gt; &amp;sparc.cpu.v8,</span>
<span class="line" id="L1324"></span>
<span class="line" id="L1325">                    <span class="tok-kw">else</span> =&gt; generic(arch),</span>
<span class="line" id="L1326">                };</span>
<span class="line" id="L1327">            }</span>
<span class="line" id="L1328">        };</span>
<span class="line" id="L1329"></span>
<span class="line" id="L1330">        <span class="tok-comment">/// The &quot;default&quot; set of CPU features for cross-compiling. A conservative set</span></span>
<span class="line" id="L1331">        <span class="tok-comment">/// of features that is expected to be supported on most available hardware.</span></span>
<span class="line" id="L1332">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">baseline</span>(arch: Arch) Cpu {</span>
<span class="line" id="L1333">            <span class="tok-kw">return</span> Model.baseline(arch).toCpu(arch);</span>
<span class="line" id="L1334">        }</span>
<span class="line" id="L1335">    };</span>
<span class="line" id="L1336"></span>
<span class="line" id="L1337">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> stack_align = <span class="tok-number">16</span>;</span>
<span class="line" id="L1338"></span>
<span class="line" id="L1339">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">zigTriple</span>(self: Target, allocator: mem.Allocator) ![]<span class="tok-type">u8</span> {</span>
<span class="line" id="L1340">        <span class="tok-kw">return</span> std.zig.CrossTarget.fromTarget(self).zigTriple(allocator);</span>
<span class="line" id="L1341">    }</span>
<span class="line" id="L1342"></span>
<span class="line" id="L1343">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">linuxTripleSimple</span>(allocator: mem.Allocator, cpu_arch: Cpu.Arch, os_tag: Os.Tag, abi: Abi) ![]<span class="tok-type">u8</span> {</span>
<span class="line" id="L1344">        <span class="tok-kw">return</span> std.fmt.allocPrint(allocator, <span class="tok-str">&quot;{s}-{s}-{s}&quot;</span>, .{ <span class="tok-builtin">@tagName</span>(cpu_arch), <span class="tok-builtin">@tagName</span>(os_tag), <span class="tok-builtin">@tagName</span>(abi) });</span>
<span class="line" id="L1345">    }</span>
<span class="line" id="L1346"></span>
<span class="line" id="L1347">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">linuxTriple</span>(self: Target, allocator: mem.Allocator) ![]<span class="tok-type">u8</span> {</span>
<span class="line" id="L1348">        <span class="tok-kw">return</span> linuxTripleSimple(allocator, self.cpu.arch, self.os.tag, self.abi);</span>
<span class="line" id="L1349">    }</span>
<span class="line" id="L1350"></span>
<span class="line" id="L1351">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">exeFileExtSimple</span>(cpu_arch: Cpu.Arch, os_tag: Os.Tag) [:<span class="tok-number">0</span>]<span class="tok-kw">const</span> <span class="tok-type">u8</span> {</span>
<span class="line" id="L1352">        <span class="tok-kw">return</span> <span class="tok-kw">switch</span> (os_tag) {</span>
<span class="line" id="L1353">            .windows =&gt; <span class="tok-str">&quot;.exe&quot;</span>,</span>
<span class="line" id="L1354">            .uefi =&gt; <span class="tok-str">&quot;.efi&quot;</span>,</span>
<span class="line" id="L1355">            .plan9 =&gt; plan9Ext(cpu_arch),</span>
<span class="line" id="L1356">            <span class="tok-kw">else</span> =&gt; <span class="tok-kw">switch</span> (cpu_arch) {</span>
<span class="line" id="L1357">                .wasm32, .wasm64 =&gt; <span class="tok-str">&quot;.wasm&quot;</span>,</span>
<span class="line" id="L1358">                <span class="tok-kw">else</span> =&gt; <span class="tok-str">&quot;&quot;</span>,</span>
<span class="line" id="L1359">            },</span>
<span class="line" id="L1360">        };</span>
<span class="line" id="L1361">    }</span>
<span class="line" id="L1362"></span>
<span class="line" id="L1363">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">exeFileExt</span>(self: Target) [:<span class="tok-number">0</span>]<span class="tok-kw">const</span> <span class="tok-type">u8</span> {</span>
<span class="line" id="L1364">        <span class="tok-kw">return</span> exeFileExtSimple(self.cpu.arch, self.os.tag);</span>
<span class="line" id="L1365">    }</span>
<span class="line" id="L1366"></span>
<span class="line" id="L1367">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">staticLibSuffix_os_abi</span>(os_tag: Os.Tag, abi: Abi) [:<span class="tok-number">0</span>]<span class="tok-kw">const</span> <span class="tok-type">u8</span> {</span>
<span class="line" id="L1368">        <span class="tok-kw">if</span> (abi == .msvc) {</span>
<span class="line" id="L1369">            <span class="tok-kw">return</span> <span class="tok-str">&quot;.lib&quot;</span>;</span>
<span class="line" id="L1370">        }</span>
<span class="line" id="L1371">        <span class="tok-kw">switch</span> (os_tag) {</span>
<span class="line" id="L1372">            .windows, .uefi =&gt; <span class="tok-kw">return</span> <span class="tok-str">&quot;.lib&quot;</span>,</span>
<span class="line" id="L1373">            <span class="tok-kw">else</span> =&gt; <span class="tok-kw">return</span> <span class="tok-str">&quot;.a&quot;</span>,</span>
<span class="line" id="L1374">        }</span>
<span class="line" id="L1375">    }</span>
<span class="line" id="L1376"></span>
<span class="line" id="L1377">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">staticLibSuffix</span>(self: Target) [:<span class="tok-number">0</span>]<span class="tok-kw">const</span> <span class="tok-type">u8</span> {</span>
<span class="line" id="L1378">        <span class="tok-kw">return</span> staticLibSuffix_os_abi(self.os.tag, self.abi);</span>
<span class="line" id="L1379">    }</span>
<span class="line" id="L1380"></span>
<span class="line" id="L1381">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">dynamicLibSuffix</span>(self: Target) [:<span class="tok-number">0</span>]<span class="tok-kw">const</span> <span class="tok-type">u8</span> {</span>
<span class="line" id="L1382">        <span class="tok-kw">return</span> self.os.tag.dynamicLibSuffix();</span>
<span class="line" id="L1383">    }</span>
<span class="line" id="L1384"></span>
<span class="line" id="L1385">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">libPrefix_os_abi</span>(os_tag: Os.Tag, abi: Abi) [:<span class="tok-number">0</span>]<span class="tok-kw">const</span> <span class="tok-type">u8</span> {</span>
<span class="line" id="L1386">        <span class="tok-kw">if</span> (abi == .msvc) {</span>
<span class="line" id="L1387">            <span class="tok-kw">return</span> <span class="tok-str">&quot;&quot;</span>;</span>
<span class="line" id="L1388">        }</span>
<span class="line" id="L1389">        <span class="tok-kw">switch</span> (os_tag) {</span>
<span class="line" id="L1390">            .windows, .uefi =&gt; <span class="tok-kw">return</span> <span class="tok-str">&quot;&quot;</span>,</span>
<span class="line" id="L1391">            <span class="tok-kw">else</span> =&gt; <span class="tok-kw">return</span> <span class="tok-str">&quot;lib&quot;</span>,</span>
<span class="line" id="L1392">        }</span>
<span class="line" id="L1393">    }</span>
<span class="line" id="L1394"></span>
<span class="line" id="L1395">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">libPrefix</span>(self: Target) [:<span class="tok-number">0</span>]<span class="tok-kw">const</span> <span class="tok-type">u8</span> {</span>
<span class="line" id="L1396">        <span class="tok-kw">return</span> libPrefix_os_abi(self.os.tag, self.abi);</span>
<span class="line" id="L1397">    }</span>
<span class="line" id="L1398"></span>
<span class="line" id="L1399">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">isMinGW</span>(self: Target) <span class="tok-type">bool</span> {</span>
<span class="line" id="L1400">        <span class="tok-kw">return</span> self.os.tag == .windows <span class="tok-kw">and</span> self.isGnu();</span>
<span class="line" id="L1401">    }</span>
<span class="line" id="L1402"></span>
<span class="line" id="L1403">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">isGnu</span>(self: Target) <span class="tok-type">bool</span> {</span>
<span class="line" id="L1404">        <span class="tok-kw">return</span> self.abi.isGnu();</span>
<span class="line" id="L1405">    }</span>
<span class="line" id="L1406"></span>
<span class="line" id="L1407">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">isMusl</span>(self: Target) <span class="tok-type">bool</span> {</span>
<span class="line" id="L1408">        <span class="tok-kw">return</span> self.abi.isMusl();</span>
<span class="line" id="L1409">    }</span>
<span class="line" id="L1410"></span>
<span class="line" id="L1411">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">isAndroid</span>(self: Target) <span class="tok-type">bool</span> {</span>
<span class="line" id="L1412">        <span class="tok-kw">return</span> self.abi == .android;</span>
<span class="line" id="L1413">    }</span>
<span class="line" id="L1414"></span>
<span class="line" id="L1415">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">isWasm</span>(self: Target) <span class="tok-type">bool</span> {</span>
<span class="line" id="L1416">        <span class="tok-kw">return</span> self.cpu.arch.isWasm();</span>
<span class="line" id="L1417">    }</span>
<span class="line" id="L1418"></span>
<span class="line" id="L1419">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">isDarwin</span>(self: Target) <span class="tok-type">bool</span> {</span>
<span class="line" id="L1420">        <span class="tok-kw">return</span> self.os.tag.isDarwin();</span>
<span class="line" id="L1421">    }</span>
<span class="line" id="L1422"></span>
<span class="line" id="L1423">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">isBSD</span>(self: Target) <span class="tok-type">bool</span> {</span>
<span class="line" id="L1424">        <span class="tok-kw">return</span> self.os.tag.isBSD();</span>
<span class="line" id="L1425">    }</span>
<span class="line" id="L1426"></span>
<span class="line" id="L1427">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">isBpfFreestanding</span>(self: Target) <span class="tok-type">bool</span> {</span>
<span class="line" id="L1428">        <span class="tok-kw">return</span> self.cpu.arch.isBpf() <span class="tok-kw">and</span> self.os.tag == .freestanding;</span>
<span class="line" id="L1429">    }</span>
<span class="line" id="L1430"></span>
<span class="line" id="L1431">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">isGnuLibC_os_tag_abi</span>(os_tag: Os.Tag, abi: Abi) <span class="tok-type">bool</span> {</span>
<span class="line" id="L1432">        <span class="tok-kw">return</span> os_tag == .linux <span class="tok-kw">and</span> abi.isGnu();</span>
<span class="line" id="L1433">    }</span>
<span class="line" id="L1434"></span>
<span class="line" id="L1435">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">isGnuLibC</span>(self: Target) <span class="tok-type">bool</span> {</span>
<span class="line" id="L1436">        <span class="tok-kw">return</span> isGnuLibC_os_tag_abi(self.os.tag, self.abi);</span>
<span class="line" id="L1437">    }</span>
<span class="line" id="L1438"></span>
<span class="line" id="L1439">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">supportsNewStackCall</span>(self: Target) <span class="tok-type">bool</span> {</span>
<span class="line" id="L1440">        <span class="tok-kw">return</span> !self.cpu.arch.isWasm();</span>
<span class="line" id="L1441">    }</span>
<span class="line" id="L1442"></span>
<span class="line" id="L1443">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> FloatAbi = <span class="tok-kw">enum</span> {</span>
<span class="line" id="L1444">        hard,</span>
<span class="line" id="L1445">        soft,</span>
<span class="line" id="L1446">        soft_fp,</span>
<span class="line" id="L1447">    };</span>
<span class="line" id="L1448"></span>
<span class="line" id="L1449">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">getFloatAbi</span>(self: Target) FloatAbi {</span>
<span class="line" id="L1450">        <span class="tok-kw">return</span> self.abi.floatAbi();</span>
<span class="line" id="L1451">    }</span>
<span class="line" id="L1452"></span>
<span class="line" id="L1453">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">hasDynamicLinker</span>(self: Target) <span class="tok-type">bool</span> {</span>
<span class="line" id="L1454">        <span class="tok-kw">if</span> (self.cpu.arch.isWasm()) {</span>
<span class="line" id="L1455">            <span class="tok-kw">return</span> <span class="tok-null">false</span>;</span>
<span class="line" id="L1456">        }</span>
<span class="line" id="L1457">        <span class="tok-kw">switch</span> (self.os.tag) {</span>
<span class="line" id="L1458">            .freestanding,</span>
<span class="line" id="L1459">            .ios,</span>
<span class="line" id="L1460">            .tvos,</span>
<span class="line" id="L1461">            .watchos,</span>
<span class="line" id="L1462">            .macos,</span>
<span class="line" id="L1463">            .uefi,</span>
<span class="line" id="L1464">            .windows,</span>
<span class="line" id="L1465">            .emscripten,</span>
<span class="line" id="L1466">            .opencl,</span>
<span class="line" id="L1467">            .glsl450,</span>
<span class="line" id="L1468">            .vulkan,</span>
<span class="line" id="L1469">            .plan9,</span>
<span class="line" id="L1470">            .other,</span>
<span class="line" id="L1471">            =&gt; <span class="tok-kw">return</span> <span class="tok-null">false</span>,</span>
<span class="line" id="L1472">            <span class="tok-kw">else</span> =&gt; <span class="tok-kw">return</span> <span class="tok-null">true</span>,</span>
<span class="line" id="L1473">        }</span>
<span class="line" id="L1474">    }</span>
<span class="line" id="L1475"></span>
<span class="line" id="L1476">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> DynamicLinker = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L1477">        <span class="tok-comment">/// Contains the memory used to store the dynamic linker path. This field should</span></span>
<span class="line" id="L1478">        <span class="tok-comment">/// not be used directly. See `get` and `set`. This field exists so that this API requires no allocator.</span></span>
<span class="line" id="L1479">        buffer: [<span class="tok-number">255</span>]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>,</span>
<span class="line" id="L1480"></span>
<span class="line" id="L1481">        <span class="tok-comment">/// Used to construct the dynamic linker path. This field should not be used</span></span>
<span class="line" id="L1482">        <span class="tok-comment">/// directly. See `get` and `set`.</span></span>
<span class="line" id="L1483">        max_byte: ?<span class="tok-type">u8</span> = <span class="tok-null">null</span>,</span>
<span class="line" id="L1484"></span>
<span class="line" id="L1485">        <span class="tok-comment">/// Asserts that the length is less than or equal to 255 bytes.</span></span>
<span class="line" id="L1486">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">init</span>(dl_or_null: ?[]<span class="tok-kw">const</span> <span class="tok-type">u8</span>) DynamicLinker {</span>
<span class="line" id="L1487">            <span class="tok-kw">var</span> result: DynamicLinker = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L1488">            result.set(dl_or_null);</span>
<span class="line" id="L1489">            <span class="tok-kw">return</span> result;</span>
<span class="line" id="L1490">        }</span>
<span class="line" id="L1491"></span>
<span class="line" id="L1492">        <span class="tok-comment">/// The returned memory has the same lifetime as the `DynamicLinker`.</span></span>
<span class="line" id="L1493">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">get</span>(self: *<span class="tok-kw">const</span> DynamicLinker) ?[]<span class="tok-kw">const</span> <span class="tok-type">u8</span> {</span>
<span class="line" id="L1494">            <span class="tok-kw">const</span> m: <span class="tok-type">usize</span> = self.max_byte <span class="tok-kw">orelse</span> <span class="tok-kw">return</span> <span class="tok-null">null</span>;</span>
<span class="line" id="L1495">            <span class="tok-kw">return</span> self.buffer[<span class="tok-number">0</span> .. m + <span class="tok-number">1</span>];</span>
<span class="line" id="L1496">        }</span>
<span class="line" id="L1497"></span>
<span class="line" id="L1498">        <span class="tok-comment">/// Asserts that the length is less than or equal to 255 bytes.</span></span>
<span class="line" id="L1499">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">set</span>(self: *DynamicLinker, dl_or_null: ?[]<span class="tok-kw">const</span> <span class="tok-type">u8</span>) <span class="tok-type">void</span> {</span>
<span class="line" id="L1500">            <span class="tok-kw">if</span> (dl_or_null) |dl| {</span>
<span class="line" id="L1501">                mem.copy(<span class="tok-type">u8</span>, &amp;self.buffer, dl);</span>
<span class="line" id="L1502">                self.max_byte = <span class="tok-builtin">@intCast</span>(<span class="tok-type">u8</span>, dl.len - <span class="tok-number">1</span>);</span>
<span class="line" id="L1503">            } <span class="tok-kw">else</span> {</span>
<span class="line" id="L1504">                self.max_byte = <span class="tok-null">null</span>;</span>
<span class="line" id="L1505">            }</span>
<span class="line" id="L1506">        }</span>
<span class="line" id="L1507">    };</span>
<span class="line" id="L1508"></span>
<span class="line" id="L1509">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">standardDynamicLinkerPath</span>(self: Target) DynamicLinker {</span>
<span class="line" id="L1510">        <span class="tok-kw">var</span> result: DynamicLinker = .{};</span>
<span class="line" id="L1511">        <span class="tok-kw">const</span> S = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L1512">            <span class="tok-kw">fn</span> <span class="tok-fn">print</span>(r: *DynamicLinker, <span class="tok-kw">comptime</span> fmt: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>, args: <span class="tok-kw">anytype</span>) DynamicLinker {</span>
<span class="line" id="L1513">                r.max_byte = <span class="tok-builtin">@intCast</span>(<span class="tok-type">u8</span>, (std.fmt.bufPrint(&amp;r.buffer, fmt, args) <span class="tok-kw">catch</span> <span class="tok-kw">unreachable</span>).len - <span class="tok-number">1</span>);</span>
<span class="line" id="L1514">                <span class="tok-kw">return</span> r.*;</span>
<span class="line" id="L1515">            }</span>
<span class="line" id="L1516">            <span class="tok-kw">fn</span> <span class="tok-fn">copy</span>(r: *DynamicLinker, s: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) DynamicLinker {</span>
<span class="line" id="L1517">                mem.copy(<span class="tok-type">u8</span>, &amp;r.buffer, s);</span>
<span class="line" id="L1518">                r.max_byte = <span class="tok-builtin">@intCast</span>(<span class="tok-type">u8</span>, s.len - <span class="tok-number">1</span>);</span>
<span class="line" id="L1519">                <span class="tok-kw">return</span> r.*;</span>
<span class="line" id="L1520">            }</span>
<span class="line" id="L1521">        };</span>
<span class="line" id="L1522">        <span class="tok-kw">const</span> print = S.print;</span>
<span class="line" id="L1523">        <span class="tok-kw">const</span> copy = S.copy;</span>
<span class="line" id="L1524"></span>
<span class="line" id="L1525">        <span class="tok-kw">if</span> (self.abi == .android) {</span>
<span class="line" id="L1526">            <span class="tok-kw">const</span> suffix = <span class="tok-kw">if</span> (self.cpu.arch.ptrBitWidth() == <span class="tok-number">64</span>) <span class="tok-str">&quot;64&quot;</span> <span class="tok-kw">else</span> <span class="tok-str">&quot;&quot;</span>;</span>
<span class="line" id="L1527">            <span class="tok-kw">return</span> print(&amp;result, <span class="tok-str">&quot;/system/bin/linker{s}&quot;</span>, .{suffix});</span>
<span class="line" id="L1528">        }</span>
<span class="line" id="L1529"></span>
<span class="line" id="L1530">        <span class="tok-kw">if</span> (self.abi.isMusl()) {</span>
<span class="line" id="L1531">            <span class="tok-kw">const</span> is_arm = <span class="tok-kw">switch</span> (self.cpu.arch) {</span>
<span class="line" id="L1532">                .arm, .armeb, .thumb, .thumbeb =&gt; <span class="tok-null">true</span>,</span>
<span class="line" id="L1533">                <span class="tok-kw">else</span> =&gt; <span class="tok-null">false</span>,</span>
<span class="line" id="L1534">            };</span>
<span class="line" id="L1535">            <span class="tok-kw">const</span> arch_part = <span class="tok-kw">switch</span> (self.cpu.arch) {</span>
<span class="line" id="L1536">                .arm, .thumb =&gt; <span class="tok-str">&quot;arm&quot;</span>,</span>
<span class="line" id="L1537">                .armeb, .thumbeb =&gt; <span class="tok-str">&quot;armeb&quot;</span>,</span>
<span class="line" id="L1538">                <span class="tok-kw">else</span> =&gt; |arch| <span class="tok-builtin">@tagName</span>(arch),</span>
<span class="line" id="L1539">            };</span>
<span class="line" id="L1540">            <span class="tok-kw">const</span> arch_suffix = <span class="tok-kw">if</span> (is_arm <span class="tok-kw">and</span> self.abi.floatAbi() == .hard) <span class="tok-str">&quot;hf&quot;</span> <span class="tok-kw">else</span> <span class="tok-str">&quot;&quot;</span>;</span>
<span class="line" id="L1541">            <span class="tok-kw">return</span> print(&amp;result, <span class="tok-str">&quot;/lib/ld-musl-{s}{s}.so.1&quot;</span>, .{ arch_part, arch_suffix });</span>
<span class="line" id="L1542">        }</span>
<span class="line" id="L1543"></span>
<span class="line" id="L1544">        <span class="tok-kw">switch</span> (self.os.tag) {</span>
<span class="line" id="L1545">            .freebsd =&gt; <span class="tok-kw">return</span> copy(&amp;result, <span class="tok-str">&quot;/libexec/ld-elf.so.1&quot;</span>),</span>
<span class="line" id="L1546">            .netbsd =&gt; <span class="tok-kw">return</span> copy(&amp;result, <span class="tok-str">&quot;/libexec/ld.elf_so&quot;</span>),</span>
<span class="line" id="L1547">            .openbsd =&gt; <span class="tok-kw">return</span> copy(&amp;result, <span class="tok-str">&quot;/usr/libexec/ld.so&quot;</span>),</span>
<span class="line" id="L1548">            .dragonfly =&gt; <span class="tok-kw">return</span> copy(&amp;result, <span class="tok-str">&quot;/libexec/ld-elf.so.2&quot;</span>),</span>
<span class="line" id="L1549">            .solaris =&gt; <span class="tok-kw">return</span> copy(&amp;result, <span class="tok-str">&quot;/lib/64/ld.so.1&quot;</span>),</span>
<span class="line" id="L1550">            .linux =&gt; <span class="tok-kw">switch</span> (self.cpu.arch) {</span>
<span class="line" id="L1551">                .<span class="tok-type">i386</span>,</span>
<span class="line" id="L1552">                .sparc,</span>
<span class="line" id="L1553">                .sparcel,</span>
<span class="line" id="L1554">                =&gt; <span class="tok-kw">return</span> copy(&amp;result, <span class="tok-str">&quot;/lib/ld-linux.so.2&quot;</span>),</span>
<span class="line" id="L1555"></span>
<span class="line" id="L1556">                .aarch64 =&gt; <span class="tok-kw">return</span> copy(&amp;result, <span class="tok-str">&quot;/lib/ld-linux-aarch64.so.1&quot;</span>),</span>
<span class="line" id="L1557">                .aarch64_be =&gt; <span class="tok-kw">return</span> copy(&amp;result, <span class="tok-str">&quot;/lib/ld-linux-aarch64_be.so.1&quot;</span>),</span>
<span class="line" id="L1558">                .aarch64_32 =&gt; <span class="tok-kw">return</span> copy(&amp;result, <span class="tok-str">&quot;/lib/ld-linux-aarch64_32.so.1&quot;</span>),</span>
<span class="line" id="L1559"></span>
<span class="line" id="L1560">                .arm,</span>
<span class="line" id="L1561">                .armeb,</span>
<span class="line" id="L1562">                .thumb,</span>
<span class="line" id="L1563">                .thumbeb,</span>
<span class="line" id="L1564">                =&gt; <span class="tok-kw">return</span> copy(&amp;result, <span class="tok-kw">switch</span> (self.abi.floatAbi()) {</span>
<span class="line" id="L1565">                    .hard =&gt; <span class="tok-str">&quot;/lib/ld-linux-armhf.so.3&quot;</span>,</span>
<span class="line" id="L1566">                    <span class="tok-kw">else</span> =&gt; <span class="tok-str">&quot;/lib/ld-linux.so.3&quot;</span>,</span>
<span class="line" id="L1567">                }),</span>
<span class="line" id="L1568"></span>
<span class="line" id="L1569">                .mips,</span>
<span class="line" id="L1570">                .mipsel,</span>
<span class="line" id="L1571">                .mips64,</span>
<span class="line" id="L1572">                .mips64el,</span>
<span class="line" id="L1573">                =&gt; {</span>
<span class="line" id="L1574">                    <span class="tok-kw">const</span> lib_suffix = <span class="tok-kw">switch</span> (self.abi) {</span>
<span class="line" id="L1575">                        .gnuabin32, .gnux32 =&gt; <span class="tok-str">&quot;32&quot;</span>,</span>
<span class="line" id="L1576">                        .gnuabi64 =&gt; <span class="tok-str">&quot;64&quot;</span>,</span>
<span class="line" id="L1577">                        <span class="tok-kw">else</span> =&gt; <span class="tok-str">&quot;&quot;</span>,</span>
<span class="line" id="L1578">                    };</span>
<span class="line" id="L1579">                    <span class="tok-kw">const</span> is_nan_2008 = mips.featureSetHas(self.cpu.features, .nan2008);</span>
<span class="line" id="L1580">                    <span class="tok-kw">const</span> loader = <span class="tok-kw">if</span> (is_nan_2008) <span class="tok-str">&quot;ld-linux-mipsn8.so.1&quot;</span> <span class="tok-kw">else</span> <span class="tok-str">&quot;ld.so.1&quot;</span>;</span>
<span class="line" id="L1581">                    <span class="tok-kw">return</span> print(&amp;result, <span class="tok-str">&quot;/lib{s}/{s}&quot;</span>, .{ lib_suffix, loader });</span>
<span class="line" id="L1582">                },</span>
<span class="line" id="L1583"></span>
<span class="line" id="L1584">                .powerpc, .powerpcle =&gt; <span class="tok-kw">return</span> copy(&amp;result, <span class="tok-str">&quot;/lib/ld.so.1&quot;</span>),</span>
<span class="line" id="L1585">                .powerpc64, .powerpc64le =&gt; <span class="tok-kw">return</span> copy(&amp;result, <span class="tok-str">&quot;/lib64/ld64.so.2&quot;</span>),</span>
<span class="line" id="L1586">                .s390x =&gt; <span class="tok-kw">return</span> copy(&amp;result, <span class="tok-str">&quot;/lib64/ld64.so.1&quot;</span>),</span>
<span class="line" id="L1587">                .sparc64 =&gt; <span class="tok-kw">return</span> copy(&amp;result, <span class="tok-str">&quot;/lib64/ld-linux.so.2&quot;</span>),</span>
<span class="line" id="L1588">                .x86_64 =&gt; <span class="tok-kw">return</span> copy(&amp;result, <span class="tok-kw">switch</span> (self.abi) {</span>
<span class="line" id="L1589">                    .gnux32 =&gt; <span class="tok-str">&quot;/libx32/ld-linux-x32.so.2&quot;</span>,</span>
<span class="line" id="L1590">                    <span class="tok-kw">else</span> =&gt; <span class="tok-str">&quot;/lib64/ld-linux-x86-64.so.2&quot;</span>,</span>
<span class="line" id="L1591">                }),</span>
<span class="line" id="L1592"></span>
<span class="line" id="L1593">                .riscv32 =&gt; <span class="tok-kw">return</span> copy(&amp;result, <span class="tok-str">&quot;/lib/ld-linux-riscv32-ilp32.so.1&quot;</span>),</span>
<span class="line" id="L1594">                .riscv64 =&gt; <span class="tok-kw">return</span> copy(&amp;result, <span class="tok-str">&quot;/lib/ld-linux-riscv64-lp64.so.1&quot;</span>),</span>
<span class="line" id="L1595"></span>
<span class="line" id="L1596">                <span class="tok-comment">// Architectures in this list have been verified as not having a standard</span>
</span>
<span class="line" id="L1597">                <span class="tok-comment">// dynamic linker path.</span>
</span>
<span class="line" id="L1598">                .wasm32,</span>
<span class="line" id="L1599">                .wasm64,</span>
<span class="line" id="L1600">                .bpfel,</span>
<span class="line" id="L1601">                .bpfeb,</span>
<span class="line" id="L1602">                .nvptx,</span>
<span class="line" id="L1603">                .nvptx64,</span>
<span class="line" id="L1604">                .spu_2,</span>
<span class="line" id="L1605">                .avr,</span>
<span class="line" id="L1606">                .spirv32,</span>
<span class="line" id="L1607">                .spirv64,</span>
<span class="line" id="L1608">                =&gt; <span class="tok-kw">return</span> result,</span>
<span class="line" id="L1609"></span>
<span class="line" id="L1610">                <span class="tok-comment">// TODO go over each item in this list and either move it to the above list, or</span>
</span>
<span class="line" id="L1611">                <span class="tok-comment">// implement the standard dynamic linker path code for it.</span>
</span>
<span class="line" id="L1612">                .arc,</span>
<span class="line" id="L1613">                .csky,</span>
<span class="line" id="L1614">                .hexagon,</span>
<span class="line" id="L1615">                .m68k,</span>
<span class="line" id="L1616">                .msp430,</span>
<span class="line" id="L1617">                .r600,</span>
<span class="line" id="L1618">                .amdgcn,</span>
<span class="line" id="L1619">                .tce,</span>
<span class="line" id="L1620">                .tcele,</span>
<span class="line" id="L1621">                .xcore,</span>
<span class="line" id="L1622">                .le32,</span>
<span class="line" id="L1623">                .le64,</span>
<span class="line" id="L1624">                .amdil,</span>
<span class="line" id="L1625">                .amdil64,</span>
<span class="line" id="L1626">                .hsail,</span>
<span class="line" id="L1627">                .hsail64,</span>
<span class="line" id="L1628">                .spir,</span>
<span class="line" id="L1629">                .spir64,</span>
<span class="line" id="L1630">                .kalimba,</span>
<span class="line" id="L1631">                .shave,</span>
<span class="line" id="L1632">                .lanai,</span>
<span class="line" id="L1633">                .renderscript32,</span>
<span class="line" id="L1634">                .renderscript64,</span>
<span class="line" id="L1635">                .ve,</span>
<span class="line" id="L1636">                =&gt; <span class="tok-kw">return</span> result,</span>
<span class="line" id="L1637">            },</span>
<span class="line" id="L1638"></span>
<span class="line" id="L1639">            .ios,</span>
<span class="line" id="L1640">            .tvos,</span>
<span class="line" id="L1641">            .watchos,</span>
<span class="line" id="L1642">            .macos,</span>
<span class="line" id="L1643">            =&gt; <span class="tok-kw">return</span> copy(&amp;result, <span class="tok-str">&quot;/usr/lib/dyld&quot;</span>),</span>
<span class="line" id="L1644"></span>
<span class="line" id="L1645">            <span class="tok-comment">// Operating systems in this list have been verified as not having a standard</span>
</span>
<span class="line" id="L1646">            <span class="tok-comment">// dynamic linker path.</span>
</span>
<span class="line" id="L1647">            .freestanding,</span>
<span class="line" id="L1648">            .uefi,</span>
<span class="line" id="L1649">            .windows,</span>
<span class="line" id="L1650">            .emscripten,</span>
<span class="line" id="L1651">            .wasi,</span>
<span class="line" id="L1652">            .opencl,</span>
<span class="line" id="L1653">            .glsl450,</span>
<span class="line" id="L1654">            .vulkan,</span>
<span class="line" id="L1655">            .other,</span>
<span class="line" id="L1656">            .plan9,</span>
<span class="line" id="L1657">            =&gt; <span class="tok-kw">return</span> result,</span>
<span class="line" id="L1658"></span>
<span class="line" id="L1659">            <span class="tok-comment">// TODO revisit when multi-arch for Haiku is available</span>
</span>
<span class="line" id="L1660">            .haiku =&gt; <span class="tok-kw">return</span> copy(&amp;result, <span class="tok-str">&quot;/system/runtime_loader&quot;</span>),</span>
<span class="line" id="L1661"></span>
<span class="line" id="L1662">            <span class="tok-comment">// TODO go over each item in this list and either move it to the above list, or</span>
</span>
<span class="line" id="L1663">            <span class="tok-comment">// implement the standard dynamic linker path code for it.</span>
</span>
<span class="line" id="L1664">            .ananas,</span>
<span class="line" id="L1665">            .cloudabi,</span>
<span class="line" id="L1666">            .fuchsia,</span>
<span class="line" id="L1667">            .kfreebsd,</span>
<span class="line" id="L1668">            .lv2,</span>
<span class="line" id="L1669">            .zos,</span>
<span class="line" id="L1670">            .minix,</span>
<span class="line" id="L1671">            .rtems,</span>
<span class="line" id="L1672">            .nacl,</span>
<span class="line" id="L1673">            .aix,</span>
<span class="line" id="L1674">            .cuda,</span>
<span class="line" id="L1675">            .nvcl,</span>
<span class="line" id="L1676">            .amdhsa,</span>
<span class="line" id="L1677">            .ps4,</span>
<span class="line" id="L1678">            .elfiamcu,</span>
<span class="line" id="L1679">            .mesa3d,</span>
<span class="line" id="L1680">            .contiki,</span>
<span class="line" id="L1681">            .amdpal,</span>
<span class="line" id="L1682">            .hermit,</span>
<span class="line" id="L1683">            .hurd,</span>
<span class="line" id="L1684">            =&gt; <span class="tok-kw">return</span> result,</span>
<span class="line" id="L1685">        }</span>
<span class="line" id="L1686">    }</span>
<span class="line" id="L1687"></span>
<span class="line" id="L1688">    <span class="tok-comment">/// 0c spim    little-endian MIPS 3000 family</span></span>
<span class="line" id="L1689">    <span class="tok-comment">/// 1c 68000   Motorola MC68000</span></span>
<span class="line" id="L1690">    <span class="tok-comment">/// 2c 68020   Motorola MC68020</span></span>
<span class="line" id="L1691">    <span class="tok-comment">/// 5c arm     little-endian ARM</span></span>
<span class="line" id="L1692">    <span class="tok-comment">/// 6c amd64   AMD64 and compatibles (e.g., Intel EM64T)</span></span>
<span class="line" id="L1693">    <span class="tok-comment">/// 7c arm64   ARM64 (ARMv8)</span></span>
<span class="line" id="L1694">    <span class="tok-comment">/// 8c 386     Intel i386, i486, Pentium, etc.</span></span>
<span class="line" id="L1695">    <span class="tok-comment">/// kc sparc   Sun SPARC</span></span>
<span class="line" id="L1696">    <span class="tok-comment">/// qc power   Power PC</span></span>
<span class="line" id="L1697">    <span class="tok-comment">/// vc mips    big-endian MIPS 3000 family</span></span>
<span class="line" id="L1698">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">plan9Ext</span>(cpu_arch: Cpu.Arch) [:<span class="tok-number">0</span>]<span class="tok-kw">const</span> <span class="tok-type">u8</span> {</span>
<span class="line" id="L1699">        <span class="tok-kw">return</span> <span class="tok-kw">switch</span> (cpu_arch) {</span>
<span class="line" id="L1700">            .arm =&gt; <span class="tok-str">&quot;.5&quot;</span>,</span>
<span class="line" id="L1701">            .x86_64 =&gt; <span class="tok-str">&quot;.6&quot;</span>,</span>
<span class="line" id="L1702">            .aarch64 =&gt; <span class="tok-str">&quot;.7&quot;</span>,</span>
<span class="line" id="L1703">            .<span class="tok-type">i386</span> =&gt; <span class="tok-str">&quot;.8&quot;</span>,</span>
<span class="line" id="L1704">            .sparc =&gt; <span class="tok-str">&quot;.k&quot;</span>,</span>
<span class="line" id="L1705">            .powerpc, .powerpcle =&gt; <span class="tok-str">&quot;.q&quot;</span>,</span>
<span class="line" id="L1706">            .mips, .mipsel =&gt; <span class="tok-str">&quot;.v&quot;</span>,</span>
<span class="line" id="L1707">            <span class="tok-comment">// ISAs without designated characters get 'X' for lack of a better option.</span>
</span>
<span class="line" id="L1708">            <span class="tok-kw">else</span> =&gt; <span class="tok-str">&quot;.X&quot;</span>,</span>
<span class="line" id="L1709">        };</span>
<span class="line" id="L1710">    }</span>
<span class="line" id="L1711"></span>
<span class="line" id="L1712">    <span class="tok-kw">pub</span> <span class="tok-kw">inline</span> <span class="tok-kw">fn</span> <span class="tok-fn">longDoubleIs</span>(target: Target, <span class="tok-kw">comptime</span> F: <span class="tok-type">type</span>) <span class="tok-type">bool</span> {</span>
<span class="line" id="L1713">        <span class="tok-kw">if</span> (target.abi == .msvc) {</span>
<span class="line" id="L1714">            <span class="tok-kw">return</span> F == <span class="tok-type">f64</span>;</span>
<span class="line" id="L1715">        }</span>
<span class="line" id="L1716">        <span class="tok-kw">return</span> <span class="tok-kw">switch</span> (F) {</span>
<span class="line" id="L1717">            <span class="tok-type">f128</span> =&gt; <span class="tok-kw">switch</span> (target.cpu.arch) {</span>
<span class="line" id="L1718">                .aarch64 =&gt; {</span>
<span class="line" id="L1719">                    <span class="tok-comment">// According to Apple's official guide:</span>
</span>
<span class="line" id="L1720">                    <span class="tok-comment">// &gt; The long double type is a double precision IEEE754 binary floating-point type,</span>
</span>
<span class="line" id="L1721">                    <span class="tok-comment">// &gt; which makes it identical to the double type. This behavior contrasts to the</span>
</span>
<span class="line" id="L1722">                    <span class="tok-comment">// &gt; standard specification, in which a long double is a quad-precision, IEEE754</span>
</span>
<span class="line" id="L1723">                    <span class="tok-comment">// &gt; binary, floating-point type.</span>
</span>
<span class="line" id="L1724">                    <span class="tok-comment">// https://developer.apple.com/documentation/xcode/writing-arm64-code-for-apple-platforms</span>
</span>
<span class="line" id="L1725">                    <span class="tok-kw">return</span> !target.isDarwin();</span>
<span class="line" id="L1726">                },</span>
<span class="line" id="L1727"></span>
<span class="line" id="L1728">                .riscv64,</span>
<span class="line" id="L1729">                .aarch64_be,</span>
<span class="line" id="L1730">                .aarch64_32,</span>
<span class="line" id="L1731">                .s390x,</span>
<span class="line" id="L1732">                .mips64,</span>
<span class="line" id="L1733">                .mips64el,</span>
<span class="line" id="L1734">                .sparc,</span>
<span class="line" id="L1735">                .sparc64,</span>
<span class="line" id="L1736">                .sparcel,</span>
<span class="line" id="L1737">                .powerpc,</span>
<span class="line" id="L1738">                .powerpcle,</span>
<span class="line" id="L1739">                .powerpc64,</span>
<span class="line" id="L1740">                .powerpc64le,</span>
<span class="line" id="L1741">                =&gt; <span class="tok-null">true</span>,</span>
<span class="line" id="L1742"></span>
<span class="line" id="L1743">                <span class="tok-kw">else</span> =&gt; <span class="tok-null">false</span>,</span>
<span class="line" id="L1744">            },</span>
<span class="line" id="L1745">            f80 =&gt; <span class="tok-kw">switch</span> (target.cpu.arch) {</span>
<span class="line" id="L1746">                .x86_64, .<span class="tok-type">i386</span> =&gt; <span class="tok-null">true</span>,</span>
<span class="line" id="L1747">                <span class="tok-kw">else</span> =&gt; <span class="tok-null">false</span>,</span>
<span class="line" id="L1748">            },</span>
<span class="line" id="L1749">            <span class="tok-type">f64</span> =&gt; <span class="tok-kw">switch</span> (target.cpu.arch) {</span>
<span class="line" id="L1750">                .aarch64 =&gt; target.isDarwin(),</span>
<span class="line" id="L1751"></span>
<span class="line" id="L1752">                .x86_64,</span>
<span class="line" id="L1753">                .<span class="tok-type">i386</span>,</span>
<span class="line" id="L1754">                .riscv64,</span>
<span class="line" id="L1755">                .aarch64_be,</span>
<span class="line" id="L1756">                .aarch64_32,</span>
<span class="line" id="L1757">                .s390x,</span>
<span class="line" id="L1758">                .mips64,</span>
<span class="line" id="L1759">                .mips64el,</span>
<span class="line" id="L1760">                .sparc,</span>
<span class="line" id="L1761">                .sparc64,</span>
<span class="line" id="L1762">                .sparcel,</span>
<span class="line" id="L1763">                .powerpc,</span>
<span class="line" id="L1764">                .powerpcle,</span>
<span class="line" id="L1765">                .powerpc64,</span>
<span class="line" id="L1766">                .powerpc64le,</span>
<span class="line" id="L1767">                =&gt; <span class="tok-null">false</span>,</span>
<span class="line" id="L1768"></span>
<span class="line" id="L1769">                <span class="tok-kw">else</span> =&gt; <span class="tok-null">true</span>,</span>
<span class="line" id="L1770">            },</span>
<span class="line" id="L1771">            <span class="tok-kw">else</span> =&gt; <span class="tok-null">false</span>,</span>
<span class="line" id="L1772">        };</span>
<span class="line" id="L1773">    }</span>
<span class="line" id="L1774"></span>
<span class="line" id="L1775">    <span class="tok-kw">pub</span> <span class="tok-kw">inline</span> <span class="tok-kw">fn</span> <span class="tok-fn">maxIntAlignment</span>(target: Target) <span class="tok-type">u16</span> {</span>
<span class="line" id="L1776">        <span class="tok-kw">return</span> <span class="tok-kw">switch</span> (target.cpu.arch) {</span>
<span class="line" id="L1777">            .avr =&gt; <span class="tok-number">1</span>,</span>
<span class="line" id="L1778">            .msp430 =&gt; <span class="tok-number">2</span>,</span>
<span class="line" id="L1779">            .xcore =&gt; <span class="tok-number">4</span>,</span>
<span class="line" id="L1780"></span>
<span class="line" id="L1781">            .arm,</span>
<span class="line" id="L1782">            .armeb,</span>
<span class="line" id="L1783">            .thumb,</span>
<span class="line" id="L1784">            .thumbeb,</span>
<span class="line" id="L1785">            .hexagon,</span>
<span class="line" id="L1786">            .mips,</span>
<span class="line" id="L1787">            .mipsel,</span>
<span class="line" id="L1788">            .powerpc,</span>
<span class="line" id="L1789">            .powerpcle,</span>
<span class="line" id="L1790">            .r600,</span>
<span class="line" id="L1791">            .amdgcn,</span>
<span class="line" id="L1792">            .riscv32,</span>
<span class="line" id="L1793">            .sparc,</span>
<span class="line" id="L1794">            .sparcel,</span>
<span class="line" id="L1795">            .s390x,</span>
<span class="line" id="L1796">            .lanai,</span>
<span class="line" id="L1797">            .wasm32,</span>
<span class="line" id="L1798">            .wasm64,</span>
<span class="line" id="L1799">            =&gt; <span class="tok-number">8</span>,</span>
<span class="line" id="L1800"></span>
<span class="line" id="L1801">            .<span class="tok-type">i386</span> =&gt; <span class="tok-kw">return</span> <span class="tok-kw">switch</span> (target.os.tag) {</span>
<span class="line" id="L1802">                .windows =&gt; <span class="tok-number">8</span>,</span>
<span class="line" id="L1803">                <span class="tok-kw">else</span> =&gt; <span class="tok-number">4</span>,</span>
<span class="line" id="L1804">            },</span>
<span class="line" id="L1805"></span>
<span class="line" id="L1806">            <span class="tok-comment">// For these, LLVMABIAlignmentOfType(i128) reports 8. Note that 16</span>
</span>
<span class="line" id="L1807">            <span class="tok-comment">// is a relevant number in three cases:</span>
</span>
<span class="line" id="L1808">            <span class="tok-comment">// 1. Different machine code instruction when loading into SIMD register.</span>
</span>
<span class="line" id="L1809">            <span class="tok-comment">// 2. The C ABI wants 16 for extern structs.</span>
</span>
<span class="line" id="L1810">            <span class="tok-comment">// 3. 16-byte cmpxchg needs 16-byte alignment.</span>
</span>
<span class="line" id="L1811">            <span class="tok-comment">// Same logic for powerpc64, mips64, sparc64.</span>
</span>
<span class="line" id="L1812">            .x86_64,</span>
<span class="line" id="L1813">            .powerpc64,</span>
<span class="line" id="L1814">            .powerpc64le,</span>
<span class="line" id="L1815">            .mips64,</span>
<span class="line" id="L1816">            .mips64el,</span>
<span class="line" id="L1817">            .sparc64,</span>
<span class="line" id="L1818">            =&gt; <span class="tok-kw">return</span> <span class="tok-kw">switch</span> (target.ofmt) {</span>
<span class="line" id="L1819">                .c =&gt; <span class="tok-number">16</span>,</span>
<span class="line" id="L1820">                <span class="tok-kw">else</span> =&gt; <span class="tok-number">8</span>,</span>
<span class="line" id="L1821">            },</span>
<span class="line" id="L1822"></span>
<span class="line" id="L1823">            <span class="tok-comment">// Even LLVMABIAlignmentOfType(i128) agrees on these targets.</span>
</span>
<span class="line" id="L1824">            .aarch64,</span>
<span class="line" id="L1825">            .aarch64_be,</span>
<span class="line" id="L1826">            .aarch64_32,</span>
<span class="line" id="L1827">            .riscv64,</span>
<span class="line" id="L1828">            .bpfel,</span>
<span class="line" id="L1829">            .bpfeb,</span>
<span class="line" id="L1830">            .nvptx,</span>
<span class="line" id="L1831">            .nvptx64,</span>
<span class="line" id="L1832">            =&gt; <span class="tok-number">16</span>,</span>
<span class="line" id="L1833"></span>
<span class="line" id="L1834">            <span class="tok-comment">// Below this comment are unverified but based on the fact that C requires</span>
</span>
<span class="line" id="L1835">            <span class="tok-comment">// int128_t to be 16 bytes aligned, it's a safe default.</span>
</span>
<span class="line" id="L1836">            .spu_2,</span>
<span class="line" id="L1837">            .csky,</span>
<span class="line" id="L1838">            .arc,</span>
<span class="line" id="L1839">            .m68k,</span>
<span class="line" id="L1840">            .tce,</span>
<span class="line" id="L1841">            .tcele,</span>
<span class="line" id="L1842">            .le32,</span>
<span class="line" id="L1843">            .amdil,</span>
<span class="line" id="L1844">            .hsail,</span>
<span class="line" id="L1845">            .spir,</span>
<span class="line" id="L1846">            .kalimba,</span>
<span class="line" id="L1847">            .renderscript32,</span>
<span class="line" id="L1848">            .spirv32,</span>
<span class="line" id="L1849">            .shave,</span>
<span class="line" id="L1850">            .le64,</span>
<span class="line" id="L1851">            .amdil64,</span>
<span class="line" id="L1852">            .hsail64,</span>
<span class="line" id="L1853">            .spir64,</span>
<span class="line" id="L1854">            .renderscript64,</span>
<span class="line" id="L1855">            .ve,</span>
<span class="line" id="L1856">            .spirv64,</span>
<span class="line" id="L1857">            =&gt; <span class="tok-number">16</span>,</span>
<span class="line" id="L1858">        };</span>
<span class="line" id="L1859">    }</span>
<span class="line" id="L1860">};</span>
<span class="line" id="L1861"></span>
<span class="line" id="L1862"><span class="tok-kw">test</span> {</span>
<span class="line" id="L1863">    std.testing.refAllDecls(Target.Cpu.Arch);</span>
<span class="line" id="L1864">}</span>
<span class="line" id="L1865"></span>
</code></pre></body>
</html>