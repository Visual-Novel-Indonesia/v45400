#--------------------------------------------------------------------------
#戦闘高速化 ver0.30
#--------------------------------------------------------------------------
=begin

 ボタン押しっぱなしで戦闘速度が飛躍的に上昇します。
 コマンドもボタン押しっぱなしで選択可能です。
 また、元々の通常状態でもちょっとテンポを上げています。
 
 BATTLE_SPEED_SIDに設定したスイッチIDをtrueにする事で、
 高速戦闘中はエフェクトをカット出来るようになります。

 BATTLE_SPEED_VIDに設定した値は、ゲーム変数XXX番として認識します。
 コマンドで変数に値を入れる事によって、戦闘速度が変更されます。
 値が大きい程、早くなります。

 BATTLE_SPEED_DEFAULT_VALUEに設定した値は速度のデフォルト値です。
 下記は例になります。なお、小数点には対応していません。

 戦闘速度1：遅め(オリジナルの戦闘システムに近い速度)
 　　　　2：普通(推奨値)
 　　　　3：速め
 　　　　6：高速
 　　　 10：最速、11以上の値を入れると、10になるように制限をかけています。
　　　　　　※ 11以上はバトルログが消え、20以上はエラーを返します。
　　　　　　※ 速度0は未対応です。1に制限をかける事も考えましたが、
　　　　　　　 変数指定を間違っていた際にバグチェックしづらくなるため、
　　　　　　　 わざとエラーするようにしています。

=end

#--------------------------------------------------------------------------
# ● 設定項目
#--------------------------------------------------------------------------

module SSS_BTLSPD
  BATTLE_SPEED_SID = 100          #エフェクト(アニメ)を飛ばすスイッチ
  BATTLE_SPEED_VID = 100          #戦闘速度変更用のゲーム変数
  BATTLE_SPEED_DEFAULT_VALUE = 2  #速度変更値(整数10まで)
end


class Scene_Map
  #--------------------------------------------------------------------------
  # ● 戦闘前トランジション実行　＠速度変更
  #--------------------------------------------------------------------------
  alias SSS001_perform_battle_transition perform_battle_transition
  def perform_battle_transition
    if $game_variables[SSS_BTLSPD::BATTLE_SPEED_VID] == 0
      $game_variables[SSS_BTLSPD::BATTLE_SPEED_VID] = SSS_BTLSPD::BATTLE_SPEED_DEFAULT_VALUE
    end
    if $game_variables[SSS_BTLSPD::BATTLE_SPEED_VID] >= 11
      $game_variables[SSS_BTLSPD::BATTLE_SPEED_VID] = 10
    end
    Graphics.transition(25 / $game_variables[SSS_BTLSPD::BATTLE_SPEED_VID], "Graphics/System/BattleStart", 100)
    Graphics.freeze
  end
end

class Scene_Battle
  
  #--------------------------------------------------------------------------
  # ● 終了前処理
  #--------------------------------------------------------------------------
  alias SSS001_pre_terminate pre_terminate
  def pre_terminate
    super
    Graphics.fadeout(30 / $game_variables[SSS_BTLSPD::BATTLE_SPEED_VID]) if SceneManager.scene_is?(Scene_Map)
    Graphics.fadeout(30 / $game_variables[SSS_BTLSPD::BATTLE_SPEED_VID]) if SceneManager.scene_is?(Scene_Title)
  end
  
  #--------------------------------------------------------------------------
  # ● ウェイト
  #--------------------------------------------------------------------------
  alias SSS001_wait wait
  def wait(duration)
    duration.times {|i| update_for_wait if i < duration / (2 * $game_variables[SSS_BTLSPD::BATTLE_SPEED_VID]) || !show_fast? }
  end

  #--------------------------------------------------------------------------
  # ● アニメーションの表示
  #     targets      : 対象者の配列
  #     animation_id : アニメーション ID（-1: 通常攻撃と同じ）
  #--------------------------------------------------------------------------
  alias SSS001_show_animation show_animation
  def show_animation(targets, animation_id)
    #もしアニメカット用のスイッチがtrueで、
    #fast状態にしているなら、エフェクトを飛ばす
    #両方満たしていないなら、エフェクトを飛ばさない
    if $game_switches[SSS_BTLSPD::BATTLE_SPEED_SID] == true
      if !show_fast?
        if animation_id < 0
          show_attack_animation(targets)
        else
          show_normal_animation(targets, animation_id)
        end
        @log_window.wait
        wait_for_animation
      end
    else
      if animation_id < 0
        show_attack_animation(targets)
      else
        show_normal_animation(targets, animation_id)
      end
      @log_window.wait
      wait_for_animation
    end
  end
end

class Window_Selectable
  #--------------------------------------------------------------------------
  # ● 決定やキャンセルなどのハンドリング処理
  #--------------------------------------------------------------------------
  alias SSS001_process_handling process_handling
  def process_handling
      #戦闘中はInput.trigger?をrepeat?に書き換えて、テンポを上げてます
    if $game_party.in_battle
      return unless open? && active
      return process_ok       if ok_enabled?        && Input.repeat?(:C)
      return process_cancel   if cancel_enabled?    && Input.repeat?(:B)
      return process_pagedown if handle?(:pagedown) && Input.trigger?(:R)
      return process_pageup   if handle?(:pageup)   && Input.trigger?(:L)
    else
      return unless open? && active
      return process_ok       if ok_enabled?        && Input.trigger?(:C)
      return process_cancel   if cancel_enabled?    && Input.trigger?(:B)
      return process_pagedown if handle?(:pagedown) && Input.trigger?(:R)
      return process_pageup   if handle?(:pageup)   && Input.trigger?(:L)
    end
  end
end

class Sprite_Battler
  #--------------------------------------------------------------------------
  # ● エフェクトの開始
  #--------------------------------------------------------------------------
  alias SSS001_start_effect start_effect
  def start_effect(effect_type)
    @effect_type = effect_type
    case @effect_type
    when :appear
      @effect_duration = 16
      @battler_visible = true
    when :disappear
      @effect_duration = 32 
      @battler_visible = false
    when :whiten
      @effect_duration = 16
      @battler_visible = true
    when :blink
      @effect_duration = 20
      @battler_visible = true
    #敵撃破時エフェクト(default=48)
    #Sprite_Battler 150行以降を変数を織りまぜて書き換えた方が良いかも
    when :collapse
      @effect_duration = 38 / ($game_variables[SSS_BTLSPD::BATTLE_SPEED_VID])
      @battler_visible = false
    when :boss_collapse
      @effect_duration = bitmap.height
      @battler_visible = false
    when :instant_collapse
      @effect_duration = 16
      @battler_visible = false
      end
      revert_to_normal
  end
end