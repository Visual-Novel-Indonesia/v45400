#==============================================================================
# ■ RGSS3 メッセージ関連追加システム Ver1.02 by 星潟
#------------------------------------------------------------------------------
# 変数に依存した自動ページ送り、メッセージウィンドウの消去機能、
# メッセージ履歴システムをそれぞれ追加します。
# それぞれ、個別に機能のON/OFFを比較的自由に行う事が出来ます。
# 
# なお、当方のメッセージスキップと併用される際は
# このスクリプトをメッセージスキップよりも下に配置して下さい。
#==============================================================================
# 以下、デフォルト設定における操作方法の追加内容。
# (全てメッセージを表示し終えた状態でのみ有効)
#------------------------------------------------------------------------------
# ALTキー:
# 自動ページ送りのON/OFF切り替え。(初期状態はOFF)
# 自動ページ送りをOFFからONに切り替えた際のページでは
# 右下に半透明で自動モードを示すスプライトが表示される。
# 一度決定キー等で次のページに行くとスプライトが通常の表示となり
# ここから自動モードに入った事を示す。
# (半透明の状態ではまだ自動ではなく、次のページから自動送りが適用される事を示す)
#------------------------------------------------------------------------------
# CTRLキー:
# 自動ページ送り中は決定キー等でのページ送りが無効化されるが
# CTRLキーを押す事でページ送りがされる。(メッセージスキップ用)
#------------------------------------------------------------------------------
# Aボタン(デフォルトではSHIFTキー):
# メッセージウィンドウを一時的に消去する。
#------------------------------------------------------------------------------
# Xボタン(デフォルトではAキー):
# メッセージ履歴画面を起動/終了する。
# メッセージ履歴画面では左/上キーで1ページ戻り、右/下キーで1ページ進む。
#==============================================================================
module MessageEnhance
  
  #空のハッシュを用意。(変更不要)
  
  SV = {}
  
  #自動ページ送りシステムそのものを有効化するかを指定。
  
  OK1 = true
  
  #自動ページ送りシステムを戦闘中も有効にするかを指定。
  
  OB1 = false
  
  #メッセージウィンドウの消去システムそのものを有効化するかを指定。
  
  OK2 = true
  
  #メッセージウィンドウの消去システムを戦闘中も有効にするかを指定。
  
  OB2 = true
  
  #メッセージ履歴システムそのものを有効化するかを指定。
  
  OK3 = true
  
  #メッセージ履歴への追加を戦闘中も有効にするかを指定。
  
  OB3 = false
  
  #メッセージ履歴の表示を戦闘中も有効にするかを指定。
  
  OB4 = false
  
  #自動ページ送りON/OFF切り替え用ボタンシンボルを取得。
  
  K1 = [:Y]
  
  #自動ページ送り中の手動文字送り用ボタンシンボルを取得。
  #（メッセージスキップ用）
  
  K2 = [:C]
  
  #自動ページ送り用変数IDを取得。
  
  V = 144
  
  #自動ページ送り用変数に格納されている値別の文字送り待機時間を指定。
  #設定されていない値の場合、自動ページ送りは行われない。(機能の無効化)
  #例.SV[1] = 120
  #自動ページ送り用変数に格納されている値が1の時
  #文字送りは120ウェイト待機する。
  
  SV[5] = 30
  SV[4] = 60
  SV[3] = 120
  SV[2] = 180
  SV[1] = 240
  
  
  #自動ページ送りスプライト上に表示する文字列を設定。
  
  AT = "Auto Mode"
  
  #自動ページ送りのグラデーションカラー1を指定。(端側)
  
  C1 = [0,0,0,0]
  
  #自動ページ送りのグラデーションカラー1を指定。(中央側)
  
  C2 = [0,0,0,200]
  
  #自動ページ送りの幅と高さとフォントサイズを指定。
  
  WH = [120,18,18]
  
  #テキスト自動用スプライトのキャッシュ用のパスを設定。(変更不要)
  
  P1 = "TextAuto"
  
  #メッセージウィンドウの消去用ボタンシンボルを指定。
  
  K3 = [:R]
  
  #メッセージウィンドウの消去機能無効化用スイッチIDを指定。
  
  S1 = 131
  
  #メッセージ履歴表示用のボタンシンボルを指定。
  
  K4 = [:L]
  
  #メッセージ履歴保存の無効化用スイッチIDを指定。
  
  S2 = 132
  
  #メッセージ履歴保存の表示禁止用スイッチIDを指定。
  
  S3 = 133
  
  #メッセージ履歴保存行数を指定。
  #（メッセージページ毎に自動的に空の行が挿入される為
  #  実質的な行数は少なくなる点を注意）
  
  M = 96
  
  #メッセージ履歴の背景色を指定。
  
  C = [0,0,0,200]
  
  #メッセージ履歴の背景スプライトのキャッシュ用のパスを設定。(変更不要)
  
  P2 = "TextHistory"
  
  OBA = [OB1,OB2,OB3,OB4]
  
  #--------------------------------------------------------------------------
  # バトル状態か否かでの判定
  #--------------------------------------------------------------------------
  def self.battle(type)
    return true unless $game_party.in_battle
    OBA[type]
  end
  #--------------------------------------------------------------------------
  # 文字送りウェイトの時間を取得
  #--------------------------------------------------------------------------
  def self.wait
    return -1 unless $game_party.message_auto_mode
    wait_value
  end
  #--------------------------------------------------------------------------
  # 文字送りウェイトの時間を取得
  #--------------------------------------------------------------------------
  def self.wait_value
    return 0 unless battle(0)
    s = SV[$game_variables[V]]
    s ? s : 0
  end
  #--------------------------------------------------------------------------
  # メッセージウィンドウの不可視化＆停止状態の切り替え
  #--------------------------------------------------------------------------
  def self.invisible
    K3.any? {|k| Input.trigger?(k)} && !$game_switches[S1] && battle(1)
  end
  #--------------------------------------------------------------------------
  # 履歴への追加が可能かを判定
  #--------------------------------------------------------------------------
  def self.addable?
    !$game_switches[S2] && battle(2)
  end
  #--------------------------------------------------------------------------
  # 履歴への追加
  #--------------------------------------------------------------------------
  def self.add(text)
    return unless addable?
    $game_party.text_history_add(convert_text(text))
  end
  #--------------------------------------------------------------------------
  # 履歴関連の一連の更新
  #--------------------------------------------------------------------------
  def self.update
    return unless (history_key? && history_able?)
    @back_sprite = Sprite.new
    @back_sprite.bitmap = Cache.text_history
    @text_history = Window_Text_History.new
    a = [@back_sprite,@text_history]
    a.each {|o| o.z = 10000000}
    Input.update
    ws_update while !history_key?
    a.each {|o| o.dispose}
  end
  #--------------------------------------------------------------------------
  # 履歴の閲覧が可能かを判定
  #--------------------------------------------------------------------------
  def self.history_able?
    !$game_switches[S3] && battle(3)
  end
  #--------------------------------------------------------------------------
  # 履歴の開始/終了に関するキーが押されたか？
  #--------------------------------------------------------------------------
  def self.history_key?
    MessageEnhance::K4.any? {|k| Input.trigger?(k)}
  end
  #--------------------------------------------------------------------------
  # 履歴ウィンドウと背景スプライトの更新
  #--------------------------------------------------------------------------
  def self.ws_update
    @back_sprite.update
    @text_history.update
  end
  #--------------------------------------------------------------------------
  # テキストの変換
  #--------------------------------------------------------------------------
  def self.convert_text(text)
    w = Window_Base.new(0,0,32,32)
    r = w.convert_escape_characters(text)
    w.dispose
    r
  end
