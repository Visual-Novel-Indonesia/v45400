=begin
      RGSS3
      
      ★ シンボルエンカウント補助 ★

      イベントでのシンボルエンカウントの動作を補助します。
      
      ● 仕様 ●==========================================================
      シンボルエンカウント有効後は、
      イベントページの自律移動の項で設定されたものは全て無効になります。
      --------------------------------------------------------------------
      一度有効になったシンボルエンカウントを無効にするには、
      シンボルエンカウント設定のないイベントページに切り替えてください。
      ====================================================================
      
      ● 機能 ●==========================================================
      シンボルエンカウントイベントから戦闘を起動した場合、
      シンボルとプレイヤーの位置関係により先制攻撃or不意打ちが発生します。
          ・イベントの背後を取った場合           => 先制攻撃
          ・イベントに背後を取られた場合         => 不意打ち
          ・イベントが隊列の最後尾に接触した場合 => 不意打ち
      --------------------------------------------------------------------
      プレイヤーとの距離が一定内になるとプレイヤーを追跡するようになります。
      --------------------------------------------------------------------
      プレイヤーとの距離によりシンボルの透明度を変化させることができます。
      --------------------------------------------------------------------
      プレイヤーのレベルによりシンボルが逃走したりします。
      --------------------------------------------------------------------
      ダッシュしているとシンボルが反応しやすくなったりします。
      --------------------------------------------------------------------
      シンボルが反応した瞬間フキダシアイコンが表示されたりします。
      --------------------------------------------------------------------
      シンボルが反応しなくなるアイテムやスキルを作ることができます。
      --------------------------------------------------------------------
      シンボルが通行できないリージョンを設定することができます。
      ====================================================================
      
      ● シンボルエンカウントイベントの設定方法 ●========================
      シンボルの動作を設定箇所にてあらかじめ定義しておきます。
      --------------------------------------------------------------------
      イベント＞自律移動＞頻度を最高に設定してください。
      --------------------------------------------------------------------
      イベント＞自律移動＞カスタム＞移動ルート＞スクリプトに
        enable_symbol_encount(id)
      と記述します。idには設定箇所で定義したものを指定します。
      --------------------------------------------------------------------
      後はイベントのトリガーを"イベントから接触"にして戦闘を起動するだけ！
      ====================================================================
      
      ● ステルス機能について ●==========================================
      メモ欄に「ステルス:n」と記述されたスキル・アイテムを使用すると
      ステルス状態となり、一定期間シンボルが反応しなくなります。
      nにはステルス状態が維持されるプレイヤーの歩数を指定します。
      --------------------------------------------------------------------
      イベントのスクリプトから下記のコードを実行することで、
      ステルスを強制的に解除することができます。
        reset_stealth
      --------------------------------------------------------------------
      操作キャラクターの変更時や、シナリオ上で長い時間が経過した際などに
      使用してください。
      ====================================================================
      
      ● 注意 ●==========================================================
      ニューゲームから始めないとエラーを吐きます。
      ====================================================================
      
      ver1.01

      Last Update : 2012/03/04
      03/04 : 追跡中のイベントが存在する際にイベントが発生すると、
              追跡状態がおかしくなる不具合を修正
      ----------------------2012--------------------------
      12/23 : RGSS2からの移植
      ----------------------2011--------------------------
      
      ろかん　　　http://kaisou-ryouiki.sakura.ne.jp/
=end

