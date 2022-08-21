<!doctype html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">    <title>os/uefi/protocols/ip6_config_protocol.zig - source view</title>
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
<pre><code><span class="line" id="L1"><span class="tok-kw">const</span> uefi = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;std&quot;</span>).os.uefi;</span>
<span class="line" id="L2"><span class="tok-kw">const</span> Guid = uefi.Guid;</span>
<span class="line" id="L3"><span class="tok-kw">const</span> Event = uefi.Event;</span>
<span class="line" id="L4"><span class="tok-kw">const</span> Status = uefi.Status;</span>
<span class="line" id="L5"></span>
<span class="line" id="L6"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> Ip6ConfigProtocol = <span class="tok-kw">extern</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L7">    _set_data: <span class="tok-kw">fn</span> (*<span class="tok-kw">const</span> Ip6ConfigProtocol, Ip6ConfigDataType, <span class="tok-type">usize</span>, *<span class="tok-kw">const</span> <span class="tok-type">anyopaque</span>) <span class="tok-kw">callconv</span>(.C) Status,</span>
<span class="line" id="L8">    _get_data: <span class="tok-kw">fn</span> (*<span class="tok-kw">const</span> Ip6ConfigProtocol, Ip6ConfigDataType, *<span class="tok-type">usize</span>, ?*<span class="tok-kw">const</span> <span class="tok-type">anyopaque</span>) <span class="tok-kw">callconv</span>(.C) Status,</span>
<span class="line" id="L9">    _register_data_notify: <span class="tok-kw">fn</span> (*<span class="tok-kw">const</span> Ip6ConfigProtocol, Ip6ConfigDataType, Event) <span class="tok-kw">callconv</span>(.C) Status,</span>
<span class="line" id="L10">    _unregister_data_notify: <span class="tok-kw">fn</span> (*<span class="tok-kw">const</span> Ip6ConfigProtocol, Ip6ConfigDataType, Event) <span class="tok-kw">callconv</span>(.C) Status,</span>
<span class="line" id="L11"></span>
<span class="line" id="L12">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">setData</span>(self: *<span class="tok-kw">const</span> Ip6ConfigProtocol, data_type: Ip6ConfigDataType, data_size: <span class="tok-type">usize</span>, data: *<span class="tok-kw">const</span> <span class="tok-type">anyopaque</span>) Status {</span>
<span class="line" id="L13">        <span class="tok-kw">return</span> self._set_data(self, data_type, data_size, data);</span>
<span class="line" id="L14">    }</span>
<span class="line" id="L15"></span>
<span class="line" id="L16">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">getData</span>(self: *<span class="tok-kw">const</span> Ip6ConfigProtocol, data_type: Ip6ConfigDataType, data_size: *<span class="tok-type">usize</span>, data: ?*<span class="tok-kw">const</span> <span class="tok-type">anyopaque</span>) Status {</span>
<span class="line" id="L17">        <span class="tok-kw">return</span> self._get_data(self, data_type, data_size, data);</span>
<span class="line" id="L18">    }</span>
<span class="line" id="L19"></span>
<span class="line" id="L20">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">registerDataNotify</span>(self: *<span class="tok-kw">const</span> Ip6ConfigProtocol, data_type: Ip6ConfigDataType, event: Event) Status {</span>
<span class="line" id="L21">        <span class="tok-kw">return</span> self._register_data_notify(self, data_type, event);</span>
<span class="line" id="L22">    }</span>
<span class="line" id="L23"></span>
<span class="line" id="L24">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">unregisterDataNotify</span>(self: *<span class="tok-kw">const</span> Ip6ConfigProtocol, data_type: Ip6ConfigDataType, event: Event) Status {</span>
<span class="line" id="L25">        <span class="tok-kw">return</span> self._unregister_data_notify(self, data_type, event);</span>
<span class="line" id="L26">    }</span>
<span class="line" id="L27"></span>
<span class="line" id="L28">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> guid <span class="tok-kw">align</span>(<span class="tok-number">8</span>) = Guid{</span>
<span class="line" id="L29">        .time_low = <span class="tok-number">0x937fe521</span>,</span>
<span class="line" id="L30">        .time_mid = <span class="tok-number">0x95ae</span>,</span>
<span class="line" id="L31">        .time_high_and_version = <span class="tok-number">0x4d1a</span>,</span>
<span class="line" id="L32">        .clock_seq_high_and_reserved = <span class="tok-number">0x89</span>,</span>
<span class="line" id="L33">        .clock_seq_low = <span class="tok-number">0x29</span>,</span>
<span class="line" id="L34">        .node = [_]<span class="tok-type">u8</span>{ <span class="tok-number">0x48</span>, <span class="tok-number">0xbc</span>, <span class="tok-number">0xd9</span>, <span class="tok-number">0x0a</span>, <span class="tok-number">0xd3</span>, <span class="tok-number">0x1a</span> },</span>
<span class="line" id="L35">    };</span>
<span class="line" id="L36">};</span>
<span class="line" id="L37"></span>
<span class="line" id="L38"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> Ip6ConfigDataType = <span class="tok-kw">enum</span>(<span class="tok-type">u32</span>) {</span>
<span class="line" id="L39">    InterfaceInfo,</span>
<span class="line" id="L40">    AltInterfaceId,</span>
<span class="line" id="L41">    Policy,</span>
<span class="line" id="L42">    DupAddrDetectTransmits,</span>
<span class="line" id="L43">    ManualAddress,</span>
<span class="line" id="L44">    Gateway,</span>
<span class="line" id="L45">    DnsServer,</span>
<span class="line" id="L46">};</span>
<span class="line" id="L47"></span>
</code></pre></body>
</html>