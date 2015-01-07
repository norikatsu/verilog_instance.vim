" Verilogのインスタンスを自動挿入
" Version: 1.0
" Author:  norikatsu <norikatsu@gmail.com>
" License: VIM LICENSE

if exists('g:loaded_verilog_instance')
  finish
endif
let g:loaded_verilog_instance = 1

let s:save_cpo = &cpo
set cpo&vim

"========== Script 本体

"----- Exコマンド
command! -bar VerilogInstanceWire call verilog_instance#insert( 0 )
command! -bar VerilogInstanceInst call verilog_instance#insert( 1 )

"----- キーマッピング
nnoremap <silent> <Plug>(verilog_instance_wire) :<C-u>VerilogInstanceWire<CR>
nnoremap <silent> <Plug>(verilog_instance_inst) :<C-u>VerilogInstanceInst<CR>

if !hasmapto('<Plug>(verilog_instance_wire)')
      \  && (!exists('g:verilog_instance_no_default_key_mappings')
      \      || !g:verilog_instance_no_default_key_mappings)
    silent! nmap <unique> <Space>mm <Plug>(verilog_instance_wire)
endif

if !hasmapto('<Plug>(verilog_instance_inst)')
      \  && (!exists('g:verilog_instance_no_default_key_mappings')
      \      || !g:verilog_instance_no_default_key_mappings)
    silent! nmap <unique> <Space>nn <Plug>(verilog_instance_inst)
endif

" ===== 自動実行のサンプル(このスクリプトでは未使用)
"augroup plugin-sweep_trail
"  autocmd!
"  autocmd BufWritePre * call sweep_trail#auto_sweep()
"augroup END


"========== Script 本体 終了
"
"
let &cpo = s:save_cpo
unlet s:save_cpo
