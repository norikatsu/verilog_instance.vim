# verilog_instance
---
# Verilogのモジュール名からwire , instanceを挿入

# 概要
verilog_instance.vim はVerilogのモジュール名を入力し ```:VerilogInstanceInst```  
コマンドを実行することで、インスタンスを自動挿入します  
また ```:VerilogInstanceWire``` コマンドを実行することで、output,inoutポート用の wireを自動挿入します。
実行時にはカレントに記入したモジュール名の verilogファイルを置いておく必要が
あります。  
またVerilog 1ファイルに1モジュールとしてください


