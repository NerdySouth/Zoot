<!doctype html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">    <title>os/uefi/protocols/device_path_protocol.zig - source view</title>
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
<pre><code><span class="line" id="L1"><span class="tok-kw">const</span> std = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;std&quot;</span>);</span>
<span class="line" id="L2"><span class="tok-kw">const</span> mem = std.mem;</span>
<span class="line" id="L3"><span class="tok-kw">const</span> uefi = std.os.uefi;</span>
<span class="line" id="L4"><span class="tok-kw">const</span> Allocator = mem.Allocator;</span>
<span class="line" id="L5"><span class="tok-kw">const</span> Guid = uefi.Guid;</span>
<span class="line" id="L6"></span>
<span class="line" id="L7"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> DevicePathProtocol = <span class="tok-kw">packed</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L8">    <span class="tok-type">type</span>: DevicePathType,</span>
<span class="line" id="L9">    subtype: <span class="tok-type">u8</span>,</span>
<span class="line" id="L10">    length: <span class="tok-type">u16</span>,</span>
<span class="line" id="L11"></span>
<span class="line" id="L12">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> guid <span class="tok-kw">align</span>(<span class="tok-number">8</span>) = Guid{</span>
<span class="line" id="L13">        .time_low = <span class="tok-number">0x09576e91</span>,</span>
<span class="line" id="L14">        .time_mid = <span class="tok-number">0x6d3f</span>,</span>
<span class="line" id="L15">        .time_high_and_version = <span class="tok-number">0x11d2</span>,</span>
<span class="line" id="L16">        .clock_seq_high_and_reserved = <span class="tok-number">0x8e</span>,</span>
<span class="line" id="L17">        .clock_seq_low = <span class="tok-number">0x39</span>,</span>
<span class="line" id="L18">        .node = [_]<span class="tok-type">u8</span>{ <span class="tok-number">0x00</span>, <span class="tok-number">0xa0</span>, <span class="tok-number">0xc9</span>, <span class="tok-number">0x69</span>, <span class="tok-number">0x72</span>, <span class="tok-number">0x3b</span> },</span>
<span class="line" id="L19">    };</span>
<span class="line" id="L20"></span>
<span class="line" id="L21">    <span class="tok-comment">/// Returns the next DevicePathProtocol node in the sequence, if any.</span></span>
<span class="line" id="L22">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">next</span>(self: *DevicePathProtocol) ?*DevicePathProtocol {</span>
<span class="line" id="L23">        <span class="tok-kw">if</span> (self.<span class="tok-type">type</span> == .End <span class="tok-kw">and</span> <span class="tok-builtin">@intToEnum</span>(EndDevicePath.Subtype, self.subtype) == .EndEntire)</span>
<span class="line" id="L24">            <span class="tok-kw">return</span> <span class="tok-null">null</span>;</span>
<span class="line" id="L25"></span>
<span class="line" id="L26">        <span class="tok-kw">return</span> <span class="tok-builtin">@ptrCast</span>(*DevicePathProtocol, <span class="tok-builtin">@ptrCast</span>([*]<span class="tok-type">u8</span>, self) + self.length);</span>
<span class="line" id="L27">    }</span>
<span class="line" id="L28"></span>
<span class="line" id="L29">    <span class="tok-comment">/// Calculates the total length of the device path structure in bytes, including the end of device path node.</span></span>
<span class="line" id="L30">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">size</span>(self: *DevicePathProtocol) <span class="tok-type">usize</span> {</span>
<span class="line" id="L31">        <span class="tok-kw">var</span> node = self;</span>
<span class="line" id="L32"></span>
<span class="line" id="L33">        <span class="tok-kw">while</span> (node.next()) |next_node| {</span>
<span class="line" id="L34">            node = next_node;</span>
<span class="line" id="L35">        }</span>
<span class="line" id="L36"></span>
<span class="line" id="L37">        <span class="tok-kw">return</span> (<span class="tok-builtin">@ptrToInt</span>(node) + node.length) - <span class="tok-builtin">@ptrToInt</span>(self);</span>
<span class="line" id="L38">    }</span>
<span class="line" id="L39"></span>
<span class="line" id="L40">    <span class="tok-comment">/// Creates a file device path from the existing device path and a file path.</span></span>
<span class="line" id="L41">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">create_file_device_path</span>(self: *DevicePathProtocol, allocator: Allocator, path: [:<span class="tok-number">0</span>]<span class="tok-kw">const</span> <span class="tok-type">u16</span>) !*DevicePathProtocol {</span>
<span class="line" id="L42">        <span class="tok-kw">var</span> path_size = self.size();</span>
<span class="line" id="L43"></span>
<span class="line" id="L44">        <span class="tok-comment">// 2 * (path.len + 1) for the path and its null terminator, which are u16s</span>
</span>
<span class="line" id="L45">        <span class="tok-comment">// DevicePathProtocol for the extra node before the end</span>
</span>
<span class="line" id="L46">        <span class="tok-kw">var</span> buf = <span class="tok-kw">try</span> allocator.alloc(<span class="tok-type">u8</span>, path_size + <span class="tok-number">2</span> * (path.len + <span class="tok-number">1</span>) + <span class="tok-builtin">@sizeOf</span>(DevicePathProtocol));</span>
<span class="line" id="L47"></span>
<span class="line" id="L48">        mem.copy(<span class="tok-type">u8</span>, buf, <span class="tok-builtin">@ptrCast</span>([*]<span class="tok-kw">const</span> <span class="tok-type">u8</span>, self)[<span class="tok-number">0</span>..path_size]);</span>
<span class="line" id="L49"></span>
<span class="line" id="L50">        <span class="tok-comment">// Pointer to the copy of the end node of the current chain, which is - 4 from the buffer</span>
</span>
<span class="line" id="L51">        <span class="tok-comment">// as the end node itself is 4 bytes (type: u8 + subtype: u8 + length: u16).</span>
</span>
<span class="line" id="L52">        <span class="tok-kw">var</span> new = <span class="tok-builtin">@ptrCast</span>(*MediaDevicePath.FilePathDevicePath, buf.ptr + path_size - <span class="tok-number">4</span>);</span>
<span class="line" id="L53"></span>
<span class="line" id="L54">        new.<span class="tok-type">type</span> = .Media;</span>
<span class="line" id="L55">        new.subtype = .FilePath;</span>
<span class="line" id="L56">        new.length = <span class="tok-builtin">@sizeOf</span>(MediaDevicePath.FilePathDevicePath) + <span class="tok-number">2</span> * (<span class="tok-builtin">@intCast</span>(<span class="tok-type">u16</span>, path.len) + <span class="tok-number">1</span>);</span>
<span class="line" id="L57"></span>
<span class="line" id="L58">        <span class="tok-comment">// The same as new.getPath(), but not const as we're filling it in.</span>
</span>
<span class="line" id="L59">        <span class="tok-kw">var</span> ptr = <span class="tok-builtin">@ptrCast</span>([*:<span class="tok-number">0</span>]<span class="tok-type">u16</span>, <span class="tok-builtin">@alignCast</span>(<span class="tok-number">2</span>, <span class="tok-builtin">@ptrCast</span>([*]<span class="tok-type">u8</span>, new)) + <span class="tok-builtin">@sizeOf</span>(MediaDevicePath.FilePathDevicePath));</span>
<span class="line" id="L60"></span>
<span class="line" id="L61">        <span class="tok-kw">for</span> (path) |s, i|</span>
<span class="line" id="L62">            ptr[i] = s;</span>
<span class="line" id="L63"></span>
<span class="line" id="L64">        ptr[path.len] = <span class="tok-number">0</span>;</span>
<span class="line" id="L65"></span>
<span class="line" id="L66">        <span class="tok-kw">var</span> end = <span class="tok-builtin">@ptrCast</span>(*EndDevicePath.EndEntireDevicePath, <span class="tok-builtin">@ptrCast</span>(*DevicePathProtocol, new).next().?);</span>
<span class="line" id="L67">        end.<span class="tok-type">type</span> = .End;</span>
<span class="line" id="L68">        end.subtype = .EndEntire;</span>
<span class="line" id="L69">        end.length = <span class="tok-builtin">@sizeOf</span>(EndDevicePath.EndEntireDevicePath);</span>
<span class="line" id="L70"></span>
<span class="line" id="L71">        <span class="tok-kw">return</span> <span class="tok-builtin">@ptrCast</span>(*DevicePathProtocol, buf.ptr);</span>
<span class="line" id="L72">    }</span>
<span class="line" id="L73"></span>
<span class="line" id="L74">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">getDevicePath</span>(self: *<span class="tok-kw">const</span> DevicePathProtocol) ?DevicePath {</span>
<span class="line" id="L75">        <span class="tok-kw">inline</span> <span class="tok-kw">for</span> (<span class="tok-builtin">@typeInfo</span>(DevicePath).Union.fields) |ufield| {</span>
<span class="line" id="L76">            <span class="tok-kw">const</span> enum_value = std.meta.stringToEnum(DevicePathType, ufield.name);</span>
<span class="line" id="L77"></span>
<span class="line" id="L78">            <span class="tok-comment">// Got the associated union type for self.type, now</span>
</span>
<span class="line" id="L79">            <span class="tok-comment">// we need to initialize it and its subtype</span>
</span>
<span class="line" id="L80">            <span class="tok-kw">if</span> (self.<span class="tok-type">type</span> == enum_value) {</span>
<span class="line" id="L81">                <span class="tok-kw">var</span> subtype = self.initSubtype(ufield.field_type);</span>
<span class="line" id="L82"></span>
<span class="line" id="L83">                <span class="tok-kw">if</span> (subtype) |sb| {</span>
<span class="line" id="L84">                    <span class="tok-comment">// e.g. return .{ .Hardware = .{ .Pci = @ptrCast(...) } }</span>
</span>
<span class="line" id="L85">                    <span class="tok-kw">return</span> <span class="tok-builtin">@unionInit</span>(DevicePath, ufield.name, sb);</span>
<span class="line" id="L86">                }</span>
<span class="line" id="L87">            }</span>
<span class="line" id="L88">        }</span>
<span class="line" id="L89"></span>
<span class="line" id="L90">        <span class="tok-kw">return</span> <span class="tok-null">null</span>;</span>
<span class="line" id="L91">    }</span>
<span class="line" id="L92"></span>
<span class="line" id="L93">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">initSubtype</span>(self: *<span class="tok-kw">const</span> DevicePathProtocol, <span class="tok-kw">comptime</span> TUnion: <span class="tok-type">type</span>) ?TUnion {</span>
<span class="line" id="L94">        <span class="tok-kw">const</span> type_info = <span class="tok-builtin">@typeInfo</span>(TUnion).Union;</span>
<span class="line" id="L95">        <span class="tok-kw">const</span> TTag = type_info.tag_type.?;</span>
<span class="line" id="L96"></span>
<span class="line" id="L97">        <span class="tok-kw">inline</span> <span class="tok-kw">for</span> (type_info.fields) |subtype| {</span>
<span class="line" id="L98">            <span class="tok-comment">// The tag names match the union names, so just grab that off the enum</span>
</span>
<span class="line" id="L99">            <span class="tok-kw">const</span> tag_val: <span class="tok-type">u8</span> = <span class="tok-builtin">@enumToInt</span>(<span class="tok-builtin">@field</span>(TTag, subtype.name));</span>
<span class="line" id="L100"></span>
<span class="line" id="L101">            <span class="tok-kw">if</span> (self.subtype == tag_val) {</span>
<span class="line" id="L102">                <span class="tok-comment">// e.g. expr = .{ .Pci = @ptrCast(...) }</span>
</span>
<span class="line" id="L103">                <span class="tok-kw">return</span> <span class="tok-builtin">@unionInit</span>(TUnion, subtype.name, <span class="tok-builtin">@ptrCast</span>(subtype.field_type, self));</span>
<span class="line" id="L104">            }</span>
<span class="line" id="L105">        }</span>
<span class="line" id="L106"></span>
<span class="line" id="L107">        <span class="tok-kw">return</span> <span class="tok-null">null</span>;</span>
<span class="line" id="L108">    }</span>
<span class="line" id="L109">};</span>
<span class="line" id="L110"></span>
<span class="line" id="L111"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> DevicePath = <span class="tok-kw">union</span>(DevicePathType) {</span>
<span class="line" id="L112">    Hardware: HardwareDevicePath,</span>
<span class="line" id="L113">    Acpi: AcpiDevicePath,</span>
<span class="line" id="L114">    Messaging: MessagingDevicePath,</span>
<span class="line" id="L115">    Media: MediaDevicePath,</span>
<span class="line" id="L116">    BiosBootSpecification: BiosBootSpecificationDevicePath,</span>
<span class="line" id="L117">    End: EndDevicePath,</span>
<span class="line" id="L118">};</span>
<span class="line" id="L119"></span>
<span class="line" id="L120"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> DevicePathType = <span class="tok-kw">enum</span>(<span class="tok-type">u8</span>) {</span>
<span class="line" id="L121">    Hardware = <span class="tok-number">0x01</span>,</span>
<span class="line" id="L122">    Acpi = <span class="tok-number">0x02</span>,</span>
<span class="line" id="L123">    Messaging = <span class="tok-number">0x03</span>,</span>
<span class="line" id="L124">    Media = <span class="tok-number">0x04</span>,</span>
<span class="line" id="L125">    BiosBootSpecification = <span class="tok-number">0x05</span>,</span>
<span class="line" id="L126">    End = <span class="tok-number">0x7f</span>,</span>
<span class="line" id="L127">    _,</span>
<span class="line" id="L128">};</span>
<span class="line" id="L129"></span>
<span class="line" id="L130"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> HardwareDevicePath = <span class="tok-kw">union</span>(Subtype) {</span>
<span class="line" id="L131">    Pci: *<span class="tok-kw">const</span> PciDevicePath,</span>
<span class="line" id="L132">    PcCard: *<span class="tok-kw">const</span> PcCardDevicePath,</span>
<span class="line" id="L133">    MemoryMapped: *<span class="tok-kw">const</span> MemoryMappedDevicePath,</span>
<span class="line" id="L134">    Vendor: *<span class="tok-kw">const</span> VendorDevicePath,</span>
<span class="line" id="L135">    Controller: *<span class="tok-kw">const</span> ControllerDevicePath,</span>
<span class="line" id="L136">    Bmc: *<span class="tok-kw">const</span> BmcDevicePath,</span>
<span class="line" id="L137"></span>
<span class="line" id="L138">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> Subtype = <span class="tok-kw">enum</span>(<span class="tok-type">u8</span>) {</span>
<span class="line" id="L139">        Pci = <span class="tok-number">1</span>,</span>
<span class="line" id="L140">        PcCard = <span class="tok-number">2</span>,</span>
<span class="line" id="L141">        MemoryMapped = <span class="tok-number">3</span>,</span>
<span class="line" id="L142">        Vendor = <span class="tok-number">4</span>,</span>
<span class="line" id="L143">        Controller = <span class="tok-number">5</span>,</span>
<span class="line" id="L144">        Bmc = <span class="tok-number">6</span>,</span>
<span class="line" id="L145">        _,</span>
<span class="line" id="L146">    };</span>
<span class="line" id="L147"></span>
<span class="line" id="L148">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> PciDevicePath = <span class="tok-kw">packed</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L149">        <span class="tok-type">type</span>: DevicePathType,</span>
<span class="line" id="L150">        subtype: Subtype,</span>
<span class="line" id="L151">        length: <span class="tok-type">u16</span>,</span>
<span class="line" id="L152">        function: <span class="tok-type">u8</span>,</span>
<span class="line" id="L153">        device: <span class="tok-type">u8</span>,</span>
<span class="line" id="L154">    };</span>
<span class="line" id="L155"></span>
<span class="line" id="L156">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> PcCardDevicePath = <span class="tok-kw">packed</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L157">        <span class="tok-type">type</span>: DevicePathType,</span>
<span class="line" id="L158">        subtype: Subtype,</span>
<span class="line" id="L159">        length: <span class="tok-type">u16</span>,</span>
<span class="line" id="L160">        function_number: <span class="tok-type">u8</span>,</span>
<span class="line" id="L161">    };</span>
<span class="line" id="L162"></span>
<span class="line" id="L163">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> MemoryMappedDevicePath = <span class="tok-kw">packed</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L164">        <span class="tok-type">type</span>: DevicePathType,</span>
<span class="line" id="L165">        subtype: Subtype,</span>
<span class="line" id="L166">        length: <span class="tok-type">u16</span>,</span>
<span class="line" id="L167">        memory_type: <span class="tok-type">u32</span>,</span>
<span class="line" id="L168">        start_address: <span class="tok-type">u64</span>,</span>
<span class="line" id="L169">        end_address: <span class="tok-type">u64</span>,</span>
<span class="line" id="L170">    };</span>
<span class="line" id="L171"></span>
<span class="line" id="L172">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> VendorDevicePath = <span class="tok-kw">packed</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L173">        <span class="tok-type">type</span>: DevicePathType,</span>
<span class="line" id="L174">        subtype: Subtype,</span>
<span class="line" id="L175">        length: <span class="tok-type">u16</span>,</span>
<span class="line" id="L176">        vendor_guid: Guid,</span>
<span class="line" id="L177">    };</span>
<span class="line" id="L178"></span>
<span class="line" id="L179">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> ControllerDevicePath = <span class="tok-kw">packed</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L180">        <span class="tok-type">type</span>: DevicePathType,</span>
<span class="line" id="L181">        subtype: Subtype,</span>
<span class="line" id="L182">        length: <span class="tok-type">u16</span>,</span>
<span class="line" id="L183">        controller_number: <span class="tok-type">u32</span>,</span>
<span class="line" id="L184">    };</span>
<span class="line" id="L185"></span>
<span class="line" id="L186">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> BmcDevicePath = <span class="tok-kw">packed</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L187">        <span class="tok-type">type</span>: DevicePathType,</span>
<span class="line" id="L188">        subtype: Subtype,</span>
<span class="line" id="L189">        length: <span class="tok-type">u16</span>,</span>
<span class="line" id="L190">        interface_type: <span class="tok-type">u8</span>,</span>
<span class="line" id="L191">        base_address: <span class="tok-type">usize</span>,</span>
<span class="line" id="L192">    };</span>
<span class="line" id="L193">};</span>
<span class="line" id="L194"></span>
<span class="line" id="L195"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> AcpiDevicePath = <span class="tok-kw">union</span>(Subtype) {</span>
<span class="line" id="L196">    Acpi: *<span class="tok-kw">const</span> BaseAcpiDevicePath,</span>
<span class="line" id="L197">    ExpandedAcpi: *<span class="tok-kw">const</span> ExpandedAcpiDevicePath,</span>
<span class="line" id="L198">    Adr: *<span class="tok-kw">const</span> AdrDevicePath,</span>
<span class="line" id="L199"></span>
<span class="line" id="L200">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> Subtype = <span class="tok-kw">enum</span>(<span class="tok-type">u8</span>) {</span>
<span class="line" id="L201">        Acpi = <span class="tok-number">1</span>,</span>
<span class="line" id="L202">        ExpandedAcpi = <span class="tok-number">2</span>,</span>
<span class="line" id="L203">        Adr = <span class="tok-number">3</span>,</span>
<span class="line" id="L204">        _,</span>
<span class="line" id="L205">    };</span>
<span class="line" id="L206"></span>
<span class="line" id="L207">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> BaseAcpiDevicePath = <span class="tok-kw">packed</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L208">        <span class="tok-type">type</span>: DevicePathType,</span>
<span class="line" id="L209">        subtype: Subtype,</span>
<span class="line" id="L210">        length: <span class="tok-type">u16</span>,</span>
<span class="line" id="L211">        hid: <span class="tok-type">u32</span>,</span>
<span class="line" id="L212">        uid: <span class="tok-type">u32</span>,</span>
<span class="line" id="L213">    };</span>
<span class="line" id="L214"></span>
<span class="line" id="L215">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> ExpandedAcpiDevicePath = <span class="tok-kw">packed</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L216">        <span class="tok-type">type</span>: DevicePathType,</span>
<span class="line" id="L217">        subtype: Subtype,</span>
<span class="line" id="L218">        length: <span class="tok-type">u16</span>,</span>
<span class="line" id="L219">        hid: <span class="tok-type">u32</span>,</span>
<span class="line" id="L220">        uid: <span class="tok-type">u32</span>,</span>
<span class="line" id="L221">        cid: <span class="tok-type">u32</span>,</span>
<span class="line" id="L222">        <span class="tok-comment">// variable length u16[*:0] strings</span>
</span>
<span class="line" id="L223">        <span class="tok-comment">// hid_str, uid_str, cid_str</span>
</span>
<span class="line" id="L224">    };</span>
<span class="line" id="L225"></span>
<span class="line" id="L226">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> AdrDevicePath = <span class="tok-kw">packed</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L227">        <span class="tok-type">type</span>: DevicePathType,</span>
<span class="line" id="L228">        subtype: Subtype,</span>
<span class="line" id="L229">        length: <span class="tok-type">u16</span>,</span>
<span class="line" id="L230">        adr: <span class="tok-type">u32</span>,</span>
<span class="line" id="L231">        <span class="tok-comment">// multiple adr entries can optionally follow</span>
</span>
<span class="line" id="L232">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">adrs</span>(self: *<span class="tok-kw">const</span> AdrDevicePath) []<span class="tok-kw">const</span> <span class="tok-type">u32</span> {</span>
<span class="line" id="L233">            <span class="tok-comment">// self.length is a minimum of 8 with one adr which is size 4.</span>
</span>
<span class="line" id="L234">            <span class="tok-kw">var</span> entries = (self.length - <span class="tok-number">4</span>) / <span class="tok-builtin">@sizeOf</span>(<span class="tok-type">u32</span>);</span>
<span class="line" id="L235">            <span class="tok-kw">return</span> <span class="tok-builtin">@ptrCast</span>([*]<span class="tok-kw">const</span> <span class="tok-type">u32</span>, &amp;self.adr)[<span class="tok-number">0</span>..entries];</span>
<span class="line" id="L236">        }</span>
<span class="line" id="L237">    };</span>
<span class="line" id="L238">};</span>
<span class="line" id="L239"></span>
<span class="line" id="L240"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> MessagingDevicePath = <span class="tok-kw">union</span>(Subtype) {</span>
<span class="line" id="L241">    Atapi: *<span class="tok-kw">const</span> AtapiDevicePath,</span>
<span class="line" id="L242">    Scsi: *<span class="tok-kw">const</span> ScsiDevicePath,</span>
<span class="line" id="L243">    FibreChannel: *<span class="tok-kw">const</span> FibreChannelDevicePath,</span>
<span class="line" id="L244">    FibreChannelEx: *<span class="tok-kw">const</span> FibreChannelExDevicePath,</span>
<span class="line" id="L245">    @&quot;1394&quot;: *<span class="tok-kw">const</span> F1394DevicePath,</span>
<span class="line" id="L246">    Usb: *<span class="tok-kw">const</span> UsbDevicePath,</span>
<span class="line" id="L247">    Sata: *<span class="tok-kw">const</span> SataDevicePath,</span>
<span class="line" id="L248">    UsbWwid: *<span class="tok-kw">const</span> UsbWwidDevicePath,</span>
<span class="line" id="L249">    Lun: *<span class="tok-kw">const</span> DeviceLogicalUnitDevicePath,</span>
<span class="line" id="L250">    UsbClass: *<span class="tok-kw">const</span> UsbClassDevicePath,</span>
<span class="line" id="L251">    I2o: *<span class="tok-kw">const</span> I2oDevicePath,</span>
<span class="line" id="L252">    MacAddress: *<span class="tok-kw">const</span> MacAddressDevicePath,</span>
<span class="line" id="L253">    Ipv4: *<span class="tok-kw">const</span> Ipv4DevicePath,</span>
<span class="line" id="L254">    Ipv6: *<span class="tok-kw">const</span> Ipv6DevicePath,</span>
<span class="line" id="L255">    Vlan: *<span class="tok-kw">const</span> VlanDevicePath,</span>
<span class="line" id="L256">    InfiniBand: *<span class="tok-kw">const</span> InfiniBandDevicePath,</span>
<span class="line" id="L257">    Uart: *<span class="tok-kw">const</span> UartDevicePath,</span>
<span class="line" id="L258">    Vendor: *<span class="tok-kw">const</span> VendorDefinedDevicePath,</span>
<span class="line" id="L259"></span>
<span class="line" id="L260">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> Subtype = <span class="tok-kw">enum</span>(<span class="tok-type">u8</span>) {</span>
<span class="line" id="L261">        Atapi = <span class="tok-number">1</span>,</span>
<span class="line" id="L262">        Scsi = <span class="tok-number">2</span>,</span>
<span class="line" id="L263">        FibreChannel = <span class="tok-number">3</span>,</span>
<span class="line" id="L264">        FibreChannelEx = <span class="tok-number">21</span>,</span>
<span class="line" id="L265">        @&quot;1394&quot; = <span class="tok-number">4</span>,</span>
<span class="line" id="L266">        Usb = <span class="tok-number">5</span>,</span>
<span class="line" id="L267">        Sata = <span class="tok-number">18</span>,</span>
<span class="line" id="L268">        UsbWwid = <span class="tok-number">16</span>,</span>
<span class="line" id="L269">        Lun = <span class="tok-number">17</span>,</span>
<span class="line" id="L270">        UsbClass = <span class="tok-number">15</span>,</span>
<span class="line" id="L271">        I2o = <span class="tok-number">6</span>,</span>
<span class="line" id="L272">        MacAddress = <span class="tok-number">11</span>,</span>
<span class="line" id="L273">        Ipv4 = <span class="tok-number">12</span>,</span>
<span class="line" id="L274">        Ipv6 = <span class="tok-number">13</span>,</span>
<span class="line" id="L275">        Vlan = <span class="tok-number">20</span>,</span>
<span class="line" id="L276">        InfiniBand = <span class="tok-number">9</span>,</span>
<span class="line" id="L277">        Uart = <span class="tok-number">14</span>,</span>
<span class="line" id="L278">        Vendor = <span class="tok-number">10</span>,</span>
<span class="line" id="L279">        _,</span>
<span class="line" id="L280">    };</span>
<span class="line" id="L281"></span>
<span class="line" id="L282">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> AtapiDevicePath = <span class="tok-kw">packed</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L283">        <span class="tok-kw">const</span> Role = <span class="tok-kw">enum</span>(<span class="tok-type">u8</span>) {</span>
<span class="line" id="L284">            Master = <span class="tok-number">0</span>,</span>
<span class="line" id="L285">            Slave = <span class="tok-number">1</span>,</span>
<span class="line" id="L286">        };</span>
<span class="line" id="L287"></span>
<span class="line" id="L288">        <span class="tok-kw">const</span> Rank = <span class="tok-kw">enum</span>(<span class="tok-type">u8</span>) {</span>
<span class="line" id="L289">            Primary = <span class="tok-number">0</span>,</span>
<span class="line" id="L290">            Secondary = <span class="tok-number">1</span>,</span>
<span class="line" id="L291">        };</span>
<span class="line" id="L292"></span>
<span class="line" id="L293">        <span class="tok-type">type</span>: DevicePathType,</span>
<span class="line" id="L294">        subtype: Subtype,</span>
<span class="line" id="L295">        length: <span class="tok-type">u16</span>,</span>
<span class="line" id="L296">        primary_secondary: Rank,</span>
<span class="line" id="L297">        slave_master: Role,</span>
<span class="line" id="L298">        logical_unit_number: <span class="tok-type">u16</span>,</span>
<span class="line" id="L299">    };</span>
<span class="line" id="L300"></span>
<span class="line" id="L301">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> ScsiDevicePath = <span class="tok-kw">packed</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L302">        <span class="tok-type">type</span>: DevicePathType,</span>
<span class="line" id="L303">        subtype: Subtype,</span>
<span class="line" id="L304">        length: <span class="tok-type">u16</span>,</span>
<span class="line" id="L305">        target_id: <span class="tok-type">u16</span>,</span>
<span class="line" id="L306">        logical_unit_number: <span class="tok-type">u16</span>,</span>
<span class="line" id="L307">    };</span>
<span class="line" id="L308"></span>
<span class="line" id="L309">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> FibreChannelDevicePath = <span class="tok-kw">packed</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L310">        <span class="tok-type">type</span>: DevicePathType,</span>
<span class="line" id="L311">        subtype: Subtype,</span>
<span class="line" id="L312">        length: <span class="tok-type">u16</span>,</span>
<span class="line" id="L313">        reserved: <span class="tok-type">u32</span>,</span>
<span class="line" id="L314">        world_wide_name: <span class="tok-type">u64</span>,</span>
<span class="line" id="L315">        logical_unit_number: <span class="tok-type">u64</span>,</span>
<span class="line" id="L316">    };</span>
<span class="line" id="L317"></span>
<span class="line" id="L318">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> FibreChannelExDevicePath = <span class="tok-kw">packed</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L319">        <span class="tok-type">type</span>: DevicePathType,</span>
<span class="line" id="L320">        subtype: Subtype,</span>
<span class="line" id="L321">        length: <span class="tok-type">u16</span>,</span>
<span class="line" id="L322">        reserved: <span class="tok-type">u32</span>,</span>
<span class="line" id="L323">        world_wide_name: [<span class="tok-number">8</span>]<span class="tok-type">u8</span>,</span>
<span class="line" id="L324">        logical_unit_number: [<span class="tok-number">8</span>]<span class="tok-type">u8</span>,</span>
<span class="line" id="L325">    };</span>
<span class="line" id="L326"></span>
<span class="line" id="L327">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> F1394DevicePath = <span class="tok-kw">packed</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L328">        <span class="tok-type">type</span>: DevicePathType,</span>
<span class="line" id="L329">        subtype: Subtype,</span>
<span class="line" id="L330">        length: <span class="tok-type">u16</span>,</span>
<span class="line" id="L331">        reserved: <span class="tok-type">u32</span>,</span>
<span class="line" id="L332">        guid: <span class="tok-type">u64</span>,</span>
<span class="line" id="L333">    };</span>
<span class="line" id="L334"></span>
<span class="line" id="L335">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> UsbDevicePath = <span class="tok-kw">packed</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L336">        <span class="tok-type">type</span>: DevicePathType,</span>
<span class="line" id="L337">        subtype: Subtype,</span>
<span class="line" id="L338">        length: <span class="tok-type">u16</span>,</span>
<span class="line" id="L339">        parent_port_number: <span class="tok-type">u8</span>,</span>
<span class="line" id="L340">        interface_number: <span class="tok-type">u8</span>,</span>
<span class="line" id="L341">    };</span>
<span class="line" id="L342"></span>
<span class="line" id="L343">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> SataDevicePath = <span class="tok-kw">packed</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L344">        <span class="tok-type">type</span>: DevicePathType,</span>
<span class="line" id="L345">        subtype: Subtype,</span>
<span class="line" id="L346">        length: <span class="tok-type">u16</span>,</span>
<span class="line" id="L347">        hba_port_number: <span class="tok-type">u16</span>,</span>
<span class="line" id="L348">        port_multiplier_port_number: <span class="tok-type">u16</span>,</span>
<span class="line" id="L349">        logical_unit_number: <span class="tok-type">u16</span>,</span>
<span class="line" id="L350">    };</span>
<span class="line" id="L351"></span>
<span class="line" id="L352">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> UsbWwidDevicePath = <span class="tok-kw">packed</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L353">        <span class="tok-type">type</span>: DevicePathType,</span>
<span class="line" id="L354">        subtype: Subtype,</span>
<span class="line" id="L355">        length: <span class="tok-type">u16</span>,</span>
<span class="line" id="L356">        interface_number: <span class="tok-type">u16</span>,</span>
<span class="line" id="L357">        device_vendor_id: <span class="tok-type">u16</span>,</span>
<span class="line" id="L358">        device_product_id: <span class="tok-type">u16</span>,</span>
<span class="line" id="L359"></span>
<span class="line" id="L360">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">serial_number</span>(self: *<span class="tok-kw">const</span> UsbWwidDevicePath) []<span class="tok-kw">const</span> <span class="tok-type">u16</span> {</span>
<span class="line" id="L361">            <span class="tok-kw">var</span> serial_len = (self.length - <span class="tok-builtin">@sizeOf</span>(UsbWwidDevicePath)) / <span class="tok-builtin">@sizeOf</span>(<span class="tok-type">u16</span>);</span>
<span class="line" id="L362">            <span class="tok-kw">return</span> <span class="tok-builtin">@ptrCast</span>([*]<span class="tok-type">u16</span>, <span class="tok-builtin">@ptrCast</span>([*]<span class="tok-type">u8</span>, self) + <span class="tok-builtin">@sizeOf</span>(UsbWwidDevicePath))[<span class="tok-number">0</span>..serial_len];</span>
<span class="line" id="L363">        }</span>
<span class="line" id="L364">    };</span>
<span class="line" id="L365"></span>
<span class="line" id="L366">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> DeviceLogicalUnitDevicePath = <span class="tok-kw">packed</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L367">        <span class="tok-type">type</span>: DevicePathType,</span>
<span class="line" id="L368">        subtype: Subtype,</span>
<span class="line" id="L369">        length: <span class="tok-type">u16</span>,</span>
<span class="line" id="L370">        lun: <span class="tok-type">u8</span>,</span>
<span class="line" id="L371">    };</span>
<span class="line" id="L372"></span>
<span class="line" id="L373">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> UsbClassDevicePath = <span class="tok-kw">packed</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L374">        <span class="tok-type">type</span>: DevicePathType,</span>
<span class="line" id="L375">        subtype: Subtype,</span>
<span class="line" id="L376">        length: <span class="tok-type">u16</span>,</span>
<span class="line" id="L377">        vendor_id: <span class="tok-type">u16</span>,</span>
<span class="line" id="L378">        product_id: <span class="tok-type">u16</span>,</span>
<span class="line" id="L379">        device_class: <span class="tok-type">u8</span>,</span>
<span class="line" id="L380">        device_subclass: <span class="tok-type">u8</span>,</span>
<span class="line" id="L381">        device_protocol: <span class="tok-type">u8</span>,</span>
<span class="line" id="L382">    };</span>
<span class="line" id="L383"></span>
<span class="line" id="L384">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> I2oDevicePath = <span class="tok-kw">packed</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L385">        <span class="tok-type">type</span>: DevicePathType,</span>
<span class="line" id="L386">        subtype: Subtype,</span>
<span class="line" id="L387">        length: <span class="tok-type">u16</span>,</span>
<span class="line" id="L388">        tid: <span class="tok-type">u32</span>,</span>
<span class="line" id="L389">    };</span>
<span class="line" id="L390"></span>
<span class="line" id="L391">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> MacAddressDevicePath = <span class="tok-kw">packed</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L392">        <span class="tok-type">type</span>: DevicePathType,</span>
<span class="line" id="L393">        subtype: Subtype,</span>
<span class="line" id="L394">        length: <span class="tok-type">u16</span>,</span>
<span class="line" id="L395">        mac_address: uefi.MacAddress,</span>
<span class="line" id="L396">        if_type: <span class="tok-type">u8</span>,</span>
<span class="line" id="L397">    };</span>
<span class="line" id="L398"></span>
<span class="line" id="L399">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> Ipv4DevicePath = <span class="tok-kw">packed</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L400">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> IpType = <span class="tok-kw">enum</span>(<span class="tok-type">u8</span>) {</span>
<span class="line" id="L401">            Dhcp = <span class="tok-number">0</span>,</span>
<span class="line" id="L402">            Static = <span class="tok-number">1</span>,</span>
<span class="line" id="L403">        };</span>
<span class="line" id="L404"></span>
<span class="line" id="L405">        <span class="tok-type">type</span>: DevicePathType,</span>
<span class="line" id="L406">        subtype: Subtype,</span>
<span class="line" id="L407">        length: <span class="tok-type">u16</span>,</span>
<span class="line" id="L408">        local_ip_address: uefi.Ipv4Address,</span>
<span class="line" id="L409">        remote_ip_address: uefi.Ipv4Address,</span>
<span class="line" id="L410">        local_port: <span class="tok-type">u16</span>,</span>
<span class="line" id="L411">        remote_port: <span class="tok-type">u16</span>,</span>
<span class="line" id="L412">        network_protocol: <span class="tok-type">u16</span>,</span>
<span class="line" id="L413">        static_ip_address: IpType,</span>
<span class="line" id="L414">        gateway_ip_address: <span class="tok-type">u32</span>,</span>
<span class="line" id="L415">        subnet_mask: <span class="tok-type">u32</span>,</span>
<span class="line" id="L416">    };</span>
<span class="line" id="L417"></span>
<span class="line" id="L418">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> Ipv6DevicePath = <span class="tok-kw">packed</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L419">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> Origin = <span class="tok-kw">enum</span>(<span class="tok-type">u8</span>) {</span>
<span class="line" id="L420">            Manual = <span class="tok-number">0</span>,</span>
<span class="line" id="L421">            AssignedStateless = <span class="tok-number">1</span>,</span>
<span class="line" id="L422">            AssignedStateful = <span class="tok-number">2</span>,</span>
<span class="line" id="L423">        };</span>
<span class="line" id="L424"></span>
<span class="line" id="L425">        <span class="tok-type">type</span>: DevicePathType,</span>
<span class="line" id="L426">        subtype: Subtype,</span>
<span class="line" id="L427">        length: <span class="tok-type">u16</span>,</span>
<span class="line" id="L428">        local_ip_address: uefi.Ipv6Address,</span>
<span class="line" id="L429">        remote_ip_address: uefi.Ipv6Address,</span>
<span class="line" id="L430">        local_port: <span class="tok-type">u16</span>,</span>
<span class="line" id="L431">        remote_port: <span class="tok-type">u16</span>,</span>
<span class="line" id="L432">        protocol: <span class="tok-type">u16</span>,</span>
<span class="line" id="L433">        ip_address_origin: Origin,</span>
<span class="line" id="L434">        prefix_length: <span class="tok-type">u8</span>,</span>
<span class="line" id="L435">        gateway_ip_address: uefi.Ipv6Address,</span>
<span class="line" id="L436">    };</span>
<span class="line" id="L437"></span>
<span class="line" id="L438">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> VlanDevicePath = <span class="tok-kw">packed</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L439">        <span class="tok-type">type</span>: DevicePathType,</span>
<span class="line" id="L440">        subtype: Subtype,</span>
<span class="line" id="L441">        length: <span class="tok-type">u16</span>,</span>
<span class="line" id="L442">        vlan_id: <span class="tok-type">u16</span>,</span>
<span class="line" id="L443">    };</span>
<span class="line" id="L444"></span>
<span class="line" id="L445">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> InfiniBandDevicePath = <span class="tok-kw">packed</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L446">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> ResourceFlags = <span class="tok-kw">packed</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L447">            <span class="tok-kw">pub</span> <span class="tok-kw">const</span> ControllerType = <span class="tok-kw">enum</span>(<span class="tok-type">u1</span>) {</span>
<span class="line" id="L448">                Ioc = <span class="tok-number">0</span>,</span>
<span class="line" id="L449">                Service = <span class="tok-number">1</span>,</span>
<span class="line" id="L450">            };</span>
<span class="line" id="L451"></span>
<span class="line" id="L452">            ioc_or_service: ControllerType,</span>
<span class="line" id="L453">            extend_boot_environment: <span class="tok-type">bool</span>,</span>
<span class="line" id="L454">            console_protocol: <span class="tok-type">bool</span>,</span>
<span class="line" id="L455">            storage_protocol: <span class="tok-type">bool</span>,</span>
<span class="line" id="L456">            network_protocol: <span class="tok-type">bool</span>,</span>
<span class="line" id="L457"></span>
<span class="line" id="L458">            <span class="tok-comment">// u1 + 4 * bool = 5 bits, we need a total of 32 bits</span>
</span>
<span class="line" id="L459">            reserved: <span class="tok-type">u27</span>,</span>
<span class="line" id="L460">        };</span>
<span class="line" id="L461"></span>
<span class="line" id="L462">        <span class="tok-type">type</span>: DevicePathType,</span>
<span class="line" id="L463">        subtype: Subtype,</span>
<span class="line" id="L464">        length: <span class="tok-type">u16</span>,</span>
<span class="line" id="L465">        resource_flags: ResourceFlags,</span>
<span class="line" id="L466">        port_gid: [<span class="tok-number">16</span>]<span class="tok-type">u8</span>,</span>
<span class="line" id="L467">        service_id: <span class="tok-type">u64</span>,</span>
<span class="line" id="L468">        target_port_id: <span class="tok-type">u64</span>,</span>
<span class="line" id="L469">        device_id: <span class="tok-type">u64</span>,</span>
<span class="line" id="L470">    };</span>
<span class="line" id="L471"></span>
<span class="line" id="L472">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> UartDevicePath = <span class="tok-kw">packed</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L473">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> Parity = <span class="tok-kw">enum</span>(<span class="tok-type">u8</span>) {</span>
<span class="line" id="L474">            Default = <span class="tok-number">0</span>,</span>
<span class="line" id="L475">            None = <span class="tok-number">1</span>,</span>
<span class="line" id="L476">            Even = <span class="tok-number">2</span>,</span>
<span class="line" id="L477">            Odd = <span class="tok-number">3</span>,</span>
<span class="line" id="L478">            Mark = <span class="tok-number">4</span>,</span>
<span class="line" id="L479">            Space = <span class="tok-number">5</span>,</span>
<span class="line" id="L480">            _,</span>
<span class="line" id="L481">        };</span>
<span class="line" id="L482"></span>
<span class="line" id="L483">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> StopBits = <span class="tok-kw">enum</span>(<span class="tok-type">u8</span>) {</span>
<span class="line" id="L484">            Default = <span class="tok-number">0</span>,</span>
<span class="line" id="L485">            One = <span class="tok-number">1</span>,</span>
<span class="line" id="L486">            OneAndAHalf = <span class="tok-number">2</span>,</span>
<span class="line" id="L487">            Two = <span class="tok-number">3</span>,</span>
<span class="line" id="L488">            _,</span>
<span class="line" id="L489">        };</span>
<span class="line" id="L490"></span>
<span class="line" id="L491">        <span class="tok-type">type</span>: DevicePathType,</span>
<span class="line" id="L492">        subtype: Subtype,</span>
<span class="line" id="L493">        length: <span class="tok-type">u16</span>,</span>
<span class="line" id="L494">        reserved: <span class="tok-type">u16</span>,</span>
<span class="line" id="L495">        baud_rate: <span class="tok-type">u32</span>,</span>
<span class="line" id="L496">        data_bits: <span class="tok-type">u8</span>,</span>
<span class="line" id="L497">        parity: Parity,</span>
<span class="line" id="L498">        stop_bits: StopBits,</span>
<span class="line" id="L499">    };</span>
<span class="line" id="L500"></span>
<span class="line" id="L501">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> VendorDefinedDevicePath = <span class="tok-kw">packed</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L502">        <span class="tok-type">type</span>: DevicePathType,</span>
<span class="line" id="L503">        subtype: Subtype,</span>
<span class="line" id="L504">        length: <span class="tok-type">u16</span>,</span>
<span class="line" id="L505">        vendor_guid: Guid,</span>
<span class="line" id="L506">    };</span>
<span class="line" id="L507">};</span>
<span class="line" id="L508"></span>
<span class="line" id="L509"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> MediaDevicePath = <span class="tok-kw">union</span>(Subtype) {</span>
<span class="line" id="L510">    HardDrive: *<span class="tok-kw">const</span> HardDriveDevicePath,</span>
<span class="line" id="L511">    Cdrom: *<span class="tok-kw">const</span> CdromDevicePath,</span>
<span class="line" id="L512">    Vendor: *<span class="tok-kw">const</span> VendorDevicePath,</span>
<span class="line" id="L513">    FilePath: *<span class="tok-kw">const</span> FilePathDevicePath,</span>
<span class="line" id="L514">    MediaProtocol: *<span class="tok-kw">const</span> MediaProtocolDevicePath,</span>
<span class="line" id="L515">    PiwgFirmwareFile: *<span class="tok-kw">const</span> PiwgFirmwareFileDevicePath,</span>
<span class="line" id="L516">    PiwgFirmwareVolume: *<span class="tok-kw">const</span> PiwgFirmwareVolumeDevicePath,</span>
<span class="line" id="L517">    RelativeOffsetRange: *<span class="tok-kw">const</span> RelativeOffsetRangeDevicePath,</span>
<span class="line" id="L518">    RamDisk: *<span class="tok-kw">const</span> RamDiskDevicePath,</span>
<span class="line" id="L519"></span>
<span class="line" id="L520">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> Subtype = <span class="tok-kw">enum</span>(<span class="tok-type">u8</span>) {</span>
<span class="line" id="L521">        HardDrive = <span class="tok-number">1</span>,</span>
<span class="line" id="L522">        Cdrom = <span class="tok-number">2</span>,</span>
<span class="line" id="L523">        Vendor = <span class="tok-number">3</span>,</span>
<span class="line" id="L524">        FilePath = <span class="tok-number">4</span>,</span>
<span class="line" id="L525">        MediaProtocol = <span class="tok-number">5</span>,</span>
<span class="line" id="L526">        PiwgFirmwareFile = <span class="tok-number">6</span>,</span>
<span class="line" id="L527">        PiwgFirmwareVolume = <span class="tok-number">7</span>,</span>
<span class="line" id="L528">        RelativeOffsetRange = <span class="tok-number">8</span>,</span>
<span class="line" id="L529">        RamDisk = <span class="tok-number">9</span>,</span>
<span class="line" id="L530">        _,</span>
<span class="line" id="L531">    };</span>
<span class="line" id="L532"></span>
<span class="line" id="L533">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> HardDriveDevicePath = <span class="tok-kw">packed</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L534">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> Format = <span class="tok-kw">enum</span>(<span class="tok-type">u8</span>) {</span>
<span class="line" id="L535">            LegacyMbr = <span class="tok-number">0x01</span>,</span>
<span class="line" id="L536">            GuidPartitionTable = <span class="tok-number">0x02</span>,</span>
<span class="line" id="L537">        };</span>
<span class="line" id="L538"></span>
<span class="line" id="L539">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> SignatureType = <span class="tok-kw">enum</span>(<span class="tok-type">u8</span>) {</span>
<span class="line" id="L540">            NoSignature = <span class="tok-number">0x00</span>,</span>
<span class="line" id="L541">            <span class="tok-comment">/// &quot;32-bit signature from address 0x1b8 of the type 0x01 MBR&quot;</span></span>
<span class="line" id="L542">            MbrSignature = <span class="tok-number">0x01</span>,</span>
<span class="line" id="L543">            GuidSignature = <span class="tok-number">0x02</span>,</span>
<span class="line" id="L544">        };</span>
<span class="line" id="L545"></span>
<span class="line" id="L546">        <span class="tok-type">type</span>: DevicePathType,</span>
<span class="line" id="L547">        subtype: Subtype,</span>
<span class="line" id="L548">        length: <span class="tok-type">u16</span>,</span>
<span class="line" id="L549">        partition_number: <span class="tok-type">u32</span>,</span>
<span class="line" id="L550">        partition_start: <span class="tok-type">u64</span>,</span>
<span class="line" id="L551">        partition_size: <span class="tok-type">u64</span>,</span>
<span class="line" id="L552">        partition_signature: [<span class="tok-number">16</span>]<span class="tok-type">u8</span>,</span>
<span class="line" id="L553">        partition_format: Format,</span>
<span class="line" id="L554">        signature_type: SignatureType,</span>
<span class="line" id="L555">    };</span>
<span class="line" id="L556"></span>
<span class="line" id="L557">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> CdromDevicePath = <span class="tok-kw">packed</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L558">        <span class="tok-type">type</span>: DevicePathType,</span>
<span class="line" id="L559">        subtype: Subtype,</span>
<span class="line" id="L560">        length: <span class="tok-type">u16</span>,</span>
<span class="line" id="L561">        boot_entry: <span class="tok-type">u32</span>,</span>
<span class="line" id="L562">        partition_start: <span class="tok-type">u64</span>,</span>
<span class="line" id="L563">        partition_size: <span class="tok-type">u64</span>,</span>
<span class="line" id="L564">    };</span>
<span class="line" id="L565"></span>
<span class="line" id="L566">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> VendorDevicePath = <span class="tok-kw">packed</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L567">        <span class="tok-type">type</span>: DevicePathType,</span>
<span class="line" id="L568">        subtype: Subtype,</span>
<span class="line" id="L569">        length: <span class="tok-type">u16</span>,</span>
<span class="line" id="L570">        guid: Guid,</span>
<span class="line" id="L571">        <span class="tok-comment">// vendor-defined variable data</span>
</span>
<span class="line" id="L572">    };</span>
<span class="line" id="L573"></span>
<span class="line" id="L574">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> FilePathDevicePath = <span class="tok-kw">packed</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L575">        <span class="tok-type">type</span>: DevicePathType,</span>
<span class="line" id="L576">        subtype: Subtype,</span>
<span class="line" id="L577">        length: <span class="tok-type">u16</span>,</span>
<span class="line" id="L578"></span>
<span class="line" id="L579">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">getPath</span>(self: *<span class="tok-kw">const</span> FilePathDevicePath) [*:<span class="tok-number">0</span>]<span class="tok-kw">const</span> <span class="tok-type">u16</span> {</span>
<span class="line" id="L580">            <span class="tok-kw">return</span> <span class="tok-builtin">@ptrCast</span>([*:<span class="tok-number">0</span>]<span class="tok-kw">const</span> <span class="tok-type">u16</span>, <span class="tok-builtin">@alignCast</span>(<span class="tok-number">2</span>, <span class="tok-builtin">@ptrCast</span>([*]<span class="tok-kw">const</span> <span class="tok-type">u8</span>, self)) + <span class="tok-builtin">@sizeOf</span>(FilePathDevicePath));</span>
<span class="line" id="L581">        }</span>
<span class="line" id="L582">    };</span>
<span class="line" id="L583"></span>
<span class="line" id="L584">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> MediaProtocolDevicePath = <span class="tok-kw">packed</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L585">        <span class="tok-type">type</span>: DevicePathType,</span>
<span class="line" id="L586">        subtype: Subtype,</span>
<span class="line" id="L587">        length: <span class="tok-type">u16</span>,</span>
<span class="line" id="L588">        guid: Guid,</span>
<span class="line" id="L589">    };</span>
<span class="line" id="L590"></span>
<span class="line" id="L591">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> PiwgFirmwareFileDevicePath = <span class="tok-kw">packed</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L592">        <span class="tok-type">type</span>: DevicePathType,</span>
<span class="line" id="L593">        subtype: Subtype,</span>
<span class="line" id="L594">        length: <span class="tok-type">u16</span>,</span>
<span class="line" id="L595">        fv_filename: Guid,</span>
<span class="line" id="L596">    };</span>
<span class="line" id="L597"></span>
<span class="line" id="L598">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> PiwgFirmwareVolumeDevicePath = <span class="tok-kw">packed</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L599">        <span class="tok-type">type</span>: DevicePathType,</span>
<span class="line" id="L600">        subtype: Subtype,</span>
<span class="line" id="L601">        length: <span class="tok-type">u16</span>,</span>
<span class="line" id="L602">        fv_name: Guid,</span>
<span class="line" id="L603">    };</span>
<span class="line" id="L604"></span>
<span class="line" id="L605">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> RelativeOffsetRangeDevicePath = <span class="tok-kw">packed</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L606">        <span class="tok-type">type</span>: DevicePathType,</span>
<span class="line" id="L607">        subtype: Subtype,</span>
<span class="line" id="L608">        length: <span class="tok-type">u16</span>,</span>
<span class="line" id="L609">        reserved: <span class="tok-type">u32</span>,</span>
<span class="line" id="L610">        start: <span class="tok-type">u64</span>,</span>
<span class="line" id="L611">        end: <span class="tok-type">u64</span>,</span>
<span class="line" id="L612">    };</span>
<span class="line" id="L613"></span>
<span class="line" id="L614">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> RamDiskDevicePath = <span class="tok-kw">packed</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L615">        <span class="tok-type">type</span>: DevicePathType,</span>
<span class="line" id="L616">        subtype: Subtype,</span>
<span class="line" id="L617">        length: <span class="tok-type">u16</span>,</span>
<span class="line" id="L618">        start: <span class="tok-type">u64</span>,</span>
<span class="line" id="L619">        end: <span class="tok-type">u64</span>,</span>
<span class="line" id="L620">        disk_type: Guid,</span>
<span class="line" id="L621">        instance: <span class="tok-type">u16</span>,</span>
<span class="line" id="L622">    };</span>
<span class="line" id="L623">};</span>
<span class="line" id="L624"></span>
<span class="line" id="L625"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> BiosBootSpecificationDevicePath = <span class="tok-kw">union</span>(Subtype) {</span>
<span class="line" id="L626">    BBS101: *<span class="tok-kw">const</span> BBS101DevicePath,</span>
<span class="line" id="L627"></span>
<span class="line" id="L628">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> Subtype = <span class="tok-kw">enum</span>(<span class="tok-type">u8</span>) {</span>
<span class="line" id="L629">        BBS101 = <span class="tok-number">1</span>,</span>
<span class="line" id="L630">        _,</span>
<span class="line" id="L631">    };</span>
<span class="line" id="L632"></span>
<span class="line" id="L633">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> BBS101DevicePath = <span class="tok-kw">packed</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L634">        <span class="tok-type">type</span>: DevicePathType,</span>
<span class="line" id="L635">        subtype: Subtype,</span>
<span class="line" id="L636">        length: <span class="tok-type">u16</span>,</span>
<span class="line" id="L637">        device_type: <span class="tok-type">u16</span>,</span>
<span class="line" id="L638">        status_flag: <span class="tok-type">u16</span>,</span>
<span class="line" id="L639"></span>
<span class="line" id="L640">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">getDescription</span>(self: *<span class="tok-kw">const</span> BBS101DevicePath) [*:<span class="tok-number">0</span>]<span class="tok-kw">const</span> <span class="tok-type">u8</span> {</span>
<span class="line" id="L641">            <span class="tok-kw">return</span> <span class="tok-builtin">@ptrCast</span>([*:<span class="tok-number">0</span>]<span class="tok-kw">const</span> <span class="tok-type">u8</span>, self) + <span class="tok-builtin">@sizeOf</span>(BBS101DevicePath);</span>
<span class="line" id="L642">        }</span>
<span class="line" id="L643">    };</span>
<span class="line" id="L644">};</span>
<span class="line" id="L645"></span>
<span class="line" id="L646"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> EndDevicePath = <span class="tok-kw">union</span>(Subtype) {</span>
<span class="line" id="L647">    EndEntire: *<span class="tok-kw">const</span> EndEntireDevicePath,</span>
<span class="line" id="L648">    EndThisInstance: *<span class="tok-kw">const</span> EndThisInstanceDevicePath,</span>
<span class="line" id="L649"></span>
<span class="line" id="L650">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> Subtype = <span class="tok-kw">enum</span>(<span class="tok-type">u8</span>) {</span>
<span class="line" id="L651">        EndEntire = <span class="tok-number">0xff</span>,</span>
<span class="line" id="L652">        EndThisInstance = <span class="tok-number">0x01</span>,</span>
<span class="line" id="L653">        _,</span>
<span class="line" id="L654">    };</span>
<span class="line" id="L655"></span>
<span class="line" id="L656">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> EndEntireDevicePath = <span class="tok-kw">packed</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L657">        <span class="tok-type">type</span>: DevicePathType,</span>
<span class="line" id="L658">        subtype: Subtype,</span>
<span class="line" id="L659">        length: <span class="tok-type">u16</span>,</span>
<span class="line" id="L660">    };</span>
<span class="line" id="L661"></span>
<span class="line" id="L662">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> EndThisInstanceDevicePath = <span class="tok-kw">packed</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L663">        <span class="tok-type">type</span>: DevicePathType,</span>
<span class="line" id="L664">        subtype: Subtype,</span>
<span class="line" id="L665">        length: <span class="tok-type">u16</span>,</span>
<span class="line" id="L666">    };</span>
<span class="line" id="L667">};</span>
<span class="line" id="L668"></span>
</code></pre></body>
</html>