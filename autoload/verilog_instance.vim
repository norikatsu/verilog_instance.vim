" Verilogのインスタンスを自動挿入
" Version: 1.0
" Author:  norikatsu <norikatsu@gmail.com>
" License: VIM LICENSE


let s:save_cpo = &cpo
set cpo&vim


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
        let s:file_name = s:module_name.".v"
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
            call Verilog_test_wires( modulename, list_io_mode, list_io_port, list_io_name, io_num)
        else
            call Verilog_test_instance( modulename, list_io_mode, list_io_port, list_io_name, io_num)
        endif
    endif

endfunction


"========== Script 本体 終了


let &cpo = s:save_cpo
unlet s:save_cpo
