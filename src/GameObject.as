package com.company.assembleegameclient.objects
{
   import com.company.assembleegameclient.engine3d.Model3D;
   import com.company.assembleegameclient.engine3d.Object3D;
   import com.company.assembleegameclient.map.Camera;
   import com.company.assembleegameclient.map.Map;
   import com.company.assembleegameclient.map.Square;
   import com.company.assembleegameclient.map.mapoverlay.CharacterStatusText;
   import com.company.assembleegameclient.objects.animation.Animations;
   import com.company.assembleegameclient.objects.animation.AnimationsData;
   import com.company.assembleegameclient.objects.particles.ExplosionEffect;
   import com.company.assembleegameclient.objects.particles.HitEffect;
   import com.company.assembleegameclient.objects.particles.ParticleEffect;
   import com.company.assembleegameclient.objects.particles.ShockerEffect;
   import com.company.assembleegameclient.parameters.Parameters;
   import com.company.assembleegameclient.sound.SoundEffectLibrary;
   import com.company.assembleegameclient.util.AnimatedChar;
   import com.company.assembleegameclient.util.BloodComposition;
   import com.company.assembleegameclient.util.ConditionEffect;
   import com.company.assembleegameclient.util.MaskedImage;
   import com.company.assembleegameclient.util.TextureRedrawer;
   import com.company.assembleegameclient.util.redrawers.GlowRedrawer;
   import com.company.util.AssetLibrary;
   import com.company.util.BitmapUtil;
   import com.company.util.CachingColorTransformer;
   import com.company.util.ConversionUtil;
   import com.company.util.GraphicsUtil;
   import com.company.util.MoreColorUtil;
   import flash.display.BitmapData;
   import flash.display.GradientType;
   import flash.display.GraphicsBitmapFill;
   import flash.display.GraphicsGradientFill;
   import flash.display.GraphicsPath;
   import flash.display.GraphicsSolidFill;
   import flash.display.IGraphicsData;
   import flash.filters.ColorMatrixFilter;
   import flash.geom.ColorTransform;
   import flash.geom.Matrix;
   import flash.geom.Point;
   import flash.geom.Vector3D;
   import flash.utils.Dictionary;
   import flash.utils.getQualifiedClassName;
   import flash.utils.getTimer;
   import kabam.rotmg.core.StaticInjectorContext;
   import kabam.rotmg.messaging.impl.data.WorldPosData;
   import kabam.rotmg.pets.data.PetVO;
   import kabam.rotmg.pets.data.PetsModel;
   import kabam.rotmg.stage3D.GraphicsFillExtra;
   import kabam.rotmg.stage3D.Object3D.Object3DStage3D;
   import kabam.rotmg.text.model.TextKey;
   import kabam.rotmg.text.view.BitmapTextFactory;
   import kabam.rotmg.text.view.stringBuilder.LineBuilder;
   import kabam.rotmg.text.view.stringBuilder.StaticStringBuilder;
   import kabam.rotmg.text.view.stringBuilder.StringBuilder;
   
   public class GameObject extends BasicObject
   {
      
      protected static const PAUSED_FILTER:ColorMatrixFilter = new ColorMatrixFilter(MoreColorUtil.greyscaleFilterMatrix);
      
      protected static const CURSED_FILTER:ColorMatrixFilter = new ColorMatrixFilter(MoreColorUtil.redFilterMatrix);
      
      protected static const IDENTITY_MATRIX:Matrix = new Matrix();
      
      private static const ZERO_LIMIT:Number = 0.00001;
      
      private static const NEGATIVE_ZERO_LIMIT:Number = -ZERO_LIMIT;
      
      public static const ATTACK_PERIOD:int = 300;
       
      
      public var nameBitmapData_:BitmapData = null;
      
      private var nameFill_:GraphicsBitmapFill = null;
      
      private var namePath_:GraphicsPath = null;
      
      public var shockEffect:ShockerEffect;
      
      private var isShocked:Boolean;
      
      private var isShockedTransformSet:Boolean = false;
      
      private var isCharging:Boolean;
      
      private var isChargingTransformSet:Boolean = false;
      
      public var props_:ObjectProperties;
      
      public var name_:String;
      
      public var radius_:Number = 0.5;
      
      public var facing_:Number = 0;
      
      public var flying_:Boolean = false;
      
      public var attackAngle_:Number = 0;
      
      public var attackStart_:int = 0;
      
      public var animatedChar_:AnimatedChar = null;
      
      public var texture_:BitmapData = null;
      
      public var mask_:BitmapData = null;
      
      public var randomTextureData_:Vector.<TextureData> = null;
      
      public var obj3D_:Object3D = null;
      
      public var object3d_:Object3DStage3D = null;
      
      public var effect_:ParticleEffect = null;
      
      public var animations_:Animations = null;
      
      public var dead_:Boolean = false;
      
      protected var portrait_:BitmapData = null;
      
      protected var texturingCache_:Dictionary = null;
      
      public var maxHP_:int = 200;
      
      public var hp_:int = 200;
      
      public var size_:int = 100;
      
      public var level_:int = -1;
      
      public var defense_:int = 0;
      
      public var slotTypes_:Vector.<int> = null;
      
      public var equipment_:Vector.<int> = null;
      
      public var condition_:Vector.<uint>;
      
      protected var tex1Id_:int = 0;
      
      protected var tex2Id_:int = 0;
      
      public var isInteractive_:Boolean = false;
      
      public var objectType_:int;
      
      private var nextBulletId_:uint = 1;
      
      private var sizeMult_:Number = 1;
      
      public var sinkLevel_:int = 0;
      
      public var hallucinatingTexture_:BitmapData = null;
      
      public var flash_:FlashDescription = null;
      
      public var connectType_:int = -1;
      
      private var isStunImmune_:Boolean = false;
      
      private var isParalyzeImmune_:Boolean = false;
      
      private var isDazedImmune_:Boolean = false;
      
      protected var lastTickUpdateTime_:int = 0;
      
      protected var myLastTickId_:int = -1;
      
      protected var posAtTick_:Point;
      
      protected var tickPosition_:Point;
      
      protected var moveVec_:Vector3D;
      
      protected var bitmapFill_:GraphicsBitmapFill;
      
      protected var path_:GraphicsPath;
      
      protected var vS_:Vector.<Number>;
      
      protected var uvt_:Vector.<Number>;
      
      protected var fillMatrix_:Matrix;
      
      private var hpbarBackFill_:GraphicsSolidFill = null;
      
      private var hpbarBackPath_:GraphicsPath = null;
      
      private var hpbarFill_:GraphicsSolidFill = null;
      
      private var hpbarPath_:GraphicsPath = null;
      
      private var icons_:Vector.<BitmapData> = null;
      
      private var iconFills_:Vector.<GraphicsBitmapFill> = null;
      
      private var iconPaths_:Vector.<GraphicsPath> = null;
      
      protected var shadowGradientFill_:GraphicsGradientFill = null;
      
      protected var shadowPath_:GraphicsPath = null;
      
      public function GameObject(param1:XML)
      {
         var _loc2_:int = 0;
         this.props_ = ObjectLibrary.defaultProps_;
         this.condition_ = new <uint>[0,0];
         this.posAtTick_ = new Point();
         this.tickPosition_ = new Point();
         this.moveVec_ = new Vector3D();
         this.bitmapFill_ = new GraphicsBitmapFill(null,null,false,false);
         this.path_ = new GraphicsPath(GraphicsUtil.QUAD_COMMANDS,null);
         this.vS_ = new Vector.<Number>();
         this.uvt_ = new Vector.<Number>();
         this.fillMatrix_ = new Matrix();
         super();
         if(param1 == null)
         {
            return;
         }
         this.objectType_ = int(param1.@type);
         this.props_ = ObjectLibrary.propsLibrary_[this.objectType_];
         hasShadow_ = this.props_.shadowSize_ > 0;
         var _loc3_:TextureData = ObjectLibrary.typeToTextureData_[this.objectType_];
         this.texture_ = _loc3_.texture_;
         this.mask_ = _loc3_.mask_;
         this.animatedChar_ = _loc3_.animatedChar_;
         this.randomTextureData_ = _loc3_.randomTextureData_;
         if(_loc3_.effectProps_ != null)
         {
            this.effect_ = ParticleEffect.fromProps(_loc3_.effectProps_,this);
         }
         if(this.texture_ != null)
         {
            this.sizeMult_ = this.texture_.height / 8;
         }
         if(param1.hasOwnProperty("Model"))
         {
            this.obj3D_ = Model3D.getObject3D(String(param1.Model));
            this.object3d_ = Model3D.getStage3dObject3D(String(param1.Model));
            if(this.texture_ != null)
            {
               this.object3d_.setBitMapData(this.texture_);
            }
         }
         var _loc4_:AnimationsData = ObjectLibrary.typeToAnimationsData_[this.objectType_];
         if(_loc4_ != null)
         {
            this.animations_ = new Animations(_loc4_);
         }
         z_ = this.props_.z_;
         this.flying_ = this.props_.flying_;
         if(param1.hasOwnProperty("MaxHitPoints"))
         {
            this.hp_ = this.maxHP_ = int(param1.MaxHitPoints);
         }
         if(param1.hasOwnProperty("Defense"))
         {
            this.defense_ = int(param1.Defense);
         }
         if(param1.hasOwnProperty("SlotTypes"))
         {
            this.slotTypes_ = ConversionUtil.toIntVector(param1.SlotTypes);
            this.equipment_ = new Vector.<int>(this.slotTypes_.length);
            _loc2_ = 0;
            while(_loc2_ < this.equipment_.length)
            {
               this.equipment_[_loc2_] = -1;
               _loc2_++;
            }
         }
         if(param1.hasOwnProperty("Tex1"))
         {
            this.tex1Id_ = int(param1.Tex1);
         }
         if(param1.hasOwnProperty("Tex2"))
         {
            this.tex2Id_ = int(param1.Tex2);
         }
         if(param1.hasOwnProperty("StunImmune"))
         {
            this.isStunImmune_ = true;
         }
         if(param1.hasOwnProperty("ParalyzeImmune"))
         {
            this.isParalyzeImmune_ = true;
         }
         if(param1.hasOwnProperty("DazedImmune"))
         {
            this.isDazedImmune_ = true;
         }
         this.props_.loadSounds();
      }
      
      public static function damageWithDefense(param1:int, param2:int, param3:Boolean, param4:Vector.<uint>) : int
      {
         var _loc5_:int = param2;
         if(param3 || (param4[ConditionEffect.CE_FIRST_BATCH] & ConditionEffect.ARMORBROKEN_BIT) != 0)
         {
            _loc5_ = 0;
         }
         else if((param4[ConditionEffect.CE_FIRST_BATCH] & ConditionEffect.ARMORED_BIT) != 0)
         {
            _loc5_ *= 2;
         }
         var _loc6_:int = param1 * 3 / 20;
         var _loc7_:int = Math.max(_loc6_,param1 - _loc5_);
         if((param4[ConditionEffect.CE_FIRST_BATCH] & ConditionEffect.INVULNERABLE_BIT) != 0)
         {
            _loc7_ = 0;
         }
         if((param4[ConditionEffect.CE_SECOND_BATCH] & ConditionEffect.PETRIFIED_BIT) != 0)
         {
            _loc7_ *= 0.9;
         }
         if((param4[ConditionEffect.CE_SECOND_BATCH] & ConditionEffect.CURSE_BIT) != 0)
         {
            _loc7_ *= 1.2;
         }
         return _loc7_;
      }
      
      public function setObjectId(param1:int) : void
      {
         var _loc2_:TextureData = null;
         objectId_ = param1;
         if(this.randomTextureData_ != null)
         {
            _loc2_ = this.randomTextureData_[objectId_ % this.randomTextureData_.length];
            this.texture_ = _loc2_.texture_;
            this.mask_ = _loc2_.mask_;
            this.animatedChar_ = _loc2_.animatedChar_;
            if(this.object3d_ != null)
            {
               this.object3d_.setBitMapData(this.texture_);
            }
         }
      }
      
      public function setAltTexture(param1:int) : void
      {
         var _loc2_:TextureData = null;
         var _loc3_:TextureData = ObjectLibrary.typeToTextureData_[this.objectType_];
         if(param1 == 0)
         {
            _loc2_ = _loc3_;
         }
         else
         {
            _loc2_ = _loc3_.getAltTextureData(param1);
            if(_loc2_ == null)
            {
               return;
            }
         }
         this.texture_ = _loc2_.texture_;
         this.mask_ = _loc2_.mask_;
         this.animatedChar_ = _loc2_.animatedChar_;
         if(this.effect_ != null)
         {
            map_.removeObj(this.effect_.objectId_);
            this.effect_ = null;
         }
         if(_loc2_.effectProps_ != null)
         {
            this.effect_ = ParticleEffect.fromProps(_loc2_.effectProps_,this);
            if(map_ != null)
            {
               map_.addObj(this.effect_,x_,y_);
            }
         }
      }
      
      public function setTex1(param1:int) : void
      {
         if(param1 == this.tex1Id_)
         {
            return;
         }
         this.tex1Id_ = param1;
         this.texturingCache_ = new Dictionary();
         this.portrait_ = null;
      }
      
      public function setTex2(param1:int) : void
      {
         if(param1 == this.tex2Id_)
         {
            return;
         }
         this.tex2Id_ = param1;
         this.texturingCache_ = new Dictionary();
         this.portrait_ = null;
      }
      
      public function playSound(param1:int) : void
      {
         SoundEffectLibrary.play(this.props_.sounds_[param1]);
      }
      
      override public function dispose() : void
      {
         var _loc1_:Object = null;
         var _loc2_:BitmapData = null;
         var _loc3_:Dictionary = null;
         var _loc4_:Object = null;
         var _loc5_:BitmapData = null;
         super.dispose();
         this.texture_ = null;
         if(this.portrait_ != null)
         {
            this.portrait_.dispose();
            this.portrait_ = null;
         }
         if(this.texturingCache_ != null)
         {
            for each(_loc1_ in this.texturingCache_)
            {
               _loc2_ = _loc1_ as BitmapData;
               if(_loc2_ != null)
               {
                  _loc2_.dispose();
               }
               else
               {
                  _loc3_ = _loc1_ as Dictionary;
                  for each(_loc4_ in _loc3_)
                  {
                     _loc5_ = _loc4_ as BitmapData;
                     if(_loc5_ != null)
                     {
                        _loc5_.dispose();
                     }
                  }
               }
            }
            this.texturingCache_ = null;
         }
         if(this.obj3D_ != null)
         {
            this.obj3D_.dispose();
            this.obj3D_ = null;
         }
         if(this.object3d_ != null)
         {
            this.object3d_.dispose();
            this.object3d_ = null;
         }
         this.slotTypes_ = null;
         this.equipment_ = null;
         if(this.nameBitmapData_ != null)
         {
            this.nameBitmapData_.dispose();
            this.nameBitmapData_ = null;
         }
         this.nameFill_ = null;
         this.namePath_ = null;
         this.bitmapFill_ = null;
         this.path_.commands = null;
         this.path_.data = null;
         this.vS_ = null;
         this.uvt_ = null;
         this.fillMatrix_ = null;
         this.icons_ = null;
         this.iconFills_ = null;
         this.iconPaths_ = null;
         this.shadowGradientFill_ = null;
         if(this.shadowPath_ != null)
         {
            this.shadowPath_.commands = null;
            this.shadowPath_.data = null;
            this.shadowPath_ = null;
         }
      }
      
      public function isQuiet() : Boolean
      {
         return (this.condition_[ConditionEffect.CE_FIRST_BATCH] & ConditionEffect.QUIET_BIT) != 0;
      }
      
      public function isWeak() : Boolean
      {
         return (this.condition_[ConditionEffect.CE_FIRST_BATCH] & ConditionEffect.WEAK_BIT) != 0;
      }
      
      public function isSlowed() : Boolean
      {
         return !!Parameters.data_.NoDebuff ? false : (this.condition_[ConditionEffect.CE_FIRST_BATCH] & ConditionEffect.SLOWED_BIT) != 0;
      }
      
      public function isSick() : Boolean
      {
         return (this.condition_[ConditionEffect.CE_FIRST_BATCH] & ConditionEffect.SICK_BIT) != 0;
      }
      
      public function isDazed() : Boolean
      {
         return !!Parameters.data_.NoDebuff ? false : (this.condition_[ConditionEffect.CE_FIRST_BATCH] & ConditionEffect.DAZED_BIT) != 0;
      }
      
      public function isStunned() : Boolean
      {
         return !!Parameters.data_.NoDebuff ? false : (this.condition_[ConditionEffect.CE_FIRST_BATCH] & ConditionEffect.STUNNED_BIT) != 0;
      }
      
      public function isBlind() : Boolean
      {
         return !!Parameters.data_.NoDebuff ? false : (this.condition_[ConditionEffect.CE_FIRST_BATCH] & ConditionEffect.BLIND_BIT) != 0;
      }
      
      public function isDrunk() : Boolean
      {
         return !!Parameters.data_.NoDebuff ? false : (this.condition_[ConditionEffect.CE_FIRST_BATCH] & ConditionEffect.DRUNK_BIT) != 0;
      }
      
      public function isConfused() : Boolean
      {
         return !!Parameters.data_.NoDebuff ? false : (this.condition_[ConditionEffect.CE_FIRST_BATCH] & ConditionEffect.CONFUSED_BIT) != 0;
      }
      
      public function isStunImmune() : Boolean
      {
         return (this.condition_[ConditionEffect.CE_FIRST_BATCH] & ConditionEffect.STUN_IMMUNE_BIT) != 0 || this.isStunImmune_;
      }
      
      public function isInvisible() : Boolean
      {
         return (this.condition_[ConditionEffect.CE_FIRST_BATCH] & ConditionEffect.INVISIBLE_BIT) != 0;
      }
      
      public function isParalyzed() : Boolean
      {
         return !!Parameters.data_.NoDebuff ? false : (this.condition_[ConditionEffect.CE_FIRST_BATCH] & ConditionEffect.PARALYZED_BIT) != 0;
      }
      
      public function isSpeedy() : Boolean
      {
         return (this.condition_[ConditionEffect.CE_FIRST_BATCH] & ConditionEffect.SPEEDY_BIT) != 0;
      }
      
      public function isNinjaSpeedy() : Boolean
      {
         return (this.condition_[ConditionEffect.CE_FIRST_BATCH] & ConditionEffect.NINJA_SPEEDY_BIT) != 0;
      }
      
      public function isHallucinating() : Boolean
      {
         return !!Parameters.data_.NoDebuff ? false : (this.condition_[ConditionEffect.CE_FIRST_BATCH] & ConditionEffect.HALLUCINATING_BIT) != 0;
      }
      
      public function isHealing() : Boolean
      {
         return (this.condition_[ConditionEffect.CE_FIRST_BATCH] & ConditionEffect.HEALING_BIT) != 0;
      }
      
      public function isDamaging() : Boolean
      {
         return (this.condition_[ConditionEffect.CE_FIRST_BATCH] & ConditionEffect.DAMAGING_BIT) != 0;
      }
      
      public function isBerserk() : Boolean
      {
         return !!Parameters.data_.DexHack ? true : (this.condition_[ConditionEffect.CE_FIRST_BATCH] & ConditionEffect.BERSERK_BIT) != 0;
      }
      
      public function isPaused() : Boolean
      {
         return false;
      }
      
      public function isStasis() : Boolean
      {
         return (this.condition_[ConditionEffect.CE_FIRST_BATCH] & ConditionEffect.STASIS_BIT) != 0;
      }
      
      public function isInvincible() : Boolean
      {
         return (this.condition_[ConditionEffect.CE_FIRST_BATCH] & ConditionEffect.INVINCIBLE_BIT) != 0;
      }
      
      public function isInvulnerable() : Boolean
      {
         return (this.condition_[ConditionEffect.CE_FIRST_BATCH] & ConditionEffect.INVULNERABLE_BIT) != 0;
      }
      
      public function isArmored() : Boolean
      {
         return (this.condition_[ConditionEffect.CE_FIRST_BATCH] & ConditionEffect.ARMORED_BIT) != 0;
      }
      
      public function isArmorBroken() : Boolean
      {
         return (this.condition_[ConditionEffect.CE_FIRST_BATCH] & ConditionEffect.ARMORBROKEN_BIT) != 0;
      }
      
      public function isArmorBrokenImmune() : Boolean
      {
         return (this.condition_[ConditionEffect.CE_FIRST_BATCH] & ConditionEffect.ARMORBROKEN_IMMUNE_BIT) != 0;
      }
      
      public function isSlowedImmune() : Boolean
      {
         return (this.condition_[ConditionEffect.CE_SECOND_BATCH] & ConditionEffect.SLOWED_IMMUNE_BIT) != 0;
      }
      
      public function isUnstable() : Boolean
      {
         return !!Parameters.data_.NoDebuff ? false : (this.condition_[ConditionEffect.CE_FIRST_BATCH] & ConditionEffect.UNSTABLE_BIT) != 0;
      }
      
      public function isShowPetEffectIcon() : Boolean
      {
         return (this.condition_[ConditionEffect.CE_SECOND_BATCH] & ConditionEffect.PET_EFFECT_ICON) != 0;
      }
      
      public function isDarkness() : Boolean
      {
         return !!Parameters.data_.NoDebuff ? false : (this.condition_[ConditionEffect.CE_FIRST_BATCH] & ConditionEffect.DARKNESS_BIT) != 0;
      }
      
      public function isParalyzeImmune() : Boolean
      {
         return this.isParalyzeImmune_ || (this.condition_[ConditionEffect.CE_SECOND_BATCH] & ConditionEffect.PARALYZED_IMMUNE_BIT) != 0;
      }
      
      public function isDazedImmune() : Boolean
      {
         return this.isDazedImmune_ || (this.condition_[ConditionEffect.CE_SECOND_BATCH] & ConditionEffect.DAZED_IMMUNE_BIT) != 0;
      }
      
      public function isPetrified() : Boolean
      {
         return (this.condition_[ConditionEffect.CE_SECOND_BATCH] & ConditionEffect.PETRIFIED_BIT) != 0;
      }
      
      public function isPetrifiedImmune() : Boolean
      {
         return (this.condition_[ConditionEffect.CE_SECOND_BATCH] & ConditionEffect.PETRIFIED_IMMUNE_BIT) != 0;
      }
      
      public function isCursed() : Boolean
      {
         return (this.condition_[ConditionEffect.CE_SECOND_BATCH] & ConditionEffect.CURSE_BIT) != 0;
      }
      
      public function isCursedImmune() : Boolean
      {
         return (this.condition_[ConditionEffect.CE_SECOND_BATCH] & ConditionEffect.CURSE_IMMUNE_BIT) != 0;
      }
      
      public function isSafe(param1:int = 20) : Boolean
      {
         var _loc2_:GameObject = null;
         var _loc3_:int = 0;
         var _loc4_:int = 0;
         for each(_loc2_ in map_.goDict_)
         {
            if(_loc2_ is Character && _loc2_.props_.isEnemy_)
            {
               _loc3_ = x_ > _loc2_.x_ ? int(x_ - _loc2_.x_) : int(_loc2_.x_ - x_);
               _loc4_ = y_ > _loc2_.y_ ? int(y_ - _loc2_.y_) : int(_loc2_.y_ - y_);
               if(_loc3_ < param1 && _loc4_ < param1)
               {
                  return false;
               }
            }
         }
         return true;
      }
      
      public function getName() : String
      {
         return this.name_ == null || this.name_ == "" ? ObjectLibrary.typeToDisplayId_[this.objectType_] : this.name_;
      }
      
      public function getColor() : uint
      {
         return BitmapUtil.mostCommonColor(this.texture_);
      }
      
      public function getBulletId() : uint
      {
         var _loc1_:uint = this.nextBulletId_;
         this.nextBulletId_ = (this.nextBulletId_ + 1) % 128;
         return _loc1_;
      }
      
      public function distTo(param1:WorldPosData) : Number
      {
         var _loc2_:Number = param1.x_ - x_;
         var _loc3_:Number = param1.y_ - y_;
         return Math.sqrt(_loc2_ * _loc2_ + _loc3_ * _loc3_);
      }
      
      public function toggleShockEffect(param1:Boolean) : void
      {
         if(param1)
         {
            this.isShocked = true;
         }
         else
         {
            this.isShocked = false;
            this.isShockedTransformSet = false;
         }
      }
      
      public function toggleChargingEffect(param1:Boolean) : void
      {
         if(param1)
         {
            this.isCharging = true;
         }
         else
         {
            this.isCharging = false;
            this.isChargingTransformSet = false;
         }
      }
      
      override public function addTo(param1:Map, param2:Number, param3:Number) : Boolean
      {
         map_ = param1;
         this.posAtTick_.x = this.tickPosition_.x = param2;
         this.posAtTick_.y = this.tickPosition_.y = param3;
         if(!this.moveTo(param2,param3))
         {
            map_ = null;
            return false;
         }
         if(this.effect_ != null)
         {
            map_.addObj(this.effect_,param2,param3);
         }
         return true;
      }
      
      override public function removeFromMap() : void
      {
         if(this.props_.static_ && square_ != null)
         {
            if(square_.obj_ == this)
            {
               square_.obj_ = null;
            }
            square_ = null;
         }
         if(this.effect_ != null)
         {
            map_.removeObj(this.effect_.objectId_);
         }
         super.removeFromMap();
         this.dispose();
      }
      
      public function moveTo(param1:Number, param2:Number) : Boolean
      {
         var _loc3_:Square = map_.getSquare(param1,param2);
         if(_loc3_ == null)
         {
            return false;
         }
         x_ = param1;
         y_ = param2;
         if(this.props_.static_)
         {
            if(square_ != null)
            {
               square_.obj_ = null;
            }
            _loc3_.obj_ = this;
         }
         square_ = _loc3_;
         if(this.obj3D_ != null)
         {
            this.obj3D_.setPosition(x_,y_,0,this.props_.rotation_);
         }
         if(this.object3d_ != null)
         {
            this.object3d_.setPosition(x_,y_,0,this.props_.rotation_);
         }
         return true;
      }
      
      override public function update(param1:int, param2:int) : Boolean
      {
         var _loc3_:int = 0;
         var _loc4_:Number = NaN;
         var _loc5_:Number = NaN;
         var _loc6_:Boolean = false;
         if(!(this.moveVec_.x == 0 && this.moveVec_.y == 0))
         {
            if(this.myLastTickId_ < map_.gs_.gsc_.lastTickId_)
            {
               this.moveVec_.x = 0;
               this.moveVec_.y = 0;
               this.moveTo(this.tickPosition_.x,this.tickPosition_.y);
            }
            else
            {
               _loc3_ = param1 - this.lastTickUpdateTime_;
               _loc4_ = this.posAtTick_.x + _loc3_ * this.moveVec_.x;
               _loc5_ = this.posAtTick_.y + _loc3_ * this.moveVec_.y;
               this.moveTo(_loc4_,_loc5_);
               _loc6_ = true;
            }
         }
         if(this.props_.whileMoving_ != null)
         {
            if(!_loc6_)
            {
               z_ = this.props_.z_;
               this.flying_ = this.props_.flying_;
            }
            else
            {
               z_ = this.props_.whileMoving_.z_;
               this.flying_ = this.props_.whileMoving_.flying_;
            }
         }
         return true;
      }
      
      public function onGoto(param1:Number, param2:Number, param3:int) : void
      {
         this.moveTo(param1,param2);
         this.lastTickUpdateTime_ = param3;
         this.tickPosition_.x = param1;
         this.tickPosition_.y = param2;
         this.posAtTick_.x = param1;
         this.posAtTick_.y = param2;
         this.moveVec_.x = 0;
         this.moveVec_.y = 0;
      }
      
      public function onTickPos(param1:Number, param2:Number, param3:int, param4:int) : void
      {
         if(this.myLastTickId_ < map_.gs_.gsc_.lastTickId_)
         {
            this.moveTo(this.tickPosition_.x,this.tickPosition_.y);
         }
         this.lastTickUpdateTime_ = map_.gs_.lastUpdate_;
         this.tickPosition_.x = param1;
         this.tickPosition_.y = param2;
         this.posAtTick_.x = x_;
         this.posAtTick_.y = y_;
         this.moveVec_.x = (this.tickPosition_.x - this.posAtTick_.x) / param3;
         this.moveVec_.y = (this.tickPosition_.y - this.posAtTick_.y) / param3;
         this.myLastTickId_ = param4;
      }
      
      public function damage(param1:int, param2:int, param3:Vector.<uint>, param4:Boolean, param5:Projectile) : void
      {
         var _loc6_:int = 0;
         var _loc7_:uint = 0;
         var _loc8_:ConditionEffect = null;
         var _loc9_:CharacterStatusText = null;
         var _loc10_:PetsModel = null;
         var _loc11_:PetVO = null;
         var _loc12_:String = null;
         var _loc13_:Vector.<uint> = null;
         var _loc14_:Boolean = false;
         var _loc15_:Boolean = false;
         if(param4)
         {
            this.dead_ = true;
         }
         else if(param3 != null)
         {
            _loc6_ = 0;
            for each(_loc7_ in param3)
            {
               _loc8_ = null;
               if(param5 != null && param5.projProps_.isPetEffect_ && param5.projProps_.isPetEffect_[_loc7_])
               {
                  _loc10_ = StaticInjectorContext.getInjector().getInstance(PetsModel);
                  _loc11_ = _loc10_.getActivePet();
                  if(_loc11_ != null)
                  {
                     _loc8_ = ConditionEffect.effects_[_loc7_];
                     this.showConditionEffectPet(_loc6_,_loc8_.name_);
                     _loc6_ += 500;
                  }
               }
               else
               {
                  switch(_loc7_)
                  {
                     case ConditionEffect.NOTHING:
                        break;
                     case ConditionEffect.QUIET:
                     case ConditionEffect.WEAK:
                     case ConditionEffect.SICK:
                     case ConditionEffect.BLIND:
                     case ConditionEffect.HALLUCINATING:
                     case ConditionEffect.DRUNK:
                     case ConditionEffect.CONFUSED:
                     case ConditionEffect.STUN_IMMUNE:
                     case ConditionEffect.INVISIBLE:
                     case ConditionEffect.SPEEDY:
                     case ConditionEffect.BLEEDING:
                     case ConditionEffect.STASIS:
                     case ConditionEffect.STASIS_IMMUNE:
                     case ConditionEffect.NINJA_SPEEDY:
                     case ConditionEffect.UNSTABLE:
                     case ConditionEffect.DARKNESS:
                     case ConditionEffect.PETRIFIED_IMMUNE:
                        _loc8_ = ConditionEffect.effects_[_loc7_];
                        break;
                     case ConditionEffect.SLOWED:
                        if(this.isSlowedImmune())
                        {
                           _loc9_ = new CharacterStatusText(this,16711680,3000);
                           _loc9_.setStringBuilder(new LineBuilder().setParams(TextKey.GAMEOBJECT_IMMUNE));
                           map_.mapOverlay_.addStatusText(_loc9_);
                           break;
                        }
                        _loc8_ = ConditionEffect.effects_[_loc7_];
                        break;
                     case ConditionEffect.ARMORBROKEN:
                        if(this.isArmorBrokenImmune())
                        {
                           _loc9_ = new CharacterStatusText(this,16711680,3000);
                           _loc9_.setStringBuilder(new LineBuilder().setParams(TextKey.GAMEOBJECT_IMMUNE));
                           map_.mapOverlay_.addStatusText(_loc9_);
                           break;
                        }
                        _loc8_ = ConditionEffect.effects_[_loc7_];
                        break;
                     case ConditionEffect.STUNNED:
                        if(this.isStunImmune())
                        {
                           _loc9_ = new CharacterStatusText(this,16711680,3000);
                           _loc9_.setStringBuilder(new LineBuilder().setParams(TextKey.GAMEOBJECT_IMMUNE));
                           map_.mapOverlay_.addStatusText(_loc9_);
                           break;
                        }
                        _loc8_ = ConditionEffect.effects_[_loc7_];
                        break;
                     case ConditionEffect.DAZED:
                        if(this.isDazedImmune())
                        {
                           _loc9_ = new CharacterStatusText(this,16711680,3000);
                           _loc9_.setStringBuilder(new LineBuilder().setParams(TextKey.GAMEOBJECT_IMMUNE));
                           map_.mapOverlay_.addStatusText(_loc9_);
                           break;
                        }
                        _loc8_ = ConditionEffect.effects_[_loc7_];
                        break;
                     case ConditionEffect.PARALYZED:
                        if(this.isParalyzeImmune())
                        {
                           _loc9_ = new CharacterStatusText(this,16711680,3000);
                           _loc9_.setStringBuilder(new LineBuilder().setParams(TextKey.GAMEOBJECT_IMMUNE));
                           map_.mapOverlay_.addStatusText(_loc9_);
                           break;
                        }
                        _loc8_ = ConditionEffect.effects_[_loc7_];
                        break;
                     case ConditionEffect.PETRIFIED:
                        if(this.isPetrifiedImmune())
                        {
                           _loc9_ = new CharacterStatusText(this,16711680,3000);
                           _loc9_.setStringBuilder(new LineBuilder().setParams(TextKey.GAMEOBJECT_IMMUNE));
                           map_.mapOverlay_.addStatusText(_loc9_);
                           break;
                        }
                        _loc8_ = ConditionEffect.effects_[_loc7_];
                        break;
                     case ConditionEffect.CURSE:
                        if(this.isCursedImmune())
                        {
                           _loc9_ = new CharacterStatusText(this,16711680,3000);
                           _loc9_.setStringBuilder(new LineBuilder().setParams(TextKey.GAMEOBJECT_IMMUNE));
                           map_.mapOverlay_.addStatusText(_loc9_);
                           break;
                        }
                        _loc8_ = ConditionEffect.effects_[_loc7_];
                        break;
                     case ConditionEffect.GROUND_DAMAGE:
                        _loc15_ = true;
                  }
                  if(_loc8_ != null)
                  {
                     if(_loc7_ < ConditionEffect.NEW_CON_THREASHOLD)
                     {
                        if((this.condition_[ConditionEffect.CE_FIRST_BATCH] | _loc8_.bit_) == this.condition_[ConditionEffect.CE_FIRST_BATCH])
                        {
                           continue;
                        }
                        this.condition_[ConditionEffect.CE_FIRST_BATCH] |= _loc8_.bit_;
                     }
                     else
                     {
                        if((this.condition_[ConditionEffect.CE_SECOND_BATCH] | _loc8_.bit_) == this.condition_[ConditionEffect.CE_SECOND_BATCH])
                        {
                           continue;
                        }
                        this.condition_[ConditionEffect.CE_SECOND_BATCH] |= _loc8_.bit_;
                     }
                     _loc12_ = _loc8_.localizationKey_;
                     this.showConditionEffect(_loc6_,_loc12_);
                     _loc6_ += 500;
                  }
               }
            }
         }
         if(!(this.props_.isEnemy_ && Parameters.data_.disableEnemyParticles))
         {
            _loc13_ = BloodComposition.getBloodComposition(this.objectType_,this.texture_,this.props_.bloodProb_,this.props_.bloodColor_);
            if(this.dead_)
            {
               map_.addObj(new ExplosionEffect(_loc13_,this.size_,30),x_,y_);
            }
            else if(param5 != null)
            {
               map_.addObj(new HitEffect(_loc13_,this.size_,10,param5.angle_,param5.projProps_.speed_),x_,y_);
            }
            else
            {
               map_.addObj(new ExplosionEffect(_loc13_,this.size_,10),x_,y_);
            }
         }
         if(param2 > 0)
         {
            _loc14_ = this.isArmorBroken() || param5 != null && param5.projProps_.armorPiercing_ || _loc15_;
            this.showDamageText(param2,_loc14_);
         }
      }
      
      public function showConditionEffect(param1:int, param2:String) : void
      {
         var _loc3_:CharacterStatusText = new CharacterStatusText(this,16711680,3000,param1);
         _loc3_.setStringBuilder(new LineBuilder().setParams(param2));
         map_.mapOverlay_.addStatusText(_loc3_);
      }
      
      public function showConditionEffectPet(param1:int, param2:String) : void
      {
         var _loc3_:CharacterStatusText = new CharacterStatusText(this,16711680,3000,param1);
         _loc3_.setStringBuilder(new StaticStringBuilder("Pet " + param2));
         map_.mapOverlay_.addStatusText(_loc3_);
      }
      
      public function showDamageText(param1:int, param2:Boolean) : void
      {
         var _loc3_:String = "-" + param1;
         var _loc4_:CharacterStatusText = new CharacterStatusText(this,!!param2 ? uint(9437439) : uint(16711680),1000);
         _loc4_.setStringBuilder(new StaticStringBuilder(_loc3_));
         map_.mapOverlay_.addStatusText(_loc4_);
      }
      
      protected function makeNameBitmapData() : BitmapData
      {
         var _loc1_:StringBuilder = new StaticStringBuilder(this.name_);
         var _loc2_:BitmapTextFactory = StaticInjectorContext.getInjector().getInstance(BitmapTextFactory);
         return _loc2_.make(_loc1_,16,16777215,true,IDENTITY_MATRIX,true);
      }
      
      public function drawName(param1:Vector.<IGraphicsData>, param2:Camera) : void
      {
         if(this.nameBitmapData_ == null)
         {
            this.nameBitmapData_ = this.makeNameBitmapData();
            this.nameFill_ = new GraphicsBitmapFill(null,new Matrix(),false,false);
            this.namePath_ = new GraphicsPath(GraphicsUtil.QUAD_COMMANDS,new Vector.<Number>());
         }
         var _loc3_:int = this.nameBitmapData_.width / 2 + 1;
         var _loc5_:Vector.<Number> = this.namePath_.data;
         _loc5_.length = 0;
         _loc5_.push(posS_[0] - _loc3_,posS_[1],posS_[0] + _loc3_,posS_[1],posS_[0] + _loc3_,posS_[1] + 30,posS_[0] - _loc3_,posS_[1] + 30);
         this.nameFill_.bitmapData = this.nameBitmapData_;
         var _loc6_:Matrix = this.nameFill_.matrix;
         _loc6_.identity();
         _loc6_.translate(_loc5_[0],_loc5_[1]);
         param1.push(this.nameFill_);
         param1.push(this.namePath_);
         param1.push(GraphicsUtil.END_FILL);
      }
      
      protected function getHallucinatingTexture() : BitmapData
      {
         if(this.hallucinatingTexture_ == null)
         {
            this.hallucinatingTexture_ = AssetLibrary.getImageFromSet("lofiChar8x8",int(Math.random() * 239));
         }
         return this.hallucinatingTexture_;
      }
      
      protected function getTexture(param1:Camera, param2:int) : BitmapData
      {
         var _loc3_:Pet = null;
         var _loc4_:Number = NaN;
         var _loc5_:int = 0;
         var _loc6_:MaskedImage = null;
         var _loc7_:int = 0;
         var _loc8_:BitmapData = null;
         var _loc9_:int = 0;
         var _loc10_:BitmapData = null;
         var _loc13_:BitmapData = null;
         if(this is Pet)
         {
            _loc3_ = Pet(this);
            if(this.condition_[ConditionEffect.CE_FIRST_BATCH] != 0 && !this.isPaused())
            {
               if(_loc3_.skinId != 32912)
               {
                  _loc3_.setSkin(32912);
               }
            }
            else if(!_loc3_.isDefaultAnimatedChar)
            {
               _loc3_.setDefaultSkin();
            }
         }
         var _loc11_:BitmapData = this.texture_;
         var _loc12_:int = this.size_;
         if(this.animatedChar_ != null)
         {
            _loc4_ = 0;
            _loc5_ = AnimatedChar.STAND;
            if(param2 < this.attackStart_ + ATTACK_PERIOD)
            {
               if(!this.props_.dontFaceAttacks_)
               {
                  this.facing_ = this.attackAngle_;
               }
               _loc4_ = (param2 - this.attackStart_) % ATTACK_PERIOD / ATTACK_PERIOD;
               _loc5_ = AnimatedChar.ATTACK;
            }
            else if(this.moveVec_.x != 0 || this.moveVec_.y != 0)
            {
               _loc7_ = 0.5 / this.moveVec_.length;
               _loc7_ += 400 - _loc7_ % 400;
               if(this.moveVec_.x > ZERO_LIMIT || this.moveVec_.x < NEGATIVE_ZERO_LIMIT || this.moveVec_.y > ZERO_LIMIT || this.moveVec_.y < NEGATIVE_ZERO_LIMIT)
               {
                  this.facing_ = Math.atan2(this.moveVec_.y,this.moveVec_.x);
                  _loc5_ = AnimatedChar.WALK;
               }
               else
               {
                  _loc5_ = AnimatedChar.STAND;
               }
               _loc4_ = param2 % _loc7_ / _loc7_;
            }
            _loc6_ = this.animatedChar_.imageFromFacing(this.facing_,param1,_loc5_,_loc4_);
            _loc11_ = _loc6_.image_;
            _loc13_ = _loc6_.mask_;
         }
         else if(this.animations_ != null)
         {
            _loc8_ = this.animations_.getTexture(param2);
            if(_loc8_ != null)
            {
               _loc11_ = _loc8_;
            }
         }
         if(this.props_.drawOnGround_ || this.obj3D_ != null)
         {
            return _loc11_;
         }
         if(param1.isHallucinating_)
         {
            _loc9_ = _loc11_ == null ? 8 : int(_loc11_.width);
            _loc11_ = this.getHallucinatingTexture();
            _loc13_ = null;
            _loc12_ = this.size_ * Math.min(1.5,_loc9_ / _loc11_.width);
         }
         if(this.isCursed() && !(this is Pet))
         {
            _loc11_ = CachingColorTransformer.filterBitmapData(_loc11_,CURSED_FILTER);
         }
         if((this.isStasis() || this.isPetrified()) && !(this is Pet))
         {
            _loc11_ = CachingColorTransformer.filterBitmapData(_loc11_,PAUSED_FILTER);
         }
         if(this.tex1Id_ == 0 && this.tex2Id_ == 0)
         {
            _loc11_ = TextureRedrawer.redraw(_loc11_,_loc12_,false,0);
         }
         else
         {
            _loc10_ = null;
            if(this.texturingCache_ == null)
            {
               this.texturingCache_ = new Dictionary();
            }
            else
            {
               _loc10_ = this.texturingCache_[_loc11_];
            }
            if(_loc10_ == null)
            {
               _loc10_ = TextureRedrawer.resize(_loc11_,_loc13_,_loc12_,false,this.tex1Id_,this.tex2Id_);
               _loc10_ = GlowRedrawer.outlineGlow(_loc10_,0);
               this.texturingCache_[_loc11_] = _loc10_;
            }
            _loc11_ = _loc10_;
         }
         return _loc11_;
      }
      
      public function useAltTexture(param1:String, param2:int) : void
      {
         this.texture_ = AssetLibrary.getImageFromSet(param1,param2);
         this.sizeMult_ = this.texture_.height / 8;
      }
      
      public function getPortrait() : BitmapData
      {
         var _loc1_:BitmapData = null;
         var _loc2_:int = 0;
         if(this.portrait_ == null)
         {
            _loc1_ = this.props_.portrait_ != null ? this.props_.portrait_.getTexture() : this.texture_;
            _loc2_ = 4 / _loc1_.width * 100;
            this.portrait_ = TextureRedrawer.resize(_loc1_,this.mask_,_loc2_,true,this.tex1Id_,this.tex2Id_);
            this.portrait_ = GlowRedrawer.outlineGlow(this.portrait_,0);
         }
         return this.portrait_;
      }
      
      public function setAttack(param1:int, param2:Number) : void
      {
         this.attackAngle_ = param2;
         this.attackStart_ = getTimer();
      }
      
      override public function draw3d(param1:Vector.<Object3DStage3D>) : void
      {
         if(this.object3d_ != null)
         {
            param1.push(this.object3d_);
         }
      }
      
      protected function drawHpBar(param1:Vector.<IGraphicsData>, param2:int) : void
      {
         var _loc3_:Number = NaN;
         var _loc4_:Number = NaN;
         if(this.hpbarPath_ == null)
         {
            this.hpbarBackFill_ = new GraphicsSolidFill();
            this.hpbarBackPath_ = new GraphicsPath(GraphicsUtil.QUAD_COMMANDS,new Vector.<Number>());
            this.hpbarFill_ = new GraphicsSolidFill(1113856);
            this.hpbarPath_ = new GraphicsPath(GraphicsUtil.QUAD_COMMANDS,new Vector.<Number>());
         }
         var _loc5_:Number = this.maxHP_;
         if(this.hp_ <= _loc5_)
         {
            _loc3_ = (_loc5_ - this.hp_) / _loc5_;
            this.hpbarBackFill_.color = MoreColorUtil.lerpColor(5526612,16711680,Math.abs(Math.sin(param2 / 300)) * _loc3_);
         }
         else
         {
            this.hpbarBackFill_.color = 5526612;
         }
         var _loc6_:int = 20;
         this.hpbarBackPath_.data.length = 0;
         this.hpbarBackPath_.data.push(posS_[0] - _loc6_,posS_[1] + 4,posS_[0] + _loc6_,posS_[1] + 4,posS_[0] + _loc6_,posS_[1] + 4 + 6,posS_[0] - _loc6_,posS_[1] + 4 + 6);
         param1.push(this.hpbarBackFill_);
         param1.push(this.hpbarBackPath_);
         param1.push(GraphicsUtil.END_FILL);
         if(this.hp_ > 0)
         {
            _loc4_ = this.hp_ / this.maxHP_ * 2 * _loc6_;
            this.hpbarPath_.data.length = 0;
            this.hpbarPath_.data.push(posS_[0] - _loc6_,posS_[1] + 4,posS_[0] - _loc6_ + _loc4_,posS_[1] + 4,posS_[0] - _loc6_ + _loc4_,posS_[1] + 4 + 6,posS_[0] - _loc6_,posS_[1] + 4 + 6);
            param1.push(this.hpbarFill_);
            param1.push(this.hpbarPath_);
            param1.push(GraphicsUtil.END_FILL);
         }
         GraphicsFillExtra.setSoftwareDrawSolid(this.hpbarFill_,true);
         GraphicsFillExtra.setSoftwareDrawSolid(this.hpbarBackFill_,true);
      }
      
      override public function draw(param1:Vector.<IGraphicsData>, param2:Camera, param3:int) : void
      {
         var _loc4_:BitmapData = null;
         var _loc5_:uint = 0;
         var _loc6_:uint = 0;
         var _loc7_:BitmapData = this.getTexture(param2,param3);
         if(this.props_.drawOnGround_)
         {
            if(square_.faces_.length == 0)
            {
               return;
            }
            this.path_.data = square_.faces_[0].face_.vout_;
            this.bitmapFill_.bitmapData = _loc7_;
            square_.baseTexMatrix_.calculateTextureMatrix(this.path_.data);
            this.bitmapFill_.matrix = square_.baseTexMatrix_.tToS_;
            param1.push(this.bitmapFill_);
            param1.push(this.path_);
            param1.push(GraphicsUtil.END_FILL);
            return;
         }
         if(this.obj3D_ != null && !Parameters.isGpuRender())
         {
            this.obj3D_.draw(param1,param2,this.props_.color_,_loc7_);
            return;
         }
         if(this.obj3D_ != null && Parameters.isGpuRender())
         {
            param1.push(null);
            return;
         }
         var _loc8_:int = _loc7_.width;
         var _loc9_:int = _loc7_.height;
         var _loc10_:int = square_.sink_ + this.sinkLevel_;
         if(_loc10_ > 0 && (this.flying_ || square_.obj_ != null && square_.obj_.props_.protectFromSink_))
         {
            _loc10_ = 0;
         }
         if(Parameters.isGpuRender())
         {
            if(_loc10_ != 0)
            {
               GraphicsFillExtra.setSinkLevel(this.bitmapFill_,Math.max(_loc10_ / _loc9_ * 1.65 - 0.02,0));
               _loc10_ = -_loc10_ + 0.02;
            }
            else if(_loc10_ == 0 && GraphicsFillExtra.getSinkLevel(this.bitmapFill_) != 0)
            {
               GraphicsFillExtra.clearSink(this.bitmapFill_);
            }
         }
         this.vS_.length = 0;
         this.vS_.push(posS_[3] - _loc8_ / 2,posS_[4] - _loc9_ + _loc10_,posS_[3] + _loc8_ / 2,posS_[4] - _loc9_ + _loc10_,posS_[3] + _loc8_ / 2,posS_[4],posS_[3] - _loc8_ / 2,posS_[4]);
         this.path_.data = this.vS_;
         if(this.flash_ != null)
         {
            if(!this.flash_.doneAt(param3))
            {
               if(Parameters.isGpuRender())
               {
                  this.flash_.applyGPUTextureColorTransform(_loc7_,param3);
               }
               else
               {
                  _loc7_ = this.flash_.apply(_loc7_,param3);
               }
            }
            else
            {
               this.flash_ = null;
            }
         }
         if(this.isShocked && !this.isShockedTransformSet)
         {
            if(Parameters.isGpuRender())
            {
               GraphicsFillExtra.setColorTransform(_loc7_,new ColorTransform(-1,-1,-1,1,255,255,255,0));
            }
            else
            {
               _loc4_ = _loc7_.clone();
               _loc4_.colorTransform(_loc4_.rect,new ColorTransform(-1,-1,-1,1,255,255,255,0));
               _loc4_ = CachingColorTransformer.filterBitmapData(_loc4_,new ColorMatrixFilter(MoreColorUtil.greyscaleFilterMatrix));
               _loc7_ = _loc4_;
            }
            this.isShockedTransformSet = true;
         }
         if(this.isCharging && !this.isChargingTransformSet)
         {
            if(Parameters.isGpuRender())
            {
               GraphicsFillExtra.setColorTransform(_loc7_,new ColorTransform(1,1,1,1,255,255,255,0));
            }
            else
            {
               _loc4_ = _loc7_.clone();
               _loc4_.colorTransform(_loc4_.rect,new ColorTransform(1,1,1,1,255,255,255,0));
               _loc7_ = _loc4_;
            }
            this.isChargingTransformSet = true;
         }
         this.bitmapFill_.bitmapData = _loc7_;
         this.fillMatrix_.identity();
         this.fillMatrix_.translate(this.vS_[0],this.vS_[1]);
         this.bitmapFill_.matrix = this.fillMatrix_;
         param1.push(this.bitmapFill_);
         param1.push(this.path_);
         param1.push(GraphicsUtil.END_FILL);
         if(!this.isPaused() && (this.condition_[ConditionEffect.CE_FIRST_BATCH] || this.condition_[ConditionEffect.CE_SECOND_BATCH]) && !Parameters.screenShotMode_ && !(this is Pet))
         {
            this.drawConditionIcons(param1,param2,param3);
         }
         if(this.props_.showName_ && this.name_ != null && this.name_.length != 0)
         {
            this.drawName(param1,param2);
         }
         if(this.props_ && (this.props_.isEnemy_ || this.props_.isPlayer_) && !this.isInvisible() && !this.isInvulnerable() && !this.props_.noMiniMap_)
         {
            _loc5_ = _loc7_.getPixel32(_loc7_.width / 4,_loc7_.height / 4) | _loc7_.getPixel32(_loc7_.width / 2,_loc7_.height / 2) | _loc7_.getPixel32(_loc7_.width * 3 / 4,_loc7_.height * 3 / 4);
            _loc6_ = _loc5_ >> 24;
            if(_loc6_ != 0)
            {
               hasShadow_ = true;
               if(Parameters.data_.HPBar)
               {
                  this.drawHpBar(param1,param3);
               }
            }
            else
            {
               hasShadow_ = false;
            }
         }
      }
      
      public function drawConditionIcons(param1:Vector.<IGraphicsData>, param2:Camera, param3:int) : void
      {
         var _loc4_:BitmapData = null;
         var _loc5_:GraphicsBitmapFill = null;
         var _loc6_:GraphicsPath = null;
         var _loc7_:Number = NaN;
         var _loc8_:Number = NaN;
         var _loc9_:Matrix = null;
         var _loc14_:int = 0;
         if(this.icons_ == null)
         {
            this.icons_ = new Vector.<BitmapData>();
            this.iconFills_ = new Vector.<GraphicsBitmapFill>();
            this.iconPaths_ = new Vector.<GraphicsPath>();
         }
         this.icons_.length = 0;
         var _loc10_:int = param3 / 500;
         ConditionEffect.getConditionEffectIcons(this.condition_[ConditionEffect.CE_FIRST_BATCH],this.icons_,_loc10_);
         ConditionEffect.getConditionEffectIcons2(this.condition_[ConditionEffect.CE_SECOND_BATCH],this.icons_,_loc10_);
         var _loc11_:Number = posS_[3];
         var _loc12_:Number = this.vS_[1];
         var _loc13_:int = this.icons_.length;
         while(_loc14_ < _loc13_)
         {
            _loc4_ = this.icons_[_loc14_];
            if(_loc14_ >= this.iconFills_.length)
            {
               this.iconFills_.push(new GraphicsBitmapFill(null,new Matrix(),false,false));
               this.iconPaths_.push(new GraphicsPath(GraphicsUtil.QUAD_COMMANDS,new Vector.<Number>()));
            }
            _loc5_ = this.iconFills_[_loc14_];
            _loc6_ = this.iconPaths_[_loc14_];
            _loc5_.bitmapData = _loc4_;
            _loc7_ = _loc11_ - _loc4_.width * _loc13_ / 2 + _loc14_ * _loc4_.width;
            _loc8_ = _loc12_ - _loc4_.height / 2;
            _loc6_.data.length = 0;
            _loc6_.data.push(_loc7_,_loc8_,_loc7_ + _loc4_.width,_loc8_,_loc7_ + _loc4_.width,_loc8_ + _loc4_.height,_loc7_,_loc8_ + _loc4_.height);
            _loc9_ = _loc5_.matrix;
            _loc9_.identity();
            _loc9_.translate(_loc7_,_loc8_);
            param1.push(_loc5_);
            param1.push(_loc6_);
            param1.push(GraphicsUtil.END_FILL);
            _loc14_++;
         }
      }
      
      override public function drawShadow(param1:Vector.<IGraphicsData>, param2:Camera, param3:int) : void
      {
         if(this.shadowGradientFill_ == null)
         {
            this.shadowGradientFill_ = new GraphicsGradientFill(GradientType.RADIAL,[this.props_.shadowColor_,this.props_.shadowColor_],[0.5,0],null,new Matrix());
            this.shadowPath_ = new GraphicsPath(GraphicsUtil.QUAD_COMMANDS,new Vector.<Number>());
         }
         var _loc4_:Number = this.size_ / 100 * (this.props_.shadowSize_ / 100) * this.sizeMult_;
         var _loc5_:Number = 30 * _loc4_;
         var _loc6_:Number = 15 * _loc4_;
         this.shadowGradientFill_.matrix.createGradientBox(_loc5_ * 2,_loc6_ * 2,0,posS_[0] - _loc5_,posS_[1] - _loc6_);
         param1.push(this.shadowGradientFill_);
         this.shadowPath_.data.length = 0;
         this.shadowPath_.data.push(posS_[0] - _loc5_,posS_[1] - _loc6_,posS_[0] + _loc5_,posS_[1] - _loc6_,posS_[0] + _loc5_,posS_[1] + _loc6_,posS_[0] - _loc5_,posS_[1] + _loc6_);
         param1.push(this.shadowPath_);
         param1.push(GraphicsUtil.END_FILL);
      }
      
      public function clearTextureCache() : void
      {
         this.texturingCache_ = new Dictionary();
      }
      
      public function toString() : String
      {
         return "[" + getQualifiedClassName(this) + " id: " + objectId_ + " type: " + ObjectLibrary.typeToDisplayId_[this.objectType_] + " pos: " + x_ + ", " + y_ + "]";
      }
   }
}
