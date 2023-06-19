=begin
生者死者両方に使えるアイテム・スキルVXAce版
２０１２年０１月１７日　作成。
製作：tamura
http://tamurarpgvx.blog137.fc2.com/blog-entry-119.html

【概要】
・通常、アイテムの「効果範囲」を、「味方単体（戦闘不能）」とすると、
　戦闘不能でない味方へは使えません。
　このスクリプトは、その制限を無くして、戦闘不能の味方に使えば復活、
　戦闘不能でない味方に使えば全回復、などといったアイテムを作れるようにします。

【使い方】
アイテムやスキルのメモ欄に、
<生者にも効果>
と記述して、効果範囲は「味方単体（戦闘不能）」もしくは
「味方全体（戦闘不能）」を指定して下さい。
なお、敵を標的にしたアイテムには対応していません。

【改訂履歴】
2012.01.17　製作。

=end
#==============================================================================
# ■ Game_Battler
#==============================================================================
class Game_Battler < Game_BattlerBase
  #--------------------------------------------------------------------------
  # ● スキル／アイテムの適用テスト　※再定義
  #--------------------------------------------------------------------------
  def item_test(user, item)
    unless /<生者にも効果>/ =~ item.note
     return false if item.for_dead_friend? != dead?
    end
    return true if $game_party.in_battle
    return true if item.for_opponent?
    return true if item.damage.recover? && item.damage.to_hp? && hp < mhp
    return true if item.damage.recover? && item.damage.to_mp? && mp < mmp
    return true if item_has_any_valid_effects?(user, item)
    return false
  end
end
  
#==============================================================================
# ■ Game_Unit
#==============================================================================
class Game_Unit
  #--------------------------------------------------------------------------
  # ● ターゲットのスムーズな決定・生死にかかわらず。
  #--------------------------------------------------------------------------
  def smooth_target_all(index)
    return members[index]
  end
end  
  
#==============================================================================
# ■ Game_Action
#==============================================================================
class Game_Action
  #--------------------------------------------------------------------------
  # ● 味方に対するターゲット　※再定義
  #--------------------------------------------------------------------------
  def targets_for_friends
    if item.for_user?
      [subject]
    elsif item.for_dead_friend?
      if item.for_one?
        if /<生者にも効果>/ =~ item.note
          [friends_unit.smooth_target_all(@target_index)] #生死関わらず。
        else
          [friends_unit.smooth_dead_target(@target_index)]
        end
      else
        if /<生者にも効果>/ =~ item.note
          friends_unit.members #全メンバーを返す。
        else
          friends_unit.dead_members
        end
      end
    elsif item.for_friend?
      if item.for_one?
        [friends_unit.smooth_target(@target_index)]
      else
        friends_unit.alive_members
      end
    end
  end
end