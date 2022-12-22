package com.company.assembleegameclient.ui.options
{
   import com.company.assembleegameclient.game.GameSprite;
   import com.company.assembleegameclient.parameters.Parameters;
   import com.company.assembleegameclient.screens.TitleMenuOption;
   import com.company.assembleegameclient.sound.Music;
   import com.company.assembleegameclient.sound.SFX;
   import com.company.assembleegameclient.ui.StatusBar;
   import com.company.rotmg.graphics.ScreenGraphic;
   import com.company.util.AssetLibrary;
   import flash.display.BitmapData;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.KeyboardEvent;
   import flash.events.MouseEvent;
   import flash.filters.DropShadowFilter;
   import flash.geom.Point;
   import flash.system.Capabilities;
   import flash.text.TextFieldAutoSize;
   import flash.ui.Mouse;
   import flash.ui.MouseCursor;
   import flash.ui.MouseCursorData;
   import kabam.rotmg.text.model.TextKey;
   import kabam.rotmg.text.view.TextFieldDisplayConcrete;
   import kabam.rotmg.text.view.stringBuilder.LineBuilder;
   import kabam.rotmg.text.view.stringBuilder.StaticStringBuilder;
   import kabam.rotmg.text.view.stringBuilder.StringBuilder;
   
   public class Options extends Sprite
   {
      
      private static const TABS:Vector.<String> = new <String>[TextKey.OPTIONS_CONTROLS,TextKey.OPTIONS_HOTKEYS,TextKey.OPTIONS_CHAT,TextKey.OPTIONS_GRAPHICS,TextKey.OPTIONS_SOUND,"Hacks",TextKey.OPTIONS_EXTRA];
      
      public static const Y_POSITION:int = 550;
      
      public static const CHAT_COMMAND:String = "chatCommand";
      
      public static const CHAT:String = "chat";
      
      public static const TELL:String = "tell";
      
      public static const GUILD_CHAT:String = "guildChat";
      
      public static const SCROLL_CHAT_UP:String = "scrollChatUp";
      
      public static const SCROLL_CHAT_DOWN:String = "scrollChatDown";
      
      private static var registeredCursors:Vector.<String> = new Vector.<String>(0);
       
      
      private var gs_:GameSprite;
      
      private var continueButton_:TitleMenuOption;
      
      private var resetToDefaultsButton_:TitleMenuOption;
      
      private var homeButton_:TitleMenuOption;
      
      private var tabs_:Vector.<OptionsTabTitle>;
      
      private var selected_:OptionsTabTitle = null;
      
      private var options_:Vector.<Sprite>;
      
      public function Options(param1:GameSprite)
      {
         var _loc2_:TextFieldDisplayConcrete = null;
         var _loc3_:OptionsTabTitle = null;
         var _loc4_:int = 0;
         this.tabs_ = new Vector.<OptionsTabTitle>();
         this.options_ = new Vector.<Sprite>();
         super();
         this.gs_ = param1;
         graphics.clear();
         graphics.beginFill(2829099,0.8);
         graphics.drawRect(0,0,800,600);
         graphics.endFill();
         graphics.lineStyle(1,6184542);
         graphics.moveTo(0,100);
         graphics.lineTo(800,100);
         graphics.lineStyle();
         _loc2_ = new TextFieldDisplayConcrete().setSize(36).setColor(16777215);
         _loc2_.setBold(true);
         _loc2_.setStringBuilder(new LineBuilder().setParams(TextKey.OPTIONS_TITLE));
         _loc2_.setAutoSize(TextFieldAutoSize.CENTER);
         _loc2_.filters = [new DropShadowFilter(0,0,0)];
         _loc2_.x = 800 / 2 - _loc2_.width / 2;
         _loc2_.y = 8;
         addChild(_loc2_);
         addChild(new ScreenGraphic());
         this.continueButton_ = new TitleMenuOption(TextKey.OPTIONS_CONTINUE_BUTTON,36,false);
         this.continueButton_.setVerticalAlign(TextFieldDisplayConcrete.MIDDLE);
         this.continueButton_.setAutoSize(TextFieldAutoSize.CENTER);
         this.continueButton_.addEventListener(MouseEvent.CLICK,this.onContinueClick);
         addChild(this.continueButton_);
         this.resetToDefaultsButton_ = new TitleMenuOption(TextKey.OPTIONS_RESET_TO_DEFAULTS_BUTTON,22,false);
         this.resetToDefaultsButton_.setVerticalAlign(TextFieldDisplayConcrete.MIDDLE);
         this.resetToDefaultsButton_.setAutoSize(TextFieldAutoSize.LEFT);
         this.resetToDefaultsButton_.addEventListener(MouseEvent.CLICK,this.onResetToDefaultsClick);
         addChild(this.resetToDefaultsButton_);
         this.homeButton_ = new TitleMenuOption(TextKey.OPTIONS_HOME_BUTTON,22,false);
         this.homeButton_.setVerticalAlign(TextFieldDisplayConcrete.MIDDLE);
         this.homeButton_.setAutoSize(TextFieldAutoSize.RIGHT);
         this.homeButton_.addEventListener(MouseEvent.CLICK,this.onHomeClick);
         addChild(this.homeButton_);
         _loc4_ = 14;
         var _loc5_:int = 0;
         while(_loc5_ < TABS.length)
         {
            _loc3_ = new OptionsTabTitle(TABS[_loc5_]);
            _loc3_.x = _loc4_;
            _loc3_.y = 70;
            addChild(_loc3_);
            _loc3_.addEventListener(MouseEvent.CLICK,this.onTabClick);
            this.tabs_.push(_loc3_);
            _loc4_ += 111;
            _loc5_++;
         }
         addEventListener(Event.ADDED_TO_STAGE,this.onAddedToStage);
         addEventListener(Event.REMOVED_FROM_STAGE,this.onRemovedFromStage);
      }
      
      private static function makePotionBuy() : ChoiceOption
      {
         return new ChoiceOption("contextualPotionBuy",makeOnOffLabels(),[true,false],TextKey.OPTIONS_CONTEXTUAL_POTION_BUY,TextKey.OPTIONS_CONTEXTUAL_POTION_BUY_DESC,null);
      }
      
      private static function makeOnOffLabels() : Vector.<StringBuilder>
      {
         return new <StringBuilder>[makeLineBuilder(TextKey.OPTIONS_ON),makeLineBuilder(TextKey.OPTIONS_OFF)];
      }
      
      private static function makeHighLowLabels() : Vector.<StringBuilder>
      {
         return new <StringBuilder>[new StaticStringBuilder("High"),new StaticStringBuilder("Low")];
      }
      
      private static function makeStarSelectLabels() : Vector.<StringBuilder>
      {
         return new <StringBuilder>[new StaticStringBuilder("Off"),new StaticStringBuilder("1"),new StaticStringBuilder("2"),new StaticStringBuilder("3"),new StaticStringBuilder("5"),new StaticStringBuilder("10")];
      }
      
      private static function makeCursorSelectLabels() : Vector.<StringBuilder>
      {
         return new <StringBuilder>[new StaticStringBuilder("Off"),new StaticStringBuilder("ProX"),new StaticStringBuilder("X2"),new StaticStringBuilder("X3"),new StaticStringBuilder("X4"),new StaticStringBuilder("Corner1"),new StaticStringBuilder("Corner2"),new StaticStringBuilder("Symb"),new StaticStringBuilder("Alien"),new StaticStringBuilder("Xhair"),new StaticStringBuilder("Dystopia+")];
      }
      
      private static function makeLineBuilder(param1:String) : LineBuilder
      {
         return new LineBuilder().setParams(param1);
      }
      
      private static function onBarTextToggle() : void
      {
         StatusBar.barTextSignal.dispatch(Parameters.data_.toggleBarText);
      }
      
      public static function refreshCursor() : void
      {
         var _loc1_:MouseCursorData = null;
         var _loc2_:Vector.<BitmapData> = null;
         if(Parameters.data_.cursorSelect != MouseCursor.AUTO && registeredCursors.indexOf(Parameters.data_.cursorSelect) == -1)
         {
            _loc1_ = new MouseCursorData();
            _loc1_.hotSpot = new Point(15,15);
            _loc2_ = new Vector.<BitmapData>(1,true);
            _loc2_[0] = AssetLibrary.getImageFromSet("cursorsEmbed",int(Parameters.data_.cursorSelect));
            _loc1_.data = _loc2_;
            Mouse.registerCursor(Parameters.data_.cursorSelect,_loc1_);
            registeredCursors.push(Parameters.data_.cursorSelect);
         }
         Mouse.cursor = Parameters.data_.cursorSelect;
      }
      
      private static function makeDegreeOptions() : Vector.<StringBuilder>
      {
         return new <StringBuilder>[new StaticStringBuilder("45°"),new StaticStringBuilder("0°")];
      }
      
      private static function onDefaultCameraAngleChange() : void
      {
         Parameters.data_.cameraAngle = Parameters.data_.defaultCameraAngle;
         Parameters.save();
      }
      
      private function onContinueClick(param1:MouseEvent) : void
      {
         this.close();
      }
      
      private function onResetToDefaultsClick(param1:MouseEvent) : void
      {
         var _loc2_:BaseOption = null;
         var _loc3_:int = 0;
         while(_loc3_ < this.options_.length)
         {
            _loc2_ = this.options_[_loc3_] as BaseOption;
            if(_loc2_ != null)
            {
               delete Parameters.data_[_loc2_.paramName_];
            }
            _loc3_++;
         }
         Parameters.setDefaults();
         Parameters.save();
         this.refresh();
      }
      
      private function onHomeClick(param1:MouseEvent) : void
      {
         this.close();
         this.gs_.closed.dispatch();
      }
      
      private function onTabClick(param1:MouseEvent) : void
      {
         var _loc2_:OptionsTabTitle = param1.currentTarget as OptionsTabTitle;
         this.setSelected(_loc2_);
      }
      
      private function setSelected(param1:OptionsTabTitle) : void
      {
         if(param1 == this.selected_)
         {
            return;
         }
         if(this.selected_ != null)
         {
            this.selected_.setSelected(false);
         }
         this.selected_ = param1;
         this.selected_.setSelected(true);
         this.removeOptions();
         switch(this.selected_.text_)
         {
            case TextKey.OPTIONS_CONTROLS:
               this.addControlsOptions();
               return;
            case TextKey.OPTIONS_HOTKEYS:
               this.addHotKeysOptions();
               return;
            case TextKey.OPTIONS_CHAT:
               this.addChatOptions();
               return;
            case TextKey.OPTIONS_GRAPHICS:
               this.addGraphicsOptions();
               return;
            case TextKey.OPTIONS_SOUND:
               this.addSoundOptions();
               return;
            case "Hacks":
               this.addHackOptions();
               return;
            case TextKey.OPTIONS_EXTRA:
               this.addExperimentalOptions();
               return;
            default:
               return;
         }
      }
      
      private function onAddedToStage(param1:Event) : void
      {
         this.continueButton_.x = stage.stageWidth / 2;
         this.continueButton_.y = Y_POSITION;
         this.resetToDefaultsButton_.x = 20;
         this.resetToDefaultsButton_.y = Y_POSITION;
         this.homeButton_.x = stage.stageWidth - 20;
         this.homeButton_.y = Y_POSITION;
         this.setSelected(this.tabs_[0]);
         stage.addEventListener(KeyboardEvent.KEY_DOWN,this.onKeyDown,false,1);
         stage.addEventListener(KeyboardEvent.KEY_UP,this.onKeyUp,false,1);
      }
      
      private function onRemovedFromStage(param1:Event) : void
      {
         stage.removeEventListener(KeyboardEvent.KEY_DOWN,this.onKeyDown,false);
         stage.removeEventListener(KeyboardEvent.KEY_UP,this.onKeyUp,false);
      }
      
      private function onKeyDown(param1:KeyboardEvent) : void
      {
         if(param1.keyCode == Parameters.data_.options)
         {
            this.close();
         }
         param1.stopImmediatePropagation();
      }
      
      private function close() : void
      {
         stage.focus = null;
         parent.removeChild(this);
      }
      
      private function onKeyUp(param1:KeyboardEvent) : void
      {
         param1.stopImmediatePropagation();
      }
      
      private function removeOptions() : void
      {
         var _loc1_:Sprite = null;
         for each(_loc1_ in this.options_)
         {
            removeChild(_loc1_);
         }
         this.options_.length = 0;
      }
      
      private function addControlsOptions() : void
      {
         this.addOptionAndPosition(new KeyMapper("moveUp",TextKey.OPTIONS_MOVE_UP,TextKey.OPTIONS_MOVE_UP_DESC));
         this.addOptionAndPosition(new KeyMapper("moveLeft",TextKey.OPTIONS_MOVE_LEFT,TextKey.OPTIONS_MOVE_LEFT_DESC));
         this.addOptionAndPosition(new KeyMapper("moveDown",TextKey.OPTIONS_MOVE_DOWN,TextKey.OPTIONS_MOVE_DOWN_DESC));
         this.addOptionAndPosition(new KeyMapper("moveRight",TextKey.OPTIONS_MOVE_RIGHT,TextKey.OPTIONS_MOVE_RIGHT_DESC));
         this.addOptionAndPosition(this.makeAllowCameraRotation());
         this.addOptionAndPosition(this.makeAllowMiniMapRotation());
         this.addOptionAndPosition(new KeyMapper("rotateLeft",TextKey.OPTIONS_ROTATE_LEFT,TextKey.OPTIONS_ROTATE_LEFT_DESC,!Parameters.data_.allowRotation));
         this.addOptionAndPosition(new KeyMapper("rotateRight",TextKey.OPTIONS_ROTATE_RIGHT,TextKey.OPTIONS_ROTATE_RIGHT_DESC,!Parameters.data_.allowRotation));
         this.addOptionAndPosition(new KeyMapper("useSpecial",TextKey.OPTIONS_USE_SPECIAL_ABILITY,TextKey.OPTIONS_USE_SPECIAL_ABILITY_DESC));
         this.addOptionAndPosition(new KeyMapper("autofireToggle",TextKey.OPTIONS_AUTOFIRE_TOGGLE,TextKey.OPTIONS_AUTOFIRE_TOGGLE_DESC));
         this.addOptionAndPosition(new KeyMapper("toggleHPBar",TextKey.OPTIONS_TOGGLE_HPBAR,TextKey.OPTIONS_TOGGLE_HPBAR_DESC));
         this.addOptionAndPosition(new KeyMapper("resetToDefaultCameraAngle",TextKey.OPTIONS_RESET_CAMERA,TextKey.OPTIONS_RESET_CAMERA_DESC));
         this.addOptionAndPosition(new KeyMapper("togglePerformanceStats",TextKey.OPTIONS_TOGGLE_PERFORMANCE_STATS,TextKey.OPTIONS_TOGGLE_PERFORMANCE_STATS_DESC));
         this.addOptionAndPosition(new KeyMapper("toggleCentering",TextKey.OPTIONS_TOGGLE_CENTERING,TextKey.OPTIONS_TOGGLE_CENTERING_DESC));
         this.addOptionAndPosition(new KeyMapper("interact",TextKey.OPTIONS_INTERACT_OR_BUY,TextKey.OPTIONS_INTERACT_OR_BUY_DESC));
         this.addOptionAndPosition(makePotionBuy());
      }
      
      private function makeAllowCameraRotation() : ChoiceOption
      {
         return new ChoiceOption("allowRotation",makeOnOffLabels(),[true,false],TextKey.OPTIONS_ALLOW_ROTATION,TextKey.OPTIONS_ALLOW_ROTATION_DESC,this.onAllowRotationChange);
      }
      
      private function makeAllowMiniMapRotation() : ChoiceOption
      {
         return new ChoiceOption("allowMiniMapRotation",makeOnOffLabels(),[true,false],TextKey.OPTIONS_ALLOW_MINIMAP_ROTATION,TextKey.OPTIONS_ALLOW_MINIMAP_ROTATION_DESC,null);
      }
      
      private function onAllowRotationChange() : void
      {
         var _loc1_:KeyMapper = null;
         var _loc2_:int = 0;
         while(_loc2_ < this.options_.length)
         {
            _loc1_ = this.options_[_loc2_] as KeyMapper;
            if(_loc1_ != null)
            {
               if(_loc1_.paramName_ == "rotateLeft" || _loc1_.paramName_ == "rotateRight")
               {
                  _loc1_.setDisabled(!Parameters.data_.allowRotation);
               }
            }
            _loc2_++;
         }
      }
      
      private function addHotKeysOptions() : void
      {
         this.addOptionAndPosition(new KeyMapper("useHealthPotion",TextKey.OPTIONS_USE_BUY_HEALTH,TextKey.OPTIONS_USE_BUY_HEALTH_DESC));
         this.addOptionAndPosition(new KeyMapper("useMagicPotion",TextKey.OPTIONS_USE_BUY_MAGIC,TextKey.OPTIONS_USE_BUY_MAGIC_DESC));
         this.addInventoryOptions();
         this.addOptionAndPosition(new KeyMapper("miniMapZoomIn",TextKey.OPTIONS_MINI_MAP_ZOOM_IN,TextKey.OPTIONS_MINI_MAP_ZOOM_IN_DESC));
         this.addOptionAndPosition(new KeyMapper("miniMapZoomOut",TextKey.OPTIONS_MINI_MAP_ZOOM_OUT,TextKey.OPTIONS_MINI_MAP_ZOOM_OUT_DESC));
         this.addOptionAndPosition(new KeyMapper("escapeToNexus",TextKey.OPTIONS_ESCAPE_TO_NEXUS,TextKey.OPTIONS_ESCAPE_TO_NEXUS_DESC));
         this.addOptionAndPosition(new KeyMapper("options",TextKey.OPTIONS_SHOW_OPTIONS,TextKey.OPTIONS_SHOW_OPTIONS_DESC));
         this.addOptionAndPosition(new KeyMapper("switchTabs",TextKey.OPTIONS_SWITCH_TABS,TextKey.OPTIONS_SWITCH_TABS_DESC));
         this.addOptionsChoiceOption();
      }
      
      public function addOptionsChoiceOption() : void
      {
         var _loc1_:String = Capabilities.os.split(" ")[0] == "Mac" ? "Command" : "Ctrl";
         var _loc2_:ChoiceOption = new ChoiceOption("inventorySwap",makeOnOffLabels(),[true,false],TextKey.OPTIONS_SWITCH_ITEM_IN_BACKPACK,"",null);
         _loc2_.setTooltipText(new LineBuilder().setParams(TextKey.OPTIONS_SWITCH_ITEM_IN_BACKPACK_DESC,{"key":_loc1_}));
         this.addOptionAndPosition(_loc2_);
      }
      
      public function addInventoryOptions() : void
      {
         var _loc1_:KeyMapper = null;
         var _loc2_:int = 1;
         while(_loc2_ <= 8)
         {
            _loc1_ = new KeyMapper("useInvSlot" + _loc2_,"","");
            _loc1_.setDescription(new LineBuilder().setParams(TextKey.OPTIONS_INVENTORY_SLOT_N,{"n":_loc2_}));
            _loc1_.setTooltipText(new LineBuilder().setParams(TextKey.OPTIONS_INVENTORY_SLOT_N_DESC,{"n":_loc2_}));
            this.addOptionAndPosition(_loc1_);
            _loc2_++;
         }
      }
      
      private function addChatOptions() : void
      {
         this.addOptionAndPosition(new KeyMapper(CHAT,TextKey.OPTIONS_ACTIVATE_CHAT,TextKey.OPTIONS_ACTIVATE_CHAT_DESC));
         this.addOptionAndPosition(new KeyMapper(CHAT_COMMAND,TextKey.OPTIONS_START_CHAT,TextKey.OPTIONS_START_CHAT_DESC));
         this.addOptionAndPosition(new KeyMapper(TELL,TextKey.OPTIONS_BEGIN_TELL,TextKey.OPTIONS_BEGIN_TELL_DESC));
         this.addOptionAndPosition(new KeyMapper(GUILD_CHAT,TextKey.OPTIONS_BEGIN_GUILD_CHAT,TextKey.OPTIONS_BEGIN_GUILD_CHAT_DESC));
         this.addOptionAndPosition(new KeyMapper(SCROLL_CHAT_UP,TextKey.OPTIONS_SCROLL_CHAT_UP,TextKey.OPTIONS_SCROLL_CHAT_UP_DESC));
         this.addOptionAndPosition(new KeyMapper(SCROLL_CHAT_DOWN,TextKey.OPTIONS_SCROLL_CHAT_DOWN,TextKey.OPTIONS_SCROLL_CHAT_DOWN_DESC));
         this.addOptionAndPosition(new ChoiceOption("forceChatQuality",makeOnOffLabels(),[true,false],TextKey.OPTIONS_FORCE_CHAT_QUALITY,TextKey.OPTIONS_FORCE_CHAT_QUALITY_DESC,null));
         this.addOptionAndPosition(new ChoiceOption("hidePlayerChat",makeOnOffLabels(),[true,false],TextKey.OPTIONS_HIDE_PLAYER_CHAT,TextKey.OPTIONS_HIDE_PLAYER_CHAT_DESC,null));
         this.addOptionAndPosition(new ChoiceOption("chatStarRequirement",makeStarSelectLabels(),[0,1,2,3,5,10],TextKey.OPTIONS_STAR_REQ,TextKey.OPTIONS_CHAT_STAR_REQ_DESC,null));
         this.addOptionAndPosition(new ChoiceOption("chatAll",makeOnOffLabels(),[true,false],TextKey.OPTIONS_CHAT_ALL,TextKey.OPTIONS_CHAT_ALL_DESC,this.onAllChatEnabled));
         this.addOptionAndPosition(new ChoiceOption("chatWhisper",makeOnOffLabels(),[true,false],TextKey.OPTIONS_CHAT_WHISPER,TextKey.OPTIONS_CHAT_WHISPER_DESC,this.onAllChatDisabled));
         this.addOptionAndPosition(new ChoiceOption("chatGuild",makeOnOffLabels(),[true,false],TextKey.OPTIONS_CHAT_GUILD,TextKey.OPTIONS_CHAT_GUILD_DESC,this.onAllChatDisabled));
         this.addOptionAndPosition(new ChoiceOption("chatTrade",makeOnOffLabels(),[true,false],TextKey.OPTIONS_CHAT_TRADE,TextKey.OPTIONS_CHAT_TRADE_DESC,null));
      }
      
      private function onAllChatDisabled() : void
      {
         var _loc1_:ChoiceOption = null;
         Parameters.data_.chatAll = false;
         var _loc2_:int = 0;
         for(; _loc2_ < this.options_.length; _loc2_++)
         {
            _loc1_ = this.options_[_loc2_] as ChoiceOption;
            if(_loc1_ == null)
            {
               continue;
            }
            switch(_loc1_.paramName_)
            {
               case "chatAll":
                  _loc1_.refreshNoCallback();
                  break;
            }
         }
      }
      
      private function onAllChatEnabled() : void
      {
         var _loc1_:ChoiceOption = null;
         Parameters.data_.hidePlayerChat = false;
         Parameters.data_.chatWhisper = true;
         Parameters.data_.chatGuild = true;
         var _loc2_:int = 0;
         while(_loc2_ < this.options_.length)
         {
            _loc1_ = this.options_[_loc2_] as ChoiceOption;
            if(_loc1_ != null)
            {
               switch(_loc1_.paramName_)
               {
                  case "hidePlayerChat":
                  case "chatWhisper":
                  case "chatGuild":
               }
            }
            _loc2_++;
         }
      }
      
      private function addHackOptions() : void
      {
         this.addOptionAndPosition(new KeyMapper("ToggleGod","Toggle Godmode","Key used for toggling godmode"));
         this.addOptionAndPosition(new ChoiceOption("NoDebuff",makeOnOffLabels(),[true,false],"No Debuff","Disables some  debuffs",null));
         this.addOptionAndPosition(new KeyMapper("ToggleSS","Toggle Stacked","Key used for toggling stacked shots"));
         this.addOptionAndPosition(new ChoiceOption("NoSink",makeOnOffLabels(),[true,false],"No Sink","Disables slowness for sink tiles",null));
         this.addOptionAndPosition(new KeyMapper("ToggleMsm","Msm (Move Speed Multiplier)","Key used for toggling msm"));
         this.addOptionAndPosition(new ChoiceOption("NoCoolDown",makeOnOffLabels(),[true,false],"No Cooldowns","Disables cooldowns for abilities",null));
         this.addOptionAndPosition(new KeyMapper("ToggleInfo","Toggle Info","Key used for toggling the hack info display"));
         this.addOptionAndPosition(new ChoiceOption("ProjNoClip",makeOnOffLabels(),[true,false],"Projectile No-clip","\'Whats a wall\' - Projectile",null));
         this.addOptionAndPosition(new KeyMapper("ToggleRange","Toggle Range Boost","Key used for toggling extra range"));
      }
      
      private function addExperimentalOptions() : void
      {
         this.addOptionAndPosition(new ChoiceOption("disableEnemyParticles",makeOnOffLabels(),[true,false],"Disable enemy particles","Disable particles when hit enemy and when enemy is dying.",null));
         this.addOptionAndPosition(new ChoiceOption("disableAllyParticles",makeOnOffLabels(),[true,false],"Disable ally particles","Disable particles produces by shooting ally.",null));
         this.addOptionAndPosition(new ChoiceOption("disablePlayersHitParticles",makeOnOffLabels(),[true,false],"Disable players hit particles","Disable particles when player or ally is hit.",null));
         this.addOptionAndPosition(new ChoiceOption("hidePlayers",makeOnOffLabels(),[true,false],"Disable Players","Disable particles when player or ally is hit.",null));
      }
      
      private function addGraphicsOptions() : void
      {
         this.addOptionAndPosition(new ChoiceOption("defaultCameraAngle",makeDegreeOptions(),[7 * Math.PI / 4,0],TextKey.OPTIONS_DEFAULT_CAMERA_ANGLE,TextKey.OPTIONS_DEFAULT_CAMERA_ANGLE_DESC,onDefaultCameraAngleChange));
         this.addOptionAndPosition(new ChoiceOption("centerOnPlayer",makeOnOffLabels(),[true,false],TextKey.OPTIONS_CENTER_ON_PLAYER,TextKey.OPTIONS_CENTER_ON_PLAYER_DESC,null));
         this.addOptionAndPosition(new ChoiceOption("showQuestPortraits",makeOnOffLabels(),[true,false],TextKey.OPTIONS_SHOW_QUEST_PORTRAITS,TextKey.OPTIONS_SHOW_QUEST_PORTRAITS_DESC,this.onShowQuestPortraitsChange));
         this.addOptionAndPosition(new ChoiceOption("drawShadows",makeOnOffLabels(),[true,false],TextKey.OPTIONS_DRAW_SHADOWS,TextKey.OPTIONS_DRAW_SHADOWS_DESC,null));
         this.addOptionAndPosition(new ChoiceOption("textBubbles",makeOnOffLabels(),[true,false],TextKey.OPTIONS_DRAW_TEXT_BUBBLES,TextKey.OPTIONS_DRAW_TEXT_BUBBLES_DESC,null));
         this.addOptionAndPosition(new ChoiceOption("showTradePopup",makeOnOffLabels(),[true,false],TextKey.OPTIONS_SHOW_TRADE_REQUEST_PANEL,TextKey.OPTIONS_SHOW_TRADE_REQUEST_PANEL_DESC,null));
         this.addOptionAndPosition(new ChoiceOption("showGuildInvitePopup",makeOnOffLabels(),[true,false],TextKey.OPTIONS_SHOW_GUILD_INVITE_PANEL,TextKey.OPTIONS_SHOW_GUILD_INVITE_PANEL_DESC,null));
         this.addOptionAndPosition(new ChoiceOption("cursorSelect",makeCursorSelectLabels(),[MouseCursor.AUTO,"0","1","2","3","4","5","6","7","8","9"],"Custom Cursor","Click here to change the mouse cursor. May help with aiming.",refreshCursor));
         this.addOptionAndPosition(new ChoiceOption("toggleBarText",makeOnOffLabels(),[true,false],TextKey.OPTIONS_TOGGLE_BARTEXT,TextKey.OPTIONS_TOGGLE_BARTEXT_DESC,onBarTextToggle));
         this.addOptionAndPosition(new ChoiceOption("particleEffect",makeHighLowLabels(),[true,false],TextKey.OPTIONS_TOGGLE_PARTICLE_EFFECT,TextKey.OPTIONS_TOGGLE_PARTICLE_EFFECT_DESC,null));
      }
      
      private function onShowQuestPortraitsChange() : void
      {
         if(this.gs_ != null && this.gs_.map != null && this.gs_.map.partyOverlay_ != null && this.gs_.map.partyOverlay_.questArrow_ != null)
         {
            this.gs_.map.partyOverlay_.questArrow_.refreshToolTip();
         }
      }
      
      private function addSoundOptions() : void
      {
         this.addOptionAndPosition(new ChoiceOption("playMusic",makeOnOffLabels(),[true,false],TextKey.OPTIONS_PLAY_MUSIC,TextKey.OPTIONS_PLAY_MUSIC_DESC,this.onPlayMusicChange));
         this.addOptionAndPosition(new SliderOption("musicVolume",this.onMusicVolumeChange),-120,15);
         this.addOptionAndPosition(new ChoiceOption("playSFX",makeOnOffLabels(),[true,false],TextKey.OPTIONS_PLAY_SOUND_EFFECTS,TextKey.OPTIONS_PLAY_SOUND_EFFECTS_DESC,this.onPlaySoundEffectsChange));
         this.addOptionAndPosition(new SliderOption("SFXVolume",this.onSoundEffectsVolumeChange),-120,34);
         this.addOptionAndPosition(new ChoiceOption("playPewPew",makeOnOffLabels(),[true,false],TextKey.OPTIONS_PLAY_WEAPON_SOUNDS,TextKey.OPTIONS_PLAY_WEAPON_SOUNDS_DESC,null));
      }
      
      private function onPlayMusicChange() : void
      {
         Music.setPlayMusic(Parameters.data_.playMusic);
         if(Parameters.data_.playMusic)
         {
            Music.setMusicVolume(1);
         }
         else
         {
            Music.setMusicVolume(0);
         }
         this.refresh();
      }
      
      private function onPlaySoundEffectsChange() : void
      {
         SFX.setPlaySFX(Parameters.data_.playSFX);
         if(Parameters.data_.playSFX || Parameters.data_.playPewPew)
         {
            SFX.setSFXVolume(1);
         }
         else
         {
            SFX.setSFXVolume(0);
         }
         this.refresh();
      }
      
      private function onMusicVolumeChange(param1:Number) : void
      {
         Music.setMusicVolume(param1);
      }
      
      private function onSoundEffectsVolumeChange(param1:Number) : void
      {
         SFX.setSFXVolume(param1);
      }
      
      private function addOptionAndPosition(param1:Option, param2:Number = 0, param3:Number = 0) : void
      {
         var positionOption:Function = null;
         var option:Option = param1;
         var offsetX:Number = param2;
         var offsetY:Number = param3;
         positionOption = function():void
         {
            option.x = (options_.length % 2 == 0 ? 20 : 415) + offsetX;
            option.y = int(options_.length / 2) * 44 + 122 + offsetY;
         };
         option.textChanged.addOnce(positionOption);
         this.addOption(option);
      }
      
      private function addOption(param1:Option) : void
      {
         addChild(param1);
         param1.addEventListener(Event.CHANGE,this.onChange);
         this.options_.push(param1);
      }
      
      private function onChange(param1:Event) : void
      {
         this.refresh();
      }
      
      private function refresh() : void
      {
         var _loc1_:BaseOption = null;
         var _loc2_:int = 0;
         while(_loc2_ < this.options_.length)
         {
            _loc1_ = this.options_[_loc2_] as BaseOption;
            if(_loc1_ != null)
            {
               _loc1_.refresh();
            }
            _loc2_++;
         }
      }
   }
}
