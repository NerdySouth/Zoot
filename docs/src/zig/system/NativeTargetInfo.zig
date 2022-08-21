<!doctype html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">    <title>zig/system/NativeTargetInfo.zig - source view</title>
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
<span class="line" id="L3"><span class="tok-kw">const</span> mem = std.mem;</span>
<span class="line" id="L4"><span class="tok-kw">const</span> assert = std.debug.assert;</span>
<span class="line" id="L5"><span class="tok-kw">const</span> fs = std.fs;</span>
<span class="line" id="L6"><span class="tok-kw">const</span> elf = std.elf;</span>
<span class="line" id="L7"><span class="tok-kw">const</span> native_endian = builtin.cpu.arch.endian();</span>
<span class="line" id="L8"></span>
<span class="line" id="L9"><span class="tok-kw">const</span> NativeTargetInfo = <span class="tok-builtin">@This</span>();</span>
<span class="line" id="L10"><span class="tok-kw">const</span> Target = std.Target;</span>
<span class="line" id="L11"><span class="tok-kw">const</span> Allocator = std.mem.Allocator;</span>
<span class="line" id="L12"><span class="tok-kw">const</span> CrossTarget = std.zig.CrossTarget;</span>
<span class="line" id="L13"><span class="tok-kw">const</span> windows = std.zig.system.windows;</span>
<span class="line" id="L14"><span class="tok-kw">const</span> darwin = std.zig.system.darwin;</span>
<span class="line" id="L15"><span class="tok-kw">const</span> linux = std.zig.system.linux;</span>
<span class="line" id="L16"></span>
<span class="line" id="L17">target: Target,</span>
<span class="line" id="L18">dynamic_linker: DynamicLinker = DynamicLinker{},</span>
<span class="line" id="L19"></span>
<span class="line" id="L20"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> DynamicLinker = Target.DynamicLinker;</span>
<span class="line" id="L21"></span>
<span class="line" id="L22"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> DetectError = <span class="tok-kw">error</span>{</span>
<span class="line" id="L23">    OutOfMemory,</span>
<span class="line" id="L24">    FileSystem,</span>
<span class="line" id="L25">    SystemResources,</span>
<span class="line" id="L26">    SymLinkLoop,</span>
<span class="line" id="L27">    ProcessFdQuotaExceeded,</span>
<span class="line" id="L28">    SystemFdQuotaExceeded,</span>
<span class="line" id="L29">    DeviceBusy,</span>
<span class="line" id="L30">    OSVersionDetectionFail,</span>
<span class="line" id="L31">};</span>
<span class="line" id="L32"></span>
<span class="line" id="L33"><span class="tok-comment">/// Given a `CrossTarget`, which specifies in detail which parts of the target should be detected</span></span>
<span class="line" id="L34"><span class="tok-comment">/// natively, which should be standard or default, and which are provided explicitly, this function</span></span>
<span class="line" id="L35"><span class="tok-comment">/// resolves the native components by detecting the native system, and then resolves standard/default parts</span></span>
<span class="line" id="L36"><span class="tok-comment">/// relative to that.</span></span>
<span class="line" id="L37"><span class="tok-comment">/// Any resources this function allocates are released before returning, and so there is no</span></span>
<span class="line" id="L38"><span class="tok-comment">/// deinitialization method.</span></span>
<span class="line" id="L39"><span class="tok-comment">/// TODO Remove the Allocator requirement from this function.</span></span>
<span class="line" id="L40"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">detect</span>(allocator: Allocator, cross_target: CrossTarget) DetectError!NativeTargetInfo {</span>
<span class="line" id="L41">    <span class="tok-kw">var</span> os = cross_target.getOsTag().defaultVersionRange(cross_target.getCpuArch());</span>
<span class="line" id="L42">    <span class="tok-kw">if</span> (cross_target.os_tag == <span class="tok-null">null</span>) {</span>
<span class="line" id="L43">        <span class="tok-kw">switch</span> (builtin.target.os.tag) {</span>
<span class="line" id="L44">            .linux =&gt; {</span>
<span class="line" id="L45">                <span class="tok-kw">const</span> uts = std.os.uname();</span>
<span class="line" id="L46">                <span class="tok-kw">const</span> release = mem.sliceTo(&amp;uts.release, <span class="tok-number">0</span>);</span>
<span class="line" id="L47">                <span class="tok-comment">// The release field sometimes has a weird format,</span>
</span>
<span class="line" id="L48">                <span class="tok-comment">// `Version.parse` will attempt to find some meaningful interpretation.</span>
</span>
<span class="line" id="L49">                <span class="tok-kw">if</span> (std.builtin.Version.parse(release)) |ver| {</span>
<span class="line" id="L50">                    os.version_range.linux.range.min = ver;</span>
<span class="line" id="L51">                    os.version_range.linux.range.max = ver;</span>
<span class="line" id="L52">                } <span class="tok-kw">else</span> |err| <span class="tok-kw">switch</span> (err) {</span>
<span class="line" id="L53">                    <span class="tok-kw">error</span>.Overflow =&gt; {},</span>
<span class="line" id="L54">                    <span class="tok-kw">error</span>.InvalidCharacter =&gt; {},</span>
<span class="line" id="L55">                    <span class="tok-kw">error</span>.InvalidVersion =&gt; {},</span>
<span class="line" id="L56">                }</span>
<span class="line" id="L57">            },</span>
<span class="line" id="L58">            .solaris =&gt; {</span>
<span class="line" id="L59">                <span class="tok-kw">const</span> uts = std.os.uname();</span>
<span class="line" id="L60">                <span class="tok-kw">const</span> release = mem.sliceTo(&amp;uts.release, <span class="tok-number">0</span>);</span>
<span class="line" id="L61">                <span class="tok-kw">if</span> (std.builtin.Version.parse(release)) |ver| {</span>
<span class="line" id="L62">                    os.version_range.semver.min = ver;</span>
<span class="line" id="L63">                    os.version_range.semver.max = ver;</span>
<span class="line" id="L64">                } <span class="tok-kw">else</span> |err| <span class="tok-kw">switch</span> (err) {</span>
<span class="line" id="L65">                    <span class="tok-kw">error</span>.Overflow =&gt; {},</span>
<span class="line" id="L66">                    <span class="tok-kw">error</span>.InvalidCharacter =&gt; {},</span>
<span class="line" id="L67">                    <span class="tok-kw">error</span>.InvalidVersion =&gt; {},</span>
<span class="line" id="L68">                }</span>
<span class="line" id="L69">            },</span>
<span class="line" id="L70">            .windows =&gt; {</span>
<span class="line" id="L71">                <span class="tok-kw">const</span> detected_version = windows.detectRuntimeVersion();</span>
<span class="line" id="L72">                os.version_range.windows.min = detected_version;</span>
<span class="line" id="L73">                os.version_range.windows.max = detected_version;</span>
<span class="line" id="L74">            },</span>
<span class="line" id="L75">            .macos =&gt; <span class="tok-kw">try</span> darwin.macos.detect(&amp;os),</span>
<span class="line" id="L76">            .freebsd, .netbsd, .dragonfly =&gt; {</span>
<span class="line" id="L77">                <span class="tok-kw">const</span> key = <span class="tok-kw">switch</span> (builtin.target.os.tag) {</span>
<span class="line" id="L78">                    .freebsd =&gt; <span class="tok-str">&quot;kern.osreldate&quot;</span>,</span>
<span class="line" id="L79">                    .netbsd, .dragonfly =&gt; <span class="tok-str">&quot;kern.osrevision&quot;</span>,</span>
<span class="line" id="L80">                    <span class="tok-kw">else</span> =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L81">                };</span>
<span class="line" id="L82">                <span class="tok-kw">var</span> value: <span class="tok-type">u32</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L83">                <span class="tok-kw">var</span> len: <span class="tok-type">usize</span> = <span class="tok-builtin">@sizeOf</span>(<span class="tok-builtin">@TypeOf</span>(value));</span>
<span class="line" id="L84"></span>
<span class="line" id="L85">                std.os.sysctlbynameZ(key, &amp;value, &amp;len, <span class="tok-null">null</span>, <span class="tok-number">0</span>) <span class="tok-kw">catch</span> |err| <span class="tok-kw">switch</span> (err) {</span>
<span class="line" id="L86">                    <span class="tok-kw">error</span>.NameTooLong =&gt; <span class="tok-kw">unreachable</span>, <span class="tok-comment">// constant, known good value</span>
</span>
<span class="line" id="L87">                    <span class="tok-kw">error</span>.PermissionDenied =&gt; <span class="tok-kw">unreachable</span>, <span class="tok-comment">// only when setting values,</span>
</span>
<span class="line" id="L88">                    <span class="tok-kw">error</span>.SystemResources =&gt; <span class="tok-kw">unreachable</span>, <span class="tok-comment">// memory already on the stack</span>
</span>
<span class="line" id="L89">                    <span class="tok-kw">error</span>.UnknownName =&gt; <span class="tok-kw">unreachable</span>, <span class="tok-comment">// constant, known good value</span>
</span>
<span class="line" id="L90">                    <span class="tok-kw">error</span>.Unexpected =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.OSVersionDetectionFail,</span>
<span class="line" id="L91">                };</span>
<span class="line" id="L92"></span>
<span class="line" id="L93">                <span class="tok-kw">switch</span> (builtin.target.os.tag) {</span>
<span class="line" id="L94">                    .freebsd =&gt; {</span>
<span class="line" id="L95">                        <span class="tok-comment">// https://www.freebsd.org/doc/en_US.ISO8859-1/books/porters-handbook/versions.html</span>
</span>
<span class="line" id="L96">                        <span class="tok-comment">// Major * 100,000 has been convention since FreeBSD 2.2 (1997)</span>
</span>
<span class="line" id="L97">                        <span class="tok-comment">// Minor * 1(0),000 summed has been convention since FreeBSD 2.2 (1997)</span>
</span>
<span class="line" id="L98">                        <span class="tok-comment">// e.g. 492101 = 4.11-STABLE = 4.(9+2)</span>
</span>
<span class="line" id="L99">                        <span class="tok-kw">const</span> major = value / <span class="tok-number">100_000</span>;</span>
<span class="line" id="L100">                        <span class="tok-kw">const</span> minor1 = value % <span class="tok-number">100_000</span> / <span class="tok-number">10_000</span>; <span class="tok-comment">// usually 0 since 5.1</span>
</span>
<span class="line" id="L101">                        <span class="tok-kw">const</span> minor2 = value % <span class="tok-number">10_000</span> / <span class="tok-number">1_000</span>; <span class="tok-comment">// 0 before 5.1, minor version since</span>
</span>
<span class="line" id="L102">                        <span class="tok-kw">const</span> patch = value % <span class="tok-number">1_000</span>;</span>
<span class="line" id="L103">                        os.version_range.semver.min = .{ .major = major, .minor = minor1 + minor2, .patch = patch };</span>
<span class="line" id="L104">                        os.version_range.semver.max = os.version_range.semver.min;</span>
<span class="line" id="L105">                    },</span>
<span class="line" id="L106">                    .netbsd =&gt; {</span>
<span class="line" id="L107">                        <span class="tok-comment">// #define __NetBSD_Version__ MMmmrrpp00</span>
</span>
<span class="line" id="L108">                        <span class="tok-comment">//</span>
</span>
<span class="line" id="L109">                        <span class="tok-comment">// M = major version</span>
</span>
<span class="line" id="L110">                        <span class="tok-comment">// m = minor version; a minor number of 99 indicates current.</span>
</span>
<span class="line" id="L111">                        <span class="tok-comment">// r = 0 (*)</span>
</span>
<span class="line" id="L112">                        <span class="tok-comment">// p = patchlevel</span>
</span>
<span class="line" id="L113">                        <span class="tok-kw">const</span> major = value / <span class="tok-number">100_000_000</span>;</span>
<span class="line" id="L114">                        <span class="tok-kw">const</span> minor = value % <span class="tok-number">100_000_000</span> / <span class="tok-number">1_000_000</span>;</span>
<span class="line" id="L115">                        <span class="tok-kw">const</span> patch = value % <span class="tok-number">10_000</span> / <span class="tok-number">100</span>;</span>
<span class="line" id="L116">                        os.version_range.semver.min = .{ .major = major, .minor = minor, .patch = patch };</span>
<span class="line" id="L117">                        os.version_range.semver.max = os.version_range.semver.min;</span>
<span class="line" id="L118">                    },</span>
<span class="line" id="L119">                    .dragonfly =&gt; {</span>
<span class="line" id="L120">                        <span class="tok-comment">// https://github.com/DragonFlyBSD/DragonFlyBSD/blob/cb2cde83771754aeef9bb3251ee48959138dec87/Makefile.inc1#L15-L17</span>
</span>
<span class="line" id="L121">                        <span class="tok-comment">// flat base10 format: Mmmmpp</span>
</span>
<span class="line" id="L122">                        <span class="tok-comment">//   M = major</span>
</span>
<span class="line" id="L123">                        <span class="tok-comment">//   m = minor; odd-numbers indicate current dev branch</span>
</span>
<span class="line" id="L124">                        <span class="tok-comment">//   p = patch</span>
</span>
<span class="line" id="L125">                        <span class="tok-kw">const</span> major = value / <span class="tok-number">100_000</span>;</span>
<span class="line" id="L126">                        <span class="tok-kw">const</span> minor = value % <span class="tok-number">100_000</span> / <span class="tok-number">100</span>;</span>
<span class="line" id="L127">                        <span class="tok-kw">const</span> patch = value % <span class="tok-number">100</span>;</span>
<span class="line" id="L128">                        os.version_range.semver.min = .{ .major = major, .minor = minor, .patch = patch };</span>
<span class="line" id="L129">                        os.version_range.semver.max = os.version_range.semver.min;</span>
<span class="line" id="L130">                    },</span>
<span class="line" id="L131">                    <span class="tok-kw">else</span> =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L132">                }</span>
<span class="line" id="L133">            },</span>
<span class="line" id="L134">            .openbsd =&gt; {</span>
<span class="line" id="L135">                <span class="tok-kw">const</span> mib: [<span class="tok-number">2</span>]<span class="tok-type">c_int</span> = [_]<span class="tok-type">c_int</span>{</span>
<span class="line" id="L136">                    std.os.CTL.KERN,</span>
<span class="line" id="L137">                    std.os.KERN.OSRELEASE,</span>
<span class="line" id="L138">                };</span>
<span class="line" id="L139">                <span class="tok-kw">var</span> buf: [<span class="tok-number">64</span>]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L140">                <span class="tok-kw">var</span> len: <span class="tok-type">usize</span> = buf.len;</span>
<span class="line" id="L141"></span>
<span class="line" id="L142">                std.os.sysctl(&amp;mib, &amp;buf, &amp;len, <span class="tok-null">null</span>, <span class="tok-number">0</span>) <span class="tok-kw">catch</span> |err| <span class="tok-kw">switch</span> (err) {</span>
<span class="line" id="L143">                    <span class="tok-kw">error</span>.NameTooLong =&gt; <span class="tok-kw">unreachable</span>, <span class="tok-comment">// constant, known good value</span>
</span>
<span class="line" id="L144">                    <span class="tok-kw">error</span>.PermissionDenied =&gt; <span class="tok-kw">unreachable</span>, <span class="tok-comment">// only when setting values,</span>
</span>
<span class="line" id="L145">                    <span class="tok-kw">error</span>.SystemResources =&gt; <span class="tok-kw">unreachable</span>, <span class="tok-comment">// memory already on the stack</span>
</span>
<span class="line" id="L146">                    <span class="tok-kw">error</span>.UnknownName =&gt; <span class="tok-kw">unreachable</span>, <span class="tok-comment">// constant, known good value</span>
</span>
<span class="line" id="L147">                    <span class="tok-kw">error</span>.Unexpected =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.OSVersionDetectionFail,</span>
<span class="line" id="L148">                };</span>
<span class="line" id="L149"></span>
<span class="line" id="L150">                <span class="tok-kw">if</span> (std.builtin.Version.parse(buf[<span class="tok-number">0</span> .. len - <span class="tok-number">1</span>])) |ver| {</span>
<span class="line" id="L151">                    os.version_range.semver.min = ver;</span>
<span class="line" id="L152">                    os.version_range.semver.max = ver;</span>
<span class="line" id="L153">                } <span class="tok-kw">else</span> |_| {</span>
<span class="line" id="L154">                    <span class="tok-kw">return</span> <span class="tok-kw">error</span>.OSVersionDetectionFail;</span>
<span class="line" id="L155">                }</span>
<span class="line" id="L156">            },</span>
<span class="line" id="L157">            <span class="tok-kw">else</span> =&gt; {</span>
<span class="line" id="L158">                <span class="tok-comment">// Unimplemented, fall back to default version range.</span>
</span>
<span class="line" id="L159">            },</span>
<span class="line" id="L160">        }</span>
<span class="line" id="L161">    }</span>
<span class="line" id="L162"></span>
<span class="line" id="L163">    <span class="tok-kw">if</span> (cross_target.os_version_min) |min| <span class="tok-kw">switch</span> (min) {</span>
<span class="line" id="L164">        .none =&gt; {},</span>
<span class="line" id="L165">        .semver =&gt; |semver| <span class="tok-kw">switch</span> (cross_target.getOsTag()) {</span>
<span class="line" id="L166">            .linux =&gt; os.version_range.linux.range.min = semver,</span>
<span class="line" id="L167">            <span class="tok-kw">else</span> =&gt; os.version_range.semver.min = semver,</span>
<span class="line" id="L168">        },</span>
<span class="line" id="L169">        .windows =&gt; |win_ver| os.version_range.windows.min = win_ver,</span>
<span class="line" id="L170">    };</span>
<span class="line" id="L171"></span>
<span class="line" id="L172">    <span class="tok-kw">if</span> (cross_target.os_version_max) |max| <span class="tok-kw">switch</span> (max) {</span>
<span class="line" id="L173">        .none =&gt; {},</span>
<span class="line" id="L174">        .semver =&gt; |semver| <span class="tok-kw">switch</span> (cross_target.getOsTag()) {</span>
<span class="line" id="L175">            .linux =&gt; os.version_range.linux.range.max = semver,</span>
<span class="line" id="L176">            <span class="tok-kw">else</span> =&gt; os.version_range.semver.max = semver,</span>
<span class="line" id="L177">        },</span>
<span class="line" id="L178">        .windows =&gt; |win_ver| os.version_range.windows.max = win_ver,</span>
<span class="line" id="L179">    };</span>
<span class="line" id="L180"></span>
<span class="line" id="L181">    <span class="tok-kw">if</span> (cross_target.glibc_version) |glibc| {</span>
<span class="line" id="L182">        assert(cross_target.isGnuLibC());</span>
<span class="line" id="L183">        os.version_range.linux.glibc = glibc;</span>
<span class="line" id="L184">    }</span>
<span class="line" id="L185"></span>
<span class="line" id="L186">    <span class="tok-comment">// Until https://github.com/ziglang/zig/issues/4592 is implemented (support detecting the</span>
</span>
<span class="line" id="L187">    <span class="tok-comment">// native CPU architecture as being different than the current target), we use this:</span>
</span>
<span class="line" id="L188">    <span class="tok-kw">const</span> cpu_arch = cross_target.getCpuArch();</span>
<span class="line" id="L189"></span>
<span class="line" id="L190">    <span class="tok-kw">var</span> cpu = <span class="tok-kw">switch</span> (cross_target.cpu_model) {</span>
<span class="line" id="L191">        .native =&gt; detectNativeCpuAndFeatures(cpu_arch, os, cross_target),</span>
<span class="line" id="L192">        .baseline =&gt; Target.Cpu.baseline(cpu_arch),</span>
<span class="line" id="L193">        .determined_by_cpu_arch =&gt; <span class="tok-kw">if</span> (cross_target.cpu_arch == <span class="tok-null">null</span>)</span>
<span class="line" id="L194">            detectNativeCpuAndFeatures(cpu_arch, os, cross_target)</span>
<span class="line" id="L195">        <span class="tok-kw">else</span></span>
<span class="line" id="L196">            Target.Cpu.baseline(cpu_arch),</span>
<span class="line" id="L197">        .explicit =&gt; |model| model.toCpu(cpu_arch),</span>
<span class="line" id="L198">    } <span class="tok-kw">orelse</span> backup_cpu_detection: {</span>
<span class="line" id="L199">        <span class="tok-kw">break</span> :backup_cpu_detection Target.Cpu.baseline(cpu_arch);</span>
<span class="line" id="L200">    };</span>
<span class="line" id="L201">    <span class="tok-kw">var</span> result = <span class="tok-kw">try</span> detectAbiAndDynamicLinker(allocator, cpu, os, cross_target);</span>
<span class="line" id="L202">    <span class="tok-comment">// For x86, we need to populate some CPU feature flags depending on architecture</span>
</span>
<span class="line" id="L203">    <span class="tok-comment">// and mode:</span>
</span>
<span class="line" id="L204">    <span class="tok-comment">//  * 16bit_mode =&gt; if the abi is code16</span>
</span>
<span class="line" id="L205">    <span class="tok-comment">//  * 32bit_mode =&gt; if the arch is i386</span>
</span>
<span class="line" id="L206">    <span class="tok-comment">// However, the &quot;mode&quot; flags can be used as overrides, so if the user explicitly</span>
</span>
<span class="line" id="L207">    <span class="tok-comment">// sets one of them, that takes precedence.</span>
</span>
<span class="line" id="L208">    <span class="tok-kw">switch</span> (cpu_arch) {</span>
<span class="line" id="L209">        .<span class="tok-type">i386</span> =&gt; {</span>
<span class="line" id="L210">            <span class="tok-kw">if</span> (!std.Target.x86.featureSetHasAny(cross_target.cpu_features_add, .{</span>
<span class="line" id="L211">                .@&quot;16bit_mode&quot;, .@&quot;32bit_mode&quot;,</span>
<span class="line" id="L212">            })) {</span>
<span class="line" id="L213">                <span class="tok-kw">switch</span> (result.target.abi) {</span>
<span class="line" id="L214">                    .code16 =&gt; result.target.cpu.features.addFeature(</span>
<span class="line" id="L215">                        <span class="tok-builtin">@enumToInt</span>(std.Target.x86.Feature.@&quot;16bit_mode&quot;),</span>
<span class="line" id="L216">                    ),</span>
<span class="line" id="L217">                    <span class="tok-kw">else</span> =&gt; result.target.cpu.features.addFeature(</span>
<span class="line" id="L218">                        <span class="tok-builtin">@enumToInt</span>(std.Target.x86.Feature.@&quot;32bit_mode&quot;),</span>
<span class="line" id="L219">                    ),</span>
<span class="line" id="L220">                }</span>
<span class="line" id="L221">            }</span>
<span class="line" id="L222">        },</span>
<span class="line" id="L223">        .arm, .armeb =&gt; {</span>
<span class="line" id="L224">            <span class="tok-comment">// XXX What do we do if the target has the noarm feature?</span>
</span>
<span class="line" id="L225">            <span class="tok-comment">//     What do we do if the user specifies +thumb_mode?</span>
</span>
<span class="line" id="L226">        },</span>
<span class="line" id="L227">        .thumb, .thumbeb =&gt; {</span>
<span class="line" id="L228">            result.target.cpu.features.addFeature(</span>
<span class="line" id="L229">                <span class="tok-builtin">@enumToInt</span>(std.Target.arm.Feature.thumb_mode),</span>
<span class="line" id="L230">            );</span>
<span class="line" id="L231">        },</span>
<span class="line" id="L232">        <span class="tok-kw">else</span> =&gt; {},</span>
<span class="line" id="L233">    }</span>
<span class="line" id="L234">    cross_target.updateCpuFeatures(&amp;result.target.cpu.features);</span>
<span class="line" id="L235">    <span class="tok-kw">return</span> result;</span>
<span class="line" id="L236">}</span>
<span class="line" id="L237"></span>
<span class="line" id="L238"><span class="tok-comment">/// First we attempt to use the executable's own binary. If it is dynamically</span></span>
<span class="line" id="L239"><span class="tok-comment">/// linked, then it should answer both the C ABI question and the dynamic linker question.</span></span>
<span class="line" id="L240"><span class="tok-comment">/// If it is statically linked, then we try /usr/bin/env (or the file it references in shebang). If that does not provide the answer, then</span></span>
<span class="line" id="L241"><span class="tok-comment">/// we fall back to the defaults.</span></span>
<span class="line" id="L242"><span class="tok-comment">/// TODO Remove the Allocator requirement from this function.</span></span>
<span class="line" id="L243"><span class="tok-kw">fn</span> <span class="tok-fn">detectAbiAndDynamicLinker</span>(</span>
<span class="line" id="L244">    allocator: Allocator,</span>
<span class="line" id="L245">    cpu: Target.Cpu,</span>
<span class="line" id="L246">    os: Target.Os,</span>
<span class="line" id="L247">    cross_target: CrossTarget,</span>
<span class="line" id="L248">) DetectError!NativeTargetInfo {</span>
<span class="line" id="L249">    <span class="tok-kw">const</span> native_target_has_ld = <span class="tok-kw">comptime</span> builtin.target.hasDynamicLinker();</span>
<span class="line" id="L250">    <span class="tok-kw">const</span> is_linux = builtin.target.os.tag == .linux;</span>
<span class="line" id="L251">    <span class="tok-kw">const</span> have_all_info = cross_target.dynamic_linker.get() != <span class="tok-null">null</span> <span class="tok-kw">and</span></span>
<span class="line" id="L252">        cross_target.abi != <span class="tok-null">null</span> <span class="tok-kw">and</span> (!is_linux <span class="tok-kw">or</span> cross_target.abi.?.isGnu());</span>
<span class="line" id="L253">    <span class="tok-kw">const</span> os_is_non_native = cross_target.os_tag != <span class="tok-null">null</span>;</span>
<span class="line" id="L254">    <span class="tok-kw">if</span> (!native_target_has_ld <span class="tok-kw">or</span> have_all_info <span class="tok-kw">or</span> os_is_non_native) {</span>
<span class="line" id="L255">        <span class="tok-kw">return</span> defaultAbiAndDynamicLinker(cpu, os, cross_target);</span>
<span class="line" id="L256">    }</span>
<span class="line" id="L257">    <span class="tok-kw">if</span> (cross_target.abi) |abi| {</span>
<span class="line" id="L258">        <span class="tok-kw">if</span> (abi.isMusl()) {</span>
<span class="line" id="L259">            <span class="tok-comment">// musl implies static linking.</span>
</span>
<span class="line" id="L260">            <span class="tok-kw">return</span> defaultAbiAndDynamicLinker(cpu, os, cross_target);</span>
<span class="line" id="L261">        }</span>
<span class="line" id="L262">    }</span>
<span class="line" id="L263">    <span class="tok-comment">// The current target's ABI cannot be relied on for this. For example, we may build the zig</span>
</span>
<span class="line" id="L264">    <span class="tok-comment">// compiler for target riscv64-linux-musl and provide a tarball for users to download.</span>
</span>
<span class="line" id="L265">    <span class="tok-comment">// A user could then run that zig compiler on riscv64-linux-gnu. This use case is well-defined</span>
</span>
<span class="line" id="L266">    <span class="tok-comment">// and supported by Zig. But that means that we must detect the system ABI here rather than</span>
</span>
<span class="line" id="L267">    <span class="tok-comment">// relying on `builtin.target`.</span>
</span>
<span class="line" id="L268">    <span class="tok-kw">const</span> all_abis = <span class="tok-kw">comptime</span> blk: {</span>
<span class="line" id="L269">        assert(<span class="tok-builtin">@enumToInt</span>(Target.Abi.none) == <span class="tok-number">0</span>);</span>
<span class="line" id="L270">        <span class="tok-kw">const</span> fields = std.meta.fields(Target.Abi)[<span class="tok-number">1</span>..];</span>
<span class="line" id="L271">        <span class="tok-kw">var</span> array: [fields.len]Target.Abi = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L272">        <span class="tok-kw">inline</span> <span class="tok-kw">for</span> (fields) |field, i| {</span>
<span class="line" id="L273">            array[i] = <span class="tok-builtin">@field</span>(Target.Abi, field.name);</span>
<span class="line" id="L274">        }</span>
<span class="line" id="L275">        <span class="tok-kw">break</span> :blk array;</span>
<span class="line" id="L276">    };</span>
<span class="line" id="L277">    <span class="tok-kw">var</span> ld_info_list_buffer: [all_abis.len]LdInfo = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L278">    <span class="tok-kw">var</span> ld_info_list_len: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L279">    <span class="tok-kw">const</span> ofmt = cross_target.ofmt <span class="tok-kw">orelse</span> Target.ObjectFormat.default(os.tag, cpu.arch);</span>
<span class="line" id="L280"></span>
<span class="line" id="L281">    <span class="tok-kw">for</span> (all_abis) |abi| {</span>
<span class="line" id="L282">        <span class="tok-comment">// This may be a nonsensical parameter. We detect this with error.UnknownDynamicLinkerPath and</span>
</span>
<span class="line" id="L283">        <span class="tok-comment">// skip adding it to `ld_info_list`.</span>
</span>
<span class="line" id="L284">        <span class="tok-kw">const</span> target: Target = .{</span>
<span class="line" id="L285">            .cpu = cpu,</span>
<span class="line" id="L286">            .os = os,</span>
<span class="line" id="L287">            .abi = abi,</span>
<span class="line" id="L288">            .ofmt = ofmt,</span>
<span class="line" id="L289">        };</span>
<span class="line" id="L290">        <span class="tok-kw">const</span> ld = target.standardDynamicLinkerPath();</span>
<span class="line" id="L291">        <span class="tok-kw">if</span> (ld.get() == <span class="tok-null">null</span>) <span class="tok-kw">continue</span>;</span>
<span class="line" id="L292"></span>
<span class="line" id="L293">        ld_info_list_buffer[ld_info_list_len] = .{</span>
<span class="line" id="L294">            .ld = ld,</span>
<span class="line" id="L295">            .abi = abi,</span>
<span class="line" id="L296">        };</span>
<span class="line" id="L297">        ld_info_list_len += <span class="tok-number">1</span>;</span>
<span class="line" id="L298">    }</span>
<span class="line" id="L299">    <span class="tok-kw">const</span> ld_info_list = ld_info_list_buffer[<span class="tok-number">0</span>..ld_info_list_len];</span>
<span class="line" id="L300"></span>
<span class="line" id="L301">    <span class="tok-comment">// Best case scenario: the executable is dynamically linked, and we can iterate</span>
</span>
<span class="line" id="L302">    <span class="tok-comment">// over our own shared objects and find a dynamic linker.</span>
</span>
<span class="line" id="L303">    self_exe: {</span>
<span class="line" id="L304">        <span class="tok-kw">const</span> lib_paths = <span class="tok-kw">try</span> std.process.getSelfExeSharedLibPaths(allocator);</span>
<span class="line" id="L305">        <span class="tok-kw">defer</span> {</span>
<span class="line" id="L306">            <span class="tok-kw">for</span> (lib_paths) |lib_path| {</span>
<span class="line" id="L307">                allocator.free(lib_path);</span>
<span class="line" id="L308">            }</span>
<span class="line" id="L309">            allocator.free(lib_paths);</span>
<span class="line" id="L310">        }</span>
<span class="line" id="L311"></span>
<span class="line" id="L312">        <span class="tok-kw">var</span> found_ld_info: LdInfo = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L313">        <span class="tok-kw">var</span> found_ld_path: [:<span class="tok-number">0</span>]<span class="tok-kw">const</span> <span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L314"></span>
<span class="line" id="L315">        <span class="tok-comment">// Look for dynamic linker.</span>
</span>
<span class="line" id="L316">        <span class="tok-comment">// This is O(N^M) but typical case here is N=2 and M=10.</span>
</span>
<span class="line" id="L317">        find_ld: <span class="tok-kw">for</span> (lib_paths) |lib_path| {</span>
<span class="line" id="L318">            <span class="tok-kw">for</span> (ld_info_list) |ld_info| {</span>
<span class="line" id="L319">                <span class="tok-kw">const</span> standard_ld_basename = fs.path.basename(ld_info.ld.get().?);</span>
<span class="line" id="L320">                <span class="tok-kw">if</span> (std.mem.endsWith(<span class="tok-type">u8</span>, lib_path, standard_ld_basename)) {</span>
<span class="line" id="L321">                    found_ld_info = ld_info;</span>
<span class="line" id="L322">                    found_ld_path = lib_path;</span>
<span class="line" id="L323">                    <span class="tok-kw">break</span> :find_ld;</span>
<span class="line" id="L324">                }</span>
<span class="line" id="L325">            }</span>
<span class="line" id="L326">        } <span class="tok-kw">else</span> <span class="tok-kw">break</span> :self_exe;</span>
<span class="line" id="L327"></span>
<span class="line" id="L328">        <span class="tok-comment">// Look for glibc version.</span>
</span>
<span class="line" id="L329">        <span class="tok-kw">var</span> os_adjusted = os;</span>
<span class="line" id="L330">        <span class="tok-kw">if</span> (builtin.target.os.tag == .linux <span class="tok-kw">and</span> found_ld_info.abi.isGnu() <span class="tok-kw">and</span></span>
<span class="line" id="L331">            cross_target.glibc_version == <span class="tok-null">null</span>)</span>
<span class="line" id="L332">        {</span>
<span class="line" id="L333">            <span class="tok-kw">for</span> (lib_paths) |lib_path| {</span>
<span class="line" id="L334">                <span class="tok-kw">if</span> (std.mem.endsWith(<span class="tok-type">u8</span>, lib_path, glibc_so_basename)) {</span>
<span class="line" id="L335">                    os_adjusted.version_range.linux.glibc = glibcVerFromSO(lib_path) <span class="tok-kw">catch</span> |err| <span class="tok-kw">switch</span> (err) {</span>
<span class="line" id="L336">                        <span class="tok-kw">error</span>.UnrecognizedGnuLibCFileName =&gt; <span class="tok-kw">continue</span>,</span>
<span class="line" id="L337">                        <span class="tok-kw">error</span>.InvalidGnuLibCVersion =&gt; <span class="tok-kw">continue</span>,</span>
<span class="line" id="L338">                        <span class="tok-kw">error</span>.GnuLibCVersionUnavailable =&gt; <span class="tok-kw">continue</span>,</span>
<span class="line" id="L339">                        <span class="tok-kw">else</span> =&gt; |e| <span class="tok-kw">return</span> e,</span>
<span class="line" id="L340">                    };</span>
<span class="line" id="L341">                    <span class="tok-kw">break</span>;</span>
<span class="line" id="L342">                }</span>
<span class="line" id="L343">            }</span>
<span class="line" id="L344">        }</span>
<span class="line" id="L345"></span>
<span class="line" id="L346">        <span class="tok-kw">var</span> result: NativeTargetInfo = .{</span>
<span class="line" id="L347">            .target = .{</span>
<span class="line" id="L348">                .cpu = cpu,</span>
<span class="line" id="L349">                .os = os_adjusted,</span>
<span class="line" id="L350">                .abi = cross_target.abi <span class="tok-kw">orelse</span> found_ld_info.abi,</span>
<span class="line" id="L351">                .ofmt = cross_target.ofmt <span class="tok-kw">orelse</span> Target.ObjectFormat.default(os_adjusted.tag, cpu.arch),</span>
<span class="line" id="L352">            },</span>
<span class="line" id="L353">            .dynamic_linker = <span class="tok-kw">if</span> (cross_target.dynamic_linker.get() == <span class="tok-null">null</span>)</span>
<span class="line" id="L354">                DynamicLinker.init(found_ld_path)</span>
<span class="line" id="L355">            <span class="tok-kw">else</span></span>
<span class="line" id="L356">                cross_target.dynamic_linker,</span>
<span class="line" id="L357">        };</span>
<span class="line" id="L358">        <span class="tok-kw">return</span> result;</span>
<span class="line" id="L359">    }</span>
<span class="line" id="L360"></span>
<span class="line" id="L361">    <span class="tok-kw">const</span> elf_file = blk: {</span>
<span class="line" id="L362">        <span class="tok-comment">// This block looks for a shebang line in /usr/bin/env,</span>
</span>
<span class="line" id="L363">        <span class="tok-comment">// if it finds one, then instead of using /usr/bin/env as the ELF file to examine, it uses the file it references instead,</span>
</span>
<span class="line" id="L364">        <span class="tok-comment">// doing the same logic recursively in case it finds another shebang line.</span>
</span>
<span class="line" id="L365"></span>
<span class="line" id="L366">        <span class="tok-comment">// Since /usr/bin/env is hard-coded into the shebang line of many portable scripts, it's a</span>
</span>
<span class="line" id="L367">        <span class="tok-comment">// reasonably reliable path to start with.</span>
</span>
<span class="line" id="L368">        <span class="tok-kw">var</span> file_name: []<span class="tok-kw">const</span> <span class="tok-type">u8</span> = <span class="tok-str">&quot;/usr/bin/env&quot;</span>;</span>
<span class="line" id="L369">        <span class="tok-comment">// #! (2) + 255 (max length of shebang line since Linux 5.1) + \n (1)</span>
</span>
<span class="line" id="L370">        <span class="tok-kw">var</span> buffer: [<span class="tok-number">258</span>]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L371">        <span class="tok-kw">while</span> (<span class="tok-null">true</span>) {</span>
<span class="line" id="L372">            <span class="tok-kw">const</span> file = std.fs.openFileAbsolute(file_name, .{}) <span class="tok-kw">catch</span> |err| <span class="tok-kw">switch</span> (err) {</span>
<span class="line" id="L373">                <span class="tok-kw">error</span>.NoSpaceLeft =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L374">                <span class="tok-kw">error</span>.NameTooLong =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L375">                <span class="tok-kw">error</span>.PathAlreadyExists =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L376">                <span class="tok-kw">error</span>.SharingViolation =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L377">                <span class="tok-kw">error</span>.InvalidUtf8 =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L378">                <span class="tok-kw">error</span>.BadPathName =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L379">                <span class="tok-kw">error</span>.PipeBusy =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L380">                <span class="tok-kw">error</span>.FileLocksNotSupported =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L381">                <span class="tok-kw">error</span>.WouldBlock =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L382">                <span class="tok-kw">error</span>.FileBusy =&gt; <span class="tok-kw">unreachable</span>, <span class="tok-comment">// opened without write permissions</span>
</span>
<span class="line" id="L383"></span>
<span class="line" id="L384">                <span class="tok-kw">error</span>.IsDir,</span>
<span class="line" id="L385">                <span class="tok-kw">error</span>.NotDir,</span>
<span class="line" id="L386">                <span class="tok-kw">error</span>.InvalidHandle,</span>
<span class="line" id="L387">                <span class="tok-kw">error</span>.AccessDenied,</span>
<span class="line" id="L388">                <span class="tok-kw">error</span>.NoDevice,</span>
<span class="line" id="L389">                <span class="tok-kw">error</span>.FileNotFound,</span>
<span class="line" id="L390">                <span class="tok-kw">error</span>.FileTooBig,</span>
<span class="line" id="L391">                <span class="tok-kw">error</span>.Unexpected,</span>
<span class="line" id="L392">                =&gt; |e| {</span>
<span class="line" id="L393">                    std.log.warn(<span class="tok-str">&quot;Encoutered error: {s}, falling back to default ABI and dynamic linker.\n&quot;</span>, .{<span class="tok-builtin">@errorName</span>(e)});</span>
<span class="line" id="L394">                    <span class="tok-kw">return</span> defaultAbiAndDynamicLinker(cpu, os, cross_target);</span>
<span class="line" id="L395">                },</span>
<span class="line" id="L396"></span>
<span class="line" id="L397">                <span class="tok-kw">else</span> =&gt; |e| <span class="tok-kw">return</span> e,</span>
<span class="line" id="L398">            };</span>
<span class="line" id="L399"></span>
<span class="line" id="L400">            <span class="tok-kw">const</span> line = file.reader().readUntilDelimiter(&amp;buffer, <span class="tok-str">'\n'</span>) <span class="tok-kw">catch</span> |err| <span class="tok-kw">switch</span> (err) {</span>
<span class="line" id="L401">                <span class="tok-kw">error</span>.IsDir =&gt; <span class="tok-kw">unreachable</span>, <span class="tok-comment">// Handled before</span>
</span>
<span class="line" id="L402">                <span class="tok-kw">error</span>.AccessDenied =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L403">                <span class="tok-kw">error</span>.WouldBlock =&gt; <span class="tok-kw">unreachable</span>, <span class="tok-comment">// Did not request blocking mode</span>
</span>
<span class="line" id="L404">                <span class="tok-kw">error</span>.OperationAborted =&gt; <span class="tok-kw">unreachable</span>, <span class="tok-comment">// Windows-only</span>
</span>
<span class="line" id="L405">                <span class="tok-kw">error</span>.BrokenPipe =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L406">                <span class="tok-kw">error</span>.ConnectionResetByPeer =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L407">                <span class="tok-kw">error</span>.ConnectionTimedOut =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L408">                <span class="tok-kw">error</span>.InputOutput =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L409">                <span class="tok-kw">error</span>.Unexpected =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L410"></span>
<span class="line" id="L411">                <span class="tok-kw">error</span>.StreamTooLong,</span>
<span class="line" id="L412">                <span class="tok-kw">error</span>.EndOfStream,</span>
<span class="line" id="L413">                <span class="tok-kw">error</span>.NotOpenForReading,</span>
<span class="line" id="L414">                =&gt; <span class="tok-kw">break</span> :blk file,</span>
<span class="line" id="L415"></span>
<span class="line" id="L416">                <span class="tok-kw">else</span> =&gt; |e| {</span>
<span class="line" id="L417">                    file.close();</span>
<span class="line" id="L418">                    <span class="tok-kw">return</span> e;</span>
<span class="line" id="L419">                },</span>
<span class="line" id="L420">            };</span>
<span class="line" id="L421">            <span class="tok-kw">if</span> (!mem.startsWith(<span class="tok-type">u8</span>, line, <span class="tok-str">&quot;#!&quot;</span>)) <span class="tok-kw">break</span> :blk file;</span>
<span class="line" id="L422">            <span class="tok-kw">var</span> it = std.mem.tokenize(<span class="tok-type">u8</span>, line[<span class="tok-number">2</span>..], <span class="tok-str">&quot; &quot;</span>);</span>
<span class="line" id="L423">            file.close();</span>
<span class="line" id="L424">            file_name = it.next() <span class="tok-kw">orelse</span> <span class="tok-kw">return</span> defaultAbiAndDynamicLinker(cpu, os, cross_target);</span>
<span class="line" id="L425">        }</span>
<span class="line" id="L426">    };</span>
<span class="line" id="L427">    <span class="tok-kw">defer</span> elf_file.close();</span>
<span class="line" id="L428"></span>
<span class="line" id="L429">    <span class="tok-comment">// If Zig is statically linked, such as via distributed binary static builds, the above</span>
</span>
<span class="line" id="L430">    <span class="tok-comment">// trick (block self_exe) won't work. The next thing we fall back to is the same thing, but for elf_file.</span>
</span>
<span class="line" id="L431">    <span class="tok-kw">return</span> abiAndDynamicLinkerFromFile(elf_file, cpu, os, ld_info_list, cross_target) <span class="tok-kw">catch</span> |err| <span class="tok-kw">switch</span> (err) {</span>
<span class="line" id="L432">        <span class="tok-kw">error</span>.FileSystem,</span>
<span class="line" id="L433">        <span class="tok-kw">error</span>.SystemResources,</span>
<span class="line" id="L434">        <span class="tok-kw">error</span>.SymLinkLoop,</span>
<span class="line" id="L435">        <span class="tok-kw">error</span>.ProcessFdQuotaExceeded,</span>
<span class="line" id="L436">        <span class="tok-kw">error</span>.SystemFdQuotaExceeded,</span>
<span class="line" id="L437">        =&gt; |e| <span class="tok-kw">return</span> e,</span>
<span class="line" id="L438"></span>
<span class="line" id="L439">        <span class="tok-kw">error</span>.UnableToReadElfFile,</span>
<span class="line" id="L440">        <span class="tok-kw">error</span>.InvalidElfClass,</span>
<span class="line" id="L441">        <span class="tok-kw">error</span>.InvalidElfVersion,</span>
<span class="line" id="L442">        <span class="tok-kw">error</span>.InvalidElfEndian,</span>
<span class="line" id="L443">        <span class="tok-kw">error</span>.InvalidElfFile,</span>
<span class="line" id="L444">        <span class="tok-kw">error</span>.InvalidElfMagic,</span>
<span class="line" id="L445">        <span class="tok-kw">error</span>.Unexpected,</span>
<span class="line" id="L446">        <span class="tok-kw">error</span>.UnexpectedEndOfFile,</span>
<span class="line" id="L447">        <span class="tok-kw">error</span>.NameTooLong,</span>
<span class="line" id="L448">        <span class="tok-comment">// Finally, we fall back on the standard path.</span>
</span>
<span class="line" id="L449">        =&gt; |e| {</span>
<span class="line" id="L450">            std.log.warn(<span class="tok-str">&quot;Encoutered error: {s}, falling back to default ABI and dynamic linker.\n&quot;</span>, .{<span class="tok-builtin">@errorName</span>(e)});</span>
<span class="line" id="L451">            <span class="tok-kw">return</span> defaultAbiAndDynamicLinker(cpu, os, cross_target);</span>
<span class="line" id="L452">        },</span>
<span class="line" id="L453">    };</span>
<span class="line" id="L454">}</span>
<span class="line" id="L455"></span>
<span class="line" id="L456"><span class="tok-kw">const</span> glibc_so_basename = <span class="tok-str">&quot;libc.so.6&quot;</span>;</span>
<span class="line" id="L457"></span>
<span class="line" id="L458"><span class="tok-kw">fn</span> <span class="tok-fn">glibcVerFromSO</span>(so_path: [:<span class="tok-number">0</span>]<span class="tok-kw">const</span> <span class="tok-type">u8</span>) !std.builtin.Version {</span>
<span class="line" id="L459">    <span class="tok-kw">var</span> link_buf: [std.os.PATH_MAX]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L460">    <span class="tok-kw">const</span> link_name = std.os.readlinkZ(so_path.ptr, &amp;link_buf) <span class="tok-kw">catch</span> |err| <span class="tok-kw">switch</span> (err) {</span>
<span class="line" id="L461">        <span class="tok-kw">error</span>.AccessDenied =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.GnuLibCVersionUnavailable,</span>
<span class="line" id="L462">        <span class="tok-kw">error</span>.FileSystem =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.FileSystem,</span>
<span class="line" id="L463">        <span class="tok-kw">error</span>.SymLinkLoop =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.SymLinkLoop,</span>
<span class="line" id="L464">        <span class="tok-kw">error</span>.NameTooLong =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L465">        <span class="tok-kw">error</span>.NotLink =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.GnuLibCVersionUnavailable,</span>
<span class="line" id="L466">        <span class="tok-kw">error</span>.FileNotFound =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.GnuLibCVersionUnavailable,</span>
<span class="line" id="L467">        <span class="tok-kw">error</span>.SystemResources =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.SystemResources,</span>
<span class="line" id="L468">        <span class="tok-kw">error</span>.NotDir =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.GnuLibCVersionUnavailable,</span>
<span class="line" id="L469">        <span class="tok-kw">error</span>.Unexpected =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.GnuLibCVersionUnavailable,</span>
<span class="line" id="L470">        <span class="tok-kw">error</span>.InvalidUtf8 =&gt; <span class="tok-kw">unreachable</span>, <span class="tok-comment">// Windows only</span>
</span>
<span class="line" id="L471">        <span class="tok-kw">error</span>.BadPathName =&gt; <span class="tok-kw">unreachable</span>, <span class="tok-comment">// Windows only</span>
</span>
<span class="line" id="L472">        <span class="tok-kw">error</span>.UnsupportedReparsePointType =&gt; <span class="tok-kw">unreachable</span>, <span class="tok-comment">// Windows only</span>
</span>
<span class="line" id="L473">    };</span>
<span class="line" id="L474">    <span class="tok-kw">return</span> glibcVerFromLinkName(link_name, <span class="tok-str">&quot;libc-&quot;</span>);</span>
<span class="line" id="L475">}</span>
<span class="line" id="L476"></span>
<span class="line" id="L477"><span class="tok-kw">fn</span> <span class="tok-fn">glibcVerFromLinkName</span>(link_name: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>, prefix: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) !std.builtin.Version {</span>
<span class="line" id="L478">    <span class="tok-comment">// example: &quot;libc-2.3.4.so&quot;</span>
</span>
<span class="line" id="L479">    <span class="tok-comment">// example: &quot;libc-2.27.so&quot;</span>
</span>
<span class="line" id="L480">    <span class="tok-comment">// example: &quot;ld-2.33.so&quot;</span>
</span>
<span class="line" id="L481">    <span class="tok-kw">const</span> suffix = <span class="tok-str">&quot;.so&quot;</span>;</span>
<span class="line" id="L482">    <span class="tok-kw">if</span> (!mem.startsWith(<span class="tok-type">u8</span>, link_name, prefix) <span class="tok-kw">or</span> !mem.endsWith(<span class="tok-type">u8</span>, link_name, suffix)) {</span>
<span class="line" id="L483">        <span class="tok-kw">return</span> <span class="tok-kw">error</span>.UnrecognizedGnuLibCFileName;</span>
<span class="line" id="L484">    }</span>
<span class="line" id="L485">    <span class="tok-comment">// chop off &quot;libc-&quot; and &quot;.so&quot;</span>
</span>
<span class="line" id="L486">    <span class="tok-kw">const</span> link_name_chopped = link_name[prefix.len .. link_name.len - suffix.len];</span>
<span class="line" id="L487">    <span class="tok-kw">return</span> std.builtin.Version.parse(link_name_chopped) <span class="tok-kw">catch</span> |err| <span class="tok-kw">switch</span> (err) {</span>
<span class="line" id="L488">        <span class="tok-kw">error</span>.Overflow =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.InvalidGnuLibCVersion,</span>
<span class="line" id="L489">        <span class="tok-kw">error</span>.InvalidCharacter =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.InvalidGnuLibCVersion,</span>
<span class="line" id="L490">        <span class="tok-kw">error</span>.InvalidVersion =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.InvalidGnuLibCVersion,</span>
<span class="line" id="L491">    };</span>
<span class="line" id="L492">}</span>
<span class="line" id="L493"></span>
<span class="line" id="L494"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> AbiAndDynamicLinkerFromFileError = <span class="tok-kw">error</span>{</span>
<span class="line" id="L495">    FileSystem,</span>
<span class="line" id="L496">    SystemResources,</span>
<span class="line" id="L497">    SymLinkLoop,</span>
<span class="line" id="L498">    ProcessFdQuotaExceeded,</span>
<span class="line" id="L499">    SystemFdQuotaExceeded,</span>
<span class="line" id="L500">    UnableToReadElfFile,</span>
<span class="line" id="L501">    InvalidElfClass,</span>
<span class="line" id="L502">    InvalidElfVersion,</span>
<span class="line" id="L503">    InvalidElfEndian,</span>
<span class="line" id="L504">    InvalidElfFile,</span>
<span class="line" id="L505">    InvalidElfMagic,</span>
<span class="line" id="L506">    Unexpected,</span>
<span class="line" id="L507">    UnexpectedEndOfFile,</span>
<span class="line" id="L508">    NameTooLong,</span>
<span class="line" id="L509">};</span>
<span class="line" id="L510"></span>
<span class="line" id="L511"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">abiAndDynamicLinkerFromFile</span>(</span>
<span class="line" id="L512">    file: fs.File,</span>
<span class="line" id="L513">    cpu: Target.Cpu,</span>
<span class="line" id="L514">    os: Target.Os,</span>
<span class="line" id="L515">    ld_info_list: []<span class="tok-kw">const</span> LdInfo,</span>
<span class="line" id="L516">    cross_target: CrossTarget,</span>
<span class="line" id="L517">) AbiAndDynamicLinkerFromFileError!NativeTargetInfo {</span>
<span class="line" id="L518">    <span class="tok-kw">var</span> hdr_buf: [<span class="tok-builtin">@sizeOf</span>(elf.Elf64_Ehdr)]<span class="tok-type">u8</span> <span class="tok-kw">align</span>(<span class="tok-builtin">@alignOf</span>(elf.Elf64_Ehdr)) = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L519">    _ = <span class="tok-kw">try</span> preadMin(file, &amp;hdr_buf, <span class="tok-number">0</span>, hdr_buf.len);</span>
<span class="line" id="L520">    <span class="tok-kw">const</span> hdr32 = <span class="tok-builtin">@ptrCast</span>(*elf.Elf32_Ehdr, &amp;hdr_buf);</span>
<span class="line" id="L521">    <span class="tok-kw">const</span> hdr64 = <span class="tok-builtin">@ptrCast</span>(*elf.Elf64_Ehdr, &amp;hdr_buf);</span>
<span class="line" id="L522">    <span class="tok-kw">if</span> (!mem.eql(<span class="tok-type">u8</span>, hdr32.e_ident[<span class="tok-number">0</span>..<span class="tok-number">4</span>], elf.MAGIC)) <span class="tok-kw">return</span> <span class="tok-kw">error</span>.InvalidElfMagic;</span>
<span class="line" id="L523">    <span class="tok-kw">const</span> elf_endian: std.builtin.Endian = <span class="tok-kw">switch</span> (hdr32.e_ident[elf.EI_DATA]) {</span>
<span class="line" id="L524">        elf.ELFDATA2LSB =&gt; .Little,</span>
<span class="line" id="L525">        elf.ELFDATA2MSB =&gt; .Big,</span>
<span class="line" id="L526">        <span class="tok-kw">else</span> =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.InvalidElfEndian,</span>
<span class="line" id="L527">    };</span>
<span class="line" id="L528">    <span class="tok-kw">const</span> need_bswap = elf_endian != native_endian;</span>
<span class="line" id="L529">    <span class="tok-kw">if</span> (hdr32.e_ident[elf.EI_VERSION] != <span class="tok-number">1</span>) <span class="tok-kw">return</span> <span class="tok-kw">error</span>.InvalidElfVersion;</span>
<span class="line" id="L530"></span>
<span class="line" id="L531">    <span class="tok-kw">const</span> is_64 = <span class="tok-kw">switch</span> (hdr32.e_ident[elf.EI_CLASS]) {</span>
<span class="line" id="L532">        elf.ELFCLASS32 =&gt; <span class="tok-null">false</span>,</span>
<span class="line" id="L533">        elf.ELFCLASS64 =&gt; <span class="tok-null">true</span>,</span>
<span class="line" id="L534">        <span class="tok-kw">else</span> =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.InvalidElfClass,</span>
<span class="line" id="L535">    };</span>
<span class="line" id="L536">    <span class="tok-kw">var</span> phoff = elfInt(is_64, need_bswap, hdr32.e_phoff, hdr64.e_phoff);</span>
<span class="line" id="L537">    <span class="tok-kw">const</span> phentsize = elfInt(is_64, need_bswap, hdr32.e_phentsize, hdr64.e_phentsize);</span>
<span class="line" id="L538">    <span class="tok-kw">const</span> phnum = elfInt(is_64, need_bswap, hdr32.e_phnum, hdr64.e_phnum);</span>
<span class="line" id="L539"></span>
<span class="line" id="L540">    <span class="tok-kw">var</span> result: NativeTargetInfo = .{</span>
<span class="line" id="L541">        .target = .{</span>
<span class="line" id="L542">            .cpu = cpu,</span>
<span class="line" id="L543">            .os = os,</span>
<span class="line" id="L544">            .abi = cross_target.abi <span class="tok-kw">orelse</span> Target.Abi.default(cpu.arch, os),</span>
<span class="line" id="L545">            .ofmt = cross_target.ofmt <span class="tok-kw">orelse</span> Target.ObjectFormat.default(os.tag, cpu.arch),</span>
<span class="line" id="L546">        },</span>
<span class="line" id="L547">        .dynamic_linker = cross_target.dynamic_linker,</span>
<span class="line" id="L548">    };</span>
<span class="line" id="L549">    <span class="tok-kw">var</span> rpath_offset: ?<span class="tok-type">u64</span> = <span class="tok-null">null</span>; <span class="tok-comment">// Found inside PT_DYNAMIC</span>
</span>
<span class="line" id="L550">    <span class="tok-kw">const</span> look_for_ld = cross_target.dynamic_linker.get() == <span class="tok-null">null</span>;</span>
<span class="line" id="L551"></span>
<span class="line" id="L552">    <span class="tok-kw">var</span> ph_buf: [<span class="tok-number">16</span> * <span class="tok-builtin">@sizeOf</span>(elf.Elf64_Phdr)]<span class="tok-type">u8</span> <span class="tok-kw">align</span>(<span class="tok-builtin">@alignOf</span>(elf.Elf64_Phdr)) = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L553">    <span class="tok-kw">if</span> (phentsize &gt; <span class="tok-builtin">@sizeOf</span>(elf.Elf64_Phdr)) <span class="tok-kw">return</span> <span class="tok-kw">error</span>.InvalidElfFile;</span>
<span class="line" id="L554"></span>
<span class="line" id="L555">    <span class="tok-kw">var</span> ph_i: <span class="tok-type">u16</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L556">    <span class="tok-kw">while</span> (ph_i &lt; phnum) {</span>
<span class="line" id="L557">        <span class="tok-comment">// Reserve some bytes so that we can deref the 64-bit struct fields</span>
</span>
<span class="line" id="L558">        <span class="tok-comment">// even when the ELF file is 32-bits.</span>
</span>
<span class="line" id="L559">        <span class="tok-kw">const</span> ph_reserve: <span class="tok-type">usize</span> = <span class="tok-builtin">@sizeOf</span>(elf.Elf64_Phdr) - <span class="tok-builtin">@sizeOf</span>(elf.Elf32_Phdr);</span>
<span class="line" id="L560">        <span class="tok-kw">const</span> ph_read_byte_len = <span class="tok-kw">try</span> preadMin(file, ph_buf[<span class="tok-number">0</span> .. ph_buf.len - ph_reserve], phoff, phentsize);</span>
<span class="line" id="L561">        <span class="tok-kw">var</span> ph_buf_i: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L562">        <span class="tok-kw">while</span> (ph_buf_i &lt; ph_read_byte_len <span class="tok-kw">and</span> ph_i &lt; phnum) : ({</span>
<span class="line" id="L563">            ph_i += <span class="tok-number">1</span>;</span>
<span class="line" id="L564">            phoff += phentsize;</span>
<span class="line" id="L565">            ph_buf_i += phentsize;</span>
<span class="line" id="L566">        }) {</span>
<span class="line" id="L567">            <span class="tok-kw">const</span> ph32 = <span class="tok-builtin">@ptrCast</span>(*elf.Elf32_Phdr, <span class="tok-builtin">@alignCast</span>(<span class="tok-builtin">@alignOf</span>(elf.Elf32_Phdr), &amp;ph_buf[ph_buf_i]));</span>
<span class="line" id="L568">            <span class="tok-kw">const</span> ph64 = <span class="tok-builtin">@ptrCast</span>(*elf.Elf64_Phdr, <span class="tok-builtin">@alignCast</span>(<span class="tok-builtin">@alignOf</span>(elf.Elf64_Phdr), &amp;ph_buf[ph_buf_i]));</span>
<span class="line" id="L569">            <span class="tok-kw">const</span> p_type = elfInt(is_64, need_bswap, ph32.p_type, ph64.p_type);</span>
<span class="line" id="L570">            <span class="tok-kw">switch</span> (p_type) {</span>
<span class="line" id="L571">                elf.PT_INTERP =&gt; <span class="tok-kw">if</span> (look_for_ld) {</span>
<span class="line" id="L572">                    <span class="tok-kw">const</span> p_offset = elfInt(is_64, need_bswap, ph32.p_offset, ph64.p_offset);</span>
<span class="line" id="L573">                    <span class="tok-kw">const</span> p_filesz = elfInt(is_64, need_bswap, ph32.p_filesz, ph64.p_filesz);</span>
<span class="line" id="L574">                    <span class="tok-kw">if</span> (p_filesz &gt; result.dynamic_linker.buffer.len) <span class="tok-kw">return</span> <span class="tok-kw">error</span>.NameTooLong;</span>
<span class="line" id="L575">                    <span class="tok-kw">const</span> filesz = <span class="tok-builtin">@intCast</span>(<span class="tok-type">usize</span>, p_filesz);</span>
<span class="line" id="L576">                    _ = <span class="tok-kw">try</span> preadMin(file, result.dynamic_linker.buffer[<span class="tok-number">0</span>..filesz], p_offset, filesz);</span>
<span class="line" id="L577">                    <span class="tok-comment">// PT_INTERP includes a null byte in filesz.</span>
</span>
<span class="line" id="L578">                    <span class="tok-kw">const</span> len = filesz - <span class="tok-number">1</span>;</span>
<span class="line" id="L579">                    <span class="tok-comment">// dynamic_linker.max_byte is &quot;max&quot;, not &quot;len&quot;.</span>
</span>
<span class="line" id="L580">                    <span class="tok-comment">// We know it will fit in u8 because we check against dynamic_linker.buffer.len above.</span>
</span>
<span class="line" id="L581">                    result.dynamic_linker.max_byte = <span class="tok-builtin">@intCast</span>(<span class="tok-type">u8</span>, len - <span class="tok-number">1</span>);</span>
<span class="line" id="L582"></span>
<span class="line" id="L583">                    <span class="tok-comment">// Use it to determine ABI.</span>
</span>
<span class="line" id="L584">                    <span class="tok-kw">const</span> full_ld_path = result.dynamic_linker.buffer[<span class="tok-number">0</span>..len];</span>
<span class="line" id="L585">                    <span class="tok-kw">for</span> (ld_info_list) |ld_info| {</span>
<span class="line" id="L586">                        <span class="tok-kw">const</span> standard_ld_basename = fs.path.basename(ld_info.ld.get().?);</span>
<span class="line" id="L587">                        <span class="tok-kw">if</span> (std.mem.endsWith(<span class="tok-type">u8</span>, full_ld_path, standard_ld_basename)) {</span>
<span class="line" id="L588">                            result.target.abi = ld_info.abi;</span>
<span class="line" id="L589">                            <span class="tok-kw">break</span>;</span>
<span class="line" id="L590">                        }</span>
<span class="line" id="L591">                    }</span>
<span class="line" id="L592">                },</span>
<span class="line" id="L593">                <span class="tok-comment">// We only need this for detecting glibc version.</span>
</span>
<span class="line" id="L594">                elf.PT_DYNAMIC =&gt; <span class="tok-kw">if</span> (builtin.target.os.tag == .linux <span class="tok-kw">and</span> result.target.isGnuLibC() <span class="tok-kw">and</span></span>
<span class="line" id="L595">                    cross_target.glibc_version == <span class="tok-null">null</span>)</span>
<span class="line" id="L596">                {</span>
<span class="line" id="L597">                    <span class="tok-kw">var</span> dyn_off = elfInt(is_64, need_bswap, ph32.p_offset, ph64.p_offset);</span>
<span class="line" id="L598">                    <span class="tok-kw">const</span> p_filesz = elfInt(is_64, need_bswap, ph32.p_filesz, ph64.p_filesz);</span>
<span class="line" id="L599">                    <span class="tok-kw">const</span> dyn_size: <span class="tok-type">usize</span> = <span class="tok-kw">if</span> (is_64) <span class="tok-builtin">@sizeOf</span>(elf.Elf64_Dyn) <span class="tok-kw">else</span> <span class="tok-builtin">@sizeOf</span>(elf.Elf32_Dyn);</span>
<span class="line" id="L600">                    <span class="tok-kw">const</span> dyn_num = p_filesz / dyn_size;</span>
<span class="line" id="L601">                    <span class="tok-kw">var</span> dyn_buf: [<span class="tok-number">16</span> * <span class="tok-builtin">@sizeOf</span>(elf.Elf64_Dyn)]<span class="tok-type">u8</span> <span class="tok-kw">align</span>(<span class="tok-builtin">@alignOf</span>(elf.Elf64_Dyn)) = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L602">                    <span class="tok-kw">var</span> dyn_i: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L603">                    dyn: <span class="tok-kw">while</span> (dyn_i &lt; dyn_num) {</span>
<span class="line" id="L604">                        <span class="tok-comment">// Reserve some bytes so that we can deref the 64-bit struct fields</span>
</span>
<span class="line" id="L605">                        <span class="tok-comment">// even when the ELF file is 32-bits.</span>
</span>
<span class="line" id="L606">                        <span class="tok-kw">const</span> dyn_reserve: <span class="tok-type">usize</span> = <span class="tok-builtin">@sizeOf</span>(elf.Elf64_Dyn) - <span class="tok-builtin">@sizeOf</span>(elf.Elf32_Dyn);</span>
<span class="line" id="L607">                        <span class="tok-kw">const</span> dyn_read_byte_len = <span class="tok-kw">try</span> preadMin(</span>
<span class="line" id="L608">                            file,</span>
<span class="line" id="L609">                            dyn_buf[<span class="tok-number">0</span> .. dyn_buf.len - dyn_reserve],</span>
<span class="line" id="L610">                            dyn_off,</span>
<span class="line" id="L611">                            dyn_size,</span>
<span class="line" id="L612">                        );</span>
<span class="line" id="L613">                        <span class="tok-kw">var</span> dyn_buf_i: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L614">                        <span class="tok-kw">while</span> (dyn_buf_i &lt; dyn_read_byte_len <span class="tok-kw">and</span> dyn_i &lt; dyn_num) : ({</span>
<span class="line" id="L615">                            dyn_i += <span class="tok-number">1</span>;</span>
<span class="line" id="L616">                            dyn_off += dyn_size;</span>
<span class="line" id="L617">                            dyn_buf_i += dyn_size;</span>
<span class="line" id="L618">                        }) {</span>
<span class="line" id="L619">                            <span class="tok-kw">const</span> dyn32 = <span class="tok-builtin">@ptrCast</span>(</span>
<span class="line" id="L620">                                *elf.Elf32_Dyn,</span>
<span class="line" id="L621">                                <span class="tok-builtin">@alignCast</span>(<span class="tok-builtin">@alignOf</span>(elf.Elf32_Dyn), &amp;dyn_buf[dyn_buf_i]),</span>
<span class="line" id="L622">                            );</span>
<span class="line" id="L623">                            <span class="tok-kw">const</span> dyn64 = <span class="tok-builtin">@ptrCast</span>(</span>
<span class="line" id="L624">                                *elf.Elf64_Dyn,</span>
<span class="line" id="L625">                                <span class="tok-builtin">@alignCast</span>(<span class="tok-builtin">@alignOf</span>(elf.Elf64_Dyn), &amp;dyn_buf[dyn_buf_i]),</span>
<span class="line" id="L626">                            );</span>
<span class="line" id="L627">                            <span class="tok-kw">const</span> tag = elfInt(is_64, need_bswap, dyn32.d_tag, dyn64.d_tag);</span>
<span class="line" id="L628">                            <span class="tok-kw">const</span> val = elfInt(is_64, need_bswap, dyn32.d_val, dyn64.d_val);</span>
<span class="line" id="L629">                            <span class="tok-kw">if</span> (tag == elf.DT_RUNPATH) {</span>
<span class="line" id="L630">                                rpath_offset = val;</span>
<span class="line" id="L631">                                <span class="tok-kw">break</span> :dyn;</span>
<span class="line" id="L632">                            }</span>
<span class="line" id="L633">                        }</span>
<span class="line" id="L634">                    }</span>
<span class="line" id="L635">                },</span>
<span class="line" id="L636">                <span class="tok-kw">else</span> =&gt; <span class="tok-kw">continue</span>,</span>
<span class="line" id="L637">            }</span>
<span class="line" id="L638">        }</span>
<span class="line" id="L639">    }</span>
<span class="line" id="L640"></span>
<span class="line" id="L641">    <span class="tok-kw">if</span> (builtin.target.os.tag == .linux <span class="tok-kw">and</span> result.target.isGnuLibC() <span class="tok-kw">and</span></span>
<span class="line" id="L642">        cross_target.glibc_version == <span class="tok-null">null</span>)</span>
<span class="line" id="L643">    {</span>
<span class="line" id="L644">        <span class="tok-kw">if</span> (rpath_offset) |rpoff| {</span>
<span class="line" id="L645">            <span class="tok-kw">const</span> shstrndx = elfInt(is_64, need_bswap, hdr32.e_shstrndx, hdr64.e_shstrndx);</span>
<span class="line" id="L646"></span>
<span class="line" id="L647">            <span class="tok-kw">var</span> shoff = elfInt(is_64, need_bswap, hdr32.e_shoff, hdr64.e_shoff);</span>
<span class="line" id="L648">            <span class="tok-kw">const</span> shentsize = elfInt(is_64, need_bswap, hdr32.e_shentsize, hdr64.e_shentsize);</span>
<span class="line" id="L649">            <span class="tok-kw">const</span> str_section_off = shoff + <span class="tok-builtin">@as</span>(<span class="tok-type">u64</span>, shentsize) * <span class="tok-builtin">@as</span>(<span class="tok-type">u64</span>, shstrndx);</span>
<span class="line" id="L650"></span>
<span class="line" id="L651">            <span class="tok-kw">var</span> sh_buf: [<span class="tok-number">16</span> * <span class="tok-builtin">@sizeOf</span>(elf.Elf64_Shdr)]<span class="tok-type">u8</span> <span class="tok-kw">align</span>(<span class="tok-builtin">@alignOf</span>(elf.Elf64_Shdr)) = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L652">            <span class="tok-kw">if</span> (sh_buf.len &lt; shentsize) <span class="tok-kw">return</span> <span class="tok-kw">error</span>.InvalidElfFile;</span>
<span class="line" id="L653"></span>
<span class="line" id="L654">            _ = <span class="tok-kw">try</span> preadMin(file, &amp;sh_buf, str_section_off, shentsize);</span>
<span class="line" id="L655">            <span class="tok-kw">const</span> shstr32 = <span class="tok-builtin">@ptrCast</span>(*elf.Elf32_Shdr, <span class="tok-builtin">@alignCast</span>(<span class="tok-builtin">@alignOf</span>(elf.Elf32_Shdr), &amp;sh_buf));</span>
<span class="line" id="L656">            <span class="tok-kw">const</span> shstr64 = <span class="tok-builtin">@ptrCast</span>(*elf.Elf64_Shdr, <span class="tok-builtin">@alignCast</span>(<span class="tok-builtin">@alignOf</span>(elf.Elf64_Shdr), &amp;sh_buf));</span>
<span class="line" id="L657">            <span class="tok-kw">const</span> shstrtab_off = elfInt(is_64, need_bswap, shstr32.sh_offset, shstr64.sh_offset);</span>
<span class="line" id="L658">            <span class="tok-kw">const</span> shstrtab_size = elfInt(is_64, need_bswap, shstr32.sh_size, shstr64.sh_size);</span>
<span class="line" id="L659">            <span class="tok-kw">var</span> strtab_buf: [<span class="tok-number">4096</span>:<span class="tok-number">0</span>]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L660">            <span class="tok-kw">const</span> shstrtab_len = std.math.min(shstrtab_size, strtab_buf.len);</span>
<span class="line" id="L661">            <span class="tok-kw">const</span> shstrtab_read_len = <span class="tok-kw">try</span> preadMin(file, &amp;strtab_buf, shstrtab_off, shstrtab_len);</span>
<span class="line" id="L662">            <span class="tok-kw">const</span> shstrtab = strtab_buf[<span class="tok-number">0</span>..shstrtab_read_len];</span>
<span class="line" id="L663"></span>
<span class="line" id="L664">            <span class="tok-kw">const</span> shnum = elfInt(is_64, need_bswap, hdr32.e_shnum, hdr64.e_shnum);</span>
<span class="line" id="L665">            <span class="tok-kw">var</span> sh_i: <span class="tok-type">u16</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L666">            <span class="tok-kw">const</span> dynstr: ?<span class="tok-kw">struct</span> { offset: <span class="tok-type">u64</span>, size: <span class="tok-type">u64</span> } = find_dyn_str: <span class="tok-kw">while</span> (sh_i &lt; shnum) {</span>
<span class="line" id="L667">                <span class="tok-comment">// Reserve some bytes so that we can deref the 64-bit struct fields</span>
</span>
<span class="line" id="L668">                <span class="tok-comment">// even when the ELF file is 32-bits.</span>
</span>
<span class="line" id="L669">                <span class="tok-kw">const</span> sh_reserve: <span class="tok-type">usize</span> = <span class="tok-builtin">@sizeOf</span>(elf.Elf64_Shdr) - <span class="tok-builtin">@sizeOf</span>(elf.Elf32_Shdr);</span>
<span class="line" id="L670">                <span class="tok-kw">const</span> sh_read_byte_len = <span class="tok-kw">try</span> preadMin(</span>
<span class="line" id="L671">                    file,</span>
<span class="line" id="L672">                    sh_buf[<span class="tok-number">0</span> .. sh_buf.len - sh_reserve],</span>
<span class="line" id="L673">                    shoff,</span>
<span class="line" id="L674">                    shentsize,</span>
<span class="line" id="L675">                );</span>
<span class="line" id="L676">                <span class="tok-kw">var</span> sh_buf_i: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L677">                <span class="tok-kw">while</span> (sh_buf_i &lt; sh_read_byte_len <span class="tok-kw">and</span> sh_i &lt; shnum) : ({</span>
<span class="line" id="L678">                    sh_i += <span class="tok-number">1</span>;</span>
<span class="line" id="L679">                    shoff += shentsize;</span>
<span class="line" id="L680">                    sh_buf_i += shentsize;</span>
<span class="line" id="L681">                }) {</span>
<span class="line" id="L682">                    <span class="tok-kw">const</span> sh32 = <span class="tok-builtin">@ptrCast</span>(</span>
<span class="line" id="L683">                        *elf.Elf32_Shdr,</span>
<span class="line" id="L684">                        <span class="tok-builtin">@alignCast</span>(<span class="tok-builtin">@alignOf</span>(elf.Elf32_Shdr), &amp;sh_buf[sh_buf_i]),</span>
<span class="line" id="L685">                    );</span>
<span class="line" id="L686">                    <span class="tok-kw">const</span> sh64 = <span class="tok-builtin">@ptrCast</span>(</span>
<span class="line" id="L687">                        *elf.Elf64_Shdr,</span>
<span class="line" id="L688">                        <span class="tok-builtin">@alignCast</span>(<span class="tok-builtin">@alignOf</span>(elf.Elf64_Shdr), &amp;sh_buf[sh_buf_i]),</span>
<span class="line" id="L689">                    );</span>
<span class="line" id="L690">                    <span class="tok-kw">const</span> sh_name_off = elfInt(is_64, need_bswap, sh32.sh_name, sh64.sh_name);</span>
<span class="line" id="L691">                    <span class="tok-comment">// TODO this pointer cast should not be necessary</span>
</span>
<span class="line" id="L692">                    <span class="tok-kw">const</span> sh_name = mem.sliceTo(std.meta.assumeSentinel(shstrtab[sh_name_off..].ptr, <span class="tok-number">0</span>), <span class="tok-number">0</span>);</span>
<span class="line" id="L693">                    <span class="tok-kw">if</span> (mem.eql(<span class="tok-type">u8</span>, sh_name, <span class="tok-str">&quot;.dynstr&quot;</span>)) {</span>
<span class="line" id="L694">                        <span class="tok-kw">break</span> :find_dyn_str .{</span>
<span class="line" id="L695">                            .offset = elfInt(is_64, need_bswap, sh32.sh_offset, sh64.sh_offset),</span>
<span class="line" id="L696">                            .size = elfInt(is_64, need_bswap, sh32.sh_size, sh64.sh_size),</span>
<span class="line" id="L697">                        };</span>
<span class="line" id="L698">                    }</span>
<span class="line" id="L699">                }</span>
<span class="line" id="L700">            } <span class="tok-kw">else</span> <span class="tok-null">null</span>;</span>
<span class="line" id="L701"></span>
<span class="line" id="L702">            <span class="tok-kw">if</span> (dynstr) |ds| {</span>
<span class="line" id="L703">                <span class="tok-comment">// TODO this pointer cast should not be necessary</span>
</span>
<span class="line" id="L704">                <span class="tok-kw">const</span> rpoff_usize = std.math.cast(<span class="tok-type">usize</span>, rpoff) <span class="tok-kw">orelse</span> <span class="tok-kw">return</span> <span class="tok-kw">error</span>.InvalidElfFile;</span>
<span class="line" id="L705">                <span class="tok-kw">if</span> (rpoff_usize &gt; ds.size) <span class="tok-kw">return</span> <span class="tok-kw">error</span>.InvalidElfFile;</span>
<span class="line" id="L706">                <span class="tok-kw">const</span> rpoff_file = ds.offset + rpoff_usize;</span>
<span class="line" id="L707">                <span class="tok-kw">const</span> rp_max_size = ds.size - rpoff_usize;</span>
<span class="line" id="L708"></span>
<span class="line" id="L709">                <span class="tok-kw">const</span> strtab_len = std.math.min(rp_max_size, strtab_buf.len);</span>
<span class="line" id="L710">                <span class="tok-kw">const</span> strtab_read_len = <span class="tok-kw">try</span> preadMin(file, &amp;strtab_buf, rpoff_file, strtab_len);</span>
<span class="line" id="L711">                <span class="tok-kw">const</span> strtab = strtab_buf[<span class="tok-number">0</span>..strtab_read_len];</span>
<span class="line" id="L712"></span>
<span class="line" id="L713">                <span class="tok-kw">const</span> rpath_list = mem.sliceTo(std.meta.assumeSentinel(strtab.ptr, <span class="tok-number">0</span>), <span class="tok-number">0</span>);</span>
<span class="line" id="L714">                <span class="tok-kw">var</span> it = mem.tokenize(<span class="tok-type">u8</span>, rpath_list, <span class="tok-str">&quot;:&quot;</span>);</span>
<span class="line" id="L715">                <span class="tok-kw">while</span> (it.next()) |rpath| {</span>
<span class="line" id="L716">                    <span class="tok-kw">var</span> dir = fs.cwd().openDir(rpath, .{}) <span class="tok-kw">catch</span> |err| <span class="tok-kw">switch</span> (err) {</span>
<span class="line" id="L717">                        <span class="tok-kw">error</span>.NameTooLong =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L718">                        <span class="tok-kw">error</span>.InvalidUtf8 =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L719">                        <span class="tok-kw">error</span>.BadPathName =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L720">                        <span class="tok-kw">error</span>.DeviceBusy =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L721"></span>
<span class="line" id="L722">                        <span class="tok-kw">error</span>.FileNotFound,</span>
<span class="line" id="L723">                        <span class="tok-kw">error</span>.NotDir,</span>
<span class="line" id="L724">                        <span class="tok-kw">error</span>.InvalidHandle,</span>
<span class="line" id="L725">                        <span class="tok-kw">error</span>.AccessDenied,</span>
<span class="line" id="L726">                        <span class="tok-kw">error</span>.NoDevice,</span>
<span class="line" id="L727">                        =&gt; <span class="tok-kw">continue</span>,</span>
<span class="line" id="L728"></span>
<span class="line" id="L729">                        <span class="tok-kw">error</span>.ProcessFdQuotaExceeded,</span>
<span class="line" id="L730">                        <span class="tok-kw">error</span>.SystemFdQuotaExceeded,</span>
<span class="line" id="L731">                        <span class="tok-kw">error</span>.SystemResources,</span>
<span class="line" id="L732">                        <span class="tok-kw">error</span>.SymLinkLoop,</span>
<span class="line" id="L733">                        <span class="tok-kw">error</span>.Unexpected,</span>
<span class="line" id="L734">                        =&gt; |e| <span class="tok-kw">return</span> e,</span>
<span class="line" id="L735">                    };</span>
<span class="line" id="L736">                    <span class="tok-kw">defer</span> dir.close();</span>
<span class="line" id="L737"></span>
<span class="line" id="L738">                    <span class="tok-kw">var</span> link_buf: [std.os.PATH_MAX]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L739">                    <span class="tok-kw">const</span> link_name = std.os.readlinkatZ(</span>
<span class="line" id="L740">                        dir.fd,</span>
<span class="line" id="L741">                        glibc_so_basename,</span>
<span class="line" id="L742">                        &amp;link_buf,</span>
<span class="line" id="L743">                    ) <span class="tok-kw">catch</span> |err| <span class="tok-kw">switch</span> (err) {</span>
<span class="line" id="L744">                        <span class="tok-kw">error</span>.NameTooLong =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L745">                        <span class="tok-kw">error</span>.InvalidUtf8 =&gt; <span class="tok-kw">unreachable</span>, <span class="tok-comment">// Windows only</span>
</span>
<span class="line" id="L746">                        <span class="tok-kw">error</span>.BadPathName =&gt; <span class="tok-kw">unreachable</span>, <span class="tok-comment">// Windows only</span>
</span>
<span class="line" id="L747">                        <span class="tok-kw">error</span>.UnsupportedReparsePointType =&gt; <span class="tok-kw">unreachable</span>, <span class="tok-comment">// Windows only</span>
</span>
<span class="line" id="L748"></span>
<span class="line" id="L749">                        <span class="tok-kw">error</span>.AccessDenied,</span>
<span class="line" id="L750">                        <span class="tok-kw">error</span>.FileNotFound,</span>
<span class="line" id="L751">                        <span class="tok-kw">error</span>.NotLink,</span>
<span class="line" id="L752">                        <span class="tok-kw">error</span>.NotDir,</span>
<span class="line" id="L753">                        =&gt; <span class="tok-kw">continue</span>,</span>
<span class="line" id="L754"></span>
<span class="line" id="L755">                        <span class="tok-kw">error</span>.SystemResources,</span>
<span class="line" id="L756">                        <span class="tok-kw">error</span>.FileSystem,</span>
<span class="line" id="L757">                        <span class="tok-kw">error</span>.SymLinkLoop,</span>
<span class="line" id="L758">                        <span class="tok-kw">error</span>.Unexpected,</span>
<span class="line" id="L759">                        =&gt; |e| <span class="tok-kw">return</span> e,</span>
<span class="line" id="L760">                    };</span>
<span class="line" id="L761">                    result.target.os.version_range.linux.glibc = glibcVerFromLinkName(</span>
<span class="line" id="L762">                        link_name,</span>
<span class="line" id="L763">                        <span class="tok-str">&quot;libc-&quot;</span>,</span>
<span class="line" id="L764">                    ) <span class="tok-kw">catch</span> |err| <span class="tok-kw">switch</span> (err) {</span>
<span class="line" id="L765">                        <span class="tok-kw">error</span>.UnrecognizedGnuLibCFileName,</span>
<span class="line" id="L766">                        <span class="tok-kw">error</span>.InvalidGnuLibCVersion,</span>
<span class="line" id="L767">                        =&gt; <span class="tok-kw">continue</span>,</span>
<span class="line" id="L768">                    };</span>
<span class="line" id="L769">                    <span class="tok-kw">break</span>;</span>
<span class="line" id="L770">                }</span>
<span class="line" id="L771">            }</span>
<span class="line" id="L772">        } <span class="tok-kw">else</span> <span class="tok-kw">if</span> (result.dynamic_linker.get()) |dl_path| glibc_ver: {</span>
<span class="line" id="L773">            <span class="tok-comment">// There is no DT_RUNPATH but we can try to see if the information is</span>
</span>
<span class="line" id="L774">            <span class="tok-comment">// present in the symlink data for the dynamic linker path.</span>
</span>
<span class="line" id="L775">            <span class="tok-kw">var</span> link_buf: [std.os.PATH_MAX]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L776">            <span class="tok-kw">const</span> link_name = std.os.readlink(dl_path, &amp;link_buf) <span class="tok-kw">catch</span> |err| <span class="tok-kw">switch</span> (err) {</span>
<span class="line" id="L777">                <span class="tok-kw">error</span>.NameTooLong =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L778">                <span class="tok-kw">error</span>.InvalidUtf8 =&gt; <span class="tok-kw">unreachable</span>, <span class="tok-comment">// Windows only</span>
</span>
<span class="line" id="L779">                <span class="tok-kw">error</span>.BadPathName =&gt; <span class="tok-kw">unreachable</span>, <span class="tok-comment">// Windows only</span>
</span>
<span class="line" id="L780">                <span class="tok-kw">error</span>.UnsupportedReparsePointType =&gt; <span class="tok-kw">unreachable</span>, <span class="tok-comment">// Windows only</span>
</span>
<span class="line" id="L781"></span>
<span class="line" id="L782">                <span class="tok-kw">error</span>.AccessDenied,</span>
<span class="line" id="L783">                <span class="tok-kw">error</span>.FileNotFound,</span>
<span class="line" id="L784">                <span class="tok-kw">error</span>.NotLink,</span>
<span class="line" id="L785">                <span class="tok-kw">error</span>.NotDir,</span>
<span class="line" id="L786">                =&gt; <span class="tok-kw">break</span> :glibc_ver,</span>
<span class="line" id="L787"></span>
<span class="line" id="L788">                <span class="tok-kw">error</span>.SystemResources,</span>
<span class="line" id="L789">                <span class="tok-kw">error</span>.FileSystem,</span>
<span class="line" id="L790">                <span class="tok-kw">error</span>.SymLinkLoop,</span>
<span class="line" id="L791">                <span class="tok-kw">error</span>.Unexpected,</span>
<span class="line" id="L792">                =&gt; |e| <span class="tok-kw">return</span> e,</span>
<span class="line" id="L793">            };</span>
<span class="line" id="L794">            result.target.os.version_range.linux.glibc = glibcVerFromLinkName(</span>
<span class="line" id="L795">                fs.path.basename(link_name),</span>
<span class="line" id="L796">                <span class="tok-str">&quot;ld-&quot;</span>,</span>
<span class="line" id="L797">            ) <span class="tok-kw">catch</span> |err| <span class="tok-kw">switch</span> (err) {</span>
<span class="line" id="L798">                <span class="tok-kw">error</span>.UnrecognizedGnuLibCFileName,</span>
<span class="line" id="L799">                <span class="tok-kw">error</span>.InvalidGnuLibCVersion,</span>
<span class="line" id="L800">                =&gt; <span class="tok-kw">break</span> :glibc_ver,</span>
<span class="line" id="L801">            };</span>
<span class="line" id="L802">        }</span>
<span class="line" id="L803">    }</span>
<span class="line" id="L804"></span>
<span class="line" id="L805">    <span class="tok-kw">return</span> result;</span>
<span class="line" id="L806">}</span>
<span class="line" id="L807"></span>
<span class="line" id="L808"><span class="tok-kw">fn</span> <span class="tok-fn">preadMin</span>(file: fs.File, buf: []<span class="tok-type">u8</span>, offset: <span class="tok-type">u64</span>, min_read_len: <span class="tok-type">usize</span>) !<span class="tok-type">usize</span> {</span>
<span class="line" id="L809">    <span class="tok-kw">var</span> i: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L810">    <span class="tok-kw">while</span> (i &lt; min_read_len) {</span>
<span class="line" id="L811">        <span class="tok-kw">const</span> len = file.pread(buf[i..], offset + i) <span class="tok-kw">catch</span> |err| <span class="tok-kw">switch</span> (err) {</span>
<span class="line" id="L812">            <span class="tok-kw">error</span>.OperationAborted =&gt; <span class="tok-kw">unreachable</span>, <span class="tok-comment">// Windows-only</span>
</span>
<span class="line" id="L813">            <span class="tok-kw">error</span>.WouldBlock =&gt; <span class="tok-kw">unreachable</span>, <span class="tok-comment">// Did not request blocking mode</span>
</span>
<span class="line" id="L814">            <span class="tok-kw">error</span>.NotOpenForReading =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L815">            <span class="tok-kw">error</span>.SystemResources =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.SystemResources,</span>
<span class="line" id="L816">            <span class="tok-kw">error</span>.IsDir =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.UnableToReadElfFile,</span>
<span class="line" id="L817">            <span class="tok-kw">error</span>.BrokenPipe =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.UnableToReadElfFile,</span>
<span class="line" id="L818">            <span class="tok-kw">error</span>.Unseekable =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.UnableToReadElfFile,</span>
<span class="line" id="L819">            <span class="tok-kw">error</span>.ConnectionResetByPeer =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.UnableToReadElfFile,</span>
<span class="line" id="L820">            <span class="tok-kw">error</span>.ConnectionTimedOut =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.UnableToReadElfFile,</span>
<span class="line" id="L821">            <span class="tok-kw">error</span>.Unexpected =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.Unexpected,</span>
<span class="line" id="L822">            <span class="tok-kw">error</span>.InputOutput =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.FileSystem,</span>
<span class="line" id="L823">            <span class="tok-kw">error</span>.AccessDenied =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.Unexpected,</span>
<span class="line" id="L824">        };</span>
<span class="line" id="L825">        <span class="tok-kw">if</span> (len == <span class="tok-number">0</span>) <span class="tok-kw">return</span> <span class="tok-kw">error</span>.UnexpectedEndOfFile;</span>
<span class="line" id="L826">        i += len;</span>
<span class="line" id="L827">    }</span>
<span class="line" id="L828">    <span class="tok-kw">return</span> i;</span>
<span class="line" id="L829">}</span>
<span class="line" id="L830"></span>
<span class="line" id="L831"><span class="tok-kw">fn</span> <span class="tok-fn">defaultAbiAndDynamicLinker</span>(cpu: Target.Cpu, os: Target.Os, cross_target: CrossTarget) !NativeTargetInfo {</span>
<span class="line" id="L832">    <span class="tok-kw">const</span> target: Target = .{</span>
<span class="line" id="L833">        .cpu = cpu,</span>
<span class="line" id="L834">        .os = os,</span>
<span class="line" id="L835">        .abi = cross_target.abi <span class="tok-kw">orelse</span> Target.Abi.default(cpu.arch, os),</span>
<span class="line" id="L836">        .ofmt = cross_target.ofmt <span class="tok-kw">orelse</span> Target.ObjectFormat.default(os.tag, cpu.arch),</span>
<span class="line" id="L837">    };</span>
<span class="line" id="L838">    <span class="tok-kw">return</span> NativeTargetInfo{</span>
<span class="line" id="L839">        .target = target,</span>
<span class="line" id="L840">        .dynamic_linker = <span class="tok-kw">if</span> (cross_target.dynamic_linker.get() == <span class="tok-null">null</span>)</span>
<span class="line" id="L841">            target.standardDynamicLinkerPath()</span>
<span class="line" id="L842">        <span class="tok-kw">else</span></span>
<span class="line" id="L843">            cross_target.dynamic_linker,</span>
<span class="line" id="L844">    };</span>
<span class="line" id="L845">}</span>
<span class="line" id="L846"></span>
<span class="line" id="L847"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> LdInfo = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L848">    ld: DynamicLinker,</span>
<span class="line" id="L849">    abi: Target.Abi,</span>
<span class="line" id="L850">};</span>
<span class="line" id="L851"></span>
<span class="line" id="L852"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">elfInt</span>(is_64: <span class="tok-type">bool</span>, need_bswap: <span class="tok-type">bool</span>, int_32: <span class="tok-kw">anytype</span>, int_64: <span class="tok-kw">anytype</span>) <span class="tok-builtin">@TypeOf</span>(int_64) {</span>
<span class="line" id="L853">    <span class="tok-kw">if</span> (is_64) {</span>
<span class="line" id="L854">        <span class="tok-kw">if</span> (need_bswap) {</span>
<span class="line" id="L855">            <span class="tok-kw">return</span> <span class="tok-builtin">@byteSwap</span>(<span class="tok-builtin">@TypeOf</span>(int_64), int_64);</span>
<span class="line" id="L856">        } <span class="tok-kw">else</span> {</span>
<span class="line" id="L857">            <span class="tok-kw">return</span> int_64;</span>
<span class="line" id="L858">        }</span>
<span class="line" id="L859">    } <span class="tok-kw">else</span> {</span>
<span class="line" id="L860">        <span class="tok-kw">if</span> (need_bswap) {</span>
<span class="line" id="L861">            <span class="tok-kw">return</span> <span class="tok-builtin">@byteSwap</span>(<span class="tok-builtin">@TypeOf</span>(int_32), int_32);</span>
<span class="line" id="L862">        } <span class="tok-kw">else</span> {</span>
<span class="line" id="L863">            <span class="tok-kw">return</span> int_32;</span>
<span class="line" id="L864">        }</span>
<span class="line" id="L865">    }</span>
<span class="line" id="L866">}</span>
<span class="line" id="L867"></span>
<span class="line" id="L868"><span class="tok-kw">fn</span> <span class="tok-fn">detectNativeCpuAndFeatures</span>(cpu_arch: Target.Cpu.Arch, os: Target.Os, cross_target: CrossTarget) ?Target.Cpu {</span>
<span class="line" id="L869">    <span class="tok-comment">// Here we switch on a comptime value rather than `cpu_arch`. This is valid because `cpu_arch`,</span>
</span>
<span class="line" id="L870">    <span class="tok-comment">// although it is a runtime value, is guaranteed to be one of the architectures in the set</span>
</span>
<span class="line" id="L871">    <span class="tok-comment">// of the respective switch prong.</span>
</span>
<span class="line" id="L872">    <span class="tok-kw">switch</span> (builtin.cpu.arch) {</span>
<span class="line" id="L873">        .x86_64, .<span class="tok-type">i386</span> =&gt; {</span>
<span class="line" id="L874">            <span class="tok-kw">return</span> <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;x86.zig&quot;</span>).detectNativeCpuAndFeatures(cpu_arch, os, cross_target);</span>
<span class="line" id="L875">        },</span>
<span class="line" id="L876">        <span class="tok-kw">else</span> =&gt; {},</span>
<span class="line" id="L877">    }</span>
<span class="line" id="L878"></span>
<span class="line" id="L879">    <span class="tok-kw">switch</span> (builtin.os.tag) {</span>
<span class="line" id="L880">        .linux =&gt; <span class="tok-kw">return</span> linux.detectNativeCpuAndFeatures(),</span>
<span class="line" id="L881">        .macos =&gt; <span class="tok-kw">return</span> darwin.macos.detectNativeCpuAndFeatures(),</span>
<span class="line" id="L882">        <span class="tok-kw">else</span> =&gt; {},</span>
<span class="line" id="L883">    }</span>
<span class="line" id="L884"></span>
<span class="line" id="L885">    <span class="tok-comment">// This architecture does not have CPU model &amp; feature detection yet.</span>
</span>
<span class="line" id="L886">    <span class="tok-comment">// See https://github.com/ziglang/zig/issues/4591</span>
</span>
<span class="line" id="L887">    <span class="tok-kw">return</span> <span class="tok-null">null</span>;</span>
<span class="line" id="L888">}</span>
<span class="line" id="L889"></span>
<span class="line" id="L890"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> Executor = <span class="tok-kw">union</span>(<span class="tok-kw">enum</span>) {</span>
<span class="line" id="L891">    native,</span>
<span class="line" id="L892">    rosetta,</span>
<span class="line" id="L893">    qemu: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>,</span>
<span class="line" id="L894">    wine: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>,</span>
<span class="line" id="L895">    wasmtime: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>,</span>
<span class="line" id="L896">    darling: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>,</span>
<span class="line" id="L897">    bad_dl: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>,</span>
<span class="line" id="L898">    bad_os_or_cpu,</span>
<span class="line" id="L899">};</span>
<span class="line" id="L900"></span>
<span class="line" id="L901"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> GetExternalExecutorOptions = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L902">    allow_darling: <span class="tok-type">bool</span> = <span class="tok-null">true</span>,</span>
<span class="line" id="L903">    allow_qemu: <span class="tok-type">bool</span> = <span class="tok-null">true</span>,</span>
<span class="line" id="L904">    allow_rosetta: <span class="tok-type">bool</span> = <span class="tok-null">true</span>,</span>
<span class="line" id="L905">    allow_wasmtime: <span class="tok-type">bool</span> = <span class="tok-null">true</span>,</span>
<span class="line" id="L906">    allow_wine: <span class="tok-type">bool</span> = <span class="tok-null">true</span>,</span>
<span class="line" id="L907">    qemu_fixes_dl: <span class="tok-type">bool</span> = <span class="tok-null">false</span>,</span>
<span class="line" id="L908">    link_libc: <span class="tok-type">bool</span> = <span class="tok-null">false</span>,</span>
<span class="line" id="L909">};</span>
<span class="line" id="L910"></span>
<span class="line" id="L911"><span class="tok-comment">/// Return whether or not the given host target is capable of executing natively executables</span></span>
<span class="line" id="L912"><span class="tok-comment">/// of the other target.</span></span>
<span class="line" id="L913"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">getExternalExecutor</span>(</span>
<span class="line" id="L914">    host: NativeTargetInfo,</span>
<span class="line" id="L915">    candidate: NativeTargetInfo,</span>
<span class="line" id="L916">    options: GetExternalExecutorOptions,</span>
<span class="line" id="L917">) Executor {</span>
<span class="line" id="L918">    <span class="tok-kw">const</span> os_match = host.target.os.tag == candidate.target.os.tag;</span>
<span class="line" id="L919">    <span class="tok-kw">const</span> cpu_ok = cpu_ok: {</span>
<span class="line" id="L920">        <span class="tok-kw">if</span> (host.target.cpu.arch == candidate.target.cpu.arch)</span>
<span class="line" id="L921">            <span class="tok-kw">break</span> :cpu_ok <span class="tok-null">true</span>;</span>
<span class="line" id="L922"></span>
<span class="line" id="L923">        <span class="tok-kw">if</span> (host.target.cpu.arch == .x86_64 <span class="tok-kw">and</span> candidate.target.cpu.arch == .<span class="tok-type">i386</span>)</span>
<span class="line" id="L924">            <span class="tok-kw">break</span> :cpu_ok <span class="tok-null">true</span>;</span>
<span class="line" id="L925"></span>
<span class="line" id="L926">        <span class="tok-kw">if</span> (host.target.cpu.arch == .aarch64 <span class="tok-kw">and</span> candidate.target.cpu.arch == .arm)</span>
<span class="line" id="L927">            <span class="tok-kw">break</span> :cpu_ok <span class="tok-null">true</span>;</span>
<span class="line" id="L928"></span>
<span class="line" id="L929">        <span class="tok-kw">if</span> (host.target.cpu.arch == .aarch64_be <span class="tok-kw">and</span> candidate.target.cpu.arch == .armeb)</span>
<span class="line" id="L930">            <span class="tok-kw">break</span> :cpu_ok <span class="tok-null">true</span>;</span>
<span class="line" id="L931"></span>
<span class="line" id="L932">        <span class="tok-comment">// TODO additionally detect incompatible CPU features.</span>
</span>
<span class="line" id="L933">        <span class="tok-comment">// Note that in some cases the OS kernel will emulate missing CPU features</span>
</span>
<span class="line" id="L934">        <span class="tok-comment">// when an illegal instruction is encountered.</span>
</span>
<span class="line" id="L935"></span>
<span class="line" id="L936">        <span class="tok-kw">break</span> :cpu_ok <span class="tok-null">false</span>;</span>
<span class="line" id="L937">    };</span>
<span class="line" id="L938"></span>
<span class="line" id="L939">    <span class="tok-kw">var</span> bad_result: Executor = .bad_os_or_cpu;</span>
<span class="line" id="L940"></span>
<span class="line" id="L941">    <span class="tok-kw">if</span> (os_match <span class="tok-kw">and</span> cpu_ok) native: {</span>
<span class="line" id="L942">        <span class="tok-kw">if</span> (options.link_libc) {</span>
<span class="line" id="L943">            <span class="tok-kw">if</span> (candidate.dynamic_linker.get()) |candidate_dl| {</span>
<span class="line" id="L944">                fs.cwd().access(candidate_dl, .{}) <span class="tok-kw">catch</span> {</span>
<span class="line" id="L945">                    bad_result = .{ .bad_dl = candidate_dl };</span>
<span class="line" id="L946">                    <span class="tok-kw">break</span> :native;</span>
<span class="line" id="L947">                };</span>
<span class="line" id="L948">            }</span>
<span class="line" id="L949">        }</span>
<span class="line" id="L950">        <span class="tok-kw">return</span> .native;</span>
<span class="line" id="L951">    }</span>
<span class="line" id="L952"></span>
<span class="line" id="L953">    <span class="tok-comment">// If the OS match and OS is macOS and CPU is arm64, we can use Rosetta 2</span>
</span>
<span class="line" id="L954">    <span class="tok-comment">// to emulate the foreign architecture.</span>
</span>
<span class="line" id="L955">    <span class="tok-kw">if</span> (options.allow_rosetta <span class="tok-kw">and</span> os_match <span class="tok-kw">and</span></span>
<span class="line" id="L956">        host.target.os.tag == .macos <span class="tok-kw">and</span> host.target.cpu.arch == .aarch64)</span>
<span class="line" id="L957">    {</span>
<span class="line" id="L958">        <span class="tok-kw">switch</span> (candidate.target.cpu.arch) {</span>
<span class="line" id="L959">            .x86_64 =&gt; <span class="tok-kw">return</span> .rosetta,</span>
<span class="line" id="L960">            <span class="tok-kw">else</span> =&gt; <span class="tok-kw">return</span> bad_result,</span>
<span class="line" id="L961">        }</span>
<span class="line" id="L962">    }</span>
<span class="line" id="L963"></span>
<span class="line" id="L964">    <span class="tok-comment">// If the OS matches, we can use QEMU to emulate a foreign architecture.</span>
</span>
<span class="line" id="L965">    <span class="tok-kw">if</span> (options.allow_qemu <span class="tok-kw">and</span> os_match <span class="tok-kw">and</span> (!cpu_ok <span class="tok-kw">or</span> options.qemu_fixes_dl)) {</span>
<span class="line" id="L966">        <span class="tok-kw">return</span> <span class="tok-kw">switch</span> (candidate.target.cpu.arch) {</span>
<span class="line" id="L967">            .aarch64 =&gt; Executor{ .qemu = <span class="tok-str">&quot;qemu-aarch64&quot;</span> },</span>
<span class="line" id="L968">            .aarch64_be =&gt; Executor{ .qemu = <span class="tok-str">&quot;qemu-aarch64_be&quot;</span> },</span>
<span class="line" id="L969">            .arm =&gt; Executor{ .qemu = <span class="tok-str">&quot;qemu-arm&quot;</span> },</span>
<span class="line" id="L970">            .armeb =&gt; Executor{ .qemu = <span class="tok-str">&quot;qemu-armeb&quot;</span> },</span>
<span class="line" id="L971">            .hexagon =&gt; Executor{ .qemu = <span class="tok-str">&quot;qemu-hexagon&quot;</span> },</span>
<span class="line" id="L972">            .<span class="tok-type">i386</span> =&gt; Executor{ .qemu = <span class="tok-str">&quot;qemu-i386&quot;</span> },</span>
<span class="line" id="L973">            .m68k =&gt; Executor{ .qemu = <span class="tok-str">&quot;qemu-m68k&quot;</span> },</span>
<span class="line" id="L974">            .mips =&gt; Executor{ .qemu = <span class="tok-str">&quot;qemu-mips&quot;</span> },</span>
<span class="line" id="L975">            .mipsel =&gt; Executor{ .qemu = <span class="tok-str">&quot;qemu-mipsel&quot;</span> },</span>
<span class="line" id="L976">            .mips64 =&gt; Executor{ .qemu = <span class="tok-str">&quot;qemu-mips64&quot;</span> },</span>
<span class="line" id="L977">            .mips64el =&gt; Executor{ .qemu = <span class="tok-str">&quot;qemu-mips64el&quot;</span> },</span>
<span class="line" id="L978">            .powerpc =&gt; Executor{ .qemu = <span class="tok-str">&quot;qemu-ppc&quot;</span> },</span>
<span class="line" id="L979">            .powerpc64 =&gt; Executor{ .qemu = <span class="tok-str">&quot;qemu-ppc64&quot;</span> },</span>
<span class="line" id="L980">            .powerpc64le =&gt; Executor{ .qemu = <span class="tok-str">&quot;qemu-ppc64le&quot;</span> },</span>
<span class="line" id="L981">            .riscv32 =&gt; Executor{ .qemu = <span class="tok-str">&quot;qemu-riscv32&quot;</span> },</span>
<span class="line" id="L982">            .riscv64 =&gt; Executor{ .qemu = <span class="tok-str">&quot;qemu-riscv64&quot;</span> },</span>
<span class="line" id="L983">            .s390x =&gt; Executor{ .qemu = <span class="tok-str">&quot;qemu-s390x&quot;</span> },</span>
<span class="line" id="L984">            .sparc =&gt; Executor{ .qemu = <span class="tok-str">&quot;qemu-sparc&quot;</span> },</span>
<span class="line" id="L985">            .sparc64 =&gt; Executor{ .qemu = <span class="tok-str">&quot;qemu-sparc64&quot;</span> },</span>
<span class="line" id="L986">            .x86_64 =&gt; Executor{ .qemu = <span class="tok-str">&quot;qemu-x86_64&quot;</span> },</span>
<span class="line" id="L987">            <span class="tok-kw">else</span> =&gt; <span class="tok-kw">return</span> bad_result,</span>
<span class="line" id="L988">        };</span>
<span class="line" id="L989">    }</span>
<span class="line" id="L990"></span>
<span class="line" id="L991">    <span class="tok-kw">switch</span> (candidate.target.os.tag) {</span>
<span class="line" id="L992">        .windows =&gt; {</span>
<span class="line" id="L993">            <span class="tok-kw">if</span> (options.allow_wine) {</span>
<span class="line" id="L994">                <span class="tok-kw">switch</span> (candidate.target.cpu.arch.ptrBitWidth()) {</span>
<span class="line" id="L995">                    <span class="tok-number">32</span> =&gt; <span class="tok-kw">return</span> Executor{ .wine = <span class="tok-str">&quot;wine&quot;</span> },</span>
<span class="line" id="L996">                    <span class="tok-number">64</span> =&gt; <span class="tok-kw">return</span> Executor{ .wine = <span class="tok-str">&quot;wine64&quot;</span> },</span>
<span class="line" id="L997">                    <span class="tok-kw">else</span> =&gt; <span class="tok-kw">return</span> bad_result,</span>
<span class="line" id="L998">                }</span>
<span class="line" id="L999">            }</span>
<span class="line" id="L1000">            <span class="tok-kw">return</span> bad_result;</span>
<span class="line" id="L1001">        },</span>
<span class="line" id="L1002">        .wasi =&gt; {</span>
<span class="line" id="L1003">            <span class="tok-kw">if</span> (options.allow_wasmtime) {</span>
<span class="line" id="L1004">                <span class="tok-kw">switch</span> (candidate.target.cpu.arch.ptrBitWidth()) {</span>
<span class="line" id="L1005">                    <span class="tok-number">32</span> =&gt; <span class="tok-kw">return</span> Executor{ .wasmtime = <span class="tok-str">&quot;wasmtime&quot;</span> },</span>
<span class="line" id="L1006">                    <span class="tok-kw">else</span> =&gt; <span class="tok-kw">return</span> bad_result,</span>
<span class="line" id="L1007">                }</span>
<span class="line" id="L1008">            }</span>
<span class="line" id="L1009">            <span class="tok-kw">return</span> bad_result;</span>
<span class="line" id="L1010">        },</span>
<span class="line" id="L1011">        .macos =&gt; {</span>
<span class="line" id="L1012">            <span class="tok-kw">if</span> (options.allow_darling) {</span>
<span class="line" id="L1013">                <span class="tok-comment">// This check can be loosened once darling adds a QEMU-based emulation</span>
</span>
<span class="line" id="L1014">                <span class="tok-comment">// layer for non-host architectures:</span>
</span>
<span class="line" id="L1015">                <span class="tok-comment">// https://github.com/darlinghq/darling/issues/863</span>
</span>
<span class="line" id="L1016">                <span class="tok-kw">if</span> (candidate.target.cpu.arch != builtin.cpu.arch) {</span>
<span class="line" id="L1017">                    <span class="tok-kw">return</span> bad_result;</span>
<span class="line" id="L1018">                }</span>
<span class="line" id="L1019">                <span class="tok-kw">return</span> Executor{ .darling = <span class="tok-str">&quot;darling&quot;</span> };</span>
<span class="line" id="L1020">            }</span>
<span class="line" id="L1021">            <span class="tok-kw">return</span> bad_result;</span>
<span class="line" id="L1022">        },</span>
<span class="line" id="L1023">        <span class="tok-kw">else</span> =&gt; <span class="tok-kw">return</span> bad_result,</span>
<span class="line" id="L1024">    }</span>
<span class="line" id="L1025">}</span>
<span class="line" id="L1026"></span>
</code></pre></body>
</html>