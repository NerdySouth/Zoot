<!doctype html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">    <title>coff.zig - source view</title>
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
<span class="line" id="L2"><span class="tok-kw">const</span> io = std.io;</span>
<span class="line" id="L3"><span class="tok-kw">const</span> mem = std.mem;</span>
<span class="line" id="L4"><span class="tok-kw">const</span> os = std.os;</span>
<span class="line" id="L5"><span class="tok-kw">const</span> File = std.fs.File;</span>
<span class="line" id="L6"></span>
<span class="line" id="L7"><span class="tok-comment">// CoffHeader.machine values</span>
</span>
<span class="line" id="L8"><span class="tok-comment">// see https://msdn.microsoft.com/en-us/library/windows/desktop/ms680313(v=vs.85).aspx</span>
</span>
<span class="line" id="L9"><span class="tok-kw">const</span> IMAGE_FILE_MACHINE_I386 = <span class="tok-number">0x014c</span>;</span>
<span class="line" id="L10"><span class="tok-kw">const</span> IMAGE_FILE_MACHINE_IA64 = <span class="tok-number">0x0200</span>;</span>
<span class="line" id="L11"><span class="tok-kw">const</span> IMAGE_FILE_MACHINE_AMD64 = <span class="tok-number">0x8664</span>;</span>
<span class="line" id="L12"></span>
<span class="line" id="L13"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> MachineType = <span class="tok-kw">enum</span>(<span class="tok-type">u16</span>) {</span>
<span class="line" id="L14">    Unknown = <span class="tok-number">0x0</span>,</span>
<span class="line" id="L15">    <span class="tok-comment">/// Matsushita AM33</span></span>
<span class="line" id="L16">    AM33 = <span class="tok-number">0x1d3</span>,</span>
<span class="line" id="L17">    <span class="tok-comment">/// x64</span></span>
<span class="line" id="L18">    X64 = <span class="tok-number">0x8664</span>,</span>
<span class="line" id="L19">    <span class="tok-comment">/// ARM little endian</span></span>
<span class="line" id="L20">    ARM = <span class="tok-number">0x1c0</span>,</span>
<span class="line" id="L21">    <span class="tok-comment">/// ARM64 little endian</span></span>
<span class="line" id="L22">    ARM64 = <span class="tok-number">0xaa64</span>,</span>
<span class="line" id="L23">    <span class="tok-comment">/// ARM Thumb-2 little endian</span></span>
<span class="line" id="L24">    ARMNT = <span class="tok-number">0x1c4</span>,</span>
<span class="line" id="L25">    <span class="tok-comment">/// EFI byte code</span></span>
<span class="line" id="L26">    EBC = <span class="tok-number">0xebc</span>,</span>
<span class="line" id="L27">    <span class="tok-comment">/// Intel 386 or later processors and compatible processors</span></span>
<span class="line" id="L28">    I386 = <span class="tok-number">0x14c</span>,</span>
<span class="line" id="L29">    <span class="tok-comment">/// Intel Itanium processor family</span></span>
<span class="line" id="L30">    IA64 = <span class="tok-number">0x200</span>,</span>
<span class="line" id="L31">    <span class="tok-comment">/// Mitsubishi M32R little endian</span></span>
<span class="line" id="L32">    M32R = <span class="tok-number">0x9041</span>,</span>
<span class="line" id="L33">    <span class="tok-comment">/// MIPS16</span></span>
<span class="line" id="L34">    MIPS16 = <span class="tok-number">0x266</span>,</span>
<span class="line" id="L35">    <span class="tok-comment">/// MIPS with FPU</span></span>
<span class="line" id="L36">    MIPSFPU = <span class="tok-number">0x366</span>,</span>
<span class="line" id="L37">    <span class="tok-comment">/// MIPS16 with FPU</span></span>
<span class="line" id="L38">    MIPSFPU16 = <span class="tok-number">0x466</span>,</span>
<span class="line" id="L39">    <span class="tok-comment">/// Power PC little endian</span></span>
<span class="line" id="L40">    POWERPC = <span class="tok-number">0x1f0</span>,</span>
<span class="line" id="L41">    <span class="tok-comment">/// Power PC with floating point support</span></span>
<span class="line" id="L42">    POWERPCFP = <span class="tok-number">0x1f1</span>,</span>
<span class="line" id="L43">    <span class="tok-comment">/// MIPS little endian</span></span>
<span class="line" id="L44">    R4000 = <span class="tok-number">0x166</span>,</span>
<span class="line" id="L45">    <span class="tok-comment">/// RISC-V 32-bit address space</span></span>
<span class="line" id="L46">    RISCV32 = <span class="tok-number">0x5032</span>,</span>
<span class="line" id="L47">    <span class="tok-comment">/// RISC-V 64-bit address space</span></span>
<span class="line" id="L48">    RISCV64 = <span class="tok-number">0x5064</span>,</span>
<span class="line" id="L49">    <span class="tok-comment">/// RISC-V 128-bit address space</span></span>
<span class="line" id="L50">    RISCV128 = <span class="tok-number">0x5128</span>,</span>
<span class="line" id="L51">    <span class="tok-comment">/// Hitachi SH3</span></span>
<span class="line" id="L52">    SH3 = <span class="tok-number">0x1a2</span>,</span>
<span class="line" id="L53">    <span class="tok-comment">/// Hitachi SH3 DSP</span></span>
<span class="line" id="L54">    SH3DSP = <span class="tok-number">0x1a3</span>,</span>
<span class="line" id="L55">    <span class="tok-comment">/// Hitachi SH4</span></span>
<span class="line" id="L56">    SH4 = <span class="tok-number">0x1a6</span>,</span>
<span class="line" id="L57">    <span class="tok-comment">/// Hitachi SH5</span></span>
<span class="line" id="L58">    SH5 = <span class="tok-number">0x1a8</span>,</span>
<span class="line" id="L59">    <span class="tok-comment">/// Thumb</span></span>
<span class="line" id="L60">    Thumb = <span class="tok-number">0x1c2</span>,</span>
<span class="line" id="L61">    <span class="tok-comment">/// MIPS little-endian WCE v2</span></span>
<span class="line" id="L62">    WCEMIPSV2 = <span class="tok-number">0x169</span>,</span>
<span class="line" id="L63"></span>
<span class="line" id="L64">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">toTargetCpuArch</span>(machine_type: MachineType) ?std.Target.Cpu.Arch {</span>
<span class="line" id="L65">        <span class="tok-kw">return</span> <span class="tok-kw">switch</span> (machine_type) {</span>
<span class="line" id="L66">            .ARM =&gt; .arm,</span>
<span class="line" id="L67">            .POWERPC =&gt; .powerpc,</span>
<span class="line" id="L68">            .RISCV32 =&gt; .riscv32,</span>
<span class="line" id="L69">            .Thumb =&gt; .thumb,</span>
<span class="line" id="L70">            .I386 =&gt; .<span class="tok-type">i386</span>,</span>
<span class="line" id="L71">            .ARM64 =&gt; .aarch64,</span>
<span class="line" id="L72">            .RISCV64 =&gt; .riscv64,</span>
<span class="line" id="L73">            .X64 =&gt; .x86_64,</span>
<span class="line" id="L74">            <span class="tok-comment">// there's cases we don't (yet) handle</span>
</span>
<span class="line" id="L75">            <span class="tok-kw">else</span> =&gt; <span class="tok-null">null</span>,</span>
<span class="line" id="L76">        };</span>
<span class="line" id="L77">    }</span>
<span class="line" id="L78">};</span>
<span class="line" id="L79"></span>
<span class="line" id="L80"><span class="tok-comment">// OptionalHeader.magic values</span>
</span>
<span class="line" id="L81"><span class="tok-comment">// see https://msdn.microsoft.com/en-us/library/windows/desktop/ms680339(v=vs.85).aspx</span>
</span>
<span class="line" id="L82"><span class="tok-kw">const</span> IMAGE_NT_OPTIONAL_HDR32_MAGIC = <span class="tok-number">0x10b</span>;</span>
<span class="line" id="L83"><span class="tok-kw">const</span> IMAGE_NT_OPTIONAL_HDR64_MAGIC = <span class="tok-number">0x20b</span>;</span>
<span class="line" id="L84"></span>
<span class="line" id="L85"><span class="tok-comment">// Image Characteristics</span>
</span>
<span class="line" id="L86"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> IMAGE_FILE_RELOCS_STRIPPED = <span class="tok-number">0x1</span>;</span>
<span class="line" id="L87"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> IMAGE_FILE_DEBUG_STRIPPED = <span class="tok-number">0x200</span>;</span>
<span class="line" id="L88"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> IMAGE_FILE_EXECUTABLE_IMAGE = <span class="tok-number">0x2</span>;</span>
<span class="line" id="L89"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> IMAGE_FILE_32BIT_MACHINE = <span class="tok-number">0x100</span>;</span>
<span class="line" id="L90"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> IMAGE_FILE_LARGE_ADDRESS_AWARE = <span class="tok-number">0x20</span>;</span>
<span class="line" id="L91"></span>
<span class="line" id="L92"><span class="tok-comment">// Section flags</span>
</span>
<span class="line" id="L93"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> IMAGE_SCN_CNT_INITIALIZED_DATA = <span class="tok-number">0x40</span>;</span>
<span class="line" id="L94"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> IMAGE_SCN_MEM_READ = <span class="tok-number">0x40000000</span>;</span>
<span class="line" id="L95"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> IMAGE_SCN_CNT_CODE = <span class="tok-number">0x20</span>;</span>
<span class="line" id="L96"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> IMAGE_SCN_MEM_EXECUTE = <span class="tok-number">0x20000000</span>;</span>
<span class="line" id="L97"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> IMAGE_SCN_MEM_WRITE = <span class="tok-number">0x80000000</span>;</span>
<span class="line" id="L98"></span>
<span class="line" id="L99"><span class="tok-kw">const</span> IMAGE_NUMBEROF_DIRECTORY_ENTRIES = <span class="tok-number">16</span>;</span>
<span class="line" id="L100"><span class="tok-kw">const</span> IMAGE_DEBUG_TYPE_CODEVIEW = <span class="tok-number">2</span>;</span>
<span class="line" id="L101"><span class="tok-kw">const</span> DEBUG_DIRECTORY = <span class="tok-number">6</span>;</span>
<span class="line" id="L102"></span>
<span class="line" id="L103"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> CoffError = <span class="tok-kw">error</span>{</span>
<span class="line" id="L104">    InvalidPEMagic,</span>
<span class="line" id="L105">    InvalidPEHeader,</span>
<span class="line" id="L106">    InvalidMachine,</span>
<span class="line" id="L107">    MissingCoffSection,</span>
<span class="line" id="L108">    MissingStringTable,</span>
<span class="line" id="L109">};</span>
<span class="line" id="L110"></span>
<span class="line" id="L111"><span class="tok-comment">// Official documentation of the format: https://docs.microsoft.com/en-us/windows/win32/debug/pe-format</span>
</span>
<span class="line" id="L112"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> Coff = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L113">    in_file: File,</span>
<span class="line" id="L114">    allocator: mem.Allocator,</span>
<span class="line" id="L115"></span>
<span class="line" id="L116">    coff_header: CoffHeader,</span>
<span class="line" id="L117">    pe_header: OptionalHeader,</span>
<span class="line" id="L118">    sections: std.ArrayListUnmanaged(Section) = .{},</span>
<span class="line" id="L119"></span>
<span class="line" id="L120">    guid: [<span class="tok-number">16</span>]<span class="tok-type">u8</span>,</span>
<span class="line" id="L121">    age: <span class="tok-type">u32</span>,</span>
<span class="line" id="L122"></span>
<span class="line" id="L123">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">init</span>(allocator: mem.Allocator, in_file: File) Coff {</span>
<span class="line" id="L124">        <span class="tok-kw">return</span> Coff{</span>
<span class="line" id="L125">            .in_file = in_file,</span>
<span class="line" id="L126">            .allocator = allocator,</span>
<span class="line" id="L127">            .coff_header = <span class="tok-null">undefined</span>,</span>
<span class="line" id="L128">            .pe_header = <span class="tok-null">undefined</span>,</span>
<span class="line" id="L129">            .guid = <span class="tok-null">undefined</span>,</span>
<span class="line" id="L130">            .age = <span class="tok-null">undefined</span>,</span>
<span class="line" id="L131">        };</span>
<span class="line" id="L132">    }</span>
<span class="line" id="L133"></span>
<span class="line" id="L134">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">deinit</span>(self: *Coff) <span class="tok-type">void</span> {</span>
<span class="line" id="L135">        self.sections.deinit(self.allocator);</span>
<span class="line" id="L136">    }</span>
<span class="line" id="L137"></span>
<span class="line" id="L138">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">loadHeader</span>(self: *Coff) !<span class="tok-type">void</span> {</span>
<span class="line" id="L139">        <span class="tok-kw">const</span> pe_pointer_offset = <span class="tok-number">0x3C</span>;</span>
<span class="line" id="L140"></span>
<span class="line" id="L141">        <span class="tok-kw">const</span> in = self.in_file.reader();</span>
<span class="line" id="L142"></span>
<span class="line" id="L143">        <span class="tok-kw">var</span> magic: [<span class="tok-number">2</span>]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L144">        <span class="tok-kw">try</span> in.readNoEof(magic[<span class="tok-number">0</span>..]);</span>
<span class="line" id="L145">        <span class="tok-kw">if</span> (!mem.eql(<span class="tok-type">u8</span>, &amp;magic, <span class="tok-str">&quot;MZ&quot;</span>))</span>
<span class="line" id="L146">            <span class="tok-kw">return</span> <span class="tok-kw">error</span>.InvalidPEMagic;</span>
<span class="line" id="L147"></span>
<span class="line" id="L148">        <span class="tok-comment">// Seek to PE File Header (coff header)</span>
</span>
<span class="line" id="L149">        <span class="tok-kw">try</span> self.in_file.seekTo(pe_pointer_offset);</span>
<span class="line" id="L150">        <span class="tok-kw">const</span> pe_magic_offset = <span class="tok-kw">try</span> in.readIntLittle(<span class="tok-type">u32</span>);</span>
<span class="line" id="L151">        <span class="tok-kw">try</span> self.in_file.seekTo(pe_magic_offset);</span>
<span class="line" id="L152"></span>
<span class="line" id="L153">        <span class="tok-kw">var</span> pe_header_magic: [<span class="tok-number">4</span>]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L154">        <span class="tok-kw">try</span> in.readNoEof(pe_header_magic[<span class="tok-number">0</span>..]);</span>
<span class="line" id="L155">        <span class="tok-kw">if</span> (!mem.eql(<span class="tok-type">u8</span>, &amp;pe_header_magic, &amp;[_]<span class="tok-type">u8</span>{ <span class="tok-str">'P'</span>, <span class="tok-str">'E'</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span> }))</span>
<span class="line" id="L156">            <span class="tok-kw">return</span> <span class="tok-kw">error</span>.InvalidPEHeader;</span>
<span class="line" id="L157"></span>
<span class="line" id="L158">        self.coff_header = CoffHeader{</span>
<span class="line" id="L159">            .machine = <span class="tok-kw">try</span> in.readIntLittle(<span class="tok-type">u16</span>),</span>
<span class="line" id="L160">            .number_of_sections = <span class="tok-kw">try</span> in.readIntLittle(<span class="tok-type">u16</span>),</span>
<span class="line" id="L161">            .timedate_stamp = <span class="tok-kw">try</span> in.readIntLittle(<span class="tok-type">u32</span>),</span>
<span class="line" id="L162">            .pointer_to_symbol_table = <span class="tok-kw">try</span> in.readIntLittle(<span class="tok-type">u32</span>),</span>
<span class="line" id="L163">            .number_of_symbols = <span class="tok-kw">try</span> in.readIntLittle(<span class="tok-type">u32</span>),</span>
<span class="line" id="L164">            .size_of_optional_header = <span class="tok-kw">try</span> in.readIntLittle(<span class="tok-type">u16</span>),</span>
<span class="line" id="L165">            .characteristics = <span class="tok-kw">try</span> in.readIntLittle(<span class="tok-type">u16</span>),</span>
<span class="line" id="L166">        };</span>
<span class="line" id="L167"></span>
<span class="line" id="L168">        <span class="tok-kw">switch</span> (self.coff_header.machine) {</span>
<span class="line" id="L169">            IMAGE_FILE_MACHINE_I386, IMAGE_FILE_MACHINE_AMD64, IMAGE_FILE_MACHINE_IA64 =&gt; {},</span>
<span class="line" id="L170">            <span class="tok-kw">else</span> =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.InvalidMachine,</span>
<span class="line" id="L171">        }</span>
<span class="line" id="L172"></span>
<span class="line" id="L173">        <span class="tok-kw">try</span> self.loadOptionalHeader();</span>
<span class="line" id="L174">    }</span>
<span class="line" id="L175"></span>
<span class="line" id="L176">    <span class="tok-kw">fn</span> <span class="tok-fn">readStringFromTable</span>(self: *Coff, offset: <span class="tok-type">usize</span>, buf: []<span class="tok-type">u8</span>) ![]<span class="tok-kw">const</span> <span class="tok-type">u8</span> {</span>
<span class="line" id="L177">        <span class="tok-kw">if</span> (self.coff_header.pointer_to_symbol_table == <span class="tok-number">0</span>) {</span>
<span class="line" id="L178">            <span class="tok-comment">// No symbol table therefore no string table</span>
</span>
<span class="line" id="L179">            <span class="tok-kw">return</span> <span class="tok-kw">error</span>.MissingStringTable;</span>
<span class="line" id="L180">        }</span>
<span class="line" id="L181">        <span class="tok-comment">// The string table is at the end of the symbol table and symbols are 18 bytes long</span>
</span>
<span class="line" id="L182">        <span class="tok-kw">const</span> string_table_offset = self.coff_header.pointer_to_symbol_table + (self.coff_header.number_of_symbols * <span class="tok-number">18</span>) + offset;</span>
<span class="line" id="L183">        <span class="tok-kw">const</span> in = self.in_file.reader();</span>
<span class="line" id="L184">        <span class="tok-kw">const</span> old_pos = <span class="tok-kw">try</span> self.in_file.getPos();</span>
<span class="line" id="L185"></span>
<span class="line" id="L186">        <span class="tok-kw">try</span> self.in_file.seekTo(string_table_offset);</span>
<span class="line" id="L187">        <span class="tok-kw">defer</span> {</span>
<span class="line" id="L188">            self.in_file.seekTo(old_pos) <span class="tok-kw">catch</span> <span class="tok-kw">unreachable</span>;</span>
<span class="line" id="L189">        }</span>
<span class="line" id="L190"></span>
<span class="line" id="L191">        <span class="tok-kw">const</span> str = <span class="tok-kw">try</span> in.readUntilDelimiterOrEof(buf, <span class="tok-number">0</span>);</span>
<span class="line" id="L192">        <span class="tok-kw">return</span> str <span class="tok-kw">orelse</span> <span class="tok-str">&quot;&quot;</span>;</span>
<span class="line" id="L193">    }</span>
<span class="line" id="L194"></span>
<span class="line" id="L195">    <span class="tok-kw">fn</span> <span class="tok-fn">loadOptionalHeader</span>(self: *Coff) !<span class="tok-type">void</span> {</span>
<span class="line" id="L196">        <span class="tok-kw">const</span> in = self.in_file.reader();</span>
<span class="line" id="L197">        <span class="tok-kw">const</span> opt_header_pos = <span class="tok-kw">try</span> self.in_file.getPos();</span>
<span class="line" id="L198"></span>
<span class="line" id="L199">        self.pe_header.magic = <span class="tok-kw">try</span> in.readIntLittle(<span class="tok-type">u16</span>);</span>
<span class="line" id="L200">        <span class="tok-kw">try</span> self.in_file.seekTo(opt_header_pos + <span class="tok-number">16</span>);</span>
<span class="line" id="L201">        self.pe_header.entry_addr = <span class="tok-kw">try</span> in.readIntLittle(<span class="tok-type">u32</span>);</span>
<span class="line" id="L202">        <span class="tok-kw">try</span> self.in_file.seekTo(opt_header_pos + <span class="tok-number">20</span>);</span>
<span class="line" id="L203">        self.pe_header.code_base = <span class="tok-kw">try</span> in.readIntLittle(<span class="tok-type">u32</span>);</span>
<span class="line" id="L204"></span>
<span class="line" id="L205">        <span class="tok-comment">// The header structure is different for 32 or 64 bit</span>
</span>
<span class="line" id="L206">        <span class="tok-kw">var</span> num_rva_pos: <span class="tok-type">u64</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L207">        <span class="tok-kw">if</span> (self.pe_header.magic == IMAGE_NT_OPTIONAL_HDR32_MAGIC) {</span>
<span class="line" id="L208">            num_rva_pos = opt_header_pos + <span class="tok-number">92</span>;</span>
<span class="line" id="L209"></span>
<span class="line" id="L210">            <span class="tok-kw">try</span> self.in_file.seekTo(opt_header_pos + <span class="tok-number">28</span>);</span>
<span class="line" id="L211">            <span class="tok-kw">const</span> image_base32 = <span class="tok-kw">try</span> in.readIntLittle(<span class="tok-type">u32</span>);</span>
<span class="line" id="L212">            self.pe_header.image_base = image_base32;</span>
<span class="line" id="L213">        } <span class="tok-kw">else</span> <span class="tok-kw">if</span> (self.pe_header.magic == IMAGE_NT_OPTIONAL_HDR64_MAGIC) {</span>
<span class="line" id="L214">            num_rva_pos = opt_header_pos + <span class="tok-number">108</span>;</span>
<span class="line" id="L215"></span>
<span class="line" id="L216">            <span class="tok-kw">try</span> self.in_file.seekTo(opt_header_pos + <span class="tok-number">24</span>);</span>
<span class="line" id="L217">            self.pe_header.image_base = <span class="tok-kw">try</span> in.readIntLittle(<span class="tok-type">u64</span>);</span>
<span class="line" id="L218">        } <span class="tok-kw">else</span> <span class="tok-kw">return</span> <span class="tok-kw">error</span>.InvalidPEMagic;</span>
<span class="line" id="L219"></span>
<span class="line" id="L220">        <span class="tok-kw">try</span> self.in_file.seekTo(num_rva_pos);</span>
<span class="line" id="L221"></span>
<span class="line" id="L222">        <span class="tok-kw">const</span> number_of_rva_and_sizes = <span class="tok-kw">try</span> in.readIntLittle(<span class="tok-type">u32</span>);</span>
<span class="line" id="L223">        <span class="tok-kw">if</span> (number_of_rva_and_sizes != IMAGE_NUMBEROF_DIRECTORY_ENTRIES)</span>
<span class="line" id="L224">            <span class="tok-kw">return</span> <span class="tok-kw">error</span>.InvalidPEHeader;</span>
<span class="line" id="L225"></span>
<span class="line" id="L226">        <span class="tok-kw">for</span> (self.pe_header.data_directory) |*data_dir| {</span>
<span class="line" id="L227">            data_dir.* = OptionalHeader.DataDirectory{</span>
<span class="line" id="L228">                .virtual_address = <span class="tok-kw">try</span> in.readIntLittle(<span class="tok-type">u32</span>),</span>
<span class="line" id="L229">                .size = <span class="tok-kw">try</span> in.readIntLittle(<span class="tok-type">u32</span>),</span>
<span class="line" id="L230">            };</span>
<span class="line" id="L231">        }</span>
<span class="line" id="L232">    }</span>
<span class="line" id="L233"></span>
<span class="line" id="L234">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">getPdbPath</span>(self: *Coff, buffer: []<span class="tok-type">u8</span>) !<span class="tok-type">usize</span> {</span>
<span class="line" id="L235">        <span class="tok-kw">try</span> self.loadSections();</span>
<span class="line" id="L236"></span>
<span class="line" id="L237">        <span class="tok-kw">const</span> header = blk: {</span>
<span class="line" id="L238">            <span class="tok-kw">if</span> (self.getSection(<span class="tok-str">&quot;.buildid&quot;</span>)) |section| {</span>
<span class="line" id="L239">                <span class="tok-kw">break</span> :blk section.header;</span>
<span class="line" id="L240">            } <span class="tok-kw">else</span> <span class="tok-kw">if</span> (self.getSection(<span class="tok-str">&quot;.rdata&quot;</span>)) |section| {</span>
<span class="line" id="L241">                <span class="tok-kw">break</span> :blk section.header;</span>
<span class="line" id="L242">            } <span class="tok-kw">else</span> {</span>
<span class="line" id="L243">                <span class="tok-kw">return</span> <span class="tok-kw">error</span>.MissingCoffSection;</span>
<span class="line" id="L244">            }</span>
<span class="line" id="L245">        };</span>
<span class="line" id="L246"></span>
<span class="line" id="L247">        <span class="tok-kw">const</span> debug_dir = &amp;self.pe_header.data_directory[DEBUG_DIRECTORY];</span>
<span class="line" id="L248">        <span class="tok-kw">const</span> file_offset = debug_dir.virtual_address - header.virtual_address + header.pointer_to_raw_data;</span>
<span class="line" id="L249"></span>
<span class="line" id="L250">        <span class="tok-kw">const</span> in = self.in_file.reader();</span>
<span class="line" id="L251">        <span class="tok-kw">try</span> self.in_file.seekTo(file_offset);</span>
<span class="line" id="L252"></span>
<span class="line" id="L253">        <span class="tok-comment">// Find the correct DebugDirectoryEntry, and where its data is stored.</span>
</span>
<span class="line" id="L254">        <span class="tok-comment">// It can be in any section.</span>
</span>
<span class="line" id="L255">        <span class="tok-kw">const</span> debug_dir_entry_count = debug_dir.size / <span class="tok-builtin">@sizeOf</span>(DebugDirectoryEntry);</span>
<span class="line" id="L256">        <span class="tok-kw">var</span> i: <span class="tok-type">u32</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L257">        blk: <span class="tok-kw">while</span> (i &lt; debug_dir_entry_count) : (i += <span class="tok-number">1</span>) {</span>
<span class="line" id="L258">            <span class="tok-kw">const</span> debug_dir_entry = <span class="tok-kw">try</span> in.readStruct(DebugDirectoryEntry);</span>
<span class="line" id="L259">            <span class="tok-kw">if</span> (debug_dir_entry.<span class="tok-type">type</span> == IMAGE_DEBUG_TYPE_CODEVIEW) {</span>
<span class="line" id="L260">                <span class="tok-kw">for</span> (self.sections.items) |*section| {</span>
<span class="line" id="L261">                    <span class="tok-kw">const</span> section_start = section.header.virtual_address;</span>
<span class="line" id="L262">                    <span class="tok-kw">const</span> section_size = section.header.misc.virtual_size;</span>
<span class="line" id="L263">                    <span class="tok-kw">const</span> rva = debug_dir_entry.address_of_raw_data;</span>
<span class="line" id="L264">                    <span class="tok-kw">const</span> offset = rva - section_start;</span>
<span class="line" id="L265">                    <span class="tok-kw">if</span> (section_start &lt;= rva <span class="tok-kw">and</span> offset &lt; section_size <span class="tok-kw">and</span> debug_dir_entry.size_of_data &lt;= section_size - offset) {</span>
<span class="line" id="L266">                        <span class="tok-kw">try</span> self.in_file.seekTo(section.header.pointer_to_raw_data + offset);</span>
<span class="line" id="L267">                        <span class="tok-kw">break</span> :blk;</span>
<span class="line" id="L268">                    }</span>
<span class="line" id="L269">                }</span>
<span class="line" id="L270">            }</span>
<span class="line" id="L271">        }</span>
<span class="line" id="L272"></span>
<span class="line" id="L273">        <span class="tok-kw">var</span> cv_signature: [<span class="tok-number">4</span>]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>; <span class="tok-comment">// CodeView signature</span>
</span>
<span class="line" id="L274">        <span class="tok-kw">try</span> in.readNoEof(cv_signature[<span class="tok-number">0</span>..]);</span>
<span class="line" id="L275">        <span class="tok-comment">// 'RSDS' indicates PDB70 format, used by lld.</span>
</span>
<span class="line" id="L276">        <span class="tok-kw">if</span> (!mem.eql(<span class="tok-type">u8</span>, &amp;cv_signature, <span class="tok-str">&quot;RSDS&quot;</span>))</span>
<span class="line" id="L277">            <span class="tok-kw">return</span> <span class="tok-kw">error</span>.InvalidPEMagic;</span>
<span class="line" id="L278">        <span class="tok-kw">try</span> in.readNoEof(self.guid[<span class="tok-number">0</span>..]);</span>
<span class="line" id="L279">        self.age = <span class="tok-kw">try</span> in.readIntLittle(<span class="tok-type">u32</span>);</span>
<span class="line" id="L280"></span>
<span class="line" id="L281">        <span class="tok-comment">// Finally read the null-terminated string.</span>
</span>
<span class="line" id="L282">        <span class="tok-kw">var</span> byte = <span class="tok-kw">try</span> in.readByte();</span>
<span class="line" id="L283">        i = <span class="tok-number">0</span>;</span>
<span class="line" id="L284">        <span class="tok-kw">while</span> (byte != <span class="tok-number">0</span> <span class="tok-kw">and</span> i &lt; buffer.len) : (i += <span class="tok-number">1</span>) {</span>
<span class="line" id="L285">            buffer[i] = byte;</span>
<span class="line" id="L286">            byte = <span class="tok-kw">try</span> in.readByte();</span>
<span class="line" id="L287">        }</span>
<span class="line" id="L288"></span>
<span class="line" id="L289">        <span class="tok-kw">if</span> (byte != <span class="tok-number">0</span> <span class="tok-kw">and</span> i == buffer.len)</span>
<span class="line" id="L290">            <span class="tok-kw">return</span> <span class="tok-kw">error</span>.NameTooLong;</span>
<span class="line" id="L291"></span>
<span class="line" id="L292">        <span class="tok-kw">return</span> <span class="tok-builtin">@as</span>(<span class="tok-type">usize</span>, i);</span>
<span class="line" id="L293">    }</span>
<span class="line" id="L294"></span>
<span class="line" id="L295">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">loadSections</span>(self: *Coff) !<span class="tok-type">void</span> {</span>
<span class="line" id="L296">        <span class="tok-kw">if</span> (self.sections.items.len == self.coff_header.number_of_sections)</span>
<span class="line" id="L297">            <span class="tok-kw">return</span>;</span>
<span class="line" id="L298"></span>
<span class="line" id="L299">        <span class="tok-kw">try</span> self.sections.ensureTotalCapacityPrecise(self.allocator, self.coff_header.number_of_sections);</span>
<span class="line" id="L300"></span>
<span class="line" id="L301">        <span class="tok-kw">const</span> in = self.in_file.reader();</span>
<span class="line" id="L302"></span>
<span class="line" id="L303">        <span class="tok-kw">var</span> name: [<span class="tok-number">32</span>]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L304"></span>
<span class="line" id="L305">        <span class="tok-kw">var</span> i: <span class="tok-type">u16</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L306">        <span class="tok-kw">while</span> (i &lt; self.coff_header.number_of_sections) : (i += <span class="tok-number">1</span>) {</span>
<span class="line" id="L307">            <span class="tok-kw">try</span> in.readNoEof(name[<span class="tok-number">0</span>..<span class="tok-number">8</span>]);</span>
<span class="line" id="L308"></span>
<span class="line" id="L309">            <span class="tok-kw">if</span> (name[<span class="tok-number">0</span>] == <span class="tok-str">'/'</span>) {</span>
<span class="line" id="L310">                <span class="tok-comment">// This is a long name and stored in the string table</span>
</span>
<span class="line" id="L311">                <span class="tok-kw">const</span> offset_len = mem.indexOfScalar(<span class="tok-type">u8</span>, name[<span class="tok-number">1</span>..], <span class="tok-number">0</span>) <span class="tok-kw">orelse</span> <span class="tok-number">7</span>;</span>
<span class="line" id="L312"></span>
<span class="line" id="L313">                <span class="tok-kw">const</span> str_offset = <span class="tok-kw">try</span> std.fmt.parseInt(<span class="tok-type">u32</span>, name[<span class="tok-number">1</span> .. offset_len + <span class="tok-number">1</span>], <span class="tok-number">10</span>);</span>
<span class="line" id="L314">                <span class="tok-kw">const</span> str = <span class="tok-kw">try</span> self.readStringFromTable(str_offset, &amp;name);</span>
<span class="line" id="L315">                std.mem.set(<span class="tok-type">u8</span>, name[str.len..], <span class="tok-number">0</span>);</span>
<span class="line" id="L316">            } <span class="tok-kw">else</span> {</span>
<span class="line" id="L317">                std.mem.set(<span class="tok-type">u8</span>, name[<span class="tok-number">8</span>..], <span class="tok-number">0</span>);</span>
<span class="line" id="L318">            }</span>
<span class="line" id="L319"></span>
<span class="line" id="L320">            self.sections.appendAssumeCapacity(Section{</span>
<span class="line" id="L321">                .header = SectionHeader{</span>
<span class="line" id="L322">                    .name = name,</span>
<span class="line" id="L323">                    .misc = SectionHeader.Misc{ .virtual_size = <span class="tok-kw">try</span> in.readIntLittle(<span class="tok-type">u32</span>) },</span>
<span class="line" id="L324">                    .virtual_address = <span class="tok-kw">try</span> in.readIntLittle(<span class="tok-type">u32</span>),</span>
<span class="line" id="L325">                    .size_of_raw_data = <span class="tok-kw">try</span> in.readIntLittle(<span class="tok-type">u32</span>),</span>
<span class="line" id="L326">                    .pointer_to_raw_data = <span class="tok-kw">try</span> in.readIntLittle(<span class="tok-type">u32</span>),</span>
<span class="line" id="L327">                    .pointer_to_relocations = <span class="tok-kw">try</span> in.readIntLittle(<span class="tok-type">u32</span>),</span>
<span class="line" id="L328">                    .pointer_to_line_numbers = <span class="tok-kw">try</span> in.readIntLittle(<span class="tok-type">u32</span>),</span>
<span class="line" id="L329">                    .number_of_relocations = <span class="tok-kw">try</span> in.readIntLittle(<span class="tok-type">u16</span>),</span>
<span class="line" id="L330">                    .number_of_line_numbers = <span class="tok-kw">try</span> in.readIntLittle(<span class="tok-type">u16</span>),</span>
<span class="line" id="L331">                    .characteristics = <span class="tok-kw">try</span> in.readIntLittle(<span class="tok-type">u32</span>),</span>
<span class="line" id="L332">                },</span>
<span class="line" id="L333">            });</span>
<span class="line" id="L334">        }</span>
<span class="line" id="L335">    }</span>
<span class="line" id="L336"></span>
<span class="line" id="L337">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">getSection</span>(self: *Coff, <span class="tok-kw">comptime</span> name: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) ?*Section {</span>
<span class="line" id="L338">        <span class="tok-kw">for</span> (self.sections.items) |*sec| {</span>
<span class="line" id="L339">            <span class="tok-kw">if</span> (mem.eql(<span class="tok-type">u8</span>, sec.header.name[<span class="tok-number">0</span>..name.len], name)) {</span>
<span class="line" id="L340">                <span class="tok-kw">return</span> sec;</span>
<span class="line" id="L341">            }</span>
<span class="line" id="L342">        }</span>
<span class="line" id="L343">        <span class="tok-kw">return</span> <span class="tok-null">null</span>;</span>
<span class="line" id="L344">    }</span>
<span class="line" id="L345"></span>
<span class="line" id="L346">    <span class="tok-comment">// Return an owned slice full of the section data</span>
</span>
<span class="line" id="L347">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">getSectionData</span>(self: *Coff, <span class="tok-kw">comptime</span> name: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>, allocator: mem.Allocator) ![]<span class="tok-type">u8</span> {</span>
<span class="line" id="L348">        <span class="tok-kw">const</span> sec = <span class="tok-kw">for</span> (self.sections.items) |*sec| {</span>
<span class="line" id="L349">            <span class="tok-kw">if</span> (mem.eql(<span class="tok-type">u8</span>, sec.header.name[<span class="tok-number">0</span>..name.len], name)) {</span>
<span class="line" id="L350">                <span class="tok-kw">break</span> sec;</span>
<span class="line" id="L351">            }</span>
<span class="line" id="L352">        } <span class="tok-kw">else</span> {</span>
<span class="line" id="L353">            <span class="tok-kw">return</span> <span class="tok-kw">error</span>.MissingCoffSection;</span>
<span class="line" id="L354">        };</span>
<span class="line" id="L355">        <span class="tok-kw">const</span> in = self.in_file.reader();</span>
<span class="line" id="L356">        <span class="tok-kw">try</span> self.in_file.seekTo(sec.header.pointer_to_raw_data);</span>
<span class="line" id="L357">        <span class="tok-kw">const</span> out_buff = <span class="tok-kw">try</span> allocator.alloc(<span class="tok-type">u8</span>, sec.header.misc.virtual_size);</span>
<span class="line" id="L358">        <span class="tok-kw">try</span> in.readNoEof(out_buff);</span>
<span class="line" id="L359">        <span class="tok-kw">return</span> out_buff;</span>
<span class="line" id="L360">    }</span>
<span class="line" id="L361">};</span>
<span class="line" id="L362"></span>
<span class="line" id="L363"><span class="tok-kw">const</span> CoffHeader = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L364">    machine: <span class="tok-type">u16</span>,</span>
<span class="line" id="L365">    number_of_sections: <span class="tok-type">u16</span>,</span>
<span class="line" id="L366">    timedate_stamp: <span class="tok-type">u32</span>,</span>
<span class="line" id="L367">    pointer_to_symbol_table: <span class="tok-type">u32</span>,</span>
<span class="line" id="L368">    number_of_symbols: <span class="tok-type">u32</span>,</span>
<span class="line" id="L369">    size_of_optional_header: <span class="tok-type">u16</span>,</span>
<span class="line" id="L370">    characteristics: <span class="tok-type">u16</span>,</span>
<span class="line" id="L371">};</span>
<span class="line" id="L372"></span>
<span class="line" id="L373"><span class="tok-kw">const</span> OptionalHeader = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L374">    <span class="tok-kw">const</span> DataDirectory = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L375">        virtual_address: <span class="tok-type">u32</span>,</span>
<span class="line" id="L376">        size: <span class="tok-type">u32</span>,</span>
<span class="line" id="L377">    };</span>
<span class="line" id="L378"></span>
<span class="line" id="L379">    magic: <span class="tok-type">u16</span>,</span>
<span class="line" id="L380">    data_directory: [IMAGE_NUMBEROF_DIRECTORY_ENTRIES]DataDirectory,</span>
<span class="line" id="L381">    entry_addr: <span class="tok-type">u32</span>,</span>
<span class="line" id="L382">    code_base: <span class="tok-type">u32</span>,</span>
<span class="line" id="L383">    image_base: <span class="tok-type">u64</span>,</span>
<span class="line" id="L384">};</span>
<span class="line" id="L385"></span>
<span class="line" id="L386"><span class="tok-kw">const</span> DebugDirectoryEntry = <span class="tok-kw">extern</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L387">    characteristiccs: <span class="tok-type">u32</span>,</span>
<span class="line" id="L388">    time_date_stamp: <span class="tok-type">u32</span>,</span>
<span class="line" id="L389">    major_version: <span class="tok-type">u16</span>,</span>
<span class="line" id="L390">    minor_version: <span class="tok-type">u16</span>,</span>
<span class="line" id="L391">    @&quot;type&quot;: <span class="tok-type">u32</span>,</span>
<span class="line" id="L392">    size_of_data: <span class="tok-type">u32</span>,</span>
<span class="line" id="L393">    address_of_raw_data: <span class="tok-type">u32</span>,</span>
<span class="line" id="L394">    pointer_to_raw_data: <span class="tok-type">u32</span>,</span>
<span class="line" id="L395">};</span>
<span class="line" id="L396"></span>
<span class="line" id="L397"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> Section = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L398">    header: SectionHeader,</span>
<span class="line" id="L399">};</span>
<span class="line" id="L400"></span>
<span class="line" id="L401"><span class="tok-kw">const</span> SectionHeader = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L402">    <span class="tok-kw">const</span> Misc = <span class="tok-kw">union</span> {</span>
<span class="line" id="L403">        physical_address: <span class="tok-type">u32</span>,</span>
<span class="line" id="L404">        virtual_size: <span class="tok-type">u32</span>,</span>
<span class="line" id="L405">    };</span>
<span class="line" id="L406"></span>
<span class="line" id="L407">    name: [<span class="tok-number">32</span>]<span class="tok-type">u8</span>,</span>
<span class="line" id="L408">    misc: Misc,</span>
<span class="line" id="L409">    virtual_address: <span class="tok-type">u32</span>,</span>
<span class="line" id="L410">    size_of_raw_data: <span class="tok-type">u32</span>,</span>
<span class="line" id="L411">    pointer_to_raw_data: <span class="tok-type">u32</span>,</span>
<span class="line" id="L412">    pointer_to_relocations: <span class="tok-type">u32</span>,</span>
<span class="line" id="L413">    pointer_to_line_numbers: <span class="tok-type">u32</span>,</span>
<span class="line" id="L414">    number_of_relocations: <span class="tok-type">u16</span>,</span>
<span class="line" id="L415">    number_of_line_numbers: <span class="tok-type">u16</span>,</span>
<span class="line" id="L416">    characteristics: <span class="tok-type">u32</span>,</span>
<span class="line" id="L417">};</span>
<span class="line" id="L418"></span>
</code></pre></body>
</html>