end
if MessageEnhance::OK2
class Window_Message < Window_Base
  #--------------------------------------------------------------------------
  # オブジェクト初期化
  #--------------------------------------------------------------------------
  alias initialize_invisible initialize
  def initialize
    initialize_invisible
    @invisible_mode = false
  end
  #--------------------------------------------------------------------------
  # フレーム更新
  #--------------------------------------------------------------------------
  alias update_invisible update
  def update
    if open? && MessageEnhance.invisible
      @invisible_mode = @invisible_mode ? false : true
    elsif !@invisible_mode
      update_invisible
    end
    self.visible = @invisible_mode ? false : true
    @back_sprite.visible = @invisible_mode ? false : true if @background == 1
  end
end
end
if MessageEnhance::OK1
module Cache
  #--------------------------------------------------------------------------
  # 自動ページ送り用スプライトの為のビットマップを取得
  #--------------------------------------------------------------------------
  def self.text_auto
    path = MessageEnhance::P1
    @cache[path] = create_text_auto_bitmap unless include?(path)
    @cache[path]
  end
  #--------------------------------------------------------------------------
  # 自動ページ送り用スプライトの為のビットマップを作成
  #--------------------------------------------------------------------------
  def self.create_text_auto_bitmap
    wh = MessageEnhance::WH
    b = Bitmap.new(wh[0],wh[1])
    r = b.rect
    w1 = r.width / 3
    c = MessageEnhance::C1
    co1 = Color.new(c[0],c[1],c[2],c[3])
    c = MessageEnhance::C2
    co2 = Color.new(c[0],c[1],c[2],c[3])
    r.width = w1
    b.gradient_fill_rect(r,co1,co2)
    r.x += w1
    b.fill_rect(r,co2)
    r.x += w1
    b.gradient_fill_rect(r,co2,co1)
    b.font.size = wh[2]
    b.draw_text(0,0,b.width,b.height,MessageEnhance::AT,1)
    b
  end