#===================================
#  ●設定箇所
#===================================
module SymbolEncount
  # 隊列がシンボルと接触した場合、イベントを起動するかどうか
  FOLLOWER_CONTACT = true
  
  # シンボルエンカウントの設定をあらかじめ定義
  SYMBOL_SETTING_LIST = {
    #-----------------------------------------------------------
    0 => [
          # シンボルが逃げるプレイヤーレベル
          #   0が設定されている場合逃走しません
          0,
          # プレイヤーレベルの判断種別
          #   0:平均レベル、1:最大レベル、2:先頭メンバーのレベル
          0,
          # シンボルが反応するプレイヤーとの距離
          3,
          # シンボルが反応するプレイヤーとの距離（プレイヤーダッシュ時）
          5,
          # プレイヤーに反応していない時の移動パターン
          #   0:ランダム移動、1:停止
          0,
          # 透明度の変化するプレイヤーとの距離
          #   ここで指定した距離よりもシンボルから遠ざかることで
          #   シンボルが少しずつ見えにくくなっていきます。
          #   0が設定されている場合この機能は無効になります。
          5,
          # 反応前の移動速度
          #   1:1/8倍速、2:1/4倍速、3:1/2倍速、4:標準速、5:2倍速、6:4倍速
          4,
          # 反応後の移動速度
          #   1:1/8倍速、2:1/4倍速、3:1/2倍速、4:標準速、5:2倍速、6:4倍速
          5,
          # 反応前の移動頻度
          #   1:最低、2:低、3:通常、4:高、5:最高
          5,
          # 反応後の移動頻度
          #   1:最低、2:低、3:通常、4:高、5:最高
          5,
          # 反応時に再生するフキダシアイコンID
          #   0が設定されている場合この機能は無効になります。
          1,
          # シンボルが通行することのできないリージョンID
          # 配列形式で指定してください。
          [1, 3]
         ],
    #-----------------------------------------------------------
    1 => [
          15,# シンボルが逃げるプレイヤーレベル
          0, # プレイヤーレベルの判断種別
          3, # シンボルが反応するプレイヤーとの距離
          5, # シンボルが反応するプレイヤーとの距離（プレイヤーダッシュ時）
          1, # プレイヤーに反応していない時の移動パターン
          0, # 透明度の変化するプレイヤーとの距離
          0, # 反応前の移動速度
          4, # 反応後の移動速度
          0, # 反応前の移動頻度
          5, # 反応後の移動頻度
          1, # 反応時に再生するフキダシアイコンID
          [] # シンボルが移動することのできないリージョンID
         ],
    #-----------------------------------------------------------
    2 => [
          0, # シンボルが逃げるプレイヤーレベル
          0, # プレイヤーレベルの判断種別
          3, # シンボルが反応するプレイヤーとの距離
          5, # シンボルが反応するプレイヤーとの距離（プレイヤーダッシュ時）
          0, # プレイヤーに反応していない時の移動パターン
          5, # 透明度の変化するプレイヤーとの距離
          3, # 反応前の移動速度
          5, # 反応後の移動速度
          5, # 反応前の移動頻度
          5, # 反応後の移動頻度
          1, # 反応時に再生するフキダシアイコンID
          [] # シンボルが移動することのできないリージョンID
         ],
    #-----------------------------------------------------------
    3 => [
          0, # シンボルが逃げるプレイヤーレベル
          0, # プレイヤーレベルの判断種別
          0, # シンボルが反応するプレイヤーとの距離
          0, # シンボルが反応するプレイヤーとの距離（プレイヤーダッシュ時）
          0, # プレイヤーに反応していない時の移動パターン
          0, # 透明度の変化するプレイヤーとの距離
          0, # 反応前の移動速度
          0, # 反応後の移動速度
          0, # 反応前の移動頻度
          0, # 反応後の移動頻度
          0, # 反応時に再生するフキダシアイコンID
          [] # シンボルが移動することのできないリージョンID
         ],
    #-----------------------------------------------------------
  }
end
#===================================
#  ここまで
#===================================

$rsi ||= {}
$rsi["シンボルエンカウント補助"] = true

class RPG::UsableItem < RPG::BaseItem
  def stealth_obj_count
    self.note.each_line{|line|
      return $1.to_i if line =~ /ステルス:(\d+)/i
    }
    0
  end
end

class << BattleManager
  #--------------------------------------------------------------------------
  # ● モジュールのインスタンス変数
  #--------------------------------------------------------------------------
  attr_writer   :run_event
  @run_event = nil # 戦闘を呼び出したイベント
  #--------------------------------------------------------------------------
  # ● セットアップ
  #--------------------------------------------------------------------------
  alias _symbol_encount_setup setup
  def setup(troop_id, can_escape = true, can_lose = false)
    _symbol_encount_setup(troop_id, can_escape, can_lose)
    set_battle_condition
  end
  #--------------------------------------------------------------------------
  # ● シンボルエンカウントイベントから戦闘が呼び出されている場合の処理
  #--------------------------------------------------------------------------
  def set_battle_condition
    if @run_event && @run_event.symbol_encount
      @run_event.set_contact_condition
      case @run_event.contact_condition
      when 1
        @preemptive = true
      when 2
        @surprise = true
      end
    end
    @run_event = nil
  end
end

class Game_Actor < Game_Battler
  #--------------------------------------------------------------------------
  # ● スキル／アイテムの使用
  #--------------------------------------------------------------------------
  def use_item(item)
    stealth_effect(item)
    super
  end
  #--------------------------------------------------------------------------
  # ● ステルス効果の適用
  #--------------------------------------------------------------------------
  def stealth_effect(item)
    result = item.stealth_obj_count
    $game_player.stealth_count = result if result > 0
  end
end

