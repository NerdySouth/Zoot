 /** @type {DocData} */
 var zigAnalysis={
 "typeKinds": ["Unanalyzed","Type","Void","Bool","NoReturn","Int","Float","Pointer","Array","Struct","ComptimeExpr","ComptimeFloat","ComptimeInt","Undefined","Null","Optional","ErrorUnion","InferredErrorUnion","ErrorSet","Enum","Union","Fn","BoundFn","Opaque","Frame","AnyFrame","Vector","EnumLiteral"],
 "rootPkg": 0,
 "rootPkgName": "main",
 "params": {"zigId": "arst","zigVersion": "0.10.0-dev.3659+e5e6eb983","target": "arst","rootName": "root","builds": [{"target": "arst"}]},
 "packages": [{
 "name": "root",
 "file": 0,
 "main": 61,
 "table": {
  "root": 0
 }
}],
 "errors": [],
 "astNodes": [{"file": 0,"line": 0,"col": 0,"name": "(root)","fields": [],"comptime": false},{"file": 0,"line": 0,"col": 0,"fields": [],"comptime": false},{"file": 1,"line": 0,"col": 0,"fields": [],"comptime": false},{"file": 2,"line": 3,"col": 0,"docs": " A register can be read or written, but may have different behavior or characteristics depending on which\n you choose to do. This allows us to instantiate Register instances that\n can handle that fact by having distinct read and write types.","fields": [4,5],"comptime": false},{"file": 0,"line": 0,"col": 0,"name": "Read","docs": "","comptime": true},{"file": 0,"line": 0,"col": 0,"name": "Write","docs": "","fields": [22],"comptime": true},{"file": 2,"line": 8,"col": 0,"comptime": false},{"file": 2,"line": 13,"col": 0,"fields": [8],"comptime": false},{"file": 0,"line": 0,"col": 0,"name": "addr","docs": "","comptime": true},{"file": 2,"line": 26,"col": 0,"fields": [10],"comptime": false},{"file": 0,"line": 0,"col": 0,"name": "self","docs": "","comptime": false},{"file": 2,"line": 39,"col": 0,"fields": [12,13],"comptime": false},{"file": 0,"line": 0,"col": 0,"name": "self","docs": "","comptime": false},{"file": 0,"line": 0,"col": 0,"name": "val","docs": "","comptime": false},{"file": 2,"line": 50,"col": 0,"fields": [15],"comptime": false},{"file": 0,"line": 0,"col": 0,"name": "self","docs": "","comptime": false},{"file": 2,"line": 61,"col": 0,"fields": [17,18],"comptime": false},{"file": 0,"line": 0,"col": 0,"name": "self","docs": "","comptime": false},{"file": 0,"line": 0,"col": 0,"name": "val","docs": "","comptime": false},{"file": 2,"line": 74,"col": 0,"fields": [20,21],"comptime": false},{"file": 0,"line": 0,"col": 0,"name": "self","docs": "","comptime": false},{"file": 0,"line": 0,"col": 0,"name": "new_val","docs": "","comptime": false},{"file": 0,"line": 0,"col": 0,"name": "raw_ptr","comptime": false},{"file": 1,"line": 2,"col": 0,"fields": [26,27],"comptime": false},{"file": 1,"line": 4,"col": 0,"fields": [25],"comptime": false},{"file": 0,"line": 0,"col": 0,"name": "base","docs": "","comptime": true},{"file": 0,"line": 0,"col": 0,"name": "data","comptime": false},{"file": 0,"line": 0,"col": 0,"name": "dir","comptime": false},{"file": 1,"line": 14,"col": 0,"fields": [29,30,31,32,33],"comptime": false},{"file": 0,"line": 0,"col": 0,"name": "zero","comptime": false},{"file": 0,"line": 0,"col": 0,"name": "one","comptime": false},{"file": 0,"line": 0,"col": 0,"name": "two","comptime": false},{"file": 0,"line": 0,"col": 0,"name": "three","comptime": false},{"file": 0,"line": 0,"col": 0,"name": "four","comptime": false},{"file": 0,"line": 3,"col": 0,"comptime": false},{"file": 0,"line": 4,"col": 0,"comptime": false},{"file": 0,"line": 6,"col": 0,"fields": [],"comptime": false},{"file": 0,"line": 15,"col": 0,"fields": [],"comptime": false}],
 "calls": [{"func": {
 "refPath": [{
 "declRef": 5
},{
 "declRef": 8
}]
},"args": [{
 "type": 7
},{
 "type": 7
}],"ret": {
 "comptimeExpr": 3
}},{"func": {
 "refPath": [{
 "declRef": 5
},{
 "declRef": 8
}]
},"args": [{
 "type": 7
},{
 "type": 7
}],"ret": {
 "comptimeExpr": 4
}}],
 "files": [
  "main.zig",
  "gpio.zig",
  "mmio.zig"
 ],
 "types": [{
 "kind": 10,
 "name": "ComptimeExpr"
},{
 "kind": 5,
 "name": "u1"
},{
 "kind": 5,
 "name": "u8"
},{
 "kind": 5,
 "name": "i8"
},{
 "kind": 5,
 "name": "u16"
},{
 "kind": 5,
 "name": "i16"
},{
 "kind": 8,
 "len": {
 "int": 1
},
 "child": {
 "type": 0
},
 "sentinel": null
},{
 "kind": 5,
 "name": "u32"
},{
 "kind": 5,
 "name": "i32"
},{
 "kind": 5,
 "name": "u64"
},{
 "kind": 5,
 "name": "i64"
},{
 "kind": 5,
 "name": "u128"
},{
 "kind": 5,
 "name": "i128"
},{
 "kind": 5,
 "name": "usize"
},{
 "kind": 5,
 "name": "isize"
},{
 "kind": 5,
 "name": "c_short"
},{
 "kind": 5,
 "name": "c_ushort"
},{
 "kind": 5,
 "name": "c_int"
},{
 "kind": 5,
 "name": "c_uint"
},{
 "kind": 5,
 "name": "c_long"
},{
 "kind": 5,
 "name": "c_ulong"
},{
 "kind": 5,
 "name": "c_longlong"
},{
 "kind": 5,
 "name": "c_ulonglong"
},{
 "kind": 5,
 "name": "c_longdouble"
},{
 "kind": 6,
 "name": "f16"
},{
 "kind": 6,
 "name": "f32"
},{
 "kind": 6,
 "name": "f64"
},{
 "kind": 8,
 "len": {
 "int": 1
},
 "child": {
 "type": 0
},
 "sentinel": null
},{
 "kind": 6,
 "name": "f128"
},{
 "kind": 10,
 "name": "anyopaque"
},{
 "kind": 3,
 "name": "bool"
},{
 "kind": 2,
 "name": "void"
},{
 "kind": 1,
 "name": "type"
},{
 "kind": 18,
 "name": "anyerror",
 "fields": null
},{
 "kind": 12,
 "name": "comptime_int"
},{
 "kind": 11,
 "name": "comptime_float"
},{
 "kind": 4,
 "name": "noreturn"
},{
 "kind": 8,
 "len": {
 "int": 1
},
 "child": {
 "type": 0
},
 "sentinel": null
},{
 "kind": 8,
 "len": {
 "int": 1
},
 "child": {
 "type": 0
},
 "sentinel": null
},{
 "kind": 8,
 "len": {
 "int": 1
},
 "child": {
 "type": 0
},
 "sentinel": null
},{
 "kind": 8,
 "len": {
 "int": 1
},
 "child": {
 "type": 0
},
 "sentinel": null
},{
 "kind": 8,
 "len": {
 "int": 1
},
 "child": {
 "type": 0
},
 "sentinel": null
},{
 "kind": 8,
 "len": {
 "int": 1
},
 "child": {
 "type": 0
},
 "sentinel": null
},{
 "kind": 27,
 "name": "std.builtin.CallingConvention"
},{
 "kind": 8,
 "len": {
 "int": 1
},
 "child": {
 "type": 0
},
 "sentinel": null
},{
 "kind": 8,
 "len": {
 "int": 1
},
 "child": {
 "type": 0
},
 "sentinel": null
},{
 "kind": 8,
 "len": {
 "int": 1
},
 "child": {
 "type": 0
},
 "sentinel": null
},{
 "kind": 8,
 "len": {
 "int": 1
},
 "child": {
 "type": 0
},
 "sentinel": null
},{
 "kind": 8,
 "len": {
 "int": 1
},
 "child": {
 "type": 0
},
 "sentinel": null
},{
 "kind": 8,
 "len": {
 "int": 1
},
 "child": {
 "type": 0
},
 "sentinel": null
},{
 "kind": 8,
 "len": {
 "int": 1
},
 "child": {
 "type": 0
},
 "sentinel": null
},{
 "kind": 8,
 "len": {
 "int": 1
},
 "child": {
 "type": 0
},
 "sentinel": null
},{
 "kind": 8,
 "len": {
 "int": 1
},
 "child": {
 "type": 0
},
 "sentinel": null
},{
 "kind": 8,
 "len": {
 "int": 1
},
 "child": {
 "type": 0
},
 "sentinel": null
},{
 "kind": 8,
 "len": {
 "int": 1
},
 "child": {
 "type": 0
},
 "sentinel": null
},{
 "kind": 8,
 "len": {
 "int": 1
},
 "child": {
 "type": 0
},
 "sentinel": null
},{
 "kind": 8,
 "len": {
 "int": 1
},
 "child": {
 "type": 0
},
 "sentinel": null
},{
 "kind": 8,
 "len": {
 "int": 1
},
 "child": {
 "type": 0
},
 "sentinel": null
},{
 "kind": 8,
 "len": {
 "int": 1
},
 "child": {
 "type": 0
},
 "sentinel": null
},{
 "kind": 8,
 "len": {
 "int": 1
},
 "child": {
 "type": 0
},
 "sentinel": null
},{
 "kind": 8,
 "len": {
 "int": 1
},
 "child": {
 "type": 0
},
 "sentinel": null
},{
 "kind": 9,
 "name": "todo_name",
 "src": 0,
 "privDecls": [0,1,2,3,4],
 "pubDecls": [],
 "fields": [],
 "line_number": 0,
 "outer_decl": 60,
 "ast": 0
},{
 "kind": 9,
 "name": "todo_name",
 "src": 1,
 "privDecls": [5],
 "pubDecls": [6,7],
 "fields": [],
 "line_number": 0,
 "outer_decl": 61,
 "ast": 1
},{
 "kind": 9,
 "name": "todo_name",
 "src": 2,
 "privDecls": [],
 "pubDecls": [8],
 "fields": [],
 "line_number": 0,
 "outer_decl": 62,
 "ast": 2
},{
 "kind": 21,
 "name": "todo_name func",
 "src": 3,
 "ret": {
 "type": 32
},
 "generic_ret": {
 "as": {"typeRefArg": 1,"exprArg": 0}
},
 "params": [{
 "type": 32
},{
 "type": 32
}],
 "lib_name": "",
 "is_var_args": false,
 "is_inferred_error": false,
 "has_lib_name": false,
 "has_cc": false,
 "cc": null,
 "align": null,
 "has_align": false,
 "is_test": false,
 "is_extern": false
},{
 "kind": 9,
 "name": "todo_name",
 "src": 5,
 "privDecls": [9],
 "pubDecls": [10,11,12,13,14,15],
 "fields": [{
 "type": 72
}],
 "line_number": 0,
 "outer_decl": 64,
 "ast": 5
},{
 "kind": 21,
 "name": "todo_name func",
 "src": 7,
 "ret": {
 "declRef": 9
},
 "generic_ret": null,
 "params": [{
 "type": 7
}],
 "lib_name": "",
 "is_var_args": false,
 "is_inferred_error": false,
 "has_lib_name": false,
 "has_cc": false,
 "cc": null,
 "align": null,
 "has_align": false,
 "is_test": false,
 "is_extern": false
},{
 "kind": 21,
 "name": "todo_name func",
 "src": 9,
 "ret": {
 "type": 7
},
 "generic_ret": null,
 "params": [{
 "declRef": 9
}],
 "lib_name": "",
 "is_var_args": false,
 "is_inferred_error": false,
 "has_lib_name": false,
 "has_cc": false,
 "cc": null,
 "align": null,
 "has_align": false,
 "is_test": false,
 "is_extern": false
},{
 "kind": 21,
 "name": "todo_name func",
 "src": 11,
 "ret": {
 "type": 31
},
 "generic_ret": null,
 "params": [{
 "declRef": 9
},{
 "type": 7
}],
 "lib_name": "",
 "is_var_args": false,
 "is_inferred_error": false,
 "has_lib_name": false,
 "has_cc": false,
 "cc": null,
 "align": null,
 "has_align": false,
 "is_test": false,
 "is_extern": false
},{
 "kind": 21,
 "name": "todo_name func",
 "src": 14,
 "ret": {
 "comptimeExpr": 1
},
 "generic_ret": null,
 "params": [{
 "declRef": 9
}],
 "lib_name": "",
 "is_var_args": false,
 "is_inferred_error": false,
 "has_lib_name": false,
 "has_cc": false,
 "cc": null,
 "align": null,
 "has_align": false,
 "is_test": false,
 "is_extern": false
},{
 "kind": 21,
 "name": "todo_name func",
 "src": 16,
 "ret": {
 "type": 31
},
 "generic_ret": null,
 "params": [{
 "declRef": 9
},{
 "comptimeExpr": 2
}],
 "lib_name": "",
 "is_var_args": false,
 "is_inferred_error": false,
 "has_lib_name": false,
 "has_cc": false,
 "cc": null,
 "align": null,
 "has_align": false,
 "is_test": false,
 "is_extern": false
},{
 "kind": 21,
 "name": "todo_name func",
 "src": 19,
 "ret": {
 "type": 31
},
 "generic_ret": null,
 "params": [{
 "declRef": 9
},{
 "anytype": {}
}],
 "lib_name": "",
 "is_var_args": false,
 "is_inferred_error": false,
 "has_lib_name": false,
 "has_cc": false,
 "cc": null,
 "align": null,
 "has_align": false,
 "is_test": false,
 "is_extern": false
},{
 "kind": 7,
 "size": 0,
 "child": {
 "type": 7
},
 "sentinel": null,
 "align": null,
 "address_space": null,
 "bit_start": null,
 "host_size": null,
 "is_ref": false,
 "is_allowzero": false,
 "is_mutable": true,
 "is_volatile": true,
 "has_sentinel": false,
 "has_align": false,
 "has_addrspace": false,
 "has_bit_range": false
},{
 "kind": 9,
 "name": "todo_name",
 "src": 23,
 "privDecls": [],
 "pubDecls": [16],
 "fields": [{
 "call": 0
},{
 "call": 1
}],
 "line_number": 2,
 "outer_decl": 72,
 "ast": 23
},{
 "kind": 21,
 "name": "todo_name func",
 "src": 24,
 "ret": {
 "declRef": 6
},
 "generic_ret": null,
 "params": [{
 "declRef": 7
}],
 "lib_name": "",
 "is_var_args": false,
 "is_inferred_error": false,
 "has_lib_name": false,
 "has_cc": false,
 "cc": null,
 "align": null,
 "has_align": false,
 "is_test": false,
 "is_extern": false
},{
 "kind": 19,
 "name": "todo_name",
 "src": 28,
 "privDecls": [],
 "pubDecls": [],
 "ast": 28
},{
 "kind": 21,
 "name": "todo_name func",
 "src": 36,
 "ret": {
 "type": 31
},
 "generic_ret": null,
 "params": [],
 "lib_name": "",
 "is_var_args": false,
 "is_inferred_error": false,
 "has_lib_name": false,
 "has_cc": false,
 "cc": null,
 "align": null,
 "has_align": false,
 "is_test": false,
 "is_extern": false
},{
 "kind": 21,
 "name": "todo_name func",
 "src": 37,
 "ret": {
 "type": 36
},
 "generic_ret": null,
 "params": [],
 "lib_name": "",
 "is_var_args": false,
 "is_inferred_error": false,
 "has_lib_name": false,
 "has_cc": false,
 "cc": null,
 "align": null,
 "has_align": false,
 "is_test": false,
 "is_extern": false
}],
 "decls": [{"name": "gpio","kind": "const","isTest": false,"src": 1,"value": {"typeRef": {
 "type": 32
},"expr": {
 "type": 62
}},"_analyzed": true},{"name": "__bss_start","kind": "const","isTest": false,"src": 34,"value": {"expr": {
 "void": {}
}},"_analyzed": true},{"name": "__bss_end","kind": "const","isTest": false,"src": 35,"value": {"expr": {
 "void": {}
}},"_analyzed": true},{"name": "delay","kind": "const","isTest": false,"src": 36,"value": {"typeRef": {
 "type": 32
},"expr": {
 "type": 76
}},"_analyzed": true},{"name": "zigMain","kind": "const","isTest": false,"src": 37,"value": {"typeRef": {
 "type": 32
},"expr": {
 "type": 77
}},"_analyzed": true},{"name": "mmio","kind": "const","isTest": false,"src": 2,"value": {"typeRef": {
 "type": 32
},"expr": {
 "type": 63
}},"_analyzed": true},{"name": "Gpio","kind": "const","isTest": false,"src": 23,"value": {"typeRef": {
 "type": 32
},"expr": {
 "type": 73
}},"_analyzed": true},{"name": "GpioBase","kind": "const","isTest": false,"src": 28,"value": {"typeRef": {
 "type": 32
},"expr": {
 "type": 75
}},"_analyzed": true},{"name": "Register","kind": "const","isTest": false,"src": 3,"value": {"typeRef": {
 "type": 32
},"expr": {
 "type": 64
}},"_analyzed": true},{"name": "Self","kind": "const","isTest": false,"src": 6,"value": {"typeRef": {
 "type": 32
},"expr": {
 "this": 65
}},"_analyzed": true},{"name": "init","kind": "const","isTest": false,"src": 7,"value": {"typeRef": {
 "type": 32
},"expr": {
 "type": 66
}},"_analyzed": true},{"name": "read_raw","kind": "const","isTest": false,"src": 9,"value": {"typeRef": {
 "type": 32
},"expr": {
 "type": 67
}},"_analyzed": true},{"name": "write_raw","kind": "const","isTest": false,"src": 11,"value": {"typeRef": {
 "type": 32
},"expr": {
 "type": 68
}},"_analyzed": true},{"name": "read","kind": "const","isTest": false,"src": 14,"value": {"typeRef": {
 "type": 32
},"expr": {
 "type": 69
}},"_analyzed": true},{"name": "write","kind": "const","isTest": false,"src": 16,"value": {"typeRef": {
 "type": 32
},"expr": {
 "type": 70
}},"_analyzed": true},{"name": "modify","kind": "const","isTest": false,"src": 19,"value": {"typeRef": {
 "type": 32
},"expr": {
 "type": 71
}},"_analyzed": true},{"name": "init","kind": "const","isTest": false,"src": 24,"value": {"typeRef": {
 "type": 32
},"expr": {
 "type": 74
}},"_analyzed": true}],
 "exprs": [{
 "type": 65
},{
 "comptimeExpr": 0
}],
 "comptimeExprs": [{"code": "ret_type"},{"code": "Read"},{"code": "Write"},{"code": "func call"},{"code": "func call"}]
};