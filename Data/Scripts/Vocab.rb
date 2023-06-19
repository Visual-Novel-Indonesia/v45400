#==============================================================================
# ■ Vocab
#------------------------------------------------------------------------------
# 　用語とメッセージを定義するモジュールです。定数でメッセージなどを直接定義す
# るほか、グローバル変数 $data_system から用語データを取得します。
#==============================================================================

module Vocab

  # ショップ画面
  ShopBuy         = "Buy"
  ShopSell        = "Sell"
  ShopCancel      = "Stop"
  Possession      = "Held"

  # ステータス画面
  ExpTotal        = "Exp Total"
  ExpNext         = "Next %s"

  # セーブ／ロード画面
  SaveMessage     = "Which file do you want to save in?"
  LoadMessage     = "Which file do you want to load?"
  File            = "File"

  # 複数メンバーの場合の表示
  PartyName       = "%s's party"

  # 戦闘基本メッセージ
  Emerge          = "%s appeared!"
  Preemptive      = "%s took the initiative!"
  Surprise        = "%s was taken by surprise!"
  EscapeStart     = "%s is running away!"
  EscapeFailure   = "But was unable to escape!"

  # 戦闘終了メッセージ
  Victory         = "%s's victory!"
  Defeat          = "%s was defeated."
  ObtainExp       = "%s experience gained!"
  ObtainGold      = "%s\\G obtained!"
  ObtainItem      = "%s obtained!"
  LevelUp         = "%s went up to %s %s!"
  ObtainSkill     = "%s was learned!"

  # アイテム使用
  UseItem         = "%s used %s!"

  # クリティカルヒット
  CriticalToEnemy = "Critical Hit!!"
  CriticalToActor = "A regretful blow!!"

  # アクター対象の行動結果
  ActorDamage     = "%s took %s damage!"
  ActorRecovery   = "%s recovered %s %s!"
  ActorGain       = "%s gained %s %s!"
  ActorLoss       = "%s lost %s %s!"
  ActorDrain      = "%s was drained of %s %s!"
  ActorNoDamage   = "%s took no damage!"
  ActorNoHit      = "Miss! %s took no damage!"

  # 敵キャラ対象の行動結果
  EnemyDamage     = "%s took %s damage!"
  EnemyRecovery   = "%s recovered %s %s!"
  EnemyGain       = "%s gained %s %s!"
  EnemyLoss       = "%s lost %s %s!"
  EnemyDrain      = "%s was drained of %s %s!"
  EnemyNoDamage   = "%s took no damage!"
  EnemyNoHit      = "Miss! %s took no damage!"

  # 回避／反射
  Evasion         = "%s dodged the attack!"
  MagicEvasion    = "%s negated the magic!"
  MagicReflection = "%s reflected the magic!"
  CounterAttack   = "%s counterattacks!"
  Substitute      = "%s protects %s!"

  # 能力強化／弱体
  BuffAdd         = "%s's %s increased!"
  DebuffAdd       = "%s's %s decreased!"
  BuffRemove      = "%s's %s returned to normal!"

  # スキル、アイテムの効果がなかった
  ActionFailure   = "%s had no effect!"

  # エラーメッセージ
  PlayerPosError  = "Player's initial position not set."
  EventOverflow   = "Common Event exceeded the limit."

  # 基本ステータス
  def self.basic(basic_id)
    $data_system.terms.basic[basic_id]
  end

  # 能力値
  def self.param(param_id)
    $data_system.terms.params[param_id]
  end

  # 装備タイプ
  def self.etype(etype_id)
    $data_system.terms.etypes[etype_id]
  end

  # コマンド
  def self.command(command_id)
    $data_system.terms.commands[command_id]
  end

  # 通貨単位
  def self.currency_unit
    $data_system.currency_unit
  end

  #--------------------------------------------------------------------------
  def self.level;       basic(0);     end   # レベル
  def self.level_a;     basic(1);     end   # レベル (短)
  def self.hp;          basic(2);     end   # HP
  def self.hp_a;        basic(3);     end   # HP (短)
  def self.mp;          basic(4);     end   # MP
  def self.mp_a;        basic(5);     end   # MP (短)
  def self.tp;          basic(6);     end   # TP
  def self.tp_a;        basic(7);     end   # TP (短)
  def self.fight;       command(0);   end   # 戦う
  def self.escape;      command(1);   end   # 逃げる
  def self.attack;      command(2);   end   # 攻撃
  def self.guard;       command(3);   end   # 防御
  def self.item;        command(4);   end   # アイテム
  def self.skill;       command(5);   end   # スキル
  def self.equip;       command(6);   end   # 装備
  def self.status;      command(7);   end   # ステータス
  def self.formation;   command(8);   end   # 並び替え
  def self.save;        command(9);   end   # セーブ
  def self.game_end;    command(10);  end   # ゲーム終了
  def self.weapon;      command(12);  end   # 武器
  def self.armor;       command(13);  end   # 防具
  def self.key_item;    command(14);  end   # 大事なもの
  def self.equip2;      command(15);  end   # 装備変更
  def self.optimize;    command(16);  end   # 最強装備
  def self.clear;       command(17);  end   # 全て外す
  def self.new_game;    command(18);  end   # ニューゲーム
  def self.continue;    command(19);  end   # コンティニュー
  def self.shutdown;    command(20);  end   # シャットダウン
  def self.to_title;    command(21);  end   # タイトルへ
  def self.cancel;      command(22);  end   # やめる
  #--------------------------------------------------------------------------
end
