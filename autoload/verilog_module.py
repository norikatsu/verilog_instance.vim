# ========== vim モジュールインポート
#import vim
from vim import *



#=====================================
#   Verilog File Port管理クラス
#
#   Start : 2015/01/01
#   Auth  : Yoshida Norikatsu
#   Mod   :
#=====================================
class ModuleIOs:
    def __init__(self, mode, port, name):
        self.mode = mode
        self.port = port
        self.name = name


#=====================================
#   Verilog File wire挿入関数
#
#   Start : 2015/01/01
#   Auth  : Yoshida Norikatsu
#   Mod   :
#=====================================

def write_wires( modulename, ios ):

    # カーソル位置取得
    pos = current.window.cursor

    # モジュール名挿入
    indent = "".rjust(4)
    current.buffer.append((indent + "// ----- " + modulename + " inst wires"), pos[0])

    # port名挿入
    io_num = len(ios)
    j      = 1
    for i in range(io_num):
        if ( (ios[i].mode == "output") or (ios[i].mode == "inout") ):
            wire_name = "xyz_" + ios[i].name
            strings = indent + "wire".ljust(8) + ios[i].port.ljust(20) + wire_name.ljust(16) + ";"
            current.buffer.append(strings, pos[0] + j)
            j += 1




#=====================================
#   Verilog File インスタンス挿入関数
#
#   Start : 2015/01/03
#   Auth  : Yoshida Norikatsu
#   Mod   :
#=====================================

def write_instance( modulename, ios ):

    # カーソル位置取得
    pos = current.window.cursor

    # コメント挿入
    indent = "".rjust(4)
    current.buffer.append((indent + "// ----- " + modulename + " instance "), pos[0])

    # インスタンス名挿入
    indent = "".rjust(4)
    current.buffer.append((indent + modulename + " U" + modulename + " (" ), pos[0] + 1)

    # port名挿入
    indent = "".rjust(8)
    io_num = len(ios)
    j      = 2
    for i in range(io_num):
        # port名
        port_name = "." + ios[i].name

        # wire名とコメント
        if (ios[i].mode == "output"):
            wire_name = "( xyz_"   + ios[i].name + " )"
            comment   = "// o  "   + ios[i].port
        elif (ios[i].mode == "inout"):
            wire_name = "( xyz_"   + ios[i].name + " )"
            comment   = "// io "   + ios[i].port
        else:
            wire_name = "( "       + ios[i].name + " )"
            comment   = "// i  "   + ios[i].port

        if (i < (io_num-1) ):
            wire_name = wire_name + ","


        strings = indent + port_name.ljust(20) + wire_name.ljust(28) + comment.ljust(24)
        current.buffer.append(strings, pos[0] + j)
        j += 1

    # インスタンス終了
    indent = "".rjust(4)
    current.buffer.append((indent +  ");" ), pos[0] + j)

#=====================================
#   Verilog File 構文解析関数
#
#   Start : 2014/12/17
#   Auth  : Yoshida Norikatsu
#   Mod   :
#=====================================

def read_verilog( f, mode ):
    io_num = 0
    ios    = []
    for line in f:
        #print(line)
        linelist = line.split()
        if ( len(linelist) > 1 ):
            # ---- module 名検出
            if (linelist [0] == "module"):
                if linelist[1][-1] == "(":
                    modulename = linelist[1][0:-1]
                else:
                    modulename = linelist[1]
                #print("Module Name = ", modulename)


            # ---- input output inout 名検出
            if ( (linelist [0] == "input") \
            or   (linelist [0] == "output") \
            or   (linelist [0] == "inout")):
                #print("IO Num = ",io_num)
                io_mode = linelist[0]

                # ポート数検出,IO名検出
                if ("[" in linelist[1] ):

                    i = 1
                    io_port = linelist[1]
                    while ( "]" not in linelist[i] ):
                        i += 1
                        io_port += linelist[i]

                    io_name = linelist[i+1]
                else:
                    io_port = ""
                    io_name = linelist[1]

                # IO名整形（セミコロン削除）
                if io_name[-1] == ";":
                    io_name = io_name[0:-1]

                ios.append( ModuleIOs(io_mode,io_port,io_name) )
                #print (ios[io_num].mode, ios[io_num].port, ios[io_num].name)
                io_num += 1

    if ( mode == 0):
        ##### Verilog Code に Wire を挿入
        write_wires( modulename, ios)
    else:
        ##### Verilog Code に Instance を挿入
        write_instance( modulename, ios)


#=====================================
#   Verilog Instance Input Modules
#     ( need python3 )
#
#   Start : 2014/12/09
#   Auth  : Yoshida Norikatsu
#   Mod   :
#=====================================



# ========== スクリプトスコープをバインド
s = vim.bindeval('s:')


# ========== File Name
file_verilog    = s['module_name'].decode('utf-8') + ".v"
file_sysverilog = s['module_name'].decode('utf-8') + ".sv"


# ========== File Open

file_open = 0   # まだファイル未オープン
try:
    f = open(file_verilog,"r")
except IOError:
    #print ( "Can't open " + file_verilog )

    file_verilog = file_sysverilog
    try:
        f = open(file_verilog,"r")
    except IOError:
        #print ( "Can't open " + file_verilog )
        print ( "" )
    else:
        file_open = 1
else:
    file_open = 1


# ========== エンコード判別
if file_open == 1:
    lookup = ('utf_8', 'euc_jp', 'euc_jis_2004', 'euc_jisx0213',
            'shift_jis', 'shift_jis_2004','shift_jisx0213',
            'iso2022jp', 'iso2022_jp_1', 'iso2022_jp_2', 'iso2022_jp_3',
            'iso2022_jp_ext','latin_1', 'ascii')

    #一端ファイルクローズ
    f.close()

    for encode in lookup:
        f = open(file_verilog,"r", encoding=encode)

        try:
            strings = f.read()
        except UnicodeDecodeError:
            #print("NG = " + encode)
            f.close()
        else:
            #print("OK Encode = " + encode)
            f.close()
            break

    #再度ファイルオープン
    f = open(file_verilog,"r", encoding=encode)


# ========== 読み込み処理
if file_open == 1:
    print (" Open " + file_verilog )

    read_verilog( f,s['mode'] )

    f.close()
else:
    print ("Can't open " + file_verilog + " or " + file_sysverilog )





