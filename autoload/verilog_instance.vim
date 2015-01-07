" Verilogのインスタンスを自動挿入
" Version: 1.0
" Author:  norikatsu <norikatsu@gmail.com>
" License: VIM LICENSE


let s:save_cpo = &cpo
set cpo&vim


"========== Script 本体

let s:plugin_path = escape(expand('<sfile>:p:h'),'\')

" 自動実行用の設定変数
"if !exists('g:verilog_instance#enable')
"  let g:verilog_instance#enable = 1
"endif


" メイン関数
" mode = 0 : wire 挿入
" mode = 1 : instance 挿入
function! verilog_instance#insert( mode )

    " ========== python 側に変数を渡せるよう s: にmode値を代入
    let s:mode = a:mode

    " ========== カーソル位置の文字列検出
    let s:module_name = expand("<cword>")

    " ========== 検出文字列の判別
    if s:module_name == ""

        " 文字列が空
        let s:error_message = "Not Found Moudle Name"
        echo s:error_message
    else
        " 文字列がある場合は Python側で処理(ファイルが内場合はエラー表示をする
        " が、それもPython側で行う
        "execute 'py3file' 'verilog_module.py'
        execute 'py3file' s:plugin_path.'/verilog_module.py'

    endif

endfunction

" 自動実行用の関数
"function! verilog_instance#auto_sweep()
"  if g:verilog_instance#enable
"    call sweep_trail#sweep()
"  endif
"endfunction

"========== Script 本体 終了


let &cpo = s:save_cpo
unlet s:save_cpo
