#==============================================================================
# ■ RGSS3 メニューコモンコマンド Ver1.00 by 星潟
#------------------------------------------------------------------------------
# 選択時、マップに戻って指定IDのコモンイベントを
# 呼び出すメニューコマンドを追加できるようになります。
# 特定のアクターを選んでから呼び出す物も作成出来ます。
# (選択したアクターのIDは変数に保存されるので、
#  その情報を元にイベントの条件分岐を行う事が可能になります)
#==============================================================================
# 以下は場合に応じてイベントコマンドのスクリプトに記述
#==============================================================================
# recall_menu_command
# 
# 直前にメニューコマンドで選んだのがコモンイベントのコマンドだった場合
# そのコマンドのカーソルを合わせた状態でメニューを呼び出す。
#==============================================================================
module CommonMenu
  
  #アクター選択型の場合に
  #どのアクターを選択したかを取得する為のIDを指定。
  #0以下の場合は処理しない。
  
  V = 20
  
  #空のハッシュを用意。
  
  C = {}
  
  #以下に設定。
  #設定例.
  #C[1] = ["コモン1",true,"true"]
  #この場合、呼び出すのはID1のコモンイベント。
  #コマンド名はコモン1。
  #アクターを選択して起動。
  #常時選択可能。
  
  #C[2] = ["コモン2",false,"true"]
  #この場合、呼び出すのはID2のコモンイベント。
  #コマンド名はコモン2。
  #アクターを選択せず、コマンドを選んだ時点で起動。
  #常時選択可能。
  
  #C[3] = ["コモン3",true,"$game_switches[1]"]
  #この場合、呼び出すのはID3のコモンイベント。
  #コマンド名はコモン3。
  #アクターを選択して起動。
  #スイッチ1がONの時に選択可能。
  
  #C[4] = ["コモン4",false,"!$game_switches[2]"]
  #この場合、呼び出すのはID4のコモンイベント。
  #コマンド名はコモン4。
  #アクターを選択せず、コマンドを選んだ時点で起動。
  #スイッチ2がOFFの時に選択可能。
  
  #C[5] = ["コモン5",true,"$game_variables[1] > 2"]
  #この場合、呼び出すのはID5のコモンイベント。
  #コマンド名はコモン5。
  #アクターを選択して起動。
  #変数ID1が2より大きい時に選択可能。
  
  C[6] = ["Message Auto Speed",false,"true"]
  
end
class Window_MenuCommand < Window_Command
  #--------------------------------------------------------------------------
  # 独自コマンドの追加用
  #--------------------------------------------------------------------------
  alias add_original_commands_commonmenu add_original_commands
  def add_original_commands
    add_original_commands_commonmenu
    CommonMenu::C.each {|k,v| s = v[1] ? :common2 : :common1
    flag = s == :common2 ? main_commands_enabled : true
    add_command(v[0],s,flag && eval(v[2]),k)}
  end
end
class Scene_Menu < Scene_MenuBase
  #--------------------------------------------------------------------------
  # コマンドウィンドウの作成
  #--------------------------------------------------------------------------
  alias create_command_window_commonmenu create_command_window
  def create_command_window
    create_command_window_commonmenu
    @command_window.set_handler(:common1,method(:command_common))
    @command_window.set_handler(:common2,method(:command_personal))
    if @recall_menu_command_index
      @command_window.select(@recall_menu_command_index)
      @recall_menu_command_index = nil
    end
  end
  #--------------------------------------------------------------------------
  # 個人コマンド［決定］
  #--------------------------------------------------------------------------
  alias on_personal_ok_commonmenu on_personal_ok
  def on_personal_ok
    if @command_window.current_symbol == :common2
      v = CommonMenu::V
      $game_variables[v] = $game_party.menu_actor.id if v > 0
      return command_common
    end
    on_personal_ok_commonmenu
  end
  #--------------------------------------------------------------------------
  # コマンドコモン
  #--------------------------------------------------------------------------
  def command_common
    $game_party.recall_menu_command_index = @command_window.index
    $game_temp.reserve_common_event(@command_window.current_ext)
    return_scene
  end
  #--------------------------------------------------------------------------
  # 最後に呼び出したメニューのインデックス情報を呼び出し
  #--------------------------------------------------------------------------
  def recall_menu_command_index
    @recall_menu_command_index = nil
    if $game_party.recall_menu_command_index >= 0
      @recall_menu_command_index = $game_party.recall_menu_command_index
      $game_party.recall_menu_command_index = -1
    end
  end
end
class Game_Party < Game_Unit
  attr_accessor :recall_menu_command_index
  #--------------------------------------------------------------------------
  # 最後に呼び出したメニューのインデックス(シンボルでは問題がある為)
  #--------------------------------------------------------------------------
  def recall_menu_command_index
    @recall_menu_command_index ||= -1
  end
end
class Game_Interpreter
  #--------------------------------------------------------------------------
  # 最後に呼び出したメニューのインデックス
  #--------------------------------------------------------------------------
  def recall_menu_command
    SceneManager.call(Scene_Menu)
    SceneManager.scene.recall_menu_command_index
    Fiber.yield
  end
end