end
class Window_Message < Window_Base
  attr_accessor :extra_pause_count
  #--------------------------------------------------------------------------
  # オブジェクト初期化
  #--------------------------------------------------------------------------
  alias initialize_auto_mode initialize
  def initialize
    @extra_pause_count = -1
    initialize_auto_mode
    @auto_mode_sprite = Sprite_MessageAutoMode.new(self)
  end
  #--------------------------------------------------------------------------
  # フレーム更新
  #--------------------------------------------------------------------------
  alias update_auto_mode update
  def update
    update_auto_mode
    message_auto_mode_switching
    @auto_mode_sprite.update
  end
  #--------------------------------------------------------------------------
  # 自動ページ送り用スプライトの為のビットマップを作成
  #--------------------------------------------------------------------------
  alias dispose_auto_mode_sprite dispose
  def dispose
    @auto_mode_sprite.dispose
    dispose_auto_mode_sprite
  end
  #--------------------------------------------------------------------------
  # 入力待ち処理
  #--------------------------------------------------------------------------
  def input_pause
    begin
      return if M_SKIP.seal
    rescue
    end
    self.pause = true
    wait(extra_pause_wait_count)
    @extra_pause_count = MessageEnhance.wait
    loop do
      if $game_party.message_auto_mode
        extra_pause_flag ? break : extra_pause(@extra_pause_count)
      else
        @extra_pause_count = -1
        extra_pause_key ? break : Fiber.yield
      end
    end
    self.pause = false
    @extra_pause_count = 0
  end
  #--------------------------------------------------------------------------
  # 入力判定
  #--------------------------------------------------------------------------
  def extra_pause_key
    f1 = Input.trigger?(:B) || Input.trigger?(:C)
    begin
      M_SKIP.seal
      f1 or M_SKIP.seal
    rescue
      f1
    end
  end
  #--------------------------------------------------------------------------
  # ウェイト取得
  #--------------------------------------------------------------------------
  def extra_pause_wait_count
    begin
      M_SKIP::WAIT
    rescue
      10
    end
  end
  #--------------------------------------------------------------------------
  # 自動ページ送り用ポーズ
  #--------------------------------------------------------------------------
  def extra_pause(s)
    @extra_pause_count -= 1
    wait(1)
    Fiber.yield
  end
  #--------------------------------------------------------------------------
  # 自動ページ送りの切り替え
  #--------------------------------------------------------------------------
  def message_auto_mode_switching
    if message_auto_mode_switching_flag
      $game_party.message_auto_mode_switching
      @extra_pause_count = MessageEnhance.wait_value
    end
  end
  #--------------------------------------------------------------------------
  # 自動ページ送りの切り替えフラグ
  #--------------------------------------------------------------------------
  def message_auto_mode_switching_flag
    visible && pause &&
    MessageEnhance::K1.any? {|k| Input.trigger?(k)} &&
    MessageEnhance.wait_value != 0
  end
  #--------------------------------------------------------------------------
  # 自動ページ送り用ポーズの終了フラグ
  #--------------------------------------------------------------------------
  def extra_pause_flag
    MessageEnhance::K2.any? {|k| Input.press?(k)} or @extra_pause_count <= 0
  end
  #--------------------------------------------------------------------------
  # 自動ページ送りスプライト可視状態判定
  #--------------------------------------------------------------------------
  def message_auto_sprite_visible
    $game_party.message_auto_mode && visible && open? && MessageEnhance.wait != 0
  end
end
class Sprite_MessageAutoMode < Sprite
  #--------------------------------------------------------------------------
  # 初期化
  #--------------------------------------------------------------------------
  def initialize(w)
    super(w.viewport)
    @message_window = w
    self.bitmap = Cache.text_auto
    wh = MessageEnhance::WH
    @bitmap_width = wh[0]
    @bitmap_height = wh[1]
    update
  end
  #--------------------------------------------------------------------------
  # 更新
  #--------------------------------------------------------------------------
  def update
    super
    self.x = @message_window.x + @message_window.width - @bitmap_width
    self.y = @message_window.y + @message_window.height - @bitmap_height
    self.z = @message_window.z += 1
    self.visible = @message_window.message_auto_sprite_visible
  end
end
class Game_Party < Game_Unit
  attr_accessor :message_auto_mode
  #--------------------------------------------------------------------------
  # 自動送りを切り替え
  #--------------------------------------------------------------------------
  def message_auto_mode_switching
    @message_auto_mode = !@message_auto_mode
  end
