package com.company.assembleegameclient.map
{
   import com.company.assembleegameclient.game.AGameSprite;
   import com.company.assembleegameclient.map.mapoverlay.MapOverlay;
   import com.company.assembleegameclient.map.partyoverlay.PartyOverlay;
   import com.company.assembleegameclient.objects.BasicObject;
   import com.company.assembleegameclient.objects.GameObject;
   import com.company.assembleegameclient.objects.Party;
   import com.company.assembleegameclient.objects.particles.ParticleEffect;
   import com.company.assembleegameclient.parameters.Parameters;
   import com.company.assembleegameclient.util.ConditionEffect;
   import flash.display.BitmapData;
   import flash.display.DisplayObject;
   import flash.display.GraphicsBitmapFill;
   import flash.display.GraphicsSolidFill;
   import flash.display.IGraphicsData;
   import flash.filters.BlurFilter;
   import flash.filters.ColorMatrixFilter;
   import flash.geom.Point;
   import flash.geom.Rectangle;
   import flash.utils.Dictionary;
   import kabam.rotmg.assets.EmbeddedAssets;
   import kabam.rotmg.core.StaticInjectorContext;
   import kabam.rotmg.game.logging.RollingMeanLoopMonitor;
   import kabam.rotmg.game.model.GameModel;
   import kabam.rotmg.stage3D.GraphicsFillExtra;
   import kabam.rotmg.stage3D.Object3D.Object3DStage3D;
   import kabam.rotmg.stage3D.Render3D;
   import kabam.rotmg.stage3D.Renderer;
   import kabam.rotmg.stage3D.graphic3D.Program3DFactory;
   import kabam.rotmg.stage3D.graphic3D.TextureFactory;
   
   public class Map extends AbstractMap
   {
      
      public static const CLOTH_BAZAAR:String = "Cloth Bazaar";
      
      public static const NEXUS:String = "Nexus";
      
      public static const DAILY_QUEST_ROOM:String = "Daily Quest Room";
      
      public static const PET_YARD_1:String = "Pet Yard";
      
      public static const PET_YARD_2:String = "Pet Yard 2";
      
      public static const PET_YARD_3:String = "Pet Yard 3";
      
      public static const PET_YARD_4:String = "Pet Yard 4";
      
      public static const PET_YARD_5:String = "Pet Yard 5";
      
      public static const GUILD_HALL:String = "Guild Hall";
      
      public static const NEXUS_EXPLANATION:String = "Nexus_Explanation";
      
      public static const VAULT:String = "Vault";
      
      public static var forceSoftwareRender:Boolean = false;
      
      private static const VISIBLE_SORT_FIELDS:Array = ["sortVal_","objectId_"];
      
      private static const VISIBLE_SORT_PARAMS:Array = [Array.NUMERIC,Array.NUMERIC];
      
      protected static const BLIND_FILTER:ColorMatrixFilter = new ColorMatrixFilter([0.05,0.05,0.05,0,0,0.05,0.05,0.05,0,0,0.05,0.05,0.05,0,0,0.05,0.05,0.05,1,0]);
      
      public static var texture:BitmapData;
       
      
      private var loopMonitor:RollingMeanLoopMonitor;
      
      private var inUpdate_:Boolean = false;
      
      private var objsToAdd_:Vector.<BasicObject>;
      
      private var idsToRemove_:Vector.<int>;
      
      private var forceSoftwareMap:Dictionary;
      
      private var lastSoftwareClear:Boolean = false;
      
      private var darkness:DisplayObject;
      
      private var graphicsData_:Vector.<IGraphicsData>;
      
      private var graphicsDataStageSoftware_:Vector.<IGraphicsData>;
      
      private var graphicsData3d_:Vector.<Object3DStage3D>;
      
      public var visible_:Array;
      
      public var visibleUnder_:Array;
      
      public var visibleSquares_:Vector.<Square>;
      
      public var topSquares_:Vector.<Square>;
      
      public function Map(param1:AGameSprite)
      {
         this.objsToAdd_ = new Vector.<BasicObject>();
         this.idsToRemove_ = new Vector.<int>();
         this.forceSoftwareMap = new Dictionary();
         this.darkness = new EmbeddedAssets.DarknessBackground();
         this.graphicsData_ = new Vector.<IGraphicsData>();
         this.graphicsDataStageSoftware_ = new Vector.<IGraphicsData>();
         this.graphicsData3d_ = new Vector.<Object3DStage3D>();
         this.visible_ = [];
         this.visibleUnder_ = [];
         this.visibleSquares_ = new Vector.<Square>();
         this.topSquares_ = new Vector.<Square>();
         super();
         gs_ = param1;
         hurtOverlay_ = new HurtOverlay();
         gradientOverlay_ = new GradientOverlay();
         mapOverlay_ = new MapOverlay();
         partyOverlay_ = new PartyOverlay(this);
         party_ = new Party(this);
         quest_ = new Quest(this);
         this.loopMonitor = StaticInjectorContext.getInjector().getInstance(RollingMeanLoopMonitor);
         StaticInjectorContext.getInjector().getInstance(GameModel).gameObjects = goDict_;
         this.forceSoftwareMap[PET_YARD_1] = true;
         this.forceSoftwareMap[PET_YARD_2] = true;
         this.forceSoftwareMap[PET_YARD_3] = true;
         this.forceSoftwareMap[PET_YARD_4] = true;
         this.forceSoftwareMap[PET_YARD_5] = true;
         this.forceSoftwareMap["Nexus"] = true;
         this.forceSoftwareMap["Tomb of the Ancients"] = true;
         this.forceSoftwareMap["Tomb of the Ancients (Heroic)"] = true;
         this.forceSoftwareMap["Mad Lab"] = true;
         this.forceSoftwareMap["Guild Hall"] = true;
         this.forceSoftwareMap["Guild Hall 2"] = true;
         this.forceSoftwareMap["Guild Hall 3"] = true;
         this.forceSoftwareMap["Guild Hall 4"] = true;
         this.forceSoftwareMap["Cloth Bazaar"] = true;
         wasLastFrameGpu = Parameters.isGpuRender();
      }
      
      override public function setProps(param1:int, param2:int, param3:String, param4:int, param5:Boolean, param6:Boolean) : void
      {
         width_ = param1;
         height_ = param2;
         name_ = param3;
         back_ = param4;
         allowPlayerTeleport_ = param5;
         showDisplays_ = param6;
         this.forceSoftwareRenderCheck(name_);
      }
      
      private function forceSoftwareRenderCheck(param1:String) : void
      {
         forceSoftwareRender = this.forceSoftwareMap[param1] != null || WebMain.STAGE.stage3Ds[0].context3D == null;
      }
      
      override public function initialize() : void
      {
         squares_.length = width_ * height_;
         addChild(map_);
         addChild(hurtOverlay_);
         addChild(gradientOverlay_);
         addChild(mapOverlay_);
         addChild(partyOverlay_);
         isPetYard = name_.substr(0,8) == "Pet Yard";
      }
      
      override public function dispose() : void
      {
         var _loc1_:Square = null;
         var _loc2_:GameObject = null;
         var _loc3_:BasicObject = null;
         gs_ = null;
         map_ = null;
         hurtOverlay_ = null;
         gradientOverlay_ = null;
         mapOverlay_ = null;
         partyOverlay_ = null;
         for each(_loc1_ in squareList_)
         {
            _loc1_.dispose();
         }
         squareList_.length = 0;
         squareList_ = null;
         squares_.length = 0;
         squares_ = null;
         for each(_loc2_ in goDict_)
         {
            _loc2_.dispose();
         }
         goDict_ = null;
         for each(_loc3_ in boDict_)
         {
            _loc3_.dispose();
         }
         boDict_ = null;
         merchLookup_ = null;
         player_ = null;
         party_ = null;
         quest_ = null;
         this.objsToAdd_ = null;
         this.idsToRemove_ = null;
         TextureFactory.disposeTextures();
         GraphicsFillExtra.dispose();
         Program3DFactory.getInstance().dispose();
      }
      
      override public function update(param1:int, param2:int) : void
      {
         var _loc3_:BasicObject = null;
         var _loc4_:int = 0;
         this.inUpdate_ = true;
         for each(_loc3_ in goDict_)
         {
            if(!_loc3_.update(param1,param2))
            {
               this.idsToRemove_.push(_loc3_.objectId_);
            }
         }
         for each(_loc3_ in boDict_)
         {
            if(!_loc3_.update(param1,param2))
            {
               this.idsToRemove_.push(_loc3_.objectId_);
            }
         }
         this.inUpdate_ = false;
         for each(_loc3_ in this.objsToAdd_)
         {
            this.internalAddObj(_loc3_);
         }
         this.objsToAdd_.length = 0;
         for each(_loc4_ in this.idsToRemove_)
         {
            this.internalRemoveObj(_loc4_);
         }
         this.idsToRemove_.length = 0;
         party_.update(param1,param2);
      }
      
      override public function pSTopW(param1:Number, param2:Number) : Point
      {
         var _loc3_:Square = null;
         for each(_loc3_ in this.visibleSquares_)
         {
            if(_loc3_.faces_.length != 0 && _loc3_.faces_[0].face_.contains(param1,param2))
            {
               return new Point(_loc3_.center_.x,_loc3_.center_.y);
            }
         }
         return null;
      }
      
      override public function setGroundTile(param1:int, param2:int, param3:uint) : void
      {
         var _loc4_:int = 0;
         var _loc5_:int = 0;
         var _loc6_:Square = null;
         var _loc7_:Square = this.getSquare(param1,param2);
         _loc7_.setTileType(param3);
         var _loc8_:int = param1 < width_ - 1 ? int(param1 + 1) : int(param1);
         var _loc9_:int = param2 < height_ - 1 ? int(param2 + 1) : int(param2);
         var _loc10_:int = param1 > 0 ? int(param1 - 1) : int(param1);
         while(_loc10_ <= _loc8_)
         {
            _loc4_ = param2 > 0 ? int(param2 - 1) : int(param2);
            while(_loc4_ <= _loc9_)
            {
               _loc5_ = _loc10_ + _loc4_ * width_;
               _loc6_ = squares_[_loc5_];
               if(_loc6_ != null && (_loc6_.props_.hasEdge_ || _loc6_.tileType_ != param3))
               {
                  _loc6_.faces_.length = 0;
               }
               _loc4_++;
            }
            _loc10_++;
         }
      }
      
      override public function addObj(param1:BasicObject, param2:Number, param3:Number) : void
      {
         param1.x_ = param2;
         param1.y_ = param3;
         if(param1 is ParticleEffect)
         {
            (param1 as ParticleEffect).reducedDrawEnabled = !Parameters.data_.particleEffect;
         }
         if(this.inUpdate_)
         {
            this.objsToAdd_.push(param1);
         }
         else
         {
            this.internalAddObj(param1);
         }
      }
      
      public function internalAddObj(param1:BasicObject) : void
      {
         if(!param1.addTo(this,param1.x_,param1.y_))
         {
            return;
         }
         var _loc2_:Dictionary = param1 is GameObject ? goDict_ : boDict_;
         if(_loc2_[param1.objectId_] != null)
         {
            if(!isPetYard)
            {
               return;
            }
         }
         _loc2_[param1.objectId_] = param1;
      }
      
      override public function removeObj(param1:int) : void
      {
         if(this.inUpdate_)
         {
            this.idsToRemove_.push(param1);
         }
         else
         {
            this.internalRemoveObj(param1);
         }
      }
      
      public function internalRemoveObj(param1:int) : void
      {
         var _loc2_:Dictionary = goDict_;
         var _loc3_:BasicObject = _loc2_[param1];
         if(_loc3_ == null)
         {
            _loc2_ = boDict_;
            _loc3_ = _loc2_[param1];
            if(_loc3_ == null)
            {
               return;
            }
         }
         _loc3_.removeFromMap();
         delete _loc2_[param1];
      }
      
      public function getSquare(param1:Number, param2:Number) : Square
      {
         if(param1 < 0 || param1 >= width_ || param2 < 0 || param2 >= height_)
         {
            return null;
         }
         var _loc3_:int = int(param1) + int(param2) * width_;
         var _loc4_:Square = squares_[_loc3_];
         if(_loc4_ == null)
         {
            _loc4_ = new Square(this,int(param1),int(param2));
            squares_[_loc3_] = _loc4_;
            squareList_.push(_loc4_);
         }
         return _loc4_;
      }
      
      public function lookupSquare(param1:int, param2:int) : Square
      {
         if(param1 < 0 || param1 >= width_ || param2 < 0 || param2 >= height_)
         {
            return null;
         }
         return squares_[param1 + param2 * width_];
      }
      
      override public function draw(param1:Camera, param2:int) : void
      {
         var _loc11_:Square = null;
         var _loc12_:int = 0;
         var _loc13_:GameObject = null;
         var _loc14_:BasicObject = null;
         var _loc15_:int = 0;
         var _loc16_:Number = NaN;
         var _loc17_:Number = NaN;
         var _loc18_:Number = NaN;
         var _loc19_:uint = 0;
         var _loc20_:Render3D = null;
         var _loc21_:Array = null;
         var _loc22_:Number = NaN;
         if(wasLastFrameGpu != Parameters.isGpuRender())
         {
            if(wasLastFrameGpu == true && WebMain.STAGE.stage3Ds[0].context3D != null && !(WebMain.STAGE.stage3Ds[0].context3D != null && WebMain.STAGE.stage3Ds[0].context3D.driverInfo.toLowerCase().indexOf("disposed") != -1))
            {
               WebMain.STAGE.stage3Ds[0].context3D.clear();
               WebMain.STAGE.stage3Ds[0].context3D.present();
            }
            else
            {
               map_.graphics.clear();
            }
            signalRenderSwitch.dispatch(wasLastFrameGpu);
            wasLastFrameGpu = Parameters.isGpuRender();
         }
         var _loc3_:Rectangle = param1.clipRect_;
         this.scaleX = 600 / (Parameters.data_.mscale * 50);
         this.scaleY = 600 / (Parameters.data_.mscale * 50);
         x = -_loc3_.x * 600 / (Parameters.data_.mscale * 50);
         y = -_loc3_.y * 600 / (Parameters.data_.mscale * 50);
         var _loc4_:Number = (-_loc3_.y - _loc3_.height / 2) / 50;
         var _loc5_:Point = new Point(param1.x_ + _loc4_ * Math.cos(param1.angleRad_ - Math.PI / 2),param1.y_ + _loc4_ * Math.sin(param1.angleRad_ - Math.PI / 2));
         if(background_ != null)
         {
            background_.draw(param1,param2);
         }
         this.visible_.length = 0;
         this.visibleUnder_.length = 0;
         this.visibleSquares_.length = 0;
         this.topSquares_.length = 0;
         var _loc6_:int = param1.maxDist_;
         var _loc7_:int = Math.max(0,_loc5_.x - _loc6_);
         var _loc8_:int = Math.min(width_ - 1,_loc5_.x + _loc6_);
         var _loc9_:int = Math.max(0,_loc5_.y - _loc6_);
         var _loc10_:int = Math.min(height_ - 1,_loc5_.y + _loc6_);
         this.graphicsData_.length = 0;
         this.graphicsDataStageSoftware_.length = 0;
         this.graphicsData3d_.length = 0;
         _loc12_ = _loc7_;
         while(_loc12_ <= _loc8_)
         {
            _loc15_ = _loc9_;
            while(_loc15_ <= _loc10_)
            {
               _loc11_ = squares_[_loc12_ + _loc15_ * width_];
               if(_loc11_ != null)
               {
                  _loc16_ = _loc5_.x - _loc11_.center_.x;
                  _loc17_ = _loc5_.y - _loc11_.center_.y;
                  _loc18_ = _loc16_ * _loc16_ + _loc17_ * _loc17_;
                  if(_loc18_ <= param1.maxDistSq_)
                  {
                     _loc11_.lastVisible_ = param2;
                     _loc11_.draw(this.graphicsData_,param1,param2);
                     this.visibleSquares_.push(_loc11_);
                     if(_loc11_.topFace_ != null)
                     {
                        this.topSquares_.push(_loc11_);
                     }
                  }
               }
               _loc15_++;
            }
            _loc12_++;
         }
         for each(_loc13_ in goDict_)
         {
            _loc13_.drawn_ = false;
            if(!_loc13_.dead_)
            {
               _loc11_ = _loc13_.square_;
               if(_loc11_ != null && _loc11_.lastVisible_ == param2)
               {
                  _loc13_.drawn_ = true;
                  _loc13_.computeSortVal(param1);
                  if(_loc13_.props_.drawUnder_)
                  {
                     if(_loc13_.props_.drawOnGround_)
                     {
                        _loc13_.draw(this.graphicsData_,param1,param2);
                     }
                     this.visibleUnder_.push(_loc13_);
                  }
                  else
                  {
                     this.visible_.push(_loc13_);
                  }
               }
            }
         }
         for each(_loc14_ in boDict_)
         {
            _loc14_.drawn_ = false;
            _loc11_ = _loc14_.square_;
            if(_loc11_ != null && _loc11_.lastVisible_ == param2)
            {
               _loc14_.drawn_ = true;
               _loc14_.computeSortVal(param1);
               this.visible_.push(_loc14_);
            }
         }
         if(this.visibleUnder_.length > 0)
         {
            this.visibleUnder_.sortOn(VISIBLE_SORT_FIELDS,VISIBLE_SORT_PARAMS);
            for each(_loc14_ in this.visibleUnder_)
            {
               if(!(_loc14_ is GameObject && (_loc14_ as GameObject).props_.drawOnGround_))
               {
                  _loc14_.draw(this.graphicsData_,param1,param2);
               }
            }
         }
         this.visible_.sortOn(VISIBLE_SORT_FIELDS,VISIBLE_SORT_PARAMS);
         if(Parameters.data_.drawShadows)
         {
            for each(_loc14_ in this.visible_)
            {
               if(_loc14_.hasShadow_)
               {
                  _loc14_.drawShadow(this.graphicsData_,param1,param2);
               }
            }
         }
         for each(_loc14_ in this.visible_)
         {
            _loc14_.draw(this.graphicsData_,param1,param2);
            if(Parameters.isGpuRender())
            {
               _loc14_.draw3d(this.graphicsData3d_);
            }
         }
         if(this.topSquares_.length > 0)
         {
            for each(_loc11_ in this.topSquares_)
            {
               _loc11_.drawTop(this.graphicsData_,param1,param2);
            }
         }
         if(Parameters.isGpuRender() && Renderer.inGame)
         {
            _loc19_ = this.getFilterIndex();
            _loc20_ = StaticInjectorContext.getInjector().getInstance(Render3D);
            _loc20_.dispatch(this.graphicsData_,this.graphicsData3d_,width_,height_,param1,_loc19_);
            _loc12_ = 0;
            while(_loc12_ < this.graphicsData_.length)
            {
               if(this.graphicsData_[_loc12_] is GraphicsBitmapFill && GraphicsFillExtra.isSoftwareDraw(GraphicsBitmapFill(this.graphicsData_[_loc12_])))
               {
                  this.graphicsDataStageSoftware_.push(this.graphicsData_[_loc12_]);
                  this.graphicsDataStageSoftware_.push(this.graphicsData_[_loc12_ + 1]);
                  this.graphicsDataStageSoftware_.push(this.graphicsData_[_loc12_ + 2]);
               }
               else if(this.graphicsData_[_loc12_] is GraphicsSolidFill && GraphicsFillExtra.isSoftwareDrawSolid(GraphicsSolidFill(this.graphicsData_[_loc12_])))
               {
                  this.graphicsDataStageSoftware_.push(this.graphicsData_[_loc12_]);
                  this.graphicsDataStageSoftware_.push(this.graphicsData_[_loc12_ + 1]);
                  this.graphicsDataStageSoftware_.push(this.graphicsData_[_loc12_ + 2]);
               }
               _loc12_++;
            }
            if(this.graphicsDataStageSoftware_.length > 0)
            {
               map_.graphics.clear();
               map_.graphics.drawGraphicsData(this.graphicsDataStageSoftware_);
               if(this.lastSoftwareClear)
               {
                  this.lastSoftwareClear = false;
               }
            }
            else if(!this.lastSoftwareClear)
            {
               map_.graphics.clear();
               this.lastSoftwareClear = true;
            }
            if(param2 % 149 == 0)
            {
               GraphicsFillExtra.manageSize();
            }
         }
         else
         {
            map_.graphics.clear();
            map_.graphics.drawGraphicsData(this.graphicsData_);
         }
         map_.filters.length = 0;
         if(player_ != null && (player_.condition_[ConditionEffect.CE_FIRST_BATCH] & ConditionEffect.MAP_FILTER_BITMASK) != 0)
         {
            _loc21_ = [];
            if(player_.isDrunk())
            {
               _loc22_ = 20 + 10 * Math.sin(param2 / 1000);
               _loc21_.push(new BlurFilter(_loc22_,_loc22_));
            }
            if(player_.isBlind())
            {
               _loc21_.push(BLIND_FILTER);
            }
            map_.filters = _loc21_;
         }
         else if(map_.filters.length > 0)
         {
            map_.filters = [];
         }
         mapOverlay_.draw(param1,param2);
         partyOverlay_.draw(param1,param2);
      }
      
      private function getFilterIndex() : uint
      {
         var _loc1_:uint = 0;
         if(player_ != null && (player_.condition_[ConditionEffect.CE_FIRST_BATCH] & ConditionEffect.MAP_FILTER_BITMASK) != 0)
         {
            if(player_.isPaused())
            {
               _loc1_ = Renderer.STAGE3D_FILTER_PAUSE;
            }
            else if(player_.isBlind())
            {
               _loc1_ = Renderer.STAGE3D_FILTER_BLIND;
            }
            else if(player_.isDrunk())
            {
               _loc1_ = Renderer.STAGE3D_FILTER_DRUNK;
            }
         }
         return _loc1_;
      }
   }
}
