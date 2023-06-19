#==============================================================================
# ★ RGSS3_パッシブスキル Ver1.01
#==============================================================================
=begin

作者：tomoaky
webサイト：ひきも記 (http://hikimoki.sakura.ne.jp/)

メモ欄に <パッシブ 5> という文字列が含まれるスキルを習得していると
ID５番の武器を装備しているのと同じ効果が得られるようになります。

2012.02.24  Ver1.01
　・パッシブスキルのみを習得している場合に発生する不具合を修正

2012.02.17　Ver1.0
  公開

=end

#==============================================================================
# □ 設定項目
#==============================================================================
module TMPASSIVE
  INVISIBLE_TYPE = [3]      # 戦闘中のコマンドリストに表示しないスキルタイプ
end

#==============================================================================
# ■ RPG::Skill
#==============================================================================
class RPG::Skill
  #--------------------------------------------------------------------------
  # ○ パッシブスキルの効果（武器ID）を返す
  #--------------------------------------------------------------------------
  def passive_effect
    @passive_effect ||= /<パッシブ\s*(\d+)\s*>/ =~ @note ? $1.to_i : 0
  end
end

#==============================================================================
# ■ Game_Actor
#==============================================================================
class Game_Actor
  #--------------------------------------------------------------------------
  # ● 追加スキルタイプの取得
  #--------------------------------------------------------------------------
  alias tmpassive_game_actor_added_skill_types added_skill_types
  def added_skill_types
    if $game_party.in_battle
      tmpassive_game_actor_added_skill_types - TMPASSIVE::INVISIBLE_TYPE
    else
      tmpassive_game_actor_added_skill_types
    end
  end
  #--------------------------------------------------------------------------
  # ● 特徴を保持する全オブジェクトの配列取得
  #--------------------------------------------------------------------------
  alias tmpassive_game_actor_feature_objects feature_objects
  def feature_objects
    tmpassive_game_actor_feature_objects + passive_skills
  end
  #--------------------------------------------------------------------------
  # ● 通常能力値の加算値取得
  #--------------------------------------------------------------------------
  alias tmpassive_game_actor_param_plus param_plus
  def param_plus(param_id)
    passive_skills.inject(tmpassive_game_actor_param_plus(param_id)) {
      |r, item| r += item.params[param_id] }
  end
  #--------------------------------------------------------------------------
  # ○ 習得しているパッシブスキルの効果（武器オブジェクト）の配列を返す
  #--------------------------------------------------------------------------
  def passive_skills
    result = ((@skills.collect {|id| $data_skills[id] }).collect {
      |skill| $data_weapons[skill.passive_effect] }).compact
    result
  end
end