end
end
if MessageEnhance::OK3
module Cache
  #--------------------------------------------------------------------------
  # 履歴用スプライトの為のビットマップを取得
  #--------------------------------------------------------------------------
  def self.text_history
    path = MessageEnhance::P2
    @cache[path] = create_text_history_bitmap unless include?(path)
    @cache[path]
  end
  #--------------------------------------------------------------------------
  # 履歴用スプライトの為のビットマップを作成
  #--------------------------------------------------------------------------
  def self.create_text_history_bitmap
    b = Bitmap.new(Graphics.width,Graphics.height)
    c = MessageEnhance::C
    b.fill_rect(b.rect,Color.new(c[0],c[1],c[2],c[3]))
    b
  end
end
class Game_Message
  #--------------------------------------------------------------------------
  # クリア
  #--------------------------------------------------------------------------
  alias clear_text_history clear
  def clear
    MessageEnhance.add("") if @texts && !@texts.empty?
    clear_text_history
  end
  #--------------------------------------------------------------------------
  # テキストの追加
  #--------------------------------------------------------------------------
  alias add_text_history add
  def add(text)
    add_text_history(text)
    MessageEnhance.add(text)
  end
end
class Game_Party < Game_Unit
  #--------------------------------------------------------------------------
  # テキスト履歴の追加
  #--------------------------------------------------------------------------
  def text_history_add(text)
    text_history.push(text)
    s = text_history.size - MessageEnhance::M
    s.times {text_history.shift} if s > 0
    loop {text_history[0] && text_history[0].empty? ? text_history.shift : break}
  end
  #--------------------------------------------------------------------------
  # テキスト履歴
  #--------------------------------------------------------------------------
  def text_history
    @text_history ||= []
  end
end
class Window_Text_History < Window_Base
  #--------------------------------------------------------------------------
  # 初期化
  #--------------------------------------------------------------------------
  def initialize
    super(0,-12,Graphics.width,Graphics.height + 24)
    self.opacity = 0
    self.contents_opacity = 255
    @line_max ||= contents.height / line_height - 1
    @last_page_number = $game_party.text_history.size / @line_max
    @last_page_number += 1 if $game_party.text_history.size % @line_max > 0
    @last_page_number = 1 if @last_page_number == 0
    @page_number = @last_page_number.to_i
    refresh
  end
  #--------------------------------------------------------------------------
  # 更新
  #--------------------------------------------------------------------------
  def update
    super
    Input.update
    Graphics.update
    if Input.trigger?(:L) or Input.trigger?(:LEFT) or Input.trigger?(:UP)
      prev_page
    elsif Input.trigger?(:R) or Input.trigger?(:RIGHT) or Input.trigger?(:DOWN)
      next_page
    end
  end
  #--------------------------------------------------------------------------
  # 前のページへ
  #--------------------------------------------------------------------------
  def prev_page
    return unless @page_number > 1
    Sound.play_cursor
    @page_number -= 1
    refresh
  end
  #--------------------------------------------------------------------------
  # 次のページへ
  #--------------------------------------------------------------------------
  def next_page
    l = @last_page_number
    return @page_number = l if @page_number >= l
    Sound.play_cursor
    @page_number += 1
    refresh
  end
  #--------------------------------------------------------------------------
  # リフレッシュ
  #--------------------------------------------------------------------------
  def refresh
    create_contents
    draw_text(0,0,contents_width,line_height,@page_number.to_s + "/" + @last_page_number.to_s,2)
    a = $game_party.text_history
    s1 = a.size
    if s1 <= @line_max
      a2 = a
    else
      a2 = a[(@page_number - 1) * @line_max,@page_number * @line_max - 1]
    end
    draw_text_ex(0,0,(a2.inject("") {|r,t| r += "\n" + t}))
  end
  #--------------------------------------------------------------------------
  # 制御文字の処理
  #--------------------------------------------------------------------------
  def process_escape_character(code, text, pos)
    c = code.upcase
    case c
    when '$'
    when '.'
    when '|'
    when '!'
    when '>'
    when '<'
    when '^'
    else;super
    end
  end
  #--------------------------------------------------------------------------
  # フォントを大きくする(履歴を見易くする為無効化)
  #--------------------------------------------------------------------------
  def make_font_bigger
  end
  #--------------------------------------------------------------------------
  # フォントを小さくする(履歴を見易くする為無効化)
  #--------------------------------------------------------------------------
  def make_font_smaller
  end
end
class Spriteset_Map
  #--------------------------------------------------------------------------
  # フレーム更新
  #--------------------------------------------------------------------------
  alias update_text_history update
  def update
    MessageEnhance.update
    update_text_history
  end
end
class Spriteset_Battle
  #--------------------------------------------------------------------------
  # フレーム更新
  #--------------------------------------------------------------------------
  alias update_text_history update
  def update
    MessageEnhance.update
    update_text_history
  end
end
end