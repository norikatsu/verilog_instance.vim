" Verilogのインスタンスを自動挿入
" Version: 2.0
" Author:  norikatsu <norikatsu@gmail.com>
" License: VIM LICENSE


let s:save_cpo = &cpo
set cpo&vim



"========== num分の長さの文字列にstringsを左詰して入れる(残りは空白文字)
function!  verilog_instance#alignleft( num, strings )
    let length = len(a:strings)
    if ( a:num > length )
        let space_num = a:num - length
    else
        let space_num = 1
    endif

    let outstrings = a:strings
    for i in range(1,space_num)
        let outstrings = outstrings . " "
    endfor

    return outstrings

endfunction


"========== wire 挿入関数
function! verilog_instance#wires( modulename, list_io_mode, list_io_port, list_io_name, io_num)
    "カーソル位置取得
    let line_num = line(".")
    
    let indent = "    "

    "モジュール名挿入
    call append(line_num + 0, indent . "// ----- " . a:modulename . " inst wires")

    "ポート名挿入
    let i = 0
    let j = 1
    for atom_io_mode in a:list_io_mode
        if ( (atom_io_mode == "output") || (atom_io_mode == "inout") )
            let wire_wire = verilog_instance#alignleft(  8, "wire"                     )
            let wire_name = verilog_instance#alignleft( 20, "xyz_" . a:list_io_name[i] )
            let wire_port = verilog_instance#alignleft( 20,          a:list_io_port[i] )
            let strings = indent . wire_wire . wire_port . wire_name . ";"
            call append( line_num + j, strings )
            let j = j + 1
        endif
        let i = i + 1
    endfor

endfunction


"========== instance 挿入関数
function! verilog_instance#instance( modulename, list_io_mode, list_io_port, list_io_name, io_num)
    "カーソル位置取得
    let line_num = line(".")
    
    let indent = "    "

    "コメント挿入
    call append(line_num + 0, indent . "// ----- " . a:modulename . " instance ")

    "インスタンス名挿入
    call append(line_num + 1, indent . a:modulename . " U" . a:modulename . " (" )


    "ポート名挿入

    let indent = "        "
    let i = 0
    let j = 2
    for atom_io_mode in a:list_io_mode
        " port名
        let port_name = ".".a:list_io_name[i]

        " wire名とコメント
        if ( atom_io_mode == "output")
            let wire_name = "( xyz_" . a:list_io_name[i] . " )"
            let comment   = "// o  " . a:list_io_port[i]
        elseif ( atom_io_mode == "inout")
            let wire_name = "( xyz_" . a:list_io_name[i] . " )"
            let comment   = "// io " . a:list_io_port[i]
        else
            let wire_name = "( "     . a:list_io_name[i] . " )"
            let comment   = "// i  " . a:list_io_port[i]
        endif

        if ( i < (a:io_num-1) )
            let wire_name = wire_name . ","
        endif


        let port_name = verilog_instance#alignleft( 20, port_name) 
        let wire_name = verilog_instance#alignleft( 28, wire_name) 
        let comment   = verilog_instance#alignleft( 24, comment) 

        let strings = indent . port_name . wire_name . comment
        call append(line_num + j, strings)

        let i = i + 1
        let j = j + 1
    endfor

    "インスタンス終了
    let indent = "    "
    call append(line_num + j, indent . ");" )

endfunction





"========== Script 本体

" メイン関数
" mode = 0 : wire 挿入
" mode = 1 : instance 挿入
function! verilog_instance#insert( mode )

    " ========== カーソル位置の文字列検出
    let s:module_name = expand("<cword>")

    " ========== 検出文字列の判別
    if s:module_name == ""

        " 文字列が空
        let s:error_message = "Not Found Moudle Name"
        echo s:error_message
    else

        "Fileの有無確認

        if ( filereadable( s:module_name.".v" ) )
            let s:readable = 1
            let s:file_name = s:module_name.".v"
        elseif ( filereadable( s:module_name.".sv") )
            let s:readable = 1
            let s:file_name = s:module_name.".sv"
        else
            let s:readable = 0
        endif

        if ( s:readable == 0)
            let s:error_message = "Not Found " . s:module_name . " File"
            echo s:error_message
        else
            let io_num = 0
            let list_io_mode = []
            let list_io_port = []
            let list_io_name = []

            for line in readfile(s:file_name)
                "echo line
                let linelist = split(line)
                let length = len(linelist)
                "echo length
                if ( length > 1)
                    " モジュール名検出
                    if ( linelist[0] == "module")
                        if (linelist[1][-1:-1] == "(" )
                            let modulename = linelist[1][0:-2]
                        else
                            let modulename = linelist[1]
                        endif
                        echo "Module Name = ".modulename
                    endif

                    " Function の入力部を排除するため
                    if ( linelist[0] == "function")
                        break
                    endif

                    " input output inout名検出
                    if (  (linelist[0] == "input")||(linelist[0] == "output")||(linelist[0] == "inout") )
                        let io_mode = linelist[0]
                        " ポート数検出
                        if ( linelist[1][0] == "[")
                            let i = 1
                            let io_port = linelist[1]
                            "echo "linelist1 = ".linelist[1]
                            "echo "io_port = ".io_port
                            while ( linelist[i][-1:-1] != "]" )
                                let i = i + 1
                                let io_port = io_port.linelist[i]
                            endwhile
                            let io_name = linelist[i+1]
                        else
                            let io_port = ""
                            let io_name = linelist[1]
                        endif
                        "IO名整形(セミコロン削除)
                        if ( io_name[-1:-1] == ";" )
                            let io_name = io_name[0:-2]
                        endif
                        "echo io_mode.", ".io_port.", ".io_name
                        let list_io_mode = add(list_io_mode,io_mode)
                        let list_io_port = add(list_io_port,io_port)
                        let list_io_name = add(list_io_name,io_name)
                        let io_num = io_num + 1
                    endif
                endif
            endfor

            if ( a:mode == 0 )
                call verilog_instance#wires( modulename, list_io_mode, list_io_port, list_io_name, io_num)
            else
                call verilog_instance#instance( modulename, list_io_mode, list_io_port, list_io_name, io_num)
            endif
        endif
    endif

endfunction


"========== Script 本体 終了


let &cpo = s:save_cpo
unlet s:save_cpo