class Game_Party < Game_Unit
  #--------------------------------------------------------------------------
  # ● プレイヤーレベルの取得
  #--------------------------------------------------------------------------
  def get_player_level(type)
    case type
    when 0
      members.inject(0){|r, actor| r += actor.level} / members.size
    when 1
      members.max_by{|actor| actor.level}
    when 2
      $game_party.members.first.level
    end
  end
end

class Game_Character < Game_CharacterBase
  #--------------------------------------------------------------------------
  # ● 非公開メンバ変数の初期化
  #--------------------------------------------------------------------------
  alias _symbol_init_private_members init_private_members
  def init_private_members
    _symbol_init_private_members
    @origin_opacity = @opacity
  end
  #--------------------------------------------------------------------------
  # ● 移動コマンドの処理
  #--------------------------------------------------------------------------
  alias _symbol_process_move_command process_move_command
  def process_move_command(command)
    params = command.parameters
    @origin_opacity = params[0] if command.code == ROUTE_CHANGE_OPACITY
    _symbol_process_move_command(command)
  end
  #--------------------------------------------------------------------------
  # ● 指定キャラクターとの位置関係を取得（接触していることを前提）
  #--------------------------------------------------------------------------
  def positional_relationship(character)
    if character.real_x == real_x
      character.real_y > real_y ? 1 : 0
    elsif character.real_y == real_y
      character.real_x > real_x ? 2 : 3
    else
      -1
    end
  end
  #--------------------------------------------------------------------------
  # ● シンボルエンカウント関連処理による透明度の更新
  #--------------------------------------------------------------------------
  def update_symbol_opacity
  end
  #--------------------------------------------------------------------------
  # ● フレーム更新
  #--------------------------------------------------------------------------
  alias _symbol_opacity_update update
  def update
    _symbol_opacity_update
    update_symbol_opacity
  end
end

class Game_Player < Game_Character
  #--------------------------------------------------------------------------
  # ● 公開インスタンス変数
  #--------------------------------------------------------------------------
  attr_writer :stealth_count
  #--------------------------------------------------------------------------
  # ● 公開メンバ変数の初期化
  #--------------------------------------------------------------------------
  def init_public_members
    super
    reset_stealth
  end
  #--------------------------------------------------------------------------
  # ● ステルス状態の初期化
  #--------------------------------------------------------------------------
  def reset_stealth
    @stealth_count = 0
  end
  #--------------------------------------------------------------------------
  # ● ステルス判定
  #--------------------------------------------------------------------------
  def stealth?
    !@stealth_count.zero?
  end
  #--------------------------------------------------------------------------
  # ● 歩数増加
  #--------------------------------------------------------------------------
  alias _increase_stealth_count increase_steps
  def increase_steps
    _increase_stealth_count
    @stealth_count -= 1 if stealth?
  end
  #--------------------------------------------------------------------------
  # ● シンボルエンカウント関連処理による透明度の更新
  #--------------------------------------------------------------------------
  def update_symbol_opacity
    if stealth? && !$game_map.interpreter.running?
      @opacity = 128
    else
      @opacity = @origin_opacity
    end
  end
end

class Game_Follower < Game_Character
  #--------------------------------------------------------------------------
  # ● 公開インスタンス変数
  #--------------------------------------------------------------------------
  attr_reader :member_index
end

