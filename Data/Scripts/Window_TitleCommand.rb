#==============================================================================
# ■ Window_TitleCommand
#------------------------------------------------------------------------------
# 　タイトル画面で、ニューゲーム／コンティニューを選択するウィンドウです。
#==============================================================================

class Window_TitleCommand < Window_Command
  #--------------------------------------------------------------------------
  # ● オブジェクト初期化
  #--------------------------------------------------------------------------
  def initialize
    super(0, 0)
    update_placement
    select_symbol(:continue) if continue_enabled
    self.openness = 0
    open
  end
  #--------------------------------------------------------------------------
  # ● ウィンドウ幅の取得
  #--------------------------------------------------------------------------
  def window_width
    return 160
  end
  #--------------------------------------------------------------------------
  # ● ウィンドウ位置の更新
  #--------------------------------------------------------------------------
  def update_placement
    self.x = (Graphics.width - width) - 250
    self.y = (Graphics.height * 1.6 - height) - 300
  end
  #--------------------------------------------------------------------------
  # ● コマンドリストの作成
  #--------------------------------------------------------------------------
  def make_command_list
    add_command(Vocab::new_game, :new_game)
    add_command(Vocab::continue, :continue, continue_enabled)
    add_command(Vocab::shutdown, :shutdown)
  end
  #--------------------------------------------------------------------------
  # ● コンティニューの有効状態を取得
  #--------------------------------------------------------------------------
  def continue_enabled
    DataManager.save_file_exists?
  end
end
