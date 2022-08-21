<!doctype html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">    <title>dwarf.zig - source view</title>
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
<span class="line" id="L2"><span class="tok-kw">const</span> std = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;std.zig&quot;</span>);</span>
<span class="line" id="L3"><span class="tok-kw">const</span> debug = std.debug;</span>
<span class="line" id="L4"><span class="tok-kw">const</span> fs = std.fs;</span>
<span class="line" id="L5"><span class="tok-kw">const</span> io = std.io;</span>
<span class="line" id="L6"><span class="tok-kw">const</span> mem = std.mem;</span>
<span class="line" id="L7"><span class="tok-kw">const</span> math = std.math;</span>
<span class="line" id="L8"><span class="tok-kw">const</span> leb = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;leb128.zig&quot;</span>);</span>
<span class="line" id="L9"></span>
<span class="line" id="L10"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> TAG = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;dwarf/TAG.zig&quot;</span>);</span>
<span class="line" id="L11"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> AT = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;dwarf/AT.zig&quot;</span>);</span>
<span class="line" id="L12"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> OP = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;dwarf/OP.zig&quot;</span>);</span>
<span class="line" id="L13"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> LANG = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;dwarf/LANG.zig&quot;</span>);</span>
<span class="line" id="L14"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> FORM = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;dwarf/FORM.zig&quot;</span>);</span>
<span class="line" id="L15"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> ATE = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;dwarf/ATE.zig&quot;</span>);</span>
<span class="line" id="L16"></span>
<span class="line" id="L17"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> LLE = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L18">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> end_of_list = <span class="tok-number">0x00</span>;</span>
<span class="line" id="L19">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> base_addressx = <span class="tok-number">0x01</span>;</span>
<span class="line" id="L20">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> startx_endx = <span class="tok-number">0x02</span>;</span>
<span class="line" id="L21">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> startx_length = <span class="tok-number">0x03</span>;</span>
<span class="line" id="L22">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> offset_pair = <span class="tok-number">0x04</span>;</span>
<span class="line" id="L23">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> default_location = <span class="tok-number">0x05</span>;</span>
<span class="line" id="L24">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> base_address = <span class="tok-number">0x06</span>;</span>
<span class="line" id="L25">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> start_end = <span class="tok-number">0x07</span>;</span>
<span class="line" id="L26">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> start_length = <span class="tok-number">0x08</span>;</span>
<span class="line" id="L27">};</span>
<span class="line" id="L28"></span>
<span class="line" id="L29"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> CFA = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L30">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> advance_loc = <span class="tok-number">0x40</span>;</span>
<span class="line" id="L31">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> offset = <span class="tok-number">0x80</span>;</span>
<span class="line" id="L32">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> restore = <span class="tok-number">0xc0</span>;</span>
<span class="line" id="L33">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> nop = <span class="tok-number">0x00</span>;</span>
<span class="line" id="L34">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> set_loc = <span class="tok-number">0x01</span>;</span>
<span class="line" id="L35">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> advance_loc1 = <span class="tok-number">0x02</span>;</span>
<span class="line" id="L36">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> advance_loc2 = <span class="tok-number">0x03</span>;</span>
<span class="line" id="L37">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> advance_loc4 = <span class="tok-number">0x04</span>;</span>
<span class="line" id="L38">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> offset_extended = <span class="tok-number">0x05</span>;</span>
<span class="line" id="L39">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> restore_extended = <span class="tok-number">0x06</span>;</span>
<span class="line" id="L40">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> @&quot;undefined&quot; = <span class="tok-number">0x07</span>;</span>
<span class="line" id="L41">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> same_value = <span class="tok-number">0x08</span>;</span>
<span class="line" id="L42">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> register = <span class="tok-number">0x09</span>;</span>
<span class="line" id="L43">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> remember_state = <span class="tok-number">0x0a</span>;</span>
<span class="line" id="L44">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> restore_state = <span class="tok-number">0x0b</span>;</span>
<span class="line" id="L45">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> def_cfa = <span class="tok-number">0x0c</span>;</span>
<span class="line" id="L46">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> def_cfa_register = <span class="tok-number">0x0d</span>;</span>
<span class="line" id="L47">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> def_cfa_offset = <span class="tok-number">0x0e</span>;</span>
<span class="line" id="L48"></span>
<span class="line" id="L49">    <span class="tok-comment">// DWARF 3.</span>
</span>
<span class="line" id="L50">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> def_cfa_expression = <span class="tok-number">0x0f</span>;</span>
<span class="line" id="L51">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> expression = <span class="tok-number">0x10</span>;</span>
<span class="line" id="L52">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> offset_extended_sf = <span class="tok-number">0x11</span>;</span>
<span class="line" id="L53">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> def_cfa_sf = <span class="tok-number">0x12</span>;</span>
<span class="line" id="L54">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> def_cfa_offset_sf = <span class="tok-number">0x13</span>;</span>
<span class="line" id="L55">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> val_offset = <span class="tok-number">0x14</span>;</span>
<span class="line" id="L56">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> val_offset_sf = <span class="tok-number">0x15</span>;</span>
<span class="line" id="L57">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> val_expression = <span class="tok-number">0x16</span>;</span>
<span class="line" id="L58"></span>
<span class="line" id="L59">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> lo_user = <span class="tok-number">0x1c</span>;</span>
<span class="line" id="L60">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> hi_user = <span class="tok-number">0x3f</span>;</span>
<span class="line" id="L61"></span>
<span class="line" id="L62">    <span class="tok-comment">// SGI/MIPS specific.</span>
</span>
<span class="line" id="L63">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> MIPS_advance_loc8 = <span class="tok-number">0x1d</span>;</span>
<span class="line" id="L64"></span>
<span class="line" id="L65">    <span class="tok-comment">// GNU extensions.</span>
</span>
<span class="line" id="L66">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> GNU_window_save = <span class="tok-number">0x2d</span>;</span>
<span class="line" id="L67">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> GNU_args_size = <span class="tok-number">0x2e</span>;</span>
<span class="line" id="L68">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> GNU_negative_offset_extended = <span class="tok-number">0x2f</span>;</span>
<span class="line" id="L69">};</span>
<span class="line" id="L70"></span>
<span class="line" id="L71"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> CHILDREN = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L72">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> no = <span class="tok-number">0x00</span>;</span>
<span class="line" id="L73">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> yes = <span class="tok-number">0x01</span>;</span>
<span class="line" id="L74">};</span>
<span class="line" id="L75"></span>
<span class="line" id="L76"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> LNS = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L77">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> extended_op = <span class="tok-number">0x00</span>;</span>
<span class="line" id="L78">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> copy = <span class="tok-number">0x01</span>;</span>
<span class="line" id="L79">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> advance_pc = <span class="tok-number">0x02</span>;</span>
<span class="line" id="L80">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> advance_line = <span class="tok-number">0x03</span>;</span>
<span class="line" id="L81">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> set_file = <span class="tok-number">0x04</span>;</span>
<span class="line" id="L82">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> set_column = <span class="tok-number">0x05</span>;</span>
<span class="line" id="L83">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> negate_stmt = <span class="tok-number">0x06</span>;</span>
<span class="line" id="L84">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> set_basic_block = <span class="tok-number">0x07</span>;</span>
<span class="line" id="L85">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> const_add_pc = <span class="tok-number">0x08</span>;</span>
<span class="line" id="L86">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> fixed_advance_pc = <span class="tok-number">0x09</span>;</span>
<span class="line" id="L87">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> set_prologue_end = <span class="tok-number">0x0a</span>;</span>
<span class="line" id="L88">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> set_epilogue_begin = <span class="tok-number">0x0b</span>;</span>
<span class="line" id="L89">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> set_isa = <span class="tok-number">0x0c</span>;</span>
<span class="line" id="L90">};</span>
<span class="line" id="L91"></span>
<span class="line" id="L92"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> LNE = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L93">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> end_sequence = <span class="tok-number">0x01</span>;</span>
<span class="line" id="L94">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> set_address = <span class="tok-number">0x02</span>;</span>
<span class="line" id="L95">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> define_file = <span class="tok-number">0x03</span>;</span>
<span class="line" id="L96">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> set_discriminator = <span class="tok-number">0x04</span>;</span>
<span class="line" id="L97">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> lo_user = <span class="tok-number">0x80</span>;</span>
<span class="line" id="L98">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> hi_user = <span class="tok-number">0xff</span>;</span>
<span class="line" id="L99">};</span>
<span class="line" id="L100"></span>
<span class="line" id="L101"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> UT = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L102">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> compile = <span class="tok-number">0x01</span>;</span>
<span class="line" id="L103">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> @&quot;type&quot; = <span class="tok-number">0x02</span>;</span>
<span class="line" id="L104">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> partial = <span class="tok-number">0x03</span>;</span>
<span class="line" id="L105">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> skeleton = <span class="tok-number">0x04</span>;</span>
<span class="line" id="L106">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> split_compile = <span class="tok-number">0x05</span>;</span>
<span class="line" id="L107">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> split_type = <span class="tok-number">0x06</span>;</span>
<span class="line" id="L108"></span>
<span class="line" id="L109">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> lo_user = <span class="tok-number">0x80</span>;</span>
<span class="line" id="L110">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> hi_user = <span class="tok-number">0xff</span>;</span>
<span class="line" id="L111">};</span>
<span class="line" id="L112"></span>
<span class="line" id="L113"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> LNCT = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L114">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> path = <span class="tok-number">0x1</span>;</span>
<span class="line" id="L115">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> directory_index = <span class="tok-number">0x2</span>;</span>
<span class="line" id="L116">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> timestamp = <span class="tok-number">0x3</span>;</span>
<span class="line" id="L117">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> size = <span class="tok-number">0x4</span>;</span>
<span class="line" id="L118">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> MD5 = <span class="tok-number">0x5</span>;</span>
<span class="line" id="L119"></span>
<span class="line" id="L120">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> lo_user = <span class="tok-number">0x2000</span>;</span>
<span class="line" id="L121">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> hi_user = <span class="tok-number">0x3fff</span>;</span>
<span class="line" id="L122">};</span>
<span class="line" id="L123"></span>
<span class="line" id="L124"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> RLE = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L125">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> end_of_list = <span class="tok-number">0x00</span>;</span>
<span class="line" id="L126">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> base_addressx = <span class="tok-number">0x01</span>;</span>
<span class="line" id="L127">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> startx_endx = <span class="tok-number">0x02</span>;</span>
<span class="line" id="L128">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> startx_length = <span class="tok-number">0x03</span>;</span>
<span class="line" id="L129">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> offset_pair = <span class="tok-number">0x04</span>;</span>
<span class="line" id="L130">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> base_address = <span class="tok-number">0x05</span>;</span>
<span class="line" id="L131">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> start_end = <span class="tok-number">0x06</span>;</span>
<span class="line" id="L132">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> start_length = <span class="tok-number">0x07</span>;</span>
<span class="line" id="L133">};</span>
<span class="line" id="L134"></span>
<span class="line" id="L135"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> CC = <span class="tok-kw">enum</span>(<span class="tok-type">u8</span>) {</span>
<span class="line" id="L136">    normal = <span class="tok-number">0x1</span>,</span>
<span class="line" id="L137">    program = <span class="tok-number">0x2</span>,</span>
<span class="line" id="L138">    nocall = <span class="tok-number">0x3</span>,</span>
<span class="line" id="L139"></span>
<span class="line" id="L140">    pass_by_reference = <span class="tok-number">0x4</span>,</span>
<span class="line" id="L141">    pass_by_value = <span class="tok-number">0x5</span>,</span>
<span class="line" id="L142"></span>
<span class="line" id="L143">    lo_user = <span class="tok-number">0x40</span>,</span>
<span class="line" id="L144">    hi_user = <span class="tok-number">0xff</span>,</span>
<span class="line" id="L145"></span>
<span class="line" id="L146">    GNU_renesas_sh = <span class="tok-number">0x40</span>,</span>
<span class="line" id="L147">    GNU_borland_fastcall_i386 = <span class="tok-number">0x41</span>,</span>
<span class="line" id="L148">};</span>
<span class="line" id="L149"></span>
<span class="line" id="L150"><span class="tok-kw">const</span> PcRange = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L151">    start: <span class="tok-type">u64</span>,</span>
<span class="line" id="L152">    end: <span class="tok-type">u64</span>,</span>
<span class="line" id="L153">};</span>
<span class="line" id="L154"></span>
<span class="line" id="L155"><span class="tok-kw">const</span> Func = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L156">    pc_range: ?PcRange,</span>
<span class="line" id="L157">    name: ?[]<span class="tok-kw">const</span> <span class="tok-type">u8</span>,</span>
<span class="line" id="L158"></span>
<span class="line" id="L159">    <span class="tok-kw">fn</span> <span class="tok-fn">deinit</span>(func: *Func, allocator: mem.Allocator) <span class="tok-type">void</span> {</span>
<span class="line" id="L160">        <span class="tok-kw">if</span> (func.name) |name| {</span>
<span class="line" id="L161">            allocator.free(name);</span>
<span class="line" id="L162">        }</span>
<span class="line" id="L163">    }</span>
<span class="line" id="L164">};</span>
<span class="line" id="L165"></span>
<span class="line" id="L166"><span class="tok-kw">const</span> CompileUnit = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L167">    version: <span class="tok-type">u16</span>,</span>
<span class="line" id="L168">    is_64: <span class="tok-type">bool</span>,</span>
<span class="line" id="L169">    die: *Die,</span>
<span class="line" id="L170">    pc_range: ?PcRange,</span>
<span class="line" id="L171">};</span>
<span class="line" id="L172"></span>
<span class="line" id="L173"><span class="tok-kw">const</span> AbbrevTable = std.ArrayList(AbbrevTableEntry);</span>
<span class="line" id="L174"></span>
<span class="line" id="L175"><span class="tok-kw">const</span> AbbrevTableHeader = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L176">    <span class="tok-comment">// offset from .debug_abbrev</span>
</span>
<span class="line" id="L177">    offset: <span class="tok-type">u64</span>,</span>
<span class="line" id="L178">    table: AbbrevTable,</span>
<span class="line" id="L179"></span>
<span class="line" id="L180">    <span class="tok-kw">fn</span> <span class="tok-fn">deinit</span>(header: *AbbrevTableHeader) <span class="tok-type">void</span> {</span>
<span class="line" id="L181">        <span class="tok-kw">for</span> (header.table.items) |*entry| {</span>
<span class="line" id="L182">            entry.deinit();</span>
<span class="line" id="L183">        }</span>
<span class="line" id="L184">        header.table.deinit();</span>
<span class="line" id="L185">    }</span>
<span class="line" id="L186">};</span>
<span class="line" id="L187"></span>
<span class="line" id="L188"><span class="tok-kw">const</span> AbbrevTableEntry = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L189">    has_children: <span class="tok-type">bool</span>,</span>
<span class="line" id="L190">    abbrev_code: <span class="tok-type">u64</span>,</span>
<span class="line" id="L191">    tag_id: <span class="tok-type">u64</span>,</span>
<span class="line" id="L192">    attrs: std.ArrayList(AbbrevAttr),</span>
<span class="line" id="L193"></span>
<span class="line" id="L194">    <span class="tok-kw">fn</span> <span class="tok-fn">deinit</span>(entry: *AbbrevTableEntry) <span class="tok-type">void</span> {</span>
<span class="line" id="L195">        entry.attrs.deinit();</span>
<span class="line" id="L196">    }</span>
<span class="line" id="L197">};</span>
<span class="line" id="L198"></span>
<span class="line" id="L199"><span class="tok-kw">const</span> AbbrevAttr = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L200">    attr_id: <span class="tok-type">u64</span>,</span>
<span class="line" id="L201">    form_id: <span class="tok-type">u64</span>,</span>
<span class="line" id="L202">    <span class="tok-comment">/// Only valid if form_id is .implicit_const</span></span>
<span class="line" id="L203">    payload: <span class="tok-type">i64</span>,</span>
<span class="line" id="L204">};</span>
<span class="line" id="L205"></span>
<span class="line" id="L206"><span class="tok-kw">const</span> FormValue = <span class="tok-kw">union</span>(<span class="tok-kw">enum</span>) {</span>
<span class="line" id="L207">    Address: <span class="tok-type">u64</span>,</span>
<span class="line" id="L208">    Block: []<span class="tok-type">u8</span>,</span>
<span class="line" id="L209">    Const: Constant,</span>
<span class="line" id="L210">    ExprLoc: []<span class="tok-type">u8</span>,</span>
<span class="line" id="L211">    Flag: <span class="tok-type">bool</span>,</span>
<span class="line" id="L212">    SecOffset: <span class="tok-type">u64</span>,</span>
<span class="line" id="L213">    Ref: <span class="tok-type">u64</span>,</span>
<span class="line" id="L214">    RefAddr: <span class="tok-type">u64</span>,</span>
<span class="line" id="L215">    String: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>,</span>
<span class="line" id="L216">    StrPtr: <span class="tok-type">u64</span>,</span>
<span class="line" id="L217">    LineStrPtr: <span class="tok-type">u64</span>,</span>
<span class="line" id="L218">};</span>
<span class="line" id="L219"></span>
<span class="line" id="L220"><span class="tok-kw">const</span> Constant = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L221">    payload: <span class="tok-type">u64</span>,</span>
<span class="line" id="L222">    signed: <span class="tok-type">bool</span>,</span>
<span class="line" id="L223"></span>
<span class="line" id="L224">    <span class="tok-kw">fn</span> <span class="tok-fn">asUnsignedLe</span>(self: *<span class="tok-kw">const</span> Constant) !<span class="tok-type">u64</span> {</span>
<span class="line" id="L225">        <span class="tok-kw">if</span> (self.signed) <span class="tok-kw">return</span> <span class="tok-kw">error</span>.InvalidDebugInfo;</span>
<span class="line" id="L226">        <span class="tok-kw">return</span> self.payload;</span>
<span class="line" id="L227">    }</span>
<span class="line" id="L228">};</span>
<span class="line" id="L229"></span>
<span class="line" id="L230"><span class="tok-kw">const</span> Die = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L231">    <span class="tok-comment">// Arena for Die's Attr's and FormValue's.</span>
</span>
<span class="line" id="L232">    arena: std.heap.ArenaAllocator,</span>
<span class="line" id="L233">    tag_id: <span class="tok-type">u64</span>,</span>
<span class="line" id="L234">    has_children: <span class="tok-type">bool</span>,</span>
<span class="line" id="L235">    attrs: std.ArrayListUnmanaged(Attr) = .{},</span>
<span class="line" id="L236"></span>
<span class="line" id="L237">    <span class="tok-kw">const</span> Attr = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L238">        id: <span class="tok-type">u64</span>,</span>
<span class="line" id="L239">        value: FormValue,</span>
<span class="line" id="L240">    };</span>
<span class="line" id="L241"></span>
<span class="line" id="L242">    <span class="tok-kw">fn</span> <span class="tok-fn">deinit</span>(self: *Die, allocator: mem.Allocator) <span class="tok-type">void</span> {</span>
<span class="line" id="L243">        self.arena.deinit();</span>
<span class="line" id="L244">        self.attrs.deinit(allocator);</span>
<span class="line" id="L245">    }</span>
<span class="line" id="L246"></span>
<span class="line" id="L247">    <span class="tok-kw">fn</span> <span class="tok-fn">getAttr</span>(self: *<span class="tok-kw">const</span> Die, id: <span class="tok-type">u64</span>) ?*<span class="tok-kw">const</span> FormValue {</span>
<span class="line" id="L248">        <span class="tok-kw">for</span> (self.attrs.items) |*attr| {</span>
<span class="line" id="L249">            <span class="tok-kw">if</span> (attr.id == id) <span class="tok-kw">return</span> &amp;attr.value;</span>
<span class="line" id="L250">        }</span>
<span class="line" id="L251">        <span class="tok-kw">return</span> <span class="tok-null">null</span>;</span>
<span class="line" id="L252">    }</span>
<span class="line" id="L253"></span>
<span class="line" id="L254">    <span class="tok-kw">fn</span> <span class="tok-fn">getAttrAddr</span>(self: *<span class="tok-kw">const</span> Die, id: <span class="tok-type">u64</span>) !<span class="tok-type">u64</span> {</span>
<span class="line" id="L255">        <span class="tok-kw">const</span> form_value = self.getAttr(id) <span class="tok-kw">orelse</span> <span class="tok-kw">return</span> <span class="tok-kw">error</span>.MissingDebugInfo;</span>
<span class="line" id="L256">        <span class="tok-kw">return</span> <span class="tok-kw">switch</span> (form_value.*) {</span>
<span class="line" id="L257">            FormValue.Address =&gt; |value| value,</span>
<span class="line" id="L258">            <span class="tok-kw">else</span> =&gt; <span class="tok-kw">error</span>.InvalidDebugInfo,</span>
<span class="line" id="L259">        };</span>
<span class="line" id="L260">    }</span>
<span class="line" id="L261"></span>
<span class="line" id="L262">    <span class="tok-kw">fn</span> <span class="tok-fn">getAttrSecOffset</span>(self: *<span class="tok-kw">const</span> Die, id: <span class="tok-type">u64</span>) !<span class="tok-type">u64</span> {</span>
<span class="line" id="L263">        <span class="tok-kw">const</span> form_value = self.getAttr(id) <span class="tok-kw">orelse</span> <span class="tok-kw">return</span> <span class="tok-kw">error</span>.MissingDebugInfo;</span>
<span class="line" id="L264">        <span class="tok-kw">return</span> <span class="tok-kw">switch</span> (form_value.*) {</span>
<span class="line" id="L265">            FormValue.Const =&gt; |value| value.asUnsignedLe(),</span>
<span class="line" id="L266">            FormValue.SecOffset =&gt; |value| value,</span>
<span class="line" id="L267">            <span class="tok-kw">else</span> =&gt; <span class="tok-kw">error</span>.InvalidDebugInfo,</span>
<span class="line" id="L268">        };</span>
<span class="line" id="L269">    }</span>
<span class="line" id="L270"></span>
<span class="line" id="L271">    <span class="tok-kw">fn</span> <span class="tok-fn">getAttrUnsignedLe</span>(self: *<span class="tok-kw">const</span> Die, id: <span class="tok-type">u64</span>) !<span class="tok-type">u64</span> {</span>
<span class="line" id="L272">        <span class="tok-kw">const</span> form_value = self.getAttr(id) <span class="tok-kw">orelse</span> <span class="tok-kw">return</span> <span class="tok-kw">error</span>.MissingDebugInfo;</span>
<span class="line" id="L273">        <span class="tok-kw">return</span> <span class="tok-kw">switch</span> (form_value.*) {</span>
<span class="line" id="L274">            FormValue.Const =&gt; |value| value.asUnsignedLe(),</span>
<span class="line" id="L275">            <span class="tok-kw">else</span> =&gt; <span class="tok-kw">error</span>.InvalidDebugInfo,</span>
<span class="line" id="L276">        };</span>
<span class="line" id="L277">    }</span>
<span class="line" id="L278"></span>
<span class="line" id="L279">    <span class="tok-kw">fn</span> <span class="tok-fn">getAttrRef</span>(self: *<span class="tok-kw">const</span> Die, id: <span class="tok-type">u64</span>) !<span class="tok-type">u64</span> {</span>
<span class="line" id="L280">        <span class="tok-kw">const</span> form_value = self.getAttr(id) <span class="tok-kw">orelse</span> <span class="tok-kw">return</span> <span class="tok-kw">error</span>.MissingDebugInfo;</span>
<span class="line" id="L281">        <span class="tok-kw">return</span> <span class="tok-kw">switch</span> (form_value.*) {</span>
<span class="line" id="L282">            FormValue.Ref =&gt; |value| value,</span>
<span class="line" id="L283">            <span class="tok-kw">else</span> =&gt; <span class="tok-kw">error</span>.InvalidDebugInfo,</span>
<span class="line" id="L284">        };</span>
<span class="line" id="L285">    }</span>
<span class="line" id="L286"></span>
<span class="line" id="L287">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">getAttrString</span>(self: *<span class="tok-kw">const</span> Die, di: *DwarfInfo, id: <span class="tok-type">u64</span>) ![]<span class="tok-kw">const</span> <span class="tok-type">u8</span> {</span>
<span class="line" id="L288">        <span class="tok-kw">const</span> form_value = self.getAttr(id) <span class="tok-kw">orelse</span> <span class="tok-kw">return</span> <span class="tok-kw">error</span>.MissingDebugInfo;</span>
<span class="line" id="L289">        <span class="tok-kw">return</span> <span class="tok-kw">switch</span> (form_value.*) {</span>
<span class="line" id="L290">            FormValue.String =&gt; |value| value,</span>
<span class="line" id="L291">            FormValue.StrPtr =&gt; |offset| di.getString(offset),</span>
<span class="line" id="L292">            FormValue.LineStrPtr =&gt; |offset| di.getLineString(offset),</span>
<span class="line" id="L293">            <span class="tok-kw">else</span> =&gt; <span class="tok-kw">error</span>.InvalidDebugInfo,</span>
<span class="line" id="L294">        };</span>
<span class="line" id="L295">    }</span>
<span class="line" id="L296">};</span>
<span class="line" id="L297"></span>
<span class="line" id="L298"><span class="tok-kw">const</span> FileEntry = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L299">    file_name: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>,</span>
<span class="line" id="L300">    dir_index: <span class="tok-type">usize</span>,</span>
<span class="line" id="L301">    mtime: <span class="tok-type">usize</span>,</span>
<span class="line" id="L302">    len_bytes: <span class="tok-type">usize</span>,</span>
<span class="line" id="L303">};</span>
<span class="line" id="L304"></span>
<span class="line" id="L305"><span class="tok-kw">const</span> LineNumberProgram = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L306">    address: <span class="tok-type">u64</span>,</span>
<span class="line" id="L307">    file: <span class="tok-type">usize</span>,</span>
<span class="line" id="L308">    line: <span class="tok-type">i64</span>,</span>
<span class="line" id="L309">    column: <span class="tok-type">u64</span>,</span>
<span class="line" id="L310">    is_stmt: <span class="tok-type">bool</span>,</span>
<span class="line" id="L311">    basic_block: <span class="tok-type">bool</span>,</span>
<span class="line" id="L312">    end_sequence: <span class="tok-type">bool</span>,</span>
<span class="line" id="L313"></span>
<span class="line" id="L314">    default_is_stmt: <span class="tok-type">bool</span>,</span>
<span class="line" id="L315">    target_address: <span class="tok-type">u64</span>,</span>
<span class="line" id="L316">    include_dirs: []<span class="tok-kw">const</span> []<span class="tok-kw">const</span> <span class="tok-type">u8</span>,</span>
<span class="line" id="L317"></span>
<span class="line" id="L318">    prev_valid: <span class="tok-type">bool</span>,</span>
<span class="line" id="L319">    prev_address: <span class="tok-type">u64</span>,</span>
<span class="line" id="L320">    prev_file: <span class="tok-type">usize</span>,</span>
<span class="line" id="L321">    prev_line: <span class="tok-type">i64</span>,</span>
<span class="line" id="L322">    prev_column: <span class="tok-type">u64</span>,</span>
<span class="line" id="L323">    prev_is_stmt: <span class="tok-type">bool</span>,</span>
<span class="line" id="L324">    prev_basic_block: <span class="tok-type">bool</span>,</span>
<span class="line" id="L325">    prev_end_sequence: <span class="tok-type">bool</span>,</span>
<span class="line" id="L326"></span>
<span class="line" id="L327">    <span class="tok-comment">// Reset the state machine following the DWARF specification</span>
</span>
<span class="line" id="L328">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">reset</span>(self: *LineNumberProgram) <span class="tok-type">void</span> {</span>
<span class="line" id="L329">        self.address = <span class="tok-number">0</span>;</span>
<span class="line" id="L330">        self.file = <span class="tok-number">1</span>;</span>
<span class="line" id="L331">        self.line = <span class="tok-number">1</span>;</span>
<span class="line" id="L332">        self.column = <span class="tok-number">0</span>;</span>
<span class="line" id="L333">        self.is_stmt = self.default_is_stmt;</span>
<span class="line" id="L334">        self.basic_block = <span class="tok-null">false</span>;</span>
<span class="line" id="L335">        self.end_sequence = <span class="tok-null">false</span>;</span>
<span class="line" id="L336">        <span class="tok-comment">// Invalidate all the remaining fields</span>
</span>
<span class="line" id="L337">        self.prev_valid = <span class="tok-null">false</span>;</span>
<span class="line" id="L338">        self.prev_address = <span class="tok-number">0</span>;</span>
<span class="line" id="L339">        self.prev_file = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L340">        self.prev_line = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L341">        self.prev_column = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L342">        self.prev_is_stmt = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L343">        self.prev_basic_block = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L344">        self.prev_end_sequence = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L345">    }</span>
<span class="line" id="L346"></span>
<span class="line" id="L347">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">init</span>(is_stmt: <span class="tok-type">bool</span>, include_dirs: []<span class="tok-kw">const</span> []<span class="tok-kw">const</span> <span class="tok-type">u8</span>, target_address: <span class="tok-type">u64</span>) LineNumberProgram {</span>
<span class="line" id="L348">        <span class="tok-kw">return</span> LineNumberProgram{</span>
<span class="line" id="L349">            .address = <span class="tok-number">0</span>,</span>
<span class="line" id="L350">            .file = <span class="tok-number">1</span>,</span>
<span class="line" id="L351">            .line = <span class="tok-number">1</span>,</span>
<span class="line" id="L352">            .column = <span class="tok-number">0</span>,</span>
<span class="line" id="L353">            .is_stmt = is_stmt,</span>
<span class="line" id="L354">            .basic_block = <span class="tok-null">false</span>,</span>
<span class="line" id="L355">            .end_sequence = <span class="tok-null">false</span>,</span>
<span class="line" id="L356">            .include_dirs = include_dirs,</span>
<span class="line" id="L357">            .default_is_stmt = is_stmt,</span>
<span class="line" id="L358">            .target_address = target_address,</span>
<span class="line" id="L359">            .prev_valid = <span class="tok-null">false</span>,</span>
<span class="line" id="L360">            .prev_address = <span class="tok-number">0</span>,</span>
<span class="line" id="L361">            .prev_file = <span class="tok-null">undefined</span>,</span>
<span class="line" id="L362">            .prev_line = <span class="tok-null">undefined</span>,</span>
<span class="line" id="L363">            .prev_column = <span class="tok-null">undefined</span>,</span>
<span class="line" id="L364">            .prev_is_stmt = <span class="tok-null">undefined</span>,</span>
<span class="line" id="L365">            .prev_basic_block = <span class="tok-null">undefined</span>,</span>
<span class="line" id="L366">            .prev_end_sequence = <span class="tok-null">undefined</span>,</span>
<span class="line" id="L367">        };</span>
<span class="line" id="L368">    }</span>
<span class="line" id="L369"></span>
<span class="line" id="L370">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">checkLineMatch</span>(</span>
<span class="line" id="L371">        self: *LineNumberProgram,</span>
<span class="line" id="L372">        allocator: mem.Allocator,</span>
<span class="line" id="L373">        file_entries: []<span class="tok-kw">const</span> FileEntry,</span>
<span class="line" id="L374">    ) !?debug.LineInfo {</span>
<span class="line" id="L375">        <span class="tok-kw">if</span> (self.prev_valid <span class="tok-kw">and</span> self.target_address &gt;= self.prev_address <span class="tok-kw">and</span> self.target_address &lt; self.address) {</span>
<span class="line" id="L376">            <span class="tok-kw">const</span> file_entry = <span class="tok-kw">if</span> (self.prev_file == <span class="tok-number">0</span>) {</span>
<span class="line" id="L377">                <span class="tok-kw">return</span> <span class="tok-kw">error</span>.MissingDebugInfo;</span>
<span class="line" id="L378">            } <span class="tok-kw">else</span> <span class="tok-kw">if</span> (self.prev_file - <span class="tok-number">1</span> &gt;= file_entries.len) {</span>
<span class="line" id="L379">                <span class="tok-kw">return</span> <span class="tok-kw">error</span>.InvalidDebugInfo;</span>
<span class="line" id="L380">            } <span class="tok-kw">else</span> &amp;file_entries[self.prev_file - <span class="tok-number">1</span>];</span>
<span class="line" id="L381"></span>
<span class="line" id="L382">            <span class="tok-kw">const</span> dir_name = <span class="tok-kw">if</span> (file_entry.dir_index &gt;= self.include_dirs.len) {</span>
<span class="line" id="L383">                <span class="tok-kw">return</span> <span class="tok-kw">error</span>.InvalidDebugInfo;</span>
<span class="line" id="L384">            } <span class="tok-kw">else</span> self.include_dirs[file_entry.dir_index];</span>
<span class="line" id="L385"></span>
<span class="line" id="L386">            <span class="tok-kw">const</span> file_name = <span class="tok-kw">try</span> fs.path.join(allocator, &amp;[_][]<span class="tok-kw">const</span> <span class="tok-type">u8</span>{ dir_name, file_entry.file_name });</span>
<span class="line" id="L387"></span>
<span class="line" id="L388">            <span class="tok-kw">return</span> debug.LineInfo{</span>
<span class="line" id="L389">                .line = <span class="tok-kw">if</span> (self.prev_line &gt;= <span class="tok-number">0</span>) <span class="tok-builtin">@intCast</span>(<span class="tok-type">u64</span>, self.prev_line) <span class="tok-kw">else</span> <span class="tok-number">0</span>,</span>
<span class="line" id="L390">                .column = self.prev_column,</span>
<span class="line" id="L391">                .file_name = file_name,</span>
<span class="line" id="L392">            };</span>
<span class="line" id="L393">        }</span>
<span class="line" id="L394"></span>
<span class="line" id="L395">        self.prev_valid = <span class="tok-null">true</span>;</span>
<span class="line" id="L396">        self.prev_address = self.address;</span>
<span class="line" id="L397">        self.prev_file = self.file;</span>
<span class="line" id="L398">        self.prev_line = self.line;</span>
<span class="line" id="L399">        self.prev_column = self.column;</span>
<span class="line" id="L400">        self.prev_is_stmt = self.is_stmt;</span>
<span class="line" id="L401">        self.prev_basic_block = self.basic_block;</span>
<span class="line" id="L402">        self.prev_end_sequence = self.end_sequence;</span>
<span class="line" id="L403">        <span class="tok-kw">return</span> <span class="tok-null">null</span>;</span>
<span class="line" id="L404">    }</span>
<span class="line" id="L405">};</span>
<span class="line" id="L406"></span>
<span class="line" id="L407"><span class="tok-kw">fn</span> <span class="tok-fn">readUnitLength</span>(in_stream: <span class="tok-kw">anytype</span>, endian: std.builtin.Endian, is_64: *<span class="tok-type">bool</span>) !<span class="tok-type">u64</span> {</span>
<span class="line" id="L408">    <span class="tok-kw">const</span> first_32_bits = <span class="tok-kw">try</span> in_stream.readInt(<span class="tok-type">u32</span>, endian);</span>
<span class="line" id="L409">    is_64.* = (first_32_bits == <span class="tok-number">0xffffffff</span>);</span>
<span class="line" id="L410">    <span class="tok-kw">if</span> (is_64.*) {</span>
<span class="line" id="L411">        <span class="tok-kw">return</span> in_stream.readInt(<span class="tok-type">u64</span>, endian);</span>
<span class="line" id="L412">    } <span class="tok-kw">else</span> {</span>
<span class="line" id="L413">        <span class="tok-kw">if</span> (first_32_bits &gt;= <span class="tok-number">0xfffffff0</span>) <span class="tok-kw">return</span> <span class="tok-kw">error</span>.InvalidDebugInfo;</span>
<span class="line" id="L414">        <span class="tok-comment">// TODO this cast should not be needed</span>
</span>
<span class="line" id="L415">        <span class="tok-kw">return</span> <span class="tok-builtin">@as</span>(<span class="tok-type">u64</span>, first_32_bits);</span>
<span class="line" id="L416">    }</span>
<span class="line" id="L417">}</span>
<span class="line" id="L418"></span>
<span class="line" id="L419"><span class="tok-comment">// TODO the nosuspends here are workarounds</span>
</span>
<span class="line" id="L420"><span class="tok-kw">fn</span> <span class="tok-fn">readAllocBytes</span>(allocator: mem.Allocator, in_stream: <span class="tok-kw">anytype</span>, size: <span class="tok-type">usize</span>) ![]<span class="tok-type">u8</span> {</span>
<span class="line" id="L421">    <span class="tok-kw">const</span> buf = <span class="tok-kw">try</span> allocator.alloc(<span class="tok-type">u8</span>, size);</span>
<span class="line" id="L422">    <span class="tok-kw">errdefer</span> allocator.free(buf);</span>
<span class="line" id="L423">    <span class="tok-kw">if</span> ((<span class="tok-kw">try</span> <span class="tok-kw">nosuspend</span> in_stream.read(buf)) &lt; size) <span class="tok-kw">return</span> <span class="tok-kw">error</span>.EndOfFile;</span>
<span class="line" id="L424">    <span class="tok-kw">return</span> buf;</span>
<span class="line" id="L425">}</span>
<span class="line" id="L426"></span>
<span class="line" id="L427"><span class="tok-comment">// TODO the nosuspends here are workarounds</span>
</span>
<span class="line" id="L428"><span class="tok-kw">fn</span> <span class="tok-fn">readAddress</span>(in_stream: <span class="tok-kw">anytype</span>, endian: std.builtin.Endian, is_64: <span class="tok-type">bool</span>) !<span class="tok-type">u64</span> {</span>
<span class="line" id="L429">    <span class="tok-kw">return</span> <span class="tok-kw">nosuspend</span> <span class="tok-kw">if</span> (is_64)</span>
<span class="line" id="L430">        <span class="tok-kw">try</span> in_stream.readInt(<span class="tok-type">u64</span>, endian)</span>
<span class="line" id="L431">    <span class="tok-kw">else</span></span>
<span class="line" id="L432">        <span class="tok-builtin">@as</span>(<span class="tok-type">u64</span>, <span class="tok-kw">try</span> in_stream.readInt(<span class="tok-type">u32</span>, endian));</span>
<span class="line" id="L433">}</span>
<span class="line" id="L434"></span>
<span class="line" id="L435"><span class="tok-kw">fn</span> <span class="tok-fn">parseFormValueBlockLen</span>(allocator: mem.Allocator, in_stream: <span class="tok-kw">anytype</span>, size: <span class="tok-type">usize</span>) !FormValue {</span>
<span class="line" id="L436">    <span class="tok-kw">const</span> buf = <span class="tok-kw">try</span> readAllocBytes(allocator, in_stream, size);</span>
<span class="line" id="L437">    <span class="tok-kw">return</span> FormValue{ .Block = buf };</span>
<span class="line" id="L438">}</span>
<span class="line" id="L439"></span>
<span class="line" id="L440"><span class="tok-comment">// TODO the nosuspends here are workarounds</span>
</span>
<span class="line" id="L441"><span class="tok-kw">fn</span> <span class="tok-fn">parseFormValueBlock</span>(allocator: mem.Allocator, in_stream: <span class="tok-kw">anytype</span>, endian: std.builtin.Endian, size: <span class="tok-type">usize</span>) !FormValue {</span>
<span class="line" id="L442">    <span class="tok-kw">const</span> block_len = <span class="tok-kw">try</span> <span class="tok-kw">nosuspend</span> in_stream.readVarInt(<span class="tok-type">usize</span>, endian, size);</span>
<span class="line" id="L443">    <span class="tok-kw">return</span> parseFormValueBlockLen(allocator, in_stream, block_len);</span>
<span class="line" id="L444">}</span>
<span class="line" id="L445"></span>
<span class="line" id="L446"><span class="tok-kw">fn</span> <span class="tok-fn">parseFormValueConstant</span>(in_stream: <span class="tok-kw">anytype</span>, signed: <span class="tok-type">bool</span>, endian: std.builtin.Endian, <span class="tok-kw">comptime</span> size: <span class="tok-type">i32</span>) !FormValue {</span>
<span class="line" id="L447">    <span class="tok-comment">// TODO: Please forgive me, I've worked around zig not properly spilling some intermediate values here.</span>
</span>
<span class="line" id="L448">    <span class="tok-comment">// `nosuspend` should be removed from all the function calls once it is fixed.</span>
</span>
<span class="line" id="L449">    <span class="tok-kw">return</span> FormValue{</span>
<span class="line" id="L450">        .Const = Constant{</span>
<span class="line" id="L451">            .signed = signed,</span>
<span class="line" id="L452">            .payload = <span class="tok-kw">switch</span> (size) {</span>
<span class="line" id="L453">                <span class="tok-number">1</span> =&gt; <span class="tok-kw">try</span> <span class="tok-kw">nosuspend</span> in_stream.readInt(<span class="tok-type">u8</span>, endian),</span>
<span class="line" id="L454">                <span class="tok-number">2</span> =&gt; <span class="tok-kw">try</span> <span class="tok-kw">nosuspend</span> in_stream.readInt(<span class="tok-type">u16</span>, endian),</span>
<span class="line" id="L455">                <span class="tok-number">4</span> =&gt; <span class="tok-kw">try</span> <span class="tok-kw">nosuspend</span> in_stream.readInt(<span class="tok-type">u32</span>, endian),</span>
<span class="line" id="L456">                <span class="tok-number">8</span> =&gt; <span class="tok-kw">try</span> <span class="tok-kw">nosuspend</span> in_stream.readInt(<span class="tok-type">u64</span>, endian),</span>
<span class="line" id="L457">                -<span class="tok-number">1</span> =&gt; blk: {</span>
<span class="line" id="L458">                    <span class="tok-kw">if</span> (signed) {</span>
<span class="line" id="L459">                        <span class="tok-kw">const</span> x = <span class="tok-kw">try</span> <span class="tok-kw">nosuspend</span> leb.readILEB128(<span class="tok-type">i64</span>, in_stream);</span>
<span class="line" id="L460">                        <span class="tok-kw">break</span> :blk <span class="tok-builtin">@bitCast</span>(<span class="tok-type">u64</span>, x);</span>
<span class="line" id="L461">                    } <span class="tok-kw">else</span> {</span>
<span class="line" id="L462">                        <span class="tok-kw">const</span> x = <span class="tok-kw">try</span> <span class="tok-kw">nosuspend</span> leb.readULEB128(<span class="tok-type">u64</span>, in_stream);</span>
<span class="line" id="L463">                        <span class="tok-kw">break</span> :blk x;</span>
<span class="line" id="L464">                    }</span>
<span class="line" id="L465">                },</span>
<span class="line" id="L466">                <span class="tok-kw">else</span> =&gt; <span class="tok-builtin">@compileError</span>(<span class="tok-str">&quot;Invalid size&quot;</span>),</span>
<span class="line" id="L467">            },</span>
<span class="line" id="L468">        },</span>
<span class="line" id="L469">    };</span>
<span class="line" id="L470">}</span>
<span class="line" id="L471"></span>
<span class="line" id="L472"><span class="tok-comment">// TODO the nosuspends here are workarounds</span>
</span>
<span class="line" id="L473"><span class="tok-kw">fn</span> <span class="tok-fn">parseFormValueRef</span>(in_stream: <span class="tok-kw">anytype</span>, endian: std.builtin.Endian, size: <span class="tok-type">i32</span>) !FormValue {</span>
<span class="line" id="L474">    <span class="tok-kw">return</span> FormValue{</span>
<span class="line" id="L475">        .Ref = <span class="tok-kw">switch</span> (size) {</span>
<span class="line" id="L476">            <span class="tok-number">1</span> =&gt; <span class="tok-kw">try</span> <span class="tok-kw">nosuspend</span> in_stream.readInt(<span class="tok-type">u8</span>, endian),</span>
<span class="line" id="L477">            <span class="tok-number">2</span> =&gt; <span class="tok-kw">try</span> <span class="tok-kw">nosuspend</span> in_stream.readInt(<span class="tok-type">u16</span>, endian),</span>
<span class="line" id="L478">            <span class="tok-number">4</span> =&gt; <span class="tok-kw">try</span> <span class="tok-kw">nosuspend</span> in_stream.readInt(<span class="tok-type">u32</span>, endian),</span>
<span class="line" id="L479">            <span class="tok-number">8</span> =&gt; <span class="tok-kw">try</span> <span class="tok-kw">nosuspend</span> in_stream.readInt(<span class="tok-type">u64</span>, endian),</span>
<span class="line" id="L480">            -<span class="tok-number">1</span> =&gt; <span class="tok-kw">try</span> <span class="tok-kw">nosuspend</span> leb.readULEB128(<span class="tok-type">u64</span>, in_stream),</span>
<span class="line" id="L481">            <span class="tok-kw">else</span> =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L482">        },</span>
<span class="line" id="L483">    };</span>
<span class="line" id="L484">}</span>
<span class="line" id="L485"></span>
<span class="line" id="L486"><span class="tok-comment">// TODO the nosuspends here are workarounds</span>
</span>
<span class="line" id="L487"><span class="tok-kw">fn</span> <span class="tok-fn">parseFormValue</span>(allocator: mem.Allocator, in_stream: <span class="tok-kw">anytype</span>, form_id: <span class="tok-type">u64</span>, endian: std.builtin.Endian, is_64: <span class="tok-type">bool</span>) <span class="tok-type">anyerror</span>!FormValue {</span>
<span class="line" id="L488">    <span class="tok-kw">return</span> <span class="tok-kw">switch</span> (form_id) {</span>
<span class="line" id="L489">        FORM.addr =&gt; FormValue{ .Address = <span class="tok-kw">try</span> readAddress(in_stream, endian, <span class="tok-builtin">@sizeOf</span>(<span class="tok-type">usize</span>) == <span class="tok-number">8</span>) },</span>
<span class="line" id="L490">        FORM.block1 =&gt; parseFormValueBlock(allocator, in_stream, endian, <span class="tok-number">1</span>),</span>
<span class="line" id="L491">        FORM.block2 =&gt; parseFormValueBlock(allocator, in_stream, endian, <span class="tok-number">2</span>),</span>
<span class="line" id="L492">        FORM.block4 =&gt; parseFormValueBlock(allocator, in_stream, endian, <span class="tok-number">4</span>),</span>
<span class="line" id="L493">        FORM.block =&gt; {</span>
<span class="line" id="L494">            <span class="tok-kw">const</span> block_len = <span class="tok-kw">try</span> <span class="tok-kw">nosuspend</span> leb.readULEB128(<span class="tok-type">usize</span>, in_stream);</span>
<span class="line" id="L495">            <span class="tok-kw">return</span> parseFormValueBlockLen(allocator, in_stream, block_len);</span>
<span class="line" id="L496">        },</span>
<span class="line" id="L497">        FORM.data1 =&gt; parseFormValueConstant(in_stream, <span class="tok-null">false</span>, endian, <span class="tok-number">1</span>),</span>
<span class="line" id="L498">        FORM.data2 =&gt; parseFormValueConstant(in_stream, <span class="tok-null">false</span>, endian, <span class="tok-number">2</span>),</span>
<span class="line" id="L499">        FORM.data4 =&gt; parseFormValueConstant(in_stream, <span class="tok-null">false</span>, endian, <span class="tok-number">4</span>),</span>
<span class="line" id="L500">        FORM.data8 =&gt; parseFormValueConstant(in_stream, <span class="tok-null">false</span>, endian, <span class="tok-number">8</span>),</span>
<span class="line" id="L501">        FORM.udata, FORM.sdata =&gt; {</span>
<span class="line" id="L502">            <span class="tok-kw">const</span> signed = form_id == FORM.sdata;</span>
<span class="line" id="L503">            <span class="tok-kw">return</span> parseFormValueConstant(in_stream, signed, endian, -<span class="tok-number">1</span>);</span>
<span class="line" id="L504">        },</span>
<span class="line" id="L505">        FORM.exprloc =&gt; {</span>
<span class="line" id="L506">            <span class="tok-kw">const</span> size = <span class="tok-kw">try</span> <span class="tok-kw">nosuspend</span> leb.readULEB128(<span class="tok-type">usize</span>, in_stream);</span>
<span class="line" id="L507">            <span class="tok-kw">const</span> buf = <span class="tok-kw">try</span> readAllocBytes(allocator, in_stream, size);</span>
<span class="line" id="L508">            <span class="tok-kw">return</span> FormValue{ .ExprLoc = buf };</span>
<span class="line" id="L509">        },</span>
<span class="line" id="L510">        FORM.flag =&gt; FormValue{ .Flag = (<span class="tok-kw">try</span> <span class="tok-kw">nosuspend</span> in_stream.readByte()) != <span class="tok-number">0</span> },</span>
<span class="line" id="L511">        FORM.flag_present =&gt; FormValue{ .Flag = <span class="tok-null">true</span> },</span>
<span class="line" id="L512">        FORM.sec_offset =&gt; FormValue{ .SecOffset = <span class="tok-kw">try</span> readAddress(in_stream, endian, is_64) },</span>
<span class="line" id="L513"></span>
<span class="line" id="L514">        FORM.ref1 =&gt; parseFormValueRef(in_stream, endian, <span class="tok-number">1</span>),</span>
<span class="line" id="L515">        FORM.ref2 =&gt; parseFormValueRef(in_stream, endian, <span class="tok-number">2</span>),</span>
<span class="line" id="L516">        FORM.ref4 =&gt; parseFormValueRef(in_stream, endian, <span class="tok-number">4</span>),</span>
<span class="line" id="L517">        FORM.ref8 =&gt; parseFormValueRef(in_stream, endian, <span class="tok-number">8</span>),</span>
<span class="line" id="L518">        FORM.ref_udata =&gt; parseFormValueRef(in_stream, endian, -<span class="tok-number">1</span>),</span>
<span class="line" id="L519"></span>
<span class="line" id="L520">        FORM.ref_addr =&gt; FormValue{ .RefAddr = <span class="tok-kw">try</span> readAddress(in_stream, endian, is_64) },</span>
<span class="line" id="L521">        FORM.ref_sig8 =&gt; FormValue{ .Ref = <span class="tok-kw">try</span> <span class="tok-kw">nosuspend</span> in_stream.readInt(<span class="tok-type">u64</span>, endian) },</span>
<span class="line" id="L522"></span>
<span class="line" id="L523">        FORM.string =&gt; FormValue{ .String = <span class="tok-kw">try</span> in_stream.readUntilDelimiterAlloc(allocator, <span class="tok-number">0</span>, math.maxInt(<span class="tok-type">usize</span>)) },</span>
<span class="line" id="L524">        FORM.strp =&gt; FormValue{ .StrPtr = <span class="tok-kw">try</span> readAddress(in_stream, endian, is_64) },</span>
<span class="line" id="L525">        FORM.line_strp =&gt; FormValue{ .LineStrPtr = <span class="tok-kw">try</span> readAddress(in_stream, endian, is_64) },</span>
<span class="line" id="L526">        FORM.indirect =&gt; {</span>
<span class="line" id="L527">            <span class="tok-kw">const</span> child_form_id = <span class="tok-kw">try</span> <span class="tok-kw">nosuspend</span> leb.readULEB128(<span class="tok-type">u64</span>, in_stream);</span>
<span class="line" id="L528">            <span class="tok-kw">if</span> (builtin.zig_backend != .stage1) {</span>
<span class="line" id="L529">                <span class="tok-kw">return</span> parseFormValue(allocator, in_stream, child_form_id, endian, is_64);</span>
<span class="line" id="L530">            }</span>
<span class="line" id="L531">            <span class="tok-kw">const</span> F = <span class="tok-builtin">@TypeOf</span>(<span class="tok-kw">async</span> parseFormValue(allocator, in_stream, child_form_id, endian, is_64));</span>
<span class="line" id="L532">            <span class="tok-kw">var</span> frame = <span class="tok-kw">try</span> allocator.create(F);</span>
<span class="line" id="L533">            <span class="tok-kw">defer</span> allocator.destroy(frame);</span>
<span class="line" id="L534">            <span class="tok-kw">return</span> <span class="tok-kw">await</span> <span class="tok-builtin">@asyncCall</span>(frame, {}, parseFormValue, .{ allocator, in_stream, child_form_id, endian, is_64 });</span>
<span class="line" id="L535">        },</span>
<span class="line" id="L536">        FORM.implicit_const =&gt; FormValue{ .Const = Constant{ .signed = <span class="tok-null">true</span>, .payload = <span class="tok-null">undefined</span> } },</span>
<span class="line" id="L537"></span>
<span class="line" id="L538">        <span class="tok-kw">else</span> =&gt; {</span>
<span class="line" id="L539">            <span class="tok-kw">return</span> <span class="tok-kw">error</span>.InvalidDebugInfo;</span>
<span class="line" id="L540">        },</span>
<span class="line" id="L541">    };</span>
<span class="line" id="L542">}</span>
<span class="line" id="L543"></span>
<span class="line" id="L544"><span class="tok-kw">fn</span> <span class="tok-fn">getAbbrevTableEntry</span>(abbrev_table: *<span class="tok-kw">const</span> AbbrevTable, abbrev_code: <span class="tok-type">u64</span>) ?*<span class="tok-kw">const</span> AbbrevTableEntry {</span>
<span class="line" id="L545">    <span class="tok-kw">for</span> (abbrev_table.items) |*table_entry| {</span>
<span class="line" id="L546">        <span class="tok-kw">if</span> (table_entry.abbrev_code == abbrev_code) <span class="tok-kw">return</span> table_entry;</span>
<span class="line" id="L547">    }</span>
<span class="line" id="L548">    <span class="tok-kw">return</span> <span class="tok-null">null</span>;</span>
<span class="line" id="L549">}</span>
<span class="line" id="L550"></span>
<span class="line" id="L551"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> DwarfInfo = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L552">    endian: std.builtin.Endian,</span>
<span class="line" id="L553">    <span class="tok-comment">// No memory is owned by the DwarfInfo</span>
</span>
<span class="line" id="L554">    debug_info: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>,</span>
<span class="line" id="L555">    debug_abbrev: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>,</span>
<span class="line" id="L556">    debug_str: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>,</span>
<span class="line" id="L557">    debug_line: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>,</span>
<span class="line" id="L558">    debug_line_str: ?[]<span class="tok-kw">const</span> <span class="tok-type">u8</span>,</span>
<span class="line" id="L559">    debug_ranges: ?[]<span class="tok-kw">const</span> <span class="tok-type">u8</span>,</span>
<span class="line" id="L560">    <span class="tok-comment">// Filled later by the initializer</span>
</span>
<span class="line" id="L561">    abbrev_table_list: std.ArrayListUnmanaged(AbbrevTableHeader) = .{},</span>
<span class="line" id="L562">    compile_unit_list: std.ArrayListUnmanaged(CompileUnit) = .{},</span>
<span class="line" id="L563">    func_list: std.ArrayListUnmanaged(Func) = .{},</span>
<span class="line" id="L564"></span>
<span class="line" id="L565">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">deinit</span>(di: *DwarfInfo, allocator: mem.Allocator) <span class="tok-type">void</span> {</span>
<span class="line" id="L566">        <span class="tok-kw">for</span> (di.abbrev_table_list.items) |*abbrev| {</span>
<span class="line" id="L567">            abbrev.deinit();</span>
<span class="line" id="L568">        }</span>
<span class="line" id="L569">        di.abbrev_table_list.deinit(allocator);</span>
<span class="line" id="L570">        <span class="tok-kw">for</span> (di.compile_unit_list.items) |*cu| {</span>
<span class="line" id="L571">            cu.die.deinit(allocator);</span>
<span class="line" id="L572">            allocator.destroy(cu.die);</span>
<span class="line" id="L573">        }</span>
<span class="line" id="L574">        di.compile_unit_list.deinit(allocator);</span>
<span class="line" id="L575">        <span class="tok-kw">for</span> (di.func_list.items) |*func| {</span>
<span class="line" id="L576">            func.deinit(allocator);</span>
<span class="line" id="L577">        }</span>
<span class="line" id="L578">        di.func_list.deinit(allocator);</span>
<span class="line" id="L579">    }</span>
<span class="line" id="L580"></span>
<span class="line" id="L581">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">getSymbolName</span>(di: *DwarfInfo, address: <span class="tok-type">u64</span>) ?[]<span class="tok-kw">const</span> <span class="tok-type">u8</span> {</span>
<span class="line" id="L582">        <span class="tok-kw">for</span> (di.func_list.items) |*func| {</span>
<span class="line" id="L583">            <span class="tok-kw">if</span> (func.pc_range) |range| {</span>
<span class="line" id="L584">                <span class="tok-kw">if</span> (address &gt;= range.start <span class="tok-kw">and</span> address &lt; range.end) {</span>
<span class="line" id="L585">                    <span class="tok-kw">return</span> func.name;</span>
<span class="line" id="L586">                }</span>
<span class="line" id="L587">            }</span>
<span class="line" id="L588">        }</span>
<span class="line" id="L589"></span>
<span class="line" id="L590">        <span class="tok-kw">return</span> <span class="tok-null">null</span>;</span>
<span class="line" id="L591">    }</span>
<span class="line" id="L592"></span>
<span class="line" id="L593">    <span class="tok-kw">fn</span> <span class="tok-fn">scanAllFunctions</span>(di: *DwarfInfo, allocator: mem.Allocator) !<span class="tok-type">void</span> {</span>
<span class="line" id="L594">        <span class="tok-kw">var</span> stream = io.fixedBufferStream(di.debug_info);</span>
<span class="line" id="L595">        <span class="tok-kw">const</span> in = &amp;stream.reader();</span>
<span class="line" id="L596">        <span class="tok-kw">const</span> seekable = &amp;stream.seekableStream();</span>
<span class="line" id="L597">        <span class="tok-kw">var</span> this_unit_offset: <span class="tok-type">u64</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L598"></span>
<span class="line" id="L599">        <span class="tok-kw">var</span> tmp_arena = std.heap.ArenaAllocator.init(allocator);</span>
<span class="line" id="L600">        <span class="tok-kw">defer</span> tmp_arena.deinit();</span>
<span class="line" id="L601">        <span class="tok-kw">const</span> arena = tmp_arena.allocator();</span>
<span class="line" id="L602"></span>
<span class="line" id="L603">        <span class="tok-kw">while</span> (this_unit_offset &lt; <span class="tok-kw">try</span> seekable.getEndPos()) {</span>
<span class="line" id="L604">            <span class="tok-kw">try</span> seekable.seekTo(this_unit_offset);</span>
<span class="line" id="L605"></span>
<span class="line" id="L606">            <span class="tok-kw">var</span> is_64: <span class="tok-type">bool</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L607">            <span class="tok-kw">const</span> unit_length = <span class="tok-kw">try</span> readUnitLength(in, di.endian, &amp;is_64);</span>
<span class="line" id="L608">            <span class="tok-kw">if</span> (unit_length == <span class="tok-number">0</span>) <span class="tok-kw">return</span>;</span>
<span class="line" id="L609">            <span class="tok-kw">const</span> next_offset = unit_length + (<span class="tok-kw">if</span> (is_64) <span class="tok-builtin">@as</span>(<span class="tok-type">usize</span>, <span class="tok-number">12</span>) <span class="tok-kw">else</span> <span class="tok-builtin">@as</span>(<span class="tok-type">usize</span>, <span class="tok-number">4</span>));</span>
<span class="line" id="L610"></span>
<span class="line" id="L611">            <span class="tok-kw">const</span> version = <span class="tok-kw">try</span> in.readInt(<span class="tok-type">u16</span>, di.endian);</span>
<span class="line" id="L612">            <span class="tok-kw">if</span> (version &lt; <span class="tok-number">2</span> <span class="tok-kw">or</span> version &gt; <span class="tok-number">5</span>) <span class="tok-kw">return</span> <span class="tok-kw">error</span>.InvalidDebugInfo;</span>
<span class="line" id="L613"></span>
<span class="line" id="L614">            <span class="tok-kw">var</span> address_size: <span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L615">            <span class="tok-kw">var</span> debug_abbrev_offset: <span class="tok-type">u64</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L616">            <span class="tok-kw">switch</span> (version) {</span>
<span class="line" id="L617">                <span class="tok-number">5</span> =&gt; {</span>
<span class="line" id="L618">                    <span class="tok-kw">const</span> unit_type = <span class="tok-kw">try</span> in.readInt(<span class="tok-type">u8</span>, di.endian);</span>
<span class="line" id="L619">                    <span class="tok-kw">if</span> (unit_type != UT.compile) <span class="tok-kw">return</span> <span class="tok-kw">error</span>.InvalidDebugInfo;</span>
<span class="line" id="L620">                    address_size = <span class="tok-kw">try</span> in.readByte();</span>
<span class="line" id="L621">                    debug_abbrev_offset = <span class="tok-kw">if</span> (is_64)</span>
<span class="line" id="L622">                        <span class="tok-kw">try</span> in.readInt(<span class="tok-type">u64</span>, di.endian)</span>
<span class="line" id="L623">                    <span class="tok-kw">else</span></span>
<span class="line" id="L624">                        <span class="tok-kw">try</span> in.readInt(<span class="tok-type">u32</span>, di.endian);</span>
<span class="line" id="L625">                },</span>
<span class="line" id="L626">                <span class="tok-kw">else</span> =&gt; {</span>
<span class="line" id="L627">                    debug_abbrev_offset = <span class="tok-kw">if</span> (is_64)</span>
<span class="line" id="L628">                        <span class="tok-kw">try</span> in.readInt(<span class="tok-type">u64</span>, di.endian)</span>
<span class="line" id="L629">                    <span class="tok-kw">else</span></span>
<span class="line" id="L630">                        <span class="tok-kw">try</span> in.readInt(<span class="tok-type">u32</span>, di.endian);</span>
<span class="line" id="L631">                    address_size = <span class="tok-kw">try</span> in.readByte();</span>
<span class="line" id="L632">                },</span>
<span class="line" id="L633">            }</span>
<span class="line" id="L634">            <span class="tok-kw">if</span> (address_size != <span class="tok-builtin">@sizeOf</span>(<span class="tok-type">usize</span>)) <span class="tok-kw">return</span> <span class="tok-kw">error</span>.InvalidDebugInfo;</span>
<span class="line" id="L635"></span>
<span class="line" id="L636">            <span class="tok-kw">const</span> compile_unit_pos = <span class="tok-kw">try</span> seekable.getPos();</span>
<span class="line" id="L637">            <span class="tok-kw">const</span> abbrev_table = <span class="tok-kw">try</span> di.getAbbrevTable(allocator, debug_abbrev_offset);</span>
<span class="line" id="L638"></span>
<span class="line" id="L639">            <span class="tok-kw">try</span> seekable.seekTo(compile_unit_pos);</span>
<span class="line" id="L640"></span>
<span class="line" id="L641">            <span class="tok-kw">const</span> next_unit_pos = this_unit_offset + next_offset;</span>
<span class="line" id="L642"></span>
<span class="line" id="L643">            <span class="tok-kw">while</span> ((<span class="tok-kw">try</span> seekable.getPos()) &lt; next_unit_pos) {</span>
<span class="line" id="L644">                <span class="tok-kw">const</span> die_obj = (<span class="tok-kw">try</span> di.parseDie(arena, in, abbrev_table, is_64)) <span class="tok-kw">orelse</span> <span class="tok-kw">continue</span>;</span>
<span class="line" id="L645">                <span class="tok-kw">const</span> after_die_offset = <span class="tok-kw">try</span> seekable.getPos();</span>
<span class="line" id="L646"></span>
<span class="line" id="L647">                <span class="tok-kw">switch</span> (die_obj.tag_id) {</span>
<span class="line" id="L648">                    TAG.subprogram, TAG.inlined_subroutine, TAG.subroutine, TAG.entry_point =&gt; {</span>
<span class="line" id="L649">                        <span class="tok-kw">const</span> fn_name = x: {</span>
<span class="line" id="L650">                            <span class="tok-kw">var</span> depth: <span class="tok-type">i32</span> = <span class="tok-number">3</span>;</span>
<span class="line" id="L651">                            <span class="tok-kw">var</span> this_die_obj = die_obj;</span>
<span class="line" id="L652">                            <span class="tok-comment">// Prevent endless loops</span>
</span>
<span class="line" id="L653">                            <span class="tok-kw">while</span> (depth &gt; <span class="tok-number">0</span>) : (depth -= <span class="tok-number">1</span>) {</span>
<span class="line" id="L654">                                <span class="tok-kw">if</span> (this_die_obj.getAttr(AT.name)) |_| {</span>
<span class="line" id="L655">                                    <span class="tok-kw">const</span> name = <span class="tok-kw">try</span> this_die_obj.getAttrString(di, AT.name);</span>
<span class="line" id="L656">                                    <span class="tok-kw">break</span> :x <span class="tok-kw">try</span> allocator.dupe(<span class="tok-type">u8</span>, name);</span>
<span class="line" id="L657">                                } <span class="tok-kw">else</span> <span class="tok-kw">if</span> (this_die_obj.getAttr(AT.abstract_origin)) |_| {</span>
<span class="line" id="L658">                                    <span class="tok-comment">// Follow the DIE it points to and repeat</span>
</span>
<span class="line" id="L659">                                    <span class="tok-kw">const</span> ref_offset = <span class="tok-kw">try</span> this_die_obj.getAttrRef(AT.abstract_origin);</span>
<span class="line" id="L660">                                    <span class="tok-kw">if</span> (ref_offset &gt; next_offset) <span class="tok-kw">return</span> <span class="tok-kw">error</span>.InvalidDebugInfo;</span>
<span class="line" id="L661">                                    <span class="tok-kw">try</span> seekable.seekTo(this_unit_offset + ref_offset);</span>
<span class="line" id="L662">                                    this_die_obj = (<span class="tok-kw">try</span> di.parseDie(</span>
<span class="line" id="L663">                                        arena,</span>
<span class="line" id="L664">                                        in,</span>
<span class="line" id="L665">                                        abbrev_table,</span>
<span class="line" id="L666">                                        is_64,</span>
<span class="line" id="L667">                                    )) <span class="tok-kw">orelse</span> <span class="tok-kw">return</span> <span class="tok-kw">error</span>.InvalidDebugInfo;</span>
<span class="line" id="L668">                                } <span class="tok-kw">else</span> <span class="tok-kw">if</span> (this_die_obj.getAttr(AT.specification)) |_| {</span>
<span class="line" id="L669">                                    <span class="tok-comment">// Follow the DIE it points to and repeat</span>
</span>
<span class="line" id="L670">                                    <span class="tok-kw">const</span> ref_offset = <span class="tok-kw">try</span> this_die_obj.getAttrRef(AT.specification);</span>
<span class="line" id="L671">                                    <span class="tok-kw">if</span> (ref_offset &gt; next_offset) <span class="tok-kw">return</span> <span class="tok-kw">error</span>.InvalidDebugInfo;</span>
<span class="line" id="L672">                                    <span class="tok-kw">try</span> seekable.seekTo(this_unit_offset + ref_offset);</span>
<span class="line" id="L673">                                    this_die_obj = (<span class="tok-kw">try</span> di.parseDie(</span>
<span class="line" id="L674">                                        arena,</span>
<span class="line" id="L675">                                        in,</span>
<span class="line" id="L676">                                        abbrev_table,</span>
<span class="line" id="L677">                                        is_64,</span>
<span class="line" id="L678">                                    )) <span class="tok-kw">orelse</span> <span class="tok-kw">return</span> <span class="tok-kw">error</span>.InvalidDebugInfo;</span>
<span class="line" id="L679">                                } <span class="tok-kw">else</span> {</span>
<span class="line" id="L680">                                    <span class="tok-kw">break</span> :x <span class="tok-null">null</span>;</span>
<span class="line" id="L681">                                }</span>
<span class="line" id="L682">                            }</span>
<span class="line" id="L683"></span>
<span class="line" id="L684">                            <span class="tok-kw">break</span> :x <span class="tok-null">null</span>;</span>
<span class="line" id="L685">                        };</span>
<span class="line" id="L686"></span>
<span class="line" id="L687">                        <span class="tok-kw">const</span> pc_range = x: {</span>
<span class="line" id="L688">                            <span class="tok-kw">if</span> (die_obj.getAttrAddr(AT.low_pc)) |low_pc| {</span>
<span class="line" id="L689">                                <span class="tok-kw">if</span> (die_obj.getAttr(AT.high_pc)) |high_pc_value| {</span>
<span class="line" id="L690">                                    <span class="tok-kw">const</span> pc_end = <span class="tok-kw">switch</span> (high_pc_value.*) {</span>
<span class="line" id="L691">                                        FormValue.Address =&gt; |value| value,</span>
<span class="line" id="L692">                                        FormValue.Const =&gt; |value| b: {</span>
<span class="line" id="L693">                                            <span class="tok-kw">const</span> offset = <span class="tok-kw">try</span> value.asUnsignedLe();</span>
<span class="line" id="L694">                                            <span class="tok-kw">break</span> :b (low_pc + offset);</span>
<span class="line" id="L695">                                        },</span>
<span class="line" id="L696">                                        <span class="tok-kw">else</span> =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.InvalidDebugInfo,</span>
<span class="line" id="L697">                                    };</span>
<span class="line" id="L698">                                    <span class="tok-kw">break</span> :x PcRange{</span>
<span class="line" id="L699">                                        .start = low_pc,</span>
<span class="line" id="L700">                                        .end = pc_end,</span>
<span class="line" id="L701">                                    };</span>
<span class="line" id="L702">                                } <span class="tok-kw">else</span> {</span>
<span class="line" id="L703">                                    <span class="tok-kw">break</span> :x <span class="tok-null">null</span>;</span>
<span class="line" id="L704">                                }</span>
<span class="line" id="L705">                            } <span class="tok-kw">else</span> |err| {</span>
<span class="line" id="L706">                                <span class="tok-kw">if</span> (err != <span class="tok-kw">error</span>.MissingDebugInfo) <span class="tok-kw">return</span> err;</span>
<span class="line" id="L707">                                <span class="tok-kw">break</span> :x <span class="tok-null">null</span>;</span>
<span class="line" id="L708">                            }</span>
<span class="line" id="L709">                        };</span>
<span class="line" id="L710"></span>
<span class="line" id="L711">                        <span class="tok-kw">try</span> di.func_list.append(allocator, Func{</span>
<span class="line" id="L712">                            .name = fn_name,</span>
<span class="line" id="L713">                            .pc_range = pc_range,</span>
<span class="line" id="L714">                        });</span>
<span class="line" id="L715">                    },</span>
<span class="line" id="L716">                    <span class="tok-kw">else</span> =&gt; {},</span>
<span class="line" id="L717">                }</span>
<span class="line" id="L718"></span>
<span class="line" id="L719">                <span class="tok-kw">try</span> seekable.seekTo(after_die_offset);</span>
<span class="line" id="L720">            }</span>
<span class="line" id="L721"></span>
<span class="line" id="L722">            this_unit_offset += next_offset;</span>
<span class="line" id="L723">        }</span>
<span class="line" id="L724">    }</span>
<span class="line" id="L725"></span>
<span class="line" id="L726">    <span class="tok-kw">fn</span> <span class="tok-fn">scanAllCompileUnits</span>(di: *DwarfInfo, allocator: mem.Allocator) !<span class="tok-type">void</span> {</span>
<span class="line" id="L727">        <span class="tok-kw">var</span> stream = io.fixedBufferStream(di.debug_info);</span>
<span class="line" id="L728">        <span class="tok-kw">const</span> in = &amp;stream.reader();</span>
<span class="line" id="L729">        <span class="tok-kw">const</span> seekable = &amp;stream.seekableStream();</span>
<span class="line" id="L730">        <span class="tok-kw">var</span> this_unit_offset: <span class="tok-type">u64</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L731"></span>
<span class="line" id="L732">        <span class="tok-kw">while</span> (this_unit_offset &lt; <span class="tok-kw">try</span> seekable.getEndPos()) {</span>
<span class="line" id="L733">            <span class="tok-kw">try</span> seekable.seekTo(this_unit_offset);</span>
<span class="line" id="L734"></span>
<span class="line" id="L735">            <span class="tok-kw">var</span> is_64: <span class="tok-type">bool</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L736">            <span class="tok-kw">const</span> unit_length = <span class="tok-kw">try</span> readUnitLength(in, di.endian, &amp;is_64);</span>
<span class="line" id="L737">            <span class="tok-kw">if</span> (unit_length == <span class="tok-number">0</span>) <span class="tok-kw">return</span>;</span>
<span class="line" id="L738">            <span class="tok-kw">const</span> next_offset = unit_length + (<span class="tok-kw">if</span> (is_64) <span class="tok-builtin">@as</span>(<span class="tok-type">usize</span>, <span class="tok-number">12</span>) <span class="tok-kw">else</span> <span class="tok-builtin">@as</span>(<span class="tok-type">usize</span>, <span class="tok-number">4</span>));</span>
<span class="line" id="L739"></span>
<span class="line" id="L740">            <span class="tok-kw">const</span> version = <span class="tok-kw">try</span> in.readInt(<span class="tok-type">u16</span>, di.endian);</span>
<span class="line" id="L741">            <span class="tok-kw">if</span> (version &lt; <span class="tok-number">2</span> <span class="tok-kw">or</span> version &gt; <span class="tok-number">5</span>) <span class="tok-kw">return</span> <span class="tok-kw">error</span>.InvalidDebugInfo;</span>
<span class="line" id="L742"></span>
<span class="line" id="L743">            <span class="tok-kw">var</span> address_size: <span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L744">            <span class="tok-kw">var</span> debug_abbrev_offset: <span class="tok-type">u64</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L745">            <span class="tok-kw">switch</span> (version) {</span>
<span class="line" id="L746">                <span class="tok-number">5</span> =&gt; {</span>
<span class="line" id="L747">                    <span class="tok-kw">const</span> unit_type = <span class="tok-kw">try</span> in.readInt(<span class="tok-type">u8</span>, di.endian);</span>
<span class="line" id="L748">                    <span class="tok-kw">if</span> (unit_type != UT.compile) <span class="tok-kw">return</span> <span class="tok-kw">error</span>.InvalidDebugInfo;</span>
<span class="line" id="L749">                    address_size = <span class="tok-kw">try</span> in.readByte();</span>
<span class="line" id="L750">                    debug_abbrev_offset = <span class="tok-kw">if</span> (is_64)</span>
<span class="line" id="L751">                        <span class="tok-kw">try</span> in.readInt(<span class="tok-type">u64</span>, di.endian)</span>
<span class="line" id="L752">                    <span class="tok-kw">else</span></span>
<span class="line" id="L753">                        <span class="tok-kw">try</span> in.readInt(<span class="tok-type">u32</span>, di.endian);</span>
<span class="line" id="L754">                },</span>
<span class="line" id="L755">                <span class="tok-kw">else</span> =&gt; {</span>
<span class="line" id="L756">                    debug_abbrev_offset = <span class="tok-kw">if</span> (is_64)</span>
<span class="line" id="L757">                        <span class="tok-kw">try</span> in.readInt(<span class="tok-type">u64</span>, di.endian)</span>
<span class="line" id="L758">                    <span class="tok-kw">else</span></span>
<span class="line" id="L759">                        <span class="tok-kw">try</span> in.readInt(<span class="tok-type">u32</span>, di.endian);</span>
<span class="line" id="L760">                    address_size = <span class="tok-kw">try</span> in.readByte();</span>
<span class="line" id="L761">                },</span>
<span class="line" id="L762">            }</span>
<span class="line" id="L763">            <span class="tok-kw">if</span> (address_size != <span class="tok-builtin">@sizeOf</span>(<span class="tok-type">usize</span>)) <span class="tok-kw">return</span> <span class="tok-kw">error</span>.InvalidDebugInfo;</span>
<span class="line" id="L764"></span>
<span class="line" id="L765">            <span class="tok-kw">const</span> compile_unit_pos = <span class="tok-kw">try</span> seekable.getPos();</span>
<span class="line" id="L766">            <span class="tok-kw">const</span> abbrev_table = <span class="tok-kw">try</span> di.getAbbrevTable(allocator, debug_abbrev_offset);</span>
<span class="line" id="L767"></span>
<span class="line" id="L768">            <span class="tok-kw">try</span> seekable.seekTo(compile_unit_pos);</span>
<span class="line" id="L769"></span>
<span class="line" id="L770">            <span class="tok-kw">const</span> compile_unit_die = <span class="tok-kw">try</span> allocator.create(Die);</span>
<span class="line" id="L771">            <span class="tok-kw">errdefer</span> allocator.destroy(compile_unit_die);</span>
<span class="line" id="L772">            compile_unit_die.* = (<span class="tok-kw">try</span> di.parseDie(allocator, in, abbrev_table, is_64)) <span class="tok-kw">orelse</span></span>
<span class="line" id="L773">                <span class="tok-kw">return</span> <span class="tok-kw">error</span>.InvalidDebugInfo;</span>
<span class="line" id="L774"></span>
<span class="line" id="L775">            <span class="tok-kw">if</span> (compile_unit_die.tag_id != TAG.compile_unit) <span class="tok-kw">return</span> <span class="tok-kw">error</span>.InvalidDebugInfo;</span>
<span class="line" id="L776"></span>
<span class="line" id="L777">            <span class="tok-kw">const</span> pc_range = x: {</span>
<span class="line" id="L778">                <span class="tok-kw">if</span> (compile_unit_die.getAttrAddr(AT.low_pc)) |low_pc| {</span>
<span class="line" id="L779">                    <span class="tok-kw">if</span> (compile_unit_die.getAttr(AT.high_pc)) |high_pc_value| {</span>
<span class="line" id="L780">                        <span class="tok-kw">const</span> pc_end = <span class="tok-kw">switch</span> (high_pc_value.*) {</span>
<span class="line" id="L781">                            FormValue.Address =&gt; |value| value,</span>
<span class="line" id="L782">                            FormValue.Const =&gt; |value| b: {</span>
<span class="line" id="L783">                                <span class="tok-kw">const</span> offset = <span class="tok-kw">try</span> value.asUnsignedLe();</span>
<span class="line" id="L784">                                <span class="tok-kw">break</span> :b (low_pc + offset);</span>
<span class="line" id="L785">                            },</span>
<span class="line" id="L786">                            <span class="tok-kw">else</span> =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.InvalidDebugInfo,</span>
<span class="line" id="L787">                        };</span>
<span class="line" id="L788">                        <span class="tok-kw">break</span> :x PcRange{</span>
<span class="line" id="L789">                            .start = low_pc,</span>
<span class="line" id="L790">                            .end = pc_end,</span>
<span class="line" id="L791">                        };</span>
<span class="line" id="L792">                    } <span class="tok-kw">else</span> {</span>
<span class="line" id="L793">                        <span class="tok-kw">break</span> :x <span class="tok-null">null</span>;</span>
<span class="line" id="L794">                    }</span>
<span class="line" id="L795">                } <span class="tok-kw">else</span> |err| {</span>
<span class="line" id="L796">                    <span class="tok-kw">if</span> (err != <span class="tok-kw">error</span>.MissingDebugInfo) <span class="tok-kw">return</span> err;</span>
<span class="line" id="L797">                    <span class="tok-kw">break</span> :x <span class="tok-null">null</span>;</span>
<span class="line" id="L798">                }</span>
<span class="line" id="L799">            };</span>
<span class="line" id="L800"></span>
<span class="line" id="L801">            <span class="tok-kw">try</span> di.compile_unit_list.append(allocator, CompileUnit{</span>
<span class="line" id="L802">                .version = version,</span>
<span class="line" id="L803">                .is_64 = is_64,</span>
<span class="line" id="L804">                .pc_range = pc_range,</span>
<span class="line" id="L805">                .die = compile_unit_die,</span>
<span class="line" id="L806">            });</span>
<span class="line" id="L807"></span>
<span class="line" id="L808">            this_unit_offset += next_offset;</span>
<span class="line" id="L809">        }</span>
<span class="line" id="L810">    }</span>
<span class="line" id="L811"></span>
<span class="line" id="L812">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">findCompileUnit</span>(di: *DwarfInfo, target_address: <span class="tok-type">u64</span>) !*<span class="tok-kw">const</span> CompileUnit {</span>
<span class="line" id="L813">        <span class="tok-kw">for</span> (di.compile_unit_list.items) |*compile_unit| {</span>
<span class="line" id="L814">            <span class="tok-kw">if</span> (compile_unit.pc_range) |range| {</span>
<span class="line" id="L815">                <span class="tok-kw">if</span> (target_address &gt;= range.start <span class="tok-kw">and</span> target_address &lt; range.end) <span class="tok-kw">return</span> compile_unit;</span>
<span class="line" id="L816">            }</span>
<span class="line" id="L817">            <span class="tok-kw">if</span> (di.debug_ranges) |debug_ranges| {</span>
<span class="line" id="L818">                <span class="tok-kw">if</span> (compile_unit.die.getAttrSecOffset(AT.ranges)) |ranges_offset| {</span>
<span class="line" id="L819">                    <span class="tok-kw">var</span> stream = io.fixedBufferStream(debug_ranges);</span>
<span class="line" id="L820">                    <span class="tok-kw">const</span> in = &amp;stream.reader();</span>
<span class="line" id="L821">                    <span class="tok-kw">const</span> seekable = &amp;stream.seekableStream();</span>
<span class="line" id="L822"></span>
<span class="line" id="L823">                    <span class="tok-comment">// All the addresses in the list are relative to the value</span>
</span>
<span class="line" id="L824">                    <span class="tok-comment">// specified by DW_AT.low_pc or to some other value encoded</span>
</span>
<span class="line" id="L825">                    <span class="tok-comment">// in the list itself.</span>
</span>
<span class="line" id="L826">                    <span class="tok-comment">// If no starting value is specified use zero.</span>
</span>
<span class="line" id="L827">                    <span class="tok-kw">var</span> base_address = compile_unit.die.getAttrAddr(AT.low_pc) <span class="tok-kw">catch</span> |err| <span class="tok-kw">switch</span> (err) {</span>
<span class="line" id="L828">                        <span class="tok-kw">error</span>.MissingDebugInfo =&gt; <span class="tok-builtin">@as</span>(<span class="tok-type">u64</span>, <span class="tok-number">0</span>), <span class="tok-comment">// TODO https://github.com/ziglang/zig/issues/11135</span>
</span>
<span class="line" id="L829">                        <span class="tok-kw">else</span> =&gt; <span class="tok-kw">return</span> err,</span>
<span class="line" id="L830">                    };</span>
<span class="line" id="L831"></span>
<span class="line" id="L832">                    <span class="tok-kw">try</span> seekable.seekTo(ranges_offset);</span>
<span class="line" id="L833"></span>
<span class="line" id="L834">                    <span class="tok-kw">while</span> (<span class="tok-null">true</span>) {</span>
<span class="line" id="L835">                        <span class="tok-kw">const</span> begin_addr = <span class="tok-kw">try</span> in.readInt(<span class="tok-type">usize</span>, di.endian);</span>
<span class="line" id="L836">                        <span class="tok-kw">const</span> end_addr = <span class="tok-kw">try</span> in.readInt(<span class="tok-type">usize</span>, di.endian);</span>
<span class="line" id="L837">                        <span class="tok-kw">if</span> (begin_addr == <span class="tok-number">0</span> <span class="tok-kw">and</span> end_addr == <span class="tok-number">0</span>) {</span>
<span class="line" id="L838">                            <span class="tok-kw">break</span>;</span>
<span class="line" id="L839">                        }</span>
<span class="line" id="L840">                        <span class="tok-comment">// This entry selects a new value for the base address</span>
</span>
<span class="line" id="L841">                        <span class="tok-kw">if</span> (begin_addr == math.maxInt(<span class="tok-type">usize</span>)) {</span>
<span class="line" id="L842">                            base_address = end_addr;</span>
<span class="line" id="L843">                            <span class="tok-kw">continue</span>;</span>
<span class="line" id="L844">                        }</span>
<span class="line" id="L845">                        <span class="tok-kw">if</span> (target_address &gt;= base_address + begin_addr <span class="tok-kw">and</span> target_address &lt; base_address + end_addr) {</span>
<span class="line" id="L846">                            <span class="tok-kw">return</span> compile_unit;</span>
<span class="line" id="L847">                        }</span>
<span class="line" id="L848">                    }</span>
<span class="line" id="L849">                } <span class="tok-kw">else</span> |err| {</span>
<span class="line" id="L850">                    <span class="tok-kw">if</span> (err != <span class="tok-kw">error</span>.MissingDebugInfo) <span class="tok-kw">return</span> err;</span>
<span class="line" id="L851">                    <span class="tok-kw">continue</span>;</span>
<span class="line" id="L852">                }</span>
<span class="line" id="L853">            }</span>
<span class="line" id="L854">        }</span>
<span class="line" id="L855">        <span class="tok-kw">return</span> <span class="tok-kw">error</span>.MissingDebugInfo;</span>
<span class="line" id="L856">    }</span>
<span class="line" id="L857"></span>
<span class="line" id="L858">    <span class="tok-comment">/// Gets an already existing AbbrevTable given the abbrev_offset, or if not found,</span></span>
<span class="line" id="L859">    <span class="tok-comment">/// seeks in the stream and parses it.</span></span>
<span class="line" id="L860">    <span class="tok-kw">fn</span> <span class="tok-fn">getAbbrevTable</span>(di: *DwarfInfo, allocator: mem.Allocator, abbrev_offset: <span class="tok-type">u64</span>) !*<span class="tok-kw">const</span> AbbrevTable {</span>
<span class="line" id="L861">        <span class="tok-kw">for</span> (di.abbrev_table_list.items) |*header| {</span>
<span class="line" id="L862">            <span class="tok-kw">if</span> (header.offset == abbrev_offset) {</span>
<span class="line" id="L863">                <span class="tok-kw">return</span> &amp;header.table;</span>
<span class="line" id="L864">            }</span>
<span class="line" id="L865">        }</span>
<span class="line" id="L866">        <span class="tok-kw">try</span> di.abbrev_table_list.append(allocator, AbbrevTableHeader{</span>
<span class="line" id="L867">            .offset = abbrev_offset,</span>
<span class="line" id="L868">            .table = <span class="tok-kw">try</span> di.parseAbbrevTable(allocator, abbrev_offset),</span>
<span class="line" id="L869">        });</span>
<span class="line" id="L870">        <span class="tok-kw">return</span> &amp;di.abbrev_table_list.items[di.abbrev_table_list.items.len - <span class="tok-number">1</span>].table;</span>
<span class="line" id="L871">    }</span>
<span class="line" id="L872"></span>
<span class="line" id="L873">    <span class="tok-kw">fn</span> <span class="tok-fn">parseAbbrevTable</span>(di: *DwarfInfo, allocator: mem.Allocator, offset: <span class="tok-type">u64</span>) !AbbrevTable {</span>
<span class="line" id="L874">        <span class="tok-kw">var</span> stream = io.fixedBufferStream(di.debug_abbrev);</span>
<span class="line" id="L875">        <span class="tok-kw">const</span> in = &amp;stream.reader();</span>
<span class="line" id="L876">        <span class="tok-kw">const</span> seekable = &amp;stream.seekableStream();</span>
<span class="line" id="L877"></span>
<span class="line" id="L878">        <span class="tok-kw">try</span> seekable.seekTo(offset);</span>
<span class="line" id="L879">        <span class="tok-kw">var</span> result = AbbrevTable.init(allocator);</span>
<span class="line" id="L880">        <span class="tok-kw">errdefer</span> {</span>
<span class="line" id="L881">            <span class="tok-kw">for</span> (result.items) |*entry| {</span>
<span class="line" id="L882">                entry.attrs.deinit();</span>
<span class="line" id="L883">            }</span>
<span class="line" id="L884">            result.deinit();</span>
<span class="line" id="L885">        }</span>
<span class="line" id="L886"></span>
<span class="line" id="L887">        <span class="tok-kw">while</span> (<span class="tok-null">true</span>) {</span>
<span class="line" id="L888">            <span class="tok-kw">const</span> abbrev_code = <span class="tok-kw">try</span> leb.readULEB128(<span class="tok-type">u64</span>, in);</span>
<span class="line" id="L889">            <span class="tok-kw">if</span> (abbrev_code == <span class="tok-number">0</span>) <span class="tok-kw">return</span> result;</span>
<span class="line" id="L890">            <span class="tok-kw">try</span> result.append(AbbrevTableEntry{</span>
<span class="line" id="L891">                .abbrev_code = abbrev_code,</span>
<span class="line" id="L892">                .tag_id = <span class="tok-kw">try</span> leb.readULEB128(<span class="tok-type">u64</span>, in),</span>
<span class="line" id="L893">                .has_children = (<span class="tok-kw">try</span> in.readByte()) == CHILDREN.yes,</span>
<span class="line" id="L894">                .attrs = std.ArrayList(AbbrevAttr).init(allocator),</span>
<span class="line" id="L895">            });</span>
<span class="line" id="L896">            <span class="tok-kw">const</span> attrs = &amp;result.items[result.items.len - <span class="tok-number">1</span>].attrs;</span>
<span class="line" id="L897"></span>
<span class="line" id="L898">            <span class="tok-kw">while</span> (<span class="tok-null">true</span>) {</span>
<span class="line" id="L899">                <span class="tok-kw">const</span> attr_id = <span class="tok-kw">try</span> leb.readULEB128(<span class="tok-type">u64</span>, in);</span>
<span class="line" id="L900">                <span class="tok-kw">const</span> form_id = <span class="tok-kw">try</span> leb.readULEB128(<span class="tok-type">u64</span>, in);</span>
<span class="line" id="L901">                <span class="tok-kw">if</span> (attr_id == <span class="tok-number">0</span> <span class="tok-kw">and</span> form_id == <span class="tok-number">0</span>) <span class="tok-kw">break</span>;</span>
<span class="line" id="L902">                <span class="tok-comment">// DW_FORM_implicit_const stores its value immediately after the attribute pair :(</span>
</span>
<span class="line" id="L903">                <span class="tok-kw">const</span> payload = <span class="tok-kw">if</span> (form_id == FORM.implicit_const) <span class="tok-kw">try</span> leb.readILEB128(<span class="tok-type">i64</span>, in) <span class="tok-kw">else</span> <span class="tok-null">undefined</span>;</span>
<span class="line" id="L904">                <span class="tok-kw">try</span> attrs.append(AbbrevAttr{</span>
<span class="line" id="L905">                    .attr_id = attr_id,</span>
<span class="line" id="L906">                    .form_id = form_id,</span>
<span class="line" id="L907">                    .payload = payload,</span>
<span class="line" id="L908">                });</span>
<span class="line" id="L909">            }</span>
<span class="line" id="L910">        }</span>
<span class="line" id="L911">    }</span>
<span class="line" id="L912"></span>
<span class="line" id="L913">    <span class="tok-kw">fn</span> <span class="tok-fn">parseDie</span>(</span>
<span class="line" id="L914">        di: *DwarfInfo,</span>
<span class="line" id="L915">        allocator: mem.Allocator,</span>
<span class="line" id="L916">        in_stream: <span class="tok-kw">anytype</span>,</span>
<span class="line" id="L917">        abbrev_table: *<span class="tok-kw">const</span> AbbrevTable,</span>
<span class="line" id="L918">        is_64: <span class="tok-type">bool</span>,</span>
<span class="line" id="L919">    ) !?Die {</span>
<span class="line" id="L920">        <span class="tok-kw">const</span> abbrev_code = <span class="tok-kw">try</span> leb.readULEB128(<span class="tok-type">u64</span>, in_stream);</span>
<span class="line" id="L921">        <span class="tok-kw">if</span> (abbrev_code == <span class="tok-number">0</span>) <span class="tok-kw">return</span> <span class="tok-null">null</span>;</span>
<span class="line" id="L922">        <span class="tok-kw">const</span> table_entry = getAbbrevTableEntry(abbrev_table, abbrev_code) <span class="tok-kw">orelse</span> <span class="tok-kw">return</span> <span class="tok-kw">error</span>.InvalidDebugInfo;</span>
<span class="line" id="L923"></span>
<span class="line" id="L924">        <span class="tok-kw">var</span> result = Die{</span>
<span class="line" id="L925">            <span class="tok-comment">// Lives as long as the Die.</span>
</span>
<span class="line" id="L926">            .arena = std.heap.ArenaAllocator.init(allocator),</span>
<span class="line" id="L927">            .tag_id = table_entry.tag_id,</span>
<span class="line" id="L928">            .has_children = table_entry.has_children,</span>
<span class="line" id="L929">        };</span>
<span class="line" id="L930">        <span class="tok-kw">try</span> result.attrs.resize(allocator, table_entry.attrs.items.len);</span>
<span class="line" id="L931">        <span class="tok-kw">for</span> (table_entry.attrs.items) |attr, i| {</span>
<span class="line" id="L932">            result.attrs.items[i] = Die.Attr{</span>
<span class="line" id="L933">                .id = attr.attr_id,</span>
<span class="line" id="L934">                .value = <span class="tok-kw">try</span> parseFormValue(</span>
<span class="line" id="L935">                    result.arena.allocator(),</span>
<span class="line" id="L936">                    in_stream,</span>
<span class="line" id="L937">                    attr.form_id,</span>
<span class="line" id="L938">                    di.endian,</span>
<span class="line" id="L939">                    is_64,</span>
<span class="line" id="L940">                ),</span>
<span class="line" id="L941">            };</span>
<span class="line" id="L942">            <span class="tok-kw">if</span> (attr.form_id == FORM.implicit_const) {</span>
<span class="line" id="L943">                result.attrs.items[i].value.Const.payload = <span class="tok-builtin">@bitCast</span>(<span class="tok-type">u64</span>, attr.payload);</span>
<span class="line" id="L944">            }</span>
<span class="line" id="L945">        }</span>
<span class="line" id="L946">        <span class="tok-kw">return</span> result;</span>
<span class="line" id="L947">    }</span>
<span class="line" id="L948"></span>
<span class="line" id="L949">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">getLineNumberInfo</span>(</span>
<span class="line" id="L950">        di: *DwarfInfo,</span>
<span class="line" id="L951">        allocator: mem.Allocator,</span>
<span class="line" id="L952">        compile_unit: CompileUnit,</span>
<span class="line" id="L953">        target_address: <span class="tok-type">u64</span>,</span>
<span class="line" id="L954">    ) !debug.LineInfo {</span>
<span class="line" id="L955">        <span class="tok-kw">var</span> stream = io.fixedBufferStream(di.debug_line);</span>
<span class="line" id="L956">        <span class="tok-kw">const</span> in = &amp;stream.reader();</span>
<span class="line" id="L957">        <span class="tok-kw">const</span> seekable = &amp;stream.seekableStream();</span>
<span class="line" id="L958"></span>
<span class="line" id="L959">        <span class="tok-kw">const</span> compile_unit_cwd = <span class="tok-kw">try</span> compile_unit.die.getAttrString(di, AT.comp_dir);</span>
<span class="line" id="L960">        <span class="tok-kw">const</span> line_info_offset = <span class="tok-kw">try</span> compile_unit.die.getAttrSecOffset(AT.stmt_list);</span>
<span class="line" id="L961"></span>
<span class="line" id="L962">        <span class="tok-kw">try</span> seekable.seekTo(line_info_offset);</span>
<span class="line" id="L963"></span>
<span class="line" id="L964">        <span class="tok-kw">var</span> is_64: <span class="tok-type">bool</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L965">        <span class="tok-kw">const</span> unit_length = <span class="tok-kw">try</span> readUnitLength(in, di.endian, &amp;is_64);</span>
<span class="line" id="L966">        <span class="tok-kw">if</span> (unit_length == <span class="tok-number">0</span>) {</span>
<span class="line" id="L967">            <span class="tok-kw">return</span> <span class="tok-kw">error</span>.MissingDebugInfo;</span>
<span class="line" id="L968">        }</span>
<span class="line" id="L969">        <span class="tok-kw">const</span> next_offset = unit_length + (<span class="tok-kw">if</span> (is_64) <span class="tok-builtin">@as</span>(<span class="tok-type">usize</span>, <span class="tok-number">12</span>) <span class="tok-kw">else</span> <span class="tok-builtin">@as</span>(<span class="tok-type">usize</span>, <span class="tok-number">4</span>));</span>
<span class="line" id="L970"></span>
<span class="line" id="L971">        <span class="tok-kw">const</span> version = <span class="tok-kw">try</span> in.readInt(<span class="tok-type">u16</span>, di.endian);</span>
<span class="line" id="L972">        <span class="tok-kw">if</span> (version &lt; <span class="tok-number">2</span> <span class="tok-kw">or</span> version &gt; <span class="tok-number">4</span>) <span class="tok-kw">return</span> <span class="tok-kw">error</span>.InvalidDebugInfo;</span>
<span class="line" id="L973"></span>
<span class="line" id="L974">        <span class="tok-kw">const</span> prologue_length = <span class="tok-kw">if</span> (is_64) <span class="tok-kw">try</span> in.readInt(<span class="tok-type">u64</span>, di.endian) <span class="tok-kw">else</span> <span class="tok-kw">try</span> in.readInt(<span class="tok-type">u32</span>, di.endian);</span>
<span class="line" id="L975">        <span class="tok-kw">const</span> prog_start_offset = (<span class="tok-kw">try</span> seekable.getPos()) + prologue_length;</span>
<span class="line" id="L976"></span>
<span class="line" id="L977">        <span class="tok-kw">const</span> minimum_instruction_length = <span class="tok-kw">try</span> in.readByte();</span>
<span class="line" id="L978">        <span class="tok-kw">if</span> (minimum_instruction_length == <span class="tok-number">0</span>) <span class="tok-kw">return</span> <span class="tok-kw">error</span>.InvalidDebugInfo;</span>
<span class="line" id="L979"></span>
<span class="line" id="L980">        <span class="tok-kw">if</span> (version &gt;= <span class="tok-number">4</span>) {</span>
<span class="line" id="L981">            <span class="tok-comment">// maximum_operations_per_instruction</span>
</span>
<span class="line" id="L982">            _ = <span class="tok-kw">try</span> in.readByte();</span>
<span class="line" id="L983">        }</span>
<span class="line" id="L984"></span>
<span class="line" id="L985">        <span class="tok-kw">const</span> default_is_stmt = (<span class="tok-kw">try</span> in.readByte()) != <span class="tok-number">0</span>;</span>
<span class="line" id="L986">        <span class="tok-kw">const</span> line_base = <span class="tok-kw">try</span> in.readByteSigned();</span>
<span class="line" id="L987"></span>
<span class="line" id="L988">        <span class="tok-kw">const</span> line_range = <span class="tok-kw">try</span> in.readByte();</span>
<span class="line" id="L989">        <span class="tok-kw">if</span> (line_range == <span class="tok-number">0</span>) <span class="tok-kw">return</span> <span class="tok-kw">error</span>.InvalidDebugInfo;</span>
<span class="line" id="L990"></span>
<span class="line" id="L991">        <span class="tok-kw">const</span> opcode_base = <span class="tok-kw">try</span> in.readByte();</span>
<span class="line" id="L992"></span>
<span class="line" id="L993">        <span class="tok-kw">const</span> standard_opcode_lengths = <span class="tok-kw">try</span> allocator.alloc(<span class="tok-type">u8</span>, opcode_base - <span class="tok-number">1</span>);</span>
<span class="line" id="L994">        <span class="tok-kw">defer</span> allocator.free(standard_opcode_lengths);</span>
<span class="line" id="L995"></span>
<span class="line" id="L996">        {</span>
<span class="line" id="L997">            <span class="tok-kw">var</span> i: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L998">            <span class="tok-kw">while</span> (i &lt; opcode_base - <span class="tok-number">1</span>) : (i += <span class="tok-number">1</span>) {</span>
<span class="line" id="L999">                standard_opcode_lengths[i] = <span class="tok-kw">try</span> in.readByte();</span>
<span class="line" id="L1000">            }</span>
<span class="line" id="L1001">        }</span>
<span class="line" id="L1002"></span>
<span class="line" id="L1003">        <span class="tok-kw">var</span> tmp_arena = std.heap.ArenaAllocator.init(allocator);</span>
<span class="line" id="L1004">        <span class="tok-kw">defer</span> tmp_arena.deinit();</span>
<span class="line" id="L1005">        <span class="tok-kw">const</span> arena = tmp_arena.allocator();</span>
<span class="line" id="L1006"></span>
<span class="line" id="L1007">        <span class="tok-kw">var</span> include_directories = std.ArrayList([]<span class="tok-kw">const</span> <span class="tok-type">u8</span>).init(arena);</span>
<span class="line" id="L1008">        <span class="tok-kw">try</span> include_directories.append(compile_unit_cwd);</span>
<span class="line" id="L1009"></span>
<span class="line" id="L1010">        <span class="tok-kw">while</span> (<span class="tok-null">true</span>) {</span>
<span class="line" id="L1011">            <span class="tok-kw">const</span> dir = <span class="tok-kw">try</span> in.readUntilDelimiterAlloc(arena, <span class="tok-number">0</span>, math.maxInt(<span class="tok-type">usize</span>));</span>
<span class="line" id="L1012">            <span class="tok-kw">if</span> (dir.len == <span class="tok-number">0</span>) <span class="tok-kw">break</span>;</span>
<span class="line" id="L1013">            <span class="tok-kw">try</span> include_directories.append(dir);</span>
<span class="line" id="L1014">        }</span>
<span class="line" id="L1015"></span>
<span class="line" id="L1016">        <span class="tok-kw">var</span> file_entries = std.ArrayList(FileEntry).init(arena);</span>
<span class="line" id="L1017">        <span class="tok-kw">var</span> prog = LineNumberProgram.init(</span>
<span class="line" id="L1018">            default_is_stmt,</span>
<span class="line" id="L1019">            include_directories.items,</span>
<span class="line" id="L1020">            target_address,</span>
<span class="line" id="L1021">        );</span>
<span class="line" id="L1022"></span>
<span class="line" id="L1023">        <span class="tok-kw">while</span> (<span class="tok-null">true</span>) {</span>
<span class="line" id="L1024">            <span class="tok-kw">const</span> file_name = <span class="tok-kw">try</span> in.readUntilDelimiterAlloc(arena, <span class="tok-number">0</span>, math.maxInt(<span class="tok-type">usize</span>));</span>
<span class="line" id="L1025">            <span class="tok-kw">if</span> (file_name.len == <span class="tok-number">0</span>) <span class="tok-kw">break</span>;</span>
<span class="line" id="L1026">            <span class="tok-kw">const</span> dir_index = <span class="tok-kw">try</span> leb.readULEB128(<span class="tok-type">usize</span>, in);</span>
<span class="line" id="L1027">            <span class="tok-kw">const</span> mtime = <span class="tok-kw">try</span> leb.readULEB128(<span class="tok-type">usize</span>, in);</span>
<span class="line" id="L1028">            <span class="tok-kw">const</span> len_bytes = <span class="tok-kw">try</span> leb.readULEB128(<span class="tok-type">usize</span>, in);</span>
<span class="line" id="L1029">            <span class="tok-kw">try</span> file_entries.append(FileEntry{</span>
<span class="line" id="L1030">                .file_name = file_name,</span>
<span class="line" id="L1031">                .dir_index = dir_index,</span>
<span class="line" id="L1032">                .mtime = mtime,</span>
<span class="line" id="L1033">                .len_bytes = len_bytes,</span>
<span class="line" id="L1034">            });</span>
<span class="line" id="L1035">        }</span>
<span class="line" id="L1036"></span>
<span class="line" id="L1037">        <span class="tok-kw">try</span> seekable.seekTo(prog_start_offset);</span>
<span class="line" id="L1038"></span>
<span class="line" id="L1039">        <span class="tok-kw">const</span> next_unit_pos = line_info_offset + next_offset;</span>
<span class="line" id="L1040"></span>
<span class="line" id="L1041">        <span class="tok-kw">while</span> ((<span class="tok-kw">try</span> seekable.getPos()) &lt; next_unit_pos) {</span>
<span class="line" id="L1042">            <span class="tok-kw">const</span> opcode = <span class="tok-kw">try</span> in.readByte();</span>
<span class="line" id="L1043"></span>
<span class="line" id="L1044">            <span class="tok-kw">if</span> (opcode == LNS.extended_op) {</span>
<span class="line" id="L1045">                <span class="tok-kw">const</span> op_size = <span class="tok-kw">try</span> leb.readULEB128(<span class="tok-type">u64</span>, in);</span>
<span class="line" id="L1046">                <span class="tok-kw">if</span> (op_size &lt; <span class="tok-number">1</span>) <span class="tok-kw">return</span> <span class="tok-kw">error</span>.InvalidDebugInfo;</span>
<span class="line" id="L1047">                <span class="tok-kw">var</span> sub_op = <span class="tok-kw">try</span> in.readByte();</span>
<span class="line" id="L1048">                <span class="tok-kw">switch</span> (sub_op) {</span>
<span class="line" id="L1049">                    LNE.end_sequence =&gt; {</span>
<span class="line" id="L1050">                        prog.end_sequence = <span class="tok-null">true</span>;</span>
<span class="line" id="L1051">                        <span class="tok-kw">if</span> (<span class="tok-kw">try</span> prog.checkLineMatch(allocator, file_entries.items)) |info| <span class="tok-kw">return</span> info;</span>
<span class="line" id="L1052">                        prog.reset();</span>
<span class="line" id="L1053">                    },</span>
<span class="line" id="L1054">                    LNE.set_address =&gt; {</span>
<span class="line" id="L1055">                        <span class="tok-kw">const</span> addr = <span class="tok-kw">try</span> in.readInt(<span class="tok-type">usize</span>, di.endian);</span>
<span class="line" id="L1056">                        prog.address = addr;</span>
<span class="line" id="L1057">                    },</span>
<span class="line" id="L1058">                    LNE.define_file =&gt; {</span>
<span class="line" id="L1059">                        <span class="tok-kw">const</span> file_name = <span class="tok-kw">try</span> in.readUntilDelimiterAlloc(arena, <span class="tok-number">0</span>, math.maxInt(<span class="tok-type">usize</span>));</span>
<span class="line" id="L1060">                        <span class="tok-kw">const</span> dir_index = <span class="tok-kw">try</span> leb.readULEB128(<span class="tok-type">usize</span>, in);</span>
<span class="line" id="L1061">                        <span class="tok-kw">const</span> mtime = <span class="tok-kw">try</span> leb.readULEB128(<span class="tok-type">usize</span>, in);</span>
<span class="line" id="L1062">                        <span class="tok-kw">const</span> len_bytes = <span class="tok-kw">try</span> leb.readULEB128(<span class="tok-type">usize</span>, in);</span>
<span class="line" id="L1063">                        <span class="tok-kw">try</span> file_entries.append(FileEntry{</span>
<span class="line" id="L1064">                            .file_name = file_name,</span>
<span class="line" id="L1065">                            .dir_index = dir_index,</span>
<span class="line" id="L1066">                            .mtime = mtime,</span>
<span class="line" id="L1067">                            .len_bytes = len_bytes,</span>
<span class="line" id="L1068">                        });</span>
<span class="line" id="L1069">                    },</span>
<span class="line" id="L1070">                    <span class="tok-kw">else</span> =&gt; {</span>
<span class="line" id="L1071">                        <span class="tok-kw">const</span> fwd_amt = math.cast(<span class="tok-type">isize</span>, op_size - <span class="tok-number">1</span>) <span class="tok-kw">orelse</span> <span class="tok-kw">return</span> <span class="tok-kw">error</span>.InvalidDebugInfo;</span>
<span class="line" id="L1072">                        <span class="tok-kw">try</span> seekable.seekBy(fwd_amt);</span>
<span class="line" id="L1073">                    },</span>
<span class="line" id="L1074">                }</span>
<span class="line" id="L1075">            } <span class="tok-kw">else</span> <span class="tok-kw">if</span> (opcode &gt;= opcode_base) {</span>
<span class="line" id="L1076">                <span class="tok-comment">// special opcodes</span>
</span>
<span class="line" id="L1077">                <span class="tok-kw">const</span> adjusted_opcode = opcode - opcode_base;</span>
<span class="line" id="L1078">                <span class="tok-kw">const</span> inc_addr = minimum_instruction_length * (adjusted_opcode / line_range);</span>
<span class="line" id="L1079">                <span class="tok-kw">const</span> inc_line = <span class="tok-builtin">@as</span>(<span class="tok-type">i32</span>, line_base) + <span class="tok-builtin">@as</span>(<span class="tok-type">i32</span>, adjusted_opcode % line_range);</span>
<span class="line" id="L1080">                prog.line += inc_line;</span>
<span class="line" id="L1081">                prog.address += inc_addr;</span>
<span class="line" id="L1082">                <span class="tok-kw">if</span> (<span class="tok-kw">try</span> prog.checkLineMatch(allocator, file_entries.items)) |info| <span class="tok-kw">return</span> info;</span>
<span class="line" id="L1083">                prog.basic_block = <span class="tok-null">false</span>;</span>
<span class="line" id="L1084">            } <span class="tok-kw">else</span> {</span>
<span class="line" id="L1085">                <span class="tok-kw">switch</span> (opcode) {</span>
<span class="line" id="L1086">                    LNS.copy =&gt; {</span>
<span class="line" id="L1087">                        <span class="tok-kw">if</span> (<span class="tok-kw">try</span> prog.checkLineMatch(allocator, file_entries.items)) |info| <span class="tok-kw">return</span> info;</span>
<span class="line" id="L1088">                        prog.basic_block = <span class="tok-null">false</span>;</span>
<span class="line" id="L1089">                    },</span>
<span class="line" id="L1090">                    LNS.advance_pc =&gt; {</span>
<span class="line" id="L1091">                        <span class="tok-kw">const</span> arg = <span class="tok-kw">try</span> leb.readULEB128(<span class="tok-type">usize</span>, in);</span>
<span class="line" id="L1092">                        prog.address += arg * minimum_instruction_length;</span>
<span class="line" id="L1093">                    },</span>
<span class="line" id="L1094">                    LNS.advance_line =&gt; {</span>
<span class="line" id="L1095">                        <span class="tok-kw">const</span> arg = <span class="tok-kw">try</span> leb.readILEB128(<span class="tok-type">i64</span>, in);</span>
<span class="line" id="L1096">                        prog.line += arg;</span>
<span class="line" id="L1097">                    },</span>
<span class="line" id="L1098">                    LNS.set_file =&gt; {</span>
<span class="line" id="L1099">                        <span class="tok-kw">const</span> arg = <span class="tok-kw">try</span> leb.readULEB128(<span class="tok-type">usize</span>, in);</span>
<span class="line" id="L1100">                        prog.file = arg;</span>
<span class="line" id="L1101">                    },</span>
<span class="line" id="L1102">                    LNS.set_column =&gt; {</span>
<span class="line" id="L1103">                        <span class="tok-kw">const</span> arg = <span class="tok-kw">try</span> leb.readULEB128(<span class="tok-type">u64</span>, in);</span>
<span class="line" id="L1104">                        prog.column = arg;</span>
<span class="line" id="L1105">                    },</span>
<span class="line" id="L1106">                    LNS.negate_stmt =&gt; {</span>
<span class="line" id="L1107">                        prog.is_stmt = !prog.is_stmt;</span>
<span class="line" id="L1108">                    },</span>
<span class="line" id="L1109">                    LNS.set_basic_block =&gt; {</span>
<span class="line" id="L1110">                        prog.basic_block = <span class="tok-null">true</span>;</span>
<span class="line" id="L1111">                    },</span>
<span class="line" id="L1112">                    LNS.const_add_pc =&gt; {</span>
<span class="line" id="L1113">                        <span class="tok-kw">const</span> inc_addr = minimum_instruction_length * ((<span class="tok-number">255</span> - opcode_base) / line_range);</span>
<span class="line" id="L1114">                        prog.address += inc_addr;</span>
<span class="line" id="L1115">                    },</span>
<span class="line" id="L1116">                    LNS.fixed_advance_pc =&gt; {</span>
<span class="line" id="L1117">                        <span class="tok-kw">const</span> arg = <span class="tok-kw">try</span> in.readInt(<span class="tok-type">u16</span>, di.endian);</span>
<span class="line" id="L1118">                        prog.address += arg;</span>
<span class="line" id="L1119">                    },</span>
<span class="line" id="L1120">                    LNS.set_prologue_end =&gt; {},</span>
<span class="line" id="L1121">                    <span class="tok-kw">else</span> =&gt; {</span>
<span class="line" id="L1122">                        <span class="tok-kw">if</span> (opcode - <span class="tok-number">1</span> &gt;= standard_opcode_lengths.len) <span class="tok-kw">return</span> <span class="tok-kw">error</span>.InvalidDebugInfo;</span>
<span class="line" id="L1123">                        <span class="tok-kw">const</span> len_bytes = standard_opcode_lengths[opcode - <span class="tok-number">1</span>];</span>
<span class="line" id="L1124">                        <span class="tok-kw">try</span> seekable.seekBy(len_bytes);</span>
<span class="line" id="L1125">                    },</span>
<span class="line" id="L1126">                }</span>
<span class="line" id="L1127">            }</span>
<span class="line" id="L1128">        }</span>
<span class="line" id="L1129"></span>
<span class="line" id="L1130">        <span class="tok-kw">return</span> <span class="tok-kw">error</span>.MissingDebugInfo;</span>
<span class="line" id="L1131">    }</span>
<span class="line" id="L1132"></span>
<span class="line" id="L1133">    <span class="tok-kw">fn</span> <span class="tok-fn">getString</span>(di: *DwarfInfo, offset: <span class="tok-type">u64</span>) ![]<span class="tok-kw">const</span> <span class="tok-type">u8</span> {</span>
<span class="line" id="L1134">        <span class="tok-kw">if</span> (offset &gt; di.debug_str.len)</span>
<span class="line" id="L1135">            <span class="tok-kw">return</span> <span class="tok-kw">error</span>.InvalidDebugInfo;</span>
<span class="line" id="L1136">        <span class="tok-kw">const</span> casted_offset = math.cast(<span class="tok-type">usize</span>, offset) <span class="tok-kw">orelse</span></span>
<span class="line" id="L1137">            <span class="tok-kw">return</span> <span class="tok-kw">error</span>.InvalidDebugInfo;</span>
<span class="line" id="L1138"></span>
<span class="line" id="L1139">        <span class="tok-comment">// Valid strings always have a terminating zero byte</span>
</span>
<span class="line" id="L1140">        <span class="tok-kw">if</span> (mem.indexOfScalarPos(<span class="tok-type">u8</span>, di.debug_str, casted_offset, <span class="tok-number">0</span>)) |last| {</span>
<span class="line" id="L1141">            <span class="tok-kw">return</span> di.debug_str[casted_offset..last];</span>
<span class="line" id="L1142">        }</span>
<span class="line" id="L1143"></span>
<span class="line" id="L1144">        <span class="tok-kw">return</span> <span class="tok-kw">error</span>.InvalidDebugInfo;</span>
<span class="line" id="L1145">    }</span>
<span class="line" id="L1146"></span>
<span class="line" id="L1147">    <span class="tok-kw">fn</span> <span class="tok-fn">getLineString</span>(di: *DwarfInfo, offset: <span class="tok-type">u64</span>) ![]<span class="tok-kw">const</span> <span class="tok-type">u8</span> {</span>
<span class="line" id="L1148">        <span class="tok-kw">const</span> debug_line_str = di.debug_line_str <span class="tok-kw">orelse</span> <span class="tok-kw">return</span> <span class="tok-kw">error</span>.InvalidDebugInfo;</span>
<span class="line" id="L1149">        <span class="tok-kw">if</span> (offset &gt; debug_line_str.len)</span>
<span class="line" id="L1150">            <span class="tok-kw">return</span> <span class="tok-kw">error</span>.InvalidDebugInfo;</span>
<span class="line" id="L1151">        <span class="tok-kw">const</span> casted_offset = math.cast(<span class="tok-type">usize</span>, offset) <span class="tok-kw">orelse</span></span>
<span class="line" id="L1152">            <span class="tok-kw">return</span> <span class="tok-kw">error</span>.InvalidDebugInfo;</span>
<span class="line" id="L1153"></span>
<span class="line" id="L1154">        <span class="tok-comment">// Valid strings always have a terminating zero byte</span>
</span>
<span class="line" id="L1155">        <span class="tok-kw">if</span> (mem.indexOfScalarPos(<span class="tok-type">u8</span>, debug_line_str, casted_offset, <span class="tok-number">0</span>)) |last| {</span>
<span class="line" id="L1156">            <span class="tok-kw">return</span> debug_line_str[casted_offset..last];</span>
<span class="line" id="L1157">        }</span>
<span class="line" id="L1158"></span>
<span class="line" id="L1159">        <span class="tok-kw">return</span> <span class="tok-kw">error</span>.InvalidDebugInfo;</span>
<span class="line" id="L1160">    }</span>
<span class="line" id="L1161">};</span>
<span class="line" id="L1162"></span>
<span class="line" id="L1163"><span class="tok-comment">/// Initialize DWARF info. The caller has the responsibility to initialize most</span></span>
<span class="line" id="L1164"><span class="tok-comment">/// the DwarfInfo fields before calling.</span></span>
<span class="line" id="L1165"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">openDwarfDebugInfo</span>(di: *DwarfInfo, allocator: mem.Allocator) !<span class="tok-type">void</span> {</span>
<span class="line" id="L1166">    <span class="tok-kw">try</span> di.scanAllFunctions(allocator);</span>
<span class="line" id="L1167">    <span class="tok-kw">try</span> di.scanAllCompileUnits(allocator);</span>
<span class="line" id="L1168">}</span>
<span class="line" id="L1169"></span>
</code></pre></body>
</html>