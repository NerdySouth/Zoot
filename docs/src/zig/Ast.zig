<!doctype html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">    <title>zig/Ast.zig - source view</title>
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
<pre><code><span class="line" id="L1"><span class="tok-comment">//! Abstract Syntax Tree for Zig source code.</span></span>
<span class="line" id="L2"></span>
<span class="line" id="L3"><span class="tok-comment">/// Reference to externally-owned data.</span></span>
<span class="line" id="L4">source: [:<span class="tok-number">0</span>]<span class="tok-kw">const</span> <span class="tok-type">u8</span>,</span>
<span class="line" id="L5"></span>
<span class="line" id="L6">tokens: TokenList.Slice,</span>
<span class="line" id="L7"><span class="tok-comment">/// The root AST node is assumed to be index 0. Since there can be no</span></span>
<span class="line" id="L8"><span class="tok-comment">/// references to the root node, this means 0 is available to indicate null.</span></span>
<span class="line" id="L9">nodes: NodeList.Slice,</span>
<span class="line" id="L10">extra_data: []Node.Index,</span>
<span class="line" id="L11"></span>
<span class="line" id="L12">errors: []<span class="tok-kw">const</span> Error,</span>
<span class="line" id="L13"></span>
<span class="line" id="L14"><span class="tok-kw">const</span> std = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;../std.zig&quot;</span>);</span>
<span class="line" id="L15"><span class="tok-kw">const</span> assert = std.debug.assert;</span>
<span class="line" id="L16"><span class="tok-kw">const</span> testing = std.testing;</span>
<span class="line" id="L17"><span class="tok-kw">const</span> mem = std.mem;</span>
<span class="line" id="L18"><span class="tok-kw">const</span> Token = std.zig.Token;</span>
<span class="line" id="L19"><span class="tok-kw">const</span> Ast = <span class="tok-builtin">@This</span>();</span>
<span class="line" id="L20"></span>
<span class="line" id="L21"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> TokenIndex = <span class="tok-type">u32</span>;</span>
<span class="line" id="L22"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> ByteOffset = <span class="tok-type">u32</span>;</span>
<span class="line" id="L23"></span>
<span class="line" id="L24"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> TokenList = std.MultiArrayList(<span class="tok-kw">struct</span> {</span>
<span class="line" id="L25">    tag: Token.Tag,</span>
<span class="line" id="L26">    start: ByteOffset,</span>
<span class="line" id="L27">});</span>
<span class="line" id="L28"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> NodeList = std.MultiArrayList(Node);</span>
<span class="line" id="L29"></span>
<span class="line" id="L30"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> Location = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L31">    line: <span class="tok-type">usize</span>,</span>
<span class="line" id="L32">    column: <span class="tok-type">usize</span>,</span>
<span class="line" id="L33">    line_start: <span class="tok-type">usize</span>,</span>
<span class="line" id="L34">    line_end: <span class="tok-type">usize</span>,</span>
<span class="line" id="L35">};</span>
<span class="line" id="L36"></span>
<span class="line" id="L37"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">deinit</span>(tree: *Ast, gpa: mem.Allocator) <span class="tok-type">void</span> {</span>
<span class="line" id="L38">    tree.tokens.deinit(gpa);</span>
<span class="line" id="L39">    tree.nodes.deinit(gpa);</span>
<span class="line" id="L40">    gpa.free(tree.extra_data);</span>
<span class="line" id="L41">    gpa.free(tree.errors);</span>
<span class="line" id="L42">    tree.* = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L43">}</span>
<span class="line" id="L44"></span>
<span class="line" id="L45"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> RenderError = <span class="tok-kw">error</span>{</span>
<span class="line" id="L46">    <span class="tok-comment">/// Ran out of memory allocating call stack frames to complete rendering, or</span></span>
<span class="line" id="L47">    <span class="tok-comment">/// ran out of memory allocating space in the output buffer.</span></span>
<span class="line" id="L48">    OutOfMemory,</span>
<span class="line" id="L49">};</span>
<span class="line" id="L50"></span>
<span class="line" id="L51"><span class="tok-comment">/// `gpa` is used for allocating the resulting formatted source code, as well as</span></span>
<span class="line" id="L52"><span class="tok-comment">/// for allocating extra stack memory if needed, because this function utilizes recursion.</span></span>
<span class="line" id="L53"><span class="tok-comment">/// Note: that's not actually true yet, see https://github.com/ziglang/zig/issues/1006.</span></span>
<span class="line" id="L54"><span class="tok-comment">/// Caller owns the returned slice of bytes, allocated with `gpa`.</span></span>
<span class="line" id="L55"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">render</span>(tree: Ast, gpa: mem.Allocator) RenderError![]<span class="tok-type">u8</span> {</span>
<span class="line" id="L56">    <span class="tok-kw">var</span> buffer = std.ArrayList(<span class="tok-type">u8</span>).init(gpa);</span>
<span class="line" id="L57">    <span class="tok-kw">defer</span> buffer.deinit();</span>
<span class="line" id="L58"></span>
<span class="line" id="L59">    <span class="tok-kw">try</span> tree.renderToArrayList(&amp;buffer);</span>
<span class="line" id="L60">    <span class="tok-kw">return</span> buffer.toOwnedSlice();</span>
<span class="line" id="L61">}</span>
<span class="line" id="L62"></span>
<span class="line" id="L63"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">renderToArrayList</span>(tree: Ast, buffer: *std.ArrayList(<span class="tok-type">u8</span>)) RenderError!<span class="tok-type">void</span> {</span>
<span class="line" id="L64">    <span class="tok-kw">return</span> <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;./render.zig&quot;</span>).renderTree(buffer, tree);</span>
<span class="line" id="L65">}</span>
<span class="line" id="L66"></span>
<span class="line" id="L67"><span class="tok-comment">/// Returns an extra offset for column and byte offset of errors that</span></span>
<span class="line" id="L68"><span class="tok-comment">/// should point after the token in the error message.</span></span>
<span class="line" id="L69"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">errorOffset</span>(tree: Ast, parse_error: Error) <span class="tok-type">u32</span> {</span>
<span class="line" id="L70">    <span class="tok-kw">return</span> <span class="tok-kw">if</span> (parse_error.token_is_prev)</span>
<span class="line" id="L71">        <span class="tok-builtin">@intCast</span>(<span class="tok-type">u32</span>, tree.tokenSlice(parse_error.token).len)</span>
<span class="line" id="L72">    <span class="tok-kw">else</span></span>
<span class="line" id="L73">        <span class="tok-number">0</span>;</span>
<span class="line" id="L74">}</span>
<span class="line" id="L75"></span>
<span class="line" id="L76"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">tokenLocation</span>(self: Ast, start_offset: ByteOffset, token_index: TokenIndex) Location {</span>
<span class="line" id="L77">    <span class="tok-kw">var</span> loc = Location{</span>
<span class="line" id="L78">        .line = <span class="tok-number">0</span>,</span>
<span class="line" id="L79">        .column = <span class="tok-number">0</span>,</span>
<span class="line" id="L80">        .line_start = start_offset,</span>
<span class="line" id="L81">        .line_end = self.source.len,</span>
<span class="line" id="L82">    };</span>
<span class="line" id="L83">    <span class="tok-kw">const</span> token_start = self.tokens.items(.start)[token_index];</span>
<span class="line" id="L84">    <span class="tok-kw">for</span> (self.source[start_offset..]) |c, i| {</span>
<span class="line" id="L85">        <span class="tok-kw">if</span> (i + start_offset == token_start) {</span>
<span class="line" id="L86">            loc.line_end = i + start_offset;</span>
<span class="line" id="L87">            <span class="tok-kw">while</span> (loc.line_end &lt; self.source.len <span class="tok-kw">and</span> self.source[loc.line_end] != <span class="tok-str">'\n'</span>) {</span>
<span class="line" id="L88">                loc.line_end += <span class="tok-number">1</span>;</span>
<span class="line" id="L89">            }</span>
<span class="line" id="L90">            <span class="tok-kw">return</span> loc;</span>
<span class="line" id="L91">        }</span>
<span class="line" id="L92">        <span class="tok-kw">if</span> (c == <span class="tok-str">'\n'</span>) {</span>
<span class="line" id="L93">            loc.line += <span class="tok-number">1</span>;</span>
<span class="line" id="L94">            loc.column = <span class="tok-number">0</span>;</span>
<span class="line" id="L95">            loc.line_start = i + <span class="tok-number">1</span>;</span>
<span class="line" id="L96">        } <span class="tok-kw">else</span> {</span>
<span class="line" id="L97">            loc.column += <span class="tok-number">1</span>;</span>
<span class="line" id="L98">        }</span>
<span class="line" id="L99">    }</span>
<span class="line" id="L100">    <span class="tok-kw">return</span> loc;</span>
<span class="line" id="L101">}</span>
<span class="line" id="L102"></span>
<span class="line" id="L103"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">tokenSlice</span>(tree: Ast, token_index: TokenIndex) []<span class="tok-kw">const</span> <span class="tok-type">u8</span> {</span>
<span class="line" id="L104">    <span class="tok-kw">const</span> token_starts = tree.tokens.items(.start);</span>
<span class="line" id="L105">    <span class="tok-kw">const</span> token_tags = tree.tokens.items(.tag);</span>
<span class="line" id="L106">    <span class="tok-kw">const</span> token_tag = token_tags[token_index];</span>
<span class="line" id="L107"></span>
<span class="line" id="L108">    <span class="tok-comment">// Many tokens can be determined entirely by their tag.</span>
</span>
<span class="line" id="L109">    <span class="tok-kw">if</span> (token_tag.lexeme()) |lexeme| {</span>
<span class="line" id="L110">        <span class="tok-kw">return</span> lexeme;</span>
<span class="line" id="L111">    }</span>
<span class="line" id="L112"></span>
<span class="line" id="L113">    <span class="tok-comment">// For some tokens, re-tokenization is needed to find the end.</span>
</span>
<span class="line" id="L114">    <span class="tok-kw">var</span> tokenizer: std.zig.Tokenizer = .{</span>
<span class="line" id="L115">        .buffer = tree.source,</span>
<span class="line" id="L116">        .index = token_starts[token_index],</span>
<span class="line" id="L117">        .pending_invalid_token = <span class="tok-null">null</span>,</span>
<span class="line" id="L118">    };</span>
<span class="line" id="L119">    <span class="tok-kw">const</span> token = tokenizer.next();</span>
<span class="line" id="L120">    assert(token.tag == token_tag);</span>
<span class="line" id="L121">    <span class="tok-kw">return</span> tree.source[token.loc.start..token.loc.end];</span>
<span class="line" id="L122">}</span>
<span class="line" id="L123"></span>
<span class="line" id="L124"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">extraData</span>(tree: Ast, index: <span class="tok-type">usize</span>, <span class="tok-kw">comptime</span> T: <span class="tok-type">type</span>) T {</span>
<span class="line" id="L125">    <span class="tok-kw">const</span> fields = std.meta.fields(T);</span>
<span class="line" id="L126">    <span class="tok-kw">var</span> result: T = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L127">    <span class="tok-kw">inline</span> <span class="tok-kw">for</span> (fields) |field, i| {</span>
<span class="line" id="L128">        <span class="tok-kw">comptime</span> assert(field.field_type == Node.Index);</span>
<span class="line" id="L129">        <span class="tok-builtin">@field</span>(result, field.name) = tree.extra_data[index + i];</span>
<span class="line" id="L130">    }</span>
<span class="line" id="L131">    <span class="tok-kw">return</span> result;</span>
<span class="line" id="L132">}</span>
<span class="line" id="L133"></span>
<span class="line" id="L134"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">rootDecls</span>(tree: Ast) []<span class="tok-kw">const</span> Node.Index {</span>
<span class="line" id="L135">    <span class="tok-comment">// Root is always index 0.</span>
</span>
<span class="line" id="L136">    <span class="tok-kw">const</span> nodes_data = tree.nodes.items(.data);</span>
<span class="line" id="L137">    <span class="tok-kw">return</span> tree.extra_data[nodes_data[<span class="tok-number">0</span>].lhs..nodes_data[<span class="tok-number">0</span>].rhs];</span>
<span class="line" id="L138">}</span>
<span class="line" id="L139"></span>
<span class="line" id="L140"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">renderError</span>(tree: Ast, parse_error: Error, stream: <span class="tok-kw">anytype</span>) !<span class="tok-type">void</span> {</span>
<span class="line" id="L141">    <span class="tok-kw">const</span> token_tags = tree.tokens.items(.tag);</span>
<span class="line" id="L142">    <span class="tok-kw">switch</span> (parse_error.tag) {</span>
<span class="line" id="L143">        .asterisk_after_ptr_deref =&gt; {</span>
<span class="line" id="L144">            <span class="tok-comment">// Note that the token will point at the `.*` but ideally the source</span>
</span>
<span class="line" id="L145">            <span class="tok-comment">// location would point to the `*` after the `.*`.</span>
</span>
<span class="line" id="L146">            <span class="tok-kw">return</span> stream.writeAll(<span class="tok-str">&quot;'.*' cannot be followed by '*'. Are you missing a space?&quot;</span>);</span>
<span class="line" id="L147">        },</span>
<span class="line" id="L148">        .chained_comparison_operators =&gt; {</span>
<span class="line" id="L149">            <span class="tok-kw">return</span> stream.writeAll(<span class="tok-str">&quot;comparison operators cannot be chained&quot;</span>);</span>
<span class="line" id="L150">        },</span>
<span class="line" id="L151">        .decl_between_fields =&gt; {</span>
<span class="line" id="L152">            <span class="tok-kw">return</span> stream.writeAll(<span class="tok-str">&quot;declarations are not allowed between container fields&quot;</span>);</span>
<span class="line" id="L153">        },</span>
<span class="line" id="L154">        .expected_block =&gt; {</span>
<span class="line" id="L155">            <span class="tok-kw">return</span> stream.print(<span class="tok-str">&quot;expected block or field, found '{s}'&quot;</span>, .{</span>
<span class="line" id="L156">                token_tags[parse_error.token + <span class="tok-builtin">@boolToInt</span>(parse_error.token_is_prev)].symbol(),</span>
<span class="line" id="L157">            });</span>
<span class="line" id="L158">        },</span>
<span class="line" id="L159">        .expected_block_or_assignment =&gt; {</span>
<span class="line" id="L160">            <span class="tok-kw">return</span> stream.print(<span class="tok-str">&quot;expected block or assignment, found '{s}'&quot;</span>, .{</span>
<span class="line" id="L161">                token_tags[parse_error.token + <span class="tok-builtin">@boolToInt</span>(parse_error.token_is_prev)].symbol(),</span>
<span class="line" id="L162">            });</span>
<span class="line" id="L163">        },</span>
<span class="line" id="L164">        .expected_block_or_expr =&gt; {</span>
<span class="line" id="L165">            <span class="tok-kw">return</span> stream.print(<span class="tok-str">&quot;expected block or expression, found '{s}'&quot;</span>, .{</span>
<span class="line" id="L166">                token_tags[parse_error.token + <span class="tok-builtin">@boolToInt</span>(parse_error.token_is_prev)].symbol(),</span>
<span class="line" id="L167">            });</span>
<span class="line" id="L168">        },</span>
<span class="line" id="L169">        .expected_block_or_field =&gt; {</span>
<span class="line" id="L170">            <span class="tok-kw">return</span> stream.print(<span class="tok-str">&quot;expected block or field, found '{s}'&quot;</span>, .{</span>
<span class="line" id="L171">                token_tags[parse_error.token + <span class="tok-builtin">@boolToInt</span>(parse_error.token_is_prev)].symbol(),</span>
<span class="line" id="L172">            });</span>
<span class="line" id="L173">        },</span>
<span class="line" id="L174">        .expected_container_members =&gt; {</span>
<span class="line" id="L175">            <span class="tok-kw">return</span> stream.print(<span class="tok-str">&quot;expected test, comptime, var decl, or container field, found '{s}'&quot;</span>, .{</span>
<span class="line" id="L176">                token_tags[parse_error.token].symbol(),</span>
<span class="line" id="L177">            });</span>
<span class="line" id="L178">        },</span>
<span class="line" id="L179">        .expected_expr =&gt; {</span>
<span class="line" id="L180">            <span class="tok-kw">return</span> stream.print(<span class="tok-str">&quot;expected expression, found '{s}'&quot;</span>, .{</span>
<span class="line" id="L181">                token_tags[parse_error.token + <span class="tok-builtin">@boolToInt</span>(parse_error.token_is_prev)].symbol(),</span>
<span class="line" id="L182">            });</span>
<span class="line" id="L183">        },</span>
<span class="line" id="L184">        .expected_expr_or_assignment =&gt; {</span>
<span class="line" id="L185">            <span class="tok-kw">return</span> stream.print(<span class="tok-str">&quot;expected expression or assignment, found '{s}'&quot;</span>, .{</span>
<span class="line" id="L186">                token_tags[parse_error.token + <span class="tok-builtin">@boolToInt</span>(parse_error.token_is_prev)].symbol(),</span>
<span class="line" id="L187">            });</span>
<span class="line" id="L188">        },</span>
<span class="line" id="L189">        .expected_fn =&gt; {</span>
<span class="line" id="L190">            <span class="tok-kw">return</span> stream.print(<span class="tok-str">&quot;expected function, found '{s}'&quot;</span>, .{</span>
<span class="line" id="L191">                token_tags[parse_error.token + <span class="tok-builtin">@boolToInt</span>(parse_error.token_is_prev)].symbol(),</span>
<span class="line" id="L192">            });</span>
<span class="line" id="L193">        },</span>
<span class="line" id="L194">        .expected_inlinable =&gt; {</span>
<span class="line" id="L195">            <span class="tok-kw">return</span> stream.print(<span class="tok-str">&quot;expected 'while' or 'for', found '{s}'&quot;</span>, .{</span>
<span class="line" id="L196">                token_tags[parse_error.token + <span class="tok-builtin">@boolToInt</span>(parse_error.token_is_prev)].symbol(),</span>
<span class="line" id="L197">            });</span>
<span class="line" id="L198">        },</span>
<span class="line" id="L199">        .expected_labelable =&gt; {</span>
<span class="line" id="L200">            <span class="tok-kw">return</span> stream.print(<span class="tok-str">&quot;expected 'while', 'for', 'inline', 'suspend', or '{{', found '{s}'&quot;</span>, .{</span>
<span class="line" id="L201">                token_tags[parse_error.token + <span class="tok-builtin">@boolToInt</span>(parse_error.token_is_prev)].symbol(),</span>
<span class="line" id="L202">            });</span>
<span class="line" id="L203">        },</span>
<span class="line" id="L204">        .expected_param_list =&gt; {</span>
<span class="line" id="L205">            <span class="tok-kw">return</span> stream.print(<span class="tok-str">&quot;expected parameter list, found '{s}'&quot;</span>, .{</span>
<span class="line" id="L206">                token_tags[parse_error.token + <span class="tok-builtin">@boolToInt</span>(parse_error.token_is_prev)].symbol(),</span>
<span class="line" id="L207">            });</span>
<span class="line" id="L208">        },</span>
<span class="line" id="L209">        .expected_prefix_expr =&gt; {</span>
<span class="line" id="L210">            <span class="tok-kw">return</span> stream.print(<span class="tok-str">&quot;expected prefix expression, found '{s}'&quot;</span>, .{</span>
<span class="line" id="L211">                token_tags[parse_error.token + <span class="tok-builtin">@boolToInt</span>(parse_error.token_is_prev)].symbol(),</span>
<span class="line" id="L212">            });</span>
<span class="line" id="L213">        },</span>
<span class="line" id="L214">        .expected_primary_type_expr =&gt; {</span>
<span class="line" id="L215">            <span class="tok-kw">return</span> stream.print(<span class="tok-str">&quot;expected primary type expression, found '{s}'&quot;</span>, .{</span>
<span class="line" id="L216">                token_tags[parse_error.token + <span class="tok-builtin">@boolToInt</span>(parse_error.token_is_prev)].symbol(),</span>
<span class="line" id="L217">            });</span>
<span class="line" id="L218">        },</span>
<span class="line" id="L219">        .expected_pub_item =&gt; {</span>
<span class="line" id="L220">            <span class="tok-kw">return</span> stream.writeAll(<span class="tok-str">&quot;expected function or variable declaration after pub&quot;</span>);</span>
<span class="line" id="L221">        },</span>
<span class="line" id="L222">        .expected_return_type =&gt; {</span>
<span class="line" id="L223">            <span class="tok-kw">return</span> stream.print(<span class="tok-str">&quot;expected return type expression, found '{s}'&quot;</span>, .{</span>
<span class="line" id="L224">                token_tags[parse_error.token + <span class="tok-builtin">@boolToInt</span>(parse_error.token_is_prev)].symbol(),</span>
<span class="line" id="L225">            });</span>
<span class="line" id="L226">        },</span>
<span class="line" id="L227">        .expected_semi_or_else =&gt; {</span>
<span class="line" id="L228">            <span class="tok-kw">return</span> stream.writeAll(<span class="tok-str">&quot;expected ';' or 'else' after statement&quot;</span>);</span>
<span class="line" id="L229">        },</span>
<span class="line" id="L230">        .expected_semi_or_lbrace =&gt; {</span>
<span class="line" id="L231">            <span class="tok-kw">return</span> stream.writeAll(<span class="tok-str">&quot;expected ';' or block after function prototype&quot;</span>);</span>
<span class="line" id="L232">        },</span>
<span class="line" id="L233">        .expected_statement =&gt; {</span>
<span class="line" id="L234">            <span class="tok-kw">return</span> stream.print(<span class="tok-str">&quot;expected statement, found '{s}'&quot;</span>, .{</span>
<span class="line" id="L235">                token_tags[parse_error.token].symbol(),</span>
<span class="line" id="L236">            });</span>
<span class="line" id="L237">        },</span>
<span class="line" id="L238">        .expected_suffix_op =&gt; {</span>
<span class="line" id="L239">            <span class="tok-kw">return</span> stream.print(<span class="tok-str">&quot;expected pointer dereference, optional unwrap, or field access, found '{s}'&quot;</span>, .{</span>
<span class="line" id="L240">                token_tags[parse_error.token + <span class="tok-builtin">@boolToInt</span>(parse_error.token_is_prev)].symbol(),</span>
<span class="line" id="L241">            });</span>
<span class="line" id="L242">        },</span>
<span class="line" id="L243">        .expected_type_expr =&gt; {</span>
<span class="line" id="L244">            <span class="tok-kw">return</span> stream.print(<span class="tok-str">&quot;expected type expression, found '{s}'&quot;</span>, .{</span>
<span class="line" id="L245">                token_tags[parse_error.token + <span class="tok-builtin">@boolToInt</span>(parse_error.token_is_prev)].symbol(),</span>
<span class="line" id="L246">            });</span>
<span class="line" id="L247">        },</span>
<span class="line" id="L248">        .expected_var_decl =&gt; {</span>
<span class="line" id="L249">            <span class="tok-kw">return</span> stream.print(<span class="tok-str">&quot;expected variable declaration, found '{s}'&quot;</span>, .{</span>
<span class="line" id="L250">                token_tags[parse_error.token + <span class="tok-builtin">@boolToInt</span>(parse_error.token_is_prev)].symbol(),</span>
<span class="line" id="L251">            });</span>
<span class="line" id="L252">        },</span>
<span class="line" id="L253">        .expected_var_decl_or_fn =&gt; {</span>
<span class="line" id="L254">            <span class="tok-kw">return</span> stream.print(<span class="tok-str">&quot;expected variable declaration or function, found '{s}'&quot;</span>, .{</span>
<span class="line" id="L255">                token_tags[parse_error.token + <span class="tok-builtin">@boolToInt</span>(parse_error.token_is_prev)].symbol(),</span>
<span class="line" id="L256">            });</span>
<span class="line" id="L257">        },</span>
<span class="line" id="L258">        .expected_loop_payload =&gt; {</span>
<span class="line" id="L259">            <span class="tok-kw">return</span> stream.print(<span class="tok-str">&quot;expected loop payload, found '{s}'&quot;</span>, .{</span>
<span class="line" id="L260">                token_tags[parse_error.token + <span class="tok-builtin">@boolToInt</span>(parse_error.token_is_prev)].symbol(),</span>
<span class="line" id="L261">            });</span>
<span class="line" id="L262">        },</span>
<span class="line" id="L263">        .expected_container =&gt; {</span>
<span class="line" id="L264">            <span class="tok-kw">return</span> stream.print(<span class="tok-str">&quot;expected a struct, enum or union, found '{s}'&quot;</span>, .{</span>
<span class="line" id="L265">                token_tags[parse_error.token + <span class="tok-builtin">@boolToInt</span>(parse_error.token_is_prev)].symbol(),</span>
<span class="line" id="L266">            });</span>
<span class="line" id="L267">        },</span>
<span class="line" id="L268">        .extern_fn_body =&gt; {</span>
<span class="line" id="L269">            <span class="tok-kw">return</span> stream.writeAll(<span class="tok-str">&quot;extern functions have no body&quot;</span>);</span>
<span class="line" id="L270">        },</span>
<span class="line" id="L271">        .extra_addrspace_qualifier =&gt; {</span>
<span class="line" id="L272">            <span class="tok-kw">return</span> stream.writeAll(<span class="tok-str">&quot;extra addrspace qualifier&quot;</span>);</span>
<span class="line" id="L273">        },</span>
<span class="line" id="L274">        .extra_align_qualifier =&gt; {</span>
<span class="line" id="L275">            <span class="tok-kw">return</span> stream.writeAll(<span class="tok-str">&quot;extra align qualifier&quot;</span>);</span>
<span class="line" id="L276">        },</span>
<span class="line" id="L277">        .extra_allowzero_qualifier =&gt; {</span>
<span class="line" id="L278">            <span class="tok-kw">return</span> stream.writeAll(<span class="tok-str">&quot;extra allowzero qualifier&quot;</span>);</span>
<span class="line" id="L279">        },</span>
<span class="line" id="L280">        .extra_const_qualifier =&gt; {</span>
<span class="line" id="L281">            <span class="tok-kw">return</span> stream.writeAll(<span class="tok-str">&quot;extra const qualifier&quot;</span>);</span>
<span class="line" id="L282">        },</span>
<span class="line" id="L283">        .extra_volatile_qualifier =&gt; {</span>
<span class="line" id="L284">            <span class="tok-kw">return</span> stream.writeAll(<span class="tok-str">&quot;extra volatile qualifier&quot;</span>);</span>
<span class="line" id="L285">        },</span>
<span class="line" id="L286">        .ptr_mod_on_array_child_type =&gt; {</span>
<span class="line" id="L287">            <span class="tok-kw">return</span> stream.print(<span class="tok-str">&quot;pointer modifier '{s}' not allowed on array child type&quot;</span>, .{</span>
<span class="line" id="L288">                token_tags[parse_error.token].symbol(),</span>
<span class="line" id="L289">            });</span>
<span class="line" id="L290">        },</span>
<span class="line" id="L291">        .invalid_bit_range =&gt; {</span>
<span class="line" id="L292">            <span class="tok-kw">return</span> stream.writeAll(<span class="tok-str">&quot;bit range not allowed on slices and arrays&quot;</span>);</span>
<span class="line" id="L293">        },</span>
<span class="line" id="L294">        .same_line_doc_comment =&gt; {</span>
<span class="line" id="L295">            <span class="tok-kw">return</span> stream.writeAll(<span class="tok-str">&quot;same line documentation comment&quot;</span>);</span>
<span class="line" id="L296">        },</span>
<span class="line" id="L297">        .unattached_doc_comment =&gt; {</span>
<span class="line" id="L298">            <span class="tok-kw">return</span> stream.writeAll(<span class="tok-str">&quot;unattached documentation comment&quot;</span>);</span>
<span class="line" id="L299">        },</span>
<span class="line" id="L300">        .test_doc_comment =&gt; {</span>
<span class="line" id="L301">            <span class="tok-kw">return</span> stream.writeAll(<span class="tok-str">&quot;documentation comments cannot be attached to tests&quot;</span>);</span>
<span class="line" id="L302">        },</span>
<span class="line" id="L303">        .comptime_doc_comment =&gt; {</span>
<span class="line" id="L304">            <span class="tok-kw">return</span> stream.writeAll(<span class="tok-str">&quot;documentation comments cannot be attached to comptime blocks&quot;</span>);</span>
<span class="line" id="L305">        },</span>
<span class="line" id="L306">        .varargs_nonfinal =&gt; {</span>
<span class="line" id="L307">            <span class="tok-kw">return</span> stream.writeAll(<span class="tok-str">&quot;function prototype has parameter after varargs&quot;</span>);</span>
<span class="line" id="L308">        },</span>
<span class="line" id="L309">        .expected_continue_expr =&gt; {</span>
<span class="line" id="L310">            <span class="tok-kw">return</span> stream.writeAll(<span class="tok-str">&quot;expected ':' before while continue expression&quot;</span>);</span>
<span class="line" id="L311">        },</span>
<span class="line" id="L312"></span>
<span class="line" id="L313">        .expected_semi_after_decl =&gt; {</span>
<span class="line" id="L314">            <span class="tok-kw">return</span> stream.writeAll(<span class="tok-str">&quot;expected ';' after declaration&quot;</span>);</span>
<span class="line" id="L315">        },</span>
<span class="line" id="L316">        .expected_semi_after_stmt =&gt; {</span>
<span class="line" id="L317">            <span class="tok-kw">return</span> stream.writeAll(<span class="tok-str">&quot;expected ';' after statement&quot;</span>);</span>
<span class="line" id="L318">        },</span>
<span class="line" id="L319">        .expected_comma_after_field =&gt; {</span>
<span class="line" id="L320">            <span class="tok-kw">return</span> stream.writeAll(<span class="tok-str">&quot;expected ',' after field&quot;</span>);</span>
<span class="line" id="L321">        },</span>
<span class="line" id="L322">        .expected_comma_after_arg =&gt; {</span>
<span class="line" id="L323">            <span class="tok-kw">return</span> stream.writeAll(<span class="tok-str">&quot;expected ',' after argument&quot;</span>);</span>
<span class="line" id="L324">        },</span>
<span class="line" id="L325">        .expected_comma_after_param =&gt; {</span>
<span class="line" id="L326">            <span class="tok-kw">return</span> stream.writeAll(<span class="tok-str">&quot;expected ',' after parameter&quot;</span>);</span>
<span class="line" id="L327">        },</span>
<span class="line" id="L328">        .expected_comma_after_initializer =&gt; {</span>
<span class="line" id="L329">            <span class="tok-kw">return</span> stream.writeAll(<span class="tok-str">&quot;expected ',' after initializer&quot;</span>);</span>
<span class="line" id="L330">        },</span>
<span class="line" id="L331">        .expected_comma_after_switch_prong =&gt; {</span>
<span class="line" id="L332">            <span class="tok-kw">return</span> stream.writeAll(<span class="tok-str">&quot;expected ',' after switch prong&quot;</span>);</span>
<span class="line" id="L333">        },</span>
<span class="line" id="L334">        .expected_initializer =&gt; {</span>
<span class="line" id="L335">            <span class="tok-kw">return</span> stream.writeAll(<span class="tok-str">&quot;expected field initializer&quot;</span>);</span>
<span class="line" id="L336">        },</span>
<span class="line" id="L337">        .mismatched_binary_op_whitespace =&gt; {</span>
<span class="line" id="L338">            <span class="tok-kw">return</span> stream.print(<span class="tok-str">&quot;binary operator `{s}` has whitespace on one side, but not the other.&quot;</span>, .{token_tags[parse_error.token].lexeme().?});</span>
<span class="line" id="L339">        },</span>
<span class="line" id="L340">        .invalid_ampersand_ampersand =&gt; {</span>
<span class="line" id="L341">            <span class="tok-kw">return</span> stream.writeAll(<span class="tok-str">&quot;ambiguous use of '&amp;&amp;'; use 'and' for logical AND, or change whitespace to ' &amp; &amp;' for bitwise AND&quot;</span>);</span>
<span class="line" id="L342">        },</span>
<span class="line" id="L343">        .c_style_container =&gt; {</span>
<span class="line" id="L344">            <span class="tok-kw">return</span> stream.print(<span class="tok-str">&quot;'{s} {s}' is invalid&quot;</span>, .{</span>
<span class="line" id="L345">                parse_error.extra.expected_tag.symbol(), tree.tokenSlice(parse_error.token),</span>
<span class="line" id="L346">            });</span>
<span class="line" id="L347">        },</span>
<span class="line" id="L348">        .zig_style_container =&gt; {</span>
<span class="line" id="L349">            <span class="tok-kw">return</span> stream.print(<span class="tok-str">&quot;to declare a container do 'const {s} = {s}'&quot;</span>, .{</span>
<span class="line" id="L350">                tree.tokenSlice(parse_error.token), parse_error.extra.expected_tag.symbol(),</span>
<span class="line" id="L351">            });</span>
<span class="line" id="L352">        },</span>
<span class="line" id="L353">        .previous_field =&gt; {</span>
<span class="line" id="L354">            <span class="tok-kw">return</span> stream.writeAll(<span class="tok-str">&quot;field before declarations here&quot;</span>);</span>
<span class="line" id="L355">        },</span>
<span class="line" id="L356">        .next_field =&gt; {</span>
<span class="line" id="L357">            <span class="tok-kw">return</span> stream.writeAll(<span class="tok-str">&quot;field after declarations here&quot;</span>);</span>
<span class="line" id="L358">        },</span>
<span class="line" id="L359"></span>
<span class="line" id="L360">        .expected_token =&gt; {</span>
<span class="line" id="L361">            <span class="tok-kw">const</span> found_tag = token_tags[parse_error.token + <span class="tok-builtin">@boolToInt</span>(parse_error.token_is_prev)];</span>
<span class="line" id="L362">            <span class="tok-kw">const</span> expected_symbol = parse_error.extra.expected_tag.symbol();</span>
<span class="line" id="L363">            <span class="tok-kw">switch</span> (found_tag) {</span>
<span class="line" id="L364">                .invalid =&gt; <span class="tok-kw">return</span> stream.print(<span class="tok-str">&quot;expected '{s}', found invalid bytes&quot;</span>, .{</span>
<span class="line" id="L365">                    expected_symbol,</span>
<span class="line" id="L366">                }),</span>
<span class="line" id="L367">                <span class="tok-kw">else</span> =&gt; <span class="tok-kw">return</span> stream.print(<span class="tok-str">&quot;expected '{s}', found '{s}'&quot;</span>, .{</span>
<span class="line" id="L368">                    expected_symbol, found_tag.symbol(),</span>
<span class="line" id="L369">                }),</span>
<span class="line" id="L370">            }</span>
<span class="line" id="L371">        },</span>
<span class="line" id="L372">    }</span>
<span class="line" id="L373">}</span>
<span class="line" id="L374"></span>
<span class="line" id="L375"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">firstToken</span>(tree: Ast, node: Node.Index) TokenIndex {</span>
<span class="line" id="L376">    <span class="tok-kw">const</span> tags = tree.nodes.items(.tag);</span>
<span class="line" id="L377">    <span class="tok-kw">const</span> datas = tree.nodes.items(.data);</span>
<span class="line" id="L378">    <span class="tok-kw">const</span> main_tokens = tree.nodes.items(.main_token);</span>
<span class="line" id="L379">    <span class="tok-kw">const</span> token_tags = tree.tokens.items(.tag);</span>
<span class="line" id="L380">    <span class="tok-kw">var</span> end_offset: TokenIndex = <span class="tok-number">0</span>;</span>
<span class="line" id="L381">    <span class="tok-kw">var</span> n = node;</span>
<span class="line" id="L382">    <span class="tok-kw">while</span> (<span class="tok-null">true</span>) <span class="tok-kw">switch</span> (tags[n]) {</span>
<span class="line" id="L383">        .root =&gt; <span class="tok-kw">return</span> <span class="tok-number">0</span>,</span>
<span class="line" id="L384"></span>
<span class="line" id="L385">        .test_decl,</span>
<span class="line" id="L386">        .@&quot;errdefer&quot;,</span>
<span class="line" id="L387">        .@&quot;defer&quot;,</span>
<span class="line" id="L388">        .bool_not,</span>
<span class="line" id="L389">        .negation,</span>
<span class="line" id="L390">        .bit_not,</span>
<span class="line" id="L391">        .negation_wrap,</span>
<span class="line" id="L392">        .address_of,</span>
<span class="line" id="L393">        .@&quot;try&quot;,</span>
<span class="line" id="L394">        .@&quot;await&quot;,</span>
<span class="line" id="L395">        .optional_type,</span>
<span class="line" id="L396">        .@&quot;switch&quot;,</span>
<span class="line" id="L397">        .switch_comma,</span>
<span class="line" id="L398">        .if_simple,</span>
<span class="line" id="L399">        .@&quot;if&quot;,</span>
<span class="line" id="L400">        .@&quot;suspend&quot;,</span>
<span class="line" id="L401">        .@&quot;resume&quot;,</span>
<span class="line" id="L402">        .@&quot;continue&quot;,</span>
<span class="line" id="L403">        .@&quot;break&quot;,</span>
<span class="line" id="L404">        .@&quot;return&quot;,</span>
<span class="line" id="L405">        .anyframe_type,</span>
<span class="line" id="L406">        .identifier,</span>
<span class="line" id="L407">        .anyframe_literal,</span>
<span class="line" id="L408">        .char_literal,</span>
<span class="line" id="L409">        .integer_literal,</span>
<span class="line" id="L410">        .float_literal,</span>
<span class="line" id="L411">        .unreachable_literal,</span>
<span class="line" id="L412">        .string_literal,</span>
<span class="line" id="L413">        .multiline_string_literal,</span>
<span class="line" id="L414">        .grouped_expression,</span>
<span class="line" id="L415">        .builtin_call_two,</span>
<span class="line" id="L416">        .builtin_call_two_comma,</span>
<span class="line" id="L417">        .builtin_call,</span>
<span class="line" id="L418">        .builtin_call_comma,</span>
<span class="line" id="L419">        .error_set_decl,</span>
<span class="line" id="L420">        .@&quot;comptime&quot;,</span>
<span class="line" id="L421">        .@&quot;nosuspend&quot;,</span>
<span class="line" id="L422">        .asm_simple,</span>
<span class="line" id="L423">        .@&quot;asm&quot;,</span>
<span class="line" id="L424">        .array_type,</span>
<span class="line" id="L425">        .array_type_sentinel,</span>
<span class="line" id="L426">        .error_value,</span>
<span class="line" id="L427">        =&gt; <span class="tok-kw">return</span> main_tokens[n] - end_offset,</span>
<span class="line" id="L428"></span>
<span class="line" id="L429">        .array_init_dot,</span>
<span class="line" id="L430">        .array_init_dot_comma,</span>
<span class="line" id="L431">        .array_init_dot_two,</span>
<span class="line" id="L432">        .array_init_dot_two_comma,</span>
<span class="line" id="L433">        .struct_init_dot,</span>
<span class="line" id="L434">        .struct_init_dot_comma,</span>
<span class="line" id="L435">        .struct_init_dot_two,</span>
<span class="line" id="L436">        .struct_init_dot_two_comma,</span>
<span class="line" id="L437">        .enum_literal,</span>
<span class="line" id="L438">        =&gt; <span class="tok-kw">return</span> main_tokens[n] - <span class="tok-number">1</span> - end_offset,</span>
<span class="line" id="L439"></span>
<span class="line" id="L440">        .@&quot;catch&quot;,</span>
<span class="line" id="L441">        .field_access,</span>
<span class="line" id="L442">        .unwrap_optional,</span>
<span class="line" id="L443">        .equal_equal,</span>
<span class="line" id="L444">        .bang_equal,</span>
<span class="line" id="L445">        .less_than,</span>
<span class="line" id="L446">        .greater_than,</span>
<span class="line" id="L447">        .less_or_equal,</span>
<span class="line" id="L448">        .greater_or_equal,</span>
<span class="line" id="L449">        .assign_mul,</span>
<span class="line" id="L450">        .assign_div,</span>
<span class="line" id="L451">        .assign_mod,</span>
<span class="line" id="L452">        .assign_add,</span>
<span class="line" id="L453">        .assign_sub,</span>
<span class="line" id="L454">        .assign_shl,</span>
<span class="line" id="L455">        .assign_shl_sat,</span>
<span class="line" id="L456">        .assign_shr,</span>
<span class="line" id="L457">        .assign_bit_and,</span>
<span class="line" id="L458">        .assign_bit_xor,</span>
<span class="line" id="L459">        .assign_bit_or,</span>
<span class="line" id="L460">        .assign_mul_wrap,</span>
<span class="line" id="L461">        .assign_add_wrap,</span>
<span class="line" id="L462">        .assign_sub_wrap,</span>
<span class="line" id="L463">        .assign_mul_sat,</span>
<span class="line" id="L464">        .assign_add_sat,</span>
<span class="line" id="L465">        .assign_sub_sat,</span>
<span class="line" id="L466">        .assign,</span>
<span class="line" id="L467">        .merge_error_sets,</span>
<span class="line" id="L468">        .mul,</span>
<span class="line" id="L469">        .div,</span>
<span class="line" id="L470">        .mod,</span>
<span class="line" id="L471">        .array_mult,</span>
<span class="line" id="L472">        .mul_wrap,</span>
<span class="line" id="L473">        .mul_sat,</span>
<span class="line" id="L474">        .add,</span>
<span class="line" id="L475">        .sub,</span>
<span class="line" id="L476">        .array_cat,</span>
<span class="line" id="L477">        .add_wrap,</span>
<span class="line" id="L478">        .sub_wrap,</span>
<span class="line" id="L479">        .add_sat,</span>
<span class="line" id="L480">        .sub_sat,</span>
<span class="line" id="L481">        .shl,</span>
<span class="line" id="L482">        .shl_sat,</span>
<span class="line" id="L483">        .shr,</span>
<span class="line" id="L484">        .bit_and,</span>
<span class="line" id="L485">        .bit_xor,</span>
<span class="line" id="L486">        .bit_or,</span>
<span class="line" id="L487">        .@&quot;orelse&quot;,</span>
<span class="line" id="L488">        .bool_and,</span>
<span class="line" id="L489">        .bool_or,</span>
<span class="line" id="L490">        .slice_open,</span>
<span class="line" id="L491">        .slice,</span>
<span class="line" id="L492">        .slice_sentinel,</span>
<span class="line" id="L493">        .deref,</span>
<span class="line" id="L494">        .array_access,</span>
<span class="line" id="L495">        .array_init_one,</span>
<span class="line" id="L496">        .array_init_one_comma,</span>
<span class="line" id="L497">        .array_init,</span>
<span class="line" id="L498">        .array_init_comma,</span>
<span class="line" id="L499">        .struct_init_one,</span>
<span class="line" id="L500">        .struct_init_one_comma,</span>
<span class="line" id="L501">        .struct_init,</span>
<span class="line" id="L502">        .struct_init_comma,</span>
<span class="line" id="L503">        .call_one,</span>
<span class="line" id="L504">        .call_one_comma,</span>
<span class="line" id="L505">        .call,</span>
<span class="line" id="L506">        .call_comma,</span>
<span class="line" id="L507">        .switch_range,</span>
<span class="line" id="L508">        .error_union,</span>
<span class="line" id="L509">        =&gt; n = datas[n].lhs,</span>
<span class="line" id="L510"></span>
<span class="line" id="L511">        .fn_decl,</span>
<span class="line" id="L512">        .fn_proto_simple,</span>
<span class="line" id="L513">        .fn_proto_multi,</span>
<span class="line" id="L514">        .fn_proto_one,</span>
<span class="line" id="L515">        .fn_proto,</span>
<span class="line" id="L516">        =&gt; {</span>
<span class="line" id="L517">            <span class="tok-kw">var</span> i = main_tokens[n]; <span class="tok-comment">// fn token</span>
</span>
<span class="line" id="L518">            <span class="tok-kw">while</span> (i &gt; <span class="tok-number">0</span>) {</span>
<span class="line" id="L519">                i -= <span class="tok-number">1</span>;</span>
<span class="line" id="L520">                <span class="tok-kw">switch</span> (token_tags[i]) {</span>
<span class="line" id="L521">                    .keyword_extern,</span>
<span class="line" id="L522">                    .keyword_export,</span>
<span class="line" id="L523">                    .keyword_pub,</span>
<span class="line" id="L524">                    .keyword_inline,</span>
<span class="line" id="L525">                    .keyword_noinline,</span>
<span class="line" id="L526">                    .string_literal,</span>
<span class="line" id="L527">                    =&gt; <span class="tok-kw">continue</span>,</span>
<span class="line" id="L528"></span>
<span class="line" id="L529">                    <span class="tok-kw">else</span> =&gt; <span class="tok-kw">return</span> i + <span class="tok-number">1</span> - end_offset,</span>
<span class="line" id="L530">                }</span>
<span class="line" id="L531">            }</span>
<span class="line" id="L532">            <span class="tok-kw">return</span> i - end_offset;</span>
<span class="line" id="L533">        },</span>
<span class="line" id="L534"></span>
<span class="line" id="L535">        .@&quot;usingnamespace&quot; =&gt; {</span>
<span class="line" id="L536">            <span class="tok-kw">const</span> main_token = main_tokens[n];</span>
<span class="line" id="L537">            <span class="tok-kw">if</span> (main_token &gt; <span class="tok-number">0</span> <span class="tok-kw">and</span> token_tags[main_token - <span class="tok-number">1</span>] == .keyword_pub) {</span>
<span class="line" id="L538">                end_offset += <span class="tok-number">1</span>;</span>
<span class="line" id="L539">            }</span>
<span class="line" id="L540">            <span class="tok-kw">return</span> main_token - end_offset;</span>
<span class="line" id="L541">        },</span>
<span class="line" id="L542"></span>
<span class="line" id="L543">        .async_call_one,</span>
<span class="line" id="L544">        .async_call_one_comma,</span>
<span class="line" id="L545">        .async_call,</span>
<span class="line" id="L546">        .async_call_comma,</span>
<span class="line" id="L547">        =&gt; {</span>
<span class="line" id="L548">            end_offset += <span class="tok-number">1</span>; <span class="tok-comment">// async token</span>
</span>
<span class="line" id="L549">            n = datas[n].lhs;</span>
<span class="line" id="L550">        },</span>
<span class="line" id="L551"></span>
<span class="line" id="L552">        .container_field_init,</span>
<span class="line" id="L553">        .container_field_align,</span>
<span class="line" id="L554">        .container_field,</span>
<span class="line" id="L555">        =&gt; {</span>
<span class="line" id="L556">            <span class="tok-kw">const</span> name_token = main_tokens[n];</span>
<span class="line" id="L557">            <span class="tok-kw">if</span> (name_token &gt; <span class="tok-number">0</span> <span class="tok-kw">and</span> token_tags[name_token - <span class="tok-number">1</span>] == .keyword_comptime) {</span>
<span class="line" id="L558">                end_offset += <span class="tok-number">1</span>;</span>
<span class="line" id="L559">            }</span>
<span class="line" id="L560">            <span class="tok-kw">return</span> name_token - end_offset;</span>
<span class="line" id="L561">        },</span>
<span class="line" id="L562"></span>
<span class="line" id="L563">        .global_var_decl,</span>
<span class="line" id="L564">        .local_var_decl,</span>
<span class="line" id="L565">        .simple_var_decl,</span>
<span class="line" id="L566">        .aligned_var_decl,</span>
<span class="line" id="L567">        =&gt; {</span>
<span class="line" id="L568">            <span class="tok-kw">var</span> i = main_tokens[n]; <span class="tok-comment">// mut token</span>
</span>
<span class="line" id="L569">            <span class="tok-kw">while</span> (i &gt; <span class="tok-number">0</span>) {</span>
<span class="line" id="L570">                i -= <span class="tok-number">1</span>;</span>
<span class="line" id="L571">                <span class="tok-kw">switch</span> (token_tags[i]) {</span>
<span class="line" id="L572">                    .keyword_extern,</span>
<span class="line" id="L573">                    .keyword_export,</span>
<span class="line" id="L574">                    .keyword_comptime,</span>
<span class="line" id="L575">                    .keyword_pub,</span>
<span class="line" id="L576">                    .keyword_threadlocal,</span>
<span class="line" id="L577">                    .string_literal,</span>
<span class="line" id="L578">                    =&gt; <span class="tok-kw">continue</span>,</span>
<span class="line" id="L579"></span>
<span class="line" id="L580">                    <span class="tok-kw">else</span> =&gt; <span class="tok-kw">return</span> i + <span class="tok-number">1</span> - end_offset,</span>
<span class="line" id="L581">                }</span>
<span class="line" id="L582">            }</span>
<span class="line" id="L583">            <span class="tok-kw">return</span> i - end_offset;</span>
<span class="line" id="L584">        },</span>
<span class="line" id="L585"></span>
<span class="line" id="L586">        .block,</span>
<span class="line" id="L587">        .block_semicolon,</span>
<span class="line" id="L588">        .block_two,</span>
<span class="line" id="L589">        .block_two_semicolon,</span>
<span class="line" id="L590">        =&gt; {</span>
<span class="line" id="L591">            <span class="tok-comment">// Look for a label.</span>
</span>
<span class="line" id="L592">            <span class="tok-kw">const</span> lbrace = main_tokens[n];</span>
<span class="line" id="L593">            <span class="tok-kw">if</span> (token_tags[lbrace - <span class="tok-number">1</span>] == .colon <span class="tok-kw">and</span></span>
<span class="line" id="L594">                token_tags[lbrace - <span class="tok-number">2</span>] == .identifier)</span>
<span class="line" id="L595">            {</span>
<span class="line" id="L596">                end_offset += <span class="tok-number">2</span>;</span>
<span class="line" id="L597">            }</span>
<span class="line" id="L598">            <span class="tok-kw">return</span> lbrace - end_offset;</span>
<span class="line" id="L599">        },</span>
<span class="line" id="L600"></span>
<span class="line" id="L601">        .container_decl,</span>
<span class="line" id="L602">        .container_decl_trailing,</span>
<span class="line" id="L603">        .container_decl_two,</span>
<span class="line" id="L604">        .container_decl_two_trailing,</span>
<span class="line" id="L605">        .container_decl_arg,</span>
<span class="line" id="L606">        .container_decl_arg_trailing,</span>
<span class="line" id="L607">        .tagged_union,</span>
<span class="line" id="L608">        .tagged_union_trailing,</span>
<span class="line" id="L609">        .tagged_union_two,</span>
<span class="line" id="L610">        .tagged_union_two_trailing,</span>
<span class="line" id="L611">        .tagged_union_enum_tag,</span>
<span class="line" id="L612">        .tagged_union_enum_tag_trailing,</span>
<span class="line" id="L613">        =&gt; {</span>
<span class="line" id="L614">            <span class="tok-kw">const</span> main_token = main_tokens[n];</span>
<span class="line" id="L615">            <span class="tok-kw">switch</span> (token_tags[main_token - <span class="tok-number">1</span>]) {</span>
<span class="line" id="L616">                .keyword_packed, .keyword_extern =&gt; end_offset += <span class="tok-number">1</span>,</span>
<span class="line" id="L617">                <span class="tok-kw">else</span> =&gt; {},</span>
<span class="line" id="L618">            }</span>
<span class="line" id="L619">            <span class="tok-kw">return</span> main_token - end_offset;</span>
<span class="line" id="L620">        },</span>
<span class="line" id="L621"></span>
<span class="line" id="L622">        .ptr_type_aligned,</span>
<span class="line" id="L623">        .ptr_type_sentinel,</span>
<span class="line" id="L624">        .ptr_type,</span>
<span class="line" id="L625">        .ptr_type_bit_range,</span>
<span class="line" id="L626">        =&gt; {</span>
<span class="line" id="L627">            <span class="tok-kw">const</span> main_token = main_tokens[n];</span>
<span class="line" id="L628">            <span class="tok-kw">return</span> <span class="tok-kw">switch</span> (token_tags[main_token]) {</span>
<span class="line" id="L629">                .asterisk,</span>
<span class="line" id="L630">                .asterisk_asterisk,</span>
<span class="line" id="L631">                =&gt; <span class="tok-kw">switch</span> (token_tags[main_token - <span class="tok-number">1</span>]) {</span>
<span class="line" id="L632">                    .l_bracket =&gt; main_token - <span class="tok-number">1</span>,</span>
<span class="line" id="L633">                    <span class="tok-kw">else</span> =&gt; main_token,</span>
<span class="line" id="L634">                },</span>
<span class="line" id="L635">                .l_bracket =&gt; main_token,</span>
<span class="line" id="L636">                <span class="tok-kw">else</span> =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L637">            } - end_offset;</span>
<span class="line" id="L638">        },</span>
<span class="line" id="L639"></span>
<span class="line" id="L640">        .switch_case_one =&gt; {</span>
<span class="line" id="L641">            <span class="tok-kw">if</span> (datas[n].lhs == <span class="tok-number">0</span>) {</span>
<span class="line" id="L642">                <span class="tok-kw">return</span> main_tokens[n] - <span class="tok-number">1</span> - end_offset; <span class="tok-comment">// else token</span>
</span>
<span class="line" id="L643">            } <span class="tok-kw">else</span> {</span>
<span class="line" id="L644">                n = datas[n].lhs;</span>
<span class="line" id="L645">            }</span>
<span class="line" id="L646">        },</span>
<span class="line" id="L647">        .switch_case =&gt; {</span>
<span class="line" id="L648">            <span class="tok-kw">const</span> extra = tree.extraData(datas[n].lhs, Node.SubRange);</span>
<span class="line" id="L649">            assert(extra.end - extra.start &gt; <span class="tok-number">0</span>);</span>
<span class="line" id="L650">            n = tree.extra_data[extra.start];</span>
<span class="line" id="L651">        },</span>
<span class="line" id="L652"></span>
<span class="line" id="L653">        .asm_output, .asm_input =&gt; {</span>
<span class="line" id="L654">            assert(token_tags[main_tokens[n] - <span class="tok-number">1</span>] == .l_bracket);</span>
<span class="line" id="L655">            <span class="tok-kw">return</span> main_tokens[n] - <span class="tok-number">1</span> - end_offset;</span>
<span class="line" id="L656">        },</span>
<span class="line" id="L657"></span>
<span class="line" id="L658">        .while_simple,</span>
<span class="line" id="L659">        .while_cont,</span>
<span class="line" id="L660">        .@&quot;while&quot;,</span>
<span class="line" id="L661">        .for_simple,</span>
<span class="line" id="L662">        .@&quot;for&quot;,</span>
<span class="line" id="L663">        =&gt; {</span>
<span class="line" id="L664">            <span class="tok-comment">// Look for a label and inline.</span>
</span>
<span class="line" id="L665">            <span class="tok-kw">const</span> main_token = main_tokens[n];</span>
<span class="line" id="L666">            <span class="tok-kw">var</span> result = main_token;</span>
<span class="line" id="L667">            <span class="tok-kw">if</span> (token_tags[result - <span class="tok-number">1</span>] == .keyword_inline) {</span>
<span class="line" id="L668">                result -= <span class="tok-number">1</span>;</span>
<span class="line" id="L669">            }</span>
<span class="line" id="L670">            <span class="tok-kw">if</span> (token_tags[result - <span class="tok-number">1</span>] == .colon) {</span>
<span class="line" id="L671">                result -= <span class="tok-number">2</span>;</span>
<span class="line" id="L672">            }</span>
<span class="line" id="L673">            <span class="tok-kw">return</span> result - end_offset;</span>
<span class="line" id="L674">        },</span>
<span class="line" id="L675">    };</span>
<span class="line" id="L676">}</span>
<span class="line" id="L677"></span>
<span class="line" id="L678"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">lastToken</span>(tree: Ast, node: Node.Index) TokenIndex {</span>
<span class="line" id="L679">    <span class="tok-kw">const</span> tags = tree.nodes.items(.tag);</span>
<span class="line" id="L680">    <span class="tok-kw">const</span> datas = tree.nodes.items(.data);</span>
<span class="line" id="L681">    <span class="tok-kw">const</span> main_tokens = tree.nodes.items(.main_token);</span>
<span class="line" id="L682">    <span class="tok-kw">const</span> token_starts = tree.tokens.items(.start);</span>
<span class="line" id="L683">    <span class="tok-kw">const</span> token_tags = tree.tokens.items(.tag);</span>
<span class="line" id="L684">    <span class="tok-kw">var</span> n = node;</span>
<span class="line" id="L685">    <span class="tok-kw">var</span> end_offset: TokenIndex = <span class="tok-number">0</span>;</span>
<span class="line" id="L686">    <span class="tok-kw">while</span> (<span class="tok-null">true</span>) <span class="tok-kw">switch</span> (tags[n]) {</span>
<span class="line" id="L687">        .root =&gt; <span class="tok-kw">return</span> <span class="tok-builtin">@intCast</span>(TokenIndex, tree.tokens.len - <span class="tok-number">1</span>),</span>
<span class="line" id="L688"></span>
<span class="line" id="L689">        .@&quot;usingnamespace&quot;,</span>
<span class="line" id="L690">        .bool_not,</span>
<span class="line" id="L691">        .negation,</span>
<span class="line" id="L692">        .bit_not,</span>
<span class="line" id="L693">        .negation_wrap,</span>
<span class="line" id="L694">        .address_of,</span>
<span class="line" id="L695">        .@&quot;try&quot;,</span>
<span class="line" id="L696">        .@&quot;await&quot;,</span>
<span class="line" id="L697">        .optional_type,</span>
<span class="line" id="L698">        .@&quot;resume&quot;,</span>
<span class="line" id="L699">        .@&quot;nosuspend&quot;,</span>
<span class="line" id="L700">        .@&quot;comptime&quot;,</span>
<span class="line" id="L701">        =&gt; n = datas[n].lhs,</span>
<span class="line" id="L702"></span>
<span class="line" id="L703">        .test_decl,</span>
<span class="line" id="L704">        .@&quot;errdefer&quot;,</span>
<span class="line" id="L705">        .@&quot;defer&quot;,</span>
<span class="line" id="L706">        .@&quot;catch&quot;,</span>
<span class="line" id="L707">        .equal_equal,</span>
<span class="line" id="L708">        .bang_equal,</span>
<span class="line" id="L709">        .less_than,</span>
<span class="line" id="L710">        .greater_than,</span>
<span class="line" id="L711">        .less_or_equal,</span>
<span class="line" id="L712">        .greater_or_equal,</span>
<span class="line" id="L713">        .assign_mul,</span>
<span class="line" id="L714">        .assign_div,</span>
<span class="line" id="L715">        .assign_mod,</span>
<span class="line" id="L716">        .assign_add,</span>
<span class="line" id="L717">        .assign_sub,</span>
<span class="line" id="L718">        .assign_shl,</span>
<span class="line" id="L719">        .assign_shl_sat,</span>
<span class="line" id="L720">        .assign_shr,</span>
<span class="line" id="L721">        .assign_bit_and,</span>
<span class="line" id="L722">        .assign_bit_xor,</span>
<span class="line" id="L723">        .assign_bit_or,</span>
<span class="line" id="L724">        .assign_mul_wrap,</span>
<span class="line" id="L725">        .assign_add_wrap,</span>
<span class="line" id="L726">        .assign_sub_wrap,</span>
<span class="line" id="L727">        .assign_mul_sat,</span>
<span class="line" id="L728">        .assign_add_sat,</span>
<span class="line" id="L729">        .assign_sub_sat,</span>
<span class="line" id="L730">        .assign,</span>
<span class="line" id="L731">        .merge_error_sets,</span>
<span class="line" id="L732">        .mul,</span>
<span class="line" id="L733">        .div,</span>
<span class="line" id="L734">        .mod,</span>
<span class="line" id="L735">        .array_mult,</span>
<span class="line" id="L736">        .mul_wrap,</span>
<span class="line" id="L737">        .mul_sat,</span>
<span class="line" id="L738">        .add,</span>
<span class="line" id="L739">        .sub,</span>
<span class="line" id="L740">        .array_cat,</span>
<span class="line" id="L741">        .add_wrap,</span>
<span class="line" id="L742">        .sub_wrap,</span>
<span class="line" id="L743">        .add_sat,</span>
<span class="line" id="L744">        .sub_sat,</span>
<span class="line" id="L745">        .shl,</span>
<span class="line" id="L746">        .shl_sat,</span>
<span class="line" id="L747">        .shr,</span>
<span class="line" id="L748">        .bit_and,</span>
<span class="line" id="L749">        .bit_xor,</span>
<span class="line" id="L750">        .bit_or,</span>
<span class="line" id="L751">        .@&quot;orelse&quot;,</span>
<span class="line" id="L752">        .bool_and,</span>
<span class="line" id="L753">        .bool_or,</span>
<span class="line" id="L754">        .anyframe_type,</span>
<span class="line" id="L755">        .error_union,</span>
<span class="line" id="L756">        .if_simple,</span>
<span class="line" id="L757">        .while_simple,</span>
<span class="line" id="L758">        .for_simple,</span>
<span class="line" id="L759">        .fn_proto_simple,</span>
<span class="line" id="L760">        .fn_proto_multi,</span>
<span class="line" id="L761">        .ptr_type_aligned,</span>
<span class="line" id="L762">        .ptr_type_sentinel,</span>
<span class="line" id="L763">        .ptr_type,</span>
<span class="line" id="L764">        .ptr_type_bit_range,</span>
<span class="line" id="L765">        .array_type,</span>
<span class="line" id="L766">        .switch_case_one,</span>
<span class="line" id="L767">        .switch_case,</span>
<span class="line" id="L768">        .switch_range,</span>
<span class="line" id="L769">        =&gt; n = datas[n].rhs,</span>
<span class="line" id="L770"></span>
<span class="line" id="L771">        .field_access,</span>
<span class="line" id="L772">        .unwrap_optional,</span>
<span class="line" id="L773">        .grouped_expression,</span>
<span class="line" id="L774">        .multiline_string_literal,</span>
<span class="line" id="L775">        .error_set_decl,</span>
<span class="line" id="L776">        .asm_simple,</span>
<span class="line" id="L777">        .asm_output,</span>
<span class="line" id="L778">        .asm_input,</span>
<span class="line" id="L779">        .error_value,</span>
<span class="line" id="L780">        =&gt; <span class="tok-kw">return</span> datas[n].rhs + end_offset,</span>
<span class="line" id="L781"></span>
<span class="line" id="L782">        .anyframe_literal,</span>
<span class="line" id="L783">        .char_literal,</span>
<span class="line" id="L784">        .integer_literal,</span>
<span class="line" id="L785">        .float_literal,</span>
<span class="line" id="L786">        .unreachable_literal,</span>
<span class="line" id="L787">        .identifier,</span>
<span class="line" id="L788">        .deref,</span>
<span class="line" id="L789">        .enum_literal,</span>
<span class="line" id="L790">        .string_literal,</span>
<span class="line" id="L791">        =&gt; <span class="tok-kw">return</span> main_tokens[n] + end_offset,</span>
<span class="line" id="L792"></span>
<span class="line" id="L793">        .@&quot;return&quot; =&gt; <span class="tok-kw">if</span> (datas[n].lhs != <span class="tok-number">0</span>) {</span>
<span class="line" id="L794">            n = datas[n].lhs;</span>
<span class="line" id="L795">        } <span class="tok-kw">else</span> {</span>
<span class="line" id="L796">            <span class="tok-kw">return</span> main_tokens[n] + end_offset;</span>
<span class="line" id="L797">        },</span>
<span class="line" id="L798"></span>
<span class="line" id="L799">        .call, .async_call =&gt; {</span>
<span class="line" id="L800">            end_offset += <span class="tok-number">1</span>; <span class="tok-comment">// for the rparen</span>
</span>
<span class="line" id="L801">            <span class="tok-kw">const</span> params = tree.extraData(datas[n].rhs, Node.SubRange);</span>
<span class="line" id="L802">            <span class="tok-kw">if</span> (params.end - params.start == <span class="tok-number">0</span>) {</span>
<span class="line" id="L803">                <span class="tok-kw">return</span> main_tokens[n] + end_offset;</span>
<span class="line" id="L804">            }</span>
<span class="line" id="L805">            n = tree.extra_data[params.end - <span class="tok-number">1</span>]; <span class="tok-comment">// last parameter</span>
</span>
<span class="line" id="L806">        },</span>
<span class="line" id="L807">        .tagged_union_enum_tag =&gt; {</span>
<span class="line" id="L808">            <span class="tok-kw">const</span> members = tree.extraData(datas[n].rhs, Node.SubRange);</span>
<span class="line" id="L809">            <span class="tok-kw">if</span> (members.end - members.start == <span class="tok-number">0</span>) {</span>
<span class="line" id="L810">                end_offset += <span class="tok-number">4</span>; <span class="tok-comment">// for the rparen + rparen + lbrace + rbrace</span>
</span>
<span class="line" id="L811">                n = datas[n].lhs;</span>
<span class="line" id="L812">            } <span class="tok-kw">else</span> {</span>
<span class="line" id="L813">                end_offset += <span class="tok-number">1</span>; <span class="tok-comment">// for the rbrace</span>
</span>
<span class="line" id="L814">                n = tree.extra_data[members.end - <span class="tok-number">1</span>]; <span class="tok-comment">// last parameter</span>
</span>
<span class="line" id="L815">            }</span>
<span class="line" id="L816">        },</span>
<span class="line" id="L817">        .call_comma,</span>
<span class="line" id="L818">        .async_call_comma,</span>
<span class="line" id="L819">        .tagged_union_enum_tag_trailing,</span>
<span class="line" id="L820">        =&gt; {</span>
<span class="line" id="L821">            end_offset += <span class="tok-number">2</span>; <span class="tok-comment">// for the comma/semicolon + rparen/rbrace</span>
</span>
<span class="line" id="L822">            <span class="tok-kw">const</span> params = tree.extraData(datas[n].rhs, Node.SubRange);</span>
<span class="line" id="L823">            assert(params.end &gt; params.start);</span>
<span class="line" id="L824">            n = tree.extra_data[params.end - <span class="tok-number">1</span>]; <span class="tok-comment">// last parameter</span>
</span>
<span class="line" id="L825">        },</span>
<span class="line" id="L826">        .@&quot;switch&quot; =&gt; {</span>
<span class="line" id="L827">            <span class="tok-kw">const</span> cases = tree.extraData(datas[n].rhs, Node.SubRange);</span>
<span class="line" id="L828">            <span class="tok-kw">if</span> (cases.end - cases.start == <span class="tok-number">0</span>) {</span>
<span class="line" id="L829">                end_offset += <span class="tok-number">3</span>; <span class="tok-comment">// rparen, lbrace, rbrace</span>
</span>
<span class="line" id="L830">                n = datas[n].lhs; <span class="tok-comment">// condition expression</span>
</span>
<span class="line" id="L831">            } <span class="tok-kw">else</span> {</span>
<span class="line" id="L832">                end_offset += <span class="tok-number">1</span>; <span class="tok-comment">// for the rbrace</span>
</span>
<span class="line" id="L833">                n = tree.extra_data[cases.end - <span class="tok-number">1</span>]; <span class="tok-comment">// last case</span>
</span>
<span class="line" id="L834">            }</span>
<span class="line" id="L835">        },</span>
<span class="line" id="L836">        .container_decl_arg =&gt; {</span>
<span class="line" id="L837">            <span class="tok-kw">const</span> members = tree.extraData(datas[n].rhs, Node.SubRange);</span>
<span class="line" id="L838">            <span class="tok-kw">if</span> (members.end - members.start == <span class="tok-number">0</span>) {</span>
<span class="line" id="L839">                end_offset += <span class="tok-number">3</span>; <span class="tok-comment">// for the rparen + lbrace + rbrace</span>
</span>
<span class="line" id="L840">                n = datas[n].lhs;</span>
<span class="line" id="L841">            } <span class="tok-kw">else</span> {</span>
<span class="line" id="L842">                end_offset += <span class="tok-number">1</span>; <span class="tok-comment">// for the rbrace</span>
</span>
<span class="line" id="L843">                n = tree.extra_data[members.end - <span class="tok-number">1</span>]; <span class="tok-comment">// last parameter</span>
</span>
<span class="line" id="L844">            }</span>
<span class="line" id="L845">        },</span>
<span class="line" id="L846">        .@&quot;asm&quot; =&gt; {</span>
<span class="line" id="L847">            <span class="tok-kw">const</span> extra = tree.extraData(datas[n].rhs, Node.Asm);</span>
<span class="line" id="L848">            <span class="tok-kw">return</span> extra.rparen + end_offset;</span>
<span class="line" id="L849">        },</span>
<span class="line" id="L850">        .array_init,</span>
<span class="line" id="L851">        .struct_init,</span>
<span class="line" id="L852">        =&gt; {</span>
<span class="line" id="L853">            <span class="tok-kw">const</span> elements = tree.extraData(datas[n].rhs, Node.SubRange);</span>
<span class="line" id="L854">            assert(elements.end - elements.start &gt; <span class="tok-number">0</span>);</span>
<span class="line" id="L855">            end_offset += <span class="tok-number">1</span>; <span class="tok-comment">// for the rbrace</span>
</span>
<span class="line" id="L856">            n = tree.extra_data[elements.end - <span class="tok-number">1</span>]; <span class="tok-comment">// last element</span>
</span>
<span class="line" id="L857">        },</span>
<span class="line" id="L858">        .array_init_comma,</span>
<span class="line" id="L859">        .struct_init_comma,</span>
<span class="line" id="L860">        .container_decl_arg_trailing,</span>
<span class="line" id="L861">        .switch_comma,</span>
<span class="line" id="L862">        =&gt; {</span>
<span class="line" id="L863">            <span class="tok-kw">const</span> members = tree.extraData(datas[n].rhs, Node.SubRange);</span>
<span class="line" id="L864">            assert(members.end - members.start &gt; <span class="tok-number">0</span>);</span>
<span class="line" id="L865">            end_offset += <span class="tok-number">2</span>; <span class="tok-comment">// for the comma + rbrace</span>
</span>
<span class="line" id="L866">            n = tree.extra_data[members.end - <span class="tok-number">1</span>]; <span class="tok-comment">// last parameter</span>
</span>
<span class="line" id="L867">        },</span>
<span class="line" id="L868">        .array_init_dot,</span>
<span class="line" id="L869">        .struct_init_dot,</span>
<span class="line" id="L870">        .block,</span>
<span class="line" id="L871">        .container_decl,</span>
<span class="line" id="L872">        .tagged_union,</span>
<span class="line" id="L873">        .builtin_call,</span>
<span class="line" id="L874">        =&gt; {</span>
<span class="line" id="L875">            assert(datas[n].rhs - datas[n].lhs &gt; <span class="tok-number">0</span>);</span>
<span class="line" id="L876">            end_offset += <span class="tok-number">1</span>; <span class="tok-comment">// for the rbrace</span>
</span>
<span class="line" id="L877">            n = tree.extra_data[datas[n].rhs - <span class="tok-number">1</span>]; <span class="tok-comment">// last statement</span>
</span>
<span class="line" id="L878">        },</span>
<span class="line" id="L879">        .array_init_dot_comma,</span>
<span class="line" id="L880">        .struct_init_dot_comma,</span>
<span class="line" id="L881">        .block_semicolon,</span>
<span class="line" id="L882">        .container_decl_trailing,</span>
<span class="line" id="L883">        .tagged_union_trailing,</span>
<span class="line" id="L884">        .builtin_call_comma,</span>
<span class="line" id="L885">        =&gt; {</span>
<span class="line" id="L886">            assert(datas[n].rhs - datas[n].lhs &gt; <span class="tok-number">0</span>);</span>
<span class="line" id="L887">            end_offset += <span class="tok-number">2</span>; <span class="tok-comment">// for the comma/semicolon + rbrace/rparen</span>
</span>
<span class="line" id="L888">            n = tree.extra_data[datas[n].rhs - <span class="tok-number">1</span>]; <span class="tok-comment">// last member</span>
</span>
<span class="line" id="L889">        },</span>
<span class="line" id="L890">        .call_one,</span>
<span class="line" id="L891">        .async_call_one,</span>
<span class="line" id="L892">        .array_access,</span>
<span class="line" id="L893">        =&gt; {</span>
<span class="line" id="L894">            end_offset += <span class="tok-number">1</span>; <span class="tok-comment">// for the rparen/rbracket</span>
</span>
<span class="line" id="L895">            <span class="tok-kw">if</span> (datas[n].rhs == <span class="tok-number">0</span>) {</span>
<span class="line" id="L896">                <span class="tok-kw">return</span> main_tokens[n] + end_offset;</span>
<span class="line" id="L897">            }</span>
<span class="line" id="L898">            n = datas[n].rhs;</span>
<span class="line" id="L899">        },</span>
<span class="line" id="L900">        .array_init_dot_two,</span>
<span class="line" id="L901">        .block_two,</span>
<span class="line" id="L902">        .builtin_call_two,</span>
<span class="line" id="L903">        .struct_init_dot_two,</span>
<span class="line" id="L904">        .container_decl_two,</span>
<span class="line" id="L905">        .tagged_union_two,</span>
<span class="line" id="L906">        =&gt; {</span>
<span class="line" id="L907">            <span class="tok-kw">if</span> (datas[n].rhs != <span class="tok-number">0</span>) {</span>
<span class="line" id="L908">                end_offset += <span class="tok-number">1</span>; <span class="tok-comment">// for the rparen/rbrace</span>
</span>
<span class="line" id="L909">                n = datas[n].rhs;</span>
<span class="line" id="L910">            } <span class="tok-kw">else</span> <span class="tok-kw">if</span> (datas[n].lhs != <span class="tok-number">0</span>) {</span>
<span class="line" id="L911">                end_offset += <span class="tok-number">1</span>; <span class="tok-comment">// for the rparen/rbrace</span>
</span>
<span class="line" id="L912">                n = datas[n].lhs;</span>
<span class="line" id="L913">            } <span class="tok-kw">else</span> {</span>
<span class="line" id="L914">                <span class="tok-kw">switch</span> (tags[n]) {</span>
<span class="line" id="L915">                    .array_init_dot_two,</span>
<span class="line" id="L916">                    .block_two,</span>
<span class="line" id="L917">                    .struct_init_dot_two,</span>
<span class="line" id="L918">                    =&gt; end_offset += <span class="tok-number">1</span>, <span class="tok-comment">// rbrace</span>
</span>
<span class="line" id="L919">                    .builtin_call_two =&gt; end_offset += <span class="tok-number">2</span>, <span class="tok-comment">// lparen/lbrace + rparen/rbrace</span>
</span>
<span class="line" id="L920">                    .container_decl_two =&gt; {</span>
<span class="line" id="L921">                        <span class="tok-kw">var</span> i: <span class="tok-type">u32</span> = <span class="tok-number">2</span>; <span class="tok-comment">// lbrace + rbrace</span>
</span>
<span class="line" id="L922">                        <span class="tok-kw">while</span> (token_tags[main_tokens[n] + i] == .container_doc_comment) i += <span class="tok-number">1</span>;</span>
<span class="line" id="L923">                        end_offset += i;</span>
<span class="line" id="L924">                    },</span>
<span class="line" id="L925">                    .tagged_union_two =&gt; {</span>
<span class="line" id="L926">                        <span class="tok-kw">var</span> i: <span class="tok-type">u32</span> = <span class="tok-number">5</span>; <span class="tok-comment">// (enum) {}</span>
</span>
<span class="line" id="L927">                        <span class="tok-kw">while</span> (token_tags[main_tokens[n] + i] == .container_doc_comment) i += <span class="tok-number">1</span>;</span>
<span class="line" id="L928">                        end_offset += i;</span>
<span class="line" id="L929">                    },</span>
<span class="line" id="L930">                    <span class="tok-kw">else</span> =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L931">                }</span>
<span class="line" id="L932">                <span class="tok-kw">return</span> main_tokens[n] + end_offset;</span>
<span class="line" id="L933">            }</span>
<span class="line" id="L934">        },</span>
<span class="line" id="L935">        .array_init_dot_two_comma,</span>
<span class="line" id="L936">        .builtin_call_two_comma,</span>
<span class="line" id="L937">        .block_two_semicolon,</span>
<span class="line" id="L938">        .struct_init_dot_two_comma,</span>
<span class="line" id="L939">        .container_decl_two_trailing,</span>
<span class="line" id="L940">        .tagged_union_two_trailing,</span>
<span class="line" id="L941">        =&gt; {</span>
<span class="line" id="L942">            end_offset += <span class="tok-number">2</span>; <span class="tok-comment">// for the comma/semicolon + rbrace/rparen</span>
</span>
<span class="line" id="L943">            <span class="tok-kw">if</span> (datas[n].rhs != <span class="tok-number">0</span>) {</span>
<span class="line" id="L944">                n = datas[n].rhs;</span>
<span class="line" id="L945">            } <span class="tok-kw">else</span> <span class="tok-kw">if</span> (datas[n].lhs != <span class="tok-number">0</span>) {</span>
<span class="line" id="L946">                n = datas[n].lhs;</span>
<span class="line" id="L947">            } <span class="tok-kw">else</span> {</span>
<span class="line" id="L948">                <span class="tok-kw">unreachable</span>;</span>
<span class="line" id="L949">            }</span>
<span class="line" id="L950">        },</span>
<span class="line" id="L951">        .simple_var_decl =&gt; {</span>
<span class="line" id="L952">            <span class="tok-kw">if</span> (datas[n].rhs != <span class="tok-number">0</span>) {</span>
<span class="line" id="L953">                n = datas[n].rhs;</span>
<span class="line" id="L954">            } <span class="tok-kw">else</span> <span class="tok-kw">if</span> (datas[n].lhs != <span class="tok-number">0</span>) {</span>
<span class="line" id="L955">                n = datas[n].lhs;</span>
<span class="line" id="L956">            } <span class="tok-kw">else</span> {</span>
<span class="line" id="L957">                end_offset += <span class="tok-number">1</span>; <span class="tok-comment">// from mut token to name</span>
</span>
<span class="line" id="L958">                <span class="tok-kw">return</span> main_tokens[n] + end_offset;</span>
<span class="line" id="L959">            }</span>
<span class="line" id="L960">        },</span>
<span class="line" id="L961">        .aligned_var_decl =&gt; {</span>
<span class="line" id="L962">            <span class="tok-kw">if</span> (datas[n].rhs != <span class="tok-number">0</span>) {</span>
<span class="line" id="L963">                n = datas[n].rhs;</span>
<span class="line" id="L964">            } <span class="tok-kw">else</span> <span class="tok-kw">if</span> (datas[n].lhs != <span class="tok-number">0</span>) {</span>
<span class="line" id="L965">                end_offset += <span class="tok-number">1</span>; <span class="tok-comment">// for the rparen</span>
</span>
<span class="line" id="L966">                n = datas[n].lhs;</span>
<span class="line" id="L967">            } <span class="tok-kw">else</span> {</span>
<span class="line" id="L968">                end_offset += <span class="tok-number">1</span>; <span class="tok-comment">// from mut token to name</span>
</span>
<span class="line" id="L969">                <span class="tok-kw">return</span> main_tokens[n] + end_offset;</span>
<span class="line" id="L970">            }</span>
<span class="line" id="L971">        },</span>
<span class="line" id="L972">        .global_var_decl =&gt; {</span>
<span class="line" id="L973">            <span class="tok-kw">if</span> (datas[n].rhs != <span class="tok-number">0</span>) {</span>
<span class="line" id="L974">                n = datas[n].rhs;</span>
<span class="line" id="L975">            } <span class="tok-kw">else</span> {</span>
<span class="line" id="L976">                <span class="tok-kw">const</span> extra = tree.extraData(datas[n].lhs, Node.GlobalVarDecl);</span>
<span class="line" id="L977">                <span class="tok-kw">if</span> (extra.section_node != <span class="tok-number">0</span>) {</span>
<span class="line" id="L978">                    end_offset += <span class="tok-number">1</span>; <span class="tok-comment">// for the rparen</span>
</span>
<span class="line" id="L979">                    n = extra.section_node;</span>
<span class="line" id="L980">                } <span class="tok-kw">else</span> <span class="tok-kw">if</span> (extra.align_node != <span class="tok-number">0</span>) {</span>
<span class="line" id="L981">                    end_offset += <span class="tok-number">1</span>; <span class="tok-comment">// for the rparen</span>
</span>
<span class="line" id="L982">                    n = extra.align_node;</span>
<span class="line" id="L983">                } <span class="tok-kw">else</span> <span class="tok-kw">if</span> (extra.type_node != <span class="tok-number">0</span>) {</span>
<span class="line" id="L984">                    n = extra.type_node;</span>
<span class="line" id="L985">                } <span class="tok-kw">else</span> {</span>
<span class="line" id="L986">                    end_offset += <span class="tok-number">1</span>; <span class="tok-comment">// from mut token to name</span>
</span>
<span class="line" id="L987">                    <span class="tok-kw">return</span> main_tokens[n] + end_offset;</span>
<span class="line" id="L988">                }</span>
<span class="line" id="L989">            }</span>
<span class="line" id="L990">        },</span>
<span class="line" id="L991">        .local_var_decl =&gt; {</span>
<span class="line" id="L992">            <span class="tok-kw">if</span> (datas[n].rhs != <span class="tok-number">0</span>) {</span>
<span class="line" id="L993">                n = datas[n].rhs;</span>
<span class="line" id="L994">            } <span class="tok-kw">else</span> {</span>
<span class="line" id="L995">                <span class="tok-kw">const</span> extra = tree.extraData(datas[n].lhs, Node.LocalVarDecl);</span>
<span class="line" id="L996">                <span class="tok-kw">if</span> (extra.align_node != <span class="tok-number">0</span>) {</span>
<span class="line" id="L997">                    end_offset += <span class="tok-number">1</span>; <span class="tok-comment">// for the rparen</span>
</span>
<span class="line" id="L998">                    n = extra.align_node;</span>
<span class="line" id="L999">                } <span class="tok-kw">else</span> <span class="tok-kw">if</span> (extra.type_node != <span class="tok-number">0</span>) {</span>
<span class="line" id="L1000">                    n = extra.type_node;</span>
<span class="line" id="L1001">                } <span class="tok-kw">else</span> {</span>
<span class="line" id="L1002">                    end_offset += <span class="tok-number">1</span>; <span class="tok-comment">// from mut token to name</span>
</span>
<span class="line" id="L1003">                    <span class="tok-kw">return</span> main_tokens[n] + end_offset;</span>
<span class="line" id="L1004">                }</span>
<span class="line" id="L1005">            }</span>
<span class="line" id="L1006">        },</span>
<span class="line" id="L1007">        .container_field_init =&gt; {</span>
<span class="line" id="L1008">            <span class="tok-kw">if</span> (datas[n].rhs != <span class="tok-number">0</span>) {</span>
<span class="line" id="L1009">                n = datas[n].rhs;</span>
<span class="line" id="L1010">            } <span class="tok-kw">else</span> <span class="tok-kw">if</span> (datas[n].lhs != <span class="tok-number">0</span>) {</span>
<span class="line" id="L1011">                n = datas[n].lhs;</span>
<span class="line" id="L1012">            } <span class="tok-kw">else</span> {</span>
<span class="line" id="L1013">                <span class="tok-kw">return</span> main_tokens[n] + end_offset;</span>
<span class="line" id="L1014">            }</span>
<span class="line" id="L1015">        },</span>
<span class="line" id="L1016">        .container_field_align =&gt; {</span>
<span class="line" id="L1017">            <span class="tok-kw">if</span> (datas[n].rhs != <span class="tok-number">0</span>) {</span>
<span class="line" id="L1018">                end_offset += <span class="tok-number">1</span>; <span class="tok-comment">// for the rparen</span>
</span>
<span class="line" id="L1019">                n = datas[n].rhs;</span>
<span class="line" id="L1020">            } <span class="tok-kw">else</span> <span class="tok-kw">if</span> (datas[n].lhs != <span class="tok-number">0</span>) {</span>
<span class="line" id="L1021">                n = datas[n].lhs;</span>
<span class="line" id="L1022">            } <span class="tok-kw">else</span> {</span>
<span class="line" id="L1023">                <span class="tok-kw">return</span> main_tokens[n] + end_offset;</span>
<span class="line" id="L1024">            }</span>
<span class="line" id="L1025">        },</span>
<span class="line" id="L1026">        .container_field =&gt; {</span>
<span class="line" id="L1027">            <span class="tok-kw">const</span> extra = tree.extraData(datas[n].rhs, Node.ContainerField);</span>
<span class="line" id="L1028">            <span class="tok-kw">if</span> (extra.value_expr != <span class="tok-number">0</span>) {</span>
<span class="line" id="L1029">                n = extra.value_expr;</span>
<span class="line" id="L1030">            } <span class="tok-kw">else</span> <span class="tok-kw">if</span> (extra.align_expr != <span class="tok-number">0</span>) {</span>
<span class="line" id="L1031">                end_offset += <span class="tok-number">1</span>; <span class="tok-comment">// for the rparen</span>
</span>
<span class="line" id="L1032">                n = extra.align_expr;</span>
<span class="line" id="L1033">            } <span class="tok-kw">else</span> <span class="tok-kw">if</span> (datas[n].lhs != <span class="tok-number">0</span>) {</span>
<span class="line" id="L1034">                n = datas[n].lhs;</span>
<span class="line" id="L1035">            } <span class="tok-kw">else</span> {</span>
<span class="line" id="L1036">                <span class="tok-kw">return</span> main_tokens[n] + end_offset;</span>
<span class="line" id="L1037">            }</span>
<span class="line" id="L1038">        },</span>
<span class="line" id="L1039"></span>
<span class="line" id="L1040">        .array_init_one,</span>
<span class="line" id="L1041">        .struct_init_one,</span>
<span class="line" id="L1042">        =&gt; {</span>
<span class="line" id="L1043">            end_offset += <span class="tok-number">1</span>; <span class="tok-comment">// rbrace</span>
</span>
<span class="line" id="L1044">            <span class="tok-kw">if</span> (datas[n].rhs == <span class="tok-number">0</span>) {</span>
<span class="line" id="L1045">                <span class="tok-kw">return</span> main_tokens[n] + end_offset;</span>
<span class="line" id="L1046">            } <span class="tok-kw">else</span> {</span>
<span class="line" id="L1047">                n = datas[n].rhs;</span>
<span class="line" id="L1048">            }</span>
<span class="line" id="L1049">        },</span>
<span class="line" id="L1050">        .slice_open,</span>
<span class="line" id="L1051">        .call_one_comma,</span>
<span class="line" id="L1052">        .async_call_one_comma,</span>
<span class="line" id="L1053">        .array_init_one_comma,</span>
<span class="line" id="L1054">        .struct_init_one_comma,</span>
<span class="line" id="L1055">        =&gt; {</span>
<span class="line" id="L1056">            end_offset += <span class="tok-number">2</span>; <span class="tok-comment">// ellipsis2 + rbracket, or comma + rparen</span>
</span>
<span class="line" id="L1057">            n = datas[n].rhs;</span>
<span class="line" id="L1058">            assert(n != <span class="tok-number">0</span>);</span>
<span class="line" id="L1059">        },</span>
<span class="line" id="L1060">        .slice =&gt; {</span>
<span class="line" id="L1061">            <span class="tok-kw">const</span> extra = tree.extraData(datas[n].rhs, Node.Slice);</span>
<span class="line" id="L1062">            assert(extra.end != <span class="tok-number">0</span>); <span class="tok-comment">// should have used slice_open</span>
</span>
<span class="line" id="L1063">            end_offset += <span class="tok-number">1</span>; <span class="tok-comment">// rbracket</span>
</span>
<span class="line" id="L1064">            n = extra.end;</span>
<span class="line" id="L1065">        },</span>
<span class="line" id="L1066">        .slice_sentinel =&gt; {</span>
<span class="line" id="L1067">            <span class="tok-kw">const</span> extra = tree.extraData(datas[n].rhs, Node.SliceSentinel);</span>
<span class="line" id="L1068">            assert(extra.sentinel != <span class="tok-number">0</span>); <span class="tok-comment">// should have used slice</span>
</span>
<span class="line" id="L1069">            end_offset += <span class="tok-number">1</span>; <span class="tok-comment">// rbracket</span>
</span>
<span class="line" id="L1070">            n = extra.sentinel;</span>
<span class="line" id="L1071">        },</span>
<span class="line" id="L1072"></span>
<span class="line" id="L1073">        .@&quot;continue&quot; =&gt; {</span>
<span class="line" id="L1074">            <span class="tok-kw">if</span> (datas[n].lhs != <span class="tok-number">0</span>) {</span>
<span class="line" id="L1075">                <span class="tok-kw">return</span> datas[n].lhs + end_offset;</span>
<span class="line" id="L1076">            } <span class="tok-kw">else</span> {</span>
<span class="line" id="L1077">                <span class="tok-kw">return</span> main_tokens[n] + end_offset;</span>
<span class="line" id="L1078">            }</span>
<span class="line" id="L1079">        },</span>
<span class="line" id="L1080">        .@&quot;break&quot; =&gt; {</span>
<span class="line" id="L1081">            <span class="tok-kw">if</span> (datas[n].rhs != <span class="tok-number">0</span>) {</span>
<span class="line" id="L1082">                n = datas[n].rhs;</span>
<span class="line" id="L1083">            } <span class="tok-kw">else</span> <span class="tok-kw">if</span> (datas[n].lhs != <span class="tok-number">0</span>) {</span>
<span class="line" id="L1084">                <span class="tok-kw">return</span> datas[n].lhs + end_offset;</span>
<span class="line" id="L1085">            } <span class="tok-kw">else</span> {</span>
<span class="line" id="L1086">                <span class="tok-kw">return</span> main_tokens[n] + end_offset;</span>
<span class="line" id="L1087">            }</span>
<span class="line" id="L1088">        },</span>
<span class="line" id="L1089">        .fn_decl =&gt; {</span>
<span class="line" id="L1090">            <span class="tok-kw">if</span> (datas[n].rhs != <span class="tok-number">0</span>) {</span>
<span class="line" id="L1091">                n = datas[n].rhs;</span>
<span class="line" id="L1092">            } <span class="tok-kw">else</span> {</span>
<span class="line" id="L1093">                n = datas[n].lhs;</span>
<span class="line" id="L1094">            }</span>
<span class="line" id="L1095">        },</span>
<span class="line" id="L1096">        .fn_proto_one =&gt; {</span>
<span class="line" id="L1097">            <span class="tok-kw">const</span> extra = tree.extraData(datas[n].lhs, Node.FnProtoOne);</span>
<span class="line" id="L1098">            <span class="tok-comment">// addrspace, linksection, callconv, align can appear in any order, so we</span>
</span>
<span class="line" id="L1099">            <span class="tok-comment">// find the last one here.</span>
</span>
<span class="line" id="L1100">            <span class="tok-kw">var</span> max_node: Node.Index = datas[n].rhs;</span>
<span class="line" id="L1101">            <span class="tok-kw">var</span> max_start = token_starts[main_tokens[max_node]];</span>
<span class="line" id="L1102">            <span class="tok-kw">var</span> max_offset: TokenIndex = <span class="tok-number">0</span>;</span>
<span class="line" id="L1103">            <span class="tok-kw">if</span> (extra.align_expr != <span class="tok-number">0</span>) {</span>
<span class="line" id="L1104">                <span class="tok-kw">const</span> start = token_starts[main_tokens[extra.align_expr]];</span>
<span class="line" id="L1105">                <span class="tok-kw">if</span> (start &gt; max_start) {</span>
<span class="line" id="L1106">                    max_node = extra.align_expr;</span>
<span class="line" id="L1107">                    max_start = start;</span>
<span class="line" id="L1108">                    max_offset = <span class="tok-number">1</span>; <span class="tok-comment">// for the rparen</span>
</span>
<span class="line" id="L1109">                }</span>
<span class="line" id="L1110">            }</span>
<span class="line" id="L1111">            <span class="tok-kw">if</span> (extra.addrspace_expr != <span class="tok-number">0</span>) {</span>
<span class="line" id="L1112">                <span class="tok-kw">const</span> start = token_starts[main_tokens[extra.addrspace_expr]];</span>
<span class="line" id="L1113">                <span class="tok-kw">if</span> (start &gt; max_start) {</span>
<span class="line" id="L1114">                    max_node = extra.addrspace_expr;</span>
<span class="line" id="L1115">                    max_start = start;</span>
<span class="line" id="L1116">                    max_offset = <span class="tok-number">1</span>; <span class="tok-comment">// for the rparen</span>
</span>
<span class="line" id="L1117">                }</span>
<span class="line" id="L1118">            }</span>
<span class="line" id="L1119">            <span class="tok-kw">if</span> (extra.section_expr != <span class="tok-number">0</span>) {</span>
<span class="line" id="L1120">                <span class="tok-kw">const</span> start = token_starts[main_tokens[extra.section_expr]];</span>
<span class="line" id="L1121">                <span class="tok-kw">if</span> (start &gt; max_start) {</span>
<span class="line" id="L1122">                    max_node = extra.section_expr;</span>
<span class="line" id="L1123">                    max_start = start;</span>
<span class="line" id="L1124">                    max_offset = <span class="tok-number">1</span>; <span class="tok-comment">// for the rparen</span>
</span>
<span class="line" id="L1125">                }</span>
<span class="line" id="L1126">            }</span>
<span class="line" id="L1127">            <span class="tok-kw">if</span> (extra.callconv_expr != <span class="tok-number">0</span>) {</span>
<span class="line" id="L1128">                <span class="tok-kw">const</span> start = token_starts[main_tokens[extra.callconv_expr]];</span>
<span class="line" id="L1129">                <span class="tok-kw">if</span> (start &gt; max_start) {</span>
<span class="line" id="L1130">                    max_node = extra.callconv_expr;</span>
<span class="line" id="L1131">                    max_start = start;</span>
<span class="line" id="L1132">                    max_offset = <span class="tok-number">1</span>; <span class="tok-comment">// for the rparen</span>
</span>
<span class="line" id="L1133">                }</span>
<span class="line" id="L1134">            }</span>
<span class="line" id="L1135">            n = max_node;</span>
<span class="line" id="L1136">            end_offset += max_offset;</span>
<span class="line" id="L1137">        },</span>
<span class="line" id="L1138">        .fn_proto =&gt; {</span>
<span class="line" id="L1139">            <span class="tok-kw">const</span> extra = tree.extraData(datas[n].lhs, Node.FnProto);</span>
<span class="line" id="L1140">            <span class="tok-comment">// addrspace, linksection, callconv, align can appear in any order, so we</span>
</span>
<span class="line" id="L1141">            <span class="tok-comment">// find the last one here.</span>
</span>
<span class="line" id="L1142">            <span class="tok-kw">var</span> max_node: Node.Index = datas[n].rhs;</span>
<span class="line" id="L1143">            <span class="tok-kw">var</span> max_start = token_starts[main_tokens[max_node]];</span>
<span class="line" id="L1144">            <span class="tok-kw">var</span> max_offset: TokenIndex = <span class="tok-number">0</span>;</span>
<span class="line" id="L1145">            <span class="tok-kw">if</span> (extra.align_expr != <span class="tok-number">0</span>) {</span>
<span class="line" id="L1146">                <span class="tok-kw">const</span> start = token_starts[main_tokens[extra.align_expr]];</span>
<span class="line" id="L1147">                <span class="tok-kw">if</span> (start &gt; max_start) {</span>
<span class="line" id="L1148">                    max_node = extra.align_expr;</span>
<span class="line" id="L1149">                    max_start = start;</span>
<span class="line" id="L1150">                    max_offset = <span class="tok-number">1</span>; <span class="tok-comment">// for the rparen</span>
</span>
<span class="line" id="L1151">                }</span>
<span class="line" id="L1152">            }</span>
<span class="line" id="L1153">            <span class="tok-kw">if</span> (extra.addrspace_expr != <span class="tok-number">0</span>) {</span>
<span class="line" id="L1154">                <span class="tok-kw">const</span> start = token_starts[main_tokens[extra.addrspace_expr]];</span>
<span class="line" id="L1155">                <span class="tok-kw">if</span> (start &gt; max_start) {</span>
<span class="line" id="L1156">                    max_node = extra.addrspace_expr;</span>
<span class="line" id="L1157">                    max_start = start;</span>
<span class="line" id="L1158">                    max_offset = <span class="tok-number">1</span>; <span class="tok-comment">// for the rparen</span>
</span>
<span class="line" id="L1159">                }</span>
<span class="line" id="L1160">            }</span>
<span class="line" id="L1161">            <span class="tok-kw">if</span> (extra.section_expr != <span class="tok-number">0</span>) {</span>
<span class="line" id="L1162">                <span class="tok-kw">const</span> start = token_starts[main_tokens[extra.section_expr]];</span>
<span class="line" id="L1163">                <span class="tok-kw">if</span> (start &gt; max_start) {</span>
<span class="line" id="L1164">                    max_node = extra.section_expr;</span>
<span class="line" id="L1165">                    max_start = start;</span>
<span class="line" id="L1166">                    max_offset = <span class="tok-number">1</span>; <span class="tok-comment">// for the rparen</span>
</span>
<span class="line" id="L1167">                }</span>
<span class="line" id="L1168">            }</span>
<span class="line" id="L1169">            <span class="tok-kw">if</span> (extra.callconv_expr != <span class="tok-number">0</span>) {</span>
<span class="line" id="L1170">                <span class="tok-kw">const</span> start = token_starts[main_tokens[extra.callconv_expr]];</span>
<span class="line" id="L1171">                <span class="tok-kw">if</span> (start &gt; max_start) {</span>
<span class="line" id="L1172">                    max_node = extra.callconv_expr;</span>
<span class="line" id="L1173">                    max_start = start;</span>
<span class="line" id="L1174">                    max_offset = <span class="tok-number">1</span>; <span class="tok-comment">// for the rparen</span>
</span>
<span class="line" id="L1175">                }</span>
<span class="line" id="L1176">            }</span>
<span class="line" id="L1177">            n = max_node;</span>
<span class="line" id="L1178">            end_offset += max_offset;</span>
<span class="line" id="L1179">        },</span>
<span class="line" id="L1180">        .while_cont =&gt; {</span>
<span class="line" id="L1181">            <span class="tok-kw">const</span> extra = tree.extraData(datas[n].rhs, Node.WhileCont);</span>
<span class="line" id="L1182">            assert(extra.then_expr != <span class="tok-number">0</span>);</span>
<span class="line" id="L1183">            n = extra.then_expr;</span>
<span class="line" id="L1184">        },</span>
<span class="line" id="L1185">        .@&quot;while&quot; =&gt; {</span>
<span class="line" id="L1186">            <span class="tok-kw">const</span> extra = tree.extraData(datas[n].rhs, Node.While);</span>
<span class="line" id="L1187">            assert(extra.else_expr != <span class="tok-number">0</span>);</span>
<span class="line" id="L1188">            n = extra.else_expr;</span>
<span class="line" id="L1189">        },</span>
<span class="line" id="L1190">        .@&quot;if&quot;, .@&quot;for&quot; =&gt; {</span>
<span class="line" id="L1191">            <span class="tok-kw">const</span> extra = tree.extraData(datas[n].rhs, Node.If);</span>
<span class="line" id="L1192">            assert(extra.else_expr != <span class="tok-number">0</span>);</span>
<span class="line" id="L1193">            n = extra.else_expr;</span>
<span class="line" id="L1194">        },</span>
<span class="line" id="L1195">        .@&quot;suspend&quot; =&gt; {</span>
<span class="line" id="L1196">            <span class="tok-kw">if</span> (datas[n].lhs != <span class="tok-number">0</span>) {</span>
<span class="line" id="L1197">                n = datas[n].lhs;</span>
<span class="line" id="L1198">            } <span class="tok-kw">else</span> {</span>
<span class="line" id="L1199">                <span class="tok-kw">return</span> main_tokens[n] + end_offset;</span>
<span class="line" id="L1200">            }</span>
<span class="line" id="L1201">        },</span>
<span class="line" id="L1202">        .array_type_sentinel =&gt; {</span>
<span class="line" id="L1203">            <span class="tok-kw">const</span> extra = tree.extraData(datas[n].rhs, Node.ArrayTypeSentinel);</span>
<span class="line" id="L1204">            n = extra.elem_type;</span>
<span class="line" id="L1205">        },</span>
<span class="line" id="L1206">    };</span>
<span class="line" id="L1207">}</span>
<span class="line" id="L1208"></span>
<span class="line" id="L1209"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">tokensOnSameLine</span>(tree: Ast, token1: TokenIndex, token2: TokenIndex) <span class="tok-type">bool</span> {</span>
<span class="line" id="L1210">    <span class="tok-kw">const</span> token_starts = tree.tokens.items(.start);</span>
<span class="line" id="L1211">    <span class="tok-kw">const</span> source = tree.source[token_starts[token1]..token_starts[token2]];</span>
<span class="line" id="L1212">    <span class="tok-kw">return</span> mem.indexOfScalar(<span class="tok-type">u8</span>, source, <span class="tok-str">'\n'</span>) == <span class="tok-null">null</span>;</span>
<span class="line" id="L1213">}</span>
<span class="line" id="L1214"></span>
<span class="line" id="L1215"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">getNodeSource</span>(tree: Ast, node: Node.Index) []<span class="tok-kw">const</span> <span class="tok-type">u8</span> {</span>
<span class="line" id="L1216">    <span class="tok-kw">const</span> token_starts = tree.tokens.items(.start);</span>
<span class="line" id="L1217">    <span class="tok-kw">const</span> first_token = tree.firstToken(node);</span>
<span class="line" id="L1218">    <span class="tok-kw">const</span> last_token = tree.lastToken(node);</span>
<span class="line" id="L1219">    <span class="tok-kw">const</span> start = token_starts[first_token];</span>
<span class="line" id="L1220">    <span class="tok-kw">const</span> end = token_starts[last_token] + tree.tokenSlice(last_token).len;</span>
<span class="line" id="L1221">    <span class="tok-kw">return</span> tree.source[start..end];</span>
<span class="line" id="L1222">}</span>
<span class="line" id="L1223"></span>
<span class="line" id="L1224"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">globalVarDecl</span>(tree: Ast, node: Node.Index) full.VarDecl {</span>
<span class="line" id="L1225">    assert(tree.nodes.items(.tag)[node] == .global_var_decl);</span>
<span class="line" id="L1226">    <span class="tok-kw">const</span> data = tree.nodes.items(.data)[node];</span>
<span class="line" id="L1227">    <span class="tok-kw">const</span> extra = tree.extraData(data.lhs, Node.GlobalVarDecl);</span>
<span class="line" id="L1228">    <span class="tok-kw">return</span> tree.fullVarDecl(.{</span>
<span class="line" id="L1229">        .type_node = extra.type_node,</span>
<span class="line" id="L1230">        .align_node = extra.align_node,</span>
<span class="line" id="L1231">        .addrspace_node = extra.addrspace_node,</span>
<span class="line" id="L1232">        .section_node = extra.section_node,</span>
<span class="line" id="L1233">        .init_node = data.rhs,</span>
<span class="line" id="L1234">        .mut_token = tree.nodes.items(.main_token)[node],</span>
<span class="line" id="L1235">    });</span>
<span class="line" id="L1236">}</span>
<span class="line" id="L1237"></span>
<span class="line" id="L1238"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">localVarDecl</span>(tree: Ast, node: Node.Index) full.VarDecl {</span>
<span class="line" id="L1239">    assert(tree.nodes.items(.tag)[node] == .local_var_decl);</span>
<span class="line" id="L1240">    <span class="tok-kw">const</span> data = tree.nodes.items(.data)[node];</span>
<span class="line" id="L1241">    <span class="tok-kw">const</span> extra = tree.extraData(data.lhs, Node.LocalVarDecl);</span>
<span class="line" id="L1242">    <span class="tok-kw">return</span> tree.fullVarDecl(.{</span>
<span class="line" id="L1243">        .type_node = extra.type_node,</span>
<span class="line" id="L1244">        .align_node = extra.align_node,</span>
<span class="line" id="L1245">        .addrspace_node = <span class="tok-number">0</span>,</span>
<span class="line" id="L1246">        .section_node = <span class="tok-number">0</span>,</span>
<span class="line" id="L1247">        .init_node = data.rhs,</span>
<span class="line" id="L1248">        .mut_token = tree.nodes.items(.main_token)[node],</span>
<span class="line" id="L1249">    });</span>
<span class="line" id="L1250">}</span>
<span class="line" id="L1251"></span>
<span class="line" id="L1252"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">simpleVarDecl</span>(tree: Ast, node: Node.Index) full.VarDecl {</span>
<span class="line" id="L1253">    assert(tree.nodes.items(.tag)[node] == .simple_var_decl);</span>
<span class="line" id="L1254">    <span class="tok-kw">const</span> data = tree.nodes.items(.data)[node];</span>
<span class="line" id="L1255">    <span class="tok-kw">return</span> tree.fullVarDecl(.{</span>
<span class="line" id="L1256">        .type_node = data.lhs,</span>
<span class="line" id="L1257">        .align_node = <span class="tok-number">0</span>,</span>
<span class="line" id="L1258">        .addrspace_node = <span class="tok-number">0</span>,</span>
<span class="line" id="L1259">        .section_node = <span class="tok-number">0</span>,</span>
<span class="line" id="L1260">        .init_node = data.rhs,</span>
<span class="line" id="L1261">        .mut_token = tree.nodes.items(.main_token)[node],</span>
<span class="line" id="L1262">    });</span>
<span class="line" id="L1263">}</span>
<span class="line" id="L1264"></span>
<span class="line" id="L1265"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">alignedVarDecl</span>(tree: Ast, node: Node.Index) full.VarDecl {</span>
<span class="line" id="L1266">    assert(tree.nodes.items(.tag)[node] == .aligned_var_decl);</span>
<span class="line" id="L1267">    <span class="tok-kw">const</span> data = tree.nodes.items(.data)[node];</span>
<span class="line" id="L1268">    <span class="tok-kw">return</span> tree.fullVarDecl(.{</span>
<span class="line" id="L1269">        .type_node = <span class="tok-number">0</span>,</span>
<span class="line" id="L1270">        .align_node = data.lhs,</span>
<span class="line" id="L1271">        .addrspace_node = <span class="tok-number">0</span>,</span>
<span class="line" id="L1272">        .section_node = <span class="tok-number">0</span>,</span>
<span class="line" id="L1273">        .init_node = data.rhs,</span>
<span class="line" id="L1274">        .mut_token = tree.nodes.items(.main_token)[node],</span>
<span class="line" id="L1275">    });</span>
<span class="line" id="L1276">}</span>
<span class="line" id="L1277"></span>
<span class="line" id="L1278"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">ifSimple</span>(tree: Ast, node: Node.Index) full.If {</span>
<span class="line" id="L1279">    assert(tree.nodes.items(.tag)[node] == .if_simple);</span>
<span class="line" id="L1280">    <span class="tok-kw">const</span> data = tree.nodes.items(.data)[node];</span>
<span class="line" id="L1281">    <span class="tok-kw">return</span> tree.fullIf(.{</span>
<span class="line" id="L1282">        .cond_expr = data.lhs,</span>
<span class="line" id="L1283">        .then_expr = data.rhs,</span>
<span class="line" id="L1284">        .else_expr = <span class="tok-number">0</span>,</span>
<span class="line" id="L1285">        .if_token = tree.nodes.items(.main_token)[node],</span>
<span class="line" id="L1286">    });</span>
<span class="line" id="L1287">}</span>
<span class="line" id="L1288"></span>
<span class="line" id="L1289"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">ifFull</span>(tree: Ast, node: Node.Index) full.If {</span>
<span class="line" id="L1290">    assert(tree.nodes.items(.tag)[node] == .@&quot;if&quot;);</span>
<span class="line" id="L1291">    <span class="tok-kw">const</span> data = tree.nodes.items(.data)[node];</span>
<span class="line" id="L1292">    <span class="tok-kw">const</span> extra = tree.extraData(data.rhs, Node.If);</span>
<span class="line" id="L1293">    <span class="tok-kw">return</span> tree.fullIf(.{</span>
<span class="line" id="L1294">        .cond_expr = data.lhs,</span>
<span class="line" id="L1295">        .then_expr = extra.then_expr,</span>
<span class="line" id="L1296">        .else_expr = extra.else_expr,</span>
<span class="line" id="L1297">        .if_token = tree.nodes.items(.main_token)[node],</span>
<span class="line" id="L1298">    });</span>
<span class="line" id="L1299">}</span>
<span class="line" id="L1300"></span>
<span class="line" id="L1301"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">containerField</span>(tree: Ast, node: Node.Index) full.ContainerField {</span>
<span class="line" id="L1302">    assert(tree.nodes.items(.tag)[node] == .container_field);</span>
<span class="line" id="L1303">    <span class="tok-kw">const</span> data = tree.nodes.items(.data)[node];</span>
<span class="line" id="L1304">    <span class="tok-kw">const</span> extra = tree.extraData(data.rhs, Node.ContainerField);</span>
<span class="line" id="L1305">    <span class="tok-kw">return</span> tree.fullContainerField(.{</span>
<span class="line" id="L1306">        .name_token = tree.nodes.items(.main_token)[node],</span>
<span class="line" id="L1307">        .type_expr = data.lhs,</span>
<span class="line" id="L1308">        .value_expr = extra.value_expr,</span>
<span class="line" id="L1309">        .align_expr = extra.align_expr,</span>
<span class="line" id="L1310">    });</span>
<span class="line" id="L1311">}</span>
<span class="line" id="L1312"></span>
<span class="line" id="L1313"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">containerFieldInit</span>(tree: Ast, node: Node.Index) full.ContainerField {</span>
<span class="line" id="L1314">    assert(tree.nodes.items(.tag)[node] == .container_field_init);</span>
<span class="line" id="L1315">    <span class="tok-kw">const</span> data = tree.nodes.items(.data)[node];</span>
<span class="line" id="L1316">    <span class="tok-kw">return</span> tree.fullContainerField(.{</span>
<span class="line" id="L1317">        .name_token = tree.nodes.items(.main_token)[node],</span>
<span class="line" id="L1318">        .type_expr = data.lhs,</span>
<span class="line" id="L1319">        .value_expr = data.rhs,</span>
<span class="line" id="L1320">        .align_expr = <span class="tok-number">0</span>,</span>
<span class="line" id="L1321">    });</span>
<span class="line" id="L1322">}</span>
<span class="line" id="L1323"></span>
<span class="line" id="L1324"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">containerFieldAlign</span>(tree: Ast, node: Node.Index) full.ContainerField {</span>
<span class="line" id="L1325">    assert(tree.nodes.items(.tag)[node] == .container_field_align);</span>
<span class="line" id="L1326">    <span class="tok-kw">const</span> data = tree.nodes.items(.data)[node];</span>
<span class="line" id="L1327">    <span class="tok-kw">return</span> tree.fullContainerField(.{</span>
<span class="line" id="L1328">        .name_token = tree.nodes.items(.main_token)[node],</span>
<span class="line" id="L1329">        .type_expr = data.lhs,</span>
<span class="line" id="L1330">        .value_expr = <span class="tok-number">0</span>,</span>
<span class="line" id="L1331">        .align_expr = data.rhs,</span>
<span class="line" id="L1332">    });</span>
<span class="line" id="L1333">}</span>
<span class="line" id="L1334"></span>
<span class="line" id="L1335"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">fnProtoSimple</span>(tree: Ast, buffer: *[<span class="tok-number">1</span>]Node.Index, node: Node.Index) full.FnProto {</span>
<span class="line" id="L1336">    assert(tree.nodes.items(.tag)[node] == .fn_proto_simple);</span>
<span class="line" id="L1337">    <span class="tok-kw">const</span> data = tree.nodes.items(.data)[node];</span>
<span class="line" id="L1338">    buffer[<span class="tok-number">0</span>] = data.lhs;</span>
<span class="line" id="L1339">    <span class="tok-kw">const</span> params = <span class="tok-kw">if</span> (data.lhs == <span class="tok-number">0</span>) buffer[<span class="tok-number">0</span>..<span class="tok-number">0</span>] <span class="tok-kw">else</span> buffer[<span class="tok-number">0</span>..<span class="tok-number">1</span>];</span>
<span class="line" id="L1340">    <span class="tok-kw">return</span> tree.fullFnProto(.{</span>
<span class="line" id="L1341">        .proto_node = node,</span>
<span class="line" id="L1342">        .fn_token = tree.nodes.items(.main_token)[node],</span>
<span class="line" id="L1343">        .return_type = data.rhs,</span>
<span class="line" id="L1344">        .params = params,</span>
<span class="line" id="L1345">        .align_expr = <span class="tok-number">0</span>,</span>
<span class="line" id="L1346">        .addrspace_expr = <span class="tok-number">0</span>,</span>
<span class="line" id="L1347">        .section_expr = <span class="tok-number">0</span>,</span>
<span class="line" id="L1348">        .callconv_expr = <span class="tok-number">0</span>,</span>
<span class="line" id="L1349">    });</span>
<span class="line" id="L1350">}</span>
<span class="line" id="L1351"></span>
<span class="line" id="L1352"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">fnProtoMulti</span>(tree: Ast, node: Node.Index) full.FnProto {</span>
<span class="line" id="L1353">    assert(tree.nodes.items(.tag)[node] == .fn_proto_multi);</span>
<span class="line" id="L1354">    <span class="tok-kw">const</span> data = tree.nodes.items(.data)[node];</span>
<span class="line" id="L1355">    <span class="tok-kw">const</span> params_range = tree.extraData(data.lhs, Node.SubRange);</span>
<span class="line" id="L1356">    <span class="tok-kw">const</span> params = tree.extra_data[params_range.start..params_range.end];</span>
<span class="line" id="L1357">    <span class="tok-kw">return</span> tree.fullFnProto(.{</span>
<span class="line" id="L1358">        .proto_node = node,</span>
<span class="line" id="L1359">        .fn_token = tree.nodes.items(.main_token)[node],</span>
<span class="line" id="L1360">        .return_type = data.rhs,</span>
<span class="line" id="L1361">        .params = params,</span>
<span class="line" id="L1362">        .align_expr = <span class="tok-number">0</span>,</span>
<span class="line" id="L1363">        .addrspace_expr = <span class="tok-number">0</span>,</span>
<span class="line" id="L1364">        .section_expr = <span class="tok-number">0</span>,</span>
<span class="line" id="L1365">        .callconv_expr = <span class="tok-number">0</span>,</span>
<span class="line" id="L1366">    });</span>
<span class="line" id="L1367">}</span>
<span class="line" id="L1368"></span>
<span class="line" id="L1369"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">fnProtoOne</span>(tree: Ast, buffer: *[<span class="tok-number">1</span>]Node.Index, node: Node.Index) full.FnProto {</span>
<span class="line" id="L1370">    assert(tree.nodes.items(.tag)[node] == .fn_proto_one);</span>
<span class="line" id="L1371">    <span class="tok-kw">const</span> data = tree.nodes.items(.data)[node];</span>
<span class="line" id="L1372">    <span class="tok-kw">const</span> extra = tree.extraData(data.lhs, Node.FnProtoOne);</span>
<span class="line" id="L1373">    buffer[<span class="tok-number">0</span>] = extra.param;</span>
<span class="line" id="L1374">    <span class="tok-kw">const</span> params = <span class="tok-kw">if</span> (extra.param == <span class="tok-number">0</span>) buffer[<span class="tok-number">0</span>..<span class="tok-number">0</span>] <span class="tok-kw">else</span> buffer[<span class="tok-number">0</span>..<span class="tok-number">1</span>];</span>
<span class="line" id="L1375">    <span class="tok-kw">return</span> tree.fullFnProto(.{</span>
<span class="line" id="L1376">        .proto_node = node,</span>
<span class="line" id="L1377">        .fn_token = tree.nodes.items(.main_token)[node],</span>
<span class="line" id="L1378">        .return_type = data.rhs,</span>
<span class="line" id="L1379">        .params = params,</span>
<span class="line" id="L1380">        .align_expr = extra.align_expr,</span>
<span class="line" id="L1381">        .addrspace_expr = extra.addrspace_expr,</span>
<span class="line" id="L1382">        .section_expr = extra.section_expr,</span>
<span class="line" id="L1383">        .callconv_expr = extra.callconv_expr,</span>
<span class="line" id="L1384">    });</span>
<span class="line" id="L1385">}</span>
<span class="line" id="L1386"></span>
<span class="line" id="L1387"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">fnProto</span>(tree: Ast, node: Node.Index) full.FnProto {</span>
<span class="line" id="L1388">    assert(tree.nodes.items(.tag)[node] == .fn_proto);</span>
<span class="line" id="L1389">    <span class="tok-kw">const</span> data = tree.nodes.items(.data)[node];</span>
<span class="line" id="L1390">    <span class="tok-kw">const</span> extra = tree.extraData(data.lhs, Node.FnProto);</span>
<span class="line" id="L1391">    <span class="tok-kw">const</span> params = tree.extra_data[extra.params_start..extra.params_end];</span>
<span class="line" id="L1392">    <span class="tok-kw">return</span> tree.fullFnProto(.{</span>
<span class="line" id="L1393">        .proto_node = node,</span>
<span class="line" id="L1394">        .fn_token = tree.nodes.items(.main_token)[node],</span>
<span class="line" id="L1395">        .return_type = data.rhs,</span>
<span class="line" id="L1396">        .params = params,</span>
<span class="line" id="L1397">        .align_expr = extra.align_expr,</span>
<span class="line" id="L1398">        .addrspace_expr = extra.addrspace_expr,</span>
<span class="line" id="L1399">        .section_expr = extra.section_expr,</span>
<span class="line" id="L1400">        .callconv_expr = extra.callconv_expr,</span>
<span class="line" id="L1401">    });</span>
<span class="line" id="L1402">}</span>
<span class="line" id="L1403"></span>
<span class="line" id="L1404"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">structInitOne</span>(tree: Ast, buffer: *[<span class="tok-number">1</span>]Node.Index, node: Node.Index) full.StructInit {</span>
<span class="line" id="L1405">    assert(tree.nodes.items(.tag)[node] == .struct_init_one <span class="tok-kw">or</span></span>
<span class="line" id="L1406">        tree.nodes.items(.tag)[node] == .struct_init_one_comma);</span>
<span class="line" id="L1407">    <span class="tok-kw">const</span> data = tree.nodes.items(.data)[node];</span>
<span class="line" id="L1408">    buffer[<span class="tok-number">0</span>] = data.rhs;</span>
<span class="line" id="L1409">    <span class="tok-kw">const</span> fields = <span class="tok-kw">if</span> (data.rhs == <span class="tok-number">0</span>) buffer[<span class="tok-number">0</span>..<span class="tok-number">0</span>] <span class="tok-kw">else</span> buffer[<span class="tok-number">0</span>..<span class="tok-number">1</span>];</span>
<span class="line" id="L1410">    <span class="tok-kw">return</span> tree.fullStructInit(.{</span>
<span class="line" id="L1411">        .lbrace = tree.nodes.items(.main_token)[node],</span>
<span class="line" id="L1412">        .fields = fields,</span>
<span class="line" id="L1413">        .type_expr = data.lhs,</span>
<span class="line" id="L1414">    });</span>
<span class="line" id="L1415">}</span>
<span class="line" id="L1416"></span>
<span class="line" id="L1417"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">structInitDotTwo</span>(tree: Ast, buffer: *[<span class="tok-number">2</span>]Node.Index, node: Node.Index) full.StructInit {</span>
<span class="line" id="L1418">    assert(tree.nodes.items(.tag)[node] == .struct_init_dot_two <span class="tok-kw">or</span></span>
<span class="line" id="L1419">        tree.nodes.items(.tag)[node] == .struct_init_dot_two_comma);</span>
<span class="line" id="L1420">    <span class="tok-kw">const</span> data = tree.nodes.items(.data)[node];</span>
<span class="line" id="L1421">    buffer.* = .{ data.lhs, data.rhs };</span>
<span class="line" id="L1422">    <span class="tok-kw">const</span> fields = <span class="tok-kw">if</span> (data.rhs != <span class="tok-number">0</span>)</span>
<span class="line" id="L1423">        buffer[<span class="tok-number">0</span>..<span class="tok-number">2</span>]</span>
<span class="line" id="L1424">    <span class="tok-kw">else</span> <span class="tok-kw">if</span> (data.lhs != <span class="tok-number">0</span>)</span>
<span class="line" id="L1425">        buffer[<span class="tok-number">0</span>..<span class="tok-number">1</span>]</span>
<span class="line" id="L1426">    <span class="tok-kw">else</span></span>
<span class="line" id="L1427">        buffer[<span class="tok-number">0</span>..<span class="tok-number">0</span>];</span>
<span class="line" id="L1428">    <span class="tok-kw">return</span> tree.fullStructInit(.{</span>
<span class="line" id="L1429">        .lbrace = tree.nodes.items(.main_token)[node],</span>
<span class="line" id="L1430">        .fields = fields,</span>
<span class="line" id="L1431">        .type_expr = <span class="tok-number">0</span>,</span>
<span class="line" id="L1432">    });</span>
<span class="line" id="L1433">}</span>
<span class="line" id="L1434"></span>
<span class="line" id="L1435"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">structInitDot</span>(tree: Ast, node: Node.Index) full.StructInit {</span>
<span class="line" id="L1436">    assert(tree.nodes.items(.tag)[node] == .struct_init_dot <span class="tok-kw">or</span></span>
<span class="line" id="L1437">        tree.nodes.items(.tag)[node] == .struct_init_dot_comma);</span>
<span class="line" id="L1438">    <span class="tok-kw">const</span> data = tree.nodes.items(.data)[node];</span>
<span class="line" id="L1439">    <span class="tok-kw">return</span> tree.fullStructInit(.{</span>
<span class="line" id="L1440">        .lbrace = tree.nodes.items(.main_token)[node],</span>
<span class="line" id="L1441">        .fields = tree.extra_data[data.lhs..data.rhs],</span>
<span class="line" id="L1442">        .type_expr = <span class="tok-number">0</span>,</span>
<span class="line" id="L1443">    });</span>
<span class="line" id="L1444">}</span>
<span class="line" id="L1445"></span>
<span class="line" id="L1446"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">structInit</span>(tree: Ast, node: Node.Index) full.StructInit {</span>
<span class="line" id="L1447">    assert(tree.nodes.items(.tag)[node] == .struct_init <span class="tok-kw">or</span></span>
<span class="line" id="L1448">        tree.nodes.items(.tag)[node] == .struct_init_comma);</span>
<span class="line" id="L1449">    <span class="tok-kw">const</span> data = tree.nodes.items(.data)[node];</span>
<span class="line" id="L1450">    <span class="tok-kw">const</span> fields_range = tree.extraData(data.rhs, Node.SubRange);</span>
<span class="line" id="L1451">    <span class="tok-kw">return</span> tree.fullStructInit(.{</span>
<span class="line" id="L1452">        .lbrace = tree.nodes.items(.main_token)[node],</span>
<span class="line" id="L1453">        .fields = tree.extra_data[fields_range.start..fields_range.end],</span>
<span class="line" id="L1454">        .type_expr = data.lhs,</span>
<span class="line" id="L1455">    });</span>
<span class="line" id="L1456">}</span>
<span class="line" id="L1457"></span>
<span class="line" id="L1458"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">arrayInitOne</span>(tree: Ast, buffer: *[<span class="tok-number">1</span>]Node.Index, node: Node.Index) full.ArrayInit {</span>
<span class="line" id="L1459">    assert(tree.nodes.items(.tag)[node] == .array_init_one <span class="tok-kw">or</span></span>
<span class="line" id="L1460">        tree.nodes.items(.tag)[node] == .array_init_one_comma);</span>
<span class="line" id="L1461">    <span class="tok-kw">const</span> data = tree.nodes.items(.data)[node];</span>
<span class="line" id="L1462">    buffer[<span class="tok-number">0</span>] = data.rhs;</span>
<span class="line" id="L1463">    <span class="tok-kw">const</span> elements = <span class="tok-kw">if</span> (data.rhs == <span class="tok-number">0</span>) buffer[<span class="tok-number">0</span>..<span class="tok-number">0</span>] <span class="tok-kw">else</span> buffer[<span class="tok-number">0</span>..<span class="tok-number">1</span>];</span>
<span class="line" id="L1464">    <span class="tok-kw">return</span> .{</span>
<span class="line" id="L1465">        .ast = .{</span>
<span class="line" id="L1466">            .lbrace = tree.nodes.items(.main_token)[node],</span>
<span class="line" id="L1467">            .elements = elements,</span>
<span class="line" id="L1468">            .type_expr = data.lhs,</span>
<span class="line" id="L1469">        },</span>
<span class="line" id="L1470">    };</span>
<span class="line" id="L1471">}</span>
<span class="line" id="L1472"></span>
<span class="line" id="L1473"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">arrayInitDotTwo</span>(tree: Ast, buffer: *[<span class="tok-number">2</span>]Node.Index, node: Node.Index) full.ArrayInit {</span>
<span class="line" id="L1474">    assert(tree.nodes.items(.tag)[node] == .array_init_dot_two <span class="tok-kw">or</span></span>
<span class="line" id="L1475">        tree.nodes.items(.tag)[node] == .array_init_dot_two_comma);</span>
<span class="line" id="L1476">    <span class="tok-kw">const</span> data = tree.nodes.items(.data)[node];</span>
<span class="line" id="L1477">    buffer.* = .{ data.lhs, data.rhs };</span>
<span class="line" id="L1478">    <span class="tok-kw">const</span> elements = <span class="tok-kw">if</span> (data.rhs != <span class="tok-number">0</span>)</span>
<span class="line" id="L1479">        buffer[<span class="tok-number">0</span>..<span class="tok-number">2</span>]</span>
<span class="line" id="L1480">    <span class="tok-kw">else</span> <span class="tok-kw">if</span> (data.lhs != <span class="tok-number">0</span>)</span>
<span class="line" id="L1481">        buffer[<span class="tok-number">0</span>..<span class="tok-number">1</span>]</span>
<span class="line" id="L1482">    <span class="tok-kw">else</span></span>
<span class="line" id="L1483">        buffer[<span class="tok-number">0</span>..<span class="tok-number">0</span>];</span>
<span class="line" id="L1484">    <span class="tok-kw">return</span> .{</span>
<span class="line" id="L1485">        .ast = .{</span>
<span class="line" id="L1486">            .lbrace = tree.nodes.items(.main_token)[node],</span>
<span class="line" id="L1487">            .elements = elements,</span>
<span class="line" id="L1488">            .type_expr = <span class="tok-number">0</span>,</span>
<span class="line" id="L1489">        },</span>
<span class="line" id="L1490">    };</span>
<span class="line" id="L1491">}</span>
<span class="line" id="L1492"></span>
<span class="line" id="L1493"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">arrayInitDot</span>(tree: Ast, node: Node.Index) full.ArrayInit {</span>
<span class="line" id="L1494">    assert(tree.nodes.items(.tag)[node] == .array_init_dot <span class="tok-kw">or</span></span>
<span class="line" id="L1495">        tree.nodes.items(.tag)[node] == .array_init_dot_comma);</span>
<span class="line" id="L1496">    <span class="tok-kw">const</span> data = tree.nodes.items(.data)[node];</span>
<span class="line" id="L1497">    <span class="tok-kw">return</span> .{</span>
<span class="line" id="L1498">        .ast = .{</span>
<span class="line" id="L1499">            .lbrace = tree.nodes.items(.main_token)[node],</span>
<span class="line" id="L1500">            .elements = tree.extra_data[data.lhs..data.rhs],</span>
<span class="line" id="L1501">            .type_expr = <span class="tok-number">0</span>,</span>
<span class="line" id="L1502">        },</span>
<span class="line" id="L1503">    };</span>
<span class="line" id="L1504">}</span>
<span class="line" id="L1505"></span>
<span class="line" id="L1506"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">arrayInit</span>(tree: Ast, node: Node.Index) full.ArrayInit {</span>
<span class="line" id="L1507">    assert(tree.nodes.items(.tag)[node] == .array_init <span class="tok-kw">or</span></span>
<span class="line" id="L1508">        tree.nodes.items(.tag)[node] == .array_init_comma);</span>
<span class="line" id="L1509">    <span class="tok-kw">const</span> data = tree.nodes.items(.data)[node];</span>
<span class="line" id="L1510">    <span class="tok-kw">const</span> elem_range = tree.extraData(data.rhs, Node.SubRange);</span>
<span class="line" id="L1511">    <span class="tok-kw">return</span> .{</span>
<span class="line" id="L1512">        .ast = .{</span>
<span class="line" id="L1513">            .lbrace = tree.nodes.items(.main_token)[node],</span>
<span class="line" id="L1514">            .elements = tree.extra_data[elem_range.start..elem_range.end],</span>
<span class="line" id="L1515">            .type_expr = data.lhs,</span>
<span class="line" id="L1516">        },</span>
<span class="line" id="L1517">    };</span>
<span class="line" id="L1518">}</span>
<span class="line" id="L1519"></span>
<span class="line" id="L1520"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">arrayType</span>(tree: Ast, node: Node.Index) full.ArrayType {</span>
<span class="line" id="L1521">    assert(tree.nodes.items(.tag)[node] == .array_type);</span>
<span class="line" id="L1522">    <span class="tok-kw">const</span> data = tree.nodes.items(.data)[node];</span>
<span class="line" id="L1523">    <span class="tok-kw">return</span> .{</span>
<span class="line" id="L1524">        .ast = .{</span>
<span class="line" id="L1525">            .lbracket = tree.nodes.items(.main_token)[node],</span>
<span class="line" id="L1526">            .elem_count = data.lhs,</span>
<span class="line" id="L1527">            .sentinel = <span class="tok-number">0</span>,</span>
<span class="line" id="L1528">            .elem_type = data.rhs,</span>
<span class="line" id="L1529">        },</span>
<span class="line" id="L1530">    };</span>
<span class="line" id="L1531">}</span>
<span class="line" id="L1532"></span>
<span class="line" id="L1533"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">arrayTypeSentinel</span>(tree: Ast, node: Node.Index) full.ArrayType {</span>
<span class="line" id="L1534">    assert(tree.nodes.items(.tag)[node] == .array_type_sentinel);</span>
<span class="line" id="L1535">    <span class="tok-kw">const</span> data = tree.nodes.items(.data)[node];</span>
<span class="line" id="L1536">    <span class="tok-kw">const</span> extra = tree.extraData(data.rhs, Node.ArrayTypeSentinel);</span>
<span class="line" id="L1537">    assert(extra.sentinel != <span class="tok-number">0</span>);</span>
<span class="line" id="L1538">    <span class="tok-kw">return</span> .{</span>
<span class="line" id="L1539">        .ast = .{</span>
<span class="line" id="L1540">            .lbracket = tree.nodes.items(.main_token)[node],</span>
<span class="line" id="L1541">            .elem_count = data.lhs,</span>
<span class="line" id="L1542">            .sentinel = extra.sentinel,</span>
<span class="line" id="L1543">            .elem_type = extra.elem_type,</span>
<span class="line" id="L1544">        },</span>
<span class="line" id="L1545">    };</span>
<span class="line" id="L1546">}</span>
<span class="line" id="L1547"></span>
<span class="line" id="L1548"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">ptrTypeAligned</span>(tree: Ast, node: Node.Index) full.PtrType {</span>
<span class="line" id="L1549">    assert(tree.nodes.items(.tag)[node] == .ptr_type_aligned);</span>
<span class="line" id="L1550">    <span class="tok-kw">const</span> data = tree.nodes.items(.data)[node];</span>
<span class="line" id="L1551">    <span class="tok-kw">return</span> tree.fullPtrType(.{</span>
<span class="line" id="L1552">        .main_token = tree.nodes.items(.main_token)[node],</span>
<span class="line" id="L1553">        .align_node = data.lhs,</span>
<span class="line" id="L1554">        .addrspace_node = <span class="tok-number">0</span>,</span>
<span class="line" id="L1555">        .sentinel = <span class="tok-number">0</span>,</span>
<span class="line" id="L1556">        .bit_range_start = <span class="tok-number">0</span>,</span>
<span class="line" id="L1557">        .bit_range_end = <span class="tok-number">0</span>,</span>
<span class="line" id="L1558">        .child_type = data.rhs,</span>
<span class="line" id="L1559">    });</span>
<span class="line" id="L1560">}</span>
<span class="line" id="L1561"></span>
<span class="line" id="L1562"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">ptrTypeSentinel</span>(tree: Ast, node: Node.Index) full.PtrType {</span>
<span class="line" id="L1563">    assert(tree.nodes.items(.tag)[node] == .ptr_type_sentinel);</span>
<span class="line" id="L1564">    <span class="tok-kw">const</span> data = tree.nodes.items(.data)[node];</span>
<span class="line" id="L1565">    <span class="tok-kw">return</span> tree.fullPtrType(.{</span>
<span class="line" id="L1566">        .main_token = tree.nodes.items(.main_token)[node],</span>
<span class="line" id="L1567">        .align_node = <span class="tok-number">0</span>,</span>
<span class="line" id="L1568">        .addrspace_node = <span class="tok-number">0</span>,</span>
<span class="line" id="L1569">        .sentinel = data.lhs,</span>
<span class="line" id="L1570">        .bit_range_start = <span class="tok-number">0</span>,</span>
<span class="line" id="L1571">        .bit_range_end = <span class="tok-number">0</span>,</span>
<span class="line" id="L1572">        .child_type = data.rhs,</span>
<span class="line" id="L1573">    });</span>
<span class="line" id="L1574">}</span>
<span class="line" id="L1575"></span>
<span class="line" id="L1576"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">ptrType</span>(tree: Ast, node: Node.Index) full.PtrType {</span>
<span class="line" id="L1577">    assert(tree.nodes.items(.tag)[node] == .ptr_type);</span>
<span class="line" id="L1578">    <span class="tok-kw">const</span> data = tree.nodes.items(.data)[node];</span>
<span class="line" id="L1579">    <span class="tok-kw">const</span> extra = tree.extraData(data.lhs, Node.PtrType);</span>
<span class="line" id="L1580">    <span class="tok-kw">return</span> tree.fullPtrType(.{</span>
<span class="line" id="L1581">        .main_token = tree.nodes.items(.main_token)[node],</span>
<span class="line" id="L1582">        .align_node = extra.align_node,</span>
<span class="line" id="L1583">        .addrspace_node = extra.addrspace_node,</span>
<span class="line" id="L1584">        .sentinel = extra.sentinel,</span>
<span class="line" id="L1585">        .bit_range_start = <span class="tok-number">0</span>,</span>
<span class="line" id="L1586">        .bit_range_end = <span class="tok-number">0</span>,</span>
<span class="line" id="L1587">        .child_type = data.rhs,</span>
<span class="line" id="L1588">    });</span>
<span class="line" id="L1589">}</span>
<span class="line" id="L1590"></span>
<span class="line" id="L1591"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">ptrTypeBitRange</span>(tree: Ast, node: Node.Index) full.PtrType {</span>
<span class="line" id="L1592">    assert(tree.nodes.items(.tag)[node] == .ptr_type_bit_range);</span>
<span class="line" id="L1593">    <span class="tok-kw">const</span> data = tree.nodes.items(.data)[node];</span>
<span class="line" id="L1594">    <span class="tok-kw">const</span> extra = tree.extraData(data.lhs, Node.PtrTypeBitRange);</span>
<span class="line" id="L1595">    <span class="tok-kw">return</span> tree.fullPtrType(.{</span>
<span class="line" id="L1596">        .main_token = tree.nodes.items(.main_token)[node],</span>
<span class="line" id="L1597">        .align_node = extra.align_node,</span>
<span class="line" id="L1598">        .addrspace_node = extra.addrspace_node,</span>
<span class="line" id="L1599">        .sentinel = extra.sentinel,</span>
<span class="line" id="L1600">        .bit_range_start = extra.bit_range_start,</span>
<span class="line" id="L1601">        .bit_range_end = extra.bit_range_end,</span>
<span class="line" id="L1602">        .child_type = data.rhs,</span>
<span class="line" id="L1603">    });</span>
<span class="line" id="L1604">}</span>
<span class="line" id="L1605"></span>
<span class="line" id="L1606"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">sliceOpen</span>(tree: Ast, node: Node.Index) full.Slice {</span>
<span class="line" id="L1607">    assert(tree.nodes.items(.tag)[node] == .slice_open);</span>
<span class="line" id="L1608">    <span class="tok-kw">const</span> data = tree.nodes.items(.data)[node];</span>
<span class="line" id="L1609">    <span class="tok-kw">return</span> .{</span>
<span class="line" id="L1610">        .ast = .{</span>
<span class="line" id="L1611">            .sliced = data.lhs,</span>
<span class="line" id="L1612">            .lbracket = tree.nodes.items(.main_token)[node],</span>
<span class="line" id="L1613">            .start = data.rhs,</span>
<span class="line" id="L1614">            .end = <span class="tok-number">0</span>,</span>
<span class="line" id="L1615">            .sentinel = <span class="tok-number">0</span>,</span>
<span class="line" id="L1616">        },</span>
<span class="line" id="L1617">    };</span>
<span class="line" id="L1618">}</span>
<span class="line" id="L1619"></span>
<span class="line" id="L1620"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">slice</span>(tree: Ast, node: Node.Index) full.Slice {</span>
<span class="line" id="L1621">    assert(tree.nodes.items(.tag)[node] == .slice);</span>
<span class="line" id="L1622">    <span class="tok-kw">const</span> data = tree.nodes.items(.data)[node];</span>
<span class="line" id="L1623">    <span class="tok-kw">const</span> extra = tree.extraData(data.rhs, Node.Slice);</span>
<span class="line" id="L1624">    <span class="tok-kw">return</span> .{</span>
<span class="line" id="L1625">        .ast = .{</span>
<span class="line" id="L1626">            .sliced = data.lhs,</span>
<span class="line" id="L1627">            .lbracket = tree.nodes.items(.main_token)[node],</span>
<span class="line" id="L1628">            .start = extra.start,</span>
<span class="line" id="L1629">            .end = extra.end,</span>
<span class="line" id="L1630">            .sentinel = <span class="tok-number">0</span>,</span>
<span class="line" id="L1631">        },</span>
<span class="line" id="L1632">    };</span>
<span class="line" id="L1633">}</span>
<span class="line" id="L1634"></span>
<span class="line" id="L1635"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">sliceSentinel</span>(tree: Ast, node: Node.Index) full.Slice {</span>
<span class="line" id="L1636">    assert(tree.nodes.items(.tag)[node] == .slice_sentinel);</span>
<span class="line" id="L1637">    <span class="tok-kw">const</span> data = tree.nodes.items(.data)[node];</span>
<span class="line" id="L1638">    <span class="tok-kw">const</span> extra = tree.extraData(data.rhs, Node.SliceSentinel);</span>
<span class="line" id="L1639">    <span class="tok-kw">return</span> .{</span>
<span class="line" id="L1640">        .ast = .{</span>
<span class="line" id="L1641">            .sliced = data.lhs,</span>
<span class="line" id="L1642">            .lbracket = tree.nodes.items(.main_token)[node],</span>
<span class="line" id="L1643">            .start = extra.start,</span>
<span class="line" id="L1644">            .end = extra.end,</span>
<span class="line" id="L1645">            .sentinel = extra.sentinel,</span>
<span class="line" id="L1646">        },</span>
<span class="line" id="L1647">    };</span>
<span class="line" id="L1648">}</span>
<span class="line" id="L1649"></span>
<span class="line" id="L1650"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">containerDeclTwo</span>(tree: Ast, buffer: *[<span class="tok-number">2</span>]Node.Index, node: Node.Index) full.ContainerDecl {</span>
<span class="line" id="L1651">    assert(tree.nodes.items(.tag)[node] == .container_decl_two <span class="tok-kw">or</span></span>
<span class="line" id="L1652">        tree.nodes.items(.tag)[node] == .container_decl_two_trailing);</span>
<span class="line" id="L1653">    <span class="tok-kw">const</span> data = tree.nodes.items(.data)[node];</span>
<span class="line" id="L1654">    buffer.* = .{ data.lhs, data.rhs };</span>
<span class="line" id="L1655">    <span class="tok-kw">const</span> members = <span class="tok-kw">if</span> (data.rhs != <span class="tok-number">0</span>)</span>
<span class="line" id="L1656">        buffer[<span class="tok-number">0</span>..<span class="tok-number">2</span>]</span>
<span class="line" id="L1657">    <span class="tok-kw">else</span> <span class="tok-kw">if</span> (data.lhs != <span class="tok-number">0</span>)</span>
<span class="line" id="L1658">        buffer[<span class="tok-number">0</span>..<span class="tok-number">1</span>]</span>
<span class="line" id="L1659">    <span class="tok-kw">else</span></span>
<span class="line" id="L1660">        buffer[<span class="tok-number">0</span>..<span class="tok-number">0</span>];</span>
<span class="line" id="L1661">    <span class="tok-kw">return</span> tree.fullContainerDecl(.{</span>
<span class="line" id="L1662">        .main_token = tree.nodes.items(.main_token)[node],</span>
<span class="line" id="L1663">        .enum_token = <span class="tok-null">null</span>,</span>
<span class="line" id="L1664">        .members = members,</span>
<span class="line" id="L1665">        .arg = <span class="tok-number">0</span>,</span>
<span class="line" id="L1666">    });</span>
<span class="line" id="L1667">}</span>
<span class="line" id="L1668"></span>
<span class="line" id="L1669"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">containerDecl</span>(tree: Ast, node: Node.Index) full.ContainerDecl {</span>
<span class="line" id="L1670">    assert(tree.nodes.items(.tag)[node] == .container_decl <span class="tok-kw">or</span></span>
<span class="line" id="L1671">        tree.nodes.items(.tag)[node] == .container_decl_trailing);</span>
<span class="line" id="L1672">    <span class="tok-kw">const</span> data = tree.nodes.items(.data)[node];</span>
<span class="line" id="L1673">    <span class="tok-kw">return</span> tree.fullContainerDecl(.{</span>
<span class="line" id="L1674">        .main_token = tree.nodes.items(.main_token)[node],</span>
<span class="line" id="L1675">        .enum_token = <span class="tok-null">null</span>,</span>
<span class="line" id="L1676">        .members = tree.extra_data[data.lhs..data.rhs],</span>
<span class="line" id="L1677">        .arg = <span class="tok-number">0</span>,</span>
<span class="line" id="L1678">    });</span>
<span class="line" id="L1679">}</span>
<span class="line" id="L1680"></span>
<span class="line" id="L1681"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">containerDeclArg</span>(tree: Ast, node: Node.Index) full.ContainerDecl {</span>
<span class="line" id="L1682">    assert(tree.nodes.items(.tag)[node] == .container_decl_arg <span class="tok-kw">or</span></span>
<span class="line" id="L1683">        tree.nodes.items(.tag)[node] == .container_decl_arg_trailing);</span>
<span class="line" id="L1684">    <span class="tok-kw">const</span> data = tree.nodes.items(.data)[node];</span>
<span class="line" id="L1685">    <span class="tok-kw">const</span> members_range = tree.extraData(data.rhs, Node.SubRange);</span>
<span class="line" id="L1686">    <span class="tok-kw">return</span> tree.fullContainerDecl(.{</span>
<span class="line" id="L1687">        .main_token = tree.nodes.items(.main_token)[node],</span>
<span class="line" id="L1688">        .enum_token = <span class="tok-null">null</span>,</span>
<span class="line" id="L1689">        .members = tree.extra_data[members_range.start..members_range.end],</span>
<span class="line" id="L1690">        .arg = data.lhs,</span>
<span class="line" id="L1691">    });</span>
<span class="line" id="L1692">}</span>
<span class="line" id="L1693"></span>
<span class="line" id="L1694"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">containerDeclRoot</span>(tree: Ast) full.ContainerDecl {</span>
<span class="line" id="L1695">    <span class="tok-kw">return</span> .{</span>
<span class="line" id="L1696">        .layout_token = <span class="tok-null">null</span>,</span>
<span class="line" id="L1697">        .ast = .{</span>
<span class="line" id="L1698">            .main_token = <span class="tok-null">undefined</span>,</span>
<span class="line" id="L1699">            .enum_token = <span class="tok-null">null</span>,</span>
<span class="line" id="L1700">            .members = tree.rootDecls(),</span>
<span class="line" id="L1701">            .arg = <span class="tok-number">0</span>,</span>
<span class="line" id="L1702">        },</span>
<span class="line" id="L1703">    };</span>
<span class="line" id="L1704">}</span>
<span class="line" id="L1705"></span>
<span class="line" id="L1706"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">taggedUnionTwo</span>(tree: Ast, buffer: *[<span class="tok-number">2</span>]Node.Index, node: Node.Index) full.ContainerDecl {</span>
<span class="line" id="L1707">    assert(tree.nodes.items(.tag)[node] == .tagged_union_two <span class="tok-kw">or</span></span>
<span class="line" id="L1708">        tree.nodes.items(.tag)[node] == .tagged_union_two_trailing);</span>
<span class="line" id="L1709">    <span class="tok-kw">const</span> data = tree.nodes.items(.data)[node];</span>
<span class="line" id="L1710">    buffer.* = .{ data.lhs, data.rhs };</span>
<span class="line" id="L1711">    <span class="tok-kw">const</span> members = <span class="tok-kw">if</span> (data.rhs != <span class="tok-number">0</span>)</span>
<span class="line" id="L1712">        buffer[<span class="tok-number">0</span>..<span class="tok-number">2</span>]</span>
<span class="line" id="L1713">    <span class="tok-kw">else</span> <span class="tok-kw">if</span> (data.lhs != <span class="tok-number">0</span>)</span>
<span class="line" id="L1714">        buffer[<span class="tok-number">0</span>..<span class="tok-number">1</span>]</span>
<span class="line" id="L1715">    <span class="tok-kw">else</span></span>
<span class="line" id="L1716">        buffer[<span class="tok-number">0</span>..<span class="tok-number">0</span>];</span>
<span class="line" id="L1717">    <span class="tok-kw">const</span> main_token = tree.nodes.items(.main_token)[node];</span>
<span class="line" id="L1718">    <span class="tok-kw">return</span> tree.fullContainerDecl(.{</span>
<span class="line" id="L1719">        .main_token = main_token,</span>
<span class="line" id="L1720">        .enum_token = main_token + <span class="tok-number">2</span>, <span class="tok-comment">// union lparen enum</span>
</span>
<span class="line" id="L1721">        .members = members,</span>
<span class="line" id="L1722">        .arg = <span class="tok-number">0</span>,</span>
<span class="line" id="L1723">    });</span>
<span class="line" id="L1724">}</span>
<span class="line" id="L1725"></span>
<span class="line" id="L1726"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">taggedUnion</span>(tree: Ast, node: Node.Index) full.ContainerDecl {</span>
<span class="line" id="L1727">    assert(tree.nodes.items(.tag)[node] == .tagged_union <span class="tok-kw">or</span></span>
<span class="line" id="L1728">        tree.nodes.items(.tag)[node] == .tagged_union_trailing);</span>
<span class="line" id="L1729">    <span class="tok-kw">const</span> data = tree.nodes.items(.data)[node];</span>
<span class="line" id="L1730">    <span class="tok-kw">const</span> main_token = tree.nodes.items(.main_token)[node];</span>
<span class="line" id="L1731">    <span class="tok-kw">return</span> tree.fullContainerDecl(.{</span>
<span class="line" id="L1732">        .main_token = main_token,</span>
<span class="line" id="L1733">        .enum_token = main_token + <span class="tok-number">2</span>, <span class="tok-comment">// union lparen enum</span>
</span>
<span class="line" id="L1734">        .members = tree.extra_data[data.lhs..data.rhs],</span>
<span class="line" id="L1735">        .arg = <span class="tok-number">0</span>,</span>
<span class="line" id="L1736">    });</span>
<span class="line" id="L1737">}</span>
<span class="line" id="L1738"></span>
<span class="line" id="L1739"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">taggedUnionEnumTag</span>(tree: Ast, node: Node.Index) full.ContainerDecl {</span>
<span class="line" id="L1740">    assert(tree.nodes.items(.tag)[node] == .tagged_union_enum_tag <span class="tok-kw">or</span></span>
<span class="line" id="L1741">        tree.nodes.items(.tag)[node] == .tagged_union_enum_tag_trailing);</span>
<span class="line" id="L1742">    <span class="tok-kw">const</span> data = tree.nodes.items(.data)[node];</span>
<span class="line" id="L1743">    <span class="tok-kw">const</span> members_range = tree.extraData(data.rhs, Node.SubRange);</span>
<span class="line" id="L1744">    <span class="tok-kw">const</span> main_token = tree.nodes.items(.main_token)[node];</span>
<span class="line" id="L1745">    <span class="tok-kw">return</span> tree.fullContainerDecl(.{</span>
<span class="line" id="L1746">        .main_token = main_token,</span>
<span class="line" id="L1747">        .enum_token = main_token + <span class="tok-number">2</span>, <span class="tok-comment">// union lparen enum</span>
</span>
<span class="line" id="L1748">        .members = tree.extra_data[members_range.start..members_range.end],</span>
<span class="line" id="L1749">        .arg = data.lhs,</span>
<span class="line" id="L1750">    });</span>
<span class="line" id="L1751">}</span>
<span class="line" id="L1752"></span>
<span class="line" id="L1753"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">switchCaseOne</span>(tree: Ast, node: Node.Index) full.SwitchCase {</span>
<span class="line" id="L1754">    <span class="tok-kw">const</span> data = &amp;tree.nodes.items(.data)[node];</span>
<span class="line" id="L1755">    <span class="tok-kw">const</span> values: *[<span class="tok-number">1</span>]Node.Index = &amp;data.lhs;</span>
<span class="line" id="L1756">    <span class="tok-kw">return</span> tree.fullSwitchCase(.{</span>
<span class="line" id="L1757">        .values = <span class="tok-kw">if</span> (data.lhs == <span class="tok-number">0</span>) values[<span class="tok-number">0</span>..<span class="tok-number">0</span>] <span class="tok-kw">else</span> values[<span class="tok-number">0</span>..<span class="tok-number">1</span>],</span>
<span class="line" id="L1758">        .arrow_token = tree.nodes.items(.main_token)[node],</span>
<span class="line" id="L1759">        .target_expr = data.rhs,</span>
<span class="line" id="L1760">    });</span>
<span class="line" id="L1761">}</span>
<span class="line" id="L1762"></span>
<span class="line" id="L1763"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">switchCase</span>(tree: Ast, node: Node.Index) full.SwitchCase {</span>
<span class="line" id="L1764">    <span class="tok-kw">const</span> data = tree.nodes.items(.data)[node];</span>
<span class="line" id="L1765">    <span class="tok-kw">const</span> extra = tree.extraData(data.lhs, Node.SubRange);</span>
<span class="line" id="L1766">    <span class="tok-kw">return</span> tree.fullSwitchCase(.{</span>
<span class="line" id="L1767">        .values = tree.extra_data[extra.start..extra.end],</span>
<span class="line" id="L1768">        .arrow_token = tree.nodes.items(.main_token)[node],</span>
<span class="line" id="L1769">        .target_expr = data.rhs,</span>
<span class="line" id="L1770">    });</span>
<span class="line" id="L1771">}</span>
<span class="line" id="L1772"></span>
<span class="line" id="L1773"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">asmSimple</span>(tree: Ast, node: Node.Index) full.Asm {</span>
<span class="line" id="L1774">    <span class="tok-kw">const</span> data = tree.nodes.items(.data)[node];</span>
<span class="line" id="L1775">    <span class="tok-kw">return</span> tree.fullAsm(.{</span>
<span class="line" id="L1776">        .asm_token = tree.nodes.items(.main_token)[node],</span>
<span class="line" id="L1777">        .template = data.lhs,</span>
<span class="line" id="L1778">        .items = &amp;.{},</span>
<span class="line" id="L1779">        .rparen = data.rhs,</span>
<span class="line" id="L1780">    });</span>
<span class="line" id="L1781">}</span>
<span class="line" id="L1782"></span>
<span class="line" id="L1783"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">asmFull</span>(tree: Ast, node: Node.Index) full.Asm {</span>
<span class="line" id="L1784">    <span class="tok-kw">const</span> data = tree.nodes.items(.data)[node];</span>
<span class="line" id="L1785">    <span class="tok-kw">const</span> extra = tree.extraData(data.rhs, Node.Asm);</span>
<span class="line" id="L1786">    <span class="tok-kw">return</span> tree.fullAsm(.{</span>
<span class="line" id="L1787">        .asm_token = tree.nodes.items(.main_token)[node],</span>
<span class="line" id="L1788">        .template = data.lhs,</span>
<span class="line" id="L1789">        .items = tree.extra_data[extra.items_start..extra.items_end],</span>
<span class="line" id="L1790">        .rparen = extra.rparen,</span>
<span class="line" id="L1791">    });</span>
<span class="line" id="L1792">}</span>
<span class="line" id="L1793"></span>
<span class="line" id="L1794"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">whileSimple</span>(tree: Ast, node: Node.Index) full.While {</span>
<span class="line" id="L1795">    <span class="tok-kw">const</span> data = tree.nodes.items(.data)[node];</span>
<span class="line" id="L1796">    <span class="tok-kw">return</span> tree.fullWhile(.{</span>
<span class="line" id="L1797">        .while_token = tree.nodes.items(.main_token)[node],</span>
<span class="line" id="L1798">        .cond_expr = data.lhs,</span>
<span class="line" id="L1799">        .cont_expr = <span class="tok-number">0</span>,</span>
<span class="line" id="L1800">        .then_expr = data.rhs,</span>
<span class="line" id="L1801">        .else_expr = <span class="tok-number">0</span>,</span>
<span class="line" id="L1802">    });</span>
<span class="line" id="L1803">}</span>
<span class="line" id="L1804"></span>
<span class="line" id="L1805"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">whileCont</span>(tree: Ast, node: Node.Index) full.While {</span>
<span class="line" id="L1806">    <span class="tok-kw">const</span> data = tree.nodes.items(.data)[node];</span>
<span class="line" id="L1807">    <span class="tok-kw">const</span> extra = tree.extraData(data.rhs, Node.WhileCont);</span>
<span class="line" id="L1808">    <span class="tok-kw">return</span> tree.fullWhile(.{</span>
<span class="line" id="L1809">        .while_token = tree.nodes.items(.main_token)[node],</span>
<span class="line" id="L1810">        .cond_expr = data.lhs,</span>
<span class="line" id="L1811">        .cont_expr = extra.cont_expr,</span>
<span class="line" id="L1812">        .then_expr = extra.then_expr,</span>
<span class="line" id="L1813">        .else_expr = <span class="tok-number">0</span>,</span>
<span class="line" id="L1814">    });</span>
<span class="line" id="L1815">}</span>
<span class="line" id="L1816"></span>
<span class="line" id="L1817"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">whileFull</span>(tree: Ast, node: Node.Index) full.While {</span>
<span class="line" id="L1818">    <span class="tok-kw">const</span> data = tree.nodes.items(.data)[node];</span>
<span class="line" id="L1819">    <span class="tok-kw">const</span> extra = tree.extraData(data.rhs, Node.While);</span>
<span class="line" id="L1820">    <span class="tok-kw">return</span> tree.fullWhile(.{</span>
<span class="line" id="L1821">        .while_token = tree.nodes.items(.main_token)[node],</span>
<span class="line" id="L1822">        .cond_expr = data.lhs,</span>
<span class="line" id="L1823">        .cont_expr = extra.cont_expr,</span>
<span class="line" id="L1824">        .then_expr = extra.then_expr,</span>
<span class="line" id="L1825">        .else_expr = extra.else_expr,</span>
<span class="line" id="L1826">    });</span>
<span class="line" id="L1827">}</span>
<span class="line" id="L1828"></span>
<span class="line" id="L1829"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">forSimple</span>(tree: Ast, node: Node.Index) full.While {</span>
<span class="line" id="L1830">    <span class="tok-kw">const</span> data = tree.nodes.items(.data)[node];</span>
<span class="line" id="L1831">    <span class="tok-kw">return</span> tree.fullWhile(.{</span>
<span class="line" id="L1832">        .while_token = tree.nodes.items(.main_token)[node],</span>
<span class="line" id="L1833">        .cond_expr = data.lhs,</span>
<span class="line" id="L1834">        .cont_expr = <span class="tok-number">0</span>,</span>
<span class="line" id="L1835">        .then_expr = data.rhs,</span>
<span class="line" id="L1836">        .else_expr = <span class="tok-number">0</span>,</span>
<span class="line" id="L1837">    });</span>
<span class="line" id="L1838">}</span>
<span class="line" id="L1839"></span>
<span class="line" id="L1840"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">forFull</span>(tree: Ast, node: Node.Index) full.While {</span>
<span class="line" id="L1841">    <span class="tok-kw">const</span> data = tree.nodes.items(.data)[node];</span>
<span class="line" id="L1842">    <span class="tok-kw">const</span> extra = tree.extraData(data.rhs, Node.If);</span>
<span class="line" id="L1843">    <span class="tok-kw">return</span> tree.fullWhile(.{</span>
<span class="line" id="L1844">        .while_token = tree.nodes.items(.main_token)[node],</span>
<span class="line" id="L1845">        .cond_expr = data.lhs,</span>
<span class="line" id="L1846">        .cont_expr = <span class="tok-number">0</span>,</span>
<span class="line" id="L1847">        .then_expr = extra.then_expr,</span>
<span class="line" id="L1848">        .else_expr = extra.else_expr,</span>
<span class="line" id="L1849">    });</span>
<span class="line" id="L1850">}</span>
<span class="line" id="L1851"></span>
<span class="line" id="L1852"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">callOne</span>(tree: Ast, buffer: *[<span class="tok-number">1</span>]Node.Index, node: Node.Index) full.Call {</span>
<span class="line" id="L1853">    <span class="tok-kw">const</span> data = tree.nodes.items(.data)[node];</span>
<span class="line" id="L1854">    buffer.* = .{data.rhs};</span>
<span class="line" id="L1855">    <span class="tok-kw">const</span> params = <span class="tok-kw">if</span> (data.rhs != <span class="tok-number">0</span>) buffer[<span class="tok-number">0</span>..<span class="tok-number">1</span>] <span class="tok-kw">else</span> buffer[<span class="tok-number">0</span>..<span class="tok-number">0</span>];</span>
<span class="line" id="L1856">    <span class="tok-kw">return</span> tree.fullCall(.{</span>
<span class="line" id="L1857">        .lparen = tree.nodes.items(.main_token)[node],</span>
<span class="line" id="L1858">        .fn_expr = data.lhs,</span>
<span class="line" id="L1859">        .params = params,</span>
<span class="line" id="L1860">    });</span>
<span class="line" id="L1861">}</span>
<span class="line" id="L1862"></span>
<span class="line" id="L1863"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">callFull</span>(tree: Ast, node: Node.Index) full.Call {</span>
<span class="line" id="L1864">    <span class="tok-kw">const</span> data = tree.nodes.items(.data)[node];</span>
<span class="line" id="L1865">    <span class="tok-kw">const</span> extra = tree.extraData(data.rhs, Node.SubRange);</span>
<span class="line" id="L1866">    <span class="tok-kw">return</span> tree.fullCall(.{</span>
<span class="line" id="L1867">        .lparen = tree.nodes.items(.main_token)[node],</span>
<span class="line" id="L1868">        .fn_expr = data.lhs,</span>
<span class="line" id="L1869">        .params = tree.extra_data[extra.start..extra.end],</span>
<span class="line" id="L1870">    });</span>
<span class="line" id="L1871">}</span>
<span class="line" id="L1872"></span>
<span class="line" id="L1873"><span class="tok-kw">fn</span> <span class="tok-fn">fullVarDecl</span>(tree: Ast, info: full.VarDecl.Components) full.VarDecl {</span>
<span class="line" id="L1874">    <span class="tok-kw">const</span> token_tags = tree.tokens.items(.tag);</span>
<span class="line" id="L1875">    <span class="tok-kw">var</span> result: full.VarDecl = .{</span>
<span class="line" id="L1876">        .ast = info,</span>
<span class="line" id="L1877">        .visib_token = <span class="tok-null">null</span>,</span>
<span class="line" id="L1878">        .extern_export_token = <span class="tok-null">null</span>,</span>
<span class="line" id="L1879">        .lib_name = <span class="tok-null">null</span>,</span>
<span class="line" id="L1880">        .threadlocal_token = <span class="tok-null">null</span>,</span>
<span class="line" id="L1881">        .comptime_token = <span class="tok-null">null</span>,</span>
<span class="line" id="L1882">    };</span>
<span class="line" id="L1883">    <span class="tok-kw">var</span> i = info.mut_token;</span>
<span class="line" id="L1884">    <span class="tok-kw">while</span> (i &gt; <span class="tok-number">0</span>) {</span>
<span class="line" id="L1885">        i -= <span class="tok-number">1</span>;</span>
<span class="line" id="L1886">        <span class="tok-kw">switch</span> (token_tags[i]) {</span>
<span class="line" id="L1887">            .keyword_extern, .keyword_export =&gt; result.extern_export_token = i,</span>
<span class="line" id="L1888">            .keyword_comptime =&gt; result.comptime_token = i,</span>
<span class="line" id="L1889">            .keyword_pub =&gt; result.visib_token = i,</span>
<span class="line" id="L1890">            .keyword_threadlocal =&gt; result.threadlocal_token = i,</span>
<span class="line" id="L1891">            .string_literal =&gt; result.lib_name = i,</span>
<span class="line" id="L1892">            <span class="tok-kw">else</span> =&gt; <span class="tok-kw">break</span>,</span>
<span class="line" id="L1893">        }</span>
<span class="line" id="L1894">    }</span>
<span class="line" id="L1895">    <span class="tok-kw">return</span> result;</span>
<span class="line" id="L1896">}</span>
<span class="line" id="L1897"></span>
<span class="line" id="L1898"><span class="tok-kw">fn</span> <span class="tok-fn">fullIf</span>(tree: Ast, info: full.If.Components) full.If {</span>
<span class="line" id="L1899">    <span class="tok-kw">const</span> token_tags = tree.tokens.items(.tag);</span>
<span class="line" id="L1900">    <span class="tok-kw">var</span> result: full.If = .{</span>
<span class="line" id="L1901">        .ast = info,</span>
<span class="line" id="L1902">        .payload_token = <span class="tok-null">null</span>,</span>
<span class="line" id="L1903">        .error_token = <span class="tok-null">null</span>,</span>
<span class="line" id="L1904">        .else_token = <span class="tok-null">undefined</span>,</span>
<span class="line" id="L1905">    };</span>
<span class="line" id="L1906">    <span class="tok-comment">// if (cond_expr) |x|</span>
</span>
<span class="line" id="L1907">    <span class="tok-comment">//              ^ ^</span>
</span>
<span class="line" id="L1908">    <span class="tok-kw">const</span> payload_pipe = tree.lastToken(info.cond_expr) + <span class="tok-number">2</span>;</span>
<span class="line" id="L1909">    <span class="tok-kw">if</span> (token_tags[payload_pipe] == .pipe) {</span>
<span class="line" id="L1910">        result.payload_token = payload_pipe + <span class="tok-number">1</span>;</span>
<span class="line" id="L1911">    }</span>
<span class="line" id="L1912">    <span class="tok-kw">if</span> (info.else_expr != <span class="tok-number">0</span>) {</span>
<span class="line" id="L1913">        <span class="tok-comment">// then_expr else |x|</span>
</span>
<span class="line" id="L1914">        <span class="tok-comment">//           ^    ^</span>
</span>
<span class="line" id="L1915">        result.else_token = tree.lastToken(info.then_expr) + <span class="tok-number">1</span>;</span>
<span class="line" id="L1916">        <span class="tok-kw">if</span> (token_tags[result.else_token + <span class="tok-number">1</span>] == .pipe) {</span>
<span class="line" id="L1917">            result.error_token = result.else_token + <span class="tok-number">2</span>;</span>
<span class="line" id="L1918">        }</span>
<span class="line" id="L1919">    }</span>
<span class="line" id="L1920">    <span class="tok-kw">return</span> result;</span>
<span class="line" id="L1921">}</span>
<span class="line" id="L1922"></span>
<span class="line" id="L1923"><span class="tok-kw">fn</span> <span class="tok-fn">fullContainerField</span>(tree: Ast, info: full.ContainerField.Components) full.ContainerField {</span>
<span class="line" id="L1924">    <span class="tok-kw">const</span> token_tags = tree.tokens.items(.tag);</span>
<span class="line" id="L1925">    <span class="tok-kw">var</span> result: full.ContainerField = .{</span>
<span class="line" id="L1926">        .ast = info,</span>
<span class="line" id="L1927">        .comptime_token = <span class="tok-null">null</span>,</span>
<span class="line" id="L1928">    };</span>
<span class="line" id="L1929">    <span class="tok-comment">// comptime name: type = init,</span>
</span>
<span class="line" id="L1930">    <span class="tok-comment">// ^</span>
</span>
<span class="line" id="L1931">    <span class="tok-kw">if</span> (info.name_token &gt; <span class="tok-number">0</span> <span class="tok-kw">and</span> token_tags[info.name_token - <span class="tok-number">1</span>] == .keyword_comptime) {</span>
<span class="line" id="L1932">        result.comptime_token = info.name_token - <span class="tok-number">1</span>;</span>
<span class="line" id="L1933">    }</span>
<span class="line" id="L1934">    <span class="tok-kw">return</span> result;</span>
<span class="line" id="L1935">}</span>
<span class="line" id="L1936"></span>
<span class="line" id="L1937"><span class="tok-kw">fn</span> <span class="tok-fn">fullFnProto</span>(tree: Ast, info: full.FnProto.Components) full.FnProto {</span>
<span class="line" id="L1938">    <span class="tok-kw">const</span> token_tags = tree.tokens.items(.tag);</span>
<span class="line" id="L1939">    <span class="tok-kw">var</span> result: full.FnProto = .{</span>
<span class="line" id="L1940">        .ast = info,</span>
<span class="line" id="L1941">        .visib_token = <span class="tok-null">null</span>,</span>
<span class="line" id="L1942">        .extern_export_inline_token = <span class="tok-null">null</span>,</span>
<span class="line" id="L1943">        .lib_name = <span class="tok-null">null</span>,</span>
<span class="line" id="L1944">        .name_token = <span class="tok-null">null</span>,</span>
<span class="line" id="L1945">        .lparen = <span class="tok-null">undefined</span>,</span>
<span class="line" id="L1946">    };</span>
<span class="line" id="L1947">    <span class="tok-kw">var</span> i = info.fn_token;</span>
<span class="line" id="L1948">    <span class="tok-kw">while</span> (i &gt; <span class="tok-number">0</span>) {</span>
<span class="line" id="L1949">        i -= <span class="tok-number">1</span>;</span>
<span class="line" id="L1950">        <span class="tok-kw">switch</span> (token_tags[i]) {</span>
<span class="line" id="L1951">            .keyword_extern,</span>
<span class="line" id="L1952">            .keyword_export,</span>
<span class="line" id="L1953">            .keyword_inline,</span>
<span class="line" id="L1954">            .keyword_noinline,</span>
<span class="line" id="L1955">            =&gt; result.extern_export_inline_token = i,</span>
<span class="line" id="L1956">            .keyword_pub =&gt; result.visib_token = i,</span>
<span class="line" id="L1957">            .string_literal =&gt; result.lib_name = i,</span>
<span class="line" id="L1958">            <span class="tok-kw">else</span> =&gt; <span class="tok-kw">break</span>,</span>
<span class="line" id="L1959">        }</span>
<span class="line" id="L1960">    }</span>
<span class="line" id="L1961">    <span class="tok-kw">const</span> after_fn_token = info.fn_token + <span class="tok-number">1</span>;</span>
<span class="line" id="L1962">    <span class="tok-kw">if</span> (token_tags[after_fn_token] == .identifier) {</span>
<span class="line" id="L1963">        result.name_token = after_fn_token;</span>
<span class="line" id="L1964">        result.lparen = after_fn_token + <span class="tok-number">1</span>;</span>
<span class="line" id="L1965">    } <span class="tok-kw">else</span> {</span>
<span class="line" id="L1966">        result.lparen = after_fn_token;</span>
<span class="line" id="L1967">    }</span>
<span class="line" id="L1968">    assert(token_tags[result.lparen] == .l_paren);</span>
<span class="line" id="L1969"></span>
<span class="line" id="L1970">    <span class="tok-kw">return</span> result;</span>
<span class="line" id="L1971">}</span>
<span class="line" id="L1972"></span>
<span class="line" id="L1973"><span class="tok-kw">fn</span> <span class="tok-fn">fullStructInit</span>(tree: Ast, info: full.StructInit.Components) full.StructInit {</span>
<span class="line" id="L1974">    _ = tree;</span>
<span class="line" id="L1975">    <span class="tok-kw">var</span> result: full.StructInit = .{</span>
<span class="line" id="L1976">        .ast = info,</span>
<span class="line" id="L1977">    };</span>
<span class="line" id="L1978">    <span class="tok-kw">return</span> result;</span>
<span class="line" id="L1979">}</span>
<span class="line" id="L1980"></span>
<span class="line" id="L1981"><span class="tok-kw">fn</span> <span class="tok-fn">fullPtrType</span>(tree: Ast, info: full.PtrType.Components) full.PtrType {</span>
<span class="line" id="L1982">    <span class="tok-kw">const</span> token_tags = tree.tokens.items(.tag);</span>
<span class="line" id="L1983">    <span class="tok-comment">// TODO: looks like stage1 isn't quite smart enough to handle enum</span>
</span>
<span class="line" id="L1984">    <span class="tok-comment">// literals in some places here</span>
</span>
<span class="line" id="L1985">    <span class="tok-kw">const</span> Size = std.builtin.Type.Pointer.Size;</span>
<span class="line" id="L1986">    <span class="tok-kw">const</span> size: Size = <span class="tok-kw">switch</span> (token_tags[info.main_token]) {</span>
<span class="line" id="L1987">        .asterisk,</span>
<span class="line" id="L1988">        .asterisk_asterisk,</span>
<span class="line" id="L1989">        =&gt; <span class="tok-kw">switch</span> (token_tags[info.main_token + <span class="tok-number">1</span>]) {</span>
<span class="line" id="L1990">            .r_bracket, .colon =&gt; .Many,</span>
<span class="line" id="L1991">            .identifier =&gt; <span class="tok-kw">if</span> (token_tags[info.main_token - <span class="tok-number">1</span>] == .l_bracket) Size.C <span class="tok-kw">else</span> .One,</span>
<span class="line" id="L1992">            <span class="tok-kw">else</span> =&gt; .One,</span>
<span class="line" id="L1993">        },</span>
<span class="line" id="L1994">        .l_bracket =&gt; Size.Slice,</span>
<span class="line" id="L1995">        <span class="tok-kw">else</span> =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L1996">    };</span>
<span class="line" id="L1997">    <span class="tok-kw">var</span> result: full.PtrType = .{</span>
<span class="line" id="L1998">        .size = size,</span>
<span class="line" id="L1999">        .allowzero_token = <span class="tok-null">null</span>,</span>
<span class="line" id="L2000">        .const_token = <span class="tok-null">null</span>,</span>
<span class="line" id="L2001">        .volatile_token = <span class="tok-null">null</span>,</span>
<span class="line" id="L2002">        .ast = info,</span>
<span class="line" id="L2003">    };</span>
<span class="line" id="L2004">    <span class="tok-comment">// We need to be careful that we don't iterate over any sub-expressions</span>
</span>
<span class="line" id="L2005">    <span class="tok-comment">// here while looking for modifiers as that could result in false</span>
</span>
<span class="line" id="L2006">    <span class="tok-comment">// positives. Therefore, start after a sentinel if there is one and</span>
</span>
<span class="line" id="L2007">    <span class="tok-comment">// skip over any align node and bit range nodes.</span>
</span>
<span class="line" id="L2008">    <span class="tok-kw">var</span> i = <span class="tok-kw">if</span> (info.sentinel != <span class="tok-number">0</span>) tree.lastToken(info.sentinel) + <span class="tok-number">1</span> <span class="tok-kw">else</span> info.main_token;</span>
<span class="line" id="L2009">    <span class="tok-kw">const</span> end = tree.firstToken(info.child_type);</span>
<span class="line" id="L2010">    <span class="tok-kw">while</span> (i &lt; end) : (i += <span class="tok-number">1</span>) {</span>
<span class="line" id="L2011">        <span class="tok-kw">switch</span> (token_tags[i]) {</span>
<span class="line" id="L2012">            .keyword_allowzero =&gt; result.allowzero_token = i,</span>
<span class="line" id="L2013">            .keyword_const =&gt; result.const_token = i,</span>
<span class="line" id="L2014">            .keyword_volatile =&gt; result.volatile_token = i,</span>
<span class="line" id="L2015">            .keyword_align =&gt; {</span>
<span class="line" id="L2016">                assert(info.align_node != <span class="tok-number">0</span>);</span>
<span class="line" id="L2017">                <span class="tok-kw">if</span> (info.bit_range_end != <span class="tok-number">0</span>) {</span>
<span class="line" id="L2018">                    assert(info.bit_range_start != <span class="tok-number">0</span>);</span>
<span class="line" id="L2019">                    i = tree.lastToken(info.bit_range_end) + <span class="tok-number">1</span>;</span>
<span class="line" id="L2020">                } <span class="tok-kw">else</span> {</span>
<span class="line" id="L2021">                    i = tree.lastToken(info.align_node) + <span class="tok-number">1</span>;</span>
<span class="line" id="L2022">                }</span>
<span class="line" id="L2023">            },</span>
<span class="line" id="L2024">            <span class="tok-kw">else</span> =&gt; {},</span>
<span class="line" id="L2025">        }</span>
<span class="line" id="L2026">    }</span>
<span class="line" id="L2027">    <span class="tok-kw">return</span> result;</span>
<span class="line" id="L2028">}</span>
<span class="line" id="L2029"></span>
<span class="line" id="L2030"><span class="tok-kw">fn</span> <span class="tok-fn">fullContainerDecl</span>(tree: Ast, info: full.ContainerDecl.Components) full.ContainerDecl {</span>
<span class="line" id="L2031">    <span class="tok-kw">const</span> token_tags = tree.tokens.items(.tag);</span>
<span class="line" id="L2032">    <span class="tok-kw">var</span> result: full.ContainerDecl = .{</span>
<span class="line" id="L2033">        .ast = info,</span>
<span class="line" id="L2034">        .layout_token = <span class="tok-null">null</span>,</span>
<span class="line" id="L2035">    };</span>
<span class="line" id="L2036">    <span class="tok-kw">switch</span> (token_tags[info.main_token - <span class="tok-number">1</span>]) {</span>
<span class="line" id="L2037">        .keyword_extern, .keyword_packed =&gt; result.layout_token = info.main_token - <span class="tok-number">1</span>,</span>
<span class="line" id="L2038">        <span class="tok-kw">else</span> =&gt; {},</span>
<span class="line" id="L2039">    }</span>
<span class="line" id="L2040">    <span class="tok-kw">return</span> result;</span>
<span class="line" id="L2041">}</span>
<span class="line" id="L2042"></span>
<span class="line" id="L2043"><span class="tok-kw">fn</span> <span class="tok-fn">fullSwitchCase</span>(tree: Ast, info: full.SwitchCase.Components) full.SwitchCase {</span>
<span class="line" id="L2044">    <span class="tok-kw">const</span> token_tags = tree.tokens.items(.tag);</span>
<span class="line" id="L2045">    <span class="tok-kw">var</span> result: full.SwitchCase = .{</span>
<span class="line" id="L2046">        .ast = info,</span>
<span class="line" id="L2047">        .payload_token = <span class="tok-null">null</span>,</span>
<span class="line" id="L2048">    };</span>
<span class="line" id="L2049">    <span class="tok-kw">if</span> (token_tags[info.arrow_token + <span class="tok-number">1</span>] == .pipe) {</span>
<span class="line" id="L2050">        result.payload_token = info.arrow_token + <span class="tok-number">2</span>;</span>
<span class="line" id="L2051">    }</span>
<span class="line" id="L2052">    <span class="tok-kw">return</span> result;</span>
<span class="line" id="L2053">}</span>
<span class="line" id="L2054"></span>
<span class="line" id="L2055"><span class="tok-kw">fn</span> <span class="tok-fn">fullAsm</span>(tree: Ast, info: full.Asm.Components) full.Asm {</span>
<span class="line" id="L2056">    <span class="tok-kw">const</span> token_tags = tree.tokens.items(.tag);</span>
<span class="line" id="L2057">    <span class="tok-kw">const</span> node_tags = tree.nodes.items(.tag);</span>
<span class="line" id="L2058">    <span class="tok-kw">var</span> result: full.Asm = .{</span>
<span class="line" id="L2059">        .ast = info,</span>
<span class="line" id="L2060">        .volatile_token = <span class="tok-null">null</span>,</span>
<span class="line" id="L2061">        .inputs = &amp;.{},</span>
<span class="line" id="L2062">        .outputs = &amp;.{},</span>
<span class="line" id="L2063">        .first_clobber = <span class="tok-null">null</span>,</span>
<span class="line" id="L2064">    };</span>
<span class="line" id="L2065">    <span class="tok-kw">if</span> (token_tags[info.asm_token + <span class="tok-number">1</span>] == .keyword_volatile) {</span>
<span class="line" id="L2066">        result.volatile_token = info.asm_token + <span class="tok-number">1</span>;</span>
<span class="line" id="L2067">    }</span>
<span class="line" id="L2068">    <span class="tok-kw">const</span> outputs_end: <span class="tok-type">usize</span> = <span class="tok-kw">for</span> (info.items) |item, i| {</span>
<span class="line" id="L2069">        <span class="tok-kw">switch</span> (node_tags[item]) {</span>
<span class="line" id="L2070">            .asm_output =&gt; <span class="tok-kw">continue</span>,</span>
<span class="line" id="L2071">            <span class="tok-kw">else</span> =&gt; <span class="tok-kw">break</span> i,</span>
<span class="line" id="L2072">        }</span>
<span class="line" id="L2073">    } <span class="tok-kw">else</span> info.items.len;</span>
<span class="line" id="L2074"></span>
<span class="line" id="L2075">    result.outputs = info.items[<span class="tok-number">0</span>..outputs_end];</span>
<span class="line" id="L2076">    result.inputs = info.items[outputs_end..];</span>
<span class="line" id="L2077"></span>
<span class="line" id="L2078">    <span class="tok-kw">if</span> (info.items.len == <span class="tok-number">0</span>) {</span>
<span class="line" id="L2079">        <span class="tok-comment">// asm (&quot;foo&quot; ::: &quot;a&quot;, &quot;b&quot;);</span>
</span>
<span class="line" id="L2080">        <span class="tok-kw">const</span> template_token = tree.lastToken(info.template);</span>
<span class="line" id="L2081">        <span class="tok-kw">if</span> (token_tags[template_token + <span class="tok-number">1</span>] == .colon <span class="tok-kw">and</span></span>
<span class="line" id="L2082">            token_tags[template_token + <span class="tok-number">2</span>] == .colon <span class="tok-kw">and</span></span>
<span class="line" id="L2083">            token_tags[template_token + <span class="tok-number">3</span>] == .colon <span class="tok-kw">and</span></span>
<span class="line" id="L2084">            token_tags[template_token + <span class="tok-number">4</span>] == .string_literal)</span>
<span class="line" id="L2085">        {</span>
<span class="line" id="L2086">            result.first_clobber = template_token + <span class="tok-number">4</span>;</span>
<span class="line" id="L2087">        }</span>
<span class="line" id="L2088">    } <span class="tok-kw">else</span> <span class="tok-kw">if</span> (result.inputs.len != <span class="tok-number">0</span>) {</span>
<span class="line" id="L2089">        <span class="tok-comment">// asm (&quot;foo&quot; :: [_] &quot;&quot; (y) : &quot;a&quot;, &quot;b&quot;);</span>
</span>
<span class="line" id="L2090">        <span class="tok-kw">const</span> last_input = result.inputs[result.inputs.len - <span class="tok-number">1</span>];</span>
<span class="line" id="L2091">        <span class="tok-kw">const</span> rparen = tree.lastToken(last_input);</span>
<span class="line" id="L2092">        <span class="tok-kw">var</span> i = rparen + <span class="tok-number">1</span>;</span>
<span class="line" id="L2093">        <span class="tok-comment">// Allow a (useless) comma right after the closing parenthesis.</span>
</span>
<span class="line" id="L2094">        <span class="tok-kw">if</span> (token_tags[i] == .comma) i += <span class="tok-number">1</span>;</span>
<span class="line" id="L2095">        <span class="tok-kw">if</span> (token_tags[i] == .colon <span class="tok-kw">and</span></span>
<span class="line" id="L2096">            token_tags[i + <span class="tok-number">1</span>] == .string_literal)</span>
<span class="line" id="L2097">        {</span>
<span class="line" id="L2098">            result.first_clobber = i + <span class="tok-number">1</span>;</span>
<span class="line" id="L2099">        }</span>
<span class="line" id="L2100">    } <span class="tok-kw">else</span> {</span>
<span class="line" id="L2101">        <span class="tok-comment">// asm (&quot;foo&quot; : [_] &quot;&quot; (x) :: &quot;a&quot;, &quot;b&quot;);</span>
</span>
<span class="line" id="L2102">        <span class="tok-kw">const</span> last_output = result.outputs[result.outputs.len - <span class="tok-number">1</span>];</span>
<span class="line" id="L2103">        <span class="tok-kw">const</span> rparen = tree.lastToken(last_output);</span>
<span class="line" id="L2104">        <span class="tok-kw">var</span> i = rparen + <span class="tok-number">1</span>;</span>
<span class="line" id="L2105">        <span class="tok-comment">// Allow a (useless) comma right after the closing parenthesis.</span>
</span>
<span class="line" id="L2106">        <span class="tok-kw">if</span> (token_tags[i] == .comma) i += <span class="tok-number">1</span>;</span>
<span class="line" id="L2107">        <span class="tok-kw">if</span> (token_tags[i] == .colon <span class="tok-kw">and</span></span>
<span class="line" id="L2108">            token_tags[i + <span class="tok-number">1</span>] == .colon <span class="tok-kw">and</span></span>
<span class="line" id="L2109">            token_tags[i + <span class="tok-number">2</span>] == .string_literal)</span>
<span class="line" id="L2110">        {</span>
<span class="line" id="L2111">            result.first_clobber = i + <span class="tok-number">2</span>;</span>
<span class="line" id="L2112">        }</span>
<span class="line" id="L2113">    }</span>
<span class="line" id="L2114"></span>
<span class="line" id="L2115">    <span class="tok-kw">return</span> result;</span>
<span class="line" id="L2116">}</span>
<span class="line" id="L2117"></span>
<span class="line" id="L2118"><span class="tok-kw">fn</span> <span class="tok-fn">fullWhile</span>(tree: Ast, info: full.While.Components) full.While {</span>
<span class="line" id="L2119">    <span class="tok-kw">const</span> token_tags = tree.tokens.items(.tag);</span>
<span class="line" id="L2120">    <span class="tok-kw">var</span> result: full.While = .{</span>
<span class="line" id="L2121">        .ast = info,</span>
<span class="line" id="L2122">        .inline_token = <span class="tok-null">null</span>,</span>
<span class="line" id="L2123">        .label_token = <span class="tok-null">null</span>,</span>
<span class="line" id="L2124">        .payload_token = <span class="tok-null">null</span>,</span>
<span class="line" id="L2125">        .else_token = <span class="tok-null">undefined</span>,</span>
<span class="line" id="L2126">        .error_token = <span class="tok-null">null</span>,</span>
<span class="line" id="L2127">    };</span>
<span class="line" id="L2128">    <span class="tok-kw">var</span> tok_i = info.while_token - <span class="tok-number">1</span>;</span>
<span class="line" id="L2129">    <span class="tok-kw">if</span> (token_tags[tok_i] == .keyword_inline) {</span>
<span class="line" id="L2130">        result.inline_token = tok_i;</span>
<span class="line" id="L2131">        tok_i -= <span class="tok-number">1</span>;</span>
<span class="line" id="L2132">    }</span>
<span class="line" id="L2133">    <span class="tok-kw">if</span> (token_tags[tok_i] == .colon <span class="tok-kw">and</span></span>
<span class="line" id="L2134">        token_tags[tok_i - <span class="tok-number">1</span>] == .identifier)</span>
<span class="line" id="L2135">    {</span>
<span class="line" id="L2136">        result.label_token = tok_i - <span class="tok-number">1</span>;</span>
<span class="line" id="L2137">    }</span>
<span class="line" id="L2138">    <span class="tok-kw">const</span> last_cond_token = tree.lastToken(info.cond_expr);</span>
<span class="line" id="L2139">    <span class="tok-kw">if</span> (token_tags[last_cond_token + <span class="tok-number">2</span>] == .pipe) {</span>
<span class="line" id="L2140">        result.payload_token = last_cond_token + <span class="tok-number">3</span>;</span>
<span class="line" id="L2141">    }</span>
<span class="line" id="L2142">    <span class="tok-kw">if</span> (info.else_expr != <span class="tok-number">0</span>) {</span>
<span class="line" id="L2143">        <span class="tok-comment">// then_expr else |x|</span>
</span>
<span class="line" id="L2144">        <span class="tok-comment">//           ^    ^</span>
</span>
<span class="line" id="L2145">        result.else_token = tree.lastToken(info.then_expr) + <span class="tok-number">1</span>;</span>
<span class="line" id="L2146">        <span class="tok-kw">if</span> (token_tags[result.else_token + <span class="tok-number">1</span>] == .pipe) {</span>
<span class="line" id="L2147">            result.error_token = result.else_token + <span class="tok-number">2</span>;</span>
<span class="line" id="L2148">        }</span>
<span class="line" id="L2149">    }</span>
<span class="line" id="L2150">    <span class="tok-kw">return</span> result;</span>
<span class="line" id="L2151">}</span>
<span class="line" id="L2152"></span>
<span class="line" id="L2153"><span class="tok-kw">fn</span> <span class="tok-fn">fullCall</span>(tree: Ast, info: full.Call.Components) full.Call {</span>
<span class="line" id="L2154">    <span class="tok-kw">const</span> token_tags = tree.tokens.items(.tag);</span>
<span class="line" id="L2155">    <span class="tok-kw">var</span> result: full.Call = .{</span>
<span class="line" id="L2156">        .ast = info,</span>
<span class="line" id="L2157">        .async_token = <span class="tok-null">null</span>,</span>
<span class="line" id="L2158">    };</span>
<span class="line" id="L2159">    <span class="tok-kw">const</span> maybe_async_token = tree.firstToken(info.fn_expr) - <span class="tok-number">1</span>;</span>
<span class="line" id="L2160">    <span class="tok-kw">if</span> (token_tags[maybe_async_token] == .keyword_async) {</span>
<span class="line" id="L2161">        result.async_token = maybe_async_token;</span>
<span class="line" id="L2162">    }</span>
<span class="line" id="L2163">    <span class="tok-kw">return</span> result;</span>
<span class="line" id="L2164">}</span>
<span class="line" id="L2165"></span>
<span class="line" id="L2166"><span class="tok-comment">/// Fully assembled AST node information.</span></span>
<span class="line" id="L2167"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> full = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L2168">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> VarDecl = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L2169">        visib_token: ?TokenIndex,</span>
<span class="line" id="L2170">        extern_export_token: ?TokenIndex,</span>
<span class="line" id="L2171">        lib_name: ?TokenIndex,</span>
<span class="line" id="L2172">        threadlocal_token: ?TokenIndex,</span>
<span class="line" id="L2173">        comptime_token: ?TokenIndex,</span>
<span class="line" id="L2174">        ast: Components,</span>
<span class="line" id="L2175"></span>
<span class="line" id="L2176">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> Components = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L2177">            mut_token: TokenIndex,</span>
<span class="line" id="L2178">            type_node: Node.Index,</span>
<span class="line" id="L2179">            align_node: Node.Index,</span>
<span class="line" id="L2180">            addrspace_node: Node.Index,</span>
<span class="line" id="L2181">            section_node: Node.Index,</span>
<span class="line" id="L2182">            init_node: Node.Index,</span>
<span class="line" id="L2183">        };</span>
<span class="line" id="L2184"></span>
<span class="line" id="L2185">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">firstToken</span>(var_decl: VarDecl) TokenIndex {</span>
<span class="line" id="L2186">            <span class="tok-kw">return</span> var_decl.visib_token <span class="tok-kw">orelse</span></span>
<span class="line" id="L2187">                var_decl.extern_export_token <span class="tok-kw">orelse</span></span>
<span class="line" id="L2188">                var_decl.threadlocal_token <span class="tok-kw">orelse</span></span>
<span class="line" id="L2189">                var_decl.comptime_token <span class="tok-kw">orelse</span></span>
<span class="line" id="L2190">                var_decl.ast.mut_token;</span>
<span class="line" id="L2191">        }</span>
<span class="line" id="L2192">    };</span>
<span class="line" id="L2193"></span>
<span class="line" id="L2194">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> If = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L2195">        <span class="tok-comment">/// Points to the first token after the `|`. Will either be an identifier or</span></span>
<span class="line" id="L2196">        <span class="tok-comment">/// a `*` (with an identifier immediately after it).</span></span>
<span class="line" id="L2197">        payload_token: ?TokenIndex,</span>
<span class="line" id="L2198">        <span class="tok-comment">/// Points to the identifier after the `|`.</span></span>
<span class="line" id="L2199">        error_token: ?TokenIndex,</span>
<span class="line" id="L2200">        <span class="tok-comment">/// Populated only if else_expr != 0.</span></span>
<span class="line" id="L2201">        else_token: TokenIndex,</span>
<span class="line" id="L2202">        ast: Components,</span>
<span class="line" id="L2203"></span>
<span class="line" id="L2204">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> Components = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L2205">            if_token: TokenIndex,</span>
<span class="line" id="L2206">            cond_expr: Node.Index,</span>
<span class="line" id="L2207">            then_expr: Node.Index,</span>
<span class="line" id="L2208">            else_expr: Node.Index,</span>
<span class="line" id="L2209">        };</span>
<span class="line" id="L2210">    };</span>
<span class="line" id="L2211"></span>
<span class="line" id="L2212">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> While = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L2213">        ast: Components,</span>
<span class="line" id="L2214">        inline_token: ?TokenIndex,</span>
<span class="line" id="L2215">        label_token: ?TokenIndex,</span>
<span class="line" id="L2216">        payload_token: ?TokenIndex,</span>
<span class="line" id="L2217">        error_token: ?TokenIndex,</span>
<span class="line" id="L2218">        <span class="tok-comment">/// Populated only if else_expr != 0.</span></span>
<span class="line" id="L2219">        else_token: TokenIndex,</span>
<span class="line" id="L2220"></span>
<span class="line" id="L2221">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> Components = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L2222">            while_token: TokenIndex,</span>
<span class="line" id="L2223">            cond_expr: Node.Index,</span>
<span class="line" id="L2224">            cont_expr: Node.Index,</span>
<span class="line" id="L2225">            then_expr: Node.Index,</span>
<span class="line" id="L2226">            else_expr: Node.Index,</span>
<span class="line" id="L2227">        };</span>
<span class="line" id="L2228">    };</span>
<span class="line" id="L2229"></span>
<span class="line" id="L2230">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> ContainerField = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L2231">        comptime_token: ?TokenIndex,</span>
<span class="line" id="L2232">        ast: Components,</span>
<span class="line" id="L2233"></span>
<span class="line" id="L2234">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> Components = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L2235">            name_token: TokenIndex,</span>
<span class="line" id="L2236">            type_expr: Node.Index,</span>
<span class="line" id="L2237">            value_expr: Node.Index,</span>
<span class="line" id="L2238">            align_expr: Node.Index,</span>
<span class="line" id="L2239">        };</span>
<span class="line" id="L2240"></span>
<span class="line" id="L2241">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">firstToken</span>(cf: ContainerField) TokenIndex {</span>
<span class="line" id="L2242">            <span class="tok-kw">return</span> cf.comptime_token <span class="tok-kw">orelse</span> cf.ast.name_token;</span>
<span class="line" id="L2243">        }</span>
<span class="line" id="L2244">    };</span>
<span class="line" id="L2245"></span>
<span class="line" id="L2246">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> FnProto = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L2247">        visib_token: ?TokenIndex,</span>
<span class="line" id="L2248">        extern_export_inline_token: ?TokenIndex,</span>
<span class="line" id="L2249">        lib_name: ?TokenIndex,</span>
<span class="line" id="L2250">        name_token: ?TokenIndex,</span>
<span class="line" id="L2251">        lparen: TokenIndex,</span>
<span class="line" id="L2252">        ast: Components,</span>
<span class="line" id="L2253"></span>
<span class="line" id="L2254">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> Components = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L2255">            proto_node: Node.Index,</span>
<span class="line" id="L2256">            fn_token: TokenIndex,</span>
<span class="line" id="L2257">            return_type: Node.Index,</span>
<span class="line" id="L2258">            params: []<span class="tok-kw">const</span> Node.Index,</span>
<span class="line" id="L2259">            align_expr: Node.Index,</span>
<span class="line" id="L2260">            addrspace_expr: Node.Index,</span>
<span class="line" id="L2261">            section_expr: Node.Index,</span>
<span class="line" id="L2262">            callconv_expr: Node.Index,</span>
<span class="line" id="L2263">        };</span>
<span class="line" id="L2264"></span>
<span class="line" id="L2265">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> Param = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L2266">            first_doc_comment: ?TokenIndex,</span>
<span class="line" id="L2267">            name_token: ?TokenIndex,</span>
<span class="line" id="L2268">            comptime_noalias: ?TokenIndex,</span>
<span class="line" id="L2269">            anytype_ellipsis3: ?TokenIndex,</span>
<span class="line" id="L2270">            type_expr: Node.Index,</span>
<span class="line" id="L2271">        };</span>
<span class="line" id="L2272"></span>
<span class="line" id="L2273">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">firstToken</span>(fn_proto: FnProto) TokenIndex {</span>
<span class="line" id="L2274">            <span class="tok-kw">return</span> fn_proto.visib_token <span class="tok-kw">orelse</span></span>
<span class="line" id="L2275">                fn_proto.extern_export_inline_token <span class="tok-kw">orelse</span></span>
<span class="line" id="L2276">                fn_proto.ast.fn_token;</span>
<span class="line" id="L2277">        }</span>
<span class="line" id="L2278"></span>
<span class="line" id="L2279">        <span class="tok-comment">/// Abstracts over the fact that anytype and ... are not included</span></span>
<span class="line" id="L2280">        <span class="tok-comment">/// in the params slice, since they are simple identifiers and</span></span>
<span class="line" id="L2281">        <span class="tok-comment">/// not sub-expressions.</span></span>
<span class="line" id="L2282">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> Iterator = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L2283">            tree: *<span class="tok-kw">const</span> Ast,</span>
<span class="line" id="L2284">            fn_proto: *<span class="tok-kw">const</span> FnProto,</span>
<span class="line" id="L2285">            param_i: <span class="tok-type">usize</span>,</span>
<span class="line" id="L2286">            tok_i: TokenIndex,</span>
<span class="line" id="L2287">            tok_flag: <span class="tok-type">bool</span>,</span>
<span class="line" id="L2288"></span>
<span class="line" id="L2289">            <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">next</span>(it: *Iterator) ?Param {</span>
<span class="line" id="L2290">                <span class="tok-kw">const</span> token_tags = it.tree.tokens.items(.tag);</span>
<span class="line" id="L2291">                <span class="tok-kw">while</span> (<span class="tok-null">true</span>) {</span>
<span class="line" id="L2292">                    <span class="tok-kw">var</span> first_doc_comment: ?TokenIndex = <span class="tok-null">null</span>;</span>
<span class="line" id="L2293">                    <span class="tok-kw">var</span> comptime_noalias: ?TokenIndex = <span class="tok-null">null</span>;</span>
<span class="line" id="L2294">                    <span class="tok-kw">var</span> name_token: ?TokenIndex = <span class="tok-null">null</span>;</span>
<span class="line" id="L2295">                    <span class="tok-kw">if</span> (!it.tok_flag) {</span>
<span class="line" id="L2296">                        <span class="tok-kw">if</span> (it.param_i &gt;= it.fn_proto.ast.params.len) {</span>
<span class="line" id="L2297">                            <span class="tok-kw">return</span> <span class="tok-null">null</span>;</span>
<span class="line" id="L2298">                        }</span>
<span class="line" id="L2299">                        <span class="tok-kw">const</span> param_type = it.fn_proto.ast.params[it.param_i];</span>
<span class="line" id="L2300">                        <span class="tok-kw">var</span> tok_i = it.tree.firstToken(param_type) - <span class="tok-number">1</span>;</span>
<span class="line" id="L2301">                        <span class="tok-kw">while</span> (<span class="tok-null">true</span>) : (tok_i -= <span class="tok-number">1</span>) <span class="tok-kw">switch</span> (token_tags[tok_i]) {</span>
<span class="line" id="L2302">                            .colon =&gt; <span class="tok-kw">continue</span>,</span>
<span class="line" id="L2303">                            .identifier =&gt; name_token = tok_i,</span>
<span class="line" id="L2304">                            .doc_comment =&gt; first_doc_comment = tok_i,</span>
<span class="line" id="L2305">                            .keyword_comptime, .keyword_noalias =&gt; comptime_noalias = tok_i,</span>
<span class="line" id="L2306">                            <span class="tok-kw">else</span> =&gt; <span class="tok-kw">break</span>,</span>
<span class="line" id="L2307">                        };</span>
<span class="line" id="L2308">                        it.param_i += <span class="tok-number">1</span>;</span>
<span class="line" id="L2309">                        it.tok_i = it.tree.lastToken(param_type) + <span class="tok-number">1</span>;</span>
<span class="line" id="L2310">                        <span class="tok-comment">// Look for anytype and ... params afterwards.</span>
</span>
<span class="line" id="L2311">                        <span class="tok-kw">if</span> (token_tags[it.tok_i] == .comma) {</span>
<span class="line" id="L2312">                            it.tok_i += <span class="tok-number">1</span>;</span>
<span class="line" id="L2313">                        }</span>
<span class="line" id="L2314">                        it.tok_flag = <span class="tok-null">true</span>;</span>
<span class="line" id="L2315">                        <span class="tok-kw">return</span> Param{</span>
<span class="line" id="L2316">                            .first_doc_comment = first_doc_comment,</span>
<span class="line" id="L2317">                            .comptime_noalias = comptime_noalias,</span>
<span class="line" id="L2318">                            .name_token = name_token,</span>
<span class="line" id="L2319">                            .anytype_ellipsis3 = <span class="tok-null">null</span>,</span>
<span class="line" id="L2320">                            .type_expr = param_type,</span>
<span class="line" id="L2321">                        };</span>
<span class="line" id="L2322">                    }</span>
<span class="line" id="L2323">                    <span class="tok-kw">if</span> (token_tags[it.tok_i] == .comma) {</span>
<span class="line" id="L2324">                        it.tok_i += <span class="tok-number">1</span>;</span>
<span class="line" id="L2325">                    }</span>
<span class="line" id="L2326">                    <span class="tok-kw">if</span> (token_tags[it.tok_i] == .r_paren) {</span>
<span class="line" id="L2327">                        <span class="tok-kw">return</span> <span class="tok-null">null</span>;</span>
<span class="line" id="L2328">                    }</span>
<span class="line" id="L2329">                    <span class="tok-kw">if</span> (token_tags[it.tok_i] == .doc_comment) {</span>
<span class="line" id="L2330">                        first_doc_comment = it.tok_i;</span>
<span class="line" id="L2331">                        <span class="tok-kw">while</span> (token_tags[it.tok_i] == .doc_comment) {</span>
<span class="line" id="L2332">                            it.tok_i += <span class="tok-number">1</span>;</span>
<span class="line" id="L2333">                        }</span>
<span class="line" id="L2334">                    }</span>
<span class="line" id="L2335">                    <span class="tok-kw">switch</span> (token_tags[it.tok_i]) {</span>
<span class="line" id="L2336">                        .ellipsis3 =&gt; {</span>
<span class="line" id="L2337">                            it.tok_flag = <span class="tok-null">false</span>; <span class="tok-comment">// Next iteration should return null.</span>
</span>
<span class="line" id="L2338">                            <span class="tok-kw">return</span> Param{</span>
<span class="line" id="L2339">                                .first_doc_comment = first_doc_comment,</span>
<span class="line" id="L2340">                                .comptime_noalias = <span class="tok-null">null</span>,</span>
<span class="line" id="L2341">                                .name_token = <span class="tok-null">null</span>,</span>
<span class="line" id="L2342">                                .anytype_ellipsis3 = it.tok_i,</span>
<span class="line" id="L2343">                                .type_expr = <span class="tok-number">0</span>,</span>
<span class="line" id="L2344">                            };</span>
<span class="line" id="L2345">                        },</span>
<span class="line" id="L2346">                        .keyword_noalias, .keyword_comptime =&gt; {</span>
<span class="line" id="L2347">                            comptime_noalias = it.tok_i;</span>
<span class="line" id="L2348">                            it.tok_i += <span class="tok-number">1</span>;</span>
<span class="line" id="L2349">                        },</span>
<span class="line" id="L2350">                        <span class="tok-kw">else</span> =&gt; {},</span>
<span class="line" id="L2351">                    }</span>
<span class="line" id="L2352">                    <span class="tok-kw">if</span> (token_tags[it.tok_i] == .identifier <span class="tok-kw">and</span></span>
<span class="line" id="L2353">                        token_tags[it.tok_i + <span class="tok-number">1</span>] == .colon)</span>
<span class="line" id="L2354">                    {</span>
<span class="line" id="L2355">                        name_token = it.tok_i;</span>
<span class="line" id="L2356">                        it.tok_i += <span class="tok-number">2</span>;</span>
<span class="line" id="L2357">                    }</span>
<span class="line" id="L2358">                    <span class="tok-kw">if</span> (token_tags[it.tok_i] == .keyword_anytype) {</span>
<span class="line" id="L2359">                        it.tok_i += <span class="tok-number">1</span>;</span>
<span class="line" id="L2360">                        <span class="tok-kw">return</span> Param{</span>
<span class="line" id="L2361">                            .first_doc_comment = first_doc_comment,</span>
<span class="line" id="L2362">                            .comptime_noalias = comptime_noalias,</span>
<span class="line" id="L2363">                            .name_token = name_token,</span>
<span class="line" id="L2364">                            .anytype_ellipsis3 = it.tok_i - <span class="tok-number">1</span>,</span>
<span class="line" id="L2365">                            .type_expr = <span class="tok-number">0</span>,</span>
<span class="line" id="L2366">                        };</span>
<span class="line" id="L2367">                    }</span>
<span class="line" id="L2368">                    it.tok_flag = <span class="tok-null">false</span>;</span>
<span class="line" id="L2369">                }</span>
<span class="line" id="L2370">            }</span>
<span class="line" id="L2371">        };</span>
<span class="line" id="L2372"></span>
<span class="line" id="L2373">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">iterate</span>(fn_proto: *<span class="tok-kw">const</span> FnProto, tree: *<span class="tok-kw">const</span> Ast) Iterator {</span>
<span class="line" id="L2374">            <span class="tok-kw">return</span> .{</span>
<span class="line" id="L2375">                .tree = tree,</span>
<span class="line" id="L2376">                .fn_proto = fn_proto,</span>
<span class="line" id="L2377">                .param_i = <span class="tok-number">0</span>,</span>
<span class="line" id="L2378">                .tok_i = fn_proto.lparen + <span class="tok-number">1</span>,</span>
<span class="line" id="L2379">                .tok_flag = <span class="tok-null">true</span>,</span>
<span class="line" id="L2380">            };</span>
<span class="line" id="L2381">        }</span>
<span class="line" id="L2382">    };</span>
<span class="line" id="L2383"></span>
<span class="line" id="L2384">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> StructInit = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L2385">        ast: Components,</span>
<span class="line" id="L2386"></span>
<span class="line" id="L2387">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> Components = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L2388">            lbrace: TokenIndex,</span>
<span class="line" id="L2389">            fields: []<span class="tok-kw">const</span> Node.Index,</span>
<span class="line" id="L2390">            type_expr: Node.Index,</span>
<span class="line" id="L2391">        };</span>
<span class="line" id="L2392">    };</span>
<span class="line" id="L2393"></span>
<span class="line" id="L2394">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> ArrayInit = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L2395">        ast: Components,</span>
<span class="line" id="L2396"></span>
<span class="line" id="L2397">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> Components = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L2398">            lbrace: TokenIndex,</span>
<span class="line" id="L2399">            elements: []<span class="tok-kw">const</span> Node.Index,</span>
<span class="line" id="L2400">            type_expr: Node.Index,</span>
<span class="line" id="L2401">        };</span>
<span class="line" id="L2402">    };</span>
<span class="line" id="L2403"></span>
<span class="line" id="L2404">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> ArrayType = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L2405">        ast: Components,</span>
<span class="line" id="L2406"></span>
<span class="line" id="L2407">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> Components = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L2408">            lbracket: TokenIndex,</span>
<span class="line" id="L2409">            elem_count: Node.Index,</span>
<span class="line" id="L2410">            sentinel: Node.Index,</span>
<span class="line" id="L2411">            elem_type: Node.Index,</span>
<span class="line" id="L2412">        };</span>
<span class="line" id="L2413">    };</span>
<span class="line" id="L2414"></span>
<span class="line" id="L2415">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> PtrType = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L2416">        size: std.builtin.Type.Pointer.Size,</span>
<span class="line" id="L2417">        allowzero_token: ?TokenIndex,</span>
<span class="line" id="L2418">        const_token: ?TokenIndex,</span>
<span class="line" id="L2419">        volatile_token: ?TokenIndex,</span>
<span class="line" id="L2420">        ast: Components,</span>
<span class="line" id="L2421"></span>
<span class="line" id="L2422">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> Components = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L2423">            main_token: TokenIndex,</span>
<span class="line" id="L2424">            align_node: Node.Index,</span>
<span class="line" id="L2425">            addrspace_node: Node.Index,</span>
<span class="line" id="L2426">            sentinel: Node.Index,</span>
<span class="line" id="L2427">            bit_range_start: Node.Index,</span>
<span class="line" id="L2428">            bit_range_end: Node.Index,</span>
<span class="line" id="L2429">            child_type: Node.Index,</span>
<span class="line" id="L2430">        };</span>
<span class="line" id="L2431">    };</span>
<span class="line" id="L2432"></span>
<span class="line" id="L2433">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> Slice = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L2434">        ast: Components,</span>
<span class="line" id="L2435"></span>
<span class="line" id="L2436">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> Components = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L2437">            sliced: Node.Index,</span>
<span class="line" id="L2438">            lbracket: TokenIndex,</span>
<span class="line" id="L2439">            start: Node.Index,</span>
<span class="line" id="L2440">            end: Node.Index,</span>
<span class="line" id="L2441">            sentinel: Node.Index,</span>
<span class="line" id="L2442">        };</span>
<span class="line" id="L2443">    };</span>
<span class="line" id="L2444"></span>
<span class="line" id="L2445">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> ContainerDecl = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L2446">        layout_token: ?TokenIndex,</span>
<span class="line" id="L2447">        ast: Components,</span>
<span class="line" id="L2448"></span>
<span class="line" id="L2449">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> Components = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L2450">            main_token: TokenIndex,</span>
<span class="line" id="L2451">            <span class="tok-comment">/// Populated when main_token is Keyword_union.</span></span>
<span class="line" id="L2452">            enum_token: ?TokenIndex,</span>
<span class="line" id="L2453">            members: []<span class="tok-kw">const</span> Node.Index,</span>
<span class="line" id="L2454">            arg: Node.Index,</span>
<span class="line" id="L2455">        };</span>
<span class="line" id="L2456">    };</span>
<span class="line" id="L2457"></span>
<span class="line" id="L2458">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> SwitchCase = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L2459">        <span class="tok-comment">/// Points to the first token after the `|`. Will either be an identifier or</span></span>
<span class="line" id="L2460">        <span class="tok-comment">/// a `*` (with an identifier immediately after it).</span></span>
<span class="line" id="L2461">        payload_token: ?TokenIndex,</span>
<span class="line" id="L2462">        ast: Components,</span>
<span class="line" id="L2463"></span>
<span class="line" id="L2464">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> Components = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L2465">            <span class="tok-comment">/// If empty, this is an else case</span></span>
<span class="line" id="L2466">            values: []<span class="tok-kw">const</span> Node.Index,</span>
<span class="line" id="L2467">            arrow_token: TokenIndex,</span>
<span class="line" id="L2468">            target_expr: Node.Index,</span>
<span class="line" id="L2469">        };</span>
<span class="line" id="L2470">    };</span>
<span class="line" id="L2471"></span>
<span class="line" id="L2472">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> Asm = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L2473">        ast: Components,</span>
<span class="line" id="L2474">        volatile_token: ?TokenIndex,</span>
<span class="line" id="L2475">        first_clobber: ?TokenIndex,</span>
<span class="line" id="L2476">        outputs: []<span class="tok-kw">const</span> Node.Index,</span>
<span class="line" id="L2477">        inputs: []<span class="tok-kw">const</span> Node.Index,</span>
<span class="line" id="L2478"></span>
<span class="line" id="L2479">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> Components = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L2480">            asm_token: TokenIndex,</span>
<span class="line" id="L2481">            template: Node.Index,</span>
<span class="line" id="L2482">            items: []<span class="tok-kw">const</span> Node.Index,</span>
<span class="line" id="L2483">            rparen: TokenIndex,</span>
<span class="line" id="L2484">        };</span>
<span class="line" id="L2485">    };</span>
<span class="line" id="L2486"></span>
<span class="line" id="L2487">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> Call = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L2488">        ast: Components,</span>
<span class="line" id="L2489">        async_token: ?TokenIndex,</span>
<span class="line" id="L2490"></span>
<span class="line" id="L2491">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> Components = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L2492">            lparen: TokenIndex,</span>
<span class="line" id="L2493">            fn_expr: Node.Index,</span>
<span class="line" id="L2494">            params: []<span class="tok-kw">const</span> Node.Index,</span>
<span class="line" id="L2495">        };</span>
<span class="line" id="L2496">    };</span>
<span class="line" id="L2497">};</span>
<span class="line" id="L2498"></span>
<span class="line" id="L2499"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> Error = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L2500">    tag: Tag,</span>
<span class="line" id="L2501">    is_note: <span class="tok-type">bool</span> = <span class="tok-null">false</span>,</span>
<span class="line" id="L2502">    <span class="tok-comment">/// True if `token` points to the token before the token causing an issue.</span></span>
<span class="line" id="L2503">    token_is_prev: <span class="tok-type">bool</span> = <span class="tok-null">false</span>,</span>
<span class="line" id="L2504">    token: TokenIndex,</span>
<span class="line" id="L2505">    extra: <span class="tok-kw">union</span> {</span>
<span class="line" id="L2506">        none: <span class="tok-type">void</span>,</span>
<span class="line" id="L2507">        expected_tag: Token.Tag,</span>
<span class="line" id="L2508">    } = .{ .none = {} },</span>
<span class="line" id="L2509"></span>
<span class="line" id="L2510">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> Tag = <span class="tok-kw">enum</span> {</span>
<span class="line" id="L2511">        asterisk_after_ptr_deref,</span>
<span class="line" id="L2512">        chained_comparison_operators,</span>
<span class="line" id="L2513">        decl_between_fields,</span>
<span class="line" id="L2514">        expected_block,</span>
<span class="line" id="L2515">        expected_block_or_assignment,</span>
<span class="line" id="L2516">        expected_block_or_expr,</span>
<span class="line" id="L2517">        expected_block_or_field,</span>
<span class="line" id="L2518">        expected_container_members,</span>
<span class="line" id="L2519">        expected_expr,</span>
<span class="line" id="L2520">        expected_expr_or_assignment,</span>
<span class="line" id="L2521">        expected_fn,</span>
<span class="line" id="L2522">        expected_inlinable,</span>
<span class="line" id="L2523">        expected_labelable,</span>
<span class="line" id="L2524">        expected_param_list,</span>
<span class="line" id="L2525">        expected_prefix_expr,</span>
<span class="line" id="L2526">        expected_primary_type_expr,</span>
<span class="line" id="L2527">        expected_pub_item,</span>
<span class="line" id="L2528">        expected_return_type,</span>
<span class="line" id="L2529">        expected_semi_or_else,</span>
<span class="line" id="L2530">        expected_semi_or_lbrace,</span>
<span class="line" id="L2531">        expected_statement,</span>
<span class="line" id="L2532">        expected_suffix_op,</span>
<span class="line" id="L2533">        expected_type_expr,</span>
<span class="line" id="L2534">        expected_var_decl,</span>
<span class="line" id="L2535">        expected_var_decl_or_fn,</span>
<span class="line" id="L2536">        expected_loop_payload,</span>
<span class="line" id="L2537">        expected_container,</span>
<span class="line" id="L2538">        extern_fn_body,</span>
<span class="line" id="L2539">        extra_addrspace_qualifier,</span>
<span class="line" id="L2540">        extra_align_qualifier,</span>
<span class="line" id="L2541">        extra_allowzero_qualifier,</span>
<span class="line" id="L2542">        extra_const_qualifier,</span>
<span class="line" id="L2543">        extra_volatile_qualifier,</span>
<span class="line" id="L2544">        ptr_mod_on_array_child_type,</span>
<span class="line" id="L2545">        invalid_bit_range,</span>
<span class="line" id="L2546">        same_line_doc_comment,</span>
<span class="line" id="L2547">        unattached_doc_comment,</span>
<span class="line" id="L2548">        test_doc_comment,</span>
<span class="line" id="L2549">        comptime_doc_comment,</span>
<span class="line" id="L2550">        varargs_nonfinal,</span>
<span class="line" id="L2551">        expected_continue_expr,</span>
<span class="line" id="L2552">        expected_semi_after_decl,</span>
<span class="line" id="L2553">        expected_semi_after_stmt,</span>
<span class="line" id="L2554">        expected_comma_after_field,</span>
<span class="line" id="L2555">        expected_comma_after_arg,</span>
<span class="line" id="L2556">        expected_comma_after_param,</span>
<span class="line" id="L2557">        expected_comma_after_initializer,</span>
<span class="line" id="L2558">        expected_comma_after_switch_prong,</span>
<span class="line" id="L2559">        expected_initializer,</span>
<span class="line" id="L2560">        mismatched_binary_op_whitespace,</span>
<span class="line" id="L2561">        invalid_ampersand_ampersand,</span>
<span class="line" id="L2562">        c_style_container,</span>
<span class="line" id="L2563"></span>
<span class="line" id="L2564">        zig_style_container,</span>
<span class="line" id="L2565">        previous_field,</span>
<span class="line" id="L2566">        next_field,</span>
<span class="line" id="L2567"></span>
<span class="line" id="L2568">        <span class="tok-comment">/// `expected_tag` is populated.</span></span>
<span class="line" id="L2569">        expected_token,</span>
<span class="line" id="L2570">    };</span>
<span class="line" id="L2571">};</span>
<span class="line" id="L2572"></span>
<span class="line" id="L2573"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> Node = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L2574">    tag: Tag,</span>
<span class="line" id="L2575">    main_token: TokenIndex,</span>
<span class="line" id="L2576">    data: Data,</span>
<span class="line" id="L2577"></span>
<span class="line" id="L2578">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> Index = <span class="tok-type">u32</span>;</span>
<span class="line" id="L2579"></span>
<span class="line" id="L2580">    <span class="tok-kw">comptime</span> {</span>
<span class="line" id="L2581">        <span class="tok-comment">// Goal is to keep this under one byte for efficiency.</span>
</span>
<span class="line" id="L2582">        assert(<span class="tok-builtin">@sizeOf</span>(Tag) == <span class="tok-number">1</span>);</span>
<span class="line" id="L2583">    }</span>
<span class="line" id="L2584"></span>
<span class="line" id="L2585">    <span class="tok-comment">/// Note: The FooComma/FooSemicolon variants exist to ease the implementation of</span></span>
<span class="line" id="L2586">    <span class="tok-comment">/// Ast.lastToken()</span></span>
<span class="line" id="L2587">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> Tag = <span class="tok-kw">enum</span> {</span>
<span class="line" id="L2588">        <span class="tok-comment">/// sub_list[lhs...rhs]</span></span>
<span class="line" id="L2589">        root,</span>
<span class="line" id="L2590">        <span class="tok-comment">/// `usingnamespace lhs;`. rhs unused. main_token is `usingnamespace`.</span></span>
<span class="line" id="L2591">        @&quot;usingnamespace&quot;,</span>
<span class="line" id="L2592">        <span class="tok-comment">/// lhs is test name token (must be string literal or identifier), if any.</span></span>
<span class="line" id="L2593">        <span class="tok-comment">/// rhs is the body node.</span></span>
<span class="line" id="L2594">        test_decl,</span>
<span class="line" id="L2595">        <span class="tok-comment">/// lhs is the index into extra_data.</span></span>
<span class="line" id="L2596">        <span class="tok-comment">/// rhs is the initialization expression, if any.</span></span>
<span class="line" id="L2597">        <span class="tok-comment">/// main_token is `var` or `const`.</span></span>
<span class="line" id="L2598">        global_var_decl,</span>
<span class="line" id="L2599">        <span class="tok-comment">/// `var a: x align(y) = rhs`</span></span>
<span class="line" id="L2600">        <span class="tok-comment">/// lhs is the index into extra_data.</span></span>
<span class="line" id="L2601">        <span class="tok-comment">/// main_token is `var` or `const`.</span></span>
<span class="line" id="L2602">        local_var_decl,</span>
<span class="line" id="L2603">        <span class="tok-comment">/// `var a: lhs = rhs`. lhs and rhs may be unused.</span></span>
<span class="line" id="L2604">        <span class="tok-comment">/// Can be local or global.</span></span>
<span class="line" id="L2605">        <span class="tok-comment">/// main_token is `var` or `const`.</span></span>
<span class="line" id="L2606">        simple_var_decl,</span>
<span class="line" id="L2607">        <span class="tok-comment">/// `var a align(lhs) = rhs`. lhs and rhs may be unused.</span></span>
<span class="line" id="L2608">        <span class="tok-comment">/// Can be local or global.</span></span>
<span class="line" id="L2609">        <span class="tok-comment">/// main_token is `var` or `const`.</span></span>
<span class="line" id="L2610">        aligned_var_decl,</span>
<span class="line" id="L2611">        <span class="tok-comment">/// lhs is the identifier token payload if any,</span></span>
<span class="line" id="L2612">        <span class="tok-comment">/// rhs is the deferred expression.</span></span>
<span class="line" id="L2613">        @&quot;errdefer&quot;,</span>
<span class="line" id="L2614">        <span class="tok-comment">/// lhs is unused.</span></span>
<span class="line" id="L2615">        <span class="tok-comment">/// rhs is the deferred expression.</span></span>
<span class="line" id="L2616">        @&quot;defer&quot;,</span>
<span class="line" id="L2617">        <span class="tok-comment">/// lhs catch rhs</span></span>
<span class="line" id="L2618">        <span class="tok-comment">/// lhs catch |err| rhs</span></span>
<span class="line" id="L2619">        <span class="tok-comment">/// main_token is the `catch` keyword.</span></span>
<span class="line" id="L2620">        <span class="tok-comment">/// payload is determined by looking at the next token after the `catch` keyword.</span></span>
<span class="line" id="L2621">        @&quot;catch&quot;,</span>
<span class="line" id="L2622">        <span class="tok-comment">/// `lhs.a`. main_token is the dot. rhs is the identifier token index.</span></span>
<span class="line" id="L2623">        field_access,</span>
<span class="line" id="L2624">        <span class="tok-comment">/// `lhs.?`. main_token is the dot. rhs is the `?` token index.</span></span>
<span class="line" id="L2625">        unwrap_optional,</span>
<span class="line" id="L2626">        <span class="tok-comment">/// `lhs == rhs`. main_token is op.</span></span>
<span class="line" id="L2627">        equal_equal,</span>
<span class="line" id="L2628">        <span class="tok-comment">/// `lhs != rhs`. main_token is op.</span></span>
<span class="line" id="L2629">        bang_equal,</span>
<span class="line" id="L2630">        <span class="tok-comment">/// `lhs &lt; rhs`. main_token is op.</span></span>
<span class="line" id="L2631">        less_than,</span>
<span class="line" id="L2632">        <span class="tok-comment">/// `lhs &gt; rhs`. main_token is op.</span></span>
<span class="line" id="L2633">        greater_than,</span>
<span class="line" id="L2634">        <span class="tok-comment">/// `lhs &lt;= rhs`. main_token is op.</span></span>
<span class="line" id="L2635">        less_or_equal,</span>
<span class="line" id="L2636">        <span class="tok-comment">/// `lhs &gt;= rhs`. main_token is op.</span></span>
<span class="line" id="L2637">        greater_or_equal,</span>
<span class="line" id="L2638">        <span class="tok-comment">/// `lhs *= rhs`. main_token is op.</span></span>
<span class="line" id="L2639">        assign_mul,</span>
<span class="line" id="L2640">        <span class="tok-comment">/// `lhs /= rhs`. main_token is op.</span></span>
<span class="line" id="L2641">        assign_div,</span>
<span class="line" id="L2642">        <span class="tok-comment">/// `lhs *= rhs`. main_token is op.</span></span>
<span class="line" id="L2643">        assign_mod,</span>
<span class="line" id="L2644">        <span class="tok-comment">/// `lhs += rhs`. main_token is op.</span></span>
<span class="line" id="L2645">        assign_add,</span>
<span class="line" id="L2646">        <span class="tok-comment">/// `lhs -= rhs`. main_token is op.</span></span>
<span class="line" id="L2647">        assign_sub,</span>
<span class="line" id="L2648">        <span class="tok-comment">/// `lhs &lt;&lt;= rhs`. main_token is op.</span></span>
<span class="line" id="L2649">        assign_shl,</span>
<span class="line" id="L2650">        <span class="tok-comment">/// `lhs &lt;&lt;|= rhs`. main_token is op.</span></span>
<span class="line" id="L2651">        assign_shl_sat,</span>
<span class="line" id="L2652">        <span class="tok-comment">/// `lhs &gt;&gt;= rhs`. main_token is op.</span></span>
<span class="line" id="L2653">        assign_shr,</span>
<span class="line" id="L2654">        <span class="tok-comment">/// `lhs &amp;= rhs`. main_token is op.</span></span>
<span class="line" id="L2655">        assign_bit_and,</span>
<span class="line" id="L2656">        <span class="tok-comment">/// `lhs ^= rhs`. main_token is op.</span></span>
<span class="line" id="L2657">        assign_bit_xor,</span>
<span class="line" id="L2658">        <span class="tok-comment">/// `lhs |= rhs`. main_token is op.</span></span>
<span class="line" id="L2659">        assign_bit_or,</span>
<span class="line" id="L2660">        <span class="tok-comment">/// `lhs *%= rhs`. main_token is op.</span></span>
<span class="line" id="L2661">        assign_mul_wrap,</span>
<span class="line" id="L2662">        <span class="tok-comment">/// `lhs +%= rhs`. main_token is op.</span></span>
<span class="line" id="L2663">        assign_add_wrap,</span>
<span class="line" id="L2664">        <span class="tok-comment">/// `lhs -%= rhs`. main_token is op.</span></span>
<span class="line" id="L2665">        assign_sub_wrap,</span>
<span class="line" id="L2666">        <span class="tok-comment">/// `lhs *|= rhs`. main_token is op.</span></span>
<span class="line" id="L2667">        assign_mul_sat,</span>
<span class="line" id="L2668">        <span class="tok-comment">/// `lhs +|= rhs`. main_token is op.</span></span>
<span class="line" id="L2669">        assign_add_sat,</span>
<span class="line" id="L2670">        <span class="tok-comment">/// `lhs -|= rhs`. main_token is op.</span></span>
<span class="line" id="L2671">        assign_sub_sat,</span>
<span class="line" id="L2672">        <span class="tok-comment">/// `lhs = rhs`. main_token is op.</span></span>
<span class="line" id="L2673">        assign,</span>
<span class="line" id="L2674">        <span class="tok-comment">/// `lhs || rhs`. main_token is the `||`.</span></span>
<span class="line" id="L2675">        merge_error_sets,</span>
<span class="line" id="L2676">        <span class="tok-comment">/// `lhs * rhs`. main_token is the `*`.</span></span>
<span class="line" id="L2677">        mul,</span>
<span class="line" id="L2678">        <span class="tok-comment">/// `lhs / rhs`. main_token is the `/`.</span></span>
<span class="line" id="L2679">        div,</span>
<span class="line" id="L2680">        <span class="tok-comment">/// `lhs % rhs`. main_token is the `%`.</span></span>
<span class="line" id="L2681">        mod,</span>
<span class="line" id="L2682">        <span class="tok-comment">/// `lhs ** rhs`. main_token is the `**`.</span></span>
<span class="line" id="L2683">        array_mult,</span>
<span class="line" id="L2684">        <span class="tok-comment">/// `lhs *% rhs`. main_token is the `*%`.</span></span>
<span class="line" id="L2685">        mul_wrap,</span>
<span class="line" id="L2686">        <span class="tok-comment">/// `lhs *| rhs`. main_token is the `*|`.</span></span>
<span class="line" id="L2687">        mul_sat,</span>
<span class="line" id="L2688">        <span class="tok-comment">/// `lhs + rhs`. main_token is the `+`.</span></span>
<span class="line" id="L2689">        add,</span>
<span class="line" id="L2690">        <span class="tok-comment">/// `lhs - rhs`. main_token is the `-`.</span></span>
<span class="line" id="L2691">        sub,</span>
<span class="line" id="L2692">        <span class="tok-comment">/// `lhs ++ rhs`. main_token is the `++`.</span></span>
<span class="line" id="L2693">        array_cat,</span>
<span class="line" id="L2694">        <span class="tok-comment">/// `lhs +% rhs`. main_token is the `+%`.</span></span>
<span class="line" id="L2695">        add_wrap,</span>
<span class="line" id="L2696">        <span class="tok-comment">/// `lhs -% rhs`. main_token is the `-%`.</span></span>
<span class="line" id="L2697">        sub_wrap,</span>
<span class="line" id="L2698">        <span class="tok-comment">/// `lhs +| rhs`. main_token is the `+|`.</span></span>
<span class="line" id="L2699">        add_sat,</span>
<span class="line" id="L2700">        <span class="tok-comment">/// `lhs -| rhs`. main_token is the `-|`.</span></span>
<span class="line" id="L2701">        sub_sat,</span>
<span class="line" id="L2702">        <span class="tok-comment">/// `lhs &lt;&lt; rhs`. main_token is the `&lt;&lt;`.</span></span>
<span class="line" id="L2703">        shl,</span>
<span class="line" id="L2704">        <span class="tok-comment">/// `lhs &lt;&lt;| rhs`. main_token is the `&lt;&lt;|`.</span></span>
<span class="line" id="L2705">        shl_sat,</span>
<span class="line" id="L2706">        <span class="tok-comment">/// `lhs &gt;&gt; rhs`. main_token is the `&gt;&gt;`.</span></span>
<span class="line" id="L2707">        shr,</span>
<span class="line" id="L2708">        <span class="tok-comment">/// `lhs &amp; rhs`. main_token is the `&amp;`.</span></span>
<span class="line" id="L2709">        bit_and,</span>
<span class="line" id="L2710">        <span class="tok-comment">/// `lhs ^ rhs`. main_token is the `^`.</span></span>
<span class="line" id="L2711">        bit_xor,</span>
<span class="line" id="L2712">        <span class="tok-comment">/// `lhs | rhs`. main_token is the `|`.</span></span>
<span class="line" id="L2713">        bit_or,</span>
<span class="line" id="L2714">        <span class="tok-comment">/// `lhs orelse rhs`. main_token is the `orelse`.</span></span>
<span class="line" id="L2715">        @&quot;orelse&quot;,</span>
<span class="line" id="L2716">        <span class="tok-comment">/// `lhs and rhs`. main_token is the `and`.</span></span>
<span class="line" id="L2717">        bool_and,</span>
<span class="line" id="L2718">        <span class="tok-comment">/// `lhs or rhs`. main_token is the `or`.</span></span>
<span class="line" id="L2719">        bool_or,</span>
<span class="line" id="L2720">        <span class="tok-comment">/// `op lhs`. rhs unused. main_token is op.</span></span>
<span class="line" id="L2721">        bool_not,</span>
<span class="line" id="L2722">        <span class="tok-comment">/// `op lhs`. rhs unused. main_token is op.</span></span>
<span class="line" id="L2723">        negation,</span>
<span class="line" id="L2724">        <span class="tok-comment">/// `op lhs`. rhs unused. main_token is op.</span></span>
<span class="line" id="L2725">        bit_not,</span>
<span class="line" id="L2726">        <span class="tok-comment">/// `op lhs`. rhs unused. main_token is op.</span></span>
<span class="line" id="L2727">        negation_wrap,</span>
<span class="line" id="L2728">        <span class="tok-comment">/// `op lhs`. rhs unused. main_token is op.</span></span>
<span class="line" id="L2729">        address_of,</span>
<span class="line" id="L2730">        <span class="tok-comment">/// `op lhs`. rhs unused. main_token is op.</span></span>
<span class="line" id="L2731">        @&quot;try&quot;,</span>
<span class="line" id="L2732">        <span class="tok-comment">/// `op lhs`. rhs unused. main_token is op.</span></span>
<span class="line" id="L2733">        @&quot;await&quot;,</span>
<span class="line" id="L2734">        <span class="tok-comment">/// `?lhs`. rhs unused. main_token is the `?`.</span></span>
<span class="line" id="L2735">        optional_type,</span>
<span class="line" id="L2736">        <span class="tok-comment">/// `[lhs]rhs`.</span></span>
<span class="line" id="L2737">        array_type,</span>
<span class="line" id="L2738">        <span class="tok-comment">/// `[lhs:a]b`. `ArrayTypeSentinel[rhs]`.</span></span>
<span class="line" id="L2739">        array_type_sentinel,</span>
<span class="line" id="L2740">        <span class="tok-comment">/// `[*]align(lhs) rhs`. lhs can be omitted.</span></span>
<span class="line" id="L2741">        <span class="tok-comment">/// `*align(lhs) rhs`. lhs can be omitted.</span></span>
<span class="line" id="L2742">        <span class="tok-comment">/// `[]rhs`.</span></span>
<span class="line" id="L2743">        <span class="tok-comment">/// main_token is the asterisk if a pointer or the lbracket if a slice</span></span>
<span class="line" id="L2744">        <span class="tok-comment">/// main_token might be a ** token, which is shared with a parent/child</span></span>
<span class="line" id="L2745">        <span class="tok-comment">/// pointer type and may require special handling.</span></span>
<span class="line" id="L2746">        ptr_type_aligned,</span>
<span class="line" id="L2747">        <span class="tok-comment">/// `[*:lhs]rhs`. lhs can be omitted.</span></span>
<span class="line" id="L2748">        <span class="tok-comment">/// `*rhs`.</span></span>
<span class="line" id="L2749">        <span class="tok-comment">/// `[:lhs]rhs`.</span></span>
<span class="line" id="L2750">        <span class="tok-comment">/// main_token is the asterisk if a pointer or the lbracket if a slice</span></span>
<span class="line" id="L2751">        <span class="tok-comment">/// main_token might be a ** token, which is shared with a parent/child</span></span>
<span class="line" id="L2752">        <span class="tok-comment">/// pointer type and may require special handling.</span></span>
<span class="line" id="L2753">        ptr_type_sentinel,</span>
<span class="line" id="L2754">        <span class="tok-comment">/// lhs is index into ptr_type. rhs is the element type expression.</span></span>
<span class="line" id="L2755">        <span class="tok-comment">/// main_token is the asterisk if a pointer or the lbracket if a slice</span></span>
<span class="line" id="L2756">        <span class="tok-comment">/// main_token might be a ** token, which is shared with a parent/child</span></span>
<span class="line" id="L2757">        <span class="tok-comment">/// pointer type and may require special handling.</span></span>
<span class="line" id="L2758">        ptr_type,</span>
<span class="line" id="L2759">        <span class="tok-comment">/// lhs is index into ptr_type_bit_range. rhs is the element type expression.</span></span>
<span class="line" id="L2760">        <span class="tok-comment">/// main_token is the asterisk if a pointer or the lbracket if a slice</span></span>
<span class="line" id="L2761">        <span class="tok-comment">/// main_token might be a ** token, which is shared with a parent/child</span></span>
<span class="line" id="L2762">        <span class="tok-comment">/// pointer type and may require special handling.</span></span>
<span class="line" id="L2763">        ptr_type_bit_range,</span>
<span class="line" id="L2764">        <span class="tok-comment">/// `lhs[rhs..]`</span></span>
<span class="line" id="L2765">        <span class="tok-comment">/// main_token is the lbracket.</span></span>
<span class="line" id="L2766">        slice_open,</span>
<span class="line" id="L2767">        <span class="tok-comment">/// `lhs[b..c]`. rhs is index into Slice</span></span>
<span class="line" id="L2768">        <span class="tok-comment">/// main_token is the lbracket.</span></span>
<span class="line" id="L2769">        slice,</span>
<span class="line" id="L2770">        <span class="tok-comment">/// `lhs[b..c :d]`. rhs is index into SliceSentinel</span></span>
<span class="line" id="L2771">        <span class="tok-comment">/// main_token is the lbracket.</span></span>
<span class="line" id="L2772">        slice_sentinel,</span>
<span class="line" id="L2773">        <span class="tok-comment">/// `lhs.*`. rhs is unused.</span></span>
<span class="line" id="L2774">        deref,</span>
<span class="line" id="L2775">        <span class="tok-comment">/// `lhs[rhs]`.</span></span>
<span class="line" id="L2776">        array_access,</span>
<span class="line" id="L2777">        <span class="tok-comment">/// `lhs{rhs}`. rhs can be omitted.</span></span>
<span class="line" id="L2778">        array_init_one,</span>
<span class="line" id="L2779">        <span class="tok-comment">/// `lhs{rhs,}`. rhs can *not* be omitted</span></span>
<span class="line" id="L2780">        array_init_one_comma,</span>
<span class="line" id="L2781">        <span class="tok-comment">/// `.{lhs, rhs}`. lhs and rhs can be omitted.</span></span>
<span class="line" id="L2782">        array_init_dot_two,</span>
<span class="line" id="L2783">        <span class="tok-comment">/// Same as `array_init_dot_two` except there is known to be a trailing comma</span></span>
<span class="line" id="L2784">        <span class="tok-comment">/// before the final rbrace.</span></span>
<span class="line" id="L2785">        array_init_dot_two_comma,</span>
<span class="line" id="L2786">        <span class="tok-comment">/// `.{a, b}`. `sub_list[lhs..rhs]`.</span></span>
<span class="line" id="L2787">        array_init_dot,</span>
<span class="line" id="L2788">        <span class="tok-comment">/// Same as `array_init_dot` except there is known to be a trailing comma</span></span>
<span class="line" id="L2789">        <span class="tok-comment">/// before the final rbrace.</span></span>
<span class="line" id="L2790">        array_init_dot_comma,</span>
<span class="line" id="L2791">        <span class="tok-comment">/// `lhs{a, b}`. `sub_range_list[rhs]`. lhs can be omitted which means `.{a, b}`.</span></span>
<span class="line" id="L2792">        array_init,</span>
<span class="line" id="L2793">        <span class="tok-comment">/// Same as `array_init` except there is known to be a trailing comma</span></span>
<span class="line" id="L2794">        <span class="tok-comment">/// before the final rbrace.</span></span>
<span class="line" id="L2795">        array_init_comma,</span>
<span class="line" id="L2796">        <span class="tok-comment">/// `lhs{.a = rhs}`. rhs can be omitted making it empty.</span></span>
<span class="line" id="L2797">        <span class="tok-comment">/// main_token is the lbrace.</span></span>
<span class="line" id="L2798">        struct_init_one,</span>
<span class="line" id="L2799">        <span class="tok-comment">/// `lhs{.a = rhs,}`. rhs can *not* be omitted.</span></span>
<span class="line" id="L2800">        <span class="tok-comment">/// main_token is the lbrace.</span></span>
<span class="line" id="L2801">        struct_init_one_comma,</span>
<span class="line" id="L2802">        <span class="tok-comment">/// `.{.a = lhs, .b = rhs}`. lhs and rhs can be omitted.</span></span>
<span class="line" id="L2803">        <span class="tok-comment">/// main_token is the lbrace.</span></span>
<span class="line" id="L2804">        <span class="tok-comment">/// No trailing comma before the rbrace.</span></span>
<span class="line" id="L2805">        struct_init_dot_two,</span>
<span class="line" id="L2806">        <span class="tok-comment">/// Same as `struct_init_dot_two` except there is known to be a trailing comma</span></span>
<span class="line" id="L2807">        <span class="tok-comment">/// before the final rbrace.</span></span>
<span class="line" id="L2808">        struct_init_dot_two_comma,</span>
<span class="line" id="L2809">        <span class="tok-comment">/// `.{.a = b, .c = d}`. `sub_list[lhs..rhs]`.</span></span>
<span class="line" id="L2810">        <span class="tok-comment">/// main_token is the lbrace.</span></span>
<span class="line" id="L2811">        struct_init_dot,</span>
<span class="line" id="L2812">        <span class="tok-comment">/// Same as `struct_init_dot` except there is known to be a trailing comma</span></span>
<span class="line" id="L2813">        <span class="tok-comment">/// before the final rbrace.</span></span>
<span class="line" id="L2814">        struct_init_dot_comma,</span>
<span class="line" id="L2815">        <span class="tok-comment">/// `lhs{.a = b, .c = d}`. `sub_range_list[rhs]`.</span></span>
<span class="line" id="L2816">        <span class="tok-comment">/// lhs can be omitted which means `.{.a = b, .c = d}`.</span></span>
<span class="line" id="L2817">        <span class="tok-comment">/// main_token is the lbrace.</span></span>
<span class="line" id="L2818">        struct_init,</span>
<span class="line" id="L2819">        <span class="tok-comment">/// Same as `struct_init` except there is known to be a trailing comma</span></span>
<span class="line" id="L2820">        <span class="tok-comment">/// before the final rbrace.</span></span>
<span class="line" id="L2821">        struct_init_comma,</span>
<span class="line" id="L2822">        <span class="tok-comment">/// `lhs(rhs)`. rhs can be omitted.</span></span>
<span class="line" id="L2823">        <span class="tok-comment">/// main_token is the lparen.</span></span>
<span class="line" id="L2824">        call_one,</span>
<span class="line" id="L2825">        <span class="tok-comment">/// `lhs(rhs,)`. rhs can be omitted.</span></span>
<span class="line" id="L2826">        <span class="tok-comment">/// main_token is the lparen.</span></span>
<span class="line" id="L2827">        call_one_comma,</span>
<span class="line" id="L2828">        <span class="tok-comment">/// `async lhs(rhs)`. rhs can be omitted.</span></span>
<span class="line" id="L2829">        async_call_one,</span>
<span class="line" id="L2830">        <span class="tok-comment">/// `async lhs(rhs,)`.</span></span>
<span class="line" id="L2831">        async_call_one_comma,</span>
<span class="line" id="L2832">        <span class="tok-comment">/// `lhs(a, b, c)`. `SubRange[rhs]`.</span></span>
<span class="line" id="L2833">        <span class="tok-comment">/// main_token is the `(`.</span></span>
<span class="line" id="L2834">        call,</span>
<span class="line" id="L2835">        <span class="tok-comment">/// `lhs(a, b, c,)`. `SubRange[rhs]`.</span></span>
<span class="line" id="L2836">        <span class="tok-comment">/// main_token is the `(`.</span></span>
<span class="line" id="L2837">        call_comma,</span>
<span class="line" id="L2838">        <span class="tok-comment">/// `async lhs(a, b, c)`. `SubRange[rhs]`.</span></span>
<span class="line" id="L2839">        <span class="tok-comment">/// main_token is the `(`.</span></span>
<span class="line" id="L2840">        async_call,</span>
<span class="line" id="L2841">        <span class="tok-comment">/// `async lhs(a, b, c,)`. `SubRange[rhs]`.</span></span>
<span class="line" id="L2842">        <span class="tok-comment">/// main_token is the `(`.</span></span>
<span class="line" id="L2843">        async_call_comma,</span>
<span class="line" id="L2844">        <span class="tok-comment">/// `switch(lhs) {}`. `SubRange[rhs]`.</span></span>
<span class="line" id="L2845">        @&quot;switch&quot;,</span>
<span class="line" id="L2846">        <span class="tok-comment">/// Same as switch except there is known to be a trailing comma</span></span>
<span class="line" id="L2847">        <span class="tok-comment">/// before the final rbrace</span></span>
<span class="line" id="L2848">        switch_comma,</span>
<span class="line" id="L2849">        <span class="tok-comment">/// `lhs =&gt; rhs`. If lhs is omitted it means `else`.</span></span>
<span class="line" id="L2850">        <span class="tok-comment">/// main_token is the `=&gt;`</span></span>
<span class="line" id="L2851">        switch_case_one,</span>
<span class="line" id="L2852">        <span class="tok-comment">/// `a, b, c =&gt; rhs`. `SubRange[lhs]`.</span></span>
<span class="line" id="L2853">        <span class="tok-comment">/// main_token is the `=&gt;`</span></span>
<span class="line" id="L2854">        switch_case,</span>
<span class="line" id="L2855">        <span class="tok-comment">/// `lhs...rhs`.</span></span>
<span class="line" id="L2856">        switch_range,</span>
<span class="line" id="L2857">        <span class="tok-comment">/// `while (lhs) rhs`.</span></span>
<span class="line" id="L2858">        <span class="tok-comment">/// `while (lhs) |x| rhs`.</span></span>
<span class="line" id="L2859">        while_simple,</span>
<span class="line" id="L2860">        <span class="tok-comment">/// `while (lhs) : (a) b`. `WhileCont[rhs]`.</span></span>
<span class="line" id="L2861">        <span class="tok-comment">/// `while (lhs) : (a) b`. `WhileCont[rhs]`.</span></span>
<span class="line" id="L2862">        while_cont,</span>
<span class="line" id="L2863">        <span class="tok-comment">/// `while (lhs) : (a) b else c`. `While[rhs]`.</span></span>
<span class="line" id="L2864">        <span class="tok-comment">/// `while (lhs) |x| : (a) b else c`. `While[rhs]`.</span></span>
<span class="line" id="L2865">        <span class="tok-comment">/// `while (lhs) |x| : (a) b else |y| c`. `While[rhs]`.</span></span>
<span class="line" id="L2866">        @&quot;while&quot;,</span>
<span class="line" id="L2867">        <span class="tok-comment">/// `for (lhs) rhs`.</span></span>
<span class="line" id="L2868">        for_simple,</span>
<span class="line" id="L2869">        <span class="tok-comment">/// `for (lhs) a else b`. `if_list[rhs]`.</span></span>
<span class="line" id="L2870">        @&quot;for&quot;,</span>
<span class="line" id="L2871">        <span class="tok-comment">/// `if (lhs) rhs`.</span></span>
<span class="line" id="L2872">        <span class="tok-comment">/// `if (lhs) |a| rhs`.</span></span>
<span class="line" id="L2873">        if_simple,</span>
<span class="line" id="L2874">        <span class="tok-comment">/// `if (lhs) a else b`. `If[rhs]`.</span></span>
<span class="line" id="L2875">        <span class="tok-comment">/// `if (lhs) |x| a else b`. `If[rhs]`.</span></span>
<span class="line" id="L2876">        <span class="tok-comment">/// `if (lhs) |x| a else |y| b`. `If[rhs]`.</span></span>
<span class="line" id="L2877">        @&quot;if&quot;,</span>
<span class="line" id="L2878">        <span class="tok-comment">/// `suspend lhs`. lhs can be omitted. rhs is unused.</span></span>
<span class="line" id="L2879">        @&quot;suspend&quot;,</span>
<span class="line" id="L2880">        <span class="tok-comment">/// `resume lhs`. rhs is unused.</span></span>
<span class="line" id="L2881">        @&quot;resume&quot;,</span>
<span class="line" id="L2882">        <span class="tok-comment">/// `continue`. lhs is token index of label if any. rhs is unused.</span></span>
<span class="line" id="L2883">        @&quot;continue&quot;,</span>
<span class="line" id="L2884">        <span class="tok-comment">/// `break :lhs rhs`</span></span>
<span class="line" id="L2885">        <span class="tok-comment">/// both lhs and rhs may be omitted.</span></span>
<span class="line" id="L2886">        @&quot;break&quot;,</span>
<span class="line" id="L2887">        <span class="tok-comment">/// `return lhs`. lhs can be omitted. rhs is unused.</span></span>
<span class="line" id="L2888">        @&quot;return&quot;,</span>
<span class="line" id="L2889">        <span class="tok-comment">/// `fn(a: lhs) rhs`. lhs can be omitted.</span></span>
<span class="line" id="L2890">        <span class="tok-comment">/// anytype and ... parameters are omitted from the AST tree.</span></span>
<span class="line" id="L2891">        <span class="tok-comment">/// main_token is the `fn` keyword.</span></span>
<span class="line" id="L2892">        <span class="tok-comment">/// extern function declarations use this tag.</span></span>
<span class="line" id="L2893">        fn_proto_simple,</span>
<span class="line" id="L2894">        <span class="tok-comment">/// `fn(a: b, c: d) rhs`. `sub_range_list[lhs]`.</span></span>
<span class="line" id="L2895">        <span class="tok-comment">/// anytype and ... parameters are omitted from the AST tree.</span></span>
<span class="line" id="L2896">        <span class="tok-comment">/// main_token is the `fn` keyword.</span></span>
<span class="line" id="L2897">        <span class="tok-comment">/// extern function declarations use this tag.</span></span>
<span class="line" id="L2898">        fn_proto_multi,</span>
<span class="line" id="L2899">        <span class="tok-comment">/// `fn(a: b) rhs addrspace(e) linksection(f) callconv(g)`. `FnProtoOne[lhs]`.</span></span>
<span class="line" id="L2900">        <span class="tok-comment">/// zero or one parameters.</span></span>
<span class="line" id="L2901">        <span class="tok-comment">/// anytype and ... parameters are omitted from the AST tree.</span></span>
<span class="line" id="L2902">        <span class="tok-comment">/// main_token is the `fn` keyword.</span></span>
<span class="line" id="L2903">        <span class="tok-comment">/// extern function declarations use this tag.</span></span>
<span class="line" id="L2904">        fn_proto_one,</span>
<span class="line" id="L2905">        <span class="tok-comment">/// `fn(a: b, c: d) rhs addrspace(e) linksection(f) callconv(g)`. `FnProto[lhs]`.</span></span>
<span class="line" id="L2906">        <span class="tok-comment">/// anytype and ... parameters are omitted from the AST tree.</span></span>
<span class="line" id="L2907">        <span class="tok-comment">/// main_token is the `fn` keyword.</span></span>
<span class="line" id="L2908">        <span class="tok-comment">/// extern function declarations use this tag.</span></span>
<span class="line" id="L2909">        fn_proto,</span>
<span class="line" id="L2910">        <span class="tok-comment">/// lhs is the fn_proto.</span></span>
<span class="line" id="L2911">        <span class="tok-comment">/// rhs is the function body block.</span></span>
<span class="line" id="L2912">        <span class="tok-comment">/// Note that extern function declarations use the fn_proto tags rather</span></span>
<span class="line" id="L2913">        <span class="tok-comment">/// than this one.</span></span>
<span class="line" id="L2914">        fn_decl,</span>
<span class="line" id="L2915">        <span class="tok-comment">/// `anyframe-&gt;rhs`. main_token is `anyframe`. `lhs` is arrow token index.</span></span>
<span class="line" id="L2916">        anyframe_type,</span>
<span class="line" id="L2917">        <span class="tok-comment">/// Both lhs and rhs unused.</span></span>
<span class="line" id="L2918">        anyframe_literal,</span>
<span class="line" id="L2919">        <span class="tok-comment">/// Both lhs and rhs unused.</span></span>
<span class="line" id="L2920">        char_literal,</span>
<span class="line" id="L2921">        <span class="tok-comment">/// Both lhs and rhs unused.</span></span>
<span class="line" id="L2922">        integer_literal,</span>
<span class="line" id="L2923">        <span class="tok-comment">/// Both lhs and rhs unused.</span></span>
<span class="line" id="L2924">        float_literal,</span>
<span class="line" id="L2925">        <span class="tok-comment">/// Both lhs and rhs unused.</span></span>
<span class="line" id="L2926">        unreachable_literal,</span>
<span class="line" id="L2927">        <span class="tok-comment">/// Both lhs and rhs unused.</span></span>
<span class="line" id="L2928">        <span class="tok-comment">/// Most identifiers will not have explicit AST nodes, however for expressions</span></span>
<span class="line" id="L2929">        <span class="tok-comment">/// which could be one of many different kinds of AST nodes, there will be an</span></span>
<span class="line" id="L2930">        <span class="tok-comment">/// identifier AST node for it.</span></span>
<span class="line" id="L2931">        identifier,</span>
<span class="line" id="L2932">        <span class="tok-comment">/// lhs is the dot token index, rhs unused, main_token is the identifier.</span></span>
<span class="line" id="L2933">        enum_literal,</span>
<span class="line" id="L2934">        <span class="tok-comment">/// main_token is the string literal token</span></span>
<span class="line" id="L2935">        <span class="tok-comment">/// Both lhs and rhs unused.</span></span>
<span class="line" id="L2936">        string_literal,</span>
<span class="line" id="L2937">        <span class="tok-comment">/// main_token is the first token index (redundant with lhs)</span></span>
<span class="line" id="L2938">        <span class="tok-comment">/// lhs is the first token index; rhs is the last token index.</span></span>
<span class="line" id="L2939">        <span class="tok-comment">/// Could be a series of multiline_string_literal_line tokens, or a single</span></span>
<span class="line" id="L2940">        <span class="tok-comment">/// string_literal token.</span></span>
<span class="line" id="L2941">        multiline_string_literal,</span>
<span class="line" id="L2942">        <span class="tok-comment">/// `(lhs)`. main_token is the `(`; rhs is the token index of the `)`.</span></span>
<span class="line" id="L2943">        grouped_expression,</span>
<span class="line" id="L2944">        <span class="tok-comment">/// `@a(lhs, rhs)`. lhs and rhs may be omitted.</span></span>
<span class="line" id="L2945">        <span class="tok-comment">/// main_token is the builtin token.</span></span>
<span class="line" id="L2946">        builtin_call_two,</span>
<span class="line" id="L2947">        <span class="tok-comment">/// Same as builtin_call_two but there is known to be a trailing comma before the rparen.</span></span>
<span class="line" id="L2948">        builtin_call_two_comma,</span>
<span class="line" id="L2949">        <span class="tok-comment">/// `@a(b, c)`. `sub_list[lhs..rhs]`.</span></span>
<span class="line" id="L2950">        <span class="tok-comment">/// main_token is the builtin token.</span></span>
<span class="line" id="L2951">        builtin_call,</span>
<span class="line" id="L2952">        <span class="tok-comment">/// Same as builtin_call but there is known to be a trailing comma before the rparen.</span></span>
<span class="line" id="L2953">        builtin_call_comma,</span>
<span class="line" id="L2954">        <span class="tok-comment">/// `error{a, b}`.</span></span>
<span class="line" id="L2955">        <span class="tok-comment">/// rhs is the rbrace, lhs is unused.</span></span>
<span class="line" id="L2956">        error_set_decl,</span>
<span class="line" id="L2957">        <span class="tok-comment">/// `struct {}`, `union {}`, `opaque {}`, `enum {}`. `extra_data[lhs..rhs]`.</span></span>
<span class="line" id="L2958">        <span class="tok-comment">/// main_token is `struct`, `union`, `opaque`, `enum` keyword.</span></span>
<span class="line" id="L2959">        container_decl,</span>
<span class="line" id="L2960">        <span class="tok-comment">/// Same as ContainerDecl but there is known to be a trailing comma</span></span>
<span class="line" id="L2961">        <span class="tok-comment">/// or semicolon before the rbrace.</span></span>
<span class="line" id="L2962">        container_decl_trailing,</span>
<span class="line" id="L2963">        <span class="tok-comment">/// `struct {lhs, rhs}`, `union {lhs, rhs}`, `opaque {lhs, rhs}`, `enum {lhs, rhs}`.</span></span>
<span class="line" id="L2964">        <span class="tok-comment">/// lhs or rhs can be omitted.</span></span>
<span class="line" id="L2965">        <span class="tok-comment">/// main_token is `struct`, `union`, `opaque`, `enum` keyword.</span></span>
<span class="line" id="L2966">        container_decl_two,</span>
<span class="line" id="L2967">        <span class="tok-comment">/// Same as ContainerDeclTwo except there is known to be a trailing comma</span></span>
<span class="line" id="L2968">        <span class="tok-comment">/// or semicolon before the rbrace.</span></span>
<span class="line" id="L2969">        container_decl_two_trailing,</span>
<span class="line" id="L2970">        <span class="tok-comment">/// `struct(lhs)` / `union(lhs)` / `enum(lhs)`. `SubRange[rhs]`.</span></span>
<span class="line" id="L2971">        container_decl_arg,</span>
<span class="line" id="L2972">        <span class="tok-comment">/// Same as container_decl_arg but there is known to be a trailing</span></span>
<span class="line" id="L2973">        <span class="tok-comment">/// comma or semicolon before the rbrace.</span></span>
<span class="line" id="L2974">        container_decl_arg_trailing,</span>
<span class="line" id="L2975">        <span class="tok-comment">/// `union(enum) {}`. `sub_list[lhs..rhs]`.</span></span>
<span class="line" id="L2976">        <span class="tok-comment">/// Note that tagged unions with explicitly provided enums are represented</span></span>
<span class="line" id="L2977">        <span class="tok-comment">/// by `container_decl_arg`.</span></span>
<span class="line" id="L2978">        tagged_union,</span>
<span class="line" id="L2979">        <span class="tok-comment">/// Same as tagged_union but there is known to be a trailing comma</span></span>
<span class="line" id="L2980">        <span class="tok-comment">/// or semicolon before the rbrace.</span></span>
<span class="line" id="L2981">        tagged_union_trailing,</span>
<span class="line" id="L2982">        <span class="tok-comment">/// `union(enum) {lhs, rhs}`. lhs or rhs may be omitted.</span></span>
<span class="line" id="L2983">        <span class="tok-comment">/// Note that tagged unions with explicitly provided enums are represented</span></span>
<span class="line" id="L2984">        <span class="tok-comment">/// by `container_decl_arg`.</span></span>
<span class="line" id="L2985">        tagged_union_two,</span>
<span class="line" id="L2986">        <span class="tok-comment">/// Same as tagged_union_two but there is known to be a trailing comma</span></span>
<span class="line" id="L2987">        <span class="tok-comment">/// or semicolon before the rbrace.</span></span>
<span class="line" id="L2988">        tagged_union_two_trailing,</span>
<span class="line" id="L2989">        <span class="tok-comment">/// `union(enum(lhs)) {}`. `SubRange[rhs]`.</span></span>
<span class="line" id="L2990">        tagged_union_enum_tag,</span>
<span class="line" id="L2991">        <span class="tok-comment">/// Same as tagged_union_enum_tag but there is known to be a trailing comma</span></span>
<span class="line" id="L2992">        <span class="tok-comment">/// or semicolon before the rbrace.</span></span>
<span class="line" id="L2993">        tagged_union_enum_tag_trailing,</span>
<span class="line" id="L2994">        <span class="tok-comment">/// `a: lhs = rhs,`. lhs and rhs can be omitted.</span></span>
<span class="line" id="L2995">        <span class="tok-comment">/// main_token is the field name identifier.</span></span>
<span class="line" id="L2996">        <span class="tok-comment">/// lastToken() does not include the possible trailing comma.</span></span>
<span class="line" id="L2997">        container_field_init,</span>
<span class="line" id="L2998">        <span class="tok-comment">/// `a: lhs align(rhs),`. rhs can be omitted.</span></span>
<span class="line" id="L2999">        <span class="tok-comment">/// main_token is the field name identifier.</span></span>
<span class="line" id="L3000">        <span class="tok-comment">/// lastToken() does not include the possible trailing comma.</span></span>
<span class="line" id="L3001">        container_field_align,</span>
<span class="line" id="L3002">        <span class="tok-comment">/// `a: lhs align(c) = d,`. `container_field_list[rhs]`.</span></span>
<span class="line" id="L3003">        <span class="tok-comment">/// main_token is the field name identifier.</span></span>
<span class="line" id="L3004">        <span class="tok-comment">/// lastToken() does not include the possible trailing comma.</span></span>
<span class="line" id="L3005">        container_field,</span>
<span class="line" id="L3006">        <span class="tok-comment">/// `comptime lhs`. rhs unused.</span></span>
<span class="line" id="L3007">        @&quot;comptime&quot;,</span>
<span class="line" id="L3008">        <span class="tok-comment">/// `nosuspend lhs`. rhs unused.</span></span>
<span class="line" id="L3009">        @&quot;nosuspend&quot;,</span>
<span class="line" id="L3010">        <span class="tok-comment">/// `{lhs rhs}`. rhs or lhs can be omitted.</span></span>
<span class="line" id="L3011">        <span class="tok-comment">/// main_token points at the lbrace.</span></span>
<span class="line" id="L3012">        block_two,</span>
<span class="line" id="L3013">        <span class="tok-comment">/// Same as block_two but there is known to be a semicolon before the rbrace.</span></span>
<span class="line" id="L3014">        block_two_semicolon,</span>
<span class="line" id="L3015">        <span class="tok-comment">/// `{}`. `sub_list[lhs..rhs]`.</span></span>
<span class="line" id="L3016">        <span class="tok-comment">/// main_token points at the lbrace.</span></span>
<span class="line" id="L3017">        block,</span>
<span class="line" id="L3018">        <span class="tok-comment">/// Same as block but there is known to be a semicolon before the rbrace.</span></span>
<span class="line" id="L3019">        block_semicolon,</span>
<span class="line" id="L3020">        <span class="tok-comment">/// `asm(lhs)`. rhs is the token index of the rparen.</span></span>
<span class="line" id="L3021">        asm_simple,</span>
<span class="line" id="L3022">        <span class="tok-comment">/// `asm(lhs, a)`. `Asm[rhs]`.</span></span>
<span class="line" id="L3023">        @&quot;asm&quot;,</span>
<span class="line" id="L3024">        <span class="tok-comment">/// `[a] &quot;b&quot; (c)`. lhs is 0, rhs is token index of the rparen.</span></span>
<span class="line" id="L3025">        <span class="tok-comment">/// `[a] &quot;b&quot; (-&gt; lhs)`. rhs is token index of the rparen.</span></span>
<span class="line" id="L3026">        <span class="tok-comment">/// main_token is `a`.</span></span>
<span class="line" id="L3027">        asm_output,</span>
<span class="line" id="L3028">        <span class="tok-comment">/// `[a] &quot;b&quot; (lhs)`. rhs is token index of the rparen.</span></span>
<span class="line" id="L3029">        <span class="tok-comment">/// main_token is `a`.</span></span>
<span class="line" id="L3030">        asm_input,</span>
<span class="line" id="L3031">        <span class="tok-comment">/// `error.a`. lhs is token index of `.`. rhs is token index of `a`.</span></span>
<span class="line" id="L3032">        error_value,</span>
<span class="line" id="L3033">        <span class="tok-comment">/// `lhs!rhs`. main_token is the `!`.</span></span>
<span class="line" id="L3034">        error_union,</span>
<span class="line" id="L3035"></span>
<span class="line" id="L3036">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">isContainerField</span>(tag: Tag) <span class="tok-type">bool</span> {</span>
<span class="line" id="L3037">            <span class="tok-kw">return</span> <span class="tok-kw">switch</span> (tag) {</span>
<span class="line" id="L3038">                .container_field_init,</span>
<span class="line" id="L3039">                .container_field_align,</span>
<span class="line" id="L3040">                .container_field,</span>
<span class="line" id="L3041">                =&gt; <span class="tok-null">true</span>,</span>
<span class="line" id="L3042"></span>
<span class="line" id="L3043">                <span class="tok-kw">else</span> =&gt; <span class="tok-null">false</span>,</span>
<span class="line" id="L3044">            };</span>
<span class="line" id="L3045">        }</span>
<span class="line" id="L3046">    };</span>
<span class="line" id="L3047"></span>
<span class="line" id="L3048">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> Data = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L3049">        lhs: Index,</span>
<span class="line" id="L3050">        rhs: Index,</span>
<span class="line" id="L3051">    };</span>
<span class="line" id="L3052"></span>
<span class="line" id="L3053">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> LocalVarDecl = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L3054">        type_node: Index,</span>
<span class="line" id="L3055">        align_node: Index,</span>
<span class="line" id="L3056">    };</span>
<span class="line" id="L3057"></span>
<span class="line" id="L3058">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> ArrayTypeSentinel = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L3059">        elem_type: Index,</span>
<span class="line" id="L3060">        sentinel: Index,</span>
<span class="line" id="L3061">    };</span>
<span class="line" id="L3062"></span>
<span class="line" id="L3063">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> PtrType = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L3064">        sentinel: Index,</span>
<span class="line" id="L3065">        align_node: Index,</span>
<span class="line" id="L3066">        addrspace_node: Index,</span>
<span class="line" id="L3067">    };</span>
<span class="line" id="L3068"></span>
<span class="line" id="L3069">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> PtrTypeBitRange = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L3070">        sentinel: Index,</span>
<span class="line" id="L3071">        align_node: Index,</span>
<span class="line" id="L3072">        addrspace_node: Index,</span>
<span class="line" id="L3073">        bit_range_start: Index,</span>
<span class="line" id="L3074">        bit_range_end: Index,</span>
<span class="line" id="L3075">    };</span>
<span class="line" id="L3076"></span>
<span class="line" id="L3077">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> SubRange = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L3078">        <span class="tok-comment">/// Index into sub_list.</span></span>
<span class="line" id="L3079">        start: Index,</span>
<span class="line" id="L3080">        <span class="tok-comment">/// Index into sub_list.</span></span>
<span class="line" id="L3081">        end: Index,</span>
<span class="line" id="L3082">    };</span>
<span class="line" id="L3083"></span>
<span class="line" id="L3084">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> If = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L3085">        then_expr: Index,</span>
<span class="line" id="L3086">        else_expr: Index,</span>
<span class="line" id="L3087">    };</span>
<span class="line" id="L3088"></span>
<span class="line" id="L3089">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> ContainerField = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L3090">        value_expr: Index,</span>
<span class="line" id="L3091">        align_expr: Index,</span>
<span class="line" id="L3092">    };</span>
<span class="line" id="L3093"></span>
<span class="line" id="L3094">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> GlobalVarDecl = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L3095">        <span class="tok-comment">/// Populated if there is an explicit type ascription.</span></span>
<span class="line" id="L3096">        type_node: Index,</span>
<span class="line" id="L3097">        <span class="tok-comment">/// Populated if align(A) is present.</span></span>
<span class="line" id="L3098">        align_node: Index,</span>
<span class="line" id="L3099">        <span class="tok-comment">/// Populated if addrspace(A) is present.</span></span>
<span class="line" id="L3100">        addrspace_node: Index,</span>
<span class="line" id="L3101">        <span class="tok-comment">/// Populated if linksection(A) is present.</span></span>
<span class="line" id="L3102">        section_node: Index,</span>
<span class="line" id="L3103">    };</span>
<span class="line" id="L3104"></span>
<span class="line" id="L3105">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> Slice = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L3106">        start: Index,</span>
<span class="line" id="L3107">        end: Index,</span>
<span class="line" id="L3108">    };</span>
<span class="line" id="L3109"></span>
<span class="line" id="L3110">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> SliceSentinel = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L3111">        start: Index,</span>
<span class="line" id="L3112">        <span class="tok-comment">/// May be 0 if the slice is &quot;open&quot;</span></span>
<span class="line" id="L3113">        end: Index,</span>
<span class="line" id="L3114">        sentinel: Index,</span>
<span class="line" id="L3115">    };</span>
<span class="line" id="L3116"></span>
<span class="line" id="L3117">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> While = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L3118">        cont_expr: Index,</span>
<span class="line" id="L3119">        then_expr: Index,</span>
<span class="line" id="L3120">        else_expr: Index,</span>
<span class="line" id="L3121">    };</span>
<span class="line" id="L3122"></span>
<span class="line" id="L3123">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> WhileCont = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L3124">        cont_expr: Index,</span>
<span class="line" id="L3125">        then_expr: Index,</span>
<span class="line" id="L3126">    };</span>
<span class="line" id="L3127"></span>
<span class="line" id="L3128">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> FnProtoOne = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L3129">        <span class="tok-comment">/// Populated if there is exactly 1 parameter. Otherwise there are 0 parameters.</span></span>
<span class="line" id="L3130">        param: Index,</span>
<span class="line" id="L3131">        <span class="tok-comment">/// Populated if align(A) is present.</span></span>
<span class="line" id="L3132">        align_expr: Index,</span>
<span class="line" id="L3133">        <span class="tok-comment">/// Populated if addrspace(A) is present.</span></span>
<span class="line" id="L3134">        addrspace_expr: Index,</span>
<span class="line" id="L3135">        <span class="tok-comment">/// Populated if linksection(A) is present.</span></span>
<span class="line" id="L3136">        section_expr: Index,</span>
<span class="line" id="L3137">        <span class="tok-comment">/// Populated if callconv(A) is present.</span></span>
<span class="line" id="L3138">        callconv_expr: Index,</span>
<span class="line" id="L3139">    };</span>
<span class="line" id="L3140"></span>
<span class="line" id="L3141">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> FnProto = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L3142">        params_start: Index,</span>
<span class="line" id="L3143">        params_end: Index,</span>
<span class="line" id="L3144">        <span class="tok-comment">/// Populated if align(A) is present.</span></span>
<span class="line" id="L3145">        align_expr: Index,</span>
<span class="line" id="L3146">        <span class="tok-comment">/// Populated if addrspace(A) is present.</span></span>
<span class="line" id="L3147">        addrspace_expr: Index,</span>
<span class="line" id="L3148">        <span class="tok-comment">/// Populated if linksection(A) is present.</span></span>
<span class="line" id="L3149">        section_expr: Index,</span>
<span class="line" id="L3150">        <span class="tok-comment">/// Populated if callconv(A) is present.</span></span>
<span class="line" id="L3151">        callconv_expr: Index,</span>
<span class="line" id="L3152">    };</span>
<span class="line" id="L3153"></span>
<span class="line" id="L3154">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> Asm = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L3155">        items_start: Index,</span>
<span class="line" id="L3156">        items_end: Index,</span>
<span class="line" id="L3157">        <span class="tok-comment">/// Needed to make lastToken() work.</span></span>
<span class="line" id="L3158">        rparen: TokenIndex,</span>
<span class="line" id="L3159">    };</span>
<span class="line" id="L3160">};</span>
<span class="line" id="L3161"></span>
</code></pre></body>
</html>