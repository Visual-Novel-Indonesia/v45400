=begin
      RGSS3
      
      ★ フキダシアイコン常時再生 ★

      フキダシアイコンを表示し続けるキャラクターを作ります。
      寝ているキャラなどにどうぞ。
      新たな画像ファイルを作って、お店の看板代わりとかもいいかも。

      ● 仕様 ●==========================================================
      横に8分割されたフキダシアイコン画像の内、
      左から 3～7つ目をループ再生します。
      ====================================================================
      
      ● 使い方 ●========================================================
      イベント＞自律移動＞カスタム＞移動ルート＞スクリプトに
          @auto_balloon = n
      と記述してください。nはフキダシアイコンのIDです。
      ====================================================================
      
      ver1.00

      Last Update : 2011/12/18
      12/18 : 新規
      
      ろかん　　　http://kaisou-ryouiki.sakura.ne.jp/
=end

#===========================================
#   設定箇所
#===========================================
module Rokan
module Auto_Balloon
    # フキダシの半透明化が始まるプレイヤーとの距離
    # 不透明化を行わない場合は"0"を設定してください。
    DBO = 0
end
end
#===========================================
#   ここまで
#===========================================

$rsi ||= {}
$rsi["フキダシアイコン常時再生"] = true

class Game_Event < Game_Character
  #--------------------------------------------------------------------------
  # ● 公開インスタンス変数
  #--------------------------------------------------------------------------
  attr_reader   :auto_balloon
  #--------------------------------------------------------------------------
  # ● 公開メンバ変数の初期化
  #--------------------------------------------------------------------------
  alias _auto_balloon_init init_public_members
  def init_public_members
    _auto_balloon_init
    @auto_balloon = 0
  end
  #--------------------------------------------------------------------------
  # ● プレイヤーからの距離を取得
  #--------------------------------------------------------------------------
  def distance_from_player
    distance_x_from($game_player.x).abs + distance_y_from($game_player.y).abs
  end
  #--------------------------------------------------------------------------
  # ● イベントページのセットアップ
  #--------------------------------------------------------------------------
  alias _auto_balloon_setup_page setup_page
  def setup_page(new_page)
    @auto_balloon = 0
    _auto_balloon_setup_page(new_page)
  end
end

class Sprite_Character < Sprite_Base
  #--------------------------------------------------------------------------
  # ● インクルード Rokan::Auto_Balloon
  #--------------------------------------------------------------------------
  include Rokan::Auto_Balloon
  #--------------------------------------------------------------------------
  # ● 解放
  #--------------------------------------------------------------------------
  alias _auto_balloon_dispose dispose
  def dispose
    dispose_auto_balloon
    _auto_balloon_dispose
  end
  #--------------------------------------------------------------------------
  # ● 常時再生フキダシアイコンの解放
  #--------------------------------------------------------------------------
  def dispose_auto_balloon
    @bw = 10
    @bx = -1
    @auto_balloon_id = 0
    if @auto_balloon_sprite
      @auto_balloon_sprite.dispose
      @auto_balloon_sprite = nil
    end
  end
  #--------------------------------------------------------------------------
  # ● フレーム更新
  #--------------------------------------------------------------------------
  alias _auto_balloon_update update
  def update
    update_auto_balloon
    _auto_balloon_update
  end
  #--------------------------------------------------------------------------
  # ● プレイヤーからの距離を取得
  #--------------------------------------------------------------------------
  def distance_from_player
    @character.distance_from_player
  end
  #--------------------------------------------------------------------------
  # ● 距離によるフキダシの透明度を取得
  #--------------------------------------------------------------------------
  def distance_balloon_opacity
    DBO.zero? ? 255 : 255 - 50 * (distance_from_player - DBO)
  end
  #--------------------------------------------------------------------------
  # ● 表示するフキダシのX座標を取得
  #--------------------------------------------------------------------------
  def auto_balloon_x
    @bx * 32 + 64
  end
  #--------------------------------------------------------------------------
  # ● 表示するフキダシのY座標を取得
  #--------------------------------------------------------------------------
  def auto_balloon_y
    (@auto_balloon_id - 1) * 32
  end
  #--------------------------------------------------------------------------
  # ● 常時再生フキダシアイコン表示の開始
  #--------------------------------------------------------------------------
  def start_auto_balloon
    dispose_auto_balloon
    @auto_balloon_id = @character.auto_balloon
    @auto_balloon_sprite = Sprite.new(self.viewport) 
    @auto_balloon_sprite.bitmap = Cache.system("Balloon")
    @auto_balloon_sprite.z = self.z + 200
    @auto_balloon_sprite.ox = 16
    @auto_balloon_sprite.oy = 32
  end
  #--------------------------------------------------------------------------
  # ● 常時再生フキダシアイコンの更新
  #--------------------------------------------------------------------------
  def update_auto_balloon
    if @character.is_a?(Game_Event)
      if @character.auto_balloon.zero? || !@balloon_duration.zero?
        dispose_auto_balloon
      else
        start_auto_balloon if !@auto_balloon_sprite || @auto_balloon_id != @character.auto_balloon
        @auto_balloon_sprite.x = self.x
        @auto_balloon_sprite.y = self.y - self.height
        @auto_balloon_sprite.opacity = distance_balloon_opacity
        if @bw == 10
          @bw = 0
          @bx = @bx == 4 ? 0 : @bx.next
          @auto_balloon_sprite.src_rect.set(auto_balloon_x, auto_balloon_y, 32, 32)
        else
          @bw = @bw.next
        end
      end
    end
  end
end