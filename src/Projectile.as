package com.company.assembleegameclient.objects
{
   import com.company.assembleegameclient.engine3d.Point3D;
   import com.company.assembleegameclient.game.AGameSprite;
   import com.company.assembleegameclient.map.Camera;
   import com.company.assembleegameclient.map.Map;
   import com.company.assembleegameclient.map.Square;
   import com.company.assembleegameclient.objects.particles.HitEffect;
   import com.company.assembleegameclient.objects.particles.SparkParticle;
   import com.company.assembleegameclient.parameters.Parameters;
   import com.company.assembleegameclient.tutorial.Tutorial;
   import com.company.assembleegameclient.tutorial.doneAction;
   import com.company.assembleegameclient.util.BloodComposition;
   import com.company.assembleegameclient.util.FreeList;
   import com.company.assembleegameclient.util.RandomUtil;
   import com.company.assembleegameclient.util.TextureRedrawer;
   import com.company.util.GraphicsUtil;
   import com.company.util.Trig;
   import flash.display.BitmapData;
   import flash.display.GradientType;
   import flash.display.GraphicsGradientFill;
   import flash.display.GraphicsPath;
   import flash.display.IGraphicsData;
   import flash.geom.Matrix;
   import flash.geom.Point;
   import flash.geom.Vector3D;
   import flash.utils.Dictionary;
   
   public class Projectile extends BasicObject
   {
      
      private static var objBullIdToObjId_:Dictionary = new Dictionary();
       
      
      public var gs_:AGameSprite;
      
      public var props_:ObjectProperties;
      
      public var containerProps_:ObjectProperties;
      
      public var projProps_:ProjectileProperties;
      
      public var texture_:BitmapData;
      
      public var bulletId_:uint;
      
      public var ownerId_:int;
      
      public var containerType_:int;
      
      public var bulletType_:uint;
      
      public var damagesEnemies_:Boolean;
      
      public var damagesPlayers_:Boolean;
      
      public var damage_:int;
      
      public var sound_:String;
      
      public var startX_:Number;
      
      public var startY_:Number;
      
      public var startTime_:int;
      
      public var angle_:Number = 0;
      
      public var multiHitDict_:Dictionary;
      
      public var p_:Point3D;
      
      private var staticPoint_:Point;
      
      private var staticVector3D_:Vector3D;
      
      protected var shadowGradientFill_:GraphicsGradientFill;
      
      protected var shadowPath_:GraphicsPath;
      
      public function Projectile()
      {
         this.p_ = new Point3D(100);
         this.staticPoint_ = new Point();
         this.staticVector3D_ = new Vector3D();
         this.shadowGradientFill_ = new GraphicsGradientFill(GradientType.RADIAL,[0,0],[0.5,0],null,new Matrix());
         this.shadowPath_ = new GraphicsPath(GraphicsUtil.QUAD_COMMANDS,new Vector.<Number>());
         super();
      }
      
      public static function findObjId(param1:int, param2:uint) : int
      {
         return objBullIdToObjId_[param2 << 24 | param1];
      }
      
      public static function getNewObjId(param1:int, param2:uint) : int
      {
         var _loc3_:int = getNextFakeObjectId();
         objBullIdToObjId_[param2 << 24 | param1] = _loc3_;
         return _loc3_;
      }
      
      public static function removeObjId(param1:int, param2:uint) : void
      {
         delete objBullIdToObjId_[param2 << 24 | param1];
      }
      
      public static function dispose() : void
      {
         objBullIdToObjId_ = new Dictionary();
      }
      
      public function reset(param1:int, param2:int, param3:int, param4:int, param5:Number, param6:int, param7:String = "", param8:String = "") : void
      {
         var _loc9_:Number = NaN;
         clear();
         this.containerType_ = param1;
         this.bulletType_ = param2;
         this.ownerId_ = param3;
         this.bulletId_ = param4;
         this.angle_ = Trig.boundToPI(param5);
         this.startTime_ = param6;
         objectId_ = getNewObjId(this.ownerId_,this.bulletId_);
         z_ = 0.5;
         this.containerProps_ = ObjectLibrary.propsLibrary_[this.containerType_];
         this.projProps_ = this.containerProps_.projectiles_[param2];
         var _loc10_:String = param7 != "" && this.projProps_.objectId_ == param8 ? param7 : this.projProps_.objectId_;
         this.props_ = ObjectLibrary.getPropsFromId(_loc10_);
         hasShadow_ = this.props_.shadowSize_ > 0;
         var _loc11_:TextureData = ObjectLibrary.typeToTextureData_[this.props_.type_];
         this.texture_ = _loc11_.getTexture(objectId_);
         this.damagesPlayers_ = this.containerProps_.isEnemy_;
         this.damagesEnemies_ = !this.damagesPlayers_;
         this.sound_ = this.containerProps_.oldSound_;
         this.multiHitDict_ = !!this.projProps_.multiHit_ ? new Dictionary() : null;
         if(this.projProps_.size_ >= 0)
         {
            _loc9_ = this.projProps_.size_;
         }
         else
         {
            _loc9_ = ObjectLibrary.getSizeFromType(this.containerType_);
         }
         this.p_.setSize(8 * (_loc9_ / 100));
         this.damage_ = 0;
      }
      
      public function setDamage(param1:int) : void
      {
         this.damage_ = param1;
      }
      
      override public function addTo(param1:Map, param2:Number, param3:Number) : Boolean
      {
         var _loc4_:Player = null;
         this.startX_ = param2;
         this.startY_ = param3;
         if(!super.addTo(param1,param2,param3))
         {
            return false;
         }
         if(!this.containerProps_.flying_ && square_.sink_)
         {
            z_ = 0.1;
         }
         else
         {
            _loc4_ = param1.goDict_[this.ownerId_] as Player;
            if(_loc4_ != null && _loc4_.sinkLevel_ > 0)
            {
               z_ = 0.5 - 0.4 * (_loc4_.sinkLevel_ / Parameters.MAX_SINK_LEVEL);
            }
         }
         return true;
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
         square_ = _loc3_;
         return true;
      }
      
      override public function removeFromMap() : void
      {
         super.removeFromMap();
         removeObjId(this.ownerId_,this.bulletId_);
         this.multiHitDict_ = null;
         FreeList.deleteObject(this);
      }
      
      private function positionAt(param1:int, param2:Point) : void
      {
         var _loc3_:Number = NaN;
         var _loc4_:Number = NaN;
         var _loc5_:Number = NaN;
         var _loc6_:Number = NaN;
         var _loc7_:Number = NaN;
         var _loc8_:Number = NaN;
         var _loc9_:Number = NaN;
         var _loc10_:Number = NaN;
         var _loc11_:Number = NaN;
         var _loc12_:Number = NaN;
         param2.x = this.startX_;
         param2.y = this.startY_;
         var _loc13_:Number = param1 * (this.projProps_.speed_ / 10000);
         var _loc14_:Number = this.bulletId_ % 2 == 0 ? Number(0) : Number(Math.PI);
         if(this.projProps_.wavy_)
         {
            _loc3_ = 6 * Math.PI;
            _loc4_ = Math.PI / 64;
            _loc5_ = this.angle_ + _loc4_ * Math.sin(_loc14_ + _loc3_ * param1 / 1000);
            param2.x += _loc13_ * Math.cos(_loc5_);
            param2.y += _loc13_ * Math.sin(_loc5_);
         }
         else if(this.projProps_.parametric_)
         {
            _loc6_ = param1 / this.projProps_.lifetime_ * 2 * Math.PI;
            _loc7_ = Math.sin(_loc6_) * (!!(this.bulletId_ % 2) ? 1 : -1);
            _loc8_ = Math.sin(2 * _loc6_) * (this.bulletId_ % 4 < 2 ? 1 : -1);
            _loc9_ = Math.sin(this.angle_);
            _loc10_ = Math.cos(this.angle_);
            param2.x += (_loc7_ * _loc10_ - _loc8_ * _loc9_) * this.projProps_.magnitude_;
            param2.y += (_loc7_ * _loc9_ + _loc8_ * _loc10_) * this.projProps_.magnitude_;
         }
         else
         {
            if(this.projProps_.boomerang_)
            {
               _loc11_ = this.projProps_.lifetime_ * (this.projProps_.speed_ / 10000) / 2;
               if(_loc13_ > _loc11_)
               {
                  _loc13_ = _loc11_ - (_loc13_ - _loc11_);
               }
            }
            param2.x += _loc13_ * Math.cos(this.angle_);
            param2.y += _loc13_ * Math.sin(this.angle_);
            if(this.projProps_.amplitude_ != 0)
            {
               _loc12_ = this.projProps_.amplitude_ * Math.sin(_loc14_ + param1 / this.projProps_.lifetime_ * this.projProps_.frequency_ * 2 * Math.PI);
               param2.x += _loc12_ * Math.cos(this.angle_ + Math.PI / 2);
               param2.y += _loc12_ * Math.sin(this.angle_ + Math.PI / 2);
            }
         }
      }
      
      override public function update(param1:int, param2:int) : Boolean
      {
         var _loc3_:Vector.<uint> = null;
         var _loc4_:Player = null;
         var _loc5_:* = false;
         var _loc6_:Boolean = false;
         var _loc7_:Boolean = false;
         var _loc8_:int = 0;
         var _loc9_:Boolean = false;
         var _loc14_:Number = NaN;
         var _loc10_:int = Parameters.data_.RangeHax && this.ownerId_ == map_.player_.objectId_ ? 1000 : 0;
         var _loc11_:int = param1 - this.startTime_;
         if(_loc11_ > this.projProps_.lifetime_ + _loc10_)
         {
            return false;
         }
         var _loc12_:Point = this.staticPoint_;
         this.positionAt(_loc11_,_loc12_);
         if(!this.moveTo(_loc12_.x,_loc12_.y) || square_.tileType_ == 65535)
         {
            if(this.damagesPlayers_)
            {
               map_.gs_.gsc_.squareHit(param1,this.bulletId_,this.ownerId_);
            }
            else if(square_.obj_ != null)
            {
               _loc3_ = BloodComposition.getColors(this.texture_);
               map_.addObj(new HitEffect(_loc3_,100,3,this.angle_,this.projProps_.speed_),_loc12_.x,_loc12_.y);
            }
            return false;
         }
         if(square_.obj_ != null && (!square_.obj_.props_.isEnemy_ || !this.damagesEnemies_) && (square_.obj_.props_.enemyOccupySquare_ || !this.projProps_.passesCover_ && square_.obj_.props_.occupySquare_))
         {
            if(this.damagesPlayers_)
            {
               map_.gs_.gsc_.otherHit(param1,this.bulletId_,this.ownerId_,square_.obj_.objectId_);
            }
            else
            {
               if(Parameters.data_.ProjNoClip && this.ownerId_ == map_.player_.objectId_)
               {
                  return true;
               }
               _loc3_ = BloodComposition.getColors(this.texture_);
               map_.addObj(new HitEffect(_loc3_,100,3,this.angle_,this.projProps_.speed_),_loc12_.x,_loc12_.y);
            }
            return false;
         }
         var _loc13_:GameObject = this.getHit(_loc12_.x,_loc12_.y);
         if(_loc13_ != null)
         {
            _loc4_ = map_.player_;
            _loc5_ = _loc4_ != null;
            _loc6_ = _loc13_.props_.isEnemy_;
            _loc7_ = _loc5_ && !_loc4_.isPaused() && (this.damagesPlayers_ || _loc6_ && this.ownerId_ == _loc4_.objectId_);
            if(_loc7_)
            {
               _loc8_ = GameObject.damageWithDefense(this.damage_,_loc13_.defense_,this.projProps_.armorPiercing_,_loc13_.condition_);
               _loc9_ = false;
               if(_loc13_.hp_ <= _loc8_)
               {
                  _loc9_ = true;
                  if(_loc13_.props_.isEnemy_)
                  {
                     doneAction(map_.gs_,Tutorial.KILL_ACTION);
                  }
               }
               if(_loc13_ == _loc4_)
               {
                  map_.gs_.gsc_.playerHit(this.bulletId_,this.ownerId_);
                  _loc13_.damage(this.containerType_,_loc8_,this.projProps_.effects_,false,this);
               }
               else if(_loc13_.props_.isEnemy_)
               {
                  _loc14_ = 0;
                  while(_loc14_ < 5 && Parameters.data_.StackedShots)
                  {
                     _loc14_++;
                     map_.gs_.gsc_.enemyHit(param1,this.bulletId_,_loc13_.objectId_,_loc9_);
                  }
                  map_.gs_.gsc_.enemyHit(param1,this.bulletId_,_loc13_.objectId_,_loc9_);
                  _loc13_.damage(this.containerType_,_loc8_,this.projProps_.effects_,_loc9_,this);
               }
               else if(!this.projProps_.multiHit_)
               {
                  map_.gs_.gsc_.otherHit(param1,this.bulletId_,this.ownerId_,_loc13_.objectId_);
               }
            }
            if(this.ownerId_ == map_.player_.objectId_ && Parameters.data_.ProjNoClip)
            {
               this.projProps_.multiHit_ = true;
            }
            if(!this.projProps_.multiHit_)
            {
               return false;
            }
            this.multiHitDict_[_loc13_] = true;
         }
         return true;
      }
      
      public function getHit(param1:Number, param2:Number) : GameObject
      {
         var _loc3_:GameObject = null;
         var _loc4_:Number = NaN;
         var _loc5_:Number = NaN;
         var _loc6_:Number = NaN;
         var _loc7_:Number = NaN;
         var _loc9_:GameObject = null;
         var _loc8_:Number = Number.MAX_VALUE;
         for each(_loc3_ in map_.goDict_)
         {
            if(!_loc3_.isInvincible())
            {
               if(!_loc3_.isStasis())
               {
                  if(this.damagesEnemies_ && _loc3_.props_.isEnemy_ || this.damagesPlayers_ && _loc3_.props_.isItem_)
                  {
                     if(!(_loc3_.dead_ || _loc3_.isPaused()))
                     {
                        _loc4_ = _loc3_.x_ > param1 ? Number(_loc3_.x_ - param1) : Number(param1 - _loc3_.x_);
                        _loc5_ = _loc3_.y_ > param2 ? Number(_loc3_.y_ - param2) : Number(param2 - _loc3_.y_);
                        if(!(_loc4_ > _loc3_.radius_ || _loc5_ > _loc3_.radius_))
                        {
                           if(!(this.projProps_.multiHit_ && this.multiHitDict_[_loc3_] != null))
                           {
                              if(_loc3_ == map_.player_)
                              {
                                 return _loc3_;
                              }
                              _loc6_ = Math.sqrt(_loc4_ * _loc4_ + _loc5_ * _loc5_);
                              _loc7_ = _loc4_ * _loc4_ + _loc5_ * _loc5_;
                              if(_loc7_ < _loc8_)
                              {
                                 _loc8_ = _loc7_;
                                 _loc9_ = _loc3_;
                              }
                           }
                        }
                     }
                  }
               }
            }
         }
         return _loc9_;
      }
      
      override public function draw(param1:Vector.<IGraphicsData>, param2:Camera, param3:int) : void
      {
         var _loc4_:uint = 0;
         var _loc5_:uint = 0;
         var _loc6_:int = 0;
         var _loc7_:int = 0;
         if(!Parameters.drawProj_)
         {
            return;
         }
         var _loc8_:BitmapData = this.texture_;
         if(Parameters.projColorType_ != 0)
         {
            switch(Parameters.projColorType_)
            {
               case 1:
                  _loc4_ = 16777100;
                  _loc5_ = 16777215;
                  break;
               case 2:
                  _loc4_ = 16777100;
                  _loc5_ = 16777100;
                  break;
               case 3:
                  _loc4_ = 16711680;
                  _loc5_ = 16711680;
                  break;
               case 4:
                  _loc4_ = 255;
                  _loc5_ = 255;
                  break;
               case 5:
                  _loc4_ = 16777215;
                  _loc5_ = 16777215;
                  break;
               case 6:
                  _loc4_ = 0;
                  _loc5_ = 0;
            }
            _loc8_ = TextureRedrawer.redraw(_loc8_,120,true,_loc5_);
         }
         var _loc9_:Number = this.props_.rotation_ == 0 ? Number(0) : Number(param3 / this.props_.rotation_);
         this.staticVector3D_.x = x_;
         this.staticVector3D_.y = y_;
         this.staticVector3D_.z = z_;
         this.p_.draw(param1,this.staticVector3D_,this.angle_ - param2.angleRad_ + this.props_.angleCorrection_ + _loc9_,param2.wToS_,param2,_loc8_);
         if(this.projProps_.particleTrail_)
         {
            _loc6_ = this.projProps_.particleTrailLifetimeMS != -1 ? int(this.projProps_.particleTrailLifetimeMS) : 600;
            _loc7_ = 0;
            for(; _loc7_ < 3; _loc7_++)
            {
               if(map_ != null && map_.player_.objectId_ != this.ownerId_)
               {
                  if(this.projProps_.particleTrailIntensity_ == -1 && Math.random() * 100 > this.projProps_.particleTrailIntensity_)
                  {
                     continue;
                  }
               }
               map_.addObj(new SparkParticle(100,this.projProps_.particleTrailColor_,_loc6_,0.5,RandomUtil.plusMinus(3),RandomUtil.plusMinus(3)),x_,y_);
            }
         }
      }
      
      override public function drawShadow(param1:Vector.<IGraphicsData>, param2:Camera, param3:int) : void
      {
         if(!Parameters.drawProj_)
         {
            return;
         }
         var _loc4_:Number = this.props_.shadowSize_ / 400;
         var _loc5_:Number = 30 * _loc4_;
         var _loc6_:Number = 15 * _loc4_;
         this.shadowGradientFill_.matrix.createGradientBox(_loc5_ * 2,_loc6_ * 2,0,posS_[0] - _loc5_,posS_[1] - _loc6_);
         param1.push(this.shadowGradientFill_);
         this.shadowPath_.data.length = 0;
         Vector.<Number>(this.shadowPath_.data).push(posS_[0] - _loc5_,posS_[1] - _loc6_,posS_[0] + _loc5_,posS_[1] - _loc6_,posS_[0] + _loc5_,posS_[1] + _loc6_,posS_[0] - _loc5_,posS_[1] + _loc6_);
         param1.push(this.shadowPath_);
         param1.push(GraphicsUtil.END_FILL);
      }
   }
}
