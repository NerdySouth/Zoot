<!doctype html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">    <title>zig/tokenizer.zig - source view</title>
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
<pre><code><span class="line" id="L1"><span class="tok-kw">const</span> std = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;../std.zig&quot;</span>);</span>
<span class="line" id="L2"></span>
<span class="line" id="L3"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> Token = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L4">    tag: Tag,</span>
<span class="line" id="L5">    loc: Loc,</span>
<span class="line" id="L6"></span>
<span class="line" id="L7">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> Loc = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L8">        start: <span class="tok-type">usize</span>,</span>
<span class="line" id="L9">        end: <span class="tok-type">usize</span>,</span>
<span class="line" id="L10">    };</span>
<span class="line" id="L11"></span>
<span class="line" id="L12">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> keywords = std.ComptimeStringMap(Tag, .{</span>
<span class="line" id="L13">        .{ <span class="tok-str">&quot;addrspace&quot;</span>, .keyword_addrspace },</span>
<span class="line" id="L14">        .{ <span class="tok-str">&quot;align&quot;</span>, .keyword_align },</span>
<span class="line" id="L15">        .{ <span class="tok-str">&quot;allowzero&quot;</span>, .keyword_allowzero },</span>
<span class="line" id="L16">        .{ <span class="tok-str">&quot;and&quot;</span>, .keyword_and },</span>
<span class="line" id="L17">        .{ <span class="tok-str">&quot;anyframe&quot;</span>, .keyword_anyframe },</span>
<span class="line" id="L18">        .{ <span class="tok-str">&quot;anytype&quot;</span>, .keyword_anytype },</span>
<span class="line" id="L19">        .{ <span class="tok-str">&quot;asm&quot;</span>, .keyword_asm },</span>
<span class="line" id="L20">        .{ <span class="tok-str">&quot;async&quot;</span>, .keyword_async },</span>
<span class="line" id="L21">        .{ <span class="tok-str">&quot;await&quot;</span>, .keyword_await },</span>
<span class="line" id="L22">        .{ <span class="tok-str">&quot;break&quot;</span>, .keyword_break },</span>
<span class="line" id="L23">        .{ <span class="tok-str">&quot;callconv&quot;</span>, .keyword_callconv },</span>
<span class="line" id="L24">        .{ <span class="tok-str">&quot;catch&quot;</span>, .keyword_catch },</span>
<span class="line" id="L25">        .{ <span class="tok-str">&quot;comptime&quot;</span>, .keyword_comptime },</span>
<span class="line" id="L26">        .{ <span class="tok-str">&quot;const&quot;</span>, .keyword_const },</span>
<span class="line" id="L27">        .{ <span class="tok-str">&quot;continue&quot;</span>, .keyword_continue },</span>
<span class="line" id="L28">        .{ <span class="tok-str">&quot;defer&quot;</span>, .keyword_defer },</span>
<span class="line" id="L29">        .{ <span class="tok-str">&quot;else&quot;</span>, .keyword_else },</span>
<span class="line" id="L30">        .{ <span class="tok-str">&quot;enum&quot;</span>, .keyword_enum },</span>
<span class="line" id="L31">        .{ <span class="tok-str">&quot;errdefer&quot;</span>, .keyword_errdefer },</span>
<span class="line" id="L32">        .{ <span class="tok-str">&quot;error&quot;</span>, .keyword_error },</span>
<span class="line" id="L33">        .{ <span class="tok-str">&quot;export&quot;</span>, .keyword_export },</span>
<span class="line" id="L34">        .{ <span class="tok-str">&quot;extern&quot;</span>, .keyword_extern },</span>
<span class="line" id="L35">        .{ <span class="tok-str">&quot;fn&quot;</span>, .keyword_fn },</span>
<span class="line" id="L36">        .{ <span class="tok-str">&quot;for&quot;</span>, .keyword_for },</span>
<span class="line" id="L37">        .{ <span class="tok-str">&quot;if&quot;</span>, .keyword_if },</span>
<span class="line" id="L38">        .{ <span class="tok-str">&quot;inline&quot;</span>, .keyword_inline },</span>
<span class="line" id="L39">        .{ <span class="tok-str">&quot;noalias&quot;</span>, .keyword_noalias },</span>
<span class="line" id="L40">        .{ <span class="tok-str">&quot;noinline&quot;</span>, .keyword_noinline },</span>
<span class="line" id="L41">        .{ <span class="tok-str">&quot;nosuspend&quot;</span>, .keyword_nosuspend },</span>
<span class="line" id="L42">        .{ <span class="tok-str">&quot;opaque&quot;</span>, .keyword_opaque },</span>
<span class="line" id="L43">        .{ <span class="tok-str">&quot;or&quot;</span>, .keyword_or },</span>
<span class="line" id="L44">        .{ <span class="tok-str">&quot;orelse&quot;</span>, .keyword_orelse },</span>
<span class="line" id="L45">        .{ <span class="tok-str">&quot;packed&quot;</span>, .keyword_packed },</span>
<span class="line" id="L46">        .{ <span class="tok-str">&quot;pub&quot;</span>, .keyword_pub },</span>
<span class="line" id="L47">        .{ <span class="tok-str">&quot;resume&quot;</span>, .keyword_resume },</span>
<span class="line" id="L48">        .{ <span class="tok-str">&quot;return&quot;</span>, .keyword_return },</span>
<span class="line" id="L49">        .{ <span class="tok-str">&quot;linksection&quot;</span>, .keyword_linksection },</span>
<span class="line" id="L50">        .{ <span class="tok-str">&quot;struct&quot;</span>, .keyword_struct },</span>
<span class="line" id="L51">        .{ <span class="tok-str">&quot;suspend&quot;</span>, .keyword_suspend },</span>
<span class="line" id="L52">        .{ <span class="tok-str">&quot;switch&quot;</span>, .keyword_switch },</span>
<span class="line" id="L53">        .{ <span class="tok-str">&quot;test&quot;</span>, .keyword_test },</span>
<span class="line" id="L54">        .{ <span class="tok-str">&quot;threadlocal&quot;</span>, .keyword_threadlocal },</span>
<span class="line" id="L55">        .{ <span class="tok-str">&quot;try&quot;</span>, .keyword_try },</span>
<span class="line" id="L56">        .{ <span class="tok-str">&quot;union&quot;</span>, .keyword_union },</span>
<span class="line" id="L57">        .{ <span class="tok-str">&quot;unreachable&quot;</span>, .keyword_unreachable },</span>
<span class="line" id="L58">        .{ <span class="tok-str">&quot;usingnamespace&quot;</span>, .keyword_usingnamespace },</span>
<span class="line" id="L59">        .{ <span class="tok-str">&quot;var&quot;</span>, .keyword_var },</span>
<span class="line" id="L60">        .{ <span class="tok-str">&quot;volatile&quot;</span>, .keyword_volatile },</span>
<span class="line" id="L61">        .{ <span class="tok-str">&quot;while&quot;</span>, .keyword_while },</span>
<span class="line" id="L62">    });</span>
<span class="line" id="L63"></span>
<span class="line" id="L64">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">getKeyword</span>(bytes: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) ?Tag {</span>
<span class="line" id="L65">        <span class="tok-kw">return</span> keywords.get(bytes);</span>
<span class="line" id="L66">    }</span>
<span class="line" id="L67"></span>
<span class="line" id="L68">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> Tag = <span class="tok-kw">enum</span> {</span>
<span class="line" id="L69">        invalid,</span>
<span class="line" id="L70">        invalid_periodasterisks,</span>
<span class="line" id="L71">        identifier,</span>
<span class="line" id="L72">        string_literal,</span>
<span class="line" id="L73">        multiline_string_literal_line,</span>
<span class="line" id="L74">        char_literal,</span>
<span class="line" id="L75">        eof,</span>
<span class="line" id="L76">        builtin,</span>
<span class="line" id="L77">        bang,</span>
<span class="line" id="L78">        pipe,</span>
<span class="line" id="L79">        pipe_pipe,</span>
<span class="line" id="L80">        pipe_equal,</span>
<span class="line" id="L81">        equal,</span>
<span class="line" id="L82">        equal_equal,</span>
<span class="line" id="L83">        equal_angle_bracket_right,</span>
<span class="line" id="L84">        bang_equal,</span>
<span class="line" id="L85">        l_paren,</span>
<span class="line" id="L86">        r_paren,</span>
<span class="line" id="L87">        semicolon,</span>
<span class="line" id="L88">        percent,</span>
<span class="line" id="L89">        percent_equal,</span>
<span class="line" id="L90">        l_brace,</span>
<span class="line" id="L91">        r_brace,</span>
<span class="line" id="L92">        l_bracket,</span>
<span class="line" id="L93">        r_bracket,</span>
<span class="line" id="L94">        period,</span>
<span class="line" id="L95">        period_asterisk,</span>
<span class="line" id="L96">        ellipsis2,</span>
<span class="line" id="L97">        ellipsis3,</span>
<span class="line" id="L98">        caret,</span>
<span class="line" id="L99">        caret_equal,</span>
<span class="line" id="L100">        plus,</span>
<span class="line" id="L101">        plus_plus,</span>
<span class="line" id="L102">        plus_equal,</span>
<span class="line" id="L103">        plus_percent,</span>
<span class="line" id="L104">        plus_percent_equal,</span>
<span class="line" id="L105">        plus_pipe,</span>
<span class="line" id="L106">        plus_pipe_equal,</span>
<span class="line" id="L107">        minus,</span>
<span class="line" id="L108">        minus_equal,</span>
<span class="line" id="L109">        minus_percent,</span>
<span class="line" id="L110">        minus_percent_equal,</span>
<span class="line" id="L111">        minus_pipe,</span>
<span class="line" id="L112">        minus_pipe_equal,</span>
<span class="line" id="L113">        asterisk,</span>
<span class="line" id="L114">        asterisk_equal,</span>
<span class="line" id="L115">        asterisk_asterisk,</span>
<span class="line" id="L116">        asterisk_percent,</span>
<span class="line" id="L117">        asterisk_percent_equal,</span>
<span class="line" id="L118">        asterisk_pipe,</span>
<span class="line" id="L119">        asterisk_pipe_equal,</span>
<span class="line" id="L120">        arrow,</span>
<span class="line" id="L121">        colon,</span>
<span class="line" id="L122">        slash,</span>
<span class="line" id="L123">        slash_equal,</span>
<span class="line" id="L124">        comma,</span>
<span class="line" id="L125">        ampersand,</span>
<span class="line" id="L126">        ampersand_equal,</span>
<span class="line" id="L127">        question_mark,</span>
<span class="line" id="L128">        angle_bracket_left,</span>
<span class="line" id="L129">        angle_bracket_left_equal,</span>
<span class="line" id="L130">        angle_bracket_angle_bracket_left,</span>
<span class="line" id="L131">        angle_bracket_angle_bracket_left_equal,</span>
<span class="line" id="L132">        angle_bracket_angle_bracket_left_pipe,</span>
<span class="line" id="L133">        angle_bracket_angle_bracket_left_pipe_equal,</span>
<span class="line" id="L134">        angle_bracket_right,</span>
<span class="line" id="L135">        angle_bracket_right_equal,</span>
<span class="line" id="L136">        angle_bracket_angle_bracket_right,</span>
<span class="line" id="L137">        angle_bracket_angle_bracket_right_equal,</span>
<span class="line" id="L138">        tilde,</span>
<span class="line" id="L139">        integer_literal,</span>
<span class="line" id="L140">        float_literal,</span>
<span class="line" id="L141">        doc_comment,</span>
<span class="line" id="L142">        container_doc_comment,</span>
<span class="line" id="L143">        keyword_addrspace,</span>
<span class="line" id="L144">        keyword_align,</span>
<span class="line" id="L145">        keyword_allowzero,</span>
<span class="line" id="L146">        keyword_and,</span>
<span class="line" id="L147">        keyword_anyframe,</span>
<span class="line" id="L148">        keyword_anytype,</span>
<span class="line" id="L149">        keyword_asm,</span>
<span class="line" id="L150">        keyword_async,</span>
<span class="line" id="L151">        keyword_await,</span>
<span class="line" id="L152">        keyword_break,</span>
<span class="line" id="L153">        keyword_callconv,</span>
<span class="line" id="L154">        keyword_catch,</span>
<span class="line" id="L155">        keyword_comptime,</span>
<span class="line" id="L156">        keyword_const,</span>
<span class="line" id="L157">        keyword_continue,</span>
<span class="line" id="L158">        keyword_defer,</span>
<span class="line" id="L159">        keyword_else,</span>
<span class="line" id="L160">        keyword_enum,</span>
<span class="line" id="L161">        keyword_errdefer,</span>
<span class="line" id="L162">        keyword_error,</span>
<span class="line" id="L163">        keyword_export,</span>
<span class="line" id="L164">        keyword_extern,</span>
<span class="line" id="L165">        keyword_fn,</span>
<span class="line" id="L166">        keyword_for,</span>
<span class="line" id="L167">        keyword_if,</span>
<span class="line" id="L168">        keyword_inline,</span>
<span class="line" id="L169">        keyword_noalias,</span>
<span class="line" id="L170">        keyword_noinline,</span>
<span class="line" id="L171">        keyword_nosuspend,</span>
<span class="line" id="L172">        keyword_opaque,</span>
<span class="line" id="L173">        keyword_or,</span>
<span class="line" id="L174">        keyword_orelse,</span>
<span class="line" id="L175">        keyword_packed,</span>
<span class="line" id="L176">        keyword_pub,</span>
<span class="line" id="L177">        keyword_resume,</span>
<span class="line" id="L178">        keyword_return,</span>
<span class="line" id="L179">        keyword_linksection,</span>
<span class="line" id="L180">        keyword_struct,</span>
<span class="line" id="L181">        keyword_suspend,</span>
<span class="line" id="L182">        keyword_switch,</span>
<span class="line" id="L183">        keyword_test,</span>
<span class="line" id="L184">        keyword_threadlocal,</span>
<span class="line" id="L185">        keyword_try,</span>
<span class="line" id="L186">        keyword_union,</span>
<span class="line" id="L187">        keyword_unreachable,</span>
<span class="line" id="L188">        keyword_usingnamespace,</span>
<span class="line" id="L189">        keyword_var,</span>
<span class="line" id="L190">        keyword_volatile,</span>
<span class="line" id="L191">        keyword_while,</span>
<span class="line" id="L192"></span>
<span class="line" id="L193">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">lexeme</span>(tag: Tag) ?[]<span class="tok-kw">const</span> <span class="tok-type">u8</span> {</span>
<span class="line" id="L194">            <span class="tok-kw">return</span> <span class="tok-kw">switch</span> (tag) {</span>
<span class="line" id="L195">                .invalid,</span>
<span class="line" id="L196">                .identifier,</span>
<span class="line" id="L197">                .string_literal,</span>
<span class="line" id="L198">                .multiline_string_literal_line,</span>
<span class="line" id="L199">                .char_literal,</span>
<span class="line" id="L200">                .eof,</span>
<span class="line" id="L201">                .builtin,</span>
<span class="line" id="L202">                .integer_literal,</span>
<span class="line" id="L203">                .float_literal,</span>
<span class="line" id="L204">                .doc_comment,</span>
<span class="line" id="L205">                .container_doc_comment,</span>
<span class="line" id="L206">                =&gt; <span class="tok-null">null</span>,</span>
<span class="line" id="L207"></span>
<span class="line" id="L208">                .invalid_periodasterisks =&gt; <span class="tok-str">&quot;.**&quot;</span>,</span>
<span class="line" id="L209">                .bang =&gt; <span class="tok-str">&quot;!&quot;</span>,</span>
<span class="line" id="L210">                .pipe =&gt; <span class="tok-str">&quot;|&quot;</span>,</span>
<span class="line" id="L211">                .pipe_pipe =&gt; <span class="tok-str">&quot;||&quot;</span>,</span>
<span class="line" id="L212">                .pipe_equal =&gt; <span class="tok-str">&quot;|=&quot;</span>,</span>
<span class="line" id="L213">                .equal =&gt; <span class="tok-str">&quot;=&quot;</span>,</span>
<span class="line" id="L214">                .equal_equal =&gt; <span class="tok-str">&quot;==&quot;</span>,</span>
<span class="line" id="L215">                .equal_angle_bracket_right =&gt; <span class="tok-str">&quot;=&gt;&quot;</span>,</span>
<span class="line" id="L216">                .bang_equal =&gt; <span class="tok-str">&quot;!=&quot;</span>,</span>
<span class="line" id="L217">                .l_paren =&gt; <span class="tok-str">&quot;(&quot;</span>,</span>
<span class="line" id="L218">                .r_paren =&gt; <span class="tok-str">&quot;)&quot;</span>,</span>
<span class="line" id="L219">                .semicolon =&gt; <span class="tok-str">&quot;;&quot;</span>,</span>
<span class="line" id="L220">                .percent =&gt; <span class="tok-str">&quot;%&quot;</span>,</span>
<span class="line" id="L221">                .percent_equal =&gt; <span class="tok-str">&quot;%=&quot;</span>,</span>
<span class="line" id="L222">                .l_brace =&gt; <span class="tok-str">&quot;{&quot;</span>,</span>
<span class="line" id="L223">                .r_brace =&gt; <span class="tok-str">&quot;}&quot;</span>,</span>
<span class="line" id="L224">                .l_bracket =&gt; <span class="tok-str">&quot;[&quot;</span>,</span>
<span class="line" id="L225">                .r_bracket =&gt; <span class="tok-str">&quot;]&quot;</span>,</span>
<span class="line" id="L226">                .period =&gt; <span class="tok-str">&quot;.&quot;</span>,</span>
<span class="line" id="L227">                .period_asterisk =&gt; <span class="tok-str">&quot;.*&quot;</span>,</span>
<span class="line" id="L228">                .ellipsis2 =&gt; <span class="tok-str">&quot;..&quot;</span>,</span>
<span class="line" id="L229">                .ellipsis3 =&gt; <span class="tok-str">&quot;...&quot;</span>,</span>
<span class="line" id="L230">                .caret =&gt; <span class="tok-str">&quot;^&quot;</span>,</span>
<span class="line" id="L231">                .caret_equal =&gt; <span class="tok-str">&quot;^=&quot;</span>,</span>
<span class="line" id="L232">                .plus =&gt; <span class="tok-str">&quot;+&quot;</span>,</span>
<span class="line" id="L233">                .plus_plus =&gt; <span class="tok-str">&quot;++&quot;</span>,</span>
<span class="line" id="L234">                .plus_equal =&gt; <span class="tok-str">&quot;+=&quot;</span>,</span>
<span class="line" id="L235">                .plus_percent =&gt; <span class="tok-str">&quot;+%&quot;</span>,</span>
<span class="line" id="L236">                .plus_percent_equal =&gt; <span class="tok-str">&quot;+%=&quot;</span>,</span>
<span class="line" id="L237">                .plus_pipe =&gt; <span class="tok-str">&quot;+|&quot;</span>,</span>
<span class="line" id="L238">                .plus_pipe_equal =&gt; <span class="tok-str">&quot;+|=&quot;</span>,</span>
<span class="line" id="L239">                .minus =&gt; <span class="tok-str">&quot;-&quot;</span>,</span>
<span class="line" id="L240">                .minus_equal =&gt; <span class="tok-str">&quot;-=&quot;</span>,</span>
<span class="line" id="L241">                .minus_percent =&gt; <span class="tok-str">&quot;-%&quot;</span>,</span>
<span class="line" id="L242">                .minus_percent_equal =&gt; <span class="tok-str">&quot;-%=&quot;</span>,</span>
<span class="line" id="L243">                .minus_pipe =&gt; <span class="tok-str">&quot;-|&quot;</span>,</span>
<span class="line" id="L244">                .minus_pipe_equal =&gt; <span class="tok-str">&quot;-|=&quot;</span>,</span>
<span class="line" id="L245">                .asterisk =&gt; <span class="tok-str">&quot;*&quot;</span>,</span>
<span class="line" id="L246">                .asterisk_equal =&gt; <span class="tok-str">&quot;*=&quot;</span>,</span>
<span class="line" id="L247">                .asterisk_asterisk =&gt; <span class="tok-str">&quot;**&quot;</span>,</span>
<span class="line" id="L248">                .asterisk_percent =&gt; <span class="tok-str">&quot;*%&quot;</span>,</span>
<span class="line" id="L249">                .asterisk_percent_equal =&gt; <span class="tok-str">&quot;*%=&quot;</span>,</span>
<span class="line" id="L250">                .asterisk_pipe =&gt; <span class="tok-str">&quot;*|&quot;</span>,</span>
<span class="line" id="L251">                .asterisk_pipe_equal =&gt; <span class="tok-str">&quot;*|=&quot;</span>,</span>
<span class="line" id="L252">                .arrow =&gt; <span class="tok-str">&quot;-&gt;&quot;</span>,</span>
<span class="line" id="L253">                .colon =&gt; <span class="tok-str">&quot;:&quot;</span>,</span>
<span class="line" id="L254">                .slash =&gt; <span class="tok-str">&quot;/&quot;</span>,</span>
<span class="line" id="L255">                .slash_equal =&gt; <span class="tok-str">&quot;/=&quot;</span>,</span>
<span class="line" id="L256">                .comma =&gt; <span class="tok-str">&quot;,&quot;</span>,</span>
<span class="line" id="L257">                .ampersand =&gt; <span class="tok-str">&quot;&amp;&quot;</span>,</span>
<span class="line" id="L258">                .ampersand_equal =&gt; <span class="tok-str">&quot;&amp;=&quot;</span>,</span>
<span class="line" id="L259">                .question_mark =&gt; <span class="tok-str">&quot;?&quot;</span>,</span>
<span class="line" id="L260">                .angle_bracket_left =&gt; <span class="tok-str">&quot;&lt;&quot;</span>,</span>
<span class="line" id="L261">                .angle_bracket_left_equal =&gt; <span class="tok-str">&quot;&lt;=&quot;</span>,</span>
<span class="line" id="L262">                .angle_bracket_angle_bracket_left =&gt; <span class="tok-str">&quot;&lt;&lt;&quot;</span>,</span>
<span class="line" id="L263">                .angle_bracket_angle_bracket_left_equal =&gt; <span class="tok-str">&quot;&lt;&lt;=&quot;</span>,</span>
<span class="line" id="L264">                .angle_bracket_angle_bracket_left_pipe =&gt; <span class="tok-str">&quot;&lt;&lt;|&quot;</span>,</span>
<span class="line" id="L265">                .angle_bracket_angle_bracket_left_pipe_equal =&gt; <span class="tok-str">&quot;&lt;&lt;|=&quot;</span>,</span>
<span class="line" id="L266">                .angle_bracket_right =&gt; <span class="tok-str">&quot;&gt;&quot;</span>,</span>
<span class="line" id="L267">                .angle_bracket_right_equal =&gt; <span class="tok-str">&quot;&gt;=&quot;</span>,</span>
<span class="line" id="L268">                .angle_bracket_angle_bracket_right =&gt; <span class="tok-str">&quot;&gt;&gt;&quot;</span>,</span>
<span class="line" id="L269">                .angle_bracket_angle_bracket_right_equal =&gt; <span class="tok-str">&quot;&gt;&gt;=&quot;</span>,</span>
<span class="line" id="L270">                .tilde =&gt; <span class="tok-str">&quot;~&quot;</span>,</span>
<span class="line" id="L271">                .keyword_addrspace =&gt; <span class="tok-str">&quot;addrspace&quot;</span>,</span>
<span class="line" id="L272">                .keyword_align =&gt; <span class="tok-str">&quot;align&quot;</span>,</span>
<span class="line" id="L273">                .keyword_allowzero =&gt; <span class="tok-str">&quot;allowzero&quot;</span>,</span>
<span class="line" id="L274">                .keyword_and =&gt; <span class="tok-str">&quot;and&quot;</span>,</span>
<span class="line" id="L275">                .keyword_anyframe =&gt; <span class="tok-str">&quot;anyframe&quot;</span>,</span>
<span class="line" id="L276">                .keyword_anytype =&gt; <span class="tok-str">&quot;anytype&quot;</span>,</span>
<span class="line" id="L277">                .keyword_asm =&gt; <span class="tok-str">&quot;asm&quot;</span>,</span>
<span class="line" id="L278">                .keyword_async =&gt; <span class="tok-str">&quot;async&quot;</span>,</span>
<span class="line" id="L279">                .keyword_await =&gt; <span class="tok-str">&quot;await&quot;</span>,</span>
<span class="line" id="L280">                .keyword_break =&gt; <span class="tok-str">&quot;break&quot;</span>,</span>
<span class="line" id="L281">                .keyword_callconv =&gt; <span class="tok-str">&quot;callconv&quot;</span>,</span>
<span class="line" id="L282">                .keyword_catch =&gt; <span class="tok-str">&quot;catch&quot;</span>,</span>
<span class="line" id="L283">                .keyword_comptime =&gt; <span class="tok-str">&quot;comptime&quot;</span>,</span>
<span class="line" id="L284">                .keyword_const =&gt; <span class="tok-str">&quot;const&quot;</span>,</span>
<span class="line" id="L285">                .keyword_continue =&gt; <span class="tok-str">&quot;continue&quot;</span>,</span>
<span class="line" id="L286">                .keyword_defer =&gt; <span class="tok-str">&quot;defer&quot;</span>,</span>
<span class="line" id="L287">                .keyword_else =&gt; <span class="tok-str">&quot;else&quot;</span>,</span>
<span class="line" id="L288">                .keyword_enum =&gt; <span class="tok-str">&quot;enum&quot;</span>,</span>
<span class="line" id="L289">                .keyword_errdefer =&gt; <span class="tok-str">&quot;errdefer&quot;</span>,</span>
<span class="line" id="L290">                .keyword_error =&gt; <span class="tok-str">&quot;error&quot;</span>,</span>
<span class="line" id="L291">                .keyword_export =&gt; <span class="tok-str">&quot;export&quot;</span>,</span>
<span class="line" id="L292">                .keyword_extern =&gt; <span class="tok-str">&quot;extern&quot;</span>,</span>
<span class="line" id="L293">                .keyword_fn =&gt; <span class="tok-str">&quot;fn&quot;</span>,</span>
<span class="line" id="L294">                .keyword_for =&gt; <span class="tok-str">&quot;for&quot;</span>,</span>
<span class="line" id="L295">                .keyword_if =&gt; <span class="tok-str">&quot;if&quot;</span>,</span>
<span class="line" id="L296">                .keyword_inline =&gt; <span class="tok-str">&quot;inline&quot;</span>,</span>
<span class="line" id="L297">                .keyword_noalias =&gt; <span class="tok-str">&quot;noalias&quot;</span>,</span>
<span class="line" id="L298">                .keyword_noinline =&gt; <span class="tok-str">&quot;noinline&quot;</span>,</span>
<span class="line" id="L299">                .keyword_nosuspend =&gt; <span class="tok-str">&quot;nosuspend&quot;</span>,</span>
<span class="line" id="L300">                .keyword_opaque =&gt; <span class="tok-str">&quot;opaque&quot;</span>,</span>
<span class="line" id="L301">                .keyword_or =&gt; <span class="tok-str">&quot;or&quot;</span>,</span>
<span class="line" id="L302">                .keyword_orelse =&gt; <span class="tok-str">&quot;orelse&quot;</span>,</span>
<span class="line" id="L303">                .keyword_packed =&gt; <span class="tok-str">&quot;packed&quot;</span>,</span>
<span class="line" id="L304">                .keyword_pub =&gt; <span class="tok-str">&quot;pub&quot;</span>,</span>
<span class="line" id="L305">                .keyword_resume =&gt; <span class="tok-str">&quot;resume&quot;</span>,</span>
<span class="line" id="L306">                .keyword_return =&gt; <span class="tok-str">&quot;return&quot;</span>,</span>
<span class="line" id="L307">                .keyword_linksection =&gt; <span class="tok-str">&quot;linksection&quot;</span>,</span>
<span class="line" id="L308">                .keyword_struct =&gt; <span class="tok-str">&quot;struct&quot;</span>,</span>
<span class="line" id="L309">                .keyword_suspend =&gt; <span class="tok-str">&quot;suspend&quot;</span>,</span>
<span class="line" id="L310">                .keyword_switch =&gt; <span class="tok-str">&quot;switch&quot;</span>,</span>
<span class="line" id="L311">                .keyword_test =&gt; <span class="tok-str">&quot;test&quot;</span>,</span>
<span class="line" id="L312">                .keyword_threadlocal =&gt; <span class="tok-str">&quot;threadlocal&quot;</span>,</span>
<span class="line" id="L313">                .keyword_try =&gt; <span class="tok-str">&quot;try&quot;</span>,</span>
<span class="line" id="L314">                .keyword_union =&gt; <span class="tok-str">&quot;union&quot;</span>,</span>
<span class="line" id="L315">                .keyword_unreachable =&gt; <span class="tok-str">&quot;unreachable&quot;</span>,</span>
<span class="line" id="L316">                .keyword_usingnamespace =&gt; <span class="tok-str">&quot;usingnamespace&quot;</span>,</span>
<span class="line" id="L317">                .keyword_var =&gt; <span class="tok-str">&quot;var&quot;</span>,</span>
<span class="line" id="L318">                .keyword_volatile =&gt; <span class="tok-str">&quot;volatile&quot;</span>,</span>
<span class="line" id="L319">                .keyword_while =&gt; <span class="tok-str">&quot;while&quot;</span>,</span>
<span class="line" id="L320">            };</span>
<span class="line" id="L321">        }</span>
<span class="line" id="L322"></span>
<span class="line" id="L323">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">symbol</span>(tag: Tag) []<span class="tok-kw">const</span> <span class="tok-type">u8</span> {</span>
<span class="line" id="L324">            <span class="tok-kw">return</span> tag.lexeme() <span class="tok-kw">orelse</span> <span class="tok-kw">switch</span> (tag) {</span>
<span class="line" id="L325">                .invalid =&gt; <span class="tok-str">&quot;invalid bytes&quot;</span>,</span>
<span class="line" id="L326">                .identifier =&gt; <span class="tok-str">&quot;an identifier&quot;</span>,</span>
<span class="line" id="L327">                .string_literal, .multiline_string_literal_line =&gt; <span class="tok-str">&quot;a string literal&quot;</span>,</span>
<span class="line" id="L328">                .char_literal =&gt; <span class="tok-str">&quot;a character literal&quot;</span>,</span>
<span class="line" id="L329">                .eof =&gt; <span class="tok-str">&quot;EOF&quot;</span>,</span>
<span class="line" id="L330">                .builtin =&gt; <span class="tok-str">&quot;a builtin function&quot;</span>,</span>
<span class="line" id="L331">                .integer_literal =&gt; <span class="tok-str">&quot;an integer literal&quot;</span>,</span>
<span class="line" id="L332">                .float_literal =&gt; <span class="tok-str">&quot;a floating point literal&quot;</span>,</span>
<span class="line" id="L333">                .doc_comment, .container_doc_comment =&gt; <span class="tok-str">&quot;a document comment&quot;</span>,</span>
<span class="line" id="L334">                <span class="tok-kw">else</span> =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L335">            };</span>
<span class="line" id="L336">        }</span>
<span class="line" id="L337">    };</span>
<span class="line" id="L338">};</span>
<span class="line" id="L339"></span>
<span class="line" id="L340"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> Tokenizer = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L341">    buffer: [:<span class="tok-number">0</span>]<span class="tok-kw">const</span> <span class="tok-type">u8</span>,</span>
<span class="line" id="L342">    index: <span class="tok-type">usize</span>,</span>
<span class="line" id="L343">    pending_invalid_token: ?Token,</span>
<span class="line" id="L344"></span>
<span class="line" id="L345">    <span class="tok-comment">/// For debugging purposes</span></span>
<span class="line" id="L346">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">dump</span>(self: *Tokenizer, token: *<span class="tok-kw">const</span> Token) <span class="tok-type">void</span> {</span>
<span class="line" id="L347">        std.debug.print(<span class="tok-str">&quot;{s} \&quot;{s}\&quot;\n&quot;</span>, .{ <span class="tok-builtin">@tagName</span>(token.tag), self.buffer[token.loc.start..token.loc.end] });</span>
<span class="line" id="L348">    }</span>
<span class="line" id="L349"></span>
<span class="line" id="L350">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">init</span>(buffer: [:<span class="tok-number">0</span>]<span class="tok-kw">const</span> <span class="tok-type">u8</span>) Tokenizer {</span>
<span class="line" id="L351">        <span class="tok-comment">// Skip the UTF-8 BOM if present</span>
</span>
<span class="line" id="L352">        <span class="tok-kw">const</span> src_start: <span class="tok-type">usize</span> = <span class="tok-kw">if</span> (std.mem.startsWith(<span class="tok-type">u8</span>, buffer, <span class="tok-str">&quot;\xEF\xBB\xBF&quot;</span>)) <span class="tok-number">3</span> <span class="tok-kw">else</span> <span class="tok-number">0</span>;</span>
<span class="line" id="L353">        <span class="tok-kw">return</span> Tokenizer{</span>
<span class="line" id="L354">            .buffer = buffer,</span>
<span class="line" id="L355">            .index = src_start,</span>
<span class="line" id="L356">            .pending_invalid_token = <span class="tok-null">null</span>,</span>
<span class="line" id="L357">        };</span>
<span class="line" id="L358">    }</span>
<span class="line" id="L359"></span>
<span class="line" id="L360">    <span class="tok-kw">const</span> State = <span class="tok-kw">enum</span> {</span>
<span class="line" id="L361">        start,</span>
<span class="line" id="L362">        identifier,</span>
<span class="line" id="L363">        builtin,</span>
<span class="line" id="L364">        string_literal,</span>
<span class="line" id="L365">        string_literal_backslash,</span>
<span class="line" id="L366">        multiline_string_literal_line,</span>
<span class="line" id="L367">        char_literal,</span>
<span class="line" id="L368">        char_literal_backslash,</span>
<span class="line" id="L369">        char_literal_hex_escape,</span>
<span class="line" id="L370">        char_literal_unicode_escape_saw_u,</span>
<span class="line" id="L371">        char_literal_unicode_escape,</span>
<span class="line" id="L372">        char_literal_unicode_invalid,</span>
<span class="line" id="L373">        char_literal_unicode,</span>
<span class="line" id="L374">        char_literal_end,</span>
<span class="line" id="L375">        backslash,</span>
<span class="line" id="L376">        equal,</span>
<span class="line" id="L377">        bang,</span>
<span class="line" id="L378">        pipe,</span>
<span class="line" id="L379">        minus,</span>
<span class="line" id="L380">        minus_percent,</span>
<span class="line" id="L381">        minus_pipe,</span>
<span class="line" id="L382">        asterisk,</span>
<span class="line" id="L383">        asterisk_percent,</span>
<span class="line" id="L384">        asterisk_pipe,</span>
<span class="line" id="L385">        slash,</span>
<span class="line" id="L386">        line_comment_start,</span>
<span class="line" id="L387">        line_comment,</span>
<span class="line" id="L388">        doc_comment_start,</span>
<span class="line" id="L389">        doc_comment,</span>
<span class="line" id="L390">        zero,</span>
<span class="line" id="L391">        int_literal_dec,</span>
<span class="line" id="L392">        int_literal_dec_no_underscore,</span>
<span class="line" id="L393">        int_literal_bin,</span>
<span class="line" id="L394">        int_literal_bin_no_underscore,</span>
<span class="line" id="L395">        int_literal_oct,</span>
<span class="line" id="L396">        int_literal_oct_no_underscore,</span>
<span class="line" id="L397">        int_literal_hex,</span>
<span class="line" id="L398">        int_literal_hex_no_underscore,</span>
<span class="line" id="L399">        num_dot_dec,</span>
<span class="line" id="L400">        num_dot_hex,</span>
<span class="line" id="L401">        float_fraction_dec,</span>
<span class="line" id="L402">        float_fraction_dec_no_underscore,</span>
<span class="line" id="L403">        float_fraction_hex,</span>
<span class="line" id="L404">        float_fraction_hex_no_underscore,</span>
<span class="line" id="L405">        float_exponent_unsigned,</span>
<span class="line" id="L406">        float_exponent_num,</span>
<span class="line" id="L407">        float_exponent_num_no_underscore,</span>
<span class="line" id="L408">        ampersand,</span>
<span class="line" id="L409">        caret,</span>
<span class="line" id="L410">        percent,</span>
<span class="line" id="L411">        plus,</span>
<span class="line" id="L412">        plus_percent,</span>
<span class="line" id="L413">        plus_pipe,</span>
<span class="line" id="L414">        angle_bracket_left,</span>
<span class="line" id="L415">        angle_bracket_angle_bracket_left,</span>
<span class="line" id="L416">        angle_bracket_angle_bracket_left_pipe,</span>
<span class="line" id="L417">        angle_bracket_right,</span>
<span class="line" id="L418">        angle_bracket_angle_bracket_right,</span>
<span class="line" id="L419">        period,</span>
<span class="line" id="L420">        period_2,</span>
<span class="line" id="L421">        period_asterisk,</span>
<span class="line" id="L422">        saw_at_sign,</span>
<span class="line" id="L423">    };</span>
<span class="line" id="L424"></span>
<span class="line" id="L425">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">next</span>(self: *Tokenizer) Token {</span>
<span class="line" id="L426">        <span class="tok-kw">if</span> (self.pending_invalid_token) |token| {</span>
<span class="line" id="L427">            self.pending_invalid_token = <span class="tok-null">null</span>;</span>
<span class="line" id="L428">            <span class="tok-kw">return</span> token;</span>
<span class="line" id="L429">        }</span>
<span class="line" id="L430">        <span class="tok-kw">var</span> state: State = .start;</span>
<span class="line" id="L431">        <span class="tok-kw">var</span> result = Token{</span>
<span class="line" id="L432">            .tag = .eof,</span>
<span class="line" id="L433">            .loc = .{</span>
<span class="line" id="L434">                .start = self.index,</span>
<span class="line" id="L435">                .end = <span class="tok-null">undefined</span>,</span>
<span class="line" id="L436">            },</span>
<span class="line" id="L437">        };</span>
<span class="line" id="L438">        <span class="tok-kw">var</span> seen_escape_digits: <span class="tok-type">usize</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L439">        <span class="tok-kw">var</span> remaining_code_units: <span class="tok-type">usize</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L440">        <span class="tok-kw">while</span> (<span class="tok-null">true</span>) : (self.index += <span class="tok-number">1</span>) {</span>
<span class="line" id="L441">            <span class="tok-kw">const</span> c = self.buffer[self.index];</span>
<span class="line" id="L442">            <span class="tok-kw">switch</span> (state) {</span>
<span class="line" id="L443">                .start =&gt; <span class="tok-kw">switch</span> (c) {</span>
<span class="line" id="L444">                    <span class="tok-number">0</span> =&gt; <span class="tok-kw">break</span>,</span>
<span class="line" id="L445">                    <span class="tok-str">' '</span>, <span class="tok-str">'\n'</span>, <span class="tok-str">'\t'</span>, <span class="tok-str">'\r'</span> =&gt; {</span>
<span class="line" id="L446">                        result.loc.start = self.index + <span class="tok-number">1</span>;</span>
<span class="line" id="L447">                    },</span>
<span class="line" id="L448">                    <span class="tok-str">'&quot;'</span> =&gt; {</span>
<span class="line" id="L449">                        state = .string_literal;</span>
<span class="line" id="L450">                        result.tag = .string_literal;</span>
<span class="line" id="L451">                    },</span>
<span class="line" id="L452">                    <span class="tok-str">'\''</span> =&gt; {</span>
<span class="line" id="L453">                        state = .char_literal;</span>
<span class="line" id="L454">                    },</span>
<span class="line" id="L455">                    <span class="tok-str">'a'</span>...<span class="tok-str">'z'</span>, <span class="tok-str">'A'</span>...<span class="tok-str">'Z'</span>, <span class="tok-str">'_'</span> =&gt; {</span>
<span class="line" id="L456">                        state = .identifier;</span>
<span class="line" id="L457">                        result.tag = .identifier;</span>
<span class="line" id="L458">                    },</span>
<span class="line" id="L459">                    <span class="tok-str">'@'</span> =&gt; {</span>
<span class="line" id="L460">                        state = .saw_at_sign;</span>
<span class="line" id="L461">                    },</span>
<span class="line" id="L462">                    <span class="tok-str">'='</span> =&gt; {</span>
<span class="line" id="L463">                        state = .equal;</span>
<span class="line" id="L464">                    },</span>
<span class="line" id="L465">                    <span class="tok-str">'!'</span> =&gt; {</span>
<span class="line" id="L466">                        state = .bang;</span>
<span class="line" id="L467">                    },</span>
<span class="line" id="L468">                    <span class="tok-str">'|'</span> =&gt; {</span>
<span class="line" id="L469">                        state = .pipe;</span>
<span class="line" id="L470">                    },</span>
<span class="line" id="L471">                    <span class="tok-str">'('</span> =&gt; {</span>
<span class="line" id="L472">                        result.tag = .l_paren;</span>
<span class="line" id="L473">                        self.index += <span class="tok-number">1</span>;</span>
<span class="line" id="L474">                        <span class="tok-kw">break</span>;</span>
<span class="line" id="L475">                    },</span>
<span class="line" id="L476">                    <span class="tok-str">')'</span> =&gt; {</span>
<span class="line" id="L477">                        result.tag = .r_paren;</span>
<span class="line" id="L478">                        self.index += <span class="tok-number">1</span>;</span>
<span class="line" id="L479">                        <span class="tok-kw">break</span>;</span>
<span class="line" id="L480">                    },</span>
<span class="line" id="L481">                    <span class="tok-str">'['</span> =&gt; {</span>
<span class="line" id="L482">                        result.tag = .l_bracket;</span>
<span class="line" id="L483">                        self.index += <span class="tok-number">1</span>;</span>
<span class="line" id="L484">                        <span class="tok-kw">break</span>;</span>
<span class="line" id="L485">                    },</span>
<span class="line" id="L486">                    <span class="tok-str">']'</span> =&gt; {</span>
<span class="line" id="L487">                        result.tag = .r_bracket;</span>
<span class="line" id="L488">                        self.index += <span class="tok-number">1</span>;</span>
<span class="line" id="L489">                        <span class="tok-kw">break</span>;</span>
<span class="line" id="L490">                    },</span>
<span class="line" id="L491">                    <span class="tok-str">';'</span> =&gt; {</span>
<span class="line" id="L492">                        result.tag = .semicolon;</span>
<span class="line" id="L493">                        self.index += <span class="tok-number">1</span>;</span>
<span class="line" id="L494">                        <span class="tok-kw">break</span>;</span>
<span class="line" id="L495">                    },</span>
<span class="line" id="L496">                    <span class="tok-str">','</span> =&gt; {</span>
<span class="line" id="L497">                        result.tag = .comma;</span>
<span class="line" id="L498">                        self.index += <span class="tok-number">1</span>;</span>
<span class="line" id="L499">                        <span class="tok-kw">break</span>;</span>
<span class="line" id="L500">                    },</span>
<span class="line" id="L501">                    <span class="tok-str">'?'</span> =&gt; {</span>
<span class="line" id="L502">                        result.tag = .question_mark;</span>
<span class="line" id="L503">                        self.index += <span class="tok-number">1</span>;</span>
<span class="line" id="L504">                        <span class="tok-kw">break</span>;</span>
<span class="line" id="L505">                    },</span>
<span class="line" id="L506">                    <span class="tok-str">':'</span> =&gt; {</span>
<span class="line" id="L507">                        result.tag = .colon;</span>
<span class="line" id="L508">                        self.index += <span class="tok-number">1</span>;</span>
<span class="line" id="L509">                        <span class="tok-kw">break</span>;</span>
<span class="line" id="L510">                    },</span>
<span class="line" id="L511">                    <span class="tok-str">'%'</span> =&gt; {</span>
<span class="line" id="L512">                        state = .percent;</span>
<span class="line" id="L513">                    },</span>
<span class="line" id="L514">                    <span class="tok-str">'*'</span> =&gt; {</span>
<span class="line" id="L515">                        state = .asterisk;</span>
<span class="line" id="L516">                    },</span>
<span class="line" id="L517">                    <span class="tok-str">'+'</span> =&gt; {</span>
<span class="line" id="L518">                        state = .plus;</span>
<span class="line" id="L519">                    },</span>
<span class="line" id="L520">                    <span class="tok-str">'&lt;'</span> =&gt; {</span>
<span class="line" id="L521">                        state = .angle_bracket_left;</span>
<span class="line" id="L522">                    },</span>
<span class="line" id="L523">                    <span class="tok-str">'&gt;'</span> =&gt; {</span>
<span class="line" id="L524">                        state = .angle_bracket_right;</span>
<span class="line" id="L525">                    },</span>
<span class="line" id="L526">                    <span class="tok-str">'^'</span> =&gt; {</span>
<span class="line" id="L527">                        state = .caret;</span>
<span class="line" id="L528">                    },</span>
<span class="line" id="L529">                    <span class="tok-str">'\\'</span> =&gt; {</span>
<span class="line" id="L530">                        state = .backslash;</span>
<span class="line" id="L531">                        result.tag = .multiline_string_literal_line;</span>
<span class="line" id="L532">                    },</span>
<span class="line" id="L533">                    <span class="tok-str">'{'</span> =&gt; {</span>
<span class="line" id="L534">                        result.tag = .l_brace;</span>
<span class="line" id="L535">                        self.index += <span class="tok-number">1</span>;</span>
<span class="line" id="L536">                        <span class="tok-kw">break</span>;</span>
<span class="line" id="L537">                    },</span>
<span class="line" id="L538">                    <span class="tok-str">'}'</span> =&gt; {</span>
<span class="line" id="L539">                        result.tag = .r_brace;</span>
<span class="line" id="L540">                        self.index += <span class="tok-number">1</span>;</span>
<span class="line" id="L541">                        <span class="tok-kw">break</span>;</span>
<span class="line" id="L542">                    },</span>
<span class="line" id="L543">                    <span class="tok-str">'~'</span> =&gt; {</span>
<span class="line" id="L544">                        result.tag = .tilde;</span>
<span class="line" id="L545">                        self.index += <span class="tok-number">1</span>;</span>
<span class="line" id="L546">                        <span class="tok-kw">break</span>;</span>
<span class="line" id="L547">                    },</span>
<span class="line" id="L548">                    <span class="tok-str">'.'</span> =&gt; {</span>
<span class="line" id="L549">                        state = .period;</span>
<span class="line" id="L550">                    },</span>
<span class="line" id="L551">                    <span class="tok-str">'-'</span> =&gt; {</span>
<span class="line" id="L552">                        state = .minus;</span>
<span class="line" id="L553">                    },</span>
<span class="line" id="L554">                    <span class="tok-str">'/'</span> =&gt; {</span>
<span class="line" id="L555">                        state = .slash;</span>
<span class="line" id="L556">                    },</span>
<span class="line" id="L557">                    <span class="tok-str">'&amp;'</span> =&gt; {</span>
<span class="line" id="L558">                        state = .ampersand;</span>
<span class="line" id="L559">                    },</span>
<span class="line" id="L560">                    <span class="tok-str">'0'</span> =&gt; {</span>
<span class="line" id="L561">                        state = .zero;</span>
<span class="line" id="L562">                        result.tag = .integer_literal;</span>
<span class="line" id="L563">                    },</span>
<span class="line" id="L564">                    <span class="tok-str">'1'</span>...<span class="tok-str">'9'</span> =&gt; {</span>
<span class="line" id="L565">                        state = .int_literal_dec;</span>
<span class="line" id="L566">                        result.tag = .integer_literal;</span>
<span class="line" id="L567">                    },</span>
<span class="line" id="L568">                    <span class="tok-kw">else</span> =&gt; {</span>
<span class="line" id="L569">                        result.tag = .invalid;</span>
<span class="line" id="L570">                        result.loc.end = self.index;</span>
<span class="line" id="L571">                        self.index += <span class="tok-number">1</span>;</span>
<span class="line" id="L572">                        <span class="tok-kw">return</span> result;</span>
<span class="line" id="L573">                    },</span>
<span class="line" id="L574">                },</span>
<span class="line" id="L575"></span>
<span class="line" id="L576">                .saw_at_sign =&gt; <span class="tok-kw">switch</span> (c) {</span>
<span class="line" id="L577">                    <span class="tok-str">'&quot;'</span> =&gt; {</span>
<span class="line" id="L578">                        result.tag = .identifier;</span>
<span class="line" id="L579">                        state = .string_literal;</span>
<span class="line" id="L580">                    },</span>
<span class="line" id="L581">                    <span class="tok-str">'a'</span>...<span class="tok-str">'z'</span>, <span class="tok-str">'A'</span>...<span class="tok-str">'Z'</span>, <span class="tok-str">'_'</span> =&gt; {</span>
<span class="line" id="L582">                        state = .builtin;</span>
<span class="line" id="L583">                        result.tag = .builtin;</span>
<span class="line" id="L584">                    },</span>
<span class="line" id="L585">                    <span class="tok-kw">else</span> =&gt; {</span>
<span class="line" id="L586">                        result.tag = .invalid;</span>
<span class="line" id="L587">                        <span class="tok-kw">break</span>;</span>
<span class="line" id="L588">                    },</span>
<span class="line" id="L589">                },</span>
<span class="line" id="L590"></span>
<span class="line" id="L591">                .ampersand =&gt; <span class="tok-kw">switch</span> (c) {</span>
<span class="line" id="L592">                    <span class="tok-str">'='</span> =&gt; {</span>
<span class="line" id="L593">                        result.tag = .ampersand_equal;</span>
<span class="line" id="L594">                        self.index += <span class="tok-number">1</span>;</span>
<span class="line" id="L595">                        <span class="tok-kw">break</span>;</span>
<span class="line" id="L596">                    },</span>
<span class="line" id="L597">                    <span class="tok-kw">else</span> =&gt; {</span>
<span class="line" id="L598">                        result.tag = .ampersand;</span>
<span class="line" id="L599">                        <span class="tok-kw">break</span>;</span>
<span class="line" id="L600">                    },</span>
<span class="line" id="L601">                },</span>
<span class="line" id="L602"></span>
<span class="line" id="L603">                .asterisk =&gt; <span class="tok-kw">switch</span> (c) {</span>
<span class="line" id="L604">                    <span class="tok-str">'='</span> =&gt; {</span>
<span class="line" id="L605">                        result.tag = .asterisk_equal;</span>
<span class="line" id="L606">                        self.index += <span class="tok-number">1</span>;</span>
<span class="line" id="L607">                        <span class="tok-kw">break</span>;</span>
<span class="line" id="L608">                    },</span>
<span class="line" id="L609">                    <span class="tok-str">'*'</span> =&gt; {</span>
<span class="line" id="L610">                        result.tag = .asterisk_asterisk;</span>
<span class="line" id="L611">                        self.index += <span class="tok-number">1</span>;</span>
<span class="line" id="L612">                        <span class="tok-kw">break</span>;</span>
<span class="line" id="L613">                    },</span>
<span class="line" id="L614">                    <span class="tok-str">'%'</span> =&gt; {</span>
<span class="line" id="L615">                        state = .asterisk_percent;</span>
<span class="line" id="L616">                    },</span>
<span class="line" id="L617">                    <span class="tok-str">'|'</span> =&gt; {</span>
<span class="line" id="L618">                        state = .asterisk_pipe;</span>
<span class="line" id="L619">                    },</span>
<span class="line" id="L620">                    <span class="tok-kw">else</span> =&gt; {</span>
<span class="line" id="L621">                        result.tag = .asterisk;</span>
<span class="line" id="L622">                        <span class="tok-kw">break</span>;</span>
<span class="line" id="L623">                    },</span>
<span class="line" id="L624">                },</span>
<span class="line" id="L625"></span>
<span class="line" id="L626">                .asterisk_percent =&gt; <span class="tok-kw">switch</span> (c) {</span>
<span class="line" id="L627">                    <span class="tok-str">'='</span> =&gt; {</span>
<span class="line" id="L628">                        result.tag = .asterisk_percent_equal;</span>
<span class="line" id="L629">                        self.index += <span class="tok-number">1</span>;</span>
<span class="line" id="L630">                        <span class="tok-kw">break</span>;</span>
<span class="line" id="L631">                    },</span>
<span class="line" id="L632">                    <span class="tok-kw">else</span> =&gt; {</span>
<span class="line" id="L633">                        result.tag = .asterisk_percent;</span>
<span class="line" id="L634">                        <span class="tok-kw">break</span>;</span>
<span class="line" id="L635">                    },</span>
<span class="line" id="L636">                },</span>
<span class="line" id="L637"></span>
<span class="line" id="L638">                .asterisk_pipe =&gt; <span class="tok-kw">switch</span> (c) {</span>
<span class="line" id="L639">                    <span class="tok-str">'='</span> =&gt; {</span>
<span class="line" id="L640">                        result.tag = .asterisk_pipe_equal;</span>
<span class="line" id="L641">                        self.index += <span class="tok-number">1</span>;</span>
<span class="line" id="L642">                        <span class="tok-kw">break</span>;</span>
<span class="line" id="L643">                    },</span>
<span class="line" id="L644">                    <span class="tok-kw">else</span> =&gt; {</span>
<span class="line" id="L645">                        result.tag = .asterisk_pipe;</span>
<span class="line" id="L646">                        <span class="tok-kw">break</span>;</span>
<span class="line" id="L647">                    },</span>
<span class="line" id="L648">                },</span>
<span class="line" id="L649"></span>
<span class="line" id="L650">                .percent =&gt; <span class="tok-kw">switch</span> (c) {</span>
<span class="line" id="L651">                    <span class="tok-str">'='</span> =&gt; {</span>
<span class="line" id="L652">                        result.tag = .percent_equal;</span>
<span class="line" id="L653">                        self.index += <span class="tok-number">1</span>;</span>
<span class="line" id="L654">                        <span class="tok-kw">break</span>;</span>
<span class="line" id="L655">                    },</span>
<span class="line" id="L656">                    <span class="tok-kw">else</span> =&gt; {</span>
<span class="line" id="L657">                        result.tag = .percent;</span>
<span class="line" id="L658">                        <span class="tok-kw">break</span>;</span>
<span class="line" id="L659">                    },</span>
<span class="line" id="L660">                },</span>
<span class="line" id="L661"></span>
<span class="line" id="L662">                .plus =&gt; <span class="tok-kw">switch</span> (c) {</span>
<span class="line" id="L663">                    <span class="tok-str">'='</span> =&gt; {</span>
<span class="line" id="L664">                        result.tag = .plus_equal;</span>
<span class="line" id="L665">                        self.index += <span class="tok-number">1</span>;</span>
<span class="line" id="L666">                        <span class="tok-kw">break</span>;</span>
<span class="line" id="L667">                    },</span>
<span class="line" id="L668">                    <span class="tok-str">'+'</span> =&gt; {</span>
<span class="line" id="L669">                        result.tag = .plus_plus;</span>
<span class="line" id="L670">                        self.index += <span class="tok-number">1</span>;</span>
<span class="line" id="L671">                        <span class="tok-kw">break</span>;</span>
<span class="line" id="L672">                    },</span>
<span class="line" id="L673">                    <span class="tok-str">'%'</span> =&gt; {</span>
<span class="line" id="L674">                        state = .plus_percent;</span>
<span class="line" id="L675">                    },</span>
<span class="line" id="L676">                    <span class="tok-str">'|'</span> =&gt; {</span>
<span class="line" id="L677">                        state = .plus_pipe;</span>
<span class="line" id="L678">                    },</span>
<span class="line" id="L679">                    <span class="tok-kw">else</span> =&gt; {</span>
<span class="line" id="L680">                        result.tag = .plus;</span>
<span class="line" id="L681">                        <span class="tok-kw">break</span>;</span>
<span class="line" id="L682">                    },</span>
<span class="line" id="L683">                },</span>
<span class="line" id="L684"></span>
<span class="line" id="L685">                .plus_percent =&gt; <span class="tok-kw">switch</span> (c) {</span>
<span class="line" id="L686">                    <span class="tok-str">'='</span> =&gt; {</span>
<span class="line" id="L687">                        result.tag = .plus_percent_equal;</span>
<span class="line" id="L688">                        self.index += <span class="tok-number">1</span>;</span>
<span class="line" id="L689">                        <span class="tok-kw">break</span>;</span>
<span class="line" id="L690">                    },</span>
<span class="line" id="L691">                    <span class="tok-kw">else</span> =&gt; {</span>
<span class="line" id="L692">                        result.tag = .plus_percent;</span>
<span class="line" id="L693">                        <span class="tok-kw">break</span>;</span>
<span class="line" id="L694">                    },</span>
<span class="line" id="L695">                },</span>
<span class="line" id="L696"></span>
<span class="line" id="L697">                .plus_pipe =&gt; <span class="tok-kw">switch</span> (c) {</span>
<span class="line" id="L698">                    <span class="tok-str">'='</span> =&gt; {</span>
<span class="line" id="L699">                        result.tag = .plus_pipe_equal;</span>
<span class="line" id="L700">                        self.index += <span class="tok-number">1</span>;</span>
<span class="line" id="L701">                        <span class="tok-kw">break</span>;</span>
<span class="line" id="L702">                    },</span>
<span class="line" id="L703">                    <span class="tok-kw">else</span> =&gt; {</span>
<span class="line" id="L704">                        result.tag = .plus_pipe;</span>
<span class="line" id="L705">                        <span class="tok-kw">break</span>;</span>
<span class="line" id="L706">                    },</span>
<span class="line" id="L707">                },</span>
<span class="line" id="L708"></span>
<span class="line" id="L709">                .caret =&gt; <span class="tok-kw">switch</span> (c) {</span>
<span class="line" id="L710">                    <span class="tok-str">'='</span> =&gt; {</span>
<span class="line" id="L711">                        result.tag = .caret_equal;</span>
<span class="line" id="L712">                        self.index += <span class="tok-number">1</span>;</span>
<span class="line" id="L713">                        <span class="tok-kw">break</span>;</span>
<span class="line" id="L714">                    },</span>
<span class="line" id="L715">                    <span class="tok-kw">else</span> =&gt; {</span>
<span class="line" id="L716">                        result.tag = .caret;</span>
<span class="line" id="L717">                        <span class="tok-kw">break</span>;</span>
<span class="line" id="L718">                    },</span>
<span class="line" id="L719">                },</span>
<span class="line" id="L720"></span>
<span class="line" id="L721">                .identifier =&gt; <span class="tok-kw">switch</span> (c) {</span>
<span class="line" id="L722">                    <span class="tok-str">'a'</span>...<span class="tok-str">'z'</span>, <span class="tok-str">'A'</span>...<span class="tok-str">'Z'</span>, <span class="tok-str">'_'</span>, <span class="tok-str">'0'</span>...<span class="tok-str">'9'</span> =&gt; {},</span>
<span class="line" id="L723">                    <span class="tok-kw">else</span> =&gt; {</span>
<span class="line" id="L724">                        <span class="tok-kw">if</span> (Token.getKeyword(self.buffer[result.loc.start..self.index])) |tag| {</span>
<span class="line" id="L725">                            result.tag = tag;</span>
<span class="line" id="L726">                        }</span>
<span class="line" id="L727">                        <span class="tok-kw">break</span>;</span>
<span class="line" id="L728">                    },</span>
<span class="line" id="L729">                },</span>
<span class="line" id="L730">                .builtin =&gt; <span class="tok-kw">switch</span> (c) {</span>
<span class="line" id="L731">                    <span class="tok-str">'a'</span>...<span class="tok-str">'z'</span>, <span class="tok-str">'A'</span>...<span class="tok-str">'Z'</span>, <span class="tok-str">'_'</span>, <span class="tok-str">'0'</span>...<span class="tok-str">'9'</span> =&gt; {},</span>
<span class="line" id="L732">                    <span class="tok-kw">else</span> =&gt; <span class="tok-kw">break</span>,</span>
<span class="line" id="L733">                },</span>
<span class="line" id="L734">                .backslash =&gt; <span class="tok-kw">switch</span> (c) {</span>
<span class="line" id="L735">                    <span class="tok-str">'\\'</span> =&gt; {</span>
<span class="line" id="L736">                        state = .multiline_string_literal_line;</span>
<span class="line" id="L737">                    },</span>
<span class="line" id="L738">                    <span class="tok-kw">else</span> =&gt; {</span>
<span class="line" id="L739">                        result.tag = .invalid;</span>
<span class="line" id="L740">                        <span class="tok-kw">break</span>;</span>
<span class="line" id="L741">                    },</span>
<span class="line" id="L742">                },</span>
<span class="line" id="L743">                .string_literal =&gt; <span class="tok-kw">switch</span> (c) {</span>
<span class="line" id="L744">                    <span class="tok-str">'\\'</span> =&gt; {</span>
<span class="line" id="L745">                        state = .string_literal_backslash;</span>
<span class="line" id="L746">                    },</span>
<span class="line" id="L747">                    <span class="tok-str">'&quot;'</span> =&gt; {</span>
<span class="line" id="L748">                        self.index += <span class="tok-number">1</span>;</span>
<span class="line" id="L749">                        <span class="tok-kw">break</span>;</span>
<span class="line" id="L750">                    },</span>
<span class="line" id="L751">                    <span class="tok-number">0</span> =&gt; {</span>
<span class="line" id="L752">                        <span class="tok-kw">if</span> (self.index == self.buffer.len) {</span>
<span class="line" id="L753">                            <span class="tok-kw">break</span>;</span>
<span class="line" id="L754">                        } <span class="tok-kw">else</span> {</span>
<span class="line" id="L755">                            self.checkLiteralCharacter();</span>
<span class="line" id="L756">                        }</span>
<span class="line" id="L757">                    },</span>
<span class="line" id="L758">                    <span class="tok-str">'\n'</span> =&gt; {</span>
<span class="line" id="L759">                        result.tag = .invalid;</span>
<span class="line" id="L760">                        <span class="tok-kw">break</span>;</span>
<span class="line" id="L761">                    },</span>
<span class="line" id="L762">                    <span class="tok-kw">else</span> =&gt; self.checkLiteralCharacter(),</span>
<span class="line" id="L763">                },</span>
<span class="line" id="L764"></span>
<span class="line" id="L765">                .string_literal_backslash =&gt; <span class="tok-kw">switch</span> (c) {</span>
<span class="line" id="L766">                    <span class="tok-number">0</span>, <span class="tok-str">'\n'</span> =&gt; {</span>
<span class="line" id="L767">                        result.tag = .invalid;</span>
<span class="line" id="L768">                        <span class="tok-kw">break</span>;</span>
<span class="line" id="L769">                    },</span>
<span class="line" id="L770">                    <span class="tok-kw">else</span> =&gt; {</span>
<span class="line" id="L771">                        state = .string_literal;</span>
<span class="line" id="L772">                    },</span>
<span class="line" id="L773">                },</span>
<span class="line" id="L774"></span>
<span class="line" id="L775">                .char_literal =&gt; <span class="tok-kw">switch</span> (c) {</span>
<span class="line" id="L776">                    <span class="tok-number">0</span> =&gt; {</span>
<span class="line" id="L777">                        result.tag = .invalid;</span>
<span class="line" id="L778">                        <span class="tok-kw">break</span>;</span>
<span class="line" id="L779">                    },</span>
<span class="line" id="L780">                    <span class="tok-str">'\\'</span> =&gt; {</span>
<span class="line" id="L781">                        state = .char_literal_backslash;</span>
<span class="line" id="L782">                    },</span>
<span class="line" id="L783">                    <span class="tok-str">'\''</span>, <span class="tok-number">0x80</span>...<span class="tok-number">0xbf</span>, <span class="tok-number">0xf8</span>...<span class="tok-number">0xff</span> =&gt; {</span>
<span class="line" id="L784">                        result.tag = .invalid;</span>
<span class="line" id="L785">                        <span class="tok-kw">break</span>;</span>
<span class="line" id="L786">                    },</span>
<span class="line" id="L787">                    <span class="tok-number">0xc0</span>...<span class="tok-number">0xdf</span> =&gt; { <span class="tok-comment">// 110xxxxx</span>
</span>
<span class="line" id="L788">                        remaining_code_units = <span class="tok-number">1</span>;</span>
<span class="line" id="L789">                        state = .char_literal_unicode;</span>
<span class="line" id="L790">                    },</span>
<span class="line" id="L791">                    <span class="tok-number">0xe0</span>...<span class="tok-number">0xef</span> =&gt; { <span class="tok-comment">// 1110xxxx</span>
</span>
<span class="line" id="L792">                        remaining_code_units = <span class="tok-number">2</span>;</span>
<span class="line" id="L793">                        state = .char_literal_unicode;</span>
<span class="line" id="L794">                    },</span>
<span class="line" id="L795">                    <span class="tok-number">0xf0</span>...<span class="tok-number">0xf7</span> =&gt; { <span class="tok-comment">// 11110xxx</span>
</span>
<span class="line" id="L796">                        remaining_code_units = <span class="tok-number">3</span>;</span>
<span class="line" id="L797">                        state = .char_literal_unicode;</span>
<span class="line" id="L798">                    },</span>
<span class="line" id="L799">                    <span class="tok-str">'\n'</span> =&gt; {</span>
<span class="line" id="L800">                        result.tag = .invalid;</span>
<span class="line" id="L801">                        <span class="tok-kw">break</span>;</span>
<span class="line" id="L802">                    },</span>
<span class="line" id="L803">                    <span class="tok-kw">else</span> =&gt; {</span>
<span class="line" id="L804">                        state = .char_literal_end;</span>
<span class="line" id="L805">                    },</span>
<span class="line" id="L806">                },</span>
<span class="line" id="L807"></span>
<span class="line" id="L808">                .char_literal_backslash =&gt; <span class="tok-kw">switch</span> (c) {</span>
<span class="line" id="L809">                    <span class="tok-number">0</span>, <span class="tok-str">'\n'</span> =&gt; {</span>
<span class="line" id="L810">                        result.tag = .invalid;</span>
<span class="line" id="L811">                        <span class="tok-kw">break</span>;</span>
<span class="line" id="L812">                    },</span>
<span class="line" id="L813">                    <span class="tok-str">'x'</span> =&gt; {</span>
<span class="line" id="L814">                        state = .char_literal_hex_escape;</span>
<span class="line" id="L815">                        seen_escape_digits = <span class="tok-number">0</span>;</span>
<span class="line" id="L816">                    },</span>
<span class="line" id="L817">                    <span class="tok-str">'u'</span> =&gt; {</span>
<span class="line" id="L818">                        state = .char_literal_unicode_escape_saw_u;</span>
<span class="line" id="L819">                    },</span>
<span class="line" id="L820">                    <span class="tok-kw">else</span> =&gt; {</span>
<span class="line" id="L821">                        state = .char_literal_end;</span>
<span class="line" id="L822">                    },</span>
<span class="line" id="L823">                },</span>
<span class="line" id="L824"></span>
<span class="line" id="L825">                .char_literal_hex_escape =&gt; <span class="tok-kw">switch</span> (c) {</span>
<span class="line" id="L826">                    <span class="tok-str">'0'</span>...<span class="tok-str">'9'</span>, <span class="tok-str">'a'</span>...<span class="tok-str">'f'</span>, <span class="tok-str">'A'</span>...<span class="tok-str">'F'</span> =&gt; {</span>
<span class="line" id="L827">                        seen_escape_digits += <span class="tok-number">1</span>;</span>
<span class="line" id="L828">                        <span class="tok-kw">if</span> (seen_escape_digits == <span class="tok-number">2</span>) {</span>
<span class="line" id="L829">                            state = .char_literal_end;</span>
<span class="line" id="L830">                        }</span>
<span class="line" id="L831">                    },</span>
<span class="line" id="L832">                    <span class="tok-kw">else</span> =&gt; {</span>
<span class="line" id="L833">                        result.tag = .invalid;</span>
<span class="line" id="L834">                        <span class="tok-kw">break</span>;</span>
<span class="line" id="L835">                    },</span>
<span class="line" id="L836">                },</span>
<span class="line" id="L837"></span>
<span class="line" id="L838">                .char_literal_unicode_escape_saw_u =&gt; <span class="tok-kw">switch</span> (c) {</span>
<span class="line" id="L839">                    <span class="tok-number">0</span> =&gt; {</span>
<span class="line" id="L840">                        result.tag = .invalid;</span>
<span class="line" id="L841">                        <span class="tok-kw">break</span>;</span>
<span class="line" id="L842">                    },</span>
<span class="line" id="L843">                    <span class="tok-str">'{'</span> =&gt; {</span>
<span class="line" id="L844">                        state = .char_literal_unicode_escape;</span>
<span class="line" id="L845">                    },</span>
<span class="line" id="L846">                    <span class="tok-kw">else</span> =&gt; {</span>
<span class="line" id="L847">                        result.tag = .invalid;</span>
<span class="line" id="L848">                        state = .char_literal_unicode_invalid;</span>
<span class="line" id="L849">                    },</span>
<span class="line" id="L850">                },</span>
<span class="line" id="L851"></span>
<span class="line" id="L852">                .char_literal_unicode_escape =&gt; <span class="tok-kw">switch</span> (c) {</span>
<span class="line" id="L853">                    <span class="tok-number">0</span> =&gt; {</span>
<span class="line" id="L854">                        result.tag = .invalid;</span>
<span class="line" id="L855">                        <span class="tok-kw">break</span>;</span>
<span class="line" id="L856">                    },</span>
<span class="line" id="L857">                    <span class="tok-str">'0'</span>...<span class="tok-str">'9'</span>, <span class="tok-str">'a'</span>...<span class="tok-str">'f'</span>, <span class="tok-str">'A'</span>...<span class="tok-str">'F'</span> =&gt; {},</span>
<span class="line" id="L858">                    <span class="tok-str">'}'</span> =&gt; {</span>
<span class="line" id="L859">                        state = .char_literal_end; <span class="tok-comment">// too many/few digits handled later</span>
</span>
<span class="line" id="L860">                    },</span>
<span class="line" id="L861">                    <span class="tok-kw">else</span> =&gt; {</span>
<span class="line" id="L862">                        result.tag = .invalid;</span>
<span class="line" id="L863">                        state = .char_literal_unicode_invalid;</span>
<span class="line" id="L864">                    },</span>
<span class="line" id="L865">                },</span>
<span class="line" id="L866"></span>
<span class="line" id="L867">                .char_literal_unicode_invalid =&gt; <span class="tok-kw">switch</span> (c) {</span>
<span class="line" id="L868">                    <span class="tok-comment">// Keep consuming characters until an obvious stopping point.</span>
</span>
<span class="line" id="L869">                    <span class="tok-comment">// This consolidates e.g. `u{0ab1Q}` into a single invalid token</span>
</span>
<span class="line" id="L870">                    <span class="tok-comment">// instead of creating the tokens `u{0ab1`, `Q`, `}`</span>
</span>
<span class="line" id="L871">                    <span class="tok-str">'0'</span>...<span class="tok-str">'9'</span>, <span class="tok-str">'a'</span>...<span class="tok-str">'z'</span>, <span class="tok-str">'A'</span>...<span class="tok-str">'Z'</span>, <span class="tok-str">'}'</span> =&gt; {},</span>
<span class="line" id="L872">                    <span class="tok-kw">else</span> =&gt; <span class="tok-kw">break</span>,</span>
<span class="line" id="L873">                },</span>
<span class="line" id="L874"></span>
<span class="line" id="L875">                .char_literal_end =&gt; <span class="tok-kw">switch</span> (c) {</span>
<span class="line" id="L876">                    <span class="tok-str">'\''</span> =&gt; {</span>
<span class="line" id="L877">                        result.tag = .char_literal;</span>
<span class="line" id="L878">                        self.index += <span class="tok-number">1</span>;</span>
<span class="line" id="L879">                        <span class="tok-kw">break</span>;</span>
<span class="line" id="L880">                    },</span>
<span class="line" id="L881">                    <span class="tok-kw">else</span> =&gt; {</span>
<span class="line" id="L882">                        result.tag = .invalid;</span>
<span class="line" id="L883">                        <span class="tok-kw">break</span>;</span>
<span class="line" id="L884">                    },</span>
<span class="line" id="L885">                },</span>
<span class="line" id="L886"></span>
<span class="line" id="L887">                .char_literal_unicode =&gt; <span class="tok-kw">switch</span> (c) {</span>
<span class="line" id="L888">                    <span class="tok-number">0x80</span>...<span class="tok-number">0xbf</span> =&gt; {</span>
<span class="line" id="L889">                        remaining_code_units -= <span class="tok-number">1</span>;</span>
<span class="line" id="L890">                        <span class="tok-kw">if</span> (remaining_code_units == <span class="tok-number">0</span>) {</span>
<span class="line" id="L891">                            state = .char_literal_end;</span>
<span class="line" id="L892">                        }</span>
<span class="line" id="L893">                    },</span>
<span class="line" id="L894">                    <span class="tok-kw">else</span> =&gt; {</span>
<span class="line" id="L895">                        result.tag = .invalid;</span>
<span class="line" id="L896">                        <span class="tok-kw">break</span>;</span>
<span class="line" id="L897">                    },</span>
<span class="line" id="L898">                },</span>
<span class="line" id="L899"></span>
<span class="line" id="L900">                .multiline_string_literal_line =&gt; <span class="tok-kw">switch</span> (c) {</span>
<span class="line" id="L901">                    <span class="tok-number">0</span> =&gt; <span class="tok-kw">break</span>,</span>
<span class="line" id="L902">                    <span class="tok-str">'\n'</span> =&gt; {</span>
<span class="line" id="L903">                        self.index += <span class="tok-number">1</span>;</span>
<span class="line" id="L904">                        <span class="tok-kw">break</span>;</span>
<span class="line" id="L905">                    },</span>
<span class="line" id="L906">                    <span class="tok-str">'\t'</span> =&gt; {},</span>
<span class="line" id="L907">                    <span class="tok-kw">else</span> =&gt; self.checkLiteralCharacter(),</span>
<span class="line" id="L908">                },</span>
<span class="line" id="L909"></span>
<span class="line" id="L910">                .bang =&gt; <span class="tok-kw">switch</span> (c) {</span>
<span class="line" id="L911">                    <span class="tok-str">'='</span> =&gt; {</span>
<span class="line" id="L912">                        result.tag = .bang_equal;</span>
<span class="line" id="L913">                        self.index += <span class="tok-number">1</span>;</span>
<span class="line" id="L914">                        <span class="tok-kw">break</span>;</span>
<span class="line" id="L915">                    },</span>
<span class="line" id="L916">                    <span class="tok-kw">else</span> =&gt; {</span>
<span class="line" id="L917">                        result.tag = .bang;</span>
<span class="line" id="L918">                        <span class="tok-kw">break</span>;</span>
<span class="line" id="L919">                    },</span>
<span class="line" id="L920">                },</span>
<span class="line" id="L921"></span>
<span class="line" id="L922">                .pipe =&gt; <span class="tok-kw">switch</span> (c) {</span>
<span class="line" id="L923">                    <span class="tok-str">'='</span> =&gt; {</span>
<span class="line" id="L924">                        result.tag = .pipe_equal;</span>
<span class="line" id="L925">                        self.index += <span class="tok-number">1</span>;</span>
<span class="line" id="L926">                        <span class="tok-kw">break</span>;</span>
<span class="line" id="L927">                    },</span>
<span class="line" id="L928">                    <span class="tok-str">'|'</span> =&gt; {</span>
<span class="line" id="L929">                        result.tag = .pipe_pipe;</span>
<span class="line" id="L930">                        self.index += <span class="tok-number">1</span>;</span>
<span class="line" id="L931">                        <span class="tok-kw">break</span>;</span>
<span class="line" id="L932">                    },</span>
<span class="line" id="L933">                    <span class="tok-kw">else</span> =&gt; {</span>
<span class="line" id="L934">                        result.tag = .pipe;</span>
<span class="line" id="L935">                        <span class="tok-kw">break</span>;</span>
<span class="line" id="L936">                    },</span>
<span class="line" id="L937">                },</span>
<span class="line" id="L938"></span>
<span class="line" id="L939">                .equal =&gt; <span class="tok-kw">switch</span> (c) {</span>
<span class="line" id="L940">                    <span class="tok-str">'='</span> =&gt; {</span>
<span class="line" id="L941">                        result.tag = .equal_equal;</span>
<span class="line" id="L942">                        self.index += <span class="tok-number">1</span>;</span>
<span class="line" id="L943">                        <span class="tok-kw">break</span>;</span>
<span class="line" id="L944">                    },</span>
<span class="line" id="L945">                    <span class="tok-str">'&gt;'</span> =&gt; {</span>
<span class="line" id="L946">                        result.tag = .equal_angle_bracket_right;</span>
<span class="line" id="L947">                        self.index += <span class="tok-number">1</span>;</span>
<span class="line" id="L948">                        <span class="tok-kw">break</span>;</span>
<span class="line" id="L949">                    },</span>
<span class="line" id="L950">                    <span class="tok-kw">else</span> =&gt; {</span>
<span class="line" id="L951">                        result.tag = .equal;</span>
<span class="line" id="L952">                        <span class="tok-kw">break</span>;</span>
<span class="line" id="L953">                    },</span>
<span class="line" id="L954">                },</span>
<span class="line" id="L955"></span>
<span class="line" id="L956">                .minus =&gt; <span class="tok-kw">switch</span> (c) {</span>
<span class="line" id="L957">                    <span class="tok-str">'&gt;'</span> =&gt; {</span>
<span class="line" id="L958">                        result.tag = .arrow;</span>
<span class="line" id="L959">                        self.index += <span class="tok-number">1</span>;</span>
<span class="line" id="L960">                        <span class="tok-kw">break</span>;</span>
<span class="line" id="L961">                    },</span>
<span class="line" id="L962">                    <span class="tok-str">'='</span> =&gt; {</span>
<span class="line" id="L963">                        result.tag = .minus_equal;</span>
<span class="line" id="L964">                        self.index += <span class="tok-number">1</span>;</span>
<span class="line" id="L965">                        <span class="tok-kw">break</span>;</span>
<span class="line" id="L966">                    },</span>
<span class="line" id="L967">                    <span class="tok-str">'%'</span> =&gt; {</span>
<span class="line" id="L968">                        state = .minus_percent;</span>
<span class="line" id="L969">                    },</span>
<span class="line" id="L970">                    <span class="tok-str">'|'</span> =&gt; {</span>
<span class="line" id="L971">                        state = .minus_pipe;</span>
<span class="line" id="L972">                    },</span>
<span class="line" id="L973">                    <span class="tok-kw">else</span> =&gt; {</span>
<span class="line" id="L974">                        result.tag = .minus;</span>
<span class="line" id="L975">                        <span class="tok-kw">break</span>;</span>
<span class="line" id="L976">                    },</span>
<span class="line" id="L977">                },</span>
<span class="line" id="L978"></span>
<span class="line" id="L979">                .minus_percent =&gt; <span class="tok-kw">switch</span> (c) {</span>
<span class="line" id="L980">                    <span class="tok-str">'='</span> =&gt; {</span>
<span class="line" id="L981">                        result.tag = .minus_percent_equal;</span>
<span class="line" id="L982">                        self.index += <span class="tok-number">1</span>;</span>
<span class="line" id="L983">                        <span class="tok-kw">break</span>;</span>
<span class="line" id="L984">                    },</span>
<span class="line" id="L985">                    <span class="tok-kw">else</span> =&gt; {</span>
<span class="line" id="L986">                        result.tag = .minus_percent;</span>
<span class="line" id="L987">                        <span class="tok-kw">break</span>;</span>
<span class="line" id="L988">                    },</span>
<span class="line" id="L989">                },</span>
<span class="line" id="L990">                .minus_pipe =&gt; <span class="tok-kw">switch</span> (c) {</span>
<span class="line" id="L991">                    <span class="tok-str">'='</span> =&gt; {</span>
<span class="line" id="L992">                        result.tag = .minus_pipe_equal;</span>
<span class="line" id="L993">                        self.index += <span class="tok-number">1</span>;</span>
<span class="line" id="L994">                        <span class="tok-kw">break</span>;</span>
<span class="line" id="L995">                    },</span>
<span class="line" id="L996">                    <span class="tok-kw">else</span> =&gt; {</span>
<span class="line" id="L997">                        result.tag = .minus_pipe;</span>
<span class="line" id="L998">                        <span class="tok-kw">break</span>;</span>
<span class="line" id="L999">                    },</span>
<span class="line" id="L1000">                },</span>
<span class="line" id="L1001"></span>
<span class="line" id="L1002">                .angle_bracket_left =&gt; <span class="tok-kw">switch</span> (c) {</span>
<span class="line" id="L1003">                    <span class="tok-str">'&lt;'</span> =&gt; {</span>
<span class="line" id="L1004">                        state = .angle_bracket_angle_bracket_left;</span>
<span class="line" id="L1005">                    },</span>
<span class="line" id="L1006">                    <span class="tok-str">'='</span> =&gt; {</span>
<span class="line" id="L1007">                        result.tag = .angle_bracket_left_equal;</span>
<span class="line" id="L1008">                        self.index += <span class="tok-number">1</span>;</span>
<span class="line" id="L1009">                        <span class="tok-kw">break</span>;</span>
<span class="line" id="L1010">                    },</span>
<span class="line" id="L1011">                    <span class="tok-kw">else</span> =&gt; {</span>
<span class="line" id="L1012">                        result.tag = .angle_bracket_left;</span>
<span class="line" id="L1013">                        <span class="tok-kw">break</span>;</span>
<span class="line" id="L1014">                    },</span>
<span class="line" id="L1015">                },</span>
<span class="line" id="L1016"></span>
<span class="line" id="L1017">                .angle_bracket_angle_bracket_left =&gt; <span class="tok-kw">switch</span> (c) {</span>
<span class="line" id="L1018">                    <span class="tok-str">'='</span> =&gt; {</span>
<span class="line" id="L1019">                        result.tag = .angle_bracket_angle_bracket_left_equal;</span>
<span class="line" id="L1020">                        self.index += <span class="tok-number">1</span>;</span>
<span class="line" id="L1021">                        <span class="tok-kw">break</span>;</span>
<span class="line" id="L1022">                    },</span>
<span class="line" id="L1023">                    <span class="tok-str">'|'</span> =&gt; {</span>
<span class="line" id="L1024">                        state = .angle_bracket_angle_bracket_left_pipe;</span>
<span class="line" id="L1025">                    },</span>
<span class="line" id="L1026">                    <span class="tok-kw">else</span> =&gt; {</span>
<span class="line" id="L1027">                        result.tag = .angle_bracket_angle_bracket_left;</span>
<span class="line" id="L1028">                        <span class="tok-kw">break</span>;</span>
<span class="line" id="L1029">                    },</span>
<span class="line" id="L1030">                },</span>
<span class="line" id="L1031"></span>
<span class="line" id="L1032">                .angle_bracket_angle_bracket_left_pipe =&gt; <span class="tok-kw">switch</span> (c) {</span>
<span class="line" id="L1033">                    <span class="tok-str">'='</span> =&gt; {</span>
<span class="line" id="L1034">                        result.tag = .angle_bracket_angle_bracket_left_pipe_equal;</span>
<span class="line" id="L1035">                        self.index += <span class="tok-number">1</span>;</span>
<span class="line" id="L1036">                        <span class="tok-kw">break</span>;</span>
<span class="line" id="L1037">                    },</span>
<span class="line" id="L1038">                    <span class="tok-kw">else</span> =&gt; {</span>
<span class="line" id="L1039">                        result.tag = .angle_bracket_angle_bracket_left_pipe;</span>
<span class="line" id="L1040">                        <span class="tok-kw">break</span>;</span>
<span class="line" id="L1041">                    },</span>
<span class="line" id="L1042">                },</span>
<span class="line" id="L1043"></span>
<span class="line" id="L1044">                .angle_bracket_right =&gt; <span class="tok-kw">switch</span> (c) {</span>
<span class="line" id="L1045">                    <span class="tok-str">'&gt;'</span> =&gt; {</span>
<span class="line" id="L1046">                        state = .angle_bracket_angle_bracket_right;</span>
<span class="line" id="L1047">                    },</span>
<span class="line" id="L1048">                    <span class="tok-str">'='</span> =&gt; {</span>
<span class="line" id="L1049">                        result.tag = .angle_bracket_right_equal;</span>
<span class="line" id="L1050">                        self.index += <span class="tok-number">1</span>;</span>
<span class="line" id="L1051">                        <span class="tok-kw">break</span>;</span>
<span class="line" id="L1052">                    },</span>
<span class="line" id="L1053">                    <span class="tok-kw">else</span> =&gt; {</span>
<span class="line" id="L1054">                        result.tag = .angle_bracket_right;</span>
<span class="line" id="L1055">                        <span class="tok-kw">break</span>;</span>
<span class="line" id="L1056">                    },</span>
<span class="line" id="L1057">                },</span>
<span class="line" id="L1058"></span>
<span class="line" id="L1059">                .angle_bracket_angle_bracket_right =&gt; <span class="tok-kw">switch</span> (c) {</span>
<span class="line" id="L1060">                    <span class="tok-str">'='</span> =&gt; {</span>
<span class="line" id="L1061">                        result.tag = .angle_bracket_angle_bracket_right_equal;</span>
<span class="line" id="L1062">                        self.index += <span class="tok-number">1</span>;</span>
<span class="line" id="L1063">                        <span class="tok-kw">break</span>;</span>
<span class="line" id="L1064">                    },</span>
<span class="line" id="L1065">                    <span class="tok-kw">else</span> =&gt; {</span>
<span class="line" id="L1066">                        result.tag = .angle_bracket_angle_bracket_right;</span>
<span class="line" id="L1067">                        <span class="tok-kw">break</span>;</span>
<span class="line" id="L1068">                    },</span>
<span class="line" id="L1069">                },</span>
<span class="line" id="L1070"></span>
<span class="line" id="L1071">                .period =&gt; <span class="tok-kw">switch</span> (c) {</span>
<span class="line" id="L1072">                    <span class="tok-str">'.'</span> =&gt; {</span>
<span class="line" id="L1073">                        state = .period_2;</span>
<span class="line" id="L1074">                    },</span>
<span class="line" id="L1075">                    <span class="tok-str">'*'</span> =&gt; {</span>
<span class="line" id="L1076">                        state = .period_asterisk;</span>
<span class="line" id="L1077">                    },</span>
<span class="line" id="L1078">                    <span class="tok-kw">else</span> =&gt; {</span>
<span class="line" id="L1079">                        result.tag = .period;</span>
<span class="line" id="L1080">                        <span class="tok-kw">break</span>;</span>
<span class="line" id="L1081">                    },</span>
<span class="line" id="L1082">                },</span>
<span class="line" id="L1083"></span>
<span class="line" id="L1084">                .period_2 =&gt; <span class="tok-kw">switch</span> (c) {</span>
<span class="line" id="L1085">                    <span class="tok-str">'.'</span> =&gt; {</span>
<span class="line" id="L1086">                        result.tag = .ellipsis3;</span>
<span class="line" id="L1087">                        self.index += <span class="tok-number">1</span>;</span>
<span class="line" id="L1088">                        <span class="tok-kw">break</span>;</span>
<span class="line" id="L1089">                    },</span>
<span class="line" id="L1090">                    <span class="tok-kw">else</span> =&gt; {</span>
<span class="line" id="L1091">                        result.tag = .ellipsis2;</span>
<span class="line" id="L1092">                        <span class="tok-kw">break</span>;</span>
<span class="line" id="L1093">                    },</span>
<span class="line" id="L1094">                },</span>
<span class="line" id="L1095"></span>
<span class="line" id="L1096">                .period_asterisk =&gt; <span class="tok-kw">switch</span> (c) {</span>
<span class="line" id="L1097">                    <span class="tok-str">'*'</span> =&gt; {</span>
<span class="line" id="L1098">                        result.tag = .invalid_periodasterisks;</span>
<span class="line" id="L1099">                        <span class="tok-kw">break</span>;</span>
<span class="line" id="L1100">                    },</span>
<span class="line" id="L1101">                    <span class="tok-kw">else</span> =&gt; {</span>
<span class="line" id="L1102">                        result.tag = .period_asterisk;</span>
<span class="line" id="L1103">                        <span class="tok-kw">break</span>;</span>
<span class="line" id="L1104">                    },</span>
<span class="line" id="L1105">                },</span>
<span class="line" id="L1106"></span>
<span class="line" id="L1107">                .slash =&gt; <span class="tok-kw">switch</span> (c) {</span>
<span class="line" id="L1108">                    <span class="tok-str">'/'</span> =&gt; {</span>
<span class="line" id="L1109">                        state = .line_comment_start;</span>
<span class="line" id="L1110">                    },</span>
<span class="line" id="L1111">                    <span class="tok-str">'='</span> =&gt; {</span>
<span class="line" id="L1112">                        result.tag = .slash_equal;</span>
<span class="line" id="L1113">                        self.index += <span class="tok-number">1</span>;</span>
<span class="line" id="L1114">                        <span class="tok-kw">break</span>;</span>
<span class="line" id="L1115">                    },</span>
<span class="line" id="L1116">                    <span class="tok-kw">else</span> =&gt; {</span>
<span class="line" id="L1117">                        result.tag = .slash;</span>
<span class="line" id="L1118">                        <span class="tok-kw">break</span>;</span>
<span class="line" id="L1119">                    },</span>
<span class="line" id="L1120">                },</span>
<span class="line" id="L1121">                .line_comment_start =&gt; <span class="tok-kw">switch</span> (c) {</span>
<span class="line" id="L1122">                    <span class="tok-number">0</span> =&gt; {</span>
<span class="line" id="L1123">                        <span class="tok-kw">if</span> (self.index != self.buffer.len) {</span>
<span class="line" id="L1124">                            result.tag = .invalid;</span>
<span class="line" id="L1125">                            self.index += <span class="tok-number">1</span>;</span>
<span class="line" id="L1126">                        }</span>
<span class="line" id="L1127">                        <span class="tok-kw">break</span>;</span>
<span class="line" id="L1128">                    },</span>
<span class="line" id="L1129">                    <span class="tok-str">'/'</span> =&gt; {</span>
<span class="line" id="L1130">                        state = .doc_comment_start;</span>
<span class="line" id="L1131">                    },</span>
<span class="line" id="L1132">                    <span class="tok-str">'!'</span> =&gt; {</span>
<span class="line" id="L1133">                        result.tag = .container_doc_comment;</span>
<span class="line" id="L1134">                        state = .doc_comment;</span>
<span class="line" id="L1135">                    },</span>
<span class="line" id="L1136">                    <span class="tok-str">'\n'</span> =&gt; {</span>
<span class="line" id="L1137">                        state = .start;</span>
<span class="line" id="L1138">                        result.loc.start = self.index + <span class="tok-number">1</span>;</span>
<span class="line" id="L1139">                    },</span>
<span class="line" id="L1140">                    <span class="tok-str">'\t'</span>, <span class="tok-str">'\r'</span> =&gt; state = .line_comment,</span>
<span class="line" id="L1141">                    <span class="tok-kw">else</span> =&gt; {</span>
<span class="line" id="L1142">                        state = .line_comment;</span>
<span class="line" id="L1143">                        self.checkLiteralCharacter();</span>
<span class="line" id="L1144">                    },</span>
<span class="line" id="L1145">                },</span>
<span class="line" id="L1146">                .doc_comment_start =&gt; <span class="tok-kw">switch</span> (c) {</span>
<span class="line" id="L1147">                    <span class="tok-str">'/'</span> =&gt; {</span>
<span class="line" id="L1148">                        state = .line_comment;</span>
<span class="line" id="L1149">                    },</span>
<span class="line" id="L1150">                    <span class="tok-number">0</span>, <span class="tok-str">'\n'</span> =&gt; {</span>
<span class="line" id="L1151">                        result.tag = .doc_comment;</span>
<span class="line" id="L1152">                        <span class="tok-kw">break</span>;</span>
<span class="line" id="L1153">                    },</span>
<span class="line" id="L1154">                    <span class="tok-str">'\t'</span>, <span class="tok-str">'\r'</span> =&gt; {</span>
<span class="line" id="L1155">                        state = .doc_comment;</span>
<span class="line" id="L1156">                        result.tag = .doc_comment;</span>
<span class="line" id="L1157">                    },</span>
<span class="line" id="L1158">                    <span class="tok-kw">else</span> =&gt; {</span>
<span class="line" id="L1159">                        state = .doc_comment;</span>
<span class="line" id="L1160">                        result.tag = .doc_comment;</span>
<span class="line" id="L1161">                        self.checkLiteralCharacter();</span>
<span class="line" id="L1162">                    },</span>
<span class="line" id="L1163">                },</span>
<span class="line" id="L1164">                .line_comment =&gt; <span class="tok-kw">switch</span> (c) {</span>
<span class="line" id="L1165">                    <span class="tok-number">0</span> =&gt; <span class="tok-kw">break</span>,</span>
<span class="line" id="L1166">                    <span class="tok-str">'\n'</span> =&gt; {</span>
<span class="line" id="L1167">                        state = .start;</span>
<span class="line" id="L1168">                        result.loc.start = self.index + <span class="tok-number">1</span>;</span>
<span class="line" id="L1169">                    },</span>
<span class="line" id="L1170">                    <span class="tok-str">'\t'</span>, <span class="tok-str">'\r'</span> =&gt; {},</span>
<span class="line" id="L1171">                    <span class="tok-kw">else</span> =&gt; self.checkLiteralCharacter(),</span>
<span class="line" id="L1172">                },</span>
<span class="line" id="L1173">                .doc_comment =&gt; <span class="tok-kw">switch</span> (c) {</span>
<span class="line" id="L1174">                    <span class="tok-number">0</span>, <span class="tok-str">'\n'</span> =&gt; <span class="tok-kw">break</span>,</span>
<span class="line" id="L1175">                    <span class="tok-str">'\t'</span>, <span class="tok-str">'\r'</span> =&gt; {},</span>
<span class="line" id="L1176">                    <span class="tok-kw">else</span> =&gt; self.checkLiteralCharacter(),</span>
<span class="line" id="L1177">                },</span>
<span class="line" id="L1178">                .zero =&gt; <span class="tok-kw">switch</span> (c) {</span>
<span class="line" id="L1179">                    <span class="tok-str">'b'</span> =&gt; {</span>
<span class="line" id="L1180">                        state = .int_literal_bin_no_underscore;</span>
<span class="line" id="L1181">                    },</span>
<span class="line" id="L1182">                    <span class="tok-str">'o'</span> =&gt; {</span>
<span class="line" id="L1183">                        state = .int_literal_oct_no_underscore;</span>
<span class="line" id="L1184">                    },</span>
<span class="line" id="L1185">                    <span class="tok-str">'x'</span> =&gt; {</span>
<span class="line" id="L1186">                        state = .int_literal_hex_no_underscore;</span>
<span class="line" id="L1187">                    },</span>
<span class="line" id="L1188">                    <span class="tok-str">'0'</span>...<span class="tok-str">'9'</span>, <span class="tok-str">'_'</span>, <span class="tok-str">'.'</span>, <span class="tok-str">'e'</span>, <span class="tok-str">'E'</span> =&gt; {</span>
<span class="line" id="L1189">                        <span class="tok-comment">// reinterpret as a decimal number</span>
</span>
<span class="line" id="L1190">                        self.index -= <span class="tok-number">1</span>;</span>
<span class="line" id="L1191">                        state = .int_literal_dec;</span>
<span class="line" id="L1192">                    },</span>
<span class="line" id="L1193">                    <span class="tok-str">'a'</span>, <span class="tok-str">'c'</span>, <span class="tok-str">'d'</span>, <span class="tok-str">'f'</span>...<span class="tok-str">'n'</span>, <span class="tok-str">'p'</span>...<span class="tok-str">'w'</span>, <span class="tok-str">'y'</span>, <span class="tok-str">'z'</span>, <span class="tok-str">'A'</span>...<span class="tok-str">'D'</span>, <span class="tok-str">'F'</span>...<span class="tok-str">'Z'</span> =&gt; {</span>
<span class="line" id="L1194">                        result.tag = .invalid;</span>
<span class="line" id="L1195">                        <span class="tok-kw">break</span>;</span>
<span class="line" id="L1196">                    },</span>
<span class="line" id="L1197">                    <span class="tok-kw">else</span> =&gt; <span class="tok-kw">break</span>,</span>
<span class="line" id="L1198">                },</span>
<span class="line" id="L1199">                .int_literal_bin_no_underscore =&gt; <span class="tok-kw">switch</span> (c) {</span>
<span class="line" id="L1200">                    <span class="tok-str">'0'</span>...<span class="tok-str">'1'</span> =&gt; {</span>
<span class="line" id="L1201">                        state = .int_literal_bin;</span>
<span class="line" id="L1202">                    },</span>
<span class="line" id="L1203">                    <span class="tok-kw">else</span> =&gt; {</span>
<span class="line" id="L1204">                        result.tag = .invalid;</span>
<span class="line" id="L1205">                        <span class="tok-kw">break</span>;</span>
<span class="line" id="L1206">                    },</span>
<span class="line" id="L1207">                },</span>
<span class="line" id="L1208">                .int_literal_bin =&gt; <span class="tok-kw">switch</span> (c) {</span>
<span class="line" id="L1209">                    <span class="tok-str">'_'</span> =&gt; {</span>
<span class="line" id="L1210">                        state = .int_literal_bin_no_underscore;</span>
<span class="line" id="L1211">                    },</span>
<span class="line" id="L1212">                    <span class="tok-str">'0'</span>...<span class="tok-str">'1'</span> =&gt; {},</span>
<span class="line" id="L1213">                    <span class="tok-str">'2'</span>...<span class="tok-str">'9'</span>, <span class="tok-str">'a'</span>...<span class="tok-str">'z'</span>, <span class="tok-str">'A'</span>...<span class="tok-str">'Z'</span> =&gt; {</span>
<span class="line" id="L1214">                        result.tag = .invalid;</span>
<span class="line" id="L1215">                        <span class="tok-kw">break</span>;</span>
<span class="line" id="L1216">                    },</span>
<span class="line" id="L1217">                    <span class="tok-kw">else</span> =&gt; <span class="tok-kw">break</span>,</span>
<span class="line" id="L1218">                },</span>
<span class="line" id="L1219">                .int_literal_oct_no_underscore =&gt; <span class="tok-kw">switch</span> (c) {</span>
<span class="line" id="L1220">                    <span class="tok-str">'0'</span>...<span class="tok-str">'7'</span> =&gt; {</span>
<span class="line" id="L1221">                        state = .int_literal_oct;</span>
<span class="line" id="L1222">                    },</span>
<span class="line" id="L1223">                    <span class="tok-kw">else</span> =&gt; {</span>
<span class="line" id="L1224">                        result.tag = .invalid;</span>
<span class="line" id="L1225">                        <span class="tok-kw">break</span>;</span>
<span class="line" id="L1226">                    },</span>
<span class="line" id="L1227">                },</span>
<span class="line" id="L1228">                .int_literal_oct =&gt; <span class="tok-kw">switch</span> (c) {</span>
<span class="line" id="L1229">                    <span class="tok-str">'_'</span> =&gt; {</span>
<span class="line" id="L1230">                        state = .int_literal_oct_no_underscore;</span>
<span class="line" id="L1231">                    },</span>
<span class="line" id="L1232">                    <span class="tok-str">'0'</span>...<span class="tok-str">'7'</span> =&gt; {},</span>
<span class="line" id="L1233">                    <span class="tok-str">'8'</span>, <span class="tok-str">'9'</span>, <span class="tok-str">'a'</span>...<span class="tok-str">'z'</span>, <span class="tok-str">'A'</span>...<span class="tok-str">'Z'</span> =&gt; {</span>
<span class="line" id="L1234">                        result.tag = .invalid;</span>
<span class="line" id="L1235">                        <span class="tok-kw">break</span>;</span>
<span class="line" id="L1236">                    },</span>
<span class="line" id="L1237">                    <span class="tok-kw">else</span> =&gt; <span class="tok-kw">break</span>,</span>
<span class="line" id="L1238">                },</span>
<span class="line" id="L1239">                .int_literal_dec_no_underscore =&gt; <span class="tok-kw">switch</span> (c) {</span>
<span class="line" id="L1240">                    <span class="tok-str">'0'</span>...<span class="tok-str">'9'</span> =&gt; {</span>
<span class="line" id="L1241">                        state = .int_literal_dec;</span>
<span class="line" id="L1242">                    },</span>
<span class="line" id="L1243">                    <span class="tok-kw">else</span> =&gt; {</span>
<span class="line" id="L1244">                        result.tag = .invalid;</span>
<span class="line" id="L1245">                        <span class="tok-kw">break</span>;</span>
<span class="line" id="L1246">                    },</span>
<span class="line" id="L1247">                },</span>
<span class="line" id="L1248">                .int_literal_dec =&gt; <span class="tok-kw">switch</span> (c) {</span>
<span class="line" id="L1249">                    <span class="tok-str">'_'</span> =&gt; {</span>
<span class="line" id="L1250">                        state = .int_literal_dec_no_underscore;</span>
<span class="line" id="L1251">                    },</span>
<span class="line" id="L1252">                    <span class="tok-str">'.'</span> =&gt; {</span>
<span class="line" id="L1253">                        state = .num_dot_dec;</span>
<span class="line" id="L1254">                        result.tag = .invalid;</span>
<span class="line" id="L1255">                    },</span>
<span class="line" id="L1256">                    <span class="tok-str">'e'</span>, <span class="tok-str">'E'</span> =&gt; {</span>
<span class="line" id="L1257">                        state = .float_exponent_unsigned;</span>
<span class="line" id="L1258">                        result.tag = .float_literal;</span>
<span class="line" id="L1259">                    },</span>
<span class="line" id="L1260">                    <span class="tok-str">'0'</span>...<span class="tok-str">'9'</span> =&gt; {},</span>
<span class="line" id="L1261">                    <span class="tok-str">'a'</span>...<span class="tok-str">'d'</span>, <span class="tok-str">'f'</span>...<span class="tok-str">'z'</span>, <span class="tok-str">'A'</span>...<span class="tok-str">'D'</span>, <span class="tok-str">'F'</span>...<span class="tok-str">'Z'</span> =&gt; {</span>
<span class="line" id="L1262">                        result.tag = .invalid;</span>
<span class="line" id="L1263">                        <span class="tok-kw">break</span>;</span>
<span class="line" id="L1264">                    },</span>
<span class="line" id="L1265">                    <span class="tok-kw">else</span> =&gt; <span class="tok-kw">break</span>,</span>
<span class="line" id="L1266">                },</span>
<span class="line" id="L1267">                .int_literal_hex_no_underscore =&gt; <span class="tok-kw">switch</span> (c) {</span>
<span class="line" id="L1268">                    <span class="tok-str">'0'</span>...<span class="tok-str">'9'</span>, <span class="tok-str">'a'</span>...<span class="tok-str">'f'</span>, <span class="tok-str">'A'</span>...<span class="tok-str">'F'</span> =&gt; {</span>
<span class="line" id="L1269">                        state = .int_literal_hex;</span>
<span class="line" id="L1270">                    },</span>
<span class="line" id="L1271">                    <span class="tok-kw">else</span> =&gt; {</span>
<span class="line" id="L1272">                        result.tag = .invalid;</span>
<span class="line" id="L1273">                        <span class="tok-kw">break</span>;</span>
<span class="line" id="L1274">                    },</span>
<span class="line" id="L1275">                },</span>
<span class="line" id="L1276">                .int_literal_hex =&gt; <span class="tok-kw">switch</span> (c) {</span>
<span class="line" id="L1277">                    <span class="tok-str">'_'</span> =&gt; {</span>
<span class="line" id="L1278">                        state = .int_literal_hex_no_underscore;</span>
<span class="line" id="L1279">                    },</span>
<span class="line" id="L1280">                    <span class="tok-str">'.'</span> =&gt; {</span>
<span class="line" id="L1281">                        state = .num_dot_hex;</span>
<span class="line" id="L1282">                        result.tag = .invalid;</span>
<span class="line" id="L1283">                    },</span>
<span class="line" id="L1284">                    <span class="tok-str">'p'</span>, <span class="tok-str">'P'</span> =&gt; {</span>
<span class="line" id="L1285">                        state = .float_exponent_unsigned;</span>
<span class="line" id="L1286">                        result.tag = .float_literal;</span>
<span class="line" id="L1287">                    },</span>
<span class="line" id="L1288">                    <span class="tok-str">'0'</span>...<span class="tok-str">'9'</span>, <span class="tok-str">'a'</span>...<span class="tok-str">'f'</span>, <span class="tok-str">'A'</span>...<span class="tok-str">'F'</span> =&gt; {},</span>
<span class="line" id="L1289">                    <span class="tok-str">'g'</span>...<span class="tok-str">'o'</span>, <span class="tok-str">'q'</span>...<span class="tok-str">'z'</span>, <span class="tok-str">'G'</span>...<span class="tok-str">'O'</span>, <span class="tok-str">'Q'</span>...<span class="tok-str">'Z'</span> =&gt; {</span>
<span class="line" id="L1290">                        result.tag = .invalid;</span>
<span class="line" id="L1291">                        <span class="tok-kw">break</span>;</span>
<span class="line" id="L1292">                    },</span>
<span class="line" id="L1293">                    <span class="tok-kw">else</span> =&gt; <span class="tok-kw">break</span>,</span>
<span class="line" id="L1294">                },</span>
<span class="line" id="L1295">                .num_dot_dec =&gt; <span class="tok-kw">switch</span> (c) {</span>
<span class="line" id="L1296">                    <span class="tok-str">'.'</span> =&gt; {</span>
<span class="line" id="L1297">                        result.tag = .integer_literal;</span>
<span class="line" id="L1298">                        self.index -= <span class="tok-number">1</span>;</span>
<span class="line" id="L1299">                        state = .start;</span>
<span class="line" id="L1300">                        <span class="tok-kw">break</span>;</span>
<span class="line" id="L1301">                    },</span>
<span class="line" id="L1302">                    <span class="tok-str">'0'</span>...<span class="tok-str">'9'</span> =&gt; {</span>
<span class="line" id="L1303">                        result.tag = .float_literal;</span>
<span class="line" id="L1304">                        state = .float_fraction_dec;</span>
<span class="line" id="L1305">                    },</span>
<span class="line" id="L1306">                    <span class="tok-str">'_'</span>, <span class="tok-str">'a'</span>...<span class="tok-str">'z'</span>, <span class="tok-str">'A'</span>...<span class="tok-str">'Z'</span> =&gt; {</span>
<span class="line" id="L1307">                        result.tag = .invalid;</span>
<span class="line" id="L1308">                        <span class="tok-kw">break</span>;</span>
<span class="line" id="L1309">                    },</span>
<span class="line" id="L1310">                    <span class="tok-kw">else</span> =&gt; <span class="tok-kw">break</span>,</span>
<span class="line" id="L1311">                },</span>
<span class="line" id="L1312">                .num_dot_hex =&gt; <span class="tok-kw">switch</span> (c) {</span>
<span class="line" id="L1313">                    <span class="tok-str">'.'</span> =&gt; {</span>
<span class="line" id="L1314">                        result.tag = .integer_literal;</span>
<span class="line" id="L1315">                        self.index -= <span class="tok-number">1</span>;</span>
<span class="line" id="L1316">                        state = .start;</span>
<span class="line" id="L1317">                        <span class="tok-kw">break</span>;</span>
<span class="line" id="L1318">                    },</span>
<span class="line" id="L1319">                    <span class="tok-str">'0'</span>...<span class="tok-str">'9'</span>, <span class="tok-str">'a'</span>...<span class="tok-str">'f'</span>, <span class="tok-str">'A'</span>...<span class="tok-str">'F'</span> =&gt; {</span>
<span class="line" id="L1320">                        result.tag = .float_literal;</span>
<span class="line" id="L1321">                        state = .float_fraction_hex;</span>
<span class="line" id="L1322">                    },</span>
<span class="line" id="L1323">                    <span class="tok-str">'_'</span>, <span class="tok-str">'g'</span>...<span class="tok-str">'z'</span>, <span class="tok-str">'G'</span>...<span class="tok-str">'Z'</span> =&gt; {</span>
<span class="line" id="L1324">                        result.tag = .invalid;</span>
<span class="line" id="L1325">                        <span class="tok-kw">break</span>;</span>
<span class="line" id="L1326">                    },</span>
<span class="line" id="L1327">                    <span class="tok-kw">else</span> =&gt; <span class="tok-kw">break</span>,</span>
<span class="line" id="L1328">                },</span>
<span class="line" id="L1329">                .float_fraction_dec_no_underscore =&gt; <span class="tok-kw">switch</span> (c) {</span>
<span class="line" id="L1330">                    <span class="tok-str">'0'</span>...<span class="tok-str">'9'</span> =&gt; {</span>
<span class="line" id="L1331">                        state = .float_fraction_dec;</span>
<span class="line" id="L1332">                    },</span>
<span class="line" id="L1333">                    <span class="tok-kw">else</span> =&gt; {</span>
<span class="line" id="L1334">                        result.tag = .invalid;</span>
<span class="line" id="L1335">                        <span class="tok-kw">break</span>;</span>
<span class="line" id="L1336">                    },</span>
<span class="line" id="L1337">                },</span>
<span class="line" id="L1338">                .float_fraction_dec =&gt; <span class="tok-kw">switch</span> (c) {</span>
<span class="line" id="L1339">                    <span class="tok-str">'_'</span> =&gt; {</span>
<span class="line" id="L1340">                        state = .float_fraction_dec_no_underscore;</span>
<span class="line" id="L1341">                    },</span>
<span class="line" id="L1342">                    <span class="tok-str">'e'</span>, <span class="tok-str">'E'</span> =&gt; {</span>
<span class="line" id="L1343">                        state = .float_exponent_unsigned;</span>
<span class="line" id="L1344">                    },</span>
<span class="line" id="L1345">                    <span class="tok-str">'0'</span>...<span class="tok-str">'9'</span> =&gt; {},</span>
<span class="line" id="L1346">                    <span class="tok-str">'a'</span>...<span class="tok-str">'d'</span>, <span class="tok-str">'f'</span>...<span class="tok-str">'z'</span>, <span class="tok-str">'A'</span>...<span class="tok-str">'D'</span>, <span class="tok-str">'F'</span>...<span class="tok-str">'Z'</span> =&gt; {</span>
<span class="line" id="L1347">                        result.tag = .invalid;</span>
<span class="line" id="L1348">                        <span class="tok-kw">break</span>;</span>
<span class="line" id="L1349">                    },</span>
<span class="line" id="L1350">                    <span class="tok-kw">else</span> =&gt; <span class="tok-kw">break</span>,</span>
<span class="line" id="L1351">                },</span>
<span class="line" id="L1352">                .float_fraction_hex_no_underscore =&gt; <span class="tok-kw">switch</span> (c) {</span>
<span class="line" id="L1353">                    <span class="tok-str">'0'</span>...<span class="tok-str">'9'</span>, <span class="tok-str">'a'</span>...<span class="tok-str">'f'</span>, <span class="tok-str">'A'</span>...<span class="tok-str">'F'</span> =&gt; {</span>
<span class="line" id="L1354">                        state = .float_fraction_hex;</span>
<span class="line" id="L1355">                    },</span>
<span class="line" id="L1356">                    <span class="tok-kw">else</span> =&gt; {</span>
<span class="line" id="L1357">                        result.tag = .invalid;</span>
<span class="line" id="L1358">                        <span class="tok-kw">break</span>;</span>
<span class="line" id="L1359">                    },</span>
<span class="line" id="L1360">                },</span>
<span class="line" id="L1361">                .float_fraction_hex =&gt; <span class="tok-kw">switch</span> (c) {</span>
<span class="line" id="L1362">                    <span class="tok-str">'_'</span> =&gt; {</span>
<span class="line" id="L1363">                        state = .float_fraction_hex_no_underscore;</span>
<span class="line" id="L1364">                    },</span>
<span class="line" id="L1365">                    <span class="tok-str">'p'</span>, <span class="tok-str">'P'</span> =&gt; {</span>
<span class="line" id="L1366">                        state = .float_exponent_unsigned;</span>
<span class="line" id="L1367">                    },</span>
<span class="line" id="L1368">                    <span class="tok-str">'0'</span>...<span class="tok-str">'9'</span>, <span class="tok-str">'a'</span>...<span class="tok-str">'f'</span>, <span class="tok-str">'A'</span>...<span class="tok-str">'F'</span> =&gt; {},</span>
<span class="line" id="L1369">                    <span class="tok-str">'g'</span>...<span class="tok-str">'o'</span>, <span class="tok-str">'q'</span>...<span class="tok-str">'z'</span>, <span class="tok-str">'G'</span>...<span class="tok-str">'O'</span>, <span class="tok-str">'Q'</span>...<span class="tok-str">'Z'</span> =&gt; {</span>
<span class="line" id="L1370">                        result.tag = .invalid;</span>
<span class="line" id="L1371">                        <span class="tok-kw">break</span>;</span>
<span class="line" id="L1372">                    },</span>
<span class="line" id="L1373">                    <span class="tok-kw">else</span> =&gt; <span class="tok-kw">break</span>,</span>
<span class="line" id="L1374">                },</span>
<span class="line" id="L1375">                .float_exponent_unsigned =&gt; <span class="tok-kw">switch</span> (c) {</span>
<span class="line" id="L1376">                    <span class="tok-str">'+'</span>, <span class="tok-str">'-'</span> =&gt; {</span>
<span class="line" id="L1377">                        state = .float_exponent_num_no_underscore;</span>
<span class="line" id="L1378">                    },</span>
<span class="line" id="L1379">                    <span class="tok-kw">else</span> =&gt; {</span>
<span class="line" id="L1380">                        <span class="tok-comment">// reinterpret as a normal exponent number</span>
</span>
<span class="line" id="L1381">                        self.index -= <span class="tok-number">1</span>;</span>
<span class="line" id="L1382">                        state = .float_exponent_num_no_underscore;</span>
<span class="line" id="L1383">                    },</span>
<span class="line" id="L1384">                },</span>
<span class="line" id="L1385">                .float_exponent_num_no_underscore =&gt; <span class="tok-kw">switch</span> (c) {</span>
<span class="line" id="L1386">                    <span class="tok-str">'0'</span>...<span class="tok-str">'9'</span> =&gt; {</span>
<span class="line" id="L1387">                        state = .float_exponent_num;</span>
<span class="line" id="L1388">                    },</span>
<span class="line" id="L1389">                    <span class="tok-kw">else</span> =&gt; {</span>
<span class="line" id="L1390">                        result.tag = .invalid;</span>
<span class="line" id="L1391">                        <span class="tok-kw">break</span>;</span>
<span class="line" id="L1392">                    },</span>
<span class="line" id="L1393">                },</span>
<span class="line" id="L1394">                .float_exponent_num =&gt; <span class="tok-kw">switch</span> (c) {</span>
<span class="line" id="L1395">                    <span class="tok-str">'_'</span> =&gt; {</span>
<span class="line" id="L1396">                        state = .float_exponent_num_no_underscore;</span>
<span class="line" id="L1397">                    },</span>
<span class="line" id="L1398">                    <span class="tok-str">'0'</span>...<span class="tok-str">'9'</span> =&gt; {},</span>
<span class="line" id="L1399">                    <span class="tok-str">'a'</span>...<span class="tok-str">'z'</span>, <span class="tok-str">'A'</span>...<span class="tok-str">'Z'</span> =&gt; {</span>
<span class="line" id="L1400">                        result.tag = .invalid;</span>
<span class="line" id="L1401">                        <span class="tok-kw">break</span>;</span>
<span class="line" id="L1402">                    },</span>
<span class="line" id="L1403">                    <span class="tok-kw">else</span> =&gt; <span class="tok-kw">break</span>,</span>
<span class="line" id="L1404">                },</span>
<span class="line" id="L1405">            }</span>
<span class="line" id="L1406">        }</span>
<span class="line" id="L1407"></span>
<span class="line" id="L1408">        <span class="tok-kw">if</span> (result.tag == .eof) {</span>
<span class="line" id="L1409">            <span class="tok-kw">if</span> (self.pending_invalid_token) |token| {</span>
<span class="line" id="L1410">                self.pending_invalid_token = <span class="tok-null">null</span>;</span>
<span class="line" id="L1411">                <span class="tok-kw">return</span> token;</span>
<span class="line" id="L1412">            }</span>
<span class="line" id="L1413">            result.loc.start = self.index;</span>
<span class="line" id="L1414">        }</span>
<span class="line" id="L1415"></span>
<span class="line" id="L1416">        result.loc.end = self.index;</span>
<span class="line" id="L1417">        <span class="tok-kw">return</span> result;</span>
<span class="line" id="L1418">    }</span>
<span class="line" id="L1419"></span>
<span class="line" id="L1420">    <span class="tok-kw">fn</span> <span class="tok-fn">checkLiteralCharacter</span>(self: *Tokenizer) <span class="tok-type">void</span> {</span>
<span class="line" id="L1421">        <span class="tok-kw">if</span> (self.pending_invalid_token != <span class="tok-null">null</span>) <span class="tok-kw">return</span>;</span>
<span class="line" id="L1422">        <span class="tok-kw">const</span> invalid_length = self.getInvalidCharacterLength();</span>
<span class="line" id="L1423">        <span class="tok-kw">if</span> (invalid_length == <span class="tok-number">0</span>) <span class="tok-kw">return</span>;</span>
<span class="line" id="L1424">        self.pending_invalid_token = .{</span>
<span class="line" id="L1425">            .tag = .invalid,</span>
<span class="line" id="L1426">            .loc = .{</span>
<span class="line" id="L1427">                .start = self.index,</span>
<span class="line" id="L1428">                .end = self.index + invalid_length,</span>
<span class="line" id="L1429">            },</span>
<span class="line" id="L1430">        };</span>
<span class="line" id="L1431">    }</span>
<span class="line" id="L1432"></span>
<span class="line" id="L1433">    <span class="tok-kw">fn</span> <span class="tok-fn">getInvalidCharacterLength</span>(self: *Tokenizer) <span class="tok-type">u3</span> {</span>
<span class="line" id="L1434">        <span class="tok-kw">const</span> c0 = self.buffer[self.index];</span>
<span class="line" id="L1435">        <span class="tok-kw">if</span> (std.ascii.isASCII(c0)) {</span>
<span class="line" id="L1436">            <span class="tok-kw">if</span> (std.ascii.isCntrl(c0)) {</span>
<span class="line" id="L1437">                <span class="tok-comment">// ascii control codes are never allowed</span>
</span>
<span class="line" id="L1438">                <span class="tok-comment">// (note that \n was checked before we got here)</span>
</span>
<span class="line" id="L1439">                <span class="tok-kw">return</span> <span class="tok-number">1</span>;</span>
<span class="line" id="L1440">            }</span>
<span class="line" id="L1441">            <span class="tok-comment">// looks fine to me.</span>
</span>
<span class="line" id="L1442">            <span class="tok-kw">return</span> <span class="tok-number">0</span>;</span>
<span class="line" id="L1443">        } <span class="tok-kw">else</span> {</span>
<span class="line" id="L1444">            <span class="tok-comment">// check utf8-encoded character.</span>
</span>
<span class="line" id="L1445">            <span class="tok-kw">const</span> length = std.unicode.utf8ByteSequenceLength(c0) <span class="tok-kw">catch</span> <span class="tok-kw">return</span> <span class="tok-number">1</span>;</span>
<span class="line" id="L1446">            <span class="tok-kw">if</span> (self.index + length &gt; self.buffer.len) {</span>
<span class="line" id="L1447">                <span class="tok-kw">return</span> <span class="tok-builtin">@intCast</span>(<span class="tok-type">u3</span>, self.buffer.len - self.index);</span>
<span class="line" id="L1448">            }</span>
<span class="line" id="L1449">            <span class="tok-kw">const</span> bytes = self.buffer[self.index .. self.index + length];</span>
<span class="line" id="L1450">            <span class="tok-kw">switch</span> (length) {</span>
<span class="line" id="L1451">                <span class="tok-number">2</span> =&gt; {</span>
<span class="line" id="L1452">                    <span class="tok-kw">const</span> value = std.unicode.utf8Decode2(bytes) <span class="tok-kw">catch</span> <span class="tok-kw">return</span> length;</span>
<span class="line" id="L1453">                    <span class="tok-kw">if</span> (value == <span class="tok-number">0x85</span>) <span class="tok-kw">return</span> length; <span class="tok-comment">// U+0085 (NEL)</span>
</span>
<span class="line" id="L1454">                },</span>
<span class="line" id="L1455">                <span class="tok-number">3</span> =&gt; {</span>
<span class="line" id="L1456">                    <span class="tok-kw">const</span> value = std.unicode.utf8Decode3(bytes) <span class="tok-kw">catch</span> <span class="tok-kw">return</span> length;</span>
<span class="line" id="L1457">                    <span class="tok-kw">if</span> (value == <span class="tok-number">0x2028</span>) <span class="tok-kw">return</span> length; <span class="tok-comment">// U+2028 (LS)</span>
</span>
<span class="line" id="L1458">                    <span class="tok-kw">if</span> (value == <span class="tok-number">0x2029</span>) <span class="tok-kw">return</span> length; <span class="tok-comment">// U+2029 (PS)</span>
</span>
<span class="line" id="L1459">                },</span>
<span class="line" id="L1460">                <span class="tok-number">4</span> =&gt; {</span>
<span class="line" id="L1461">                    _ = std.unicode.utf8Decode4(bytes) <span class="tok-kw">catch</span> <span class="tok-kw">return</span> length;</span>
<span class="line" id="L1462">                },</span>
<span class="line" id="L1463">                <span class="tok-kw">else</span> =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L1464">            }</span>
<span class="line" id="L1465">            self.index += length - <span class="tok-number">1</span>;</span>
<span class="line" id="L1466">            <span class="tok-kw">return</span> <span class="tok-number">0</span>;</span>
<span class="line" id="L1467">        }</span>
<span class="line" id="L1468">    }</span>
<span class="line" id="L1469">};</span>
<span class="line" id="L1470"></span>
<span class="line" id="L1471"><span class="tok-kw">test</span> <span class="tok-str">&quot;keywords&quot;</span> {</span>
<span class="line" id="L1472">    <span class="tok-kw">try</span> testTokenize(<span class="tok-str">&quot;test const else&quot;</span>, &amp;.{ .keyword_test, .keyword_const, .keyword_else });</span>
<span class="line" id="L1473">}</span>
<span class="line" id="L1474"></span>
<span class="line" id="L1475"><span class="tok-kw">test</span> <span class="tok-str">&quot;line comment followed by top-level comptime&quot;</span> {</span>
<span class="line" id="L1476">    <span class="tok-kw">try</span> testTokenize(</span>
<span class="line" id="L1477">        <span class="tok-str">\\// line comment</span></span>

<span class="line" id="L1478">        <span class="tok-str">\\comptime {}</span></span>

<span class="line" id="L1479">        <span class="tok-str">\\</span></span>

<span class="line" id="L1480">    , &amp;.{</span>
<span class="line" id="L1481">        .keyword_comptime,</span>
<span class="line" id="L1482">        .l_brace,</span>
<span class="line" id="L1483">        .r_brace,</span>
<span class="line" id="L1484">    });</span>
<span class="line" id="L1485">}</span>
<span class="line" id="L1486"></span>
<span class="line" id="L1487"><span class="tok-kw">test</span> <span class="tok-str">&quot;unknown length pointer and then c pointer&quot;</span> {</span>
<span class="line" id="L1488">    <span class="tok-kw">try</span> testTokenize(</span>
<span class="line" id="L1489">        <span class="tok-str">\\[*]u8</span></span>

<span class="line" id="L1490">        <span class="tok-str">\\[*c]u8</span></span>

<span class="line" id="L1491">    , &amp;.{</span>
<span class="line" id="L1492">        .l_bracket,</span>
<span class="line" id="L1493">        .asterisk,</span>
<span class="line" id="L1494">        .r_bracket,</span>
<span class="line" id="L1495">        .identifier,</span>
<span class="line" id="L1496">        .l_bracket,</span>
<span class="line" id="L1497">        .asterisk,</span>
<span class="line" id="L1498">        .identifier,</span>
<span class="line" id="L1499">        .r_bracket,</span>
<span class="line" id="L1500">        .identifier,</span>
<span class="line" id="L1501">    });</span>
<span class="line" id="L1502">}</span>
<span class="line" id="L1503"></span>
<span class="line" id="L1504"><span class="tok-kw">test</span> <span class="tok-str">&quot;code point literal with hex escape&quot;</span> {</span>
<span class="line" id="L1505">    <span class="tok-kw">try</span> testTokenize(</span>
<span class="line" id="L1506">        <span class="tok-str">\\'\x1b'</span></span>

<span class="line" id="L1507">    , &amp;.{.char_literal});</span>
<span class="line" id="L1508">    <span class="tok-kw">try</span> testTokenize(</span>
<span class="line" id="L1509">        <span class="tok-str">\\'\x1'</span></span>

<span class="line" id="L1510">    , &amp;.{ .invalid, .invalid });</span>
<span class="line" id="L1511">}</span>
<span class="line" id="L1512"></span>
<span class="line" id="L1513"><span class="tok-kw">test</span> <span class="tok-str">&quot;newline in char literal&quot;</span> {</span>
<span class="line" id="L1514">    <span class="tok-kw">try</span> testTokenize(</span>
<span class="line" id="L1515">        <span class="tok-str">\\'</span></span>

<span class="line" id="L1516">        <span class="tok-str">\\'</span></span>

<span class="line" id="L1517">    , &amp;.{ .invalid, .invalid });</span>
<span class="line" id="L1518">}</span>
<span class="line" id="L1519"></span>
<span class="line" id="L1520"><span class="tok-kw">test</span> <span class="tok-str">&quot;newline in string literal&quot;</span> {</span>
<span class="line" id="L1521">    <span class="tok-kw">try</span> testTokenize(</span>
<span class="line" id="L1522">        <span class="tok-str">\\&quot;</span></span>

<span class="line" id="L1523">        <span class="tok-str">\\&quot;</span></span>

<span class="line" id="L1524">    , &amp;.{ .invalid, .string_literal });</span>
<span class="line" id="L1525">}</span>
<span class="line" id="L1526"></span>
<span class="line" id="L1527"><span class="tok-kw">test</span> <span class="tok-str">&quot;code point literal with unicode escapes&quot;</span> {</span>
<span class="line" id="L1528">    <span class="tok-comment">// Valid unicode escapes</span>
</span>
<span class="line" id="L1529">    <span class="tok-kw">try</span> testTokenize(</span>
<span class="line" id="L1530">        <span class="tok-str">\\'\u{3}'</span></span>

<span class="line" id="L1531">    , &amp;.{.char_literal});</span>
<span class="line" id="L1532">    <span class="tok-kw">try</span> testTokenize(</span>
<span class="line" id="L1533">        <span class="tok-str">\\'\u{01}'</span></span>

<span class="line" id="L1534">    , &amp;.{.char_literal});</span>
<span class="line" id="L1535">    <span class="tok-kw">try</span> testTokenize(</span>
<span class="line" id="L1536">        <span class="tok-str">\\'\u{2a}'</span></span>

<span class="line" id="L1537">    , &amp;.{.char_literal});</span>
<span class="line" id="L1538">    <span class="tok-kw">try</span> testTokenize(</span>
<span class="line" id="L1539">        <span class="tok-str">\\'\u{3f9}'</span></span>

<span class="line" id="L1540">    , &amp;.{.char_literal});</span>
<span class="line" id="L1541">    <span class="tok-kw">try</span> testTokenize(</span>
<span class="line" id="L1542">        <span class="tok-str">\\'\u{6E09aBc1523}'</span></span>

<span class="line" id="L1543">    , &amp;.{.char_literal});</span>
<span class="line" id="L1544">    <span class="tok-kw">try</span> testTokenize(</span>
<span class="line" id="L1545">        <span class="tok-str">\\&quot;\u{440}&quot;</span></span>

<span class="line" id="L1546">    , &amp;.{.string_literal});</span>
<span class="line" id="L1547"></span>
<span class="line" id="L1548">    <span class="tok-comment">// Invalid unicode escapes</span>
</span>
<span class="line" id="L1549">    <span class="tok-kw">try</span> testTokenize(</span>
<span class="line" id="L1550">        <span class="tok-str">\\'\u'</span></span>

<span class="line" id="L1551">    , &amp;.{.invalid});</span>
<span class="line" id="L1552">    <span class="tok-kw">try</span> testTokenize(</span>
<span class="line" id="L1553">        <span class="tok-str">\\'\u{{'</span></span>

<span class="line" id="L1554">    , &amp;.{ .invalid, .invalid });</span>
<span class="line" id="L1555">    <span class="tok-kw">try</span> testTokenize(</span>
<span class="line" id="L1556">        <span class="tok-str">\\'\u{}'</span></span>

<span class="line" id="L1557">    , &amp;.{.char_literal});</span>
<span class="line" id="L1558">    <span class="tok-kw">try</span> testTokenize(</span>
<span class="line" id="L1559">        <span class="tok-str">\\'\u{s}'</span></span>

<span class="line" id="L1560">    , &amp;.{ .invalid, .invalid });</span>
<span class="line" id="L1561">    <span class="tok-kw">try</span> testTokenize(</span>
<span class="line" id="L1562">        <span class="tok-str">\\'\u{2z}'</span></span>

<span class="line" id="L1563">    , &amp;.{ .invalid, .invalid });</span>
<span class="line" id="L1564">    <span class="tok-kw">try</span> testTokenize(</span>
<span class="line" id="L1565">        <span class="tok-str">\\'\u{4a'</span></span>

<span class="line" id="L1566">    , &amp;.{.invalid});</span>
<span class="line" id="L1567"></span>
<span class="line" id="L1568">    <span class="tok-comment">// Test old-style unicode literals</span>
</span>
<span class="line" id="L1569">    <span class="tok-kw">try</span> testTokenize(</span>
<span class="line" id="L1570">        <span class="tok-str">\\'\u0333'</span></span>

<span class="line" id="L1571">    , &amp;.{ .invalid, .invalid });</span>
<span class="line" id="L1572">    <span class="tok-kw">try</span> testTokenize(</span>
<span class="line" id="L1573">        <span class="tok-str">\\'\U0333'</span></span>

<span class="line" id="L1574">    , &amp;.{ .invalid, .integer_literal, .invalid });</span>
<span class="line" id="L1575">}</span>
<span class="line" id="L1576"></span>
<span class="line" id="L1577"><span class="tok-kw">test</span> <span class="tok-str">&quot;code point literal with unicode code point&quot;</span> {</span>
<span class="line" id="L1578">    <span class="tok-kw">try</span> testTokenize(</span>
<span class="line" id="L1579">        <span class="tok-str">\\'💩'</span></span>

<span class="line" id="L1580">    , &amp;.{.char_literal});</span>
<span class="line" id="L1581">}</span>
<span class="line" id="L1582"></span>
<span class="line" id="L1583"><span class="tok-kw">test</span> <span class="tok-str">&quot;float literal e exponent&quot;</span> {</span>
<span class="line" id="L1584">    <span class="tok-kw">try</span> testTokenize(<span class="tok-str">&quot;a = 4.94065645841246544177e-324;\n&quot;</span>, &amp;.{</span>
<span class="line" id="L1585">        .identifier,</span>
<span class="line" id="L1586">        .equal,</span>
<span class="line" id="L1587">        .float_literal,</span>
<span class="line" id="L1588">        .semicolon,</span>
<span class="line" id="L1589">    });</span>
<span class="line" id="L1590">}</span>
<span class="line" id="L1591"></span>
<span class="line" id="L1592"><span class="tok-kw">test</span> <span class="tok-str">&quot;float literal p exponent&quot;</span> {</span>
<span class="line" id="L1593">    <span class="tok-kw">try</span> testTokenize(<span class="tok-str">&quot;a = 0x1.a827999fcef32p+1022;\n&quot;</span>, &amp;.{</span>
<span class="line" id="L1594">        .identifier,</span>
<span class="line" id="L1595">        .equal,</span>
<span class="line" id="L1596">        .float_literal,</span>
<span class="line" id="L1597">        .semicolon,</span>
<span class="line" id="L1598">    });</span>
<span class="line" id="L1599">}</span>
<span class="line" id="L1600"></span>
<span class="line" id="L1601"><span class="tok-kw">test</span> <span class="tok-str">&quot;chars&quot;</span> {</span>
<span class="line" id="L1602">    <span class="tok-kw">try</span> testTokenize(<span class="tok-str">&quot;'c'&quot;</span>, &amp;.{.char_literal});</span>
<span class="line" id="L1603">}</span>
<span class="line" id="L1604"></span>
<span class="line" id="L1605"><span class="tok-kw">test</span> <span class="tok-str">&quot;invalid token characters&quot;</span> {</span>
<span class="line" id="L1606">    <span class="tok-kw">try</span> testTokenize(<span class="tok-str">&quot;#&quot;</span>, &amp;.{.invalid});</span>
<span class="line" id="L1607">    <span class="tok-kw">try</span> testTokenize(<span class="tok-str">&quot;`&quot;</span>, &amp;.{.invalid});</span>
<span class="line" id="L1608">    <span class="tok-kw">try</span> testTokenize(<span class="tok-str">&quot;'c&quot;</span>, &amp;.{.invalid});</span>
<span class="line" id="L1609">    <span class="tok-kw">try</span> testTokenize(<span class="tok-str">&quot;'&quot;</span>, &amp;.{.invalid});</span>
<span class="line" id="L1610">    <span class="tok-kw">try</span> testTokenize(<span class="tok-str">&quot;''&quot;</span>, &amp;.{ .invalid, .invalid });</span>
<span class="line" id="L1611">}</span>
<span class="line" id="L1612"></span>
<span class="line" id="L1613"><span class="tok-kw">test</span> <span class="tok-str">&quot;invalid literal/comment characters&quot;</span> {</span>
<span class="line" id="L1614">    <span class="tok-kw">try</span> testTokenize(<span class="tok-str">&quot;\&quot;\x00\&quot;&quot;</span>, &amp;.{</span>
<span class="line" id="L1615">        .string_literal,</span>
<span class="line" id="L1616">        .invalid,</span>
<span class="line" id="L1617">    });</span>
<span class="line" id="L1618">    <span class="tok-kw">try</span> testTokenize(<span class="tok-str">&quot;//\x00&quot;</span>, &amp;.{</span>
<span class="line" id="L1619">        .invalid,</span>
<span class="line" id="L1620">    });</span>
<span class="line" id="L1621">    <span class="tok-kw">try</span> testTokenize(<span class="tok-str">&quot;//\x1f&quot;</span>, &amp;.{</span>
<span class="line" id="L1622">        .invalid,</span>
<span class="line" id="L1623">    });</span>
<span class="line" id="L1624">    <span class="tok-kw">try</span> testTokenize(<span class="tok-str">&quot;//\x7f&quot;</span>, &amp;.{</span>
<span class="line" id="L1625">        .invalid,</span>
<span class="line" id="L1626">    });</span>
<span class="line" id="L1627">}</span>
<span class="line" id="L1628"></span>
<span class="line" id="L1629"><span class="tok-kw">test</span> <span class="tok-str">&quot;utf8&quot;</span> {</span>
<span class="line" id="L1630">    <span class="tok-kw">try</span> testTokenize(<span class="tok-str">&quot;//\xc2\x80&quot;</span>, &amp;.{});</span>
<span class="line" id="L1631">    <span class="tok-kw">try</span> testTokenize(<span class="tok-str">&quot;//\xf4\x8f\xbf\xbf&quot;</span>, &amp;.{});</span>
<span class="line" id="L1632">}</span>
<span class="line" id="L1633"></span>
<span class="line" id="L1634"><span class="tok-kw">test</span> <span class="tok-str">&quot;invalid utf8&quot;</span> {</span>
<span class="line" id="L1635">    <span class="tok-kw">try</span> testTokenize(<span class="tok-str">&quot;//\x80&quot;</span>, &amp;.{</span>
<span class="line" id="L1636">        .invalid,</span>
<span class="line" id="L1637">    });</span>
<span class="line" id="L1638">    <span class="tok-kw">try</span> testTokenize(<span class="tok-str">&quot;//\xbf&quot;</span>, &amp;.{</span>
<span class="line" id="L1639">        .invalid,</span>
<span class="line" id="L1640">    });</span>
<span class="line" id="L1641">    <span class="tok-kw">try</span> testTokenize(<span class="tok-str">&quot;//\xf8&quot;</span>, &amp;.{</span>
<span class="line" id="L1642">        .invalid,</span>
<span class="line" id="L1643">    });</span>
<span class="line" id="L1644">    <span class="tok-kw">try</span> testTokenize(<span class="tok-str">&quot;//\xff&quot;</span>, &amp;.{</span>
<span class="line" id="L1645">        .invalid,</span>
<span class="line" id="L1646">    });</span>
<span class="line" id="L1647">    <span class="tok-kw">try</span> testTokenize(<span class="tok-str">&quot;//\xc2\xc0&quot;</span>, &amp;.{</span>
<span class="line" id="L1648">        .invalid,</span>
<span class="line" id="L1649">    });</span>
<span class="line" id="L1650">    <span class="tok-kw">try</span> testTokenize(<span class="tok-str">&quot;//\xe0&quot;</span>, &amp;.{</span>
<span class="line" id="L1651">        .invalid,</span>
<span class="line" id="L1652">    });</span>
<span class="line" id="L1653">    <span class="tok-kw">try</span> testTokenize(<span class="tok-str">&quot;//\xf0&quot;</span>, &amp;.{</span>
<span class="line" id="L1654">        .invalid,</span>
<span class="line" id="L1655">    });</span>
<span class="line" id="L1656">    <span class="tok-kw">try</span> testTokenize(<span class="tok-str">&quot;//\xf0\x90\x80\xc0&quot;</span>, &amp;.{</span>
<span class="line" id="L1657">        .invalid,</span>
<span class="line" id="L1658">    });</span>
<span class="line" id="L1659">}</span>
<span class="line" id="L1660"></span>
<span class="line" id="L1661"><span class="tok-kw">test</span> <span class="tok-str">&quot;illegal unicode codepoints&quot;</span> {</span>
<span class="line" id="L1662">    <span class="tok-comment">// unicode newline characters.U+0085, U+2028, U+2029</span>
</span>
<span class="line" id="L1663">    <span class="tok-kw">try</span> testTokenize(<span class="tok-str">&quot;//\xc2\x84&quot;</span>, &amp;.{});</span>
<span class="line" id="L1664">    <span class="tok-kw">try</span> testTokenize(<span class="tok-str">&quot;//\xc2\x85&quot;</span>, &amp;.{</span>
<span class="line" id="L1665">        .invalid,</span>
<span class="line" id="L1666">    });</span>
<span class="line" id="L1667">    <span class="tok-kw">try</span> testTokenize(<span class="tok-str">&quot;//\xc2\x86&quot;</span>, &amp;.{});</span>
<span class="line" id="L1668">    <span class="tok-kw">try</span> testTokenize(<span class="tok-str">&quot;//\xe2\x80\xa7&quot;</span>, &amp;.{});</span>
<span class="line" id="L1669">    <span class="tok-kw">try</span> testTokenize(<span class="tok-str">&quot;//\xe2\x80\xa8&quot;</span>, &amp;.{</span>
<span class="line" id="L1670">        .invalid,</span>
<span class="line" id="L1671">    });</span>
<span class="line" id="L1672">    <span class="tok-kw">try</span> testTokenize(<span class="tok-str">&quot;//\xe2\x80\xa9&quot;</span>, &amp;.{</span>
<span class="line" id="L1673">        .invalid,</span>
<span class="line" id="L1674">    });</span>
<span class="line" id="L1675">    <span class="tok-kw">try</span> testTokenize(<span class="tok-str">&quot;//\xe2\x80\xaa&quot;</span>, &amp;.{});</span>
<span class="line" id="L1676">}</span>
<span class="line" id="L1677"></span>
<span class="line" id="L1678"><span class="tok-kw">test</span> <span class="tok-str">&quot;string identifier and builtin fns&quot;</span> {</span>
<span class="line" id="L1679">    <span class="tok-kw">try</span> testTokenize(</span>
<span class="line" id="L1680">        <span class="tok-str">\\const @&quot;if&quot; = @import(&quot;std&quot;);</span></span>

<span class="line" id="L1681">    , &amp;.{</span>
<span class="line" id="L1682">        .keyword_const,</span>
<span class="line" id="L1683">        .identifier,</span>
<span class="line" id="L1684">        .equal,</span>
<span class="line" id="L1685">        .builtin,</span>
<span class="line" id="L1686">        .l_paren,</span>
<span class="line" id="L1687">        .string_literal,</span>
<span class="line" id="L1688">        .r_paren,</span>
<span class="line" id="L1689">        .semicolon,</span>
<span class="line" id="L1690">    });</span>
<span class="line" id="L1691">}</span>
<span class="line" id="L1692"></span>
<span class="line" id="L1693"><span class="tok-kw">test</span> <span class="tok-str">&quot;multiline string literal with literal tab&quot;</span> {</span>
<span class="line" id="L1694">    <span class="tok-kw">try</span> testTokenize(</span>
<span class="line" id="L1695">        <span class="tok-str">\\\\foo	bar</span></span>

<span class="line" id="L1696">    , &amp;.{</span>
<span class="line" id="L1697">        .multiline_string_literal_line,</span>
<span class="line" id="L1698">    });</span>
<span class="line" id="L1699">}</span>
<span class="line" id="L1700"></span>
<span class="line" id="L1701"><span class="tok-kw">test</span> <span class="tok-str">&quot;comments with literal tab&quot;</span> {</span>
<span class="line" id="L1702">    <span class="tok-kw">try</span> testTokenize(</span>
<span class="line" id="L1703">        <span class="tok-str">\\//foo	bar</span></span>

<span class="line" id="L1704">        <span class="tok-str">\\//!foo	bar</span></span>

<span class="line" id="L1705">        <span class="tok-str">\\///foo	bar</span></span>

<span class="line" id="L1706">        <span class="tok-str">\\//	foo</span></span>

<span class="line" id="L1707">        <span class="tok-str">\\///	foo</span></span>

<span class="line" id="L1708">        <span class="tok-str">\\///	/foo</span></span>

<span class="line" id="L1709">    , &amp;.{</span>
<span class="line" id="L1710">        .container_doc_comment,</span>
<span class="line" id="L1711">        .doc_comment,</span>
<span class="line" id="L1712">        .doc_comment,</span>
<span class="line" id="L1713">        .doc_comment,</span>
<span class="line" id="L1714">    });</span>
<span class="line" id="L1715">}</span>
<span class="line" id="L1716"></span>
<span class="line" id="L1717"><span class="tok-kw">test</span> <span class="tok-str">&quot;pipe and then invalid&quot;</span> {</span>
<span class="line" id="L1718">    <span class="tok-kw">try</span> testTokenize(<span class="tok-str">&quot;||=&quot;</span>, &amp;.{</span>
<span class="line" id="L1719">        .pipe_pipe,</span>
<span class="line" id="L1720">        .equal,</span>
<span class="line" id="L1721">    });</span>
<span class="line" id="L1722">}</span>
<span class="line" id="L1723"></span>
<span class="line" id="L1724"><span class="tok-kw">test</span> <span class="tok-str">&quot;line comment and doc comment&quot;</span> {</span>
<span class="line" id="L1725">    <span class="tok-kw">try</span> testTokenize(<span class="tok-str">&quot;//&quot;</span>, &amp;.{});</span>
<span class="line" id="L1726">    <span class="tok-kw">try</span> testTokenize(<span class="tok-str">&quot;// a / b&quot;</span>, &amp;.{});</span>
<span class="line" id="L1727">    <span class="tok-kw">try</span> testTokenize(<span class="tok-str">&quot;// /&quot;</span>, &amp;.{});</span>
<span class="line" id="L1728">    <span class="tok-kw">try</span> testTokenize(<span class="tok-str">&quot;/// a&quot;</span>, &amp;.{.doc_comment});</span>
<span class="line" id="L1729">    <span class="tok-kw">try</span> testTokenize(<span class="tok-str">&quot;///&quot;</span>, &amp;.{.doc_comment});</span>
<span class="line" id="L1730">    <span class="tok-kw">try</span> testTokenize(<span class="tok-str">&quot;////&quot;</span>, &amp;.{});</span>
<span class="line" id="L1731">    <span class="tok-kw">try</span> testTokenize(<span class="tok-str">&quot;//!&quot;</span>, &amp;.{.container_doc_comment});</span>
<span class="line" id="L1732">    <span class="tok-kw">try</span> testTokenize(<span class="tok-str">&quot;//!!&quot;</span>, &amp;.{.container_doc_comment});</span>
<span class="line" id="L1733">}</span>
<span class="line" id="L1734"></span>
<span class="line" id="L1735"><span class="tok-kw">test</span> <span class="tok-str">&quot;line comment followed by identifier&quot;</span> {</span>
<span class="line" id="L1736">    <span class="tok-kw">try</span> testTokenize(</span>
<span class="line" id="L1737">        <span class="tok-str">\\    Unexpected,</span></span>

<span class="line" id="L1738">        <span class="tok-str">\\    // another</span></span>

<span class="line" id="L1739">        <span class="tok-str">\\    Another,</span></span>

<span class="line" id="L1740">    , &amp;.{</span>
<span class="line" id="L1741">        .identifier,</span>
<span class="line" id="L1742">        .comma,</span>
<span class="line" id="L1743">        .identifier,</span>
<span class="line" id="L1744">        .comma,</span>
<span class="line" id="L1745">    });</span>
<span class="line" id="L1746">}</span>
<span class="line" id="L1747"></span>
<span class="line" id="L1748"><span class="tok-kw">test</span> <span class="tok-str">&quot;UTF-8 BOM is recognized and skipped&quot;</span> {</span>
<span class="line" id="L1749">    <span class="tok-kw">try</span> testTokenize(<span class="tok-str">&quot;\xEF\xBB\xBFa;\n&quot;</span>, &amp;.{</span>
<span class="line" id="L1750">        .identifier,</span>
<span class="line" id="L1751">        .semicolon,</span>
<span class="line" id="L1752">    });</span>
<span class="line" id="L1753">}</span>
<span class="line" id="L1754"></span>
<span class="line" id="L1755"><span class="tok-kw">test</span> <span class="tok-str">&quot;correctly parse pointer assignment&quot;</span> {</span>
<span class="line" id="L1756">    <span class="tok-kw">try</span> testTokenize(<span class="tok-str">&quot;b.*=3;\n&quot;</span>, &amp;.{</span>
<span class="line" id="L1757">        .identifier,</span>
<span class="line" id="L1758">        .period_asterisk,</span>
<span class="line" id="L1759">        .equal,</span>
<span class="line" id="L1760">        .integer_literal,</span>
<span class="line" id="L1761">        .semicolon,</span>
<span class="line" id="L1762">    });</span>
<span class="line" id="L1763">}</span>
<span class="line" id="L1764"></span>
<span class="line" id="L1765"><span class="tok-kw">test</span> <span class="tok-str">&quot;correctly parse pointer dereference followed by asterisk&quot;</span> {</span>
<span class="line" id="L1766">    <span class="tok-kw">try</span> testTokenize(<span class="tok-str">&quot;\&quot;b\&quot;.* ** 10&quot;</span>, &amp;.{</span>
<span class="line" id="L1767">        .string_literal,</span>
<span class="line" id="L1768">        .period_asterisk,</span>
<span class="line" id="L1769">        .asterisk_asterisk,</span>
<span class="line" id="L1770">        .integer_literal,</span>
<span class="line" id="L1771">    });</span>
<span class="line" id="L1772"></span>
<span class="line" id="L1773">    <span class="tok-kw">try</span> testTokenize(<span class="tok-str">&quot;(\&quot;b\&quot;.*)** 10&quot;</span>, &amp;.{</span>
<span class="line" id="L1774">        .l_paren,</span>
<span class="line" id="L1775">        .string_literal,</span>
<span class="line" id="L1776">        .period_asterisk,</span>
<span class="line" id="L1777">        .r_paren,</span>
<span class="line" id="L1778">        .asterisk_asterisk,</span>
<span class="line" id="L1779">        .integer_literal,</span>
<span class="line" id="L1780">    });</span>
<span class="line" id="L1781"></span>
<span class="line" id="L1782">    <span class="tok-kw">try</span> testTokenize(<span class="tok-str">&quot;\&quot;b\&quot;.*** 10&quot;</span>, &amp;.{</span>
<span class="line" id="L1783">        .string_literal,</span>
<span class="line" id="L1784">        .invalid_periodasterisks,</span>
<span class="line" id="L1785">        .asterisk_asterisk,</span>
<span class="line" id="L1786">        .integer_literal,</span>
<span class="line" id="L1787">    });</span>
<span class="line" id="L1788">}</span>
<span class="line" id="L1789"></span>
<span class="line" id="L1790"><span class="tok-kw">test</span> <span class="tok-str">&quot;range literals&quot;</span> {</span>
<span class="line" id="L1791">    <span class="tok-kw">try</span> testTokenize(<span class="tok-str">&quot;0...9&quot;</span>, &amp;.{ .integer_literal, .ellipsis3, .integer_literal });</span>
<span class="line" id="L1792">    <span class="tok-kw">try</span> testTokenize(<span class="tok-str">&quot;'0'...'9'&quot;</span>, &amp;.{ .char_literal, .ellipsis3, .char_literal });</span>
<span class="line" id="L1793">    <span class="tok-kw">try</span> testTokenize(<span class="tok-str">&quot;0x00...0x09&quot;</span>, &amp;.{ .integer_literal, .ellipsis3, .integer_literal });</span>
<span class="line" id="L1794">    <span class="tok-kw">try</span> testTokenize(<span class="tok-str">&quot;0b00...0b11&quot;</span>, &amp;.{ .integer_literal, .ellipsis3, .integer_literal });</span>
<span class="line" id="L1795">    <span class="tok-kw">try</span> testTokenize(<span class="tok-str">&quot;0o00...0o11&quot;</span>, &amp;.{ .integer_literal, .ellipsis3, .integer_literal });</span>
<span class="line" id="L1796">}</span>
<span class="line" id="L1797"></span>
<span class="line" id="L1798"><span class="tok-kw">test</span> <span class="tok-str">&quot;number literals decimal&quot;</span> {</span>
<span class="line" id="L1799">    <span class="tok-kw">try</span> testTokenize(<span class="tok-str">&quot;0&quot;</span>, &amp;.{.integer_literal});</span>
<span class="line" id="L1800">    <span class="tok-kw">try</span> testTokenize(<span class="tok-str">&quot;1&quot;</span>, &amp;.{.integer_literal});</span>
<span class="line" id="L1801">    <span class="tok-kw">try</span> testTokenize(<span class="tok-str">&quot;2&quot;</span>, &amp;.{.integer_literal});</span>
<span class="line" id="L1802">    <span class="tok-kw">try</span> testTokenize(<span class="tok-str">&quot;3&quot;</span>, &amp;.{.integer_literal});</span>
<span class="line" id="L1803">    <span class="tok-kw">try</span> testTokenize(<span class="tok-str">&quot;4&quot;</span>, &amp;.{.integer_literal});</span>
<span class="line" id="L1804">    <span class="tok-kw">try</span> testTokenize(<span class="tok-str">&quot;5&quot;</span>, &amp;.{.integer_literal});</span>
<span class="line" id="L1805">    <span class="tok-kw">try</span> testTokenize(<span class="tok-str">&quot;6&quot;</span>, &amp;.{.integer_literal});</span>
<span class="line" id="L1806">    <span class="tok-kw">try</span> testTokenize(<span class="tok-str">&quot;7&quot;</span>, &amp;.{.integer_literal});</span>
<span class="line" id="L1807">    <span class="tok-kw">try</span> testTokenize(<span class="tok-str">&quot;8&quot;</span>, &amp;.{.integer_literal});</span>
<span class="line" id="L1808">    <span class="tok-kw">try</span> testTokenize(<span class="tok-str">&quot;9&quot;</span>, &amp;.{.integer_literal});</span>
<span class="line" id="L1809">    <span class="tok-kw">try</span> testTokenize(<span class="tok-str">&quot;1..&quot;</span>, &amp;.{ .integer_literal, .ellipsis2 });</span>
<span class="line" id="L1810">    <span class="tok-kw">try</span> testTokenize(<span class="tok-str">&quot;0a&quot;</span>, &amp;.{ .invalid, .identifier });</span>
<span class="line" id="L1811">    <span class="tok-kw">try</span> testTokenize(<span class="tok-str">&quot;9b&quot;</span>, &amp;.{ .invalid, .identifier });</span>
<span class="line" id="L1812">    <span class="tok-kw">try</span> testTokenize(<span class="tok-str">&quot;1z&quot;</span>, &amp;.{ .invalid, .identifier });</span>
<span class="line" id="L1813">    <span class="tok-kw">try</span> testTokenize(<span class="tok-str">&quot;1z_1&quot;</span>, &amp;.{ .invalid, .identifier });</span>
<span class="line" id="L1814">    <span class="tok-kw">try</span> testTokenize(<span class="tok-str">&quot;9z3&quot;</span>, &amp;.{ .invalid, .identifier });</span>
<span class="line" id="L1815"></span>
<span class="line" id="L1816">    <span class="tok-kw">try</span> testTokenize(<span class="tok-str">&quot;0_0&quot;</span>, &amp;.{.integer_literal});</span>
<span class="line" id="L1817">    <span class="tok-kw">try</span> testTokenize(<span class="tok-str">&quot;0001&quot;</span>, &amp;.{.integer_literal});</span>
<span class="line" id="L1818">    <span class="tok-kw">try</span> testTokenize(<span class="tok-str">&quot;01234567890&quot;</span>, &amp;.{.integer_literal});</span>
<span class="line" id="L1819">    <span class="tok-kw">try</span> testTokenize(<span class="tok-str">&quot;012_345_6789_0&quot;</span>, &amp;.{.integer_literal});</span>
<span class="line" id="L1820">    <span class="tok-kw">try</span> testTokenize(<span class="tok-str">&quot;0_1_2_3_4_5_6_7_8_9_0&quot;</span>, &amp;.{.integer_literal});</span>
<span class="line" id="L1821"></span>
<span class="line" id="L1822">    <span class="tok-kw">try</span> testTokenize(<span class="tok-str">&quot;00_&quot;</span>, &amp;.{.invalid});</span>
<span class="line" id="L1823">    <span class="tok-kw">try</span> testTokenize(<span class="tok-str">&quot;0_0_&quot;</span>, &amp;.{.invalid});</span>
<span class="line" id="L1824">    <span class="tok-kw">try</span> testTokenize(<span class="tok-str">&quot;0__0&quot;</span>, &amp;.{ .invalid, .identifier });</span>
<span class="line" id="L1825">    <span class="tok-kw">try</span> testTokenize(<span class="tok-str">&quot;0_0f&quot;</span>, &amp;.{ .invalid, .identifier });</span>
<span class="line" id="L1826">    <span class="tok-kw">try</span> testTokenize(<span class="tok-str">&quot;0_0_f&quot;</span>, &amp;.{ .invalid, .identifier });</span>
<span class="line" id="L1827">    <span class="tok-kw">try</span> testTokenize(<span class="tok-str">&quot;0_0_f_00&quot;</span>, &amp;.{ .invalid, .identifier });</span>
<span class="line" id="L1828">    <span class="tok-kw">try</span> testTokenize(<span class="tok-str">&quot;1_,&quot;</span>, &amp;.{ .invalid, .comma });</span>
<span class="line" id="L1829"></span>
<span class="line" id="L1830">    <span class="tok-kw">try</span> testTokenize(<span class="tok-str">&quot;0.0&quot;</span>, &amp;.{.float_literal});</span>
<span class="line" id="L1831">    <span class="tok-kw">try</span> testTokenize(<span class="tok-str">&quot;1.0&quot;</span>, &amp;.{.float_literal});</span>
<span class="line" id="L1832">    <span class="tok-kw">try</span> testTokenize(<span class="tok-str">&quot;10.0&quot;</span>, &amp;.{.float_literal});</span>
<span class="line" id="L1833">    <span class="tok-kw">try</span> testTokenize(<span class="tok-str">&quot;0e0&quot;</span>, &amp;.{.float_literal});</span>
<span class="line" id="L1834">    <span class="tok-kw">try</span> testTokenize(<span class="tok-str">&quot;1e0&quot;</span>, &amp;.{.float_literal});</span>
<span class="line" id="L1835">    <span class="tok-kw">try</span> testTokenize(<span class="tok-str">&quot;1e100&quot;</span>, &amp;.{.float_literal});</span>
<span class="line" id="L1836">    <span class="tok-kw">try</span> testTokenize(<span class="tok-str">&quot;1.0e100&quot;</span>, &amp;.{.float_literal});</span>
<span class="line" id="L1837">    <span class="tok-kw">try</span> testTokenize(<span class="tok-str">&quot;1.0e+100&quot;</span>, &amp;.{.float_literal});</span>
<span class="line" id="L1838">    <span class="tok-kw">try</span> testTokenize(<span class="tok-str">&quot;1.0e-100&quot;</span>, &amp;.{.float_literal});</span>
<span class="line" id="L1839">    <span class="tok-kw">try</span> testTokenize(<span class="tok-str">&quot;1_0_0_0.0_0_0_0_0_1e1_0_0_0&quot;</span>, &amp;.{.float_literal});</span>
<span class="line" id="L1840"></span>
<span class="line" id="L1841">    <span class="tok-kw">try</span> testTokenize(<span class="tok-str">&quot;1.&quot;</span>, &amp;.{.invalid});</span>
<span class="line" id="L1842">    <span class="tok-kw">try</span> testTokenize(<span class="tok-str">&quot;1e&quot;</span>, &amp;.{.invalid});</span>
<span class="line" id="L1843">    <span class="tok-kw">try</span> testTokenize(<span class="tok-str">&quot;1.e100&quot;</span>, &amp;.{ .invalid, .identifier });</span>
<span class="line" id="L1844">    <span class="tok-kw">try</span> testTokenize(<span class="tok-str">&quot;1.0e1f0&quot;</span>, &amp;.{ .invalid, .identifier });</span>
<span class="line" id="L1845">    <span class="tok-kw">try</span> testTokenize(<span class="tok-str">&quot;1.0p100&quot;</span>, &amp;.{ .invalid, .identifier });</span>
<span class="line" id="L1846">    <span class="tok-kw">try</span> testTokenize(<span class="tok-str">&quot;1.0p-100&quot;</span>, &amp;.{ .invalid, .identifier, .minus, .integer_literal });</span>
<span class="line" id="L1847">    <span class="tok-kw">try</span> testTokenize(<span class="tok-str">&quot;1.0p1f0&quot;</span>, &amp;.{ .invalid, .identifier });</span>
<span class="line" id="L1848">    <span class="tok-kw">try</span> testTokenize(<span class="tok-str">&quot;1.0_,&quot;</span>, &amp;.{ .invalid, .comma });</span>
<span class="line" id="L1849">    <span class="tok-kw">try</span> testTokenize(<span class="tok-str">&quot;1_.0&quot;</span>, &amp;.{ .invalid, .period, .integer_literal });</span>
<span class="line" id="L1850">    <span class="tok-kw">try</span> testTokenize(<span class="tok-str">&quot;1._&quot;</span>, &amp;.{ .invalid, .identifier });</span>
<span class="line" id="L1851">    <span class="tok-kw">try</span> testTokenize(<span class="tok-str">&quot;1.a&quot;</span>, &amp;.{ .invalid, .identifier });</span>
<span class="line" id="L1852">    <span class="tok-kw">try</span> testTokenize(<span class="tok-str">&quot;1.z&quot;</span>, &amp;.{ .invalid, .identifier });</span>
<span class="line" id="L1853">    <span class="tok-kw">try</span> testTokenize(<span class="tok-str">&quot;1._0&quot;</span>, &amp;.{ .invalid, .identifier });</span>
<span class="line" id="L1854">    <span class="tok-kw">try</span> testTokenize(<span class="tok-str">&quot;1.+&quot;</span>, &amp;.{ .invalid, .plus });</span>
<span class="line" id="L1855">    <span class="tok-kw">try</span> testTokenize(<span class="tok-str">&quot;1._+&quot;</span>, &amp;.{ .invalid, .identifier, .plus });</span>
<span class="line" id="L1856">    <span class="tok-kw">try</span> testTokenize(<span class="tok-str">&quot;1._e&quot;</span>, &amp;.{ .invalid, .identifier });</span>
<span class="line" id="L1857">    <span class="tok-kw">try</span> testTokenize(<span class="tok-str">&quot;1.0e&quot;</span>, &amp;.{.invalid});</span>
<span class="line" id="L1858">    <span class="tok-kw">try</span> testTokenize(<span class="tok-str">&quot;1.0e,&quot;</span>, &amp;.{ .invalid, .comma });</span>
<span class="line" id="L1859">    <span class="tok-kw">try</span> testTokenize(<span class="tok-str">&quot;1.0e_&quot;</span>, &amp;.{ .invalid, .identifier });</span>
<span class="line" id="L1860">    <span class="tok-kw">try</span> testTokenize(<span class="tok-str">&quot;1.0e+_&quot;</span>, &amp;.{ .invalid, .identifier });</span>
<span class="line" id="L1861">    <span class="tok-kw">try</span> testTokenize(<span class="tok-str">&quot;1.0e-_&quot;</span>, &amp;.{ .invalid, .identifier });</span>
<span class="line" id="L1862">    <span class="tok-kw">try</span> testTokenize(<span class="tok-str">&quot;1.0e0_+&quot;</span>, &amp;.{ .invalid, .plus });</span>
<span class="line" id="L1863">}</span>
<span class="line" id="L1864"></span>
<span class="line" id="L1865"><span class="tok-kw">test</span> <span class="tok-str">&quot;number literals binary&quot;</span> {</span>
<span class="line" id="L1866">    <span class="tok-kw">try</span> testTokenize(<span class="tok-str">&quot;0b0&quot;</span>, &amp;.{.integer_literal});</span>
<span class="line" id="L1867">    <span class="tok-kw">try</span> testTokenize(<span class="tok-str">&quot;0b1&quot;</span>, &amp;.{.integer_literal});</span>
<span class="line" id="L1868">    <span class="tok-kw">try</span> testTokenize(<span class="tok-str">&quot;0b2&quot;</span>, &amp;.{ .invalid, .integer_literal });</span>
<span class="line" id="L1869">    <span class="tok-kw">try</span> testTokenize(<span class="tok-str">&quot;0b3&quot;</span>, &amp;.{ .invalid, .integer_literal });</span>
<span class="line" id="L1870">    <span class="tok-kw">try</span> testTokenize(<span class="tok-str">&quot;0b4&quot;</span>, &amp;.{ .invalid, .integer_literal });</span>
<span class="line" id="L1871">    <span class="tok-kw">try</span> testTokenize(<span class="tok-str">&quot;0b5&quot;</span>, &amp;.{ .invalid, .integer_literal });</span>
<span class="line" id="L1872">    <span class="tok-kw">try</span> testTokenize(<span class="tok-str">&quot;0b6&quot;</span>, &amp;.{ .invalid, .integer_literal });</span>
<span class="line" id="L1873">    <span class="tok-kw">try</span> testTokenize(<span class="tok-str">&quot;0b7&quot;</span>, &amp;.{ .invalid, .integer_literal });</span>
<span class="line" id="L1874">    <span class="tok-kw">try</span> testTokenize(<span class="tok-str">&quot;0b8&quot;</span>, &amp;.{ .invalid, .integer_literal });</span>
<span class="line" id="L1875">    <span class="tok-kw">try</span> testTokenize(<span class="tok-str">&quot;0b9&quot;</span>, &amp;.{ .invalid, .integer_literal });</span>
<span class="line" id="L1876">    <span class="tok-kw">try</span> testTokenize(<span class="tok-str">&quot;0ba&quot;</span>, &amp;.{ .invalid, .identifier });</span>
<span class="line" id="L1877">    <span class="tok-kw">try</span> testTokenize(<span class="tok-str">&quot;0bb&quot;</span>, &amp;.{ .invalid, .identifier });</span>
<span class="line" id="L1878">    <span class="tok-kw">try</span> testTokenize(<span class="tok-str">&quot;0bc&quot;</span>, &amp;.{ .invalid, .identifier });</span>
<span class="line" id="L1879">    <span class="tok-kw">try</span> testTokenize(<span class="tok-str">&quot;0bd&quot;</span>, &amp;.{ .invalid, .identifier });</span>
<span class="line" id="L1880">    <span class="tok-kw">try</span> testTokenize(<span class="tok-str">&quot;0be&quot;</span>, &amp;.{ .invalid, .identifier });</span>
<span class="line" id="L1881">    <span class="tok-kw">try</span> testTokenize(<span class="tok-str">&quot;0bf&quot;</span>, &amp;.{ .invalid, .identifier });</span>
<span class="line" id="L1882">    <span class="tok-kw">try</span> testTokenize(<span class="tok-str">&quot;0bz&quot;</span>, &amp;.{ .invalid, .identifier });</span>
<span class="line" id="L1883"></span>
<span class="line" id="L1884">    <span class="tok-kw">try</span> testTokenize(<span class="tok-str">&quot;0b0000_0000&quot;</span>, &amp;.{.integer_literal});</span>
<span class="line" id="L1885">    <span class="tok-kw">try</span> testTokenize(<span class="tok-str">&quot;0b1111_1111&quot;</span>, &amp;.{.integer_literal});</span>
<span class="line" id="L1886">    <span class="tok-kw">try</span> testTokenize(<span class="tok-str">&quot;0b10_10_10_10&quot;</span>, &amp;.{.integer_literal});</span>
<span class="line" id="L1887">    <span class="tok-kw">try</span> testTokenize(<span class="tok-str">&quot;0b0_1_0_1_0_1_0_1&quot;</span>, &amp;.{.integer_literal});</span>
<span class="line" id="L1888">    <span class="tok-kw">try</span> testTokenize(<span class="tok-str">&quot;0b1.&quot;</span>, &amp;.{ .integer_literal, .period });</span>
<span class="line" id="L1889">    <span class="tok-kw">try</span> testTokenize(<span class="tok-str">&quot;0b1.0&quot;</span>, &amp;.{ .integer_literal, .period, .integer_literal });</span>
<span class="line" id="L1890"></span>
<span class="line" id="L1891">    <span class="tok-kw">try</span> testTokenize(<span class="tok-str">&quot;0B0&quot;</span>, &amp;.{ .invalid, .identifier });</span>
<span class="line" id="L1892">    <span class="tok-kw">try</span> testTokenize(<span class="tok-str">&quot;0b_&quot;</span>, &amp;.{ .invalid, .identifier });</span>
<span class="line" id="L1893">    <span class="tok-kw">try</span> testTokenize(<span class="tok-str">&quot;0b_0&quot;</span>, &amp;.{ .invalid, .identifier });</span>
<span class="line" id="L1894">    <span class="tok-kw">try</span> testTokenize(<span class="tok-str">&quot;0b1_&quot;</span>, &amp;.{.invalid});</span>
<span class="line" id="L1895">    <span class="tok-kw">try</span> testTokenize(<span class="tok-str">&quot;0b0__1&quot;</span>, &amp;.{ .invalid, .identifier });</span>
<span class="line" id="L1896">    <span class="tok-kw">try</span> testTokenize(<span class="tok-str">&quot;0b0_1_&quot;</span>, &amp;.{.invalid});</span>
<span class="line" id="L1897">    <span class="tok-kw">try</span> testTokenize(<span class="tok-str">&quot;0b1e&quot;</span>, &amp;.{ .invalid, .identifier });</span>
<span class="line" id="L1898">    <span class="tok-kw">try</span> testTokenize(<span class="tok-str">&quot;0b1p&quot;</span>, &amp;.{ .invalid, .identifier });</span>
<span class="line" id="L1899">    <span class="tok-kw">try</span> testTokenize(<span class="tok-str">&quot;0b1e0&quot;</span>, &amp;.{ .invalid, .identifier });</span>
<span class="line" id="L1900">    <span class="tok-kw">try</span> testTokenize(<span class="tok-str">&quot;0b1p0&quot;</span>, &amp;.{ .invalid, .identifier });</span>
<span class="line" id="L1901">    <span class="tok-kw">try</span> testTokenize(<span class="tok-str">&quot;0b1_,&quot;</span>, &amp;.{ .invalid, .comma });</span>
<span class="line" id="L1902">}</span>
<span class="line" id="L1903"></span>
<span class="line" id="L1904"><span class="tok-kw">test</span> <span class="tok-str">&quot;number literals octal&quot;</span> {</span>
<span class="line" id="L1905">    <span class="tok-kw">try</span> testTokenize(<span class="tok-str">&quot;0o0&quot;</span>, &amp;.{.integer_literal});</span>
<span class="line" id="L1906">    <span class="tok-kw">try</span> testTokenize(<span class="tok-str">&quot;0o1&quot;</span>, &amp;.{.integer_literal});</span>
<span class="line" id="L1907">    <span class="tok-kw">try</span> testTokenize(<span class="tok-str">&quot;0o2&quot;</span>, &amp;.{.integer_literal});</span>
<span class="line" id="L1908">    <span class="tok-kw">try</span> testTokenize(<span class="tok-str">&quot;0o3&quot;</span>, &amp;.{.integer_literal});</span>
<span class="line" id="L1909">    <span class="tok-kw">try</span> testTokenize(<span class="tok-str">&quot;0o4&quot;</span>, &amp;.{.integer_literal});</span>
<span class="line" id="L1910">    <span class="tok-kw">try</span> testTokenize(<span class="tok-str">&quot;0o5&quot;</span>, &amp;.{.integer_literal});</span>
<span class="line" id="L1911">    <span class="tok-kw">try</span> testTokenize(<span class="tok-str">&quot;0o6&quot;</span>, &amp;.{.integer_literal});</span>
<span class="line" id="L1912">    <span class="tok-kw">try</span> testTokenize(<span class="tok-str">&quot;0o7&quot;</span>, &amp;.{.integer_literal});</span>
<span class="line" id="L1913">    <span class="tok-kw">try</span> testTokenize(<span class="tok-str">&quot;0o8&quot;</span>, &amp;.{ .invalid, .integer_literal });</span>
<span class="line" id="L1914">    <span class="tok-kw">try</span> testTokenize(<span class="tok-str">&quot;0o9&quot;</span>, &amp;.{ .invalid, .integer_literal });</span>
<span class="line" id="L1915">    <span class="tok-kw">try</span> testTokenize(<span class="tok-str">&quot;0oa&quot;</span>, &amp;.{ .invalid, .identifier });</span>
<span class="line" id="L1916">    <span class="tok-kw">try</span> testTokenize(<span class="tok-str">&quot;0ob&quot;</span>, &amp;.{ .invalid, .identifier });</span>
<span class="line" id="L1917">    <span class="tok-kw">try</span> testTokenize(<span class="tok-str">&quot;0oc&quot;</span>, &amp;.{ .invalid, .identifier });</span>
<span class="line" id="L1918">    <span class="tok-kw">try</span> testTokenize(<span class="tok-str">&quot;0od&quot;</span>, &amp;.{ .invalid, .identifier });</span>
<span class="line" id="L1919">    <span class="tok-kw">try</span> testTokenize(<span class="tok-str">&quot;0oe&quot;</span>, &amp;.{ .invalid, .identifier });</span>
<span class="line" id="L1920">    <span class="tok-kw">try</span> testTokenize(<span class="tok-str">&quot;0of&quot;</span>, &amp;.{ .invalid, .identifier });</span>
<span class="line" id="L1921">    <span class="tok-kw">try</span> testTokenize(<span class="tok-str">&quot;0oz&quot;</span>, &amp;.{ .invalid, .identifier });</span>
<span class="line" id="L1922"></span>
<span class="line" id="L1923">    <span class="tok-kw">try</span> testTokenize(<span class="tok-str">&quot;0o01234567&quot;</span>, &amp;.{.integer_literal});</span>
<span class="line" id="L1924">    <span class="tok-kw">try</span> testTokenize(<span class="tok-str">&quot;0o0123_4567&quot;</span>, &amp;.{.integer_literal});</span>
<span class="line" id="L1925">    <span class="tok-kw">try</span> testTokenize(<span class="tok-str">&quot;0o01_23_45_67&quot;</span>, &amp;.{.integer_literal});</span>
<span class="line" id="L1926">    <span class="tok-kw">try</span> testTokenize(<span class="tok-str">&quot;0o0_1_2_3_4_5_6_7&quot;</span>, &amp;.{.integer_literal});</span>
<span class="line" id="L1927">    <span class="tok-kw">try</span> testTokenize(<span class="tok-str">&quot;0o7.&quot;</span>, &amp;.{ .integer_literal, .period });</span>
<span class="line" id="L1928">    <span class="tok-kw">try</span> testTokenize(<span class="tok-str">&quot;0o7.0&quot;</span>, &amp;.{ .integer_literal, .period, .integer_literal });</span>
<span class="line" id="L1929"></span>
<span class="line" id="L1930">    <span class="tok-kw">try</span> testTokenize(<span class="tok-str">&quot;0O0&quot;</span>, &amp;.{ .invalid, .identifier });</span>
<span class="line" id="L1931">    <span class="tok-kw">try</span> testTokenize(<span class="tok-str">&quot;0o_&quot;</span>, &amp;.{ .invalid, .identifier });</span>
<span class="line" id="L1932">    <span class="tok-kw">try</span> testTokenize(<span class="tok-str">&quot;0o_0&quot;</span>, &amp;.{ .invalid, .identifier });</span>
<span class="line" id="L1933">    <span class="tok-kw">try</span> testTokenize(<span class="tok-str">&quot;0o1_&quot;</span>, &amp;.{.invalid});</span>
<span class="line" id="L1934">    <span class="tok-kw">try</span> testTokenize(<span class="tok-str">&quot;0o0__1&quot;</span>, &amp;.{ .invalid, .identifier });</span>
<span class="line" id="L1935">    <span class="tok-kw">try</span> testTokenize(<span class="tok-str">&quot;0o0_1_&quot;</span>, &amp;.{.invalid});</span>
<span class="line" id="L1936">    <span class="tok-kw">try</span> testTokenize(<span class="tok-str">&quot;0o1e&quot;</span>, &amp;.{ .invalid, .identifier });</span>
<span class="line" id="L1937">    <span class="tok-kw">try</span> testTokenize(<span class="tok-str">&quot;0o1p&quot;</span>, &amp;.{ .invalid, .identifier });</span>
<span class="line" id="L1938">    <span class="tok-kw">try</span> testTokenize(<span class="tok-str">&quot;0o1e0&quot;</span>, &amp;.{ .invalid, .identifier });</span>
<span class="line" id="L1939">    <span class="tok-kw">try</span> testTokenize(<span class="tok-str">&quot;0o1p0&quot;</span>, &amp;.{ .invalid, .identifier });</span>
<span class="line" id="L1940">    <span class="tok-kw">try</span> testTokenize(<span class="tok-str">&quot;0o_,&quot;</span>, &amp;.{ .invalid, .identifier, .comma });</span>
<span class="line" id="L1941">}</span>
<span class="line" id="L1942"></span>
<span class="line" id="L1943"><span class="tok-kw">test</span> <span class="tok-str">&quot;number literals hexadecimal&quot;</span> {</span>
<span class="line" id="L1944">    <span class="tok-kw">try</span> testTokenize(<span class="tok-str">&quot;0x0&quot;</span>, &amp;.{.integer_literal});</span>
<span class="line" id="L1945">    <span class="tok-kw">try</span> testTokenize(<span class="tok-str">&quot;0x1&quot;</span>, &amp;.{.integer_literal});</span>
<span class="line" id="L1946">    <span class="tok-kw">try</span> testTokenize(<span class="tok-str">&quot;0x2&quot;</span>, &amp;.{.integer_literal});</span>
<span class="line" id="L1947">    <span class="tok-kw">try</span> testTokenize(<span class="tok-str">&quot;0x3&quot;</span>, &amp;.{.integer_literal});</span>
<span class="line" id="L1948">    <span class="tok-kw">try</span> testTokenize(<span class="tok-str">&quot;0x4&quot;</span>, &amp;.{.integer_literal});</span>
<span class="line" id="L1949">    <span class="tok-kw">try</span> testTokenize(<span class="tok-str">&quot;0x5&quot;</span>, &amp;.{.integer_literal});</span>
<span class="line" id="L1950">    <span class="tok-kw">try</span> testTokenize(<span class="tok-str">&quot;0x6&quot;</span>, &amp;.{.integer_literal});</span>
<span class="line" id="L1951">    <span class="tok-kw">try</span> testTokenize(<span class="tok-str">&quot;0x7&quot;</span>, &amp;.{.integer_literal});</span>
<span class="line" id="L1952">    <span class="tok-kw">try</span> testTokenize(<span class="tok-str">&quot;0x8&quot;</span>, &amp;.{.integer_literal});</span>
<span class="line" id="L1953">    <span class="tok-kw">try</span> testTokenize(<span class="tok-str">&quot;0x9&quot;</span>, &amp;.{.integer_literal});</span>
<span class="line" id="L1954">    <span class="tok-kw">try</span> testTokenize(<span class="tok-str">&quot;0xa&quot;</span>, &amp;.{.integer_literal});</span>
<span class="line" id="L1955">    <span class="tok-kw">try</span> testTokenize(<span class="tok-str">&quot;0xb&quot;</span>, &amp;.{.integer_literal});</span>
<span class="line" id="L1956">    <span class="tok-kw">try</span> testTokenize(<span class="tok-str">&quot;0xc&quot;</span>, &amp;.{.integer_literal});</span>
<span class="line" id="L1957">    <span class="tok-kw">try</span> testTokenize(<span class="tok-str">&quot;0xd&quot;</span>, &amp;.{.integer_literal});</span>
<span class="line" id="L1958">    <span class="tok-kw">try</span> testTokenize(<span class="tok-str">&quot;0xe&quot;</span>, &amp;.{.integer_literal});</span>
<span class="line" id="L1959">    <span class="tok-kw">try</span> testTokenize(<span class="tok-str">&quot;0xf&quot;</span>, &amp;.{.integer_literal});</span>
<span class="line" id="L1960">    <span class="tok-kw">try</span> testTokenize(<span class="tok-str">&quot;0xA&quot;</span>, &amp;.{.integer_literal});</span>
<span class="line" id="L1961">    <span class="tok-kw">try</span> testTokenize(<span class="tok-str">&quot;0xB&quot;</span>, &amp;.{.integer_literal});</span>
<span class="line" id="L1962">    <span class="tok-kw">try</span> testTokenize(<span class="tok-str">&quot;0xC&quot;</span>, &amp;.{.integer_literal});</span>
<span class="line" id="L1963">    <span class="tok-kw">try</span> testTokenize(<span class="tok-str">&quot;0xD&quot;</span>, &amp;.{.integer_literal});</span>
<span class="line" id="L1964">    <span class="tok-kw">try</span> testTokenize(<span class="tok-str">&quot;0xE&quot;</span>, &amp;.{.integer_literal});</span>
<span class="line" id="L1965">    <span class="tok-kw">try</span> testTokenize(<span class="tok-str">&quot;0xF&quot;</span>, &amp;.{.integer_literal});</span>
<span class="line" id="L1966">    <span class="tok-kw">try</span> testTokenize(<span class="tok-str">&quot;0x0z&quot;</span>, &amp;.{ .invalid, .identifier });</span>
<span class="line" id="L1967">    <span class="tok-kw">try</span> testTokenize(<span class="tok-str">&quot;0xz&quot;</span>, &amp;.{ .invalid, .identifier });</span>
<span class="line" id="L1968"></span>
<span class="line" id="L1969">    <span class="tok-kw">try</span> testTokenize(<span class="tok-str">&quot;0x0123456789ABCDEF&quot;</span>, &amp;.{.integer_literal});</span>
<span class="line" id="L1970">    <span class="tok-kw">try</span> testTokenize(<span class="tok-str">&quot;0x0123_4567_89AB_CDEF&quot;</span>, &amp;.{.integer_literal});</span>
<span class="line" id="L1971">    <span class="tok-kw">try</span> testTokenize(<span class="tok-str">&quot;0x01_23_45_67_89AB_CDE_F&quot;</span>, &amp;.{.integer_literal});</span>
<span class="line" id="L1972">    <span class="tok-kw">try</span> testTokenize(<span class="tok-str">&quot;0x0_1_2_3_4_5_6_7_8_9_A_B_C_D_E_F&quot;</span>, &amp;.{.integer_literal});</span>
<span class="line" id="L1973"></span>
<span class="line" id="L1974">    <span class="tok-kw">try</span> testTokenize(<span class="tok-str">&quot;0X0&quot;</span>, &amp;.{ .invalid, .identifier });</span>
<span class="line" id="L1975">    <span class="tok-kw">try</span> testTokenize(<span class="tok-str">&quot;0x_&quot;</span>, &amp;.{ .invalid, .identifier });</span>
<span class="line" id="L1976">    <span class="tok-kw">try</span> testTokenize(<span class="tok-str">&quot;0x_1&quot;</span>, &amp;.{ .invalid, .identifier });</span>
<span class="line" id="L1977">    <span class="tok-kw">try</span> testTokenize(<span class="tok-str">&quot;0x1_&quot;</span>, &amp;.{.invalid});</span>
<span class="line" id="L1978">    <span class="tok-kw">try</span> testTokenize(<span class="tok-str">&quot;0x0__1&quot;</span>, &amp;.{ .invalid, .identifier });</span>
<span class="line" id="L1979">    <span class="tok-kw">try</span> testTokenize(<span class="tok-str">&quot;0x0_1_&quot;</span>, &amp;.{.invalid});</span>
<span class="line" id="L1980">    <span class="tok-kw">try</span> testTokenize(<span class="tok-str">&quot;0x_,&quot;</span>, &amp;.{ .invalid, .identifier, .comma });</span>
<span class="line" id="L1981"></span>
<span class="line" id="L1982">    <span class="tok-kw">try</span> testTokenize(<span class="tok-str">&quot;0x1.0&quot;</span>, &amp;.{.float_literal});</span>
<span class="line" id="L1983">    <span class="tok-kw">try</span> testTokenize(<span class="tok-str">&quot;0xF.0&quot;</span>, &amp;.{.float_literal});</span>
<span class="line" id="L1984">    <span class="tok-kw">try</span> testTokenize(<span class="tok-str">&quot;0xF.F&quot;</span>, &amp;.{.float_literal});</span>
<span class="line" id="L1985">    <span class="tok-kw">try</span> testTokenize(<span class="tok-str">&quot;0xF.Fp0&quot;</span>, &amp;.{.float_literal});</span>
<span class="line" id="L1986">    <span class="tok-kw">try</span> testTokenize(<span class="tok-str">&quot;0xF.FP0&quot;</span>, &amp;.{.float_literal});</span>
<span class="line" id="L1987">    <span class="tok-kw">try</span> testTokenize(<span class="tok-str">&quot;0x1p0&quot;</span>, &amp;.{.float_literal});</span>
<span class="line" id="L1988">    <span class="tok-kw">try</span> testTokenize(<span class="tok-str">&quot;0xfp0&quot;</span>, &amp;.{.float_literal});</span>
<span class="line" id="L1989">    <span class="tok-kw">try</span> testTokenize(<span class="tok-str">&quot;0x1.0+0xF.0&quot;</span>, &amp;.{ .float_literal, .plus, .float_literal });</span>
<span class="line" id="L1990"></span>
<span class="line" id="L1991">    <span class="tok-kw">try</span> testTokenize(<span class="tok-str">&quot;0x1.&quot;</span>, &amp;.{.invalid});</span>
<span class="line" id="L1992">    <span class="tok-kw">try</span> testTokenize(<span class="tok-str">&quot;0xF.&quot;</span>, &amp;.{.invalid});</span>
<span class="line" id="L1993">    <span class="tok-kw">try</span> testTokenize(<span class="tok-str">&quot;0x1.+0xF.&quot;</span>, &amp;.{ .invalid, .plus, .invalid });</span>
<span class="line" id="L1994">    <span class="tok-kw">try</span> testTokenize(<span class="tok-str">&quot;0xff.p10&quot;</span>, &amp;.{ .invalid, .identifier });</span>
<span class="line" id="L1995"></span>
<span class="line" id="L1996">    <span class="tok-kw">try</span> testTokenize(<span class="tok-str">&quot;0x0123456.789ABCDEF&quot;</span>, &amp;.{.float_literal});</span>
<span class="line" id="L1997">    <span class="tok-kw">try</span> testTokenize(<span class="tok-str">&quot;0x0_123_456.789_ABC_DEF&quot;</span>, &amp;.{.float_literal});</span>
<span class="line" id="L1998">    <span class="tok-kw">try</span> testTokenize(<span class="tok-str">&quot;0x0_1_2_3_4_5_6.7_8_9_A_B_C_D_E_F&quot;</span>, &amp;.{.float_literal});</span>
<span class="line" id="L1999">    <span class="tok-kw">try</span> testTokenize(<span class="tok-str">&quot;0x0p0&quot;</span>, &amp;.{.float_literal});</span>
<span class="line" id="L2000">    <span class="tok-kw">try</span> testTokenize(<span class="tok-str">&quot;0x0.0p0&quot;</span>, &amp;.{.float_literal});</span>
<span class="line" id="L2001">    <span class="tok-kw">try</span> testTokenize(<span class="tok-str">&quot;0xff.ffp10&quot;</span>, &amp;.{.float_literal});</span>
<span class="line" id="L2002">    <span class="tok-kw">try</span> testTokenize(<span class="tok-str">&quot;0xff.ffP10&quot;</span>, &amp;.{.float_literal});</span>
<span class="line" id="L2003">    <span class="tok-kw">try</span> testTokenize(<span class="tok-str">&quot;0xffp10&quot;</span>, &amp;.{.float_literal});</span>
<span class="line" id="L2004">    <span class="tok-kw">try</span> testTokenize(<span class="tok-str">&quot;0xff_ff.ff_ffp1_0_0_0&quot;</span>, &amp;.{.float_literal});</span>
<span class="line" id="L2005">    <span class="tok-kw">try</span> testTokenize(<span class="tok-str">&quot;0xf_f_f_f.f_f_f_fp+1_000&quot;</span>, &amp;.{.float_literal});</span>
<span class="line" id="L2006">    <span class="tok-kw">try</span> testTokenize(<span class="tok-str">&quot;0xf_f_f_f.f_f_f_fp-1_00_0&quot;</span>, &amp;.{.float_literal});</span>
<span class="line" id="L2007"></span>
<span class="line" id="L2008">    <span class="tok-kw">try</span> testTokenize(<span class="tok-str">&quot;0x1e&quot;</span>, &amp;.{.integer_literal});</span>
<span class="line" id="L2009">    <span class="tok-kw">try</span> testTokenize(<span class="tok-str">&quot;0x1e0&quot;</span>, &amp;.{.integer_literal});</span>
<span class="line" id="L2010">    <span class="tok-kw">try</span> testTokenize(<span class="tok-str">&quot;0x1p&quot;</span>, &amp;.{.invalid});</span>
<span class="line" id="L2011">    <span class="tok-kw">try</span> testTokenize(<span class="tok-str">&quot;0xfp0z1&quot;</span>, &amp;.{ .invalid, .identifier });</span>
<span class="line" id="L2012">    <span class="tok-kw">try</span> testTokenize(<span class="tok-str">&quot;0xff.ffpff&quot;</span>, &amp;.{ .invalid, .identifier });</span>
<span class="line" id="L2013">    <span class="tok-kw">try</span> testTokenize(<span class="tok-str">&quot;0x0.p&quot;</span>, &amp;.{ .invalid, .identifier });</span>
<span class="line" id="L2014">    <span class="tok-kw">try</span> testTokenize(<span class="tok-str">&quot;0x0.z&quot;</span>, &amp;.{ .invalid, .identifier });</span>
<span class="line" id="L2015">    <span class="tok-kw">try</span> testTokenize(<span class="tok-str">&quot;0x0._&quot;</span>, &amp;.{ .invalid, .identifier });</span>
<span class="line" id="L2016">    <span class="tok-kw">try</span> testTokenize(<span class="tok-str">&quot;0x0_.0&quot;</span>, &amp;.{ .invalid, .period, .integer_literal });</span>
<span class="line" id="L2017">    <span class="tok-kw">try</span> testTokenize(<span class="tok-str">&quot;0x0_.0.0&quot;</span>, &amp;.{ .invalid, .period, .float_literal });</span>
<span class="line" id="L2018">    <span class="tok-kw">try</span> testTokenize(<span class="tok-str">&quot;0x0._0&quot;</span>, &amp;.{ .invalid, .identifier });</span>
<span class="line" id="L2019">    <span class="tok-kw">try</span> testTokenize(<span class="tok-str">&quot;0x0.0_&quot;</span>, &amp;.{.invalid});</span>
<span class="line" id="L2020">    <span class="tok-kw">try</span> testTokenize(<span class="tok-str">&quot;0x0_p0&quot;</span>, &amp;.{ .invalid, .identifier });</span>
<span class="line" id="L2021">    <span class="tok-kw">try</span> testTokenize(<span class="tok-str">&quot;0x0_.p0&quot;</span>, &amp;.{ .invalid, .period, .identifier });</span>
<span class="line" id="L2022">    <span class="tok-kw">try</span> testTokenize(<span class="tok-str">&quot;0x0._p0&quot;</span>, &amp;.{ .invalid, .identifier });</span>
<span class="line" id="L2023">    <span class="tok-kw">try</span> testTokenize(<span class="tok-str">&quot;0x0.0_p0&quot;</span>, &amp;.{ .invalid, .identifier });</span>
<span class="line" id="L2024">    <span class="tok-kw">try</span> testTokenize(<span class="tok-str">&quot;0x0._0p0&quot;</span>, &amp;.{ .invalid, .identifier });</span>
<span class="line" id="L2025">    <span class="tok-kw">try</span> testTokenize(<span class="tok-str">&quot;0x0.0p_0&quot;</span>, &amp;.{ .invalid, .identifier });</span>
<span class="line" id="L2026">    <span class="tok-kw">try</span> testTokenize(<span class="tok-str">&quot;0x0.0p+_0&quot;</span>, &amp;.{ .invalid, .identifier });</span>
<span class="line" id="L2027">    <span class="tok-kw">try</span> testTokenize(<span class="tok-str">&quot;0x0.0p-_0&quot;</span>, &amp;.{ .invalid, .identifier });</span>
<span class="line" id="L2028">    <span class="tok-kw">try</span> testTokenize(<span class="tok-str">&quot;0x0.0p0_&quot;</span>, &amp;.{ .invalid, .eof });</span>
<span class="line" id="L2029">}</span>
<span class="line" id="L2030"></span>
<span class="line" id="L2031"><span class="tok-kw">test</span> <span class="tok-str">&quot;multi line string literal with only 1 backslash&quot;</span> {</span>
<span class="line" id="L2032">    <span class="tok-kw">try</span> testTokenize(<span class="tok-str">&quot;x \\\n;&quot;</span>, &amp;.{ .identifier, .invalid, .semicolon });</span>
<span class="line" id="L2033">}</span>
<span class="line" id="L2034"></span>
<span class="line" id="L2035"><span class="tok-kw">test</span> <span class="tok-str">&quot;invalid builtin identifiers&quot;</span> {</span>
<span class="line" id="L2036">    <span class="tok-kw">try</span> testTokenize(<span class="tok-str">&quot;@()&quot;</span>, &amp;.{ .invalid, .l_paren, .r_paren });</span>
<span class="line" id="L2037">    <span class="tok-kw">try</span> testTokenize(<span class="tok-str">&quot;@0()&quot;</span>, &amp;.{ .invalid, .integer_literal, .l_paren, .r_paren });</span>
<span class="line" id="L2038">}</span>
<span class="line" id="L2039"></span>
<span class="line" id="L2040"><span class="tok-kw">test</span> <span class="tok-str">&quot;invalid token with unfinished escape right before eof&quot;</span> {</span>
<span class="line" id="L2041">    <span class="tok-kw">try</span> testTokenize(<span class="tok-str">&quot;\&quot;\\&quot;</span>, &amp;.{.invalid});</span>
<span class="line" id="L2042">    <span class="tok-kw">try</span> testTokenize(<span class="tok-str">&quot;'\\&quot;</span>, &amp;.{.invalid});</span>
<span class="line" id="L2043">    <span class="tok-kw">try</span> testTokenize(<span class="tok-str">&quot;'\\u&quot;</span>, &amp;.{.invalid});</span>
<span class="line" id="L2044">}</span>
<span class="line" id="L2045"></span>
<span class="line" id="L2046"><span class="tok-kw">test</span> <span class="tok-str">&quot;saturating operators&quot;</span> {</span>
<span class="line" id="L2047">    <span class="tok-kw">try</span> testTokenize(<span class="tok-str">&quot;&lt;&lt;&quot;</span>, &amp;.{.angle_bracket_angle_bracket_left});</span>
<span class="line" id="L2048">    <span class="tok-kw">try</span> testTokenize(<span class="tok-str">&quot;&lt;&lt;|&quot;</span>, &amp;.{.angle_bracket_angle_bracket_left_pipe});</span>
<span class="line" id="L2049">    <span class="tok-kw">try</span> testTokenize(<span class="tok-str">&quot;&lt;&lt;|=&quot;</span>, &amp;.{.angle_bracket_angle_bracket_left_pipe_equal});</span>
<span class="line" id="L2050"></span>
<span class="line" id="L2051">    <span class="tok-kw">try</span> testTokenize(<span class="tok-str">&quot;*&quot;</span>, &amp;.{.asterisk});</span>
<span class="line" id="L2052">    <span class="tok-kw">try</span> testTokenize(<span class="tok-str">&quot;*|&quot;</span>, &amp;.{.asterisk_pipe});</span>
<span class="line" id="L2053">    <span class="tok-kw">try</span> testTokenize(<span class="tok-str">&quot;*|=&quot;</span>, &amp;.{.asterisk_pipe_equal});</span>
<span class="line" id="L2054"></span>
<span class="line" id="L2055">    <span class="tok-kw">try</span> testTokenize(<span class="tok-str">&quot;+&quot;</span>, &amp;.{.plus});</span>
<span class="line" id="L2056">    <span class="tok-kw">try</span> testTokenize(<span class="tok-str">&quot;+|&quot;</span>, &amp;.{.plus_pipe});</span>
<span class="line" id="L2057">    <span class="tok-kw">try</span> testTokenize(<span class="tok-str">&quot;+|=&quot;</span>, &amp;.{.plus_pipe_equal});</span>
<span class="line" id="L2058"></span>
<span class="line" id="L2059">    <span class="tok-kw">try</span> testTokenize(<span class="tok-str">&quot;-&quot;</span>, &amp;.{.minus});</span>
<span class="line" id="L2060">    <span class="tok-kw">try</span> testTokenize(<span class="tok-str">&quot;-|&quot;</span>, &amp;.{.minus_pipe});</span>
<span class="line" id="L2061">    <span class="tok-kw">try</span> testTokenize(<span class="tok-str">&quot;-|=&quot;</span>, &amp;.{.minus_pipe_equal});</span>
<span class="line" id="L2062">}</span>
<span class="line" id="L2063"></span>
<span class="line" id="L2064"><span class="tok-kw">fn</span> <span class="tok-fn">testTokenize</span>(source: [:<span class="tok-number">0</span>]<span class="tok-kw">const</span> <span class="tok-type">u8</span>, expected_token_tags: []<span class="tok-kw">const</span> Token.Tag) !<span class="tok-type">void</span> {</span>
<span class="line" id="L2065">    <span class="tok-kw">var</span> tokenizer = Tokenizer.init(source);</span>
<span class="line" id="L2066">    <span class="tok-kw">for</span> (expected_token_tags) |expected_token_tag| {</span>
<span class="line" id="L2067">        <span class="tok-kw">const</span> token = tokenizer.next();</span>
<span class="line" id="L2068">        <span class="tok-kw">try</span> std.testing.expectEqual(expected_token_tag, token.tag);</span>
<span class="line" id="L2069">    }</span>
<span class="line" id="L2070">    <span class="tok-kw">const</span> last_token = tokenizer.next();</span>
<span class="line" id="L2071">    <span class="tok-kw">try</span> std.testing.expectEqual(Token.Tag.eof, last_token.tag);</span>
<span class="line" id="L2072">    <span class="tok-kw">try</span> std.testing.expectEqual(source.len, last_token.loc.start);</span>
<span class="line" id="L2073">    <span class="tok-kw">try</span> std.testing.expectEqual(source.len, last_token.loc.end);</span>
<span class="line" id="L2074">}</span>
<span class="line" id="L2075"></span>
</code></pre></body>
</html>