package com.company.assembleegameclient.objects
{
   import com.company.assembleegameclient.map.Camera;
   import com.company.assembleegameclient.map.Square;
   import com.company.assembleegameclient.map.mapoverlay.CharacterStatusText;
   import com.company.assembleegameclient.objects.particles.HealingEffect;
   import com.company.assembleegameclient.objects.particles.LevelUpEffect;
   import com.company.assembleegameclient.parameters.Parameters;
   import com.company.assembleegameclient.sound.SoundEffectLibrary;
   import com.company.assembleegameclient.tutorial.Tutorial;
   import com.company.assembleegameclient.tutorial.doneAction;
   import com.company.assembleegameclient.util.AnimatedChar;
   import com.company.assembleegameclient.util.ConditionEffect;
   import com.company.assembleegameclient.util.FameUtil;
   import com.company.assembleegameclient.util.FreeList;
   import com.company.assembleegameclient.util.MaskedImage;
   import com.company.assembleegameclient.util.TextureRedrawer;
   import com.company.assembleegameclient.util.redrawers.GlowRedrawer;
   import com.company.util.CachingColorTransformer;
   import com.company.util.ConversionUtil;
   import com.company.util.GraphicsUtil;
   import com.company.util.IntPoint;
   import com.company.util.MoreColorUtil;
   import com.company.util.PointUtil;
   import com.company.util.Trig;
   import flash.display.BitmapData;
   import flash.display.GraphicsPath;
   import flash.display.GraphicsSolidFill;
   import flash.display.IGraphicsData;
   import flash.geom.ColorTransform;
   import flash.geom.Matrix;
   import flash.geom.Point;
   import flash.geom.Vector3D;
   import flash.utils.Dictionary;
   import flash.utils.getTimer;
   import kabam.rotmg.assets.services.CharacterFactory;
   import kabam.rotmg.chat.model.ChatMessage;
   import kabam.rotmg.constants.ActivationType;
   import kabam.rotmg.constants.GeneralConstants;
   import kabam.rotmg.constants.UseType;
   import kabam.rotmg.core.StaticInjectorContext;
   import kabam.rotmg.game.model.PotionInventoryModel;
   import kabam.rotmg.game.signals.AddTextLineSignal;
   import kabam.rotmg.game.view.components.QueuedStatusText;
   import kabam.rotmg.stage3D.GraphicsFillExtra;
   import kabam.rotmg.text.model.TextKey;
   import kabam.rotmg.text.view.BitmapTextFactory;
   import kabam.rotmg.text.view.stringBuilder.LineBuilder;
   import kabam.rotmg.text.view.stringBuilder.StaticStringBuilder;
   import kabam.rotmg.text.view.stringBuilder.StringBuilder;
   import kabam.rotmg.ui.model.TabStripModel;
   import org.swiftsuspenders.Injector;
   
   public class Player extends Character
   {
      
      public static const MS_BETWEEN_TELEPORT:int = 10000;
      
      private static const MOVE_THRESHOLD:Number = 0.4;
      
      public static var isAdmin:Boolean = false;
      
      private static const NEARBY:Vector.<Point> = new <Point>[new Point(0,0),new Point(1,0),new Point(0,1),new Point(1,1)];
      
      private static var newP:Point = new Point();
      
      private static const RANK_OFFSET_MATRIX:Matrix = new Matrix(1,0,0,1,2,2);
      
      private static const NAME_OFFSET_MATRIX:Matrix = new Matrix(1,0,0,1,20,1);
      
      private static const MIN_MOVE_SPEED:Number = 0.004;
      
      private static const MAX_MOVE_SPEED:Number = 0.0096;
      
      private static const MIN_ATTACK_FREQ:Number = 0.0015;
      
      private static const MAX_ATTACK_FREQ:Number = 0.008;
      
      private static const MIN_ATTACK_MULT:Number = 0.5;
      
      private static const MAX_ATTACK_MULT:Number = 2;
       
      
      public var xpTimer:int;
      
      public var skinId:int;
      
      public var skin:AnimatedChar;
      
      public var isShooting:Boolean;
      
      public var accountId_:String = "";
      
      public var credits_:int = 0;
      
      public var tokens_:int = 0;
      
      public var numStars_:int = 0;
      
      public var fame_:int = 0;
      
      public var nameChosen_:Boolean = false;
      
      public var currFame_:int = 0;
      
      public var nextClassQuestFame_:int = -1;
      
      public var legendaryRank_:int = -1;
      
      public var guildName_:String = null;
      
      public var guildRank_:int = -1;
      
      public var isFellowGuild_:Boolean = false;
      
      public var breath_:int = -1;
      
      public var maxMP_:int = 200;
      
      public var mp_:Number = 0;
      
      public var nextLevelExp_:int = 1000;
      
      public var exp_:int = 0;
      
      public var attack_:int = 0;
      
      public var speed_:int = 0;
      
      public var dexterity_:int = 0;
      
      public var vitality_:int = 0;
      
      public var wisdom_:int = 0;
      
      public var maxHPBoost_:int = 0;
      
      public var maxMPBoost_:int = 0;
      
      public var attackBoost_:int = 0;
      
      public var defenseBoost_:int = 0;
      
      public var speedBoost_:int = 0;
      
      public var vitalityBoost_:int = 0;
      
      public var wisdomBoost_:int = 0;
      
      public var dexterityBoost_:int = 0;
      
      public var xpBoost_:int = 0;
      
      public var healthPotionCount_:int = 0;
      
      public var magicPotionCount_:int = 0;
      
      public var attackMax_:int = 0;
      
      public var defenseMax_:int = 0;
      
      public var speedMax_:int = 0;
      
      public var dexterityMax_:int = 0;
      
      public var vitalityMax_:int = 0;
      
      public var wisdomMax_:int = 0;
      
      public var maxHPMax_:int = 0;
      
      public var maxMPMax_:int = 0;
      
      public var hasBackpack_:Boolean = false;
      
      public var starred_:Boolean = false;
      
      public var ignored_:Boolean = false;
      
      public var distSqFromThisPlayer_:Number = 0;
      
      protected var rotate_:Number = 0;
      
      protected var relMoveVec_:Point = null;
      
      protected var moveMultiplier_:Number = 1;
      
      public var attackPeriod_:int = 0;
      
      public var nextAltAttack_:int = 0;
      
      public var nextTeleportAt_:int = 0;
      
      public var dropBoost:int = 0;
      
      public var tierBoost:int = 0;
      
      protected var healingEffect_:HealingEffect = null;
      
      protected var nearestMerchant_:Merchant = null;
      
      public var isDefaultAnimatedChar:Boolean = true;
      
      public var projectileIdSetOverrideNew:String = "";
      
      public var projectileIdSetOverrideOld:String = "";
      
      private var addTextLine:AddTextLineSignal;
      
      private var factory:CharacterFactory;
      
      private var ip_:IntPoint;
      
      private var breathBackFill_:GraphicsSolidFill = null;
      
      private var breathBackPath_:GraphicsPath = null;
      
      private var breathFill_:GraphicsSolidFill = null;
      
      private var breathPath_:GraphicsPath = null;
      
      public function Player(param1:XML)
      {
         this.ip_ = new IntPoint();
         var _loc2_:Injector = StaticInjectorContext.getInjector();
         this.addTextLine = _loc2_.getInstance(AddTextLineSignal);
         this.factory = _loc2_.getInstance(CharacterFactory);
         super(param1);
         this.attackMax_ = int(param1.Attack.@max);
         this.defenseMax_ = int(param1.Defense.@max);
         this.speedMax_ = int(param1.Speed.@max);
         this.dexterityMax_ = int(param1.Dexterity.@max);
         this.vitalityMax_ = int(param1.HpRegen.@max);
         this.wisdomMax_ = int(param1.MpRegen.@max);
         this.maxHPMax_ = int(param1.MaxHitPoints.@max);
         this.maxMPMax_ = int(param1.MaxMagicPoints.@max);
         texturingCache_ = new Dictionary();
      }
      
      public static function fromPlayerXML(param1:String, param2:XML) : Player
      {
         var _loc3_:int = int(param2.ObjectType);
         var _loc4_:XML = ObjectLibrary.xmlLibrary_[_loc3_];
         var _loc5_:Player = new Player(_loc4_);
         _loc5_.name_ = param1;
         _loc5_.level_ = int(param2.Level);
         _loc5_.exp_ = int(param2.Exp);
         _loc5_.equipment_ = ConversionUtil.toIntVector(param2.Equipment);
         _loc5_.maxHP_ = int(param2.MaxHitPoints);
         _loc5_.hp_ = int(param2.HitPoints);
         _loc5_.maxMP_ = int(param2.MaxMagicPoints);
         _loc5_.mp_ = int(param2.MagicPoints);
         _loc5_.attack_ = int(param2.Attack);
         _loc5_.defense_ = int(param2.Defense);
         _loc5_.speed_ = int(param2.Speed);
         _loc5_.dexterity_ = int(param2.Dexterity);
         _loc5_.vitality_ = int(param2.HpRegen);
         _loc5_.wisdom_ = int(param2.MpRegen);
         _loc5_.tex1Id_ = int(param2.Tex1);
         _loc5_.tex2Id_ = int(param2.Tex2);
         return _loc5_;
      }
      
      public function setRelativeMovement(param1:Number, param2:Number, param3:Number) : void
      {
         var _loc4_:Number = NaN;
         if(this.relMoveVec_ == null)
         {
            this.relMoveVec_ = new Point();
         }
         this.rotate_ = param1;
         this.relMoveVec_.x = param2;
         this.relMoveVec_.y = param3;
         if(isConfused())
         {
            _loc4_ = this.relMoveVec_.x;
            this.relMoveVec_.x = -this.relMoveVec_.y;
            this.relMoveVec_.y = -_loc4_;
            this.rotate_ = -this.rotate_;
         }
      }
      
      public function setCredits(param1:int) : void
      {
         this.credits_ = param1;
      }
      
      public function setTokens(param1:int) : void
      {
         this.tokens_ = param1;
      }
      
      public function setGuildName(param1:String) : void
      {
         var _loc2_:GameObject = null;
         var _loc3_:Player = null;
         var _loc4_:Boolean = false;
         this.guildName_ = param1;
         var _loc5_:Player = map_.player_;
         if(_loc5_ == this)
         {
            for each(_loc2_ in map_.goDict_)
            {
               _loc3_ = _loc2_ as Player;
               if(_loc3_ != null && _loc3_ != this)
               {
                  _loc3_.setGuildName(_loc3_.guildName_);
               }
            }
         }
         else
         {
            _loc4_ = _loc5_ != null && _loc5_.guildName_ != null && _loc5_.guildName_ != "" && _loc5_.guildName_ == this.guildName_;
            if(_loc4_ != this.isFellowGuild_)
            {
               this.isFellowGuild_ = _loc4_;
               nameBitmapData_ = null;
            }
         }
      }
      
      public function isTeleportEligible(param1:Player) : Boolean
      {
         return !(param1.isPaused() || param1.isInvisible());
      }
      
      public function msUtilTeleport() : int
      {
         var _loc1_:int = getTimer();
         return Math.max(0,this.nextTeleportAt_ - _loc1_);
      }
      
      public function teleportTo(param1:Player) : Boolean
      {
         if(isPaused())
         {
            this.addTextLine.dispatch(this.makeErrorMessage(TextKey.PLAYER_NOTELEPORTWHILEPAUSED));
            return false;
         }
         var _loc2_:int = this.msUtilTeleport();
         if(_loc2_ > 0)
         {
            this.addTextLine.dispatch(this.makeErrorMessage(TextKey.PLAYER_TELEPORT_COOLDOWN,{"seconds":int(_loc2_ / 1000 + 1)}));
            return false;
         }
         if(!this.isTeleportEligible(param1))
         {
            if(param1.isInvisible())
            {
               this.addTextLine.dispatch(this.makeErrorMessage(TextKey.TELEPORT_INVISIBLE_PLAYER,{"player":param1.name_}));
            }
            else
            {
               this.addTextLine.dispatch(this.makeErrorMessage(TextKey.PLAYER_TELEPORT_TO_PLAYER,{"player":param1.name_}));
            }
            return false;
         }
         map_.gs_.gsc_.teleport(param1.objectId_);
         this.nextTeleportAt_ = getTimer() + MS_BETWEEN_TELEPORT;
         return true;
      }
      
      private function makeErrorMessage(param1:String, param2:Object = null) : ChatMessage
      {
         return ChatMessage.make(Parameters.ERROR_CHAT_NAME,param1,-1,-1,"",false,param2);
      }
      
      public function levelUpEffect(param1:String, param2:Boolean = true) : void
      {
         if(param2)
         {
            this.levelUpParticleEffect();
         }
         var _loc3_:QueuedStatusText = new QueuedStatusText(this,new LineBuilder().setParams(param1),65280,2000);
         map_.mapOverlay_.addQueuedText(_loc3_);
      }
      
      public function handleLevelUp(param1:Boolean) : void
      {
         SoundEffectLibrary.play("level_up");
         if(param1)
         {
            this.levelUpEffect(TextKey.PLAYER_NEWCLASSUNLOCKED,false);
            this.levelUpEffect(TextKey.PLAYER_LEVELUP);
         }
         else
         {
            this.levelUpEffect(TextKey.PLAYER_LEVELUP);
         }
      }
      
      public function levelUpParticleEffect(param1:uint = 4278255360) : void
      {
         map_.addObj(new LevelUpEffect(this,param1,20),x_,y_);
      }
      
      public function handleExpUp(param1:int) : void
      {
         if(level_ == 20)
         {
            return;
         }
         var _loc2_:CharacterStatusText = new CharacterStatusText(this,65280,1000);
         _loc2_.setStringBuilder(new LineBuilder().setParams(TextKey.PLAYER_EXP,{"exp":param1}));
         map_.mapOverlay_.addStatusText(_loc2_);
      }
      
      private function getNearbyMerchant() : Merchant
      {
         var _loc1_:Point = null;
         var _loc2_:Merchant = null;
         var _loc3_:int = x_ - int(x_) > 0.5 ? 1 : -1;
         var _loc4_:int = y_ - int(y_) > 0.5 ? 1 : -1;
         for each(_loc1_ in NEARBY)
         {
            this.ip_.x_ = x_ + _loc3_ * _loc1_.x;
            this.ip_.y_ = y_ + _loc4_ * _loc1_.y;
            _loc2_ = map_.merchLookup_[this.ip_];
            if(_loc2_ != null)
            {
               return PointUtil.distanceSquaredXY(_loc2_.x_,_loc2_.y_,x_,y_) < 1 ? _loc2_ : null;
            }
         }
         return null;
      }
      
      public function walkTo(param1:Number, param2:Number) : Boolean
      {
         this.modifyMove(param1,param2,newP);
         return this.moveTo(newP.x,newP.y);
      }
      
      override public function moveTo(param1:Number, param2:Number) : Boolean
      {
         var _loc3_:Boolean = super.moveTo(param1,param2);
         if(map_.gs_.evalIsNotInCombatMapArea())
         {
            this.nearestMerchant_ = this.getNearbyMerchant();
         }
         return _loc3_;
      }
      
      public function modifyMove(param1:Number, param2:Number, param3:Point) : void
      {
         var _loc8_:Boolean = false;
         if(isParalyzed() || isPetrified())
         {
            param3.x = x_;
            param3.y = y_;
            return;
         }
         var _loc4_:Number = param1 - x_;
         var _loc5_:Number = param2 - y_;
         if(_loc4_ < MOVE_THRESHOLD && _loc4_ > -MOVE_THRESHOLD && _loc5_ < MOVE_THRESHOLD && _loc5_ > -MOVE_THRESHOLD)
         {
            this.modifyStep(param1,param2,param3);
            return;
         }
         var _loc6_:Number = MOVE_THRESHOLD / Math.max(Math.abs(_loc4_),Math.abs(_loc5_));
         var _loc7_:Number = 0;
         param3.x = x_;
         param3.y = y_;
         while(!_loc8_)
         {
            if(_loc7_ + _loc6_ >= 1)
            {
               _loc6_ = 1 - _loc7_;
               _loc8_ = true;
            }
            this.modifyStep(param3.x + _loc4_ * _loc6_,param3.y + _loc5_ * _loc6_,param3);
            _loc7_ += _loc6_;
         }
      }
      
      public function modifyStep(param1:Number, param2:Number, param3:Point) : void
      {
         var _loc4_:Number = NaN;
         var _loc5_:Number = NaN;
         var _loc6_:Boolean = x_ % 0.5 == 0 && param1 != x_ || int(x_ / 0.5) != int(param1 / 0.5);
         var _loc7_:Boolean = y_ % 0.5 == 0 && param2 != y_ || int(y_ / 0.5) != int(param2 / 0.5);
         if(!_loc6_ && !_loc7_ || this.isValidPosition(param1,param2))
         {
            param3.x = param1;
            param3.y = param2;
            return;
         }
         if(_loc6_)
         {
            _loc4_ = param1 > x_ ? Number(int(param1 * 2) / 2) : Number(int(x_ * 2) / 2);
            if(int(_loc4_) > int(x_))
            {
               _loc4_ -= 0.01;
            }
         }
         if(_loc7_)
         {
            _loc5_ = param2 > y_ ? Number(int(param2 * 2) / 2) : Number(int(y_ * 2) / 2);
            if(int(_loc5_) > int(y_))
            {
               _loc5_ -= 0.01;
            }
         }
         if(!_loc6_)
         {
            param3.x = param1;
            param3.y = _loc5_;
            if(square_ != null && square_.props_.slideAmount_ != 0)
            {
               this.resetMoveVector(false);
            }
            return;
         }
         if(!_loc7_)
         {
            param3.x = _loc4_;
            param3.y = param2;
            if(square_ != null && square_.props_.slideAmount_ != 0)
            {
               this.resetMoveVector(true);
            }
            return;
         }
         var _loc8_:Number = param1 > x_ ? Number(param1 - _loc4_) : Number(_loc4_ - param1);
         var _loc9_:Number = param2 > y_ ? Number(param2 - _loc5_) : Number(_loc5_ - param2);
         if(_loc8_ > _loc9_)
         {
            if(this.isValidPosition(param1,_loc5_))
            {
               param3.x = param1;
               param3.y = _loc5_;
               return;
            }
            if(this.isValidPosition(_loc4_,param2))
            {
               param3.x = _loc4_;
               param3.y = param2;
               return;
            }
         }
         else
         {
            if(this.isValidPosition(_loc4_,param2))
            {
               param3.x = _loc4_;
               param3.y = param2;
               return;
            }
            if(this.isValidPosition(param1,_loc5_))
            {
               param3.x = param1;
               param3.y = _loc5_;
               return;
            }
         }
         param3.x = _loc4_;
         param3.y = _loc5_;
      }
      
      private function resetMoveVector(param1:Boolean) : void
      {
         moveVec_.scaleBy(-0.5);
         if(param1)
         {
            moveVec_.y *= -1;
         }
         else
         {
            moveVec_.x *= -1;
         }
      }
      
      public function isValidPosition(param1:Number, param2:Number) : Boolean
      {
         var _loc3_:Square = map_.getSquare(param1,param2);
         if(square_ != _loc3_ && (_loc3_ == null || !_loc3_.isWalkable()))
         {
            return false;
         }
         var _loc4_:Number = param1 - int(param1);
         var _loc5_:Number = param2 - int(param2);
         if(_loc4_ < 0.5)
         {
            if(this.isFullOccupy(param1 - 1,param2))
            {
               return false;
            }
            if(_loc5_ < 0.5)
            {
               if(this.isFullOccupy(param1,param2 - 1) || this.isFullOccupy(param1 - 1,param2 - 1))
               {
                  return false;
               }
            }
            else if(_loc5_ > 0.5)
            {
               if(this.isFullOccupy(param1,param2 + 1) || this.isFullOccupy(param1 - 1,param2 + 1))
               {
                  return false;
               }
            }
         }
         else if(_loc4_ > 0.5)
         {
            if(this.isFullOccupy(param1 + 1,param2))
            {
               return false;
            }
            if(_loc5_ < 0.5)
            {
               if(this.isFullOccupy(param1,param2 - 1) || this.isFullOccupy(param1 + 1,param2 - 1))
               {
                  return false;
               }
            }
            else if(_loc5_ > 0.5)
            {
               if(this.isFullOccupy(param1,param2 + 1) || this.isFullOccupy(param1 + 1,param2 + 1))
               {
                  return false;
               }
            }
         }
         else if(_loc5_ < 0.5)
         {
            if(this.isFullOccupy(param1,param2 - 1))
            {
               return false;
            }
         }
         else if(_loc5_ > 0.5)
         {
            if(this.isFullOccupy(param1,param2 + 1))
            {
               return false;
            }
         }
         return true;
      }
      
      public function isFullOccupy(param1:Number, param2:Number) : Boolean
      {
         var _loc3_:Square = map_.lookupSquare(param1,param2);
         return _loc3_ == null || _loc3_.tileType_ == 255 || _loc3_.obj_ != null && _loc3_.obj_.props_.fullOccupy_;
      }
      
      override public function update(param1:int, param2:int) : Boolean
      {
         var _loc3_:Number = NaN;
         var _loc4_:Number = NaN;
         var _loc5_:Number = NaN;
         var _loc6_:Vector3D = null;
         var _loc7_:Number = NaN;
         var _loc8_:int = 0;
         var _loc9_:Vector.<uint> = null;
         if(this.tierBoost && !isPaused())
         {
            this.tierBoost -= param2;
            if(this.tierBoost < 0)
            {
               this.tierBoost = 0;
            }
         }
         if(this.dropBoost && !isPaused())
         {
            this.dropBoost -= param2;
            if(this.dropBoost < 0)
            {
               this.dropBoost = 0;
            }
         }
         if(this.xpTimer && !isPaused())
         {
            this.xpTimer -= param2;
            if(this.xpTimer < 0)
            {
               this.xpTimer = 0;
            }
         }
         if(isHealing() && !isPaused())
         {
            if(this.healingEffect_ == null)
            {
               this.healingEffect_ = new HealingEffect(this);
               map_.addObj(this.healingEffect_,x_,y_);
            }
         }
         else if(this.healingEffect_ != null)
         {
            map_.removeObj(this.healingEffect_.objectId_);
            this.healingEffect_ = null;
         }
         if(map_.player_ == this && isPaused())
         {
            return true;
         }
         if(this.relMoveVec_ != null)
         {
            _loc3_ = Parameters.data_.cameraAngle;
            if(this.rotate_ != 0)
            {
               _loc3_ += param2 * Parameters.PLAYER_ROTATE_SPEED * this.rotate_;
               Parameters.data_.cameraAngle = _loc3_;
            }
            if(this.relMoveVec_.x != 0 || this.relMoveVec_.y != 0)
            {
               _loc4_ = this.getMoveSpeed();
               _loc5_ = Math.atan2(this.relMoveVec_.y,this.relMoveVec_.x);
               if(square_.props_.slideAmount_ > 0)
               {
                  _loc6_ = new Vector3D();
                  _loc6_.x = _loc4_ * Math.cos(_loc3_ + _loc5_);
                  _loc6_.y = _loc4_ * Math.sin(_loc3_ + _loc5_);
                  _loc6_.z = 0;
                  _loc7_ = _loc6_.length;
                  _loc6_.scaleBy(-1 * (square_.props_.slideAmount_ - 1));
                  moveVec_.scaleBy(square_.props_.slideAmount_);
                  if(moveVec_.length < _loc7_)
                  {
                     moveVec_ = moveVec_.add(_loc6_);
                  }
               }
               else
               {
                  moveVec_.x = _loc4_ * Math.cos(_loc3_ + _loc5_);
                  moveVec_.y = _loc4_ * Math.sin(_loc3_ + _loc5_);
               }
            }
            else if(moveVec_.length > 0.00012 && square_.props_.slideAmount_ > 0)
            {
               moveVec_.scaleBy(square_.props_.slideAmount_);
            }
            else
            {
               moveVec_.x = 0;
               moveVec_.y = 0;
            }
            if(square_ != null && square_.props_.push_)
            {
               moveVec_.x -= square_.props_.animate_.dx_ / 1000;
               moveVec_.y -= square_.props_.animate_.dy_ / 1000;
            }
            this.walkTo(x_ + param2 * moveVec_.x,y_ + param2 * moveVec_.y);
         }
         else if(!super.update(param1,param2))
         {
            return false;
         }
         if(map_.player_ == this && square_.props_.maxDamage_ > 0 && square_.lastDamage_ + 500 < param1 && !isInvincible() && (square_.obj_ == null || !square_.obj_.props_.protectFromGroundDamage_))
         {
            _loc8_ = map_.gs_.gsc_.getNextDamage(square_.props_.minDamage_,square_.props_.maxDamage_);
            _loc9_ = new Vector.<uint>();
            _loc9_.push(ConditionEffect.GROUND_DAMAGE);
            damage(-1,_loc8_,_loc9_,hp_ <= _loc8_,null);
            map_.gs_.gsc_.groundDamage(param1,x_,y_);
            square_.lastDamage_ = param1;
         }
         return true;
      }
      
      public function onMove() : void
      {
         if(map_ == null)
         {
            return;
         }
         var _loc1_:Square = map_.getSquare(x_,y_);
         if(_loc1_.props_.sinking_ && !Parameters.data_.NoSink)
         {
            sinkLevel_ = Math.min(sinkLevel_ + 1,Parameters.MAX_SINK_LEVEL);
            this.moveMultiplier_ = 0.1 + (1 - sinkLevel_ / Parameters.MAX_SINK_LEVEL) * (_loc1_.props_.speed_ - 0.1);
         }
         else
         {
            sinkLevel_ = 0;
            if(Parameters.data_.NoSink && _loc1_.props_.speed_ < 1)
            {
               this.moveMultiplier_ = 1;
            }
            else
            {
               this.moveMultiplier_ = _loc1_.props_.speed_;
            }
         }
      }
      
      override protected function makeNameBitmapData() : BitmapData
      {
         var _loc1_:StringBuilder = new StaticStringBuilder(name_);
         var _loc2_:BitmapTextFactory = StaticInjectorContext.getInjector().getInstance(BitmapTextFactory);
         var _loc3_:BitmapData = _loc2_.make(_loc1_,16,this.getNameColor(),true,NAME_OFFSET_MATRIX,true);
         _loc3_.draw(FameUtil.numStarsToIcon(this.numStars_),RANK_OFFSET_MATRIX);
         return _loc3_;
      }
      
      private function getNameColor() : uint
      {
         if(this.isFellowGuild_)
         {
            return Parameters.FELLOW_GUILD_COLOR;
         }
         if(this.nameChosen_)
         {
            return Parameters.NAME_CHOSEN_COLOR;
         }
         return 16777215;
      }
      
      protected function drawBreathBar(param1:Vector.<IGraphicsData>, param2:int) : void
      {
         var _loc3_:Number = NaN;
         var _loc4_:Number = NaN;
         if(this.breathPath_ == null)
         {
            this.breathBackFill_ = new GraphicsSolidFill();
            this.breathBackPath_ = new GraphicsPath(GraphicsUtil.QUAD_COMMANDS,new Vector.<Number>());
            this.breathFill_ = new GraphicsSolidFill(2542335);
            this.breathPath_ = new GraphicsPath(GraphicsUtil.QUAD_COMMANDS,new Vector.<Number>());
         }
         if(this.breath_ <= Parameters.BREATH_THRESH)
         {
            _loc3_ = (Parameters.BREATH_THRESH - this.breath_) / Parameters.BREATH_THRESH;
            this.breathBackFill_.color = MoreColorUtil.lerpColor(5526612,16711680,Math.abs(Math.sin(param2 / 300)) * _loc3_);
         }
         else
         {
            this.breathBackFill_.color = 5526612;
         }
         var _loc5_:int = 20;
         var _loc8_:Vector.<Number> = this.breathBackPath_.data as Vector.<Number>;
         _loc8_.length = 0;
         _loc8_.push(posS_[0] - _loc5_,posS_[1] + 8,posS_[0] + _loc5_,posS_[1] + 8,posS_[0] + _loc5_,posS_[1] + 8 + 6,posS_[0] - _loc5_,posS_[1] + 8 + 6);
         param1.push(this.breathBackFill_);
         param1.push(this.breathBackPath_);
         param1.push(GraphicsUtil.END_FILL);
         if(this.breath_ > 0)
         {
            _loc4_ = this.breath_ / 100 * 2 * _loc5_;
            this.breathPath_.data.length = 0;
            _loc8_ = this.breathPath_.data as Vector.<Number>;
            _loc8_.length = 0;
            _loc8_.push(posS_[0] - _loc5_,posS_[1] + 8,posS_[0] - _loc5_ + _loc4_,posS_[1] + 8,posS_[0] - _loc5_ + _loc4_,posS_[1] + 8 + 6,posS_[0] - _loc5_,posS_[1] + 8 + 6);
            param1.push(this.breathFill_);
            param1.push(this.breathPath_);
            param1.push(GraphicsUtil.END_FILL);
         }
         GraphicsFillExtra.setSoftwareDrawSolid(this.breathFill_,true);
         GraphicsFillExtra.setSoftwareDrawSolid(this.breathBackFill_,true);
      }
      
      override public function draw(param1:Vector.<IGraphicsData>, param2:Camera, param3:int) : void
      {
         if(this.objectId_ != map_.player_.objectId_ && Parameters.data_.hidePlayers)
         {
            return;
         }
         super.draw(param1,param2,param3);
         if(this != map_.player_)
         {
            if(!Parameters.screenShotMode_)
            {
               drawName(param1,param2);
            }
         }
         else if(this.breath_ >= 0)
         {
            this.drawBreathBar(param1,param3);
         }
      }
      
      private function getMoveSpeed() : Number
      {
         if(isSlowed())
         {
            return MIN_MOVE_SPEED * this.moveMultiplier_;
         }
         var _loc1_:Number = MIN_MOVE_SPEED + this.speed_ / 75 * (MAX_MOVE_SPEED - MIN_MOVE_SPEED);
         if(isSpeedy() || isNinjaSpeedy())
         {
            _loc1_ *= 1.5;
         }
         _loc1_ *= this.moveMultiplier_;
         if(Parameters.data_.msmToggle)
         {
            return _loc1_ * Parameters.data_.msm;
         }
         return _loc1_;
      }
      
      public function attackFrequency() : Number
      {
         if(isDazed())
         {
            return MIN_ATTACK_FREQ;
         }
         var _loc1_:Number = MIN_ATTACK_FREQ + this.dexterity_ / 75 * (MAX_ATTACK_FREQ - MIN_ATTACK_FREQ);
         if(isBerserk())
         {
            _loc1_ *= 1.5;
         }
         return _loc1_;
      }
      
      private function attackMultiplier() : Number
      {
         if(isWeak())
         {
            return MIN_ATTACK_MULT;
         }
         var _loc1_:Number = MIN_ATTACK_MULT + this.attack_ / 75 * (MAX_ATTACK_MULT - MIN_ATTACK_MULT);
         if(isDamaging())
         {
            _loc1_ *= 1.5;
         }
         return _loc1_;
      }
      
      private function makeSkinTexture() : void
      {
         var _loc1_:MaskedImage = this.skin.imageFromAngle(0,AnimatedChar.STAND,0);
         animatedChar_ = this.skin;
         texture_ = _loc1_.image_;
         mask_ = _loc1_.mask_;
         this.isDefaultAnimatedChar = true;
      }
      
      private function setToRandomAnimatedCharacter() : void
      {
         var _loc1_:Vector.<XML> = ObjectLibrary.hexTransforms_;
         var _loc2_:uint = Math.floor(Math.random() * _loc1_.length);
         var _loc3_:int = int(_loc1_[_loc2_].@type);
         var _loc4_:TextureData = ObjectLibrary.typeToTextureData_[_loc3_];
         texture_ = _loc4_.texture_;
         mask_ = _loc4_.mask_;
         animatedChar_ = _loc4_.animatedChar_;
         this.isDefaultAnimatedChar = false;
      }
      
      override protected function getTexture(param1:Camera, param2:int) : BitmapData
      {
         var _loc3_:MaskedImage = null;
         var _loc4_:int = 0;
         var _loc5_:Dictionary = null;
         var _loc6_:Number = NaN;
         var _loc7_:int = 0;
         var _loc8_:ColorTransform = null;
         var _loc13_:BitmapData = null;
         var _loc9_:Number = 0;
         var _loc10_:int = AnimatedChar.STAND;
         if(this.isShooting || param2 < attackStart_ + this.attackPeriod_)
         {
            facing_ = attackAngle_;
            _loc9_ = (param2 - attackStart_) % this.attackPeriod_ / this.attackPeriod_;
            _loc10_ = AnimatedChar.ATTACK;
         }
         else if(moveVec_.x != 0 || moveVec_.y != 0)
         {
            _loc4_ = 3.5 / this.getMoveSpeed();
            if(moveVec_.y != 0 || moveVec_.x != 0)
            {
               facing_ = Math.atan2(moveVec_.y,moveVec_.x);
            }
            _loc9_ = param2 % _loc4_ / _loc4_;
            _loc10_ = AnimatedChar.WALK;
         }
         if(this.isHexed())
         {
            this.isDefaultAnimatedChar && this.setToRandomAnimatedCharacter();
         }
         else if(!this.isDefaultAnimatedChar)
         {
            this.makeSkinTexture();
         }
         if(param1.isHallucinating_)
         {
            _loc3_ = new MaskedImage(getHallucinatingTexture(),null);
         }
         else
         {
            _loc3_ = animatedChar_.imageFromFacing(facing_,param1,_loc10_,_loc9_);
         }
         var _loc11_:int = tex1Id_;
         var _loc12_:int = tex2Id_;
         if(this.nearestMerchant_)
         {
            _loc5_ = texturingCache_[this.nearestMerchant_];
            if(_loc5_ == null)
            {
               texturingCache_[this.nearestMerchant_] = new Dictionary();
            }
            else
            {
               _loc13_ = _loc5_[_loc3_];
            }
            _loc11_ = this.nearestMerchant_.getTex1Id(tex1Id_);
            _loc12_ = this.nearestMerchant_.getTex2Id(tex2Id_);
         }
         else
         {
            _loc13_ = texturingCache_[_loc3_];
         }
         if(_loc13_ == null)
         {
            _loc13_ = TextureRedrawer.resize(_loc3_.image_,_loc3_.mask_,size_,false,_loc11_,_loc12_);
            if(this.nearestMerchant_ != null)
            {
               texturingCache_[this.nearestMerchant_][_loc3_] = _loc13_;
            }
            else
            {
               texturingCache_[_loc3_] = _loc13_;
            }
         }
         if(hp_ < maxHP_ * 0.2)
         {
            _loc6_ = int(Math.abs(Math.sin(param2 / 200)) * 10) / 10;
            _loc7_ = 128;
            _loc8_ = new ColorTransform(1,1,1,1,_loc6_ * _loc7_,-_loc6_ * _loc7_,-_loc6_ * _loc7_);
            _loc13_ = CachingColorTransformer.transformBitmapData(_loc13_,_loc8_);
         }
         var _loc14_:BitmapData = texturingCache_[_loc13_];
         if(_loc14_ == null)
         {
            _loc14_ = GlowRedrawer.outlineGlow(_loc13_,this.legendaryRank_ == -1 ? uint(0) : uint(16711680));
            texturingCache_[_loc13_] = _loc14_;
         }
         if(isPaused() || isStasis() || isPetrified())
         {
            _loc14_ = CachingColorTransformer.filterBitmapData(_loc14_,PAUSED_FILTER);
         }
         else if(isInvisible())
         {
            _loc14_ = CachingColorTransformer.alphaBitmapData(_loc14_,0.4);
         }
         return _loc14_;
      }
      
      override public function getPortrait() : BitmapData
      {
         var _loc1_:MaskedImage = null;
         var _loc2_:int = 0;
         if(portrait_ == null)
         {
            _loc1_ = animatedChar_.imageFromDir(AnimatedChar.RIGHT,AnimatedChar.STAND,0);
            _loc2_ = 4 / _loc1_.image_.width * 100;
            portrait_ = TextureRedrawer.resize(_loc1_.image_,_loc1_.mask_,_loc2_,true,tex1Id_,tex2Id_);
            portrait_ = GlowRedrawer.outlineGlow(portrait_,0);
         }
         return portrait_;
      }
      
      public function useAltWeapon(param1:Number, param2:Number, param3:int) : Boolean
      {
         var _loc4_:XML = null;
         var _loc5_:int = 0;
         var _loc6_:Number = NaN;
         var _loc7_:int = 0;
         var _loc8_:int = 0;
         if(map_ == null || isPaused())
         {
            return false;
         }
         var _loc9_:int = equipment_[1];
         if(_loc9_ == -1)
         {
            return false;
         }
         var _loc10_:XML = ObjectLibrary.xmlLibrary_[_loc9_];
         if(_loc10_ == null || !_loc10_.hasOwnProperty("Usable"))
         {
            return false;
         }
         var _loc11_:Point = map_.pSTopW(param1,param2);
         if(_loc11_ == null)
         {
            SoundEffectLibrary.play("error");
            return false;
         }
         for each(_loc4_ in _loc10_.Activate)
         {
            if(_loc4_.toString() == ActivationType.TELEPORT)
            {
               if(!this.isValidPosition(_loc11_.x,_loc11_.y))
               {
                  SoundEffectLibrary.play("error");
                  return false;
               }
            }
         }
         _loc5_ = getTimer();
         if(param3 == UseType.START_USE)
         {
            if(_loc5_ < this.nextAltAttack_)
            {
               SoundEffectLibrary.play("error");
               return false;
            }
            _loc7_ = int(_loc10_.MpCost);
            if(_loc7_ > this.mp_)
            {
               SoundEffectLibrary.play("no_mana");
               return false;
            }
            if(Parameters.data_.NoCoolDown)
            {
               _loc8_ = 0;
            }
            else
            {
               _loc8_ = 500;
               if(_loc10_.hasOwnProperty("Cooldown"))
               {
                  _loc8_ = Number(_loc10_.Cooldown) * 1000;
               }
            }
            this.nextAltAttack_ = _loc5_ + _loc8_;
            map_.gs_.gsc_.useItem(_loc5_,objectId_,1,_loc9_,_loc11_.x,_loc11_.y,param3);
            if(_loc10_.Activate == ActivationType.SHOOT)
            {
               _loc6_ = Math.atan2(param2,param1);
               this.doShoot(_loc5_,_loc9_,_loc10_,Parameters.data_.cameraAngle + _loc6_,false);
            }
         }
         else if(_loc10_.hasOwnProperty("MultiPhase"))
         {
            map_.gs_.gsc_.useItem(_loc5_,objectId_,1,_loc9_,_loc11_.x,_loc11_.y,param3);
            _loc7_ = int(_loc10_.MpEndCost);
            if(_loc7_ <= this.mp_)
            {
               _loc6_ = Math.atan2(param2,param1);
               this.doShoot(_loc5_,_loc9_,_loc10_,Parameters.data_.cameraAngle + _loc6_,false);
            }
         }
         return true;
      }
      
      public function attemptAttackAngle(param1:Number) : void
      {
         this.shoot(Parameters.data_.cameraAngle + param1);
      }
      
      override public function setAttack(param1:int, param2:Number) : void
      {
         var _loc3_:XML = ObjectLibrary.xmlLibrary_[param1];
         if(_loc3_ == null || !_loc3_.hasOwnProperty("RateOfFire"))
         {
            return;
         }
         var _loc4_:Number = Number(_loc3_.RateOfFire);
         this.attackPeriod_ = 1 / this.attackFrequency() * (1 / _loc4_);
         super.setAttack(param1,param2);
      }
      
      private function shoot(param1:Number) : void
      {
         if(map_ == null || isStunned() || isPaused() || isPetrified())
         {
            return;
         }
         var _loc2_:int = equipment_[0];
         if(_loc2_ == -1)
         {
            this.addTextLine.dispatch(ChatMessage.make(Parameters.ERROR_CHAT_NAME,TextKey.PLAYER_NO_WEAPON_EQUIPPED));
            return;
         }
         var _loc3_:XML = ObjectLibrary.xmlLibrary_[_loc2_];
         var _loc4_:int = getTimer();
         var _loc5_:Number = Number(_loc3_.RateOfFire);
         this.attackPeriod_ = 1 / this.attackFrequency() * (1 / _loc5_);
         if(_loc4_ < attackStart_ + this.attackPeriod_)
         {
            return;
         }
         doneAction(map_.gs_,Tutorial.ATTACK_ACTION);
         attackAngle_ = param1;
         attackStart_ = _loc4_;
         this.doShoot(attackStart_,_loc2_,_loc3_,attackAngle_,true);
      }
      
      private function doShoot(param1:int, param2:int, param3:XML, param4:Number, param5:Boolean) : void
      {
         var _loc6_:uint = 0;
         var _loc7_:Projectile = null;
         var _loc8_:int = 0;
         var _loc9_:int = 0;
         var _loc10_:Number = NaN;
         var _loc11_:int = 0;
         var _loc12_:int = !!param3.hasOwnProperty("NumProjectiles") ? int(int(param3.NumProjectiles)) : 1;
         var _loc13_:Number = (!!param3.hasOwnProperty("ArcGap") ? Number(param3.ArcGap) : 11.25) * Trig.toRadians;
         var _loc14_:Number = _loc13_ * (_loc12_ - 1);
         var _loc15_:Number = param4 - _loc14_ / 2;
         this.isShooting = param5;
         var _loc16_:int = 0;
         while(_loc16_ < _loc12_)
         {
            _loc6_ = getBulletId();
            _loc7_ = FreeList.newObject(Projectile) as Projectile;
            if(param5 && this.projectileIdSetOverrideNew != "")
            {
               _loc7_.reset(param2,0,objectId_,_loc6_,_loc15_,param1,this.projectileIdSetOverrideNew,this.projectileIdSetOverrideOld);
            }
            else
            {
               _loc7_.reset(param2,0,objectId_,_loc6_,_loc15_,param1);
            }
            _loc8_ = int(_loc7_.projProps_.minDamage_);
            _loc9_ = int(_loc7_.projProps_.maxDamage_);
            _loc10_ = !!param5 ? Number(this.attackMultiplier()) : Number(1);
            _loc11_ = map_.gs_.gsc_.getNextDamage(_loc8_,_loc9_) * _loc10_;
            if(param1 > map_.gs_.moveRecords_.lastClearTime_ + 600)
            {
               _loc11_ = 0;
            }
            _loc7_.setDamage(_loc11_);
            if(_loc16_ == 0 && _loc7_.sound_ != null)
            {
               SoundEffectLibrary.play(_loc7_.sound_,0.75,false);
            }
            map_.addObj(_loc7_,x_ + Math.cos(param4) * 0.3,y_ + Math.sin(param4) * 0.3);
            map_.gs_.gsc_.playerShoot(param1,_loc7_);
            _loc15_ += _loc13_;
            _loc16_++;
         }
      }
      
      public function isHexed() : Boolean
      {
         return (condition_[ConditionEffect.CE_FIRST_BATCH] & ConditionEffect.HEXED_BIT) != 0;
      }
      
      public function isInventoryFull() : Boolean
      {
         var _loc1_:int = equipment_.length;
         var _loc2_:uint = 4;
         while(_loc2_ < _loc1_)
         {
            if(equipment_[_loc2_] <= 0)
            {
               return false;
            }
            _loc2_++;
         }
         return true;
      }
      
      public function nextAvailableInventorySlot() : int
      {
         var _loc1_:int = !!this.hasBackpack_ ? int(equipment_.length) : int(equipment_.length - GeneralConstants.NUM_INVENTORY_SLOTS);
         var _loc2_:uint = 4;
         while(_loc2_ < _loc1_)
         {
            if(equipment_[_loc2_] <= 0)
            {
               return _loc2_;
            }
            _loc2_++;
         }
         return -1;
      }
      
      public function numberOfAvailableSlots() : int
      {
         var _loc2_:int = 0;
         var _loc1_:int = !!this.hasBackpack_ ? int(equipment_.length) : int(equipment_.length - GeneralConstants.NUM_INVENTORY_SLOTS);
         var _loc3_:uint = 4;
         while(_loc3_ < _loc1_)
         {
            if(equipment_[_loc3_] <= 0)
            {
               _loc2_++;
            }
            _loc3_++;
         }
         return _loc2_;
      }
      
      public function swapInventoryIndex(param1:String) : int
      {
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         if(!this.hasBackpack_)
         {
            return -1;
         }
         if(param1 == TabStripModel.BACKPACK)
         {
            _loc2_ = GeneralConstants.NUM_EQUIPMENT_SLOTS;
            _loc3_ = GeneralConstants.NUM_EQUIPMENT_SLOTS + GeneralConstants.NUM_INVENTORY_SLOTS;
         }
         else
         {
            _loc2_ = GeneralConstants.NUM_EQUIPMENT_SLOTS + GeneralConstants.NUM_INVENTORY_SLOTS;
            _loc3_ = equipment_.length;
         }
         var _loc4_:uint = _loc2_;
         while(_loc4_ < _loc3_)
         {
            if(equipment_[_loc4_] <= 0)
            {
               return _loc4_;
            }
            _loc4_++;
         }
         return -1;
      }
      
      public function getPotionCount(param1:int) : int
      {
         switch(param1)
         {
            case PotionInventoryModel.HEALTH_POTION_ID:
               return this.healthPotionCount_;
            case PotionInventoryModel.MAGIC_POTION_ID:
               return this.magicPotionCount_;
            default:
               return 0;
         }
      }
      
      public function getTex1() : int
      {
         return tex1Id_;
      }
      
      public function getTex2() : int
      {
         return tex2Id_;
      }
   }
}
