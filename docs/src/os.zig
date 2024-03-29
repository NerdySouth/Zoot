<!doctype html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">    <title>os.zig - source view</title>
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
<pre><code><span class="line" id="L1"><span class="tok-comment">//! This file contains thin wrappers around OS-specific APIs, with these</span></span>
<span class="line" id="L2"><span class="tok-comment">//! specific goals in mind:</span></span>
<span class="line" id="L3"><span class="tok-comment">//! * Convert &quot;errno&quot;-style error codes into Zig errors.</span></span>
<span class="line" id="L4"><span class="tok-comment">//! * When null-terminated byte buffers are required, provide APIs which accept</span></span>
<span class="line" id="L5"><span class="tok-comment">//!   slices as well as APIs which accept null-terminated byte buffers. Same goes</span></span>
<span class="line" id="L6"><span class="tok-comment">//!   for UTF-16LE encoding.</span></span>
<span class="line" id="L7"><span class="tok-comment">//! * Where operating systems share APIs, e.g. POSIX, these thin wrappers provide</span></span>
<span class="line" id="L8"><span class="tok-comment">//!   cross platform abstracting.</span></span>
<span class="line" id="L9"><span class="tok-comment">//! * When there exists a corresponding libc function and linking libc, the libc</span></span>
<span class="line" id="L10"><span class="tok-comment">//!   implementation is used. Exceptions are made for known buggy areas of libc.</span></span>
<span class="line" id="L11"><span class="tok-comment">//!   On Linux libc can be side-stepped by using `std.os.linux` directly.</span></span>
<span class="line" id="L12"><span class="tok-comment">//! * For Windows, this file represents the API that libc would provide for</span></span>
<span class="line" id="L13"><span class="tok-comment">//!   Windows. For thin wrappers around Windows-specific APIs, see `std.os.windows`.</span></span>
<span class="line" id="L14"><span class="tok-comment">//! Note: The Zig standard library does not support POSIX thread cancellation, and</span></span>
<span class="line" id="L15"><span class="tok-comment">//! in general EINTR is handled by trying again.</span></span>
<span class="line" id="L16"></span>
<span class="line" id="L17"><span class="tok-kw">const</span> root = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;root&quot;</span>);</span>
<span class="line" id="L18"><span class="tok-kw">const</span> std = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;std.zig&quot;</span>);</span>
<span class="line" id="L19"><span class="tok-kw">const</span> builtin = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;builtin&quot;</span>);</span>
<span class="line" id="L20"><span class="tok-kw">const</span> assert = std.debug.assert;</span>
<span class="line" id="L21"><span class="tok-kw">const</span> math = std.math;</span>
<span class="line" id="L22"><span class="tok-kw">const</span> mem = std.mem;</span>
<span class="line" id="L23"><span class="tok-kw">const</span> elf = std.elf;</span>
<span class="line" id="L24"><span class="tok-kw">const</span> fs = std.fs;</span>
<span class="line" id="L25"><span class="tok-kw">const</span> dl = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;dynamic_library.zig&quot;</span>);</span>
<span class="line" id="L26"><span class="tok-kw">const</span> MAX_PATH_BYTES = std.fs.MAX_PATH_BYTES;</span>
<span class="line" id="L27"><span class="tok-kw">const</span> is_windows = builtin.os.tag == .windows;</span>
<span class="line" id="L28"><span class="tok-kw">const</span> Allocator = std.mem.Allocator;</span>
<span class="line" id="L29"><span class="tok-kw">const</span> Preopen = std.fs.wasi.Preopen;</span>
<span class="line" id="L30"><span class="tok-kw">const</span> PreopenList = std.fs.wasi.PreopenList;</span>
<span class="line" id="L31"></span>
<span class="line" id="L32"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> darwin = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;os/darwin.zig&quot;</span>);</span>
<span class="line" id="L33"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> dragonfly = std.c;</span>
<span class="line" id="L34"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> freebsd = std.c;</span>
<span class="line" id="L35"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> haiku = std.c;</span>
<span class="line" id="L36"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> netbsd = std.c;</span>
<span class="line" id="L37"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> openbsd = std.c;</span>
<span class="line" id="L38"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> solaris = std.c;</span>
<span class="line" id="L39"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> linux = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;os/linux.zig&quot;</span>);</span>
<span class="line" id="L40"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> plan9 = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;os/plan9.zig&quot;</span>);</span>
<span class="line" id="L41"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> uefi = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;os/uefi.zig&quot;</span>);</span>
<span class="line" id="L42"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> wasi = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;os/wasi.zig&quot;</span>);</span>
<span class="line" id="L43"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> windows = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;os/windows.zig&quot;</span>);</span>
<span class="line" id="L44"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> posix_spawn = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;os/posix_spawn.zig&quot;</span>);</span>
<span class="line" id="L45"></span>
<span class="line" id="L46"><span class="tok-kw">comptime</span> {</span>
<span class="line" id="L47">    assert(<span class="tok-builtin">@import</span>(<span class="tok-str">&quot;std&quot;</span>) == std); <span class="tok-comment">// std lib tests require --zig-lib-dir</span>
</span>
<span class="line" id="L48">}</span>
<span class="line" id="L49"></span>
<span class="line" id="L50"><span class="tok-kw">test</span> {</span>
<span class="line" id="L51">    _ = darwin;</span>
<span class="line" id="L52">    _ = linux;</span>
<span class="line" id="L53">    _ = uefi;</span>
<span class="line" id="L54">    _ = wasi;</span>
<span class="line" id="L55">    _ = windows;</span>
<span class="line" id="L56">    _ = posix_spawn;</span>
<span class="line" id="L57"></span>
<span class="line" id="L58">    _ = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;os/test.zig&quot;</span>);</span>
<span class="line" id="L59">}</span>
<span class="line" id="L60"></span>
<span class="line" id="L61"><span class="tok-comment">/// Applications can override the `system` API layer in their root source file.</span></span>
<span class="line" id="L62"><span class="tok-comment">/// Otherwise, when linking libc, this is the C API.</span></span>
<span class="line" id="L63"><span class="tok-comment">/// When not linking libc, it is the OS-specific system interface.</span></span>
<span class="line" id="L64"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> system = <span class="tok-kw">if</span> (<span class="tok-builtin">@hasDecl</span>(root, <span class="tok-str">&quot;os&quot;</span>) <span class="tok-kw">and</span> root.os != <span class="tok-builtin">@This</span>())</span>
<span class="line" id="L65">    root.os.system</span>
<span class="line" id="L66"><span class="tok-kw">else</span> <span class="tok-kw">if</span> (builtin.link_libc <span class="tok-kw">or</span> is_windows)</span>
<span class="line" id="L67">    std.c</span>
<span class="line" id="L68"><span class="tok-kw">else</span> <span class="tok-kw">switch</span> (builtin.os.tag) {</span>
<span class="line" id="L69">    .linux =&gt; linux,</span>
<span class="line" id="L70">    .wasi =&gt; wasi,</span>
<span class="line" id="L71">    .uefi =&gt; uefi,</span>
<span class="line" id="L72">    <span class="tok-kw">else</span> =&gt; <span class="tok-kw">struct</span> {},</span>
<span class="line" id="L73">};</span>
<span class="line" id="L74"></span>
<span class="line" id="L75"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> AF = system.AF;</span>
<span class="line" id="L76"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> AF_SUN = system.AF_SUN;</span>
<span class="line" id="L77"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> ARCH = system.ARCH;</span>
<span class="line" id="L78"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> AT = system.AT;</span>
<span class="line" id="L79"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> AT_SUN = system.AT_SUN;</span>
<span class="line" id="L80"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> CLOCK = system.CLOCK;</span>
<span class="line" id="L81"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> CPU_COUNT = system.CPU_COUNT;</span>
<span class="line" id="L82"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> CTL = system.CTL;</span>
<span class="line" id="L83"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> DT = system.DT;</span>
<span class="line" id="L84"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> E = system.E;</span>
<span class="line" id="L85"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> Elf_Symndx = system.Elf_Symndx;</span>
<span class="line" id="L86"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> F = system.F;</span>
<span class="line" id="L87"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> FD_CLOEXEC = system.FD_CLOEXEC;</span>
<span class="line" id="L88"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> Flock = system.Flock;</span>
<span class="line" id="L89"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> HOST_NAME_MAX = system.HOST_NAME_MAX;</span>
<span class="line" id="L90"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> IFNAMESIZE = system.IFNAMESIZE;</span>
<span class="line" id="L91"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> IOV_MAX = system.IOV_MAX;</span>
<span class="line" id="L92"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> IPPROTO = system.IPPROTO;</span>
<span class="line" id="L93"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> KERN = system.KERN;</span>
<span class="line" id="L94"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> Kevent = system.Kevent;</span>
<span class="line" id="L95"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> LOCK = system.LOCK;</span>
<span class="line" id="L96"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> MADV = system.MADV;</span>
<span class="line" id="L97"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> MAP = system.MAP;</span>
<span class="line" id="L98"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> MSF = system.MSF;</span>
<span class="line" id="L99"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> MAX_ADDR_LEN = system.MAX_ADDR_LEN;</span>
<span class="line" id="L100"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> MFD = system.MFD;</span>
<span class="line" id="L101"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> MMAP2_UNIT = system.MMAP2_UNIT;</span>
<span class="line" id="L102"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> MSG = system.MSG;</span>
<span class="line" id="L103"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> NAME_MAX = system.NAME_MAX;</span>
<span class="line" id="L104"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> O = <span class="tok-kw">switch</span> (builtin.os.tag) {</span>
<span class="line" id="L105">    <span class="tok-comment">// We want to expose the POSIX-like OFLAGS, so we use std.c.wasi.O instead</span>
</span>
<span class="line" id="L106">    <span class="tok-comment">// of std.os.wasi.O, which is for non-POSIX-like `wasi.path_open`, etc.</span>
</span>
<span class="line" id="L107">    .wasi =&gt; std.c.O,</span>
<span class="line" id="L108">    <span class="tok-kw">else</span> =&gt; system.O,</span>
<span class="line" id="L109">};</span>
<span class="line" id="L110"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> PATH_MAX = system.PATH_MAX;</span>
<span class="line" id="L111"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> POLL = system.POLL;</span>
<span class="line" id="L112"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> POSIX_FADV = system.POSIX_FADV;</span>
<span class="line" id="L113"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> PR = system.PR;</span>
<span class="line" id="L114"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> PROT = system.PROT;</span>
<span class="line" id="L115"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> REG = system.REG;</span>
<span class="line" id="L116"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> RIGHT = system.RIGHT;</span>
<span class="line" id="L117"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> RLIM = system.RLIM;</span>
<span class="line" id="L118"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> RR = system.RR;</span>
<span class="line" id="L119"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> S = system.S;</span>
<span class="line" id="L120"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> SA = system.SA;</span>
<span class="line" id="L121"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> SC = system.SC;</span>
<span class="line" id="L122"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> _SC = system._SC;</span>
<span class="line" id="L123"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> SEEK = system.SEEK;</span>
<span class="line" id="L124"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> SHUT = system.SHUT;</span>
<span class="line" id="L125"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> SIG = system.SIG;</span>
<span class="line" id="L126"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> SIOCGIFINDEX = system.SIOCGIFINDEX;</span>
<span class="line" id="L127"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> SO = system.SO;</span>
<span class="line" id="L128"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> SOCK = system.SOCK;</span>
<span class="line" id="L129"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> SOL = system.SOL;</span>
<span class="line" id="L130"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> STDERR_FILENO = system.STDERR_FILENO;</span>
<span class="line" id="L131"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> STDIN_FILENO = system.STDIN_FILENO;</span>
<span class="line" id="L132"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> STDOUT_FILENO = system.STDOUT_FILENO;</span>
<span class="line" id="L133"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> SYS = system.SYS;</span>
<span class="line" id="L134"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> Sigaction = system.Sigaction;</span>
<span class="line" id="L135"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> Stat = system.Stat;</span>
<span class="line" id="L136"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> TCSA = system.TCSA;</span>
<span class="line" id="L137"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> TCP = system.TCP;</span>
<span class="line" id="L138"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> VDSO = system.VDSO;</span>
<span class="line" id="L139"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> W = system.W;</span>
<span class="line" id="L140"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> addrinfo = system.addrinfo;</span>
<span class="line" id="L141"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> blkcnt_t = system.blkcnt_t;</span>
<span class="line" id="L142"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> blksize_t = system.blksize_t;</span>
<span class="line" id="L143"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> clock_t = system.clock_t;</span>
<span class="line" id="L144"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> cpu_set_t = system.cpu_set_t;</span>
<span class="line" id="L145"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> dev_t = system.dev_t;</span>
<span class="line" id="L146"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> dl_phdr_info = system.dl_phdr_info;</span>
<span class="line" id="L147"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> empty_sigset = system.empty_sigset;</span>
<span class="line" id="L148"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> fd_t = system.fd_t;</span>
<span class="line" id="L149"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> fdflags_t = system.fdflags_t;</span>
<span class="line" id="L150"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> fdstat_t = system.fdstat_t;</span>
<span class="line" id="L151"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> gid_t = system.gid_t;</span>
<span class="line" id="L152"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> ifreq = system.ifreq;</span>
<span class="line" id="L153"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> ino_t = system.ino_t;</span>
<span class="line" id="L154"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> lookupflags_t = system.lookupflags_t;</span>
<span class="line" id="L155"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> mcontext_t = system.mcontext_t;</span>
<span class="line" id="L156"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> mode_t = system.mode_t;</span>
<span class="line" id="L157"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> msghdr = system.msghdr;</span>
<span class="line" id="L158"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> msghdr_const = system.msghdr_const;</span>
<span class="line" id="L159"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> nfds_t = system.nfds_t;</span>
<span class="line" id="L160"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> nlink_t = system.nlink_t;</span>
<span class="line" id="L161"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> off_t = system.off_t;</span>
<span class="line" id="L162"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> oflags_t = system.oflags_t;</span>
<span class="line" id="L163"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> pid_t = system.pid_t;</span>
<span class="line" id="L164"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> pollfd = system.pollfd;</span>
<span class="line" id="L165"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> port_t = system.port_t;</span>
<span class="line" id="L166"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> port_event = system.port_event;</span>
<span class="line" id="L167"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> port_notify = system.port_notify;</span>
<span class="line" id="L168"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> file_obj = system.file_obj;</span>
<span class="line" id="L169"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> rights_t = system.rights_t;</span>
<span class="line" id="L170"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> rlim_t = system.rlim_t;</span>
<span class="line" id="L171"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> rlimit = system.rlimit;</span>
<span class="line" id="L172"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> rlimit_resource = system.rlimit_resource;</span>
<span class="line" id="L173"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> rusage = system.rusage;</span>
<span class="line" id="L174"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> sa_family_t = system.sa_family_t;</span>
<span class="line" id="L175"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> siginfo_t = system.siginfo_t;</span>
<span class="line" id="L176"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> sigset_t = system.sigset_t;</span>
<span class="line" id="L177"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> sockaddr = system.sockaddr;</span>
<span class="line" id="L178"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> socklen_t = system.socklen_t;</span>
<span class="line" id="L179"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> stack_t = system.stack_t;</span>
<span class="line" id="L180"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> tcflag_t = system.tcflag_t;</span>
<span class="line" id="L181"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> termios = system.termios;</span>
<span class="line" id="L182"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> time_t = system.time_t;</span>
<span class="line" id="L183"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> timespec = system.timespec;</span>
<span class="line" id="L184"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> timestamp_t = system.timestamp_t;</span>
<span class="line" id="L185"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> timeval = system.timeval;</span>
<span class="line" id="L186"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> timezone = system.timezone;</span>
<span class="line" id="L187"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> ucontext_t = system.ucontext_t;</span>
<span class="line" id="L188"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> uid_t = system.uid_t;</span>
<span class="line" id="L189"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> user_desc = system.user_desc;</span>
<span class="line" id="L190"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> utsname = system.utsname;</span>
<span class="line" id="L191"></span>
<span class="line" id="L192"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> F_OK = system.F_OK;</span>
<span class="line" id="L193"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> R_OK = system.R_OK;</span>
<span class="line" id="L194"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> W_OK = system.W_OK;</span>
<span class="line" id="L195"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> X_OK = system.X_OK;</span>
<span class="line" id="L196"></span>
<span class="line" id="L197"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> iovec = <span class="tok-kw">extern</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L198">    iov_base: [*]<span class="tok-type">u8</span>,</span>
<span class="line" id="L199">    iov_len: <span class="tok-type">usize</span>,</span>
<span class="line" id="L200">};</span>
<span class="line" id="L201"></span>
<span class="line" id="L202"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> iovec_const = <span class="tok-kw">extern</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L203">    iov_base: [*]<span class="tok-kw">const</span> <span class="tok-type">u8</span>,</span>
<span class="line" id="L204">    iov_len: <span class="tok-type">usize</span>,</span>
<span class="line" id="L205">};</span>
<span class="line" id="L206"></span>
<span class="line" id="L207"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> LOG = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L208">    <span class="tok-comment">/// system is unusable</span></span>
<span class="line" id="L209">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> EMERG = <span class="tok-number">0</span>;</span>
<span class="line" id="L210">    <span class="tok-comment">/// action must be taken immediately</span></span>
<span class="line" id="L211">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> ALERT = <span class="tok-number">1</span>;</span>
<span class="line" id="L212">    <span class="tok-comment">/// critical conditions</span></span>
<span class="line" id="L213">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> CRIT = <span class="tok-number">2</span>;</span>
<span class="line" id="L214">    <span class="tok-comment">/// error conditions</span></span>
<span class="line" id="L215">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> ERR = <span class="tok-number">3</span>;</span>
<span class="line" id="L216">    <span class="tok-comment">/// warning conditions</span></span>
<span class="line" id="L217">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> WARNING = <span class="tok-number">4</span>;</span>
<span class="line" id="L218">    <span class="tok-comment">/// normal but significant condition</span></span>
<span class="line" id="L219">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> NOTICE = <span class="tok-number">5</span>;</span>
<span class="line" id="L220">    <span class="tok-comment">/// informational</span></span>
<span class="line" id="L221">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> INFO = <span class="tok-number">6</span>;</span>
<span class="line" id="L222">    <span class="tok-comment">/// debug-level messages</span></span>
<span class="line" id="L223">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> DEBUG = <span class="tok-number">7</span>;</span>
<span class="line" id="L224">};</span>
<span class="line" id="L225"></span>
<span class="line" id="L226"><span class="tok-comment">/// An fd-relative file path</span></span>
<span class="line" id="L227"><span class="tok-comment">///</span></span>
<span class="line" id="L228"><span class="tok-comment">/// This is currently only used for WASI-specific functionality, but the concept</span></span>
<span class="line" id="L229"><span class="tok-comment">/// is the same as the dirfd/pathname pairs in the `*at(...)` POSIX functions.</span></span>
<span class="line" id="L230"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> RelativePathWasi = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L231">    <span class="tok-comment">/// Handle to directory</span></span>
<span class="line" id="L232">    dir_fd: fd_t,</span>
<span class="line" id="L233">    <span class="tok-comment">/// Path to resource within `dir_fd`.</span></span>
<span class="line" id="L234">    relative_path: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>,</span>
<span class="line" id="L235">};</span>
<span class="line" id="L236"></span>
<span class="line" id="L237"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> socket_t = <span class="tok-kw">if</span> (builtin.os.tag == .windows) windows.ws2_32.SOCKET <span class="tok-kw">else</span> fd_t;</span>
<span class="line" id="L238"></span>
<span class="line" id="L239"><span class="tok-comment">/// See also `getenv`. Populated by startup code before main().</span></span>
<span class="line" id="L240"><span class="tok-comment">/// TODO this is a footgun because the value will be undefined when using `zig build-lib`.</span></span>
<span class="line" id="L241"><span class="tok-comment">/// https://github.com/ziglang/zig/issues/4524</span></span>
<span class="line" id="L242"><span class="tok-kw">pub</span> <span class="tok-kw">var</span> environ: [][*:<span class="tok-number">0</span>]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L243"></span>
<span class="line" id="L244"><span class="tok-comment">/// Populated by startup code before main().</span></span>
<span class="line" id="L245"><span class="tok-comment">/// Not available on WASI or Windows without libc. See `std.process.argsAlloc`</span></span>
<span class="line" id="L246"><span class="tok-comment">/// or `std.process.argsWithAllocator` for a cross-platform alternative.</span></span>
<span class="line" id="L247"><span class="tok-kw">pub</span> <span class="tok-kw">var</span> argv: [][*:<span class="tok-number">0</span>]<span class="tok-type">u8</span> = <span class="tok-kw">if</span> (builtin.link_libc) <span class="tok-null">undefined</span> <span class="tok-kw">else</span> <span class="tok-kw">switch</span> (builtin.os.tag) {</span>
<span class="line" id="L248">    .windows =&gt; <span class="tok-builtin">@compileError</span>(<span class="tok-str">&quot;argv isn't supported on Windows: use std.process.argsAlloc instead&quot;</span>),</span>
<span class="line" id="L249">    .wasi =&gt; <span class="tok-builtin">@compileError</span>(<span class="tok-str">&quot;argv isn't supported on WASI: use std.process.argsAlloc instead&quot;</span>),</span>
<span class="line" id="L250">    <span class="tok-kw">else</span> =&gt; <span class="tok-null">undefined</span>,</span>
<span class="line" id="L251">};</span>
<span class="line" id="L252"></span>
<span class="line" id="L253"><span class="tok-comment">/// To obtain errno, call this function with the return value of the</span></span>
<span class="line" id="L254"><span class="tok-comment">/// system function call. For some systems this will obtain the value directly</span></span>
<span class="line" id="L255"><span class="tok-comment">/// from the return code; for others it will use a thread-local errno variable.</span></span>
<span class="line" id="L256"><span class="tok-comment">/// Therefore, this function only returns a well-defined value when it is called</span></span>
<span class="line" id="L257"><span class="tok-comment">/// directly after the system function call which one wants to learn the errno</span></span>
<span class="line" id="L258"><span class="tok-comment">/// value of.</span></span>
<span class="line" id="L259"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> errno = system.getErrno;</span>
<span class="line" id="L260"></span>
<span class="line" id="L261"><span class="tok-comment">/// Closes the file descriptor.</span></span>
<span class="line" id="L262"><span class="tok-comment">/// This function is not capable of returning any indication of failure. An</span></span>
<span class="line" id="L263"><span class="tok-comment">/// application which wants to ensure writes have succeeded before closing</span></span>
<span class="line" id="L264"><span class="tok-comment">/// must call `fsync` before `close`.</span></span>
<span class="line" id="L265"><span class="tok-comment">/// Note: The Zig standard library does not support POSIX thread cancellation.</span></span>
<span class="line" id="L266"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">close</span>(fd: fd_t) <span class="tok-type">void</span> {</span>
<span class="line" id="L267">    <span class="tok-kw">if</span> (builtin.os.tag == .windows) {</span>
<span class="line" id="L268">        <span class="tok-kw">return</span> windows.CloseHandle(fd);</span>
<span class="line" id="L269">    }</span>
<span class="line" id="L270">    <span class="tok-kw">if</span> (builtin.os.tag == .wasi <span class="tok-kw">and</span> !builtin.link_libc) {</span>
<span class="line" id="L271">        _ = wasi.fd_close(fd);</span>
<span class="line" id="L272">        <span class="tok-kw">return</span>;</span>
<span class="line" id="L273">    }</span>
<span class="line" id="L274">    <span class="tok-kw">if</span> (<span class="tok-kw">comptime</span> builtin.target.isDarwin()) {</span>
<span class="line" id="L275">        <span class="tok-comment">// This avoids the EINTR problem.</span>
</span>
<span class="line" id="L276">        <span class="tok-kw">switch</span> (darwin.getErrno(darwin.@&quot;close$NOCANCEL&quot;(fd))) {</span>
<span class="line" id="L277">            .BADF =&gt; <span class="tok-kw">unreachable</span>, <span class="tok-comment">// Always a race condition.</span>
</span>
<span class="line" id="L278">            <span class="tok-kw">else</span> =&gt; <span class="tok-kw">return</span>,</span>
<span class="line" id="L279">        }</span>
<span class="line" id="L280">    }</span>
<span class="line" id="L281">    <span class="tok-kw">switch</span> (errno(system.close(fd))) {</span>
<span class="line" id="L282">        .BADF =&gt; <span class="tok-kw">unreachable</span>, <span class="tok-comment">// Always a race condition.</span>
</span>
<span class="line" id="L283">        .INTR =&gt; <span class="tok-kw">return</span>, <span class="tok-comment">// This is still a success. See https://github.com/ziglang/zig/issues/2425</span>
</span>
<span class="line" id="L284">        <span class="tok-kw">else</span> =&gt; <span class="tok-kw">return</span>,</span>
<span class="line" id="L285">    }</span>
<span class="line" id="L286">}</span>
<span class="line" id="L287"></span>
<span class="line" id="L288"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> FChmodError = <span class="tok-kw">error</span>{</span>
<span class="line" id="L289">    AccessDenied,</span>
<span class="line" id="L290">    InputOutput,</span>
<span class="line" id="L291">    SymLinkLoop,</span>
<span class="line" id="L292">    FileNotFound,</span>
<span class="line" id="L293">    SystemResources,</span>
<span class="line" id="L294">    ReadOnlyFileSystem,</span>
<span class="line" id="L295">} || UnexpectedError;</span>
<span class="line" id="L296"></span>
<span class="line" id="L297"><span class="tok-comment">/// Changes the mode of the file referred to by the file descriptor.</span></span>
<span class="line" id="L298"><span class="tok-comment">/// The process must have the correct privileges in order to do this</span></span>
<span class="line" id="L299"><span class="tok-comment">/// successfully, or must have the effective user ID matching the owner</span></span>
<span class="line" id="L300"><span class="tok-comment">/// of the file.</span></span>
<span class="line" id="L301"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">fchmod</span>(fd: fd_t, mode: mode_t) FChmodError!<span class="tok-type">void</span> {</span>
<span class="line" id="L302">    <span class="tok-kw">if</span> (builtin.os.tag == .windows <span class="tok-kw">or</span> builtin.os.tag == .wasi)</span>
<span class="line" id="L303">        <span class="tok-builtin">@compileError</span>(<span class="tok-str">&quot;Unsupported OS&quot;</span>);</span>
<span class="line" id="L304"></span>
<span class="line" id="L305">    <span class="tok-kw">while</span> (<span class="tok-null">true</span>) {</span>
<span class="line" id="L306">        <span class="tok-kw">const</span> res = system.fchmod(fd, mode);</span>
<span class="line" id="L307"></span>
<span class="line" id="L308">        <span class="tok-kw">switch</span> (system.getErrno(res)) {</span>
<span class="line" id="L309">            .SUCCESS =&gt; <span class="tok-kw">return</span>,</span>
<span class="line" id="L310">            .INTR =&gt; <span class="tok-kw">continue</span>,</span>
<span class="line" id="L311">            .BADF =&gt; <span class="tok-kw">unreachable</span>, <span class="tok-comment">// Can be reached if the fd refers to a non-iterable directory.</span>
</span>
<span class="line" id="L312"></span>
<span class="line" id="L313">            .FAULT =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L314">            .INVAL =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L315">            .ACCES =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.AccessDenied,</span>
<span class="line" id="L316">            .IO =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.InputOutput,</span>
<span class="line" id="L317">            .LOOP =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.SymLinkLoop,</span>
<span class="line" id="L318">            .NOENT =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.FileNotFound,</span>
<span class="line" id="L319">            .NOMEM =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.SystemResources,</span>
<span class="line" id="L320">            .NOTDIR =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.FileNotFound,</span>
<span class="line" id="L321">            .PERM =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.AccessDenied,</span>
<span class="line" id="L322">            .ROFS =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.ReadOnlyFileSystem,</span>
<span class="line" id="L323">            <span class="tok-kw">else</span> =&gt; |err| <span class="tok-kw">return</span> unexpectedErrno(err),</span>
<span class="line" id="L324">        }</span>
<span class="line" id="L325">    }</span>
<span class="line" id="L326">}</span>
<span class="line" id="L327"></span>
<span class="line" id="L328"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> FChownError = <span class="tok-kw">error</span>{</span>
<span class="line" id="L329">    AccessDenied,</span>
<span class="line" id="L330">    InputOutput,</span>
<span class="line" id="L331">    SymLinkLoop,</span>
<span class="line" id="L332">    FileNotFound,</span>
<span class="line" id="L333">    SystemResources,</span>
<span class="line" id="L334">    ReadOnlyFileSystem,</span>
<span class="line" id="L335">} || UnexpectedError;</span>
<span class="line" id="L336"></span>
<span class="line" id="L337"><span class="tok-comment">/// Changes the owner and group of the file referred to by the file descriptor.</span></span>
<span class="line" id="L338"><span class="tok-comment">/// The process must have the correct privileges in order to do this</span></span>
<span class="line" id="L339"><span class="tok-comment">/// successfully. The group may be changed by the owner of the directory to</span></span>
<span class="line" id="L340"><span class="tok-comment">/// any group of which the owner is a member. If the owner or group is</span></span>
<span class="line" id="L341"><span class="tok-comment">/// specified as `null`, the ID is not changed.</span></span>
<span class="line" id="L342"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">fchown</span>(fd: fd_t, owner: ?uid_t, group: ?gid_t) FChownError!<span class="tok-type">void</span> {</span>
<span class="line" id="L343">    <span class="tok-kw">if</span> (builtin.os.tag == .windows <span class="tok-kw">or</span> builtin.os.tag == .wasi)</span>
<span class="line" id="L344">        <span class="tok-builtin">@compileError</span>(<span class="tok-str">&quot;Unsupported OS&quot;</span>);</span>
<span class="line" id="L345"></span>
<span class="line" id="L346">    <span class="tok-kw">while</span> (<span class="tok-null">true</span>) {</span>
<span class="line" id="L347">        <span class="tok-kw">const</span> res = system.fchown(fd, owner <span class="tok-kw">orelse</span> <span class="tok-builtin">@as</span>(<span class="tok-type">u32</span>, <span class="tok-number">0</span>) -% <span class="tok-number">1</span>, group <span class="tok-kw">orelse</span> <span class="tok-builtin">@as</span>(<span class="tok-type">u32</span>, <span class="tok-number">0</span>) -% <span class="tok-number">1</span>);</span>
<span class="line" id="L348"></span>
<span class="line" id="L349">        <span class="tok-kw">switch</span> (system.getErrno(res)) {</span>
<span class="line" id="L350">            .SUCCESS =&gt; <span class="tok-kw">return</span>,</span>
<span class="line" id="L351">            .INTR =&gt; <span class="tok-kw">continue</span>,</span>
<span class="line" id="L352">            .BADF =&gt; <span class="tok-kw">unreachable</span>, <span class="tok-comment">// Can be reached if the fd refers to a non-iterable directory.</span>
</span>
<span class="line" id="L353"></span>
<span class="line" id="L354">            .FAULT =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L355">            .INVAL =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L356">            .ACCES =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.AccessDenied,</span>
<span class="line" id="L357">            .IO =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.InputOutput,</span>
<span class="line" id="L358">            .LOOP =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.SymLinkLoop,</span>
<span class="line" id="L359">            .NOENT =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.FileNotFound,</span>
<span class="line" id="L360">            .NOMEM =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.SystemResources,</span>
<span class="line" id="L361">            .NOTDIR =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.FileNotFound,</span>
<span class="line" id="L362">            .PERM =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.AccessDenied,</span>
<span class="line" id="L363">            .ROFS =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.ReadOnlyFileSystem,</span>
<span class="line" id="L364">            <span class="tok-kw">else</span> =&gt; |err| <span class="tok-kw">return</span> unexpectedErrno(err),</span>
<span class="line" id="L365">        }</span>
<span class="line" id="L366">    }</span>
<span class="line" id="L367">}</span>
<span class="line" id="L368"></span>
<span class="line" id="L369"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> GetRandomError = OpenError;</span>
<span class="line" id="L370"></span>
<span class="line" id="L371"><span class="tok-comment">/// Obtain a series of random bytes. These bytes can be used to seed user-space</span></span>
<span class="line" id="L372"><span class="tok-comment">/// random number generators or for cryptographic purposes.</span></span>
<span class="line" id="L373"><span class="tok-comment">/// When linking against libc, this calls the</span></span>
<span class="line" id="L374"><span class="tok-comment">/// appropriate OS-specific library call. Otherwise it uses the zig standard</span></span>
<span class="line" id="L375"><span class="tok-comment">/// library implementation.</span></span>
<span class="line" id="L376"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">getrandom</span>(buffer: []<span class="tok-type">u8</span>) GetRandomError!<span class="tok-type">void</span> {</span>
<span class="line" id="L377">    <span class="tok-kw">if</span> (builtin.os.tag == .windows) {</span>
<span class="line" id="L378">        <span class="tok-kw">return</span> windows.RtlGenRandom(buffer);</span>
<span class="line" id="L379">    }</span>
<span class="line" id="L380">    <span class="tok-kw">if</span> (builtin.os.tag == .linux <span class="tok-kw">or</span> builtin.os.tag == .freebsd) {</span>
<span class="line" id="L381">        <span class="tok-kw">var</span> buf = buffer;</span>
<span class="line" id="L382">        <span class="tok-kw">const</span> use_c = builtin.os.tag != .linux <span class="tok-kw">or</span></span>
<span class="line" id="L383">            std.c.versionCheck(std.builtin.Version{ .major = <span class="tok-number">2</span>, .minor = <span class="tok-number">25</span>, .patch = <span class="tok-number">0</span> }).ok;</span>
<span class="line" id="L384"></span>
<span class="line" id="L385">        <span class="tok-kw">while</span> (buf.len != <span class="tok-number">0</span>) {</span>
<span class="line" id="L386">            <span class="tok-kw">const</span> res = <span class="tok-kw">if</span> (use_c) blk: {</span>
<span class="line" id="L387">                <span class="tok-kw">const</span> rc = std.c.getrandom(buf.ptr, buf.len, <span class="tok-number">0</span>);</span>
<span class="line" id="L388">                <span class="tok-kw">break</span> :blk .{</span>
<span class="line" id="L389">                    .num_read = <span class="tok-builtin">@bitCast</span>(<span class="tok-type">usize</span>, rc),</span>
<span class="line" id="L390">                    .err = std.c.getErrno(rc),</span>
<span class="line" id="L391">                };</span>
<span class="line" id="L392">            } <span class="tok-kw">else</span> blk: {</span>
<span class="line" id="L393">                <span class="tok-kw">const</span> rc = linux.getrandom(buf.ptr, buf.len, <span class="tok-number">0</span>);</span>
<span class="line" id="L394">                <span class="tok-kw">break</span> :blk .{</span>
<span class="line" id="L395">                    .num_read = rc,</span>
<span class="line" id="L396">                    .err = linux.getErrno(rc),</span>
<span class="line" id="L397">                };</span>
<span class="line" id="L398">            };</span>
<span class="line" id="L399"></span>
<span class="line" id="L400">            <span class="tok-kw">switch</span> (res.err) {</span>
<span class="line" id="L401">                .SUCCESS =&gt; buf = buf[res.num_read..],</span>
<span class="line" id="L402">                .INVAL =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L403">                .FAULT =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L404">                .INTR =&gt; <span class="tok-kw">continue</span>,</span>
<span class="line" id="L405">                .NOSYS =&gt; <span class="tok-kw">return</span> getRandomBytesDevURandom(buf),</span>
<span class="line" id="L406">                <span class="tok-kw">else</span> =&gt; <span class="tok-kw">return</span> unexpectedErrno(res.err),</span>
<span class="line" id="L407">            }</span>
<span class="line" id="L408">        }</span>
<span class="line" id="L409">        <span class="tok-kw">return</span>;</span>
<span class="line" id="L410">    }</span>
<span class="line" id="L411">    <span class="tok-kw">switch</span> (builtin.os.tag) {</span>
<span class="line" id="L412">        .netbsd, .openbsd, .macos, .ios, .tvos, .watchos =&gt; {</span>
<span class="line" id="L413">            system.arc4random_buf(buffer.ptr, buffer.len);</span>
<span class="line" id="L414">            <span class="tok-kw">return</span>;</span>
<span class="line" id="L415">        },</span>
<span class="line" id="L416">        .wasi =&gt; <span class="tok-kw">switch</span> (wasi.random_get(buffer.ptr, buffer.len)) {</span>
<span class="line" id="L417">            .SUCCESS =&gt; <span class="tok-kw">return</span>,</span>
<span class="line" id="L418">            <span class="tok-kw">else</span> =&gt; |err| <span class="tok-kw">return</span> unexpectedErrno(err),</span>
<span class="line" id="L419">        },</span>
<span class="line" id="L420">        <span class="tok-kw">else</span> =&gt; <span class="tok-kw">return</span> getRandomBytesDevURandom(buffer),</span>
<span class="line" id="L421">    }</span>
<span class="line" id="L422">}</span>
<span class="line" id="L423"></span>
<span class="line" id="L424"><span class="tok-kw">fn</span> <span class="tok-fn">getRandomBytesDevURandom</span>(buf: []<span class="tok-type">u8</span>) !<span class="tok-type">void</span> {</span>
<span class="line" id="L425">    <span class="tok-kw">const</span> fd = <span class="tok-kw">try</span> openZ(<span class="tok-str">&quot;/dev/urandom&quot;</span>, O.RDONLY | O.CLOEXEC, <span class="tok-number">0</span>);</span>
<span class="line" id="L426">    <span class="tok-kw">defer</span> close(fd);</span>
<span class="line" id="L427"></span>
<span class="line" id="L428">    <span class="tok-kw">const</span> st = <span class="tok-kw">try</span> fstat(fd);</span>
<span class="line" id="L429">    <span class="tok-kw">if</span> (!S.ISCHR(st.mode)) {</span>
<span class="line" id="L430">        <span class="tok-kw">return</span> <span class="tok-kw">error</span>.NoDevice;</span>
<span class="line" id="L431">    }</span>
<span class="line" id="L432"></span>
<span class="line" id="L433">    <span class="tok-kw">const</span> file = std.fs.File{</span>
<span class="line" id="L434">        .handle = fd,</span>
<span class="line" id="L435">        .capable_io_mode = .blocking,</span>
<span class="line" id="L436">        .intended_io_mode = .blocking,</span>
<span class="line" id="L437">    };</span>
<span class="line" id="L438">    <span class="tok-kw">const</span> stream = file.reader();</span>
<span class="line" id="L439">    stream.readNoEof(buf) <span class="tok-kw">catch</span> <span class="tok-kw">return</span> <span class="tok-kw">error</span>.Unexpected;</span>
<span class="line" id="L440">}</span>
<span class="line" id="L441"></span>
<span class="line" id="L442"><span class="tok-comment">/// Causes abnormal process termination.</span></span>
<span class="line" id="L443"><span class="tok-comment">/// If linking against libc, this calls the abort() libc function. Otherwise</span></span>
<span class="line" id="L444"><span class="tok-comment">/// it raises SIGABRT followed by SIGKILL and finally lo</span></span>
<span class="line" id="L445"><span class="tok-comment">/// Invokes the current signal handler for SIGABRT, if any.</span></span>
<span class="line" id="L446"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">abort</span>() <span class="tok-type">noreturn</span> {</span>
<span class="line" id="L447">    <span class="tok-builtin">@setCold</span>(<span class="tok-null">true</span>);</span>
<span class="line" id="L448">    <span class="tok-comment">// MSVCRT abort() sometimes opens a popup window which is undesirable, so</span>
</span>
<span class="line" id="L449">    <span class="tok-comment">// even when linking libc on Windows we use our own abort implementation.</span>
</span>
<span class="line" id="L450">    <span class="tok-comment">// See https://github.com/ziglang/zig/issues/2071 for more details.</span>
</span>
<span class="line" id="L451">    <span class="tok-kw">if</span> (builtin.os.tag == .windows) {</span>
<span class="line" id="L452">        <span class="tok-kw">if</span> (builtin.mode == .Debug) {</span>
<span class="line" id="L453">            <span class="tok-builtin">@breakpoint</span>();</span>
<span class="line" id="L454">        }</span>
<span class="line" id="L455">        windows.kernel32.ExitProcess(<span class="tok-number">3</span>);</span>
<span class="line" id="L456">    }</span>
<span class="line" id="L457">    <span class="tok-kw">if</span> (!builtin.link_libc <span class="tok-kw">and</span> builtin.os.tag == .linux) {</span>
<span class="line" id="L458">        <span class="tok-comment">// The Linux man page says that the libc abort() function</span>
</span>
<span class="line" id="L459">        <span class="tok-comment">// &quot;first unblocks the SIGABRT signal&quot;, but this is a footgun</span>
</span>
<span class="line" id="L460">        <span class="tok-comment">// for user-defined signal handlers that want to restore some state in</span>
</span>
<span class="line" id="L461">        <span class="tok-comment">// some program sections and crash in others.</span>
</span>
<span class="line" id="L462">        <span class="tok-comment">// So, the user-installed SIGABRT handler is run, if present.</span>
</span>
<span class="line" id="L463">        raise(SIG.ABRT) <span class="tok-kw">catch</span> {};</span>
<span class="line" id="L464"></span>
<span class="line" id="L465">        <span class="tok-comment">// Disable all signal handlers.</span>
</span>
<span class="line" id="L466">        sigprocmask(SIG.BLOCK, &amp;linux.all_mask, <span class="tok-null">null</span>);</span>
<span class="line" id="L467"></span>
<span class="line" id="L468">        <span class="tok-comment">// Only one thread may proceed to the rest of abort().</span>
</span>
<span class="line" id="L469">        <span class="tok-kw">if</span> (!builtin.single_threaded) {</span>
<span class="line" id="L470">            <span class="tok-kw">const</span> global = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L471">                <span class="tok-kw">var</span> abort_entered: <span class="tok-type">bool</span> = <span class="tok-null">false</span>;</span>
<span class="line" id="L472">            };</span>
<span class="line" id="L473">            <span class="tok-kw">while</span> (<span class="tok-builtin">@cmpxchgWeak</span>(<span class="tok-type">bool</span>, &amp;global.abort_entered, <span class="tok-null">false</span>, <span class="tok-null">true</span>, .SeqCst, .SeqCst)) |_| {}</span>
<span class="line" id="L474">        }</span>
<span class="line" id="L475"></span>
<span class="line" id="L476">        <span class="tok-comment">// Install default handler so that the tkill below will terminate.</span>
</span>
<span class="line" id="L477">        <span class="tok-kw">const</span> sigact = Sigaction{</span>
<span class="line" id="L478">            .handler = .{ .handler = SIG.DFL },</span>
<span class="line" id="L479">            .mask = empty_sigset,</span>
<span class="line" id="L480">            .flags = <span class="tok-number">0</span>,</span>
<span class="line" id="L481">        };</span>
<span class="line" id="L482">        sigaction(SIG.ABRT, &amp;sigact, <span class="tok-null">null</span>) <span class="tok-kw">catch</span> |err| <span class="tok-kw">switch</span> (err) {</span>
<span class="line" id="L483">            <span class="tok-kw">error</span>.OperationNotSupported =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L484">        };</span>
<span class="line" id="L485"></span>
<span class="line" id="L486">        _ = linux.tkill(linux.gettid(), SIG.ABRT);</span>
<span class="line" id="L487"></span>
<span class="line" id="L488">        <span class="tok-kw">const</span> sigabrtmask: linux.sigset_t = [_]<span class="tok-type">u32</span>{<span class="tok-number">0</span>} ** <span class="tok-number">31</span> ++ [_]<span class="tok-type">u32</span>{<span class="tok-number">1</span> &lt;&lt; (SIG.ABRT - <span class="tok-number">1</span>)};</span>
<span class="line" id="L489">        sigprocmask(SIG.UNBLOCK, &amp;sigabrtmask, <span class="tok-null">null</span>);</span>
<span class="line" id="L490"></span>
<span class="line" id="L491">        <span class="tok-comment">// Beyond this point should be unreachable.</span>
</span>
<span class="line" id="L492">        <span class="tok-builtin">@intToPtr</span>(*<span class="tok-kw">allowzero</span> <span class="tok-kw">volatile</span> <span class="tok-type">u8</span>, <span class="tok-number">0</span>).* = <span class="tok-number">0</span>;</span>
<span class="line" id="L493">        raise(SIG.KILL) <span class="tok-kw">catch</span> {};</span>
<span class="line" id="L494">        exit(<span class="tok-number">127</span>); <span class="tok-comment">// Pid 1 might not be signalled in some containers.</span>
</span>
<span class="line" id="L495">    }</span>
<span class="line" id="L496">    <span class="tok-kw">if</span> (builtin.os.tag == .uefi) {</span>
<span class="line" id="L497">        exit(<span class="tok-number">0</span>); <span class="tok-comment">// TODO choose appropriate exit code</span>
</span>
<span class="line" id="L498">    }</span>
<span class="line" id="L499">    <span class="tok-kw">if</span> (builtin.os.tag == .wasi) {</span>
<span class="line" id="L500">        <span class="tok-builtin">@breakpoint</span>();</span>
<span class="line" id="L501">        exit(<span class="tok-number">1</span>);</span>
<span class="line" id="L502">    }</span>
<span class="line" id="L503"></span>
<span class="line" id="L504">    system.abort();</span>
<span class="line" id="L505">}</span>
<span class="line" id="L506"></span>
<span class="line" id="L507"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> RaiseError = UnexpectedError;</span>
<span class="line" id="L508"></span>
<span class="line" id="L509"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">raise</span>(sig: <span class="tok-type">u8</span>) RaiseError!<span class="tok-type">void</span> {</span>
<span class="line" id="L510">    <span class="tok-kw">if</span> (builtin.link_libc) {</span>
<span class="line" id="L511">        <span class="tok-kw">switch</span> (errno(system.raise(sig))) {</span>
<span class="line" id="L512">            .SUCCESS =&gt; <span class="tok-kw">return</span>,</span>
<span class="line" id="L513">            <span class="tok-kw">else</span> =&gt; |err| <span class="tok-kw">return</span> unexpectedErrno(err),</span>
<span class="line" id="L514">        }</span>
<span class="line" id="L515">    }</span>
<span class="line" id="L516"></span>
<span class="line" id="L517">    <span class="tok-kw">if</span> (builtin.os.tag == .linux) {</span>
<span class="line" id="L518">        <span class="tok-kw">var</span> set: sigset_t = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L519">        <span class="tok-comment">// block application signals</span>
</span>
<span class="line" id="L520">        sigprocmask(SIG.BLOCK, &amp;linux.app_mask, &amp;set);</span>
<span class="line" id="L521"></span>
<span class="line" id="L522">        <span class="tok-kw">const</span> tid = linux.gettid();</span>
<span class="line" id="L523">        <span class="tok-kw">const</span> rc = linux.tkill(tid, sig);</span>
<span class="line" id="L524"></span>
<span class="line" id="L525">        <span class="tok-comment">// restore signal mask</span>
</span>
<span class="line" id="L526">        sigprocmask(SIG.SETMASK, &amp;set, <span class="tok-null">null</span>);</span>
<span class="line" id="L527"></span>
<span class="line" id="L528">        <span class="tok-kw">switch</span> (errno(rc)) {</span>
<span class="line" id="L529">            .SUCCESS =&gt; <span class="tok-kw">return</span>,</span>
<span class="line" id="L530">            <span class="tok-kw">else</span> =&gt; |err| <span class="tok-kw">return</span> unexpectedErrno(err),</span>
<span class="line" id="L531">        }</span>
<span class="line" id="L532">    }</span>
<span class="line" id="L533"></span>
<span class="line" id="L534">    <span class="tok-builtin">@compileError</span>(<span class="tok-str">&quot;std.os.raise unimplemented for this target&quot;</span>);</span>
<span class="line" id="L535">}</span>
<span class="line" id="L536"></span>
<span class="line" id="L537"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> KillError = <span class="tok-kw">error</span>{PermissionDenied} || UnexpectedError;</span>
<span class="line" id="L538"></span>
<span class="line" id="L539"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">kill</span>(pid: pid_t, sig: <span class="tok-type">u8</span>) KillError!<span class="tok-type">void</span> {</span>
<span class="line" id="L540">    <span class="tok-kw">switch</span> (errno(system.kill(pid, sig))) {</span>
<span class="line" id="L541">        .SUCCESS =&gt; <span class="tok-kw">return</span>,</span>
<span class="line" id="L542">        .INVAL =&gt; <span class="tok-kw">unreachable</span>, <span class="tok-comment">// invalid signal</span>
</span>
<span class="line" id="L543">        .PERM =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.PermissionDenied,</span>
<span class="line" id="L544">        .SRCH =&gt; <span class="tok-kw">unreachable</span>, <span class="tok-comment">// always a race condition</span>
</span>
<span class="line" id="L545">        <span class="tok-kw">else</span> =&gt; |err| <span class="tok-kw">return</span> unexpectedErrno(err),</span>
<span class="line" id="L546">    }</span>
<span class="line" id="L547">}</span>
<span class="line" id="L548"></span>
<span class="line" id="L549"><span class="tok-comment">/// Exits the program cleanly with the specified status code.</span></span>
<span class="line" id="L550"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">exit</span>(status: <span class="tok-type">u8</span>) <span class="tok-type">noreturn</span> {</span>
<span class="line" id="L551">    <span class="tok-kw">if</span> (builtin.link_libc) {</span>
<span class="line" id="L552">        system.exit(status);</span>
<span class="line" id="L553">    }</span>
<span class="line" id="L554">    <span class="tok-kw">if</span> (builtin.os.tag == .windows) {</span>
<span class="line" id="L555">        windows.kernel32.ExitProcess(status);</span>
<span class="line" id="L556">    }</span>
<span class="line" id="L557">    <span class="tok-kw">if</span> (builtin.os.tag == .wasi) {</span>
<span class="line" id="L558">        wasi.proc_exit(status);</span>
<span class="line" id="L559">    }</span>
<span class="line" id="L560">    <span class="tok-kw">if</span> (builtin.os.tag == .linux <span class="tok-kw">and</span> !builtin.single_threaded) {</span>
<span class="line" id="L561">        linux.exit_group(status);</span>
<span class="line" id="L562">    }</span>
<span class="line" id="L563">    <span class="tok-kw">if</span> (builtin.os.tag == .uefi) {</span>
<span class="line" id="L564">        <span class="tok-comment">// exit() is only avaliable if exitBootServices() has not been called yet.</span>
</span>
<span class="line" id="L565">        <span class="tok-comment">// This call to exit should not fail, so we don't care about its return value.</span>
</span>
<span class="line" id="L566">        <span class="tok-kw">if</span> (uefi.system_table.boot_services) |bs| {</span>
<span class="line" id="L567">            _ = bs.exit(uefi.handle, <span class="tok-builtin">@intToEnum</span>(uefi.Status, status), <span class="tok-number">0</span>, <span class="tok-null">null</span>);</span>
<span class="line" id="L568">        }</span>
<span class="line" id="L569">        <span class="tok-comment">// If we can't exit, reboot the system instead.</span>
</span>
<span class="line" id="L570">        uefi.system_table.runtime_services.resetSystem(uefi.tables.ResetType.ResetCold, <span class="tok-builtin">@intToEnum</span>(uefi.Status, status), <span class="tok-number">0</span>, <span class="tok-null">null</span>);</span>
<span class="line" id="L571">    }</span>
<span class="line" id="L572">    system.exit(status);</span>
<span class="line" id="L573">}</span>
<span class="line" id="L574"></span>
<span class="line" id="L575"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> ReadError = <span class="tok-kw">error</span>{</span>
<span class="line" id="L576">    InputOutput,</span>
<span class="line" id="L577">    SystemResources,</span>
<span class="line" id="L578">    IsDir,</span>
<span class="line" id="L579">    OperationAborted,</span>
<span class="line" id="L580">    BrokenPipe,</span>
<span class="line" id="L581">    ConnectionResetByPeer,</span>
<span class="line" id="L582">    ConnectionTimedOut,</span>
<span class="line" id="L583">    NotOpenForReading,</span>
<span class="line" id="L584"></span>
<span class="line" id="L585">    <span class="tok-comment">/// This error occurs when no global event loop is configured,</span></span>
<span class="line" id="L586">    <span class="tok-comment">/// and reading from the file descriptor would block.</span></span>
<span class="line" id="L587">    WouldBlock,</span>
<span class="line" id="L588"></span>
<span class="line" id="L589">    <span class="tok-comment">/// In WASI, this error occurs when the file descriptor does</span></span>
<span class="line" id="L590">    <span class="tok-comment">/// not hold the required rights to read from it.</span></span>
<span class="line" id="L591">    AccessDenied,</span>
<span class="line" id="L592">} || UnexpectedError;</span>
<span class="line" id="L593"></span>
<span class="line" id="L594"><span class="tok-comment">/// Returns the number of bytes that were read, which can be less than</span></span>
<span class="line" id="L595"><span class="tok-comment">/// buf.len. If 0 bytes were read, that means EOF.</span></span>
<span class="line" id="L596"><span class="tok-comment">/// If `fd` is opened in non blocking mode, the function will return error.WouldBlock</span></span>
<span class="line" id="L597"><span class="tok-comment">/// when EAGAIN is received.</span></span>
<span class="line" id="L598"><span class="tok-comment">///</span></span>
<span class="line" id="L599"><span class="tok-comment">/// Linux has a limit on how many bytes may be transferred in one `read` call, which is `0x7ffff000`</span></span>
<span class="line" id="L600"><span class="tok-comment">/// on both 64-bit and 32-bit systems. This is due to using a signed C int as the return value, as</span></span>
<span class="line" id="L601"><span class="tok-comment">/// well as stuffing the errno codes into the last `4096` values. This is noted on the `read` man page.</span></span>
<span class="line" id="L602"><span class="tok-comment">/// The limit on Darwin is `0x7fffffff`, trying to read more than that returns EINVAL.</span></span>
<span class="line" id="L603"><span class="tok-comment">/// The corresponding POSIX limit is `math.maxInt(isize)`.</span></span>
<span class="line" id="L604"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">read</span>(fd: fd_t, buf: []<span class="tok-type">u8</span>) ReadError!<span class="tok-type">usize</span> {</span>
<span class="line" id="L605">    <span class="tok-kw">if</span> (builtin.os.tag == .windows) {</span>
<span class="line" id="L606">        <span class="tok-kw">return</span> windows.ReadFile(fd, buf, <span class="tok-null">null</span>, std.io.default_mode);</span>
<span class="line" id="L607">    }</span>
<span class="line" id="L608">    <span class="tok-kw">if</span> (builtin.os.tag == .wasi <span class="tok-kw">and</span> !builtin.link_libc) {</span>
<span class="line" id="L609">        <span class="tok-kw">const</span> iovs = [<span class="tok-number">1</span>]iovec{iovec{</span>
<span class="line" id="L610">            .iov_base = buf.ptr,</span>
<span class="line" id="L611">            .iov_len = buf.len,</span>
<span class="line" id="L612">        }};</span>
<span class="line" id="L613"></span>
<span class="line" id="L614">        <span class="tok-kw">var</span> nread: <span class="tok-type">usize</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L615">        <span class="tok-kw">switch</span> (wasi.fd_read(fd, &amp;iovs, iovs.len, &amp;nread)) {</span>
<span class="line" id="L616">            .SUCCESS =&gt; <span class="tok-kw">return</span> nread,</span>
<span class="line" id="L617">            .INTR =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L618">            .INVAL =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L619">            .FAULT =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L620">            .AGAIN =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L621">            .BADF =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.NotOpenForReading, <span class="tok-comment">// Can be a race condition.</span>
</span>
<span class="line" id="L622">            .IO =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.InputOutput,</span>
<span class="line" id="L623">            .ISDIR =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.IsDir,</span>
<span class="line" id="L624">            .NOBUFS =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.SystemResources,</span>
<span class="line" id="L625">            .NOMEM =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.SystemResources,</span>
<span class="line" id="L626">            .CONNRESET =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.ConnectionResetByPeer,</span>
<span class="line" id="L627">            .TIMEDOUT =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.ConnectionTimedOut,</span>
<span class="line" id="L628">            .NOTCAPABLE =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.AccessDenied,</span>
<span class="line" id="L629">            <span class="tok-kw">else</span> =&gt; |err| <span class="tok-kw">return</span> unexpectedErrno(err),</span>
<span class="line" id="L630">        }</span>
<span class="line" id="L631">    }</span>
<span class="line" id="L632"></span>
<span class="line" id="L633">    <span class="tok-comment">// Prevents EINVAL.</span>
</span>
<span class="line" id="L634">    <span class="tok-kw">const</span> max_count = <span class="tok-kw">switch</span> (builtin.os.tag) {</span>
<span class="line" id="L635">        .linux =&gt; <span class="tok-number">0x7ffff000</span>,</span>
<span class="line" id="L636">        .macos, .ios, .watchos, .tvos =&gt; math.maxInt(<span class="tok-type">i32</span>),</span>
<span class="line" id="L637">        <span class="tok-kw">else</span> =&gt; math.maxInt(<span class="tok-type">isize</span>),</span>
<span class="line" id="L638">    };</span>
<span class="line" id="L639">    <span class="tok-kw">const</span> adjusted_len = <span class="tok-builtin">@minimum</span>(max_count, buf.len);</span>
<span class="line" id="L640"></span>
<span class="line" id="L641">    <span class="tok-kw">while</span> (<span class="tok-null">true</span>) {</span>
<span class="line" id="L642">        <span class="tok-kw">const</span> rc = system.read(fd, buf.ptr, adjusted_len);</span>
<span class="line" id="L643">        <span class="tok-kw">switch</span> (errno(rc)) {</span>
<span class="line" id="L644">            .SUCCESS =&gt; <span class="tok-kw">return</span> <span class="tok-builtin">@intCast</span>(<span class="tok-type">usize</span>, rc),</span>
<span class="line" id="L645">            .INTR =&gt; <span class="tok-kw">continue</span>,</span>
<span class="line" id="L646">            .INVAL =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L647">            .FAULT =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L648">            .AGAIN =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.WouldBlock,</span>
<span class="line" id="L649">            .BADF =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.NotOpenForReading, <span class="tok-comment">// Can be a race condition.</span>
</span>
<span class="line" id="L650">            .IO =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.InputOutput,</span>
<span class="line" id="L651">            .ISDIR =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.IsDir,</span>
<span class="line" id="L652">            .NOBUFS =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.SystemResources,</span>
<span class="line" id="L653">            .NOMEM =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.SystemResources,</span>
<span class="line" id="L654">            .CONNRESET =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.ConnectionResetByPeer,</span>
<span class="line" id="L655">            .TIMEDOUT =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.ConnectionTimedOut,</span>
<span class="line" id="L656">            <span class="tok-kw">else</span> =&gt; |err| <span class="tok-kw">return</span> unexpectedErrno(err),</span>
<span class="line" id="L657">        }</span>
<span class="line" id="L658">    }</span>
<span class="line" id="L659">}</span>
<span class="line" id="L660"></span>
<span class="line" id="L661"><span class="tok-comment">/// Number of bytes read is returned. Upon reading end-of-file, zero is returned.</span></span>
<span class="line" id="L662"><span class="tok-comment">///</span></span>
<span class="line" id="L663"><span class="tok-comment">/// For POSIX systems, if `fd` is opened in non blocking mode, the function will</span></span>
<span class="line" id="L664"><span class="tok-comment">/// return error.WouldBlock when EAGAIN is received.</span></span>
<span class="line" id="L665"><span class="tok-comment">/// On Windows, if the application has a global event loop enabled, I/O Completion Ports are</span></span>
<span class="line" id="L666"><span class="tok-comment">/// used to perform the I/O. `error.WouldBlock` is not possible on Windows.</span></span>
<span class="line" id="L667"><span class="tok-comment">///</span></span>
<span class="line" id="L668"><span class="tok-comment">/// This operation is non-atomic on the following systems:</span></span>
<span class="line" id="L669"><span class="tok-comment">/// * Windows</span></span>
<span class="line" id="L670"><span class="tok-comment">/// On these systems, the read races with concurrent writes to the same file descriptor.</span></span>
<span class="line" id="L671"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">readv</span>(fd: fd_t, iov: []<span class="tok-kw">const</span> iovec) ReadError!<span class="tok-type">usize</span> {</span>
<span class="line" id="L672">    <span class="tok-kw">if</span> (builtin.os.tag == .windows) {</span>
<span class="line" id="L673">        <span class="tok-comment">// TODO improve this to use ReadFileScatter</span>
</span>
<span class="line" id="L674">        <span class="tok-kw">if</span> (iov.len == <span class="tok-number">0</span>) <span class="tok-kw">return</span> <span class="tok-builtin">@as</span>(<span class="tok-type">usize</span>, <span class="tok-number">0</span>);</span>
<span class="line" id="L675">        <span class="tok-kw">const</span> first = iov[<span class="tok-number">0</span>];</span>
<span class="line" id="L676">        <span class="tok-kw">return</span> read(fd, first.iov_base[<span class="tok-number">0</span>..first.iov_len]);</span>
<span class="line" id="L677">    }</span>
<span class="line" id="L678">    <span class="tok-kw">if</span> (builtin.os.tag == .wasi <span class="tok-kw">and</span> !builtin.link_libc) {</span>
<span class="line" id="L679">        <span class="tok-kw">var</span> nread: <span class="tok-type">usize</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L680">        <span class="tok-kw">switch</span> (wasi.fd_read(fd, iov.ptr, iov.len, &amp;nread)) {</span>
<span class="line" id="L681">            .SUCCESS =&gt; <span class="tok-kw">return</span> nread,</span>
<span class="line" id="L682">            .INTR =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L683">            .INVAL =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L684">            .FAULT =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L685">            .AGAIN =&gt; <span class="tok-kw">unreachable</span>, <span class="tok-comment">// currently not support in WASI</span>
</span>
<span class="line" id="L686">            .BADF =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.NotOpenForReading, <span class="tok-comment">// can be a race condition</span>
</span>
<span class="line" id="L687">            .IO =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.InputOutput,</span>
<span class="line" id="L688">            .ISDIR =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.IsDir,</span>
<span class="line" id="L689">            .NOBUFS =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.SystemResources,</span>
<span class="line" id="L690">            .NOMEM =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.SystemResources,</span>
<span class="line" id="L691">            .NOTCAPABLE =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.AccessDenied,</span>
<span class="line" id="L692">            <span class="tok-kw">else</span> =&gt; |err| <span class="tok-kw">return</span> unexpectedErrno(err),</span>
<span class="line" id="L693">        }</span>
<span class="line" id="L694">    }</span>
<span class="line" id="L695">    <span class="tok-kw">const</span> iov_count = math.cast(<span class="tok-type">u31</span>, iov.len) <span class="tok-kw">orelse</span> math.maxInt(<span class="tok-type">u31</span>);</span>
<span class="line" id="L696">    <span class="tok-kw">while</span> (<span class="tok-null">true</span>) {</span>
<span class="line" id="L697">        <span class="tok-comment">// TODO handle the case when iov_len is too large and get rid of this @intCast</span>
</span>
<span class="line" id="L698">        <span class="tok-kw">const</span> rc = system.readv(fd, iov.ptr, iov_count);</span>
<span class="line" id="L699">        <span class="tok-kw">switch</span> (errno(rc)) {</span>
<span class="line" id="L700">            .SUCCESS =&gt; <span class="tok-kw">return</span> <span class="tok-builtin">@intCast</span>(<span class="tok-type">usize</span>, rc),</span>
<span class="line" id="L701">            .INTR =&gt; <span class="tok-kw">continue</span>,</span>
<span class="line" id="L702">            .INVAL =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L703">            .FAULT =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L704">            .AGAIN =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.WouldBlock,</span>
<span class="line" id="L705">            .BADF =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.NotOpenForReading, <span class="tok-comment">// can be a race condition</span>
</span>
<span class="line" id="L706">            .IO =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.InputOutput,</span>
<span class="line" id="L707">            .ISDIR =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.IsDir,</span>
<span class="line" id="L708">            .NOBUFS =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.SystemResources,</span>
<span class="line" id="L709">            .NOMEM =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.SystemResources,</span>
<span class="line" id="L710">            <span class="tok-kw">else</span> =&gt; |err| <span class="tok-kw">return</span> unexpectedErrno(err),</span>
<span class="line" id="L711">        }</span>
<span class="line" id="L712">    }</span>
<span class="line" id="L713">}</span>
<span class="line" id="L714"></span>
<span class="line" id="L715"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> PReadError = ReadError || <span class="tok-kw">error</span>{Unseekable};</span>
<span class="line" id="L716"></span>
<span class="line" id="L717"><span class="tok-comment">/// Number of bytes read is returned. Upon reading end-of-file, zero is returned.</span></span>
<span class="line" id="L718"><span class="tok-comment">///</span></span>
<span class="line" id="L719"><span class="tok-comment">/// Retries when interrupted by a signal.</span></span>
<span class="line" id="L720"><span class="tok-comment">///</span></span>
<span class="line" id="L721"><span class="tok-comment">/// For POSIX systems, if `fd` is opened in non blocking mode, the function will</span></span>
<span class="line" id="L722"><span class="tok-comment">/// return error.WouldBlock when EAGAIN is received.</span></span>
<span class="line" id="L723"><span class="tok-comment">/// On Windows, if the application has a global event loop enabled, I/O Completion Ports are</span></span>
<span class="line" id="L724"><span class="tok-comment">/// used to perform the I/O. `error.WouldBlock` is not possible on Windows.</span></span>
<span class="line" id="L725"><span class="tok-comment">///</span></span>
<span class="line" id="L726"><span class="tok-comment">/// Linux has a limit on how many bytes may be transferred in one `pread` call, which is `0x7ffff000`</span></span>
<span class="line" id="L727"><span class="tok-comment">/// on both 64-bit and 32-bit systems. This is due to using a signed C int as the return value, as</span></span>
<span class="line" id="L728"><span class="tok-comment">/// well as stuffing the errno codes into the last `4096` values. This is noted on the `read` man page.</span></span>
<span class="line" id="L729"><span class="tok-comment">/// The limit on Darwin is `0x7fffffff`, trying to read more than that returns EINVAL.</span></span>
<span class="line" id="L730"><span class="tok-comment">/// The corresponding POSIX limit is `math.maxInt(isize)`.</span></span>
<span class="line" id="L731"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">pread</span>(fd: fd_t, buf: []<span class="tok-type">u8</span>, offset: <span class="tok-type">u64</span>) PReadError!<span class="tok-type">usize</span> {</span>
<span class="line" id="L732">    <span class="tok-kw">if</span> (builtin.os.tag == .windows) {</span>
<span class="line" id="L733">        <span class="tok-kw">return</span> windows.ReadFile(fd, buf, offset, std.io.default_mode);</span>
<span class="line" id="L734">    }</span>
<span class="line" id="L735">    <span class="tok-kw">if</span> (builtin.os.tag == .wasi <span class="tok-kw">and</span> !builtin.link_libc) {</span>
<span class="line" id="L736">        <span class="tok-kw">const</span> iovs = [<span class="tok-number">1</span>]iovec{iovec{</span>
<span class="line" id="L737">            .iov_base = buf.ptr,</span>
<span class="line" id="L738">            .iov_len = buf.len,</span>
<span class="line" id="L739">        }};</span>
<span class="line" id="L740"></span>
<span class="line" id="L741">        <span class="tok-kw">var</span> nread: <span class="tok-type">usize</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L742">        <span class="tok-kw">switch</span> (wasi.fd_pread(fd, &amp;iovs, iovs.len, offset, &amp;nread)) {</span>
<span class="line" id="L743">            .SUCCESS =&gt; <span class="tok-kw">return</span> nread,</span>
<span class="line" id="L744">            .INTR =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L745">            .INVAL =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L746">            .FAULT =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L747">            .AGAIN =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L748">            .BADF =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.NotOpenForReading, <span class="tok-comment">// Can be a race condition.</span>
</span>
<span class="line" id="L749">            .IO =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.InputOutput,</span>
<span class="line" id="L750">            .ISDIR =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.IsDir,</span>
<span class="line" id="L751">            .NOBUFS =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.SystemResources,</span>
<span class="line" id="L752">            .NOMEM =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.SystemResources,</span>
<span class="line" id="L753">            .CONNRESET =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.ConnectionResetByPeer,</span>
<span class="line" id="L754">            .NXIO =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.Unseekable,</span>
<span class="line" id="L755">            .SPIPE =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.Unseekable,</span>
<span class="line" id="L756">            .OVERFLOW =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.Unseekable,</span>
<span class="line" id="L757">            .NOTCAPABLE =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.AccessDenied,</span>
<span class="line" id="L758">            <span class="tok-kw">else</span> =&gt; |err| <span class="tok-kw">return</span> unexpectedErrno(err),</span>
<span class="line" id="L759">        }</span>
<span class="line" id="L760">    }</span>
<span class="line" id="L761"></span>
<span class="line" id="L762">    <span class="tok-comment">// Prevent EINVAL.</span>
</span>
<span class="line" id="L763">    <span class="tok-kw">const</span> max_count = <span class="tok-kw">switch</span> (builtin.os.tag) {</span>
<span class="line" id="L764">        .linux =&gt; <span class="tok-number">0x7ffff000</span>,</span>
<span class="line" id="L765">        .macos, .ios, .watchos, .tvos =&gt; math.maxInt(<span class="tok-type">i32</span>),</span>
<span class="line" id="L766">        <span class="tok-kw">else</span> =&gt; math.maxInt(<span class="tok-type">isize</span>),</span>
<span class="line" id="L767">    };</span>
<span class="line" id="L768">    <span class="tok-kw">const</span> adjusted_len = <span class="tok-builtin">@minimum</span>(max_count, buf.len);</span>
<span class="line" id="L769"></span>
<span class="line" id="L770">    <span class="tok-kw">const</span> pread_sym = <span class="tok-kw">if</span> (builtin.os.tag == .linux <span class="tok-kw">and</span> builtin.link_libc)</span>
<span class="line" id="L771">        system.pread64</span>
<span class="line" id="L772">    <span class="tok-kw">else</span></span>
<span class="line" id="L773">        system.pread;</span>
<span class="line" id="L774"></span>
<span class="line" id="L775">    <span class="tok-kw">const</span> ioffset = <span class="tok-builtin">@bitCast</span>(<span class="tok-type">i64</span>, offset); <span class="tok-comment">// the OS treats this as unsigned</span>
</span>
<span class="line" id="L776">    <span class="tok-kw">while</span> (<span class="tok-null">true</span>) {</span>
<span class="line" id="L777">        <span class="tok-kw">const</span> rc = pread_sym(fd, buf.ptr, adjusted_len, ioffset);</span>
<span class="line" id="L778">        <span class="tok-kw">switch</span> (errno(rc)) {</span>
<span class="line" id="L779">            .SUCCESS =&gt; <span class="tok-kw">return</span> <span class="tok-builtin">@intCast</span>(<span class="tok-type">usize</span>, rc),</span>
<span class="line" id="L780">            .INTR =&gt; <span class="tok-kw">continue</span>,</span>
<span class="line" id="L781">            .INVAL =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L782">            .FAULT =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L783">            .AGAIN =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.WouldBlock,</span>
<span class="line" id="L784">            .BADF =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.NotOpenForReading, <span class="tok-comment">// Can be a race condition.</span>
</span>
<span class="line" id="L785">            .IO =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.InputOutput,</span>
<span class="line" id="L786">            .ISDIR =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.IsDir,</span>
<span class="line" id="L787">            .NOBUFS =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.SystemResources,</span>
<span class="line" id="L788">            .NOMEM =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.SystemResources,</span>
<span class="line" id="L789">            .CONNRESET =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.ConnectionResetByPeer,</span>
<span class="line" id="L790">            .NXIO =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.Unseekable,</span>
<span class="line" id="L791">            .SPIPE =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.Unseekable,</span>
<span class="line" id="L792">            .OVERFLOW =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.Unseekable,</span>
<span class="line" id="L793">            <span class="tok-kw">else</span> =&gt; |err| <span class="tok-kw">return</span> unexpectedErrno(err),</span>
<span class="line" id="L794">        }</span>
<span class="line" id="L795">    }</span>
<span class="line" id="L796">}</span>
<span class="line" id="L797"></span>
<span class="line" id="L798"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> TruncateError = <span class="tok-kw">error</span>{</span>
<span class="line" id="L799">    FileTooBig,</span>
<span class="line" id="L800">    InputOutput,</span>
<span class="line" id="L801">    FileBusy,</span>
<span class="line" id="L802"></span>
<span class="line" id="L803">    <span class="tok-comment">/// In WASI, this error occurs when the file descriptor does</span></span>
<span class="line" id="L804">    <span class="tok-comment">/// not hold the required rights to call `ftruncate` on it.</span></span>
<span class="line" id="L805">    AccessDenied,</span>
<span class="line" id="L806">} || UnexpectedError;</span>
<span class="line" id="L807"></span>
<span class="line" id="L808"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">ftruncate</span>(fd: fd_t, length: <span class="tok-type">u64</span>) TruncateError!<span class="tok-type">void</span> {</span>
<span class="line" id="L809">    <span class="tok-kw">if</span> (builtin.os.tag == .windows) {</span>
<span class="line" id="L810">        <span class="tok-kw">var</span> io_status_block: windows.IO_STATUS_BLOCK = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L811">        <span class="tok-kw">var</span> eof_info = windows.FILE_END_OF_FILE_INFORMATION{</span>
<span class="line" id="L812">            .EndOfFile = <span class="tok-builtin">@bitCast</span>(windows.LARGE_INTEGER, length),</span>
<span class="line" id="L813">        };</span>
<span class="line" id="L814"></span>
<span class="line" id="L815">        <span class="tok-kw">const</span> rc = windows.ntdll.NtSetInformationFile(</span>
<span class="line" id="L816">            fd,</span>
<span class="line" id="L817">            &amp;io_status_block,</span>
<span class="line" id="L818">            &amp;eof_info,</span>
<span class="line" id="L819">            <span class="tok-builtin">@sizeOf</span>(windows.FILE_END_OF_FILE_INFORMATION),</span>
<span class="line" id="L820">            .FileEndOfFileInformation,</span>
<span class="line" id="L821">        );</span>
<span class="line" id="L822"></span>
<span class="line" id="L823">        <span class="tok-kw">switch</span> (rc) {</span>
<span class="line" id="L824">            .SUCCESS =&gt; <span class="tok-kw">return</span>,</span>
<span class="line" id="L825">            .INVALID_HANDLE =&gt; <span class="tok-kw">unreachable</span>, <span class="tok-comment">// Handle not open for writing</span>
</span>
<span class="line" id="L826">            .ACCESS_DENIED =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.AccessDenied,</span>
<span class="line" id="L827">            <span class="tok-kw">else</span> =&gt; <span class="tok-kw">return</span> windows.unexpectedStatus(rc),</span>
<span class="line" id="L828">        }</span>
<span class="line" id="L829">    }</span>
<span class="line" id="L830">    <span class="tok-kw">if</span> (builtin.os.tag == .wasi <span class="tok-kw">and</span> !builtin.link_libc) {</span>
<span class="line" id="L831">        <span class="tok-kw">switch</span> (wasi.fd_filestat_set_size(fd, length)) {</span>
<span class="line" id="L832">            .SUCCESS =&gt; <span class="tok-kw">return</span>,</span>
<span class="line" id="L833">            .INTR =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L834">            .FBIG =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.FileTooBig,</span>
<span class="line" id="L835">            .IO =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.InputOutput,</span>
<span class="line" id="L836">            .PERM =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.AccessDenied,</span>
<span class="line" id="L837">            .TXTBSY =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.FileBusy,</span>
<span class="line" id="L838">            .BADF =&gt; <span class="tok-kw">unreachable</span>, <span class="tok-comment">// Handle not open for writing</span>
</span>
<span class="line" id="L839">            .INVAL =&gt; <span class="tok-kw">unreachable</span>, <span class="tok-comment">// Handle not open for writing</span>
</span>
<span class="line" id="L840">            .NOTCAPABLE =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.AccessDenied,</span>
<span class="line" id="L841">            <span class="tok-kw">else</span> =&gt; |err| <span class="tok-kw">return</span> unexpectedErrno(err),</span>
<span class="line" id="L842">        }</span>
<span class="line" id="L843">    }</span>
<span class="line" id="L844"></span>
<span class="line" id="L845">    <span class="tok-kw">while</span> (<span class="tok-null">true</span>) {</span>
<span class="line" id="L846">        <span class="tok-kw">const</span> ftruncate_sym = <span class="tok-kw">if</span> (builtin.os.tag == .linux <span class="tok-kw">and</span> builtin.link_libc)</span>
<span class="line" id="L847">            system.ftruncate64</span>
<span class="line" id="L848">        <span class="tok-kw">else</span></span>
<span class="line" id="L849">            system.ftruncate;</span>
<span class="line" id="L850"></span>
<span class="line" id="L851">        <span class="tok-kw">const</span> ilen = <span class="tok-builtin">@bitCast</span>(<span class="tok-type">i64</span>, length); <span class="tok-comment">// the OS treats this as unsigned</span>
</span>
<span class="line" id="L852">        <span class="tok-kw">switch</span> (errno(ftruncate_sym(fd, ilen))) {</span>
<span class="line" id="L853">            .SUCCESS =&gt; <span class="tok-kw">return</span>,</span>
<span class="line" id="L854">            .INTR =&gt; <span class="tok-kw">continue</span>,</span>
<span class="line" id="L855">            .FBIG =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.FileTooBig,</span>
<span class="line" id="L856">            .IO =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.InputOutput,</span>
<span class="line" id="L857">            .PERM =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.AccessDenied,</span>
<span class="line" id="L858">            .TXTBSY =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.FileBusy,</span>
<span class="line" id="L859">            .BADF =&gt; <span class="tok-kw">unreachable</span>, <span class="tok-comment">// Handle not open for writing</span>
</span>
<span class="line" id="L860">            .INVAL =&gt; <span class="tok-kw">unreachable</span>, <span class="tok-comment">// Handle not open for writing</span>
</span>
<span class="line" id="L861">            <span class="tok-kw">else</span> =&gt; |err| <span class="tok-kw">return</span> unexpectedErrno(err),</span>
<span class="line" id="L862">        }</span>
<span class="line" id="L863">    }</span>
<span class="line" id="L864">}</span>
<span class="line" id="L865"></span>
<span class="line" id="L866"><span class="tok-comment">/// Number of bytes read is returned. Upon reading end-of-file, zero is returned.</span></span>
<span class="line" id="L867"><span class="tok-comment">///</span></span>
<span class="line" id="L868"><span class="tok-comment">/// Retries when interrupted by a signal.</span></span>
<span class="line" id="L869"><span class="tok-comment">///</span></span>
<span class="line" id="L870"><span class="tok-comment">/// For POSIX systems, if `fd` is opened in non blocking mode, the function will</span></span>
<span class="line" id="L871"><span class="tok-comment">/// return error.WouldBlock when EAGAIN is received.</span></span>
<span class="line" id="L872"><span class="tok-comment">/// On Windows, if the application has a global event loop enabled, I/O Completion Ports are</span></span>
<span class="line" id="L873"><span class="tok-comment">/// used to perform the I/O. `error.WouldBlock` is not possible on Windows.</span></span>
<span class="line" id="L874"><span class="tok-comment">///</span></span>
<span class="line" id="L875"><span class="tok-comment">/// This operation is non-atomic on the following systems:</span></span>
<span class="line" id="L876"><span class="tok-comment">/// * Darwin</span></span>
<span class="line" id="L877"><span class="tok-comment">/// * Windows</span></span>
<span class="line" id="L878"><span class="tok-comment">/// On these systems, the read races with concurrent writes to the same file descriptor.</span></span>
<span class="line" id="L879"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">preadv</span>(fd: fd_t, iov: []<span class="tok-kw">const</span> iovec, offset: <span class="tok-type">u64</span>) PReadError!<span class="tok-type">usize</span> {</span>
<span class="line" id="L880">    <span class="tok-kw">const</span> have_pread_but_not_preadv = <span class="tok-kw">switch</span> (builtin.os.tag) {</span>
<span class="line" id="L881">        .windows, .macos, .ios, .watchos, .tvos, .haiku =&gt; <span class="tok-null">true</span>,</span>
<span class="line" id="L882">        <span class="tok-kw">else</span> =&gt; <span class="tok-null">false</span>,</span>
<span class="line" id="L883">    };</span>
<span class="line" id="L884">    <span class="tok-kw">if</span> (have_pread_but_not_preadv) {</span>
<span class="line" id="L885">        <span class="tok-comment">// We could loop here; but proper usage of `preadv` must handle partial reads anyway.</span>
</span>
<span class="line" id="L886">        <span class="tok-comment">// So we simply read into the first vector only.</span>
</span>
<span class="line" id="L887">        <span class="tok-kw">if</span> (iov.len == <span class="tok-number">0</span>) <span class="tok-kw">return</span> <span class="tok-builtin">@as</span>(<span class="tok-type">usize</span>, <span class="tok-number">0</span>);</span>
<span class="line" id="L888">        <span class="tok-kw">const</span> first = iov[<span class="tok-number">0</span>];</span>
<span class="line" id="L889">        <span class="tok-kw">return</span> pread(fd, first.iov_base[<span class="tok-number">0</span>..first.iov_len], offset);</span>
<span class="line" id="L890">    }</span>
<span class="line" id="L891">    <span class="tok-kw">if</span> (builtin.os.tag == .wasi <span class="tok-kw">and</span> !builtin.link_libc) {</span>
<span class="line" id="L892">        <span class="tok-kw">var</span> nread: <span class="tok-type">usize</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L893">        <span class="tok-kw">switch</span> (wasi.fd_pread(fd, iov.ptr, iov.len, offset, &amp;nread)) {</span>
<span class="line" id="L894">            .SUCCESS =&gt; <span class="tok-kw">return</span> nread,</span>
<span class="line" id="L895">            .INTR =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L896">            .INVAL =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L897">            .FAULT =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L898">            .AGAIN =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L899">            .BADF =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.NotOpenForReading, <span class="tok-comment">// can be a race condition</span>
</span>
<span class="line" id="L900">            .IO =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.InputOutput,</span>
<span class="line" id="L901">            .ISDIR =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.IsDir,</span>
<span class="line" id="L902">            .NOBUFS =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.SystemResources,</span>
<span class="line" id="L903">            .NOMEM =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.SystemResources,</span>
<span class="line" id="L904">            .NXIO =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.Unseekable,</span>
<span class="line" id="L905">            .SPIPE =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.Unseekable,</span>
<span class="line" id="L906">            .OVERFLOW =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.Unseekable,</span>
<span class="line" id="L907">            .NOTCAPABLE =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.AccessDenied,</span>
<span class="line" id="L908">            <span class="tok-kw">else</span> =&gt; |err| <span class="tok-kw">return</span> unexpectedErrno(err),</span>
<span class="line" id="L909">        }</span>
<span class="line" id="L910">    }</span>
<span class="line" id="L911"></span>
<span class="line" id="L912">    <span class="tok-kw">const</span> iov_count = math.cast(<span class="tok-type">u31</span>, iov.len) <span class="tok-kw">orelse</span> math.maxInt(<span class="tok-type">u31</span>);</span>
<span class="line" id="L913"></span>
<span class="line" id="L914">    <span class="tok-kw">const</span> preadv_sym = <span class="tok-kw">if</span> (builtin.os.tag == .linux <span class="tok-kw">and</span> builtin.link_libc)</span>
<span class="line" id="L915">        system.preadv64</span>
<span class="line" id="L916">    <span class="tok-kw">else</span></span>
<span class="line" id="L917">        system.preadv;</span>
<span class="line" id="L918"></span>
<span class="line" id="L919">    <span class="tok-kw">const</span> ioffset = <span class="tok-builtin">@bitCast</span>(<span class="tok-type">i64</span>, offset); <span class="tok-comment">// the OS treats this as unsigned</span>
</span>
<span class="line" id="L920">    <span class="tok-kw">while</span> (<span class="tok-null">true</span>) {</span>
<span class="line" id="L921">        <span class="tok-kw">const</span> rc = preadv_sym(fd, iov.ptr, iov_count, ioffset);</span>
<span class="line" id="L922">        <span class="tok-kw">switch</span> (errno(rc)) {</span>
<span class="line" id="L923">            .SUCCESS =&gt; <span class="tok-kw">return</span> <span class="tok-builtin">@bitCast</span>(<span class="tok-type">usize</span>, rc),</span>
<span class="line" id="L924">            .INTR =&gt; <span class="tok-kw">continue</span>,</span>
<span class="line" id="L925">            .INVAL =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L926">            .FAULT =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L927">            .AGAIN =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.WouldBlock,</span>
<span class="line" id="L928">            .BADF =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.NotOpenForReading, <span class="tok-comment">// can be a race condition</span>
</span>
<span class="line" id="L929">            .IO =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.InputOutput,</span>
<span class="line" id="L930">            .ISDIR =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.IsDir,</span>
<span class="line" id="L931">            .NOBUFS =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.SystemResources,</span>
<span class="line" id="L932">            .NOMEM =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.SystemResources,</span>
<span class="line" id="L933">            .NXIO =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.Unseekable,</span>
<span class="line" id="L934">            .SPIPE =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.Unseekable,</span>
<span class="line" id="L935">            .OVERFLOW =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.Unseekable,</span>
<span class="line" id="L936">            <span class="tok-kw">else</span> =&gt; |err| <span class="tok-kw">return</span> unexpectedErrno(err),</span>
<span class="line" id="L937">        }</span>
<span class="line" id="L938">    }</span>
<span class="line" id="L939">}</span>
<span class="line" id="L940"></span>
<span class="line" id="L941"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> WriteError = <span class="tok-kw">error</span>{</span>
<span class="line" id="L942">    DiskQuota,</span>
<span class="line" id="L943">    FileTooBig,</span>
<span class="line" id="L944">    InputOutput,</span>
<span class="line" id="L945">    NoSpaceLeft,</span>
<span class="line" id="L946"></span>
<span class="line" id="L947">    <span class="tok-comment">/// In WASI, this error may occur when the file descriptor does</span></span>
<span class="line" id="L948">    <span class="tok-comment">/// not hold the required rights to write to it.</span></span>
<span class="line" id="L949">    AccessDenied,</span>
<span class="line" id="L950">    BrokenPipe,</span>
<span class="line" id="L951">    SystemResources,</span>
<span class="line" id="L952">    OperationAborted,</span>
<span class="line" id="L953">    NotOpenForWriting,</span>
<span class="line" id="L954"></span>
<span class="line" id="L955">    <span class="tok-comment">/// The process cannot access the file because another process has locked</span></span>
<span class="line" id="L956">    <span class="tok-comment">/// a portion of the file. Windows-only.</span></span>
<span class="line" id="L957">    LockViolation,</span>
<span class="line" id="L958"></span>
<span class="line" id="L959">    <span class="tok-comment">/// This error occurs when no global event loop is configured,</span></span>
<span class="line" id="L960">    <span class="tok-comment">/// and reading from the file descriptor would block.</span></span>
<span class="line" id="L961">    WouldBlock,</span>
<span class="line" id="L962"></span>
<span class="line" id="L963">    <span class="tok-comment">/// Connection reset by peer.</span></span>
<span class="line" id="L964">    ConnectionResetByPeer,</span>
<span class="line" id="L965">} || UnexpectedError;</span>
<span class="line" id="L966"></span>
<span class="line" id="L967"><span class="tok-comment">/// Write to a file descriptor.</span></span>
<span class="line" id="L968"><span class="tok-comment">/// Retries when interrupted by a signal.</span></span>
<span class="line" id="L969"><span class="tok-comment">/// Returns the number of bytes written. If nonzero bytes were supplied, this will be nonzero.</span></span>
<span class="line" id="L970"><span class="tok-comment">///</span></span>
<span class="line" id="L971"><span class="tok-comment">/// Note that a successful write() may transfer fewer than count bytes.  Such partial  writes  can</span></span>
<span class="line" id="L972"><span class="tok-comment">/// occur  for  various reasons; for example, because there was insufficient space on the disk</span></span>
<span class="line" id="L973"><span class="tok-comment">/// device to write all of the requested bytes, or because a blocked write() to a socket,  pipe,  or</span></span>
<span class="line" id="L974"><span class="tok-comment">/// similar  was  interrupted by a signal handler after it had transferred some, but before it had</span></span>
<span class="line" id="L975"><span class="tok-comment">/// transferred all of the requested bytes.  In the event of a partial write, the caller can  make</span></span>
<span class="line" id="L976"><span class="tok-comment">/// another  write() call to transfer the remaining bytes.  The subsequent call will either</span></span>
<span class="line" id="L977"><span class="tok-comment">/// transfer further bytes or may result in an error (e.g., if the disk is now full).</span></span>
<span class="line" id="L978"><span class="tok-comment">///</span></span>
<span class="line" id="L979"><span class="tok-comment">/// For POSIX systems, if `fd` is opened in non blocking mode, the function will</span></span>
<span class="line" id="L980"><span class="tok-comment">/// return error.WouldBlock when EAGAIN is received.</span></span>
<span class="line" id="L981"><span class="tok-comment">/// On Windows, if the application has a global event loop enabled, I/O Completion Ports are</span></span>
<span class="line" id="L982"><span class="tok-comment">/// used to perform the I/O. `error.WouldBlock` is not possible on Windows.</span></span>
<span class="line" id="L983"><span class="tok-comment">///</span></span>
<span class="line" id="L984"><span class="tok-comment">/// Linux has a limit on how many bytes may be transferred in one `write` call, which is `0x7ffff000`</span></span>
<span class="line" id="L985"><span class="tok-comment">/// on both 64-bit and 32-bit systems. This is due to using a signed C int as the return value, as</span></span>
<span class="line" id="L986"><span class="tok-comment">/// well as stuffing the errno codes into the last `4096` values. This is noted on the `write` man page.</span></span>
<span class="line" id="L987"><span class="tok-comment">/// The limit on Darwin is `0x7fffffff`, trying to read more than that returns EINVAL.</span></span>
<span class="line" id="L988"><span class="tok-comment">/// The corresponding POSIX limit is `math.maxInt(isize)`.</span></span>
<span class="line" id="L989"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">write</span>(fd: fd_t, bytes: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) WriteError!<span class="tok-type">usize</span> {</span>
<span class="line" id="L990">    <span class="tok-kw">if</span> (builtin.os.tag == .windows) {</span>
<span class="line" id="L991">        <span class="tok-kw">return</span> windows.WriteFile(fd, bytes, <span class="tok-null">null</span>, std.io.default_mode);</span>
<span class="line" id="L992">    }</span>
<span class="line" id="L993"></span>
<span class="line" id="L994">    <span class="tok-kw">if</span> (builtin.os.tag == .wasi <span class="tok-kw">and</span> !builtin.link_libc) {</span>
<span class="line" id="L995">        <span class="tok-kw">const</span> ciovs = [_]iovec_const{iovec_const{</span>
<span class="line" id="L996">            .iov_base = bytes.ptr,</span>
<span class="line" id="L997">            .iov_len = bytes.len,</span>
<span class="line" id="L998">        }};</span>
<span class="line" id="L999">        <span class="tok-kw">var</span> nwritten: <span class="tok-type">usize</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L1000">        <span class="tok-kw">switch</span> (wasi.fd_write(fd, &amp;ciovs, ciovs.len, &amp;nwritten)) {</span>
<span class="line" id="L1001">            .SUCCESS =&gt; <span class="tok-kw">return</span> nwritten,</span>
<span class="line" id="L1002">            .INTR =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L1003">            .INVAL =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L1004">            .FAULT =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L1005">            .AGAIN =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L1006">            .BADF =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.NotOpenForWriting, <span class="tok-comment">// can be a race condition.</span>
</span>
<span class="line" id="L1007">            .DESTADDRREQ =&gt; <span class="tok-kw">unreachable</span>, <span class="tok-comment">// `connect` was never called.</span>
</span>
<span class="line" id="L1008">            .DQUOT =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.DiskQuota,</span>
<span class="line" id="L1009">            .FBIG =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.FileTooBig,</span>
<span class="line" id="L1010">            .IO =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.InputOutput,</span>
<span class="line" id="L1011">            .NOSPC =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.NoSpaceLeft,</span>
<span class="line" id="L1012">            .PERM =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.AccessDenied,</span>
<span class="line" id="L1013">            .PIPE =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.BrokenPipe,</span>
<span class="line" id="L1014">            .NOTCAPABLE =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.AccessDenied,</span>
<span class="line" id="L1015">            <span class="tok-kw">else</span> =&gt; |err| <span class="tok-kw">return</span> unexpectedErrno(err),</span>
<span class="line" id="L1016">        }</span>
<span class="line" id="L1017">    }</span>
<span class="line" id="L1018"></span>
<span class="line" id="L1019">    <span class="tok-kw">const</span> max_count = <span class="tok-kw">switch</span> (builtin.os.tag) {</span>
<span class="line" id="L1020">        .linux =&gt; <span class="tok-number">0x7ffff000</span>,</span>
<span class="line" id="L1021">        .macos, .ios, .watchos, .tvos =&gt; math.maxInt(<span class="tok-type">i32</span>),</span>
<span class="line" id="L1022">        <span class="tok-kw">else</span> =&gt; math.maxInt(<span class="tok-type">isize</span>),</span>
<span class="line" id="L1023">    };</span>
<span class="line" id="L1024">    <span class="tok-kw">const</span> adjusted_len = <span class="tok-builtin">@minimum</span>(max_count, bytes.len);</span>
<span class="line" id="L1025"></span>
<span class="line" id="L1026">    <span class="tok-kw">while</span> (<span class="tok-null">true</span>) {</span>
<span class="line" id="L1027">        <span class="tok-kw">const</span> rc = system.write(fd, bytes.ptr, adjusted_len);</span>
<span class="line" id="L1028">        <span class="tok-kw">switch</span> (errno(rc)) {</span>
<span class="line" id="L1029">            .SUCCESS =&gt; <span class="tok-kw">return</span> <span class="tok-builtin">@intCast</span>(<span class="tok-type">usize</span>, rc),</span>
<span class="line" id="L1030">            .INTR =&gt; <span class="tok-kw">continue</span>,</span>
<span class="line" id="L1031">            .INVAL =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L1032">            .FAULT =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L1033">            .AGAIN =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.WouldBlock,</span>
<span class="line" id="L1034">            .BADF =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.NotOpenForWriting, <span class="tok-comment">// can be a race condition.</span>
</span>
<span class="line" id="L1035">            .DESTADDRREQ =&gt; <span class="tok-kw">unreachable</span>, <span class="tok-comment">// `connect` was never called.</span>
</span>
<span class="line" id="L1036">            .DQUOT =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.DiskQuota,</span>
<span class="line" id="L1037">            .FBIG =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.FileTooBig,</span>
<span class="line" id="L1038">            .IO =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.InputOutput,</span>
<span class="line" id="L1039">            .NOSPC =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.NoSpaceLeft,</span>
<span class="line" id="L1040">            .PERM =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.AccessDenied,</span>
<span class="line" id="L1041">            .PIPE =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.BrokenPipe,</span>
<span class="line" id="L1042">            .CONNRESET =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.ConnectionResetByPeer,</span>
<span class="line" id="L1043">            <span class="tok-kw">else</span> =&gt; |err| <span class="tok-kw">return</span> unexpectedErrno(err),</span>
<span class="line" id="L1044">        }</span>
<span class="line" id="L1045">    }</span>
<span class="line" id="L1046">}</span>
<span class="line" id="L1047"></span>
<span class="line" id="L1048"><span class="tok-comment">/// Write multiple buffers to a file descriptor.</span></span>
<span class="line" id="L1049"><span class="tok-comment">/// Retries when interrupted by a signal.</span></span>
<span class="line" id="L1050"><span class="tok-comment">/// Returns the number of bytes written. If nonzero bytes were supplied, this will be nonzero.</span></span>
<span class="line" id="L1051"><span class="tok-comment">///</span></span>
<span class="line" id="L1052"><span class="tok-comment">/// Note that a successful write() may transfer fewer bytes than supplied.  Such partial  writes  can</span></span>
<span class="line" id="L1053"><span class="tok-comment">/// occur  for  various reasons; for example, because there was insufficient space on the disk</span></span>
<span class="line" id="L1054"><span class="tok-comment">/// device to write all of the requested bytes, or because a blocked write() to a socket,  pipe,  or</span></span>
<span class="line" id="L1055"><span class="tok-comment">/// similar  was  interrupted by a signal handler after it had transferred some, but before it had</span></span>
<span class="line" id="L1056"><span class="tok-comment">/// transferred all of the requested bytes.  In the event of a partial write, the caller can  make</span></span>
<span class="line" id="L1057"><span class="tok-comment">/// another  write() call to transfer the remaining bytes.  The subsequent call will either</span></span>
<span class="line" id="L1058"><span class="tok-comment">/// transfer further bytes or may result in an error (e.g., if the disk is now full).</span></span>
<span class="line" id="L1059"><span class="tok-comment">///</span></span>
<span class="line" id="L1060"><span class="tok-comment">/// For POSIX systems, if `fd` is opened in non blocking mode, the function will</span></span>
<span class="line" id="L1061"><span class="tok-comment">/// return error.WouldBlock when EAGAIN is received.</span></span>
<span class="line" id="L1062"><span class="tok-comment">/// On Windows, if the application has a global event loop enabled, I/O Completion Ports are</span></span>
<span class="line" id="L1063"><span class="tok-comment">/// used to perform the I/O. `error.WouldBlock` is not possible on Windows.</span></span>
<span class="line" id="L1064"><span class="tok-comment">///</span></span>
<span class="line" id="L1065"><span class="tok-comment">/// If `iov.len` is larger than `IOV_MAX`, a partial write will occur.</span></span>
<span class="line" id="L1066"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">writev</span>(fd: fd_t, iov: []<span class="tok-kw">const</span> iovec_const) WriteError!<span class="tok-type">usize</span> {</span>
<span class="line" id="L1067">    <span class="tok-kw">if</span> (builtin.os.tag == .windows) {</span>
<span class="line" id="L1068">        <span class="tok-comment">// TODO improve this to use WriteFileScatter</span>
</span>
<span class="line" id="L1069">        <span class="tok-kw">if</span> (iov.len == <span class="tok-number">0</span>) <span class="tok-kw">return</span> <span class="tok-builtin">@as</span>(<span class="tok-type">usize</span>, <span class="tok-number">0</span>);</span>
<span class="line" id="L1070">        <span class="tok-kw">const</span> first = iov[<span class="tok-number">0</span>];</span>
<span class="line" id="L1071">        <span class="tok-kw">return</span> write(fd, first.iov_base[<span class="tok-number">0</span>..first.iov_len]);</span>
<span class="line" id="L1072">    }</span>
<span class="line" id="L1073">    <span class="tok-kw">if</span> (builtin.os.tag == .wasi <span class="tok-kw">and</span> !builtin.link_libc) {</span>
<span class="line" id="L1074">        <span class="tok-kw">var</span> nwritten: <span class="tok-type">usize</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L1075">        <span class="tok-kw">switch</span> (wasi.fd_write(fd, iov.ptr, iov.len, &amp;nwritten)) {</span>
<span class="line" id="L1076">            .SUCCESS =&gt; <span class="tok-kw">return</span> nwritten,</span>
<span class="line" id="L1077">            .INTR =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L1078">            .INVAL =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L1079">            .FAULT =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L1080">            .AGAIN =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L1081">            .BADF =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.NotOpenForWriting, <span class="tok-comment">// can be a race condition.</span>
</span>
<span class="line" id="L1082">            .DESTADDRREQ =&gt; <span class="tok-kw">unreachable</span>, <span class="tok-comment">// `connect` was never called.</span>
</span>
<span class="line" id="L1083">            .DQUOT =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.DiskQuota,</span>
<span class="line" id="L1084">            .FBIG =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.FileTooBig,</span>
<span class="line" id="L1085">            .IO =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.InputOutput,</span>
<span class="line" id="L1086">            .NOSPC =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.NoSpaceLeft,</span>
<span class="line" id="L1087">            .PERM =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.AccessDenied,</span>
<span class="line" id="L1088">            .PIPE =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.BrokenPipe,</span>
<span class="line" id="L1089">            .NOTCAPABLE =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.AccessDenied,</span>
<span class="line" id="L1090">            <span class="tok-kw">else</span> =&gt; |err| <span class="tok-kw">return</span> unexpectedErrno(err),</span>
<span class="line" id="L1091">        }</span>
<span class="line" id="L1092">    }</span>
<span class="line" id="L1093"></span>
<span class="line" id="L1094">    <span class="tok-kw">const</span> iov_count = <span class="tok-kw">if</span> (iov.len &gt; IOV_MAX) IOV_MAX <span class="tok-kw">else</span> <span class="tok-builtin">@intCast</span>(<span class="tok-type">u31</span>, iov.len);</span>
<span class="line" id="L1095">    <span class="tok-kw">while</span> (<span class="tok-null">true</span>) {</span>
<span class="line" id="L1096">        <span class="tok-kw">const</span> rc = system.writev(fd, iov.ptr, iov_count);</span>
<span class="line" id="L1097">        <span class="tok-kw">switch</span> (errno(rc)) {</span>
<span class="line" id="L1098">            .SUCCESS =&gt; <span class="tok-kw">return</span> <span class="tok-builtin">@intCast</span>(<span class="tok-type">usize</span>, rc),</span>
<span class="line" id="L1099">            .INTR =&gt; <span class="tok-kw">continue</span>,</span>
<span class="line" id="L1100">            .INVAL =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L1101">            .FAULT =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L1102">            .AGAIN =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.WouldBlock,</span>
<span class="line" id="L1103">            .BADF =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.NotOpenForWriting, <span class="tok-comment">// Can be a race condition.</span>
</span>
<span class="line" id="L1104">            .DESTADDRREQ =&gt; <span class="tok-kw">unreachable</span>, <span class="tok-comment">// `connect` was never called.</span>
</span>
<span class="line" id="L1105">            .DQUOT =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.DiskQuota,</span>
<span class="line" id="L1106">            .FBIG =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.FileTooBig,</span>
<span class="line" id="L1107">            .IO =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.InputOutput,</span>
<span class="line" id="L1108">            .NOSPC =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.NoSpaceLeft,</span>
<span class="line" id="L1109">            .PERM =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.AccessDenied,</span>
<span class="line" id="L1110">            .PIPE =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.BrokenPipe,</span>
<span class="line" id="L1111">            .CONNRESET =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.ConnectionResetByPeer,</span>
<span class="line" id="L1112">            <span class="tok-kw">else</span> =&gt; |err| <span class="tok-kw">return</span> unexpectedErrno(err),</span>
<span class="line" id="L1113">        }</span>
<span class="line" id="L1114">    }</span>
<span class="line" id="L1115">}</span>
<span class="line" id="L1116"></span>
<span class="line" id="L1117"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> PWriteError = WriteError || <span class="tok-kw">error</span>{Unseekable};</span>
<span class="line" id="L1118"></span>
<span class="line" id="L1119"><span class="tok-comment">/// Write to a file descriptor, with a position offset.</span></span>
<span class="line" id="L1120"><span class="tok-comment">/// Retries when interrupted by a signal.</span></span>
<span class="line" id="L1121"><span class="tok-comment">/// Returns the number of bytes written. If nonzero bytes were supplied, this will be nonzero.</span></span>
<span class="line" id="L1122"><span class="tok-comment">///</span></span>
<span class="line" id="L1123"><span class="tok-comment">/// Note that a successful write() may transfer fewer bytes than supplied.  Such partial  writes  can</span></span>
<span class="line" id="L1124"><span class="tok-comment">/// occur  for  various reasons; for example, because there was insufficient space on the disk</span></span>
<span class="line" id="L1125"><span class="tok-comment">/// device to write all of the requested bytes, or because a blocked write() to a socket,  pipe,  or</span></span>
<span class="line" id="L1126"><span class="tok-comment">/// similar  was  interrupted by a signal handler after it had transferred some, but before it had</span></span>
<span class="line" id="L1127"><span class="tok-comment">/// transferred all of the requested bytes.  In the event of a partial write, the caller can  make</span></span>
<span class="line" id="L1128"><span class="tok-comment">/// another  write() call to transfer the remaining bytes.  The subsequent call will either</span></span>
<span class="line" id="L1129"><span class="tok-comment">/// transfer further bytes or may result in an error (e.g., if the disk is now full).</span></span>
<span class="line" id="L1130"><span class="tok-comment">///</span></span>
<span class="line" id="L1131"><span class="tok-comment">/// For POSIX systems, if `fd` is opened in non blocking mode, the function will</span></span>
<span class="line" id="L1132"><span class="tok-comment">/// return error.WouldBlock when EAGAIN is received.</span></span>
<span class="line" id="L1133"><span class="tok-comment">/// On Windows, if the application has a global event loop enabled, I/O Completion Ports are</span></span>
<span class="line" id="L1134"><span class="tok-comment">/// used to perform the I/O. `error.WouldBlock` is not possible on Windows.</span></span>
<span class="line" id="L1135"><span class="tok-comment">///</span></span>
<span class="line" id="L1136"><span class="tok-comment">/// Linux has a limit on how many bytes may be transferred in one `pwrite` call, which is `0x7ffff000`</span></span>
<span class="line" id="L1137"><span class="tok-comment">/// on both 64-bit and 32-bit systems. This is due to using a signed C int as the return value, as</span></span>
<span class="line" id="L1138"><span class="tok-comment">/// well as stuffing the errno codes into the last `4096` values. This is noted on the `write` man page.</span></span>
<span class="line" id="L1139"><span class="tok-comment">/// The limit on Darwin is `0x7fffffff`, trying to write more than that returns EINVAL.</span></span>
<span class="line" id="L1140"><span class="tok-comment">/// The corresponding POSIX limit is `math.maxInt(isize)`.</span></span>
<span class="line" id="L1141"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">pwrite</span>(fd: fd_t, bytes: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>, offset: <span class="tok-type">u64</span>) PWriteError!<span class="tok-type">usize</span> {</span>
<span class="line" id="L1142">    <span class="tok-kw">if</span> (builtin.os.tag == .windows) {</span>
<span class="line" id="L1143">        <span class="tok-kw">return</span> windows.WriteFile(fd, bytes, offset, std.io.default_mode);</span>
<span class="line" id="L1144">    }</span>
<span class="line" id="L1145">    <span class="tok-kw">if</span> (builtin.os.tag == .wasi <span class="tok-kw">and</span> !builtin.link_libc) {</span>
<span class="line" id="L1146">        <span class="tok-kw">const</span> ciovs = [<span class="tok-number">1</span>]iovec_const{iovec_const{</span>
<span class="line" id="L1147">            .iov_base = bytes.ptr,</span>
<span class="line" id="L1148">            .iov_len = bytes.len,</span>
<span class="line" id="L1149">        }};</span>
<span class="line" id="L1150"></span>
<span class="line" id="L1151">        <span class="tok-kw">var</span> nwritten: <span class="tok-type">usize</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L1152">        <span class="tok-kw">switch</span> (wasi.fd_pwrite(fd, &amp;ciovs, ciovs.len, offset, &amp;nwritten)) {</span>
<span class="line" id="L1153">            .SUCCESS =&gt; <span class="tok-kw">return</span> nwritten,</span>
<span class="line" id="L1154">            .INTR =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L1155">            .INVAL =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L1156">            .FAULT =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L1157">            .AGAIN =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L1158">            .BADF =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.NotOpenForWriting, <span class="tok-comment">// can be a race condition.</span>
</span>
<span class="line" id="L1159">            .DESTADDRREQ =&gt; <span class="tok-kw">unreachable</span>, <span class="tok-comment">// `connect` was never called.</span>
</span>
<span class="line" id="L1160">            .DQUOT =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.DiskQuota,</span>
<span class="line" id="L1161">            .FBIG =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.FileTooBig,</span>
<span class="line" id="L1162">            .IO =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.InputOutput,</span>
<span class="line" id="L1163">            .NOSPC =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.NoSpaceLeft,</span>
<span class="line" id="L1164">            .PERM =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.AccessDenied,</span>
<span class="line" id="L1165">            .PIPE =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.BrokenPipe,</span>
<span class="line" id="L1166">            .NXIO =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.Unseekable,</span>
<span class="line" id="L1167">            .SPIPE =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.Unseekable,</span>
<span class="line" id="L1168">            .OVERFLOW =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.Unseekable,</span>
<span class="line" id="L1169">            .NOTCAPABLE =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.AccessDenied,</span>
<span class="line" id="L1170">            <span class="tok-kw">else</span> =&gt; |err| <span class="tok-kw">return</span> unexpectedErrno(err),</span>
<span class="line" id="L1171">        }</span>
<span class="line" id="L1172">    }</span>
<span class="line" id="L1173"></span>
<span class="line" id="L1174">    <span class="tok-comment">// Prevent EINVAL.</span>
</span>
<span class="line" id="L1175">    <span class="tok-kw">const</span> max_count = <span class="tok-kw">switch</span> (builtin.os.tag) {</span>
<span class="line" id="L1176">        .linux =&gt; <span class="tok-number">0x7ffff000</span>,</span>
<span class="line" id="L1177">        .macos, .ios, .watchos, .tvos =&gt; math.maxInt(<span class="tok-type">i32</span>),</span>
<span class="line" id="L1178">        <span class="tok-kw">else</span> =&gt; math.maxInt(<span class="tok-type">isize</span>),</span>
<span class="line" id="L1179">    };</span>
<span class="line" id="L1180">    <span class="tok-kw">const</span> adjusted_len = <span class="tok-builtin">@minimum</span>(max_count, bytes.len);</span>
<span class="line" id="L1181"></span>
<span class="line" id="L1182">    <span class="tok-kw">const</span> pwrite_sym = <span class="tok-kw">if</span> (builtin.os.tag == .linux <span class="tok-kw">and</span> builtin.link_libc)</span>
<span class="line" id="L1183">        system.pwrite64</span>
<span class="line" id="L1184">    <span class="tok-kw">else</span></span>
<span class="line" id="L1185">        system.pwrite;</span>
<span class="line" id="L1186"></span>
<span class="line" id="L1187">    <span class="tok-kw">const</span> ioffset = <span class="tok-builtin">@bitCast</span>(<span class="tok-type">i64</span>, offset); <span class="tok-comment">// the OS treats this as unsigned</span>
</span>
<span class="line" id="L1188">    <span class="tok-kw">while</span> (<span class="tok-null">true</span>) {</span>
<span class="line" id="L1189">        <span class="tok-kw">const</span> rc = pwrite_sym(fd, bytes.ptr, adjusted_len, ioffset);</span>
<span class="line" id="L1190">        <span class="tok-kw">switch</span> (errno(rc)) {</span>
<span class="line" id="L1191">            .SUCCESS =&gt; <span class="tok-kw">return</span> <span class="tok-builtin">@intCast</span>(<span class="tok-type">usize</span>, rc),</span>
<span class="line" id="L1192">            .INTR =&gt; <span class="tok-kw">continue</span>,</span>
<span class="line" id="L1193">            .INVAL =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L1194">            .FAULT =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L1195">            .AGAIN =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.WouldBlock,</span>
<span class="line" id="L1196">            .BADF =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.NotOpenForWriting, <span class="tok-comment">// Can be a race condition.</span>
</span>
<span class="line" id="L1197">            .DESTADDRREQ =&gt; <span class="tok-kw">unreachable</span>, <span class="tok-comment">// `connect` was never called.</span>
</span>
<span class="line" id="L1198">            .DQUOT =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.DiskQuota,</span>
<span class="line" id="L1199">            .FBIG =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.FileTooBig,</span>
<span class="line" id="L1200">            .IO =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.InputOutput,</span>
<span class="line" id="L1201">            .NOSPC =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.NoSpaceLeft,</span>
<span class="line" id="L1202">            .PERM =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.AccessDenied,</span>
<span class="line" id="L1203">            .PIPE =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.BrokenPipe,</span>
<span class="line" id="L1204">            .NXIO =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.Unseekable,</span>
<span class="line" id="L1205">            .SPIPE =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.Unseekable,</span>
<span class="line" id="L1206">            .OVERFLOW =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.Unseekable,</span>
<span class="line" id="L1207">            <span class="tok-kw">else</span> =&gt; |err| <span class="tok-kw">return</span> unexpectedErrno(err),</span>
<span class="line" id="L1208">        }</span>
<span class="line" id="L1209">    }</span>
<span class="line" id="L1210">}</span>
<span class="line" id="L1211"></span>
<span class="line" id="L1212"><span class="tok-comment">/// Write multiple buffers to a file descriptor, with a position offset.</span></span>
<span class="line" id="L1213"><span class="tok-comment">/// Retries when interrupted by a signal.</span></span>
<span class="line" id="L1214"><span class="tok-comment">/// Returns the number of bytes written. If nonzero bytes were supplied, this will be nonzero.</span></span>
<span class="line" id="L1215"><span class="tok-comment">///</span></span>
<span class="line" id="L1216"><span class="tok-comment">/// Note that a successful write() may transfer fewer than count bytes.  Such partial  writes  can</span></span>
<span class="line" id="L1217"><span class="tok-comment">/// occur  for  various reasons; for example, because there was insufficient space on the disk</span></span>
<span class="line" id="L1218"><span class="tok-comment">/// device to write all of the requested bytes, or because a blocked write() to a socket,  pipe,  or</span></span>
<span class="line" id="L1219"><span class="tok-comment">/// similar  was  interrupted by a signal handler after it had transferred some, but before it had</span></span>
<span class="line" id="L1220"><span class="tok-comment">/// transferred all of the requested bytes.  In the event of a partial write, the caller can  make</span></span>
<span class="line" id="L1221"><span class="tok-comment">/// another  write() call to transfer the remaining bytes.  The subsequent call will either</span></span>
<span class="line" id="L1222"><span class="tok-comment">/// transfer further bytes or may result in an error (e.g., if the disk is now full).</span></span>
<span class="line" id="L1223"><span class="tok-comment">///</span></span>
<span class="line" id="L1224"><span class="tok-comment">/// If `fd` is opened in non blocking mode, the function will</span></span>
<span class="line" id="L1225"><span class="tok-comment">/// return error.WouldBlock when EAGAIN is received.</span></span>
<span class="line" id="L1226"><span class="tok-comment">///</span></span>
<span class="line" id="L1227"><span class="tok-comment">/// The following systems do not have this syscall, and will return partial writes if more than one</span></span>
<span class="line" id="L1228"><span class="tok-comment">/// vector is provided:</span></span>
<span class="line" id="L1229"><span class="tok-comment">/// * Darwin</span></span>
<span class="line" id="L1230"><span class="tok-comment">/// * Windows</span></span>
<span class="line" id="L1231"><span class="tok-comment">///</span></span>
<span class="line" id="L1232"><span class="tok-comment">/// If `iov.len` is larger than `IOV_MAX`, a partial write will occur.</span></span>
<span class="line" id="L1233"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">pwritev</span>(fd: fd_t, iov: []<span class="tok-kw">const</span> iovec_const, offset: <span class="tok-type">u64</span>) PWriteError!<span class="tok-type">usize</span> {</span>
<span class="line" id="L1234">    <span class="tok-kw">const</span> have_pwrite_but_not_pwritev = <span class="tok-kw">switch</span> (builtin.os.tag) {</span>
<span class="line" id="L1235">        .windows, .macos, .ios, .watchos, .tvos, .haiku =&gt; <span class="tok-null">true</span>,</span>
<span class="line" id="L1236">        <span class="tok-kw">else</span> =&gt; <span class="tok-null">false</span>,</span>
<span class="line" id="L1237">    };</span>
<span class="line" id="L1238"></span>
<span class="line" id="L1239">    <span class="tok-kw">if</span> (have_pwrite_but_not_pwritev) {</span>
<span class="line" id="L1240">        <span class="tok-comment">// We could loop here; but proper usage of `pwritev` must handle partial writes anyway.</span>
</span>
<span class="line" id="L1241">        <span class="tok-comment">// So we simply write the first vector only.</span>
</span>
<span class="line" id="L1242">        <span class="tok-kw">if</span> (iov.len == <span class="tok-number">0</span>) <span class="tok-kw">return</span> <span class="tok-builtin">@as</span>(<span class="tok-type">usize</span>, <span class="tok-number">0</span>);</span>
<span class="line" id="L1243">        <span class="tok-kw">const</span> first = iov[<span class="tok-number">0</span>];</span>
<span class="line" id="L1244">        <span class="tok-kw">return</span> pwrite(fd, first.iov_base[<span class="tok-number">0</span>..first.iov_len], offset);</span>
<span class="line" id="L1245">    }</span>
<span class="line" id="L1246">    <span class="tok-kw">if</span> (builtin.os.tag == .wasi <span class="tok-kw">and</span> !builtin.link_libc) {</span>
<span class="line" id="L1247">        <span class="tok-kw">var</span> nwritten: <span class="tok-type">usize</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L1248">        <span class="tok-kw">switch</span> (wasi.fd_pwrite(fd, iov.ptr, iov.len, offset, &amp;nwritten)) {</span>
<span class="line" id="L1249">            .SUCCESS =&gt; <span class="tok-kw">return</span> nwritten,</span>
<span class="line" id="L1250">            .INTR =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L1251">            .INVAL =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L1252">            .FAULT =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L1253">            .AGAIN =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L1254">            .BADF =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.NotOpenForWriting, <span class="tok-comment">// Can be a race condition.</span>
</span>
<span class="line" id="L1255">            .DESTADDRREQ =&gt; <span class="tok-kw">unreachable</span>, <span class="tok-comment">// `connect` was never called.</span>
</span>
<span class="line" id="L1256">            .DQUOT =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.DiskQuota,</span>
<span class="line" id="L1257">            .FBIG =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.FileTooBig,</span>
<span class="line" id="L1258">            .IO =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.InputOutput,</span>
<span class="line" id="L1259">            .NOSPC =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.NoSpaceLeft,</span>
<span class="line" id="L1260">            .PERM =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.AccessDenied,</span>
<span class="line" id="L1261">            .PIPE =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.BrokenPipe,</span>
<span class="line" id="L1262">            .NXIO =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.Unseekable,</span>
<span class="line" id="L1263">            .SPIPE =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.Unseekable,</span>
<span class="line" id="L1264">            .OVERFLOW =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.Unseekable,</span>
<span class="line" id="L1265">            .NOTCAPABLE =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.AccessDenied,</span>
<span class="line" id="L1266">            <span class="tok-kw">else</span> =&gt; |err| <span class="tok-kw">return</span> unexpectedErrno(err),</span>
<span class="line" id="L1267">        }</span>
<span class="line" id="L1268">    }</span>
<span class="line" id="L1269"></span>
<span class="line" id="L1270">    <span class="tok-kw">const</span> pwritev_sym = <span class="tok-kw">if</span> (builtin.os.tag == .linux <span class="tok-kw">and</span> builtin.link_libc)</span>
<span class="line" id="L1271">        system.pwritev64</span>
<span class="line" id="L1272">    <span class="tok-kw">else</span></span>
<span class="line" id="L1273">        system.pwritev;</span>
<span class="line" id="L1274"></span>
<span class="line" id="L1275">    <span class="tok-kw">const</span> iov_count = <span class="tok-kw">if</span> (iov.len &gt; IOV_MAX) IOV_MAX <span class="tok-kw">else</span> <span class="tok-builtin">@intCast</span>(<span class="tok-type">u31</span>, iov.len);</span>
<span class="line" id="L1276">    <span class="tok-kw">const</span> ioffset = <span class="tok-builtin">@bitCast</span>(<span class="tok-type">i64</span>, offset); <span class="tok-comment">// the OS treats this as unsigned</span>
</span>
<span class="line" id="L1277">    <span class="tok-kw">while</span> (<span class="tok-null">true</span>) {</span>
<span class="line" id="L1278">        <span class="tok-kw">const</span> rc = pwritev_sym(fd, iov.ptr, iov_count, ioffset);</span>
<span class="line" id="L1279">        <span class="tok-kw">switch</span> (errno(rc)) {</span>
<span class="line" id="L1280">            .SUCCESS =&gt; <span class="tok-kw">return</span> <span class="tok-builtin">@intCast</span>(<span class="tok-type">usize</span>, rc),</span>
<span class="line" id="L1281">            .INTR =&gt; <span class="tok-kw">continue</span>,</span>
<span class="line" id="L1282">            .INVAL =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L1283">            .FAULT =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L1284">            .AGAIN =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.WouldBlock,</span>
<span class="line" id="L1285">            .BADF =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.NotOpenForWriting, <span class="tok-comment">// Can be a race condition.</span>
</span>
<span class="line" id="L1286">            .DESTADDRREQ =&gt; <span class="tok-kw">unreachable</span>, <span class="tok-comment">// `connect` was never called.</span>
</span>
<span class="line" id="L1287">            .DQUOT =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.DiskQuota,</span>
<span class="line" id="L1288">            .FBIG =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.FileTooBig,</span>
<span class="line" id="L1289">            .IO =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.InputOutput,</span>
<span class="line" id="L1290">            .NOSPC =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.NoSpaceLeft,</span>
<span class="line" id="L1291">            .PERM =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.AccessDenied,</span>
<span class="line" id="L1292">            .PIPE =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.BrokenPipe,</span>
<span class="line" id="L1293">            .NXIO =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.Unseekable,</span>
<span class="line" id="L1294">            .SPIPE =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.Unseekable,</span>
<span class="line" id="L1295">            .OVERFLOW =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.Unseekable,</span>
<span class="line" id="L1296">            <span class="tok-kw">else</span> =&gt; |err| <span class="tok-kw">return</span> unexpectedErrno(err),</span>
<span class="line" id="L1297">        }</span>
<span class="line" id="L1298">    }</span>
<span class="line" id="L1299">}</span>
<span class="line" id="L1300"></span>
<span class="line" id="L1301"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> OpenError = <span class="tok-kw">error</span>{</span>
<span class="line" id="L1302">    <span class="tok-comment">/// In WASI, this error may occur when the provided file handle is invalid.</span></span>
<span class="line" id="L1303">    InvalidHandle,</span>
<span class="line" id="L1304"></span>
<span class="line" id="L1305">    <span class="tok-comment">/// In WASI, this error may occur when the file descriptor does</span></span>
<span class="line" id="L1306">    <span class="tok-comment">/// not hold the required rights to open a new resource relative to it.</span></span>
<span class="line" id="L1307">    AccessDenied,</span>
<span class="line" id="L1308">    SymLinkLoop,</span>
<span class="line" id="L1309">    ProcessFdQuotaExceeded,</span>
<span class="line" id="L1310">    SystemFdQuotaExceeded,</span>
<span class="line" id="L1311">    NoDevice,</span>
<span class="line" id="L1312">    FileNotFound,</span>
<span class="line" id="L1313"></span>
<span class="line" id="L1314">    <span class="tok-comment">/// The path exceeded `MAX_PATH_BYTES` bytes.</span></span>
<span class="line" id="L1315">    NameTooLong,</span>
<span class="line" id="L1316"></span>
<span class="line" id="L1317">    <span class="tok-comment">/// Insufficient kernel memory was available, or</span></span>
<span class="line" id="L1318">    <span class="tok-comment">/// the named file is a FIFO and per-user hard limit on</span></span>
<span class="line" id="L1319">    <span class="tok-comment">/// memory allocation for pipes has been reached.</span></span>
<span class="line" id="L1320">    SystemResources,</span>
<span class="line" id="L1321"></span>
<span class="line" id="L1322">    <span class="tok-comment">/// The file is too large to be opened. This error is unreachable</span></span>
<span class="line" id="L1323">    <span class="tok-comment">/// for 64-bit targets, as well as when opening directories.</span></span>
<span class="line" id="L1324">    FileTooBig,</span>
<span class="line" id="L1325"></span>
<span class="line" id="L1326">    <span class="tok-comment">/// The path refers to directory but the `O.DIRECTORY` flag was not provided.</span></span>
<span class="line" id="L1327">    IsDir,</span>
<span class="line" id="L1328"></span>
<span class="line" id="L1329">    <span class="tok-comment">/// A new path cannot be created because the device has no room for the new file.</span></span>
<span class="line" id="L1330">    <span class="tok-comment">/// This error is only reachable when the `O.CREAT` flag is provided.</span></span>
<span class="line" id="L1331">    NoSpaceLeft,</span>
<span class="line" id="L1332"></span>
<span class="line" id="L1333">    <span class="tok-comment">/// A component used as a directory in the path was not, in fact, a directory, or</span></span>
<span class="line" id="L1334">    <span class="tok-comment">/// `O.DIRECTORY` was specified and the path was not a directory.</span></span>
<span class="line" id="L1335">    NotDir,</span>
<span class="line" id="L1336"></span>
<span class="line" id="L1337">    <span class="tok-comment">/// The path already exists and the `O.CREAT` and `O.EXCL` flags were provided.</span></span>
<span class="line" id="L1338">    PathAlreadyExists,</span>
<span class="line" id="L1339">    DeviceBusy,</span>
<span class="line" id="L1340"></span>
<span class="line" id="L1341">    <span class="tok-comment">/// The underlying filesystem does not support file locks</span></span>
<span class="line" id="L1342">    FileLocksNotSupported,</span>
<span class="line" id="L1343"></span>
<span class="line" id="L1344">    BadPathName,</span>
<span class="line" id="L1345">    InvalidUtf8,</span>
<span class="line" id="L1346"></span>
<span class="line" id="L1347">    <span class="tok-comment">/// One of these three things:</span></span>
<span class="line" id="L1348">    <span class="tok-comment">/// * pathname  refers to an executable image which is currently being</span></span>
<span class="line" id="L1349">    <span class="tok-comment">///   executed and write access was requested.</span></span>
<span class="line" id="L1350">    <span class="tok-comment">/// * pathname refers to a file that is currently in  use  as  a  swap</span></span>
<span class="line" id="L1351">    <span class="tok-comment">///   file, and the O_TRUNC flag was specified.</span></span>
<span class="line" id="L1352">    <span class="tok-comment">/// * pathname  refers  to  a file that is currently being read by the</span></span>
<span class="line" id="L1353">    <span class="tok-comment">///   kernel (e.g., for module/firmware loading), and write access was</span></span>
<span class="line" id="L1354">    <span class="tok-comment">///   requested.</span></span>
<span class="line" id="L1355">    FileBusy,</span>
<span class="line" id="L1356"></span>
<span class="line" id="L1357">    WouldBlock,</span>
<span class="line" id="L1358">} || UnexpectedError;</span>
<span class="line" id="L1359"></span>
<span class="line" id="L1360"><span class="tok-comment">/// Open and possibly create a file. Keeps trying if it gets interrupted.</span></span>
<span class="line" id="L1361"><span class="tok-comment">/// See also `openZ`.</span></span>
<span class="line" id="L1362"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">open</span>(file_path: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>, flags: <span class="tok-type">u32</span>, perm: mode_t) OpenError!fd_t {</span>
<span class="line" id="L1363">    <span class="tok-kw">if</span> (builtin.os.tag == .windows) {</span>
<span class="line" id="L1364">        <span class="tok-kw">const</span> file_path_w = <span class="tok-kw">try</span> windows.sliceToPrefixedFileW(file_path);</span>
<span class="line" id="L1365">        <span class="tok-kw">return</span> openW(file_path_w.span(), flags, perm);</span>
<span class="line" id="L1366">    } <span class="tok-kw">else</span> <span class="tok-kw">if</span> (builtin.os.tag == .wasi <span class="tok-kw">and</span> !builtin.link_libc) {</span>
<span class="line" id="L1367">        <span class="tok-kw">return</span> openat(wasi.AT.FDCWD, file_path, flags, perm);</span>
<span class="line" id="L1368">    }</span>
<span class="line" id="L1369">    <span class="tok-kw">const</span> file_path_c = <span class="tok-kw">try</span> toPosixPath(file_path);</span>
<span class="line" id="L1370">    <span class="tok-kw">return</span> openZ(&amp;file_path_c, flags, perm);</span>
<span class="line" id="L1371">}</span>
<span class="line" id="L1372"></span>
<span class="line" id="L1373"><span class="tok-comment">/// Open and possibly create a file. Keeps trying if it gets interrupted.</span></span>
<span class="line" id="L1374"><span class="tok-comment">/// See also `open`.</span></span>
<span class="line" id="L1375"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">openZ</span>(file_path: [*:<span class="tok-number">0</span>]<span class="tok-kw">const</span> <span class="tok-type">u8</span>, flags: <span class="tok-type">u32</span>, perm: mode_t) OpenError!fd_t {</span>
<span class="line" id="L1376">    <span class="tok-kw">if</span> (builtin.os.tag == .windows) {</span>
<span class="line" id="L1377">        <span class="tok-kw">const</span> file_path_w = <span class="tok-kw">try</span> windows.cStrToPrefixedFileW(file_path);</span>
<span class="line" id="L1378">        <span class="tok-kw">return</span> openW(file_path_w.span(), flags, perm);</span>
<span class="line" id="L1379">    } <span class="tok-kw">else</span> <span class="tok-kw">if</span> (builtin.os.tag == .wasi <span class="tok-kw">and</span> !builtin.link_libc) {</span>
<span class="line" id="L1380">        <span class="tok-kw">return</span> open(mem.sliceTo(file_path, <span class="tok-number">0</span>), flags, perm);</span>
<span class="line" id="L1381">    }</span>
<span class="line" id="L1382"></span>
<span class="line" id="L1383">    <span class="tok-kw">const</span> open_sym = <span class="tok-kw">if</span> (builtin.os.tag == .linux <span class="tok-kw">and</span> builtin.link_libc)</span>
<span class="line" id="L1384">        system.open64</span>
<span class="line" id="L1385">    <span class="tok-kw">else</span></span>
<span class="line" id="L1386">        system.open;</span>
<span class="line" id="L1387"></span>
<span class="line" id="L1388">    <span class="tok-kw">while</span> (<span class="tok-null">true</span>) {</span>
<span class="line" id="L1389">        <span class="tok-kw">const</span> rc = open_sym(file_path, flags, perm);</span>
<span class="line" id="L1390">        <span class="tok-kw">switch</span> (errno(rc)) {</span>
<span class="line" id="L1391">            .SUCCESS =&gt; <span class="tok-kw">return</span> <span class="tok-builtin">@intCast</span>(fd_t, rc),</span>
<span class="line" id="L1392">            .INTR =&gt; <span class="tok-kw">continue</span>,</span>
<span class="line" id="L1393"></span>
<span class="line" id="L1394">            .FAULT =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L1395">            .INVAL =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L1396">            .ACCES =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.AccessDenied,</span>
<span class="line" id="L1397">            .FBIG =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.FileTooBig,</span>
<span class="line" id="L1398">            .OVERFLOW =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.FileTooBig,</span>
<span class="line" id="L1399">            .ISDIR =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.IsDir,</span>
<span class="line" id="L1400">            .LOOP =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.SymLinkLoop,</span>
<span class="line" id="L1401">            .MFILE =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.ProcessFdQuotaExceeded,</span>
<span class="line" id="L1402">            .NAMETOOLONG =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.NameTooLong,</span>
<span class="line" id="L1403">            .NFILE =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.SystemFdQuotaExceeded,</span>
<span class="line" id="L1404">            .NODEV =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.NoDevice,</span>
<span class="line" id="L1405">            .NOENT =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.FileNotFound,</span>
<span class="line" id="L1406">            .NOMEM =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.SystemResources,</span>
<span class="line" id="L1407">            .NOSPC =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.NoSpaceLeft,</span>
<span class="line" id="L1408">            .NOTDIR =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.NotDir,</span>
<span class="line" id="L1409">            .PERM =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.AccessDenied,</span>
<span class="line" id="L1410">            .EXIST =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.PathAlreadyExists,</span>
<span class="line" id="L1411">            .BUSY =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.DeviceBusy,</span>
<span class="line" id="L1412">            <span class="tok-kw">else</span> =&gt; |err| <span class="tok-kw">return</span> unexpectedErrno(err),</span>
<span class="line" id="L1413">        }</span>
<span class="line" id="L1414">    }</span>
<span class="line" id="L1415">}</span>
<span class="line" id="L1416"></span>
<span class="line" id="L1417"><span class="tok-kw">fn</span> <span class="tok-fn">openOptionsFromFlagsWindows</span>(flags: <span class="tok-type">u32</span>) windows.OpenFileOptions {</span>
<span class="line" id="L1418">    <span class="tok-kw">const</span> w = windows;</span>
<span class="line" id="L1419"></span>
<span class="line" id="L1420">    <span class="tok-kw">var</span> access_mask: w.ULONG = w.READ_CONTROL | w.FILE_WRITE_ATTRIBUTES | w.SYNCHRONIZE;</span>
<span class="line" id="L1421">    <span class="tok-kw">if</span> (flags &amp; O.RDWR != <span class="tok-number">0</span>) {</span>
<span class="line" id="L1422">        access_mask |= w.GENERIC_READ | w.GENERIC_WRITE;</span>
<span class="line" id="L1423">    } <span class="tok-kw">else</span> <span class="tok-kw">if</span> (flags &amp; O.WRONLY != <span class="tok-number">0</span>) {</span>
<span class="line" id="L1424">        access_mask |= w.GENERIC_WRITE;</span>
<span class="line" id="L1425">    } <span class="tok-kw">else</span> {</span>
<span class="line" id="L1426">        access_mask |= w.GENERIC_READ | w.GENERIC_WRITE;</span>
<span class="line" id="L1427">    }</span>
<span class="line" id="L1428"></span>
<span class="line" id="L1429">    <span class="tok-kw">const</span> filter: windows.OpenFileOptions.Filter = <span class="tok-kw">if</span> (flags &amp; O.DIRECTORY != <span class="tok-number">0</span>) .dir_only <span class="tok-kw">else</span> .file_only;</span>
<span class="line" id="L1430">    <span class="tok-kw">const</span> follow_symlinks: <span class="tok-type">bool</span> = flags &amp; O.NOFOLLOW == <span class="tok-number">0</span>;</span>
<span class="line" id="L1431"></span>
<span class="line" id="L1432">    <span class="tok-kw">const</span> creation: w.ULONG = blk: {</span>
<span class="line" id="L1433">        <span class="tok-kw">if</span> (flags &amp; O.CREAT != <span class="tok-number">0</span>) {</span>
<span class="line" id="L1434">            <span class="tok-kw">if</span> (flags &amp; O.EXCL != <span class="tok-number">0</span>) {</span>
<span class="line" id="L1435">                <span class="tok-kw">break</span> :blk w.FILE_CREATE;</span>
<span class="line" id="L1436">            }</span>
<span class="line" id="L1437">        }</span>
<span class="line" id="L1438">        <span class="tok-kw">break</span> :blk w.FILE_OPEN;</span>
<span class="line" id="L1439">    };</span>
<span class="line" id="L1440"></span>
<span class="line" id="L1441">    <span class="tok-kw">return</span> .{</span>
<span class="line" id="L1442">        .access_mask = access_mask,</span>
<span class="line" id="L1443">        .io_mode = .blocking,</span>
<span class="line" id="L1444">        .creation = creation,</span>
<span class="line" id="L1445">        .filter = filter,</span>
<span class="line" id="L1446">        .follow_symlinks = follow_symlinks,</span>
<span class="line" id="L1447">    };</span>
<span class="line" id="L1448">}</span>
<span class="line" id="L1449"></span>
<span class="line" id="L1450"><span class="tok-comment">/// Windows-only. The path parameter is</span></span>
<span class="line" id="L1451"><span class="tok-comment">/// [WTF-16](https://simonsapin.github.io/wtf-8/#potentially-ill-formed-utf-16) encoded.</span></span>
<span class="line" id="L1452"><span class="tok-comment">/// Translates the POSIX open API call to a Windows API call.</span></span>
<span class="line" id="L1453"><span class="tok-comment">/// TODO currently, this function does not handle all flag combinations</span></span>
<span class="line" id="L1454"><span class="tok-comment">/// or makes use of perm argument.</span></span>
<span class="line" id="L1455"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">openW</span>(file_path_w: []<span class="tok-kw">const</span> <span class="tok-type">u16</span>, flags: <span class="tok-type">u32</span>, perm: mode_t) OpenError!fd_t {</span>
<span class="line" id="L1456">    _ = perm;</span>
<span class="line" id="L1457">    <span class="tok-kw">var</span> options = openOptionsFromFlagsWindows(flags);</span>
<span class="line" id="L1458">    options.dir = std.fs.cwd().fd;</span>
<span class="line" id="L1459">    <span class="tok-kw">return</span> windows.OpenFile(file_path_w, options) <span class="tok-kw">catch</span> |err| <span class="tok-kw">switch</span> (err) {</span>
<span class="line" id="L1460">        <span class="tok-kw">error</span>.WouldBlock =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L1461">        <span class="tok-kw">error</span>.PipeBusy =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L1462">        <span class="tok-kw">else</span> =&gt; |e| <span class="tok-kw">return</span> e,</span>
<span class="line" id="L1463">    };</span>
<span class="line" id="L1464">}</span>
<span class="line" id="L1465"></span>
<span class="line" id="L1466"><span class="tok-kw">var</span> wasi_cwd = <span class="tok-kw">if</span> (builtin.os.tag == .wasi <span class="tok-kw">and</span> !builtin.link_libc) <span class="tok-kw">struct</span> {</span>
<span class="line" id="L1467">    <span class="tok-comment">// List of available Preopens</span>
</span>
<span class="line" id="L1468">    preopens: ?PreopenList = <span class="tok-null">null</span>,</span>
<span class="line" id="L1469">    <span class="tok-comment">// Memory buffer for storing the relative portion of the CWD</span>
</span>
<span class="line" id="L1470">    path_buffer: [MAX_PATH_BYTES]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>,</span>
<span class="line" id="L1471">    <span class="tok-comment">// The absolute path associated with the current working directory</span>
</span>
<span class="line" id="L1472">    cwd: []<span class="tok-kw">const</span> <span class="tok-type">u8</span> = <span class="tok-str">&quot;/&quot;</span>,</span>
<span class="line" id="L1473">}{} <span class="tok-kw">else</span> <span class="tok-null">undefined</span>;</span>
<span class="line" id="L1474"></span>
<span class="line" id="L1475"><span class="tok-comment">/// Initialize the available Preopen list on WASI and set the CWD to `cwd_init`.</span></span>
<span class="line" id="L1476"><span class="tok-comment">/// Note that `cwd_init` corresponds to a Preopen directory, not necessarily</span></span>
<span class="line" id="L1477"><span class="tok-comment">/// a POSIX path. For example, &quot;.&quot; matches a Preopen provided with `--dir=.`</span></span>
<span class="line" id="L1478"><span class="tok-comment">///</span></span>
<span class="line" id="L1479"><span class="tok-comment">/// This must be called before using any relative or absolute paths with `std.os`</span></span>
<span class="line" id="L1480"><span class="tok-comment">/// functions, if you are on WASI without linking libc.</span></span>
<span class="line" id="L1481"><span class="tok-comment">///</span></span>
<span class="line" id="L1482"><span class="tok-comment">/// The current working directory is initialized to `cwd_root`, and `cwd_root`</span></span>
<span class="line" id="L1483"><span class="tok-comment">/// is inserted as a prefix for any Preopens whose dir begins with &quot;.&quot;</span></span>
<span class="line" id="L1484"><span class="tok-comment">///   For example:</span></span>
<span class="line" id="L1485"><span class="tok-comment">///      &quot;./foo/bar&quot; - canonicalizes to -&gt; &quot;{cwd_root}/foo/bar&quot;</span></span>
<span class="line" id="L1486"><span class="tok-comment">///      &quot;foo/bar&quot;   - canonicalizes to -&gt; &quot;/foo/bar&quot;</span></span>
<span class="line" id="L1487"><span class="tok-comment">///      &quot;/foo/bar&quot;  - canonicalizes to -&gt; &quot;/foo/bar&quot;</span></span>
<span class="line" id="L1488"><span class="tok-comment">///</span></span>
<span class="line" id="L1489"><span class="tok-comment">/// `cwd_root` must be an absolute path. For initialization behavior similar to</span></span>
<span class="line" id="L1490"><span class="tok-comment">/// wasi-libc, use &quot;/&quot; as the `cwd_root`</span></span>
<span class="line" id="L1491"><span class="tok-comment">///</span></span>
<span class="line" id="L1492"><span class="tok-comment">/// `alloc` must not be a temporary or leak-detecting allocator, since `std.os`</span></span>
<span class="line" id="L1493"><span class="tok-comment">/// retains ownership of allocations internally and may never call free().</span></span>
<span class="line" id="L1494"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">initPreopensWasi</span>(alloc: Allocator, cwd_root: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) !<span class="tok-type">void</span> {</span>
<span class="line" id="L1495">    <span class="tok-kw">if</span> (builtin.os.tag == .wasi) {</span>
<span class="line" id="L1496">        <span class="tok-kw">if</span> (!builtin.link_libc) {</span>
<span class="line" id="L1497">            <span class="tok-kw">var</span> preopen_list = PreopenList.init(alloc);</span>
<span class="line" id="L1498">            <span class="tok-kw">errdefer</span> preopen_list.deinit();</span>
<span class="line" id="L1499">            <span class="tok-kw">try</span> preopen_list.populate(cwd_root);</span>
<span class="line" id="L1500"></span>
<span class="line" id="L1501">            <span class="tok-kw">var</span> path_alloc = std.heap.FixedBufferAllocator.init(&amp;wasi_cwd.path_buffer);</span>
<span class="line" id="L1502">            wasi_cwd.cwd = <span class="tok-kw">try</span> path_alloc.allocator().dupe(<span class="tok-type">u8</span>, cwd_root);</span>
<span class="line" id="L1503"></span>
<span class="line" id="L1504">            <span class="tok-kw">if</span> (wasi_cwd.preopens) |preopens| preopens.deinit();</span>
<span class="line" id="L1505">            wasi_cwd.preopens = preopen_list;</span>
<span class="line" id="L1506">        } <span class="tok-kw">else</span> {</span>
<span class="line" id="L1507">            <span class="tok-comment">// wasi-libc defaults to an effective CWD root of &quot;/&quot;</span>
</span>
<span class="line" id="L1508">            <span class="tok-kw">if</span> (!mem.eql(<span class="tok-type">u8</span>, cwd_root, <span class="tok-str">&quot;/&quot;</span>)) <span class="tok-kw">return</span> <span class="tok-kw">error</span>.UnsupportedDirectory;</span>
<span class="line" id="L1509">        }</span>
<span class="line" id="L1510">    }</span>
<span class="line" id="L1511">}</span>
<span class="line" id="L1512"></span>
<span class="line" id="L1513"><span class="tok-comment">/// Resolve a relative or absolute path to an handle (`fd_t`) and a relative subpath.</span></span>
<span class="line" id="L1514"><span class="tok-comment">///</span></span>
<span class="line" id="L1515"><span class="tok-comment">/// For absolute paths, this automatically searches among available Preopens to find</span></span>
<span class="line" id="L1516"><span class="tok-comment">/// a match. For relative paths, it uses the &quot;emulated&quot; CWD.</span></span>
<span class="line" id="L1517"><span class="tok-comment">/// Automatically looks up the correct Preopen corresponding to the provided path.</span></span>
<span class="line" id="L1518"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">resolvePathWasi</span>(path: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>, out_buffer: *[MAX_PATH_BYTES]<span class="tok-type">u8</span>) !RelativePathWasi {</span>
<span class="line" id="L1519">    <span class="tok-kw">var</span> allocator = std.heap.FixedBufferAllocator.init(out_buffer);</span>
<span class="line" id="L1520">    <span class="tok-kw">var</span> alloc = allocator.allocator();</span>
<span class="line" id="L1521"></span>
<span class="line" id="L1522">    <span class="tok-kw">const</span> abs_path = fs.path.resolve(alloc, &amp;.{ wasi_cwd.cwd, path }) <span class="tok-kw">catch</span> <span class="tok-kw">return</span> <span class="tok-kw">error</span>.NameTooLong;</span>
<span class="line" id="L1523">    <span class="tok-kw">const</span> preopen_uri = wasi_cwd.preopens.?.findContaining(.{ .Dir = abs_path });</span>
<span class="line" id="L1524"></span>
<span class="line" id="L1525">    <span class="tok-kw">if</span> (preopen_uri) |po| {</span>
<span class="line" id="L1526">        <span class="tok-kw">return</span> RelativePathWasi{</span>
<span class="line" id="L1527">            .dir_fd = po.base.fd,</span>
<span class="line" id="L1528">            .relative_path = po.relative_path,</span>
<span class="line" id="L1529">        };</span>
<span class="line" id="L1530">    } <span class="tok-kw">else</span> {</span>
<span class="line" id="L1531">        <span class="tok-comment">// No matching preopen found</span>
</span>
<span class="line" id="L1532">        <span class="tok-kw">return</span> <span class="tok-kw">error</span>.AccessDenied;</span>
<span class="line" id="L1533">    }</span>
<span class="line" id="L1534">}</span>
<span class="line" id="L1535"></span>
<span class="line" id="L1536"><span class="tok-comment">/// Open and possibly create a file. Keeps trying if it gets interrupted.</span></span>
<span class="line" id="L1537"><span class="tok-comment">/// `file_path` is relative to the open directory handle `dir_fd`.</span></span>
<span class="line" id="L1538"><span class="tok-comment">/// See also `openatZ`.</span></span>
<span class="line" id="L1539"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">openat</span>(dir_fd: fd_t, file_path: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>, flags: <span class="tok-type">u32</span>, mode: mode_t) OpenError!fd_t {</span>
<span class="line" id="L1540">    <span class="tok-kw">if</span> (builtin.os.tag == .windows) {</span>
<span class="line" id="L1541">        <span class="tok-kw">const</span> file_path_w = <span class="tok-kw">try</span> windows.sliceToPrefixedFileW(file_path);</span>
<span class="line" id="L1542">        <span class="tok-kw">return</span> openatW(dir_fd, file_path_w.span(), flags, mode);</span>
<span class="line" id="L1543">    } <span class="tok-kw">else</span> <span class="tok-kw">if</span> (builtin.os.tag == .wasi <span class="tok-kw">and</span> !builtin.link_libc) {</span>
<span class="line" id="L1544">        <span class="tok-comment">// `mode` is ignored on WASI, which does not support unix-style file permissions</span>
</span>
<span class="line" id="L1545">        <span class="tok-kw">const</span> fd = <span class="tok-kw">if</span> (dir_fd == wasi.AT.FDCWD <span class="tok-kw">or</span> fs.path.isAbsolute(file_path)) blk: {</span>
<span class="line" id="L1546">            <span class="tok-comment">// Resolve absolute or CWD-relative paths to a path within a Preopen</span>
</span>
<span class="line" id="L1547">            <span class="tok-kw">var</span> path_buf: [MAX_PATH_BYTES]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L1548">            <span class="tok-kw">const</span> path = <span class="tok-kw">try</span> resolvePathWasi(file_path, &amp;path_buf);</span>
<span class="line" id="L1549"></span>
<span class="line" id="L1550">            <span class="tok-kw">const</span> opts = <span class="tok-kw">try</span> openOptionsFromFlagsWasi(path.dir_fd, flags);</span>
<span class="line" id="L1551">            <span class="tok-kw">break</span> :blk <span class="tok-kw">try</span> openatWasi(path.dir_fd, path.relative_path, opts.lookup_flags, opts.oflags, opts.fs_flags, opts.fs_rights_base, opts.fs_rights_inheriting);</span>
<span class="line" id="L1552">        } <span class="tok-kw">else</span> blk: {</span>
<span class="line" id="L1553">            <span class="tok-kw">const</span> opts = <span class="tok-kw">try</span> openOptionsFromFlagsWasi(dir_fd, flags);</span>
<span class="line" id="L1554">            <span class="tok-kw">break</span> :blk <span class="tok-kw">try</span> openatWasi(dir_fd, file_path, opts.lookup_flags, opts.oflags, opts.fs_flags, opts.fs_rights_base, opts.fs_rights_inheriting);</span>
<span class="line" id="L1555">        };</span>
<span class="line" id="L1556">        <span class="tok-kw">errdefer</span> close(fd);</span>
<span class="line" id="L1557"></span>
<span class="line" id="L1558">        <span class="tok-kw">const</span> info = <span class="tok-kw">try</span> fstat(fd);</span>
<span class="line" id="L1559">        <span class="tok-kw">if</span> (flags &amp; O.WRONLY != <span class="tok-number">0</span> <span class="tok-kw">and</span> info.filetype == .DIRECTORY)</span>
<span class="line" id="L1560">            <span class="tok-kw">return</span> <span class="tok-kw">error</span>.IsDir;</span>
<span class="line" id="L1561"></span>
<span class="line" id="L1562">        <span class="tok-kw">return</span> fd;</span>
<span class="line" id="L1563">    }</span>
<span class="line" id="L1564">    <span class="tok-kw">const</span> file_path_c = <span class="tok-kw">try</span> toPosixPath(file_path);</span>
<span class="line" id="L1565">    <span class="tok-kw">return</span> openatZ(dir_fd, &amp;file_path_c, flags, mode);</span>
<span class="line" id="L1566">}</span>
<span class="line" id="L1567"></span>
<span class="line" id="L1568"><span class="tok-comment">/// A struct to contain all lookup/rights flags accepted by `wasi.path_open`</span></span>
<span class="line" id="L1569"><span class="tok-kw">const</span> WasiOpenOptions = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L1570">    oflags: wasi.oflags_t,</span>
<span class="line" id="L1571">    lookup_flags: wasi.lookupflags_t,</span>
<span class="line" id="L1572">    fs_rights_base: wasi.rights_t,</span>
<span class="line" id="L1573">    fs_rights_inheriting: wasi.rights_t,</span>
<span class="line" id="L1574">    fs_flags: wasi.fdflags_t,</span>
<span class="line" id="L1575">};</span>
<span class="line" id="L1576"></span>
<span class="line" id="L1577"><span class="tok-comment">/// Compute rights + flags corresponding to the provided POSIX access mode.</span></span>
<span class="line" id="L1578"><span class="tok-kw">fn</span> <span class="tok-fn">openOptionsFromFlagsWasi</span>(fd: fd_t, oflag: <span class="tok-type">u32</span>) OpenError!WasiOpenOptions {</span>
<span class="line" id="L1579">    <span class="tok-kw">const</span> w = std.os.wasi;</span>
<span class="line" id="L1580"></span>
<span class="line" id="L1581">    <span class="tok-comment">// First, discover the rights that we can derive from `fd`</span>
</span>
<span class="line" id="L1582">    <span class="tok-kw">var</span> fsb_cur: wasi.fdstat_t = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L1583">    _ = <span class="tok-kw">switch</span> (w.fd_fdstat_get(fd, &amp;fsb_cur)) {</span>
<span class="line" id="L1584">        .SUCCESS =&gt; .{},</span>
<span class="line" id="L1585">        .BADF =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.InvalidHandle,</span>
<span class="line" id="L1586">        <span class="tok-kw">else</span> =&gt; |err| <span class="tok-kw">return</span> unexpectedErrno(err),</span>
<span class="line" id="L1587">    };</span>
<span class="line" id="L1588"></span>
<span class="line" id="L1589">    <span class="tok-comment">// Next, calculate the read/write rights to request, depending on the</span>
</span>
<span class="line" id="L1590">    <span class="tok-comment">// provided POSIX access mode</span>
</span>
<span class="line" id="L1591">    <span class="tok-kw">var</span> rights: w.rights_t = <span class="tok-number">0</span>;</span>
<span class="line" id="L1592">    <span class="tok-kw">if</span> (oflag &amp; O.RDONLY != <span class="tok-number">0</span>) {</span>
<span class="line" id="L1593">        rights |= w.RIGHT.FD_READ | w.RIGHT.FD_READDIR;</span>
<span class="line" id="L1594">    }</span>
<span class="line" id="L1595">    <span class="tok-kw">if</span> (oflag &amp; O.WRONLY != <span class="tok-number">0</span>) {</span>
<span class="line" id="L1596">        rights |= w.RIGHT.FD_DATASYNC | w.RIGHT.FD_WRITE |</span>
<span class="line" id="L1597">            w.RIGHT.FD_ALLOCATE | w.RIGHT.FD_FILESTAT_SET_SIZE;</span>
<span class="line" id="L1598">    }</span>
<span class="line" id="L1599"></span>
<span class="line" id="L1600">    <span class="tok-comment">// Request all other rights unconditionally</span>
</span>
<span class="line" id="L1601">    rights |= ~(w.RIGHT.FD_DATASYNC | w.RIGHT.FD_READ |</span>
<span class="line" id="L1602">        w.RIGHT.FD_WRITE | w.RIGHT.FD_ALLOCATE |</span>
<span class="line" id="L1603">        w.RIGHT.FD_READDIR | w.RIGHT.FD_FILESTAT_SET_SIZE);</span>
<span class="line" id="L1604"></span>
<span class="line" id="L1605">    <span class="tok-comment">// But only take rights that we can actually inherit</span>
</span>
<span class="line" id="L1606">    rights &amp;= fsb_cur.fs_rights_inheriting;</span>
<span class="line" id="L1607"></span>
<span class="line" id="L1608">    <span class="tok-kw">return</span> WasiOpenOptions{</span>
<span class="line" id="L1609">        .oflags = <span class="tok-builtin">@truncate</span>(w.oflags_t, (oflag &gt;&gt; <span class="tok-number">12</span>)) &amp; <span class="tok-number">0xfff</span>,</span>
<span class="line" id="L1610">        .lookup_flags = <span class="tok-kw">if</span> (oflag &amp; O.NOFOLLOW == <span class="tok-number">0</span>) w.LOOKUP_SYMLINK_FOLLOW <span class="tok-kw">else</span> <span class="tok-number">0</span>,</span>
<span class="line" id="L1611">        .fs_rights_base = rights,</span>
<span class="line" id="L1612">        .fs_rights_inheriting = fsb_cur.fs_rights_inheriting,</span>
<span class="line" id="L1613">        .fs_flags = <span class="tok-builtin">@truncate</span>(w.fdflags_t, oflag &amp; <span class="tok-number">0xfff</span>),</span>
<span class="line" id="L1614">    };</span>
<span class="line" id="L1615">}</span>
<span class="line" id="L1616"></span>
<span class="line" id="L1617"><span class="tok-comment">/// Open and possibly create a file in WASI.</span></span>
<span class="line" id="L1618"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">openatWasi</span>(dir_fd: fd_t, file_path: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>, lookup_flags: lookupflags_t, oflags: oflags_t, fdflags: fdflags_t, base: rights_t, inheriting: rights_t) OpenError!fd_t {</span>
<span class="line" id="L1619">    <span class="tok-kw">while</span> (<span class="tok-null">true</span>) {</span>
<span class="line" id="L1620">        <span class="tok-kw">var</span> fd: fd_t = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L1621">        <span class="tok-kw">switch</span> (wasi.path_open(dir_fd, lookup_flags, file_path.ptr, file_path.len, oflags, base, inheriting, fdflags, &amp;fd)) {</span>
<span class="line" id="L1622">            .SUCCESS =&gt; <span class="tok-kw">return</span> fd,</span>
<span class="line" id="L1623">            .INTR =&gt; <span class="tok-kw">continue</span>,</span>
<span class="line" id="L1624"></span>
<span class="line" id="L1625">            .FAULT =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L1626">            .INVAL =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L1627">            .ACCES =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.AccessDenied,</span>
<span class="line" id="L1628">            .FBIG =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.FileTooBig,</span>
<span class="line" id="L1629">            .OVERFLOW =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.FileTooBig,</span>
<span class="line" id="L1630">            .ISDIR =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.IsDir,</span>
<span class="line" id="L1631">            .LOOP =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.SymLinkLoop,</span>
<span class="line" id="L1632">            .MFILE =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.ProcessFdQuotaExceeded,</span>
<span class="line" id="L1633">            .NAMETOOLONG =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.NameTooLong,</span>
<span class="line" id="L1634">            .NFILE =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.SystemFdQuotaExceeded,</span>
<span class="line" id="L1635">            .NODEV =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.NoDevice,</span>
<span class="line" id="L1636">            .NOENT =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.FileNotFound,</span>
<span class="line" id="L1637">            .NOMEM =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.SystemResources,</span>
<span class="line" id="L1638">            .NOSPC =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.NoSpaceLeft,</span>
<span class="line" id="L1639">            .NOTDIR =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.NotDir,</span>
<span class="line" id="L1640">            .PERM =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.AccessDenied,</span>
<span class="line" id="L1641">            .EXIST =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.PathAlreadyExists,</span>
<span class="line" id="L1642">            .BUSY =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.DeviceBusy,</span>
<span class="line" id="L1643">            .NOTCAPABLE =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.AccessDenied,</span>
<span class="line" id="L1644">            <span class="tok-kw">else</span> =&gt; |err| <span class="tok-kw">return</span> unexpectedErrno(err),</span>
<span class="line" id="L1645">        }</span>
<span class="line" id="L1646">    }</span>
<span class="line" id="L1647">}</span>
<span class="line" id="L1648"></span>
<span class="line" id="L1649"><span class="tok-comment">/// Open and possibly create a file. Keeps trying if it gets interrupted.</span></span>
<span class="line" id="L1650"><span class="tok-comment">/// `file_path` is relative to the open directory handle `dir_fd`.</span></span>
<span class="line" id="L1651"><span class="tok-comment">/// See also `openat`.</span></span>
<span class="line" id="L1652"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">openatZ</span>(dir_fd: fd_t, file_path: [*:<span class="tok-number">0</span>]<span class="tok-kw">const</span> <span class="tok-type">u8</span>, flags: <span class="tok-type">u32</span>, mode: mode_t) OpenError!fd_t {</span>
<span class="line" id="L1653">    <span class="tok-kw">if</span> (builtin.os.tag == .windows) {</span>
<span class="line" id="L1654">        <span class="tok-kw">const</span> file_path_w = <span class="tok-kw">try</span> windows.cStrToPrefixedFileW(file_path);</span>
<span class="line" id="L1655">        <span class="tok-kw">return</span> openatW(dir_fd, file_path_w.span(), flags, mode);</span>
<span class="line" id="L1656">    } <span class="tok-kw">else</span> <span class="tok-kw">if</span> (builtin.os.tag == .wasi <span class="tok-kw">and</span> !builtin.link_libc) {</span>
<span class="line" id="L1657">        <span class="tok-kw">return</span> openat(dir_fd, mem.sliceTo(file_path, <span class="tok-number">0</span>), flags, mode);</span>
<span class="line" id="L1658">    }</span>
<span class="line" id="L1659"></span>
<span class="line" id="L1660">    <span class="tok-kw">const</span> openat_sym = <span class="tok-kw">if</span> (builtin.os.tag == .linux <span class="tok-kw">and</span> builtin.link_libc)</span>
<span class="line" id="L1661">        system.openat64</span>
<span class="line" id="L1662">    <span class="tok-kw">else</span></span>
<span class="line" id="L1663">        system.openat;</span>
<span class="line" id="L1664"></span>
<span class="line" id="L1665">    <span class="tok-kw">while</span> (<span class="tok-null">true</span>) {</span>
<span class="line" id="L1666">        <span class="tok-kw">const</span> rc = openat_sym(dir_fd, file_path, flags, mode);</span>
<span class="line" id="L1667">        <span class="tok-kw">switch</span> (errno(rc)) {</span>
<span class="line" id="L1668">            .SUCCESS =&gt; <span class="tok-kw">return</span> <span class="tok-builtin">@intCast</span>(fd_t, rc),</span>
<span class="line" id="L1669">            .INTR =&gt; <span class="tok-kw">continue</span>,</span>
<span class="line" id="L1670"></span>
<span class="line" id="L1671">            .FAULT =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L1672">            .INVAL =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L1673">            .BADF =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L1674">            .ACCES =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.AccessDenied,</span>
<span class="line" id="L1675">            .FBIG =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.FileTooBig,</span>
<span class="line" id="L1676">            .OVERFLOW =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.FileTooBig,</span>
<span class="line" id="L1677">            .ISDIR =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.IsDir,</span>
<span class="line" id="L1678">            .LOOP =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.SymLinkLoop,</span>
<span class="line" id="L1679">            .MFILE =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.ProcessFdQuotaExceeded,</span>
<span class="line" id="L1680">            .NAMETOOLONG =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.NameTooLong,</span>
<span class="line" id="L1681">            .NFILE =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.SystemFdQuotaExceeded,</span>
<span class="line" id="L1682">            .NODEV =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.NoDevice,</span>
<span class="line" id="L1683">            .NOENT =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.FileNotFound,</span>
<span class="line" id="L1684">            .NOMEM =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.SystemResources,</span>
<span class="line" id="L1685">            .NOSPC =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.NoSpaceLeft,</span>
<span class="line" id="L1686">            .NOTDIR =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.NotDir,</span>
<span class="line" id="L1687">            .PERM =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.AccessDenied,</span>
<span class="line" id="L1688">            .EXIST =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.PathAlreadyExists,</span>
<span class="line" id="L1689">            .BUSY =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.DeviceBusy,</span>
<span class="line" id="L1690">            .OPNOTSUPP =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.FileLocksNotSupported,</span>
<span class="line" id="L1691">            .AGAIN =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.WouldBlock,</span>
<span class="line" id="L1692">            .TXTBSY =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.FileBusy,</span>
<span class="line" id="L1693">            <span class="tok-kw">else</span> =&gt; |err| <span class="tok-kw">return</span> unexpectedErrno(err),</span>
<span class="line" id="L1694">        }</span>
<span class="line" id="L1695">    }</span>
<span class="line" id="L1696">}</span>
<span class="line" id="L1697"></span>
<span class="line" id="L1698"><span class="tok-comment">/// Windows-only. Similar to `openat` but with pathname argument null-terminated</span></span>
<span class="line" id="L1699"><span class="tok-comment">/// WTF16 encoded.</span></span>
<span class="line" id="L1700"><span class="tok-comment">/// TODO currently, this function does not handle all flag combinations</span></span>
<span class="line" id="L1701"><span class="tok-comment">/// or makes use of perm argument.</span></span>
<span class="line" id="L1702"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">openatW</span>(dir_fd: fd_t, file_path_w: []<span class="tok-kw">const</span> <span class="tok-type">u16</span>, flags: <span class="tok-type">u32</span>, mode: mode_t) OpenError!fd_t {</span>
<span class="line" id="L1703">    _ = mode;</span>
<span class="line" id="L1704">    <span class="tok-kw">var</span> options = openOptionsFromFlagsWindows(flags);</span>
<span class="line" id="L1705">    options.dir = dir_fd;</span>
<span class="line" id="L1706">    <span class="tok-kw">return</span> windows.OpenFile(file_path_w, options) <span class="tok-kw">catch</span> |err| <span class="tok-kw">switch</span> (err) {</span>
<span class="line" id="L1707">        <span class="tok-kw">error</span>.WouldBlock =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L1708">        <span class="tok-kw">error</span>.PipeBusy =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L1709">        <span class="tok-kw">else</span> =&gt; |e| <span class="tok-kw">return</span> e,</span>
<span class="line" id="L1710">    };</span>
<span class="line" id="L1711">}</span>
<span class="line" id="L1712"></span>
<span class="line" id="L1713"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">dup</span>(old_fd: fd_t) !fd_t {</span>
<span class="line" id="L1714">    <span class="tok-kw">const</span> rc = system.dup(old_fd);</span>
<span class="line" id="L1715">    <span class="tok-kw">return</span> <span class="tok-kw">switch</span> (errno(rc)) {</span>
<span class="line" id="L1716">        .SUCCESS =&gt; <span class="tok-kw">return</span> <span class="tok-builtin">@intCast</span>(fd_t, rc),</span>
<span class="line" id="L1717">        .MFILE =&gt; <span class="tok-kw">error</span>.ProcessFdQuotaExceeded,</span>
<span class="line" id="L1718">        .BADF =&gt; <span class="tok-kw">unreachable</span>, <span class="tok-comment">// invalid file descriptor</span>
</span>
<span class="line" id="L1719">        <span class="tok-kw">else</span> =&gt; |err| <span class="tok-kw">return</span> unexpectedErrno(err),</span>
<span class="line" id="L1720">    };</span>
<span class="line" id="L1721">}</span>
<span class="line" id="L1722"></span>
<span class="line" id="L1723"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">dup2</span>(old_fd: fd_t, new_fd: fd_t) !<span class="tok-type">void</span> {</span>
<span class="line" id="L1724">    <span class="tok-kw">while</span> (<span class="tok-null">true</span>) {</span>
<span class="line" id="L1725">        <span class="tok-kw">switch</span> (errno(system.dup2(old_fd, new_fd))) {</span>
<span class="line" id="L1726">            .SUCCESS =&gt; <span class="tok-kw">return</span>,</span>
<span class="line" id="L1727">            .BUSY, .INTR =&gt; <span class="tok-kw">continue</span>,</span>
<span class="line" id="L1728">            .MFILE =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.ProcessFdQuotaExceeded,</span>
<span class="line" id="L1729">            .INVAL =&gt; <span class="tok-kw">unreachable</span>, <span class="tok-comment">// invalid parameters passed to dup2</span>
</span>
<span class="line" id="L1730">            .BADF =&gt; <span class="tok-kw">unreachable</span>, <span class="tok-comment">// invalid file descriptor</span>
</span>
<span class="line" id="L1731">            <span class="tok-kw">else</span> =&gt; |err| <span class="tok-kw">return</span> unexpectedErrno(err),</span>
<span class="line" id="L1732">        }</span>
<span class="line" id="L1733">    }</span>
<span class="line" id="L1734">}</span>
<span class="line" id="L1735"></span>
<span class="line" id="L1736"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> ExecveError = <span class="tok-kw">error</span>{</span>
<span class="line" id="L1737">    SystemResources,</span>
<span class="line" id="L1738">    AccessDenied,</span>
<span class="line" id="L1739">    InvalidExe,</span>
<span class="line" id="L1740">    FileSystem,</span>
<span class="line" id="L1741">    IsDir,</span>
<span class="line" id="L1742">    FileNotFound,</span>
<span class="line" id="L1743">    NotDir,</span>
<span class="line" id="L1744">    FileBusy,</span>
<span class="line" id="L1745">    ProcessFdQuotaExceeded,</span>
<span class="line" id="L1746">    SystemFdQuotaExceeded,</span>
<span class="line" id="L1747">    NameTooLong,</span>
<span class="line" id="L1748">} || UnexpectedError;</span>
<span class="line" id="L1749"></span>
<span class="line" id="L1750"><span class="tok-comment">/// Like `execve` except the parameters are null-terminated,</span></span>
<span class="line" id="L1751"><span class="tok-comment">/// matching the syscall API on all targets. This removes the need for an allocator.</span></span>
<span class="line" id="L1752"><span class="tok-comment">/// This function ignores PATH environment variable. See `execvpeZ` for that.</span></span>
<span class="line" id="L1753"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">execveZ</span>(</span>
<span class="line" id="L1754">    path: [*:<span class="tok-number">0</span>]<span class="tok-kw">const</span> <span class="tok-type">u8</span>,</span>
<span class="line" id="L1755">    child_argv: [*:<span class="tok-null">null</span>]<span class="tok-kw">const</span> ?[*:<span class="tok-number">0</span>]<span class="tok-kw">const</span> <span class="tok-type">u8</span>,</span>
<span class="line" id="L1756">    envp: [*:<span class="tok-null">null</span>]<span class="tok-kw">const</span> ?[*:<span class="tok-number">0</span>]<span class="tok-kw">const</span> <span class="tok-type">u8</span>,</span>
<span class="line" id="L1757">) ExecveError {</span>
<span class="line" id="L1758">    <span class="tok-kw">switch</span> (errno(system.execve(path, child_argv, envp))) {</span>
<span class="line" id="L1759">        .SUCCESS =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L1760">        .FAULT =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L1761">        .@&quot;2BIG&quot; =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.SystemResources,</span>
<span class="line" id="L1762">        .MFILE =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.ProcessFdQuotaExceeded,</span>
<span class="line" id="L1763">        .NAMETOOLONG =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.NameTooLong,</span>
<span class="line" id="L1764">        .NFILE =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.SystemFdQuotaExceeded,</span>
<span class="line" id="L1765">        .NOMEM =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.SystemResources,</span>
<span class="line" id="L1766">        .ACCES =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.AccessDenied,</span>
<span class="line" id="L1767">        .PERM =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.AccessDenied,</span>
<span class="line" id="L1768">        .INVAL =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.InvalidExe,</span>
<span class="line" id="L1769">        .NOEXEC =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.InvalidExe,</span>
<span class="line" id="L1770">        .IO =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.FileSystem,</span>
<span class="line" id="L1771">        .LOOP =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.FileSystem,</span>
<span class="line" id="L1772">        .ISDIR =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.IsDir,</span>
<span class="line" id="L1773">        .NOENT =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.FileNotFound,</span>
<span class="line" id="L1774">        .NOTDIR =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.NotDir,</span>
<span class="line" id="L1775">        .TXTBSY =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.FileBusy,</span>
<span class="line" id="L1776">        <span class="tok-kw">else</span> =&gt; |err| <span class="tok-kw">switch</span> (builtin.os.tag) {</span>
<span class="line" id="L1777">            .macos, .ios, .tvos, .watchos =&gt; <span class="tok-kw">switch</span> (err) {</span>
<span class="line" id="L1778">                .BADEXEC =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.InvalidExe,</span>
<span class="line" id="L1779">                .BADARCH =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.InvalidExe,</span>
<span class="line" id="L1780">                <span class="tok-kw">else</span> =&gt; <span class="tok-kw">return</span> unexpectedErrno(err),</span>
<span class="line" id="L1781">            },</span>
<span class="line" id="L1782">            .linux, .solaris =&gt; <span class="tok-kw">switch</span> (err) {</span>
<span class="line" id="L1783">                .LIBBAD =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.InvalidExe,</span>
<span class="line" id="L1784">                <span class="tok-kw">else</span> =&gt; <span class="tok-kw">return</span> unexpectedErrno(err),</span>
<span class="line" id="L1785">            },</span>
<span class="line" id="L1786">            <span class="tok-kw">else</span> =&gt; <span class="tok-kw">return</span> unexpectedErrno(err),</span>
<span class="line" id="L1787">        },</span>
<span class="line" id="L1788">    }</span>
<span class="line" id="L1789">}</span>
<span class="line" id="L1790"></span>
<span class="line" id="L1791"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> Arg0Expand = <span class="tok-kw">enum</span> {</span>
<span class="line" id="L1792">    expand,</span>
<span class="line" id="L1793">    no_expand,</span>
<span class="line" id="L1794">};</span>
<span class="line" id="L1795"></span>
<span class="line" id="L1796"><span class="tok-comment">/// Like `execvpeZ` except if `arg0_expand` is `.expand`, then `argv` is mutable,</span></span>
<span class="line" id="L1797"><span class="tok-comment">/// and `argv[0]` is expanded to be the same absolute path that is passed to the execve syscall.</span></span>
<span class="line" id="L1798"><span class="tok-comment">/// If this function returns with an error, `argv[0]` will be restored to the value it was when it was passed in.</span></span>
<span class="line" id="L1799"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">execvpeZ_expandArg0</span>(</span>
<span class="line" id="L1800">    <span class="tok-kw">comptime</span> arg0_expand: Arg0Expand,</span>
<span class="line" id="L1801">    file: [*:<span class="tok-number">0</span>]<span class="tok-kw">const</span> <span class="tok-type">u8</span>,</span>
<span class="line" id="L1802">    child_argv: <span class="tok-kw">switch</span> (arg0_expand) {</span>
<span class="line" id="L1803">        .expand =&gt; [*:<span class="tok-null">null</span>]?[*:<span class="tok-number">0</span>]<span class="tok-kw">const</span> <span class="tok-type">u8</span>,</span>
<span class="line" id="L1804">        .no_expand =&gt; [*:<span class="tok-null">null</span>]<span class="tok-kw">const</span> ?[*:<span class="tok-number">0</span>]<span class="tok-kw">const</span> <span class="tok-type">u8</span>,</span>
<span class="line" id="L1805">    },</span>
<span class="line" id="L1806">    envp: [*:<span class="tok-null">null</span>]<span class="tok-kw">const</span> ?[*:<span class="tok-number">0</span>]<span class="tok-kw">const</span> <span class="tok-type">u8</span>,</span>
<span class="line" id="L1807">) ExecveError {</span>
<span class="line" id="L1808">    <span class="tok-kw">const</span> file_slice = mem.sliceTo(file, <span class="tok-number">0</span>);</span>
<span class="line" id="L1809">    <span class="tok-kw">if</span> (mem.indexOfScalar(<span class="tok-type">u8</span>, file_slice, <span class="tok-str">'/'</span>) != <span class="tok-null">null</span>) <span class="tok-kw">return</span> execveZ(file, child_argv, envp);</span>
<span class="line" id="L1810"></span>
<span class="line" id="L1811">    <span class="tok-kw">const</span> PATH = getenvZ(<span class="tok-str">&quot;PATH&quot;</span>) <span class="tok-kw">orelse</span> <span class="tok-str">&quot;/usr/local/bin:/bin/:/usr/bin&quot;</span>;</span>
<span class="line" id="L1812">    <span class="tok-comment">// Use of MAX_PATH_BYTES here is valid as the path_buf will be passed</span>
</span>
<span class="line" id="L1813">    <span class="tok-comment">// directly to the operating system in execveZ.</span>
</span>
<span class="line" id="L1814">    <span class="tok-kw">var</span> path_buf: [MAX_PATH_BYTES]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L1815">    <span class="tok-kw">var</span> it = mem.tokenize(<span class="tok-type">u8</span>, PATH, <span class="tok-str">&quot;:&quot;</span>);</span>
<span class="line" id="L1816">    <span class="tok-kw">var</span> seen_eacces = <span class="tok-null">false</span>;</span>
<span class="line" id="L1817">    <span class="tok-kw">var</span> err: ExecveError = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L1818"></span>
<span class="line" id="L1819">    <span class="tok-comment">// In case of expanding arg0 we must put it back if we return with an error.</span>
</span>
<span class="line" id="L1820">    <span class="tok-kw">const</span> prev_arg0 = child_argv[<span class="tok-number">0</span>];</span>
<span class="line" id="L1821">    <span class="tok-kw">defer</span> <span class="tok-kw">switch</span> (arg0_expand) {</span>
<span class="line" id="L1822">        .expand =&gt; child_argv[<span class="tok-number">0</span>] = prev_arg0,</span>
<span class="line" id="L1823">        .no_expand =&gt; {},</span>
<span class="line" id="L1824">    };</span>
<span class="line" id="L1825"></span>
<span class="line" id="L1826">    <span class="tok-kw">while</span> (it.next()) |search_path| {</span>
<span class="line" id="L1827">        <span class="tok-kw">const</span> path_len = search_path.len + file_slice.len + <span class="tok-number">1</span>;</span>
<span class="line" id="L1828">        <span class="tok-kw">if</span> (path_buf.len &lt; path_len + <span class="tok-number">1</span>) <span class="tok-kw">return</span> <span class="tok-kw">error</span>.NameTooLong;</span>
<span class="line" id="L1829">        mem.copy(<span class="tok-type">u8</span>, &amp;path_buf, search_path);</span>
<span class="line" id="L1830">        path_buf[search_path.len] = <span class="tok-str">'/'</span>;</span>
<span class="line" id="L1831">        mem.copy(<span class="tok-type">u8</span>, path_buf[search_path.len + <span class="tok-number">1</span> ..], file_slice);</span>
<span class="line" id="L1832">        path_buf[path_len] = <span class="tok-number">0</span>;</span>
<span class="line" id="L1833">        <span class="tok-kw">const</span> full_path = path_buf[<span class="tok-number">0</span>..path_len :<span class="tok-number">0</span>].ptr;</span>
<span class="line" id="L1834">        <span class="tok-kw">switch</span> (arg0_expand) {</span>
<span class="line" id="L1835">            .expand =&gt; child_argv[<span class="tok-number">0</span>] = full_path,</span>
<span class="line" id="L1836">            .no_expand =&gt; {},</span>
<span class="line" id="L1837">        }</span>
<span class="line" id="L1838">        err = execveZ(full_path, child_argv, envp);</span>
<span class="line" id="L1839">        <span class="tok-kw">switch</span> (err) {</span>
<span class="line" id="L1840">            <span class="tok-kw">error</span>.AccessDenied =&gt; seen_eacces = <span class="tok-null">true</span>,</span>
<span class="line" id="L1841">            <span class="tok-kw">error</span>.FileNotFound, <span class="tok-kw">error</span>.NotDir =&gt; {},</span>
<span class="line" id="L1842">            <span class="tok-kw">else</span> =&gt; |e| <span class="tok-kw">return</span> e,</span>
<span class="line" id="L1843">        }</span>
<span class="line" id="L1844">    }</span>
<span class="line" id="L1845">    <span class="tok-kw">if</span> (seen_eacces) <span class="tok-kw">return</span> <span class="tok-kw">error</span>.AccessDenied;</span>
<span class="line" id="L1846">    <span class="tok-kw">return</span> err;</span>
<span class="line" id="L1847">}</span>
<span class="line" id="L1848"></span>
<span class="line" id="L1849"><span class="tok-comment">/// Like `execvpe` except the parameters are null-terminated,</span></span>
<span class="line" id="L1850"><span class="tok-comment">/// matching the syscall API on all targets. This removes the need for an allocator.</span></span>
<span class="line" id="L1851"><span class="tok-comment">/// This function also uses the PATH environment variable to get the full path to the executable.</span></span>
<span class="line" id="L1852"><span class="tok-comment">/// If `file` is an absolute path, this is the same as `execveZ`.</span></span>
<span class="line" id="L1853"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">execvpeZ</span>(</span>
<span class="line" id="L1854">    file: [*:<span class="tok-number">0</span>]<span class="tok-kw">const</span> <span class="tok-type">u8</span>,</span>
<span class="line" id="L1855">    argv_ptr: [*:<span class="tok-null">null</span>]<span class="tok-kw">const</span> ?[*:<span class="tok-number">0</span>]<span class="tok-kw">const</span> <span class="tok-type">u8</span>,</span>
<span class="line" id="L1856">    envp: [*:<span class="tok-null">null</span>]<span class="tok-kw">const</span> ?[*:<span class="tok-number">0</span>]<span class="tok-kw">const</span> <span class="tok-type">u8</span>,</span>
<span class="line" id="L1857">) ExecveError {</span>
<span class="line" id="L1858">    <span class="tok-kw">return</span> execvpeZ_expandArg0(.no_expand, file, argv_ptr, envp);</span>
<span class="line" id="L1859">}</span>
<span class="line" id="L1860"></span>
<span class="line" id="L1861"><span class="tok-comment">/// Get an environment variable.</span></span>
<span class="line" id="L1862"><span class="tok-comment">/// See also `getenvZ`.</span></span>
<span class="line" id="L1863"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">getenv</span>(key: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) ?[]<span class="tok-kw">const</span> <span class="tok-type">u8</span> {</span>
<span class="line" id="L1864">    <span class="tok-kw">if</span> (builtin.link_libc) {</span>
<span class="line" id="L1865">        <span class="tok-kw">var</span> small_key_buf: [<span class="tok-number">64</span>]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L1866">        <span class="tok-kw">if</span> (key.len &lt; small_key_buf.len) {</span>
<span class="line" id="L1867">            mem.copy(<span class="tok-type">u8</span>, &amp;small_key_buf, key);</span>
<span class="line" id="L1868">            small_key_buf[key.len] = <span class="tok-number">0</span>;</span>
<span class="line" id="L1869">            <span class="tok-kw">const</span> key0 = small_key_buf[<span class="tok-number">0</span>..key.len :<span class="tok-number">0</span>];</span>
<span class="line" id="L1870">            <span class="tok-kw">return</span> getenvZ(key0);</span>
<span class="line" id="L1871">        }</span>
<span class="line" id="L1872">        <span class="tok-comment">// Search the entire `environ` because we don't have a null terminated pointer.</span>
</span>
<span class="line" id="L1873">        <span class="tok-kw">var</span> ptr = std.c.environ;</span>
<span class="line" id="L1874">        <span class="tok-kw">while</span> (ptr[<span class="tok-number">0</span>]) |line| : (ptr += <span class="tok-number">1</span>) {</span>
<span class="line" id="L1875">            <span class="tok-kw">var</span> line_i: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L1876">            <span class="tok-kw">while</span> (line[line_i] != <span class="tok-number">0</span> <span class="tok-kw">and</span> line[line_i] != <span class="tok-str">'='</span>) : (line_i += <span class="tok-number">1</span>) {}</span>
<span class="line" id="L1877">            <span class="tok-kw">const</span> this_key = line[<span class="tok-number">0</span>..line_i];</span>
<span class="line" id="L1878"></span>
<span class="line" id="L1879">            <span class="tok-kw">if</span> (!mem.eql(<span class="tok-type">u8</span>, this_key, key)) <span class="tok-kw">continue</span>;</span>
<span class="line" id="L1880"></span>
<span class="line" id="L1881">            <span class="tok-kw">var</span> end_i: <span class="tok-type">usize</span> = line_i;</span>
<span class="line" id="L1882">            <span class="tok-kw">while</span> (line[end_i] != <span class="tok-number">0</span>) : (end_i += <span class="tok-number">1</span>) {}</span>
<span class="line" id="L1883">            <span class="tok-kw">const</span> value = line[line_i + <span class="tok-number">1</span> .. end_i];</span>
<span class="line" id="L1884"></span>
<span class="line" id="L1885">            <span class="tok-kw">return</span> value;</span>
<span class="line" id="L1886">        }</span>
<span class="line" id="L1887">        <span class="tok-kw">return</span> <span class="tok-null">null</span>;</span>
<span class="line" id="L1888">    }</span>
<span class="line" id="L1889">    <span class="tok-kw">if</span> (builtin.os.tag == .windows) {</span>
<span class="line" id="L1890">        <span class="tok-builtin">@compileError</span>(<span class="tok-str">&quot;std.os.getenv is unavailable for Windows because environment string is in WTF-16 format. See std.process.getEnvVarOwned for cross-platform API or std.os.getenvW for Windows-specific API.&quot;</span>);</span>
<span class="line" id="L1891">    }</span>
<span class="line" id="L1892">    <span class="tok-comment">// TODO see https://github.com/ziglang/zig/issues/4524</span>
</span>
<span class="line" id="L1893">    <span class="tok-kw">for</span> (environ) |ptr| {</span>
<span class="line" id="L1894">        <span class="tok-kw">var</span> line_i: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L1895">        <span class="tok-kw">while</span> (ptr[line_i] != <span class="tok-number">0</span> <span class="tok-kw">and</span> ptr[line_i] != <span class="tok-str">'='</span>) : (line_i += <span class="tok-number">1</span>) {}</span>
<span class="line" id="L1896">        <span class="tok-kw">const</span> this_key = ptr[<span class="tok-number">0</span>..line_i];</span>
<span class="line" id="L1897">        <span class="tok-kw">if</span> (!mem.eql(<span class="tok-type">u8</span>, key, this_key)) <span class="tok-kw">continue</span>;</span>
<span class="line" id="L1898"></span>
<span class="line" id="L1899">        <span class="tok-kw">var</span> end_i: <span class="tok-type">usize</span> = line_i;</span>
<span class="line" id="L1900">        <span class="tok-kw">while</span> (ptr[end_i] != <span class="tok-number">0</span>) : (end_i += <span class="tok-number">1</span>) {}</span>
<span class="line" id="L1901">        <span class="tok-kw">const</span> this_value = ptr[line_i + <span class="tok-number">1</span> .. end_i];</span>
<span class="line" id="L1902"></span>
<span class="line" id="L1903">        <span class="tok-kw">return</span> this_value;</span>
<span class="line" id="L1904">    }</span>
<span class="line" id="L1905">    <span class="tok-kw">return</span> <span class="tok-null">null</span>;</span>
<span class="line" id="L1906">}</span>
<span class="line" id="L1907"></span>
<span class="line" id="L1908"><span class="tok-comment">/// Get an environment variable with a null-terminated name.</span></span>
<span class="line" id="L1909"><span class="tok-comment">/// See also `getenv`.</span></span>
<span class="line" id="L1910"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">getenvZ</span>(key: [*:<span class="tok-number">0</span>]<span class="tok-kw">const</span> <span class="tok-type">u8</span>) ?[]<span class="tok-kw">const</span> <span class="tok-type">u8</span> {</span>
<span class="line" id="L1911">    <span class="tok-kw">if</span> (builtin.link_libc) {</span>
<span class="line" id="L1912">        <span class="tok-kw">const</span> value = system.getenv(key) <span class="tok-kw">orelse</span> <span class="tok-kw">return</span> <span class="tok-null">null</span>;</span>
<span class="line" id="L1913">        <span class="tok-kw">return</span> mem.sliceTo(value, <span class="tok-number">0</span>);</span>
<span class="line" id="L1914">    }</span>
<span class="line" id="L1915">    <span class="tok-kw">if</span> (builtin.os.tag == .windows) {</span>
<span class="line" id="L1916">        <span class="tok-builtin">@compileError</span>(<span class="tok-str">&quot;std.os.getenvZ is unavailable for Windows because environment string is in WTF-16 format. See std.process.getEnvVarOwned for cross-platform API or std.os.getenvW for Windows-specific API.&quot;</span>);</span>
<span class="line" id="L1917">    }</span>
<span class="line" id="L1918">    <span class="tok-kw">return</span> getenv(mem.sliceTo(key, <span class="tok-number">0</span>));</span>
<span class="line" id="L1919">}</span>
<span class="line" id="L1920"></span>
<span class="line" id="L1921"><span class="tok-comment">/// Windows-only. Get an environment variable with a null-terminated, WTF-16 encoded name.</span></span>
<span class="line" id="L1922"><span class="tok-comment">/// See also `getenv`.</span></span>
<span class="line" id="L1923"><span class="tok-comment">/// This function performs a Unicode-aware case-insensitive lookup using RtlEqualUnicodeString.</span></span>
<span class="line" id="L1924"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">getenvW</span>(key: [*:<span class="tok-number">0</span>]<span class="tok-kw">const</span> <span class="tok-type">u16</span>) ?[:<span class="tok-number">0</span>]<span class="tok-kw">const</span> <span class="tok-type">u16</span> {</span>
<span class="line" id="L1925">    <span class="tok-kw">if</span> (builtin.os.tag != .windows) {</span>
<span class="line" id="L1926">        <span class="tok-builtin">@compileError</span>(<span class="tok-str">&quot;std.os.getenvW is a Windows-only API&quot;</span>);</span>
<span class="line" id="L1927">    }</span>
<span class="line" id="L1928">    <span class="tok-kw">const</span> key_slice = mem.sliceTo(key, <span class="tok-number">0</span>);</span>
<span class="line" id="L1929">    <span class="tok-kw">const</span> ptr = windows.peb().ProcessParameters.Environment;</span>
<span class="line" id="L1930">    <span class="tok-kw">var</span> i: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L1931">    <span class="tok-kw">while</span> (ptr[i] != <span class="tok-number">0</span>) {</span>
<span class="line" id="L1932">        <span class="tok-kw">const</span> key_start = i;</span>
<span class="line" id="L1933"></span>
<span class="line" id="L1934">        <span class="tok-comment">// There are some special environment variables that start with =,</span>
</span>
<span class="line" id="L1935">        <span class="tok-comment">// so we need a special case to not treat = as a key/value separator</span>
</span>
<span class="line" id="L1936">        <span class="tok-comment">// if it's the first character.</span>
</span>
<span class="line" id="L1937">        <span class="tok-comment">// https://devblogs.microsoft.com/oldnewthing/20100506-00/?p=14133</span>
</span>
<span class="line" id="L1938">        <span class="tok-kw">if</span> (ptr[key_start] == <span class="tok-str">'='</span>) i += <span class="tok-number">1</span>;</span>
<span class="line" id="L1939"></span>
<span class="line" id="L1940">        <span class="tok-kw">while</span> (ptr[i] != <span class="tok-number">0</span> <span class="tok-kw">and</span> ptr[i] != <span class="tok-str">'='</span>) : (i += <span class="tok-number">1</span>) {}</span>
<span class="line" id="L1941">        <span class="tok-kw">const</span> this_key = ptr[key_start..i];</span>
<span class="line" id="L1942"></span>
<span class="line" id="L1943">        <span class="tok-kw">if</span> (ptr[i] == <span class="tok-str">'='</span>) i += <span class="tok-number">1</span>;</span>
<span class="line" id="L1944"></span>
<span class="line" id="L1945">        <span class="tok-kw">const</span> value_start = i;</span>
<span class="line" id="L1946">        <span class="tok-kw">while</span> (ptr[i] != <span class="tok-number">0</span>) : (i += <span class="tok-number">1</span>) {}</span>
<span class="line" id="L1947">        <span class="tok-kw">const</span> this_value = ptr[value_start..i :<span class="tok-number">0</span>];</span>
<span class="line" id="L1948"></span>
<span class="line" id="L1949">        <span class="tok-kw">const</span> key_string_bytes = <span class="tok-builtin">@intCast</span>(<span class="tok-type">u16</span>, key_slice.len * <span class="tok-number">2</span>);</span>
<span class="line" id="L1950">        <span class="tok-kw">const</span> key_string = windows.UNICODE_STRING{</span>
<span class="line" id="L1951">            .Length = key_string_bytes,</span>
<span class="line" id="L1952">            .MaximumLength = key_string_bytes,</span>
<span class="line" id="L1953">            .Buffer = <span class="tok-builtin">@intToPtr</span>([*]<span class="tok-type">u16</span>, <span class="tok-builtin">@ptrToInt</span>(key)),</span>
<span class="line" id="L1954">        };</span>
<span class="line" id="L1955">        <span class="tok-kw">const</span> this_key_string_bytes = <span class="tok-builtin">@intCast</span>(<span class="tok-type">u16</span>, this_key.len * <span class="tok-number">2</span>);</span>
<span class="line" id="L1956">        <span class="tok-kw">const</span> this_key_string = windows.UNICODE_STRING{</span>
<span class="line" id="L1957">            .Length = this_key_string_bytes,</span>
<span class="line" id="L1958">            .MaximumLength = this_key_string_bytes,</span>
<span class="line" id="L1959">            .Buffer = this_key.ptr,</span>
<span class="line" id="L1960">        };</span>
<span class="line" id="L1961">        <span class="tok-kw">if</span> (windows.ntdll.RtlEqualUnicodeString(&amp;key_string, &amp;this_key_string, windows.TRUE) == windows.TRUE) {</span>
<span class="line" id="L1962">            <span class="tok-kw">return</span> this_value;</span>
<span class="line" id="L1963">        }</span>
<span class="line" id="L1964"></span>
<span class="line" id="L1965">        i += <span class="tok-number">1</span>; <span class="tok-comment">// skip over null byte</span>
</span>
<span class="line" id="L1966">    }</span>
<span class="line" id="L1967">    <span class="tok-kw">return</span> <span class="tok-null">null</span>;</span>
<span class="line" id="L1968">}</span>
<span class="line" id="L1969"></span>
<span class="line" id="L1970"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> GetCwdError = <span class="tok-kw">error</span>{</span>
<span class="line" id="L1971">    NameTooLong,</span>
<span class="line" id="L1972">    CurrentWorkingDirectoryUnlinked,</span>
<span class="line" id="L1973">} || UnexpectedError;</span>
<span class="line" id="L1974"></span>
<span class="line" id="L1975"><span class="tok-comment">/// The result is a slice of out_buffer, indexed from 0.</span></span>
<span class="line" id="L1976"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">getcwd</span>(out_buffer: []<span class="tok-type">u8</span>) GetCwdError![]<span class="tok-type">u8</span> {</span>
<span class="line" id="L1977">    <span class="tok-kw">if</span> (builtin.os.tag == .windows) {</span>
<span class="line" id="L1978">        <span class="tok-kw">return</span> windows.GetCurrentDirectory(out_buffer);</span>
<span class="line" id="L1979">    } <span class="tok-kw">else</span> <span class="tok-kw">if</span> (builtin.os.tag == .wasi <span class="tok-kw">and</span> !builtin.link_libc) {</span>
<span class="line" id="L1980">        <span class="tok-kw">const</span> path = wasi_cwd.cwd;</span>
<span class="line" id="L1981">        <span class="tok-kw">if</span> (out_buffer.len &lt; path.len) <span class="tok-kw">return</span> <span class="tok-kw">error</span>.NameTooLong;</span>
<span class="line" id="L1982">        std.mem.copy(<span class="tok-type">u8</span>, out_buffer, path);</span>
<span class="line" id="L1983">        <span class="tok-kw">return</span> out_buffer[<span class="tok-number">0</span>..path.len];</span>
<span class="line" id="L1984">    }</span>
<span class="line" id="L1985"></span>
<span class="line" id="L1986">    <span class="tok-kw">const</span> err = <span class="tok-kw">if</span> (builtin.link_libc) blk: {</span>
<span class="line" id="L1987">        <span class="tok-kw">const</span> c_err = <span class="tok-kw">if</span> (std.c.getcwd(out_buffer.ptr, out_buffer.len)) |_| <span class="tok-number">0</span> <span class="tok-kw">else</span> std.c._errno().*;</span>
<span class="line" id="L1988">        <span class="tok-kw">break</span> :blk <span class="tok-builtin">@intToEnum</span>(E, c_err);</span>
<span class="line" id="L1989">    } <span class="tok-kw">else</span> blk: {</span>
<span class="line" id="L1990">        <span class="tok-kw">break</span> :blk errno(system.getcwd(out_buffer.ptr, out_buffer.len));</span>
<span class="line" id="L1991">    };</span>
<span class="line" id="L1992">    <span class="tok-kw">switch</span> (err) {</span>
<span class="line" id="L1993">        .SUCCESS =&gt; <span class="tok-kw">return</span> mem.sliceTo(std.meta.assumeSentinel(out_buffer.ptr, <span class="tok-number">0</span>), <span class="tok-number">0</span>),</span>
<span class="line" id="L1994">        .FAULT =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L1995">        .INVAL =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L1996">        .NOENT =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.CurrentWorkingDirectoryUnlinked,</span>
<span class="line" id="L1997">        .RANGE =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.NameTooLong,</span>
<span class="line" id="L1998">        <span class="tok-kw">else</span> =&gt; <span class="tok-kw">return</span> unexpectedErrno(err),</span>
<span class="line" id="L1999">    }</span>
<span class="line" id="L2000">}</span>
<span class="line" id="L2001"></span>
<span class="line" id="L2002"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> SymLinkError = <span class="tok-kw">error</span>{</span>
<span class="line" id="L2003">    <span class="tok-comment">/// In WASI, this error may occur when the file descriptor does</span></span>
<span class="line" id="L2004">    <span class="tok-comment">/// not hold the required rights to create a new symbolic link relative to it.</span></span>
<span class="line" id="L2005">    AccessDenied,</span>
<span class="line" id="L2006">    DiskQuota,</span>
<span class="line" id="L2007">    PathAlreadyExists,</span>
<span class="line" id="L2008">    FileSystem,</span>
<span class="line" id="L2009">    SymLinkLoop,</span>
<span class="line" id="L2010">    FileNotFound,</span>
<span class="line" id="L2011">    SystemResources,</span>
<span class="line" id="L2012">    NoSpaceLeft,</span>
<span class="line" id="L2013">    ReadOnlyFileSystem,</span>
<span class="line" id="L2014">    NotDir,</span>
<span class="line" id="L2015">    NameTooLong,</span>
<span class="line" id="L2016">    InvalidUtf8,</span>
<span class="line" id="L2017">    BadPathName,</span>
<span class="line" id="L2018">} || UnexpectedError;</span>
<span class="line" id="L2019"></span>
<span class="line" id="L2020"><span class="tok-comment">/// Creates a symbolic link named `sym_link_path` which contains the string `target_path`.</span></span>
<span class="line" id="L2021"><span class="tok-comment">/// A symbolic link (also known as a soft link) may point to an existing file or to a nonexistent</span></span>
<span class="line" id="L2022"><span class="tok-comment">/// one; the latter case is known as a dangling link.</span></span>
<span class="line" id="L2023"><span class="tok-comment">/// If `sym_link_path` exists, it will not be overwritten.</span></span>
<span class="line" id="L2024"><span class="tok-comment">/// See also `symlinkZ.</span></span>
<span class="line" id="L2025"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">symlink</span>(target_path: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>, sym_link_path: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) SymLinkError!<span class="tok-type">void</span> {</span>
<span class="line" id="L2026">    <span class="tok-kw">if</span> (builtin.os.tag == .windows) {</span>
<span class="line" id="L2027">        <span class="tok-builtin">@compileError</span>(<span class="tok-str">&quot;symlink is not supported on Windows; use std.os.windows.CreateSymbolicLink instead&quot;</span>);</span>
<span class="line" id="L2028">    } <span class="tok-kw">else</span> <span class="tok-kw">if</span> (builtin.os.tag == .wasi <span class="tok-kw">and</span> !builtin.link_libc) {</span>
<span class="line" id="L2029">        <span class="tok-kw">return</span> symlinkat(target_path, wasi.AT.FDCWD, sym_link_path);</span>
<span class="line" id="L2030">    }</span>
<span class="line" id="L2031">    <span class="tok-kw">const</span> target_path_c = <span class="tok-kw">try</span> toPosixPath(target_path);</span>
<span class="line" id="L2032">    <span class="tok-kw">const</span> sym_link_path_c = <span class="tok-kw">try</span> toPosixPath(sym_link_path);</span>
<span class="line" id="L2033">    <span class="tok-kw">return</span> symlinkZ(&amp;target_path_c, &amp;sym_link_path_c);</span>
<span class="line" id="L2034">}</span>
<span class="line" id="L2035"></span>
<span class="line" id="L2036"><span class="tok-comment">/// This is the same as `symlink` except the parameters are null-terminated pointers.</span></span>
<span class="line" id="L2037"><span class="tok-comment">/// See also `symlink`.</span></span>
<span class="line" id="L2038"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">symlinkZ</span>(target_path: [*:<span class="tok-number">0</span>]<span class="tok-kw">const</span> <span class="tok-type">u8</span>, sym_link_path: [*:<span class="tok-number">0</span>]<span class="tok-kw">const</span> <span class="tok-type">u8</span>) SymLinkError!<span class="tok-type">void</span> {</span>
<span class="line" id="L2039">    <span class="tok-kw">if</span> (builtin.os.tag == .windows) {</span>
<span class="line" id="L2040">        <span class="tok-builtin">@compileError</span>(<span class="tok-str">&quot;symlink is not supported on Windows; use std.os.windows.CreateSymbolicLink instead&quot;</span>);</span>
<span class="line" id="L2041">    } <span class="tok-kw">else</span> <span class="tok-kw">if</span> (builtin.os.tag == .wasi <span class="tok-kw">and</span> !builtin.link_libc) {</span>
<span class="line" id="L2042">        <span class="tok-kw">return</span> symlink(mem.sliceTo(target_path, <span class="tok-number">0</span>), mem.sliceTo(sym_link_path, <span class="tok-number">0</span>));</span>
<span class="line" id="L2043">    }</span>
<span class="line" id="L2044">    <span class="tok-kw">switch</span> (errno(system.symlink(target_path, sym_link_path))) {</span>
<span class="line" id="L2045">        .SUCCESS =&gt; <span class="tok-kw">return</span>,</span>
<span class="line" id="L2046">        .FAULT =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L2047">        .INVAL =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L2048">        .ACCES =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.AccessDenied,</span>
<span class="line" id="L2049">        .PERM =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.AccessDenied,</span>
<span class="line" id="L2050">        .DQUOT =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.DiskQuota,</span>
<span class="line" id="L2051">        .EXIST =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.PathAlreadyExists,</span>
<span class="line" id="L2052">        .IO =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.FileSystem,</span>
<span class="line" id="L2053">        .LOOP =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.SymLinkLoop,</span>
<span class="line" id="L2054">        .NAMETOOLONG =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.NameTooLong,</span>
<span class="line" id="L2055">        .NOENT =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.FileNotFound,</span>
<span class="line" id="L2056">        .NOTDIR =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.NotDir,</span>
<span class="line" id="L2057">        .NOMEM =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.SystemResources,</span>
<span class="line" id="L2058">        .NOSPC =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.NoSpaceLeft,</span>
<span class="line" id="L2059">        .ROFS =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.ReadOnlyFileSystem,</span>
<span class="line" id="L2060">        <span class="tok-kw">else</span> =&gt; |err| <span class="tok-kw">return</span> unexpectedErrno(err),</span>
<span class="line" id="L2061">    }</span>
<span class="line" id="L2062">}</span>
<span class="line" id="L2063"></span>
<span class="line" id="L2064"><span class="tok-comment">/// Similar to `symlink`, however, creates a symbolic link named `sym_link_path` which contains the string</span></span>
<span class="line" id="L2065"><span class="tok-comment">/// `target_path` **relative** to `newdirfd` directory handle.</span></span>
<span class="line" id="L2066"><span class="tok-comment">/// A symbolic link (also known as a soft link) may point to an existing file or to a nonexistent</span></span>
<span class="line" id="L2067"><span class="tok-comment">/// one; the latter case is known as a dangling link.</span></span>
<span class="line" id="L2068"><span class="tok-comment">/// If `sym_link_path` exists, it will not be overwritten.</span></span>
<span class="line" id="L2069"><span class="tok-comment">/// See also `symlinkatWasi`, `symlinkatZ` and `symlinkatW`.</span></span>
<span class="line" id="L2070"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">symlinkat</span>(target_path: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>, newdirfd: fd_t, sym_link_path: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) SymLinkError!<span class="tok-type">void</span> {</span>
<span class="line" id="L2071">    <span class="tok-kw">if</span> (builtin.os.tag == .windows) {</span>
<span class="line" id="L2072">        <span class="tok-builtin">@compileError</span>(<span class="tok-str">&quot;symlinkat is not supported on Windows; use std.os.windows.CreateSymbolicLink instead&quot;</span>);</span>
<span class="line" id="L2073">    } <span class="tok-kw">else</span> <span class="tok-kw">if</span> (builtin.os.tag == .wasi <span class="tok-kw">and</span> !builtin.link_libc) {</span>
<span class="line" id="L2074">        <span class="tok-kw">if</span> (newdirfd == wasi.AT.FDCWD <span class="tok-kw">or</span> fs.path.isAbsolute(target_path)) {</span>
<span class="line" id="L2075">            <span class="tok-comment">// Resolve absolute or CWD-relative paths to a path within a Preopen</span>
</span>
<span class="line" id="L2076">            <span class="tok-kw">var</span> path_buf: [MAX_PATH_BYTES]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L2077">            <span class="tok-kw">const</span> path = <span class="tok-kw">try</span> resolvePathWasi(sym_link_path, &amp;path_buf);</span>
<span class="line" id="L2078">            <span class="tok-kw">return</span> symlinkatWasi(target_path, path.dir_fd, path.relative_path);</span>
<span class="line" id="L2079">        }</span>
<span class="line" id="L2080">        <span class="tok-kw">return</span> symlinkatWasi(target_path, newdirfd, sym_link_path);</span>
<span class="line" id="L2081">    }</span>
<span class="line" id="L2082">    <span class="tok-kw">const</span> target_path_c = <span class="tok-kw">try</span> toPosixPath(target_path);</span>
<span class="line" id="L2083">    <span class="tok-kw">const</span> sym_link_path_c = <span class="tok-kw">try</span> toPosixPath(sym_link_path);</span>
<span class="line" id="L2084">    <span class="tok-kw">return</span> symlinkatZ(&amp;target_path_c, newdirfd, &amp;sym_link_path_c);</span>
<span class="line" id="L2085">}</span>
<span class="line" id="L2086"></span>
<span class="line" id="L2087"><span class="tok-comment">/// WASI-only. The same as `symlinkat` but targeting WASI.</span></span>
<span class="line" id="L2088"><span class="tok-comment">/// See also `symlinkat`.</span></span>
<span class="line" id="L2089"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">symlinkatWasi</span>(target_path: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>, newdirfd: fd_t, sym_link_path: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) SymLinkError!<span class="tok-type">void</span> {</span>
<span class="line" id="L2090">    <span class="tok-kw">switch</span> (wasi.path_symlink(target_path.ptr, target_path.len, newdirfd, sym_link_path.ptr, sym_link_path.len)) {</span>
<span class="line" id="L2091">        .SUCCESS =&gt; {},</span>
<span class="line" id="L2092">        .FAULT =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L2093">        .INVAL =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L2094">        .ACCES =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.AccessDenied,</span>
<span class="line" id="L2095">        .PERM =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.AccessDenied,</span>
<span class="line" id="L2096">        .DQUOT =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.DiskQuota,</span>
<span class="line" id="L2097">        .EXIST =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.PathAlreadyExists,</span>
<span class="line" id="L2098">        .IO =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.FileSystem,</span>
<span class="line" id="L2099">        .LOOP =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.SymLinkLoop,</span>
<span class="line" id="L2100">        .NAMETOOLONG =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.NameTooLong,</span>
<span class="line" id="L2101">        .NOENT =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.FileNotFound,</span>
<span class="line" id="L2102">        .NOTDIR =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.NotDir,</span>
<span class="line" id="L2103">        .NOMEM =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.SystemResources,</span>
<span class="line" id="L2104">        .NOSPC =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.NoSpaceLeft,</span>
<span class="line" id="L2105">        .ROFS =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.ReadOnlyFileSystem,</span>
<span class="line" id="L2106">        .NOTCAPABLE =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.AccessDenied,</span>
<span class="line" id="L2107">        <span class="tok-kw">else</span> =&gt; |err| <span class="tok-kw">return</span> unexpectedErrno(err),</span>
<span class="line" id="L2108">    }</span>
<span class="line" id="L2109">}</span>
<span class="line" id="L2110"></span>
<span class="line" id="L2111"><span class="tok-comment">/// The same as `symlinkat` except the parameters are null-terminated pointers.</span></span>
<span class="line" id="L2112"><span class="tok-comment">/// See also `symlinkat`.</span></span>
<span class="line" id="L2113"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">symlinkatZ</span>(target_path: [*:<span class="tok-number">0</span>]<span class="tok-kw">const</span> <span class="tok-type">u8</span>, newdirfd: fd_t, sym_link_path: [*:<span class="tok-number">0</span>]<span class="tok-kw">const</span> <span class="tok-type">u8</span>) SymLinkError!<span class="tok-type">void</span> {</span>
<span class="line" id="L2114">    <span class="tok-kw">if</span> (builtin.os.tag == .windows) {</span>
<span class="line" id="L2115">        <span class="tok-builtin">@compileError</span>(<span class="tok-str">&quot;symlinkat is not supported on Windows; use std.os.windows.CreateSymbolicLink instead&quot;</span>);</span>
<span class="line" id="L2116">    } <span class="tok-kw">else</span> <span class="tok-kw">if</span> (builtin.os.tag == .wasi <span class="tok-kw">and</span> !builtin.link_libc) {</span>
<span class="line" id="L2117">        <span class="tok-kw">return</span> symlinkat(mem.sliceTo(target_path, <span class="tok-number">0</span>), newdirfd, mem.sliceTo(sym_link_path, <span class="tok-number">0</span>));</span>
<span class="line" id="L2118">    }</span>
<span class="line" id="L2119">    <span class="tok-kw">switch</span> (errno(system.symlinkat(target_path, newdirfd, sym_link_path))) {</span>
<span class="line" id="L2120">        .SUCCESS =&gt; <span class="tok-kw">return</span>,</span>
<span class="line" id="L2121">        .FAULT =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L2122">        .INVAL =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L2123">        .ACCES =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.AccessDenied,</span>
<span class="line" id="L2124">        .PERM =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.AccessDenied,</span>
<span class="line" id="L2125">        .DQUOT =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.DiskQuota,</span>
<span class="line" id="L2126">        .EXIST =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.PathAlreadyExists,</span>
<span class="line" id="L2127">        .IO =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.FileSystem,</span>
<span class="line" id="L2128">        .LOOP =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.SymLinkLoop,</span>
<span class="line" id="L2129">        .NAMETOOLONG =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.NameTooLong,</span>
<span class="line" id="L2130">        .NOENT =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.FileNotFound,</span>
<span class="line" id="L2131">        .NOTDIR =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.NotDir,</span>
<span class="line" id="L2132">        .NOMEM =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.SystemResources,</span>
<span class="line" id="L2133">        .NOSPC =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.NoSpaceLeft,</span>
<span class="line" id="L2134">        .ROFS =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.ReadOnlyFileSystem,</span>
<span class="line" id="L2135">        <span class="tok-kw">else</span> =&gt; |err| <span class="tok-kw">return</span> unexpectedErrno(err),</span>
<span class="line" id="L2136">    }</span>
<span class="line" id="L2137">}</span>
<span class="line" id="L2138"></span>
<span class="line" id="L2139"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> LinkError = UnexpectedError || <span class="tok-kw">error</span>{</span>
<span class="line" id="L2140">    AccessDenied,</span>
<span class="line" id="L2141">    DiskQuota,</span>
<span class="line" id="L2142">    PathAlreadyExists,</span>
<span class="line" id="L2143">    FileSystem,</span>
<span class="line" id="L2144">    SymLinkLoop,</span>
<span class="line" id="L2145">    LinkQuotaExceeded,</span>
<span class="line" id="L2146">    NameTooLong,</span>
<span class="line" id="L2147">    FileNotFound,</span>
<span class="line" id="L2148">    SystemResources,</span>
<span class="line" id="L2149">    NoSpaceLeft,</span>
<span class="line" id="L2150">    ReadOnlyFileSystem,</span>
<span class="line" id="L2151">    NotSameFileSystem,</span>
<span class="line" id="L2152">};</span>
<span class="line" id="L2153"></span>
<span class="line" id="L2154"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">linkZ</span>(oldpath: [*:<span class="tok-number">0</span>]<span class="tok-kw">const</span> <span class="tok-type">u8</span>, newpath: [*:<span class="tok-number">0</span>]<span class="tok-kw">const</span> <span class="tok-type">u8</span>, flags: <span class="tok-type">i32</span>) LinkError!<span class="tok-type">void</span> {</span>
<span class="line" id="L2155">    <span class="tok-kw">if</span> (builtin.os.tag == .wasi <span class="tok-kw">and</span> !builtin.link_libc) {</span>
<span class="line" id="L2156">        <span class="tok-kw">return</span> link(mem.sliceTo(oldpath, <span class="tok-number">0</span>), mem.sliceTo(newpath, <span class="tok-number">0</span>), flags);</span>
<span class="line" id="L2157">    }</span>
<span class="line" id="L2158">    <span class="tok-kw">switch</span> (errno(system.link(oldpath, newpath, flags))) {</span>
<span class="line" id="L2159">        .SUCCESS =&gt; <span class="tok-kw">return</span>,</span>
<span class="line" id="L2160">        .ACCES =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.AccessDenied,</span>
<span class="line" id="L2161">        .DQUOT =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.DiskQuota,</span>
<span class="line" id="L2162">        .EXIST =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.PathAlreadyExists,</span>
<span class="line" id="L2163">        .FAULT =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L2164">        .IO =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.FileSystem,</span>
<span class="line" id="L2165">        .LOOP =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.SymLinkLoop,</span>
<span class="line" id="L2166">        .MLINK =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.LinkQuotaExceeded,</span>
<span class="line" id="L2167">        .NAMETOOLONG =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.NameTooLong,</span>
<span class="line" id="L2168">        .NOENT =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.FileNotFound,</span>
<span class="line" id="L2169">        .NOMEM =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.SystemResources,</span>
<span class="line" id="L2170">        .NOSPC =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.NoSpaceLeft,</span>
<span class="line" id="L2171">        .PERM =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.AccessDenied,</span>
<span class="line" id="L2172">        .ROFS =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.ReadOnlyFileSystem,</span>
<span class="line" id="L2173">        .XDEV =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.NotSameFileSystem,</span>
<span class="line" id="L2174">        .INVAL =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L2175">        <span class="tok-kw">else</span> =&gt; |err| <span class="tok-kw">return</span> unexpectedErrno(err),</span>
<span class="line" id="L2176">    }</span>
<span class="line" id="L2177">}</span>
<span class="line" id="L2178"></span>
<span class="line" id="L2179"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">link</span>(oldpath: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>, newpath: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>, flags: <span class="tok-type">i32</span>) LinkError!<span class="tok-type">void</span> {</span>
<span class="line" id="L2180">    <span class="tok-kw">if</span> (builtin.os.tag == .wasi <span class="tok-kw">and</span> !builtin.link_libc) {</span>
<span class="line" id="L2181">        <span class="tok-kw">return</span> linkat(wasi.AT.FDCWD, oldpath, wasi.AT.FDCWD, newpath, flags) <span class="tok-kw">catch</span> |err| <span class="tok-kw">switch</span> (err) {</span>
<span class="line" id="L2182">            <span class="tok-kw">error</span>.NotDir =&gt; <span class="tok-kw">unreachable</span>, <span class="tok-comment">// link() does not support directories</span>
</span>
<span class="line" id="L2183">            <span class="tok-kw">else</span> =&gt; |e| <span class="tok-kw">return</span> e,</span>
<span class="line" id="L2184">        };</span>
<span class="line" id="L2185">    }</span>
<span class="line" id="L2186">    <span class="tok-kw">const</span> old = <span class="tok-kw">try</span> toPosixPath(oldpath);</span>
<span class="line" id="L2187">    <span class="tok-kw">const</span> new = <span class="tok-kw">try</span> toPosixPath(newpath);</span>
<span class="line" id="L2188">    <span class="tok-kw">return</span> <span class="tok-kw">try</span> linkZ(&amp;old, &amp;new, flags);</span>
<span class="line" id="L2189">}</span>
<span class="line" id="L2190"></span>
<span class="line" id="L2191"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> LinkatError = LinkError || <span class="tok-kw">error</span>{NotDir};</span>
<span class="line" id="L2192"></span>
<span class="line" id="L2193"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">linkatZ</span>(</span>
<span class="line" id="L2194">    olddir: fd_t,</span>
<span class="line" id="L2195">    oldpath: [*:<span class="tok-number">0</span>]<span class="tok-kw">const</span> <span class="tok-type">u8</span>,</span>
<span class="line" id="L2196">    newdir: fd_t,</span>
<span class="line" id="L2197">    newpath: [*:<span class="tok-number">0</span>]<span class="tok-kw">const</span> <span class="tok-type">u8</span>,</span>
<span class="line" id="L2198">    flags: <span class="tok-type">i32</span>,</span>
<span class="line" id="L2199">) LinkatError!<span class="tok-type">void</span> {</span>
<span class="line" id="L2200">    <span class="tok-kw">if</span> (builtin.os.tag == .wasi <span class="tok-kw">and</span> !builtin.link_libc) {</span>
<span class="line" id="L2201">        <span class="tok-kw">return</span> linkat(olddir, mem.sliceTo(oldpath, <span class="tok-number">0</span>), newdir, mem.sliceTo(newpath, <span class="tok-number">0</span>), flags);</span>
<span class="line" id="L2202">    }</span>
<span class="line" id="L2203">    <span class="tok-kw">switch</span> (errno(system.linkat(olddir, oldpath, newdir, newpath, flags))) {</span>
<span class="line" id="L2204">        .SUCCESS =&gt; <span class="tok-kw">return</span>,</span>
<span class="line" id="L2205">        .ACCES =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.AccessDenied,</span>
<span class="line" id="L2206">        .DQUOT =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.DiskQuota,</span>
<span class="line" id="L2207">        .EXIST =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.PathAlreadyExists,</span>
<span class="line" id="L2208">        .FAULT =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L2209">        .IO =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.FileSystem,</span>
<span class="line" id="L2210">        .LOOP =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.SymLinkLoop,</span>
<span class="line" id="L2211">        .MLINK =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.LinkQuotaExceeded,</span>
<span class="line" id="L2212">        .NAMETOOLONG =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.NameTooLong,</span>
<span class="line" id="L2213">        .NOENT =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.FileNotFound,</span>
<span class="line" id="L2214">        .NOMEM =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.SystemResources,</span>
<span class="line" id="L2215">        .NOSPC =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.NoSpaceLeft,</span>
<span class="line" id="L2216">        .NOTDIR =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.NotDir,</span>
<span class="line" id="L2217">        .PERM =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.AccessDenied,</span>
<span class="line" id="L2218">        .ROFS =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.ReadOnlyFileSystem,</span>
<span class="line" id="L2219">        .XDEV =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.NotSameFileSystem,</span>
<span class="line" id="L2220">        .INVAL =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L2221">        <span class="tok-kw">else</span> =&gt; |err| <span class="tok-kw">return</span> unexpectedErrno(err),</span>
<span class="line" id="L2222">    }</span>
<span class="line" id="L2223">}</span>
<span class="line" id="L2224"></span>
<span class="line" id="L2225"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">linkat</span>(</span>
<span class="line" id="L2226">    olddir: fd_t,</span>
<span class="line" id="L2227">    oldpath: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>,</span>
<span class="line" id="L2228">    newdir: fd_t,</span>
<span class="line" id="L2229">    newpath: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>,</span>
<span class="line" id="L2230">    flags: <span class="tok-type">i32</span>,</span>
<span class="line" id="L2231">) LinkatError!<span class="tok-type">void</span> {</span>
<span class="line" id="L2232">    <span class="tok-kw">if</span> (builtin.os.tag == .wasi <span class="tok-kw">and</span> !builtin.link_libc) {</span>
<span class="line" id="L2233">        <span class="tok-kw">var</span> resolve_olddir: <span class="tok-type">bool</span> = (olddir == wasi.AT.FDCWD <span class="tok-kw">or</span> fs.path.isAbsolute(oldpath));</span>
<span class="line" id="L2234">        <span class="tok-kw">var</span> resolve_newdir: <span class="tok-type">bool</span> = (newdir == wasi.AT.FDCWD <span class="tok-kw">or</span> fs.path.isAbsolute(newpath));</span>
<span class="line" id="L2235"></span>
<span class="line" id="L2236">        <span class="tok-kw">var</span> old: RelativePathWasi = .{ .dir_fd = olddir, .relative_path = oldpath };</span>
<span class="line" id="L2237">        <span class="tok-kw">var</span> new: RelativePathWasi = .{ .dir_fd = newdir, .relative_path = newpath };</span>
<span class="line" id="L2238"></span>
<span class="line" id="L2239">        <span class="tok-comment">// Resolve absolute or CWD-relative paths to a path within a Preopen</span>
</span>
<span class="line" id="L2240">        <span class="tok-kw">if</span> (resolve_olddir <span class="tok-kw">or</span> resolve_newdir) {</span>
<span class="line" id="L2241">            <span class="tok-kw">var</span> buf_old: [MAX_PATH_BYTES]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L2242">            <span class="tok-kw">var</span> buf_new: [MAX_PATH_BYTES]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L2243"></span>
<span class="line" id="L2244">            <span class="tok-kw">if</span> (resolve_olddir)</span>
<span class="line" id="L2245">                old = <span class="tok-kw">try</span> resolvePathWasi(oldpath, &amp;buf_old);</span>
<span class="line" id="L2246"></span>
<span class="line" id="L2247">            <span class="tok-kw">if</span> (resolve_newdir)</span>
<span class="line" id="L2248">                new = <span class="tok-kw">try</span> resolvePathWasi(newpath, &amp;buf_new);</span>
<span class="line" id="L2249"></span>
<span class="line" id="L2250">            <span class="tok-kw">return</span> linkatWasi(old, new, flags);</span>
<span class="line" id="L2251">        }</span>
<span class="line" id="L2252">        <span class="tok-kw">return</span> linkatWasi(old, new, flags);</span>
<span class="line" id="L2253">    }</span>
<span class="line" id="L2254">    <span class="tok-kw">const</span> old = <span class="tok-kw">try</span> toPosixPath(oldpath);</span>
<span class="line" id="L2255">    <span class="tok-kw">const</span> new = <span class="tok-kw">try</span> toPosixPath(newpath);</span>
<span class="line" id="L2256">    <span class="tok-kw">return</span> <span class="tok-kw">try</span> linkatZ(olddir, &amp;old, newdir, &amp;new, flags);</span>
<span class="line" id="L2257">}</span>
<span class="line" id="L2258"></span>
<span class="line" id="L2259"><span class="tok-comment">/// WASI-only. The same as `linkat` but targeting WASI.</span></span>
<span class="line" id="L2260"><span class="tok-comment">/// See also `linkat`.</span></span>
<span class="line" id="L2261"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">linkatWasi</span>(old: RelativePathWasi, new: RelativePathWasi, flags: <span class="tok-type">i32</span>) LinkatError!<span class="tok-type">void</span> {</span>
<span class="line" id="L2262">    <span class="tok-kw">var</span> old_flags: wasi.lookupflags_t = <span class="tok-number">0</span>;</span>
<span class="line" id="L2263">    <span class="tok-comment">// TODO: Why is this not defined in wasi-libc?</span>
</span>
<span class="line" id="L2264">    <span class="tok-kw">if</span> (flags &amp; linux.AT.SYMLINK_FOLLOW != <span class="tok-number">0</span>) old_flags |= wasi.LOOKUP_SYMLINK_FOLLOW;</span>
<span class="line" id="L2265"></span>
<span class="line" id="L2266">    <span class="tok-kw">switch</span> (wasi.path_link(old.dir_fd, old_flags, old.relative_path.ptr, old.relative_path.len, new.dir_fd, new.relative_path.ptr, new.relative_path.len)) {</span>
<span class="line" id="L2267">        .SUCCESS =&gt; <span class="tok-kw">return</span>,</span>
<span class="line" id="L2268">        .ACCES =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.AccessDenied,</span>
<span class="line" id="L2269">        .DQUOT =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.DiskQuota,</span>
<span class="line" id="L2270">        .EXIST =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.PathAlreadyExists,</span>
<span class="line" id="L2271">        .FAULT =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L2272">        .IO =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.FileSystem,</span>
<span class="line" id="L2273">        .LOOP =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.SymLinkLoop,</span>
<span class="line" id="L2274">        .MLINK =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.LinkQuotaExceeded,</span>
<span class="line" id="L2275">        .NAMETOOLONG =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.NameTooLong,</span>
<span class="line" id="L2276">        .NOENT =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.FileNotFound,</span>
<span class="line" id="L2277">        .NOMEM =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.SystemResources,</span>
<span class="line" id="L2278">        .NOSPC =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.NoSpaceLeft,</span>
<span class="line" id="L2279">        .NOTDIR =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.NotDir,</span>
<span class="line" id="L2280">        .PERM =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.AccessDenied,</span>
<span class="line" id="L2281">        .ROFS =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.ReadOnlyFileSystem,</span>
<span class="line" id="L2282">        .XDEV =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.NotSameFileSystem,</span>
<span class="line" id="L2283">        .INVAL =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L2284">        <span class="tok-kw">else</span> =&gt; |err| <span class="tok-kw">return</span> unexpectedErrno(err),</span>
<span class="line" id="L2285">    }</span>
<span class="line" id="L2286">}</span>
<span class="line" id="L2287"></span>
<span class="line" id="L2288"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> UnlinkError = <span class="tok-kw">error</span>{</span>
<span class="line" id="L2289">    FileNotFound,</span>
<span class="line" id="L2290"></span>
<span class="line" id="L2291">    <span class="tok-comment">/// In WASI, this error may occur when the file descriptor does</span></span>
<span class="line" id="L2292">    <span class="tok-comment">/// not hold the required rights to unlink a resource by path relative to it.</span></span>
<span class="line" id="L2293">    AccessDenied,</span>
<span class="line" id="L2294">    FileBusy,</span>
<span class="line" id="L2295">    FileSystem,</span>
<span class="line" id="L2296">    IsDir,</span>
<span class="line" id="L2297">    SymLinkLoop,</span>
<span class="line" id="L2298">    NameTooLong,</span>
<span class="line" id="L2299">    NotDir,</span>
<span class="line" id="L2300">    SystemResources,</span>
<span class="line" id="L2301">    ReadOnlyFileSystem,</span>
<span class="line" id="L2302"></span>
<span class="line" id="L2303">    <span class="tok-comment">/// On Windows, file paths must be valid Unicode.</span></span>
<span class="line" id="L2304">    InvalidUtf8,</span>
<span class="line" id="L2305"></span>
<span class="line" id="L2306">    <span class="tok-comment">/// On Windows, file paths cannot contain these characters:</span></span>
<span class="line" id="L2307">    <span class="tok-comment">/// '/', '*', '?', '&quot;', '&lt;', '&gt;', '|'</span></span>
<span class="line" id="L2308">    BadPathName,</span>
<span class="line" id="L2309">} || UnexpectedError;</span>
<span class="line" id="L2310"></span>
<span class="line" id="L2311"><span class="tok-comment">/// Delete a name and possibly the file it refers to.</span></span>
<span class="line" id="L2312"><span class="tok-comment">/// See also `unlinkZ`.</span></span>
<span class="line" id="L2313"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">unlink</span>(file_path: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) UnlinkError!<span class="tok-type">void</span> {</span>
<span class="line" id="L2314">    <span class="tok-kw">if</span> (builtin.os.tag == .wasi <span class="tok-kw">and</span> !builtin.link_libc) {</span>
<span class="line" id="L2315">        <span class="tok-kw">return</span> unlinkat(wasi.AT.FDCWD, file_path, <span class="tok-number">0</span>) <span class="tok-kw">catch</span> |err| <span class="tok-kw">switch</span> (err) {</span>
<span class="line" id="L2316">            <span class="tok-kw">error</span>.DirNotEmpty =&gt; <span class="tok-kw">unreachable</span>, <span class="tok-comment">// only occurs when targeting directories</span>
</span>
<span class="line" id="L2317">            <span class="tok-kw">else</span> =&gt; |e| <span class="tok-kw">return</span> e,</span>
<span class="line" id="L2318">        };</span>
<span class="line" id="L2319">    } <span class="tok-kw">else</span> <span class="tok-kw">if</span> (builtin.os.tag == .windows) {</span>
<span class="line" id="L2320">        <span class="tok-kw">const</span> file_path_w = <span class="tok-kw">try</span> windows.sliceToPrefixedFileW(file_path);</span>
<span class="line" id="L2321">        <span class="tok-kw">return</span> unlinkW(file_path_w.span());</span>
<span class="line" id="L2322">    } <span class="tok-kw">else</span> {</span>
<span class="line" id="L2323">        <span class="tok-kw">const</span> file_path_c = <span class="tok-kw">try</span> toPosixPath(file_path);</span>
<span class="line" id="L2324">        <span class="tok-kw">return</span> unlinkZ(&amp;file_path_c);</span>
<span class="line" id="L2325">    }</span>
<span class="line" id="L2326">}</span>
<span class="line" id="L2327"></span>
<span class="line" id="L2328"><span class="tok-comment">/// Same as `unlink` except the parameter is a null terminated UTF8-encoded string.</span></span>
<span class="line" id="L2329"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">unlinkZ</span>(file_path: [*:<span class="tok-number">0</span>]<span class="tok-kw">const</span> <span class="tok-type">u8</span>) UnlinkError!<span class="tok-type">void</span> {</span>
<span class="line" id="L2330">    <span class="tok-kw">if</span> (builtin.os.tag == .windows) {</span>
<span class="line" id="L2331">        <span class="tok-kw">const</span> file_path_w = <span class="tok-kw">try</span> windows.cStrToPrefixedFileW(file_path);</span>
<span class="line" id="L2332">        <span class="tok-kw">return</span> unlinkW(file_path_w.span());</span>
<span class="line" id="L2333">    } <span class="tok-kw">else</span> <span class="tok-kw">if</span> (builtin.os.tag == .wasi <span class="tok-kw">and</span> !builtin.link_libc) {</span>
<span class="line" id="L2334">        <span class="tok-kw">return</span> unlink(mem.sliceTo(file_path, <span class="tok-number">0</span>));</span>
<span class="line" id="L2335">    }</span>
<span class="line" id="L2336">    <span class="tok-kw">switch</span> (errno(system.unlink(file_path))) {</span>
<span class="line" id="L2337">        .SUCCESS =&gt; <span class="tok-kw">return</span>,</span>
<span class="line" id="L2338">        .ACCES =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.AccessDenied,</span>
<span class="line" id="L2339">        .PERM =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.AccessDenied,</span>
<span class="line" id="L2340">        .BUSY =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.FileBusy,</span>
<span class="line" id="L2341">        .FAULT =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L2342">        .INVAL =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L2343">        .IO =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.FileSystem,</span>
<span class="line" id="L2344">        .ISDIR =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.IsDir,</span>
<span class="line" id="L2345">        .LOOP =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.SymLinkLoop,</span>
<span class="line" id="L2346">        .NAMETOOLONG =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.NameTooLong,</span>
<span class="line" id="L2347">        .NOENT =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.FileNotFound,</span>
<span class="line" id="L2348">        .NOTDIR =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.NotDir,</span>
<span class="line" id="L2349">        .NOMEM =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.SystemResources,</span>
<span class="line" id="L2350">        .ROFS =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.ReadOnlyFileSystem,</span>
<span class="line" id="L2351">        <span class="tok-kw">else</span> =&gt; |err| <span class="tok-kw">return</span> unexpectedErrno(err),</span>
<span class="line" id="L2352">    }</span>
<span class="line" id="L2353">}</span>
<span class="line" id="L2354"></span>
<span class="line" id="L2355"><span class="tok-comment">/// Windows-only. Same as `unlink` except the parameter is null-terminated, WTF16 encoded.</span></span>
<span class="line" id="L2356"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">unlinkW</span>(file_path_w: []<span class="tok-kw">const</span> <span class="tok-type">u16</span>) UnlinkError!<span class="tok-type">void</span> {</span>
<span class="line" id="L2357">    <span class="tok-kw">return</span> windows.DeleteFile(file_path_w, .{ .dir = std.fs.cwd().fd });</span>
<span class="line" id="L2358">}</span>
<span class="line" id="L2359"></span>
<span class="line" id="L2360"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> UnlinkatError = UnlinkError || <span class="tok-kw">error</span>{</span>
<span class="line" id="L2361">    <span class="tok-comment">/// When passing `AT.REMOVEDIR`, this error occurs when the named directory is not empty.</span></span>
<span class="line" id="L2362">    DirNotEmpty,</span>
<span class="line" id="L2363">};</span>
<span class="line" id="L2364"></span>
<span class="line" id="L2365"><span class="tok-comment">/// Delete a file name and possibly the file it refers to, based on an open directory handle.</span></span>
<span class="line" id="L2366"><span class="tok-comment">/// Asserts that the path parameter has no null bytes.</span></span>
<span class="line" id="L2367"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">unlinkat</span>(dirfd: fd_t, file_path: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>, flags: <span class="tok-type">u32</span>) UnlinkatError!<span class="tok-type">void</span> {</span>
<span class="line" id="L2368">    <span class="tok-kw">if</span> (builtin.os.tag == .windows) {</span>
<span class="line" id="L2369">        <span class="tok-kw">const</span> file_path_w = <span class="tok-kw">try</span> windows.sliceToPrefixedFileW(file_path);</span>
<span class="line" id="L2370">        <span class="tok-kw">return</span> unlinkatW(dirfd, file_path_w.span(), flags);</span>
<span class="line" id="L2371">    } <span class="tok-kw">else</span> <span class="tok-kw">if</span> (builtin.os.tag == .wasi <span class="tok-kw">and</span> !builtin.link_libc) {</span>
<span class="line" id="L2372">        <span class="tok-kw">if</span> (dirfd == wasi.AT.FDCWD <span class="tok-kw">or</span> fs.path.isAbsolute(file_path)) {</span>
<span class="line" id="L2373">            <span class="tok-comment">// Resolve absolute or CWD-relative paths to a path within a Preopen</span>
</span>
<span class="line" id="L2374">            <span class="tok-kw">var</span> path_buf: [MAX_PATH_BYTES]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L2375">            <span class="tok-kw">const</span> path = <span class="tok-kw">try</span> resolvePathWasi(file_path, &amp;path_buf);</span>
<span class="line" id="L2376">            <span class="tok-kw">return</span> unlinkatWasi(path.dir_fd, path.relative_path, flags);</span>
<span class="line" id="L2377">        }</span>
<span class="line" id="L2378">        <span class="tok-kw">return</span> unlinkatWasi(dirfd, file_path, flags);</span>
<span class="line" id="L2379">    } <span class="tok-kw">else</span> {</span>
<span class="line" id="L2380">        <span class="tok-kw">const</span> file_path_c = <span class="tok-kw">try</span> toPosixPath(file_path);</span>
<span class="line" id="L2381">        <span class="tok-kw">return</span> unlinkatZ(dirfd, &amp;file_path_c, flags);</span>
<span class="line" id="L2382">    }</span>
<span class="line" id="L2383">}</span>
<span class="line" id="L2384"></span>
<span class="line" id="L2385"><span class="tok-comment">/// WASI-only. Same as `unlinkat` but targeting WASI.</span></span>
<span class="line" id="L2386"><span class="tok-comment">/// See also `unlinkat`.</span></span>
<span class="line" id="L2387"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">unlinkatWasi</span>(dirfd: fd_t, file_path: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>, flags: <span class="tok-type">u32</span>) UnlinkatError!<span class="tok-type">void</span> {</span>
<span class="line" id="L2388">    <span class="tok-kw">const</span> remove_dir = (flags &amp; AT.REMOVEDIR) != <span class="tok-number">0</span>;</span>
<span class="line" id="L2389">    <span class="tok-kw">const</span> res = <span class="tok-kw">if</span> (remove_dir)</span>
<span class="line" id="L2390">        wasi.path_remove_directory(dirfd, file_path.ptr, file_path.len)</span>
<span class="line" id="L2391">    <span class="tok-kw">else</span></span>
<span class="line" id="L2392">        wasi.path_unlink_file(dirfd, file_path.ptr, file_path.len);</span>
<span class="line" id="L2393">    <span class="tok-kw">switch</span> (res) {</span>
<span class="line" id="L2394">        .SUCCESS =&gt; <span class="tok-kw">return</span>,</span>
<span class="line" id="L2395">        .ACCES =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.AccessDenied,</span>
<span class="line" id="L2396">        .PERM =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.AccessDenied,</span>
<span class="line" id="L2397">        .BUSY =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.FileBusy,</span>
<span class="line" id="L2398">        .FAULT =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L2399">        .IO =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.FileSystem,</span>
<span class="line" id="L2400">        .ISDIR =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.IsDir,</span>
<span class="line" id="L2401">        .LOOP =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.SymLinkLoop,</span>
<span class="line" id="L2402">        .NAMETOOLONG =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.NameTooLong,</span>
<span class="line" id="L2403">        .NOENT =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.FileNotFound,</span>
<span class="line" id="L2404">        .NOTDIR =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.NotDir,</span>
<span class="line" id="L2405">        .NOMEM =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.SystemResources,</span>
<span class="line" id="L2406">        .ROFS =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.ReadOnlyFileSystem,</span>
<span class="line" id="L2407">        .NOTEMPTY =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.DirNotEmpty,</span>
<span class="line" id="L2408">        .NOTCAPABLE =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.AccessDenied,</span>
<span class="line" id="L2409"></span>
<span class="line" id="L2410">        .INVAL =&gt; <span class="tok-kw">unreachable</span>, <span class="tok-comment">// invalid flags, or pathname has . as last component</span>
</span>
<span class="line" id="L2411">        .BADF =&gt; <span class="tok-kw">unreachable</span>, <span class="tok-comment">// always a race condition</span>
</span>
<span class="line" id="L2412"></span>
<span class="line" id="L2413">        <span class="tok-kw">else</span> =&gt; |err| <span class="tok-kw">return</span> unexpectedErrno(err),</span>
<span class="line" id="L2414">    }</span>
<span class="line" id="L2415">}</span>
<span class="line" id="L2416"></span>
<span class="line" id="L2417"><span class="tok-comment">/// Same as `unlinkat` but `file_path` is a null-terminated string.</span></span>
<span class="line" id="L2418"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">unlinkatZ</span>(dirfd: fd_t, file_path_c: [*:<span class="tok-number">0</span>]<span class="tok-kw">const</span> <span class="tok-type">u8</span>, flags: <span class="tok-type">u32</span>) UnlinkatError!<span class="tok-type">void</span> {</span>
<span class="line" id="L2419">    <span class="tok-kw">if</span> (builtin.os.tag == .windows) {</span>
<span class="line" id="L2420">        <span class="tok-kw">const</span> file_path_w = <span class="tok-kw">try</span> windows.cStrToPrefixedFileW(file_path_c);</span>
<span class="line" id="L2421">        <span class="tok-kw">return</span> unlinkatW(dirfd, file_path_w.span(), flags);</span>
<span class="line" id="L2422">    } <span class="tok-kw">else</span> <span class="tok-kw">if</span> (builtin.os.tag == .wasi <span class="tok-kw">and</span> !builtin.link_libc) {</span>
<span class="line" id="L2423">        <span class="tok-kw">return</span> unlinkat(dirfd, mem.sliceTo(file_path_c, <span class="tok-number">0</span>), flags);</span>
<span class="line" id="L2424">    }</span>
<span class="line" id="L2425">    <span class="tok-kw">switch</span> (errno(system.unlinkat(dirfd, file_path_c, flags))) {</span>
<span class="line" id="L2426">        .SUCCESS =&gt; <span class="tok-kw">return</span>,</span>
<span class="line" id="L2427">        .ACCES =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.AccessDenied,</span>
<span class="line" id="L2428">        .PERM =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.AccessDenied,</span>
<span class="line" id="L2429">        .BUSY =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.FileBusy,</span>
<span class="line" id="L2430">        .FAULT =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L2431">        .IO =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.FileSystem,</span>
<span class="line" id="L2432">        .ISDIR =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.IsDir,</span>
<span class="line" id="L2433">        .LOOP =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.SymLinkLoop,</span>
<span class="line" id="L2434">        .NAMETOOLONG =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.NameTooLong,</span>
<span class="line" id="L2435">        .NOENT =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.FileNotFound,</span>
<span class="line" id="L2436">        .NOTDIR =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.NotDir,</span>
<span class="line" id="L2437">        .NOMEM =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.SystemResources,</span>
<span class="line" id="L2438">        .ROFS =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.ReadOnlyFileSystem,</span>
<span class="line" id="L2439">        .EXIST =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.DirNotEmpty,</span>
<span class="line" id="L2440">        .NOTEMPTY =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.DirNotEmpty,</span>
<span class="line" id="L2441"></span>
<span class="line" id="L2442">        .INVAL =&gt; <span class="tok-kw">unreachable</span>, <span class="tok-comment">// invalid flags, or pathname has . as last component</span>
</span>
<span class="line" id="L2443">        .BADF =&gt; <span class="tok-kw">unreachable</span>, <span class="tok-comment">// always a race condition</span>
</span>
<span class="line" id="L2444"></span>
<span class="line" id="L2445">        <span class="tok-kw">else</span> =&gt; |err| <span class="tok-kw">return</span> unexpectedErrno(err),</span>
<span class="line" id="L2446">    }</span>
<span class="line" id="L2447">}</span>
<span class="line" id="L2448"></span>
<span class="line" id="L2449"><span class="tok-comment">/// Same as `unlinkat` but `sub_path_w` is UTF16LE, NT prefixed. Windows only.</span></span>
<span class="line" id="L2450"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">unlinkatW</span>(dirfd: fd_t, sub_path_w: []<span class="tok-kw">const</span> <span class="tok-type">u16</span>, flags: <span class="tok-type">u32</span>) UnlinkatError!<span class="tok-type">void</span> {</span>
<span class="line" id="L2451">    <span class="tok-kw">const</span> remove_dir = (flags &amp; AT.REMOVEDIR) != <span class="tok-number">0</span>;</span>
<span class="line" id="L2452">    <span class="tok-kw">return</span> windows.DeleteFile(sub_path_w, .{ .dir = dirfd, .remove_dir = remove_dir });</span>
<span class="line" id="L2453">}</span>
<span class="line" id="L2454"></span>
<span class="line" id="L2455"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> RenameError = <span class="tok-kw">error</span>{</span>
<span class="line" id="L2456">    <span class="tok-comment">/// In WASI, this error may occur when the file descriptor does</span></span>
<span class="line" id="L2457">    <span class="tok-comment">/// not hold the required rights to rename a resource by path relative to it.</span></span>
<span class="line" id="L2458">    AccessDenied,</span>
<span class="line" id="L2459">    FileBusy,</span>
<span class="line" id="L2460">    DiskQuota,</span>
<span class="line" id="L2461">    IsDir,</span>
<span class="line" id="L2462">    SymLinkLoop,</span>
<span class="line" id="L2463">    LinkQuotaExceeded,</span>
<span class="line" id="L2464">    NameTooLong,</span>
<span class="line" id="L2465">    FileNotFound,</span>
<span class="line" id="L2466">    NotDir,</span>
<span class="line" id="L2467">    SystemResources,</span>
<span class="line" id="L2468">    NoSpaceLeft,</span>
<span class="line" id="L2469">    PathAlreadyExists,</span>
<span class="line" id="L2470">    ReadOnlyFileSystem,</span>
<span class="line" id="L2471">    RenameAcrossMountPoints,</span>
<span class="line" id="L2472">    InvalidUtf8,</span>
<span class="line" id="L2473">    BadPathName,</span>
<span class="line" id="L2474">    NoDevice,</span>
<span class="line" id="L2475">    SharingViolation,</span>
<span class="line" id="L2476">    PipeBusy,</span>
<span class="line" id="L2477">} || UnexpectedError;</span>
<span class="line" id="L2478"></span>
<span class="line" id="L2479"><span class="tok-comment">/// Change the name or location of a file.</span></span>
<span class="line" id="L2480"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">rename</span>(old_path: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>, new_path: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) RenameError!<span class="tok-type">void</span> {</span>
<span class="line" id="L2481">    <span class="tok-kw">if</span> (builtin.os.tag == .wasi <span class="tok-kw">and</span> !builtin.link_libc) {</span>
<span class="line" id="L2482">        <span class="tok-kw">return</span> renameat(wasi.AT.FDCWD, old_path, wasi.AT.FDCWD, new_path);</span>
<span class="line" id="L2483">    } <span class="tok-kw">else</span> <span class="tok-kw">if</span> (builtin.os.tag == .windows) {</span>
<span class="line" id="L2484">        <span class="tok-kw">const</span> old_path_w = <span class="tok-kw">try</span> windows.sliceToPrefixedFileW(old_path);</span>
<span class="line" id="L2485">        <span class="tok-kw">const</span> new_path_w = <span class="tok-kw">try</span> windows.sliceToPrefixedFileW(new_path);</span>
<span class="line" id="L2486">        <span class="tok-kw">return</span> renameW(old_path_w.span().ptr, new_path_w.span().ptr);</span>
<span class="line" id="L2487">    } <span class="tok-kw">else</span> {</span>
<span class="line" id="L2488">        <span class="tok-kw">const</span> old_path_c = <span class="tok-kw">try</span> toPosixPath(old_path);</span>
<span class="line" id="L2489">        <span class="tok-kw">const</span> new_path_c = <span class="tok-kw">try</span> toPosixPath(new_path);</span>
<span class="line" id="L2490">        <span class="tok-kw">return</span> renameZ(&amp;old_path_c, &amp;new_path_c);</span>
<span class="line" id="L2491">    }</span>
<span class="line" id="L2492">}</span>
<span class="line" id="L2493"></span>
<span class="line" id="L2494"><span class="tok-comment">/// Same as `rename` except the parameters are null-terminated byte arrays.</span></span>
<span class="line" id="L2495"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">renameZ</span>(old_path: [*:<span class="tok-number">0</span>]<span class="tok-kw">const</span> <span class="tok-type">u8</span>, new_path: [*:<span class="tok-number">0</span>]<span class="tok-kw">const</span> <span class="tok-type">u8</span>) RenameError!<span class="tok-type">void</span> {</span>
<span class="line" id="L2496">    <span class="tok-kw">if</span> (builtin.os.tag == .windows) {</span>
<span class="line" id="L2497">        <span class="tok-kw">const</span> old_path_w = <span class="tok-kw">try</span> windows.cStrToPrefixedFileW(old_path);</span>
<span class="line" id="L2498">        <span class="tok-kw">const</span> new_path_w = <span class="tok-kw">try</span> windows.cStrToPrefixedFileW(new_path);</span>
<span class="line" id="L2499">        <span class="tok-kw">return</span> renameW(old_path_w.span().ptr, new_path_w.span().ptr);</span>
<span class="line" id="L2500">    } <span class="tok-kw">else</span> <span class="tok-kw">if</span> (builtin.os.tag == .wasi <span class="tok-kw">and</span> !builtin.link_libc) {</span>
<span class="line" id="L2501">        <span class="tok-kw">return</span> rename(mem.sliceTo(old_path, <span class="tok-number">0</span>), mem.sliceTo(new_path, <span class="tok-number">0</span>));</span>
<span class="line" id="L2502">    }</span>
<span class="line" id="L2503">    <span class="tok-kw">switch</span> (errno(system.rename(old_path, new_path))) {</span>
<span class="line" id="L2504">        .SUCCESS =&gt; <span class="tok-kw">return</span>,</span>
<span class="line" id="L2505">        .ACCES =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.AccessDenied,</span>
<span class="line" id="L2506">        .PERM =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.AccessDenied,</span>
<span class="line" id="L2507">        .BUSY =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.FileBusy,</span>
<span class="line" id="L2508">        .DQUOT =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.DiskQuota,</span>
<span class="line" id="L2509">        .FAULT =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L2510">        .INVAL =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L2511">        .ISDIR =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.IsDir,</span>
<span class="line" id="L2512">        .LOOP =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.SymLinkLoop,</span>
<span class="line" id="L2513">        .MLINK =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.LinkQuotaExceeded,</span>
<span class="line" id="L2514">        .NAMETOOLONG =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.NameTooLong,</span>
<span class="line" id="L2515">        .NOENT =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.FileNotFound,</span>
<span class="line" id="L2516">        .NOTDIR =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.NotDir,</span>
<span class="line" id="L2517">        .NOMEM =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.SystemResources,</span>
<span class="line" id="L2518">        .NOSPC =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.NoSpaceLeft,</span>
<span class="line" id="L2519">        .EXIST =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.PathAlreadyExists,</span>
<span class="line" id="L2520">        .NOTEMPTY =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.PathAlreadyExists,</span>
<span class="line" id="L2521">        .ROFS =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.ReadOnlyFileSystem,</span>
<span class="line" id="L2522">        .XDEV =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.RenameAcrossMountPoints,</span>
<span class="line" id="L2523">        <span class="tok-kw">else</span> =&gt; |err| <span class="tok-kw">return</span> unexpectedErrno(err),</span>
<span class="line" id="L2524">    }</span>
<span class="line" id="L2525">}</span>
<span class="line" id="L2526"></span>
<span class="line" id="L2527"><span class="tok-comment">/// Same as `rename` except the parameters are null-terminated UTF16LE encoded byte arrays.</span></span>
<span class="line" id="L2528"><span class="tok-comment">/// Assumes target is Windows.</span></span>
<span class="line" id="L2529"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">renameW</span>(old_path: [*:<span class="tok-number">0</span>]<span class="tok-kw">const</span> <span class="tok-type">u16</span>, new_path: [*:<span class="tok-number">0</span>]<span class="tok-kw">const</span> <span class="tok-type">u16</span>) RenameError!<span class="tok-type">void</span> {</span>
<span class="line" id="L2530">    <span class="tok-kw">const</span> flags = windows.MOVEFILE_REPLACE_EXISTING | windows.MOVEFILE_WRITE_THROUGH;</span>
<span class="line" id="L2531">    <span class="tok-kw">return</span> windows.MoveFileExW(old_path, new_path, flags);</span>
<span class="line" id="L2532">}</span>
<span class="line" id="L2533"></span>
<span class="line" id="L2534"><span class="tok-comment">/// Change the name or location of a file based on an open directory handle.</span></span>
<span class="line" id="L2535"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">renameat</span>(</span>
<span class="line" id="L2536">    old_dir_fd: fd_t,</span>
<span class="line" id="L2537">    old_path: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>,</span>
<span class="line" id="L2538">    new_dir_fd: fd_t,</span>
<span class="line" id="L2539">    new_path: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>,</span>
<span class="line" id="L2540">) RenameError!<span class="tok-type">void</span> {</span>
<span class="line" id="L2541">    <span class="tok-kw">if</span> (builtin.os.tag == .windows) {</span>
<span class="line" id="L2542">        <span class="tok-kw">const</span> old_path_w = <span class="tok-kw">try</span> windows.sliceToPrefixedFileW(old_path);</span>
<span class="line" id="L2543">        <span class="tok-kw">const</span> new_path_w = <span class="tok-kw">try</span> windows.sliceToPrefixedFileW(new_path);</span>
<span class="line" id="L2544">        <span class="tok-kw">return</span> renameatW(old_dir_fd, old_path_w.span(), new_dir_fd, new_path_w.span(), windows.TRUE);</span>
<span class="line" id="L2545">    } <span class="tok-kw">else</span> <span class="tok-kw">if</span> (builtin.os.tag == .wasi <span class="tok-kw">and</span> !builtin.link_libc) {</span>
<span class="line" id="L2546">        <span class="tok-kw">var</span> resolve_old: <span class="tok-type">bool</span> = (old_dir_fd == wasi.AT.FDCWD <span class="tok-kw">or</span> fs.path.isAbsolute(old_path));</span>
<span class="line" id="L2547">        <span class="tok-kw">var</span> resolve_new: <span class="tok-type">bool</span> = (new_dir_fd == wasi.AT.FDCWD <span class="tok-kw">or</span> fs.path.isAbsolute(new_path));</span>
<span class="line" id="L2548"></span>
<span class="line" id="L2549">        <span class="tok-kw">var</span> old: RelativePathWasi = .{ .dir_fd = old_dir_fd, .relative_path = old_path };</span>
<span class="line" id="L2550">        <span class="tok-kw">var</span> new: RelativePathWasi = .{ .dir_fd = new_dir_fd, .relative_path = new_path };</span>
<span class="line" id="L2551"></span>
<span class="line" id="L2552">        <span class="tok-comment">// Resolve absolute or CWD-relative paths to a path within a Preopen</span>
</span>
<span class="line" id="L2553">        <span class="tok-kw">if</span> (resolve_old <span class="tok-kw">or</span> resolve_new) {</span>
<span class="line" id="L2554">            <span class="tok-kw">var</span> buf_old: [MAX_PATH_BYTES]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L2555">            <span class="tok-kw">var</span> buf_new: [MAX_PATH_BYTES]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L2556"></span>
<span class="line" id="L2557">            <span class="tok-kw">if</span> (resolve_old)</span>
<span class="line" id="L2558">                old = <span class="tok-kw">try</span> resolvePathWasi(old_path, &amp;buf_old);</span>
<span class="line" id="L2559">            <span class="tok-kw">if</span> (resolve_new)</span>
<span class="line" id="L2560">                new = <span class="tok-kw">try</span> resolvePathWasi(new_path, &amp;buf_new);</span>
<span class="line" id="L2561"></span>
<span class="line" id="L2562">            <span class="tok-kw">return</span> renameatWasi(old, new);</span>
<span class="line" id="L2563">        }</span>
<span class="line" id="L2564">        <span class="tok-kw">return</span> renameatWasi(old, new);</span>
<span class="line" id="L2565">    } <span class="tok-kw">else</span> {</span>
<span class="line" id="L2566">        <span class="tok-kw">const</span> old_path_c = <span class="tok-kw">try</span> toPosixPath(old_path);</span>
<span class="line" id="L2567">        <span class="tok-kw">const</span> new_path_c = <span class="tok-kw">try</span> toPosixPath(new_path);</span>
<span class="line" id="L2568">        <span class="tok-kw">return</span> renameatZ(old_dir_fd, &amp;old_path_c, new_dir_fd, &amp;new_path_c);</span>
<span class="line" id="L2569">    }</span>
<span class="line" id="L2570">}</span>
<span class="line" id="L2571"></span>
<span class="line" id="L2572"><span class="tok-comment">/// WASI-only. Same as `renameat` expect targeting WASI.</span></span>
<span class="line" id="L2573"><span class="tok-comment">/// See also `renameat`.</span></span>
<span class="line" id="L2574"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">renameatWasi</span>(old: RelativePathWasi, new: RelativePathWasi) RenameError!<span class="tok-type">void</span> {</span>
<span class="line" id="L2575">    <span class="tok-kw">switch</span> (wasi.path_rename(old.dir_fd, old.relative_path.ptr, old.relative_path.len, new.dir_fd, new.relative_path.ptr, new.relative_path.len)) {</span>
<span class="line" id="L2576">        .SUCCESS =&gt; <span class="tok-kw">return</span>,</span>
<span class="line" id="L2577">        .ACCES =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.AccessDenied,</span>
<span class="line" id="L2578">        .PERM =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.AccessDenied,</span>
<span class="line" id="L2579">        .BUSY =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.FileBusy,</span>
<span class="line" id="L2580">        .DQUOT =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.DiskQuota,</span>
<span class="line" id="L2581">        .FAULT =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L2582">        .INVAL =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L2583">        .ISDIR =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.IsDir,</span>
<span class="line" id="L2584">        .LOOP =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.SymLinkLoop,</span>
<span class="line" id="L2585">        .MLINK =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.LinkQuotaExceeded,</span>
<span class="line" id="L2586">        .NAMETOOLONG =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.NameTooLong,</span>
<span class="line" id="L2587">        .NOENT =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.FileNotFound,</span>
<span class="line" id="L2588">        .NOTDIR =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.NotDir,</span>
<span class="line" id="L2589">        .NOMEM =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.SystemResources,</span>
<span class="line" id="L2590">        .NOSPC =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.NoSpaceLeft,</span>
<span class="line" id="L2591">        .EXIST =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.PathAlreadyExists,</span>
<span class="line" id="L2592">        .NOTEMPTY =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.PathAlreadyExists,</span>
<span class="line" id="L2593">        .ROFS =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.ReadOnlyFileSystem,</span>
<span class="line" id="L2594">        .XDEV =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.RenameAcrossMountPoints,</span>
<span class="line" id="L2595">        .NOTCAPABLE =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.AccessDenied,</span>
<span class="line" id="L2596">        <span class="tok-kw">else</span> =&gt; |err| <span class="tok-kw">return</span> unexpectedErrno(err),</span>
<span class="line" id="L2597">    }</span>
<span class="line" id="L2598">}</span>
<span class="line" id="L2599"></span>
<span class="line" id="L2600"><span class="tok-comment">/// Same as `renameat` except the parameters are null-terminated byte arrays.</span></span>
<span class="line" id="L2601"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">renameatZ</span>(</span>
<span class="line" id="L2602">    old_dir_fd: fd_t,</span>
<span class="line" id="L2603">    old_path: [*:<span class="tok-number">0</span>]<span class="tok-kw">const</span> <span class="tok-type">u8</span>,</span>
<span class="line" id="L2604">    new_dir_fd: fd_t,</span>
<span class="line" id="L2605">    new_path: [*:<span class="tok-number">0</span>]<span class="tok-kw">const</span> <span class="tok-type">u8</span>,</span>
<span class="line" id="L2606">) RenameError!<span class="tok-type">void</span> {</span>
<span class="line" id="L2607">    <span class="tok-kw">if</span> (builtin.os.tag == .windows) {</span>
<span class="line" id="L2608">        <span class="tok-kw">const</span> old_path_w = <span class="tok-kw">try</span> windows.cStrToPrefixedFileW(old_path);</span>
<span class="line" id="L2609">        <span class="tok-kw">const</span> new_path_w = <span class="tok-kw">try</span> windows.cStrToPrefixedFileW(new_path);</span>
<span class="line" id="L2610">        <span class="tok-kw">return</span> renameatW(old_dir_fd, old_path_w.span(), new_dir_fd, new_path_w.span(), windows.TRUE);</span>
<span class="line" id="L2611">    } <span class="tok-kw">else</span> <span class="tok-kw">if</span> (builtin.os.tag == .wasi <span class="tok-kw">and</span> !builtin.link_libc) {</span>
<span class="line" id="L2612">        <span class="tok-kw">return</span> renameat(old_dir_fd, mem.sliceTo(old_path, <span class="tok-number">0</span>), new_dir_fd, mem.sliceTo(new_path, <span class="tok-number">0</span>));</span>
<span class="line" id="L2613">    }</span>
<span class="line" id="L2614"></span>
<span class="line" id="L2615">    <span class="tok-kw">switch</span> (errno(system.renameat(old_dir_fd, old_path, new_dir_fd, new_path))) {</span>
<span class="line" id="L2616">        .SUCCESS =&gt; <span class="tok-kw">return</span>,</span>
<span class="line" id="L2617">        .ACCES =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.AccessDenied,</span>
<span class="line" id="L2618">        .PERM =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.AccessDenied,</span>
<span class="line" id="L2619">        .BUSY =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.FileBusy,</span>
<span class="line" id="L2620">        .DQUOT =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.DiskQuota,</span>
<span class="line" id="L2621">        .FAULT =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L2622">        .INVAL =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L2623">        .ISDIR =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.IsDir,</span>
<span class="line" id="L2624">        .LOOP =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.SymLinkLoop,</span>
<span class="line" id="L2625">        .MLINK =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.LinkQuotaExceeded,</span>
<span class="line" id="L2626">        .NAMETOOLONG =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.NameTooLong,</span>
<span class="line" id="L2627">        .NOENT =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.FileNotFound,</span>
<span class="line" id="L2628">        .NOTDIR =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.NotDir,</span>
<span class="line" id="L2629">        .NOMEM =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.SystemResources,</span>
<span class="line" id="L2630">        .NOSPC =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.NoSpaceLeft,</span>
<span class="line" id="L2631">        .EXIST =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.PathAlreadyExists,</span>
<span class="line" id="L2632">        .NOTEMPTY =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.PathAlreadyExists,</span>
<span class="line" id="L2633">        .ROFS =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.ReadOnlyFileSystem,</span>
<span class="line" id="L2634">        .XDEV =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.RenameAcrossMountPoints,</span>
<span class="line" id="L2635">        <span class="tok-kw">else</span> =&gt; |err| <span class="tok-kw">return</span> unexpectedErrno(err),</span>
<span class="line" id="L2636">    }</span>
<span class="line" id="L2637">}</span>
<span class="line" id="L2638"></span>
<span class="line" id="L2639"><span class="tok-comment">/// Same as `renameat` but Windows-only and the path parameters are</span></span>
<span class="line" id="L2640"><span class="tok-comment">/// [WTF-16](https://simonsapin.github.io/wtf-8/#potentially-ill-formed-utf-16) encoded.</span></span>
<span class="line" id="L2641"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">renameatW</span>(</span>
<span class="line" id="L2642">    old_dir_fd: fd_t,</span>
<span class="line" id="L2643">    old_path_w: []<span class="tok-kw">const</span> <span class="tok-type">u16</span>,</span>
<span class="line" id="L2644">    new_dir_fd: fd_t,</span>
<span class="line" id="L2645">    new_path_w: []<span class="tok-kw">const</span> <span class="tok-type">u16</span>,</span>
<span class="line" id="L2646">    ReplaceIfExists: windows.BOOLEAN,</span>
<span class="line" id="L2647">) RenameError!<span class="tok-type">void</span> {</span>
<span class="line" id="L2648">    <span class="tok-kw">const</span> src_fd = windows.OpenFile(old_path_w, .{</span>
<span class="line" id="L2649">        .dir = old_dir_fd,</span>
<span class="line" id="L2650">        .access_mask = windows.SYNCHRONIZE | windows.GENERIC_WRITE | windows.DELETE,</span>
<span class="line" id="L2651">        .creation = windows.FILE_OPEN,</span>
<span class="line" id="L2652">        .io_mode = .blocking,</span>
<span class="line" id="L2653">        .filter = .any, <span class="tok-comment">// This function is supposed to rename both files and directories.</span>
</span>
<span class="line" id="L2654">        .follow_symlinks = <span class="tok-null">false</span>,</span>
<span class="line" id="L2655">    }) <span class="tok-kw">catch</span> |err| <span class="tok-kw">switch</span> (err) {</span>
<span class="line" id="L2656">        <span class="tok-kw">error</span>.WouldBlock =&gt; <span class="tok-kw">unreachable</span>, <span class="tok-comment">// Not possible without `.share_access_nonblocking = true`.</span>
</span>
<span class="line" id="L2657">        <span class="tok-kw">else</span> =&gt; |e| <span class="tok-kw">return</span> e,</span>
<span class="line" id="L2658">    };</span>
<span class="line" id="L2659">    <span class="tok-kw">defer</span> windows.CloseHandle(src_fd);</span>
<span class="line" id="L2660"></span>
<span class="line" id="L2661">    <span class="tok-kw">const</span> struct_buf_len = <span class="tok-builtin">@sizeOf</span>(windows.FILE_RENAME_INFORMATION) + (MAX_PATH_BYTES - <span class="tok-number">1</span>);</span>
<span class="line" id="L2662">    <span class="tok-kw">var</span> rename_info_buf: [struct_buf_len]<span class="tok-type">u8</span> <span class="tok-kw">align</span>(<span class="tok-builtin">@alignOf</span>(windows.FILE_RENAME_INFORMATION)) = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L2663">    <span class="tok-kw">const</span> struct_len = <span class="tok-builtin">@sizeOf</span>(windows.FILE_RENAME_INFORMATION) - <span class="tok-number">1</span> + new_path_w.len * <span class="tok-number">2</span>;</span>
<span class="line" id="L2664">    <span class="tok-kw">if</span> (struct_len &gt; struct_buf_len) <span class="tok-kw">return</span> <span class="tok-kw">error</span>.NameTooLong;</span>
<span class="line" id="L2665"></span>
<span class="line" id="L2666">    <span class="tok-kw">const</span> rename_info = <span class="tok-builtin">@ptrCast</span>(*windows.FILE_RENAME_INFORMATION, &amp;rename_info_buf);</span>
<span class="line" id="L2667"></span>
<span class="line" id="L2668">    rename_info.* = .{</span>
<span class="line" id="L2669">        .ReplaceIfExists = ReplaceIfExists,</span>
<span class="line" id="L2670">        .RootDirectory = <span class="tok-kw">if</span> (std.fs.path.isAbsoluteWindowsWTF16(new_path_w)) <span class="tok-null">null</span> <span class="tok-kw">else</span> new_dir_fd,</span>
<span class="line" id="L2671">        .FileNameLength = <span class="tok-builtin">@intCast</span>(<span class="tok-type">u32</span>, new_path_w.len * <span class="tok-number">2</span>), <span class="tok-comment">// already checked error.NameTooLong</span>
</span>
<span class="line" id="L2672">        .FileName = <span class="tok-null">undefined</span>,</span>
<span class="line" id="L2673">    };</span>
<span class="line" id="L2674">    std.mem.copy(<span class="tok-type">u16</span>, <span class="tok-builtin">@as</span>([*]<span class="tok-type">u16</span>, &amp;rename_info.FileName)[<span class="tok-number">0</span>..new_path_w.len], new_path_w);</span>
<span class="line" id="L2675"></span>
<span class="line" id="L2676">    <span class="tok-kw">var</span> io_status_block: windows.IO_STATUS_BLOCK = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L2677"></span>
<span class="line" id="L2678">    <span class="tok-kw">const</span> rc = windows.ntdll.NtSetInformationFile(</span>
<span class="line" id="L2679">        src_fd,</span>
<span class="line" id="L2680">        &amp;io_status_block,</span>
<span class="line" id="L2681">        rename_info,</span>
<span class="line" id="L2682">        <span class="tok-builtin">@intCast</span>(<span class="tok-type">u32</span>, struct_len), <span class="tok-comment">// already checked for error.NameTooLong</span>
</span>
<span class="line" id="L2683">        .FileRenameInformation,</span>
<span class="line" id="L2684">    );</span>
<span class="line" id="L2685"></span>
<span class="line" id="L2686">    <span class="tok-kw">switch</span> (rc) {</span>
<span class="line" id="L2687">        .SUCCESS =&gt; <span class="tok-kw">return</span>,</span>
<span class="line" id="L2688">        .INVALID_HANDLE =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L2689">        .INVALID_PARAMETER =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L2690">        .OBJECT_PATH_SYNTAX_BAD =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L2691">        .ACCESS_DENIED =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.AccessDenied,</span>
<span class="line" id="L2692">        .OBJECT_NAME_NOT_FOUND =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.FileNotFound,</span>
<span class="line" id="L2693">        .OBJECT_PATH_NOT_FOUND =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.FileNotFound,</span>
<span class="line" id="L2694">        .NOT_SAME_DEVICE =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.RenameAcrossMountPoints,</span>
<span class="line" id="L2695">        <span class="tok-kw">else</span> =&gt; <span class="tok-kw">return</span> windows.unexpectedStatus(rc),</span>
<span class="line" id="L2696">    }</span>
<span class="line" id="L2697">}</span>
<span class="line" id="L2698"></span>
<span class="line" id="L2699"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">mkdirat</span>(dir_fd: fd_t, sub_dir_path: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>, mode: <span class="tok-type">u32</span>) MakeDirError!<span class="tok-type">void</span> {</span>
<span class="line" id="L2700">    <span class="tok-kw">if</span> (builtin.os.tag == .windows) {</span>
<span class="line" id="L2701">        <span class="tok-kw">const</span> sub_dir_path_w = <span class="tok-kw">try</span> windows.sliceToPrefixedFileW(sub_dir_path);</span>
<span class="line" id="L2702">        <span class="tok-kw">return</span> mkdiratW(dir_fd, sub_dir_path_w.span(), mode);</span>
<span class="line" id="L2703">    } <span class="tok-kw">else</span> <span class="tok-kw">if</span> (builtin.os.tag == .wasi <span class="tok-kw">and</span> !builtin.link_libc) {</span>
<span class="line" id="L2704">        <span class="tok-kw">if</span> (dir_fd == wasi.AT.FDCWD <span class="tok-kw">or</span> fs.path.isAbsolute(sub_dir_path)) {</span>
<span class="line" id="L2705">            <span class="tok-comment">// Resolve absolute or CWD-relative paths to a path within a Preopen</span>
</span>
<span class="line" id="L2706">            <span class="tok-kw">var</span> path_buf: [MAX_PATH_BYTES]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L2707">            <span class="tok-kw">const</span> path = <span class="tok-kw">try</span> resolvePathWasi(sub_dir_path, &amp;path_buf);</span>
<span class="line" id="L2708">            <span class="tok-kw">return</span> mkdiratWasi(path.dir_fd, path.relative_path, mode);</span>
<span class="line" id="L2709">        }</span>
<span class="line" id="L2710">        <span class="tok-kw">return</span> mkdiratWasi(dir_fd, sub_dir_path, mode);</span>
<span class="line" id="L2711">    } <span class="tok-kw">else</span> {</span>
<span class="line" id="L2712">        <span class="tok-kw">const</span> sub_dir_path_c = <span class="tok-kw">try</span> toPosixPath(sub_dir_path);</span>
<span class="line" id="L2713">        <span class="tok-kw">return</span> mkdiratZ(dir_fd, &amp;sub_dir_path_c, mode);</span>
<span class="line" id="L2714">    }</span>
<span class="line" id="L2715">}</span>
<span class="line" id="L2716"></span>
<span class="line" id="L2717"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">mkdiratWasi</span>(dir_fd: fd_t, sub_dir_path: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>, mode: <span class="tok-type">u32</span>) MakeDirError!<span class="tok-type">void</span> {</span>
<span class="line" id="L2718">    _ = mode;</span>
<span class="line" id="L2719">    <span class="tok-kw">switch</span> (wasi.path_create_directory(dir_fd, sub_dir_path.ptr, sub_dir_path.len)) {</span>
<span class="line" id="L2720">        .SUCCESS =&gt; <span class="tok-kw">return</span>,</span>
<span class="line" id="L2721">        .ACCES =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.AccessDenied,</span>
<span class="line" id="L2722">        .BADF =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L2723">        .PERM =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.AccessDenied,</span>
<span class="line" id="L2724">        .DQUOT =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.DiskQuota,</span>
<span class="line" id="L2725">        .EXIST =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.PathAlreadyExists,</span>
<span class="line" id="L2726">        .FAULT =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L2727">        .LOOP =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.SymLinkLoop,</span>
<span class="line" id="L2728">        .MLINK =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.LinkQuotaExceeded,</span>
<span class="line" id="L2729">        .NAMETOOLONG =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.NameTooLong,</span>
<span class="line" id="L2730">        .NOENT =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.FileNotFound,</span>
<span class="line" id="L2731">        .NOMEM =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.SystemResources,</span>
<span class="line" id="L2732">        .NOSPC =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.NoSpaceLeft,</span>
<span class="line" id="L2733">        .NOTDIR =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.NotDir,</span>
<span class="line" id="L2734">        .ROFS =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.ReadOnlyFileSystem,</span>
<span class="line" id="L2735">        .NOTCAPABLE =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.AccessDenied,</span>
<span class="line" id="L2736">        <span class="tok-kw">else</span> =&gt; |err| <span class="tok-kw">return</span> unexpectedErrno(err),</span>
<span class="line" id="L2737">    }</span>
<span class="line" id="L2738">}</span>
<span class="line" id="L2739"></span>
<span class="line" id="L2740"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">mkdiratZ</span>(dir_fd: fd_t, sub_dir_path: [*:<span class="tok-number">0</span>]<span class="tok-kw">const</span> <span class="tok-type">u8</span>, mode: <span class="tok-type">u32</span>) MakeDirError!<span class="tok-type">void</span> {</span>
<span class="line" id="L2741">    <span class="tok-kw">if</span> (builtin.os.tag == .windows) {</span>
<span class="line" id="L2742">        <span class="tok-kw">const</span> sub_dir_path_w = <span class="tok-kw">try</span> windows.cStrToPrefixedFileW(sub_dir_path);</span>
<span class="line" id="L2743">        <span class="tok-kw">return</span> mkdiratW(dir_fd, sub_dir_path_w.span().ptr, mode);</span>
<span class="line" id="L2744">    } <span class="tok-kw">else</span> <span class="tok-kw">if</span> (builtin.os.tag == .wasi <span class="tok-kw">and</span> !builtin.link_libc) {</span>
<span class="line" id="L2745">        <span class="tok-kw">return</span> mkdirat(dir_fd, mem.sliceTo(sub_dir_path, <span class="tok-number">0</span>), mode);</span>
<span class="line" id="L2746">    }</span>
<span class="line" id="L2747">    <span class="tok-kw">switch</span> (errno(system.mkdirat(dir_fd, sub_dir_path, mode))) {</span>
<span class="line" id="L2748">        .SUCCESS =&gt; <span class="tok-kw">return</span>,</span>
<span class="line" id="L2749">        .ACCES =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.AccessDenied,</span>
<span class="line" id="L2750">        .BADF =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L2751">        .PERM =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.AccessDenied,</span>
<span class="line" id="L2752">        .DQUOT =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.DiskQuota,</span>
<span class="line" id="L2753">        .EXIST =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.PathAlreadyExists,</span>
<span class="line" id="L2754">        .FAULT =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L2755">        .LOOP =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.SymLinkLoop,</span>
<span class="line" id="L2756">        .MLINK =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.LinkQuotaExceeded,</span>
<span class="line" id="L2757">        .NAMETOOLONG =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.NameTooLong,</span>
<span class="line" id="L2758">        .NOENT =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.FileNotFound,</span>
<span class="line" id="L2759">        .NOMEM =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.SystemResources,</span>
<span class="line" id="L2760">        .NOSPC =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.NoSpaceLeft,</span>
<span class="line" id="L2761">        .NOTDIR =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.NotDir,</span>
<span class="line" id="L2762">        .ROFS =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.ReadOnlyFileSystem,</span>
<span class="line" id="L2763">        <span class="tok-kw">else</span> =&gt; |err| <span class="tok-kw">return</span> unexpectedErrno(err),</span>
<span class="line" id="L2764">    }</span>
<span class="line" id="L2765">}</span>
<span class="line" id="L2766"></span>
<span class="line" id="L2767"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">mkdiratW</span>(dir_fd: fd_t, sub_path_w: []<span class="tok-kw">const</span> <span class="tok-type">u16</span>, mode: <span class="tok-type">u32</span>) MakeDirError!<span class="tok-type">void</span> {</span>
<span class="line" id="L2768">    _ = mode;</span>
<span class="line" id="L2769">    <span class="tok-kw">const</span> sub_dir_handle = windows.OpenFile(sub_path_w, .{</span>
<span class="line" id="L2770">        .dir = dir_fd,</span>
<span class="line" id="L2771">        .access_mask = windows.GENERIC_READ | windows.SYNCHRONIZE,</span>
<span class="line" id="L2772">        .creation = windows.FILE_CREATE,</span>
<span class="line" id="L2773">        .io_mode = .blocking,</span>
<span class="line" id="L2774">        .filter = .dir_only,</span>
<span class="line" id="L2775">    }) <span class="tok-kw">catch</span> |err| <span class="tok-kw">switch</span> (err) {</span>
<span class="line" id="L2776">        <span class="tok-kw">error</span>.IsDir =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L2777">        <span class="tok-kw">error</span>.PipeBusy =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L2778">        <span class="tok-kw">error</span>.WouldBlock =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L2779">        <span class="tok-kw">else</span> =&gt; |e| <span class="tok-kw">return</span> e,</span>
<span class="line" id="L2780">    };</span>
<span class="line" id="L2781">    windows.CloseHandle(sub_dir_handle);</span>
<span class="line" id="L2782">}</span>
<span class="line" id="L2783"></span>
<span class="line" id="L2784"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> MakeDirError = <span class="tok-kw">error</span>{</span>
<span class="line" id="L2785">    <span class="tok-comment">/// In WASI, this error may occur when the file descriptor does</span></span>
<span class="line" id="L2786">    <span class="tok-comment">/// not hold the required rights to create a new directory relative to it.</span></span>
<span class="line" id="L2787">    AccessDenied,</span>
<span class="line" id="L2788">    DiskQuota,</span>
<span class="line" id="L2789">    PathAlreadyExists,</span>
<span class="line" id="L2790">    SymLinkLoop,</span>
<span class="line" id="L2791">    LinkQuotaExceeded,</span>
<span class="line" id="L2792">    NameTooLong,</span>
<span class="line" id="L2793">    FileNotFound,</span>
<span class="line" id="L2794">    SystemResources,</span>
<span class="line" id="L2795">    NoSpaceLeft,</span>
<span class="line" id="L2796">    NotDir,</span>
<span class="line" id="L2797">    ReadOnlyFileSystem,</span>
<span class="line" id="L2798">    InvalidUtf8,</span>
<span class="line" id="L2799">    BadPathName,</span>
<span class="line" id="L2800">    NoDevice,</span>
<span class="line" id="L2801">} || UnexpectedError;</span>
<span class="line" id="L2802"></span>
<span class="line" id="L2803"><span class="tok-comment">/// Create a directory.</span></span>
<span class="line" id="L2804"><span class="tok-comment">/// `mode` is ignored on Windows and WASI.</span></span>
<span class="line" id="L2805"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">mkdir</span>(dir_path: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>, mode: <span class="tok-type">u32</span>) MakeDirError!<span class="tok-type">void</span> {</span>
<span class="line" id="L2806">    <span class="tok-kw">if</span> (builtin.os.tag == .wasi <span class="tok-kw">and</span> !builtin.link_libc) {</span>
<span class="line" id="L2807">        <span class="tok-kw">return</span> mkdirat(wasi.AT.FDCWD, dir_path, mode);</span>
<span class="line" id="L2808">    } <span class="tok-kw">else</span> <span class="tok-kw">if</span> (builtin.os.tag == .windows) {</span>
<span class="line" id="L2809">        <span class="tok-kw">const</span> dir_path_w = <span class="tok-kw">try</span> windows.sliceToPrefixedFileW(dir_path);</span>
<span class="line" id="L2810">        <span class="tok-kw">return</span> mkdirW(dir_path_w.span(), mode);</span>
<span class="line" id="L2811">    } <span class="tok-kw">else</span> {</span>
<span class="line" id="L2812">        <span class="tok-kw">const</span> dir_path_c = <span class="tok-kw">try</span> toPosixPath(dir_path);</span>
<span class="line" id="L2813">        <span class="tok-kw">return</span> mkdirZ(&amp;dir_path_c, mode);</span>
<span class="line" id="L2814">    }</span>
<span class="line" id="L2815">}</span>
<span class="line" id="L2816"></span>
<span class="line" id="L2817"><span class="tok-comment">/// Same as `mkdir` but the parameter is a null-terminated UTF8-encoded string.</span></span>
<span class="line" id="L2818"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">mkdirZ</span>(dir_path: [*:<span class="tok-number">0</span>]<span class="tok-kw">const</span> <span class="tok-type">u8</span>, mode: <span class="tok-type">u32</span>) MakeDirError!<span class="tok-type">void</span> {</span>
<span class="line" id="L2819">    <span class="tok-kw">if</span> (builtin.os.tag == .windows) {</span>
<span class="line" id="L2820">        <span class="tok-kw">const</span> dir_path_w = <span class="tok-kw">try</span> windows.cStrToPrefixedFileW(dir_path);</span>
<span class="line" id="L2821">        <span class="tok-kw">return</span> mkdirW(dir_path_w.span(), mode);</span>
<span class="line" id="L2822">    } <span class="tok-kw">else</span> <span class="tok-kw">if</span> (builtin.os.tag == .wasi <span class="tok-kw">and</span> !builtin.link_libc) {</span>
<span class="line" id="L2823">        <span class="tok-kw">return</span> mkdir(mem.sliceTo(dir_path, <span class="tok-number">0</span>), mode);</span>
<span class="line" id="L2824">    }</span>
<span class="line" id="L2825">    <span class="tok-kw">switch</span> (errno(system.mkdir(dir_path, mode))) {</span>
<span class="line" id="L2826">        .SUCCESS =&gt; <span class="tok-kw">return</span>,</span>
<span class="line" id="L2827">        .ACCES =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.AccessDenied,</span>
<span class="line" id="L2828">        .PERM =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.AccessDenied,</span>
<span class="line" id="L2829">        .DQUOT =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.DiskQuota,</span>
<span class="line" id="L2830">        .EXIST =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.PathAlreadyExists,</span>
<span class="line" id="L2831">        .FAULT =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L2832">        .LOOP =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.SymLinkLoop,</span>
<span class="line" id="L2833">        .MLINK =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.LinkQuotaExceeded,</span>
<span class="line" id="L2834">        .NAMETOOLONG =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.NameTooLong,</span>
<span class="line" id="L2835">        .NOENT =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.FileNotFound,</span>
<span class="line" id="L2836">        .NOMEM =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.SystemResources,</span>
<span class="line" id="L2837">        .NOSPC =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.NoSpaceLeft,</span>
<span class="line" id="L2838">        .NOTDIR =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.NotDir,</span>
<span class="line" id="L2839">        .ROFS =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.ReadOnlyFileSystem,</span>
<span class="line" id="L2840">        <span class="tok-kw">else</span> =&gt; |err| <span class="tok-kw">return</span> unexpectedErrno(err),</span>
<span class="line" id="L2841">    }</span>
<span class="line" id="L2842">}</span>
<span class="line" id="L2843"></span>
<span class="line" id="L2844"><span class="tok-comment">/// Windows-only. Same as `mkdir` but the parameters is  WTF16 encoded.</span></span>
<span class="line" id="L2845"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">mkdirW</span>(dir_path_w: []<span class="tok-kw">const</span> <span class="tok-type">u16</span>, mode: <span class="tok-type">u32</span>) MakeDirError!<span class="tok-type">void</span> {</span>
<span class="line" id="L2846">    _ = mode;</span>
<span class="line" id="L2847">    <span class="tok-kw">const</span> sub_dir_handle = windows.OpenFile(dir_path_w, .{</span>
<span class="line" id="L2848">        .dir = std.fs.cwd().fd,</span>
<span class="line" id="L2849">        .access_mask = windows.GENERIC_READ | windows.SYNCHRONIZE,</span>
<span class="line" id="L2850">        .creation = windows.FILE_CREATE,</span>
<span class="line" id="L2851">        .io_mode = .blocking,</span>
<span class="line" id="L2852">        .filter = .dir_only,</span>
<span class="line" id="L2853">    }) <span class="tok-kw">catch</span> |err| <span class="tok-kw">switch</span> (err) {</span>
<span class="line" id="L2854">        <span class="tok-kw">error</span>.IsDir =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L2855">        <span class="tok-kw">error</span>.PipeBusy =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L2856">        <span class="tok-kw">error</span>.WouldBlock =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L2857">        <span class="tok-kw">else</span> =&gt; |e| <span class="tok-kw">return</span> e,</span>
<span class="line" id="L2858">    };</span>
<span class="line" id="L2859">    windows.CloseHandle(sub_dir_handle);</span>
<span class="line" id="L2860">}</span>
<span class="line" id="L2861"></span>
<span class="line" id="L2862"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> DeleteDirError = <span class="tok-kw">error</span>{</span>
<span class="line" id="L2863">    AccessDenied,</span>
<span class="line" id="L2864">    FileBusy,</span>
<span class="line" id="L2865">    SymLinkLoop,</span>
<span class="line" id="L2866">    NameTooLong,</span>
<span class="line" id="L2867">    FileNotFound,</span>
<span class="line" id="L2868">    SystemResources,</span>
<span class="line" id="L2869">    NotDir,</span>
<span class="line" id="L2870">    DirNotEmpty,</span>
<span class="line" id="L2871">    ReadOnlyFileSystem,</span>
<span class="line" id="L2872">    InvalidUtf8,</span>
<span class="line" id="L2873">    BadPathName,</span>
<span class="line" id="L2874">} || UnexpectedError;</span>
<span class="line" id="L2875"></span>
<span class="line" id="L2876"><span class="tok-comment">/// Deletes an empty directory.</span></span>
<span class="line" id="L2877"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">rmdir</span>(dir_path: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) DeleteDirError!<span class="tok-type">void</span> {</span>
<span class="line" id="L2878">    <span class="tok-kw">if</span> (builtin.os.tag == .wasi <span class="tok-kw">and</span> !builtin.link_libc) {</span>
<span class="line" id="L2879">        <span class="tok-kw">return</span> unlinkat(wasi.AT.FDCWD, dir_path, AT.REMOVEDIR) <span class="tok-kw">catch</span> |err| <span class="tok-kw">switch</span> (err) {</span>
<span class="line" id="L2880">            <span class="tok-kw">error</span>.FileSystem =&gt; <span class="tok-kw">unreachable</span>, <span class="tok-comment">// only occurs when targeting files</span>
</span>
<span class="line" id="L2881">            <span class="tok-kw">error</span>.IsDir =&gt; <span class="tok-kw">unreachable</span>, <span class="tok-comment">// only occurs when targeting files</span>
</span>
<span class="line" id="L2882">            <span class="tok-kw">else</span> =&gt; |e| <span class="tok-kw">return</span> e,</span>
<span class="line" id="L2883">        };</span>
<span class="line" id="L2884">    } <span class="tok-kw">else</span> <span class="tok-kw">if</span> (builtin.os.tag == .windows) {</span>
<span class="line" id="L2885">        <span class="tok-kw">const</span> dir_path_w = <span class="tok-kw">try</span> windows.sliceToPrefixedFileW(dir_path);</span>
<span class="line" id="L2886">        <span class="tok-kw">return</span> rmdirW(dir_path_w.span());</span>
<span class="line" id="L2887">    } <span class="tok-kw">else</span> {</span>
<span class="line" id="L2888">        <span class="tok-kw">const</span> dir_path_c = <span class="tok-kw">try</span> toPosixPath(dir_path);</span>
<span class="line" id="L2889">        <span class="tok-kw">return</span> rmdirZ(&amp;dir_path_c);</span>
<span class="line" id="L2890">    }</span>
<span class="line" id="L2891">}</span>
<span class="line" id="L2892"></span>
<span class="line" id="L2893"><span class="tok-comment">/// Same as `rmdir` except the parameter is null-terminated.</span></span>
<span class="line" id="L2894"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">rmdirZ</span>(dir_path: [*:<span class="tok-number">0</span>]<span class="tok-kw">const</span> <span class="tok-type">u8</span>) DeleteDirError!<span class="tok-type">void</span> {</span>
<span class="line" id="L2895">    <span class="tok-kw">if</span> (builtin.os.tag == .windows) {</span>
<span class="line" id="L2896">        <span class="tok-kw">const</span> dir_path_w = <span class="tok-kw">try</span> windows.cStrToPrefixedFileW(dir_path);</span>
<span class="line" id="L2897">        <span class="tok-kw">return</span> rmdirW(dir_path_w.span());</span>
<span class="line" id="L2898">    } <span class="tok-kw">else</span> <span class="tok-kw">if</span> (builtin.os.tag == .wasi <span class="tok-kw">and</span> !builtin.link_libc) {</span>
<span class="line" id="L2899">        <span class="tok-kw">return</span> rmdir(mem.sliceTo(dir_path, <span class="tok-number">0</span>));</span>
<span class="line" id="L2900">    }</span>
<span class="line" id="L2901">    <span class="tok-kw">switch</span> (errno(system.rmdir(dir_path))) {</span>
<span class="line" id="L2902">        .SUCCESS =&gt; <span class="tok-kw">return</span>,</span>
<span class="line" id="L2903">        .ACCES =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.AccessDenied,</span>
<span class="line" id="L2904">        .PERM =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.AccessDenied,</span>
<span class="line" id="L2905">        .BUSY =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.FileBusy,</span>
<span class="line" id="L2906">        .FAULT =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L2907">        .INVAL =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.BadPathName,</span>
<span class="line" id="L2908">        .LOOP =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.SymLinkLoop,</span>
<span class="line" id="L2909">        .NAMETOOLONG =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.NameTooLong,</span>
<span class="line" id="L2910">        .NOENT =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.FileNotFound,</span>
<span class="line" id="L2911">        .NOMEM =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.SystemResources,</span>
<span class="line" id="L2912">        .NOTDIR =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.NotDir,</span>
<span class="line" id="L2913">        .EXIST =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.DirNotEmpty,</span>
<span class="line" id="L2914">        .NOTEMPTY =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.DirNotEmpty,</span>
<span class="line" id="L2915">        .ROFS =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.ReadOnlyFileSystem,</span>
<span class="line" id="L2916">        <span class="tok-kw">else</span> =&gt; |err| <span class="tok-kw">return</span> unexpectedErrno(err),</span>
<span class="line" id="L2917">    }</span>
<span class="line" id="L2918">}</span>
<span class="line" id="L2919"></span>
<span class="line" id="L2920"><span class="tok-comment">/// Windows-only. Same as `rmdir` except the parameter is WTF16 encoded.</span></span>
<span class="line" id="L2921"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">rmdirW</span>(dir_path_w: []<span class="tok-kw">const</span> <span class="tok-type">u16</span>) DeleteDirError!<span class="tok-type">void</span> {</span>
<span class="line" id="L2922">    <span class="tok-kw">return</span> windows.DeleteFile(dir_path_w, .{ .dir = std.fs.cwd().fd, .remove_dir = <span class="tok-null">true</span> }) <span class="tok-kw">catch</span> |err| <span class="tok-kw">switch</span> (err) {</span>
<span class="line" id="L2923">        <span class="tok-kw">error</span>.IsDir =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L2924">        <span class="tok-kw">else</span> =&gt; |e| <span class="tok-kw">return</span> e,</span>
<span class="line" id="L2925">    };</span>
<span class="line" id="L2926">}</span>
<span class="line" id="L2927"></span>
<span class="line" id="L2928"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> ChangeCurDirError = <span class="tok-kw">error</span>{</span>
<span class="line" id="L2929">    AccessDenied,</span>
<span class="line" id="L2930">    FileSystem,</span>
<span class="line" id="L2931">    SymLinkLoop,</span>
<span class="line" id="L2932">    NameTooLong,</span>
<span class="line" id="L2933">    FileNotFound,</span>
<span class="line" id="L2934">    SystemResources,</span>
<span class="line" id="L2935">    NotDir,</span>
<span class="line" id="L2936">    BadPathName,</span>
<span class="line" id="L2937"></span>
<span class="line" id="L2938">    <span class="tok-comment">/// On Windows, file paths must be valid Unicode.</span></span>
<span class="line" id="L2939">    InvalidUtf8,</span>
<span class="line" id="L2940">} || UnexpectedError;</span>
<span class="line" id="L2941"></span>
<span class="line" id="L2942"><span class="tok-comment">/// Changes the current working directory of the calling process.</span></span>
<span class="line" id="L2943"><span class="tok-comment">/// `dir_path` is recommended to be a UTF-8 encoded string.</span></span>
<span class="line" id="L2944"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">chdir</span>(dir_path: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) ChangeCurDirError!<span class="tok-type">void</span> {</span>
<span class="line" id="L2945">    <span class="tok-kw">if</span> (builtin.os.tag == .wasi <span class="tok-kw">and</span> !builtin.link_libc) {</span>
<span class="line" id="L2946">        <span class="tok-kw">var</span> buf: [MAX_PATH_BYTES]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L2947">        <span class="tok-kw">var</span> alloc = std.heap.FixedBufferAllocator.init(&amp;buf);</span>
<span class="line" id="L2948">        <span class="tok-kw">const</span> path = <span class="tok-kw">try</span> fs.resolve(alloc.allocator(), &amp;.{ wasi_cwd.cwd, dir_path });</span>
<span class="line" id="L2949"></span>
<span class="line" id="L2950">        <span class="tok-kw">const</span> dirinfo = <span class="tok-kw">try</span> fstatat(AT.FDCWD, path, <span class="tok-number">0</span>);</span>
<span class="line" id="L2951">        <span class="tok-kw">if</span> (dirinfo.filetype != .DIRECTORY) {</span>
<span class="line" id="L2952">            <span class="tok-kw">return</span> <span class="tok-kw">error</span>.NotDir;</span>
<span class="line" id="L2953">        }</span>
<span class="line" id="L2954"></span>
<span class="line" id="L2955">        <span class="tok-kw">var</span> cwd_alloc = std.heap.FixedBufferAllocator.init(&amp;wasi_cwd.path_buffer);</span>
<span class="line" id="L2956">        wasi_cwd.cwd = <span class="tok-kw">try</span> cwd_alloc.allocator().dupe(<span class="tok-type">u8</span>, path);</span>
<span class="line" id="L2957">        <span class="tok-kw">return</span>;</span>
<span class="line" id="L2958">    } <span class="tok-kw">else</span> <span class="tok-kw">if</span> (builtin.os.tag == .windows) {</span>
<span class="line" id="L2959">        <span class="tok-kw">var</span> utf16_dir_path: [windows.PATH_MAX_WIDE]<span class="tok-type">u16</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L2960">        <span class="tok-kw">const</span> len = <span class="tok-kw">try</span> std.unicode.utf8ToUtf16Le(utf16_dir_path[<span class="tok-number">0</span>..], dir_path);</span>
<span class="line" id="L2961">        <span class="tok-kw">if</span> (len &gt; utf16_dir_path.len) <span class="tok-kw">return</span> <span class="tok-kw">error</span>.NameTooLong;</span>
<span class="line" id="L2962">        <span class="tok-kw">return</span> chdirW(utf16_dir_path[<span class="tok-number">0</span>..len]);</span>
<span class="line" id="L2963">    } <span class="tok-kw">else</span> {</span>
<span class="line" id="L2964">        <span class="tok-kw">const</span> dir_path_c = <span class="tok-kw">try</span> toPosixPath(dir_path);</span>
<span class="line" id="L2965">        <span class="tok-kw">return</span> chdirZ(&amp;dir_path_c);</span>
<span class="line" id="L2966">    }</span>
<span class="line" id="L2967">}</span>
<span class="line" id="L2968"></span>
<span class="line" id="L2969"><span class="tok-comment">/// Same as `chdir` except the parameter is null-terminated.</span></span>
<span class="line" id="L2970"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">chdirZ</span>(dir_path: [*:<span class="tok-number">0</span>]<span class="tok-kw">const</span> <span class="tok-type">u8</span>) ChangeCurDirError!<span class="tok-type">void</span> {</span>
<span class="line" id="L2971">    <span class="tok-kw">if</span> (builtin.os.tag == .windows) {</span>
<span class="line" id="L2972">        <span class="tok-kw">var</span> utf16_dir_path: [windows.PATH_MAX_WIDE]<span class="tok-type">u16</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L2973">        <span class="tok-kw">const</span> len = <span class="tok-kw">try</span> std.unicode.utf8ToUtf16Le(utf16_dir_path[<span class="tok-number">0</span>..], dir_path);</span>
<span class="line" id="L2974">        <span class="tok-kw">if</span> (len &gt; utf16_dir_path.len) <span class="tok-kw">return</span> <span class="tok-kw">error</span>.NameTooLong;</span>
<span class="line" id="L2975">        <span class="tok-kw">return</span> chdirW(utf16_dir_path[<span class="tok-number">0</span>..len]);</span>
<span class="line" id="L2976">    } <span class="tok-kw">else</span> <span class="tok-kw">if</span> (builtin.os.tag == .wasi <span class="tok-kw">and</span> !builtin.link_libc) {</span>
<span class="line" id="L2977">        <span class="tok-kw">return</span> chdir(mem.sliceTo(dir_path, <span class="tok-number">0</span>));</span>
<span class="line" id="L2978">    }</span>
<span class="line" id="L2979">    <span class="tok-kw">switch</span> (errno(system.chdir(dir_path))) {</span>
<span class="line" id="L2980">        .SUCCESS =&gt; <span class="tok-kw">return</span>,</span>
<span class="line" id="L2981">        .ACCES =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.AccessDenied,</span>
<span class="line" id="L2982">        .FAULT =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L2983">        .IO =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.FileSystem,</span>
<span class="line" id="L2984">        .LOOP =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.SymLinkLoop,</span>
<span class="line" id="L2985">        .NAMETOOLONG =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.NameTooLong,</span>
<span class="line" id="L2986">        .NOENT =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.FileNotFound,</span>
<span class="line" id="L2987">        .NOMEM =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.SystemResources,</span>
<span class="line" id="L2988">        .NOTDIR =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.NotDir,</span>
<span class="line" id="L2989">        <span class="tok-kw">else</span> =&gt; |err| <span class="tok-kw">return</span> unexpectedErrno(err),</span>
<span class="line" id="L2990">    }</span>
<span class="line" id="L2991">}</span>
<span class="line" id="L2992"></span>
<span class="line" id="L2993"><span class="tok-comment">/// Windows-only. Same as `chdir` except the paramter is WTF16 encoded.</span></span>
<span class="line" id="L2994"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">chdirW</span>(dir_path: []<span class="tok-kw">const</span> <span class="tok-type">u16</span>) ChangeCurDirError!<span class="tok-type">void</span> {</span>
<span class="line" id="L2995">    windows.SetCurrentDirectory(dir_path) <span class="tok-kw">catch</span> |err| <span class="tok-kw">switch</span> (err) {</span>
<span class="line" id="L2996">        <span class="tok-kw">error</span>.NoDevice =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.FileSystem,</span>
<span class="line" id="L2997">        <span class="tok-kw">else</span> =&gt; |e| <span class="tok-kw">return</span> e,</span>
<span class="line" id="L2998">    };</span>
<span class="line" id="L2999">}</span>
<span class="line" id="L3000"></span>
<span class="line" id="L3001"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> FchdirError = <span class="tok-kw">error</span>{</span>
<span class="line" id="L3002">    AccessDenied,</span>
<span class="line" id="L3003">    NotDir,</span>
<span class="line" id="L3004">    FileSystem,</span>
<span class="line" id="L3005">} || UnexpectedError;</span>
<span class="line" id="L3006"></span>
<span class="line" id="L3007"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">fchdir</span>(dirfd: fd_t) FchdirError!<span class="tok-type">void</span> {</span>
<span class="line" id="L3008">    <span class="tok-kw">while</span> (<span class="tok-null">true</span>) {</span>
<span class="line" id="L3009">        <span class="tok-kw">switch</span> (errno(system.fchdir(dirfd))) {</span>
<span class="line" id="L3010">            .SUCCESS =&gt; <span class="tok-kw">return</span>,</span>
<span class="line" id="L3011">            .ACCES =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.AccessDenied,</span>
<span class="line" id="L3012">            .BADF =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L3013">            .NOTDIR =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.NotDir,</span>
<span class="line" id="L3014">            .INTR =&gt; <span class="tok-kw">continue</span>,</span>
<span class="line" id="L3015">            .IO =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.FileSystem,</span>
<span class="line" id="L3016">            <span class="tok-kw">else</span> =&gt; |err| <span class="tok-kw">return</span> unexpectedErrno(err),</span>
<span class="line" id="L3017">        }</span>
<span class="line" id="L3018">    }</span>
<span class="line" id="L3019">}</span>
<span class="line" id="L3020"></span>
<span class="line" id="L3021"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> ReadLinkError = <span class="tok-kw">error</span>{</span>
<span class="line" id="L3022">    <span class="tok-comment">/// In WASI, this error may occur when the file descriptor does</span></span>
<span class="line" id="L3023">    <span class="tok-comment">/// not hold the required rights to read value of a symbolic link relative to it.</span></span>
<span class="line" id="L3024">    AccessDenied,</span>
<span class="line" id="L3025">    FileSystem,</span>
<span class="line" id="L3026">    SymLinkLoop,</span>
<span class="line" id="L3027">    NameTooLong,</span>
<span class="line" id="L3028">    FileNotFound,</span>
<span class="line" id="L3029">    SystemResources,</span>
<span class="line" id="L3030">    NotLink,</span>
<span class="line" id="L3031">    NotDir,</span>
<span class="line" id="L3032">    InvalidUtf8,</span>
<span class="line" id="L3033">    BadPathName,</span>
<span class="line" id="L3034">    <span class="tok-comment">/// Windows-only. This error may occur if the opened reparse point is</span></span>
<span class="line" id="L3035">    <span class="tok-comment">/// of unsupported type.</span></span>
<span class="line" id="L3036">    UnsupportedReparsePointType,</span>
<span class="line" id="L3037">} || UnexpectedError;</span>
<span class="line" id="L3038"></span>
<span class="line" id="L3039"><span class="tok-comment">/// Read value of a symbolic link.</span></span>
<span class="line" id="L3040"><span class="tok-comment">/// The return value is a slice of `out_buffer` from index 0.</span></span>
<span class="line" id="L3041"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">readlink</span>(file_path: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>, out_buffer: []<span class="tok-type">u8</span>) ReadLinkError![]<span class="tok-type">u8</span> {</span>
<span class="line" id="L3042">    <span class="tok-kw">if</span> (builtin.os.tag == .wasi <span class="tok-kw">and</span> !builtin.link_libc) {</span>
<span class="line" id="L3043">        <span class="tok-kw">return</span> readlinkat(wasi.AT.FDCWD, file_path, out_buffer);</span>
<span class="line" id="L3044">    } <span class="tok-kw">else</span> <span class="tok-kw">if</span> (builtin.os.tag == .windows) {</span>
<span class="line" id="L3045">        <span class="tok-kw">const</span> file_path_w = <span class="tok-kw">try</span> windows.sliceToPrefixedFileW(file_path);</span>
<span class="line" id="L3046">        <span class="tok-kw">return</span> readlinkW(file_path_w.span(), out_buffer);</span>
<span class="line" id="L3047">    } <span class="tok-kw">else</span> {</span>
<span class="line" id="L3048">        <span class="tok-kw">const</span> file_path_c = <span class="tok-kw">try</span> toPosixPath(file_path);</span>
<span class="line" id="L3049">        <span class="tok-kw">return</span> readlinkZ(&amp;file_path_c, out_buffer);</span>
<span class="line" id="L3050">    }</span>
<span class="line" id="L3051">}</span>
<span class="line" id="L3052"></span>
<span class="line" id="L3053"><span class="tok-comment">/// Windows-only. Same as `readlink` except `file_path` is WTF16 encoded.</span></span>
<span class="line" id="L3054"><span class="tok-comment">/// See also `readlinkZ`.</span></span>
<span class="line" id="L3055"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">readlinkW</span>(file_path: []<span class="tok-kw">const</span> <span class="tok-type">u16</span>, out_buffer: []<span class="tok-type">u8</span>) ReadLinkError![]<span class="tok-type">u8</span> {</span>
<span class="line" id="L3056">    <span class="tok-kw">return</span> windows.ReadLink(std.fs.cwd().fd, file_path, out_buffer);</span>
<span class="line" id="L3057">}</span>
<span class="line" id="L3058"></span>
<span class="line" id="L3059"><span class="tok-comment">/// Same as `readlink` except `file_path` is null-terminated.</span></span>
<span class="line" id="L3060"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">readlinkZ</span>(file_path: [*:<span class="tok-number">0</span>]<span class="tok-kw">const</span> <span class="tok-type">u8</span>, out_buffer: []<span class="tok-type">u8</span>) ReadLinkError![]<span class="tok-type">u8</span> {</span>
<span class="line" id="L3061">    <span class="tok-kw">if</span> (builtin.os.tag == .windows) {</span>
<span class="line" id="L3062">        <span class="tok-kw">const</span> file_path_w = <span class="tok-kw">try</span> windows.cStrToWin32PrefixedFileW(file_path);</span>
<span class="line" id="L3063">        <span class="tok-kw">return</span> readlinkW(file_path_w.span(), out_buffer);</span>
<span class="line" id="L3064">    } <span class="tok-kw">else</span> <span class="tok-kw">if</span> (builtin.os.tag == .wasi <span class="tok-kw">and</span> !builtin.link_libc) {</span>
<span class="line" id="L3065">        <span class="tok-kw">return</span> readlink(mem.sliceTo(file_path, <span class="tok-number">0</span>), out_buffer);</span>
<span class="line" id="L3066">    }</span>
<span class="line" id="L3067">    <span class="tok-kw">const</span> rc = system.readlink(file_path, out_buffer.ptr, out_buffer.len);</span>
<span class="line" id="L3068">    <span class="tok-kw">switch</span> (errno(rc)) {</span>
<span class="line" id="L3069">        .SUCCESS =&gt; <span class="tok-kw">return</span> out_buffer[<span class="tok-number">0</span>..<span class="tok-builtin">@bitCast</span>(<span class="tok-type">usize</span>, rc)],</span>
<span class="line" id="L3070">        .ACCES =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.AccessDenied,</span>
<span class="line" id="L3071">        .FAULT =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L3072">        .INVAL =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.NotLink,</span>
<span class="line" id="L3073">        .IO =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.FileSystem,</span>
<span class="line" id="L3074">        .LOOP =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.SymLinkLoop,</span>
<span class="line" id="L3075">        .NAMETOOLONG =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.NameTooLong,</span>
<span class="line" id="L3076">        .NOENT =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.FileNotFound,</span>
<span class="line" id="L3077">        .NOMEM =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.SystemResources,</span>
<span class="line" id="L3078">        .NOTDIR =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.NotDir,</span>
<span class="line" id="L3079">        <span class="tok-kw">else</span> =&gt; |err| <span class="tok-kw">return</span> unexpectedErrno(err),</span>
<span class="line" id="L3080">    }</span>
<span class="line" id="L3081">}</span>
<span class="line" id="L3082"></span>
<span class="line" id="L3083"><span class="tok-comment">/// Similar to `readlink` except reads value of a symbolink link **relative** to `dirfd` directory handle.</span></span>
<span class="line" id="L3084"><span class="tok-comment">/// The return value is a slice of `out_buffer` from index 0.</span></span>
<span class="line" id="L3085"><span class="tok-comment">/// See also `readlinkatWasi`, `realinkatZ` and `realinkatW`.</span></span>
<span class="line" id="L3086"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">readlinkat</span>(dirfd: fd_t, file_path: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>, out_buffer: []<span class="tok-type">u8</span>) ReadLinkError![]<span class="tok-type">u8</span> {</span>
<span class="line" id="L3087">    <span class="tok-kw">if</span> (builtin.os.tag == .wasi <span class="tok-kw">and</span> !builtin.link_libc) {</span>
<span class="line" id="L3088">        <span class="tok-kw">if</span> (dirfd == wasi.AT.FDCWD <span class="tok-kw">or</span> fs.path.isAbsolute(file_path)) {</span>
<span class="line" id="L3089">            <span class="tok-comment">// Resolve absolute or CWD-relative paths to a path within a Preopen</span>
</span>
<span class="line" id="L3090">            <span class="tok-kw">var</span> path_buf: [MAX_PATH_BYTES]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L3091">            <span class="tok-kw">var</span> path = <span class="tok-kw">try</span> resolvePathWasi(file_path, &amp;path_buf);</span>
<span class="line" id="L3092">            <span class="tok-kw">return</span> readlinkatWasi(path.dir_fd, path.relative_path, out_buffer);</span>
<span class="line" id="L3093">        }</span>
<span class="line" id="L3094">        <span class="tok-kw">return</span> readlinkatWasi(dirfd, file_path, out_buffer);</span>
<span class="line" id="L3095">    }</span>
<span class="line" id="L3096">    <span class="tok-kw">if</span> (builtin.os.tag == .windows) {</span>
<span class="line" id="L3097">        <span class="tok-kw">const</span> file_path_w = <span class="tok-kw">try</span> windows.sliceToPrefixedFileW(file_path);</span>
<span class="line" id="L3098">        <span class="tok-kw">return</span> readlinkatW(dirfd, file_path_w.span(), out_buffer);</span>
<span class="line" id="L3099">    }</span>
<span class="line" id="L3100">    <span class="tok-kw">const</span> file_path_c = <span class="tok-kw">try</span> toPosixPath(file_path);</span>
<span class="line" id="L3101">    <span class="tok-kw">return</span> readlinkatZ(dirfd, &amp;file_path_c, out_buffer);</span>
<span class="line" id="L3102">}</span>
<span class="line" id="L3103"></span>
<span class="line" id="L3104"><span class="tok-comment">/// WASI-only. Same as `readlinkat` but targets WASI.</span></span>
<span class="line" id="L3105"><span class="tok-comment">/// See also `readlinkat`.</span></span>
<span class="line" id="L3106"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">readlinkatWasi</span>(dirfd: fd_t, file_path: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>, out_buffer: []<span class="tok-type">u8</span>) ReadLinkError![]<span class="tok-type">u8</span> {</span>
<span class="line" id="L3107">    <span class="tok-kw">var</span> bufused: <span class="tok-type">usize</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L3108">    <span class="tok-kw">switch</span> (wasi.path_readlink(dirfd, file_path.ptr, file_path.len, out_buffer.ptr, out_buffer.len, &amp;bufused)) {</span>
<span class="line" id="L3109">        .SUCCESS =&gt; <span class="tok-kw">return</span> out_buffer[<span class="tok-number">0</span>..bufused],</span>
<span class="line" id="L3110">        .ACCES =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.AccessDenied,</span>
<span class="line" id="L3111">        .FAULT =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L3112">        .INVAL =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.NotLink,</span>
<span class="line" id="L3113">        .IO =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.FileSystem,</span>
<span class="line" id="L3114">        .LOOP =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.SymLinkLoop,</span>
<span class="line" id="L3115">        .NAMETOOLONG =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.NameTooLong,</span>
<span class="line" id="L3116">        .NOENT =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.FileNotFound,</span>
<span class="line" id="L3117">        .NOMEM =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.SystemResources,</span>
<span class="line" id="L3118">        .NOTDIR =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.NotDir,</span>
<span class="line" id="L3119">        .NOTCAPABLE =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.AccessDenied,</span>
<span class="line" id="L3120">        <span class="tok-kw">else</span> =&gt; |err| <span class="tok-kw">return</span> unexpectedErrno(err),</span>
<span class="line" id="L3121">    }</span>
<span class="line" id="L3122">}</span>
<span class="line" id="L3123"></span>
<span class="line" id="L3124"><span class="tok-comment">/// Windows-only. Same as `readlinkat` except `file_path` is null-terminated, WTF16 encoded.</span></span>
<span class="line" id="L3125"><span class="tok-comment">/// See also `readlinkat`.</span></span>
<span class="line" id="L3126"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">readlinkatW</span>(dirfd: fd_t, file_path: []<span class="tok-kw">const</span> <span class="tok-type">u16</span>, out_buffer: []<span class="tok-type">u8</span>) ReadLinkError![]<span class="tok-type">u8</span> {</span>
<span class="line" id="L3127">    <span class="tok-kw">return</span> windows.ReadLink(dirfd, file_path, out_buffer);</span>
<span class="line" id="L3128">}</span>
<span class="line" id="L3129"></span>
<span class="line" id="L3130"><span class="tok-comment">/// Same as `readlinkat` except `file_path` is null-terminated.</span></span>
<span class="line" id="L3131"><span class="tok-comment">/// See also `readlinkat`.</span></span>
<span class="line" id="L3132"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">readlinkatZ</span>(dirfd: fd_t, file_path: [*:<span class="tok-number">0</span>]<span class="tok-kw">const</span> <span class="tok-type">u8</span>, out_buffer: []<span class="tok-type">u8</span>) ReadLinkError![]<span class="tok-type">u8</span> {</span>
<span class="line" id="L3133">    <span class="tok-kw">if</span> (builtin.os.tag == .windows) {</span>
<span class="line" id="L3134">        <span class="tok-kw">const</span> file_path_w = <span class="tok-kw">try</span> windows.cStrToPrefixedFileW(file_path);</span>
<span class="line" id="L3135">        <span class="tok-kw">return</span> readlinkatW(dirfd, file_path_w.span(), out_buffer);</span>
<span class="line" id="L3136">    } <span class="tok-kw">else</span> <span class="tok-kw">if</span> (builtin.os.tag == .wasi <span class="tok-kw">and</span> !builtin.link_libc) {</span>
<span class="line" id="L3137">        <span class="tok-kw">return</span> readlinkat(dirfd, mem.sliceTo(file_path, <span class="tok-number">0</span>), out_buffer);</span>
<span class="line" id="L3138">    }</span>
<span class="line" id="L3139">    <span class="tok-kw">const</span> rc = system.readlinkat(dirfd, file_path, out_buffer.ptr, out_buffer.len);</span>
<span class="line" id="L3140">    <span class="tok-kw">switch</span> (errno(rc)) {</span>
<span class="line" id="L3141">        .SUCCESS =&gt; <span class="tok-kw">return</span> out_buffer[<span class="tok-number">0</span>..<span class="tok-builtin">@bitCast</span>(<span class="tok-type">usize</span>, rc)],</span>
<span class="line" id="L3142">        .ACCES =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.AccessDenied,</span>
<span class="line" id="L3143">        .FAULT =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L3144">        .INVAL =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.NotLink,</span>
<span class="line" id="L3145">        .IO =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.FileSystem,</span>
<span class="line" id="L3146">        .LOOP =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.SymLinkLoop,</span>
<span class="line" id="L3147">        .NAMETOOLONG =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.NameTooLong,</span>
<span class="line" id="L3148">        .NOENT =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.FileNotFound,</span>
<span class="line" id="L3149">        .NOMEM =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.SystemResources,</span>
<span class="line" id="L3150">        .NOTDIR =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.NotDir,</span>
<span class="line" id="L3151">        <span class="tok-kw">else</span> =&gt; |err| <span class="tok-kw">return</span> unexpectedErrno(err),</span>
<span class="line" id="L3152">    }</span>
<span class="line" id="L3153">}</span>
<span class="line" id="L3154"></span>
<span class="line" id="L3155"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> SetEidError = <span class="tok-kw">error</span>{</span>
<span class="line" id="L3156">    InvalidUserId,</span>
<span class="line" id="L3157">    PermissionDenied,</span>
<span class="line" id="L3158">} || UnexpectedError;</span>
<span class="line" id="L3159"></span>
<span class="line" id="L3160"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> SetIdError = <span class="tok-kw">error</span>{ResourceLimitReached} || SetEidError;</span>
<span class="line" id="L3161"></span>
<span class="line" id="L3162"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">setuid</span>(uid: uid_t) SetIdError!<span class="tok-type">void</span> {</span>
<span class="line" id="L3163">    <span class="tok-kw">switch</span> (errno(system.setuid(uid))) {</span>
<span class="line" id="L3164">        .SUCCESS =&gt; <span class="tok-kw">return</span>,</span>
<span class="line" id="L3165">        .AGAIN =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.ResourceLimitReached,</span>
<span class="line" id="L3166">        .INVAL =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.InvalidUserId,</span>
<span class="line" id="L3167">        .PERM =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.PermissionDenied,</span>
<span class="line" id="L3168">        <span class="tok-kw">else</span> =&gt; |err| <span class="tok-kw">return</span> unexpectedErrno(err),</span>
<span class="line" id="L3169">    }</span>
<span class="line" id="L3170">}</span>
<span class="line" id="L3171"></span>
<span class="line" id="L3172"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">seteuid</span>(uid: uid_t) SetEidError!<span class="tok-type">void</span> {</span>
<span class="line" id="L3173">    <span class="tok-kw">switch</span> (errno(system.seteuid(uid))) {</span>
<span class="line" id="L3174">        .SUCCESS =&gt; <span class="tok-kw">return</span>,</span>
<span class="line" id="L3175">        .INVAL =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.InvalidUserId,</span>
<span class="line" id="L3176">        .PERM =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.PermissionDenied,</span>
<span class="line" id="L3177">        <span class="tok-kw">else</span> =&gt; |err| <span class="tok-kw">return</span> unexpectedErrno(err),</span>
<span class="line" id="L3178">    }</span>
<span class="line" id="L3179">}</span>
<span class="line" id="L3180"></span>
<span class="line" id="L3181"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">setreuid</span>(ruid: uid_t, euid: uid_t) SetIdError!<span class="tok-type">void</span> {</span>
<span class="line" id="L3182">    <span class="tok-kw">switch</span> (errno(system.setreuid(ruid, euid))) {</span>
<span class="line" id="L3183">        .SUCCESS =&gt; <span class="tok-kw">return</span>,</span>
<span class="line" id="L3184">        .AGAIN =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.ResourceLimitReached,</span>
<span class="line" id="L3185">        .INVAL =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.InvalidUserId,</span>
<span class="line" id="L3186">        .PERM =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.PermissionDenied,</span>
<span class="line" id="L3187">        <span class="tok-kw">else</span> =&gt; |err| <span class="tok-kw">return</span> unexpectedErrno(err),</span>
<span class="line" id="L3188">    }</span>
<span class="line" id="L3189">}</span>
<span class="line" id="L3190"></span>
<span class="line" id="L3191"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">setgid</span>(gid: gid_t) SetIdError!<span class="tok-type">void</span> {</span>
<span class="line" id="L3192">    <span class="tok-kw">switch</span> (errno(system.setgid(gid))) {</span>
<span class="line" id="L3193">        .SUCCESS =&gt; <span class="tok-kw">return</span>,</span>
<span class="line" id="L3194">        .AGAIN =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.ResourceLimitReached,</span>
<span class="line" id="L3195">        .INVAL =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.InvalidUserId,</span>
<span class="line" id="L3196">        .PERM =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.PermissionDenied,</span>
<span class="line" id="L3197">        <span class="tok-kw">else</span> =&gt; |err| <span class="tok-kw">return</span> unexpectedErrno(err),</span>
<span class="line" id="L3198">    }</span>
<span class="line" id="L3199">}</span>
<span class="line" id="L3200"></span>
<span class="line" id="L3201"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">setegid</span>(uid: uid_t) SetEidError!<span class="tok-type">void</span> {</span>
<span class="line" id="L3202">    <span class="tok-kw">switch</span> (errno(system.setegid(uid))) {</span>
<span class="line" id="L3203">        .SUCCESS =&gt; <span class="tok-kw">return</span>,</span>
<span class="line" id="L3204">        .INVAL =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.InvalidUserId,</span>
<span class="line" id="L3205">        .PERM =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.PermissionDenied,</span>
<span class="line" id="L3206">        <span class="tok-kw">else</span> =&gt; |err| <span class="tok-kw">return</span> unexpectedErrno(err),</span>
<span class="line" id="L3207">    }</span>
<span class="line" id="L3208">}</span>
<span class="line" id="L3209"></span>
<span class="line" id="L3210"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">setregid</span>(rgid: gid_t, egid: gid_t) SetIdError!<span class="tok-type">void</span> {</span>
<span class="line" id="L3211">    <span class="tok-kw">switch</span> (errno(system.setregid(rgid, egid))) {</span>
<span class="line" id="L3212">        .SUCCESS =&gt; <span class="tok-kw">return</span>,</span>
<span class="line" id="L3213">        .AGAIN =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.ResourceLimitReached,</span>
<span class="line" id="L3214">        .INVAL =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.InvalidUserId,</span>
<span class="line" id="L3215">        .PERM =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.PermissionDenied,</span>
<span class="line" id="L3216">        <span class="tok-kw">else</span> =&gt; |err| <span class="tok-kw">return</span> unexpectedErrno(err),</span>
<span class="line" id="L3217">    }</span>
<span class="line" id="L3218">}</span>
<span class="line" id="L3219"></span>
<span class="line" id="L3220"><span class="tok-comment">/// Test whether a file descriptor refers to a terminal.</span></span>
<span class="line" id="L3221"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">isatty</span>(handle: fd_t) <span class="tok-type">bool</span> {</span>
<span class="line" id="L3222">    <span class="tok-kw">if</span> (builtin.os.tag == .windows) {</span>
<span class="line" id="L3223">        <span class="tok-kw">if</span> (isCygwinPty(handle))</span>
<span class="line" id="L3224">            <span class="tok-kw">return</span> <span class="tok-null">true</span>;</span>
<span class="line" id="L3225"></span>
<span class="line" id="L3226">        <span class="tok-kw">var</span> out: windows.DWORD = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L3227">        <span class="tok-kw">return</span> windows.kernel32.GetConsoleMode(handle, &amp;out) != <span class="tok-number">0</span>;</span>
<span class="line" id="L3228">    }</span>
<span class="line" id="L3229">    <span class="tok-kw">if</span> (builtin.link_libc) {</span>
<span class="line" id="L3230">        <span class="tok-kw">return</span> system.isatty(handle) != <span class="tok-number">0</span>;</span>
<span class="line" id="L3231">    }</span>
<span class="line" id="L3232">    <span class="tok-kw">if</span> (builtin.os.tag == .wasi) {</span>
<span class="line" id="L3233">        <span class="tok-kw">var</span> statbuf: fdstat_t = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L3234">        <span class="tok-kw">const</span> err = system.fd_fdstat_get(handle, &amp;statbuf);</span>
<span class="line" id="L3235">        <span class="tok-kw">if</span> (err != <span class="tok-number">0</span>) {</span>
<span class="line" id="L3236">            <span class="tok-comment">// errno = err;</span>
</span>
<span class="line" id="L3237">            <span class="tok-kw">return</span> <span class="tok-null">false</span>;</span>
<span class="line" id="L3238">        }</span>
<span class="line" id="L3239"></span>
<span class="line" id="L3240">        <span class="tok-comment">// A tty is a character device that we can't seek or tell on.</span>
</span>
<span class="line" id="L3241">        <span class="tok-kw">if</span> (statbuf.fs_filetype != .CHARACTER_DEVICE <span class="tok-kw">or</span></span>
<span class="line" id="L3242">            (statbuf.fs_rights_base &amp; (RIGHT.FD_SEEK | RIGHT.FD_TELL)) != <span class="tok-number">0</span>)</span>
<span class="line" id="L3243">        {</span>
<span class="line" id="L3244">            <span class="tok-comment">// errno = ENOTTY;</span>
</span>
<span class="line" id="L3245">            <span class="tok-kw">return</span> <span class="tok-null">false</span>;</span>
<span class="line" id="L3246">        }</span>
<span class="line" id="L3247"></span>
<span class="line" id="L3248">        <span class="tok-kw">return</span> <span class="tok-null">true</span>;</span>
<span class="line" id="L3249">    }</span>
<span class="line" id="L3250">    <span class="tok-kw">if</span> (builtin.os.tag == .linux) {</span>
<span class="line" id="L3251">        <span class="tok-kw">while</span> (<span class="tok-null">true</span>) {</span>
<span class="line" id="L3252">            <span class="tok-kw">var</span> wsz: linux.winsize = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L3253">            <span class="tok-kw">const</span> fd = <span class="tok-builtin">@bitCast</span>(<span class="tok-type">usize</span>, <span class="tok-builtin">@as</span>(<span class="tok-type">isize</span>, handle));</span>
<span class="line" id="L3254">            <span class="tok-kw">const</span> rc = linux.syscall3(.ioctl, fd, linux.T.IOCGWINSZ, <span class="tok-builtin">@ptrToInt</span>(&amp;wsz));</span>
<span class="line" id="L3255">            <span class="tok-kw">switch</span> (linux.getErrno(rc)) {</span>
<span class="line" id="L3256">                .SUCCESS =&gt; <span class="tok-kw">return</span> <span class="tok-null">true</span>,</span>
<span class="line" id="L3257">                .INTR =&gt; <span class="tok-kw">continue</span>,</span>
<span class="line" id="L3258">                <span class="tok-kw">else</span> =&gt; <span class="tok-kw">return</span> <span class="tok-null">false</span>,</span>
<span class="line" id="L3259">            }</span>
<span class="line" id="L3260">        }</span>
<span class="line" id="L3261">    }</span>
<span class="line" id="L3262">    <span class="tok-kw">return</span> system.isatty(handle) != <span class="tok-number">0</span>;</span>
<span class="line" id="L3263">}</span>
<span class="line" id="L3264"></span>
<span class="line" id="L3265"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">isCygwinPty</span>(handle: fd_t) <span class="tok-type">bool</span> {</span>
<span class="line" id="L3266">    <span class="tok-kw">if</span> (builtin.os.tag != .windows) <span class="tok-kw">return</span> <span class="tok-null">false</span>;</span>
<span class="line" id="L3267"></span>
<span class="line" id="L3268">    <span class="tok-kw">const</span> size = <span class="tok-builtin">@sizeOf</span>(windows.FILE_NAME_INFO);</span>
<span class="line" id="L3269">    <span class="tok-kw">var</span> name_info_bytes <span class="tok-kw">align</span>(<span class="tok-builtin">@alignOf</span>(windows.FILE_NAME_INFO)) = [_]<span class="tok-type">u8</span>{<span class="tok-number">0</span>} ** (size + windows.MAX_PATH);</span>
<span class="line" id="L3270"></span>
<span class="line" id="L3271">    <span class="tok-kw">if</span> (windows.kernel32.GetFileInformationByHandleEx(</span>
<span class="line" id="L3272">        handle,</span>
<span class="line" id="L3273">        windows.FileNameInfo,</span>
<span class="line" id="L3274">        <span class="tok-builtin">@ptrCast</span>(*<span class="tok-type">anyopaque</span>, &amp;name_info_bytes),</span>
<span class="line" id="L3275">        name_info_bytes.len,</span>
<span class="line" id="L3276">    ) == <span class="tok-number">0</span>) {</span>
<span class="line" id="L3277">        <span class="tok-kw">return</span> <span class="tok-null">false</span>;</span>
<span class="line" id="L3278">    }</span>
<span class="line" id="L3279"></span>
<span class="line" id="L3280">    <span class="tok-kw">const</span> name_info = <span class="tok-builtin">@ptrCast</span>(*<span class="tok-kw">const</span> windows.FILE_NAME_INFO, &amp;name_info_bytes[<span class="tok-number">0</span>]);</span>
<span class="line" id="L3281">    <span class="tok-kw">const</span> name_bytes = name_info_bytes[size .. size + <span class="tok-builtin">@as</span>(<span class="tok-type">usize</span>, name_info.FileNameLength)];</span>
<span class="line" id="L3282">    <span class="tok-kw">const</span> name_wide = mem.bytesAsSlice(<span class="tok-type">u16</span>, name_bytes);</span>
<span class="line" id="L3283">    <span class="tok-kw">return</span> mem.indexOf(<span class="tok-type">u16</span>, name_wide, &amp;[_]<span class="tok-type">u16</span>{ <span class="tok-str">'m'</span>, <span class="tok-str">'s'</span>, <span class="tok-str">'y'</span>, <span class="tok-str">'s'</span>, <span class="tok-str">'-'</span> }) != <span class="tok-null">null</span> <span class="tok-kw">or</span></span>
<span class="line" id="L3284">        mem.indexOf(<span class="tok-type">u16</span>, name_wide, &amp;[_]<span class="tok-type">u16</span>{ <span class="tok-str">'-'</span>, <span class="tok-str">'p'</span>, <span class="tok-str">'t'</span>, <span class="tok-str">'y'</span> }) != <span class="tok-null">null</span>;</span>
<span class="line" id="L3285">}</span>
<span class="line" id="L3286"></span>
<span class="line" id="L3287"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> SocketError = <span class="tok-kw">error</span>{</span>
<span class="line" id="L3288">    <span class="tok-comment">/// Permission to create a socket of the specified type and/or</span></span>
<span class="line" id="L3289">    <span class="tok-comment">/// pro‐tocol is denied.</span></span>
<span class="line" id="L3290">    PermissionDenied,</span>
<span class="line" id="L3291"></span>
<span class="line" id="L3292">    <span class="tok-comment">/// The implementation does not support the specified address family.</span></span>
<span class="line" id="L3293">    AddressFamilyNotSupported,</span>
<span class="line" id="L3294"></span>
<span class="line" id="L3295">    <span class="tok-comment">/// Unknown protocol, or protocol family not available.</span></span>
<span class="line" id="L3296">    ProtocolFamilyNotAvailable,</span>
<span class="line" id="L3297"></span>
<span class="line" id="L3298">    <span class="tok-comment">/// The per-process limit on the number of open file descriptors has been reached.</span></span>
<span class="line" id="L3299">    ProcessFdQuotaExceeded,</span>
<span class="line" id="L3300"></span>
<span class="line" id="L3301">    <span class="tok-comment">/// The system-wide limit on the total number of open files has been reached.</span></span>
<span class="line" id="L3302">    SystemFdQuotaExceeded,</span>
<span class="line" id="L3303"></span>
<span class="line" id="L3304">    <span class="tok-comment">/// Insufficient memory is available. The socket cannot be created until sufficient</span></span>
<span class="line" id="L3305">    <span class="tok-comment">/// resources are freed.</span></span>
<span class="line" id="L3306">    SystemResources,</span>
<span class="line" id="L3307"></span>
<span class="line" id="L3308">    <span class="tok-comment">/// The protocol type or the specified protocol is not supported within this domain.</span></span>
<span class="line" id="L3309">    ProtocolNotSupported,</span>
<span class="line" id="L3310"></span>
<span class="line" id="L3311">    <span class="tok-comment">/// The socket type is not supported by the protocol.</span></span>
<span class="line" id="L3312">    SocketTypeNotSupported,</span>
<span class="line" id="L3313">} || UnexpectedError;</span>
<span class="line" id="L3314"></span>
<span class="line" id="L3315"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">socket</span>(domain: <span class="tok-type">u32</span>, socket_type: <span class="tok-type">u32</span>, protocol: <span class="tok-type">u32</span>) SocketError!socket_t {</span>
<span class="line" id="L3316">    <span class="tok-kw">if</span> (builtin.os.tag == .windows) {</span>
<span class="line" id="L3317">        <span class="tok-comment">// NOTE: windows translates the SOCK.NONBLOCK/SOCK.CLOEXEC flags into</span>
</span>
<span class="line" id="L3318">        <span class="tok-comment">// windows-analagous operations</span>
</span>
<span class="line" id="L3319">        <span class="tok-kw">const</span> filtered_sock_type = socket_type &amp; ~<span class="tok-builtin">@as</span>(<span class="tok-type">u32</span>, SOCK.NONBLOCK | SOCK.CLOEXEC);</span>
<span class="line" id="L3320">        <span class="tok-kw">const</span> flags: <span class="tok-type">u32</span> = <span class="tok-kw">if</span> ((socket_type &amp; SOCK.CLOEXEC) != <span class="tok-number">0</span>)</span>
<span class="line" id="L3321">            windows.ws2_32.WSA_FLAG_NO_HANDLE_INHERIT</span>
<span class="line" id="L3322">        <span class="tok-kw">else</span></span>
<span class="line" id="L3323">            <span class="tok-number">0</span>;</span>
<span class="line" id="L3324">        <span class="tok-kw">const</span> rc = <span class="tok-kw">try</span> windows.WSASocketW(</span>
<span class="line" id="L3325">            <span class="tok-builtin">@bitCast</span>(<span class="tok-type">i32</span>, domain),</span>
<span class="line" id="L3326">            <span class="tok-builtin">@bitCast</span>(<span class="tok-type">i32</span>, filtered_sock_type),</span>
<span class="line" id="L3327">            <span class="tok-builtin">@bitCast</span>(<span class="tok-type">i32</span>, protocol),</span>
<span class="line" id="L3328">            <span class="tok-null">null</span>,</span>
<span class="line" id="L3329">            <span class="tok-number">0</span>,</span>
<span class="line" id="L3330">            flags,</span>
<span class="line" id="L3331">        );</span>
<span class="line" id="L3332">        <span class="tok-kw">errdefer</span> windows.closesocket(rc) <span class="tok-kw">catch</span> <span class="tok-kw">unreachable</span>;</span>
<span class="line" id="L3333">        <span class="tok-kw">if</span> ((socket_type &amp; SOCK.NONBLOCK) != <span class="tok-number">0</span>) {</span>
<span class="line" id="L3334">            <span class="tok-kw">var</span> mode: <span class="tok-type">c_ulong</span> = <span class="tok-number">1</span>; <span class="tok-comment">// nonblocking</span>
</span>
<span class="line" id="L3335">            <span class="tok-kw">if</span> (windows.ws2_32.SOCKET_ERROR == windows.ws2_32.ioctlsocket(rc, windows.ws2_32.FIONBIO, &amp;mode)) {</span>
<span class="line" id="L3336">                <span class="tok-kw">switch</span> (windows.ws2_32.WSAGetLastError()) {</span>
<span class="line" id="L3337">                    <span class="tok-comment">// have not identified any error codes that should be handled yet</span>
</span>
<span class="line" id="L3338">                    <span class="tok-kw">else</span> =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L3339">                }</span>
<span class="line" id="L3340">            }</span>
<span class="line" id="L3341">        }</span>
<span class="line" id="L3342">        <span class="tok-kw">return</span> rc;</span>
<span class="line" id="L3343">    }</span>
<span class="line" id="L3344"></span>
<span class="line" id="L3345">    <span class="tok-kw">const</span> have_sock_flags = <span class="tok-kw">comptime</span> !builtin.target.isDarwin();</span>
<span class="line" id="L3346">    <span class="tok-kw">const</span> filtered_sock_type = <span class="tok-kw">if</span> (!have_sock_flags)</span>
<span class="line" id="L3347">        socket_type &amp; ~<span class="tok-builtin">@as</span>(<span class="tok-type">u32</span>, SOCK.NONBLOCK | SOCK.CLOEXEC)</span>
<span class="line" id="L3348">    <span class="tok-kw">else</span></span>
<span class="line" id="L3349">        socket_type;</span>
<span class="line" id="L3350">    <span class="tok-kw">const</span> rc = system.socket(domain, filtered_sock_type, protocol);</span>
<span class="line" id="L3351">    <span class="tok-kw">switch</span> (errno(rc)) {</span>
<span class="line" id="L3352">        .SUCCESS =&gt; {</span>
<span class="line" id="L3353">            <span class="tok-kw">const</span> fd = <span class="tok-builtin">@intCast</span>(fd_t, rc);</span>
<span class="line" id="L3354">            <span class="tok-kw">if</span> (!have_sock_flags) {</span>
<span class="line" id="L3355">                <span class="tok-kw">try</span> setSockFlags(fd, socket_type);</span>
<span class="line" id="L3356">            }</span>
<span class="line" id="L3357">            <span class="tok-kw">return</span> fd;</span>
<span class="line" id="L3358">        },</span>
<span class="line" id="L3359">        .ACCES =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.PermissionDenied,</span>
<span class="line" id="L3360">        .AFNOSUPPORT =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.AddressFamilyNotSupported,</span>
<span class="line" id="L3361">        .INVAL =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.ProtocolFamilyNotAvailable,</span>
<span class="line" id="L3362">        .MFILE =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.ProcessFdQuotaExceeded,</span>
<span class="line" id="L3363">        .NFILE =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.SystemFdQuotaExceeded,</span>
<span class="line" id="L3364">        .NOBUFS =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.SystemResources,</span>
<span class="line" id="L3365">        .NOMEM =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.SystemResources,</span>
<span class="line" id="L3366">        .PROTONOSUPPORT =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.ProtocolNotSupported,</span>
<span class="line" id="L3367">        .PROTOTYPE =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.SocketTypeNotSupported,</span>
<span class="line" id="L3368">        <span class="tok-kw">else</span> =&gt; |err| <span class="tok-kw">return</span> unexpectedErrno(err),</span>
<span class="line" id="L3369">    }</span>
<span class="line" id="L3370">}</span>
<span class="line" id="L3371"></span>
<span class="line" id="L3372"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> ShutdownError = <span class="tok-kw">error</span>{</span>
<span class="line" id="L3373">    ConnectionAborted,</span>
<span class="line" id="L3374"></span>
<span class="line" id="L3375">    <span class="tok-comment">/// Connection was reset by peer, application should close socket as it is no longer usable.</span></span>
<span class="line" id="L3376">    ConnectionResetByPeer,</span>
<span class="line" id="L3377">    BlockingOperationInProgress,</span>
<span class="line" id="L3378"></span>
<span class="line" id="L3379">    <span class="tok-comment">/// The network subsystem has failed.</span></span>
<span class="line" id="L3380">    NetworkSubsystemFailed,</span>
<span class="line" id="L3381"></span>
<span class="line" id="L3382">    <span class="tok-comment">/// The socket is not connected (connection-oriented sockets only).</span></span>
<span class="line" id="L3383">    SocketNotConnected,</span>
<span class="line" id="L3384">    SystemResources,</span>
<span class="line" id="L3385">} || UnexpectedError;</span>
<span class="line" id="L3386"></span>
<span class="line" id="L3387"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> ShutdownHow = <span class="tok-kw">enum</span> { recv, send, both };</span>
<span class="line" id="L3388"></span>
<span class="line" id="L3389"><span class="tok-comment">/// Shutdown socket send/receive operations</span></span>
<span class="line" id="L3390"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">shutdown</span>(sock: socket_t, how: ShutdownHow) ShutdownError!<span class="tok-type">void</span> {</span>
<span class="line" id="L3391">    <span class="tok-kw">if</span> (builtin.os.tag == .windows) {</span>
<span class="line" id="L3392">        <span class="tok-kw">const</span> result = windows.ws2_32.shutdown(sock, <span class="tok-kw">switch</span> (how) {</span>
<span class="line" id="L3393">            .recv =&gt; windows.ws2_32.SD_RECEIVE,</span>
<span class="line" id="L3394">            .send =&gt; windows.ws2_32.SD_SEND,</span>
<span class="line" id="L3395">            .both =&gt; windows.ws2_32.SD_BOTH,</span>
<span class="line" id="L3396">        });</span>
<span class="line" id="L3397">        <span class="tok-kw">if</span> (<span class="tok-number">0</span> != result) <span class="tok-kw">switch</span> (windows.ws2_32.WSAGetLastError()) {</span>
<span class="line" id="L3398">            .WSAECONNABORTED =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.ConnectionAborted,</span>
<span class="line" id="L3399">            .WSAECONNRESET =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.ConnectionResetByPeer,</span>
<span class="line" id="L3400">            .WSAEINPROGRESS =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.BlockingOperationInProgress,</span>
<span class="line" id="L3401">            .WSAEINVAL =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L3402">            .WSAENETDOWN =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.NetworkSubsystemFailed,</span>
<span class="line" id="L3403">            .WSAENOTCONN =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.SocketNotConnected,</span>
<span class="line" id="L3404">            .WSAENOTSOCK =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L3405">            .WSANOTINITIALISED =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L3406">            <span class="tok-kw">else</span> =&gt; |err| <span class="tok-kw">return</span> windows.unexpectedWSAError(err),</span>
<span class="line" id="L3407">        };</span>
<span class="line" id="L3408">    } <span class="tok-kw">else</span> {</span>
<span class="line" id="L3409">        <span class="tok-kw">const</span> rc = system.shutdown(sock, <span class="tok-kw">switch</span> (how) {</span>
<span class="line" id="L3410">            .recv =&gt; SHUT.RD,</span>
<span class="line" id="L3411">            .send =&gt; SHUT.WR,</span>
<span class="line" id="L3412">            .both =&gt; SHUT.RDWR,</span>
<span class="line" id="L3413">        });</span>
<span class="line" id="L3414">        <span class="tok-kw">switch</span> (errno(rc)) {</span>
<span class="line" id="L3415">            .SUCCESS =&gt; <span class="tok-kw">return</span>,</span>
<span class="line" id="L3416">            .BADF =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L3417">            .INVAL =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L3418">            .NOTCONN =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.SocketNotConnected,</span>
<span class="line" id="L3419">            .NOTSOCK =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L3420">            .NOBUFS =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.SystemResources,</span>
<span class="line" id="L3421">            <span class="tok-kw">else</span> =&gt; |err| <span class="tok-kw">return</span> unexpectedErrno(err),</span>
<span class="line" id="L3422">        }</span>
<span class="line" id="L3423">    }</span>
<span class="line" id="L3424">}</span>
<span class="line" id="L3425"></span>
<span class="line" id="L3426"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">closeSocket</span>(sock: socket_t) <span class="tok-type">void</span> {</span>
<span class="line" id="L3427">    <span class="tok-kw">if</span> (builtin.os.tag == .windows) {</span>
<span class="line" id="L3428">        windows.closesocket(sock) <span class="tok-kw">catch</span> <span class="tok-kw">unreachable</span>;</span>
<span class="line" id="L3429">    } <span class="tok-kw">else</span> {</span>
<span class="line" id="L3430">        close(sock);</span>
<span class="line" id="L3431">    }</span>
<span class="line" id="L3432">}</span>
<span class="line" id="L3433"></span>
<span class="line" id="L3434"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> BindError = <span class="tok-kw">error</span>{</span>
<span class="line" id="L3435">    <span class="tok-comment">/// The address is protected, and the user is not the superuser.</span></span>
<span class="line" id="L3436">    <span class="tok-comment">/// For UNIX domain sockets: Search permission is denied on  a  component</span></span>
<span class="line" id="L3437">    <span class="tok-comment">/// of  the  path  prefix.</span></span>
<span class="line" id="L3438">    AccessDenied,</span>
<span class="line" id="L3439"></span>
<span class="line" id="L3440">    <span class="tok-comment">/// The given address is already in use, or in the case of Internet domain sockets,</span></span>
<span class="line" id="L3441">    <span class="tok-comment">/// The  port number was specified as zero in the socket</span></span>
<span class="line" id="L3442">    <span class="tok-comment">/// address structure, but, upon attempting to bind to  an  ephemeral  port,  it  was</span></span>
<span class="line" id="L3443">    <span class="tok-comment">/// determined  that  all  port  numbers in the ephemeral port range are currently in</span></span>
<span class="line" id="L3444">    <span class="tok-comment">/// use.  See the discussion of /proc/sys/net/ipv4/ip_local_port_range ip(7).</span></span>
<span class="line" id="L3445">    AddressInUse,</span>
<span class="line" id="L3446"></span>
<span class="line" id="L3447">    <span class="tok-comment">/// A nonexistent interface was requested or the requested address was not local.</span></span>
<span class="line" id="L3448">    AddressNotAvailable,</span>
<span class="line" id="L3449"></span>
<span class="line" id="L3450">    <span class="tok-comment">/// Too many symbolic links were encountered in resolving addr.</span></span>
<span class="line" id="L3451">    SymLinkLoop,</span>
<span class="line" id="L3452"></span>
<span class="line" id="L3453">    <span class="tok-comment">/// addr is too long.</span></span>
<span class="line" id="L3454">    NameTooLong,</span>
<span class="line" id="L3455"></span>
<span class="line" id="L3456">    <span class="tok-comment">/// A component in the directory prefix of the socket pathname does not exist.</span></span>
<span class="line" id="L3457">    FileNotFound,</span>
<span class="line" id="L3458"></span>
<span class="line" id="L3459">    <span class="tok-comment">/// Insufficient kernel memory was available.</span></span>
<span class="line" id="L3460">    SystemResources,</span>
<span class="line" id="L3461"></span>
<span class="line" id="L3462">    <span class="tok-comment">/// A component of the path prefix is not a directory.</span></span>
<span class="line" id="L3463">    NotDir,</span>
<span class="line" id="L3464"></span>
<span class="line" id="L3465">    <span class="tok-comment">/// The socket inode would reside on a read-only filesystem.</span></span>
<span class="line" id="L3466">    ReadOnlyFileSystem,</span>
<span class="line" id="L3467"></span>
<span class="line" id="L3468">    <span class="tok-comment">/// The network subsystem has failed.</span></span>
<span class="line" id="L3469">    NetworkSubsystemFailed,</span>
<span class="line" id="L3470"></span>
<span class="line" id="L3471">    FileDescriptorNotASocket,</span>
<span class="line" id="L3472"></span>
<span class="line" id="L3473">    AlreadyBound,</span>
<span class="line" id="L3474">} || UnexpectedError;</span>
<span class="line" id="L3475"></span>
<span class="line" id="L3476"><span class="tok-comment">/// addr is `*const T` where T is one of the sockaddr</span></span>
<span class="line" id="L3477"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">bind</span>(sock: socket_t, addr: *<span class="tok-kw">const</span> sockaddr, len: socklen_t) BindError!<span class="tok-type">void</span> {</span>
<span class="line" id="L3478">    <span class="tok-kw">if</span> (builtin.os.tag == .windows) {</span>
<span class="line" id="L3479">        <span class="tok-kw">const</span> rc = windows.bind(sock, addr, len);</span>
<span class="line" id="L3480">        <span class="tok-kw">if</span> (rc == windows.ws2_32.SOCKET_ERROR) {</span>
<span class="line" id="L3481">            <span class="tok-kw">switch</span> (windows.ws2_32.WSAGetLastError()) {</span>
<span class="line" id="L3482">                .WSANOTINITIALISED =&gt; <span class="tok-kw">unreachable</span>, <span class="tok-comment">// not initialized WSA</span>
</span>
<span class="line" id="L3483">                .WSAEACCES =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.AccessDenied,</span>
<span class="line" id="L3484">                .WSAEADDRINUSE =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.AddressInUse,</span>
<span class="line" id="L3485">                .WSAEADDRNOTAVAIL =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.AddressNotAvailable,</span>
<span class="line" id="L3486">                .WSAENOTSOCK =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.FileDescriptorNotASocket,</span>
<span class="line" id="L3487">                .WSAEFAULT =&gt; <span class="tok-kw">unreachable</span>, <span class="tok-comment">// invalid pointers</span>
</span>
<span class="line" id="L3488">                .WSAEINVAL =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.AlreadyBound,</span>
<span class="line" id="L3489">                .WSAENOBUFS =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.SystemResources,</span>
<span class="line" id="L3490">                .WSAENETDOWN =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.NetworkSubsystemFailed,</span>
<span class="line" id="L3491">                <span class="tok-kw">else</span> =&gt; |err| <span class="tok-kw">return</span> windows.unexpectedWSAError(err),</span>
<span class="line" id="L3492">            }</span>
<span class="line" id="L3493">            <span class="tok-kw">unreachable</span>;</span>
<span class="line" id="L3494">        }</span>
<span class="line" id="L3495">        <span class="tok-kw">return</span>;</span>
<span class="line" id="L3496">    } <span class="tok-kw">else</span> {</span>
<span class="line" id="L3497">        <span class="tok-kw">const</span> rc = system.bind(sock, addr, len);</span>
<span class="line" id="L3498">        <span class="tok-kw">switch</span> (errno(rc)) {</span>
<span class="line" id="L3499">            .SUCCESS =&gt; <span class="tok-kw">return</span>,</span>
<span class="line" id="L3500">            .ACCES =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.AccessDenied,</span>
<span class="line" id="L3501">            .ADDRINUSE =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.AddressInUse,</span>
<span class="line" id="L3502">            .BADF =&gt; <span class="tok-kw">unreachable</span>, <span class="tok-comment">// always a race condition if this error is returned</span>
</span>
<span class="line" id="L3503">            .INVAL =&gt; <span class="tok-kw">unreachable</span>, <span class="tok-comment">// invalid parameters</span>
</span>
<span class="line" id="L3504">            .NOTSOCK =&gt; <span class="tok-kw">unreachable</span>, <span class="tok-comment">// invalid `sockfd`</span>
</span>
<span class="line" id="L3505">            .ADDRNOTAVAIL =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.AddressNotAvailable,</span>
<span class="line" id="L3506">            .FAULT =&gt; <span class="tok-kw">unreachable</span>, <span class="tok-comment">// invalid `addr` pointer</span>
</span>
<span class="line" id="L3507">            .LOOP =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.SymLinkLoop,</span>
<span class="line" id="L3508">            .NAMETOOLONG =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.NameTooLong,</span>
<span class="line" id="L3509">            .NOENT =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.FileNotFound,</span>
<span class="line" id="L3510">            .NOMEM =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.SystemResources,</span>
<span class="line" id="L3511">            .NOTDIR =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.NotDir,</span>
<span class="line" id="L3512">            .ROFS =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.ReadOnlyFileSystem,</span>
<span class="line" id="L3513">            <span class="tok-kw">else</span> =&gt; |err| <span class="tok-kw">return</span> unexpectedErrno(err),</span>
<span class="line" id="L3514">        }</span>
<span class="line" id="L3515">    }</span>
<span class="line" id="L3516">    <span class="tok-kw">unreachable</span>;</span>
<span class="line" id="L3517">}</span>
<span class="line" id="L3518"></span>
<span class="line" id="L3519"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> ListenError = <span class="tok-kw">error</span>{</span>
<span class="line" id="L3520">    <span class="tok-comment">/// Another socket is already listening on the same port.</span></span>
<span class="line" id="L3521">    <span class="tok-comment">/// For Internet domain sockets, the  socket referred to by sockfd had not previously</span></span>
<span class="line" id="L3522">    <span class="tok-comment">/// been bound to an address and, upon attempting to bind it to an ephemeral port, it</span></span>
<span class="line" id="L3523">    <span class="tok-comment">/// was determined that all port numbers in the ephemeral port range are currently in</span></span>
<span class="line" id="L3524">    <span class="tok-comment">/// use.  See the discussion of /proc/sys/net/ipv4/ip_local_port_range in ip(7).</span></span>
<span class="line" id="L3525">    AddressInUse,</span>
<span class="line" id="L3526"></span>
<span class="line" id="L3527">    <span class="tok-comment">/// The file descriptor sockfd does not refer to a socket.</span></span>
<span class="line" id="L3528">    FileDescriptorNotASocket,</span>
<span class="line" id="L3529"></span>
<span class="line" id="L3530">    <span class="tok-comment">/// The socket is not of a type that supports the listen() operation.</span></span>
<span class="line" id="L3531">    OperationNotSupported,</span>
<span class="line" id="L3532"></span>
<span class="line" id="L3533">    <span class="tok-comment">/// The network subsystem has failed.</span></span>
<span class="line" id="L3534">    NetworkSubsystemFailed,</span>
<span class="line" id="L3535"></span>
<span class="line" id="L3536">    <span class="tok-comment">/// Ran out of system resources</span></span>
<span class="line" id="L3537">    <span class="tok-comment">/// On Windows it can either run out of socket descriptors or buffer space</span></span>
<span class="line" id="L3538">    SystemResources,</span>
<span class="line" id="L3539"></span>
<span class="line" id="L3540">    <span class="tok-comment">/// Already connected</span></span>
<span class="line" id="L3541">    AlreadyConnected,</span>
<span class="line" id="L3542"></span>
<span class="line" id="L3543">    <span class="tok-comment">/// Socket has not been bound yet</span></span>
<span class="line" id="L3544">    SocketNotBound,</span>
<span class="line" id="L3545">} || UnexpectedError;</span>
<span class="line" id="L3546"></span>
<span class="line" id="L3547"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">listen</span>(sock: socket_t, backlog: <span class="tok-type">u31</span>) ListenError!<span class="tok-type">void</span> {</span>
<span class="line" id="L3548">    <span class="tok-kw">if</span> (builtin.os.tag == .windows) {</span>
<span class="line" id="L3549">        <span class="tok-kw">const</span> rc = windows.listen(sock, backlog);</span>
<span class="line" id="L3550">        <span class="tok-kw">if</span> (rc == windows.ws2_32.SOCKET_ERROR) {</span>
<span class="line" id="L3551">            <span class="tok-kw">switch</span> (windows.ws2_32.WSAGetLastError()) {</span>
<span class="line" id="L3552">                .WSANOTINITIALISED =&gt; <span class="tok-kw">unreachable</span>, <span class="tok-comment">// not initialized WSA</span>
</span>
<span class="line" id="L3553">                .WSAENETDOWN =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.NetworkSubsystemFailed,</span>
<span class="line" id="L3554">                .WSAEADDRINUSE =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.AddressInUse,</span>
<span class="line" id="L3555">                .WSAEISCONN =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.AlreadyConnected,</span>
<span class="line" id="L3556">                .WSAEINVAL =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.SocketNotBound,</span>
<span class="line" id="L3557">                .WSAEMFILE, .WSAENOBUFS =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.SystemResources,</span>
<span class="line" id="L3558">                .WSAENOTSOCK =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.FileDescriptorNotASocket,</span>
<span class="line" id="L3559">                .WSAEOPNOTSUPP =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.OperationNotSupported,</span>
<span class="line" id="L3560">                .WSAEINPROGRESS =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L3561">                <span class="tok-kw">else</span> =&gt; |err| <span class="tok-kw">return</span> windows.unexpectedWSAError(err),</span>
<span class="line" id="L3562">            }</span>
<span class="line" id="L3563">        }</span>
<span class="line" id="L3564">        <span class="tok-kw">return</span>;</span>
<span class="line" id="L3565">    } <span class="tok-kw">else</span> {</span>
<span class="line" id="L3566">        <span class="tok-kw">const</span> rc = system.listen(sock, backlog);</span>
<span class="line" id="L3567">        <span class="tok-kw">switch</span> (errno(rc)) {</span>
<span class="line" id="L3568">            .SUCCESS =&gt; <span class="tok-kw">return</span>,</span>
<span class="line" id="L3569">            .ADDRINUSE =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.AddressInUse,</span>
<span class="line" id="L3570">            .BADF =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L3571">            .NOTSOCK =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.FileDescriptorNotASocket,</span>
<span class="line" id="L3572">            .OPNOTSUPP =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.OperationNotSupported,</span>
<span class="line" id="L3573">            <span class="tok-kw">else</span> =&gt; |err| <span class="tok-kw">return</span> unexpectedErrno(err),</span>
<span class="line" id="L3574">        }</span>
<span class="line" id="L3575">    }</span>
<span class="line" id="L3576">}</span>
<span class="line" id="L3577"></span>
<span class="line" id="L3578"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> AcceptError = <span class="tok-kw">error</span>{</span>
<span class="line" id="L3579">    ConnectionAborted,</span>
<span class="line" id="L3580"></span>
<span class="line" id="L3581">    <span class="tok-comment">/// The file descriptor sockfd does not refer to a socket.</span></span>
<span class="line" id="L3582">    FileDescriptorNotASocket,</span>
<span class="line" id="L3583"></span>
<span class="line" id="L3584">    <span class="tok-comment">/// The per-process limit on the number of open file descriptors has been reached.</span></span>
<span class="line" id="L3585">    ProcessFdQuotaExceeded,</span>
<span class="line" id="L3586"></span>
<span class="line" id="L3587">    <span class="tok-comment">/// The system-wide limit on the total number of open files has been reached.</span></span>
<span class="line" id="L3588">    SystemFdQuotaExceeded,</span>
<span class="line" id="L3589"></span>
<span class="line" id="L3590">    <span class="tok-comment">/// Not enough free memory.  This often means that the memory allocation  is  limited</span></span>
<span class="line" id="L3591">    <span class="tok-comment">/// by the socket buffer limits, not by the system memory.</span></span>
<span class="line" id="L3592">    SystemResources,</span>
<span class="line" id="L3593"></span>
<span class="line" id="L3594">    <span class="tok-comment">/// Socket is not listening for new connections.</span></span>
<span class="line" id="L3595">    SocketNotListening,</span>
<span class="line" id="L3596"></span>
<span class="line" id="L3597">    ProtocolFailure,</span>
<span class="line" id="L3598"></span>
<span class="line" id="L3599">    <span class="tok-comment">/// Firewall rules forbid connection.</span></span>
<span class="line" id="L3600">    BlockedByFirewall,</span>
<span class="line" id="L3601"></span>
<span class="line" id="L3602">    <span class="tok-comment">/// This error occurs when no global event loop is configured,</span></span>
<span class="line" id="L3603">    <span class="tok-comment">/// and accepting from the socket would block.</span></span>
<span class="line" id="L3604">    WouldBlock,</span>
<span class="line" id="L3605"></span>
<span class="line" id="L3606">    <span class="tok-comment">/// An incoming connection was indicated, but was subsequently terminated by the</span></span>
<span class="line" id="L3607">    <span class="tok-comment">/// remote peer prior to accepting the call.</span></span>
<span class="line" id="L3608">    ConnectionResetByPeer,</span>
<span class="line" id="L3609"></span>
<span class="line" id="L3610">    <span class="tok-comment">/// The network subsystem has failed.</span></span>
<span class="line" id="L3611">    NetworkSubsystemFailed,</span>
<span class="line" id="L3612"></span>
<span class="line" id="L3613">    <span class="tok-comment">/// The referenced socket is not a type that supports connection-oriented service.</span></span>
<span class="line" id="L3614">    OperationNotSupported,</span>
<span class="line" id="L3615">} || UnexpectedError;</span>
<span class="line" id="L3616"></span>
<span class="line" id="L3617"><span class="tok-comment">/// Accept a connection on a socket.</span></span>
<span class="line" id="L3618"><span class="tok-comment">/// If `sockfd` is opened in non blocking mode, the function will</span></span>
<span class="line" id="L3619"><span class="tok-comment">/// return error.WouldBlock when EAGAIN is received.</span></span>
<span class="line" id="L3620"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">accept</span>(</span>
<span class="line" id="L3621">    <span class="tok-comment">/// This argument is a socket that has been created with `socket`, bound to a local address</span></span>
<span class="line" id="L3622">    <span class="tok-comment">/// with `bind`, and is listening for connections after a `listen`.</span></span>
<span class="line" id="L3623">    sock: socket_t,</span>
<span class="line" id="L3624">    <span class="tok-comment">/// This argument is a pointer to a sockaddr structure.  This structure is filled in with  the</span></span>
<span class="line" id="L3625">    <span class="tok-comment">/// address  of  the  peer  socket, as known to the communications layer.  The exact format of the</span></span>
<span class="line" id="L3626">    <span class="tok-comment">/// address returned addr is determined by the socket's address  family  (see  `socket`  and  the</span></span>
<span class="line" id="L3627">    <span class="tok-comment">/// respective  protocol  man  pages).</span></span>
<span class="line" id="L3628">    addr: ?*sockaddr,</span>
<span class="line" id="L3629">    <span class="tok-comment">/// This argument is a value-result argument: the caller must initialize it to contain  the</span></span>
<span class="line" id="L3630">    <span class="tok-comment">/// size (in bytes) of the structure pointed to by addr; on return it will contain the actual size</span></span>
<span class="line" id="L3631">    <span class="tok-comment">/// of the peer address.</span></span>
<span class="line" id="L3632">    <span class="tok-comment">///</span></span>
<span class="line" id="L3633">    <span class="tok-comment">/// The returned address is truncated if the buffer provided is too small; in this  case,  `addr_size`</span></span>
<span class="line" id="L3634">    <span class="tok-comment">/// will return a value greater than was supplied to the call.</span></span>
<span class="line" id="L3635">    addr_size: ?*socklen_t,</span>
<span class="line" id="L3636">    <span class="tok-comment">/// The following values can be bitwise ORed in flags to obtain different behavior:</span></span>
<span class="line" id="L3637">    <span class="tok-comment">/// * `SOCK.NONBLOCK` - Set the `O.NONBLOCK` file status flag on the open file description (see `open`)</span></span>
<span class="line" id="L3638">    <span class="tok-comment">///   referred  to by the new file descriptor.  Using this flag saves extra calls to `fcntl` to achieve</span></span>
<span class="line" id="L3639">    <span class="tok-comment">///   the same result.</span></span>
<span class="line" id="L3640">    <span class="tok-comment">/// * `SOCK.CLOEXEC`  - Set the close-on-exec (`FD_CLOEXEC`) flag on the new file descriptor.   See  the</span></span>
<span class="line" id="L3641">    <span class="tok-comment">///   description  of the `O.CLOEXEC` flag in `open` for reasons why this may be useful.</span></span>
<span class="line" id="L3642">    flags: <span class="tok-type">u32</span>,</span>
<span class="line" id="L3643">) AcceptError!socket_t {</span>
<span class="line" id="L3644">    <span class="tok-kw">const</span> have_accept4 = <span class="tok-kw">comptime</span> !(builtin.target.isDarwin() <span class="tok-kw">or</span> builtin.os.tag == .windows);</span>
<span class="line" id="L3645">    assert(<span class="tok-number">0</span> == (flags &amp; ~<span class="tok-builtin">@as</span>(<span class="tok-type">u32</span>, SOCK.NONBLOCK | SOCK.CLOEXEC))); <span class="tok-comment">// Unsupported flag(s)</span>
</span>
<span class="line" id="L3646"></span>
<span class="line" id="L3647">    <span class="tok-kw">const</span> accepted_sock = <span class="tok-kw">while</span> (<span class="tok-null">true</span>) {</span>
<span class="line" id="L3648">        <span class="tok-kw">const</span> rc = <span class="tok-kw">if</span> (have_accept4)</span>
<span class="line" id="L3649">            system.accept4(sock, addr, addr_size, flags)</span>
<span class="line" id="L3650">        <span class="tok-kw">else</span> <span class="tok-kw">if</span> (builtin.os.tag == .windows)</span>
<span class="line" id="L3651">            windows.accept(sock, addr, addr_size)</span>
<span class="line" id="L3652">        <span class="tok-kw">else</span></span>
<span class="line" id="L3653">            system.accept(sock, addr, addr_size);</span>
<span class="line" id="L3654"></span>
<span class="line" id="L3655">        <span class="tok-kw">if</span> (builtin.os.tag == .windows) {</span>
<span class="line" id="L3656">            <span class="tok-kw">if</span> (rc == windows.ws2_32.INVALID_SOCKET) {</span>
<span class="line" id="L3657">                <span class="tok-kw">switch</span> (windows.ws2_32.WSAGetLastError()) {</span>
<span class="line" id="L3658">                    .WSANOTINITIALISED =&gt; <span class="tok-kw">unreachable</span>, <span class="tok-comment">// not initialized WSA</span>
</span>
<span class="line" id="L3659">                    .WSAECONNRESET =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.ConnectionResetByPeer,</span>
<span class="line" id="L3660">                    .WSAEFAULT =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L3661">                    .WSAEINVAL =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.SocketNotListening,</span>
<span class="line" id="L3662">                    .WSAEMFILE =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.ProcessFdQuotaExceeded,</span>
<span class="line" id="L3663">                    .WSAENETDOWN =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.NetworkSubsystemFailed,</span>
<span class="line" id="L3664">                    .WSAENOBUFS =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.FileDescriptorNotASocket,</span>
<span class="line" id="L3665">                    .WSAEOPNOTSUPP =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.OperationNotSupported,</span>
<span class="line" id="L3666">                    .WSAEWOULDBLOCK =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.WouldBlock,</span>
<span class="line" id="L3667">                    <span class="tok-kw">else</span> =&gt; |err| <span class="tok-kw">return</span> windows.unexpectedWSAError(err),</span>
<span class="line" id="L3668">                }</span>
<span class="line" id="L3669">            } <span class="tok-kw">else</span> {</span>
<span class="line" id="L3670">                <span class="tok-kw">break</span> rc;</span>
<span class="line" id="L3671">            }</span>
<span class="line" id="L3672">        } <span class="tok-kw">else</span> {</span>
<span class="line" id="L3673">            <span class="tok-kw">switch</span> (errno(rc)) {</span>
<span class="line" id="L3674">                .SUCCESS =&gt; {</span>
<span class="line" id="L3675">                    <span class="tok-kw">break</span> <span class="tok-builtin">@intCast</span>(socket_t, rc);</span>
<span class="line" id="L3676">                },</span>
<span class="line" id="L3677">                .INTR =&gt; <span class="tok-kw">continue</span>,</span>
<span class="line" id="L3678">                .AGAIN =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.WouldBlock,</span>
<span class="line" id="L3679">                .BADF =&gt; <span class="tok-kw">unreachable</span>, <span class="tok-comment">// always a race condition</span>
</span>
<span class="line" id="L3680">                .CONNABORTED =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.ConnectionAborted,</span>
<span class="line" id="L3681">                .FAULT =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L3682">                .INVAL =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.SocketNotListening,</span>
<span class="line" id="L3683">                .NOTSOCK =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L3684">                .MFILE =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.ProcessFdQuotaExceeded,</span>
<span class="line" id="L3685">                .NFILE =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.SystemFdQuotaExceeded,</span>
<span class="line" id="L3686">                .NOBUFS =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.SystemResources,</span>
<span class="line" id="L3687">                .NOMEM =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.SystemResources,</span>
<span class="line" id="L3688">                .OPNOTSUPP =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L3689">                .PROTO =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.ProtocolFailure,</span>
<span class="line" id="L3690">                .PERM =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.BlockedByFirewall,</span>
<span class="line" id="L3691">                <span class="tok-kw">else</span> =&gt; |err| <span class="tok-kw">return</span> unexpectedErrno(err),</span>
<span class="line" id="L3692">            }</span>
<span class="line" id="L3693">        }</span>
<span class="line" id="L3694">    } <span class="tok-kw">else</span> <span class="tok-kw">unreachable</span>;</span>
<span class="line" id="L3695"></span>
<span class="line" id="L3696">    <span class="tok-kw">if</span> (!have_accept4) {</span>
<span class="line" id="L3697">        <span class="tok-kw">try</span> setSockFlags(accepted_sock, flags);</span>
<span class="line" id="L3698">    }</span>
<span class="line" id="L3699">    <span class="tok-kw">return</span> accepted_sock;</span>
<span class="line" id="L3700">}</span>
<span class="line" id="L3701"></span>
<span class="line" id="L3702"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> EpollCreateError = <span class="tok-kw">error</span>{</span>
<span class="line" id="L3703">    <span class="tok-comment">/// The  per-user   limit   on   the   number   of   epoll   instances   imposed   by</span></span>
<span class="line" id="L3704">    <span class="tok-comment">/// /proc/sys/fs/epoll/max_user_instances  was encountered.  See epoll(7) for further</span></span>
<span class="line" id="L3705">    <span class="tok-comment">/// details.</span></span>
<span class="line" id="L3706">    <span class="tok-comment">/// Or, The per-process limit on the number of open file descriptors has been reached.</span></span>
<span class="line" id="L3707">    ProcessFdQuotaExceeded,</span>
<span class="line" id="L3708"></span>
<span class="line" id="L3709">    <span class="tok-comment">/// The system-wide limit on the total number of open files has been reached.</span></span>
<span class="line" id="L3710">    SystemFdQuotaExceeded,</span>
<span class="line" id="L3711"></span>
<span class="line" id="L3712">    <span class="tok-comment">/// There was insufficient memory to create the kernel object.</span></span>
<span class="line" id="L3713">    SystemResources,</span>
<span class="line" id="L3714">} || UnexpectedError;</span>
<span class="line" id="L3715"></span>
<span class="line" id="L3716"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">epoll_create1</span>(flags: <span class="tok-type">u32</span>) EpollCreateError!<span class="tok-type">i32</span> {</span>
<span class="line" id="L3717">    <span class="tok-kw">const</span> rc = system.epoll_create1(flags);</span>
<span class="line" id="L3718">    <span class="tok-kw">switch</span> (errno(rc)) {</span>
<span class="line" id="L3719">        .SUCCESS =&gt; <span class="tok-kw">return</span> <span class="tok-builtin">@intCast</span>(<span class="tok-type">i32</span>, rc),</span>
<span class="line" id="L3720">        <span class="tok-kw">else</span> =&gt; |err| <span class="tok-kw">return</span> unexpectedErrno(err),</span>
<span class="line" id="L3721"></span>
<span class="line" id="L3722">        .INVAL =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L3723">        .MFILE =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.ProcessFdQuotaExceeded,</span>
<span class="line" id="L3724">        .NFILE =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.SystemFdQuotaExceeded,</span>
<span class="line" id="L3725">        .NOMEM =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.SystemResources,</span>
<span class="line" id="L3726">    }</span>
<span class="line" id="L3727">}</span>
<span class="line" id="L3728"></span>
<span class="line" id="L3729"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> EpollCtlError = <span class="tok-kw">error</span>{</span>
<span class="line" id="L3730">    <span class="tok-comment">/// op was EPOLL_CTL_ADD, and the supplied file descriptor fd is  already  registered</span></span>
<span class="line" id="L3731">    <span class="tok-comment">/// with this epoll instance.</span></span>
<span class="line" id="L3732">    FileDescriptorAlreadyPresentInSet,</span>
<span class="line" id="L3733"></span>
<span class="line" id="L3734">    <span class="tok-comment">/// fd refers to an epoll instance and this EPOLL_CTL_ADD operation would result in a</span></span>
<span class="line" id="L3735">    <span class="tok-comment">/// circular loop of epoll instances monitoring one another.</span></span>
<span class="line" id="L3736">    OperationCausesCircularLoop,</span>
<span class="line" id="L3737"></span>
<span class="line" id="L3738">    <span class="tok-comment">/// op was EPOLL_CTL_MOD or EPOLL_CTL_DEL, and fd is not registered with  this  epoll</span></span>
<span class="line" id="L3739">    <span class="tok-comment">/// instance.</span></span>
<span class="line" id="L3740">    FileDescriptorNotRegistered,</span>
<span class="line" id="L3741"></span>
<span class="line" id="L3742">    <span class="tok-comment">/// There was insufficient memory to handle the requested op control operation.</span></span>
<span class="line" id="L3743">    SystemResources,</span>
<span class="line" id="L3744"></span>
<span class="line" id="L3745">    <span class="tok-comment">/// The  limit  imposed  by /proc/sys/fs/epoll/max_user_watches was encountered while</span></span>
<span class="line" id="L3746">    <span class="tok-comment">/// trying to register (EPOLL_CTL_ADD) a new file descriptor on  an  epoll  instance.</span></span>
<span class="line" id="L3747">    <span class="tok-comment">/// See epoll(7) for further details.</span></span>
<span class="line" id="L3748">    UserResourceLimitReached,</span>
<span class="line" id="L3749"></span>
<span class="line" id="L3750">    <span class="tok-comment">/// The target file fd does not support epoll.  This error can occur if fd refers to,</span></span>
<span class="line" id="L3751">    <span class="tok-comment">/// for example, a regular file or a directory.</span></span>
<span class="line" id="L3752">    FileDescriptorIncompatibleWithEpoll,</span>
<span class="line" id="L3753">} || UnexpectedError;</span>
<span class="line" id="L3754"></span>
<span class="line" id="L3755"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">epoll_ctl</span>(epfd: <span class="tok-type">i32</span>, op: <span class="tok-type">u32</span>, fd: <span class="tok-type">i32</span>, event: ?*linux.epoll_event) EpollCtlError!<span class="tok-type">void</span> {</span>
<span class="line" id="L3756">    <span class="tok-kw">const</span> rc = system.epoll_ctl(epfd, op, fd, event);</span>
<span class="line" id="L3757">    <span class="tok-kw">switch</span> (errno(rc)) {</span>
<span class="line" id="L3758">        .SUCCESS =&gt; <span class="tok-kw">return</span>,</span>
<span class="line" id="L3759">        <span class="tok-kw">else</span> =&gt; |err| <span class="tok-kw">return</span> unexpectedErrno(err),</span>
<span class="line" id="L3760"></span>
<span class="line" id="L3761">        .BADF =&gt; <span class="tok-kw">unreachable</span>, <span class="tok-comment">// always a race condition if this happens</span>
</span>
<span class="line" id="L3762">        .EXIST =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.FileDescriptorAlreadyPresentInSet,</span>
<span class="line" id="L3763">        .INVAL =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L3764">        .LOOP =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.OperationCausesCircularLoop,</span>
<span class="line" id="L3765">        .NOENT =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.FileDescriptorNotRegistered,</span>
<span class="line" id="L3766">        .NOMEM =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.SystemResources,</span>
<span class="line" id="L3767">        .NOSPC =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.UserResourceLimitReached,</span>
<span class="line" id="L3768">        .PERM =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.FileDescriptorIncompatibleWithEpoll,</span>
<span class="line" id="L3769">    }</span>
<span class="line" id="L3770">}</span>
<span class="line" id="L3771"></span>
<span class="line" id="L3772"><span class="tok-comment">/// Waits for an I/O event on an epoll file descriptor.</span></span>
<span class="line" id="L3773"><span class="tok-comment">/// Returns the number of file descriptors ready for the requested I/O,</span></span>
<span class="line" id="L3774"><span class="tok-comment">/// or zero if no file descriptor became ready during the requested timeout milliseconds.</span></span>
<span class="line" id="L3775"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">epoll_wait</span>(epfd: <span class="tok-type">i32</span>, events: []linux.epoll_event, timeout: <span class="tok-type">i32</span>) <span class="tok-type">usize</span> {</span>
<span class="line" id="L3776">    <span class="tok-kw">while</span> (<span class="tok-null">true</span>) {</span>
<span class="line" id="L3777">        <span class="tok-comment">// TODO get rid of the @intCast</span>
</span>
<span class="line" id="L3778">        <span class="tok-kw">const</span> rc = system.epoll_wait(epfd, events.ptr, <span class="tok-builtin">@intCast</span>(<span class="tok-type">u32</span>, events.len), timeout);</span>
<span class="line" id="L3779">        <span class="tok-kw">switch</span> (errno(rc)) {</span>
<span class="line" id="L3780">            .SUCCESS =&gt; <span class="tok-kw">return</span> <span class="tok-builtin">@intCast</span>(<span class="tok-type">usize</span>, rc),</span>
<span class="line" id="L3781">            .INTR =&gt; <span class="tok-kw">continue</span>,</span>
<span class="line" id="L3782">            .BADF =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L3783">            .FAULT =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L3784">            .INVAL =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L3785">            <span class="tok-kw">else</span> =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L3786">        }</span>
<span class="line" id="L3787">    }</span>
<span class="line" id="L3788">}</span>
<span class="line" id="L3789"></span>
<span class="line" id="L3790"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> EventFdError = <span class="tok-kw">error</span>{</span>
<span class="line" id="L3791">    SystemResources,</span>
<span class="line" id="L3792">    ProcessFdQuotaExceeded,</span>
<span class="line" id="L3793">    SystemFdQuotaExceeded,</span>
<span class="line" id="L3794">} || UnexpectedError;</span>
<span class="line" id="L3795"></span>
<span class="line" id="L3796"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">eventfd</span>(initval: <span class="tok-type">u32</span>, flags: <span class="tok-type">u32</span>) EventFdError!<span class="tok-type">i32</span> {</span>
<span class="line" id="L3797">    <span class="tok-kw">const</span> rc = system.eventfd(initval, flags);</span>
<span class="line" id="L3798">    <span class="tok-kw">switch</span> (errno(rc)) {</span>
<span class="line" id="L3799">        .SUCCESS =&gt; <span class="tok-kw">return</span> <span class="tok-builtin">@intCast</span>(<span class="tok-type">i32</span>, rc),</span>
<span class="line" id="L3800">        <span class="tok-kw">else</span> =&gt; |err| <span class="tok-kw">return</span> unexpectedErrno(err),</span>
<span class="line" id="L3801"></span>
<span class="line" id="L3802">        .INVAL =&gt; <span class="tok-kw">unreachable</span>, <span class="tok-comment">// invalid parameters</span>
</span>
<span class="line" id="L3803">        .MFILE =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.ProcessFdQuotaExceeded,</span>
<span class="line" id="L3804">        .NFILE =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.SystemFdQuotaExceeded,</span>
<span class="line" id="L3805">        .NODEV =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.SystemResources,</span>
<span class="line" id="L3806">        .NOMEM =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.SystemResources,</span>
<span class="line" id="L3807">    }</span>
<span class="line" id="L3808">}</span>
<span class="line" id="L3809"></span>
<span class="line" id="L3810"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> GetSockNameError = <span class="tok-kw">error</span>{</span>
<span class="line" id="L3811">    <span class="tok-comment">/// Insufficient resources were available in the system to perform the operation.</span></span>
<span class="line" id="L3812">    SystemResources,</span>
<span class="line" id="L3813"></span>
<span class="line" id="L3814">    <span class="tok-comment">/// The network subsystem has failed.</span></span>
<span class="line" id="L3815">    NetworkSubsystemFailed,</span>
<span class="line" id="L3816"></span>
<span class="line" id="L3817">    <span class="tok-comment">/// Socket hasn't been bound yet</span></span>
<span class="line" id="L3818">    SocketNotBound,</span>
<span class="line" id="L3819"></span>
<span class="line" id="L3820">    FileDescriptorNotASocket,</span>
<span class="line" id="L3821">} || UnexpectedError;</span>
<span class="line" id="L3822"></span>
<span class="line" id="L3823"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">getsockname</span>(sock: socket_t, addr: *sockaddr, addrlen: *socklen_t) GetSockNameError!<span class="tok-type">void</span> {</span>
<span class="line" id="L3824">    <span class="tok-kw">if</span> (builtin.os.tag == .windows) {</span>
<span class="line" id="L3825">        <span class="tok-kw">const</span> rc = windows.getsockname(sock, addr, addrlen);</span>
<span class="line" id="L3826">        <span class="tok-kw">if</span> (rc == windows.ws2_32.SOCKET_ERROR) {</span>
<span class="line" id="L3827">            <span class="tok-kw">switch</span> (windows.ws2_32.WSAGetLastError()) {</span>
<span class="line" id="L3828">                .WSANOTINITIALISED =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L3829">                .WSAENETDOWN =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.NetworkSubsystemFailed,</span>
<span class="line" id="L3830">                .WSAEFAULT =&gt; <span class="tok-kw">unreachable</span>, <span class="tok-comment">// addr or addrlen have invalid pointers or addrlen points to an incorrect value</span>
</span>
<span class="line" id="L3831">                .WSAENOTSOCK =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.FileDescriptorNotASocket,</span>
<span class="line" id="L3832">                .WSAEINVAL =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.SocketNotBound,</span>
<span class="line" id="L3833">                <span class="tok-kw">else</span> =&gt; |err| <span class="tok-kw">return</span> windows.unexpectedWSAError(err),</span>
<span class="line" id="L3834">            }</span>
<span class="line" id="L3835">        }</span>
<span class="line" id="L3836">        <span class="tok-kw">return</span>;</span>
<span class="line" id="L3837">    } <span class="tok-kw">else</span> {</span>
<span class="line" id="L3838">        <span class="tok-kw">const</span> rc = system.getsockname(sock, addr, addrlen);</span>
<span class="line" id="L3839">        <span class="tok-kw">switch</span> (errno(rc)) {</span>
<span class="line" id="L3840">            .SUCCESS =&gt; <span class="tok-kw">return</span>,</span>
<span class="line" id="L3841">            <span class="tok-kw">else</span> =&gt; |err| <span class="tok-kw">return</span> unexpectedErrno(err),</span>
<span class="line" id="L3842"></span>
<span class="line" id="L3843">            .BADF =&gt; <span class="tok-kw">unreachable</span>, <span class="tok-comment">// always a race condition</span>
</span>
<span class="line" id="L3844">            .FAULT =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L3845">            .INVAL =&gt; <span class="tok-kw">unreachable</span>, <span class="tok-comment">// invalid parameters</span>
</span>
<span class="line" id="L3846">            .NOTSOCK =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.FileDescriptorNotASocket,</span>
<span class="line" id="L3847">            .NOBUFS =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.SystemResources,</span>
<span class="line" id="L3848">        }</span>
<span class="line" id="L3849">    }</span>
<span class="line" id="L3850">}</span>
<span class="line" id="L3851"></span>
<span class="line" id="L3852"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">getpeername</span>(sock: socket_t, addr: *sockaddr, addrlen: *socklen_t) GetSockNameError!<span class="tok-type">void</span> {</span>
<span class="line" id="L3853">    <span class="tok-kw">if</span> (builtin.os.tag == .windows) {</span>
<span class="line" id="L3854">        <span class="tok-kw">const</span> rc = windows.getpeername(sock, addr, addrlen);</span>
<span class="line" id="L3855">        <span class="tok-kw">if</span> (rc == windows.ws2_32.SOCKET_ERROR) {</span>
<span class="line" id="L3856">            <span class="tok-kw">switch</span> (windows.ws2_32.WSAGetLastError()) {</span>
<span class="line" id="L3857">                .WSANOTINITIALISED =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L3858">                .WSAENETDOWN =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.NetworkSubsystemFailed,</span>
<span class="line" id="L3859">                .WSAEFAULT =&gt; <span class="tok-kw">unreachable</span>, <span class="tok-comment">// addr or addrlen have invalid pointers or addrlen points to an incorrect value</span>
</span>
<span class="line" id="L3860">                .WSAENOTSOCK =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.FileDescriptorNotASocket,</span>
<span class="line" id="L3861">                .WSAEINVAL =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.SocketNotBound,</span>
<span class="line" id="L3862">                <span class="tok-kw">else</span> =&gt; |err| <span class="tok-kw">return</span> windows.unexpectedWSAError(err),</span>
<span class="line" id="L3863">            }</span>
<span class="line" id="L3864">        }</span>
<span class="line" id="L3865">        <span class="tok-kw">return</span>;</span>
<span class="line" id="L3866">    } <span class="tok-kw">else</span> {</span>
<span class="line" id="L3867">        <span class="tok-kw">const</span> rc = system.getpeername(sock, addr, addrlen);</span>
<span class="line" id="L3868">        <span class="tok-kw">switch</span> (errno(rc)) {</span>
<span class="line" id="L3869">            .SUCCESS =&gt; <span class="tok-kw">return</span>,</span>
<span class="line" id="L3870">            <span class="tok-kw">else</span> =&gt; |err| <span class="tok-kw">return</span> unexpectedErrno(err),</span>
<span class="line" id="L3871"></span>
<span class="line" id="L3872">            .BADF =&gt; <span class="tok-kw">unreachable</span>, <span class="tok-comment">// always a race condition</span>
</span>
<span class="line" id="L3873">            .FAULT =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L3874">            .INVAL =&gt; <span class="tok-kw">unreachable</span>, <span class="tok-comment">// invalid parameters</span>
</span>
<span class="line" id="L3875">            .NOTSOCK =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.FileDescriptorNotASocket,</span>
<span class="line" id="L3876">            .NOBUFS =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.SystemResources,</span>
<span class="line" id="L3877">        }</span>
<span class="line" id="L3878">    }</span>
<span class="line" id="L3879">}</span>
<span class="line" id="L3880"></span>
<span class="line" id="L3881"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> ConnectError = <span class="tok-kw">error</span>{</span>
<span class="line" id="L3882">    <span class="tok-comment">/// For UNIX domain sockets, which are identified by pathname: Write permission is denied on  the  socket</span></span>
<span class="line" id="L3883">    <span class="tok-comment">/// file,  or  search  permission  is  denied  for  one of the directories in the path prefix.</span></span>
<span class="line" id="L3884">    <span class="tok-comment">/// or</span></span>
<span class="line" id="L3885">    <span class="tok-comment">/// The user tried to connect to a broadcast address without having the socket broadcast flag enabled  or</span></span>
<span class="line" id="L3886">    <span class="tok-comment">/// the connection request failed because of a local firewall rule.</span></span>
<span class="line" id="L3887">    PermissionDenied,</span>
<span class="line" id="L3888"></span>
<span class="line" id="L3889">    <span class="tok-comment">/// Local address is already in use.</span></span>
<span class="line" id="L3890">    AddressInUse,</span>
<span class="line" id="L3891"></span>
<span class="line" id="L3892">    <span class="tok-comment">/// (Internet  domain  sockets)  The  socket  referred  to  by sockfd had not previously been bound to an</span></span>
<span class="line" id="L3893">    <span class="tok-comment">/// address and, upon attempting to bind it to an ephemeral port, it was determined that all port numbers</span></span>
<span class="line" id="L3894">    <span class="tok-comment">/// in    the    ephemeral    port    range    are   currently   in   use.    See   the   discussion   of</span></span>
<span class="line" id="L3895">    <span class="tok-comment">/// /proc/sys/net/ipv4/ip_local_port_range in ip(7).</span></span>
<span class="line" id="L3896">    AddressNotAvailable,</span>
<span class="line" id="L3897"></span>
<span class="line" id="L3898">    <span class="tok-comment">/// The passed address didn't have the correct address family in its sa_family field.</span></span>
<span class="line" id="L3899">    AddressFamilyNotSupported,</span>
<span class="line" id="L3900"></span>
<span class="line" id="L3901">    <span class="tok-comment">/// Insufficient entries in the routing cache.</span></span>
<span class="line" id="L3902">    SystemResources,</span>
<span class="line" id="L3903"></span>
<span class="line" id="L3904">    <span class="tok-comment">/// A connect() on a stream socket found no one listening on the remote address.</span></span>
<span class="line" id="L3905">    ConnectionRefused,</span>
<span class="line" id="L3906"></span>
<span class="line" id="L3907">    <span class="tok-comment">/// Network is unreachable.</span></span>
<span class="line" id="L3908">    NetworkUnreachable,</span>
<span class="line" id="L3909"></span>
<span class="line" id="L3910">    <span class="tok-comment">/// Timeout  while  attempting  connection.   The server may be too busy to accept new connections.  Note</span></span>
<span class="line" id="L3911">    <span class="tok-comment">/// that for IP sockets the timeout may be very long when syncookies are enabled on the server.</span></span>
<span class="line" id="L3912">    ConnectionTimedOut,</span>
<span class="line" id="L3913"></span>
<span class="line" id="L3914">    <span class="tok-comment">/// This error occurs when no global event loop is configured,</span></span>
<span class="line" id="L3915">    <span class="tok-comment">/// and connecting to the socket would block.</span></span>
<span class="line" id="L3916">    WouldBlock,</span>
<span class="line" id="L3917"></span>
<span class="line" id="L3918">    <span class="tok-comment">/// The given path for the unix socket does not exist.</span></span>
<span class="line" id="L3919">    FileNotFound,</span>
<span class="line" id="L3920"></span>
<span class="line" id="L3921">    <span class="tok-comment">/// Connection was reset by peer before connect could complete.</span></span>
<span class="line" id="L3922">    ConnectionResetByPeer,</span>
<span class="line" id="L3923"></span>
<span class="line" id="L3924">    <span class="tok-comment">/// Socket is non-blocking and already has a pending connection in progress.</span></span>
<span class="line" id="L3925">    ConnectionPending,</span>
<span class="line" id="L3926">} || UnexpectedError;</span>
<span class="line" id="L3927"></span>
<span class="line" id="L3928"><span class="tok-comment">/// Initiate a connection on a socket.</span></span>
<span class="line" id="L3929"><span class="tok-comment">/// If `sockfd` is opened in non blocking mode, the function will</span></span>
<span class="line" id="L3930"><span class="tok-comment">/// return error.WouldBlock when EAGAIN or EINPROGRESS is received.</span></span>
<span class="line" id="L3931"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">connect</span>(sock: socket_t, sock_addr: *<span class="tok-kw">const</span> sockaddr, len: socklen_t) ConnectError!<span class="tok-type">void</span> {</span>
<span class="line" id="L3932">    <span class="tok-kw">if</span> (builtin.os.tag == .windows) {</span>
<span class="line" id="L3933">        <span class="tok-kw">const</span> rc = windows.ws2_32.connect(sock, sock_addr, <span class="tok-builtin">@intCast</span>(<span class="tok-type">i32</span>, len));</span>
<span class="line" id="L3934">        <span class="tok-kw">if</span> (rc == <span class="tok-number">0</span>) <span class="tok-kw">return</span>;</span>
<span class="line" id="L3935">        <span class="tok-kw">switch</span> (windows.ws2_32.WSAGetLastError()) {</span>
<span class="line" id="L3936">            .WSAEADDRINUSE =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.AddressInUse,</span>
<span class="line" id="L3937">            .WSAEADDRNOTAVAIL =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.AddressNotAvailable,</span>
<span class="line" id="L3938">            .WSAECONNREFUSED =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.ConnectionRefused,</span>
<span class="line" id="L3939">            .WSAECONNRESET =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.ConnectionResetByPeer,</span>
<span class="line" id="L3940">            .WSAETIMEDOUT =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.ConnectionTimedOut,</span>
<span class="line" id="L3941">            .WSAEHOSTUNREACH, <span class="tok-comment">// TODO: should we return NetworkUnreachable in this case as well?</span>
</span>
<span class="line" id="L3942">            .WSAENETUNREACH,</span>
<span class="line" id="L3943">            =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.NetworkUnreachable,</span>
<span class="line" id="L3944">            .WSAEFAULT =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L3945">            .WSAEINVAL =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L3946">            .WSAEISCONN =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L3947">            .WSAENOTSOCK =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L3948">            .WSAEWOULDBLOCK =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L3949">            .WSAEACCES =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L3950">            .WSAENOBUFS =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.SystemResources,</span>
<span class="line" id="L3951">            .WSAEAFNOSUPPORT =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.AddressFamilyNotSupported,</span>
<span class="line" id="L3952">            <span class="tok-kw">else</span> =&gt; |err| <span class="tok-kw">return</span> windows.unexpectedWSAError(err),</span>
<span class="line" id="L3953">        }</span>
<span class="line" id="L3954">        <span class="tok-kw">return</span>;</span>
<span class="line" id="L3955">    }</span>
<span class="line" id="L3956"></span>
<span class="line" id="L3957">    <span class="tok-kw">while</span> (<span class="tok-null">true</span>) {</span>
<span class="line" id="L3958">        <span class="tok-kw">switch</span> (errno(system.connect(sock, sock_addr, len))) {</span>
<span class="line" id="L3959">            .SUCCESS =&gt; <span class="tok-kw">return</span>,</span>
<span class="line" id="L3960">            .ACCES =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.PermissionDenied,</span>
<span class="line" id="L3961">            .PERM =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.PermissionDenied,</span>
<span class="line" id="L3962">            .ADDRINUSE =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.AddressInUse,</span>
<span class="line" id="L3963">            .ADDRNOTAVAIL =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.AddressNotAvailable,</span>
<span class="line" id="L3964">            .AFNOSUPPORT =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.AddressFamilyNotSupported,</span>
<span class="line" id="L3965">            .AGAIN, .INPROGRESS =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.WouldBlock,</span>
<span class="line" id="L3966">            .ALREADY =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.ConnectionPending,</span>
<span class="line" id="L3967">            .BADF =&gt; <span class="tok-kw">unreachable</span>, <span class="tok-comment">// sockfd is not a valid open file descriptor.</span>
</span>
<span class="line" id="L3968">            .CONNREFUSED =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.ConnectionRefused,</span>
<span class="line" id="L3969">            .CONNRESET =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.ConnectionResetByPeer,</span>
<span class="line" id="L3970">            .FAULT =&gt; <span class="tok-kw">unreachable</span>, <span class="tok-comment">// The socket structure address is outside the user's address space.</span>
</span>
<span class="line" id="L3971">            .INTR =&gt; <span class="tok-kw">continue</span>,</span>
<span class="line" id="L3972">            .ISCONN =&gt; <span class="tok-kw">unreachable</span>, <span class="tok-comment">// The socket is already connected.</span>
</span>
<span class="line" id="L3973">            .HOSTUNREACH =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.NetworkUnreachable,</span>
<span class="line" id="L3974">            .NETUNREACH =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.NetworkUnreachable,</span>
<span class="line" id="L3975">            .NOTSOCK =&gt; <span class="tok-kw">unreachable</span>, <span class="tok-comment">// The file descriptor sockfd does not refer to a socket.</span>
</span>
<span class="line" id="L3976">            .PROTOTYPE =&gt; <span class="tok-kw">unreachable</span>, <span class="tok-comment">// The socket type does not support the requested communications protocol.</span>
</span>
<span class="line" id="L3977">            .TIMEDOUT =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.ConnectionTimedOut,</span>
<span class="line" id="L3978">            .NOENT =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.FileNotFound, <span class="tok-comment">// Returned when socket is AF.UNIX and the given path does not exist.</span>
</span>
<span class="line" id="L3979">            <span class="tok-kw">else</span> =&gt; |err| <span class="tok-kw">return</span> unexpectedErrno(err),</span>
<span class="line" id="L3980">        }</span>
<span class="line" id="L3981">    }</span>
<span class="line" id="L3982">}</span>
<span class="line" id="L3983"></span>
<span class="line" id="L3984"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">getsockoptError</span>(sockfd: fd_t) ConnectError!<span class="tok-type">void</span> {</span>
<span class="line" id="L3985">    <span class="tok-kw">var</span> err_code: <span class="tok-type">i32</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L3986">    <span class="tok-kw">var</span> size: <span class="tok-type">u32</span> = <span class="tok-builtin">@sizeOf</span>(<span class="tok-type">u32</span>);</span>
<span class="line" id="L3987">    <span class="tok-kw">const</span> rc = system.getsockopt(sockfd, SOL.SOCKET, SO.ERROR, <span class="tok-builtin">@ptrCast</span>([*]<span class="tok-type">u8</span>, &amp;err_code), &amp;size);</span>
<span class="line" id="L3988">    assert(size == <span class="tok-number">4</span>);</span>
<span class="line" id="L3989">    <span class="tok-kw">switch</span> (errno(rc)) {</span>
<span class="line" id="L3990">        .SUCCESS =&gt; <span class="tok-kw">switch</span> (<span class="tok-builtin">@intToEnum</span>(E, err_code)) {</span>
<span class="line" id="L3991">            .SUCCESS =&gt; <span class="tok-kw">return</span>,</span>
<span class="line" id="L3992">            .ACCES =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.PermissionDenied,</span>
<span class="line" id="L3993">            .PERM =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.PermissionDenied,</span>
<span class="line" id="L3994">            .ADDRINUSE =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.AddressInUse,</span>
<span class="line" id="L3995">            .ADDRNOTAVAIL =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.AddressNotAvailable,</span>
<span class="line" id="L3996">            .AFNOSUPPORT =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.AddressFamilyNotSupported,</span>
<span class="line" id="L3997">            .AGAIN =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.SystemResources,</span>
<span class="line" id="L3998">            .ALREADY =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.ConnectionPending,</span>
<span class="line" id="L3999">            .BADF =&gt; <span class="tok-kw">unreachable</span>, <span class="tok-comment">// sockfd is not a valid open file descriptor.</span>
</span>
<span class="line" id="L4000">            .CONNREFUSED =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.ConnectionRefused,</span>
<span class="line" id="L4001">            .FAULT =&gt; <span class="tok-kw">unreachable</span>, <span class="tok-comment">// The socket structure address is outside the user's address space.</span>
</span>
<span class="line" id="L4002">            .ISCONN =&gt; <span class="tok-kw">unreachable</span>, <span class="tok-comment">// The socket is already connected.</span>
</span>
<span class="line" id="L4003">            .HOSTUNREACH =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.NetworkUnreachable,</span>
<span class="line" id="L4004">            .NETUNREACH =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.NetworkUnreachable,</span>
<span class="line" id="L4005">            .NOTSOCK =&gt; <span class="tok-kw">unreachable</span>, <span class="tok-comment">// The file descriptor sockfd does not refer to a socket.</span>
</span>
<span class="line" id="L4006">            .PROTOTYPE =&gt; <span class="tok-kw">unreachable</span>, <span class="tok-comment">// The socket type does not support the requested communications protocol.</span>
</span>
<span class="line" id="L4007">            .TIMEDOUT =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.ConnectionTimedOut,</span>
<span class="line" id="L4008">            .CONNRESET =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.ConnectionResetByPeer,</span>
<span class="line" id="L4009">            <span class="tok-kw">else</span> =&gt; |err| <span class="tok-kw">return</span> unexpectedErrno(err),</span>
<span class="line" id="L4010">        },</span>
<span class="line" id="L4011">        .BADF =&gt; <span class="tok-kw">unreachable</span>, <span class="tok-comment">// The argument sockfd is not a valid file descriptor.</span>
</span>
<span class="line" id="L4012">        .FAULT =&gt; <span class="tok-kw">unreachable</span>, <span class="tok-comment">// The address pointed to by optval or optlen is not in a valid part of the process address space.</span>
</span>
<span class="line" id="L4013">        .INVAL =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L4014">        .NOPROTOOPT =&gt; <span class="tok-kw">unreachable</span>, <span class="tok-comment">// The option is unknown at the level indicated.</span>
</span>
<span class="line" id="L4015">        .NOTSOCK =&gt; <span class="tok-kw">unreachable</span>, <span class="tok-comment">// The file descriptor sockfd does not refer to a socket.</span>
</span>
<span class="line" id="L4016">        <span class="tok-kw">else</span> =&gt; |err| <span class="tok-kw">return</span> unexpectedErrno(err),</span>
<span class="line" id="L4017">    }</span>
<span class="line" id="L4018">}</span>
<span class="line" id="L4019"></span>
<span class="line" id="L4020"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> WaitPidResult = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L4021">    pid: pid_t,</span>
<span class="line" id="L4022">    status: <span class="tok-type">u32</span>,</span>
<span class="line" id="L4023">};</span>
<span class="line" id="L4024"></span>
<span class="line" id="L4025"><span class="tok-comment">/// Use this version of the `waitpid` wrapper if you spawned your child process using explicit</span></span>
<span class="line" id="L4026"><span class="tok-comment">/// `fork` and `execve` method. If you spawned your child process using `posix_spawn` method,</span></span>
<span class="line" id="L4027"><span class="tok-comment">/// use `std.os.posix_spawn.waitpid` instead.</span></span>
<span class="line" id="L4028"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">waitpid</span>(pid: pid_t, flags: <span class="tok-type">u32</span>) WaitPidResult {</span>
<span class="line" id="L4029">    <span class="tok-kw">const</span> Status = <span class="tok-kw">if</span> (builtin.link_libc) <span class="tok-type">c_int</span> <span class="tok-kw">else</span> <span class="tok-type">u32</span>;</span>
<span class="line" id="L4030">    <span class="tok-kw">var</span> status: Status = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L4031">    <span class="tok-kw">while</span> (<span class="tok-null">true</span>) {</span>
<span class="line" id="L4032">        <span class="tok-kw">const</span> rc = system.waitpid(pid, &amp;status, <span class="tok-kw">if</span> (builtin.link_libc) <span class="tok-builtin">@intCast</span>(<span class="tok-type">c_int</span>, flags) <span class="tok-kw">else</span> flags);</span>
<span class="line" id="L4033">        <span class="tok-kw">switch</span> (errno(rc)) {</span>
<span class="line" id="L4034">            .SUCCESS =&gt; <span class="tok-kw">return</span> .{</span>
<span class="line" id="L4035">                .pid = <span class="tok-builtin">@intCast</span>(pid_t, rc),</span>
<span class="line" id="L4036">                .status = <span class="tok-builtin">@bitCast</span>(<span class="tok-type">u32</span>, status),</span>
<span class="line" id="L4037">            },</span>
<span class="line" id="L4038">            .INTR =&gt; <span class="tok-kw">continue</span>,</span>
<span class="line" id="L4039">            .CHILD =&gt; <span class="tok-kw">unreachable</span>, <span class="tok-comment">// The process specified does not exist. It would be a race condition to handle this error.</span>
</span>
<span class="line" id="L4040">            .INVAL =&gt; <span class="tok-kw">unreachable</span>, <span class="tok-comment">// Invalid flags.</span>
</span>
<span class="line" id="L4041">            <span class="tok-kw">else</span> =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L4042">        }</span>
<span class="line" id="L4043">    }</span>
<span class="line" id="L4044">}</span>
<span class="line" id="L4045"></span>
<span class="line" id="L4046"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> FStatError = <span class="tok-kw">error</span>{</span>
<span class="line" id="L4047">    SystemResources,</span>
<span class="line" id="L4048"></span>
<span class="line" id="L4049">    <span class="tok-comment">/// In WASI, this error may occur when the file descriptor does</span></span>
<span class="line" id="L4050">    <span class="tok-comment">/// not hold the required rights to get its filestat information.</span></span>
<span class="line" id="L4051">    AccessDenied,</span>
<span class="line" id="L4052">} || UnexpectedError;</span>
<span class="line" id="L4053"></span>
<span class="line" id="L4054"><span class="tok-comment">/// Return information about a file descriptor.</span></span>
<span class="line" id="L4055"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">fstat</span>(fd: fd_t) FStatError!Stat {</span>
<span class="line" id="L4056">    <span class="tok-kw">if</span> (builtin.os.tag == .wasi <span class="tok-kw">and</span> !builtin.link_libc) {</span>
<span class="line" id="L4057">        <span class="tok-kw">var</span> stat: wasi.filestat_t = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L4058">        <span class="tok-kw">switch</span> (wasi.fd_filestat_get(fd, &amp;stat)) {</span>
<span class="line" id="L4059">            .SUCCESS =&gt; <span class="tok-kw">return</span> Stat.fromFilestat(stat),</span>
<span class="line" id="L4060">            .INVAL =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L4061">            .BADF =&gt; <span class="tok-kw">unreachable</span>, <span class="tok-comment">// Always a race condition.</span>
</span>
<span class="line" id="L4062">            .NOMEM =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.SystemResources,</span>
<span class="line" id="L4063">            .ACCES =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.AccessDenied,</span>
<span class="line" id="L4064">            .NOTCAPABLE =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.AccessDenied,</span>
<span class="line" id="L4065">            <span class="tok-kw">else</span> =&gt; |err| <span class="tok-kw">return</span> unexpectedErrno(err),</span>
<span class="line" id="L4066">        }</span>
<span class="line" id="L4067">    }</span>
<span class="line" id="L4068">    <span class="tok-kw">if</span> (builtin.os.tag == .windows) {</span>
<span class="line" id="L4069">        <span class="tok-builtin">@compileError</span>(<span class="tok-str">&quot;fstat is not yet implemented on Windows&quot;</span>);</span>
<span class="line" id="L4070">    }</span>
<span class="line" id="L4071"></span>
<span class="line" id="L4072">    <span class="tok-kw">const</span> fstat_sym = <span class="tok-kw">if</span> (builtin.os.tag == .linux <span class="tok-kw">and</span> builtin.link_libc)</span>
<span class="line" id="L4073">        system.fstat64</span>
<span class="line" id="L4074">    <span class="tok-kw">else</span></span>
<span class="line" id="L4075">        system.fstat;</span>
<span class="line" id="L4076"></span>
<span class="line" id="L4077">    <span class="tok-kw">var</span> stat = mem.zeroes(Stat);</span>
<span class="line" id="L4078">    <span class="tok-kw">switch</span> (errno(fstat_sym(fd, &amp;stat))) {</span>
<span class="line" id="L4079">        .SUCCESS =&gt; <span class="tok-kw">return</span> stat,</span>
<span class="line" id="L4080">        .INVAL =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L4081">        .BADF =&gt; <span class="tok-kw">unreachable</span>, <span class="tok-comment">// Always a race condition.</span>
</span>
<span class="line" id="L4082">        .NOMEM =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.SystemResources,</span>
<span class="line" id="L4083">        .ACCES =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.AccessDenied,</span>
<span class="line" id="L4084">        <span class="tok-kw">else</span> =&gt; |err| <span class="tok-kw">return</span> unexpectedErrno(err),</span>
<span class="line" id="L4085">    }</span>
<span class="line" id="L4086">}</span>
<span class="line" id="L4087"></span>
<span class="line" id="L4088"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> FStatAtError = FStatError || <span class="tok-kw">error</span>{ NameTooLong, FileNotFound, SymLinkLoop };</span>
<span class="line" id="L4089"></span>
<span class="line" id="L4090"><span class="tok-comment">/// Similar to `fstat`, but returns stat of a resource pointed to by `pathname`</span></span>
<span class="line" id="L4091"><span class="tok-comment">/// which is relative to `dirfd` handle.</span></span>
<span class="line" id="L4092"><span class="tok-comment">/// See also `fstatatZ` and `fstatatWasi`.</span></span>
<span class="line" id="L4093"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">fstatat</span>(dirfd: fd_t, pathname: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>, flags: <span class="tok-type">u32</span>) FStatAtError!Stat {</span>
<span class="line" id="L4094">    <span class="tok-kw">if</span> (builtin.os.tag == .wasi <span class="tok-kw">and</span> !builtin.link_libc) {</span>
<span class="line" id="L4095">        <span class="tok-kw">const</span> wasi_flags = <span class="tok-kw">if</span> (flags &amp; linux.AT.SYMLINK_NOFOLLOW == <span class="tok-number">0</span>) wasi.LOOKUP_SYMLINK_FOLLOW <span class="tok-kw">else</span> <span class="tok-number">0</span>;</span>
<span class="line" id="L4096">        <span class="tok-kw">if</span> (dirfd == wasi.AT.FDCWD <span class="tok-kw">or</span> fs.path.isAbsolute(pathname)) {</span>
<span class="line" id="L4097">            <span class="tok-comment">// Resolve absolute or CWD-relative paths to a path within a Preopen</span>
</span>
<span class="line" id="L4098">            <span class="tok-kw">var</span> path_buf: [MAX_PATH_BYTES]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L4099">            <span class="tok-kw">const</span> path = <span class="tok-kw">try</span> resolvePathWasi(pathname, &amp;path_buf);</span>
<span class="line" id="L4100">            <span class="tok-kw">return</span> fstatatWasi(path.dir_fd, path.relative_path, wasi_flags);</span>
<span class="line" id="L4101">        }</span>
<span class="line" id="L4102">        <span class="tok-kw">return</span> fstatatWasi(dirfd, pathname, wasi_flags);</span>
<span class="line" id="L4103">    } <span class="tok-kw">else</span> <span class="tok-kw">if</span> (builtin.os.tag == .windows) {</span>
<span class="line" id="L4104">        <span class="tok-builtin">@compileError</span>(<span class="tok-str">&quot;fstatat is not yet implemented on Windows&quot;</span>);</span>
<span class="line" id="L4105">    } <span class="tok-kw">else</span> {</span>
<span class="line" id="L4106">        <span class="tok-kw">const</span> pathname_c = <span class="tok-kw">try</span> toPosixPath(pathname);</span>
<span class="line" id="L4107">        <span class="tok-kw">return</span> fstatatZ(dirfd, &amp;pathname_c, flags);</span>
<span class="line" id="L4108">    }</span>
<span class="line" id="L4109">}</span>
<span class="line" id="L4110"></span>
<span class="line" id="L4111"><span class="tok-comment">/// WASI-only. Same as `fstatat` but targeting WASI.</span></span>
<span class="line" id="L4112"><span class="tok-comment">/// See also `fstatat`.</span></span>
<span class="line" id="L4113"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">fstatatWasi</span>(dirfd: fd_t, pathname: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>, flags: <span class="tok-type">u32</span>) FStatAtError!Stat {</span>
<span class="line" id="L4114">    <span class="tok-kw">var</span> stat: wasi.filestat_t = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L4115">    <span class="tok-kw">switch</span> (wasi.path_filestat_get(dirfd, flags, pathname.ptr, pathname.len, &amp;stat)) {</span>
<span class="line" id="L4116">        .SUCCESS =&gt; <span class="tok-kw">return</span> Stat.fromFilestat(stat),</span>
<span class="line" id="L4117">        .INVAL =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L4118">        .BADF =&gt; <span class="tok-kw">unreachable</span>, <span class="tok-comment">// Always a race condition.</span>
</span>
<span class="line" id="L4119">        .NOMEM =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.SystemResources,</span>
<span class="line" id="L4120">        .ACCES =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.AccessDenied,</span>
<span class="line" id="L4121">        .FAULT =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L4122">        .NAMETOOLONG =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.NameTooLong,</span>
<span class="line" id="L4123">        .NOENT =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.FileNotFound,</span>
<span class="line" id="L4124">        .NOTDIR =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.FileNotFound,</span>
<span class="line" id="L4125">        .NOTCAPABLE =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.AccessDenied,</span>
<span class="line" id="L4126">        <span class="tok-kw">else</span> =&gt; |err| <span class="tok-kw">return</span> unexpectedErrno(err),</span>
<span class="line" id="L4127">    }</span>
<span class="line" id="L4128">}</span>
<span class="line" id="L4129"></span>
<span class="line" id="L4130"><span class="tok-comment">/// Same as `fstatat` but `pathname` is null-terminated.</span></span>
<span class="line" id="L4131"><span class="tok-comment">/// See also `fstatat`.</span></span>
<span class="line" id="L4132"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">fstatatZ</span>(dirfd: fd_t, pathname: [*:<span class="tok-number">0</span>]<span class="tok-kw">const</span> <span class="tok-type">u8</span>, flags: <span class="tok-type">u32</span>) FStatAtError!Stat {</span>
<span class="line" id="L4133">    <span class="tok-kw">if</span> (builtin.os.tag == .wasi <span class="tok-kw">and</span> !builtin.link_libc) {</span>
<span class="line" id="L4134">        <span class="tok-kw">return</span> fstatatWasi(dirfd, mem.sliceTo(pathname), flags);</span>
<span class="line" id="L4135">    }</span>
<span class="line" id="L4136"></span>
<span class="line" id="L4137">    <span class="tok-kw">const</span> fstatat_sym = <span class="tok-kw">if</span> (builtin.os.tag == .linux <span class="tok-kw">and</span> builtin.link_libc)</span>
<span class="line" id="L4138">        system.fstatat64</span>
<span class="line" id="L4139">    <span class="tok-kw">else</span></span>
<span class="line" id="L4140">        system.fstatat;</span>
<span class="line" id="L4141"></span>
<span class="line" id="L4142">    <span class="tok-kw">var</span> stat = mem.zeroes(Stat);</span>
<span class="line" id="L4143">    <span class="tok-kw">switch</span> (errno(fstatat_sym(dirfd, pathname, &amp;stat, flags))) {</span>
<span class="line" id="L4144">        .SUCCESS =&gt; <span class="tok-kw">return</span> stat,</span>
<span class="line" id="L4145">        .INVAL =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L4146">        .BADF =&gt; <span class="tok-kw">unreachable</span>, <span class="tok-comment">// Always a race condition.</span>
</span>
<span class="line" id="L4147">        .NOMEM =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.SystemResources,</span>
<span class="line" id="L4148">        .ACCES =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.AccessDenied,</span>
<span class="line" id="L4149">        .PERM =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.AccessDenied,</span>
<span class="line" id="L4150">        .FAULT =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L4151">        .NAMETOOLONG =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.NameTooLong,</span>
<span class="line" id="L4152">        .LOOP =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.SymLinkLoop,</span>
<span class="line" id="L4153">        .NOENT =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.FileNotFound,</span>
<span class="line" id="L4154">        .NOTDIR =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.FileNotFound,</span>
<span class="line" id="L4155">        <span class="tok-kw">else</span> =&gt; |err| <span class="tok-kw">return</span> unexpectedErrno(err),</span>
<span class="line" id="L4156">    }</span>
<span class="line" id="L4157">}</span>
<span class="line" id="L4158"></span>
<span class="line" id="L4159"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> KQueueError = <span class="tok-kw">error</span>{</span>
<span class="line" id="L4160">    <span class="tok-comment">/// The per-process limit on the number of open file descriptors has been reached.</span></span>
<span class="line" id="L4161">    ProcessFdQuotaExceeded,</span>
<span class="line" id="L4162"></span>
<span class="line" id="L4163">    <span class="tok-comment">/// The system-wide limit on the total number of open files has been reached.</span></span>
<span class="line" id="L4164">    SystemFdQuotaExceeded,</span>
<span class="line" id="L4165">} || UnexpectedError;</span>
<span class="line" id="L4166"></span>
<span class="line" id="L4167"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">kqueue</span>() KQueueError!<span class="tok-type">i32</span> {</span>
<span class="line" id="L4168">    <span class="tok-kw">const</span> rc = system.kqueue();</span>
<span class="line" id="L4169">    <span class="tok-kw">switch</span> (errno(rc)) {</span>
<span class="line" id="L4170">        .SUCCESS =&gt; <span class="tok-kw">return</span> <span class="tok-builtin">@intCast</span>(<span class="tok-type">i32</span>, rc),</span>
<span class="line" id="L4171">        .MFILE =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.ProcessFdQuotaExceeded,</span>
<span class="line" id="L4172">        .NFILE =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.SystemFdQuotaExceeded,</span>
<span class="line" id="L4173">        <span class="tok-kw">else</span> =&gt; |err| <span class="tok-kw">return</span> unexpectedErrno(err),</span>
<span class="line" id="L4174">    }</span>
<span class="line" id="L4175">}</span>
<span class="line" id="L4176"></span>
<span class="line" id="L4177"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> KEventError = <span class="tok-kw">error</span>{</span>
<span class="line" id="L4178">    <span class="tok-comment">/// The process does not have permission to register a filter.</span></span>
<span class="line" id="L4179">    AccessDenied,</span>
<span class="line" id="L4180"></span>
<span class="line" id="L4181">    <span class="tok-comment">/// The event could not be found to be modified or deleted.</span></span>
<span class="line" id="L4182">    EventNotFound,</span>
<span class="line" id="L4183"></span>
<span class="line" id="L4184">    <span class="tok-comment">/// No memory was available to register the event.</span></span>
<span class="line" id="L4185">    SystemResources,</span>
<span class="line" id="L4186"></span>
<span class="line" id="L4187">    <span class="tok-comment">/// The specified process to attach to does not exist.</span></span>
<span class="line" id="L4188">    ProcessNotFound,</span>
<span class="line" id="L4189"></span>
<span class="line" id="L4190">    <span class="tok-comment">/// changelist or eventlist had too many items on it.</span></span>
<span class="line" id="L4191">    <span class="tok-comment">/// TODO remove this possibility</span></span>
<span class="line" id="L4192">    Overflow,</span>
<span class="line" id="L4193">};</span>
<span class="line" id="L4194"></span>
<span class="line" id="L4195"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">kevent</span>(</span>
<span class="line" id="L4196">    kq: <span class="tok-type">i32</span>,</span>
<span class="line" id="L4197">    changelist: []<span class="tok-kw">const</span> Kevent,</span>
<span class="line" id="L4198">    eventlist: []Kevent,</span>
<span class="line" id="L4199">    timeout: ?*<span class="tok-kw">const</span> timespec,</span>
<span class="line" id="L4200">) KEventError!<span class="tok-type">usize</span> {</span>
<span class="line" id="L4201">    <span class="tok-kw">while</span> (<span class="tok-null">true</span>) {</span>
<span class="line" id="L4202">        <span class="tok-kw">const</span> rc = system.kevent(</span>
<span class="line" id="L4203">            kq,</span>
<span class="line" id="L4204">            changelist.ptr,</span>
<span class="line" id="L4205">            math.cast(<span class="tok-type">c_int</span>, changelist.len) <span class="tok-kw">orelse</span> <span class="tok-kw">return</span> <span class="tok-kw">error</span>.Overflow,</span>
<span class="line" id="L4206">            eventlist.ptr,</span>
<span class="line" id="L4207">            math.cast(<span class="tok-type">c_int</span>, eventlist.len) <span class="tok-kw">orelse</span> <span class="tok-kw">return</span> <span class="tok-kw">error</span>.Overflow,</span>
<span class="line" id="L4208">            timeout,</span>
<span class="line" id="L4209">        );</span>
<span class="line" id="L4210">        <span class="tok-kw">switch</span> (errno(rc)) {</span>
<span class="line" id="L4211">            .SUCCESS =&gt; <span class="tok-kw">return</span> <span class="tok-builtin">@intCast</span>(<span class="tok-type">usize</span>, rc),</span>
<span class="line" id="L4212">            .ACCES =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.AccessDenied,</span>
<span class="line" id="L4213">            .FAULT =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L4214">            .BADF =&gt; <span class="tok-kw">unreachable</span>, <span class="tok-comment">// Always a race condition.</span>
</span>
<span class="line" id="L4215">            .INTR =&gt; <span class="tok-kw">continue</span>,</span>
<span class="line" id="L4216">            .INVAL =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L4217">            .NOENT =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.EventNotFound,</span>
<span class="line" id="L4218">            .NOMEM =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.SystemResources,</span>
<span class="line" id="L4219">            .SRCH =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.ProcessNotFound,</span>
<span class="line" id="L4220">            <span class="tok-kw">else</span> =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L4221">        }</span>
<span class="line" id="L4222">    }</span>
<span class="line" id="L4223">}</span>
<span class="line" id="L4224"></span>
<span class="line" id="L4225"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> INotifyInitError = <span class="tok-kw">error</span>{</span>
<span class="line" id="L4226">    ProcessFdQuotaExceeded,</span>
<span class="line" id="L4227">    SystemFdQuotaExceeded,</span>
<span class="line" id="L4228">    SystemResources,</span>
<span class="line" id="L4229">} || UnexpectedError;</span>
<span class="line" id="L4230"></span>
<span class="line" id="L4231"><span class="tok-comment">/// initialize an inotify instance</span></span>
<span class="line" id="L4232"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">inotify_init1</span>(flags: <span class="tok-type">u32</span>) INotifyInitError!<span class="tok-type">i32</span> {</span>
<span class="line" id="L4233">    <span class="tok-kw">const</span> rc = system.inotify_init1(flags);</span>
<span class="line" id="L4234">    <span class="tok-kw">switch</span> (errno(rc)) {</span>
<span class="line" id="L4235">        .SUCCESS =&gt; <span class="tok-kw">return</span> <span class="tok-builtin">@intCast</span>(<span class="tok-type">i32</span>, rc),</span>
<span class="line" id="L4236">        .INVAL =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L4237">        .MFILE =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.ProcessFdQuotaExceeded,</span>
<span class="line" id="L4238">        .NFILE =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.SystemFdQuotaExceeded,</span>
<span class="line" id="L4239">        .NOMEM =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.SystemResources,</span>
<span class="line" id="L4240">        <span class="tok-kw">else</span> =&gt; |err| <span class="tok-kw">return</span> unexpectedErrno(err),</span>
<span class="line" id="L4241">    }</span>
<span class="line" id="L4242">}</span>
<span class="line" id="L4243"></span>
<span class="line" id="L4244"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> INotifyAddWatchError = <span class="tok-kw">error</span>{</span>
<span class="line" id="L4245">    AccessDenied,</span>
<span class="line" id="L4246">    NameTooLong,</span>
<span class="line" id="L4247">    FileNotFound,</span>
<span class="line" id="L4248">    SystemResources,</span>
<span class="line" id="L4249">    UserResourceLimitReached,</span>
<span class="line" id="L4250">    NotDir,</span>
<span class="line" id="L4251">    WatchAlreadyExists,</span>
<span class="line" id="L4252">} || UnexpectedError;</span>
<span class="line" id="L4253"></span>
<span class="line" id="L4254"><span class="tok-comment">/// add a watch to an initialized inotify instance</span></span>
<span class="line" id="L4255"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">inotify_add_watch</span>(inotify_fd: <span class="tok-type">i32</span>, pathname: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>, mask: <span class="tok-type">u32</span>) INotifyAddWatchError!<span class="tok-type">i32</span> {</span>
<span class="line" id="L4256">    <span class="tok-kw">const</span> pathname_c = <span class="tok-kw">try</span> toPosixPath(pathname);</span>
<span class="line" id="L4257">    <span class="tok-kw">return</span> inotify_add_watchZ(inotify_fd, &amp;pathname_c, mask);</span>
<span class="line" id="L4258">}</span>
<span class="line" id="L4259"></span>
<span class="line" id="L4260"><span class="tok-comment">/// Same as `inotify_add_watch` except pathname is null-terminated.</span></span>
<span class="line" id="L4261"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">inotify_add_watchZ</span>(inotify_fd: <span class="tok-type">i32</span>, pathname: [*:<span class="tok-number">0</span>]<span class="tok-kw">const</span> <span class="tok-type">u8</span>, mask: <span class="tok-type">u32</span>) INotifyAddWatchError!<span class="tok-type">i32</span> {</span>
<span class="line" id="L4262">    <span class="tok-kw">const</span> rc = system.inotify_add_watch(inotify_fd, pathname, mask);</span>
<span class="line" id="L4263">    <span class="tok-kw">switch</span> (errno(rc)) {</span>
<span class="line" id="L4264">        .SUCCESS =&gt; <span class="tok-kw">return</span> <span class="tok-builtin">@intCast</span>(<span class="tok-type">i32</span>, rc),</span>
<span class="line" id="L4265">        .ACCES =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.AccessDenied,</span>
<span class="line" id="L4266">        .BADF =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L4267">        .FAULT =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L4268">        .INVAL =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L4269">        .NAMETOOLONG =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.NameTooLong,</span>
<span class="line" id="L4270">        .NOENT =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.FileNotFound,</span>
<span class="line" id="L4271">        .NOMEM =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.SystemResources,</span>
<span class="line" id="L4272">        .NOSPC =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.UserResourceLimitReached,</span>
<span class="line" id="L4273">        .NOTDIR =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.NotDir,</span>
<span class="line" id="L4274">        .EXIST =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.WatchAlreadyExists,</span>
<span class="line" id="L4275">        <span class="tok-kw">else</span> =&gt; |err| <span class="tok-kw">return</span> unexpectedErrno(err),</span>
<span class="line" id="L4276">    }</span>
<span class="line" id="L4277">}</span>
<span class="line" id="L4278"></span>
<span class="line" id="L4279"><span class="tok-comment">/// remove an existing watch from an inotify instance</span></span>
<span class="line" id="L4280"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">inotify_rm_watch</span>(inotify_fd: <span class="tok-type">i32</span>, wd: <span class="tok-type">i32</span>) <span class="tok-type">void</span> {</span>
<span class="line" id="L4281">    <span class="tok-kw">switch</span> (errno(system.inotify_rm_watch(inotify_fd, wd))) {</span>
<span class="line" id="L4282">        .SUCCESS =&gt; <span class="tok-kw">return</span>,</span>
<span class="line" id="L4283">        .BADF =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L4284">        .INVAL =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L4285">        <span class="tok-kw">else</span> =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L4286">    }</span>
<span class="line" id="L4287">}</span>
<span class="line" id="L4288"></span>
<span class="line" id="L4289"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> MProtectError = <span class="tok-kw">error</span>{</span>
<span class="line" id="L4290">    <span class="tok-comment">/// The memory cannot be given the specified access.  This can happen, for example, if you</span></span>
<span class="line" id="L4291">    <span class="tok-comment">/// mmap(2)  a  file  to  which  you have read-only access, then ask mprotect() to mark it</span></span>
<span class="line" id="L4292">    <span class="tok-comment">/// PROT_WRITE.</span></span>
<span class="line" id="L4293">    AccessDenied,</span>
<span class="line" id="L4294"></span>
<span class="line" id="L4295">    <span class="tok-comment">/// Changing  the  protection  of a memory region would result in the total number of map‐</span></span>
<span class="line" id="L4296">    <span class="tok-comment">/// pings with distinct attributes (e.g., read versus read/write protection) exceeding the</span></span>
<span class="line" id="L4297">    <span class="tok-comment">/// allowed maximum.  (For example, making the protection of a range PROT_READ in the mid‐</span></span>
<span class="line" id="L4298">    <span class="tok-comment">/// dle of a region currently protected as PROT_READ|PROT_WRITE would result in three map‐</span></span>
<span class="line" id="L4299">    <span class="tok-comment">/// pings: two read/write mappings at each end and a read-only mapping in the middle.)</span></span>
<span class="line" id="L4300">    OutOfMemory,</span>
<span class="line" id="L4301">} || UnexpectedError;</span>
<span class="line" id="L4302"></span>
<span class="line" id="L4303"><span class="tok-comment">/// `memory.len` must be page-aligned.</span></span>
<span class="line" id="L4304"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">mprotect</span>(memory: []<span class="tok-kw">align</span>(mem.page_size) <span class="tok-type">u8</span>, protection: <span class="tok-type">u32</span>) MProtectError!<span class="tok-type">void</span> {</span>
<span class="line" id="L4305">    assert(mem.isAligned(memory.len, mem.page_size));</span>
<span class="line" id="L4306">    <span class="tok-kw">switch</span> (errno(system.mprotect(memory.ptr, memory.len, protection))) {</span>
<span class="line" id="L4307">        .SUCCESS =&gt; <span class="tok-kw">return</span>,</span>
<span class="line" id="L4308">        .INVAL =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L4309">        .ACCES =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.AccessDenied,</span>
<span class="line" id="L4310">        .NOMEM =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.OutOfMemory,</span>
<span class="line" id="L4311">        <span class="tok-kw">else</span> =&gt; |err| <span class="tok-kw">return</span> unexpectedErrno(err),</span>
<span class="line" id="L4312">    }</span>
<span class="line" id="L4313">}</span>
<span class="line" id="L4314"></span>
<span class="line" id="L4315"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> ForkError = <span class="tok-kw">error</span>{SystemResources} || UnexpectedError;</span>
<span class="line" id="L4316"></span>
<span class="line" id="L4317"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">fork</span>() ForkError!pid_t {</span>
<span class="line" id="L4318">    <span class="tok-kw">const</span> rc = system.fork();</span>
<span class="line" id="L4319">    <span class="tok-kw">switch</span> (errno(rc)) {</span>
<span class="line" id="L4320">        .SUCCESS =&gt; <span class="tok-kw">return</span> <span class="tok-builtin">@intCast</span>(pid_t, rc),</span>
<span class="line" id="L4321">        .AGAIN =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.SystemResources,</span>
<span class="line" id="L4322">        .NOMEM =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.SystemResources,</span>
<span class="line" id="L4323">        <span class="tok-kw">else</span> =&gt; |err| <span class="tok-kw">return</span> unexpectedErrno(err),</span>
<span class="line" id="L4324">    }</span>
<span class="line" id="L4325">}</span>
<span class="line" id="L4326"></span>
<span class="line" id="L4327"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> MMapError = <span class="tok-kw">error</span>{</span>
<span class="line" id="L4328">    <span class="tok-comment">/// The underlying filesystem of the specified file does not support memory mapping.</span></span>
<span class="line" id="L4329">    MemoryMappingNotSupported,</span>
<span class="line" id="L4330"></span>
<span class="line" id="L4331">    <span class="tok-comment">/// A file descriptor refers to a non-regular file. Or a file mapping was requested,</span></span>
<span class="line" id="L4332">    <span class="tok-comment">/// but the file descriptor is not open for reading. Or `MAP.SHARED` was requested</span></span>
<span class="line" id="L4333">    <span class="tok-comment">/// and `PROT_WRITE` is set, but the file descriptor is not open in `O.RDWR` mode.</span></span>
<span class="line" id="L4334">    <span class="tok-comment">/// Or `PROT_WRITE` is set, but the file is append-only.</span></span>
<span class="line" id="L4335">    AccessDenied,</span>
<span class="line" id="L4336"></span>
<span class="line" id="L4337">    <span class="tok-comment">/// The `prot` argument asks for `PROT_EXEC` but the mapped area belongs to a file on</span></span>
<span class="line" id="L4338">    <span class="tok-comment">/// a filesystem that was mounted no-exec.</span></span>
<span class="line" id="L4339">    PermissionDenied,</span>
<span class="line" id="L4340">    LockedMemoryLimitExceeded,</span>
<span class="line" id="L4341">    OutOfMemory,</span>
<span class="line" id="L4342">} || UnexpectedError;</span>
<span class="line" id="L4343"></span>
<span class="line" id="L4344"><span class="tok-comment">/// Map files or devices into memory.</span></span>
<span class="line" id="L4345"><span class="tok-comment">/// `length` does not need to be aligned.</span></span>
<span class="line" id="L4346"><span class="tok-comment">/// Use of a mapped region can result in these signals:</span></span>
<span class="line" id="L4347"><span class="tok-comment">/// * SIGSEGV - Attempted write into a region mapped as read-only.</span></span>
<span class="line" id="L4348"><span class="tok-comment">/// * SIGBUS - Attempted  access to a portion of the buffer that does not correspond to the file</span></span>
<span class="line" id="L4349"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">mmap</span>(</span>
<span class="line" id="L4350">    ptr: ?[*]<span class="tok-kw">align</span>(mem.page_size) <span class="tok-type">u8</span>,</span>
<span class="line" id="L4351">    length: <span class="tok-type">usize</span>,</span>
<span class="line" id="L4352">    prot: <span class="tok-type">u32</span>,</span>
<span class="line" id="L4353">    flags: <span class="tok-type">u32</span>,</span>
<span class="line" id="L4354">    fd: fd_t,</span>
<span class="line" id="L4355">    offset: <span class="tok-type">u64</span>,</span>
<span class="line" id="L4356">) MMapError![]<span class="tok-kw">align</span>(mem.page_size) <span class="tok-type">u8</span> {</span>
<span class="line" id="L4357">    <span class="tok-kw">const</span> mmap_sym = <span class="tok-kw">if</span> (builtin.os.tag == .linux <span class="tok-kw">and</span> builtin.link_libc)</span>
<span class="line" id="L4358">        system.mmap64</span>
<span class="line" id="L4359">    <span class="tok-kw">else</span></span>
<span class="line" id="L4360">        system.mmap;</span>
<span class="line" id="L4361"></span>
<span class="line" id="L4362">    <span class="tok-kw">const</span> ioffset = <span class="tok-builtin">@bitCast</span>(<span class="tok-type">i64</span>, offset); <span class="tok-comment">// the OS treats this as unsigned</span>
</span>
<span class="line" id="L4363">    <span class="tok-kw">const</span> rc = mmap_sym(ptr, length, prot, flags, fd, ioffset);</span>
<span class="line" id="L4364">    <span class="tok-kw">const</span> err = <span class="tok-kw">if</span> (builtin.link_libc) blk: {</span>
<span class="line" id="L4365">        <span class="tok-kw">if</span> (rc != std.c.MAP.FAILED) <span class="tok-kw">return</span> <span class="tok-builtin">@ptrCast</span>([*]<span class="tok-kw">align</span>(mem.page_size) <span class="tok-type">u8</span>, <span class="tok-builtin">@alignCast</span>(mem.page_size, rc))[<span class="tok-number">0</span>..length];</span>
<span class="line" id="L4366">        <span class="tok-kw">break</span> :blk <span class="tok-builtin">@intToEnum</span>(E, system._errno().*);</span>
<span class="line" id="L4367">    } <span class="tok-kw">else</span> blk: {</span>
<span class="line" id="L4368">        <span class="tok-kw">const</span> err = errno(rc);</span>
<span class="line" id="L4369">        <span class="tok-kw">if</span> (err == .SUCCESS) <span class="tok-kw">return</span> <span class="tok-builtin">@intToPtr</span>([*]<span class="tok-kw">align</span>(mem.page_size) <span class="tok-type">u8</span>, rc)[<span class="tok-number">0</span>..length];</span>
<span class="line" id="L4370">        <span class="tok-kw">break</span> :blk err;</span>
<span class="line" id="L4371">    };</span>
<span class="line" id="L4372">    <span class="tok-kw">switch</span> (err) {</span>
<span class="line" id="L4373">        .SUCCESS =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L4374">        .TXTBSY =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.AccessDenied,</span>
<span class="line" id="L4375">        .ACCES =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.AccessDenied,</span>
<span class="line" id="L4376">        .PERM =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.PermissionDenied,</span>
<span class="line" id="L4377">        .AGAIN =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.LockedMemoryLimitExceeded,</span>
<span class="line" id="L4378">        .BADF =&gt; <span class="tok-kw">unreachable</span>, <span class="tok-comment">// Always a race condition.</span>
</span>
<span class="line" id="L4379">        .OVERFLOW =&gt; <span class="tok-kw">unreachable</span>, <span class="tok-comment">// The number of pages used for length + offset would overflow.</span>
</span>
<span class="line" id="L4380">        .NODEV =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.MemoryMappingNotSupported,</span>
<span class="line" id="L4381">        .INVAL =&gt; <span class="tok-kw">unreachable</span>, <span class="tok-comment">// Invalid parameters to mmap()</span>
</span>
<span class="line" id="L4382">        .NOMEM =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.OutOfMemory,</span>
<span class="line" id="L4383">        <span class="tok-kw">else</span> =&gt; <span class="tok-kw">return</span> unexpectedErrno(err),</span>
<span class="line" id="L4384">    }</span>
<span class="line" id="L4385">}</span>
<span class="line" id="L4386"></span>
<span class="line" id="L4387"><span class="tok-comment">/// Deletes the mappings for the specified address range, causing</span></span>
<span class="line" id="L4388"><span class="tok-comment">/// further references to addresses within the range to generate invalid memory references.</span></span>
<span class="line" id="L4389"><span class="tok-comment">/// Note that while POSIX allows unmapping a region in the middle of an existing mapping,</span></span>
<span class="line" id="L4390"><span class="tok-comment">/// Zig's munmap function does not, for two reasons:</span></span>
<span class="line" id="L4391"><span class="tok-comment">/// * It violates the Zig principle that resource deallocation must succeed.</span></span>
<span class="line" id="L4392"><span class="tok-comment">/// * The Windows function, VirtualFree, has this restriction.</span></span>
<span class="line" id="L4393"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">munmap</span>(memory: []<span class="tok-kw">align</span>(mem.page_size) <span class="tok-kw">const</span> <span class="tok-type">u8</span>) <span class="tok-type">void</span> {</span>
<span class="line" id="L4394">    <span class="tok-kw">switch</span> (errno(system.munmap(memory.ptr, memory.len))) {</span>
<span class="line" id="L4395">        .SUCCESS =&gt; <span class="tok-kw">return</span>,</span>
<span class="line" id="L4396">        .INVAL =&gt; <span class="tok-kw">unreachable</span>, <span class="tok-comment">// Invalid parameters.</span>
</span>
<span class="line" id="L4397">        .NOMEM =&gt; <span class="tok-kw">unreachable</span>, <span class="tok-comment">// Attempted to unmap a region in the middle of an existing mapping.</span>
</span>
<span class="line" id="L4398">        <span class="tok-kw">else</span> =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L4399">    }</span>
<span class="line" id="L4400">}</span>
<span class="line" id="L4401"></span>
<span class="line" id="L4402"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> MSyncError = <span class="tok-kw">error</span>{</span>
<span class="line" id="L4403">    UnmappedMemory,</span>
<span class="line" id="L4404">} || UnexpectedError;</span>
<span class="line" id="L4405"></span>
<span class="line" id="L4406"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">msync</span>(memory: []<span class="tok-kw">align</span>(mem.page_size) <span class="tok-type">u8</span>, flags: <span class="tok-type">i32</span>) MSyncError!<span class="tok-type">void</span> {</span>
<span class="line" id="L4407">    <span class="tok-kw">switch</span> (errno(system.msync(memory.ptr, memory.len, flags))) {</span>
<span class="line" id="L4408">        .SUCCESS =&gt; <span class="tok-kw">return</span>,</span>
<span class="line" id="L4409">        .NOMEM =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.UnmappedMemory, <span class="tok-comment">// Unsuccessful, provided pointer does not point mapped memory</span>
</span>
<span class="line" id="L4410">        .INVAL =&gt; <span class="tok-kw">unreachable</span>, <span class="tok-comment">// Invalid parameters.</span>
</span>
<span class="line" id="L4411">        <span class="tok-kw">else</span> =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L4412">    }</span>
<span class="line" id="L4413">}</span>
<span class="line" id="L4414"></span>
<span class="line" id="L4415"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> AccessError = <span class="tok-kw">error</span>{</span>
<span class="line" id="L4416">    PermissionDenied,</span>
<span class="line" id="L4417">    FileNotFound,</span>
<span class="line" id="L4418">    NameTooLong,</span>
<span class="line" id="L4419">    InputOutput,</span>
<span class="line" id="L4420">    SystemResources,</span>
<span class="line" id="L4421">    BadPathName,</span>
<span class="line" id="L4422">    FileBusy,</span>
<span class="line" id="L4423">    SymLinkLoop,</span>
<span class="line" id="L4424">    ReadOnlyFileSystem,</span>
<span class="line" id="L4425"></span>
<span class="line" id="L4426">    <span class="tok-comment">/// On Windows, file paths must be valid Unicode.</span></span>
<span class="line" id="L4427">    InvalidUtf8,</span>
<span class="line" id="L4428">} || UnexpectedError;</span>
<span class="line" id="L4429"></span>
<span class="line" id="L4430"><span class="tok-comment">/// check user's permissions for a file</span></span>
<span class="line" id="L4431"><span class="tok-comment">/// TODO currently this assumes `mode` is `F.OK` on Windows.</span></span>
<span class="line" id="L4432"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">access</span>(path: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>, mode: <span class="tok-type">u32</span>) AccessError!<span class="tok-type">void</span> {</span>
<span class="line" id="L4433">    <span class="tok-kw">if</span> (builtin.os.tag == .windows) {</span>
<span class="line" id="L4434">        <span class="tok-kw">const</span> path_w = <span class="tok-kw">try</span> windows.sliceToPrefixedFileW(path);</span>
<span class="line" id="L4435">        _ = <span class="tok-kw">try</span> windows.GetFileAttributesW(path_w.span().ptr);</span>
<span class="line" id="L4436">        <span class="tok-kw">return</span>;</span>
<span class="line" id="L4437">    } <span class="tok-kw">else</span> <span class="tok-kw">if</span> (builtin.os.tag == .wasi <span class="tok-kw">and</span> !builtin.link_libc) {</span>
<span class="line" id="L4438">        <span class="tok-kw">return</span> faccessat(wasi.AT.FDCWD, path, mode, <span class="tok-number">0</span>);</span>
<span class="line" id="L4439">    }</span>
<span class="line" id="L4440">    <span class="tok-kw">const</span> path_c = <span class="tok-kw">try</span> toPosixPath(path);</span>
<span class="line" id="L4441">    <span class="tok-kw">return</span> accessZ(&amp;path_c, mode);</span>
<span class="line" id="L4442">}</span>
<span class="line" id="L4443"></span>
<span class="line" id="L4444"><span class="tok-comment">/// Same as `access` except `path` is null-terminated.</span></span>
<span class="line" id="L4445"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">accessZ</span>(path: [*:<span class="tok-number">0</span>]<span class="tok-kw">const</span> <span class="tok-type">u8</span>, mode: <span class="tok-type">u32</span>) AccessError!<span class="tok-type">void</span> {</span>
<span class="line" id="L4446">    <span class="tok-kw">if</span> (builtin.os.tag == .windows) {</span>
<span class="line" id="L4447">        <span class="tok-kw">const</span> path_w = <span class="tok-kw">try</span> windows.cStrToPrefixedFileW(path);</span>
<span class="line" id="L4448">        _ = <span class="tok-kw">try</span> windows.GetFileAttributesW(path_w.span().ptr);</span>
<span class="line" id="L4449">        <span class="tok-kw">return</span>;</span>
<span class="line" id="L4450">    } <span class="tok-kw">else</span> <span class="tok-kw">if</span> (builtin.os.tag == .wasi <span class="tok-kw">and</span> !builtin.link_libc) {</span>
<span class="line" id="L4451">        <span class="tok-kw">return</span> access(mem.sliceTo(path, <span class="tok-number">0</span>), mode);</span>
<span class="line" id="L4452">    }</span>
<span class="line" id="L4453">    <span class="tok-kw">switch</span> (errno(system.access(path, mode))) {</span>
<span class="line" id="L4454">        .SUCCESS =&gt; <span class="tok-kw">return</span>,</span>
<span class="line" id="L4455">        .ACCES =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.PermissionDenied,</span>
<span class="line" id="L4456">        .ROFS =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.ReadOnlyFileSystem,</span>
<span class="line" id="L4457">        .LOOP =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.SymLinkLoop,</span>
<span class="line" id="L4458">        .TXTBSY =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.FileBusy,</span>
<span class="line" id="L4459">        .NOTDIR =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.FileNotFound,</span>
<span class="line" id="L4460">        .NOENT =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.FileNotFound,</span>
<span class="line" id="L4461">        .NAMETOOLONG =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.NameTooLong,</span>
<span class="line" id="L4462">        .INVAL =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L4463">        .FAULT =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L4464">        .IO =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.InputOutput,</span>
<span class="line" id="L4465">        .NOMEM =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.SystemResources,</span>
<span class="line" id="L4466">        <span class="tok-kw">else</span> =&gt; |err| <span class="tok-kw">return</span> unexpectedErrno(err),</span>
<span class="line" id="L4467">    }</span>
<span class="line" id="L4468">}</span>
<span class="line" id="L4469"></span>
<span class="line" id="L4470"><span class="tok-comment">/// Call from Windows-specific code if you already have a UTF-16LE encoded, null terminated string.</span></span>
<span class="line" id="L4471"><span class="tok-comment">/// Otherwise use `access` or `accessC`.</span></span>
<span class="line" id="L4472"><span class="tok-comment">/// TODO currently this ignores `mode`.</span></span>
<span class="line" id="L4473"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">accessW</span>(path: [*:<span class="tok-number">0</span>]<span class="tok-kw">const</span> <span class="tok-type">u16</span>, mode: <span class="tok-type">u32</span>) windows.GetFileAttributesError!<span class="tok-type">void</span> {</span>
<span class="line" id="L4474">    _ = mode;</span>
<span class="line" id="L4475">    <span class="tok-kw">const</span> ret = <span class="tok-kw">try</span> windows.GetFileAttributesW(path);</span>
<span class="line" id="L4476">    <span class="tok-kw">if</span> (ret != windows.INVALID_FILE_ATTRIBUTES) {</span>
<span class="line" id="L4477">        <span class="tok-kw">return</span>;</span>
<span class="line" id="L4478">    }</span>
<span class="line" id="L4479">    <span class="tok-kw">switch</span> (windows.kernel32.GetLastError()) {</span>
<span class="line" id="L4480">        .FILE_NOT_FOUND =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.FileNotFound,</span>
<span class="line" id="L4481">        .PATH_NOT_FOUND =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.FileNotFound,</span>
<span class="line" id="L4482">        .ACCESS_DENIED =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.PermissionDenied,</span>
<span class="line" id="L4483">        <span class="tok-kw">else</span> =&gt; |err| <span class="tok-kw">return</span> windows.unexpectedError(err),</span>
<span class="line" id="L4484">    }</span>
<span class="line" id="L4485">}</span>
<span class="line" id="L4486"></span>
<span class="line" id="L4487"><span class="tok-comment">/// Check user's permissions for a file, based on an open directory handle.</span></span>
<span class="line" id="L4488"><span class="tok-comment">/// TODO currently this ignores `mode` and `flags` on Windows.</span></span>
<span class="line" id="L4489"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">faccessat</span>(dirfd: fd_t, path: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>, mode: <span class="tok-type">u32</span>, flags: <span class="tok-type">u32</span>) AccessError!<span class="tok-type">void</span> {</span>
<span class="line" id="L4490">    <span class="tok-kw">if</span> (builtin.os.tag == .windows) {</span>
<span class="line" id="L4491">        <span class="tok-kw">const</span> path_w = <span class="tok-kw">try</span> windows.sliceToPrefixedFileW(path);</span>
<span class="line" id="L4492">        <span class="tok-kw">return</span> faccessatW(dirfd, path_w.span().ptr, mode, flags);</span>
<span class="line" id="L4493">    } <span class="tok-kw">else</span> <span class="tok-kw">if</span> (builtin.os.tag == .wasi <span class="tok-kw">and</span> !builtin.link_libc) {</span>
<span class="line" id="L4494">        <span class="tok-kw">var</span> resolved = RelativePathWasi{ .dir_fd = dirfd, .relative_path = path };</span>
<span class="line" id="L4495"></span>
<span class="line" id="L4496">        <span class="tok-kw">const</span> file = blk: {</span>
<span class="line" id="L4497">            <span class="tok-kw">if</span> (dirfd == wasi.AT.FDCWD <span class="tok-kw">or</span> fs.path.isAbsolute(path)) {</span>
<span class="line" id="L4498">                <span class="tok-comment">// Resolve absolute or CWD-relative paths to a path within a Preopen</span>
</span>
<span class="line" id="L4499">                <span class="tok-kw">var</span> path_buf: [MAX_PATH_BYTES]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L4500">                resolved = resolvePathWasi(path, &amp;path_buf) <span class="tok-kw">catch</span> |err| <span class="tok-kw">break</span> :blk <span class="tok-builtin">@as</span>(FStatAtError!Stat, err);</span>
<span class="line" id="L4501">                <span class="tok-kw">break</span> :blk fstatat(resolved.dir_fd, resolved.relative_path, flags);</span>
<span class="line" id="L4502">            }</span>
<span class="line" id="L4503">            <span class="tok-kw">break</span> :blk fstatat(dirfd, path, flags);</span>
<span class="line" id="L4504">        } <span class="tok-kw">catch</span> |err| <span class="tok-kw">switch</span> (err) {</span>
<span class="line" id="L4505">            <span class="tok-kw">error</span>.AccessDenied =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.PermissionDenied,</span>
<span class="line" id="L4506">            <span class="tok-kw">else</span> =&gt; |e| <span class="tok-kw">return</span> e,</span>
<span class="line" id="L4507">        };</span>
<span class="line" id="L4508"></span>
<span class="line" id="L4509">        <span class="tok-kw">if</span> (mode != F_OK) {</span>
<span class="line" id="L4510">            <span class="tok-kw">var</span> directory: wasi.fdstat_t = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L4511">            <span class="tok-kw">if</span> (wasi.fd_fdstat_get(resolved.dir_fd, &amp;directory) != .SUCCESS) {</span>
<span class="line" id="L4512">                <span class="tok-kw">return</span> <span class="tok-kw">error</span>.PermissionDenied;</span>
<span class="line" id="L4513">            }</span>
<span class="line" id="L4514"></span>
<span class="line" id="L4515">            <span class="tok-kw">var</span> rights: wasi.rights_t = <span class="tok-number">0</span>;</span>
<span class="line" id="L4516">            <span class="tok-kw">if</span> (mode &amp; R_OK != <span class="tok-number">0</span>) {</span>
<span class="line" id="L4517">                rights |= <span class="tok-kw">if</span> (file.filetype == .DIRECTORY)</span>
<span class="line" id="L4518">                    wasi.RIGHT.FD_READDIR</span>
<span class="line" id="L4519">                <span class="tok-kw">else</span></span>
<span class="line" id="L4520">                    wasi.RIGHT.FD_READ;</span>
<span class="line" id="L4521">            }</span>
<span class="line" id="L4522">            <span class="tok-kw">if</span> (mode &amp; W_OK != <span class="tok-number">0</span>) {</span>
<span class="line" id="L4523">                rights |= wasi.RIGHT.FD_WRITE;</span>
<span class="line" id="L4524">            }</span>
<span class="line" id="L4525">            <span class="tok-comment">// No validation for X_OK</span>
</span>
<span class="line" id="L4526"></span>
<span class="line" id="L4527">            <span class="tok-kw">if</span> ((rights &amp; directory.fs_rights_inheriting) != rights) {</span>
<span class="line" id="L4528">                <span class="tok-kw">return</span> <span class="tok-kw">error</span>.PermissionDenied;</span>
<span class="line" id="L4529">            }</span>
<span class="line" id="L4530">        }</span>
<span class="line" id="L4531">        <span class="tok-kw">return</span>;</span>
<span class="line" id="L4532">    }</span>
<span class="line" id="L4533">    <span class="tok-kw">const</span> path_c = <span class="tok-kw">try</span> toPosixPath(path);</span>
<span class="line" id="L4534">    <span class="tok-kw">return</span> faccessatZ(dirfd, &amp;path_c, mode, flags);</span>
<span class="line" id="L4535">}</span>
<span class="line" id="L4536"></span>
<span class="line" id="L4537"><span class="tok-comment">/// Same as `faccessat` except the path parameter is null-terminated.</span></span>
<span class="line" id="L4538"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">faccessatZ</span>(dirfd: fd_t, path: [*:<span class="tok-number">0</span>]<span class="tok-kw">const</span> <span class="tok-type">u8</span>, mode: <span class="tok-type">u32</span>, flags: <span class="tok-type">u32</span>) AccessError!<span class="tok-type">void</span> {</span>
<span class="line" id="L4539">    <span class="tok-kw">if</span> (builtin.os.tag == .windows) {</span>
<span class="line" id="L4540">        <span class="tok-kw">const</span> path_w = <span class="tok-kw">try</span> windows.cStrToPrefixedFileW(path);</span>
<span class="line" id="L4541">        <span class="tok-kw">return</span> faccessatW(dirfd, path_w.span().ptr, mode, flags);</span>
<span class="line" id="L4542">    } <span class="tok-kw">else</span> <span class="tok-kw">if</span> (builtin.os.tag == .wasi <span class="tok-kw">and</span> !builtin.link_libc) {</span>
<span class="line" id="L4543">        <span class="tok-kw">return</span> faccessat(dirfd, mem.sliceTo(path, <span class="tok-number">0</span>), mode, flags);</span>
<span class="line" id="L4544">    }</span>
<span class="line" id="L4545">    <span class="tok-kw">switch</span> (errno(system.faccessat(dirfd, path, mode, flags))) {</span>
<span class="line" id="L4546">        .SUCCESS =&gt; <span class="tok-kw">return</span>,</span>
<span class="line" id="L4547">        .ACCES =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.PermissionDenied,</span>
<span class="line" id="L4548">        .ROFS =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.ReadOnlyFileSystem,</span>
<span class="line" id="L4549">        .LOOP =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.SymLinkLoop,</span>
<span class="line" id="L4550">        .TXTBSY =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.FileBusy,</span>
<span class="line" id="L4551">        .NOTDIR =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.FileNotFound,</span>
<span class="line" id="L4552">        .NOENT =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.FileNotFound,</span>
<span class="line" id="L4553">        .NAMETOOLONG =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.NameTooLong,</span>
<span class="line" id="L4554">        .INVAL =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L4555">        .FAULT =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L4556">        .IO =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.InputOutput,</span>
<span class="line" id="L4557">        .NOMEM =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.SystemResources,</span>
<span class="line" id="L4558">        <span class="tok-kw">else</span> =&gt; |err| <span class="tok-kw">return</span> unexpectedErrno(err),</span>
<span class="line" id="L4559">    }</span>
<span class="line" id="L4560">}</span>
<span class="line" id="L4561"></span>
<span class="line" id="L4562"><span class="tok-comment">/// Same as `faccessat` except asserts the target is Windows and the path parameter</span></span>
<span class="line" id="L4563"><span class="tok-comment">/// is NtDll-prefixed, null-terminated, WTF-16 encoded.</span></span>
<span class="line" id="L4564"><span class="tok-comment">/// TODO currently this ignores `mode` and `flags`</span></span>
<span class="line" id="L4565"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">faccessatW</span>(dirfd: fd_t, sub_path_w: [*:<span class="tok-number">0</span>]<span class="tok-kw">const</span> <span class="tok-type">u16</span>, mode: <span class="tok-type">u32</span>, flags: <span class="tok-type">u32</span>) AccessError!<span class="tok-type">void</span> {</span>
<span class="line" id="L4566">    _ = mode;</span>
<span class="line" id="L4567">    _ = flags;</span>
<span class="line" id="L4568">    <span class="tok-kw">if</span> (sub_path_w[<span class="tok-number">0</span>] == <span class="tok-str">'.'</span> <span class="tok-kw">and</span> sub_path_w[<span class="tok-number">1</span>] == <span class="tok-number">0</span>) {</span>
<span class="line" id="L4569">        <span class="tok-kw">return</span>;</span>
<span class="line" id="L4570">    }</span>
<span class="line" id="L4571">    <span class="tok-kw">if</span> (sub_path_w[<span class="tok-number">0</span>] == <span class="tok-str">'.'</span> <span class="tok-kw">and</span> sub_path_w[<span class="tok-number">1</span>] == <span class="tok-str">'.'</span> <span class="tok-kw">and</span> sub_path_w[<span class="tok-number">2</span>] == <span class="tok-number">0</span>) {</span>
<span class="line" id="L4572">        <span class="tok-kw">return</span>;</span>
<span class="line" id="L4573">    }</span>
<span class="line" id="L4574"></span>
<span class="line" id="L4575">    <span class="tok-kw">const</span> path_len_bytes = math.cast(<span class="tok-type">u16</span>, mem.sliceTo(sub_path_w, <span class="tok-number">0</span>).len * <span class="tok-number">2</span>) <span class="tok-kw">orelse</span> <span class="tok-kw">return</span> <span class="tok-kw">error</span>.NameTooLong;</span>
<span class="line" id="L4576">    <span class="tok-kw">var</span> nt_name = windows.UNICODE_STRING{</span>
<span class="line" id="L4577">        .Length = path_len_bytes,</span>
<span class="line" id="L4578">        .MaximumLength = path_len_bytes,</span>
<span class="line" id="L4579">        .Buffer = <span class="tok-builtin">@intToPtr</span>([*]<span class="tok-type">u16</span>, <span class="tok-builtin">@ptrToInt</span>(sub_path_w)),</span>
<span class="line" id="L4580">    };</span>
<span class="line" id="L4581">    <span class="tok-kw">var</span> attr = windows.OBJECT_ATTRIBUTES{</span>
<span class="line" id="L4582">        .Length = <span class="tok-builtin">@sizeOf</span>(windows.OBJECT_ATTRIBUTES),</span>
<span class="line" id="L4583">        .RootDirectory = <span class="tok-kw">if</span> (std.fs.path.isAbsoluteWindowsW(sub_path_w)) <span class="tok-null">null</span> <span class="tok-kw">else</span> dirfd,</span>
<span class="line" id="L4584">        .Attributes = <span class="tok-number">0</span>, <span class="tok-comment">// Note we do not use OBJ_CASE_INSENSITIVE here.</span>
</span>
<span class="line" id="L4585">        .ObjectName = &amp;nt_name,</span>
<span class="line" id="L4586">        .SecurityDescriptor = <span class="tok-null">null</span>,</span>
<span class="line" id="L4587">        .SecurityQualityOfService = <span class="tok-null">null</span>,</span>
<span class="line" id="L4588">    };</span>
<span class="line" id="L4589">    <span class="tok-kw">var</span> basic_info: windows.FILE_BASIC_INFORMATION = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L4590">    <span class="tok-kw">switch</span> (windows.ntdll.NtQueryAttributesFile(&amp;attr, &amp;basic_info)) {</span>
<span class="line" id="L4591">        .SUCCESS =&gt; <span class="tok-kw">return</span>,</span>
<span class="line" id="L4592">        .OBJECT_NAME_NOT_FOUND =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.FileNotFound,</span>
<span class="line" id="L4593">        .OBJECT_PATH_NOT_FOUND =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.FileNotFound,</span>
<span class="line" id="L4594">        .OBJECT_NAME_INVALID =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L4595">        .INVALID_PARAMETER =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L4596">        .ACCESS_DENIED =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.PermissionDenied,</span>
<span class="line" id="L4597">        .OBJECT_PATH_SYNTAX_BAD =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L4598">        <span class="tok-kw">else</span> =&gt; |rc| <span class="tok-kw">return</span> windows.unexpectedStatus(rc),</span>
<span class="line" id="L4599">    }</span>
<span class="line" id="L4600">}</span>
<span class="line" id="L4601"></span>
<span class="line" id="L4602"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> PipeError = <span class="tok-kw">error</span>{</span>
<span class="line" id="L4603">    SystemFdQuotaExceeded,</span>
<span class="line" id="L4604">    ProcessFdQuotaExceeded,</span>
<span class="line" id="L4605">} || UnexpectedError;</span>
<span class="line" id="L4606"></span>
<span class="line" id="L4607"><span class="tok-comment">/// Creates a unidirectional data channel that can be used for interprocess communication.</span></span>
<span class="line" id="L4608"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">pipe</span>() PipeError![<span class="tok-number">2</span>]fd_t {</span>
<span class="line" id="L4609">    <span class="tok-kw">var</span> fds: [<span class="tok-number">2</span>]fd_t = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L4610">    <span class="tok-kw">switch</span> (errno(system.pipe(&amp;fds))) {</span>
<span class="line" id="L4611">        .SUCCESS =&gt; <span class="tok-kw">return</span> fds,</span>
<span class="line" id="L4612">        .INVAL =&gt; <span class="tok-kw">unreachable</span>, <span class="tok-comment">// Invalid parameters to pipe()</span>
</span>
<span class="line" id="L4613">        .FAULT =&gt; <span class="tok-kw">unreachable</span>, <span class="tok-comment">// Invalid fds pointer</span>
</span>
<span class="line" id="L4614">        .NFILE =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.SystemFdQuotaExceeded,</span>
<span class="line" id="L4615">        .MFILE =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.ProcessFdQuotaExceeded,</span>
<span class="line" id="L4616">        <span class="tok-kw">else</span> =&gt; |err| <span class="tok-kw">return</span> unexpectedErrno(err),</span>
<span class="line" id="L4617">    }</span>
<span class="line" id="L4618">}</span>
<span class="line" id="L4619"></span>
<span class="line" id="L4620"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">pipe2</span>(flags: <span class="tok-type">u32</span>) PipeError![<span class="tok-number">2</span>]fd_t {</span>
<span class="line" id="L4621">    <span class="tok-kw">if</span> (<span class="tok-builtin">@hasDecl</span>(system, <span class="tok-str">&quot;pipe2&quot;</span>)) {</span>
<span class="line" id="L4622">        <span class="tok-kw">var</span> fds: [<span class="tok-number">2</span>]fd_t = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L4623">        <span class="tok-kw">switch</span> (errno(system.pipe2(&amp;fds, flags))) {</span>
<span class="line" id="L4624">            .SUCCESS =&gt; <span class="tok-kw">return</span> fds,</span>
<span class="line" id="L4625">            .INVAL =&gt; <span class="tok-kw">unreachable</span>, <span class="tok-comment">// Invalid flags</span>
</span>
<span class="line" id="L4626">            .FAULT =&gt; <span class="tok-kw">unreachable</span>, <span class="tok-comment">// Invalid fds pointer</span>
</span>
<span class="line" id="L4627">            .NFILE =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.SystemFdQuotaExceeded,</span>
<span class="line" id="L4628">            .MFILE =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.ProcessFdQuotaExceeded,</span>
<span class="line" id="L4629">            <span class="tok-kw">else</span> =&gt; |err| <span class="tok-kw">return</span> unexpectedErrno(err),</span>
<span class="line" id="L4630">        }</span>
<span class="line" id="L4631">    }</span>
<span class="line" id="L4632"></span>
<span class="line" id="L4633">    <span class="tok-kw">var</span> fds: [<span class="tok-number">2</span>]fd_t = <span class="tok-kw">try</span> pipe();</span>
<span class="line" id="L4634">    <span class="tok-kw">errdefer</span> {</span>
<span class="line" id="L4635">        close(fds[<span class="tok-number">0</span>]);</span>
<span class="line" id="L4636">        close(fds[<span class="tok-number">1</span>]);</span>
<span class="line" id="L4637">    }</span>
<span class="line" id="L4638"></span>
<span class="line" id="L4639">    <span class="tok-kw">if</span> (flags == <span class="tok-number">0</span>)</span>
<span class="line" id="L4640">        <span class="tok-kw">return</span> fds;</span>
<span class="line" id="L4641"></span>
<span class="line" id="L4642">    <span class="tok-comment">// O.CLOEXEC is special, it's a file descriptor flag and must be set using</span>
</span>
<span class="line" id="L4643">    <span class="tok-comment">// F.SETFD.</span>
</span>
<span class="line" id="L4644">    <span class="tok-kw">if</span> (flags &amp; O.CLOEXEC != <span class="tok-number">0</span>) {</span>
<span class="line" id="L4645">        <span class="tok-kw">for</span> (fds) |fd| {</span>
<span class="line" id="L4646">            <span class="tok-kw">switch</span> (errno(system.fcntl(fd, F.SETFD, <span class="tok-builtin">@as</span>(<span class="tok-type">u32</span>, FD_CLOEXEC)))) {</span>
<span class="line" id="L4647">                .SUCCESS =&gt; {},</span>
<span class="line" id="L4648">                .INVAL =&gt; <span class="tok-kw">unreachable</span>, <span class="tok-comment">// Invalid flags</span>
</span>
<span class="line" id="L4649">                .BADF =&gt; <span class="tok-kw">unreachable</span>, <span class="tok-comment">// Always a race condition</span>
</span>
<span class="line" id="L4650">                <span class="tok-kw">else</span> =&gt; |err| <span class="tok-kw">return</span> unexpectedErrno(err),</span>
<span class="line" id="L4651">            }</span>
<span class="line" id="L4652">        }</span>
<span class="line" id="L4653">    }</span>
<span class="line" id="L4654"></span>
<span class="line" id="L4655">    <span class="tok-kw">const</span> new_flags = flags &amp; ~<span class="tok-builtin">@as</span>(<span class="tok-type">u32</span>, O.CLOEXEC);</span>
<span class="line" id="L4656">    <span class="tok-comment">// Set every other flag affecting the file status using F.SETFL.</span>
</span>
<span class="line" id="L4657">    <span class="tok-kw">if</span> (new_flags != <span class="tok-number">0</span>) {</span>
<span class="line" id="L4658">        <span class="tok-kw">for</span> (fds) |fd| {</span>
<span class="line" id="L4659">            <span class="tok-kw">switch</span> (errno(system.fcntl(fd, F.SETFL, new_flags))) {</span>
<span class="line" id="L4660">                .SUCCESS =&gt; {},</span>
<span class="line" id="L4661">                .INVAL =&gt; <span class="tok-kw">unreachable</span>, <span class="tok-comment">// Invalid flags</span>
</span>
<span class="line" id="L4662">                .BADF =&gt; <span class="tok-kw">unreachable</span>, <span class="tok-comment">// Always a race condition</span>
</span>
<span class="line" id="L4663">                <span class="tok-kw">else</span> =&gt; |err| <span class="tok-kw">return</span> unexpectedErrno(err),</span>
<span class="line" id="L4664">            }</span>
<span class="line" id="L4665">        }</span>
<span class="line" id="L4666">    }</span>
<span class="line" id="L4667"></span>
<span class="line" id="L4668">    <span class="tok-kw">return</span> fds;</span>
<span class="line" id="L4669">}</span>
<span class="line" id="L4670"></span>
<span class="line" id="L4671"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> SysCtlError = <span class="tok-kw">error</span>{</span>
<span class="line" id="L4672">    PermissionDenied,</span>
<span class="line" id="L4673">    SystemResources,</span>
<span class="line" id="L4674">    NameTooLong,</span>
<span class="line" id="L4675">    UnknownName,</span>
<span class="line" id="L4676">} || UnexpectedError;</span>
<span class="line" id="L4677"></span>
<span class="line" id="L4678"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">sysctl</span>(</span>
<span class="line" id="L4679">    name: []<span class="tok-kw">const</span> <span class="tok-type">c_int</span>,</span>
<span class="line" id="L4680">    oldp: ?*<span class="tok-type">anyopaque</span>,</span>
<span class="line" id="L4681">    oldlenp: ?*<span class="tok-type">usize</span>,</span>
<span class="line" id="L4682">    newp: ?*<span class="tok-type">anyopaque</span>,</span>
<span class="line" id="L4683">    newlen: <span class="tok-type">usize</span>,</span>
<span class="line" id="L4684">) SysCtlError!<span class="tok-type">void</span> {</span>
<span class="line" id="L4685">    <span class="tok-kw">if</span> (builtin.os.tag == .wasi) {</span>
<span class="line" id="L4686">        <span class="tok-builtin">@panic</span>(<span class="tok-str">&quot;unsupported&quot;</span>); <span class="tok-comment">// TODO should be compile error, not panic</span>
</span>
<span class="line" id="L4687">    }</span>
<span class="line" id="L4688">    <span class="tok-kw">if</span> (builtin.os.tag == .haiku) {</span>
<span class="line" id="L4689">        <span class="tok-builtin">@panic</span>(<span class="tok-str">&quot;unsupported&quot;</span>); <span class="tok-comment">// TODO should be compile error, not panic</span>
</span>
<span class="line" id="L4690">    }</span>
<span class="line" id="L4691"></span>
<span class="line" id="L4692">    <span class="tok-kw">const</span> name_len = math.cast(<span class="tok-type">c_uint</span>, name.len) <span class="tok-kw">orelse</span> <span class="tok-kw">return</span> <span class="tok-kw">error</span>.NameTooLong;</span>
<span class="line" id="L4693">    <span class="tok-kw">switch</span> (errno(system.sysctl(name.ptr, name_len, oldp, oldlenp, newp, newlen))) {</span>
<span class="line" id="L4694">        .SUCCESS =&gt; <span class="tok-kw">return</span>,</span>
<span class="line" id="L4695">        .FAULT =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L4696">        .PERM =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.PermissionDenied,</span>
<span class="line" id="L4697">        .NOMEM =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.SystemResources,</span>
<span class="line" id="L4698">        .NOENT =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.UnknownName,</span>
<span class="line" id="L4699">        <span class="tok-kw">else</span> =&gt; |err| <span class="tok-kw">return</span> unexpectedErrno(err),</span>
<span class="line" id="L4700">    }</span>
<span class="line" id="L4701">}</span>
<span class="line" id="L4702"></span>
<span class="line" id="L4703"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">sysctlbynameZ</span>(</span>
<span class="line" id="L4704">    name: [*:<span class="tok-number">0</span>]<span class="tok-kw">const</span> <span class="tok-type">u8</span>,</span>
<span class="line" id="L4705">    oldp: ?*<span class="tok-type">anyopaque</span>,</span>
<span class="line" id="L4706">    oldlenp: ?*<span class="tok-type">usize</span>,</span>
<span class="line" id="L4707">    newp: ?*<span class="tok-type">anyopaque</span>,</span>
<span class="line" id="L4708">    newlen: <span class="tok-type">usize</span>,</span>
<span class="line" id="L4709">) SysCtlError!<span class="tok-type">void</span> {</span>
<span class="line" id="L4710">    <span class="tok-kw">if</span> (builtin.os.tag == .wasi) {</span>
<span class="line" id="L4711">        <span class="tok-builtin">@panic</span>(<span class="tok-str">&quot;unsupported&quot;</span>); <span class="tok-comment">// TODO should be compile error, not panic</span>
</span>
<span class="line" id="L4712">    }</span>
<span class="line" id="L4713">    <span class="tok-kw">if</span> (builtin.os.tag == .haiku) {</span>
<span class="line" id="L4714">        <span class="tok-builtin">@panic</span>(<span class="tok-str">&quot;unsupported&quot;</span>); <span class="tok-comment">// TODO should be compile error, not panic</span>
</span>
<span class="line" id="L4715">    }</span>
<span class="line" id="L4716"></span>
<span class="line" id="L4717">    <span class="tok-kw">switch</span> (errno(system.sysctlbyname(name, oldp, oldlenp, newp, newlen))) {</span>
<span class="line" id="L4718">        .SUCCESS =&gt; <span class="tok-kw">return</span>,</span>
<span class="line" id="L4719">        .FAULT =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L4720">        .PERM =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.PermissionDenied,</span>
<span class="line" id="L4721">        .NOMEM =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.SystemResources,</span>
<span class="line" id="L4722">        .NOENT =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.UnknownName,</span>
<span class="line" id="L4723">        <span class="tok-kw">else</span> =&gt; |err| <span class="tok-kw">return</span> unexpectedErrno(err),</span>
<span class="line" id="L4724">    }</span>
<span class="line" id="L4725">}</span>
<span class="line" id="L4726"></span>
<span class="line" id="L4727"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">gettimeofday</span>(tv: ?*timeval, tz: ?*timezone) <span class="tok-type">void</span> {</span>
<span class="line" id="L4728">    <span class="tok-kw">switch</span> (errno(system.gettimeofday(tv, tz))) {</span>
<span class="line" id="L4729">        .SUCCESS =&gt; <span class="tok-kw">return</span>,</span>
<span class="line" id="L4730">        .INVAL =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L4731">        <span class="tok-kw">else</span> =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L4732">    }</span>
<span class="line" id="L4733">}</span>
<span class="line" id="L4734"></span>
<span class="line" id="L4735"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> SeekError = <span class="tok-kw">error</span>{</span>
<span class="line" id="L4736">    Unseekable,</span>
<span class="line" id="L4737"></span>
<span class="line" id="L4738">    <span class="tok-comment">/// In WASI, this error may occur when the file descriptor does</span></span>
<span class="line" id="L4739">    <span class="tok-comment">/// not hold the required rights to seek on it.</span></span>
<span class="line" id="L4740">    AccessDenied,</span>
<span class="line" id="L4741">} || UnexpectedError;</span>
<span class="line" id="L4742"></span>
<span class="line" id="L4743"><span class="tok-comment">/// Repositions read/write file offset relative to the beginning.</span></span>
<span class="line" id="L4744"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">lseek_SET</span>(fd: fd_t, offset: <span class="tok-type">u64</span>) SeekError!<span class="tok-type">void</span> {</span>
<span class="line" id="L4745">    <span class="tok-kw">if</span> (builtin.os.tag == .linux <span class="tok-kw">and</span> !builtin.link_libc <span class="tok-kw">and</span> <span class="tok-builtin">@sizeOf</span>(<span class="tok-type">usize</span>) == <span class="tok-number">4</span>) {</span>
<span class="line" id="L4746">        <span class="tok-kw">var</span> result: <span class="tok-type">u64</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L4747">        <span class="tok-kw">switch</span> (errno(system.llseek(fd, offset, &amp;result, SEEK.SET))) {</span>
<span class="line" id="L4748">            .SUCCESS =&gt; <span class="tok-kw">return</span>,</span>
<span class="line" id="L4749">            .BADF =&gt; <span class="tok-kw">unreachable</span>, <span class="tok-comment">// always a race condition</span>
</span>
<span class="line" id="L4750">            .INVAL =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.Unseekable,</span>
<span class="line" id="L4751">            .OVERFLOW =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.Unseekable,</span>
<span class="line" id="L4752">            .SPIPE =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.Unseekable,</span>
<span class="line" id="L4753">            .NXIO =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.Unseekable,</span>
<span class="line" id="L4754">            <span class="tok-kw">else</span> =&gt; |err| <span class="tok-kw">return</span> unexpectedErrno(err),</span>
<span class="line" id="L4755">        }</span>
<span class="line" id="L4756">    }</span>
<span class="line" id="L4757">    <span class="tok-kw">if</span> (builtin.os.tag == .windows) {</span>
<span class="line" id="L4758">        <span class="tok-kw">return</span> windows.SetFilePointerEx_BEGIN(fd, offset);</span>
<span class="line" id="L4759">    }</span>
<span class="line" id="L4760">    <span class="tok-kw">if</span> (builtin.os.tag == .wasi <span class="tok-kw">and</span> !builtin.link_libc) {</span>
<span class="line" id="L4761">        <span class="tok-kw">var</span> new_offset: wasi.filesize_t = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L4762">        <span class="tok-kw">switch</span> (wasi.fd_seek(fd, <span class="tok-builtin">@bitCast</span>(wasi.filedelta_t, offset), .SET, &amp;new_offset)) {</span>
<span class="line" id="L4763">            .SUCCESS =&gt; <span class="tok-kw">return</span>,</span>
<span class="line" id="L4764">            .BADF =&gt; <span class="tok-kw">unreachable</span>, <span class="tok-comment">// always a race condition</span>
</span>
<span class="line" id="L4765">            .INVAL =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.Unseekable,</span>
<span class="line" id="L4766">            .OVERFLOW =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.Unseekable,</span>
<span class="line" id="L4767">            .SPIPE =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.Unseekable,</span>
<span class="line" id="L4768">            .NXIO =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.Unseekable,</span>
<span class="line" id="L4769">            .NOTCAPABLE =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.AccessDenied,</span>
<span class="line" id="L4770">            <span class="tok-kw">else</span> =&gt; |err| <span class="tok-kw">return</span> unexpectedErrno(err),</span>
<span class="line" id="L4771">        }</span>
<span class="line" id="L4772">    }</span>
<span class="line" id="L4773"></span>
<span class="line" id="L4774">    <span class="tok-kw">const</span> lseek_sym = <span class="tok-kw">if</span> (builtin.os.tag == .linux <span class="tok-kw">and</span> builtin.link_libc)</span>
<span class="line" id="L4775">        system.lseek64</span>
<span class="line" id="L4776">    <span class="tok-kw">else</span></span>
<span class="line" id="L4777">        system.lseek;</span>
<span class="line" id="L4778"></span>
<span class="line" id="L4779">    <span class="tok-kw">const</span> ioffset = <span class="tok-builtin">@bitCast</span>(<span class="tok-type">i64</span>, offset); <span class="tok-comment">// the OS treats this as unsigned</span>
</span>
<span class="line" id="L4780">    <span class="tok-kw">switch</span> (errno(lseek_sym(fd, ioffset, SEEK.SET))) {</span>
<span class="line" id="L4781">        .SUCCESS =&gt; <span class="tok-kw">return</span>,</span>
<span class="line" id="L4782">        .BADF =&gt; <span class="tok-kw">unreachable</span>, <span class="tok-comment">// always a race condition</span>
</span>
<span class="line" id="L4783">        .INVAL =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.Unseekable,</span>
<span class="line" id="L4784">        .OVERFLOW =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.Unseekable,</span>
<span class="line" id="L4785">        .SPIPE =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.Unseekable,</span>
<span class="line" id="L4786">        .NXIO =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.Unseekable,</span>
<span class="line" id="L4787">        <span class="tok-kw">else</span> =&gt; |err| <span class="tok-kw">return</span> unexpectedErrno(err),</span>
<span class="line" id="L4788">    }</span>
<span class="line" id="L4789">}</span>
<span class="line" id="L4790"></span>
<span class="line" id="L4791"><span class="tok-comment">/// Repositions read/write file offset relative to the current offset.</span></span>
<span class="line" id="L4792"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">lseek_CUR</span>(fd: fd_t, offset: <span class="tok-type">i64</span>) SeekError!<span class="tok-type">void</span> {</span>
<span class="line" id="L4793">    <span class="tok-kw">if</span> (builtin.os.tag == .linux <span class="tok-kw">and</span> !builtin.link_libc <span class="tok-kw">and</span> <span class="tok-builtin">@sizeOf</span>(<span class="tok-type">usize</span>) == <span class="tok-number">4</span>) {</span>
<span class="line" id="L4794">        <span class="tok-kw">var</span> result: <span class="tok-type">u64</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L4795">        <span class="tok-kw">switch</span> (errno(system.llseek(fd, <span class="tok-builtin">@bitCast</span>(<span class="tok-type">u64</span>, offset), &amp;result, SEEK.CUR))) {</span>
<span class="line" id="L4796">            .SUCCESS =&gt; <span class="tok-kw">return</span>,</span>
<span class="line" id="L4797">            .BADF =&gt; <span class="tok-kw">unreachable</span>, <span class="tok-comment">// always a race condition</span>
</span>
<span class="line" id="L4798">            .INVAL =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.Unseekable,</span>
<span class="line" id="L4799">            .OVERFLOW =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.Unseekable,</span>
<span class="line" id="L4800">            .SPIPE =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.Unseekable,</span>
<span class="line" id="L4801">            .NXIO =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.Unseekable,</span>
<span class="line" id="L4802">            <span class="tok-kw">else</span> =&gt; |err| <span class="tok-kw">return</span> unexpectedErrno(err),</span>
<span class="line" id="L4803">        }</span>
<span class="line" id="L4804">    }</span>
<span class="line" id="L4805">    <span class="tok-kw">if</span> (builtin.os.tag == .windows) {</span>
<span class="line" id="L4806">        <span class="tok-kw">return</span> windows.SetFilePointerEx_CURRENT(fd, offset);</span>
<span class="line" id="L4807">    }</span>
<span class="line" id="L4808">    <span class="tok-kw">if</span> (builtin.os.tag == .wasi <span class="tok-kw">and</span> !builtin.link_libc) {</span>
<span class="line" id="L4809">        <span class="tok-kw">var</span> new_offset: wasi.filesize_t = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L4810">        <span class="tok-kw">switch</span> (wasi.fd_seek(fd, offset, .CUR, &amp;new_offset)) {</span>
<span class="line" id="L4811">            .SUCCESS =&gt; <span class="tok-kw">return</span>,</span>
<span class="line" id="L4812">            .BADF =&gt; <span class="tok-kw">unreachable</span>, <span class="tok-comment">// always a race condition</span>
</span>
<span class="line" id="L4813">            .INVAL =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.Unseekable,</span>
<span class="line" id="L4814">            .OVERFLOW =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.Unseekable,</span>
<span class="line" id="L4815">            .SPIPE =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.Unseekable,</span>
<span class="line" id="L4816">            .NXIO =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.Unseekable,</span>
<span class="line" id="L4817">            .NOTCAPABLE =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.AccessDenied,</span>
<span class="line" id="L4818">            <span class="tok-kw">else</span> =&gt; |err| <span class="tok-kw">return</span> unexpectedErrno(err),</span>
<span class="line" id="L4819">        }</span>
<span class="line" id="L4820">    }</span>
<span class="line" id="L4821">    <span class="tok-kw">const</span> lseek_sym = <span class="tok-kw">if</span> (builtin.os.tag == .linux <span class="tok-kw">and</span> builtin.link_libc)</span>
<span class="line" id="L4822">        system.lseek64</span>
<span class="line" id="L4823">    <span class="tok-kw">else</span></span>
<span class="line" id="L4824">        system.lseek;</span>
<span class="line" id="L4825"></span>
<span class="line" id="L4826">    <span class="tok-kw">const</span> ioffset = <span class="tok-builtin">@bitCast</span>(<span class="tok-type">i64</span>, offset); <span class="tok-comment">// the OS treats this as unsigned</span>
</span>
<span class="line" id="L4827">    <span class="tok-kw">switch</span> (errno(lseek_sym(fd, ioffset, SEEK.CUR))) {</span>
<span class="line" id="L4828">        .SUCCESS =&gt; <span class="tok-kw">return</span>,</span>
<span class="line" id="L4829">        .BADF =&gt; <span class="tok-kw">unreachable</span>, <span class="tok-comment">// always a race condition</span>
</span>
<span class="line" id="L4830">        .INVAL =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.Unseekable,</span>
<span class="line" id="L4831">        .OVERFLOW =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.Unseekable,</span>
<span class="line" id="L4832">        .SPIPE =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.Unseekable,</span>
<span class="line" id="L4833">        .NXIO =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.Unseekable,</span>
<span class="line" id="L4834">        <span class="tok-kw">else</span> =&gt; |err| <span class="tok-kw">return</span> unexpectedErrno(err),</span>
<span class="line" id="L4835">    }</span>
<span class="line" id="L4836">}</span>
<span class="line" id="L4837"></span>
<span class="line" id="L4838"><span class="tok-comment">/// Repositions read/write file offset relative to the end.</span></span>
<span class="line" id="L4839"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">lseek_END</span>(fd: fd_t, offset: <span class="tok-type">i64</span>) SeekError!<span class="tok-type">void</span> {</span>
<span class="line" id="L4840">    <span class="tok-kw">if</span> (builtin.os.tag == .linux <span class="tok-kw">and</span> !builtin.link_libc <span class="tok-kw">and</span> <span class="tok-builtin">@sizeOf</span>(<span class="tok-type">usize</span>) == <span class="tok-number">4</span>) {</span>
<span class="line" id="L4841">        <span class="tok-kw">var</span> result: <span class="tok-type">u64</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L4842">        <span class="tok-kw">switch</span> (errno(system.llseek(fd, <span class="tok-builtin">@bitCast</span>(<span class="tok-type">u64</span>, offset), &amp;result, SEEK.END))) {</span>
<span class="line" id="L4843">            .SUCCESS =&gt; <span class="tok-kw">return</span>,</span>
<span class="line" id="L4844">            .BADF =&gt; <span class="tok-kw">unreachable</span>, <span class="tok-comment">// always a race condition</span>
</span>
<span class="line" id="L4845">            .INVAL =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.Unseekable,</span>
<span class="line" id="L4846">            .OVERFLOW =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.Unseekable,</span>
<span class="line" id="L4847">            .SPIPE =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.Unseekable,</span>
<span class="line" id="L4848">            .NXIO =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.Unseekable,</span>
<span class="line" id="L4849">            <span class="tok-kw">else</span> =&gt; |err| <span class="tok-kw">return</span> unexpectedErrno(err),</span>
<span class="line" id="L4850">        }</span>
<span class="line" id="L4851">    }</span>
<span class="line" id="L4852">    <span class="tok-kw">if</span> (builtin.os.tag == .windows) {</span>
<span class="line" id="L4853">        <span class="tok-kw">return</span> windows.SetFilePointerEx_END(fd, offset);</span>
<span class="line" id="L4854">    }</span>
<span class="line" id="L4855">    <span class="tok-kw">if</span> (builtin.os.tag == .wasi <span class="tok-kw">and</span> !builtin.link_libc) {</span>
<span class="line" id="L4856">        <span class="tok-kw">var</span> new_offset: wasi.filesize_t = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L4857">        <span class="tok-kw">switch</span> (wasi.fd_seek(fd, offset, .END, &amp;new_offset)) {</span>
<span class="line" id="L4858">            .SUCCESS =&gt; <span class="tok-kw">return</span>,</span>
<span class="line" id="L4859">            .BADF =&gt; <span class="tok-kw">unreachable</span>, <span class="tok-comment">// always a race condition</span>
</span>
<span class="line" id="L4860">            .INVAL =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.Unseekable,</span>
<span class="line" id="L4861">            .OVERFLOW =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.Unseekable,</span>
<span class="line" id="L4862">            .SPIPE =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.Unseekable,</span>
<span class="line" id="L4863">            .NXIO =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.Unseekable,</span>
<span class="line" id="L4864">            .NOTCAPABLE =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.AccessDenied,</span>
<span class="line" id="L4865">            <span class="tok-kw">else</span> =&gt; |err| <span class="tok-kw">return</span> unexpectedErrno(err),</span>
<span class="line" id="L4866">        }</span>
<span class="line" id="L4867">    }</span>
<span class="line" id="L4868">    <span class="tok-kw">const</span> lseek_sym = <span class="tok-kw">if</span> (builtin.os.tag == .linux <span class="tok-kw">and</span> builtin.link_libc)</span>
<span class="line" id="L4869">        system.lseek64</span>
<span class="line" id="L4870">    <span class="tok-kw">else</span></span>
<span class="line" id="L4871">        system.lseek;</span>
<span class="line" id="L4872"></span>
<span class="line" id="L4873">    <span class="tok-kw">const</span> ioffset = <span class="tok-builtin">@bitCast</span>(<span class="tok-type">i64</span>, offset); <span class="tok-comment">// the OS treats this as unsigned</span>
</span>
<span class="line" id="L4874">    <span class="tok-kw">switch</span> (errno(lseek_sym(fd, ioffset, SEEK.END))) {</span>
<span class="line" id="L4875">        .SUCCESS =&gt; <span class="tok-kw">return</span>,</span>
<span class="line" id="L4876">        .BADF =&gt; <span class="tok-kw">unreachable</span>, <span class="tok-comment">// always a race condition</span>
</span>
<span class="line" id="L4877">        .INVAL =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.Unseekable,</span>
<span class="line" id="L4878">        .OVERFLOW =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.Unseekable,</span>
<span class="line" id="L4879">        .SPIPE =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.Unseekable,</span>
<span class="line" id="L4880">        .NXIO =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.Unseekable,</span>
<span class="line" id="L4881">        <span class="tok-kw">else</span> =&gt; |err| <span class="tok-kw">return</span> unexpectedErrno(err),</span>
<span class="line" id="L4882">    }</span>
<span class="line" id="L4883">}</span>
<span class="line" id="L4884"></span>
<span class="line" id="L4885"><span class="tok-comment">/// Returns the read/write file offset relative to the beginning.</span></span>
<span class="line" id="L4886"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">lseek_CUR_get</span>(fd: fd_t) SeekError!<span class="tok-type">u64</span> {</span>
<span class="line" id="L4887">    <span class="tok-kw">if</span> (builtin.os.tag == .linux <span class="tok-kw">and</span> !builtin.link_libc <span class="tok-kw">and</span> <span class="tok-builtin">@sizeOf</span>(<span class="tok-type">usize</span>) == <span class="tok-number">4</span>) {</span>
<span class="line" id="L4888">        <span class="tok-kw">var</span> result: <span class="tok-type">u64</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L4889">        <span class="tok-kw">switch</span> (errno(system.llseek(fd, <span class="tok-number">0</span>, &amp;result, SEEK.CUR))) {</span>
<span class="line" id="L4890">            .SUCCESS =&gt; <span class="tok-kw">return</span> result,</span>
<span class="line" id="L4891">            .BADF =&gt; <span class="tok-kw">unreachable</span>, <span class="tok-comment">// always a race condition</span>
</span>
<span class="line" id="L4892">            .INVAL =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.Unseekable,</span>
<span class="line" id="L4893">            .OVERFLOW =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.Unseekable,</span>
<span class="line" id="L4894">            .SPIPE =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.Unseekable,</span>
<span class="line" id="L4895">            .NXIO =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.Unseekable,</span>
<span class="line" id="L4896">            <span class="tok-kw">else</span> =&gt; |err| <span class="tok-kw">return</span> unexpectedErrno(err),</span>
<span class="line" id="L4897">        }</span>
<span class="line" id="L4898">    }</span>
<span class="line" id="L4899">    <span class="tok-kw">if</span> (builtin.os.tag == .windows) {</span>
<span class="line" id="L4900">        <span class="tok-kw">return</span> windows.SetFilePointerEx_CURRENT_get(fd);</span>
<span class="line" id="L4901">    }</span>
<span class="line" id="L4902">    <span class="tok-kw">if</span> (builtin.os.tag == .wasi <span class="tok-kw">and</span> !builtin.link_libc) {</span>
<span class="line" id="L4903">        <span class="tok-kw">var</span> new_offset: wasi.filesize_t = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L4904">        <span class="tok-kw">switch</span> (wasi.fd_seek(fd, <span class="tok-number">0</span>, .CUR, &amp;new_offset)) {</span>
<span class="line" id="L4905">            .SUCCESS =&gt; <span class="tok-kw">return</span> new_offset,</span>
<span class="line" id="L4906">            .BADF =&gt; <span class="tok-kw">unreachable</span>, <span class="tok-comment">// always a race condition</span>
</span>
<span class="line" id="L4907">            .INVAL =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.Unseekable,</span>
<span class="line" id="L4908">            .OVERFLOW =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.Unseekable,</span>
<span class="line" id="L4909">            .SPIPE =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.Unseekable,</span>
<span class="line" id="L4910">            .NXIO =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.Unseekable,</span>
<span class="line" id="L4911">            .NOTCAPABLE =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.AccessDenied,</span>
<span class="line" id="L4912">            <span class="tok-kw">else</span> =&gt; |err| <span class="tok-kw">return</span> unexpectedErrno(err),</span>
<span class="line" id="L4913">        }</span>
<span class="line" id="L4914">    }</span>
<span class="line" id="L4915">    <span class="tok-kw">const</span> lseek_sym = <span class="tok-kw">if</span> (builtin.os.tag == .linux <span class="tok-kw">and</span> builtin.link_libc)</span>
<span class="line" id="L4916">        system.lseek64</span>
<span class="line" id="L4917">    <span class="tok-kw">else</span></span>
<span class="line" id="L4918">        system.lseek;</span>
<span class="line" id="L4919"></span>
<span class="line" id="L4920">    <span class="tok-kw">const</span> rc = lseek_sym(fd, <span class="tok-number">0</span>, SEEK.CUR);</span>
<span class="line" id="L4921">    <span class="tok-kw">switch</span> (errno(rc)) {</span>
<span class="line" id="L4922">        .SUCCESS =&gt; <span class="tok-kw">return</span> <span class="tok-builtin">@bitCast</span>(<span class="tok-type">u64</span>, rc),</span>
<span class="line" id="L4923">        .BADF =&gt; <span class="tok-kw">unreachable</span>, <span class="tok-comment">// always a race condition</span>
</span>
<span class="line" id="L4924">        .INVAL =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.Unseekable,</span>
<span class="line" id="L4925">        .OVERFLOW =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.Unseekable,</span>
<span class="line" id="L4926">        .SPIPE =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.Unseekable,</span>
<span class="line" id="L4927">        .NXIO =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.Unseekable,</span>
<span class="line" id="L4928">        <span class="tok-kw">else</span> =&gt; |err| <span class="tok-kw">return</span> unexpectedErrno(err),</span>
<span class="line" id="L4929">    }</span>
<span class="line" id="L4930">}</span>
<span class="line" id="L4931"></span>
<span class="line" id="L4932"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> FcntlError = <span class="tok-kw">error</span>{</span>
<span class="line" id="L4933">    PermissionDenied,</span>
<span class="line" id="L4934">    FileBusy,</span>
<span class="line" id="L4935">    ProcessFdQuotaExceeded,</span>
<span class="line" id="L4936">    Locked,</span>
<span class="line" id="L4937">    DeadLock,</span>
<span class="line" id="L4938">    LockedRegionLimitExceeded,</span>
<span class="line" id="L4939">} || UnexpectedError;</span>
<span class="line" id="L4940"></span>
<span class="line" id="L4941"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">fcntl</span>(fd: fd_t, cmd: <span class="tok-type">i32</span>, arg: <span class="tok-type">usize</span>) FcntlError!<span class="tok-type">usize</span> {</span>
<span class="line" id="L4942">    <span class="tok-kw">while</span> (<span class="tok-null">true</span>) {</span>
<span class="line" id="L4943">        <span class="tok-kw">const</span> rc = system.fcntl(fd, cmd, arg);</span>
<span class="line" id="L4944">        <span class="tok-kw">switch</span> (errno(rc)) {</span>
<span class="line" id="L4945">            .SUCCESS =&gt; <span class="tok-kw">return</span> <span class="tok-builtin">@intCast</span>(<span class="tok-type">usize</span>, rc),</span>
<span class="line" id="L4946">            .INTR =&gt; <span class="tok-kw">continue</span>,</span>
<span class="line" id="L4947">            .AGAIN, .ACCES =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.Locked,</span>
<span class="line" id="L4948">            .BADF =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L4949">            .BUSY =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.FileBusy,</span>
<span class="line" id="L4950">            .INVAL =&gt; <span class="tok-kw">unreachable</span>, <span class="tok-comment">// invalid parameters</span>
</span>
<span class="line" id="L4951">            .PERM =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.PermissionDenied,</span>
<span class="line" id="L4952">            .MFILE =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.ProcessFdQuotaExceeded,</span>
<span class="line" id="L4953">            .NOTDIR =&gt; <span class="tok-kw">unreachable</span>, <span class="tok-comment">// invalid parameter</span>
</span>
<span class="line" id="L4954">            .DEADLK =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.DeadLock,</span>
<span class="line" id="L4955">            .NOLCK =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.LockedRegionLimitExceeded,</span>
<span class="line" id="L4956">            <span class="tok-kw">else</span> =&gt; |err| <span class="tok-kw">return</span> unexpectedErrno(err),</span>
<span class="line" id="L4957">        }</span>
<span class="line" id="L4958">    }</span>
<span class="line" id="L4959">}</span>
<span class="line" id="L4960"></span>
<span class="line" id="L4961"><span class="tok-kw">fn</span> <span class="tok-fn">setSockFlags</span>(sock: socket_t, flags: <span class="tok-type">u32</span>) !<span class="tok-type">void</span> {</span>
<span class="line" id="L4962">    <span class="tok-kw">if</span> ((flags &amp; SOCK.CLOEXEC) != <span class="tok-number">0</span>) {</span>
<span class="line" id="L4963">        <span class="tok-kw">if</span> (builtin.os.tag == .windows) {</span>
<span class="line" id="L4964">            <span class="tok-comment">// TODO: Find out if this is supported for sockets</span>
</span>
<span class="line" id="L4965">        } <span class="tok-kw">else</span> {</span>
<span class="line" id="L4966">            <span class="tok-kw">var</span> fd_flags = fcntl(sock, F.GETFD, <span class="tok-number">0</span>) <span class="tok-kw">catch</span> |err| <span class="tok-kw">switch</span> (err) {</span>
<span class="line" id="L4967">                <span class="tok-kw">error</span>.FileBusy =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L4968">                <span class="tok-kw">error</span>.Locked =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L4969">                <span class="tok-kw">error</span>.PermissionDenied =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L4970">                <span class="tok-kw">error</span>.DeadLock =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L4971">                <span class="tok-kw">error</span>.LockedRegionLimitExceeded =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L4972">                <span class="tok-kw">else</span> =&gt; |e| <span class="tok-kw">return</span> e,</span>
<span class="line" id="L4973">            };</span>
<span class="line" id="L4974">            fd_flags |= FD_CLOEXEC;</span>
<span class="line" id="L4975">            _ = fcntl(sock, F.SETFD, fd_flags) <span class="tok-kw">catch</span> |err| <span class="tok-kw">switch</span> (err) {</span>
<span class="line" id="L4976">                <span class="tok-kw">error</span>.FileBusy =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L4977">                <span class="tok-kw">error</span>.Locked =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L4978">                <span class="tok-kw">error</span>.PermissionDenied =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L4979">                <span class="tok-kw">error</span>.DeadLock =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L4980">                <span class="tok-kw">error</span>.LockedRegionLimitExceeded =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L4981">                <span class="tok-kw">else</span> =&gt; |e| <span class="tok-kw">return</span> e,</span>
<span class="line" id="L4982">            };</span>
<span class="line" id="L4983">        }</span>
<span class="line" id="L4984">    }</span>
<span class="line" id="L4985">    <span class="tok-kw">if</span> ((flags &amp; SOCK.NONBLOCK) != <span class="tok-number">0</span>) {</span>
<span class="line" id="L4986">        <span class="tok-kw">if</span> (builtin.os.tag == .windows) {</span>
<span class="line" id="L4987">            <span class="tok-kw">var</span> mode: <span class="tok-type">c_ulong</span> = <span class="tok-number">1</span>;</span>
<span class="line" id="L4988">            <span class="tok-kw">if</span> (windows.ws2_32.ioctlsocket(sock, windows.ws2_32.FIONBIO, &amp;mode) == windows.ws2_32.SOCKET_ERROR) {</span>
<span class="line" id="L4989">                <span class="tok-kw">switch</span> (windows.ws2_32.WSAGetLastError()) {</span>
<span class="line" id="L4990">                    .WSANOTINITIALISED =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L4991">                    .WSAENETDOWN =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.NetworkSubsystemFailed,</span>
<span class="line" id="L4992">                    .WSAENOTSOCK =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.FileDescriptorNotASocket,</span>
<span class="line" id="L4993">                    <span class="tok-comment">// TODO: handle more errors</span>
</span>
<span class="line" id="L4994">                    <span class="tok-kw">else</span> =&gt; |err| <span class="tok-kw">return</span> windows.unexpectedWSAError(err),</span>
<span class="line" id="L4995">                }</span>
<span class="line" id="L4996">            }</span>
<span class="line" id="L4997">        } <span class="tok-kw">else</span> {</span>
<span class="line" id="L4998">            <span class="tok-kw">var</span> fl_flags = fcntl(sock, F.GETFL, <span class="tok-number">0</span>) <span class="tok-kw">catch</span> |err| <span class="tok-kw">switch</span> (err) {</span>
<span class="line" id="L4999">                <span class="tok-kw">error</span>.FileBusy =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L5000">                <span class="tok-kw">error</span>.Locked =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L5001">                <span class="tok-kw">error</span>.PermissionDenied =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L5002">                <span class="tok-kw">error</span>.DeadLock =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L5003">                <span class="tok-kw">error</span>.LockedRegionLimitExceeded =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L5004">                <span class="tok-kw">else</span> =&gt; |e| <span class="tok-kw">return</span> e,</span>
<span class="line" id="L5005">            };</span>
<span class="line" id="L5006">            fl_flags |= O.NONBLOCK;</span>
<span class="line" id="L5007">            _ = fcntl(sock, F.SETFL, fl_flags) <span class="tok-kw">catch</span> |err| <span class="tok-kw">switch</span> (err) {</span>
<span class="line" id="L5008">                <span class="tok-kw">error</span>.FileBusy =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L5009">                <span class="tok-kw">error</span>.Locked =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L5010">                <span class="tok-kw">error</span>.PermissionDenied =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L5011">                <span class="tok-kw">error</span>.DeadLock =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L5012">                <span class="tok-kw">error</span>.LockedRegionLimitExceeded =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L5013">                <span class="tok-kw">else</span> =&gt; |e| <span class="tok-kw">return</span> e,</span>
<span class="line" id="L5014">            };</span>
<span class="line" id="L5015">        }</span>
<span class="line" id="L5016">    }</span>
<span class="line" id="L5017">}</span>
<span class="line" id="L5018"></span>
<span class="line" id="L5019"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> FlockError = <span class="tok-kw">error</span>{</span>
<span class="line" id="L5020">    WouldBlock,</span>
<span class="line" id="L5021"></span>
<span class="line" id="L5022">    <span class="tok-comment">/// The kernel ran out of memory for allocating file locks</span></span>
<span class="line" id="L5023">    SystemResources,</span>
<span class="line" id="L5024"></span>
<span class="line" id="L5025">    <span class="tok-comment">/// The underlying filesystem does not support file locks</span></span>
<span class="line" id="L5026">    FileLocksNotSupported,</span>
<span class="line" id="L5027">} || UnexpectedError;</span>
<span class="line" id="L5028"></span>
<span class="line" id="L5029"><span class="tok-comment">/// Depending on the operating system `flock` may or may not interact with</span></span>
<span class="line" id="L5030"><span class="tok-comment">/// `fcntl` locks made by other processes.</span></span>
<span class="line" id="L5031"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">flock</span>(fd: fd_t, operation: <span class="tok-type">i32</span>) FlockError!<span class="tok-type">void</span> {</span>
<span class="line" id="L5032">    <span class="tok-kw">while</span> (<span class="tok-null">true</span>) {</span>
<span class="line" id="L5033">        <span class="tok-kw">const</span> rc = system.flock(fd, operation);</span>
<span class="line" id="L5034">        <span class="tok-kw">switch</span> (errno(rc)) {</span>
<span class="line" id="L5035">            .SUCCESS =&gt; <span class="tok-kw">return</span>,</span>
<span class="line" id="L5036">            .BADF =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L5037">            .INTR =&gt; <span class="tok-kw">continue</span>,</span>
<span class="line" id="L5038">            .INVAL =&gt; <span class="tok-kw">unreachable</span>, <span class="tok-comment">// invalid parameters</span>
</span>
<span class="line" id="L5039">            .NOLCK =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.SystemResources,</span>
<span class="line" id="L5040">            .AGAIN =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.WouldBlock, <span class="tok-comment">// TODO: integrate with async instead of just returning an error</span>
</span>
<span class="line" id="L5041">            .OPNOTSUPP =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.FileLocksNotSupported,</span>
<span class="line" id="L5042">            <span class="tok-kw">else</span> =&gt; |err| <span class="tok-kw">return</span> unexpectedErrno(err),</span>
<span class="line" id="L5043">        }</span>
<span class="line" id="L5044">    }</span>
<span class="line" id="L5045">}</span>
<span class="line" id="L5046"></span>
<span class="line" id="L5047"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> RealPathError = <span class="tok-kw">error</span>{</span>
<span class="line" id="L5048">    FileNotFound,</span>
<span class="line" id="L5049">    AccessDenied,</span>
<span class="line" id="L5050">    NameTooLong,</span>
<span class="line" id="L5051">    NotSupported,</span>
<span class="line" id="L5052">    NotDir,</span>
<span class="line" id="L5053">    SymLinkLoop,</span>
<span class="line" id="L5054">    InputOutput,</span>
<span class="line" id="L5055">    FileTooBig,</span>
<span class="line" id="L5056">    IsDir,</span>
<span class="line" id="L5057">    ProcessFdQuotaExceeded,</span>
<span class="line" id="L5058">    SystemFdQuotaExceeded,</span>
<span class="line" id="L5059">    NoDevice,</span>
<span class="line" id="L5060">    SystemResources,</span>
<span class="line" id="L5061">    NoSpaceLeft,</span>
<span class="line" id="L5062">    FileSystem,</span>
<span class="line" id="L5063">    BadPathName,</span>
<span class="line" id="L5064">    DeviceBusy,</span>
<span class="line" id="L5065"></span>
<span class="line" id="L5066">    SharingViolation,</span>
<span class="line" id="L5067">    PipeBusy,</span>
<span class="line" id="L5068"></span>
<span class="line" id="L5069">    <span class="tok-comment">/// On WASI, the current CWD may not be associated with an absolute path.</span></span>
<span class="line" id="L5070">    InvalidHandle,</span>
<span class="line" id="L5071"></span>
<span class="line" id="L5072">    <span class="tok-comment">/// On Windows, file paths must be valid Unicode.</span></span>
<span class="line" id="L5073">    InvalidUtf8,</span>
<span class="line" id="L5074"></span>
<span class="line" id="L5075">    PathAlreadyExists,</span>
<span class="line" id="L5076">} || UnexpectedError;</span>
<span class="line" id="L5077"></span>
<span class="line" id="L5078"><span class="tok-comment">/// Return the canonicalized absolute pathname.</span></span>
<span class="line" id="L5079"><span class="tok-comment">/// Expands all symbolic links and resolves references to `.`, `..`, and</span></span>
<span class="line" id="L5080"><span class="tok-comment">/// extra `/` characters in `pathname`.</span></span>
<span class="line" id="L5081"><span class="tok-comment">/// The return value is a slice of `out_buffer`, but not necessarily from the beginning.</span></span>
<span class="line" id="L5082"><span class="tok-comment">/// See also `realpathZ` and `realpathW`.</span></span>
<span class="line" id="L5083"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">realpath</span>(pathname: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>, out_buffer: *[MAX_PATH_BYTES]<span class="tok-type">u8</span>) RealPathError![]<span class="tok-type">u8</span> {</span>
<span class="line" id="L5084">    <span class="tok-kw">if</span> (builtin.os.tag == .windows) {</span>
<span class="line" id="L5085">        <span class="tok-kw">const</span> pathname_w = <span class="tok-kw">try</span> windows.sliceToPrefixedFileW(pathname);</span>
<span class="line" id="L5086">        <span class="tok-kw">return</span> realpathW(pathname_w.span(), out_buffer);</span>
<span class="line" id="L5087">    } <span class="tok-kw">else</span> <span class="tok-kw">if</span> (builtin.os.tag == .wasi <span class="tok-kw">and</span> !builtin.link_libc) {</span>
<span class="line" id="L5088">        <span class="tok-kw">var</span> alloc = std.heap.FixedBufferAllocator.init(out_buffer);</span>
<span class="line" id="L5089"></span>
<span class="line" id="L5090">        <span class="tok-comment">// NOTE: This emulation is incomplete. Symbolic links are not</span>
</span>
<span class="line" id="L5091">        <span class="tok-comment">//       currently expanded during path canonicalization.</span>
</span>
<span class="line" id="L5092">        <span class="tok-kw">const</span> paths = &amp;.{ wasi_cwd.cwd, pathname };</span>
<span class="line" id="L5093">        <span class="tok-kw">return</span> fs.path.resolve(alloc.allocator(), paths) <span class="tok-kw">catch</span> <span class="tok-kw">error</span>.NameTooLong;</span>
<span class="line" id="L5094">    }</span>
<span class="line" id="L5095">    <span class="tok-kw">const</span> pathname_c = <span class="tok-kw">try</span> toPosixPath(pathname);</span>
<span class="line" id="L5096">    <span class="tok-kw">return</span> realpathZ(&amp;pathname_c, out_buffer);</span>
<span class="line" id="L5097">}</span>
<span class="line" id="L5098"></span>
<span class="line" id="L5099"><span class="tok-comment">/// Same as `realpath` except `pathname` is null-terminated.</span></span>
<span class="line" id="L5100"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">realpathZ</span>(pathname: [*:<span class="tok-number">0</span>]<span class="tok-kw">const</span> <span class="tok-type">u8</span>, out_buffer: *[MAX_PATH_BYTES]<span class="tok-type">u8</span>) RealPathError![]<span class="tok-type">u8</span> {</span>
<span class="line" id="L5101">    <span class="tok-kw">if</span> (builtin.os.tag == .windows) {</span>
<span class="line" id="L5102">        <span class="tok-kw">const</span> pathname_w = <span class="tok-kw">try</span> windows.cStrToPrefixedFileW(pathname);</span>
<span class="line" id="L5103">        <span class="tok-kw">return</span> realpathW(pathname_w.span(), out_buffer);</span>
<span class="line" id="L5104">    } <span class="tok-kw">else</span> <span class="tok-kw">if</span> (builtin.os.tag == .wasi <span class="tok-kw">and</span> !builtin.link_libc) {</span>
<span class="line" id="L5105">        <span class="tok-kw">return</span> realpath(mem.sliceTo(pathname, <span class="tok-number">0</span>), out_buffer);</span>
<span class="line" id="L5106">    }</span>
<span class="line" id="L5107">    <span class="tok-kw">if</span> (!builtin.link_libc) {</span>
<span class="line" id="L5108">        <span class="tok-kw">const</span> flags = <span class="tok-kw">if</span> (builtin.os.tag == .linux) O.PATH | O.NONBLOCK | O.CLOEXEC <span class="tok-kw">else</span> O.NONBLOCK | O.CLOEXEC;</span>
<span class="line" id="L5109">        <span class="tok-kw">const</span> fd = openZ(pathname, flags, <span class="tok-number">0</span>) <span class="tok-kw">catch</span> |err| <span class="tok-kw">switch</span> (err) {</span>
<span class="line" id="L5110">            <span class="tok-kw">error</span>.FileLocksNotSupported =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L5111">            <span class="tok-kw">error</span>.WouldBlock =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L5112">            <span class="tok-kw">error</span>.FileBusy =&gt; <span class="tok-kw">unreachable</span>, <span class="tok-comment">// not asking for write permissions</span>
</span>
<span class="line" id="L5113">            <span class="tok-kw">error</span>.InvalidHandle =&gt; <span class="tok-kw">unreachable</span>, <span class="tok-comment">// WASI-only</span>
</span>
<span class="line" id="L5114">            <span class="tok-kw">else</span> =&gt; |e| <span class="tok-kw">return</span> e,</span>
<span class="line" id="L5115">        };</span>
<span class="line" id="L5116">        <span class="tok-kw">defer</span> close(fd);</span>
<span class="line" id="L5117"></span>
<span class="line" id="L5118">        <span class="tok-kw">return</span> getFdPath(fd, out_buffer);</span>
<span class="line" id="L5119">    }</span>
<span class="line" id="L5120">    <span class="tok-kw">const</span> result_path = std.c.realpath(pathname, out_buffer) <span class="tok-kw">orelse</span> <span class="tok-kw">switch</span> (<span class="tok-builtin">@intToEnum</span>(E, std.c._errno().*)) {</span>
<span class="line" id="L5121">        .SUCCESS =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L5122">        .INVAL =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L5123">        .BADF =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L5124">        .FAULT =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L5125">        .ACCES =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.AccessDenied,</span>
<span class="line" id="L5126">        .NOENT =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.FileNotFound,</span>
<span class="line" id="L5127">        .OPNOTSUPP =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.NotSupported,</span>
<span class="line" id="L5128">        .NOTDIR =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.NotDir,</span>
<span class="line" id="L5129">        .NAMETOOLONG =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.NameTooLong,</span>
<span class="line" id="L5130">        .LOOP =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.SymLinkLoop,</span>
<span class="line" id="L5131">        .IO =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.InputOutput,</span>
<span class="line" id="L5132">        <span class="tok-kw">else</span> =&gt; |err| <span class="tok-kw">return</span> unexpectedErrno(err),</span>
<span class="line" id="L5133">    };</span>
<span class="line" id="L5134">    <span class="tok-kw">return</span> mem.sliceTo(result_path, <span class="tok-number">0</span>);</span>
<span class="line" id="L5135">}</span>
<span class="line" id="L5136"></span>
<span class="line" id="L5137"><span class="tok-comment">/// Same as `realpath` except `pathname` is UTF16LE-encoded.</span></span>
<span class="line" id="L5138"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">realpathW</span>(pathname: []<span class="tok-kw">const</span> <span class="tok-type">u16</span>, out_buffer: *[MAX_PATH_BYTES]<span class="tok-type">u8</span>) RealPathError![]<span class="tok-type">u8</span> {</span>
<span class="line" id="L5139">    <span class="tok-kw">const</span> w = windows;</span>
<span class="line" id="L5140"></span>
<span class="line" id="L5141">    <span class="tok-kw">const</span> dir = std.fs.cwd().fd;</span>
<span class="line" id="L5142">    <span class="tok-kw">const</span> access_mask = w.GENERIC_READ | w.SYNCHRONIZE;</span>
<span class="line" id="L5143">    <span class="tok-kw">const</span> share_access = w.FILE_SHARE_READ;</span>
<span class="line" id="L5144">    <span class="tok-kw">const</span> creation = w.FILE_OPEN;</span>
<span class="line" id="L5145">    <span class="tok-kw">const</span> h_file = blk: {</span>
<span class="line" id="L5146">        <span class="tok-kw">const</span> res = w.OpenFile(pathname, .{</span>
<span class="line" id="L5147">            .dir = dir,</span>
<span class="line" id="L5148">            .access_mask = access_mask,</span>
<span class="line" id="L5149">            .share_access = share_access,</span>
<span class="line" id="L5150">            .creation = creation,</span>
<span class="line" id="L5151">            .io_mode = .blocking,</span>
<span class="line" id="L5152">        }) <span class="tok-kw">catch</span> |err| <span class="tok-kw">switch</span> (err) {</span>
<span class="line" id="L5153">            <span class="tok-kw">error</span>.IsDir =&gt; <span class="tok-kw">break</span> :blk w.OpenFile(pathname, .{</span>
<span class="line" id="L5154">                .dir = dir,</span>
<span class="line" id="L5155">                .access_mask = access_mask,</span>
<span class="line" id="L5156">                .share_access = share_access,</span>
<span class="line" id="L5157">                .creation = creation,</span>
<span class="line" id="L5158">                .io_mode = .blocking,</span>
<span class="line" id="L5159">                .filter = .dir_only,</span>
<span class="line" id="L5160">            }) <span class="tok-kw">catch</span> |er| <span class="tok-kw">switch</span> (er) {</span>
<span class="line" id="L5161">                <span class="tok-kw">error</span>.WouldBlock =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L5162">                <span class="tok-kw">else</span> =&gt; |e2| <span class="tok-kw">return</span> e2,</span>
<span class="line" id="L5163">            },</span>
<span class="line" id="L5164">            <span class="tok-kw">error</span>.WouldBlock =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L5165">            <span class="tok-kw">else</span> =&gt; |e| <span class="tok-kw">return</span> e,</span>
<span class="line" id="L5166">        };</span>
<span class="line" id="L5167">        <span class="tok-kw">break</span> :blk res;</span>
<span class="line" id="L5168">    };</span>
<span class="line" id="L5169">    <span class="tok-kw">defer</span> w.CloseHandle(h_file);</span>
<span class="line" id="L5170"></span>
<span class="line" id="L5171">    <span class="tok-kw">return</span> getFdPath(h_file, out_buffer);</span>
<span class="line" id="L5172">}</span>
<span class="line" id="L5173"></span>
<span class="line" id="L5174"><span class="tok-comment">/// Return canonical path of handle `fd`.</span></span>
<span class="line" id="L5175"><span class="tok-comment">/// This function is very host-specific and is not universally supported by all hosts.</span></span>
<span class="line" id="L5176"><span class="tok-comment">/// For example, while it generally works on Linux, macOS, FreeBSD or Windows, it is</span></span>
<span class="line" id="L5177"><span class="tok-comment">/// unsupported on WASI.</span></span>
<span class="line" id="L5178"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">getFdPath</span>(fd: fd_t, out_buffer: *[MAX_PATH_BYTES]<span class="tok-type">u8</span>) RealPathError![]<span class="tok-type">u8</span> {</span>
<span class="line" id="L5179">    <span class="tok-kw">switch</span> (builtin.os.tag) {</span>
<span class="line" id="L5180">        .windows =&gt; {</span>
<span class="line" id="L5181">            <span class="tok-kw">var</span> wide_buf: [windows.PATH_MAX_WIDE]<span class="tok-type">u16</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L5182">            <span class="tok-kw">const</span> wide_slice = <span class="tok-kw">try</span> windows.GetFinalPathNameByHandle(fd, .{}, wide_buf[<span class="tok-number">0</span>..]);</span>
<span class="line" id="L5183"></span>
<span class="line" id="L5184">            <span class="tok-comment">// Trust that Windows gives us valid UTF-16LE.</span>
</span>
<span class="line" id="L5185">            <span class="tok-kw">const</span> end_index = std.unicode.utf16leToUtf8(out_buffer, wide_slice) <span class="tok-kw">catch</span> <span class="tok-kw">unreachable</span>;</span>
<span class="line" id="L5186">            <span class="tok-kw">return</span> out_buffer[<span class="tok-number">0</span>..end_index];</span>
<span class="line" id="L5187">        },</span>
<span class="line" id="L5188">        .macos, .ios, .watchos, .tvos =&gt; {</span>
<span class="line" id="L5189">            <span class="tok-comment">// On macOS, we can use F.GETPATH fcntl command to query the OS for</span>
</span>
<span class="line" id="L5190">            <span class="tok-comment">// the path to the file descriptor.</span>
</span>
<span class="line" id="L5191">            <span class="tok-builtin">@memset</span>(out_buffer, <span class="tok-number">0</span>, MAX_PATH_BYTES);</span>
<span class="line" id="L5192">            <span class="tok-kw">switch</span> (errno(system.fcntl(fd, F.GETPATH, out_buffer))) {</span>
<span class="line" id="L5193">                .SUCCESS =&gt; {},</span>
<span class="line" id="L5194">                .BADF =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.FileNotFound,</span>
<span class="line" id="L5195">                <span class="tok-comment">// TODO man pages for fcntl on macOS don't really tell you what</span>
</span>
<span class="line" id="L5196">                <span class="tok-comment">// errno values to expect when command is F.GETPATH...</span>
</span>
<span class="line" id="L5197">                <span class="tok-kw">else</span> =&gt; |err| <span class="tok-kw">return</span> unexpectedErrno(err),</span>
<span class="line" id="L5198">            }</span>
<span class="line" id="L5199">            <span class="tok-kw">const</span> len = mem.indexOfScalar(<span class="tok-type">u8</span>, out_buffer[<span class="tok-number">0</span>..], <span class="tok-builtin">@as</span>(<span class="tok-type">u8</span>, <span class="tok-number">0</span>)) <span class="tok-kw">orelse</span> MAX_PATH_BYTES;</span>
<span class="line" id="L5200">            <span class="tok-kw">return</span> out_buffer[<span class="tok-number">0</span>..len];</span>
<span class="line" id="L5201">        },</span>
<span class="line" id="L5202">        .linux =&gt; {</span>
<span class="line" id="L5203">            <span class="tok-kw">var</span> procfs_buf: [<span class="tok-str">&quot;/proc/self/fd/-2147483648&quot;</span>.len:<span class="tok-number">0</span>]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L5204">            <span class="tok-kw">const</span> proc_path = std.fmt.bufPrint(procfs_buf[<span class="tok-number">0</span>..], <span class="tok-str">&quot;/proc/self/fd/{d}\x00&quot;</span>, .{fd}) <span class="tok-kw">catch</span> <span class="tok-kw">unreachable</span>;</span>
<span class="line" id="L5205"></span>
<span class="line" id="L5206">            <span class="tok-kw">const</span> target = readlinkZ(std.meta.assumeSentinel(proc_path.ptr, <span class="tok-number">0</span>), out_buffer) <span class="tok-kw">catch</span> |err| {</span>
<span class="line" id="L5207">                <span class="tok-kw">switch</span> (err) {</span>
<span class="line" id="L5208">                    <span class="tok-kw">error</span>.UnsupportedReparsePointType =&gt; <span class="tok-kw">unreachable</span>, <span class="tok-comment">// Windows only,</span>
</span>
<span class="line" id="L5209">                    <span class="tok-kw">error</span>.NotLink =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L5210">                    <span class="tok-kw">else</span> =&gt; |e| <span class="tok-kw">return</span> e,</span>
<span class="line" id="L5211">                }</span>
<span class="line" id="L5212">            };</span>
<span class="line" id="L5213">            <span class="tok-kw">return</span> target;</span>
<span class="line" id="L5214">        },</span>
<span class="line" id="L5215">        .solaris =&gt; {</span>
<span class="line" id="L5216">            <span class="tok-kw">var</span> procfs_buf: [<span class="tok-str">&quot;/proc/self/path/-2147483648&quot;</span>.len:<span class="tok-number">0</span>]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L5217">            <span class="tok-kw">const</span> proc_path = std.fmt.bufPrintZ(procfs_buf[<span class="tok-number">0</span>..], <span class="tok-str">&quot;/proc/self/path/{d}&quot;</span>, .{fd}) <span class="tok-kw">catch</span> <span class="tok-kw">unreachable</span>;</span>
<span class="line" id="L5218"></span>
<span class="line" id="L5219">            <span class="tok-kw">const</span> target = readlinkZ(proc_path, out_buffer) <span class="tok-kw">catch</span> |err| <span class="tok-kw">switch</span> (err) {</span>
<span class="line" id="L5220">                <span class="tok-kw">error</span>.UnsupportedReparsePointType =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L5221">                <span class="tok-kw">error</span>.NotLink =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L5222">                <span class="tok-kw">else</span> =&gt; |e| <span class="tok-kw">return</span> e,</span>
<span class="line" id="L5223">            };</span>
<span class="line" id="L5224">            <span class="tok-kw">return</span> target;</span>
<span class="line" id="L5225">        },</span>
<span class="line" id="L5226">        .freebsd =&gt; {</span>
<span class="line" id="L5227">            <span class="tok-kw">comptime</span> <span class="tok-kw">if</span> (builtin.os.version_range.semver.max.order(.{ .major = <span class="tok-number">13</span>, .minor = <span class="tok-number">0</span> }) == .lt)</span>
<span class="line" id="L5228">                <span class="tok-builtin">@compileError</span>(<span class="tok-str">&quot;querying for canonical path of a handle is unsupported on FreeBSD 12 and below&quot;</span>);</span>
<span class="line" id="L5229"></span>
<span class="line" id="L5230">            <span class="tok-kw">var</span> kfile: system.kinfo_file = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L5231">            kfile.structsize = system.KINFO_FILE_SIZE;</span>
<span class="line" id="L5232">            <span class="tok-kw">switch</span> (errno(system.fcntl(fd, system.F.KINFO, <span class="tok-builtin">@ptrToInt</span>(&amp;kfile)))) {</span>
<span class="line" id="L5233">                .SUCCESS =&gt; {},</span>
<span class="line" id="L5234">                .BADF =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.FileNotFound,</span>
<span class="line" id="L5235">                <span class="tok-kw">else</span> =&gt; |err| <span class="tok-kw">return</span> unexpectedErrno(err),</span>
<span class="line" id="L5236">            }</span>
<span class="line" id="L5237"></span>
<span class="line" id="L5238">            <span class="tok-kw">const</span> len = mem.indexOfScalar(<span class="tok-type">u8</span>, &amp;kfile.path, <span class="tok-number">0</span>) <span class="tok-kw">orelse</span> MAX_PATH_BYTES;</span>
<span class="line" id="L5239">            mem.copy(<span class="tok-type">u8</span>, out_buffer, kfile.path[<span class="tok-number">0</span>..len]);</span>
<span class="line" id="L5240">            <span class="tok-kw">return</span> out_buffer[<span class="tok-number">0</span>..len];</span>
<span class="line" id="L5241">        },</span>
<span class="line" id="L5242">        <span class="tok-kw">else</span> =&gt; <span class="tok-builtin">@compileError</span>(<span class="tok-str">&quot;querying for canonical path of a handle is unsupported on this host&quot;</span>),</span>
<span class="line" id="L5243">    }</span>
<span class="line" id="L5244">}</span>
<span class="line" id="L5245"></span>
<span class="line" id="L5246"><span class="tok-comment">/// Spurious wakeups are possible and no precision of timing is guaranteed.</span></span>
<span class="line" id="L5247"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">nanosleep</span>(seconds: <span class="tok-type">u64</span>, nanoseconds: <span class="tok-type">u64</span>) <span class="tok-type">void</span> {</span>
<span class="line" id="L5248">    <span class="tok-kw">var</span> req = timespec{</span>
<span class="line" id="L5249">        .tv_sec = math.cast(<span class="tok-type">isize</span>, seconds) <span class="tok-kw">orelse</span> math.maxInt(<span class="tok-type">isize</span>),</span>
<span class="line" id="L5250">        .tv_nsec = math.cast(<span class="tok-type">isize</span>, nanoseconds) <span class="tok-kw">orelse</span> math.maxInt(<span class="tok-type">isize</span>),</span>
<span class="line" id="L5251">    };</span>
<span class="line" id="L5252">    <span class="tok-kw">var</span> rem: timespec = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L5253">    <span class="tok-kw">while</span> (<span class="tok-null">true</span>) {</span>
<span class="line" id="L5254">        <span class="tok-kw">switch</span> (errno(system.nanosleep(&amp;req, &amp;rem))) {</span>
<span class="line" id="L5255">            .FAULT =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L5256">            .INVAL =&gt; {</span>
<span class="line" id="L5257">                <span class="tok-comment">// Sometimes Darwin returns EINVAL for no reason.</span>
</span>
<span class="line" id="L5258">                <span class="tok-comment">// We treat it as a spurious wakeup.</span>
</span>
<span class="line" id="L5259">                <span class="tok-kw">return</span>;</span>
<span class="line" id="L5260">            },</span>
<span class="line" id="L5261">            .INTR =&gt; {</span>
<span class="line" id="L5262">                req = rem;</span>
<span class="line" id="L5263">                <span class="tok-kw">continue</span>;</span>
<span class="line" id="L5264">            },</span>
<span class="line" id="L5265">            <span class="tok-comment">// This prong handles success as well as unexpected errors.</span>
</span>
<span class="line" id="L5266">            <span class="tok-kw">else</span> =&gt; <span class="tok-kw">return</span>,</span>
<span class="line" id="L5267">        }</span>
<span class="line" id="L5268">    }</span>
<span class="line" id="L5269">}</span>
<span class="line" id="L5270"></span>
<span class="line" id="L5271"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">dl_iterate_phdr</span>(</span>
<span class="line" id="L5272">    context: <span class="tok-kw">anytype</span>,</span>
<span class="line" id="L5273">    <span class="tok-kw">comptime</span> Error: <span class="tok-type">type</span>,</span>
<span class="line" id="L5274">    <span class="tok-kw">comptime</span> callback: <span class="tok-kw">fn</span> (info: *dl_phdr_info, size: <span class="tok-type">usize</span>, context: <span class="tok-builtin">@TypeOf</span>(context)) Error!<span class="tok-type">void</span>,</span>
<span class="line" id="L5275">) Error!<span class="tok-type">void</span> {</span>
<span class="line" id="L5276">    <span class="tok-kw">const</span> Context = <span class="tok-builtin">@TypeOf</span>(context);</span>
<span class="line" id="L5277"></span>
<span class="line" id="L5278">    <span class="tok-kw">if</span> (builtin.object_format != .elf)</span>
<span class="line" id="L5279">        <span class="tok-builtin">@compileError</span>(<span class="tok-str">&quot;dl_iterate_phdr is not available for this target&quot;</span>);</span>
<span class="line" id="L5280"></span>
<span class="line" id="L5281">    <span class="tok-kw">if</span> (builtin.link_libc) {</span>
<span class="line" id="L5282">        <span class="tok-kw">switch</span> (system.dl_iterate_phdr(<span class="tok-kw">struct</span> {</span>
<span class="line" id="L5283">            <span class="tok-kw">fn</span> <span class="tok-fn">callbackC</span>(info: *dl_phdr_info, size: <span class="tok-type">usize</span>, data: ?*<span class="tok-type">anyopaque</span>) <span class="tok-kw">callconv</span>(.C) <span class="tok-type">c_int</span> {</span>
<span class="line" id="L5284">                <span class="tok-kw">const</span> context_ptr = <span class="tok-builtin">@ptrCast</span>(*<span class="tok-kw">const</span> Context, <span class="tok-builtin">@alignCast</span>(<span class="tok-builtin">@alignOf</span>(*<span class="tok-kw">const</span> Context), data));</span>
<span class="line" id="L5285">                callback(info, size, context_ptr.*) <span class="tok-kw">catch</span> |err| <span class="tok-kw">return</span> <span class="tok-builtin">@errorToInt</span>(err);</span>
<span class="line" id="L5286">                <span class="tok-kw">return</span> <span class="tok-number">0</span>;</span>
<span class="line" id="L5287">            }</span>
<span class="line" id="L5288">        }.callbackC, <span class="tok-builtin">@intToPtr</span>(?*<span class="tok-type">anyopaque</span>, <span class="tok-builtin">@ptrToInt</span>(&amp;context)))) {</span>
<span class="line" id="L5289">            <span class="tok-number">0</span> =&gt; <span class="tok-kw">return</span>,</span>
<span class="line" id="L5290">            <span class="tok-kw">else</span> =&gt; |err| <span class="tok-kw">return</span> <span class="tok-builtin">@errSetCast</span>(Error, <span class="tok-builtin">@intToError</span>(<span class="tok-builtin">@intCast</span>(<span class="tok-type">u16</span>, err))), <span class="tok-comment">// TODO don't hardcode u16</span>
</span>
<span class="line" id="L5291">        }</span>
<span class="line" id="L5292">    }</span>
<span class="line" id="L5293"></span>
<span class="line" id="L5294">    <span class="tok-kw">const</span> elf_base = std.process.getBaseAddress();</span>
<span class="line" id="L5295">    <span class="tok-kw">const</span> ehdr = <span class="tok-builtin">@intToPtr</span>(*elf.Ehdr, elf_base);</span>
<span class="line" id="L5296">    <span class="tok-comment">// Make sure the base address points to an ELF image.</span>
</span>
<span class="line" id="L5297">    assert(mem.eql(<span class="tok-type">u8</span>, ehdr.e_ident[<span class="tok-number">0</span>..<span class="tok-number">4</span>], elf.MAGIC));</span>
<span class="line" id="L5298">    <span class="tok-kw">const</span> n_phdr = ehdr.e_phnum;</span>
<span class="line" id="L5299">    <span class="tok-kw">const</span> phdrs = (<span class="tok-builtin">@intToPtr</span>([*]elf.Phdr, elf_base + ehdr.e_phoff))[<span class="tok-number">0</span>..n_phdr];</span>
<span class="line" id="L5300"></span>
<span class="line" id="L5301">    <span class="tok-kw">var</span> it = dl.linkmap_iterator(phdrs) <span class="tok-kw">catch</span> <span class="tok-kw">unreachable</span>;</span>
<span class="line" id="L5302"></span>
<span class="line" id="L5303">    <span class="tok-comment">// The executable has no dynamic link segment, create a single entry for</span>
</span>
<span class="line" id="L5304">    <span class="tok-comment">// the whole ELF image.</span>
</span>
<span class="line" id="L5305">    <span class="tok-kw">if</span> (it.end()) {</span>
<span class="line" id="L5306">        <span class="tok-comment">// Find the base address for the ELF image, if this is a PIE the value</span>
</span>
<span class="line" id="L5307">        <span class="tok-comment">// is non-zero.</span>
</span>
<span class="line" id="L5308">        <span class="tok-kw">const</span> base_address = <span class="tok-kw">for</span> (phdrs) |*phdr| {</span>
<span class="line" id="L5309">            <span class="tok-kw">if</span> (phdr.p_type == elf.PT_PHDR) {</span>
<span class="line" id="L5310">                <span class="tok-kw">break</span> <span class="tok-builtin">@ptrToInt</span>(phdrs.ptr) - phdr.p_vaddr;</span>
<span class="line" id="L5311">                <span class="tok-comment">// We could try computing the difference between _DYNAMIC and</span>
</span>
<span class="line" id="L5312">                <span class="tok-comment">// the p_vaddr of the PT_DYNAMIC section, but using the phdr is</span>
</span>
<span class="line" id="L5313">                <span class="tok-comment">// good enough (Is it?).</span>
</span>
<span class="line" id="L5314">            }</span>
<span class="line" id="L5315">        } <span class="tok-kw">else</span> <span class="tok-kw">unreachable</span>;</span>
<span class="line" id="L5316"></span>
<span class="line" id="L5317">        <span class="tok-kw">var</span> info = dl_phdr_info{</span>
<span class="line" id="L5318">            .dlpi_addr = base_address,</span>
<span class="line" id="L5319">            .dlpi_name = <span class="tok-str">&quot;/proc/self/exe&quot;</span>,</span>
<span class="line" id="L5320">            .dlpi_phdr = phdrs.ptr,</span>
<span class="line" id="L5321">            .dlpi_phnum = ehdr.e_phnum,</span>
<span class="line" id="L5322">        };</span>
<span class="line" id="L5323"></span>
<span class="line" id="L5324">        <span class="tok-kw">return</span> callback(&amp;info, <span class="tok-builtin">@sizeOf</span>(dl_phdr_info), context);</span>
<span class="line" id="L5325">    }</span>
<span class="line" id="L5326"></span>
<span class="line" id="L5327">    <span class="tok-comment">// Last return value from the callback function.</span>
</span>
<span class="line" id="L5328">    <span class="tok-kw">while</span> (it.next()) |entry| {</span>
<span class="line" id="L5329">        <span class="tok-kw">var</span> dlpi_phdr: [*]elf.Phdr = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L5330">        <span class="tok-kw">var</span> dlpi_phnum: <span class="tok-type">u16</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L5331"></span>
<span class="line" id="L5332">        <span class="tok-kw">if</span> (entry.l_addr != <span class="tok-number">0</span>) {</span>
<span class="line" id="L5333">            <span class="tok-kw">const</span> elf_header = <span class="tok-builtin">@intToPtr</span>(*elf.Ehdr, entry.l_addr);</span>
<span class="line" id="L5334">            dlpi_phdr = <span class="tok-builtin">@intToPtr</span>([*]elf.Phdr, entry.l_addr + elf_header.e_phoff);</span>
<span class="line" id="L5335">            dlpi_phnum = elf_header.e_phnum;</span>
<span class="line" id="L5336">        } <span class="tok-kw">else</span> {</span>
<span class="line" id="L5337">            <span class="tok-comment">// This is the running ELF image</span>
</span>
<span class="line" id="L5338">            dlpi_phdr = <span class="tok-builtin">@intToPtr</span>([*]elf.Phdr, elf_base + ehdr.e_phoff);</span>
<span class="line" id="L5339">            dlpi_phnum = ehdr.e_phnum;</span>
<span class="line" id="L5340">        }</span>
<span class="line" id="L5341"></span>
<span class="line" id="L5342">        <span class="tok-kw">var</span> info = dl_phdr_info{</span>
<span class="line" id="L5343">            .dlpi_addr = entry.l_addr,</span>
<span class="line" id="L5344">            .dlpi_name = entry.l_name,</span>
<span class="line" id="L5345">            .dlpi_phdr = dlpi_phdr,</span>
<span class="line" id="L5346">            .dlpi_phnum = dlpi_phnum,</span>
<span class="line" id="L5347">        };</span>
<span class="line" id="L5348"></span>
<span class="line" id="L5349">        <span class="tok-kw">try</span> callback(&amp;info, <span class="tok-builtin">@sizeOf</span>(dl_phdr_info), context);</span>
<span class="line" id="L5350">    }</span>
<span class="line" id="L5351">}</span>
<span class="line" id="L5352"></span>
<span class="line" id="L5353"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> ClockGetTimeError = <span class="tok-kw">error</span>{UnsupportedClock} || UnexpectedError;</span>
<span class="line" id="L5354"></span>
<span class="line" id="L5355"><span class="tok-comment">/// TODO: change this to return the timespec as a return value</span></span>
<span class="line" id="L5356"><span class="tok-comment">/// TODO: look into making clk_id an enum</span></span>
<span class="line" id="L5357"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">clock_gettime</span>(clk_id: <span class="tok-type">i32</span>, tp: *timespec) ClockGetTimeError!<span class="tok-type">void</span> {</span>
<span class="line" id="L5358">    <span class="tok-kw">if</span> (builtin.os.tag == .wasi <span class="tok-kw">and</span> !builtin.link_libc) {</span>
<span class="line" id="L5359">        <span class="tok-kw">var</span> ts: timestamp_t = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L5360">        <span class="tok-kw">switch</span> (system.clock_time_get(<span class="tok-builtin">@bitCast</span>(<span class="tok-type">u32</span>, clk_id), <span class="tok-number">1</span>, &amp;ts)) {</span>
<span class="line" id="L5361">            .SUCCESS =&gt; {</span>
<span class="line" id="L5362">                tp.* = .{</span>
<span class="line" id="L5363">                    .tv_sec = <span class="tok-builtin">@intCast</span>(<span class="tok-type">i64</span>, ts / std.time.ns_per_s),</span>
<span class="line" id="L5364">                    .tv_nsec = <span class="tok-builtin">@intCast</span>(<span class="tok-type">isize</span>, ts % std.time.ns_per_s),</span>
<span class="line" id="L5365">                };</span>
<span class="line" id="L5366">            },</span>
<span class="line" id="L5367">            .INVAL =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.UnsupportedClock,</span>
<span class="line" id="L5368">            <span class="tok-kw">else</span> =&gt; |err| <span class="tok-kw">return</span> unexpectedErrno(err),</span>
<span class="line" id="L5369">        }</span>
<span class="line" id="L5370">        <span class="tok-kw">return</span>;</span>
<span class="line" id="L5371">    }</span>
<span class="line" id="L5372">    <span class="tok-kw">if</span> (builtin.os.tag == .windows) {</span>
<span class="line" id="L5373">        <span class="tok-kw">if</span> (clk_id == CLOCK.REALTIME) {</span>
<span class="line" id="L5374">            <span class="tok-kw">var</span> ft: windows.FILETIME = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L5375">            windows.kernel32.GetSystemTimeAsFileTime(&amp;ft);</span>
<span class="line" id="L5376">            <span class="tok-comment">// FileTime has a granularity of 100 nanoseconds and uses the NTFS/Windows epoch.</span>
</span>
<span class="line" id="L5377">            <span class="tok-kw">const</span> ft64 = (<span class="tok-builtin">@as</span>(<span class="tok-type">u64</span>, ft.dwHighDateTime) &lt;&lt; <span class="tok-number">32</span>) | ft.dwLowDateTime;</span>
<span class="line" id="L5378">            <span class="tok-kw">const</span> ft_per_s = std.time.ns_per_s / <span class="tok-number">100</span>;</span>
<span class="line" id="L5379">            tp.* = .{</span>
<span class="line" id="L5380">                .tv_sec = <span class="tok-builtin">@intCast</span>(<span class="tok-type">i64</span>, ft64 / ft_per_s) + std.time.epoch.windows,</span>
<span class="line" id="L5381">                .tv_nsec = <span class="tok-builtin">@intCast</span>(<span class="tok-type">c_long</span>, ft64 % ft_per_s) * <span class="tok-number">100</span>,</span>
<span class="line" id="L5382">            };</span>
<span class="line" id="L5383">            <span class="tok-kw">return</span>;</span>
<span class="line" id="L5384">        } <span class="tok-kw">else</span> {</span>
<span class="line" id="L5385">            <span class="tok-comment">// TODO POSIX implementation of CLOCK.MONOTONIC on Windows.</span>
</span>
<span class="line" id="L5386">            <span class="tok-kw">return</span> <span class="tok-kw">error</span>.UnsupportedClock;</span>
<span class="line" id="L5387">        }</span>
<span class="line" id="L5388">    }</span>
<span class="line" id="L5389"></span>
<span class="line" id="L5390">    <span class="tok-kw">switch</span> (errno(system.clock_gettime(clk_id, tp))) {</span>
<span class="line" id="L5391">        .SUCCESS =&gt; <span class="tok-kw">return</span>,</span>
<span class="line" id="L5392">        .FAULT =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L5393">        .INVAL =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.UnsupportedClock,</span>
<span class="line" id="L5394">        <span class="tok-kw">else</span> =&gt; |err| <span class="tok-kw">return</span> unexpectedErrno(err),</span>
<span class="line" id="L5395">    }</span>
<span class="line" id="L5396">}</span>
<span class="line" id="L5397"></span>
<span class="line" id="L5398"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">clock_getres</span>(clk_id: <span class="tok-type">i32</span>, res: *timespec) ClockGetTimeError!<span class="tok-type">void</span> {</span>
<span class="line" id="L5399">    <span class="tok-kw">if</span> (builtin.os.tag == .wasi <span class="tok-kw">and</span> !builtin.link_libc) {</span>
<span class="line" id="L5400">        <span class="tok-kw">var</span> ts: timestamp_t = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L5401">        <span class="tok-kw">switch</span> (system.clock_res_get(<span class="tok-builtin">@bitCast</span>(<span class="tok-type">u32</span>, clk_id), &amp;ts)) {</span>
<span class="line" id="L5402">            .SUCCESS =&gt; res.* = .{</span>
<span class="line" id="L5403">                .tv_sec = <span class="tok-builtin">@intCast</span>(<span class="tok-type">i64</span>, ts / std.time.ns_per_s),</span>
<span class="line" id="L5404">                .tv_nsec = <span class="tok-builtin">@intCast</span>(<span class="tok-type">isize</span>, ts % std.time.ns_per_s),</span>
<span class="line" id="L5405">            },</span>
<span class="line" id="L5406">            .INVAL =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.UnsupportedClock,</span>
<span class="line" id="L5407">            <span class="tok-kw">else</span> =&gt; |err| <span class="tok-kw">return</span> unexpectedErrno(err),</span>
<span class="line" id="L5408">        }</span>
<span class="line" id="L5409">        <span class="tok-kw">return</span>;</span>
<span class="line" id="L5410">    }</span>
<span class="line" id="L5411"></span>
<span class="line" id="L5412">    <span class="tok-kw">switch</span> (errno(system.clock_getres(clk_id, res))) {</span>
<span class="line" id="L5413">        .SUCCESS =&gt; <span class="tok-kw">return</span>,</span>
<span class="line" id="L5414">        .FAULT =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L5415">        .INVAL =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.UnsupportedClock,</span>
<span class="line" id="L5416">        <span class="tok-kw">else</span> =&gt; |err| <span class="tok-kw">return</span> unexpectedErrno(err),</span>
<span class="line" id="L5417">    }</span>
<span class="line" id="L5418">}</span>
<span class="line" id="L5419"></span>
<span class="line" id="L5420"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> SchedGetAffinityError = <span class="tok-kw">error</span>{PermissionDenied} || UnexpectedError;</span>
<span class="line" id="L5421"></span>
<span class="line" id="L5422"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">sched_getaffinity</span>(pid: pid_t) SchedGetAffinityError!cpu_set_t {</span>
<span class="line" id="L5423">    <span class="tok-kw">var</span> set: cpu_set_t = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L5424">    <span class="tok-kw">switch</span> (errno(system.sched_getaffinity(pid, <span class="tok-builtin">@sizeOf</span>(cpu_set_t), &amp;set))) {</span>
<span class="line" id="L5425">        .SUCCESS =&gt; <span class="tok-kw">return</span> set,</span>
<span class="line" id="L5426">        .FAULT =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L5427">        .INVAL =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L5428">        .SRCH =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L5429">        .PERM =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.PermissionDenied,</span>
<span class="line" id="L5430">        <span class="tok-kw">else</span> =&gt; |err| <span class="tok-kw">return</span> unexpectedErrno(err),</span>
<span class="line" id="L5431">    }</span>
<span class="line" id="L5432">}</span>
<span class="line" id="L5433"></span>
<span class="line" id="L5434"><span class="tok-comment">/// Used to convert a slice to a null terminated slice on the stack.</span></span>
<span class="line" id="L5435"><span class="tok-comment">/// TODO https://github.com/ziglang/zig/issues/287</span></span>
<span class="line" id="L5436"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">toPosixPath</span>(file_path: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) ![MAX_PATH_BYTES - <span class="tok-number">1</span>:<span class="tok-number">0</span>]<span class="tok-type">u8</span> {</span>
<span class="line" id="L5437">    <span class="tok-kw">if</span> (std.debug.runtime_safety) assert(std.mem.indexOfScalar(<span class="tok-type">u8</span>, file_path, <span class="tok-number">0</span>) == <span class="tok-null">null</span>);</span>
<span class="line" id="L5438">    <span class="tok-kw">var</span> path_with_null: [MAX_PATH_BYTES - <span class="tok-number">1</span>:<span class="tok-number">0</span>]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L5439">    <span class="tok-comment">// &gt;= rather than &gt; to make room for the null byte</span>
</span>
<span class="line" id="L5440">    <span class="tok-kw">if</span> (file_path.len &gt;= MAX_PATH_BYTES) <span class="tok-kw">return</span> <span class="tok-kw">error</span>.NameTooLong;</span>
<span class="line" id="L5441">    mem.copy(<span class="tok-type">u8</span>, &amp;path_with_null, file_path);</span>
<span class="line" id="L5442">    path_with_null[file_path.len] = <span class="tok-number">0</span>;</span>
<span class="line" id="L5443">    <span class="tok-kw">return</span> path_with_null;</span>
<span class="line" id="L5444">}</span>
<span class="line" id="L5445"></span>
<span class="line" id="L5446"><span class="tok-comment">/// Whether or not error.Unexpected will print its value and a stack trace.</span></span>
<span class="line" id="L5447"><span class="tok-comment">/// if this happens the fix is to add the error code to the corresponding</span></span>
<span class="line" id="L5448"><span class="tok-comment">/// switch expression, possibly introduce a new error in the error set, and</span></span>
<span class="line" id="L5449"><span class="tok-comment">/// send a patch to Zig.</span></span>
<span class="line" id="L5450"><span class="tok-comment">/// The self-hosted compiler is not fully capable of handle the related code.</span></span>
<span class="line" id="L5451"><span class="tok-comment">/// Until then, unexpected error tracing is disabled for the self-hosted compiler.</span></span>
<span class="line" id="L5452"><span class="tok-comment">/// TODO remove this once self-hosted is capable enough to handle printing and</span></span>
<span class="line" id="L5453"><span class="tok-comment">/// stack trace dumping.</span></span>
<span class="line" id="L5454"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> unexpected_error_tracing = builtin.zig_backend == .stage1 <span class="tok-kw">and</span> builtin.mode == .Debug;</span>
<span class="line" id="L5455"></span>
<span class="line" id="L5456"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> UnexpectedError = <span class="tok-kw">error</span>{</span>
<span class="line" id="L5457">    <span class="tok-comment">/// The Operating System returned an undocumented error code.</span></span>
<span class="line" id="L5458">    <span class="tok-comment">/// This error is in theory not possible, but it would be better</span></span>
<span class="line" id="L5459">    <span class="tok-comment">/// to handle this error than to invoke undefined behavior.</span></span>
<span class="line" id="L5460">    Unexpected,</span>
<span class="line" id="L5461">};</span>
<span class="line" id="L5462"></span>
<span class="line" id="L5463"><span class="tok-comment">/// Call this when you made a syscall or something that sets errno</span></span>
<span class="line" id="L5464"><span class="tok-comment">/// and you get an unexpected error.</span></span>
<span class="line" id="L5465"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">unexpectedErrno</span>(err: E) UnexpectedError {</span>
<span class="line" id="L5466">    <span class="tok-kw">if</span> (unexpected_error_tracing) {</span>
<span class="line" id="L5467">        std.debug.print(<span class="tok-str">&quot;unexpected errno: {d}\n&quot;</span>, .{<span class="tok-builtin">@enumToInt</span>(err)});</span>
<span class="line" id="L5468">        std.debug.dumpCurrentStackTrace(<span class="tok-null">null</span>);</span>
<span class="line" id="L5469">    }</span>
<span class="line" id="L5470">    <span class="tok-kw">return</span> <span class="tok-kw">error</span>.Unexpected;</span>
<span class="line" id="L5471">}</span>
<span class="line" id="L5472"></span>
<span class="line" id="L5473"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> SigaltstackError = <span class="tok-kw">error</span>{</span>
<span class="line" id="L5474">    <span class="tok-comment">/// The supplied stack size was less than MINSIGSTKSZ.</span></span>
<span class="line" id="L5475">    SizeTooSmall,</span>
<span class="line" id="L5476"></span>
<span class="line" id="L5477">    <span class="tok-comment">/// Attempted to change the signal stack while it was active.</span></span>
<span class="line" id="L5478">    PermissionDenied,</span>
<span class="line" id="L5479">} || UnexpectedError;</span>
<span class="line" id="L5480"></span>
<span class="line" id="L5481"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">sigaltstack</span>(ss: ?*stack_t, old_ss: ?*stack_t) SigaltstackError!<span class="tok-type">void</span> {</span>
<span class="line" id="L5482">    <span class="tok-kw">switch</span> (errno(system.sigaltstack(ss, old_ss))) {</span>
<span class="line" id="L5483">        .SUCCESS =&gt; <span class="tok-kw">return</span>,</span>
<span class="line" id="L5484">        .FAULT =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L5485">        .INVAL =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L5486">        .NOMEM =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.SizeTooSmall,</span>
<span class="line" id="L5487">        .PERM =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.PermissionDenied,</span>
<span class="line" id="L5488">        <span class="tok-kw">else</span> =&gt; |err| <span class="tok-kw">return</span> unexpectedErrno(err),</span>
<span class="line" id="L5489">    }</span>
<span class="line" id="L5490">}</span>
<span class="line" id="L5491"></span>
<span class="line" id="L5492"><span class="tok-comment">/// Examine and change a signal action.</span></span>
<span class="line" id="L5493"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">sigaction</span>(sig: <span class="tok-type">u6</span>, <span class="tok-kw">noalias</span> act: ?*<span class="tok-kw">const</span> Sigaction, <span class="tok-kw">noalias</span> oact: ?*Sigaction) <span class="tok-kw">error</span>{OperationNotSupported}!<span class="tok-type">void</span> {</span>
<span class="line" id="L5494">    <span class="tok-kw">switch</span> (errno(system.sigaction(sig, act, oact))) {</span>
<span class="line" id="L5495">        .SUCCESS =&gt; <span class="tok-kw">return</span>,</span>
<span class="line" id="L5496">        .INVAL, .NOSYS =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.OperationNotSupported,</span>
<span class="line" id="L5497">        <span class="tok-kw">else</span> =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L5498">    }</span>
<span class="line" id="L5499">}</span>
<span class="line" id="L5500"></span>
<span class="line" id="L5501"><span class="tok-comment">/// Sets the thread signal mask.</span></span>
<span class="line" id="L5502"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">sigprocmask</span>(flags: <span class="tok-type">u32</span>, <span class="tok-kw">noalias</span> set: ?*<span class="tok-kw">const</span> sigset_t, <span class="tok-kw">noalias</span> oldset: ?*sigset_t) <span class="tok-type">void</span> {</span>
<span class="line" id="L5503">    <span class="tok-kw">switch</span> (errno(system.sigprocmask(flags, set, oldset))) {</span>
<span class="line" id="L5504">        .SUCCESS =&gt; <span class="tok-kw">return</span>,</span>
<span class="line" id="L5505">        .FAULT =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L5506">        .INVAL =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L5507">        <span class="tok-kw">else</span> =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L5508">    }</span>
<span class="line" id="L5509">}</span>
<span class="line" id="L5510"></span>
<span class="line" id="L5511"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> FutimensError = <span class="tok-kw">error</span>{</span>
<span class="line" id="L5512">    <span class="tok-comment">/// times is NULL, or both tv_nsec values are UTIME_NOW, and either:</span></span>
<span class="line" id="L5513">    <span class="tok-comment">/// *  the effective user ID of the caller does not match the  owner</span></span>
<span class="line" id="L5514">    <span class="tok-comment">///    of  the  file,  the  caller does not have write access to the</span></span>
<span class="line" id="L5515">    <span class="tok-comment">///    file, and the caller is not privileged (Linux: does not  have</span></span>
<span class="line" id="L5516">    <span class="tok-comment">///    either  the  CAP_FOWNER  or the CAP_DAC_OVERRIDE capability);</span></span>
<span class="line" id="L5517">    <span class="tok-comment">///    or,</span></span>
<span class="line" id="L5518">    <span class="tok-comment">/// *  the file is marked immutable (see chattr(1)).</span></span>
<span class="line" id="L5519">    AccessDenied,</span>
<span class="line" id="L5520"></span>
<span class="line" id="L5521">    <span class="tok-comment">/// The caller attempted to change one or both timestamps to a value</span></span>
<span class="line" id="L5522">    <span class="tok-comment">/// other than the current time, or to change one of the  timestamps</span></span>
<span class="line" id="L5523">    <span class="tok-comment">/// to the current time while leaving the other timestamp unchanged,</span></span>
<span class="line" id="L5524">    <span class="tok-comment">/// (i.e., times is not NULL, neither tv_nsec  field  is  UTIME_NOW,</span></span>
<span class="line" id="L5525">    <span class="tok-comment">/// and neither tv_nsec field is UTIME_OMIT) and either:</span></span>
<span class="line" id="L5526">    <span class="tok-comment">/// *  the  caller's  effective  user ID does not match the owner of</span></span>
<span class="line" id="L5527">    <span class="tok-comment">///    file, and the caller is not privileged (Linux: does not  have</span></span>
<span class="line" id="L5528">    <span class="tok-comment">///    the CAP_FOWNER capability); or,</span></span>
<span class="line" id="L5529">    <span class="tok-comment">/// *  the file is marked append-only or immutable (see chattr(1)).</span></span>
<span class="line" id="L5530">    PermissionDenied,</span>
<span class="line" id="L5531"></span>
<span class="line" id="L5532">    ReadOnlyFileSystem,</span>
<span class="line" id="L5533">} || UnexpectedError;</span>
<span class="line" id="L5534"></span>
<span class="line" id="L5535"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">futimens</span>(fd: fd_t, times: *<span class="tok-kw">const</span> [<span class="tok-number">2</span>]timespec) FutimensError!<span class="tok-type">void</span> {</span>
<span class="line" id="L5536">    <span class="tok-kw">if</span> (builtin.os.tag == .wasi <span class="tok-kw">and</span> !builtin.link_libc) {</span>
<span class="line" id="L5537">        <span class="tok-comment">// TODO WASI encodes `wasi.fstflags` to signify magic values</span>
</span>
<span class="line" id="L5538">        <span class="tok-comment">// similar to UTIME_NOW and UTIME_OMIT. Currently, we ignore</span>
</span>
<span class="line" id="L5539">        <span class="tok-comment">// this here, but we should really handle it somehow.</span>
</span>
<span class="line" id="L5540">        <span class="tok-kw">const</span> atim = times[<span class="tok-number">0</span>].toTimestamp();</span>
<span class="line" id="L5541">        <span class="tok-kw">const</span> mtim = times[<span class="tok-number">1</span>].toTimestamp();</span>
<span class="line" id="L5542">        <span class="tok-kw">switch</span> (wasi.fd_filestat_set_times(fd, atim, mtim, wasi.FILESTAT_SET_ATIM | wasi.FILESTAT_SET_MTIM)) {</span>
<span class="line" id="L5543">            .SUCCESS =&gt; <span class="tok-kw">return</span>,</span>
<span class="line" id="L5544">            .ACCES =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.AccessDenied,</span>
<span class="line" id="L5545">            .PERM =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.PermissionDenied,</span>
<span class="line" id="L5546">            .BADF =&gt; <span class="tok-kw">unreachable</span>, <span class="tok-comment">// always a race condition</span>
</span>
<span class="line" id="L5547">            .FAULT =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L5548">            .INVAL =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L5549">            .ROFS =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.ReadOnlyFileSystem,</span>
<span class="line" id="L5550">            <span class="tok-kw">else</span> =&gt; |err| <span class="tok-kw">return</span> unexpectedErrno(err),</span>
<span class="line" id="L5551">        }</span>
<span class="line" id="L5552">    }</span>
<span class="line" id="L5553"></span>
<span class="line" id="L5554">    <span class="tok-kw">switch</span> (errno(system.futimens(fd, times))) {</span>
<span class="line" id="L5555">        .SUCCESS =&gt; <span class="tok-kw">return</span>,</span>
<span class="line" id="L5556">        .ACCES =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.AccessDenied,</span>
<span class="line" id="L5557">        .PERM =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.PermissionDenied,</span>
<span class="line" id="L5558">        .BADF =&gt; <span class="tok-kw">unreachable</span>, <span class="tok-comment">// always a race condition</span>
</span>
<span class="line" id="L5559">        .FAULT =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L5560">        .INVAL =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L5561">        .ROFS =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.ReadOnlyFileSystem,</span>
<span class="line" id="L5562">        <span class="tok-kw">else</span> =&gt; |err| <span class="tok-kw">return</span> unexpectedErrno(err),</span>
<span class="line" id="L5563">    }</span>
<span class="line" id="L5564">}</span>
<span class="line" id="L5565"></span>
<span class="line" id="L5566"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> GetHostNameError = <span class="tok-kw">error</span>{PermissionDenied} || UnexpectedError;</span>
<span class="line" id="L5567"></span>
<span class="line" id="L5568"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">gethostname</span>(name_buffer: *[HOST_NAME_MAX]<span class="tok-type">u8</span>) GetHostNameError![]<span class="tok-type">u8</span> {</span>
<span class="line" id="L5569">    <span class="tok-kw">if</span> (builtin.link_libc) {</span>
<span class="line" id="L5570">        <span class="tok-kw">switch</span> (errno(system.gethostname(name_buffer, name_buffer.len))) {</span>
<span class="line" id="L5571">            .SUCCESS =&gt; <span class="tok-kw">return</span> mem.sliceTo(std.meta.assumeSentinel(name_buffer, <span class="tok-number">0</span>), <span class="tok-number">0</span>),</span>
<span class="line" id="L5572">            .FAULT =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L5573">            .NAMETOOLONG =&gt; <span class="tok-kw">unreachable</span>, <span class="tok-comment">// HOST_NAME_MAX prevents this</span>
</span>
<span class="line" id="L5574">            .PERM =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.PermissionDenied,</span>
<span class="line" id="L5575">            <span class="tok-kw">else</span> =&gt; |err| <span class="tok-kw">return</span> unexpectedErrno(err),</span>
<span class="line" id="L5576">        }</span>
<span class="line" id="L5577">    }</span>
<span class="line" id="L5578">    <span class="tok-kw">if</span> (builtin.os.tag == .linux) {</span>
<span class="line" id="L5579">        <span class="tok-kw">const</span> uts = uname();</span>
<span class="line" id="L5580">        <span class="tok-kw">const</span> hostname = mem.sliceTo(std.meta.assumeSentinel(&amp;uts.nodename, <span class="tok-number">0</span>), <span class="tok-number">0</span>);</span>
<span class="line" id="L5581">        mem.copy(<span class="tok-type">u8</span>, name_buffer, hostname);</span>
<span class="line" id="L5582">        <span class="tok-kw">return</span> name_buffer[<span class="tok-number">0</span>..hostname.len];</span>
<span class="line" id="L5583">    }</span>
<span class="line" id="L5584"></span>
<span class="line" id="L5585">    <span class="tok-builtin">@compileError</span>(<span class="tok-str">&quot;TODO implement gethostname for this OS&quot;</span>);</span>
<span class="line" id="L5586">}</span>
<span class="line" id="L5587"></span>
<span class="line" id="L5588"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">uname</span>() utsname {</span>
<span class="line" id="L5589">    <span class="tok-kw">var</span> uts: utsname = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L5590">    <span class="tok-kw">switch</span> (errno(system.uname(&amp;uts))) {</span>
<span class="line" id="L5591">        .SUCCESS =&gt; <span class="tok-kw">return</span> uts,</span>
<span class="line" id="L5592">        .FAULT =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L5593">        <span class="tok-kw">else</span> =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L5594">    }</span>
<span class="line" id="L5595">}</span>
<span class="line" id="L5596"></span>
<span class="line" id="L5597"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">res_mkquery</span>(</span>
<span class="line" id="L5598">    op: <span class="tok-type">u4</span>,</span>
<span class="line" id="L5599">    dname: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>,</span>
<span class="line" id="L5600">    class: <span class="tok-type">u8</span>,</span>
<span class="line" id="L5601">    ty: <span class="tok-type">u8</span>,</span>
<span class="line" id="L5602">    data: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>,</span>
<span class="line" id="L5603">    newrr: ?[*]<span class="tok-kw">const</span> <span class="tok-type">u8</span>,</span>
<span class="line" id="L5604">    buf: []<span class="tok-type">u8</span>,</span>
<span class="line" id="L5605">) <span class="tok-type">usize</span> {</span>
<span class="line" id="L5606">    _ = data;</span>
<span class="line" id="L5607">    _ = newrr;</span>
<span class="line" id="L5608">    <span class="tok-comment">// This implementation is ported from musl libc.</span>
</span>
<span class="line" id="L5609">    <span class="tok-comment">// A more idiomatic &quot;ziggy&quot; implementation would be welcome.</span>
</span>
<span class="line" id="L5610">    <span class="tok-kw">var</span> name = dname;</span>
<span class="line" id="L5611">    <span class="tok-kw">if</span> (mem.endsWith(<span class="tok-type">u8</span>, name, <span class="tok-str">&quot;.&quot;</span>)) name.len -= <span class="tok-number">1</span>;</span>
<span class="line" id="L5612">    assert(name.len &lt;= <span class="tok-number">253</span>);</span>
<span class="line" id="L5613">    <span class="tok-kw">const</span> n = <span class="tok-number">17</span> + name.len + <span class="tok-builtin">@boolToInt</span>(name.len != <span class="tok-number">0</span>);</span>
<span class="line" id="L5614"></span>
<span class="line" id="L5615">    <span class="tok-comment">// Construct query template - ID will be filled later</span>
</span>
<span class="line" id="L5616">    <span class="tok-kw">var</span> q: [<span class="tok-number">280</span>]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L5617">    <span class="tok-builtin">@memset</span>(&amp;q, <span class="tok-number">0</span>, n);</span>
<span class="line" id="L5618">    q[<span class="tok-number">2</span>] = <span class="tok-builtin">@as</span>(<span class="tok-type">u8</span>, op) * <span class="tok-number">8</span> + <span class="tok-number">1</span>;</span>
<span class="line" id="L5619">    q[<span class="tok-number">5</span>] = <span class="tok-number">1</span>;</span>
<span class="line" id="L5620">    mem.copy(<span class="tok-type">u8</span>, q[<span class="tok-number">13</span>..], name);</span>
<span class="line" id="L5621">    <span class="tok-kw">var</span> i: <span class="tok-type">usize</span> = <span class="tok-number">13</span>;</span>
<span class="line" id="L5622">    <span class="tok-kw">var</span> j: <span class="tok-type">usize</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L5623">    <span class="tok-kw">while</span> (q[i] != <span class="tok-number">0</span>) : (i = j + <span class="tok-number">1</span>) {</span>
<span class="line" id="L5624">        j = i;</span>
<span class="line" id="L5625">        <span class="tok-kw">while</span> (q[j] != <span class="tok-number">0</span> <span class="tok-kw">and</span> q[j] != <span class="tok-str">'.'</span>) : (j += <span class="tok-number">1</span>) {}</span>
<span class="line" id="L5626">        <span class="tok-comment">// TODO determine the circumstances for this and whether or</span>
</span>
<span class="line" id="L5627">        <span class="tok-comment">// not this should be an error.</span>
</span>
<span class="line" id="L5628">        <span class="tok-kw">if</span> (j - i - <span class="tok-number">1</span> &gt; <span class="tok-number">62</span>) <span class="tok-kw">unreachable</span>;</span>
<span class="line" id="L5629">        q[i - <span class="tok-number">1</span>] = <span class="tok-builtin">@intCast</span>(<span class="tok-type">u8</span>, j - i);</span>
<span class="line" id="L5630">    }</span>
<span class="line" id="L5631">    q[i + <span class="tok-number">1</span>] = ty;</span>
<span class="line" id="L5632">    q[i + <span class="tok-number">3</span>] = class;</span>
<span class="line" id="L5633"></span>
<span class="line" id="L5634">    <span class="tok-comment">// Make a reasonably unpredictable id</span>
</span>
<span class="line" id="L5635">    <span class="tok-kw">var</span> ts: timespec = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L5636">    clock_gettime(CLOCK.REALTIME, &amp;ts) <span class="tok-kw">catch</span> {};</span>
<span class="line" id="L5637">    <span class="tok-kw">const</span> UInt = std.meta.Int(.unsigned, <span class="tok-builtin">@bitSizeOf</span>(<span class="tok-builtin">@TypeOf</span>(ts.tv_nsec)));</span>
<span class="line" id="L5638">    <span class="tok-kw">const</span> unsec = <span class="tok-builtin">@bitCast</span>(UInt, ts.tv_nsec);</span>
<span class="line" id="L5639">    <span class="tok-kw">const</span> id = <span class="tok-builtin">@truncate</span>(<span class="tok-type">u32</span>, unsec + unsec / <span class="tok-number">65536</span>);</span>
<span class="line" id="L5640">    q[<span class="tok-number">0</span>] = <span class="tok-builtin">@truncate</span>(<span class="tok-type">u8</span>, id / <span class="tok-number">256</span>);</span>
<span class="line" id="L5641">    q[<span class="tok-number">1</span>] = <span class="tok-builtin">@truncate</span>(<span class="tok-type">u8</span>, id);</span>
<span class="line" id="L5642"></span>
<span class="line" id="L5643">    mem.copy(<span class="tok-type">u8</span>, buf, q[<span class="tok-number">0</span>..n]);</span>
<span class="line" id="L5644">    <span class="tok-kw">return</span> n;</span>
<span class="line" id="L5645">}</span>
<span class="line" id="L5646"></span>
<span class="line" id="L5647"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> SendError = <span class="tok-kw">error</span>{</span>
<span class="line" id="L5648">    <span class="tok-comment">/// (For UNIX domain sockets, which are identified by pathname) Write permission is  denied</span></span>
<span class="line" id="L5649">    <span class="tok-comment">/// on  the destination socket file, or search permission is denied for one of the</span></span>
<span class="line" id="L5650">    <span class="tok-comment">/// directories the path prefix.  (See path_resolution(7).)</span></span>
<span class="line" id="L5651">    <span class="tok-comment">/// (For UDP sockets) An attempt was made to send to a network/broadcast address as  though</span></span>
<span class="line" id="L5652">    <span class="tok-comment">/// it was a unicast address.</span></span>
<span class="line" id="L5653">    AccessDenied,</span>
<span class="line" id="L5654"></span>
<span class="line" id="L5655">    <span class="tok-comment">/// The socket is marked nonblocking and the requested operation would block, and</span></span>
<span class="line" id="L5656">    <span class="tok-comment">/// there is no global event loop configured.</span></span>
<span class="line" id="L5657">    <span class="tok-comment">/// It's also possible to get this error under the following condition:</span></span>
<span class="line" id="L5658">    <span class="tok-comment">/// (Internet  domain datagram sockets) The socket referred to by sockfd had not previously</span></span>
<span class="line" id="L5659">    <span class="tok-comment">/// been bound to an address and, upon attempting to bind it to an ephemeral port,  it  was</span></span>
<span class="line" id="L5660">    <span class="tok-comment">/// determined that all port numbers in the ephemeral port range are currently in use.  See</span></span>
<span class="line" id="L5661">    <span class="tok-comment">/// the discussion of /proc/sys/net/ipv4/ip_local_port_range in ip(7).</span></span>
<span class="line" id="L5662">    WouldBlock,</span>
<span class="line" id="L5663"></span>
<span class="line" id="L5664">    <span class="tok-comment">/// Another Fast Open is already in progress.</span></span>
<span class="line" id="L5665">    FastOpenAlreadyInProgress,</span>
<span class="line" id="L5666"></span>
<span class="line" id="L5667">    <span class="tok-comment">/// Connection reset by peer.</span></span>
<span class="line" id="L5668">    ConnectionResetByPeer,</span>
<span class="line" id="L5669"></span>
<span class="line" id="L5670">    <span class="tok-comment">/// The  socket  type requires that message be sent atomically, and the size of the message</span></span>
<span class="line" id="L5671">    <span class="tok-comment">/// to be sent made this impossible. The message is not transmitted.</span></span>
<span class="line" id="L5672">    MessageTooBig,</span>
<span class="line" id="L5673"></span>
<span class="line" id="L5674">    <span class="tok-comment">/// The output queue for a network interface was full.  This generally indicates  that  the</span></span>
<span class="line" id="L5675">    <span class="tok-comment">/// interface  has  stopped sending, but may be caused by transient congestion.  (Normally,</span></span>
<span class="line" id="L5676">    <span class="tok-comment">/// this does not occur in Linux.  Packets are just silently dropped when  a  device  queue</span></span>
<span class="line" id="L5677">    <span class="tok-comment">/// overflows.)</span></span>
<span class="line" id="L5678">    <span class="tok-comment">/// This is also caused when there is not enough kernel memory available.</span></span>
<span class="line" id="L5679">    SystemResources,</span>
<span class="line" id="L5680"></span>
<span class="line" id="L5681">    <span class="tok-comment">/// The  local  end  has been shut down on a connection oriented socket.  In this case, the</span></span>
<span class="line" id="L5682">    <span class="tok-comment">/// process will also receive a SIGPIPE unless MSG.NOSIGNAL is set.</span></span>
<span class="line" id="L5683">    BrokenPipe,</span>
<span class="line" id="L5684"></span>
<span class="line" id="L5685">    FileDescriptorNotASocket,</span>
<span class="line" id="L5686"></span>
<span class="line" id="L5687">    <span class="tok-comment">/// Network is unreachable.</span></span>
<span class="line" id="L5688">    NetworkUnreachable,</span>
<span class="line" id="L5689"></span>
<span class="line" id="L5690">    <span class="tok-comment">/// The local network interface used to reach the destination is down.</span></span>
<span class="line" id="L5691">    NetworkSubsystemFailed,</span>
<span class="line" id="L5692">} || UnexpectedError;</span>
<span class="line" id="L5693"></span>
<span class="line" id="L5694"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> SendMsgError = SendError || <span class="tok-kw">error</span>{</span>
<span class="line" id="L5695">    <span class="tok-comment">/// The passed address didn't have the correct address family in its sa_family field.</span></span>
<span class="line" id="L5696">    AddressFamilyNotSupported,</span>
<span class="line" id="L5697"></span>
<span class="line" id="L5698">    <span class="tok-comment">/// Returned when socket is AF.UNIX and the given path has a symlink loop.</span></span>
<span class="line" id="L5699">    SymLinkLoop,</span>
<span class="line" id="L5700"></span>
<span class="line" id="L5701">    <span class="tok-comment">/// Returned when socket is AF.UNIX and the given path length exceeds `MAX_PATH_BYTES` bytes.</span></span>
<span class="line" id="L5702">    NameTooLong,</span>
<span class="line" id="L5703"></span>
<span class="line" id="L5704">    <span class="tok-comment">/// Returned when socket is AF.UNIX and the given path does not point to an existing file.</span></span>
<span class="line" id="L5705">    FileNotFound,</span>
<span class="line" id="L5706">    NotDir,</span>
<span class="line" id="L5707"></span>
<span class="line" id="L5708">    <span class="tok-comment">/// The socket is not connected (connection-oriented sockets only).</span></span>
<span class="line" id="L5709">    SocketNotConnected,</span>
<span class="line" id="L5710">    AddressNotAvailable,</span>
<span class="line" id="L5711">};</span>
<span class="line" id="L5712"></span>
<span class="line" id="L5713"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">sendmsg</span>(</span>
<span class="line" id="L5714">    <span class="tok-comment">/// The file descriptor of the sending socket.</span></span>
<span class="line" id="L5715">    sockfd: socket_t,</span>
<span class="line" id="L5716">    <span class="tok-comment">/// Message header and iovecs</span></span>
<span class="line" id="L5717">    msg: msghdr_const,</span>
<span class="line" id="L5718">    flags: <span class="tok-type">u32</span>,</span>
<span class="line" id="L5719">) SendMsgError!<span class="tok-type">usize</span> {</span>
<span class="line" id="L5720">    <span class="tok-kw">while</span> (<span class="tok-null">true</span>) {</span>
<span class="line" id="L5721">        <span class="tok-kw">const</span> rc = system.sendmsg(sockfd, <span class="tok-builtin">@ptrCast</span>(*<span class="tok-kw">const</span> std.x.os.Socket.Message, &amp;msg), <span class="tok-builtin">@intCast</span>(<span class="tok-type">c_int</span>, flags));</span>
<span class="line" id="L5722">        <span class="tok-kw">if</span> (builtin.os.tag == .windows) {</span>
<span class="line" id="L5723">            <span class="tok-kw">if</span> (rc == windows.ws2_32.SOCKET_ERROR) {</span>
<span class="line" id="L5724">                <span class="tok-kw">switch</span> (windows.ws2_32.WSAGetLastError()) {</span>
<span class="line" id="L5725">                    .WSAEACCES =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.AccessDenied,</span>
<span class="line" id="L5726">                    .WSAEADDRNOTAVAIL =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.AddressNotAvailable,</span>
<span class="line" id="L5727">                    .WSAECONNRESET =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.ConnectionResetByPeer,</span>
<span class="line" id="L5728">                    .WSAEMSGSIZE =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.MessageTooBig,</span>
<span class="line" id="L5729">                    .WSAENOBUFS =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.SystemResources,</span>
<span class="line" id="L5730">                    .WSAENOTSOCK =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.FileDescriptorNotASocket,</span>
<span class="line" id="L5731">                    .WSAEAFNOSUPPORT =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.AddressFamilyNotSupported,</span>
<span class="line" id="L5732">                    .WSAEDESTADDRREQ =&gt; <span class="tok-kw">unreachable</span>, <span class="tok-comment">// A destination address is required.</span>
</span>
<span class="line" id="L5733">                    .WSAEFAULT =&gt; <span class="tok-kw">unreachable</span>, <span class="tok-comment">// The lpBuffers, lpTo, lpOverlapped, lpNumberOfBytesSent, or lpCompletionRoutine parameters are not part of the user address space, or the lpTo parameter is too small.</span>
</span>
<span class="line" id="L5734">                    .WSAEHOSTUNREACH =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.NetworkUnreachable,</span>
<span class="line" id="L5735">                    <span class="tok-comment">// TODO: WSAEINPROGRESS, WSAEINTR</span>
</span>
<span class="line" id="L5736">                    .WSAEINVAL =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L5737">                    .WSAENETDOWN =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.NetworkSubsystemFailed,</span>
<span class="line" id="L5738">                    .WSAENETRESET =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.ConnectionResetByPeer,</span>
<span class="line" id="L5739">                    .WSAENETUNREACH =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.NetworkUnreachable,</span>
<span class="line" id="L5740">                    .WSAENOTCONN =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.SocketNotConnected,</span>
<span class="line" id="L5741">                    .WSAESHUTDOWN =&gt; <span class="tok-kw">unreachable</span>, <span class="tok-comment">// The socket has been shut down; it is not possible to WSASendTo on a socket after shutdown has been invoked with how set to SD_SEND or SD_BOTH.</span>
</span>
<span class="line" id="L5742">                    .WSAEWOULDBLOCK =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.WouldBlock,</span>
<span class="line" id="L5743">                    .WSANOTINITIALISED =&gt; <span class="tok-kw">unreachable</span>, <span class="tok-comment">// A successful WSAStartup call must occur before using this function.</span>
</span>
<span class="line" id="L5744">                    <span class="tok-kw">else</span> =&gt; |err| <span class="tok-kw">return</span> windows.unexpectedWSAError(err),</span>
<span class="line" id="L5745">                }</span>
<span class="line" id="L5746">            } <span class="tok-kw">else</span> {</span>
<span class="line" id="L5747">                <span class="tok-kw">return</span> <span class="tok-builtin">@intCast</span>(<span class="tok-type">usize</span>, rc);</span>
<span class="line" id="L5748">            }</span>
<span class="line" id="L5749">        } <span class="tok-kw">else</span> {</span>
<span class="line" id="L5750">            <span class="tok-kw">switch</span> (errno(rc)) {</span>
<span class="line" id="L5751">                .SUCCESS =&gt; <span class="tok-kw">return</span> <span class="tok-builtin">@intCast</span>(<span class="tok-type">usize</span>, rc),</span>
<span class="line" id="L5752"></span>
<span class="line" id="L5753">                .ACCES =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.AccessDenied,</span>
<span class="line" id="L5754">                .AGAIN =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.WouldBlock,</span>
<span class="line" id="L5755">                .ALREADY =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.FastOpenAlreadyInProgress,</span>
<span class="line" id="L5756">                .BADF =&gt; <span class="tok-kw">unreachable</span>, <span class="tok-comment">// always a race condition</span>
</span>
<span class="line" id="L5757">                .CONNRESET =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.ConnectionResetByPeer,</span>
<span class="line" id="L5758">                .DESTADDRREQ =&gt; <span class="tok-kw">unreachable</span>, <span class="tok-comment">// The socket is not connection-mode, and no peer address is set.</span>
</span>
<span class="line" id="L5759">                .FAULT =&gt; <span class="tok-kw">unreachable</span>, <span class="tok-comment">// An invalid user space address was specified for an argument.</span>
</span>
<span class="line" id="L5760">                .INTR =&gt; <span class="tok-kw">continue</span>,</span>
<span class="line" id="L5761">                .INVAL =&gt; <span class="tok-kw">unreachable</span>, <span class="tok-comment">// Invalid argument passed.</span>
</span>
<span class="line" id="L5762">                .ISCONN =&gt; <span class="tok-kw">unreachable</span>, <span class="tok-comment">// connection-mode socket was connected already but a recipient was specified</span>
</span>
<span class="line" id="L5763">                .MSGSIZE =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.MessageTooBig,</span>
<span class="line" id="L5764">                .NOBUFS =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.SystemResources,</span>
<span class="line" id="L5765">                .NOMEM =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.SystemResources,</span>
<span class="line" id="L5766">                .NOTSOCK =&gt; <span class="tok-kw">unreachable</span>, <span class="tok-comment">// The file descriptor sockfd does not refer to a socket.</span>
</span>
<span class="line" id="L5767">                .OPNOTSUPP =&gt; <span class="tok-kw">unreachable</span>, <span class="tok-comment">// Some bit in the flags argument is inappropriate for the socket type.</span>
</span>
<span class="line" id="L5768">                .PIPE =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.BrokenPipe,</span>
<span class="line" id="L5769">                .AFNOSUPPORT =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.AddressFamilyNotSupported,</span>
<span class="line" id="L5770">                .LOOP =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.SymLinkLoop,</span>
<span class="line" id="L5771">                .NAMETOOLONG =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.NameTooLong,</span>
<span class="line" id="L5772">                .NOENT =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.FileNotFound,</span>
<span class="line" id="L5773">                .NOTDIR =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.NotDir,</span>
<span class="line" id="L5774">                .HOSTUNREACH =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.NetworkUnreachable,</span>
<span class="line" id="L5775">                .NETUNREACH =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.NetworkUnreachable,</span>
<span class="line" id="L5776">                .NOTCONN =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.SocketNotConnected,</span>
<span class="line" id="L5777">                .NETDOWN =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.NetworkSubsystemFailed,</span>
<span class="line" id="L5778">                <span class="tok-kw">else</span> =&gt; |err| <span class="tok-kw">return</span> unexpectedErrno(err),</span>
<span class="line" id="L5779">            }</span>
<span class="line" id="L5780">        }</span>
<span class="line" id="L5781">    }</span>
<span class="line" id="L5782">}</span>
<span class="line" id="L5783"></span>
<span class="line" id="L5784"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> SendToError = SendMsgError;</span>
<span class="line" id="L5785"></span>
<span class="line" id="L5786"><span class="tok-comment">/// Transmit a message to another socket.</span></span>
<span class="line" id="L5787"><span class="tok-comment">///</span></span>
<span class="line" id="L5788"><span class="tok-comment">/// The `sendto` call may be used only when the socket is in a connected state (so that the intended</span></span>
<span class="line" id="L5789"><span class="tok-comment">/// recipient  is  known). The  following call</span></span>
<span class="line" id="L5790"><span class="tok-comment">///</span></span>
<span class="line" id="L5791"><span class="tok-comment">///     send(sockfd, buf, len, flags);</span></span>
<span class="line" id="L5792"><span class="tok-comment">///</span></span>
<span class="line" id="L5793"><span class="tok-comment">/// is equivalent to</span></span>
<span class="line" id="L5794"><span class="tok-comment">///</span></span>
<span class="line" id="L5795"><span class="tok-comment">///     sendto(sockfd, buf, len, flags, NULL, 0);</span></span>
<span class="line" id="L5796"><span class="tok-comment">///</span></span>
<span class="line" id="L5797"><span class="tok-comment">/// If  sendto()  is used on a connection-mode (`SOCK.STREAM`, `SOCK.SEQPACKET`) socket, the arguments</span></span>
<span class="line" id="L5798"><span class="tok-comment">/// `dest_addr` and `addrlen` are asserted to be `null` and `0` respectively, and asserted</span></span>
<span class="line" id="L5799"><span class="tok-comment">/// that the socket was actually connected.</span></span>
<span class="line" id="L5800"><span class="tok-comment">/// Otherwise, the address of the target is given by `dest_addr` with `addrlen` specifying  its  size.</span></span>
<span class="line" id="L5801"><span class="tok-comment">///</span></span>
<span class="line" id="L5802"><span class="tok-comment">/// If the message is too long to pass atomically through the underlying protocol,</span></span>
<span class="line" id="L5803"><span class="tok-comment">/// `SendError.MessageTooBig` is returned, and the message is not transmitted.</span></span>
<span class="line" id="L5804"><span class="tok-comment">///</span></span>
<span class="line" id="L5805"><span class="tok-comment">/// There is no  indication  of  failure  to  deliver.</span></span>
<span class="line" id="L5806"><span class="tok-comment">///</span></span>
<span class="line" id="L5807"><span class="tok-comment">/// When the message does not fit into the send buffer of  the  socket,  `sendto`  normally  blocks,</span></span>
<span class="line" id="L5808"><span class="tok-comment">/// unless  the socket has been placed in nonblocking I/O mode.  In nonblocking mode it would fail</span></span>
<span class="line" id="L5809"><span class="tok-comment">/// with `SendError.WouldBlock`.  The `select` call may be used  to  determine when it is</span></span>
<span class="line" id="L5810"><span class="tok-comment">/// possible to send more data.</span></span>
<span class="line" id="L5811"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">sendto</span>(</span>
<span class="line" id="L5812">    <span class="tok-comment">/// The file descriptor of the sending socket.</span></span>
<span class="line" id="L5813">    sockfd: socket_t,</span>
<span class="line" id="L5814">    <span class="tok-comment">/// Message to send.</span></span>
<span class="line" id="L5815">    buf: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>,</span>
<span class="line" id="L5816">    flags: <span class="tok-type">u32</span>,</span>
<span class="line" id="L5817">    dest_addr: ?*<span class="tok-kw">const</span> sockaddr,</span>
<span class="line" id="L5818">    addrlen: socklen_t,</span>
<span class="line" id="L5819">) SendToError!<span class="tok-type">usize</span> {</span>
<span class="line" id="L5820">    <span class="tok-kw">while</span> (<span class="tok-null">true</span>) {</span>
<span class="line" id="L5821">        <span class="tok-kw">const</span> rc = system.sendto(sockfd, buf.ptr, buf.len, flags, dest_addr, addrlen);</span>
<span class="line" id="L5822">        <span class="tok-kw">if</span> (builtin.os.tag == .windows) {</span>
<span class="line" id="L5823">            <span class="tok-kw">if</span> (rc == windows.ws2_32.SOCKET_ERROR) {</span>
<span class="line" id="L5824">                <span class="tok-kw">switch</span> (windows.ws2_32.WSAGetLastError()) {</span>
<span class="line" id="L5825">                    .WSAEACCES =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.AccessDenied,</span>
<span class="line" id="L5826">                    .WSAEADDRNOTAVAIL =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.AddressNotAvailable,</span>
<span class="line" id="L5827">                    .WSAECONNRESET =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.ConnectionResetByPeer,</span>
<span class="line" id="L5828">                    .WSAEMSGSIZE =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.MessageTooBig,</span>
<span class="line" id="L5829">                    .WSAENOBUFS =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.SystemResources,</span>
<span class="line" id="L5830">                    .WSAENOTSOCK =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.FileDescriptorNotASocket,</span>
<span class="line" id="L5831">                    .WSAEAFNOSUPPORT =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.AddressFamilyNotSupported,</span>
<span class="line" id="L5832">                    .WSAEDESTADDRREQ =&gt; <span class="tok-kw">unreachable</span>, <span class="tok-comment">// A destination address is required.</span>
</span>
<span class="line" id="L5833">                    .WSAEFAULT =&gt; <span class="tok-kw">unreachable</span>, <span class="tok-comment">// The lpBuffers, lpTo, lpOverlapped, lpNumberOfBytesSent, or lpCompletionRoutine parameters are not part of the user address space, or the lpTo parameter is too small.</span>
</span>
<span class="line" id="L5834">                    .WSAEHOSTUNREACH =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.NetworkUnreachable,</span>
<span class="line" id="L5835">                    <span class="tok-comment">// TODO: WSAEINPROGRESS, WSAEINTR</span>
</span>
<span class="line" id="L5836">                    .WSAEINVAL =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L5837">                    .WSAENETDOWN =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.NetworkSubsystemFailed,</span>
<span class="line" id="L5838">                    .WSAENETRESET =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.ConnectionResetByPeer,</span>
<span class="line" id="L5839">                    .WSAENETUNREACH =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.NetworkUnreachable,</span>
<span class="line" id="L5840">                    .WSAENOTCONN =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.SocketNotConnected,</span>
<span class="line" id="L5841">                    .WSAESHUTDOWN =&gt; <span class="tok-kw">unreachable</span>, <span class="tok-comment">// The socket has been shut down; it is not possible to WSASendTo on a socket after shutdown has been invoked with how set to SD_SEND or SD_BOTH.</span>
</span>
<span class="line" id="L5842">                    .WSAEWOULDBLOCK =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.WouldBlock,</span>
<span class="line" id="L5843">                    .WSANOTINITIALISED =&gt; <span class="tok-kw">unreachable</span>, <span class="tok-comment">// A successful WSAStartup call must occur before using this function.</span>
</span>
<span class="line" id="L5844">                    <span class="tok-kw">else</span> =&gt; |err| <span class="tok-kw">return</span> windows.unexpectedWSAError(err),</span>
<span class="line" id="L5845">                }</span>
<span class="line" id="L5846">            } <span class="tok-kw">else</span> {</span>
<span class="line" id="L5847">                <span class="tok-kw">return</span> <span class="tok-builtin">@intCast</span>(<span class="tok-type">usize</span>, rc);</span>
<span class="line" id="L5848">            }</span>
<span class="line" id="L5849">        } <span class="tok-kw">else</span> {</span>
<span class="line" id="L5850">            <span class="tok-kw">switch</span> (errno(rc)) {</span>
<span class="line" id="L5851">                .SUCCESS =&gt; <span class="tok-kw">return</span> <span class="tok-builtin">@intCast</span>(<span class="tok-type">usize</span>, rc),</span>
<span class="line" id="L5852"></span>
<span class="line" id="L5853">                .ACCES =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.AccessDenied,</span>
<span class="line" id="L5854">                .AGAIN =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.WouldBlock,</span>
<span class="line" id="L5855">                .ALREADY =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.FastOpenAlreadyInProgress,</span>
<span class="line" id="L5856">                .BADF =&gt; <span class="tok-kw">unreachable</span>, <span class="tok-comment">// always a race condition</span>
</span>
<span class="line" id="L5857">                .CONNRESET =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.ConnectionResetByPeer,</span>
<span class="line" id="L5858">                .DESTADDRREQ =&gt; <span class="tok-kw">unreachable</span>, <span class="tok-comment">// The socket is not connection-mode, and no peer address is set.</span>
</span>
<span class="line" id="L5859">                .FAULT =&gt; <span class="tok-kw">unreachable</span>, <span class="tok-comment">// An invalid user space address was specified for an argument.</span>
</span>
<span class="line" id="L5860">                .INTR =&gt; <span class="tok-kw">continue</span>,</span>
<span class="line" id="L5861">                .INVAL =&gt; <span class="tok-kw">unreachable</span>, <span class="tok-comment">// Invalid argument passed.</span>
</span>
<span class="line" id="L5862">                .ISCONN =&gt; <span class="tok-kw">unreachable</span>, <span class="tok-comment">// connection-mode socket was connected already but a recipient was specified</span>
</span>
<span class="line" id="L5863">                .MSGSIZE =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.MessageTooBig,</span>
<span class="line" id="L5864">                .NOBUFS =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.SystemResources,</span>
<span class="line" id="L5865">                .NOMEM =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.SystemResources,</span>
<span class="line" id="L5866">                .NOTSOCK =&gt; <span class="tok-kw">unreachable</span>, <span class="tok-comment">// The file descriptor sockfd does not refer to a socket.</span>
</span>
<span class="line" id="L5867">                .OPNOTSUPP =&gt; <span class="tok-kw">unreachable</span>, <span class="tok-comment">// Some bit in the flags argument is inappropriate for the socket type.</span>
</span>
<span class="line" id="L5868">                .PIPE =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.BrokenPipe,</span>
<span class="line" id="L5869">                .AFNOSUPPORT =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.AddressFamilyNotSupported,</span>
<span class="line" id="L5870">                .LOOP =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.SymLinkLoop,</span>
<span class="line" id="L5871">                .NAMETOOLONG =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.NameTooLong,</span>
<span class="line" id="L5872">                .NOENT =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.FileNotFound,</span>
<span class="line" id="L5873">                .NOTDIR =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.NotDir,</span>
<span class="line" id="L5874">                .HOSTUNREACH =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.NetworkUnreachable,</span>
<span class="line" id="L5875">                .NETUNREACH =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.NetworkUnreachable,</span>
<span class="line" id="L5876">                .NOTCONN =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.SocketNotConnected,</span>
<span class="line" id="L5877">                .NETDOWN =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.NetworkSubsystemFailed,</span>
<span class="line" id="L5878">                <span class="tok-kw">else</span> =&gt; |err| <span class="tok-kw">return</span> unexpectedErrno(err),</span>
<span class="line" id="L5879">            }</span>
<span class="line" id="L5880">        }</span>
<span class="line" id="L5881">    }</span>
<span class="line" id="L5882">}</span>
<span class="line" id="L5883"></span>
<span class="line" id="L5884"><span class="tok-comment">/// Transmit a message to another socket.</span></span>
<span class="line" id="L5885"><span class="tok-comment">///</span></span>
<span class="line" id="L5886"><span class="tok-comment">/// The `send` call may be used only when the socket is in a connected state (so that the intended</span></span>
<span class="line" id="L5887"><span class="tok-comment">/// recipient  is  known).   The  only  difference  between `send` and `write` is the presence of</span></span>
<span class="line" id="L5888"><span class="tok-comment">/// flags.  With a zero flags argument, `send` is equivalent to  `write`.   Also,  the  following</span></span>
<span class="line" id="L5889"><span class="tok-comment">/// call</span></span>
<span class="line" id="L5890"><span class="tok-comment">///</span></span>
<span class="line" id="L5891"><span class="tok-comment">///     send(sockfd, buf, len, flags);</span></span>
<span class="line" id="L5892"><span class="tok-comment">///</span></span>
<span class="line" id="L5893"><span class="tok-comment">/// is equivalent to</span></span>
<span class="line" id="L5894"><span class="tok-comment">///</span></span>
<span class="line" id="L5895"><span class="tok-comment">///     sendto(sockfd, buf, len, flags, NULL, 0);</span></span>
<span class="line" id="L5896"><span class="tok-comment">///</span></span>
<span class="line" id="L5897"><span class="tok-comment">/// There is no  indication  of  failure  to  deliver.</span></span>
<span class="line" id="L5898"><span class="tok-comment">///</span></span>
<span class="line" id="L5899"><span class="tok-comment">/// When the message does not fit into the send buffer of  the  socket,  `send`  normally  blocks,</span></span>
<span class="line" id="L5900"><span class="tok-comment">/// unless  the socket has been placed in nonblocking I/O mode.  In nonblocking mode it would fail</span></span>
<span class="line" id="L5901"><span class="tok-comment">/// with `SendError.WouldBlock`.  The `select` call may be used  to  determine when it is</span></span>
<span class="line" id="L5902"><span class="tok-comment">/// possible to send more data.</span></span>
<span class="line" id="L5903"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">send</span>(</span>
<span class="line" id="L5904">    <span class="tok-comment">/// The file descriptor of the sending socket.</span></span>
<span class="line" id="L5905">    sockfd: socket_t,</span>
<span class="line" id="L5906">    buf: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>,</span>
<span class="line" id="L5907">    flags: <span class="tok-type">u32</span>,</span>
<span class="line" id="L5908">) SendError!<span class="tok-type">usize</span> {</span>
<span class="line" id="L5909">    <span class="tok-kw">return</span> sendto(sockfd, buf, flags, <span class="tok-null">null</span>, <span class="tok-number">0</span>) <span class="tok-kw">catch</span> |err| <span class="tok-kw">switch</span> (err) {</span>
<span class="line" id="L5910">        <span class="tok-kw">error</span>.AddressFamilyNotSupported =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L5911">        <span class="tok-kw">error</span>.SymLinkLoop =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L5912">        <span class="tok-kw">error</span>.NameTooLong =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L5913">        <span class="tok-kw">error</span>.FileNotFound =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L5914">        <span class="tok-kw">error</span>.NotDir =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L5915">        <span class="tok-kw">error</span>.NetworkUnreachable =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L5916">        <span class="tok-kw">error</span>.AddressNotAvailable =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L5917">        <span class="tok-kw">error</span>.SocketNotConnected =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L5918">        <span class="tok-kw">else</span> =&gt; |e| <span class="tok-kw">return</span> e,</span>
<span class="line" id="L5919">    };</span>
<span class="line" id="L5920">}</span>
<span class="line" id="L5921"></span>
<span class="line" id="L5922"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> SendFileError = PReadError || WriteError || SendError;</span>
<span class="line" id="L5923"></span>
<span class="line" id="L5924"><span class="tok-kw">fn</span> <span class="tok-fn">count_iovec_bytes</span>(iovs: []<span class="tok-kw">const</span> iovec_const) <span class="tok-type">usize</span> {</span>
<span class="line" id="L5925">    <span class="tok-kw">var</span> count: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L5926">    <span class="tok-kw">for</span> (iovs) |iov| {</span>
<span class="line" id="L5927">        count += iov.iov_len;</span>
<span class="line" id="L5928">    }</span>
<span class="line" id="L5929">    <span class="tok-kw">return</span> count;</span>
<span class="line" id="L5930">}</span>
<span class="line" id="L5931"></span>
<span class="line" id="L5932"><span class="tok-comment">/// Transfer data between file descriptors, with optional headers and trailers.</span></span>
<span class="line" id="L5933"><span class="tok-comment">/// Returns the number of bytes written, which can be zero.</span></span>
<span class="line" id="L5934"><span class="tok-comment">///</span></span>
<span class="line" id="L5935"><span class="tok-comment">/// The `sendfile` call copies `in_len` bytes from one file descriptor to another. When possible,</span></span>
<span class="line" id="L5936"><span class="tok-comment">/// this is done within the operating system kernel, which can provide better performance</span></span>
<span class="line" id="L5937"><span class="tok-comment">/// characteristics than transferring data from kernel to user space and back, such as with</span></span>
<span class="line" id="L5938"><span class="tok-comment">/// `read` and `write` calls. When `in_len` is `0`, it means to copy until the end of the input file has been</span></span>
<span class="line" id="L5939"><span class="tok-comment">/// reached. Note, however, that partial writes are still possible in this case.</span></span>
<span class="line" id="L5940"><span class="tok-comment">///</span></span>
<span class="line" id="L5941"><span class="tok-comment">/// `in_fd` must be a file descriptor opened for reading, and `out_fd` must be a file descriptor</span></span>
<span class="line" id="L5942"><span class="tok-comment">/// opened for writing. They may be any kind of file descriptor; however, if `in_fd` is not a regular</span></span>
<span class="line" id="L5943"><span class="tok-comment">/// file system file, it may cause this function to fall back to calling `read` and `write`, in which case</span></span>
<span class="line" id="L5944"><span class="tok-comment">/// atomicity guarantees no longer apply.</span></span>
<span class="line" id="L5945"><span class="tok-comment">///</span></span>
<span class="line" id="L5946"><span class="tok-comment">/// Copying begins reading at `in_offset`. The input file descriptor seek position is ignored and not updated.</span></span>
<span class="line" id="L5947"><span class="tok-comment">/// If the output file descriptor has a seek position, it is updated as bytes are written. When</span></span>
<span class="line" id="L5948"><span class="tok-comment">/// `in_offset` is past the end of the input file, it successfully reads 0 bytes.</span></span>
<span class="line" id="L5949"><span class="tok-comment">///</span></span>
<span class="line" id="L5950"><span class="tok-comment">/// `flags` has different meanings per operating system; refer to the respective man pages.</span></span>
<span class="line" id="L5951"><span class="tok-comment">///</span></span>
<span class="line" id="L5952"><span class="tok-comment">/// These systems support atomically sending everything, including headers and trailers:</span></span>
<span class="line" id="L5953"><span class="tok-comment">/// * macOS</span></span>
<span class="line" id="L5954"><span class="tok-comment">/// * FreeBSD</span></span>
<span class="line" id="L5955"><span class="tok-comment">///</span></span>
<span class="line" id="L5956"><span class="tok-comment">/// These systems support in-kernel data copying, but headers and trailers are not sent atomically:</span></span>
<span class="line" id="L5957"><span class="tok-comment">/// * Linux</span></span>
<span class="line" id="L5958"><span class="tok-comment">///</span></span>
<span class="line" id="L5959"><span class="tok-comment">/// Other systems fall back to calling `read` / `write`.</span></span>
<span class="line" id="L5960"><span class="tok-comment">///</span></span>
<span class="line" id="L5961"><span class="tok-comment">/// Linux has a limit on how many bytes may be transferred in one `sendfile` call, which is `0x7ffff000`</span></span>
<span class="line" id="L5962"><span class="tok-comment">/// on both 64-bit and 32-bit systems. This is due to using a signed C int as the return value, as</span></span>
<span class="line" id="L5963"><span class="tok-comment">/// well as stuffing the errno codes into the last `4096` values. This is noted on the `sendfile` man page.</span></span>
<span class="line" id="L5964"><span class="tok-comment">/// The limit on Darwin is `0x7fffffff`, trying to write more than that returns EINVAL.</span></span>
<span class="line" id="L5965"><span class="tok-comment">/// The corresponding POSIX limit on this is `math.maxInt(isize)`.</span></span>
<span class="line" id="L5966"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">sendfile</span>(</span>
<span class="line" id="L5967">    out_fd: fd_t,</span>
<span class="line" id="L5968">    in_fd: fd_t,</span>
<span class="line" id="L5969">    in_offset: <span class="tok-type">u64</span>,</span>
<span class="line" id="L5970">    in_len: <span class="tok-type">u64</span>,</span>
<span class="line" id="L5971">    headers: []<span class="tok-kw">const</span> iovec_const,</span>
<span class="line" id="L5972">    trailers: []<span class="tok-kw">const</span> iovec_const,</span>
<span class="line" id="L5973">    flags: <span class="tok-type">u32</span>,</span>
<span class="line" id="L5974">) SendFileError!<span class="tok-type">usize</span> {</span>
<span class="line" id="L5975">    <span class="tok-kw">var</span> header_done = <span class="tok-null">false</span>;</span>
<span class="line" id="L5976">    <span class="tok-kw">var</span> total_written: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L5977"></span>
<span class="line" id="L5978">    <span class="tok-comment">// Prevents EOVERFLOW.</span>
</span>
<span class="line" id="L5979">    <span class="tok-kw">const</span> size_t = std.meta.Int(.unsigned, <span class="tok-builtin">@typeInfo</span>(<span class="tok-type">usize</span>).Int.bits - <span class="tok-number">1</span>);</span>
<span class="line" id="L5980">    <span class="tok-kw">const</span> max_count = <span class="tok-kw">switch</span> (builtin.os.tag) {</span>
<span class="line" id="L5981">        .linux =&gt; <span class="tok-number">0x7ffff000</span>,</span>
<span class="line" id="L5982">        .macos, .ios, .watchos, .tvos =&gt; math.maxInt(<span class="tok-type">i32</span>),</span>
<span class="line" id="L5983">        <span class="tok-kw">else</span> =&gt; math.maxInt(size_t),</span>
<span class="line" id="L5984">    };</span>
<span class="line" id="L5985"></span>
<span class="line" id="L5986">    <span class="tok-kw">switch</span> (builtin.os.tag) {</span>
<span class="line" id="L5987">        .linux =&gt; sf: {</span>
<span class="line" id="L5988">            <span class="tok-comment">// sendfile() first appeared in Linux 2.2, glibc 2.1.</span>
</span>
<span class="line" id="L5989">            <span class="tok-kw">const</span> call_sf = <span class="tok-kw">comptime</span> <span class="tok-kw">if</span> (builtin.link_libc)</span>
<span class="line" id="L5990">                std.c.versionCheck(.{ .major = <span class="tok-number">2</span>, .minor = <span class="tok-number">1</span> }).ok</span>
<span class="line" id="L5991">            <span class="tok-kw">else</span></span>
<span class="line" id="L5992">                builtin.os.version_range.linux.range.max.order(.{ .major = <span class="tok-number">2</span>, .minor = <span class="tok-number">2</span> }) != .lt;</span>
<span class="line" id="L5993">            <span class="tok-kw">if</span> (!call_sf) <span class="tok-kw">break</span> :sf;</span>
<span class="line" id="L5994"></span>
<span class="line" id="L5995">            <span class="tok-kw">if</span> (headers.len != <span class="tok-number">0</span>) {</span>
<span class="line" id="L5996">                <span class="tok-kw">const</span> amt = <span class="tok-kw">try</span> writev(out_fd, headers);</span>
<span class="line" id="L5997">                total_written += amt;</span>
<span class="line" id="L5998">                <span class="tok-kw">if</span> (amt &lt; count_iovec_bytes(headers)) <span class="tok-kw">return</span> total_written;</span>
<span class="line" id="L5999">                header_done = <span class="tok-null">true</span>;</span>
<span class="line" id="L6000">            }</span>
<span class="line" id="L6001"></span>
<span class="line" id="L6002">            <span class="tok-comment">// Here we match BSD behavior, making a zero count value send as many bytes as possible.</span>
</span>
<span class="line" id="L6003">            <span class="tok-kw">const</span> adjusted_count_tmp = <span class="tok-kw">if</span> (in_len == <span class="tok-number">0</span>) max_count <span class="tok-kw">else</span> <span class="tok-builtin">@minimum</span>(in_len, <span class="tok-builtin">@as</span>(size_t, max_count));</span>
<span class="line" id="L6004">            <span class="tok-comment">// TODO we should not need this cast; improve return type of @minimum</span>
</span>
<span class="line" id="L6005">            <span class="tok-kw">const</span> adjusted_count = <span class="tok-builtin">@intCast</span>(<span class="tok-type">usize</span>, adjusted_count_tmp);</span>
<span class="line" id="L6006"></span>
<span class="line" id="L6007">            <span class="tok-kw">const</span> sendfile_sym = <span class="tok-kw">if</span> (builtin.link_libc)</span>
<span class="line" id="L6008">                system.sendfile64</span>
<span class="line" id="L6009">            <span class="tok-kw">else</span></span>
<span class="line" id="L6010">                system.sendfile;</span>
<span class="line" id="L6011"></span>
<span class="line" id="L6012">            <span class="tok-kw">while</span> (<span class="tok-null">true</span>) {</span>
<span class="line" id="L6013">                <span class="tok-kw">var</span> offset: off_t = <span class="tok-builtin">@bitCast</span>(off_t, in_offset);</span>
<span class="line" id="L6014">                <span class="tok-kw">const</span> rc = sendfile_sym(out_fd, in_fd, &amp;offset, adjusted_count);</span>
<span class="line" id="L6015">                <span class="tok-kw">switch</span> (errno(rc)) {</span>
<span class="line" id="L6016">                    .SUCCESS =&gt; {</span>
<span class="line" id="L6017">                        <span class="tok-kw">const</span> amt = <span class="tok-builtin">@bitCast</span>(<span class="tok-type">usize</span>, rc);</span>
<span class="line" id="L6018">                        total_written += amt;</span>
<span class="line" id="L6019">                        <span class="tok-kw">if</span> (in_len == <span class="tok-number">0</span> <span class="tok-kw">and</span> amt == <span class="tok-number">0</span>) {</span>
<span class="line" id="L6020">                            <span class="tok-comment">// We have detected EOF from `in_fd`.</span>
</span>
<span class="line" id="L6021">                            <span class="tok-kw">break</span>;</span>
<span class="line" id="L6022">                        } <span class="tok-kw">else</span> <span class="tok-kw">if</span> (amt &lt; in_len) {</span>
<span class="line" id="L6023">                            <span class="tok-kw">return</span> total_written;</span>
<span class="line" id="L6024">                        } <span class="tok-kw">else</span> {</span>
<span class="line" id="L6025">                            <span class="tok-kw">break</span>;</span>
<span class="line" id="L6026">                        }</span>
<span class="line" id="L6027">                    },</span>
<span class="line" id="L6028"></span>
<span class="line" id="L6029">                    .BADF =&gt; <span class="tok-kw">unreachable</span>, <span class="tok-comment">// Always a race condition.</span>
</span>
<span class="line" id="L6030">                    .FAULT =&gt; <span class="tok-kw">unreachable</span>, <span class="tok-comment">// Segmentation fault.</span>
</span>
<span class="line" id="L6031">                    .OVERFLOW =&gt; <span class="tok-kw">unreachable</span>, <span class="tok-comment">// We avoid passing too large of a `count`.</span>
</span>
<span class="line" id="L6032">                    .NOTCONN =&gt; <span class="tok-kw">unreachable</span>, <span class="tok-comment">// `out_fd` is an unconnected socket.</span>
</span>
<span class="line" id="L6033"></span>
<span class="line" id="L6034">                    .INVAL, .NOSYS =&gt; {</span>
<span class="line" id="L6035">                        <span class="tok-comment">// EINVAL could be any of the following situations:</span>
</span>
<span class="line" id="L6036">                        <span class="tok-comment">// * Descriptor is not valid or locked</span>
</span>
<span class="line" id="L6037">                        <span class="tok-comment">// * an mmap(2)-like operation is  not  available  for in_fd</span>
</span>
<span class="line" id="L6038">                        <span class="tok-comment">// * count is negative</span>
</span>
<span class="line" id="L6039">                        <span class="tok-comment">// * out_fd has the O.APPEND flag set</span>
</span>
<span class="line" id="L6040">                        <span class="tok-comment">// Because of the &quot;mmap(2)-like operation&quot; possibility, we fall back to doing read/write</span>
</span>
<span class="line" id="L6041">                        <span class="tok-comment">// manually, the same as ENOSYS.</span>
</span>
<span class="line" id="L6042">                        <span class="tok-kw">break</span> :sf;</span>
<span class="line" id="L6043">                    },</span>
<span class="line" id="L6044">                    .AGAIN =&gt; <span class="tok-kw">if</span> (std.event.Loop.instance) |loop| {</span>
<span class="line" id="L6045">                        loop.waitUntilFdWritable(out_fd);</span>
<span class="line" id="L6046">                        <span class="tok-kw">continue</span>;</span>
<span class="line" id="L6047">                    } <span class="tok-kw">else</span> {</span>
<span class="line" id="L6048">                        <span class="tok-kw">return</span> <span class="tok-kw">error</span>.WouldBlock;</span>
<span class="line" id="L6049">                    },</span>
<span class="line" id="L6050">                    .IO =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.InputOutput,</span>
<span class="line" id="L6051">                    .PIPE =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.BrokenPipe,</span>
<span class="line" id="L6052">                    .NOMEM =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.SystemResources,</span>
<span class="line" id="L6053">                    .NXIO =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.Unseekable,</span>
<span class="line" id="L6054">                    .SPIPE =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.Unseekable,</span>
<span class="line" id="L6055">                    <span class="tok-kw">else</span> =&gt; |err| {</span>
<span class="line" id="L6056">                        unexpectedErrno(err) <span class="tok-kw">catch</span> {};</span>
<span class="line" id="L6057">                        <span class="tok-kw">break</span> :sf;</span>
<span class="line" id="L6058">                    },</span>
<span class="line" id="L6059">                }</span>
<span class="line" id="L6060">            }</span>
<span class="line" id="L6061"></span>
<span class="line" id="L6062">            <span class="tok-kw">if</span> (trailers.len != <span class="tok-number">0</span>) {</span>
<span class="line" id="L6063">                total_written += <span class="tok-kw">try</span> writev(out_fd, trailers);</span>
<span class="line" id="L6064">            }</span>
<span class="line" id="L6065"></span>
<span class="line" id="L6066">            <span class="tok-kw">return</span> total_written;</span>
<span class="line" id="L6067">        },</span>
<span class="line" id="L6068">        .freebsd =&gt; sf: {</span>
<span class="line" id="L6069">            <span class="tok-kw">var</span> hdtr_data: std.c.sf_hdtr = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L6070">            <span class="tok-kw">var</span> hdtr: ?*std.c.sf_hdtr = <span class="tok-null">null</span>;</span>
<span class="line" id="L6071">            <span class="tok-kw">if</span> (headers.len != <span class="tok-number">0</span> <span class="tok-kw">or</span> trailers.len != <span class="tok-number">0</span>) {</span>
<span class="line" id="L6072">                <span class="tok-comment">// Here we carefully avoid `@intCast` by returning partial writes when</span>
</span>
<span class="line" id="L6073">                <span class="tok-comment">// too many io vectors are provided.</span>
</span>
<span class="line" id="L6074">                <span class="tok-kw">const</span> hdr_cnt = math.cast(<span class="tok-type">u31</span>, headers.len) <span class="tok-kw">orelse</span> math.maxInt(<span class="tok-type">u31</span>);</span>
<span class="line" id="L6075">                <span class="tok-kw">if</span> (headers.len &gt; hdr_cnt) <span class="tok-kw">return</span> writev(out_fd, headers);</span>
<span class="line" id="L6076"></span>
<span class="line" id="L6077">                <span class="tok-kw">const</span> trl_cnt = math.cast(<span class="tok-type">u31</span>, trailers.len) <span class="tok-kw">orelse</span> math.maxInt(<span class="tok-type">u31</span>);</span>
<span class="line" id="L6078"></span>
<span class="line" id="L6079">                hdtr_data = std.c.sf_hdtr{</span>
<span class="line" id="L6080">                    .headers = headers.ptr,</span>
<span class="line" id="L6081">                    .hdr_cnt = hdr_cnt,</span>
<span class="line" id="L6082">                    .trailers = trailers.ptr,</span>
<span class="line" id="L6083">                    .trl_cnt = trl_cnt,</span>
<span class="line" id="L6084">                };</span>
<span class="line" id="L6085">                hdtr = &amp;hdtr_data;</span>
<span class="line" id="L6086">            }</span>
<span class="line" id="L6087"></span>
<span class="line" id="L6088">            <span class="tok-kw">const</span> adjusted_count = <span class="tok-builtin">@minimum</span>(in_len, max_count);</span>
<span class="line" id="L6089"></span>
<span class="line" id="L6090">            <span class="tok-kw">while</span> (<span class="tok-null">true</span>) {</span>
<span class="line" id="L6091">                <span class="tok-kw">var</span> sbytes: off_t = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L6092">                <span class="tok-kw">const</span> offset = <span class="tok-builtin">@bitCast</span>(off_t, in_offset);</span>
<span class="line" id="L6093">                <span class="tok-kw">const</span> err = errno(system.sendfile(in_fd, out_fd, offset, adjusted_count, hdtr, &amp;sbytes, flags));</span>
<span class="line" id="L6094">                <span class="tok-kw">const</span> amt = <span class="tok-builtin">@bitCast</span>(<span class="tok-type">usize</span>, sbytes);</span>
<span class="line" id="L6095">                <span class="tok-kw">switch</span> (err) {</span>
<span class="line" id="L6096">                    .SUCCESS =&gt; <span class="tok-kw">return</span> amt,</span>
<span class="line" id="L6097"></span>
<span class="line" id="L6098">                    .BADF =&gt; <span class="tok-kw">unreachable</span>, <span class="tok-comment">// Always a race condition.</span>
</span>
<span class="line" id="L6099">                    .FAULT =&gt; <span class="tok-kw">unreachable</span>, <span class="tok-comment">// Segmentation fault.</span>
</span>
<span class="line" id="L6100">                    .NOTCONN =&gt; <span class="tok-kw">unreachable</span>, <span class="tok-comment">// `out_fd` is an unconnected socket.</span>
</span>
<span class="line" id="L6101"></span>
<span class="line" id="L6102">                    .INVAL, .OPNOTSUPP, .NOTSOCK, .NOSYS =&gt; {</span>
<span class="line" id="L6103">                        <span class="tok-comment">// EINVAL could be any of the following situations:</span>
</span>
<span class="line" id="L6104">                        <span class="tok-comment">// * The fd argument is not a regular file.</span>
</span>
<span class="line" id="L6105">                        <span class="tok-comment">// * The s argument is not a SOCK.STREAM type socket.</span>
</span>
<span class="line" id="L6106">                        <span class="tok-comment">// * The offset argument is negative.</span>
</span>
<span class="line" id="L6107">                        <span class="tok-comment">// Because of some of these possibilities, we fall back to doing read/write</span>
</span>
<span class="line" id="L6108">                        <span class="tok-comment">// manually, the same as ENOSYS.</span>
</span>
<span class="line" id="L6109">                        <span class="tok-kw">break</span> :sf;</span>
<span class="line" id="L6110">                    },</span>
<span class="line" id="L6111"></span>
<span class="line" id="L6112">                    .INTR =&gt; <span class="tok-kw">if</span> (amt != <span class="tok-number">0</span>) <span class="tok-kw">return</span> amt <span class="tok-kw">else</span> <span class="tok-kw">continue</span>,</span>
<span class="line" id="L6113"></span>
<span class="line" id="L6114">                    .AGAIN =&gt; <span class="tok-kw">if</span> (amt != <span class="tok-number">0</span>) {</span>
<span class="line" id="L6115">                        <span class="tok-kw">return</span> amt;</span>
<span class="line" id="L6116">                    } <span class="tok-kw">else</span> <span class="tok-kw">if</span> (std.event.Loop.instance) |loop| {</span>
<span class="line" id="L6117">                        loop.waitUntilFdWritable(out_fd);</span>
<span class="line" id="L6118">                        <span class="tok-kw">continue</span>;</span>
<span class="line" id="L6119">                    } <span class="tok-kw">else</span> {</span>
<span class="line" id="L6120">                        <span class="tok-kw">return</span> <span class="tok-kw">error</span>.WouldBlock;</span>
<span class="line" id="L6121">                    },</span>
<span class="line" id="L6122"></span>
<span class="line" id="L6123">                    .BUSY =&gt; <span class="tok-kw">if</span> (amt != <span class="tok-number">0</span>) {</span>
<span class="line" id="L6124">                        <span class="tok-kw">return</span> amt;</span>
<span class="line" id="L6125">                    } <span class="tok-kw">else</span> <span class="tok-kw">if</span> (std.event.Loop.instance) |loop| {</span>
<span class="line" id="L6126">                        loop.waitUntilFdReadable(in_fd);</span>
<span class="line" id="L6127">                        <span class="tok-kw">continue</span>;</span>
<span class="line" id="L6128">                    } <span class="tok-kw">else</span> {</span>
<span class="line" id="L6129">                        <span class="tok-kw">return</span> <span class="tok-kw">error</span>.WouldBlock;</span>
<span class="line" id="L6130">                    },</span>
<span class="line" id="L6131"></span>
<span class="line" id="L6132">                    .IO =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.InputOutput,</span>
<span class="line" id="L6133">                    .NOBUFS =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.SystemResources,</span>
<span class="line" id="L6134">                    .PIPE =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.BrokenPipe,</span>
<span class="line" id="L6135"></span>
<span class="line" id="L6136">                    <span class="tok-kw">else</span> =&gt; {</span>
<span class="line" id="L6137">                        unexpectedErrno(err) <span class="tok-kw">catch</span> {};</span>
<span class="line" id="L6138">                        <span class="tok-kw">if</span> (amt != <span class="tok-number">0</span>) {</span>
<span class="line" id="L6139">                            <span class="tok-kw">return</span> amt;</span>
<span class="line" id="L6140">                        } <span class="tok-kw">else</span> {</span>
<span class="line" id="L6141">                            <span class="tok-kw">break</span> :sf;</span>
<span class="line" id="L6142">                        }</span>
<span class="line" id="L6143">                    },</span>
<span class="line" id="L6144">                }</span>
<span class="line" id="L6145">            }</span>
<span class="line" id="L6146">        },</span>
<span class="line" id="L6147">        .macos, .ios, .tvos, .watchos =&gt; sf: {</span>
<span class="line" id="L6148">            <span class="tok-kw">var</span> hdtr_data: std.c.sf_hdtr = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L6149">            <span class="tok-kw">var</span> hdtr: ?*std.c.sf_hdtr = <span class="tok-null">null</span>;</span>
<span class="line" id="L6150">            <span class="tok-kw">if</span> (headers.len != <span class="tok-number">0</span> <span class="tok-kw">or</span> trailers.len != <span class="tok-number">0</span>) {</span>
<span class="line" id="L6151">                <span class="tok-comment">// Here we carefully avoid `@intCast` by returning partial writes when</span>
</span>
<span class="line" id="L6152">                <span class="tok-comment">// too many io vectors are provided.</span>
</span>
<span class="line" id="L6153">                <span class="tok-kw">const</span> hdr_cnt = math.cast(<span class="tok-type">u31</span>, headers.len) <span class="tok-kw">orelse</span> math.maxInt(<span class="tok-type">u31</span>);</span>
<span class="line" id="L6154">                <span class="tok-kw">if</span> (headers.len &gt; hdr_cnt) <span class="tok-kw">return</span> writev(out_fd, headers);</span>
<span class="line" id="L6155"></span>
<span class="line" id="L6156">                <span class="tok-kw">const</span> trl_cnt = math.cast(<span class="tok-type">u31</span>, trailers.len) <span class="tok-kw">orelse</span> math.maxInt(<span class="tok-type">u31</span>);</span>
<span class="line" id="L6157"></span>
<span class="line" id="L6158">                hdtr_data = std.c.sf_hdtr{</span>
<span class="line" id="L6159">                    .headers = headers.ptr,</span>
<span class="line" id="L6160">                    .hdr_cnt = hdr_cnt,</span>
<span class="line" id="L6161">                    .trailers = trailers.ptr,</span>
<span class="line" id="L6162">                    .trl_cnt = trl_cnt,</span>
<span class="line" id="L6163">                };</span>
<span class="line" id="L6164">                hdtr = &amp;hdtr_data;</span>
<span class="line" id="L6165">            }</span>
<span class="line" id="L6166"></span>
<span class="line" id="L6167">            <span class="tok-kw">const</span> adjusted_count_temporary = <span class="tok-builtin">@minimum</span>(in_len, <span class="tok-builtin">@as</span>(<span class="tok-type">u63</span>, max_count));</span>
<span class="line" id="L6168">            <span class="tok-comment">// TODO we should not need this int cast; improve the return type of `@minimum`</span>
</span>
<span class="line" id="L6169">            <span class="tok-kw">const</span> adjusted_count = <span class="tok-builtin">@intCast</span>(<span class="tok-type">u63</span>, adjusted_count_temporary);</span>
<span class="line" id="L6170"></span>
<span class="line" id="L6171">            <span class="tok-kw">while</span> (<span class="tok-null">true</span>) {</span>
<span class="line" id="L6172">                <span class="tok-kw">var</span> sbytes: off_t = adjusted_count;</span>
<span class="line" id="L6173">                <span class="tok-kw">const</span> signed_offset = <span class="tok-builtin">@bitCast</span>(<span class="tok-type">i64</span>, in_offset);</span>
<span class="line" id="L6174">                <span class="tok-kw">const</span> err = errno(system.sendfile(in_fd, out_fd, signed_offset, &amp;sbytes, hdtr, flags));</span>
<span class="line" id="L6175">                <span class="tok-kw">const</span> amt = <span class="tok-builtin">@bitCast</span>(<span class="tok-type">usize</span>, sbytes);</span>
<span class="line" id="L6176">                <span class="tok-kw">switch</span> (err) {</span>
<span class="line" id="L6177">                    .SUCCESS =&gt; <span class="tok-kw">return</span> amt,</span>
<span class="line" id="L6178"></span>
<span class="line" id="L6179">                    .BADF =&gt; <span class="tok-kw">unreachable</span>, <span class="tok-comment">// Always a race condition.</span>
</span>
<span class="line" id="L6180">                    .FAULT =&gt; <span class="tok-kw">unreachable</span>, <span class="tok-comment">// Segmentation fault.</span>
</span>
<span class="line" id="L6181">                    .INVAL =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L6182">                    .NOTCONN =&gt; <span class="tok-kw">unreachable</span>, <span class="tok-comment">// `out_fd` is an unconnected socket.</span>
</span>
<span class="line" id="L6183"></span>
<span class="line" id="L6184">                    .OPNOTSUPP, .NOTSOCK, .NOSYS =&gt; <span class="tok-kw">break</span> :sf,</span>
<span class="line" id="L6185"></span>
<span class="line" id="L6186">                    .INTR =&gt; <span class="tok-kw">if</span> (amt != <span class="tok-number">0</span>) <span class="tok-kw">return</span> amt <span class="tok-kw">else</span> <span class="tok-kw">continue</span>,</span>
<span class="line" id="L6187"></span>
<span class="line" id="L6188">                    .AGAIN =&gt; <span class="tok-kw">if</span> (amt != <span class="tok-number">0</span>) {</span>
<span class="line" id="L6189">                        <span class="tok-kw">return</span> amt;</span>
<span class="line" id="L6190">                    } <span class="tok-kw">else</span> <span class="tok-kw">if</span> (std.event.Loop.instance) |loop| {</span>
<span class="line" id="L6191">                        loop.waitUntilFdWritable(out_fd);</span>
<span class="line" id="L6192">                        <span class="tok-kw">continue</span>;</span>
<span class="line" id="L6193">                    } <span class="tok-kw">else</span> {</span>
<span class="line" id="L6194">                        <span class="tok-kw">return</span> <span class="tok-kw">error</span>.WouldBlock;</span>
<span class="line" id="L6195">                    },</span>
<span class="line" id="L6196"></span>
<span class="line" id="L6197">                    .IO =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.InputOutput,</span>
<span class="line" id="L6198">                    .PIPE =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.BrokenPipe,</span>
<span class="line" id="L6199"></span>
<span class="line" id="L6200">                    <span class="tok-kw">else</span> =&gt; {</span>
<span class="line" id="L6201">                        unexpectedErrno(err) <span class="tok-kw">catch</span> {};</span>
<span class="line" id="L6202">                        <span class="tok-kw">if</span> (amt != <span class="tok-number">0</span>) {</span>
<span class="line" id="L6203">                            <span class="tok-kw">return</span> amt;</span>
<span class="line" id="L6204">                        } <span class="tok-kw">else</span> {</span>
<span class="line" id="L6205">                            <span class="tok-kw">break</span> :sf;</span>
<span class="line" id="L6206">                        }</span>
<span class="line" id="L6207">                    },</span>
<span class="line" id="L6208">                }</span>
<span class="line" id="L6209">            }</span>
<span class="line" id="L6210">        },</span>
<span class="line" id="L6211">        <span class="tok-kw">else</span> =&gt; {}, <span class="tok-comment">// fall back to read/write</span>
</span>
<span class="line" id="L6212">    }</span>
<span class="line" id="L6213"></span>
<span class="line" id="L6214">    <span class="tok-kw">if</span> (headers.len != <span class="tok-number">0</span> <span class="tok-kw">and</span> !header_done) {</span>
<span class="line" id="L6215">        <span class="tok-kw">const</span> amt = <span class="tok-kw">try</span> writev(out_fd, headers);</span>
<span class="line" id="L6216">        total_written += amt;</span>
<span class="line" id="L6217">        <span class="tok-kw">if</span> (amt &lt; count_iovec_bytes(headers)) <span class="tok-kw">return</span> total_written;</span>
<span class="line" id="L6218">    }</span>
<span class="line" id="L6219"></span>
<span class="line" id="L6220">    rw: {</span>
<span class="line" id="L6221">        <span class="tok-kw">var</span> buf: [<span class="tok-number">8</span> * <span class="tok-number">4096</span>]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L6222">        <span class="tok-comment">// Here we match BSD behavior, making a zero count value send as many bytes as possible.</span>
</span>
<span class="line" id="L6223">        <span class="tok-kw">const</span> adjusted_count_tmp = <span class="tok-kw">if</span> (in_len == <span class="tok-number">0</span>) buf.len <span class="tok-kw">else</span> <span class="tok-builtin">@minimum</span>(buf.len, in_len);</span>
<span class="line" id="L6224">        <span class="tok-comment">// TODO we should not need this cast; improve return type of @minimum</span>
</span>
<span class="line" id="L6225">        <span class="tok-kw">const</span> adjusted_count = <span class="tok-builtin">@intCast</span>(<span class="tok-type">usize</span>, adjusted_count_tmp);</span>
<span class="line" id="L6226">        <span class="tok-kw">const</span> amt_read = <span class="tok-kw">try</span> pread(in_fd, buf[<span class="tok-number">0</span>..adjusted_count], in_offset);</span>
<span class="line" id="L6227">        <span class="tok-kw">if</span> (amt_read == <span class="tok-number">0</span>) {</span>
<span class="line" id="L6228">            <span class="tok-kw">if</span> (in_len == <span class="tok-number">0</span>) {</span>
<span class="line" id="L6229">                <span class="tok-comment">// We have detected EOF from `in_fd`.</span>
</span>
<span class="line" id="L6230">                <span class="tok-kw">break</span> :rw;</span>
<span class="line" id="L6231">            } <span class="tok-kw">else</span> {</span>
<span class="line" id="L6232">                <span class="tok-kw">return</span> total_written;</span>
<span class="line" id="L6233">            }</span>
<span class="line" id="L6234">        }</span>
<span class="line" id="L6235">        <span class="tok-kw">const</span> amt_written = <span class="tok-kw">try</span> write(out_fd, buf[<span class="tok-number">0</span>..amt_read]);</span>
<span class="line" id="L6236">        total_written += amt_written;</span>
<span class="line" id="L6237">        <span class="tok-kw">if</span> (amt_written &lt; in_len <span class="tok-kw">or</span> in_len == <span class="tok-number">0</span>) <span class="tok-kw">return</span> total_written;</span>
<span class="line" id="L6238">    }</span>
<span class="line" id="L6239"></span>
<span class="line" id="L6240">    <span class="tok-kw">if</span> (trailers.len != <span class="tok-number">0</span>) {</span>
<span class="line" id="L6241">        total_written += <span class="tok-kw">try</span> writev(out_fd, trailers);</span>
<span class="line" id="L6242">    }</span>
<span class="line" id="L6243"></span>
<span class="line" id="L6244">    <span class="tok-kw">return</span> total_written;</span>
<span class="line" id="L6245">}</span>
<span class="line" id="L6246"></span>
<span class="line" id="L6247"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> CopyFileRangeError = <span class="tok-kw">error</span>{</span>
<span class="line" id="L6248">    FileTooBig,</span>
<span class="line" id="L6249">    InputOutput,</span>
<span class="line" id="L6250">    <span class="tok-comment">/// `fd_in` is not open for reading; or `fd_out` is not open  for  writing;</span></span>
<span class="line" id="L6251">    <span class="tok-comment">/// or the  `O.APPEND`  flag  is  set  for `fd_out`.</span></span>
<span class="line" id="L6252">    FilesOpenedWithWrongFlags,</span>
<span class="line" id="L6253">    IsDir,</span>
<span class="line" id="L6254">    OutOfMemory,</span>
<span class="line" id="L6255">    NoSpaceLeft,</span>
<span class="line" id="L6256">    Unseekable,</span>
<span class="line" id="L6257">    PermissionDenied,</span>
<span class="line" id="L6258">    FileBusy,</span>
<span class="line" id="L6259">} || PReadError || PWriteError || UnexpectedError;</span>
<span class="line" id="L6260"></span>
<span class="line" id="L6261"><span class="tok-kw">var</span> has_copy_file_range_syscall = std.atomic.Atomic(<span class="tok-type">bool</span>).init(<span class="tok-null">true</span>);</span>
<span class="line" id="L6262"></span>
<span class="line" id="L6263"><span class="tok-comment">/// Transfer data between file descriptors at specified offsets.</span></span>
<span class="line" id="L6264"><span class="tok-comment">/// Returns the number of bytes written, which can less than requested.</span></span>
<span class="line" id="L6265"><span class="tok-comment">///</span></span>
<span class="line" id="L6266"><span class="tok-comment">/// The `copy_file_range` call copies `len` bytes from one file descriptor to another. When possible,</span></span>
<span class="line" id="L6267"><span class="tok-comment">/// this is done within the operating system kernel, which can provide better performance</span></span>
<span class="line" id="L6268"><span class="tok-comment">/// characteristics than transferring data from kernel to user space and back, such as with</span></span>
<span class="line" id="L6269"><span class="tok-comment">/// `pread` and `pwrite` calls.</span></span>
<span class="line" id="L6270"><span class="tok-comment">///</span></span>
<span class="line" id="L6271"><span class="tok-comment">/// `fd_in` must be a file descriptor opened for reading, and `fd_out` must be a file descriptor</span></span>
<span class="line" id="L6272"><span class="tok-comment">/// opened for writing. They may be any kind of file descriptor; however, if `fd_in` is not a regular</span></span>
<span class="line" id="L6273"><span class="tok-comment">/// file system file, it may cause this function to fall back to calling `pread` and `pwrite`, in which case</span></span>
<span class="line" id="L6274"><span class="tok-comment">/// atomicity guarantees no longer apply.</span></span>
<span class="line" id="L6275"><span class="tok-comment">///</span></span>
<span class="line" id="L6276"><span class="tok-comment">/// If `fd_in` and `fd_out` are the same, source and target ranges must not overlap.</span></span>
<span class="line" id="L6277"><span class="tok-comment">/// The file descriptor seek positions are ignored and not updated.</span></span>
<span class="line" id="L6278"><span class="tok-comment">/// When `off_in` is past the end of the input file, it successfully reads 0 bytes.</span></span>
<span class="line" id="L6279"><span class="tok-comment">///</span></span>
<span class="line" id="L6280"><span class="tok-comment">/// `flags` has different meanings per operating system; refer to the respective man pages.</span></span>
<span class="line" id="L6281"><span class="tok-comment">///</span></span>
<span class="line" id="L6282"><span class="tok-comment">/// These systems support in-kernel data copying:</span></span>
<span class="line" id="L6283"><span class="tok-comment">/// * Linux 4.5 (cross-filesystem 5.3)</span></span>
<span class="line" id="L6284"><span class="tok-comment">///</span></span>
<span class="line" id="L6285"><span class="tok-comment">/// Other systems fall back to calling `pread` / `pwrite`.</span></span>
<span class="line" id="L6286"><span class="tok-comment">///</span></span>
<span class="line" id="L6287"><span class="tok-comment">/// Maximum offsets on Linux are `math.maxInt(i64)`.</span></span>
<span class="line" id="L6288"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">copy_file_range</span>(fd_in: fd_t, off_in: <span class="tok-type">u64</span>, fd_out: fd_t, off_out: <span class="tok-type">u64</span>, len: <span class="tok-type">usize</span>, flags: <span class="tok-type">u32</span>) CopyFileRangeError!<span class="tok-type">usize</span> {</span>
<span class="line" id="L6289">    <span class="tok-kw">const</span> call_cfr = <span class="tok-kw">comptime</span> <span class="tok-kw">if</span> (builtin.os.tag == .wasi)</span>
<span class="line" id="L6290">        <span class="tok-comment">// WASI-libc doesn't have copy_file_range.</span>
</span>
<span class="line" id="L6291">        <span class="tok-null">false</span></span>
<span class="line" id="L6292">    <span class="tok-kw">else</span> <span class="tok-kw">if</span> (builtin.link_libc)</span>
<span class="line" id="L6293">        std.c.versionCheck(.{ .major = <span class="tok-number">2</span>, .minor = <span class="tok-number">27</span>, .patch = <span class="tok-number">0</span> }).ok</span>
<span class="line" id="L6294">    <span class="tok-kw">else</span></span>
<span class="line" id="L6295">        builtin.os.isAtLeast(.linux, .{ .major = <span class="tok-number">4</span>, .minor = <span class="tok-number">5</span> }) <span class="tok-kw">orelse</span> <span class="tok-null">true</span>;</span>
<span class="line" id="L6296"></span>
<span class="line" id="L6297">    <span class="tok-kw">if</span> (call_cfr <span class="tok-kw">and</span> has_copy_file_range_syscall.load(.Monotonic)) {</span>
<span class="line" id="L6298">        <span class="tok-kw">var</span> off_in_copy = <span class="tok-builtin">@bitCast</span>(<span class="tok-type">i64</span>, off_in);</span>
<span class="line" id="L6299">        <span class="tok-kw">var</span> off_out_copy = <span class="tok-builtin">@bitCast</span>(<span class="tok-type">i64</span>, off_out);</span>
<span class="line" id="L6300"></span>
<span class="line" id="L6301">        <span class="tok-kw">const</span> rc = system.copy_file_range(fd_in, &amp;off_in_copy, fd_out, &amp;off_out_copy, len, flags);</span>
<span class="line" id="L6302">        <span class="tok-kw">switch</span> (system.getErrno(rc)) {</span>
<span class="line" id="L6303">            .SUCCESS =&gt; <span class="tok-kw">return</span> <span class="tok-builtin">@intCast</span>(<span class="tok-type">usize</span>, rc),</span>
<span class="line" id="L6304">            .BADF =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.FilesOpenedWithWrongFlags,</span>
<span class="line" id="L6305">            .FBIG =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.FileTooBig,</span>
<span class="line" id="L6306">            .IO =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.InputOutput,</span>
<span class="line" id="L6307">            .ISDIR =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.IsDir,</span>
<span class="line" id="L6308">            .NOMEM =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.OutOfMemory,</span>
<span class="line" id="L6309">            .NOSPC =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.NoSpaceLeft,</span>
<span class="line" id="L6310">            .OVERFLOW =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.Unseekable,</span>
<span class="line" id="L6311">            .PERM =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.PermissionDenied,</span>
<span class="line" id="L6312">            .TXTBSY =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.FileBusy,</span>
<span class="line" id="L6313">            <span class="tok-comment">// these may not be regular files, try fallback</span>
</span>
<span class="line" id="L6314">            .INVAL =&gt; {},</span>
<span class="line" id="L6315">            <span class="tok-comment">// support for cross-filesystem copy added in Linux 5.3, use fallback</span>
</span>
<span class="line" id="L6316">            .XDEV =&gt; {},</span>
<span class="line" id="L6317">            <span class="tok-comment">// syscall added in Linux 4.5, use fallback</span>
</span>
<span class="line" id="L6318">            .NOSYS =&gt; {</span>
<span class="line" id="L6319">                has_copy_file_range_syscall.store(<span class="tok-null">false</span>, .Monotonic);</span>
<span class="line" id="L6320">            },</span>
<span class="line" id="L6321">            <span class="tok-kw">else</span> =&gt; |err| <span class="tok-kw">return</span> unexpectedErrno(err),</span>
<span class="line" id="L6322">        }</span>
<span class="line" id="L6323">    }</span>
<span class="line" id="L6324"></span>
<span class="line" id="L6325">    <span class="tok-kw">var</span> buf: [<span class="tok-number">8</span> * <span class="tok-number">4096</span>]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L6326">    <span class="tok-kw">const</span> adjusted_count = <span class="tok-builtin">@minimum</span>(buf.len, len);</span>
<span class="line" id="L6327">    <span class="tok-kw">const</span> amt_read = <span class="tok-kw">try</span> pread(fd_in, buf[<span class="tok-number">0</span>..adjusted_count], off_in);</span>
<span class="line" id="L6328">    <span class="tok-comment">// TODO without @as the line below fails to compile for wasm32-wasi:</span>
</span>
<span class="line" id="L6329">    <span class="tok-comment">// error: integer value 0 cannot be coerced to type 'os.PWriteError!usize'</span>
</span>
<span class="line" id="L6330">    <span class="tok-kw">if</span> (amt_read == <span class="tok-number">0</span>) <span class="tok-kw">return</span> <span class="tok-builtin">@as</span>(<span class="tok-type">usize</span>, <span class="tok-number">0</span>);</span>
<span class="line" id="L6331">    <span class="tok-kw">return</span> pwrite(fd_out, buf[<span class="tok-number">0</span>..amt_read], off_out);</span>
<span class="line" id="L6332">}</span>
<span class="line" id="L6333"></span>
<span class="line" id="L6334"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> PollError = <span class="tok-kw">error</span>{</span>
<span class="line" id="L6335">    <span class="tok-comment">/// The network subsystem has failed.</span></span>
<span class="line" id="L6336">    NetworkSubsystemFailed,</span>
<span class="line" id="L6337"></span>
<span class="line" id="L6338">    <span class="tok-comment">/// The kernel had no space to allocate file descriptor tables.</span></span>
<span class="line" id="L6339">    SystemResources,</span>
<span class="line" id="L6340">} || UnexpectedError;</span>
<span class="line" id="L6341"></span>
<span class="line" id="L6342"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">poll</span>(fds: []pollfd, timeout: <span class="tok-type">i32</span>) PollError!<span class="tok-type">usize</span> {</span>
<span class="line" id="L6343">    <span class="tok-kw">while</span> (<span class="tok-null">true</span>) {</span>
<span class="line" id="L6344">        <span class="tok-kw">const</span> fds_count = math.cast(nfds_t, fds.len) <span class="tok-kw">orelse</span> <span class="tok-kw">return</span> <span class="tok-kw">error</span>.SystemResources;</span>
<span class="line" id="L6345">        <span class="tok-kw">const</span> rc = system.poll(fds.ptr, fds_count, timeout);</span>
<span class="line" id="L6346">        <span class="tok-kw">if</span> (builtin.os.tag == .windows) {</span>
<span class="line" id="L6347">            <span class="tok-kw">if</span> (rc == windows.ws2_32.SOCKET_ERROR) {</span>
<span class="line" id="L6348">                <span class="tok-kw">switch</span> (windows.ws2_32.WSAGetLastError()) {</span>
<span class="line" id="L6349">                    .WSANOTINITIALISED =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L6350">                    .WSAENETDOWN =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.NetworkSubsystemFailed,</span>
<span class="line" id="L6351">                    .WSAENOBUFS =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.SystemResources,</span>
<span class="line" id="L6352">                    <span class="tok-comment">// TODO: handle more errors</span>
</span>
<span class="line" id="L6353">                    <span class="tok-kw">else</span> =&gt; |err| <span class="tok-kw">return</span> windows.unexpectedWSAError(err),</span>
<span class="line" id="L6354">                }</span>
<span class="line" id="L6355">            } <span class="tok-kw">else</span> {</span>
<span class="line" id="L6356">                <span class="tok-kw">return</span> <span class="tok-builtin">@intCast</span>(<span class="tok-type">usize</span>, rc);</span>
<span class="line" id="L6357">            }</span>
<span class="line" id="L6358">        } <span class="tok-kw">else</span> {</span>
<span class="line" id="L6359">            <span class="tok-kw">switch</span> (errno(rc)) {</span>
<span class="line" id="L6360">                .SUCCESS =&gt; <span class="tok-kw">return</span> <span class="tok-builtin">@intCast</span>(<span class="tok-type">usize</span>, rc),</span>
<span class="line" id="L6361">                .FAULT =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L6362">                .INTR =&gt; <span class="tok-kw">continue</span>,</span>
<span class="line" id="L6363">                .INVAL =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L6364">                .NOMEM =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.SystemResources,</span>
<span class="line" id="L6365">                <span class="tok-kw">else</span> =&gt; |err| <span class="tok-kw">return</span> unexpectedErrno(err),</span>
<span class="line" id="L6366">            }</span>
<span class="line" id="L6367">        }</span>
<span class="line" id="L6368">        <span class="tok-kw">unreachable</span>;</span>
<span class="line" id="L6369">    }</span>
<span class="line" id="L6370">}</span>
<span class="line" id="L6371"></span>
<span class="line" id="L6372"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> PPollError = <span class="tok-kw">error</span>{</span>
<span class="line" id="L6373">    <span class="tok-comment">/// The operation was interrupted by a delivery of a signal before it could complete.</span></span>
<span class="line" id="L6374">    SignalInterrupt,</span>
<span class="line" id="L6375"></span>
<span class="line" id="L6376">    <span class="tok-comment">/// The kernel had no space to allocate file descriptor tables.</span></span>
<span class="line" id="L6377">    SystemResources,</span>
<span class="line" id="L6378">} || UnexpectedError;</span>
<span class="line" id="L6379"></span>
<span class="line" id="L6380"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">ppoll</span>(fds: []pollfd, timeout: ?*<span class="tok-kw">const</span> timespec, mask: ?*<span class="tok-kw">const</span> sigset_t) PPollError!<span class="tok-type">usize</span> {</span>
<span class="line" id="L6381">    <span class="tok-kw">var</span> ts: timespec = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L6382">    <span class="tok-kw">var</span> ts_ptr: ?*timespec = <span class="tok-null">null</span>;</span>
<span class="line" id="L6383">    <span class="tok-kw">if</span> (timeout) |timeout_ns| {</span>
<span class="line" id="L6384">        ts_ptr = &amp;ts;</span>
<span class="line" id="L6385">        ts = timeout_ns.*;</span>
<span class="line" id="L6386">    }</span>
<span class="line" id="L6387">    <span class="tok-kw">const</span> fds_count = math.cast(nfds_t, fds.len) <span class="tok-kw">orelse</span> <span class="tok-kw">return</span> <span class="tok-kw">error</span>.SystemResources;</span>
<span class="line" id="L6388">    <span class="tok-kw">const</span> rc = system.ppoll(fds.ptr, fds_count, ts_ptr, mask);</span>
<span class="line" id="L6389">    <span class="tok-kw">switch</span> (errno(rc)) {</span>
<span class="line" id="L6390">        .SUCCESS =&gt; <span class="tok-kw">return</span> <span class="tok-builtin">@intCast</span>(<span class="tok-type">usize</span>, rc),</span>
<span class="line" id="L6391">        .FAULT =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L6392">        .INTR =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.SignalInterrupt,</span>
<span class="line" id="L6393">        .INVAL =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L6394">        .NOMEM =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.SystemResources,</span>
<span class="line" id="L6395">        <span class="tok-kw">else</span> =&gt; |err| <span class="tok-kw">return</span> unexpectedErrno(err),</span>
<span class="line" id="L6396">    }</span>
<span class="line" id="L6397">}</span>
<span class="line" id="L6398"></span>
<span class="line" id="L6399"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> RecvFromError = <span class="tok-kw">error</span>{</span>
<span class="line" id="L6400">    <span class="tok-comment">/// The socket is marked nonblocking and the requested operation would block, and</span></span>
<span class="line" id="L6401">    <span class="tok-comment">/// there is no global event loop configured.</span></span>
<span class="line" id="L6402">    WouldBlock,</span>
<span class="line" id="L6403"></span>
<span class="line" id="L6404">    <span class="tok-comment">/// A remote host refused to allow the network connection, typically because it is not</span></span>
<span class="line" id="L6405">    <span class="tok-comment">/// running the requested service.</span></span>
<span class="line" id="L6406">    ConnectionRefused,</span>
<span class="line" id="L6407"></span>
<span class="line" id="L6408">    <span class="tok-comment">/// Could not allocate kernel memory.</span></span>
<span class="line" id="L6409">    SystemResources,</span>
<span class="line" id="L6410"></span>
<span class="line" id="L6411">    ConnectionResetByPeer,</span>
<span class="line" id="L6412"></span>
<span class="line" id="L6413">    <span class="tok-comment">/// The socket has not been bound.</span></span>
<span class="line" id="L6414">    SocketNotBound,</span>
<span class="line" id="L6415"></span>
<span class="line" id="L6416">    <span class="tok-comment">/// The UDP message was too big for the buffer and part of it has been discarded</span></span>
<span class="line" id="L6417">    MessageTooBig,</span>
<span class="line" id="L6418"></span>
<span class="line" id="L6419">    <span class="tok-comment">/// The network subsystem has failed.</span></span>
<span class="line" id="L6420">    NetworkSubsystemFailed,</span>
<span class="line" id="L6421"></span>
<span class="line" id="L6422">    <span class="tok-comment">/// The socket is not connected (connection-oriented sockets only).</span></span>
<span class="line" id="L6423">    SocketNotConnected,</span>
<span class="line" id="L6424">} || UnexpectedError;</span>
<span class="line" id="L6425"></span>
<span class="line" id="L6426"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">recv</span>(sock: socket_t, buf: []<span class="tok-type">u8</span>, flags: <span class="tok-type">u32</span>) RecvFromError!<span class="tok-type">usize</span> {</span>
<span class="line" id="L6427">    <span class="tok-kw">return</span> recvfrom(sock, buf, flags, <span class="tok-null">null</span>, <span class="tok-null">null</span>);</span>
<span class="line" id="L6428">}</span>
<span class="line" id="L6429"></span>
<span class="line" id="L6430"><span class="tok-comment">/// If `sockfd` is opened in non blocking mode, the function will</span></span>
<span class="line" id="L6431"><span class="tok-comment">/// return error.WouldBlock when EAGAIN is received.</span></span>
<span class="line" id="L6432"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">recvfrom</span>(</span>
<span class="line" id="L6433">    sockfd: socket_t,</span>
<span class="line" id="L6434">    buf: []<span class="tok-type">u8</span>,</span>
<span class="line" id="L6435">    flags: <span class="tok-type">u32</span>,</span>
<span class="line" id="L6436">    src_addr: ?*sockaddr,</span>
<span class="line" id="L6437">    addrlen: ?*socklen_t,</span>
<span class="line" id="L6438">) RecvFromError!<span class="tok-type">usize</span> {</span>
<span class="line" id="L6439">    <span class="tok-kw">while</span> (<span class="tok-null">true</span>) {</span>
<span class="line" id="L6440">        <span class="tok-kw">const</span> rc = system.recvfrom(sockfd, buf.ptr, buf.len, flags, src_addr, addrlen);</span>
<span class="line" id="L6441">        <span class="tok-kw">if</span> (builtin.os.tag == .windows) {</span>
<span class="line" id="L6442">            <span class="tok-kw">if</span> (rc == windows.ws2_32.SOCKET_ERROR) {</span>
<span class="line" id="L6443">                <span class="tok-kw">switch</span> (windows.ws2_32.WSAGetLastError()) {</span>
<span class="line" id="L6444">                    .WSANOTINITIALISED =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L6445">                    .WSAECONNRESET =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.ConnectionResetByPeer,</span>
<span class="line" id="L6446">                    .WSAEINVAL =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.SocketNotBound,</span>
<span class="line" id="L6447">                    .WSAEMSGSIZE =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.MessageTooBig,</span>
<span class="line" id="L6448">                    .WSAENETDOWN =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.NetworkSubsystemFailed,</span>
<span class="line" id="L6449">                    .WSAENOTCONN =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.SocketNotConnected,</span>
<span class="line" id="L6450">                    .WSAEWOULDBLOCK =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.WouldBlock,</span>
<span class="line" id="L6451">                    <span class="tok-comment">// TODO: handle more errors</span>
</span>
<span class="line" id="L6452">                    <span class="tok-kw">else</span> =&gt; |err| <span class="tok-kw">return</span> windows.unexpectedWSAError(err),</span>
<span class="line" id="L6453">                }</span>
<span class="line" id="L6454">            } <span class="tok-kw">else</span> {</span>
<span class="line" id="L6455">                <span class="tok-kw">return</span> <span class="tok-builtin">@intCast</span>(<span class="tok-type">usize</span>, rc);</span>
<span class="line" id="L6456">            }</span>
<span class="line" id="L6457">        } <span class="tok-kw">else</span> {</span>
<span class="line" id="L6458">            <span class="tok-kw">switch</span> (errno(rc)) {</span>
<span class="line" id="L6459">                .SUCCESS =&gt; <span class="tok-kw">return</span> <span class="tok-builtin">@intCast</span>(<span class="tok-type">usize</span>, rc),</span>
<span class="line" id="L6460">                .BADF =&gt; <span class="tok-kw">unreachable</span>, <span class="tok-comment">// always a race condition</span>
</span>
<span class="line" id="L6461">                .FAULT =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L6462">                .INVAL =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L6463">                .NOTCONN =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L6464">                .NOTSOCK =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L6465">                .INTR =&gt; <span class="tok-kw">continue</span>,</span>
<span class="line" id="L6466">                .AGAIN =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.WouldBlock,</span>
<span class="line" id="L6467">                .NOMEM =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.SystemResources,</span>
<span class="line" id="L6468">                .CONNREFUSED =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.ConnectionRefused,</span>
<span class="line" id="L6469">                .CONNRESET =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.ConnectionResetByPeer,</span>
<span class="line" id="L6470">                <span class="tok-kw">else</span> =&gt; |err| <span class="tok-kw">return</span> unexpectedErrno(err),</span>
<span class="line" id="L6471">            }</span>
<span class="line" id="L6472">        }</span>
<span class="line" id="L6473">    }</span>
<span class="line" id="L6474">}</span>
<span class="line" id="L6475"></span>
<span class="line" id="L6476"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> DnExpandError = <span class="tok-kw">error</span>{InvalidDnsPacket};</span>
<span class="line" id="L6477"></span>
<span class="line" id="L6478"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">dn_expand</span>(</span>
<span class="line" id="L6479">    msg: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>,</span>
<span class="line" id="L6480">    comp_dn: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>,</span>
<span class="line" id="L6481">    exp_dn: []<span class="tok-type">u8</span>,</span>
<span class="line" id="L6482">) DnExpandError!<span class="tok-type">usize</span> {</span>
<span class="line" id="L6483">    <span class="tok-comment">// This implementation is ported from musl libc.</span>
</span>
<span class="line" id="L6484">    <span class="tok-comment">// A more idiomatic &quot;ziggy&quot; implementation would be welcome.</span>
</span>
<span class="line" id="L6485">    <span class="tok-kw">var</span> p = comp_dn.ptr;</span>
<span class="line" id="L6486">    <span class="tok-kw">var</span> len: <span class="tok-type">usize</span> = std.math.maxInt(<span class="tok-type">usize</span>);</span>
<span class="line" id="L6487">    <span class="tok-kw">const</span> end = msg.ptr + msg.len;</span>
<span class="line" id="L6488">    <span class="tok-kw">if</span> (p == end <span class="tok-kw">or</span> exp_dn.len == <span class="tok-number">0</span>) <span class="tok-kw">return</span> <span class="tok-kw">error</span>.InvalidDnsPacket;</span>
<span class="line" id="L6489">    <span class="tok-kw">var</span> dest = exp_dn.ptr;</span>
<span class="line" id="L6490">    <span class="tok-kw">const</span> dend = dest + <span class="tok-builtin">@minimum</span>(exp_dn.len, <span class="tok-number">254</span>);</span>
<span class="line" id="L6491">    <span class="tok-comment">// detect reference loop using an iteration counter</span>
</span>
<span class="line" id="L6492">    <span class="tok-kw">var</span> i: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L6493">    <span class="tok-kw">while</span> (i &lt; msg.len) : (i += <span class="tok-number">2</span>) {</span>
<span class="line" id="L6494">        <span class="tok-comment">// loop invariants: p&lt;end, dest&lt;dend</span>
</span>
<span class="line" id="L6495">        <span class="tok-kw">if</span> ((p[<span class="tok-number">0</span>] &amp; <span class="tok-number">0xc0</span>) != <span class="tok-number">0</span>) {</span>
<span class="line" id="L6496">            <span class="tok-kw">if</span> (p + <span class="tok-number">1</span> == end) <span class="tok-kw">return</span> <span class="tok-kw">error</span>.InvalidDnsPacket;</span>
<span class="line" id="L6497">            <span class="tok-kw">var</span> j = ((p[<span class="tok-number">0</span>] &amp; <span class="tok-builtin">@as</span>(<span class="tok-type">usize</span>, <span class="tok-number">0x3f</span>)) &lt;&lt; <span class="tok-number">8</span>) | p[<span class="tok-number">1</span>];</span>
<span class="line" id="L6498">            <span class="tok-kw">if</span> (len == std.math.maxInt(<span class="tok-type">usize</span>)) len = <span class="tok-builtin">@ptrToInt</span>(p) + <span class="tok-number">2</span> - <span class="tok-builtin">@ptrToInt</span>(comp_dn.ptr);</span>
<span class="line" id="L6499">            <span class="tok-kw">if</span> (j &gt;= msg.len) <span class="tok-kw">return</span> <span class="tok-kw">error</span>.InvalidDnsPacket;</span>
<span class="line" id="L6500">            p = msg.ptr + j;</span>
<span class="line" id="L6501">        } <span class="tok-kw">else</span> <span class="tok-kw">if</span> (p[<span class="tok-number">0</span>] != <span class="tok-number">0</span>) {</span>
<span class="line" id="L6502">            <span class="tok-kw">if</span> (dest != exp_dn.ptr) {</span>
<span class="line" id="L6503">                dest[<span class="tok-number">0</span>] = <span class="tok-str">'.'</span>;</span>
<span class="line" id="L6504">                dest += <span class="tok-number">1</span>;</span>
<span class="line" id="L6505">            }</span>
<span class="line" id="L6506">            <span class="tok-kw">var</span> j = p[<span class="tok-number">0</span>];</span>
<span class="line" id="L6507">            p += <span class="tok-number">1</span>;</span>
<span class="line" id="L6508">            <span class="tok-kw">if</span> (j &gt;= <span class="tok-builtin">@ptrToInt</span>(end) - <span class="tok-builtin">@ptrToInt</span>(p) <span class="tok-kw">or</span> j &gt;= <span class="tok-builtin">@ptrToInt</span>(dend) - <span class="tok-builtin">@ptrToInt</span>(dest)) {</span>
<span class="line" id="L6509">                <span class="tok-kw">return</span> <span class="tok-kw">error</span>.InvalidDnsPacket;</span>
<span class="line" id="L6510">            }</span>
<span class="line" id="L6511">            <span class="tok-kw">while</span> (j != <span class="tok-number">0</span>) {</span>
<span class="line" id="L6512">                j -= <span class="tok-number">1</span>;</span>
<span class="line" id="L6513">                dest[<span class="tok-number">0</span>] = p[<span class="tok-number">0</span>];</span>
<span class="line" id="L6514">                dest += <span class="tok-number">1</span>;</span>
<span class="line" id="L6515">                p += <span class="tok-number">1</span>;</span>
<span class="line" id="L6516">            }</span>
<span class="line" id="L6517">        } <span class="tok-kw">else</span> {</span>
<span class="line" id="L6518">            dest[<span class="tok-number">0</span>] = <span class="tok-number">0</span>;</span>
<span class="line" id="L6519">            <span class="tok-kw">if</span> (len == std.math.maxInt(<span class="tok-type">usize</span>)) len = <span class="tok-builtin">@ptrToInt</span>(p) + <span class="tok-number">1</span> - <span class="tok-builtin">@ptrToInt</span>(comp_dn.ptr);</span>
<span class="line" id="L6520">            <span class="tok-kw">return</span> len;</span>
<span class="line" id="L6521">        }</span>
<span class="line" id="L6522">    }</span>
<span class="line" id="L6523">    <span class="tok-kw">return</span> <span class="tok-kw">error</span>.InvalidDnsPacket;</span>
<span class="line" id="L6524">}</span>
<span class="line" id="L6525"></span>
<span class="line" id="L6526"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> SetSockOptError = <span class="tok-kw">error</span>{</span>
<span class="line" id="L6527">    <span class="tok-comment">/// The socket is already connected, and a specified option cannot be set while the socket is connected.</span></span>
<span class="line" id="L6528">    AlreadyConnected,</span>
<span class="line" id="L6529"></span>
<span class="line" id="L6530">    <span class="tok-comment">/// The option is not supported by the protocol.</span></span>
<span class="line" id="L6531">    InvalidProtocolOption,</span>
<span class="line" id="L6532"></span>
<span class="line" id="L6533">    <span class="tok-comment">/// The send and receive timeout values are too big to fit into the timeout fields in the socket structure.</span></span>
<span class="line" id="L6534">    TimeoutTooBig,</span>
<span class="line" id="L6535"></span>
<span class="line" id="L6536">    <span class="tok-comment">/// Insufficient resources are available in the system to complete the call.</span></span>
<span class="line" id="L6537">    SystemResources,</span>
<span class="line" id="L6538"></span>
<span class="line" id="L6539">    <span class="tok-comment">// Setting the socket option requires more elevated permissions.</span>
</span>
<span class="line" id="L6540">    PermissionDenied,</span>
<span class="line" id="L6541"></span>
<span class="line" id="L6542">    NetworkSubsystemFailed,</span>
<span class="line" id="L6543">    FileDescriptorNotASocket,</span>
<span class="line" id="L6544">    SocketNotBound,</span>
<span class="line" id="L6545">} || UnexpectedError;</span>
<span class="line" id="L6546"></span>
<span class="line" id="L6547"><span class="tok-comment">/// Set a socket's options.</span></span>
<span class="line" id="L6548"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">setsockopt</span>(fd: socket_t, level: <span class="tok-type">u32</span>, optname: <span class="tok-type">u32</span>, opt: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) SetSockOptError!<span class="tok-type">void</span> {</span>
<span class="line" id="L6549">    <span class="tok-kw">if</span> (builtin.os.tag == .windows) {</span>
<span class="line" id="L6550">        <span class="tok-kw">const</span> rc = windows.ws2_32.setsockopt(fd, <span class="tok-builtin">@intCast</span>(<span class="tok-type">i32</span>, level), <span class="tok-builtin">@intCast</span>(<span class="tok-type">i32</span>, optname), opt.ptr, <span class="tok-builtin">@intCast</span>(<span class="tok-type">i32</span>, opt.len));</span>
<span class="line" id="L6551">        <span class="tok-kw">if</span> (rc == windows.ws2_32.SOCKET_ERROR) {</span>
<span class="line" id="L6552">            <span class="tok-kw">switch</span> (windows.ws2_32.WSAGetLastError()) {</span>
<span class="line" id="L6553">                .WSANOTINITIALISED =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L6554">                .WSAENETDOWN =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.NetworkSubsystemFailed,</span>
<span class="line" id="L6555">                .WSAEFAULT =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L6556">                .WSAENOTSOCK =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.FileDescriptorNotASocket,</span>
<span class="line" id="L6557">                .WSAEINVAL =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.SocketNotBound,</span>
<span class="line" id="L6558">                <span class="tok-kw">else</span> =&gt; |err| <span class="tok-kw">return</span> windows.unexpectedWSAError(err),</span>
<span class="line" id="L6559">            }</span>
<span class="line" id="L6560">        }</span>
<span class="line" id="L6561">        <span class="tok-kw">return</span>;</span>
<span class="line" id="L6562">    } <span class="tok-kw">else</span> {</span>
<span class="line" id="L6563">        <span class="tok-kw">switch</span> (errno(system.setsockopt(fd, level, optname, opt.ptr, <span class="tok-builtin">@intCast</span>(socklen_t, opt.len)))) {</span>
<span class="line" id="L6564">            .SUCCESS =&gt; {},</span>
<span class="line" id="L6565">            .BADF =&gt; <span class="tok-kw">unreachable</span>, <span class="tok-comment">// always a race condition</span>
</span>
<span class="line" id="L6566">            .NOTSOCK =&gt; <span class="tok-kw">unreachable</span>, <span class="tok-comment">// always a race condition</span>
</span>
<span class="line" id="L6567">            .INVAL =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L6568">            .FAULT =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L6569">            .DOM =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.TimeoutTooBig,</span>
<span class="line" id="L6570">            .ISCONN =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.AlreadyConnected,</span>
<span class="line" id="L6571">            .NOPROTOOPT =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.InvalidProtocolOption,</span>
<span class="line" id="L6572">            .NOMEM =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.SystemResources,</span>
<span class="line" id="L6573">            .NOBUFS =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.SystemResources,</span>
<span class="line" id="L6574">            .PERM =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.PermissionDenied,</span>
<span class="line" id="L6575">            <span class="tok-kw">else</span> =&gt; |err| <span class="tok-kw">return</span> unexpectedErrno(err),</span>
<span class="line" id="L6576">        }</span>
<span class="line" id="L6577">    }</span>
<span class="line" id="L6578">}</span>
<span class="line" id="L6579"></span>
<span class="line" id="L6580"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> MemFdCreateError = <span class="tok-kw">error</span>{</span>
<span class="line" id="L6581">    SystemFdQuotaExceeded,</span>
<span class="line" id="L6582">    ProcessFdQuotaExceeded,</span>
<span class="line" id="L6583">    OutOfMemory,</span>
<span class="line" id="L6584"></span>
<span class="line" id="L6585">    <span class="tok-comment">/// memfd_create is available in Linux 3.17 and later. This error is returned</span></span>
<span class="line" id="L6586">    <span class="tok-comment">/// for older kernel versions.</span></span>
<span class="line" id="L6587">    SystemOutdated,</span>
<span class="line" id="L6588">} || UnexpectedError;</span>
<span class="line" id="L6589"></span>
<span class="line" id="L6590"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">memfd_createZ</span>(name: [*:<span class="tok-number">0</span>]<span class="tok-kw">const</span> <span class="tok-type">u8</span>, flags: <span class="tok-type">u32</span>) MemFdCreateError!fd_t {</span>
<span class="line" id="L6591">    <span class="tok-kw">switch</span> (builtin.os.tag) {</span>
<span class="line" id="L6592">        .linux =&gt; {</span>
<span class="line" id="L6593">            <span class="tok-comment">// memfd_create is available only in glibc versions starting with 2.27.</span>
</span>
<span class="line" id="L6594">            <span class="tok-kw">const</span> use_c = std.c.versionCheck(.{ .major = <span class="tok-number">2</span>, .minor = <span class="tok-number">27</span>, .patch = <span class="tok-number">0</span> }).ok;</span>
<span class="line" id="L6595">            <span class="tok-kw">const</span> sys = <span class="tok-kw">if</span> (use_c) std.c <span class="tok-kw">else</span> linux;</span>
<span class="line" id="L6596">            <span class="tok-kw">const</span> getErrno = <span class="tok-kw">if</span> (use_c) std.c.getErrno <span class="tok-kw">else</span> linux.getErrno;</span>
<span class="line" id="L6597">            <span class="tok-kw">const</span> rc = sys.memfd_create(name, flags);</span>
<span class="line" id="L6598">            <span class="tok-kw">switch</span> (getErrno(rc)) {</span>
<span class="line" id="L6599">                .SUCCESS =&gt; <span class="tok-kw">return</span> <span class="tok-builtin">@intCast</span>(fd_t, rc),</span>
<span class="line" id="L6600">                .FAULT =&gt; <span class="tok-kw">unreachable</span>, <span class="tok-comment">// name has invalid memory</span>
</span>
<span class="line" id="L6601">                .INVAL =&gt; <span class="tok-kw">unreachable</span>, <span class="tok-comment">// name/flags are faulty</span>
</span>
<span class="line" id="L6602">                .NFILE =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.SystemFdQuotaExceeded,</span>
<span class="line" id="L6603">                .MFILE =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.ProcessFdQuotaExceeded,</span>
<span class="line" id="L6604">                .NOMEM =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.OutOfMemory,</span>
<span class="line" id="L6605">                .NOSYS =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.SystemOutdated,</span>
<span class="line" id="L6606">                <span class="tok-kw">else</span> =&gt; |err| <span class="tok-kw">return</span> unexpectedErrno(err),</span>
<span class="line" id="L6607">            }</span>
<span class="line" id="L6608">        },</span>
<span class="line" id="L6609">        .freebsd =&gt; {</span>
<span class="line" id="L6610">            <span class="tok-kw">const</span> rc = system.memfd_create(name, flags);</span>
<span class="line" id="L6611">            <span class="tok-kw">switch</span> (errno(rc)) {</span>
<span class="line" id="L6612">                .SUCCESS =&gt; <span class="tok-kw">return</span> rc,</span>
<span class="line" id="L6613">                .BADF =&gt; <span class="tok-kw">unreachable</span>, <span class="tok-comment">// name argument NULL</span>
</span>
<span class="line" id="L6614">                .INVAL =&gt; <span class="tok-kw">unreachable</span>, <span class="tok-comment">// name too long or invalid/unsupported flags.</span>
</span>
<span class="line" id="L6615">                .MFILE =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.ProcessFdQuotaExceeded,</span>
<span class="line" id="L6616">                .NFILE =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.SystemFdQuotaExceeded,</span>
<span class="line" id="L6617">                .NOSYS =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.SystemOutdated,</span>
<span class="line" id="L6618">                <span class="tok-kw">else</span> =&gt; |err| <span class="tok-kw">return</span> unexpectedErrno(err),</span>
<span class="line" id="L6619">            }</span>
<span class="line" id="L6620">        },</span>
<span class="line" id="L6621">        <span class="tok-kw">else</span> =&gt; <span class="tok-builtin">@compileError</span>(<span class="tok-str">&quot;target OS does not support memfd_create()&quot;</span>),</span>
<span class="line" id="L6622">    }</span>
<span class="line" id="L6623">}</span>
<span class="line" id="L6624"></span>
<span class="line" id="L6625"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> MFD_NAME_PREFIX = <span class="tok-str">&quot;memfd:&quot;</span>;</span>
<span class="line" id="L6626"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> MFD_MAX_NAME_LEN = NAME_MAX - MFD_NAME_PREFIX.len;</span>
<span class="line" id="L6627"><span class="tok-kw">fn</span> <span class="tok-fn">toMemFdPath</span>(name: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) ![MFD_MAX_NAME_LEN:<span class="tok-number">0</span>]<span class="tok-type">u8</span> {</span>
<span class="line" id="L6628">    <span class="tok-kw">var</span> path_with_null: [MFD_MAX_NAME_LEN:<span class="tok-number">0</span>]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L6629">    <span class="tok-comment">// &gt;= rather than &gt; to make room for the null byte</span>
</span>
<span class="line" id="L6630">    <span class="tok-kw">if</span> (name.len &gt;= MFD_MAX_NAME_LEN) <span class="tok-kw">return</span> <span class="tok-kw">error</span>.NameTooLong;</span>
<span class="line" id="L6631">    mem.copy(<span class="tok-type">u8</span>, &amp;path_with_null, name);</span>
<span class="line" id="L6632">    path_with_null[name.len] = <span class="tok-number">0</span>;</span>
<span class="line" id="L6633">    <span class="tok-kw">return</span> path_with_null;</span>
<span class="line" id="L6634">}</span>
<span class="line" id="L6635"></span>
<span class="line" id="L6636"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">memfd_create</span>(name: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>, flags: <span class="tok-type">u32</span>) !fd_t {</span>
<span class="line" id="L6637">    <span class="tok-kw">const</span> name_t = <span class="tok-kw">try</span> toMemFdPath(name);</span>
<span class="line" id="L6638">    <span class="tok-kw">return</span> memfd_createZ(&amp;name_t, flags);</span>
<span class="line" id="L6639">}</span>
<span class="line" id="L6640"></span>
<span class="line" id="L6641"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">getrusage</span>(who: <span class="tok-type">i32</span>) rusage {</span>
<span class="line" id="L6642">    <span class="tok-kw">var</span> result: rusage = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L6643">    <span class="tok-kw">const</span> rc = system.getrusage(who, &amp;result);</span>
<span class="line" id="L6644">    <span class="tok-kw">switch</span> (errno(rc)) {</span>
<span class="line" id="L6645">        .SUCCESS =&gt; <span class="tok-kw">return</span> result,</span>
<span class="line" id="L6646">        .INVAL =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L6647">        .FAULT =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L6648">        <span class="tok-kw">else</span> =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L6649">    }</span>
<span class="line" id="L6650">}</span>
<span class="line" id="L6651"></span>
<span class="line" id="L6652"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> TermiosGetError = <span class="tok-kw">error</span>{NotATerminal} || UnexpectedError;</span>
<span class="line" id="L6653"></span>
<span class="line" id="L6654"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">tcgetattr</span>(handle: fd_t) TermiosGetError!termios {</span>
<span class="line" id="L6655">    <span class="tok-kw">while</span> (<span class="tok-null">true</span>) {</span>
<span class="line" id="L6656">        <span class="tok-kw">var</span> term: termios = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L6657">        <span class="tok-kw">switch</span> (errno(system.tcgetattr(handle, &amp;term))) {</span>
<span class="line" id="L6658">            .SUCCESS =&gt; <span class="tok-kw">return</span> term,</span>
<span class="line" id="L6659">            .INTR =&gt; <span class="tok-kw">continue</span>,</span>
<span class="line" id="L6660">            .BADF =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L6661">            .NOTTY =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.NotATerminal,</span>
<span class="line" id="L6662">            <span class="tok-kw">else</span> =&gt; |err| <span class="tok-kw">return</span> unexpectedErrno(err),</span>
<span class="line" id="L6663">        }</span>
<span class="line" id="L6664">    }</span>
<span class="line" id="L6665">}</span>
<span class="line" id="L6666"></span>
<span class="line" id="L6667"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> TermiosSetError = TermiosGetError || <span class="tok-kw">error</span>{ProcessOrphaned};</span>
<span class="line" id="L6668"></span>
<span class="line" id="L6669"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">tcsetattr</span>(handle: fd_t, optional_action: TCSA, termios_p: termios) TermiosSetError!<span class="tok-type">void</span> {</span>
<span class="line" id="L6670">    <span class="tok-kw">while</span> (<span class="tok-null">true</span>) {</span>
<span class="line" id="L6671">        <span class="tok-kw">switch</span> (errno(system.tcsetattr(handle, optional_action, &amp;termios_p))) {</span>
<span class="line" id="L6672">            .SUCCESS =&gt; <span class="tok-kw">return</span>,</span>
<span class="line" id="L6673">            .BADF =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L6674">            .INTR =&gt; <span class="tok-kw">continue</span>,</span>
<span class="line" id="L6675">            .INVAL =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L6676">            .NOTTY =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.NotATerminal,</span>
<span class="line" id="L6677">            .IO =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.ProcessOrphaned,</span>
<span class="line" id="L6678">            <span class="tok-kw">else</span> =&gt; |err| <span class="tok-kw">return</span> unexpectedErrno(err),</span>
<span class="line" id="L6679">        }</span>
<span class="line" id="L6680">    }</span>
<span class="line" id="L6681">}</span>
<span class="line" id="L6682"></span>
<span class="line" id="L6683"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> IoCtl_SIOCGIFINDEX_Error = <span class="tok-kw">error</span>{</span>
<span class="line" id="L6684">    FileSystem,</span>
<span class="line" id="L6685">    InterfaceNotFound,</span>
<span class="line" id="L6686">} || UnexpectedError;</span>
<span class="line" id="L6687"></span>
<span class="line" id="L6688"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">ioctl_SIOCGIFINDEX</span>(fd: fd_t, ifr: *ifreq) IoCtl_SIOCGIFINDEX_Error!<span class="tok-type">void</span> {</span>
<span class="line" id="L6689">    <span class="tok-kw">while</span> (<span class="tok-null">true</span>) {</span>
<span class="line" id="L6690">        <span class="tok-kw">switch</span> (errno(system.ioctl(fd, SIOCGIFINDEX, <span class="tok-builtin">@ptrToInt</span>(ifr)))) {</span>
<span class="line" id="L6691">            .SUCCESS =&gt; <span class="tok-kw">return</span>,</span>
<span class="line" id="L6692">            .INVAL =&gt; <span class="tok-kw">unreachable</span>, <span class="tok-comment">// Bad parameters.</span>
</span>
<span class="line" id="L6693">            .NOTTY =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L6694">            .NXIO =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L6695">            .BADF =&gt; <span class="tok-kw">unreachable</span>, <span class="tok-comment">// Always a race condition.</span>
</span>
<span class="line" id="L6696">            .FAULT =&gt; <span class="tok-kw">unreachable</span>, <span class="tok-comment">// Bad pointer parameter.</span>
</span>
<span class="line" id="L6697">            .INTR =&gt; <span class="tok-kw">continue</span>,</span>
<span class="line" id="L6698">            .IO =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.FileSystem,</span>
<span class="line" id="L6699">            .NODEV =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.InterfaceNotFound,</span>
<span class="line" id="L6700">            <span class="tok-kw">else</span> =&gt; |err| <span class="tok-kw">return</span> unexpectedErrno(err),</span>
<span class="line" id="L6701">        }</span>
<span class="line" id="L6702">    }</span>
<span class="line" id="L6703">}</span>
<span class="line" id="L6704"></span>
<span class="line" id="L6705"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">signalfd</span>(fd: fd_t, mask: *<span class="tok-kw">const</span> sigset_t, flags: <span class="tok-type">u32</span>) !fd_t {</span>
<span class="line" id="L6706">    <span class="tok-kw">const</span> rc = system.signalfd(fd, mask, flags);</span>
<span class="line" id="L6707">    <span class="tok-kw">switch</span> (errno(rc)) {</span>
<span class="line" id="L6708">        .SUCCESS =&gt; <span class="tok-kw">return</span> <span class="tok-builtin">@intCast</span>(fd_t, rc),</span>
<span class="line" id="L6709">        .BADF, .INVAL =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L6710">        .NFILE =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.SystemFdQuotaExceeded,</span>
<span class="line" id="L6711">        .NOMEM =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.SystemResources,</span>
<span class="line" id="L6712">        .MFILE =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.ProcessResources,</span>
<span class="line" id="L6713">        .NODEV =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.InodeMountFail,</span>
<span class="line" id="L6714">        .NOSYS =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.SystemOutdated,</span>
<span class="line" id="L6715">        <span class="tok-kw">else</span> =&gt; |err| <span class="tok-kw">return</span> unexpectedErrno(err),</span>
<span class="line" id="L6716">    }</span>
<span class="line" id="L6717">}</span>
<span class="line" id="L6718"></span>
<span class="line" id="L6719"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> SyncError = <span class="tok-kw">error</span>{</span>
<span class="line" id="L6720">    InputOutput,</span>
<span class="line" id="L6721">    NoSpaceLeft,</span>
<span class="line" id="L6722">    DiskQuota,</span>
<span class="line" id="L6723">    AccessDenied,</span>
<span class="line" id="L6724">} || UnexpectedError;</span>
<span class="line" id="L6725"></span>
<span class="line" id="L6726"><span class="tok-comment">/// Write all pending file contents and metadata modifications to all filesystems.</span></span>
<span class="line" id="L6727"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">sync</span>() <span class="tok-type">void</span> {</span>
<span class="line" id="L6728">    system.sync();</span>
<span class="line" id="L6729">}</span>
<span class="line" id="L6730"></span>
<span class="line" id="L6731"><span class="tok-comment">/// Write all pending file contents and metadata modifications to the filesystem which contains the specified file.</span></span>
<span class="line" id="L6732"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">syncfs</span>(fd: fd_t) SyncError!<span class="tok-type">void</span> {</span>
<span class="line" id="L6733">    <span class="tok-kw">const</span> rc = system.syncfs(fd);</span>
<span class="line" id="L6734">    <span class="tok-kw">switch</span> (errno(rc)) {</span>
<span class="line" id="L6735">        .SUCCESS =&gt; <span class="tok-kw">return</span>,</span>
<span class="line" id="L6736">        .BADF, .INVAL, .ROFS =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L6737">        .IO =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.InputOutput,</span>
<span class="line" id="L6738">        .NOSPC =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.NoSpaceLeft,</span>
<span class="line" id="L6739">        .DQUOT =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.DiskQuota,</span>
<span class="line" id="L6740">        <span class="tok-kw">else</span> =&gt; |err| <span class="tok-kw">return</span> unexpectedErrno(err),</span>
<span class="line" id="L6741">    }</span>
<span class="line" id="L6742">}</span>
<span class="line" id="L6743"></span>
<span class="line" id="L6744"><span class="tok-comment">/// Write all pending file contents and metadata modifications for the specified file descriptor to the underlying filesystem.</span></span>
<span class="line" id="L6745"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">fsync</span>(fd: fd_t) SyncError!<span class="tok-type">void</span> {</span>
<span class="line" id="L6746">    <span class="tok-kw">if</span> (builtin.os.tag == .windows) {</span>
<span class="line" id="L6747">        <span class="tok-kw">if</span> (windows.kernel32.FlushFileBuffers(fd) != <span class="tok-number">0</span>)</span>
<span class="line" id="L6748">            <span class="tok-kw">return</span>;</span>
<span class="line" id="L6749">        <span class="tok-kw">switch</span> (windows.kernel32.GetLastError()) {</span>
<span class="line" id="L6750">            .SUCCESS =&gt; <span class="tok-kw">return</span>,</span>
<span class="line" id="L6751">            .INVALID_HANDLE =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L6752">            .ACCESS_DENIED =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.AccessDenied, <span class="tok-comment">// a sync was performed but the system couldn't update the access time</span>
</span>
<span class="line" id="L6753">            .UNEXP_NET_ERR =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.InputOutput,</span>
<span class="line" id="L6754">            <span class="tok-kw">else</span> =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.InputOutput,</span>
<span class="line" id="L6755">        }</span>
<span class="line" id="L6756">    }</span>
<span class="line" id="L6757">    <span class="tok-kw">const</span> rc = system.fsync(fd);</span>
<span class="line" id="L6758">    <span class="tok-kw">switch</span> (errno(rc)) {</span>
<span class="line" id="L6759">        .SUCCESS =&gt; <span class="tok-kw">return</span>,</span>
<span class="line" id="L6760">        .BADF, .INVAL, .ROFS =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L6761">        .IO =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.InputOutput,</span>
<span class="line" id="L6762">        .NOSPC =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.NoSpaceLeft,</span>
<span class="line" id="L6763">        .DQUOT =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.DiskQuota,</span>
<span class="line" id="L6764">        <span class="tok-kw">else</span> =&gt; |err| <span class="tok-kw">return</span> unexpectedErrno(err),</span>
<span class="line" id="L6765">    }</span>
<span class="line" id="L6766">}</span>
<span class="line" id="L6767"></span>
<span class="line" id="L6768"><span class="tok-comment">/// Write all pending file contents for the specified file descriptor to the underlying filesystem, but not necessarily the metadata.</span></span>
<span class="line" id="L6769"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">fdatasync</span>(fd: fd_t) SyncError!<span class="tok-type">void</span> {</span>
<span class="line" id="L6770">    <span class="tok-kw">if</span> (builtin.os.tag == .windows) {</span>
<span class="line" id="L6771">        <span class="tok-kw">return</span> fsync(fd) <span class="tok-kw">catch</span> |err| <span class="tok-kw">switch</span> (err) {</span>
<span class="line" id="L6772">            SyncError.AccessDenied =&gt; <span class="tok-kw">return</span>, <span class="tok-comment">// fdatasync doesn't promise that the access time was synced</span>
</span>
<span class="line" id="L6773">            <span class="tok-kw">else</span> =&gt; <span class="tok-kw">return</span> err,</span>
<span class="line" id="L6774">        };</span>
<span class="line" id="L6775">    }</span>
<span class="line" id="L6776">    <span class="tok-kw">const</span> rc = system.fdatasync(fd);</span>
<span class="line" id="L6777">    <span class="tok-kw">switch</span> (errno(rc)) {</span>
<span class="line" id="L6778">        .SUCCESS =&gt; <span class="tok-kw">return</span>,</span>
<span class="line" id="L6779">        .BADF, .INVAL, .ROFS =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L6780">        .IO =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.InputOutput,</span>
<span class="line" id="L6781">        .NOSPC =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.NoSpaceLeft,</span>
<span class="line" id="L6782">        .DQUOT =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.DiskQuota,</span>
<span class="line" id="L6783">        <span class="tok-kw">else</span> =&gt; |err| <span class="tok-kw">return</span> unexpectedErrno(err),</span>
<span class="line" id="L6784">    }</span>
<span class="line" id="L6785">}</span>
<span class="line" id="L6786"></span>
<span class="line" id="L6787"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> PrctlError = <span class="tok-kw">error</span>{</span>
<span class="line" id="L6788">    <span class="tok-comment">/// Can only occur with PR_SET_SECCOMP/SECCOMP_MODE_FILTER or</span></span>
<span class="line" id="L6789">    <span class="tok-comment">/// PR_SET_MM/PR_SET_MM_EXE_FILE</span></span>
<span class="line" id="L6790">    AccessDenied,</span>
<span class="line" id="L6791">    <span class="tok-comment">/// Can only occur with PR_SET_MM/PR_SET_MM_EXE_FILE</span></span>
<span class="line" id="L6792">    InvalidFileDescriptor,</span>
<span class="line" id="L6793">    InvalidAddress,</span>
<span class="line" id="L6794">    <span class="tok-comment">/// Can only occur with PR_SET_SPECULATION_CTRL, PR_MPX_ENABLE_MANAGEMENT,</span></span>
<span class="line" id="L6795">    <span class="tok-comment">/// or PR_MPX_DISABLE_MANAGEMENT</span></span>
<span class="line" id="L6796">    UnsupportedFeature,</span>
<span class="line" id="L6797">    <span class="tok-comment">/// Can only occur wih PR_SET_FP_MODE</span></span>
<span class="line" id="L6798">    OperationNotSupported,</span>
<span class="line" id="L6799">    PermissionDenied,</span>
<span class="line" id="L6800">} || UnexpectedError;</span>
<span class="line" id="L6801"></span>
<span class="line" id="L6802"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">prctl</span>(option: PR, args: <span class="tok-kw">anytype</span>) PrctlError!<span class="tok-type">u31</span> {</span>
<span class="line" id="L6803">    <span class="tok-kw">if</span> (<span class="tok-builtin">@typeInfo</span>(<span class="tok-builtin">@TypeOf</span>(args)) != .Struct)</span>
<span class="line" id="L6804">        <span class="tok-builtin">@compileError</span>(<span class="tok-str">&quot;Expected tuple or struct argument, found &quot;</span> ++ <span class="tok-builtin">@typeName</span>(<span class="tok-builtin">@TypeOf</span>(args)));</span>
<span class="line" id="L6805">    <span class="tok-kw">if</span> (args.len &gt; <span class="tok-number">4</span>)</span>
<span class="line" id="L6806">        <span class="tok-builtin">@compileError</span>(<span class="tok-str">&quot;prctl takes a maximum of 4 optional arguments&quot;</span>);</span>
<span class="line" id="L6807"></span>
<span class="line" id="L6808">    <span class="tok-kw">var</span> buf: [<span class="tok-number">4</span>]<span class="tok-type">usize</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L6809">    {</span>
<span class="line" id="L6810">        <span class="tok-kw">comptime</span> <span class="tok-kw">var</span> i = <span class="tok-number">0</span>;</span>
<span class="line" id="L6811">        <span class="tok-kw">inline</span> <span class="tok-kw">while</span> (i &lt; args.len) : (i += <span class="tok-number">1</span>) buf[i] = args[i];</span>
<span class="line" id="L6812">    }</span>
<span class="line" id="L6813"></span>
<span class="line" id="L6814">    <span class="tok-kw">const</span> rc = system.prctl(<span class="tok-builtin">@enumToInt</span>(option), buf[<span class="tok-number">0</span>], buf[<span class="tok-number">1</span>], buf[<span class="tok-number">2</span>], buf[<span class="tok-number">3</span>]);</span>
<span class="line" id="L6815">    <span class="tok-kw">switch</span> (errno(rc)) {</span>
<span class="line" id="L6816">        .SUCCESS =&gt; <span class="tok-kw">return</span> <span class="tok-builtin">@intCast</span>(<span class="tok-type">u31</span>, rc),</span>
<span class="line" id="L6817">        .ACCES =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.AccessDenied,</span>
<span class="line" id="L6818">        .BADF =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.InvalidFileDescriptor,</span>
<span class="line" id="L6819">        .FAULT =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.InvalidAddress,</span>
<span class="line" id="L6820">        .INVAL =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L6821">        .NODEV, .NXIO =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.UnsupportedFeature,</span>
<span class="line" id="L6822">        .OPNOTSUPP =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.OperationNotSupported,</span>
<span class="line" id="L6823">        .PERM, .BUSY =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.PermissionDenied,</span>
<span class="line" id="L6824">        .RANGE =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L6825">        <span class="tok-kw">else</span> =&gt; |err| <span class="tok-kw">return</span> unexpectedErrno(err),</span>
<span class="line" id="L6826">    }</span>
<span class="line" id="L6827">}</span>
<span class="line" id="L6828"></span>
<span class="line" id="L6829"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> GetrlimitError = UnexpectedError;</span>
<span class="line" id="L6830"></span>
<span class="line" id="L6831"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">getrlimit</span>(resource: rlimit_resource) GetrlimitError!rlimit {</span>
<span class="line" id="L6832">    <span class="tok-kw">const</span> getrlimit_sym = <span class="tok-kw">if</span> (builtin.os.tag == .linux <span class="tok-kw">and</span> builtin.link_libc)</span>
<span class="line" id="L6833">        system.getrlimit64</span>
<span class="line" id="L6834">    <span class="tok-kw">else</span></span>
<span class="line" id="L6835">        system.getrlimit;</span>
<span class="line" id="L6836"></span>
<span class="line" id="L6837">    <span class="tok-kw">var</span> limits: rlimit = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L6838">    <span class="tok-kw">switch</span> (errno(getrlimit_sym(resource, &amp;limits))) {</span>
<span class="line" id="L6839">        .SUCCESS =&gt; <span class="tok-kw">return</span> limits,</span>
<span class="line" id="L6840">        .FAULT =&gt; <span class="tok-kw">unreachable</span>, <span class="tok-comment">// bogus pointer</span>
</span>
<span class="line" id="L6841">        .INVAL =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L6842">        <span class="tok-kw">else</span> =&gt; |err| <span class="tok-kw">return</span> unexpectedErrno(err),</span>
<span class="line" id="L6843">    }</span>
<span class="line" id="L6844">}</span>
<span class="line" id="L6845"></span>
<span class="line" id="L6846"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> SetrlimitError = <span class="tok-kw">error</span>{ PermissionDenied, LimitTooBig } || UnexpectedError;</span>
<span class="line" id="L6847"></span>
<span class="line" id="L6848"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">setrlimit</span>(resource: rlimit_resource, limits: rlimit) SetrlimitError!<span class="tok-type">void</span> {</span>
<span class="line" id="L6849">    <span class="tok-kw">const</span> setrlimit_sym = <span class="tok-kw">if</span> (builtin.os.tag == .linux <span class="tok-kw">and</span> builtin.link_libc)</span>
<span class="line" id="L6850">        system.setrlimit64</span>
<span class="line" id="L6851">    <span class="tok-kw">else</span></span>
<span class="line" id="L6852">        system.setrlimit;</span>
<span class="line" id="L6853"></span>
<span class="line" id="L6854">    <span class="tok-kw">switch</span> (errno(setrlimit_sym(resource, &amp;limits))) {</span>
<span class="line" id="L6855">        .SUCCESS =&gt; <span class="tok-kw">return</span>,</span>
<span class="line" id="L6856">        .FAULT =&gt; <span class="tok-kw">unreachable</span>, <span class="tok-comment">// bogus pointer</span>
</span>
<span class="line" id="L6857">        .INVAL =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.LimitTooBig, <span class="tok-comment">// this could also mean &quot;invalid resource&quot;, but that would be unreachable</span>
</span>
<span class="line" id="L6858">        .PERM =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.PermissionDenied,</span>
<span class="line" id="L6859">        <span class="tok-kw">else</span> =&gt; |err| <span class="tok-kw">return</span> unexpectedErrno(err),</span>
<span class="line" id="L6860">    }</span>
<span class="line" id="L6861">}</span>
<span class="line" id="L6862"></span>
<span class="line" id="L6863"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> MadviseError = <span class="tok-kw">error</span>{</span>
<span class="line" id="L6864">    <span class="tok-comment">/// advice is MADV.REMOVE, but the specified address range is not a shared writable mapping.</span></span>
<span class="line" id="L6865">    AccessDenied,</span>
<span class="line" id="L6866">    <span class="tok-comment">/// advice is MADV.HWPOISON, but the caller does not have the CAP_SYS_ADMIN capability.</span></span>
<span class="line" id="L6867">    PermissionDenied,</span>
<span class="line" id="L6868">    <span class="tok-comment">/// A kernel resource was temporarily unavailable.</span></span>
<span class="line" id="L6869">    SystemResources,</span>
<span class="line" id="L6870">    <span class="tok-comment">/// One of the following:</span></span>
<span class="line" id="L6871">    <span class="tok-comment">/// * addr is not page-aligned or length is negative</span></span>
<span class="line" id="L6872">    <span class="tok-comment">/// * advice is not valid</span></span>
<span class="line" id="L6873">    <span class="tok-comment">/// * advice is MADV.DONTNEED or MADV.REMOVE and the specified address range</span></span>
<span class="line" id="L6874">    <span class="tok-comment">///   includes locked, Huge TLB pages, or VM_PFNMAP pages.</span></span>
<span class="line" id="L6875">    <span class="tok-comment">/// * advice is MADV.MERGEABLE or MADV.UNMERGEABLE, but the kernel was not</span></span>
<span class="line" id="L6876">    <span class="tok-comment">///   configured with CONFIG_KSM.</span></span>
<span class="line" id="L6877">    <span class="tok-comment">/// * advice is MADV.FREE or MADV.WIPEONFORK but the specified address range</span></span>
<span class="line" id="L6878">    <span class="tok-comment">///   includes file, Huge TLB, MAP.SHARED, or VM_PFNMAP ranges.</span></span>
<span class="line" id="L6879">    InvalidSyscall,</span>
<span class="line" id="L6880">    <span class="tok-comment">/// (for MADV.WILLNEED) Paging in this area would exceed the process's</span></span>
<span class="line" id="L6881">    <span class="tok-comment">/// maximum resident set size.</span></span>
<span class="line" id="L6882">    WouldExceedMaximumResidentSetSize,</span>
<span class="line" id="L6883">    <span class="tok-comment">/// One of the following:</span></span>
<span class="line" id="L6884">    <span class="tok-comment">/// * (for MADV.WILLNEED) Not enough memory: paging in failed.</span></span>
<span class="line" id="L6885">    <span class="tok-comment">/// * Addresses in the specified range are not currently mapped, or</span></span>
<span class="line" id="L6886">    <span class="tok-comment">///   are outside the address space of the process.</span></span>
<span class="line" id="L6887">    OutOfMemory,</span>
<span class="line" id="L6888">    <span class="tok-comment">/// The madvise syscall is not available on this version and configuration</span></span>
<span class="line" id="L6889">    <span class="tok-comment">/// of the Linux kernel.</span></span>
<span class="line" id="L6890">    MadviseUnavailable,</span>
<span class="line" id="L6891">    <span class="tok-comment">/// The operating system returned an undocumented error code.</span></span>
<span class="line" id="L6892">    Unexpected,</span>
<span class="line" id="L6893">};</span>
<span class="line" id="L6894"></span>
<span class="line" id="L6895"><span class="tok-comment">/// Give advice about use of memory.</span></span>
<span class="line" id="L6896"><span class="tok-comment">/// This syscall is optional and is sometimes configured to be disabled.</span></span>
<span class="line" id="L6897"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">madvise</span>(ptr: [*]<span class="tok-kw">align</span>(mem.page_size) <span class="tok-type">u8</span>, length: <span class="tok-type">usize</span>, advice: <span class="tok-type">u32</span>) MadviseError!<span class="tok-type">void</span> {</span>
<span class="line" id="L6898">    <span class="tok-kw">switch</span> (errno(system.madvise(ptr, length, advice))) {</span>
<span class="line" id="L6899">        .SUCCESS =&gt; <span class="tok-kw">return</span>,</span>
<span class="line" id="L6900">        .ACCES =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.AccessDenied,</span>
<span class="line" id="L6901">        .AGAIN =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.SystemResources,</span>
<span class="line" id="L6902">        .BADF =&gt; <span class="tok-kw">unreachable</span>, <span class="tok-comment">// The map exists, but the area maps something that isn't a file.</span>
</span>
<span class="line" id="L6903">        .INVAL =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.InvalidSyscall,</span>
<span class="line" id="L6904">        .IO =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.WouldExceedMaximumResidentSetSize,</span>
<span class="line" id="L6905">        .NOMEM =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.OutOfMemory,</span>
<span class="line" id="L6906">        .NOSYS =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.MadviseUnavailable,</span>
<span class="line" id="L6907">        <span class="tok-kw">else</span> =&gt; |err| <span class="tok-kw">return</span> unexpectedErrno(err),</span>
<span class="line" id="L6908">    }</span>
<span class="line" id="L6909">}</span>
<span class="line" id="L6910"></span>
<span class="line" id="L6911"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> PerfEventOpenError = <span class="tok-kw">error</span>{</span>
<span class="line" id="L6912">    <span class="tok-comment">/// Returned if the perf_event_attr size value is too small (smaller</span></span>
<span class="line" id="L6913">    <span class="tok-comment">/// than PERF_ATTR_SIZE_VER0), too big (larger than the page  size),</span></span>
<span class="line" id="L6914">    <span class="tok-comment">/// or  larger  than the kernel supports and the extra bytes are not</span></span>
<span class="line" id="L6915">    <span class="tok-comment">/// zero.  When E2BIG is returned, the perf_event_attr size field is</span></span>
<span class="line" id="L6916">    <span class="tok-comment">/// overwritten by the kernel to be the size of the structure it was</span></span>
<span class="line" id="L6917">    <span class="tok-comment">/// expecting.</span></span>
<span class="line" id="L6918">    TooBig,</span>
<span class="line" id="L6919">    <span class="tok-comment">/// Returned when the requested event requires CAP_SYS_ADMIN permis‐</span></span>
<span class="line" id="L6920">    <span class="tok-comment">/// sions  (or a more permissive perf_event paranoid setting).  Some</span></span>
<span class="line" id="L6921">    <span class="tok-comment">/// common cases where an unprivileged process  may  encounter  this</span></span>
<span class="line" id="L6922">    <span class="tok-comment">/// error:  attaching  to a process owned by a different user; moni‐</span></span>
<span class="line" id="L6923">    <span class="tok-comment">/// toring all processes on a given CPU (i.e.,  specifying  the  pid</span></span>
<span class="line" id="L6924">    <span class="tok-comment">/// argument  as  -1); and not setting exclude_kernel when the para‐</span></span>
<span class="line" id="L6925">    <span class="tok-comment">/// noid setting requires it.</span></span>
<span class="line" id="L6926">    <span class="tok-comment">/// Also:</span></span>
<span class="line" id="L6927">    <span class="tok-comment">/// Returned on many (but not all) architectures when an unsupported</span></span>
<span class="line" id="L6928">    <span class="tok-comment">/// exclude_hv,  exclude_idle,  exclude_user, or exclude_kernel set‐</span></span>
<span class="line" id="L6929">    <span class="tok-comment">/// ting is specified.</span></span>
<span class="line" id="L6930">    <span class="tok-comment">/// It can also happen, as with EACCES, when the requested event re‐</span></span>
<span class="line" id="L6931">    <span class="tok-comment">/// quires   CAP_SYS_ADMIN   permissions   (or   a  more  permissive</span></span>
<span class="line" id="L6932">    <span class="tok-comment">/// perf_event paranoid setting).  This includes  setting  a  break‐</span></span>
<span class="line" id="L6933">    <span class="tok-comment">/// point on a kernel address, and (since Linux 3.13) setting a ker‐</span></span>
<span class="line" id="L6934">    <span class="tok-comment">/// nel function-trace tracepoint.</span></span>
<span class="line" id="L6935">    PermissionDenied,</span>
<span class="line" id="L6936">    <span class="tok-comment">/// Returned if another event already has exclusive  access  to  the</span></span>
<span class="line" id="L6937">    <span class="tok-comment">/// PMU.</span></span>
<span class="line" id="L6938">    DeviceBusy,</span>
<span class="line" id="L6939">    <span class="tok-comment">/// Each  opened  event uses one file descriptor.  If a large number</span></span>
<span class="line" id="L6940">    <span class="tok-comment">/// of events are opened, the per-process limit  on  the  number  of</span></span>
<span class="line" id="L6941">    <span class="tok-comment">/// open file descriptors will be reached, and no more events can be</span></span>
<span class="line" id="L6942">    <span class="tok-comment">/// created.</span></span>
<span class="line" id="L6943">    ProcessResources,</span>
<span class="line" id="L6944">    EventRequiresUnsupportedCpuFeature,</span>
<span class="line" id="L6945">    <span class="tok-comment">/// Returned if  you  try  to  add  more  breakpoint</span></span>
<span class="line" id="L6946">    <span class="tok-comment">/// events than supported by the hardware.</span></span>
<span class="line" id="L6947">    TooManyBreakpoints,</span>
<span class="line" id="L6948">    <span class="tok-comment">/// Returned  if PERF_SAMPLE_STACK_USER is set in sample_type and it</span></span>
<span class="line" id="L6949">    <span class="tok-comment">/// is not supported by hardware.</span></span>
<span class="line" id="L6950">    SampleStackNotSupported,</span>
<span class="line" id="L6951">    <span class="tok-comment">/// Returned if an event requiring a specific  hardware  feature  is</span></span>
<span class="line" id="L6952">    <span class="tok-comment">/// requested  but  there is no hardware support.  This includes re‐</span></span>
<span class="line" id="L6953">    <span class="tok-comment">/// questing low-skid events if not supported, branch tracing if  it</span></span>
<span class="line" id="L6954">    <span class="tok-comment">/// is not available, sampling if no PMU interrupt is available, and</span></span>
<span class="line" id="L6955">    <span class="tok-comment">/// branch stacks for software events.</span></span>
<span class="line" id="L6956">    EventNotSupported,</span>
<span class="line" id="L6957">    <span class="tok-comment">/// Returned  if  PERF_SAMPLE_CALLCHAIN  is   requested   and   sam‐</span></span>
<span class="line" id="L6958">    <span class="tok-comment">/// ple_max_stack   is   larger   than   the  maximum  specified  in</span></span>
<span class="line" id="L6959">    <span class="tok-comment">/// /proc/sys/kernel/perf_event_max_stack.</span></span>
<span class="line" id="L6960">    SampleMaxStackOverflow,</span>
<span class="line" id="L6961">    <span class="tok-comment">/// Returned if attempting to attach to a process that does not  exist.</span></span>
<span class="line" id="L6962">    ProcessNotFound,</span>
<span class="line" id="L6963">} || UnexpectedError;</span>
<span class="line" id="L6964"></span>
<span class="line" id="L6965"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">perf_event_open</span>(</span>
<span class="line" id="L6966">    attr: *linux.perf_event_attr,</span>
<span class="line" id="L6967">    pid: pid_t,</span>
<span class="line" id="L6968">    cpu: <span class="tok-type">i32</span>,</span>
<span class="line" id="L6969">    group_fd: fd_t,</span>
<span class="line" id="L6970">    flags: <span class="tok-type">usize</span>,</span>
<span class="line" id="L6971">) PerfEventOpenError!fd_t {</span>
<span class="line" id="L6972">    <span class="tok-kw">const</span> rc = system.perf_event_open(attr, pid, cpu, group_fd, flags);</span>
<span class="line" id="L6973">    <span class="tok-kw">switch</span> (errno(rc)) {</span>
<span class="line" id="L6974">        .SUCCESS =&gt; <span class="tok-kw">return</span> <span class="tok-builtin">@intCast</span>(fd_t, rc),</span>
<span class="line" id="L6975">        .@&quot;2BIG&quot; =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.TooBig,</span>
<span class="line" id="L6976">        .ACCES =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.PermissionDenied,</span>
<span class="line" id="L6977">        .BADF =&gt; <span class="tok-kw">unreachable</span>, <span class="tok-comment">// group_fd file descriptor is not valid.</span>
</span>
<span class="line" id="L6978">        .BUSY =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.DeviceBusy,</span>
<span class="line" id="L6979">        .FAULT =&gt; <span class="tok-kw">unreachable</span>, <span class="tok-comment">// Segmentation fault.</span>
</span>
<span class="line" id="L6980">        .INVAL =&gt; <span class="tok-kw">unreachable</span>, <span class="tok-comment">// Bad attr settings.</span>
</span>
<span class="line" id="L6981">        .INTR =&gt; <span class="tok-kw">unreachable</span>, <span class="tok-comment">// Mixed perf and ftrace handling for a uprobe.</span>
</span>
<span class="line" id="L6982">        .MFILE =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.ProcessResources,</span>
<span class="line" id="L6983">        .NODEV =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.EventRequiresUnsupportedCpuFeature,</span>
<span class="line" id="L6984">        .NOENT =&gt; <span class="tok-kw">unreachable</span>, <span class="tok-comment">// Invalid type setting.</span>
</span>
<span class="line" id="L6985">        .NOSPC =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.TooManyBreakpoints,</span>
<span class="line" id="L6986">        .NOSYS =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.SampleStackNotSupported,</span>
<span class="line" id="L6987">        .OPNOTSUPP =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.EventNotSupported,</span>
<span class="line" id="L6988">        .OVERFLOW =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.SampleMaxStackOverflow,</span>
<span class="line" id="L6989">        .PERM =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.PermissionDenied,</span>
<span class="line" id="L6990">        .SRCH =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.ProcessNotFound,</span>
<span class="line" id="L6991">        <span class="tok-kw">else</span> =&gt; |err| <span class="tok-kw">return</span> unexpectedErrno(err),</span>
<span class="line" id="L6992">    }</span>
<span class="line" id="L6993">}</span>
<span class="line" id="L6994"></span>
<span class="line" id="L6995"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> TimerFdCreateError = <span class="tok-kw">error</span>{</span>
<span class="line" id="L6996">    AccessDenied,</span>
<span class="line" id="L6997">    ProcessFdQuotaExceeded,</span>
<span class="line" id="L6998">    SystemFdQuotaExceeded,</span>
<span class="line" id="L6999">    NoDevice,</span>
<span class="line" id="L7000">    SystemResources,</span>
<span class="line" id="L7001">} || UnexpectedError;</span>
<span class="line" id="L7002"></span>
<span class="line" id="L7003"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> TimerFdGetError = <span class="tok-kw">error</span>{InvalidHandle} || UnexpectedError;</span>
<span class="line" id="L7004"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> TimerFdSetError = TimerFdGetError || <span class="tok-kw">error</span>{Canceled};</span>
<span class="line" id="L7005"></span>
<span class="line" id="L7006"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">timerfd_create</span>(clokid: <span class="tok-type">i32</span>, flags: <span class="tok-type">u32</span>) TimerFdCreateError!fd_t {</span>
<span class="line" id="L7007">    <span class="tok-kw">var</span> rc = linux.timerfd_create(clokid, flags);</span>
<span class="line" id="L7008">    <span class="tok-kw">return</span> <span class="tok-kw">switch</span> (errno(rc)) {</span>
<span class="line" id="L7009">        .SUCCESS =&gt; <span class="tok-builtin">@intCast</span>(fd_t, rc),</span>
<span class="line" id="L7010">        .INVAL =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L7011">        .MFILE =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.ProcessFdQuotaExceeded,</span>
<span class="line" id="L7012">        .NFILE =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.SystemFdQuotaExceeded,</span>
<span class="line" id="L7013">        .NODEV =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.NoDevice,</span>
<span class="line" id="L7014">        .NOMEM =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.SystemResources,</span>
<span class="line" id="L7015">        .PERM =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.AccessDenied,</span>
<span class="line" id="L7016">        <span class="tok-kw">else</span> =&gt; |err| <span class="tok-kw">return</span> unexpectedErrno(err),</span>
<span class="line" id="L7017">    };</span>
<span class="line" id="L7018">}</span>
<span class="line" id="L7019"></span>
<span class="line" id="L7020"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">timerfd_settime</span>(fd: <span class="tok-type">i32</span>, flags: <span class="tok-type">u32</span>, new_value: *<span class="tok-kw">const</span> linux.itimerspec, old_value: ?*linux.itimerspec) TimerFdSetError!<span class="tok-type">void</span> {</span>
<span class="line" id="L7021">    <span class="tok-kw">var</span> rc = linux.timerfd_settime(fd, flags, new_value, old_value);</span>
<span class="line" id="L7022">    <span class="tok-kw">return</span> <span class="tok-kw">switch</span> (errno(rc)) {</span>
<span class="line" id="L7023">        .SUCCESS =&gt; {},</span>
<span class="line" id="L7024">        .BADF =&gt; <span class="tok-kw">error</span>.InvalidHandle,</span>
<span class="line" id="L7025">        .FAULT =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L7026">        .INVAL =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L7027">        .CANCELED =&gt; <span class="tok-kw">error</span>.Canceled,</span>
<span class="line" id="L7028">        <span class="tok-kw">else</span> =&gt; |err| <span class="tok-kw">return</span> unexpectedErrno(err),</span>
<span class="line" id="L7029">    };</span>
<span class="line" id="L7030">}</span>
<span class="line" id="L7031"></span>
<span class="line" id="L7032"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">timerfd_gettime</span>(fd: <span class="tok-type">i32</span>) TimerFdGetError!linux.itimerspec {</span>
<span class="line" id="L7033">    <span class="tok-kw">var</span> curr_value: linux.itimerspec = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L7034">    <span class="tok-kw">var</span> rc = linux.timerfd_gettime(fd, &amp;curr_value);</span>
<span class="line" id="L7035">    <span class="tok-kw">return</span> <span class="tok-kw">switch</span> (errno(rc)) {</span>
<span class="line" id="L7036">        .SUCCESS =&gt; <span class="tok-kw">return</span> curr_value,</span>
<span class="line" id="L7037">        .BADF =&gt; <span class="tok-kw">error</span>.InvalidHandle,</span>
<span class="line" id="L7038">        .FAULT =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L7039">        .INVAL =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L7040">        <span class="tok-kw">else</span> =&gt; |err| <span class="tok-kw">return</span> unexpectedErrno(err),</span>
<span class="line" id="L7041">    };</span>
<span class="line" id="L7042">}</span>
<span class="line" id="L7043"></span>
</code></pre></body>
</html>