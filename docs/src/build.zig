<!doctype html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">    <title>build.zig - source view</title>
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
<span class="line" id="L2"><span class="tok-kw">const</span> builtin = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;builtin&quot;</span>);</span>
<span class="line" id="L3"><span class="tok-kw">const</span> io = std.io;</span>
<span class="line" id="L4"><span class="tok-kw">const</span> fs = std.fs;</span>
<span class="line" id="L5"><span class="tok-kw">const</span> mem = std.mem;</span>
<span class="line" id="L6"><span class="tok-kw">const</span> debug = std.debug;</span>
<span class="line" id="L7"><span class="tok-kw">const</span> panic = std.debug.panic;</span>
<span class="line" id="L8"><span class="tok-kw">const</span> assert = debug.assert;</span>
<span class="line" id="L9"><span class="tok-kw">const</span> log = std.log;</span>
<span class="line" id="L10"><span class="tok-kw">const</span> ArrayList = std.ArrayList;</span>
<span class="line" id="L11"><span class="tok-kw">const</span> StringHashMap = std.StringHashMap;</span>
<span class="line" id="L12"><span class="tok-kw">const</span> Allocator = mem.Allocator;</span>
<span class="line" id="L13"><span class="tok-kw">const</span> process = std.process;</span>
<span class="line" id="L14"><span class="tok-kw">const</span> EnvMap = std.process.EnvMap;</span>
<span class="line" id="L15"><span class="tok-kw">const</span> fmt_lib = std.fmt;</span>
<span class="line" id="L16"><span class="tok-kw">const</span> File = std.fs.File;</span>
<span class="line" id="L17"><span class="tok-kw">const</span> CrossTarget = std.zig.CrossTarget;</span>
<span class="line" id="L18"><span class="tok-kw">const</span> NativeTargetInfo = std.zig.system.NativeTargetInfo;</span>
<span class="line" id="L19"><span class="tok-kw">const</span> Sha256 = std.crypto.hash.sha2.Sha256;</span>
<span class="line" id="L20"></span>
<span class="line" id="L21"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> FmtStep = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;build/FmtStep.zig&quot;</span>);</span>
<span class="line" id="L22"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> TranslateCStep = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;build/TranslateCStep.zig&quot;</span>);</span>
<span class="line" id="L23"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> WriteFileStep = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;build/WriteFileStep.zig&quot;</span>);</span>
<span class="line" id="L24"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> RunStep = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;build/RunStep.zig&quot;</span>);</span>
<span class="line" id="L25"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> CheckFileStep = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;build/CheckFileStep.zig&quot;</span>);</span>
<span class="line" id="L26"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> CheckObjectStep = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;build/CheckObjectStep.zig&quot;</span>);</span>
<span class="line" id="L27"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> InstallRawStep = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;build/InstallRawStep.zig&quot;</span>);</span>
<span class="line" id="L28"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> OptionsStep = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;build/OptionsStep.zig&quot;</span>);</span>
<span class="line" id="L29"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> EmulatableRunStep = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;build/EmulatableRunStep.zig&quot;</span>);</span>
<span class="line" id="L30"></span>
<span class="line" id="L31"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> Builder = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L32">    install_tls: TopLevelStep,</span>
<span class="line" id="L33">    uninstall_tls: TopLevelStep,</span>
<span class="line" id="L34">    allocator: Allocator,</span>
<span class="line" id="L35">    user_input_options: UserInputOptionsMap,</span>
<span class="line" id="L36">    available_options_map: AvailableOptionsMap,</span>
<span class="line" id="L37">    available_options_list: ArrayList(AvailableOption),</span>
<span class="line" id="L38">    verbose: <span class="tok-type">bool</span>,</span>
<span class="line" id="L39">    verbose_link: <span class="tok-type">bool</span>,</span>
<span class="line" id="L40">    verbose_cc: <span class="tok-type">bool</span>,</span>
<span class="line" id="L41">    verbose_air: <span class="tok-type">bool</span>,</span>
<span class="line" id="L42">    verbose_llvm_ir: <span class="tok-type">bool</span>,</span>
<span class="line" id="L43">    verbose_cimport: <span class="tok-type">bool</span>,</span>
<span class="line" id="L44">    verbose_llvm_cpu_features: <span class="tok-type">bool</span>,</span>
<span class="line" id="L45">    <span class="tok-comment">/// The purpose of executing the command is for a human to read compile errors from the terminal</span></span>
<span class="line" id="L46">    prominent_compile_errors: <span class="tok-type">bool</span>,</span>
<span class="line" id="L47">    color: <span class="tok-kw">enum</span> { auto, on, off } = .auto,</span>
<span class="line" id="L48">    use_stage1: ?<span class="tok-type">bool</span> = <span class="tok-null">null</span>,</span>
<span class="line" id="L49">    invalid_user_input: <span class="tok-type">bool</span>,</span>
<span class="line" id="L50">    zig_exe: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>,</span>
<span class="line" id="L51">    default_step: *Step,</span>
<span class="line" id="L52">    env_map: *EnvMap,</span>
<span class="line" id="L53">    top_level_steps: ArrayList(*TopLevelStep),</span>
<span class="line" id="L54">    install_prefix: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>,</span>
<span class="line" id="L55">    dest_dir: ?[]<span class="tok-kw">const</span> <span class="tok-type">u8</span>,</span>
<span class="line" id="L56">    lib_dir: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>,</span>
<span class="line" id="L57">    exe_dir: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>,</span>
<span class="line" id="L58">    h_dir: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>,</span>
<span class="line" id="L59">    install_path: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>,</span>
<span class="line" id="L60">    sysroot: ?[]<span class="tok-kw">const</span> <span class="tok-type">u8</span> = <span class="tok-null">null</span>,</span>
<span class="line" id="L61">    search_prefixes: ArrayList([]<span class="tok-kw">const</span> <span class="tok-type">u8</span>),</span>
<span class="line" id="L62">    libc_file: ?[]<span class="tok-kw">const</span> <span class="tok-type">u8</span> = <span class="tok-null">null</span>,</span>
<span class="line" id="L63">    installed_files: ArrayList(InstalledFile),</span>
<span class="line" id="L64">    build_root: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>,</span>
<span class="line" id="L65">    cache_root: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>,</span>
<span class="line" id="L66">    global_cache_root: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>,</span>
<span class="line" id="L67">    release_mode: ?std.builtin.Mode,</span>
<span class="line" id="L68">    is_release: <span class="tok-type">bool</span>,</span>
<span class="line" id="L69">    override_lib_dir: ?[]<span class="tok-kw">const</span> <span class="tok-type">u8</span>,</span>
<span class="line" id="L70">    vcpkg_root: VcpkgRoot,</span>
<span class="line" id="L71">    pkg_config_pkg_list: ?(PkgConfigError![]<span class="tok-kw">const</span> PkgConfigPkg) = <span class="tok-null">null</span>,</span>
<span class="line" id="L72">    args: ?[][]<span class="tok-kw">const</span> <span class="tok-type">u8</span> = <span class="tok-null">null</span>,</span>
<span class="line" id="L73">    debug_log_scopes: []<span class="tok-kw">const</span> []<span class="tok-kw">const</span> <span class="tok-type">u8</span> = &amp;.{},</span>
<span class="line" id="L74"></span>
<span class="line" id="L75">    <span class="tok-comment">/// Experimental. Use system Darling installation to run cross compiled macOS build artifacts.</span></span>
<span class="line" id="L76">    enable_darling: <span class="tok-type">bool</span> = <span class="tok-null">false</span>,</span>
<span class="line" id="L77">    <span class="tok-comment">/// Use system QEMU installation to run cross compiled foreign architecture build artifacts.</span></span>
<span class="line" id="L78">    enable_qemu: <span class="tok-type">bool</span> = <span class="tok-null">false</span>,</span>
<span class="line" id="L79">    <span class="tok-comment">/// Darwin. Use Rosetta to run x86_64 macOS build artifacts on arm64 macOS.</span></span>
<span class="line" id="L80">    enable_rosetta: <span class="tok-type">bool</span> = <span class="tok-null">false</span>,</span>
<span class="line" id="L81">    <span class="tok-comment">/// Use system Wasmtime installation to run cross compiled wasm/wasi build artifacts.</span></span>
<span class="line" id="L82">    enable_wasmtime: <span class="tok-type">bool</span> = <span class="tok-null">false</span>,</span>
<span class="line" id="L83">    <span class="tok-comment">/// Use system Wine installation to run cross compiled Windows build artifacts.</span></span>
<span class="line" id="L84">    enable_wine: <span class="tok-type">bool</span> = <span class="tok-null">false</span>,</span>
<span class="line" id="L85">    <span class="tok-comment">/// After following the steps in https://github.com/ziglang/zig/wiki/Updating-libc#glibc,</span></span>
<span class="line" id="L86">    <span class="tok-comment">/// this will be the directory $glibc-build-dir/install/glibcs</span></span>
<span class="line" id="L87">    <span class="tok-comment">/// Given the example of the aarch64 target, this is the directory</span></span>
<span class="line" id="L88">    <span class="tok-comment">/// that contains the path `aarch64-linux-gnu/lib/ld-linux-aarch64.so.1`.</span></span>
<span class="line" id="L89">    glibc_runtimes_dir: ?[]<span class="tok-kw">const</span> <span class="tok-type">u8</span> = <span class="tok-null">null</span>,</span>
<span class="line" id="L90"></span>
<span class="line" id="L91">    <span class="tok-comment">/// Information about the native target. Computed before build() is invoked.</span></span>
<span class="line" id="L92">    host: NativeTargetInfo,</span>
<span class="line" id="L93"></span>
<span class="line" id="L94">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> ExecError = <span class="tok-kw">error</span>{</span>
<span class="line" id="L95">        ReadFailure,</span>
<span class="line" id="L96">        ExitCodeFailure,</span>
<span class="line" id="L97">        ProcessTerminated,</span>
<span class="line" id="L98">        ExecNotSupported,</span>
<span class="line" id="L99">    } || std.ChildProcess.SpawnError;</span>
<span class="line" id="L100"></span>
<span class="line" id="L101">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> PkgConfigError = <span class="tok-kw">error</span>{</span>
<span class="line" id="L102">        PkgConfigCrashed,</span>
<span class="line" id="L103">        PkgConfigFailed,</span>
<span class="line" id="L104">        PkgConfigNotInstalled,</span>
<span class="line" id="L105">        PkgConfigInvalidOutput,</span>
<span class="line" id="L106">    };</span>
<span class="line" id="L107"></span>
<span class="line" id="L108">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> PkgConfigPkg = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L109">        name: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>,</span>
<span class="line" id="L110">        desc: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>,</span>
<span class="line" id="L111">    };</span>
<span class="line" id="L112"></span>
<span class="line" id="L113">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> CStd = <span class="tok-kw">enum</span> {</span>
<span class="line" id="L114">        C89,</span>
<span class="line" id="L115">        C99,</span>
<span class="line" id="L116">        C11,</span>
<span class="line" id="L117">    };</span>
<span class="line" id="L118"></span>
<span class="line" id="L119">    <span class="tok-kw">const</span> UserInputOptionsMap = StringHashMap(UserInputOption);</span>
<span class="line" id="L120">    <span class="tok-kw">const</span> AvailableOptionsMap = StringHashMap(AvailableOption);</span>
<span class="line" id="L121"></span>
<span class="line" id="L122">    <span class="tok-kw">const</span> AvailableOption = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L123">        name: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>,</span>
<span class="line" id="L124">        type_id: TypeId,</span>
<span class="line" id="L125">        description: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>,</span>
<span class="line" id="L126">        <span class="tok-comment">/// If the `type_id` is `enum` this provides the list of enum options</span></span>
<span class="line" id="L127">        enum_options: ?[]<span class="tok-kw">const</span> []<span class="tok-kw">const</span> <span class="tok-type">u8</span>,</span>
<span class="line" id="L128">    };</span>
<span class="line" id="L129"></span>
<span class="line" id="L130">    <span class="tok-kw">const</span> UserInputOption = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L131">        name: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>,</span>
<span class="line" id="L132">        value: UserValue,</span>
<span class="line" id="L133">        used: <span class="tok-type">bool</span>,</span>
<span class="line" id="L134">    };</span>
<span class="line" id="L135"></span>
<span class="line" id="L136">    <span class="tok-kw">const</span> UserValue = <span class="tok-kw">union</span>(<span class="tok-kw">enum</span>) {</span>
<span class="line" id="L137">        flag: <span class="tok-type">void</span>,</span>
<span class="line" id="L138">        scalar: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>,</span>
<span class="line" id="L139">        list: ArrayList([]<span class="tok-kw">const</span> <span class="tok-type">u8</span>),</span>
<span class="line" id="L140">    };</span>
<span class="line" id="L141"></span>
<span class="line" id="L142">    <span class="tok-kw">const</span> TypeId = <span class="tok-kw">enum</span> {</span>
<span class="line" id="L143">        <span class="tok-type">bool</span>,</span>
<span class="line" id="L144">        int,</span>
<span class="line" id="L145">        float,</span>
<span class="line" id="L146">        @&quot;enum&quot;,</span>
<span class="line" id="L147">        string,</span>
<span class="line" id="L148">        list,</span>
<span class="line" id="L149">    };</span>
<span class="line" id="L150"></span>
<span class="line" id="L151">    <span class="tok-kw">const</span> TopLevelStep = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L152">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> base_id = .top_level;</span>
<span class="line" id="L153"></span>
<span class="line" id="L154">        step: Step,</span>
<span class="line" id="L155">        description: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>,</span>
<span class="line" id="L156">    };</span>
<span class="line" id="L157"></span>
<span class="line" id="L158">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> DirList = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L159">        lib_dir: ?[]<span class="tok-kw">const</span> <span class="tok-type">u8</span> = <span class="tok-null">null</span>,</span>
<span class="line" id="L160">        exe_dir: ?[]<span class="tok-kw">const</span> <span class="tok-type">u8</span> = <span class="tok-null">null</span>,</span>
<span class="line" id="L161">        include_dir: ?[]<span class="tok-kw">const</span> <span class="tok-type">u8</span> = <span class="tok-null">null</span>,</span>
<span class="line" id="L162">    };</span>
<span class="line" id="L163"></span>
<span class="line" id="L164">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">create</span>(</span>
<span class="line" id="L165">        allocator: Allocator,</span>
<span class="line" id="L166">        zig_exe: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>,</span>
<span class="line" id="L167">        build_root: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>,</span>
<span class="line" id="L168">        cache_root: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>,</span>
<span class="line" id="L169">        global_cache_root: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>,</span>
<span class="line" id="L170">    ) !*Builder {</span>
<span class="line" id="L171">        <span class="tok-kw">const</span> env_map = <span class="tok-kw">try</span> allocator.create(EnvMap);</span>
<span class="line" id="L172">        env_map.* = <span class="tok-kw">try</span> process.getEnvMap(allocator);</span>
<span class="line" id="L173"></span>
<span class="line" id="L174">        <span class="tok-kw">const</span> host = <span class="tok-kw">try</span> NativeTargetInfo.detect(allocator, .{});</span>
<span class="line" id="L175"></span>
<span class="line" id="L176">        <span class="tok-kw">const</span> self = <span class="tok-kw">try</span> allocator.create(Builder);</span>
<span class="line" id="L177">        self.* = Builder{</span>
<span class="line" id="L178">            .zig_exe = zig_exe,</span>
<span class="line" id="L179">            .build_root = build_root,</span>
<span class="line" id="L180">            .cache_root = <span class="tok-kw">try</span> fs.path.relative(allocator, build_root, cache_root),</span>
<span class="line" id="L181">            .global_cache_root = global_cache_root,</span>
<span class="line" id="L182">            .verbose = <span class="tok-null">false</span>,</span>
<span class="line" id="L183">            .verbose_link = <span class="tok-null">false</span>,</span>
<span class="line" id="L184">            .verbose_cc = <span class="tok-null">false</span>,</span>
<span class="line" id="L185">            .verbose_air = <span class="tok-null">false</span>,</span>
<span class="line" id="L186">            .verbose_llvm_ir = <span class="tok-null">false</span>,</span>
<span class="line" id="L187">            .verbose_cimport = <span class="tok-null">false</span>,</span>
<span class="line" id="L188">            .verbose_llvm_cpu_features = <span class="tok-null">false</span>,</span>
<span class="line" id="L189">            .prominent_compile_errors = <span class="tok-null">false</span>,</span>
<span class="line" id="L190">            .invalid_user_input = <span class="tok-null">false</span>,</span>
<span class="line" id="L191">            .allocator = allocator,</span>
<span class="line" id="L192">            .user_input_options = UserInputOptionsMap.init(allocator),</span>
<span class="line" id="L193">            .available_options_map = AvailableOptionsMap.init(allocator),</span>
<span class="line" id="L194">            .available_options_list = ArrayList(AvailableOption).init(allocator),</span>
<span class="line" id="L195">            .top_level_steps = ArrayList(*TopLevelStep).init(allocator),</span>
<span class="line" id="L196">            .default_step = <span class="tok-null">undefined</span>,</span>
<span class="line" id="L197">            .env_map = env_map,</span>
<span class="line" id="L198">            .search_prefixes = ArrayList([]<span class="tok-kw">const</span> <span class="tok-type">u8</span>).init(allocator),</span>
<span class="line" id="L199">            .install_prefix = <span class="tok-null">undefined</span>,</span>
<span class="line" id="L200">            .lib_dir = <span class="tok-null">undefined</span>,</span>
<span class="line" id="L201">            .exe_dir = <span class="tok-null">undefined</span>,</span>
<span class="line" id="L202">            .h_dir = <span class="tok-null">undefined</span>,</span>
<span class="line" id="L203">            .dest_dir = env_map.get(<span class="tok-str">&quot;DESTDIR&quot;</span>),</span>
<span class="line" id="L204">            .installed_files = ArrayList(InstalledFile).init(allocator),</span>
<span class="line" id="L205">            .install_tls = TopLevelStep{</span>
<span class="line" id="L206">                .step = Step.initNoOp(.top_level, <span class="tok-str">&quot;install&quot;</span>, allocator),</span>
<span class="line" id="L207">                .description = <span class="tok-str">&quot;Copy build artifacts to prefix path&quot;</span>,</span>
<span class="line" id="L208">            },</span>
<span class="line" id="L209">            .uninstall_tls = TopLevelStep{</span>
<span class="line" id="L210">                .step = Step.init(.top_level, <span class="tok-str">&quot;uninstall&quot;</span>, allocator, makeUninstall),</span>
<span class="line" id="L211">                .description = <span class="tok-str">&quot;Remove build artifacts from prefix path&quot;</span>,</span>
<span class="line" id="L212">            },</span>
<span class="line" id="L213">            .release_mode = <span class="tok-null">null</span>,</span>
<span class="line" id="L214">            .is_release = <span class="tok-null">false</span>,</span>
<span class="line" id="L215">            .override_lib_dir = <span class="tok-null">null</span>,</span>
<span class="line" id="L216">            .install_path = <span class="tok-null">undefined</span>,</span>
<span class="line" id="L217">            .vcpkg_root = VcpkgRoot{ .unattempted = {} },</span>
<span class="line" id="L218">            .args = <span class="tok-null">null</span>,</span>
<span class="line" id="L219">            .host = host,</span>
<span class="line" id="L220">        };</span>
<span class="line" id="L221">        <span class="tok-kw">try</span> self.top_level_steps.append(&amp;self.install_tls);</span>
<span class="line" id="L222">        <span class="tok-kw">try</span> self.top_level_steps.append(&amp;self.uninstall_tls);</span>
<span class="line" id="L223">        self.default_step = &amp;self.install_tls.step;</span>
<span class="line" id="L224">        <span class="tok-kw">return</span> self;</span>
<span class="line" id="L225">    }</span>
<span class="line" id="L226"></span>
<span class="line" id="L227">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">destroy</span>(self: *Builder) <span class="tok-type">void</span> {</span>
<span class="line" id="L228">        self.env_map.deinit();</span>
<span class="line" id="L229">        self.top_level_steps.deinit();</span>
<span class="line" id="L230">        self.allocator.destroy(self);</span>
<span class="line" id="L231">    }</span>
<span class="line" id="L232"></span>
<span class="line" id="L233">    <span class="tok-comment">/// This function is intended to be called by lib/build_runner.zig, not a build.zig file.</span></span>
<span class="line" id="L234">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">resolveInstallPrefix</span>(self: *Builder, install_prefix: ?[]<span class="tok-kw">const</span> <span class="tok-type">u8</span>, dir_list: DirList) <span class="tok-type">void</span> {</span>
<span class="line" id="L235">        <span class="tok-kw">if</span> (self.dest_dir) |dest_dir| {</span>
<span class="line" id="L236">            self.install_prefix = install_prefix <span class="tok-kw">orelse</span> <span class="tok-str">&quot;/usr&quot;</span>;</span>
<span class="line" id="L237">            self.install_path = self.pathJoin(&amp;.{ dest_dir, self.install_prefix });</span>
<span class="line" id="L238">        } <span class="tok-kw">else</span> {</span>
<span class="line" id="L239">            self.install_prefix = install_prefix <span class="tok-kw">orelse</span></span>
<span class="line" id="L240">                (self.pathJoin(&amp;.{ self.build_root, <span class="tok-str">&quot;zig-out&quot;</span> }));</span>
<span class="line" id="L241">            self.install_path = self.install_prefix;</span>
<span class="line" id="L242">        }</span>
<span class="line" id="L243"></span>
<span class="line" id="L244">        <span class="tok-kw">var</span> lib_list = [_][]<span class="tok-kw">const</span> <span class="tok-type">u8</span>{ self.install_path, <span class="tok-str">&quot;lib&quot;</span> };</span>
<span class="line" id="L245">        <span class="tok-kw">var</span> exe_list = [_][]<span class="tok-kw">const</span> <span class="tok-type">u8</span>{ self.install_path, <span class="tok-str">&quot;bin&quot;</span> };</span>
<span class="line" id="L246">        <span class="tok-kw">var</span> h_list = [_][]<span class="tok-kw">const</span> <span class="tok-type">u8</span>{ self.install_path, <span class="tok-str">&quot;include&quot;</span> };</span>
<span class="line" id="L247"></span>
<span class="line" id="L248">        <span class="tok-kw">if</span> (dir_list.lib_dir) |dir| {</span>
<span class="line" id="L249">            <span class="tok-kw">if</span> (std.fs.path.isAbsolute(dir)) lib_list[<span class="tok-number">0</span>] = self.dest_dir <span class="tok-kw">orelse</span> <span class="tok-str">&quot;&quot;</span>;</span>
<span class="line" id="L250">            lib_list[<span class="tok-number">1</span>] = dir;</span>
<span class="line" id="L251">        }</span>
<span class="line" id="L252"></span>
<span class="line" id="L253">        <span class="tok-kw">if</span> (dir_list.exe_dir) |dir| {</span>
<span class="line" id="L254">            <span class="tok-kw">if</span> (std.fs.path.isAbsolute(dir)) exe_list[<span class="tok-number">0</span>] = self.dest_dir <span class="tok-kw">orelse</span> <span class="tok-str">&quot;&quot;</span>;</span>
<span class="line" id="L255">            exe_list[<span class="tok-number">1</span>] = dir;</span>
<span class="line" id="L256">        }</span>
<span class="line" id="L257"></span>
<span class="line" id="L258">        <span class="tok-kw">if</span> (dir_list.include_dir) |dir| {</span>
<span class="line" id="L259">            <span class="tok-kw">if</span> (std.fs.path.isAbsolute(dir)) h_list[<span class="tok-number">0</span>] = self.dest_dir <span class="tok-kw">orelse</span> <span class="tok-str">&quot;&quot;</span>;</span>
<span class="line" id="L260">            h_list[<span class="tok-number">1</span>] = dir;</span>
<span class="line" id="L261">        }</span>
<span class="line" id="L262"></span>
<span class="line" id="L263">        self.lib_dir = self.pathJoin(&amp;lib_list);</span>
<span class="line" id="L264">        self.exe_dir = self.pathJoin(&amp;exe_list);</span>
<span class="line" id="L265">        self.h_dir = self.pathJoin(&amp;h_list);</span>
<span class="line" id="L266">    }</span>
<span class="line" id="L267"></span>
<span class="line" id="L268">    <span class="tok-kw">fn</span> <span class="tok-fn">convertOptionalPathToFileSource</span>(path: ?[]<span class="tok-kw">const</span> <span class="tok-type">u8</span>) ?FileSource {</span>
<span class="line" id="L269">        <span class="tok-kw">return</span> <span class="tok-kw">if</span> (path) |p|</span>
<span class="line" id="L270">            FileSource{ .path = p }</span>
<span class="line" id="L271">        <span class="tok-kw">else</span></span>
<span class="line" id="L272">            <span class="tok-null">null</span>;</span>
<span class="line" id="L273">    }</span>
<span class="line" id="L274"></span>
<span class="line" id="L275">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">addExecutable</span>(self: *Builder, name: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>, root_src: ?[]<span class="tok-kw">const</span> <span class="tok-type">u8</span>) *LibExeObjStep {</span>
<span class="line" id="L276">        <span class="tok-kw">return</span> addExecutableSource(self, name, convertOptionalPathToFileSource(root_src));</span>
<span class="line" id="L277">    }</span>
<span class="line" id="L278"></span>
<span class="line" id="L279">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">addExecutableSource</span>(builder: *Builder, name: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>, root_src: ?FileSource) *LibExeObjStep {</span>
<span class="line" id="L280">        <span class="tok-kw">return</span> LibExeObjStep.createExecutable(builder, name, root_src);</span>
<span class="line" id="L281">    }</span>
<span class="line" id="L282"></span>
<span class="line" id="L283">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">addOptions</span>(self: *Builder) *OptionsStep {</span>
<span class="line" id="L284">        <span class="tok-kw">return</span> OptionsStep.create(self);</span>
<span class="line" id="L285">    }</span>
<span class="line" id="L286"></span>
<span class="line" id="L287">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">addObject</span>(self: *Builder, name: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>, root_src: ?[]<span class="tok-kw">const</span> <span class="tok-type">u8</span>) *LibExeObjStep {</span>
<span class="line" id="L288">        <span class="tok-kw">return</span> addObjectSource(self, name, convertOptionalPathToFileSource(root_src));</span>
<span class="line" id="L289">    }</span>
<span class="line" id="L290"></span>
<span class="line" id="L291">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">addObjectSource</span>(builder: *Builder, name: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>, root_src: ?FileSource) *LibExeObjStep {</span>
<span class="line" id="L292">        <span class="tok-kw">return</span> LibExeObjStep.createObject(builder, name, root_src);</span>
<span class="line" id="L293">    }</span>
<span class="line" id="L294"></span>
<span class="line" id="L295">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">addSharedLibrary</span>(</span>
<span class="line" id="L296">        self: *Builder,</span>
<span class="line" id="L297">        name: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>,</span>
<span class="line" id="L298">        root_src: ?[]<span class="tok-kw">const</span> <span class="tok-type">u8</span>,</span>
<span class="line" id="L299">        kind: LibExeObjStep.SharedLibKind,</span>
<span class="line" id="L300">    ) *LibExeObjStep {</span>
<span class="line" id="L301">        <span class="tok-kw">return</span> addSharedLibrarySource(self, name, convertOptionalPathToFileSource(root_src), kind);</span>
<span class="line" id="L302">    }</span>
<span class="line" id="L303"></span>
<span class="line" id="L304">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">addSharedLibrarySource</span>(</span>
<span class="line" id="L305">        self: *Builder,</span>
<span class="line" id="L306">        name: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>,</span>
<span class="line" id="L307">        root_src: ?FileSource,</span>
<span class="line" id="L308">        kind: LibExeObjStep.SharedLibKind,</span>
<span class="line" id="L309">    ) *LibExeObjStep {</span>
<span class="line" id="L310">        <span class="tok-kw">return</span> LibExeObjStep.createSharedLibrary(self, name, root_src, kind);</span>
<span class="line" id="L311">    }</span>
<span class="line" id="L312"></span>
<span class="line" id="L313">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">addStaticLibrary</span>(self: *Builder, name: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>, root_src: ?[]<span class="tok-kw">const</span> <span class="tok-type">u8</span>) *LibExeObjStep {</span>
<span class="line" id="L314">        <span class="tok-kw">return</span> addStaticLibrarySource(self, name, convertOptionalPathToFileSource(root_src));</span>
<span class="line" id="L315">    }</span>
<span class="line" id="L316"></span>
<span class="line" id="L317">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">addStaticLibrarySource</span>(self: *Builder, name: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>, root_src: ?FileSource) *LibExeObjStep {</span>
<span class="line" id="L318">        <span class="tok-kw">return</span> LibExeObjStep.createStaticLibrary(self, name, root_src);</span>
<span class="line" id="L319">    }</span>
<span class="line" id="L320"></span>
<span class="line" id="L321">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">addTest</span>(self: *Builder, root_src: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) *LibExeObjStep {</span>
<span class="line" id="L322">        <span class="tok-kw">return</span> LibExeObjStep.createTest(self, <span class="tok-str">&quot;test&quot;</span>, .{ .path = root_src });</span>
<span class="line" id="L323">    }</span>
<span class="line" id="L324"></span>
<span class="line" id="L325">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">addTestSource</span>(self: *Builder, root_src: FileSource) *LibExeObjStep {</span>
<span class="line" id="L326">        <span class="tok-kw">return</span> LibExeObjStep.createTest(self, <span class="tok-str">&quot;test&quot;</span>, root_src.dupe(self));</span>
<span class="line" id="L327">    }</span>
<span class="line" id="L328"></span>
<span class="line" id="L329">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">addTestExe</span>(self: *Builder, name: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>, root_src: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) *LibExeObjStep {</span>
<span class="line" id="L330">        <span class="tok-kw">return</span> LibExeObjStep.createTestExe(self, name, .{ .path = root_src });</span>
<span class="line" id="L331">    }</span>
<span class="line" id="L332"></span>
<span class="line" id="L333">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">addTestExeSource</span>(self: *Builder, name: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>, root_src: FileSource) *LibExeObjStep {</span>
<span class="line" id="L334">        <span class="tok-kw">return</span> LibExeObjStep.createTestExe(self, name, root_src.dupe(self));</span>
<span class="line" id="L335">    }</span>
<span class="line" id="L336"></span>
<span class="line" id="L337">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">addAssemble</span>(self: *Builder, name: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>, src: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) *LibExeObjStep {</span>
<span class="line" id="L338">        <span class="tok-kw">return</span> addAssembleSource(self, name, .{ .path = src });</span>
<span class="line" id="L339">    }</span>
<span class="line" id="L340"></span>
<span class="line" id="L341">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">addAssembleSource</span>(self: *Builder, name: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>, src: FileSource) *LibExeObjStep {</span>
<span class="line" id="L342">        <span class="tok-kw">const</span> obj_step = LibExeObjStep.createObject(self, name, <span class="tok-null">null</span>);</span>
<span class="line" id="L343">        obj_step.addAssemblyFileSource(src.dupe(self));</span>
<span class="line" id="L344">        <span class="tok-kw">return</span> obj_step;</span>
<span class="line" id="L345">    }</span>
<span class="line" id="L346"></span>
<span class="line" id="L347">    <span class="tok-comment">/// Initializes a RunStep with argv, which must at least have the path to the</span></span>
<span class="line" id="L348">    <span class="tok-comment">/// executable. More command line arguments can be added with `addArg`,</span></span>
<span class="line" id="L349">    <span class="tok-comment">/// `addArgs`, and `addArtifactArg`.</span></span>
<span class="line" id="L350">    <span class="tok-comment">/// Be careful using this function, as it introduces a system dependency.</span></span>
<span class="line" id="L351">    <span class="tok-comment">/// To run an executable built with zig build, see `LibExeObjStep.run`.</span></span>
<span class="line" id="L352">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">addSystemCommand</span>(self: *Builder, argv: []<span class="tok-kw">const</span> []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) *RunStep {</span>
<span class="line" id="L353">        assert(argv.len &gt;= <span class="tok-number">1</span>);</span>
<span class="line" id="L354">        <span class="tok-kw">const</span> run_step = RunStep.create(self, self.fmt(<span class="tok-str">&quot;run {s}&quot;</span>, .{argv[<span class="tok-number">0</span>]}));</span>
<span class="line" id="L355">        run_step.addArgs(argv);</span>
<span class="line" id="L356">        <span class="tok-kw">return</span> run_step;</span>
<span class="line" id="L357">    }</span>
<span class="line" id="L358"></span>
<span class="line" id="L359">    <span class="tok-comment">/// Allocator.dupe without the need to handle out of memory.</span></span>
<span class="line" id="L360">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">dupe</span>(self: *Builder, bytes: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) []<span class="tok-type">u8</span> {</span>
<span class="line" id="L361">        <span class="tok-kw">return</span> self.allocator.dupe(<span class="tok-type">u8</span>, bytes) <span class="tok-kw">catch</span> <span class="tok-kw">unreachable</span>;</span>
<span class="line" id="L362">    }</span>
<span class="line" id="L363"></span>
<span class="line" id="L364">    <span class="tok-comment">/// Duplicates an array of strings without the need to handle out of memory.</span></span>
<span class="line" id="L365">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">dupeStrings</span>(self: *Builder, strings: []<span class="tok-kw">const</span> []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) [][]<span class="tok-type">u8</span> {</span>
<span class="line" id="L366">        <span class="tok-kw">const</span> array = self.allocator.alloc([]<span class="tok-type">u8</span>, strings.len) <span class="tok-kw">catch</span> <span class="tok-kw">unreachable</span>;</span>
<span class="line" id="L367">        <span class="tok-kw">for</span> (strings) |s, i| {</span>
<span class="line" id="L368">            array[i] = self.dupe(s);</span>
<span class="line" id="L369">        }</span>
<span class="line" id="L370">        <span class="tok-kw">return</span> array;</span>
<span class="line" id="L371">    }</span>
<span class="line" id="L372"></span>
<span class="line" id="L373">    <span class="tok-comment">/// Duplicates a path and converts all slashes to the OS's canonical path separator.</span></span>
<span class="line" id="L374">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">dupePath</span>(self: *Builder, bytes: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) []<span class="tok-type">u8</span> {</span>
<span class="line" id="L375">        <span class="tok-kw">const</span> the_copy = self.dupe(bytes);</span>
<span class="line" id="L376">        <span class="tok-kw">for</span> (the_copy) |*byte| {</span>
<span class="line" id="L377">            <span class="tok-kw">switch</span> (byte.*) {</span>
<span class="line" id="L378">                <span class="tok-str">'/'</span>, <span class="tok-str">'\\'</span> =&gt; byte.* = fs.path.sep,</span>
<span class="line" id="L379">                <span class="tok-kw">else</span> =&gt; {},</span>
<span class="line" id="L380">            }</span>
<span class="line" id="L381">        }</span>
<span class="line" id="L382">        <span class="tok-kw">return</span> the_copy;</span>
<span class="line" id="L383">    }</span>
<span class="line" id="L384"></span>
<span class="line" id="L385">    <span class="tok-comment">/// Duplicates a package recursively.</span></span>
<span class="line" id="L386">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">dupePkg</span>(self: *Builder, package: Pkg) Pkg {</span>
<span class="line" id="L387">        <span class="tok-kw">var</span> the_copy = Pkg{</span>
<span class="line" id="L388">            .name = self.dupe(package.name),</span>
<span class="line" id="L389">            .source = package.source.dupe(self),</span>
<span class="line" id="L390">        };</span>
<span class="line" id="L391"></span>
<span class="line" id="L392">        <span class="tok-kw">if</span> (package.dependencies) |dependencies| {</span>
<span class="line" id="L393">            <span class="tok-kw">const</span> new_dependencies = self.allocator.alloc(Pkg, dependencies.len) <span class="tok-kw">catch</span> <span class="tok-kw">unreachable</span>;</span>
<span class="line" id="L394">            the_copy.dependencies = new_dependencies;</span>
<span class="line" id="L395"></span>
<span class="line" id="L396">            <span class="tok-kw">for</span> (dependencies) |dep_package, i| {</span>
<span class="line" id="L397">                new_dependencies[i] = self.dupePkg(dep_package);</span>
<span class="line" id="L398">            }</span>
<span class="line" id="L399">        }</span>
<span class="line" id="L400">        <span class="tok-kw">return</span> the_copy;</span>
<span class="line" id="L401">    }</span>
<span class="line" id="L402"></span>
<span class="line" id="L403">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">addWriteFile</span>(self: *Builder, file_path: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>, data: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) *WriteFileStep {</span>
<span class="line" id="L404">        <span class="tok-kw">const</span> write_file_step = self.addWriteFiles();</span>
<span class="line" id="L405">        write_file_step.add(file_path, data);</span>
<span class="line" id="L406">        <span class="tok-kw">return</span> write_file_step;</span>
<span class="line" id="L407">    }</span>
<span class="line" id="L408"></span>
<span class="line" id="L409">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">addWriteFiles</span>(self: *Builder) *WriteFileStep {</span>
<span class="line" id="L410">        <span class="tok-kw">const</span> write_file_step = self.allocator.create(WriteFileStep) <span class="tok-kw">catch</span> <span class="tok-kw">unreachable</span>;</span>
<span class="line" id="L411">        write_file_step.* = WriteFileStep.init(self);</span>
<span class="line" id="L412">        <span class="tok-kw">return</span> write_file_step;</span>
<span class="line" id="L413">    }</span>
<span class="line" id="L414"></span>
<span class="line" id="L415">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">addLog</span>(self: *Builder, <span class="tok-kw">comptime</span> format: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>, args: <span class="tok-kw">anytype</span>) *LogStep {</span>
<span class="line" id="L416">        <span class="tok-kw">const</span> data = self.fmt(format, args);</span>
<span class="line" id="L417">        <span class="tok-kw">const</span> log_step = self.allocator.create(LogStep) <span class="tok-kw">catch</span> <span class="tok-kw">unreachable</span>;</span>
<span class="line" id="L418">        log_step.* = LogStep.init(self, data);</span>
<span class="line" id="L419">        <span class="tok-kw">return</span> log_step;</span>
<span class="line" id="L420">    }</span>
<span class="line" id="L421"></span>
<span class="line" id="L422">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">addRemoveDirTree</span>(self: *Builder, dir_path: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) *RemoveDirStep {</span>
<span class="line" id="L423">        <span class="tok-kw">const</span> remove_dir_step = self.allocator.create(RemoveDirStep) <span class="tok-kw">catch</span> <span class="tok-kw">unreachable</span>;</span>
<span class="line" id="L424">        remove_dir_step.* = RemoveDirStep.init(self, dir_path);</span>
<span class="line" id="L425">        <span class="tok-kw">return</span> remove_dir_step;</span>
<span class="line" id="L426">    }</span>
<span class="line" id="L427"></span>
<span class="line" id="L428">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">addFmt</span>(self: *Builder, paths: []<span class="tok-kw">const</span> []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) *FmtStep {</span>
<span class="line" id="L429">        <span class="tok-kw">return</span> FmtStep.create(self, paths);</span>
<span class="line" id="L430">    }</span>
<span class="line" id="L431"></span>
<span class="line" id="L432">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">addTranslateC</span>(self: *Builder, source: FileSource) *TranslateCStep {</span>
<span class="line" id="L433">        <span class="tok-kw">return</span> TranslateCStep.create(self, source.dupe(self));</span>
<span class="line" id="L434">    }</span>
<span class="line" id="L435"></span>
<span class="line" id="L436">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">version</span>(self: *<span class="tok-kw">const</span> Builder, major: <span class="tok-type">u32</span>, minor: <span class="tok-type">u32</span>, patch: <span class="tok-type">u32</span>) LibExeObjStep.SharedLibKind {</span>
<span class="line" id="L437">        _ = self;</span>
<span class="line" id="L438">        <span class="tok-kw">return</span> .{</span>
<span class="line" id="L439">            .versioned = .{</span>
<span class="line" id="L440">                .major = major,</span>
<span class="line" id="L441">                .minor = minor,</span>
<span class="line" id="L442">                .patch = patch,</span>
<span class="line" id="L443">            },</span>
<span class="line" id="L444">        };</span>
<span class="line" id="L445">    }</span>
<span class="line" id="L446"></span>
<span class="line" id="L447">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">make</span>(self: *Builder, step_names: []<span class="tok-kw">const</span> []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) !<span class="tok-type">void</span> {</span>
<span class="line" id="L448">        <span class="tok-kw">try</span> self.makePath(self.cache_root);</span>
<span class="line" id="L449"></span>
<span class="line" id="L450">        <span class="tok-kw">var</span> wanted_steps = ArrayList(*Step).init(self.allocator);</span>
<span class="line" id="L451">        <span class="tok-kw">defer</span> wanted_steps.deinit();</span>
<span class="line" id="L452"></span>
<span class="line" id="L453">        <span class="tok-kw">if</span> (step_names.len == <span class="tok-number">0</span>) {</span>
<span class="line" id="L454">            <span class="tok-kw">try</span> wanted_steps.append(self.default_step);</span>
<span class="line" id="L455">        } <span class="tok-kw">else</span> {</span>
<span class="line" id="L456">            <span class="tok-kw">for</span> (step_names) |step_name| {</span>
<span class="line" id="L457">                <span class="tok-kw">const</span> s = <span class="tok-kw">try</span> self.getTopLevelStepByName(step_name);</span>
<span class="line" id="L458">                <span class="tok-kw">try</span> wanted_steps.append(s);</span>
<span class="line" id="L459">            }</span>
<span class="line" id="L460">        }</span>
<span class="line" id="L461"></span>
<span class="line" id="L462">        <span class="tok-kw">for</span> (wanted_steps.items) |s| {</span>
<span class="line" id="L463">            <span class="tok-kw">try</span> self.makeOneStep(s);</span>
<span class="line" id="L464">        }</span>
<span class="line" id="L465">    }</span>
<span class="line" id="L466"></span>
<span class="line" id="L467">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">getInstallStep</span>(self: *Builder) *Step {</span>
<span class="line" id="L468">        <span class="tok-kw">return</span> &amp;self.install_tls.step;</span>
<span class="line" id="L469">    }</span>
<span class="line" id="L470"></span>
<span class="line" id="L471">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">getUninstallStep</span>(self: *Builder) *Step {</span>
<span class="line" id="L472">        <span class="tok-kw">return</span> &amp;self.uninstall_tls.step;</span>
<span class="line" id="L473">    }</span>
<span class="line" id="L474"></span>
<span class="line" id="L475">    <span class="tok-kw">fn</span> <span class="tok-fn">makeUninstall</span>(uninstall_step: *Step) <span class="tok-type">anyerror</span>!<span class="tok-type">void</span> {</span>
<span class="line" id="L476">        <span class="tok-kw">const</span> uninstall_tls = <span class="tok-builtin">@fieldParentPtr</span>(TopLevelStep, <span class="tok-str">&quot;step&quot;</span>, uninstall_step);</span>
<span class="line" id="L477">        <span class="tok-kw">const</span> self = <span class="tok-builtin">@fieldParentPtr</span>(Builder, <span class="tok-str">&quot;uninstall_tls&quot;</span>, uninstall_tls);</span>
<span class="line" id="L478"></span>
<span class="line" id="L479">        <span class="tok-kw">for</span> (self.installed_files.items) |installed_file| {</span>
<span class="line" id="L480">            <span class="tok-kw">const</span> full_path = self.getInstallPath(installed_file.dir, installed_file.path);</span>
<span class="line" id="L481">            <span class="tok-kw">if</span> (self.verbose) {</span>
<span class="line" id="L482">                log.info(<span class="tok-str">&quot;rm {s}&quot;</span>, .{full_path});</span>
<span class="line" id="L483">            }</span>
<span class="line" id="L484">            fs.cwd().deleteTree(full_path) <span class="tok-kw">catch</span> {};</span>
<span class="line" id="L485">        }</span>
<span class="line" id="L486"></span>
<span class="line" id="L487">        <span class="tok-comment">// TODO remove empty directories</span>
</span>
<span class="line" id="L488">    }</span>
<span class="line" id="L489"></span>
<span class="line" id="L490">    <span class="tok-kw">fn</span> <span class="tok-fn">makeOneStep</span>(self: *Builder, s: *Step) <span class="tok-type">anyerror</span>!<span class="tok-type">void</span> {</span>
<span class="line" id="L491">        <span class="tok-kw">if</span> (s.loop_flag) {</span>
<span class="line" id="L492">            log.err(<span class="tok-str">&quot;Dependency loop detected:\n  {s}&quot;</span>, .{s.name});</span>
<span class="line" id="L493">            <span class="tok-kw">return</span> <span class="tok-kw">error</span>.DependencyLoopDetected;</span>
<span class="line" id="L494">        }</span>
<span class="line" id="L495">        s.loop_flag = <span class="tok-null">true</span>;</span>
<span class="line" id="L496"></span>
<span class="line" id="L497">        <span class="tok-kw">for</span> (s.dependencies.items) |dep| {</span>
<span class="line" id="L498">            self.makeOneStep(dep) <span class="tok-kw">catch</span> |err| {</span>
<span class="line" id="L499">                <span class="tok-kw">if</span> (err == <span class="tok-kw">error</span>.DependencyLoopDetected) {</span>
<span class="line" id="L500">                    log.err(<span class="tok-str">&quot;  {s}&quot;</span>, .{s.name});</span>
<span class="line" id="L501">                }</span>
<span class="line" id="L502">                <span class="tok-kw">return</span> err;</span>
<span class="line" id="L503">            };</span>
<span class="line" id="L504">        }</span>
<span class="line" id="L505"></span>
<span class="line" id="L506">        s.loop_flag = <span class="tok-null">false</span>;</span>
<span class="line" id="L507"></span>
<span class="line" id="L508">        <span class="tok-kw">try</span> s.make();</span>
<span class="line" id="L509">    }</span>
<span class="line" id="L510"></span>
<span class="line" id="L511">    <span class="tok-kw">fn</span> <span class="tok-fn">getTopLevelStepByName</span>(self: *Builder, name: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) !*Step {</span>
<span class="line" id="L512">        <span class="tok-kw">for</span> (self.top_level_steps.items) |top_level_step| {</span>
<span class="line" id="L513">            <span class="tok-kw">if</span> (mem.eql(<span class="tok-type">u8</span>, top_level_step.step.name, name)) {</span>
<span class="line" id="L514">                <span class="tok-kw">return</span> &amp;top_level_step.step;</span>
<span class="line" id="L515">            }</span>
<span class="line" id="L516">        }</span>
<span class="line" id="L517">        log.err(<span class="tok-str">&quot;Cannot run step '{s}' because it does not exist&quot;</span>, .{name});</span>
<span class="line" id="L518">        <span class="tok-kw">return</span> <span class="tok-kw">error</span>.InvalidStepName;</span>
<span class="line" id="L519">    }</span>
<span class="line" id="L520"></span>
<span class="line" id="L521">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">option</span>(self: *Builder, <span class="tok-kw">comptime</span> T: <span class="tok-type">type</span>, name_raw: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>, description_raw: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) ?T {</span>
<span class="line" id="L522">        <span class="tok-kw">const</span> name = self.dupe(name_raw);</span>
<span class="line" id="L523">        <span class="tok-kw">const</span> description = self.dupe(description_raw);</span>
<span class="line" id="L524">        <span class="tok-kw">const</span> type_id = <span class="tok-kw">comptime</span> typeToEnum(T);</span>
<span class="line" id="L525">        <span class="tok-kw">const</span> enum_options = <span class="tok-kw">if</span> (type_id == .@&quot;enum&quot;) blk: {</span>
<span class="line" id="L526">            <span class="tok-kw">const</span> fields = <span class="tok-kw">comptime</span> std.meta.fields(T);</span>
<span class="line" id="L527">            <span class="tok-kw">var</span> options = ArrayList([]<span class="tok-kw">const</span> <span class="tok-type">u8</span>).initCapacity(self.allocator, fields.len) <span class="tok-kw">catch</span> <span class="tok-kw">unreachable</span>;</span>
<span class="line" id="L528"></span>
<span class="line" id="L529">            <span class="tok-kw">inline</span> <span class="tok-kw">for</span> (fields) |field| {</span>
<span class="line" id="L530">                options.appendAssumeCapacity(field.name);</span>
<span class="line" id="L531">            }</span>
<span class="line" id="L532"></span>
<span class="line" id="L533">            <span class="tok-kw">break</span> :blk options.toOwnedSlice();</span>
<span class="line" id="L534">        } <span class="tok-kw">else</span> <span class="tok-null">null</span>;</span>
<span class="line" id="L535">        <span class="tok-kw">const</span> available_option = AvailableOption{</span>
<span class="line" id="L536">            .name = name,</span>
<span class="line" id="L537">            .type_id = type_id,</span>
<span class="line" id="L538">            .description = description,</span>
<span class="line" id="L539">            .enum_options = enum_options,</span>
<span class="line" id="L540">        };</span>
<span class="line" id="L541">        <span class="tok-kw">if</span> ((self.available_options_map.fetchPut(name, available_option) <span class="tok-kw">catch</span> <span class="tok-kw">unreachable</span>) != <span class="tok-null">null</span>) {</span>
<span class="line" id="L542">            panic(<span class="tok-str">&quot;Option '{s}' declared twice&quot;</span>, .{name});</span>
<span class="line" id="L543">        }</span>
<span class="line" id="L544">        self.available_options_list.append(available_option) <span class="tok-kw">catch</span> <span class="tok-kw">unreachable</span>;</span>
<span class="line" id="L545"></span>
<span class="line" id="L546">        <span class="tok-kw">const</span> option_ptr = self.user_input_options.getPtr(name) <span class="tok-kw">orelse</span> <span class="tok-kw">return</span> <span class="tok-null">null</span>;</span>
<span class="line" id="L547">        option_ptr.used = <span class="tok-null">true</span>;</span>
<span class="line" id="L548">        <span class="tok-kw">switch</span> (type_id) {</span>
<span class="line" id="L549">            .<span class="tok-type">bool</span> =&gt; <span class="tok-kw">switch</span> (option_ptr.value) {</span>
<span class="line" id="L550">                .flag =&gt; <span class="tok-kw">return</span> <span class="tok-null">true</span>,</span>
<span class="line" id="L551">                .scalar =&gt; |s| {</span>
<span class="line" id="L552">                    <span class="tok-kw">if</span> (mem.eql(<span class="tok-type">u8</span>, s, <span class="tok-str">&quot;true&quot;</span>)) {</span>
<span class="line" id="L553">                        <span class="tok-kw">return</span> <span class="tok-null">true</span>;</span>
<span class="line" id="L554">                    } <span class="tok-kw">else</span> <span class="tok-kw">if</span> (mem.eql(<span class="tok-type">u8</span>, s, <span class="tok-str">&quot;false&quot;</span>)) {</span>
<span class="line" id="L555">                        <span class="tok-kw">return</span> <span class="tok-null">false</span>;</span>
<span class="line" id="L556">                    } <span class="tok-kw">else</span> {</span>
<span class="line" id="L557">                        log.err(<span class="tok-str">&quot;Expected -D{s} to be a boolean, but received '{s}'\n&quot;</span>, .{ name, s });</span>
<span class="line" id="L558">                        self.markInvalidUserInput();</span>
<span class="line" id="L559">                        <span class="tok-kw">return</span> <span class="tok-null">null</span>;</span>
<span class="line" id="L560">                    }</span>
<span class="line" id="L561">                },</span>
<span class="line" id="L562">                .list =&gt; {</span>
<span class="line" id="L563">                    log.err(<span class="tok-str">&quot;Expected -D{s} to be a boolean, but received a list.\n&quot;</span>, .{name});</span>
<span class="line" id="L564">                    self.markInvalidUserInput();</span>
<span class="line" id="L565">                    <span class="tok-kw">return</span> <span class="tok-null">null</span>;</span>
<span class="line" id="L566">                },</span>
<span class="line" id="L567">            },</span>
<span class="line" id="L568">            .int =&gt; <span class="tok-kw">switch</span> (option_ptr.value) {</span>
<span class="line" id="L569">                .flag =&gt; {</span>
<span class="line" id="L570">                    log.err(<span class="tok-str">&quot;Expected -D{s} to be an integer, but received a boolean.\n&quot;</span>, .{name});</span>
<span class="line" id="L571">                    self.markInvalidUserInput();</span>
<span class="line" id="L572">                    <span class="tok-kw">return</span> <span class="tok-null">null</span>;</span>
<span class="line" id="L573">                },</span>
<span class="line" id="L574">                .scalar =&gt; |s| {</span>
<span class="line" id="L575">                    <span class="tok-kw">const</span> n = std.fmt.parseInt(T, s, <span class="tok-number">10</span>) <span class="tok-kw">catch</span> |err| <span class="tok-kw">switch</span> (err) {</span>
<span class="line" id="L576">                        <span class="tok-kw">error</span>.Overflow =&gt; {</span>
<span class="line" id="L577">                            log.err(<span class="tok-str">&quot;-D{s} value {s} cannot fit into type {s}.\n&quot;</span>, .{ name, s, <span class="tok-builtin">@typeName</span>(T) });</span>
<span class="line" id="L578">                            self.markInvalidUserInput();</span>
<span class="line" id="L579">                            <span class="tok-kw">return</span> <span class="tok-null">null</span>;</span>
<span class="line" id="L580">                        },</span>
<span class="line" id="L581">                        <span class="tok-kw">else</span> =&gt; {</span>
<span class="line" id="L582">                            log.err(<span class="tok-str">&quot;Expected -D{s} to be an integer of type {s}.\n&quot;</span>, .{ name, <span class="tok-builtin">@typeName</span>(T) });</span>
<span class="line" id="L583">                            self.markInvalidUserInput();</span>
<span class="line" id="L584">                            <span class="tok-kw">return</span> <span class="tok-null">null</span>;</span>
<span class="line" id="L585">                        },</span>
<span class="line" id="L586">                    };</span>
<span class="line" id="L587">                    <span class="tok-kw">return</span> n;</span>
<span class="line" id="L588">                },</span>
<span class="line" id="L589">                .list =&gt; {</span>
<span class="line" id="L590">                    log.err(<span class="tok-str">&quot;Expected -D{s} to be an integer, but received a list.\n&quot;</span>, .{name});</span>
<span class="line" id="L591">                    self.markInvalidUserInput();</span>
<span class="line" id="L592">                    <span class="tok-kw">return</span> <span class="tok-null">null</span>;</span>
<span class="line" id="L593">                },</span>
<span class="line" id="L594">            },</span>
<span class="line" id="L595">            .float =&gt; <span class="tok-kw">switch</span> (option_ptr.value) {</span>
<span class="line" id="L596">                .flag =&gt; {</span>
<span class="line" id="L597">                    log.err(<span class="tok-str">&quot;Expected -D{s} to be a float, but received a boolean.\n&quot;</span>, .{name});</span>
<span class="line" id="L598">                    self.markInvalidUserInput();</span>
<span class="line" id="L599">                    <span class="tok-kw">return</span> <span class="tok-null">null</span>;</span>
<span class="line" id="L600">                },</span>
<span class="line" id="L601">                .scalar =&gt; |s| {</span>
<span class="line" id="L602">                    <span class="tok-kw">const</span> n = std.fmt.parseFloat(T, s) <span class="tok-kw">catch</span> {</span>
<span class="line" id="L603">                        log.err(<span class="tok-str">&quot;Expected -D{s} to be a float of type {s}.\n&quot;</span>, .{ name, <span class="tok-builtin">@typeName</span>(T) });</span>
<span class="line" id="L604">                        self.markInvalidUserInput();</span>
<span class="line" id="L605">                        <span class="tok-kw">return</span> <span class="tok-null">null</span>;</span>
<span class="line" id="L606">                    };</span>
<span class="line" id="L607">                    <span class="tok-kw">return</span> n;</span>
<span class="line" id="L608">                },</span>
<span class="line" id="L609">                .list =&gt; {</span>
<span class="line" id="L610">                    log.err(<span class="tok-str">&quot;Expected -D{s} to be a float, but received a list.\n&quot;</span>, .{name});</span>
<span class="line" id="L611">                    self.markInvalidUserInput();</span>
<span class="line" id="L612">                    <span class="tok-kw">return</span> <span class="tok-null">null</span>;</span>
<span class="line" id="L613">                },</span>
<span class="line" id="L614">            },</span>
<span class="line" id="L615">            .@&quot;enum&quot; =&gt; <span class="tok-kw">switch</span> (option_ptr.value) {</span>
<span class="line" id="L616">                .flag =&gt; {</span>
<span class="line" id="L617">                    log.err(<span class="tok-str">&quot;Expected -D{s} to be a string, but received a boolean.\n&quot;</span>, .{name});</span>
<span class="line" id="L618">                    self.markInvalidUserInput();</span>
<span class="line" id="L619">                    <span class="tok-kw">return</span> <span class="tok-null">null</span>;</span>
<span class="line" id="L620">                },</span>
<span class="line" id="L621">                .scalar =&gt; |s| {</span>
<span class="line" id="L622">                    <span class="tok-kw">if</span> (std.meta.stringToEnum(T, s)) |enum_lit| {</span>
<span class="line" id="L623">                        <span class="tok-kw">return</span> enum_lit;</span>
<span class="line" id="L624">                    } <span class="tok-kw">else</span> {</span>
<span class="line" id="L625">                        log.err(<span class="tok-str">&quot;Expected -D{s} to be of type {s}.\n&quot;</span>, .{ name, <span class="tok-builtin">@typeName</span>(T) });</span>
<span class="line" id="L626">                        self.markInvalidUserInput();</span>
<span class="line" id="L627">                        <span class="tok-kw">return</span> <span class="tok-null">null</span>;</span>
<span class="line" id="L628">                    }</span>
<span class="line" id="L629">                },</span>
<span class="line" id="L630">                .list =&gt; {</span>
<span class="line" id="L631">                    log.err(<span class="tok-str">&quot;Expected -D{s} to be a string, but received a list.\n&quot;</span>, .{name});</span>
<span class="line" id="L632">                    self.markInvalidUserInput();</span>
<span class="line" id="L633">                    <span class="tok-kw">return</span> <span class="tok-null">null</span>;</span>
<span class="line" id="L634">                },</span>
<span class="line" id="L635">            },</span>
<span class="line" id="L636">            .string =&gt; <span class="tok-kw">switch</span> (option_ptr.value) {</span>
<span class="line" id="L637">                .flag =&gt; {</span>
<span class="line" id="L638">                    log.err(<span class="tok-str">&quot;Expected -D{s} to be a string, but received a boolean.\n&quot;</span>, .{name});</span>
<span class="line" id="L639">                    self.markInvalidUserInput();</span>
<span class="line" id="L640">                    <span class="tok-kw">return</span> <span class="tok-null">null</span>;</span>
<span class="line" id="L641">                },</span>
<span class="line" id="L642">                .list =&gt; {</span>
<span class="line" id="L643">                    log.err(<span class="tok-str">&quot;Expected -D{s} to be a string, but received a list.\n&quot;</span>, .{name});</span>
<span class="line" id="L644">                    self.markInvalidUserInput();</span>
<span class="line" id="L645">                    <span class="tok-kw">return</span> <span class="tok-null">null</span>;</span>
<span class="line" id="L646">                },</span>
<span class="line" id="L647">                .scalar =&gt; |s| <span class="tok-kw">return</span> s,</span>
<span class="line" id="L648">            },</span>
<span class="line" id="L649">            .list =&gt; <span class="tok-kw">switch</span> (option_ptr.value) {</span>
<span class="line" id="L650">                .flag =&gt; {</span>
<span class="line" id="L651">                    log.err(<span class="tok-str">&quot;Expected -D{s} to be a list, but received a boolean.\n&quot;</span>, .{name});</span>
<span class="line" id="L652">                    self.markInvalidUserInput();</span>
<span class="line" id="L653">                    <span class="tok-kw">return</span> <span class="tok-null">null</span>;</span>
<span class="line" id="L654">                },</span>
<span class="line" id="L655">                .scalar =&gt; |s| {</span>
<span class="line" id="L656">                    <span class="tok-kw">return</span> self.allocator.dupe([]<span class="tok-kw">const</span> <span class="tok-type">u8</span>, &amp;[_][]<span class="tok-kw">const</span> <span class="tok-type">u8</span>{s}) <span class="tok-kw">catch</span> <span class="tok-kw">unreachable</span>;</span>
<span class="line" id="L657">                },</span>
<span class="line" id="L658">                .list =&gt; |lst| <span class="tok-kw">return</span> lst.items,</span>
<span class="line" id="L659">            },</span>
<span class="line" id="L660">        }</span>
<span class="line" id="L661">    }</span>
<span class="line" id="L662"></span>
<span class="line" id="L663">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">step</span>(self: *Builder, name: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>, description: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) *Step {</span>
<span class="line" id="L664">        <span class="tok-kw">const</span> step_info = self.allocator.create(TopLevelStep) <span class="tok-kw">catch</span> <span class="tok-kw">unreachable</span>;</span>
<span class="line" id="L665">        step_info.* = TopLevelStep{</span>
<span class="line" id="L666">            .step = Step.initNoOp(.top_level, name, self.allocator),</span>
<span class="line" id="L667">            .description = self.dupe(description),</span>
<span class="line" id="L668">        };</span>
<span class="line" id="L669">        self.top_level_steps.append(step_info) <span class="tok-kw">catch</span> <span class="tok-kw">unreachable</span>;</span>
<span class="line" id="L670">        <span class="tok-kw">return</span> &amp;step_info.step;</span>
<span class="line" id="L671">    }</span>
<span class="line" id="L672"></span>
<span class="line" id="L673">    <span class="tok-comment">/// This provides the -Drelease option to the build user and does not give them the choice.</span></span>
<span class="line" id="L674">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">setPreferredReleaseMode</span>(self: *Builder, mode: std.builtin.Mode) <span class="tok-type">void</span> {</span>
<span class="line" id="L675">        <span class="tok-kw">if</span> (self.release_mode != <span class="tok-null">null</span>) {</span>
<span class="line" id="L676">            <span class="tok-builtin">@panic</span>(<span class="tok-str">&quot;setPreferredReleaseMode must be called before standardReleaseOptions and may not be called twice&quot;</span>);</span>
<span class="line" id="L677">        }</span>
<span class="line" id="L678">        <span class="tok-kw">const</span> description = self.fmt(<span class="tok-str">&quot;Create a release build ({s})&quot;</span>, .{<span class="tok-builtin">@tagName</span>(mode)});</span>
<span class="line" id="L679">        self.is_release = self.option(<span class="tok-type">bool</span>, <span class="tok-str">&quot;release&quot;</span>, description) <span class="tok-kw">orelse</span> <span class="tok-null">false</span>;</span>
<span class="line" id="L680">        self.release_mode = <span class="tok-kw">if</span> (self.is_release) mode <span class="tok-kw">else</span> std.builtin.Mode.Debug;</span>
<span class="line" id="L681">    }</span>
<span class="line" id="L682"></span>
<span class="line" id="L683">    <span class="tok-comment">/// If you call this without first calling `setPreferredReleaseMode` then it gives the build user</span></span>
<span class="line" id="L684">    <span class="tok-comment">/// the choice of what kind of release.</span></span>
<span class="line" id="L685">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">standardReleaseOptions</span>(self: *Builder) std.builtin.Mode {</span>
<span class="line" id="L686">        <span class="tok-kw">if</span> (self.release_mode) |mode| <span class="tok-kw">return</span> mode;</span>
<span class="line" id="L687"></span>
<span class="line" id="L688">        <span class="tok-kw">const</span> release_safe = self.option(<span class="tok-type">bool</span>, <span class="tok-str">&quot;release-safe&quot;</span>, <span class="tok-str">&quot;Optimizations on and safety on&quot;</span>) <span class="tok-kw">orelse</span> <span class="tok-null">false</span>;</span>
<span class="line" id="L689">        <span class="tok-kw">const</span> release_fast = self.option(<span class="tok-type">bool</span>, <span class="tok-str">&quot;release-fast&quot;</span>, <span class="tok-str">&quot;Optimizations on and safety off&quot;</span>) <span class="tok-kw">orelse</span> <span class="tok-null">false</span>;</span>
<span class="line" id="L690">        <span class="tok-kw">const</span> release_small = self.option(<span class="tok-type">bool</span>, <span class="tok-str">&quot;release-small&quot;</span>, <span class="tok-str">&quot;Size optimizations on and safety off&quot;</span>) <span class="tok-kw">orelse</span> <span class="tok-null">false</span>;</span>
<span class="line" id="L691"></span>
<span class="line" id="L692">        <span class="tok-kw">const</span> mode = <span class="tok-kw">if</span> (release_safe <span class="tok-kw">and</span> !release_fast <span class="tok-kw">and</span> !release_small)</span>
<span class="line" id="L693">            std.builtin.Mode.ReleaseSafe</span>
<span class="line" id="L694">        <span class="tok-kw">else</span> <span class="tok-kw">if</span> (release_fast <span class="tok-kw">and</span> !release_safe <span class="tok-kw">and</span> !release_small)</span>
<span class="line" id="L695">            std.builtin.Mode.ReleaseFast</span>
<span class="line" id="L696">        <span class="tok-kw">else</span> <span class="tok-kw">if</span> (release_small <span class="tok-kw">and</span> !release_fast <span class="tok-kw">and</span> !release_safe)</span>
<span class="line" id="L697">            std.builtin.Mode.ReleaseSmall</span>
<span class="line" id="L698">        <span class="tok-kw">else</span> <span class="tok-kw">if</span> (!release_fast <span class="tok-kw">and</span> !release_safe <span class="tok-kw">and</span> !release_small)</span>
<span class="line" id="L699">            std.builtin.Mode.Debug</span>
<span class="line" id="L700">        <span class="tok-kw">else</span> x: {</span>
<span class="line" id="L701">            log.err(<span class="tok-str">&quot;Multiple release modes (of -Drelease-safe, -Drelease-fast and -Drelease-small)\n&quot;</span>, .{});</span>
<span class="line" id="L702">            self.markInvalidUserInput();</span>
<span class="line" id="L703">            <span class="tok-kw">break</span> :x std.builtin.Mode.Debug;</span>
<span class="line" id="L704">        };</span>
<span class="line" id="L705">        self.is_release = mode != .Debug;</span>
<span class="line" id="L706">        self.release_mode = mode;</span>
<span class="line" id="L707">        <span class="tok-kw">return</span> mode;</span>
<span class="line" id="L708">    }</span>
<span class="line" id="L709"></span>
<span class="line" id="L710">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> StandardTargetOptionsArgs = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L711">        whitelist: ?[]<span class="tok-kw">const</span> CrossTarget = <span class="tok-null">null</span>,</span>
<span class="line" id="L712"></span>
<span class="line" id="L713">        default_target: CrossTarget = CrossTarget{},</span>
<span class="line" id="L714">    };</span>
<span class="line" id="L715"></span>
<span class="line" id="L716">    <span class="tok-comment">/// Exposes standard `zig build` options for choosing a target.</span></span>
<span class="line" id="L717">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">standardTargetOptions</span>(self: *Builder, args: StandardTargetOptionsArgs) CrossTarget {</span>
<span class="line" id="L718">        <span class="tok-kw">const</span> maybe_triple = self.option(</span>
<span class="line" id="L719">            []<span class="tok-kw">const</span> <span class="tok-type">u8</span>,</span>
<span class="line" id="L720">            <span class="tok-str">&quot;target&quot;</span>,</span>
<span class="line" id="L721">            <span class="tok-str">&quot;The CPU architecture, OS, and ABI to build for&quot;</span>,</span>
<span class="line" id="L722">        );</span>
<span class="line" id="L723">        <span class="tok-kw">const</span> mcpu = self.option([]<span class="tok-kw">const</span> <span class="tok-type">u8</span>, <span class="tok-str">&quot;cpu&quot;</span>, <span class="tok-str">&quot;Target CPU features to add or subtract&quot;</span>);</span>
<span class="line" id="L724"></span>
<span class="line" id="L725">        <span class="tok-kw">if</span> (maybe_triple == <span class="tok-null">null</span> <span class="tok-kw">and</span> mcpu == <span class="tok-null">null</span>) {</span>
<span class="line" id="L726">            <span class="tok-kw">return</span> args.default_target;</span>
<span class="line" id="L727">        }</span>
<span class="line" id="L728"></span>
<span class="line" id="L729">        <span class="tok-kw">const</span> triple = maybe_triple <span class="tok-kw">orelse</span> <span class="tok-str">&quot;native&quot;</span>;</span>
<span class="line" id="L730"></span>
<span class="line" id="L731">        <span class="tok-kw">var</span> diags: CrossTarget.ParseOptions.Diagnostics = .{};</span>
<span class="line" id="L732">        <span class="tok-kw">const</span> selected_target = CrossTarget.parse(.{</span>
<span class="line" id="L733">            .arch_os_abi = triple,</span>
<span class="line" id="L734">            .cpu_features = mcpu,</span>
<span class="line" id="L735">            .diagnostics = &amp;diags,</span>
<span class="line" id="L736">        }) <span class="tok-kw">catch</span> |err| <span class="tok-kw">switch</span> (err) {</span>
<span class="line" id="L737">            <span class="tok-kw">error</span>.UnknownCpuModel =&gt; {</span>
<span class="line" id="L738">                log.err(<span class="tok-str">&quot;Unknown CPU: '{s}'\nAvailable CPUs for architecture '{s}':&quot;</span>, .{</span>
<span class="line" id="L739">                    diags.cpu_name.?,</span>
<span class="line" id="L740">                    <span class="tok-builtin">@tagName</span>(diags.arch.?),</span>
<span class="line" id="L741">                });</span>
<span class="line" id="L742">                <span class="tok-kw">for</span> (diags.arch.?.allCpuModels()) |cpu| {</span>
<span class="line" id="L743">                    log.err(<span class="tok-str">&quot; {s}&quot;</span>, .{cpu.name});</span>
<span class="line" id="L744">                }</span>
<span class="line" id="L745">                self.markInvalidUserInput();</span>
<span class="line" id="L746">                <span class="tok-kw">return</span> args.default_target;</span>
<span class="line" id="L747">            },</span>
<span class="line" id="L748">            <span class="tok-kw">error</span>.UnknownCpuFeature =&gt; {</span>
<span class="line" id="L749">                log.err(</span>
<span class="line" id="L750">                    <span class="tok-str">\\Unknown CPU feature: '{s}'</span></span>

<span class="line" id="L751">                    <span class="tok-str">\\Available CPU features for architecture '{s}':</span></span>

<span class="line" id="L752">                    <span class="tok-str">\\</span></span>

<span class="line" id="L753">                , .{</span>
<span class="line" id="L754">                    diags.unknown_feature_name.?,</span>
<span class="line" id="L755">                    <span class="tok-builtin">@tagName</span>(diags.arch.?),</span>
<span class="line" id="L756">                });</span>
<span class="line" id="L757">                <span class="tok-kw">for</span> (diags.arch.?.allFeaturesList()) |feature| {</span>
<span class="line" id="L758">                    log.err(<span class="tok-str">&quot; {s}: {s}&quot;</span>, .{ feature.name, feature.description });</span>
<span class="line" id="L759">                }</span>
<span class="line" id="L760">                self.markInvalidUserInput();</span>
<span class="line" id="L761">                <span class="tok-kw">return</span> args.default_target;</span>
<span class="line" id="L762">            },</span>
<span class="line" id="L763">            <span class="tok-kw">error</span>.UnknownOperatingSystem =&gt; {</span>
<span class="line" id="L764">                log.err(</span>
<span class="line" id="L765">                    <span class="tok-str">\\Unknown OS: '{s}'</span></span>

<span class="line" id="L766">                    <span class="tok-str">\\Available operating systems:</span></span>

<span class="line" id="L767">                    <span class="tok-str">\\</span></span>

<span class="line" id="L768">                , .{diags.os_name.?});</span>
<span class="line" id="L769">                <span class="tok-kw">inline</span> <span class="tok-kw">for</span> (std.meta.fields(std.Target.Os.Tag)) |field| {</span>
<span class="line" id="L770">                    log.err(<span class="tok-str">&quot; {s}&quot;</span>, .{field.name});</span>
<span class="line" id="L771">                }</span>
<span class="line" id="L772">                self.markInvalidUserInput();</span>
<span class="line" id="L773">                <span class="tok-kw">return</span> args.default_target;</span>
<span class="line" id="L774">            },</span>
<span class="line" id="L775">            <span class="tok-kw">else</span> =&gt; |e| {</span>
<span class="line" id="L776">                log.err(<span class="tok-str">&quot;Unable to parse target '{s}': {s}\n&quot;</span>, .{ triple, <span class="tok-builtin">@errorName</span>(e) });</span>
<span class="line" id="L777">                self.markInvalidUserInput();</span>
<span class="line" id="L778">                <span class="tok-kw">return</span> args.default_target;</span>
<span class="line" id="L779">            },</span>
<span class="line" id="L780">        };</span>
<span class="line" id="L781"></span>
<span class="line" id="L782">        <span class="tok-kw">const</span> selected_canonicalized_triple = selected_target.zigTriple(self.allocator) <span class="tok-kw">catch</span> <span class="tok-kw">unreachable</span>;</span>
<span class="line" id="L783"></span>
<span class="line" id="L784">        <span class="tok-kw">if</span> (args.whitelist) |list| whitelist_check: {</span>
<span class="line" id="L785">            <span class="tok-comment">// Make sure it's a match of one of the list.</span>
</span>
<span class="line" id="L786">            <span class="tok-kw">var</span> mismatch_triple = <span class="tok-null">true</span>;</span>
<span class="line" id="L787">            <span class="tok-kw">var</span> mismatch_cpu_features = <span class="tok-null">true</span>;</span>
<span class="line" id="L788">            <span class="tok-kw">var</span> whitelist_item = CrossTarget{};</span>
<span class="line" id="L789">            <span class="tok-kw">for</span> (list) |t| {</span>
<span class="line" id="L790">                mismatch_cpu_features = <span class="tok-null">true</span>;</span>
<span class="line" id="L791">                mismatch_triple = <span class="tok-null">true</span>;</span>
<span class="line" id="L792"></span>
<span class="line" id="L793">                <span class="tok-kw">const</span> t_triple = t.zigTriple(self.allocator) <span class="tok-kw">catch</span> <span class="tok-kw">unreachable</span>;</span>
<span class="line" id="L794">                <span class="tok-kw">if</span> (mem.eql(<span class="tok-type">u8</span>, t_triple, selected_canonicalized_triple)) {</span>
<span class="line" id="L795">                    mismatch_triple = <span class="tok-null">false</span>;</span>
<span class="line" id="L796">                    whitelist_item = t;</span>
<span class="line" id="L797">                    <span class="tok-kw">if</span> (t.getCpuFeatures().isSuperSetOf(selected_target.getCpuFeatures())) {</span>
<span class="line" id="L798">                        mismatch_cpu_features = <span class="tok-null">false</span>;</span>
<span class="line" id="L799">                        <span class="tok-kw">break</span> :whitelist_check;</span>
<span class="line" id="L800">                    } <span class="tok-kw">else</span> {</span>
<span class="line" id="L801">                        <span class="tok-kw">break</span>;</span>
<span class="line" id="L802">                    }</span>
<span class="line" id="L803">                }</span>
<span class="line" id="L804">            }</span>
<span class="line" id="L805">            <span class="tok-kw">if</span> (mismatch_triple) {</span>
<span class="line" id="L806">                log.err(<span class="tok-str">&quot;Chosen target '{s}' does not match one of the supported targets:&quot;</span>, .{</span>
<span class="line" id="L807">                    selected_canonicalized_triple,</span>
<span class="line" id="L808">                });</span>
<span class="line" id="L809">                <span class="tok-kw">for</span> (list) |t| {</span>
<span class="line" id="L810">                    <span class="tok-kw">const</span> t_triple = t.zigTriple(self.allocator) <span class="tok-kw">catch</span> <span class="tok-kw">unreachable</span>;</span>
<span class="line" id="L811">                    log.err(<span class="tok-str">&quot; {s}&quot;</span>, .{t_triple});</span>
<span class="line" id="L812">                }</span>
<span class="line" id="L813">            } <span class="tok-kw">else</span> {</span>
<span class="line" id="L814">                assert(mismatch_cpu_features);</span>
<span class="line" id="L815">                <span class="tok-kw">const</span> whitelist_cpu = whitelist_item.getCpu();</span>
<span class="line" id="L816">                <span class="tok-kw">const</span> selected_cpu = selected_target.getCpu();</span>
<span class="line" id="L817">                log.err(<span class="tok-str">&quot;Chosen CPU model '{s}' does not match one of the supported targets:&quot;</span>, .{</span>
<span class="line" id="L818">                    selected_cpu.model.name,</span>
<span class="line" id="L819">                });</span>
<span class="line" id="L820">                log.err(<span class="tok-str">&quot;  Supported feature Set: &quot;</span>, .{});</span>
<span class="line" id="L821">                <span class="tok-kw">const</span> all_features = whitelist_cpu.arch.allFeaturesList();</span>
<span class="line" id="L822">                <span class="tok-kw">var</span> populated_cpu_features = whitelist_cpu.model.features;</span>
<span class="line" id="L823">                populated_cpu_features.populateDependencies(all_features);</span>
<span class="line" id="L824">                <span class="tok-kw">for</span> (all_features) |feature, i_usize| {</span>
<span class="line" id="L825">                    <span class="tok-kw">const</span> i = <span class="tok-builtin">@intCast</span>(std.Target.Cpu.Feature.Set.Index, i_usize);</span>
<span class="line" id="L826">                    <span class="tok-kw">const</span> in_cpu_set = populated_cpu_features.isEnabled(i);</span>
<span class="line" id="L827">                    <span class="tok-kw">if</span> (in_cpu_set) {</span>
<span class="line" id="L828">                        log.err(<span class="tok-str">&quot;{s} &quot;</span>, .{feature.name});</span>
<span class="line" id="L829">                    }</span>
<span class="line" id="L830">                }</span>
<span class="line" id="L831">                log.err(<span class="tok-str">&quot;  Remove: &quot;</span>, .{});</span>
<span class="line" id="L832">                <span class="tok-kw">for</span> (all_features) |feature, i_usize| {</span>
<span class="line" id="L833">                    <span class="tok-kw">const</span> i = <span class="tok-builtin">@intCast</span>(std.Target.Cpu.Feature.Set.Index, i_usize);</span>
<span class="line" id="L834">                    <span class="tok-kw">const</span> in_cpu_set = populated_cpu_features.isEnabled(i);</span>
<span class="line" id="L835">                    <span class="tok-kw">const</span> in_actual_set = selected_cpu.features.isEnabled(i);</span>
<span class="line" id="L836">                    <span class="tok-kw">if</span> (in_actual_set <span class="tok-kw">and</span> !in_cpu_set) {</span>
<span class="line" id="L837">                        log.err(<span class="tok-str">&quot;{s} &quot;</span>, .{feature.name});</span>
<span class="line" id="L838">                    }</span>
<span class="line" id="L839">                }</span>
<span class="line" id="L840">            }</span>
<span class="line" id="L841">            self.markInvalidUserInput();</span>
<span class="line" id="L842">            <span class="tok-kw">return</span> args.default_target;</span>
<span class="line" id="L843">        }</span>
<span class="line" id="L844"></span>
<span class="line" id="L845">        <span class="tok-kw">return</span> selected_target;</span>
<span class="line" id="L846">    }</span>
<span class="line" id="L847"></span>
<span class="line" id="L848">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">addUserInputOption</span>(self: *Builder, name_raw: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>, value_raw: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) !<span class="tok-type">bool</span> {</span>
<span class="line" id="L849">        <span class="tok-kw">const</span> name = self.dupe(name_raw);</span>
<span class="line" id="L850">        <span class="tok-kw">const</span> value = self.dupe(value_raw);</span>
<span class="line" id="L851">        <span class="tok-kw">const</span> gop = <span class="tok-kw">try</span> self.user_input_options.getOrPut(name);</span>
<span class="line" id="L852">        <span class="tok-kw">if</span> (!gop.found_existing) {</span>
<span class="line" id="L853">            gop.value_ptr.* = UserInputOption{</span>
<span class="line" id="L854">                .name = name,</span>
<span class="line" id="L855">                .value = .{ .scalar = value },</span>
<span class="line" id="L856">                .used = <span class="tok-null">false</span>,</span>
<span class="line" id="L857">            };</span>
<span class="line" id="L858">            <span class="tok-kw">return</span> <span class="tok-null">false</span>;</span>
<span class="line" id="L859">        }</span>
<span class="line" id="L860"></span>
<span class="line" id="L861">        <span class="tok-comment">// option already exists</span>
</span>
<span class="line" id="L862">        <span class="tok-kw">switch</span> (gop.value_ptr.value) {</span>
<span class="line" id="L863">            .scalar =&gt; |s| {</span>
<span class="line" id="L864">                <span class="tok-comment">// turn it into a list</span>
</span>
<span class="line" id="L865">                <span class="tok-kw">var</span> list = ArrayList([]<span class="tok-kw">const</span> <span class="tok-type">u8</span>).init(self.allocator);</span>
<span class="line" id="L866">                list.append(s) <span class="tok-kw">catch</span> <span class="tok-kw">unreachable</span>;</span>
<span class="line" id="L867">                list.append(value) <span class="tok-kw">catch</span> <span class="tok-kw">unreachable</span>;</span>
<span class="line" id="L868">                self.user_input_options.put(name, .{</span>
<span class="line" id="L869">                    .name = name,</span>
<span class="line" id="L870">                    .value = .{ .list = list },</span>
<span class="line" id="L871">                    .used = <span class="tok-null">false</span>,</span>
<span class="line" id="L872">                }) <span class="tok-kw">catch</span> <span class="tok-kw">unreachable</span>;</span>
<span class="line" id="L873">            },</span>
<span class="line" id="L874">            .list =&gt; |*list| {</span>
<span class="line" id="L875">                <span class="tok-comment">// append to the list</span>
</span>
<span class="line" id="L876">                list.append(value) <span class="tok-kw">catch</span> <span class="tok-kw">unreachable</span>;</span>
<span class="line" id="L877">                self.user_input_options.put(name, .{</span>
<span class="line" id="L878">                    .name = name,</span>
<span class="line" id="L879">                    .value = .{ .list = list.* },</span>
<span class="line" id="L880">                    .used = <span class="tok-null">false</span>,</span>
<span class="line" id="L881">                }) <span class="tok-kw">catch</span> <span class="tok-kw">unreachable</span>;</span>
<span class="line" id="L882">            },</span>
<span class="line" id="L883">            .flag =&gt; {</span>
<span class="line" id="L884">                log.warn(<span class="tok-str">&quot;Option '-D{s}={s}' conflicts with flag '-D{s}'.&quot;</span>, .{ name, value, name });</span>
<span class="line" id="L885">                <span class="tok-kw">return</span> <span class="tok-null">true</span>;</span>
<span class="line" id="L886">            },</span>
<span class="line" id="L887">        }</span>
<span class="line" id="L888">        <span class="tok-kw">return</span> <span class="tok-null">false</span>;</span>
<span class="line" id="L889">    }</span>
<span class="line" id="L890"></span>
<span class="line" id="L891">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">addUserInputFlag</span>(self: *Builder, name_raw: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) !<span class="tok-type">bool</span> {</span>
<span class="line" id="L892">        <span class="tok-kw">const</span> name = self.dupe(name_raw);</span>
<span class="line" id="L893">        <span class="tok-kw">const</span> gop = <span class="tok-kw">try</span> self.user_input_options.getOrPut(name);</span>
<span class="line" id="L894">        <span class="tok-kw">if</span> (!gop.found_existing) {</span>
<span class="line" id="L895">            gop.value_ptr.* = .{</span>
<span class="line" id="L896">                .name = name,</span>
<span class="line" id="L897">                .value = .{ .flag = {} },</span>
<span class="line" id="L898">                .used = <span class="tok-null">false</span>,</span>
<span class="line" id="L899">            };</span>
<span class="line" id="L900">            <span class="tok-kw">return</span> <span class="tok-null">false</span>;</span>
<span class="line" id="L901">        }</span>
<span class="line" id="L902"></span>
<span class="line" id="L903">        <span class="tok-comment">// option already exists</span>
</span>
<span class="line" id="L904">        <span class="tok-kw">switch</span> (gop.value_ptr.value) {</span>
<span class="line" id="L905">            .scalar =&gt; |s| {</span>
<span class="line" id="L906">                log.err(<span class="tok-str">&quot;Flag '-D{s}' conflicts with option '-D{s}={s}'.&quot;</span>, .{ name, name, s });</span>
<span class="line" id="L907">                <span class="tok-kw">return</span> <span class="tok-null">true</span>;</span>
<span class="line" id="L908">            },</span>
<span class="line" id="L909">            .list =&gt; {</span>
<span class="line" id="L910">                log.err(<span class="tok-str">&quot;Flag '-D{s}' conflicts with multiple options of the same name.&quot;</span>, .{name});</span>
<span class="line" id="L911">                <span class="tok-kw">return</span> <span class="tok-null">true</span>;</span>
<span class="line" id="L912">            },</span>
<span class="line" id="L913">            .flag =&gt; {},</span>
<span class="line" id="L914">        }</span>
<span class="line" id="L915">        <span class="tok-kw">return</span> <span class="tok-null">false</span>;</span>
<span class="line" id="L916">    }</span>
<span class="line" id="L917"></span>
<span class="line" id="L918">    <span class="tok-kw">fn</span> <span class="tok-fn">typeToEnum</span>(<span class="tok-kw">comptime</span> T: <span class="tok-type">type</span>) TypeId {</span>
<span class="line" id="L919">        <span class="tok-kw">return</span> <span class="tok-kw">switch</span> (<span class="tok-builtin">@typeInfo</span>(T)) {</span>
<span class="line" id="L920">            .Int =&gt; .int,</span>
<span class="line" id="L921">            .Float =&gt; .float,</span>
<span class="line" id="L922">            .Bool =&gt; .<span class="tok-type">bool</span>,</span>
<span class="line" id="L923">            .Enum =&gt; .@&quot;enum&quot;,</span>
<span class="line" id="L924">            <span class="tok-kw">else</span> =&gt; <span class="tok-kw">switch</span> (T) {</span>
<span class="line" id="L925">                []<span class="tok-kw">const</span> <span class="tok-type">u8</span> =&gt; .string,</span>
<span class="line" id="L926">                []<span class="tok-kw">const</span> []<span class="tok-kw">const</span> <span class="tok-type">u8</span> =&gt; .list,</span>
<span class="line" id="L927">                <span class="tok-kw">else</span> =&gt; <span class="tok-builtin">@compileError</span>(<span class="tok-str">&quot;Unsupported type: &quot;</span> ++ <span class="tok-builtin">@typeName</span>(T)),</span>
<span class="line" id="L928">            },</span>
<span class="line" id="L929">        };</span>
<span class="line" id="L930">    }</span>
<span class="line" id="L931"></span>
<span class="line" id="L932">    <span class="tok-kw">fn</span> <span class="tok-fn">markInvalidUserInput</span>(self: *Builder) <span class="tok-type">void</span> {</span>
<span class="line" id="L933">        self.invalid_user_input = <span class="tok-null">true</span>;</span>
<span class="line" id="L934">    }</span>
<span class="line" id="L935"></span>
<span class="line" id="L936">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">validateUserInputDidItFail</span>(self: *Builder) <span class="tok-type">bool</span> {</span>
<span class="line" id="L937">        <span class="tok-comment">// make sure all args are used</span>
</span>
<span class="line" id="L938">        <span class="tok-kw">var</span> it = self.user_input_options.iterator();</span>
<span class="line" id="L939">        <span class="tok-kw">while</span> (it.next()) |entry| {</span>
<span class="line" id="L940">            <span class="tok-kw">if</span> (!entry.value_ptr.used) {</span>
<span class="line" id="L941">                log.err(<span class="tok-str">&quot;Invalid option: -D{s}\n&quot;</span>, .{entry.key_ptr.*});</span>
<span class="line" id="L942">                self.markInvalidUserInput();</span>
<span class="line" id="L943">            }</span>
<span class="line" id="L944">        }</span>
<span class="line" id="L945"></span>
<span class="line" id="L946">        <span class="tok-kw">return</span> self.invalid_user_input;</span>
<span class="line" id="L947">    }</span>
<span class="line" id="L948"></span>
<span class="line" id="L949">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">spawnChild</span>(self: *Builder, argv: []<span class="tok-kw">const</span> []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) !<span class="tok-type">void</span> {</span>
<span class="line" id="L950">        <span class="tok-kw">return</span> self.spawnChildEnvMap(<span class="tok-null">null</span>, self.env_map, argv);</span>
<span class="line" id="L951">    }</span>
<span class="line" id="L952"></span>
<span class="line" id="L953">    <span class="tok-kw">fn</span> <span class="tok-fn">printCmd</span>(cwd: ?[]<span class="tok-kw">const</span> <span class="tok-type">u8</span>, argv: []<span class="tok-kw">const</span> []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) <span class="tok-type">void</span> {</span>
<span class="line" id="L954">        <span class="tok-kw">if</span> (cwd) |yes_cwd| std.debug.print(<span class="tok-str">&quot;cd {s} &amp;&amp; &quot;</span>, .{yes_cwd});</span>
<span class="line" id="L955">        <span class="tok-kw">for</span> (argv) |arg| {</span>
<span class="line" id="L956">            std.debug.print(<span class="tok-str">&quot;{s} &quot;</span>, .{arg});</span>
<span class="line" id="L957">        }</span>
<span class="line" id="L958">        std.debug.print(<span class="tok-str">&quot;\n&quot;</span>, .{});</span>
<span class="line" id="L959">    }</span>
<span class="line" id="L960"></span>
<span class="line" id="L961">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">spawnChildEnvMap</span>(self: *Builder, cwd: ?[]<span class="tok-kw">const</span> <span class="tok-type">u8</span>, env_map: *<span class="tok-kw">const</span> EnvMap, argv: []<span class="tok-kw">const</span> []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) !<span class="tok-type">void</span> {</span>
<span class="line" id="L962">        <span class="tok-kw">if</span> (self.verbose) {</span>
<span class="line" id="L963">            printCmd(cwd, argv);</span>
<span class="line" id="L964">        }</span>
<span class="line" id="L965"></span>
<span class="line" id="L966">        <span class="tok-kw">if</span> (!std.process.can_spawn)</span>
<span class="line" id="L967">            <span class="tok-kw">return</span> <span class="tok-kw">error</span>.ExecNotSupported;</span>
<span class="line" id="L968"></span>
<span class="line" id="L969">        <span class="tok-kw">var</span> child = std.ChildProcess.init(argv, self.allocator);</span>
<span class="line" id="L970">        child.cwd = cwd;</span>
<span class="line" id="L971">        child.env_map = env_map;</span>
<span class="line" id="L972"></span>
<span class="line" id="L973">        <span class="tok-kw">const</span> term = child.spawnAndWait() <span class="tok-kw">catch</span> |err| {</span>
<span class="line" id="L974">            log.err(<span class="tok-str">&quot;Unable to spawn {s}: {s}&quot;</span>, .{ argv[<span class="tok-number">0</span>], <span class="tok-builtin">@errorName</span>(err) });</span>
<span class="line" id="L975">            <span class="tok-kw">return</span> err;</span>
<span class="line" id="L976">        };</span>
<span class="line" id="L977"></span>
<span class="line" id="L978">        <span class="tok-kw">switch</span> (term) {</span>
<span class="line" id="L979">            .Exited =&gt; |code| {</span>
<span class="line" id="L980">                <span class="tok-kw">if</span> (code != <span class="tok-number">0</span>) {</span>
<span class="line" id="L981">                    log.err(<span class="tok-str">&quot;The following command exited with error code {}:&quot;</span>, .{code});</span>
<span class="line" id="L982">                    printCmd(cwd, argv);</span>
<span class="line" id="L983">                    <span class="tok-kw">return</span> <span class="tok-kw">error</span>.UncleanExit;</span>
<span class="line" id="L984">                }</span>
<span class="line" id="L985">            },</span>
<span class="line" id="L986">            <span class="tok-kw">else</span> =&gt; {</span>
<span class="line" id="L987">                log.err(<span class="tok-str">&quot;The following command terminated unexpectedly:&quot;</span>, .{});</span>
<span class="line" id="L988">                printCmd(cwd, argv);</span>
<span class="line" id="L989"></span>
<span class="line" id="L990">                <span class="tok-kw">return</span> <span class="tok-kw">error</span>.UncleanExit;</span>
<span class="line" id="L991">            },</span>
<span class="line" id="L992">        }</span>
<span class="line" id="L993">    }</span>
<span class="line" id="L994"></span>
<span class="line" id="L995">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">makePath</span>(self: *Builder, path: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) !<span class="tok-type">void</span> {</span>
<span class="line" id="L996">        fs.cwd().makePath(self.pathFromRoot(path)) <span class="tok-kw">catch</span> |err| {</span>
<span class="line" id="L997">            log.err(<span class="tok-str">&quot;Unable to create path {s}: {s}&quot;</span>, .{ path, <span class="tok-builtin">@errorName</span>(err) });</span>
<span class="line" id="L998">            <span class="tok-kw">return</span> err;</span>
<span class="line" id="L999">        };</span>
<span class="line" id="L1000">    }</span>
<span class="line" id="L1001"></span>
<span class="line" id="L1002">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">installArtifact</span>(self: *Builder, artifact: *LibExeObjStep) <span class="tok-type">void</span> {</span>
<span class="line" id="L1003">        self.getInstallStep().dependOn(&amp;self.addInstallArtifact(artifact).step);</span>
<span class="line" id="L1004">    }</span>
<span class="line" id="L1005"></span>
<span class="line" id="L1006">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">addInstallArtifact</span>(self: *Builder, artifact: *LibExeObjStep) *InstallArtifactStep {</span>
<span class="line" id="L1007">        <span class="tok-kw">return</span> InstallArtifactStep.create(self, artifact);</span>
<span class="line" id="L1008">    }</span>
<span class="line" id="L1009"></span>
<span class="line" id="L1010">    <span class="tok-comment">///`dest_rel_path` is relative to prefix path</span></span>
<span class="line" id="L1011">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">installFile</span>(self: *Builder, src_path: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>, dest_rel_path: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) <span class="tok-type">void</span> {</span>
<span class="line" id="L1012">        self.getInstallStep().dependOn(&amp;self.addInstallFileWithDir(.{ .path = src_path }, .prefix, dest_rel_path).step);</span>
<span class="line" id="L1013">    }</span>
<span class="line" id="L1014"></span>
<span class="line" id="L1015">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">installDirectory</span>(self: *Builder, options: InstallDirectoryOptions) <span class="tok-type">void</span> {</span>
<span class="line" id="L1016">        self.getInstallStep().dependOn(&amp;self.addInstallDirectory(options).step);</span>
<span class="line" id="L1017">    }</span>
<span class="line" id="L1018"></span>
<span class="line" id="L1019">    <span class="tok-comment">///`dest_rel_path` is relative to bin path</span></span>
<span class="line" id="L1020">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">installBinFile</span>(self: *Builder, src_path: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>, dest_rel_path: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) <span class="tok-type">void</span> {</span>
<span class="line" id="L1021">        self.getInstallStep().dependOn(&amp;self.addInstallFileWithDir(.{ .path = src_path }, .bin, dest_rel_path).step);</span>
<span class="line" id="L1022">    }</span>
<span class="line" id="L1023"></span>
<span class="line" id="L1024">    <span class="tok-comment">///`dest_rel_path` is relative to lib path</span></span>
<span class="line" id="L1025">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">installLibFile</span>(self: *Builder, src_path: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>, dest_rel_path: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) <span class="tok-type">void</span> {</span>
<span class="line" id="L1026">        self.getInstallStep().dependOn(&amp;self.addInstallFileWithDir(.{ .path = src_path }, .lib, dest_rel_path).step);</span>
<span class="line" id="L1027">    }</span>
<span class="line" id="L1028"></span>
<span class="line" id="L1029">    <span class="tok-comment">/// Output format (BIN vs Intel HEX) determined by filename</span></span>
<span class="line" id="L1030">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">installRaw</span>(self: *Builder, artifact: *LibExeObjStep, dest_filename: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>, options: InstallRawStep.CreateOptions) *InstallRawStep {</span>
<span class="line" id="L1031">        <span class="tok-kw">const</span> raw = self.addInstallRaw(artifact, dest_filename, options);</span>
<span class="line" id="L1032">        self.getInstallStep().dependOn(&amp;raw.step);</span>
<span class="line" id="L1033">        <span class="tok-kw">return</span> raw;</span>
<span class="line" id="L1034">    }</span>
<span class="line" id="L1035"></span>
<span class="line" id="L1036">    <span class="tok-comment">///`dest_rel_path` is relative to install prefix path</span></span>
<span class="line" id="L1037">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">addInstallFile</span>(self: *Builder, source: FileSource, dest_rel_path: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) *InstallFileStep {</span>
<span class="line" id="L1038">        <span class="tok-kw">return</span> self.addInstallFileWithDir(source.dupe(self), .prefix, dest_rel_path);</span>
<span class="line" id="L1039">    }</span>
<span class="line" id="L1040"></span>
<span class="line" id="L1041">    <span class="tok-comment">///`dest_rel_path` is relative to bin path</span></span>
<span class="line" id="L1042">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">addInstallBinFile</span>(self: *Builder, source: FileSource, dest_rel_path: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) *InstallFileStep {</span>
<span class="line" id="L1043">        <span class="tok-kw">return</span> self.addInstallFileWithDir(source.dupe(self), .bin, dest_rel_path);</span>
<span class="line" id="L1044">    }</span>
<span class="line" id="L1045"></span>
<span class="line" id="L1046">    <span class="tok-comment">///`dest_rel_path` is relative to lib path</span></span>
<span class="line" id="L1047">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">addInstallLibFile</span>(self: *Builder, source: FileSource, dest_rel_path: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) *InstallFileStep {</span>
<span class="line" id="L1048">        <span class="tok-kw">return</span> self.addInstallFileWithDir(source.dupe(self), .lib, dest_rel_path);</span>
<span class="line" id="L1049">    }</span>
<span class="line" id="L1050"></span>
<span class="line" id="L1051">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">addInstallRaw</span>(self: *Builder, artifact: *LibExeObjStep, dest_filename: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>, options: InstallRawStep.CreateOptions) *InstallRawStep {</span>
<span class="line" id="L1052">        <span class="tok-kw">return</span> InstallRawStep.create(self, artifact, dest_filename, options);</span>
<span class="line" id="L1053">    }</span>
<span class="line" id="L1054"></span>
<span class="line" id="L1055">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">addInstallFileWithDir</span>(</span>
<span class="line" id="L1056">        self: *Builder,</span>
<span class="line" id="L1057">        source: FileSource,</span>
<span class="line" id="L1058">        install_dir: InstallDir,</span>
<span class="line" id="L1059">        dest_rel_path: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>,</span>
<span class="line" id="L1060">    ) *InstallFileStep {</span>
<span class="line" id="L1061">        <span class="tok-kw">if</span> (dest_rel_path.len == <span class="tok-number">0</span>) {</span>
<span class="line" id="L1062">            panic(<span class="tok-str">&quot;dest_rel_path must be non-empty&quot;</span>, .{});</span>
<span class="line" id="L1063">        }</span>
<span class="line" id="L1064">        <span class="tok-kw">const</span> install_step = self.allocator.create(InstallFileStep) <span class="tok-kw">catch</span> <span class="tok-kw">unreachable</span>;</span>
<span class="line" id="L1065">        install_step.* = InstallFileStep.init(self, source.dupe(self), install_dir, dest_rel_path);</span>
<span class="line" id="L1066">        <span class="tok-kw">return</span> install_step;</span>
<span class="line" id="L1067">    }</span>
<span class="line" id="L1068"></span>
<span class="line" id="L1069">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">addInstallDirectory</span>(self: *Builder, options: InstallDirectoryOptions) *InstallDirStep {</span>
<span class="line" id="L1070">        <span class="tok-kw">const</span> install_step = self.allocator.create(InstallDirStep) <span class="tok-kw">catch</span> <span class="tok-kw">unreachable</span>;</span>
<span class="line" id="L1071">        install_step.* = InstallDirStep.init(self, options);</span>
<span class="line" id="L1072">        <span class="tok-kw">return</span> install_step;</span>
<span class="line" id="L1073">    }</span>
<span class="line" id="L1074"></span>
<span class="line" id="L1075">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">pushInstalledFile</span>(self: *Builder, dir: InstallDir, dest_rel_path: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) <span class="tok-type">void</span> {</span>
<span class="line" id="L1076">        <span class="tok-kw">const</span> file = InstalledFile{</span>
<span class="line" id="L1077">            .dir = dir,</span>
<span class="line" id="L1078">            .path = dest_rel_path,</span>
<span class="line" id="L1079">        };</span>
<span class="line" id="L1080">        self.installed_files.append(file.dupe(self)) <span class="tok-kw">catch</span> <span class="tok-kw">unreachable</span>;</span>
<span class="line" id="L1081">    }</span>
<span class="line" id="L1082"></span>
<span class="line" id="L1083">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">updateFile</span>(self: *Builder, source_path: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>, dest_path: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) !<span class="tok-type">void</span> {</span>
<span class="line" id="L1084">        <span class="tok-kw">if</span> (self.verbose) {</span>
<span class="line" id="L1085">            log.info(<span class="tok-str">&quot;cp {s} {s} &quot;</span>, .{ source_path, dest_path });</span>
<span class="line" id="L1086">        }</span>
<span class="line" id="L1087">        <span class="tok-kw">const</span> cwd = fs.cwd();</span>
<span class="line" id="L1088">        <span class="tok-kw">const</span> prev_status = <span class="tok-kw">try</span> fs.Dir.updateFile(cwd, source_path, cwd, dest_path, .{});</span>
<span class="line" id="L1089">        <span class="tok-kw">if</span> (self.verbose) <span class="tok-kw">switch</span> (prev_status) {</span>
<span class="line" id="L1090">            .stale =&gt; log.info(<span class="tok-str">&quot;# installed&quot;</span>, .{}),</span>
<span class="line" id="L1091">            .fresh =&gt; log.info(<span class="tok-str">&quot;# up-to-date&quot;</span>, .{}),</span>
<span class="line" id="L1092">        };</span>
<span class="line" id="L1093">    }</span>
<span class="line" id="L1094"></span>
<span class="line" id="L1095">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">truncateFile</span>(self: *Builder, dest_path: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) !<span class="tok-type">void</span> {</span>
<span class="line" id="L1096">        <span class="tok-kw">if</span> (self.verbose) {</span>
<span class="line" id="L1097">            log.info(<span class="tok-str">&quot;truncate {s}&quot;</span>, .{dest_path});</span>
<span class="line" id="L1098">        }</span>
<span class="line" id="L1099">        <span class="tok-kw">const</span> cwd = fs.cwd();</span>
<span class="line" id="L1100">        <span class="tok-kw">var</span> src_file = cwd.createFile(dest_path, .{}) <span class="tok-kw">catch</span> |err| <span class="tok-kw">switch</span> (err) {</span>
<span class="line" id="L1101">            <span class="tok-kw">error</span>.FileNotFound =&gt; blk: {</span>
<span class="line" id="L1102">                <span class="tok-kw">if</span> (fs.path.dirname(dest_path)) |dirname| {</span>
<span class="line" id="L1103">                    <span class="tok-kw">try</span> cwd.makePath(dirname);</span>
<span class="line" id="L1104">                }</span>
<span class="line" id="L1105">                <span class="tok-kw">break</span> :blk <span class="tok-kw">try</span> cwd.createFile(dest_path, .{});</span>
<span class="line" id="L1106">            },</span>
<span class="line" id="L1107">            <span class="tok-kw">else</span> =&gt; |e| <span class="tok-kw">return</span> e,</span>
<span class="line" id="L1108">        };</span>
<span class="line" id="L1109">        src_file.close();</span>
<span class="line" id="L1110">    }</span>
<span class="line" id="L1111"></span>
<span class="line" id="L1112">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">pathFromRoot</span>(self: *Builder, rel_path: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) []<span class="tok-type">u8</span> {</span>
<span class="line" id="L1113">        <span class="tok-kw">return</span> fs.path.resolve(self.allocator, &amp;[_][]<span class="tok-kw">const</span> <span class="tok-type">u8</span>{ self.build_root, rel_path }) <span class="tok-kw">catch</span> <span class="tok-kw">unreachable</span>;</span>
<span class="line" id="L1114">    }</span>
<span class="line" id="L1115"></span>
<span class="line" id="L1116">    <span class="tok-comment">/// Shorthand for `std.fs.path.join(builder.allocator, paths) catch unreachable`</span></span>
<span class="line" id="L1117">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">pathJoin</span>(self: *Builder, paths: []<span class="tok-kw">const</span> []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) []<span class="tok-type">u8</span> {</span>
<span class="line" id="L1118">        <span class="tok-kw">return</span> fs.path.join(self.allocator, paths) <span class="tok-kw">catch</span> <span class="tok-kw">unreachable</span>;</span>
<span class="line" id="L1119">    }</span>
<span class="line" id="L1120"></span>
<span class="line" id="L1121">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">fmt</span>(self: *Builder, <span class="tok-kw">comptime</span> format: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>, args: <span class="tok-kw">anytype</span>) []<span class="tok-type">u8</span> {</span>
<span class="line" id="L1122">        <span class="tok-kw">return</span> fmt_lib.allocPrint(self.allocator, format, args) <span class="tok-kw">catch</span> <span class="tok-kw">unreachable</span>;</span>
<span class="line" id="L1123">    }</span>
<span class="line" id="L1124"></span>
<span class="line" id="L1125">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">findProgram</span>(self: *Builder, names: []<span class="tok-kw">const</span> []<span class="tok-kw">const</span> <span class="tok-type">u8</span>, paths: []<span class="tok-kw">const</span> []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) ![]<span class="tok-kw">const</span> <span class="tok-type">u8</span> {</span>
<span class="line" id="L1126">        <span class="tok-comment">// TODO report error for ambiguous situations</span>
</span>
<span class="line" id="L1127">        <span class="tok-kw">const</span> exe_extension = <span class="tok-builtin">@as</span>(CrossTarget, .{}).exeFileExt();</span>
<span class="line" id="L1128">        <span class="tok-kw">for</span> (self.search_prefixes.items) |search_prefix| {</span>
<span class="line" id="L1129">            <span class="tok-kw">for</span> (names) |name| {</span>
<span class="line" id="L1130">                <span class="tok-kw">if</span> (fs.path.isAbsolute(name)) {</span>
<span class="line" id="L1131">                    <span class="tok-kw">return</span> name;</span>
<span class="line" id="L1132">                }</span>
<span class="line" id="L1133">                <span class="tok-kw">const</span> full_path = self.pathJoin(&amp;.{</span>
<span class="line" id="L1134">                    search_prefix,</span>
<span class="line" id="L1135">                    <span class="tok-str">&quot;bin&quot;</span>,</span>
<span class="line" id="L1136">                    self.fmt(<span class="tok-str">&quot;{s}{s}&quot;</span>, .{ name, exe_extension }),</span>
<span class="line" id="L1137">                });</span>
<span class="line" id="L1138">                <span class="tok-kw">return</span> fs.realpathAlloc(self.allocator, full_path) <span class="tok-kw">catch</span> <span class="tok-kw">continue</span>;</span>
<span class="line" id="L1139">            }</span>
<span class="line" id="L1140">        }</span>
<span class="line" id="L1141">        <span class="tok-kw">if</span> (self.env_map.get(<span class="tok-str">&quot;PATH&quot;</span>)) |PATH| {</span>
<span class="line" id="L1142">            <span class="tok-kw">for</span> (names) |name| {</span>
<span class="line" id="L1143">                <span class="tok-kw">if</span> (fs.path.isAbsolute(name)) {</span>
<span class="line" id="L1144">                    <span class="tok-kw">return</span> name;</span>
<span class="line" id="L1145">                }</span>
<span class="line" id="L1146">                <span class="tok-kw">var</span> it = mem.tokenize(<span class="tok-type">u8</span>, PATH, &amp;[_]<span class="tok-type">u8</span>{fs.path.delimiter});</span>
<span class="line" id="L1147">                <span class="tok-kw">while</span> (it.next()) |path| {</span>
<span class="line" id="L1148">                    <span class="tok-kw">const</span> full_path = self.pathJoin(&amp;.{</span>
<span class="line" id="L1149">                        path,</span>
<span class="line" id="L1150">                        self.fmt(<span class="tok-str">&quot;{s}{s}&quot;</span>, .{ name, exe_extension }),</span>
<span class="line" id="L1151">                    });</span>
<span class="line" id="L1152">                    <span class="tok-kw">return</span> fs.realpathAlloc(self.allocator, full_path) <span class="tok-kw">catch</span> <span class="tok-kw">continue</span>;</span>
<span class="line" id="L1153">                }</span>
<span class="line" id="L1154">            }</span>
<span class="line" id="L1155">        }</span>
<span class="line" id="L1156">        <span class="tok-kw">for</span> (names) |name| {</span>
<span class="line" id="L1157">            <span class="tok-kw">if</span> (fs.path.isAbsolute(name)) {</span>
<span class="line" id="L1158">                <span class="tok-kw">return</span> name;</span>
<span class="line" id="L1159">            }</span>
<span class="line" id="L1160">            <span class="tok-kw">for</span> (paths) |path| {</span>
<span class="line" id="L1161">                <span class="tok-kw">const</span> full_path = self.pathJoin(&amp;.{</span>
<span class="line" id="L1162">                    path,</span>
<span class="line" id="L1163">                    self.fmt(<span class="tok-str">&quot;{s}{s}&quot;</span>, .{ name, exe_extension }),</span>
<span class="line" id="L1164">                });</span>
<span class="line" id="L1165">                <span class="tok-kw">return</span> fs.realpathAlloc(self.allocator, full_path) <span class="tok-kw">catch</span> <span class="tok-kw">continue</span>;</span>
<span class="line" id="L1166">            }</span>
<span class="line" id="L1167">        }</span>
<span class="line" id="L1168">        <span class="tok-kw">return</span> <span class="tok-kw">error</span>.FileNotFound;</span>
<span class="line" id="L1169">    }</span>
<span class="line" id="L1170"></span>
<span class="line" id="L1171">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">execAllowFail</span>(</span>
<span class="line" id="L1172">        self: *Builder,</span>
<span class="line" id="L1173">        argv: []<span class="tok-kw">const</span> []<span class="tok-kw">const</span> <span class="tok-type">u8</span>,</span>
<span class="line" id="L1174">        out_code: *<span class="tok-type">u8</span>,</span>
<span class="line" id="L1175">        stderr_behavior: std.ChildProcess.StdIo,</span>
<span class="line" id="L1176">    ) ExecError![]<span class="tok-type">u8</span> {</span>
<span class="line" id="L1177">        assert(argv.len != <span class="tok-number">0</span>);</span>
<span class="line" id="L1178"></span>
<span class="line" id="L1179">        <span class="tok-kw">if</span> (!std.process.can_spawn)</span>
<span class="line" id="L1180">            <span class="tok-kw">return</span> <span class="tok-kw">error</span>.ExecNotSupported;</span>
<span class="line" id="L1181"></span>
<span class="line" id="L1182">        <span class="tok-kw">const</span> max_output_size = <span class="tok-number">400</span> * <span class="tok-number">1024</span>;</span>
<span class="line" id="L1183">        <span class="tok-kw">var</span> child = std.ChildProcess.init(argv, self.allocator);</span>
<span class="line" id="L1184">        child.stdin_behavior = .Ignore;</span>
<span class="line" id="L1185">        child.stdout_behavior = .Pipe;</span>
<span class="line" id="L1186">        child.stderr_behavior = stderr_behavior;</span>
<span class="line" id="L1187">        child.env_map = self.env_map;</span>
<span class="line" id="L1188"></span>
<span class="line" id="L1189">        <span class="tok-kw">try</span> child.spawn();</span>
<span class="line" id="L1190"></span>
<span class="line" id="L1191">        <span class="tok-kw">const</span> stdout = child.stdout.?.reader().readAllAlloc(self.allocator, max_output_size) <span class="tok-kw">catch</span> {</span>
<span class="line" id="L1192">            <span class="tok-kw">return</span> <span class="tok-kw">error</span>.ReadFailure;</span>
<span class="line" id="L1193">        };</span>
<span class="line" id="L1194">        <span class="tok-kw">errdefer</span> self.allocator.free(stdout);</span>
<span class="line" id="L1195"></span>
<span class="line" id="L1196">        <span class="tok-kw">const</span> term = <span class="tok-kw">try</span> child.wait();</span>
<span class="line" id="L1197">        <span class="tok-kw">switch</span> (term) {</span>
<span class="line" id="L1198">            .Exited =&gt; |code| {</span>
<span class="line" id="L1199">                <span class="tok-kw">if</span> (code != <span class="tok-number">0</span>) {</span>
<span class="line" id="L1200">                    out_code.* = <span class="tok-builtin">@truncate</span>(<span class="tok-type">u8</span>, code);</span>
<span class="line" id="L1201">                    <span class="tok-kw">return</span> <span class="tok-kw">error</span>.ExitCodeFailure;</span>
<span class="line" id="L1202">                }</span>
<span class="line" id="L1203">                <span class="tok-kw">return</span> stdout;</span>
<span class="line" id="L1204">            },</span>
<span class="line" id="L1205">            .Signal, .Stopped, .Unknown =&gt; |code| {</span>
<span class="line" id="L1206">                out_code.* = <span class="tok-builtin">@truncate</span>(<span class="tok-type">u8</span>, code);</span>
<span class="line" id="L1207">                <span class="tok-kw">return</span> <span class="tok-kw">error</span>.ProcessTerminated;</span>
<span class="line" id="L1208">            },</span>
<span class="line" id="L1209">        }</span>
<span class="line" id="L1210">    }</span>
<span class="line" id="L1211"></span>
<span class="line" id="L1212">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">execFromStep</span>(self: *Builder, argv: []<span class="tok-kw">const</span> []<span class="tok-kw">const</span> <span class="tok-type">u8</span>, src_step: ?*Step) ![]<span class="tok-type">u8</span> {</span>
<span class="line" id="L1213">        assert(argv.len != <span class="tok-number">0</span>);</span>
<span class="line" id="L1214"></span>
<span class="line" id="L1215">        <span class="tok-kw">if</span> (self.verbose) {</span>
<span class="line" id="L1216">            printCmd(<span class="tok-null">null</span>, argv);</span>
<span class="line" id="L1217">        }</span>
<span class="line" id="L1218"></span>
<span class="line" id="L1219">        <span class="tok-kw">if</span> (!std.process.can_spawn) {</span>
<span class="line" id="L1220">            <span class="tok-kw">if</span> (src_step) |s| log.err(<span class="tok-str">&quot;{s}...&quot;</span>, .{s.name});</span>
<span class="line" id="L1221">            log.err(<span class="tok-str">&quot;Unable to spawn the following command: cannot spawn child process&quot;</span>, .{});</span>
<span class="line" id="L1222">            printCmd(<span class="tok-null">null</span>, argv);</span>
<span class="line" id="L1223">            std.os.abort();</span>
<span class="line" id="L1224">        }</span>
<span class="line" id="L1225"></span>
<span class="line" id="L1226">        <span class="tok-kw">var</span> code: <span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L1227">        <span class="tok-kw">return</span> self.execAllowFail(argv, &amp;code, .Inherit) <span class="tok-kw">catch</span> |err| <span class="tok-kw">switch</span> (err) {</span>
<span class="line" id="L1228">            <span class="tok-kw">error</span>.ExecNotSupported =&gt; {</span>
<span class="line" id="L1229">                <span class="tok-kw">if</span> (src_step) |s| log.err(<span class="tok-str">&quot;{s}...&quot;</span>, .{s.name});</span>
<span class="line" id="L1230">                log.err(<span class="tok-str">&quot;Unable to spawn the following command: cannot spawn child process&quot;</span>, .{});</span>
<span class="line" id="L1231">                printCmd(<span class="tok-null">null</span>, argv);</span>
<span class="line" id="L1232">                std.os.abort();</span>
<span class="line" id="L1233">            },</span>
<span class="line" id="L1234">            <span class="tok-kw">error</span>.FileNotFound =&gt; {</span>
<span class="line" id="L1235">                <span class="tok-kw">if</span> (src_step) |s| log.err(<span class="tok-str">&quot;{s}...&quot;</span>, .{s.name});</span>
<span class="line" id="L1236">                log.err(<span class="tok-str">&quot;Unable to spawn the following command: file not found&quot;</span>, .{});</span>
<span class="line" id="L1237">                printCmd(<span class="tok-null">null</span>, argv);</span>
<span class="line" id="L1238">                std.os.exit(<span class="tok-builtin">@truncate</span>(<span class="tok-type">u8</span>, code));</span>
<span class="line" id="L1239">            },</span>
<span class="line" id="L1240">            <span class="tok-kw">error</span>.ExitCodeFailure =&gt; {</span>
<span class="line" id="L1241">                <span class="tok-kw">if</span> (src_step) |s| log.err(<span class="tok-str">&quot;{s}...&quot;</span>, .{s.name});</span>
<span class="line" id="L1242">                <span class="tok-kw">if</span> (self.prominent_compile_errors) {</span>
<span class="line" id="L1243">                    log.err(<span class="tok-str">&quot;The step exited with error code {d}&quot;</span>, .{code});</span>
<span class="line" id="L1244">                } <span class="tok-kw">else</span> {</span>
<span class="line" id="L1245">                    log.err(<span class="tok-str">&quot;The following command exited with error code {d}:&quot;</span>, .{code});</span>
<span class="line" id="L1246">                    printCmd(<span class="tok-null">null</span>, argv);</span>
<span class="line" id="L1247">                }</span>
<span class="line" id="L1248"></span>
<span class="line" id="L1249">                std.os.exit(<span class="tok-builtin">@truncate</span>(<span class="tok-type">u8</span>, code));</span>
<span class="line" id="L1250">            },</span>
<span class="line" id="L1251">            <span class="tok-kw">error</span>.ProcessTerminated =&gt; {</span>
<span class="line" id="L1252">                <span class="tok-kw">if</span> (src_step) |s| log.err(<span class="tok-str">&quot;{s}...&quot;</span>, .{s.name});</span>
<span class="line" id="L1253">                log.err(<span class="tok-str">&quot;The following command terminated unexpectedly:&quot;</span>, .{});</span>
<span class="line" id="L1254">                printCmd(<span class="tok-null">null</span>, argv);</span>
<span class="line" id="L1255">                std.os.exit(<span class="tok-builtin">@truncate</span>(<span class="tok-type">u8</span>, code));</span>
<span class="line" id="L1256">            },</span>
<span class="line" id="L1257">            <span class="tok-kw">else</span> =&gt; |e| <span class="tok-kw">return</span> e,</span>
<span class="line" id="L1258">        };</span>
<span class="line" id="L1259">    }</span>
<span class="line" id="L1260"></span>
<span class="line" id="L1261">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">exec</span>(self: *Builder, argv: []<span class="tok-kw">const</span> []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) ![]<span class="tok-type">u8</span> {</span>
<span class="line" id="L1262">        <span class="tok-kw">return</span> self.execFromStep(argv, <span class="tok-null">null</span>);</span>
<span class="line" id="L1263">    }</span>
<span class="line" id="L1264"></span>
<span class="line" id="L1265">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">addSearchPrefix</span>(self: *Builder, search_prefix: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) <span class="tok-type">void</span> {</span>
<span class="line" id="L1266">        self.search_prefixes.append(self.dupePath(search_prefix)) <span class="tok-kw">catch</span> <span class="tok-kw">unreachable</span>;</span>
<span class="line" id="L1267">    }</span>
<span class="line" id="L1268"></span>
<span class="line" id="L1269">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">getInstallPath</span>(self: *Builder, dir: InstallDir, dest_rel_path: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) []<span class="tok-kw">const</span> <span class="tok-type">u8</span> {</span>
<span class="line" id="L1270">        assert(!fs.path.isAbsolute(dest_rel_path)); <span class="tok-comment">// Install paths must be relative to the prefix</span>
</span>
<span class="line" id="L1271">        <span class="tok-kw">const</span> base_dir = <span class="tok-kw">switch</span> (dir) {</span>
<span class="line" id="L1272">            .prefix =&gt; self.install_path,</span>
<span class="line" id="L1273">            .bin =&gt; self.exe_dir,</span>
<span class="line" id="L1274">            .lib =&gt; self.lib_dir,</span>
<span class="line" id="L1275">            .header =&gt; self.h_dir,</span>
<span class="line" id="L1276">            .custom =&gt; |path| self.pathJoin(&amp;.{ self.install_path, path }),</span>
<span class="line" id="L1277">        };</span>
<span class="line" id="L1278">        <span class="tok-kw">return</span> fs.path.resolve(</span>
<span class="line" id="L1279">            self.allocator,</span>
<span class="line" id="L1280">            &amp;[_][]<span class="tok-kw">const</span> <span class="tok-type">u8</span>{ base_dir, dest_rel_path },</span>
<span class="line" id="L1281">        ) <span class="tok-kw">catch</span> <span class="tok-kw">unreachable</span>;</span>
<span class="line" id="L1282">    }</span>
<span class="line" id="L1283"></span>
<span class="line" id="L1284">    <span class="tok-kw">fn</span> <span class="tok-fn">execPkgConfigList</span>(self: *Builder, out_code: *<span class="tok-type">u8</span>) (PkgConfigError || ExecError)![]<span class="tok-kw">const</span> PkgConfigPkg {</span>
<span class="line" id="L1285">        <span class="tok-kw">const</span> stdout = <span class="tok-kw">try</span> self.execAllowFail(&amp;[_][]<span class="tok-kw">const</span> <span class="tok-type">u8</span>{ <span class="tok-str">&quot;pkg-config&quot;</span>, <span class="tok-str">&quot;--list-all&quot;</span> }, out_code, .Ignore);</span>
<span class="line" id="L1286">        <span class="tok-kw">var</span> list = ArrayList(PkgConfigPkg).init(self.allocator);</span>
<span class="line" id="L1287">        <span class="tok-kw">errdefer</span> list.deinit();</span>
<span class="line" id="L1288">        <span class="tok-kw">var</span> line_it = mem.tokenize(<span class="tok-type">u8</span>, stdout, <span class="tok-str">&quot;\r\n&quot;</span>);</span>
<span class="line" id="L1289">        <span class="tok-kw">while</span> (line_it.next()) |line| {</span>
<span class="line" id="L1290">            <span class="tok-kw">if</span> (mem.trim(<span class="tok-type">u8</span>, line, <span class="tok-str">&quot; \t&quot;</span>).len == <span class="tok-number">0</span>) <span class="tok-kw">continue</span>;</span>
<span class="line" id="L1291">            <span class="tok-kw">var</span> tok_it = mem.tokenize(<span class="tok-type">u8</span>, line, <span class="tok-str">&quot; \t&quot;</span>);</span>
<span class="line" id="L1292">            <span class="tok-kw">try</span> list.append(PkgConfigPkg{</span>
<span class="line" id="L1293">                .name = tok_it.next() <span class="tok-kw">orelse</span> <span class="tok-kw">return</span> <span class="tok-kw">error</span>.PkgConfigInvalidOutput,</span>
<span class="line" id="L1294">                .desc = tok_it.rest(),</span>
<span class="line" id="L1295">            });</span>
<span class="line" id="L1296">        }</span>
<span class="line" id="L1297">        <span class="tok-kw">return</span> list.toOwnedSlice();</span>
<span class="line" id="L1298">    }</span>
<span class="line" id="L1299"></span>
<span class="line" id="L1300">    <span class="tok-kw">fn</span> <span class="tok-fn">getPkgConfigList</span>(self: *Builder) ![]<span class="tok-kw">const</span> PkgConfigPkg {</span>
<span class="line" id="L1301">        <span class="tok-kw">if</span> (self.pkg_config_pkg_list) |res| {</span>
<span class="line" id="L1302">            <span class="tok-kw">return</span> res;</span>
<span class="line" id="L1303">        }</span>
<span class="line" id="L1304">        <span class="tok-kw">var</span> code: <span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L1305">        <span class="tok-kw">if</span> (self.execPkgConfigList(&amp;code)) |list| {</span>
<span class="line" id="L1306">            self.pkg_config_pkg_list = list;</span>
<span class="line" id="L1307">            <span class="tok-kw">return</span> list;</span>
<span class="line" id="L1308">        } <span class="tok-kw">else</span> |err| {</span>
<span class="line" id="L1309">            <span class="tok-kw">const</span> result = <span class="tok-kw">switch</span> (err) {</span>
<span class="line" id="L1310">                <span class="tok-kw">error</span>.ProcessTerminated =&gt; <span class="tok-kw">error</span>.PkgConfigCrashed,</span>
<span class="line" id="L1311">                <span class="tok-kw">error</span>.ExecNotSupported =&gt; <span class="tok-kw">error</span>.PkgConfigFailed,</span>
<span class="line" id="L1312">                <span class="tok-kw">error</span>.ExitCodeFailure =&gt; <span class="tok-kw">error</span>.PkgConfigFailed,</span>
<span class="line" id="L1313">                <span class="tok-kw">error</span>.FileNotFound =&gt; <span class="tok-kw">error</span>.PkgConfigNotInstalled,</span>
<span class="line" id="L1314">                <span class="tok-kw">error</span>.InvalidName =&gt; <span class="tok-kw">error</span>.PkgConfigNotInstalled,</span>
<span class="line" id="L1315">                <span class="tok-kw">error</span>.PkgConfigInvalidOutput =&gt; <span class="tok-kw">error</span>.PkgConfigInvalidOutput,</span>
<span class="line" id="L1316">                <span class="tok-kw">error</span>.ChildExecFailed =&gt; <span class="tok-kw">error</span>.PkgConfigFailed,</span>
<span class="line" id="L1317">                <span class="tok-kw">else</span> =&gt; <span class="tok-kw">return</span> err,</span>
<span class="line" id="L1318">            };</span>
<span class="line" id="L1319">            self.pkg_config_pkg_list = result;</span>
<span class="line" id="L1320">            <span class="tok-kw">return</span> result;</span>
<span class="line" id="L1321">        }</span>
<span class="line" id="L1322">    }</span>
<span class="line" id="L1323">};</span>
<span class="line" id="L1324"></span>
<span class="line" id="L1325"><span class="tok-kw">test</span> <span class="tok-str">&quot;builder.findProgram compiles&quot;</span> {</span>
<span class="line" id="L1326">    <span class="tok-kw">if</span> (builtin.os.tag == .wasi) <span class="tok-kw">return</span> <span class="tok-kw">error</span>.SkipZigTest;</span>
<span class="line" id="L1327"></span>
<span class="line" id="L1328">    <span class="tok-kw">var</span> arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);</span>
<span class="line" id="L1329">    <span class="tok-kw">defer</span> arena.deinit();</span>
<span class="line" id="L1330"></span>
<span class="line" id="L1331">    <span class="tok-kw">const</span> builder = <span class="tok-kw">try</span> Builder.create(</span>
<span class="line" id="L1332">        arena.allocator(),</span>
<span class="line" id="L1333">        <span class="tok-str">&quot;zig&quot;</span>,</span>
<span class="line" id="L1334">        <span class="tok-str">&quot;zig-cache&quot;</span>,</span>
<span class="line" id="L1335">        <span class="tok-str">&quot;zig-cache&quot;</span>,</span>
<span class="line" id="L1336">        <span class="tok-str">&quot;zig-cache&quot;</span>,</span>
<span class="line" id="L1337">    );</span>
<span class="line" id="L1338">    <span class="tok-kw">defer</span> builder.destroy();</span>
<span class="line" id="L1339">    _ = builder.findProgram(&amp;[_][]<span class="tok-kw">const</span> <span class="tok-type">u8</span>{}, &amp;[_][]<span class="tok-kw">const</span> <span class="tok-type">u8</span>{}) <span class="tok-kw">catch</span> <span class="tok-null">null</span>;</span>
<span class="line" id="L1340">}</span>
<span class="line" id="L1341"></span>
<span class="line" id="L1342"><span class="tok-comment">/// TODO: propose some kind of `@deprecate` builtin so that we can deprecate</span></span>
<span class="line" id="L1343"><span class="tok-comment">/// this while still having somewhat non-lazy decls. In this file we wanted to do</span></span>
<span class="line" id="L1344"><span class="tok-comment">/// refAllDecls for example which makes it trigger `@compileError` if you try</span></span>
<span class="line" id="L1345"><span class="tok-comment">/// to use that strategy.</span></span>
<span class="line" id="L1346"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> Version = <span class="tok-builtin">@compileError</span>(<span class="tok-str">&quot;deprecated; Use `std.builtin.Version`&quot;</span>);</span>
<span class="line" id="L1347"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> Target = <span class="tok-builtin">@compileError</span>(<span class="tok-str">&quot;deprecated; Use `std.zig.CrossTarget`&quot;</span>);</span>
<span class="line" id="L1348"></span>
<span class="line" id="L1349"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> Pkg = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L1350">    name: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>,</span>
<span class="line" id="L1351">    source: FileSource,</span>
<span class="line" id="L1352">    dependencies: ?[]<span class="tok-kw">const</span> Pkg = <span class="tok-null">null</span>,</span>
<span class="line" id="L1353">};</span>
<span class="line" id="L1354"></span>
<span class="line" id="L1355"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> CSourceFile = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L1356">    source: FileSource,</span>
<span class="line" id="L1357">    args: []<span class="tok-kw">const</span> []<span class="tok-kw">const</span> <span class="tok-type">u8</span>,</span>
<span class="line" id="L1358"></span>
<span class="line" id="L1359">    <span class="tok-kw">fn</span> <span class="tok-fn">dupe</span>(self: CSourceFile, b: *Builder) CSourceFile {</span>
<span class="line" id="L1360">        <span class="tok-kw">return</span> .{</span>
<span class="line" id="L1361">            .source = self.source.dupe(b),</span>
<span class="line" id="L1362">            .args = b.dupeStrings(self.args),</span>
<span class="line" id="L1363">        };</span>
<span class="line" id="L1364">    }</span>
<span class="line" id="L1365">};</span>
<span class="line" id="L1366"></span>
<span class="line" id="L1367"><span class="tok-kw">const</span> CSourceFiles = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L1368">    files: []<span class="tok-kw">const</span> []<span class="tok-kw">const</span> <span class="tok-type">u8</span>,</span>
<span class="line" id="L1369">    flags: []<span class="tok-kw">const</span> []<span class="tok-kw">const</span> <span class="tok-type">u8</span>,</span>
<span class="line" id="L1370">};</span>
<span class="line" id="L1371"></span>
<span class="line" id="L1372"><span class="tok-kw">fn</span> <span class="tok-fn">isLibCLibrary</span>(name: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) <span class="tok-type">bool</span> {</span>
<span class="line" id="L1373">    <span class="tok-kw">const</span> libc_libraries = [_][]<span class="tok-kw">const</span> <span class="tok-type">u8</span>{ <span class="tok-str">&quot;c&quot;</span>, <span class="tok-str">&quot;m&quot;</span>, <span class="tok-str">&quot;dl&quot;</span>, <span class="tok-str">&quot;rt&quot;</span>, <span class="tok-str">&quot;pthread&quot;</span> };</span>
<span class="line" id="L1374">    <span class="tok-kw">for</span> (libc_libraries) |libc_lib_name| {</span>
<span class="line" id="L1375">        <span class="tok-kw">if</span> (mem.eql(<span class="tok-type">u8</span>, name, libc_lib_name))</span>
<span class="line" id="L1376">            <span class="tok-kw">return</span> <span class="tok-null">true</span>;</span>
<span class="line" id="L1377">    }</span>
<span class="line" id="L1378">    <span class="tok-kw">return</span> <span class="tok-null">false</span>;</span>
<span class="line" id="L1379">}</span>
<span class="line" id="L1380"></span>
<span class="line" id="L1381"><span class="tok-kw">fn</span> <span class="tok-fn">isLibCppLibrary</span>(name: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) <span class="tok-type">bool</span> {</span>
<span class="line" id="L1382">    <span class="tok-kw">const</span> libcpp_libraries = [_][]<span class="tok-kw">const</span> <span class="tok-type">u8</span>{ <span class="tok-str">&quot;c++&quot;</span>, <span class="tok-str">&quot;stdc++&quot;</span> };</span>
<span class="line" id="L1383">    <span class="tok-kw">for</span> (libcpp_libraries) |libcpp_lib_name| {</span>
<span class="line" id="L1384">        <span class="tok-kw">if</span> (mem.eql(<span class="tok-type">u8</span>, name, libcpp_lib_name))</span>
<span class="line" id="L1385">            <span class="tok-kw">return</span> <span class="tok-null">true</span>;</span>
<span class="line" id="L1386">    }</span>
<span class="line" id="L1387">    <span class="tok-kw">return</span> <span class="tok-null">false</span>;</span>
<span class="line" id="L1388">}</span>
<span class="line" id="L1389"></span>
<span class="line" id="L1390"><span class="tok-comment">/// A file that is generated by a build step.</span></span>
<span class="line" id="L1391"><span class="tok-comment">/// This struct is an interface that is meant to be used with `@fieldParentPtr` to implement the actual path logic.</span></span>
<span class="line" id="L1392"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> GeneratedFile = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L1393">    <span class="tok-comment">/// The step that generates the file</span></span>
<span class="line" id="L1394">    step: *Step,</span>
<span class="line" id="L1395"></span>
<span class="line" id="L1396">    <span class="tok-comment">/// The path to the generated file. Must be either absolute or relative to the build root.</span></span>
<span class="line" id="L1397">    <span class="tok-comment">/// This value must be set in the `fn make()` of the `step` and must not be `null` afterwards.</span></span>
<span class="line" id="L1398">    path: ?[]<span class="tok-kw">const</span> <span class="tok-type">u8</span> = <span class="tok-null">null</span>,</span>
<span class="line" id="L1399"></span>
<span class="line" id="L1400">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">getPath</span>(self: GeneratedFile) []<span class="tok-kw">const</span> <span class="tok-type">u8</span> {</span>
<span class="line" id="L1401">        <span class="tok-kw">return</span> self.path <span class="tok-kw">orelse</span> std.debug.panic(</span>
<span class="line" id="L1402">            <span class="tok-str">&quot;getPath() was called on a GeneratedFile that wasn't build yet. Is there a missing Step dependency on step '{s}'?&quot;</span>,</span>
<span class="line" id="L1403">            .{self.step.name},</span>
<span class="line" id="L1404">        );</span>
<span class="line" id="L1405">    }</span>
<span class="line" id="L1406">};</span>
<span class="line" id="L1407"></span>
<span class="line" id="L1408"><span class="tok-comment">/// A file source is a reference to an existing or future file.</span></span>
<span class="line" id="L1409"><span class="tok-comment">///</span></span>
<span class="line" id="L1410"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> FileSource = <span class="tok-kw">union</span>(<span class="tok-kw">enum</span>) {</span>
<span class="line" id="L1411">    <span class="tok-comment">/// A plain file path, relative to build root or absolute.</span></span>
<span class="line" id="L1412">    path: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>,</span>
<span class="line" id="L1413"></span>
<span class="line" id="L1414">    <span class="tok-comment">/// A file that is generated by an interface. Those files usually are</span></span>
<span class="line" id="L1415">    <span class="tok-comment">/// not available until built by a build step.</span></span>
<span class="line" id="L1416">    generated: *<span class="tok-kw">const</span> GeneratedFile,</span>
<span class="line" id="L1417"></span>
<span class="line" id="L1418">    <span class="tok-comment">/// Returns a new file source that will have a relative path to the build root guaranteed.</span></span>
<span class="line" id="L1419">    <span class="tok-comment">/// This should be preferred over setting `.path` directly as it documents that the files are in the project directory.</span></span>
<span class="line" id="L1420">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">relative</span>(path: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) FileSource {</span>
<span class="line" id="L1421">        std.debug.assert(!std.fs.path.isAbsolute(path));</span>
<span class="line" id="L1422">        <span class="tok-kw">return</span> FileSource{ .path = path };</span>
<span class="line" id="L1423">    }</span>
<span class="line" id="L1424"></span>
<span class="line" id="L1425">    <span class="tok-comment">/// Returns a string that can be shown to represent the file source.</span></span>
<span class="line" id="L1426">    <span class="tok-comment">/// Either returns the path or `&quot;generated&quot;`.</span></span>
<span class="line" id="L1427">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">getDisplayName</span>(self: FileSource) []<span class="tok-kw">const</span> <span class="tok-type">u8</span> {</span>
<span class="line" id="L1428">        <span class="tok-kw">return</span> <span class="tok-kw">switch</span> (self) {</span>
<span class="line" id="L1429">            .path =&gt; self.path,</span>
<span class="line" id="L1430">            .generated =&gt; <span class="tok-str">&quot;generated&quot;</span>,</span>
<span class="line" id="L1431">        };</span>
<span class="line" id="L1432">    }</span>
<span class="line" id="L1433"></span>
<span class="line" id="L1434">    <span class="tok-comment">/// Adds dependencies this file source implies to the given step.</span></span>
<span class="line" id="L1435">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">addStepDependencies</span>(self: FileSource, step: *Step) <span class="tok-type">void</span> {</span>
<span class="line" id="L1436">        <span class="tok-kw">switch</span> (self) {</span>
<span class="line" id="L1437">            .path =&gt; {},</span>
<span class="line" id="L1438">            .generated =&gt; |gen| step.dependOn(gen.step),</span>
<span class="line" id="L1439">        }</span>
<span class="line" id="L1440">    }</span>
<span class="line" id="L1441"></span>
<span class="line" id="L1442">    <span class="tok-comment">/// Should only be called during make(), returns a path relative to the build root or absolute.</span></span>
<span class="line" id="L1443">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">getPath</span>(self: FileSource, builder: *Builder) []<span class="tok-kw">const</span> <span class="tok-type">u8</span> {</span>
<span class="line" id="L1444">        <span class="tok-kw">const</span> path = <span class="tok-kw">switch</span> (self) {</span>
<span class="line" id="L1445">            .path =&gt; |p| builder.pathFromRoot(p),</span>
<span class="line" id="L1446">            .generated =&gt; |gen| gen.getPath(),</span>
<span class="line" id="L1447">        };</span>
<span class="line" id="L1448">        <span class="tok-kw">return</span> path;</span>
<span class="line" id="L1449">    }</span>
<span class="line" id="L1450"></span>
<span class="line" id="L1451">    <span class="tok-comment">/// Duplicates the file source for a given builder.</span></span>
<span class="line" id="L1452">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">dupe</span>(self: FileSource, b: *Builder) FileSource {</span>
<span class="line" id="L1453">        <span class="tok-kw">return</span> <span class="tok-kw">switch</span> (self) {</span>
<span class="line" id="L1454">            .path =&gt; |p| .{ .path = b.dupePath(p) },</span>
<span class="line" id="L1455">            .generated =&gt; |gen| .{ .generated = gen },</span>
<span class="line" id="L1456">        };</span>
<span class="line" id="L1457">    }</span>
<span class="line" id="L1458">};</span>
<span class="line" id="L1459"></span>
<span class="line" id="L1460"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> LibExeObjStep = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L1461">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> base_id = .lib_exe_obj;</span>
<span class="line" id="L1462"></span>
<span class="line" id="L1463">    step: Step,</span>
<span class="line" id="L1464">    builder: *Builder,</span>
<span class="line" id="L1465">    name: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>,</span>
<span class="line" id="L1466">    target: CrossTarget = CrossTarget{},</span>
<span class="line" id="L1467">    target_info: NativeTargetInfo,</span>
<span class="line" id="L1468">    linker_script: ?FileSource = <span class="tok-null">null</span>,</span>
<span class="line" id="L1469">    version_script: ?[]<span class="tok-kw">const</span> <span class="tok-type">u8</span> = <span class="tok-null">null</span>,</span>
<span class="line" id="L1470">    out_filename: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>,</span>
<span class="line" id="L1471">    linkage: ?Linkage = <span class="tok-null">null</span>,</span>
<span class="line" id="L1472">    version: ?std.builtin.Version,</span>
<span class="line" id="L1473">    build_mode: std.builtin.Mode,</span>
<span class="line" id="L1474">    kind: Kind,</span>
<span class="line" id="L1475">    major_only_filename: ?[]<span class="tok-kw">const</span> <span class="tok-type">u8</span>,</span>
<span class="line" id="L1476">    name_only_filename: ?[]<span class="tok-kw">const</span> <span class="tok-type">u8</span>,</span>
<span class="line" id="L1477">    strip: <span class="tok-type">bool</span>,</span>
<span class="line" id="L1478">    <span class="tok-comment">// keep in sync with src/link.zig:CompressDebugSections</span>
</span>
<span class="line" id="L1479">    compress_debug_sections: <span class="tok-kw">enum</span> { none, zlib } = .none,</span>
<span class="line" id="L1480">    lib_paths: ArrayList([]<span class="tok-kw">const</span> <span class="tok-type">u8</span>),</span>
<span class="line" id="L1481">    rpaths: ArrayList([]<span class="tok-kw">const</span> <span class="tok-type">u8</span>),</span>
<span class="line" id="L1482">    framework_dirs: ArrayList([]<span class="tok-kw">const</span> <span class="tok-type">u8</span>),</span>
<span class="line" id="L1483">    frameworks: StringHashMap(FrameworkLinkInfo),</span>
<span class="line" id="L1484">    verbose_link: <span class="tok-type">bool</span>,</span>
<span class="line" id="L1485">    verbose_cc: <span class="tok-type">bool</span>,</span>
<span class="line" id="L1486">    emit_analysis: EmitOption = .default,</span>
<span class="line" id="L1487">    emit_asm: EmitOption = .default,</span>
<span class="line" id="L1488">    emit_bin: EmitOption = .default,</span>
<span class="line" id="L1489">    emit_docs: EmitOption = .default,</span>
<span class="line" id="L1490">    emit_implib: EmitOption = .default,</span>
<span class="line" id="L1491">    emit_llvm_bc: EmitOption = .default,</span>
<span class="line" id="L1492">    emit_llvm_ir: EmitOption = .default,</span>
<span class="line" id="L1493">    <span class="tok-comment">// Lots of things depend on emit_h having a consistent path,</span>
</span>
<span class="line" id="L1494">    <span class="tok-comment">// so it is not an EmitOption for now.</span>
</span>
<span class="line" id="L1495">    emit_h: <span class="tok-type">bool</span> = <span class="tok-null">false</span>,</span>
<span class="line" id="L1496">    bundle_compiler_rt: ?<span class="tok-type">bool</span> = <span class="tok-null">null</span>,</span>
<span class="line" id="L1497">    single_threaded: ?<span class="tok-type">bool</span> = <span class="tok-null">null</span>,</span>
<span class="line" id="L1498">    disable_stack_probing: <span class="tok-type">bool</span>,</span>
<span class="line" id="L1499">    disable_sanitize_c: <span class="tok-type">bool</span>,</span>
<span class="line" id="L1500">    sanitize_thread: <span class="tok-type">bool</span>,</span>
<span class="line" id="L1501">    rdynamic: <span class="tok-type">bool</span>,</span>
<span class="line" id="L1502">    import_memory: <span class="tok-type">bool</span> = <span class="tok-null">false</span>,</span>
<span class="line" id="L1503">    import_table: <span class="tok-type">bool</span> = <span class="tok-null">false</span>,</span>
<span class="line" id="L1504">    export_table: <span class="tok-type">bool</span> = <span class="tok-null">false</span>,</span>
<span class="line" id="L1505">    initial_memory: ?<span class="tok-type">u64</span> = <span class="tok-null">null</span>,</span>
<span class="line" id="L1506">    max_memory: ?<span class="tok-type">u64</span> = <span class="tok-null">null</span>,</span>
<span class="line" id="L1507">    shared_memory: <span class="tok-type">bool</span> = <span class="tok-null">false</span>,</span>
<span class="line" id="L1508">    global_base: ?<span class="tok-type">u64</span> = <span class="tok-null">null</span>,</span>
<span class="line" id="L1509">    c_std: Builder.CStd,</span>
<span class="line" id="L1510">    override_lib_dir: ?[]<span class="tok-kw">const</span> <span class="tok-type">u8</span>,</span>
<span class="line" id="L1511">    main_pkg_path: ?[]<span class="tok-kw">const</span> <span class="tok-type">u8</span>,</span>
<span class="line" id="L1512">    exec_cmd_args: ?[]<span class="tok-kw">const</span> ?[]<span class="tok-kw">const</span> <span class="tok-type">u8</span>,</span>
<span class="line" id="L1513">    name_prefix: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>,</span>
<span class="line" id="L1514">    filter: ?[]<span class="tok-kw">const</span> <span class="tok-type">u8</span>,</span>
<span class="line" id="L1515">    test_evented_io: <span class="tok-type">bool</span> = <span class="tok-null">false</span>,</span>
<span class="line" id="L1516">    code_model: std.builtin.CodeModel = .default,</span>
<span class="line" id="L1517">    wasi_exec_model: ?std.builtin.WasiExecModel = <span class="tok-null">null</span>,</span>
<span class="line" id="L1518">    <span class="tok-comment">/// Symbols to be exported when compiling to wasm</span></span>
<span class="line" id="L1519">    export_symbol_names: []<span class="tok-kw">const</span> []<span class="tok-kw">const</span> <span class="tok-type">u8</span> = &amp;.{},</span>
<span class="line" id="L1520"></span>
<span class="line" id="L1521">    root_src: ?FileSource,</span>
<span class="line" id="L1522">    out_h_filename: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>,</span>
<span class="line" id="L1523">    out_lib_filename: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>,</span>
<span class="line" id="L1524">    out_pdb_filename: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>,</span>
<span class="line" id="L1525">    packages: ArrayList(Pkg),</span>
<span class="line" id="L1526"></span>
<span class="line" id="L1527">    object_src: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>,</span>
<span class="line" id="L1528"></span>
<span class="line" id="L1529">    link_objects: ArrayList(LinkObject),</span>
<span class="line" id="L1530">    include_dirs: ArrayList(IncludeDir),</span>
<span class="line" id="L1531">    c_macros: ArrayList([]<span class="tok-kw">const</span> <span class="tok-type">u8</span>),</span>
<span class="line" id="L1532">    output_dir: ?[]<span class="tok-kw">const</span> <span class="tok-type">u8</span>,</span>
<span class="line" id="L1533">    is_linking_libc: <span class="tok-type">bool</span> = <span class="tok-null">false</span>,</span>
<span class="line" id="L1534">    is_linking_libcpp: <span class="tok-type">bool</span> = <span class="tok-null">false</span>,</span>
<span class="line" id="L1535">    vcpkg_bin_path: ?[]<span class="tok-kw">const</span> <span class="tok-type">u8</span> = <span class="tok-null">null</span>,</span>
<span class="line" id="L1536"></span>
<span class="line" id="L1537">    <span class="tok-comment">/// This may be set in order to override the default install directory</span></span>
<span class="line" id="L1538">    override_dest_dir: ?InstallDir,</span>
<span class="line" id="L1539">    installed_path: ?[]<span class="tok-kw">const</span> <span class="tok-type">u8</span>,</span>
<span class="line" id="L1540">    install_step: ?*InstallArtifactStep,</span>
<span class="line" id="L1541"></span>
<span class="line" id="L1542">    <span class="tok-comment">/// Base address for an executable image.</span></span>
<span class="line" id="L1543">    image_base: ?<span class="tok-type">u64</span> = <span class="tok-null">null</span>,</span>
<span class="line" id="L1544"></span>
<span class="line" id="L1545">    libc_file: ?FileSource = <span class="tok-null">null</span>,</span>
<span class="line" id="L1546"></span>
<span class="line" id="L1547">    valgrind_support: ?<span class="tok-type">bool</span> = <span class="tok-null">null</span>,</span>
<span class="line" id="L1548">    each_lib_rpath: ?<span class="tok-type">bool</span> = <span class="tok-null">null</span>,</span>
<span class="line" id="L1549">    <span class="tok-comment">/// On ELF targets, this will emit a link section called &quot;.note.gnu.build-id&quot;</span></span>
<span class="line" id="L1550">    <span class="tok-comment">/// which can be used to coordinate a stripped binary with its debug symbols.</span></span>
<span class="line" id="L1551">    <span class="tok-comment">/// As an example, the bloaty project refuses to work unless its inputs have</span></span>
<span class="line" id="L1552">    <span class="tok-comment">/// build ids, in order to prevent accidental mismatches.</span></span>
<span class="line" id="L1553">    <span class="tok-comment">/// The default is to not include this section because it slows down linking.</span></span>
<span class="line" id="L1554">    build_id: ?<span class="tok-type">bool</span> = <span class="tok-null">null</span>,</span>
<span class="line" id="L1555"></span>
<span class="line" id="L1556">    <span class="tok-comment">/// Create a .eh_frame_hdr section and a PT_GNU_EH_FRAME segment in the ELF</span></span>
<span class="line" id="L1557">    <span class="tok-comment">/// file.</span></span>
<span class="line" id="L1558">    link_eh_frame_hdr: <span class="tok-type">bool</span> = <span class="tok-null">false</span>,</span>
<span class="line" id="L1559">    link_emit_relocs: <span class="tok-type">bool</span> = <span class="tok-null">false</span>,</span>
<span class="line" id="L1560"></span>
<span class="line" id="L1561">    <span class="tok-comment">/// Place every function in its own section so that unused ones may be</span></span>
<span class="line" id="L1562">    <span class="tok-comment">/// safely garbage-collected during the linking phase.</span></span>
<span class="line" id="L1563">    link_function_sections: <span class="tok-type">bool</span> = <span class="tok-null">false</span>,</span>
<span class="line" id="L1564"></span>
<span class="line" id="L1565">    <span class="tok-comment">/// Remove functions and data that are unreachable by the entry point or</span></span>
<span class="line" id="L1566">    <span class="tok-comment">/// exported symbols.</span></span>
<span class="line" id="L1567">    link_gc_sections: ?<span class="tok-type">bool</span> = <span class="tok-null">null</span>,</span>
<span class="line" id="L1568"></span>
<span class="line" id="L1569">    linker_allow_shlib_undefined: ?<span class="tok-type">bool</span> = <span class="tok-null">null</span>,</span>
<span class="line" id="L1570"></span>
<span class="line" id="L1571">    <span class="tok-comment">/// Permit read-only relocations in read-only segments. Disallowed by default.</span></span>
<span class="line" id="L1572">    link_z_notext: <span class="tok-type">bool</span> = <span class="tok-null">false</span>,</span>
<span class="line" id="L1573"></span>
<span class="line" id="L1574">    <span class="tok-comment">/// Force all relocations to be read-only after processing.</span></span>
<span class="line" id="L1575">    link_z_relro: <span class="tok-type">bool</span> = <span class="tok-null">true</span>,</span>
<span class="line" id="L1576"></span>
<span class="line" id="L1577">    <span class="tok-comment">/// Allow relocations to be lazily processed after load.</span></span>
<span class="line" id="L1578">    link_z_lazy: <span class="tok-type">bool</span> = <span class="tok-null">false</span>,</span>
<span class="line" id="L1579"></span>
<span class="line" id="L1580">    <span class="tok-comment">/// (Darwin) Install name for the dylib</span></span>
<span class="line" id="L1581">    install_name: ?[]<span class="tok-kw">const</span> <span class="tok-type">u8</span> = <span class="tok-null">null</span>,</span>
<span class="line" id="L1582"></span>
<span class="line" id="L1583">    <span class="tok-comment">/// (Darwin) Path to entitlements file</span></span>
<span class="line" id="L1584">    entitlements: ?[]<span class="tok-kw">const</span> <span class="tok-type">u8</span> = <span class="tok-null">null</span>,</span>
<span class="line" id="L1585"></span>
<span class="line" id="L1586">    <span class="tok-comment">/// (Darwin) Size of the pagezero segment.</span></span>
<span class="line" id="L1587">    pagezero_size: ?<span class="tok-type">u64</span> = <span class="tok-null">null</span>,</span>
<span class="line" id="L1588"></span>
<span class="line" id="L1589">    <span class="tok-comment">/// (Darwin) Search strategy for searching system libraries. Either `paths_first` or `dylibs_first`.</span></span>
<span class="line" id="L1590">    <span class="tok-comment">/// The former lowers to `-search_paths_first` linker option, while the latter to `-search_dylibs_first`</span></span>
<span class="line" id="L1591">    <span class="tok-comment">/// option.</span></span>
<span class="line" id="L1592">    <span class="tok-comment">/// By default, if no option is specified, the linker assumes `paths_first` as the default</span></span>
<span class="line" id="L1593">    <span class="tok-comment">/// search strategy.</span></span>
<span class="line" id="L1594">    search_strategy: ?<span class="tok-kw">enum</span> { paths_first, dylibs_first } = <span class="tok-null">null</span>,</span>
<span class="line" id="L1595"></span>
<span class="line" id="L1596">    <span class="tok-comment">/// (Darwin) Set size of the padding between the end of load commands</span></span>
<span class="line" id="L1597">    <span class="tok-comment">/// and start of `__TEXT,__text` section.</span></span>
<span class="line" id="L1598">    headerpad_size: ?<span class="tok-type">u32</span> = <span class="tok-null">null</span>,</span>
<span class="line" id="L1599"></span>
<span class="line" id="L1600">    <span class="tok-comment">/// (Darwin) Automatically Set size of the padding between the end of load commands</span></span>
<span class="line" id="L1601">    <span class="tok-comment">/// and start of `__TEXT,__text` section to a value fitting all paths expanded to MAXPATHLEN.</span></span>
<span class="line" id="L1602">    headerpad_max_install_names: <span class="tok-type">bool</span> = <span class="tok-null">false</span>,</span>
<span class="line" id="L1603"></span>
<span class="line" id="L1604">    <span class="tok-comment">/// (Darwin) Remove dylibs that are unreachable by the entry point or exported symbols.</span></span>
<span class="line" id="L1605">    dead_strip_dylibs: <span class="tok-type">bool</span> = <span class="tok-null">false</span>,</span>
<span class="line" id="L1606"></span>
<span class="line" id="L1607">    <span class="tok-comment">/// Position Independent Code</span></span>
<span class="line" id="L1608">    force_pic: ?<span class="tok-type">bool</span> = <span class="tok-null">null</span>,</span>
<span class="line" id="L1609"></span>
<span class="line" id="L1610">    <span class="tok-comment">/// Position Independent Executable</span></span>
<span class="line" id="L1611">    pie: ?<span class="tok-type">bool</span> = <span class="tok-null">null</span>,</span>
<span class="line" id="L1612"></span>
<span class="line" id="L1613">    red_zone: ?<span class="tok-type">bool</span> = <span class="tok-null">null</span>,</span>
<span class="line" id="L1614"></span>
<span class="line" id="L1615">    omit_frame_pointer: ?<span class="tok-type">bool</span> = <span class="tok-null">null</span>,</span>
<span class="line" id="L1616">    dll_export_fns: ?<span class="tok-type">bool</span> = <span class="tok-null">null</span>,</span>
<span class="line" id="L1617"></span>
<span class="line" id="L1618">    subsystem: ?std.Target.SubSystem = <span class="tok-null">null</span>,</span>
<span class="line" id="L1619"></span>
<span class="line" id="L1620">    entry_symbol_name: ?[]<span class="tok-kw">const</span> <span class="tok-type">u8</span> = <span class="tok-null">null</span>,</span>
<span class="line" id="L1621"></span>
<span class="line" id="L1622">    <span class="tok-comment">/// Overrides the default stack size</span></span>
<span class="line" id="L1623">    stack_size: ?<span class="tok-type">u64</span> = <span class="tok-null">null</span>,</span>
<span class="line" id="L1624"></span>
<span class="line" id="L1625">    want_lto: ?<span class="tok-type">bool</span> = <span class="tok-null">null</span>,</span>
<span class="line" id="L1626">    use_stage1: ?<span class="tok-type">bool</span> = <span class="tok-null">null</span>,</span>
<span class="line" id="L1627">    use_llvm: ?<span class="tok-type">bool</span> = <span class="tok-null">null</span>,</span>
<span class="line" id="L1628">    use_lld: ?<span class="tok-type">bool</span> = <span class="tok-null">null</span>,</span>
<span class="line" id="L1629">    ofmt: ?std.Target.ObjectFormat = <span class="tok-null">null</span>,</span>
<span class="line" id="L1630"></span>
<span class="line" id="L1631">    output_path_source: GeneratedFile,</span>
<span class="line" id="L1632">    output_lib_path_source: GeneratedFile,</span>
<span class="line" id="L1633">    output_h_path_source: GeneratedFile,</span>
<span class="line" id="L1634">    output_pdb_path_source: GeneratedFile,</span>
<span class="line" id="L1635"></span>
<span class="line" id="L1636">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> LinkObject = <span class="tok-kw">union</span>(<span class="tok-kw">enum</span>) {</span>
<span class="line" id="L1637">        static_path: FileSource,</span>
<span class="line" id="L1638">        other_step: *LibExeObjStep,</span>
<span class="line" id="L1639">        system_lib: SystemLib,</span>
<span class="line" id="L1640">        assembly_file: FileSource,</span>
<span class="line" id="L1641">        c_source_file: *CSourceFile,</span>
<span class="line" id="L1642">        c_source_files: *CSourceFiles,</span>
<span class="line" id="L1643">    };</span>
<span class="line" id="L1644"></span>
<span class="line" id="L1645">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> SystemLib = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L1646">        name: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>,</span>
<span class="line" id="L1647">        needed: <span class="tok-type">bool</span>,</span>
<span class="line" id="L1648">        weak: <span class="tok-type">bool</span>,</span>
<span class="line" id="L1649">        use_pkg_config: <span class="tok-kw">enum</span> {</span>
<span class="line" id="L1650">            <span class="tok-comment">/// Don't use pkg-config, just pass -lfoo where foo is name.</span></span>
<span class="line" id="L1651">            no,</span>
<span class="line" id="L1652">            <span class="tok-comment">/// Try to get information on how to link the library from pkg-config.</span></span>
<span class="line" id="L1653">            <span class="tok-comment">/// If that fails, fall back to passing -lfoo where foo is name.</span></span>
<span class="line" id="L1654">            yes,</span>
<span class="line" id="L1655">            <span class="tok-comment">/// Try to get information on how to link the library from pkg-config.</span></span>
<span class="line" id="L1656">            <span class="tok-comment">/// If that fails, error out.</span></span>
<span class="line" id="L1657">            force,</span>
<span class="line" id="L1658">        },</span>
<span class="line" id="L1659">    };</span>
<span class="line" id="L1660"></span>
<span class="line" id="L1661">    <span class="tok-kw">const</span> FrameworkLinkInfo = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L1662">        needed: <span class="tok-type">bool</span> = <span class="tok-null">false</span>,</span>
<span class="line" id="L1663">        weak: <span class="tok-type">bool</span> = <span class="tok-null">false</span>,</span>
<span class="line" id="L1664">    };</span>
<span class="line" id="L1665"></span>
<span class="line" id="L1666">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> IncludeDir = <span class="tok-kw">union</span>(<span class="tok-kw">enum</span>) {</span>
<span class="line" id="L1667">        raw_path: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>,</span>
<span class="line" id="L1668">        raw_path_system: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>,</span>
<span class="line" id="L1669">        other_step: *LibExeObjStep,</span>
<span class="line" id="L1670">    };</span>
<span class="line" id="L1671"></span>
<span class="line" id="L1672">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> Kind = <span class="tok-kw">enum</span> {</span>
<span class="line" id="L1673">        exe,</span>
<span class="line" id="L1674">        lib,</span>
<span class="line" id="L1675">        obj,</span>
<span class="line" id="L1676">        @&quot;test&quot;,</span>
<span class="line" id="L1677">        test_exe,</span>
<span class="line" id="L1678">    };</span>
<span class="line" id="L1679"></span>
<span class="line" id="L1680">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> SharedLibKind = <span class="tok-kw">union</span>(<span class="tok-kw">enum</span>) {</span>
<span class="line" id="L1681">        versioned: std.builtin.Version,</span>
<span class="line" id="L1682">        unversioned: <span class="tok-type">void</span>,</span>
<span class="line" id="L1683">    };</span>
<span class="line" id="L1684"></span>
<span class="line" id="L1685">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> Linkage = <span class="tok-kw">enum</span> { dynamic, static };</span>
<span class="line" id="L1686"></span>
<span class="line" id="L1687">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> EmitOption = <span class="tok-kw">union</span>(<span class="tok-kw">enum</span>) {</span>
<span class="line" id="L1688">        default: <span class="tok-type">void</span>,</span>
<span class="line" id="L1689">        no_emit: <span class="tok-type">void</span>,</span>
<span class="line" id="L1690">        emit: <span class="tok-type">void</span>,</span>
<span class="line" id="L1691">        emit_to: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>,</span>
<span class="line" id="L1692"></span>
<span class="line" id="L1693">        <span class="tok-kw">fn</span> <span class="tok-fn">getArg</span>(self: <span class="tok-builtin">@This</span>(), b: *Builder, arg_name: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) ?[]<span class="tok-kw">const</span> <span class="tok-type">u8</span> {</span>
<span class="line" id="L1694">            <span class="tok-kw">return</span> <span class="tok-kw">switch</span> (self) {</span>
<span class="line" id="L1695">                .no_emit =&gt; b.fmt(<span class="tok-str">&quot;-fno-{s}&quot;</span>, .{arg_name}),</span>
<span class="line" id="L1696">                .default =&gt; <span class="tok-null">null</span>,</span>
<span class="line" id="L1697">                .emit =&gt; b.fmt(<span class="tok-str">&quot;-f{s}&quot;</span>, .{arg_name}),</span>
<span class="line" id="L1698">                .emit_to =&gt; |path| b.fmt(<span class="tok-str">&quot;-f{s}={s}&quot;</span>, .{ arg_name, path }),</span>
<span class="line" id="L1699">            };</span>
<span class="line" id="L1700">        }</span>
<span class="line" id="L1701">    };</span>
<span class="line" id="L1702"></span>
<span class="line" id="L1703">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">createSharedLibrary</span>(builder: *Builder, name: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>, root_src: ?FileSource, kind: SharedLibKind) *LibExeObjStep {</span>
<span class="line" id="L1704">        <span class="tok-kw">return</span> initExtraArgs(builder, name, root_src, .lib, .dynamic, <span class="tok-kw">switch</span> (kind) {</span>
<span class="line" id="L1705">            .versioned =&gt; |ver| ver,</span>
<span class="line" id="L1706">            .unversioned =&gt; <span class="tok-null">null</span>,</span>
<span class="line" id="L1707">        });</span>
<span class="line" id="L1708">    }</span>
<span class="line" id="L1709"></span>
<span class="line" id="L1710">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">createStaticLibrary</span>(builder: *Builder, name: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>, root_src: ?FileSource) *LibExeObjStep {</span>
<span class="line" id="L1711">        <span class="tok-kw">return</span> initExtraArgs(builder, name, root_src, .lib, .static, <span class="tok-null">null</span>);</span>
<span class="line" id="L1712">    }</span>
<span class="line" id="L1713"></span>
<span class="line" id="L1714">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">createObject</span>(builder: *Builder, name: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>, root_src: ?FileSource) *LibExeObjStep {</span>
<span class="line" id="L1715">        <span class="tok-kw">return</span> initExtraArgs(builder, name, root_src, .obj, <span class="tok-null">null</span>, <span class="tok-null">null</span>);</span>
<span class="line" id="L1716">    }</span>
<span class="line" id="L1717"></span>
<span class="line" id="L1718">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">createExecutable</span>(builder: *Builder, name: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>, root_src: ?FileSource) *LibExeObjStep {</span>
<span class="line" id="L1719">        <span class="tok-kw">return</span> initExtraArgs(builder, name, root_src, .exe, <span class="tok-null">null</span>, <span class="tok-null">null</span>);</span>
<span class="line" id="L1720">    }</span>
<span class="line" id="L1721"></span>
<span class="line" id="L1722">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">createTest</span>(builder: *Builder, name: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>, root_src: FileSource) *LibExeObjStep {</span>
<span class="line" id="L1723">        <span class="tok-kw">return</span> initExtraArgs(builder, name, root_src, .@&quot;test&quot;, <span class="tok-null">null</span>, <span class="tok-null">null</span>);</span>
<span class="line" id="L1724">    }</span>
<span class="line" id="L1725"></span>
<span class="line" id="L1726">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">createTestExe</span>(builder: *Builder, name: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>, root_src: FileSource) *LibExeObjStep {</span>
<span class="line" id="L1727">        <span class="tok-kw">return</span> initExtraArgs(builder, name, root_src, .test_exe, <span class="tok-null">null</span>, <span class="tok-null">null</span>);</span>
<span class="line" id="L1728">    }</span>
<span class="line" id="L1729"></span>
<span class="line" id="L1730">    <span class="tok-kw">fn</span> <span class="tok-fn">initExtraArgs</span>(</span>
<span class="line" id="L1731">        builder: *Builder,</span>
<span class="line" id="L1732">        name_raw: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>,</span>
<span class="line" id="L1733">        root_src_raw: ?FileSource,</span>
<span class="line" id="L1734">        kind: Kind,</span>
<span class="line" id="L1735">        linkage: ?Linkage,</span>
<span class="line" id="L1736">        ver: ?std.builtin.Version,</span>
<span class="line" id="L1737">    ) *LibExeObjStep {</span>
<span class="line" id="L1738">        <span class="tok-kw">const</span> name = builder.dupe(name_raw);</span>
<span class="line" id="L1739">        <span class="tok-kw">const</span> root_src: ?FileSource = <span class="tok-kw">if</span> (root_src_raw) |rsrc| rsrc.dupe(builder) <span class="tok-kw">else</span> <span class="tok-null">null</span>;</span>
<span class="line" id="L1740">        <span class="tok-kw">if</span> (mem.indexOf(<span class="tok-type">u8</span>, name, <span class="tok-str">&quot;/&quot;</span>) != <span class="tok-null">null</span> <span class="tok-kw">or</span> mem.indexOf(<span class="tok-type">u8</span>, name, <span class="tok-str">&quot;\\&quot;</span>) != <span class="tok-null">null</span>) {</span>
<span class="line" id="L1741">            panic(<span class="tok-str">&quot;invalid name: '{s}'. It looks like a file path, but it is supposed to be the library or application name.&quot;</span>, .{name});</span>
<span class="line" id="L1742">        }</span>
<span class="line" id="L1743"></span>
<span class="line" id="L1744">        <span class="tok-kw">const</span> self = builder.allocator.create(LibExeObjStep) <span class="tok-kw">catch</span> <span class="tok-kw">unreachable</span>;</span>
<span class="line" id="L1745">        self.* = LibExeObjStep{</span>
<span class="line" id="L1746">            .strip = <span class="tok-null">false</span>,</span>
<span class="line" id="L1747">            .builder = builder,</span>
<span class="line" id="L1748">            .verbose_link = <span class="tok-null">false</span>,</span>
<span class="line" id="L1749">            .verbose_cc = <span class="tok-null">false</span>,</span>
<span class="line" id="L1750">            .build_mode = std.builtin.Mode.Debug,</span>
<span class="line" id="L1751">            .linkage = linkage,</span>
<span class="line" id="L1752">            .kind = kind,</span>
<span class="line" id="L1753">            .root_src = root_src,</span>
<span class="line" id="L1754">            .name = name,</span>
<span class="line" id="L1755">            .frameworks = StringHashMap(FrameworkLinkInfo).init(builder.allocator),</span>
<span class="line" id="L1756">            .step = Step.init(base_id, name, builder.allocator, make),</span>
<span class="line" id="L1757">            .version = ver,</span>
<span class="line" id="L1758">            .out_filename = <span class="tok-null">undefined</span>,</span>
<span class="line" id="L1759">            .out_h_filename = builder.fmt(<span class="tok-str">&quot;{s}.h&quot;</span>, .{name}),</span>
<span class="line" id="L1760">            .out_lib_filename = <span class="tok-null">undefined</span>,</span>
<span class="line" id="L1761">            .out_pdb_filename = builder.fmt(<span class="tok-str">&quot;{s}.pdb&quot;</span>, .{name}),</span>
<span class="line" id="L1762">            .major_only_filename = <span class="tok-null">null</span>,</span>
<span class="line" id="L1763">            .name_only_filename = <span class="tok-null">null</span>,</span>
<span class="line" id="L1764">            .packages = ArrayList(Pkg).init(builder.allocator),</span>
<span class="line" id="L1765">            .include_dirs = ArrayList(IncludeDir).init(builder.allocator),</span>
<span class="line" id="L1766">            .link_objects = ArrayList(LinkObject).init(builder.allocator),</span>
<span class="line" id="L1767">            .c_macros = ArrayList([]<span class="tok-kw">const</span> <span class="tok-type">u8</span>).init(builder.allocator),</span>
<span class="line" id="L1768">            .lib_paths = ArrayList([]<span class="tok-kw">const</span> <span class="tok-type">u8</span>).init(builder.allocator),</span>
<span class="line" id="L1769">            .rpaths = ArrayList([]<span class="tok-kw">const</span> <span class="tok-type">u8</span>).init(builder.allocator),</span>
<span class="line" id="L1770">            .framework_dirs = ArrayList([]<span class="tok-kw">const</span> <span class="tok-type">u8</span>).init(builder.allocator),</span>
<span class="line" id="L1771">            .object_src = <span class="tok-null">undefined</span>,</span>
<span class="line" id="L1772">            .c_std = Builder.CStd.C99,</span>
<span class="line" id="L1773">            .override_lib_dir = <span class="tok-null">null</span>,</span>
<span class="line" id="L1774">            .main_pkg_path = <span class="tok-null">null</span>,</span>
<span class="line" id="L1775">            .exec_cmd_args = <span class="tok-null">null</span>,</span>
<span class="line" id="L1776">            .name_prefix = <span class="tok-str">&quot;&quot;</span>,</span>
<span class="line" id="L1777">            .filter = <span class="tok-null">null</span>,</span>
<span class="line" id="L1778">            .disable_stack_probing = <span class="tok-null">false</span>,</span>
<span class="line" id="L1779">            .disable_sanitize_c = <span class="tok-null">false</span>,</span>
<span class="line" id="L1780">            .sanitize_thread = <span class="tok-null">false</span>,</span>
<span class="line" id="L1781">            .rdynamic = <span class="tok-null">false</span>,</span>
<span class="line" id="L1782">            .output_dir = <span class="tok-null">null</span>,</span>
<span class="line" id="L1783">            .override_dest_dir = <span class="tok-null">null</span>,</span>
<span class="line" id="L1784">            .installed_path = <span class="tok-null">null</span>,</span>
<span class="line" id="L1785">            .install_step = <span class="tok-null">null</span>,</span>
<span class="line" id="L1786"></span>
<span class="line" id="L1787">            .output_path_source = GeneratedFile{ .step = &amp;self.step },</span>
<span class="line" id="L1788">            .output_lib_path_source = GeneratedFile{ .step = &amp;self.step },</span>
<span class="line" id="L1789">            .output_h_path_source = GeneratedFile{ .step = &amp;self.step },</span>
<span class="line" id="L1790">            .output_pdb_path_source = GeneratedFile{ .step = &amp;self.step },</span>
<span class="line" id="L1791"></span>
<span class="line" id="L1792">            .target_info = <span class="tok-null">undefined</span>, <span class="tok-comment">// populated in computeOutFileNames</span>
</span>
<span class="line" id="L1793">        };</span>
<span class="line" id="L1794">        self.computeOutFileNames();</span>
<span class="line" id="L1795">        <span class="tok-kw">if</span> (root_src) |rs| rs.addStepDependencies(&amp;self.step);</span>
<span class="line" id="L1796">        <span class="tok-kw">return</span> self;</span>
<span class="line" id="L1797">    }</span>
<span class="line" id="L1798"></span>
<span class="line" id="L1799">    <span class="tok-kw">fn</span> <span class="tok-fn">computeOutFileNames</span>(self: *LibExeObjStep) <span class="tok-type">void</span> {</span>
<span class="line" id="L1800">        self.target_info = NativeTargetInfo.detect(self.builder.allocator, self.target) <span class="tok-kw">catch</span></span>
<span class="line" id="L1801">            <span class="tok-kw">unreachable</span>;</span>
<span class="line" id="L1802"></span>
<span class="line" id="L1803">        <span class="tok-kw">const</span> target = self.target_info.target;</span>
<span class="line" id="L1804"></span>
<span class="line" id="L1805">        self.out_filename = std.zig.binNameAlloc(self.builder.allocator, .{</span>
<span class="line" id="L1806">            .root_name = self.name,</span>
<span class="line" id="L1807">            .target = target,</span>
<span class="line" id="L1808">            .output_mode = <span class="tok-kw">switch</span> (self.kind) {</span>
<span class="line" id="L1809">                .lib =&gt; .Lib,</span>
<span class="line" id="L1810">                .obj =&gt; .Obj,</span>
<span class="line" id="L1811">                .exe, .@&quot;test&quot;, .test_exe =&gt; .Exe,</span>
<span class="line" id="L1812">            },</span>
<span class="line" id="L1813">            .link_mode = <span class="tok-kw">if</span> (self.linkage) |some| <span class="tok-builtin">@as</span>(std.builtin.LinkMode, <span class="tok-kw">switch</span> (some) {</span>
<span class="line" id="L1814">                .dynamic =&gt; .Dynamic,</span>
<span class="line" id="L1815">                .static =&gt; .Static,</span>
<span class="line" id="L1816">            }) <span class="tok-kw">else</span> <span class="tok-null">null</span>,</span>
<span class="line" id="L1817">            .version = self.version,</span>
<span class="line" id="L1818">        }) <span class="tok-kw">catch</span> <span class="tok-kw">unreachable</span>;</span>
<span class="line" id="L1819"></span>
<span class="line" id="L1820">        <span class="tok-kw">if</span> (self.kind == .lib) {</span>
<span class="line" id="L1821">            <span class="tok-kw">if</span> (self.linkage != <span class="tok-null">null</span> <span class="tok-kw">and</span> self.linkage.? == .static) {</span>
<span class="line" id="L1822">                self.out_lib_filename = self.out_filename;</span>
<span class="line" id="L1823">            } <span class="tok-kw">else</span> <span class="tok-kw">if</span> (self.version) |version| {</span>
<span class="line" id="L1824">                <span class="tok-kw">if</span> (target.isDarwin()) {</span>
<span class="line" id="L1825">                    self.major_only_filename = self.builder.fmt(<span class="tok-str">&quot;lib{s}.{d}.dylib&quot;</span>, .{</span>
<span class="line" id="L1826">                        self.name,</span>
<span class="line" id="L1827">                        version.major,</span>
<span class="line" id="L1828">                    });</span>
<span class="line" id="L1829">                    self.name_only_filename = self.builder.fmt(<span class="tok-str">&quot;lib{s}.dylib&quot;</span>, .{self.name});</span>
<span class="line" id="L1830">                    self.out_lib_filename = self.out_filename;</span>
<span class="line" id="L1831">                } <span class="tok-kw">else</span> <span class="tok-kw">if</span> (target.os.tag == .windows) {</span>
<span class="line" id="L1832">                    self.out_lib_filename = self.builder.fmt(<span class="tok-str">&quot;{s}.lib&quot;</span>, .{self.name});</span>
<span class="line" id="L1833">                } <span class="tok-kw">else</span> {</span>
<span class="line" id="L1834">                    self.major_only_filename = self.builder.fmt(<span class="tok-str">&quot;lib{s}.so.{d}&quot;</span>, .{ self.name, version.major });</span>
<span class="line" id="L1835">                    self.name_only_filename = self.builder.fmt(<span class="tok-str">&quot;lib{s}.so&quot;</span>, .{self.name});</span>
<span class="line" id="L1836">                    self.out_lib_filename = self.out_filename;</span>
<span class="line" id="L1837">                }</span>
<span class="line" id="L1838">            } <span class="tok-kw">else</span> {</span>
<span class="line" id="L1839">                <span class="tok-kw">if</span> (target.isDarwin()) {</span>
<span class="line" id="L1840">                    self.out_lib_filename = self.out_filename;</span>
<span class="line" id="L1841">                } <span class="tok-kw">else</span> <span class="tok-kw">if</span> (target.os.tag == .windows) {</span>
<span class="line" id="L1842">                    self.out_lib_filename = self.builder.fmt(<span class="tok-str">&quot;{s}.lib&quot;</span>, .{self.name});</span>
<span class="line" id="L1843">                } <span class="tok-kw">else</span> {</span>
<span class="line" id="L1844">                    self.out_lib_filename = self.out_filename;</span>
<span class="line" id="L1845">                }</span>
<span class="line" id="L1846">            }</span>
<span class="line" id="L1847">            <span class="tok-kw">if</span> (self.output_dir != <span class="tok-null">null</span>) {</span>
<span class="line" id="L1848">                self.output_lib_path_source.path = self.builder.pathJoin(</span>
<span class="line" id="L1849">                    &amp;.{ self.output_dir.?, self.out_lib_filename },</span>
<span class="line" id="L1850">                );</span>
<span class="line" id="L1851">            }</span>
<span class="line" id="L1852">        }</span>
<span class="line" id="L1853">    }</span>
<span class="line" id="L1854"></span>
<span class="line" id="L1855">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">setTarget</span>(self: *LibExeObjStep, target: CrossTarget) <span class="tok-type">void</span> {</span>
<span class="line" id="L1856">        self.target = target;</span>
<span class="line" id="L1857">        self.computeOutFileNames();</span>
<span class="line" id="L1858">    }</span>
<span class="line" id="L1859"></span>
<span class="line" id="L1860">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">setOutputDir</span>(self: *LibExeObjStep, dir: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) <span class="tok-type">void</span> {</span>
<span class="line" id="L1861">        self.output_dir = self.builder.dupePath(dir);</span>
<span class="line" id="L1862">    }</span>
<span class="line" id="L1863"></span>
<span class="line" id="L1864">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">install</span>(self: *LibExeObjStep) <span class="tok-type">void</span> {</span>
<span class="line" id="L1865">        self.builder.installArtifact(self);</span>
<span class="line" id="L1866">    }</span>
<span class="line" id="L1867"></span>
<span class="line" id="L1868">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">installRaw</span>(self: *LibExeObjStep, dest_filename: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>, options: InstallRawStep.CreateOptions) *InstallRawStep {</span>
<span class="line" id="L1869">        <span class="tok-kw">return</span> self.builder.installRaw(self, dest_filename, options);</span>
<span class="line" id="L1870">    }</span>
<span class="line" id="L1871"></span>
<span class="line" id="L1872">    <span class="tok-comment">/// Creates a `RunStep` with an executable built with `addExecutable`.</span></span>
<span class="line" id="L1873">    <span class="tok-comment">/// Add command line arguments with `addArg`.</span></span>
<span class="line" id="L1874">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">run</span>(exe: *LibExeObjStep) *RunStep {</span>
<span class="line" id="L1875">        assert(exe.kind == .exe <span class="tok-kw">or</span> exe.kind == .test_exe);</span>
<span class="line" id="L1876"></span>
<span class="line" id="L1877">        <span class="tok-comment">// It doesn't have to be native. We catch that if you actually try to run it.</span>
</span>
<span class="line" id="L1878">        <span class="tok-comment">// Consider that this is declarative; the run step may not be run unless a user</span>
</span>
<span class="line" id="L1879">        <span class="tok-comment">// option is supplied.</span>
</span>
<span class="line" id="L1880">        <span class="tok-kw">const</span> run_step = RunStep.create(exe.builder, exe.builder.fmt(<span class="tok-str">&quot;run {s}&quot;</span>, .{exe.step.name}));</span>
<span class="line" id="L1881">        run_step.addArtifactArg(exe);</span>
<span class="line" id="L1882"></span>
<span class="line" id="L1883">        <span class="tok-kw">if</span> (exe.kind == .test_exe) {</span>
<span class="line" id="L1884">            run_step.addArg(exe.builder.zig_exe);</span>
<span class="line" id="L1885">        }</span>
<span class="line" id="L1886"></span>
<span class="line" id="L1887">        <span class="tok-kw">if</span> (exe.vcpkg_bin_path) |path| {</span>
<span class="line" id="L1888">            run_step.addPathDir(path);</span>
<span class="line" id="L1889">        }</span>
<span class="line" id="L1890"></span>
<span class="line" id="L1891">        <span class="tok-kw">return</span> run_step;</span>
<span class="line" id="L1892">    }</span>
<span class="line" id="L1893"></span>
<span class="line" id="L1894">    <span class="tok-comment">/// Creates an `EmulatableRunStep` with an executable built with `addExecutable`.</span></span>
<span class="line" id="L1895">    <span class="tok-comment">/// Allows running foreign binaries through emulation platforms such as Qemu or Rosetta.</span></span>
<span class="line" id="L1896">    <span class="tok-comment">/// When a binary cannot be ran through emulation or the option is disabled, a warning</span></span>
<span class="line" id="L1897">    <span class="tok-comment">/// will be printed and the binary will *NOT* be ran.</span></span>
<span class="line" id="L1898">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">runEmulatable</span>(exe: *LibExeObjStep) *EmulatableRunStep {</span>
<span class="line" id="L1899">        assert(exe.kind == .exe <span class="tok-kw">or</span> exe.kind == .test_exe);</span>
<span class="line" id="L1900"></span>
<span class="line" id="L1901">        <span class="tok-kw">const</span> run_step = EmulatableRunStep.create(exe.builder.fmt(<span class="tok-str">&quot;run {s}&quot;</span>, .{exe.step.name}), exe);</span>
<span class="line" id="L1902">        <span class="tok-kw">if</span> (exe.vcpkg_bin_path) |path| {</span>
<span class="line" id="L1903">            run_step.addPathDir(path);</span>
<span class="line" id="L1904">        }</span>
<span class="line" id="L1905"></span>
<span class="line" id="L1906">        <span class="tok-kw">return</span> run_step;</span>
<span class="line" id="L1907">    }</span>
<span class="line" id="L1908"></span>
<span class="line" id="L1909">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">checkObject</span>(self: *LibExeObjStep, obj_format: std.Target.ObjectFormat) *CheckObjectStep {</span>
<span class="line" id="L1910">        <span class="tok-kw">return</span> CheckObjectStep.create(self.builder, self.getOutputSource(), obj_format);</span>
<span class="line" id="L1911">    }</span>
<span class="line" id="L1912"></span>
<span class="line" id="L1913">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">setLinkerScriptPath</span>(self: *LibExeObjStep, source: FileSource) <span class="tok-type">void</span> {</span>
<span class="line" id="L1914">        self.linker_script = source.dupe(self.builder);</span>
<span class="line" id="L1915">        source.addStepDependencies(&amp;self.step);</span>
<span class="line" id="L1916">    }</span>
<span class="line" id="L1917"></span>
<span class="line" id="L1918">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">linkFramework</span>(self: *LibExeObjStep, framework_name: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) <span class="tok-type">void</span> {</span>
<span class="line" id="L1919">        self.frameworks.put(self.builder.dupe(framework_name), .{}) <span class="tok-kw">catch</span> <span class="tok-kw">unreachable</span>;</span>
<span class="line" id="L1920">    }</span>
<span class="line" id="L1921"></span>
<span class="line" id="L1922">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">linkFrameworkNeeded</span>(self: *LibExeObjStep, framework_name: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) <span class="tok-type">void</span> {</span>
<span class="line" id="L1923">        self.frameworks.put(self.builder.dupe(framework_name), .{</span>
<span class="line" id="L1924">            .needed = <span class="tok-null">true</span>,</span>
<span class="line" id="L1925">        }) <span class="tok-kw">catch</span> <span class="tok-kw">unreachable</span>;</span>
<span class="line" id="L1926">    }</span>
<span class="line" id="L1927"></span>
<span class="line" id="L1928">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">linkFrameworkWeak</span>(self: *LibExeObjStep, framework_name: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) <span class="tok-type">void</span> {</span>
<span class="line" id="L1929">        self.frameworks.put(self.builder.dupe(framework_name), .{</span>
<span class="line" id="L1930">            .weak = <span class="tok-null">true</span>,</span>
<span class="line" id="L1931">        }) <span class="tok-kw">catch</span> <span class="tok-kw">unreachable</span>;</span>
<span class="line" id="L1932">    }</span>
<span class="line" id="L1933"></span>
<span class="line" id="L1934">    <span class="tok-comment">/// Returns whether the library, executable, or object depends on a particular system library.</span></span>
<span class="line" id="L1935">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">dependsOnSystemLibrary</span>(self: LibExeObjStep, name: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) <span class="tok-type">bool</span> {</span>
<span class="line" id="L1936">        <span class="tok-kw">if</span> (isLibCLibrary(name)) {</span>
<span class="line" id="L1937">            <span class="tok-kw">return</span> self.is_linking_libc;</span>
<span class="line" id="L1938">        }</span>
<span class="line" id="L1939">        <span class="tok-kw">if</span> (isLibCppLibrary(name)) {</span>
<span class="line" id="L1940">            <span class="tok-kw">return</span> self.is_linking_libcpp;</span>
<span class="line" id="L1941">        }</span>
<span class="line" id="L1942">        <span class="tok-kw">for</span> (self.link_objects.items) |link_object| {</span>
<span class="line" id="L1943">            <span class="tok-kw">switch</span> (link_object) {</span>
<span class="line" id="L1944">                .system_lib =&gt; |lib| <span class="tok-kw">if</span> (mem.eql(<span class="tok-type">u8</span>, lib.name, name)) <span class="tok-kw">return</span> <span class="tok-null">true</span>,</span>
<span class="line" id="L1945">                <span class="tok-kw">else</span> =&gt; <span class="tok-kw">continue</span>,</span>
<span class="line" id="L1946">            }</span>
<span class="line" id="L1947">        }</span>
<span class="line" id="L1948">        <span class="tok-kw">return</span> <span class="tok-null">false</span>;</span>
<span class="line" id="L1949">    }</span>
<span class="line" id="L1950"></span>
<span class="line" id="L1951">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">linkLibrary</span>(self: *LibExeObjStep, lib: *LibExeObjStep) <span class="tok-type">void</span> {</span>
<span class="line" id="L1952">        assert(lib.kind == .lib);</span>
<span class="line" id="L1953">        self.linkLibraryOrObject(lib);</span>
<span class="line" id="L1954">    }</span>
<span class="line" id="L1955"></span>
<span class="line" id="L1956">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">isDynamicLibrary</span>(self: *LibExeObjStep) <span class="tok-type">bool</span> {</span>
<span class="line" id="L1957">        <span class="tok-kw">return</span> self.kind == .lib <span class="tok-kw">and</span> self.linkage != <span class="tok-null">null</span> <span class="tok-kw">and</span> self.linkage.? == .dynamic;</span>
<span class="line" id="L1958">    }</span>
<span class="line" id="L1959"></span>
<span class="line" id="L1960">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">producesPdbFile</span>(self: *LibExeObjStep) <span class="tok-type">bool</span> {</span>
<span class="line" id="L1961">        <span class="tok-kw">if</span> (!self.target.isWindows() <span class="tok-kw">and</span> !self.target.isUefi()) <span class="tok-kw">return</span> <span class="tok-null">false</span>;</span>
<span class="line" id="L1962">        <span class="tok-kw">if</span> (self.strip) <span class="tok-kw">return</span> <span class="tok-null">false</span>;</span>
<span class="line" id="L1963">        <span class="tok-kw">return</span> self.isDynamicLibrary() <span class="tok-kw">or</span> self.kind == .exe <span class="tok-kw">or</span> self.kind == .test_exe;</span>
<span class="line" id="L1964">    }</span>
<span class="line" id="L1965"></span>
<span class="line" id="L1966">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">linkLibC</span>(self: *LibExeObjStep) <span class="tok-type">void</span> {</span>
<span class="line" id="L1967">        <span class="tok-kw">if</span> (!self.is_linking_libc) {</span>
<span class="line" id="L1968">            self.is_linking_libc = <span class="tok-null">true</span>;</span>
<span class="line" id="L1969">            self.link_objects.append(.{</span>
<span class="line" id="L1970">                .system_lib = .{</span>
<span class="line" id="L1971">                    .name = <span class="tok-str">&quot;c&quot;</span>,</span>
<span class="line" id="L1972">                    .needed = <span class="tok-null">false</span>,</span>
<span class="line" id="L1973">                    .weak = <span class="tok-null">false</span>,</span>
<span class="line" id="L1974">                    .use_pkg_config = .no,</span>
<span class="line" id="L1975">                },</span>
<span class="line" id="L1976">            }) <span class="tok-kw">catch</span> <span class="tok-kw">unreachable</span>;</span>
<span class="line" id="L1977">        }</span>
<span class="line" id="L1978">    }</span>
<span class="line" id="L1979"></span>
<span class="line" id="L1980">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">linkLibCpp</span>(self: *LibExeObjStep) <span class="tok-type">void</span> {</span>
<span class="line" id="L1981">        <span class="tok-kw">if</span> (!self.is_linking_libcpp) {</span>
<span class="line" id="L1982">            self.is_linking_libcpp = <span class="tok-null">true</span>;</span>
<span class="line" id="L1983">            self.link_objects.append(.{</span>
<span class="line" id="L1984">                .system_lib = .{</span>
<span class="line" id="L1985">                    .name = <span class="tok-str">&quot;c++&quot;</span>,</span>
<span class="line" id="L1986">                    .needed = <span class="tok-null">false</span>,</span>
<span class="line" id="L1987">                    .weak = <span class="tok-null">false</span>,</span>
<span class="line" id="L1988">                    .use_pkg_config = .no,</span>
<span class="line" id="L1989">                },</span>
<span class="line" id="L1990">            }) <span class="tok-kw">catch</span> <span class="tok-kw">unreachable</span>;</span>
<span class="line" id="L1991">        }</span>
<span class="line" id="L1992">    }</span>
<span class="line" id="L1993"></span>
<span class="line" id="L1994">    <span class="tok-comment">/// If the value is omitted, it is set to 1.</span></span>
<span class="line" id="L1995">    <span class="tok-comment">/// `name` and `value` need not live longer than the function call.</span></span>
<span class="line" id="L1996">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">defineCMacro</span>(self: *LibExeObjStep, name: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>, value: ?[]<span class="tok-kw">const</span> <span class="tok-type">u8</span>) <span class="tok-type">void</span> {</span>
<span class="line" id="L1997">        <span class="tok-kw">const</span> macro = constructCMacro(self.builder.allocator, name, value);</span>
<span class="line" id="L1998">        self.c_macros.append(macro) <span class="tok-kw">catch</span> <span class="tok-kw">unreachable</span>;</span>
<span class="line" id="L1999">    }</span>
<span class="line" id="L2000"></span>
<span class="line" id="L2001">    <span class="tok-comment">/// name_and_value looks like [name]=[value]. If the value is omitted, it is set to 1.</span></span>
<span class="line" id="L2002">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">defineCMacroRaw</span>(self: *LibExeObjStep, name_and_value: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) <span class="tok-type">void</span> {</span>
<span class="line" id="L2003">        self.c_macros.append(self.builder.dupe(name_and_value)) <span class="tok-kw">catch</span> <span class="tok-kw">unreachable</span>;</span>
<span class="line" id="L2004">    }</span>
<span class="line" id="L2005"></span>
<span class="line" id="L2006">    <span class="tok-comment">/// This one has no integration with anything, it just puts -lname on the command line.</span></span>
<span class="line" id="L2007">    <span class="tok-comment">/// Prefer to use `linkSystemLibrary` instead.</span></span>
<span class="line" id="L2008">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">linkSystemLibraryName</span>(self: *LibExeObjStep, name: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) <span class="tok-type">void</span> {</span>
<span class="line" id="L2009">        self.link_objects.append(.{</span>
<span class="line" id="L2010">            .system_lib = .{</span>
<span class="line" id="L2011">                .name = self.builder.dupe(name),</span>
<span class="line" id="L2012">                .needed = <span class="tok-null">false</span>,</span>
<span class="line" id="L2013">                .weak = <span class="tok-null">false</span>,</span>
<span class="line" id="L2014">                .use_pkg_config = .no,</span>
<span class="line" id="L2015">            },</span>
<span class="line" id="L2016">        }) <span class="tok-kw">catch</span> <span class="tok-kw">unreachable</span>;</span>
<span class="line" id="L2017">    }</span>
<span class="line" id="L2018"></span>
<span class="line" id="L2019">    <span class="tok-comment">/// This one has no integration with anything, it just puts -needed-lname on the command line.</span></span>
<span class="line" id="L2020">    <span class="tok-comment">/// Prefer to use `linkSystemLibraryNeeded` instead.</span></span>
<span class="line" id="L2021">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">linkSystemLibraryNeededName</span>(self: *LibExeObjStep, name: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) <span class="tok-type">void</span> {</span>
<span class="line" id="L2022">        self.link_objects.append(.{</span>
<span class="line" id="L2023">            .system_lib = .{</span>
<span class="line" id="L2024">                .name = self.builder.dupe(name),</span>
<span class="line" id="L2025">                .needed = <span class="tok-null">true</span>,</span>
<span class="line" id="L2026">                .weak = <span class="tok-null">false</span>,</span>
<span class="line" id="L2027">                .use_pkg_config = .no,</span>
<span class="line" id="L2028">            },</span>
<span class="line" id="L2029">        }) <span class="tok-kw">catch</span> <span class="tok-kw">unreachable</span>;</span>
<span class="line" id="L2030">    }</span>
<span class="line" id="L2031"></span>
<span class="line" id="L2032">    <span class="tok-comment">/// Darwin-only. This one has no integration with anything, it just puts -weak-lname on the</span></span>
<span class="line" id="L2033">    <span class="tok-comment">/// command line. Prefer to use `linkSystemLibraryWeak` instead.</span></span>
<span class="line" id="L2034">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">linkSystemLibraryWeakName</span>(self: *LibExeObjStep, name: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) <span class="tok-type">void</span> {</span>
<span class="line" id="L2035">        self.link_objects.append(.{</span>
<span class="line" id="L2036">            .system_lib = .{</span>
<span class="line" id="L2037">                .name = self.builder.dupe(name),</span>
<span class="line" id="L2038">                .needed = <span class="tok-null">false</span>,</span>
<span class="line" id="L2039">                .weak = <span class="tok-null">true</span>,</span>
<span class="line" id="L2040">                .use_pkg_config = .no,</span>
<span class="line" id="L2041">            },</span>
<span class="line" id="L2042">        }) <span class="tok-kw">catch</span> <span class="tok-kw">unreachable</span>;</span>
<span class="line" id="L2043">    }</span>
<span class="line" id="L2044"></span>
<span class="line" id="L2045">    <span class="tok-comment">/// This links against a system library, exclusively using pkg-config to find the library.</span></span>
<span class="line" id="L2046">    <span class="tok-comment">/// Prefer to use `linkSystemLibrary` instead.</span></span>
<span class="line" id="L2047">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">linkSystemLibraryPkgConfigOnly</span>(self: *LibExeObjStep, lib_name: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) <span class="tok-type">void</span> {</span>
<span class="line" id="L2048">        self.link_objects.append(.{</span>
<span class="line" id="L2049">            .system_lib = .{</span>
<span class="line" id="L2050">                .name = self.builder.dupe(lib_name),</span>
<span class="line" id="L2051">                .needed = <span class="tok-null">false</span>,</span>
<span class="line" id="L2052">                .weak = <span class="tok-null">false</span>,</span>
<span class="line" id="L2053">                .use_pkg_config = .force,</span>
<span class="line" id="L2054">            },</span>
<span class="line" id="L2055">        }) <span class="tok-kw">catch</span> <span class="tok-kw">unreachable</span>;</span>
<span class="line" id="L2056">    }</span>
<span class="line" id="L2057"></span>
<span class="line" id="L2058">    <span class="tok-comment">/// This links against a system library, exclusively using pkg-config to find the library.</span></span>
<span class="line" id="L2059">    <span class="tok-comment">/// Prefer to use `linkSystemLibraryNeeded` instead.</span></span>
<span class="line" id="L2060">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">linkSystemLibraryNeededPkgConfigOnly</span>(self: *LibExeObjStep, lib_name: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) <span class="tok-type">void</span> {</span>
<span class="line" id="L2061">        self.link_objects.append(.{</span>
<span class="line" id="L2062">            .system_lib = .{</span>
<span class="line" id="L2063">                .name = self.builder.dupe(lib_name),</span>
<span class="line" id="L2064">                .needed = <span class="tok-null">true</span>,</span>
<span class="line" id="L2065">                .weak = <span class="tok-null">false</span>,</span>
<span class="line" id="L2066">                .use_pkg_config = .force,</span>
<span class="line" id="L2067">            },</span>
<span class="line" id="L2068">        }) <span class="tok-kw">catch</span> <span class="tok-kw">unreachable</span>;</span>
<span class="line" id="L2069">    }</span>
<span class="line" id="L2070"></span>
<span class="line" id="L2071">    <span class="tok-comment">/// Run pkg-config for the given library name and parse the output, returning the arguments</span></span>
<span class="line" id="L2072">    <span class="tok-comment">/// that should be passed to zig to link the given library.</span></span>
<span class="line" id="L2073">    <span class="tok-kw">fn</span> <span class="tok-fn">runPkgConfig</span>(self: *LibExeObjStep, lib_name: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) ![]<span class="tok-kw">const</span> []<span class="tok-kw">const</span> <span class="tok-type">u8</span> {</span>
<span class="line" id="L2074">        <span class="tok-kw">const</span> pkg_name = match: {</span>
<span class="line" id="L2075">            <span class="tok-comment">// First we have to map the library name to pkg config name. Unfortunately,</span>
</span>
<span class="line" id="L2076">            <span class="tok-comment">// there are several examples where this is not straightforward:</span>
</span>
<span class="line" id="L2077">            <span class="tok-comment">// -lSDL2 -&gt; pkg-config sdl2</span>
</span>
<span class="line" id="L2078">            <span class="tok-comment">// -lgdk-3 -&gt; pkg-config gdk-3.0</span>
</span>
<span class="line" id="L2079">            <span class="tok-comment">// -latk-1.0 -&gt; pkg-config atk</span>
</span>
<span class="line" id="L2080">            <span class="tok-kw">const</span> pkgs = <span class="tok-kw">try</span> self.builder.getPkgConfigList();</span>
<span class="line" id="L2081"></span>
<span class="line" id="L2082">            <span class="tok-comment">// Exact match means instant winner.</span>
</span>
<span class="line" id="L2083">            <span class="tok-kw">for</span> (pkgs) |pkg| {</span>
<span class="line" id="L2084">                <span class="tok-kw">if</span> (mem.eql(<span class="tok-type">u8</span>, pkg.name, lib_name)) {</span>
<span class="line" id="L2085">                    <span class="tok-kw">break</span> :match pkg.name;</span>
<span class="line" id="L2086">                }</span>
<span class="line" id="L2087">            }</span>
<span class="line" id="L2088"></span>
<span class="line" id="L2089">            <span class="tok-comment">// Next we'll try ignoring case.</span>
</span>
<span class="line" id="L2090">            <span class="tok-kw">for</span> (pkgs) |pkg| {</span>
<span class="line" id="L2091">                <span class="tok-kw">if</span> (std.ascii.eqlIgnoreCase(pkg.name, lib_name)) {</span>
<span class="line" id="L2092">                    <span class="tok-kw">break</span> :match pkg.name;</span>
<span class="line" id="L2093">                }</span>
<span class="line" id="L2094">            }</span>
<span class="line" id="L2095"></span>
<span class="line" id="L2096">            <span class="tok-comment">// Now try appending &quot;.0&quot;.</span>
</span>
<span class="line" id="L2097">            <span class="tok-kw">for</span> (pkgs) |pkg| {</span>
<span class="line" id="L2098">                <span class="tok-kw">if</span> (std.ascii.indexOfIgnoreCase(pkg.name, lib_name)) |pos| {</span>
<span class="line" id="L2099">                    <span class="tok-kw">if</span> (pos != <span class="tok-number">0</span>) <span class="tok-kw">continue</span>;</span>
<span class="line" id="L2100">                    <span class="tok-kw">if</span> (mem.eql(<span class="tok-type">u8</span>, pkg.name[lib_name.len..], <span class="tok-str">&quot;.0&quot;</span>)) {</span>
<span class="line" id="L2101">                        <span class="tok-kw">break</span> :match pkg.name;</span>
<span class="line" id="L2102">                    }</span>
<span class="line" id="L2103">                }</span>
<span class="line" id="L2104">            }</span>
<span class="line" id="L2105"></span>
<span class="line" id="L2106">            <span class="tok-comment">// Trimming &quot;-1.0&quot;.</span>
</span>
<span class="line" id="L2107">            <span class="tok-kw">if</span> (mem.endsWith(<span class="tok-type">u8</span>, lib_name, <span class="tok-str">&quot;-1.0&quot;</span>)) {</span>
<span class="line" id="L2108">                <span class="tok-kw">const</span> trimmed_lib_name = lib_name[<span class="tok-number">0</span> .. lib_name.len - <span class="tok-str">&quot;-1.0&quot;</span>.len];</span>
<span class="line" id="L2109">                <span class="tok-kw">for</span> (pkgs) |pkg| {</span>
<span class="line" id="L2110">                    <span class="tok-kw">if</span> (std.ascii.eqlIgnoreCase(pkg.name, trimmed_lib_name)) {</span>
<span class="line" id="L2111">                        <span class="tok-kw">break</span> :match pkg.name;</span>
<span class="line" id="L2112">                    }</span>
<span class="line" id="L2113">                }</span>
<span class="line" id="L2114">            }</span>
<span class="line" id="L2115"></span>
<span class="line" id="L2116">            <span class="tok-kw">return</span> <span class="tok-kw">error</span>.PackageNotFound;</span>
<span class="line" id="L2117">        };</span>
<span class="line" id="L2118"></span>
<span class="line" id="L2119">        <span class="tok-kw">var</span> code: <span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L2120">        <span class="tok-kw">const</span> stdout = <span class="tok-kw">if</span> (self.builder.execAllowFail(&amp;[_][]<span class="tok-kw">const</span> <span class="tok-type">u8</span>{</span>
<span class="line" id="L2121">            <span class="tok-str">&quot;pkg-config&quot;</span>,</span>
<span class="line" id="L2122">            pkg_name,</span>
<span class="line" id="L2123">            <span class="tok-str">&quot;--cflags&quot;</span>,</span>
<span class="line" id="L2124">            <span class="tok-str">&quot;--libs&quot;</span>,</span>
<span class="line" id="L2125">        }, &amp;code, .Ignore)) |stdout| stdout <span class="tok-kw">else</span> |err| <span class="tok-kw">switch</span> (err) {</span>
<span class="line" id="L2126">            <span class="tok-kw">error</span>.ProcessTerminated =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.PkgConfigCrashed,</span>
<span class="line" id="L2127">            <span class="tok-kw">error</span>.ExecNotSupported =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.PkgConfigFailed,</span>
<span class="line" id="L2128">            <span class="tok-kw">error</span>.ExitCodeFailure =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.PkgConfigFailed,</span>
<span class="line" id="L2129">            <span class="tok-kw">error</span>.FileNotFound =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.PkgConfigNotInstalled,</span>
<span class="line" id="L2130">            <span class="tok-kw">error</span>.ChildExecFailed =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.PkgConfigFailed,</span>
<span class="line" id="L2131">            <span class="tok-kw">else</span> =&gt; <span class="tok-kw">return</span> err,</span>
<span class="line" id="L2132">        };</span>
<span class="line" id="L2133"></span>
<span class="line" id="L2134">        <span class="tok-kw">var</span> zig_args = std.ArrayList([]<span class="tok-kw">const</span> <span class="tok-type">u8</span>).init(self.builder.allocator);</span>
<span class="line" id="L2135">        <span class="tok-kw">defer</span> zig_args.deinit();</span>
<span class="line" id="L2136"></span>
<span class="line" id="L2137">        <span class="tok-kw">var</span> it = mem.tokenize(<span class="tok-type">u8</span>, stdout, <span class="tok-str">&quot; \r\n\t&quot;</span>);</span>
<span class="line" id="L2138">        <span class="tok-kw">while</span> (it.next()) |tok| {</span>
<span class="line" id="L2139">            <span class="tok-kw">if</span> (mem.eql(<span class="tok-type">u8</span>, tok, <span class="tok-str">&quot;-I&quot;</span>)) {</span>
<span class="line" id="L2140">                <span class="tok-kw">const</span> dir = it.next() <span class="tok-kw">orelse</span> <span class="tok-kw">return</span> <span class="tok-kw">error</span>.PkgConfigInvalidOutput;</span>
<span class="line" id="L2141">                <span class="tok-kw">try</span> zig_args.appendSlice(&amp;[_][]<span class="tok-kw">const</span> <span class="tok-type">u8</span>{ <span class="tok-str">&quot;-I&quot;</span>, dir });</span>
<span class="line" id="L2142">            } <span class="tok-kw">else</span> <span class="tok-kw">if</span> (mem.startsWith(<span class="tok-type">u8</span>, tok, <span class="tok-str">&quot;-I&quot;</span>)) {</span>
<span class="line" id="L2143">                <span class="tok-kw">try</span> zig_args.append(tok);</span>
<span class="line" id="L2144">            } <span class="tok-kw">else</span> <span class="tok-kw">if</span> (mem.eql(<span class="tok-type">u8</span>, tok, <span class="tok-str">&quot;-L&quot;</span>)) {</span>
<span class="line" id="L2145">                <span class="tok-kw">const</span> dir = it.next() <span class="tok-kw">orelse</span> <span class="tok-kw">return</span> <span class="tok-kw">error</span>.PkgConfigInvalidOutput;</span>
<span class="line" id="L2146">                <span class="tok-kw">try</span> zig_args.appendSlice(&amp;[_][]<span class="tok-kw">const</span> <span class="tok-type">u8</span>{ <span class="tok-str">&quot;-L&quot;</span>, dir });</span>
<span class="line" id="L2147">            } <span class="tok-kw">else</span> <span class="tok-kw">if</span> (mem.startsWith(<span class="tok-type">u8</span>, tok, <span class="tok-str">&quot;-L&quot;</span>)) {</span>
<span class="line" id="L2148">                <span class="tok-kw">try</span> zig_args.append(tok);</span>
<span class="line" id="L2149">            } <span class="tok-kw">else</span> <span class="tok-kw">if</span> (mem.eql(<span class="tok-type">u8</span>, tok, <span class="tok-str">&quot;-l&quot;</span>)) {</span>
<span class="line" id="L2150">                <span class="tok-kw">const</span> lib = it.next() <span class="tok-kw">orelse</span> <span class="tok-kw">return</span> <span class="tok-kw">error</span>.PkgConfigInvalidOutput;</span>
<span class="line" id="L2151">                <span class="tok-kw">try</span> zig_args.appendSlice(&amp;[_][]<span class="tok-kw">const</span> <span class="tok-type">u8</span>{ <span class="tok-str">&quot;-l&quot;</span>, lib });</span>
<span class="line" id="L2152">            } <span class="tok-kw">else</span> <span class="tok-kw">if</span> (mem.startsWith(<span class="tok-type">u8</span>, tok, <span class="tok-str">&quot;-l&quot;</span>)) {</span>
<span class="line" id="L2153">                <span class="tok-kw">try</span> zig_args.append(tok);</span>
<span class="line" id="L2154">            } <span class="tok-kw">else</span> <span class="tok-kw">if</span> (mem.eql(<span class="tok-type">u8</span>, tok, <span class="tok-str">&quot;-D&quot;</span>)) {</span>
<span class="line" id="L2155">                <span class="tok-kw">const</span> macro = it.next() <span class="tok-kw">orelse</span> <span class="tok-kw">return</span> <span class="tok-kw">error</span>.PkgConfigInvalidOutput;</span>
<span class="line" id="L2156">                <span class="tok-kw">try</span> zig_args.appendSlice(&amp;[_][]<span class="tok-kw">const</span> <span class="tok-type">u8</span>{ <span class="tok-str">&quot;-D&quot;</span>, macro });</span>
<span class="line" id="L2157">            } <span class="tok-kw">else</span> <span class="tok-kw">if</span> (mem.startsWith(<span class="tok-type">u8</span>, tok, <span class="tok-str">&quot;-D&quot;</span>)) {</span>
<span class="line" id="L2158">                <span class="tok-kw">try</span> zig_args.append(tok);</span>
<span class="line" id="L2159">            } <span class="tok-kw">else</span> <span class="tok-kw">if</span> (self.builder.verbose) {</span>
<span class="line" id="L2160">                log.warn(<span class="tok-str">&quot;Ignoring pkg-config flag '{s}'&quot;</span>, .{tok});</span>
<span class="line" id="L2161">            }</span>
<span class="line" id="L2162">        }</span>
<span class="line" id="L2163"></span>
<span class="line" id="L2164">        <span class="tok-kw">return</span> zig_args.toOwnedSlice();</span>
<span class="line" id="L2165">    }</span>
<span class="line" id="L2166"></span>
<span class="line" id="L2167">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">linkSystemLibrary</span>(self: *LibExeObjStep, name: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) <span class="tok-type">void</span> {</span>
<span class="line" id="L2168">        self.linkSystemLibraryInner(name, .{});</span>
<span class="line" id="L2169">    }</span>
<span class="line" id="L2170"></span>
<span class="line" id="L2171">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">linkSystemLibraryNeeded</span>(self: *LibExeObjStep, name: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) <span class="tok-type">void</span> {</span>
<span class="line" id="L2172">        self.linkSystemLibraryInner(name, .{ .needed = <span class="tok-null">true</span> });</span>
<span class="line" id="L2173">    }</span>
<span class="line" id="L2174"></span>
<span class="line" id="L2175">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">linkSystemLibraryWeak</span>(self: *LibExeObjStep, name: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) <span class="tok-type">void</span> {</span>
<span class="line" id="L2176">        self.linkSystemLibraryInner(name, .{ .weak = <span class="tok-null">true</span> });</span>
<span class="line" id="L2177">    }</span>
<span class="line" id="L2178"></span>
<span class="line" id="L2179">    <span class="tok-kw">fn</span> <span class="tok-fn">linkSystemLibraryInner</span>(self: *LibExeObjStep, name: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>, opts: <span class="tok-kw">struct</span> {</span>
<span class="line" id="L2180">        needed: <span class="tok-type">bool</span> = <span class="tok-null">false</span>,</span>
<span class="line" id="L2181">        weak: <span class="tok-type">bool</span> = <span class="tok-null">false</span>,</span>
<span class="line" id="L2182">    }) <span class="tok-type">void</span> {</span>
<span class="line" id="L2183">        <span class="tok-kw">if</span> (isLibCLibrary(name)) {</span>
<span class="line" id="L2184">            self.linkLibC();</span>
<span class="line" id="L2185">            <span class="tok-kw">return</span>;</span>
<span class="line" id="L2186">        }</span>
<span class="line" id="L2187">        <span class="tok-kw">if</span> (isLibCppLibrary(name)) {</span>
<span class="line" id="L2188">            self.linkLibCpp();</span>
<span class="line" id="L2189">            <span class="tok-kw">return</span>;</span>
<span class="line" id="L2190">        }</span>
<span class="line" id="L2191"></span>
<span class="line" id="L2192">        self.link_objects.append(.{</span>
<span class="line" id="L2193">            .system_lib = .{</span>
<span class="line" id="L2194">                .name = self.builder.dupe(name),</span>
<span class="line" id="L2195">                .needed = opts.needed,</span>
<span class="line" id="L2196">                .weak = opts.weak,</span>
<span class="line" id="L2197">                .use_pkg_config = .yes,</span>
<span class="line" id="L2198">            },</span>
<span class="line" id="L2199">        }) <span class="tok-kw">catch</span> <span class="tok-kw">unreachable</span>;</span>
<span class="line" id="L2200">    }</span>
<span class="line" id="L2201"></span>
<span class="line" id="L2202">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">setNamePrefix</span>(self: *LibExeObjStep, text: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) <span class="tok-type">void</span> {</span>
<span class="line" id="L2203">        assert(self.kind == .@&quot;test&quot; <span class="tok-kw">or</span> self.kind == .test_exe);</span>
<span class="line" id="L2204">        self.name_prefix = self.builder.dupe(text);</span>
<span class="line" id="L2205">    }</span>
<span class="line" id="L2206"></span>
<span class="line" id="L2207">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">setFilter</span>(self: *LibExeObjStep, text: ?[]<span class="tok-kw">const</span> <span class="tok-type">u8</span>) <span class="tok-type">void</span> {</span>
<span class="line" id="L2208">        assert(self.kind == .@&quot;test&quot; <span class="tok-kw">or</span> self.kind == .test_exe);</span>
<span class="line" id="L2209">        self.filter = <span class="tok-kw">if</span> (text) |t| self.builder.dupe(t) <span class="tok-kw">else</span> <span class="tok-null">null</span>;</span>
<span class="line" id="L2210">    }</span>
<span class="line" id="L2211"></span>
<span class="line" id="L2212">    <span class="tok-comment">/// Handy when you have many C/C++ source files and want them all to have the same flags.</span></span>
<span class="line" id="L2213">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">addCSourceFiles</span>(self: *LibExeObjStep, files: []<span class="tok-kw">const</span> []<span class="tok-kw">const</span> <span class="tok-type">u8</span>, flags: []<span class="tok-kw">const</span> []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) <span class="tok-type">void</span> {</span>
<span class="line" id="L2214">        <span class="tok-kw">const</span> c_source_files = self.builder.allocator.create(CSourceFiles) <span class="tok-kw">catch</span> <span class="tok-kw">unreachable</span>;</span>
<span class="line" id="L2215"></span>
<span class="line" id="L2216">        <span class="tok-kw">const</span> files_copy = self.builder.dupeStrings(files);</span>
<span class="line" id="L2217">        <span class="tok-kw">const</span> flags_copy = self.builder.dupeStrings(flags);</span>
<span class="line" id="L2218"></span>
<span class="line" id="L2219">        c_source_files.* = .{</span>
<span class="line" id="L2220">            .files = files_copy,</span>
<span class="line" id="L2221">            .flags = flags_copy,</span>
<span class="line" id="L2222">        };</span>
<span class="line" id="L2223">        self.link_objects.append(.{ .c_source_files = c_source_files }) <span class="tok-kw">catch</span> <span class="tok-kw">unreachable</span>;</span>
<span class="line" id="L2224">    }</span>
<span class="line" id="L2225"></span>
<span class="line" id="L2226">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">addCSourceFile</span>(self: *LibExeObjStep, file: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>, flags: []<span class="tok-kw">const</span> []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) <span class="tok-type">void</span> {</span>
<span class="line" id="L2227">        self.addCSourceFileSource(.{</span>
<span class="line" id="L2228">            .args = flags,</span>
<span class="line" id="L2229">            .source = .{ .path = file },</span>
<span class="line" id="L2230">        });</span>
<span class="line" id="L2231">    }</span>
<span class="line" id="L2232"></span>
<span class="line" id="L2233">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">addCSourceFileSource</span>(self: *LibExeObjStep, source: CSourceFile) <span class="tok-type">void</span> {</span>
<span class="line" id="L2234">        <span class="tok-kw">const</span> c_source_file = self.builder.allocator.create(CSourceFile) <span class="tok-kw">catch</span> <span class="tok-kw">unreachable</span>;</span>
<span class="line" id="L2235">        c_source_file.* = source.dupe(self.builder);</span>
<span class="line" id="L2236">        self.link_objects.append(.{ .c_source_file = c_source_file }) <span class="tok-kw">catch</span> <span class="tok-kw">unreachable</span>;</span>
<span class="line" id="L2237">        source.source.addStepDependencies(&amp;self.step);</span>
<span class="line" id="L2238">    }</span>
<span class="line" id="L2239"></span>
<span class="line" id="L2240">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">setVerboseLink</span>(self: *LibExeObjStep, value: <span class="tok-type">bool</span>) <span class="tok-type">void</span> {</span>
<span class="line" id="L2241">        self.verbose_link = value;</span>
<span class="line" id="L2242">    }</span>
<span class="line" id="L2243"></span>
<span class="line" id="L2244">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">setVerboseCC</span>(self: *LibExeObjStep, value: <span class="tok-type">bool</span>) <span class="tok-type">void</span> {</span>
<span class="line" id="L2245">        self.verbose_cc = value;</span>
<span class="line" id="L2246">    }</span>
<span class="line" id="L2247"></span>
<span class="line" id="L2248">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">setBuildMode</span>(self: *LibExeObjStep, mode: std.builtin.Mode) <span class="tok-type">void</span> {</span>
<span class="line" id="L2249">        self.build_mode = mode;</span>
<span class="line" id="L2250">    }</span>
<span class="line" id="L2251"></span>
<span class="line" id="L2252">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">overrideZigLibDir</span>(self: *LibExeObjStep, dir_path: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) <span class="tok-type">void</span> {</span>
<span class="line" id="L2253">        self.override_lib_dir = self.builder.dupePath(dir_path);</span>
<span class="line" id="L2254">    }</span>
<span class="line" id="L2255"></span>
<span class="line" id="L2256">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">setMainPkgPath</span>(self: *LibExeObjStep, dir_path: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) <span class="tok-type">void</span> {</span>
<span class="line" id="L2257">        self.main_pkg_path = self.builder.dupePath(dir_path);</span>
<span class="line" id="L2258">    }</span>
<span class="line" id="L2259"></span>
<span class="line" id="L2260">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">setLibCFile</span>(self: *LibExeObjStep, libc_file: ?FileSource) <span class="tok-type">void</span> {</span>
<span class="line" id="L2261">        self.libc_file = <span class="tok-kw">if</span> (libc_file) |f| f.dupe(self.builder) <span class="tok-kw">else</span> <span class="tok-null">null</span>;</span>
<span class="line" id="L2262">    }</span>
<span class="line" id="L2263"></span>
<span class="line" id="L2264">    <span class="tok-comment">/// Returns the generated executable, library or object file.</span></span>
<span class="line" id="L2265">    <span class="tok-comment">/// To run an executable built with zig build, use `run`, or create an install step and invoke it.</span></span>
<span class="line" id="L2266">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">getOutputSource</span>(self: *LibExeObjStep) FileSource {</span>
<span class="line" id="L2267">        <span class="tok-kw">return</span> FileSource{ .generated = &amp;self.output_path_source };</span>
<span class="line" id="L2268">    }</span>
<span class="line" id="L2269"></span>
<span class="line" id="L2270">    <span class="tok-comment">/// Returns the generated import library. This function can only be called for libraries.</span></span>
<span class="line" id="L2271">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">getOutputLibSource</span>(self: *LibExeObjStep) FileSource {</span>
<span class="line" id="L2272">        assert(self.kind == .lib);</span>
<span class="line" id="L2273">        <span class="tok-kw">return</span> FileSource{ .generated = &amp;self.output_lib_path_source };</span>
<span class="line" id="L2274">    }</span>
<span class="line" id="L2275"></span>
<span class="line" id="L2276">    <span class="tok-comment">/// Returns the generated header file.</span></span>
<span class="line" id="L2277">    <span class="tok-comment">/// This function can only be called for libraries or object files which have `emit_h` set.</span></span>
<span class="line" id="L2278">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">getOutputHSource</span>(self: *LibExeObjStep) FileSource {</span>
<span class="line" id="L2279">        assert(self.kind != .exe <span class="tok-kw">and</span> self.kind != .test_exe <span class="tok-kw">and</span> self.kind != .@&quot;test&quot;);</span>
<span class="line" id="L2280">        assert(self.emit_h);</span>
<span class="line" id="L2281">        <span class="tok-kw">return</span> FileSource{ .generated = &amp;self.output_h_path_source };</span>
<span class="line" id="L2282">    }</span>
<span class="line" id="L2283"></span>
<span class="line" id="L2284">    <span class="tok-comment">/// Returns the generated PDB file. This function can only be called for Windows and UEFI.</span></span>
<span class="line" id="L2285">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">getOutputPdbSource</span>(self: *LibExeObjStep) FileSource {</span>
<span class="line" id="L2286">        <span class="tok-comment">// TODO: Is this right? Isn't PDB for *any* PE/COFF file?</span>
</span>
<span class="line" id="L2287">        assert(self.target.isWindows() <span class="tok-kw">or</span> self.target.isUefi());</span>
<span class="line" id="L2288">        <span class="tok-kw">return</span> FileSource{ .generated = &amp;self.output_pdb_path_source };</span>
<span class="line" id="L2289">    }</span>
<span class="line" id="L2290"></span>
<span class="line" id="L2291">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">addAssemblyFile</span>(self: *LibExeObjStep, path: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) <span class="tok-type">void</span> {</span>
<span class="line" id="L2292">        self.link_objects.append(.{</span>
<span class="line" id="L2293">            .assembly_file = .{ .path = self.builder.dupe(path) },</span>
<span class="line" id="L2294">        }) <span class="tok-kw">catch</span> <span class="tok-kw">unreachable</span>;</span>
<span class="line" id="L2295">    }</span>
<span class="line" id="L2296"></span>
<span class="line" id="L2297">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">addAssemblyFileSource</span>(self: *LibExeObjStep, source: FileSource) <span class="tok-type">void</span> {</span>
<span class="line" id="L2298">        <span class="tok-kw">const</span> source_duped = source.dupe(self.builder);</span>
<span class="line" id="L2299">        self.link_objects.append(.{ .assembly_file = source_duped }) <span class="tok-kw">catch</span> <span class="tok-kw">unreachable</span>;</span>
<span class="line" id="L2300">        source_duped.addStepDependencies(&amp;self.step);</span>
<span class="line" id="L2301">    }</span>
<span class="line" id="L2302"></span>
<span class="line" id="L2303">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">addObjectFile</span>(self: *LibExeObjStep, source_file: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) <span class="tok-type">void</span> {</span>
<span class="line" id="L2304">        self.addObjectFileSource(.{ .path = source_file });</span>
<span class="line" id="L2305">    }</span>
<span class="line" id="L2306"></span>
<span class="line" id="L2307">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">addObjectFileSource</span>(self: *LibExeObjStep, source: FileSource) <span class="tok-type">void</span> {</span>
<span class="line" id="L2308">        self.link_objects.append(.{ .static_path = source.dupe(self.builder) }) <span class="tok-kw">catch</span> <span class="tok-kw">unreachable</span>;</span>
<span class="line" id="L2309">        source.addStepDependencies(&amp;self.step);</span>
<span class="line" id="L2310">    }</span>
<span class="line" id="L2311"></span>
<span class="line" id="L2312">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">addObject</span>(self: *LibExeObjStep, obj: *LibExeObjStep) <span class="tok-type">void</span> {</span>
<span class="line" id="L2313">        assert(obj.kind == .obj);</span>
<span class="line" id="L2314">        self.linkLibraryOrObject(obj);</span>
<span class="line" id="L2315">    }</span>
<span class="line" id="L2316"></span>
<span class="line" id="L2317">    <span class="tok-comment">/// TODO deprecated, use `addSystemIncludePath`.</span></span>
<span class="line" id="L2318">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">addSystemIncludeDir</span>(self: *LibExeObjStep, path: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) <span class="tok-type">void</span> {</span>
<span class="line" id="L2319">        self.addSystemIncludePath(path);</span>
<span class="line" id="L2320">    }</span>
<span class="line" id="L2321"></span>
<span class="line" id="L2322">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">addSystemIncludePath</span>(self: *LibExeObjStep, path: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) <span class="tok-type">void</span> {</span>
<span class="line" id="L2323">        self.include_dirs.append(IncludeDir{ .raw_path_system = self.builder.dupe(path) }) <span class="tok-kw">catch</span> <span class="tok-kw">unreachable</span>;</span>
<span class="line" id="L2324">    }</span>
<span class="line" id="L2325"></span>
<span class="line" id="L2326">    <span class="tok-comment">/// TODO deprecated, use `addIncludePath`.</span></span>
<span class="line" id="L2327">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">addIncludeDir</span>(self: *LibExeObjStep, path: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) <span class="tok-type">void</span> {</span>
<span class="line" id="L2328">        self.addIncludePath(path);</span>
<span class="line" id="L2329">    }</span>
<span class="line" id="L2330"></span>
<span class="line" id="L2331">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">addIncludePath</span>(self: *LibExeObjStep, path: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) <span class="tok-type">void</span> {</span>
<span class="line" id="L2332">        self.include_dirs.append(IncludeDir{ .raw_path = self.builder.dupe(path) }) <span class="tok-kw">catch</span> <span class="tok-kw">unreachable</span>;</span>
<span class="line" id="L2333">    }</span>
<span class="line" id="L2334"></span>
<span class="line" id="L2335">    <span class="tok-comment">/// TODO deprecated, use `addLibraryPath`.</span></span>
<span class="line" id="L2336">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">addLibPath</span>(self: *LibExeObjStep, path: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) <span class="tok-type">void</span> {</span>
<span class="line" id="L2337">        self.addLibraryPath(path);</span>
<span class="line" id="L2338">    }</span>
<span class="line" id="L2339"></span>
<span class="line" id="L2340">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">addLibraryPath</span>(self: *LibExeObjStep, path: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) <span class="tok-type">void</span> {</span>
<span class="line" id="L2341">        self.lib_paths.append(self.builder.dupe(path)) <span class="tok-kw">catch</span> <span class="tok-kw">unreachable</span>;</span>
<span class="line" id="L2342">    }</span>
<span class="line" id="L2343"></span>
<span class="line" id="L2344">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">addRPath</span>(self: *LibExeObjStep, path: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) <span class="tok-type">void</span> {</span>
<span class="line" id="L2345">        self.rpaths.append(self.builder.dupe(path)) <span class="tok-kw">catch</span> <span class="tok-kw">unreachable</span>;</span>
<span class="line" id="L2346">    }</span>
<span class="line" id="L2347"></span>
<span class="line" id="L2348">    <span class="tok-comment">/// TODO deprecated, use `addFrameworkPath`.</span></span>
<span class="line" id="L2349">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">addFrameworkDir</span>(self: *LibExeObjStep, dir_path: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) <span class="tok-type">void</span> {</span>
<span class="line" id="L2350">        self.addFrameworkPath(dir_path);</span>
<span class="line" id="L2351">    }</span>
<span class="line" id="L2352"></span>
<span class="line" id="L2353">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">addFrameworkPath</span>(self: *LibExeObjStep, dir_path: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) <span class="tok-type">void</span> {</span>
<span class="line" id="L2354">        self.framework_dirs.append(self.builder.dupe(dir_path)) <span class="tok-kw">catch</span> <span class="tok-kw">unreachable</span>;</span>
<span class="line" id="L2355">    }</span>
<span class="line" id="L2356"></span>
<span class="line" id="L2357">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">addPackage</span>(self: *LibExeObjStep, package: Pkg) <span class="tok-type">void</span> {</span>
<span class="line" id="L2358">        self.packages.append(self.builder.dupePkg(package)) <span class="tok-kw">catch</span> <span class="tok-kw">unreachable</span>;</span>
<span class="line" id="L2359">        self.addRecursiveBuildDeps(package);</span>
<span class="line" id="L2360">    }</span>
<span class="line" id="L2361"></span>
<span class="line" id="L2362">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">addOptions</span>(self: *LibExeObjStep, package_name: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>, options: *OptionsStep) <span class="tok-type">void</span> {</span>
<span class="line" id="L2363">        self.addPackage(options.getPackage(package_name));</span>
<span class="line" id="L2364">    }</span>
<span class="line" id="L2365"></span>
<span class="line" id="L2366">    <span class="tok-kw">fn</span> <span class="tok-fn">addRecursiveBuildDeps</span>(self: *LibExeObjStep, package: Pkg) <span class="tok-type">void</span> {</span>
<span class="line" id="L2367">        package.source.addStepDependencies(&amp;self.step);</span>
<span class="line" id="L2368">        <span class="tok-kw">if</span> (package.dependencies) |deps| {</span>
<span class="line" id="L2369">            <span class="tok-kw">for</span> (deps) |dep| {</span>
<span class="line" id="L2370">                self.addRecursiveBuildDeps(dep);</span>
<span class="line" id="L2371">            }</span>
<span class="line" id="L2372">        }</span>
<span class="line" id="L2373">    }</span>
<span class="line" id="L2374"></span>
<span class="line" id="L2375">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">addPackagePath</span>(self: *LibExeObjStep, name: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>, pkg_index_path: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) <span class="tok-type">void</span> {</span>
<span class="line" id="L2376">        self.addPackage(Pkg{</span>
<span class="line" id="L2377">            .name = self.builder.dupe(name),</span>
<span class="line" id="L2378">            .source = .{ .path = self.builder.dupe(pkg_index_path) },</span>
<span class="line" id="L2379">        });</span>
<span class="line" id="L2380">    }</span>
<span class="line" id="L2381"></span>
<span class="line" id="L2382">    <span class="tok-comment">/// If Vcpkg was found on the system, it will be added to include and lib</span></span>
<span class="line" id="L2383">    <span class="tok-comment">/// paths for the specified target.</span></span>
<span class="line" id="L2384">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">addVcpkgPaths</span>(self: *LibExeObjStep, linkage: LibExeObjStep.Linkage) !<span class="tok-type">void</span> {</span>
<span class="line" id="L2385">        <span class="tok-comment">// Ideally in the Unattempted case we would call the function recursively</span>
</span>
<span class="line" id="L2386">        <span class="tok-comment">// after findVcpkgRoot and have only one switch statement, but the compiler</span>
</span>
<span class="line" id="L2387">        <span class="tok-comment">// cannot resolve the error set.</span>
</span>
<span class="line" id="L2388">        <span class="tok-kw">switch</span> (self.builder.vcpkg_root) {</span>
<span class="line" id="L2389">            .unattempted =&gt; {</span>
<span class="line" id="L2390">                self.builder.vcpkg_root = <span class="tok-kw">if</span> (<span class="tok-kw">try</span> findVcpkgRoot(self.builder.allocator)) |root|</span>
<span class="line" id="L2391">                    VcpkgRoot{ .found = root }</span>
<span class="line" id="L2392">                <span class="tok-kw">else</span></span>
<span class="line" id="L2393">                    .not_found;</span>
<span class="line" id="L2394">            },</span>
<span class="line" id="L2395">            .not_found =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.VcpkgNotFound,</span>
<span class="line" id="L2396">            .found =&gt; {},</span>
<span class="line" id="L2397">        }</span>
<span class="line" id="L2398"></span>
<span class="line" id="L2399">        <span class="tok-kw">switch</span> (self.builder.vcpkg_root) {</span>
<span class="line" id="L2400">            .unattempted =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L2401">            .not_found =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.VcpkgNotFound,</span>
<span class="line" id="L2402">            .found =&gt; |root| {</span>
<span class="line" id="L2403">                <span class="tok-kw">const</span> allocator = self.builder.allocator;</span>
<span class="line" id="L2404">                <span class="tok-kw">const</span> triplet = <span class="tok-kw">try</span> self.target.vcpkgTriplet(allocator, <span class="tok-kw">if</span> (linkage == .static) .Static <span class="tok-kw">else</span> .Dynamic);</span>
<span class="line" id="L2405">                <span class="tok-kw">defer</span> self.builder.allocator.free(triplet);</span>
<span class="line" id="L2406"></span>
<span class="line" id="L2407">                <span class="tok-kw">const</span> include_path = self.builder.pathJoin(&amp;.{ root, <span class="tok-str">&quot;installed&quot;</span>, triplet, <span class="tok-str">&quot;include&quot;</span> });</span>
<span class="line" id="L2408">                <span class="tok-kw">errdefer</span> allocator.free(include_path);</span>
<span class="line" id="L2409">                <span class="tok-kw">try</span> self.include_dirs.append(IncludeDir{ .raw_path = include_path });</span>
<span class="line" id="L2410"></span>
<span class="line" id="L2411">                <span class="tok-kw">const</span> lib_path = self.builder.pathJoin(&amp;.{ root, <span class="tok-str">&quot;installed&quot;</span>, triplet, <span class="tok-str">&quot;lib&quot;</span> });</span>
<span class="line" id="L2412">                <span class="tok-kw">try</span> self.lib_paths.append(lib_path);</span>
<span class="line" id="L2413"></span>
<span class="line" id="L2414">                self.vcpkg_bin_path = self.builder.pathJoin(&amp;.{ root, <span class="tok-str">&quot;installed&quot;</span>, triplet, <span class="tok-str">&quot;bin&quot;</span> });</span>
<span class="line" id="L2415">            },</span>
<span class="line" id="L2416">        }</span>
<span class="line" id="L2417">    }</span>
<span class="line" id="L2418"></span>
<span class="line" id="L2419">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">setExecCmd</span>(self: *LibExeObjStep, args: []<span class="tok-kw">const</span> ?[]<span class="tok-kw">const</span> <span class="tok-type">u8</span>) <span class="tok-type">void</span> {</span>
<span class="line" id="L2420">        assert(self.kind == .@&quot;test&quot;);</span>
<span class="line" id="L2421">        <span class="tok-kw">const</span> duped_args = self.builder.allocator.alloc(?[]<span class="tok-type">u8</span>, args.len) <span class="tok-kw">catch</span> <span class="tok-kw">unreachable</span>;</span>
<span class="line" id="L2422">        <span class="tok-kw">for</span> (args) |arg, i| {</span>
<span class="line" id="L2423">            duped_args[i] = <span class="tok-kw">if</span> (arg) |a| self.builder.dupe(a) <span class="tok-kw">else</span> <span class="tok-null">null</span>;</span>
<span class="line" id="L2424">        }</span>
<span class="line" id="L2425">        self.exec_cmd_args = duped_args;</span>
<span class="line" id="L2426">    }</span>
<span class="line" id="L2427"></span>
<span class="line" id="L2428">    <span class="tok-kw">fn</span> <span class="tok-fn">linkLibraryOrObject</span>(self: *LibExeObjStep, other: *LibExeObjStep) <span class="tok-type">void</span> {</span>
<span class="line" id="L2429">        self.step.dependOn(&amp;other.step);</span>
<span class="line" id="L2430">        self.link_objects.append(.{ .other_step = other }) <span class="tok-kw">catch</span> <span class="tok-kw">unreachable</span>;</span>
<span class="line" id="L2431">        self.include_dirs.append(.{ .other_step = other }) <span class="tok-kw">catch</span> <span class="tok-kw">unreachable</span>;</span>
<span class="line" id="L2432">    }</span>
<span class="line" id="L2433"></span>
<span class="line" id="L2434">    <span class="tok-kw">fn</span> <span class="tok-fn">makePackageCmd</span>(self: *LibExeObjStep, pkg: Pkg, zig_args: *ArrayList([]<span class="tok-kw">const</span> <span class="tok-type">u8</span>)) <span class="tok-kw">error</span>{OutOfMemory}!<span class="tok-type">void</span> {</span>
<span class="line" id="L2435">        <span class="tok-kw">const</span> builder = self.builder;</span>
<span class="line" id="L2436"></span>
<span class="line" id="L2437">        <span class="tok-kw">try</span> zig_args.append(<span class="tok-str">&quot;--pkg-begin&quot;</span>);</span>
<span class="line" id="L2438">        <span class="tok-kw">try</span> zig_args.append(pkg.name);</span>
<span class="line" id="L2439">        <span class="tok-kw">try</span> zig_args.append(builder.pathFromRoot(pkg.source.getPath(self.builder)));</span>
<span class="line" id="L2440"></span>
<span class="line" id="L2441">        <span class="tok-kw">if</span> (pkg.dependencies) |dependencies| {</span>
<span class="line" id="L2442">            <span class="tok-kw">for</span> (dependencies) |sub_pkg| {</span>
<span class="line" id="L2443">                <span class="tok-kw">try</span> self.makePackageCmd(sub_pkg, zig_args);</span>
<span class="line" id="L2444">            }</span>
<span class="line" id="L2445">        }</span>
<span class="line" id="L2446"></span>
<span class="line" id="L2447">        <span class="tok-kw">try</span> zig_args.append(<span class="tok-str">&quot;--pkg-end&quot;</span>);</span>
<span class="line" id="L2448">    }</span>
<span class="line" id="L2449"></span>
<span class="line" id="L2450">    <span class="tok-kw">fn</span> <span class="tok-fn">make</span>(step: *Step) !<span class="tok-type">void</span> {</span>
<span class="line" id="L2451">        <span class="tok-kw">const</span> self = <span class="tok-builtin">@fieldParentPtr</span>(LibExeObjStep, <span class="tok-str">&quot;step&quot;</span>, step);</span>
<span class="line" id="L2452">        <span class="tok-kw">const</span> builder = self.builder;</span>
<span class="line" id="L2453"></span>
<span class="line" id="L2454">        <span class="tok-kw">if</span> (self.root_src == <span class="tok-null">null</span> <span class="tok-kw">and</span> self.link_objects.items.len == <span class="tok-number">0</span>) {</span>
<span class="line" id="L2455">            log.err(<span class="tok-str">&quot;{s}: linker needs 1 or more objects to link&quot;</span>, .{self.step.name});</span>
<span class="line" id="L2456">            <span class="tok-kw">return</span> <span class="tok-kw">error</span>.NeedAnObject;</span>
<span class="line" id="L2457">        }</span>
<span class="line" id="L2458"></span>
<span class="line" id="L2459">        <span class="tok-kw">var</span> zig_args = ArrayList([]<span class="tok-kw">const</span> <span class="tok-type">u8</span>).init(builder.allocator);</span>
<span class="line" id="L2460">        <span class="tok-kw">defer</span> zig_args.deinit();</span>
<span class="line" id="L2461"></span>
<span class="line" id="L2462">        zig_args.append(builder.zig_exe) <span class="tok-kw">catch</span> <span class="tok-kw">unreachable</span>;</span>
<span class="line" id="L2463"></span>
<span class="line" id="L2464">        <span class="tok-kw">const</span> cmd = <span class="tok-kw">switch</span> (self.kind) {</span>
<span class="line" id="L2465">            .lib =&gt; <span class="tok-str">&quot;build-lib&quot;</span>,</span>
<span class="line" id="L2466">            .exe =&gt; <span class="tok-str">&quot;build-exe&quot;</span>,</span>
<span class="line" id="L2467">            .obj =&gt; <span class="tok-str">&quot;build-obj&quot;</span>,</span>
<span class="line" id="L2468">            .@&quot;test&quot; =&gt; <span class="tok-str">&quot;test&quot;</span>,</span>
<span class="line" id="L2469">            .test_exe =&gt; <span class="tok-str">&quot;test&quot;</span>,</span>
<span class="line" id="L2470">        };</span>
<span class="line" id="L2471">        zig_args.append(cmd) <span class="tok-kw">catch</span> <span class="tok-kw">unreachable</span>;</span>
<span class="line" id="L2472"></span>
<span class="line" id="L2473">        <span class="tok-kw">if</span> (builder.color != .auto) {</span>
<span class="line" id="L2474">            <span class="tok-kw">try</span> zig_args.append(<span class="tok-str">&quot;--color&quot;</span>);</span>
<span class="line" id="L2475">            <span class="tok-kw">try</span> zig_args.append(<span class="tok-builtin">@tagName</span>(builder.color));</span>
<span class="line" id="L2476">        }</span>
<span class="line" id="L2477"></span>
<span class="line" id="L2478">        <span class="tok-kw">if</span> (self.use_stage1) |stage1| {</span>
<span class="line" id="L2479">            <span class="tok-kw">if</span> (stage1) {</span>
<span class="line" id="L2480">                <span class="tok-kw">try</span> zig_args.append(<span class="tok-str">&quot;-fstage1&quot;</span>);</span>
<span class="line" id="L2481">            } <span class="tok-kw">else</span> {</span>
<span class="line" id="L2482">                <span class="tok-kw">try</span> zig_args.append(<span class="tok-str">&quot;-fno-stage1&quot;</span>);</span>
<span class="line" id="L2483">            }</span>
<span class="line" id="L2484">        } <span class="tok-kw">else</span> <span class="tok-kw">if</span> (builder.use_stage1) |stage1| {</span>
<span class="line" id="L2485">            <span class="tok-kw">if</span> (stage1) {</span>
<span class="line" id="L2486">                <span class="tok-kw">try</span> zig_args.append(<span class="tok-str">&quot;-fstage1&quot;</span>);</span>
<span class="line" id="L2487">            } <span class="tok-kw">else</span> {</span>
<span class="line" id="L2488">                <span class="tok-kw">try</span> zig_args.append(<span class="tok-str">&quot;-fno-stage1&quot;</span>);</span>
<span class="line" id="L2489">            }</span>
<span class="line" id="L2490">        }</span>
<span class="line" id="L2491"></span>
<span class="line" id="L2492">        <span class="tok-kw">if</span> (self.use_llvm) |use_llvm| {</span>
<span class="line" id="L2493">            <span class="tok-kw">if</span> (use_llvm) {</span>
<span class="line" id="L2494">                <span class="tok-kw">try</span> zig_args.append(<span class="tok-str">&quot;-fLLVM&quot;</span>);</span>
<span class="line" id="L2495">            } <span class="tok-kw">else</span> {</span>
<span class="line" id="L2496">                <span class="tok-kw">try</span> zig_args.append(<span class="tok-str">&quot;-fno-LLVM&quot;</span>);</span>
<span class="line" id="L2497">            }</span>
<span class="line" id="L2498">        }</span>
<span class="line" id="L2499"></span>
<span class="line" id="L2500">        <span class="tok-kw">if</span> (self.use_lld) |use_lld| {</span>
<span class="line" id="L2501">            <span class="tok-kw">if</span> (use_lld) {</span>
<span class="line" id="L2502">                <span class="tok-kw">try</span> zig_args.append(<span class="tok-str">&quot;-fLLD&quot;</span>);</span>
<span class="line" id="L2503">            } <span class="tok-kw">else</span> {</span>
<span class="line" id="L2504">                <span class="tok-kw">try</span> zig_args.append(<span class="tok-str">&quot;-fno-LLD&quot;</span>);</span>
<span class="line" id="L2505">            }</span>
<span class="line" id="L2506">        }</span>
<span class="line" id="L2507"></span>
<span class="line" id="L2508">        <span class="tok-kw">if</span> (self.ofmt) |ofmt| {</span>
<span class="line" id="L2509">            <span class="tok-kw">try</span> zig_args.append(<span class="tok-kw">try</span> std.fmt.allocPrint(builder.allocator, <span class="tok-str">&quot;-ofmt={s}&quot;</span>, .{<span class="tok-builtin">@tagName</span>(ofmt)}));</span>
<span class="line" id="L2510">        }</span>
<span class="line" id="L2511"></span>
<span class="line" id="L2512">        <span class="tok-kw">if</span> (self.entry_symbol_name) |entry| {</span>
<span class="line" id="L2513">            <span class="tok-kw">try</span> zig_args.append(<span class="tok-str">&quot;--entry&quot;</span>);</span>
<span class="line" id="L2514">            <span class="tok-kw">try</span> zig_args.append(entry);</span>
<span class="line" id="L2515">        }</span>
<span class="line" id="L2516"></span>
<span class="line" id="L2517">        <span class="tok-kw">if</span> (self.stack_size) |stack_size| {</span>
<span class="line" id="L2518">            <span class="tok-kw">try</span> zig_args.append(<span class="tok-str">&quot;--stack&quot;</span>);</span>
<span class="line" id="L2519">            <span class="tok-kw">try</span> zig_args.append(<span class="tok-kw">try</span> std.fmt.allocPrint(builder.allocator, <span class="tok-str">&quot;{}&quot;</span>, .{stack_size}));</span>
<span class="line" id="L2520">        }</span>
<span class="line" id="L2521"></span>
<span class="line" id="L2522">        <span class="tok-kw">if</span> (self.root_src) |root_src| <span class="tok-kw">try</span> zig_args.append(root_src.getPath(builder));</span>
<span class="line" id="L2523"></span>
<span class="line" id="L2524">        <span class="tok-kw">var</span> prev_has_extra_flags = <span class="tok-null">false</span>;</span>
<span class="line" id="L2525"></span>
<span class="line" id="L2526">        <span class="tok-comment">// Resolve transitive dependencies</span>
</span>
<span class="line" id="L2527">        {</span>
<span class="line" id="L2528">            <span class="tok-kw">var</span> transitive_dependencies = std.ArrayList(LinkObject).init(builder.allocator);</span>
<span class="line" id="L2529">            <span class="tok-kw">defer</span> transitive_dependencies.deinit();</span>
<span class="line" id="L2530"></span>
<span class="line" id="L2531">            <span class="tok-kw">for</span> (self.link_objects.items) |link_object| {</span>
<span class="line" id="L2532">                <span class="tok-kw">switch</span> (link_object) {</span>
<span class="line" id="L2533">                    .other_step =&gt; |other| {</span>
<span class="line" id="L2534">                        <span class="tok-comment">// Inherit dependency on system libraries</span>
</span>
<span class="line" id="L2535">                        <span class="tok-kw">for</span> (other.link_objects.items) |other_link_object| {</span>
<span class="line" id="L2536">                            <span class="tok-kw">switch</span> (other_link_object) {</span>
<span class="line" id="L2537">                                .system_lib =&gt; <span class="tok-kw">try</span> transitive_dependencies.append(other_link_object),</span>
<span class="line" id="L2538">                                <span class="tok-kw">else</span> =&gt; <span class="tok-kw">continue</span>,</span>
<span class="line" id="L2539">                            }</span>
<span class="line" id="L2540">                        }</span>
<span class="line" id="L2541"></span>
<span class="line" id="L2542">                        <span class="tok-comment">// Inherit dependencies on darwin frameworks</span>
</span>
<span class="line" id="L2543">                        <span class="tok-kw">if</span> (!other.isDynamicLibrary()) {</span>
<span class="line" id="L2544">                            <span class="tok-kw">var</span> it = other.frameworks.iterator();</span>
<span class="line" id="L2545">                            <span class="tok-kw">while</span> (it.next()) |framework| {</span>
<span class="line" id="L2546">                                self.frameworks.put(framework.key_ptr.*, framework.value_ptr.*) <span class="tok-kw">catch</span> <span class="tok-kw">unreachable</span>;</span>
<span class="line" id="L2547">                            }</span>
<span class="line" id="L2548">                        }</span>
<span class="line" id="L2549">                    },</span>
<span class="line" id="L2550">                    <span class="tok-kw">else</span> =&gt; <span class="tok-kw">continue</span>,</span>
<span class="line" id="L2551">                }</span>
<span class="line" id="L2552">            }</span>
<span class="line" id="L2553"></span>
<span class="line" id="L2554">            <span class="tok-kw">try</span> self.link_objects.appendSlice(transitive_dependencies.items);</span>
<span class="line" id="L2555">        }</span>
<span class="line" id="L2556"></span>
<span class="line" id="L2557">        <span class="tok-kw">for</span> (self.link_objects.items) |link_object| {</span>
<span class="line" id="L2558">            <span class="tok-kw">switch</span> (link_object) {</span>
<span class="line" id="L2559">                .static_path =&gt; |static_path| <span class="tok-kw">try</span> zig_args.append(static_path.getPath(builder)),</span>
<span class="line" id="L2560"></span>
<span class="line" id="L2561">                .other_step =&gt; |other| <span class="tok-kw">switch</span> (other.kind) {</span>
<span class="line" id="L2562">                    .exe =&gt; <span class="tok-builtin">@panic</span>(<span class="tok-str">&quot;Cannot link with an executable build artifact&quot;</span>),</span>
<span class="line" id="L2563">                    .test_exe =&gt; <span class="tok-builtin">@panic</span>(<span class="tok-str">&quot;Cannot link with an executable build artifact&quot;</span>),</span>
<span class="line" id="L2564">                    .@&quot;test&quot; =&gt; <span class="tok-builtin">@panic</span>(<span class="tok-str">&quot;Cannot link with a test&quot;</span>),</span>
<span class="line" id="L2565">                    .obj =&gt; {</span>
<span class="line" id="L2566">                        <span class="tok-kw">try</span> zig_args.append(other.getOutputSource().getPath(builder));</span>
<span class="line" id="L2567">                    },</span>
<span class="line" id="L2568">                    .lib =&gt; {</span>
<span class="line" id="L2569">                        <span class="tok-kw">const</span> full_path_lib = other.getOutputLibSource().getPath(builder);</span>
<span class="line" id="L2570">                        <span class="tok-kw">try</span> zig_args.append(full_path_lib);</span>
<span class="line" id="L2571"></span>
<span class="line" id="L2572">                        <span class="tok-kw">if</span> (other.linkage != <span class="tok-null">null</span> <span class="tok-kw">and</span> other.linkage.? == .dynamic <span class="tok-kw">and</span> !self.target.isWindows()) {</span>
<span class="line" id="L2573">                            <span class="tok-kw">if</span> (fs.path.dirname(full_path_lib)) |dirname| {</span>
<span class="line" id="L2574">                                <span class="tok-kw">try</span> zig_args.append(<span class="tok-str">&quot;-rpath&quot;</span>);</span>
<span class="line" id="L2575">                                <span class="tok-kw">try</span> zig_args.append(dirname);</span>
<span class="line" id="L2576">                            }</span>
<span class="line" id="L2577">                        }</span>
<span class="line" id="L2578">                    },</span>
<span class="line" id="L2579">                },</span>
<span class="line" id="L2580"></span>
<span class="line" id="L2581">                .system_lib =&gt; |system_lib| {</span>
<span class="line" id="L2582">                    <span class="tok-kw">const</span> prefix: []<span class="tok-kw">const</span> <span class="tok-type">u8</span> = prefix: {</span>
<span class="line" id="L2583">                        <span class="tok-kw">if</span> (system_lib.needed) <span class="tok-kw">break</span> :prefix <span class="tok-str">&quot;-needed-l&quot;</span>;</span>
<span class="line" id="L2584">                        <span class="tok-kw">if</span> (system_lib.weak) {</span>
<span class="line" id="L2585">                            <span class="tok-kw">if</span> (self.target.isDarwin()) <span class="tok-kw">break</span> :prefix <span class="tok-str">&quot;-weak-l&quot;</span>;</span>
<span class="line" id="L2586">                            log.warn(<span class="tok-str">&quot;Weak library import used for a non-darwin target, this will be converted to normally library import `-lname`&quot;</span>, .{});</span>
<span class="line" id="L2587">                        }</span>
<span class="line" id="L2588">                        <span class="tok-kw">break</span> :prefix <span class="tok-str">&quot;-l&quot;</span>;</span>
<span class="line" id="L2589">                    };</span>
<span class="line" id="L2590">                    <span class="tok-kw">switch</span> (system_lib.use_pkg_config) {</span>
<span class="line" id="L2591">                        .no =&gt; <span class="tok-kw">try</span> zig_args.append(builder.fmt(<span class="tok-str">&quot;{s}{s}&quot;</span>, .{ prefix, system_lib.name })),</span>
<span class="line" id="L2592">                        .yes, .force =&gt; {</span>
<span class="line" id="L2593">                            <span class="tok-kw">if</span> (self.runPkgConfig(system_lib.name)) |args| {</span>
<span class="line" id="L2594">                                <span class="tok-kw">try</span> zig_args.appendSlice(args);</span>
<span class="line" id="L2595">                            } <span class="tok-kw">else</span> |err| <span class="tok-kw">switch</span> (err) {</span>
<span class="line" id="L2596">                                <span class="tok-kw">error</span>.PkgConfigInvalidOutput,</span>
<span class="line" id="L2597">                                <span class="tok-kw">error</span>.PkgConfigCrashed,</span>
<span class="line" id="L2598">                                <span class="tok-kw">error</span>.PkgConfigFailed,</span>
<span class="line" id="L2599">                                <span class="tok-kw">error</span>.PkgConfigNotInstalled,</span>
<span class="line" id="L2600">                                <span class="tok-kw">error</span>.PackageNotFound,</span>
<span class="line" id="L2601">                                =&gt; <span class="tok-kw">switch</span> (system_lib.use_pkg_config) {</span>
<span class="line" id="L2602">                                    .yes =&gt; {</span>
<span class="line" id="L2603">                                        <span class="tok-comment">// pkg-config failed, so fall back to linking the library</span>
</span>
<span class="line" id="L2604">                                        <span class="tok-comment">// by name directly.</span>
</span>
<span class="line" id="L2605">                                        <span class="tok-kw">try</span> zig_args.append(builder.fmt(<span class="tok-str">&quot;{s}{s}&quot;</span>, .{</span>
<span class="line" id="L2606">                                            prefix,</span>
<span class="line" id="L2607">                                            system_lib.name,</span>
<span class="line" id="L2608">                                        }));</span>
<span class="line" id="L2609">                                    },</span>
<span class="line" id="L2610">                                    .force =&gt; {</span>
<span class="line" id="L2611">                                        panic(<span class="tok-str">&quot;pkg-config failed for library {s}&quot;</span>, .{system_lib.name});</span>
<span class="line" id="L2612">                                    },</span>
<span class="line" id="L2613">                                    .no =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L2614">                                },</span>
<span class="line" id="L2615"></span>
<span class="line" id="L2616">                                <span class="tok-kw">else</span> =&gt; |e| <span class="tok-kw">return</span> e,</span>
<span class="line" id="L2617">                            }</span>
<span class="line" id="L2618">                        },</span>
<span class="line" id="L2619">                    }</span>
<span class="line" id="L2620">                },</span>
<span class="line" id="L2621"></span>
<span class="line" id="L2622">                .assembly_file =&gt; |asm_file| {</span>
<span class="line" id="L2623">                    <span class="tok-kw">if</span> (prev_has_extra_flags) {</span>
<span class="line" id="L2624">                        <span class="tok-kw">try</span> zig_args.append(<span class="tok-str">&quot;-extra-cflags&quot;</span>);</span>
<span class="line" id="L2625">                        <span class="tok-kw">try</span> zig_args.append(<span class="tok-str">&quot;--&quot;</span>);</span>
<span class="line" id="L2626">                        prev_has_extra_flags = <span class="tok-null">false</span>;</span>
<span class="line" id="L2627">                    }</span>
<span class="line" id="L2628">                    <span class="tok-kw">try</span> zig_args.append(asm_file.getPath(builder));</span>
<span class="line" id="L2629">                },</span>
<span class="line" id="L2630"></span>
<span class="line" id="L2631">                .c_source_file =&gt; |c_source_file| {</span>
<span class="line" id="L2632">                    <span class="tok-kw">if</span> (c_source_file.args.len == <span class="tok-number">0</span>) {</span>
<span class="line" id="L2633">                        <span class="tok-kw">if</span> (prev_has_extra_flags) {</span>
<span class="line" id="L2634">                            <span class="tok-kw">try</span> zig_args.append(<span class="tok-str">&quot;-cflags&quot;</span>);</span>
<span class="line" id="L2635">                            <span class="tok-kw">try</span> zig_args.append(<span class="tok-str">&quot;--&quot;</span>);</span>
<span class="line" id="L2636">                            prev_has_extra_flags = <span class="tok-null">false</span>;</span>
<span class="line" id="L2637">                        }</span>
<span class="line" id="L2638">                    } <span class="tok-kw">else</span> {</span>
<span class="line" id="L2639">                        <span class="tok-kw">try</span> zig_args.append(<span class="tok-str">&quot;-cflags&quot;</span>);</span>
<span class="line" id="L2640">                        <span class="tok-kw">for</span> (c_source_file.args) |arg| {</span>
<span class="line" id="L2641">                            <span class="tok-kw">try</span> zig_args.append(arg);</span>
<span class="line" id="L2642">                        }</span>
<span class="line" id="L2643">                        <span class="tok-kw">try</span> zig_args.append(<span class="tok-str">&quot;--&quot;</span>);</span>
<span class="line" id="L2644">                    }</span>
<span class="line" id="L2645">                    <span class="tok-kw">try</span> zig_args.append(c_source_file.source.getPath(builder));</span>
<span class="line" id="L2646">                },</span>
<span class="line" id="L2647"></span>
<span class="line" id="L2648">                .c_source_files =&gt; |c_source_files| {</span>
<span class="line" id="L2649">                    <span class="tok-kw">if</span> (c_source_files.flags.len == <span class="tok-number">0</span>) {</span>
<span class="line" id="L2650">                        <span class="tok-kw">if</span> (prev_has_extra_flags) {</span>
<span class="line" id="L2651">                            <span class="tok-kw">try</span> zig_args.append(<span class="tok-str">&quot;-cflags&quot;</span>);</span>
<span class="line" id="L2652">                            <span class="tok-kw">try</span> zig_args.append(<span class="tok-str">&quot;--&quot;</span>);</span>
<span class="line" id="L2653">                            prev_has_extra_flags = <span class="tok-null">false</span>;</span>
<span class="line" id="L2654">                        }</span>
<span class="line" id="L2655">                    } <span class="tok-kw">else</span> {</span>
<span class="line" id="L2656">                        <span class="tok-kw">try</span> zig_args.append(<span class="tok-str">&quot;-cflags&quot;</span>);</span>
<span class="line" id="L2657">                        <span class="tok-kw">for</span> (c_source_files.flags) |flag| {</span>
<span class="line" id="L2658">                            <span class="tok-kw">try</span> zig_args.append(flag);</span>
<span class="line" id="L2659">                        }</span>
<span class="line" id="L2660">                        <span class="tok-kw">try</span> zig_args.append(<span class="tok-str">&quot;--&quot;</span>);</span>
<span class="line" id="L2661">                    }</span>
<span class="line" id="L2662">                    <span class="tok-kw">for</span> (c_source_files.files) |file| {</span>
<span class="line" id="L2663">                        <span class="tok-kw">try</span> zig_args.append(builder.pathFromRoot(file));</span>
<span class="line" id="L2664">                    }</span>
<span class="line" id="L2665">                },</span>
<span class="line" id="L2666">            }</span>
<span class="line" id="L2667">        }</span>
<span class="line" id="L2668"></span>
<span class="line" id="L2669">        <span class="tok-kw">if</span> (self.image_base) |image_base| {</span>
<span class="line" id="L2670">            <span class="tok-kw">try</span> zig_args.append(<span class="tok-str">&quot;--image-base&quot;</span>);</span>
<span class="line" id="L2671">            <span class="tok-kw">try</span> zig_args.append(builder.fmt(<span class="tok-str">&quot;0x{x}&quot;</span>, .{image_base}));</span>
<span class="line" id="L2672">        }</span>
<span class="line" id="L2673"></span>
<span class="line" id="L2674">        <span class="tok-kw">if</span> (self.filter) |filter| {</span>
<span class="line" id="L2675">            <span class="tok-kw">try</span> zig_args.append(<span class="tok-str">&quot;--test-filter&quot;</span>);</span>
<span class="line" id="L2676">            <span class="tok-kw">try</span> zig_args.append(filter);</span>
<span class="line" id="L2677">        }</span>
<span class="line" id="L2678"></span>
<span class="line" id="L2679">        <span class="tok-kw">if</span> (self.test_evented_io) {</span>
<span class="line" id="L2680">            <span class="tok-kw">try</span> zig_args.append(<span class="tok-str">&quot;--test-evented-io&quot;</span>);</span>
<span class="line" id="L2681">        }</span>
<span class="line" id="L2682"></span>
<span class="line" id="L2683">        <span class="tok-kw">if</span> (self.name_prefix.len != <span class="tok-number">0</span>) {</span>
<span class="line" id="L2684">            <span class="tok-kw">try</span> zig_args.append(<span class="tok-str">&quot;--test-name-prefix&quot;</span>);</span>
<span class="line" id="L2685">            <span class="tok-kw">try</span> zig_args.append(self.name_prefix);</span>
<span class="line" id="L2686">        }</span>
<span class="line" id="L2687"></span>
<span class="line" id="L2688">        <span class="tok-kw">for</span> (builder.debug_log_scopes) |log_scope| {</span>
<span class="line" id="L2689">            <span class="tok-kw">try</span> zig_args.append(<span class="tok-str">&quot;--debug-log&quot;</span>);</span>
<span class="line" id="L2690">            <span class="tok-kw">try</span> zig_args.append(log_scope);</span>
<span class="line" id="L2691">        }</span>
<span class="line" id="L2692"></span>
<span class="line" id="L2693">        <span class="tok-kw">if</span> (builder.verbose_cimport) zig_args.append(<span class="tok-str">&quot;--verbose-cimport&quot;</span>) <span class="tok-kw">catch</span> <span class="tok-kw">unreachable</span>;</span>
<span class="line" id="L2694">        <span class="tok-kw">if</span> (builder.verbose_air) zig_args.append(<span class="tok-str">&quot;--verbose-air&quot;</span>) <span class="tok-kw">catch</span> <span class="tok-kw">unreachable</span>;</span>
<span class="line" id="L2695">        <span class="tok-kw">if</span> (builder.verbose_llvm_ir) zig_args.append(<span class="tok-str">&quot;--verbose-llvm-ir&quot;</span>) <span class="tok-kw">catch</span> <span class="tok-kw">unreachable</span>;</span>
<span class="line" id="L2696">        <span class="tok-kw">if</span> (builder.verbose_link <span class="tok-kw">or</span> self.verbose_link) zig_args.append(<span class="tok-str">&quot;--verbose-link&quot;</span>) <span class="tok-kw">catch</span> <span class="tok-kw">unreachable</span>;</span>
<span class="line" id="L2697">        <span class="tok-kw">if</span> (builder.verbose_cc <span class="tok-kw">or</span> self.verbose_cc) zig_args.append(<span class="tok-str">&quot;--verbose-cc&quot;</span>) <span class="tok-kw">catch</span> <span class="tok-kw">unreachable</span>;</span>
<span class="line" id="L2698">        <span class="tok-kw">if</span> (builder.verbose_llvm_cpu_features) zig_args.append(<span class="tok-str">&quot;--verbose-llvm-cpu-features&quot;</span>) <span class="tok-kw">catch</span> <span class="tok-kw">unreachable</span>;</span>
<span class="line" id="L2699"></span>
<span class="line" id="L2700">        <span class="tok-kw">if</span> (self.emit_analysis.getArg(builder, <span class="tok-str">&quot;emit-analysis&quot;</span>)) |arg| <span class="tok-kw">try</span> zig_args.append(arg);</span>
<span class="line" id="L2701">        <span class="tok-kw">if</span> (self.emit_asm.getArg(builder, <span class="tok-str">&quot;emit-asm&quot;</span>)) |arg| <span class="tok-kw">try</span> zig_args.append(arg);</span>
<span class="line" id="L2702">        <span class="tok-kw">if</span> (self.emit_bin.getArg(builder, <span class="tok-str">&quot;emit-bin&quot;</span>)) |arg| <span class="tok-kw">try</span> zig_args.append(arg);</span>
<span class="line" id="L2703">        <span class="tok-kw">if</span> (self.emit_docs.getArg(builder, <span class="tok-str">&quot;emit-docs&quot;</span>)) |arg| <span class="tok-kw">try</span> zig_args.append(arg);</span>
<span class="line" id="L2704">        <span class="tok-kw">if</span> (self.emit_implib.getArg(builder, <span class="tok-str">&quot;emit-implib&quot;</span>)) |arg| <span class="tok-kw">try</span> zig_args.append(arg);</span>
<span class="line" id="L2705">        <span class="tok-kw">if</span> (self.emit_llvm_bc.getArg(builder, <span class="tok-str">&quot;emit-llvm-bc&quot;</span>)) |arg| <span class="tok-kw">try</span> zig_args.append(arg);</span>
<span class="line" id="L2706">        <span class="tok-kw">if</span> (self.emit_llvm_ir.getArg(builder, <span class="tok-str">&quot;emit-llvm-ir&quot;</span>)) |arg| <span class="tok-kw">try</span> zig_args.append(arg);</span>
<span class="line" id="L2707"></span>
<span class="line" id="L2708">        <span class="tok-kw">if</span> (self.emit_h) <span class="tok-kw">try</span> zig_args.append(<span class="tok-str">&quot;-femit-h&quot;</span>);</span>
<span class="line" id="L2709"></span>
<span class="line" id="L2710">        <span class="tok-kw">if</span> (self.strip) {</span>
<span class="line" id="L2711">            <span class="tok-kw">try</span> zig_args.append(<span class="tok-str">&quot;--strip&quot;</span>);</span>
<span class="line" id="L2712">        }</span>
<span class="line" id="L2713"></span>
<span class="line" id="L2714">        <span class="tok-kw">switch</span> (self.compress_debug_sections) {</span>
<span class="line" id="L2715">            .none =&gt; {},</span>
<span class="line" id="L2716">            .zlib =&gt; <span class="tok-kw">try</span> zig_args.append(<span class="tok-str">&quot;--compress-debug-sections=zlib&quot;</span>),</span>
<span class="line" id="L2717">        }</span>
<span class="line" id="L2718"></span>
<span class="line" id="L2719">        <span class="tok-kw">if</span> (self.link_eh_frame_hdr) {</span>
<span class="line" id="L2720">            <span class="tok-kw">try</span> zig_args.append(<span class="tok-str">&quot;--eh-frame-hdr&quot;</span>);</span>
<span class="line" id="L2721">        }</span>
<span class="line" id="L2722">        <span class="tok-kw">if</span> (self.link_emit_relocs) {</span>
<span class="line" id="L2723">            <span class="tok-kw">try</span> zig_args.append(<span class="tok-str">&quot;--emit-relocs&quot;</span>);</span>
<span class="line" id="L2724">        }</span>
<span class="line" id="L2725">        <span class="tok-kw">if</span> (self.link_function_sections) {</span>
<span class="line" id="L2726">            <span class="tok-kw">try</span> zig_args.append(<span class="tok-str">&quot;-ffunction-sections&quot;</span>);</span>
<span class="line" id="L2727">        }</span>
<span class="line" id="L2728">        <span class="tok-kw">if</span> (self.link_gc_sections) |x| {</span>
<span class="line" id="L2729">            <span class="tok-kw">try</span> zig_args.append(<span class="tok-kw">if</span> (x) <span class="tok-str">&quot;--gc-sections&quot;</span> <span class="tok-kw">else</span> <span class="tok-str">&quot;--no-gc-sections&quot;</span>);</span>
<span class="line" id="L2730">        }</span>
<span class="line" id="L2731">        <span class="tok-kw">if</span> (self.linker_allow_shlib_undefined) |x| {</span>
<span class="line" id="L2732">            <span class="tok-kw">try</span> zig_args.append(<span class="tok-kw">if</span> (x) <span class="tok-str">&quot;-fallow-shlib-undefined&quot;</span> <span class="tok-kw">else</span> <span class="tok-str">&quot;-fno-allow-shlib-undefined&quot;</span>);</span>
<span class="line" id="L2733">        }</span>
<span class="line" id="L2734">        <span class="tok-kw">if</span> (self.link_z_notext) {</span>
<span class="line" id="L2735">            <span class="tok-kw">try</span> zig_args.append(<span class="tok-str">&quot;-z&quot;</span>);</span>
<span class="line" id="L2736">            <span class="tok-kw">try</span> zig_args.append(<span class="tok-str">&quot;notext&quot;</span>);</span>
<span class="line" id="L2737">        }</span>
<span class="line" id="L2738">        <span class="tok-kw">if</span> (!self.link_z_relro) {</span>
<span class="line" id="L2739">            <span class="tok-kw">try</span> zig_args.append(<span class="tok-str">&quot;-z&quot;</span>);</span>
<span class="line" id="L2740">            <span class="tok-kw">try</span> zig_args.append(<span class="tok-str">&quot;norelro&quot;</span>);</span>
<span class="line" id="L2741">        }</span>
<span class="line" id="L2742">        <span class="tok-kw">if</span> (self.link_z_lazy) {</span>
<span class="line" id="L2743">            <span class="tok-kw">try</span> zig_args.append(<span class="tok-str">&quot;-z&quot;</span>);</span>
<span class="line" id="L2744">            <span class="tok-kw">try</span> zig_args.append(<span class="tok-str">&quot;lazy&quot;</span>);</span>
<span class="line" id="L2745">        }</span>
<span class="line" id="L2746"></span>
<span class="line" id="L2747">        <span class="tok-kw">if</span> (self.libc_file) |libc_file| {</span>
<span class="line" id="L2748">            <span class="tok-kw">try</span> zig_args.append(<span class="tok-str">&quot;--libc&quot;</span>);</span>
<span class="line" id="L2749">            <span class="tok-kw">try</span> zig_args.append(libc_file.getPath(self.builder));</span>
<span class="line" id="L2750">        } <span class="tok-kw">else</span> <span class="tok-kw">if</span> (builder.libc_file) |libc_file| {</span>
<span class="line" id="L2751">            <span class="tok-kw">try</span> zig_args.append(<span class="tok-str">&quot;--libc&quot;</span>);</span>
<span class="line" id="L2752">            <span class="tok-kw">try</span> zig_args.append(libc_file);</span>
<span class="line" id="L2753">        }</span>
<span class="line" id="L2754"></span>
<span class="line" id="L2755">        <span class="tok-kw">switch</span> (self.build_mode) {</span>
<span class="line" id="L2756">            .Debug =&gt; {}, <span class="tok-comment">// Skip since it's the default.</span>
</span>
<span class="line" id="L2757">            <span class="tok-kw">else</span> =&gt; zig_args.append(builder.fmt(<span class="tok-str">&quot;-O{s}&quot;</span>, .{<span class="tok-builtin">@tagName</span>(self.build_mode)})) <span class="tok-kw">catch</span> <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L2758">        }</span>
<span class="line" id="L2759"></span>
<span class="line" id="L2760">        <span class="tok-kw">try</span> zig_args.append(<span class="tok-str">&quot;--cache-dir&quot;</span>);</span>
<span class="line" id="L2761">        <span class="tok-kw">try</span> zig_args.append(builder.pathFromRoot(builder.cache_root));</span>
<span class="line" id="L2762"></span>
<span class="line" id="L2763">        <span class="tok-kw">try</span> zig_args.append(<span class="tok-str">&quot;--global-cache-dir&quot;</span>);</span>
<span class="line" id="L2764">        <span class="tok-kw">try</span> zig_args.append(builder.pathFromRoot(builder.global_cache_root));</span>
<span class="line" id="L2765"></span>
<span class="line" id="L2766">        zig_args.append(<span class="tok-str">&quot;--name&quot;</span>) <span class="tok-kw">catch</span> <span class="tok-kw">unreachable</span>;</span>
<span class="line" id="L2767">        zig_args.append(self.name) <span class="tok-kw">catch</span> <span class="tok-kw">unreachable</span>;</span>
<span class="line" id="L2768"></span>
<span class="line" id="L2769">        <span class="tok-kw">if</span> (self.linkage) |some| <span class="tok-kw">switch</span> (some) {</span>
<span class="line" id="L2770">            .dynamic =&gt; <span class="tok-kw">try</span> zig_args.append(<span class="tok-str">&quot;-dynamic&quot;</span>),</span>
<span class="line" id="L2771">            .static =&gt; <span class="tok-kw">try</span> zig_args.append(<span class="tok-str">&quot;-static&quot;</span>),</span>
<span class="line" id="L2772">        };</span>
<span class="line" id="L2773">        <span class="tok-kw">if</span> (self.kind == .lib <span class="tok-kw">and</span> self.linkage != <span class="tok-null">null</span> <span class="tok-kw">and</span> self.linkage.? == .dynamic) {</span>
<span class="line" id="L2774">            <span class="tok-kw">if</span> (self.version) |version| {</span>
<span class="line" id="L2775">                zig_args.append(<span class="tok-str">&quot;--version&quot;</span>) <span class="tok-kw">catch</span> <span class="tok-kw">unreachable</span>;</span>
<span class="line" id="L2776">                zig_args.append(builder.fmt(<span class="tok-str">&quot;{}&quot;</span>, .{version})) <span class="tok-kw">catch</span> <span class="tok-kw">unreachable</span>;</span>
<span class="line" id="L2777">            }</span>
<span class="line" id="L2778"></span>
<span class="line" id="L2779">            <span class="tok-kw">if</span> (self.target.isDarwin()) {</span>
<span class="line" id="L2780">                <span class="tok-kw">const</span> install_name = self.install_name <span class="tok-kw">orelse</span> builder.fmt(<span class="tok-str">&quot;@rpath/{s}{s}{s}&quot;</span>, .{</span>
<span class="line" id="L2781">                    self.target.libPrefix(),</span>
<span class="line" id="L2782">                    self.name,</span>
<span class="line" id="L2783">                    self.target.dynamicLibSuffix(),</span>
<span class="line" id="L2784">                });</span>
<span class="line" id="L2785">                <span class="tok-kw">try</span> zig_args.append(<span class="tok-str">&quot;-install_name&quot;</span>);</span>
<span class="line" id="L2786">                <span class="tok-kw">try</span> zig_args.append(install_name);</span>
<span class="line" id="L2787">            }</span>
<span class="line" id="L2788">        }</span>
<span class="line" id="L2789"></span>
<span class="line" id="L2790">        <span class="tok-kw">if</span> (self.entitlements) |entitlements| {</span>
<span class="line" id="L2791">            <span class="tok-kw">try</span> zig_args.appendSlice(&amp;[_][]<span class="tok-kw">const</span> <span class="tok-type">u8</span>{ <span class="tok-str">&quot;--entitlements&quot;</span>, entitlements });</span>
<span class="line" id="L2792">        }</span>
<span class="line" id="L2793">        <span class="tok-kw">if</span> (self.pagezero_size) |pagezero_size| {</span>
<span class="line" id="L2794">            <span class="tok-kw">const</span> size = <span class="tok-kw">try</span> std.fmt.allocPrint(builder.allocator, <span class="tok-str">&quot;{x}&quot;</span>, .{pagezero_size});</span>
<span class="line" id="L2795">            <span class="tok-kw">try</span> zig_args.appendSlice(&amp;[_][]<span class="tok-kw">const</span> <span class="tok-type">u8</span>{ <span class="tok-str">&quot;-pagezero_size&quot;</span>, size });</span>
<span class="line" id="L2796">        }</span>
<span class="line" id="L2797">        <span class="tok-kw">if</span> (self.search_strategy) |strat| <span class="tok-kw">switch</span> (strat) {</span>
<span class="line" id="L2798">            .paths_first =&gt; <span class="tok-kw">try</span> zig_args.append(<span class="tok-str">&quot;-search_paths_first&quot;</span>),</span>
<span class="line" id="L2799">            .dylibs_first =&gt; <span class="tok-kw">try</span> zig_args.append(<span class="tok-str">&quot;-search_dylibs_first&quot;</span>),</span>
<span class="line" id="L2800">        };</span>
<span class="line" id="L2801">        <span class="tok-kw">if</span> (self.headerpad_size) |headerpad_size| {</span>
<span class="line" id="L2802">            <span class="tok-kw">const</span> size = <span class="tok-kw">try</span> std.fmt.allocPrint(builder.allocator, <span class="tok-str">&quot;{x}&quot;</span>, .{headerpad_size});</span>
<span class="line" id="L2803">            <span class="tok-kw">try</span> zig_args.appendSlice(&amp;[_][]<span class="tok-kw">const</span> <span class="tok-type">u8</span>{ <span class="tok-str">&quot;-headerpad&quot;</span>, size });</span>
<span class="line" id="L2804">        }</span>
<span class="line" id="L2805">        <span class="tok-kw">if</span> (self.headerpad_max_install_names) {</span>
<span class="line" id="L2806">            <span class="tok-kw">try</span> zig_args.append(<span class="tok-str">&quot;-headerpad_max_install_names&quot;</span>);</span>
<span class="line" id="L2807">        }</span>
<span class="line" id="L2808">        <span class="tok-kw">if</span> (self.dead_strip_dylibs) {</span>
<span class="line" id="L2809">            <span class="tok-kw">try</span> zig_args.append(<span class="tok-str">&quot;-dead_strip_dylibs&quot;</span>);</span>
<span class="line" id="L2810">        }</span>
<span class="line" id="L2811"></span>
<span class="line" id="L2812">        <span class="tok-kw">if</span> (self.bundle_compiler_rt) |x| {</span>
<span class="line" id="L2813">            <span class="tok-kw">if</span> (x) {</span>
<span class="line" id="L2814">                <span class="tok-kw">try</span> zig_args.append(<span class="tok-str">&quot;-fcompiler-rt&quot;</span>);</span>
<span class="line" id="L2815">            } <span class="tok-kw">else</span> {</span>
<span class="line" id="L2816">                <span class="tok-kw">try</span> zig_args.append(<span class="tok-str">&quot;-fno-compiler-rt&quot;</span>);</span>
<span class="line" id="L2817">            }</span>
<span class="line" id="L2818">        }</span>
<span class="line" id="L2819">        <span class="tok-kw">if</span> (self.single_threaded) |single_threaded| {</span>
<span class="line" id="L2820">            <span class="tok-kw">if</span> (single_threaded) {</span>
<span class="line" id="L2821">                <span class="tok-kw">try</span> zig_args.append(<span class="tok-str">&quot;-fsingle-threaded&quot;</span>);</span>
<span class="line" id="L2822">            } <span class="tok-kw">else</span> {</span>
<span class="line" id="L2823">                <span class="tok-kw">try</span> zig_args.append(<span class="tok-str">&quot;-fno-single-threaded&quot;</span>);</span>
<span class="line" id="L2824">            }</span>
<span class="line" id="L2825">        }</span>
<span class="line" id="L2826">        <span class="tok-kw">if</span> (self.disable_stack_probing) {</span>
<span class="line" id="L2827">            <span class="tok-kw">try</span> zig_args.append(<span class="tok-str">&quot;-fno-stack-check&quot;</span>);</span>
<span class="line" id="L2828">        }</span>
<span class="line" id="L2829">        <span class="tok-kw">if</span> (self.red_zone) |red_zone| {</span>
<span class="line" id="L2830">            <span class="tok-kw">if</span> (red_zone) {</span>
<span class="line" id="L2831">                <span class="tok-kw">try</span> zig_args.append(<span class="tok-str">&quot;-mred-zone&quot;</span>);</span>
<span class="line" id="L2832">            } <span class="tok-kw">else</span> {</span>
<span class="line" id="L2833">                <span class="tok-kw">try</span> zig_args.append(<span class="tok-str">&quot;-mno-red-zone&quot;</span>);</span>
<span class="line" id="L2834">            }</span>
<span class="line" id="L2835">        }</span>
<span class="line" id="L2836">        <span class="tok-kw">if</span> (self.omit_frame_pointer) |omit_frame_pointer| {</span>
<span class="line" id="L2837">            <span class="tok-kw">if</span> (omit_frame_pointer) {</span>
<span class="line" id="L2838">                <span class="tok-kw">try</span> zig_args.append(<span class="tok-str">&quot;-fomit-frame-pointer&quot;</span>);</span>
<span class="line" id="L2839">            } <span class="tok-kw">else</span> {</span>
<span class="line" id="L2840">                <span class="tok-kw">try</span> zig_args.append(<span class="tok-str">&quot;-fno-omit-frame-pointer&quot;</span>);</span>
<span class="line" id="L2841">            }</span>
<span class="line" id="L2842">        }</span>
<span class="line" id="L2843">        <span class="tok-kw">if</span> (self.dll_export_fns) |dll_export_fns| {</span>
<span class="line" id="L2844">            <span class="tok-kw">if</span> (dll_export_fns) {</span>
<span class="line" id="L2845">                <span class="tok-kw">try</span> zig_args.append(<span class="tok-str">&quot;-fdll-export-fns&quot;</span>);</span>
<span class="line" id="L2846">            } <span class="tok-kw">else</span> {</span>
<span class="line" id="L2847">                <span class="tok-kw">try</span> zig_args.append(<span class="tok-str">&quot;-fno-dll-export-fns&quot;</span>);</span>
<span class="line" id="L2848">            }</span>
<span class="line" id="L2849">        }</span>
<span class="line" id="L2850">        <span class="tok-kw">if</span> (self.disable_sanitize_c) {</span>
<span class="line" id="L2851">            <span class="tok-kw">try</span> zig_args.append(<span class="tok-str">&quot;-fno-sanitize-c&quot;</span>);</span>
<span class="line" id="L2852">        }</span>
<span class="line" id="L2853">        <span class="tok-kw">if</span> (self.sanitize_thread) {</span>
<span class="line" id="L2854">            <span class="tok-kw">try</span> zig_args.append(<span class="tok-str">&quot;-fsanitize-thread&quot;</span>);</span>
<span class="line" id="L2855">        }</span>
<span class="line" id="L2856">        <span class="tok-kw">if</span> (self.rdynamic) {</span>
<span class="line" id="L2857">            <span class="tok-kw">try</span> zig_args.append(<span class="tok-str">&quot;-rdynamic&quot;</span>);</span>
<span class="line" id="L2858">        }</span>
<span class="line" id="L2859">        <span class="tok-kw">if</span> (self.import_memory) {</span>
<span class="line" id="L2860">            <span class="tok-kw">try</span> zig_args.append(<span class="tok-str">&quot;--import-memory&quot;</span>);</span>
<span class="line" id="L2861">        }</span>
<span class="line" id="L2862">        <span class="tok-kw">if</span> (self.import_table) {</span>
<span class="line" id="L2863">            <span class="tok-kw">try</span> zig_args.append(<span class="tok-str">&quot;--import-table&quot;</span>);</span>
<span class="line" id="L2864">        }</span>
<span class="line" id="L2865">        <span class="tok-kw">if</span> (self.export_table) {</span>
<span class="line" id="L2866">            <span class="tok-kw">try</span> zig_args.append(<span class="tok-str">&quot;--export-table&quot;</span>);</span>
<span class="line" id="L2867">        }</span>
<span class="line" id="L2868">        <span class="tok-kw">if</span> (self.initial_memory) |initial_memory| {</span>
<span class="line" id="L2869">            <span class="tok-kw">try</span> zig_args.append(builder.fmt(<span class="tok-str">&quot;--initial-memory={d}&quot;</span>, .{initial_memory}));</span>
<span class="line" id="L2870">        }</span>
<span class="line" id="L2871">        <span class="tok-kw">if</span> (self.max_memory) |max_memory| {</span>
<span class="line" id="L2872">            <span class="tok-kw">try</span> zig_args.append(builder.fmt(<span class="tok-str">&quot;--max-memory={d}&quot;</span>, .{max_memory}));</span>
<span class="line" id="L2873">        }</span>
<span class="line" id="L2874">        <span class="tok-kw">if</span> (self.shared_memory) {</span>
<span class="line" id="L2875">            <span class="tok-kw">try</span> zig_args.append(<span class="tok-str">&quot;--shared-memory&quot;</span>);</span>
<span class="line" id="L2876">        }</span>
<span class="line" id="L2877">        <span class="tok-kw">if</span> (self.global_base) |global_base| {</span>
<span class="line" id="L2878">            <span class="tok-kw">try</span> zig_args.append(builder.fmt(<span class="tok-str">&quot;--global-base={d}&quot;</span>, .{global_base}));</span>
<span class="line" id="L2879">        }</span>
<span class="line" id="L2880"></span>
<span class="line" id="L2881">        <span class="tok-kw">if</span> (self.code_model != .default) {</span>
<span class="line" id="L2882">            <span class="tok-kw">try</span> zig_args.append(<span class="tok-str">&quot;-mcmodel&quot;</span>);</span>
<span class="line" id="L2883">            <span class="tok-kw">try</span> zig_args.append(<span class="tok-builtin">@tagName</span>(self.code_model));</span>
<span class="line" id="L2884">        }</span>
<span class="line" id="L2885">        <span class="tok-kw">if</span> (self.wasi_exec_model) |model| {</span>
<span class="line" id="L2886">            <span class="tok-kw">try</span> zig_args.append(builder.fmt(<span class="tok-str">&quot;-mexec-model={s}&quot;</span>, .{<span class="tok-builtin">@tagName</span>(model)}));</span>
<span class="line" id="L2887">        }</span>
<span class="line" id="L2888">        <span class="tok-kw">for</span> (self.export_symbol_names) |symbol_name| {</span>
<span class="line" id="L2889">            <span class="tok-kw">try</span> zig_args.append(builder.fmt(<span class="tok-str">&quot;--export={s}&quot;</span>, .{symbol_name}));</span>
<span class="line" id="L2890">        }</span>
<span class="line" id="L2891"></span>
<span class="line" id="L2892">        <span class="tok-kw">if</span> (!self.target.isNative()) {</span>
<span class="line" id="L2893">            <span class="tok-kw">try</span> zig_args.append(<span class="tok-str">&quot;-target&quot;</span>);</span>
<span class="line" id="L2894">            <span class="tok-kw">try</span> zig_args.append(<span class="tok-kw">try</span> self.target.zigTriple(builder.allocator));</span>
<span class="line" id="L2895"></span>
<span class="line" id="L2896">            <span class="tok-comment">// TODO this logic can disappear if cpu model + features becomes part of the target triple</span>
</span>
<span class="line" id="L2897">            <span class="tok-kw">const</span> cross = self.target.toTarget();</span>
<span class="line" id="L2898">            <span class="tok-kw">const</span> all_features = cross.cpu.arch.allFeaturesList();</span>
<span class="line" id="L2899">            <span class="tok-kw">var</span> populated_cpu_features = cross.cpu.model.features;</span>
<span class="line" id="L2900">            populated_cpu_features.populateDependencies(all_features);</span>
<span class="line" id="L2901"></span>
<span class="line" id="L2902">            <span class="tok-kw">if</span> (populated_cpu_features.eql(cross.cpu.features)) {</span>
<span class="line" id="L2903">                <span class="tok-comment">// The CPU name alone is sufficient.</span>
</span>
<span class="line" id="L2904">                <span class="tok-kw">try</span> zig_args.append(<span class="tok-str">&quot;-mcpu&quot;</span>);</span>
<span class="line" id="L2905">                <span class="tok-kw">try</span> zig_args.append(cross.cpu.model.name);</span>
<span class="line" id="L2906">            } <span class="tok-kw">else</span> {</span>
<span class="line" id="L2907">                <span class="tok-kw">var</span> mcpu_buffer = std.ArrayList(<span class="tok-type">u8</span>).init(builder.allocator);</span>
<span class="line" id="L2908"></span>
<span class="line" id="L2909">                <span class="tok-kw">try</span> mcpu_buffer.writer().print(<span class="tok-str">&quot;-mcpu={s}&quot;</span>, .{cross.cpu.model.name});</span>
<span class="line" id="L2910"></span>
<span class="line" id="L2911">                <span class="tok-kw">for</span> (all_features) |feature, i_usize| {</span>
<span class="line" id="L2912">                    <span class="tok-kw">const</span> i = <span class="tok-builtin">@intCast</span>(std.Target.Cpu.Feature.Set.Index, i_usize);</span>
<span class="line" id="L2913">                    <span class="tok-kw">const</span> in_cpu_set = populated_cpu_features.isEnabled(i);</span>
<span class="line" id="L2914">                    <span class="tok-kw">const</span> in_actual_set = cross.cpu.features.isEnabled(i);</span>
<span class="line" id="L2915">                    <span class="tok-kw">if</span> (in_cpu_set <span class="tok-kw">and</span> !in_actual_set) {</span>
<span class="line" id="L2916">                        <span class="tok-kw">try</span> mcpu_buffer.writer().print(<span class="tok-str">&quot;-{s}&quot;</span>, .{feature.name});</span>
<span class="line" id="L2917">                    } <span class="tok-kw">else</span> <span class="tok-kw">if</span> (!in_cpu_set <span class="tok-kw">and</span> in_actual_set) {</span>
<span class="line" id="L2918">                        <span class="tok-kw">try</span> mcpu_buffer.writer().print(<span class="tok-str">&quot;+{s}&quot;</span>, .{feature.name});</span>
<span class="line" id="L2919">                    }</span>
<span class="line" id="L2920">                }</span>
<span class="line" id="L2921"></span>
<span class="line" id="L2922">                <span class="tok-kw">try</span> zig_args.append(mcpu_buffer.toOwnedSlice());</span>
<span class="line" id="L2923">            }</span>
<span class="line" id="L2924"></span>
<span class="line" id="L2925">            <span class="tok-kw">if</span> (self.target.dynamic_linker.get()) |dynamic_linker| {</span>
<span class="line" id="L2926">                <span class="tok-kw">try</span> zig_args.append(<span class="tok-str">&quot;--dynamic-linker&quot;</span>);</span>
<span class="line" id="L2927">                <span class="tok-kw">try</span> zig_args.append(dynamic_linker);</span>
<span class="line" id="L2928">            }</span>
<span class="line" id="L2929">        }</span>
<span class="line" id="L2930"></span>
<span class="line" id="L2931">        <span class="tok-kw">if</span> (self.linker_script) |linker_script| {</span>
<span class="line" id="L2932">            <span class="tok-kw">try</span> zig_args.append(<span class="tok-str">&quot;--script&quot;</span>);</span>
<span class="line" id="L2933">            <span class="tok-kw">try</span> zig_args.append(linker_script.getPath(builder));</span>
<span class="line" id="L2934">        }</span>
<span class="line" id="L2935"></span>
<span class="line" id="L2936">        <span class="tok-kw">if</span> (self.version_script) |version_script| {</span>
<span class="line" id="L2937">            <span class="tok-kw">try</span> zig_args.append(<span class="tok-str">&quot;--version-script&quot;</span>);</span>
<span class="line" id="L2938">            <span class="tok-kw">try</span> zig_args.append(builder.pathFromRoot(version_script));</span>
<span class="line" id="L2939">        }</span>
<span class="line" id="L2940"></span>
<span class="line" id="L2941">        <span class="tok-kw">if</span> (self.kind == .@&quot;test&quot;) {</span>
<span class="line" id="L2942">            <span class="tok-kw">if</span> (self.exec_cmd_args) |exec_cmd_args| {</span>
<span class="line" id="L2943">                <span class="tok-kw">for</span> (exec_cmd_args) |cmd_arg| {</span>
<span class="line" id="L2944">                    <span class="tok-kw">if</span> (cmd_arg) |arg| {</span>
<span class="line" id="L2945">                        <span class="tok-kw">try</span> zig_args.append(<span class="tok-str">&quot;--test-cmd&quot;</span>);</span>
<span class="line" id="L2946">                        <span class="tok-kw">try</span> zig_args.append(arg);</span>
<span class="line" id="L2947">                    } <span class="tok-kw">else</span> {</span>
<span class="line" id="L2948">                        <span class="tok-kw">try</span> zig_args.append(<span class="tok-str">&quot;--test-cmd-bin&quot;</span>);</span>
<span class="line" id="L2949">                    }</span>
<span class="line" id="L2950">                }</span>
<span class="line" id="L2951">            } <span class="tok-kw">else</span> {</span>
<span class="line" id="L2952">                <span class="tok-kw">const</span> need_cross_glibc = self.target.isGnuLibC() <span class="tok-kw">and</span> self.is_linking_libc;</span>
<span class="line" id="L2953"></span>
<span class="line" id="L2954">                <span class="tok-kw">switch</span> (self.builder.host.getExternalExecutor(self.target_info, .{</span>
<span class="line" id="L2955">                    .qemu_fixes_dl = need_cross_glibc <span class="tok-kw">and</span> builder.glibc_runtimes_dir != <span class="tok-null">null</span>,</span>
<span class="line" id="L2956">                    .link_libc = self.is_linking_libc,</span>
<span class="line" id="L2957">                })) {</span>
<span class="line" id="L2958">                    .native =&gt; {},</span>
<span class="line" id="L2959">                    .bad_dl, .bad_os_or_cpu =&gt; {</span>
<span class="line" id="L2960">                        <span class="tok-kw">try</span> zig_args.append(<span class="tok-str">&quot;--test-no-exec&quot;</span>);</span>
<span class="line" id="L2961">                    },</span>
<span class="line" id="L2962">                    .rosetta =&gt; <span class="tok-kw">if</span> (builder.enable_rosetta) {</span>
<span class="line" id="L2963">                        <span class="tok-kw">try</span> zig_args.append(<span class="tok-str">&quot;--test-cmd-bin&quot;</span>);</span>
<span class="line" id="L2964">                    } <span class="tok-kw">else</span> {</span>
<span class="line" id="L2965">                        <span class="tok-kw">try</span> zig_args.append(<span class="tok-str">&quot;--test-no-exec&quot;</span>);</span>
<span class="line" id="L2966">                    },</span>
<span class="line" id="L2967">                    .qemu =&gt; |bin_name| ok: {</span>
<span class="line" id="L2968">                        <span class="tok-kw">if</span> (builder.enable_qemu) qemu: {</span>
<span class="line" id="L2969">                            <span class="tok-kw">const</span> glibc_dir_arg = <span class="tok-kw">if</span> (need_cross_glibc)</span>
<span class="line" id="L2970">                                builder.glibc_runtimes_dir <span class="tok-kw">orelse</span> <span class="tok-kw">break</span> :qemu</span>
<span class="line" id="L2971">                            <span class="tok-kw">else</span></span>
<span class="line" id="L2972">                                <span class="tok-null">null</span>;</span>
<span class="line" id="L2973">                            <span class="tok-kw">try</span> zig_args.append(<span class="tok-str">&quot;--test-cmd&quot;</span>);</span>
<span class="line" id="L2974">                            <span class="tok-kw">try</span> zig_args.append(bin_name);</span>
<span class="line" id="L2975">                            <span class="tok-kw">if</span> (glibc_dir_arg) |dir| {</span>
<span class="line" id="L2976">                                <span class="tok-comment">// TODO look into making this a call to `linuxTriple`. This</span>
</span>
<span class="line" id="L2977">                                <span class="tok-comment">// needs the directory to be called &quot;i686&quot; rather than</span>
</span>
<span class="line" id="L2978">                                <span class="tok-comment">// &quot;i386&quot; which is why we do it manually here.</span>
</span>
<span class="line" id="L2979">                                <span class="tok-kw">const</span> fmt_str = <span class="tok-str">&quot;{s}&quot;</span> ++ fs.path.sep_str ++ <span class="tok-str">&quot;{s}-{s}-{s}&quot;</span>;</span>
<span class="line" id="L2980">                                <span class="tok-kw">const</span> cpu_arch = self.target.getCpuArch();</span>
<span class="line" id="L2981">                                <span class="tok-kw">const</span> os_tag = self.target.getOsTag();</span>
<span class="line" id="L2982">                                <span class="tok-kw">const</span> abi = self.target.getAbi();</span>
<span class="line" id="L2983">                                <span class="tok-kw">const</span> cpu_arch_name: []<span class="tok-kw">const</span> <span class="tok-type">u8</span> = <span class="tok-kw">if</span> (cpu_arch == .<span class="tok-type">i386</span>)</span>
<span class="line" id="L2984">                                    <span class="tok-str">&quot;i686&quot;</span></span>
<span class="line" id="L2985">                                <span class="tok-kw">else</span></span>
<span class="line" id="L2986">                                    <span class="tok-builtin">@tagName</span>(cpu_arch);</span>
<span class="line" id="L2987">                                <span class="tok-kw">const</span> full_dir = <span class="tok-kw">try</span> std.fmt.allocPrint(builder.allocator, fmt_str, .{</span>
<span class="line" id="L2988">                                    dir, cpu_arch_name, <span class="tok-builtin">@tagName</span>(os_tag), <span class="tok-builtin">@tagName</span>(abi),</span>
<span class="line" id="L2989">                                });</span>
<span class="line" id="L2990"></span>
<span class="line" id="L2991">                                <span class="tok-kw">try</span> zig_args.append(<span class="tok-str">&quot;--test-cmd&quot;</span>);</span>
<span class="line" id="L2992">                                <span class="tok-kw">try</span> zig_args.append(<span class="tok-str">&quot;-L&quot;</span>);</span>
<span class="line" id="L2993">                                <span class="tok-kw">try</span> zig_args.append(<span class="tok-str">&quot;--test-cmd&quot;</span>);</span>
<span class="line" id="L2994">                                <span class="tok-kw">try</span> zig_args.append(full_dir);</span>
<span class="line" id="L2995">                            }</span>
<span class="line" id="L2996">                            <span class="tok-kw">try</span> zig_args.append(<span class="tok-str">&quot;--test-cmd-bin&quot;</span>);</span>
<span class="line" id="L2997">                            <span class="tok-kw">break</span> :ok;</span>
<span class="line" id="L2998">                        }</span>
<span class="line" id="L2999">                        <span class="tok-kw">try</span> zig_args.append(<span class="tok-str">&quot;--test-no-exec&quot;</span>);</span>
<span class="line" id="L3000">                    },</span>
<span class="line" id="L3001">                    .wine =&gt; |bin_name| <span class="tok-kw">if</span> (builder.enable_wine) {</span>
<span class="line" id="L3002">                        <span class="tok-kw">try</span> zig_args.append(<span class="tok-str">&quot;--test-cmd&quot;</span>);</span>
<span class="line" id="L3003">                        <span class="tok-kw">try</span> zig_args.append(bin_name);</span>
<span class="line" id="L3004">                        <span class="tok-kw">try</span> zig_args.append(<span class="tok-str">&quot;--test-cmd-bin&quot;</span>);</span>
<span class="line" id="L3005">                    } <span class="tok-kw">else</span> {</span>
<span class="line" id="L3006">                        <span class="tok-kw">try</span> zig_args.append(<span class="tok-str">&quot;--test-no-exec&quot;</span>);</span>
<span class="line" id="L3007">                    },</span>
<span class="line" id="L3008">                    .wasmtime =&gt; |bin_name| <span class="tok-kw">if</span> (builder.enable_wasmtime) {</span>
<span class="line" id="L3009">                        <span class="tok-kw">try</span> zig_args.append(<span class="tok-str">&quot;--test-cmd&quot;</span>);</span>
<span class="line" id="L3010">                        <span class="tok-kw">try</span> zig_args.append(bin_name);</span>
<span class="line" id="L3011">                        <span class="tok-kw">try</span> zig_args.append(<span class="tok-str">&quot;--test-cmd&quot;</span>);</span>
<span class="line" id="L3012">                        <span class="tok-kw">try</span> zig_args.append(<span class="tok-str">&quot;--dir=.&quot;</span>);</span>
<span class="line" id="L3013">                        <span class="tok-kw">try</span> zig_args.append(<span class="tok-str">&quot;--test-cmd&quot;</span>);</span>
<span class="line" id="L3014">                        <span class="tok-kw">try</span> zig_args.append(<span class="tok-str">&quot;--allow-unknown-exports&quot;</span>); <span class="tok-comment">// TODO: Remove when stage2 is default compiler</span>
</span>
<span class="line" id="L3015">                        <span class="tok-kw">try</span> zig_args.append(<span class="tok-str">&quot;--test-cmd-bin&quot;</span>);</span>
<span class="line" id="L3016">                    } <span class="tok-kw">else</span> {</span>
<span class="line" id="L3017">                        <span class="tok-kw">try</span> zig_args.append(<span class="tok-str">&quot;--test-no-exec&quot;</span>);</span>
<span class="line" id="L3018">                    },</span>
<span class="line" id="L3019">                    .darling =&gt; |bin_name| <span class="tok-kw">if</span> (builder.enable_darling) {</span>
<span class="line" id="L3020">                        <span class="tok-kw">try</span> zig_args.append(<span class="tok-str">&quot;--test-cmd&quot;</span>);</span>
<span class="line" id="L3021">                        <span class="tok-kw">try</span> zig_args.append(bin_name);</span>
<span class="line" id="L3022">                        <span class="tok-kw">try</span> zig_args.append(<span class="tok-str">&quot;--test-cmd-bin&quot;</span>);</span>
<span class="line" id="L3023">                    } <span class="tok-kw">else</span> {</span>
<span class="line" id="L3024">                        <span class="tok-kw">try</span> zig_args.append(<span class="tok-str">&quot;--test-no-exec&quot;</span>);</span>
<span class="line" id="L3025">                    },</span>
<span class="line" id="L3026">                }</span>
<span class="line" id="L3027">            }</span>
<span class="line" id="L3028">        } <span class="tok-kw">else</span> <span class="tok-kw">if</span> (self.kind == .test_exe) {</span>
<span class="line" id="L3029">            <span class="tok-kw">try</span> zig_args.append(<span class="tok-str">&quot;--test-no-exec&quot;</span>);</span>
<span class="line" id="L3030">        }</span>
<span class="line" id="L3031"></span>
<span class="line" id="L3032">        <span class="tok-kw">for</span> (self.packages.items) |pkg| {</span>
<span class="line" id="L3033">            <span class="tok-kw">try</span> self.makePackageCmd(pkg, &amp;zig_args);</span>
<span class="line" id="L3034">        }</span>
<span class="line" id="L3035"></span>
<span class="line" id="L3036">        <span class="tok-kw">for</span> (self.include_dirs.items) |include_dir| {</span>
<span class="line" id="L3037">            <span class="tok-kw">switch</span> (include_dir) {</span>
<span class="line" id="L3038">                .raw_path =&gt; |include_path| {</span>
<span class="line" id="L3039">                    <span class="tok-kw">try</span> zig_args.append(<span class="tok-str">&quot;-I&quot;</span>);</span>
<span class="line" id="L3040">                    <span class="tok-kw">try</span> zig_args.append(self.builder.pathFromRoot(include_path));</span>
<span class="line" id="L3041">                },</span>
<span class="line" id="L3042">                .raw_path_system =&gt; |include_path| {</span>
<span class="line" id="L3043">                    <span class="tok-kw">if</span> (builder.sysroot != <span class="tok-null">null</span>) {</span>
<span class="line" id="L3044">                        <span class="tok-kw">try</span> zig_args.append(<span class="tok-str">&quot;-iwithsysroot&quot;</span>);</span>
<span class="line" id="L3045">                    } <span class="tok-kw">else</span> {</span>
<span class="line" id="L3046">                        <span class="tok-kw">try</span> zig_args.append(<span class="tok-str">&quot;-isystem&quot;</span>);</span>
<span class="line" id="L3047">                    }</span>
<span class="line" id="L3048"></span>
<span class="line" id="L3049">                    <span class="tok-kw">const</span> resolved_include_path = self.builder.pathFromRoot(include_path);</span>
<span class="line" id="L3050"></span>
<span class="line" id="L3051">                    <span class="tok-kw">const</span> common_include_path = <span class="tok-kw">if</span> (builtin.os.tag == .windows <span class="tok-kw">and</span> builder.sysroot != <span class="tok-null">null</span> <span class="tok-kw">and</span> fs.path.isAbsolute(resolved_include_path)) blk: {</span>
<span class="line" id="L3052">                        <span class="tok-comment">// We need to check for disk designator and strip it out from dir path so</span>
</span>
<span class="line" id="L3053">                        <span class="tok-comment">// that zig/clang can concat resolved_include_path with sysroot.</span>
</span>
<span class="line" id="L3054">                        <span class="tok-kw">const</span> disk_designator = fs.path.diskDesignatorWindows(resolved_include_path);</span>
<span class="line" id="L3055"></span>
<span class="line" id="L3056">                        <span class="tok-kw">if</span> (mem.indexOf(<span class="tok-type">u8</span>, resolved_include_path, disk_designator)) |where| {</span>
<span class="line" id="L3057">                            <span class="tok-kw">break</span> :blk resolved_include_path[where + disk_designator.len ..];</span>
<span class="line" id="L3058">                        }</span>
<span class="line" id="L3059"></span>
<span class="line" id="L3060">                        <span class="tok-kw">break</span> :blk resolved_include_path;</span>
<span class="line" id="L3061">                    } <span class="tok-kw">else</span> resolved_include_path;</span>
<span class="line" id="L3062"></span>
<span class="line" id="L3063">                    <span class="tok-kw">try</span> zig_args.append(common_include_path);</span>
<span class="line" id="L3064">                },</span>
<span class="line" id="L3065">                .other_step =&gt; |other| <span class="tok-kw">if</span> (other.emit_h) {</span>
<span class="line" id="L3066">                    <span class="tok-kw">const</span> h_path = other.getOutputHSource().getPath(self.builder);</span>
<span class="line" id="L3067">                    <span class="tok-kw">try</span> zig_args.append(<span class="tok-str">&quot;-isystem&quot;</span>);</span>
<span class="line" id="L3068">                    <span class="tok-kw">try</span> zig_args.append(fs.path.dirname(h_path).?);</span>
<span class="line" id="L3069">                },</span>
<span class="line" id="L3070">            }</span>
<span class="line" id="L3071">        }</span>
<span class="line" id="L3072"></span>
<span class="line" id="L3073">        <span class="tok-kw">for</span> (self.lib_paths.items) |lib_path| {</span>
<span class="line" id="L3074">            <span class="tok-kw">try</span> zig_args.append(<span class="tok-str">&quot;-L&quot;</span>);</span>
<span class="line" id="L3075">            <span class="tok-kw">try</span> zig_args.append(lib_path);</span>
<span class="line" id="L3076">        }</span>
<span class="line" id="L3077"></span>
<span class="line" id="L3078">        <span class="tok-kw">for</span> (self.rpaths.items) |rpath| {</span>
<span class="line" id="L3079">            <span class="tok-kw">try</span> zig_args.append(<span class="tok-str">&quot;-rpath&quot;</span>);</span>
<span class="line" id="L3080">            <span class="tok-kw">try</span> zig_args.append(rpath);</span>
<span class="line" id="L3081">        }</span>
<span class="line" id="L3082"></span>
<span class="line" id="L3083">        <span class="tok-kw">for</span> (self.c_macros.items) |c_macro| {</span>
<span class="line" id="L3084">            <span class="tok-kw">try</span> zig_args.append(<span class="tok-str">&quot;-D&quot;</span>);</span>
<span class="line" id="L3085">            <span class="tok-kw">try</span> zig_args.append(c_macro);</span>
<span class="line" id="L3086">        }</span>
<span class="line" id="L3087"></span>
<span class="line" id="L3088">        <span class="tok-kw">if</span> (self.target.isDarwin()) {</span>
<span class="line" id="L3089">            <span class="tok-kw">for</span> (self.framework_dirs.items) |dir| {</span>
<span class="line" id="L3090">                <span class="tok-kw">if</span> (builder.sysroot != <span class="tok-null">null</span>) {</span>
<span class="line" id="L3091">                    <span class="tok-kw">try</span> zig_args.append(<span class="tok-str">&quot;-iframeworkwithsysroot&quot;</span>);</span>
<span class="line" id="L3092">                } <span class="tok-kw">else</span> {</span>
<span class="line" id="L3093">                    <span class="tok-kw">try</span> zig_args.append(<span class="tok-str">&quot;-iframework&quot;</span>);</span>
<span class="line" id="L3094">                }</span>
<span class="line" id="L3095">                <span class="tok-kw">try</span> zig_args.append(dir);</span>
<span class="line" id="L3096">                <span class="tok-kw">try</span> zig_args.append(<span class="tok-str">&quot;-F&quot;</span>);</span>
<span class="line" id="L3097">                <span class="tok-kw">try</span> zig_args.append(dir);</span>
<span class="line" id="L3098">            }</span>
<span class="line" id="L3099"></span>
<span class="line" id="L3100">            <span class="tok-kw">var</span> it = self.frameworks.iterator();</span>
<span class="line" id="L3101">            <span class="tok-kw">while</span> (it.next()) |entry| {</span>
<span class="line" id="L3102">                <span class="tok-kw">const</span> name = entry.key_ptr.*;</span>
<span class="line" id="L3103">                <span class="tok-kw">const</span> info = entry.value_ptr.*;</span>
<span class="line" id="L3104">                <span class="tok-kw">if</span> (info.needed) {</span>
<span class="line" id="L3105">                    zig_args.append(<span class="tok-str">&quot;-needed_framework&quot;</span>) <span class="tok-kw">catch</span> <span class="tok-kw">unreachable</span>;</span>
<span class="line" id="L3106">                } <span class="tok-kw">else</span> <span class="tok-kw">if</span> (info.weak) {</span>
<span class="line" id="L3107">                    zig_args.append(<span class="tok-str">&quot;-weak_framework&quot;</span>) <span class="tok-kw">catch</span> <span class="tok-kw">unreachable</span>;</span>
<span class="line" id="L3108">                } <span class="tok-kw">else</span> {</span>
<span class="line" id="L3109">                    zig_args.append(<span class="tok-str">&quot;-framework&quot;</span>) <span class="tok-kw">catch</span> <span class="tok-kw">unreachable</span>;</span>
<span class="line" id="L3110">                }</span>
<span class="line" id="L3111">                zig_args.append(name) <span class="tok-kw">catch</span> <span class="tok-kw">unreachable</span>;</span>
<span class="line" id="L3112">            }</span>
<span class="line" id="L3113">        } <span class="tok-kw">else</span> {</span>
<span class="line" id="L3114">            <span class="tok-kw">if</span> (self.framework_dirs.items.len &gt; <span class="tok-number">0</span>) {</span>
<span class="line" id="L3115">                log.info(<span class="tok-str">&quot;Framework directories have been added for a non-darwin target, this will have no affect on the build&quot;</span>, .{});</span>
<span class="line" id="L3116">            }</span>
<span class="line" id="L3117"></span>
<span class="line" id="L3118">            <span class="tok-kw">if</span> (self.frameworks.count() &gt; <span class="tok-number">0</span>) {</span>
<span class="line" id="L3119">                log.info(<span class="tok-str">&quot;Frameworks have been added for a non-darwin target, this will have no affect on the build&quot;</span>, .{});</span>
<span class="line" id="L3120">            }</span>
<span class="line" id="L3121">        }</span>
<span class="line" id="L3122"></span>
<span class="line" id="L3123">        <span class="tok-kw">if</span> (builder.sysroot) |sysroot| {</span>
<span class="line" id="L3124">            <span class="tok-kw">try</span> zig_args.appendSlice(&amp;[_][]<span class="tok-kw">const</span> <span class="tok-type">u8</span>{ <span class="tok-str">&quot;--sysroot&quot;</span>, sysroot });</span>
<span class="line" id="L3125">        }</span>
<span class="line" id="L3126"></span>
<span class="line" id="L3127">        <span class="tok-kw">for</span> (builder.search_prefixes.items) |search_prefix| {</span>
<span class="line" id="L3128">            <span class="tok-kw">try</span> zig_args.append(<span class="tok-str">&quot;-L&quot;</span>);</span>
<span class="line" id="L3129">            <span class="tok-kw">try</span> zig_args.append(builder.pathJoin(&amp;.{</span>
<span class="line" id="L3130">                search_prefix, <span class="tok-str">&quot;lib&quot;</span>,</span>
<span class="line" id="L3131">            }));</span>
<span class="line" id="L3132">            <span class="tok-kw">try</span> zig_args.append(<span class="tok-str">&quot;-isystem&quot;</span>);</span>
<span class="line" id="L3133">            <span class="tok-kw">try</span> zig_args.append(builder.pathJoin(&amp;.{</span>
<span class="line" id="L3134">                search_prefix, <span class="tok-str">&quot;include&quot;</span>,</span>
<span class="line" id="L3135">            }));</span>
<span class="line" id="L3136">        }</span>
<span class="line" id="L3137"></span>
<span class="line" id="L3138">        <span class="tok-kw">if</span> (self.valgrind_support) |valgrind_support| {</span>
<span class="line" id="L3139">            <span class="tok-kw">if</span> (valgrind_support) {</span>
<span class="line" id="L3140">                <span class="tok-kw">try</span> zig_args.append(<span class="tok-str">&quot;-fvalgrind&quot;</span>);</span>
<span class="line" id="L3141">            } <span class="tok-kw">else</span> {</span>
<span class="line" id="L3142">                <span class="tok-kw">try</span> zig_args.append(<span class="tok-str">&quot;-fno-valgrind&quot;</span>);</span>
<span class="line" id="L3143">            }</span>
<span class="line" id="L3144">        }</span>
<span class="line" id="L3145"></span>
<span class="line" id="L3146">        <span class="tok-kw">if</span> (self.each_lib_rpath) |each_lib_rpath| {</span>
<span class="line" id="L3147">            <span class="tok-kw">if</span> (each_lib_rpath) {</span>
<span class="line" id="L3148">                <span class="tok-kw">try</span> zig_args.append(<span class="tok-str">&quot;-feach-lib-rpath&quot;</span>);</span>
<span class="line" id="L3149">            } <span class="tok-kw">else</span> {</span>
<span class="line" id="L3150">                <span class="tok-kw">try</span> zig_args.append(<span class="tok-str">&quot;-fno-each-lib-rpath&quot;</span>);</span>
<span class="line" id="L3151">            }</span>
<span class="line" id="L3152">        }</span>
<span class="line" id="L3153"></span>
<span class="line" id="L3154">        <span class="tok-kw">if</span> (self.build_id) |build_id| {</span>
<span class="line" id="L3155">            <span class="tok-kw">if</span> (build_id) {</span>
<span class="line" id="L3156">                <span class="tok-kw">try</span> zig_args.append(<span class="tok-str">&quot;-fbuild-id&quot;</span>);</span>
<span class="line" id="L3157">            } <span class="tok-kw">else</span> {</span>
<span class="line" id="L3158">                <span class="tok-kw">try</span> zig_args.append(<span class="tok-str">&quot;-fno-build-id&quot;</span>);</span>
<span class="line" id="L3159">            }</span>
<span class="line" id="L3160">        }</span>
<span class="line" id="L3161"></span>
<span class="line" id="L3162">        <span class="tok-kw">if</span> (self.override_lib_dir) |dir| {</span>
<span class="line" id="L3163">            <span class="tok-kw">try</span> zig_args.append(<span class="tok-str">&quot;--zig-lib-dir&quot;</span>);</span>
<span class="line" id="L3164">            <span class="tok-kw">try</span> zig_args.append(builder.pathFromRoot(dir));</span>
<span class="line" id="L3165">        } <span class="tok-kw">else</span> <span class="tok-kw">if</span> (self.builder.override_lib_dir) |dir| {</span>
<span class="line" id="L3166">            <span class="tok-kw">try</span> zig_args.append(<span class="tok-str">&quot;--zig-lib-dir&quot;</span>);</span>
<span class="line" id="L3167">            <span class="tok-kw">try</span> zig_args.append(builder.pathFromRoot(dir));</span>
<span class="line" id="L3168">        }</span>
<span class="line" id="L3169"></span>
<span class="line" id="L3170">        <span class="tok-kw">if</span> (self.main_pkg_path) |dir| {</span>
<span class="line" id="L3171">            <span class="tok-kw">try</span> zig_args.append(<span class="tok-str">&quot;--main-pkg-path&quot;</span>);</span>
<span class="line" id="L3172">            <span class="tok-kw">try</span> zig_args.append(builder.pathFromRoot(dir));</span>
<span class="line" id="L3173">        }</span>
<span class="line" id="L3174"></span>
<span class="line" id="L3175">        <span class="tok-kw">if</span> (self.force_pic) |pic| {</span>
<span class="line" id="L3176">            <span class="tok-kw">if</span> (pic) {</span>
<span class="line" id="L3177">                <span class="tok-kw">try</span> zig_args.append(<span class="tok-str">&quot;-fPIC&quot;</span>);</span>
<span class="line" id="L3178">            } <span class="tok-kw">else</span> {</span>
<span class="line" id="L3179">                <span class="tok-kw">try</span> zig_args.append(<span class="tok-str">&quot;-fno-PIC&quot;</span>);</span>
<span class="line" id="L3180">            }</span>
<span class="line" id="L3181">        }</span>
<span class="line" id="L3182"></span>
<span class="line" id="L3183">        <span class="tok-kw">if</span> (self.pie) |pie| {</span>
<span class="line" id="L3184">            <span class="tok-kw">if</span> (pie) {</span>
<span class="line" id="L3185">                <span class="tok-kw">try</span> zig_args.append(<span class="tok-str">&quot;-fPIE&quot;</span>);</span>
<span class="line" id="L3186">            } <span class="tok-kw">else</span> {</span>
<span class="line" id="L3187">                <span class="tok-kw">try</span> zig_args.append(<span class="tok-str">&quot;-fno-PIE&quot;</span>);</span>
<span class="line" id="L3188">            }</span>
<span class="line" id="L3189">        }</span>
<span class="line" id="L3190"></span>
<span class="line" id="L3191">        <span class="tok-kw">if</span> (self.want_lto) |lto| {</span>
<span class="line" id="L3192">            <span class="tok-kw">if</span> (lto) {</span>
<span class="line" id="L3193">                <span class="tok-kw">try</span> zig_args.append(<span class="tok-str">&quot;-flto&quot;</span>);</span>
<span class="line" id="L3194">            } <span class="tok-kw">else</span> {</span>
<span class="line" id="L3195">                <span class="tok-kw">try</span> zig_args.append(<span class="tok-str">&quot;-fno-lto&quot;</span>);</span>
<span class="line" id="L3196">            }</span>
<span class="line" id="L3197">        }</span>
<span class="line" id="L3198"></span>
<span class="line" id="L3199">        <span class="tok-kw">if</span> (self.subsystem) |subsystem| {</span>
<span class="line" id="L3200">            <span class="tok-kw">try</span> zig_args.append(<span class="tok-str">&quot;--subsystem&quot;</span>);</span>
<span class="line" id="L3201">            <span class="tok-kw">try</span> zig_args.append(<span class="tok-kw">switch</span> (subsystem) {</span>
<span class="line" id="L3202">                .Console =&gt; <span class="tok-str">&quot;console&quot;</span>,</span>
<span class="line" id="L3203">                .Windows =&gt; <span class="tok-str">&quot;windows&quot;</span>,</span>
<span class="line" id="L3204">                .Posix =&gt; <span class="tok-str">&quot;posix&quot;</span>,</span>
<span class="line" id="L3205">                .Native =&gt; <span class="tok-str">&quot;native&quot;</span>,</span>
<span class="line" id="L3206">                .EfiApplication =&gt; <span class="tok-str">&quot;efi_application&quot;</span>,</span>
<span class="line" id="L3207">                .EfiBootServiceDriver =&gt; <span class="tok-str">&quot;efi_boot_service_driver&quot;</span>,</span>
<span class="line" id="L3208">                .EfiRom =&gt; <span class="tok-str">&quot;efi_rom&quot;</span>,</span>
<span class="line" id="L3209">                .EfiRuntimeDriver =&gt; <span class="tok-str">&quot;efi_runtime_driver&quot;</span>,</span>
<span class="line" id="L3210">            });</span>
<span class="line" id="L3211">        }</span>
<span class="line" id="L3212"></span>
<span class="line" id="L3213">        <span class="tok-kw">try</span> zig_args.append(<span class="tok-str">&quot;--enable-cache&quot;</span>);</span>
<span class="line" id="L3214"></span>
<span class="line" id="L3215">        <span class="tok-comment">// Windows has an argument length limit of 32,766 characters, macOS 262,144 and Linux</span>
</span>
<span class="line" id="L3216">        <span class="tok-comment">// 2,097,152. If our args exceed 30 KiB, we instead write them to a &quot;response file&quot; and</span>
</span>
<span class="line" id="L3217">        <span class="tok-comment">// pass that to zig, e.g. via 'zig build-lib @args.rsp'</span>
</span>
<span class="line" id="L3218">        <span class="tok-comment">// See @file syntax here: https://gcc.gnu.org/onlinedocs/gcc/Overall-Options.html</span>
</span>
<span class="line" id="L3219">        <span class="tok-kw">var</span> args_length: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L3220">        <span class="tok-kw">for</span> (zig_args.items) |arg| {</span>
<span class="line" id="L3221">            args_length += arg.len + <span class="tok-number">1</span>; <span class="tok-comment">// +1 to account for null terminator</span>
</span>
<span class="line" id="L3222">        }</span>
<span class="line" id="L3223">        <span class="tok-kw">if</span> (args_length &gt;= <span class="tok-number">30</span> * <span class="tok-number">1024</span>) {</span>
<span class="line" id="L3224">            <span class="tok-kw">const</span> args_dir = <span class="tok-kw">try</span> fs.path.join(</span>
<span class="line" id="L3225">                builder.allocator,</span>
<span class="line" id="L3226">                &amp;[_][]<span class="tok-kw">const</span> <span class="tok-type">u8</span>{ builder.pathFromRoot(<span class="tok-str">&quot;zig-cache&quot;</span>), <span class="tok-str">&quot;args&quot;</span> },</span>
<span class="line" id="L3227">            );</span>
<span class="line" id="L3228">            <span class="tok-kw">try</span> std.fs.cwd().makePath(args_dir);</span>
<span class="line" id="L3229"></span>
<span class="line" id="L3230">            <span class="tok-kw">var</span> args_arena = std.heap.ArenaAllocator.init(builder.allocator);</span>
<span class="line" id="L3231">            <span class="tok-kw">defer</span> args_arena.deinit();</span>
<span class="line" id="L3232"></span>
<span class="line" id="L3233">            <span class="tok-kw">const</span> args_to_escape = zig_args.items[<span class="tok-number">2</span>..];</span>
<span class="line" id="L3234">            <span class="tok-kw">var</span> escaped_args = <span class="tok-kw">try</span> ArrayList([]<span class="tok-kw">const</span> <span class="tok-type">u8</span>).initCapacity(args_arena.allocator(), args_to_escape.len);</span>
<span class="line" id="L3235"></span>
<span class="line" id="L3236">            arg_blk: <span class="tok-kw">for</span> (args_to_escape) |arg| {</span>
<span class="line" id="L3237">                <span class="tok-kw">for</span> (arg) |c, arg_idx| {</span>
<span class="line" id="L3238">                    <span class="tok-kw">if</span> (c == <span class="tok-str">'\\'</span> <span class="tok-kw">or</span> c == <span class="tok-str">'&quot;'</span>) {</span>
<span class="line" id="L3239">                        <span class="tok-comment">// Slow path for arguments that need to be escaped. We'll need to allocate and copy</span>
</span>
<span class="line" id="L3240">                        <span class="tok-kw">var</span> escaped = <span class="tok-kw">try</span> ArrayList(<span class="tok-type">u8</span>).initCapacity(args_arena.allocator(), arg.len + <span class="tok-number">1</span>);</span>
<span class="line" id="L3241">                        <span class="tok-kw">const</span> writer = escaped.writer();</span>
<span class="line" id="L3242">                        writer.writeAll(arg[<span class="tok-number">0</span>..arg_idx]) <span class="tok-kw">catch</span> <span class="tok-kw">unreachable</span>;</span>
<span class="line" id="L3243">                        <span class="tok-kw">for</span> (arg[arg_idx..]) |to_escape| {</span>
<span class="line" id="L3244">                            <span class="tok-kw">if</span> (to_escape == <span class="tok-str">'\\'</span> <span class="tok-kw">or</span> to_escape == <span class="tok-str">'&quot;'</span>) <span class="tok-kw">try</span> writer.writeByte(<span class="tok-str">'\\'</span>);</span>
<span class="line" id="L3245">                            <span class="tok-kw">try</span> writer.writeByte(to_escape);</span>
<span class="line" id="L3246">                        }</span>
<span class="line" id="L3247">                        escaped_args.appendAssumeCapacity(escaped.items);</span>
<span class="line" id="L3248">                        <span class="tok-kw">continue</span> :arg_blk;</span>
<span class="line" id="L3249">                    }</span>
<span class="line" id="L3250">                }</span>
<span class="line" id="L3251">                escaped_args.appendAssumeCapacity(arg); <span class="tok-comment">// no escaping needed so just use original argument</span>
</span>
<span class="line" id="L3252">            }</span>
<span class="line" id="L3253"></span>
<span class="line" id="L3254">            <span class="tok-comment">// Write the args to zig-cache/args/&lt;SHA256 hash of args&gt; to avoid conflicts with</span>
</span>
<span class="line" id="L3255">            <span class="tok-comment">// other zig build commands running in parallel.</span>
</span>
<span class="line" id="L3256">            <span class="tok-kw">const</span> partially_quoted = <span class="tok-kw">try</span> std.mem.join(builder.allocator, <span class="tok-str">&quot;\&quot; \&quot;&quot;</span>, escaped_args.items);</span>
<span class="line" id="L3257">            <span class="tok-kw">const</span> args = <span class="tok-kw">try</span> std.mem.concat(builder.allocator, <span class="tok-type">u8</span>, &amp;[_][]<span class="tok-kw">const</span> <span class="tok-type">u8</span>{ <span class="tok-str">&quot;\&quot;&quot;</span>, partially_quoted, <span class="tok-str">&quot;\&quot;&quot;</span> });</span>
<span class="line" id="L3258"></span>
<span class="line" id="L3259">            <span class="tok-kw">var</span> args_hash: [Sha256.digest_length]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L3260">            Sha256.hash(args, &amp;args_hash, .{});</span>
<span class="line" id="L3261">            <span class="tok-kw">var</span> args_hex_hash: [Sha256.digest_length * <span class="tok-number">2</span>]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L3262">            _ = <span class="tok-kw">try</span> std.fmt.bufPrint(</span>
<span class="line" id="L3263">                &amp;args_hex_hash,</span>
<span class="line" id="L3264">                <span class="tok-str">&quot;{s}&quot;</span>,</span>
<span class="line" id="L3265">                .{std.fmt.fmtSliceHexLower(&amp;args_hash)},</span>
<span class="line" id="L3266">            );</span>
<span class="line" id="L3267"></span>
<span class="line" id="L3268">            <span class="tok-kw">const</span> args_file = <span class="tok-kw">try</span> fs.path.join(builder.allocator, &amp;[_][]<span class="tok-kw">const</span> <span class="tok-type">u8</span>{ args_dir, args_hex_hash[<span class="tok-number">0</span>..] });</span>
<span class="line" id="L3269">            <span class="tok-kw">try</span> std.fs.cwd().writeFile(args_file, args);</span>
<span class="line" id="L3270"></span>
<span class="line" id="L3271">            zig_args.shrinkRetainingCapacity(<span class="tok-number">2</span>);</span>
<span class="line" id="L3272">            <span class="tok-kw">try</span> zig_args.append(<span class="tok-kw">try</span> std.mem.concat(builder.allocator, <span class="tok-type">u8</span>, &amp;[_][]<span class="tok-kw">const</span> <span class="tok-type">u8</span>{ <span class="tok-str">&quot;@&quot;</span>, args_file }));</span>
<span class="line" id="L3273">        }</span>
<span class="line" id="L3274"></span>
<span class="line" id="L3275">        <span class="tok-kw">const</span> output_dir_nl = <span class="tok-kw">try</span> builder.execFromStep(zig_args.items, &amp;self.step);</span>
<span class="line" id="L3276">        <span class="tok-kw">const</span> build_output_dir = mem.trimRight(<span class="tok-type">u8</span>, output_dir_nl, <span class="tok-str">&quot;\r\n&quot;</span>);</span>
<span class="line" id="L3277"></span>
<span class="line" id="L3278">        <span class="tok-kw">if</span> (self.output_dir) |output_dir| {</span>
<span class="line" id="L3279">            <span class="tok-kw">var</span> src_dir = <span class="tok-kw">try</span> std.fs.cwd().openIterableDir(build_output_dir, .{});</span>
<span class="line" id="L3280">            <span class="tok-kw">defer</span> src_dir.close();</span>
<span class="line" id="L3281"></span>
<span class="line" id="L3282">            <span class="tok-comment">// Create the output directory if it doesn't exist.</span>
</span>
<span class="line" id="L3283">            <span class="tok-kw">try</span> std.fs.cwd().makePath(output_dir);</span>
<span class="line" id="L3284"></span>
<span class="line" id="L3285">            <span class="tok-kw">var</span> dest_dir = <span class="tok-kw">try</span> std.fs.cwd().openDir(output_dir, .{});</span>
<span class="line" id="L3286">            <span class="tok-kw">defer</span> dest_dir.close();</span>
<span class="line" id="L3287"></span>
<span class="line" id="L3288">            <span class="tok-kw">var</span> it = src_dir.iterate();</span>
<span class="line" id="L3289">            <span class="tok-kw">while</span> (<span class="tok-kw">try</span> it.next()) |entry| {</span>
<span class="line" id="L3290">                <span class="tok-comment">// The compiler can put these files into the same directory, but we don't</span>
</span>
<span class="line" id="L3291">                <span class="tok-comment">// want to copy them over.</span>
</span>
<span class="line" id="L3292">                <span class="tok-kw">if</span> (mem.eql(<span class="tok-type">u8</span>, entry.name, <span class="tok-str">&quot;stage1.id&quot;</span>) <span class="tok-kw">or</span></span>
<span class="line" id="L3293">                    mem.eql(<span class="tok-type">u8</span>, entry.name, <span class="tok-str">&quot;llvm-ar.id&quot;</span>) <span class="tok-kw">or</span></span>
<span class="line" id="L3294">                    mem.eql(<span class="tok-type">u8</span>, entry.name, <span class="tok-str">&quot;libs.txt&quot;</span>) <span class="tok-kw">or</span></span>
<span class="line" id="L3295">                    mem.eql(<span class="tok-type">u8</span>, entry.name, <span class="tok-str">&quot;builtin.zig&quot;</span>) <span class="tok-kw">or</span></span>
<span class="line" id="L3296">                    mem.eql(<span class="tok-type">u8</span>, entry.name, <span class="tok-str">&quot;zld.id&quot;</span>) <span class="tok-kw">or</span></span>
<span class="line" id="L3297">                    mem.eql(<span class="tok-type">u8</span>, entry.name, <span class="tok-str">&quot;lld.id&quot;</span>)) <span class="tok-kw">continue</span>;</span>
<span class="line" id="L3298"></span>
<span class="line" id="L3299">                _ = <span class="tok-kw">try</span> src_dir.dir.updateFile(entry.name, dest_dir, entry.name, .{});</span>
<span class="line" id="L3300">            }</span>
<span class="line" id="L3301">        } <span class="tok-kw">else</span> {</span>
<span class="line" id="L3302">            self.output_dir = build_output_dir;</span>
<span class="line" id="L3303">        }</span>
<span class="line" id="L3304"></span>
<span class="line" id="L3305">        <span class="tok-comment">// This will ensure all output filenames will now have the output_dir available!</span>
</span>
<span class="line" id="L3306">        self.computeOutFileNames();</span>
<span class="line" id="L3307"></span>
<span class="line" id="L3308">        <span class="tok-comment">// Update generated files</span>
</span>
<span class="line" id="L3309">        <span class="tok-kw">if</span> (self.output_dir != <span class="tok-null">null</span>) {</span>
<span class="line" id="L3310">            self.output_path_source.path = builder.pathJoin(</span>
<span class="line" id="L3311">                &amp;.{ self.output_dir.?, self.out_filename },</span>
<span class="line" id="L3312">            );</span>
<span class="line" id="L3313"></span>
<span class="line" id="L3314">            <span class="tok-kw">if</span> (self.emit_h) {</span>
<span class="line" id="L3315">                self.output_h_path_source.path = builder.pathJoin(</span>
<span class="line" id="L3316">                    &amp;.{ self.output_dir.?, self.out_h_filename },</span>
<span class="line" id="L3317">                );</span>
<span class="line" id="L3318">            }</span>
<span class="line" id="L3319"></span>
<span class="line" id="L3320">            <span class="tok-kw">if</span> (self.target.isWindows() <span class="tok-kw">or</span> self.target.isUefi()) {</span>
<span class="line" id="L3321">                self.output_pdb_path_source.path = builder.pathJoin(</span>
<span class="line" id="L3322">                    &amp;.{ self.output_dir.?, self.out_pdb_filename },</span>
<span class="line" id="L3323">                );</span>
<span class="line" id="L3324">            }</span>
<span class="line" id="L3325">        }</span>
<span class="line" id="L3326"></span>
<span class="line" id="L3327">        <span class="tok-kw">if</span> (self.kind == .lib <span class="tok-kw">and</span> self.linkage != <span class="tok-null">null</span> <span class="tok-kw">and</span> self.linkage.? == .dynamic <span class="tok-kw">and</span> self.version != <span class="tok-null">null</span> <span class="tok-kw">and</span> self.target.wantSharedLibSymLinks()) {</span>
<span class="line" id="L3328">            <span class="tok-kw">try</span> doAtomicSymLinks(builder.allocator, self.getOutputSource().getPath(builder), self.major_only_filename.?, self.name_only_filename.?);</span>
<span class="line" id="L3329">        }</span>
<span class="line" id="L3330">    }</span>
<span class="line" id="L3331">};</span>
<span class="line" id="L3332"></span>
<span class="line" id="L3333"><span class="tok-comment">/// Allocates a new string for assigning a value to a named macro.</span></span>
<span class="line" id="L3334"><span class="tok-comment">/// If the value is omitted, it is set to 1.</span></span>
<span class="line" id="L3335"><span class="tok-comment">/// `name` and `value` need not live longer than the function call.</span></span>
<span class="line" id="L3336"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">constructCMacro</span>(allocator: Allocator, name: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>, value: ?[]<span class="tok-kw">const</span> <span class="tok-type">u8</span>) []<span class="tok-kw">const</span> <span class="tok-type">u8</span> {</span>
<span class="line" id="L3337">    <span class="tok-kw">var</span> macro = allocator.alloc(</span>
<span class="line" id="L3338">        <span class="tok-type">u8</span>,</span>
<span class="line" id="L3339">        name.len + <span class="tok-kw">if</span> (value) |value_slice| value_slice.len + <span class="tok-number">1</span> <span class="tok-kw">else</span> <span class="tok-number">0</span>,</span>
<span class="line" id="L3340">    ) <span class="tok-kw">catch</span> |err| <span class="tok-kw">if</span> (err == <span class="tok-kw">error</span>.OutOfMemory) <span class="tok-builtin">@panic</span>(<span class="tok-str">&quot;Out of memory&quot;</span>) <span class="tok-kw">else</span> <span class="tok-kw">unreachable</span>;</span>
<span class="line" id="L3341">    mem.copy(<span class="tok-type">u8</span>, macro, name);</span>
<span class="line" id="L3342">    <span class="tok-kw">if</span> (value) |value_slice| {</span>
<span class="line" id="L3343">        macro[name.len] = <span class="tok-str">'='</span>;</span>
<span class="line" id="L3344">        mem.copy(<span class="tok-type">u8</span>, macro[name.len + <span class="tok-number">1</span> ..], value_slice);</span>
<span class="line" id="L3345">    }</span>
<span class="line" id="L3346">    <span class="tok-kw">return</span> macro;</span>
<span class="line" id="L3347">}</span>
<span class="line" id="L3348"></span>
<span class="line" id="L3349"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> InstallArtifactStep = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L3350">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> base_id = .install_artifact;</span>
<span class="line" id="L3351"></span>
<span class="line" id="L3352">    step: Step,</span>
<span class="line" id="L3353">    builder: *Builder,</span>
<span class="line" id="L3354">    artifact: *LibExeObjStep,</span>
<span class="line" id="L3355">    dest_dir: InstallDir,</span>
<span class="line" id="L3356">    pdb_dir: ?InstallDir,</span>
<span class="line" id="L3357">    h_dir: ?InstallDir,</span>
<span class="line" id="L3358"></span>
<span class="line" id="L3359">    <span class="tok-kw">const</span> Self = <span class="tok-builtin">@This</span>();</span>
<span class="line" id="L3360"></span>
<span class="line" id="L3361">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">create</span>(builder: *Builder, artifact: *LibExeObjStep) *Self {</span>
<span class="line" id="L3362">        <span class="tok-kw">if</span> (artifact.install_step) |s| <span class="tok-kw">return</span> s;</span>
<span class="line" id="L3363"></span>
<span class="line" id="L3364">        <span class="tok-kw">const</span> self = builder.allocator.create(Self) <span class="tok-kw">catch</span> <span class="tok-kw">unreachable</span>;</span>
<span class="line" id="L3365">        self.* = Self{</span>
<span class="line" id="L3366">            .builder = builder,</span>
<span class="line" id="L3367">            .step = Step.init(.install_artifact, builder.fmt(<span class="tok-str">&quot;install {s}&quot;</span>, .{artifact.step.name}), builder.allocator, make),</span>
<span class="line" id="L3368">            .artifact = artifact,</span>
<span class="line" id="L3369">            .dest_dir = artifact.override_dest_dir <span class="tok-kw">orelse</span> <span class="tok-kw">switch</span> (artifact.kind) {</span>
<span class="line" id="L3370">                .obj =&gt; <span class="tok-builtin">@panic</span>(<span class="tok-str">&quot;Cannot install a .obj build artifact.&quot;</span>),</span>
<span class="line" id="L3371">                .@&quot;test&quot; =&gt; <span class="tok-builtin">@panic</span>(<span class="tok-str">&quot;Cannot install a test build artifact, use addTestExe instead.&quot;</span>),</span>
<span class="line" id="L3372">                .exe, .test_exe =&gt; InstallDir{ .bin = {} },</span>
<span class="line" id="L3373">                .lib =&gt; InstallDir{ .lib = {} },</span>
<span class="line" id="L3374">            },</span>
<span class="line" id="L3375">            .pdb_dir = <span class="tok-kw">if</span> (artifact.producesPdbFile()) blk: {</span>
<span class="line" id="L3376">                <span class="tok-kw">if</span> (artifact.kind == .exe <span class="tok-kw">or</span> artifact.kind == .test_exe) {</span>
<span class="line" id="L3377">                    <span class="tok-kw">break</span> :blk InstallDir{ .bin = {} };</span>
<span class="line" id="L3378">                } <span class="tok-kw">else</span> {</span>
<span class="line" id="L3379">                    <span class="tok-kw">break</span> :blk InstallDir{ .lib = {} };</span>
<span class="line" id="L3380">                }</span>
<span class="line" id="L3381">            } <span class="tok-kw">else</span> <span class="tok-null">null</span>,</span>
<span class="line" id="L3382">            .h_dir = <span class="tok-kw">if</span> (artifact.kind == .lib <span class="tok-kw">and</span> artifact.emit_h) .header <span class="tok-kw">else</span> <span class="tok-null">null</span>,</span>
<span class="line" id="L3383">        };</span>
<span class="line" id="L3384">        self.step.dependOn(&amp;artifact.step);</span>
<span class="line" id="L3385">        artifact.install_step = self;</span>
<span class="line" id="L3386"></span>
<span class="line" id="L3387">        builder.pushInstalledFile(self.dest_dir, artifact.out_filename);</span>
<span class="line" id="L3388">        <span class="tok-kw">if</span> (self.artifact.isDynamicLibrary()) {</span>
<span class="line" id="L3389">            <span class="tok-kw">if</span> (artifact.major_only_filename) |name| {</span>
<span class="line" id="L3390">                builder.pushInstalledFile(.lib, name);</span>
<span class="line" id="L3391">            }</span>
<span class="line" id="L3392">            <span class="tok-kw">if</span> (artifact.name_only_filename) |name| {</span>
<span class="line" id="L3393">                builder.pushInstalledFile(.lib, name);</span>
<span class="line" id="L3394">            }</span>
<span class="line" id="L3395">            <span class="tok-kw">if</span> (self.artifact.target.isWindows()) {</span>
<span class="line" id="L3396">                builder.pushInstalledFile(.lib, artifact.out_lib_filename);</span>
<span class="line" id="L3397">            }</span>
<span class="line" id="L3398">        }</span>
<span class="line" id="L3399">        <span class="tok-kw">if</span> (self.pdb_dir) |pdb_dir| {</span>
<span class="line" id="L3400">            builder.pushInstalledFile(pdb_dir, artifact.out_pdb_filename);</span>
<span class="line" id="L3401">        }</span>
<span class="line" id="L3402">        <span class="tok-kw">if</span> (self.h_dir) |h_dir| {</span>
<span class="line" id="L3403">            builder.pushInstalledFile(h_dir, artifact.out_h_filename);</span>
<span class="line" id="L3404">        }</span>
<span class="line" id="L3405">        <span class="tok-kw">return</span> self;</span>
<span class="line" id="L3406">    }</span>
<span class="line" id="L3407"></span>
<span class="line" id="L3408">    <span class="tok-kw">fn</span> <span class="tok-fn">make</span>(step: *Step) !<span class="tok-type">void</span> {</span>
<span class="line" id="L3409">        <span class="tok-kw">const</span> self = <span class="tok-builtin">@fieldParentPtr</span>(Self, <span class="tok-str">&quot;step&quot;</span>, step);</span>
<span class="line" id="L3410">        <span class="tok-kw">const</span> builder = self.builder;</span>
<span class="line" id="L3411"></span>
<span class="line" id="L3412">        <span class="tok-kw">const</span> full_dest_path = builder.getInstallPath(self.dest_dir, self.artifact.out_filename);</span>
<span class="line" id="L3413">        <span class="tok-kw">try</span> builder.updateFile(self.artifact.getOutputSource().getPath(builder), full_dest_path);</span>
<span class="line" id="L3414">        <span class="tok-kw">if</span> (self.artifact.isDynamicLibrary() <span class="tok-kw">and</span> self.artifact.version != <span class="tok-null">null</span> <span class="tok-kw">and</span> self.artifact.target.wantSharedLibSymLinks()) {</span>
<span class="line" id="L3415">            <span class="tok-kw">try</span> doAtomicSymLinks(builder.allocator, full_dest_path, self.artifact.major_only_filename.?, self.artifact.name_only_filename.?);</span>
<span class="line" id="L3416">        }</span>
<span class="line" id="L3417">        <span class="tok-kw">if</span> (self.artifact.isDynamicLibrary() <span class="tok-kw">and</span> self.artifact.target.isWindows() <span class="tok-kw">and</span> self.artifact.emit_implib != .no_emit) {</span>
<span class="line" id="L3418">            <span class="tok-kw">const</span> full_implib_path = builder.getInstallPath(self.dest_dir, self.artifact.out_lib_filename);</span>
<span class="line" id="L3419">            <span class="tok-kw">try</span> builder.updateFile(self.artifact.getOutputLibSource().getPath(builder), full_implib_path);</span>
<span class="line" id="L3420">        }</span>
<span class="line" id="L3421">        <span class="tok-kw">if</span> (self.pdb_dir) |pdb_dir| {</span>
<span class="line" id="L3422">            <span class="tok-kw">const</span> full_pdb_path = builder.getInstallPath(pdb_dir, self.artifact.out_pdb_filename);</span>
<span class="line" id="L3423">            <span class="tok-kw">try</span> builder.updateFile(self.artifact.getOutputPdbSource().getPath(builder), full_pdb_path);</span>
<span class="line" id="L3424">        }</span>
<span class="line" id="L3425">        <span class="tok-kw">if</span> (self.h_dir) |h_dir| {</span>
<span class="line" id="L3426">            <span class="tok-kw">const</span> full_pdb_path = builder.getInstallPath(h_dir, self.artifact.out_h_filename);</span>
<span class="line" id="L3427">            <span class="tok-kw">try</span> builder.updateFile(self.artifact.getOutputHSource().getPath(builder), full_pdb_path);</span>
<span class="line" id="L3428">        }</span>
<span class="line" id="L3429">        self.artifact.installed_path = full_dest_path;</span>
<span class="line" id="L3430">    }</span>
<span class="line" id="L3431">};</span>
<span class="line" id="L3432"></span>
<span class="line" id="L3433"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> InstallFileStep = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L3434">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> base_id = .install_file;</span>
<span class="line" id="L3435"></span>
<span class="line" id="L3436">    step: Step,</span>
<span class="line" id="L3437">    builder: *Builder,</span>
<span class="line" id="L3438">    source: FileSource,</span>
<span class="line" id="L3439">    dir: InstallDir,</span>
<span class="line" id="L3440">    dest_rel_path: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>,</span>
<span class="line" id="L3441"></span>
<span class="line" id="L3442">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">init</span>(</span>
<span class="line" id="L3443">        builder: *Builder,</span>
<span class="line" id="L3444">        source: FileSource,</span>
<span class="line" id="L3445">        dir: InstallDir,</span>
<span class="line" id="L3446">        dest_rel_path: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>,</span>
<span class="line" id="L3447">    ) InstallFileStep {</span>
<span class="line" id="L3448">        builder.pushInstalledFile(dir, dest_rel_path);</span>
<span class="line" id="L3449">        <span class="tok-kw">return</span> InstallFileStep{</span>
<span class="line" id="L3450">            .builder = builder,</span>
<span class="line" id="L3451">            .step = Step.init(.install_file, builder.fmt(<span class="tok-str">&quot;install {s} to {s}&quot;</span>, .{ source.getDisplayName(), dest_rel_path }), builder.allocator, make),</span>
<span class="line" id="L3452">            .source = source.dupe(builder),</span>
<span class="line" id="L3453">            .dir = dir.dupe(builder),</span>
<span class="line" id="L3454">            .dest_rel_path = builder.dupePath(dest_rel_path),</span>
<span class="line" id="L3455">        };</span>
<span class="line" id="L3456">    }</span>
<span class="line" id="L3457"></span>
<span class="line" id="L3458">    <span class="tok-kw">fn</span> <span class="tok-fn">make</span>(step: *Step) !<span class="tok-type">void</span> {</span>
<span class="line" id="L3459">        <span class="tok-kw">const</span> self = <span class="tok-builtin">@fieldParentPtr</span>(InstallFileStep, <span class="tok-str">&quot;step&quot;</span>, step);</span>
<span class="line" id="L3460">        <span class="tok-kw">const</span> full_dest_path = self.builder.getInstallPath(self.dir, self.dest_rel_path);</span>
<span class="line" id="L3461">        <span class="tok-kw">const</span> full_src_path = self.source.getPath(self.builder);</span>
<span class="line" id="L3462">        <span class="tok-kw">try</span> self.builder.updateFile(full_src_path, full_dest_path);</span>
<span class="line" id="L3463">    }</span>
<span class="line" id="L3464">};</span>
<span class="line" id="L3465"></span>
<span class="line" id="L3466"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> InstallDirectoryOptions = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L3467">    source_dir: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>,</span>
<span class="line" id="L3468">    install_dir: InstallDir,</span>
<span class="line" id="L3469">    install_subdir: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>,</span>
<span class="line" id="L3470">    <span class="tok-comment">/// File paths which end in any of these suffixes will be excluded</span></span>
<span class="line" id="L3471">    <span class="tok-comment">/// from being installed.</span></span>
<span class="line" id="L3472">    exclude_extensions: []<span class="tok-kw">const</span> []<span class="tok-kw">const</span> <span class="tok-type">u8</span> = &amp;.{},</span>
<span class="line" id="L3473">    <span class="tok-comment">/// File paths which end in any of these suffixes will result in</span></span>
<span class="line" id="L3474">    <span class="tok-comment">/// empty files being installed. This is mainly intended for large</span></span>
<span class="line" id="L3475">    <span class="tok-comment">/// test.zig files in order to prevent needless installation bloat.</span></span>
<span class="line" id="L3476">    <span class="tok-comment">/// However if the files were not present at all, then</span></span>
<span class="line" id="L3477">    <span class="tok-comment">/// `@import(&quot;test.zig&quot;)` would be a compile error.</span></span>
<span class="line" id="L3478">    blank_extensions: []<span class="tok-kw">const</span> []<span class="tok-kw">const</span> <span class="tok-type">u8</span> = &amp;.{},</span>
<span class="line" id="L3479"></span>
<span class="line" id="L3480">    <span class="tok-kw">fn</span> <span class="tok-fn">dupe</span>(self: InstallDirectoryOptions, b: *Builder) InstallDirectoryOptions {</span>
<span class="line" id="L3481">        <span class="tok-kw">return</span> .{</span>
<span class="line" id="L3482">            .source_dir = b.dupe(self.source_dir),</span>
<span class="line" id="L3483">            .install_dir = self.install_dir.dupe(b),</span>
<span class="line" id="L3484">            .install_subdir = b.dupe(self.install_subdir),</span>
<span class="line" id="L3485">            .exclude_extensions = b.dupeStrings(self.exclude_extensions),</span>
<span class="line" id="L3486">            .blank_extensions = b.dupeStrings(self.blank_extensions),</span>
<span class="line" id="L3487">        };</span>
<span class="line" id="L3488">    }</span>
<span class="line" id="L3489">};</span>
<span class="line" id="L3490"></span>
<span class="line" id="L3491"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> InstallDirStep = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L3492">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> base_id = .install_dir;</span>
<span class="line" id="L3493"></span>
<span class="line" id="L3494">    step: Step,</span>
<span class="line" id="L3495">    builder: *Builder,</span>
<span class="line" id="L3496">    options: InstallDirectoryOptions,</span>
<span class="line" id="L3497"></span>
<span class="line" id="L3498">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">init</span>(</span>
<span class="line" id="L3499">        builder: *Builder,</span>
<span class="line" id="L3500">        options: InstallDirectoryOptions,</span>
<span class="line" id="L3501">    ) InstallDirStep {</span>
<span class="line" id="L3502">        builder.pushInstalledFile(options.install_dir, options.install_subdir);</span>
<span class="line" id="L3503">        <span class="tok-kw">return</span> InstallDirStep{</span>
<span class="line" id="L3504">            .builder = builder,</span>
<span class="line" id="L3505">            .step = Step.init(.install_dir, builder.fmt(<span class="tok-str">&quot;install {s}/&quot;</span>, .{options.source_dir}), builder.allocator, make),</span>
<span class="line" id="L3506">            .options = options.dupe(builder),</span>
<span class="line" id="L3507">        };</span>
<span class="line" id="L3508">    }</span>
<span class="line" id="L3509"></span>
<span class="line" id="L3510">    <span class="tok-kw">fn</span> <span class="tok-fn">make</span>(step: *Step) !<span class="tok-type">void</span> {</span>
<span class="line" id="L3511">        <span class="tok-kw">const</span> self = <span class="tok-builtin">@fieldParentPtr</span>(InstallDirStep, <span class="tok-str">&quot;step&quot;</span>, step);</span>
<span class="line" id="L3512">        <span class="tok-kw">const</span> dest_prefix = self.builder.getInstallPath(self.options.install_dir, self.options.install_subdir);</span>
<span class="line" id="L3513">        <span class="tok-kw">const</span> full_src_dir = self.builder.pathFromRoot(self.options.source_dir);</span>
<span class="line" id="L3514">        <span class="tok-kw">var</span> src_dir = <span class="tok-kw">try</span> std.fs.cwd().openIterableDir(full_src_dir, .{});</span>
<span class="line" id="L3515">        <span class="tok-kw">defer</span> src_dir.close();</span>
<span class="line" id="L3516">        <span class="tok-kw">var</span> it = <span class="tok-kw">try</span> src_dir.walk(self.builder.allocator);</span>
<span class="line" id="L3517">        next_entry: <span class="tok-kw">while</span> (<span class="tok-kw">try</span> it.next()) |entry| {</span>
<span class="line" id="L3518">            <span class="tok-kw">for</span> (self.options.exclude_extensions) |ext| {</span>
<span class="line" id="L3519">                <span class="tok-kw">if</span> (mem.endsWith(<span class="tok-type">u8</span>, entry.path, ext)) {</span>
<span class="line" id="L3520">                    <span class="tok-kw">continue</span> :next_entry;</span>
<span class="line" id="L3521">                }</span>
<span class="line" id="L3522">            }</span>
<span class="line" id="L3523"></span>
<span class="line" id="L3524">            <span class="tok-kw">const</span> full_path = self.builder.pathJoin(&amp;.{</span>
<span class="line" id="L3525">                full_src_dir, entry.path,</span>
<span class="line" id="L3526">            });</span>
<span class="line" id="L3527"></span>
<span class="line" id="L3528">            <span class="tok-kw">const</span> dest_path = self.builder.pathJoin(&amp;.{</span>
<span class="line" id="L3529">                dest_prefix, entry.path,</span>
<span class="line" id="L3530">            });</span>
<span class="line" id="L3531"></span>
<span class="line" id="L3532">            <span class="tok-kw">switch</span> (entry.kind) {</span>
<span class="line" id="L3533">                .Directory =&gt; <span class="tok-kw">try</span> fs.cwd().makePath(dest_path),</span>
<span class="line" id="L3534">                .File =&gt; {</span>
<span class="line" id="L3535">                    <span class="tok-kw">for</span> (self.options.blank_extensions) |ext| {</span>
<span class="line" id="L3536">                        <span class="tok-kw">if</span> (mem.endsWith(<span class="tok-type">u8</span>, entry.path, ext)) {</span>
<span class="line" id="L3537">                            <span class="tok-kw">try</span> self.builder.truncateFile(dest_path);</span>
<span class="line" id="L3538">                            <span class="tok-kw">continue</span> :next_entry;</span>
<span class="line" id="L3539">                        }</span>
<span class="line" id="L3540">                    }</span>
<span class="line" id="L3541"></span>
<span class="line" id="L3542">                    <span class="tok-kw">try</span> self.builder.updateFile(full_path, dest_path);</span>
<span class="line" id="L3543">                },</span>
<span class="line" id="L3544">                <span class="tok-kw">else</span> =&gt; <span class="tok-kw">continue</span>,</span>
<span class="line" id="L3545">            }</span>
<span class="line" id="L3546">        }</span>
<span class="line" id="L3547">    }</span>
<span class="line" id="L3548">};</span>
<span class="line" id="L3549"></span>
<span class="line" id="L3550"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> LogStep = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L3551">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> base_id = .log;</span>
<span class="line" id="L3552"></span>
<span class="line" id="L3553">    step: Step,</span>
<span class="line" id="L3554">    builder: *Builder,</span>
<span class="line" id="L3555">    data: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>,</span>
<span class="line" id="L3556"></span>
<span class="line" id="L3557">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">init</span>(builder: *Builder, data: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) LogStep {</span>
<span class="line" id="L3558">        <span class="tok-kw">return</span> LogStep{</span>
<span class="line" id="L3559">            .builder = builder,</span>
<span class="line" id="L3560">            .step = Step.init(.log, builder.fmt(<span class="tok-str">&quot;log {s}&quot;</span>, .{data}), builder.allocator, make),</span>
<span class="line" id="L3561">            .data = builder.dupe(data),</span>
<span class="line" id="L3562">        };</span>
<span class="line" id="L3563">    }</span>
<span class="line" id="L3564"></span>
<span class="line" id="L3565">    <span class="tok-kw">fn</span> <span class="tok-fn">make</span>(step: *Step) <span class="tok-type">anyerror</span>!<span class="tok-type">void</span> {</span>
<span class="line" id="L3566">        <span class="tok-kw">const</span> self = <span class="tok-builtin">@fieldParentPtr</span>(LogStep, <span class="tok-str">&quot;step&quot;</span>, step);</span>
<span class="line" id="L3567">        log.info(<span class="tok-str">&quot;{s}&quot;</span>, .{self.data});</span>
<span class="line" id="L3568">    }</span>
<span class="line" id="L3569">};</span>
<span class="line" id="L3570"></span>
<span class="line" id="L3571"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> RemoveDirStep = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L3572">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> base_id = .remove_dir;</span>
<span class="line" id="L3573"></span>
<span class="line" id="L3574">    step: Step,</span>
<span class="line" id="L3575">    builder: *Builder,</span>
<span class="line" id="L3576">    dir_path: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>,</span>
<span class="line" id="L3577"></span>
<span class="line" id="L3578">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">init</span>(builder: *Builder, dir_path: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) RemoveDirStep {</span>
<span class="line" id="L3579">        <span class="tok-kw">return</span> RemoveDirStep{</span>
<span class="line" id="L3580">            .builder = builder,</span>
<span class="line" id="L3581">            .step = Step.init(.remove_dir, builder.fmt(<span class="tok-str">&quot;RemoveDir {s}&quot;</span>, .{dir_path}), builder.allocator, make),</span>
<span class="line" id="L3582">            .dir_path = builder.dupePath(dir_path),</span>
<span class="line" id="L3583">        };</span>
<span class="line" id="L3584">    }</span>
<span class="line" id="L3585"></span>
<span class="line" id="L3586">    <span class="tok-kw">fn</span> <span class="tok-fn">make</span>(step: *Step) !<span class="tok-type">void</span> {</span>
<span class="line" id="L3587">        <span class="tok-kw">const</span> self = <span class="tok-builtin">@fieldParentPtr</span>(RemoveDirStep, <span class="tok-str">&quot;step&quot;</span>, step);</span>
<span class="line" id="L3588"></span>
<span class="line" id="L3589">        <span class="tok-kw">const</span> full_path = self.builder.pathFromRoot(self.dir_path);</span>
<span class="line" id="L3590">        fs.cwd().deleteTree(full_path) <span class="tok-kw">catch</span> |err| {</span>
<span class="line" id="L3591">            log.err(<span class="tok-str">&quot;Unable to remove {s}: {s}&quot;</span>, .{ full_path, <span class="tok-builtin">@errorName</span>(err) });</span>
<span class="line" id="L3592">            <span class="tok-kw">return</span> err;</span>
<span class="line" id="L3593">        };</span>
<span class="line" id="L3594">    }</span>
<span class="line" id="L3595">};</span>
<span class="line" id="L3596"></span>
<span class="line" id="L3597"><span class="tok-kw">const</span> ThisModule = <span class="tok-builtin">@This</span>();</span>
<span class="line" id="L3598"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> Step = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L3599">    id: Id,</span>
<span class="line" id="L3600">    name: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>,</span>
<span class="line" id="L3601">    makeFn: MakeFn,</span>
<span class="line" id="L3602">    dependencies: ArrayList(*Step),</span>
<span class="line" id="L3603">    loop_flag: <span class="tok-type">bool</span>,</span>
<span class="line" id="L3604">    done_flag: <span class="tok-type">bool</span>,</span>
<span class="line" id="L3605"></span>
<span class="line" id="L3606">    <span class="tok-kw">const</span> MakeFn = <span class="tok-kw">switch</span> (builtin.zig_backend) {</span>
<span class="line" id="L3607">        .stage1 =&gt; <span class="tok-kw">fn</span> (self: *Step) <span class="tok-type">anyerror</span>!<span class="tok-type">void</span>,</span>
<span class="line" id="L3608">        <span class="tok-kw">else</span> =&gt; *<span class="tok-kw">const</span> <span class="tok-kw">fn</span> (self: *Step) <span class="tok-type">anyerror</span>!<span class="tok-type">void</span>,</span>
<span class="line" id="L3609">    };</span>
<span class="line" id="L3610"></span>
<span class="line" id="L3611">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> Id = <span class="tok-kw">enum</span> {</span>
<span class="line" id="L3612">        top_level,</span>
<span class="line" id="L3613">        lib_exe_obj,</span>
<span class="line" id="L3614">        install_artifact,</span>
<span class="line" id="L3615">        install_file,</span>
<span class="line" id="L3616">        install_dir,</span>
<span class="line" id="L3617">        log,</span>
<span class="line" id="L3618">        remove_dir,</span>
<span class="line" id="L3619">        fmt,</span>
<span class="line" id="L3620">        translate_c,</span>
<span class="line" id="L3621">        write_file,</span>
<span class="line" id="L3622">        run,</span>
<span class="line" id="L3623">        emulatable_run,</span>
<span class="line" id="L3624">        check_file,</span>
<span class="line" id="L3625">        check_object,</span>
<span class="line" id="L3626">        install_raw,</span>
<span class="line" id="L3627">        options,</span>
<span class="line" id="L3628">        custom,</span>
<span class="line" id="L3629">    };</span>
<span class="line" id="L3630"></span>
<span class="line" id="L3631">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">init</span>(id: Id, name: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>, allocator: Allocator, makeFn: MakeFn) Step {</span>
<span class="line" id="L3632">        <span class="tok-kw">return</span> Step{</span>
<span class="line" id="L3633">            .id = id,</span>
<span class="line" id="L3634">            .name = allocator.dupe(<span class="tok-type">u8</span>, name) <span class="tok-kw">catch</span> <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L3635">            .makeFn = makeFn,</span>
<span class="line" id="L3636">            .dependencies = ArrayList(*Step).init(allocator),</span>
<span class="line" id="L3637">            .loop_flag = <span class="tok-null">false</span>,</span>
<span class="line" id="L3638">            .done_flag = <span class="tok-null">false</span>,</span>
<span class="line" id="L3639">        };</span>
<span class="line" id="L3640">    }</span>
<span class="line" id="L3641">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">initNoOp</span>(id: Id, name: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>, allocator: Allocator) Step {</span>
<span class="line" id="L3642">        <span class="tok-kw">return</span> init(id, name, allocator, makeNoOp);</span>
<span class="line" id="L3643">    }</span>
<span class="line" id="L3644"></span>
<span class="line" id="L3645">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">make</span>(self: *Step) !<span class="tok-type">void</span> {</span>
<span class="line" id="L3646">        <span class="tok-kw">if</span> (self.done_flag) <span class="tok-kw">return</span>;</span>
<span class="line" id="L3647"></span>
<span class="line" id="L3648">        <span class="tok-kw">try</span> self.makeFn(self);</span>
<span class="line" id="L3649">        self.done_flag = <span class="tok-null">true</span>;</span>
<span class="line" id="L3650">    }</span>
<span class="line" id="L3651"></span>
<span class="line" id="L3652">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">dependOn</span>(self: *Step, other: *Step) <span class="tok-type">void</span> {</span>
<span class="line" id="L3653">        self.dependencies.append(other) <span class="tok-kw">catch</span> <span class="tok-kw">unreachable</span>;</span>
<span class="line" id="L3654">    }</span>
<span class="line" id="L3655"></span>
<span class="line" id="L3656">    <span class="tok-kw">fn</span> <span class="tok-fn">makeNoOp</span>(self: *Step) <span class="tok-type">anyerror</span>!<span class="tok-type">void</span> {</span>
<span class="line" id="L3657">        _ = self;</span>
<span class="line" id="L3658">    }</span>
<span class="line" id="L3659"></span>
<span class="line" id="L3660">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">cast</span>(step: *Step, <span class="tok-kw">comptime</span> T: <span class="tok-type">type</span>) ?*T {</span>
<span class="line" id="L3661">        <span class="tok-kw">if</span> (step.id == T.base_id) {</span>
<span class="line" id="L3662">            <span class="tok-kw">return</span> <span class="tok-builtin">@fieldParentPtr</span>(T, <span class="tok-str">&quot;step&quot;</span>, step);</span>
<span class="line" id="L3663">        }</span>
<span class="line" id="L3664">        <span class="tok-kw">return</span> <span class="tok-null">null</span>;</span>
<span class="line" id="L3665">    }</span>
<span class="line" id="L3666">};</span>
<span class="line" id="L3667"></span>
<span class="line" id="L3668"><span class="tok-kw">fn</span> <span class="tok-fn">doAtomicSymLinks</span>(allocator: Allocator, output_path: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>, filename_major_only: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>, filename_name_only: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) !<span class="tok-type">void</span> {</span>
<span class="line" id="L3669">    <span class="tok-kw">const</span> out_dir = fs.path.dirname(output_path) <span class="tok-kw">orelse</span> <span class="tok-str">&quot;.&quot;</span>;</span>
<span class="line" id="L3670">    <span class="tok-kw">const</span> out_basename = fs.path.basename(output_path);</span>
<span class="line" id="L3671">    <span class="tok-comment">// sym link for libfoo.so.1 to libfoo.so.1.2.3</span>
</span>
<span class="line" id="L3672">    <span class="tok-kw">const</span> major_only_path = fs.path.join(</span>
<span class="line" id="L3673">        allocator,</span>
<span class="line" id="L3674">        &amp;[_][]<span class="tok-kw">const</span> <span class="tok-type">u8</span>{ out_dir, filename_major_only },</span>
<span class="line" id="L3675">    ) <span class="tok-kw">catch</span> <span class="tok-kw">unreachable</span>;</span>
<span class="line" id="L3676">    fs.atomicSymLink(allocator, out_basename, major_only_path) <span class="tok-kw">catch</span> |err| {</span>
<span class="line" id="L3677">        log.err(<span class="tok-str">&quot;Unable to symlink {s} -&gt; {s}&quot;</span>, .{ major_only_path, out_basename });</span>
<span class="line" id="L3678">        <span class="tok-kw">return</span> err;</span>
<span class="line" id="L3679">    };</span>
<span class="line" id="L3680">    <span class="tok-comment">// sym link for libfoo.so to libfoo.so.1</span>
</span>
<span class="line" id="L3681">    <span class="tok-kw">const</span> name_only_path = fs.path.join(</span>
<span class="line" id="L3682">        allocator,</span>
<span class="line" id="L3683">        &amp;[_][]<span class="tok-kw">const</span> <span class="tok-type">u8</span>{ out_dir, filename_name_only },</span>
<span class="line" id="L3684">    ) <span class="tok-kw">catch</span> <span class="tok-kw">unreachable</span>;</span>
<span class="line" id="L3685">    fs.atomicSymLink(allocator, filename_major_only, name_only_path) <span class="tok-kw">catch</span> |err| {</span>
<span class="line" id="L3686">        log.err(<span class="tok-str">&quot;Unable to symlink {s} -&gt; {s}&quot;</span>, .{ name_only_path, filename_major_only });</span>
<span class="line" id="L3687">        <span class="tok-kw">return</span> err;</span>
<span class="line" id="L3688">    };</span>
<span class="line" id="L3689">}</span>
<span class="line" id="L3690"></span>
<span class="line" id="L3691"><span class="tok-comment">/// Returned slice must be freed by the caller.</span></span>
<span class="line" id="L3692"><span class="tok-kw">fn</span> <span class="tok-fn">findVcpkgRoot</span>(allocator: Allocator) !?[]<span class="tok-kw">const</span> <span class="tok-type">u8</span> {</span>
<span class="line" id="L3693">    <span class="tok-kw">const</span> appdata_path = <span class="tok-kw">try</span> fs.getAppDataDir(allocator, <span class="tok-str">&quot;vcpkg&quot;</span>);</span>
<span class="line" id="L3694">    <span class="tok-kw">defer</span> allocator.free(appdata_path);</span>
<span class="line" id="L3695"></span>
<span class="line" id="L3696">    <span class="tok-kw">const</span> path_file = <span class="tok-kw">try</span> fs.path.join(allocator, &amp;[_][]<span class="tok-kw">const</span> <span class="tok-type">u8</span>{ appdata_path, <span class="tok-str">&quot;vcpkg.path.txt&quot;</span> });</span>
<span class="line" id="L3697">    <span class="tok-kw">defer</span> allocator.free(path_file);</span>
<span class="line" id="L3698"></span>
<span class="line" id="L3699">    <span class="tok-kw">const</span> file = fs.cwd().openFile(path_file, .{}) <span class="tok-kw">catch</span> <span class="tok-kw">return</span> <span class="tok-null">null</span>;</span>
<span class="line" id="L3700">    <span class="tok-kw">defer</span> file.close();</span>
<span class="line" id="L3701"></span>
<span class="line" id="L3702">    <span class="tok-kw">const</span> size = <span class="tok-builtin">@intCast</span>(<span class="tok-type">usize</span>, <span class="tok-kw">try</span> file.getEndPos());</span>
<span class="line" id="L3703">    <span class="tok-kw">const</span> vcpkg_path = <span class="tok-kw">try</span> allocator.alloc(<span class="tok-type">u8</span>, size);</span>
<span class="line" id="L3704">    <span class="tok-kw">const</span> size_read = <span class="tok-kw">try</span> file.read(vcpkg_path);</span>
<span class="line" id="L3705">    std.debug.assert(size == size_read);</span>
<span class="line" id="L3706"></span>
<span class="line" id="L3707">    <span class="tok-kw">return</span> vcpkg_path;</span>
<span class="line" id="L3708">}</span>
<span class="line" id="L3709"></span>
<span class="line" id="L3710"><span class="tok-kw">const</span> VcpkgRoot = <span class="tok-kw">union</span>(VcpkgRootStatus) {</span>
<span class="line" id="L3711">    unattempted: <span class="tok-type">void</span>,</span>
<span class="line" id="L3712">    not_found: <span class="tok-type">void</span>,</span>
<span class="line" id="L3713">    found: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>,</span>
<span class="line" id="L3714">};</span>
<span class="line" id="L3715"></span>
<span class="line" id="L3716"><span class="tok-kw">const</span> VcpkgRootStatus = <span class="tok-kw">enum</span> {</span>
<span class="line" id="L3717">    unattempted,</span>
<span class="line" id="L3718">    not_found,</span>
<span class="line" id="L3719">    found,</span>
<span class="line" id="L3720">};</span>
<span class="line" id="L3721"></span>
<span class="line" id="L3722"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> InstallDir = <span class="tok-kw">union</span>(<span class="tok-kw">enum</span>) {</span>
<span class="line" id="L3723">    prefix: <span class="tok-type">void</span>,</span>
<span class="line" id="L3724">    lib: <span class="tok-type">void</span>,</span>
<span class="line" id="L3725">    bin: <span class="tok-type">void</span>,</span>
<span class="line" id="L3726">    header: <span class="tok-type">void</span>,</span>
<span class="line" id="L3727">    <span class="tok-comment">/// A path relative to the prefix</span></span>
<span class="line" id="L3728">    custom: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>,</span>
<span class="line" id="L3729"></span>
<span class="line" id="L3730">    <span class="tok-comment">/// Duplicates the install directory including the path if set to custom.</span></span>
<span class="line" id="L3731">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">dupe</span>(self: InstallDir, builder: *Builder) InstallDir {</span>
<span class="line" id="L3732">        <span class="tok-kw">if</span> (self == .custom) {</span>
<span class="line" id="L3733">            <span class="tok-comment">// Written with this temporary to avoid RLS problems</span>
</span>
<span class="line" id="L3734">            <span class="tok-kw">const</span> duped_path = builder.dupe(self.custom);</span>
<span class="line" id="L3735">            <span class="tok-kw">return</span> .{ .custom = duped_path };</span>
<span class="line" id="L3736">        } <span class="tok-kw">else</span> {</span>
<span class="line" id="L3737">            <span class="tok-kw">return</span> self;</span>
<span class="line" id="L3738">        }</span>
<span class="line" id="L3739">    }</span>
<span class="line" id="L3740">};</span>
<span class="line" id="L3741"></span>
<span class="line" id="L3742"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> InstalledFile = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L3743">    dir: InstallDir,</span>
<span class="line" id="L3744">    path: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>,</span>
<span class="line" id="L3745"></span>
<span class="line" id="L3746">    <span class="tok-comment">/// Duplicates the installed file path and directory.</span></span>
<span class="line" id="L3747">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">dupe</span>(self: InstalledFile, builder: *Builder) InstalledFile {</span>
<span class="line" id="L3748">        <span class="tok-kw">return</span> .{</span>
<span class="line" id="L3749">            .dir = self.dir.dupe(builder),</span>
<span class="line" id="L3750">            .path = builder.dupe(self.path),</span>
<span class="line" id="L3751">        };</span>
<span class="line" id="L3752">    }</span>
<span class="line" id="L3753">};</span>
<span class="line" id="L3754"></span>
<span class="line" id="L3755"><span class="tok-kw">test</span> <span class="tok-str">&quot;Builder.dupePkg()&quot;</span> {</span>
<span class="line" id="L3756">    <span class="tok-kw">if</span> (builtin.os.tag == .wasi) <span class="tok-kw">return</span> <span class="tok-kw">error</span>.SkipZigTest;</span>
<span class="line" id="L3757"></span>
<span class="line" id="L3758">    <span class="tok-kw">var</span> arena = std.heap.ArenaAllocator.init(std.testing.allocator);</span>
<span class="line" id="L3759">    <span class="tok-kw">defer</span> arena.deinit();</span>
<span class="line" id="L3760">    <span class="tok-kw">var</span> builder = <span class="tok-kw">try</span> Builder.create(</span>
<span class="line" id="L3761">        arena.allocator(),</span>
<span class="line" id="L3762">        <span class="tok-str">&quot;test&quot;</span>,</span>
<span class="line" id="L3763">        <span class="tok-str">&quot;test&quot;</span>,</span>
<span class="line" id="L3764">        <span class="tok-str">&quot;test&quot;</span>,</span>
<span class="line" id="L3765">        <span class="tok-str">&quot;test&quot;</span>,</span>
<span class="line" id="L3766">    );</span>
<span class="line" id="L3767">    <span class="tok-kw">defer</span> builder.destroy();</span>
<span class="line" id="L3768"></span>
<span class="line" id="L3769">    <span class="tok-kw">var</span> pkg_dep = Pkg{</span>
<span class="line" id="L3770">        .name = <span class="tok-str">&quot;pkg_dep&quot;</span>,</span>
<span class="line" id="L3771">        .source = .{ .path = <span class="tok-str">&quot;/not/a/pkg_dep.zig&quot;</span> },</span>
<span class="line" id="L3772">    };</span>
<span class="line" id="L3773">    <span class="tok-kw">var</span> pkg_top = Pkg{</span>
<span class="line" id="L3774">        .name = <span class="tok-str">&quot;pkg_top&quot;</span>,</span>
<span class="line" id="L3775">        .source = .{ .path = <span class="tok-str">&quot;/not/a/pkg_top.zig&quot;</span> },</span>
<span class="line" id="L3776">        .dependencies = &amp;[_]Pkg{pkg_dep},</span>
<span class="line" id="L3777">    };</span>
<span class="line" id="L3778">    <span class="tok-kw">const</span> dupe = builder.dupePkg(pkg_top);</span>
<span class="line" id="L3779"></span>
<span class="line" id="L3780">    <span class="tok-kw">const</span> original_deps = pkg_top.dependencies.?;</span>
<span class="line" id="L3781">    <span class="tok-kw">const</span> dupe_deps = dupe.dependencies.?;</span>
<span class="line" id="L3782"></span>
<span class="line" id="L3783">    <span class="tok-comment">// probably the same top level package details</span>
</span>
<span class="line" id="L3784">    <span class="tok-kw">try</span> std.testing.expectEqualStrings(pkg_top.name, dupe.name);</span>
<span class="line" id="L3785"></span>
<span class="line" id="L3786">    <span class="tok-comment">// probably the same dependencies</span>
</span>
<span class="line" id="L3787">    <span class="tok-kw">try</span> std.testing.expectEqual(original_deps.len, dupe_deps.len);</span>
<span class="line" id="L3788">    <span class="tok-kw">try</span> std.testing.expectEqual(original_deps[<span class="tok-number">0</span>].name, pkg_dep.name);</span>
<span class="line" id="L3789"></span>
<span class="line" id="L3790">    <span class="tok-comment">// could segfault otherwise if pointers in duplicated package's fields are</span>
</span>
<span class="line" id="L3791">    <span class="tok-comment">// the same as those in stack allocated package's fields</span>
</span>
<span class="line" id="L3792">    <span class="tok-kw">try</span> std.testing.expect(dupe_deps.ptr != original_deps.ptr);</span>
<span class="line" id="L3793">    <span class="tok-kw">try</span> std.testing.expect(dupe.name.ptr != pkg_top.name.ptr);</span>
<span class="line" id="L3794">    <span class="tok-kw">try</span> std.testing.expect(dupe.source.path.ptr != pkg_top.source.path.ptr);</span>
<span class="line" id="L3795">    <span class="tok-kw">try</span> std.testing.expect(dupe_deps[<span class="tok-number">0</span>].name.ptr != pkg_dep.name.ptr);</span>
<span class="line" id="L3796">    <span class="tok-kw">try</span> std.testing.expect(dupe_deps[<span class="tok-number">0</span>].source.path.ptr != pkg_dep.source.path.ptr);</span>
<span class="line" id="L3797">}</span>
<span class="line" id="L3798"></span>
<span class="line" id="L3799"><span class="tok-kw">test</span> <span class="tok-str">&quot;LibExeObjStep.addPackage&quot;</span> {</span>
<span class="line" id="L3800">    <span class="tok-kw">if</span> (builtin.os.tag == .wasi) <span class="tok-kw">return</span> <span class="tok-kw">error</span>.SkipZigTest;</span>
<span class="line" id="L3801"></span>
<span class="line" id="L3802">    <span class="tok-kw">var</span> arena = std.heap.ArenaAllocator.init(std.testing.allocator);</span>
<span class="line" id="L3803">    <span class="tok-kw">defer</span> arena.deinit();</span>
<span class="line" id="L3804"></span>
<span class="line" id="L3805">    <span class="tok-kw">var</span> builder = <span class="tok-kw">try</span> Builder.create(</span>
<span class="line" id="L3806">        arena.allocator(),</span>
<span class="line" id="L3807">        <span class="tok-str">&quot;test&quot;</span>,</span>
<span class="line" id="L3808">        <span class="tok-str">&quot;test&quot;</span>,</span>
<span class="line" id="L3809">        <span class="tok-str">&quot;test&quot;</span>,</span>
<span class="line" id="L3810">        <span class="tok-str">&quot;test&quot;</span>,</span>
<span class="line" id="L3811">    );</span>
<span class="line" id="L3812">    <span class="tok-kw">defer</span> builder.destroy();</span>
<span class="line" id="L3813"></span>
<span class="line" id="L3814">    <span class="tok-kw">const</span> pkg_dep = Pkg{</span>
<span class="line" id="L3815">        .name = <span class="tok-str">&quot;pkg_dep&quot;</span>,</span>
<span class="line" id="L3816">        .source = .{ .path = <span class="tok-str">&quot;/not/a/pkg_dep.zig&quot;</span> },</span>
<span class="line" id="L3817">    };</span>
<span class="line" id="L3818">    <span class="tok-kw">const</span> pkg_top = Pkg{</span>
<span class="line" id="L3819">        .name = <span class="tok-str">&quot;pkg_dep&quot;</span>,</span>
<span class="line" id="L3820">        .source = .{ .path = <span class="tok-str">&quot;/not/a/pkg_top.zig&quot;</span> },</span>
<span class="line" id="L3821">        .dependencies = &amp;[_]Pkg{pkg_dep},</span>
<span class="line" id="L3822">    };</span>
<span class="line" id="L3823"></span>
<span class="line" id="L3824">    <span class="tok-kw">var</span> exe = builder.addExecutable(<span class="tok-str">&quot;not_an_executable&quot;</span>, <span class="tok-str">&quot;/not/an/executable.zig&quot;</span>);</span>
<span class="line" id="L3825">    exe.addPackage(pkg_top);</span>
<span class="line" id="L3826"></span>
<span class="line" id="L3827">    <span class="tok-kw">try</span> std.testing.expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">usize</span>, <span class="tok-number">1</span>), exe.packages.items.len);</span>
<span class="line" id="L3828"></span>
<span class="line" id="L3829">    <span class="tok-kw">const</span> dupe = exe.packages.items[<span class="tok-number">0</span>];</span>
<span class="line" id="L3830">    <span class="tok-kw">try</span> std.testing.expectEqualStrings(pkg_top.name, dupe.name);</span>
<span class="line" id="L3831">}</span>
<span class="line" id="L3832"></span>
</code></pre></body>
</html>