class Game_Event < Game_Character
  #--------------------------------------------------------------------------
  # ● インクルード SymbolEncount
  #--------------------------------------------------------------------------
  include SymbolEncount
  #--------------------------------------------------------------------------
  # ● 公開インスタンス変数
  #--------------------------------------------------------------------------
  attr_reader :symbol_encount
  attr_reader :contact_condition
  #--------------------------------------------------------------------------
  # ● 非公開メンバ変数の初期化
  #--------------------------------------------------------------------------
  alias _symbol_encount_ini init_private_members
  def init_private_members
    _symbol_encount_ini
    init_symbol_encount
  end
  #--------------------------------------------------------------------------
  # ● イベントページのセットアップ
  #--------------------------------------------------------------------------
  alias _symbol_encount_setup_page setup_page
  def setup_page(new_page)
    init_symbol_encount
    _symbol_encount_setup_page(new_page)
  end
  #--------------------------------------------------------------------------
  # ● シンボルエンカウントの初期化
  #--------------------------------------------------------------------------
  def init_symbol_encount
    @forming = false
    @symbol_encount = false
    @symbol_away_level = 0
    @symbol_away_level_type = 0
    @reaction_distance = 0
    @reaction_distance_with_dash = 0
    @nonreaction_move_type = 0
    @visibility_distance = 0
    @reaction_before_speed = 0
    @reaction_after_speed = 0
    @reaction_before_speed = 0
    @reaction_after_frequency = 0
    @reaction_balloon_id = 0
    @unpassable_region = []
    @contact_index = -1
    @contact_condition = 0
  end
  #--------------------------------------------------------------------------
  # ● シンボルエンカウントを有効化
  #--------------------------------------------------------------------------
  def enable_symbol_encount(id)
    data = SYMBOL_SETTING_LIST[id]
    @symbol_encount = true
    @symbol_away_level = data[0]
    @symbol_away_level_type = data[1]
    @reaction_distance = data[2]
    @reaction_distance_with_dash = data[3]
    @nonreaction_move_type = data[4]
    @visibility_distance = data[5]
    @reaction_before_speed = data[6]
    @reaction_after_speed = data[7]
    @reaction_before_frequency = data[8]
    @reaction_after_frequency = data[9]
    @reaction_balloon_id = data[10]
    @unpassable_region = data[11].dup
  end
  #--------------------------------------------------------------------------
  # ● 通行可能判定
  #--------------------------------------------------------------------------
  def passable?(x, y, d)
    if @symbol_encount
      x2 = $game_map.round_x_with_direction(x, d)
      y2 = $game_map.round_y_with_direction(y, d)
      return false if @unpassable_region.include?($game_map.region_id(x2, y2))
    end
    super
  end
  #--------------------------------------------------------------------------
  # ● ロック（実行中のイベントが立ち止まる処理）　※再定義
  #--------------------------------------------------------------------------
  def lock
    unless @locked
      @prelock_direction = @direction
      turn_toward_player unless @symbol_encount
      @locked = true
    end
  end
  #--------------------------------------------------------------------------
  # ● プレイヤーレベルの取得
  #--------------------------------------------------------------------------
  def player_level
    $game_party.get_player_level(@symbol_away_level_type)
  end
  #--------------------------------------------------------------------------
  # ● プレイヤーからの距離を取得
  #--------------------------------------------------------------------------
  def distance_from_player
    distance_x_from($game_player.x).abs + distance_y_from($game_player.y).abs
  end
  #--------------------------------------------------------------------------
  # ● 指定キャラクターからの距離を取得
  #--------------------------------------------------------------------------
  def distance_from_character(character)
    distance_x_from(character.x).abs + distance_y_from(character.y).abs
  end
  #--------------------------------------------------------------------------
  # ● 反応するプレイヤーからの距離を取得
  #--------------------------------------------------------------------------
  def reaction_distance
    if @forming
      @reaction_distance_with_dash.next
    elsif $game_player.dash? && $game_player.moving?
      @reaction_distance_with_dash
    else
      @reaction_distance
    end
  end
  #--------------------------------------------------------------------------
  # ● シンボルエンカウントを動作させるか
  #--------------------------------------------------------------------------
  def active_symbol_encount?
    if $game_map.interpreter.running?
      false
    elsif @erased || $game_player.stealth?
      @forming = false
      false
    else
      true
    end
  end
  #--------------------------------------------------------------------------
  # ● プレイヤーと同じ方向を向いているか
  #--------------------------------------------------------------------------
  def direction_as_player?
    direction == $game_player.direction
  end
  #--------------------------------------------------------------------------
  # ● 指定キャラクターとの簡易接触判定
  #--------------------------------------------------------------------------
  def contact?(character)
    distance_from_character(character) <= 1
  end
  #--------------------------------------------------------------------------
  # ● プレイヤーへの反応判定
  #--------------------------------------------------------------------------
  def reaction?
    distance_from_player <= reaction_distance
  end
  #--------------------------------------------------------------------------
  # ● プレイヤーからの逃走判定
  #--------------------------------------------------------------------------
  def away?
    player_level > @symbol_away_level
  end
  #--------------------------------------------------------------------------
  # ● 接触状況の判断
  #--------------------------------------------------------------------------
  def set_contact_condition
    @contact_index = -1
    @contact_condition = 0
    if contact?($game_player)
      @contact_index = 0
    elsif FOLLOWER_CONTACT
      $game_player.followers.visible_folloers.each{|follower|
        @contact_index = follower.member_index if contact?(follower)
      }
    end
    if @contact_index.zero?
      @contact_condition = direction_and_positional
    elsif $game_player.followers.visible_folloers.size == @contact_index
      @contact_condition = 2
    else
      @contact_condition = 0
    end
  end
  #--------------------------------------------------------------------------
  # ● プレイヤーとの位置と向き関係から接触状況を取得
  #--------------------------------------------------------------------------
  def direction_and_positional
    position = positional_relationship($game_player)
    if position == -1
      0
    else
      case direction
      when 2
        direction_as_player? ? (position == 0 ? 1 : 2) : 0
      when 4
        direction_as_player? ? (position == 2 ? 1 : 2) : 0
      when 6
        direction_as_player? ? (position == 3 ? 1 : 2) : 0
      when 8
        direction_as_player? ? (position == 1 ? 1 : 2) : 0
      else
        0
      end
    end
  end
  #--------------------------------------------------------------------------
  # ● 接触イベントの起動判定
  #--------------------------------------------------------------------------
  alias _symbol_encount_trigger check_event_trigger_touch
  def check_event_trigger_touch(x, y)
    if @symbol_encount && FOLLOWER_CONTACT
      unless $game_map.interpreter.running?
        if @trigger == 2 && collide_with_player_characters?(x, y)
          start unless jumping?
        end
      end
    else
      _symbol_encount_trigger(x, y)
    end
  end
  #--------------------------------------------------------------------------
  # ● 追跡の開始
  #--------------------------------------------------------------------------
  def start_forming
    @move_speed = @reaction_after_speed
    @move_frequency = @reaction_after_frequency
    unless @reaction_balloon_id.zero?
      Audio.se_play('Audio/SE/Decision1', 50, 150)
      @balloon_id = @reaction_balloon_id
    end
  end
  #--------------------------------------------------------------------------
  # ● 追跡の終了（見失う）
  #--------------------------------------------------------------------------
  def end_forming
    @move_speed = @reaction_before_speed
    @move_frequency = @reaction_before_frequency
  end
  #--------------------------------------------------------------------------
  # ● 反応している時の移動処理
  #--------------------------------------------------------------------------
  def reaction_movement
    @move_speed = @reaction_after_speed
    @move_frequency = @reaction_after_frequency
    if @symbol_away_level.zero?
      move_type_toward_player
    elsif away?
      move_away_from_player
    else
      move_type_toward_player
    end
  end
  #--------------------------------------------------------------------------
  # ● 反応していない時の移動処理
  #--------------------------------------------------------------------------
  def nonreaction_movement
    @move_speed = @reaction_before_speed
    @move_frequency = @reaction_before_frequency
    case @nonreaction_move_type
    when 0
      move_type_random
    when 1
    end
  end
  #--------------------------------------------------------------------------
  # ● フレーム更新
  #--------------------------------------------------------------------------
  alias _update_with_symbol update
  def update
    update_symbol_reaction if @symbol_encount && @wait_count <= 0 && !@move_route_forcing
    _update_with_symbol
  end
  #--------------------------------------------------------------------------
  # ● プレイヤーへの反応判定を更新
  #--------------------------------------------------------------------------
  def update_symbol_reaction
    if active_symbol_encount?
      if !@forming && reaction?
        start_forming
      elsif @forming && !reaction?
        end_forming
      end
      @forming = reaction?
    end
  end
  #--------------------------------------------------------------------------
  # ● シンボルエンカウント関連処理による透明度の更新
  #--------------------------------------------------------------------------
  def update_symbol_opacity
    if @visibility_distance.zero?
      @opacity = @origin_opacity
    else
      @opacity = @origin_opacity - 50 * (distance_from_player - @visibility_distance)
    end
  end
  #--------------------------------------------------------------------------
  # ● 自律移動の更新
  #--------------------------------------------------------------------------
  alias _update_self_movement_with_symbol update_self_movement
  def update_self_movement
    if @symbol_encount
      update_symbol_movement if near_the_screen? && @stop_count > stop_count_threshold
    else
      _update_self_movement_with_symbol
    end
  end
  #--------------------------------------------------------------------------
  # ● シンボルの動作を更新
  #--------------------------------------------------------------------------
  def update_symbol_movement
    if near_the_screen? && @stop_count > stop_count_threshold
      if active_symbol_encount?
        @forming ? reaction_movement : nonreaction_movement
      else
        nonreaction_movement
      end
    end
  end
end

class Game_Interpreter
  #--------------------------------------------------------------------------
  # ● バトルの処理
  #--------------------------------------------------------------------------
  alias _command_301_with_symbol_encount command_301
  def command_301
    unless $game_party.in_battle
      BattleManager.run_event = $game_map.events[@event_id]
      _command_301_with_symbol_encount
    end
  end
  #--------------------------------------------------------------------------
  # ● ステルス状態の解除
  #--------------------------------------------------------------------------
  def reset_stealth
    $game_player.reset_stealth
  end
end