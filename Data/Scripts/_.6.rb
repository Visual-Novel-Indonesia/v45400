#==============================================================================
# ■ RGSS3 命中・会心システム改変 Ver1.00 by 星潟
#------------------------------------------------------------------------------
# 命中判定と回避判定が別にあるデフォルトシステムを変更し
# 回避判定を消滅させ、命中率と回避率の差分を以て実効命中率とします。
# また、会心率・会心回避率については
# 会心率と1 - 会心回避率の乗算で会心率を求める計算を変更し
# 会心率から会心回避率を引いた確率で実効会心率とします。
#==============================================================================
module EFF_PER
  
  #命中率と回避率の計算を変更するか否か(true 変更する/false 変更しない)
  
  HE_EFF = true
  
  #会心率と会心回避率の計算を変更するか否か(true 変更する/false 変更しない)
  
  CC_EFF = true
  
end
class Game_Battler < Game_BattlerBase
  #--------------------------------------------------------------------------
  # ● スキル／アイテムの実効会心率の計算
  #--------------------------------------------------------------------------
  alias item_cri_efficiency item_cri
  def item_cri(user, item)
    return item_cri_efficiency(user, item) if !EFF_PER::CC_EFF
    if item.damage.critical
      data = eff_cri(user, item)
      return data if data > 0
    end
    return 0
  end
  #--------------------------------------------------------------------------
  # ● スキル／アイテムの効果適用
  #--------------------------------------------------------------------------
  alias item_apply_efficiency item_apply
  def item_apply(user, item)
    return item_apply_efficiency(user, item) if !EFF_PER::HE_EFF
    @result.clear
    @result.used = item_test(user, item)
    @result.missed = (@result.used && rand >= eff_hit(user, item))
    @result.evaded = @result.missed
    if @result.hit?
      unless item.damage.none?
        @result.critical = (rand < item_cri(user, item))
        make_damage_value(user, item)
        execute_damage(user)
      end
      item.effects.each {|effect| item_effect_apply(user, item, effect) }
      item_user_effect(user, item)
    end
  end
  #--------------------------------------------------------------------------
  # ● 実効命中率の計算
  #--------------------------------------------------------------------------
  def eff_hit(user, item)
    data = item_hit(user, item) - item_eva(user, item)
    data = 0 if data < 0
    return data
  end
  #--------------------------------------------------------------------------
  # ● 実効会心率の計算
  #--------------------------------------------------------------------------
  def eff_cri(user, item)
    data = user.cri - cev
    data = 0 if data < 0
    return data
  end
end
