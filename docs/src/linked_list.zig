<!doctype html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">    <title>linked_list.zig - source view</title>
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
<span class="line" id="L2"><span class="tok-kw">const</span> debug = std.debug;</span>
<span class="line" id="L3"><span class="tok-kw">const</span> assert = debug.assert;</span>
<span class="line" id="L4"><span class="tok-kw">const</span> testing = std.testing;</span>
<span class="line" id="L5"><span class="tok-kw">const</span> mem = std.mem;</span>
<span class="line" id="L6"><span class="tok-kw">const</span> Allocator = mem.Allocator;</span>
<span class="line" id="L7"></span>
<span class="line" id="L8"><span class="tok-comment">/// A singly-linked list is headed by a single forward pointer. The elements</span></span>
<span class="line" id="L9"><span class="tok-comment">/// are singly linked for minimum space and pointer manipulation overhead at</span></span>
<span class="line" id="L10"><span class="tok-comment">/// the expense of O(n) removal for arbitrary elements. New elements can be</span></span>
<span class="line" id="L11"><span class="tok-comment">/// added to the list after an existing element or at the head of the list.</span></span>
<span class="line" id="L12"><span class="tok-comment">/// A singly-linked list may only be traversed in the forward direction.</span></span>
<span class="line" id="L13"><span class="tok-comment">/// Singly-linked lists are ideal for applications with large datasets and</span></span>
<span class="line" id="L14"><span class="tok-comment">/// few or no removals or for implementing a LIFO queue.</span></span>
<span class="line" id="L15"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">SinglyLinkedList</span>(<span class="tok-kw">comptime</span> T: <span class="tok-type">type</span>) <span class="tok-type">type</span> {</span>
<span class="line" id="L16">    <span class="tok-kw">return</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L17">        <span class="tok-kw">const</span> Self = <span class="tok-builtin">@This</span>();</span>
<span class="line" id="L18"></span>
<span class="line" id="L19">        <span class="tok-comment">/// Node inside the linked list wrapping the actual data.</span></span>
<span class="line" id="L20">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> Node = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L21">            next: ?*Node = <span class="tok-null">null</span>,</span>
<span class="line" id="L22">            data: T,</span>
<span class="line" id="L23"></span>
<span class="line" id="L24">            <span class="tok-kw">pub</span> <span class="tok-kw">const</span> Data = T;</span>
<span class="line" id="L25"></span>
<span class="line" id="L26">            <span class="tok-comment">/// Insert a new node after the current one.</span></span>
<span class="line" id="L27">            <span class="tok-comment">///</span></span>
<span class="line" id="L28">            <span class="tok-comment">/// Arguments:</span></span>
<span class="line" id="L29">            <span class="tok-comment">///     new_node: Pointer to the new node to insert.</span></span>
<span class="line" id="L30">            <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">insertAfter</span>(node: *Node, new_node: *Node) <span class="tok-type">void</span> {</span>
<span class="line" id="L31">                new_node.next = node.next;</span>
<span class="line" id="L32">                node.next = new_node;</span>
<span class="line" id="L33">            }</span>
<span class="line" id="L34"></span>
<span class="line" id="L35">            <span class="tok-comment">/// Remove a node from the list.</span></span>
<span class="line" id="L36">            <span class="tok-comment">///</span></span>
<span class="line" id="L37">            <span class="tok-comment">/// Arguments:</span></span>
<span class="line" id="L38">            <span class="tok-comment">///     node: Pointer to the node to be removed.</span></span>
<span class="line" id="L39">            <span class="tok-comment">/// Returns:</span></span>
<span class="line" id="L40">            <span class="tok-comment">///     node removed</span></span>
<span class="line" id="L41">            <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">removeNext</span>(node: *Node) ?*Node {</span>
<span class="line" id="L42">                <span class="tok-kw">const</span> next_node = node.next <span class="tok-kw">orelse</span> <span class="tok-kw">return</span> <span class="tok-null">null</span>;</span>
<span class="line" id="L43">                node.next = next_node.next;</span>
<span class="line" id="L44">                <span class="tok-kw">return</span> next_node;</span>
<span class="line" id="L45">            }</span>
<span class="line" id="L46"></span>
<span class="line" id="L47">            <span class="tok-comment">/// Iterate over the singly-linked list from this node, until the final node is found.</span></span>
<span class="line" id="L48">            <span class="tok-comment">/// This operation is O(N).</span></span>
<span class="line" id="L49">            <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">findLast</span>(node: *Node) *Node {</span>
<span class="line" id="L50">                <span class="tok-kw">var</span> it = node;</span>
<span class="line" id="L51">                <span class="tok-kw">while</span> (<span class="tok-null">true</span>) {</span>
<span class="line" id="L52">                    it = it.next <span class="tok-kw">orelse</span> <span class="tok-kw">return</span> it;</span>
<span class="line" id="L53">                }</span>
<span class="line" id="L54">            }</span>
<span class="line" id="L55"></span>
<span class="line" id="L56">            <span class="tok-comment">/// Iterate over each next node, returning the count of all nodes except the starting one.</span></span>
<span class="line" id="L57">            <span class="tok-comment">/// This operation is O(N).</span></span>
<span class="line" id="L58">            <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">countChildren</span>(node: *<span class="tok-kw">const</span> Node) <span class="tok-type">usize</span> {</span>
<span class="line" id="L59">                <span class="tok-kw">var</span> count: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L60">                <span class="tok-kw">var</span> it: ?*<span class="tok-kw">const</span> Node = node.next;</span>
<span class="line" id="L61">                <span class="tok-kw">while</span> (it) |n| : (it = n.next) {</span>
<span class="line" id="L62">                    count += <span class="tok-number">1</span>;</span>
<span class="line" id="L63">                }</span>
<span class="line" id="L64">                <span class="tok-kw">return</span> count;</span>
<span class="line" id="L65">            }</span>
<span class="line" id="L66">        };</span>
<span class="line" id="L67"></span>
<span class="line" id="L68">        first: ?*Node = <span class="tok-null">null</span>,</span>
<span class="line" id="L69"></span>
<span class="line" id="L70">        <span class="tok-comment">/// Insert a new node at the head.</span></span>
<span class="line" id="L71">        <span class="tok-comment">///</span></span>
<span class="line" id="L72">        <span class="tok-comment">/// Arguments:</span></span>
<span class="line" id="L73">        <span class="tok-comment">///     new_node: Pointer to the new node to insert.</span></span>
<span class="line" id="L74">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">prepend</span>(list: *Self, new_node: *Node) <span class="tok-type">void</span> {</span>
<span class="line" id="L75">            new_node.next = list.first;</span>
<span class="line" id="L76">            list.first = new_node;</span>
<span class="line" id="L77">        }</span>
<span class="line" id="L78"></span>
<span class="line" id="L79">        <span class="tok-comment">/// Remove a node from the list.</span></span>
<span class="line" id="L80">        <span class="tok-comment">///</span></span>
<span class="line" id="L81">        <span class="tok-comment">/// Arguments:</span></span>
<span class="line" id="L82">        <span class="tok-comment">///     node: Pointer to the node to be removed.</span></span>
<span class="line" id="L83">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">remove</span>(list: *Self, node: *Node) <span class="tok-type">void</span> {</span>
<span class="line" id="L84">            <span class="tok-kw">if</span> (list.first == node) {</span>
<span class="line" id="L85">                list.first = node.next;</span>
<span class="line" id="L86">            } <span class="tok-kw">else</span> {</span>
<span class="line" id="L87">                <span class="tok-kw">var</span> current_elm = list.first.?;</span>
<span class="line" id="L88">                <span class="tok-kw">while</span> (current_elm.next != node) {</span>
<span class="line" id="L89">                    current_elm = current_elm.next.?;</span>
<span class="line" id="L90">                }</span>
<span class="line" id="L91">                current_elm.next = node.next;</span>
<span class="line" id="L92">            }</span>
<span class="line" id="L93">        }</span>
<span class="line" id="L94"></span>
<span class="line" id="L95">        <span class="tok-comment">/// Remove and return the first node in the list.</span></span>
<span class="line" id="L96">        <span class="tok-comment">///</span></span>
<span class="line" id="L97">        <span class="tok-comment">/// Returns:</span></span>
<span class="line" id="L98">        <span class="tok-comment">///     A pointer to the first node in the list.</span></span>
<span class="line" id="L99">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">popFirst</span>(list: *Self) ?*Node {</span>
<span class="line" id="L100">            <span class="tok-kw">const</span> first = list.first <span class="tok-kw">orelse</span> <span class="tok-kw">return</span> <span class="tok-null">null</span>;</span>
<span class="line" id="L101">            list.first = first.next;</span>
<span class="line" id="L102">            <span class="tok-kw">return</span> first;</span>
<span class="line" id="L103">        }</span>
<span class="line" id="L104"></span>
<span class="line" id="L105">        <span class="tok-comment">/// Iterate over all nodes, returning the count.</span></span>
<span class="line" id="L106">        <span class="tok-comment">/// This operation is O(N).</span></span>
<span class="line" id="L107">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">len</span>(list: Self) <span class="tok-type">usize</span> {</span>
<span class="line" id="L108">            <span class="tok-kw">if</span> (list.first) |n| {</span>
<span class="line" id="L109">                <span class="tok-kw">return</span> <span class="tok-number">1</span> + n.countChildren();</span>
<span class="line" id="L110">            } <span class="tok-kw">else</span> {</span>
<span class="line" id="L111">                <span class="tok-kw">return</span> <span class="tok-number">0</span>;</span>
<span class="line" id="L112">            }</span>
<span class="line" id="L113">        }</span>
<span class="line" id="L114">    };</span>
<span class="line" id="L115">}</span>
<span class="line" id="L116"></span>
<span class="line" id="L117"><span class="tok-kw">test</span> <span class="tok-str">&quot;basic SinglyLinkedList test&quot;</span> {</span>
<span class="line" id="L118">    <span class="tok-kw">const</span> L = SinglyLinkedList(<span class="tok-type">u32</span>);</span>
<span class="line" id="L119">    <span class="tok-kw">var</span> list = L{};</span>
<span class="line" id="L120"></span>
<span class="line" id="L121">    <span class="tok-kw">try</span> testing.expect(list.len() == <span class="tok-number">0</span>);</span>
<span class="line" id="L122"></span>
<span class="line" id="L123">    <span class="tok-kw">var</span> one = L.Node{ .data = <span class="tok-number">1</span> };</span>
<span class="line" id="L124">    <span class="tok-kw">var</span> two = L.Node{ .data = <span class="tok-number">2</span> };</span>
<span class="line" id="L125">    <span class="tok-kw">var</span> three = L.Node{ .data = <span class="tok-number">3</span> };</span>
<span class="line" id="L126">    <span class="tok-kw">var</span> four = L.Node{ .data = <span class="tok-number">4</span> };</span>
<span class="line" id="L127">    <span class="tok-kw">var</span> five = L.Node{ .data = <span class="tok-number">5</span> };</span>
<span class="line" id="L128"></span>
<span class="line" id="L129">    list.prepend(&amp;two); <span class="tok-comment">// {2}</span>
</span>
<span class="line" id="L130">    two.insertAfter(&amp;five); <span class="tok-comment">// {2, 5}</span>
</span>
<span class="line" id="L131">    list.prepend(&amp;one); <span class="tok-comment">// {1, 2, 5}</span>
</span>
<span class="line" id="L132">    two.insertAfter(&amp;three); <span class="tok-comment">// {1, 2, 3, 5}</span>
</span>
<span class="line" id="L133">    three.insertAfter(&amp;four); <span class="tok-comment">// {1, 2, 3, 4, 5}</span>
</span>
<span class="line" id="L134"></span>
<span class="line" id="L135">    <span class="tok-kw">try</span> testing.expect(list.len() == <span class="tok-number">5</span>);</span>
<span class="line" id="L136"></span>
<span class="line" id="L137">    <span class="tok-comment">// Traverse forwards.</span>
</span>
<span class="line" id="L138">    {</span>
<span class="line" id="L139">        <span class="tok-kw">var</span> it = list.first;</span>
<span class="line" id="L140">        <span class="tok-kw">var</span> index: <span class="tok-type">u32</span> = <span class="tok-number">1</span>;</span>
<span class="line" id="L141">        <span class="tok-kw">while</span> (it) |node| : (it = node.next) {</span>
<span class="line" id="L142">            <span class="tok-kw">try</span> testing.expect(node.data == index);</span>
<span class="line" id="L143">            index += <span class="tok-number">1</span>;</span>
<span class="line" id="L144">        }</span>
<span class="line" id="L145">    }</span>
<span class="line" id="L146"></span>
<span class="line" id="L147">    _ = list.popFirst(); <span class="tok-comment">// {2, 3, 4, 5}</span>
</span>
<span class="line" id="L148">    _ = list.remove(&amp;five); <span class="tok-comment">// {2, 3, 4}</span>
</span>
<span class="line" id="L149">    _ = two.removeNext(); <span class="tok-comment">// {2, 4}</span>
</span>
<span class="line" id="L150"></span>
<span class="line" id="L151">    <span class="tok-kw">try</span> testing.expect(list.first.?.data == <span class="tok-number">2</span>);</span>
<span class="line" id="L152">    <span class="tok-kw">try</span> testing.expect(list.first.?.next.?.data == <span class="tok-number">4</span>);</span>
<span class="line" id="L153">    <span class="tok-kw">try</span> testing.expect(list.first.?.next.?.next == <span class="tok-null">null</span>);</span>
<span class="line" id="L154">}</span>
<span class="line" id="L155"></span>
<span class="line" id="L156"><span class="tok-comment">/// A tail queue is headed by a pair of pointers, one to the head of the</span></span>
<span class="line" id="L157"><span class="tok-comment">/// list and the other to the tail of the list. The elements are doubly</span></span>
<span class="line" id="L158"><span class="tok-comment">/// linked so that an arbitrary element can be removed without a need to</span></span>
<span class="line" id="L159"><span class="tok-comment">/// traverse the list. New elements can be added to the list before or</span></span>
<span class="line" id="L160"><span class="tok-comment">/// after an existing element, at the head of the list, or at the end of</span></span>
<span class="line" id="L161"><span class="tok-comment">/// the list. A tail queue may be traversed in either direction.</span></span>
<span class="line" id="L162"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">TailQueue</span>(<span class="tok-kw">comptime</span> T: <span class="tok-type">type</span>) <span class="tok-type">type</span> {</span>
<span class="line" id="L163">    <span class="tok-kw">return</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L164">        <span class="tok-kw">const</span> Self = <span class="tok-builtin">@This</span>();</span>
<span class="line" id="L165"></span>
<span class="line" id="L166">        <span class="tok-comment">/// Node inside the linked list wrapping the actual data.</span></span>
<span class="line" id="L167">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> Node = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L168">            prev: ?*Node = <span class="tok-null">null</span>,</span>
<span class="line" id="L169">            next: ?*Node = <span class="tok-null">null</span>,</span>
<span class="line" id="L170">            data: T,</span>
<span class="line" id="L171">        };</span>
<span class="line" id="L172"></span>
<span class="line" id="L173">        first: ?*Node = <span class="tok-null">null</span>,</span>
<span class="line" id="L174">        last: ?*Node = <span class="tok-null">null</span>,</span>
<span class="line" id="L175">        len: <span class="tok-type">usize</span> = <span class="tok-number">0</span>,</span>
<span class="line" id="L176"></span>
<span class="line" id="L177">        <span class="tok-comment">/// Insert a new node after an existing one.</span></span>
<span class="line" id="L178">        <span class="tok-comment">///</span></span>
<span class="line" id="L179">        <span class="tok-comment">/// Arguments:</span></span>
<span class="line" id="L180">        <span class="tok-comment">///     node: Pointer to a node in the list.</span></span>
<span class="line" id="L181">        <span class="tok-comment">///     new_node: Pointer to the new node to insert.</span></span>
<span class="line" id="L182">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">insertAfter</span>(list: *Self, node: *Node, new_node: *Node) <span class="tok-type">void</span> {</span>
<span class="line" id="L183">            new_node.prev = node;</span>
<span class="line" id="L184">            <span class="tok-kw">if</span> (node.next) |next_node| {</span>
<span class="line" id="L185">                <span class="tok-comment">// Intermediate node.</span>
</span>
<span class="line" id="L186">                new_node.next = next_node;</span>
<span class="line" id="L187">                next_node.prev = new_node;</span>
<span class="line" id="L188">            } <span class="tok-kw">else</span> {</span>
<span class="line" id="L189">                <span class="tok-comment">// Last element of the list.</span>
</span>
<span class="line" id="L190">                new_node.next = <span class="tok-null">null</span>;</span>
<span class="line" id="L191">                list.last = new_node;</span>
<span class="line" id="L192">            }</span>
<span class="line" id="L193">            node.next = new_node;</span>
<span class="line" id="L194"></span>
<span class="line" id="L195">            list.len += <span class="tok-number">1</span>;</span>
<span class="line" id="L196">        }</span>
<span class="line" id="L197"></span>
<span class="line" id="L198">        <span class="tok-comment">/// Insert a new node before an existing one.</span></span>
<span class="line" id="L199">        <span class="tok-comment">///</span></span>
<span class="line" id="L200">        <span class="tok-comment">/// Arguments:</span></span>
<span class="line" id="L201">        <span class="tok-comment">///     node: Pointer to a node in the list.</span></span>
<span class="line" id="L202">        <span class="tok-comment">///     new_node: Pointer to the new node to insert.</span></span>
<span class="line" id="L203">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">insertBefore</span>(list: *Self, node: *Node, new_node: *Node) <span class="tok-type">void</span> {</span>
<span class="line" id="L204">            new_node.next = node;</span>
<span class="line" id="L205">            <span class="tok-kw">if</span> (node.prev) |prev_node| {</span>
<span class="line" id="L206">                <span class="tok-comment">// Intermediate node.</span>
</span>
<span class="line" id="L207">                new_node.prev = prev_node;</span>
<span class="line" id="L208">                prev_node.next = new_node;</span>
<span class="line" id="L209">            } <span class="tok-kw">else</span> {</span>
<span class="line" id="L210">                <span class="tok-comment">// First element of the list.</span>
</span>
<span class="line" id="L211">                new_node.prev = <span class="tok-null">null</span>;</span>
<span class="line" id="L212">                list.first = new_node;</span>
<span class="line" id="L213">            }</span>
<span class="line" id="L214">            node.prev = new_node;</span>
<span class="line" id="L215"></span>
<span class="line" id="L216">            list.len += <span class="tok-number">1</span>;</span>
<span class="line" id="L217">        }</span>
<span class="line" id="L218"></span>
<span class="line" id="L219">        <span class="tok-comment">/// Concatenate list2 onto the end of list1, removing all entries from the former.</span></span>
<span class="line" id="L220">        <span class="tok-comment">///</span></span>
<span class="line" id="L221">        <span class="tok-comment">/// Arguments:</span></span>
<span class="line" id="L222">        <span class="tok-comment">///     list1: the list to concatenate onto</span></span>
<span class="line" id="L223">        <span class="tok-comment">///     list2: the list to be concatenated</span></span>
<span class="line" id="L224">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">concatByMoving</span>(list1: *Self, list2: *Self) <span class="tok-type">void</span> {</span>
<span class="line" id="L225">            <span class="tok-kw">const</span> l2_first = list2.first <span class="tok-kw">orelse</span> <span class="tok-kw">return</span>;</span>
<span class="line" id="L226">            <span class="tok-kw">if</span> (list1.last) |l1_last| {</span>
<span class="line" id="L227">                l1_last.next = list2.first;</span>
<span class="line" id="L228">                l2_first.prev = list1.last;</span>
<span class="line" id="L229">                list1.len += list2.len;</span>
<span class="line" id="L230">            } <span class="tok-kw">else</span> {</span>
<span class="line" id="L231">                <span class="tok-comment">// list1 was empty</span>
</span>
<span class="line" id="L232">                list1.first = list2.first;</span>
<span class="line" id="L233">                list1.len = list2.len;</span>
<span class="line" id="L234">            }</span>
<span class="line" id="L235">            list1.last = list2.last;</span>
<span class="line" id="L236">            list2.first = <span class="tok-null">null</span>;</span>
<span class="line" id="L237">            list2.last = <span class="tok-null">null</span>;</span>
<span class="line" id="L238">            list2.len = <span class="tok-number">0</span>;</span>
<span class="line" id="L239">        }</span>
<span class="line" id="L240"></span>
<span class="line" id="L241">        <span class="tok-comment">/// Insert a new node at the end of the list.</span></span>
<span class="line" id="L242">        <span class="tok-comment">///</span></span>
<span class="line" id="L243">        <span class="tok-comment">/// Arguments:</span></span>
<span class="line" id="L244">        <span class="tok-comment">///     new_node: Pointer to the new node to insert.</span></span>
<span class="line" id="L245">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">append</span>(list: *Self, new_node: *Node) <span class="tok-type">void</span> {</span>
<span class="line" id="L246">            <span class="tok-kw">if</span> (list.last) |last| {</span>
<span class="line" id="L247">                <span class="tok-comment">// Insert after last.</span>
</span>
<span class="line" id="L248">                list.insertAfter(last, new_node);</span>
<span class="line" id="L249">            } <span class="tok-kw">else</span> {</span>
<span class="line" id="L250">                <span class="tok-comment">// Empty list.</span>
</span>
<span class="line" id="L251">                list.prepend(new_node);</span>
<span class="line" id="L252">            }</span>
<span class="line" id="L253">        }</span>
<span class="line" id="L254"></span>
<span class="line" id="L255">        <span class="tok-comment">/// Insert a new node at the beginning of the list.</span></span>
<span class="line" id="L256">        <span class="tok-comment">///</span></span>
<span class="line" id="L257">        <span class="tok-comment">/// Arguments:</span></span>
<span class="line" id="L258">        <span class="tok-comment">///     new_node: Pointer to the new node to insert.</span></span>
<span class="line" id="L259">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">prepend</span>(list: *Self, new_node: *Node) <span class="tok-type">void</span> {</span>
<span class="line" id="L260">            <span class="tok-kw">if</span> (list.first) |first| {</span>
<span class="line" id="L261">                <span class="tok-comment">// Insert before first.</span>
</span>
<span class="line" id="L262">                list.insertBefore(first, new_node);</span>
<span class="line" id="L263">            } <span class="tok-kw">else</span> {</span>
<span class="line" id="L264">                <span class="tok-comment">// Empty list.</span>
</span>
<span class="line" id="L265">                list.first = new_node;</span>
<span class="line" id="L266">                list.last = new_node;</span>
<span class="line" id="L267">                new_node.prev = <span class="tok-null">null</span>;</span>
<span class="line" id="L268">                new_node.next = <span class="tok-null">null</span>;</span>
<span class="line" id="L269"></span>
<span class="line" id="L270">                list.len = <span class="tok-number">1</span>;</span>
<span class="line" id="L271">            }</span>
<span class="line" id="L272">        }</span>
<span class="line" id="L273"></span>
<span class="line" id="L274">        <span class="tok-comment">/// Remove a node from the list.</span></span>
<span class="line" id="L275">        <span class="tok-comment">///</span></span>
<span class="line" id="L276">        <span class="tok-comment">/// Arguments:</span></span>
<span class="line" id="L277">        <span class="tok-comment">///     node: Pointer to the node to be removed.</span></span>
<span class="line" id="L278">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">remove</span>(list: *Self, node: *Node) <span class="tok-type">void</span> {</span>
<span class="line" id="L279">            <span class="tok-kw">if</span> (node.prev) |prev_node| {</span>
<span class="line" id="L280">                <span class="tok-comment">// Intermediate node.</span>
</span>
<span class="line" id="L281">                prev_node.next = node.next;</span>
<span class="line" id="L282">            } <span class="tok-kw">else</span> {</span>
<span class="line" id="L283">                <span class="tok-comment">// First element of the list.</span>
</span>
<span class="line" id="L284">                list.first = node.next;</span>
<span class="line" id="L285">            }</span>
<span class="line" id="L286"></span>
<span class="line" id="L287">            <span class="tok-kw">if</span> (node.next) |next_node| {</span>
<span class="line" id="L288">                <span class="tok-comment">// Intermediate node.</span>
</span>
<span class="line" id="L289">                next_node.prev = node.prev;</span>
<span class="line" id="L290">            } <span class="tok-kw">else</span> {</span>
<span class="line" id="L291">                <span class="tok-comment">// Last element of the list.</span>
</span>
<span class="line" id="L292">                list.last = node.prev;</span>
<span class="line" id="L293">            }</span>
<span class="line" id="L294"></span>
<span class="line" id="L295">            list.len -= <span class="tok-number">1</span>;</span>
<span class="line" id="L296">            assert(list.len == <span class="tok-number">0</span> <span class="tok-kw">or</span> (list.first != <span class="tok-null">null</span> <span class="tok-kw">and</span> list.last != <span class="tok-null">null</span>));</span>
<span class="line" id="L297">        }</span>
<span class="line" id="L298"></span>
<span class="line" id="L299">        <span class="tok-comment">/// Remove and return the last node in the list.</span></span>
<span class="line" id="L300">        <span class="tok-comment">///</span></span>
<span class="line" id="L301">        <span class="tok-comment">/// Returns:</span></span>
<span class="line" id="L302">        <span class="tok-comment">///     A pointer to the last node in the list.</span></span>
<span class="line" id="L303">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">pop</span>(list: *Self) ?*Node {</span>
<span class="line" id="L304">            <span class="tok-kw">const</span> last = list.last <span class="tok-kw">orelse</span> <span class="tok-kw">return</span> <span class="tok-null">null</span>;</span>
<span class="line" id="L305">            list.remove(last);</span>
<span class="line" id="L306">            <span class="tok-kw">return</span> last;</span>
<span class="line" id="L307">        }</span>
<span class="line" id="L308"></span>
<span class="line" id="L309">        <span class="tok-comment">/// Remove and return the first node in the list.</span></span>
<span class="line" id="L310">        <span class="tok-comment">///</span></span>
<span class="line" id="L311">        <span class="tok-comment">/// Returns:</span></span>
<span class="line" id="L312">        <span class="tok-comment">///     A pointer to the first node in the list.</span></span>
<span class="line" id="L313">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">popFirst</span>(list: *Self) ?*Node {</span>
<span class="line" id="L314">            <span class="tok-kw">const</span> first = list.first <span class="tok-kw">orelse</span> <span class="tok-kw">return</span> <span class="tok-null">null</span>;</span>
<span class="line" id="L315">            list.remove(first);</span>
<span class="line" id="L316">            <span class="tok-kw">return</span> first;</span>
<span class="line" id="L317">        }</span>
<span class="line" id="L318">    };</span>
<span class="line" id="L319">}</span>
<span class="line" id="L320"></span>
<span class="line" id="L321"><span class="tok-kw">test</span> <span class="tok-str">&quot;basic TailQueue test&quot;</span> {</span>
<span class="line" id="L322">    <span class="tok-kw">const</span> L = TailQueue(<span class="tok-type">u32</span>);</span>
<span class="line" id="L323">    <span class="tok-kw">var</span> list = L{};</span>
<span class="line" id="L324"></span>
<span class="line" id="L325">    <span class="tok-kw">var</span> one = L.Node{ .data = <span class="tok-number">1</span> };</span>
<span class="line" id="L326">    <span class="tok-kw">var</span> two = L.Node{ .data = <span class="tok-number">2</span> };</span>
<span class="line" id="L327">    <span class="tok-kw">var</span> three = L.Node{ .data = <span class="tok-number">3</span> };</span>
<span class="line" id="L328">    <span class="tok-kw">var</span> four = L.Node{ .data = <span class="tok-number">4</span> };</span>
<span class="line" id="L329">    <span class="tok-kw">var</span> five = L.Node{ .data = <span class="tok-number">5</span> };</span>
<span class="line" id="L330"></span>
<span class="line" id="L331">    list.append(&amp;two); <span class="tok-comment">// {2}</span>
</span>
<span class="line" id="L332">    list.append(&amp;five); <span class="tok-comment">// {2, 5}</span>
</span>
<span class="line" id="L333">    list.prepend(&amp;one); <span class="tok-comment">// {1, 2, 5}</span>
</span>
<span class="line" id="L334">    list.insertBefore(&amp;five, &amp;four); <span class="tok-comment">// {1, 2, 4, 5}</span>
</span>
<span class="line" id="L335">    list.insertAfter(&amp;two, &amp;three); <span class="tok-comment">// {1, 2, 3, 4, 5}</span>
</span>
<span class="line" id="L336"></span>
<span class="line" id="L337">    <span class="tok-comment">// Traverse forwards.</span>
</span>
<span class="line" id="L338">    {</span>
<span class="line" id="L339">        <span class="tok-kw">var</span> it = list.first;</span>
<span class="line" id="L340">        <span class="tok-kw">var</span> index: <span class="tok-type">u32</span> = <span class="tok-number">1</span>;</span>
<span class="line" id="L341">        <span class="tok-kw">while</span> (it) |node| : (it = node.next) {</span>
<span class="line" id="L342">            <span class="tok-kw">try</span> testing.expect(node.data == index);</span>
<span class="line" id="L343">            index += <span class="tok-number">1</span>;</span>
<span class="line" id="L344">        }</span>
<span class="line" id="L345">    }</span>
<span class="line" id="L346"></span>
<span class="line" id="L347">    <span class="tok-comment">// Traverse backwards.</span>
</span>
<span class="line" id="L348">    {</span>
<span class="line" id="L349">        <span class="tok-kw">var</span> it = list.last;</span>
<span class="line" id="L350">        <span class="tok-kw">var</span> index: <span class="tok-type">u32</span> = <span class="tok-number">1</span>;</span>
<span class="line" id="L351">        <span class="tok-kw">while</span> (it) |node| : (it = node.prev) {</span>
<span class="line" id="L352">            <span class="tok-kw">try</span> testing.expect(node.data == (<span class="tok-number">6</span> - index));</span>
<span class="line" id="L353">            index += <span class="tok-number">1</span>;</span>
<span class="line" id="L354">        }</span>
<span class="line" id="L355">    }</span>
<span class="line" id="L356"></span>
<span class="line" id="L357">    _ = list.popFirst(); <span class="tok-comment">// {2, 3, 4, 5}</span>
</span>
<span class="line" id="L358">    _ = list.pop(); <span class="tok-comment">// {2, 3, 4}</span>
</span>
<span class="line" id="L359">    list.remove(&amp;three); <span class="tok-comment">// {2, 4}</span>
</span>
<span class="line" id="L360"></span>
<span class="line" id="L361">    <span class="tok-kw">try</span> testing.expect(list.first.?.data == <span class="tok-number">2</span>);</span>
<span class="line" id="L362">    <span class="tok-kw">try</span> testing.expect(list.last.?.data == <span class="tok-number">4</span>);</span>
<span class="line" id="L363">    <span class="tok-kw">try</span> testing.expect(list.len == <span class="tok-number">2</span>);</span>
<span class="line" id="L364">}</span>
<span class="line" id="L365"></span>
<span class="line" id="L366"><span class="tok-kw">test</span> <span class="tok-str">&quot;TailQueue concatenation&quot;</span> {</span>
<span class="line" id="L367">    <span class="tok-kw">const</span> L = TailQueue(<span class="tok-type">u32</span>);</span>
<span class="line" id="L368">    <span class="tok-kw">var</span> list1 = L{};</span>
<span class="line" id="L369">    <span class="tok-kw">var</span> list2 = L{};</span>
<span class="line" id="L370"></span>
<span class="line" id="L371">    <span class="tok-kw">var</span> one = L.Node{ .data = <span class="tok-number">1</span> };</span>
<span class="line" id="L372">    <span class="tok-kw">var</span> two = L.Node{ .data = <span class="tok-number">2</span> };</span>
<span class="line" id="L373">    <span class="tok-kw">var</span> three = L.Node{ .data = <span class="tok-number">3</span> };</span>
<span class="line" id="L374">    <span class="tok-kw">var</span> four = L.Node{ .data = <span class="tok-number">4</span> };</span>
<span class="line" id="L375">    <span class="tok-kw">var</span> five = L.Node{ .data = <span class="tok-number">5</span> };</span>
<span class="line" id="L376"></span>
<span class="line" id="L377">    list1.append(&amp;one);</span>
<span class="line" id="L378">    list1.append(&amp;two);</span>
<span class="line" id="L379">    list2.append(&amp;three);</span>
<span class="line" id="L380">    list2.append(&amp;four);</span>
<span class="line" id="L381">    list2.append(&amp;five);</span>
<span class="line" id="L382"></span>
<span class="line" id="L383">    list1.concatByMoving(&amp;list2);</span>
<span class="line" id="L384"></span>
<span class="line" id="L385">    <span class="tok-kw">try</span> testing.expect(list1.last == &amp;five);</span>
<span class="line" id="L386">    <span class="tok-kw">try</span> testing.expect(list1.len == <span class="tok-number">5</span>);</span>
<span class="line" id="L387">    <span class="tok-kw">try</span> testing.expect(list2.first == <span class="tok-null">null</span>);</span>
<span class="line" id="L388">    <span class="tok-kw">try</span> testing.expect(list2.last == <span class="tok-null">null</span>);</span>
<span class="line" id="L389">    <span class="tok-kw">try</span> testing.expect(list2.len == <span class="tok-number">0</span>);</span>
<span class="line" id="L390"></span>
<span class="line" id="L391">    <span class="tok-comment">// Traverse forwards.</span>
</span>
<span class="line" id="L392">    {</span>
<span class="line" id="L393">        <span class="tok-kw">var</span> it = list1.first;</span>
<span class="line" id="L394">        <span class="tok-kw">var</span> index: <span class="tok-type">u32</span> = <span class="tok-number">1</span>;</span>
<span class="line" id="L395">        <span class="tok-kw">while</span> (it) |node| : (it = node.next) {</span>
<span class="line" id="L396">            <span class="tok-kw">try</span> testing.expect(node.data == index);</span>
<span class="line" id="L397">            index += <span class="tok-number">1</span>;</span>
<span class="line" id="L398">        }</span>
<span class="line" id="L399">    }</span>
<span class="line" id="L400"></span>
<span class="line" id="L401">    <span class="tok-comment">// Traverse backwards.</span>
</span>
<span class="line" id="L402">    {</span>
<span class="line" id="L403">        <span class="tok-kw">var</span> it = list1.last;</span>
<span class="line" id="L404">        <span class="tok-kw">var</span> index: <span class="tok-type">u32</span> = <span class="tok-number">1</span>;</span>
<span class="line" id="L405">        <span class="tok-kw">while</span> (it) |node| : (it = node.prev) {</span>
<span class="line" id="L406">            <span class="tok-kw">try</span> testing.expect(node.data == (<span class="tok-number">6</span> - index));</span>
<span class="line" id="L407">            index += <span class="tok-number">1</span>;</span>
<span class="line" id="L408">        }</span>
<span class="line" id="L409">    }</span>
<span class="line" id="L410"></span>
<span class="line" id="L411">    <span class="tok-comment">// Swap them back, this verifies that concating to an empty list works.</span>
</span>
<span class="line" id="L412">    list2.concatByMoving(&amp;list1);</span>
<span class="line" id="L413"></span>
<span class="line" id="L414">    <span class="tok-comment">// Traverse forwards.</span>
</span>
<span class="line" id="L415">    {</span>
<span class="line" id="L416">        <span class="tok-kw">var</span> it = list2.first;</span>
<span class="line" id="L417">        <span class="tok-kw">var</span> index: <span class="tok-type">u32</span> = <span class="tok-number">1</span>;</span>
<span class="line" id="L418">        <span class="tok-kw">while</span> (it) |node| : (it = node.next) {</span>
<span class="line" id="L419">            <span class="tok-kw">try</span> testing.expect(node.data == index);</span>
<span class="line" id="L420">            index += <span class="tok-number">1</span>;</span>
<span class="line" id="L421">        }</span>
<span class="line" id="L422">    }</span>
<span class="line" id="L423"></span>
<span class="line" id="L424">    <span class="tok-comment">// Traverse backwards.</span>
</span>
<span class="line" id="L425">    {</span>
<span class="line" id="L426">        <span class="tok-kw">var</span> it = list2.last;</span>
<span class="line" id="L427">        <span class="tok-kw">var</span> index: <span class="tok-type">u32</span> = <span class="tok-number">1</span>;</span>
<span class="line" id="L428">        <span class="tok-kw">while</span> (it) |node| : (it = node.prev) {</span>
<span class="line" id="L429">            <span class="tok-kw">try</span> testing.expect(node.data == (<span class="tok-number">6</span> - index));</span>
<span class="line" id="L430">            index += <span class="tok-number">1</span>;</span>
<span class="line" id="L431">        }</span>
<span class="line" id="L432">    }</span>
<span class="line" id="L433">}</span>
<span class="line" id="L434"></span>
</code></pre></body>
</html>